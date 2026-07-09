import { createFileRoute, Link, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Search, Filter, ArrowRight, Layers } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { clients, getPerson, projectStatusLabels, type ProjectStatus, type HealthStatus } from "@/lib/mock-data";
import { HealthPill, StatusPill, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/portfolio")({
  head: () => ({
    meta: [
      { title: "Portfolio — Pulse PMO" },
      { name: "description", content: "Department-wide read-only portfolio view of every project, owner and health." },
    ],
  }),
  component: PortfolioPage,
});

function PortfolioPage() {
  const { isHOD, isBO, assignedProjects } = useRoleContext();
  const [q, setQ] = useState("");
  const [status, setStatus] = useState<"all" | ProjectStatus>("all");
  const [health, setHealth] = useState<"all" | HealthStatus>("all");

  if (!isHOD && !isBO) return <Navigate to="/" />;

  const filtered = useMemo(
    () => assignedProjects.filter((p) => {
      if (status !== "all" && p.status !== status) return false;
      if (health !== "all" && p.health !== health) return false;
      if (!q.trim()) return true;
      const c = clients.find((c) => c.id === p.clientId);
      return [p.name, c?.name ?? "", p.description].some((v) => v.toLowerCase().includes(q.toLowerCase()));
    }),
    [assignedProjects, status, health, q],
  );

  const stats = {
    total: assignedProjects.length,
    ongoing: assignedProjects.filter((p) => p.status === "ongoing").length,
    red: assignedProjects.filter((p) => p.health === "red").length,
    amber: assignedProjects.filter((p) => p.health === "amber").length,
  };

  return (
    <AppShell title="Portfolio" subtitle="Department-wide read-only project tracking">
      <div className="mb-4 grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Mini label="Total projects" value={stats.total} />
        <Mini label="Ongoing" value={stats.ongoing} />
        <Mini label="At risk" value={stats.amber} tone="warn" />
        <Mini label="Critical" value={stats.red} tone="danger" />
      </div>

      <div className="mb-4 flex flex-wrap items-center gap-2">
        <div className="relative max-w-xs flex-1">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q} onChange={(e) => setQ(e.target.value)}
            placeholder="Search project, client…"
            className="h-9 w-full rounded-md border border-input bg-card pl-8 pr-3 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        <div className="flex items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          <Filter className="ml-1 h-3.5 w-3.5 text-muted-foreground" />
          {(["all", "ongoing", "completed", "on_hold"] as const).map((s) => (
            <button
              key={s}
              onClick={() => setStatus(s)}
              className={cn(
                "rounded-md px-2.5 py-1 capitalize",
                status === s ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              {s === "all" ? "All status" : projectStatusLabels[s]}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          {(["all", "green", "amber", "red"] as const).map((h) => (
            <button
              key={h}
              onClick={() => setHealth(h)}
              className={cn(
                "rounded-md px-2.5 py-1 capitalize",
                health === h ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              {h === "all" ? "All health" : h}
            </button>
          ))}
        </div>
      </div>

      <section className="rounded-xl border border-border bg-card shadow-sm">
        <header className="flex items-center gap-2 border-b border-border px-4 py-3 text-sm font-semibold">
          <Layers className="h-4 w-4 text-muted-foreground" /> All projects ({filtered.length})
        </header>
        <ul className="divide-y divide-border">
          {filtered.map((p) => {
            const pm = getPerson(p.pmId);
            const tl = getPerson(p.tlId);
            const client = clients.find((c) => c.id === p.clientId);
            const taskTotal = p.tasks.length;
            const taskDone = p.tasks.filter((t) => t.status === "done").length;
            return (
              <li key={p.id}>
                <Link
                  to="/projects/$projectId"
                  params={{ projectId: p.id }}
                  className="grid items-center gap-3 px-4 py-3 hover:bg-accent/40 lg:grid-cols-[1.4fr,1fr,1fr,140px,40px]"
                >
                  <div className="min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className="truncate text-sm font-semibold">{p.name}</span>
                      <HealthPill status={p.health} />
                      <StatusPill status={p.status} />
                    </div>
                    <p className="mt-0.5 line-clamp-1 text-xs text-muted-foreground">{p.description}</p>
                  </div>
                  <div className="text-xs">
                    <div className="font-medium">{client?.name}</div>
                    <div className="text-muted-foreground">{client?.industry}</div>
                  </div>
                  <div className="text-xs">
                    <div className="font-medium">PM · {pm.name}</div>
                    <div className="text-muted-foreground">TL · {tl.name} · {p.teamIds.length + 2} people</div>
                  </div>
                  <div>
                    <div className="mb-1 flex justify-between text-[11px] tabular-nums text-muted-foreground">
                      <span>{taskDone}/{taskTotal} tasks</span>
                      <span>{p.progress}%</span>
                    </div>
                    <ProgressBar value={p.progress} />
                  </div>
                  <ArrowRight className="hidden h-4 w-4 text-muted-foreground lg:block" />
                </Link>
              </li>
            );
          })}
          {filtered.length === 0 && (
            <li className="px-4 py-10 text-center text-sm text-muted-foreground">No projects match your filters</li>
          )}
        </ul>
      </section>

      <p className="mt-4 text-center text-xs text-muted-foreground">
        Read-only view · open any project to see WBS, tasks, team, risks and delivery status
      </p>
    </AppShell>
  );
}

function Mini({ label, value, tone = "default" }: { label: string; value: number; tone?: "default" | "warn" | "danger" }) {
  const cls = tone === "danger" ? "text-destructive" : tone === "warn" ? "text-warning-foreground" : "";
  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">{label}</div>
      <div className={cn("mt-2 text-2xl font-semibold tabular-nums", cls)}>{value}</div>
    </div>
  );
}
