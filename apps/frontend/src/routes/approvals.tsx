import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { Check, X, Clock, AlertCircle } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { timesheets as initialTs, getPerson, projects, type Timesheet } from "@/lib/mock-data";
import { TimesheetStatusPill, Avatar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/approvals")({
  head: () => ({
    meta: [
      { title: "Approvals — Pulse PMO" },
      { name: "description", content: "Review and approve PM weekly timesheets." },
    ],
  }),
  component: ApprovalsPage,
});

const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

function ApprovalsPage() {
  const [ts, setTs] = useState<Timesheet[]>(initialTs);
  const [tab, setTab] = useState<"pending" | "all">("pending");
  const [rejectOpen, setRejectOpen] = useState(false);
  const [reason, setReason] = useState("");
  const { isPMO, isHOD } = useRoleContext();

  const inScope = (t: Timesheet) => {
    if (isPMO) return true;
    if (isHOD) return t.userRole === "Senior PM" || t.userRole === "EM";
    return t.userRole === "PM";
  };

  const visible = ts.filter((t) => {
    if (!inScope(t)) return false;
    return tab === "all" || t.status === "submitted";
  });
  const pendingCount = ts.filter((t) => inScope(t) && t.status === "submitted").length;
  const [selectedId, setSelectedId] = useState<string | null>(
    ts.find((t) => inScope(t) && t.status === "submitted")?.id ?? null,
  );
  const selected = ts.find((t) => t.id === selectedId);

  function approve() {
    if (!selected) return;
    setTs((prev) => prev.map((t) => t.id === selected.id ? { ...t, status: "approved" } : t));
  }
  function reject() {
    if (!selected || !reason.trim()) return;
    setTs((prev) => prev.map((t) => t.id === selected.id ? { ...t, status: "rejected", rejectionReason: reason.trim() } : t));
    setReason("");
    setRejectOpen(false);
  }

  const subtitle = isPMO
    ? "Monitoring view · timesheet flow across the company"
    : isHOD
      ? "Review weekly Senior PM and Engagement Manager timesheets"
      : "Review weekly PM timesheets";

  return (
    <AppShell title="Approvals" subtitle={subtitle}>
      {isPMO && (
        <div className="mb-3 rounded-lg border border-info/30 bg-info/10 px-3 py-2 text-xs text-info">
          PMO monitoring only — you can review the entire timesheet approval flow but cannot approve or reject directly.
        </div>
      )}
      {isHOD && (
        <div className="mb-3 rounded-lg border border-info/30 bg-info/10 px-3 py-2 text-xs text-info">
          HOD approval queue — Senior PM and Engagement Manager weekly timesheets.
        </div>
      )}
      <div className="mb-4 inline-flex rounded-lg border border-border bg-card p-1 text-xs">
        {(["pending", "all"] as const).map((t) => (
          <button
            key={t}
            onClick={() => setTab(t)}
            className={cn(
              "rounded-md px-3 py-1.5 capitalize",
              tab === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
            )}
          >
            {t === "pending" ? `Pending (${pendingCount})` : "All"}
          </button>
        ))}
      </div>

      <div className="grid gap-4 lg:grid-cols-[340px,1fr]">
        <aside className="rounded-xl border border-border bg-card shadow-sm">
          <ul className="max-h-[70vh] divide-y divide-border overflow-y-auto">
            {visible.map((t) => {
              const u = getPerson(t.userId);
              return (
                <li key={t.id}>
                  <button
                    onClick={() => setSelectedId(t.id)}
                    className={cn(
                      "flex w-full items-center gap-3 px-4 py-3 text-left",
                      selectedId === t.id ? "bg-accent/60" : "hover:bg-accent/40",
                    )}
                  >
                    <Avatar name={u.name} size={36} />
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-medium">{u.name}</span>
                        <TimesheetStatusPill status={t.status} />
                      </div>
                      <div className="mt-0.5 flex items-center gap-2 text-xs text-muted-foreground">
                        <Clock className="h-3 w-3" /> Week of {t.weekStart} · {t.totalHours}h
                      </div>
                    </div>
                  </button>
                </li>
              );
            })}
            {visible.length === 0 && (
              <li className="px-4 py-10 text-center text-sm text-muted-foreground">Nothing here</li>
            )}
          </ul>
        </aside>

        <section className="rounded-xl border border-border bg-card shadow-sm">
          {selected ? (
            <TimesheetReview
              ts={selected}
              onApprove={approve}
              onRejectClick={() => setRejectOpen(true)}
              monitoringOnly={isPMO}
            />
          ) : (
            <div className="flex h-64 items-center justify-center text-sm text-muted-foreground">Select a timesheet</div>
          )}
        </section>
      </div>

      {rejectOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-foreground/40 p-4">
          <div className="w-full max-w-md rounded-xl border border-border bg-card shadow-lg">
            <header className="flex items-center gap-2 border-b border-border px-5 py-3">
              <AlertCircle className="h-4 w-4 text-destructive" />
              <h3 className="text-base font-semibold">Reject timesheet</h3>
            </header>
            <div className="p-5">
              <label className="block text-xs font-medium text-muted-foreground">Reason (required)</label>
              <textarea
                value={reason} onChange={(e) => setReason(e.target.value)} rows={3}
                placeholder="Explain why so the PM can resubmit…"
                className="form-input mt-1 resize-none"
              />
              <p className="mt-2 text-xs text-muted-foreground">PM will be notified to resubmit.</p>
            </div>
            <footer className="flex items-center justify-end gap-2 border-t border-border bg-muted/30 px-5 py-3">
              <button onClick={() => setRejectOpen(false)} className="rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent">Cancel</button>
              <button
                onClick={reject}
                disabled={!reason.trim()}
                className="rounded-md bg-destructive px-3 py-1.5 text-sm font-medium text-destructive-foreground hover:bg-destructive/90 disabled:opacity-50"
              >
                Reject
              </button>
            </footer>
          </div>
        </div>
      )}
    </AppShell>
  );
}

function TimesheetReview({ ts, onApprove, onRejectClick, monitoringOnly = false }: { ts: Timesheet; onApprove: () => void; onRejectClick: () => void; monitoringOnly?: boolean }) {
  const u = getPerson(ts.userId);
  const dayTotals = days.map((_, di) => ts.entries.reduce((sum, e) => sum + (e.hours[di] ?? 0), 0));
  return (
    <div>
      <header className="flex flex-wrap items-center gap-3 border-b border-border p-5">
        <Avatar name={u.name} size={40} />
        <div>
          <div className="font-semibold">{u.name} <span className="text-xs font-normal text-muted-foreground">· {u.role}</span></div>
          <div className="text-xs text-muted-foreground">Week of {ts.weekStart} · {ts.totalHours}h total</div>
        </div>
        <div className="ml-auto flex items-center gap-2">
          <TimesheetStatusPill status={ts.status} />
          {ts.status === "submitted" && !monitoringOnly && (
            <>
              <button onClick={onRejectClick} className="inline-flex items-center gap-1 rounded-md border border-destructive/40 bg-destructive/10 px-3 py-1.5 text-xs font-medium text-destructive hover:bg-destructive/15">
                <X className="h-3.5 w-3.5" /> Reject
              </button>
              <button onClick={onApprove} className="inline-flex items-center gap-1 rounded-md bg-success px-3 py-1.5 text-xs font-medium text-success-foreground hover:bg-success/90">
                <Check className="h-3.5 w-3.5" /> Approve
              </button>
            </>
          )}
          {monitoringOnly && (
            <span className="rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] text-muted-foreground">Monitoring only</span>
          )}
        </div>
      </header>

      {ts.rejectionReason && (
        <div className="mx-5 mt-4 rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm text-destructive">
          <strong className="font-semibold">Rejection reason:</strong> {ts.rejectionReason}
        </div>
      )}

      <div className="overflow-x-auto p-5">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-xs uppercase tracking-wide text-muted-foreground">
              <th className="pb-2 font-medium">Project · Task</th>
              {days.map((d) => <th key={d} className="px-2 pb-2 text-center font-medium">{d}</th>)}
              <th className="pb-2 text-right font-medium">Total</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {ts.entries.map((e, i) => {
              const p = projects.find((p) => p.id === e.projectId);
              const task = p?.tasks.find((t) => t.id === e.taskId);
              const total = e.hours.reduce((a, b) => a + b, 0);
              return (
                <tr key={i}>
                  <td className="py-2.5">
                    <div className="font-medium">{p?.name}</div>
                    <div className="text-xs text-muted-foreground">{task?.title}</div>
                  </td>
                  {e.hours.map((h, di) => (
                    <td key={di} className="px-2 py-2.5 text-center tabular-nums">
                      {h > 0 ? <span className="rounded-md bg-accent/60 px-2 py-0.5 text-xs">{h}</span> : <span className="text-muted-foreground">—</span>}
                    </td>
                  ))}
                  <td className="py-2.5 text-right font-semibold tabular-nums">{total}</td>
                </tr>
              );
            })}
          </tbody>
          <tfoot>
            <tr className="border-t border-border bg-muted/30 text-xs font-semibold">
              <td className="py-2">Daily total</td>
              {dayTotals.map((d, i) => <td key={i} className="px-2 py-2 text-center tabular-nums">{d}</td>)}
              <td className="py-2 text-right tabular-nums">{ts.totalHours}</td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  );
}
