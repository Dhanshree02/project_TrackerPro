import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";
import { getDemoPersona } from "@/lib/user-personas";
import { fetchRoles, fetchRolePermissions, type ApiRolePermission } from "@/lib/api/users";
import { fetchSidebarModules, type SidebarTab } from "@/lib/api/catalogs";

interface PermissionsContextValue {
  permissions: ApiRolePermission[];
  canView: (codeOrId: string) => boolean;
  canManage: (codeOrId: string) => boolean;
  hasPermission: (key: string) => boolean;
  hasAny: (...keys: Array<string | undefined | null>) => boolean;
  hasAll: (...keys: Array<string | undefined | null>) => boolean;
  loading: boolean;
}

const PermissionsContext = createContext<PermissionsContextValue | null>(null);

export function PermissionProvider({ children }: { children: ReactNode }) {
  const { user, demoRole } = useAuth();
  const [rolePermissions, setRolePermissions] = useState<ApiRolePermission[]>([]);
  const [codeToId, setCodeToId] = useState<Record<string, string>>({});
  const [parentMap, setParentMap] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);

  // Load catalog to build code -> ID and child -> parent mappings
  useEffect(() => {
    fetchSidebarModules()
      .then((modules) => {
        const mapping: Record<string, string> = {};
        const parents: Record<string, string> = {};
        const registerItem = (code: string, id: string, parentId?: string, parentCode?: string) => {
          const lCode = code.toLowerCase();
          const lId = id.toLowerCase();
          mapping[lCode] = lId;
          if (parentId) {
            parents[lId] = parentId.toLowerCase();
          }
          if (parentCode) {
            parents[lCode] = parentCode.toLowerCase();
          }
        };

        const registerTab = (t: SidebarTab, parentId?: string, parentCode?: string) => {
          registerItem(t.code, t.id, parentId, parentCode);
          for (const child of t.children ?? []) {
            registerTab(child, t.id, t.code);
          }
        };

        const registerSubModule = (sub: SidebarSubModule, parentId?: string, parentCode?: string) => {
          registerItem(sub.code, sub.id, parentId, parentCode);
          for (const subChild of sub.children ?? []) {
            registerSubModule(subChild, sub.id, sub.code);
          }
          for (const tab of sub.tabs ?? []) {
            registerTab(tab, sub.id, sub.code);
          }
        };

        for (const mod of modules) {
          registerItem(mod.code, mod.id);
          for (const sub of mod.subModules ?? []) {
            registerSubModule(sub, mod.id, mod.code);
          }
          for (const w of mod.widgets ?? []) {
            registerItem(w.code, w.id, mod.id, mod.code);
          }
          for (const tab of mod.tabs ?? []) {
            registerTab(tab, mod.id, mod.code);
          }
        }
        setCodeToId(mapping);
        setParentMap(parents);
      })
      .catch(() => {});
  }, []);

  // Extract active role name robustly across employee codes and RBAC roles
  const activeRoleName = useMemo(() => {
    if (user?.role) return user.role.trim().toLowerCase();
    const persona = getDemoPersona(demoRole);
    return (persona?.roleKey || persona?.accessRole || demoRole || "").trim().toLowerCase();
  }, [user?.role, demoRole]);

  useEffect(() => {
    if (!activeRoleName) return;
    let cancelled = false;
    setLoading(true);

    fetchRoles()
      .then(async (roles) => {
        if (cancelled) return;
        const matchingRole = roles.find(
          (r) =>
            r.name.toLowerCase() === activeRoleName ||
            r.displayName.toLowerCase() === activeRoleName,
        );
        if (!matchingRole) {
          setRolePermissions([]);
          setLoading(false);
          return;
        }

        const perms = await fetchRolePermissions(matchingRole.id);
        if (!cancelled) {
          setRolePermissions(perms);
          setLoading(false);
        }
      })
      .catch(() => {
        if (!cancelled) setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [activeRoleName]);

  const permissionMap = useMemo(() => {
    const map = new Map<string, ApiRolePermission>();
    for (const p of rolePermissions) {
      map.set(p.itemId.toLowerCase(), p);
    }
    return map;
  }, [rolePermissions]);

  const canView = (codeOrId: string): boolean => {
    // Admin always has full access
    if (activeRoleName === "admin") return true;

    const lower = codeOrId.trim().toLowerCase();
    const itemId = (codeToId[lower] ?? lower).toLowerCase();

    // Check parent permission if item is a child
    const parent = parentMap[itemId] || parentMap[lower];
    if (parent && !canView(parent)) {
      return false;
    }

    const dashboardWidgets = new Set([
      "total-team-size",
      "resource-boarding-details",
      "team-utilization-onsite",
      "team-utilization-offsite",
      "team-utilization-onsite-projects",
      "team-allocation-onsite-offsite",
      "team-resignation-count",
      "team-capacity-offsite",
    ]);

    // If it's a dashboard widget and the dashboard module itself is turned off, forbid view
    if (dashboardWidgets.has(lower) && !canView("dashboard")) {
      return false;
    }

    // If permission record exists in auth.tbl_role_permissions, enforce its CanView flag
    const perm = permissionMap.get(itemId);
    if (perm !== undefined) {
      return perm.canView === 1;
    }

    // For modules strictly governed by auth.tbl_role_permissions: if not granted in DB, access is false
    const strictRbacItems = new Set(["dashboard", "repository", ...dashboardWidgets]);

    if (strictRbacItems.has(lower)) {
      return false;
    }

    // If item has a parent and no explicit permission was saved, inherit from parent
    if (parent) {
      return canView(parent);
    }

    // Default to true for items not yet configured/migrated
    return true;
  };

  const canManage = (codeOrId: string): boolean => {
    if (activeRoleName === "admin") return true;

    const lower = codeOrId.trim().toLowerCase();
    const itemId = (codeToId[lower] ?? lower).toLowerCase();

    // If item is a child, it cannot have manage access if its parent does not have manage access
    const parent = parentMap[itemId] || parentMap[lower];
    if (parent && !canManage(parent)) {
      return false;
    }

    const perm = permissionMap.get(itemId);
    if (perm !== undefined) {
      return perm.canManage === 1;
    }

    // If item has a parent and no explicit permission was saved, inherit parent's manage
    if (parent) {
      return canManage(parent);
    }

    return false;
  };

  const hasPermission = (key: string): boolean => {
    const cleaned = key.replace(/\.view$/, "").replace(/\.manage$/, "");
    return canView(cleaned);
  };

  const hasAny = (...keys: Array<string | undefined | null>): boolean => {
    const valid = keys.filter(Boolean) as string[];
    if (valid.length === 0) return true;
    return valid.some((k) => hasPermission(k));
  };

  const hasAll = (...keys: Array<string | undefined | null>): boolean => {
    const valid = keys.filter(Boolean) as string[];
    if (valid.length === 0) return true;
    return valid.every((k) => hasPermission(k));
  };

  const value = useMemo(
    () => ({
      permissions: rolePermissions,
      canView,
      canManage,
      hasPermission,
      hasAny,
      hasAll,
      loading,
    }),
    [rolePermissions, permissionMap, codeToId, parentMap, activeRoleName, loading],
  );

  return <PermissionsContext.Provider value={value}>{children}</PermissionsContext.Provider>;
}

export function usePermissions(): PermissionsContextValue {
  const ctx = useContext(PermissionsContext);
  if (!ctx) throw new Error("usePermissions must be used inside PermissionProvider");
  return ctx;
}
