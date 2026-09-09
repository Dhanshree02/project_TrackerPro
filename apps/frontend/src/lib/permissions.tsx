import { createContext, useContext, useMemo, type ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";
import { resolvePermissionAliases } from "@/lib/rbac";

/**
 * Central permission mechanism (frontend core of RBAC).
 *
 * All module, submodule, widget, and action permissions are dynamically verified.
 * The permission set comes from the backend / JWT `permission` claims and live role configurations.
 */
export interface PermissionsContextValue {
  /** Effective permission keys for the active user/role. */
  permissions: string[];
  /** True when the user holds super-admin privilege (Admin / Dhanshree). */
  isSuperAdmin: boolean;
  /** True when the user holds the given permission key (or any recognized alias). */
  hasPermission: (key: string) => boolean;
  /** True when the user holds ANY of the given keys (null/undefined entries ignored). */
  hasAny: (...keys: Array<string | undefined | null>) => boolean;
  /** True when the user holds ALL of the given keys. */
  hasAll: (...keys: Array<string | undefined | null>) => boolean;
}

const PermissionsContext = createContext<PermissionsContextValue | null>(null);

export function PermissionProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();

  const value = useMemo<PermissionsContextValue>(() => {
    const rawRole = (user?.role ?? "").toLowerCase();
    const isSuperAdmin = rawRole === "admin" || rawRole === "dhanshree";
    const rawPerms = user?.permissions ?? [];

    const set = new Set<string>();
    for (const p of rawPerms) {
      set.add(p);
      const aliases = resolvePermissionAliases(p);
      for (const a of aliases) {
        set.add(a);
      }
    }

    const checkSingle = (key: string): boolean => {
      if (isSuperAdmin) return true;
      if (set.has(key)) return true;
      const aliases = resolvePermissionAliases(key);
      return aliases.some((a) => set.has(a));
    };

    return {
      permissions: Array.from(set),
      isSuperAdmin,
      hasPermission: (key: string) => checkSingle(key),
      hasAny: (...keys: Array<string | undefined | null>) => {
        if (isSuperAdmin) return true;
        const valid = keys.filter((k): k is string => Boolean(k));
        if (valid.length === 0) return true;
        return valid.some((k) => checkSingle(k));
      },
      hasAll: (...keys: Array<string | undefined | null>) => {
        if (isSuperAdmin) return true;
        const valid = keys.filter((k): k is string => Boolean(k));
        if (valid.length === 0) return true;
        return valid.every((k) => checkSingle(k));
      },
    };
  }, [user?.role, user?.permissions]);

  return <PermissionsContext.Provider value={value}>{children}</PermissionsContext.Provider>;
}

export function usePermissions(): PermissionsContextValue {
  const ctx = useContext(PermissionsContext);
  if (!ctx) throw new Error("usePermissions must be used inside PermissionProvider");
  return ctx;
}

export interface AuthorizeProps {
  permission?: string;
  anyOf?: string[];
  allOf?: string[];
  fallback?: ReactNode;
  children: ReactNode;
}

/**
 * Declarative component-level authorization wrapper.
 * Conditionally renders children only if the active role possesses the required permission(s).
 */
export function Authorize({
  permission,
  anyOf,
  allOf,
  fallback = null,
  children,
}: AuthorizeProps) {
  const { hasPermission, hasAny, hasAll } = usePermissions();

  if (permission && !hasPermission(permission)) {
    return <>{fallback}</>;
  }

  if (anyOf && anyOf.length > 0 && !hasAny(...anyOf)) {
    return <>{fallback}</>;
  }

  if (allOf && allOf.length > 0 && !hasAll(...allOf)) {
    return <>{fallback}</>;
  }

  return <>{children}</>;
}
