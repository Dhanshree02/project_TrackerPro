import { apiFetch } from "@/lib/api-client";

export interface NamedMaster {
  id: string;
  code: string;
  name: string;
}

export interface AddressCityMaster {
  id: string;
  code: string;
  name: string;
  line?: string | null;
  sortOrder: number;
}

export interface DepartmentHierarchyRow {
  id: string;
  departmentId?: string | null;
  department: string;
  designationId: string;
  designation: string;
  subDepartment?: string | null;
  onFloorRoleId?: string | null;
  onFloorRole?: string | null;
  rbacRoleId?: string | null;
  rbacRoleName?: string | null;
  rbacRoleDisplayName?: string | null;
}

export interface HierarchyDesignationOption {
  id: string;
  name: string;
  departmentId?: string | null;
  department: string;
  subDepartment?: string | null;
}

export interface RbacRoleOption {
  id: string;
  name: string;
  displayName: string;
}

export interface DepartmentHierarchyBundle {
  rows: DepartmentHierarchyRow[];
  departments: NamedMaster[];
  designations: HierarchyDesignationOption[];
  onFloorRoles: NamedMaster[];
  rbacRoles: RbacRoleOption[];
}

export interface ResourceMastersSnapshot {
  hierarchy: DepartmentHierarchyBundle;
  emailDomains: NamedMaster[];
  businessUnits: NamedMaster[];
  workLocations: NamedMaster[];
  graduationDegrees: NamedMaster[];
  postGraduationDegrees: NamedMaster[];
  certifications: NamedMaster[];
  addressCities: AddressCityMaster[];
}

export interface HierarchyInput {
  department: string;
  designation: string;
  subDepartment: string;
  onFloorRole: string;
  rbacRoleId: string;
}

const ROOT = "/api/v1/catalogs/resource-masters";

export function explainResourceMasterError(error: unknown, fallback: string): string {
  const status = (error as { status?: number }).status;
  if (status === 404 || status === 405) {
    return "Resource masters API is not available. Rebuild and restart the backend, then refresh.";
  }
  return error instanceof Error && error.message ? error.message : fallback;
}

export function countResourceMasters(snapshot: ResourceMastersSnapshot): number {
  return (
    snapshot.hierarchy.rows.length +
    snapshot.emailDomains.length +
    snapshot.businessUnits.length +
    snapshot.workLocations.length +
    snapshot.graduationDegrees.length +
    snapshot.postGraduationDegrees.length +
    snapshot.certifications.length +
    snapshot.addressCities.length
  );
}

export async function fetchResourceMasters(): Promise<ResourceMastersSnapshot> {
  return apiFetch<ResourceMastersSnapshot>(ROOT);
}

export async function createHierarchy(input: HierarchyInput): Promise<DepartmentHierarchyRow> {
  return apiFetch<DepartmentHierarchyRow>(`${ROOT}/hierarchy`, {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateHierarchy(id: string, input: HierarchyInput): Promise<DepartmentHierarchyRow> {
  return apiFetch<DepartmentHierarchyRow>(`${ROOT}/hierarchy/${id}`, {
    method: "PUT",
    body: JSON.stringify(input),
  });
}

export async function deleteHierarchy(id: string): Promise<void> {
  await apiFetch<string>(`${ROOT}/hierarchy/${id}`, { method: "DELETE" });
}

async function createNamed(path: string, name: string): Promise<NamedMaster> {
  return apiFetch<NamedMaster>(path, {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

async function updateNamed(path: string, name: string): Promise<NamedMaster> {
  return apiFetch<NamedMaster>(path, {
    method: "PUT",
    body: JSON.stringify({ name }),
  });
}

async function deleteNamed(path: string): Promise<void> {
  await apiFetch<string>(path, { method: "DELETE" });
}

export const createEmailDomain = (name: string) => createNamed(`${ROOT}/email-domains`, name);
export const updateEmailDomain = (id: string, name: string) => updateNamed(`${ROOT}/email-domains/${id}`, name);
export const deleteEmailDomain = (id: string) => deleteNamed(`${ROOT}/email-domains/${id}`);

export const createBusinessUnit = (name: string) => createNamed(`${ROOT}/business-units`, name);
export const updateBusinessUnit = (id: string, name: string) => updateNamed(`${ROOT}/business-units/${id}`, name);
export const deleteBusinessUnit = (id: string) => deleteNamed(`${ROOT}/business-units/${id}`);

export const createWorkLocation = (name: string) => createNamed(`${ROOT}/work-locations`, name);
export const updateWorkLocation = (id: string, name: string) => updateNamed(`${ROOT}/work-locations/${id}`, name);
export const deleteWorkLocation = (id: string) => deleteNamed(`${ROOT}/work-locations/${id}`);

export const createGraduationDegree = (name: string) => createNamed(`${ROOT}/graduation-degrees`, name);
export const updateGraduationDegree = (id: string, name: string) => updateNamed(`${ROOT}/graduation-degrees/${id}`, name);
export const deleteGraduationDegree = (id: string) => deleteNamed(`${ROOT}/graduation-degrees/${id}`);

export const createPostGraduationDegree = (name: string) => createNamed(`${ROOT}/post-graduation-degrees`, name);
export const updatePostGraduationDegree = (id: string, name: string) =>
  updateNamed(`${ROOT}/post-graduation-degrees/${id}`, name);
export const deletePostGraduationDegree = (id: string) => deleteNamed(`${ROOT}/post-graduation-degrees/${id}`);

export const createCertification = (name: string) => createNamed(`${ROOT}/certifications`, name);
export const updateCertification = (id: string, name: string) => updateNamed(`${ROOT}/certifications/${id}`, name);
export const deleteCertification = (id: string) => deleteNamed(`${ROOT}/certifications/${id}`);

export async function createAddressCityMaster(name: string, line?: string): Promise<AddressCityMaster> {
  return apiFetch<AddressCityMaster>("/api/v1/catalogs/address-cities", {
    method: "POST",
    body: JSON.stringify({ name, line: line?.trim() || null }),
  });
}

export async function updateAddressCityMaster(id: string, name: string, line?: string): Promise<AddressCityMaster> {
  return apiFetch<AddressCityMaster>(`/api/v1/catalogs/address-cities/${id}`, {
    method: "PUT",
    body: JSON.stringify({ name, line: line?.trim() || null }),
  });
}

export async function deleteAddressCityMaster(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/address-cities/${id}`, { method: "DELETE" });
}
