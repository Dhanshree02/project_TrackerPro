import { apiFetch } from "@/lib/api-client";
import { fetchServiceHierarchy, type ServiceGroupOption, type ServiceHierarchyGroup } from "@/lib/api/catalogs";

export interface ProjectMasterRow {
  id: string;
  groupId: string;
  contractType: string;
  departmentId: string;
  department: string;
  subDepartmentId: string;
  subDepartment: string;
  service: string;
  code: string;
  tools?: string | null;
  durationDays?: number | null;
  unitPrice?: number | null;
  createdAtUtc: string;
}

export interface CreateProjectMasterPayload {
  contractType: string;
  department: string;
  service: string;
  tools: string;
  durationDays: number;
  unitPrice: number;
  subDepartment?: string | null;
}

export type UpdateProjectMasterPayload = CreateProjectMasterPayload;

/** Read-only fallback when the API container has not been rebuilt yet (GET returns 404). */
export function flattenServiceHierarchyToProjectMasterRows(
  groups: ServiceHierarchyGroup[],
): ProjectMasterRow[] {
  const rows: ProjectMasterRow[] = [];
  for (const group of groups) {
    for (const dept of group.departments) {
      for (const sub of dept.subDepartments) {
        for (const svc of sub.services) {
          rows.push({
            id: svc.id,
            groupId: group.id,
            contractType: group.name,
            departmentId: dept.id,
            department: dept.name,
            subDepartmentId: sub.id,
            subDepartment: sub.name,
            service: svc.name,
            code: svc.code,
            tools: svc.defaultTools ?? null,
            durationDays: svc.defaultDurationDays ?? null,
            unitPrice: svc.defaultUnitPrice ?? null,
            createdAtUtc: new Date(0).toISOString(),
          });
        }
      }
    }
  }
  return rows;
}

export async function fetchProjectMasterRows(): Promise<ProjectMasterRow[]> {
  try {
    return (await apiFetch<ProjectMasterRow[]>("/api/v1/catalogs/project-masters")) ?? [];
  } catch (error) {
    const status = (error as Error & { status?: number }).status;
    if (status === 404 || status === 405) {
      const hierarchy = await fetchServiceHierarchy();
      return flattenServiceHierarchyToProjectMasterRows(hierarchy);
    }
    throw error;
  }
}

export function isProjectMastersApiMissingError(error: unknown): boolean {
  const status = (error as Error & { status?: number }).status;
  return status === 404 || status === 405;
}

export async function createProjectMaster(payload: CreateProjectMasterPayload): Promise<ProjectMasterRow> {
  return apiFetch<ProjectMasterRow>("/api/v1/catalogs/project-masters", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function updateProjectMaster(
  id: string,
  payload: UpdateProjectMasterPayload,
): Promise<ProjectMasterRow> {
  return apiFetch<ProjectMasterRow>(`/api/v1/catalogs/project-masters/${encodeURIComponent(id)}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export async function deleteProjectMaster(id: string): Promise<void> {
  await apiFetch(`/api/v1/catalogs/project-masters/${encodeURIComponent(id)}`, {
    method: "DELETE",
  });
}

export async function createServiceGroup(name: string): Promise<ServiceGroupOption> {
  return apiFetch<ServiceGroupOption>("/api/v1/catalogs/service-groups", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

export async function createServiceDepartment(
  contractType: string,
  name: string,
): Promise<{ id: string; code: string; name: string; groupId: string; groupName: string; sortOrder: number }> {
  return apiFetch("/api/v1/catalogs/service-departments", {
    method: "POST",
    body: JSON.stringify({ contractType, name }),
  });
}

export async function createServiceOnly(payload: {
  contractType: string;
  department: string;
  service: string;
  tools?: string;
  durationDays?: number;
  unitPrice?: number;
}): Promise<ProjectMasterRow> {
  return apiFetch<ProjectMasterRow>("/api/v1/catalogs/project-masters/service-only", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function rowToProjectMasterItem(row: ProjectMasterRow) {
  const days = row.durationDays ?? 0;
  return {
    id: row.id,
    contractType: row.contractType,
    group: row.contractType,
    department: row.department,
    service: row.service,
    tools: row.tools ?? "",
    duration: days > 0 ? `${days} Days` : "",
    unitPrice: Number(row.unitPrice ?? 0),
    createdAt: row.createdAtUtc,
  };
}

export function parseDurationDays(duration: string): number {
  const match = duration.match(/\d+/);
  const n = match ? parseInt(match[0], 10) : NaN;
  return Number.isFinite(n) && n > 0 ? n : 0;
}
