import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useMemo, useState, useEffect, useCallback } from "react";
import {
  Search,
  Filter,
  Plus,
  Send,
  Trash2,
  Clock,
  MessageSquare,
  Copy,
  X,
  CheckCircle2,
  XCircle,
  RotateCcw,
  AlertTriangle,
  AlertCircle,
  Calendar,
  DollarSign,
  Check,
  ExternalLink,
  ShieldAlert,
  ListFilter,
  User,
  Paperclip,
  Bell,
  Archive,
  ChevronDown,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useAuth } from "@/lib/auth-context";
import { getDemoPersona } from "@/lib/demo-roles";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { startTaskTimer, stopTaskTimer, fetchProjects, type ApiProject } from "@/lib/api/projects";
import {
  createIssueApi,
  fetchIssueProjectOptionsApi,
  type ProjectIssueApiItem,
  type IssueProjectOption,
} from "@/lib/api/issues";
import {
  fetchBucketTasks,
  startBucketTimer,
  pauseBucketTimer,
  resumeBucketTimer,
  completeBucketTask as completeBucketTaskApi,
  type BucketTaskApiItem,
} from "@/lib/api/bucket-tasks";
import {
  fetchAlertsApi,
  fetchAlertMetricsApi,
  acknowledgeAlertApi,
  resolveAlertApi,
  triggerAlertScanApi,
  type AlertApiItem,
  type AlertMetricsApi,
} from "@/lib/api/alerts";
import {
  fetchApprovals,
  submitApprovalAction,
  type ApprovalApiItem,
} from "@/lib/api/approvals";
import {
  getPerson,
  people,
  type TaskStatus,
  type CellCommentData,
  type CellCommentMessage,
} from "@/lib/mock-data";
import { TaskStatusPill, TimesheetStatusPill, PriorityPill, Avatar } from "@/components/pills";
import {
  useDhStore,
  dhStore,
  allProjects,
  allClients,
  type DhAlert,
  type DhInterview,
  type DhTimesheet,
  type DhCentralApproval,
  type AlertStatus,
  type DhNotification,
  type IssueCategory,
  type DhPriority,
} from "@/lib/dh-store";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { Modal } from "./projects.index";
import { Field } from "@/components/form-row";

export const Route = createFileRoute("/action-centre")({
  head: () => ({
    meta: [
      { title: "Action Centre — Pulse PMO" },
      {
        name: "description",
        content: "Bucket list, timesheets, approvals and alerts in one place.",
      },
    ],
  }),
  component: ActionCentrePage,
});

// Employees only get their Bucket List (assigned tasks) + Notifications.
const tabs = ["Bucket List", "Approvals", "Alerts", "Notifications"] as const;
type Tab = (typeof tabs)[number];

function ActionCentrePage() {
  const { isDhanshree, isAdmin, user, isEmployee, isPmoFamily, isSales } = useRoleContext();
  const { hasPermission } = usePermissions();
  const store = useDhStore((s) => s);
  const pendingCount = (store.notifications || []).filter((n) => n.status === "Pending").length;

  const visibleTabs: Tab[] = useMemo(() => {
    return tabs.filter((t) => {
      if (isAdmin || isDhanshree) return true;
      if (t === "Bucket List") {
        return (
          hasPermission("action.bucket_list") ||
          hasPermission("Action Center|Bucket List:view") ||
          hasPermission("action-center.bucket-list.view") ||
          hasPermission("action-center.view")
        );
      }
      if (t === "Approvals") {
        return (
          hasPermission("action.approvals") ||
          hasPermission("Action Center|Approvals:view") ||
          hasPermission("action-center.approvals.view")
        );
      }
      if (t === "Alerts") {
        return (
          hasPermission("action.alerts") ||
          hasPermission("Action Center|Alerts:view") ||
          hasPermission("action-center.alerts.view")
        );
      }
      if (t === "Notifications") {
        return (
          hasPermission("action.notifications") ||
          hasPermission("Action Center|Notifications:view") ||
          hasPermission("action-center.notifications.view")
        );
      }
      return false;
    });
  }, [isAdmin, isDhanshree, hasPermission]);

  const [tab, setTab] = useState<Tab>(() => visibleTabs[0] ?? "Bucket List");
  const activeTab = visibleTabs.includes(tab) ? tab : (visibleTabs[0] ?? "Bucket List");

  if (!isAdmin && !isDhanshree && !hasPermission("action-center.view")) return <Navigate to="/" />;

  return (
    <AppShell
      title="Action Centre"
      subtitle="Bucket list, timesheets, approvals and alerts in one place"
    >
      <div className="mb-4 flex gap-1 overflow-x-auto rounded-lg border border-border bg-card p-1 text-sm shadow-sm">
        {visibleTabs.map((t) => {
          const isNotif = t === "Notifications";
          return (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={cn(
                "rounded-md px-3 py-1.5 font-medium transition-colors whitespace-nowrap flex items-center gap-1.5",
                activeTab === t
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <span>{t}</span>
              {isNotif && pendingCount > 0 && (
                <span className="rounded-full bg-destructive text-destructive-foreground px-2 py-0.5 text-xs font-semibold leading-none">
                  {pendingCount}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {activeTab === "Bucket List" && <BucketList />}
      {activeTab === "Approvals" && <ApprovalsTab />}
      {activeTab === "Alerts" && <AlertsTab />}
      {activeTab === "Notifications" && <NotificationsTab />}
    </AppShell>
  );
}

// ---------- Bucket List ----------
function BucketListRow({
  r,
  canViewTimer,
  onAction,
}: {
  r: BucketTaskApiItem;
  canViewTimer: boolean;
  onAction?: () => void;
}) {
  const by = { name: r.assignedByName || "Project Manager" };
  const [now, setNow] = useState(Date.now());
  const { hasPermission } = usePermissions();
  const { isDhanshree, isAdmin } = useRoleContext();

  const canManageTimer =
    canViewTimer &&
    (isAdmin ||
      isDhanshree ||
      hasPermission("Action Center|Bucket List|Start timer:manage") ||
      hasPermission("action-center.start-timer.manage") ||
      hasPermission("action-center.bucket-list.timer.manage"));

  useEffect(() => {
    if (!r.isTimerRunning) return;
    const interval = setInterval(() => {
      setNow(Date.now());
    }, 1000);
    return () => clearInterval(interval);
  }, [r.isTimerRunning]);

  let workingTimeSeconds = r.elapsedSeconds;
  if (r.isTimerRunning && r.timerStartedAtUtc) {
    const elapsedSinceStart = Math.floor((now - new Date(r.timerStartedAtUtc).getTime()) / 1000);
    workingTimeSeconds += Math.max(0, elapsedSinceStart);
  }

  const formatTimer = (totalSecs: number) => {
    const h = Math.floor(totalSecs / 3600);
    const m = Math.floor((totalSecs % 3600) / 60);
    const s = totalSecs % 60;
    return [h, m, s].map((v) => String(v).padStart(2, "0")).join(":");
  };

  const handleStart = async () => {
    try {
      await startBucketTimer(r.assignmentId);
      toast.success("Timer started", { description: r.taskTitle });
      onAction?.();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not start timer");
    }
  };

  const handlePause = async () => {
    try {
      await pauseBucketTimer(r.assignmentId);
      toast.info("Timer paused", { description: r.taskTitle });
      onAction?.();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not pause timer");
    }
  };

  const handleResume = async () => {
    try {
      await resumeBucketTimer(r.assignmentId);
      toast.success("Timer resumed", { description: r.taskTitle });
      onAction?.();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not resume timer");
    }
  };

  const handleStop = async () => {
    try {
      await pauseBucketTimer(r.assignmentId);
      toast.warning("Timer stopped", { description: r.taskTitle });
      onAction?.();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not stop timer");
    }
  };

  const handleComplete = async () => {
    try {
      await completeBucketTaskApi(r.assignmentId);
      toast.success("Task completed!", { description: r.taskTitle });
      onAction?.();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not complete task");
    }
  };

  return (
    <tr className="hover:bg-accent/30 border-b border-border">
      <td className="px-3 py-2.5">
        <Link
          to="/projects/$projectId"
          params={{ projectId: r.projectId }}
          hash={r.taskId}
          className="font-semibold text-gray-800 hover:text-primary transition-colors"
        >
          {r.taskTitle}
        </Link>
      </td>
      <td className="px-3 py-2.5 text-muted-foreground font-medium">{r.projectName}</td>
      <td className="px-3 py-2.5">
        <PriorityPill priority={r.priority} />
      </td>
      <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground font-medium">
        {r.dueDate
          ? new Date(r.dueDate).toLocaleDateString("en-GB", {
              day: "2-digit",
              month: "short",
              year: "numeric",
            })
          : "—"}
      </td>
      <td className="px-3 py-2.5">
        <span
          className={cn(
            "inline-flex items-center gap-1 rounded-full border px-2.5 py-0.5 text-[10px] font-bold capitalize shadow-2xs",
            r.status === "Not Started" && "bg-slate-50 text-slate-700 border-slate-200",
            r.status === "Ongoing" && "bg-blue-50 text-blue-700 border-blue-200 animate-pulse",
            r.status === "Paused" && "bg-amber-50 text-amber-700 border-amber-200",
            r.status === "Stopped" && "bg-rose-50 text-rose-700 border-rose-200",
            r.status === "Completed" && "bg-green-50 text-green-700 border-green-200",
          )}
        >
          {r.status === "Ongoing" && <Clock className="h-3 w-3 animate-spin text-blue-600" />}
          {r.status}
        </span>
      </td>
      <td className="px-3 py-2.5">
        <div className="flex items-center gap-2">
          <Avatar name={by.name} size={24} />
          <span className="text-xs font-semibold text-gray-700">{by.name}</span>
        </div>
      </td>
      {canViewTimer && (
        <td className="px-3 py-2.5">
          <div className="flex flex-col gap-1.5 min-w-[210px] bg-muted/20 p-2 rounded-lg border border-border/80">
            {(r.status === "Ongoing" ||
              r.status === "Paused" ||
              r.status === "Stopped" ||
              r.status === "Completed") && (
              <div className="text-[10px] text-muted-foreground flex flex-col gap-0.5 font-medium">
                {(r.startedAtUtc || r.timerStartedAtUtc) && (
                  <div>
                    <span className="font-semibold text-gray-500">Started:</span>{" "}
                    {new Date(r.startedAtUtc || r.timerStartedAtUtc!).toLocaleString("en-GB", {
                      day: "2-digit",
                      month: "short",
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                  </div>
                )}
                <div className="flex items-center justify-between font-mono font-bold text-gray-800 border-t border-border/50 mt-1 pt-1">
                  <span>Working Time:</span>
                  <span
                    className={cn(
                      "text-xs font-bold",
                      r.isTimerRunning ? "text-blue-600 animate-pulse" : "text-gray-600",
                    )}
                  >
                    {formatTimer(workingTimeSeconds)}
                  </span>
                </div>
                {r.status === "Stopped" && (
                  <div className="text-rose-600 font-semibold border-t border-border/50 mt-1 pt-1 flex items-center gap-1">
                    Timer Frozen
                  </div>
                )}
                {r.status === "Completed" && r.completedAtUtc && (
                  <div className="text-success font-semibold border-t border-border/50 mt-1 pt-1">
                    Completed:{" "}
                    {new Date(r.completedAtUtc).toLocaleString("en-GB", {
                      day: "2-digit",
                      month: "short",
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                  </div>
                )}
              </div>
            )}

            {canManageTimer && (
              <div className="flex gap-1.5">
                {r.status === "Not Started" && (
                  <button
                    onClick={handleStart}
                    className="inline-flex items-center justify-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-xs font-bold text-primary-foreground hover:bg-primary/95 transition-all shadow-sm cursor-pointer"
                  >
                    <Clock className="h-3.5 w-3.5" /> Start Task
                  </button>
                )}
                {r.status === "Ongoing" && (
                  <>
                    <button
                      onClick={handlePause}
                      className="inline-flex items-center justify-center gap-1 rounded-md border border-amber-300 bg-amber-50 px-3 py-1.5 text-xs font-bold text-amber-700 hover:bg-amber-100 transition-all shadow-2xs cursor-pointer"
                    >
                      Pause
                    </button>
                    <button
                      onClick={handleStop}
                      className="inline-flex items-center justify-center gap-1 rounded-md bg-rose-600 px-3 py-1.5 text-xs font-bold text-white hover:bg-rose-700 transition-all shadow-sm cursor-pointer"
                    >
                      Stop
                    </button>
                  </>
                )}
                {r.status === "Paused" && (
                  <>
                    <button
                      onClick={handleResume}
                      className="inline-flex items-center justify-center gap-1 rounded-md border border-blue-300 bg-blue-50 px-3 py-1.5 text-xs font-bold text-blue-700 hover:bg-blue-100 transition-all shadow-2xs cursor-pointer"
                    >
                      Resume
                    </button>
                    <button
                      onClick={handleStop}
                      className="inline-flex items-center justify-center gap-1 rounded-md bg-rose-600 px-3 py-1.5 text-xs font-bold text-white hover:bg-rose-700 transition-all shadow-sm cursor-pointer"
                    >
                      Stop
                    </button>
                  </>
                )}
                {r.status === "Stopped" && (
                  <>
                    <button
                      onClick={handleResume}
                      className="inline-flex items-center justify-center gap-1 rounded-md border border-blue-300 bg-blue-50 px-3 py-1.5 text-xs font-bold text-blue-700 hover:bg-blue-100 transition-all shadow-2xs cursor-pointer"
                    >
                      Resume
                    </button>
                    <button
                      disabled
                      className="inline-flex items-center justify-center gap-1 rounded-md bg-muted px-3 py-1.5 text-xs font-bold text-muted-foreground border border-border cursor-not-allowed"
                    >
                      Stopped
                    </button>
                  </>
                )}
                {r.status === "Completed" && (
                  <span className="text-xs font-bold text-success flex items-center gap-1 py-1">
                    <CheckCircle2 className="h-4.5 w-4.5 text-success" /> Task Completed
                  </span>
                )}
              </div>
            )}
            {!canManageTimer && r.status === "Completed" && (
              <span className="text-xs font-bold text-success flex items-center gap-1 py-1">
                <CheckCircle2 className="h-4.5 w-4.5 text-success" /> Task Completed
              </span>
            )}
          </div>
        </td>
      )}
    </tr>
  );
}

function BucketList() {
  const { user, isDhanshree, isAdmin } = useRoleContext();
  const { demoRole } = useAuth();
  const currentPersona = useMemo(() => getDemoPersona(demoRole), [demoRole]);
  const { hasPermission } = usePermissions();
  const canViewTimer =
    isAdmin ||
    isDhanshree ||
    hasPermission("Action Center|Bucket List|Start timer:view") ||
    hasPermission("action-center.start-timer.view") ||
    hasPermission("action-center.start-timer") ||
    hasPermission("action-center.bucket-list.timer.view");

  const canRaiseIssue =
    isAdmin ||
    isDhanshree ||
    hasPermission("Action Center|Bucket List|Raise issues:manage") ||
    hasPermission("action-center.raise-issues.manage") ||
    hasPermission("action-center.bucket-list.manage") ||
    hasPermission("Action Center|Bucket List:manage");

  const [apiTasks, setApiTasks] = useState<BucketTaskApiItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshIndex, setRefreshIndex] = useState(0);

  const [q, setQ] = useState("");
  const [statusFilter, setStatusFilter] = useState<
    "all" | "todo" | "in_progress" | "review" | "done"
  >("all");
  const [priorityFilter, setPriorityFilter] = useState<
    "all" | "low" | "medium" | "high" | "critical"
  >("all");
  const [showRaiseModal, setShowRaiseModal] = useState(false);
  const [projectOptions, setProjectOptions] = useState<IssueProjectOption[]>([]);
  const [formData, setFormData] = useState({
    projectId: "",
    title: "",
    description: "",
    category: "Technical Related Issues" as IssueCategory,
    priority: "Medium" as DhPriority,
  });

  const triggerRefresh = useCallback(() => {
    setRefreshIndex((prev) => prev + 1);
  }, []);

  // Load real project options directly from backend (accessible to all roles including team members)
  useEffect(() => {
    fetchIssueProjectOptionsApi()
      .then((opts) => {
        if (Array.isArray(opts) && opts.length > 0) {
          setProjectOptions(opts);
        }
      })
      .catch((err) => console.warn("Could not load project options", err));
  }, []);

  // Load tasks directly from backend PostgreSQL database scoped to the active switched persona
  useEffect(() => {
    let active = true;
    setLoading(true);
    fetchBucketTasks({
      employeeId: currentPersona?.id || currentPersona?.code || undefined,
      status: statusFilter !== "all" ? statusFilter : undefined,
      priority: priorityFilter !== "all" ? priorityFilter : undefined,
      search: q.trim() || undefined,
    })
      .then((res) => {
        if (active && res && Array.isArray(res.items)) {
          setApiTasks(res.items);
        }
      })
      .catch((err) => {
        console.warn("Could not fetch API bucket tasks", err);
      })
      .finally(() => {
        if (active) setLoading(false);
      });

    return () => {
      active = false;
    };
  }, [demoRole, currentPersona, statusFilter, priorityFilter, q, refreshIndex]);

  const availableProjects = useMemo(() => {
    const map = new Map<string, { id: string; name: string; projectCode?: string }>();

    // 1. Projects loaded from backend database API
    projectOptions.forEach((p) => {
      map.set(p.id, { id: p.id, name: p.name, projectCode: p.projectCode });
    });

    // 2. Also incorporate projects from current employee's assigned tasks
    apiTasks.forEach((t) => {
      if (t.projectId && !map.has(t.projectId)) {
        map.set(t.projectId, {
          id: t.projectId,
          name: t.projectName || "Assigned Project",
          projectCode: t.projectCode || undefined,
        });
      }
    });

    return Array.from(map.values());
  }, [projectOptions, apiTasks]);

  const filtered = useMemo(() => {
    return apiTasks.filter((r) => {
      if (statusFilter !== "all") {
        if (statusFilter === "todo" && r.status !== "Not Started") return false;
        if (statusFilter === "in_progress" && r.status !== "Ongoing" && r.status !== "Paused")
          return false;
        if (statusFilter === "done" && r.status !== "Completed") return false;
        if (statusFilter === "review") return false;
      }
      if (priorityFilter !== "all" && r.priority !== priorityFilter) return false;
      if (!q.trim()) return true;
      const term = q.toLowerCase();
      return [r.taskTitle, r.projectName].some((v) => v.toLowerCase().includes(term));
    });
  }, [apiTasks, statusFilter, priorityFilter, q]);

  const handleSubmitIssue = async () => {
    if (!formData.title.trim() || !formData.description.trim()) {
      toast.error("Fill all fields");
      return;
    }
    const targetProjectId = formData.projectId || availableProjects[0]?.id;
    if (!targetProjectId) {
      toast.error("Please select a project");
      return;
    }

    try {
      const issue = await createIssueApi({
        projectId: targetProjectId,
        title: formData.title.trim(),
        description: formData.description.trim(),
        category: formData.category,
        priority: formData.priority,
        raisedByEmployeeId: currentPersona?.id || currentPersona?.code || undefined,
        raisedByName: currentPersona?.name || user.name,
        raisedByRole: currentPersona?.roleKey || user.role,
      });

      toast.success("Issue raised successfully", {
        description: `Routed to Dotted-Line Reporting Manager (${issue.dottedLineManagerName || "PM"} · PM). 2-day escalation SLA started.`,
      });
      setShowRaiseModal(false);
      setFormData({
        projectId: availableProjects[0]?.id || "",
        title: "",
        description: "",
        category: "Technical Related Issues",
        priority: "Medium",
      });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Could not raise issue");
    }
  };

  return (
    <section className="rounded-xl border border-border bg-card shadow-sm">
      <header className="flex flex-wrap items-center gap-2.5 border-b border-border p-3">
        {/* Search Bar */}
        <div className="relative w-60 max-w-xs">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search task or project…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>

        {/* Refresh Button */}
        <button
          onClick={triggerRefresh}
          title="Refresh Bucket List"
          className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-input bg-card text-muted-foreground hover:bg-accent hover:text-foreground transition-colors cursor-pointer"
        >
          <RotateCcw className={cn("h-3.5 w-3.5", loading && "animate-spin")} />
        </button>

        {/* Status Filter Bar */}
        <div className="flex h-9 items-center gap-1 rounded-md border border-input bg-card px-2 text-xs">
          <Filter className="h-3.5 w-3.5 text-muted-foreground shrink-0 mx-1" />
          {(["all", "todo", "in_progress", "done"] as const).map((s) => (
            <button
              key={s}
              onClick={() => setStatusFilter(s)}
              className={cn(
                "h-7 rounded-sm px-2.5 py-0.5 capitalize text-xs font-medium transition-colors cursor-pointer",
                statusFilter === s
                  ? "bg-primary text-primary-foreground font-semibold shadow-2xs"
                  : "text-muted-foreground hover:text-foreground hover:bg-accent/40",
              )}
            >
              {s === "all"
                ? "All status"
                : s === "todo"
                  ? "To Do"
                  : s === "in_progress"
                    ? "In Progress"
                    : "Done"}
            </button>
          ))}
        </div>

        {/* Priority Filter Bar */}
        <div className="flex h-9 items-center gap-1 rounded-md border border-input bg-card px-2 text-xs">
          {(["all", "low", "medium", "high", "critical"] as const).map((p) => (
            <button
              key={p}
              onClick={() => setPriorityFilter(p)}
              className={cn(
                "h-7 rounded-sm px-2.5 py-0.5 capitalize text-xs font-medium transition-colors cursor-pointer",
                priorityFilter === p
                  ? "bg-primary text-primary-foreground font-semibold shadow-2xs"
                  : "text-muted-foreground hover:text-foreground hover:bg-accent/40",
              )}
            >
              {p === "all" ? "All priority" : p}
            </button>
          ))}
        </div>

        {/* Raise Issue Button */}
        {canRaiseIssue && (
          <button
            onClick={() => {
              setFormData((prev) => ({
                ...prev,
                projectId: prev.projectId || availableProjects[0]?.id || "",
              }));
              setShowRaiseModal(true);
            }}
            className="inline-flex items-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground hover:bg-primary/90 transition-all shadow-sm cursor-pointer whitespace-nowrap"
          >
            <Plus className="h-3.5 w-3.5" /> Raise Issue
          </button>
        )}

        <span className="ml-auto text-xs text-muted-foreground font-medium whitespace-nowrap">
          {filtered.length} {filtered.length === 1 ? "task" : "tasks"}
        </span>
      </header>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground border-b border-border">
            <tr>
              <th className="px-3 py-2 font-bold">Task</th>
              <th className="px-3 py-2 font-bold">Project</th>
              <th className="px-3 py-2 font-bold">Priority</th>
              <th className="px-3 py-2 font-bold">Due Date</th>
              <th className="px-3 py-2 font-bold">Status</th>
              <th className="px-3 py-2 font-bold">Assigned By</th>
              {canViewTimer && <th className="px-3 py-2 font-bold">Actions & Timer</th>}
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {filtered.map((r) => (
              <BucketListRow key={r.assignmentId} r={r} canViewTimer={canViewTimer} onAction={triggerRefresh} />
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={canViewTimer ? 7 : 6} className="px-3 py-10 text-center text-sm text-muted-foreground">
                  {loading ? "Loading bucket tasks…" : "No tasks match your filters"}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Raise Issue Modal */}
      {showRaiseModal && (
        <Modal title="Raise Issue" onClose={() => setShowRaiseModal(false)} draggable>
          <div className="space-y-3">
            <Field label="Project">
              <select
                value={formData.projectId || availableProjects[0]?.id || ""}
                onChange={(e) => setFormData((s) => ({ ...s, projectId: e.target.value }))}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                {availableProjects.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name} {p.projectCode ? `(${p.projectCode})` : ""}
                  </option>
                ))}
              </select>
            </Field>
            <Field label="Issue Title">
              <input
                value={formData.title}
                onChange={(e) => setFormData((s) => ({ ...s, title: e.target.value }))}
                placeholder="Brief summary..."
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </Field>
            <Field label="Description">
              <textarea
                value={formData.description}
                onChange={(e) => setFormData((s) => ({ ...s, description: e.target.value }))}
                placeholder="Detailed description..."
                rows={3}
                className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </Field>
            <Field label="Issue Type">
              <select
                value={formData.category}
                onChange={(e) => setFormData((s) => ({ ...s, category: e.target.value as IssueCategory }))}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                {(["Technical Related Issues", "Behavioral Related Issues", "Process Related Issues"] as IssueCategory[]).map((cat) => (
                  <option key={cat} value={cat}>
                    {cat}
                  </option>
                ))}
              </select>
            </Field>
            <Field label="Priority">
              <select
                value={formData.priority}
                onChange={(e) => setFormData((s) => ({ ...s, priority: e.target.value as DhPriority }))}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                {(["Low", "Medium", "High", "Critical"] as DhPriority[]).map((pri) => (
                  <option key={pri} value={pri}>
                    {pri}
                  </option>
                ))}
              </select>
            </Field>
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button
                onClick={() => setShowRaiseModal(false)}
                className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent"
              >
                Cancel
              </button>
              <button
                onClick={handleSubmitIssue}
                className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
              >
                Raise Issue
              </button>
            </div>
          </div>
        </Modal>
      )}
    </section>
  );
}

// ---------- Approvals ----------
function ApprovalsTab() {
  const store = useDhStore((s) => s);
  const [dbApprovals, setDbApprovals] = useState<ApprovalApiItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [selectedAppId, setSelectedAppId] = useState<string | null>(null);
  const [appComment, setAppComment] = useState("");
  const [projectFilter, setProjectFilter] = useState("all");
  const [typeFilter, setTypeFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");
  const { user, isBO, isDhanshree, isAdmin } = useRoleContext();
  const { hasPermission } = usePermissions();

  const canManageApprovals =
    isAdmin ||
    isDhanshree ||
    hasPermission("approvals.manage") ||
    hasPermission("action-center.approvals.manage") ||
    hasPermission("Action Center|Approvals:manage");

  const loadApprovals = useCallback(async () => {
    try {
      setLoading(true);
      const res = await fetchApprovals();
      if (res?.items) {
        setDbApprovals(res.items);
      }
    } catch (err) {
      console.warn("Failed to fetch approvals from backend", err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadApprovals();
  }, [loadApprovals]);

  const approvalTypes = [
    "Scope Change Approval",
    "Leadership Change Approval",
    "Timeline Extension Approval",
    "Resource Allocation Approval",
    "Profile Changes",
    "Certification Validation",
    "WBS Approval",
    "Budget Approval",
    "PM Assignment Approval",
    "SPM Assignment Approval",
    "Project Ready To Start Approval",
    "Customer Requirement Approval",
  ];

  // Merge database approvals into a single unified list
  const mergedApprovals = useMemo(() => {
    const list: (DhCentralApproval & { dbItem?: ApprovalApiItem })[] = store.approvals.map((a) => ({ ...a }));
    for (const d of dbApprovals) {
      if (!list.some((x) => x.id === d.requestCode || x.id === d.id)) {
        let reqType: DhCentralApproval["requestType"] = "WBS Approval";
        if (d.approvalType === "ScopeChange" || d.approvalType.includes("Scope")) reqType = "Scope Change Approval";
        else if (d.approvalType === "LeadershipChange" || d.approvalType.includes("Leadership")) reqType = "Leadership Change Approval";
        else if (d.approvalType === "ProjectExtension" || d.approvalType.includes("Extension")) reqType = "Timeline Extension Approval";
        else if (d.approvalType === "ResourceAllocation") reqType = "Resource Allocation Approval";
        else if (d.approvalType === "ProfileChanges" || d.approvalType === "CertificationValidation") reqType = "Customer Requirement Approval";

        list.push({
          id: d.requestCode || d.id,
          projectId: d.projectId || "p1",
          projectName: d.projectName || "General Project",
          requestType: reqType,
          requestedBy: d.requestedByName,
          requestedById: d.requestedByEmployeeId,
          requestedDate: d.createdAtUtc.slice(0, 10),
          status: (d.status === "Approved" ? "Approved" : d.status === "Rejected" ? "Rejected" : d.status === "RequestChanges" ? "Request Changes" : d.status === "Hold" ? "Hold" : "Pending"),
          description: d.description,
          comments: d.decisionNotes ? [{ id: "c1", authorId: d.decidedByName || "Approver", authorName: d.decidedByName || "Approver", text: d.decisionNotes, at: d.decidedAtUtc || d.createdAtUtc }] : [],
          history: (d.auditHistory || []).map((h) => ({
            status: (h.action === "Approved" ? "Approved" : h.action === "Rejected" ? "Rejected" : "Pending") as any,
            at: h.timestampUtc,
            updatedBy: h.actorName || "System",
            comment: h.details || "",
          })),
          refId: d.id,
          dbItem: d,
        });
      }
    }
    return list;
  }, [store.approvals, dbApprovals]);

  const selectedApproval = useMemo(() => {
    return mergedApprovals.find((a) => a.id === selectedAppId);
  }, [mergedApprovals, selectedAppId]);

  const filteredApprovals = useMemo(() => {
    return mergedApprovals.filter((a) => {
      if (projectFilter !== "all" && a.projectId !== projectFilter) return false;
      if (typeFilter !== "all") {
        const matchesExact = a.requestType === typeFilter;
        const matchesDb = a.dbItem?.approvalType === typeFilter;
        const matchesScope = typeFilter === "Scope Change Approval" && (a.requestType === "Scope Change Approval" || a.dbItem?.approvalType === "ScopeChange");
        const matchesLdr = typeFilter === "Leadership Change Approval" && (a.requestType === "Leadership Change Approval" || a.dbItem?.approvalType === "LeadershipChange");
        const matchesExt = typeFilter === "Timeline Extension Approval" && (a.requestType === "Timeline Extension Approval" || a.dbItem?.approvalType === "ProjectExtension");
        if (!matchesExact && !matchesDb && !matchesScope && !matchesLdr && !matchesExt) return false;
      }
      if (statusFilter !== "all" && a.status !== statusFilter) return false;
      return true;
    });
  }, [mergedApprovals, projectFilter, typeFilter, statusFilter]);

  const handleAction = async (status: DhCentralApproval["status"]) => {
    if (!selectedAppId) return;
    if (!appComment.trim()) {
      toast.error("Comments are mandatory for every central approval action!");
      return;
    }
    const dbItem = dbApprovals.find((d) => d.requestCode === selectedAppId || d.id === selectedAppId);
    if (dbItem) {
      try {
        const actionPayload = status === "Approved" ? "Approve" : status === "Rejected" ? "Reject" : status === "Request Changes" ? "RequestChanges" : "Hold";
        await submitApprovalAction(dbItem.id, actionPayload, appComment);
      } catch (err) {
        console.warn("Backend action error", err);
      }
    }
    dhStore.updateCentralApprovalStatus(selectedAppId, status, appComment, user.name, user.id);
    toast.success(`Success: Approval Request marked as ${status}!`);
    setAppComment("");
    setSelectedAppId(null);
    loadApprovals();
  };

  const handleAcknowledge = (appId: string) => {
    dhStore.acknowledgeCentralApproval(appId);
    toast.success("Decision Acknowledged Persistently!");
  };

  return (
    <section className="rounded-xl border border-border bg-card shadow-sm">
      <header className="border-b border-border p-4 space-y-3">
        <div className="flex items-center gap-2">
          <ShieldAlert className="h-4.5 w-4.5 text-primary" />
          <h3 className="text-sm font-semibold">Central Approval Center</h3>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-2 text-xs">
          <div className="flex flex-col gap-1">
            <span className="text-[10px] font-semibold text-muted-foreground uppercase">
              Project
            </span>
            <select
              value={projectFilter}
              onChange={(e) => setProjectFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card"
            >
              <option value="all">All Projects</option>
              {allProjects().map((p) => (
                <option key={p.id} value={p.id}>
                  {p.name}
                </option>
              ))}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <span className="text-[10px] font-semibold text-muted-foreground uppercase">
              Request Type
            </span>
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card"
            >
              <option value="all">All Request Types</option>
              {approvalTypes.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>
          <div className="flex flex-col gap-1">
            <span className="text-[10px] font-semibold text-muted-foreground uppercase">
              Status
            </span>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card"
            >
              <option value="all">All Statuses</option>
              {(["Pending", "Approved", "Rejected", "Hold", "Request Changes"] as const).map(
                (s) => (
                  <option key={s} value={s}>
                    {s}
                  </option>
                ),
              )}
            </select>
          </div>
        </div>
      </header>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium">Approval ID</th>
              <th className="px-3 py-2 font-medium">Project</th>
              <th className="px-3 py-2 font-medium">Request Type</th>
              <th className="px-3 py-2 font-medium">Requested By</th>
              <th className="px-3 py-2 font-medium">Date</th>
              <th className="px-3 py-2 font-medium">Status</th>
              <th className="px-3 py-2 font-medium text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {filteredApprovals.map((app) => (
              <tr key={app.id} className="hover:bg-accent/30">
                <td className="px-3 py-2.5 font-mono text-xs font-bold text-gray-800">{app.id}</td>
                <td className="px-3 py-2.5 font-medium text-gray-700">{app.projectName}</td>
                <td className="px-3 py-2.5 text-xs text-primary font-semibold">
                  {app.requestType}
                </td>
                <td className="px-3 py-2.5">
                  <div className="flex items-center gap-2">
                    <Avatar name={app.requestedBy} size={20} />
                    <span className="text-xs">{app.requestedBy}</span>
                  </div>
                </td>
                <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">
                  {new Date(app.requestedDate).toLocaleDateString()}
                </td>
                <td className="px-3 py-2.5">
                  <span
                    className={cn(
                      "inline-flex rounded-full border px-2 py-0.5 text-[10px] font-medium capitalize",
                      app.status === "Approved"
                        ? "bg-success/10 text-success border-success/30"
                        : app.status === "Rejected"
                          ? "bg-destructive/10 text-destructive border-destructive/30"
                          : app.status === "Hold"
                            ? "bg-warning/15 text-warning-foreground border-warning/30"
                            : app.status === "Request Changes"
                              ? "bg-info/10 text-info border-info/30"
                              : "bg-muted text-muted-foreground border-border",
                    )}
                  >
                    {app.status}
                  </span>
                </td>
                <td className="px-3 py-2.5 text-right space-x-1 whitespace-nowrap">
                  <button
                    onClick={() => setSelectedAppId(app.id)}
                    className="rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent font-medium text-primary"
                  >
                    View
                  </button>
                  {app.status !== "Pending" && !app.acknowledgedAt && canManageApprovals && (
                    <button
                      onClick={() => handleAcknowledge(app.id)}
                      className="inline-flex items-center gap-1 rounded-md border border-success/30 bg-success/10 px-2.5 py-1 text-xs font-semibold text-success hover:bg-success/20"
                    >
                      <Check className="h-3 w-3" /> Acknowledge
                    </button>
                  )}
                  {app.acknowledgedAt && (
                    <span className="text-[10px] font-medium text-success pl-1 inline-flex items-center gap-0.5">
                      <CheckCircle2 className="h-3 w-3 inline" /> Acked
                    </span>
                  )}
                </td>
              </tr>
            ))}
            {filteredApprovals.length === 0 && (
              <tr>
                <td colSpan={7} className="px-3 py-10 text-center text-sm text-muted-foreground">
                  No approvals found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {selectedApproval && (
        <Modal
          title={`Review Request — ${selectedApproval.id}`}
          onClose={() => setSelectedAppId(null)}
          wide
          draggable
        >
          <div className="space-y-4">
            <div className="bg-muted/30 border border-border rounded-lg p-3 text-xs leading-relaxed grid grid-cols-2 md:grid-cols-4 gap-3">
              <div>
                <span className="text-muted-foreground">Project Link</span>
                <p className="font-medium text-primary hover:underline">
                  <Link
                    to="/projects/$projectId"
                    params={{ projectId: selectedApproval.projectId }}
                  >
                    {selectedApproval.projectName}
                  </Link>
                </p>
              </div>
              <div>
                <span className="text-muted-foreground">Requested By</span>
                <p className="font-semibold">{selectedApproval.requestedBy}</p>
              </div>
              <div>
                <span className="text-muted-foreground">Submitted On</span>
                <p className="font-medium">{selectedApproval.requestedDate}</p>
              </div>
              <div>
                <span className="text-muted-foreground">Request Type</span>
                <p className="font-bold text-xs text-primary">{selectedApproval.requestType}</p>
              </div>
            </div>

            <div className="rounded-lg border border-border p-3 bg-card space-y-1.5">
              <span className="text-xs font-bold text-muted-foreground uppercase">
                Description & Justification
              </span>
              <p className="text-sm text-gray-800 leading-relaxed font-medium">
                {selectedApproval.description}
              </p>
            </div>

            {selectedApproval.dbItem?.payloadJson && selectedApproval.dbItem.payloadJson !== "{}" && (
              <div className="rounded-lg border border-border p-3 bg-muted/20 space-y-2">
                <span className="text-xs font-bold text-muted-foreground uppercase">
                  Technical Parameters & Proposed Changes
                </span>
                {(() => {
                  try {
                    const p = JSON.parse(selectedApproval.dbItem.payloadJson);
                    return (
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-2 text-xs">
                        {p.scopeAction && (
                          <div className="p-2 rounded bg-card border border-border">
                            <span className="text-muted-foreground block text-[10px] uppercase font-semibold">Scope Action</span>
                            <span className="font-bold text-primary">{p.scopeAction}</span>
                          </div>
                        )}
                        {(p.serviceName || p.scopeTitle) && (
                          <div className="p-2 rounded bg-card border border-border">
                            <span className="text-muted-foreground block text-[10px] uppercase font-semibold">Target Service / Item</span>
                            <span className="font-medium text-foreground">{p.serviceName || p.scopeTitle}</span>
                          </div>
                        )}
                        {p.leadershipRole && (
                          <div className="p-2 rounded bg-card border border-border">
                            <span className="text-muted-foreground block text-[10px] uppercase font-semibold">Designated Role</span>
                            <span className="font-bold text-primary">{p.leadershipRole}</span>
                          </div>
                        )}
                        {(p.targetEmployeeName || p.newLeaderNames) && (
                          <div className="p-2 rounded bg-card border border-border">
                            <span className="text-muted-foreground block text-[10px] uppercase font-semibold">New Assigned Leader(s)</span>
                            <span className="font-medium text-foreground">{p.targetEmployeeName || (Array.isArray(p.newLeaderNames) ? p.newLeaderNames.join(", ") : p.newLeaderNames)}</span>
                          </div>
                        )}
                        {p.effectiveDate && (
                          <div className="p-2 rounded bg-card border border-border">
                            <span className="text-muted-foreground block text-[10px] uppercase font-semibold">Effective Date</span>
                            <span className="font-medium text-foreground">{p.effectiveDate}</span>
                          </div>
                        )}
                        {p.proposedEndDate && (
                          <div className="p-2 rounded bg-card border border-border">
                            <span className="text-muted-foreground block text-[10px] uppercase font-semibold">Proposed End Date</span>
                            <span className="font-bold text-primary">{p.proposedEndDate}</span>
                          </div>
                        )}
                        {p.daysExtended !== undefined && (
                          <div className="p-2 rounded bg-card border border-border">
                            <span className="text-muted-foreground block text-[10px] uppercase font-semibold">Days Extended</span>
                            <span className="font-semibold text-foreground">+{p.daysExtended} days</span>
                          </div>
                        )}
                        {p.reason && (
                          <div className="p-2 rounded bg-card border border-border col-span-full">
                            <span className="text-muted-foreground block text-[10px] uppercase font-semibold">Justification / Reason</span>
                            <span className="text-foreground">{p.reason}</span>
                          </div>
                        )}
                      </div>
                    );
                  } catch {
                    return null;
                  }
                })()}
              </div>
            )}

            {selectedApproval.comments.length > 0 && (
              <div className="rounded-lg border border-border bg-card p-3 space-y-2">
                <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">
                  Discussion & Audit Log History
                </span>
                <div className="space-y-2 max-h-40 overflow-y-auto pl-1">
                  {selectedApproval.history.map((h, idx) => (
                    <div
                      key={idx}
                      className="text-xs border-l-2 border-primary pl-2 py-0.5 bg-muted/10 rounded-sm"
                    >
                      <div className="flex justify-between text-muted-foreground text-[10px]">
                        <span>
                          Status:{" "}
                          <strong className="text-gray-700 font-semibold">{h.status}</strong> by{" "}
                          {h.updatedBy}
                        </span>
                        <span>{new Date(h.at).toLocaleString()}</span>
                      </div>
                      {h.comment && <p className="text-gray-800 mt-0.5">"{h.comment}"</p>}
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Requester Acknowledge State */}
            {selectedApproval.acknowledgedAt && (
              <div className="rounded-lg border border-success/30 bg-success/10 p-3 text-xs text-success flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4" />
                <span>
                  This decision was acknowledged by the requester on{" "}
                  <strong>{new Date(selectedApproval.acknowledgedAt).toLocaleString()}</strong>.
                </span>
              </div>
            )}

            {/* Mandatory Comment box */}
            {selectedApproval.status === "Pending" && canManageApprovals && (
              <div className="space-y-2 border-t border-border pt-3">
                <label className="text-xs font-semibold text-gray-700 block">
                  Action Comments / Clarifications / Instructions{" "}
                  <span className="text-destructive font-bold">*Mandatory</span>
                </label>
                <textarea
                  value={appComment}
                  onChange={(e) => setAppComment(e.target.value)}
                  placeholder="Provide detailed instructions, clarification request, or reasons..."
                  rows={3}
                  className="w-full rounded-md border border-input bg-card p-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border"
                />
              </div>
            )}

            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button
                onClick={() => setSelectedAppId(null)}
                className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
              >
                Close
              </button>
              {selectedApproval.status === "Pending" && canManageApprovals && (
                <>
                  <button
                    onClick={() => handleAction("Hold")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md border border-warning/30 bg-warning/10 px-4 py-2 text-xs font-medium text-warning-foreground hover:bg-warning/20 disabled:opacity-50"
                  >
                    Hold
                  </button>
                  <button
                    onClick={() => handleAction("Request Changes")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md border border-info/30 bg-info/10 px-4 py-2 text-xs font-medium text-info hover:bg-info/20 disabled:opacity-50"
                  >
                    Request Changes
                  </button>
                  <button
                    onClick={() => handleAction("Rejected")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md border border-destructive/30 bg-destructive/10 px-4 py-2 text-xs font-medium text-destructive hover:bg-destructive/20 disabled:opacity-50"
                  >
                    Reject
                  </button>
                  <button
                    onClick={() => handleAction("Approved")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md bg-primary px-4 py-2 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
                  >
                    Approve
                  </button>
                </>
              )}
            </div>
          </div>
        </Modal>
      )}
    </section>
  );
}

// ---------- Alerts ----------
function MetricCard({ label, value, color }: { label: string; value: number; color: string }) {
  return (
    <div
      className={cn("rounded-lg border p-3 flex flex-col justify-between shadow-xs bg-card", color)}
    >
      <span className="text-[10px] font-bold uppercase tracking-wider opacity-85">{label}</span>
      <span className="text-xl font-extrabold tracking-tight mt-1">{value}</span>
    </div>
  );
}

function AlertsTab() {
  const [alerts, setAlerts] = useState<AlertApiItem[]>([]);
  const [metrics, setMetrics] = useState<AlertMetricsApi>({
    total: 0,
    open: 0,
    critical: 0,
    resolved: 0,
    escalated: 0,
  });
  const [selectedAlert, setSelectedAlert] = useState<AlertApiItem | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isScanning, setIsScanning] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Filters
  const [searchFilter, setSearchFilter] = useState("");
  const [projFilter, setProjFilter] = useState("all");
  const [prioFilter, setPrioFilter] = useState("all");
  const [categoryFilter, setCategoryFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");

  // Modal action states
  const [ackNotes, setAckNotes] = useState("");
  const [resDetails, setResDetails] = useState("");

  const { user, isDhanshree, isAdmin } = useRoleContext();
  const { hasPermission } = usePermissions();

  const canManageAlerts =
    isAdmin ||
    isDhanshree ||
    hasPermission("action-center.alerts.manage") ||
    hasPermission("Action Center|Alerts:manage");

  // Real database project options loaded from PostgreSQL
  const [projectOptions, setProjectOptions] = useState<IssueProjectOption[]>([]);

  useEffect(() => {
    fetchIssueProjectOptionsApi()
      .then((opts) => {
        if (Array.isArray(opts)) setProjectOptions(opts);
      })
      .catch((err) => console.warn("Could not load project options for alerts filter", err));
  }, []);

  const availableProjects = useMemo(() => {
    const map = new Map<string, string>();
    // 1. Real projects loaded from backend database API
    projectOptions.forEach((p) => {
      if (p.id) map.set(p.id, p.name);
    });
    // 2. Also incorporate projects directly referenced in live alerts
    alerts.forEach((a) => {
      if (a.projectId && !map.has(a.projectId)) {
        map.set(a.projectId, a.projectName || "Assigned Project");
      }
    });
    return Array.from(map.entries())
      .map(([id, name]) => ({ id, name }))
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [projectOptions, alerts]);

  const loadAlertData = useCallback(async () => {
    setIsLoading(true);
    try {
      const [alertsRes, metricsRes] = await Promise.all([
        fetchAlertsApi({ perPage: 100 }),
        fetchAlertMetricsApi(),
      ]);
      setAlerts(alertsRes.items || []);
      setMetrics(metricsRes);
    } catch (err) {
      console.error("Failed to load alerts from backend:", err);
      toast.error("Could not load alerts from backend server.");
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadAlertData();
  }, [loadAlertData]);

  const handleTriggerScan = async () => {
    setIsScanning(true);
    try {
      const result = await triggerAlertScanApi();
      toast.success("SLA & TAT scan complete", {
        description: `${result.scannedCount} new/updated breach alerts processed.`,
      });
      await loadAlertData();
    } catch (err) {
      toast.error("Failed to execute alert evaluation scan.");
    } finally {
      setIsScanning(false);
    }
  };

  const handleAcknowledge = async () => {
    if (!selectedAlert) return;
    setIsSubmitting(true);
    try {
      const updated = await acknowledgeAlertApi(selectedAlert.id, ackNotes);
      toast.success("Alert acknowledged successfully", { description: updated.alertCode });
      setSelectedAlert(updated);
      setAckNotes("");
      await loadAlertData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to acknowledge alert");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleResolve = async () => {
    if (!selectedAlert || !resDetails.trim()) {
      toast.error("Please provide resolution details before resolving.");
      return;
    }
    setIsSubmitting(true);
    try {
      const updated = await resolveAlertApi(selectedAlert.id, resDetails.trim());
      toast.success("Alert marked as resolved", { description: updated.alertCode });
      setSelectedAlert(updated);
      setResDetails("");
      await loadAlertData();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to resolve alert");
    } finally {
      setIsSubmitting(false);
    }
  };

  const categoryLabels: Record<string, string> = {
    DeliveryTatBreach: "Delivery TAT / SLA",
    EscalationTatBreach: "Escalation & Issues SLA",
    ChangeManagementTatBreach: "Change Management SLA",
    DailyOnBenchCount: "Daily On-Bench Count",
    TimesheetTatBreach: "Timesheet SLA Breach",
  };

  const filteredAlerts = useMemo(() => {
    return alerts.filter((a) => {
      if (searchFilter.trim()) {
        const q = searchFilter.toLowerCase();
        const match =
          a.alertCode.toLowerCase().includes(q) ||
          a.title.toLowerCase().includes(q) ||
          (a.projectName && a.projectName.toLowerCase().includes(q)) ||
          (a.triggerCondition && a.triggerCondition.toLowerCase().includes(q)) ||
          (a.ownerName && a.ownerName.toLowerCase().includes(q));
        if (!match) return false;
      }
      if (projFilter !== "all" && a.projectId !== projFilter) return false;
      if (prioFilter !== "all" && a.severity !== prioFilter) return false;
      if (categoryFilter !== "all" && a.category !== categoryFilter) return false;
      if (statusFilter !== "all" && a.status !== statusFilter) return false;
      return true;
    });
  }, [alerts, searchFilter, projFilter, prioFilter, categoryFilter, statusFilter]);

  return (
    <>
      {/* Metrics Dashboard Grid */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-3 mb-4">
        <MetricCard
          label="Total Alerts"
          value={metrics.total}
          color="bg-blue-50 text-blue-700 border-blue-200"
        />
        <MetricCard
          label="Open Alerts"
          value={metrics.open}
          color="bg-orange-50 text-orange-700 border-orange-200"
        />
        <MetricCard
          label="Critical Alerts"
          value={metrics.critical}
          color="bg-red-50 text-red-700 border-red-200"
        />
        <MetricCard
          label="Resolved Alerts"
          value={metrics.resolved}
          color="bg-green-50 text-green-700 border-green-200"
        />
        <MetricCard
          label="Escalated Alerts"
          value={metrics.escalated}
          color="bg-purple-50 text-purple-700 border-purple-200"
        />
      </div>

      <section className="rounded-xl border border-border bg-card shadow-sm">
        {/* Action Header & Filters */}
        <header className="border-b border-border p-4 space-y-3">
          {canManageAlerts && (
            <div className="flex justify-end">
              <button
                onClick={handleTriggerScan}
                disabled={isScanning}
                className="inline-flex items-center gap-1.5 rounded-lg border border-primary/20 bg-primary/10 px-3 py-1.5 text-xs font-semibold text-primary hover:bg-primary/20 transition-colors disabled:opacity-50"
                title="Run real-time SLA breach evaluation scan across all BRD categories"
              >
                <RotateCcw className={cn("h-3.5 w-3.5", isScanning && "animate-spin")} />
                <span>{isScanning ? "Scanning..." : "Scan SLA Rules"}</span>
              </button>
            </div>
          )}

          <div className="grid grid-cols-2 md:grid-cols-5 gap-2.5 text-xs pt-1">
              <div className="flex flex-col gap-1">
                <span className="text-[10px] font-bold text-muted-foreground uppercase">Search</span>
                <div className="relative">
                  <Search className="absolute left-2 top-2 h-3.5 w-3.5 text-muted-foreground" />
                  <input
                    type="text"
                    value={searchFilter}
                    onChange={(e) => setSearchFilter(e.target.value)}
                    placeholder="Search code, title, owner..."
                    className="w-full form-input rounded-md border border-border pl-7 pr-2 py-1.5 text-xs bg-card"
                  />
                </div>
              </div>

              <div className="flex flex-col gap-1">
                <span className="text-[10px] font-bold text-muted-foreground uppercase">Category</span>
                <select
                  value={categoryFilter}
                  onChange={(e) => setCategoryFilter(e.target.value)}
                  className="form-input rounded-md border border-border p-1.5 bg-card"
                >
                  <option value="all">All Categories</option>
                  <option value="DeliveryTatBreach">Delivery TAT / SLA</option>
                  <option value="EscalationTatBreach">Escalation & Issues SLA</option>
                  <option value="ChangeManagementTatBreach">Change Management SLA</option>
                  <option value="DailyOnBenchCount">Daily On-Bench Count</option>
                  <option value="TimesheetTatBreach">Timesheet SLA Breach</option>
                </select>
              </div>

              <div className="flex flex-col gap-1">
                <span className="text-[10px] font-bold text-muted-foreground uppercase">Severity</span>
                <select
                  value={prioFilter}
                  onChange={(e) => setPrioFilter(e.target.value)}
                  className="form-input rounded-md border border-border p-1.5 bg-card"
                >
                  <option value="all">All Severities</option>
                  <option value="Critical">Critical</option>
                  <option value="High">High</option>
                  <option value="Medium">Medium</option>
                  <option value="Low">Low</option>
                </select>
              </div>

              <div className="flex flex-col gap-1">
                <span className="text-[10px] font-bold text-muted-foreground uppercase">Project</span>
                <select
                  value={projFilter}
                  onChange={(e) => setProjFilter(e.target.value)}
                  className="form-input rounded-md border border-border p-1.5 bg-card"
                >
                  <option value="all">All Projects</option>
                  {availableProjects.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="flex flex-col gap-1">
                <span className="text-[10px] font-bold text-muted-foreground uppercase">Status</span>
                <select
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                  className="form-input rounded-md border border-border p-1.5 bg-card"
                >
                  <option value="all">All Statuses</option>
                  <option value="Open">Open</option>
                  <option value="Acknowledged">Acknowledged</option>
                  <option value="InProgress">In Progress</option>
                  <option value="Resolved">Resolved</option>
                  <option value="Closed">Closed</option>
                </select>
              </div>
          </div>
        </header>
            {isLoading ? (
              <div className="p-12 text-center text-xs text-muted-foreground">
                <RotateCcw className="mx-auto h-5 w-5 animate-spin text-primary mb-2" />
                Loading alerts from PostgreSQL database...
              </div>
            ) : filteredAlerts.length === 0 ? (
              <div className="p-12 text-center">
                <ShieldAlert className="mx-auto h-8 w-8 text-muted-foreground/50 mb-2" />
                <p className="text-sm font-medium text-foreground">No alerts matching active filters</p>
                <p className="text-xs text-muted-foreground mt-1">
                  Click "Scan SLA Rules" to trigger an automated breach evaluation.
                </p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
                    <tr>
                      <th className="px-3 py-2 font-medium">Alert Code</th>
                      <th className="px-3 py-2 font-medium">Alert Title</th>
                      <th className="px-3 py-2 font-medium">Category</th>
                      <th className="px-3 py-2 font-medium">Severity</th>
                      <th className="px-3 py-2 font-medium">Trigger Condition</th>
                      <th className="px-3 py-2 font-medium">Project / Target</th>
                      <th className="px-3 py-2 font-medium">Owner / Assignee</th>
                      <th className="px-3 py-2 font-medium">Raised Date</th>
                      <th className="px-3 py-2 font-medium">Status</th>
                      <th className="px-3 py-2 font-medium text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {filteredAlerts.map((alert) => (
                      <tr key={alert.id} className="hover:bg-accent/30 transition-colors">
                        <td className="px-3 py-2.5 font-mono text-xs font-bold text-foreground whitespace-nowrap">
                          {alert.alertCode}
                        </td>
                        <td className="px-3 py-2.5 font-medium text-foreground max-w-xs truncate" title={alert.title}>
                          {alert.title}
                        </td>
                        <td className="px-3 py-2.5 whitespace-nowrap">
                          <span className="inline-flex rounded-full border border-border bg-muted/60 px-2 py-0.5 text-[10px] font-semibold text-foreground">
                            {categoryLabels[alert.category] || alert.category}
                          </span>
                        </td>
                        <td className="px-3 py-2.5 whitespace-nowrap">
                          <PriorityPill priority={alert.severity.toLowerCase() as any} />
                        </td>
                        <td className="px-3 py-2.5 text-xs text-muted-foreground max-w-xs truncate" title={alert.triggerCondition}>
                          {alert.triggerCondition}
                        </td>
                        <td className="px-3 py-2.5 text-xs text-muted-foreground whitespace-nowrap">
                          {alert.projectName || "—"}
                        </td>
                        <td className="px-3 py-2.5 text-xs font-medium whitespace-nowrap">
                          {alert.ownerName || "PMO Engine"}
                        </td>
                        <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground whitespace-nowrap">
                          {new Date(alert.createdAtUtc).toLocaleDateString()}
                        </td>
                        <td className="px-3 py-2.5 whitespace-nowrap">
                          <span
                            className={cn(
                              "inline-flex rounded-full border px-2 py-0.5 text-[10px] font-semibold",
                              alert.status === "Open"
                                ? "bg-orange-50 text-orange-700 border-orange-200"
                                : alert.status === "Acknowledged"
                                  ? "bg-amber-50 text-amber-700 border-amber-200"
                                  : alert.status === "InProgress"
                                    ? "bg-blue-50 text-blue-700 border-blue-200"
                                    : alert.status === "Resolved" || alert.status === "Closed"
                                      ? "bg-green-50 text-green-700 border-green-200"
                                      : "bg-muted text-muted-foreground border-border",
                            )}
                          >
                            {alert.status}
                          </span>
                        </td>
                        <td className="px-3 py-2.5 text-right whitespace-nowrap">
                          <button
                            onClick={() => {
                              setSelectedAlert(alert);
                              setAckNotes("");
                              setResDetails(alert.resolutionDetails || "");
                            }}
                            className="rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent font-medium text-primary shadow-2xs"
                          >
                            Review details
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
      </section>

      {/* Alert Details & Action Modal */}
      {selectedAlert && (
        <Modal
          title={`Alert Details — ${selectedAlert.alertCode}`}
          onClose={() => setSelectedAlert(null)}
          wide
          draggable
        >
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            {/* Left side details */}
            <div className="md:col-span-2 space-y-4">
              <div className="rounded-lg border border-border p-3 bg-muted/10 space-y-1">
                <div className="flex items-center justify-between">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase">
                    Alert Title
                  </span>
                  <span className="inline-flex rounded-full border px-2 py-0.5 text-[10px] font-bold bg-muted text-foreground">
                    {categoryLabels[selectedAlert.category] || selectedAlert.category}
                  </span>
                </div>
                <p className="text-sm font-bold text-foreground">{selectedAlert.title}</p>
              </div>

              <div className="bg-muted/30 border border-border rounded-lg p-3 grid grid-cols-2 gap-3">
                <div>
                  <span className="text-[9px] uppercase font-bold text-muted-foreground block">
                    Trigger Condition
                  </span>
                  <span className="font-semibold text-primary">{selectedAlert.triggerCondition}</span>
                </div>
                <div>
                  <span className="text-[9px] uppercase font-bold text-muted-foreground block">
                    Severity / Priority
                  </span>
                  <PriorityPill priority={selectedAlert.severity.toLowerCase() as any} />
                </div>
                <div>
                  <span className="text-[9px] uppercase font-bold text-muted-foreground block">
                    Source Entity
                  </span>
                  <span className="font-semibold text-foreground">
                    {selectedAlert.sourceEntity} ({selectedAlert.sourceEntityId?.slice(0, 8)}...)
                  </span>
                </div>
                <div>
                  <span className="text-[9px] uppercase font-bold text-muted-foreground block">
                    Owner / Responsible
                  </span>
                  <span className="font-semibold text-foreground">
                    {selectedAlert.ownerName || "PMO"}
                  </span>
                </div>
              </div>

              <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">
                  Full Breach Description
                </span>
                <p className="text-xs text-foreground leading-relaxed font-medium">
                  {selectedAlert.description}
                </p>
              </div>

              {selectedAlert.resolutionDetails && (
                <div className="rounded-lg border border-emerald-200 bg-emerald-50/50 p-3 space-y-1">
                  <span className="font-semibold text-[10px] text-emerald-800 uppercase block">
                    Resolution Notes (Resolved by {selectedAlert.resolvedByName || "User"})
                  </span>
                  <p className="text-xs text-emerald-950 font-medium">{selectedAlert.resolutionDetails}</p>
                </div>
              )}

              {/* Status Transitions Audit History */}
              {selectedAlert.auditHistory && selectedAlert.auditHistory.length > 0 && (
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">
                    Audit & Transition Log
                  </span>
                  <div className="space-y-1.5 pl-1 max-h-36 overflow-y-auto">
                    {selectedAlert.auditHistory.map((h, idx) => (
                      <div key={idx} className="flex items-start gap-2 text-[10px]">
                        <span className="text-muted-foreground tabular-nums whitespace-nowrap">
                          {new Date(h.timestampUtc).toLocaleDateString()}{" "}
                          {new Date(h.timestampUtc).toLocaleTimeString([], {
                            hour: "2-digit",
                            minute: "2-digit",
                          })}
                        </span>
                        <div>
                          <strong className="text-foreground">{h.action}</strong> by{" "}
                          <span className="font-medium text-foreground">{h.actorName || "System"}</span>
                          {h.details && <span className="text-muted-foreground"> — {h.details}</span>}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Right side actions */}
            <div className="space-y-4 flex flex-col justify-between">
              <div className="space-y-3">
                <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">
                    Current Status
                  </span>
                  <div
                    className={cn(
                      "w-full rounded-md border p-2 text-xs font-bold text-center",
                      selectedAlert.status === "Open"
                        ? "bg-orange-50 border-orange-200 text-orange-700"
                        : selectedAlert.status === "Acknowledged"
                          ? "bg-amber-50 border-amber-200 text-amber-700"
                          : selectedAlert.status === "InProgress"
                            ? "bg-blue-50 border-blue-200 text-blue-700"
                            : selectedAlert.status === "Resolved"
                              ? "bg-green-50 border-green-200 text-green-700"
                              : "bg-muted text-muted-foreground border-border",
                    )}
                  >
                    {selectedAlert.status}
                  </div>
                </div>

                {selectedAlert.projectId && (
                  <div className="rounded-lg border border-border p-3 bg-card space-y-2">
                    <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">
                      Target Project
                    </span>
                    <Link
                      to="/projects/$projectId"
                      params={{ projectId: selectedAlert.projectId }}
                      className="inline-flex items-center gap-1 bg-primary/10 text-primary border border-primary/20 rounded-md px-2.5 py-1.5 font-bold hover:bg-primary/20 text-xs w-full justify-between"
                    >
                      <span>{selectedAlert.projectName || "Go to project"}</span>
                      <ExternalLink className="h-3 w-3" />
                    </Link>
                  </div>
                )}

                {/* Lifecycle action controls */}
                {canManageAlerts && selectedAlert.status !== "Resolved" && selectedAlert.status !== "Closed" && (
                  <div className="rounded-lg border border-border p-3 bg-card space-y-3">
                    <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">
                      Manage Alert Lifecycle
                    </span>

                    {selectedAlert.status === "Open" && (
                      <div className="space-y-2">
                        <label className="text-[10px] font-bold text-muted-foreground block">
                          Acknowledgement Notes (Optional)
                        </label>
                        <input
                          type="text"
                          value={ackNotes}
                          onChange={(e) => setAckNotes(e.target.value)}
                          placeholder="e.g. Under active review by PM..."
                          className="w-full form-input rounded-md border border-border p-1.5 text-xs bg-card"
                        />
                        <button
                          onClick={handleAcknowledge}
                          disabled={isSubmitting}
                          className="w-full rounded-md border border-amber-300 bg-amber-50 px-3 py-1.5 text-xs font-bold text-amber-800 hover:bg-amber-100 transition-colors disabled:opacity-50"
                        >
                          {isSubmitting ? "Updating..." : "Acknowledge Alert"}
                        </button>
                      </div>
                    )}

                    <div className="space-y-2 pt-2 border-t border-border/50">
                      <label className="text-[10px] font-bold text-muted-foreground block">
                        Resolution Details (Required to Resolve)
                      </label>
                      <textarea
                        value={resDetails}
                        onChange={(e) => setResDetails(e.target.value)}
                        placeholder="Detail corrective actions taken, scope adjustments, or root cause fix..."
                        rows={3}
                        className="w-full rounded-md border border-border p-1.5 text-xs bg-card outline-none focus-visible:ring-1 focus-visible:ring-ring"
                      />
                      <button
                        onClick={handleResolve}
                        disabled={isSubmitting || !resDetails.trim()}
                        className="w-full rounded-md bg-emerald-600 px-3 py-1.5 text-xs font-bold text-white hover:bg-emerald-700 transition-colors disabled:opacity-50"
                      >
                        {isSubmitting ? "Resolving..." : "Resolve Alert"}
                      </button>
                    </div>
                  </div>
                )}
              </div>

              <div className="flex justify-end gap-2 border-t border-border pt-3">
                <button
                  onClick={() => setSelectedAlert(null)}
                  className="rounded-md border border-input bg-card px-4 py-1.5 text-xs font-medium hover:bg-accent"
                >
                  Close
                </button>
              </div>
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}

function NotificationsTab() {
  const store = useDhStore((s) => s);
  const { user, isBO, isAdmin, isDhanshree } = useRoleContext();
  const { hasAny } = usePermissions();
  const canManageApprovals =
    isAdmin ||
    isDhanshree ||
    hasAny(
      "action-center.approvals.manage",
      "approvals.manage",
      "approvals:write",
      "action-center.notifications.manage",
    ) ||
    !isBO;
  const [subTab, setSubTab] = useState<"Current" | "Archived">("Current");

  // Search state
  const [searchQuery, setSearchQuery] = useState("");

  // Filters state
  const [typeFilter, setTypeFilter] = useState("all");
  const [priorityFilter, setPriorityFilter] = useState("all");
  const [dateFilter, setDateFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");

  // Modal details state
  const [selectedNotifId, setSelectedNotifId] = useState<string | null>(null);
  const [commentText, setCommentText] = useState("");
  const [showCommentError, setShowCommentError] = useState(false);

  const notifications = store.notifications || [];

  // Metrics
  const totalCount = notifications.length;
  const pendingCount = notifications.filter((n) => n.status === "Pending").length;
  const criticalPendingCount = notifications.filter(
    (n) => n.status === "Pending" && (n.priority === "Critical" || n.priority === "High"),
  ).length;
  const archivedCount = notifications.filter((n) => n.status === "Acknowledged").length;

  // Formatting helpers matching images
  const formatNotifDate = (dateStr: string): string => {
    try {
      const d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      const day = d.getDate();
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      const month = months[d.getMonth()];
      const year = d.getFullYear();
      return `${day} ${month} ${year}`;
    } catch (e) {
      return dateStr;
    }
  };

  const formatNotifTime = (dateStr: string): string => {
    try {
      const d = new Date(dateStr);
      if (isNaN(d.getTime())) return "12:00";
      const hours = String(d.getHours()).padStart(2, "0");
      const minutes = String(d.getMinutes()).padStart(2, "0");
      return `${hours}:${minutes}`;
    } catch (e) {
      return "12:00";
    }
  };

  // Type styles helper
  const getTypeStyles = (type: string) => {
    const t = type.toLowerCase();
    if (t.includes("wbs")) {
      return "bg-orange-50 text-orange-700 border border-orange-200";
    } else if (
      t.includes("ready") ||
      t.includes("completed") ||
      t.includes("resolved") ||
      t.includes("approved")
    ) {
      return "bg-emerald-50 text-emerald-700 border border-emerald-200";
    } else if (t.includes("rejected") || t.includes("cancelled") || t.includes("removal")) {
      return "bg-red-50 text-red-700 border border-red-200";
    } else if (t.includes("changes") || t.includes("requirement") || t.includes("approval")) {
      return "bg-amber-50 text-amber-700 border border-amber-200";
    } else if (
      t.includes("interview") ||
      t.includes("shuffle") ||
      t.includes("allocation") ||
      t.includes("assignment")
    ) {
      return "bg-sky-50 text-sky-700 border border-sky-200";
    }
    return "bg-gray-50 text-gray-700 border border-gray-200";
  };

  // Filter & Search Logic
  const filteredNotifications = useMemo(() => {
    return notifications.filter((n) => {
      // 1. Sub-tab filter
      if (subTab === "Current") {
        const isCurrent = n.status === "Pending" || n.unread;
        if (!isCurrent) return false;
      } else {
        const isArchived = n.status === "Acknowledged";
        if (!isArchived) return false;
      }

      // 2. Search query filter (Project, Task, Notification Type, Employee, Title)
      if (searchQuery.trim()) {
        const query = searchQuery.toLowerCase();
        const matchesProject = n.relatedProject.toLowerCase().includes(query);
        const matchesTask = n.relatedTask ? n.relatedTask.toLowerCase().includes(query) : false;
        const matchesType = n.type.toLowerCase().includes(query);
        const matchesEmployee = n.raisedBy.toLowerCase().includes(query);
        const matchesTitle = n.title.toLowerCase().includes(query);

        if (!matchesProject && !matchesTask && !matchesType && !matchesEmployee && !matchesTitle) {
          return false;
        }
      }

      // 3. Dropdown/Inputs filters
      if (typeFilter !== "all" && n.type !== typeFilter) return false;
      if (priorityFilter !== "all" && n.priority.toLowerCase() !== priorityFilter.toLowerCase())
        return false;
      if (statusFilter !== "all" && n.status.toLowerCase() !== statusFilter.toLowerCase())
        return false;
      if (dateFilter) {
        const notifDate = n.createdAt.slice(0, 10);
        if (notifDate !== dateFilter) return false;
      }

      return true;
    });
  }, [notifications, subTab, searchQuery, typeFilter, priorityFilter, dateFilter, statusFilter]);

  const selectedNotification = useMemo(() => {
    return notifications.find((n) => n.id === selectedNotifId);
  }, [notifications, selectedNotifId]);

  const handleOpenDetails = (id: string) => {
    dhStore.markNotificationAsRead(id);
    setSelectedNotifId(id);
    setCommentText("");
    setShowCommentError(false);
  };

  const handleConfirmAcknowledge = () => {
    if (!selectedNotification) return;
    if (!commentText.trim()) {
      setShowCommentError(true);
      return;
    }
    dhStore.acknowledgeNotification(selectedNotification.id, user.name, commentText);
    toast.success("Notification Acknowledged Persistently!");
    setSelectedNotifId(null);
    setCommentText("");
    setShowCommentError(false);
  };

  const totalSubtabCount = subTab === "Current" ? pendingCount : archivedCount;

  return (
    <>
      {/* Metrics Dashboard Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
        {/* TOTAL NOTIFICATIONS */}
        <div className="rounded-xl border border-blue-200 bg-blue-50/15 p-4 flex flex-col justify-between shadow-xs">
          <span className="text-[10px] font-bold text-blue-600 uppercase tracking-wider">
            Total Notifications
          </span>
          <span className="text-2xl font-bold text-blue-900 mt-1">{totalCount}</span>
        </div>

        {/* PENDING */}
        <div className="rounded-xl border border-amber-250 bg-amber-50/15 p-4 flex flex-col justify-between shadow-xs">
          <span className="text-[10px] font-bold text-amber-600 uppercase tracking-wider">
            Pending
          </span>
          <span className="text-2xl font-bold text-amber-900 mt-1">{pendingCount}</span>
        </div>

        {/* CRITICAL PENDING */}
        <div className="rounded-xl border border-red-200 bg-red-50/15 p-4 flex flex-col justify-between shadow-xs">
          <span className="text-[10px] font-bold text-red-600 uppercase tracking-wider">
            Critical Pending
          </span>
          <span className="text-2xl font-bold text-red-900 mt-1">{criticalPendingCount}</span>
        </div>

        {/* ARCHIVED */}
        <div className="rounded-xl border border-emerald-250 bg-emerald-50/15 p-4 flex flex-col justify-between shadow-xs">
          <span className="text-[10px] font-bold text-emerald-600 uppercase tracking-wider">
            Archived
          </span>
          <span className="text-2xl font-bold text-emerald-900 mt-1">{archivedCount}</span>
        </div>
      </div>

      {/* Notification Inbox Container */}
      <div className="border border-border rounded-xl bg-card shadow-sm p-4 space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Bell className="h-5 w-5 text-primary" />
            <span className="font-bold text-gray-800 text-sm">Notification Inbox</span>
          </div>
          <span className="text-xs text-muted-foreground">
            {filteredNotifications.length} of {totalSubtabCount} shown
          </span>
        </div>

        {/* Search */}
        <div className="relative">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by project, task, type, employee..."
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border"
          />
        </div>

        {/* Filters */}
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-3 text-[11px] leading-relaxed">
          <div className="flex flex-col gap-1">
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider">
              Notification Type
            </span>
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card outline-none focus-visible:ring-1 focus-visible:ring-primary"
            >
              <option value="all">All Types</option>
              {NOTIFICATION_TYPES.map((t) => (
                <option key={t} value={t}>
                  {t}
                </option>
              ))}
            </select>
          </div>

          <div className="flex flex-col gap-1">
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider">
              Priority
            </span>
            <select
              value={priorityFilter}
              onChange={(e) => setPriorityFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card outline-none focus-visible:ring-1 focus-visible:ring-primary"
            >
              <option value="all">All Priorities</option>
              <option value="low">Low</option>
              <option value="medium">Medium</option>
              <option value="high">High</option>
              <option value="critical">Critical</option>
            </select>
          </div>

          <div className="flex flex-col gap-1">
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider">
              Date
            </span>
            <input
              type="date"
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              placeholder="dd-mm-yyyy"
              className="form-input rounded-md border border-border p-1.5 bg-card outline-none focus-visible:ring-1 focus-visible:ring-primary text-xs"
            />
          </div>

          <div className="flex flex-col gap-1">
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider">
              Status
            </span>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="form-input rounded-md border border-border p-1.5 bg-card outline-none focus-visible:ring-1 focus-visible:ring-primary"
            >
              <option value="all">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="acknowledged">Acknowledged</option>
            </select>
          </div>
        </div>

        {/* Sub-tabs line selector */}
        <div className="flex gap-4 border-b border-border pb-1 mt-2">
          {(["Current", "Archived"] as const).map((st) => {
            const count = notifications.filter((n) => {
              if (st === "Current") {
                return n.status === "Pending" || n.unread;
              } else {
                return n.status === "Acknowledged";
              }
            }).length;

            return (
              <button
                key={st}
                onClick={() => setSubTab(st)}
                className={cn(
                  "border-b-2 px-4 py-2 text-sm font-medium transition-all -mb-[6px] flex items-center gap-1.5 cursor-pointer",
                  subTab === st
                    ? "border-primary text-foreground"
                    : "border-transparent text-muted-foreground hover:text-foreground",
                )}
              >
                {st === "Current" ? (
                  <Bell className="h-3.5 w-3.5" />
                ) : (
                  <Archive className="h-3.5 w-3.5" />
                )}
                <span>{st}</span>
                <span className="rounded-full bg-muted px-1.5 py-0.5 text-[10px] font-semibold text-muted-foreground">
                  {count}
                </span>
              </button>
            );
          })}
        </div>

        {/* Notifications Table */}
        <div className="overflow-x-auto border border-border rounded-xl">
          <table className="min-w-full divide-y divide-border text-sm leading-relaxed text-left">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium min-w-[340px] w-[35%]">Notification Title</th>
                <th className="px-3 py-2 font-medium">Type</th>
                <th className="px-3 py-2 font-medium max-w-[180px]">Related Project</th>
                <th className="px-3 py-2 font-medium max-w-[150px]">Related Task</th>
                <th className="px-3 py-2 font-medium">Raised By</th>
                <th className="px-3 py-2 font-medium">Date</th>
                <th className="px-3 py-2 font-medium">Time</th>
                <th className="px-3 py-2 font-medium">Status</th>
                <th className="px-3 py-2 font-medium">Priority</th>
                {subTab === "Current" && (
                  <th className="px-3 py-2 font-medium text-right">Actions</th>
                )}
              </tr>
            </thead>
            <tbody className="divide-y divide-border/60 align-middle">
              {filteredNotifications.length === 0 ? (
                <tr>
                  <td colSpan={10} className="p-8 text-center text-muted-foreground">
                    No notifications matching search and filters.
                  </td>
                </tr>
              ) : (
                filteredNotifications.map((n) => (
                  <tr key={n.id} className="hover:bg-muted/10 transition-colors">
                    {/* Title */}
                    <td className="px-3 py-2.5 min-w-[340px] w-[35%]">
                      <div className="flex items-start gap-1.5">
                        {n.unread && (
                          <span className="text-primary mt-1 text-[10px] select-none">●</span>
                        )}
                        <button
                          onClick={() => handleOpenDetails(n.id)}
                          className="text-left font-medium text-gray-800 hover:text-primary transition-colors cursor-pointer hover:underline block w-full"
                        >
                          {n.title}
                        </button>
                      </div>
                    </td>

                    {/* Type Badge */}
                    <td className="px-3 py-2.5 whitespace-nowrap">
                      <span
                        className={cn(
                          "inline-flex rounded-full px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-wider",
                          getTypeStyles(n.type),
                        )}
                      >
                        {n.type}
                      </span>
                    </td>

                    {/* Related Project */}
                    <td className="px-3 py-2.5 text-xs text-muted-foreground max-w-[180px] break-words">
                      {n.relatedProject}
                    </td>

                    {/* Related Task */}
                    <td className="px-3 py-2.5 text-xs text-muted-foreground max-w-[150px] break-words">
                      {n.relatedTask || "—"}
                    </td>

                    {/* Raised By */}
                    <td className="px-3 py-2.5 whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <Avatar name={n.raisedBy} size={24} />
                        <span className="text-xs">{n.raisedBy}</span>
                      </div>
                    </td>

                    {/* Date */}
                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground whitespace-nowrap">
                      {formatNotifDate(n.createdAt)}
                    </td>

                    {/* Time */}
                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground whitespace-nowrap font-mono">
                      {formatNotifTime(n.createdAt)}
                    </td>

                    {/* Status Badge */}
                    <td className="px-3 py-2.5 whitespace-nowrap">
                      <span
                        className={cn(
                          "inline-flex rounded-full border px-2 py-0.5 text-[9px] font-bold capitalize items-center gap-1",
                          n.status === "Acknowledged"
                            ? "bg-emerald-50 text-emerald-700 border-emerald-200"
                            : "bg-orange-50 text-orange-700 border-orange-200",
                        )}
                      >
                        {n.status === "Acknowledged" ? (
                          <>
                            <Check className="h-2.5 w-2.5" />
                            <span>Acknowledged</span>
                          </>
                        ) : (
                          <>
                            <Clock className="h-2.5 w-2.5" />
                            <span>Pending</span>
                          </>
                        )}
                      </span>
                    </td>

                    {/* Priority */}
                    <td className="px-3 py-2.5 whitespace-nowrap">
                      <PriorityPill priority={n.priority.toLowerCase() as any} />
                    </td>

                    {/* Actions */}
                    {subTab === "Current" && (
                      <td className="px-3 py-2.5 pr-4 text-right whitespace-nowrap">
                        {n.status === "Pending" ? (
                          <button
                            onClick={() => handleOpenDetails(n.id)}
                            className="inline-flex items-center gap-1 rounded-md border border-success text-success bg-transparent hover:bg-success/10 px-2.5 py-1 text-xs font-semibold cursor-pointer transition-colors"
                          >
                            <Check className="h-3.5 w-3.5" /> Acknowledge
                          </button>
                        ) : (
                          <span className="text-muted-foreground">—</span>
                        )}
                      </td>
                    )}
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Details & Interactive Comment Modal */}
      {selectedNotification && (
        <Modal
          title={`Notification Details — ${selectedNotification.id}`}
          onClose={() => setSelectedNotifId(null)}
          wide
        >
          <div className="space-y-4 text-xs">
            {/* Top pill badges and Large Title */}
            <div className="space-y-2">
              <div className="flex flex-wrap gap-2">
                <span
                  className={cn(
                    "inline-flex rounded-full px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-wider",
                    getTypeStyles(selectedNotification.type),
                  )}
                >
                  {selectedNotification.type}
                </span>
                <PriorityPill priority={selectedNotification.priority.toLowerCase() as any} />
                <span
                  className={cn(
                    "inline-flex rounded-full border px-2.5 py-0.5 text-[9px] font-bold capitalize items-center gap-1",
                    selectedNotification.status === "Acknowledged"
                      ? "bg-emerald-50 text-emerald-700 border-emerald-200"
                      : "bg-orange-50 text-orange-700 border-orange-200",
                  )}
                >
                  {selectedNotification.status === "Acknowledged" ? (
                    <Check className="h-2.5 w-2.5" />
                  ) : (
                    <Clock className="h-2.5 w-2.5" />
                  )}
                  {selectedNotification.status}
                </span>
              </div>
              <h3 className="text-base font-bold text-gray-800 leading-snug">
                {selectedNotification.title}
              </h3>
            </div>

            {/* Metadata Grid */}
            <div className="grid grid-cols-2 md:grid-cols-3 gap-y-3.5 gap-x-6 border border-border rounded-xl p-4 bg-muted/5">
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                  Related Project
                </span>
                <span className="font-semibold text-gray-800">
                  {selectedNotification.relatedProject}
                </span>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                  Related Task
                </span>
                <span className="font-semibold text-gray-800">
                  {selectedNotification.relatedTask || "—"}
                </span>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                  Raised By
                </span>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <Avatar name={selectedNotification.raisedBy} size={18} />
                  <span className="font-semibold text-gray-700">
                    {selectedNotification.raisedBy}
                  </span>
                </div>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                  Date
                </span>
                <span className="font-medium text-gray-800">
                  {formatNotifDate(selectedNotification.createdAt)}
                </span>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                  Time
                </span>
                <span className="font-medium text-gray-800 font-mono">
                  {formatNotifTime(selectedNotification.createdAt)}
                </span>
              </div>
              <div>
                <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                  Notification ID
                </span>
                <span className="font-bold text-gray-800">{selectedNotification.id}</span>
              </div>
            </div>

            {/* Awaiting acknowledgement warning box */}
            {selectedNotification.status === "Pending" && (
              <div className="bg-orange-50 border border-orange-200 rounded-xl p-3.5 text-xs text-orange-800 space-y-0.5">
                <div className="font-semibold">This notification is awaiting acknowledgement.</div>
                <div className="text-orange-700">
                  Add your comment and click Acknowledge to confirm you have reviewed this
                  notification.
                </div>
              </div>
            )}

            {/* Mandatory Comment Area */}
            {selectedNotification.status === "Pending" ? (
              <div className="space-y-1">
                <label className="block text-xs font-bold text-gray-700">
                  Acknowledgement Comment <span className="text-red-500">* Mandatory</span>
                </label>
                <textarea
                  value={commentText}
                  onChange={(e) => {
                    setCommentText(e.target.value);
                    if (e.target.value.trim()) setShowCommentError(false);
                  }}
                  placeholder="Enter your acknowledgement remarks before confirming..."
                  rows={3}
                  className={cn(
                    "w-full rounded-lg border p-3 text-xs outline-none focus-visible:ring-1 focus-visible:ring-primary focus:border-primary/55 bg-card",
                    showCommentError ? "border-red-500" : "border-border",
                  )}
                />
                {showCommentError && (
                  <p className="text-[11px] text-red-500 mt-1 flex items-center gap-1 font-semibold select-none">
                    ⚠ Comment is required to acknowledge this notification.
                  </p>
                )}
              </div>
            ) : (
              // Read-only comment box for Acknowledged
              <div className="bg-emerald-50 border border-emerald-100 rounded-xl p-3.5 text-xs text-emerald-800 space-y-1">
                <div className="font-semibold">This notification has been acknowledged.</div>
                <div className="text-emerald-700">
                  Acknowledged by <strong>{selectedNotification.acknowledgedBy}</strong> on{" "}
                  {formatNotifDate(selectedNotification.acknowledgedDate || "")} at{" "}
                  {selectedNotification.acknowledgedTime}.
                </div>
              </div>
            )}

            {/* Audit History Card */}
            <div className="border border-border rounded-xl p-4 bg-card space-y-3 shadow-xs">
              <span className="font-bold text-muted-foreground uppercase text-[10px] tracking-wider block border-b border-border/50 pb-1">
                Audit History
              </span>
              <div className="grid grid-cols-3 gap-4 text-[11px] leading-relaxed">
                <div>
                  <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                    Created By
                  </span>
                  <span className="font-semibold text-gray-700">
                    {selectedNotification.createdBy}
                  </span>
                </div>
                <div>
                  <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                    Created Date
                  </span>
                  <span className="font-medium text-gray-755">
                    {formatNotifDate(selectedNotification.createdAt)}
                  </span>
                </div>
                <div>
                  <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                    Created Time
                  </span>
                  <span className="font-medium text-gray-755 font-mono">
                    {formatNotifTime(selectedNotification.createdAt)}
                  </span>
                </div>

                {selectedNotification.status === "Acknowledged" && (
                  <>
                    <div>
                      <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                        Acknowledged By
                      </span>
                      <span className="font-bold text-emerald-700">
                        {selectedNotification.acknowledgedBy}
                      </span>
                    </div>
                    <div>
                      <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                        Acknowledged Date
                      </span>
                      <span className="font-semibold text-emerald-700">
                        {formatNotifDate(selectedNotification.acknowledgedDate || "")}
                      </span>
                    </div>
                    <div>
                      <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                        Acknowledged Time
                      </span>
                      <span className="font-semibold text-emerald-700 font-mono">
                        {selectedNotification.acknowledgedTime}
                      </span>
                    </div>
                  </>
                )}
              </div>

              {/* Chronological Timeline History Log */}
              <div className="relative pl-4 border-l border-border/60 space-y-3 mt-4">
                {selectedNotification.history.map((h, idx) => (
                  <div key={idx} className="relative flex items-start gap-2">
                    <span className="absolute -left-[20.5px] top-1.5 h-2 w-2 rounded-full border border-primary bg-card" />
                    <div className="flex flex-col gap-0.5 text-xs leading-relaxed">
                      <div className="flex items-center gap-2">
                        <span className="text-muted-foreground font-mono text-[10px]">
                          {formatNotifDate(h.date)} {h.time}
                        </span>
                        <span className="font-semibold text-gray-700">
                          {h.action.includes("Remarks:") ? (
                            <>
                              Notification acknowledged by <strong>{h.by}</strong>
                              <span className="block text-muted-foreground font-normal mt-0.5 italic">
                                Remarks: {h.action.split("Remarks:")[1]?.replace(/"/g, "")}
                              </span>
                            </>
                          ) : (
                            `${h.action} by ${h.by}`
                          )}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Modal Footer Controls */}
            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button
                onClick={() => setSelectedNotifId(null)}
                className="rounded-md border border-input bg-card px-4 py-2 font-medium hover:bg-accent text-xs cursor-pointer"
              >
                Close
              </button>
              {selectedNotification.status === "Pending" && canManageApprovals && (
                <button
                  onClick={handleConfirmAcknowledge}
                  className="rounded-md bg-success text-success-foreground px-4 py-2 font-semibold hover:bg-success/90 text-xs flex items-center gap-1 cursor-pointer"
                >
                  <Check className="h-3.5 w-3.5" /> Acknowledge
                </button>
              )}
            </div>
          </div>
        </Modal>
      )}
    </>
  );
}

const NOTIFICATION_TYPES = [
  "New Project Assignment",
  "New Task Assignment",
  "WBS Assignment",
  "Project Ready To Start",
  "Team Assignment",
  "Shadow Team Assignment",
  "Appreciation Received",
  "Issue Raised",
  "Issue Resolved",
  "Customer Interview Selected",
  "Customer Interview Rejected",
  "Additional Customer Requirement",
  "Approval Request",
  "Timesheet Approved",
  "Timesheet Rejected",
  "Timesheet Request Changes",
  "Resource Allocation",
  "Resource Removal",
  "Project Status Change",
  "Project Completed",
  "Project Cancelled",
  "Scope Change",
  "Resource Shuffle",
] as const;
