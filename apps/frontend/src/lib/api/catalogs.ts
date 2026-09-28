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

