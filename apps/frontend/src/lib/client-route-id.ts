import { fetchClient, fetchClients, type ApiClient } from "@/lib/api/clients";
import { allClients } from "@/lib/dh-store";

const MOCK_CLIENT_ID = /^c\d+$/i;
const UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

type NamedClient = { id: string; name: string };

/**
 * Maps a mock client id (e.g. "c10") to the Postgres/API client id by name.
 * Returns null when no API match exists yet.
 */
export function resolveCustomerRouteId(
  routeOrMockId: string,
  clientName: string,
  apiClients: NamedClient[],
): string | null {
  if (UUID.test(routeOrMockId)) return routeOrMockId;

  const byName = apiClients.find((c) => c.name.toLowerCase() === clientName.trim().toLowerCase());
  if (byName) return byName.id;

  if (MOCK_CLIENT_ID.test(routeOrMockId)) {
    const mock = allClients().find((c) => c.id === routeOrMockId);
    const lookupName = mock?.name ?? clientName;
    const match = apiClients.find((c) => c.name.toLowerCase() === lookupName.toLowerCase());
    return match?.id ?? null;
  }

  return null;
}

/** GET /api/v1/clients/{id} with mock-id fallback (c1…c10 → API row by name). */
export async function fetchClientForRoute(routeId: string): Promise<ApiClient | null> {
  try {
    const direct = await fetchClient(routeId);
    if (direct) return direct;
  } catch {
    // fall through — mock ids 404 the API
  }

  if (!MOCK_CLIENT_ID.test(routeId)) return null;

  const mock = allClients().find((c) => c.id === routeId);
  if (!mock) return null;

  const list = await fetchClients(1, 100);
  return list.find((c) => c.name.toLowerCase() === mock.name.toLowerCase()) ?? null;
}
