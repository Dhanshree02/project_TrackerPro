import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import { Search, Download, UserMinus, CheckCircle, Clock, Building2, ChevronUp, ChevronDown } from "lucide-react";
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
      { title: "Exit Summary — Pulse PMO" },
      { name: "description", content: "Offboarding analytics, clearances tracking and exit logs." },
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
  | "employee"
  | "department"
  | "designation"
  | "exitReason"
  | "lastWorkingDay"
  | "exitType"
  | "exitedOn";
type SortDir = "asc" | "desc";

const EXIT_COLUMNS: { label: string; key: ExitSortKey }[] = [
  { label: "Employee", key: "employee" },
  { label: "Department", key: "department" },
  { label: "Designation", key: "designation" },
  { label: "Exit Reason", key: "exitReason" },
  { label: "Last Working Day", key: "lastWorkingDay" },
  { label: "Exit Type", key: "exitType" },
  { label: "Exited On", key: "exitedOn" },
];

function sortBlank(value?: string | null): string {
  return !value || value === "—" ? "" : value;
}

function compareExits(a: ApiExitedEmployee, b: ApiExitedEmployee, key: ExitSortKey): number {
  switch (key) {
    case "employee":
      return a.fullName.localeCompare(b.fullName, undefined, { sensitivity: "base" });
    case "department":
      return sortBlank(a.departmentName).localeCompare(sortBlank(b.departmentName), undefined, {
        sensitivity: "base",
      });
    case "designation":
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
    case "exitedOn":
      return sortBlank(a.exitedAtUtc).localeCompare(sortBlank(b.exitedAtUtc));
  }
}

function SortableTh({
  label,
  column,
  sortKey,
  sortDir,
  onSort,
}: {
  label: string;
  column: ExitSortKey;
  sortKey: ExitSortKey;
  sortDir: SortDir;
  onSort: (column: ExitSortKey) => void;
}) {
  const active = sortKey === column;
  const Icon = active && sortDir === "desc" ? ChevronDown : ChevronUp;
  return (
    <th className="whitespace-nowrap px-4 py-3 font-medium">
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

function ExitSummaryPage() {
  const { status: authStatus } = useAuth();
  const { isDhanshree, isHr } = useRoleContext();
  const [q, setQ] = useState("");
  const [deptFilter, setDeptFilter] = useState("");
  const [typeFilter, setTypeFilter] = useState("");
  const [exits, setExits] = useState<ApiExitedEmployee[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [sortKey, setSortKey] = useState<ExitSortKey>("exitedOn");
  const [sortDir, setSortDir] = useState<SortDir>("desc");

  useEffect(() => {
    if (authStatus !== "authed") return;
    let cancelled = false;
    (async () => {
      setIsLoading(true);
      setLoadError(null);
      try {
        const items = await fetchAllExitedEmployees();
        if (!cancelled) setExits(items);
      } catch (error: any) {
        if (!cancelled) {
          const message = error?.message ?? "Failed to load exited employees";
          setLoadError(message);
          setExits([]);
          toast.error(message);
        }
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [authStatus]);

  const filtered = useMemo(() => {
    const rows = exits.filter((e) => {
      const reason = exitReasonOf(e);
      const matchQ =
        !q ||
        e.fullName.toLowerCase().includes(q.toLowerCase()) ||
        e.employeeCode.toLowerCase().includes(q.toLowerCase()) ||
        reason.toLowerCase().includes(q.toLowerCase());
      const matchDept = !deptFilter || (e.departmentName ?? "") === deptFilter;
      const matchType = !typeFilter || (e.exitType ?? "") === typeFilter;
      return matchQ && matchDept && matchType;
    });
    return [...rows].sort((a, b) => {
      const cmp = compareExits(a, b, sortKey);
      return sortDir === "asc" ? cmp : -cmp;
    });
  }, [exits, q, deptFilter, typeFilter, sortKey, sortDir]);

  if (!isDhanshree && !isHr) return <Navigate to="/" />;

  const departments = Array.from(
    new Set(exits.map((e) => e.departmentName).filter((d): d is string => Boolean(d))),
  ).sort();
  const exitTypes = Array.from(
    new Set(exits.map((e) => e.exitType).filter((t): t is string => Boolean(t))),
  ).sort();

  const now = new Date();
  const thisMonth = exits.filter((e) => {
    const d = new Date(e.exitedAtUtc);
    return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
  }).length;

  const stats = {
    total: exits.length,
    thisMonth,
    withLastDay: exits.filter((e) => Boolean(e.lastWorkingDay)).length,
    departments: departments.length,
  };

  const exportCsv = () => {
    if (filtered.length === 0) {
      toast.error("No records to export");
      return;
    }
    const header = [
      "Employee ID",
      "Name",
      "Department",
      "Designation",
      "Exit Type",
      "Exit Reason",
      "Last Working Day",
      "Exited On",
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
    a.download = "exit-summary.csv";
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <AppShell
      title="Exit Summary"
      subtitle="Employees moved from the directory into exited employees."
    >
      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 mb-6">
        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4">
          <div className="p-3 rounded-lg bg-red-500/10 text-red-500">
            <UserMinus className="h-6 w-6" />
          </div>
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
              Total Exits
            </div>
            <div className="text-2xl font-bold mt-0.5">{stats.total}</div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4">
          <div className="p-3 rounded-lg bg-emerald-500/10 text-emerald-500">
            <CheckCircle className="h-6 w-6" />
          </div>
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
              Exits This Month
            </div>
            <div className="text-2xl font-bold mt-0.5 text-emerald-600 dark:text-emerald-400">
              {stats.thisMonth}
            </div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4">
          <div className="p-3 rounded-lg bg-amber-500/10 text-amber-500">
            <Clock className="h-6 w-6" />
          </div>
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
              With Last Working Day
            </div>
            <div className="text-2xl font-bold mt-0.5 text-amber-600 dark:text-amber-400">
              {stats.withLastDay}
            </div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4">
          <div className="p-3 rounded-lg bg-blue-500/10 text-blue-500">
            <Building2 className="h-6 w-6" />
          </div>
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
              Departments
            </div>
            <div className="text-2xl font-bold mt-0.5 text-blue-600 dark:text-blue-400">
              {stats.departments}
            </div>
          </div>
        </div>
      </div>

      <div className="space-y-4">
        <div className="flex flex-wrap items-center gap-3 rounded-xl border border-border bg-card p-3">
          <div className="relative flex-1 min-w-[200px]">
            <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Search by name, ID or reason..."
              className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
            />
          </div>
          <select
            value={deptFilter}
            onChange={(e) => setDeptFilter(e.target.value)}
            className="h-9 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring min-w-[150px]"
          >
            <option value="">All Departments</option>
            {departments.map((d) => (
              <option key={d} value={d}>
                {d}
              </option>
            ))}
          </select>
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="h-9 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring min-w-[150px]"
          >
            <option value="">All Exit Types</option>
            {exitTypes.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
          <button
            type="button"
            onClick={exportCsv}
            className="h-9 inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 text-sm hover:bg-accent ml-auto"
          >
            <Download className="h-3.5 w-3.5" />
            Export Records
          </button>
        </div>

        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
              {EXIT_COLUMNS.map((col) => (
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
              {filtered.map((e) => (
                <tr key={e.id} className="hover:bg-accent/30 transition-colors">
                  <td className="whitespace-nowrap px-4 py-3.5 font-medium">
                    <div className="flex items-center gap-2.5">
                      <Avatar name={e.fullName} size={28} />
                      <div>
                        <span className="font-semibold block">{e.fullName}</span>
                        <span className="text-[10px] text-muted-foreground font-mono">
                          {e.employeeCode}
                        </span>
                      </div>
                    </div>
                  </td>
                  <td className="whitespace-nowrap px-4 py-3.5">{e.departmentName || "—"}</td>
                  <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground">
                    {e.designationName || "—"}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground">
                    {exitReasonOf(e)}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3.5 text-xs font-semibold text-foreground/90">
                    {formatDate(e.lastWorkingDay)}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3.5">
                    <span
                      className={cn(
                        "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-semibold",
                        "border-emerald-500/30 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400",
                      )}
                    >
                      {e.exitType?.trim() || "Exited"}
                    </span>
                  </td>
                  <td className="whitespace-nowrap px-4 py-3.5 text-xs text-muted-foreground">
                    {formatDate(e.exitedAtUtc)}
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-4 py-12 text-center text-sm text-muted-foreground">
                    {isLoading
                      ? "Loading exited employees…"
                      : loadError
                        ? `Could not load exited employees: ${loadError}`
                        : exits.length === 0
                          ? "No exited employees yet. Offboard someone from the directory."
                          : "No offboarding logs found matching your filter options."}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </AppShell>
  );
}
