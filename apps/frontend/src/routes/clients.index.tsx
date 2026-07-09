import { createFileRoute, Link } from "@tanstack/react-router";
import { ChevronRight, LayoutGrid, List } from "lucide-react";
import { useState } from "react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/clients/")({
  head: () => ({
    meta: [
      { title: "Clients & Projects — Pulse PMO" },
      { name: "description", content: "Browse assigned clients and their project portfolios." },
    ],
  }),
  component: ClientsPage,
});

function ClientsPage() {
  const { assignedClients, assignedProjects } = useRoleContext();
  const [view, setView] = useState<"card" | "list">("card");

  return (
    <AppShell title="Clients & Projects" subtitle="Read-only view of your assigned portfolio">
      <div className="mb-4 flex items-center justify-end">
        <div className="flex gap-1 rounded-lg border border-border bg-card p-1 text-xs shadow-sm">
          <button onClick={() => setView("card")} aria-label="Card view"
            className={cn("inline-flex items-center gap-1 rounded-md px-2.5 py-1",
              view === "card" ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
            <LayoutGrid className="h-3.5 w-3.5" /> Kanban
          </button>
          <button onClick={() => setView("list")} aria-label="List view"
            className={cn("inline-flex items-center gap-1 rounded-md px-2.5 py-1",
              view === "list" ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
            <List className="h-3.5 w-3.5" /> List
          </button>
        </div>
      </div>

      {view === "card" ? (
        <div className="grid gap-4 lg:grid-cols-2">
          {assignedClients.map((client) => {
            const projs = assignedProjects.filter((p) => p.clientId === client.id);
            const ongoing = projs.filter((p) => p.status === "ongoing").length;
            return (
              <Link
                key={client.id}
                to="/clients/$clientId"
                params={{ clientId: client.id }}
                className="rounded-xl border border-border bg-card shadow-sm p-4 hover:bg-accent/30 hover:shadow-md transition-all"
              >
                <article>
                  <div className="flex items-center gap-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-gradient-to-br from-primary to-info text-primary-foreground font-semibold text-sm">
                      {client.logo}
                    </div>
                    <div className="flex-1">
                      <h3 className="text-sm font-semibold">{client.name}</h3>
                      <p className="text-xs text-muted-foreground">
                        {client.industry} · {projs.length} project{projs.length !== 1 ? 's' : ''} · {ongoing} ongoing
                      </p>
                    </div>
                  </div>
                </article>
              </Link>
            );
          })}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
          <table className="w-full text-sm">
            <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr>
                <th className="px-3 py-2 font-medium">Client</th>
                <th className="px-3 py-2 font-medium">Industry</th>
                <th className="px-3 py-2 font-medium">Projects</th>
                <th className="px-3 py-2 font-medium">Ongoing</th>
                <th className="px-3 py-2 font-medium text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-border">
              {assignedClients.map((client) => {
                const projs = assignedProjects.filter((p) => p.clientId === client.id);
                const ongoing = projs.filter((p) => p.status === "ongoing").length;
                return (
                  <tr key={client.id} className="hover:bg-accent/30">
                    <td className="px-3 py-2.5">
                      <div className="flex items-center gap-2">
                        <div className="flex h-8 w-8 items-center justify-center rounded-md bg-gradient-to-br from-primary to-info text-xs font-semibold text-primary-foreground">
                          {client.logo}
                        </div>
                        <span className="font-medium">{client.name}</span>
                      </div>
                    </td>
                    <td className="px-3 py-2.5 text-muted-foreground">{client.industry}</td>
                    <td className="px-3 py-2.5">{projs.length}</td>
                    <td className="px-3 py-2.5">{ongoing}</td>
                    <td className="px-3 py-2.5 text-right">
                      <Link
                        to="/clients/$clientId"
                        params={{ clientId: client.id }}
                        className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs hover:bg-accent"
                      >
                        Open <ChevronRight className="h-3 w-3" />
                      </Link>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </AppShell>
  );
}
