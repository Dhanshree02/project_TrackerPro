import { type ReactNode } from "react";
import { useNavigate } from "@tanstack/react-router";
import { ChevronDown, LogOut, UserRound } from "lucide-react";
import { GlobalSearch } from "@/components/global-search";
import { ThemeToggle } from "@/components/theme-toggle";
import { FinancialYearFilter } from "@/lib/financial-year";
import { GlobalNotificationBell } from "./global-notification-bell";
import { roleLabels, backendRoleLabels, useRoleContext } from "@/lib/role-context";
import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

/** Set by the Docker stack. Empty when the app is not running in one of the three environments. */
function AppEnvironmentMark() {
  const stage = (import.meta.env.VITE_APP_ENV as string | undefined)?.trim().toLowerCase();
  if (stage !== "development" && stage !== "uat" && stage !== "production") return null;
  const label = stage === "uat" ? "UAT" : stage === "production" ? "Production" : "Development";
  const tone =
    stage === "production"
      ? "bg-success/15 text-success"
      : stage === "uat"
        ? "bg-warning/15 text-warning"
        : "bg-info/15 text-info";
  return (
    <span className={cn("inline-flex h-7 items-center rounded-full px-2.5 text-[10px] font-semibold tracking-wide", tone)}>
      {label}
    </span>
  );
}

export function AppTopbar({ title, subtitle }: { title: string; subtitle?: ReactNode }) {
  const { role, user } = useRoleContext();
  const { user: authUser, logout, status } = useAuth();
  const navigate = useNavigate();

  const roleLabel = authUser?.role
    ? (backendRoleLabels[authUser.role] ?? roleLabels[role as keyof typeof roleLabels] ?? authUser.role)
    : (roleLabels[role as keyof typeof roleLabels] ?? String(role));

  return (
    <header className="sticky top-0 z-20 flex h-14 items-center justify-between gap-4 border-b border-border bg-background/80 px-4 backdrop-blur md:px-6">
      <div className="min-w-0 flex-1 md:flex-initial md:w-60 lg:w-72">
        <h1 className="truncate text-base font-semibold leading-tight text-foreground">{title}</h1>
        {subtitle && <p className="truncate text-xs text-muted-foreground">{subtitle}</p>}
      </div>

      <div className="flex shrink-0 items-center justify-end gap-2 md:min-w-0 md:flex-1 md:justify-center md:px-2">
        <GlobalSearch />
        <FinancialYearFilter />
      </div>

      <div className="flex items-center gap-3 shrink-0">
        <AppEnvironmentMark />
        <ThemeToggle />
        <GlobalNotificationBell />

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button
              className="flex items-center gap-2 rounded-lg border border-border/60 bg-muted/30 py-1 pl-1.5 pr-2.5 hover:border-border hover:bg-accent/60 transition-all shadow-2xs"
              aria-label="Account menu"
              disabled={status === "loading"}
            >
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/15 text-xs font-bold text-primary ring-1 ring-primary/25">
                {user.avatar}
              </div>
              <div className="hidden md:flex flex-col leading-tight text-left">
                <span className="text-xs font-semibold text-foreground truncate max-w-[130px]">
                  {user.name}
                </span>
                <span className="text-[10px] font-medium text-primary truncate max-w-[130px]">
                  {roleLabel}
                </span>
              </div>
              <ChevronDown className="hidden h-3.5 w-3.5 text-muted-foreground md:block" />
            </button>
          </DropdownMenuTrigger>

          <DropdownMenuContent align="end" className="w-56 p-1.5">
            <div className="px-2 py-1.5">
              <p className="truncate text-sm font-semibold text-foreground">{user.name}</p>
              <p className="truncate text-xs text-muted-foreground">{authUser?.email}</p>
            </div>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onSelect={() => void navigate({ to: "/profile" })}
              className="gap-2"
            >
              <UserRound className="h-4 w-4" />
              Profile
            </DropdownMenuItem>
            <DropdownMenuItem
              onSelect={() => void logout()}
              className="gap-2"
            >
              <LogOut className="h-4 w-4" />
              Sign out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
