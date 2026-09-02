import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import {
  Search,
  Download,
  UserMinus,
  CheckCircle2,
  Clock,
  Building2,
  ChevronUp,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  X,
  Users,
  ExternalLink,
  Calendar,
  FilterX,
  FileSpreadsheet,
  AlertCircle,
} from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { useRoleContext } from "@/lib/role-context";
import { Avatar } from "@/components/pills";
import { cn } from "@/lib/utils";
import { fetchAllExitedEmployees, type ApiExitedEmployee } from "@/lib/api/employees";

export const Route = createFileRoute("/dh-exit-summary")({
  head: () => ({
    meta: [
      { title: "Exit Summary — TrackerPro" },
      { name: "description", content: "Offboarding analytics, clearances tracking and historical exit logs." },
    ],
  }),
  component: ExitSummaryPage,
});

function formatDate(value?: string | null): string {
  if (!value) return "—";
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return value.slice(0, 10);
  return d.toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
}

function exitReasonOf(e: ApiExitedEmployee): string {
  return e.reasonForLeaving?.trim() || e.exitReason?.trim() || e.exitType?.trim() || "—";
}

type ExitSortKey =
  | "employeeCode"
  | "fullName"
  | "departmentName"
  | "designationName"
  | "exitReason"
  | "lastWorkingDay"
  | "exitType"
  | "exitedAtUtc";

type SortDir = "asc" | "desc";

const EXIT_COLUMNS: { label: string; key: ExitSortKey; className?: string }[] = [
  { label: "Emp ID", key: "employeeCode", className: "w-36 min-w-[125px]" },
  { label: "Employee", key: "fullName", className: "w-64 min-w-[200px]" },
  { label: "Department & Role", key: "departmentName", className: "w-56 min-w-[180px]" },
  { label: "Exit Type", key: "exitType", className: "w-36 min-w-[130px]" },
  { label: "Exit Reason", key: "exitReason", className: "w-64 min-w-[200px]" },
  { label: "Last Working Day", key: "lastWorkingDay", className: "w-48 min-w-[170px]" },
  { label: "Exited On", key: "exitedAtUtc", className: "w-36 min-w-[130px]" },
];

function sortBlank(value?: string | null): string {
  return !value || value === "—" ? "" : value;
}

function compareExits(a: ApiExitedEmployee, b: ApiExitedEmployee, key: ExitSortKey): number {
  switch (key) {
    case "employeeCode":
      return a.employeeCode.localeCompare(b.employeeCode, undefined, { numeric: true, sensitivity: "base" });
    case "fullName":
      return a.fullName.localeCompare(b.fullName, undefined, { sensitivity: "base" });
    case "departmentName":
      return sortBlank(a.departmentName).localeCompare(sortBlank(b.departmentName), undefined, {
        sensitivity: "base",
      });
    case "designationName":
      return sortBlank(a.designationName).localeCompare(sortBlank(b.designationName), undefined, {
        sensitivity: "base",
      });
    case "exitReason":
      return exitReasonOf(a).localeCompare(exitReasonOf(b), undefined, { sensitivity: "base" });
    case "lastWorkingDay":
      return sortBlank(a.lastWorkingDay).localeCompare(sortBlank(b.lastWorkingDay));
    case "exitType":
      return sortBlank(a.exitType).localeCompare(sortBlank(b.exitType), undefined, {
        sensitivity: "base",
      });
    case "exitedAtUtc":
      return sortBlank(a.exitedAtUtc).localeCompare(sortBlank(b.exitedAtUtc));
  }
}

function SortableTh({
  label,
  column,
  sortKey,
  sortDir,
  className,
  onSort,
  isLast,
}: {
  label: string;
  column: ExitSortKey;
  sortKey: ExitSortKey;
  sortDir: SortDir;
  className?: string;
  onSort: (column: ExitSortKey) => void;
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

function ExitTypeBadge({ type }: { type?: string | null }) {
  const t = (type || "").trim();
  if (!t || t.toLowerCase() === "exited" || t === "NA") {
    return (
      <span className="inline-flex items-center rounded-full border border-border bg-muted/60 px-2.5 py-0.5 text-[11px] font-semibold text-foreground">
        Exited
      </span>
    );
  }
  const lower = t.toLowerCase();
  if (lower.includes("resign")) {
    return (
      <span className="inline-flex items-center rounded-full border border-amber-500/30 bg-amber-500/10 px-2.5 py-0.5 text-[11px] font-semibold text-amber-600 dark:text-amber-400">
        Resignation
      </span>
    );
  }
  if (lower.includes("terminat") || lower.includes("involuntary") || lower.includes("abscond")) {
    return (
      <span className="inline-flex items-center rounded-full border border-destructive/30 bg-destructive/10 px-2.5 py-0.5 text-[11px] font-semibold text-destructive">
        {t}
      </span>
    );
  }
  if (lower.includes("contract") || lower.includes("project")) {
    return (
      <span className="inline-flex items-center rounded-full border border-blue-500/30 bg-blue-500/10 px-2.5 py-0.5 text-[11px] font-semibold text-blue-600 dark:text-blue-400">
        Contract End
      </span>
    );
  }
  if (lower.includes("retire")) {
    return (
      <span className="inline-flex items-center rounded-full border border-purple-500/30 bg-purple-500/10 px-2.5 py-0.5 text-[11px] font-semibold text-purple-600 dark:text-purple-400">
        Retirement
      </span>
    );
  }
  return (
    <span className="inline-flex items-center rounded-full border border-emerald-500/30 bg-emerald-500/10 px-2.5 py-0.5 text-[11px] font-semibold text-emerald-600 dark:text-emerald-400">
      {t}
    </span>
  );
}

function ExitSummaryPage() {
  const { status: authStatus } = useAuth();
  const { isDhanshree, isHr, isEmployee, isPmFamily, isPmoFamily, isAccounts, isSales } =
    useRoleContext();

  const [q, setQ] = useState("");
  const [deptFilter, setDeptFilter] = useState("");
  const [typeFilter, setTypeFilter] = useState("");
  const [datePeriodFilter, setDatePeriodFilter] = useState<"all" | "this-month" | "last-3-months" | "this-year">("all");
  const [exits, setExits] = useState<ApiExitedEmployee[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [sortKey, setSortKey] = useState<ExitSortKey>("exitedAtUtc");
  const [sortDir, setSortDir] = useState<SortDir>("desc");

  // Pagination states
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  const loadExitedData = async () => {
    setIsLoading(true);
    setLoadError(null);
    try {
      const items = await fetchAllExitedEmployees();
      setExits(items);
    } catch (error: any) {
      const message = error?.message ?? "Failed to load exited employees";
      setLoadError(message);
      setExits([]);
      toast.error(message);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (authStatus !== "authed") return;
    void loadExitedData();
  }, [authStatus]);

  const hasAccess = isDhanshree || isHr || isEmployee || isPmFamily || isPmoFamily || isAccounts || isSales;
  if (!hasAccess) return <Navigate to="/" />;

  const departments = useMemo(
    () =>
      Array.from(
        new Set(exits.map((e) => e.departmentName).filter((d): d is string => Boolean(d))),
      ).sort(),
    [exits],
  );

  const exitTypes = useMemo(
    () =>
      Array.from(
        new Set(exits.map((e) => e.exitType).filter((t): t is string => Boolean(t))),
      ).sort(),
    [exits],
  );

  const now = new Date();
  const currentMonthCount = exits.filter((e) => {
    const d = new Date(e.exitedAtUtc);
    return !Number.isNaN(d.getTime()) && d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
  }).length;

  const withLwdCount = exits.filter((e) => Boolean(e.lastWorkingDay)).length;

  const filtered = useMemo(() => {
    const qTrim = q.trim().toLowerCase();
    const rows = exits.filter((e) => {
      const reason = exitReasonOf(e).toLowerCase();
      const matchQ =
        !qTrim ||
        e.fullName.toLowerCase().includes(qTrim) ||
        e.employeeCode.toLowerCase().includes(qTrim) ||
        (e.departmentName && e.departmentName.toLowerCase().includes(qTrim)) ||
        (e.designationName && e.designationName.toLowerCase().includes(qTrim)) ||
        reason.includes(qTrim);

      const matchDept = !deptFilter || (e.departmentName ?? "") === deptFilter;
      const matchType = !typeFilter || (e.exitType ?? "") === typeFilter;

      let matchPeriod = true;
      if (datePeriodFilter !== "all") {
        const exitDate = new Date(e.exitedAtUtc || e.lastWorkingDay || "");
        if (!Number.isNaN(exitDate.getTime())) {
          if (datePeriodFilter === "this-month") {
            matchPeriod = exitDate.getMonth() === now.getMonth() && exitDate.getFullYear() === now.getFullYear();
          } else if (datePeriodFilter === "last-3-months") {
            const threeMonthsAgo = new Date();
            threeMonthsAgo.setMonth(now.getMonth() - 3);
            matchPeriod = exitDate >= threeMonthsAgo;
          } else if (datePeriodFilter === "this-year") {
            matchPeriod = exitDate.getFullYear() === now.getFullYear();
          }
        }
      }

      return matchQ && matchDept && matchType && matchPeriod;
    });

    return [...rows].sort((a, b) => {
      const cmp = compareExits(a, b, sortKey);
      return sortDir === "asc" ? cmp : -cmp;
    });
  }, [exits, q, deptFilter, typeFilter, datePeriodFilter, sortKey, sortDir, now]);

  // Reset page to 1 when filters change
  useEffect(() => {
    setPage(1);
  }, [q, deptFilter, typeFilter, datePeriodFilter, pageSize]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
  const currentPage = Math.min(page, totalPages);
  const pagedRows = useMemo(() => {
    const start = (currentPage - 1) * pageSize;
    return filtered.slice(start, start + pageSize);
  }, [filtered, currentPage, pageSize]);

  const hasActiveFilters = Boolean(q || deptFilter || typeFilter || datePeriodFilter !== "all");

  const clearFilters = () => {
    setQ("");
    setDeptFilter("");
    setTypeFilter("");
    setDatePeriodFilter("all");
  };

  const exportCsv = () => {
    if (filtered.length === 0) {
      toast.error("No records to export");
      return;
    }
    const header = [
      "TK ID",
      "Full Name",
      "Department",
      "Designation",
      "Exit Type",
      "Exit Reason",
      "Last Working Day",
      "Exited On (UTC)",
    ];
    const rows = filtered.map((e) => [
      e.employeeCode,
      e.fullName,
      e.departmentName ?? "",
      e.designationName ?? "",
      e.exitType ?? "",
      exitReasonOf(e),
      e.lastWorkingDay ?? "",
      e.exitedAtUtc,
    ]);
    const csv = [header, ...rows]
      .map((row) => row.map((cell) => `"${String(cell).replaceAll('"', '""')}"`).join(","))
      .join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `exit-summary-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
    toast.success(`Exported ${filtered.length} exited employee records to CSV`);
  };

  return (
    <AppShell
      title="Exit Summary"
      subtitle="Offboarding analytics, clearances tracking, and historical exit logs."
    >
      {/* Top action header */}
      <div className="mb-6 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div className="flex items-center gap-2">
          <Link
            to="/dh-employee-directory"
            className="inline-flex items-center gap-1.5 rounded-lg border border-input bg-card px-3 py-1.5 text-xs font-semibold text-foreground hover:bg-accent shadow-xs active:scale-[0.98] transition-all"
          >
            <Users className="h-3.5 w-3.5 text-muted-foreground" />
            <span>Employee Directory</span>
          </Link>
        </div>
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={exportCsv}
            disabled={filtered.length === 0}
            className="inline-flex items-center gap-1.5 rounded-lg border border-input bg-card px-3.5 py-1.5 text-xs font-semibold text-foreground hover:bg-accent shadow-xs active:scale-[0.98] transition-all disabled:opacity-50 disabled:pointer-events-none"
          >
            <Download className="h-3.5 w-3.5 text-muted-foreground" />
            <span>Export CSV ({filtered.length})</span>
          </button>
        </div>
      </div>

      {/* KPI Analytics Cards */}
      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 mb-6">
        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4 transition-all hover:shadow-sm">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-rose-500/10 text-rose-600 dark:text-rose-400">
            <UserMinus className="h-6 w-6" />
          </div>
          <div className="min-w-0 flex-1">
            <div className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
              Total Offboarded
            </div>
            <div className="text-2xl font-bold mt-0.5 tabular-nums text-foreground">{exits.length}</div>
            <div className="text-[11px] text-muted-foreground mt-0.5">Historical records</div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4 transition-all hover:shadow-sm">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
            <Calendar className="h-6 w-6" />
          </div>
          <div className="min-w-0 flex-1">
            <div className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
              Exits This Month
            </div>
            <div className="text-2xl font-bold mt-0.5 tabular-nums text-emerald-600 dark:text-emerald-400">
              {currentMonthCount}
            </div>
            <div className="text-[11px] text-muted-foreground mt-0.5">Current cycle</div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4 transition-all hover:shadow-sm">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-amber-500/10 text-amber-600 dark:text-amber-400">
            <Clock className="h-6 w-6" />
          </div>
          <div className="min-w-0 flex-1">
            <div className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
              LWD Documented
            </div>
            <div className="text-2xl font-bold mt-0.5 tabular-nums text-amber-600 dark:text-amber-400">
              {withLwdCount}
            </div>
            <div className="text-[11px] text-muted-foreground mt-0.5">Clearance target set</div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4 transition-all hover:shadow-sm">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-blue-500/10 text-blue-600 dark:text-blue-400">
            <Building2 className="h-6 w-6" />
          </div>
          <div className="min-w-0 flex-1">
            <div className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
              Depts Impacted
            </div>
            <div className="text-2xl font-bold mt-0.5 tabular-nums text-blue-600 dark:text-blue-400">
              {departments.length}
            </div>
            <div className="text-[11px] text-muted-foreground mt-0.5">Across organization</div>
          </div>
        </div>
      </div>

      {/* Main Content Area */}
      <div className="space-y-4">
        {/* Filter and Search Bar */}
        <div className="rounded-xl border border-border bg-card p-3.5 shadow-xs">
          <div className="flex flex-col md:flex-row items-stretch md:items-center gap-2.5">
            {/* Search input */}
            <div className="relative flex-1 min-w-[220px]">
              <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                type="text"
                value={q}
                onChange={(e) => setQ(e.target.value)}
                placeholder="Search by name, ID, department, or reason…"
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
            <select
              value={deptFilter}
              onChange={(e) => setDeptFilter(e.target.value)}
              className="h-9 rounded-md border border-input bg-background px-3 text-xs font-medium text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring min-w-[150px] cursor-pointer hover:bg-muted/30 transition-colors"
            >
              <option value="">All Departments</option>
              {departments.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>

            {/* Exit Type Filter */}
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="h-9 rounded-md border border-input bg-background px-3 text-xs font-medium text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring min-w-[140px] cursor-pointer hover:bg-muted/30 transition-colors"
            >
              <option value="">All Exit Types</option>
              {exitTypes.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>

            {/* Date Range Filter */}
            <select
              value={datePeriodFilter}
              onChange={(e) => setDatePeriodFilter(e.target.value as any)}
              className="h-9 rounded-md border border-input bg-background px-3 text-xs font-medium text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring min-w-[140px] cursor-pointer hover:bg-muted/30 transition-colors"
            >
              <option value="all">All Dates</option>
              <option value="this-month">This Month</option>
              <option value="last-3-months">Last 3 Months</option>
              <option value="this-year">This Year</option>
            </select>

            {/* Clear Filters button */}
            {hasActiveFilters && (
              <button
                type="button"
                onClick={clearFilters}
                className="h-9 inline-flex items-center justify-center gap-1.5 rounded-md border border-dashed border-border px-3 text-xs font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
              >
                <FilterX className="h-3.5 w-3.5" />
                <span>Reset</span>
              </button>
            )}
          </div>
        </div>

        {/* Table Container */}
        <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
          <div className="overflow-auto max-h-[calc(100vh-270px)] min-h-[380px]">
            <table className="w-full min-w-[1080px] table-fixed text-sm">
              <thead className="sticky top-0 z-10 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700 shadow-2xs">
                <tr>
                  {EXIT_COLUMNS.map((col, idx, arr) => (
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
                {isLoading ? (
                  Array.from({ length: 5 }).map((_, i) => (
                    <tr key={`skel-${i}`} className="animate-pulse">
                      <td className="w-28 min-w-[100px] px-4 py-3.5">
                        <div className="h-4 w-16 rounded bg-muted" />
                      </td>
                      <td className="w-64 min-w-[200px] px-4 py-3.5">
                        <div className="flex items-center gap-2.5">
                          <div className="h-7 w-7 rounded-full bg-muted" />
                          <div className="space-y-1">
                            <div className="h-3.5 w-24 rounded bg-muted" />
                            <div className="h-2.5 w-16 rounded bg-muted" />
                          </div>
                        </div>
                      </td>
                      <td className="w-56 min-w-[180px] px-4 py-3.5">
                        <div className="h-3.5 w-28 rounded bg-muted" />
                      </td>
                      <td className="w-36 min-w-[130px] px-4 py-3.5">
                        <div className="h-5 w-20 rounded-full bg-muted" />
                      </td>
                      <td className="w-64 min-w-[200px] px-4 py-3.5">
                        <div className="h-3.5 w-32 rounded bg-muted" />
                      </td>
                      <td className="w-36 min-w-[130px] px-4 py-3.5">
                        <div className="h-3.5 w-20 rounded bg-muted" />
                      </td>
                      <td className="w-36 min-w-[130px] px-4 py-3.5">
                        <div className="h-3.5 w-20 rounded bg-muted" />
                      </td>
                    </tr>
                  ))
                ) : pagedRows.length > 0 ? (
                  pagedRows.map((e) => (
                    <tr
                      key={e.id}
                      className="group transition-colors hover:bg-accent/30"
                    >
                      {/* Emp ID */}
                      <td className="w-28 min-w-[100px] whitespace-nowrap px-4 py-3 font-mono text-xs text-muted-foreground font-medium truncate" title={e.employeeCode}>
                        {e.employeeCode}
                      </td>

                      {/* Employee Profile */}
                      <td className="w-64 min-w-[200px] whitespace-nowrap px-4 py-3 font-medium">
                        <Link
                          to="/dh-employee-directory/$id"
                          params={{ id: e.id }}
                          className="flex items-center gap-2.5 text-foreground hover:text-primary transition-colors min-w-0"
                        >
                          <Avatar name={e.fullName} size={30} />
                          <div className="truncate">
                            <span className="font-semibold block text-xs truncate" title={e.fullName}>{e.fullName}</span>
                            <span className="text-[11px] text-muted-foreground block font-normal truncate" title={e.designationName || "Ex-Employee"}>
                              {e.designationName || "Ex-Employee"}
                            </span>
                          </div>
                        </Link>
                      </td>

                      {/* Department & Role */}
                      <td className="w-56 min-w-[180px] whitespace-nowrap px-4 py-3 truncate">
                        <div className="text-xs font-medium text-foreground truncate" title={e.departmentName || "—"}>{e.departmentName || "—"}</div>
                        <div className="text-[11px] text-muted-foreground truncate" title={e.designationName || "—"}>{e.designationName || "—"}</div>
                      </td>

                      {/* Exit Type */}
                      <td className="w-36 min-w-[130px] whitespace-nowrap px-4 py-3">
                        <ExitTypeBadge type={e.exitType} />
                      </td>

                      {/* Exit Reason */}
                      <td className="w-64 min-w-[200px] px-4 py-3">
                        <div className="text-xs text-muted-foreground line-clamp-2 leading-relaxed" title={exitReasonOf(e)}>
                          {exitReasonOf(e)}
                        </div>
                      </td>

                      {/* Last Working Day */}
                      <td className="w-36 min-w-[130px] whitespace-nowrap px-4 py-3 text-xs font-medium text-foreground/90">
                        {e.lastWorkingDay ? (
                          <span className="inline-flex items-center gap-1">
                            <Calendar className="h-3 w-3 text-muted-foreground" />
                            <span>{formatDate(e.lastWorkingDay)}</span>
                          </span>
                        ) : (
                          "—"
                        )}
                      </td>

                      {/* Exited On */}
                      <td className="w-36 min-w-[130px] whitespace-nowrap px-4 py-3 text-xs text-muted-foreground">
                        {formatDate(e.exitedAtUtc)}
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={7} className="px-4 py-16 text-center">
                      <div className="mx-auto flex max-w-sm flex-col items-center justify-center text-center">
                        <div className="flex h-12 w-12 items-center justify-center rounded-full bg-muted/60 text-muted-foreground mb-3">
                          <UserMinus className="h-6 w-6" />
                        </div>
                        <h4 className="text-sm font-semibold text-foreground">
                          {loadError ? "Failed to Load Exits" : "No Exited Records Found"}
                        </h4>
                        <p className="text-xs text-muted-foreground mt-1 leading-normal">
                          {loadError
                            ? loadError
                            : hasActiveFilters
                              ? "No offboarding records match the selected search terms or filters."
                              : "There are currently no offboarded employees recorded in the system."}
                        </p>
                        {hasActiveFilters && (
                          <button
                            type="button"
                            onClick={clearFilters}
                            className="mt-4 inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-semibold text-foreground hover:bg-accent shadow-xs transition-colors"
                          >
                            <FilterX className="h-3.5 w-3.5 text-muted-foreground" />
                            <span>Clear All Filters</span>
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* Frozen / Sticky Pagination Footer */}
          {!isLoading && filtered.length > 0 && (
            <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-slate-300 dark:border-slate-700 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80 shadow-xs">
              <div className="flex items-center gap-3">
                <span>
                  Showing <strong className="font-semibold text-blue-950 dark:text-blue-100">{(currentPage - 1) * pageSize + 1}</strong>–
                  <strong className="font-semibold text-blue-950 dark:text-blue-100">
                    {Math.min(currentPage * pageSize, filtered.length)}
                  </strong>{" "}
                  of <strong className="font-semibold text-blue-950 dark:text-blue-100">{filtered.length}</strong> records
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
          )}
        </div>
      </div>
    </AppShell>
  );
}
