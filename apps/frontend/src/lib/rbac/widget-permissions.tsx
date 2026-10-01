import { createContext, useContext, useEffect, useMemo, useState, type ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";
import { fetchMyWidgetPermissions } from "@/lib/api/rbac";

export interface WidgetAccessState {
  canView: boolean;
  canManage: boolean;
}

export interface WidgetPermissionsContextValue {
  permissionsMap: Record<string, { v: number; m: number }>;
  isLoading: boolean;
  canView: (widgetKey: string) => boolean;
  canManage: (widgetKey: string) => boolean;
  canViewModule: (moduleKey: string) => boolean;
  canManageModule: (moduleKey: string) => boolean;
  canViewSubmodule: (submodulePrefix: string) => boolean;
  refreshPermissions: (overrideRole?: string) => Promise<void>;
}

const WidgetPermissionsContext = createContext<WidgetPermissionsContextValue | null>(null);

const SUPER_ADMIN_ROLES = new Set(["admin", "ceo", "coo", "dhanshree"]);

export const CANONICAL_ROLE_ALIASES: Record<string, string> = {
  employee: "Testing-Team Member",
  pm: "Testing-Manager",
  senior_pm: "Consulting-Senior Manager",
  pmo: "PMO",
  hr: "HR",
  sales: "Sales Manager",
  sales_bd: "Sales Manager",
  accounts: "Accounts",
  accounts_finance: "Accounts",
  hod: "Testing HOD",
  business_owner: "CEO",
  dhanshree: "COO",
};

export function WidgetPermissionsProvider({ children }: { children: ReactNode }) {
  const { user, demoRole } = useAuth();
  const [permissionsMap, setPermissionsMap] = useState<Record<string, { v: number; m: number }>>({});
  const [isLoading, setIsLoading] = useState(true);

  const effectiveRole = useMemo(() => {
    const raw = user?.role || demoRole || "";
    return CANONICAL_ROLE_ALIASES[raw.toLowerCase()] || raw;
  }, [user?.role, demoRole]);

  const isSuperAdmin = useMemo(() => {
    const roleLower = effectiveRole.toLowerCase();
    return SUPER_ADMIN_ROLES.has(roleLower);
  }, [effectiveRole]);

  const loadPermissions = async (overrideRole?: string) => {
    const raw = overrideRole || user?.role || demoRole;
    const targetRole = raw ? (CANONICAL_ROLE_ALIASES[raw.toLowerCase()] || raw) : undefined;
    if (!targetRole && !user) {
      setPermissionsMap({});
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    try {
      const map = await fetchMyWidgetPermissions({
        roleId: user?.roleId,
        role: targetRole,
      });
      setPermissionsMap(map);
    } catch (err) {
      console.warn("Could not fetch widget permissions map:", err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadPermissions();
  }, [user?.id, user?.role, user?.roleId, demoRole]);

  // Listen for broadcasted permission updates (e.g. from Settings save)
  useEffect(() => {
    const handler = (e: Event) => {
      const customEvt = e as CustomEvent<{ role?: string }>;
      const updatedRole = customEvt.detail?.role;
      if (!updatedRole || updatedRole.toLowerCase() === effectiveRole.toLowerCase()) {
        loadPermissions(effectiveRole);
      }
    };
    window.addEventListener("rbac-permissions-updated", handler);
    return () => window.removeEventListener("rbac-permissions-updated", handler);
  }, [effectiveRole]);

  const value = useMemo<WidgetPermissionsContextValue>(() => {
    return {
      permissionsMap,
      isLoading,
      canView: (widgetKey: string) => {
        if (isSuperAdmin) return true;
        const norm = widgetKey.toLowerCase().trim();
        const entry = permissionsMap[norm];
        if (entry) return entry.v === 1;
        const clean = norm.replace(/[-_]/g, "");
        for (const [k, val] of Object.entries(permissionsMap)) {
          if (k.toLowerCase().replace(/[-_]/g, "") === clean) {
            return val.v === 1;
          }
        }
        return false;
      },
      canManage: (widgetKey: string) => {
        if (isSuperAdmin) return true;
        const norm = widgetKey.toLowerCase().trim();
        const entry = permissionsMap[norm];
        if (entry) return entry.m === 1;
        const clean = norm.replace(/[-_]/g, "");
        for (const [k, val] of Object.entries(permissionsMap)) {
          if (k.toLowerCase().replace(/[-_]/g, "") === clean) {
            return val.m === 1;
          }
        }
        return false;
      },
      canViewModule: (moduleKey: string) => {
        if (isSuperAdmin) return true;
        const cleanKey = moduleKey.toLowerCase().replace(/[-_]/g, "");
        const aliases = [cleanKey];
        if (cleanKey === "resource") aliases.push("resources");
        if (cleanKey === "resources") aliases.push("resource");
        if (cleanKey === "actioncenter") aliases.push("actioncenter", "action_center");
        if (cleanKey === "myteam") aliases.push("myteam", "my_team");
        return Object.entries(permissionsMap).some(([k, val]) => {
          const normK = k.toLowerCase().replace(/[-_]/g, "");
          return aliases.some((a) => normK.startsWith(a)) && val.v === 1;
        });
      },
      canManageModule: (moduleKey: string) => {
        if (isSuperAdmin) return true;
        const cleanKey = moduleKey.toLowerCase().replace(/[-_]/g, "");
        const aliases = [cleanKey];
        if (cleanKey === "resource") aliases.push("resources");
        if (cleanKey === "resources") aliases.push("resource");
        if (cleanKey === "actioncenter") aliases.push("actioncenter", "action_center");
        if (cleanKey === "myteam") aliases.push("myteam", "my_team");
        return Object.entries(permissionsMap).some(([k, val]) => {
          const normK = k.toLowerCase().replace(/[-_]/g, "");
          return aliases.some((a) => normK.startsWith(a)) && val.m === 1;
        });
      },
      canViewSubmodule: (submodulePrefix: string) => {
        if (isSuperAdmin) return true;
        const clean = submodulePrefix.toLowerCase().replace(/[-_]/g, "");
        return Object.entries(permissionsMap).some(([k, val]) => {
          const normK = k.toLowerCase().replace(/[-_]/g, "");
          return normK.startsWith(clean) && val.v === 1;
        });
      },
      refreshPermissions: loadPermissions,
    };
  }, [permissionsMap, isLoading, isSuperAdmin, effectiveRole]);

  return (
    <WidgetPermissionsContext.Provider value={value}>
      {children}
    </WidgetPermissionsContext.Provider>
  );
}

export function useWidgetPermissions(): WidgetPermissionsContextValue {
  const ctx = useContext(WidgetPermissionsContext);
  if (!ctx) {
    // Graceful fallback when outside provider
    return {
      permissionsMap: {},
      isLoading: false,
      canView: () => true,
      canManage: () => true,
      canViewModule: () => true,
      canManageModule: () => true,
      canViewSubmodule: () => true,
      refreshPermissions: async () => {},
    };
  }
  return ctx;
}

export function useWidgetAccess(widgetKey: string): WidgetAccessState & { isLoading: boolean } {
  const { canView, canManage, isLoading } = useWidgetPermissions();
  return {
    canView: canView(widgetKey),
    canManage: canManage(widgetKey),
    isLoading,
  };
}

interface WidgetGuardProps {
  widgetKey: string;
  action?: "view" | "manage";
  children: ReactNode;
  fallback?: ReactNode;
}

export function WidgetGuard({
  widgetKey,
  action = "view",
  children,
  fallback = null,
}: WidgetGuardProps) {
  const { canView, canManage, isLoading } = useWidgetPermissions();

  if (isLoading) {
    return null;
  }

  const allowed = action === "manage" ? canManage(widgetKey) : canView(widgetKey);
  if (!allowed) {
    return <>{fallback}</>;
  }

  return <>{children}</>;
}
