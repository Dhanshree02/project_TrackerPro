import React, { useState } from "react";
import { CheckCircle2, Clock, XCircle, MessageSquare, ExternalLink, Archive, AlertCircle, X } from "lucide-react";
import { cn, formatDateDMY } from "@/lib/utils";
import { Modal } from "@/modules/projects/pages/projects-list-page";
import { Avatar, PriorityPill } from "@/components/pills";
import type { DhNotification } from "@/lib/workspace-store";
import { apiFetch } from "@/lib/api-client";
import { toast } from "sonner";

export function formatNotificationId(id?: string | null): string {
  if (!id) return "";
  const match = id.match(/^NOT-([0-9a-fA-F-]+)$/i);
  if (match) {
    const raw = match[1].replace(/-/g, "");
    return `NOT-${raw.slice(0, 8).toUpperCase()}`;
  }
  if (id.startsWith("NOT-")) {
    const raw = id.slice(4).replace(/-/g, "");
    return `NOT-${raw.slice(0, 8).toUpperCase()}`;
  }
  const clean = id.replace(/-/g, "");
  return `NOT-${clean.slice(0, 8).toUpperCase()}`;
}

export const formatNotifDate = (dateStr?: string | null): string => {
  if (!dateStr) return "—";
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
    const [y, m, d] = dateStr.split("-");
    return `${d}-${m}-${y}`;
  }
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return dateStr;
  return formatDateDMY(d);
};

export const formatNotifTime = (dateStr?: string | null): string => {
  if (!dateStr) return "—";
  if (/am|pm/i.test(dateStr)) return dateStr.trim();
  if (/^\d{1,2}:\d{2}(:\d{2})?/.test(dateStr)) {
    const today = new Date().toISOString().slice(0, 10);
    const d = new Date(`${today}T${dateStr}${dateStr.endsWith("Z") ? "" : "Z"}`);
    if (!isNaN(d.getTime())) {
      return d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true });
    }
    return dateStr;
  }
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return "—";
  return d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true });
};

export function formatHistoryDateTime(
  h?: { at?: string; date?: string; time?: string } | any,
  fallbackCreatedAt?: string
): { dateStr: string; timeStr: string } {
  if (!h) {
    if (fallbackCreatedAt) {
      const d = new Date(fallbackCreatedAt);
      if (!isNaN(d.getTime())) {
        return {
          dateStr: formatDateDMY(d),
          timeStr: d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true })
        };
      }
    }
    return { dateStr: "—", timeStr: "" };
  }

  // 1. If full ISO timestamp `at` is present
  if (h.at) {
    const d = new Date(h.at);
    if (!isNaN(d.getTime())) {
      return {
        dateStr: formatDateDMY(d),
        timeStr: d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true })
      };
    }
  }

  // 2. If both date and time are provided
  if (h.date && h.time) {
    if (/am|pm/i.test(h.time)) {
      return {
        dateStr: formatNotifDate(h.date),
        timeStr: h.time.trim()
      };
    }

    if (/^\d{4}-\d{2}-\d{2}$/.test(h.date) && /^\d{1,2}:\d{2}(:\d{2})?/.test(h.time)) {
      const utcIso = `${h.date}T${h.time}${h.time.endsWith("Z") ? "" : "Z"}`;
      const d = new Date(utcIso);
      if (!isNaN(d.getTime())) {
        return {
          dateStr: formatDateDMY(d),
          timeStr: d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true })
        };
      }
    }
  }

  // 3. If date is provided (could be ISO string)
  if (h.date) {
    const d = new Date(h.date);
    if (!isNaN(d.getTime()) && (h.date.includes("T") || h.date.includes("Z"))) {
      return {
        dateStr: formatDateDMY(d),
        timeStr: d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true })
      };
    }
    return {
      dateStr: formatNotifDate(h.date),
      timeStr: h.time ? formatNotifTime(h.time) : ""
    };
  }

  // 4. Fallback to notification's createdAt
  if (fallbackCreatedAt) {
    const d = new Date(fallbackCreatedAt);
    if (!isNaN(d.getTime())) {
      return {
        dateStr: formatDateDMY(d),
        timeStr: d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true })
      };
    }
  }

  return { dateStr: "—", timeStr: "" };
}

export const getTypeStyles = (type: string) => {
  const t = (type || "").toLowerCase();
  if (t.includes("timesheet")) {
    return "bg-indigo-50 text-indigo-700 border border-indigo-200";
  } else if (t.includes("wbs")) {
    return "bg-orange-50 text-orange-700 border border-orange-200";
  } else if (t.includes("deleted") || t.includes("stopped")) {
    return "bg-red-50 text-red-700 border border-red-200";
  } else if (
    t.includes("ready") ||
    t.includes("started") ||
    t.includes("completed") ||
    t.includes("resolved") ||
    t.includes("approved") ||
    t.includes("selected")
  ) {
    return "bg-emerald-50 text-emerald-700 border border-emerald-200";
  } else if (t.includes("rejected") || t.includes("cancelled") || t.includes("removal")) {
    return "bg-red-50 text-red-700 border border-red-200";
  } else if (t.includes("modify") || t.includes("paused") || t.includes("changes") || t.includes("requirement") || t.includes("approval") || t.includes("postponed") || t.includes("prerequisite") || t.includes("reminder")) {
    return "bg-amber-50 text-amber-700 border border-amber-200";
  } else if (t.includes("appreciation") || t.includes("feedback")) {
    return "bg-purple-50 text-purple-700 border border-purple-200";
  } else if (
    t.includes("interview") ||
    t.includes("shuffle") ||
    t.includes("allocation") ||
    t.includes("assignment") ||
    t.includes("assigned") ||
    t.includes("added") ||
    t.includes("resumed")
  ) {
    return "bg-sky-50 text-sky-700 border border-sky-200";
  }
  return "bg-muted text-foreground border border-border";
};

export const getNotifStatusStyles = (status: string) => {
  const s = (status || "").toLowerCase().trim();
  if (s === "acknowledged" || s === "approved" || s === "accepted" || s === "resolved" || s === "selected" || s === "done" || s === "started") {
    return "bg-emerald-50 text-emerald-700 border-emerald-200";
  }
  if (s === "assigned") {
    return "bg-indigo-50 text-indigo-700 border-indigo-200";
  }
  if (s === "created" || s === "added") {
    return "bg-sky-50 text-sky-700 border-sky-200";
  }
  if (s === "edited" || s === "modify" || s === "modified") {
    return "bg-amber-50 text-amber-700 border-amber-200";
  }
  if (s === "upload" || s === "uploaded") {
    return "bg-teal-50 text-teal-700 border-teal-200";
  }
  if (s === "hold" || s === "on hold" || s === "postponed") {
    return "bg-amber-50 text-amber-700 border-amber-200";
  }
  if (s === "rejected" || s === "cancelled" || s === "deleted") {
    return "bg-red-50 text-red-700 border-red-200";
  }
  if (s === "request change" || s === "request changes" || s === "requested changes" || s === "change_requested") {
    return "bg-purple-50 text-purple-700 border-purple-200";
  }
  return "bg-orange-50 text-orange-700 border-orange-200";
};

export const renderNotifStatusIcon = (status: string) => {
  const s = (status || "").toLowerCase().trim();
  if (s === "acknowledged" || s === "approved" || s === "accepted" || s === "resolved" || s === "selected" || s === "done" || s === "started") {
    return <CheckCircle2 className="h-3 w-3 text-emerald-600" />;
  }
  if (s === "assigned") {
    return <CheckCircle2 className="h-3 w-3 text-indigo-600" />;
  }
  if (s === "created" || s === "added") {
    return <CheckCircle2 className="h-3 w-3 text-sky-600" />;
  }
  if (s === "hold" || s === "on hold" || s === "postponed" || s === "modify" || s === "modified") {
    return <Clock className="h-3 w-3 text-amber-600" />;
  }
  if (s === "rejected" || s === "cancelled" || s === "deleted") {
    return <XCircle className="h-3 w-3 text-red-600" />;
  }
  if (s === "request change" || s === "request changes" || s === "requested changes" || s === "change_requested") {
    return <AlertCircle className="h-3 w-3 text-purple-600" />;
  }
  return <Clock className="h-3 w-3 text-orange-600" />;
};

interface NotificationDetailModalProps {
  notification: DhNotification | null;
  onClose: () => void;
  onArchive?: (id: string) => Promise<void> | void;
  onNavigateToActionCentre?: () => void;
  onActionComplete?: () => Promise<void> | void;
}

export function NotificationDetailModal({
  notification,
  onClose,
  onArchive,
  onNavigateToActionCentre,
  onActionComplete,
}: NotificationDetailModalProps) {
  const [isArchiving, setIsArchiving] = useState(false);

  if (!notification) return null;

  const isAlreadyArchived = (notification.status || "").toLowerCase() === "acknowledged";

  const handleArchiveClick = async () => {
    if (!notification || !onArchive || isArchiving) return;
    try {
      setIsArchiving(true);
      await onArchive(notification.id);
    } catch (e) {
      console.error("Failed to archive notification:", e);
    } finally {
      setIsArchiving(false);
    }
  };

  const displayCode = formatNotificationId(notification.notificationCode || notification.id);

  return (
    <Modal
      title={displayCode ? `Notification Details — ${displayCode}` : "Notification Details"}
      onClose={onClose}
      wide
    >
      <div className="space-y-4 text-xs">
        {/* Top pill badges and Large Title */}
        <div className="space-y-2">
          <div className="flex flex-wrap gap-2">
            <span
              className={cn(
                "inline-flex rounded-full px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-wider",
                getTypeStyles(notification.type),
              )}
            >
              {notification.type}
            </span>

            {notification.priority === "-" ? (
              <span className="inline-flex rounded-full px-2.5 py-0.5 text-[10px] font-bold text-muted-foreground bg-muted border border-border">
                -
              </span>
            ) : (
              <PriorityPill priority={notification.priority.toLowerCase() as any} />
            )}

            <span
              className={cn(
                "inline-flex rounded-full border px-2.5 py-0.5 text-[9px] font-bold capitalize items-center gap-1",
                getNotifStatusStyles(notification.status),
              )}
            >
              {renderNotifStatusIcon(notification.status)}
              {notification.status}
            </span>
          </div>

          <h3 className="text-base font-bold text-foreground leading-snug">
            {notification.title}
          </h3>
          {notification.history?.[0]?.action && !notification.history[0].action.includes("Remarks:") && (
            <p className="text-xs text-muted-foreground mt-1 leading-relaxed">
              {notification.history[0].action}
            </p>
          )}
        </div>

        {/* Metadata Grid */}
        <div className="grid grid-cols-2 md:grid-cols-3 gap-y-3.5 gap-x-6 border border-border rounded-xl p-4 bg-muted/5">
          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Related Project
            </span>
            <span className="font-semibold text-foreground">
              {notification.relatedProject}
            </span>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Related Task
            </span>
            <span className="font-semibold text-foreground">
              {notification.relatedTask || "—"}
            </span>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Raised By
            </span>
            <div className="flex items-center gap-1.5 mt-0.5">
              <Avatar name={notification.raisedBy} size={18} />
              <span className="font-semibold text-foreground">
                {notification.raisedBy}
              </span>
            </div>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Date
            </span>
            <span className="font-medium text-foreground">
              {formatNotifDate(notification.createdAt)}
            </span>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Time
            </span>
            <span className="font-medium text-foreground font-mono">
              {formatNotifTime(notification.createdAt)}
            </span>
          </div>
        </div>

        {/* Issue / WBS Escalation Details Section (Title/Subject, Description, Issue Type/Escalation Type) */}
        {(notification.issueTitle || notification.issueDescription || notification.issueType) && (
          <div className="border border-border rounded-xl p-4 bg-card space-y-3 shadow-xs">
            <span className="font-bold text-muted-foreground uppercase text-[10px] tracking-wider block border-b border-border/50 pb-1 flex items-center gap-1.5">
              <AlertCircle className="h-3.5 w-3.5 text-primary" />
              <span>
                {notification.type.toLowerCase().includes("wbs")
                  ? "WBS Escalation Details"
                  : "Issue Details"}
              </span>
            </span>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-y-3 gap-x-6">
              {notification.issueTitle && (
                <div className="md:col-span-2">
                  <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                    {notification.type.toLowerCase().includes("wbs")
                      ? "Subject"
                      : "Issue Title"}
                  </span>
                  <span className="font-medium text-foreground text-xs">
                    {notification.issueTitle}
                  </span>
                </div>
              )}

              {notification.issueType && (
                <div>
                  <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                    {notification.type.toLowerCase().includes("wbs")
                      ? "Escalation Type"
                      : "Issue Type"}
                  </span>
                  <span className="font-medium text-foreground">
                    {notification.issueType}
                  </span>
                </div>
              )}

              {notification.issueDescription && (
                <div className="md:col-span-2">
                  <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
                    Description
                  </span>
                  <p className="text-foreground leading-relaxed whitespace-pre-wrap bg-muted/20 p-2.5 rounded-md border border-border/60">
                    {notification.issueDescription}
                  </p>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Approver Comments / Remarks Section - rendered only when comments/remarks exist */}
        {(() => {
          const directComments = notification.comments || [];
          const histRemarks: any[] = [];
          if (directComments.length === 0 && notification.history) {
            notification.history.forEach((h: any, idx: number) => {
              if (h.action && h.action.includes("Remarks:")) {
                const remarkText = h.action.split("Remarks:")[1]?.replace(/"/g, "")?.trim();
                if (remarkText) {
                  histRemarks.push({
                    id: `hist-rem-${idx}`,
                    authorName: h.by || notification.raisedBy,
                    text: remarkText,
                    at: h.date && h.time ? `${h.date}T${h.time}` : undefined,
                  });
                }
              }
            });
          }
          const displayList = directComments.length > 0 ? directComments : histRemarks;

          if (displayList.length === 0) return null;

          return (
            <div className="border border-border rounded-xl p-4 bg-card space-y-3 shadow-xs">
              <span className="font-bold text-muted-foreground uppercase text-[10px] tracking-wider block border-b border-border/50 pb-1 flex items-center gap-1.5">
                <MessageSquare className="h-3.5 w-3.5 text-primary" />
                <span>Comments</span>
              </span>
              <div className="space-y-2 max-h-48 overflow-y-auto">
                {displayList.map((c: any, idx: number) => (
                  <div key={c.id || idx} className="text-xs rounded-md border border-border/60 bg-muted/20 p-2.5">
                    <div className="flex justify-between items-center text-muted-foreground text-[10px] mb-1">
                      <span className="font-semibold text-foreground">
                        {c.authorName || notification.raisedBy || "Approver"}
                      </span>
                      <span>
                        {c.at ? `${formatNotifDate(c.at)} ${formatNotifTime(c.at)}` : ""}
                      </span>
                    </div>
                    <p className="text-foreground leading-normal whitespace-pre-wrap">{c.text}</p>
                  </div>
                ))}
              </div>
            </div>
          );
        })()}

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
              <span className="font-semibold text-foreground">
                {notification.createdBy}
              </span>
            </div>
            <div>
              <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                Created Date
              </span>
              <span className="font-medium text-foreground">
                {formatNotifDate(notification.createdAt)}
              </span>
            </div>
            <div>
              <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                Created Time
              </span>
              <span className="font-medium text-foreground font-mono">
                {formatNotifTime(notification.createdAt)}
              </span>
            </div>
          </div>

          {/* Chronological Timeline History Log */}
          <div className="relative pl-4 border-l border-border/60 space-y-3 mt-4">
            {(() => {
              const historyItems = (notification.history && notification.history.length > 0)
                ? notification.history
                : [
                    {
                      action: "Notification created",
                      at: notification.createdAt,
                      date: notification.createdDate,
                      by: notification.createdBy || notification.raisedBy || "System"
                    }
                  ];

              return historyItems.map((h, idx) => {
                const { dateStr, timeStr } = formatHistoryDateTime(h, notification.createdAt);
                const actionText = h.action || (h as any).details || ((h as any).status ? `Status: ${(h as any).status}` : "Notification updated");
                const performer = h.by || (h as any).updatedBy || notification.createdBy || "System";

                return (
                  <div key={idx} className="relative flex items-start gap-2">
                    <span className="absolute -left-[20.5px] top-1.5 h-2 w-2 rounded-full border border-primary bg-card" />
                    <div className="flex flex-col gap-0.5 text-xs leading-relaxed">
                      <div className="flex items-center gap-2">
                        <span className="text-muted-foreground font-mono text-[10px] whitespace-nowrap">
                          {dateStr} {timeStr}
                        </span>
                        <span className="font-semibold text-foreground">
                          {actionText.includes("Remarks:") ? (
                            <>
                              Notification acknowledged by <strong>{performer}</strong>
                              <span className="block text-muted-foreground font-normal mt-0.5 italic">
                                Remarks: {actionText.split("Remarks:")[1]?.replace(/"/g, "")}
                              </span>
                            </>
                          ) : actionText.toLowerCase().includes(`by ${performer.toLowerCase()}`) ? (
                            actionText
                          ) : (
                            `${actionText} by ${performer}`
                          )}
                        </span>
                      </div>
                    </div>
                  </div>
                );
              });
            })()}
          </div>
        </div>

        {/* Modal Footer Controls */}
        <div className="flex items-center justify-between border-t border-border pt-3">
          {onNavigateToActionCentre ? (
            <button
              onClick={() => {
                onClose();
                onNavigateToActionCentre();
              }}
              className="inline-flex items-center gap-1.5 text-xs font-semibold text-primary hover:underline cursor-pointer"
            >
              <ExternalLink className="h-3.5 w-3.5" />
              View in Action Centre
            </button>
          ) : (
            <div />
          )}

          <div className="flex items-center gap-2">
            {!isAlreadyArchived && onArchive && (
              <button
                type="button"
                onClick={handleArchiveClick}
                disabled={isArchiving}
                className="inline-flex items-center gap-1.5 rounded-md border border-amber-300 bg-amber-50 px-3.5 py-1.5 text-xs font-semibold text-amber-800 hover:bg-amber-100 transition-colors cursor-pointer disabled:opacity-50"
              >
                <Archive className="h-3.5 w-3.5 text-amber-700" />
                <span>{isArchiving ? "Archiving..." : "Move to Archive"}</span>
              </button>
            )}

            <button
              onClick={onClose}
              className="rounded-md border border-input bg-card px-4 py-1.5 font-medium hover:bg-accent text-xs cursor-pointer"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </Modal>
  );
}
