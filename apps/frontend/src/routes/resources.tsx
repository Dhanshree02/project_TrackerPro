import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { Search, Lock, Users } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { people, projects, benchResourceIds } from "@/lib/mock-data";
import { Avatar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/resources")({
  head: () => ({
    meta: [
      { title: "Resources — Pulse PMO" },
      { name: "description", content: "Company-wide resource directory: employees, TLs, PMs, EMs, SPMs." },
    ],
  }),
  component: ResourcesPage,
});

const roleFilters = ["All", "Engineer", "Designer", "TL", "PM", "Engagement Manager", "Senior PM", "PMO", "HOD", "Business Owner"] as const;

function ResourcesPage() {
  const { isPMO, isHOD, isBO } = useRoleContext();
  const [q, setQ] = useState("");
  const [filter, setFilter] = useState<(typeof roleFilters)[number]>("All");

  if (!isPMO && !isHOD && !isBO) return <Navigate to="/" />;

  const utilization = useMemo(() => {
    const map: Record<string, number> = {};
    projects.forEach((p) => {
      [p.pmId, p.tlId, ...p.teamIds].forEach((id) => { map[id] = (map[id] ?? 0) + 1; });
    });
    return map;
  }, []);

  const filtered = people.filter((p) => {
    if (filter !== "All" && p.role !== filter) return false;
    if (!q.trim()) return true;
    return [p.name, p.email, p.role].some((v) => v.toLowerCase().includes(q.toLowerCase()));
  });

  const benchSet = new Set(benchResourceIds);

  return (
    <AppShell title="Resources" subtitle="Company-wide directory · view only">
      <div className="mb-4 flex flex-wrap items-center gap-2">
        <div className="relative flex-1 max-w-xs">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={q} onChange={(e) => setQ(e.target.value)}
            placeholder="Search name, role or email…"
            className="form-input h-9 w-full pl-8"
          />
        </div>
        <div className="flex flex-wrap items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          {roleFilters.map((r) => (
            <button key={r}
              onClick={() => setFilter(r)}
              className={cn(
                "rounded-md px-2.5 py-1",
                filter === r ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >{r}</button>
          ))}
        </div>
        <span className="ml-auto inline-flex items-center gap-1 rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] text-muted-foreground">
          <Lock className="h-3 w-3" /> Tracking only · no shuffle/replace
        </span>
      </div>

      <div className="grid gap-3 sm:grid-cols-3">
        <Stat label="Total resources" value={people.length} />
        <Stat label="On bench" value={benchResourceIds.length} tone="warn" />
        <Stat label="Active on projects" value={Object.keys(utilization).length} tone="success" />
      </div>

      <div className="mt-4 overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium">Name</th>
              <th className="px-3 py-2 font-medium">Role</th>
              <th className="px-3 py-2 font-medium">Email</th>
              <th className="px-3 py-2 font-medium">Active projects</th>
              <th className="px-3 py-2 font-medium">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {filtered.map((p) => (
              <tr key={p.id} className="hover:bg-accent/30">
                <td className="px-3 py-2.5">
                  <div className="flex items-center gap-2">
                    <Avatar name={p.name} size={28} />
                    <span className="font-medium">{p.name}</span>
                  </div>
                </td>
                <td className="px-3 py-2.5 text-muted-foreground">{p.role}</td>
                <td className="px-3 py-2.5 text-xs text-muted-foreground">{p.email}</td>
                <td className="px-3 py-2.5 tabular-nums">{utilization[p.id] ?? 0}</td>
                <td className="px-3 py-2.5">
                  {benchSet.has(p.id) ? (
                    <span className="inline-flex items-center gap-1 rounded-full border border-warning/40 bg-warning/15 px-2 py-0.5 text-[11px] font-medium text-warning-foreground">
                      <Users className="h-3 w-3" /> On Bench
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 rounded-full border border-success/30 bg-success/10 px-2 py-0.5 text-[11px] font-medium text-success">
                      Allocated
                    </span>
                  )}
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr><td colSpan={5} className="px-3 py-8 text-center text-sm text-muted-foreground">No resources match</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </AppShell>
  );
}

function Stat({ label, value, tone = "default" }: { label: string; value: number; tone?: "default" | "success" | "warn" }) {
  const cls = { default: "text-foreground", success: "text-success", warn: "text-warning-foreground" }[tone];
  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">{label}</div>
      <div className={cn("mt-2 text-2xl font-semibold tabular-nums", cls)}>{value}</div>
    </div>
  );
}
