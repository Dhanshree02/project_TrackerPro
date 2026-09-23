import { createFileRoute, Link, Navigate, useNavigate } from "@tanstack/react-router";
import { useEffect, useMemo, useState, useRef } from "react";
import {
  LayoutGrid,
  List,
  Search,
  ArrowRight,
  Calendar,
  Plus,
  X,
  ChevronRight,
  Check,
  Trash2,
  Calculator,
  FileText,
  Clock,
  User,
} from "lucide-react";
import { toast } from "sonner";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { allClients, dhStore, useDhStore, type WbsDraft } from "@/lib/dh-store";
import { fetchProjectDrafts, deleteProjectDraft, type ProjectDraftListDto } from "@/lib/api/project-drafts";
import { fetchProjects, type ApiProject } from "@/lib/api/projects";
import { fetchClients, mapApiClient, type ApiClient } from "@/lib/api/clients";
import { type Project, type Client, people, type Person } from "@/lib/mock-data";
import { HealthPill, StatusPill, ProgressBar, PriorityPill, Avatar, RenewedProjectTag } from "@/components/pills";
import { isRenewedProject } from "@/lib/project-renewal";
import { getProjectEMs, getProjectPMs, getProjectTLs, formatPeopleSummary } from "@/lib/dh-helpers";
import { cn } from "@/lib/utils";
import { Field, HorizontalField } from "@/components/form-row";
import {
  FIELD_MAX,
  emailError,
  fieldInputCls,
} from "@/lib/form-validation";
import { useDraggable } from "@/hooks/use-draggable";

export const Route = createFileRoute("/projects/")({
  head: () => ({
    meta: [
      { title: "Projects — Pulse PMO" },
      { name: "description", content: "Active, archived and all projects in one workspace." },
    ],
  }),
  component: ProjectsPage,
});

const tabs = ["Active Projects", "Archived Projects", "All Projects"] as const;
type Tab = (typeof tabs)[number];

function ProjectsPage() {
  const { isDhanshree, isEmployee, assignedProjects } = useRoleContext();
  const { hasPermission } = usePermissions();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>("Active Projects");
  const [view, setViewState] = useState<"card" | "list">(() => {
    if (typeof window !== "undefined") {
      const saved = localStorage.getItem("projects-view-mode");
      if (saved === "card" || saved === "list") return saved;
    }
    return "card";
  });

  const setView = (v: "card" | "list") => {
    setViewState(v);
    if (typeof window !== "undefined") {
      localStorage.setItem("projects-view-mode", v);
    }
  };
  const [q, setQ] = useState("");
  const [draftsOpen, setDraftsOpen] = useState(false);
  const [backendDrafts, setBackendDrafts] = useState<ProjectDraftListDto[]>([]);
  const [loadingDrafts, setLoadingDrafts] = useState(false);
  const [draftSearch, setDraftSearch] = useState("");

  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);
  const localDrafts = useDhStore((s) => s.wbsDrafts);
  const leadershipAssignments = useDhStore((s) => s.leadershipAssignments);
  const prereqs = useDhStore((s) => s.prereqs);

  const loadDrafts = async (searchQuery?: string) => {
    setLoadingDrafts(true);
    try {
      const res = await fetchProjectDrafts({
        perPage: 100,
        search: searchQuery !== undefined ? searchQuery : draftSearch,
      });
      if (res?.items) {
        setBackendDrafts(res.items);
      }
    } catch (e) {
      console.warn("Failed to load drafts from backend, using local store:", e);
    } finally {
      setLoadingDrafts(false);
    }
  };

  useEffect(() => {
    loadDrafts();
  }, [draftsOpen]);

  const drafts = useMemo(() => {
    if (backendDrafts.length > 0) return backendDrafts;
    return localDrafts.map((ld) => ({
      id: ld.id,
      projectName: ld.projectName,
      clientId: ld.clientId,
      clientName: ld.clientName,
      salesPerson: ld.salesPerson,
      createdByName: ld.savedBy || "Local User",
      updatedByName: ld.savedBy || null,
      status: "active",
      rowVersion: 0,
      createdAtUtc: ld.savedAt,
      updatedAtUtc: ld.savedAt,
    }));
  }, [backendDrafts, localDrafts]);

  async function handleDeleteDraft(draftId: string) {
    try {
      await deleteProjectDraft(draftId);
      toast.success("Draft deleted");
    } catch {
      dhStore.deleteDraft(draftId);
      toast.success("Draft deleted from local storage");
    }
    loadDrafts();
  }

  // Live database records only — no mock data
  const [dbProjects, setDbProjects] = useState<ApiProject[]>([]);
  const [dbClients, setDbClients] = useState<ApiClient[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;
    setIsLoading(true);
    setLoadError(null);

    Promise.all([
      fetchProjects({ perPage: 500 }),
      fetchClients(1, 200),
    ])
      .then(([projRes, clientRes]) => {
        if (!active) return;
        if (projRes?.items) {
          setDbProjects(projRes.items);
        } else {
          setDbProjects([]);
        }
        if (clientRes) {
          setDbClients(clientRes);
        }
      })
      .catch((err) => {
        console.error(err);
        if (!active) return;
        setDbProjects([]);
        const message =
          err instanceof Error && err.message
            ? err.message
            : "Could not load projects from the API. Is the backend running on port 5194?";
        setLoadError(message);
        toast.error("Projects failed to load", { description: message });
      })
      .finally(() => {
        if (active) setIsLoading(false);
      });

    return () => {
      active = false;
    };
  }, [extraCount]);

  const clients = useMemo(() => {
    return dbClients.map(mapApiClient);
  }, [dbClients]);

  const projects = useMemo(() => {
    return dbProjects.map((p) => {
      const renewedFromProjId = p.renewedFromProjectId ?? undefined;
      const renewedFromWbs = p.renewedFromWbsId ?? undefined;
      const isRenewalVal = Boolean(
        renewedFromProjId ||
        renewedFromWbs ||
        p.renewedFromProjectId ||
        p.renewedFromWbsId
      );

      return {
        id: p.id,
        name: p.name,
        clientId: p.clientId,
        wbsId: p.wbsId ?? undefined,
        subVenture: p.subVentureName ?? undefined,
        status: (p.status as any) || "ongoing",
        health: (p.health as any) || "green",
        progress: p.progress ?? 0,
        pmId: p.projectManagerId ?? "",
        tlId: p.teamLeadId ?? "",
        teamIds: [],
        startDate: p.startDate ?? "",
        endDate: p.endDate ?? "",
        budget: Number(p.budget) || 0,
        spent: Number(p.spent) || 0,
        description: p.description ?? "",
        wbs: [],
        tasks: [],
        engagementManager: p.engagementManager ?? undefined,
        salesPerson: p.salesPerson ?? undefined,
        contractType: p.contractType ?? undefined,
        projectType: p.projectType ?? undefined,
        currency: p.currency ?? "INR",
        taxPercent: p.taxPercent ?? 18,
        totalHours: Number(p.totalHours) || 0,
        totalDays: Number(p.totalDays) || 0,
        invoiceValue: Number(p.invoiceValue) || 0,
        projectSeqId: p.projectCode ?? undefined,
        renewedFromProjectId: renewedFromProjId,
        renewedFromWbsId: renewedFromWbs,
        isRenewal: isRenewalVal,
        projectManagerId: p.projectManagerId ?? undefined,
        projectManagerName: p.projectManagerName ?? undefined,
        teamLeadId: p.teamLeadId ?? undefined,
        teamLeadName: p.teamLeadName ?? undefined,
        seniorProjectManager: undefined,
      } as Project;
    });
  }, [dbProjects]);

  const visible = useMemo(() => {
    const assignedIds = new Set(assignedProjects.map((p) => p.id));
    return projects.filter((p) => {
      // Extra WBS-created projects are not in the static assignment list.
      if (!assignedIds.has(p.id) && !isDhanshree && dbProjects.length === 0) return false;
      const isArchived =
        p.status === "completed" || p.status === "archived" || (p.status as any) === "Archived";
      if (tab === "Active Projects" && isArchived) return false;
      if (tab === "Archived Projects" && !isArchived) return false;
      if (!q.trim()) return true;
      const c = clients.find((c) => c.id === p.clientId);
      return [p.name, c?.name ?? "", p.description].some((v) =>
        v.toLowerCase().includes(q.toLowerCase()),
      );
    });
  }, [tab, q, projects, clients, assignedProjects, isDhanshree, dbProjects.length]);

  if (!isDhanshree && !hasPermission("projects.view")) return <Navigate to="/" />;

  const priorities: Array<"low" | "medium" | "high" | "critical"> = [
    "high",
    "medium",
    "critical",
    "medium",
    "high",
    "low",
    "medium",
    "high",
    "critical",
  ];

  return (
    <AppShell title="Projects" subtitle="Active, archived and all projects across your portfolio">
      <div className="mb-4 flex flex-wrap items-center gap-3">
        <div className="flex gap-1 rounded-lg border border-border bg-card p-1 text-sm shadow-sm">
          {tabs.map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={cn(
                "rounded-md px-3 py-1.5 font-medium",
                tab === t
                  ? "bg-primary text-primary-foreground"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              {t}
            </button>
          ))}
        </div>
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search project or customer…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div className="ml-auto flex items-center gap-2">
          {/* Drafts button — hidden for Employees (no project creation) */}
          {!isEmployee && (
            <button
              onClick={() => setDraftsOpen(true)}
              className={cn(
                "relative inline-flex items-center gap-1.5 rounded-md border border-border bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent",
                draftsOpen && "bg-accent",
              )}
            >
              <FileText className="h-3.5 w-3.5" />
              Drafts
              {drafts.length > 0 && (
                <span className="flex h-4 min-w-4 items-center justify-center rounded-full bg-warning/80 px-1 text-[10px] font-bold text-white">
                  {drafts.length}
                </span>
              )}
            </button>
          )}
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
          {hasPermission("projects.create") && (
            <button
              onClick={() => navigate({ to: "/projects/new" })}
              className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all"
            >
              <Plus className="h-4 w-4" /> New Project
            </button>
          )}
        </div>
      </div>

      {isLoading ? (
        view === "card" ? (
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <div
                key={i}
                className="flex flex-col justify-between rounded-xl border border-border bg-card p-4 shadow-sm animate-pulse h-56"
              >
                <div className="flex items-start gap-3">
                  <div className="h-10 w-10 rounded-lg bg-muted" />
                  <div className="flex-1 space-y-2">
                    <div className="h-3 w-1/3 bg-muted rounded" />
                    <div className="h-4 w-3/4 bg-muted rounded" />
                  </div>
                </div>
                <div className="space-y-2 mt-4">
                  <div className="h-2 bg-muted rounded" />
                  <div className="grid grid-cols-2 gap-2 pt-2">
                    <div className="h-3 bg-muted rounded" />
                    <div className="h-3 bg-muted rounded" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm p-4">
            <div className="space-y-3">
              {[1, 2, 3, 4, 5, 6].map((i) => (
                <div key={i} className="h-10 bg-muted/60 rounded animate-pulse" />
              ))}
            </div>
          </div>
        )
      ) : loadError ? (
        <div className="rounded-xl border border-destructive/30 bg-destructive/5 p-6 text-center space-y-2">
          <p className="text-sm font-semibold text-destructive">Could not load projects from the database</p>
          <p className="text-xs text-muted-foreground max-w-lg mx-auto">{loadError}</p>
          <p className="text-xs text-muted-foreground">
            Start the API with <code className="rounded bg-muted px-1">dotnet run --project apps/backend/PMS.API.csproj --urls http://localhost:5194</code> against local Postgres, then refresh.
          </p>
          <button
            type="button"
            onClick={() => window.location.reload()}
            className="mt-2 inline-flex items-center rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
          >
            Retry
          </button>
        </div>
      ) : visible.length === 0 ? (
        <div className="rounded-xl border border-border bg-card p-8 text-center text-sm text-muted-foreground">
          No projects found in the database for this filter.
        </div>
      ) : view === "card" ? (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {visible.map((p, i) => {
            const client = clients.find((c) => c.id === p.clientId) ?? {
              id: p.clientId,
              name: "Client",
              logo: (p.name || "P").slice(0, 2).toUpperCase(),
              industry: "General",
              status: "active" as const,
              health: "green" as const,
              projectCount: 1,
              totalRevenue: 0,
              accountManagerId: "u1",
            };
            const clientLogo = client.logo || (client.name || "P").slice(0, 2).toUpperCase();
            const ems = getCardEMs(p, leadershipAssignments);
            const spms = getCardSPMs(p, leadershipAssignments, prereqs);
            const pms = getCardPMs(p, leadershipAssignments, prereqs);
            const tls = getCardTLs(p, leadershipAssignments, prereqs);
            return (
              <article
                key={p.id}
                onClick={() =>
                  navigate({ to: "/projects/$projectId", params: { projectId: p.id } })
                }
                className="group flex flex-col justify-between rounded-xl border border-border bg-card p-4 shadow-sm transition-all hover:border-primary/50 hover:shadow-md cursor-pointer"
              >
                <div>
                  <header className="flex items-start gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-info text-sm font-semibold text-primary-foreground group-hover:scale-105 transition-transform">
                      {clientLogo}
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center justify-between gap-2">
                        <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground truncate">
                          <span className="font-mono">{p.projectSeqId || p.id.toUpperCase()}</span>
                          <span>•</span>
                          <span className="truncate">{client.name || "Client"}</span>
                        </div>
                        {isRenewedProject(p) && <RenewedProjectTag className="shrink-0" />}
                      </div>
                      <div className="truncate text-sm font-semibold group-hover:text-primary transition-colors mt-0.5">
                        {p.name}
                      </div>
                    </div>
                  </header>
                  <div className="mt-3 flex flex-wrap items-center gap-1.5">
                    <HealthPill status={p.health} />
                    <StatusPill status={p.status} />
                    <PriorityPill priority={priorities[i % priorities.length]} />
                  </div>
                  <div className="mt-3">
                    <div className="mb-1 flex justify-between text-[11px] tabular-nums text-muted-foreground">
                      <span>Progress</span>
                      <span>{p.progress}%</span>
                    </div>
                    <ProgressBar value={p.progress} />
                  </div>
                  <dl className="mt-3 grid grid-cols-2 gap-x-3 gap-y-2.5 text-xs">
                    <div>
                      <dt className="text-muted-foreground">Start</dt>
                      <dd className="font-medium tabular-nums">
                        {p.startDate ? new Date(p.startDate).toLocaleDateString() : "—"}
                      </dd>
                    </div>
                    <div>
                      <dt className="text-muted-foreground">End</dt>
                      <dd className="font-medium tabular-nums">
                        {p.endDate ? new Date(p.endDate).toLocaleDateString() : "—"}
                      </dd>
                    </div>
                    <div className="min-w-0">
                      <dt className="text-muted-foreground truncate">Engagement Manager</dt>
                      <dd className="mt-0.5">
                        <PeopleSummary list={ems} emptyText="Not Assigned" />
                      </dd>
                    </div>
                    <div className="min-w-0">
                      <dt className="text-muted-foreground truncate">Senior Project Manager</dt>
                      <dd className="mt-0.5">
                        <PeopleSummary list={spms} emptyText="Not Assigned" />
                      </dd>
                    </div>
                    <div className="min-w-0">
                      <dt className="text-muted-foreground truncate">Project Manager</dt>
                      <dd className="mt-0.5">
                        <PeopleSummary list={pms} emptyText="Not Assigned" />
                      </dd>
                    </div>
                    <div className="min-w-0">
                      <dt className="text-muted-foreground truncate">Team Lead</dt>
                      <dd className="mt-0.5">
                        <PeopleSummary list={tls} emptyText="Not Assigned" />
                      </dd>
                    </div>
                  </dl>
                </div>
              </article>
            );
          })}
          {visible.length === 0 && (
            <p className="col-span-full py-10 text-center text-sm text-muted-foreground">
              No projects in this view
            </p>
          )}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium">Project ID</th>
                <th className="px-3 py-2 font-medium">Project</th>
                <th className="px-3 py-2 font-medium">Customer</th>
                <th className="px-3 py-2 font-medium">Status</th>
                <th className="px-3 py-2 font-medium">Progress</th>
                <th className="px-3 py-2 font-medium">Start</th>
                <th className="px-3 py-2 font-medium">End</th>
                <th className="px-3 py-2 font-medium">Engagement Mgr</th>
                <th className="px-3 py-2 font-medium">Project Mgr</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {visible.map((p) => {
                const client = clients.find((c) => c.id === p.clientId) ?? {
                  id: p.clientId,
                  name: "Client",
                  logo: (p.name || "P").slice(0, 2).toUpperCase(),
                  industry: "General",
                  status: "active" as const,
                  health: "green" as const,
                  projectCount: 1,
                  totalRevenue: 0,
                  accountManagerId: "u1",
                };
                const ems = getProjectEMs(p);
                const pms = getProjectPMs(p);
                return (
                  <tr
                    key={p.id}
                    onClick={() =>
                      navigate({ to: "/projects/$projectId", params: { projectId: p.id } })
                    }
                    className="hover:bg-accent/50 cursor-pointer transition-colors group"
                  >
                    <td className="px-3 py-2.5 font-mono text-xs text-muted-foreground group-hover:text-primary font-medium transition-colors">
                      {p.projectSeqId || p.id.toUpperCase()}
                    </td>
                    <td className="px-3 py-2.5 font-medium group-hover:text-primary transition-colors">
                      <div className="flex flex-col items-start gap-1">
                        <span>{p.name}</span>
                        {isRenewedProject(p) && <RenewedProjectTag />}
                      </div>
                    </td>
                    <td className="px-3 py-2.5 text-muted-foreground">{client.name || "Client"}</td>
                    <td className="px-3 py-2.5">
                      <StatusPill status={p.status} />
                    </td>
                    <td className="px-3 py-2.5">
                      <div className="flex items-center gap-2">
                        <ProgressBar value={p.progress} className="w-24" />
                        <span className="text-xs tabular-nums text-muted-foreground">
                          {p.progress}%
                        </span>
                      </div>
                    </td>
                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">
                      {p.startDate ? new Date(p.startDate).toLocaleDateString() : "—"}
                    </td>
                    <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">
                      {p.endDate ? new Date(p.endDate).toLocaleDateString() : "—"}
                    </td>
                    <td className="px-3 py-2.5">
                      <PeopleSummary list={ems} />
                    </td>
                    <td className="px-3 py-2.5">
                      <PeopleSummary list={pms} />
                    </td>
                  </tr>
                );
              })}
              {visible.length === 0 && (
                <tr>
                  <td colSpan={9} className="px-3 py-10 text-center text-sm text-muted-foreground">
                    No projects in this view
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* New Project navigates to /projects/new (full WBS form) */}

      {/* ── Drafts panel ── */}
      {draftsOpen && (
        <div
          className="fixed inset-0 z-50 flex justify-end bg-black/50 backdrop-blur-[2px] transition-all duration-200"
          onClick={() => setDraftsOpen(false)}
        >
          <aside
            className="flex h-full w-full max-w-md flex-col border-l border-border bg-card shadow-2xl animate-in slide-in-from-right duration-200"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex flex-col gap-2.5 border-b border-border px-4 py-3 bg-muted/30">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-sm font-semibold flex items-center gap-2">
                    <FileText className="h-4 w-4 text-primary" />
                    Saved Drafts
                  </h2>
                  <p className="text-[11px] text-muted-foreground">
                    {drafts.length} shared draft{drafts.length !== 1 ? "s" : ""} available
                  </p>
                </div>
                <button
                  onClick={() => setDraftsOpen(false)}
                  className="rounded-md p-1.5 hover:bg-accent text-muted-foreground hover:text-foreground"
                  aria-label="Close"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>
              <div className="relative">
                <Search className="pointer-events-none absolute left-2.5 top-2.5 h-3.5 w-3.5 text-muted-foreground" />
                <input
                  type="text"
                  value={draftSearch}
                  onChange={(e) => {
                    setDraftSearch(e.target.value);
                    loadDrafts(e.target.value);
                  }}
                  placeholder="Search drafts by project or client…"
                  className="h-8 w-full rounded-md border border-input bg-card pl-8 pr-3 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring"
                />
              </div>
            </div>

            {/* List */}
            <div className="flex-1 overflow-y-auto">
              {loadingDrafts && drafts.length === 0 ? (
                <div className="flex flex-col items-center justify-center gap-3 py-16 text-center">
                  <div className="h-6 w-6 animate-spin rounded-full border-2 border-primary border-t-transparent" />
                  <p className="text-xs text-muted-foreground">Loading drafts from database…</p>
                </div>
              ) : drafts.length === 0 ? (
                <div className="flex flex-col items-center justify-center gap-3 py-16 text-center">
                  <FileText className="h-10 w-10 text-muted-foreground/40" />
                  <p className="text-sm text-muted-foreground">No drafts found</p>
                  <p className="text-xs text-muted-foreground">
                    Use "Save Draft" in Project Onboarding to save shared work
                  </p>
                </div>
              ) : (
                <ul className="divide-y divide-border">
                  {drafts.map((d) => (
                    <li key={d.id} className="group px-4 py-3 hover:bg-accent/40 transition-colors">
                      <div className="flex items-start gap-3">
                        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                          <FileText className="h-4 w-4" />
                        </div>
                        <div className="min-w-0 flex-1">
                          <p className="truncate text-sm font-semibold">{d.projectName}</p>
                          <div className="mt-0.5 flex flex-wrap items-center gap-x-2 gap-y-0.5 text-[11px] text-muted-foreground">
                            {d.clientName && (
                              <span className="flex items-center gap-1 font-medium text-foreground/80">
                                <User className="h-3 w-3" />
                                {d.clientName}
                              </span>
                            )}
                            {d.salesPerson && (
                              <span className="flex items-center gap-1">
                                · Sales: {d.salesPerson}
                              </span>
                            )}
                          </div>
                          <div className="mt-1 flex items-center gap-1 text-[10px] text-muted-foreground">
                            <Clock className="h-3 w-3" />
                            {d.updatedByName
                              ? `Updated by ${d.updatedByName}`
                              : `Created by ${d.createdByName}`} ·{" "}
                            {new Date(d.updatedAtUtc || d.createdAtUtc).toLocaleString("en-IN", {
                              day: "2-digit",
                              month: "short",
                              year: "numeric",
                              hour: "2-digit",
                              minute: "2-digit",
                            })}
                          </div>
                        </div>
                        <div className="flex shrink-0 flex-col gap-1.5">
                          <button
                            onClick={() => {
                              setDraftsOpen(false);
                              navigate({ to: "/projects/new", search: { draftId: d.id } as any });
                            }}
                            className="inline-flex items-center gap-1 rounded-md bg-primary px-2.5 py-1 text-[11px] font-medium text-primary-foreground hover:bg-primary/90"
                          >
                            <ArrowRight className="h-3 w-3" /> Open
                          </button>
                          <button
                            onClick={() => handleDeleteDraft(d.id)}
                            className="inline-flex items-center gap-1 rounded-md border border-destructive/30 bg-destructive/5 px-2.5 py-1 text-[11px] font-medium text-destructive hover:bg-destructive/10"
                          >
                            <Trash2 className="h-3 w-3" /> Delete
                          </button>
                        </div>
                      </div>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </aside>
        </div>
      )}
    </AppShell>
  );
}

function resolvePerson(idOrName?: string | null): Person | null {
  if (!idOrName) return null;
  const trimmed = idOrName.trim();
  if (!trimmed || trimmed === "—" || trimmed.toLowerCase() === "not assigned") return null;
  const found = people.find(
    (p) => p.id === trimmed || p.name.toLowerCase() === trimmed.toLowerCase()
  );
  if (found) return found;
  return {
    id: trimmed,
    name: trimmed,
    role: "User",
    avatar: trimmed.slice(0, 2).toUpperCase(),
    email: "",
  };
}

function getCardEMs(
  p: Project,
  leadershipAssignments: Record<string, { emIds?: string[]; spmIds?: string[]; pmIds?: string[]; tlIds?: string[] }>,
): Person[] {
  const la = leadershipAssignments[p.id];
  if (la?.emIds && Array.isArray(la.emIds) && la.emIds.length > 0) {
    const list = la.emIds.map(resolvePerson).filter(Boolean) as Person[];
    if (list.length > 0) return list;
  }
  const em = resolvePerson(p.engagementManager);
  return em ? [em] : [];
}

function getCardSPMs(
  p: Project,
  leadershipAssignments: Record<string, { emIds?: string[]; spmIds?: string[]; pmIds?: string[]; tlIds?: string[] }>,
  prereqs: Record<string, any>,
): Person[] {
  const la = leadershipAssignments[p.id];
  if (la?.spmIds && Array.isArray(la.spmIds) && la.spmIds.length > 0) {
    const list = la.spmIds.map(resolvePerson).filter(Boolean) as Person[];
    if (list.length > 0) return list;
  }
  const pr = prereqs[p.id];
  if (pr?.assignedSpmIds && Array.isArray(pr.assignedSpmIds) && pr.assignedSpmIds.length > 0) {
    const list = pr.assignedSpmIds.map(resolvePerson).filter(Boolean) as Person[];
    if (list.length > 0) return list;
  }
  const spm = resolvePerson(p.seniorProjectManager);
  return spm ? [spm] : [];
}

function getCardPMs(
  p: Project,
  leadershipAssignments: Record<string, { emIds?: string[]; spmIds?: string[]; pmIds?: string[]; tlIds?: string[] }>,
  prereqs: Record<string, any>,
): Person[] {
  const la = leadershipAssignments[p.id];
  if (la?.pmIds && Array.isArray(la.pmIds) && la.pmIds.length > 0) {
    const list = la.pmIds.map(resolvePerson).filter(Boolean) as Person[];
    if (list.length > 0) return list;
  }
  const pr = prereqs[p.id];
  if (pr?.assignedPmIds && Array.isArray(pr.assignedPmIds) && pr.assignedPmIds.length > 0) {
    const list = pr.assignedPmIds.map(resolvePerson).filter(Boolean) as Person[];
    if (list.length > 0) return list;
  }
  const pm = resolvePerson(p.projectManagerName || p.projectManagerId || p.pmId);
  return pm ? [pm] : [];
}

function getCardTLs(
  p: Project,
  leadershipAssignments: Record<string, { emIds?: string[]; spmIds?: string[]; pmIds?: string[]; tlIds?: string[] }>,
  prereqs: Record<string, any>,
): Person[] {
  const la = leadershipAssignments[p.id];
  if (la?.tlIds && Array.isArray(la.tlIds) && la.tlIds.length > 0) {
    const list = la.tlIds.map(resolvePerson).filter(Boolean) as Person[];
    if (list.length > 0) return list;
  }
  const pr = prereqs[p.id];
  if (pr?.assignedTlIds && Array.isArray(pr.assignedTlIds) && pr.assignedTlIds.length > 0) {
    const list = pr.assignedTlIds.map(resolvePerson).filter(Boolean) as Person[];
    if (list.length > 0) return list;
  }
  const tl = resolvePerson(p.teamLeadName || p.teamLeadId || p.tlId);
  return tl ? [tl] : [];
}

function PeopleSummary({
  list,
  emptyText = "—",
}: {
  list: Person[];
  emptyText?: string;
}) {
  if (!list || list.length === 0) {
    return <span className="text-muted-foreground text-xs font-normal">{emptyText}</span>;
  }
  const s = formatPeopleSummary(list);
  if (!s.primary || s.primary === "—") {
    return <span className="text-muted-foreground text-xs font-normal">{emptyText}</span>;
  }
  return (
    <div className="flex items-center gap-1.5 min-w-0">
      <Avatar name={list[0].name} size={18} />
      <span className="truncate text-xs font-medium">{s.primary}</span>
      {s.more > 0 && (
        <span className="rounded-full border border-border bg-muted px-1.5 py-0.5 text-[10px] font-medium text-muted-foreground shrink-0">
          +{s.more}
        </span>
      )}
    </div>
  );
}

// ---------- New WBS Project Modal ----------
type ClientMode = "existing" | "new";
interface WbsServiceState {
  id: string;
  department: string;
  serviceName: string;
  qty: number;
  description: string;
  frequency: string;
  location: string;
  serviceModel: string;
  deliveryModel: string;
  finalDeliveryFormat: string;
  billingModel: string;
  tools: string;
  startDate: string;
  endDate: string;
  duration: number;
  unitPrice: number;
  total: number;
}

interface WbsInvoiceState {
  id: string;
  milestone: string;
  amount: number;
  invoiceDate: string;
  remarks: string;
}

interface NewProjectState {
  clientMode: ClientMode;
  existingClientId: string;
  newClient: { name: string; industry: string; contact: string; email: string };
  proj: { name: string; description: string; startDate: string; endDate: string; budget: string };
  wbsHeader: { contractType: string; projectType: string; salesPerson: string; currency: string };
  wbsServices: WbsServiceState[];
  wbsAccounts: {
    poStatus: string;
    poNumber: string;
    poDate: string;
    billingModel: string;
    paymentTerms: string;
    targetDate: string;
    contactName: string;
    contactNumber: string;
    contactEmail: string;
  };
  wbsInvoices: WbsInvoiceState[];
}

// DEPT_SERVICES moved to /projects/new route (full WBS form)
// Kept here for backward-compat with NewWBSProjectModal
const DEPT_SERVICES: Record<string, string[]> = {
  Creative: ["Brand Design", "UI/UX Design", "Copywriting", "Video Production"],
  Technology: [
    "Web Development",
    "Mobile App Development",
    "API Integration",
    "Cloud Architecture",
  ],
  Marketing: [
    "SEO Optimization",
    "Performance Marketing",
    "Social Media Management",
    "Content Strategy",
  ],
  Consulting: ["Digital Transformation", "Process Optimization", "Market Research"],
  "Penetration Testing": [
    "External Network Penetration Testing",
    "Internal Network Penetration Testing",
    "Web Application Penetration Testing",
  ],
  "Vulnerability Assessment": [
    "Network Vulnerability Assessment",
    "Web Application Vulnerability Assessment",
  ],
  "Cloud Security": ["AWS Security Assessment", "Azure Security Assessment"],
};

function NewWBSProjectModal({ onClose }: { onClose: () => void }) {
  const [step, setStep] = useState(1);
  const [submitting, setSubmitting] = useState(false);
  const clients = allClients();
  const [s, setS] = useState<NewProjectState>({
    clientMode: "existing",
    existingClientId: clients[0]?.id ?? "",
    newClient: { name: "", industry: "", contact: "", email: "" },
    proj: { name: "", description: "", startDate: "", endDate: "", budget: "" },
    wbsHeader: {
      contractType: "Fixed Price",
      projectType: "New Implementation",
      salesPerson: "",
      currency: "USD",
    },
    wbsServices: [],
    wbsAccounts: {
      poStatus: "Not Raised",
      poNumber: "",
      poDate: "",
      billingModel: "Milestone",
      paymentTerms: "Net 30",
      targetDate: "",
      contactName: "",
      contactNumber: "",
      contactEmail: "",
    },
    wbsInvoices: [],
  });

  const [showServicePicker, setShowServicePicker] = useState(false);
  const [tempService, setTempService] = useState({ dept: "Creative", service: "Brand Design" });

  const updateProj = (k: keyof NewProjectState["proj"], v: string) =>
    setS((p) => ({ ...p, proj: { ...p.proj, [k]: v } }));
  const updateWbsHeader = (k: keyof NewProjectState["wbsHeader"], v: string) =>
    setS((p) => ({ ...p, wbsHeader: { ...p.wbsHeader, [k]: v } }));
  const updateWbsAccounts = (k: keyof NewProjectState["wbsAccounts"], v: string) =>
    setS((p) => ({ ...p, wbsAccounts: { ...p.wbsAccounts, [k]: v } }));

  const clientValid = s.clientMode === "existing" ? !!s.existingClientId : !!s.newClient.name;
  const projValid = !!s.proj.name && !!s.proj.startDate && !!s.proj.endDate;
  const isHeaderComplete = clientValid && projValid;

  const submit = () => {
    if (!isHeaderComplete || s.wbsServices.length === 0) {
      toast.error("Please complete client, project, and at least one service");
      return;
    }
    setSubmitting(true);
    setTimeout(() => {
      let clientId = s.existingClientId;
      if (s.clientMode === "new") {
        const c = dhStore.addClient({
          name: s.newClient.name,
          industry: s.newClient.industry || "Other",
          contact: s.newClient.email,
        });
        clientId = c.id;
      }

      const overallBudget = s.wbsServices.reduce((acc, curr) => acc + curr.total, 0);

      dhStore.addProject({
        name: s.proj.name,
        clientId,
        description: s.proj.description,
        startDate: s.proj.startDate,
        endDate: s.proj.endDate,
        budget: overallBudget,
        wbsDetails: {
          contractType: s.wbsHeader.contractType,
          projectType: s.wbsHeader.projectType,
          salesPerson: s.wbsHeader.salesPerson,
          currency: s.wbsHeader.currency,
          services: s.wbsServices,
          accounts: {
            poStatus: s.wbsAccounts.poStatus,
            poNumber: s.wbsAccounts.poNumber,
            poDate: s.wbsAccounts.poDate,
            billingModel: s.wbsAccounts.billingModel,
            paymentTerms: s.wbsAccounts.paymentTerms,
            targetDate: s.wbsAccounts.targetDate,
            contactName: s.wbsAccounts.contactName,
            contactNumber: s.wbsAccounts.contactNumber,
            contactEmail: s.wbsAccounts.contactEmail,
            invoices: s.wbsInvoices,
          },
        },
      });
      toast.success("WBS Project created", {
        description: "Prerequisites initialized and project active.",
      });
      setSubmitting(false);
      onClose();
    }, 500);
  };

  const addService = () => {
    setS((p) => ({
      ...p,
      wbsServices: [
        ...p.wbsServices,
        {
          id: "srv_" + Date.now(),
          department: tempService.dept,
          serviceName: tempService.service,
          qty: 1,
          description: "",
          frequency: "One-Time",
          location: "Offshore",
          serviceModel: "Fixed",
          deliveryModel: "Agile",
          finalDeliveryFormat: "Code",
          billingModel: "Milestone",
          tools: "Jira, GitHub",
          startDate: p.proj.startDate,
          endDate: p.proj.endDate,
          duration: 1,
          unitPrice: 0,
          total: 0,
        },
      ],
    }));
    setShowServicePicker(false);
  };

  const updateService = (id: string, field: string, val: any) => {
    setS((p) => {
      const svcs = p.wbsServices.map((svc) => {
        if (svc.id === id) {
          const updated = { ...svc, [field]: val };
          updated.total = updated.qty * updated.unitPrice;
          return updated;
        }
        return svc;
      });
      return { ...p, wbsServices: svcs };
    });
  };

  const removeService = (id: string) =>
    setS((p) => ({ ...p, wbsServices: p.wbsServices.filter((x) => x.id !== id) }));

  const addInvoice = () => {
    setS((p) => ({
      ...p,
      wbsInvoices: [
        ...p.wbsInvoices,
        { id: "inv_" + Date.now(), milestone: "", amount: 0, invoiceDate: "", remarks: "" },
      ],
    }));
  };

  const updateInvoice = (id: string, field: string, val: any) => {
    setS((p) => ({
      ...p,
      wbsInvoices: p.wbsInvoices.map((inv) => (inv.id === id ? { ...inv, [field]: val } : inv)),
    }));
  };

  const removeInvoice = (id: string) =>
    setS((p) => ({ ...p, wbsInvoices: p.wbsInvoices.filter((x) => x.id !== id) }));

  const totalServices = s.wbsServices.reduce((a, b) => a + b.total, 0);
  const tax = totalServices * 0.18;
  const grandTotal = totalServices + tax;
  const totalInvoices = s.wbsInvoices.reduce((a, b) => a + Number(b.amount || 0), 0);

  return (
    <Modal title="Create New Project (WBS)" onClose={onClose} fullScreen>
      <div className="pb-8 space-y-8 max-w-[1400px] mx-auto">
        <div className="grid gap-6 md:grid-cols-2">
          {/* Client Details */}
          <section className="space-y-4 rounded-lg border border-border bg-card p-5">
            <h3 className="text-sm font-semibold border-b border-border pb-2">Customer Details</h3>
            <div className="flex gap-2 mb-4">
              {(["existing", "new"] as ClientMode[]).map((m) => (
                <button
                  key={m}
                  onClick={() => setS((p) => ({ ...p, clientMode: m }))}
                  className={cn(
                    "flex-1 rounded-md border p-2 text-center text-xs font-medium",
                    s.clientMode === m
                      ? "border-primary bg-primary/10 text-primary"
                      : "border-border bg-muted/50 hover:bg-accent/30",
                  )}
                >
                  {m === "existing" ? "Existing Customer" : "Add New Customer"}
                </button>
              ))}
            </div>
            {s.clientMode === "existing" ? (
              <Field label="Select Customer" required>
                <select
                  value={s.existingClientId}
                  onChange={(e) => setS((p) => ({ ...p, existingClientId: e.target.value }))}
                  className={inputCls}
                >
                  {clients.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name} — {c.industry}
                    </option>
                  ))}
                </select>
              </Field>
            ) : (
              <div className="grid gap-3 sm:grid-cols-2">
                <Field label="Customer Name" required>
                  <input
                    className={inputCls}
                    maxLength={FIELD_MAX.clientName}
                    value={s.newClient.name}
                    onChange={(e) =>
                      setS((p) => ({
                        ...p,
                        newClient: {
                          ...p.newClient,
                          name: e.target.value.slice(0, FIELD_MAX.clientName),
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="Industry">
                  <input
                    className={inputCls}
                    maxLength={FIELD_MAX.industry}
                    value={s.newClient.industry}
                    onChange={(e) =>
                      setS((p) => ({
                        ...p,
                        newClient: {
                          ...p.newClient,
                          industry: e.target.value.slice(0, FIELD_MAX.industry),
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="Contact Person">
                  <input
                    className={inputCls}
                    maxLength={FIELD_MAX.personName}
                    value={s.newClient.contact}
                    onChange={(e) =>
                      setS((p) => ({
                        ...p,
                        newClient: {
                          ...p.newClient,
                          contact: e.target.value.slice(0, FIELD_MAX.personName),
                        },
                      }))
                    }
                  />
                </Field>
                <Field label="Email" error={emailError(s.newClient.email)}>
                  <input
                    type="email"
                    className={fieldInputCls(inputCls, Boolean(emailError(s.newClient.email)))}
                    maxLength={FIELD_MAX.email}
                    placeholder="name@company.com"
                    value={s.newClient.email}
                    onChange={(e) =>
                      setS((p) => ({
                        ...p,
                        newClient: {
                          ...p.newClient,
                          email: e.target.value.slice(0, FIELD_MAX.email),
                        },
                      }))
                    }
                    onBlur={() =>
                      setS((p) => ({
                        ...p,
                        newClient: { ...p.newClient, email: p.newClient.email.trim() },
                      }))
                    }
                  />
                </Field>
              </div>
            )}
          </section>

          {/* Project Details */}
          <section className="space-y-4 rounded-lg border border-border bg-card p-5">
            <h3 className="text-sm font-semibold border-b border-border pb-2">Project Details</h3>
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="Project Name" required className="sm:col-span-2">
                <input
                  className={inputCls}
                  maxLength={FIELD_MAX.projectName}
                  value={s.proj.name}
                  onChange={(e) => updateProj("name", e.target.value.slice(0, FIELD_MAX.projectName))}
                />
              </Field>
              <Field label="Start Date" required>
                <input
                  type="date"
                  className={inputCls}
                  value={s.proj.startDate}
                  onChange={(e) => updateProj("startDate", e.target.value)}
                />
              </Field>
              <Field label="End Date" required>
                <input
                  type="date"
                  className={inputCls}
                  value={s.proj.endDate}
                  onChange={(e) => updateProj("endDate", e.target.value)}
                />
              </Field>
              <Field label="Description" className="sm:col-span-2">
                <textarea
                  rows={1}
                  className={cn(inputCls, "py-1.5")}
                  value={s.proj.description}
                  onChange={(e) => updateProj("description", e.target.value)}
                />
              </Field>
            </div>
          </section>
        </div>

        {isHeaderComplete && (
          <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
            {/* WBS Info Cards */}
            <div className="grid gap-6 md:grid-cols-2">
              <div className="rounded-lg border border-border bg-card p-5">
                <h3 className="mb-4 text-sm font-semibold">WBS Details</h3>
                <div className="space-y-3">
                  <HorizontalField label="Contract Type">
                    <select
                      className={inputCls}
                      value={s.wbsHeader.contractType}
                      onChange={(e) => updateWbsHeader("contractType", e.target.value)}
                    >
                      {["Fixed Price", "Time & Material", "Retainer", "Staff Augmentation"].map(
                        (o) => (
                          <option key={o}>{o}</option>
                        ),
                      )}
                    </select>
                  </HorizontalField>
                  <HorizontalField label="Project Type">
                    <select
                      className={inputCls}
                      value={s.wbsHeader.projectType}
                      onChange={(e) => updateWbsHeader("projectType", e.target.value)}
                    >
                      {["New Implementation", "Enhancement", "Maintenance", "Consulting"].map(
                        (o) => (
                          <option key={o}>{o}</option>
                        ),
                      )}
                    </select>
                  </HorizontalField>
                  <HorizontalField label="Sales Person">
                    <input
                      className={inputCls}
                      value={s.wbsHeader.salesPerson}
                      onChange={(e) => updateWbsHeader("salesPerson", e.target.value)}
                    />
                  </HorizontalField>
                </div>
              </div>
              <div className="rounded-lg border border-border bg-card p-5">
                <h3 className="mb-4 text-sm font-semibold">Billing Information</h3>
                <div className="space-y-3">
                  <HorizontalField label="Currency">
                    <select
                      className={inputCls}
                      value={s.wbsHeader.currency}
                      onChange={(e) => updateWbsHeader("currency", e.target.value)}
                    >
                      {["USD", "EUR", "GBP", "INR"].map((o) => (
                        <option key={o}>{o}</option>
                      ))}
                    </select>
                  </HorizontalField>
                  <HorizontalField label="Billing Model">
                    <select
                      className={inputCls}
                      value={s.wbsAccounts.billingModel}
                      onChange={(e) => updateWbsAccounts("billingModel", e.target.value)}
                    >
                      {["Milestone based", "Monthly", "Quarterly", "On Completion"].map((o) => (
                        <option key={o}>{o}</option>
                      ))}
                    </select>
                  </HorizontalField>
                  <HorizontalField label="Payment Terms">
                    <select
                      className={inputCls}
                      value={s.wbsAccounts.paymentTerms}
                      onChange={(e) => updateWbsAccounts("paymentTerms", e.target.value)}
                    >
                      {["Net 15", "Net 30", "Net 45", "Net 60", "Due on Receipt"].map((o) => (
                        <option key={o}>{o}</option>
                      ))}
                    </select>
                  </HorizontalField>
                  <HorizontalField label="Total Amount">
                    <div className="h-9 flex items-center px-3 font-semibold bg-muted/30 rounded border border-border">
                      {s.wbsHeader.currency} {totalServices.toLocaleString()}
                    </div>
                  </HorizontalField>
                </div>
              </div>
            </div>

            {/* Services Table */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold">Services & Deliverables from WBS</h3>
                <button
                  onClick={() => setShowServicePicker(true)}
                  className="inline-flex items-center gap-1 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90"
                >
                  <Plus className="h-3.5 w-3.5" /> Add Service
                </button>
              </div>

              {showServicePicker && (
                <div className="rounded-lg border border-border bg-accent/20 p-3 mb-4 flex items-end gap-3 max-w-xl">
                  <Field label="Department" className="flex-1">
                    <select
                      className={inputCls}
                      value={tempService.dept}
                      onChange={(e) => {
                        const dept = e.target.value;
                        const svcs = DEPT_SERVICES[dept as keyof typeof DEPT_SERVICES];
                        setTempService({ dept, service: svcs[0] });
                      }}
                    >
                      {Object.keys(DEPT_SERVICES).map((d) => (
                        <option key={d}>{d}</option>
                      ))}
                    </select>
                  </Field>
                  <Field label="Service" className="flex-1">
                    <select
                      className={inputCls}
                      value={tempService.service}
                      onChange={(e) => setTempService((p) => ({ ...p, service: e.target.value }))}
                    >
                      {DEPT_SERVICES[tempService.dept as keyof typeof DEPT_SERVICES].map((s) => (
                        <option key={s}>{s}</option>
                      ))}
                    </select>
                  </Field>
                  <div className="flex gap-2">
                    <button
                      onClick={addService}
                      className="h-9 rounded-md bg-primary px-3 text-xs font-medium text-primary-foreground hover:bg-primary/90"
                    >
                      Add
                    </button>
                    <button
                      onClick={() => setShowServicePicker(false)}
                      className="h-9 rounded-md border border-input bg-card px-3 text-xs font-medium hover:bg-accent"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              )}

              <div className="overflow-x-auto rounded-lg border border-border bg-card">
                <table className="w-full text-xs whitespace-nowrap">
                  <thead className="bg-muted/40 text-left uppercase tracking-wide text-muted-foreground">
                    <tr>
                      <th className="px-3 py-2 font-medium">Department</th>
                      <th className="px-3 py-2 font-medium">Service Name</th>
                      <th className="px-3 py-2 font-medium w-20">Qty</th>
                      <th className="px-3 py-2 font-medium w-24">Unit Price</th>
                      <th className="px-3 py-2 font-medium w-32">Description</th>
                      <th className="px-3 py-2 font-medium w-28">Frequency</th>
                      <th className="px-3 py-2 font-medium w-28">Location</th>
                      <th className="px-3 py-2 font-medium w-32">Start Date</th>
                      <th className="px-3 py-2 font-medium w-32">End Date</th>
                      <th className="px-3 py-2 font-medium text-right w-28">Total</th>
                      <th className="px-3 py-2 font-medium w-10"></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {s.wbsServices.map((svc) => (
                      <tr key={svc.id} className="hover:bg-accent/10">
                        <td className="px-3 py-2">{svc.department}</td>
                        <td className="px-3 py-2 font-medium">{svc.serviceName}</td>
                        <td className="px-3 py-2">
                          <input
                            type="number"
                            min={1}
                            className={cn(inputCls, "h-7 px-2")}
                            value={svc.qty}
                            onChange={(e) => updateService(svc.id, "qty", Number(e.target.value))}
                          />
                        </td>
                        <td className="px-3 py-2">
                          <input
                            type="number"
                            min={0}
                            className={cn(inputCls, "h-7 px-2")}
                            value={svc.unitPrice}
                            onChange={(e) =>
                              updateService(svc.id, "unitPrice", Number(e.target.value))
                            }
                          />
                        </td>
                        <td className="px-3 py-2">
                          <input
                            className={cn(inputCls, "h-7 px-2")}
                            value={svc.description}
                            onChange={(e) => updateService(svc.id, "description", e.target.value)}
                          />
                        </td>
                        <td className="px-3 py-2">
                          <select
                            className={cn(inputCls, "h-7 px-2")}
                            value={svc.frequency}
                            onChange={(e) => updateService(svc.id, "frequency", e.target.value)}
                          >
                            {["One-Time", "Monthly", "Quarterly", "Annually"].map((o) => (
                              <option key={o}>{o}</option>
                            ))}
                          </select>
                        </td>
                        <td className="px-3 py-2">
                          <select
                            className={cn(inputCls, "h-7 px-2")}
                            value={svc.location}
                            onChange={(e) => updateService(svc.id, "location", e.target.value)}
                          >
                            {["Onsite", "Offshore", "Hybrid"].map((o) => (
                              <option key={o}>{o}</option>
                            ))}
                          </select>
                        </td>
                        <td className="px-3 py-2">
                          <input
                            type="date"
                            className={cn(inputCls, "h-7 px-2")}
                            value={svc.startDate}
                            onChange={(e) => updateService(svc.id, "startDate", e.target.value)}
                          />
                        </td>
                        <td className="px-3 py-2">
                          <input
                            type="date"
                            className={cn(inputCls, "h-7 px-2")}
                            value={svc.endDate}
                            onChange={(e) => updateService(svc.id, "endDate", e.target.value)}
                          />
                        </td>
                        <td className="px-3 py-2 text-right font-medium">
                          {s.wbsHeader.currency} {svc.total.toLocaleString()}
                        </td>
                        <td className="px-3 py-2 text-center">
                          <button
                            onClick={() => removeService(svc.id)}
                            className="text-muted-foreground hover:text-destructive"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </td>
                      </tr>
                    ))}
                    {s.wbsServices.length === 0 && (
                      <tr>
                        <td
                          colSpan={11}
                          className="px-3 py-8 text-center text-sm text-muted-foreground"
                        >
                          No services added. Click "Add Service" to build the WBS.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Totals */}
            <div className="grid gap-4 md:grid-cols-4 rounded-lg border border-border bg-muted/30 p-5">
              <div>
                <div className="text-xs font-semibold text-muted-foreground mb-1 uppercase tracking-wider">
                  Subtotal
                </div>
                <div className="text-lg font-bold">
                  {s.wbsHeader.currency} {totalServices.toLocaleString()}
                </div>
              </div>
              <div>
                <div className="text-xs font-semibold text-muted-foreground mb-1 uppercase tracking-wider">
                  Tax (18%)
                </div>
                <div className="text-lg font-bold">
                  {s.wbsHeader.currency} {tax.toLocaleString()}
                </div>
              </div>
              <div>
                <div className="text-xs font-semibold text-muted-foreground mb-1 uppercase tracking-wider">
                  Total Duration
                </div>
                <div className="text-lg font-bold">~</div>
              </div>
              <div>
                <div className="text-xs font-semibold text-muted-foreground mb-1 uppercase tracking-wider">
                  Grand Total
                </div>
                <div className="text-lg font-bold text-primary">
                  {s.wbsHeader.currency} {grandTotal.toLocaleString()}
                </div>
              </div>
            </div>

            {/* Invoice Schedule */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold">Invoice Schedule</h3>
                <button
                  onClick={addInvoice}
                  className="inline-flex items-center gap-1 rounded-md bg-secondary text-secondary-foreground px-3 py-1.5 text-xs font-medium hover:bg-secondary/80"
                >
                  <Plus className="h-3.5 w-3.5" /> Add Milestone
                </button>
              </div>

              <div className="overflow-x-auto rounded-lg border border-border bg-card">
                <table className="w-full text-sm">
                  <thead className="bg-muted/40 text-xs uppercase tracking-wide text-muted-foreground text-left">
                    <tr>
                      <th className="px-3 py-2">Milestone / Description</th>
                      <th className="px-3 py-2 w-48">Amount ({s.wbsHeader.currency})</th>
                      <th className="px-3 py-2 w-48">Target Date</th>
                      <th className="px-3 py-2">Remarks</th>
                      <th className="px-3 py-2 w-10"></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {s.wbsInvoices.map((inv) => (
                      <tr key={inv.id} className="hover:bg-accent/10">
                        <td className="px-3 py-2">
                          <input
                            className={cn(inputCls, "h-8")}
                            placeholder="E.g., 25% Advance"
                            value={inv.milestone}
                            onChange={(e) => updateInvoice(inv.id, "milestone", e.target.value)}
                          />
                        </td>
                        <td className="px-3 py-2">
                          <input
                            type="number"
                            className={cn(inputCls, "h-8")}
                            value={inv.amount || ""}
                            onChange={(e) =>
                              updateInvoice(inv.id, "amount", Number(e.target.value))
                            }
                          />
                        </td>
                        <td className="px-3 py-2">
                          <input
                            type="date"
                            className={cn(inputCls, "h-8")}
                            value={inv.invoiceDate}
                            onChange={(e) => updateInvoice(inv.id, "invoiceDate", e.target.value)}
                          />
                        </td>
                        <td className="px-3 py-2">
                          <input
                            className={cn(inputCls, "h-8")}
                            value={inv.remarks}
                            onChange={(e) => updateInvoice(inv.id, "remarks", e.target.value)}
                          />
                        </td>
                        <td className="px-3 py-2 text-center">
                          <button
                            onClick={() => removeInvoice(inv.id)}
                            className="text-muted-foreground hover:text-destructive"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </td>
                      </tr>
                    ))}
                    {s.wbsInvoices.length === 0 && (
                      <tr>
                        <td
                          colSpan={5}
                          className="px-3 py-8 text-center text-sm text-muted-foreground"
                        >
                          No invoices scheduled. Add milestones to match the Total Services Value.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
              {totalInvoices !== totalServices && (
                <div className="mt-3 rounded-lg border border-warning/30 bg-warning/5 p-3 text-xs text-warning-foreground">
                  <strong>Warning:</strong> The invoice schedule total ({totalInvoices}) does not
                  match the total services value ({totalServices}).
                </div>
              )}
            </div>

            <div className="flex justify-end border-t border-border pt-6 pb-2">
              <button
                onClick={onClose}
                className="mr-3 rounded-md border border-input bg-card px-4 py-2 text-sm font-medium hover:bg-accent"
              >
                Cancel
              </button>
              <button
                disabled={submitting || totalInvoices !== totalServices}
                onClick={submit}
                className="inline-flex items-center gap-2 rounded-md bg-primary px-6 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 disabled:opacity-50"
              >
                {submitting ? "Submitting…" : "Submit WBS"}
              </button>
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}

const inputCls =
  "h-9 w-full rounded-md border border-input bg-card px-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring";

function SummaryRow({ label, value }: { label: string; value: string }) {
  return (
    <>
      <dt className="text-muted-foreground">{label}</dt>
      <dd className="font-medium">{value}</dd>
    </>
  );
}

let modalScrollLocks = 0;
let previousHtmlOverflow = "";
let previousBodyOverflow = "";
let previousBodyPaddingRight = "";
let previousBodyPosition = "";
let previousBodyTop = "";
let previousBodyLeft = "";
let previousBodyRight = "";
let previousScrollY = 0;

function lockPageScroll() {
  modalScrollLocks += 1;
  if (modalScrollLocks !== 1) return;
  previousHtmlOverflow = document.documentElement.style.overflow;
  previousBodyOverflow = document.body.style.overflow;
  previousBodyPaddingRight = document.body.style.paddingRight;
  previousBodyPosition = document.body.style.position;
  previousBodyTop = document.body.style.top;
  previousBodyLeft = document.body.style.left;
  previousBodyRight = document.body.style.right;
  previousScrollY = window.scrollY;
  const scrollbar = window.innerWidth - document.documentElement.clientWidth;
  document.documentElement.style.overflow = "hidden";
  document.body.style.overflow = "hidden";
  document.body.style.position = "fixed";
  document.body.style.top = `-${previousScrollY}px`;
  document.body.style.left = "0";
  document.body.style.right = "0";
  if (scrollbar > 0) document.body.style.paddingRight = `${scrollbar}px`;
}

function unlockPageScroll() {
  modalScrollLocks = Math.max(0, modalScrollLocks - 1);
  if (modalScrollLocks !== 0) return;
  document.documentElement.style.overflow = previousHtmlOverflow;
  document.body.style.overflow = previousBodyOverflow;
  document.body.style.paddingRight = previousBodyPaddingRight;
  document.body.style.position = previousBodyPosition;
  document.body.style.top = previousBodyTop;
  document.body.style.left = previousBodyLeft;
  document.body.style.right = previousBodyRight;
  window.scrollTo(0, previousScrollY);
}

export function Modal({
  title,
  children,
  onClose,
  wide,
  fullScreen,
  draggable,
}: {
  title: string;
  children: React.ReactNode;
  onClose: () => void;
  wide?: boolean;
  fullScreen?: boolean;
  draggable?: boolean;
}) {
  const { containerRef, handleRef } = useDraggable();
  const panelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    lockPageScroll();
    const panel = panelRef.current;
    const isScrollableY = (el: HTMLElement) => {
      const overflowY = window.getComputedStyle(el).overflowY;
      return (overflowY === "auto" || overflowY === "scroll") && el.scrollHeight > el.clientHeight + 1;
    };
    // Walk the full ancestor chain so nested overlays (KYC preview, combobox lists)
    // can still scroll even when they sit outside this modal panel.
    const nearestScrollable = (start: Node | null): HTMLElement | null => {
      let el: HTMLElement | null =
        start instanceof HTMLElement ? start : start?.parentElement ?? null;
      while (el && el !== document.body && el !== document.documentElement) {
        if (isScrollableY(el)) return el;
        el = el.parentElement;
      }
      return null;
    };
    const stopPageScroll = (e: Event) => {
      const target = e.target as Node | null;
      const targetEl = target instanceof HTMLElement ? target : target?.parentElement ?? null;
      // PDF/iframe previews handle their own wheel; don't steal those events.
      if (targetEl?.closest("iframe")) return;
      const scroller =
        nearestScrollable(target) ??
        (panel && panel.contains(target) && isScrollableY(panel) ? panel : null);
      if (scroller) {
        if (!(e instanceof WheelEvent)) return;
        const atTop = scroller.scrollTop <= 0 && e.deltaY < 0;
        const atBottom =
          scroller.scrollTop + scroller.clientHeight >= scroller.scrollHeight - 1 && e.deltaY > 0;
        if (!atTop && !atBottom) return;
      }
      e.preventDefault();
    };
    document.addEventListener("wheel", stopPageScroll, { passive: false });
    document.addEventListener("touchmove", stopPageScroll, { passive: false });
    return () => {
      document.removeEventListener("wheel", stopPageScroll);
      document.removeEventListener("touchmove", stopPageScroll);
      unlockPageScroll();
    };
  }, []);

  return (
    <div
      className={cn(
        "fixed inset-0 z-50 flex items-center justify-center overscroll-none",
        fullScreen ? "bg-background p-0" : "bg-black/40 p-4",
      )}
      onClick={!fullScreen && !draggable ? onClose : undefined}
      onWheel={(e) => {
        if (e.target === e.currentTarget) e.preventDefault();
      }}
    >
      <div
        ref={(node) => {
          panelRef.current = node;
          if (draggable) containerRef.current = node;
        }}
        className={cn(
          "overflow-y-auto overscroll-contain bg-card flex flex-col",
          fullScreen
            ? "w-full h-full rounded-none shadow-none"
            : "max-h-[90vh] w-full rounded-xl shadow-xl",
          !fullScreen && wide ? "max-w-3xl" : !fullScreen ? "max-w-lg" : "",
        )}
        style={draggable ? { willChange: "transform" } : undefined}
        onClick={(e) => e.stopPropagation()}
      >
        <header
          ref={draggable ? (handleRef as React.RefObject<HTMLElement>) : undefined}
          className={cn(
            "sticky top-0 z-10 flex items-center gap-3 border-b border-border bg-card px-5 py-4",
            draggable && "select-none",
          )}
          style={draggable ? { touchAction: "none" } : undefined}
        >
          {draggable && (
            <span className="mr-1 text-muted-foreground/50 shrink-0" title="Drag to move">
              <svg width="14" height="14" viewBox="0 0 16 16" fill="currentColor">
                <circle cx="5" cy="4" r="1.4" />
                <circle cx="11" cy="4" r="1.4" />
                <circle cx="5" cy="8" r="1.4" />
                <circle cx="11" cy="8" r="1.4" />
                <circle cx="5" cy="12" r="1.4" />
                <circle cx="11" cy="12" r="1.4" />
              </svg>
            </span>
          )}
          <h2 className="flex-1 text-lg font-semibold">{title}</h2>
          <button onClick={onClose} className="rounded-md p-1.5 hover:bg-accent" aria-label="Close">
            <X className="h-5 w-5" />
          </button>
        </header>
        <div className={cn("flex-1 p-6", fullScreen ? "mx-auto w-full max-w-5xl" : "")}>
          {children}
        </div>
      </div>
    </div>
  );
}
