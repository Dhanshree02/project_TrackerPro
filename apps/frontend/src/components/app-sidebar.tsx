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
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useRoleContext } from "@/lib/role-context";

type SubItem = { to: string; label: string };
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
const dhMyOrg: Item = { to: "/my-org", label: "My Org", icon: Building };
const dhMyTeam: Item = { to: "/my-team", label: "My Team", icon: Users };
const dhSettings: Item = { to: "/dh-settings", label: "Settings", icon: Settings };

const dhResourcesDropdown: Item = {
  label: "Resources",
  icon: Users,
  subItems: [
    { to: "/dh-employee-directory", label: "Employee Directory" },
    { to: "/dh-resource-pool", label: "Resource Pool" },
    { to: "/dh-exit-summary", label: "Employee Exit Summary" },
    { to: "/dh-org-tree", label: "Organization Tree" },
  ],
};

export function AppSidebar() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });
  const { assignedIssues, pendingTimesheets, isPMO, isHOD, isBO, isDhanshree } = useRoleContext();
  const openIssues = assignedIssues.filter((i) => i.status === "open").length;

  const items: Item[] = isDhanshree
    ? [dashboardItem, dhActionCentre, dhProjects, dhReports, dhResourcesDropdown, dhCustomers, dhMyOrg, dhMyTeam, dhSettings]
    : isBO
      ? [dashboardItem, portfolioItem, clientsItem, resourcesItem, healthItem, reportsItem]
      : isHOD
        ? [dashboardItem, portfolioItem, resourcesItem, healthItem, approvalsItem, reportsItem]
        : isPMO
          ? [dashboardItem, clientsItem, wbsItem, resourcesItem, healthItem, approvalsItem]
          : [dashboardItem, clientsItem, healthItem, approvalsItem];

  const isActive = (to?: string, exact?: boolean) => {
    if (!to) return false;
    return exact ? pathname === to : pathname === to || pathname.startsWith(to + "/");
  };

  const [openDropdowns, setOpenDropdowns] = useState<Record<string, boolean>>({});

  useEffect(() => {
    // Auto-open Resources if we are in any of the resource sub-routes
    const resourceRoutes = ["/dh-employee-directory", "/dh-resource-pool", "/dh-exit-summary", "/dh-org-tree"];
    if (resourceRoutes.some(route => pathname.startsWith(route))) {
      setOpenDropdowns(prev => ({ ...prev, Resources: true }));
    }
  }, [pathname]);

  const toggleDropdown = (label: string) => {
    setOpenDropdowns(prev => ({ ...prev, [label]: !prev[label] }));
  };

  return (
    <aside className="hidden md:flex w-60 h-screen sticky top-0 shrink-0 flex-col border-r border-border bg-sidebar text-sidebar-foreground">
      <div className="flex h-14 items-center gap-2 border-b border-sidebar-border px-4">
        <div className="flex h-8 w-8 items-center justify-center rounded-md bg-primary text-primary-foreground font-bold">
          P
        </div>
        <div className="flex flex-col leading-tight">
          <span className="text-sm font-semibold">Pulse PMO</span>
          <span className="text-[10px] uppercase tracking-wider text-muted-foreground">
            Enterprise
          </span>
        </div>
      </div>
      <nav className="flex-1 overflow-y-auto p-2 space-y-1">
        {items.map((it) => {
          if (it.subItems) {
            const isExpanded = openDropdowns[it.label] ?? false;
            const isParentActive = it.subItems.some(sub => isActive(sub.to));

            return (
              <div key={it.label} className="flex flex-col gap-1">
                <button
                  onClick={() => toggleDropdown(it.label)}
                  className={cn(
                    "group flex w-full items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors text-left outline-none",
                    isParentActive
                      ? "bg-sidebar-accent/50 text-sidebar-accent-foreground font-medium"
                      : "text-sidebar-foreground/80 hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground",
                  )}
                >
                  <it.icon className="h-4 w-4" />
                  <span className="flex-1">{it.label}</span>
                  <ChevronDown
                    className={cn(
                      "h-4 w-4 shrink-0 transition-transform duration-200 text-muted-foreground",
                      isExpanded && "rotate-180"
                    )}
                  />
                </button>
                {isExpanded && (
                  <div className="ml-7 flex flex-col gap-1 border-l border-sidebar-border/60 pl-3">
                    {it.subItems.map((sub) => {
                      const subActive = isActive(sub.to);
                      return (
                        <Link
                          key={sub.to}
                          to={sub.to}
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
                "group flex items-center gap-3 rounded-md px-3 py-2 text-sm transition-colors",
                active
                  ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                  : "text-sidebar-foreground/80 hover:bg-sidebar-accent/60 hover:text-sidebar-accent-foreground",
              )}
            >
              <it.icon className="h-4 w-4" />
              <span className="flex-1">{it.label}</span>
              {badge > 0 && (
                <span className="rounded-full bg-primary/15 px-2 py-0.5 text-[10px] font-semibold text-primary">
                  {badge}
                </span>
              )}
            </Link>
          );
        })}
      </nav>
      <div className="border-t border-sidebar-border p-3 text-[11px] text-muted-foreground">
        {isDhanshree ? "v1.0 · Workspace" : isBO ? "v1.0 · Executive oversight" : isHOD ? "v1.0 · Department oversight" : isPMO ? "v1.0 · Governance + allocation" : "v1.0 · Read-only tracking"}
      </div>
    </aside>
  );
}
