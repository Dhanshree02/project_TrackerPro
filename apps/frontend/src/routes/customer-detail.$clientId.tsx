import { createFileRoute, Link, notFound, Navigate, useNavigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import {
  ChevronRight, Mail, Building2, ExternalLink,
  Calendar, Clock, TrendingUp, AlertTriangle, CheckCircle2, PauseCircle, Layers,
  User, Activity, History, Pencil, Check,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { HealthPill, StatusPill, ProgressBar } from "@/components/pills";
import { allClients, allProjects, useDhStore } from "@/lib/dh-store";
import { getPerson, people } from "@/lib/mock-data";
import { cn } from "@/lib/utils";

// Small inline avatar bubble (initials)
function AvatarBubble({ name, size = 22 }: { name: string; size?: number }) {
  const initials = name.split(" ").map((w) => w[0]).join("").slice(0, 2).toUpperCase();
  return (
    <span
      style={{ width: size, height: size, fontSize: size * 0.38 }}
      className="inline-flex shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-primary to-info font-semibold text-primary-foreground"
    >
      {initials}
    </span>
  );
}

export const Route = createFileRoute("/customer-detail/$clientId")({
  loader: ({ params }) => {
    const client = allClients().find((c) => c.id === params.clientId);
    if (!client) throw notFound();
    return { client };
  },
  head: ({ loaderData }) => ({
    meta: [
      { title: `${loaderData?.client.name ?? "Client"} — Customers — Pulse PMO` },
      {
        name: "description",
        content: `360° client view and project history for ${loaderData?.client.name ?? "client"}.`,
      },
    ],
  }),
  component: CustomerDetailPage,
});

// Format IDs as CL-XXXXXX or PR-XXXXXX
const fmtClientId = (id: string) => `CL-${id.replace(/\D/g, "").padStart(6, "0")}`;
const fmtProjectId = (id: string) => `PR-${id.replace(/\D/g, "").padStart(6, "0")}`;

type FilterTab = "all" | "new" | "ongoing" | "completed" | "archived" | "on_hold";

function CustomerDetailPage() {
  const { client } = Route.useLoaderData();
  const { isDhanshree } = useRoleContext();
  const navigate = useNavigate();

  // Live subscription to store — any client/project addition triggers re-render
  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);

  const [filter, setFilter] = useState<FilterTab>("all");

  // EM state — initialised from client.engagementManager or derived from projects
  const defaultEM = useMemo(() => {
    if (client.engagementManager) return client.engagementManager;
    // fallback: derive from first project EM field
    const proj = allProjects().find((p) => p.clientId === client.id && p.engagementManager);
    return proj?.engagementManager ?? "—";
  }, [client]);
  const [emName, setEmName] = useState<string>(defaultEM);
  const [showEMPicker, setShowEMPicker] = useState(false);
  const [emSearch, setEmSearch] = useState("");

  // EM pool — people with EM or Senior PM role
  const emPool = useMemo(() =>
    people.filter((p) => ["Engagement Manager", "Senior PM", "Business Owner"].includes(p.role)),
    []
  );

  if (!isDhanshree) return <Navigate to="/customers" />;

  // Re-compute whenever extraCount changes (reactive to new clients/projects)
  const allProj = useMemo(() => allProjects().filter((p) => p.clientId === client.id), [client.id, extraCount]);

  // Categorise
  const ongoingProjs = allProj.filter((p) => p.status === "ongoing" && p.progress > 0);
  const newProjs = allProj.filter((p) => p.status === "ongoing" && p.progress === 0);
  const completedProjs = allProj.filter((p) => p.status === "completed");
  const onHoldProjs = allProj.filter((p) => p.status === "on_hold");
  // Archived = completed that never reached 80% progress (historical/early-exit)
  const archivedProjs = completedProjs.filter((p) => p.progress < 80);
  const activeCompleted = completedProjs.filter((p) => p.progress >= 80);

  // At-risk = ongoing with health red/amber
  const atRiskCount = allProj.filter((p) => p.status === "ongoing" && (p.health === "red" || p.health === "amber")).length;

  // Client since = earliest project startDate
  const allDates = allProj.map((p) => p.startDate).filter(Boolean).sort();
  const clientSinceDate = allDates[0] ? new Date(allDates[0]).toLocaleDateString() : "—";
  const lastEngagementDate = allDates.length > 0 ? new Date(allDates[allDates.length - 1]).toLocaleDateString() : "—";
  const firstProjectName = allProj.find((p) => p.startDate === allDates[0])?.name ?? "—";
  const latestProjectName = allProj.find((p) => p.startDate === allDates[allDates.length - 1])?.name ?? "—";

  // Filter pool based on selected tab
  const poolByTab: Record<FilterTab, typeof allProj> = {
    all: allProj,
    new: newProjs,
    ongoing: ongoingProjs,
    completed: activeCompleted,
    archived: archivedProjs,
    on_hold: onHoldProjs,
  };
  const pool = poolByTab[filter];

  return (
    <AppShell title={client.name} subtitle={`${fmtClientId(client.id)} · ${client.industry} · 360° Client View`}>
      {/* Breadcrumb */}
      <nav className="mb-4 flex items-center gap-1 text-xs text-muted-foreground">
        <Link to="/customers" className="hover:text-foreground">Customers</Link>
        <ChevronRight className="h-3 w-3" />
        <span className="text-foreground font-medium">{client.name}</span>
      </nav>

      {/* ── CLIENT HEADER BANNER ── */}
      <div className="mb-4 rounded-xl border border-border bg-card shadow-sm overflow-hidden">
        <div className="flex flex-wrap items-center gap-4 p-5">
          {/* Logo */}
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-info text-lg font-bold text-primary-foreground">
            {client.logo}
          </div>

          {/* Identity */}
          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center gap-2">
              <h1 className="text-base font-bold text-foreground">{client.name}</h1>
              <span className={cn(
                "inline-flex rounded-full border px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide",
                client.clientType === "NEW"
                  ? "border-primary/30 bg-primary/10 text-primary"
                  : "border-success/30 bg-success/10 text-success"
              )}>
                {client.clientType === "NEW" ? "New Client" : "Existing Client"}
              </span>
              <span className="inline-flex rounded-full border border-success/30 bg-success/10 px-2 py-0.5 text-[10px] font-semibold text-success">Active</span>

              {/* EM Name + Change button */}
              {isDhanshree && (
                <div className="relative flex items-center gap-1.5">
                  <span className="inline-flex items-center gap-1.5 rounded-full border border-info/30 bg-info/10 px-2.5 py-0.5 text-[11px] font-semibold text-info">
                    <User className="h-3 w-3" />
                    {emName !== "—" ? emName : "No EM assigned"}
                  </span>
                  <button
                    onClick={() => { setShowEMPicker((v) => !v); setEmSearch(""); }}
                    className="inline-flex items-center gap-1 rounded-md border border-border bg-card px-2 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
                  >
                    <Pencil className="h-2.5 w-2.5" /> Change EM
                  </button>

                  {showEMPicker && (
                    <div className="absolute left-0 top-8 z-50 w-56 rounded-md border border-border bg-card shadow-lg p-2 space-y-1.5">
                      <input
                        value={emSearch}
                        onChange={(e) => setEmSearch(e.target.value)}
                        placeholder="Search EM…"
                        autoFocus
                        className="h-7 w-full rounded-md border border-input bg-card px-2 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring"
                      />
                      <ul className="max-h-40 overflow-y-auto divide-y divide-border">
                        {emPool
                          .filter((p) => !emSearch.trim() || p.name.toLowerCase().includes(emSearch.toLowerCase()))
                          .map((p) => (
                            <li key={p.id}>
                              <button
                                onClick={() => { setEmName(p.name); setShowEMPicker(false); }}
                                className={cn(
                                  "flex w-full items-center gap-2 px-2 py-1.5 text-xs text-left hover:bg-accent/40 rounded-sm",
                                  emName === p.name && "bg-primary/5"
                                )}
                              >
                                <AvatarBubble name={p.name} size={20} />
                                <div className="flex-1 min-w-0">
                                  <div className="font-medium truncate">{p.name}</div>
                                  <div className="text-[10px] text-muted-foreground">{p.role}</div>
                                </div>
                                {emName === p.name && <Check className="h-3 w-3 text-primary shrink-0" />}
                              </button>
                            </li>
                          ))
                        }
                        {emPool.filter((p) => !emSearch.trim() || p.name.toLowerCase().includes(emSearch.toLowerCase())).length === 0 && (
                          <li className="px-2 py-3 text-center text-xs text-muted-foreground">No match</li>
                        )}
                      </ul>
                    </div>
                  )}
                </div>
              )}
            </div>
            <div className="mt-1 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
              <span className="font-mono font-semibold text-foreground">{fmtClientId(client.id)}</span>
              <span>·</span>
              <span>{client.industry}</span>
              <span>·</span>
              <span className="flex items-center gap-1"><Mail className="h-3 w-3" />{client.contact}</span>
            </div>
          </div>

          {/* Clickable stat cards — act as filter buttons */}
          <div className="flex flex-wrap gap-2">
            {([
              { id: "all"       as FilterTab, label: "Total",     value: allProj.length,                        color: "text-foreground",         ring: "ring-border" },
              { id: "new"       as FilterTab, label: "New",       value: newProjs.length,                       color: "text-primary",            ring: "ring-primary" },
              { id: "ongoing"   as FilterTab, label: "Ongoing",   value: ongoingProjs.length + newProjs.length, color: "text-info",               ring: "ring-info" },
              { id: "completed" as FilterTab, label: "Completed", value: activeCompleted.length,                color: "text-success",            ring: "ring-success" },
              { id: "on_hold"   as FilterTab, label: "On Hold",   value: onHoldProjs.length,                   color: "text-warning-foreground", ring: "ring-warning" },
              { id: "archived"  as FilterTab, label: "Archived",  value: archivedProjs.length,                 color: "text-muted-foreground",   ring: "ring-muted-foreground" },
            ] as { id: FilterTab; label: string; value: number; color: string; ring: string }[]).map(({ id, label, value, color, ring }) => (
              <button
                key={id}
                onClick={() => setFilter(id)}
                className={cn(
                  "rounded-lg border bg-muted/30 px-4 py-2 text-center min-w-[72px] transition-all hover:bg-muted/60",
                  filter === id ? `border-transparent ring-2 ${ring} bg-muted/50` : "border-border"
                )}
              >
                <div className={cn("text-xl font-bold tabular-nums", color)}>{value}</div>
                <div className="text-[10px] text-muted-foreground font-medium uppercase tracking-wide">{label}</div>
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="grid gap-4 xl:grid-cols-4">
        {/* ── LEFT SIDEBAR ── */}
        <aside className="xl:col-span-1 space-y-3">

          {/* Client Information */}
          <div className="rounded-xl border border-border bg-card shadow-sm">
            <div className="border-b border-border px-4 py-3">
              <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground flex items-center gap-1.5">
                <Building2 className="h-3.5 w-3.5" /> Client Information
              </h2>
            </div>
            <dl className="divide-y divide-border">
              {[
                { label: "Client ID", value: fmtClientId(client.id), mono: true },
                { label: "Client Name", value: client.name },
                { label: "Industry", value: client.industry },
                { label: "Contact Person", value: client.contact.split("@")[0] },
                { label: "Email", value: client.contact },
                { label: "Client Type", value: client.clientType === "NEW" ? "New Client" : "Existing Client" },
                { label: "Client Since", value: clientSinceDate },
                { label: "Status", value: "Active" },
              ].map(({ label, value, mono }) => (
                <div key={label} className="grid grid-cols-2 gap-2 px-4 py-2.5 text-xs">
                  <dt className="text-muted-foreground font-medium">{label}</dt>
                  <dd className={cn("font-medium truncate text-right", mono && "font-mono text-foreground")}>{value}</dd>
                </div>
              ))}
            </dl>
          </div>

          {/* Health Summary */}
          <div className="rounded-xl border border-border bg-card shadow-sm">
            <div className="border-b border-border px-4 py-3">
              <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground flex items-center gap-1.5">
                <Activity className="h-3.5 w-3.5" /> Health Summary
              </h2>
            </div>
            <div className="p-4 space-y-2">
              {[
                { label: "Active Projects", value: ongoingProjs.length + newProjs.length, icon: TrendingUp, color: "text-info" },
                { label: "At Risk", value: atRiskCount, icon: AlertTriangle, color: atRiskCount > 0 ? "text-destructive" : "text-muted-foreground" },
                { label: "Completed", value: activeCompleted.length, icon: CheckCircle2, color: "text-success" },
                { label: "On Hold", value: onHoldProjs.length, icon: PauseCircle, color: "text-warning-foreground" },
              ].map(({ label, value, icon: Icon, color }) => (
                <div key={label} className="flex items-center justify-between rounded-lg border border-border bg-muted/20 px-3 py-2">
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <Icon className={cn("h-3.5 w-3.5", color)} />
                    {label}
                  </div>
                  <span className={cn("text-sm font-bold tabular-nums", color)}>{value}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Client Timeline */}
          <div className="rounded-xl border border-border bg-card shadow-sm">
            <div className="border-b border-border px-4 py-3">
              <h2 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground flex items-center gap-1.5">
                <History className="h-3.5 w-3.5" /> Client Timeline
              </h2>
            </div>
            <div className="p-4 space-y-3">
              {[
                { label: "Client Created", value: clientSinceDate, icon: Calendar },
                { label: "First Project", value: firstProjectName, icon: Layers },
                { label: "Latest Project", value: latestProjectName, icon: TrendingUp },
                { label: "Last Engagement", value: lastEngagementDate, icon: Clock },
              ].map(({ label, value, icon: Icon }) => (
                <div key={label} className="flex items-start gap-2.5 text-xs">
                  <div className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full border border-border bg-muted">
                    <Icon className="h-3 w-3 text-muted-foreground" />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="text-muted-foreground font-medium">{label}</div>
                    <div className="font-semibold truncate">{value}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </aside>

        {/* ── MAIN PROJECTS SECTION ── */}
        <section className="xl:col-span-3 space-y-3">



          {/* Project Table */}
          <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden">
            <header className="flex items-center justify-between border-b border-border px-5 py-3">
              <div>
                <h3 className="text-sm font-semibold">
                  {filter === "all" ? "All Projects" :
                   filter === "on_hold" ? "On Hold Projects" :
                   `${filter.charAt(0).toUpperCase() + filter.slice(1)} Projects`}
                </h3>
                <p className="text-[11px] text-muted-foreground mt-0.5">
                  {pool.length} project{pool.length !== 1 ? "s" : ""}
                </p>
              </div>
            </header>

            {pool.length === 0 ? (
              <div className="flex flex-col items-center gap-2 py-12 text-center">
                <Layers className="h-8 w-8 text-muted-foreground/40" />
                <p className="text-sm text-muted-foreground">No projects in this category</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-muted/30 text-left text-xs uppercase tracking-wide text-muted-foreground">
                    <tr>
                      <th className="px-4 py-2.5 font-medium">Project ID</th>
                      <th className="px-4 py-2.5 font-medium">Project Name</th>
                      <th className="px-4 py-2.5 font-medium">Status</th>
                      <th className="px-4 py-2.5 font-medium">Progress</th>
                      <th className="px-4 py-2.5 font-medium">PM</th>
                      <th className="px-4 py-2.5 font-medium">Start Date</th>
                      <th className="px-4 py-2.5 font-medium">End Date</th>
                      <th className="px-4 py-2.5 text-right font-medium">Open</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border">
                    {pool.map((p) => {
                      const pm = getPerson(p.pmId);
                      const category = p.status === "completed"
                        ? (p.progress >= 80 ? "Completed" : "Archived")
                        : p.status === "ongoing"
                          ? (p.progress === 0 ? "New" : "Ongoing")
                          : "On Hold";

                      return (
                        <tr
                          key={p.id}
                          className="hover:bg-accent/30 transition-colors cursor-pointer"
                          onClick={() => navigate({ to: "/projects/$projectId", params: { projectId: p.id } })}
                        >
                          <td className="px-4 py-3">
                            <div className="flex items-center gap-1.5">
                              <span className="font-mono text-xs text-muted-foreground">{fmtProjectId(p.id)}</span>
                              <span className={cn(
                                "rounded-full border px-1.5 py-0.5 text-[9px] font-bold uppercase",
                                category === "New" ? "border-primary/30 bg-primary/10 text-primary" :
                                  category === "Ongoing" ? "border-info/30 bg-info/10 text-info" :
                                    category === "Completed" ? "border-success/30 bg-success/10 text-success" :
                                      category === "On Hold" ? "border-warning/30 bg-warning/10 text-warning-foreground" :
                                        "border-muted-foreground/30 bg-muted text-muted-foreground"
                              )}>
                                {category}
                              </span>
                            </div>
                          </td>
                          <td className="px-4 py-3 max-w-[200px]">
                            <div className="flex items-center gap-2">
                              <HealthPill status={p.health} />
                              <div className="min-w-0">
                                <div className="truncate font-medium text-sm">{p.name}</div>
                                <div className="truncate text-[11px] text-muted-foreground">{p.description}</div>
                              </div>
                            </div>
                          </td>
                          <td className="px-4 py-3">
                            <StatusPill status={p.status} />
                          </td>
                          <td className="px-4 py-3">
                            <div className="flex items-center gap-2 min-w-[100px]">
                              <ProgressBar value={p.progress} className="flex-1" />
                              <span className="text-xs tabular-nums text-muted-foreground w-8 text-right">
                                {p.progress}%
                              </span>
                            </div>
                          </td>
                          <td className="px-4 py-3">
                            {pm ? (
                              <div className="flex items-center gap-1.5">
                                <AvatarBubble name={pm.name} size={20} />
                                <span className="text-xs whitespace-nowrap">{pm.name}</span>
                              </div>
                            ) : (
                              <span className="text-xs text-muted-foreground">—</span>
                            )}
                          </td>
                          <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">
                            {p.startDate ? new Date(p.startDate).toLocaleDateString() : "—"}
                          </td>
                          <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">
                            {p.endDate ? new Date(p.endDate).toLocaleDateString() : "—"}
                          </td>
                          <td className="px-4 py-3 text-right" onClick={(e) => e.stopPropagation()}>
                            <Link
                              to="/projects/$projectId"
                              params={{ projectId: p.id }}
                              className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-[11px] font-medium hover:bg-accent transition-colors"
                            >
                              <ExternalLink className="h-3 w-3" /> Open
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
    </AppShell>
  );
}
