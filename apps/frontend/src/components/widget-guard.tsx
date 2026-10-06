import { createContext, useContext, type ReactNode } from "react";
import { usePermissions } from "@/lib/permissions";
import { useRoleContext } from "@/lib/role-context";

interface WidgetPermissionContextValue {
  canView: boolean;
  canManage: boolean;
}

const WidgetPermissionContext = createContext<WidgetPermissionContextValue>({
  canView: true,
  canManage: true,
});

export function useWidgetPermission(): WidgetPermissionContextValue {
  return useContext(WidgetPermissionContext);
}

export interface WidgetGuardProps {
  /**
   * The base permission or view permission key.
   * If a single key is provided (e.g., "projects.overview"), it checks:
   * - View: key (or key + ":view")
   * - Manage: managePermission (or key + ":manage")
   */
  permission?: string;
  viewPermission?: string;
  managePermission?: string;
  /** Fallback rendered when canView = 0. Defaults to null (completely hidden). */
  fallback?: ReactNode;
  /**
   * Children can be standard ReactNode or a render function:
   * ({ canManage, canView }) => ReactNode
   */
  children: ReactNode | ((context: WidgetPermissionContextValue) => ReactNode);
}

/**
 * WidgetGuard enforces the 3-state RBAC behavior:
 * 1. CanView = 0 -> hides component (returns fallback / null)
 * 2. CanView = 1, CanManage = 0 -> renders read-only (canManage = false)
 * 3. CanView = 1, CanManage = 1 -> renders full management (canManage = true)
 */
export function WidgetGuard({
  permission,
  viewPermission,
  managePermission,
  fallback = null,
  children,
}: WidgetGuardProps) {
  const { hasPermission, hasAny } = usePermissions();
  const { isAdmin, isDhanshree } = useRoleContext();

  const isSuperAdmin = isAdmin || isDhanshree;

  const viewKey = viewPermission || (permission ? `${permission}:view` : "");
  const manageKey = managePermission || (permission ? `${permission}:manage` : "");

  // Evaluation:
  // If isSuperAdmin -> full access
  // Otherwise check exact view and manage keys
  const canView =
    isSuperAdmin ||
    (viewPermission ? hasPermission(viewPermission) : false) ||
    (permission ? hasAny(permission, `${permission}:view`) : true);

  // Invariant: CanManage = 1 always requires CanView = 1
  const canManage =
    canView &&
    (isSuperAdmin ||
      (managePermission ? hasPermission(managePermission) : false) ||
      (permission ? hasPermission(`${permission}:manage`) : false));

  // State 1: No Access -> completely hidden
  if (!canView) {
    return <>{fallback}</>;
  }

  const contextValue: WidgetPermissionContextValue = {
    canView: true,
    canManage,
  };

  return (
    <WidgetPermissionContext.Provider value={contextValue}>
      {typeof children === "function" ? children(contextValue) : children}
    </WidgetPermissionContext.Provider>
  );
}
