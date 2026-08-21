import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import {
  ChevronRight,
  ChevronDown,
  Mail,
  Building2,
  ExternalLink,
  Phone,
  Layers,
  User,
  Pencil,
  Check,
  X,
  Search,
  StickyNote,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { HealthPill, ProgressBar } from "@/components/pills";
import { fetchClient, mapApiClient, updateClient } from "@/lib/api/clients";
import {
  fetchAllEmployees,
  fetchDesignationOptions,
  fetchEmployees,
  type ApiEmployeeListItem,
} from "@/lib/api/employees";
import { categorizeClientProjects } from "@/lib/client-project-counts";
import { allClients, allProjects, useDhStore } from "@/lib/dh-store";
import { type Client, getPerson } from "@/lib/mock-data";
import { cn } from "@/lib/utils";
import { toast } from "sonner";

async function fetchEmployeesByDesignation(designationId: string): Promise<ApiEmployeeListItem[]> {
  const page = await fetchEmployees({
    designationId,
    perPage: 100,
    status: "Active",
  });
  return page.items;
}

// Small inline avatar bubble (initials)
function AvatarBubble({ name, size = 22 }: { name: string; size?: number }) {
  const initials = name
    .split(" ")
    .map((w) => w[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();
  return (
    <span
      style={{ width: size, height: size, fontSize: size * 0.38 }}
      className="inline-flex shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-primary to-info font-semibold text-primary-foreground"
    >
      {initials}
    </span>
  );
}

export const Route = createFileRoute("/customers/$clientId")({
  loader: async ({ params }) => {
    // Customer records are Postgres-only — always resolve from the API.
    // (Mock/dh-store clients are intentionally NOT used in the customer module.)
    if (typeof window !== "undefined") {
      try {
        const api = await fetchClient(params.clientId);
        if (api) return { client: mapApiClient(api) };
      } catch {
        // backend offline or genuine 404 — the component renders not-found
      }
    }
    return { client: undefined };
  },
  head: ({ loaderData }) => ({
    meta: [
      { title: `${loaderData?.client?.name ?? "Customer"} — Customers — Pulse PMO` },
      {
        name: "description",
        content: `360° customer view and project history for ${loaderData?.client?.name ?? "customer"}.`,
      },
    ],
  }),
  component: CustomerDetailPage,
});

// Format IDs as CL-XXXXXX or PR-XXXXXX
const fmtClientId = (id: string) => `CL-${id.replace(/\D/g, "").padStart(6, "0")}`;
const fmtProjectId = (id: string) => `PR-${id.replace(/\D/g, "").padStart(6, "0")}`;

type FilterTab = "all" | "new" | "ongoing" | "completed" | "archived" | "on_hold";
type HealthFilter = "all" | "healthy" | "at_risk" | "critical";

function CustomerDetailPage() {
  const { client: routeClient } = Route.useLoaderData();
  const { clientId } = Route.useParams();
  const { isDhanshree, isSales } = useRoleContext();
  const { hasPermission } = usePermissions();
  const navigate = useNavigate();

  // Live subscription to store — any client/project addition triggers re-render
  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);

  const [filter, setFilter] = useState<FilterTab>("all");
  const [healthFilter, setHealthFilter] = useState<HealthFilter>("all");
  const [selectedSpoc, setSelectedSpoc] = useState<number | null>(null);
  const [svFilter, setSvFilter] = useState<string>("all");

  useEffect(() => {
    setSvFilter("all");
    setSelectedSpoc(null);
    setHealthFilter("all");
  }, [clientId]);

  // API-backed clients (GUID ids) aren't in the dh-store — resolve lazily on the
  // client so hard loads / refreshes work even when the loader couldn't fetch.
  const [client, setClient] = useState<Client | undefined>(routeClient);
  // Start loading when the loader couldn't resolve the client (API-backed ids)
  // so hard loads show a spinner instead of a flash of "not found".
  const [clientLoading, setClientLoading] = useState(!routeClient);
  useEffect(() => {
    if (routeClient) {
      setClient(routeClient);
      return;
    }
    let cancelled = false;
    setClientLoading(true);
    fetchClient(clientId)
      .then((api) => {
        if (!cancelled) setClient(api ? mapApiClient(api) : undefined);
      })
      .catch(() => {
        if (!cancelled) setClient(undefined);
      })
      .finally(() => {
        if (!cancelled) setClientLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [routeClient, clientId]);

  // The client record is Postgres-only (GUID id). Mock projects are keyed by
  // the mock client id ("c1"…), so to keep showing the project table/counts
  // from mock data we map the API client's name back to its mock id. This is
  // an internal join key only — no mock client record is ever displayed.
  const mockClientId = useMemo(() => {
    if (!client?.name) return undefined;
    const byName = new Map(allClients().map((c) => [c.name.toLowerCase(), c.id]));
    return byName.get(client.name.toLowerCase()) ?? client.id;
  }, [client?.name, client?.id, extraCount]);

  // EM — current value from clients.EngagementManager (DB); candidates from
  // employees whose designation is "Engagement Manager" (mst_designations).
  const [emName, setEmName] = useState<string>(client?.engagementManager?.trim() || "—");
  useEffect(() => {
    setEmName(client?.engagementManager?.trim() || "—");
  }, [client?.id, client?.engagementManager]);
  const [showEMPicker, setShowEMPicker] = useState(false);
  const [emSearch, setEmSearch] = useState("");
  const [emPool, setEmPool] = useState<ApiEmployeeListItem[]>([]);
  const [emLoading, setEmLoading] = useState(false);
  const [emSaving, setEmSaving] = useState(false);

  const loadEngagementManagers = async () => {
    setEmLoading(true);
    try {
      const designations = await fetchDesignationOptions();
      const list = Array.isArray(designations) ? designations : [];
      const emDesignationIds = list
        .filter((d) => (d.name ?? "").trim().toLowerCase() === "engagement manager")
        .map((d) => d.id);

      let items: ApiEmployeeListItem[] = [];
      if (emDesignationIds.length > 0) {
        const pages = await Promise.all(
          emDesignationIds.map((designationId) => fetchEmployeesByDesignation(designationId)),
        );
        const byId = new Map<string, ApiEmployeeListItem>();
        for (const item of pages.flat()) byId.set(item.id, item);
        items = [...byId.values()];
      }

      // Always merge a full-directory filter so we never miss EMs if the
      // designationId filter is empty/stale.
      const all = await fetchAllEmployees();
      for (const e of all) {
        if ((e.designation ?? "").trim().toLowerCase() === "engagement manager") {
          items = items.some((x) => x.id === e.id) ? items : [...items, e];
        }
      }

      setEmPool(items.sort((a, b) => a.fullName.localeCompare(b.fullName)));
    } catch {
      setEmPool([]);
      toast.error("Could not load Engagement Managers");
    } finally {
      setEmLoading(false);
    }
  };

  useEffect(() => {
    void loadEngagementManagers();
  }, []);

  const filteredEmPool = useMemo(() => {
    const q = emSearch.trim().toLowerCase();
    if (!q) return emPool;
    return emPool.filter(
      (p) =>
        p.fullName.toLowerCase().includes(q) ||
        (p.designation ?? "").toLowerCase().includes(q) ||
        (p.workEmail ?? "").toLowerCase().includes(q) ||
        (p.employeeCode ?? "").toLowerCase().includes(q),
    );
  }, [emPool, emSearch]);

  const openEmPicker = () => {
    setEmSearch("");
    setShowEMPicker(true);
    void loadEngagementManagers();
  };

  const changeEngagementManager = async (employee: ApiEmployeeListItem) => {
    if (!client || emSaving) return;
    setEmSaving(true);
    try {
      const updated = await updateClient(client.id, {
        engagementManager: employee.fullName,
      });
      setClient(mapApiClient(updated));
      setEmName(updated.engagementManager?.trim() || employee.fullName);
      setShowEMPicker(false);
      setEmSearch("");
      toast.success(`Engagement Manager set to ${employee.fullName}`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not update Engagement Manager");
    } finally {
      setEmSaving(false);
    }
  };

  // Re-compute whenever extraCount changes (reactive to new clients/projects)
  const allProj = useMemo(
    () => allProjects().filter((p) => p.clientId === mockClientId),
    [mockClientId, extraCount],
  );

  if (!isDhanshree && !hasPermission("customers.view")) return <Navigate to="/customers" />;

  // Loading / not-found states (after all hooks).
  if (clientLoading) {
    return (
      <AppShell title="Customer" subtitle="Loading customer…">
        <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-12 text-center">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
          <p className="text-sm text-muted-foreground">Loading customer details…</p>
        </div>
      </AppShell>
    );
  }
  if (!client) {
    return (
      <AppShell title="Customer not found" subtitle="We couldn't find this customer">
        <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-12 text-center">
          <Building2 className="h-8 w-8 text-muted-foreground" />
          <p className="text-sm text-muted-foreground">
            This customer doesn't exist or is no longer available.
          </p>
          <Link
            to="/customers"
            className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors"
          >
            Back to Customers
          </Link>
        </div>
      </AppShell>
    );
  }

  // Categorise — mutually exclusive buckets; Total = sum of the five.
  const buckets = categorizeClientProjects(allProj);
  const newProjs = buckets.new;
  const ongoingProjs = buckets.ongoing;
  const completedProjs = buckets.completed;
  const onHoldProjs = buckets.onHold;
  const archivedProjs = buckets.archived;

  // Customer Since comes from clients.CustomerSince (set to today on create).
  const clientSinceDate = client.customerSince
    ? new Date(`${client.customerSince}T00:00:00`).toLocaleDateString()
    : "—";
  const allDates = allProj
    .map((p) => p.startDate)
    .filter(Boolean)
    .sort();
  const firstProject = allProj.find((p) => p.startDate === allDates[0]);
  const firstProjectName = firstProject?.name ?? "—";
  const firstProjectId = firstProject ? fmtProjectId(firstProject.id) : "—";

  // Sub-venture list from client. SPOC contacts are per sub-venture — only
  // show them after a specific sub-venture is selected.
  const subVentures = client.subVentures ?? [];
  const activeSubVenture =
    svFilter !== "all" ? subVentures.find((sv) => sv.name === svFilter) : undefined;
  const displaySpocs = activeSubVenture
    ? (activeSubVenture.contacts ?? []).map((c) => ({
        name: c.name,
        email: c.email,
        phone: c.phone ?? "—",
        designation: c.designation ?? "—",
        type: c.contactType ?? "Primary",
      }))
    : [];

  // Notes are per sub-venture (captured at onboarding). Legacy client.notes is a fallback.
  const displayNotes = activeSubVenture
    ? (activeSubVenture.notes?.trim() || client.notes?.trim() || "")
    : "";
  const notesTitle = activeSubVenture
    ? `Notes — ${activeSubVenture.name}`
    : "Notes";
  const notesEmptyMessage = activeSubVenture
    ? "No notes captured for this sub-venture yet."
    : subVentures.length > 0
      ? "Select a sub-venture to view its onboarding notes."
      : "No sub-ventures on file. Notes are captured per sub-venture during onboarding.";

  // Filter pool: status tab + sub-venture
  const poolByTab: Record<FilterTab, typeof allProj> = {
    all: allProj,
    new: newProjs,
    ongoing: ongoingProjs,
    completed: completedProjs,
    archived: archivedProjs,
    on_hold: onHoldProjs,
  };
  const pool = poolByTab[filter]
    .filter((p) => svFilter === "all" || p.subVenture === svFilter)
    .filter((p) => {
      if (healthFilter === "all") return true;
      if (healthFilter === "healthy") return p.health === "green";
      if (healthFilter === "at_risk") return p.health === "amber";
      return p.health === "red"; // critical
    });

  return (
    <AppShell
      title={client.name}
      subtitle={`${fmtClientId(client.id)} · ${client.industry} · 360° Client View`}
    >
      {/* Breadcrumb */}
      <nav className="mb-4 flex items-center gap-1 text-xs text-muted-foreground">
        <Link to="/customers" className="hover:text-foreground">
          Customers
        </Link>
        <ChevronRight className="h-3 w-3" />
        <span className="text-foreground font-medium">{client.name}</span>
      </nav>

      {/* ── CLIENT HEADER BANNER ── */}
      <div className="mb-4 rounded-xl border border-border bg-card shadow-sm">
        <div className="flex flex-wrap items-center gap-4 p-5">
          {/* Logo */}
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-info text-lg font-bold text-primary-foreground">
            {client.logo}
          </div>

          {/* Identity */}
          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center gap-2">
              <h1 className="text-base font-bold text-foreground">{client.name}</h1>
              <span
                className={cn(
                  "inline-flex rounded-full border px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide",
                  client.clientType === "NEW"
                    ? "border-primary/30 bg-primary/10 text-primary"
                    : "border-success/30 bg-success/10 text-success",
                )}
              >
                {client.clientType === "NEW" ? "New Client" : "Existing Client"}
              </span>
              <span className="inline-flex rounded-full border border-success/30 bg-success/10 px-2 py-0.5 text-[10px] font-semibold text-success">
                Active
              </span>

              {/* EM Name + Change button */}
              {(isDhanshree || hasPermission("customers.edit")) && (
                <div className="flex items-center gap-1.5">
                  <span className="inline-flex items-center gap-1.5 rounded-full border border-info/30 bg-info/10 px-2.5 py-0.5 text-[11px] font-semibold text-info">
                    <User className="h-3 w-3" />
                    {emName !== "—" ? emName : "No EM assigned"}
                  </span>
                  {!isSales && (
                    <button
                      type="button"
                      onClick={openEmPicker}
                      className="inline-flex items-center gap-1 rounded-md border border-border bg-card px-2 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
                    >
                      <Pencil className="h-2.5 w-2.5" /> Change EM
                    </button>
                  )}
                </div>
              )}
            </div>
            <div className="mt-1 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
              <span className="font-mono font-semibold text-foreground">
                {fmtClientId(client.id)}
              </span>
              <span>·</span>
              <span>{client.industry}</span>
              <span>·</span>
              <span className="flex items-center gap-1">
                <Mail className="h-3 w-3" />
                {client.contact}
              </span>
            </div>
          </div>

          {/* Clickable stat cards — act as filter buttons */}
          <div className="flex flex-wrap gap-2">
            {(
              [
                {
                  id: "all" as FilterTab,
                  label: "Total",
                  value: buckets.total,
                  color: "text-foreground",
                  ring: "ring-border",
                },
                {
                  id: "new" as FilterTab,
                  label: "New",
                  value: newProjs.length,
                  color: "text-primary",
                  ring: "ring-primary",
                },
                {
                  id: "ongoing" as FilterTab,
                  label: "Ongoing",
                  value: ongoingProjs.length,
                  color: "text-info",
                  ring: "ring-info",
                },
                {
                  id: "completed" as FilterTab,
                  label: "Completed",
                  value: completedProjs.length,
                  color: "text-success",
                  ring: "ring-success",
                },
                {
                  id: "on_hold" as FilterTab,
                  label: "On Hold",
                  value: onHoldProjs.length,
                  color: "text-warning-foreground",
                  ring: "ring-warning",
                },
                {
                  id: "archived" as FilterTab,
                  label: "Archived",
                  value: archivedProjs.length,
                  color: "text-muted-foreground",
                  ring: "ring-muted-foreground",
                },
              ] as { id: FilterTab; label: string; value: number; color: string; ring: string }[]
            ).map(({ id, label, value, color, ring }) => (
              <button
                key={id}
                onClick={() => setFilter(id)}
                className={cn(
                  "rounded-lg border bg-muted/30 px-4 py-2 text-center min-w-[72px] transition-all hover:bg-muted/60",
                  filter === id ? `border-transparent ring-2 ${ring} bg-muted/50` : "border-border",
                )}
              >
                <div className={cn("text-xl font-bold tabular-nums", color)}>{value}</div>
                <div className="text-[10px] text-muted-foreground font-medium uppercase tracking-wide">
                  {label}
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="grid gap-4 xl:grid-cols-4 xl:items-stretch xl:min-h-[calc(100vh-15rem)]">
        {/* ── LEFT SIDEBAR ── */}
        <aside className="xl:col-span-1 flex min-h-0 flex-col gap-3">
          {/* Customer Information */}
          <div className="shrink-0 rounded-xl border border-border bg-card shadow-sm">
            <div className="border-b border-border px-4 py-3">
              <h2 className="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                <Building2 className="h-3.5 w-3.5" /> Customer Information
              </h2>
            </div>
            <dl className="divide-y divide-border">
              {[
                { label: "Customer ID", value: fmtClientId(client.id), mono: true },
                { label: "Customer Name", value: client.name },
                { label: "Industry", value: client.industry },
                {
                  label: "Customer Type",
                  value: client.clientType === "NEW" ? "New Customer" : "Existing Customer",
                },
                { label: "Customer Since", value: clientSinceDate },
                { label: "First Project", value: firstProjectName },
                { label: "First Project ID", value: firstProjectId, mono: true },
                { label: "City", value: client.city || "—" },
                { label: "Country", value: client.country || "—" },
                { label: "Business Type", value: client.businessType || "—" },
                { label: "KYC Document", value: client.kycDocumentName || "—" },
              ].map(({ label, value, mono }) => (
                <div key={label} className="grid grid-cols-2 gap-2 px-4 py-2.5 text-xs">
                  <dt className="font-medium text-muted-foreground">{label}</dt>
                  <dd
                    className={cn(
                      "truncate text-right font-medium",
                      mono && "font-mono text-foreground",
                    )}
                  >
                    {value}
                  </dd>
                </div>
              ))}
            </dl>
          </div>

          {/* Notes — per sub-venture; fills remaining left height to match Projects */}
          <div className="flex min-h-[220px] flex-1 flex-col overflow-hidden rounded-xl border border-border bg-card shadow-sm">
            <div className="shrink-0 border-b border-border px-4 py-3">
              <h2 className="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                <StickyNote className="h-3.5 w-3.5" /> {notesTitle}
              </h2>
            </div>
            <div className="min-h-0 flex-1 overflow-y-auto p-4">
              {displayNotes ? (
                <p className="whitespace-pre-wrap text-[13px] leading-relaxed text-foreground">
                  {displayNotes}
                </p>
              ) : (
                <p className="text-xs leading-relaxed text-muted-foreground">{notesEmptyMessage}</p>
              )}
            </div>
          </div>
        </aside>

        {/* ── MAIN PROJECTS SECTION ── */}
        <section className="xl:col-span-3 flex min-h-0 flex-col gap-3">
          {/* ── SPOC Contacts + Sub-venture filter — side by side ── */}
          <div className="flex shrink-0 items-stretch gap-3">
            {/* SPOC Contacts — follows the sub-venture filter */}
            <div className="min-w-0 flex-1 rounded-xl border border-border bg-card shadow-sm">
              <div className="border-b border-border px-4 py-3">
                <h3 className="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                  <User className="h-3.5 w-3.5" />
                  {activeSubVenture ? `SPOC Contacts — ${activeSubVenture.name}` : "SPOC Contacts"}
                </h3>
              </div>
              <div className="p-3">
                {displaySpocs.length > 0 ? (
                  <div className="flex flex-wrap gap-1.5">
                    {displaySpocs.map((spoc, i) => (
                      <button
                        key={i}
                        onClick={() => setSelectedSpoc(selectedSpoc === i ? null : i)}
                        className={cn(
                          "inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1 text-xs font-medium transition-all",
                          selectedSpoc === i
                            ? "border-primary bg-primary/10 text-primary"
                            : "border-border bg-muted/30 text-muted-foreground hover:bg-muted/60 hover:text-foreground",
                        )}
                      >
                        <User className="h-3 w-3" />
                        SPOC {i + 1} — {spoc.name}
                      </button>
                    ))}
                  </div>
                ) : (
                  <p className="text-xs text-muted-foreground">
                    {activeSubVenture
                      ? "No SPOC contacts for this sub-venture yet."
                      : subVentures.length > 0
                        ? "Select a sub-venture to view SPOC contacts."
                        : "No sub-ventures on file. SPOC contacts are tied to a sub-venture."}
                  </p>
                )}

                {/* SPOC detail card */}
                {selectedSpoc !== null && displaySpocs[selectedSpoc] && (
                  <div className="relative mt-3 rounded-lg border border-primary/20 bg-primary/5 p-3 text-xs">
                    <button
                      onClick={() => setSelectedSpoc(null)}
                      className="absolute right-2 top-2 text-muted-foreground hover:text-foreground"
                    >
                      <X className="h-3 w-3" />
                    </button>
                    <div className="mb-2 flex items-center gap-2">
                      <AvatarBubble name={displaySpocs[selectedSpoc].name} size={28} />
                      <div>
                        <div className="font-semibold text-foreground">
                          {displaySpocs[selectedSpoc].name}
                        </div>
                        <div className="text-[10px] text-muted-foreground">
                          {displaySpocs[selectedSpoc].designation} ·{" "}
                          {displaySpocs[selectedSpoc].type}
                        </div>
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-x-4 gap-y-1">
                      <div className="flex items-center gap-1 text-muted-foreground">
                        <Mail className="h-3 w-3" />
                        <span className="truncate">{displaySpocs[selectedSpoc].email}</span>
                      </div>
                      <div className="flex items-center gap-1 text-muted-foreground">
                        <Phone className="h-3 w-3" />
                        <span>{displaySpocs[selectedSpoc].phone}</span>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>

            {/* Sub-venture filter — SPOC list + notes depend on this selection */}
            <div className="w-72 shrink-0 rounded-xl border border-border bg-card shadow-sm">
              <div className="border-b border-border px-4 py-3">
                <h3 className="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                  <Layers className="h-3.5 w-3.5" /> Filter by Sub-venture
                </h3>
              </div>
              <div className="space-y-2 p-3">
                {subVentures.length > 0 ? (
                  <div className="relative">
                    <select
                      value={svFilter}
                      onChange={(e) => {
                        setSvFilter(e.target.value);
                        setSelectedSpoc(null);
                      }}
                      className="h-8 w-full appearance-none rounded-md border border-border bg-card py-0 pl-3 pr-7 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
                    >
                      <option value="all">Select sub-venture…</option>
                      {subVentures.map((sv) => (
                        <option key={sv.name} value={sv.name}>
                          {sv.name}
                        </option>
                      ))}
                    </select>
                    <ChevronDown className="pointer-events-none absolute right-2 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
                  </div>
                ) : (
                  <p className="text-xs text-muted-foreground">No sub-ventures for this client.</p>
                )}
                {svFilter !== "all" && (
                  <div className="flex items-center justify-between">
                    <span className="max-w-[160px] truncate text-[11px] text-muted-foreground">
                      <span className="font-medium text-foreground">{pool.length}</span> project
                      {pool.length !== 1 ? "s" : ""}
                    </span>
                    <button
                      onClick={() => {
                        setSvFilter("all");
                        setSelectedSpoc(null);
                      }}
                      className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2 py-0.5 text-[10px] text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                    >
                      <X className="h-2.5 w-2.5" /> Clear
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>

          <div className="flex min-h-0 flex-1 flex-col overflow-hidden rounded-xl border border-border bg-card shadow-sm">
            <header className="flex shrink-0 items-center justify-between gap-3 border-b border-border px-5 py-3">
              <div className="min-w-0">
                <h3 className="text-sm font-semibold">
                  {filter === "all"
                    ? "All Projects"
                    : filter === "on_hold"
                      ? "On Hold Projects"
                      : `${filter.charAt(0).toUpperCase() + filter.slice(1)} Projects`}
                </h3>
                <p className="mt-0.5 text-[11px] text-muted-foreground">
                  {pool.length} project{pool.length !== 1 ? "s" : ""}
                  {healthFilter !== "all" &&
                    ` · ${
                      healthFilter === "healthy"
                        ? "Healthy"
                        : healthFilter === "at_risk"
                          ? "At Risk"
                          : "Critical"
                    }`}
                </p>
              </div>
              <label className="flex shrink-0 items-center gap-2 text-[11px] text-muted-foreground">
                <span className="hidden sm:inline">Health</span>
                <select
                  value={healthFilter}
                  onChange={(e) => setHealthFilter(e.target.value as HealthFilter)}
                  className="h-8 rounded-md border border-input bg-card px-2 text-xs font-medium text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring"
                  onClick={(e) => e.stopPropagation()}
                >
                  <option value="all">All</option>
                  <option value="healthy">Healthy</option>
                  <option value="at_risk">At Risk</option>
                  <option value="critical">Critical</option>
                </select>
              </label>
            </header>

            {pool.length === 0 ? (
              <div className="flex flex-1 flex-col items-center justify-center gap-2 py-12 text-center">
                <Layers className="h-8 w-8 text-muted-foreground/40" />
                <p className="text-sm text-muted-foreground">No projects in this category</p>
              </div>
            ) : (
              <div className="min-h-0 flex-1 overflow-auto">
                <table className="w-full min-w-[760px] table-fixed text-sm">
                  <thead className="sticky top-0 z-[1]">
                    <tr className="border-b border-border bg-muted/90 text-left text-[11px] font-medium uppercase tracking-[0.04em] text-muted-foreground backdrop-blur-sm">
                      <th className="w-[28%] px-5 py-3 font-medium">Project</th>
                      <th className="w-[12%] px-3 py-3 font-medium">Health</th>
                      <th className="w-[11%] px-3 py-3 font-medium">Stage</th>
                      <th className="w-[14%] px-3 py-3 font-medium">Sub-venture</th>
                      <th className="w-[14%] px-3 py-3 font-medium">Progress</th>
                      <th className="w-[13%] px-3 py-3 font-medium">PM</th>
                      <th className="w-[8%] px-3 py-3 text-right font-medium"> </th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border/70">
                    {pool.map((p) => {
                      const pm = getPerson(p.pmId);
                      const category =
                        p.status === "archived"
                          ? "Archived"
                          : p.status === "completed"
                            ? "Completed"
                            : p.status === "on_hold"
                              ? "On Hold"
                              : p.status === "ongoing" && p.progress === 0
                                ? "New"
                                : "Ongoing";
                      const startLabel = p.startDate
                        ? new Date(p.startDate).toLocaleDateString("en-IN", {
                            day: "2-digit",
                            month: "short",
                            year: "numeric",
                          })
                        : null;
                      const endLabel = p.endDate
                        ? new Date(p.endDate).toLocaleDateString("en-IN", {
                            day: "2-digit",
                            month: "short",
                            year: "numeric",
                          })
                        : null;

                      return (
                        <tr
                          key={p.id}
                          className="group cursor-pointer transition-colors hover:bg-muted/30"
                          onClick={() =>
                            navigate({ to: "/projects/$projectId", params: { projectId: p.id } })
                          }
                        >
                          <td className="px-5 py-3.5 align-middle">
                            <div className="min-w-0">
                              <div className="truncate text-[13px] font-semibold tracking-tight text-foreground">
                                {p.name}
                              </div>
                              <div className="mt-0.5 flex flex-wrap items-center gap-x-2 gap-y-0.5 text-[11px] text-muted-foreground">
                                <span className="font-mono tabular-nums">{fmtProjectId(p.id)}</span>
                                {(startLabel || endLabel) && (
                                  <>
                                    <span className="text-border">·</span>
                                    <span className="tabular-nums">
                                      {startLabel ?? "—"} → {endLabel ?? "—"}
                                    </span>
                                  </>
                                )}
                              </div>
                            </div>
                          </td>
                          <td className="px-3 py-3.5 align-middle">
                            <HealthPill status={p.health} />
                          </td>
                          <td className="px-3 py-3.5 align-middle">
                            <span
                              className={cn(
                                "inline-flex items-center rounded-full border px-2 py-0.5 text-[10px] font-semibold",
                                category === "New" &&
                                  "border-primary/30 bg-primary/10 text-primary",
                                category === "Ongoing" && "border-info/30 bg-info/10 text-info",
                                category === "Completed" &&
                                  "border-success/30 bg-success/10 text-success",
                                category === "On Hold" &&
                                  "border-warning/30 bg-warning/10 text-warning-foreground",
                                category === "Archived" &&
                                  "border-border bg-muted text-muted-foreground",
                              )}
                            >
                              {category}
                            </span>
                          </td>
                          <td className="px-3 py-3.5 align-middle">
                            {p.subVenture ? (
                              <span
                                className="block truncate text-[12px] text-foreground"
                                title={p.subVenture}
                              >
                                {p.subVenture}
                              </span>
                            ) : (
                              <span className="text-[12px] text-muted-foreground">—</span>
                            )}
                          </td>
                          <td className="px-3 py-3.5 align-middle">
                            <div className="flex items-center gap-2">
                              <ProgressBar value={p.progress} className="h-1.5 min-w-0 flex-1" />
                              <span className="w-8 shrink-0 text-right text-[11px] font-medium tabular-nums text-muted-foreground">
                                {p.progress}%
                              </span>
                            </div>
                          </td>
                          <td className="px-3 py-3.5 align-middle">
                            {pm ? (
                              <div className="flex min-w-0 items-center gap-2">
                                <AvatarBubble name={pm.name} size={22} />
                                <span className="truncate text-[12px] font-medium">{pm.name}</span>
                              </div>
                            ) : (
                              <span className="text-[12px] text-muted-foreground">Unassigned</span>
                            )}
                          </td>
                          <td
                            className="px-3 py-3.5 text-right align-middle"
                            onClick={(e) => e.stopPropagation()}
                          >
                            <Link
                              to="/projects/$projectId"
                              params={{ projectId: p.id }}
                              className="inline-flex items-center gap-1 rounded-lg border border-border/80 bg-card px-2.5 py-1.5 text-[11px] font-medium text-muted-foreground opacity-80 transition-all hover:border-border hover:bg-accent hover:text-foreground group-hover:opacity-100"
                            >
                              Open
                              <ExternalLink className="h-3 w-3" />
                            </Link>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </section>
      </div>

      {showEMPicker && (
        <div className="fixed inset-0 z-[80] flex items-center justify-center p-4">
          <button
            type="button"
            aria-label="Close"
            className="absolute inset-0 bg-black/40"
            onClick={() => {
              if (!emSaving) {
                setShowEMPicker(false);
                setEmSearch("");
              }
            }}
          />
          <div
            role="dialog"
            aria-modal="true"
            aria-labelledby="change-em-title"
            className="relative z-[81] flex w-full max-w-md flex-col rounded-xl border border-border bg-card shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between border-b border-border px-4 py-3">
              <div>
                <h2 id="change-em-title" className="text-sm font-semibold text-foreground">
                  Change Engagement Manager
                </h2>
                <p className="text-[11px] text-muted-foreground">
                  {emLoading
                    ? "Loading from directory…"
                    : `${filteredEmPool.length} of ${emPool.length} Engagement Manager${emPool.length === 1 ? "" : "s"}`}
                </p>
              </div>
              <button
                type="button"
                disabled={emSaving}
                onClick={() => {
                  setShowEMPicker(false);
                  setEmSearch("");
                }}
                className="rounded-md p-1.5 text-muted-foreground hover:bg-accent disabled:opacity-50"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <div className="border-b border-border px-4 py-3">
              <div className="relative">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
                <input
                  value={emSearch}
                  onChange={(e) => setEmSearch(e.target.value)}
                  placeholder="Search by name, email, or code…"
                  autoFocus
                  autoComplete="off"
                  className="h-9 w-full rounded-md border border-input bg-background pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                />
              </div>
            </div>

            <ul className="max-h-[min(360px,50vh)] overflow-y-auto px-2 py-2">
              {emLoading ? (
                <li className="px-3 py-8 text-center text-sm text-muted-foreground">Loading…</li>
              ) : filteredEmPool.length === 0 ? (
                <li className="px-3 py-8 text-center text-sm text-muted-foreground">
                  {emPool.length === 0
                    ? "No Engagement Managers found in the database."
                    : "No match for your search."}
                </li>
              ) : (
                filteredEmPool.map((p) => {
                  const selected = emName === p.fullName;
                  return (
                    <li key={p.id}>
                      <button
                        type="button"
                        disabled={emSaving}
                        onClick={() => void changeEngagementManager(p)}
                        className={cn(
                          "flex w-full items-center gap-3 rounded-md px-3 py-2.5 text-left text-sm transition-colors hover:bg-accent/50 disabled:opacity-50",
                          selected && "bg-primary/5",
                        )}
                      >
                        <AvatarBubble name={p.fullName} size={32} />
                        <div className="min-w-0 flex-1">
                          <div className="font-medium text-foreground truncate">{p.fullName}</div>
                          <div className="text-[11px] text-muted-foreground truncate">
                            {p.designation ?? "Engagement Manager"}
                            {p.workEmail ? ` · ${p.workEmail}` : ""}
                          </div>
                        </div>
                        {selected ? <Check className="h-4 w-4 shrink-0 text-primary" /> : null}
                      </button>
                    </li>
                  );
                })
              )}
            </ul>
          </div>
        </div>
      )}
    </AppShell>
  );
}
