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

export interface NamedCatalogWrite {
  name: string;
  code?: string | null;
}

export async function createIndustry(input: NamedCatalogWrite): Promise<CatalogOption> {
  return apiFetch<CatalogOption>("/api/v1/catalogs/industries", { method: "POST", body: JSON.stringify(input) });
}

export async function updateIndustry(id: string, input: NamedCatalogWrite): Promise<CatalogOption> {
  return apiFetch<CatalogOption>(`/api/v1/catalogs/industries/${id}`, { method: "PUT", body: JSON.stringify(input) });
}

export async function deleteIndustry(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/industries/${id}`, { method: "DELETE" });
}

export async function createContactDesignation(input: NamedCatalogWrite): Promise<CatalogOption> {
  return apiFetch<CatalogOption>("/api/v1/catalogs/contact-designations", { method: "POST", body: JSON.stringify(input) });
}

export async function updateContactDesignation(id: string, input: NamedCatalogWrite): Promise<CatalogOption> {
  return apiFetch<CatalogOption>(`/api/v1/catalogs/contact-designations/${id}`, { method: "PUT", body: JSON.stringify(input) });
}

export async function deleteContactDesignation(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/contact-designations/${id}`, { method: "DELETE" });
}

export async function createContactType(input: NamedCatalogWrite): Promise<CatalogOption> {
  return apiFetch<CatalogOption>("/api/v1/catalogs/contact-types", { method: "POST", body: JSON.stringify(input) });
}

export async function updateContactType(id: string, input: NamedCatalogWrite): Promise<CatalogOption> {
  return apiFetch<CatalogOption>(`/api/v1/catalogs/contact-types/${id}`, { method: "PUT", body: JSON.stringify(input) });
}

export async function deleteContactType(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/contact-types/${id}`, { method: "DELETE" });
}

export async function createCountry(input: NamedCatalogWrite): Promise<CatalogOption> {
  return apiFetch<CatalogOption>("/api/v1/catalogs/countries", { method: "POST", body: JSON.stringify(input) });
}

export async function updateCountry(id: string, input: NamedCatalogWrite): Promise<CatalogOption> {
  return apiFetch<CatalogOption>(`/api/v1/catalogs/countries/${id}`, { method: "PUT", body: JSON.stringify(input) });
}

export async function deleteCountry(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/countries/${id}`, { method: "DELETE" });
}

export async function createCity(input: NamedCatalogWrite & { countryId: string }): Promise<CityCatalogOption> {
  return apiFetch<CityCatalogOption>("/api/v1/catalogs/cities", { method: "POST", body: JSON.stringify(input) });
}

export async function updateCity(id: string, input: NamedCatalogWrite & { countryId: string }): Promise<CityCatalogOption> {
  return apiFetch<CityCatalogOption>(`/api/v1/catalogs/cities/${id}`, { method: "PUT", body: JSON.stringify(input) });
}

export async function deleteCity(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/cities/${id}`, { method: "DELETE" });
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

export interface ServiceCatalogWrite {
  subDepartmentId: string;
  name: string;
  defaultTools?: string | null;
  defaultUnitPrice?: number | null;
  defaultDurationDays?: number | null;
}

export interface ServiceCatalogUpdate {
  name?: string;
  subDepartmentId?: string;
  defaultTools: string;
  defaultUnitPrice: number;
  defaultDurationDays: number;
}

export function isCatalogGuid(value: string | undefined | null): value is string {
  return !!value && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value);
}

export function durationDaysFromText(value: string): number | null {
  const match = /(\d+)/.exec(value);
  if (!match) return null;
  const days = Number(match[1]);
  return Number.isInteger(days) && days > 0 && days <= 3650 ? days : null;
}

export async function createServiceGroup(name: string): Promise<ServiceGroupOption> {
  return apiFetch<ServiceGroupOption>("/api/v1/catalogs/service-groups", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

export async function createServiceDepartment(groupId: string, name: string): Promise<ServiceDepartmentOption> {
  return apiFetch<ServiceDepartmentOption>("/api/v1/catalogs/service-departments", {
    method: "POST",
    body: JSON.stringify({ groupId, name }),
  });
}

export async function createServiceSubDepartment(departmentId: string, name: string): Promise<ServiceSubDepartmentOption> {
  return apiFetch<ServiceSubDepartmentOption>("/api/v1/catalogs/service-sub-departments", {
    method: "POST",
    body: JSON.stringify({ departmentId, name }),
  });
}

export async function createServiceCatalog(input: ServiceCatalogWrite): Promise<ServiceHierarchyItem> {
  return apiFetch<ServiceHierarchyItem>("/api/v1/catalogs/service-catalog", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateServiceCatalog(id: string, input: ServiceCatalogUpdate): Promise<ServiceHierarchyItem> {
  return apiFetch<ServiceHierarchyItem>(`/api/v1/catalogs/service-catalog/${id}`, {
    method: "PUT",
    body: JSON.stringify(input),
  });
}

export async function deleteServiceCatalog(id: string): Promise<void> {
  await apiFetch<string>(`/api/v1/catalogs/service-catalog/${id}`, { method: "DELETE" });
}

