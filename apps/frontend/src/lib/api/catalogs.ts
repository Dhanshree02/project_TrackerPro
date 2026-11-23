import { apiFetch } from "@/lib/api-client";

/** Shared geo catalog row from GET /api/v1/catalogs/* (and clients/meta aliases). */
export interface CatalogOption {
  id: string;
  code: string;
  name: string;
  phoneCode?: string;
  phoneDigits?: number;
  description?: string | null;
}

export interface CityCatalogOption extends CatalogOption {
  countryId: string;
}

export interface SidebarSubModule {
  id: string;
  code: string;
  name: string;
  route: string | null;
  sortOrder: number;
  parentId: string | null;
  children: SidebarSubModule[];
  tabs: SidebarTab[];
}

export interface SidebarWidget {
  id: string;
  code: string;
  name: string;
  sortOrder: number;
  parentId: string;
}

export interface SidebarTab {
  id: string;
  code: string;
  name: string;
  sortOrder: number;
  moduleId: string | null;
  subModuleId: string | null;
  tabId: string | null;
  children: SidebarTab[];
}

export interface SidebarModule {
  id: string;
  code: string;
  name: string;
  route: string | null;
  sortOrder: number;
  iconKey: string;
  subModules: SidebarSubModule[];
  widgets: SidebarWidget[];
  tabs: SidebarTab[];
}

/** GET /api/v1/catalogs/modules — sidebar rows from master.mst_modules. */
export async function fetchSidebarModules(): Promise<SidebarModule[]> {
  return (await apiFetch<SidebarModule[]>("/api/v1/catalogs/modules")) ?? [];
}

/** GET /api/v1/catalogs/countries — reusable country dropdown source. */
export async function fetchCountries(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/countries")) ?? [];
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

/** GET /api/v1/catalogs/industries — rows from mst_industries. */
export async function fetchIndustries(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/industries")) ?? [];
}

/** GET /api/v1/catalogs/contact-designations — rows from mst_contact_designations. */
export async function fetchContactDesignations(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/contact-designations")) ?? [];
}

/** GET /api/v1/catalogs/contact-types — rows from mst_contact_types. */
export async function fetchContactTypes(): Promise<CatalogOption[]> {
  return (await apiFetch<CatalogOption[]>("/api/v1/catalogs/contact-types")) ?? [];
}

export interface ScreenOption {
  id: string;
  category: string;
  name: string;
  parentName: string;
  sortOrder: number;
}

/** GET /api/v1/catalogs/screen-options — worker type, billing medium, project type, and the other choice lists. */
export async function fetchScreenOptions(category?: string): Promise<ScreenOption[]> {
  const query = category ? `?category=${encodeURIComponent(category)}` : "";
  return (await apiFetch<ScreenOption[]>(`/api/v1/catalogs/screen-options${query}`)) ?? [];
}

export function screenOptionNames(rows: ScreenOption[], category: string, parentName?: string): string[] {
  return rows
    .filter((row) => row.category === category && (parentName === undefined || (row.parentName || "") === parentName))
    .sort((a, b) => a.sortOrder - b.sortOrder || a.name.localeCompare(b.name))
    .map((row) => row.name);
}

export async function createScreenOption(category: string, name: string, parentName?: string): Promise<ScreenOption> {
  return apiFetch<ScreenOption>("/api/v1/catalogs/screen-options", {
    method: "POST",
    body: JSON.stringify({ category, name, parentName: parentName ?? "" }),
  });
}

export async function updateScreenOption(
  id: string,
  category: string,
  name: string,
  parentName?: string,
): Promise<ScreenOption> {
  return apiFetch<ScreenOption>(`/api/v1/catalogs/screen-options/${id}`, {
    method: "PUT",
    body: JSON.stringify({ category, name, parentName: parentName ?? "" }),
  });
}

export async function deleteScreenOption(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/screen-options/${id}`, { method: "DELETE" });
}

async function saveCatalogItem(
  path: string,
  method: "POST" | "PUT",
  name: string,
  extra?: { code?: string; description?: string },
): Promise<CatalogOption> {
  return apiFetch<CatalogOption>(path, {
    method,
    body: JSON.stringify({
      name,
      code: extra?.code?.trim() || null,
      description: extra?.description?.trim() || null,
    }),
  });
}

export const createIndustry = (name: string, extra?: { code?: string }) =>
  saveCatalogItem("/api/v1/catalogs/industries", "POST", name, extra);
export const updateIndustry = (id: string, name: string, extra?: { code?: string }) =>
  saveCatalogItem(`/api/v1/catalogs/industries/${id}`, "PUT", name, extra);
export async function deleteIndustry(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/industries/${id}`, { method: "DELETE" });
}

export const createCountry = (name: string, extra?: { code?: string }) =>
  saveCatalogItem("/api/v1/catalogs/countries", "POST", name, extra);
export const updateCountry = (id: string, name: string, extra?: { code?: string }) =>
  saveCatalogItem(`/api/v1/catalogs/countries/${id}`, "PUT", name, extra);
export async function deleteCountry(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/countries/${id}`, { method: "DELETE" });
}

export async function createCity(name: string, countryId: string, code?: string): Promise<CityCatalogOption> {
  return apiFetch<CityCatalogOption>("/api/v1/catalogs/cities", {
    method: "POST",
    body: JSON.stringify({ name, countryId, code: code?.trim() || null }),
  });
}

export async function updateCity(id: string, name: string, countryId: string, code?: string): Promise<CityCatalogOption> {
  return apiFetch<CityCatalogOption>(`/api/v1/catalogs/cities/${id}`, {
    method: "PUT",
    body: JSON.stringify({ name, countryId, code: code?.trim() || null }),
  });
}

export async function deleteCity(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/cities/${id}`, { method: "DELETE" });
}

export const createContactDesignation = (name: string, extra?: { code?: string }) =>
  saveCatalogItem("/api/v1/catalogs/contact-designations", "POST", name, extra);
export const updateContactDesignation = (id: string, name: string, extra?: { code?: string }) =>
  saveCatalogItem(`/api/v1/catalogs/contact-designations/${id}`, "PUT", name, extra);
export async function deleteContactDesignation(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/contact-designations/${id}`, { method: "DELETE" });
}

export const createContactType = (name: string, extra?: { code?: string; description?: string }) =>
  saveCatalogItem("/api/v1/catalogs/contact-types", "POST", name, extra);
export const updateContactType = (id: string, name: string, extra?: { code?: string; description?: string }) =>
  saveCatalogItem(`/api/v1/catalogs/contact-types/${id}`, "PUT", name, extra);
export async function deleteContactType(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/contact-types/${id}`, { method: "DELETE" });
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
  abbreviation?: string | null;
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

/** POST /api/v1/catalogs/service-sub-departments */
export async function createServiceSubDepartment(
  contractType: string,
  department: string,
  name: string,
): Promise<ServiceSubDepartmentOption> {
  return apiFetch<ServiceSubDepartmentOption>("/api/v1/catalogs/service-sub-departments", {
    method: "POST",
    body: JSON.stringify({ contractType, department, name }),
  });
}

