import { Link, useRouterState } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import {
  LayoutDashboard,
  Briefcase,
  Activity,
  CheckCircle2,
  Users,
  Inbox,
  BarChart3,
  Layers,
  ListChecks,
  FolderKanban,
  Building2,
  Building,
  ContactRound,
  Settings,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useRoleContext } from "@/lib/role-context";

type SubItem = { to: string; search?: Record<string, any>; label: string };
type Item = {
  to?: string;
  label: string;
  icon: typeof LayoutDashboard;
  exact?: boolean;
  subItems?: SubItem[];
};

const dashboardItem: Item = { to: "/", label: "Dashboard", icon: LayoutDashboard, exact: true };
const clientsItem: Item = { to: "/clients", label: "Clients & Projects", icon: Briefcase };
const portfolioItem: Item = { to: "/portfolio", label: "Portfolio", icon: Layers };
const wbsItem: Item = { to: "/wbs-allocation", label: "WBS Allocation", icon: Inbox };
const resourcesItem: Item = { to: "/resources", label: "Resources", icon: Users };
const healthItem: Item = { to: "/health", label: "Health & Governance", icon: Activity };
const approvalsItem: Item = { to: "/approvals", label: "Approvals", icon: CheckCircle2 };
const reportsItem: Item = { to: "/reports", label: "Reports", icon: BarChart3 };

// Dhanshree-specific items
const dhActionCentre: Item = { to: "/action-centre", label: "Action Centre", icon: ListChecks };
const dhProjects: Item = { to: "/projects", label: "Projects", icon: FolderKanban };
const dhReports: Item = { to: "/dh-reports", label: "Reports", icon: BarChart3 };
const dhCustomers: Item = { to: "/customers", label: "Customers", icon: Building2 };
const dhMyOrg: Item = { to: "/my-org", label: "Repository", icon: Building };
const dhMyTeam: Item = {
  label: "My Team",
  icon: Users,
  subItems: [
    { to: "/my-team/", label: "Team Dashboard" },
    { to: "/my-team/timesheets", label: "Timesheets" },
  ],
};
const dhSettings: Item = { to: "/dh-settings", label: "Settings", icon: Settings };

const dhResourcesDropdown: Item = {
  label: "Resources",
  icon: Users,
  subItems: [
    { to: "/dh-employee-directory", label: "Directory & Pool" },
    { to: "/dh-exit-summary", label: "Exit Summary" },
  ],
};

export function AppSidebar() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const search = useRouterState({ select: (s) => s.location.search }) as any;
  const { assignedIssues, pendingTimesheets, isPMO, isHOD, isBO, isDhanshree } = useRoleContext();
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

  const items: Item[] = isDhanshree
    ? [dashboardItem, dhActionCentre, dhProjects, dhReports, dhResourcesDropdown, dhCustomers, dhMyOrg, dhMyTeam, dhSettings]
    : isBO
      ? [dashboardItem, portfolioItem, clientsItem, resourcesItem, healthItem, reportsItem]
      : isHOD
        ? [dashboardItem, portfolioItem, resourcesItem, healthItem, approvalsItem, reportsItem]
        : isPMO
          ? [dashboardItem, clientsItem, wbsItem, resourcesItem, healthItem, approvalsItem]
          : [dashboardItem, clientsItem, healthItem, approvalsItem];

  const isActive = (to?: string, exact?: boolean, subSearch?: Record<string, any>) => {
    if (!to) return false;
    // Normalise both sides — strip trailing slashes for comparison
    const norm = (p: string) => p.replace(/\/+$/, "") || "/";
    const normTo = norm(to);
    const normPath = norm(pathname);

    const pathMatch = exact
      ? normPath === normTo
      : (normPath === normTo || normPath.startsWith(normTo + "/"));

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
    if (resourceRoutes.some(route => pathname.startsWith(route))) {
      setOpenDropdowns(prev => ({ ...prev, Resources: true }));
    }
    // Auto-open My Team if we are in any of its sub-routes
    if (pathname.startsWith("/my-team")) {
      setOpenDropdowns(prev => ({ ...prev, "My Team": true }));
    }
  }, [pathname]);

  const toggleDropdown = (label: string) => {
    setOpenDropdowns(prev => ({ ...prev, [label]: !prev[label] }));
  };

  return (
    <aside className={cn("relative hidden md:flex h-screen sticky top-0 shrink-0 flex-col border-r border-border bg-sidebar text-sidebar-foreground transition-all duration-300",
      isCollapsed ? "w-16" : "w-60"
    )}>
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
      <nav className="flex-1 overflow-y-auto p-2 space-y-1">
        {items.map((it) => {
          if (it.subItems) {
            const isExpanded = openDropdowns[it.label] ?? false;
            const isParentActive = it.subItems.some(sub => isActive(sub.to, true, sub.search));

            return (
              <div key={it.label} className="flex flex-col gap-1">
                <button
                  onClick={() => {
                    if (isCollapsed) {
                      setIsCollapsed(false);
                      setOpenDropdowns(prev => ({ ...prev, [it.label]: true }));
                    } else {
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
                  title={isCollapsed ? it.label : undefined}
                >
                  <it.icon className="h-4 w-4 shrink-0" />
                  {!isCollapsed && <span className="flex-1 truncate">{it.label}</span>}
                  {!isCollapsed && (
                    <ChevronDown
                      className={cn(
                        "h-4 w-4 shrink-0 transition-transform duration-200 text-muted-foreground",
                        isExpanded && "rotate-180"
                      )}
                    />
                  )}
                </button>
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
            it.to === "/health" ? openIssues :
              it.to === "/approvals" ? pendingTimesheets.length :
                0;

          return (
            <Link
              key={it.to}
              to={it.to!}
              className={cn(
                "group flex items-center rounded-md transition-colors",
                isCollapsed ? "justify-center p-2" : "gap-3 px-3 py-2 text-sm",
                active
                  ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                  : "text-sidebar-foreground/80 hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground",
              )}
              title={isCollapsed ? it.label : undefined}
            >
              <it.icon className="h-4 w-4 shrink-0" />
              {!isCollapsed && <span className="flex-1 truncate">{it.label}</span>}
              {!isCollapsed && badge > 0 && (
                <span className="rounded-full bg-primary/15 px-2 py-0.5 text-[10px] font-semibold text-primary">
                  {badge}
                </span>
              )}
            </Link>
          );
        })}
      </nav>
      <div className="border-t border-sidebar-border p-2">
        {!isCollapsed && (
          <div className="text-[11px] text-muted-foreground truncate max-w-[150px] animate-in fade-in duration-300">
            {isDhanshree ? "v1.0 · Workspace" : isBO ? "v1.0 · Executive oversight" : isHOD ? "v1.0 · Department oversight" : isPMO ? "v1.0 · Governance + allocation" : "v1.0 · Read-only tracking"}
          </div>
        )}
      </div>
    </aside>
  );
}
