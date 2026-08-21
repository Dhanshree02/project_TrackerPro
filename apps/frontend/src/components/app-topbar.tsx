import { type ReactNode } from "react";
import { useNavigate } from "@tanstack/react-router";
import { Search, Bell, ChevronDown, Check } from "lucide-react";
import { useRoleContext, roleLabels, backendRoleLabels } from "@/lib/role-context";
import { useAuth } from "@/lib/auth-context";
import { DEMO_PERSONAS, type DemoRoleKey } from "@/lib/demo-roles";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function AppTopbar({ title, subtitle }: { title: string; subtitle?: ReactNode }) {
  const { role, user, assignedIssues, pendingTimesheets } = useRoleContext();
  const { user: authUser, demoRole, switchDemoRole, status } = useAuth();
  const navigate = useNavigate();
  const roleLabel = authUser?.role
    ? (backendRoleLabels[authUser.role] ?? roleLabels[role])
    : roleLabels[role];
  const notifCount =
    assignedIssues.filter((i) => i.status === "open").length + pendingTimesheets.length;

  const onSwitchRole = async (next: DemoRoleKey) => {
    if (next === demoRole) return;
    await switchDemoRole(next);
    await navigate({ to: "/" });
  };

  return (
    <header className="sticky top-0 z-20 flex h-14 items-center gap-3 border-b border-border bg-background/80 px-4 backdrop-blur md:px-6">
      <div className="min-w-0 flex-1">
        <h1 className="truncate text-base font-semibold leading-tight">{title}</h1>
        {subtitle && <p className="truncate text-xs text-muted-foreground">{subtitle}</p>}
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

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <button
            className="flex items-center gap-2 rounded-md border border-transparent py-1 pl-1 pr-1.5 hover:border-border hover:bg-accent/60"
            aria-label="Switch access role"
            disabled={status === "loading"}
          >
            <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/15 text-xs font-semibold text-primary">
              {user.avatar}
            </div>
            <div className="hidden md:flex flex-col leading-tight text-left">
              <span className="text-sm font-medium">{user.name}</span>
              <span className="text-[11px] text-muted-foreground">{roleLabel}</span>
            </div>
            <ChevronDown className="hidden h-3.5 w-3.5 text-muted-foreground md:block" />
          </button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-56">
          <DropdownMenuLabel className="text-xs text-muted-foreground font-medium">
            Switch access role
          </DropdownMenuLabel>
          <DropdownMenuSeparator />
          {DEMO_PERSONAS.map((persona) => (
            <DropdownMenuItem
              key={persona.key}
              onSelect={() => void onSwitchRole(persona.key)}
              className="flex items-center justify-between"
            >
              <span>{persona.label}</span>
              {demoRole === persona.key && <Check className="h-3.5 w-3.5 text-primary" />}
            </DropdownMenuItem>
          ))}
        </DropdownMenuContent>
      </DropdownMenu>
    </header>
  );
}
