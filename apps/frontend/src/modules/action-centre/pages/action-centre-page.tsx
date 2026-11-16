import { Link, Navigate } from "@tanstack/react-router";

import { useMemo, useState, useEffect, useCallback, useRef } from "react";

import { NotificationDetailModal, formatNotificationId } from "@/components/notification-detail-modal";

import {

  Search,

  Eye,

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

  ChevronLeft,

  ChevronRight,

  Play,

  Square,

  Pause,

  Loader2,
  Pencil,
  Upload,
} from "lucide-react";

import { AppShell } from "@/components/app-shell";

import { useRoleContext } from "@/lib/role-context";

import { usePermissions } from "@/lib/permissions";

import { startTaskTimer, stopTaskTimer } from "@/modules/projects/api/projects";

import {

  people,

  getPerson,

  type TaskStatus,

  type CellCommentData,

  type CellCommentMessage,

} from "@/lib/domain-models";

import { TaskStatusPill, TimesheetStatusPill, PriorityPill, Avatar } from "@/components/pills";

import {

  useDhStore,

  dhStore,

  type DhAlert,

  type DhInterview,

  type DhTimesheet,

  type DhCentralApproval,

  type AlertStatus,

  type DhNotification,

  type IssueCategory,

  type DhPriority,

} from "@/lib/workspace-store";

import { apiFetch, apiFetchBlob } from "@/lib/api-client";

import { cn } from "@/lib/utils";

import { toast } from "sonner";
import {
  fetchPendingApprovals,
  approveProjectAdditionalRequirement,
  rejectProjectAdditionalRequirement,
  takeProjectAdditionalRequirementAction,
} from "@/modules/projects/api/project-additional-requirements";

import {

  fetchPendingExtensionApprovals,

  approveProjectExtensionRequest,

  rejectProjectExtensionRequest,

  takeProjectExtensionRequestAction,

} from "@/modules/projects/api/project-extension-requests";
import {
  fetchPendingAllocationApprovals,
  takeResourceAllocationAction,
} from "@/modules/projects/api/project-team-members";
import {
  fetchPendingFeedbackApprovals,
  takeFeedbackApprovalAction,
} from "@/modules/projects/api/project-feedbacks";

import { Modal } from "@/modules/projects/pages/projects-list-page";

import { Field } from "@/components/form-row";

import {
  createProjectIssue,
  raiseBucketListIssue,
  fetchMyAssignedProjects,
  type AssignedProjectSummary,
} from "@/modules/projects/api/project-issues";
import { paginateSlice, totalPageCount } from "@/lib/pagination";
import { TablePaginationFooter } from "@/components/table-pagination-footer";



function formatToDayMonthYear(val?: string | null): string {

  if (!val) return "";

  const match = /^(\d{4})-(\d{2})-(\d{2})/.exec(val);

  if (match) {

    return `${match[3]}-${match[2]}-${match[1]}`;

  }

  const d = new Date(val);

  if (!isNaN(d.getTime())) {

    const day = String(d.getDate()).padStart(2, "0");

    const month = String(d.getMonth() + 1).padStart(2, "0");

    const year = d.getFullYear();

    return `${day}-${month}-${year}`;

  }

  return val;

}



const actionTabs = [

  { code: "bucket-list", name: "Bucket List" },

  { code: "approvals", name: "Approvals" },

  { code: "alerts", name: "Alerts" },

  { code: "notifications", name: "Notifications" },

] as const;



const employeeTabCodes = ["bucket-list", "notifications"];

const salesTabCodes = ["approvals", "alerts", "notifications"];

const pmoTabCodes = ["approvals", "alerts", "notifications"];



export function ActionCentrePage() {
  const { isDhanshree, user } = useRoleContext();
  const { canView, hasPermission } = usePermissions();
  const isAdmin = user?.role?.toLowerCase() === "admin";
  const store = useDhStore((s) => s);
  const [tabCode, setTabCode] = useState(() => {
    if (typeof window !== "undefined") {
      const p = new URLSearchParams(window.location.search).get("tab");
      if (p) return p;
    }
    return "";
  });

  useEffect(() => {
    if (typeof window !== "undefined") {
      const syncFromUrl = () => {
        const p = new URLSearchParams(window.location.search).get("tab");
        if (p && p !== tabCode) setTabCode(p);
      };
      syncFromUrl();
      window.addEventListener("popstate", syncFromUrl);
      return () => window.removeEventListener("popstate", syncFromUrl);
    }
  }, [tabCode]);

  const visibleTabs = useMemo(() => {
    return actionTabs.filter((tab) => {
      if (isAdmin || isDhanshree) return true;
      if (tab.code === "approvals") {
        return canView("approvals") || canView("action-centre") || canView("action-center") || hasPermission("action-center.view") || (store.approvals && store.approvals.length > 0);
      }
      return canView(tab.code);
    });
  }, [isAdmin, isDhanshree, canView, hasPermission, store.approvals]);

  const activeTab = visibleTabs.find((tab) => tab.code === tabCode) ?? visibleTabs[0];

  if (!isAdmin && !isDhanshree && !canView("action-centre") && !canView("action-center") && !hasPermission("action-center.view")) {
    return <Navigate to="/" />;
  }

  return (
    <AppShell
      title="Action Centre"
      subtitle="Bucket list, timesheets, approvals and alerts in one place"
    >
      {visibleTabs.length === 0 ? (
        <div className="rounded-lg border border-border bg-card p-8 text-center text-muted-foreground shadow-2xs">
          <p className="text-sm font-semibold text-foreground">No Access to Action Center Tabs</p>
          <p className="mt-1 text-xs text-muted-foreground">You do not have permission to view any Action Center tabs. Contact your administrator to request access.</p>
        </div>
      ) : (
        <>
          <div className="mb-4 inline-flex w-fit max-w-full gap-1 overflow-x-auto rounded-lg border border-border bg-card p-1 text-sm shadow-sm">
            {visibleTabs.map((tab) => (
              <button
                key={tab.code}
                onClick={() => setTabCode(tab.code)}
                className={cn(
                  "rounded-md px-3 py-1.5 font-medium transition-colors whitespace-nowrap flex items-center gap-1.5",
                  activeTab?.code === tab.code
                    ? "bg-primary text-primary-foreground"
                    : "text-muted-foreground hover:text-foreground",
                )}
              >
                <span>{tab.name}</span>
              </button>
            ))}
          </div>

          {activeTab?.code === "bucket-list" && <BucketList />}
          {activeTab?.code === "approvals" && <ApprovalsTab />}
          {activeTab?.code === "alerts" && <AlertsTab />}
          {activeTab?.code === "notifications" && <NotificationsTab />}
        </>
      )}
    </AppShell>
  );
}



// ---------- Bucket List ----------

import {

  fetchBucketList,

  startBucketTaskTimer,

  pauseBucketTaskTimer,

  stopBucketTaskTimer,

  completeBucketTask,

  type ApiBucketTask,

} from "../api/action-centre";



function BucketListRow({

  r,

  onRefresh,

  onUpdateRow,

}: {

  r: ApiBucketTask;

  onRefresh: (showLoader?: boolean) => void;

  onUpdateRow?: (updated: ApiBucketTask) => void;

}) {

  const byName = r.assignedByName || (r.assignedById ? getPerson(r.assignedById).name : "") || "Project Manager";

  const [now, setNow] = useState(Date.now());



  // Optimistic local state for immediate smooth button and timer transitions

  const [localStatus, setLocalStatus] = useState<string>(r.status);

  const [localTimerRunning, setLocalTimerRunning] = useState<boolean>(r.timerRunning);

  const [localAccumulatedSeconds, setLocalAccumulatedSeconds] = useState<number>(r.timerAccumulatedSeconds ?? 0);

  const [localTimerStartedAt, setLocalTimerStartedAt] = useState<string | null>(r.timerStartedAtUtc ?? null);

  const [showStopModal, setShowStopModal] = useState<boolean>(false);

  const [isStopping, setIsStopping] = useState<boolean>(false);



  useEffect(() => {

    setLocalStatus(r.status);

    setLocalTimerRunning(r.timerRunning);

    setLocalAccumulatedSeconds(r.timerAccumulatedSeconds ?? 0);

    setLocalTimerStartedAt(r.timerStartedAtUtc ?? null);

  }, [r.status, r.timerRunning, r.timerAccumulatedSeconds, r.timerStartedAtUtc]);



  useEffect(() => {

    if (!localTimerRunning) return;

    const interval = setInterval(() => {

      setNow(Date.now());

    }, 1000);

    return () => clearInterval(interval);

  }, [localTimerRunning]);



  let workingTimeSeconds = localAccumulatedSeconds;

  if (localTimerRunning && localTimerStartedAt) {

    const elapsedSinceStart = Math.floor((now - new Date(localTimerStartedAt).getTime()) / 1000);

    workingTimeSeconds += Math.max(0, elapsedSinceStart);

  } else if (!localTimerRunning && (r.elapsedTimeSeconds ?? 0) > workingTimeSeconds) {

    workingTimeSeconds = r.elapsedTimeSeconds;

  }



  const formatTimer = (totalSecs: number) => {

    const h = Math.floor(totalSecs / 3600);

    const m = Math.floor((totalSecs % 3600) / 60);

    const s = totalSecs % 60;

    return [h, m, s].map((v) => String(v).padStart(2, "0")).join(":");

  };



  const handleStart = async () => {

    try {

      setLocalStatus("Ongoing");

      setLocalTimerRunning(true);

      setLocalTimerStartedAt(new Date().toISOString());

      const updated = await startBucketTaskTimer(r.id);

      toast.success("Timer started", { description: r.taskTitle });

      onUpdateRow?.(updated);

      onRefresh(false);

    } catch (err: any) {

      setLocalStatus(r.status);

      setLocalTimerRunning(r.timerRunning);

      setLocalAccumulatedSeconds(r.timerAccumulatedSeconds ?? 0);

      setLocalTimerStartedAt(r.timerStartedAtUtc ?? null);

      toast.error(err.message || "Failed to start timer");

    }

  };



  const handlePause = async () => {

    try {

      const currentSeconds = workingTimeSeconds;

      setLocalStatus("Paused");

      setLocalTimerRunning(false);

      setLocalAccumulatedSeconds(currentSeconds);

      setLocalTimerStartedAt(null);

      const updated = await pauseBucketTaskTimer(r.id);

      toast.info("Timer paused", { description: r.taskTitle });

      onUpdateRow?.(updated);

      onRefresh(false);

    } catch (err: any) {

      setLocalStatus(r.status);

      setLocalTimerRunning(r.timerRunning);

      setLocalAccumulatedSeconds(r.timerAccumulatedSeconds ?? 0);

      setLocalTimerStartedAt(r.timerStartedAtUtc ?? null);

      toast.error(err.message || "Failed to pause timer");

    }

  };



  const handleResume = async () => {

    try {

      setLocalStatus("Ongoing");

      setLocalTimerRunning(true);

      setLocalTimerStartedAt(new Date().toISOString());

      const updated = await startBucketTaskTimer(r.id);

      toast.success("Timer resumed", { description: r.taskTitle });

      onUpdateRow?.(updated);

      onRefresh(false);

    } catch (err: any) {

      setLocalStatus(r.status);

      setLocalTimerRunning(r.timerRunning);

      setLocalAccumulatedSeconds(r.timerAccumulatedSeconds ?? 0);

      setLocalTimerStartedAt(r.timerStartedAtUtc ?? null);

      toast.error(err.message || "Failed to resume timer");

    }

  };



  const handleStop = async () => {

    try {

      setIsStopping(true);

      const currentSeconds = workingTimeSeconds;

      setLocalStatus("Stopped");

      setLocalTimerRunning(false);

      setLocalAccumulatedSeconds(currentSeconds);

      setLocalTimerStartedAt(null);

      const updated = await stopBucketTaskTimer(r.id);

      toast.warning("Task stopped", { description: r.taskTitle });

      onUpdateRow?.(updated);

      onRefresh(false);

    } catch (err: any) {

      setLocalStatus(r.status);

      setLocalTimerRunning(r.timerRunning);

      setLocalAccumulatedSeconds(r.timerAccumulatedSeconds ?? 0);

      setLocalTimerStartedAt(r.timerStartedAtUtc ?? null);

      toast.error(err.message || "Failed to stop timer");

    } finally {

      setIsStopping(false);

      setShowStopModal(false);

    }

  };



  const handleComplete = async () => {

    try {

      const updated = await completeBucketTask(r.id);

      toast.success("Task completed!", { description: r.taskTitle });

      onUpdateRow?.(updated);

      onRefresh(false);

    } catch (err: any) {

      toast.error(err.message || "Failed to complete task");

    }

  };



  // Determine true display status dynamically based on timerRunning and state

  let displayStatus = localStatus;

  if (localTimerRunning) {

    displayStatus = "Ongoing";

  } else if (localStatus === "Completed") {

    displayStatus = "Completed";

  } else if (localStatus === "On Hold") {

    displayStatus = "On Hold";

  } else if (localStatus === "Cancelled") {

    displayStatus = "Cancelled";

  } else if (localStatus === "Stopped") {

    displayStatus = "Stopped";

  } else if (localStatus === "Paused" || workingTimeSeconds > 0) {

    displayStatus = "Paused";

  } else {

    displayStatus = localStatus || "Not Started";

  }



  return (
    <tr className="hover:bg-accent/30 border-b border-border">
      <td className="px-3 py-2.5 truncate">
        <Link
          to="/projects/$projectId"
          params={{ projectId: r.projectId }}
          hash={r.taskId}
          className="font-semibold text-foreground hover:text-primary transition-colors block truncate"
        >
          {r.taskTitle}
        </Link>
      </td>
      <td className="px-3 py-2.5 text-muted-foreground font-medium truncate">{r.projectName}</td>
      <td className="px-3 py-2.5">
        <PriorityPill priority={(r.priority?.toLowerCase() as any) || "medium"} />
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

            displayStatus === "Not Started" && "bg-slate-50 text-slate-700 border-slate-200",

            displayStatus === "Ongoing" && "bg-blue-50 text-blue-700 border-blue-200 animate-pulse",

            displayStatus === "Paused" && "bg-amber-50 text-amber-700 border-amber-200",

            displayStatus === "Stopped" && "bg-rose-50 text-rose-700 border-rose-200",

            displayStatus === "Completed" && "bg-green-50 text-green-700 border-green-200",

            displayStatus === "On Hold" && "bg-amber-50 text-amber-800 border-amber-300",

            displayStatus === "Cancelled" && "bg-rose-50 text-rose-800 border-rose-300",

          )}

        >

          {displayStatus === "Ongoing" && <Clock className="h-3 w-3 animate-spin text-blue-600" />}

          {displayStatus === "Paused" && <Pause className="h-3 w-3 text-amber-700" />}

          {displayStatus === "Stopped" && <Square className="h-3 w-3 text-rose-700 fill-current" />}

          {displayStatus === "On Hold" && <Pause className="h-3 w-3 text-amber-700" />}

          {displayStatus === "Cancelled" && <XCircle className="h-3 w-3 text-rose-700" />}

          {displayStatus === "Completed" && <CheckCircle2 className="h-3 w-3 text-green-600" />}

          {displayStatus}

        </span>

      </td>

      <td className="px-3 py-2.5 truncate">
        <div className="flex items-center gap-2 truncate">
          <Avatar name={byName} size={24} />
          <span className="text-xs font-semibold text-foreground truncate">{byName}</span>
        </div>
      </td>

      <td className="px-3 py-2.5">

        <div className="flex flex-col gap-1.5 min-w-[210px] bg-muted/20 p-2 rounded-lg border border-border/80">

          {(displayStatus !== "Not Started" || workingTimeSeconds > 0 || !!r.actualStartDate) && (

            <div className="text-[10px] text-muted-foreground flex flex-col gap-0.5 font-medium">

              {r.actualStartDate && (

                <div>

                  <span className="font-semibold text-muted-foreground">Started:</span>{" "}

                  {new Date(r.actualStartDate).toLocaleDateString("en-GB", {

                    day: "2-digit",

                    month: "short",

                    year: "numeric",

                  })}

                </div>

              )}

              <div className="flex items-center justify-between font-mono font-bold text-foreground border-t border-border/50 mt-1 pt-1">

                <span>Working Time:</span>

                <span

                  className={cn(

                    "text-xs font-bold",

                    localTimerRunning ? "text-blue-600 animate-pulse" : "text-muted-foreground",

                  )}

                >

                  {formatTimer(workingTimeSeconds)}

                </span>

              </div>

              {displayStatus === "On Hold" && (

                <div className="text-amber-800 font-semibold border-t border-border/50 mt-1 pt-1 flex items-center gap-1 text-[10px]">

                  <Pause className="h-3 w-3 text-amber-600" /> Timer Paused (On Hold)

                </div>

              )}

              {displayStatus === "Cancelled" && (

                <div className="text-rose-700 font-semibold border-t border-border/50 mt-1 pt-1 flex items-center gap-1 text-[10px]">

                  <XCircle className="h-3 w-3 text-rose-600" /> Task Cancelled

                </div>

              )}

              {displayStatus === "Stopped" && (

                <div className="text-rose-600 font-semibold border-t border-border/50 mt-1 pt-1 flex items-center gap-1">

                  Timer Frozen

                </div>

              )}

              {displayStatus === "Completed" && r.actualEndDate && (

                <div className="text-success font-semibold border-t border-border/50 mt-1 pt-1">

                  Completed:{" "}

                  {new Date(r.actualEndDate).toLocaleDateString("en-GB", {

                    day: "2-digit",

                    month: "short",

                    year: "numeric",

                  })}

                </div>

              )}

            </div>

          )}



          <div className="flex items-center gap-1.5">

            {/* If task is completed */}

            {displayStatus === "Completed" && (

              <span className="text-xs font-bold text-success flex items-center gap-1 py-1">

                <CheckCircle2 className="h-4.5 w-4.5 text-success" /> Task Completed

              </span>

            )}



            {/* If task is On Hold */}

            {displayStatus === "On Hold" && (

              <div className="flex flex-col gap-1 w-full">

                <button

                  disabled

                  className="inline-flex items-center justify-center gap-1.5 rounded-md bg-amber-100/70 px-3 py-1.5 text-xs font-bold text-amber-800 border border-amber-300 cursor-not-allowed opacity-90 shadow-2xs w-full"

                  title="Task is On Hold. Move stage to Ongoing in the project task tab to resume this task."

                >

                  <Pause className="h-3.5 w-3.5" /> On Hold (Paused)

                </button>

                <span className="text-[9px] text-muted-foreground italic leading-tight text-center">

                  Stage must be Ongoing to resume

                </span>

              </div>

            )}



            {/* If task is Cancelled */}

            {displayStatus === "Cancelled" && (

              <div className="flex flex-col gap-1 w-full">

                <button

                  disabled

                  className="inline-flex items-center justify-center gap-1.5 rounded-md bg-rose-100/70 px-3 py-1.5 text-xs font-bold text-rose-800 border border-rose-300 cursor-not-allowed opacity-90 shadow-2xs w-full"

                  title="This task is Cancelled."

                >

                  <XCircle className="h-3.5 w-3.5" /> Cancelled

                </button>

              </div>

            )}



            {/* If task is Not Started (zero working time, not running) */}

            {displayStatus === "Not Started" && !localTimerRunning && workingTimeSeconds === 0 && (

              <>

                <button

                  onClick={handleStart}

                  className="inline-flex items-center justify-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-xs font-bold text-primary-foreground hover:bg-primary/95 transition-all shadow-sm cursor-pointer"

                  title="Start Task"

                >

                  <Play className="h-3.5 w-3.5 fill-current" /> Start

                </button>

                <button

                  disabled

                  title="Start the task first before pausing"

                  className="inline-flex items-center justify-center gap-1 rounded-md border border-border bg-muted/40 px-3 py-1.5 text-xs font-bold text-muted-foreground/60 cursor-not-allowed select-none"

                >

                  <Pause className="h-3.5 w-3.5" /> Pause

                </button>

              </>

            )}



            {/* If timer is actively running */}

            {localTimerRunning && (

              <>

                <button

                  onClick={handlePause}

                  className="inline-flex items-center justify-center gap-1.5 rounded-md border border-amber-300 bg-amber-50 px-3 py-1.5 text-xs font-bold text-amber-700 hover:bg-amber-100 transition-all shadow-2xs cursor-pointer"

                  title="Pause Timer"

                >

                  <Pause className="h-3.5 w-3.5" /> Pause

                </button>

                <button

                  type="button"

                  onClick={() => setShowStopModal(true)}

                  className="inline-flex items-center justify-center gap-1.5 rounded-md bg-rose-600 px-3 py-1.5 text-xs font-bold text-white hover:bg-rose-700 transition-all shadow-sm cursor-pointer"

                  title="Stop Task"

                >

                  <Square className="h-3 w-3 fill-current" /> Stop

                </button>

              </>

            )}



            {/* If task is Stopped: User CANNOT resume or pause that task */}

            {displayStatus === "Stopped" && (

              <div className="flex items-center gap-1.5 py-1">

                <span className="inline-flex items-center gap-1.5 rounded-md bg-rose-50 border border-rose-200 px-3 py-1.5 text-xs font-bold text-rose-700 shadow-2xs select-none">

                  <Square className="h-3 w-3 fill-current text-rose-600" /> Task Stopped

                </span>

              </div>

            )}



            {/* If timer is paused (not running, not stopped, but was started or has accumulated time) */}

            {!localTimerRunning && displayStatus !== "Completed" && displayStatus !== "On Hold" && displayStatus !== "Cancelled" && displayStatus !== "Stopped" && (displayStatus === "Paused" || workingTimeSeconds > 0) && (

              <>

                <button

                  onClick={handleResume}

                  className="inline-flex items-center justify-center gap-1.5 rounded-md border border-blue-300 bg-blue-50 px-3 py-1.5 text-xs font-bold text-blue-700 hover:bg-blue-100 transition-all shadow-2xs cursor-pointer"

                  title="Resume Timer"

                >

                  <Play className="h-3.5 w-3.5 fill-current" /> Resume

                </button>

                <button

                  type="button"

                  onClick={() => setShowStopModal(true)}

                  className="inline-flex items-center justify-center gap-1.5 rounded-md bg-rose-600 px-3 py-1.5 text-xs font-bold text-white hover:bg-rose-700 transition-all shadow-sm cursor-pointer"

                  title="Stop Task"

                >

                  <Square className="h-3 w-3 fill-current" /> Stop

                </button>

              </>

            )}

          </div>

        </div>

      </td>

      {showStopModal && (
        <td className="p-0">
          <div className="fixed inset-0 z-[90] flex items-center justify-center bg-black/50 backdrop-blur-xs p-4">
            <div
              role="dialog"
              aria-modal="true"
              className="w-full max-w-md rounded-xl border border-border bg-card shadow-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-150 text-left font-normal"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center justify-between border-b border-border px-5 py-3.5 bg-muted/20">
                <h3 className="text-sm font-semibold text-foreground flex items-center gap-2">
                  <Square className="h-4 w-4 text-rose-600 fill-current" />
                  Confirm Stop Task
                </h3>
                <button
                  type="button"
                  disabled={isStopping}
                  onClick={() => setShowStopModal(false)}
                  className="rounded-md p-1 text-muted-foreground hover:bg-accent disabled:opacity-50 cursor-pointer"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              <div className="p-5 space-y-4">
                <p className="text-xs text-foreground leading-relaxed">
                  Are you sure you want to stop this task?
                </p>

                <div className="rounded-lg border border-border/80 bg-muted/30 p-3.5 space-y-2 text-xs">
                  <div className="flex items-center justify-between">
                    <span className="text-muted-foreground">Task:</span>
                    <span className="font-semibold text-foreground text-right max-w-[240px] truncate">
                      {r.taskTitle}
                    </span>
                  </div>
                  <div className="h-px bg-border/60" />
                  <div className="flex items-center justify-between">
                    <span className="text-muted-foreground">Project:</span>
                    <span className="font-medium text-foreground text-right max-w-[240px] truncate">
                      {r.projectName}
                    </span>
                  </div>
                  <div className="h-px bg-border/60" />
                  <div className="flex items-center justify-between font-mono font-bold">
                    <span className="text-muted-foreground font-sans font-normal">Working Time:</span>
                    <span className="text-primary">{formatTimer(workingTimeSeconds)}</span>
                  </div>
                </div>

                <div className="rounded-md bg-amber-500/10 border border-amber-500/20 p-2.5 text-[11px] text-amber-800 dark:text-amber-200 flex items-start gap-2">
                  <AlertTriangle className="h-4 w-4 text-amber-600 dark:text-amber-400 shrink-0 mt-0.5" />
                  <span className="leading-normal">
                    After clicking <strong>OK</strong>, you cannot resume or pause this task, and the timer will stop permanently.
                  </span>
                </div>
              </div>

              <div className="flex items-center justify-end gap-2 border-t border-border px-5 py-3 bg-muted/10">
                <button
                  type="button"
                  disabled={isStopping}
                  onClick={() => setShowStopModal(false)}
                  className="rounded-md border border-input bg-card px-3.5 py-1.5 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-50 cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  disabled={isStopping}
                  onClick={() => void handleStop()}
                  className="inline-flex items-center gap-1.5 rounded-md bg-rose-600 px-4 py-1.5 text-xs font-medium text-white hover:bg-rose-700 disabled:opacity-50 cursor-pointer shadow-sm"
                >
                  {isStopping && <Loader2 className="h-3.5 w-3.5 animate-spin" />}
                  OK
                </button>
              </div>
            </div>
          </div>
        </td>
      )}
    </tr>

  );

}



function sortBucketTasks(tasks: ApiBucketTask[]): ApiBucketTask[] {
  return [...tasks].sort((a, b) => {
    const timeA = a.createdAtUtc ? new Date(a.createdAtUtc).getTime() : 0;
    const timeB = b.createdAtUtc ? new Date(b.createdAtUtc).getTime() : 0;
    if (timeA !== timeB) return timeB - timeA;
    return (b.id || "").localeCompare(a.id || "");
  });
}

function BucketList() {

  const { user, isEmployee, employeePersonId, assignedProjects } = useRoleContext();



  const [q, setQ] = useState("");

  const [statusFilter, setStatusFilter] = useState<

    "all" | "todo" | "in_progress" | "on_hold" | "done"

  >("all");

  const [priorityFilter, setPriorityFilter] = useState<

    "all" | "Low" | "Medium" | "High" | "Critical"

  >("all");

  const [showRaiseModal, setShowRaiseModal] = useState(false);
  const [dbAssignedProjects, setDbAssignedProjects] = useState<AssignedProjectSummary[]>([]);

  const [formData, setFormData] = useState({
    projectId: "",
    title: "",
    description: "",
    category: "Technical Related Issues" as IssueCategory,
    priority: "Medium" as DhPriority,
  });
  const [submittingIssue, setSubmittingIssue] = useState(false);

  useEffect(() => {
    fetchMyAssignedProjects()
      .then((projs) => {
        const list = projs ?? [];
        setDbAssignedProjects(list);
        if (list.length > 0) {
          setFormData((s) => ({ ...s, projectId: list[0].id }));
        }
      })
      .catch(() => {
        setDbAssignedProjects([]);
      });
  }, []);

  const userProjects = useMemo(() => {
    return dbAssignedProjects;
  }, [dbAssignedProjects]);

  const handleOpenRaiseModal = async () => {
    try {
      const projs = await fetchMyAssignedProjects();
      const list = projs ?? [];
      setDbAssignedProjects(list);
      setFormData((prev) => ({
        ...prev,
        projectId: list.length > 0 ? (prev.projectId && list.some(p => p.id === prev.projectId) ? prev.projectId : list[0].id) : "",
      }));
    } catch {
      // keep existing
    }
    setShowRaiseModal(true);
  };

  const handleSubmitIssue = async () => {
    if (!formData.projectId || !formData.projectId.trim()) {
      if (userProjects.length === 0) {
        toast.error("Cannot raise issue: No project assigned to you");
      } else {
        toast.error("Please select an assigned project");
      }
      return;
    }

    if (!formData.title.trim()) {
      toast.error("Issue Title is required");
      return;
    }

    if (!formData.description.trim()) {
      toast.error("Description is required");
      return;
    }

    if (!formData.category || !formData.category.trim()) {
      toast.error("Issue Type is required");
      return;
    }

    if (!formData.priority || !formData.priority.trim()) {
      toast.error("Priority is required");
      return;
    }

    setSubmittingIssue(true);
    try {
      await raiseBucketListIssue(formData.projectId, {
        subject: formData.title.trim(),
        description: formData.description.trim(),
        issueType: formData.category,
        priority: formData.priority,
      });

      toast.success("Issue raised successfully", {
        description: "Mirrored to project health and alerts",
      });

      setShowRaiseModal(false);
      setFormData({
        projectId: userProjects.length > 0 ? userProjects[0].id : "",
        title: "",
        description: "",
        category: "Technical Related Issues",
        priority: "Medium",
      });
    } catch (err: any) {
      toast.error(err?.message || "Failed to raise issue");
    } finally {
      setSubmittingIssue(false);
    }
  };



  const [apiTasks, setApiTasks] = useState<ApiBucketTask[]>([]);

  const [loading, setLoading] = useState(true);



  const handleUpdateRow = useCallback((updated: ApiBucketTask) => {
    setApiTasks((prev) => {
      const next = prev.map((t) => (t.id === updated.id ? { ...t, ...updated } : t));
      return sortBucketTasks(next);
    });
  }, []);



  const loadData = useCallback(async (showLoader = false) => {

    try {

      if (showLoader) {

        setLoading(true);

      }

      const res = await fetchBucketList({

        search: q.trim() || undefined,

        status: statusFilter !== "all" ? statusFilter : undefined,

        priority: priorityFilter !== "all" ? priorityFilter : undefined,

      });

      setApiTasks(sortBucketTasks(res.items || []));

    } catch (err: any) {

      toast.error(err.message || "Failed to load bucket tasks");

    } finally {

      if (showLoader) {

        setLoading(false);

      }

    }

  }, [q, statusFilter, priorityFilter, user?.id, employeePersonId]);



  useEffect(() => {

    loadData(true);

  }, [loadData]);

  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  useEffect(() => {
    setPage(1);
  }, [q, statusFilter, priorityFilter]);

  const totalTasks = apiTasks.length;
  const pageTasks = useMemo(() => paginateSlice(apiTasks, page, pageSize), [apiTasks, page, pageSize]);







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



        {/* Status Filter Bar */}

        <div className="flex h-9 items-center gap-1 rounded-md border border-input bg-card px-2 text-xs">

          <Filter className="h-3.5 w-3.5 text-muted-foreground shrink-0 mx-1" />

          {(["all", "todo", "in_progress", "on_hold", "done"] as const).map((s) => (

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

                ? "All"

                : s === "todo"

                ? "To Do"

                : s === "in_progress"

                ? "In Progress"

                : s === "on_hold"

                ? "On Hold"

                : "Done"}

            </button>

          ))}

        </div>



        {/* Priority Filter */}

        <div className="flex h-9 items-center gap-1 rounded-md border border-input bg-card px-2 text-xs">

          {(["all", "Low", "Medium", "High", "Critical"] as const).map((p) => (

            <button

              key={p}

              onClick={() => setPriorityFilter(p)}

              className={cn(

                "h-7 rounded-sm px-2 text-xs font-medium transition-colors cursor-pointer",

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
        <button
          onClick={handleOpenRaiseModal}
          className="inline-flex items-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground hover:bg-primary/90 transition-all shadow-sm cursor-pointer whitespace-nowrap"
        >
          <Plus className="h-3.5 w-3.5" /> Raise Issue
        </button>



        <span className="ml-auto text-xs text-muted-foreground font-medium whitespace-nowrap">

          {apiTasks.length} {apiTasks.length === 1 ? "task" : "tasks"}

        </span>

      </header>



      <div className="overflow-x-auto">
        <table className="w-full min-w-[980px] table-fixed text-sm">
          <colgroup>
            <col style={{ width: "22%" }} />
            <col style={{ width: "16%" }} />
            <col style={{ width: "10%" }} />
            <col style={{ width: "12%" }} />
            <col style={{ width: "12%" }} />
            <col style={{ width: "14%" }} />
            <col style={{ width: "14%" }} />
          </colgroup>
          <thead className="app-columns-head sticky top-0 z-10 bg-card/95 backdrop-blur-md text-left text-xs text-muted-foreground border-b border-border shadow-2xs">
            <tr>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Task</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Project</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Priority</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Due Date</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Status</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Assigned By</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Actions & Timer</th>
            </tr>
          </thead>

          <tbody className="divide-y divide-border">

            {loading ? (

              <tr>

                <td colSpan={7} className="px-3 py-12 text-center text-xs text-muted-foreground">

                  <div className="flex items-center justify-center gap-2">

                    <Loader2 className="h-4 w-4 animate-spin text-primary" /> Loading bucket tasks...

                  </div>

                </td>

              </tr>

            ) : apiTasks.length === 0 ? (

              <tr>

                <td colSpan={7} className="px-3 py-12 text-center text-xs text-muted-foreground">

                  No tasks assigned in your bucket list matching current filters.

                </td>

              </tr>

            ) : (

              pageTasks.map((r) => (

                <BucketListRow

                  key={r.id}

                  r={r}

                  onRefresh={loadData}

                  onUpdateRow={handleUpdateRow}

                />

              ))

            )}

          </tbody>

        </table>

      </div>

      <TablePaginationFooter
        page={page}
        pageSize={pageSize}
        total={totalTasks}
        itemLabel="tasks"
        onPageChange={setPage}
        onPageSizeChange={setPageSize}
      />



      {/* Raise Issue Modal */}
      {showRaiseModal && (
        <Modal title="Raise Issue" onClose={() => setShowRaiseModal(false)} draggable>
          <div className="space-y-3">
            <Field label="Project *">
              <select
                value={formData.projectId}
                onChange={(e) => setFormData((s) => ({ ...s, projectId: e.target.value }))}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              >
                {userProjects.length === 0 ? (
                  <option value="" disabled>
                    No project assigned
                  </option>
                ) : (
                  <>
                    <option value="" disabled>
                      Select an assigned project...
                    </option>
                    {userProjects.map((p) => (
                      <option key={p.id} value={p.id}>
                        {p.name}{p.projectCode ? ` (${p.projectCode})` : ""}
                      </option>
                    ))}
                  </>
                )}
              </select>
            </Field>

            {userProjects.length === 0 && (
              <div className="rounded-md bg-amber-500/10 border border-amber-500/20 px-3 py-2 text-xs text-amber-600 dark:text-amber-400">
                You are not currently assigned to any project. An issue must be associated with an assigned project.
              </div>
            )}

            <Field label="Issue Title *">
              <input
                value={formData.title}
                onChange={(e) => setFormData((s) => ({ ...s, title: e.target.value }))}
                placeholder="Brief summary..."
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </Field>

            <Field label="Description *">
              <textarea
                value={formData.description}
                onChange={(e) => setFormData((s) => ({ ...s, description: e.target.value }))}
                placeholder="Detailed description..."
                rows={3}
                className="w-full rounded-md border border-input bg-card px-3 py-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
              />
            </Field>

            <Field label="Issue Type *">
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

            <Field label="Priority *">
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
                disabled={submittingIssue || userProjects.length === 0}
                className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
                title={userProjects.length === 0 ? "No project assigned" : undefined}
              >
                {submittingIssue ? "Raising..." : "Raise Issue"}
              </button>
            </div>
          </div>

        </Modal>

      )}

    </section>

  );

}



// ---------- Type styles helper ----------
const getTypeStyles = (type: string) => {
  const t = (type || "").toLowerCase();
  if (t.includes("wbs")) {
    return "bg-warning/15 text-warning border border-warning/30";
  } else if (
    t.includes("ready") ||
    t.includes("completed") ||
    t.includes("resolved") ||
    t.includes("approved") ||
    t.includes("selected")
  ) {
    return "bg-success/15 text-success border border-success/30";
  } else if (t.includes("rejected") || t.includes("cancelled") || t.includes("removal") || t.includes("resignation") || t.includes("offboard")) {
    return "bg-destructive/15 text-destructive border border-destructive/30";
  } else if (t.includes("changes") || t.includes("requirement") || t.includes("approval") || t.includes("postponed") || t.includes("lwd") || t.includes("extension")) {
    return "bg-warning/15 text-warning border border-warning/30";
  } else if (t.includes("appreciation") || t.includes("feedback")) {
    return "bg-chart-3/15 text-chart-3 border border-chart-3/30";
  } else if (
    t.includes("interview") ||
    t.includes("shuffle") ||
    t.includes("allocation") ||
    t.includes("assignment") ||
    t.includes("issue")
  ) {
    return "bg-info/15 text-info border border-info/30";
  }
  return "bg-muted text-foreground border border-border";
};

// ---------- Approvals ----------

export const getApprovalRequestTypeStyles = (type: string) => {
  const t = (type || "").toLowerCase();
  if (t.includes("requirement") || t.includes("customer")) {
    return "bg-purple-100 text-purple-800 border border-purple-200/80 dark:bg-purple-950/40 dark:text-purple-300 dark:border-purple-800/50";
  }
  if (t.includes("extension") || t.includes("timeline")) {
    return "bg-amber-100 text-amber-800 border border-amber-200/80 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800/50";
  }
  if (t.includes("allocation") || t.includes("resource")) {
    return "bg-sky-100 text-sky-800 border border-sky-200/80 dark:bg-sky-950/40 dark:text-sky-300 dark:border-sky-800/50";
  }
  if (t.includes("feedback")) {
    return "bg-emerald-100 text-emerald-800 border border-emerald-200/80 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800/50";
  }
  if (t.includes("wbs")) {
    return "bg-indigo-100 text-indigo-800 border border-indigo-200/80 dark:bg-indigo-950/40 dark:text-indigo-300 dark:border-indigo-800/50";
  }
  if (t.includes("budget")) {
    return "bg-teal-100 text-teal-800 border border-teal-200/80 dark:bg-teal-950/40 dark:text-teal-300 dark:border-teal-800/50";
  }
  if (t.includes("leadership") || t.includes("assignment")) {
    return "bg-blue-100 text-blue-800 border border-blue-200/80 dark:bg-blue-950/40 dark:text-blue-300 dark:border-blue-800/50";
  }
  return "bg-slate-100 text-slate-800 border border-slate-200/80 dark:bg-slate-800 dark:text-slate-200 dark:border-slate-700";
};

export function formatApprovalId(id: string): string {
  if (!id) return "";
  const match = id.match(/^APP-(?:REQ|EXT|ALLOC|FDBK)-([0-9a-fA-F-]+)$/i);
  if (match) {
    const raw = match[1].replace(/-/g, "");
    return `APP-${raw.slice(0, 8).toUpperCase()}`;
  }
  if (id.startsWith("APP-")) {
    const raw = id.slice(4).replace(/-/g, "");
    return `APP-${raw.slice(0, 8).toUpperCase()}`;
  }
  const clean = id.replace(/-/g, "");
  return `APP-${clean.slice(0, 8).toUpperCase()}`;
}

function ApprovalsTab() {

  const store = useDhStore((s) => s);

  const [selectedAppId, setSelectedAppId] = useState<string | null>(null);

  const [appComment, setAppComment] = useState("");

  const [approvalSearchQuery, setApprovalSearchQuery] = useState("");

  const [projectFilter, setProjectFilter] = useState("all");

  const [typeFilter, setTypeFilter] = useState("all");

  const [statusFilter, setStatusFilter] = useState("all");

  const { user, isBO, assignedProjects, isDhanshree } = useRoleContext();
  const { canManage } = usePermissions();
  const isAdmin = user?.role?.toLowerCase() === "admin";
  const canManageApprovals = true;




  const [isLoadingApprovals, setIsLoadingApprovals] = useState(false);

  const loadApprovals = useCallback(async () => {
    setIsLoadingApprovals(true);
    try {
      const [reqItems, extItems, allocItems, fdbkItems] = await Promise.all([
        fetchPendingApprovals().catch((err) => {
          console.error("Error loading approvals:", err);
          return [];
        }),
        fetchPendingExtensionApprovals().catch((err) => {
          console.error("Error loading extension approvals:", err);
          return [];
        }),
        fetchPendingAllocationApprovals().catch((err) => {
          console.error("Error loading allocation approvals:", err);
          return [];
        }),
        fetchPendingFeedbackApprovals().catch((err) => {
          console.error("Error loading feedback approvals:", err);
          return [];
        }),
      ]);

      const toMerge: DhCentralApproval[] = [];
      if (Array.isArray(reqItems)) {
        reqItems.forEach((item) => {
          let parsedComments: DhComment[] = [];
          try {
            if (item.commentsJson) {
              const raw = JSON.parse(item.commentsJson);
              if (Array.isArray(raw)) {
                const seenComments = new Set<string>();
                raw.forEach((c: any) => {
                  if (c && typeof c === "object" && !Array.isArray(c)) {
                    const text = (c.text || "").trim();
                    const key = c.id ? String(c.id) : `${c.authorName || ""}|${text}|${c.at || ""}`;
                    if (!seenComments.has(key)) {
                      seenComments.add(key);
                      parsedComments.push({
                        id: c.id || Math.random().toString(36).slice(2),
                        authorId: c.authorId || "",
                        authorName: c.authorName || "User",
                        text: c.text || "",
                        at: c.at || new Date().toISOString(),
                      });
                    }
                  }
                });
              }
            }
          } catch {}

          let parsedHistory: any[] = [];
          try {
            if (item.historyJson) {
              const raw = JSON.parse(item.historyJson);
              if (Array.isArray(raw)) {
                parsedHistory = raw.flat(Infinity).map((h: any) => ({
                  status: h.status || "",
                  at: h.at || new Date().toISOString(),
                  updatedBy: h.updatedBy || "",
                  comment: h.comment || "",
                  details: h.details || "",
                }));
              }
            }
          } catch {}

          const normStatus = (item.status || "").toLowerCase();
          const mappedStatus: DhCentralApproval["status"] = normStatus === "approved" ? "Approved"
            : normStatus === "rejected" ? "Rejected"
            : normStatus === "hold" ? "Hold"
            : normStatus === "request changes" ? "Request Changes"
            : "Pending";

          toMerge.push({
            id: `APP-REQ-${item.id}`,
            projectId: item.projectId,
            projectName: item.projectName || "Project",
            requestType: "Customer Requirement Approval",
            requestedBy: item.requestedByName,
            requestedById: item.requestedByEmployeeId || "",
            requestedDate: item.requestedDate || (item.createdAtUtc ? item.createdAtUtc.slice(0, 10) : ""),
            createdAtUtc: item.createdAtUtc,
            status: mappedStatus,
            description: `${item.requirementType}: ${item.title}\n\n${item.description}${item.attachmentFileName ? `\n\nAttachment: ${item.attachmentFileName}` : ""}`,
            comments: parsedComments,
            history: parsedHistory,
          });
        });
      }

      if (Array.isArray(extItems)) {
        extItems.forEach((item) => {
          let parsedComments: DhComment[] = [];
          if (item.commentsJson) {
            try {
              const rawParsed = JSON.parse(item.commentsJson);
              if (Array.isArray(rawParsed)) {
                parsedComments = rawParsed.map((c: any, idx: number) => ({
                  id: c.id || `c-${idx}`,
                  authorName: c.authorName || "Stakeholder",
                  authorEmail: c.authorEmail || "",
                  text: c.text || "",
                  at: c.at || new Date().toISOString(),
                }));
              }
            } catch {}
          }
          let parsedHistory: any[] = [];
          if (item.historyJson) {
            try {
              const rawH = JSON.parse(item.historyJson);
              if (Array.isArray(rawH)) {
                parsedHistory = rawH;
              }
            } catch {}
          }
          toMerge.push({
            id: `APP-EXT-${item.id}`,
            projectId: item.projectId,
            projectName: item.projectName || "Project",
            requestType: "Timeline Extension Approval",
            requestedBy: item.requestedByName,
            requestedById: item.requestedByEmployeeId || "",
            requestedDate: item.createdAtUtc ? item.createdAtUtc.slice(0, 10) : "",
            createdAtUtc: item.createdAtUtc,
            status: item.status === "Approved" ? "Approved" : item.status === "Rejected" ? "Rejected" : item.status === "Hold" ? "Hold" : item.status === "Request Changes" ? "Request Changes" : "Pending",
            description: `Timeline Extension: Requesting extension of ${item.extensionDays} days. New End Date: ${formatToDayMonthYear(item.requestedEndDate)}. Reason: ${item.reason}`,
            comments: parsedComments,
            history: parsedHistory.length > 0 ? parsedHistory : [
              {
                status: item.status === "Approved" ? "Approved" : item.status === "Rejected" ? "Rejected" : "Pending",
                at: item.createdAtUtc || new Date().toISOString(),
                updatedBy: item.requestedByName,
                details: `Requested extension to ${item.requestedEndDate}`,
              },
            ],
          });
        });
      }

      // Preserve any non-API local approvals in store, replace API approvals with freshly fetched items
            if (Array.isArray(allocItems)) {
        allocItems.forEach((item) => {
          let parsedComments: DhComment[] = [];
          if (item.commentsJson) {
            try {
              const rawParsed = JSON.parse(item.commentsJson);
              if (Array.isArray(rawParsed)) {
                parsedComments = rawParsed.map((c: any, idx: number) => ({
                  id: c.id || `c-${idx}`,
                  authorName: c.authorName || "Manager",
                  authorEmail: c.authorEmail || "",
                  text: c.text || "",
                  at: c.at || new Date().toISOString(),
                }));
              }
            } catch {}
          }
          let parsedHistory: any[] = [];
          if ((item as any).historyJson) {
            try {
              const rawH = JSON.parse((item as any).historyJson);
              if (Array.isArray(rawH)) {
                parsedHistory = rawH;
              }
            } catch {}
          }
          const normStatus = (item.status || "").toLowerCase();
          const mappedStatus: DhCentralApproval["status"] = normStatus === "approved" ? "Approved"
            : normStatus === "rejected" ? "Rejected"
            : normStatus === "hold" ? "Hold"
            : normStatus === "request changes" ? "Request Changes"
            : "Pending";

          const desc = [
            `Resource: ${item.employeeName}${item.employeeCode ? ` (${item.employeeCode})` : ""}`,
            `Allocation Duration: ${formatToDayMonthYear(item.allocationStartDate)} → ${formatToDayMonthYear(item.allocationEndDate)}`,
            `Billability: ${item.billability}`,
            `Resource Type: ${item.resourceType}`,
            `Role: ${item.isTeamLead ? "Team Lead" : "Team Member"}`,
          ].join("\n");

          toMerge.push({
            id: `APP-ALLOC-${item.id}`,
            projectId: item.projectId,
            projectName: item.projectName || "Project",
            requestType: "Resource Allocation Approval",
            requestedBy: item.requestedByName || "Project Manager",
            requestedById: item.requestedByEmployeeId || "",
            requestedDate: item.createdAtUtc ? item.createdAtUtc.slice(0, 10) : "",
            createdAtUtc: item.createdAtUtc,
            status: mappedStatus,
            description: desc,
            comments: parsedComments,
            history: parsedHistory.length > 0 ? parsedHistory : [
              {
                status: mappedStatus,
                at: item.createdAtUtc || new Date().toISOString(),
                updatedBy: item.requestedByName || "Requester",
                details: `Requested allocation for ${item.employeeName}`,
              },
            ],
          });
        });
      }

      if (Array.isArray(fdbkItems)) {
        fdbkItems.forEach((item) => {
          let parsedComments: DhComment[] = [];
          if (item.commentsJson) {
            try {
              const rawParsed = JSON.parse(item.commentsJson);
              if (Array.isArray(rawParsed)) {
                parsedComments = rawParsed.map((c: any, idx: number) => ({
                  id: c.id || `c-${idx}`,
                  authorName: c.authorName || "Reporting Manager",
                  authorEmail: c.authorEmail || "",
                  text: c.text || "",
                  at: c.at || new Date().toISOString(),
                }));
              }
            } catch {}
          }
          let parsedHistory: any[] = [];
          if (item.historyJson) {
            try {
              const rawH = JSON.parse(item.historyJson);
              if (Array.isArray(rawH)) {
                parsedHistory = rawH;
              }
            } catch {}
          }
          const normStatus = (item.status || "").toLowerCase();
          const mappedStatus: DhCentralApproval["status"] = normStatus === "approved" ? "Approved"
            : normStatus === "rejected" ? "Rejected"
            : normStatus === "hold" ? "Hold"
            : normStatus === "request changes" ? "Request Changes"
            : "Pending";

          const desc = [
            `Resource: ${item.employeeName}${item.employeeCode ? ` (${item.employeeCode})` : ""}`,
            `Request Type: Feedback Request`,
            `Note: ${item.requestNote || "No note provided"}`,
          ].join("\n");

          toMerge.push({
            id: `APP-FDBK-${item.id}`,
            projectId: item.projectId,
            projectName: item.projectName || "Project",
            requestType: "Feedback Request Approval",
            requestedBy: item.submittedByName || "Project Manager",
            requestedById: item.submittedByEmployeeId || "",
            requestedDate: item.createdAtUtc ? item.createdAtUtc.slice(0, 10) : "",
            createdAtUtc: item.createdAtUtc,
            status: mappedStatus,
            description: desc,
            comments: parsedComments,
            history: parsedHistory.length > 0 ? parsedHistory : [
              {
                status: mappedStatus,
                at: item.createdAtUtc || new Date().toISOString(),
                updatedBy: item.submittedByName || "Requester",
                details: `Requested feedback for ${item.employeeName}`,
              },
            ],
          });
        });
      }

      const allSortedApprovals = [...toMerge].sort((a, b) => {
        const timeA = a.createdAtUtc ? new Date(a.createdAtUtc).getTime() : (a.requestedDate ? new Date(a.requestedDate).getTime() : 0);
        const timeB = b.createdAtUtc ? new Date(b.createdAtUtc).getTime() : (b.requestedDate ? new Date(b.requestedDate).getTime() : 0);
        if (timeA !== timeB) return timeB - timeA;
        return (b.id || "").localeCompare(a.id || "");
      });
      dhStore.setApprovals(allSortedApprovals);
    } finally {
      setIsLoadingApprovals(false);
    }
  }, [user.id, user.email, user.role]);

  useEffect(() => {
    loadApprovals();
  }, [loadApprovals]);

  const selectedApproval = useMemo(() => {

    return store.approvals.find((a) => a.id === selectedAppId);

  }, [store.approvals, selectedAppId]);



  const approvalTypes = useMemo(() => {
    const types = new Set<string>();
    (store.approvals || []).forEach((a) => {
      if (a.requestType && a.requestType.trim()) {
        types.add(a.requestType.trim());
      }
    });
    return Array.from(types).sort();
  }, [store.approvals]);

  useEffect(() => {
    if (typeFilter !== "all" && !approvalTypes.includes(typeFilter)) {
      setTypeFilter("all");
    }
  }, [approvalTypes, typeFilter]);

  const approvalProjects = useMemo(() => {
    const map = new Map<string, string>();
    (store.approvals || []).forEach((a) => {
      if (a.projectId) {
        const name = a.projectName || assignedProjects.find((p) => p.id === a.projectId)?.name || a.projectId;
        map.set(a.projectId, name);
      }
    });
    return Array.from(map.entries())
      .map(([id, name]) => ({ id, name }))
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [assignedProjects, store.approvals]);

  useEffect(() => {
    if (projectFilter !== "all" && !approvalProjects.some((p) => p.id === projectFilter)) {
      setProjectFilter("all");
    }
  }, [approvalProjects, projectFilter]);

  const filteredApprovals = useMemo(() => {
    return store.approvals
      .filter((a) => {
        if (projectFilter !== "all" && a.projectId !== projectFilter) return false;
        if (typeFilter !== "all" && a.requestType !== typeFilter) return false;
        if (statusFilter !== "all" && a.status !== statusFilter) return false;

        if (approvalSearchQuery.trim()) {
          const q = approvalSearchQuery.trim().toLowerCase();
          const compactId = formatApprovalId(a.id).toLowerCase();
          const fullId = (a.id || "").toLowerCase();
          const extId = a.id ? `ext-${a.id.replace(/-/g, "").slice(0, 8).toLowerCase()}` : "";
          const matchesId = compactId.includes(q) || fullId.includes(q) || extId.includes(q);
          const matchesType = (a.requestType || "").toLowerCase().includes(q);
          const projName = (a.projectName || assignedProjects.find((p) => p.id === a.projectId)?.name || "").toLowerCase();
          const projCode = (assignedProjects.find((p) => p.id === a.projectId)?.projectCode || "").toLowerCase();
          const matchesProject = projName.includes(q) || projCode.includes(q);

          if (!matchesId && !matchesType && !matchesProject) return false;
        }

        return true;
      })
      .sort((a, b) => {
        const timeA = a.createdAtUtc ? new Date(a.createdAtUtc).getTime() : (a.requestedDate ? new Date(a.requestedDate).getTime() : 0);
        const timeB = b.createdAtUtc ? new Date(b.createdAtUtc).getTime() : (b.requestedDate ? new Date(b.requestedDate).getTime() : 0);
        if (timeA !== timeB) return timeB - timeA;
        return (b.id || "").localeCompare(a.id || "");
      });
  }, [store.approvals, projectFilter, typeFilter, statusFilter, approvalSearchQuery, assignedProjects]);

  const [approvalPage, setApprovalPage] = useState(1);
  const [approvalPageSize, setApprovalPageSize] = useState(15);

  useEffect(() => {
    setApprovalPage(1);
  }, [projectFilter, typeFilter, statusFilter, approvalSearchQuery]);

  const totalApprovals = filteredApprovals.length;
  const pageApprovals = useMemo(() => paginateSlice(filteredApprovals, approvalPage, approvalPageSize), [filteredApprovals, approvalPage, approvalPageSize]);



  const handleAction = async (status: DhCentralApproval["status"]) => {

    if (!selectedAppId) return;

    if (!appComment.trim()) {

      toast.error("Comments are mandatory for every central approval action!");

      return;

    }

    const currentApp = store.approvals.find((a) => a.id === selectedAppId);
    let handledByApi = false;
    if (currentApp && currentApp.requestType === "Customer Requirement Approval") {
      try {
        const rawReqId = currentApp.id.replace(/^APP-REQ-/, "");
        const updated = await takeProjectAdditionalRequirementAction(currentApp.projectId, rawReqId, status, appComment);
        if (updated) {
          dhStore.updateRequirementStatus(updated.id, status as any, user.id, user.name);
          const reqInStore = ((dhStore as any).getState?.().requirements || []).find((r: any) => r.id === updated.id || r.requirementId === updated.requirementId);
          if (reqInStore) {
            reqInStore.approvedAtUtc = updated.approvedAtUtc;
          }
        }
        dhStore.updateCentralApprovalStatus(selectedAppId, status, appComment, user.name, user.id);
        await loadApprovals();
        handledByApi = true;
      } catch (err: any) {
        console.error("Failed to update additional requirement approval on backend:", err);
        toast.error(err?.message || "Failed to update additional requirement approval on backend");
        return;
      }
    }

    if (currentApp && currentApp.requestType === "Resource Allocation Approval") {
      try {
        const rawAllocId = currentApp.id.replace(/^APP-ALLOC-/, "");
        await takeResourceAllocationAction(currentApp.projectId, rawAllocId, status, appComment);
        await loadApprovals();
        handledByApi = true;
      } catch (err: any) {
        console.error("Failed to update resource allocation approval on backend:", err);
      }
    }

    if (currentApp && currentApp.requestType === "Timeline Extension Approval") {
      try {
        const rawExtId = currentApp.id.replace(/^APP-EXT-/, "");
        const updatedExt = await takeProjectExtensionRequestAction(currentApp.projectId, rawExtId, status, appComment);
        if (status === "Approved" && updatedExt?.requestedEndDate) {
          dhStore.updateProjectEndDate(currentApp.projectId, updatedExt.requestedEndDate);
        }
        await loadApprovals();
        handledByApi = true;
      } catch (err: any) {
        console.error("Failed to update extension request approval on backend:", err);
      }
    }

    if (currentApp && currentApp.requestType === "Feedback Request Approval") {
      try {
        const rawFdbkId = currentApp.id.replace(/^APP-FDBK-/, "");
        await takeFeedbackApprovalAction(rawFdbkId, { status, comment: appComment });
        await loadApprovals();
        handledByApi = true;
      } catch (err: any) {
        console.error("Failed to update feedback request approval on backend:", err);
      }
    }

    if (!handledByApi) {
      dhStore.updateCentralApprovalStatus(selectedAppId, status, appComment, user.name, user.id);
    }
    toast.success(`Success: Approval Request marked as ${status}!`);
    setAppComment("");
    setSelectedAppId(null);

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

        {/* Search */}
        <div className="relative">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={approvalSearchQuery}
            onChange={(e) => setApprovalSearchQuery(e.target.value)}
            placeholder="Search by approval ID, request type, project..."
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border"
          />
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

              {approvalProjects.map((p) => (

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

        <table className="w-full min-w-[860px] table-fixed text-sm">
          <colgroup>
            <col style={{ width: "12%" }} />
            <col style={{ width: canManageApprovals ? "26%" : "36%" }} />
            <col style={{ width: "18%" }} />
            <col style={{ width: "16%" }} />
            <col style={{ width: "10%" }} />
            <col style={{ width: "9%" }} />
            {canManageApprovals ? <col style={{ width: "9%" }} /> : null}
          </colgroup>

          <thead className="app-columns-head sticky top-0 z-10 bg-card/95 backdrop-blur-md text-left text-xs text-muted-foreground border-b border-border shadow-2xs">
            <tr>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Approval ID</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Project</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Request Type</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Requested By</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Date</th>
              <th className="px-3 py-2.5 font-semibold text-muted-foreground">Status</th>
              {canManageApprovals && (
                <th className="px-3 py-2.5 font-semibold text-muted-foreground text-right">Actions</th>
              )}
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {pageApprovals.map((app) => (
              <tr key={app.id} className="hover:bg-accent/30">
                <td className="px-3 py-2.5 font-mono text-xs font-semibold text-foreground">
                  {formatApprovalId(app.id)}
                </td>
                <td className="px-3 py-2.5 font-medium text-foreground break-words whitespace-normal">{app.projectName}</td>
                <td className="px-3 py-2.5">
                  <span
                    className={cn(
                      "inline-flex items-center rounded-full px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-wider leading-tight text-center break-words max-w-full",
                      getApprovalRequestTypeStyles(app.requestType),
                    )}
                  >
                    {app.requestType}
                  </span>
                </td>
                <td className="whitespace-nowrap px-4 py-3.5">
                  {app.requestedBy ? (
                    <span
                      className="inline-flex items-center gap-2.5 text-foreground transition-colors hover:text-primary"
                    >
                      <Avatar name={app.requestedBy} size={28} />
                      <span className="font-semibold">{app.requestedBy}</span>
                    </span>
                  ) : (
                    <span className="text-muted-foreground">—</span>
                  )}
                </td>
                <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">
                  {formatToDayMonthYear(app.requestedDate)}
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
                            ? "bg-warning/15 text-warning border-warning/30"
                            : app.status === "Request Changes"
                              ? "bg-info/10 text-info border-info/30"
                              : "bg-muted text-muted-foreground border-border",
                    )}
                  >
                    {app.status}
                  </span>
                </td>
                {canManageApprovals && (
                  <td className="px-3 py-2.5 text-right space-x-1 whitespace-nowrap">
                    <button
                      onClick={() => setSelectedAppId(app.id)}
                      className={cn(
                        "rounded-md border px-2.5 py-1 text-xs font-medium transition-colors",
                        app.status === "Pending"
                          ? "border-primary/40 bg-primary/10 text-primary hover:bg-primary/20 font-semibold"
                          : "border-input bg-card text-primary hover:bg-accent"
                      )}
                    >
                      {app.status === "Pending" ? "Review & Action" : "View"}
                    </button>
                  </td>
                )}
              </tr>
            ))}
            {isLoadingApprovals && filteredApprovals.length === 0 ? (
              <tr>
                <td colSpan={canManageApprovals ? 7 : 6} className="px-3 py-10 text-center text-sm text-muted-foreground">
                  <div className="flex flex-col items-center justify-center gap-2">
                    <Loader2 className="h-5 w-5 animate-spin text-primary" />
                    <span>Loading approvals...</span>
                  </div>
                </td>
              </tr>
            ) : filteredApprovals.length === 0 ? (
              <tr>
                <td colSpan={canManageApprovals ? 7 : 6} className="px-3 py-10 text-center text-sm text-muted-foreground">
                  No approvals found
                </td>
              </tr>
            ) : null}
          </tbody>

        </table>

      </div>

      <TablePaginationFooter
        page={approvalPage}
        pageSize={approvalPageSize}
        total={totalApprovals}
        itemLabel="approvals"
        onPageChange={setApprovalPage}
        onPageSizeChange={setApprovalPageSize}
      />



      {selectedApproval && (

        <Modal

          title={`Review Request — ${formatApprovalId(selectedApproval.id)}`}

          onClose={() => setSelectedAppId(null)}

          wide

          draggable

        >

          <div className="space-y-4">

            <div className="bg-muted/30 border border-border rounded-lg p-3 text-xs leading-relaxed grid grid-cols-2 md:grid-cols-4 gap-3">

              <div>

                <span className="text-muted-foreground">Approval ID</span>

                <p className="font-mono font-semibold text-foreground">{formatApprovalId(selectedApproval.id)}</p>

              </div>

              <div>

                <span className="text-muted-foreground">Requested By</span>

                <p className="font-semibold">{selectedApproval.requestedBy}</p>

              </div>

              <div>

                <span className="text-muted-foreground">Submitted On</span>

                <p className="font-medium">{formatToDayMonthYear(selectedApproval.requestedDate) || selectedApproval.requestedDate}</p>

              </div>

              <div>

                <span className="text-muted-foreground block mb-1">Request Type</span>

                <span
                  className={cn(
                    "inline-flex items-center rounded-full px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider leading-tight text-center break-words",
                    getApprovalRequestTypeStyles(selectedApproval.requestType),
                  )}
                >
                  {selectedApproval.requestType}
                </span>

              </div>

            </div>



            <div className="rounded-lg border border-border p-3 bg-card space-y-1.5">

              <span className="text-xs font-bold text-muted-foreground uppercase">

                Description & Justification

              </span>

              <p className="text-sm text-foreground leading-relaxed font-medium">

                {selectedApproval.description}

              </p>

            </div>
            {/* Discussion Thread comments */}
            {(() => {
              const rawList = selectedApproval.comments || [];
              const seen = new Set<string>();
              const displayComments = rawList.filter((c) => {
                const text = (c.text || "").trim();
                const key = c.id ? String(c.id) : `${c.authorName || ""}|${text}|${c.at || ""}`;
                if (seen.has(key)) return false;
                seen.add(key);
                return true;
              });

              if (displayComments.length === 0) return null;

              return (
                <div className="rounded-lg border border-border bg-card p-3 space-y-2">
                  <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wide flex items-center gap-1.5">
                    <MessageSquare className="h-3.5 w-3.5 text-primary" /> Discussion Thread ({displayComments.length})
                  </span>
                  <div className="space-y-2 max-h-48 overflow-y-auto pl-1">
                    {displayComments.map((c, idx) => (
                      <div key={c.id || idx} className="text-xs rounded-md border border-border/60 bg-muted/20 p-2.5">
                        <div className="flex justify-between items-center text-muted-foreground text-[10px] mb-1">
                          <span className="font-semibold text-foreground">{c.authorName}</span>
                          <span>{formatToDayMonthYear(c.at)} {c.at ? new Date(c.at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : ''}</span>
                        </div>
                        <p className="text-foreground leading-normal whitespace-pre-wrap">{c.text}</p>
                      </div>
                    ))}
                  </div>
                </div>
              );
            })()}





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
            {/* Action Comments box: enabled when not Approved; locked when Approved */}
            {canManageApprovals && (
              selectedApproval.status !== "Approved" ? (
                <div className="space-y-2 border-t border-border pt-3">
                  <label className="text-xs font-semibold text-foreground block">
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
              ) : (
                <div className="rounded-lg border border-success/30 bg-success/10 p-3 text-xs text-success flex items-center gap-2">
                  <CheckCircle2 className="h-4 w-4 shrink-0" />
                  <span>
                    This request has been <strong>Approved</strong>. Further action comments cannot be added.
                  </span>
                </div>
              )
            )}

            {/* Audit Log History */}
            {selectedApproval.history && selectedApproval.history.length > 0 && (
              <div className="rounded-lg border border-border bg-card p-3 space-y-2">
                <span className="text-xs font-semibold text-muted-foreground uppercase tracking-wide">
                  Audit Log History
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
                          <strong className="text-foreground font-semibold">{h.status}</strong> by{" "}
                          {h.updatedBy}
                        </span>
                        <span>{formatToDayMonthYear(h.at || h.date)} {h.at ? new Date(h.at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : (h.time || '')}</span>
                      </div>
                      {h.comment && <p className="text-foreground mt-0.5">"{h.comment}"</p>}
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className="flex justify-end gap-2 border-t border-border pt-3">
              <button
                onClick={() => setSelectedAppId(null)}
                className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium hover:bg-accent"
              >
                Close
              </button>
              {canManageApprovals && selectedApproval.status !== "Approved" && (
                <>
                  <button
                    onClick={() => handleAction("Hold")}
                    disabled={!appComment.trim()}
                    className="inline-flex items-center gap-1 rounded-md border border-warning/30 bg-warning/10 px-4 py-2 text-xs font-medium text-warning hover:bg-warning/20 disabled:opacity-50"
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

  const store = useDhStore((s) => s);

  const [selectedAlertId, setSelectedAlertId] = useState<string | null>(null);

  const [alertSearchQuery, setAlertSearchQuery] = useState("");

  const [projFilter, setProjFilter] = useState("all");

  const [clientFilter, setClientFilter] = useState("all");

  const [prioFilter, setPrioFilter] = useState("all");

  const [typeFilter, setTypeFilter] = useState("all");

  const [statusFilter, setStatusFilter] = useState("all");



  // Modal states

  const [newChatMsg, setNewChatMsg] = useState("");

  const [pendingChatMsgs, setPendingChatMsgs] = useState<string[]>([]);

  const chatEndRef = useRef<HTMLDivElement | null>(null);

  const [selectedOwner, setSelectedOwner] = useState("");

  const [selectedResOwner, setSelectedResOwner] = useState("");

  const [selectedEscOwner, setSelectedEscOwner] = useState("");

  const [resDetails, setResDetails] = useState("");

  const [selectedStatus, setSelectedStatus] = useState<AlertStatus>("Open");

  const [approved, setApproved] = useState(false);

  const { user, assignedProjects: projectsList, assignedClients: clientsList, isDhanshree } = useRoleContext();
  const { canManage } = usePermissions();
  const isAdmin = user?.role?.toLowerCase() === "admin";
  const canManageAlerts = isAdmin || isDhanshree || canManage("alerts") || canManage("action-alerts");



  const allAlerts = store.alerts;



  const [loadingAlerts, setLoadingAlerts] = useState(false);







  const loadAlerts = useCallback(async () => {



    setLoadingAlerts(true);



    try {



      const data = await apiFetch<DhAlert[]>("/api/v1/action-centre/alerts");



      if (Array.isArray(data)) {



        const normalized = data.map((a: any) => ({

          ...a,

          comments: Array.isArray(a.comments) ? a.comments : [],

          attachments: Array.isArray(a.attachments) && a.attachments.length > 0

            ? a.attachments

            : (a.attachmentFileName ? [a.attachmentFileName] : []),

          history: Array.isArray(a.history) ? a.history : [],

        }));

        dhStore.setAlerts(normalized);



      }



    } catch (e) {



      console.error("Failed to load action centre alerts:", e);



    } finally {



      setLoadingAlerts(false);



    }



  }, []);







  useEffect(() => {



    loadAlerts();



  }, [loadAlerts, user?.id]);



  const filtered = useMemo(() => {
    return allAlerts
      .filter((a) => {
        const proj = projectsList.find((p) => p.id === a.projectId);
        if (projFilter !== "all" && a.projectId !== projFilter) return false;
        if (clientFilter !== "all" && proj?.clientId !== clientFilter && (a as any).customerId !== clientFilter) return false;
        if (prioFilter !== "all" && a.priority !== prioFilter) return false;
        if (typeFilter !== "all" && a.alertType !== typeFilter) return false;
        if (statusFilter !== "all" && a.status !== statusFilter) return false;

        if (alertSearchQuery.trim()) {
          const q = alertSearchQuery.trim().toLowerCase();
          const matchesId = (a.alertId || "").toLowerCase().includes(q) || (a.id || "").toLowerCase().includes(q);
          const projName = (a.projectName || proj?.name || "").toLowerCase();
          const projCode = (proj?.code || (a as any).projectCode || "").toLowerCase();
          const matchesProject = projName.includes(q) || projCode.includes(q);
          const alertTypeStr = (a.alertType || (a as any).kind || "").toLowerCase();
          const matchesType = alertTypeStr.includes(q);

          if (!matchesId && !matchesProject && !matchesType) return false;
        }

        return true;
      })
      .sort((a, b) => {
        const timeA = (a as any).createdAtUtc ? new Date((a as any).createdAtUtc).getTime() : (a.createdAt ? new Date(a.createdAt).getTime() : 0);
        const timeB = (b as any).createdAtUtc ? new Date((b as any).createdAtUtc).getTime() : (b.createdAt ? new Date(b.createdAt).getTime() : 0);
        if (timeA !== timeB) return timeB - timeA;
        return (b.id || "").localeCompare(a.id || "");
      });
  }, [allAlerts, projFilter, clientFilter, prioFilter, typeFilter, statusFilter, projectsList, alertSearchQuery]);

  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  useEffect(() => {
    setPage(1);
  }, [projFilter, clientFilter, prioFilter, typeFilter, statusFilter, alertSearchQuery]);

  const totalAlerts = filtered.length;
  const pageAlerts = useMemo(() => paginateSlice(filtered, page, pageSize), [filtered, page, pageSize]);



  const metrics = useMemo(() => {

    const total = allAlerts.length;

    const open = allAlerts.filter((a) => a.status === "Open").length;

    const critical = allAlerts.filter((a) => a.priority === "Critical").length;

    const resolved = allAlerts.filter((a) => a.status === "Resolved").length;

    const escalated = allAlerts.filter(

      (a) => a.priority === "Critical" || a.status === "Closed",

    ).length;

    return { total, open, critical, resolved, escalated };

  }, [allAlerts]);



  const selectedAlert = useMemo(() => {

    return allAlerts.find((a) => a.id === selectedAlertId);

  }, [allAlerts, selectedAlertId]);



  // Alerts raised by the Log Requirement flow (add service / scope cancellation)

  const isRequirementAlert = !!selectedAlert?.alertId?.startsWith("REQ-AL-");

  const isAlertAudience = Boolean(
    selectedAlert && user?.id && (
      (Array.isArray(selectedAlert.audienceUserIds) && selectedAlert.audienceUserIds.includes(user.id)) ||
      (selectedAlert.raisedByEmployeeId === user.id)
    )
  );

  const canActOnAlert = canManageAlerts || isAlertAudience;



  const allDisplayComments = useMemo(() => {

    const existing = selectedAlert?.comments || [];

    const pending = pendingChatMsgs.map((text, idx) => ({

      id: `pending-${idx}`,

      authorName: user?.name || "You",

      authorEmail: user?.email || "",

      text,

      at: new Date().toISOString(),

      isPending: true,

    }));

    return [...existing, ...pending];

  }, [selectedAlert?.comments, pendingChatMsgs, user?.name, user?.email]);



  const openDetails = (id: string) => {

    const alert = allAlerts.find((a) => a.id === id);

    if (alert) {

      setSelectedAlertId(id);

      setSelectedOwner(alert.owner || "");

      setSelectedResOwner(alert.resolutionOwner || "");

      setSelectedEscOwner(alert.escalationOwner || "");

      const formattedExpDate = formatToDayMonthYear(alert.expectedResolutionDate);

      setResDetails(

        alert.resolutionDetails ||

        (formattedExpDate ? `Expected Resolution Date: ${formattedExpDate}` : "")

      );

      setSelectedStatus(alert.status);

      setApproved(false);

      setNewChatMsg("");

      setPendingChatMsgs([]);

    }

  };



  const handleStageChatMessage = () => {

    if (!newChatMsg.trim()) return;

    const msg = newChatMsg.trim().slice(0, 50);

    setPendingChatMsgs((prev) => [...prev, msg]);

    setNewChatMsg("");

  };



  const handleUpdateAlert = async () => {

    if (!selectedAlertId) return;

    try {

      const allCommentsToSend = [...pendingChatMsgs];

      if (newChatMsg.trim()) {

        allCommentsToSend.push(newChatMsg.trim().slice(0, 50));

      }

      await apiFetch(`/api/v1/action-centre/alerts/${selectedAlertId}/governance`, {

        method: "PUT",

        headers: { "Content-Type": "application/json" },

        body: JSON.stringify({

          status: selectedStatus,

          owner: selectedOwner || undefined,

          resolutionOwner: selectedResOwner || undefined,

          escalationOwner: selectedEscOwner || undefined,

          resolutionDetails: resDetails,

          comment: allCommentsToSend.length === 1 ? allCommentsToSend[0] : undefined,

          comments: allCommentsToSend.length > 1 ? allCommentsToSend : undefined,

        }),

      });

      dhStore.updateGovernanceAlert(

        selectedAlertId,

        {

          status: selectedStatus,

          owner: selectedOwner,

          resolutionOwner: selectedResOwner,

          escalationOwner: selectedEscOwner,

          resolutionDetails: resDetails,

        },

        allCommentsToSend.join("\n"),

        user.id,

        user.name,

      );

      toast.success("Governance changes saved successfully!");

      setPendingChatMsgs([]);

      setNewChatMsg("");

      setSelectedAlertId(null);

      await loadAlerts();

    } catch (e: any) {

      toast.error(e?.message || "Failed to update alert");

    }

  };



  const alertTypes = useMemo(() => {
    const types = new Set<string>();
    (allAlerts || []).forEach((a) => {
      const t = a.alertType || (a as any).kind;
      if (t && t.trim()) {
        types.add(t.trim());
      }
    });
    return Array.from(types).sort();
  }, [allAlerts]);

  useEffect(() => {
    if (typeFilter !== "all" && !alertTypes.includes(typeFilter)) {
      setTypeFilter("all");
    }
  }, [alertTypes, typeFilter]);

  const alertProjects = useMemo(() => {
    const map = new Map<string, string>();
    (allAlerts || []).forEach((a) => {
      if (a.projectId) {
        const proj = projectsList.find((p) => p.id === a.projectId);
        const name = a.projectName || proj?.name || a.projectId;
        map.set(a.projectId, name);
      }
    });
    return Array.from(map.entries())
      .map(([id, name]) => ({ id, name }))
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [allAlerts, projectsList]);

  useEffect(() => {
    if (projFilter !== "all" && !alertProjects.some((p) => p.id === projFilter)) {
      setProjFilter("all");
    }
  }, [alertProjects, projFilter]);



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

        {/* Filters Panel */}

        <header className="border-b border-border p-4 space-y-3">

          <div className="flex items-center gap-2">

            <ShieldAlert className="h-4.5 w-4.5 text-yellow-500" />

            <h3 className="text-sm font-semibold">PMO Health & Governance Governance Panel</h3>

          </div>

          {/* Search */}
          <div className="relative">
            <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <input
              value={alertSearchQuery}
              onChange={(e) => setAlertSearchQuery(e.target.value)}
              placeholder="Search by alert ID, project name, alert type..."
              className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring border-border"
            />
          </div>

          <div className="grid grid-cols-2 md:grid-cols-5 gap-2.5 text-xs">

            <div className="flex flex-col gap-1">

              <span className="text-[10px] font-bold text-muted-foreground uppercase">Project</span>

              <select

                value={projFilter}

                onChange={(e) => setProjFilter(e.target.value)}

                className="form-input rounded-md border border-border p-1.5 bg-card"

              >

                <option value="all">All Projects</option>

                {alertProjects.map((p) => (

                  <option key={p.id} value={p.id}>

                    {p.name}

                  </option>

                ))}

              </select>

            </div>

            <div className="flex flex-col gap-1">

              <span className="text-[10px] font-bold text-muted-foreground uppercase">

                Customer

              </span>

              <select

                value={clientFilter}

                onChange={(e) => setClientFilter(e.target.value)}

                className="form-input rounded-md border border-border p-1.5 bg-card"

              >

                <option value="all">All Customers</option>

                {(clientsList || []).map((c) => (

                  <option key={c.id} value={c.id}>

                    {c.name}

                  </option>

                ))}

              </select>

            </div>

            <div className="flex flex-col gap-1">

              <span className="text-[10px] font-bold text-muted-foreground uppercase">

                Priority

              </span>

              <select

                value={prioFilter}

                onChange={(e) => setPrioFilter(e.target.value)}

                className="form-input rounded-md border border-border p-1.5 bg-card"

              >

                <option value="all">All Priorities</option>

                {(["Low", "Medium", "High", "Critical"] as const).map((pr) => (

                  <option key={pr} value={pr}>

                    {pr}

                  </option>

                ))}

              </select>

            </div>

            <div className="flex flex-col gap-1">

              <span className="text-[10px] font-bold text-muted-foreground uppercase">

                Alert Type

              </span>

              <select

                value={typeFilter}

                onChange={(e) => setTypeFilter(e.target.value)}

                className="form-input rounded-md border border-border p-1.5 bg-card"

              >

                <option value="all">All Types</option>

                {alertTypes.map((t) => (

                  <option key={t} value={t}>

                    {t}

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

                {(

                  [

                    "Open",

                    "Acknowledged",

                    "In Progress",

                    "Waiting for Customer",

                    "Resolved",

                    "Closed",

                  ] as const

                ).map((s) => (

                  <option key={s} value={s}>

                    {s}

                  </option>

                ))}

              </select>

            </div>

          </div>

        </header>



        {filtered.length === 0 ? (

          <div className="p-8 text-center">

            <p className="text-sm text-muted-foreground">

              No governance alerts found matching the active filters or search.

            </p>

          </div>

        ) : (

          <div className="overflow-x-auto">

            <table className="w-full min-w-[1100px] table-fixed text-sm">
              <colgroup>
                <col style={{ width: "19%" }} />
                <col style={{ width: "17%" }} />
                <col style={{ width: "14%" }} />
                <col style={{ width: "8%" }} />
                <col style={{ width: "14%" }} />
                <col style={{ width: "12%" }} />
                <col style={{ width: "8%" }} />
                <col style={{ width: "8%" }} />
              </colgroup>

              <thead className="app-columns-head sticky top-0 z-10 bg-card/95 backdrop-blur-md text-left text-xs text-muted-foreground border-b border-border shadow-2xs">
                <tr>
                  <th className="px-3 py-2.5 font-semibold text-muted-foreground">Alert Title</th>
                  <th className="px-3 py-2.5 font-semibold text-muted-foreground">Project Name</th>
                  <th className="px-3 py-2.5 font-semibold text-muted-foreground">Alert Type</th>
                  <th className="px-3 py-2.5 font-semibold text-muted-foreground">Priority</th>
                  <th className="px-3 py-2.5 font-semibold text-muted-foreground">Raised By</th>
                  <th className="px-3 py-2.5 font-semibold text-muted-foreground">Raised Date</th>
                  <th className="px-3 py-2.5 font-semibold text-muted-foreground">Status</th>
                  <th className="px-3 py-2.5 font-semibold text-muted-foreground text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border">
                {pageAlerts.map((alert) => {
                  const project = projectsList.find((p) => p.id === alert.projectId);
                  const projectName = alert.projectName || project?.name || "—";

                  return (
                    <tr key={alert.id} className="hover:bg-accent/30">
                      <td className="px-3 py-2.5 font-medium text-foreground break-words whitespace-normal [overflow-wrap:anywhere]">
                        {alert.alertId ? (
                          <span className="font-mono text-[10px] text-foreground block font-semibold leading-tight mb-0.5">
                            {alert.alertId}
                          </span>
                        ) : null}
                        <span className="block break-words whitespace-normal [overflow-wrap:anywhere]">
                          {alert.title}
                        </span>
                      </td>
                      <td className="px-3 py-2.5 text-xs font-semibold text-foreground break-words whitespace-normal">
                        {projectName}
                      </td>

                      <td className="px-3 py-2.5">
                        <span
                          className={cn(
                            "inline-flex items-center rounded-full px-2 py-0.5 text-[9px] font-bold leading-tight break-words max-w-full",
                            getTypeStyles(alert.alertType || alert.kind),
                          )}
                        >
                          {alert.alertType || alert.kind}
                        </span>
                      </td>

                      <td className="px-3 py-2.5">

                        <PriorityPill priority={alert.priority.toLowerCase() as any} />

                      </td>

                      <td className="px-3 py-2.5 text-xs font-medium">{alert.raisedByName}</td>

                      <td className="px-3 py-2.5 text-xs tabular-nums text-foreground">

                        {new Date(alert.createdAt).toLocaleDateString()}

                      </td>

                      <td className="px-3 py-2.5">

                        <span

                          className={cn(

                            "inline-flex rounded-full border px-2 py-0.5 text-[10px] font-medium capitalize",

                            alert.status === "Open"

                              ? "bg-warning/15 text-warning border-warning/30"

                              : alert.status === "In Progress"

                                ? "bg-info/15 text-info border-info/30"

                                : alert.status === "Resolved" || alert.status === "Closed"

                                  ? "bg-success/15 text-success border-success/30"

                                  : alert.status === "Waiting for Customer"

                                    ? "bg-chart-3/15 text-chart-3 border-chart-3/30"

                                    : "bg-muted text-foreground border-border",

                          )}

                        >

                          {alert.status}

                        </span>

                      </td>

                      <td className="px-3 py-2.5 text-right">
                        <button
                          onClick={() => openDetails(alert.id)}
                          className="rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent font-medium text-primary cursor-pointer"
                        >
                          Review details
                        </button>
                      </td>

                    </tr>

                  );

                })}

              </tbody>

            </table>

          </div>

        )}

        <TablePaginationFooter
          page={page}
          pageSize={pageSize}
          total={totalAlerts}
          itemLabel="alerts"
          onPageChange={setPage}
          onPageSizeChange={setPageSize}
        />

      </section>



      {/* Alert Details Modal */}

      {selectedAlert && (

        <Modal

          title={

            selectedAlert.kind === "Escalation"

              ? `Escalation Review Details — ${selectedAlert.alertId || "ALT-GEN"}`

              : `Governance Alert Details — ${selectedAlert.alertId || "ALT-GEN"}`

          }

          onClose={() => setSelectedAlertId(null)}

          wide

          draggable

        >

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">

            {/* Left side details (md:col-span-2) */}

            <div className="md:col-span-2 space-y-4">

              <div className="rounded-lg border border-border p-3 bg-muted/10 space-y-1">

                <span className="font-semibold text-[10px] text-muted-foreground uppercase">

                  {selectedAlert.kind === "Escalation" ? "Escalation Subject" : "Alert Title"}

                </span>

                <p className="text-sm font-bold text-foreground">{selectedAlert.title}</p>

              </div>



              {selectedAlert.kind === "Escalation" ? (

                <div className="bg-muted/30 border border-border rounded-lg p-3 grid grid-cols-2 gap-3">

                  <div>

                    <span className="text-[9px] uppercase font-bold text-muted-foreground block">

                      Service Name

                    </span>

                    <span className="font-semibold text-foreground">

                      {selectedAlert.serviceName || "—"}

                    </span>

                  </div>

                  <div>

                    <span className="text-[9px] uppercase font-bold text-muted-foreground block">

                      Alert Type

                    </span>

                    <span className="font-semibold text-foreground">

                      {selectedAlert.alertType || selectedAlert.escalationType || "—"}

                    </span>

                  </div>

                  <div>

                    <span className="text-[9px] uppercase font-bold text-muted-foreground block">

                      Raised By

                    </span>

                    <span className="font-semibold text-foreground">

                      {selectedAlert.raisedByName || "—"}

                    </span>

                  </div>

                  {selectedAlert.expectedResolutionDate && (

                    <div>

                      <span className="text-[9px] uppercase font-bold text-muted-foreground block">

                        Expected Resolution Date

                      </span>

                      <span className="font-semibold text-foreground">

                        {formatToDayMonthYear(selectedAlert.expectedResolutionDate)}

                      </span>

                    </div>

                  )}

                </div>

              ) : (

                <div className="bg-muted/30 border border-border rounded-lg p-3 grid grid-cols-2 gap-3">

                  <div>

                    <span className="text-[9px] uppercase font-bold text-muted-foreground block">

                      Alert Type

                    </span>

                    <span className="font-semibold text-primary">

                      {selectedAlert.alertType || "—"}

                    </span>

                  </div>

                  <div>

                    <span className="text-[9px] uppercase font-bold text-muted-foreground block">

                      Raised By

                    </span>

                    <span className="font-semibold text-foreground">

                      {selectedAlert.raisedByName || "—"}

                    </span>

                  </div>

                </div>

              )}



              <div className="rounded-lg border border-border p-3 bg-card space-y-2">

                <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">

                  Full Description

                </span>

                <p className="text-xs text-foreground leading-relaxed font-medium">

                  {selectedAlert.description || "No full description provided."}

                </p>

              </div>



              {/* Discussion Chat Thread (Swapped to left side with wide view) */}

              <div className="rounded-lg border border-border p-3 bg-card space-y-2.5">

                <div className="flex items-center justify-between border-b border-border pb-1.5">

                  <span className="font-semibold text-[10px] text-muted-foreground uppercase flex items-center gap-1.5">

                    <MessageSquare className="h-3.5 w-3.5 text-primary" /> Discussion Chat Thread

                  </span>

                  <span className="text-[10px] text-muted-foreground font-medium">

                    {allDisplayComments.length} {allDisplayComments.length === 1 ? "message" : "messages"}

                  </span>

                </div>



                {/* WhatsApp-Style Chat Area with scroll after 3 chats (Like Status Transitions Timeline) */}

                <div className="flex flex-col space-y-2 max-h-36 overflow-y-auto p-2.5 rounded-md bg-[#efeae2]/30 border border-border">

                  {allDisplayComments.map((cm: any, idx: number) => {

                    const isMe = (cm.authorEmail && user.email && cm.authorEmail.toLowerCase() === user.email.toLowerCase()) ||

                                 (cm.authorName && user.name && cm.authorName.toLowerCase() === user.name.toLowerCase());

                    const timeStr = cm.at

                      ? new Date(cm.at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })

                      : "";

                    const dateStr = formatToDayMonthYear(cm.at);



                    return (

                      <div

                        key={cm.id || idx}

                        className={cn(

                          "flex flex-col max-w-[80%] rounded-lg px-3 py-1.5 text-xs shadow-xs",

                          isMe

                            ? "self-end ml-auto bg-emerald-100 text-emerald-950 border border-emerald-300 rounded-tr-none"

                            : "self-start mr-auto bg-muted text-foreground border border-border rounded-tl-none"

                        )}

                      >

                        <div className="flex items-center justify-between gap-3 text-[10px] pb-1 border-b border-black/5 font-semibold">

                          <span className={cn(isMe ? "text-emerald-800" : "text-primary")}>

                            {isMe ? "You" : cm.authorName || "Stakeholder"}

                            {cm.isPending && (

                              <span className="ml-1 text-[9px] font-normal text-muted-foreground italic">(staged)</span>

                            )}

                          </span>

                          <span className="text-[9px] text-muted-foreground font-normal tabular-nums">

                            {dateStr} {timeStr}

                          </span>

                        </div>

                        <p className="mt-0.5 text-xs break-words whitespace-pre-wrap leading-relaxed">

                          {cm.text}

                        </p>

                      </div>

                    );

                  })}

                  {allDisplayComments.length === 0 && (

                    <div className="flex flex-col items-center justify-center py-4 text-center text-muted-foreground">

                      <MessageSquare className="h-5 w-5 stroke-[1.5] mb-1 opacity-40" />

                      <span className="text-xs italic">No chat messages yet.</span>

                      <span className="text-[10px]">Type below and click Send (up to 50 characters).</span>

                    </div>

                  )}

                  <div ref={chatEndRef} />

                </div>



                {/* 50-Character Chat Input with live remaining counter and Send button */}

                <div className="flex items-center gap-2 pt-1">

                  <div className="relative flex-1">

                    <input

                      type="text"

                      maxLength={50}

                      value={newChatMsg}

                      onChange={(e) => setNewChatMsg(e.target.value)}

                      onKeyDown={(e) => {

                        if (e.key === "Enter" && !e.shiftKey) {

                          e.preventDefault();

                          handleStageChatMessage();

                        }

                      }}

                      placeholder="Type a message (max 50 chars)..."

                      className="w-full rounded-md border border-border bg-card px-3 py-2 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring pr-20"

                    />

                    <span className={cn(

                      "absolute right-2.5 top-1/2 -translate-y-1/2 text-[10px] font-semibold select-none",

                      50 - (newChatMsg || "").length <= 10 ? "text-red-500 font-bold" : "text-muted-foreground"

                    )}>

                      {50 - (newChatMsg || "").length} left

                    </span>

                  </div>

                  <button

                    type="button"

                    onClick={handleStageChatMessage}

                    disabled={!newChatMsg.trim()}

                    className="inline-flex items-center gap-1 rounded-md bg-emerald-600 hover:bg-emerald-700 text-white px-3.5 py-2 text-xs font-bold transition-colors disabled:opacity-40 disabled:cursor-not-allowed shadow-xs cursor-pointer shrink-0"

                  >

                    <Send className="h-3 w-3" /> Send

                  </button>

                </div>

              </div>



              {/* Status Transitions Timeline (Format: day-month-year) */}

              {selectedAlert.history && selectedAlert.history.length > 0 && (

                <div className="rounded-lg border border-border p-3 bg-card space-y-2">

                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">

                    Status Transitions Timeline

                  </span>

                  <div className="space-y-2 pl-1 max-h-36 overflow-y-auto pr-1">
                    {(selectedAlert.history || []).map((h: any, idx) => {
                      const dateStr = formatToDayMonthYear(h.at || h.date);
                      const timeStr = h.at ? new Date(h.at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }) : (h.time || "");
                      const rawText = h.action || `Status transitioned to ${h.status || ""} by ${h.updatedBy || h.by || ""}${h.details ? ` — "${h.details}"` : ""}`;

                      let action = rawText;
                      let remark = "";
                      if (rawText.includes(" — ")) {
                        const parts = rawText.split(" — ");
                        action = parts[0];
                        remark = parts.slice(1).join(" — ").replace(/^["']|["']$/g, "").trim();
                      } else if (rawText.includes(". Comment: ")) {
                        const parts = rawText.split(". Comment: ");
                        action = parts[0] + ".";
                        remark = parts.slice(1).join(". Comment: ").replace(/^["']|["']$/g, "").trim();
                      } else if (rawText.startsWith("Comment added: \"") && rawText.endsWith("\"")) {
                        action = "Comment added:";
                        remark = rawText.slice(15, -1).trim();
                      }

                      return (
                        <div key={idx} className="flex items-start gap-2 text-[11px] leading-relaxed">
                          <span className="shrink-0 font-medium text-muted-foreground tabular-nums whitespace-nowrap">
                            {dateStr} {timeStr}:
                          </span>
                          <span className="min-w-0 flex-1 break-words text-foreground/90">
                            {remark ? (
                              <>
                                <span className="font-semibold text-foreground">{action}</span>{" "}
                                <span className="text-muted-foreground font-normal italic">"{remark}"</span>
                              </>
                            ) : (
                              <span className="font-medium">{action}</span>
                            )}
                          </span>
                        </div>
                      );
                    })}
                  </div>

                </div>

              )}

            </div>



            {/* Right side controls (md:col-span-1) */}

            <div className="space-y-4 flex flex-col justify-between">

              <div className="space-y-3">

                <div className="rounded-lg border border-border p-3 bg-card space-y-2">

                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">

                    Project Link

                  </span>

                  {selectedAlert.projectId ? (

                    <Link

                      to="/projects/$projectId"

                      params={{ projectId: selectedAlert.projectId }}

                      hash="health-alerts"

                      className="inline-flex items-center gap-1 bg-primary/10 text-primary border border-primary/20 rounded-md px-2.5 py-1.5 font-bold hover:bg-primary/20 text-xs w-full justify-between"

                    >

                      <span>
                        {selectedAlert.projectName ||
                          projectsList.find((p) => p.id === selectedAlert.projectId)?.name ||
                          "Go to project"}
                      </span>

                      <ExternalLink className="h-3 w-3" />

                    </Link>

                  ) : (

                    <span className="text-muted-foreground italic">No linked project.</span>

                  )}

                </div>



                <div className="rounded-lg border border-border p-3 bg-card space-y-1.5">

                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block">

                    Attachments

                  </span>

                  {selectedAlert.attachments && selectedAlert.attachments.length > 0 ? (

                    <div className="space-y-1">

                      {(selectedAlert.attachments || []).map((file, idx) => (

                        <div

                          key={idx}

                          onClick={async () => {

                            try {

                              const downloadUrl = (selectedAlert as any).attachmentUrl || `/api/v1/action-centre/alerts/${selectedAlert.id}/attachment`;

                              const blob = await apiFetchBlob(downloadUrl);

                              const ext = file.split(".").pop()?.toLowerCase() || "";

                              let mime = blob.type;

                              if (!mime || mime === "application/octet-stream") {

                                if (ext === "pdf") mime = "application/pdf";

                                else if (ext === "png") mime = "image/png";

                                else if (ext === "jpg" || ext === "jpeg") mime = "image/jpeg";

                                else if (ext === "txt") mime = "text/plain";

                              }

                              const typedBlob = new Blob([blob], { type: mime });

                              const blobUrl = URL.createObjectURL(typedBlob);

                              window.open(blobUrl, "_blank", "noopener,noreferrer");

                            } catch (err: any) {

                              toast.error(err?.message || "Failed to open attachment");

                            }

                          }}

                          className="flex items-center gap-1.5 text-[10px] text-primary hover:underline cursor-pointer"

                          title="Click to view / download file"

                        >

                          <Paperclip className="h-3 w-3 text-muted-foreground shrink-0" />

                          <span className="truncate">{file}</span>

                        </div>

                      ))}

                    </div>

                  ) : (

                    <span className="text-muted-foreground italic text-[10px]">

                      No attachments.

                    </span>

                  )}

                </div>



                {/* Escalated To */}

                {selectedAlert.kind === "Escalation" && selectedAlert.escalatedTo && (

                  <div className="rounded-lg border border-border p-3 bg-muted/10 space-y-1">

                    <span className="font-semibold text-[10px] text-muted-foreground uppercase block">

                      Escalated To

                    </span>

                    <p

                      className="text-xs font-semibold text-foreground truncate"

                    >

                      {selectedAlert.escalatedTo.join(", ")}

                    </p>

                  </div>

                )}



                {/* Status Switcher */}

                <div className="rounded-lg border border-border p-3 bg-card space-y-2">

                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block">

                    {isRequirementAlert ? "Status" : "Set Status"}

                  </span>

                  {isRequirementAlert ? (

                    <div

                      className={cn(

                        "w-full rounded-md border p-2 text-xs font-bold shadow-xs",

                        selectedAlert.status === "Resolved" || selectedAlert.status === "Closed"

                          ? "bg-emerald-50 border-emerald-200 text-emerald-700"

                          : selectedAlert.status === "Open"

                            ? "bg-orange-50 border-orange-200 text-orange-700"

                            : "bg-gray-50 border-gray-200 text-muted-foreground",

                      )}

                    >

                      {selectedAlert.status}

                    </div>

                  ) : (

                    <select

                      value={selectedStatus}

                      onChange={(e) => setSelectedStatus(e.target.value as any)}

                      className={cn(

                        "w-full rounded-md border p-2 text-xs font-bold shadow-xs transition-colors cursor-pointer outline-none focus-visible:ring-1 focus-visible:ring-ring",

                        selectedStatus === "Resolved" || selectedStatus === "Closed"

                          ? "bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100"

                          : selectedStatus === "Open"

                            ? "bg-orange-50 border-orange-200 text-orange-700 hover:bg-orange-100"

                            : selectedStatus === "In Progress"

                              ? "bg-blue-50 border-blue-200 text-blue-700 hover:bg-blue-100"

                              : selectedStatus === "Waiting for Customer"

                                ? "bg-purple-50 border-purple-200 text-purple-700 hover:bg-purple-100"

                                : "bg-gray-50 border-gray-200 text-muted-foreground hover:bg-gray-100",

                      )}

                    >

                      {selectedAlert.kind === "Escalation"

                        ? (

                            [

                              "Open",

                              "Acknowledged",

                              "In Progress",

                              "Waiting for Customer",

                              "Resolved",

                              "Closed",

                            ] as const

                          ).map((s) => (

                            <option key={s} value={s}>

                              {s}

                            </option>

                          ))

                        : (["Open", "In Progress", "Resolved", "Closed"] as const).map((s) => (

                            <option key={s} value={s}>

                              {s}

                            </option>

                          ))}

                    </select>

                  )}

                </div>



                {/* Resolution Timeline Details (Placed under Set Status with readonly day-month-year date) */}

                <div className="rounded-lg border border-border p-3 bg-card space-y-2">

                  <span className="font-semibold text-[10px] text-muted-foreground uppercase block border-b border-border pb-1">

                    Resolution Timeline Details

                  </span>

                  <div className="space-y-1">

                    <span className="text-[10px] font-bold text-muted-foreground">Expected Resolution Date</span>

                    <input

                      type="text"

                      readOnly

                      value={formatToDayMonthYear(selectedAlert.expectedResolutionDate) || "—"}

                      className="w-full rounded-md border border-border bg-muted/40 px-2.5 py-1.5 text-xs font-semibold text-foreground outline-none cursor-default"

                    />

                  </div>

                </div>

              </div>



              <div className="flex justify-end gap-2 border-t border-border pt-3">
                {!canActOnAlert ? (
                  <button
                    onClick={() => setSelectedAlertId(null)}
                    className="rounded-md border border-input bg-card px-3.5 py-1.5 text-xs font-medium hover:bg-accent"
                  >
                    Close
                  </button>
                ) : isRequirementAlert ? (
                  <>
                    <button
                      onClick={() => {
                        setApproved(true);
                        toast.success("Requirement approved — click Update to save");
                      }}
                      className={cn(
                        "rounded-md border px-3.5 py-1.5 text-xs font-medium transition-colors",
                        approved
                          ? "border-emerald-600 bg-emerald-600 text-white"
                          : "border-emerald-300 bg-emerald-50 text-emerald-700 hover:bg-emerald-100",
                      )}
                    >
                      {approved ? "Approved ✓" : "Approve"}
                    </button>
                    <button
                      onClick={() => {
                        toast("Requirement rejected — manager notification will be enabled later");
                        setSelectedAlertId(null);
                      }}
                      className="rounded-md border border-red-300 bg-red-50 px-3.5 py-1.5 text-xs font-medium text-red-700 hover:bg-red-100"
                    >
                      Reject
                    </button>
                    <button
                      onClick={handleUpdateAlert}
                      disabled={!approved}
                      className={cn(
                        "rounded-md px-3.5 py-1.5 text-xs font-medium transition-colors",
                        approved
                          ? "bg-primary text-primary-foreground hover:bg-primary/90"
                          : "border border-border bg-muted text-muted-foreground cursor-not-allowed",
                      )}
                    >
                      Update
                    </button>
                  </>
                ) : (
                  <>
                    <button
                      onClick={() => setSelectedAlertId(null)}
                      className="rounded-md border border-input bg-card px-3.5 py-1.5 text-xs font-medium hover:bg-accent"
                    >
                      Cancel
                    </button>
                    <button
                      onClick={handleUpdateAlert}
                      className="rounded-md bg-primary px-3.5 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
                    >
                      Save Governance Changes
                    </button>
                  </>
                )}
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

  const { user, isBO } = useRoleContext();

  const [subTab, setSubTab] = useState<"Current" | "Archived">("Current");



  // Search state

  const [searchQuery, setSearchQuery] = useState("");



  // Filters state

  const [typeFilter, setTypeFilter] = useState("all");

  const [priorityFilter, setPriorityFilter] = useState("all");

  const [dateFilter, setDateFilter] = useState("");

  const [statusFilter, setStatusFilter] = useState("all");



  // Modal details state

  const [selectedNotifId, setSelectedNotifId] = useState<string | null>(() => {

    if (typeof window !== "undefined") {

      return new URLSearchParams(window.location.search).get("notifId");

    }

    return null;

  });



  useEffect(() => {

    if (typeof window !== "undefined") {

      const paramId = new URLSearchParams(window.location.search).get("notifId");

      if (paramId) {

        setSelectedNotifId(paramId);

        apiFetch(`/api/v1/action-centre/notifications/${paramId}/read`, { method: "PUT" }).catch(() => {});

        dhStore.markNotificationAsRead(paramId);

      }

    }

  }, []);

  const notifications = store.notifications || [];



  const [isLoadingNotifs, setIsLoadingNotifs] = useState(false);

  const fetchNotifications = useCallback(async () => {

    setIsLoadingNotifs(true);

    try {

      const data = await apiFetch<DhNotification[]>("/api/v1/action-centre/notifications");

      if (Array.isArray(data)) {

        dhStore.setNotifications(data);

      }

    } catch (e) {

      console.error("Failed to load notifications:", e);

    } finally {

      setIsLoadingNotifs(false);

    }

  }, []);



  useEffect(() => {

    fetchNotifications();

  }, [fetchNotifications, user?.id]);



  // Metrics

  const totalCount = notifications.length;

  const pendingCount = notifications.filter((n) => n.status === "Pending").length;

  const criticalPendingCount = notifications.filter(

    (n) => n.status === "Pending" && (n.priority === "Critical" || n.priority === "High"),

  ).length;

  const currentCount = notifications.filter((n) => (n.status || "").toLowerCase() !== "acknowledged").length;

  const archivedCount = notifications.filter((n) => (n.status || "").toLowerCase() === "acknowledged").length;

  // Available notification types dynamically derived from actual notifications in the system
  const availableNotificationTypes = useMemo(() => {
    const set = new Set<string>();
    notifications.forEach((n) => {
      const t = (n.type || "").trim();
      if (t) set.add(t);
    });
    return Array.from(set).sort((a, b) => a.localeCompare(b));
  }, [notifications]);

  useEffect(() => {
    if (typeFilter !== "all" && availableNotificationTypes.length > 0 && !availableNotificationTypes.includes(typeFilter)) {
      setTypeFilter("all");
    }
  }, [availableNotificationTypes, typeFilter]);

  // Timestamp formatting helper: DD-MM-YYYY HH:MM:SS (e.g. 16-11-2026 02:27:00)
  const formatNotifTimestamp = (dateStr?: string | null): string => {
    if (!dateStr) return "—";
    try {
      const d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      const year = d.getFullYear();
      const month = String(d.getMonth() + 1).padStart(2, "0");
      const day = String(d.getDate()).padStart(2, "0");
      const hours = String(d.getHours()).padStart(2, "0");
      const minutes = String(d.getMinutes()).padStart(2, "0");
      const seconds = String(d.getSeconds()).padStart(2, "0");
      return `${day}-${month}-${year} ${hours}:${minutes}:${seconds}`;
    } catch {
      return dateStr;
    }
  };



  // Status styles & icon helpers
  const getNotifStatusStyles = (status: string) => {
    const s = (status || "").toLowerCase().trim();
    if (s === "acknowledged" || s === "approved" || s === "accepted" || s === "resolved" || s === "selected" || s === "done") {
      return "bg-success/15 text-success border-success/30";
    }
    if (s === "assigned") {
      return "bg-indigo-50 text-indigo-700 border-indigo-200";
    }
    if (s === "edited") {
      return "bg-blue-50 text-blue-700 border-blue-200";
    }
    if (s === "created") {
      return "bg-sky-50 text-sky-700 border-sky-200";
    }
    if (s === "upload" || s === "uploaded") {
      return "bg-teal-50 text-teal-700 border-teal-200";
    }
    if (s === "hold" || s === "on hold" || s === "postponed") {
      return "bg-warning/15 text-warning border-warning/30";
    }
    if (s === "rejected" || s === "cancelled") {
      return "bg-destructive/15 text-destructive border-destructive/30";
    }
    if (s === "request change" || s === "request changes" || s === "requested changes" || s === "change_requested") {
      return "bg-chart-3/15 text-chart-3 border-chart-3/30";
    }
    return "bg-warning/15 text-warning border-warning/30";
  };

  const renderNotifStatusIcon = (status: string) => {
    const s = (status || "").toLowerCase().trim();
    if (s === "acknowledged" || s === "approved" || s === "accepted" || s === "resolved" || s === "selected" || s === "done") {
      return <Check className="h-2.5 w-2.5" />;
    }
    if (s === "assigned") {
      return <Check className="h-2.5 w-2.5 text-indigo-600" />;
    }
    if (s === "edited") {
      return <Pencil className="h-2.5 w-2.5" />;
    }
    if (s === "created") {
      return <Plus className="h-2.5 w-2.5" />;
    }
    if (s === "upload" || s === "uploaded") {
      return <Upload className="h-2.5 w-2.5" />;
    }
    if (s === "hold" || s === "on hold" || s === "postponed") {
      return <Pause className="h-2.5 w-2.5" />;
    }
    if (s === "rejected" || s === "cancelled") {
      return <X className="h-2.5 w-2.5" />;
    }
    if (s === "request change" || s === "request changes" || s === "requested changes" || s === "change_requested") {
      return <RotateCcw className="h-2.5 w-2.5 text-purple-600" />;
    }
    return <Clock className="h-2.5 w-2.5" />;
  };

  const availableStatuses = useMemo(() => {
    const defaultStatuses = ["Pending", "Created", "Assigned", "Upload", "Selected", "Approved", "Hold", "Postponed", "Request Change", "Request Changes", "Rejected", "Acknowledged", "Done", "Edited"];
    const found = new Set(defaultStatuses);
    notifications.forEach((n) => {
      if (n.status && n.status.trim()) found.add(n.status.trim());
    });
    return Array.from(found);
  }, [notifications]);




  // Filter & Search Logic

  const filteredNotifications = useMemo(() => {

    return notifications.filter((n) => {

      // 1. Sub-tab filter

      if (subTab === "Current") {

        const isCurrent = (n.status || "").toLowerCase() !== "acknowledged";

        if (!isCurrent) return false;

      } else {

        const isArchived = (n.status || "").toLowerCase() === "acknowledged";

        if (!isArchived) return false;

      }



      // 2. Search query filter (ID, Project, Task, Notification Type, Employee, Title)
      if (searchQuery.trim()) {
        const query = searchQuery.toLowerCase();
        const formattedCode = formatNotificationId(n.notificationCode || n.id).toLowerCase();
        const matchesCode = formattedCode.includes(query) || (n.notificationCode ? n.notificationCode.toLowerCase().includes(query) : false);
        const matchesId = n.id ? n.id.toLowerCase().includes(query) : false;
        const matchesProject = (n.relatedProject || "").toLowerCase().includes(query);
        const matchesTask = n.relatedTask ? n.relatedTask.toLowerCase().includes(query) : false;
        const matchesType = (n.type || "").toLowerCase().includes(query);
        const matchesEmployee = (n.raisedBy || "").toLowerCase().includes(query);
        const matchesTitle = (n.title || "").toLowerCase().includes(query);

        if (!matchesCode && !matchesId && !matchesProject && !matchesTask && !matchesType && !matchesEmployee && !matchesTitle) {
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
    }).sort((a, b) => {
      const timeA = (a as any).createdAtUtc ? new Date((a as any).createdAtUtc).getTime() : (a.createdAt ? new Date(a.createdAt).getTime() : 0);
      const timeB = (b as any).createdAtUtc ? new Date((b as any).createdAtUtc).getTime() : (b.createdAt ? new Date(b.createdAt).getTime() : 0);
      if (timeA !== timeB) return timeB - timeA;
      return (b.id || "").localeCompare(a.id || "");
    });
  }, [notifications, subTab, searchQuery, typeFilter, priorityFilter, dateFilter, statusFilter]);

  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  useEffect(() => {
    setPage(1);
  }, [subTab, searchQuery, typeFilter, priorityFilter, dateFilter, statusFilter]);

  const totalNotifications = filteredNotifications.length;
  const pageNotifications = useMemo(() => paginateSlice(filteredNotifications, page, pageSize), [filteredNotifications, page, pageSize]);



  const selectedNotification = useMemo(() => {

    return notifications.find((n) => n.id === selectedNotifId);

  }, [notifications, selectedNotifId]);



  const handleOpenDetails = (id: string) => {

    apiFetch(`/api/v1/action-centre/notifications/${id}/read`, { method: "PUT" }).catch(() => {});

    dhStore.markNotificationAsRead(id);

    setSelectedNotifId(id);
  };

  const handleArchiveNotification = async (id: string) => {
    try {
      await apiFetch(`/api/v1/action-centre/notifications/${id}/archive`, {
        method: "PUT",
        body: JSON.stringify({ comment: "Moved to archive by user" }),
      });
    } catch (e) {
      console.error("Failed to archive notification:", e);
    }
    dhStore.archiveNotification(id, user?.name || "Current User");
    setSelectedNotifId(null);
  };

  const totalSubtabCount = subTab === "Current" ? currentCount : archivedCount;



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

            <span className="font-bold text-foreground text-sm">Notification Inbox</span>

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

            placeholder="Search by ID, project, task, type, employee..."

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

              {availableNotificationTypes.map((t) => (

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

              {availableStatuses.map((st) => (

                <option key={st} value={st.toLowerCase()}>{st}</option>

              ))}

            </select>

          </div>

        </div>



        {/* Sub-tabs line selector */}

        <div className="flex gap-4 border-b border-border pb-1 mt-2">

          {(["Current", "Archived"] as const).map((st) => {

            const count = notifications.filter((n) => {

              if (st === "Current") {

                return (n.status || "").toLowerCase() !== "acknowledged";

              } else {

                return (n.status || "").toLowerCase() === "acknowledged";

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

          <table className="w-full min-w-[1100px] table-fixed text-sm leading-relaxed text-left">
            <colgroup>
              <col style={{ width: "24%" }} />
              <col style={{ width: "16%" }} />
              <col style={{ width: "14%" }} />
              <col style={{ width: "12%" }} />
              <col style={{ width: "13%" }} />
              <col style={{ width: "8%" }} />
              <col style={{ width: "6%" }} />
              <col style={{ width: "7%" }} />
            </colgroup>

            <thead className="app-columns-head sticky top-0 z-10 bg-card/95 backdrop-blur-md text-left text-xs text-muted-foreground border-b border-border shadow-2xs">

              <tr>

                <th className="px-3 py-2.5 font-semibold text-muted-foreground">Notification Title</th>

                <th className="px-3 py-2.5 font-semibold text-muted-foreground">Type</th>

                <th className="px-3 py-2.5 font-semibold text-muted-foreground">Related Project</th>

                <th className="px-3 py-2.5 font-semibold text-muted-foreground">Raised By</th>

                <th className="px-3 py-2.5 font-semibold text-muted-foreground">Timestamp</th>

                <th className="px-3 py-2.5 font-semibold text-muted-foreground">Status</th>

                <th className="px-3 py-2.5 font-semibold text-muted-foreground">Priority</th>

                <th className="px-3 py-2.5 font-semibold text-muted-foreground text-right">Actions</th>

              </tr>

            </thead>

            <tbody className="divide-y divide-border/60 align-middle">

              {filteredNotifications.length === 0 ? (

                <tr>

                  <td colSpan={8} className="p-8 text-center text-muted-foreground">

                    No notifications matching search and filters.

                  </td>

                </tr>

              ) : (

                pageNotifications.map((n) => (

                  <tr key={n.id} className="hover:bg-muted/10 transition-colors">

                    {/* Title */}

                    <td className="px-3 py-2.5">

                      <div className="flex items-start gap-1.5">

                        {n.unread && (

                          <span className="text-primary mt-1 text-[10px] select-none shrink-0">●</span>

                        )}

                        <div className="min-w-0 flex-1">

                          <span className="font-mono text-[10px] text-foreground block font-semibold leading-tight mb-0.5">

                            {formatNotificationId(n.notificationCode || n.id)}

                          </span>

                          <span

                            className="font-medium text-foreground break-words whitespace-normal block"

                          >

                            {n.title}

                          </span>

                        </div>

                      </div>

                    </td>



                    {/* Type Badge */}

                    <td className="px-3 py-2.5">

                      <span

                        className={cn(

                          "inline-flex items-center rounded-full px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-wider leading-tight text-center break-words max-w-full",

                          getTypeStyles(n.type),

                        )}

                      >

                        {n.type}

                      </span>

                    </td>



                    {/* Related Project */}

                    <td className="px-3 py-2.5 text-xs text-muted-foreground break-words whitespace-normal">

                      {n.relatedProject || "—"}

                    </td>



                    {/* Raised By */}

                    <td className="px-3 py-2.5 whitespace-nowrap">

                      <div className="flex items-center gap-2 truncate">

                        <Avatar name={n.raisedBy} size={24} />

                        <span className="text-xs truncate">{n.raisedBy}</span>

                      </div>

                    </td>



                    {/* Timestamp */}

                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground whitespace-nowrap font-mono">

                      {formatNotifTimestamp(n.createdAt)}

                    </td>



                    {/* Status Badge */}

                    <td className="px-3 py-2.5 whitespace-nowrap">

                      <span

                        className={cn(

                          "inline-flex rounded-full border px-2 py-0.5 text-[9px] font-bold capitalize items-center gap-1",

                          getNotifStatusStyles(n.status),

                        )}

                      >

                        {renderNotifStatusIcon(n.status)}

                        <span>{n.status}</span>

                      </span>

                    </td>



                    {/* Priority */}

                    <td className="px-3 py-2.5 whitespace-nowrap">

                      {n.priority === "-" ? (

                        <span className="text-muted-foreground font-semibold px-2">-</span>

                      ) : (

                        <PriorityPill priority={n.priority.toLowerCase() as any} />

                      )}

                    </td>



                    {/* Actions */}

                    <td className="px-3 py-2.5 pr-4 text-right whitespace-nowrap">

                      <button

                        onClick={() => handleOpenDetails(n.id)}

                        className="inline-flex items-center gap-1 rounded-md border border-input bg-card hover:bg-accent px-2.5 py-1 text-xs font-semibold cursor-pointer transition-colors text-foreground shadow-none"

                      >

                        <Eye className="h-3.5 w-3.5" /> View

                      </button>

                    </td>

                  </tr>

                ))

              )}

            </tbody>

          </table>

          <TablePaginationFooter
            page={page}
            pageSize={pageSize}
            total={totalNotifications}
            itemLabel="notifications"
            onPageChange={setPage}
            onPageSizeChange={setPageSize}
          />

        </div>

      </div>



      {/* Details & Interactive Comment Modal */}
      <NotificationDetailModal
        notification={selectedNotification}
        onClose={() => setSelectedNotifId(null)}
        onArchive={handleArchiveNotification}
        onActionComplete={async () => {
          await fetchNotifications();
          if (selectedNotification?.relatedTask) {
            const rawCode = selectedNotification.relatedTask.replace(/^ALLOC-/, "").toUpperCase();
            const matching = store.approvals.find((a) => a.id.toUpperCase().includes(rawCode));
            if (matching && selectedNotification.status) {
              dhStore.updateCentralApprovalStatus(
                matching.id,
                selectedNotification.status as any,
                "Action taken via notification",
                user.name,
                user.id,
              );
            }
          }
        }}
      />

    </>

  );

}



const NOTIFICATION_TYPES = [

  "New Project Assignment",

  "New Task Assignment",

  "WBS Assignment",

  "WBS Escalation",

  "Project Ready To Start",

  "Team Assignment",

  "Shadow Team Assignment",

  "Appreciation Received",

  "Feedback Received",

  "Issue Raised",

  "Issue Resolved",

  "Customer Interview Selected",

  "Customer Interview Rejected",

  "Customer Interview Postponed",

  "Additional Customer Requirement",

  "Approval Request",

  "Timesheet Submitted",

  "Timesheet Approved",

  "Timesheet Rejected",

  "Timesheet Changes Requested",

  "Timesheet Request Changes",

  "Timesheet Submission Reminder",

  "Resource Allocation",

  "Resource Removal",

  "Project Status Change",

  "Project Completed",

  "Project Cancelled",

  "Scope Change",

  "Resource Shuffle",

  "Task Paused",

  "Task Stopped",

  "Task Pause Reminder",

  "Resignation Applied",

  "LWD Reminder",

  "Employee Offboarded",

] as const;