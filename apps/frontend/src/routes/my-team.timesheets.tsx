import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useMemo, useRef, useState, type ReactNode } from "react";
import { createPortal } from "react-dom";
import {
  Clock,
  Send,
  Trash2,
  MessageSquare,
  Copy,
  X,
  CheckCircle2,
  XCircle,
  RotateCcw,
  Plus,
  ChevronUp,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { useRoleContext } from "@/lib/role-context";
import { TimesheetStatusPill, Avatar } from "@/components/pills";
import { allProjects } from "@/lib/dh-store";
import { cn, formatDateDMY } from "@/lib/utils";
import { toast } from "sonner";
import { Modal } from "./projects.index";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { HourField } from "@/components/hour-field";
import { RowsPerPageSelect } from "@/components/rows-per-page-select";
import { paginateSlice, paginationRange, totalPageCount } from "@/lib/pagination";
import {
  decideTimesheet,
  getMyTimesheet,
  getPreviousTimesheet,
  listTimesheetApprovals,
  saveTimesheetDraft,
  submitTimesheet,
  type TimesheetWeek,
} from "@/lib/api/timesheets";

export const Route = createFileRoute("/my-team/timesheets")({
  head: () => ({
    meta: [
      { title: "Timesheets — Pulse PMO" },
      { name: "description", content: "My Team timesheet management." },
    ],
  }),
  component: TimesheetsRoute,
});

function TimesheetsRoute() {
  const { status: authStatus } = useAuth();
  if (authStatus === "loading") return null;
  return (
    <AppShell title="Timesheets" subtitle="My Team · timesheets and approvals">
      <TimesheetTab />
    </AppShell>
  );
}

// ── Shared helpers ───────────────────────────────────────────────────────────
const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
interface TsRow {
  id: string;
  projectId: string;
  taskId: string;
  hours: number[];
  notes: string[];
}

function emptyRow(projects: ReturnType<typeof allProjects>): TsRow {
  return {
    id: `r${Date.now()}`,
    projectId: projects[0]?.id || "",
    taskId: projects[0]?.tasks[0]?.id || "",
    hours: [0, 0, 0, 0, 0, 0, 0],
    notes: ["", "", "", "", "", "", ""],
  };
}

function rowsFromWeek(week: TimesheetWeek): TsRow[] {
  return week.entries.map((entry) => {
    const hours = [0, 0, 0, 0, 0, 0, 0];
    const notes = ["", "", "", "", "", "", ""];
    for (const day of entry.days) {
      hours[day.dayIndex] = day.hours;
      notes[day.dayIndex] = day.comment || "";
    }
    return {
      id: entry.id,
      projectId: entry.projectKey,
      taskId: entry.taskKey,
      hours,
      notes,
    };
  });
}

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
      <div className="mb-4 flex gap-1 rounded-lg border border-border bg-card p-1 text-sm shadow-sm w-fit">
        {(["My Timesheet", "Timesheet Approval"] as const).map((st) => (
          <button
            key={st}
            type="button"
            onClick={() => setSubTab(st)}
            className={cn(
              "rounded-md px-3 py-1.5 font-medium",
              subTab === st
                ? "bg-primary text-primary-foreground"
                : "text-muted-foreground hover:text-foreground",
            )}
          >
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
  const [weekStart, setWeekStart] = useState(thisMonday());
  const [weekStatus, setWeekStatus] = useState<TimesheetWeek["status"]>("draft");
  const [showDraft, setShowDraft] = useState(false);
  const [saving, setSaving] = useState(false);
  const projectsList = allProjects();

  const [rows, setRows] = useState<TsRow[]>(() => [emptyRow(projectsList)]);

  const [commentOpen, setCommentOpen] = useState<{ row: string; day: number } | null>(null);

  const tasksByProject = useMemo(() => {
    const map: Record<string, (typeof projectsList)[number]["tasks"]> = {};
    projectsList.forEach((p) => {
      map[p.id] = p.tasks;
    });
    return map;
  }, [projectsList]);

  const dayTotals = days.map((_, di) => rows.reduce((s, r) => s + (Number(r.hours[di]) || 0), 0));
  const total = dayTotals.reduce((a, b) => a + b, 0);

  useEffect(() => {
    let cancelled = false;
    getMyTimesheet(weekStart)
      .then((week) => {
        if (cancelled) return;
        setWeekStatus(week?.status ?? "draft");
        setShowDraft(week?.status === "draft");
        setRows(week && week.entries.length > 0 ? rowsFromWeek(week) : [emptyRow(allProjects())]);
      })
      .catch(() => {
        if (!cancelled) toast.error("Could not load this week's timesheet.");
      });
    return () => {
      cancelled = true;
    };
  }, [weekStart]);

  function toSaveLines() {
    return rows.map((row) => {
      const project = projectsList.find((item) => item.id === row.projectId);
      const task = project?.tasks.find((item) => item.id === row.taskId);
      return {
        projectKey: row.projectId,
        projectName: project?.name || "Project",
        taskKey: row.taskId,
        taskName: task?.title || "Task",
        days: row.hours.map((hours, dayIndex) => ({
          dayIndex,
          hours: Number(hours) || 0,
          comment: row.notes[dayIndex]?.trim() ? row.notes[dayIndex] : null,
        })),
      };
    });
  }

  function update(id: string, patch: Partial<TsRow>) {
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
  function setNote(id: string, di: number, v: string) {
    setRows((prev) =>
      prev.map((r) =>
        r.id === id ? { ...r, notes: r.notes.map((h, i) => (i === di ? v : h)) } : r,
      ),
    );
  }
  function addRow() {
    const p = projectsList[0];
    if (!p) return;
    setRows((r) => [
      ...r,
      {
        id: `r${Date.now()}`,
        projectId: p.id,
        taskId: p.tasks[0]?.id || "",
        hours: [0, 0, 0, 0, 0, 0, 0],
        notes: ["", "", "", "", "", "", ""],
      },
    ]);
  }
  function remove(id: string) {
    setRows((r) => r.filter((x) => x.id !== id));
  }
  async function copyLast() {
    try {
      const previous = await getPreviousTimesheet(weekStart);
      if (!previous || previous.entries.length === 0) {
        toast.error("No timesheet found for last week.");
        return;
      }
      setRows(rowsFromWeek(previous).map((row) => ({ ...row, id: `r${crypto.randomUUID()}` })));
      toast.success("Copied hours and comments from last week.");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not copy last week.");
    }
  }
  function shiftWeek(d: number) {
    const dt = new Date(weekStart);
    dt.setDate(dt.getDate() + d);
    setWeekStart(dt.toISOString().slice(0, 10));
  }
  async function handleSave(submit: boolean) {
    setSaving(true);
    try {
      const saved = submit
        ? await submitTimesheet(weekStart, toSaveLines())
        : await saveTimesheetDraft(weekStart, toSaveLines());
      setWeekStatus(saved.status);
      setShowDraft(saved.status === "draft");
      toast.success(submit ? "Timesheet submitted for approval." : "Timesheet saved as draft.");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not save the timesheet.");
    } finally {
      setSaving(false);
    }
  }

  const activeRow = commentOpen ? rows.find((r) => r.id === commentOpen.row) : null;
  const currentStatus = weekStatus;
  const locked = currentStatus === "submitted" || currentStatus === "approved";

  return (
    <>
      <div className="mb-4 flex flex-wrap items-center gap-3 rounded-xl border border-border bg-card p-4 shadow-sm">
        <Clock className="h-4 w-4 text-muted-foreground" />
        <div>
          <div className="text-sm font-medium">
            {user.name} · Week of {weekStart}
          </div>
          <div className="text-xs text-muted-foreground">
            {currentStatus === "rejected"
              ? "Rejected. Update the hours and submit again."
              : currentStatus === "change_requested"
                ? "Changes requested. Update the hours and submit again."
                : currentStatus === "approved"
                  ? "This week is approved."
                  : currentStatus === "submitted"
                    ? "Submitted. It is with your reporting manager."
                    : "Log hours per project · save as draft or submit for approval"}
          </div>
        </div>
        {showDraft && <TimesheetStatusPill status="draft" />}
        <div className="ml-auto flex items-center gap-2 flex-wrap">
          <button
            onClick={() => shiftWeek(-7)}
            className="rounded-md border border-input bg-card px-2 py-1 text-xs hover:bg-accent"
          >
            ‹
          </button>
          <button
            onClick={() => shiftWeek(7)}
            className="rounded-md border border-input bg-card px-2 py-1 text-xs hover:bg-accent"
          >
            ›
          </button>
          <button
            onClick={copyLast}
            className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent"
          >
            <Copy className="h-3.5 w-3.5" /> Copy Last Week
          </button>
          <span className="text-xs text-muted-foreground">Total</span>
          <span className="text-lg font-semibold tabular-nums">{total}h</span>
          <button
            onClick={() => void handleSave(false)}
            disabled={saving || locked}
            className="rounded-md border border-input bg-card px-3 py-1.5 text-sm hover:bg-accent disabled:opacity-50"
          >
            Save draft
          </button>
          <button
            onClick={() => void handleSave(true)}
            disabled={saving || total === 0 || locked}
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
              <th className="px-3 py-2 font-medium min-w-[260px]">Project</th>
              <th className="px-3 py-2 font-medium min-w-[200px]">Task</th>
              {days.map((d) => (
                <th key={d} className="px-2 py-2 text-center font-medium">
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
                    <SearchableSelect
                      options={projectsList.map((p) => ({ value: p.id, label: p.name }))}
                      value={r.projectId}
                      onChange={(projectId) =>
                        update(r.id, {
                          projectId,
                          taskId: tasksByProject[projectId]?.[0]?.id ?? "",
                        })
                      }
                      placeholder="Select project"
                      searchPlaceholder="Search projects…"
                      clearable={false}
                    />
                  </td>
                  <td className="px-3 py-2 align-top">
                    <SearchableSelect
                      options={tasks.map((t) => ({ value: t.id, label: t.title }))}
                      value={r.taskId}
                      onChange={(taskId) => update(r.id, { taskId })}
                      placeholder="Select task"
                      searchPlaceholder="Search tasks…"
                      clearable={false}
                    />
                  </td>
                  {r.hours.map((h, di) => (
                    <td key={di} className="px-2 py-2 text-center align-top">
                      <div className="flex flex-col items-center gap-1">
                        <HourField
                          value={h}
                          label={`${days[di]} hours`}
                          onChange={(hours) => setHour(r.id, di, String(hours))}
                        />
                        <button
                          onClick={() => setCommentOpen({ row: r.id, day: di })}
                          className={cn(
                            "inline-flex h-5 w-5 items-center justify-center rounded-md hover:bg-accent",
                            r.notes[di] ? "text-primary" : "text-muted-foreground",
                          )}
                          aria-label="Day comment"
                        >
                          <MessageSquare className="h-3 w-3" />
                        </button>
                      </div>
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
              <td className="px-3 py-2" colSpan={2}>
                Daily total
              </td>
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
      {commentOpen && activeRow && typeof document !== "undefined" && createPortal(
        <div
          className="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 p-4 backdrop-blur-[1px]"
          onClick={() => setCommentOpen(null)}
        >
          <div
            className="w-full max-w-md rounded-t-2xl border border-border bg-card p-4 shadow-xl sm:rounded-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-sm font-semibold">Day note · {days[commentOpen.day]}</h3>
                <p className="text-xs text-muted-foreground">
                  {projectsList.find((p) => p.id === activeRow.projectId)?.name}
                </p>
              </div>
              <button
                onClick={() => setCommentOpen(null)}
                className="rounded-md p-1 hover:bg-accent"
                aria-label="Close"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <textarea
              value={activeRow.notes[commentOpen.day]}
              onChange={(e) => setNote(activeRow.id, commentOpen.day, e.target.value)}
              placeholder="Add a note for this day · visible to your approver"
              rows={5}
              className="mt-3 w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
            />
            <div className="mt-3 flex justify-end gap-2">
              <button
                onClick={() => setCommentOpen(null)}
                className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent"
              >
                Cancel
              </button>
              <button
                onClick={() => setCommentOpen(null)}
                className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
              >
                Save note
              </button>
            </div>
          </div>
        </div>,
        document.body,
      )}
    </>
  );
}

function commentText(data: { history: { text: string }[] } | null): string {
  if (!data) return "";
  return data.history
    .map((message) => message.text.trim())
    .filter(Boolean)
    .join("\n");
}

function CommentTip({ text, children }: { text: string; children: ReactNode }) {
  const [anchor, setAnchor] = useState<{ left: number; top: number } | null>(null);
  return (
    <span
      className="inline-flex items-center justify-center"
      onMouseEnter={(event) => {
        const rect = event.currentTarget.getBoundingClientRect();
        setAnchor({ left: rect.left + rect.width / 2, top: rect.top });
      }}
      onMouseLeave={() => setAnchor(null)}
    >
      {children}
      {anchor &&
        createPortal(
          <div
            className="pointer-events-none fixed z-[130] max-w-[240px] -translate-x-1/2 -translate-y-full whitespace-pre-wrap rounded-md border border-border bg-popover px-2.5 py-1.5 text-left text-xs text-foreground shadow-md"
            style={{ left: anchor.left, top: anchor.top - 8 }}
          >
            {text}
          </div>,
          document.body,
        )}
    </span>
  );
}

function RowCheckbox({
  checked,
  indeterminate,
  onChange,
  label,
}: {
  checked: boolean;
  indeterminate?: boolean;
  onChange: (checked: boolean) => void;
  label: string;
}) {
  const ref = useRef<HTMLInputElement>(null);
  useEffect(() => {
    if (ref.current) ref.current.indeterminate = Boolean(indeterminate);
  }, [indeterminate]);
  return (
    <input
      ref={ref}
      type="checkbox"
      checked={checked}
      aria-label={label}
      onChange={(event) => onChange(event.target.checked)}
      onClick={(event) => event.stopPropagation()}
      className="h-4 w-4 cursor-pointer accent-primary"
    />
  );
}

type ApprovalSortKey = "name" | "tk" | "project" | "week" | "submitted" | "hours" | "status";
type ReviewAction = "approved" | "rejected" | "change_requested";

type ApprovalLine = {
  id: string;
  projectName: string;
  taskName: string;
  hours: number[];
  notes: string[];
  reviewDecision?: "approved" | "rejected" | "change_requested";
};

type ApprovalSheet = {
  id: string;
  employeeName: string;
  employeeCode: string;
  weekStart: string;
  status: TimesheetWeek["status"];
  totalHours: number;
  submittedAt?: string;
  reviewComment?: string | null;
  viewerCanReview: boolean;
  entries: ApprovalLine[];
};

function toApprovalSheet(week: TimesheetWeek): ApprovalSheet {
  return {
    id: week.id,
    employeeName: week.employeeName,
    employeeCode: week.employeeCode,
    weekStart: week.weekStart.slice(0, 10),
    status: week.status,
    totalHours: week.totalHours,
    submittedAt: week.submittedAtUtc ?? undefined,
    reviewComment: week.reviewComment,
    viewerCanReview: week.viewerCanReview,
        entries: week.entries.map((entry) => {
      const hours = [0, 0, 0, 0, 0, 0, 0];
      const notes = ["", "", "", "", "", "", ""];
      for (const day of entry.days) {
        hours[day.dayIndex] = Number(day.hours) || 0;
        notes[day.dayIndex] = day.comment || "";
      }
      return {
        id: entry.id,
        projectName: entry.projectName,
        taskName: entry.taskName,
        hours,
        notes,
        reviewDecision: entry.reviewDecision ?? undefined,
      };
    }),
  };
}

function ApprovalSortTh({
  label,
  column,
  sortKey,
  sortDir,
  onSort,
  className,
  align = "left",
  isLast,
}: {
  label: string;
  column: ApprovalSortKey;
  sortKey: ApprovalSortKey;
  sortDir: "asc" | "desc";
  onSort: (column: ApprovalSortKey) => void;
  className?: string;
  align?: "left" | "right";
  isLast?: boolean;
}) {
  const active = sortKey === column;
  return (
    <th className={cn("relative whitespace-nowrap px-4 py-3 font-semibold", className)}>
      <button
        type="button"
        onClick={() => onSort(column)}
        className={cn(
          "group inline-flex items-center gap-1.5 text-xs font-semibold transition-colors select-none",
          align === "right" ? "w-full justify-end text-right" : "text-left",
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
      {!isLast && (
        <span
          className="absolute right-0 top-2.5 bottom-2.5 w-[1.5px] bg-slate-400/80 dark:bg-slate-500 pointer-events-none"
          aria-hidden="true"
        />
      )}
    </th>
  );
}

// ── TimesheetApprovalView ────────────────────────────────────────────────────
function TimesheetApprovalView() {
  const [sheets, setSheets] = useState<ApprovalSheet[]>([]);
  const [sortKey, setSortKey] = useState<ApprovalSortKey>("name");
  const [sortDir, setSortDir] = useState<"asc" | "desc">("asc");
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);
  const [selectedTsId, setSelectedTsId] = useState<string | null>(null);
  const [actionComment, setActionComment] = useState("");
  const [selectedEntries, setSelectedEntries] = useState<number[]>([]);
  const [confirmAction, setConfirmAction] = useState<ReviewAction | null>(null);

  const loadApprovals = () => {
    listTimesheetApprovals()
      .then((weeks) => setSheets(weeks.map(toApprovalSheet)))
      .catch(() => toast.error("Could not load timesheets for approval."));
  };

  useEffect(() => {
    loadApprovals();
  }, []);

  useEffect(() => {
    setSelectedEntries([]);
    setConfirmAction(null);
    setActionComment("");
  }, [selectedTsId]);

  const selectedTs = useMemo(
    () => sheets.find((sheet) => sheet.id === selectedTsId),
    [sheets, selectedTsId],
  );
  const breakdownCols = useMemo(() => {
    let project = "Project".length;
    let task = "Task".length;
    if (!selectedTs) return { project: "12rem", task: "10rem" };
    for (const entry of selectedTs.entries) {
      project = Math.max(project, entry.projectName.length + (entry.reviewDecision ? 16 : 0));
      task = Math.max(task, entry.taskName.length);
    }
    return {
      project: `calc(${project}ch + 1.75rem)`,
      task: `calc(${task}ch + 1.75rem)`,
    };
  }, [selectedTs]);
  const [activeCell, setActiveCell] = useState<{ entryIndex: number; dayIndex: number } | null>(
    null,
  );

  const getCellCommentData = (entry: any, dayIdx: number) => {
    if (entry.cellComments?.[dayIdx]) return entry.cellComments[dayIdx];
    const legacyNote = entry.notes?.[dayIdx] || (dayIdx === 0 ? entry.note : undefined);
    if (legacyNote?.trim())
      return {
        status: "new" as const,
        history: [
          {
            author: selectedTs?.employeeName || "Employee",
            text: legacyNote,
            type: "comment" as const,
            createdAt: selectedTs?.submittedAt || new Date().toISOString(),
          },
        ],
      };
    return null;
  };

  const commentedEntriesCount = useMemo(() => {
    if (!selectedTs) return 0;
    return selectedTs.entries.reduce((acc, entry) => {
      return (
        acc +
        days.filter((_, idx) => {
          const d = getCellCommentData(entry, idx);
          return d && d.history.length > 0;
        }).length
      );
    }, 0);
  }, [selectedTs]);

  const askAction = (action: ReviewAction) => {
    if (!actionComment.trim()) {
      toast.error("A comment is mandatory for all timesheet approval actions!");
      return;
    }
    if (selectedEntries.length === 0) {
      toast.error("Select at least one project.");
      return;
    }
    setConfirmAction(action);
  };

  const applyAction = () => {
    if (!selectedTs?.viewerCanReview || !confirmAction || !actionComment.trim() || selectedEntries.length === 0) return;
    const count = selectedEntries.length;
    const verb =
      confirmAction === "approved" ? "Approved" : confirmAction === "rejected" ? "Rejected" : "Requested changes on";
    const entryIds = selectedEntries
      .map((index) => selectedTs.entries[index]?.id)
      .filter((id): id is string => Boolean(id));
    decideTimesheet(selectedTs.id, entryIds, confirmAction, actionComment)
      .then((updated) => {
        const finished = updated.status !== "submitted";
        toast.success(
          `${verb} ${count} selected ${count === 1 ? "project" : "projects"}${finished ? ". Timesheet updated." : "."}`,
        );
        setActionComment("");
        setSelectedEntries([]);
        setConfirmAction(null);
        if (finished) setSelectedTsId(null);
        loadApprovals();
      })
      .catch((error) => {
        toast.error(error instanceof Error ? error.message : "Could not save the decision.");
      });
  };

  const toggleSort = (column: ApprovalSortKey) => {
    if (sortKey === column) setSortDir((d) => (d === "asc" ? "desc" : "asc"));
    else {
      setSortKey(column);
      setSortDir("asc");
    }
    setPage(1);
  };

  const approvalRows = useMemo(() => {
    const rows = sheets.map((sheet) => ({
      t: sheet,
      name: sheet.employeeName || "Employee",
      tk: sheet.employeeCode || "—",
      projectName: Array.from(new Set(sheet.entries.map((entry) => entry.projectName).filter(Boolean))).join(", ") || "—",
      submittedLabel: sheet.submittedAt ? formatDateDMY(sheet.submittedAt.slice(0, 10)) : "—",
    }));
    const dir = sortDir === "asc" ? 1 : -1;
    rows.sort((a, b) => {
      const text = (left: string, right: string) => left.localeCompare(right) * dir;
      switch (sortKey) {
        case "name":
          return text(a.name, b.name);
        case "tk":
          return text(a.tk, b.tk);
        case "project":
          return text(a.projectName, b.projectName);
        case "week":
          return text(a.t.weekStart, b.t.weekStart);
        case "submitted":
          return text(a.t.submittedAt ?? "", b.t.submittedAt ?? "");
        case "hours":
          return (a.t.totalHours - b.t.totalHours) * dir;
        case "status":
          return text(a.t.status, b.t.status);
        default:
          return 0;
      }
    });
    return rows;
  }, [sheets, sortKey, sortDir]);

  const totalPages = totalPageCount(approvalRows.length, pageSize);
  const currentPage = Math.min(page, totalPages);
  const pageRows = paginateSlice(approvalRows, currentPage, pageSize);
  const pageRange = paginationRange(currentPage, pageSize, approvalRows.length);

  return (
    <section className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
      <div className="overflow-auto max-h-[calc(100vh-220px)] min-h-[420px]">
        <table className="w-full min-w-[1100px] table-fixed text-sm">
          <thead className="sticky top-0 z-10 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700 shadow-2xs">
            <tr>
              <ApprovalSortTh label="Employee Name" column="name" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-56" />
              <ApprovalSortTh label="TK ID" column="tk" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-28" />
              <ApprovalSortTh label="Project Name" column="project" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} />
              <ApprovalSortTh label="Week Range" column="week" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-36" />
              <ApprovalSortTh label="Submitted Date" column="submitted" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-40" />
              <ApprovalSortTh label="Total Hours" column="hours" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-32" />
              <ApprovalSortTh label="Current Status" column="status" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-36" />
              <th className="relative w-40 whitespace-nowrap px-4 py-3 text-right text-xs font-semibold text-blue-950/85 dark:text-blue-100/85">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {pageRows.map(({ t, name, tk, projectName, submittedLabel }) => (
              <tr
                key={t.id}
                onClick={() => setSelectedTsId(t.id)}
                className="cursor-pointer transition-colors hover:bg-accent/30"
              >
                <td className="whitespace-nowrap px-4 py-3.5">
                  <div className="flex min-w-0 items-center gap-2.5">
                    <Avatar name={name} size={28} />
                    <span className="truncate font-semibold" title={name}>{name}</span>
                  </div>
                </td>
                <td className="whitespace-nowrap px-4 py-3.5 font-mono text-xs text-muted-foreground" title={tk}>
                  {tk}
                </td>
                <td className="px-4 py-3.5 text-muted-foreground truncate" title={projectName}>
                  {projectName}
                </td>
                <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground tabular-nums">
                  {formatDateDMY(t.weekStart)}
                </td>
                <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground">
                  {submittedLabel}
                </td>
                <td className="whitespace-nowrap px-4 py-3.5 font-medium tabular-nums">
                  {t.totalHours}h
                </td>
                <td className="whitespace-nowrap px-4 py-3.5">
                  <TimesheetStatusPill status={t.status} />
                </td>
                <td className="whitespace-nowrap px-4 py-3.5 text-right">
                  <button
                    type="button"
                    onClick={(event) => {
                      event.stopPropagation();
                      setSelectedTsId(t.id);
                    }}
                    className="rounded-md border border-slate-300 bg-white/90 px-2.5 py-1 text-xs font-medium text-blue-950 shadow-2xs transition-colors hover:bg-blue-100/60 dark:border-slate-600 dark:bg-blue-900/50 dark:text-blue-100 dark:hover:bg-blue-800/60"
                  >
                    Review
                  </button>
                </td>
              </tr>
            ))}
            {pageRows.length === 0 && (
              <tr>
                <td colSpan={8} className="px-4 py-10 text-center text-sm text-muted-foreground">
                  No timesheets to review
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
      <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-slate-300 dark:border-slate-700 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80 shadow-xs">
        <div className="flex items-center gap-3">
          <span>
            Showing{" "}
            <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.from}</strong>
            {" - "}
            <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.to}</strong>
            {" of "}
            <strong className="font-semibold text-blue-950 dark:text-blue-100">{approvalRows.length}</strong>
            {" timesheets"}
          </span>
          <span className="text-slate-300 dark:text-slate-600">|</span>
          <div className="flex items-center gap-1.5">
            <span>Per page:</span>
            <RowsPerPageSelect
              value={pageSize}
              onChange={(size) => {
                setPageSize(size);
                setPage(1);
              }}
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

      {selectedTs && (
        <Modal
          title={`Review Timesheet — ${selectedTs.employeeName}`}
          onClose={() => setSelectedTsId(null)}
          extraWide
          portal
        >
          <div className="space-y-4">
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3 bg-muted/20 border border-border rounded-lg p-3 text-xs leading-relaxed">
              <div>
                <span className="text-muted-foreground">TK ID</span>
                <p className="font-mono font-medium">{selectedTs.employeeCode || "—"}</p>
              </div>
              <div>
                <span className="text-muted-foreground">Role</span>
                <p className="font-medium">Team member</p>
              </div>
              <div>
                <span className="text-muted-foreground">Week Range</span>
                <p className="font-medium">{selectedTs.weekStart}</p>
              </div>
              <div>
                <span className="text-muted-foreground">Total Hours Logged</span>
                <p className="font-bold text-sm text-primary">{selectedTs.totalHours}h</p>
              </div>
            </div>
            <div>
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                  Logged Hours Breakdown
                </h4>
                {commentedEntriesCount > 0 && (
                  <div className="flex items-center gap-1.5 rounded bg-blue-50 border border-blue-200 px-2 py-0.5 text-[11px] font-semibold text-blue-800">
                    <MessageSquare className="h-3 w-3 text-blue-600" />
                    <span>Commented Entries: {commentedEntriesCount}</span>
                  </div>
                )}
              </div>
              <div className="overflow-x-auto overscroll-x-contain rounded-xl border border-border bg-card shadow-sm [scrollbar-width:thin] [scrollbar-color:#94a3b8_#e2e8f0] [&::-webkit-scrollbar]:h-2 [&::-webkit-scrollbar-track]:bg-slate-200 [&::-webkit-scrollbar-thumb]:rounded-full [&::-webkit-scrollbar-thumb]:bg-slate-400">
                <table className="w-full table-fixed text-sm">
                  <colgroup>
                    <col className="w-12" />
                    <col style={{ width: breakdownCols.project }} />
                    <col style={{ width: breakdownCols.task }} />
                  </colgroup>
                  <thead className="sticky top-0 z-10 bg-blue-50/80 text-left text-xs text-blue-950/85 border-b border-slate-300 shadow-2xs backdrop-blur-md dark:bg-blue-950/45 dark:text-blue-100/85 dark:border-slate-700">
                    <tr>
                      <th className="relative whitespace-nowrap px-4 py-3">
                        <RowCheckbox
                          checked={selectedTs.entries.length > 0 && selectedEntries.length === selectedTs.entries.length}
                          indeterminate={selectedEntries.length > 0 && selectedEntries.length < selectedTs.entries.length}
                          label="Select all projects"
                          onChange={(checked) =>
                            setSelectedEntries(checked ? selectedTs.entries.map((_, index) => index) : [])
                          }
                        />
                        <span
                          className="pointer-events-none absolute bottom-2.5 right-0 top-2.5 w-[1.5px] bg-slate-400/80 dark:bg-slate-500"
                          aria-hidden="true"
                        />
                      </th>
                      {["Project", "Task", ...days, "Total"].map((label, index, labels) => (
                        <th
                          key={label}
                          className={cn(
                            "relative whitespace-nowrap px-3 py-3 font-semibold text-blue-950/85 dark:text-blue-100/85",
                            index >= 2 && "px-2 text-center",
                          )}
                        >
                          {label}
                          {index < labels.length - 1 && (
                            <span
                              className="pointer-events-none absolute bottom-2.5 right-0 top-2.5 w-[1.5px] bg-slate-400/80 dark:bg-slate-500"
                              aria-hidden="true"
                            />
                          )}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {selectedTs.entries.map((e, idx) => {
                      const rowTotal = e.hours.reduce((a, b) => a + b, 0);
                      const decisionLabel =
                        e.reviewDecision === "approved"
                          ? "Approved"
                          : e.reviewDecision === "rejected"
                            ? "Rejected"
                            : e.reviewDecision === "change_requested"
                              ? "Changes requested"
                              : "";
                      return (
                        <tr
                          key={idx}
                          className={cn(
                            "transition-colors hover:bg-accent/30",
                            selectedEntries.includes(idx) && "bg-primary/5",
                          )}
                        >
                          <td className="whitespace-nowrap px-4 py-3.5">
                            <RowCheckbox
                              checked={selectedEntries.includes(idx)}
                              label={`Select ${e.projectName || "project"}`}
                              onChange={(checked) =>
                                setSelectedEntries((prev) =>
                                  checked ? [...prev, idx] : prev.filter((item) => item !== idx),
                                )
                              }
                            />
                          </td>
                          <td className="whitespace-nowrap px-3 py-3.5 font-semibold">
                            <div className="flex items-center gap-2">
                              <span>{e.projectName || "Unknown Project"}</span>
                              {decisionLabel && (
                                <span
                                  className={cn(
                                    "rounded-full px-2 py-0.5 text-[10px] font-semibold",
                                    e.reviewDecision === "approved" && "bg-emerald-500/10 text-emerald-700",
                                    e.reviewDecision === "rejected" && "bg-destructive/10 text-destructive",
                                    e.reviewDecision === "change_requested" && "bg-amber-500/15 text-amber-700",
                                  )}
                                >
                                  {decisionLabel}
                                </span>
                              )}
                            </div>
                          </td>
                          <td className="whitespace-nowrap px-3 py-3.5 text-muted-foreground">
                            {e.taskName || "Unknown Task"}
                          </td>
                          {e.hours.map((h, i) => {
                            const commentData = getCellCommentData(e, i);
                            const note = commentText(commentData);
                            const hasComment = note.length > 0;
                            const dotColor = hasComment
                              ? commentData?.status === "clarification_requested"
                                ? "text-red-500"
                                : commentData?.status === "viewed"
                                  ? "text-blue-500"
                                  : "text-green-500"
                              : "";
                            const cell = (
                              <>
                                <span>{h || "—"}</span>
                                {hasComment && (
                                  <span
                                    className={cn("ml-1 inline-block select-none font-bold", dotColor)}
                                    style={{ fontSize: "14px", lineHeight: "1" }}
                                  >
                                    ●
                                  </span>
                                )}
                              </>
                            );
                            return (
                              <td
                                key={i}
                                className={cn(
                                  "relative px-1 py-3.5 text-center font-medium tabular-nums align-middle",
                                  hasComment ? "cursor-pointer hover:bg-accent/40" : "",
                                )}
                                onClick={() => {
                                  if (!hasComment) return;
                                  setActiveCell({ entryIndex: idx, dayIndex: i });
                                }}
                              >
                                {hasComment &&
                                !(activeCell?.entryIndex === idx && activeCell.dayIndex === i) ? (
                                  <CommentTip text={note}>{cell}</CommentTip>
                                ) : (
                                  cell
                                )}
                              </td>
                            );
                          })}
                          <td className="px-4 py-3.5 text-center text-lg font-semibold tabular-nums align-middle">
                            {rowTotal}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
            {selectedTs.viewerCanReview ? (
              <>
            <div className="space-y-2 border-t border-border pt-3">
              <label className="text-xs font-semibold text-gray-700 block">
                Supervisor Decision Comments <span className="text-destructive">*</span>
              </label>
              <textarea
                value={actionComment}
                onChange={(e) => setActionComment(e.target.value)}
                placeholder="Provide approval, rejection, or change request reason comments..."
                rows={3}
                className="w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border"
              />
            </div>
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button
                onClick={() => setSelectedTsId(null)}
                className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
              >
                Cancel
              </button>
              <button
                onClick={() => askAction("rejected")}
                disabled={!actionComment.trim() || selectedEntries.length === 0}
                className="inline-flex items-center gap-1 rounded-md border border-destructive/30 bg-destructive/10 px-4 py-2 text-xs font-medium text-destructive hover:bg-destructive/20 disabled:opacity-50"
              >
                <XCircle className="h-3.5 w-3.5" /> Reject
              </button>
              <button
                onClick={() => askAction("change_requested")}
                disabled={!actionComment.trim() || selectedEntries.length === 0}
                className="inline-flex items-center gap-1 rounded-md border border-warning/30 bg-warning/10 px-4 py-2 text-xs font-medium text-warning-foreground hover:bg-warning/20 disabled:opacity-50"
              >
                <RotateCcw className="h-3.5 w-3.5" /> Request Changes
              </button>
              <button
                onClick={() => askAction("approved")}
                disabled={!actionComment.trim() || selectedEntries.length === 0}
                className="inline-flex items-center gap-1 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
              >
                <CheckCircle2 className="h-3.5 w-3.5" /> Approve
              </button>
            </div>
              </>
            ) : (
              <div className="space-y-3 border-t border-border pt-3">
                <p className="text-sm text-muted-foreground">
                  {selectedTs.status === "approved"
                    ? "This timesheet is approved."
                    : selectedTs.status === "rejected"
                      ? "This timesheet was rejected. Update it in My Timesheet and submit again."
                      : selectedTs.status === "change_requested"
                        ? "Changes were requested. Update the hours in My Timesheet and submit again."
                        : "Waiting for your reporting manager to review the logged hours."}
                </p>
                {selectedTs.reviewComment ? (
                  <p className="rounded-md bg-muted/40 px-3 py-2 text-sm">{selectedTs.reviewComment}</p>
                ) : null}
                <div className="flex justify-end">
                  <button
                    type="button"
                    onClick={() => setSelectedTsId(null)}
                    className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
                  >
                    Close
                  </button>
                </div>
              </div>
            )}
          </div>
        </Modal>
      )}

      {activeCell &&
        selectedTs &&
        typeof document !== "undefined" &&
        createPortal((() => {
          const entry = selectedTs.entries[activeCell.entryIndex];
          const note = commentText(getCellCommentData(entry, activeCell.dayIndex));
          return (
            <div
              className="fixed inset-0 z-[110] flex items-center justify-center bg-black/50 p-4 backdrop-blur-[1px]"
              onClick={() => setActiveCell(null)}
            >
              <div
                className="w-full max-w-sm rounded-xl border border-border bg-card p-4 shadow-2xl"
                onClick={(event) => event.stopPropagation()}
              >
                <div className="flex items-start justify-between gap-3">
                  <p className="whitespace-pre-wrap text-sm text-foreground">{note}</p>
                  <button
                    onClick={() => setActiveCell(null)}
                    className="rounded-md p-1.5 text-muted-foreground hover:bg-accent"
                    aria-label="Close"
                  >
                    <X className="h-4 w-4" />
                  </button>
                </div>
              </div>
            </div>
          );
        })(), document.body)}

      {confirmAction && selectedTs && typeof document !== "undefined" && createPortal(
        <div className="fixed inset-0 z-[120] flex items-center justify-center bg-black/50 p-4 backdrop-blur-[1px]">
          <div className="w-full max-w-sm rounded-xl border border-border bg-card p-5 shadow-2xl">
            <h3 className="text-sm font-semibold">
              {confirmAction === "approved"
                ? "Approve selected projects?"
                : confirmAction === "rejected"
                  ? "Reject selected projects?"
                  : "Request changes on selected projects?"}
            </h3>
            <p className="mt-2 text-sm text-muted-foreground">
              {selectedEntries.length} selected {selectedEntries.length === 1 ? "project" : "projects"}.
            </p>
            <p className="mt-3 whitespace-pre-wrap rounded-md bg-muted/40 px-3 py-2 text-sm">{actionComment}</p>
            <div className="mt-4 flex justify-end gap-2">
              <button
                type="button"
                onClick={() => setConfirmAction(null)}
                className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={applyAction}
                className={cn(
                  "rounded-md px-4 py-2 text-xs font-medium",
                  confirmAction === "approved" && "bg-primary text-primary-foreground hover:bg-primary/90",
                  confirmAction === "rejected" && "bg-destructive text-destructive-foreground hover:bg-destructive/90",
                  confirmAction === "change_requested" && "bg-amber-500 text-white hover:bg-amber-500/90",
                )}
              >
                Confirm
              </button>
            </div>
          </div>
        </div>,
        document.body,
      )}
    </section>
  );
}
