import { Link, useRouterState } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import { ChevronDown, ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { NAV_ITEMS, DH_NAV_ITEMS, filterNavItems, type NavItem } from "@/lib/navigation";

export function AppSidebar() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const search = useRouterState({ select: (s) => s.location.search }) as any;
  const {
    assignedIssues,
    pendingTimesheets,
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
  // are rendered. Dhanshree/Admin keep the super-admin workspace layout.
  const items: NavItem[] = filterNavItems(
    isDhanshree ? DH_NAV_ITEMS : NAV_ITEMS,
    hasPermission,
    hasAny,
    { isEmployee, isHr, isPmFamily, isPmoFamily, isAccounts, isSales },
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

    if (normTo === "/dh-employee-directory") {
      const activeTab = search.tab || "directory";
      const expectedTab = subSearch?.tab || "directory";
      return activeTab === expectedTab;
    }

    return true;
  };

  const [openDropdowns, setOpenDropdowns] = useState<Record<string, boolean>>({});

  useEffect(() => {
    // Auto-open Resources if we are in any of the resource sub-routes
    const resourceRoutes = ["/dh-employee-directory", "/dh-resource-pool", "/dh-exit-summary"];
    if (resourceRoutes.some((route) => pathname.startsWith(route))) {
      setOpenDropdowns((prev) => ({ ...prev, Resources: true }));
    }
    // Auto-open My Team if we are in any of its sub-routes
    if (pathname.startsWith("/my-team")) {
      setOpenDropdowns((prev) => ({ ...prev, "My Team": true }));
    }
  }, [pathname]);

  const toggleDropdown = (label: string) => {
    setOpenDropdowns((prev) => ({ ...prev, [label]: !prev[label] }));
  };

  return (
    <aside
      className={cn(
        "relative hidden md:flex h-screen sticky top-0 shrink-0 flex-col border-r border-border bg-sidebar text-sidebar-foreground transition-all duration-300 z-40",
        isCollapsed ? "w-16" : "w-60",
      )}
    >
      {/* Floating toggle button — sits half on sidebar, half on body */}
      <button
        onClick={toggleCollapse}
        className="absolute right-0 top-1/2 z-50 flex h-7 w-7 -translate-y-1/2 translate-x-1/2 items-center justify-center rounded-full border border-primary bg-primary text-primary-foreground shadow-md hover:bg-primary/80 hover:border-primary/80 transition-all duration-200"
        title={isCollapsed ? "Expand Sidebar" : "Collapse Sidebar"}
      >
        {isCollapsed ? <ChevronRight className="h-4 w-4" /> : <ChevronLeft className="h-4 w-4" />}
      </button>
      <div className="flex h-14 items-center gap-2 border-b border-sidebar-border px-4 justify-between">
        <div className="flex items-center gap-2 overflow-hidden">
          <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-md bg-primary text-primary-foreground font-bold">
            P
          </div>
          {!isCollapsed && (
            <div className="flex flex-col leading-tight animate-in fade-in duration-300">
              <span className="text-sm font-semibold truncate">Pulse PMO</span>
              <span className="text-[10px] uppercase tracking-wider text-muted-foreground truncate">
                Enterprise
              </span>
            </div>
          )}
        </div>
      </div>
      <nav
        className={cn("flex-1 p-2 space-y-1", isCollapsed ? "overflow-visible" : "overflow-y-auto")}
      >
        {items.map((it) => {
          if (it.subItems) {
            const isExpanded = openDropdowns[it.label] ?? false;
            const isParentActive = it.subItems.some((sub) => isActive(sub.to, true, sub.search));

            return (
              <div key={it.label} className="relative group/sidebar-item flex flex-col gap-1">
                <button
                  onClick={() => {
                    if (!isCollapsed) {
                      toggleDropdown(it.label);
                    }
                  }}
                  className={cn(
                    "group flex w-full items-center rounded-md transition-colors text-left outline-none",
                    isCollapsed ? "justify-center p-2" : "gap-3 px-3 py-2 text-sm",
                    isParentActive
                      ? "bg-sidebar-accent/50 text-sidebar-accent-foreground font-medium"
                      : "text-sidebar-foreground/80 hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground",
                  )}
                >
                  <it.icon className="h-4 w-4 shrink-0" />
                  {!isCollapsed && <span className="flex-1 truncate">{it.label}</span>}
                  {!isCollapsed && (
                    <ChevronDown
                      className={cn(
                        "h-4 w-4 shrink-0 transition-transform duration-200 text-muted-foreground",
                        isExpanded && "rotate-180",
                      )}
                    />
                  )}
                </button>

                {/* Collapsed Hover Flyout Popover Window */}
                {isCollapsed && (
                  <div className="hidden group-hover/sidebar-item:flex flex-col absolute left-full -top-1 ml-3 w-52 rounded-xl border border-border bg-card dark:bg-slate-900 text-card-foreground shadow-2xl z-[9999] p-2 animate-in fade-in zoom-in-95 duration-150 before:absolute before:-left-4 before:top-0 before:bottom-0 before:w-4">
                    <div className="flex items-center gap-2 px-2.5 py-2 text-xs font-bold border-b border-border text-foreground mb-1.5 bg-muted/40 dark:bg-slate-800/60 rounded-t-md">
                      <it.icon className="h-4 w-4 text-primary" />
                      <span>{it.label}</span>
                    </div>
                    <div className="flex flex-col gap-0.5">
                      {it.subItems.map((sub) => {
                        const subActive = isActive(sub.to, true, sub.search);
                        return (
                          <Link
                            key={sub.to + (sub.search?.tab || "")}
                            to={sub.to}
                            search={sub.search as any}
                            className={cn(
                              "flex items-center justify-between rounded-md px-3 py-2 text-xs transition-colors",
                              subActive
                                ? "bg-primary/10 text-primary font-semibold"
                                : "text-foreground/80 hover:bg-accent hover:text-accent-foreground",
                            )}
                          >
                            <span>{sub.label}</span>
                            {subActive && <span className="h-1.5 w-1.5 rounded-full bg-primary" />}
                          </Link>
                        );
                      })}
                    </div>
                  </div>
                )}

                {/* Expanded SubItems */}
                {!isCollapsed && isExpanded && (
                  <div className="ml-7 flex flex-col gap-1 border-l border-sidebar-border/60 pl-3">
                    {it.subItems.map((sub) => {
                      const subActive = isActive(sub.to, true, sub.search);
                      return (
                        <Link
                          key={sub.to + (sub.search?.tab || "")}
                          to={sub.to}
                          search={sub.search as any}
                          className={cn(
                            "rounded-md px-3 py-1.5 text-xs transition-colors",
                            subActive
                              ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                              : "text-sidebar-foreground/70 hover:bg-sidebar-accent/40 hover:text-sidebar-accent-foreground",
                          )}
                        >
                          {sub.label}
                        </Link>
                      );
                    })}
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
                  "group flex items-center rounded-md transition-colors",
                  isCollapsed ? "justify-center p-2" : "gap-3 px-3 py-2 text-sm",
                  active
                    ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                    : "text-sidebar-foreground/80 hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground",
                )}
              >
                <it.icon className="h-4 w-4 shrink-0" />
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
