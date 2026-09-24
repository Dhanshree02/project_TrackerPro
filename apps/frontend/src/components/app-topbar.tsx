import { useState, useMemo, type ReactNode } from "react";
import { useNavigate } from "@tanstack/react-router";
import { Search, Bell, ChevronDown, Check } from "lucide-react";
import { useRoleContext, roleLabels, backendRoleLabels } from "@/lib/role-context";
import { useAuth } from "@/lib/auth-context";
import { DEMO_PERSONAS, type DemoRoleKey, type DemoPersona } from "@/lib/demo-roles";
import { cn } from "@/lib/utils";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

export function AppTopbar({ title, subtitle }: { title: string; subtitle?: ReactNode }) {
  const { role, user, assignedIssues, pendingTimesheets } = useRoleContext();
  const { user: authUser, demoRole, switchDemoRole, status } = useAuth();
  const navigate = useNavigate();
  const [roleQuery, setRoleQuery] = useState("");

  const roleLabel = authUser?.role
    ? (backendRoleLabels[authUser.role] ?? roleLabels[role as keyof typeof roleLabels] ?? authUser.role)
    : (roleLabels[role as keyof typeof roleLabels] ?? String(role));

  const notifCount =
    assignedIssues.filter((i) => i.status === "open").length + pendingTimesheets.length;

  const onSwitchRole = async (next: DemoRoleKey) => {
    if (next === demoRole) return;
    await switchDemoRole(next);
    await navigate({ to: "/" });
  };

  const filteredPersonas = useMemo(() => {
    const q = roleQuery.trim().toLowerCase();
    if (!q) return DEMO_PERSONAS;
    return DEMO_PERSONAS.filter(
      (p) =>
        p.key.toLowerCase().includes(q) ||
        p.label.toLowerCase().includes(q) ||
        p.name.toLowerCase().includes(q) ||
        p.email.toLowerCase().includes(q) ||
        p.category.toLowerCase().includes(q),
    );
  }, [roleQuery]);

  const grouped = useMemo(() => {
    const map = new Map<string, DemoPersona[]>();
    for (const p of filteredPersonas) {
      const list = map.get(p.category) ?? [];
      list.push(p);
      map.set(p.category, list);
    }
    return map;
  }, [filteredPersonas]);

  const categories = useMemo(() => Array.from(grouped.keys()), [grouped]);

  return (
    <header className="sticky top-0 z-20 flex h-14 items-center justify-between gap-4 border-b border-border bg-background/80 px-4 backdrop-blur md:px-6">
      {/* Left: Page Title & Subtitle */}
      <div className="min-w-0 flex-1 md:flex-initial md:w-60 lg:w-72">
        <h1 className="truncate text-base font-semibold leading-tight text-foreground">{title}</h1>
        {subtitle && <p className="truncate text-xs text-muted-foreground">{subtitle}</p>}
      </div>

      {/* Center: Global Search Bar */}
      <div className="hidden md:flex flex-1 max-w-md justify-center px-2">
        <div className="relative w-full group">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground group-focus-within:text-primary transition-colors" />
          <input
            type="search"
            placeholder="Global search (projects, employees, customers)…"
            className="h-9 w-full rounded-full border border-border/80 bg-muted/60 hover:bg-muted/90 pl-9 pr-3 text-xs outline-none transition-all focus-visible:border-primary focus-visible:bg-card focus-visible:ring-2 focus-visible:ring-primary/20 shadow-2xs text-foreground placeholder:text-muted-foreground"
          />
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
              className="flex items-center gap-2 rounded-lg border border-border/60 bg-muted/30 py-1 pl-1.5 pr-2.5 hover:border-border hover:bg-accent/60 transition-all shadow-2xs"
              aria-label="Switch access role"
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

          <DropdownMenuContent align="end" className="w-80 max-w-[95vw] p-2 shadow-xl">
            <div className="px-2 pt-1 pb-2">
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold tracking-tight text-foreground">
                  Switch RBAC Persona
                </span>
                <span className="text-[10px] font-semibold px-1.5 py-0.5 rounded-full bg-primary/10 text-primary border border-primary/20">
                  27 Active Roles
                </span>
              </div>
              <p className="text-[11px] text-muted-foreground mt-0.5 truncate">
                Active: <span className="font-semibold text-foreground">{authUser?.name ?? user.name}</span> ({authUser?.role ?? roleLabel})
              </p>

              {/* Quick Filter Search Input */}
              <div className="relative mt-2">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
                <input
                  type="text"
                  value={roleQuery}
                  onChange={(e) => setRoleQuery(e.target.value)}
                  onKeyDown={(e) => e.stopPropagation()}
                  placeholder="Filter by role, name, or department..."
                  className="h-8 w-full rounded-md border border-border bg-muted/50 pl-8 pr-2 text-xs outline-none focus:border-primary focus:bg-background transition-colors placeholder:text-muted-foreground"
                />
                {roleQuery && (
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      setRoleQuery("");
                    }}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-[10px] text-muted-foreground hover:text-foreground"
                  >
                    Clear
                  </button>
                )}
              </div>
            </div>

            <DropdownMenuSeparator className="my-1" />

            {/* Scrollable list grouped by category */}
            <div className="max-h-[22rem] overflow-y-auto pr-1 space-y-3">
              {categories.map((cat) => {
                const personas = grouped.get(cat) ?? [];
                return (
                  <div key={cat} className="space-y-1">
                    <div className="px-2 text-[10px] font-bold uppercase tracking-wider text-muted-foreground/80 flex items-center justify-between">
                      <span>{cat}</span>
                      <span className="text-[9px] font-normal text-muted-foreground">
                        ({personas.length})
                      </span>
                    </div>
                    {personas.map((persona) => {
                      const isSelected = demoRole === persona.key;
                      return (
                        <DropdownMenuItem
                          key={persona.key}
                          onSelect={() => void onSwitchRole(persona.key)}
                          className={cn(
                            "flex items-center justify-between px-2 py-1.5 rounded-md cursor-pointer text-xs transition-colors",
                            isSelected
                              ? "bg-primary/10 text-primary font-medium border border-primary/20"
                              : "hover:bg-accent hover:text-accent-foreground",
                          )}
                        >
                          <div className="flex items-center gap-2 min-w-0">
                            <div
                              className={cn(
                                "flex h-6 w-6 shrink-0 items-center justify-center rounded-full text-[10px] font-bold",
                                isSelected
                                  ? "bg-primary text-primary-foreground"
                                  : "bg-muted text-muted-foreground border border-border",
                              )}
                            >
                              {persona.avatar}
                            </div>
                            <div className="flex flex-col min-w-0">
                              <span className="truncate font-medium">{persona.label}</span>
                              <span className="truncate text-[10px] text-muted-foreground">
                                {persona.name}
                              </span>
                            </div>
                          </div>
                          {isSelected && <Check className="h-4 w-4 shrink-0 text-primary ml-2" />}
                        </DropdownMenuItem>
                      );
                    })}
                  </div>
                );
              })}

              {categories.length === 0 && (
                <div className="p-4 text-center text-xs text-muted-foreground">
                  No role or persona matching &quot;{roleQuery}&quot;
                </div>
              )}
            </div>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
