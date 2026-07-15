import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import {
  Clock, Send, Trash2, MessageSquare, Copy, X, CheckCircle2,
  XCircle, RotateCcw, AlertCircle, Plus,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { getPerson, type CellCommentData, type CellCommentMessage } from "@/lib/mock-data";
import { TaskStatusPill, TimesheetStatusPill, Avatar } from "@/components/pills";
import { useDhStore, dhStore, allProjects } from "@/lib/dh-store";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { Modal } from "./projects.index";

export const Route = createFileRoute("/my-team/timesheets" as any)({
  head: () => ({
    meta: [
      { title: "Timesheets — Pulse PMO" },
      { name: "description", content: "My Team timesheet management." },
    ],
  }),
  component: TimesheetsRoute,
});

function TimesheetsRoute() {
  const { isDhanshree } = useRoleContext();
  if (!isDhanshree) return <Navigate to="/" />;
  return (
    <AppShell title="Timesheets" subtitle="My Team · timesheets and approvals">
      <TimesheetTab />
    </AppShell>
  );
}

// ── Shared helpers ───────────────────────────────────────────────────────────
const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
interface TsRow { id: string; projectId: string; taskId: string; hours: number[]; notes: string[] }

function thisMonday() {
  const d = new Date();
  const day = d.getDay() || 7;
  d.setDate(d.getDate() - (day - 1));
  return d.toISOString().slice(0, 10);
}

// ── TimesheetTab ─────────────────────────────────────────────────────────────
function TimesheetTab() {
  const [subTab, setSubTab] = useState<"My Timesheet" | "Timesheet Approval">("My Timesheet");
  return (
    <div>
      <div className="mb-4 flex gap-1 border-b border-border pb-1">
        {(["My Timesheet", "Timesheet Approval"] as const).map((st) => (
          <button key={st} onClick={() => setSubTab(st)}
            className={cn("border-b-2 px-4 py-2 text-sm font-medium transition-colors -mb-[6px]",
              subTab === st ? "border-primary text-foreground" : "border-transparent text-muted-foreground hover:text-foreground")}>
            {st}
          </button>
        ))}
      </div>
      {subTab === "My Timesheet" ? <MyTimesheetView /> : <TimesheetApprovalView />}
    </div>
  );
}

// ── MyTimesheetView ──────────────────────────────────────────────────────────
function MyTimesheetView() {
  const { user } = useRoleContext();
  const store = useDhStore((s) => s);
  const [weekStart, setWeekStart] = useState(thisMonday());
  const projectsList = allProjects();

  const storeTs = useMemo(() => {
    return store.timesheets.find(t => t.userId === user.id && t.weekStart === weekStart);
  }, [store.timesheets, user.id, weekStart]);

  const [rows, setRows] = useState<TsRow[]>(() => {
    if (storeTs) {
      return storeTs.entries.map((e, idx) => ({
        id: `r-${idx}`, projectId: e.projectId, taskId: e.taskId,
        hours: [...e.hours],
        notes: e.notes ? [...e.notes] : (e.note ? days.map((_, i) => i === 0 ? e.note || "" : "") : ["", "", "", "", "", "", ""]),
      }));
    }
    return [{ id: "r1", projectId: projectsList[0]?.id || "", taskId: projectsList[0]?.tasks[0]?.id || "", hours: [0,0,0,0,0,0,0], notes: ["","","","","","",""] }];
  });

  const [commentOpen, setCommentOpen] = useState<{ row: string; day: number } | null>(null);

  const tasksByProject = useMemo(() => {
    const map: Record<string, typeof projectsList[number]["tasks"]> = {};
    projectsList.forEach((p) => { map[p.id] = p.tasks; });
    return map;
  }, [projectsList]);

  const dayTotals = days.map((_, di) => rows.reduce((s, r) => s + (Number(r.hours[di]) || 0), 0));
  const total = dayTotals.reduce((a, b) => a + b, 0);

  function update(id: string, patch: Partial<TsRow>) { setRows((prev) => prev.map((r) => r.id === id ? { ...r, ...patch } : r)); }
  function setHour(id: string, di: number, v: string) {
    const n = Math.max(0, Math.min(24, Number(v) || 0));
    setRows((prev) => prev.map((r) => r.id === id ? { ...r, hours: r.hours.map((h, i) => i === di ? n : h) } : r));
  }
  function setNote(id: string, di: number, v: string) {
    setRows((prev) => prev.map((r) => r.id === id ? { ...r, notes: r.notes.map((h, i) => i === di ? v : h) } : r));
  }
  function addRow() {
    const p = projectsList[0]; if (!p) return;
    setRows((r) => [...r, { id: `r${Date.now()}`, projectId: p.id, taskId: p.tasks[0]?.id || "", hours: [0,0,0,0,0,0,0], notes: ["","","","","","",""] }]);
  }
  function remove(id: string) { setRows((r) => r.filter((x) => x.id !== id)); }
  function copyLast() { setRows((prev) => prev.map((r) => ({ ...r, hours: [8,8,8,8,8,0,0] }))); }
  function shiftWeek(d: number) {
    const dt = new Date(weekStart); dt.setDate(dt.getDate() + d);
    setWeekStart(dt.toISOString().slice(0, 10));
  }
  function handleSubmit() {
    const entries = rows.map((r) => {
      const cellComments: Record<number, CellCommentData> = {};
      r.notes.forEach((n, idx) => {
        if (n.trim()) cellComments[idx] = { status: "new", history: [{ author: user.name, text: n, type: "comment", createdAt: new Date().toISOString() }] };
      });
      return { projectId: r.projectId, taskId: r.taskId, hours: r.hours, note: r.notes.filter(Boolean).join(" | ") || undefined, notes: r.notes, cellComments: Object.keys(cellComments).length > 0 ? cellComments : undefined };
    });
    dhStore.submitMyTimesheet(user.id, "Employee", weekStart, entries as any, total);
    toast.success("Timesheet submitted for approval!");
  }

  const activeRow = commentOpen ? rows.find((r) => r.id === commentOpen.row) : null;
  const currentStatus = storeTs?.status || "draft";

  return (
    <>
      {storeTs && storeTs.comments.length > 0 && (
        <div className={cn("mb-4 rounded-lg border p-4 text-sm",
          storeTs.status === "rejected" ? "bg-red-50 border-red-200 text-red-800" :
          storeTs.status === "approved" ? "bg-green-50 border-green-200 text-green-800" :
          "bg-blue-50 border-blue-200 text-blue-800")}>
          <div className="flex items-center gap-2 font-semibold mb-2"><AlertCircle className="h-4 w-4" /> Approver History & Comments</div>
          <div className="space-y-1.5 pl-6 text-xs max-h-32 overflow-y-auto">
            {storeTs.history.map((h, i) => (
              <p key={i}><strong>{h.updatedBy}</strong> changed status to <span className="underline font-semibold">{h.status}</span> on {new Date(h.at).toLocaleString()}: <em>"{h.comment}"</em></p>
            ))}
          </div>
        </div>
      )}
      <div className="mb-4 flex flex-wrap items-center gap-3 rounded-xl border border-border bg-card p-4 shadow-sm">
        <Clock className="h-4 w-4 text-muted-foreground" />
        <div>
          <div className="text-sm font-medium">{user.name} · Week of {weekStart}</div>
          <div className="text-xs text-muted-foreground">Log hours per project · save as draft or submit for approval</div>
        </div>
        <TimesheetStatusPill status={currentStatus} />
        <div className="ml-auto flex items-center gap-2 flex-wrap">
          <button onClick={() => shiftWeek(-7)} className="rounded-md border border-input bg-card px-2 py-1 text-xs hover:bg-accent">‹</button>
          <button onClick={() => shiftWeek(7)} className="rounded-md border border-input bg-card px-2 py-1 text-xs hover:bg-accent">›</button>
          <button onClick={copyLast} className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent"><Copy className="h-3.5 w-3.5" /> Copy Last Week</button>
          <span className="text-xs text-muted-foreground">Total</span>
          <span className="text-lg font-semibold tabular-nums">{total}h</span>
          <button onClick={() => toast.success("Timesheet saved as draft!")} className="rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent">Save draft</button>
          <button onClick={handleSubmit} disabled={total === 0 || currentStatus === "approved"}
            className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50">
            <Send className="h-3.5 w-3.5" /> Submit
          </button>
        </div>
      </div>
      <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium min-w-[260px]">Project</th>
              <th className="px-3 py-2 font-medium min-w-[200px]">Task</th>
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
                    <select value={r.projectId} onChange={(e) => update(r.id, { projectId: e.target.value, taskId: tasksByProject[e.target.value]?.[0]?.id ?? "" })}
                      className="form-input w-full bg-card rounded-md border border-border py-1 px-2 text-xs">
                      {projectsList.map((p) => <option key={p.id} value={p.id}>{p.name}</option>)}
                    </select>
                  </td>
                  <td className="px-3 py-2 align-top">
                    <select value={r.taskId} onChange={(e) => update(r.id, { taskId: e.target.value })} className="form-input w-full bg-card rounded-md border border-border py-1 px-2 text-xs">
                      {tasks.map((t) => <option key={t.id} value={t.id}>{t.title}</option>)}
                    </select>
                  </td>
                  {r.hours.map((h, di) => (
                    <td key={di} className="px-2 py-2 text-center align-top">
                      <div className="flex flex-col items-center gap-1">
                        <input type="number" min={0} max={24} step={0.5} value={h} onChange={(e) => setHour(r.id, di, e.target.value)}
                          className="form-input h-8 w-12 text-center tabular-nums border border-border rounded-md text-xs bg-card" />
                        <button onClick={() => setCommentOpen({ row: r.id, day: di })}
                          className={cn("inline-flex h-5 w-5 items-center justify-center rounded-md hover:bg-accent", r.notes[di] ? "text-primary" : "text-muted-foreground")} aria-label="Day comment">
                          <MessageSquare className="h-3 w-3" />
                        </button>
                      </div>
                    </td>
                  ))}
                  <td className="px-3 py-2 text-right align-top font-semibold tabular-nums">{rowTotal}</td>
                  <td className="px-2 py-2 align-top">
                    <button onClick={() => remove(r.id)} className="rounded-md p-1.5 text-muted-foreground hover:bg-accent hover:text-destructive" aria-label="Remove"><Trash2 className="h-4 w-4" /></button>
                  </td>
                </tr>
              );
            })}
          </tbody>
          <tfoot>
            <tr className="border-t border-border bg-muted/30 text-xs font-semibold">
              <td className="px-3 py-2" colSpan={2}>Daily total</td>
              {dayTotals.map((d, i) => <td key={i} className="px-2 py-2 text-center tabular-nums">{d}</td>)}
              <td className="px-3 py-2 text-right tabular-nums">{total}</td><td />
            </tr>
          </tfoot>
        </table>
      </div>
      <div className="mt-3">
        <button onClick={addRow} className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent"><Plus className="h-3.5 w-3.5" /> Add row</button>
      </div>
      {commentOpen && activeRow && (
        <div className="fixed inset-0 z-40 flex items-end justify-end bg-black/30 sm:items-center sm:justify-center" onClick={() => setCommentOpen(null)}>
          <div className="w-full max-w-md rounded-t-2xl border border-border bg-card p-4 shadow-xl sm:rounded-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between">
              <div><h3 className="text-sm font-semibold">Day note · {days[commentOpen.day]}</h3>
                <p className="text-xs text-muted-foreground">{projectsList.find((p) => p.id === activeRow.projectId)?.name}</p></div>
              <button onClick={() => setCommentOpen(null)} className="rounded-md p-1 hover:bg-accent" aria-label="Close"><X className="h-4 w-4" /></button>
            </div>
            <textarea value={activeRow.notes[commentOpen.day]} onChange={(e) => setNote(activeRow.id, commentOpen.day, e.target.value)}
              placeholder="Add a note for this day · visible to your approver" rows={5}
              className="mt-3 w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring" />
            <div className="mt-3 flex justify-end gap-2">
              <button onClick={() => setCommentOpen(null)} className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent">Cancel</button>
              <button onClick={() => setCommentOpen(null)} className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90">Save note</button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

// ── TimesheetApprovalView ────────────────────────────────────────────────────
function TimesheetApprovalView() {
  const store = useDhStore((s) => s);
  const [selectedTsId, setSelectedTsId] = useState<string | null>(null);
  const [actionComment, setActionComment] = useState("");
  const { user } = useRoleContext();

  const selectedTs = useMemo(() => store.timesheets.find(t => t.id === selectedTsId), [store.timesheets, selectedTsId]);
  const [activeCell, setActiveCell] = useState<{ entryIndex: number; dayIndex: number } | null>(null);
  const [cellReplyText, setCellReplyText] = useState("");

  const getCellCommentData = (entry: any, dayIdx: number) => {
    if (entry.cellComments?.[dayIdx]) return entry.cellComments[dayIdx];
    const legacyNote = entry.notes?.[dayIdx] || (dayIdx === 0 ? entry.note : undefined);
    if (legacyNote?.trim()) return { status: "new" as const, history: [{ author: getPerson(selectedTs?.userId || "")?.name || "Employee", text: legacyNote, type: "comment" as const, createdAt: selectedTs?.submittedAt || new Date().toISOString() }] };
    return null;
  };

  const commentedEntriesCount = useMemo(() => {
    if (!selectedTs) return 0;
    return selectedTs.entries.reduce((acc, entry) => {
      return acc + days.filter((_, idx) => { const d = getCellCommentData(entry, idx); return d && d.history.length > 0; }).length;
    }, 0);
  }, [selectedTs]);

  const handleAction = (status: "approved" | "rejected" | "submitted", commentStr: string, isChangeRequest?: boolean) => {
    if (!selectedTsId) return;
    if (!commentStr.trim()) { toast.error("A comment is mandatory for all timesheet approval actions!"); return; }
    // Store takes 5 args; encode change-request intent in the comment prefix
    const finalComment = isChangeRequest ? `[Change Requested] ${commentStr}` : commentStr;
    dhStore.updateTimesheetStatus(selectedTsId, status, finalComment, user.name, user.id);
    toast.success(`Timesheet marked as ${isChangeRequest ? "Change Requested" : status} persistently!`);
    setActionComment(""); setSelectedTsId(null);
  };

  return (
    <section className="rounded-xl border border-border bg-card shadow-sm">
      <header className="border-b border-border p-3"><h3 className="text-sm font-semibold">Submitted Timesheets for Review</h3></header>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium">Employee Name</th>
              <th className="px-3 py-2 font-medium">Employee ID</th>
              <th className="px-3 py-2 font-medium">Project Name</th>
              <th className="px-3 py-2 font-medium">Week Range</th>
              <th className="px-3 py-2 font-medium">Submitted Date</th>
              <th className="px-3 py-2 font-medium">Total Hours</th>
              <th className="px-3 py-2 font-medium">Current Status</th>
              <th className="px-3 py-2 font-medium text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {store.timesheets.map((t) => {
              const u = getPerson(t.userId);
              const linkedProjects = Array.from(new Set(t.entries.map(e => allProjects().find(p => p.id === e.projectId)?.name).filter(Boolean))).join(", ");
              return (
                <tr key={t.id} className="hover:bg-accent/30">
                  <td className="px-3 py-2.5"><div className="flex items-center gap-2"><Avatar name={u?.name || "Employee"} size={24} /><span className="font-medium">{u?.name || "Employee"}</span></div></td>
                  <td className="px-3 py-2.5 text-xs text-muted-foreground font-mono">EMP-{u?.id || "000"}</td>
                  <td className="px-3 py-2.5 text-xs font-medium text-gray-700 truncate max-w-xs">{linkedProjects || "—"}</td>
                  <td className="px-3 py-2.5 text-xs tabular-nums">{t.weekStart}</td>
                  <td className="px-3 py-2.5 text-xs text-muted-foreground">{t.submittedAt ? new Date(t.submittedAt).toLocaleDateString() : "—"}</td>
                  <td className="px-3 py-2.5 tabular-nums font-medium">{t.totalHours}h</td>
                  <td className="px-3 py-2.5"><TimesheetStatusPill status={t.status} /></td>
                  <td className="px-3 py-2.5 text-right">
                    <button onClick={() => setSelectedTsId(t.id)} className="rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent font-medium text-primary">Review & Approve</button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {selectedTs && (
        <Modal title={`Review Timesheet — ${getPerson(selectedTs.userId)?.name}`} onClose={() => setSelectedTsId(null)} wide>
          <div className="space-y-4">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3 bg-muted/20 border border-border rounded-lg p-3 text-xs leading-relaxed">
              <div><span className="text-muted-foreground">Employee ID</span><p className="font-mono font-medium">EMP-{getPerson(selectedTs.userId)?.id}</p></div>
              <div><span className="text-muted-foreground">Role</span><p className="font-medium capitalize">{selectedTs.userRole}</p></div>
              <div><span className="text-muted-foreground">Week Range</span><p className="font-medium">{selectedTs.weekStart}</p></div>
              <div><span className="text-muted-foreground">Total Hours Logged</span><p className="font-bold text-sm text-primary">{selectedTs.totalHours}h</p></div>
            </div>
            <div>
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">Logged Hours Breakdown</h4>
                {commentedEntriesCount > 0 && (
                  <div className="flex items-center gap-1.5 rounded bg-blue-50 border border-blue-200 px-2 py-0.5 text-[11px] font-semibold text-blue-800">
                    <MessageSquare className="h-3 w-3 text-blue-600" /><span>Commented Entries: {commentedEntriesCount}</span>
                  </div>
                )}
              </div>
              <div className="overflow-x-auto rounded-lg border border-border bg-card">
                <table className="w-full text-xs">
                  <thead className="bg-muted/40 text-left uppercase tracking-wide text-muted-foreground">
                    <tr>
                      <th className="px-3 py-2 font-medium">Project</th><th className="px-3 py-2 font-medium">Task</th>
                      {days.map((d) => <th key={d} className="px-2 py-2 text-center font-medium">{d}</th>)}
                      <th className="px-3 py-2 text-right font-medium">Total</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {selectedTs.entries.map((e, idx) => {
                      const proj = allProjects().find(p => p.id === e.projectId);
                      const tsk = proj?.tasks.find(t => t.id === e.taskId);
                      const rowTotal = e.hours.reduce((a, b) => a + b, 0);
                      return (
                        <tr key={idx} className="hover:bg-accent/10">
                          <td className="px-3 py-2 font-medium text-gray-800">{proj?.name || "Unknown Project"}</td>
                          <td className="px-3 py-2 text-muted-foreground">{tsk?.title || "Unknown Task"}</td>
                          {e.hours.map((h, i) => {
                            const commentData = getCellCommentData(e, i);
                            const hasComment = commentData && commentData.history.length > 0;
                            const dotColor = hasComment ? (commentData.status === "clarification_requested" ? "text-red-500" : commentData.status === "viewed" ? "text-blue-500" : "text-green-500") : "";
                            return (
                              <td key={i} className={cn("px-2 py-2 text-center font-mono tabular-nums align-middle relative", hasComment ? "cursor-pointer hover:bg-accent/40" : "")}
                                onClick={() => { if (hasComment) { setActiveCell({ entryIndex: idx, dayIndex: i }); dhStore.markCellCommentViewed(selectedTs.id, e.projectId, e.taskId, i); } }}>
                                <span>{h || "—"}</span>
                                {hasComment && <span className={cn("ml-1 font-bold inline-block select-none", dotColor)} title="Comment Available" style={{ fontSize: "14px", lineHeight: "1" }}>●</span>}
                              </td>
                            );
                          })}
                          <td className="px-3 py-2 text-right font-semibold tabular-nums align-top">{rowTotal}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
            <div className="space-y-2 border-t border-border pt-3">
              <label className="text-xs font-semibold text-gray-700 block">Supervisor Decision Comments <span className="text-destructive font-bold">*Mandatory</span></label>
              <textarea value={actionComment} onChange={(e) => setActionComment(e.target.value)}
                placeholder="Provide approval, rejection, or change request reason comments..." rows={3}
                className="w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border" />
            </div>
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button onClick={() => setSelectedTsId(null)} className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent">Cancel</button>
              <button onClick={() => handleAction("rejected", actionComment)} disabled={!actionComment.trim()}
                className="inline-flex items-center gap-1 rounded-md border border-destructive/30 bg-destructive/10 px-4 py-2 text-xs font-medium text-destructive hover:bg-destructive/20 disabled:opacity-50">
                <XCircle className="h-3.5 w-3.5" /> Reject
              </button>
              <button onClick={() => handleAction("rejected", actionComment, true)} disabled={!actionComment.trim()}
                className="inline-flex items-center gap-1 rounded-md border border-warning/30 bg-warning/10 px-4 py-2 text-xs font-medium text-warning-foreground hover:bg-warning/20 disabled:opacity-50">
                <RotateCcw className="h-3.5 w-3.5" /> Request Changes
              </button>
              <button onClick={() => handleAction("approved", actionComment)} disabled={!actionComment.trim()}
                className="inline-flex items-center gap-1 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50">
                <CheckCircle2 className="h-3.5 w-3.5" /> Approve
              </button>
            </div>
          </div>
        </Modal>
      )}

      {activeCell && selectedTs && (() => {
        const entry = selectedTs.entries[activeCell.entryIndex];
        const proj = allProjects().find(p => p.id === entry.projectId);
        const tsk = proj?.tasks.find(t => t.id === entry.taskId);
        const commentData = getCellCommentData(entry, activeCell.dayIndex);
        const empName = getPerson(selectedTs.userId)?.name || "Employee";
        return (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
            <div className="w-full max-w-lg rounded-xl border border-border bg-card p-5 shadow-2xl flex flex-col max-h-[90vh]">
              <div className="flex items-center justify-between border-b border-border pb-3">
                <div><h3 className="text-sm font-semibold text-gray-900">Day Comment Conversation</h3><p className="text-[11px] text-muted-foreground">Review and respond to daily timesheet comments</p></div>
                <button onClick={() => { setActiveCell(null); setCellReplyText(""); }} className="rounded-md p-1.5 hover:bg-accent text-muted-foreground" aria-label="Close"><X className="h-4 w-4" /></button>
              </div>
              <div className="grid grid-cols-2 gap-2 bg-muted/20 border border-border rounded-lg p-3 my-3 text-xs leading-relaxed">
                <div><span className="text-muted-foreground text-[10px] uppercase font-semibold">Employee</span><p className="font-semibold text-gray-800">{empName}</p></div>
                <div><span className="text-muted-foreground text-[10px] uppercase font-semibold">Day</span><p className="font-semibold text-gray-800">{["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"][activeCell.dayIndex]}</p></div>
                <div><span className="text-muted-foreground text-[10px] uppercase font-semibold">Project</span><p className="font-medium text-gray-700 truncate max-w-[200px]">{proj?.name}</p></div>
                <div><span className="text-muted-foreground text-[10px] uppercase font-semibold">Hours</span><p className="font-bold text-sm text-primary">{entry.hours[activeCell.dayIndex]}h</p></div>
                <div className="col-span-2"><span className="text-muted-foreground text-[10px] uppercase font-semibold">Task</span><p className="font-medium text-gray-700 truncate">{tsk?.title}</p></div>
              </div>
              <div className="flex-1 overflow-y-auto min-h-[150px] pr-1 py-1 space-y-3">
                {commentData && commentData.history.length > 0 ? commentData.history.map((msg: CellCommentMessage, mIdx: number) => {
                  const isSelf = msg.author === user.name;
                  const dt = new Date(msg.createdAt);
                  return (
                    <div key={mIdx} className={cn("flex flex-col max-w-[85%] rounded-lg p-3 text-xs shadow-sm border leading-relaxed", isSelf ? "ml-auto bg-primary/5 border-primary/20" : "mr-auto bg-muted border-border")}>
                      <div className="text-[10px] font-bold text-muted-foreground mb-1">Author: {msg.author}</div>
                      <div className="text-gray-800 font-medium whitespace-pre-wrap break-words"><span className="font-semibold text-gray-600">Comment:</span> "{msg.text}"</div>
                      <div className="mt-1.5 text-[10px] text-muted-foreground border-t border-border/20 pt-1">
                        <p><strong>Created Date:</strong> {dt.toLocaleDateString()}</p>
                        <p><strong>Created Time:</strong> {dt.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}</p>
                      </div>
                    </div>
                  );
                }) : <p className="text-center text-xs text-muted-foreground py-8">No comments recorded for this entry.</p>}
              </div>
              <div className="border-t border-border pt-3 mt-3 space-y-2">
                <textarea value={cellReplyText} onChange={(e) => setCellReplyText(e.target.value)} placeholder="Type response or clarification request..." rows={2}
                  className="w-full rounded-md border border-input bg-card p-2 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring" />
                <div className="flex justify-end gap-2 text-xs">
                  <button onClick={() => { if (!cellReplyText.trim()) { toast.error("Please enter response text."); return; } dhStore.addCellComment(selectedTs.id, entry.projectId, entry.taskId, activeCell.dayIndex, cellReplyText, "clarification_request", user.name); setCellReplyText(""); toast.success("Clarification requested."); }}
                    className="inline-flex items-center gap-1 rounded-md border border-red-200 bg-red-50 px-3 py-1.5 font-medium text-red-700 hover:bg-red-100">Request Clarification</button>
                  <button onClick={() => { if (!cellReplyText.trim()) { toast.error("Please enter response text."); return; } dhStore.addCellComment(selectedTs.id, entry.projectId, entry.taskId, activeCell.dayIndex, cellReplyText, "response", user.name); setCellReplyText(""); toast.success("Response added."); }}
                    className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 font-medium text-primary-foreground hover:bg-primary/90">Add Response</button>
                </div>
              </div>
            </div>
          </div>
        );
      })()}
    </section>
  );
}
