import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { createPortal } from "react-dom";
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
  joinTkId,
  splitTkId,
  toTenDigitPhone,
  toDecimalNumberInput,
  type TkIdPrefix,
} from "@/lib/form-validation";
import { CreatableCatalogSelect, SearchableSelect } from "@/components/creatable-catalog-select";
import { TkIdField } from "@/components/tk-id-field";
import { WorkEmailField } from "@/components/work-email-field";
import { FORM_CONTROL_CLS, FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import { EmployeeBulkUploadMenu } from "@/components/employee-bulk-upload";
import { RowsPerPageSelect } from "@/components/rows-per-page-select";
import { paginateSlice, paginationRange, totalPageCount } from "@/lib/pagination";
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
  fetchEmployeeStatusOptions,
  fetchNationalityOptions,
  fetchOfficeOptions,
  fetchReportingManagerOptions,
  fetchWorkLocationOptions,
  fetchCertificationOptions,
  createCertificationOption,
  fetchGraduationDegreeOptions,
  createGraduationDegreeOption,
  fetchPostGraduationDegreeOptions,
  createPostGraduationDegreeOption,
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
  blankToNull,
  csvToList,
  EMERGENCY_RELATION_OPTIONS,
  BILLABLE_STATUS_OPTIONS,
  PROJECT_TYPE_OPTIONS,
  PMO_DEPARTMENT_OPTIONS,
  PMO_DEPARTMENT_SUB_DEPARTMENTS,
  formatExpDisplay,
  type OnboardDocs,
  type OnboardDocErrors,
  type OnboardErrors,
  type OnboardField,
  type OnboardValues,
} from "@/lib/onboard-validation";
import {
  WORKER_TYPES,
  BOND_DELIVERED_OPTIONS,
  computeBondStatus,
  formatBondExpiryDisplay,
} from "@/lib/employment-bond";
import { type Employee, type EmployeeStatus } from "@/lib/employee-data";
import { MUMBAI_RAILWAY_STATIONS } from "@/lib/mumbai-stations";
import { allProjects, allClients } from "@/lib/dh-store";
import { Modal } from "@/routes/projects.index";
import { EmployeeFormModal } from "@/components/employee-form-modal";

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
  { label: "Work Location", key: "workLocation", className: "w-48 min-w-[160px]" },
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
  { label: "Allocation Status", key: null, className: "w-48 min-w-[170px]" },
  { label: "Allocation Type", key: null, className: "w-44 min-w-[150px]" },
  { label: "Allocation Duration", key: null, className: "w-48 min-w-[170px]" },
  { label: "Work Location", key: "workLocation", className: "w-48 min-w-[160px]" },
  { label: "Tasks", key: null, className: "w-28 min-w-[100px]", align: "right" },
];

function sortBlank(value: string): string {
  return !value || value === "—" || value === "–" || value === "-" ? "" : value;
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
type AllocationStatus = "Allocated" | "Bench" | "OnLeave" | "Trainee";

function getAllocationStatus(e: Employee): AllocationStatus {
  if (e.status === "On Leave") return "OnLeave";
  if (e.category?.includes("Intern") || e.designation.toLowerCase().includes("intern") || e.id.startsWith("TKI"))
    return "Trainee";
  if (e.projectAllocated && e.projectAllocated !== "Internal / Bench" && e.projectAllocated !== "NA" && e.projectAllocated !== "-") {
    return "Allocated";
  }
  return "Bench";
}

const ALLOCATION_STATUS_ORDER: Record<AllocationStatus, number> = {
  Allocated: 0,
  Bench: 1,
  Trainee: 2,
  OnLeave: 3,
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
  return value && value.trim() && value !== "—" && value !== "–" && value !== "-" ? value : "—";
}

const DIRECTORY_STATUSES: EmployeeStatus[] = ["Active", "Probation", "Notice Period"];

// ── Allocation Status pill ──────────────────────────
function AllocationStatusBadge({ status }: { status: AllocationStatus }) {
  const map: Record<AllocationStatus, string> = {
    Allocated: "border-emerald-500/30 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400",
    Bench: "border-amber-500/30 bg-amber-500/10 text-amber-600 dark:text-amber-400",
    OnLeave: "border-rose-500/30 bg-rose-500/10 text-rose-600 dark:text-rose-400",
    Trainee: "border-blue-500/30 bg-blue-500/10 text-blue-600 dark:text-blue-400",
  };

  const labels: Record<AllocationStatus, string> = {
    Allocated: "Allocated",
    Bench: "On Bench",
    OnLeave: "On Leave",
    Trainee: "Trainee",
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

// -- Status pill --------------------------------------
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

// -- Select helper ------------------------------------
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
    <SearchableSelect
      placeholder={placeholder}
      options={options}
      value={value}
      onChange={onChange}
      className="w-full text-xs"
      buttonClassName={cn(
        "h-9 text-xs transition-all",
        value
          ? "border-blue-500/50 font-medium text-foreground bg-blue-500/5"
          : "border-input text-muted-foreground",
      )}
    />
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

// -- Request Allocation Modal --------------------------
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
                placeholder="Type @ to tag people from the directory..."
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

// (Onboarding form extracted to shared @/components/employee-form-modal)

// -- Main page ----------------------------------------
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

  // -- Deep Comprehensive Employee Search --------------
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

  // -- Directory Filtering -----------------------------
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

  // -- Pool Filtering ----------------------------------
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

  const totalPages = totalPageCount(activeRows.length, pageSize);
  const currentPage = Math.min(page, totalPages);
  const pageRows = paginateSlice(activeRows, currentPage, pageSize);
  const pageRange = paginationRange(currentPage, pageSize, activeRows.length);

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
      {/* Row 1 (Views & Global Actions) */}
      <div className="mb-3 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        {/* Left: [Directory] / [Resource Pool] view switcher */}
        <div>
          {!basicDirectoryView && ENABLE_RESOURCE_POOL && (
            <div className="flex gap-0.5 rounded-lg border border-border/80 bg-muted/60 p-1 text-xs shadow-inner">
              <button
                onClick={() => setTab("directory")}
                aria-label="Directory view"
                className={cn(
                  "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-all duration-150 cursor-pointer select-none",
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
                  "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-all duration-150 cursor-pointer select-none",
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
        </div>

        {/* Right: Bulk upload menu (ðŸ“¥) and [+ Add Employee] button */}
        {(isDhanshree || isHr) && (
          <div className="flex items-center gap-2.5 shrink-0">
            <EmployeeBulkUploadMenu
              onImported={() => {
                void loadEmployees();
                void fetchDepartmentOptions().then(setDeptCatalog).catch(() => undefined);
                void fetchDesignationOptions().then(setDesigCatalog).catch(() => undefined);
              }}
            />
            <button
              onClick={() => setOnboardOpen(true)}
              className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all cursor-pointer"
            >
              <Plus className="h-4 w-4" />
              Add Employee
            </button>
          </div>
        )}
      </div>

      {/* Row 2: Filter and Search Bar (matching Exit Summary card design) */}
      <div className="mb-4 rounded-xl border border-border bg-card p-3.5 shadow-xs">
        <div className="flex flex-col md:flex-row items-stretch md:items-center gap-2.5">
          {/* Search input */}
          <div className="relative flex-1 min-w-[220px]">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              type="text"
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search by name, role, or ID..."
              className="h-9 w-full rounded-md border border-input bg-background pl-9 pr-8 text-xs font-normal text-foreground placeholder:text-muted-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:border-primary transition-all"
            />
            {q && (
              <button
                type="button"
                onClick={() => setQ("")}
                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground p-0.5"
                title="Clear search"
              >
                <X className="h-3.5 w-3.5" />
              </button>
            )}
          </div>

          {/* Department Filter */}
          <div className="w-full md:w-44 shrink-0">
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

          {/* Designation Filter */}
          <div className="w-full md:w-48 shrink-0">
            <FilterSelect
              value={desig}
              onChange={setDesig}
              placeholder="All Designations"
              options={designationFilterOptions}
            />
          </div>

          {/* Status Filter */}
          <div className="w-full md:w-36 shrink-0">
            <FilterSelect
              value={status}
              onChange={setStatus}
              placeholder="All Statuses"
              options={DIRECTORY_STATUSES}
            />
          </div>

          {/* Reset Button */}
          <div className="w-20 shrink-0 flex items-center">
            {hasActiveFilters && (
              <button
                type="button"
                onClick={clearAllFilters}
                className="h-9 inline-flex items-center justify-center gap-1.5 rounded-md border border-dashed border-border px-3 text-xs font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
              >
                <RotateCcw className="h-3.5 w-3.5" />
                <span>Reset</span>
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Directory Table / Pool Table */}
      {tab === "directory" ? (
        <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
          <div className="overflow-auto max-h-[calc(100vh-210px)] min-h-[500px]">
            <table className={cn("w-full text-sm table-fixed", basicDirectoryView ? "min-w-[800px]" : "min-w-[1480px]")}>
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
                        <td className="w-48 min-w-[160px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.workLocation === "Onsite" && e.projectSite ? `Onsite (${e.projectSite})` : e.workLocation}>
                          {e.workLocation === "Onsite" && e.projectSite ? (
                            <span className="inline-flex items-center gap-1.5">
                              <span className="inline-flex items-center rounded-full border border-info/30 bg-info/10 px-2 py-0.5 text-[11px] font-medium text-info">
                                Onsite
                              </span>
                              <span className="text-xs text-foreground truncate max-w-[120px]">{e.projectSite}</span>
                            </span>
                          ) : (
                            dash(e.workLocation)
                          )}
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
                        ? "Loading employees from database..."
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
                Showing <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.from}</strong> - <strong className="font-semibold text-blue-950 dark:text-blue-100">
                  {pageRange.to}
                </strong>{" "}
                of <strong className="font-semibold text-blue-950 dark:text-blue-100">{activeRows.length}</strong> employees
              </span>
              <span className="text-slate-300 dark:text-slate-600">|</span>
              <div className="flex items-center gap-1.5">
                <span>Per page:</span>
                <RowsPerPageSelect
                  value={pageSize}
                  onChange={setPageSize}
                  className="h-7 min-w-[3.25rem] rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-950/60 pl-2 pr-5 text-xs font-medium text-blue-950 dark:text-blue-100 outline-none cursor-pointer hover:bg-blue-100/50 dark:hover:bg-blue-900/40 transition-colors focus-visible:ring-1 focus-visible:ring-blue-500"
                />
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
                      <td className="w-48 min-w-[170px] whitespace-nowrap px-4 py-3.5 text-muted-foreground">-</td>
                      <td className="w-44 min-w-[150px] whitespace-nowrap px-4 py-3.5 text-muted-foreground">-</td>
                      <td className="w-48 min-w-[170px] whitespace-nowrap px-4 py-3.5 text-muted-foreground">-</td>
                      <td className="w-48 min-w-[160px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.workLocation === "Onsite" && e.projectSite ? `Onsite (${e.projectSite})` : e.workLocation}>
                        {e.workLocation === "Onsite" && e.projectSite ? (
                          <span className="inline-flex items-center gap-1.5">
                            <span className="inline-flex items-center rounded-full border border-info/30 bg-info/10 px-2 py-0.5 text-[11px] font-medium text-info">
                              Onsite
                            </span>
                            <span className="text-xs text-foreground truncate max-w-[120px]">{e.projectSite}</span>
                          </span>
                        ) : (
                          dash(e.workLocation)
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
                Showing <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.from}</strong> - <strong className="font-semibold text-blue-950 dark:text-blue-100">
                  {pageRange.to}
                </strong>{" "}
                of <strong className="font-semibold text-blue-950 dark:text-blue-100">{activeRows.length}</strong> resources
              </span>
              <span className="text-slate-300 dark:text-slate-600">|</span>
              <div className="flex items-center gap-1.5">
                <span>Per page:</span>
                <RowsPerPageSelect
                  value={pageSize}
                  onChange={setPageSize}
                  className="h-7 min-w-[3.25rem] rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-950/60 pl-2 pr-5 text-xs font-medium text-blue-950 dark:text-blue-100 outline-none cursor-pointer hover:bg-blue-100/50 dark:hover:bg-blue-900/40 transition-colors focus-visible:ring-1 focus-visible:ring-blue-500"
                />
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

      {/* Onboarding modal */}
      <EmployeeFormModal
        mode="create"
        open={onboardOpen}
        onClose={() => setOnboardOpen(false)}
        existingCodes={dbEmployees.map((e) => e.id)}
        managers={managers}
        onSuccess={() => {
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
