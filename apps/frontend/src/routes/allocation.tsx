import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Network, History, Users, Save } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import {
  projects as initialProjects,
  clients,
  people,
  pmBuckets,
  benchResourceIds,
  allocationHistory,
  getPerson,
  type Project,
  type AllocationEvent,
} from "@/lib/mock-data";
import { HealthPill, StatusPill, ProgressBar, Avatar } from "@/components/pills";

export const Route = createFileRoute("/allocation")({
  head: () => ({
    meta: [
      { title: "WBS / Allocation — Pulse PMO" },
      { name: "description", content: "PMO allocation control: assign Senior PM, Engagement Manager and Project Manager to projects." },
    ],
  }),
  component: AllocationPage,
});

function AllocationPage() {
  const { isPMO, user } = useRoleContext();
  const [projs, setProjs] = useState<Project[]>(initialProjects);
  const [history, setHistory] = useState<AllocationEvent[]>(allocationHistory);
  const [selectedId, setSelectedId] = useState<string>(initialProjects[0].id);

  if (!isPMO) return <Navigate to="/" />;

  const selected = projs.find((p) => p.id === selectedId)!;
  const client = clients.find((c) => c.id === selected.clientId)!;

  const seniorPMs = people.filter((p) => p.role === "Senior PM");
  const ems = people.filter((p) => p.role === "Engagement Manager");
  const pms = people.filter((p) => p.role === "PM");

  // Synthetic ownership map (Senior PM / EM) — derived per project
  const [ownership, setOwnership] = useState<Record<string, { spmId: string; emId: string }>>(
    () => Object.fromEntries(
      initialProjects.map((p) => [p.id, { spmId: "u1", emId: "u2" }]),
    ),
  );

  function record(action: string, toId: string, fromId?: string) {
    const ev: AllocationEvent = {
      id: `al${Date.now()}`,
      projectId: selected.id,
      action, actorId: user.id, toId, fromId,
      at: new Date().toISOString(),
    };
    setHistory((h) => [ev, ...h]);
  }

  function reassignPM(toId: string) {
    const fromId = selected.pmId;
    if (toId === fromId) return;
    setProjs((prev) => prev.map((p) => p.id === selected.id ? { ...p, pmId: toId } : p));
    record("Reassigned Project Manager", toId, fromId);
  }
  function reassignSPM(toId: string) {
    const own = ownership[selected.id];
    if (toId === own.spmId) return;
    setOwnership((o) => ({ ...o, [selected.id]: { ...o[selected.id], spmId: toId } }));
    record("Assigned Senior PM", toId, own.spmId);
  }
  function reassignEM(toId: string) {
    const own = ownership[selected.id];
    if (toId === own.emId) return;
    setOwnership((o) => ({ ...o, [selected.id]: { ...o[selected.id], emId: toId } }));
    record("Assigned Engagement Manager", toId, own.emId);
  }

  const projHistory = useMemo(
    () => history.filter((h) => h.projectId === selected.id),
    [history, selected.id],
  );

  return (
    <AppShell title="WBS / Allocation" subtitle="Review WBS and assign ownership across projects">
      <div className="grid gap-3 sm:grid-cols-3">
        <Card label="PM bucket capacity" icon={Users}>
          <ul className="mt-2 space-y-2">
            {pmBuckets.map((b) => {
              const p = getPerson(b.pmId);
              return (
                <li key={b.pmId}>
                  <div className="flex justify-between text-xs">
                    <span className="font-medium">{p.name}</span>
                    <span className="tabular-nums text-muted-foreground">{b.allocated}/{b.capacity}%</span>
                  </div>
                  <ProgressBar value={b.allocated} className="mt-1" />
                </li>
              );
            })}
          </ul>
        </Card>
        <Card label="On-bench resources" icon={Users}>
          <div className="mt-2 flex flex-wrap gap-1.5">
            {benchResourceIds.map((id) => {
              const p = getPerson(id);
              return (
                <span key={id} className="inline-flex items-center gap-1.5 rounded-md border border-warning/40 bg-warning/10 px-2 py-1 text-xs">
                  <Avatar name={p.name} size={20} /> {p.name} · {p.role}
                </span>
              );
            })}
          </div>
        </Card>
        <Card label="Allocation events" icon={History}>
          <div className="mt-2 text-2xl font-semibold tabular-nums">{history.length}</div>
          <div className="text-xs text-muted-foreground">Lifetime ownership changes tracked</div>
        </Card>
      </div>

      <div className="mt-4 grid gap-4 lg:grid-cols-[320px,1fr]">
        <aside className="rounded-xl border border-border bg-card shadow-sm">
          <header className="border-b border-border px-4 py-3">
            <h3 className="text-sm font-semibold">Projects</h3>
            <p className="text-xs text-muted-foreground">Select a project to manage ownership</p>
          </header>
          <ul className="max-h-[60vh] divide-y divide-border overflow-y-auto">
            {projs.map((p) => (
              <li key={p.id}>
                <button
                  onClick={() => setSelectedId(p.id)}
                  className={`w-full px-4 py-3 text-left ${selectedId === p.id ? "bg-accent/60" : "hover:bg-accent/40"}`}
                >
                  <div className="flex items-center gap-2">
                    <span className="truncate text-sm font-medium">{p.name}</span>
                    <HealthPill status={p.health} />
                  </div>
                  <div className="mt-1 flex items-center justify-between text-[11px] text-muted-foreground">
                    <span>{clients.find((c) => c.id === p.clientId)?.name}</span>
                    <StatusPill status={p.status} />
                  </div>
                </button>
              </li>
            ))}
          </ul>
        </aside>

        <section className="rounded-xl border border-border bg-card shadow-sm">
          <header className="flex flex-wrap items-center gap-2 border-b border-border p-4">
            <Network className="h-4 w-4 text-primary" />
            <h2 className="text-base font-semibold">{selected.name}</h2>
            <span className="text-xs text-muted-foreground">· {client.name}</span>
            <Link to="/projects/$projectId" params={{ projectId: selected.id }} className="ml-auto text-xs font-medium text-primary hover:underline">
              View project →
            </Link>
          </header>

          <div className="grid gap-4 p-5 md:grid-cols-2">
            <div>
              <h3 className="text-sm font-semibold">WBS review</h3>
              <div className="mt-2 rounded-lg border border-border">
                {selected.wbs.map((n) => (
                  <div key={n.id} className="border-b border-border px-3 py-2 last:border-b-0">
                    <div className="flex items-center justify-between text-sm">
                      <span>{n.name}</span>
                      <span className="text-xs tabular-nums text-muted-foreground">{n.progress}%</span>
                    </div>
                    <ProgressBar value={n.progress} className="mt-1" />
                  </div>
                ))}
              </div>
            </div>

            <div className="space-y-3">
              <h3 className="text-sm font-semibold">Map ownership</h3>
              <Assign label="Senior PM" value={ownership[selected.id].spmId} options={seniorPMs} onChange={reassignSPM} />
              <Assign label="Engagement Manager" value={ownership[selected.id].emId} options={ems} onChange={reassignEM} />
              <Assign label="Project Manager" value={selected.pmId} options={pms} onChange={reassignPM} />
              <p className="text-[11px] text-muted-foreground">
                <Save className="mr-1 inline h-3 w-3" /> Changes are saved instantly and recorded in the allocation history.
              </p>
            </div>
          </div>

          <div className="border-t border-border p-5">
            <h3 className="mb-2 flex items-center gap-1.5 text-sm font-semibold">
              <History className="h-4 w-4" /> Allocation history
            </h3>
            <ol className="relative ml-2 space-y-2 border-l border-border pl-4">
              {projHistory.map((ev) => {
                const actor = getPerson(ev.actorId);
                const to = getPerson(ev.toId);
                const from = ev.fromId ? getPerson(ev.fromId) : null;
                return (
                  <li key={ev.id} className="text-xs">
                    <span className="absolute -left-[5px] mt-1.5 h-2 w-2 rounded-full bg-primary" />
                    <span className="font-medium">{actor.name}</span> · {ev.action} →{" "}
                    <span className="font-medium">{to.name}</span>
                    {from && <span className="text-muted-foreground"> (was {from.name})</span>}
                    <span className="ml-2 text-muted-foreground">{new Date(ev.at).toLocaleString()}</span>
                  </li>
                );
              })}
              {projHistory.length === 0 && (
                <li className="text-xs text-muted-foreground">No allocation events yet for this project.</li>
              )}
            </ol>
          </div>
        </section>
      </div>
    </AppShell>
  );
}

function Card({ label, icon: Icon, children }: { label: string; icon: React.ComponentType<{ className?: string }>; children: React.ReactNode }) {
  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">{label}</span>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </div>
      {children}
    </div>
  );
}

function Assign({ label, value, options, onChange }: {
  label: string; value: string;
  options: { id: string; name: string; role: string }[];
  onChange: (id: string) => void;
}) {
  return (
    <label className="block">
      <span className="mb-1 block text-xs font-medium text-muted-foreground">{label}</span>
      <div className="flex items-center gap-2">
        <Avatar name={getPerson(value).name} size={28} />
        <select value={value} onChange={(e) => onChange(e.target.value)} className="form-input flex-1">
          {options.map((p) => (
            <option key={p.id} value={p.id}>{p.name} · {p.role}</option>
          ))}
        </select>
      </div>
    </label>
  );
}
