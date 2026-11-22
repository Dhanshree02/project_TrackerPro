import { Link, useRouterState } from "@tanstack/react-router";
import { useState, useEffect, useMemo, useRef } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { DisclosureTriangleIcon } from "@/components/disclosure-controls";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { filterNavItems, NAV_ITEMS, type NavItem, type NavSubItem } from "@/lib/navigation";

export function AppSidebar() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const search = useRouterState({ select: (s) => s.location.search }) as any;
  const {
    assignedIssues,
    pendingTimesheets,
    isAdmin,
    isItAdmin,
    isPMO,
    isHOD,
    isBO,
    isDhanshree,
    isEmployee,
    isHr,
    isPmFamily,
    isPmoFamily,
    isAccounts,
    isSales,
  } = useRoleContext();
  const { hasPermission, hasAny } = usePermissions();
  const openIssues = assignedIssues.filter((i) => i.status === "open").length;

  const [isCollapsed, setIsCollapsed] = useState(() => {
    if (typeof window !== "undefined") {
      return localStorage.getItem("sidebar-collapsed") === "true";
    }
    return false;
  });

  const toggleCollapse = () => {
    setIsCollapsed((prev) => {
      const next = !prev;
      localStorage.setItem("sidebar-collapsed", String(next));
      return next;
    });
  };

  // Navigation is permission-driven: only modules the signed-in user may access
  // are rendered. Admin and Dhanshree get full super-admin workspace navigation.
  const items: NavItem[] = useMemo(
    () =>
      filterNavItems(NAV_ITEMS, hasPermission, hasAny, {
        isAdmin,
        isItAdmin,
        isEmployee,
        isHr,
        isPmFamily,
        isPmoFamily,
        isAccounts,
        isSales,
      }),
    [
      hasPermission,
      hasAny,
      isAdmin,
      isItAdmin,
      isEmployee,
      isHr,
      isPmFamily,
      isPmoFamily,
      isAccounts,
      isSales,
    ],
  );

  const isActive = (to?: string, exact?: boolean, subSearch?: Record<string, any>) => {
    if (!to) return false;
    // Normalise both sides — strip trailing slashes for comparison
    const norm = (p: string) => p.replace(/\/+$/, "") || "/";
    const normTo = norm(to);
    const normPath = norm(pathname);

    const pathMatch = exact
      ? normPath === normTo
      : normPath === normTo || normPath.startsWith(normTo + "/");

    if (!pathMatch) return false;

    if (normTo === "/employee-directory") {
      const activeTab = search.tab || "directory";
      const expectedTab = subSearch?.tab || "directory";
      return activeTab === expectedTab;
    }

    return true;
  };

  const [openDropdowns, setOpenDropdowns] = useState<Record<string, boolean>>({});
  const autoOpenedPath = useRef<string | null>(null);

  const branchActive = (subs?: NavSubItem[]): boolean =>
    !!subs?.some(
      (sub) => (sub.to ? isActive(sub.to, false, sub.search) : false) || branchActive(sub.subItems),
    );

  useEffect(() => {
    if (autoOpenedPath.current === pathname) return;
    if (!items.some((item) => (item.subItems?.length ?? 0) > 0)) return;
    autoOpenedPath.current = pathname;
    setOpenDropdowns((prev) => {
      const next = { ...prev };
      let changed = false;
      const visit = (code: string | undefined, subs?: NavSubItem[]): boolean => {
        if (!subs?.length) return false;
        const hit = subs.some(
          (sub) => (sub.to ? isActive(sub.to, false, sub.search) : false) || visit(sub.code, sub.subItems),
        );
        if (code && hit && !next[code]) {
          next[code] = true;
          changed = true;
        }
        return hit;
      };
      for (const item of items) visit(item.code ?? item.label, item.subItems);
      return changed ? next : prev;
    });
  }, [pathname, items]);

  const toggleDropdown = (key: string) => {
    setOpenDropdowns((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const renderSubItems = (subs: NavSubItem[], flyout = false) =>
    subs.map((sub) => {
      const key = sub.code ?? sub.to ?? sub.label;
      if (sub.subItems?.length) {
        const open = openDropdowns[key] ?? false;
        return (
          <div key={key} className="flex flex-col gap-0.5">
            <button
              type="button"
              aria-expanded={open}
              aria-label={`${open ? "Collapse" : "Expand"} ${sub.label}`}
              onClick={() => toggleDropdown(key)}
              className={cn(
                "flex w-full items-center gap-2 rounded-lg px-3 py-1.5 text-left text-xs",
                flyout
                  ? "text-foreground/80 hover:bg-accent hover:text-accent-foreground"
                  : "text-sidebar-foreground/70 hover:bg-foreground/5 hover:text-foreground",
              )}
            >
              <span className="min-w-0 flex-1 truncate">{sub.label}</span>
              <DisclosureTriangleIcon expanded={open} size="xs" className="shrink-0 text-current opacity-70" />
            </button>
            {open && (
              <div className="ml-3 flex flex-col gap-0.5 border-l border-border/60 pl-2">
                {renderSubItems(sub.subItems, flyout)}
              </div>
            )}
          </div>
        );
      }
      if (!sub.to) return null;
      const subActive = isActive(sub.to, true, sub.search);
      return (
        <Link
          key={key}
          to={sub.to}
          search={sub.search as any}
          className={cn(
            "flex items-center justify-between rounded-lg px-3 py-1.5 text-xs transition-colors",
            flyout
              ? subActive
                ? "bg-primary/10 text-primary font-semibold"
                : "text-foreground/80 hover:bg-accent hover:text-accent-foreground"
              : subActive
                ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium shadow-xs"
                : "text-sidebar-foreground/70 hover:bg-foreground/5 hover:text-foreground",
          )}
        >
          <span>{sub.label}</span>
          {flyout && subActive && <span className="h-1.5 w-1.5 rounded-full bg-primary" />}
        </Link>
      );
    });

  return (
    <aside
      className={cn(
        "relative hidden md:flex h-screen sticky top-0 shrink-0 flex-col border-r border-border bg-sidebar text-sidebar-foreground transition-[width] duration-300 z-40",
        isCollapsed ? "w-16" : "w-60",
      )}
    >
      {/* Floating toggle button — sits half on sidebar, half on body */}
      <button
        onClick={toggleCollapse}
        className="absolute right-0 top-1/2 z-50 flex h-8 w-8 -translate-y-1/2 translate-x-1/2 items-center justify-center rounded-full border border-black/15 bg-white text-[#1d1d1f] shadow-[0_2px_10px_rgba(0,0,0,0.22)] transition-colors duration-200 hover:bg-[#f5f5f7] dark:border-white/25 dark:bg-[#48484a] dark:text-white dark:hover:bg-[#5c5c5e]"
        title={isCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
      >
        {isCollapsed ? <ChevronRight className="h-4 w-4" strokeWidth={2.75} /> : <ChevronLeft className="h-4 w-4" strokeWidth={2.75} />}
      </button>
      <div
        className={cn(
          "flex h-14 shrink-0 items-center border-b border-sidebar-border",
          isCollapsed ? "justify-center px-2" : "gap-2 px-4",
        )}
      >
        <div className={cn("flex items-center", isCollapsed ? "" : "min-w-0 gap-2")}>
          <div className="relative z-10 flex size-8 shrink-0 items-center justify-center rounded-[9px] bg-foreground text-sm font-semibold text-background">
            P
          </div>
          {!isCollapsed && (
            <div className="flex min-w-0 flex-col overflow-hidden leading-tight animate-in fade-in duration-300">
              <span className="truncate text-sm font-semibold">Pulse PMO</span>
              <span className="truncate text-[10px] uppercase tracking-wider text-muted-foreground">
                Enterprise
              </span>
            </div>
          )}
        </div>
      </div>
      <nav
        className={cn("flex-1 p-3 space-y-0.5", isCollapsed ? "overflow-visible" : "overflow-y-auto")}
      >
        {items.map((it) => {
          if (it.subItems) {
            const menuKey = it.code ?? it.label;
            const isExpanded = openDropdowns[menuKey] ?? false;
            const isParentActive = branchActive(it.subItems);

            return (
              <div key={it.label} className="relative group/sidebar-item flex flex-col gap-1">
                <button
                  type="button"
                  aria-expanded={!isCollapsed ? isExpanded : undefined}
                  aria-label={
                    isCollapsed
                      ? `${it.label} (${it.subItems.length} submodules)`
                      : `${isExpanded ? "Collapse" : "Expand"} ${it.label}`
                  }
                  onClick={() => {
                    if (!isCollapsed) {
                      toggleDropdown(menuKey);
                    }
                  }}
                  title={isCollapsed ? `${it.label} (${it.subItems.length} submodules)` : undefined}
                  className={cn(
                    "group flex w-full items-center rounded-lg transition-colors text-left outline-none",
                    isCollapsed ? "justify-center p-2" : "gap-3 px-3 py-2 text-sm",
                    isParentActive
                      ? isCollapsed
                        ? "bg-sidebar-accent font-medium text-sidebar-accent-foreground shadow-xs"
                        : "font-medium text-foreground"
                      : "text-sidebar-foreground/80 hover:bg-foreground/5 hover:text-foreground",
                  )}
                >
                  <div className="relative flex items-center justify-center">
                    <it.icon className={cn("h-4 w-4 shrink-0", isParentActive && "text-primary")} />
                    {isCollapsed && (
                      <ChevronRight
                        className={cn(
                          "absolute -right-3 top-1/2 -translate-y-1/2 h-2.5 w-2.5 shrink-0 transition-all duration-200 group-hover/sidebar-item:translate-x-0.5",
                          isParentActive
                            ? "text-primary font-bold"
                            : "text-muted-foreground/70 group-hover/sidebar-item:text-foreground",
                        )}
                        strokeWidth={2.5}
                      />
                    )}
                  </div>
                  {!isCollapsed && <span className="min-w-0 flex-1 truncate">{it.label}</span>}
                  {!isCollapsed && (
                    <DisclosureTriangleIcon
                      expanded={isExpanded}
                      size="sm"
                      className={cn("shrink-0", isParentActive ? "text-primary" : "text-muted-foreground")}
                    />
                  )}
                </button>

                {/* Collapsed Hover Flyout Popover Window */}
                {isCollapsed && (
                  <div className="hidden group-hover/sidebar-item:flex flex-col absolute left-full -top-1 ml-3 w-52 rounded-xl border border-border bg-popover text-popover-foreground shadow-2xl z-[9999] p-2 animate-in fade-in zoom-in-95 duration-150 before:absolute before:-left-4 before:top-0 before:bottom-0 before:w-4">
                    <div className="flex items-center gap-2 px-2.5 py-2 text-xs font-bold border-b border-border text-foreground mb-1.5 bg-muted/40 rounded-t-md">
                      <it.icon className="h-4 w-4 text-primary" />
                      <span>{it.label}</span>
                    </div>
                    <div className="flex flex-col gap-0.5">{renderSubItems(it.subItems, true)}</div>
                  </div>
                )}

                {/* Expanded SubItems */}
                {!isCollapsed && isExpanded && (
                  <div className="ml-4 flex flex-col gap-0.5 border-l border-sidebar-border/60 pl-3">
                    {renderSubItems(it.subItems)}
                  </div>
                )}
              </div>
            );
          }

          const active = isActive(it.to, it.exact);
          const badge =
            it.to === "/health"
              ? openIssues
              : it.to === "/approvals"
                ? pendingTimesheets.length
                : 0;

          return (
            <div key={it.to} className="relative group/sidebar-item">
              <Link
                to={it.to!}
                className={cn(
                  "group flex items-center rounded-lg transition-colors",
                  isCollapsed ? "justify-center p-2" : "gap-3 px-3 py-2 text-sm",
                  active
                    ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium shadow-xs"
                    : "text-sidebar-foreground/80 hover:bg-foreground/5 hover:text-foreground",
                )}
              >
                <it.icon className={cn("h-4 w-4 shrink-0", active && "text-primary")} />
                {!isCollapsed && <span className="flex-1 truncate">{it.label}</span>}
                {!isCollapsed && badge > 0 && (
                  <span className="rounded-full bg-primary/15 px-2 py-0.5 text-[10px] font-semibold text-primary">
                    {badge}
                  </span>
                )}
              </Link>

              {/* Collapsed Hover Tooltip for Single Items */}
              {isCollapsed && (
                <div className="hidden group-hover/sidebar-item:block absolute left-full top-1/2 -translate-y-1/2 ml-2 px-2.5 py-1 text-xs font-medium bg-popover text-popover-foreground border border-border shadow-md rounded-md whitespace-nowrap z-50 pointer-events-none animate-in fade-in zoom-in-95 duration-150">
                  {it.label}
                </div>
              )}
            </div>
          );
        })}
      </nav>
      <div className="border-t border-sidebar-border p-2">
        {!isCollapsed && (
          <div className="text-[11px] text-muted-foreground truncate max-w-[150px] animate-in fade-in duration-300">
            {isDhanshree
              ? "v1.0 · Workspace"
              : isBO
                ? "v1.0 · Executive oversight"
                : isHOD
                  ? "v1.0 · Department oversight"
                  : isPMO
                    ? "v1.0 · Governance + allocation"
                    : "v1.0 · Role-based access"}
          </div>
        )}
      </div>
    </aside>
  );
}
