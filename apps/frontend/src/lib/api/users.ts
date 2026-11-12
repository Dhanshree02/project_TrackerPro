import { apiFetch } from "@/lib/api-client";

export interface ApiUser {
  id: string;
  email: string;
  name: string;
  employeeId: string;
  avatar?: string | null;
  department?: string | null;
  subDepartment?: string | null;
  designation?: string | null;
  role?: string | null;
  isActive: boolean;
  mustChangePassword: boolean;
  lastLoginAtUtc?: string | null;
  createdAtUtc: string;
}

export interface ApiRole {
  id: string;
  name: string;
  displayName: string;
  description?: string | null;
  isSystemRole: boolean;
  isActive: boolean;
  userCount: number;
}

// ─── Permission catalogue (module → submodule → action) ─────────────────────
export interface ApiPermissionAction {
  key: string;
  label: string;
  legacyKeys: string[];
}

export interface ApiPermissionSubmodule {
  key: string | null;
  label: string;
  actions: ApiPermissionAction[];
}

export interface ApiPermissionModule {
  key: string;
  label: string;
  submodules: ApiPermissionSubmodule[];
}

// ─── Audit log ──────────────────────────────────────────────────────────────
export interface ApiPermissionAudit {
  id: string;
  roleId: string;
  roleName: string;
  moduleLabel: string;
  submoduleLabel?: string | null;
  permissionKey: string;
  actionLabel: string;
  changeType: string;
  previousValue: string;
  newValue: string;
  changedByName?: string | null;
  createdAtUtc: string;
}

export interface CreateUserInput {
  email: string;
  name: string;
  employeeId: string;
  role: string;
  department?: string;
  designation?: string;
}

interface PagedEnvelope<T> {
  items: T[];
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
}

export async function fetchUsers(
  params: {
    page?: number;
    perPage?: number;
    search?: string;
    role?: string;
  } = {},
): Promise<PagedEnvelope<ApiUser>> {
  const query = new URLSearchParams();
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));
  if (params.search) query.set("search", params.search);
  if (params.role) query.set("role", params.role);

  return apiFetch<PagedEnvelope<ApiUser>>(`/api/v1/users?${query.toString()}`);
}

export async function fetchRoles(): Promise<ApiRole[]> {
  return apiFetch<ApiRole[]>("/api/v1/roles");
}

export async function fetchRole(id: string): Promise<ApiRole> {
  return apiFetch<ApiRole>(`/api/v1/roles/${id}`);
}

export async function createRole(input: {
  name: string;
  displayName: string;
  description?: string;
  cloneFromRoleId?: string;
}): Promise<ApiRole> {
  return apiFetch<ApiRole>("/api/v1/roles", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateRole(
  id: string,
  input: { displayName?: string; description?: string; isActive?: boolean },
): Promise<ApiRole> {
  return apiFetch<ApiRole>(`/api/v1/roles/${id}`, {
    method: "PUT",
    body: JSON.stringify(input),
  });
}

export async function cloneRole(
  id: string,
  input: { name: string; displayName: string; description?: string },
): Promise<ApiRole> {
  return apiFetch<ApiRole>(`/api/v1/roles/${id}/clone`, {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function createUser(input: CreateUserInput): Promise<ApiUser> {
  return apiFetch<ApiUser>("/api/v1/users", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateUser(
  id: string,
  input: {
    name?: string;
    role?: string;
    isActive?: boolean;
    department?: string;
    designation?: string;
  },
): Promise<ApiUser> {
  return apiFetch<ApiUser>(`/api/v1/users/${id}`, {
    method: "PUT",
    body: JSON.stringify(input),
  });
}

export async function resetUserPassword(id: string, newPassword: string): Promise<void> {
  await apiFetch<void>(`/api/v1/users/${id}/reset-password`, {
    method: "PUT",
    body: JSON.stringify({ newPassword }),
  });
}

export interface ApiRolePermission {
  itemId: string;
  itemType: string;
  canView: number;
  canManage: number;
  defaultCanView?: number;
  defaultCanManage?: number;
}

export async function fetchRolePermissions(roleId: string): Promise<ApiRolePermission[]> {
  return (await apiFetch<ApiRolePermission[]>(`/api/v1/roles/${roleId}/permissions`)) ?? [];
}

export async function saveRolePermissions(roleId: string, permissions: ApiRolePermission[]): Promise<boolean> {
  const result = await apiFetch<boolean>(`/api/v1/roles/${roleId}/permissions`, {
    method: "PUT",
    body: JSON.stringify({ permissions }),
  });
  return !!result;
}

export async function resetRolePermissionsToDefault(roleId: string): Promise<boolean> {
  const result = await apiFetch<boolean>(`/api/v1/roles/${roleId}/permissions/reset-default`, {
    method: "POST",
  });
  return !!result;
}

// ─── Userwise Role Access ────────────────────────────────────────────────────

export interface ApiUserRoleAccess {
  id: string;
  employeeCode: string;
  fullName: string;
  workEmail: string;
  avatar?: string | null;
  departmentId?: string | null;
  departmentName: string;
  designation?: string | null;
  originalRoleId?: string | null;
  originalRoleName: string;
  originalRoleDisplayName: string;
  currentRoleId?: string | null;
  currentRoleName: string;
  currentRoleDisplayName: string;
  isSwitched: boolean;
  isSuperAdmin: boolean;
  departmentRoles: ApiRole[];
}

export async function fetchUserRoleAccessList(params: {
  page?: number;
  perPage?: number;
  search?: string;
  department?: string;
} = {}): Promise<PagedEnvelope<ApiUserRoleAccess>> {
  const query = new URLSearchParams();
  if (params.page !== undefined) query.set("page", String(params.page));
  if (params.perPage !== undefined) query.set("perPage", String(params.perPage));
  if (params.search) query.set("search", params.search);
  if (params.department && params.department !== "All") query.set("department", params.department);

  return apiFetch<PagedEnvelope<ApiUserRoleAccess>>(`/api/v1/roles/user-access?${query.toString()}`);
}

export async function updateUserRoleAccess(employeeId: string, roleId: string): Promise<ApiUserRoleAccess> {
  return apiFetch<ApiUserRoleAccess>(`/api/v1/roles/user-access/${employeeId}`, {
    method: "PUT",
    body: JSON.stringify({ roleId }),
  });
}

export async function resetUserRoleAccess(employeeId: string): Promise<ApiUserRoleAccess> {
  return apiFetch<ApiUserRoleAccess>(`/api/v1/roles/user-access/${employeeId}/reset`, {
    method: "POST",
  });
}

export async function resetAllUserRoleAccess(): Promise<number> {
  const res = await apiFetch<number>("/api/v1/roles/user-access/reset-all", {
    method: "POST",
  });
  return typeof res === "number" ? res : 0;
}

export async function fetchDepartmentRoles(): Promise<Record<string, ApiRole[]>> {
  return apiFetch<Record<string, ApiRole[]>>("/api/v1/roles/department-roles");
}


