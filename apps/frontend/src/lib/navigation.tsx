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

// ─── Standard workspace navigation ──────────────────────────────────────────
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
  { to: "/repository", label: "Repository", icon: Building, permission: "repository.view" },
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
        to: "/settings-security-roles",
        label: "Roles & Permissions",
        permission: "settings.view",
      },
      { to: "/settings-masters", label: "Masters", permission: "settings.view" },
    ],
  },
];

// ─── Super-Admin workspace navigation ───────────────────────────────────────
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
      { to: "/employee-directory", label: "Employee Directory" },
      { to: "/exit-summary", label: "Exit Summary" },
    ],
  },
  { to: "/customers", label: "Customers", icon: Building2, permission: "customers.view" },
  { to: "/repository", label: "Repository", icon: Building, permission: "repository.view" },
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
      { to: "/settings-security-roles", label: "Roles & Permissions" },
      { to: "/settings-masters", label: "Masters" },
    ],
  },
];

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
  const { isAdmin, isItAdmin, isEmployee, isHr, isPmFamily, isPmoFamily, isAccounts, isSales } = flags;

  // Admin has super-admin visibility into every module and submodule
  if (isAdmin) {
    return items.map((item) => ({
      ...item,
      permission: undefined,
      subItems: item.subItems?.map((s) => ({ ...s, permission: undefined })),
    }));
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

  // HR & IT Admin: Resources becomes the directory & exit summary folder.
  if (isHr || isItAdmin) {
    const idx = result.findIndex((i) => i.label === "Resources");
    if (idx >= 0) {
      result[idx] = {
        label: "Resources",
        icon: Users,
        permission: undefined,
        subItems: [
          { to: "/employee-directory", label: "Employee Directory", permission: "resources.view" },
          { to: "/exit-summary", label: "Exit Summary", permission: "resources.view" },
        ],
      };
    }
  }

  const useDirectory = isEmployee || isPmFamily || isPmoFamily || isAccounts || isSales;
  if (useDirectory && !isHr && !isItAdmin) {
    const idx = result.findIndex((i) => i.label === "Resources");
    if (idx >= 0) {
      result[idx] = {
        to: "/employee-directory",
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
        subItems: [
          { to: "/my-team/", label: "Team Dashboard" },
          {
            to: "/my-team/timesheets",
            label: "Timesheet Approval",
            permission: undefined,
          },
        ],
      };
    }
  }

  const hideStandalone = isPmFamily || isPmoFamily || isAccounts || isSales;
  if (hideStandalone) {
    return result.filter((i) => i.label !== "Settings");
  }

  return result;
}

// ─── Route guard map ─────────────────────────────────────────────────────────
export const ROUTE_PERMISSIONS: { prefix: string; permission: string | string[] | null }[] = [
  { prefix: "/settings-masters", permission: "settings.view" },
  { prefix: "/settings-security-roles", permission: ["settings.manage_roles", "roles:manage", "settings.view"] },
  { prefix: "/settings", permission: "settings.view" },
  { prefix: "/action-centre", permission: "action-center.view" },
  { prefix: "/projects/new", permission: "projects.create" },
  { prefix: "/projects", permission: "projects.view" },
  { prefix: "/customers", permission: "customers.view" },
  { prefix: "/exit-summary", permission: "resources.view" },
  { prefix: "/employee-directory", permission: "resources.view" },
  { prefix: "/resources", permission: "resources.view" },
  { prefix: "/repository", permission: "repository.view" },
  { prefix: "/my-team/timesheets", permission: null },
  { prefix: "/my-team", permission: null },
  { prefix: "/health", permission: "projects.health.view" },
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
