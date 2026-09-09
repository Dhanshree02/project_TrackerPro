import {
  LayoutDashboard,
  ListChecks,
  FolderKanban,
  BarChart3,
  Users,
  Building2,
  Building,
  Activity,
  CheckCircle2,
  Inbox,
  Layers,
  Settings,
  Clock,
  type LucideIcon,
} from "lucide-react";

/**
 * Central navigation registry.
 *
 * Every sidebar / mobile-tab item declares the permission(s) required to see
 * it. The sidebar renders only items the signed-in user is allowed to see, and
 * the route guard (`ROUTE_PERMISSIONS`) blocks direct URL access to everything
 * else. Permission keys mirror the backend catalogue.
 */

export interface NavSubItem {
  to: string;
  label: string;
  search?: Record<string, unknown>;
  /** Required permission(s); undefined = inherited from the parent item. */
  permission?: string | string[];
}

export interface NavItem {
  to?: string;
  label: string;
  icon: LucideIcon;
  exact?: boolean;
  /** Required permission(s) for this item (parent level). */
  permission?: string | string[];
  subItems?: NavSubItem[];
}

// ─── Standard Application Navigation Items ──────────────────────────────────
export const NAV_ITEMS: NavItem[] = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard, exact: true, permission: "dashboard.view" },
  {
    to: "/action-centre",
    label: "Action Centre",
    icon: ListChecks,
    permission: ["action-center.view", "action.bucket_list", "action.approvals", "action.alerts"],
  },
  { to: "/projects", label: "Projects", icon: FolderKanban, permission: "projects.view" },
  { to: "/reports", label: "Reports", icon: BarChart3, permission: "reports.view" },
  {
    label: "Resources",
    icon: Users,
    permission: "resources.view",
    subItems: [
      { to: "/dh-employee-directory", label: "Employee Directory", permission: "resources.view" },
      { to: "/dh-resource-pool", label: "Resource Pool", permission: ["resources.pool", "resources.pool.view"] },
      { to: "/dh-exit-summary", label: "Exit Summary", permission: ["resources.exit_summary", "resources.exit-summary.view"] },
    ],
  },
  { to: "/customers", label: "Customers", icon: Building2, permission: "customers.view" },
  { to: "/my-org", label: "Repository", icon: Building, permission: "repository.view" },
  {
    label: "My Team",
    icon: Users,
    permission: ["my-team.dashboard.view", "my_team.dashboard", "timesheet.approve", "my-team.timesheet-approval.view"],
    subItems: [
      { to: "/my-team/", label: "Team Dashboard", permission: ["my-team.dashboard.view", "my_team.dashboard"] },
      { to: "/timesheet", label: "My Timesheet", permission: ["timesheet.my", "my-team.my-timesheet.view"] },
      {
        to: "/my-team/timesheets",
        label: "Timesheet Approval",
        permission: ["timesheet.approve", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve"],
      },
    ],
  },
  {
    label: "Settings",
    icon: Settings,
    permission: ["settings.view", "settings.manage_roles", "settings.roles.view"],
    subItems: [
      {
        to: "/dh-settings-security-roles",
        label: "Roles & Permissions",
        permission: ["settings.manage_roles", "settings.roles.view", "settings.roles.manage", "settings.view"],
      },
    ],
  },
];

// ─── Super Admin (Dhanshree) Navigation Items ───────────────────────────────
export const DH_NAV_ITEMS: NavItem[] = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard, exact: true, permission: "dashboard.view" },
  {
    to: "/action-centre",
    label: "Action Centre",
    icon: ListChecks,
    permission: "action-center.view",
  },
  { to: "/projects", label: "Projects", icon: FolderKanban, permission: "projects.view" },
  { to: "/dh-reports", label: "Reports", icon: BarChart3, permission: "reports.view" },
  {
    label: "Resources",
    icon: Users,
    permission: "resources.view",
    subItems: [
      { to: "/dh-employee-directory", label: "Directory & Resource Pool", permission: "resources.view" },
      { to: "/dh-exit-summary", label: "Exit Summary", permission: "resources.view" },
    ],
  },
  { to: "/customers", label: "Customers", icon: Building2, permission: "customers.view" },
  { to: "/my-org", label: "Repository", icon: Building, permission: "repository.view" },
  {
    label: "My Team",
    icon: Users,
    permission: "my-team.dashboard.view",
    subItems: [
      { to: "/my-team/", label: "Team Dashboard", permission: "my-team.dashboard.view" },
      {
        to: "/my-team/timesheets",
        label: "Timesheets",
        permission: "my-team.timesheet-approval.view",
      },
    ],
  },
  {
    label: "Settings",
    icon: Settings,
    permission: "settings.view",
    subItems: [
      {
        to: "/dh-settings-security-roles",
        label: "Roles & Permissions",
        permission: "settings.view",
      },
    ],
  },
];



export type NavRoleFlags = {
  isEmployee?: boolean;
  isHr?: boolean;
  isPmFamily?: boolean;
  isPmoFamily?: boolean;
  isAccounts?: boolean;
  isSales?: boolean;
};

/**
 * 100% Permission-driven Navigation Filter.
 *
 * Dynamically filters navigation registry based on user's granted permissions.
 * If Admin enables or disables any module or submodule for any role,
 * the sidebar dynamically updates immediately.
 */
export function filterNavItems(
  items: NavItem[],
  hasPermission: (key: string) => boolean,
  hasAny: (...keys: Array<string | undefined | null>) => boolean,
  _flags: NavRoleFlags = {},
): NavItem[] {
  const allowed = (perm?: string | string[]): boolean => {
    if (!perm) return true;
    const list = Array.isArray(perm) ? perm : [perm];
    return hasAny(...list);
  };

  const result: NavItem[] = [];

  for (const item of items) {
    if (item.subItems && item.subItems.length > 0) {
      // Sub-items filtering
      const validSubs = item.subItems.filter((sub) => allowed(sub.permission ?? item.permission));

      if (validSubs.length > 0) {
        // If only 1 subitem is valid (e.g. Employee only having "My Timesheet"), collapse to single link
        if (validSubs.length === 1 && validSubs[0].to === "/timesheet") {
          result.push({
            to: "/timesheet",
            label: "Timesheet",
            icon: Clock,
            permission: undefined,
          });
        } else if (validSubs.length === 1 && item.label === "Resources" && !allowed("resources.pool")) {
          result.push({
            to: validSubs[0].to,
            label: item.label,
            icon: item.icon,
            permission: undefined,
          });
        } else {
          result.push({
            ...item,
            permission: undefined,
            subItems: validSubs.map((s) => ({ ...s, permission: undefined })),
          });
        }
      } else if (allowed(item.permission) && item.to) {
        result.push({ ...item, permission: undefined, subItems: undefined });
      }
      continue;
    }

    if (allowed(item.permission)) {
      result.push({ ...item, permission: undefined });
    }
  }

  // If user has timesheet.my permission but no team dashboard, ensure Timesheet is reachable
  const hasMyTimesheet = hasAny("timesheet.my", "my-team.my-timesheet.view");
  const hasTeamDashboard = hasAny("my-team.dashboard.view", "my_team.dashboard");
  const hasTimesheetInNav = result.some((r) => r.to === "/timesheet" || r.subItems?.some((s) => s.to === "/timesheet"));

  if (hasMyTimesheet && !hasTeamDashboard && !hasTimesheetInNav) {
    result.push({
      to: "/timesheet",
      label: "Timesheet",
      icon: Clock,
      permission: undefined,
    });
  }

  return result;
}

// ─── Route guard map ─────────────────────────────────────────────────────────
// Longest matching prefix wins. `permission: null` = always allowed (any
// authenticated user). Every route that renders app content is listed so
// direct URL access is blocked for users without the required permission.
export const ROUTE_PERMISSIONS: { prefix: string; permission: string | string[] | null }[] = [
  { prefix: "/dh-settings-security-roles", permission: ["settings.manage_roles", "settings.roles.manage", "roles:manage", "users:manage", "settings.roles.view"] },
  { prefix: "/dh-settings", permission: ["settings.view", "settings.manage_roles", "settings.roles.view"] },
  { prefix: "/action-centre", permission: ["action-center.view", "action.bucket_list", "action.approvals", "action.alerts", "action.notifications"] },
  { prefix: "/projects/new", permission: ["projects.create", "projects:write"] },
  { prefix: "/projects", permission: ["projects.view", "projects:read"] },
  { prefix: "/customers", permission: ["customers.view", "clients:read"] },
  { prefix: "/dh-reports", permission: ["reports.view", "reports:read"] },
  { prefix: "/reports", permission: ["reports.view", "reports:read"] },
  { prefix: "/dh-resource-pool", permission: ["resources.view", "resources.pool", "resources.pool.view"] },
  { prefix: "/dh-exit-summary", permission: ["resources.view", "resources.exit_summary", "resources.exit-summary.view"] },
  { prefix: "/dh-employee-directory", permission: ["resources.view", "resources.directory.view", "resources:read"] },
  { prefix: "/resources", permission: ["resources.view", "resources:read"] },
  { prefix: "/my-org", permission: "repository.view" },
  {
    prefix: "/my-team/timesheets",
    permission: ["timesheet.approve", "my-team.timesheet-approval.view", "my-team.timesheet-approval.approve", "timesheets:approve"],
  },
  { prefix: "/my-team", permission: ["my-team.dashboard.view", "my_team.dashboard"] },
  { prefix: "/timesheet", permission: ["timesheet.my", "my-team.my-timesheet.view", "timesheets:submit"] },
  { prefix: "/health", permission: ["projects.health.view", "projects.health.issues", "projects.health.manage"] },
  {
    prefix: "/approvals",
    permission: [
      "approvals.view",
      "approvals.approve",
      "action.acknowledge",
      "my-team.timesheet-approval.approve",
      "my-team.timesheet-approval.view",
    ],
  },
  { prefix: "/wbs-allocation", permission: ["wbs.allocate", "wbs.view", "wbs:allocate", "wbs:read"] },
  { prefix: "/allocation", permission: ["wbs.allocate", "wbs.view"] },
  { prefix: "/portfolio", permission: "portfolio.view" },
  { prefix: "/change-password", permission: null },
  { prefix: "/access-denied", permission: null },
  { prefix: "/", permission: "dashboard.view" },
];

/** Resolves the required permission for a pathname (longest prefix wins). */
export function resolveRoutePermission(pathname: string): string | string[] | null {
  let best: { prefix: string; permission: string | string[] | null } | null = null;
  for (const entry of ROUTE_PERMISSIONS) {
    if (pathname.startsWith(entry.prefix) && (!best || entry.prefix.length > best.prefix.length)) {
      best = entry;
    }
  }
  return best?.permission ?? null;
}
