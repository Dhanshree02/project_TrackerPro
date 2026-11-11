import React, { useState, useMemo, useEffect, useCallback } from "react";
import { createPortal } from "react-dom";
import { useNavigate } from "@tanstack/react-router";
import { Bell, ArrowRight, ChevronRight, Loader2, CheckCheck, Inbox } from "lucide-react";
import { cn } from "@/lib/utils";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { dhStore, useDhStore, type DhNotification } from "@/lib/workspace-store";
import { apiFetch } from "@/lib/api-client";
import {
  formatNotifDate,
  formatNotifTime,
  getNotifStatusStyles,
} from "./notification-detail-modal";

export function GlobalNotificationBell() {
  const navigate = useNavigate();
  const [isOpen, setIsOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const notifications = useDhStore((s) => s.notifications) || [];

  const unreadCount = useMemo(() => {
    return notifications.filter((n) => n.unread).length;
  }, [notifications]);

  const sortedNotifications = useMemo(() => {
    return [...notifications].sort((a, b) => {
      const timeA = new Date(a.createdAt).getTime() || 0;
      const timeB = new Date(b.createdAt).getTime() || 0;
      return timeB - timeA;
    });
  }, [notifications]);

  const fetchNotifications = useCallback(async () => {
    setIsLoading(true);
    try {
      const data = await apiFetch<DhNotification[]>("/api/v1/action-centre/notifications");
      if (Array.isArray(data)) {
        dhStore.setNotifications(data);
      }
    } catch (err) {
      console.error("Failed to load notifications:", err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchNotifications();
  }, [fetchNotifications]);

  // Handle Escape key to close the notification panel
  useEffect(() => {
    if (!isOpen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setIsOpen(false);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen]);

  const handleOpenChange = (open: boolean) => {
    setIsOpen(open);
    if (open) {
      fetchNotifications();
    }
  };

  const handleViewAll = () => {
    setIsOpen(false);
    navigate({ to: "/action-centre", search: { tab: "notifications" } as any });
  };

  const handleMarkAllAsRead = async () => {
    const unreadList = notifications.filter((n) => n.unread);
    for (const n of unreadList) {
      apiFetch(`/api/v1/action-centre/notifications/${n.id}/read`, { method: "PUT" }).catch(() => {});
      dhStore.markNotificationAsRead(n.id);
    }
  };

  return (
    <>
      {/* Full-screen Dark Blur Background Overlay */}
      {isOpen &&
        typeof document !== "undefined" &&
        createPortal(
          <div
            className="fixed inset-0 z-[60] transition-opacity animate-in fade-in-0 duration-150"
            style={{
              backgroundColor: "rgba(0, 0, 0, 0.25)",
              backdropFilter: "blur(3px)",
              WebkitBackdropFilter: "blur(3px)",
            }}
            aria-hidden="true"
            onClick={() => setIsOpen(false)}
          />,
          document.body,
        )}

      <Popover open={isOpen} onOpenChange={handleOpenChange}>
        <PopoverTrigger asChild>
          <button
            className={cn(
              "relative inline-flex h-9 w-9 items-center justify-center rounded-md border border-border bg-card hover:bg-accent transition-colors shadow-2xs cursor-pointer focus:outline-none focus:ring-2 focus:ring-primary/20",
              isOpen && "z-[70] border-primary text-primary bg-accent",
            )}
            aria-label="Notifications"
          >
            <Bell className="h-4 w-4" />
            {unreadCount > 0 && (
              <span className="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-destructive px-1 text-[10px] font-semibold text-destructive-foreground">
                {unreadCount > 99 ? "99+" : unreadCount}
              </span>
            )}
          </button>
        </PopoverTrigger>

        <PopoverContent
          align="end"
          sideOffset={8}
          className="w-80 sm:w-96 p-0 shadow-2xl border border-border bg-popover text-popover-foreground z-[70] rounded-xl overflow-hidden"
        >
          {/* Header */}
          <div className="flex items-center justify-between border-b border-border px-4 py-3 bg-muted/20">
            <div className="flex items-center gap-2">
              <h4 className="text-sm font-bold text-foreground">Notifications</h4>
              {unreadCount > 0 ? (
                <span className="rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-bold text-primary">
                  {unreadCount} new
                </span>
              ) : notifications.length > 0 ? (
                <span className="rounded-full bg-muted px-2 py-0.5 text-[10px] font-semibold text-muted-foreground">
                  {notifications.length} total
                </span>
              ) : null}
            </div>

            <div className="flex items-center gap-2">
              {unreadCount > 0 && (
                <button
                  onClick={handleMarkAllAsRead}
                  title="Mark all as read"
                  className="text-[11px] text-muted-foreground hover:text-foreground flex items-center gap-1 cursor-pointer transition-colors"
                >
                  <CheckCheck className="h-3 w-3" />
                  <span>Read all</span>
                </button>
              )}
              <button
                onClick={handleViewAll}
                className="text-xs font-semibold text-primary hover:underline cursor-pointer flex items-center gap-0.5"
              >
                View All
                <ChevronRight className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>

          {/* Notifications List - View-Only */}
          <div className="max-h-80 overflow-y-auto divide-y divide-border/50">
            {isLoading && sortedNotifications.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-8 text-center text-muted-foreground">
                <Loader2 className="h-5 w-5 animate-spin text-primary mb-2" />
                <span className="text-xs">Loading notifications…</span>
              </div>
            ) : sortedNotifications.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-10 px-4 text-center text-muted-foreground">
                <div className="rounded-full bg-muted/60 p-3 mb-2">
                  <Inbox className="h-6 w-6 stroke-[1.5] text-muted-foreground/60" />
                </div>
                <p className="text-xs font-semibold text-foreground">No notifications yet</p>
                <p className="text-[11px] text-muted-foreground mt-0.5">
                  You're all caught up with your latest alerts.
                </p>
              </div>
            ) : (
              sortedNotifications.slice(0, 15).map((notif) => (
                <div
                  key={notif.id}
                  className={cn(
                    "w-full text-left p-3 transition-colors flex items-start gap-2.5 select-text",
                    notif.unread ? "bg-primary/[0.04]" : "hover:bg-muted/30",
                  )}
                >
                  {/* Unread indicator dot */}
                  <span
                    className={cn(
                      "h-2 w-2 rounded-full mt-1.5 shrink-0 transition-opacity",
                      notif.unread ? "bg-primary" : "bg-transparent opacity-0",
                    )}
                    title={notif.unread ? "Unread" : "Read"}
                  />

                  <div className="flex-1 min-w-0">
                    <p
                      className={cn(
                        "text-xs leading-snug line-clamp-2 select-text",
                        notif.unread ? "font-bold text-gray-900" : "font-medium text-gray-700",
                      )}
                    >
                      {notif.title}
                    </p>

                    <div className="flex items-center gap-2 mt-1 text-[10px] text-muted-foreground">
                      <span>
                        {formatNotifDate(notif.createdAt)} • {formatNotifTime(notif.createdAt)}
                      </span>

                      {notif.status && (
                        <span
                          className={cn(
                            "inline-flex rounded-full px-1.5 py-0.5 text-[8.5px] font-semibold border",
                            getNotifStatusStyles(notif.status),
                          )}
                        >
                          {notif.status}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Footer */}
          <div className="border-t border-border p-2 bg-muted/15 flex items-center justify-center">
            <button
              onClick={handleViewAll}
              className="w-full text-center text-xs font-semibold text-primary hover:text-primary/80 transition-colors flex items-center justify-center gap-1.5 py-1 cursor-pointer"
            >
              <span>View All Notifications</span>
              <ArrowRight className="h-3.5 w-3.5" />
            </button>
          </div>
        </PopoverContent>
      </Popover>
    </>
  );
}
