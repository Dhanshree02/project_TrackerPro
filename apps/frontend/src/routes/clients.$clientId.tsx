import { createFileRoute, Link, notFound } from "@tanstack/react-router";
import { ChevronRight, Mail, Briefcase } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { clients } from "@/lib/mock-data";
import { HealthPill, StatusPill, ProgressBar } from "@/components/pills";

export const Route = createFileRoute("/clients/$clientId")({
  loader: ({ params }) => {
    const client = clients.find((c) => c.id === params.clientId);
    if (!client) throw notFound();
    return { client };
  },
  head: ({ loaderData }) => ({
    meta: [
      { title: `${loaderData?.client.name ?? "Client"} — Pulse PMO` },
      { name: "description", content: `Projects and details for ${loaderData?.client.name ?? "client"}.` },
    ],
  }),
  component: ClientDetail,
});

function ClientDetail() {
  const { client } = Route.useLoaderData();
  const { assignedProjects } = useRoleContext();
  const projs = assignedProjects.filter((p) => p.clientId === client.id);
  
  const completedProjs = projs.filter((p) => p.status === "completed");
  const ongoingProjs = projs.filter((p) => p.status === "ongoing");
  const completedCount = completedProjs.length;
  const avgCompletionRate = completedProjs.length > 0 ? Math.round(completedProjs.reduce((sum, p) => sum + (p.progress || 0), 0) / completedProjs.length) : 0;

  return (
    <AppShell title={client.name} subtitle={`${client.industry} · ${projs.length} assigned projects`}>
      <nav className="mb-4 flex items-center gap-1 text-xs text-muted-foreground">
        <Link to="/clients" className="hover:text-foreground">Clients</Link>
        <ChevronRight className="h-3 w-3" />
        <span className="text-foreground">{client.name}</span>
      </nav>

      <div className="grid gap-4 lg:grid-cols-3">
        <aside className="rounded-xl border border-border bg-card p-5 shadow-sm">
          <div className="flex h-16 w-16 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-info text-xl font-bold text-primary-foreground">
            {client.logo}
          </div>
          <h2 className="mt-3 text-lg font-semibold">{client.name}</h2>
          <p className="text-sm text-muted-foreground">{client.industry}</p>
          <div className="mt-4 space-y-2 text-sm">
            <div className="flex items-center gap-2 text-muted-foreground">
              <Mail className="h-4 w-4" /> {client.contact}
            </div>
            <div className="flex items-center gap-2 text-muted-foreground">
              <Briefcase className="h-4 w-4" /> {projs.length} projects
            </div>
          </div>
        </aside>

        <section className="lg:col-span-2 space-y-4">
          {/* Completed Projects Summary */}
          {completedProjs.length > 0 && (
            <div className="grid gap-3 sm:grid-cols-3">
              <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
                <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Completed Projects</div>
                <div className="mt-2 text-2xl font-semibold tabular-nums text-success">{completedCount}</div>
              </div>
              <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
                <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Avg Completion Rate</div>
                <div className="mt-2 text-2xl font-semibold tabular-nums">{avgCompletionRate}%</div>
              </div>
              <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
                <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Ongoing Projects</div>
                <div className="mt-2 text-2xl font-semibold tabular-nums">{ongoingProjs.length}</div>
              </div>
            </div>
          )}

          {/* All Projects */}
          <div className="rounded-xl border border-border bg-card shadow-sm">
            <header className="border-b border-border px-5 py-3">
              <h3 className="text-sm font-semibold">All Projects</h3>
              <p className="text-xs text-muted-foreground">Completed, Ongoing and Project History</p>
            </header>
            <ul className="divide-y divide-border">
              {projs.map((p) => (
                <li key={p.id}>
                  <Link
                    to="/projects/$projectId"
                    params={{ projectId: p.id }}
                    className="flex items-center gap-3 px-5 py-3 hover:bg-accent/40"
                  >
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="truncate text-sm font-medium">{p.name}</span>
                        <HealthPill status={p.health} />
                        <StatusPill status={p.status} />
                      </div>
                      <p className="mt-0.5 line-clamp-1 text-xs text-muted-foreground">{p.description}</p>
                      <div className="mt-2 flex items-center gap-3">
                        <ProgressBar value={p.progress} className="max-w-xs" />
                        <span className="text-xs tabular-nums text-muted-foreground">{p.progress}%</span>
                      </div>
                    </div>
                    <ChevronRight className="h-4 w-4 text-muted-foreground" />
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </section>
      </div>
    </AppShell>
  );
}
