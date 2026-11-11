import React, { useState } from "react";
import { CheckCircle2, Clock, XCircle, MessageSquare, ExternalLink, Archive } from "lucide-react";
import { cn } from "@/lib/utils";
import { Modal } from "@/modules/projects/pages/projects-list-page";
import { Avatar, PriorityPill } from "@/components/pills";
import type { DhNotification } from "@/lib/workspace-store";

export const formatNotifDate = (dateStr: string): string => {
  if (!dateStr) return "—";
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return dateStr;
  const day = String(d.getDate()).padStart(2, "0");
  const month = d.toLocaleString("en-US", { month: "short" });
  const year = d.getFullYear();
  return `${day} ${month} ${year}`;
};

export const formatNotifTime = (dateStr: string): string => {
  if (!dateStr) return "—";
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return "—";
  return d.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true });
};

export const getTypeStyles = (type: string) => {
  const t = (type || "").toLowerCase();
  if (t.includes("wbs")) {
    return "bg-orange-50 text-orange-700 border border-orange-200";
  } else if (
    t.includes("ready") ||
    t.includes("completed") ||
    t.includes("resolved") ||
    t.includes("approved") ||
    t.includes("selected")
  ) {
    return "bg-emerald-50 text-emerald-700 border border-emerald-200";
  } else if (t.includes("rejected") || t.includes("cancelled") || t.includes("removal")) {
    return "bg-red-50 text-red-700 border border-red-200";
  } else if (t.includes("changes") || t.includes("requirement") || t.includes("approval") || t.includes("postponed")) {
    return "bg-amber-50 text-amber-700 border border-amber-200";
  } else if (t.includes("appreciation") || t.includes("feedback")) {
    return "bg-purple-50 text-purple-700 border border-purple-200";
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

export const getNotifStatusStyles = (status: string) => {
  const s = (status || "").toLowerCase().trim();
  if (s === "acknowledged" || s === "approved" || s === "accepted" || s === "resolved" || s === "selected") {
    return "bg-emerald-50 text-emerald-700 border-emerald-200";
  }
  if (s === "hold" || s === "on hold" || s === "postponed") {
    return "bg-amber-50 text-amber-700 border-amber-200";
  }
  if (s === "rejected" || s === "cancelled") {
    return "bg-red-50 text-red-700 border-red-200";
  }
  if (s === "request changes" || s === "requested changes") {
    return "bg-purple-50 text-purple-700 border-purple-200";
  }
  return "bg-orange-50 text-orange-700 border-orange-200";
};

export const renderNotifStatusIcon = (status: string) => {
  const s = (status || "").toLowerCase().trim();
  if (s === "acknowledged" || s === "approved" || s === "accepted" || s === "resolved" || s === "selected") {
    return <CheckCircle2 className="h-3 w-3 text-emerald-600" />;
  }
  if (s === "hold" || s === "on hold" || s === "postponed") {
    return <Clock className="h-3 w-3 text-amber-600" />;
  }
  if (s === "rejected" || s === "cancelled") {
    return <XCircle className="h-3 w-3 text-red-600" />;
  }
  return <Clock className="h-3 w-3 text-orange-600" />;
};

interface NotificationDetailModalProps {
  notification: DhNotification | null;
  onClose: () => void;
  onArchive?: (id: string) => Promise<void> | void;
  onNavigateToActionCentre?: () => void;
}

export function NotificationDetailModal({
  notification,
  onClose,
  onArchive,
  onNavigateToActionCentre,
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

  return (
    <Modal
      title={`Notification Details — ${notification.id}`}
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

          <h3 className="text-base font-bold text-gray-800 leading-snug">
            {notification.title}
          </h3>
        </div>

        {/* Metadata Grid */}
        <div className="grid grid-cols-2 md:grid-cols-3 gap-y-3.5 gap-x-6 border border-border rounded-xl p-4 bg-muted/5">
          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Related Project
            </span>
            <span className="font-semibold text-gray-800">
              {notification.relatedProject}
            </span>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Related Task
            </span>
            <span className="font-semibold text-gray-800">
              {notification.relatedTask || "—"}
            </span>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Raised By
            </span>
            <div className="flex items-center gap-1.5 mt-0.5">
              <Avatar name={notification.raisedBy} size={18} />
              <span className="font-semibold text-gray-700">
                {notification.raisedBy}
              </span>
            </div>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Date
            </span>
            <span className="font-medium text-gray-800">
              {formatNotifDate(notification.createdAt)}
            </span>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Time
            </span>
            <span className="font-medium text-gray-800 font-mono">
              {formatNotifTime(notification.createdAt)}
            </span>
          </div>

          <div>
            <span className="text-[9px] font-bold text-muted-foreground uppercase tracking-wider block mb-0.5">
              Notification ID
            </span>
            <span className="font-bold text-gray-800">{notification.id}</span>
          </div>
        </div>

        {/* Approver Comments / Remarks Section */}
        <div className="border border-border rounded-xl p-4 bg-card space-y-3 shadow-xs">
          <span className="font-bold text-muted-foreground uppercase text-[10px] tracking-wider block border-b border-border/50 pb-1 flex items-center gap-1.5">
            <MessageSquare className="h-3.5 w-3.5 text-primary" />
            <span>Comments</span>
          </span>
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

            if (displayList.length > 0) {
              return (
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
              );
            }
            return (
              <p className="text-xs text-muted-foreground italic py-1">
                No comments
              </p>
            );
          })()}
        </div>

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
                {notification.createdBy}
              </span>
            </div>
            <div>
              <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                Created Date
              </span>
              <span className="font-medium text-gray-755">
                {formatNotifDate(notification.createdAt)}
              </span>
            </div>
            <div>
              <span className="text-muted-foreground block text-[9px] uppercase font-bold tracking-wider">
                Created Time
              </span>
              <span className="font-medium text-gray-755 font-mono">
                {formatNotifTime(notification.createdAt)}
              </span>
            </div>
          </div>

          {/* Chronological Timeline History Log */}
          <div className="relative pl-4 border-l border-border/60 space-y-3 mt-4">
            {(notification.history || []).map((h, idx) => (
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
