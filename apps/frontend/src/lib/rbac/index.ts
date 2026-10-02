export * from "./excel-baseline";
export * from "./widget-permissions";
export * from "./catalog";
export * from "./matrix";

import type { Role } from "@/lib/mock-data";
import type { PermissionKey } from "./catalog";
import { DEFAULT_ROLE_PERMISSIONS } from "./matrix";

export function hasPermission(granted: ReadonlySet<PermissionKey>, key: PermissionKey): boolean {
  return granted.has(key);
}

export function permissionsForRole(
  role: Role,
  overrides?: Partial<Record<Role, PermissionKey[]>>,
): PermissionKey[] {
  return overrides?.[role] ?? DEFAULT_ROLE_PERMISSIONS[role] ?? [];
}
