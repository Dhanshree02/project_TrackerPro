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
