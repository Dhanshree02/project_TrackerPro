import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Plus, Send, Trash2, Clock } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { projects } from "@/lib/mock-data";
import { TimesheetStatusPill } from "@/components/pills";

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

interface Row { id: string; projectId: string; taskId: string; hours: number[]; note?: string }

function thisMonday() {
  const d = new Date();
  const day = d.getDay() || 7;
  d.setDate(d.getDate() - (day - 1));
  return d.toISOString().slice(0, 10);
}

function TimesheetPage() {
  const { isPMO, user } = useRoleContext();
  const [weekStart] = useState(thisMonday());
  const [status, setStatus] = useState<"draft" | "submitted">("draft");
  const [rows, setRows] = useState<Row[]>([
    { id: "r1", projectId: projects[0].id, taskId: projects[0].tasks[0].id, hours: [0, 0, 0, 0, 0, 0, 0] },
  ]);

  if (!isPMO) return <Navigate to="/" />;

  const dayTotals = days.map((_, di) => rows.reduce((s, r) => s + (Number(r.hours[di]) || 0), 0));
  const total = dayTotals.reduce((a, b) => a + b, 0);

  function update(id: string, patch: Partial<Row>) {
    setRows((prev) => prev.map((r) => r.id === id ? { ...r, ...patch } : r));
  }
  function setHour(id: string, di: number, v: string) {
    const n = Math.max(0, Math.min(24, Number(v) || 0));
    setRows((prev) => prev.map((r) => r.id === id ? { ...r, hours: r.hours.map((h, i) => i === di ? n : h) } : r));
  }
  function addRow() {
    const p = projects[0];
    setRows((r) => [...r, { id: `r${Date.now()}`, projectId: p.id, taskId: p.tasks[0].id, hours: [0, 0, 0, 0, 0, 0, 0] }]);
  }
  function remove(id: string) { setRows((r) => r.filter((x) => x.id !== id)); }

  const tasksByProject = useMemo(() => {
    const map: Record<string, typeof projects[number]["tasks"]> = {};
    projects.forEach((p) => { map[p.id] = p.tasks; });
    return map;
  }, []);

  return (
    <AppShell title="My Timesheet" subtitle={`${user.name} · Week of ${weekStart}`}>
      <div className="mb-4 flex flex-wrap items-center gap-3 rounded-xl border border-border bg-card p-4 shadow-sm">
        <Clock className="h-4 w-4 text-muted-foreground" />
        <div>
          <div className="text-sm font-medium">Week of {weekStart}</div>
          <div className="text-xs text-muted-foreground">Log hours per project · save as draft or submit for approval</div>
        </div>
        <TimesheetStatusPill status={status} />
        <div className="ml-auto flex items-center gap-2">
          <span className="text-xs text-muted-foreground">Total</span>
          <span className="text-lg font-semibold tabular-nums">{total}h</span>
          <button
            onClick={() => setStatus("draft")}
            className="rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent"
          >Save draft</button>
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
              {days.map((d) => <th key={d} className="px-2 py-2 text-center font-medium">{d}</th>)}
              <th className="px-3 py-2 text-right font-medium">Total</th>
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
                    <select
                      value={r.projectId}
                      onChange={(e) => update(r.id, { projectId: e.target.value, taskId: tasksByProject[e.target.value]?.[0]?.id ?? "" })}
                      className="form-input mb-1 w-full"
                    >
                      {projects.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
                    </select>
                    <select value={r.taskId} onChange={(e) => update(r.id, { taskId: e.target.value })} className="form-input w-full">
                      {tasks.map((t) => <option key={t.id} value={t.id}>{t.title}</option>)}
                    </select>
                  </td>
                  {r.hours.map((h, di) => (
                    <td key={di} className="px-2 py-2 text-center align-top">
                      <input
                        type="number" min={0} max={24} step={0.5}
                        value={h}
                        onChange={(e) => setHour(r.id, di, e.target.value)}
                        className="form-input h-9 w-14 text-center tabular-nums"
                      />
                    </td>
                  ))}
                  <td className="px-3 py-2 text-right align-top font-semibold tabular-nums">{rowTotal}</td>
                  <td className="px-2 py-2 align-top">
                    <button onClick={() => remove(r.id)} className="rounded-md p-1.5 text-muted-foreground hover:bg-accent hover:text-destructive" aria-label="Remove">
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
              {dayTotals.map((d, i) => <td key={i} className="px-2 py-2 text-center tabular-nums">{d}</td>)}
              <td className="px-3 py-2 text-right tabular-nums">{total}</td>
              <td />
            </tr>
          </tfoot>
        </table>
      </div>

      <div className="mt-3">
        <button onClick={addRow} className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent">
          <Plus className="h-3.5 w-3.5" /> Add row
        </button>
      </div>
    </AppShell>
  );
}
