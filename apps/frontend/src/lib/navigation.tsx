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
  { to: "/reports", label: "Reports", icon: BarChart3, permission: "reports.view" },
  { to: "/resources", label: "Resources", icon: Users, permission: "resources.view" },
  { to: "/customers", label: "Customers", icon: Building2, permission: "customers.view" },
  { to: "/my-org", label: "Repository", icon: Building, permission: "repository.view" },
  {
    label: "My Team",
    icon: Users,
    permission: "my-team.dashboard.view",
    subItems: [
      { to: "/my-team/", label: "Team Dashboard", permission: "my-team.dashboard.view" },
      { to: "/timesheet", label: "My Timesheet", permission: "my-team.my-timesheet.view" },
      {
        to: "/my-team/timesheets",
        label: "Timesheet Approval",
        permission: ["my-team.timesheet-approval.view", "my-team.timesheet-approval.approve"],
      },
    ],
  },
  {
    to: "/health",
    label: "Health & Governance",
    icon: Activity,
    permission: "projects.health.view",
  },
  {
    to: "/approvals",
    label: "Approvals",
    icon: CheckCircle2,
    permission: [
      "approvals.view",
      "my-team.timesheet-approval.approve",
      "my-team.timesheet-approval.view",
    ],
  },
  { to: "/wbs-allocation", label: "WBS Allocation", icon: Inbox, permission: "wbs.allocate" },
  { to: "/portfolio", label: "Portfolio", icon: Layers, permission: "portfolio.view" },
  { to: "/dh-settings", label: "Settings", icon: Settings, permission: "settings.view" },
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
  { to: "/dh-reports", label: "Reports", icon: BarChart3, permission: "reports.view" },
  {
    label: "Resources",
    icon: Users,
    permission: "resources.view",
    subItems: [
      { to: "/dh-employee-directory", label: "Directory & Pool" },
      { to: "/dh-exit-summary", label: "Exit Summary" },
    ],
  },
  { to: "/customers", label: "Customers", icon: Building2, permission: "customers.view" },
  { to: "/my-org", label: "Repository", icon: Building, permission: "repository.view" },
  {
    label: "My Team",
    icon: Users,
    permission: "my-team.dashboard.view",
    subItems: [
      { to: "/my-team/", label: "Team Dashboard" },
      {
        to: "/my-team/timesheets",
        label: "Timesheets",
        permission: "my-team.timesheet-approval.view",
      },
    ],
  },
  { to: "/dh-settings", label: "Settings", icon: Settings, permission: "settings.view" },
];

/**
 * Filters a nav registry to the items the user may see. An item with
 * sub-items is shown when at least one sub-item passes (or it passes on its
 * own); sub-items inherit the parent permission unless they declare their own.
 *
 * Role-driven replacements:
 * - Employee: the "My Team" folder is replaced by a direct "Timesheet" item —
 *   Employees never see the My Team module.
 * - HR: the single "Resources" item becomes the admin-style folder
 *   (Directory + Exit Summary) — HR manages the employee directory
 *   for onboarding (no resource pool).
 * - Employee / PM family / PMO family / Accounts / Sales: Resources opens the
 *   DH directory (view only, basic details).
 * - PM family + PMO family: Health & Governance / Approvals stay hidden
 *   (health lives inside each project; approvals live in Action Centre).
 */
export type NavRoleFlags = {
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
  const { isEmployee, isHr, isPmFamily, isPmoFamily, isAccounts, isSales } = flags;
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

  // Employee: hide the My Team folder, surface the Timesheet page directly.
  if (isEmployee) {
    const idx = result.findIndex((i) => i.label === "My Team");
    if (idx >= 0) {
      const myTeam = result[idx];
      const hasTimesheet = myTeam.subItems?.some((s) => s.to === "/timesheet");
      if (hasTimesheet) {
        result[idx] = {
          to: "/timesheet",
          label: "Timesheet",
          icon: Clock,
          permission: undefined,
        };
      }
    }
  }

  // HR: Resources becomes the admin-style directory folder.
  if (isHr) {
    const idx = result.findIndex((i) => i.label === "Resources");
    if (idx >= 0) {
      result[idx] = {
        label: "Resources",
        icon: Users,
        permission: undefined,
        subItems: [
          { to: "/dh-employee-directory", label: "Directory", permission: "resources.view" },
          { to: "/dh-exit-summary", label: "Exit Summary", permission: "resources.view" },
        ],
      };
    }
  }

  const useDhDirectory = isEmployee || isPmFamily || isPmoFamily || isAccounts || isSales;
  if (useDhDirectory && !isHr) {
    const idx = result.findIndex((i) => i.label === "Resources");
    if (idx >= 0) {
      result[idx] = {
        to: "/dh-employee-directory",
        label: "Resources",
        icon: Users,
        permission: undefined,
      };
    }
  }

  if (isPmoFamily) {
    const idx = result.findIndex((i) => i.label === "My Team");
    if (idx >= 0) {
      result[idx] = {
        ...result[idx],
        subItems: [{ to: "/my-team/", label: "Team Dashboard" }],
      };
    }
  }

  if (isAccounts || isSales) {
    const idx = result.findIndex((i) => i.label === "Reports");
    if (idx >= 0) {
      result[idx] = { ...result[idx], to: "/dh-reports" };
    }
  }

  const hideStandalone = isPmFamily || isPmoFamily || isAccounts || isSales;
  if (hideStandalone) {
    return result.filter(
      (i) =>
        i.label !== "Health & Governance" &&
        i.label !== "Approvals" &&
        i.label !== "WBS Allocation" &&
        i.label !== "Portfolio" &&
        i.label !== "Settings",
    );
  }

  return result;
}

// ─── Route guard map ─────────────────────────────────────────────────────────
// Longest matching prefix wins. `permission: null` = always allowed (any
// authenticated user). Every route that renders app content must be listed so
// direct URL access is blocked for users without the permission.
export const ROUTE_PERMISSIONS: { prefix: string; permission: string | string[] | null }[] = [
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
    permission: ["my-team.timesheet-approval.view", "my-team.my-timesheet.view"],
  },
  { prefix: "/my-team", permission: "my-team.dashboard.view" },
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
