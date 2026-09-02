import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import {
  ChevronRight,
  Mail,
  Building2,
  Phone,
  Layers,
  User,
  Pencil,
  Check,
  X,
  Search,
  StickyNote,
  Eye,
  Download,
  Info,
  FileText,
  Briefcase,
  MapPin,
  Tag,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { HealthPill, ProgressBar } from "@/components/pills";
import { KycDocPreviewModal } from "@/components/kyc-preview-modal";
import { fetchClient, mapApiClient, updateClient, formatCustomerId } from "@/lib/api/clients";
import { fetchClientForRoute } from "@/lib/client-route-id";
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
        const api = await fetchClientForRoute(params.clientId);
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
  const [kycPreviewOpen, setKycPreviewOpen] = useState(false);

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

  const handleDirectDownloadKyc = () => {
    const docName = client?.kycDocumentName || `${client?.name ? client.name.replace(/\s+/g, "_") : "Customer"}_KYC_Document.pdf`;
    const dummyContent = `KYC COMPLIANCE VERIFICATION DOCUMENT
----------------------------------------
Document Name: ${docName}
Entity Name:   ${client?.name || "Customer"}
Verification:  VERIFIED & COMPLIANT
Date Issued:   ${client?.customerSince || new Date().toLocaleDateString()}
Document Type: KYC Identification & Legal Registry
Security Hash: SHA256-KYC-${client?.id?.slice(0, 8).toUpperCase() || "VERIFIED"}
----------------------------------------
This document confirms the verified identity and KYC onboarding status for ${client?.name || "Customer"} under Pulse PMO.`;

    const blob = new Blob([dummyContent], { type: "text/plain;charset=utf-8" });
    const dlUrl = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = dlUrl;
    link.download = docName.endsWith(".txt") || docName.endsWith(".pdf") ? docName : `${docName}.txt`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(dlUrl);
    toast.success("KYC Document downloaded", { description: docName });
  };
  useEffect(() => {
    if (routeClient) {
      setClient(routeClient);
      return;
    }
    let cancelled = false;
    setClientLoading(true);
    fetchClientForRoute(clientId)
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
      subtitle={`${formatCustomerId(client.id)} · ${client.industry} · 360° Client View`}
    >
      {/* Breadcrumb */}
      <nav className="mb-3 flex items-center gap-1 text-xs text-muted-foreground">
        <Link to="/customers" className="hover:text-foreground">
          Customers
        </Link>
        <ChevronRight className="h-3 w-3" />
        <span className="text-foreground font-medium">{client.name}</span>
      </nav>

      {/* ── REDESIGNED CLIENT HEADER BANNER ── */}
      <div className="mb-4 rounded-2xl border border-slate-200/90 dark:border-border/80 bg-card p-5 shadow-sm space-y-4">
        {/* Top Tier: Identity & Stakeholders */}
        <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 pb-4 border-b border-border/60">
          {/* Left: Customer Identity & Badges */}
          <div className="flex items-start gap-3.5 min-w-0">
            <div className="flex h-13 w-13 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-primary to-info text-lg font-bold text-primary-foreground shadow-sm">
              {client.logo}
            </div>

            <div className="min-w-0 flex-1 space-y-1.5">
              <div className="flex flex-wrap items-center gap-2">
                <h1 className="text-lg font-bold tracking-tight text-foreground truncate">
                  {client.name}
                </h1>
                
                {/* Clearly Labeled Customer ID */}
                <span className="inline-flex items-center gap-1 font-mono text-[11px] font-semibold px-2 py-0.5 rounded-md bg-slate-100 dark:bg-muted border border-border text-foreground">
                  <Tag className="h-3 w-3 text-muted-foreground" />
                  {formatCustomerId(client.id)}
                </span>

                {/* Customer Type Badge */}
                <span
                  className={cn(
                    "inline-flex items-center rounded-full px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider",
                    client.clientType === "NEW"
                      ? "border border-primary/30 bg-primary/10 text-primary"
                      : "border border-slate-200 dark:border-border bg-muted/60 text-muted-foreground",
                  )}
                >
                  {client.clientType === "NEW" ? "New Customer" : "Existing Customer"}
                </span>

                {/* Active Status */}
                <span className="inline-flex items-center gap-1.5 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-2.5 py-0.5 text-[10px] font-semibold text-emerald-600 dark:text-emerald-400">
                  <span className="h-1.5 w-1.5 rounded-full bg-emerald-500 animate-pulse" />
                  Active
                </span>
              </div>

              {/* Secondary Identity Details */}
              <div className="flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
                {client.industry && (
                  <div className="flex items-center gap-1 font-medium">
                    <Building2 className="h-3.5 w-3.5 text-muted-foreground/70" />
                    <span>{client.industry}</span>
                  </div>
                )}
                {client.contact && (
                  <div className="flex items-center gap-1">
                    <Mail className="h-3.5 w-3.5 text-muted-foreground/70" />
                    <span>{client.contact}</span>
                  </div>
                )}
                {client.city && (
                  <div className="flex items-center gap-1">
                    <MapPin className="h-3.5 w-3.5 text-muted-foreground/70" />
                    <span>
                      {client.city}
                      {client.country ? `, ${client.country}` : ""}
                    </span>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right: Key Stakeholders Card (Engagement Manager & Sales Manager) */}
          <div className="flex flex-wrap sm:flex-nowrap items-center gap-2.5 shrink-0 rounded-xl bg-slate-50/90 dark:bg-muted/30 border border-slate-200/80 dark:border-border/60 p-2.5 shadow-2xs">
            {/* Engagement Manager */}
            <div className="flex items-center gap-2.5 min-w-[175px] pr-2.5 sm:border-r sm:border-slate-200/80 dark:sm:border-border/60">
              <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-blue-100 dark:bg-blue-950/60 text-blue-700 dark:text-blue-300 font-semibold text-xs shadow-2xs ring-1 ring-blue-300/60 dark:ring-blue-700/60">
                <User className="h-4 w-4" />
              </span>
              <div className="min-w-0 flex-1">
                <div className="flex items-center justify-between gap-1">
                  <span className="text-[9px] font-bold uppercase tracking-wider text-muted-foreground">
                    Engagement Manager
                  </span>
                  {(isDhanshree || hasPermission("customers.edit")) && !isSales && (
                    <button
                      type="button"
                      onClick={openEmPicker}
                      className="text-[9px] text-primary hover:underline font-semibold cursor-pointer"
                      title="Change Engagement Manager"
                    >
                      Change
                    </button>
                  )}
                </div>
                <p
                  className={cn(
                    "truncate text-xs font-semibold leading-tight mt-0.5",
                    emName !== "—" ? "text-foreground" : "text-muted-foreground font-normal italic",
                  )}
                  title={emName}
                >
                  {emName !== "—" ? emName : "Unassigned"}
                </p>
              </div>
            </div>

            {/* Sales Manager */}
            <div className="flex items-center gap-2.5 min-w-[165px] pl-1">
              <span className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-950/60 text-emerald-700 dark:text-emerald-300 font-semibold text-xs shadow-2xs ring-1 ring-emerald-300/60 dark:ring-emerald-700/60">
                <Briefcase className="h-4 w-4" />
              </span>
              <div className="min-w-0 flex-1">
                <span className="text-[9px] font-bold uppercase tracking-wider text-muted-foreground">
                  Sales Manager
                </span>
                <p
                  className={cn(
                    "truncate text-xs font-semibold leading-tight mt-0.5",
                    client.salesManager?.trim() ? "text-foreground" : "text-muted-foreground font-normal italic",
                  )}
                  title={client.salesManager || "Unassigned"}
                >
                  {client.salesManager?.trim() || "Unassigned"}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Tier: Project Portfolio Metric Filter Strip */}
        <div className="flex flex-wrap items-center justify-between gap-2.5 pt-1">
          <span className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground">
            Project Portfolio
          </span>

          <div className="flex flex-wrap items-center gap-1.5">
            {(
              [
                {
                  id: "all" as FilterTab,
                  label: "Total",
                  value: buckets.total,
                  color: "text-foreground",
                  ring: "ring-primary",
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
                  "inline-flex items-center gap-1.5 rounded-lg border px-3 py-1.5 text-center transition-all cursor-pointer",
                  filter === id
                    ? `border-transparent ring-2 ${ring} bg-primary/10 text-primary font-semibold shadow-2xs`
                    : "border-border bg-muted/30 text-muted-foreground hover:bg-muted/60 hover:text-foreground",
                )}
              >
                <span className="text-xs font-bold tabular-nums">{value}</span>
                <span className="text-[10px] uppercase tracking-wide font-medium">{label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="grid gap-4 xl:grid-cols-4 xl:items-stretch xl:min-h-[calc(100vh-15rem)]">
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
                        <span>
                          {displaySpocs[selectedSpoc].phone && displaySpocs[selectedSpoc].phone !== "—"
                            ? displaySpocs[selectedSpoc].phone.startsWith("+")
                              ? displaySpocs[selectedSpoc].phone
                              : `+91 ${displaySpocs[selectedSpoc].phone}`
                            : "—"}
                        </span>
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
                  <select
                    value={svFilter}
                    onChange={(e) => {
                      setSvFilter(e.target.value);
                      setSelectedSpoc(null);
                    }}
                    className="h-8 w-full rounded-md border border-border bg-card py-0 pl-3 pr-7 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring cursor-pointer"
                  >
                    <option value="all">Select sub-venture…</option>
                    {subVentures.map((sv) => (
                      <option key={sv.name} value={sv.name}>
                        {sv.name}
                      </option>
                    ))}
                  </select>
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
                  className="h-8 min-w-[115px] rounded-md border border-input bg-card pl-2.5 pr-8 text-xs font-medium text-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring"
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
                      <th className="w-[30%] px-5 py-3 font-medium">Project</th>
                      <th className="w-[13%] px-3 py-3 font-medium">Health</th>
                      <th className="w-[12%] px-3 py-3 font-medium">Stage</th>
                      <th className="w-[15%] px-3 py-3 font-medium">Sub-venture</th>
                      <th className="w-[15%] px-3 py-3 font-medium">Progress</th>
                      <th className="w-[15%] px-3 py-3 font-medium">PM</th>
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
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </section>

        {/* ── RIGHT SIDEBAR: Customer Info & Notes ── */}
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
                { label: "Customer ID", value: formatCustomerId(client.id), mono: true },
                { label: "Customer Name", value: client.name },
                { label: "Industry", value: client.industry },
                {
                  label: "Customer Type",
                  value: client.clientType === "NEW" ? "New Customer" : "Existing Customer",
                },
                { label: "Customer Since", value: clientSinceDate },
                { label: "Engagement Manager", value: client.engagementManager || "—" },
                { label: "Sales Manager", value: client.salesManager || "—" },
                { label: "First Project", value: firstProjectName },
                { label: "First Project ID", value: firstProjectId, mono: true },
                { label: "City", value: client.city || "—" },
                { label: "Country", value: client.country || "—" },
                { label: "Business Type", value: client.businessType || "—" },
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

              {/* KYC Document Row with View and Download */}
              <div className="px-4 py-2.5 text-xs">
                <div className="flex items-center justify-between gap-1 mb-1.5">
                  <dt className="font-medium text-muted-foreground flex items-center gap-1.5">
                    <FileText className="h-3.5 w-3.5 text-primary" /> KYC Document
                  </dt>
                  <div className="flex items-center gap-1.5">
                    <button
                      type="button"
                      onClick={() => setKycPreviewOpen(true)}
                      className="inline-flex items-center gap-1 rounded-md border border-primary/30 bg-primary/10 px-2.5 py-1 text-[11px] font-semibold text-primary hover:bg-primary/20 transition-colors cursor-pointer shadow-2xs"
                      title="Preview KYC Document"
                    >
                      <Eye className="h-3 w-3" /> View
                    </button>
                    <button
                      type="button"
                      onClick={handleDirectDownloadKyc}
                      className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-[11px] font-medium text-foreground hover:bg-accent hover:text-primary transition-colors cursor-pointer shadow-2xs"
                      title="Download KYC Document"
                      aria-label="Download KYC Document"
                    >
                      <Download className="h-3 w-3 text-primary" /> Download
                    </button>
                  </div>
                </div>
                <dd className="flex items-center justify-between text-[11px] text-muted-foreground">
                  <span className="truncate font-mono font-medium text-foreground">
                    {client.kycDocumentName || `${client.name.replace(/\s+/g, "_")}_KYC.pdf`}
                  </span>
                  <span className="shrink-0 ml-2 rounded-full border border-success/30 bg-success/10 px-1.5 py-0.2 text-[9px] font-semibold text-success uppercase">
                    Verified
                  </span>
                </dd>
              </div>
            </dl>
          </div>

          {/* Notes — per sub-venture; fills remaining right height to match Projects */}
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

      {client && (
        <KycDocPreviewModal
          open={kycPreviewOpen}
          onClose={() => setKycPreviewOpen(false)}
          fileName={client.kycDocumentName || `${client.name.replace(/\s+/g, "_")}_KYC_Document.pdf`}
          clientName={client.name}
          uploadDate={clientSinceDate}
        />
      )}
    </AppShell>
  );
}
