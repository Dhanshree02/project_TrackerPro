import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Plus, Send, Trash2, Clock } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { people, projects, timesheets } from "@/lib/mock-data";
import { TimesheetStatusPill } from "@/components/pills";
import { cn } from "@/lib/utils";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { HourField } from "@/components/hour-field";
import { isTimesheetDayOpen } from "@/lib/timesheet-window";

export const Route = createFileRoute("/timesheet")({
  head: () => ({
    meta: [
      { title: "My Timesheet — Pulse PMO" },
      { name: "description", content: "Log your weekly hours across projects." },
    ],
  }),
  component: TimesheetPage,
});

const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

interface Row {
  id: string;
  projectId: string;
  taskId: string;
  hours: number[];
  note?: string;
}

function thisMonday() {
  const d = new Date();
  const day = d.getDay() || 7;
  d.setDate(d.getDate() - (day - 1));
  return d.toISOString().slice(0, 10);
}

function TimesheetPage() {
  const { user, employeePersonId } = useRoleContext();
  const { status: authStatus } = useAuth();
  const { hasPermission } = usePermissions();
  const [tab, setTab] = useState<"current" | "history">("current");
  const [weekStart] = useState(thisMonday());
  const [status, setStatus] = useState<"draft" | "submitted">("draft");
  const [rows, setRows] = useState<Row[]>([
    {
      id: "r1",
      projectId: "",
      taskId: "",
      hours: [0, 0, 0, 0, 0, 0, 0],
    },
  ]);

  const tasksByProject = useMemo(() => {
    const map: Record<string, (typeof projects)[number]["tasks"]> = {};
    projects.forEach((p) => {
      map[p.id] = p.tasks;
    });
    return map;
  }, []);

  const history = useMemo(() => {
    const byEmail = people.find(
      (p) => p.email.toLowerCase() === (user.email ?? "").toLowerCase(),
    )?.id;
    const matchId = employeePersonId ?? byEmail ?? user.id;
    return timesheets
      .filter((t) => t.userId === matchId)
      .sort((a, b) => b.weekStart.localeCompare(a.weekStart));
  }, [employeePersonId, user.email, user.id]);

  // Wait for the session to restore before evaluating permissions — otherwise
  // a direct URL load (browser refresh) would see an empty permission set while
  // auth is still initialising and wrongly bounce the user to the 403 page.
  if (authStatus === "loading") return null;
  if (!hasPermission("my-team.my-timesheet.view")) return <Navigate to="/access-denied" />;

  const dayTotals = days.map((_, di) => rows.reduce((s, r) => s + (Number(r.hours[di]) || 0), 0));
  const total = dayTotals.reduce((a, b) => a + b, 0);

  function update(id: string, patch: Partial<Row>) {
    setRows((prev) => prev.map((r) => (r.id === id ? { ...r, ...patch } : r)));
  }
  function setHour(id: string, di: number, v: string) {
    const n = Math.max(0, Math.min(24, Number(v) || 0));
    setRows((prev) =>
      prev.map((r) =>
        r.id === id ? { ...r, hours: r.hours.map((h, i) => (i === di ? n : h)) } : r,
      ),
    );
  }
  function addRow() {
    setRows((r) => [
      ...r,
      {
        id: `r${Date.now()}`,
        projectId: "",
        taskId: "",
        hours: [0, 0, 0, 0, 0, 0, 0],
      },
    ]);
  }
  function remove(id: string) {
    setRows((r) => r.filter((x) => x.id !== id));
  }

  return (
    <AppShell title="My Timesheet" subtitle={`${user.name} · Week of ${weekStart}`}>
      <div className="mb-4 flex gap-1 rounded-lg border border-border bg-card p-1 text-sm w-fit">
        <button
          onClick={() => setTab("current")}
          className={cn(
            "rounded-md px-3 py-1.5 font-medium transition-colors",
            tab === "current"
              ? "bg-primary text-primary-foreground"
              : "text-muted-foreground hover:text-foreground",
          )}
        >
          My Timesheet
        </button>
        <button
          onClick={() => setTab("history")}
          className={cn(
            "rounded-md px-3 py-1.5 font-medium transition-colors",
            tab === "history"
              ? "bg-primary text-primary-foreground"
              : "text-muted-foreground hover:text-foreground",
          )}
        >
          Timesheet History
        </button>
      </div>

      {tab === "history" ? (
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium">Week of</th>
                <th className="px-3 py-2 font-medium">Projects</th>
                <th className="px-3 py-2 font-medium">Hours</th>
                <th className="px-3 py-2 font-medium">Submitted</th>
                <th className="px-3 py-2 font-medium">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {history.map((ts) => {
                const projectNames = [
                  ...new Set(
                    ts.entries.map(
                      (e) => projects.find((p) => p.id === e.projectId)?.name ?? e.projectId,
                    ),
                  ),
                ];
                return (
                  <tr key={ts.id} className="hover:bg-accent/30">
                    <td className="px-3 py-2.5 font-medium">{ts.weekStart}</td>
                    <td className="px-3 py-2.5 text-muted-foreground">{projectNames.join(", ")}</td>
                    <td className="px-3 py-2.5 tabular-nums">{ts.totalHours}h</td>
                    <td className="px-3 py-2.5 text-xs text-muted-foreground">
                      {ts.submittedAt ? new Date(ts.submittedAt).toLocaleDateString() : "—"}
                    </td>
                    <td className="px-3 py-2.5">
                      <TimesheetStatusPill status={ts.status} />
                      {ts.rejectionReason && (
                        <p className="mt-1 text-[11px] text-destructive">{ts.rejectionReason}</p>
                      )}
                    </td>
                  </tr>
                );
              })}
              {history.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-3 py-10 text-center text-sm text-muted-foreground">
                    No timesheet history yet
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      ) : (
        <>
          <div className="mb-4 flex flex-wrap items-center gap-3 rounded-xl border border-border bg-card p-4 shadow-sm">
            <Clock className="h-4 w-4 text-muted-foreground" />
            <div>
              <div className="text-sm font-medium">Week of {weekStart}</div>
              <div className="text-xs text-muted-foreground">
                Log hours per project · save as draft or submit for approval
              </div>
            </div>
            <TimesheetStatusPill status={status} />
            <div className="ml-auto flex items-center gap-2">
              <span className="text-xs text-muted-foreground">Total</span>
              <span className="text-lg font-semibold tabular-nums">{total}h</span>
              <button
                onClick={() => setStatus("draft")}
                className="rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent"
              >
                Save draft
              </button>
              <button
                onClick={() => setStatus("submitted")}
                disabled={total === 0}
                className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
              >
                <Send className="h-3.5 w-3.5" /> Submit
              </button>
            </div>
          </div>

          <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
            <table className="w-full text-sm">
              <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
                <tr>
                  <th className="px-3 py-2 font-medium min-w-[280px]">Project · Task</th>
                  {days.map((d, di) => (
                    <th
                      key={d}
                      className={cn(
                        "px-2 py-2 text-center font-medium",
                        !isTimesheetDayOpen(weekStart, di) && "text-muted-foreground/40",
                      )}
                    >
                      {d}
                    </th>
                  ))}
                  <th className="px-3 py-2 text-center font-medium">Total</th>
                  <th className="px-2 py-2"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {rows.map((r) => {
                  const tasks = tasksByProject[r.projectId] ?? [];
                  const rowTotal = r.hours.reduce((a, b) => a + b, 0);
                  return (
                    <tr key={r.id}>
                      <td className="px-3 py-2 align-top">
                        <div className="flex flex-col gap-1.5">
                          <SearchableSelect
                            options={projects.map((p) => ({ value: p.id, label: p.name }))}
                            value={r.projectId}
                            onChange={(projectId) =>
                              update(r.id, {
                                projectId,
                                taskId: "",
                              })
                            }
                            placeholder="Select project"
                            searchPlaceholder="Search projects…"
                            clearable={false}
                          />
                          <SearchableSelect
                            options={tasks.map((t) => ({ value: t.id, label: t.title }))}
                            value={r.taskId}
                            onChange={(taskId) => update(r.id, { taskId })}
                            placeholder="Select task"
                            searchPlaceholder="Search tasks…"
                            clearable={false}
                          />
                        </div>
                      </td>
                      {r.hours.map((h, di) => (
                        <td key={di} className="px-2 py-2 text-center align-top">
                          <HourField
                            value={h}
                            label={`${days[di]} hours`}
                            disabled={!isTimesheetDayOpen(weekStart, di)}
                            onChange={(hours) => setHour(r.id, di, String(hours))}
                          />
                        </td>
                      ))}
                      <td className="px-3 py-2 text-center align-middle">
                        <span className="text-lg font-semibold tabular-nums leading-none">{rowTotal}</span>
                      </td>
                      <td className="px-2 py-2 text-center align-middle">
                        <button
                          onClick={() => remove(r.id)}
                          className="inline-flex rounded-md p-1.5 text-muted-foreground hover:bg-accent hover:text-destructive"
                          aria-label="Remove"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
              <tfoot>
                <tr className="border-t border-border bg-muted/30 text-xs font-semibold">
                  <td className="px-3 py-2">Daily total</td>
                  {dayTotals.map((d, i) => (
                    <td key={i} className="px-2 py-2 text-center tabular-nums">
                      {d}
                    </td>
                  ))}
                  <td className="px-3 py-2 text-center text-base tabular-nums">{total}</td>
                  <td />
                </tr>
              </tfoot>
            </table>
          </div>

          <div className="mt-3">
            <button
              onClick={addRow}
              className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent"
            >
              <Plus className="h-3.5 w-3.5" /> Add row
            </button>
          </div>
        </>
      )}
    </AppShell>
  );
}
