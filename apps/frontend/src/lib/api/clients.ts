import { apiFetch, API_BASE } from "@/lib/api-client";
import {
  clientLogo,
  type Client,
  type ClientContact,
  type ClientSubVenture,
} from "@/lib/mock-data";

/** Formats a deterministic, consistent, and readable Customer ID e.g. CUST-C8E5EC6B */
export function formatCustomerId(id?: string | null): string {
  if (!id) return "—";
  const trimmed = id.trim();
  if (trimmed.startsWith("CUST-") || trimmed.startsWith("CL-") || trimmed.startsWith("C-")) {
    return trimmed;
  }
  if (/^\d+$/.test(trimmed)) {
    return `CUST-${trimmed.padStart(4, "0")}`;
  }
  const clean = trimmed.replace(/-/g, "").toUpperCase();
  return `CUST-${clean.slice(0, 8)}`;
}

/** Wire shape returned by GET /api/v1/clients (camelCase JSON). */
export interface ApiClientContact {
  name?: string | null;
  email?: string | null;
  phone?: string | null;
  designation?: string | null;
  contactType?: string | null;
}

/** Wire shape of a sub-venture: id + name + its own SPOC contacts + notes + KYC. */
export interface ApiSubVenture {
  id: string;
  name: string;
  contacts: ApiClientContact[];
  notes?: string | null;
  kycDocumentName?: string | null;
  kycDocumentPath?: string | null;
}

export interface ApiClient {
  id: string;
  name: string;
  industry: string;
  logo?: string | null;
  contactEmail?: string | null;
  clientType: "NEW" | "OLD";
  status: string;
  engagementManager?: string | null;
  salesManager?: string | null;
  contactName?: string | null;
  contactPhone?: string | null;
  contactDesignation?: string | null;
  contactType?: string | null;
  city?: string | null;
  country?: string | null;
  businessType?: string | null;
  notes?: string | null;
  kycDocumentName?: string | null;
  kycDocumentPath?: string | null;
  subVentures: ApiSubVenture[];
  contacts: ApiClientContact[];
  customerSince?: string | null;
  createdAtUtc: string;
}

interface PagedEnvelope<T> {
  items: T[];
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
}

/** Maps the wire DTO to the frontend Client shape used by the customers pages. */
export function mapApiClient(c: ApiClient): Client {
  return {
    id: c.id,
    name: c.name,
    industry: c.industry,
    // Logo is derived from the name (first + last letter) when the API omits it.
    logo: (c.logo ?? clientLogo(c.name)) || "•",
    contact: c.contactEmail ?? "",
    clientType: c.clientType,
    engagementManager: c.engagementManager ?? undefined,
    salesManager: c.salesManager ?? undefined,
    contactName: c.contactName ?? undefined,
    contactPhone: c.contactPhone ?? undefined,
    contactDesignation: c.contactDesignation ?? undefined,
    contactType: c.contactType ?? undefined,
    city: c.city ?? undefined,
    country: c.country ?? undefined,
    businessType: c.businessType ?? undefined,
    notes: c.notes ?? undefined,
    kycDocumentName: c.kycDocumentName ?? undefined,
    kycDocumentPath: c.kycDocumentPath ?? undefined,
    customerSince: c.customerSince ? c.customerSince.slice(0, 10) : c.createdAtUtc?.slice(0, 10),
    subVentures: (c.subVentures ?? []).map((sv) => ({
      id: sv.id,
      name: sv.name,
      notes: sv.notes ?? undefined,
      kycDocumentName: sv.kycDocumentName ?? undefined,
      kycDocumentPath: sv.kycDocumentPath ?? undefined,
      // A sub-venture SPOC is identified by name — phone is the primary field for
      // per-sub-venture contacts, so don't drop phone-only contacts.
      contacts: (sv.contacts ?? [])
        .filter((x): x is ApiClientContact & { name: string } => Boolean(x.name))
        .map((x) => ({
          name: x.name,
          email: x.email ?? "",
          phone: x.phone ?? undefined,
          designation: x.designation ?? undefined,
          contactType: x.contactType ?? undefined,
        })),
    })),
    contacts: (c.contacts ?? [])
      .filter((x): x is ApiClientContact & { name: string; email: string } =>
        Boolean(x.name && x.email),
      )
      .map((x) => ({
        name: x.name,
        email: x.email,
        phone: x.phone ?? undefined,
        designation: x.designation ?? undefined,
        contactType: x.contactType ?? undefined,
      })) as ClientContact[],
  };
}

/** GET /api/v1/clients?page=&perPage= — returns the client list (role-scoped). */
export async function fetchClients(page = 1, perPage = 100): Promise<ApiClient[]> {
  const data = await apiFetch<PagedEnvelope<ApiClient>>(
    `/api/v1/clients?page=${page}&perPage=${perPage}`,
  );
  return data?.items ?? [];
}

/** GET /api/v1/clients/{id} */
export async function fetchClient(id: string): Promise<ApiClient | null> {
  return apiFetch<ApiClient>(`/api/v1/clients/${id}`);
}

/** Payload for creating / updating a client (mirrors backend CreateClientRequest). */
export interface ClientContactInput {
  name?: string | null;
  email?: string | null;
  phone?: string | null;
  designation?: string | null;
  contactType?: string | null;
}

export interface CreateClientInput {
  name: string;
  industry: string;
  logo?: string | null;
  clientType?: "NEW" | "OLD";
  contactEmail?: string | null;
  engagementManager?: string | null;
  salesManager?: string | null;
  contactName?: string | null;
  contactPhone?: string | null;
  contactDesignation?: string | null;
  contactType?: string | null;
  city?: string | null;
  country?: string | null;
  businessType?: string | null;
  notes?: string | null;
  kycDocumentName?: string | null;
  subVentures?: ClientSubVenture[];
  contacts?: ClientContactInput[];
}

/** POST /api/v1/clients — creates a client in the database. */
export async function createClient(input: CreateClientInput): Promise<ApiClient> {
  return apiFetch<ApiClient>("/api/v1/clients", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

/** PUT /api/v1/clients/{id} — updates a client (e.g. adds a sub-venture). */
export async function updateClient(
  id: string,
  input: Partial<CreateClientInput>,
): Promise<ApiClient> {
  return apiFetch<ApiClient>(`/api/v1/clients/${id}`, {
    method: "PUT",
    body: JSON.stringify(input),
  });
}

/** POST /api/v1/clients/{id}/kyc — uploads the KYC document into Documents/KYC. */
export async function uploadClientKyc(id: string, file: File): Promise<ApiClient> {
  const formData = new FormData();
  formData.append("file", file);
  return apiFetch<ApiClient>(`/api/v1/clients/${id}/kyc`, {
    method: "POST",
    body: formData,
  });
}

/** Inline-preview URL for a client's stored KYC document. */
export function getClientKycUrl(id: string): string {
  return `${API_BASE}/api/v1/clients/${id}/kyc`;
}

/** Download URL (attachment) for a client's stored KYC document. */
export function getClientKycDownloadUrl(id: string): string {
  return `${API_BASE}/api/v1/clients/${id}/kyc?download=true`;
}

/** POST /api/v1/clients/{clientId}/subventures/{subVentureId}/kyc — uploads a sub-venture's KYC. */
export async function uploadSubVentureKyc(
  clientId: string,
  subVentureId: string,
  file: File,
): Promise<ApiClient> {
  const formData = new FormData();
  formData.append("file", file);
  return apiFetch<ApiClient>(
    `/api/v1/clients/${clientId}/subventures/${subVentureId}/kyc`,
    { method: "POST", body: formData },
  );
}

/** Inline-preview URL for a sub-venture's stored KYC document. */
export function getSubVentureKycUrl(clientId: string, subVentureId: string): string {
  return `${API_BASE}/api/v1/clients/${clientId}/subventures/${subVentureId}/kyc`;
}

/** Download URL (attachment) for a sub-venture's stored KYC document. */
export function getSubVentureKycDownloadUrl(clientId: string, subVentureId: string): string {
  return `${API_BASE}/api/v1/clients/${clientId}/subventures/${subVentureId}/kyc?download=true`;
}
