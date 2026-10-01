import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState } from "react";
import {
  ChevronRight,
  Mail,
  Building2,
  Phone,
  Layers,
  User,
  UserRound,
  Pencil,
  Check,
  X,
  Search,
  StickyNote,
  Eye,
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
import { fetchClient, mapApiClient, updateClient, formatCustomerId, getSubVentureKycUrl } from "@/lib/api/clients";
import { fetchSalesManagers, filterSalesManagers } from "@/lib/sales-managers";
import { fetchClientForRoute } from "@/lib/client-route-id";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import {
  fetchAllEmployees,
  fetchDesignationOptions,
  fetchEmployees,
  type ApiEmployeeListItem,
} from "@/lib/api/employees";
import { categorizeClientProjects } from "@/lib/client-project-counts";
import { fetchProjects, mapApiProjectToProject } from "@/lib/api/projects";
import { type Client, type Project } from "@/lib/mock-data";
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

type FilterTab = "all" | "new" | "ongoing" | "completed" | "archived" | "on_hold";
type HealthFilter = "all" | "healthy" | "at_risk" | "critical";

type CustomerDetailSearch = {
  status?: FilterTab;
};

export const Route = createFileRoute("/customers/$clientId")({
  validateSearch: (search: Record<string, unknown>): CustomerDetailSearch => {
    const validTabs: FilterTab[] = ["all", "new", "ongoing", "completed", "archived", "on_hold"];
    const status = search.status as FilterTab | undefined;
    return {
      status: status && validTabs.includes(status) ? status : undefined,
    };
  },
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

function CustomerDetailPage() {
  const { client: routeClient } = Route.useLoaderData();
  const { clientId } = Route.useParams();
  const searchParams = Route.useSearch();
  const { isDhanshree, isSales, isAdmin } = useRoleContext();
  const { hasPermission } = usePermissions();
  const navigate = useNavigate();

  const [filter, setFilter] = useState<FilterTab>(searchParams.status || "all");
  const [healthFilter, setHealthFilter] = useState<HealthFilter>("all");
  const [selectedSpoc, setSelectedSpoc] = useState<number | null>(null);
  const [svFilter, setSvFilter] = useState<string>("all");
  const [kycPreviewOpen, setKycPreviewOpen] = useState(false);

  useEffect(() => {
    if (searchParams.status) {
      setFilter(searchParams.status);
    }
  }, [searchParams.status]);

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

  // Projects for this customer come from the projects API (client id + sub-venture name).
  const [clientProjects, setClientProjects] = useState<Project[]>([]);
  useEffect(() => {
    if (!client?.id) {
      setClientProjects([]);
      return;
    }
    let cancelled = false;
    fetchProjects({ clientId: client.id, perPage: 500 })
      .then((page) => {
        if (cancelled) return;
        setClientProjects((page.items ?? []).map((item) => mapApiProjectToProject(item) as Project));
      })
      .catch(() => {
        if (!cancelled) setClientProjects([]);
      });
    return () => {
      cancelled = true;
    };
  }, [client?.id]);

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

  // Sales Manager — current value from clients.SalesManager (DB); candidates from
  // employees whose department is Functional - Sales.
  const [smName, setSmName] = useState<string>(client?.salesManager?.trim() || "—");
  useEffect(() => {
    setSmName(client?.salesManager?.trim() || "—");
  }, [client?.id, client?.salesManager]);
  const [showSMPicker, setShowSMPicker] = useState(false);
  const [smSearch, setSmSearch] = useState("");
  const [smPool, setSmPool] = useState<ApiEmployeeListItem[]>([]);
  const [smLoading, setSmLoading] = useState(false);
  const [smSaving, setSmSaving] = useState(false);

  useEffect(() => {
    if (!showEMPicker && !showSMPicker) return;
    const html = document.documentElement;
    const body = document.body;
    const prevHtmlOverflow = html.style.overflow;
    const prevBodyOverflow = body.style.overflow;
    const scrollX = window.scrollX;
    const scrollY = window.scrollY;
    html.style.overflow = "hidden";
    body.style.overflow = "hidden";

    const pinPage = () => {
      if (window.scrollX !== scrollX || window.scrollY !== scrollY) {
        window.scrollTo(scrollX, scrollY);
      }
    };
    const blockBackgroundScroll = (event: Event) => {
      const target = event.target;
      if (target instanceof Element && target.closest("[data-manager-scroll]")) return;
      event.preventDefault();
    };
    window.addEventListener("scroll", pinPage);
    window.addEventListener("wheel", blockBackgroundScroll, { passive: false });
    window.addEventListener("touchmove", blockBackgroundScroll, { passive: false });

    return () => {
      html.style.overflow = prevHtmlOverflow;
      body.style.overflow = prevBodyOverflow;
      window.removeEventListener("scroll", pinPage);
      window.removeEventListener("wheel", blockBackgroundScroll);
      window.removeEventListener("touchmove", blockBackgroundScroll);
    };
  }, [showEMPicker, showSMPicker]);

  const loadSalesManagers = async () => {
    setSmLoading(true);
    try {
      const items = await fetchSalesManagers();
      setSmPool(items);
    } catch {
      setSmPool([]);
      toast.error("Could not load Sales Managers");
    } finally {
      setSmLoading(false);
    }
  };

  useEffect(() => {
    void loadSalesManagers();
  }, []);

  const filteredSmPool = useMemo(() => {
    return filterSalesManagers(smPool, smSearch);
  }, [smPool, smSearch]);

  const openSmPicker = () => {
    setSmSearch("");
    setShowSMPicker(true);
    void loadSalesManagers();
  };

  const changeSalesManager = async (employee: ApiEmployeeListItem) => {
    if (!client || smSaving) return;
    setSmSaving(true);
    try {
      const updated = await updateClient(client.id, {
        salesManager: employee.fullName,
      });
      setClient(mapApiClient(updated));
      setSmName(updated.salesManager?.trim() || employee.fullName);
      setShowSMPicker(false);
      setSmSearch("");
      toast.success(`Sales Manager set to ${employee.fullName}`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Could not update Sales Manager");
    } finally {
      setSmSaving(false);
    }
  };

  const allProj = clientProjects;

  if (!isAdmin && !isDhanshree && !hasPermission("customers.view")) return <Navigate to="/customers" />;

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

  // KYC is stored per sub-venture. It's only meaningful once a sub-venture is
  // selected; the row then reflects that sub-venture's own document.
  const activeKycHasFile = Boolean(activeSubVenture?.id && activeSubVenture?.kycDocumentPath);
  const activeKycName =
    activeSubVenture?.kycDocumentName ||
    (activeSubVenture ? `${activeSubVenture.name.replace(/\s+/g, "_")}_KYC.pdf` : "");
  const activeKycPreviewUrl =
    activeKycHasFile && client.id && activeSubVenture?.id
      ? getSubVentureKycUrl(client.id, activeSubVenture.id)
      : undefined;
  const displaySpocs = activeSubVenture
    ? (activeSubVenture.contacts ?? []).map((c) => ({
        name: c.name,
        email: c.email?.trim() || "",
        phone: c.phone ?? "—",
        phoneCode: c.phoneCode,
        designation: c.designation ?? "—",
        type: c.contactType ?? "Primary",
      }))
    : (client.groupSpocName || client.contactName)
      ? [
          {
            name: client.groupSpocName || client.contactName || "",
            // Group SPOC has no email — Company step only stores name + phone.
            email: "",
            phone: client.groupSpocContact || client.contactPhone || "—",
            phoneCode: undefined as string | undefined,
            designation: "Group SPOC",
            type: "Group SPOC",
          },
        ]
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
      <div className="mb-4 overflow-hidden rounded-2xl border border-slate-300/90 dark:border-slate-700/80 bg-gradient-to-b from-slate-100/95 via-slate-100 to-blue-50/40 dark:from-slate-900 dark:via-slate-900/95 dark:to-slate-950 p-5 shadow-[0_4px_16px_-4px_rgba(15,23,42,0.12),0_2px_6px_rgba(15,23,42,0.06)] space-y-4">
        {/* Top Tier: Identity & Stakeholders */}
        <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4 pb-4 border-b border-border/60">
          {/* Left: Customer Identity & Badges */}
          <div className="flex items-start gap-3.5 min-w-0">
            <div className="flex h-12 w-12 shrink-0 items-center justify-center overflow-hidden rounded-2xl bg-gradient-to-br from-primary to-info text-sm font-bold text-primary-foreground shadow-sm">
              {client.logo}
            </div>

            <div className="min-w-0 flex-1 space-y-1.5">
              <div className="flex flex-wrap items-center gap-2">
                <h1 className="text-lg font-bold tracking-tight text-foreground truncate">
                  {client.name}
                </h1>
                
                {/* Clearly Labeled Customer ID */}
                <span className="inline-flex items-center gap-1 font-mono text-[11px] font-semibold px-2 py-0.5 rounded-md bg-white dark:bg-slate-800 border border-border text-foreground shadow-2xs">
                  <Tag className="h-3 w-3 text-muted-foreground" />
                  {formatCustomerId(client.id)}
                </span>

                {/* Customer Type Badge */}
                <span
                  className={cn(
                    "inline-flex items-center rounded-full px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wider",
                    client.clientType === "NEW"
                      ? "border border-primary/30 bg-primary/10 text-primary"
                      : "border border-slate-200 dark:border-border bg-white/80 dark:bg-muted/60 text-muted-foreground",
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

          {/* Right: Key Stakeholders (Engagement Manager & Sales Manager) - Side-by-Side Card */}
          <div className="flex items-center gap-4 rounded-2xl border border-slate-200/90 bg-white dark:bg-card dark:border-border/80 px-4 py-2.5 shadow-2xs">
            {/* Engagement Manager */}
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-50 text-blue-600 dark:bg-blue-950/60 dark:text-blue-400">
                <UserRound className="h-5 w-5" />
              </div>
              <div className="space-y-0.5 min-w-0">
                <div className="flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-wider text-muted-foreground">
                  <span>ENGAGEMENT MANAGER</span>
                  {(isAdmin || isDhanshree || hasPermission("customers.edit") || hasPermission("customers.change_em")) && !isSales && (
                    <button
                      type="button"
                      onClick={openEmPicker}
                      className="text-[11px] font-bold text-blue-600 dark:text-blue-400 hover:underline cursor-pointer transition-colors"
                      title="Change Engagement Manager"
                    >
                      Change
                    </button>
                  )}
                </div>
                <div
                  className={cn(
                    "text-sm font-bold truncate max-w-[150px]",
                    emName !== "—" ? "text-foreground" : "text-muted-foreground/60 italic font-normal text-xs",
                  )}
                  title={emName}
                >
                  {emName !== "—" ? emName : "Unassigned"}
                </div>
              </div>
            </div>

            {/* Vertical Divider */}
            <div className="h-8 w-px bg-slate-200 dark:bg-border/60 shrink-0" />

            {/* Sales Manager */}
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-emerald-50 text-emerald-600 dark:bg-emerald-950/60 dark:text-emerald-400">
                <Briefcase className="h-5 w-5" />
              </div>
              <div className="space-y-0.5 min-w-0">
                <div className="flex items-center gap-1.5 text-[11px] font-bold uppercase tracking-wider text-muted-foreground">
                  <span>SALES MANAGER</span>
                  {(isAdmin || isDhanshree || hasPermission("customers.edit") || hasPermission("customers.change_sm")) && (
                    <button
                      type="button"
                      onClick={openSmPicker}
                      className="text-[11px] font-bold text-emerald-600 dark:text-emerald-400 hover:underline cursor-pointer transition-colors"
                      title="Change Sales Manager"
                    >
                      Change
                    </button>
                  )}
                </div>
                <div
                  className={cn(
                    "text-sm font-bold truncate max-w-[150px]",
                    smName !== "—" ? "text-foreground" : "text-muted-foreground/60 italic font-normal text-xs",
                  )}
                  title={smName !== "—" ? smName : "Unassigned"}
                >
                  {smName !== "—" ? smName : "Unassigned"}
                </div>
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
                  label: "TOTAL",
                  value: buckets.total,
                },
                {
                  id: "new" as FilterTab,
                  label: "NEW",
                  value: newProjs.length,
                },
                {
                  id: "ongoing" as FilterTab,
                  label: "ONGOING",
                  value: ongoingProjs.length,
                },
                {
                  id: "completed" as FilterTab,
                  label: "COMPLETED",
                  value: completedProjs.length,
                },
                {
                  id: "on_hold" as FilterTab,
                  label: "ON HOLD",
                  value: onHoldProjs.length,
                },
                {
                  id: "archived" as FilterTab,
                  label: "ARCHIVED",
                  value: archivedProjs.length,
                },
              ] as { id: FilterTab; label: string; value: number }[]
            ).map(({ id, label, value }) => {
              const active = filter === id;
              return (
                <button
                  key={id}
                  onClick={() => {
                    setFilter(id);
                    navigate({
                      to: "/customers/$clientId",
                      params: { clientId },
                      search: { status: id === "all" ? undefined : id },
                      replace: true,
                    });
                  }}
                  className={cn(
                    "inline-flex items-center gap-1.5 rounded-lg border px-3 py-1.5 text-center transition-all cursor-pointer select-none",
                    active
                      ? "border-blue-500 bg-blue-50/90 text-blue-600 font-semibold ring-2 ring-blue-500/25 dark:border-blue-500 dark:bg-blue-950/50 dark:text-blue-400"
                      : "border-slate-200 bg-white text-slate-600 font-medium hover:border-slate-300 hover:bg-slate-50 dark:border-border dark:bg-card dark:text-muted-foreground dark:hover:text-foreground",
                  )}
                >
                  <span className="text-xs font-bold tabular-nums">{value}</span>
                  <span className="text-[10px] uppercase tracking-wider font-semibold">{label}</span>
                </button>
              );
            })}
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
                  {activeSubVenture
                    ? `SPOC Contacts — ${activeSubVenture.name}`
                    : "Group SPOC"}
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
                        {activeSubVenture
                          ? `SPOC ${i + 1} — ${spoc.name}`
                          : `Group SPOC — ${spoc.name}`}
                      </button>
                    ))}
                  </div>
                ) : (
                  <p className="text-xs text-muted-foreground">
                    {activeSubVenture
                      ? "No SPOC contacts for this sub-venture yet."
                      : subVentures.length > 0
                        ? "Select a sub-venture to view that division’s SPOC contacts."
                        : "No Group SPOC or sub-venture contacts on file."}
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
                        {activeSubVenture ? (
                          <div className="text-[10px] text-muted-foreground">
                            {displaySpocs[selectedSpoc].designation} ·{" "}
                            {displaySpocs[selectedSpoc].type}
                          </div>
                        ) : (
                          <div className="text-[10px] text-muted-foreground">
                            Group SPOC
                          </div>
                        )}
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-x-4 gap-y-1">
                      {displaySpocs[selectedSpoc].email ? (
                        <div className="flex items-center gap-1 text-muted-foreground">
                          <Mail className="h-3 w-3" />
                          <span className="truncate">{displaySpocs[selectedSpoc].email}</span>
                        </div>
                      ) : null}
                      <div className="flex items-center gap-1 text-muted-foreground">
                        <Phone className="h-3 w-3" />
                        <span>
                          {displaySpocs[selectedSpoc].phone && displaySpocs[selectedSpoc].phone !== "—"
                            ? displaySpocs[selectedSpoc].phone.startsWith("+")
                              ? displaySpocs[selectedSpoc].phone
                              : `${displaySpocs[selectedSpoc].phoneCode || "+91"} ${displaySpocs[selectedSpoc].phone}`
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
                  <SearchableSelect
                    placeholder="Select sub-venture…"
                    options={subVentures.map((sv) => ({ value: sv.name, label: sv.name }))}
                    value={svFilter === "all" ? "" : svFilter}
                    onChange={(val) => {
                      setSvFilter(val || "all");
                      setSelectedSpoc(null);
                    }}
                    buttonClassName="h-8 text-xs"
                    className="w-full"
                  />
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
              <div className="flex shrink-0 items-center gap-2 text-[11px] text-muted-foreground">
                <span className="hidden sm:inline">Health</span>
                <SearchableSelect
                  placeholder="All"
                  options={[
                    { value: "all", label: "All" },
                    { value: "healthy", label: "Healthy" },
                    { value: "at_risk", label: "At Risk" },
                    { value: "critical", label: "Critical" },
                  ]}
                  value={healthFilter}
                  onChange={(val) => setHealthFilter(((val || "all") as HealthFilter))}
                  buttonClassName="h-8 min-w-[115px] text-xs font-medium"
                  clearable={false}
                />
              </div>
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
                      const assignedPmNames = (p.projectManagers ?? [])
                        .map((manager) => manager.name?.trim())
                        .filter((name): name is string => Boolean(name));
                      const pmName =
                        assignedPmNames.join(", ") || p.projectManagerName?.trim() || "";
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
                            {pmName ? (
                              <div className="flex min-w-0 items-center gap-2">
                                <AvatarBubble name={pmName} size={22} />
                                <span className="truncate text-[12px] font-medium">{pmName}</span>
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
                { label: "Billing Medium", value: client.billingMedium || "—" },
                {
                  label: "Customer Type",
                  value: client.clientType === "NEW" ? "New Customer" : "Existing Customer",
                },
                { label: "Customer Since", value: clientSinceDate },
                { label: "Engagement Manager", value: emName !== "—" ? emName : "—" },
                { label: "Sales Manager", value: smName !== "—" ? smName : "—" },
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

              {/* KYC Document Row — scoped to the selected sub-venture */}
              <div className="grid grid-cols-2 items-center gap-2 px-4 py-2.5 text-xs">
                <dt className="font-medium text-muted-foreground flex items-center gap-1.5 min-w-0">
                  <FileText className="h-3.5 w-3.5 shrink-0 text-primary" /> KYC Document
                </dt>
                <dd className="flex min-w-0 items-center justify-end gap-1.5">
                  {activeKycHasFile ? (
                    <button
                      type="button"
                      onClick={() => setKycPreviewOpen(true)}
                      className="inline-flex shrink-0 items-center gap-1.5 rounded-md border border-primary/30 bg-primary/10 px-2.5 py-1 text-[11px] font-semibold text-primary hover:bg-primary/20 transition-colors cursor-pointer"
                      title="Preview KYC Document"
                    >
                      <Eye className="h-3 w-3" /> View
                    </button>
                  ) : (
                    <span className="text-right text-[11px] text-muted-foreground">
                      {!activeSubVenture
                        ? "Select a sub-venture"
                        : "No document uploaded"}
                    </span>
                  )}
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
        <div className="fixed inset-0 z-[80] flex items-center justify-center overscroll-none p-4">
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

            <ul data-manager-scroll className="max-h-[min(360px,50vh)] overflow-y-auto overscroll-contain px-2 py-2">
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

      {/* Change Sales Manager Modal */}
      {showSMPicker && (
        <div className="fixed inset-0 z-50 flex items-center justify-center overscroll-none p-4">
          <button
            type="button"
            aria-label="Close"
            className="absolute inset-0 bg-black/40"
            onClick={() => {
              if (!smSaving) {
                setShowSMPicker(false);
                setSmSearch("");
              }
            }}
          />
          <div
            role="dialog"
            aria-modal="true"
            aria-labelledby="change-sm-title"
            className="relative z-[81] flex w-full max-w-md flex-col rounded-xl border border-border bg-card shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between border-b border-border px-4 py-3">
              <div>
                <h2 id="change-sm-title" className="text-sm font-semibold text-foreground">
                  Change Sales Manager
                </h2>
                <p className="text-[11px] text-muted-foreground">
                  {smLoading
                    ? "Loading from directory…"
                    : `${filteredSmPool.length} of ${smPool.length} Sales Manager${smPool.length === 1 ? "" : "s"}`}
                </p>
              </div>
              <button
                type="button"
                disabled={smSaving}
                onClick={() => {
                  setShowSMPicker(false);
                  setSmSearch("");
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
                  value={smSearch}
                  onChange={(e) => setSmSearch(e.target.value)}
                  placeholder="Search by name, email, or code…"
                  autoFocus
                  autoComplete="off"
                  className="h-9 w-full rounded-md border border-input bg-background pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                />
              </div>
            </div>

            <ul data-manager-scroll className="max-h-[min(360px,50vh)] overflow-y-auto overscroll-contain px-2 py-2">
              {smLoading ? (
                <li className="px-3 py-8 text-center text-sm text-muted-foreground">Loading…</li>
              ) : filteredSmPool.length === 0 ? (
                <li className="px-3 py-8 text-center text-sm text-muted-foreground">
                  {smPool.length === 0
                    ? "No Sales Managers found in the database."
                    : "No match for your search."}
                </li>
              ) : (
                filteredSmPool.map((p) => {
                  const selected = smName === p.fullName;
                  return (
                    <li key={p.id}>
                      <button
                        type="button"
                        disabled={smSaving}
                        onClick={() => void changeSalesManager(p)}
                        className={cn(
                          "flex w-full items-center gap-3 rounded-md px-3 py-2.5 text-left text-sm transition-colors hover:bg-accent/50 disabled:opacity-50",
                          selected && "bg-emerald-500/10",
                        )}
                      >
                        <AvatarBubble name={p.fullName} size={32} />
                        <div className="min-w-0 flex-1">
                          <div className="font-medium text-foreground truncate">{p.fullName}</div>
                          <div className="text-[11px] text-muted-foreground truncate">
                            {p.designation ?? "Sales Manager"}
                            {p.workEmail ? ` · ${p.workEmail}` : ""}
                          </div>
                        </div>
                        {selected ? <Check className="h-4 w-4 shrink-0 text-emerald-600 dark:text-emerald-400" /> : null}
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
          previewUrl={activeKycPreviewUrl}
          fileName={activeKycName || `${client.name.replace(/\s+/g, "_")}_KYC_Document.pdf`}
          clientName={activeSubVenture ? `${client.name} — ${activeSubVenture.name}` : client.name}
          uploadDate={clientSinceDate}
        />
      )}
    </AppShell>
  );
}
