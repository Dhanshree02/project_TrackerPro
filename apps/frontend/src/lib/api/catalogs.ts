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
