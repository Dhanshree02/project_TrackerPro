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
    <header className="sticky top-0 z-20 flex h-14 items-center justify-between gap-4 border-b border-border bg-background/80 px-4 backdrop-blur md:px-6">
      {/* Left: Page Title & Subtitle */}
      <div className="min-w-0 flex-1 md:flex-initial md:w-60 lg:w-72">
        <h1 className="truncate text-base font-semibold leading-tight text-foreground">{title}</h1>
        {subtitle && <p className="truncate text-xs text-muted-foreground">{subtitle}</p>}
      </div>

      {/* Center: Global Search Bar (Spotlight / Command Palette Style) */}
      <div className="hidden md:flex flex-1 max-w-md justify-center px-2">
        <div className="relative w-full group">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary transition-colors" />
          <input
            type="search"
            placeholder="Global search (projects, employees, customers)…"
            className="h-9 w-full rounded-full border border-border/80 bg-muted/60 hover:bg-muted/90 pl-9 pr-14 text-xs outline-none transition-all focus-visible:border-primary focus-visible:bg-card focus-visible:ring-2 focus-visible:ring-primary/20 shadow-2xs text-foreground placeholder:text-muted-foreground"
          />
          <kbd className="pointer-events-none absolute right-2.5 top-1/2 -translate-y-1/2 hidden sm:inline-flex h-5 select-none items-center gap-0.5 rounded border border-border/80 bg-card px-1.5 font-mono text-[10px] font-medium text-muted-foreground shadow-2xs">
            ⌘K
          </kbd>
        </div>
      </div>

      {/* Right: Notifications & Profile */}
      <div className="flex items-center gap-3 shrink-0">
        <button
          className="relative inline-flex h-9 w-9 items-center justify-center rounded-md border border-border bg-card hover:bg-accent transition-colors shadow-2xs"
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
              className="flex items-center gap-2 rounded-md border border-transparent py-1 pl-1 pr-1.5 hover:border-border hover:bg-accent/60 transition-colors"
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
      </div>
    </header>
  );
}
