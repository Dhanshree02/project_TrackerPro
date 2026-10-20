import { createContext, useContext, useMemo, type ReactNode } from "react";

/**
 * Permission checks are cleared until Roles & Permissions is rebuilt.
 * Every signed-in screen stays available.
 */
interface PermissionsContextValue {
  permissions: string[];
  hasPermission: (key: string) => boolean;
  hasAny: (...keys: Array<string | undefined | null>) => boolean;
  hasAll: (...keys: Array<string | undefined | null>) => boolean;
}

const PermissionsContext = createContext<PermissionsContextValue | null>(null);

const allowAll: PermissionsContextValue = {
  permissions: [],
  hasPermission: () => true,
  hasAny: () => true,
  hasAll: () => true,
};

export function PermissionProvider({ children }: { children: ReactNode }) {
  const value = useMemo(() => allowAll, []);
  return <PermissionsContext.Provider value={value}>{children}</PermissionsContext.Provider>;
}

export function usePermissions(): PermissionsContextValue {
  const ctx = useContext(PermissionsContext);
  if (!ctx) throw new Error("usePermissions must be used inside PermissionProvider");
  return ctx;
}
