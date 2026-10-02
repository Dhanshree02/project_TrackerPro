import { apiFetch } from "@/lib/api-client";

export interface WidgetCatalogItemDto {
  id: string;
  code: string;
  name: string;
  widgetKey: string;
  widgetType: string;
  hasManageAction: boolean;
  sortOrder: number;
  canView: number;
  canManage: number;
}

export interface SubmoduleCatalogItemDto {
  id: string;
  code: string;
  name: string;
  routePrefix: string | null;
  sortOrder: number;
  widgets: WidgetCatalogItemDto[];
  childSubmodules: SubmoduleCatalogItemDto[];
}

export interface ModuleCatalogItemDto {
  id: string;
  code: string;
  name: string;
  icon: string | null;
  sortOrder: number;
  submodules: SubmoduleCatalogItemDto[];
  directWidgets: WidgetCatalogItemDto[];
}

export interface RoleWidgetPermissionDto {
  roleId: string;
  roleName: string;
  widgetId: string;
  widgetKey: string;
  widgetName: string;
  canView: number;
  canManage: number;
}

export async function fetchRbacCatalogTree(roleId?: string): Promise<ModuleCatalogItemDto[]> {
  const query = roleId ? `?roleId=${encodeURIComponent(roleId)}` : "";
  return await apiFetch<ModuleCatalogItemDto[]>(`/api/v1/rbac/catalog-tree${query}`);
}

export async function fetchMyWidgetPermissions(role?: string): Promise<Record<string, { canView: number; canManage: number }>> {
  const query = role ? `?role=${encodeURIComponent(role)}` : "";
  return await apiFetch<Record<string, { canView: number; canManage: number }>>(`/api/v1/rbac/permissions/my${query}`);
}

export async function fetchRoleWidgetPermissions(roleId: string): Promise<RoleWidgetPermissionDto[]> {
  return await apiFetch<RoleWidgetPermissionDto[]>(`/api/v1/rbac/roles/${roleId}/permissions`);
}

export async function updateRoleWidgetPermissions(
  roleId: string,
  permissions: { widgetId: string; canView: number; canManage: number }[]
): Promise<{ message: string }> {
  return await apiFetch<{ message: string }>(`/api/v1/rbac/roles/${roleId}/permissions`, {
    method: "PUT",
    body: JSON.stringify({ permissions }),
  });
}

export async function resetRoleWidgetBaseline(roleId: string): Promise<{ message: string }> {
  return await apiFetch<{ message: string }>(`/api/v1/rbac/roles/${roleId}/reset-baseline`, {
    method: "POST",
    body: JSON.stringify({}),
  });
}
