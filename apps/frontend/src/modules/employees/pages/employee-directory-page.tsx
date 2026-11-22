import { getRouteApi, Link, Navigate, useNavigate } from "@tanstack/react-router";
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
import { usePermissions } from "@/lib/permissions";
import { inFinancialYears, useFinancialYear } from "@/lib/financial-year";
import { Avatar } from "@/components/pills";
import { cn, formatDateDMY } from "@/lib/utils";
import { SegmentedControl } from "@/components/ui/segmented-control";
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
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { TkIdField } from "@/components/tk-id-field";
import { WorkEmailField } from "@/components/work-email-field";
import { FORM_CONTROL_CLS, FORM_ERROR_CLS, FORM_LABEL_CLS } from "@/components/form-row";
import { EmployeeBulkUploadMenu } from "@/modules/employees/components/employee-bulk-upload";
import { RowsPerPageSelect } from "@/components/rows-per-page-select";
import { paginateSlice, paginationRange, totalPageCount } from "@/lib/pagination";
import { formatSubDepartmentDisplay, normalizeSubDepartmentKey } from "@/lib/sub-department";
import { formatOnFloorRoleDisplay, normalizeOnFloorRole, uniqueOnFloorRoleLabels } from "@/lib/on-floor-role";
import {
  createEmployee,
  fetchAllEmployees,
  setEmployeeLoginAccess,
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
  fetchGraduationDegreeOptions,
  fetchPostGraduationDegreeOptions,
  toUiEmployeeFromList,
  uploadEmployeeDocuments,
  type ApiMetaOption,
} from "@/modules/employees/api/employees";
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
  employeeStatusDisplayLabel,
} from "@/lib/onboard-validation";
import {
  WORKER_TYPES,
  BOND_DELIVERED_OPTIONS,
  computeBondStatus,
  formatBondExpiryDisplay,
} from "@/lib/employment-bond";
import { type Employee, type EmployeeStatus } from "@/lib/employee-data";
import { Modal } from "@/modules/projects/pages/projects-list-page";
import { EmployeeFormModal } from "@/modules/employees/components/employee-form-modal";

const employeeDirectoryRoute = getRouteApi("/employee-directory/");

const DEFAULT_PAGE_SIZE = 15;
const ENABLE_RESOURCE_POOL = false;

type DirectorySortKey =
  | "id"
  | "name"
  | "department"
  | "designation"
  | "jobRoleName"
  | "subDepartment"
  | "reportingManager"
  | "workLocation"
  | "category"
  | "joiningDate"
  | "status";
type PoolSortKey =
  | "department"
  | "subDepartment"
  | "name"
  | "reportingManager"
  | "allocationStatus"
  | "officeBranch"
  | "workLocation"
  | "projectSite";
type SortDir = "asc" | "desc";

const DIRECTORY_COLUMNS: { label: string; key: DirectorySortKey }[] = [
  { label: "TK ID", key: "id" },
  { label: "Name", key: "name" },
  { label: "Department", key: "department" },
  { label: "Designation", key: "designation" },
  { label: "On Floor Role", key: "jobRoleName" },
  { label: "Sub-Department", key: "subDepartment" },
  { label: "Reporting Manager", key: "reportingManager" },
  { label: "Work Location", key: "workLocation" },
  { label: "Category", key: "category" },
  { label: "Joining Date", key: "joiningDate" },
  { label: "Status", key: "status" },
];

const BASIC_DIRECTORY_COLUMNS: { label: string; key: DirectorySortKey }[] = [
  { label: "TK ID", key: "id" },
  { label: "Employee Name", key: "name" },
  { label: "Department", key: "department" },
  { label: "Designation", key: "designation" },
  { label: "On Floor Role", key: "jobRoleName" },
  { label: "Sub-Department", key: "subDepartment" },
];

const POOL_COLUMNS: { label: string; key: PoolSortKey | null; className?: string; align?: "right" }[] = [
  { label: "Department", key: "department", className: "w-44 min-w-[150px]" },
  { label: "Sub-Department", key: "subDepartment", className: "w-52 min-w-[185px]" },
  { label: "Employee Name", key: "name", className: "w-56 min-w-[190px]" },
  { label: "Reporting Manager", key: "reportingManager", className: "w-48 min-w-[170px]" },
  { label: "Allocation Status", key: "allocationStatus", className: "w-48 min-w-[170px]" },
  { label: "Allocation Type", key: null, className: "w-44 min-w-[150px]" },
  { label: "Allocation Duration", key: null, className: "w-56 min-w-[205px]" },
  { label: "Work Location", key: "workLocation", className: "w-48 min-w-[160px]" },
  { label: "Tasks", key: null, className: "w-28 min-w-[100px]", align: "right" },
];

function sortBlank(value: string): string {
  return !value || value === "—" || value === "–" || value === "-" ? "" : value;
}

function compareEmployees(a: Employee, b: Employee, key: DirectorySortKey): number {
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
type AllocationStatus = "Occupied" | "Free" | "OnLeave";

function todayLocalIso(): string {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}

function getAllocationStatus(e: Employee): AllocationStatus {
  // Priority 1: Team attendance (Leave) or employee status On Leave overwrites Occupied / Free.
  if (
    e.allocationStatus === "On Leave" ||
    e.todayAttendance?.toLowerCase() === "leave" ||
    e.status === "On Leave"
  ) {
    return "OnLeave";
  }

  // Priority 2: Occupied if marked for a project and allocation end date is yet to finish, else Free.
  if (e.allocationStatus === "Occupied") return "Occupied";
  if (e.allocationStatus === "Free") return "Free";

  if (e.allocationEndDate && e.allocationEndDate >= todayLocalIso()) {
    return "Occupied";
  }
  return "Free";
}

function formatPoolAllocationDuration(e: Employee): string {
  if (!e.allocationStartDate || !e.allocationEndDate) return "—";
  return `${formatDateDMY(e.allocationStartDate)} → ${formatDateDMY(e.allocationEndDate)}`;
}

const ALLOCATION_STATUS_ORDER: Record<AllocationStatus, number> = {
  Occupied: 0,
  Free: 1,
  OnLeave: 2,
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
      case "subDepartment":
        return e.subDepartment ?? "";
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
  return (
    <th className={cn("whitespace-nowrap px-4 py-3.5 text-left align-middle", className)}>
      <button
        type="button"
        onClick={() => onSort(column)}
        className={cn(
          "inline-flex items-center gap-1.5 whitespace-nowrap text-left text-[13px] font-semibold tracking-[-0.01em] select-none",
          active ? "text-foreground" : "text-muted-foreground hover:text-foreground",
        )}
        aria-sort={active ? (sortDir === "asc" ? "ascending" : "descending") : "none"}
        aria-label={`Sort by ${label}`}
      >
        <span>{label}</span>
        {active &&
          (sortDir === "desc" ? (
            <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
          ) : (
            <ChevronUp className="h-3.5 w-3.5 text-muted-foreground" />
          ))}
      </button>
    </th>
  );
}

function dash(value?: string | null): string {
  return value && value.trim() && value !== "—" && value !== "–" && value !== "-" ? value : "—";
}

const DIRECTORY_STATUSES: EmployeeStatus[] = [
  "Active",
  "Probation",
  "Resignation Under Review",
  "Notice Period",
];

// ── Allocation Status pill ──────────────────────────
function AllocationStatusBadge({ status }: { status: AllocationStatus }) {
  const map: Record<AllocationStatus, string> = {
    Occupied: "border-amber-500/30 bg-amber-500/10 text-amber-600 dark:text-amber-400",
    Free: "border-emerald-500/30 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400",
    OnLeave: "border-rose-500/30 bg-rose-500/10 text-rose-600 dark:text-rose-400",
  };

  const labels: Record<AllocationStatus, string> = {
    Occupied: "Occupied",
    Free: "Free",
    OnLeave: "On Leave",
  };

  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-0.5 text-[11px] font-semibold tracking-wide shadow-xs",
        map[status],
      )}
    >
      {labels[status]}
    </span>
  );
}

function AllocationTypeBadge({ type }: { type?: string | null }) {
  if (!type || type === "—" || type === "-") {
    return <span className="text-muted-foreground">—</span>;
  }
  const normalized = type.toLowerCase().startsWith("shared") ? "Shared" : "Dedicated";
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-0.5 text-[11px] font-medium",
        normalized === "Dedicated"
          ? "border-primary/30 bg-primary/10 text-primary"
          : "border-info/30 bg-info/10 text-info",
      )}
    >
      {normalized}
    </span>
  );
}

// -- Status pill --------------------------------------
function EmpStatusBadge({ status }: { status: string }) {
  const map: Record<string, string> = {
    Active: "border-success/30 bg-success/10 text-success",
    Probation: "border-warning/40 bg-warning/15 text-warning",
    "Resignation Under Review": "border-warning/40 bg-warning/15 text-warning",
    "Resignation - Under Review": "border-warning/40 bg-warning/15 text-warning",
    Resigned: "border-destructive/30 bg-destructive/10 text-destructive",
    Terminated: "border-destructive/30 bg-destructive/10 text-destructive",
    Absconded: "border-destructive/30 bg-destructive/10 text-destructive",
    "Notice Period": "border-destructive/30 bg-destructive/10 text-destructive",
    Inactive: "border-muted-foreground/30 bg-muted text-muted-foreground",
    "On Leave": "border-info/30 bg-info/10 text-info",
  };
  return (
    <span
      className={cn(
        "inline-flex max-w-full items-center rounded-full border px-2.5 py-0.5 text-[11px] font-medium leading-snug",
        status.length > 18 && "text-[10px] px-2",
        map[status] ?? "border-border bg-muted text-muted-foreground",
      )}
      title={status}
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
  const allocStatus = getAllocationStatus(employee);
  const isOnLeave = allocStatus === "OnLeave";
  const hasAllocation = Boolean(employee.allocationStartDate && employee.allocationEndDate);

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
                {employee.subDepartment ? ` · ${dash(employee.subDepartment)}` : ""}
              </div>
              <div className="text-[11px] text-muted-foreground font-mono">{employee.id}</div>
              <div className="mt-1.5">
                <AllocationStatusBadge status={allocStatus} />
              </div>
              {isOnLeave && hasAllocation && (
                <div className="mt-1 text-[10px] text-muted-foreground">
                  Assigned to project (overridden by Leave today)
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="md:col-span-2 space-y-3">
          <h4 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Active Project Allocation
          </h4>
          {hasAllocation ? (
            <div className="rounded-lg border border-border bg-card p-4 space-y-2.5">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <div className="text-sm font-semibold text-foreground">
                  {employee.allocatedProjectName || employee.projectAllocated || "Assigned Project"}
                </div>
                <AllocationTypeBadge type={employee.allocationType} />
              </div>
              <div className="text-xs text-muted-foreground">
                <span className="font-medium text-foreground">Allocation Duration: </span>
                {formatPoolAllocationDuration(employee)}
              </div>
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">
              No active project allocation. Resource is currently free.
            </p>
          )}
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
export function EmployeeDirectoryPage() {
  const { years } = useFinancialYear();
  const { status: authStatus } = useAuth();
  const { isDhanshree, isHr, isEmployee, isPmFamily, isPmoFamily, isAccounts, isSales } =
    useRoleContext();
  const { canView, canManage, loading: permissionsLoading } = usePermissions();
  const canViewDirectory = canView("employee-directory");
  const canManageDirectory = canManage("employee-directory");
  const { tab: searchTab } = employeeDirectoryRoute.useSearch();
  const basicDirectoryView =
    isHr || isEmployee || isPmFamily || isPmoFamily || isAccounts || isSales;
  const [tab, setTabState] = useState<"directory" | "pool">("directory");
  const navigate = useNavigate({ from: employeeDirectoryRoute.fullPath });

  useEffect(() => {
    if (!searchTab) return;
    void navigate({ search: (prev) => ({ ...prev, tab: undefined }), replace: true });
  }, [searchTab, navigate]);

  const [q, setQ] = useState("");
  const [dept, setDept] = useState("");
  const [desig, setDesig] = useState("");
  const [subDept, setSubDept] = useState("");
  const [onFloorRole, setOnFloorRole] = useState("");
  const [status, setStatus] = useState("");
  const [deptCatalog, setDeptCatalog] = useState<ApiMetaOption[]>([]);
  const [desigCatalog, setDesigCatalog] = useState<ApiMetaOption[]>([]);
  const [onFloorRoleOptions, setOnFloorRoleOptions] = useState<string[]>([]);

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
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [loginBusy, setLoginBusy] = useState(false);
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
    void fetchJobRoleOptions()
      .then((rows) => setOnFloorRoleOptions(uniqueOnFloorRoleLabels(rows.map((row) => row.name))))
      .catch(() => setOnFloorRoleOptions([]));
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

  const subDepartmentFilterOptions = useMemo(() => {
    const selectedDept = deptCatalog.find((d) => d.name === dept);
    let scopedDesigs = selectedDept
      ? desigCatalog.filter((d) => d.parentId === selectedDept.id)
      : desigCatalog;
    if (desig) {
      scopedDesigs = scopedDesigs.filter((d) => d.name === desig);
    }
    const names = new Set<string>();
    for (const row of scopedDesigs) {
      if (!row.subDepartment) continue;
      for (const part of row.subDepartment.split(",").map((s) => s.trim()).filter(Boolean)) {
        const label = formatSubDepartmentDisplay(part) || part;
        names.add(label);
      }
    }
    for (const e of dbEmployees) {
      if (dept && e.department !== dept) continue;
      if (desig && e.designation !== desig) continue;
      const value = formatSubDepartmentDisplay(e.subDepartment) || e.subDepartment?.trim();
      if (value) names.add(value);
    }
    return [...names].sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }));
  }, [desigCatalog, deptCatalog, dbEmployees, dept, desig]);

  const onFloorRoleFilterOptions = onFloorRoleOptions;

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
      e.subDepartment,
      e.jobRoleName,
      e.role,
      e.businessUnit,
      e.workLocation,
      e.officeBranch,
      e.category,
      e.team,
      formatDateDMY(e.joiningDate),
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
      e.allocationStatus,
      e.allocationType,
      e.allocatedProjectName,
      formatPoolAllocationDuration(e),
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
        (!subDept || normalizeSubDepartmentKey(e.subDepartment) === normalizeSubDepartmentKey(subDept)) &&
        (!onFloorRole || normalizeOnFloorRole(e.jobRoleName) === normalizeOnFloorRole(onFloorRole)) &&
        (!status ||
          e.status === status ||
          (status === "Active" && e.status === "Resignation Under Review")) &&
        inFinancialYears(e.joiningDate, e.joiningDate, years)
      );
    });
    return [...filtered].sort((a, b) => {
      const cmp = compareEmployees(a, b, sortKey);
      return sortDir === "asc" ? cmp : -cmp;
    });
  }, [dbEmployees, q, dept, desig, subDept, onFloorRole, status, sortKey, sortDir, years]);

  // -- Pool Filtering ----------------------------------
  const poolRows = useMemo(() => {
    const filtered = dbEmployees.filter((e) => {
      const matchQ = matchesEmployeeSearch(e, q);
      return (
        matchQ &&
        (!dept || e.department === dept) &&
        (!desig || e.designation === desig) &&
        (!subDept || normalizeSubDepartmentKey(e.subDepartment) === normalizeSubDepartmentKey(subDept)) &&
        (!onFloorRole || normalizeOnFloorRole(e.jobRoleName) === normalizeOnFloorRole(onFloorRole)) &&
        (!status ||
          e.status === status ||
          (status === "Active" && e.status === "Resignation Under Review")) &&
        inFinancialYears(e.joiningDate, e.joiningDate, years)
      );
    });
    return [...filtered].sort((a, b) => {
      const cmp = comparePoolEmployees(a, b, poolSortKey);
      return poolSortDir === "asc" ? cmp : -cmp;
    });
  }, [dbEmployees, q, dept, desig, subDept, onFloorRole, status, poolSortKey, poolSortDir, years]);

  // Determine active rows based on tab
  const activeRows = tab === "directory" ? directoryRows : poolRows;

  const totalPages = totalPageCount(activeRows.length, pageSize);
  const currentPage = Math.min(page, totalPages);
  const pageRows = paginateSlice(activeRows, currentPage, pageSize);
  const pageRange = paginationRange(currentPage, pageSize, activeRows.length);
  const pageIds = pageRows.map((e) => e.id);
  const allPageSelected = pageIds.length > 0 && pageIds.every((id) => selectedIds.has(id));

  const toggleSelected = (id: string) => {
    setSelectedIds((current) => {
      const next = new Set(current);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const togglePageSelected = () => {
    setSelectedIds((current) => {
      const next = new Set(current);
      if (allPageSelected) pageIds.forEach((id) => next.delete(id));
      else pageIds.forEach((id) => next.add(id));
      return next;
    });
  };

  const applyLoginAccess = async (createLogin: boolean) => {
    const ids = [...selectedIds];
    if (ids.length === 0) return;
    setLoginBusy(true);
    try {
      const result = await setEmployeeLoginAccess(ids, createLogin);
      const label = createLogin ? "Employee and login" : "Employee only";
      toast.success(`${result.updated} ${result.updated === 1 ? "employee" : "employees"} set to ${label}`);
      if (result.notFound.length > 0) {
        toast.error(`${result.notFound.length} selected ${result.notFound.length === 1 ? "person was" : "people were"} not found`);
      }
      setSelectedIds(new Set());
      await loadEmployees();
    } catch (error: any) {
      toast.error(error?.message ?? "Could not update login access");
    } finally {
      setLoginBusy(false);
    }
  };

  // Reset page when filters, tab, or pageSize change
  useEffect(() => {
    setPage(1);
  }, [q, dept, desig, subDept, onFloorRole, status, tab, sortKey, sortDir, poolSortKey, poolSortDir, pageSize, years]);

  // Guard with dynamic RBAC: users with view access can view; users without access are redirected
  if (!permissionsLoading && !canViewDirectory) return <Navigate to="/access-denied" />;

  const title = canManageDirectory ? "Employee Directory" : "Directory";
  const subtitle =
    tab === "directory"
      ? `${activeRows.length} of ${dbEmployees.length} employees`
      : `${activeRows.length} of ${dbEmployees.length} resources active`;

  const hasActiveFilters = Boolean(q || dept || desig || subDept || onFloorRole || status);
  const clearAllFilters = () => {
    setQ("");
    setDept("");
    setDesig("");
    setSubDept("");
    setOnFloorRole("");
    setStatus("");
  };

  return (
    <AppShell title={title} subtitle={subtitle}>
      {/* Row 1 (Views & Global Actions) */}
      <div className="mb-3 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        {/* Left: [Directory] / [Resource Pool] view switcher */}
        <div>
          {!basicDirectoryView && ENABLE_RESOURCE_POOL && (
            <SegmentedControl
              size="sm"
              value={tab}
              onChange={setTab}
              options={[
                { value: "directory", label: <><Users className="h-3.5 w-3.5" /> Directory</> },
                { value: "pool", label: <><Activity className="h-3.5 w-3.5" /> Resource Pool</> },
              ]}
            />
          )}
        </div>

        {/* Right: Bulk upload menu and [+ Add Employee] button - requires View + Manage access */}
        {canManageDirectory && (
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
        <div className="grid grid-cols-1 items-center gap-2.5 sm:grid-cols-2 lg:grid-cols-[minmax(0,1.35fr)_repeat(5,minmax(0,1fr))]">
          {/* Search input */}
          <div className="relative min-w-0">
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
          <div className="min-w-0">
            <FilterSelect
              value={dept}
              onChange={(value) => {
                setDept(value);
                setDesig("");
                setSubDept("");
              }}
              placeholder="All Departments"
              options={departmentFilterOptions}
            />
          </div>

          {/* Designation Filter */}
          <div className="min-w-0">
            <FilterSelect
              value={desig}
              onChange={(value) => {
                setDesig(value);
                setSubDept("");
              }}
              placeholder="All Designations"
              options={designationFilterOptions}
            />
          </div>

          {/* Sub-Department Filter */}
          <div className="min-w-0">
            <FilterSelect
              value={subDept}
              onChange={setSubDept}
              placeholder="All Sub-Departments"
              options={subDepartmentFilterOptions}
            />
          </div>

          <div className="min-w-0">
            <FilterSelect
              value={onFloorRole}
              onChange={setOnFloorRole}
              placeholder="All On Floor Roles"
              options={onFloorRoleFilterOptions}
            />
          </div>

          {/* Status Filter */}
          <div className="min-w-0">
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
              className="inline-flex h-9 shrink-0 items-center justify-center gap-1.5 rounded-md border border-dashed border-border px-3 text-xs font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
            >
              <RotateCcw className="h-3.5 w-3.5" />
              <span>Reset</span>
            </button>
          )}
        </div>
      </div>

      {canManageDirectory && tab === "directory" && selectedIds.size > 0 && (
        <div className="mb-3 flex flex-wrap items-center gap-2 rounded-lg border border-border bg-card px-4 py-3">
          <span className="text-sm font-medium text-foreground">{selectedIds.size} selected</span>
          <button
            type="button"
            disabled={loginBusy}
            onClick={() => void applyLoginAccess(true)}
            className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-60"
          >
            Employee and login
          </button>
          <button
            type="button"
            disabled={loginBusy}
            onClick={() => void applyLoginAccess(false)}
            className="rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-60"
          >
            Employee only
          </button>
          <button
            type="button"
            disabled={loginBusy}
            onClick={() => setSelectedIds(new Set())}
            className="rounded-md px-2 py-1.5 text-xs font-medium text-muted-foreground hover:text-foreground"
          >
            Clear
          </button>
        </div>
      )}

      {/* Directory Table / Pool Table */}
      {tab === "directory" ? (
        <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
          <div className="overflow-auto max-h-[calc(100vh-210px)]">
            <table className="w-full min-w-max text-sm">
              <thead className="sticky top-0 z-10 border-b border-black/10 bg-[#E8E8ED] text-left dark:border-white/10 dark:bg-[#3A3A3C] [&_th]:bg-[#E8E8ED] dark:[&_th]:bg-[#3A3A3C]">
                <tr>
                  {canManageDirectory && (
                    <th className="w-10 px-3 py-3.5">
                      <input
                        type="checkbox"
                        aria-label="Select all employees on this page"
                        checked={allPageSelected}
                        onChange={togglePageSelected}
                      />
                    </th>
                  )}
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
              <tbody>
                {pageRows.map((e, rowIndex) => (
                  <tr
                    key={e.id}
                    onClick={() =>
                      navigate({ to: "/employee-directory/$id", params: { id: e.id } })
                    }
                    className={cn(
                      "cursor-pointer border-b border-black/[0.06] transition-colors last:border-b-0 hover:bg-primary/10 dark:border-white/[0.06]",
                      rowIndex % 2 === 1 && "bg-black/[0.03] dark:bg-white/[0.04]",
                    )}
                  >
                    {canManageDirectory && (
                      <td className="w-10 px-3 py-3.5" onClick={(event) => event.stopPropagation()}>
                        <input
                          type="checkbox"
                          aria-label={`Select ${e.firstName} ${e.lastName}`}
                          checked={selectedIds.has(e.id)}
                          onChange={() => toggleSelected(e.id)}
                        />
                      </td>
                    )}
                    <td className="whitespace-nowrap px-4 py-3.5 font-mono text-xs text-muted-foreground" title={e.id}>
                      {e.id}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3.5">
                      <Link
                        to="/employee-directory/$id"
                        params={{ id: e.id }}
                        className="flex items-center gap-2.5 hover:text-primary transition-colors"
                      >
                        <Avatar name={`${e.firstName} ${e.lastName}`} size={28} />
                        <span className="font-semibold" title={`${e.firstName} ${e.lastName}`}>
                          {e.firstName} {e.lastName}
                        </span>
                      </Link>
                    </td>
                    <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground" title={e.department}>
                      {dash(e.department)}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground" title={e.designation}>
                      {dash(e.designation)}
                    </td>
                    <td
                      className="whitespace-nowrap px-4 py-3.5 text-muted-foreground"
                      title={formatOnFloorRoleDisplay(e.jobRoleName) || e.jobRoleName}
                    >
                      {dash(formatOnFloorRoleDisplay(e.jobRoleName) || e.jobRoleName)}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground" title={e.subDepartment}>
                      {dash(e.subDepartment)}
                    </td>
                    {!basicDirectoryView && (
                      <>
                        <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground" title={e.reportingManager}>
                          {dash(e.reportingManager)}
                        </td>
                        <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground" title={e.workLocation === "Onsite" && e.projectSite ? `Onsite (${e.projectSite})` : e.workLocation}>
                          {e.workLocation === "Onsite" && e.projectSite ? (
                            <span className="inline-flex items-center gap-1.5">
                              <span className="inline-flex items-center rounded-full border border-info/30 bg-info/10 px-2 py-0.5 text-[11px] font-medium text-info">
                                Onsite
                              </span>
                              <span className="text-xs text-foreground">{e.projectSite}</span>
                            </span>
                          ) : (
                            dash(e.workLocation)
                          )}
                        </td>
                        <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground" title={e.category}>
                          {dash(e.category)}
                        </td>
                        <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground">
                          {formatDateDMY(e.joiningDate)}
                        </td>
                        <td className="whitespace-nowrap px-4 py-3.5 align-middle">
                          <EmpStatusBadge status={employeeStatusDisplayLabel(e)} />
                        </td>
                      </>
                    )}
                  </tr>
                ))}
                {pageRows.length === 0 && (
                  <tr>
                    <td
                      colSpan={(basicDirectoryView ? 6 : 11) + (canManageDirectory ? 1 : 0)}
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
          <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-border bg-card/95 backdrop-blur-md px-4 py-3 text-xs text-muted-foreground shadow-xs">
            <div className="flex items-center gap-3">
              <span>
                Showing <strong className="font-semibold text-foreground">{pageRange.from}</strong> - <strong className="font-semibold text-foreground">
                  {pageRange.to}
                </strong>{" "}
                of <strong className="font-semibold text-foreground">{activeRows.length}</strong> employees
              </span>
              <span className="text-border">|</span>
              <div className="flex items-center gap-1.5">
                <span>Per page:</span>
                <RowsPerPageSelect
                  value={pageSize}
                  onChange={setPageSize}
                />
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={currentPage <= 1}
                className="inline-flex items-center gap-1 rounded-md border border-border bg-background px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                <ChevronLeft className="h-3.5 w-3.5" /> Previous
              </button>
              <span className="px-2 tabular-nums font-semibold text-foreground">
                {currentPage} / {totalPages}
              </span>
              <button
                type="button"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage >= totalPages}
                className="inline-flex items-center gap-1 rounded-md border border-border bg-background px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                Next <ChevronRight className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>
        </div>
      ) : (
        <div className="w-fit max-w-full rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
          <div className="overflow-auto max-h-[calc(100vh-210px)]">
            <table className="w-max table-fixed text-sm">
              <thead className="sticky top-0 z-10 border-b border-black/10 bg-[#E8E8ED] text-left dark:border-white/10 dark:bg-[#3A3A3C] [&_th]:bg-[#E8E8ED] dark:[&_th]:bg-[#3A3A3C]">
                <tr>
                  {POOL_COLUMNS.map((col) =>
                    col.key ? (
                      <SortableTh
                        key={col.label}
                        label={col.label}
                        column={col.key}
                        sortKey={poolSortKey}
                        sortDir={poolSortDir}
                        className={col.className}
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
                          "whitespace-nowrap px-4 py-3.5 text-[13px] font-semibold tracking-[-0.01em] text-muted-foreground",
                          col.className,
                          col.align === "right" ? "text-right" : "text-left",
                        )}
                      >
                        {col.label}
                      </th>
                    ),
                  )}
                </tr>
              </thead>
              <tbody>
                {pageRows.map((e, rowIndex) => {
                  return (
                    <tr
                      key={e.id}
                      onClick={() =>
                        navigate({ to: "/employee-directory/$id", params: { id: e.id } })
                      }
                      className={cn(
                        "cursor-pointer border-b border-black/[0.06] transition-colors last:border-b-0 hover:bg-primary/10 dark:border-white/[0.06]",
                        rowIndex % 2 === 1 && "bg-black/[0.03] dark:bg-white/[0.04]",
                      )}
                    >
                      <td className="w-40 min-w-[140px] whitespace-nowrap px-4 py-3.5 font-semibold text-foreground/90 truncate" title={e.department}>
                        {dash(e.department)}
                      </td>
                      <td className="w-52 min-w-[185px] whitespace-nowrap px-4 py-3.5 text-muted-foreground truncate" title={e.subDepartment}>
                        {dash(e.subDepartment)}
                      </td>
                      <td className="w-56 min-w-[190px] whitespace-nowrap px-4 py-3.5">
                        <Link
                          to="/employee-directory/$id"
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
                        <AllocationStatusBadge status={getAllocationStatus(e)} />
                      </td>
                      <td className="w-44 min-w-[150px] whitespace-nowrap px-4 py-3.5">
                        <AllocationTypeBadge type={e.allocationType} />
                      </td>
                      <td
                        className="w-56 min-w-[205px] whitespace-nowrap px-4 py-3.5 text-xs font-medium tabular-nums text-muted-foreground"
                        title={e.allocatedProjectName ? `${e.allocatedProjectName}: ${formatPoolAllocationDuration(e)}` : undefined}
                      >
                        {formatPoolAllocationDuration(e)}
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
                    <td colSpan={9} className="px-4 py-12 text-center text-sm text-muted-foreground">
                      No resources match the selected criteria.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Frozen / Sticky Pagination Footer */}
          <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-border bg-card/95 backdrop-blur-md px-4 py-3 text-xs text-muted-foreground shadow-xs">
            <div className="flex items-center gap-3">
              <span>
                Showing <strong className="font-semibold text-foreground">{pageRange.from}</strong> - <strong className="font-semibold text-foreground">
                  {pageRange.to}
                </strong>{" "}
                of <strong className="font-semibold text-foreground">{activeRows.length}</strong> resources
              </span>
              <span className="text-border">|</span>
              <div className="flex items-center gap-1.5">
                <span>Per page:</span>
                <RowsPerPageSelect
                  value={pageSize}
                  onChange={setPageSize}
                />
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={currentPage <= 1}
                className="inline-flex items-center gap-1 rounded-md border border-border bg-background px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                <ChevronLeft className="h-3.5 w-3.5" /> Previous
              </button>
              <span className="px-2 tabular-nums font-semibold text-foreground">
                {currentPage} / {totalPages}
              </span>
              <button
                type="button"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={currentPage >= totalPages}
                className="inline-flex items-center gap-1 rounded-md border border-border bg-background px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
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
        existingEmployees={dbEmployees}
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
