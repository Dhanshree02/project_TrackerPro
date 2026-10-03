import React, { createContext, useContext, useEffect, useState, useMemo, useCallback } from "react";
import { useAuth } from "@/lib/auth-context";
import { getBaselinePermissionsForRole, type WidgetPermissionValue } from "@/lib/rbac/excel-baseline";
import { getEffectiveRoleWidgetMap, PERMISSIONS_CHANGED_EVENT } from "@/lib/rbac/permissions-sync";
import { fetchMyWidgetPermissions } from "@/lib/api/rbac";

export interface WidgetAccessState {
  canView: boolean;
  canManage: boolean;
  isHidden: boolean;
}

interface WidgetPermissionsContextValue {
  role: string;
  isSuperAdmin: boolean;
  getWidgetPermission: (widgetKey: string) => { canView: boolean; canManage: boolean };
  canView: (widgetKey: string) => boolean;
  canManage: (widgetKey: string) => boolean;
  refresh: () => Promise<void>;
}

const WidgetPermissionsContext = createContext<WidgetPermissionsContextValue | null>(null);

export function WidgetPermissionsProvider({ children }: { children: React.ReactNode }) {
  const { user: authUser, demoRole } = useAuth();
  const currentRole = authUser?.role || demoRole || "Admin";

  const isSuperAdmin = useMemo(() => {
    const r = (currentRole || "").trim().toLowerCase();
    return r === "admin" || r === "dhanshree";
  }, [currentRole]);

  // Initial effective permissions (checks custom overrides in localStorage, then Excel baseline)
  const initialMap = useMemo(() => {
    const base = getEffectiveRoleWidgetMap(currentRole);
    const map: Record<string, { canView: boolean; canManage: boolean }> = {};
    for (const [key, val] of Object.entries(base)) {
      map[key] = {
        canView: isSuperAdmin ? true : val.canView === 1,
        canManage: isSuperAdmin ? true : (val.canManage === 1 && val.canView === 1),
      };
    }
    return map;
  }, [currentRole, isSuperAdmin]);

  const [permissionsMap, setPermissionsMap] = useState<Record<string, { canView: boolean; canManage: boolean }>>(initialMap);

  // Sync with initialMap immediately on role change
  useEffect(() => {
    setPermissionsMap(initialMap);
  }, [initialMap]);

  // Listen to live permission changes saved by Admin in Settings
  useEffect(() => {
    const handlePermsChange = (e: Event) => {
      const detail = (e as CustomEvent).detail;
      if (!detail || !detail.roleName || detail.roleName.toLowerCase() === currentRole.toLowerCase()) {
        const base = getEffectiveRoleWidgetMap(currentRole);
        const map: Record<string, { canView: boolean; canManage: boolean }> = {};
        for (const [key, val] of Object.entries(base)) {
          map[key] = {
            canView: isSuperAdmin ? true : val.canView === 1,
            canManage: isSuperAdmin ? true : (val.canManage === 1 && val.canView === 1),
          };
        }
        setPermissionsMap(map);
      }
    };
    window.addEventListener(PERMISSIONS_CHANGED_EVENT, handlePermsChange);
    return () => window.removeEventListener(PERMISSIONS_CHANGED_EVENT, handlePermsChange);
  }, [currentRole, isSuperAdmin]);

  // Background sync with API for database-saved customizations
  const refresh = useCallback(async () => {
    try {
      const serverPerms = await fetchMyWidgetPermissions(currentRole);
      if (serverPerms && Object.keys(serverPerms).length > 0) {
        const updated: Record<string, { canView: boolean; canManage: boolean }> = {};
        for (const [key, val] of Object.entries(serverPerms)) {
          updated[key] = {
            canView: isSuperAdmin ? true : val.canView === 1,
            canManage: isSuperAdmin ? true : (val.canManage === 1 && val.canView === 1),
          };
        }
        setPermissionsMap(updated);
      }
    } catch {
      // Fallback already active from effective local/Excel map
    }
  }, [currentRole, isSuperAdmin]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const getWidgetPermission = useCallback((widgetKey: string) => {
    if (isSuperAdmin) {
      return { canView: true, canManage: true };
    }
    const perm = permissionsMap[widgetKey];
    if (!perm) {
      // Check effective map
      const base = getEffectiveRoleWidgetMap(currentRole)[widgetKey];
      return {
        canView: base?.canView === 1,
        canManage: base?.canManage === 1 && base?.canView === 1,
      };
    }
    return perm;
  }, [isSuperAdmin, permissionsMap, currentRole]);

  const canView = useCallback((widgetKey: string) => {
    return getWidgetPermission(widgetKey).canView;
  }, [getWidgetPermission]);

  const canManage = useCallback((widgetKey: string) => {
    return getWidgetPermission(widgetKey).canManage;
  }, [getWidgetPermission]);

  const value = useMemo(() => ({
    role: currentRole,
    isSuperAdmin,
    getWidgetPermission,
    canView,
    canManage,
    refresh,
  }), [currentRole, isSuperAdmin, getWidgetPermission, canView, canManage, refresh]);

  return (
    <WidgetPermissionsContext.Provider value={value}>
      {children}
    </WidgetPermissionsContext.Provider>
  );
}

export function useWidgetPermissions(): WidgetPermissionsContextValue {
  const ctx = useContext(WidgetPermissionsContext);
  if (!ctx) {
    // Graceful fallback outside provider
    return {
      role: "Admin",
      isSuperAdmin: true,
      getWidgetPermission: () => ({ canView: true, canManage: true }),
      canView: () => true,
      canManage: () => true,
      refresh: async () => {},
    };
  }
  return ctx;
}

export function useWidgetAccess(widgetKey: string): WidgetAccessState {
  const { getWidgetPermission } = useWidgetPermissions();
  const perm = getWidgetPermission(widgetKey);
  return {
    canView: perm.canView,
    canManage: perm.canManage,
    isHidden: !perm.canView,
  };
}

export interface WidgetGuardProps {
  widgetKey: string;
  fallback?: React.ReactNode;
  children: React.ReactNode | ((perms: { canManage: boolean }) => React.ReactNode);
}

export function WidgetGuard({ widgetKey, fallback = null, children }: WidgetGuardProps) {
  const { canView, canManage, isHidden } = useWidgetAccess(widgetKey);

  if (isHidden || !canView) {
    return <>{fallback}</>;
  }

  if (typeof children === "function") {
    return <>{children({ canManage })}</>;
  }

  return <>{children}</>;
}
