import { beforeEach, describe, expect, it, vi } from "vitest";
import type { ApiClient } from "@/lib/api/clients";
import type { Client } from "@/lib/mock-data";

const fetchClientForRoute = vi.fn<(id: string) => Promise<ApiClient | null>>();
const allClients = vi.fn<() => Client[]>();

vi.mock("@/lib/client-route-id", () => ({
  fetchClientForRoute: (id: string) => fetchClientForRoute(id),
}));
vi.mock("@/lib/dh-store", () => ({
  allClients: () => allClients(),
}));

const { fetchSubVentureSpocs } = await import("./sub-venture-spoc");

const apiClient = (overrides: Partial<ApiClient> = {}): ApiClient =>
  ({
    id: "guid-1",
    name: "Northwind Bank",
    industry: "Banking",
    clientType: "OLD",
    status: "Active",
    subVentures: [],
    contacts: [],
    createdAtUtc: "2026-01-01T00:00:00Z",
    ...overrides,
  }) as ApiClient;

const localClient = (overrides: Partial<Client> = {}): Client =>
  ({
    id: "c1",
    name: "Northwind Bank",
    industry: "Banking",
    logo: "NB",
    contact: "",
    subVentures: [],
    contacts: [],
    ...overrides,
  }) as Client;

beforeEach(() => {
  fetchClientForRoute.mockReset();
  allClients.mockReset();
  allClients.mockReturnValue([]);
});

describe("fetchSubVentureSpocs", () => {
  it("reads the contacts of the matching API sub-venture", async () => {
    fetchClientForRoute.mockResolvedValue(
      apiClient({
        contactName: "Client Level",
        contactPhone: "0000000000",
        subVentures: [
          { id: "sv-1", name: "Retail Banking", contacts: [{ name: "Wrong SPOC" }] },
          {
            id: "sv-2",
            name: "  digital payments ",
            contacts: [
              { name: "Raj Agarwal", phone: "9321534566", email: "raj@paymentz.com" },
              { name: "Meera Nair", phone: "9820011223", email: "meera@paymentz.com" },
            ],
          },
        ],
      }),
    );

    const spocs = await fetchSubVentureSpocs("c1", "Digital Payments");

    expect(spocs.map((s) => s.name)).toEqual(["Raj Agarwal", "Meera Nair"]);
    expect(spocs[0].phone).toBe("9321534566");
    expect(spocs[0].email).toBe("raj@paymentz.com");
  });

  it("prefers the local sub-venture over client-level contacts when the API row has none", async () => {
    fetchClientForRoute.mockResolvedValue(
      apiClient({
        contacts: [{ name: "Client Level", email: "client@acme.co" }],
        subVentures: [{ id: "sv-1", name: "Digital Payments", contacts: [] }],
      }),
    );
    allClients.mockReturnValue([
      localClient({
        subVentures: [
          { name: "Digital Payments", contacts: [{ name: "Local SPOC", email: "local@acme.co" }] },
        ],
      }),
    ]);

    const spocs = await fetchSubVentureSpocs("c1", "Digital Payments");

    expect(spocs.map((s) => s.name)).toEqual(["Local SPOC"]);
  });

  it("falls back to the local snapshot when the API is unreachable", async () => {
    fetchClientForRoute.mockRejectedValue(new Error("network down"));
    allClients.mockReturnValue([
      localClient({
        subVentures: [
          { name: "Digital Payments", contacts: [{ name: "Offline SPOC", email: "off@acme.co" }] },
        ],
      }),
    ]);

    const spocs = await fetchSubVentureSpocs("c1", "Digital Payments");

    expect(spocs.map((s) => s.name)).toEqual(["Offline SPOC"]);
  });

  it("returns an empty list when nothing is on record", async () => {
    fetchClientForRoute.mockResolvedValue(apiClient());
    allClients.mockReturnValue([localClient()]);

    expect(await fetchSubVentureSpocs("c1", "Digital Payments")).toEqual([]);
  });
});
