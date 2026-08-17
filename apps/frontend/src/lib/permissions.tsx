import { createContext, useContext, useMemo, type ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";

/**
 * Central permission mechanism (frontend half of RBAC).
 *
 * The permission set always comes from the backend — the JWT `permission`
 * claims and `GET /api/v1/auth/me` — never from role names. Use
 * `hasPermission("projects.team.assign")` everywhere; the backend enforces the
 * same keys and returns 403 when a user tries something they cannot do.
 */
interface PermissionsContextValue {
  /** Effective permission keys for the signed-in user (e.g. "projects.team.assign"). */
  permissions: string[];
  /** True when the user holds the exact permission key. */
  hasPermission: (key: string) => boolean;
  /** True when the user holds ANY of the given keys (null/undefined entries are ignored). */
  hasAny: (...keys: Array<string | undefined | null>) => boolean;
  /** True when the user holds ALL of the given keys. */
  hasAll: (...keys: Array<string | undefined | null>) => boolean;
}

const PermissionsContext = createContext<PermissionsContextValue | null>(null);

export function PermissionProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();

  const value = useMemo<PermissionsContextValue>(() => {
    const permissions = user?.permissions ?? [];
    const set = new Set(permissions);
    return {
      permissions,
      hasPermission: (key: string) => set.has(key),
      hasAny: (...keys) => keys.some((k) => !!k && set.has(k)),
      hasAll: (...keys) => keys.every((k) => !k || set.has(k)),
    };
  }, [user?.permissions]);

  return <PermissionsContext.Provider value={value}>{children}</PermissionsContext.Provider>;
}

export function usePermissions(): PermissionsContextValue {
  const ctx = useContext(PermissionsContext);
  if (!ctx) throw new Error("usePermissions must be used inside PermissionProvider");
  return ctx;
}
