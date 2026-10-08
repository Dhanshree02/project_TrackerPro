import { apiFetch } from "@/lib/api-client";

/** Shared geo catalog row from GET /api/v1/catalogs/* (and clients/meta aliases). */
export interface CatalogOption {
  id: string;
  code: string;
  name: string;
  phoneCode?: string;
  phoneDigits?: number;
}

export interface CityCatalogOption extends CatalogOption {
  countryId: string;
  countryName?: string;
}

/** GET /api/v1/catalogs/countries — reusable country dropdown source. */
export async function fetchCountries(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/countries")) ?? [];
}

/** POST /api/v1/catalogs/countries */
export async function createCountry(payload: { name: string; code?: string; phoneCode?: string; phoneDigits?: number }): Promise<CatalogOption> {
  const res = await apiFetch<CatalogOption>("/api/v1/catalogs/countries", {
    method: "POST",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to create country");
  return res;
}

/** PUT /api/v1/catalogs/countries/:id */
export async function updateCountry(id: string, payload: { name?: string; code?: string; phoneCode?: string; phoneDigits?: number }): Promise<CatalogOption> {
  const res = await apiFetch<CatalogOption>(`/api/v1/catalogs/countries/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to update country");
  return res;
}

/** DELETE /api/v1/catalogs/countries/:id */
export async function deleteCountry(id: string): Promise<boolean> {
  await apiFetch(`/api/v1/catalogs/countries/${id}`, { method: "DELETE" });
  return true;
}

/** GET /api/v1/catalogs/nationalities — rows from mst_nationalities. */
export async function fetchNationalities(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/nationalities")) ?? [];
}

/** GET /api/v1/catalogs/cities?countryId= — cities for one country (or all if omitted). */
export async function fetchCities(countryId?: string): Promise<CityCatalogOption[]> {
  const query = countryId ? `?countryId=${encodeURIComponent(countryId)}` : "";
  return (await apiFetch<CityCatalogOption[]>(`/api/v1/catalogs/cities${query}`)) ?? [];
}

/** POST /api/v1/catalogs/cities */
export async function createCity(payload: { name: string; countryId: string; code?: string }): Promise<CityCatalogOption> {
  const res = await apiFetch<CityCatalogOption>("/api/v1/catalogs/cities", {
    method: "POST",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to create city");
  return res;
}

/** PUT /api/v1/catalogs/cities/:id */
export async function updateCity(id: string, payload: { name?: string; countryId?: string; code?: string }): Promise<CityCatalogOption> {
  const res = await apiFetch<CityCatalogOption>(`/api/v1/catalogs/cities/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to update city");
  return res;
}

/** DELETE /api/v1/catalogs/cities/:id */
export async function deleteCity(id: string): Promise<boolean> {
  await apiFetch(`/api/v1/catalogs/cities/${id}`, { method: "DELETE" });
  return true;
}

/** GET /api/v1/catalogs/industries — rows from mst_industries. */
export async function fetchIndustries(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/industries")) ?? [];
}

/** POST /api/v1/catalogs/industries */
export async function createIndustry(payload: { name: string; code?: string }): Promise<CatalogOption> {
  const res = await apiFetch<CatalogOption>("/api/v1/catalogs/industries", {
    method: "POST",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to create industry");
  return res;
}

/** PUT /api/v1/catalogs/industries/:id */
export async function updateIndustry(id: string, payload: { name?: string; code?: string }): Promise<CatalogOption> {
  const res = await apiFetch<CatalogOption>(`/api/v1/catalogs/industries/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to update industry");
  return res;
}

/** DELETE /api/v1/catalogs/industries/:id */
export async function deleteIndustry(id: string): Promise<boolean> {
  await apiFetch(`/api/v1/catalogs/industries/${id}`, { method: "DELETE" });
  return true;
}

/** GET /api/v1/catalogs/contact-designations — rows from mst_contact_designations. */
export async function fetchContactDesignations(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/contact-designations")) ?? [];
}

/** POST /api/v1/catalogs/contact-designations */
export async function createContactDesignation(payload: { name: string; code?: string }): Promise<CatalogOption> {
  const res = await apiFetch<CatalogOption>("/api/v1/catalogs/contact-designations", {
    method: "POST",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to create contact designation");
  return res;
}

/** PUT /api/v1/catalogs/contact-designations/:id */
export async function updateContactDesignation(id: string, payload: { name?: string; code?: string }): Promise<CatalogOption> {
  const res = await apiFetch<CatalogOption>(`/api/v1/catalogs/contact-designations/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to update contact designation");
  return res;
}

/** DELETE /api/v1/catalogs/contact-designations/:id */
export async function deleteContactDesignation(id: string): Promise<boolean> {
  await apiFetch(`/api/v1/catalogs/contact-designations/${id}`, { method: "DELETE" });
  return true;
}

/** GET /api/v1/catalogs/contact-types — rows from mst_contact_types. */
export async function fetchContactTypes(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/contact-types")) ?? [];
}

/** POST /api/v1/catalogs/contact-types */
export async function createContactType(payload: { name: string; code?: string }): Promise<CatalogOption> {
  const res = await apiFetch<CatalogOption>("/api/v1/catalogs/contact-types", {
    method: "POST",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to create contact type");
  return res;
}

/** PUT /api/v1/catalogs/contact-types/:id */
export async function updateContactType(id: string, payload: { name?: string; code?: string }): Promise<CatalogOption> {
  const res = await apiFetch<CatalogOption>(`/api/v1/catalogs/contact-types/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
  if (!res) throw new Error("Failed to update contact type");
  return res;
}

/** DELETE /api/v1/catalogs/contact-types/:id */
export async function deleteContactType(id: string): Promise<boolean> {
  await apiFetch(`/api/v1/catalogs/contact-types/${id}`, { method: "DELETE" });
  return true;
}

/** Current Address - City row from master.mst_address_cities. */
export interface AddressCityOption {
  id: string;
  code: string;
  name: string;
  line?: string | null;
  sortOrder: number;
}

/** GET /api/v1/catalogs/address-cities */
export async function fetchAddressCities(): Promise<AddressCityOption[]> {
  return (await apiFetch<AddressCityOption[]>("/api/v1/catalogs/address-cities")) ?? [];
}

/** POST /api/v1/catalogs/address-cities */
export async function createAddressCity(name: string, line?: string): Promise<AddressCityOption> {
  return apiFetch<AddressCityOption>("/api/v1/catalogs/address-cities", {
    method: "POST",
    body: JSON.stringify({ name, line: line?.trim() || null }),
  });
}

/** DELETE /api/v1/catalogs/address-cities/{id} */
export async function deleteAddressCity(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/address-cities/${id}`, { method: "DELETE" });
}

// ── Service Catalog & Hierarchy ──

export interface ServiceGroupOption {
  id: string;
  code: string;
  name: string;
  sortOrder: number;
}

export interface ServiceDepartmentOption {
  id: string;
  code: string;
  name: string;
  groupId: string;
  groupName: string;
  sortOrder: number;
}

export interface ServiceSubDepartmentOption {
  id: string;
  code: string;
  name: string;
  departmentId: string;
  departmentName: string;
  sortOrder: number;
}

export interface ServiceCatalogOption {
  id: string;
  code: string;
  name: string;
  subDepartmentId: string;
  subDepartmentName: string;
  defaultTools?: string | null;
  defaultUnitPrice?: number | null;
  defaultDurationDays?: number | null;
  description?: string | null;
  sortOrder: number;
}

export interface ServiceHierarchyItem {
  id: string;
  code: string;
  name: string;
  defaultTools?: string | null;
  defaultUnitPrice?: number | null;
  defaultDurationDays?: number | null;
  description?: string | null;
  sortOrder: number;
}

export interface ServiceHierarchySubDept {
  id: string;
  code: string;
  name: string;
  sortOrder: number;
  services: ServiceHierarchyItem[];
}

export interface ServiceHierarchyDept {
  id: string;
  code: string;
  name: string;
  groupCode: string;
  groupName: string;
  sortOrder: number;
  subDepartments: ServiceHierarchySubDept[];
}

export interface ServiceHierarchyGroup {
  id: string;
  code: string;
  name: string;
  sortOrder: number;
  departments: ServiceHierarchyDept[];
}

/** GET /api/v1/catalogs/service-groups */
export async function fetchServiceGroups(): Promise<ServiceGroupOption[]> {
  return (await apiFetch<ServiceGroupOption[]>("/api/v1/catalogs/service-groups")) ?? [];
}

/** GET /api/v1/catalogs/service-departments?groupId= */
export async function fetchServiceDepartments(groupId?: string): Promise<ServiceDepartmentOption[]> {
  const query = groupId ? `?groupId=${encodeURIComponent(groupId)}` : "";
  return (await apiFetch<ServiceDepartmentOption[]>(`/api/v1/catalogs/service-departments${query}`)) ?? [];
}

/** GET /api/v1/catalogs/service-sub-departments?departmentId= */
export async function fetchServiceSubDepartments(departmentId?: string): Promise<ServiceSubDepartmentOption[]> {
  const query = departmentId ? `?departmentId=${encodeURIComponent(departmentId)}` : "";
  return (await apiFetch<ServiceSubDepartmentOption[]>(`/api/v1/catalogs/service-sub-departments${query}`)) ?? [];
}

/** GET /api/v1/catalogs/service-catalog?subDepartmentId= */
export async function fetchServiceCatalog(subDepartmentId?: string): Promise<ServiceCatalogOption[]> {
  const query = subDepartmentId ? `?subDepartmentId=${encodeURIComponent(subDepartmentId)}` : "";
  return (await apiFetch<ServiceCatalogOption[]>(`/api/v1/catalogs/service-catalog${query}`)) ?? [];
}

/** GET /api/v1/catalogs/service-hierarchy — Complete tree for Section A service picker */
export async function fetchServiceHierarchy(): Promise<ServiceHierarchyGroup[]> {
  return (await apiFetch<ServiceHierarchyGroup[]>("/api/v1/catalogs/service-hierarchy")) ?? [];
}

/** POST /api/v1/catalogs/service-departments — Creates department in master.mst_service_departments */
export async function createServiceDepartment(payload: {
  name: string;
  group?: string;
  groupId?: string;
  code?: string;
}): Promise<ServiceDepartmentOption | null> {
  return await apiFetch<ServiceDepartmentOption>("/api/v1/catalogs/service-departments", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

/** POST /api/v1/catalogs/service-sub-departments — Creates sub-department in master.mst_service_sub_departments */
export async function createServiceSubDepartment(payload: {
  name: string;
  departmentName?: string;
  departmentId?: string;
  code?: string;
}): Promise<ServiceSubDepartmentOption | null> {
  return await apiFetch<ServiceSubDepartmentOption>("/api/v1/catalogs/service-sub-departments", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

/** POST /api/v1/catalogs/service-catalog — Creates service in master.mst_service_catalog */
export async function createServiceCatalog(payload: {
  name: string;
  departmentName?: string;
  subDepartmentName?: string;
  subDepartmentId?: string;
  defaultTools?: string;
  defaultUnitPrice?: number;
  defaultDurationDays?: number;
  description?: string;
}): Promise<ServiceCatalogOption | null> {
  return await apiFetch<ServiceCatalogOption>("/api/v1/catalogs/service-catalog", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

/** POST /api/v1/catalogs/service-groups — Creates group in master.mst_service_groups */
export async function createServiceGroup(payload: {
  name: string;
  code?: string;
}): Promise<ServiceGroupOption | null> {
  return await apiFetch<ServiceGroupOption>("/api/v1/catalogs/service-groups", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export interface BackendProjectMasterDto {
  id: string;
  contractType: string;
  group: string;
  department: string;
  subDepartment?: string;
  service: string;
  tools: string;
  duration: string;
  unitPrice: number;
  createdAtUtc: string;
}

/** GET /api/v1/catalogs/project-masters — Fetch all project masters directly from PostgreSQL */
export async function fetchProjectMasters(): Promise<BackendProjectMasterDto[]> {
  return (await apiFetch<BackendProjectMasterDto[]>("/api/v1/catalogs/project-masters")) ?? [];
}

/** POST /api/v1/catalogs/project-masters — Create project master and store in PostgreSQL */
export async function createProjectMaster(payload: {
  contractType: string;
  department: string;
  subDepartment?: string;
  service: string;
  tools: string;
  duration: string;
  unitPrice: number;
}): Promise<BackendProjectMasterDto> {
  return await apiFetch<BackendProjectMasterDto>("/api/v1/catalogs/project-masters", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

/** PUT /api/v1/catalogs/project-masters/:id — Update existing project master in PostgreSQL */
export async function updateProjectMaster(
  id: string,
  payload: {
    contractType?: string;
    department?: string;
    subDepartment?: string;
    service?: string;
    tools?: string;
    duration?: string;
    unitPrice?: number;
  },
): Promise<BackendProjectMasterDto> {
  return await apiFetch<BackendProjectMasterDto>(`/api/v1/catalogs/project-masters/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

/** DELETE /api/v1/catalogs/project-masters/:id — Delete project master from PostgreSQL */
export async function deleteProjectMaster(id: string): Promise<boolean> {
  return await apiFetch<boolean>(`/api/v1/catalogs/project-masters/${id}`, {
    method: "DELETE",
  });
}


