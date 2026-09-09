export {
  APP_ROLES,
  ROLE_LABELS,
  PERMISSION_CATALOG,
  MODULE_ORDER,
  ROLE_PROJECT_SCOPE,
  PERMISSION_ALIASES,
  type AppRole,
  type PermissionKey,
  type ProjectScope,
  type PermissionCatalogItem,
} from "./catalog";

export { DEFAULT_ROLE_PERMISSIONS, RBAC_STORAGE_KEY } from "./matrix";

import type { Role } from "@/lib/mock-data";
import type { PermissionKey } from "./catalog";
import { PERMISSION_ALIASES } from "./catalog";
import { DEFAULT_ROLE_PERMISSIONS, RBAC_STORAGE_KEY } from "./matrix";

export function resolvePermissionAliases(key: string): string[] {
  return PERMISSION_ALIASES[key] ?? [key];
}

export function hasPermission(granted: ReadonlySet<string>, key: string): boolean {
  if (granted.has(key)) return true;
  const aliases = resolvePermissionAliases(key);
  return aliases.some((a) => granted.has(a));
}

export function permissionsForRole(
  role: Role,
  overrides?: Partial<Record<Role, PermissionKey[]>>,
): PermissionKey[] {
  if (overrides && overrides[role]) return overrides[role]!;
  if (typeof window !== "undefined") {
    try {
      const raw = window.localStorage.getItem(RBAC_STORAGE_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (parsed && parsed[role]) return parsed[role];
      }
    } catch {
      /* ignore */
    }
  }
  return DEFAULT_ROLE_PERMISSIONS[role] ?? [];
}
