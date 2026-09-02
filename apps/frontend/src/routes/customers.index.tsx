import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useCallback, useEffect, useMemo, useState } from "react";
import {
  LayoutGrid,
  List,
  Search,
  ArrowRight,
  X,
  Building2,
  Plus,
  ChevronRight,
  ChevronUp,
  ChevronDown,
  Check,
  UserRound,
  Eye,
  Download,
  Info,
  FileText,
  UploadCloud,
  CheckCircle2,
  AlertCircle,
  MapPin,
  Users,
  Briefcase,
  ShieldCheck,
  ArrowUpRight,
} from "lucide-react";
import { toast } from "sonner";
import { format } from "date-fns";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { type Client, type ClientSubVenture } from "@/lib/mock-data";
import {
  createClient,
  fetchClients,
  mapApiClient,
  updateClient,
  uploadSubVentureKyc,
  formatCustomerId,
  type CreateClientInput,
} from "@/lib/api/clients";
import { fetchCities, fetchCountries, type CatalogOption, type CityCatalogOption } from "@/lib/api/catalogs";
import { useAuth } from "@/lib/auth-context";
import { HealthPill, StatusPill, ProgressBar } from "@/components/pills";
import { Modal } from "@/routes/projects.index";
import { KycDocPreviewModal } from "@/components/kyc-preview-modal";
import { Field } from "@/components/form-row";
import { SearchableSelect } from "@/components/creatable-catalog-select";
import { dhStore, useDhStore, allClients, allProjects } from "@/lib/dh-store";
import { categorizeClientProjects } from "@/lib/client-project-counts";
import { cn } from "@/lib/utils";
import {
  FIELD_MAX,
  emailError,
  fieldInputCls,
  isCompletePhone,
  phoneError,
  toEmailInput,
  toTenDigitPhone,
} from "@/lib/form-validation";
import { useEngagementManagers } from "@/lib/engagement-managers";

export const Route = createFileRoute("/customers/")({
  head: () => ({
    meta: [
      { title: "Customers — Pulse PMO" },
      { name: "description", content: "All customers, projects and engagement health." },
    ],
  }),
  component: CustomersPage,
});

type CustomerListSortKey =
  | "name"
  | "industry"
  | "engagementManager"
  | "salesManager"
  | "total"
  | "newCount"
  | "ongoing"
  | "completed"
  | "onHold"
  | "archived"
  | "status";
type SortDir = "asc" | "desc";

type CustomerListRow = {
  client: Client;
  total: number;
  newCount: number;
  ongoing: number;
  completed: number;
  onHold: number;
  archived: number;
  active: number;
};

const CUSTOMER_LIST_COLUMNS: { label: string; key: CustomerListSortKey }[] = [
  { label: "Customer", key: "name" },
  { label: "Industry", key: "industry" },
  { label: "Engagement Manager", key: "engagementManager" },
  { label: "Sales Manager", key: "salesManager" },
  { label: "Total", key: "total" },
  { label: "New", key: "newCount" },
  { label: "Ongoing", key: "ongoing" },
  { label: "Completed", key: "completed" },
  { label: "On Hold", key: "onHold" },
  { label: "Archived", key: "archived" },
  { label: "Status", key: "status" },
];

function sortBlank(value: string): string {
  return !value || value === "—" ? "" : value;
}

function compareCustomerListRows(a: CustomerListRow, b: CustomerListRow, key: CustomerListSortKey): number {
  if (
    key === "total" ||
    key === "newCount" ||
    key === "ongoing" ||
    key === "completed" ||
    key === "onHold" ||
    key === "archived"
  ) {
    return a[key] - b[key];
  }
  const textFor = (row: CustomerListRow): string => {
    switch (key) {
      case "name":
        return row.client.name;
      case "industry":
        return row.client.industry ?? "";
      case "engagementManager":
        return row.client.engagementManager ?? "";
      case "salesManager":
        return row.client.salesManager ?? "";
      case "status":
        return "Active";
    }
  };
  return sortBlank(textFor(a)).localeCompare(sortBlank(textFor(b)), undefined, {
    numeric: true,
    sensitivity: "base",
  });
}

function SortableTh<T extends string>({
  label,
  column,
  sortKey,
  sortDir,
  onSort,
  isLast,
}: {
  label: string;
  column: T;
  sortKey: T;
  sortDir: SortDir;
  onSort: (column: T) => void;
  isLast?: boolean;
}) {
  const active = sortKey === column;
  return (
    <th className="relative whitespace-nowrap px-3 py-2.5 font-semibold">
      <button
        type="button"
        onClick={() => onSort(column)}
        className={cn(
          "group inline-flex items-center gap-1.5 text-left text-xs font-semibold transition-colors select-none",
          active
            ? "text-blue-600 dark:text-blue-400 font-bold"
            : "text-blue-950/85 hover:text-blue-600 dark:text-blue-100/85 dark:hover:text-blue-300",
        )}
        aria-sort={active ? (sortDir === "asc" ? "ascending" : "descending") : "none"}
        aria-label={`Sort by ${label}`}
      >
        <span>{label}</span>
        <span
          className={cn(
            "inline-flex h-4 w-4 shrink-0 items-center justify-center rounded transition-all duration-150",
            active
              ? "bg-blue-100 text-blue-600 dark:bg-blue-900/60 dark:text-blue-400"
              : "text-blue-400/40 opacity-0 group-hover:opacity-100 group-hover:text-blue-500",
          )}
        >
          {active && sortDir === "desc" ? (
            <ChevronDown className="h-3.5 w-3.5" />
          ) : (
            <ChevronUp className="h-3.5 w-3.5" />
          )}
        </span>
      </button>
      {!isLast ? (
        <span
          className="pointer-events-none absolute right-0 top-2.5 bottom-2.5 w-px bg-blue-300/80 dark:bg-blue-700"
          aria-hidden="true"
        />
      ) : null}
    </th>
  );
}

function CustomersPage() {
  const { isDhanshree, isBO, assignedProjects } = useRoleContext();
  const navigate = useNavigate();
  const [view, setViewState] = useState<"card" | "list">(() => {
    if (typeof window !== "undefined") {
      const saved = localStorage.getItem("customers-view-mode");
      if (saved === "card" || saved === "list") return saved;
    }
    return "card";
  });

  const setView = (v: "card" | "list") => {
    setViewState(v);
    if (typeof window !== "undefined") {
      localStorage.setItem("customers-view-mode", v);
    }
  };

  const { user: authUser } = useAuth();
  const [q, setQ] = useState("");
  const [sortKey, setSortKey] = useState<CustomerListSortKey>("name");
  const [sortDir, setSortDir] = useState<SortDir>("asc");
  const [openId, setOpenId] = useState<string | null>(null);
  const [openNew, setOpenNew] = useState(false);

  // Live data from the TrackerPro API. The customer list is Postgres-only —
  // no mock/dh-store fallback. While loading (or if the backend is unreachable)
  // we show a spinner / empty state instead of mock clients.
  const [apiClients, setApiClients] = useState<Client[] | null>(null);
  const [clientsLoading, setClientsLoading] = useState(true);
  const refreshApiClients = useCallback(async () => {
    setClientsLoading(true);
    try {
      const list = await fetchClients();
      setApiClients(list.map(mapApiClient));
    } catch {
      /* backend offline — show empty, do NOT fall back to mock data */
      setApiClients([]);
    } finally {
      setClientsLoading(false);
    }
  }, []);
  useEffect(() => {
    void refreshApiClients();
  }, [refreshApiClients]);

  // Only users holding clients:write may onboard new customers (RBAC).
  const canCreateClient =
    !isBO && (authUser ? authUser.permissions.includes("clients:write") : true);

  // Subscribe to store so newly created projects appear immediately
  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);
  // Customer records come exclusively from the API (Postgres). No mock fallback.
  const clients = useMemo(() => apiClients ?? [], [apiClients]);
  const projects = useMemo(
    () =>
      isDhanshree
        ? allProjects()
        : assignedProjects && assignedProjects.length > 0
          ? assignedProjects
          : allProjects(),
    [isDhanshree, assignedProjects, extraCount],
  );

  const enriched = useMemo(() => {
    // API clients have database ids — map them back to the mock client id (by name)
    // so project counts still work until the Projects module is API-backed.
    const mockIdByName = new Map(allClients().map((c) => [c.name.toLowerCase(), c.id]));
    return clients.map((c) => {
      const mockId = apiClients ? (mockIdByName.get(c.name.toLowerCase()) ?? c.id) : c.id;
      const projs = projects.filter((p) => p.clientId === mockId);
      const buckets = categorizeClientProjects(projs);
      return {
        client: c,
        total: buckets.total,
        newCount: buckets.new.length,
        ongoing: buckets.ongoing.length,
        completed: buckets.completed.length,
        onHold: buckets.onHold.length,
        archived: buckets.archived.length,
        active: buckets.new.length + buckets.ongoing.length,
      };
    });
  }, [clients, projects, apiClients]);

  const matchesClientSearch = (c: Client, query: string): boolean => {
    if (!query) return true;
    const terms = query.toLowerCase().trim().split(/\s+/).filter(Boolean);
    if (terms.length === 0) return true;

    const svNames = (c.subVentures ?? []).map((s) => s.name);
    const svNotes = (c.subVentures ?? []).map((s) => s.notes ?? "");
    const svContacts = (c.subVentures ?? []).flatMap((s) => s.contacts ?? []);

    const allContacts = [...(c.contacts ?? []), ...svContacts];
    const contactNames = allContacts.map((ct) => ct.name);
    const contactEmails = allContacts.map((ct) => ct.email);
    const contactPhones = allContacts.map((ct) => ct.phone ?? "");
    const contactDesigs = allContacts.map((ct) => ct.designation ?? "");
    const contactTypes = allContacts.map((ct) => ct.contactType ?? "");

    const searchableText = [
      c.id,
      c.name,
      c.industry,
      c.clientType,
      c.engagementManager,
      c.salesManager,
      c.contact,
      c.contactName,
      c.contactPhone,
      c.contactDesignation,
      c.contactType,
      c.city,
      c.country,
      c.businessType,
      c.notes,
      c.kycDocumentName,
      c.customerSince,
      ...svNames,
      ...svNotes,
      ...contactNames,
      ...contactEmails,
      ...contactPhones,
      ...contactDesigs,
      ...contactTypes,
    ]
      .filter(Boolean)
      .join(" ")
      .toLowerCase();

    return terms.every((term) => searchableText.includes(term));
  };

  const filtered = enriched.filter(({ client: c }) => matchesClientSearch(c, q));
  const sorted = useMemo(() => {
    const rows = [...filtered];
    rows.sort((a, b) => {
      const cmp = compareCustomerListRows(a, b, sortKey);
      return sortDir === "asc" ? cmp : -cmp;
    });
    return rows;
  }, [filtered, sortKey, sortDir]);

  const open = openId ? clients.find((c) => c.id === openId) : null;

  return (
    <AppShell title="Customers" subtitle="Customer directory with active and completed engagements">
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search customer, SPOC, sub-venture, phone…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div className="ml-auto flex items-center gap-2.5">
          <div className="flex gap-0.5 rounded-lg border border-border/80 bg-muted/60 p-1 text-xs shadow-inner">
            <button
              onClick={() => setView("card")}
              aria-label="Grid view"
              className={cn(
                "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-all duration-150",
                view === "card"
                  ? "bg-blue-600 text-white shadow-xs"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <LayoutGrid className="h-3.5 w-3.5" /> Grid
            </button>
            <button
              onClick={() => setView("list")}
              aria-label="List view"
              className={cn(
                "inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-all duration-150",
                view === "list"
                  ? "bg-blue-600 text-white shadow-xs"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <List className="h-3.5 w-3.5" /> List
            </button>
          </div>
          {canCreateClient && (
            <button
              onClick={() => setOpenNew(true)}
              className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all"
            >
              <Plus className="h-4 w-4" /> New Customer
            </button>
          )}
        </div>
      </div>

      {clientsLoading ? (
        <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-12 text-center">
          <div className="h-8 w-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
          <p className="text-sm text-muted-foreground">Loading customers from the database…</p>
        </div>
      ) : view === "card" ? (
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
          {filtered.map(({ client: c, total, newCount, ongoing, completed, onHold, archived }) => {
            const emName = c.engagementManager?.trim() || "Unassigned";
            const smName = c.salesManager?.trim() || "Unassigned";

            return (
              <article
                key={c.id}
                role="link"
                tabIndex={0}
                onClick={() => navigate({ to: "/customers/$clientId", params: { clientId: c.id } })}
                onKeyDown={(e) => {
                  if (e.key === "Enter" || e.key === " ") {
                    e.preventDefault();
                    navigate({ to: "/customers/$clientId", params: { clientId: c.id } });
                  }
                }}
                className={cn(
                  "group relative flex cursor-pointer flex-col overflow-hidden rounded-2xl",
                  "border border-slate-200/90 dark:border-border/80",
                  "bg-white dark:bg-card",
                  "shadow-[0_2px_8px_-2px_rgba(15,23,42,0.06),0_1px_3px_rgba(15,23,42,0.04)]",
                  "transition-all duration-200 ease-out",
                  "hover:border-blue-500 hover:shadow-[0_12px_28px_-4px_rgba(37,99,235,0.14),0_4px_10px_-2px_rgba(15,23,42,0.06)]",
                  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
                  "before:absolute before:inset-x-0 before:top-0 before:h-1 before:bg-gradient-to-r before:from-blue-600 before:to-indigo-500 before:opacity-0 group-hover:before:opacity-100 before:transition-opacity before:duration-200",
                )}
              >
                {/* SECTION 1: Client Identity & Stakeholders */}
                <div className="flex flex-col p-5 pb-4">
                  {/* Header: Logo, Name, Industry, and top-right arrow */}
                  <div className="flex items-start gap-3.5 mb-3.5">
                    <div
                      className={cn(
                        "flex h-11 w-11 shrink-0 items-center justify-center rounded-xl",
                        "bg-blue-600 text-sm font-bold tracking-tight text-white",
                        "shadow-xs group-hover:scale-105 transition-transform duration-200",
                      )}
                      aria-hidden
                    >
                      {c.logo}
                    </div>
                    <div className="min-w-0 flex-1 pt-0.5">
                      <div className="flex items-start justify-between gap-2">
                        <div className="min-w-0 flex-1">
                          <h3 className="truncate text-[15px] font-bold leading-snug tracking-tight text-foreground group-hover:text-primary transition-colors">
                            {c.name}
                          </h3>
                          <p className="truncate text-xs text-muted-foreground font-normal mt-0.5">
                            {c.industry || "—"}
                          </p>
                        </div>
                        <ArrowUpRight
                          className="h-4 w-4 text-muted-foreground/50 transition-transform duration-200 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 group-hover:text-primary shrink-0"
                          aria-hidden
                        />
                      </div>
                    </div>
                  </div>

                  {/* Stakeholders Section: Single unified box with Engagement Manager & Sales Manager stacked */}
                  <div className="rounded-xl border border-slate-200/80 bg-slate-50/60 p-3 space-y-2 dark:border-border/60 dark:bg-muted/30">
                    {/* Engagement Manager */}
                    <div className="flex items-center justify-between gap-3 text-xs">
                      <div className="flex items-center gap-2 min-w-0 text-muted-foreground">
                        <UserRound className="h-3.5 w-3.5 shrink-0 text-muted-foreground/80" aria-hidden />
                        <span className="truncate text-xs font-normal text-muted-foreground">
                          Engagement Manager
                        </span>
                      </div>
                      <span
                        className={cn(
                          "truncate text-xs font-semibold text-right max-w-[50%]",
                          c.engagementManager?.trim() ? "text-foreground font-bold" : "text-muted-foreground/60 font-normal",
                        )}
                        title={emName}
                      >
                        {emName}
                      </span>
                    </div>

                    {/* Sales Manager */}
                    <div className="flex items-center justify-between gap-3 text-xs border-t border-slate-200/60 pt-2 dark:border-border/40">
                      <div className="flex items-center gap-2 min-w-0 text-muted-foreground">
                        <Briefcase className="h-3.5 w-3.5 shrink-0 text-muted-foreground/80" aria-hidden />
                        <span className="truncate text-xs font-normal text-muted-foreground">
                          Sales Manager
                        </span>
                      </div>
                      <span
                        className={cn(
                          "truncate text-xs font-semibold text-right max-w-[50%]",
                          c.salesManager?.trim() ? "text-foreground font-bold" : "text-muted-foreground/60 font-normal",
                        )}
                        title={smName}
                      >
                        {smName}
                      </span>
                    </div>
                  </div>
                </div>

                {/* SECTION 2: Project Metrics (Separated bottom section) */}
                <div className="mt-auto border-t border-slate-200/80 bg-slate-50/40 px-5 py-3.5 dark:border-border/70 dark:bg-muted/20">
                  <div className="flex items-center gap-2.5">
                    {/* Total Project Ring Gauge Button */}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        navigate({ to: "/customers/$clientId", params: { clientId: c.id } });
                      }}
                      className="group/gauge relative flex h-10 w-10 shrink-0 items-center justify-center rounded-full transition-all duration-200 hover:scale-110 hover:shadow-xs cursor-pointer"
                      title={`View all ${total} projects for ${c.name}`}
                    >
                      <div
                        className="absolute inset-0 rounded-full"
                        style={{
                          background:
                            total > 0
                              ? `conic-gradient(
                                  #3b82f6 0deg ${((newCount || 0) / Math.max(total, 1)) * 360}deg,
                                  #a855f7 ${((newCount || 0) / Math.max(total, 1)) * 360}deg ${(((newCount || 0) + (ongoing || 0)) / Math.max(total, 1)) * 360}deg,
                                  #10b981 ${(((newCount || 0) + (ongoing || 0)) / Math.max(total, 1)) * 360}deg ${(((newCount || 0) + (ongoing || 0) + (completed || 0)) / Math.max(total, 1)) * 360}deg,
                                  #f59e0b ${(((newCount || 0) + (ongoing || 0) + (completed || 0)) / Math.max(total, 1)) * 360}deg ${(((newCount || 0) + (ongoing || 0) + (completed || 0) + (onHold || 0)) / Math.max(total, 1)) * 360}deg,
                                  #94a3b8 ${(((newCount || 0) + (ongoing || 0) + (completed || 0) + (onHold || 0)) / Math.max(total, 1)) * 360}deg 360deg
                                )`
                              : "conic-gradient(#94a3b8 0deg 360deg)",
                        }}
                      />
                      <div className="absolute inset-[2.5px] rounded-full bg-white dark:bg-card flex items-center justify-center shadow-2xs group-hover/gauge:bg-slate-100 dark:group-hover/gauge:bg-slate-800 transition-colors">
                        <span className="text-sm font-extrabold tabular-nums text-foreground group-hover/gauge:text-primary transition-colors">
                          {total}
                        </span>
                      </div>
                    </button>

                    {/* Status breakdown pills (White in Normal State, Soft Light Color Fill on Hover) */}
                    <div className="grid flex-1 grid-cols-5 gap-1.5 min-w-0">
                      {/* New (Soft Light Blue on hover) */}
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          navigate({ to: "/customers/$clientId", params: { clientId: c.id } });
                        }}
                        className={cn(
                          "group/btn flex flex-col items-center justify-center rounded-xl border py-1.5 px-1 transition-all duration-150 cursor-pointer select-none",
                          "border-slate-200 bg-white shadow-2xs dark:border-border/70 dark:bg-card",
                          "hover:border-blue-300 hover:bg-blue-50/90 active:bg-blue-100 hover:shadow-xs hover:scale-105 dark:hover:bg-blue-950/50 dark:hover:border-blue-800",
                        )}
                        title={`${newCount} New Projects`}
                      >
                        <span className="text-xs font-bold tabular-nums text-blue-600 dark:text-blue-400 group-hover/btn:text-blue-700 dark:group-hover/btn:text-blue-300 leading-tight transition-colors">
                          {newCount}
                        </span>
                        <span className="text-[10px] font-medium text-slate-500 dark:text-slate-400 group-hover/btn:text-blue-600 dark:group-hover/btn:text-blue-300 leading-tight truncate transition-colors">
                          New
                        </span>
                      </button>

                      {/* Ongoing (Soft Light Purple on hover) */}
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          navigate({ to: "/customers/$clientId", params: { clientId: c.id } });
                        }}
                        className={cn(
                          "group/btn flex flex-col items-center justify-center rounded-xl border py-1.5 px-1 transition-all duration-150 cursor-pointer select-none",
                          "border-slate-200 bg-white shadow-2xs dark:border-border/70 dark:bg-card",
                          "hover:border-purple-300 hover:bg-purple-50/90 active:bg-purple-100 hover:shadow-xs hover:scale-105 dark:hover:bg-purple-950/50 dark:hover:border-purple-800",
                        )}
                        title={`${ongoing} Ongoing Projects`}
                      >
                        <span className="text-xs font-bold tabular-nums text-purple-600 dark:text-purple-400 group-hover/btn:text-purple-700 dark:group-hover/btn:text-purple-300 leading-tight transition-colors">
                          {ongoing}
                        </span>
                        <span className="text-[10px] font-medium text-slate-500 dark:text-slate-400 group-hover/btn:text-purple-600 dark:group-hover/btn:text-purple-300 leading-tight truncate transition-colors">
                          Ongoing
                        </span>
                      </button>

                      {/* Completed (Soft Light Emerald on hover) */}
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          navigate({ to: "/customers/$clientId", params: { clientId: c.id } });
                        }}
                        className={cn(
                          "group/btn flex flex-col items-center justify-center rounded-xl border py-1.5 px-1 transition-all duration-150 cursor-pointer select-none",
                          "border-slate-200 bg-white shadow-2xs dark:border-border/70 dark:bg-card",
                          "hover:border-emerald-300 hover:bg-emerald-50/90 active:bg-emerald-100 hover:shadow-xs hover:scale-105 dark:hover:bg-emerald-950/50 dark:hover:border-emerald-800",
                        )}
                        title={`${completed} Completed Projects`}
                      >
                        <span className="text-xs font-bold tabular-nums text-emerald-600 dark:text-emerald-400 group-hover/btn:text-emerald-700 dark:group-hover/btn:text-emerald-300 leading-tight transition-colors">
                          {completed}
                        </span>
                        <span className="text-[10px] font-medium text-slate-500 dark:text-slate-400 group-hover/btn:text-emerald-600 dark:group-hover/btn:text-emerald-300 leading-tight truncate transition-colors">
                          Completed
                        </span>
                      </button>

                      {/* On Hold (Soft Light Amber on hover) */}
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          navigate({ to: "/customers/$clientId", params: { clientId: c.id } });
                        }}
                        className={cn(
                          "group/btn flex flex-col items-center justify-center rounded-xl border py-1.5 px-1 transition-all duration-150 cursor-pointer select-none",
                          "border-slate-200 bg-white shadow-2xs dark:border-border/70 dark:bg-card",
                          "hover:border-amber-300 hover:bg-amber-50/90 active:bg-amber-100 hover:shadow-xs hover:scale-105 dark:hover:bg-amber-950/50 dark:hover:border-amber-800",
                        )}
                        title={`${onHold} On Hold Projects`}
                      >
                        <span className="text-xs font-bold tabular-nums text-amber-600 dark:text-amber-400 group-hover/btn:text-amber-700 dark:group-hover/btn:text-amber-300 leading-tight transition-colors">
                          {onHold}
                        </span>
                        <span className="text-[10px] font-medium text-slate-500 dark:text-slate-400 group-hover/btn:text-amber-600 dark:group-hover/btn:text-amber-300 leading-tight truncate transition-colors">
                          On Hold
                        </span>
                      </button>

                      {/* Archived (Soft Light Slate on hover) */}
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          navigate({ to: "/customers/$clientId", params: { clientId: c.id } });
                        }}
                        className={cn(
                          "group/btn flex flex-col items-center justify-center rounded-xl border py-1.5 px-1 transition-all duration-150 cursor-pointer select-none",
                          "border-slate-200 bg-white shadow-2xs dark:border-border/70 dark:bg-card",
                          "hover:border-slate-300 hover:bg-slate-100 active:bg-slate-200/80 hover:shadow-xs hover:scale-105 dark:hover:bg-slate-800/60 dark:hover:border-slate-700",
                        )}
                        title={`${archived} Archived Projects`}
                      >
                        <span className="text-xs font-bold tabular-nums text-slate-700 dark:text-slate-300 group-hover/btn:text-slate-900 dark:group-hover/btn:text-slate-100 leading-tight transition-colors">
                          {archived}
                        </span>
                        <span className="text-[10px] font-medium text-slate-500 dark:text-slate-400 group-hover/btn:text-slate-800 dark:group-hover/btn:text-slate-200 leading-tight truncate transition-colors">
                          Archived
                        </span>
                      </button>
                    </div>
                  </div>
                </div>
              </article>
            );
          })}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full border-separate border-spacing-0 text-sm">
            <thead className="sticky top-0 z-10 bg-blue-100/80 text-left text-xs text-slate-700 shadow-[inset_0_-2px_0_0_#93c5fd] dark:bg-blue-950/55 dark:text-blue-100 dark:shadow-[inset_0_-2px_0_0_#1e3a8a]">
              <tr>
                {CUSTOMER_LIST_COLUMNS.map((col, idx, cols) => (
                  <SortableTh
                    key={col.key}
                    label={col.label}
                    column={col.key}
                    sortKey={sortKey}
                    sortDir={sortDir}
                    isLast={idx === cols.length - 1}
                    onSort={(next) => {
                      if (sortKey === next) setSortDir((d) => (d === "asc" ? "desc" : "asc"));
                      else {
                        setSortKey(next);
                        setSortDir("asc");
                      }
                    }}
                  />
                ))}
              </tr>
            </thead>
            <tbody className="bg-card [&>tr>td]:border-b [&>tr>td]:border-slate-200 dark:[&>tr>td]:border-border">
              {sorted.map(
                ({ client: c, total, newCount, ongoing, completed, onHold, archived }) => (
                <tr key={c.id} className="bg-card">
                  <td className="px-3 py-2.5">
                    <div className="flex items-center gap-2.5">
                      <span className="flex h-7 w-7 items-center justify-center rounded-md bg-gradient-to-br from-primary to-info text-[11px] font-semibold text-primary-foreground shrink-0">
                        {c.logo}
                      </span>
                      <div className="min-w-0">
                        <Link
                          to="/customers/$clientId"
                          params={{ clientId: c.id }}
                          className="block truncate font-medium text-foreground hover:text-primary hover:underline"
                        >
                          {c.name}
                        </Link>
                        <span className="font-mono text-[10px] text-muted-foreground">
                          {formatCustomerId(c.id)}
                        </span>
                      </div>
                    </div>
                  </td>
                  <td className="px-3 py-2.5 text-muted-foreground">{c.industry}</td>
                  <td className="px-3 py-2.5 text-xs text-foreground font-medium">{c.engagementManager || "—"}</td>
                  <td className="px-3 py-2.5 text-xs text-foreground font-medium">{c.salesManager || "—"}</td>
                  <td className="px-3 py-2.5 tabular-nums">{total}</td>
                  <td className="px-3 py-2.5 tabular-nums text-primary">{newCount}</td>
                  <td className="px-3 py-2.5 tabular-nums text-info">{ongoing}</td>
                  <td className="px-3 py-2.5 tabular-nums text-success">{completed}</td>
                  <td className="px-3 py-2.5 tabular-nums text-warning-foreground">{onHold}</td>
                  <td className="px-3 py-2.5 tabular-nums text-muted-foreground">{archived}</td>
                  <td className="px-3 py-2.5">
                    <span className="inline-flex items-center gap-1 rounded-full border border-success/30 bg-success/10 px-2 py-0.5 text-[11px] font-medium text-success">
                      Active
                    </span>
                  </td>
                </tr>
              ),
              )}
            </tbody>
          </table>
        </div>
      )}

      {open && <CustomerDrawer client={open} onClose={() => setOpenId(null)} />}
      {openNew && (
        <NewClientModal
          apiClients={apiClients}
          onClose={() => setOpenNew(false)}
          onCreated={() => {
            setOpenNew(false);
            void refreshApiClients();
          }}
        />
      )}
    </AppShell>
  );
}

// ---------- New Client onboarding (stepper) ----------
interface ContactEntry {
  name: string;
  email: string;
  phone: string;
  designation: string;
  contactType?: string;
}
interface NewClientState {
  clientName: string;
  subVentureName: string;
  customerId: string;
  engagementManager: string;
  salesManager: string;
  phoneNumber: string;
  city: string;
  country: string;
  industry: string;
  businessType: string;
  createdAt: string;
  createdBy: string;
  kycFile: File | null;
  contacts: ContactEntry[];
  notes: string;
}

const inputCls =
  "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring";
const Row = ({ label, v }: { label: string; v: string }) => (
  <>
    <dt className="text-muted-foreground">{label}</dt>
    <dd className="font-medium">{v || "—"}</dd>
  </>
);

function NewClientModal({
  apiClients,
  onClose,
  onCreated,
}: {
  apiClients: Client[] | null;
  onClose: () => void;
  onCreated: () => void;
}) {
  const { user } = useRoleContext();
  const [step, setStep] = useState(1);
  const [submitting, setSubmitting] = useState(false);

  // ── TK Customer search state — API-backed clients only ──
  const existingClients = useMemo(() => apiClients ?? [], [apiClients]);
  const [tkSearch, setTkSearch] = useState("");
  const [tkDropOpen, setTkDropOpen] = useState(false);
  const [selectedExisting, setSelectedExisting] = useState<(typeof existingClients)[0] | null>(
    null,
  );

  // ── Sub-venture search state (only when existing client selected) ──
  const [svSearch, setSvSearch] = useState("");
  const [svDropOpen, setSvDropOpen] = useState(false);
  const [svAlreadyExists, setSvAlreadyExists] = useState(false);

  const [countries, setCountries] = useState<CatalogOption[]>([]);
  const [cities, setCities] = useState<CityCatalogOption[]>([]);

  const filteredTk = existingClients.filter(
    (c) => tkSearch.trim() === "" || c.name.toLowerCase().includes(tkSearch.toLowerCase()),
  );

  const [s, setS] = useState<NewClientState>(() => ({
    clientName: "",
    subVentureName: "",
    customerId: "C" + String((apiClients?.length ?? 0) + 1).padStart(3, "0"),
    engagementManager: "",
    salesManager: "",
    phoneNumber: "",
    city: "",
    country: "",
    industry: "",
    businessType: "",
    createdAt: new Date().toISOString(),
    createdBy: user?.name ?? "Unknown",
    kycFile: null,
    contacts: [{ name: "", email: "", phone: "", designation: "", contactType: "" }],
    notes: "",
  }));
  const [previewKyc, setPreviewKyc] = useState(false);
  const { pool: emPool, loading: emLoading } = useEngagementManagers();
  const emOptions = useMemo(
    () =>
      emPool.map((p) => ({
        value: p.fullName,
        label: p.fullName,
        subLabel: [p.designation ?? "Engagement Manager", p.workEmail].filter(Boolean).join(" · "),
      })),
    [emPool],
  );

  useEffect(() => {
    let cancelled = false;
    void fetchCountries()
      .then((rows) => {
        if (!cancelled) setCountries(rows);
      })
      .catch(() => {
        if (!cancelled) setCountries([]);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const selectedCountryId = countries.find((c) => c.name === s.country)?.id;

  useEffect(() => {
    if (!selectedCountryId) {
      setCities([]);
      return;
    }
    let cancelled = false;
    void fetchCities(selectedCountryId)
      .then((rows) => {
        if (!cancelled) setCities(rows);
      })
      .catch(() => {
        if (!cancelled) setCities([]);
      });
    return () => {
      cancelled = true;
    };
  }, [selectedCountryId]);

  const u = (k: keyof Omit<NewClientState, "contacts" | "kycFile">, v: string) =>
    setS((p) => ({ ...p, [k]: v }));

  const MAX_CONTACTS = 4;

  const addContact = () =>
    setS((p) =>
      p.contacts.length >= MAX_CONTACTS
        ? p
        : {
            ...p,
            contacts: [
              ...p.contacts,
              { name: "", email: "", phone: "", designation: "", contactType: "" },
            ],
          },
    );

  const removeContact = (idx: number) =>
    setS((p) => ({ ...p, contacts: p.contacts.filter((_, i) => i !== idx) }));

  const updateContact = (idx: number, field: keyof ContactEntry, val: string) =>
    setS((p) => ({
      ...p,
      contacts: p.contacts.map((c, i) => (i === idx ? { ...c, [field]: val } : c)),
    }));

  const selectedCountryObj = countries.find((c) => c.name === s.country);
  const countryDialCode = selectedCountryObj?.phoneCode || "+91";
  const countryPhoneDigits = selectedCountryObj?.phoneDigits || 10;

  const namesEq = (a: string, b: string) => a.trim().toLowerCase() === b.trim().toLowerCase();
  const matchingExistingClient =
    selectedExisting ??
    existingClients.find((c) => namesEq(c.name, s.clientName || tkSearch)) ??
    null;
  const duplicatePairExists = Boolean(
    matchingExistingClient &&
      s.subVentureName.trim() &&
      (matchingExistingClient.subVentures ?? []).some((sv) => namesEq(sv.name, s.subVentureName)),
  );

  // Returns the first missing required field (top-to-bottom), or null if all valid
  const getStep1Error = (): string | null => {
    if (!selectedExisting && !s.clientName.trim()) return "TK Customer / Partner Name is required";
    if (!s.subVentureName.trim()) return "End Customer / Sub-venture Name is required";
    if (duplicatePairExists) return "Client and sub-venture already exist";
    if (selectedExisting) return null; // existing client — rest auto-filled
    if (!s.engagementManager.trim()) return "Engagement Manager is required";
    if (
      emPool.length > 0 &&
      !emPool.some((p) => p.fullName === s.engagementManager.trim())
    ) {
      return "Select an Engagement Manager from the list";
    }
    if (!s.country.trim()) return "Country is required";
    if (!s.city.trim()) return "City is required";
    if (!s.phoneNumber.trim()) return "Group SPOC Contact is required";
    const cleanPhone = s.phoneNumber.replace(/\D/g, "");
    if (cleanPhone.length !== countryPhoneDigits) {
      return `Group SPOC Contact must be exactly ${countryPhoneDigits} digits for ${s.country || "selected country"}`;
    }
    if (!s.industry.trim()) return "Industry is required";
    return null;
  };

  const getStep2Error = (): string | null => {
    for (let i = 0; i < s.contacts.length; i++) {
      const c = s.contacts[i];
      const n = s.contacts.length > 1 ? ` (Contact ${i + 1})` : "";
      if (!c.name.trim()) return `Contact Name${n} is required`;
      if (!c.contactType?.trim()) return `Contact Type${n} is required`;
      const mailErr = emailError(c.email, true);
      if (mailErr) return `Contact Email${n} — ${mailErr}`;
      const phErr = phoneError(c.phone, true);
      if (phErr) return `Contact Phone${n} — ${phErr}`;
      if (!c.designation.trim()) return `Designation${n} is required`;
    }
    if (!s.kycFile) return "KYC Document is required";
    return null;
  };

  const handleNext = () => {
    if (step === 1) {
      const err = getStep1Error();
      if (err) {
        toast.error(err);
        return;
      }
    }
    if (step === 2) {
      const err = getStep2Error();
      if (err) {
        toast.error(err);
        return;
      }
    }
    setStep((prev) => prev + 1);
  };

  const readOnlyCls = cn(inputCls, "bg-muted text-muted-foreground cursor-not-allowed");

  const isApiError = (err: unknown): err is Error & { status?: number } =>
    err instanceof Error && "status" in err;
  const isSessionError = (err: unknown): boolean =>
    err instanceof Error && /not authenticated|unauthorized/i.test(err.message);

  const buildNewClientPayload = () => {
    const validContacts = s.contacts.filter((c) => c.name.trim() && c.email.trim());
    const primary = validContacts[0] ?? s.contacts[0];
    const name = (s.clientName || s.subVentureName).trim();
    const subVentureName = s.subVentureName?.trim() || null;
    const noteText = s.notes?.trim() || undefined;
    const subVentures: ClientSubVenture[] = subVentureName
      ? [{ name: subVentureName, contacts: validContacts, notes: noteText }]
      : [];
    const engagementManager = s.engagementManager?.trim() || null;
    const salesManager = s.salesManager?.trim() || null;
    return {
      api: {
        name,
        industry: (s.industry || "Other").trim(),
        clientType: "NEW" as const,
        contactEmail: primary?.email?.trim() || null,
        contactName: primary?.name?.trim() || null,
        contactPhone: primary?.phone?.trim() || s.phoneNumber?.trim() || null,
        contactDesignation: primary?.designation?.trim() || null,
        contactType: primary?.contactType || "Primary",
        city: s.city?.trim() || null,
        country: s.country?.trim() || null,
        businessType: s.businessType?.trim() || null,
        notes: null,
        kycDocumentName: s.kycFile?.name || null,
        engagementManager,
        salesManager,
        subVentures,
        contacts: validContacts.map((c) => ({
          name: c.name.trim(),
          email: c.email.trim(),
          phone: c.phone.trim() || null,
          designation: c.designation.trim() || null,
          contactType: c.contactType || "Primary",
        })),
      } satisfies CreateClientInput,
      managerPatch: {
        ...(engagementManager ? { engagementManager } : {}),
        ...(salesManager ? { salesManager } : {}),
      },
      store: {
        name,
        industry: s.industry || "Other",
        contact: primary?.email ?? "",
        contactName: primary?.name ?? "",
        contactPhone: primary?.phone ?? "",
        contactDesignation: primary?.designation ?? "",
        contactType: primary?.contactType || "Primary",
        city: s.city,
        country: s.country,
        businessType: s.businessType,
        notes: undefined,
        kycDocumentName: s.kycFile?.name || undefined,
        contacts: validContacts.length > 0 ? validContacts : undefined,
        engagementManager: s.engagementManager,
        salesManager: s.salesManager,
        subVentures,
      },
    };
  };

  const submit = async () => {
    setSubmitting(true);
    try {
      const { api, store, managerPatch } = buildNewClientPayload();

      if (duplicatePairExists && matchingExistingClient) {
        toast.error("Client and sub-venture already exist", {
          description: `${s.subVentureName.trim()} is already under ${matchingExistingClient.name}.`,
        });
        return;
      }

      // ── Existing TK customer → add a sub-venture ──
      if (selectedExisting) {

        const isApiClient = apiClients?.some((c) => c.id === selectedExisting.id) ?? false;
        if (isApiClient) {
          try {
            const updated = await updateClient(selectedExisting.id, {
              ...managerPatch,
              subVentures: [
                ...(selectedExisting.subVentures ?? []),
                {
                  name: s.subVentureName.trim(),
                  contacts: store.contacts ?? [],
                  notes: s.notes?.trim() || undefined,
                },
              ],
            });
            // KYC is per sub-venture — attach it to the sub-venture just added.
            if (s.kycFile) {
              const svName = s.subVentureName.trim().toLowerCase();
              const targetSv = updated.subVentures?.find(
                (sv) => sv.name.trim().toLowerCase() === svName,
              );
              if (targetSv?.id) {
                try {
                  await uploadSubVentureKyc(selectedExisting.id, targetSv.id, s.kycFile);
                } catch (kycErr) {
                  toast.warning("Sub-venture saved, but the KYC document didn't upload", {
                    description: kycErr instanceof Error ? kycErr.message : "Please re-upload the KYC document from the customer page.",
                  });
                }
              }
            }
            toast.success("Sub-venture added", {
              description: `${s.subVentureName} added under ${selectedExisting.name} in the database.`,
            });
            onCreated();
            return;
          } catch (err) {
            if (isSessionError(err)) {
              toast.error("Your session has expired. Please sign in again.");
              return;
            }
            if (isApiError(err)) {
              toast.error(err.message || "Failed to save the sub-venture.");
              return;
            }
            dhStore.addSubVenture(selectedExisting.id, s.subVentureName.trim(), store.contacts, s.notes);
            toast.warning("Backend unreachable — sub-venture saved locally", {
              description: `${s.subVentureName} added under ${selectedExisting.name} in your local directory.`,
            });
            onCreated();
            return;
          }
        }

        dhStore.addSubVenture(selectedExisting.id, s.subVentureName.trim(), store.contacts, s.notes);
        toast.success("Sub-venture added", {
          description: `${s.subVentureName} added under ${selectedExisting.name}.`,
        });
        onCreated();
        return;
      }

      // ── Brand new TK customer → create it in the database ──
      try {
        const created = await createClient(api);
        // KYC is per sub-venture — attach it to the sub-venture created in this onboarding.
        if (s.kycFile && created?.id) {
          const svName = s.subVentureName.trim().toLowerCase();
          const targetSv =
            created.subVentures?.find((sv) => sv.name.trim().toLowerCase() === svName) ??
            created.subVentures?.[0];
          if (targetSv?.id) {
            try {
              await uploadSubVentureKyc(created.id, targetSv.id, s.kycFile);
            } catch (kycErr) {
              toast.warning("Customer saved, but the KYC document didn't upload", {
                description: kycErr instanceof Error ? kycErr.message : "Please re-upload the KYC document from the customer page.",
              });
            }
          }
        }
        toast.success("Customer onboarded", {
          description: `${api.name} saved to the database.`,
        });
      } catch (err) {
        if (isSessionError(err)) {
          toast.error("Your session has expired. Please sign in again.");
          return;
        }
        if (isApiError(err)) {
          toast.error(err.message || "Failed to save the client.");
          return;
        }
        dhStore.addClient(store);
        toast.warning("Backend unreachable — client saved locally", {
          description: `${store.name} added to your local directory.`,
        });
      }
      onCreated();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Something went wrong while saving.");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <>
    <Modal title="New Customer Onboarding" onClose={onClose} wide draggable>
      {/* Stepper */}
      <div className="mb-5 flex items-center gap-2 text-xs">
        {["Company", "Contact", "Review"].map((label, i) => {
          const n = i + 1;
          const active = step === n;
          const done = step > n;
          return (
            <div key={label} className="flex items-center gap-2">
              <div
                className={cn(
                  "flex h-6 w-6 items-center justify-center rounded-full border text-[11px] font-semibold",
                  done
                    ? "border-success bg-success text-success-foreground"
                    : active
                      ? "border-primary bg-primary text-primary-foreground"
                      : "border-border bg-card text-muted-foreground",
                )}
              >
                {done ? <Check className="h-3 w-3" /> : n}
              </div>
              <span
                className={cn("font-medium", active ? "text-foreground" : "text-muted-foreground")}
              >
                {label}
              </span>
              {i < 2 && <ChevronRight className="mx-1 h-3.5 w-3.5 text-muted-foreground" />}
            </div>
          );
        })}
      </div>

      {/* Step 1 — Company details */}
      {step === 1 && (
        <div className="space-y-4">
          {/* ── TK Customer search ── */}
          <div>
            <span className="mb-1 block text-xs font-medium text-muted-foreground">
              TK Customer / Partner Name <span className="text-destructive">*</span>
            </span>
            <div className="relative">
              <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-8 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                placeholder="Search existing TK customers or type a new name…"
                maxLength={FIELD_MAX.clientName}
                value={tkSearch}
                onFocus={() => setTkDropOpen(true)}
                onChange={(e) => {
                  const filtered = e.target.value.replace(/[^a-zA-Z\s-']/g, "").slice(0, FIELD_MAX.clientName);
                  setTkSearch(filtered);
                  setTkDropOpen(true);
                  if (selectedExisting && filtered !== selectedExisting.name) {
                    setSelectedExisting(null);
                    setSvSearch("");
                    setSvDropOpen(false);
                    setSvAlreadyExists(false);
                    setS((p) => ({
                      ...p,
                      clientName: filtered,
                      subVentureName: "",
                      customerId: "C" + String((apiClients?.length ?? 0) + 1).padStart(3, "0"),
                    }));
                  } else {
                    setS((p) => ({ ...p, clientName: filtered }));
                  }
                }}
                onBlur={() => setTimeout(() => setTkDropOpen(false), 150)}
              />
              {selectedExisting && (
                <button
                  type="button"
                  className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  onClick={() => {
                    setSelectedExisting(null);
                    setTkSearch("");
                    setS((p) => ({
                      ...p,
                      clientName: "",
                      engagementManager: "",
                      salesManager: "",
                      phoneNumber: "",
                      city: "",
                      country: "",
                      industry: "",
                      businessType: "",
                      customerId: "C" + String((apiClients?.length ?? 0) + 1).padStart(3, "0"),
                    }));
                    setSvSearch("");
                    setSvDropOpen(false);
                    setSvAlreadyExists(false);
                  }}
                  title="Clear selection"
                >
                  <X className="h-3.5 w-3.5" />
                </button>
              )}
              {tkDropOpen && (
                <div className="absolute left-0 right-0 top-full z-50 mt-1 max-h-56 overflow-y-auto rounded-md border border-border bg-popover shadow-lg">
                  {filteredTk.length > 0 && (
                    <>
                      <div className="px-3 py-1.5 text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
                        Existing Customers
                      </div>
                      {filteredTk.map((c) => (
                        <button
                          key={c.id}
                          type="button"
                          className="flex w-full items-center gap-3 px-3 py-2 text-left text-sm hover:bg-accent"
                          onMouseDown={() => {
                            setSelectedExisting(c);
                            setTkSearch(c.name);
                            setTkDropOpen(false);
                            setS((p) => ({
                              ...p,
                              clientName: c.name,
                              customerId: c.id,
                              engagementManager: p.engagementManager.trim() || c.engagementManager || "",
                              salesManager: p.salesManager.trim() || c.salesManager || "",
                              phoneNumber:
                                (c as { phoneNumber?: string }).phoneNumber ?? p.phoneNumber,
                              city: c.city ?? p.city,
                              country: c.country ?? p.country,
                              industry: c.industry ?? p.industry,
                              businessType: c.businessType ?? p.businessType,
                              contacts: [
                                {
                                  name: "",
                                  email: "",
                                  phone: "",
                                  designation: "",
                                  contactType: "",
                                },
                              ],
                            }));
                          }}
                        >
                          <span className="flex h-7 w-7 items-center justify-center rounded-md bg-gradient-to-br from-primary to-info text-[11px] font-semibold text-primary-foreground shrink-0">
                            {c.logo}
                          </span>
                          <div className="min-w-0 flex-1">
                            <div className="truncate font-medium">{c.name}</div>
                            <div className="truncate text-[11px] text-muted-foreground">
                              {c.industry} · {c.id}
                            </div>
                          </div>
                          <span className="shrink-0 rounded-full bg-success/10 px-2 py-0.5 text-[10px] font-medium text-success">
                            Existing
                          </span>
                        </button>
                      ))}
                    </>
                  )}
                  {tkSearch.trim() && (
                    <button
                      type="button"
                      className="flex w-full items-center gap-2 border-t border-border px-3 py-2 text-left text-sm text-primary hover:bg-accent"
                      onMouseDown={() => {
                        setSelectedExisting(null);
                        setSvSearch("");
                        setSvDropOpen(false);
                        setSvAlreadyExists(false);
                        setS((p) => ({ ...p, clientName: tkSearch.trim(), subVentureName: "" }));
                        setTkDropOpen(false);
                      }}
                    >
                      <Plus className="h-3.5 w-3.5" />
                      Add <span className="font-semibold">"{tkSearch.trim()}"</span> as new TK Customer
                    </button>
                  )}
                </div>
              )}
            </div>
            {selectedExisting && (
              <p className="mt-1 text-[11px] text-success">
                ✓ Existing customer selected — details auto-filled. Add a new sub-venture below.
              </p>
            )}
          </div>

          {/* ── Existing client info banner ── */}
          {selectedExisting && (
            <div className="rounded-lg border border-info/30 bg-info/5 px-3 py-2.5 text-xs space-y-1">
              <p className="font-semibold text-foreground">{selectedExisting.name}</p>
              <p className="text-muted-foreground">
                {selectedExisting.industry} · ID: {selectedExisting.id}
              </p>
              {selectedExisting.engagementManager && (
                <p className="text-muted-foreground">EM: {selectedExisting.engagementManager}</p>
              )}
              {selectedExisting.salesManager && (
                <p className="text-muted-foreground">SM: {selectedExisting.salesManager}</p>
              )}
            </div>
          )}

          {/* ── Sub-venture name — searchable when existing client, plain input for new ── */}
          {selectedExisting ? (
            <div>
              <span className="mb-1 block text-xs font-medium text-muted-foreground">
                End Customer Name / Sub-venture Name <span className="text-destructive">*</span>
              </span>
              {(selectedExisting.subVentures?.length ?? 0) > 0 && (
                <p className="mb-1.5 text-[11px] text-muted-foreground">
                  Existing sub-ventures:{" "}
                  {selectedExisting.subVentures!.map((sv) => sv.name).join(", ")}
                </p>
              )}
              <div className="relative">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  className="h-9 w-full rounded-md border border-input bg-card pl-8 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
                  placeholder="Search existing sub-ventures or enter a new one…"
                  maxLength={FIELD_MAX.subVentureName}
                  value={svSearch || s.subVentureName}
                  onFocus={() => setSvDropOpen(true)}
                  onChange={(e) => {
                    const val = e.target.value.slice(0, FIELD_MAX.subVentureName);
                    setSvSearch(val);
                    setSvDropOpen(true);
                    const match = (selectedExisting.subVentures ?? []).find(
                      (sv) => sv.name.toLowerCase() === val.trim().toLowerCase(),
                    );
                    if (match) {
                      setSvAlreadyExists(true);
                      setS((p) => ({ ...p, subVentureName: match.name }));
                    } else {
                      setSvAlreadyExists(false);
                      setS((p) => ({ ...p, subVentureName: val }));
                    }
                  }}
                  onBlur={() => setTimeout(() => setSvDropOpen(false), 150)}
                />
                {svDropOpen && (selectedExisting.subVentures?.length ?? 0) > 0 && (
                  <div className="absolute left-0 right-0 top-full z-50 mt-1 max-h-48 overflow-y-auto rounded-md border border-border bg-popover shadow-lg">
                    <div className="px-3 py-1.5 text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
                      Existing Sub-ventures
                    </div>
                    {selectedExisting
                      .subVentures!.filter(
                        (sv) =>
                          svSearch.trim() === "" ||
                          sv.name.toLowerCase().includes(svSearch.toLowerCase()),
                      )
                      .map((sv) => (
                        <button
                          key={sv.name}
                          type="button"
                          className="flex w-full items-center justify-between px-3 py-2 text-left text-sm hover:bg-accent"
                          onMouseDown={() => {
                            setSvSearch(sv.name);
                            setS((p) => ({ ...p, subVentureName: sv.name }));
                            setSvAlreadyExists(true);
                            setSvDropOpen(false);
                          }}
                        >
                          <span className="font-medium">{sv.name}</span>
                          <span className="rounded-full bg-warning/10 px-2 py-0.5 text-[10px] font-medium text-warning">
                            Already exists
                          </span>
                        </button>
                      ))}
                    {svSearch.trim() && !svAlreadyExists && (
                      <button
                        type="button"
                        className="flex w-full items-center gap-2 border-t border-border px-3 py-2 text-left text-sm text-primary hover:bg-accent"
                        onMouseDown={() => {
                          setS((p) => ({ ...p, subVentureName: svSearch.trim() }));
                          setSvAlreadyExists(false);
                          setSvDropOpen(false);
                        }}
                      >
                        <Plus className="h-3.5 w-3.5" />
                        Add <span className="font-semibold">"{svSearch.trim()}"</span> as new sub-venture
                      </button>
                    )}
                  </div>
                )}
              </div>
              {(svAlreadyExists || duplicatePairExists) && matchingExistingClient && (
                <p className="mt-1 text-[11px] text-destructive">
                  Client and sub-venture already exist under {matchingExistingClient.name}.
                </p>
              )}
              {!duplicatePairExists && selectedExisting && s.subVentureName.trim() && (
                <p className="mt-1 text-[11px] text-success">
                  ✓ New sub-venture will be added under {selectedExisting.name}
                </p>
              )}
            </div>
          ) : (
            <Field
              label="End Customer Name / Sub-venture Name"
              required
              error={
                duplicatePairExists && matchingExistingClient
                  ? `Client and sub-venture already exist under ${matchingExistingClient.name}.`
                  : undefined
              }
            >
              <input
                className={inputCls}
                value={s.subVentureName}
                maxLength={FIELD_MAX.subVentureName}
                onChange={(e) => u("subVentureName", e.target.value.slice(0, FIELD_MAX.subVentureName))}
                placeholder="Enter sub-venture or end customer name…"
              />
            </Field>
          )}

          {/* Stakeholders — always editable (new TK customer or existing + sub-venture) */}
          <div className="grid gap-3 sm:grid-cols-2">
            <SearchableSelect
              label="Engagement Manager"
              required={!selectedExisting}
              placeholder={emLoading ? "Loading engagement managers…" : "Select engagement manager…"}
              searchPlaceholder="Search by name, email, or code…"
              disabled={emLoading}
              disabledHint="Loading engagement managers…"
              options={emOptions}
              value={s.engagementManager}
              onChange={(name) => u("engagementManager", name)}
            />
            <Field label="Sales Manager">
              <input
                className={inputCls}
                maxLength={FIELD_MAX.salesManager}
                value={s.salesManager}
                placeholder="Enter sales manager name…"
                onChange={(e) =>
                  u(
                    "salesManager",
                    e.target.value.replace(/[^a-zA-Z\s-']/g, "").slice(0, FIELD_MAX.salesManager),
                  )
                }
              />
            </Field>
          </div>

          {/* ── New TK customer fields — only shown when not selecting existing ── */}
          {!selectedExisting && (
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="Customer ID">
                <input
                  className={cn(readOnlyCls, "font-mono")}
                  value="Auto-generated on creation"
                  readOnly
                />
              </Field>
              <Field label="Country / Region" required>
                <select
                  className={inputCls}
                  value={s.country}
                  onChange={(e) => {
                    const next = e.target.value;
                    setS((p) => ({ ...p, country: next, city: "", phoneNumber: "" }));
                  }}
                >
                  <option value="">Select country</option>
                  {countries.map((c) => (
                    <option key={c.id} value={c.name}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </Field>
              <Field label="City" required>
                <select
                  className={inputCls}
                  value={s.city}
                  disabled={!s.country}
                  onChange={(e) => u("city", e.target.value)}
                >
                  <option value="">
                    {s.country ? "Select city" : "Select country first"}
                  </option>
                  {cities.map((c) => (
                    <option key={c.id} value={c.name}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </Field>
              <Field
                label="Group SPOC Contact"
                required
                error={
                  s.phoneNumber && s.phoneNumber.length !== countryPhoneDigits
                    ? `Group SPOC Contact must be ${countryPhoneDigits} digits for ${s.country || "selected country"}`
                    : null
                }
              >
                <div className="relative flex rounded-md">
                  <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
                    {countryDialCode}
                  </span>
                  <input
                    className={cn(
                      fieldInputCls(inputCls, Boolean(s.phoneNumber && s.phoneNumber.length !== countryPhoneDigits)),
                      "rounded-l-none",
                    )}
                    type="tel"
                    inputMode="numeric"
                    maxLength={countryPhoneDigits}
                    placeholder={s.country ? "9".repeat(countryPhoneDigits) : "Select country first"}
                    value={s.phoneNumber}
                    disabled={!s.country}
                    onChange={(e) => {
                      const digits = e.target.value.replace(/\D/g, "").slice(0, countryPhoneDigits);
                      u("phoneNumber", digits);
                    }}
                  />
                </div>
              </Field>
              <Field label="Industry" required>
                <select
                  className={inputCls}
                  value={s.industry}
                  onChange={(e) => u("industry", e.target.value)}
                >
                  <option value="">Select industry</option>
                  {[
                    "Banking",
                    "Healthcare",
                    "Retail",
                    "Logistics",
                    "Energy",
                    "Manufacturing",
                    "Telecom",
                    "Media",
                  ].map((o) => (
                    <option key={o}>{o}</option>
                  ))}
                </select>
              </Field>
              <Field label="Business Type">
                <select className={readOnlyCls} value={s.businessType} disabled>
                  <option value="">Select business type</option>
                  {["Enterprise", "Mid-Market", "SMB", "Public Sector"].map((o) => (
                    <option key={o}>{o}</option>
                  ))}
                </select>
              </Field>
              <Field label="Created At">
                <input
                  className={readOnlyCls}
                  value={format(new Date(s.createdAt), "dd MMM yyyy, HH:mm")}
                  readOnly
                />
              </Field>
              <Field label="Created By">
                <input className={readOnlyCls} value={s.createdBy} readOnly />
              </Field>
            </div>
          )}

          {/* ── Existing client — show locked ID + created info ── */}
          {selectedExisting && (
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="Customer ID">
                <input className={readOnlyCls} value={selectedExisting.id} readOnly />
              </Field>
              <Field label="Created By">
                <input className={readOnlyCls} value={s.createdBy} readOnly />
              </Field>
            </div>
          )}
        </div>
      )}

      {/* Step 2 — Contacts + registration numbers */}
      {step === 2 && (
        <div className="space-y-3">
          {s.contacts.map((ct, idx) => (
            <div key={idx} className="rounded-lg border border-border bg-background p-3">
              <div className="mb-2 flex items-center justify-between">
                <span className="text-xs font-medium text-muted-foreground">
                  Contact {s.contacts.length > 1 ? `${idx + 1}` : "Person"}
                </span>
                {idx > 0 && (
                  <button
                    type="button"
                    onClick={() => removeContact(idx)}
                    className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2 py-0.5 text-xs text-muted-foreground hover:bg-accent hover:text-foreground"
                  >
                    <X className="h-3 w-3" /> Remove
                  </button>
                )}
              </div>
              <div className="grid gap-3 sm:grid-cols-2">
                <Field label="Contact Person" required>
                  <input
                    className={inputCls}
                    value={ct.name}
                    maxLength={FIELD_MAX.personName}
                    placeholder="Full name"
                    onChange={(e) => {
                      const filtered = e.target.value
                        .replace(/[^a-zA-Z\s-']/g, "")
                        .slice(0, FIELD_MAX.personName);
                      updateContact(idx, "name", filtered);
                    }}
                  />
                </Field>
                <Field label="Contact Type" required>
                  <select
                    className={inputCls}
                    value={ct.contactType}
                    onChange={(e) => updateContact(idx, "contactType", e.target.value)}
                  >
                    <option value="">Select contact type</option>
                    {["Accounts", "Procurement", "Technical", "Legal"].map((o) => (
                      <option key={o} value={o}>
                        {o}
                      </option>
                    ))}
                  </select>
                </Field>
                <Field label="Email" required error={ct.email.trim() ? emailError(ct.email, false) : undefined}>
                  <input
                    type="text"
                    inputMode="email"
                    className={fieldInputCls(
                      inputCls,
                      Boolean(ct.email.trim() && emailError(ct.email, false)),
                    )}
                    value={ct.email}
                    maxLength={FIELD_MAX.email}
                    placeholder="name@company.com"
                    onChange={(e) =>
                      updateContact(idx, "email", toEmailInput(e.target.value))
                    }
                    onBlur={() => updateContact(idx, "email", ct.email.trim())}
                  />
                </Field>
                <Field label="Phone" required error={phoneError(ct.phone)}>
                  <div className="relative flex rounded-md">
                    <span className="inline-flex items-center rounded-l-md border border-r-0 border-input bg-muted px-2.5 text-xs font-semibold text-muted-foreground select-none">
                      +91
                    </span>
                    <input
                      className={cn(
                        fieldInputCls(inputCls, Boolean(phoneError(ct.phone))),
                        "rounded-l-none",
                      )}
                      type="tel"
                      inputMode="numeric"
                      maxLength={FIELD_MAX.phone}
                      placeholder="9876543210"
                      value={ct.phone}
                      onChange={(e) => updateContact(idx, "phone", toTenDigitPhone(e.target.value))}
                    />
                  </div>
                </Field>
                <Field label="Designation" required>
                  <input
                    className={inputCls}
                    maxLength={FIELD_MAX.designation}
                    placeholder="eg ciso/spoc etc."
                    value={ct.designation}
                    onChange={(e) =>
                      updateContact(idx, "designation", e.target.value.slice(0, FIELD_MAX.designation))
                    }
                  />
                </Field>
              </div>
              <div className="mt-3 flex items-center gap-2">
                <button
                  type="button"
                  onClick={addContact}
                  disabled={s.contacts.length >= MAX_CONTACTS}
                  className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <Plus className="h-3 w-3" /> Add
                </button>
                {s.contacts.length >= MAX_CONTACTS && (
                  <span className="text-[11px] text-muted-foreground">Maximum of 4 contacts</span>
                )}
              </div>
            </div>
          ))}
          <div className="mt-4 pt-4 border-t border-border">
            <Field label="KYC Document" required>
              <div className="relative">
                <label
                  className={cn(
                    "flex h-9 w-full cursor-pointer items-center gap-2 rounded-md border border-dashed border-input bg-card px-3 text-sm transition-colors hover:bg-accent",
                    s.kycFile && "border-success/50 bg-success/5",
                  )}
                >
                  <input
                    type="file"
                    accept="*/*"
                    className="absolute inset-0 h-full w-full cursor-pointer opacity-0"
                    onChange={(e) => setS((p) => ({ ...p, kycFile: e.target.files?.[0] ?? null }))}
                  />
                  {s.kycFile ? (
                    <>
                      <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-success/15 text-success">
                        <Check className="h-3 w-3" />
                      </span>
                      <span className="flex-1 truncate text-xs font-medium text-foreground">
                        {s.kycFile.name}
                      </span>
                      <span className="text-[10px] text-muted-foreground">
                        {(s.kycFile.size / 1024).toFixed(0)} KB
                      </span>
                      <button
                        type="button"
                        onClick={(e) => {
                          e.preventDefault();
                          e.stopPropagation();
                          setS((p) => ({ ...p, kycFile: null }));
                        }}
                        className="ml-1 rounded p-0.5 hover:bg-destructive/10 hover:text-destructive cursor-pointer"
                        aria-label="Remove file"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </>
                  ) : (
                    <>
                      <span className="text-muted-foreground">📎</span>
                      <span className="text-xs text-muted-foreground">
                        Click to attach KYC document — any format accepted
                      </span>
                    </>
                  )}
                </label>
              </div>
              <p className="mt-1 text-[11px] text-muted-foreground">
                Required · PDF, image, Word, or any other format
              </p>
            </Field>
          </div>
          <Field label="Notes (this sub-venture)" className="pt-1">
            <textarea
              rows={3}
              maxLength={2000}
              className={cn(inputCls, "py-2")}
              value={s.notes}
              onChange={(e) => u("notes", e.target.value)}
              placeholder="Onboarding notes for this sub-venture…"
            />
            <p className="mt-1 text-right text-[10px] tabular-nums text-muted-foreground">
              {s.notes.length}/2000
            </p>
          </Field>
        </div>
      )}

      {/* Step 3 — Review */}
      {step === 3 && (
        <div className="rounded-lg border border-border bg-accent/20 p-4">
          <h4 className="mb-3 text-sm font-semibold">
            {selectedExisting ? "Adding Sub-venture to Existing Customer" : "New Customer Summary"}
          </h4>
          <dl className="grid grid-cols-2 gap-x-4 gap-y-2 text-xs">
            <Row label="TK Customer" v={s.clientName || selectedExisting?.name || "—"} />
            <Row label="Sub-venture Name" v={s.subVentureName} />
            <Row
              label="Customer ID"
              v={
                selectedExisting
                  ? formatCustomerId(selectedExisting.id)
                  : "Auto-assigned on creation"
              }
            />
            {!selectedExisting && (
              <>
                <Row label="Engagement Manager" v={s.engagementManager} />
                <Row label="Sales Manager" v={s.salesManager} />
                <Row label="Group SPOC Contact" v={s.phoneNumber ? `${countryDialCode} ${s.phoneNumber}` : "—"} />
                <Row label="City" v={s.city} />
                <Row label="Country / Region" v={s.country} />
                <Row label="Industry" v={s.industry} />
              </>
            )}
            {selectedExisting && (
              <>
                <Row label="Engagement Manager" v={s.engagementManager || selectedExisting.engagementManager || "—"} />
                <Row label="Sales Manager" v={s.salesManager || selectedExisting.salesManager || "—"} />
              </>
            )}
            <Row label="Created At" v={format(new Date(s.createdAt), "dd MMM yyyy, HH:mm")} />
            <Row label="Created By" v={s.createdBy} />
            
            {/* Clickable KYC Document Row with Preview button */}
            <div className="col-span-2 flex items-center justify-between rounded-lg border border-border bg-card px-3 py-2 text-xs">
              <div className="min-w-0 flex-1 pr-2">
                <dt className="text-muted-foreground font-medium flex items-center gap-1.5">
                  <FileText className="h-3.5 w-3.5 text-primary" /> KYC Document
                </dt>
                <dd className="truncate font-mono font-medium text-foreground mt-0.5">
                  {s.kycFile ? s.kycFile.name : "—"}
                </dd>
              </div>
              {s.kycFile && (
                <button
                  type="button"
                  onClick={() => setPreviewKyc(true)}
                  className="inline-flex shrink-0 items-center gap-1 rounded-md border border-primary/30 bg-primary/10 px-2.5 py-1 text-[11px] font-semibold text-primary hover:bg-primary/20 transition-colors cursor-pointer shadow-2xs"
                  title="Preview KYC Document in popup window"
                >
                  <Eye className="h-3.5 w-3.5" /> Preview KYC
                </button>
              )}
            </div>
          </dl>
          <div className="mt-3 space-y-2">
            <p className="text-xs font-medium text-muted-foreground">Contacts</p>
            {s.contacts.map((ct, idx) => (
              <dl
                key={idx}
                className="grid grid-cols-2 gap-x-4 gap-y-1 rounded-md border border-border bg-card px-3 py-2 text-xs"
              >
                <Row label="Name" v={ct.name} />
                <Row label="Contact Type" v={ct.contactType || "—"} />
                <Row label="Email" v={ct.email} />
                <Row label="Phone" v={ct.phone ? `+91 ${ct.phone}` : "—"} />
                <Row label="Designation" v={ct.designation || "—"} />
              </dl>
            ))}
          </div>
          {s.notes && (
            <div className="mt-3">
              <p className="text-xs font-medium text-muted-foreground">Notes</p>
              <p className="mt-0.5 text-xs">{s.notes}</p>
            </div>
          )}
        </div>
      )}

      {/* Footer navigation */}
      <div className="mt-6 flex items-center justify-between border-t border-border pt-4">
        <button
          onClick={() => (step === 1 ? onClose() : setStep(step - 1))}
          className="rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent cursor-pointer"
        >
          {step === 1 ? "Cancel" : "Back"}
        </button>
        {step < 3 ? (
          <button
            onClick={handleNext}
            className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 cursor-pointer"
          >
            Next <ArrowRight className="h-3 w-3" />
          </button>
        ) : (
          <button
            disabled={submitting}
            onClick={() => void submit()}
            className="rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50 cursor-pointer"
          >
            {submitting ? "Saving…" : "Save Customer"}
          </button>
        )}
      </div>
    </Modal>
    <KycDocPreviewModal
      open={previewKyc && Boolean(s.kycFile)}
      onClose={() => setPreviewKyc(false)}
      file={s.kycFile}
      fileName={s.kycFile?.name}
      clientName={s.clientName || s.subVentureName || "New Customer"}
      subVentureName={s.subVentureName}
    />
    </>
  );
}

function CustomerDrawer({ client, onClose }: { client: Client; onClose: () => void }) {
  const projects = allProjects();
  const projs = projects.filter((p) => p.clientId === client.id);
  const buckets = categorizeClientProjects(projs);
  return (
    <div
      className="fixed inset-0 z-40 flex items-stretch justify-end bg-black/30"
      onClick={onClose}
    >
      <div
        className="w-full max-w-2xl overflow-y-auto bg-card shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >
        <header className="sticky top-0 z-10 flex items-center gap-3 border-b border-border bg-card p-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-info text-base font-semibold text-primary-foreground">
            {client.logo}
          </div>
          <div className="flex-1">
            <h2 className="text-base font-semibold">{client.name}</h2>
            <p className="text-xs text-muted-foreground">
              {client.industry} · {client.contact}
            </p>
          </div>
          <button onClick={onClose} className="rounded-md p-2 hover:bg-accent" aria-label="Close">
            <X className="h-4 w-4" />
          </button>
        </header>
        <Section title="New Projects" projs={buckets.new} empty="No new projects" />
        <Section title="Ongoing Projects" projs={buckets.ongoing} empty="No ongoing projects" />
        <Section title="Completed Projects" projs={buckets.completed} empty="No completed projects" />
        <Section title="On Hold Projects" projs={buckets.onHold} empty="No on-hold projects" />
        <Section title="Archived Projects" projs={buckets.archived} empty="No archived projects" />
      </div>
    </div>
  );
}

function Section({
  title,
  projs,
  empty,
}: {
  title: string;
  projs: ReturnType<typeof allProjects>;
  empty: string;
}) {
  return (
    <section className="border-b border-border p-4">
      <h3 className="mb-3 flex items-center gap-2 text-sm font-semibold">
        <Building2 className="h-4 w-4 text-muted-foreground" />
        {title} · {projs.length}
      </h3>
      {projs.length === 0 ? (
        <p className="text-sm text-muted-foreground">{empty}</p>
      ) : (
        <ul className="space-y-2">
          {projs.map((p) => (
            <li key={p.id}>
              <Link
                to="/projects/$projectId"
                params={{ projectId: p.id }}
                className="block rounded-lg border border-border bg-background p-3 hover:bg-accent/40"
              >
                <div className="flex flex-wrap items-center gap-2">
                  <span className="text-sm font-medium">{p.name}</span>
                  <HealthPill status={p.health} />
                  <StatusPill status={p.status} />
                  <span className="ml-auto text-xs tabular-nums text-muted-foreground">
                    {p.progress}%
                  </span>
                </div>
                <p className="mt-1 line-clamp-1 text-xs text-muted-foreground">{p.description}</p>
                <ProgressBar value={p.progress} className="mt-2" />
              </Link>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
