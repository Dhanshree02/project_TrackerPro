import {
  LayoutDashboard,
  ListChecks,
  FolderKanban,
  Users,
  Building2,
  Building,
  Settings,
  type LucideIcon,
} from "lucide-react";

/**
 * Central navigation registry.
 *
 * Every sidebar / mobile-tab item declares the permission(s) required to see
 * it. The sidebar renders only items the signed-in user is allowed to see, and
 * the route guard (`ROUTE_PERMISSIONS`) blocks direct URL access to everything
 * else. Permission keys mirror the backend catalogue
 * (`Shared/Constants/PermissionCatalog.cs`).
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

/** Sidebar modules turned off for UAT (direct URLs redirect to Projects). */
const HIDDEN_NAV_LABELS = new Set(["Reports"]);

function stripHiddenNavItems(items: NavItem[]): NavItem[] {
  return items.filter((item) => !HIDDEN_NAV_LABELS.has(item.label));
}

// ─── Generic (non-Dhanshree) navigation ─────────────────────────────────────
export const NAV_ITEMS: NavItem[] = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard, exact: true, permission: "dashboard.view" },
  {
    to: "/action-centre",
    label: "Action Centre",
    icon: ListChecks,
    permission: "action-center.view",
  },
  { to: "/projects", label: "Projects", icon: FolderKanban, permission: "projects.view" },
  { to: "/resources", label: "Resources", icon: Users, permission: "resources.view" },
  { to: "/customers", label: "Customers", icon: Building2, permission: "customers.view" },
  { to: "/my-org", label: "Repository", icon: Building, permission: "repository.view" },
  {
    label: "My Team",
    icon: Users,
    subItems: [
      { to: "/my-team/", label: "Team Dashboard" },
      {
        to: "/my-team/timesheets",
        label: "Timesheet Approval",
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
      { to: "/dh-settings-masters", label: "Masters", permission: "settings.view" },
    ],
  },
];

// ─── Dhanshree / Admin (super-admin workspace) navigation ───────────────────
export const DH_NAV_ITEMS: NavItem[] = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard, exact: true, permission: "dashboard.view" },
  {
    to: "/action-centre",
    label: "Action Centre",
    icon: ListChecks,
    permission: "action-center.view",
  },
  { to: "/projects", label: "Projects", icon: FolderKanban, permission: "projects.view" },
  {
    label: "Resources",
    icon: Users,
    permission: "resources.view",
    subItems: [
      { to: "/dh-employee-directory", label: "Employee Directory" },
      { to: "/dh-exit-summary", label: "Exit Summary" },
    ],
  },
  { to: "/customers", label: "Customers", icon: Building2, permission: "customers.view" },
  { to: "/my-org", label: "Repository", icon: Building, permission: "repository.view" },
  {
    label: "My Team",
    icon: Users,
    subItems: [
      { to: "/my-team/", label: "Team Dashboard" },
      {
        to: "/my-team/timesheets",
        label: "Timesheets",
      },
    ],
  },
  {
    label: "Settings",
    icon: Settings,
    permission: "settings.view",
    subItems: [
      { to: "/dh-settings-security-roles", label: "Roles & Permissions" },
      { to: "/dh-settings-masters", label: "Masters" },
    ],
  },
];

/**
 * Filters a nav registry to the items the user may see. An item with
 * sub-items is shown when at least one sub-item passes (or it passes on its
 * own); sub-items inherit the parent permission unless they declare their own.
 */
export type NavRoleFlags = {
  isAdmin?: boolean;
  isItAdmin?: boolean;
  isEmployee?: boolean;
  isHr?: boolean;
  isPmFamily?: boolean;
  isPmoFamily?: boolean;
  isAccounts?: boolean;
  isSales?: boolean;
};

export function filterNavItems(
  items: NavItem[],
  hasPermission: (key: string) => boolean,
  hasAny: (...keys: Array<string | undefined | null>) => boolean,
  flags: NavRoleFlags = {},
): NavItem[] {
  const { isAdmin } = flags;

  // Admin has super-admin visibility into every module and submodule
  if (isAdmin) {
    return stripHiddenNavItems(
      items.map((item) => ({
        ...item,
        permission: undefined,
        subItems: item.subItems?.map((s) => ({ ...s, permission: undefined })),
      })),
    );
  }

  const allowed = (perm?: string | string[]): boolean => {
    if (!perm) return true;
    const list = Array.isArray(perm) ? perm : [perm];
    return hasAny(...list);
  };

  const result: NavItem[] = [];
  for (const item of items) {
    const parentAllowed = allowed(item.permission);

    if (item.subItems) {
      const subs = item.subItems
        .filter((s) => parentAllowed && allowed(s.permission))
        .map((s) => ({ ...s, permission: undefined }));
      if (subs.length > 0) result.push({ ...item, permission: undefined, subItems: subs });
      continue;
    }

    if (parentAllowed) result.push({ ...item, permission: undefined });
  }

  return result;
}

// ─── Route guard map ─────────────────────────────────────────────────────────
// Longest matching prefix wins. `permission: null` = always allowed (any
// authenticated user). Every route that renders app content must be listed so
// direct URL access is blocked for users without the permission.
export const ROUTE_PERMISSIONS: { prefix: string; permission: string | string[] | null }[] = [
  { prefix: "/dh-settings-masters", permission: ["settings.masters.view", "Settings|Masters:view"] },
  { prefix: "/settings/masters", permission: ["settings.masters.view", "Settings|Masters:view"] },
  { prefix: "/dh-settings-security-roles", permission: ["settings.manage_roles", "roles:manage", "settings.roles.view", "roles.view", "Settings|Roles & Permission:view", "Settings|Roles & Permission|Moduleswise Access:view", "Settings|Roles & Permission|User Role Access:view"] },
  { prefix: "/dh-settings", permission: "settings.view" },
  { prefix: "/action-centre", permission: "action-center.view" },
  { prefix: "/projects/new", permission: "projects.create" },
  { prefix: "/projects", permission: "projects.view" },
  { prefix: "/customers", permission: "customers.view" },
  { prefix: "/dh-reports", permission: "reports.view" },
  { prefix: "/reports", permission: "reports.view" },
  { prefix: "/dh-resource-pool", permission: "resources.view" },
  { prefix: "/dh-exit-summary", permission: "resources.view" },
  { prefix: "/dh-employee-directory", permission: "resources.view" },
  { prefix: "/resources", permission: "resources.view" },
  { prefix: "/my-org", permission: "repository.view" },
  {
    prefix: "/my-team/timesheets",
    permission: [
      "My team|Timesheets:view",
      "My team|Timesheets|My timsheet:view",
      "My team|Timesheets|Timesheet Approval:view",
      "my-team.timesheets.view",
      "timesheets.view",
      "timesheets.submit",
      "timesheets.monitor",
      "timesheet.my",
      "timesheet.approve",
    ],
  },
  {
    prefix: "/my-team",
    permission: [
      "My team|Team Dashboard:view",
      "my-team.team-dashboard.view",
    ],
  },
  { prefix: "/timesheet", permission: "my-team.my-timesheet.view" },
  { prefix: "/health", permission: "projects.health.view" },
  {
    prefix: "/approvals",
    permission: [
      "approvals.view",
      "my-team.timesheet-approval.approve",
      "my-team.timesheet-approval.view",
    ],
  },
  { prefix: "/wbs-allocation", permission: "wbs.allocate" },
  { prefix: "/allocation", permission: "wbs.allocate" },
  { prefix: "/portfolio", permission: "portfolio.view" },
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
