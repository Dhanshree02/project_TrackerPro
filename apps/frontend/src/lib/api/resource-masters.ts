import { apiFetch } from "@/lib/api-client";
import type {
  DepartmentHierarchyItem,
  EmailDomainItem,
  CityMasterItem,
  SimpleResourceMasterItem,
} from "@/lib/masters/types";

// ── Backend DTO Interfaces ──────────────────────────────────────────────────

export interface BackendResourceHierarchyDto {
  id: string;
  departmentId?: string;
  departmentName: string;
  departmentCode?: string;
  designationId?: string;
  designationName: string;
  designationCode?: string;
  onFloorRoleId?: string;
  onFloorRoleName: string;
  onFloorRoleCode?: string;
  assignedRbacRoleId?: string;
  assignedRbacRoleName: string;
  assignedRbacRoleCode?: string;
  isActive: boolean;
  createdAtUtc: string;
}

export interface BackendEmailDomainDto {
  id: string;
  domainName: string;
  displayName: string;
  code: string;
  isActive: boolean;
  sortOrder: number;
  createdAtUtc: string;
}

export interface BackendCityDto {
  id: string;
  name: string;
  code: string;
  line?: string;
  subLabel?: string;
  stationName?: string;
  isActive: boolean;
  createdAtUtc: string;
}

export interface BackendSimpleMasterDto {
  id: string;
  name: string;
  code: string;
  description?: string;
  isActive: boolean;
  createdAtUtc: string;
}

export interface BackendRbacRoleOptionDto {
  id: string;
  name: string;
  displayName: string;
  description?: string;
  isActive: boolean;
}

export type SimpleCategory =
  | "businessUnits"
  | "workLocations"
  | "graduationDegrees"
  | "postGraduationDegrees"
  | "certifications";

const CATEGORY_MAP: Record<SimpleCategory, string> = {
  businessUnits: "business-units",
  workLocations: "work-locations",
  graduationDegrees: "graduation-degrees",
  postGraduationDegrees: "post-graduation-degrees",
  certifications: "certifications",
};

// ── 1. Department Hierarchy ─────────────────────────────────────────────────

export async function fetchResourceHierarchy(): Promise<DepartmentHierarchyItem[]> {
  const data = await apiFetch<BackendResourceHierarchyDto[]>("/api/v1/resource-masters/hierarchy");
  if (!data) return [];
  return data.map((d) => ({
    id: d.id,
    departmentId: d.departmentId,
    departmentName: d.departmentName,
    designationId: d.designationId,
    designationName: d.designationName,
    onFloorRoleId: d.onFloorRoleId,
    onFloorRoleName: d.onFloorRoleName,
    assignedRbacRoleId: d.assignedRbacRoleId,
    assignedRbacRoleName: d.assignedRbacRoleName,
    assignedRbacRoleCode: d.assignedRbacRoleCode,
    isActive: d.isActive,
    createdAt: d.createdAtUtc,
  }));
}

const isValidGuid = (val?: string | null): boolean =>
  !!val && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(val);

export async function createResourceHierarchy(
  item: Omit<DepartmentHierarchyItem, "id" | "createdAt">,
): Promise<DepartmentHierarchyItem> {
  const res = await apiFetch<BackendResourceHierarchyDto>("/api/v1/resource-masters/hierarchy", {
    method: "POST",
    body: JSON.stringify({
      departmentName: item.departmentName?.trim(),
      designationName: item.designationName?.trim(),
      onFloorRoleName: item.onFloorRoleName?.trim(),
      assignedRbacRoleId: isValidGuid(item.assignedRbacRoleId) ? item.assignedRbacRoleId : undefined,
      assignedRbacRoleName: item.assignedRbacRoleName?.trim(),
      assignedRbacRoleCode: item.assignedRbacRoleCode?.trim(),
    }),
  });
  return {
    id: res.id,
    departmentId: res.departmentId,
    departmentName: res.departmentName,
    designationId: res.designationId,
    designationName: res.designationName,
    onFloorRoleId: res.onFloorRoleId,
    onFloorRoleName: res.onFloorRoleName,
    assignedRbacRoleId: res.assignedRbacRoleId,
    assignedRbacRoleName: res.assignedRbacRoleName,
    assignedRbacRoleCode: res.assignedRbacRoleCode,
    isActive: res.isActive,
    createdAt: res.createdAtUtc,
  };
}

export async function updateResourceHierarchy(
  id: string,
  item: Partial<Omit<DepartmentHierarchyItem, "id" | "createdAt">>,
): Promise<DepartmentHierarchyItem> {
  const res = await apiFetch<BackendResourceHierarchyDto>(`/api/v1/resource-masters/hierarchy/${id}`, {
    method: "PUT",
    body: JSON.stringify({
      departmentName: item.departmentName?.trim(),
      designationName: item.designationName?.trim(),
      onFloorRoleName: item.onFloorRoleName?.trim(),
      assignedRbacRoleId: isValidGuid(item.assignedRbacRoleId) ? item.assignedRbacRoleId : undefined,
      assignedRbacRoleName: item.assignedRbacRoleName?.trim(),
      assignedRbacRoleCode: item.assignedRbacRoleCode?.trim(),
      isActive: item.isActive,
    }),
  });
  return {
    id: res.id,
    departmentId: res.departmentId,
    departmentName: res.departmentName,
    designationId: res.designationId,
    designationName: res.designationName,
    onFloorRoleId: res.onFloorRoleId,
    onFloorRoleName: res.onFloorRoleName,
    assignedRbacRoleId: res.assignedRbacRoleId,
    assignedRbacRoleName: res.assignedRbacRoleName,
    assignedRbacRoleCode: res.assignedRbacRoleCode,
    isActive: res.isActive,
    createdAt: res.createdAtUtc,
  };
}

export async function deleteResourceHierarchy(id: string): Promise<boolean> {
  return await apiFetch<boolean>(`/api/v1/resource-masters/hierarchy/${id}`, {
    method: "DELETE",
  });
}

// ── 2. Email Domains ────────────────────────────────────────────────────────

export async function fetchEmailDomains(): Promise<EmailDomainItem[]> {
  const data = await apiFetch<BackendEmailDomainDto[]>("/api/v1/resource-masters/email-domains");
  if (!data) return [];
  return data.map((d) => ({
    id: d.id,
    domainName: d.domainName,
    displayName: d.displayName,
    code: d.code,
    isActive: d.isActive,
    createdAt: d.createdAtUtc,
  }));
}

export async function createEmailDomain(
  domainName: string,
  extra?: { displayName?: string; code?: string },
): Promise<EmailDomainItem> {
  const res = await apiFetch<BackendEmailDomainDto>("/api/v1/resource-masters/email-domains", {
    method: "POST",
    body: JSON.stringify({
      domainName,
      displayName: extra?.displayName,
      code: extra?.code,
    }),
  });
  return {
    id: res.id,
    domainName: res.domainName,
    displayName: res.displayName,
    code: res.code,
    isActive: res.isActive,
    createdAt: res.createdAtUtc,
  };
}

export async function updateEmailDomain(
  id: string,
  domainName: string,
  extra?: { displayName?: string; code?: string; isActive?: boolean },
): Promise<EmailDomainItem> {
  const res = await apiFetch<BackendEmailDomainDto>(`/api/v1/resource-masters/email-domains/${id}`, {
    method: "PUT",
    body: JSON.stringify({
      domainName,
      displayName: extra?.displayName,
      code: extra?.code,
      isActive: extra?.isActive,
    }),
  });
  return {
    id: res.id,
    domainName: res.domainName,
    displayName: res.displayName,
    code: res.code,
    isActive: res.isActive,
    createdAt: res.createdAtUtc,
  };
}

export async function deleteEmailDomain(id: string): Promise<boolean> {
  return await apiFetch<boolean>(`/api/v1/resource-masters/email-domains/${id}`, {
    method: "DELETE",
  });
}

// ── 3. Current Address - Cities / Stations ──────────────────────────────────

export async function fetchResourceCities(): Promise<CityMasterItem[]> {
  const data = await apiFetch<BackendCityDto[]>("/api/v1/resource-masters/cities");
  if (!data) return [];
  return data.map((c) => ({
    id: c.id,
    name: c.name,
    line: c.line || "Western Line",
    subLabel: c.line || "Western Line",
    value: `${c.name} (${c.line || "Western Line"})`,
    code: c.code,
    stationName: c.stationName || c.name,
    isActive: c.isActive,
    createdAt: c.createdAtUtc,
  }));
}

export async function createResourceCity(
  name: string,
  extra?: { line?: string; code?: string; stationName?: string },
): Promise<CityMasterItem> {
  const res = await apiFetch<BackendCityDto>("/api/v1/resource-masters/cities", {
    method: "POST",
    body: JSON.stringify({
      name,
      line: extra?.line,
      code: extra?.code,
      stationName: extra?.stationName,
    }),
  });
  return {
    id: res.id,
    name: res.name,
    line: res.line || "Western Line",
    subLabel: res.line || "Western Line",
    value: `${res.name} (${res.line || "Western Line"})`,
    code: res.code,
    stationName: res.stationName || res.name,
    isActive: res.isActive,
    createdAt: res.createdAtUtc,
  };
}

export async function updateResourceCity(
  id: string,
  name: string,
  extra?: { line?: string; code?: string; stationName?: string; isActive?: boolean },
): Promise<CityMasterItem> {
  const res = await apiFetch<BackendCityDto>(`/api/v1/resource-masters/cities/${id}`, {
    method: "PUT",
    body: JSON.stringify({
      name,
      line: extra?.line,
      code: extra?.code,
      stationName: extra?.stationName,
      isActive: extra?.isActive,
    }),
  });
  return {
    id: res.id,
    name: res.name,
    line: res.line || "Western Line",
    subLabel: res.line || "Western Line",
    value: `${res.name} (${res.line || "Western Line"})`,
    code: res.code,
    stationName: res.stationName || res.name,
    isActive: res.isActive,
    createdAt: res.createdAtUtc,
  };
}

export async function deleteResourceCity(id: string): Promise<boolean> {
  return await apiFetch<boolean>(`/api/v1/resource-masters/cities/${id}`, {
    method: "DELETE",
  });
}

// ── 4–8. Simple Masters ─────────────────────────────────────────────────────

export async function fetchSimpleMasters(category: SimpleCategory): Promise<SimpleResourceMasterItem[]> {
  const endpoint = CATEGORY_MAP[category];
  const data = await apiFetch<BackendSimpleMasterDto[]>(`/api/v1/resource-masters/${endpoint}`);
  if (!data) return [];
  return data.map((d) => ({
    id: d.id,
    name: d.name,
    code: d.code,
    description: d.description,
    isActive: d.isActive,
    createdAt: d.createdAtUtc,
  }));
}

export async function createSimpleMaster(
  category: SimpleCategory,
  name: string,
  extra?: { code?: string; description?: string },
): Promise<SimpleResourceMasterItem> {
  const endpoint = CATEGORY_MAP[category];
  const res = await apiFetch<BackendSimpleMasterDto>(`/api/v1/resource-masters/${endpoint}`, {
    method: "POST",
    body: JSON.stringify({
      name,
      code: extra?.code,
      description: extra?.description,
    }),
  });
  return {
    id: res.id,
    name: res.name,
    code: res.code,
    description: res.description,
    isActive: res.isActive,
    createdAt: res.createdAtUtc,
  };
}

export async function updateSimpleMaster(
  category: SimpleCategory,
  id: string,
  name: string,
  extra?: { code?: string; description?: string; isActive?: boolean },
): Promise<SimpleResourceMasterItem> {
  const endpoint = CATEGORY_MAP[category];
  const res = await apiFetch<BackendSimpleMasterDto>(`/api/v1/resource-masters/${endpoint}/${id}`, {
    method: "PUT",
    body: JSON.stringify({
      name,
      code: extra?.code,
      description: extra?.description,
      isActive: extra?.isActive,
    }),
  });
  return {
    id: res.id,
    name: res.name,
    code: res.code,
    description: res.description,
    isActive: res.isActive,
    createdAt: res.createdAtUtc,
  };
}

export async function deleteSimpleMaster(category: SimpleCategory, id: string): Promise<boolean> {
  const endpoint = CATEGORY_MAP[category];
  return await apiFetch<boolean>(`/api/v1/resource-masters/${endpoint}/${id}`, {
    method: "DELETE",
  });
}

// ── 9. RBAC Roles for selection ─────────────────────────────────────────────

export async function fetchRbacRoles(): Promise<BackendRbacRoleOptionDto[]> {
  const data = await apiFetch<BackendRbacRoleOptionDto[]>("/api/v1/resource-masters/rbac-roles");
  return data ?? [];
}
