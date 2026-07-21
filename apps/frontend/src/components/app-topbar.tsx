import { type ReactNode } from "react";
import { Search, Bell } from "lucide-react";
import { useRoleContext, roleLabels } from "@/lib/role-context";

export function AppTopbar({ title, subtitle }: { title: string; subtitle?: ReactNode }) {
  const { role, user, assignedIssues, pendingTimesheets } = useRoleContext();
  const notifCount =
    assignedIssues.filter((i) => i.status === "open").length + pendingTimesheets.length;

  return (
    <header className="sticky top-0 z-20 flex h-14 items-center gap-3 border-b border-border bg-background/80 px-4 backdrop-blur md:px-6">
      <div className="min-w-0 flex-1">
        <h1 className="truncate text-base font-semibold leading-tight">{title}</h1>
        {subtitle && (
          <p className="truncate text-xs text-muted-foreground">{subtitle}</p>
        )}
      </div>

      <div className="hidden lg:flex relative w-64">
        <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <input
          type="search"
          placeholder="Search projects, issues…"
          className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
        />
      </div>

      <button
        className="relative inline-flex h-9 w-9 items-center justify-center rounded-md border border-border bg-card hover:bg-accent"
        aria-label="Notifications"
      >
        <Bell className="h-4 w-4" />
        {notifCount > 0 && (
          <span className="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-destructive px-1 text-[10px] font-semibold text-destructive-foreground">
            {notifCount}
          </span>
        )}
      </button>

      <div className="flex items-center gap-2 pl-2">
        <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/15 text-xs font-semibold text-primary">
          {user.avatar}
        </div>
        <div className="hidden md:flex flex-col leading-tight">
          <span className="text-sm font-medium">{user.name}</span>
          <span className="text-[11px] text-muted-foreground">{roleLabels[role]}</span>
        </div>
      </div>
    </header>
  );
}
