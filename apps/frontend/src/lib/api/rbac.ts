import { apiFetch } from "@/lib/api-client";

export interface WidgetNode {
  id: string;
  code: string;
  name: string;
  widgetKey: string;
  widgetType: string;
  hasManageAction: boolean;
  sortOrder: number;
  canView: number; // 0 or 1
  canManage: number; // 0 or 1
}

export interface SubmoduleNode {
  id: string;
  code: string;
  name: string;
  routePrefix?: string | null;
  sortOrder: number;
  childSubmodules: SubmoduleNode[];
  widgets: WidgetNode[];
}

export interface ModuleNode {
  id: string;
  code: string;
  name: string;
  icon?: string | null;
  sortOrder: number;
  submodules: SubmoduleNode[];
  directWidgets: WidgetNode[];
}

export interface RoleWidgetPermissionItem {
  widgetId: string;
  canView: number;
  canManage: number;
}

export interface RoleWidgetPermissionDto {
  widgetId: string;
  widgetKey: string;
  canView: number;
  canManage: number;
}

export async function fetchRbacCatalogTree(roleId?: string): Promise<ModuleNode[]> {
  const query = roleId ? `?roleId=${encodeURIComponent(roleId)}` : "";
  const data = await apiFetch<ModuleNode[]>(`/api/v1/rbac/catalog-tree${query}`);
  return data ?? [];
}

export async function fetchRoleWidgetPermissions(roleId: string): Promise<RoleWidgetPermissionDto[]> {
  const data = await apiFetch<RoleWidgetPermissionDto[]>(`/api/v1/rbac/roles/${roleId}/widget-permissions`);
  return data ?? [];
}

export async function updateRoleWidgetPermissions(
  roleId: string,
  permissions: RoleWidgetPermissionItem[],
): Promise<boolean> {
  await apiFetch<boolean>(`/api/v1/rbac/roles/${roleId}/widget-permissions`, {
    method: "PUT",
    body: JSON.stringify({ permissions }),
  });
  return true;
}

export async function resetRoleWidgetBaseline(roleId: string): Promise<boolean> {
  await apiFetch<boolean>(`/api/v1/rbac/roles/${roleId}/reset-widget-baseline`, {
    method: "POST",
  });
  return true;
}

export async function fetchMyWidgetPermissions(options?: {
  roleId?: string;
  role?: string;
}): Promise<Record<string, { v: number; m: number }>> {
  const params = new URLSearchParams();
  if (options?.roleId) params.set("roleId", options.roleId);
  if (options?.role) params.set("role", options.role);
  const q = params.toString() ? `?${params.toString()}` : "";
  const data = await apiFetch<Record<string, { v: number; m: number }>>(`/api/v1/rbac/my-permissions${q}`);
  return data ?? {};
}
