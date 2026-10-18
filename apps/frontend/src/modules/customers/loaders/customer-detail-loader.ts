import { fetchClientForRoute } from "@/lib/client-route-id";
import { mapApiClient } from "@/modules/customers/api/clients";

export type CustomerDetailSearch = {
  status?: "all" | "new" | "ongoing" | "completed" | "archived" | "on_hold";
};

export function validateCustomerDetailSearch(search: Record<string, unknown>): CustomerDetailSearch {
  const validTabs = ["all", "new", "ongoing", "completed", "archived", "on_hold"] as const;
  const status = search.status as CustomerDetailSearch["status"] | undefined;
  return {
    status: status && validTabs.includes(status) ? status : undefined,
  };
}

export async function loadCustomerDetail(clientId: string) {
  if (typeof window !== "undefined") {
    try {
      const api = await fetchClientForRoute(clientId);
      if (api) return { client: mapApiClient(api) };
    } catch {
      // backend offline or genuine 404 — the component renders not-found
    }
  }
  return { client: undefined };
}
