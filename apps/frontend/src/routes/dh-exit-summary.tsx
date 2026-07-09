import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Search, Download, UserMinus, AlertCircle, CheckCircle, Clock, FileText } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { Avatar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/dh-exit-summary")({
  head: () => ({
    meta: [
      { title: "Employee Exit Summary — Pulse PMO" },
      { name: "description", content: "Offboarding analytics, clearances tracking and exit logs." },
    ],
  }),
  component: ExitSummaryPage,
});

// Mock Exit Data
interface ExitRecord {
  id: string;
  name: string;
  dept: string;
  exitReason: string;
  joiningDate: string;
  lastWorkingDate: string;
  clearanceStatus: "Completed" | "In Progress" | "Pending";
  clearanceProgress: number; // percentage
  feedbackScore: number; // rating out of 5
}

const mockExits: ExitRecord[] = [
  { id: "EMP-1002", name: "Vikram Mehta", dept: "Design", exitReason: "Better opportunities", joiningDate: "2020-04-12", lastWorkingDate: "2026-07-15", clearanceStatus: "In Progress", clearanceProgress: 60, feedbackScore: 4.2 },
  { id: "EMP-1005", name: "Pooja Verma", dept: "Marketing", exitReason: "Higher studies", joiningDate: "2021-08-20", lastWorkingDate: "2026-07-01", clearanceStatus: "Pending", clearanceProgress: 20, feedbackScore: 3.8 },
  { id: "EMP-1010", name: "Arjun Nair", dept: "Engineering", exitReason: "Career transition", joiningDate: "2019-11-05", lastWorkingDate: "2026-06-20", clearanceStatus: "Completed", clearanceProgress: 100, feedbackScore: 4.5 },
  { id: "EMP-1012", name: "Suresh Rao", dept: "Operations", exitReason: "Personal reasons", joiningDate: "2022-01-15", lastWorkingDate: "2026-08-05", clearanceStatus: "Pending", clearanceProgress: 10, feedbackScore: 4.0 },
  { id: "EMP-1018", name: "Deepak Das", dept: "Finance", exitReason: "Better opportunities", joiningDate: "2020-09-10", lastWorkingDate: "2026-05-30", clearanceStatus: "Completed", clearanceProgress: 100, feedbackScore: 3.5 },
  { id: "EMP-1025", name: "Neha Chauhan", dept: "Product", exitReason: "Work-life balance", joiningDate: "2021-05-18", lastWorkingDate: "2026-07-10", clearanceStatus: "In Progress", clearanceProgress: 75, feedbackScore: 4.8 },
  { id: "EMP-1031", name: "Manoj Deshpande", dept: "Sales", exitReason: "Health reasons", joiningDate: "2023-03-01", lastWorkingDate: "2026-07-28", clearanceStatus: "In Progress", clearanceProgress: 40, feedbackScore: 4.1 },
];

function ExitSummaryPage() {
  const { isDhanshree } = useRoleContext();
  const [q, setQ] = useState("");
  const [deptFilter, setDeptFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");

  if (!isDhanshree) return <Navigate to="/" />;

  const filtered = useMemo(() => {
    return mockExits.filter((e) => {
      const matchQ = !q || e.name.toLowerCase().includes(q.toLowerCase()) || e.id.toLowerCase().includes(q.toLowerCase()) || e.exitReason.toLowerCase().includes(q.toLowerCase());
      const matchDept = !deptFilter || e.dept === deptFilter;
      const matchStatus = !statusFilter || e.clearanceStatus === statusFilter;
      return matchQ && matchDept && matchStatus;
    });
  }, [q, deptFilter, statusFilter]);

  const departments = Array.from(new Set(mockExits.map((e) => e.dept)));

  const stats = {
    total: mockExits.length,
    completed: mockExits.filter((e) => e.clearanceStatus === "Completed").length,
    inProgress: mockExits.filter((e) => e.clearanceStatus === "In Progress").length,
    pending: mockExits.filter((e) => e.clearanceStatus === "Pending").length,
    avgFeedback: +(mockExits.reduce((acc, e) => acc + e.feedbackScore, 0) / mockExits.length).toFixed(1),
  };

  return (
    <AppShell title="Employee Exit Summary" subtitle="Track employee offboardings, clearance tasks, and exit feedback.">
      {/* Metrics Banner */}
      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 mb-6">
        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4">
          <div className="p-3 rounded-lg bg-red-500/10 text-red-500">
            <UserMinus className="h-6 w-6" />
          </div>
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Total Exits (Q2)</div>
            <div className="text-2xl font-bold mt-0.5">{stats.total}</div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4">
          <div className="p-3 rounded-lg bg-emerald-500/10 text-emerald-500">
            <CheckCircle className="h-6 w-6" />
          </div>
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Completed Clearances</div>
            <div className="text-2xl font-bold mt-0.5 text-emerald-600 dark:text-emerald-400">{stats.completed}</div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4">
          <div className="p-3 rounded-lg bg-amber-500/10 text-amber-500">
            <Clock className="h-6 w-6" />
          </div>
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Active Offboardings</div>
            <div className="text-2xl font-bold mt-0.5 text-amber-600 dark:text-amber-400">{stats.inProgress + stats.pending}</div>
          </div>
        </div>

        <div className="rounded-xl border border-border bg-card p-4 shadow-xs flex items-center gap-4">
          <div className="p-3 rounded-lg bg-blue-500/10 text-blue-500">
            <FileText className="h-6 w-6" />
          </div>
          <div>
            <div className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">Avg Exit Rating</div>
            <div className="text-2xl font-bold mt-0.5 text-blue-600 dark:text-blue-400">{stats.avgFeedback} <span className="text-xs text-muted-foreground">/ 5.0</span></div>
          </div>
        </div>
      </div>

      {/* Main Layout: Filters & Grid */}
      <div className="space-y-4">
        {/* Filter bar */}
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
              <option key={d} value={d}>{d}</option>
            ))}
          </select>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="h-9 rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring min-w-[150px]"
          >
            <option value="">All Clearance States</option>
            <option value="Completed">Completed</option>
            <option value="In Progress">In Progress</option>
            <option value="Pending">Pending</option>
          </select>
          <button className="h-9 inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 text-sm hover:bg-accent ml-auto">
            <Download className="h-3.5 w-3.5" />
            Export Records
          </button>
        </div>

        {/* Clearance Data Table */}
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-4 py-3 font-medium">Employee</th>
                <th className="px-4 py-3 font-medium">Department</th>
                <th className="px-4 py-3 font-medium">Exit Reason</th>
                <th className="px-4 py-3 font-medium">Last Working Day</th>
                {/* <th className="px-4 py-3 font-medium">Clearance Progress</th> */}
                <th className="px-4 py-3 font-medium">Status</th>
                <th className="px-4 py-3 font-medium text-right">Clearance Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {filtered.map((e) => (
                <tr key={e.id} className="hover:bg-accent/30 transition-colors">
                  <td className="whitespace-nowrap px-4 py-3.5 font-medium">
                    <div className="flex items-center gap-2.5">
                      <Avatar name={e.name} size={28} />
                      <div>
                        <span className="font-semibold block">{e.name}</span>
                        <span className="text-[10px] text-muted-foreground font-mono">{e.id}</span>
                      </div>
                    </div>
                  </td>
                  <td className="whitespace-nowrap px-4 py-3.5">{e.dept}</td>
                  <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground">{e.exitReason}</td>
                  <td className="whitespace-nowrap px-4 py-3.5 text-xs font-semibold text-foreground/90">{e.lastWorkingDate}</td>

                  <td className="whitespace-nowrap px-4 py-3.5">
                    <span
                      className={cn(
                        "inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-semibold",
                        e.clearanceStatus === "Completed" ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400" :
                          e.clearanceStatus === "In Progress" ? "border-blue-500/30 bg-blue-500/10 text-blue-600 dark:text-blue-400" :
                            "border-amber-500/30 bg-amber-500/10 text-amber-600 dark:text-amber-400"
                      )}
                    >
                      {e.clearanceStatus}
                    </span>
                  </td>
                  <td className="whitespace-nowrap px-4 py-3.5 text-right">
                    <button
                      className={cn(
                        "text-xs px-2.5 py-1 rounded-md border",
                        e.clearanceStatus === "Completed"
                          ? "bg-card text-muted-foreground border-border cursor-not-allowed"
                          : "bg-primary text-primary-foreground border-transparent hover:bg-primary/90"
                      )}
                      disabled={e.clearanceStatus === "Completed"}
                    >
                      {e.clearanceStatus === "Completed" ? "Archived" : "Clear Actions"}
                    </button>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-4 py-12 text-center text-sm text-muted-foreground">
                    No offboarding logs found matching your filter options.
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
