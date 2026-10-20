import { useEffect, useMemo, useRef, useState, useCallback, type ReactNode } from "react";
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
import { fetchProjects, fetchProjectTasks } from "@/modules/projects/api/projects";
import { cn, formatDateDMY } from "@/lib/utils";
import { toast } from "sonner";
import { Modal } from "@/modules/projects/pages/projects-list-page";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { HourField } from "@/components/hour-field";
import { canShiftTimesheetWeek, isTimesheetDayOpen } from "@/lib/timesheet-window";
import { RowsPerPageSelect } from "@/components/rows-per-page-select";
import { paginateSlice, paginationRange, totalPageCount } from "@/lib/pagination";
import {
  decideTimesheet,
  getMyTimesheet,
  getPreviousTimesheet,
  listMyTimesheetHistory,
  listTimesheetApprovals,
  saveTimesheetDraft,
  submitTimesheet,
  type TimesheetWeek,
} from "@/modules/timesheets/api/timesheets";

export function TimesheetsPage() {
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
const MAX_DAY_COMMENT_LENGTH = 1000;
const MAX_APPROVAL_COMMENT_LENGTH = 200;
interface TsRow {
  id: string;
  projectId: string;
  taskId: string;
  taskName: string;
  hours: number[];
  notes: string[];
}

function taskChoiceLabel(title: string, serviceName?: string) {
  return serviceName ? `${title} · ${serviceName}` : title;
}

function savedTaskLabel(taskName: string | undefined, taskId: string) {
  const name = taskName?.trim();
  if (!name || name === taskId || name.includes("-svc-")) return "";
  return name;
}

function emptyRow(): TsRow {
  return {
    id: `r${Date.now()}`,
    projectId: "",
    taskId: "",
    taskName: "",
    hours: [0, 0, 0, 0, 0, 0, 0],
    notes: ["", "", "", "", "", "", ""],
  };
}

function rowHasLoggedData(row: Pick<TsRow, "hours" | "notes">): boolean {
  const totalHours = row.hours.reduce((sum, h) => sum + (Number(h) || 0), 0);
  const hasNotes = row.notes.some((n) => Boolean(n?.trim()));
  return totalHours > 0 || hasNotes;
}

/** Drop project/task on lines with no hours and no day notes so the week opens blank until the user picks them. */
function sanitizeLoadedRow(row: TsRow): TsRow {
  if (rowHasLoggedData(row)) return row;
  return { ...row, projectId: "", taskId: "", taskName: "" };
}

function mapWeekEntries(week: TimesheetWeek): TsRow[] {
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
      taskName: entry.taskName || "",
      hours,
      notes,
    };
  });
}

/** Load current week: hide project/task on lines with no hours and no comments. */
function rowsFromWeek(week: TimesheetWeek): TsRow[] {
  const mapped = mapWeekEntries(week).map(sanitizeLoadedRow);
  if (mapped.length === 0) return [emptyRow()];
  const allBlank = mapped.every(
    (row) => !row.projectId && !row.taskId && !rowHasLoggedData(row),
  );
  return allBlank ? [emptyRow()] : mapped;
}

function localDate(date: Date) {
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${date.getFullYear()}-${month}-${day}`;
}

function weekEndFromStart(weekStart: string): string {
  const [year, month, day] = weekStart.split("-").map(Number);
  const start = new Date(year, (month || 1) - 1, day || 1);
  const end = new Date(start);
  end.setDate(end.getDate() + 6);
  return localDate(end);
}

function formatWeekRange(weekStart: string): string {
  const end = weekEndFromStart(weekStart);
  return `${formatDateDMY(weekStart)} – ${formatDateDMY(end)}`;
}

function thisMonday() {
  const date = new Date();
  const day = date.getDay() || 7;
  date.setDate(date.getDate() - (day - 1));
  return localDate(date);
}

// ── TimesheetTab ─────────────────────────────────────────────────────────────
function TimesheetTab() {
  const [subTab, setSubTab] = useState<"My Timesheet" | "Timesheet History" | "Timesheet Approval">("My Timesheet");
  return (
    <div>
      <div className="mb-4 flex gap-1 rounded-lg border border-border bg-card p-1 text-sm shadow-sm w-fit">
        {(["My Timesheet", "Timesheet History", "Timesheet Approval"] as const).map((st) => (
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
      {subTab === "My Timesheet" ? (
        <MyTimesheetView />
      ) : subTab === "Timesheet History" ? (
        <TimesheetHistoryView />
      ) : (
        <TimesheetApprovalView />
      )}
    </div>
  );
}

// ── MyTimesheetView ──────────────────────────────────────────────────────────
function MyTimesheetView() {
  const { user: authUser } = useAuth();
  const { user, employeePersonId } = useRoleContext();
  const effectiveEmployeeId = authUser?.employeeId || employeePersonId || (user as any)?.employeeId;

  const [weekStart, setWeekStart] = useState(thisMonday());
  const [weekStatus, setWeekStatus] = useState<TimesheetWeek["status"]>("draft");
  const [showDraft, setShowDraft] = useState(false);
  const [saving, setSaving] = useState(false);

  const [dbProjects, setDbProjects] = useState<Array<{ id: string; name: string; projectCode?: string }>>([]);
  const [loadingProjects, setLoadingProjects] = useState(false);
  const [tasksByProject, setTasksByProject] = useState<Record<string, Array<{ id: string; title: string; serviceName?: string; stage?: string; estimatedHours?: number }>>>({});
  const [loadingTasks, setLoadingTasks] = useState<Record<string, boolean>>({});

  const [rows, setRows] = useState<TsRow[]>(() => [emptyRow()]);
  const [commentOpen, setCommentOpen] = useState<{ row: string; day: number } | null>(null);

  const dayTotals = days.map((_, di) => rows.reduce((s, r) => s + (Number(r.hours[di]) || 0), 0));
  const total = dayTotals.reduce((a, b) => a + b, 0);

  // Load real tasks for a specific project from backend DB
  const loadTasksForProject = useCallback(async (projectId: string) => {
    if (!projectId) return;
    setLoadingTasks((prev) => ({ ...prev, [projectId]: true }));
    try {
      const apiTasks = await fetchProjectTasks(projectId);
      setTasksByProject((prev) => ({
        ...prev,
        [projectId]: apiTasks.map((t) => ({
          id: t.id,
          title: t.title,
          serviceName: t.serviceName?.trim() || undefined,
          stage: t.stage,
          estimatedHours: t.estimatedHours ?? undefined,
        })),
      }));
    } catch (err) {
      console.error(`Failed to load tasks for project ${projectId}:`, err);
    } finally {
      setLoadingTasks((prev) => ({ ...prev, [projectId]: false }));
    }
  }, []);

  // Load real projects from database (filtered to assigned employee, falling back to all active)
  useEffect(() => {
    let cancelled = false;
    setLoadingProjects(true);

    async function loadProjects() {
      try {
        let res = effectiveEmployeeId
          ? await fetchProjects({ employeeId: effectiveEmployeeId, status: "active", perPage: 200 })
          : null;

        // If no assigned projects found, fallback to active projects so timesheet is loggable
        if (!res || !res.items || res.items.length === 0) {
          res = await fetchProjects({ status: "active", perPage: 200 });
        }

        if (!res || !res.items || res.items.length === 0) {
          res = await fetchProjects({ perPage: 200 });
        }

        if (!cancelled && res?.items) {
          setDbProjects(res.items.map((p) => ({
            id: p.id,
            name: p.name,
            projectCode: p.projectCode,
          })));
        }
      } catch (err) {
        console.error("Failed to load real projects from DB:", err);
      } finally {
        if (!cancelled) setLoadingProjects(false);
      }
    }

    loadProjects();
    return () => {
      cancelled = true;
    };
  }, [effectiveEmployeeId]);

  // Load this week's timesheet from backend
  useEffect(() => {
    let cancelled = false;
    getMyTimesheet(weekStart)
      .then((week) => {
        if (cancelled) return;
        setWeekStatus(week?.status ?? "draft");
        setShowDraft(week?.status === "draft");
        const loadedRows = week && week.entries.length > 0 ? rowsFromWeek(week) : [emptyRow()];
        setRows(loadedRows);

        // Preload tasks for all projects present in this week's timesheet
        loadedRows.forEach((r) => {
          if (r.projectId) {
            loadTasksForProject(r.projectId);
          }
        });
      })
      .catch(() => {
        if (!cancelled) toast.error("Could not load this week's timesheet.");
      });
    return () => {
      cancelled = true;
    };
  }, [weekStart, loadTasksForProject]);

  function validateDayComments(): string | null {
    for (const row of rows) {
      for (let dayIndex = 0; dayIndex < row.notes.length; dayIndex += 1) {
        const note = row.notes[dayIndex]?.trim() ?? "";
        if (note.length > MAX_DAY_COMMENT_LENGTH) {
          return `Day note for ${days[dayIndex]} must be ${MAX_DAY_COMMENT_LENGTH} characters or fewer.`;
        }
      }
    }
    return null;
  }

  function toSaveLines() {
    return rows.filter((row) => row.projectId && row.taskId).map((row) => {
      const project = dbProjects.find((item) => item.id === row.projectId);
      const task = tasksByProject[row.projectId]?.find((item) => item.id === row.taskId);
      return {
        projectKey: row.projectId,
        projectName: project?.name || "Project",
        taskKey: row.taskId,
        taskName: task ? taskChoiceLabel(task.title, task.serviceName) : (row.taskName || "Task"),
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
    setRows((r) => [...r, emptyRow()]);
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
      const loaded = mapWeekEntries(previous).map((row) => ({
        ...row,
        id: `r${crypto.randomUUID()}`,
        hours: row.hours.map((hours, index) => (isTimesheetDayOpen(weekStart, index) ? hours : 0)),
        notes: row.notes.map((note, index) => (isTimesheetDayOpen(weekStart, index) ? note : "")),
      }));
      setRows(loaded);
      loaded.forEach((r) => {
        if (r.projectId) {
          loadTasksForProject(r.projectId);
        }
      });
      toast.success("Copied hours and comments from last week.");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not copy last week.");
    }
  }
  function shiftWeek(d: number) {
    const [year, month, day] = weekStart.split("-").map(Number);
    const dt = new Date(year, (month || 1) - 1, day || 1);
    dt.setDate(dt.getDate() + d);
    setWeekStart(localDate(dt));
  }
  async function handleSave(submit: boolean) {
    const commentError = validateDayComments();
    if (commentError) {
      toast.error(commentError);
      return;
    }
    setSaving(true);
    try {
      const saved = submit
        ? await submitTimesheet(weekStart, toSaveLines())
        : await saveTimesheetDraft(weekStart, toSaveLines());
      setWeekStatus(saved.status);
      setShowDraft(saved.status === "draft");
      setRows(rowsFromWeek(saved));
      toast.success(submit ? "Timesheet submitted for approval." : "Timesheet saved as draft.");
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not save the timesheet.");
    } finally {
      setSaving(false);
    }
  }

  const currentStatus = weekStatus;
  const locked = currentStatus === "submitted" || currentStatus === "approved";
  const activeRow = commentOpen ? rows.find((r) => r.id === commentOpen.row) : null;
  const activeDayOpen =
    commentOpen !== null ? isTimesheetDayOpen(weekStart, commentOpen.day) : false;
  const activeCommentReadOnly =
    commentOpen !== null && (locked || !activeDayOpen);

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
            disabled={!canShiftTimesheetWeek(weekStart, -7)}
            className="rounded-md border border-input bg-card px-2 py-1 text-xs hover:bg-accent disabled:pointer-events-none disabled:opacity-40"
          >
            ‹
          </button>
          <button
            onClick={() => shiftWeek(7)}
            disabled={!canShiftTimesheetWeek(weekStart, 7)}
            className="rounded-md border border-input bg-card px-2 py-1 text-xs hover:bg-accent disabled:pointer-events-none disabled:opacity-40"
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
                    <SearchableSelect
                      options={dbProjects.map((p) => ({
                        value: p.id,
                        label: p.name,
                        subLabel: p.projectCode,
                      }))}
                      value={r.projectId}
                      onChange={(projectId) => {
                        update(r.id, {
                          projectId,
                          taskId: "",
                          taskName: "",
                        });
                        if (projectId) {
                          loadTasksForProject(projectId);
                        }
                      }}
                      placeholder={loadingProjects ? "Loading projects…" : "Select project"}
                      searchPlaceholder="Search projects…"
                    />
                  </td>
                  <td className="px-3 py-2 align-top">
                    {(() => {
                      const pTasks = tasksByProject[r.projectId] ?? [];
                      const isTaskLoading = loadingTasks[r.projectId];
                      const options = pTasks.map((t) => ({
                        value: t.id,
                        label: taskChoiceLabel(t.title, t.serviceName),
                        subLabel: t.stage ? `${t.stage}${t.estimatedHours ? ` · ${t.estimatedHours}h` : ""}` : undefined,
                      }));
                      const savedLabel = savedTaskLabel(r.taskName, r.taskId);
                      if (r.taskId && savedLabel && !options.some((option) => option.value === r.taskId)) {
                        options.unshift({ value: r.taskId, label: savedLabel, subLabel: undefined });
                      }
                      return (
                        <SearchableSelect
                          options={options}
                          value={r.taskId}
                          onChange={(taskId) => {
                            const task = pTasks.find((item) => item.id === taskId);
                            update(r.id, {
                              taskId,
                              taskName: task ? taskChoiceLabel(task.title, task.serviceName) : savedLabel,
                            });
                          }}
                          placeholder={
                            !r.projectId
                              ? "Select a project first"
                              : isTaskLoading
                                ? "Loading tasks…"
                                : pTasks.length === 0
                                  ? "No tasks in this project"
                                  : "Select task"
                          }
                          searchPlaceholder="Search tasks…"
                          disabled={!r.projectId || isTaskLoading || pTasks.length === 0}
                        />
                      );
                    })()}
                  </td>
                  {r.hours.map((h, di) => {
                    const open = isTimesheetDayOpen(weekStart, di);
                    const hasNote = Boolean(r.notes[di]?.trim());
                    const canEditComment = open && !locked;
                    const canOpenComment = canEditComment || hasNote;
                    return (
                    <td key={di} className="px-2 py-2 text-center align-top">
                      <div className="flex flex-col items-center gap-1">
                        <HourField
                          value={h}
                          label={`${days[di]} hours`}
                          disabled={!open || locked}
                          onChange={(hours) => setHour(r.id, di, String(hours))}
                        />
                        <button
                          type="button"
                          onClick={() => canOpenComment && setCommentOpen({ row: r.id, day: di })}
                          disabled={!canOpenComment}
                          className={cn(
                            "inline-flex h-5 w-5 items-center justify-center rounded-md hover:bg-accent disabled:pointer-events-none disabled:opacity-40",
                            hasNote ? "text-primary" : "text-muted-foreground",
                          )}
                          aria-label={hasNote ? "View or edit day note" : "Add day note"}
                        >
                          <MessageSquare className="h-3 w-3" />
                        </button>
                      </div>
                    </td>
                    );
                  })}
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
                <h3 className="text-sm font-semibold">
                  Day note · {days[commentOpen.day]}
                  {activeCommentReadOnly ? " (read only)" : ""}
                </h3>
                <p className="text-xs text-muted-foreground">
                  {dbProjects.find((p) => p.id === activeRow.projectId)?.name}
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
              value={activeRow.notes[commentOpen.day] ?? ""}
              readOnly={activeCommentReadOnly}
              maxLength={MAX_DAY_COMMENT_LENGTH}
              onChange={(e) =>
                setNote(activeRow.id, commentOpen.day, e.target.value.slice(0, MAX_DAY_COMMENT_LENGTH))
              }
              placeholder="Add a note for this day · visible to your approver"
              rows={5}
              className={cn(
                "mt-3 w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring",
                activeCommentReadOnly && "cursor-default bg-muted/30",
              )}
            />
            {!activeCommentReadOnly && (
              <p className="mt-1 text-right text-[11px] text-muted-foreground">
                {(activeRow.notes[commentOpen.day] ?? "").length}/{MAX_DAY_COMMENT_LENGTH}
              </p>
            )}
            <div className="mt-3 flex justify-end gap-2">
              <button
                type="button"
                onClick={() => setCommentOpen(null)}
                className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent"
              >
                {activeCommentReadOnly ? "Close" : "Cancel"}
              </button>
              {!activeCommentReadOnly && (
              <button
                type="button"
                onClick={() => setCommentOpen(null)}
                className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
              >
                Done
              </button>
              )}
            </div>
          </div>
        </div>,
        document.body,
      )}
    </>
  );
}

function dayCommentNote(entry: ApprovalLine, dayIdx: number): string {
  return entry.notes[dayIdx]?.trim() ?? "";
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

// ── TimesheetHistoryView ─────────────────────────────────────────────────────
type HistoryLogRow = {
  key: string;
  weekStart: string;
  projectName: string;
  taskName: string;
  lineHours: number;
  submittedAt?: string;
  status: TimesheetWeek["status"];
  reviewComment?: string | null;
};

function TimesheetHistoryView() {
  const [sheets, setSheets] = useState<ApprovalSheet[]>([]);

  useEffect(() => {
    listMyTimesheetHistory()
      .then((weeks) => setSheets(weeks.map(toApprovalSheet)))
      .catch(() => toast.error("Could not load your timesheet history."));
  }, []);

  const logRows = useMemo((): HistoryLogRow[] => {
    const rows: HistoryLogRow[] = [];
    for (const sheet of sheets) {
      if (sheet.entries.length === 0) {
        rows.push({
          key: `${sheet.id}-empty`,
          weekStart: sheet.weekStart,
          projectName: "—",
          taskName: "—",
          lineHours: 0,
          submittedAt: sheet.submittedAt,
          status: sheet.status,
          reviewComment: sheet.reviewComment,
        });
        continue;
      }
      for (const entry of sheet.entries) {
        rows.push({
          key: entry.id,
          weekStart: sheet.weekStart,
          projectName: entry.projectName?.trim() || "—",
          taskName: entry.taskName?.trim() || "—",
          lineHours: entry.hours.reduce((sum, h) => sum + (Number(h) || 0), 0),
          submittedAt: sheet.submittedAt,
          status: sheet.status,
          reviewComment: sheet.reviewComment,
        });
      }
    }
    return rows;
  }, [sheets]);

  return (
    <section className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
      <div className="overflow-auto max-h-[calc(100vh-220px)] min-h-[420px]">
        <table className="w-full text-sm">
          <thead className="sticky top-0 z-10 bg-blue-50/80 dark:bg-blue-950/45 text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700">
            <tr>
              <th className="px-4 py-3 font-semibold">Week</th>
              <th className="px-4 py-3 font-semibold">Project</th>
              <th className="px-4 py-3 font-semibold">Task</th>
              <th className="px-4 py-3 font-semibold">Submitted</th>
              <th className="px-4 py-3 font-semibold">Hours</th>
              <th className="px-4 py-3 font-semibold">Status</th>
              <th className="px-4 py-3 font-semibold">Approval note</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {logRows.map((row) => (
              <tr key={row.key}>
                <td className="whitespace-nowrap px-4 py-3.5 tabular-nums text-xs sm:text-sm">
                  {formatWeekRange(row.weekStart)}
                </td>
                <td className="max-w-[14rem] px-4 py-3.5 truncate" title={row.projectName}>
                  {row.projectName}
                </td>
                <td className="max-w-[14rem] px-4 py-3.5 truncate text-muted-foreground" title={row.taskName}>
                  {row.taskName}
                </td>
                <td className="whitespace-nowrap px-4 py-3.5 text-muted-foreground">
                  {row.submittedAt ? formatDateDMY(row.submittedAt.slice(0, 10)) : "—"}
                </td>
                <td className="whitespace-nowrap px-4 py-3.5 font-medium tabular-nums">{row.lineHours}h</td>
                <td className="whitespace-nowrap px-4 py-3.5">
                  <TimesheetStatusPill status={row.status} />
                </td>
                <td className="max-w-[16rem] px-4 py-3.5 text-muted-foreground truncate" title={row.reviewComment ?? ""}>
                  {row.reviewComment?.trim() || "—"}
                </td>
              </tr>
            ))}
            {logRows.length === 0 && (
              <tr>
                <td colSpan={7} className="px-4 py-10 text-center text-sm text-muted-foreground">
                  No timesheet history yet
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </section>
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

  const commentedEntriesCount = useMemo(() => {
    if (!selectedTs) return 0;
    return selectedTs.entries.reduce((acc, entry) => {
      return acc + days.filter((_, idx) => dayCommentNote(entry, idx).length > 0).length;
    }, 0);
  }, [selectedTs]);

  const askAction = (action: ReviewAction) => {
    const comment = actionComment.trim();
    if (!comment) {
      toast.error("Enter a supervisor decision comment (up to 200 characters) before approving, rejecting, or requesting changes.");
      return;
    }
    if (comment.length > MAX_APPROVAL_COMMENT_LENGTH) {
      toast.error(`Supervisor comment must be ${MAX_APPROVAL_COMMENT_LENGTH} characters or fewer.`);
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
        <table className="w-full min-w-[1300px] table-fixed text-sm">
          <thead className="sticky top-0 z-10 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700 shadow-2xs">
            <tr>
              <ApprovalSortTh label="Employee Name" column="name" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-56" />
              <ApprovalSortTh label="TK ID" column="tk" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-28" />
              <ApprovalSortTh label="Project Name" column="project" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-64" />
              <ApprovalSortTh label="Week Range" column="week" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-48" />
              <ApprovalSortTh label="Submitted Date" column="submitted" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-40" />
              <ApprovalSortTh label="Total Hours" column="hours" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-32" />
              <ApprovalSortTh label="Current Status" column="status" sortKey={sortKey} sortDir={sortDir} onSort={toggleSort} className="w-36" />
              <th className="relative w-32 whitespace-nowrap px-4 py-3 text-right text-xs font-semibold text-blue-950/85 dark:text-blue-100/85">
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
                  {formatWeekRange(t.weekStart)}
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
                <p className="font-medium tabular-nums">{formatWeekRange(selectedTs.weekStart)}</p>
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
                            const note = dayCommentNote(e, i);
                            const hasComment = note.length > 0;
                            const dotColor = hasComment ? "text-green-500" : "";
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
                maxLength={MAX_APPROVAL_COMMENT_LENGTH}
                onChange={(e) => setActionComment(e.target.value.slice(0, MAX_APPROVAL_COMMENT_LENGTH))}
                placeholder="Provide approval, rejection, or change request reason comments..."
                rows={3}
                className="w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border"
              />
              <p className={cn("text-right text-[11px]", actionComment.length >= MAX_APPROVAL_COMMENT_LENGTH ? "text-destructive" : "text-muted-foreground")}>
                {actionComment.length}/{MAX_APPROVAL_COMMENT_LENGTH}
              </p>
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
          const note = dayCommentNote(entry, activeCell.dayIndex);
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
