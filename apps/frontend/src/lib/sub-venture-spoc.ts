/**
 * Resolves the SPOC / contact people stored on a sub-venture record.
 *
 * The onboarding form works against the dh-store client list (which merges mock
 * rows with locally created ones), but the authoritative SPOC data lives on the
 * `sub_ventures` rows in Postgres. This helper always prefers the API record and
 * only falls back to the local copy when the API cannot be reached or the client
 * has no API row yet.
 */
import type { ApiClientContact } from "@/lib/api/clients";
import { fetchClientForRoute } from "@/lib/client-route-id";
import { allClients } from "@/lib/dh-store";

export interface SpocContact {
  name: string;
  phone: string;
  email: string;
  designation: string;
}

function toSpoc(c: ApiClientContact | undefined): SpocContact | null {
  if (!c) return null;
  const name = (c.name ?? "").trim();
  const phone = (c.phone ?? "").trim();
  const email = (c.email ?? "").trim();
  if (!name && !phone && !email) return null;
  return { name, phone, email, designation: (c.designation ?? "").trim() };
}

function sameName(a: string, b: string): boolean {
  return a.trim().toLowerCase() === b.trim().toLowerCase();
}

function clean(contacts: (ApiClientContact | undefined)[] | undefined): SpocContact[] {
  return (contacts ?? []).map(toSpoc).filter((x): x is SpocContact => x !== null);
}

/**
 * Returns the SPOC contacts attached to `subVentureName` under `clientId`.
 *
 * The sub-venture row in Postgres is the source of truth, so it is tried first.
 * Only when that yields nothing do we widen the search — to the locally stored
 * sub-venture, then to the client-level contacts — so a sub-venture without its
 * own SPOC still exports something useful instead of a blank block. Never throws:
 * an unreachable API just means the local snapshot is used.
 */
export async function fetchSubVentureSpocs(
  clientId: string,
  subVentureName: string,
): Promise<SpocContact[]> {
  const wanted = (subVentureName ?? "").trim();

  let api: Awaited<ReturnType<typeof fetchClientForRoute>> = null;
  if (clientId) {
    try {
      api = await fetchClientForRoute(clientId);
    } catch {
      // API unavailable — the local snapshot below is the only source left.
    }
  }

  const apiSv = wanted
    ? api?.subVentures?.find((x) => sameName(x.name, wanted))
    : api?.subVentures?.[0];
  const fromApiSv = clean(apiSv?.contacts);
  if (fromApiSv.length > 0) return fromApiSv;

  const local = allClients().find((c) => c.id === clientId);
  const localSv = wanted
    ? local?.subVentures?.find((x) => sameName(x.name, wanted))
    : local?.subVentures?.[0];
  const fromLocalSv = clean(localSv?.contacts);
  if (fromLocalSv.length > 0) return fromLocalSv;

  const fromApiClient = clean(api?.contacts);
  if (fromApiClient.length > 0) return fromApiClient;

  const apiPrimary = toSpoc({
    name: api?.contactName,
    email: api?.contactEmail,
    phone: api?.contactPhone,
    designation: api?.contactDesignation,
  });
  if (apiPrimary) return [apiPrimary];

  const fromLocalClient = clean(local?.contacts);
  if (fromLocalClient.length > 0) return fromLocalClient;

  const localPrimary = toSpoc({
    name: local?.contactName,
    email: local?.contact,
    phone: local?.contactPhone,
    designation: local?.contactDesignation,
  });
  return localPrimary ? [localPrimary] : [];
}
