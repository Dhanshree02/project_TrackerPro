import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import {
  Inbox, Search, Calendar, Users, Sparkles, AlertTriangle,
  CheckCircle2, ClipboardList, History, X, Bell, Target, Eye, Network, ChevronDown, ChevronRight,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import {
  wbsRequests as initialRequests,
  personWorkload,
  people,
  clients,
  projects,
  pmBuckets,
  assignments,
  allocationHistory,
  getPerson,
  allocationRoleLabels,
  wbsStatusLabels,
  type WbsRequest,
  type WbsRequestStatus,
  type AllocationRoleSlot,
  type WbsAllocationAuditEntry,
  type Project,
  type AllocationEvent,
} from "@/lib/mock-data";
import { Avatar, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/wbs-allocation")({
  head: () => ({
    meta: [
      { title: "WBS Allocation — Pulse PMO" },
      { name: "description", content: "Receive new WBS from Sales and allocate Senior PM, Engagement Manager and Project Manager." },
    ],
  }),
  component: WbsAllocationPage,
});

const ROLE_TO_PERSON_ROLE: Record<AllocationRoleSlot, string> = {
  spm: "Senior PM",
  em: "Engagement Manager",
  pm: "PM",
};

const STATUS_FILTERS: (WbsRequestStatus | "all")[] = ["all", "new", "under_allocation", "assigned", "active", "closed"];

function statusClasses(s: WbsRequestStatus) {
  return {
    new: "bg-info/10 text-info border-info/30",
    under_allocation: "bg-warning/15 text-warning-foreground border-warning/40",
    assigned: "bg-primary/10 text-primary border-primary/30",
    active: "bg-success/10 text-success border-success/30",
    closed: "bg-muted text-muted-foreground border-border",
  }[s];
}

function StatusBadge({ status }: { status: WbsRequestStatus }) {
  return (
    <span className={cn("inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium", statusClasses(status))}>
      {wbsStatusLabels[status]}
    </span>
  );
}

function fitScore(personId: string, req: WbsRequest): number {
  const w = personWorkload.find((x) => x.personId === personId);
  if (!w) return 0;
  const skillHits = req.skillNeeds.filter((s) =>
    w.skills.some((ps) => ps.toLowerCase().includes(s.toLowerCase()) || s.toLowerCase().includes(ps.toLowerCase())),
  ).length;
  const skillScore = (skillHits / Math.max(1, req.skillNeeds.length)) * 60;
  const utilScore = Math.max(0, 40 - (w.utilization - 60) * 0.8);
  const benchBoost = w.onBench ? 15 : 0;
  return Math.round(Math.min(100, skillScore + utilScore + benchBoost));
}

function WbsAllocationPage() {
  const { isPMO, user } = useRoleContext();
  const [requests, setRequests] = useState<WbsRequest[]>(initialRequests);
  const [selectedId, setSelectedId] = useState<string>(initialRequests[0].id);
  const [statusFilter, setStatusFilter] = useState<(WbsRequestStatus | "all")>("all");
  const [search, setSearch] = useState("");
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [showWbs, setShowWbs] = useState(true);

  if (!isPMO) return <Navigate to="/" />;

  const filtered = requests.filter((r) => {
    if (statusFilter !== "all" && r.status !== statusFilter) return false;
    if (search) {
      const q = search.toLowerCase();
      const client = clients.find((c) => c.id === r.clientId)?.name ?? "";
      if (!`${r.code} ${r.projectName} ${client}`.toLowerCase().includes(q)) return false;
    }
    return true;
  });

  const selected = requests.find((r) => r.id === selectedId) ?? filtered[0] ?? requests[0];
  const client = clients.find((c) => c.id === selected.clientId)!;

  function pushAudit(reqId: string, action: string) {
    const entry: WbsAllocationAuditEntry = {
      id: `wa${Date.now()}`,
      actorId: user.id,
      action,
      at: new Date().toISOString(),
    };
    setRequests((prev) => prev.map((r) => r.id === reqId ? { ...r, audit: [entry, ...r.audit] } : r));
  }

  function assign(role: AllocationRoleSlot, personId: string) {
    const target = requests.find((r) => r.id === selected.id)!;
    const existing = target.slots.find((s) => s.role === role);
    const wasAssigned = existing?.personId;
    const personName = getPerson(personId).name;

    setRequests((prev) => prev.map((r) => {
      if (r.id !== selected.id) return r;
      const slots = r.slots.map((s) => s.role === role ? { ...s, personId, assignedAt: new Date().toISOString() } : s);
      const allFilled = slots.every((s) => !!s.personId);
      const nextStatus: WbsRequestStatus =
        r.status === "new" ? "under_allocation" :
        allFilled && r.status === "under_allocation" ? "assigned" :
        r.status;
      return { ...r, slots, status: nextStatus };
    }));

    pushAudit(
      selected.id,
      wasAssigned
        ? `Reassigned ${allocationRoleLabels[role]} → ${personName}`
        : `Assigned ${allocationRoleLabels[role]} → ${personName}`,
    );
  }

  function clearSlot(role: AllocationRoleSlot) {
    setRequests((prev) => prev.map((r) => {
      if (r.id !== selected.id) return r;
      const slots = r.slots.map((s) => s.role === role ? { role: s.role } : s);
      return { ...r, slots };
    }));
    pushAudit(selected.id, `Cleared ${allocationRoleLabels[role]}`);
  }

  function activate() {
    const req = requests.find((r) => r.id === selected.id)!;
    const spmId = req.slots.find((s) => s.role === "spm")?.personId;
    const emId  = req.slots.find((s) => s.role === "em")?.personId;
    const pmId  = req.slots.find((s) => s.role === "pm")?.personId;

    // 1) Create a real project from the WBS and add to global projects list
    const newProjectId = `wbs-${req.id}`;
    if (pmId && !projects.some((p) => p.id === newProjectId)) {
      const newProject: Project = {
        id: newProjectId,
        name: req.projectName,
        clientId: req.clientId,
        status: "ongoing",
        health: "green",
        progress: 0,
        pmId,
        tlId: "u5",
        teamIds: [],
        startDate: req.timelineStart,
        endDate: req.timelineEnd,
        budget: req.estBudget,
        spent: 0,
        description: req.scope,
        wbs: [
          { id: `${newProjectId}-w1`, name: "1. Discovery", progress: 0 },
          { id: `${newProjectId}-w2`, name: "2. Design", progress: 0 },
          { id: `${newProjectId}-w3`, name: "3. Build", progress: 0 },
          { id: `${newProjectId}-w4`, name: "4. Launch", progress: 0 },
        ],
        tasks: [],
      };
      projects.push(newProject);

      // 2) Add to assigned PM's capacity bucket (+20% allocation)
      const bucket = pmBuckets.find((b) => b.pmId === pmId);
      if (bucket) {
        bucket.allocated = Math.min(bucket.capacity, bucket.allocated + 20);
      } else {
        pmBuckets.push({ pmId, capacity: 100, allocated: 20 });
      }

      // 3) Register client visibility for assigned SPM / EM dashboards
      if (spmId === "u1" && !assignments.senior_pm.includes(req.clientId)) {
        assignments.senior_pm.push(req.clientId);
      }
      if (emId === "u2" && !assignments.engagement_manager.includes(req.clientId)) {
        assignments.engagement_manager.push(req.clientId);
      }

      // 4) Write to allocation history (visible in WBS / Allocation timeline)
      const now = new Date().toISOString();
      const events: AllocationEvent[] = [];
      if (spmId) events.push({ id: `al-${newProjectId}-spm`, projectId: newProjectId, action: "Assigned Senior PM",          actorId: user.id, toId: spmId, at: now });
      if (emId)  events.push({ id: `al-${newProjectId}-em`,  projectId: newProjectId, action: "Assigned Engagement Manager", actorId: user.id, toId: emId,  at: now });
      events.push({ id: `al-${newProjectId}-pm`, projectId: newProjectId, action: "Assigned Project Manager",  actorId: user.id, toId: pmId,  at: now });
      allocationHistory.unshift(...events);
    }

    setRequests((prev) => prev.map((r) => r.id === selected.id ? { ...r, status: "active" } : r));
    pushAudit(
      selected.id,
      `Project activated · added to ${getPerson(pmId!).name}'s bucket · ownership notifications sent`,
    );
    setConfirmOpen(false);
  }

  // candidates per role with fit scores
  const candidatesByRole = useMemo(() => {
    const result: Record<AllocationRoleSlot, { person: typeof people[number]; w: typeof personWorkload[number]; score: number }[]> = {
      spm: [], em: [], pm: [],
    };
    (Object.keys(result) as AllocationRoleSlot[]).forEach((role) => {
      const personRole = ROLE_TO_PERSON_ROLE[role];
      const items = people
        .filter((p) => p.role === personRole)
        .map((p) => {
          const w = personWorkload.find((x) => x.personId === p.id) ?? {
            personId: p.id, activeProjects: 0, utilization: 0, availableFrom: new Date().toISOString(), skills: [], onBench: true,
          };
          return { person: p, w, score: fitScore(p.id, selected) };
        })
        .sort((a, b) => b.score - a.score);
      result[role] = items;
    });
    return result;
  }, [selected]);

  const allFilled = selected.slots.every((s) => !!s.personId);
  const counts = STATUS_FILTERS.reduce<Record<string, number>>((acc, s) => {
    acc[s] = s === "all" ? requests.length : requests.filter((r) => r.status === (s as WbsRequestStatus)).length;
    return acc;
  }, {});

  return (
    <AppShell title="WBS Allocation" subtitle="Sales-handed WBS intake · review & allocate ownership">
      {/* status filter strip */}
      <div className="mb-3 flex flex-wrap items-center gap-2">
        <div className="relative">
          <Search className="pointer-events-none absolute left-2 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search WBS, project, client…"
            className="form-input h-9 w-64 pl-8"
          />
        </div>
        <div className="flex flex-wrap items-center gap-1.5">
          {STATUS_FILTERS.map((s) => (
            <button
              key={s}
              onClick={() => setStatusFilter(s)}
              className={cn(
                "inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-medium transition-colors",
                statusFilter === s
                  ? "border-primary bg-primary/10 text-primary"
                  : "border-border bg-card text-muted-foreground hover:bg-accent/50",
              )}
            >
              {s === "all" ? "All" : wbsStatusLabels[s as WbsRequestStatus]}
              <span className="rounded-full bg-background/60 px-1.5 text-[10px] tabular-nums">{counts[s] ?? 0}</span>
            </button>
          ))}
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-[320px,1fr]">
        {/* WBS inbox */}
        <aside className="rounded-xl border border-border bg-card shadow-sm">
          <header className="flex items-center gap-2 border-b border-border px-4 py-3">
            <Inbox className="h-4 w-4 text-primary" />
            <h3 className="text-sm font-semibold">WBS Inbox</h3>
            <span className="ml-auto text-[11px] text-muted-foreground">{filtered.length} items</span>
          </header>
          <ul className="max-h-[calc(100vh-260px)] divide-y divide-border overflow-y-auto">
            {filtered.map((r) => {
              const c = clients.find((cl) => cl.id === r.clientId)!;
              const filled = r.slots.filter((s) => s.personId).length;
              return (
                <li key={r.id}>
                  <button
                    onClick={() => setSelectedId(r.id)}
                    className={cn(
                      "block w-full px-4 py-3 text-left transition-colors",
                      selected.id === r.id ? "bg-accent/60" : "hover:bg-accent/40",
                    )}
                  >
                    <div className="flex items-center gap-2">
                      <span className="text-[10px] font-mono text-muted-foreground">{r.code}</span>
                      <span className="ml-auto"><StatusBadge status={r.status} /></span>
                    </div>
                    <div className="mt-1 truncate text-sm font-medium">{r.projectName}</div>
                    <div className="mt-0.5 flex items-center justify-between text-[11px] text-muted-foreground">
                      <span className="truncate">{c.name}</span>
                      <span className="tabular-nums">{filled}/{r.slots.length} owners</span>
                    </div>
                    <div className="mt-0.5 flex items-center justify-between text-[10px] text-muted-foreground">
                      <span>Received {new Date(r.receivedAt).toLocaleDateString()}</span>
                      <span>{r.receivedFrom.replace("Sales · ", "")}</span>
                    </div>
                  </button>
                </li>
              );
            })}
            {filtered.length === 0 && (
              <li className="px-4 py-6 text-center text-xs text-muted-foreground">No WBS match the filters.</li>
            )}
          </ul>
        </aside>

        {/* Split workspace */}
        <section className="grid gap-4 xl:grid-cols-2">
          {/* LEFT — WBS details */}
          <div className="rounded-xl border border-border bg-card shadow-sm">
            <header className="flex flex-wrap items-center gap-2 border-b border-border p-4">
              <ClipboardList className="h-4 w-4 text-primary" />
              <div className="min-w-0">
                <div className="flex items-center gap-2">
                  <h2 className="truncate text-base font-semibold">{selected.projectName}</h2>
                  <StatusBadge status={selected.status} />
                </div>
                <p className="text-[11px] text-muted-foreground">
                  {selected.code} · {client.name} · {selected.receivedFrom}
                </p>
              </div>
            </header>

            <div className="space-y-4 p-5 text-sm">
              <p className="text-muted-foreground">{selected.scope}</p>

              <div className="grid grid-cols-2 gap-3">
                <Stat icon={Calendar} label="Timeline">
                  {new Date(selected.timelineStart).toLocaleDateString()} → {new Date(selected.timelineEnd).toLocaleDateString()}
                </Stat>
                <Stat icon={Users} label="Team size">{selected.teamSize} people</Stat>
                <Stat icon={Target} label="Required roles">
                  {selected.requiredRoles.map((r) => allocationRoleLabels[r]).join(", ")}
                </Stat>
                <Stat icon={Sparkles} label="Est. budget">${(selected.estBudget / 1000).toFixed(0)}k</Stat>
                <Stat icon={AlertTriangle} label="Complexity">
                  <span className={cn(
                    "rounded-full border px-1.5 py-0.5 text-[10px] font-semibold",
                    selected.complexity === "High" ? "border-destructive/40 bg-destructive/10 text-destructive" :
                    selected.complexity === "Medium" ? "border-warning/40 bg-warning/10 text-warning-foreground" :
                    "border-success/40 bg-success/10 text-success",
                  )}>{selected.complexity}</span>
                </Stat>
                <Stat icon={Calendar} label="Received">
                  {new Date(selected.receivedAt).toLocaleDateString()} · {selected.receivedFrom}
                </Stat>
              </div>

              <div className="grid gap-3 sm:grid-cols-2">
                <div>
                  <div className="mb-1 text-xs font-medium text-muted-foreground">Modules</div>
                  <ul className="space-y-1">
                    {selected.modules.map((m) => (
                      <li key={m} className="flex items-start gap-1.5 text-[12px]">
                        <span className="mt-1 h-1.5 w-1.5 shrink-0 rounded-full bg-primary" />{m}
                      </li>
                    ))}
                  </ul>
                </div>
                <div>
                  <div className="mb-1 text-xs font-medium text-muted-foreground">Deliverables</div>
                  <ul className="space-y-1">
                    {selected.deliverables.map((d) => (
                      <li key={d} className="flex items-start gap-1.5 text-[12px]">
                        <CheckCircle2 className="mt-0.5 h-3 w-3 shrink-0 text-success" />{d}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>

              <div>
                <div className="mb-1 text-xs font-medium text-muted-foreground">Skill needs</div>
                <div className="flex flex-wrap gap-1.5">
                  {selected.skillNeeds.map((s) => (
                    <span key={s} className="rounded-md border border-border bg-accent/40 px-2 py-0.5 text-[11px]">{s}</span>
                  ))}
                </div>
              </div>

              {/* Timeline strip */}
              <div>
                <div className="mb-1 text-xs font-medium text-muted-foreground">Allocation timeline</div>
                <div className="relative h-8 rounded-md border border-border bg-muted/40">
                  <div
                    className="absolute inset-y-0 rounded-md bg-primary/30"
                    style={{
                      left: "4%",
                      width: `${Math.min(96, Math.max(8, selected.resourceCount * 6))}%`,
                    }}
                  />
                  <div className="relative flex h-full items-center justify-between px-2 text-[10px] font-medium text-foreground/80">
                    <span>{new Date(selected.timelineStart).toLocaleString("default", { month: "short", year: "2-digit" })}</span>
                    <span>{new Date(selected.timelineEnd).toLocaleString("default", { month: "short", year: "2-digit" })}</span>
                  </div>
                </div>
              </div>

              {/* WBS structure preview */}
              <div className="rounded-lg border border-border bg-background">
                <button
                  type="button"
                  onClick={() => setShowWbs((v) => !v)}
                  className="flex w-full items-center gap-2 px-3 py-2 text-left text-xs font-semibold"
                >
                  {showWbs ? <ChevronDown className="h-3.5 w-3.5" /> : <ChevronRight className="h-3.5 w-3.5" />}
                  <Network className="h-3.5 w-3.5 text-primary" />
                  View WBS structure
                  <span className="ml-auto inline-flex items-center gap-1 rounded-full border border-border bg-card px-1.5 py-0.5 text-[10px] font-medium text-muted-foreground">
                    <Eye className="h-3 w-3" /> {selected.modules.length} phases
                  </span>
                </button>
                {showWbs && (
                  <ol className="space-y-1.5 border-t border-border p-3">
                    {selected.modules.map((m, i) => {
                      const deliv = selected.deliverables.filter((_, di) => di % selected.modules.length === i);
                      return (
                        <li key={m} className="rounded-md border border-border/60 bg-card px-2.5 py-2">
                          <div className="flex items-center justify-between gap-2">
                            <div className="flex items-center gap-2 text-xs font-medium">
                              <span className="inline-flex h-5 w-5 items-center justify-center rounded-full bg-primary/10 text-[10px] font-semibold text-primary">
                                {i + 1}
                              </span>
                              {m}
                            </div>
                            <span className="text-[10px] text-muted-foreground">
                              Owner: {(["spm","em","pm"] as AllocationRoleSlot[])
                                .map((r) => selected.slots.find((s) => s.role === r)?.personId)
                                .filter(Boolean)
                                .map((id) => getPerson(id!).name.split(" ")[0])
                                .join(" · ") || "Unassigned"}
                            </span>
                          </div>
                          {deliv.length > 0 && (
                            <ul className="mt-1.5 space-y-0.5 pl-7">
                              {deliv.map((d) => (
                                <li key={d} className="flex items-start gap-1.5 text-[11px] text-muted-foreground">
                                  <CheckCircle2 className="mt-0.5 h-3 w-3 shrink-0 text-success" />{d}
                                </li>
                              ))}
                            </ul>
                          )}
                        </li>
                      );
                    })}
                  </ol>
                )}
              </div>


              <div>
                <div className="mb-2 flex items-center gap-1.5 text-xs font-medium text-muted-foreground">
                  <History className="h-3.5 w-3.5" /> Allocation history
                </div>
                <ol className="relative ml-2 space-y-2 border-l border-border pl-4">
                  {selected.audit.map((ev) => (
                    <li key={ev.id} className="text-[11px]">
                      <span className="absolute -left-[5px] mt-1.5 h-2 w-2 rounded-full bg-primary" />
                      <span className="font-medium">{getPerson(ev.actorId).name}</span> · {ev.action}
                      <span className="ml-2 text-muted-foreground">{new Date(ev.at).toLocaleString()}</span>
                    </li>
                  ))}
                </ol>
              </div>
            </div>
          </div>

          {/* RIGHT — Allocation board */}
          <div className="rounded-xl border border-border bg-card shadow-sm">
            <header className="flex flex-wrap items-center gap-2 border-b border-border p-4">
              <Sparkles className="h-4 w-4 text-primary" />
              <h3 className="text-base font-semibold">Allocation board</h3>
              <span className="ml-auto text-[11px] text-muted-foreground">Pick an owner from each dropdown</span>
            </header>

            {/* Slots — dropdown selectors */}
            <div className="grid gap-3 p-4 sm:grid-cols-3">
              {(["spm","em","pm"] as AllocationRoleSlot[]).map((role) => {
                const slot = selected.slots.find((s) => s.role === role);
                const required = selected.requiredRoles.includes(role);
                const person = slot?.personId ? getPerson(slot.personId) : null;
                const w = slot?.personId ? personWorkload.find((x) => x.personId === slot.personId) : undefined;
                const options = candidatesByRole[role];
                return (
                  <div
                    key={role}
                    className={cn(
                      "rounded-lg border p-3 transition-colors",
                      !required ? "border-border/50 bg-muted/30 opacity-60" :
                        person ? "border-success/40 bg-success/5" : "border-border bg-background",
                    )}
                  >
                    <div className="flex items-center justify-between">
                      <span className="text-[10px] font-semibold uppercase tracking-wide text-muted-foreground">
                        {allocationRoleLabels[role]}
                      </span>
                      {!required ? <span className="text-[10px] text-muted-foreground">Not needed</span> :
                        person && (
                          <button onClick={() => clearSlot(role)} className="text-muted-foreground hover:text-destructive">
                            <X className="h-3.5 w-3.5" />
                          </button>
                        )
                      }
                    </div>

                    {required && (
                      <select
                        value={slot?.personId ?? ""}
                        onChange={(e) => e.target.value && assign(role, e.target.value)}
                        className="form-input mt-2 h-8 w-full text-xs"
                      >
                        <option value="">Select {allocationRoleLabels[role]}…</option>
                        {options.map(({ person: p, w: pw, score }) => (
                          <option key={p.id} value={p.id}>
                            {p.name} · {pw.utilization}% util · {score}% match
                          </option>
                        ))}
                      </select>
                    )}

                    {person && (
                      <div className="mt-2">
                        <div className="flex items-center gap-2">
                          <Avatar name={person.name} size={26} />
                          <div className="min-w-0">
                            <div className="truncate text-sm font-medium">{person.name}</div>
                            <div className="text-[11px] text-muted-foreground">{person.role}</div>
                          </div>
                        </div>
                        {w && (
                          <div className="mt-2">
                            <div className="flex justify-between text-[10px] text-muted-foreground">
                              <span>Utilization</span><span className="tabular-nums">{w.utilization}%</span>
                            </div>
                            <ProgressBar value={w.utilization} className="mt-1" />
                          </div>
                        )}
                      </div>
                    )}
                  </div>
                );
              })}
            </div>


            {/* Confirmation / reassignment banner */}
            <div className="border-t border-border p-4">
              {selected.status === "active" || selected.status === "closed" ? (
                <div className="flex flex-wrap items-center gap-3 rounded-lg border border-info/40 bg-info/5 p-3 text-xs">
                  <CheckCircle2 className="h-4 w-4 text-info" />
                  <span className="flex-1">
                    Project is {selected.status === "active" ? "active" : "closed"}. You can reassign Senior PM, Engagement Manager or Project Manager — changes are tracked in the allocation history.
                  </span>
                </div>
              ) : (
                <div className={cn(
                  "flex flex-wrap items-center gap-3 rounded-lg border p-3 text-xs",
                  allFilled ? "border-success/40 bg-success/5" : "border-warning/40 bg-warning/5",
                )}>
                  {allFilled ? <CheckCircle2 className="h-4 w-4 text-success" /> : <AlertTriangle className="h-4 w-4 text-warning" />}
                  <span className="flex-1">
                    {allFilled
                      ? "All required roles assigned. Confirm to create project ownership and notify owners."
                      : "Pending role assignments. Pick owners from the dropdowns or click a suggested candidate."}
                  </span>
                  <button
                    disabled={!allFilled}
                    onClick={() => setConfirmOpen(true)}
                    className="inline-flex items-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-[11px] font-semibold text-primary-foreground shadow-sm hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
                  >
                    <Bell className="h-3.5 w-3.5" />
                    Confirm allocation
                  </button>
                </div>
              )}
            </div>

            {/* Suggestion engine */}
            <div className="border-t border-border p-4">
              <h4 className="mb-2 flex items-center gap-1.5 text-sm font-semibold">
                <Sparkles className="h-4 w-4 text-primary" /> Smart suggestions
              </h4>
              <div className="space-y-3">
                {(selected.requiredRoles).map((role) => (
                  <div key={role}>
                    <div className="mb-1 text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                      {allocationRoleLabels[role]}
                    </div>
                    <div className="grid gap-2 sm:grid-cols-2">
                      {candidatesByRole[role].map(({ person, w, score }, idx) => {
                        const overloaded = w.utilization >= 90;
                        const isCurrent = selected.slots.find((s) => s.role === role)?.personId === person.id;
                        return (
                          <button
                            type="button"
                            key={person.id}
                            onClick={() => assign(role, person.id)}
                            className={cn(
                              "group rounded-lg border bg-background p-2.5 text-left shadow-sm transition-all hover:border-primary hover:shadow-md",
                              idx === 0 ? "border-primary/40 ring-1 ring-primary/20" : "border-border",
                              overloaded && "border-destructive/40",
                              isCurrent && "border-success ring-1 ring-success/30",
                            )}
                          >
                            <div className="flex items-start gap-2">
                              <Avatar name={person.name} size={28} />
                              <div className="min-w-0 flex-1">
                                <div className="flex items-center gap-1.5">
                                  <span className="truncate text-sm font-medium">{person.name}</span>
                                  {idx === 0 && (
                                    <span className="rounded-full bg-primary/15 px-1.5 py-0.5 text-[9px] font-semibold text-primary">
                                      BEST FIT
                                    </span>
                                  )}
                                  {w.onBench && (
                                    <span className="rounded-full bg-info/15 px-1.5 py-0.5 text-[9px] font-semibold text-info">
                                      ON BENCH
                                    </span>
                                  )}
                                  {overloaded && (
                                    <span className="rounded-full bg-destructive/15 px-1.5 py-0.5 text-[9px] font-semibold text-destructive">
                                      OVERLOADED
                                    </span>
                                  )}
                                  {isCurrent && (
                                    <span className="rounded-full bg-success/15 px-1.5 py-0.5 text-[9px] font-semibold text-success">
                                      ASSIGNED
                                    </span>
                                  )}
                                </div>
                                <div className="text-[10px] text-muted-foreground">
                                  {w.activeProjects} projects · avail {new Date(w.availableFrom).toLocaleDateString()}
                                </div>
                                <div className="mt-1.5">
                                  <div className="flex justify-between text-[10px] text-muted-foreground">
                                    <span>Util</span><span className="tabular-nums">{w.utilization}%</span>
                                  </div>
                                  <ProgressBar value={w.utilization} />
                                </div>
                                <div className="mt-1.5 flex items-center justify-between">
                                  <div className="flex flex-wrap gap-1">
                                    {w.skills.slice(0, 2).map((s) => (
                                      <span key={s} className="rounded bg-accent/50 px-1.5 py-0.5 text-[9px]">{s}</span>
                                    ))}
                                  </div>
                                  <span className="text-[10px] font-semibold text-primary">
                                    {score}% match
                                  </span>
                                </div>
                              </div>
                            </div>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>
      </div>

      {/* Confirm dialog */}
      {confirmOpen && (
        <div className="fixed inset-0 z-40 flex items-center justify-center bg-background/80 p-4 backdrop-blur-sm">
          <div className="w-full max-w-md rounded-xl border border-border bg-card p-5 shadow-xl">
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-5 w-5 text-success" />
              <h3 className="text-base font-semibold">Confirm allocation</h3>
            </div>
            <p className="mt-2 text-sm text-muted-foreground">
              {selected.code} · <span className="font-medium text-foreground">{selected.projectName}</span> will be activated. Owners get notifications and the project appears in their dashboards.
            </p>
            <ul className="mt-3 space-y-1.5 text-xs">
              {selected.slots.filter((s) => s.personId).map((s) => (
                <li key={s.role} className="flex items-center gap-2">
                  <Avatar name={getPerson(s.personId!).name} size={22} />
                  <span className="font-medium">{getPerson(s.personId!).name}</span>
                  <span className="text-muted-foreground">— {allocationRoleLabels[s.role]}</span>
                </li>
              ))}
            </ul>
            <div className="mt-4 flex justify-end gap-2">
              <button onClick={() => setConfirmOpen(false)} className="rounded-md border border-border px-3 py-1.5 text-xs">
                Cancel
              </button>
              <button onClick={activate} className="rounded-md bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground">
                Activate project
              </button>
            </div>
          </div>
        </div>
      )}
    </AppShell>
  );
}

function Stat({ icon: Icon, label, children }: { icon: React.ComponentType<{ className?: string }>; label: string; children: React.ReactNode }) {
  return (
    <div className="rounded-lg border border-border bg-background p-2.5">
      <div className="flex items-center gap-1.5 text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
        <Icon className="h-3 w-3" /> {label}
      </div>
      <div className="mt-1 text-xs">{children}</div>
    </div>
  );
}
