import { useState, useMemo, type ReactNode } from "react";
import { useNavigate } from "@tanstack/react-router";
import { Search, Bell, ChevronDown, Check } from "lucide-react";
import { useRoleContext, roleLabels, backendRoleLabels } from "@/lib/role-context";
import { useAuth } from "@/lib/auth-context";
import { DEFAULT_DEMO_ROLE, DEMO_PERSONAS, type DemoRoleKey, type DemoPersona } from "@/lib/demo-roles";
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
  const [selectedDept, setSelectedDept] = useState("All");

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

  const activePersona = useMemo(() => {
    return (
      DEMO_PERSONAS.find(
        (p) =>
          (authUser?.employeeId && p.code.toLowerCase() === authUser.employeeId.toLowerCase()) ||
          (authUser?.email && p.email.toLowerCase() === authUser.email.toLowerCase()) ||
          p.key === demoRole ||
          p.code === demoRole,
      ) ??
      DEMO_PERSONAS.find((p) => p.roleKey === authUser?.role) ??
      DEMO_PERSONAS.find((p) => p.key === DEFAULT_DEMO_ROLE) ??
      DEMO_PERSONAS[0]
    );
  }, [demoRole, authUser]);

  const departments = useMemo(() => {
    const set = new Set<string>();
    for (const p of DEMO_PERSONAS) {
      if (p.category) set.add(p.category);
    }
    return ["All", ...Array.from(set)];
  }, []);

  const filteredPersonas = useMemo(() => {
    let list = DEMO_PERSONAS;
    if (selectedDept !== "All") {
      list = list.filter((p) => p.category === selectedDept);
    }
    const q = roleQuery.trim().toLowerCase();
    if (!q) return list;
    return list.filter(
      (p) =>
        p.key.toLowerCase().includes(q) ||
        p.code.toLowerCase().includes(q) ||
        p.label.toLowerCase().includes(q) ||
        p.name.toLowerCase().includes(q) ||
        p.email.toLowerCase().includes(q) ||
        p.category.toLowerCase().includes(q) ||
        p.department.toLowerCase().includes(q) ||
        p.designation.toLowerCase().includes(q) ||
        p.roleKey.toLowerCase().includes(q),
    );
  }, [roleQuery, selectedDept]);

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

          <DropdownMenuContent align="end" className="w-96 max-w-[95vw] p-2.5 shadow-2xl border border-border/80">
            <div className="px-1 pt-0.5 pb-2">
              <div className="flex items-center justify-between">
                <div>
                  <span className="text-xs font-bold tracking-tight text-foreground">
                    Switch User / Employee
                  </span>
                  <p className="text-[10px] text-muted-foreground">Select any employee to view as them</p>
                </div>
                <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-primary/10 text-primary border border-primary/20">
                  {DEMO_PERSONAS.length} Employees
                </span>
              </div>

              {/* Active User Card */}
              <div className="mt-2.5 flex items-center gap-2.5 rounded-lg border border-primary/25 bg-primary/5 p-2">
                <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-bold text-primary-foreground shadow-2xs">
                  {activePersona.avatar}
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-1.5">
                    <span className="truncate text-xs font-bold text-foreground">
                      {activePersona.name}
                    </span>
                    <span className="rounded bg-primary/15 px-1 py-0.2 text-[9px] font-mono font-semibold text-primary">
                      {activePersona.code}
                    </span>
                  </div>
                  <p className="truncate text-[10px] text-muted-foreground">
                    {activePersona.designation || activePersona.label} • {activePersona.roleKey}
                  </p>
                </div>
                <span className="rounded-full bg-primary/15 text-[9px] font-bold text-primary px-2 py-0.5 uppercase tracking-wide">
                  Active
                </span>
              </div>

              {/* Search Filter Input */}
              <div className="relative mt-2.5">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
                <input
                  type="text"
                  value={roleQuery}
                  onChange={(e) => setRoleQuery(e.target.value)}
                  onKeyDown={(e) => e.stopPropagation()}
                  placeholder="Search by name, ID (e.g. TK-0046), role..."
                  className="h-8 w-full rounded-md border border-border bg-muted/50 pl-8 pr-7 text-xs outline-none focus:border-primary focus:bg-background transition-colors placeholder:text-muted-foreground"
                />
                {roleQuery && (
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      setRoleQuery("");
                    }}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-[10px] text-muted-foreground hover:text-foreground font-semibold"
                  >
                    ×
                  </button>
                )}
              </div>

              {/* Department quick filter pills */}
              <div className="flex items-center gap-1 overflow-x-auto mt-2 pb-1 scrollbar-none">
                {departments.map((dept) => {
                  const count = dept === "All" ? DEMO_PERSONAS.length : DEMO_PERSONAS.filter((p) => p.category === dept).length;
                  const isDeptActive = selectedDept === dept;
                  const label = dept === "All" ? "All" : dept.replace("Functional - ", "").replace("Services - ", "").replace(" (Research & Development)", "");
                  return (
                    <button
                      key={dept}
                      onClick={(e) => {
                        e.stopPropagation();
                        setSelectedDept(dept);
                      }}
                      className={cn(
                        "shrink-0 rounded-full px-2 py-0.5 text-[9px] font-medium transition-all",
                        isDeptActive
                          ? "bg-primary text-primary-foreground font-bold shadow-2xs"
                          : "bg-muted text-muted-foreground hover:bg-accent hover:text-foreground border border-border/40",
                      )}
                    >
                      {label} ({count})
                    </button>
                  );
                })}
              </div>
            </div>

            <DropdownMenuSeparator className="my-1" />

            {/* Scrollable list grouped by category */}
            <div className="max-h-[24rem] overflow-y-auto pr-1 space-y-2.5">
              {categories.map((cat) => {
                const personas = grouped.get(cat) ?? [];
                return (
                  <div key={cat} className="space-y-1">
                    <div className="px-2 pt-1 text-[10px] font-bold uppercase tracking-wider text-muted-foreground/80 flex items-center justify-between">
                      <span className="truncate">{cat}</span>
                      <span className="text-[9px] font-normal text-muted-foreground">
                        ({personas.length})
                      </span>
                    </div>
                    {personas.map((persona) => {
                      const isSelected =
                        demoRole === persona.key ||
                        demoRole === persona.code ||
                        (authUser?.email && authUser.email.toLowerCase() === persona.email.toLowerCase()) ||
                        (authUser?.employeeId && authUser.employeeId.toLowerCase() === persona.code.toLowerCase()) ||
                        (user.email && user.email.toLowerCase() === persona.email.toLowerCase()) ||
                        activePersona.code === persona.code;
                      return (
                        <DropdownMenuItem
                          key={persona.key}
                          onSelect={() => void onSwitchRole(persona.key)}
                          className={cn(
                            "flex items-center justify-between px-2 py-1.5 rounded-lg cursor-pointer text-xs transition-colors",
                            isSelected
                              ? "bg-primary/10 text-primary font-medium border border-primary/20"
                              : "hover:bg-accent hover:text-accent-foreground",
                          )}
                        >
                          <div className="flex items-center gap-2 min-w-0 flex-1">
                            <div
                              className={cn(
                                "flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-[10px] font-bold shadow-2xs",
                                isSelected
                                  ? "bg-primary text-primary-foreground"
                                  : "bg-muted text-muted-foreground border border-border",
                              )}
                            >
                              {persona.avatar}
                            </div>
                            <div className="flex flex-col min-w-0 flex-1">
                              <div className="flex items-center gap-1.5">
                                <span className="truncate font-semibold text-foreground text-xs">
                                  {persona.name}
                                </span>
                                <span className="rounded bg-muted/80 px-1 py-0.2 text-[9px] font-mono text-muted-foreground border border-border/50">
                                  {persona.code}
                                </span>
                              </div>
                              <div className="flex items-center gap-1.5 text-[10px] text-muted-foreground truncate">
                                <span className="truncate font-normal">
                                  {persona.designation || persona.label}
                                </span>
                                <span className="text-muted-foreground/30">•</span>
                                <span className="shrink-0 text-[9px] font-medium text-primary/80">
                                  {persona.roleKey}
                                </span>
                              </div>
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
                  No employee matching &quot;{roleQuery}&quot;
                </div>
              )}
            </div>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
