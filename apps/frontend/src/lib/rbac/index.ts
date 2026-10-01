export {
  APP_ROLES,
  ROLE_LABELS,
  PERMISSION_CATALOG,
  MODULE_ORDER,
  ROLE_PROJECT_SCOPE,
  type AppRole,
  type PermissionKey,
  type ProjectScope,
} from "./catalog";

export { DEFAULT_ROLE_PERMISSIONS, RBAC_STORAGE_KEY } from "./matrix";

export {
  EXCEL_PAGE_DEFINITIONS,
  EXCEL_ROLE_BASELINES,
  BASELINE_STORAGE_KEY,
  mapRoleToExcelRole,
  getBaselineAccessForRole,
  getRoleCurrentAccess,
  saveRoleAccess,
  resetRoleToBaseline,
  resetRoleToBaseline as resetRoleToExcelBaseline,
  hasCustomOverrides,
  isPageVisibleForRole,
  type AccessLevel,
  type ExcelPageDefinition,
} from "./excel-baseline";

export {
  WidgetPermissionsProvider,
  useWidgetPermissions,
  useWidgetAccess,
  WidgetGuard,
  CANONICAL_ROLE_ALIASES,
  type WidgetAccessState,
} from "./widget-permissions";

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
