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
  code?: string;
  to?: string;
  label: string;
  search?: Record<string, unknown>;
  /** Required permission(s); undefined = inherited from the parent item. */
  permission?: string | string[];
  /** Deeper rows from mst_submodules whose parent is this submodule. */
  subItems?: NavSubItem[];
}

export interface NavItem {
  code?: string;
  to?: string;
  label: string;
  icon: LucideIcon;
  exact?: boolean;
  /** Required permission(s) for this item (parent level). */
  permission?: string | string[];
  subItems?: NavSubItem[];
}

/** Sidebar labels and routes. Roles & Permissions reads the same catalog from the database. */
export const NAV_ITEMS: NavItem[] = [
  { code: "dashboard", to: "/", label: "Dashboard", icon: LayoutDashboard, exact: true, permission: "dashboard.view" },
  { code: "action-centre", to: "/action-centre", label: "Action Center", icon: ListChecks, permission: "action-center.view" },
  { code: "projects", to: "/projects", label: "Projects", icon: FolderKanban, permission: "projects.view" },
  {
    code: "resources",
    label: "Resources",
    icon: Users,
    permission: "resources.view",
    subItems: [
      { code: "employee-directory", to: "/employee-directory", label: "Employee Directory" },
      { code: "exit-summary", to: "/exit-summary", label: "Exit Summary" },
    ],
  },
  { code: "customers", to: "/customers", label: "Customer", icon: Building2, permission: "customers.view" },
  { code: "repository", to: "/repository", label: "Repository", icon: Building, permission: "repository.view" },
  {
    code: "my-team",
    label: "My Team",
    icon: Users,
    subItems: [
      { code: "team-dashboard", to: "/my-team/", label: "Team Dashboard" },
      { code: "timesheets", to: "/my-team/timesheets", label: "Timesheets" },
    ],
  },
  {
    code: "settings",
    label: "Settings",
    icon: Settings,
    permission: "settings.view",
    subItems: [
      { code: "roles-permissions", to: "/settings-security-roles", label: "Roles & Permissions" },
      { code: "master", to: "/settings-masters", label: "Master" },
    ],
  },
];

export function firstNavRoute(items: NavItem[]): string | undefined {
  for (const item of items) {
    if (item.to) return item.to;
    const nested = firstSubRoute(item.subItems);
    if (nested) return nested;
  }
  return undefined;
}

function firstSubRoute(subs: NavSubItem[] | undefined): string | undefined {
  for (const sub of subs ?? []) {
    if (sub.to) return sub.to;
    const nested = firstSubRoute(sub.subItems);
    if (nested) return nested;
  }
  return undefined;
}

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

function clearSubPermissions(subs: NavSubItem[] | undefined): NavSubItem[] | undefined {
  return subs?.map((sub) => ({
    ...sub,
    permission: undefined,
    subItems: clearSubPermissions(sub.subItems),
  }));
}

function filterSubItems(
  subs: NavSubItem[],
  parentAllowed: boolean,
  allowed: (perm?: string | string[]) => boolean,
): NavSubItem[] {
  const kept: NavSubItem[] = [];
  for (const sub of subs) {
    const selfAllowed = parentAllowed && allowed(sub.permission);
    const children = sub.subItems?.length ? filterSubItems(sub.subItems, selfAllowed, allowed) : [];
    if (!selfAllowed && children.length === 0) continue;
    kept.push({
      ...sub,
      permission: undefined,
      subItems: children.length ? children : undefined,
    });
  }
  return kept;
}

export function filterNavItems(
  items: NavItem[],
  hasPermission: (key: string) => boolean,
  hasAny: (...keys: Array<string | undefined | null>) => boolean,
  flags: NavRoleFlags = {},
): NavItem[] {
  const { isAdmin, isPmFamily, isPmoFamily, isAccounts, isSales } = flags;

  // Admin has super-admin visibility into every module and submodule
  if (isAdmin) {
    return items.map((item) => ({
      ...item,
      permission: undefined,
      subItems: clearSubPermissions(item.subItems),
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
      const subs = filterSubItems(item.subItems, parentAllowed, allowed);
      if (subs.length > 0) result.push({ ...item, permission: undefined, subItems: subs });
      continue;
    }

    if (parentAllowed) result.push({ ...item, permission: undefined });
  }

  const hideStandalone = isPmFamily || isPmoFamily || isAccounts || isSales;
  if (hideStandalone) {
    return result.filter((i) => i.code !== "settings");
  }

  return result;
}

// ─── Route guard map ─────────────────────────────────────────────────────────
export const ROUTE_PERMISSIONS: { prefix: string; permission: string | string[] | null }[] = [
  { prefix: "/settings-masters", permission: "settings.view" },
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
