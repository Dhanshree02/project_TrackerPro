import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useMemo, useState, useEffect, useRef } from "react";
import {
  Search,
  Plus,
  Download,
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
} from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { useRoleContext } from "@/lib/role-context";
import { Avatar, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";
import {
  FIELD_MAX,
  emailError,
  isoDateToday,
  isoDateYearsAgo,
  isLettersName,
  phoneError,
  toDigits,
  toLettersName,
  toEmailInput,
  toTenDigitPhone,
} from "@/lib/form-validation";
import { type Employee, type EmployeeStatus } from "@/lib/employee-data";
import { CreatableCatalogSelect } from "@/components/creatable-catalog-select";
import { FORM_CONTROL_CLS, FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import {
  createDepartmentOption,
  createDesignationOption,
  createEmployee,
  createJobRoleOption,
  fetchAllEmployees,
  fetchDepartmentOptions,
  fetchDesignationOptions,
  fetchJobRoleOptions,
  fetchNationalityOptions,
  fetchSalaryBandOptions,
  toUiEmployeeFromList,
  type ApiMetaOption,
} from "@/lib/api/employees";
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
      { title: "Directory & Pool — Pulse PMO" },
      {
        name: "description",
        content: "Browse and manage the full employee directory & resource pool.",
      },
    ],
  }),
  component: EmployeeDirectoryPage,
});

const PAGE_SIZE = 15;
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

const DIRECTORY_COLUMNS: { label: string; key: DirectorySortKey }[] = [
  { label: "Employee ID", key: "id" },
  { label: "Name", key: "name" },
  { label: "Department", key: "department" },
  { label: "Designation", key: "designation" },
  { label: "Reporting Manager", key: "reportingManager" },
  { label: "Location", key: "workLocation" },
  { label: "Category", key: "category" },
  { label: "Joining Date", key: "joiningDate" },
  { label: "Status", key: "status" },
  { label: "KPI", key: "kpiScore" },
];

const BASIC_DIRECTORY_COLUMNS = DIRECTORY_COLUMNS.slice(0, 4).map((c, i) =>
  i === 1 ? { ...c, label: "Employee Name" } : c,
);

const POOL_COLUMNS: { label: string; key: PoolSortKey | null; align?: "right" }[] = [
  { label: "Dept", key: "department" },
  { label: "Emp Name", key: "name" },
  { label: "Reporting Manager", key: "reportingManager" },
  { label: "Allocation Status", key: "allocationStatus" },
  { label: "Allocation Type", key: null },
  { label: "Allocation Duration", key: null },
  { label: "Location", key: "officeBranch" },
  { label: "Office Site", key: "workLocation" },
  { label: "Project Site", key: "projectSite" },
  { label: "Tasks", key: null, align: "right" },
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
}: {
  label: string;
  column: T;
  sortKey: T;
  sortDir: SortDir;
  onSort: (column: T) => void;
  className?: string;
}) {
  const active = sortKey === column;
  const Icon = active && sortDir === "desc" ? ChevronDown : ChevronUp;
  return (
    <th className={cn("whitespace-nowrap px-3 py-2.5 font-medium", className)}>
      <button
        type="button"
        onClick={() => onSort(column)}
        className={cn(
          "group inline-flex items-center gap-1.5 text-left uppercase tracking-wide",
          active && "text-foreground",
        )}
        aria-sort={active ? (sortDir === "asc" ? "ascending" : "descending") : "none"}
        aria-label={`Sort by ${label}`}
      >
        {label}
        <span
          className="inline-flex h-4 w-4 shrink-0 items-center justify-center rounded-full bg-foreground text-background opacity-0 transition-opacity group-hover:opacity-100"
          aria-hidden
        >
          <Icon className="h-2.5 w-2.5" strokeWidth={2.75} />
        </span>
      </button>
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
      className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
    >
      <option value="">{placeholder}</option>
      {options.map((o) => (
        <option key={o}>{o}</option>
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
          <div className="grid grid-cols-2 gap-4">
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

const ONBOARD_DOC_SLOTS = [
  "Resume",
  "PAN Card",
  "Aadhaar Card",
  "Offer Letter",
  "Education Certs",
  "Experience Letters",
] as const;

const MAX_DOC_BYTES = 5 * 1024 * 1024;
const DOC_EXT = [".pdf", ".jpg", ".jpeg", ".png"];

type OnboardField =
  | "firstName"
  | "lastName"
  | "workEmail"
  | "personalEmail"
  | "employeeCode"
  | "phone"
  | "altPhone"
  | "gender"
  | "dateOfBirth"
  | "maritalStatus"
  | "nationalityId"
  | "address"
  | "emergencyContact"
  | "departmentId"
  | "designationId"
  | "jobRoleId"
  | "businessUnit"
  | "team"
  | "projectSite"
  | "workLocation"
  | "officeBranch"
  | "category"
  | "assetId"
  | "status"
  | "exitType"
  | "exitReason"
  | "probationPeriod"
  | "noticePeriod"
  | "salaryBandId"
  | "education"
  | "certifications"
  | "technicalSkills"
  | "functionalSkills"
  | "experience"
  | "previousCompany"
  | "employmentType"
  | "contractType"
  | "bondStatus"
  | "languages"
  | "pan"
  | "aadhaar"
  | "pfUan"
  | "bankAccount"
  | "ifsc"
  | "joiningDate"
  | "reportingManagerId";
type OnboardErrors = Partial<Record<OnboardField, string>>;
type OnboardValues = Record<OnboardField, string>;
type OnboardDocs = Record<(typeof ONBOARD_DOC_SLOTS)[number], File | null>;
type OnboardDocErrors = Partial<Record<(typeof ONBOARD_DOC_SLOTS)[number], string>>;

const EMPTY_ONBOARD: OnboardValues = {
  firstName: "",
  lastName: "",
  workEmail: "",
  personalEmail: "",
  employeeCode: "",
  phone: "",
  altPhone: "",
  gender: "",
  dateOfBirth: "",
  maritalStatus: "",
  nationalityId: "",
  address: "",
  emergencyContact: "",
  departmentId: "",
  designationId: "",
  jobRoleId: "",
  businessUnit: "",
  team: "",
  projectSite: "",
  workLocation: "",
  officeBranch: "",
  category: "",
  assetId: "",
  status: "Active",
  exitType: "NA",
  exitReason: "",
  probationPeriod: "",
  noticePeriod: "",
  salaryBandId: "",
  education: "",
  certifications: "",
  technicalSkills: "",
  functionalSkills: "",
  experience: "",
  previousCompany: "",
  employmentType: "",
  contractType: "",
  bondStatus: "",
  languages: "",
  pan: "",
  aadhaar: "",
  pfUan: "",
  bankAccount: "",
  ifsc: "",
  joiningDate: "",
  reportingManagerId: "",
};

const EMPTY_DOCS: OnboardDocs = {
  Resume: null,
  "PAN Card": null,
  "Aadhaar Card": null,
  "Offer Letter": null,
  "Education Certs": null,
  "Experience Letters": null,
};

const ONBOARD_FIELDS: OnboardField[] = [
  "firstName",
  "lastName",
  "workEmail",
  "personalEmail",
  "employeeCode",
  "phone",
  "altPhone",
  "emergencyContact",
  "dateOfBirth",
  "joiningDate",
  "probationPeriod",
  "noticePeriod",
  "pan",
  "aadhaar",
  "pfUan",
  "bankAccount",
  "ifsc",
];

const MAX_ADULT_DOB = isoDateYearsAgo(18);
const MIN_DOB = isoDateYearsAgo(100);

function digitsOnly(value: string): string {
  return value.replace(/\D/g, "");
}

/** Verhoeff checksum used by Aadhaar. */
function isValidAadhaar(value: string): boolean {
  const digits = digitsOnly(value);
  if (digits.length !== 12 || /^0+$/.test(digits)) return false;
  const d = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
  ];
  const p = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
  ];
  let c = 0;
  const reversed = digits.split("").reverse().map(Number);
  for (let i = 0; i < reversed.length; i++) c = d[c][p[i % 8][reversed[i]]];
  return c === 0;
}

function isValidPan(value: string): boolean {
  return /^[A-Z]{5}[0-9]{4}[A-Z]$/.test(value.trim().toUpperCase());
}

function isValidIfsc(value: string): boolean {
  return /^[A-Z]{4}0[A-Z0-9]{6}$/.test(value.trim().toUpperCase());
}

function formatBytes(n: number): string {
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
  return `${(n / (1024 * 1024)).toFixed(1)} MB`;
}

function validateOnboardField(
  field: OnboardField,
  values: OnboardValues,
  existingCodes: string[],
): string | undefined {
  switch (field) {
    case "firstName": {
      const v = values.firstName.trim();
      if (!v) return "First name is required";
      if (v.length > 120) return "First name must be 120 characters or less";
      if (!isLettersName(v)) return "Only letters are allowed";
      return undefined;
    }
    case "lastName": {
      const v = values.lastName.trim();
      if (!v) return "Last name is required";
      if (v.length > 120) return "Last name must be 120 characters or less";
      if (!isLettersName(v)) return "Only letters are allowed";
      return undefined;
    }
    case "dateOfBirth": {
      const v = values.dateOfBirth.trim();
      if (!v) return undefined;
      if (v > MAX_ADULT_DOB) return "Employee must be at least 18 years old";
      if (v < MIN_DOB) return "Enter a valid date of birth";
      return undefined;
    }
    case "joiningDate": {
      const v = values.joiningDate.trim();
      if (!v) return undefined;
      if (v < isoDateToday()) return "Date of joining must be today or a future date";
      return undefined;
    }
    case "nationalityId":
    case "departmentId":
    case "designationId":
    case "jobRoleId":
    case "salaryBandId":
      return undefined;
    case "probationPeriod": {
      const v = values.probationPeriod.trim();
      if (!v) return undefined;
      const n = Number(v);
      if (!Number.isInteger(n) || n < 0 || n > 36) return "Enter months between 0 and 36";
      return undefined;
    }
    case "noticePeriod": {
      const v = values.noticePeriod.trim();
      if (!v) return undefined;
      const n = Number(v);
      if (!Number.isInteger(n) || n < 0 || n > 365) return "Enter days between 0 and 365";
      return undefined;
    }
    case "workEmail": {
      const v = values.workEmail.trim();
      if (!v) return "Work email is required";
      return emailError(v, true);
    }
    case "personalEmail": {
      const v = values.personalEmail.trim();
      if (!v) return undefined;
      const mailErr = emailError(v);
      if (mailErr) return mailErr;
      if (v.toLowerCase() === values.workEmail.trim().toLowerCase()) {
        return "Personal email should be different from work email";
      }
      return undefined;
    }
    case "employeeCode": {
      const v = values.employeeCode.trim();
      if (!v) return "Employee ID is required";
      if (v.length > 20) return "Employee ID must be 20 characters or less";
      if (!/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(v)) {
        return "Use letters, numbers, dot, hyphen or underscore";
      }
      if (existingCodes.some((c) => c.toLowerCase() === v.toLowerCase())) {
        return "This employee ID already exists";
      }
      return undefined;
    }
    case "phone": {
      return phoneError(values.phone);
    }
    case "altPhone": {
      return phoneError(values.altPhone);
    }
    case "emergencyContact": {
      return phoneError(values.emergencyContact);
    }
    case "pan": {
      const v = values.pan.trim();
      if (!v) return undefined;
      if (!isValidPan(v)) return "Enter a valid PAN (e.g. ABCDE1234F)";
      return undefined;
    }
    case "aadhaar": {
      const v = values.aadhaar.trim();
      if (!v) return undefined;
      if (/\D/.test(v.replace(/\s/g, ""))) return "Only numbers are allowed";
      if (!isValidAadhaar(v)) return "Enter a valid 12-digit Aadhaar number";
      return undefined;
    }
    case "pfUan": {
      const v = values.pfUan.trim();
      if (!v) return undefined;
      if (/\D/.test(v)) return "Only numbers are allowed";
      if (digitsOnly(v).length !== 12) return "UAN must be a valid 12-digit number";
      return undefined;
    }
    case "bankAccount": {
      const v = values.bankAccount.trim();
      if (!v) return undefined;
      if (/\D/.test(v)) return "Only numbers are allowed";
      const n = digitsOnly(v);
      if (n.length < 9 || n.length > 18) return "Enter a valid bank account number (9–18 digits)";
      return undefined;
    }
    case "ifsc": {
      const v = values.ifsc.trim();
      if (!v) return undefined;
      if (!isValidIfsc(v)) return "Enter a valid IFSC (e.g. SBIN0001234)";
      return undefined;
    }
    case "gender":
    case "maritalStatus":
    case "address":
    case "businessUnit":
    case "team":
    case "projectSite":
    case "workLocation":
    case "officeBranch":
    case "category":
    case "assetId":
    case "status":
    case "exitType":
    case "exitReason":
    case "education":
    case "certifications":
    case "technicalSkills":
    case "functionalSkills":
    case "experience":
    case "previousCompany":
    case "employmentType":
    case "contractType":
    case "bondStatus":
    case "languages":
    case "reportingManagerId":
      return undefined;
  }
}

function csvToList(value: string): string[] {
  return value
    .split(/[,;]/)
    .map((part) => part.trim())
    .filter(Boolean)
    .map((part) => part.slice(0, 120));
}

function blankToNull(value: string): string | null {
  const trimmed = value.trim();
  return trimmed ? trimmed : null;
}

function toDirectoryStatus(employmentStatus: string): string {
  switch (employmentStatus) {
    case "Active - Probation":
      return "Probation";
    case "Resignation - Under Review":
    case "Resignation - Accepted":
      return "Notice Period";
    case "Inactive - After Onboarding":
      return "Inactive";
    default:
      return "Active";
  }
}

function validateOnboardForm(values: OnboardValues, existingCodes: string[]): OnboardErrors {
  const errors: OnboardErrors = {};
  ONBOARD_FIELDS.forEach((field) => {
    const message = validateOnboardField(field, values, existingCodes);
    if (message) errors[field] = message;
  });
  return errors;
}

function validateOnboardFile(file: File): string | undefined {
  const ext = file.name.includes(".") ? `.${file.name.split(".").pop()!.toLowerCase()}` : "";
  if (!DOC_EXT.includes(ext)) return "Only PDF, JPG or PNG files are allowed";
  if (file.size > MAX_DOC_BYTES) return "File must be 5 MB or smaller";
  return undefined;
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
      <div className="relative">
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

function FormSelect({
  label,
  options,
  value,
  onChange,
  error,
  disabled,
}: {
  label: string;
  options: Array<string | { value: string; label: string }>;
  value?: string;
  onChange?: (value: string) => void;
  error?: string;
  disabled?: boolean;
}) {
  const normalized = options.map((o) => (typeof o === "string" ? { value: o, label: o } : o));
  return (
    <label className="block">
      <span className={FORM_LABEL_CLS}>{label}</span>
      <div className="relative">
        <select
          disabled={disabled}
          autoComplete="off"
          data-lpignore="true"
          data-1p-ignore="true"
          data-form-type="other"
          className={cn(
            FORM_CONTROL_CLS,
            "cursor-pointer appearance-none pr-8",
            !value && "text-muted-foreground",
            error && "border-destructive focus-visible:ring-destructive",
          )}
          {...(value !== undefined
            ? { value, onChange: (e: React.ChangeEvent<HTMLSelectElement>) => onChange?.(e.target.value) }
            : {})}
        >
          <option value="">Select…</option>
          {normalized.map((o) => (
            <option key={o.value} value={o.value}>
              {o.label}
            </option>
          ))}
        </select>
        <ChevronDown className="pointer-events-none absolute right-2.5 top-1/2 h-3.5 w-3.5 shrink-0 -translate-y-1/2 text-muted-foreground" />
      </div>
      {error ? <p className={FORM_ERROR_CLS}>{error}</p> : null}
    </label>
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
  error,
  onSelect,
  onClear,
}: {
  label: string;
  file: File | null;
  error?: string;
  onSelect: (file: File) => void;
  onClear: () => void;
}) {
  const inputId = `onboard-doc-${label.replace(/\s+/g, "-").toLowerCase()}`;
  return (
    <div className="space-y-1">
      <input
        id={inputId}
        type="file"
        accept=".pdf,.jpg,.jpeg,.png,application/pdf,image/jpeg,image/png"
        className="sr-only"
        onChange={(e) => {
          const next = e.target.files?.[0];
          if (next) onSelect(next);
          e.target.value = "";
        }}
      />
      {file ? (
        <div
          className={cn(
            "flex flex-col items-center justify-center rounded-md border-2 px-3 py-5 text-center",
            error ? "border-destructive bg-destructive/5" : "border-primary/40 bg-primary/5",
          )}
        >
          <FileText className="mb-2 h-5 w-5 text-primary" />
          <div className="max-w-full truncate text-xs font-medium text-foreground" title={file.name}>
            {file.name}
          </div>
          <div className="text-[11px] text-muted-foreground">{formatBytes(file.size)}</div>
          <div className="mt-2 flex items-center gap-2">
            <label htmlFor={inputId} className="cursor-pointer text-[11px] font-medium text-primary hover:underline">
              Replace
            </label>
            <button
              type="button"
              onClick={onClear}
              className="text-[11px] font-medium text-muted-foreground hover:text-destructive"
            >
              Remove
            </button>
          </div>
        </div>
      ) : (
        <label
          htmlFor={inputId}
          className={cn(
            "flex cursor-pointer flex-col items-center justify-center rounded-md border-2 border-dashed px-4 py-6 text-center transition-colors hover:bg-muted/50",
            error ? "border-destructive bg-destructive/5" : "border-border bg-muted/30",
          )}
        >
          <Plus className="mb-2 h-5 w-5 text-muted-foreground" />
          <div className="text-xs font-medium text-foreground">{label}</div>
          <div className="text-[11px] text-muted-foreground">PDF, JPG · up to 5 MB</div>
        </label>
      )}
      {error ? <p className="text-[11px] text-destructive">{error}</p> : null}
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
  }, [open]);

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
    const next = { ...form, [field]: nextValue };
    if (field === "departmentId") {
      next.designationId = "";
      next.jobRoleId = "";
    }
    if (field === "designationId") next.jobRoleId = "";
    setForm(next);
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
      const message = validateOnboardField(field, next, existingCodes);
      if (message) nextErrors[field] = message;
      else delete nextErrors[field];
      if (field === "workEmail" && next.personalEmail.trim()) {
        const personalMsg = validateOnboardField("personalEmail", next, existingCodes);
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

  const handleCreate = async (e?: React.FormEvent) => {
    e?.preventDefault();
    const nextErrors = validateOnboardForm(form, existingCodes);
    setErrors(nextErrors);
    const nextDocErrors: OnboardDocErrors = {};
    ONBOARD_DOC_SLOTS.forEach((slot) => {
      const file = docs[slot];
      if (!file) return;
      const message = validateOnboardFile(file);
      if (message) nextDocErrors[slot] = message;
    });
    setDocErrors(nextDocErrors);
    if (Object.keys(nextErrors).length > 0 || Object.keys(nextDocErrors).length > 0) {
      toast.error("Please fix the highlighted fields");
      return;
    }
    setIsSubmitting(true);
    try {
      const probationLabel = form.probationPeriod.trim()
        ? `${form.probationPeriod.trim()} months`
        : null;
      const employmentStatus = form.status.trim() || "Active";
      await createEmployee({
        employeeCode: form.employeeCode.trim(),
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
        departmentId: form.departmentId || null,
        designationId: form.designationId || null,
        jobRoleId: form.jobRoleId || null,
        role: roleOptions.find((r) => r.id === form.jobRoleId)?.name ?? null,
        reportingManagerId: form.reportingManagerId.trim() || null,
        businessUnit: blankToNull(form.businessUnit),
        workLocation: blankToNull(form.workLocation),
        officeBranch: blankToNull(form.officeBranch),
        category: blankToNull(form.category),
        team: blankToNull(form.team),
        joiningDate: blankToNull(form.joiningDate),
        status: toDirectoryStatus(employmentStatus),
        confirmationStatus: employmentStatus,
        probationStatus:
          employmentStatus === "Active - Probation"
            ? probationLabel
              ? `On Probation (${probationLabel})`
              : "On Probation"
            : probationLabel,
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
        bankAccount: blankToNull(form.bankAccount),
        pfUan: blankToNull(form.pfUan),
        salaryBandId: form.salaryBandId || null,
        salaryBand: salaryBands.find((b) => b.id === form.salaryBandId)?.name ?? null,
      });
      const attached = ONBOARD_DOC_SLOTS.filter((slot) => docs[slot]).length;
      onCreated();
      toast.success(
        attached > 0
          ? `Employee created with ${attached} document${attached === 1 ? "" : "s"} attached`
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
              value={form.lastName}
              onChange={(v) => setField("lastName", v)}
              onBlur={() => blurField("lastName")}
              error={errors.lastName}
            />
            <FormField
              label="Email ID"
              name="workEmail"
              type="text"
              required
              maxLength={FIELD_MAX.email}
              value={form.workEmail}
              onChange={(v) => setField("workEmail", v)}
              onBlur={() => blurField("workEmail")}
              error={errors.workEmail}
            />
            <FormField
              label="Personal Email"
              name="personalEmail"
              type="text"
              maxLength={FIELD_MAX.email}
              value={form.personalEmail}
              onChange={(v) => setField("personalEmail", v)}
              onBlur={() => blurField("personalEmail")}
              error={errors.personalEmail}
            />
            <FormField
              label="Mobile Number"
              name="phone"
              inputMode="numeric"
              required
              maxLength={FIELD_MAX.phone}
              placeholder="10-digit mobile"
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
              placeholder="10-digit mobile"
              value={form.altPhone}
              onChange={(v) => setField("altPhone", v)}
              onBlur={() => blurField("altPhone")}
              error={errors.altPhone}
            />
            <FormSelect
              label="Gender"
              options={["Male", "Female", "Other"]}
              value={form.gender}
              onChange={(v) => setField("gender", v)}
            />
            <FormField
              label="Date of Birth"
              type="date"
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
              options={nationalities.map((n) => ({ value: n.id, label: n.name }))}
              value={form.nationalityId}
              onChange={(v) => setField("nationalityId", v)}
            />
            <div className="md:col-span-2">
              <FormField
                label="Address"
                maxLength={FIELD_MAX.address}
                value={form.address}
                onChange={(v) => setField("address", v)}
              />
            </div>
            <FormField
              label="Emergency Contact"
              name="emergencyContact"
              inputMode="numeric"
              maxLength={FIELD_MAX.phone}
              placeholder="10-digit mobile"
              value={form.emergencyContact}
              onChange={(v) => setField("emergencyContact", v)}
              onBlur={() => blurField("emergencyContact")}
              error={errors.emergencyContact}
            />
          </FormSection>

          <FormSection title="2. Organization Assignment">
            <FormField
              label="Employee ID"
              name="employeeCode"
              required
              placeholder="EMP-1049"
              maxLength={FIELD_MAX.employeeCode}
              value={form.employeeCode}
              onChange={(v) => setField("employeeCode", v)}
              onBlur={() => blurField("employeeCode")}
              error={errors.employeeCode}
            />
            <CreatableCatalogSelect
              label="Department"
              options={deptOptions}
              valueId={form.departmentId}
              onSelect={(id) => setField("departmentId", id)}
              onCreate={async (name) => {
                try {
                  const created = await createDepartmentOption(name);
                  setDeptOptions((prev) =>
                    prev.some((o) => o.id === created.id) ? prev : [...prev, created],
                  );
                  return created;
                } catch (error: unknown) {
                  toast.error(error instanceof Error ? error.message : "Could not add department");
                  throw error;
                }
              }}
            />
            <CreatableCatalogSelect
              label="Designation"
              options={desigOptions}
              valueId={form.designationId}
              disabled={!form.departmentId}
              disabledHint="Select a department first"
              onSelect={(id) => setField("designationId", id)}
              onCreate={async (name) => {
                try {
                  const created = await createDesignationOption(name, form.departmentId);
                  setDesigOptions((prev) =>
                    prev.some((o) => o.id === created.id) ? prev : [...prev, created],
                  );
                  return created;
                } catch (error: unknown) {
                  toast.error(error instanceof Error ? error.message : "Could not add designation");
                  throw error;
                }
              }}
            />
            <CreatableCatalogSelect
              label="Role"
              options={roleOptions}
              valueId={form.jobRoleId}
              disabled={!form.designationId}
              disabledHint="Select a designation first"
              onSelect={(id) => setField("jobRoleId", id)}
              onCreate={async (name) => {
                try {
                  const created = await createJobRoleOption(name, form.designationId);
                  setRoleOptions((prev) =>
                    prev.some((o) => o.id === created.id) ? prev : [...prev, created],
                  );
                  return created;
                } catch (error: unknown) {
                  toast.error(error instanceof Error ? error.message : "Could not add role");
                  throw error;
                }
              }}
            />
            <FormSelect
              label="Reporting Manager"
              options={managers.map((m) => ({ value: m.id, label: m.name }))}
              value={form.reportingManagerId}
              onChange={(v) => setField("reportingManagerId", v)}
            />
            <FormSelect
              label="Business Unit"
              options={["Cloud Platform", "Consumer Apps", "Enterprise"]}
              value={form.businessUnit}
              onChange={(v) => setField("businessUnit", v)}
            />
            <FormField
              label="Team"
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
            <FormSelect
              label="Work Location"
              options={[
                "Andheri Office",
                "Dombivali Office",
                "Bengaluru",
                "Hyderabad",
                "Pune",
                "Mumbai",
                "Remote",
              ]}
              value={form.workLocation}
              onChange={(v) => setField("workLocation", v)}
            />
            <FormSelect
              label="Office Branch"
              options={["HQ Tower", "Tech Park East", "Tech Park West"]}
              value={form.officeBranch}
              onChange={(v) => setField("officeBranch", v)}
            />
          </FormSection>

          <FormSection title="3. Employment Information">
            <FormField
              label="Date of Joining"
              type="date"
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
              placeholder="TK-4029"
              maxLength={FIELD_MAX.assetId}
              value={form.assetId}
              onChange={(v) => setField("assetId", v)}
            />
            <FormSelect
              label="Employment Status"
              options={[
                "Active - Probation",
                "Active",
                "Resignation - Under Review",
                "Resignation - Accepted",
                "Inactive - After Onboarding",
              ]}
              value={form.status}
              onChange={(v) => setField("status", v)}
            />
            <FormSelect
              label="Exit Type"
              options={["NA", "Resign", "Absconded", "Terminated", "Suspension"]}
              value={form.exitType}
              onChange={(v) => setField("exitType", v)}
            />
            <FormField
              label="Exit Comment"
              placeholder="Reason for resignation/termination"
              maxLength={FIELD_MAX.exitComment}
              value={form.exitReason}
              onChange={(v) => setField("exitReason", v)}
            />
            <FormField
              label="Probation Period"
              inputMode="numeric"
              maxLength={FIELD_MAX.probationMonths}
              placeholder="6"
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
              placeholder="90"
              suffix="days"
              value={form.noticePeriod}
              onChange={(v) => setField("noticePeriod", v)}
              onBlur={() => blurField("noticePeriod")}
              error={errors.noticePeriod}
            />
            <FormSelect
              label="Salary Band"
              options={salaryBands.map((b) => ({ value: b.id, label: b.name }))}
              value={form.salaryBandId}
              onChange={(v) => setField("salaryBandId", v)}
            />
            <FormSelect
              label="Employment Type"
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
              value={form.education}
              onChange={(v) => setField("education", v)}
            />
            <FormField
              label="Certifications"
              placeholder="AWS, Scrum Master"
              maxLength={FIELD_MAX.certifications}
              value={form.certifications}
              onChange={(v) => setField("certifications", v)}
            />
            <FormField
              label="Technical Skills"
              placeholder="React, Node.js"
              maxLength={FIELD_MAX.skills}
              value={form.technicalSkills}
              onChange={(v) => setField("technicalSkills", v)}
            />
            <FormField
              label="Functional Skills"
              placeholder="Stakeholder Mgmt, Mentoring"
              maxLength={FIELD_MAX.skills}
              value={form.functionalSkills}
              onChange={(v) => setField("functionalSkills", v)}
            />
            <FormField
              label="Experience"
              placeholder="5 years"
              maxLength={FIELD_MAX.experience}
              value={form.experience}
              onChange={(v) => setField("experience", v)}
            />
            <FormField
              label="Previous Organization"
              maxLength={FIELD_MAX.previousCompany}
              value={form.previousCompany}
              onChange={(v) => setField("previousCompany", v)}
            />
            <FormField
              label="Languages Known"
              placeholder="English, Hindi"
              maxLength={FIELD_MAX.text}
              value={form.languages}
              onChange={(v) => setField("languages", v)}
            />
          </FormSection>

          <FormSection title="5. Compliance Information">
            <FormField
              label="PAN Number"
              name="pan"
              maxLength={10}
              placeholder="ABCDE1234F"
              value={form.pan}
              onChange={(v) => setField("pan", v.toUpperCase())}
              onBlur={() => blurField("pan")}
              error={errors.pan}
            />
            <FormField
              label="Aadhaar Number"
              name="aadhaar"
              inputMode="numeric"
              maxLength={12}
              placeholder="12-digit Aadhaar"
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
              placeholder="12-digit UAN"
              value={form.pfUan}
              onChange={(v) => setField("pfUan", v)}
              onBlur={() => blurField("pfUan")}
              error={errors.pfUan}
            />
            <FormField
              label="Bank Account Number"
              name="bankAccount"
              inputMode="numeric"
              maxLength={18}
              value={form.bankAccount}
              onChange={(v) => setField("bankAccount", v)}
              onBlur={() => blurField("bankAccount")}
              error={errors.bankAccount}
            />
            <FormField
              label="IFSC Code"
              name="ifsc"
              maxLength={11}
              placeholder="SBIN0001234"
              value={form.ifsc}
              onChange={(v) => setField("ifsc", v.toUpperCase())}
              onBlur={() => blurField("ifsc")}
              error={errors.ifsc}
            />
          </FormSection>

          <section className="rounded-lg border border-border bg-card p-5">
            <h3 className="mb-4 text-sm font-semibold text-foreground">6. Document Uploads</h3>
            <div className="grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-6">
              {ONBOARD_DOC_SLOTS.map((d) => (
                <UploadSlot
                  key={d}
                  label={d}
                  file={docs[d]}
                  error={docErrors[d]}
                  onSelect={(file) => handleDocSelect(d, file)}
                  onClear={() => {
                    setDocs((prev) => ({ ...prev, [d]: null }));
                    setDocErrors((prev) => {
                      const next = { ...prev };
                      delete next[d];
                      return next;
                    });
                  }}
                />
              ))}
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

  // ── Directory Filtering ──
  const directoryRows = useMemo(() => {
    const filtered = dbEmployees.filter((e) => {
      const matchQ =
        !q ||
        `${e.firstName} ${e.lastName} ${e.id} ${e.email} ${e.department} ${e.designation} ${e.reportingManager} ${e.workLocation}`
          .toLowerCase()
          .includes(q.toLowerCase());
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
      const matchQ =
        !q ||
        `${e.firstName} ${e.lastName} ${e.id} ${e.email} ${e.department} ${e.designation} ${e.reportingManager} ${e.workLocation}`
          .toLowerCase()
          .includes(q.toLowerCase());
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

  const totalPages = Math.max(1, Math.ceil(activeRows.length / PAGE_SIZE));
  const currentPage = Math.min(page, totalPages);
  const pageRows = activeRows.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  // Reset page when filters or tab change
  useEffect(() => {
    setPage(1);
  }, [q, dept, desig, status, tab, sortKey, sortDir, poolSortKey, poolSortDir]);

  // Admin and HR both manage the full employee directory (HR uses it for
  // onboarding); every other role is redirected.
  if (!isDhanshree && !basicDirectoryView) return <Navigate to="/" />;

  const title = basicDirectoryView ? "Directory" : tab === "directory" ? "Directory & Pool" : "Resource Pool";
  const subtitle =
    tab === "directory"
      ? `${activeRows.length} of ${dbEmployees.length} employees`
      : `${activeRows.length} of ${dbEmployees.length} resources active`;

  return (
    <AppShell title={title} subtitle={subtitle}>
      {/* Search & Filters (Left) + View Switcher & Add Button (Right) */}
      <div className="mb-4 flex flex-wrap lg:flex-nowrap items-center justify-between gap-3">
        {/* Left Side: Search & Filters */}
        <div className="flex flex-wrap sm:flex-nowrap items-center gap-2 flex-1 min-w-0">
          <div className="relative w-44 shrink-0">
            <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search..."
              className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
            />
          </div>

          <div className="w-40 shrink-0">
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
          <div className="w-44 shrink-0">
            <FilterSelect
              value={desig}
              onChange={setDesig}
              placeholder="All Designations"
              options={designationFilterOptions}
            />
          </div>
          <div className="w-40 shrink-0">
            <FilterSelect
              value={status}
              onChange={setStatus}
              placeholder="All Status"
              options={DIRECTORY_STATUSES}
            />
          </div>
        </div>

        {/* Right Side: Tab Switcher (admin only) & Add Button */}
        <div className="flex items-center gap-3">
          {!basicDirectoryView && ENABLE_RESOURCE_POOL && (
            <div className="flex gap-1 rounded-lg border border-border bg-card p-1 text-xs shadow-sm">
              <button
                onClick={() => setTab("directory")}
                aria-label="Directory view"
                className={cn(
                  "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-colors",
                  tab === "directory"
                    ? "bg-primary text-primary-foreground"
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
                  "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-colors",
                  tab === "pool"
                    ? "bg-primary text-primary-foreground"
                    : "text-muted-foreground hover:text-foreground",
                )}
              >
                <Activity className="h-3.5 w-3.5" />
                Pool
              </button>
            </div>
          )}

          {(isDhanshree || isHr) && (
            <button
              onClick={() => setOnboardOpen(true)}
              className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all"
            >
              <Plus className="h-4 w-4" />
              Add Employee
            </button>
          )}
        </div>
      </div>

      {/* Directory Table / Pool Table */}
      {tab === "directory" ? (
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
              {(basicDirectoryView ? BASIC_DIRECTORY_COLUMNS : DIRECTORY_COLUMNS).map((col) => (
                <SortableTh
                  key={col.key}
                  label={col.label}
                  column={col.key}
                  sortKey={sortKey}
                  sortDir={sortDir}
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
                  <td className="whitespace-nowrap px-3 py-2.5 font-mono text-xs text-muted-foreground">
                    {e.id}
                  </td>
                  <td className="whitespace-nowrap px-3 py-2.5">
                    <Link
                      to="/dh-employee-directory/$id"
                      params={{ id: e.id }}
                      className="flex items-center gap-2"
                    >
                      <Avatar name={`${e.firstName} ${e.lastName}`} size={28} />
                      <span className="font-medium">
                        {e.firstName} {e.lastName}
                      </span>
                    </Link>
                  </td>
                  <td className="whitespace-nowrap px-3 py-2.5">{e.department}</td>
                  <td className="whitespace-nowrap px-3 py-2.5">{e.designation}</td>
                  {!basicDirectoryView && (
                    <>
                      <td className="whitespace-nowrap px-3 py-2.5 text-muted-foreground">
                        {e.reportingManager}
                      </td>
                      <td className="whitespace-nowrap px-3 py-2.5">{e.workLocation}</td>
                      <td className="whitespace-nowrap px-3 py-2.5">{e.category}</td>
                      <td className="whitespace-nowrap px-3 py-2.5 text-muted-foreground">
                        {e.joiningDate}
                      </td>
                      <td className="whitespace-nowrap px-3 py-2.5">
                        <EmpStatusBadge status={e.status} />
                      </td>
                      <td className="whitespace-nowrap px-3 py-2.5">
                        <div className="flex items-center gap-2">
                          <ProgressBar value={e.kpiScore} className="w-16" />
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
                    className="px-3 py-10 text-center text-sm text-muted-foreground"
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

          {/* Pagination */}
          <div className="flex items-center justify-between border-t border-border px-4 py-3 text-xs text-muted-foreground">
            <div>
              Showing {activeRows.length === 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1}–
              {Math.min(currentPage * PAGE_SIZE, activeRows.length)} of {activeRows.length}
            </div>
            <div className="flex items-center gap-1">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={currentPage <= 1}
                className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1 hover:bg-accent disabled:opacity-40"
              >
                <ChevronLeft className="h-3 w-3" /> Previous
              </button>
              <span className="px-2 tabular-nums">
                {currentPage} / {totalPages}
              </span>
              <button
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage >= totalPages}
                className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1 hover:bg-accent disabled:opacity-40"
              >
                Next <ChevronRight className="h-3 w-3" />
              </button>
            </div>
          </div>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                {POOL_COLUMNS.map((col) =>
                  col.key ? (
                    <SortableTh
                      key={col.label}
                      label={col.label}
                      column={col.key}
                      sortKey={poolSortKey}
                      sortDir={poolSortDir}
                      className="px-4 py-3"
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
                        "whitespace-nowrap px-4 py-3 font-medium",
                        col.align === "right" ? "text-right" : "text-left",
                      )}
                    >
                      {col.label}
                    </th>
                  ),
                )}
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {pageRows.map((e) => {
                const statusVal = getAllocationStatus(e);
                return (
                  <tr key={e.id} className="cursor-pointer transition-colors hover:bg-accent/30">
                    <td className="whitespace-nowrap px-4 py-3 font-semibold text-foreground/90">
                      {dash(e.department)}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 font-medium">
                      <Link
                        to="/dh-employee-directory/$id"
                        params={{ id: e.id }}
                        className="flex items-center gap-2.5 hover:text-primary transition-colors"
                      >
                        <Avatar name={`${e.firstName} ${e.lastName}`} size={28} />
                        <span className="font-semibold">
                          {e.firstName} {e.lastName}
                        </span>
                      </Link>
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">
                      {dash(e.reportingManager)}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3">
                      <AllocationStatusBadge status={statusVal} />
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">—</td>
                    <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">—</td>
                    <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">
                      {dash(e.officeBranch)}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-muted-foreground">
                      {dash(e.workLocation)}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3">
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
                    <td className="whitespace-nowrap px-4 py-3 text-right">
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

          {/* Pagination */}
          <div className="flex items-center justify-between border-t border-border px-4 py-3 text-xs text-muted-foreground bg-muted/10">
            <div>
              Showing {activeRows.length === 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1}–
              {Math.min(currentPage * PAGE_SIZE, activeRows.length)} of {activeRows.length}
            </div>
            <div className="flex items-center gap-1.5">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={currentPage <= 1}
                className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1.5 hover:bg-accent disabled:opacity-40"
              >
                <ChevronLeft className="h-3.5 w-3.5" /> Previous
              </button>
              <span className="px-2 tabular-nums font-medium">
                {currentPage} / {totalPages}
              </span>
              <button
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage >= totalPages}
                className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1.5 hover:bg-accent disabled:opacity-40"
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
