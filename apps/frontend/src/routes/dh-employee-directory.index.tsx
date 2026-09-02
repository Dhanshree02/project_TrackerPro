import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useMemo, useState, useEffect, useRef } from "react";
import {
  Search,
  Plus,
  ChevronLeft,
  ChevronRight,
  ChevronUp,
  ChevronDown,
  X,
  Users,
  Activity,
  Eye,
  UserPlus,
  FileText,
  RotateCcw,
} from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { useRoleContext } from "@/lib/role-context";
import { Avatar, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";
import {
  ALLOWED_WORK_EMAIL_DOMAINS,
  ALLOWED_WORK_EMAIL_DOMAIN_OPTIONS,
  FIELD_MAX,
  emailError,
  isAllowedWorkEmailDomain,
  isoDateToday,
  isoDateYearsAgo,
  isLettersName,
  phoneError,
  toDigits,
  toLettersName,
  toEmailInput,
  toEmailLocalPart,
  isValidEmailLocalPart,
  toTenDigitPhone,
} from "@/lib/form-validation";
import { CreatableCatalogSelect, SearchableSelect } from "@/components/creatable-catalog-select";
import { FORM_CONTROL_CLS, FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import { EmployeeBulkUploadMenu } from "@/components/employee-bulk-upload";
import {
  createBusinessUnitOption,
  createDepartmentOption,
  createDesignationOption,
  createEmployee,
  createJobRoleOption,
  createOfficeOption,
  createReportingManagerOption,
  createWorkLocationOption,
  fetchAllEmployees,
  fetchBusinessUnitOptions,
  fetchDepartmentOptions,
  fetchDesignationOptions,
  fetchEmailDomainOptions,
  fetchJobRoleOptions,
  fetchNationalityOptions,
  fetchOfficeOptions,
  fetchReportingManagerOptions,
  fetchSalaryBandOptions,
  fetchWorkLocationOptions,
  toUiEmployeeFromList,
  uploadEmployeeDocuments,
  type ApiMetaOption,
} from "@/lib/api/employees";
import {
  ONBOARD_DOC_SLOTS,
  MANDATORY_DOC_SLOTS,
  EMPTY_DOCS,
  EMPTY_ONBOARD,
  ONBOARD_FIELDS,
  MAX_ADULT_DOB,
  MIN_DOB,
  formatBytes,
  validateOnboardField,
  validateOnboardForm,
  validateOnboardFile,
  validateOnboardDocs,
  toDirectoryStatus,
  blankToNull,
  csvToList,
  type OnboardDocs,
  type OnboardDocErrors,
  type OnboardErrors,
  type OnboardField,
  type OnboardValues,
} from "@/lib/onboard-validation";
import { type Employee, type EmployeeStatus } from "@/lib/employee-data";
import { Modal } from "@/routes/projects.index";

export const Route = createFileRoute("/dh-employee-directory/")({
  validateSearch: (search: Record<string, unknown>): { tab?: "directory" | "pool" } => ({
    tab:
      search.tab === "directory" || search.tab === "pool"
        ? (search.tab as "directory" | "pool")
        : undefined,
  }),
  head: () => ({
    meta: [
      { title: "Directory & Resource Pool — Pulse PMO" },
      {
        name: "description",
        content: "Browse and manage the full employee directory & resource pool.",
      },
    ],
  }),
  component: EmployeeDirectoryPage,
});

const DEFAULT_PAGE_SIZE = 15;
const ENABLE_RESOURCE_POOL = true;

type DirectorySortKey =
  | "id"
  | "name"
  | "department"
  | "designation"
  | "reportingManager"
  | "workLocation"
  | "category"
  | "joiningDate"
  | "status"
  | "kpiScore";
type PoolSortKey =
  | "department"
  | "name"
  | "reportingManager"
  | "allocationStatus"
  | "officeBranch"
  | "workLocation"
  | "projectSite";
type SortDir = "asc" | "desc";

const DIRECTORY_COLUMNS: { label: string; key: DirectorySortKey; className?: string }[] = [
  { label: "TK ID", key: "id", className: "w-40 min-w-[145px]" },
  { label: "Name", key: "name", className: "w-52 min-w-[180px]" },
  { label: "Department", key: "department", className: "w-44 min-w-[150px]" },
  { label: "Designation", key: "designation", className: "w-52 min-w-[185px]" },
  { label: "Reporting Manager", key: "reportingManager", className: "w-48 min-w-[170px]" },
  { label: "Location", key: "workLocation", className: "w-36 min-w-[130px]" },
  { label: "Category", key: "category", className: "w-60 min-w-[210px]" },
  { label: "Joining Date", key: "joiningDate", className: "w-40 min-w-[145px]" },
  { label: "Status", key: "status", className: "w-36 min-w-[125px]" },
  { label: "KPI", key: "kpiScore", className: "w-28 min-w-[100px]" },
];

const BASIC_DIRECTORY_COLUMNS: { label: string; key: DirectorySortKey; className?: string }[] = [
  { label: "TK ID", key: "id", className: "w-40 min-w-[145px]" },
  { label: "Employee Name", key: "name", className: "w-52 min-w-[180px]" },
  { label: "Department", key: "department", className: "w-44 min-w-[150px]" },
  { label: "Designation", key: "designation", className: "w-64 min-w-[210px]" },
];

const POOL_COLUMNS: { label: string; key: PoolSortKey | null; className?: string; align?: "right" }[] = [
  { label: "Department", key: "department", className: "w-44 min-w-[150px]" },
  { label: "Employee Name", key: "name", className: "w-56 min-w-[190px]" },
  { label: "Reporting Manager", key: "reportingManager", className: "w-48 min-w-[170px]" },
  { label: "Allocation Status", key: "allocationStatus", className: "w-48 min-w-[170px]" },
  { label: "Allocation Type", key: null, className: "w-44 min-w-[150px]" },
  { label: "Allocation Duration", key: null, className: "w-48 min-w-[170px]" },
  { label: "Location", key: "workLocation", className: "w-36 min-w-[130px]" },
  { label: "Office", key: "officeBranch", className: "w-44 min-w-[150px]" },
  { label: "Project Site", key: "projectSite", className: "w-36 min-w-[130px]" },
  { label: "Tasks", key: null, className: "w-28 min-w-[100px]", align: "right" },
];

function sortBlank(value: string): string {
  return !value || value === "—" ? "" : value;
}

function compareEmployees(a: Employee, b: Employee, key: DirectorySortKey): number {
  if (key === "kpiScore") return a.kpiScore - b.kpiScore;
  if (key === "name") {
    return `${a.firstName} ${a.lastName}`.localeCompare(`${b.firstName} ${b.lastName}`, undefined, {
      sensitivity: "base",
    });
  }
  if (key === "id") {
    return a.id.localeCompare(b.id, undefined, { numeric: true, sensitivity: "base" });
  }
  const left = sortBlank(String(a[key] ?? ""));
  const right = sortBlank(String(b[key] ?? ""));
  return left.localeCompare(right, undefined, { numeric: true, sensitivity: "base" });
}

// ── Allocation Status type ──────────────────────────
type AllocationStatus = "OnLeave" | "Trainee" | "Unassigned";

function getAllocationStatus(e: Employee): AllocationStatus {
  if (e.status === "On Leave") return "OnLeave";
  if (e.category?.includes("Intern") || e.designation.toLowerCase().includes("intern"))
    return "Trainee";
  return "Unassigned";
}

const ALLOCATION_STATUS_ORDER: Record<AllocationStatus, number> = {
  OnLeave: 0,
  Trainee: 1,
  Unassigned: 2,
};

function comparePoolEmployees(a: Employee, b: Employee, key: PoolSortKey): number {
  if (key === "name") {
    return `${a.firstName} ${a.lastName}`.localeCompare(`${b.firstName} ${b.lastName}`, undefined, {
      sensitivity: "base",
    });
  }
  if (key === "allocationStatus") {
    return ALLOCATION_STATUS_ORDER[getAllocationStatus(a)] - ALLOCATION_STATUS_ORDER[getAllocationStatus(b)];
  }
  const valueFor = (e: Employee): string => {
    switch (key) {
      case "department":
        return e.department;
      case "reportingManager":
        return e.reportingManager;
      case "officeBranch":
        return e.officeBranch;
      case "workLocation":
        return e.workLocation;
      case "projectSite":
        return e.projectSite ?? "";
    }
  };
  return sortBlank(valueFor(a)).localeCompare(sortBlank(valueFor(b)), undefined, {
    numeric: true,
    sensitivity: "base",
  });
}

function SortableTh<T extends string>({
  label,
  column,
  sortKey,
  sortDir,
  onSort,
  className,
  isLast,
}: {
  label: string;
  column: T;
  sortKey: T;
  sortDir: SortDir;
  onSort: (column: T) => void;
  className?: string;
  isLast?: boolean;
}) {
  const active = sortKey === column;
  return (
    <th
      className={cn(
        "relative whitespace-nowrap px-4 py-3 font-semibold",
        className,
      )}
    >
      <button
        type="button"
        onClick={() => onSort(column)}
        className={cn(
          "group inline-flex items-center gap-1.5 text-left text-xs font-semibold transition-colors select-none",
          active
            ? "text-blue-600 dark:text-blue-400 font-bold"
            : "text-blue-950/85 hover:text-blue-600 dark:text-blue-100/85 dark:hover:text-blue-300",
        )}
        aria-sort={active ? (sortDir === "asc" ? "ascending" : "descending") : "none"}
        aria-label={`Sort by ${label}`}
      >
        <span>{label}</span>
        <span
          className={cn(
            "inline-flex h-4 w-4 shrink-0 items-center justify-center rounded transition-all duration-150",
            active
              ? "bg-blue-100 text-blue-600 dark:bg-blue-900/60 dark:text-blue-400"
              : "text-blue-400/40 opacity-0 group-hover:opacity-100 group-hover:text-blue-500",
          )}
        >
          {active && sortDir === "desc" ? (
            <ChevronDown className="h-3.5 w-3.5" />
          ) : (
            <ChevronUp className="h-3.5 w-3.5" />
          )}
        </span>
      </button>

      {/* Explicit Apple macOS-style vertical column divider */}
      {!isLast && (
        <span
          className="absolute right-0 top-2.5 bottom-2.5 w-[1.5px] bg-slate-400/80 dark:bg-slate-500 pointer-events-none"
          aria-hidden="true"
        />
      )}
    </th>
  );
}

function dash(value?: string | null): string {
  return value?.trim() && value !== "—" ? value : "—";
}

const DIRECTORY_STATUSES: EmployeeStatus[] = ["Active", "Probation", "Notice Period"];

// ── Allocation Status pill ───────────────────────────
function AllocationStatusBadge({ status }: { status: AllocationStatus }) {
  const map: Record<AllocationStatus, string> = {
    OnLeave: "border-amber-500/30 bg-amber-500/10 text-amber-600 dark:text-amber-400",
    Trainee: "border-slate-500/30 bg-slate-500/10 text-slate-600 dark:text-slate-400",
    Unassigned: "border-muted-foreground/30 bg-muted text-muted-foreground",
  };

  const labels: Record<AllocationStatus, string> = {
    OnLeave: "On Leave",
    Trainee: "Trainee",
    Unassigned: "—",
  };

  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-semibold tracking-wide shadow-xs",
        map[status],
      )}
    >
      {labels[status]}
    </span>
  );
}

// ── Status pill ────────────────────────────────────
function EmpStatusBadge({ status }: { status: string }) {
  const map: Record<string, string> = {
    Active: "border-success/30 bg-success/10 text-success",
    Probation: "border-warning/40 bg-warning/15 text-warning-foreground",
    "Notice Period": "border-destructive/30 bg-destructive/10 text-destructive",
    Inactive: "border-muted-foreground/30 bg-muted text-muted-foreground",
    "On Leave": "border-info/30 bg-info/10 text-info",
  };
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium",
        map[status] ?? "border-border bg-muted text-muted-foreground",
      )}
    >
      {status}
    </span>
  );
}

// ── Select helper ─────────────────────────────────
function FilterSelect({
  value,
  onChange,
  placeholder,
  options,
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder: string;
  options: string[];
}) {
  return (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className={cn(
        "h-9 w-full rounded-md border bg-card px-3 text-xs outline-none transition-all focus-visible:ring-2 focus-visible:ring-ring cursor-pointer",
        value
          ? "border-blue-500/50 font-medium text-foreground bg-blue-500/5"
          : "border-input text-muted-foreground",
      )}
    >
      <option value="">{placeholder}</option>
      {options.map((o) => (
        <option key={o} value={o}>
          {o}
        </option>
      ))}
    </select>
  );
}

function ResourceTasksModal({
  employee,
  onClose,
}: {
  employee: Employee;
  onClose: () => void;
}) {
  const isOnLeave = employee.status === "On Leave";

  return (
    <Modal
      title={`${employee.firstName} ${employee.lastName} — Workload & Tasks`}
      onClose={onClose}
      wide
    >
      <div className="grid gap-6 md:grid-cols-3">
        <div className="space-y-4">
          <div className="flex items-center gap-3 rounded-lg border border-border bg-accent/25 p-3">
            <Avatar name={`${employee.firstName} ${employee.lastName}`} size={42} />
            <div>
              <div className="text-sm font-semibold">
                {employee.firstName} {employee.lastName}
              </div>
              <div className="text-[11px] text-muted-foreground">
                {dash(employee.department)} · {dash(employee.designation)}
              </div>
              <div className="text-[11px] text-muted-foreground font-mono">{employee.id}</div>
              {isOnLeave && (
                <span className="mt-1 inline-flex rounded-full border border-amber-500/30 bg-amber-500/10 px-1.5 py-0.5 text-[9px] font-semibold uppercase text-amber-600 dark:text-amber-400">
                  On Leave
                </span>
              )}
            </div>
          </div>

          <div>
            <div className="mb-1.5 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
              Skills
            </div>
            <div className="flex flex-wrap gap-1">
              {employee.skills.length === 0 ? (
                <span className="text-sm text-muted-foreground">—</span>
              ) : (
                employee.skills.map((s) => (
                  <span
                    key={s}
                    className="rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] font-medium text-foreground/80"
                  >
                    {s}
                  </span>
                ))
              )}
            </div>
          </div>
        </div>

        <div className="md:col-span-2 space-y-3">
          <h4 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Active Projects & Tasks
          </h4>
          <p className="text-sm text-muted-foreground">
            Project assignments are not in the database yet. Allocation duration will show here once
            projects are wired.
          </p>
        </div>
      </div>
    </Modal>
  );
}

// ── Request Allocation Modal ──────────────────────
function RequestAllocationModal({
  employee,
  colleagues,
  onClose,
}: {
  employee: Employee;
  colleagues: Employee[];
  onClose: () => void;
}) {
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [comment, setComment] = useState("");
  const [taggedPeople, setTaggedPeople] = useState<Employee[]>([]);
  const [mentionQuery, setMentionQuery] = useState<string | null>(null);
  const [mentionIndex, setMentionIndex] = useState(-1);
  const [showDropdown, setShowDropdown] = useState(false);
  const [dropdownPosition, setDropdownPosition] = useState({ top: 0, left: 0 });

  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // Filter people for mentions
  const filteredPeople = useMemo(() => {
    if (mentionQuery === null) return [];
    return colleagues
      .filter((p) => {
        const name = `${p.firstName} ${p.lastName}`.toLowerCase();
        return name.includes(mentionQuery.toLowerCase()) && !taggedPeople.some((tp) => tp.id === p.id);
      })
      .slice(0, 5);
  }, [mentionQuery, taggedPeople, colleagues]);

  const handleTextareaChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value;
    setComment(value);

    const selectionStart = e.target.selectionStart;
    const beforeCursor = value.slice(0, selectionStart);

    // Check if user is typing a mention (word starting with @)
    const match = beforeCursor.match(/@(\w*)$/);
    if (match) {
      setMentionQuery(match[1]);
      setShowDropdown(true);

      // Calculate coordinates for the suggestions dropdown
      if (textareaRef.current) {
        const textLines = beforeCursor.split("\n");
        const currentLine = textLines.length;
        const currentCol = textLines[textLines.length - 1].length;
        setDropdownPosition({
          top: currentLine * 20 + 35,
          left: Math.min(250, currentCol * 8 + 10),
        });
      }
    } else {
      setShowDropdown(false);
      setMentionQuery(null);
    }
  };

  const handleSelectPerson = (person: Employee) => {
    if (!textareaRef.current) return;
    const value = comment;
    const selectionStart = textareaRef.current.selectionStart;
    const beforeCursor = value.slice(0, selectionStart);
    const afterCursor = value.slice(selectionStart);
    const name = `${person.firstName} ${person.lastName}`;

    const newBeforeCursor = beforeCursor.replace(/@(\w*)$/, `@${name} `);
    const newValue = newBeforeCursor + afterCursor;

    setComment(newValue);
    setTaggedPeople((prev) => {
      if (prev.some((p) => p.id === person.id)) return prev;
      return [...prev, person];
    });
    setShowDropdown(false);
    setMentionQuery(null);

    // Focus back on textarea and set cursor position
    setTimeout(() => {
      if (textareaRef.current) {
        textareaRef.current.focus();
        const newCursorPos = newBeforeCursor.length;
        textareaRef.current.setSelectionRange(newCursorPos, newCursorPos);
      }
    }, 0);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (showDropdown && filteredPeople.length > 0) {
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setMentionIndex((prev) => (prev + 1) % filteredPeople.length);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setMentionIndex((prev) => (prev - 1 + filteredPeople.length) % filteredPeople.length);
      } else if (e.key === "Enter" || e.key === "Tab") {
        e.preventDefault();
        const selected = filteredPeople[mentionIndex >= 0 ? mentionIndex : 0];
        if (selected) {
          handleSelectPerson(selected);
        }
      } else if (e.key === "Escape") {
        e.preventDefault();
        setShowDropdown(false);
        setMentionQuery(null);
      }
    }
  };

  const handleRemoveTag = (personId: string) => {
    setTaggedPeople((prev) => prev.filter((p) => p.id !== personId));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!startDate || !endDate) {
      toast.error("Please enter both start and end dates");
      return;
    }
    if (new Date(startDate) > new Date(endDate)) {
      toast.error("Start date cannot be after end date");
      return;
    }

    toast.success(
      `Allocation request for ${employee.firstName} ${employee.lastName} sent to ${employee.reportingManager}!`,
    );
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/40 backdrop-blur-[1px]" onClick={onClose} />

      {/* Modal Content */}
      <div
        className="relative w-full max-w-lg rounded-xl border border-border bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between border-b border-border pb-4">
          <div>
            <h2 className="text-base font-semibold text-foreground">Request Allocation</h2>
            <p className="text-xs text-muted-foreground">
              Request allocation of {employee.firstName} {employee.lastName} (ID: {employee.id})
            </p>
          </div>
          <button
            onClick={onClose}
            className="rounded-md p-1 text-muted-foreground hover:bg-accent transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Reporting Manager Display Header */}
        <div className="my-4 rounded-lg bg-primary/5 border border-primary/10 p-3.5 flex items-center justify-between">
          <div>
            <div className="text-[10px] uppercase font-bold tracking-wider text-primary/80">
              Routing To:
            </div>
            <div className="mt-0.5 text-sm font-semibold text-foreground">
              {employee.reportingManager}
            </div>
            <div className="text-[11px] text-muted-foreground font-medium">
              Reporting Manager Action Center
            </div>
          </div>
          <span className="inline-flex rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-medium text-primary">
            Auto-Routed
          </span>
        </div>

        <form autoComplete="off" onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">
                Start Date
              </span>
              <input
                autoComplete="off"
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                required
              />
            </label>
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">End Date</span>
              <input
                autoComplete="off"
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                required
              />
            </label>
          </div>

          <div className="relative">
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">
                Comments (Type @ to tag team members)
              </span>
              <textarea
                autoComplete="off"
                ref={textareaRef}
                value={comment}
                onChange={handleTextareaChange}
                onKeyDown={handleKeyDown}
                placeholder="Type @ to tag people from the directory…"
                className="w-full rounded-md border border-input bg-card p-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring min-h-[100px] resize-none"
              />
            </label>

            {/* Live @ Mentions Dropdown */}
            {showDropdown && filteredPeople.length > 0 && (
              <div
                className="absolute z-50 w-56 rounded-md border border-border bg-popover text-popover-foreground shadow-lg overflow-hidden py-1"
                style={{ top: `${dropdownPosition.top}px`, left: `${dropdownPosition.left}px` }}
              >
                {filteredPeople.map((p, idx) => (
                  <button
                    key={p.id}
                    type="button"
                    onClick={() => handleSelectPerson(p)}
                    onMouseEnter={() => setMentionIndex(idx)}
                    className={cn(
                      "w-full text-left px-3 py-1.5 text-xs flex items-center gap-2 hover:bg-accent hover:text-accent-foreground",
                      (mentionIndex === idx || (mentionIndex === -1 && idx === 0)) &&
                      "bg-accent text-accent-foreground",
                    )}
                  >
                    <Avatar name={`${p.firstName} ${p.lastName}`} size={20} />
                    <span>{p.firstName} {p.lastName}</span>
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Tagged people badges */}
          {taggedPeople.length > 0 && (
            <div>
              <span className="block text-xs font-medium text-muted-foreground mb-1.5">
                Tagged CC's ({taggedPeople.length}):
              </span>
              <div className="flex flex-wrap gap-1.5">
                {taggedPeople.map((p) => (
                  <span
                    key={p.id}
                    className="inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary/5 px-2.5 py-0.5 text-xs text-primary font-medium shadow-xs"
                  >
                    <Avatar name={`${p.firstName} ${p.lastName}`} size={16} />
                    <span>{p.firstName} {p.lastName}</span>
                    <button
                      type="button"
                      onClick={() => handleRemoveTag(p.id)}
                      className="ml-1 rounded-full p-0.5 hover:bg-primary/10 text-primary/70 hover:text-primary transition-colors"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                ))}
              </div>
            </div>
          )}

          <div className="flex items-center justify-end gap-2 border-t border-border pt-4 mt-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all"
            >
              Send Request
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function FormField({
  label,
  type = "text",
  placeholder = "",
  value,
  onChange,
  onBlur,
  error,
  required,
  className,
  name,
  maxLength,
  min,
  max,
  prefix,
  suffix,
  inputMode,
}: {
  label: string;
  type?: string;
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
  onBlur?: () => void;
  error?: string;
  required?: boolean;
  className?: string;
  /** Logical field id only — never emitted as a browser autofill name. */
  name?: string;
  maxLength?: number;
  min?: string;
  max?: string;
  prefix?: string;
  suffix?: string;
  inputMode?: React.HTMLAttributes<HTMLInputElement>["inputMode"];
}) {
  const resolvedMaxLength =
    type === "date" || type === "number" ? maxLength : (maxLength ?? FIELD_MAX.text);
  // Chrome ignores autoComplete="off". new-password + readOnly-until-focus is the reliable pair.
  const unlock = (el: HTMLInputElement) => {
    el.removeAttribute("readonly");
  };
  return (
    <label className={cn("block", className)}>
      <span className={FORM_LABEL_CLS}>
        {label}
        {required ? <span className="text-destructive"> *</span> : null}
      </span>
      <div className="relative flex rounded-md">
        {prefix ? (
          <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
            {prefix}
          </span>
        ) : null}
        <input
          id={name ? `onboard-${name}` : undefined}
          type={type === "email" ? "text" : type}
          placeholder={placeholder}
          autoComplete="new-password"
          autoCorrect="off"
          autoCapitalize="off"
          spellCheck={false}
          readOnly
          data-lpignore="true"
          data-1p-ignore="true"
          data-bwignore="true"
          data-form-type="other"
          maxLength={resolvedMaxLength}
          min={min}
          max={max}
          inputMode={inputMode === "email" ? "text" : inputMode}
          className={cn(
            FORM_CONTROL_CLS,
            prefix && "rounded-l-none",
            suffix && "pr-16",
            error && "border-destructive focus-visible:ring-destructive",
          )}
          {...(value !== undefined
            ? { value, onChange: (e: React.ChangeEvent<HTMLInputElement>) => onChange?.(e.target.value) }
            : {})}
          onFocus={(e) => unlock(e.currentTarget)}
          onMouseDown={(e) => unlock(e.currentTarget)}
          onBlur={onBlur}
          aria-label={label}
          aria-invalid={Boolean(error)}
          aria-required={required}
        />
        {suffix ? (
          <span className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">
            {suffix}
          </span>
        ) : null}
      </div>
      {error ? <p className={FORM_ERROR_CLS}>{error}</p> : null}
    </label>
  );
}

function FormTextarea({
  label,
  placeholder = "",
  value,
  onChange,
  onBlur,
  error,
  required,
  className,
  name,
  maxLength = FIELD_MAX.text,
  rows = 2,
}: {
  label: string;
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
  onBlur?: () => void;
  error?: string;
  required?: boolean;
  className?: string;
  name?: string;
  maxLength?: number;
  rows?: number;
}) {
  return (
    <label className={cn("block", className)}>
      <span className={FORM_LABEL_CLS}>
        {label}
        {required ? <span className="text-destructive"> *</span> : null}
      </span>
      <textarea
        id={name ? `onboard-${name}` : undefined}
        rows={rows}
        placeholder={placeholder}
        maxLength={maxLength}
        value={value ?? ""}
        onChange={(e) => onChange?.(e.target.value)}
        onBlur={onBlur}
        aria-label={label}
        aria-invalid={Boolean(error)}
        aria-required={required}
        className={cn(
          FORM_CONTROL_CLS,
          "h-auto min-h-[72px] py-2 leading-relaxed resize-y",
          error && "border-destructive focus-visible:ring-destructive",
        )}
      />
      {error ? <p className={FORM_ERROR_CLS}>{error}</p> : null}
    </label>
  );
}

function FormSelect({
  label,
  options,
  value,
  onChange,
  error,
  required,
  disabled,
  placeholder = "Select…",
}: {
  label: string;
  options: Array<string | { value: string; label: string; subLabel?: string }>;
  value?: string;
  onChange?: (value: string) => void;
  error?: string;
  required?: boolean;
  disabled?: boolean;
  placeholder?: string;
}) {
  return (
    <SearchableSelect
      label={label}
      options={options}
      value={value}
      onChange={onChange}
      error={error}
      required={required}
      disabled={disabled}
      placeholder={placeholder}
    />
  );
}

function FormSection({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-lg border border-border bg-card p-5">
      <h3 className="mb-4 text-sm font-semibold text-foreground">{title}</h3>
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">{children}</div>
    </section>
  );
}

function UploadSlot({
  label,
  file,
  files,
  multiple,
  required,
  error,
  onSelect,
  onSelectMultiple,
  onClear,
  onRemoveFile,
}: {
  label: string;
  file?: File | null;
  files?: File[];
  multiple?: boolean;
  required?: boolean;
  error?: string;
  onSelect?: (file: File) => void;
  onSelectMultiple?: (files: File[]) => void;
  onClear: () => void;
  onRemoveFile?: (index: number) => void;
}) {
  const inputId = `onboard-doc-${label.replace(/\s+/g, "-").toLowerCase()}`;
  const fileList = multiple ? files ?? [] : file ? [file] : [];
  const hasFiles = fileList.length > 0;

  return (
    <div className="flex flex-col space-y-1">
      <input
        id={inputId}
        type="file"
        multiple={multiple}
        accept=".pdf,.jpg,.jpeg,.png,application/pdf,image/jpeg,image/png"
        className="sr-only"
        onChange={(e) => {
          const selected = Array.from(e.target.files ?? []);
          if (selected.length > 0) {
            if (multiple && onSelectMultiple) {
              onSelectMultiple(selected);
            } else if (onSelect && selected[0]) {
              onSelect(selected[0]);
            }
          }
          e.target.value = "";
        }}
      />
      <div
        className={cn(
          "relative flex h-[144px] w-full flex-col items-center justify-between rounded-lg border-2 p-2.5 text-center transition-all",
          hasFiles
            ? error
              ? "border-destructive bg-destructive/5"
              : "border-primary/40 bg-primary/5 shadow-xs"
            : error
              ? "border-destructive/60 bg-destructive/5 hover:bg-destructive/10"
              : "border-dashed border-border bg-muted/20 hover:border-primary/50 hover:bg-muted/40",
        )}
      >
        {hasFiles ? (
          <>
            <div className="flex w-full flex-1 flex-col items-center justify-center min-h-0 overflow-hidden">
              <div className="flex items-center gap-1.5 text-primary mb-1 shrink-0">
                <FileText className="h-4 w-4" />
                {multiple && fileList.length > 1 ? (
                  <span className="rounded-full bg-primary/15 px-1.5 py-0.5 text-[10px] font-bold text-primary">
                    {fileList.length} files
                  </span>
                ) : null}
              </div>

              {multiple && fileList.length > 1 ? (
                <div className="w-full max-h-[55px] overflow-y-auto space-y-1 px-0.5 my-0.5 text-left text-[11px]">
                  {fileList.map((f, idx) => (
                    <div
                      key={`${f.name}-${idx}`}
                      className="flex items-center justify-between gap-1 rounded bg-background/90 px-1.5 py-0.5 text-[10px] border border-border/60"
                    >
                      <span className="truncate flex-1 font-medium text-foreground" title={f.name}>
                        {f.name}
                      </span>
                      {onRemoveFile && (
                        <button
                          type="button"
                          onClick={(e) => {
                            e.stopPropagation();
                            onRemoveFile(idx);
                          }}
                          className="shrink-0 text-muted-foreground hover:text-destructive p-0.5"
                          title="Remove file"
                        >
                          <X className="h-2.5 w-2.5" />
                        </button>
                      )}
                    </div>
                  ))}
                </div>
              ) : (
                <div className="w-full px-1">
                  <div
                    className="max-w-full truncate text-xs font-semibold text-foreground"
                    title={fileList[0].name}
                  >
                    {fileList[0].name}
                  </div>
                  <div className="text-[10px] text-muted-foreground mt-0.5">
                    {formatBytes(fileList[0].size)}
                  </div>
                </div>
              )}
            </div>

            <div className="mt-1 flex shrink-0 items-center justify-center gap-2 pt-1 border-t border-border/40 w-full text-[11px]">
              <label
                htmlFor={inputId}
                className="cursor-pointer font-medium text-primary hover:underline"
              >
                {multiple ? "+ Add More" : "Replace"}
              </label>
              <span className="text-muted-foreground/40">·</span>
              <button
                type="button"
                onClick={onClear}
                className="font-medium text-muted-foreground hover:text-destructive"
              >
                {multiple && fileList.length > 1 ? "Clear All" : "Remove"}
              </button>
            </div>
          </>
        ) : (
          <label
            htmlFor={inputId}
            className="flex h-full w-full cursor-pointer flex-col items-center justify-center"
          >
            <Plus className="mb-1.5 h-4 w-4 text-muted-foreground" />
            <div className="text-xs font-medium text-foreground line-clamp-1 leading-tight" title={label}>
              {label}
              {required ? <span className="text-destructive font-bold"> *</span> : null}
            </div>
            {multiple ? (
              <span className="mt-1 inline-block rounded bg-primary/10 px-1.5 py-0.5 text-[9px] font-semibold text-primary">
                Multi-file
              </span>
            ) : (
              <div className="text-[10px] text-muted-foreground mt-0.5">PDF, JPG · ≤ 5 MB</div>
            )}
          </label>
        )}
      </div>
      {error ? <p className="text-[10px] text-destructive leading-tight px-0.5">{error}</p> : null}
    </div>
  );
}

// ── Onboarding slide-over panel ───────────────────
function OnboardingPanel({
  open,
  onClose,
  onCreated,
  existingCodes,
  managers,
}: {
  open: boolean;
  onClose: () => void;
  onCreated: () => void;
  existingCodes: string[];
  managers: { id: string; name: string }[];
}) {
  const [form, setForm] = useState<OnboardValues>(EMPTY_ONBOARD);
  const [errors, setErrors] = useState<OnboardErrors>({});
  const [docs, setDocs] = useState<OnboardDocs>(EMPTY_DOCS);
  const [docErrors, setDocErrors] = useState<OnboardDocErrors>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [nationalities, setNationalities] = useState<ApiMetaOption[]>([]);
  const [deptOptions, setDeptOptions] = useState<ApiMetaOption[]>([]);
  const [desigOptions, setDesigOptions] = useState<ApiMetaOption[]>([]);
  const [roleOptions, setRoleOptions] = useState<ApiMetaOption[]>([]);
  const [salaryBands, setSalaryBands] = useState<ApiMetaOption[]>([]);
  const [emailDomainOptions, setEmailDomainOptions] = useState<ApiMetaOption[]>([]);
  const [managerOptions, setManagerOptions] = useState<ApiMetaOption[]>([]);
  const [buOptions, setBuOptions] = useState<ApiMetaOption[]>([]);
  const [workLocOptions, setWorkLocOptions] = useState<ApiMetaOption[]>([]);
  const [officeOptions, setOfficeOptions] = useState<ApiMetaOption[]>([]);
  const [workEmailPrefix, setWorkEmailPrefix] = useState("");
  const [workEmailDomain, setWorkEmailDomain] = useState("");

  useEffect(() => {
    if (open) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  useEffect(() => {
    if (!open) {
      setForm(EMPTY_ONBOARD);
      setErrors({});
      setDocs(EMPTY_DOCS);
      setDocErrors({});
      setIsSubmitting(false);
      setNationalities([]);
      setDeptOptions([]);
      setDesigOptions([]);
      setRoleOptions([]);
      setSalaryBands([]);
      setEmailDomainOptions([]);
      setManagerOptions([]);
      setBuOptions([]);
      setWorkLocOptions([]);
      setOfficeOptions([]);
      setWorkEmailPrefix("");
      setWorkEmailDomain("");
      return;
    }
    void fetchNationalityOptions()
      .then(setNationalities)
      .catch(() => toast.error("Could not load nationalities"));
    void fetchDepartmentOptions()
      .then(setDeptOptions)
      .catch(() => toast.error("Could not load departments"));
    void fetchSalaryBandOptions()
      .then(setSalaryBands)
      .catch(() => toast.error("Could not load salary bands"));
    void fetchBusinessUnitOptions()
      .then(setBuOptions)
      .catch(() => toast.error("Could not load business units"));
    void fetchWorkLocationOptions()
      .then((locs) => setWorkLocOptions(locs ?? []))
      .catch(() => toast.error("Could not load work locations"));
    void fetchOfficeOptions()
      .then((offs) => setOfficeOptions(offs ?? []))
      .catch(() => toast.error("Could not load offices"));
    void fetchReportingManagerOptions()
      .then((mgrs) => setManagerOptions(mgrs ?? []))
      .catch(() => toast.error("Could not load reporting managers"));
    void fetchEmailDomainOptions()
      .then((domains) => {
        const filtered = (domains ?? []).filter((d) =>
          isAllowedWorkEmailDomain(d.code.replace(/^@/, ""))
        );
        const list = filtered.length > 0 ? filtered : ALLOWED_WORK_EMAIL_DOMAIN_OPTIONS;
        setEmailDomainOptions(list);
        if (list.length > 0) {
          const firstDomain = list[0].code.replace(/^@/, "");
          setWorkEmailDomain(firstDomain);
        }
      })
      .catch(() => {
        setEmailDomainOptions(ALLOWED_WORK_EMAIL_DOMAIN_OPTIONS);
        setWorkEmailDomain("talakunchi.com");
      });
  }, [open, managers]);

  useEffect(() => {
    if (!open || !form.departmentId) {
      setDesigOptions([]);
      return;
    }
    void fetchDesignationOptions(form.departmentId)
      .then(setDesigOptions)
      .catch(() => setDesigOptions([]));
  }, [open, form.departmentId]);

  useEffect(() => {
    if (!open || !form.designationId) {
      setRoleOptions([]);
      return;
    }
    void fetchJobRoleOptions(form.designationId)
      .then(setRoleOptions)
      .catch(() => setRoleOptions([]));
  }, [open, form.designationId]);

  const selectedWorkLoc = useMemo(() => {
    if (!form.workLocation) return undefined;
    const target = form.workLocation.trim().toLowerCase();
    return workLocOptions.find(
      (l) =>
        l.name.toLowerCase() === target ||
        l.id.toLowerCase() === target ||
        (l.code && l.code.toLowerCase() === target),
    );
  }, [workLocOptions, form.workLocation]);

  const availableOffices = useMemo(() => {
    if (!selectedWorkLoc) return [];
    return officeOptions.filter((o) => o.parentId === selectedWorkLoc.id);
  }, [officeOptions, selectedWorkLoc]);

  if (!open) return null;

  const setField = (field: OnboardField, value: string) => {
    const nextValue =
      field === "phone" || field === "altPhone" || field === "emergencyContact"
        ? toTenDigitPhone(value)
        : field === "firstName" || field === "lastName"
          ? toLettersName(value)
          : field === "workEmail" || field === "personalEmail"
            ? toEmailInput(value)
            : field === "probationPeriod"
              ? toDigits(value, FIELD_MAX.probationMonths)
              : field === "noticePeriod"
                ? toDigits(value, FIELD_MAX.noticeDays)
                : value;

    setForm((prev) => {
      const next = { ...prev, [field]: nextValue };
      if (field === "departmentId") {
        next.designationId = "";
        next.jobRoleId = "";
      }
      if (field === "designationId") next.jobRoleId = "";
      return next;
    });

    const live =
      field === "phone" ||
      field === "altPhone" ||
      field === "emergencyContact" ||
      field === "workEmail" ||
      field === "personalEmail";

    setErrors((prev) => {
      if (
        !live &&
        !prev[field] &&
        !(field === "workEmail" && prev.personalEmail) &&
        !(field === "personalEmail" && prev.workEmail)
      ) {
        return prev;
      }
      const nextErrors = { ...prev };
      const simulatedNext = { ...form, [field]: nextValue };
      const message = validateOnboardField(field, simulatedNext, existingCodes);
      if (message) nextErrors[field] = message;
      else delete nextErrors[field];
      if (field === "workEmail" && simulatedNext.personalEmail.trim()) {
        const personalMsg = validateOnboardField("personalEmail", simulatedNext, existingCodes);
        if (personalMsg) nextErrors.personalEmail = personalMsg;
        else delete nextErrors.personalEmail;
      }
      return nextErrors;
    });
  };

  const blurField = (field: OnboardField) => {
    if (field === "workEmail" || field === "personalEmail") {
      const trimmed = form[field].trim();
      if (trimmed !== form[field]) {
        setField(field, trimmed);
        return;
      }
    }
    const message = validateOnboardField(field, form, existingCodes);
    setErrors((prev) => {
      const nextErrors = { ...prev };
      if (message) nextErrors[field] = message;
      else delete nextErrors[field];
      return nextErrors;
    });
  };

  const handleDocSelect = (slot: (typeof ONBOARD_DOC_SLOTS)[number], file: File) => {
    const message = validateOnboardFile(file);
    setDocErrors((prev) => {
      const next = { ...prev };
      if (message) next[slot] = message;
      else delete next[slot];
      return next;
    });
    if (message) {
      toast.error(message);
      return;
    }
    setDocs((prev) => ({ ...prev, [slot]: file }));
  };

  const handleDocSelectMultiple = (
    slot: (typeof ONBOARD_DOC_SLOTS)[number],
    incomingFiles: File[],
  ) => {
    for (const file of incomingFiles) {
      const message = validateOnboardFile(file);
      if (message) {
        setDocErrors((prev) => ({ ...prev, [slot]: message }));
        toast.error(message);
        return;
      }
    }
    setDocErrors((prev) => {
      const next = { ...prev };
      delete next[slot];
      return next;
    });
    setDocs((prev) => {
      const currentList = Array.isArray(prev[slot]) ? (prev[slot] as File[]) : [];
      const combined = [...currentList];
      for (const f of incomingFiles) {
        if (!combined.some((x) => x.name === f.name && x.size === f.size)) {
          combined.push(f);
        }
      }
      return { ...prev, [slot]: combined };
    });
  };

  const handleRemoveSingleDocFile = (
    slot: (typeof ONBOARD_DOC_SLOTS)[number],
    fileIndex: number,
  ) => {
    setDocs((prev) => {
      const currentList = Array.isArray(prev[slot]) ? (prev[slot] as File[]) : [];
      const updated = currentList.filter((_, idx) => idx !== fileIndex);
      return { ...prev, [slot]: updated };
    });
  };

  const handleCreate = async (e?: React.FormEvent) => {
    e?.preventDefault();
    const nextErrors = validateOnboardForm(form, existingCodes);
    setErrors(nextErrors);
    const nextDocErrors = validateOnboardDocs(docs);
    setDocErrors(nextDocErrors);
    if (Object.keys(nextErrors).length > 0 || Object.keys(nextDocErrors).length > 0) {
      toast.error("Please complete all mandatory fields and required documents");
      return;
    }
    setIsSubmitting(true);
    try {
      let resolvedDepartmentId = form.departmentId || null;
      if (resolvedDepartmentId && resolvedDepartmentId.startsWith("__new__")) {
        const rawName = resolvedDepartmentId.replace(/^__new__/, "");
        const createdDept = await createDepartmentOption(rawName);
        resolvedDepartmentId = createdDept.id;
        setDeptOptions((prev) =>
          prev.map((d) => (d.id === form.departmentId ? createdDept : d)),
        );
      }

      let resolvedDesignationId = form.designationId || null;
      if (resolvedDesignationId && resolvedDesignationId.startsWith("__new__")) {
        const rawName = resolvedDesignationId.replace(/^__new__/, "");
        if (!resolvedDepartmentId) {
          toast.error("Department is required for the new designation");
          setIsSubmitting(false);
          return;
        }
        const createdDesig = await createDesignationOption(rawName, resolvedDepartmentId);
        resolvedDesignationId = createdDesig.id;
        setDesigOptions((prev) =>
          prev.map((d) => (d.id === form.designationId ? createdDesig : d)),
        );
      }

      let resolvedJobRoleId = form.jobRoleId || null;
      let resolvedRoleName = roleOptions.find((r) => r.id === form.jobRoleId)?.name ?? null;
      if (resolvedJobRoleId && resolvedJobRoleId.startsWith("__new__")) {
        const rawName = resolvedJobRoleId.replace(/^__new__/, "");
        if (!resolvedDesignationId) {
          toast.error("Designation is required for the new role");
          setIsSubmitting(false);
          return;
        }
        const createdRole = await createJobRoleOption(rawName, resolvedDesignationId);
        resolvedJobRoleId = createdRole.id;
        resolvedRoleName = createdRole.name;
        setRoleOptions((prev) =>
          prev.map((r) => (r.id === form.jobRoleId ? createdRole : r)),
        );
      }

      let resolvedReportingManagerId = form.reportingManagerId.trim() || null;
      if (resolvedReportingManagerId && resolvedReportingManagerId.startsWith("__new__")) {
        const rawName = resolvedReportingManagerId.replace(/^__new__/, "");
        const createdMgr = await createReportingManagerOption(rawName);
        resolvedReportingManagerId = createdMgr.id;
        setManagerOptions((prev) =>
          prev.map((m) => (m.id === form.reportingManagerId ? createdMgr : m)),
        );
      }

      let resolvedBusinessUnit = form.businessUnit.trim() || null;
      if (resolvedBusinessUnit && resolvedBusinessUnit.startsWith("__new__")) {
        const rawName = resolvedBusinessUnit.replace(/^__new__/, "");
        const createdBu = await createBusinessUnitOption(rawName);
        resolvedBusinessUnit = createdBu.name;
        setBuOptions((prev) =>
          prev.map((b) => (b.id === form.businessUnit ? createdBu : b)),
        );
      }

      let resolvedWorkLocation = form.workLocation.trim() || null;
      let resolvedWorkLocId: string | undefined = selectedWorkLoc?.id;
      if (resolvedWorkLocation && resolvedWorkLocation.startsWith("__new__")) {
        const rawName = resolvedWorkLocation.replace(/^__new__/, "");
        const createdLoc = await createWorkLocationOption(rawName);
        resolvedWorkLocation = createdLoc.name;
        resolvedWorkLocId = createdLoc.id;
        setWorkLocOptions((prev) =>
          prev.map((w) => (w.id === form.workLocation ? createdLoc : w)),
        );
      }

      let resolvedOffice = form.officeBranch.trim() || null;
      if (resolvedOffice && resolvedOffice.startsWith("__new__")) {
        const rawName = resolvedOffice.replace(/^__new__/, "");
        const createdOff = await createOfficeOption(rawName, resolvedWorkLocId);
        resolvedOffice = createdOff.name;
        setOfficeOptions((prev) =>
          prev.map((o) => (o.id === form.officeBranch ? createdOff : o)),
        );
      }

      const probationLabel = form.probationPeriod.trim()
        ? `${form.probationPeriod.trim()} months`
        : null;
      const employmentStatus = form.status.trim() || "Active";
      const empCode = form.employeeCode.trim();

      await createEmployee({
        employeeCode: empCode,
        firstName: form.firstName.trim(),
        lastName: form.lastName.trim(),
        workEmail: form.workEmail.trim(),
        personalEmail: blankToNull(form.personalEmail),
        phone: blankToNull(form.phone),
        altPhone: blankToNull(form.altPhone),
        gender: blankToNull(form.gender),
        dateOfBirth: blankToNull(form.dateOfBirth),
        address: blankToNull(form.address),
        emergencyContact: blankToNull(form.emergencyContact),
        maritalStatus: blankToNull(form.maritalStatus),
        nationality: nationalities.find((n) => n.id === form.nationalityId)?.name ?? null,
        nationalityId: form.nationalityId || null,
        departmentId: resolvedDepartmentId,
        designationId: resolvedDesignationId,
        jobRoleId: resolvedJobRoleId,
        role: resolvedRoleName,
        reportingManagerId: resolvedReportingManagerId,
        businessUnit: resolvedBusinessUnit,
        workLocation: resolvedWorkLocation,
        officeBranch: resolvedOffice,
        category: blankToNull(form.category),
        team: blankToNull(form.team),
        joiningDate: blankToNull(form.joiningDate),
        status: toDirectoryStatus(employmentStatus),
        confirmationStatus: employmentStatus,
        probationStatus: employmentStatus === "Active - Probation" ? "Ongoing" : "Completed",
        probationPeriod: probationLabel,
        experience: blankToNull(form.experience),
        previousCompany: blankToNull(form.previousCompany),
        employmentType: blankToNull(form.employmentType),
        contractType: blankToNull(form.contractType),
        bondStatus: blankToNull(form.bondStatus),
        noticePeriod: form.noticePeriod.trim() ? `${form.noticePeriod.trim()} days` : null,
        projectSite: blankToNull(form.projectSite),
        assetId: blankToNull(form.assetId),
        exitType: form.exitType.trim() || "NA",
        exitReason: blankToNull(form.exitReason) ?? "NA",
        education: blankToNull(form.education),
        skills: [...csvToList(form.technicalSkills), ...csvToList(form.functionalSkills)],
        certifications: csvToList(form.certifications),
        languages: csvToList(form.languages),
        pan: form.pan.trim().toUpperCase() || null,
        aadhaar: form.aadhaar.replace(/\D/g, "") || null,
        bankAccount: blankToNull(form.bankAccount),
        pfUan: blankToNull(form.pfUan),
        salaryBandId: form.salaryBandId || null,
        salaryBand: salaryBands.find((b) => b.id === form.salaryBandId)?.name ?? null,
      });

      // Upload attached documents to local backend storage
      const uploadPromises: Promise<void>[] = [];
      let totalFilesUploaded = 0;
      for (const slot of ONBOARD_DOC_SLOTS) {
        const docItem = docs[slot];
        if (Array.isArray(docItem) && docItem.length > 0) {
          totalFilesUploaded += docItem.length;
          uploadPromises.push(uploadEmployeeDocuments(empCode, slot, docItem));
        } else if (docItem && !Array.isArray(docItem)) {
          totalFilesUploaded += 1;
          uploadPromises.push(uploadEmployeeDocuments(empCode, slot, [docItem]));
        }
      }
      if (uploadPromises.length > 0) {
        await Promise.allSettled(uploadPromises);
      }

      onCreated();
      toast.success(
        totalFilesUploaded > 0
          ? `Employee created with ${totalFilesUploaded} document${totalFilesUploaded === 1 ? "" : "s"} saved to storage`
          : "Employee created successfully",
      );
      onClose();
    } catch (error: any) {
      toast.error(error?.message ?? "Failed to create employee");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative flex h-full w-full max-w-4xl flex-col bg-background shadow-2xl">
        {/* header */}
        <div className="flex items-center justify-between border-b border-border bg-card px-6 py-4">
          <div>
            <h2 className="text-base font-semibold">Onboard New Employee</h2>
            <p className="text-xs text-muted-foreground">
              Fill in employee details to create their profile.
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1.5 text-muted-foreground hover:bg-accent"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <form
          noValidate
          autoComplete="off"
          autoCorrect="off"
          data-lpignore="true"
          data-1p-ignore="true"
          data-form-type="other"
          onSubmit={handleCreate}
          className="relative flex min-h-0 flex-1 flex-col"
        >
          {/* Decoy fields absorb Chrome autofill so real onboard inputs stay clean. */}
          <div aria-hidden="true" className="pointer-events-none absolute h-0 w-0 overflow-hidden opacity-0">
            <input type="text" name="username" autoComplete="username" tabIndex={-1} defaultValue="" />
            <input type="email" name="email" autoComplete="email" tabIndex={-1} defaultValue="" />
            <input type="password" name="password" autoComplete="new-password" tabIndex={-1} defaultValue="" />
          </div>
          {/* scrollable body */}
          <div className="flex-1 space-y-5 overflow-y-auto px-6 py-6">
            <FormSection title="1. Personal Information">
              <FormField
                label="First Name"
                name="firstName"
                required
                maxLength={FIELD_MAX.firstName}
                placeholder="First name"
                value={form.firstName}
                onChange={(v) => setField("firstName", v)}
                onBlur={() => blurField("firstName")}
                error={errors.firstName}
              />
              <FormField
                label="Last Name"
                name="lastName"
                required
                maxLength={FIELD_MAX.lastName}
                placeholder="Last name"
                value={form.lastName}
                onChange={(v) => setField("lastName", v)}
                onBlur={() => blurField("lastName")}
                error={errors.lastName}
              />
              <div>
                <label className="block">
                  <span className={FORM_LABEL_CLS}>
                    Work Email <span className="text-destructive">*</span>
                  </span>
                  <div className="relative flex rounded-md">
                    <input
                      id="onboard-workEmail"
                      type="text"
                      placeholder="john.doe"
                      autoComplete="new-password"
                      autoCorrect="off"
                      autoCapitalize="off"
                      spellCheck={false}
                      readOnly
                      data-lpignore="true"
                      data-1p-ignore="true"
                      data-bwignore="true"
                      data-form-type="other"
                      maxLength={64}
                      value={workEmailPrefix}
                      onChange={(e) => {
                        const cleanPrefix = toEmailLocalPart(e.target.value);
                        setWorkEmailPrefix(cleanPrefix);
                        const fullEmail = cleanPrefix ? `${cleanPrefix}@${workEmailDomain}` : "";
                        setForm((prev) => ({ ...prev, workEmail: fullEmail }));
                        setErrors((prev) => {
                          const next = { ...prev };
                          if (!cleanPrefix) next.workEmail = "Work email is required";
                          else if (!isValidEmailLocalPart(cleanPrefix)) next.workEmail = "Only alphanumeric and '.' allowed";
                          else delete next.workEmail;
                          return next;
                        });
                      }}
                      onFocus={(e) => e.currentTarget.removeAttribute("readonly")}
                      onMouseDown={(e) => e.currentTarget.removeAttribute("readonly")}
                      onBlur={() => {
                        if (!workEmailPrefix) {
                          setErrors((prev) => ({ ...prev, workEmail: "Work email is required" }));
                        } else if (!isValidEmailLocalPart(workEmailPrefix)) {
                          setErrors((prev) => ({ ...prev, workEmail: "Only alphanumeric and '.' allowed" }));
                        }
                      }}
                      className={cn(
                        FORM_CONTROL_CLS,
                        "rounded-r-none pr-2",
                        errors.workEmail && "border-destructive focus-visible:ring-destructive",
                      )}
                      aria-label="Email username"
                    />
                    <select
                      value={workEmailDomain}
                      onChange={(e) => {
                        const newDomain = e.target.value;
                        setWorkEmailDomain(newDomain);
                        const fullEmail = workEmailPrefix ? `${workEmailPrefix}@${newDomain}` : "";
                        setForm((prev) => ({ ...prev, workEmail: fullEmail }));
                        if (workEmailPrefix && isValidEmailLocalPart(workEmailPrefix)) {
                          setErrors((prev) => {
                            const next = { ...prev };
                            delete next.workEmail;
                            return next;
                          });
                        }
                      }}
                      className="h-9 shrink-0 rounded-r-md border border-l-0 border-input bg-muted/70 pl-2.5 pr-8 min-w-[130px] text-xs font-semibold text-foreground outline-none hover:bg-muted focus-visible:border-primary focus-visible:ring-2 focus-visible:ring-ring cursor-pointer transition-colors"
                      aria-label="Email domain"
                    >
                      {emailDomainOptions.length === 0 ? (
                        <option value="" disabled>Loading domains…</option>
                      ) : (
                        emailDomainOptions.map((opt) => {
                          const domainVal = opt.code.replace(/^@/, "");
                          return (
                            <option key={opt.id || opt.code} value={domainVal}>
                              {opt.name.startsWith("@") ? opt.name : `@${opt.name}`}
                            </option>
                          );
                        })
                      )}
                    </select>
                  </div>
                  {errors.workEmail ? <p className={FORM_ERROR_CLS}>{errors.workEmail}</p> : null}
                </label>
              </div>
              <FormField
                label="Personal Email"
                name="personalEmail"
                type="text"
                maxLength={FIELD_MAX.email}
                placeholder="name@example.com"
                value={form.personalEmail}
                onChange={(v) => setField("personalEmail", v)}
                onBlur={() => blurField("personalEmail")}
                error={errors.personalEmail}
              />
              <FormField
                label="Phone (Personal)"
                name="phone"
                required
                inputMode="numeric"
                maxLength={FIELD_MAX.phone}
                placeholder="10-digit number"
                prefix="+91"
                value={form.phone}
                onChange={(v) => setField("phone", v)}
                onBlur={() => blurField("phone")}
                error={errors.phone}
              />
              <FormField
                label="Alternate Contact Number"
                name="altPhone"
                inputMode="numeric"
                maxLength={FIELD_MAX.phone}
                placeholder="10-digit number"
                prefix="+91"
                value={form.altPhone}
                onChange={(v) => setField("altPhone", v)}
                onBlur={() => blurField("altPhone")}
                error={errors.altPhone}
              />
              <FormField
                label="Emergency Contact"
                name="emergencyContact"
                required
                inputMode="numeric"
                maxLength={FIELD_MAX.phone}
                placeholder="10-digit number"
                prefix="+91"
                value={form.emergencyContact}
                onChange={(v) => setField("emergencyContact", v)}
                onBlur={() => blurField("emergencyContact")}
                error={errors.emergencyContact}
              />
              <FormSelect
                label="Gender"
                required
                error={errors.gender}
                options={["Male", "Female", "Other"]}
                value={form.gender}
                onChange={(v) => setField("gender", v)}
              />
              <FormField
                label="Date of Birth"
                type="date"
                required
                value={form.dateOfBirth}
                min={MIN_DOB}
                max={MAX_ADULT_DOB}
                onChange={(v) => setField("dateOfBirth", v)}
                onBlur={() => blurField("dateOfBirth")}
                error={errors.dateOfBirth}
              />
              <FormSelect
                label="Marital Status"
                options={["Single", "Married", "Other"]}
                value={form.maritalStatus}
                onChange={(v) => setField("maritalStatus", v)}
              />
              <FormSelect
                label="Nationality"
                required
                error={errors.nationalityId}
                options={nationalities.map((n) => ({ value: n.id, label: n.name }))}
                value={form.nationalityId}
                onChange={(v) => setField("nationalityId", v)}
              />
              <div className="md:col-span-2">
                <FormTextarea
                  label="Address"
                  name="address"
                  required
                  error={errors.address}
                  maxLength={FIELD_MAX.address}
                  placeholder="Street address, city, state, PIN code"
                  value={form.address}
                  onChange={(v) => setField("address", v)}
                />
              </div>
            </FormSection>

            <FormSection title="2. Organization Assignment">
              <FormField
                label="TK ID"
                name="employeeCode"
                required
                placeholder="e.g. TK-0001 (or TKI-0001 for Intern)"
                maxLength={FIELD_MAX.employeeCode}
                value={form.employeeCode}
                onChange={(v) => setField("employeeCode", v)}
                onBlur={() => blurField("employeeCode")}
                error={errors.employeeCode}
              />
              <CreatableCatalogSelect
                label="Department"
                required
                error={errors.departmentId}
                options={deptOptions}
                valueId={form.departmentId}
                onSelect={(id) => setField("departmentId", id)}
                onCreate={(name) => {
                  const trimmed = name.trim();
                  const existing = deptOptions.find(
                    (d) => d.name.toLowerCase() === trimmed.toLowerCase(),
                  );
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setDeptOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <CreatableCatalogSelect
                label="Designation"
                required
                error={errors.designationId}
                options={desigOptions}
                valueId={form.designationId}
                disabled={!form.departmentId}
                disabledHint="Select a department first"
                onSelect={(id) => setField("designationId", id)}
                onCreate={(name) => {
                  const trimmed = name.trim();
                  const existing = desigOptions.find(
                    (d) => d.name.toLowerCase() === trimmed.toLowerCase(),
                  );
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setDesigOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <CreatableCatalogSelect
                label="Role"
                options={roleOptions}
                valueId={form.jobRoleId}
                disabled={!form.designationId}
                disabledHint="Select a designation first"
                onSelect={(id) => setField("jobRoleId", id)}
                onCreate={(name) => {
                  const trimmed = name.trim();
                  const existing = roleOptions.find(
                    (r) => r.name.toLowerCase() === trimmed.toLowerCase(),
                  );
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setRoleOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <CreatableCatalogSelect
                label="Reporting Manager"
                required
                error={errors.reportingManagerId}
                options={managerOptions}
                valueId={form.reportingManagerId}
                placeholder="Select reporting manager"
                onSelect={(id) => setField("reportingManagerId", id)}
                onCreate={(name) => {
                  const trimmed = name.trim();
                  const existing = managerOptions.find(
                    (m) => m.name.toLowerCase() === trimmed.toLowerCase(),
                  );
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setManagerOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <CreatableCatalogSelect
                label="Business Unit"
                options={buOptions}
                valueId={buOptions.find((b) => b.name === form.businessUnit || b.id === form.businessUnit)?.id ?? form.businessUnit}
                placeholder="Select business unit"
                onSelect={(id, name) => setField("businessUnit", name || id)}
                onCreate={(name) => {
                  const trimmed = name.trim();
                  const existing = buOptions.find((b) => b.name.toLowerCase() === trimmed.toLowerCase());
                  if (existing) return existing;
                  const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                  setBuOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
              <FormField
                label="Team"
                placeholder="Enter team or squad name"
                maxLength={FIELD_MAX.team}
                value={form.team}
                onChange={(v) => setField("team", v)}
              />
              <FormSelect
                label="Project Site"
                options={["Onsite", "Offsite"]}
                value={form.projectSite}
                onChange={(v) => setField("projectSite", v)}
              />
              <CreatableCatalogSelect
                label="Work Location"
                required
                error={errors.workLocation}
                options={workLocOptions}
                valueId={selectedWorkLoc?.id ?? form.workLocation}
                placeholder="Select work location"
                onSelect={(id, name) => {
                  const resolvedName = name || id;
                  const loc = workLocOptions.find(
                    (l) =>
                      l.id === id ||
                      l.name.toLowerCase() === resolvedName.toLowerCase() ||
                      (l.code && l.code.toLowerCase() === resolvedName.toLowerCase()),
                  );
                  const matchedOffices = loc ? officeOptions.filter((o) => o.parentId === loc.id) : [];
                  const autoOffice =
                    matchedOffices.length === 1
                      ? matchedOffices[0].name
                      : matchedOffices.some(
                            (o) => o.name.toLowerCase() === form.officeBranch.toLowerCase(),
                          )
                        ? form.officeBranch
                        : "";
                  setForm((prev) => ({
                    ...prev,
                    workLocation: loc ? loc.name : resolvedName,
                    officeBranch: autoOffice,
                  }));
                }}
                onCreate={async (name) => {
                  const trimmed = name.trim();
                  const existing = workLocOptions.find((w) => w.name.toLowerCase() === trimmed.toLowerCase());
                  if (existing) return existing;
                  try {
                    const created = await createWorkLocationOption(trimmed);
                    setWorkLocOptions((prev) => [...prev, created]);
                    return created;
                  } catch {
                    const temp = { id: `__new__${trimmed}`, code: `__new__${trimmed}`, name: trimmed };
                    setWorkLocOptions((prev) => [...prev, temp]);
                    return temp;
                  }
                }}
              />
              <CreatableCatalogSelect
                label="Office"
                required
                error={errors.officeBranch}
                options={availableOffices}
                valueId={availableOffices.find((o) => o.name.toLowerCase() === form.officeBranch.toLowerCase() || o.id === form.officeBranch)?.id ?? form.officeBranch}
                disabled={!selectedWorkLoc}
                disabledHint="Select a work location first"
                placeholder={selectedWorkLoc ? "Select office branch" : "Select a work location first"}
                onSelect={(id, name) => {
                  const resolvedName = name || id;
                  const off = availableOffices.find(
                    (o) =>
                      o.id === id ||
                      o.name.toLowerCase() === resolvedName.toLowerCase(),
                  );
                  setForm((prev) => ({
                    ...prev,
                    officeBranch: off ? off.name : resolvedName,
                  }));
                }}
                onCreate={async (name) => {
                  const trimmed = name.trim();
                  const existing = availableOffices.find((o) => o.name.toLowerCase() === trimmed.toLowerCase());
                  if (existing) return existing;
                  if (selectedWorkLoc && !selectedWorkLoc.id.startsWith("__new__")) {
                    try {
                      const created = await createOfficeOption(trimmed, selectedWorkLoc.id);
                      setOfficeOptions((prev) => [...prev, created]);
                      return created;
                    } catch {
                      // fallback
                    }
                  }
                  const temp = {
                    id: `__new__${trimmed}`,
                    code: `__new__${trimmed}`,
                    name: trimmed,
                    parentId: selectedWorkLoc?.id,
                  };
                  setOfficeOptions((prev) => [...prev, temp]);
                  return temp;
                }}
              />
            </FormSection>

            <FormSection title="3. Employment Information">
              <FormField
                label="Date of Joining"
                type="date"
                required
                min={isoDateToday()}
                value={form.joiningDate}
                onChange={(v) => setField("joiningDate", v)}
                onBlur={() => blurField("joiningDate")}
                error={errors.joiningDate}
              />
              <FormSelect
                label="Category"
                options={[
                  "Permanent - Bond",
                  "Permanent - Without Bond",
                  "Contract-based",
                  "Intern - Paid",
                  "Intern - Unpaid",
                ]}
                value={form.category}
                onChange={(v) => setField("category", v)}
              />
              <FormField
                label="Asset ID"
                placeholder="e.g. AST-1001"
                maxLength={FIELD_MAX.assetId}
                value={form.assetId}
                onChange={(v) => setField("assetId", v)}
              />
              <FormSelect
                label="Employment Status"
                required
                error={errors.status}
                options={[
                  "Active - Probation",
                  "Active",
                ]}
                value={form.status}
                onChange={(v) => setField("status", v)}
              />
              <FormField
                label="Probation Period"
                inputMode="numeric"
                maxLength={FIELD_MAX.probationMonths}
                placeholder="e.g. 6"
                suffix="months"
                value={form.probationPeriod}
                onChange={(v) => setField("probationPeriod", v)}
                onBlur={() => blurField("probationPeriod")}
                error={errors.probationPeriod}
              />
              <FormField
                label="Notice Period"
                inputMode="numeric"
                maxLength={FIELD_MAX.noticeDays}
                placeholder="e.g. 90"
                suffix="days"
                value={form.noticePeriod}
                onChange={(v) => setField("noticePeriod", v)}
                onBlur={() => blurField("noticePeriod")}
                error={errors.noticePeriod}
              />
              <FormSelect
                label="Salary Band"
                required
                error={errors.salaryBandId}
                options={salaryBands.map((b) => ({ value: b.id, label: b.name }))}
                value={form.salaryBandId}
                onChange={(v) => setField("salaryBandId", v)}
              />
              <FormSelect
                label="Employment Type"
                required
                error={errors.employmentType}
                options={["Full-time", "Part-time", "Contract"]}
                value={form.employmentType}
                onChange={(v) => setField("employmentType", v)}
              />
              <FormSelect
                label="Contract Type"
                options={["Permanent", "Fixed-term"]}
                value={form.contractType}
                onChange={(v) => setField("contractType", v)}
              />
              <FormSelect
                label="Bond Status"
                options={["Yes", "No"]}
                value={form.bondStatus}
                onChange={(v) => setField("bondStatus", v)}
              />
            </FormSection>

            <FormSection title="4. Skills & Qualifications">
              <FormField
                label="Highest Qualification"
                maxLength={FIELD_MAX.education}
                placeholder="e.g. Bachelor of Technology / Master of Business Administration"
                value={form.education}
                onChange={(v) => setField("education", v)}
              />
              <FormField
                label="Certifications"
                placeholder="e.g. AWS Certified Solutions Architect, Scrum Master"
                maxLength={FIELD_MAX.certifications}
                value={form.certifications}
                onChange={(v) => setField("certifications", v)}
              />
              <FormField
                label="Technical Skills"
                placeholder="e.g. React, Node.js, TypeScript, PostgreSQL"
                maxLength={FIELD_MAX.skills}
                value={form.technicalSkills}
                onChange={(v) => setField("technicalSkills", v)}
              />
              <FormField
                label="Functional Skills"
                placeholder="e.g. Stakeholder Management, Team Leadership"
                maxLength={FIELD_MAX.skills}
                value={form.functionalSkills}
                onChange={(v) => setField("functionalSkills", v)}
              />
              <FormField
                label="Experience"
                placeholder="e.g. 5 years"
                maxLength={FIELD_MAX.experience}
                value={form.experience}
                onChange={(v) => setField("experience", v)}
              />
              <FormField
                label="Previous Organization"
                placeholder="e.g. Previous Employer Name"
                maxLength={FIELD_MAX.previousCompany}
                value={form.previousCompany}
                onChange={(v) => setField("previousCompany", v)}
              />
              <FormField
                label="Languages Known"
                placeholder="e.g. English, Hindi, Marathi"
                maxLength={FIELD_MAX.text}
                value={form.languages}
                onChange={(v) => setField("languages", v)}
              />
            </FormSection>

            <FormSection title="5. Compliance Information">
              <FormField
                label="PAN Number"
                name="pan"
                required
                maxLength={10}
                placeholder="e.g. ABCDE1234F"
                value={form.pan}
                onChange={(v) => setField("pan", v.toUpperCase())}
                onBlur={() => blurField("pan")}
                error={errors.pan}
              />
              <FormField
                label="Aadhaar Number"
                name="aadhaar"
                required
                inputMode="numeric"
                maxLength={12}
                placeholder="Enter 12-digit Aadhaar number"
                value={form.aadhaar}
                onChange={(v) => setField("aadhaar", v)}
                onBlur={() => blurField("aadhaar")}
                error={errors.aadhaar}
              />
              <FormField
                label="PF/UAN Number"
                name="pfUan"
                inputMode="numeric"
                maxLength={12}
                placeholder="Enter 12-digit UAN number"
                value={form.pfUan}
                onChange={(v) => setField("pfUan", v)}
                onBlur={() => blurField("pfUan")}
                error={errors.pfUan}
              />
              <FormField
                label="Bank Account Number"
                name="bankAccount"
                required
                inputMode="numeric"
                maxLength={18}
                placeholder="Enter bank account number"
                value={form.bankAccount}
                onChange={(v) => setField("bankAccount", v)}
                onBlur={() => blurField("bankAccount")}
                error={errors.bankAccount}
              />
              <FormField
                label="IFSC Code"
                name="ifsc"
                required
                maxLength={11}
                placeholder="e.g. SBIN0001234"
                value={form.ifsc}
                onChange={(v) => setField("ifsc", v.toUpperCase())}
                onBlur={() => blurField("ifsc")}
                error={errors.ifsc}
              />
            </FormSection>

            <section className="rounded-lg border border-border bg-card p-5">
              <div className="mb-4 flex items-center justify-between">
                <div>
                  <h3 className="text-sm font-semibold text-foreground">6. Document Uploads</h3>
                  <p className="text-xs text-muted-foreground mt-0.5">
                    Attach employee verification documents (PDF, JPG, PNG up to 5 MB each). Multiple files supported for Certificates & Experience Letters.
                  </p>
                </div>
              </div>
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {ONBOARD_DOC_SLOTS.map((d) => {
                  const isMulti = d === "Education Certs" || d === "Experience Letters";
                  return (
                    <UploadSlot
                      key={d}
                      label={d}
                      required={MANDATORY_DOC_SLOTS.includes(d)}
                      multiple={isMulti}
                      file={!isMulti ? (docs[d] as File | null) : null}
                      files={isMulti ? (docs[d] as File[]) : undefined}
                      error={docErrors[d]}
                      onSelect={(file) => handleDocSelect(d, file)}
                      onSelectMultiple={(files) => handleDocSelectMultiple(d, files)}
                      onRemoveFile={(idx) => handleRemoveSingleDocFile(d, idx)}
                      onClear={() => {
                        setDocs((prev) => ({ ...prev, [d]: isMulti ? [] : null }));
                        setDocErrors((prev) => {
                          const next = { ...prev };
                          delete next[d];
                          return next;
                        });
                      }}
                    />
                  );
                })}
              </div>
            </section>
          </div>

          {/* footer */}
          <div className="flex items-center justify-end gap-2 border-t border-border bg-card px-6 py-4">
            <button
              type="button"
              onClick={onClose}
              className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-60"
            >
              Create Employee
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

// ── Main page ────────────────────────────────────
function EmployeeDirectoryPage() {
  const { status: authStatus } = useAuth();
  const { isDhanshree, isHr, isEmployee, isPmFamily, isPmoFamily, isAccounts, isSales } =
    useRoleContext();
  const { tab: searchTab } = Route.useSearch();
  const basicDirectoryView =
    isHr || isEmployee || isPmFamily || isPmoFamily || isAccounts || isSales;
  const [tab, setTabState] = useState<"directory" | "pool">("directory");
  const navigate = useNavigate({ from: Route.fullPath });

  useEffect(() => {
    if (!searchTab) return;
    void navigate({ search: (prev) => ({ ...prev, tab: undefined }), replace: true });
  }, [searchTab, navigate]);

  const [q, setQ] = useState("");
  const [dept, setDept] = useState("");
  const [desig, setDesig] = useState("");
  const [status, setStatus] = useState("");
  const [deptCatalog, setDeptCatalog] = useState<ApiMetaOption[]>([]);
  const [desigCatalog, setDesigCatalog] = useState<ApiMetaOption[]>([]);

  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);
  const [onboardOpen, setOnboardOpen] = useState(false);
  const [dbEmployees, setDbEmployees] = useState<Employee[]>([]);
  const [managers, setManagers] = useState<{ id: string; name: string }[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [sortKey, setSortKey] = useState<DirectorySortKey>("id");
  const [sortDir, setSortDir] = useState<SortDir>("asc");
  const [poolSortKey, setPoolSortKey] = useState<PoolSortKey>("department");
  const [poolSortDir, setPoolSortDir] = useState<SortDir>("asc");

  // Pool modal states
  const [selectedEmployee, setSelectedEmployee] = useState<Employee | null>(null);
  const [allocReqEmployee, setAllocReqEmployee] = useState<Employee | null>(null);

  const setTab = (newTab: "directory" | "pool") => {
    if (!ENABLE_RESOURCE_POOL && newTab === "pool") return;
    if (basicDirectoryView) return;
    setTabState(newTab);
  };

  const loadEmployees = async () => {
    setIsLoading(true);
    setLoadError(null);
    try {
      const items = await fetchAllEmployees();
      setDbEmployees(items.map(toUiEmployeeFromList));
      setManagers(items.map((item) => ({ id: item.id, name: item.fullName })));
    } catch (error: any) {
      const message = error?.message ?? "Failed to load employees from database";
      setLoadError(message);
      setDbEmployees([]);
      setManagers([]);
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (authStatus !== "authed") return;
    void loadEmployees();
    void fetchDepartmentOptions()
      .then(setDeptCatalog)
      .catch(() => toast.error("Could not load departments"));
    void fetchDesignationOptions()
      .then(setDesigCatalog)
      .catch(() => toast.error("Could not load designations"));
  }, [authStatus]);

  const departmentFilterOptions = useMemo(
    () => [...new Set(deptCatalog.map((d) => d.name).filter(Boolean))],
    [deptCatalog],
  );

  const designationFilterOptions = useMemo(() => {
    const selectedDept = deptCatalog.find((d) => d.name === dept);
    const scoped = selectedDept
      ? desigCatalog.filter((d) => d.parentId === selectedDept.id)
      : desigCatalog;
    return [...new Set(scoped.map((d) => d.name).filter(Boolean))];
  }, [desigCatalog, deptCatalog, dept]);

  // ── Deep Comprehensive Employee Search ──
  const matchesEmployeeSearch = (e: Employee, query: string): boolean => {
    if (!query) return true;
    const terms = query.toLowerCase().trim().split(/\s+/).filter(Boolean);
    if (terms.length === 0) return true;

    const searchableText = [
      e.id,
      e.firstName,
      e.lastName,
      `${e.firstName} ${e.lastName}`,
      e.email,
      e.personalEmail,
      e.phone,
      e.altPhone,
      e.emergencyContact,
      e.gender,
      e.dob,
      e.address,
      e.nationality,
      e.maritalStatus,
      e.department,
      e.designation,
      e.role,
      e.businessUnit,
      e.workLocation,
      e.officeBranch,
      e.category,
      e.team,
      e.joiningDate,
      e.status,
      e.confirmationStatus,
      e.probationStatus,
      e.experience,
      e.previousCompany,
      e.employmentType,
      e.contractType,
      e.bondStatus,
      e.noticePeriod,
      e.projectSite,
      e.assetId,
      e.exitType,
      e.exitReason,
      e.education,
      ...(e.skills ?? []),
      ...(e.certifications ?? []),
      ...(e.languages ?? []),
      e.pan,
      e.bankAccount,
      e.pfUan,
      e.salaryBand,
      e.taxRegime,
      e.complianceStatus,
      e.managerFeedback,
      e.promotionReadiness,
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase();

    return terms.every((term) => searchableText.includes(term));
  };

  // ── Directory Filtering ──
  const directoryRows = useMemo(() => {
    const filtered = dbEmployees.filter((e) => {
      const matchQ = matchesEmployeeSearch(e, q);
      return (
        matchQ &&
        (!dept || e.department === dept) &&
        (!desig || e.designation === desig) &&
        (!status || e.status === status)
      );
    });
    return [...filtered].sort((a, b) => {
      const cmp = compareEmployees(a, b, sortKey);
      return sortDir === "asc" ? cmp : -cmp;
    });
  }, [dbEmployees, q, dept, desig, status, sortKey, sortDir]);

  // ── Pool Filtering ──
  const poolRows = useMemo(() => {
    const filtered = dbEmployees.filter((e) => {
      const matchQ = matchesEmployeeSearch(e, q);
      return (
        matchQ &&
        (!dept || e.department === dept) &&
        (!desig || e.designation === desig) &&
        (!status || e.status === status)
      );
    });
    return [...filtered].sort((a, b) => {
      const cmp = comparePoolEmployees(a, b, poolSortKey);
      return poolSortDir === "asc" ? cmp : -cmp;
    });
  }, [dbEmployees, q, dept, desig, status, poolSortKey, poolSortDir]);

  // Determine active rows based on tab
  const activeRows = tab === "directory" ? directoryRows : poolRows;

  const totalPages = Math.max(1, Math.ceil(activeRows.length / pageSize));
  const currentPage = Math.min(page, totalPages);
  const pageRows = activeRows.slice((currentPage - 1) * pageSize, currentPage * pageSize);

  // Reset page when filters, tab, or pageSize change
  useEffect(() => {
    setPage(1);
  }, [q, dept, desig, status, tab, sortKey, sortDir, poolSortKey, poolSortDir, pageSize]);

  // Admin and HR both manage the full employee directory (HR uses it for
  // onboarding); every other role is redirected.
  if (!isDhanshree && !basicDirectoryView) return <Navigate to="/" />;

  const title = basicDirectoryView ? "Directory" : "Directory & Resource Pool";
  const subtitle =
    tab === "directory"
      ? `${activeRows.length} of ${dbEmployees.length} employees`
      : `${activeRows.length} of ${dbEmployees.length} resources active`;

  const hasActiveFilters = Boolean(q || dept || desig || status);
  const clearAllFilters = () => {
    setQ("");
    setDept("");
    setDesig("");
    setStatus("");
  };

  return (
    <AppShell title={title} subtitle={subtitle}>
      {/* Search & Filters (Left) + View Switcher & Add Button (Right) */}
      <div className="mb-4 flex flex-col gap-3 xl:flex-row xl:items-center xl:justify-between">
        {/* Left Side: Search & Filters */}
        <div className="flex flex-wrap items-center gap-2 flex-1 min-w-0">
          <div className="relative w-full sm:w-56 shrink-0">
            <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search by name, role, or ID..."
              className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-7 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring transition-all"
            />
            {q && (
              <button
                type="button"
                onClick={() => setQ("")}
                className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                aria-label="Clear search"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>

          <div className="w-full sm:w-40 shrink-0">
            <FilterSelect
              value={dept}
              onChange={(value) => {
                setDept(value);
                setDesig("");
              }}
              placeholder="All Departments"
              options={departmentFilterOptions}
            />
          </div>
          <div className="w-full sm:w-44 shrink-0">
            <FilterSelect
              value={desig}
              onChange={setDesig}
              placeholder="All Designations"
              options={designationFilterOptions}
            />
          </div>
          <div className="w-full sm:w-36 shrink-0">
            <FilterSelect
              value={status}
              onChange={setStatus}
              placeholder="All Statuses"
              options={DIRECTORY_STATUSES}
            />
          </div>

          {hasActiveFilters && (
            <button
              type="button"
              onClick={clearAllFilters}
              className="inline-flex items-center gap-1 rounded-md border border-border/80 bg-muted/50 px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
            >
              <RotateCcw className="h-3 w-3" />
              Reset
            </button>
          )}
        </div>

        {/* Right Side: Tab Switcher (with BLUE active pill) & Add Button */}
        <div className="flex flex-wrap items-center justify-between sm:justify-end gap-2.5 shrink-0">
          {!basicDirectoryView && ENABLE_RESOURCE_POOL && (
            <div className="flex gap-0.5 rounded-lg border border-border/80 bg-muted/60 p-1 text-xs shadow-inner">
              <button
                onClick={() => setTab("directory")}
                aria-label="Directory view"
                className={cn(
                  "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-all duration-150",
                  tab === "directory"
                    ? "bg-blue-600 text-white shadow-xs"
                    : "text-muted-foreground hover:text-foreground",
                )}
              >
                <Users className="h-3.5 w-3.5" />
                Directory
              </button>
              <button
                onClick={() => setTab("pool")}
                aria-label="Pool view"
                className={cn(
                  "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-all duration-150",
                  tab === "pool"
                    ? "bg-blue-600 text-white shadow-xs"
                    : "text-muted-foreground hover:text-foreground",
                )}
              >
                <Activity className="h-3.5 w-3.5" />
                Resource Pool
              </button>
            </div>
          )}

          {(isDhanshree || isHr) && (
            <>
              <EmployeeBulkUploadMenu
                onImported={() => {
                  void loadEmployees();
                  void fetchDepartmentOptions().then(setDeptCatalog).catch(() => undefined);
                  void fetchDesignationOptions().then(setDesigCatalog).catch(() => undefined);
                }}
              />
              <button
                onClick={() => setOnboardOpen(true)}
                className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all"
              >
                <Plus className="h-4 w-4" />
                Add Employee
              </button>
            </>
          )}
        </div>
      </div>

      {/* Directory Table / Pool Table */}
      {tab === "directory" ? (
        <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
          <div className="overflow-auto max-h-[calc(100vh-210px)] min-h-[500px]">
            <table className={cn("w-full text-sm table-fixed", basicDirectoryView ? "min-w-[800px]" : "min-w-[1440px]")}>
              <thead className="sticky top-0 z-10 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700 shadow-2xs">
                <tr>
                  {(basicDirectoryView ? BASIC_DIRECTORY_COLUMNS : DIRECTORY_COLUMNS).map((col, idx, arr) => (
                    <SortableTh
                      key={col.key}
                      label={col.label}
                      column={col.key}
                      sortKey={sortKey}
                      sortDir={sortDir}
                      className={col.className}
                      isLast={idx === arr.length - 1}
                      onSort={(next) => {
                        if (sortKey === next) setSortDir((d) => (d === "asc" ? "desc" : "asc"));
                        else {
                          setSortKey(next);
                          setSortDir("asc");
                        }
                      }}
                    />
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {pageRows.map((e) => (
                  <tr
                    key={e.id}
                    onClick={() =>
                      navigate({ to: "/dh-employee-directory/$id", params: { id: e.id } })
                    }
                    className="cursor-pointer transition-colors hover:bg-accent/30"
                  >
                    <td className={cn("whitespace-nowrap px-4 py-3.5 font-mono text-xs text-muted-foreground truncate", basicDirectoryView ? "w-32 min-w-[120px]" : "w-32 min-w-[120px]")} title={e.id}>
                      {e.id}
                    </td>
                    <td className={cn("whitespace-nowrap px-4 py-3.5", basicDirectoryView ? "w-52 min-w-[180px]" : "w-52 min-w-[180px]")}>
                      <Link
                        to="/dh-employee-directory/$id"
                        params={{ id: e.id }}
                        className="flex items-center gap-2.5 hover:text-primary transition-colors min-w-0"
                      >
                        <Avatar name={`${e.firstName} ${e.lastName}`} size={28} />
                        <span className="font-semibold truncate" title={`${e.firstName} ${e.lastName}`}>
                          {e.firstName} {e.lastName}
                        </span>
                      </Link>
                    </td>
                    <td className={cn("whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate", basicDirectoryView ? "w-44 min-w-[150px]" : "w-44 min-w-[150px]")} title={e.department}>
                      {dash(e.department)}
                    </td>
                    <td className={cn("whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate", basicDirectoryView ? "w-64 min-w-[210px]" : "w-52 min-w-[185px]")} title={e.designation}>
                      {dash(e.designation)}
                    </td>
                    {!basicDirectoryView && (
                      <>
                        <td className="w-44 min-w-[150px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.reportingManager}>
                          {dash(e.reportingManager)}
                        </td>
                        <td className="w-36 min-w-[120px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.workLocation}>
                          {dash(e.workLocation)}
                        </td>
                        <td className="w-60 min-w-[210px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.category}>
                          {dash(e.category)}
                        </td>
                        <td className="w-32 min-w-[110px] whitespace-nowrap px-4 py-3.5 text-muted-foreground">
                          {dash(e.joiningDate)}
                        </td>
                        <td className="w-36 min-w-[120px] whitespace-nowrap px-4 py-3.5">
                          <EmpStatusBadge status={e.status} />
                        </td>
                        <td className="w-28 min-w-[100px] whitespace-nowrap px-4 py-3.5">
                          <div className="flex items-center gap-2">
                            <ProgressBar value={e.kpiScore} className="w-14" />
                            <span className="text-xs font-medium tabular-nums">{e.kpiScore}</span>
                          </div>
                        </td>
                      </>
                    )}
                  </tr>
                ))}
                {pageRows.length === 0 && (
                  <tr>
                    <td
                      colSpan={basicDirectoryView ? 4 : 10}
                      className="px-4 py-10 text-center text-sm text-muted-foreground"
                    >
                      {isLoading
                        ? "Loading employees from database…"
                        : loadError
                          ? `Could not load employees: ${loadError}`
                          : dbEmployees.length === 0
                            ? "No employees in database yet. Use Add Employee to create one."
                            : "No employees match your filters"}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Frozen / Sticky Pagination Footer */}
          <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-slate-300 dark:border-slate-700 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80 shadow-xs">
            <div className="flex items-center gap-3">
              <span>
                Showing <strong className="font-semibold text-blue-950 dark:text-blue-100">{activeRows.length === 0 ? 0 : (currentPage - 1) * pageSize + 1}</strong>–
                <strong className="font-semibold text-blue-950 dark:text-blue-100">
                  {Math.min(currentPage * pageSize, activeRows.length)}
                </strong>{" "}
                of <strong className="font-semibold text-blue-950 dark:text-blue-100">{activeRows.length}</strong> employees
              </span>
              <span className="text-slate-300 dark:text-slate-600">|</span>
              <div className="flex items-center gap-1.5">
                <span>Per page:</span>
                <select
                  value={pageSize}
                  onChange={(e) => setPageSize(Number(e.target.value))}
                  className="h-7 w-14 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-950/60 pl-2 pr-5 text-xs font-medium text-blue-950 dark:text-blue-100 outline-none cursor-pointer hover:bg-blue-100/50 dark:hover:bg-blue-900/40 transition-colors focus-visible:ring-1 focus-visible:ring-blue-500"
                  aria-label="Rows per page"
                >
                  <option value={10}>10</option>
                  <option value={15}>15</option>
                  <option value={25}>25</option>
                  <option value={50}>50</option>
                  <option value={100}>100</option>
                </select>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={currentPage <= 1}
                className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                <ChevronLeft className="h-3.5 w-3.5" /> Previous
              </button>
              <span className="px-2 tabular-nums font-semibold text-blue-950 dark:text-blue-100">
                {currentPage} / {totalPages}
              </span>
              <button
                type="button"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage >= totalPages}
                className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                Next <ChevronRight className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>
        </div>
      ) : (
        <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
          <div className="overflow-auto max-h-[calc(100vh-210px)] min-h-[500px]">
            <table className="w-full min-w-[1440px] table-fixed text-sm">
              <thead className="sticky top-0 z-10 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700 shadow-2xs">
                <tr>
                  {POOL_COLUMNS.map((col, idx, arr) =>
                    col.key ? (
                      <SortableTh
                        key={col.label}
                        label={col.label}
                        column={col.key}
                        sortKey={poolSortKey}
                        sortDir={poolSortDir}
                        className={col.className}
                        isLast={idx === arr.length - 1}
                        onSort={(next) => {
                          if (poolSortKey === next) setPoolSortDir((d) => (d === "asc" ? "desc" : "asc"));
                          else {
                            setPoolSortKey(next);
                            setPoolSortDir("asc");
                          }
                        }}
                      />
                    ) : (
                      <th
                        key={col.label}
                        className={cn(
                          "relative whitespace-nowrap px-4 py-3.5 font-semibold text-xs text-blue-950/85 dark:text-blue-100/85",
                          col.className,
                          col.align === "right" ? "text-right" : "text-left",
                        )}
                      >
                        {col.label}
                        {idx < arr.length - 1 && (
                          <span
                            className="absolute right-0 top-2.5 bottom-2.5 w-[1.5px] bg-slate-400/80 dark:bg-slate-500 pointer-events-none"
                            aria-hidden="true"
                          />
                        )}
                      </th>
                    ),
                  )}
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {pageRows.map((e) => {
                  const statusVal = getAllocationStatus(e);
                  return (
                    <tr
                      key={e.id}
                      onClick={() =>
                        navigate({ to: "/dh-employee-directory/$id", params: { id: e.id } })
                      }
                      className="cursor-pointer transition-colors hover:bg-accent/30"
                    >
                      <td className="w-40 min-w-[140px] whitespace-nowrap px-4 py-3.5 font-semibold text-foreground/90 truncate" title={e.department}>
                        {dash(e.department)}
                      </td>
                      <td className="w-56 min-w-[190px] whitespace-nowrap px-4 py-3.5">
                        <Link
                          to="/dh-employee-directory/$id"
                          params={{ id: e.id }}
                          className="flex items-center gap-2.5 hover:text-primary transition-colors min-w-0"
                        >
                          <Avatar name={`${e.firstName} ${e.lastName}`} size={28} />
                          <span className="font-semibold truncate" title={`${e.firstName} ${e.lastName}`}>
                            {e.firstName} {e.lastName}
                          </span>
                        </Link>
                      </td>
                      <td className="w-44 min-w-[150px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.reportingManager}>
                        {dash(e.reportingManager)}
                      </td>
                      <td className="w-48 min-w-[170px] whitespace-nowrap px-4 py-3.5">
                        <AllocationStatusBadge status={statusVal} />
                      </td>
                      <td className="w-44 min-w-[150px] whitespace-nowrap px-4 py-3.5 text-muted-foreground">—</td>
                      <td className="w-48 min-w-[170px] whitespace-nowrap px-4 py-3.5 text-muted-foreground">—</td>
                      <td className="w-36 min-w-[120px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.workLocation}>
                        {dash(e.workLocation)}
                      </td>
                      <td className="w-44 min-w-[150px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.officeBranch}>
                        {dash(e.officeBranch)}
                      </td>
                      <td className="w-32 min-w-[110px] whitespace-nowrap px-4 py-3.5">
                        {e.projectSite === "Onsite" || e.projectSite === "Offsite" ? (
                          <span
                            className={cn(
                              "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium",
                              e.projectSite === "Onsite"
                                ? "border-info/30 bg-info/10 text-info"
                                : "border-muted-foreground/30 bg-muted text-muted-foreground",
                            )}
                          >
                            {e.projectSite}
                          </span>
                        ) : (
                          "—"
                        )}
                      </td>
                      <td className="w-28 min-w-[100px] whitespace-nowrap px-4 py-3.5 text-right">
                        <button
                          onClick={(evt) => {
                            evt.stopPropagation();
                            setAllocReqEmployee(e);
                          }}
                          title="Request Allocation"
                          className="mr-1.5 inline-flex h-7 px-2.5 items-center justify-center gap-1 rounded-md border border-primary/20 bg-primary/5 text-xs font-semibold text-primary hover:bg-primary/10 transition-colors"
                        >
                          <UserPlus className="h-3.5 w-3.5" />
                        </button>
                        <button
                          onClick={(evt) => {
                            evt.stopPropagation();
                            setSelectedEmployee(e);
                          }}
                          className="inline-flex h-7 px-2.5 items-center justify-center gap-1 rounded-md border border-input bg-card text-xs font-semibold text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
                        >
                          <Eye className="h-3.5 w-3.5" />
                        </button>
                      </td>
                    </tr>
                  );
                })}
                {pageRows.length === 0 && (
                  <tr>
                    <td colSpan={10} className="px-4 py-12 text-center text-sm text-muted-foreground">
                      No resources match the selected criteria.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Frozen / Sticky Pagination Footer */}
          <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-slate-300 dark:border-slate-700 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80 shadow-xs">
            <div className="flex items-center gap-3">
              <span>
                Showing <strong className="font-semibold text-blue-950 dark:text-blue-100">{activeRows.length === 0 ? 0 : (currentPage - 1) * pageSize + 1}</strong>–
                <strong className="font-semibold text-blue-950 dark:text-blue-100">
                  {Math.min(currentPage * pageSize, activeRows.length)}
                </strong>{" "}
                of <strong className="font-semibold text-blue-950 dark:text-blue-100">{activeRows.length}</strong> resources
              </span>
              <span className="text-slate-300 dark:text-slate-600">|</span>
              <div className="flex items-center gap-1.5">
                <span>Per page:</span>
                <select
                  value={pageSize}
                  onChange={(e) => setPageSize(Number(e.target.value))}
                  className="h-7 w-14 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-950/60 pl-2 pr-5 text-xs font-medium text-blue-950 dark:text-blue-100 outline-none cursor-pointer hover:bg-blue-100/50 dark:hover:bg-blue-900/40 transition-colors focus-visible:ring-1 focus-visible:ring-blue-500"
                  aria-label="Rows per page"
                >
                  <option value={10}>10</option>
                  <option value={15}>15</option>
                  <option value={25}>25</option>
                  <option value={50}>50</option>
                  <option value={100}>100</option>
                </select>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={currentPage <= 1}
                className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                <ChevronLeft className="h-3.5 w-3.5" /> Previous
              </button>
              <span className="px-2 tabular-nums font-semibold text-blue-950 dark:text-blue-100">
                {currentPage} / {totalPages}
              </span>
              <button
                type="button"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage >= totalPages}
                className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                Next <ChevronRight className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Onboarding panel */}
      <OnboardingPanel
        open={onboardOpen}
        onClose={() => setOnboardOpen(false)}
        existingCodes={dbEmployees.map((e) => e.id)}
        managers={managers}
        onCreated={() => {
          void loadEmployees();
          void fetchDepartmentOptions().then(setDeptCatalog).catch(() => undefined);
          void fetchDesignationOptions().then(setDesigCatalog).catch(() => undefined);
        }}
      />

      {/* Interactive Workload Tasks Modal */}
      {selectedEmployee && (
        <ResourceTasksModal employee={selectedEmployee} onClose={() => setSelectedEmployee(null)} />
      )}

      {/* Allocation Request Modal */}
      {allocReqEmployee && (
        <RequestAllocationModal
          employee={allocReqEmployee}
          colleagues={dbEmployees}
          onClose={() => setAllocReqEmployee(null)}
        />
      )}
    </AppShell>
  );
}
