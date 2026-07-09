import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { BarChart3, Download, AlertTriangle, Activity, Users, Briefcase, DollarSign, TrendingUp } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import {
  clients, projects, people, issues, invoices,
  benchResourceIds, getPerson, issueTypeLabels, projectStatusLabels,
} from "@/lib/mock-data";
import { HealthPill, StatusPill, PriorityPill, IssueStatusPill, ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/reports")({
  head: () => ({
    meta: [
      { title: "Reports — Pulse PMO" },
      { name: "description", content: "Department reports: delivery, client, resource, escalation and project health." },
    ],
  }),
  component: ReportsPage,
});

type Tab = "delivery" | "client" | "resource" | "escalation" | "health" | "revenue" | "profitability";

const baseTabs: { id: Tab; label: string; icon: typeof BarChart3 }[] = [
  { id: "delivery", label: "Delivery", icon: Briefcase },
  { id: "client", label: "Client", icon: Users },
  { id: "resource", label: "Resource", icon: Users },
  { id: "escalation", label: "Escalation", icon: AlertTriangle },
  { id: "health", label: "Project Health", icon: Activity },
];
const execTabs: { id: Tab; label: string; icon: typeof BarChart3 }[] = [
  { id: "revenue", label: "Revenue", icon: DollarSign },
  { id: "profitability", label: "Profitability", icon: TrendingUp },
];

function ReportsPage() {
  const { isHOD, isBO } = useRoleContext();
  const [tab, setTab] = useState<Tab>("delivery");
  if (!isHOD && !isBO) return <Navigate to="/" />;
  const tabs = isBO ? [...baseTabs, ...execTabs] : baseTabs;

  return (
    <AppShell title="Reports" subtitle="Department-wide reporting · delivery, client, resource and governance">
      <div className="mb-4 flex flex-wrap items-center gap-2">
        <div className="flex items-center gap-1 rounded-lg border border-border bg-card p-1 text-xs">
          {tabs.map((t) => (
            <button
              key={t.id}
              onClick={() => setTab(t.id)}
              className={cn(
                "inline-flex items-center gap-1.5 rounded-md px-2.5 py-1.5",
                tab === t.id ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              <t.icon className="h-3.5 w-3.5" /> {t.label}
            </button>
          ))}
        </div>
        <button
          onClick={() => alert("Export queued — report will be emailed.")}
          className="ml-auto inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 py-1.5 text-xs hover:bg-accent"
        >
          <Download className="h-3.5 w-3.5" /> Export
        </button>
      </div>

      {tab === "delivery" && <DeliveryReport />}
      {tab === "client" && <ClientReport />}
      {tab === "resource" && <ResourceReport />}
      {tab === "escalation" && <EscalationReport />}
      {tab === "health" && <HealthReport />}
      {tab === "revenue" && <RevenueReport />}
      {tab === "profitability" && <ProfitabilityReport />}
    </AppShell>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-xl border border-border bg-card shadow-sm">
      <header className="border-b border-border px-4 py-3 text-sm font-semibold">{title}</header>
      <div className="p-4">{children}</div>
    </section>
  );
}

function KPI({ label, value, sub }: { label: string; value: string | number; sub?: string }) {
  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">{label}</div>
      <div className="mt-2 text-2xl font-semibold tabular-nums">{value}</div>
      {sub && <div className="mt-1 text-[11px] text-muted-foreground">{sub}</div>}
    </div>
  );
}

function DeliveryReport() {
  const onTime = projects.filter((p) => p.health === "green" && p.status !== "on_hold").length;
  const atRisk = projects.filter((p) => p.health === "amber").length;
  const delayed = projects.filter((p) => p.health === "red").length;
  const completed = projects.filter((p) => p.status === "completed").length;
  const ongoing = projects.filter((p) => p.status === "ongoing").length;
  const onHold = projects.filter((p) => p.status === "on_hold").length;

  return (
    <div className="grid gap-4">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <KPI label="On track" value={onTime} sub={`${Math.round((onTime / projects.length) * 100)}% of portfolio`} />
        <KPI label="At risk" value={atRisk} />
        <KPI label="Delayed" value={delayed} />
        <KPI label="Completed YTD" value={completed} />
      </div>
      <Section title="Delivery status by project">
        <table className="w-full text-sm">
          <thead className="text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr><th className="py-2">Project</th><th>Status</th><th>Health</th><th>Progress</th><th>Ends</th></tr>
          </thead>
          <tbody className="divide-y divide-border">
            {projects.map((p) => (
              <tr key={p.id}>
                <td className="py-2.5">
                  <div className="font-medium">{p.name}</div>
                  <div className="text-xs text-muted-foreground">{clients.find((c) => c.id === p.clientId)?.name}</div>
                </td>
                <td><StatusPill status={p.status} /></td>
                <td><HealthPill status={p.health} /></td>
                <td className="w-48"><ProgressBar value={p.progress} /></td>
                <td className="text-xs text-muted-foreground">{new Date(p.endDate).toLocaleDateString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>
      <Section title="Status mix">
        <div className="grid gap-3 sm:grid-cols-3 text-sm">
          {[
            { k: "ongoing", n: ongoing },
            { k: "completed", n: completed },
            { k: "on_hold", n: onHold },
          ].map((r) => (
            <div key={r.k} className="rounded-lg border border-border bg-muted/30 p-3">
              <div className="text-xs text-muted-foreground">{projectStatusLabels[r.k as keyof typeof projectStatusLabels]}</div>
              <div className="text-2xl font-semibold tabular-nums">{r.n}</div>
            </div>
          ))}
        </div>
      </Section>
    </div>
  );
}

function ClientReport() {
  const rows = clients.map((c) => {
    const projs = projects.filter((p) => p.clientId === c.id);
    const inv = invoices.filter((i) => projs.some((p) => p.id === i.projectId));
    const paid = inv.filter((i) => i.status === "paid").reduce((s, i) => s + i.invoiceAmount, 0);
    const overdue = inv.filter((i) => i.status === "overdue").reduce((s, i) => s + i.invoiceAmount, 0);
    const active = projs.filter((p) => p.status === "ongoing").length;
    const reds = projs.filter((p) => p.health === "red").length;
    return { c, projs, paid, overdue, active, reds };
  });
  const totalRevenue = rows.reduce((s, r) => s + r.paid, 0);

  return (
    <div className="grid gap-4">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <KPI label="Active clients" value={clients.length} />
        <KPI label="Active projects" value={projects.filter((p) => p.status === "ongoing").length} />
        <KPI label="Revenue (paid)" value={`$${(totalRevenue / 1000).toFixed(0)}K`} />
        <KPI label="Overdue invoices" value={`$${(rows.reduce((s, r) => s + r.overdue, 0) / 1000).toFixed(0)}K`} />
      </div>
      <Section title="Client portfolio">
        <table className="w-full text-sm">
          <thead className="text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr><th className="py-2">Client</th><th>Projects</th><th>Active</th><th>Critical</th><th>Paid</th><th>Overdue</th></tr>
          </thead>
          <tbody className="divide-y divide-border">
            {rows.map((r) => (
              <tr key={r.c.id}>
                <td className="py-2.5">
                  <div className="font-medium">{r.c.name}</div>
                  <div className="text-xs text-muted-foreground">{r.c.industry}</div>
                </td>
                <td className="tabular-nums">{r.projs.length}</td>
                <td className="tabular-nums">{r.active}</td>
                <td className={cn("tabular-nums", r.reds > 0 && "text-destructive font-semibold")}>{r.reds}</td>
                <td className="tabular-nums">${(r.paid / 1000).toFixed(0)}K</td>
                <td className={cn("tabular-nums", r.overdue > 0 && "text-destructive")}>${(r.overdue / 1000).toFixed(0)}K</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>
    </div>
  );
}

function ResourceReport() {
  const utilByPerson = useMemo(() => {
    const map: Record<string, number> = {};
    projects.forEach((p) => [p.pmId, p.tlId, ...p.teamIds].forEach((id) => { map[id] = (map[id] ?? 0) + 1; }));
    return map;
  }, []);
  const benchSet = new Set(benchResourceIds);
  const allocated = people.filter((p) => (utilByPerson[p.id] ?? 0) > 0).length;
  const benched = benchSet.size;

  const byRole = ["Engineer", "Designer", "TL", "PM", "Engagement Manager", "Senior PM"].map((r) => ({
    role: r,
    total: people.filter((p) => p.role === r).length,
    allocated: people.filter((p) => p.role === r && (utilByPerson[p.id] ?? 0) > 0).length,
  }));

  return (
    <div className="grid gap-4">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <KPI label="Headcount" value={people.length} />
        <KPI label="Allocated" value={allocated} sub={`${Math.round((allocated / people.length) * 100)}% of dept`} />
        <KPI label="On bench" value={benched} />
        <KPI label="Avg projects / person" value={(Object.values(utilByPerson).reduce((s, n) => s + n, 0) / Math.max(allocated, 1)).toFixed(1)} />
      </div>
      <Section title="Allocation by role">
        <table className="w-full text-sm">
          <thead className="text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr><th className="py-2">Role</th><th>Allocated</th><th>Total</th><th>Utilization</th></tr>
          </thead>
          <tbody className="divide-y divide-border">
            {byRole.map((r) => (
              <tr key={r.role}>
                <td className="py-2.5 font-medium">{r.role}</td>
                <td className="tabular-nums">{r.allocated}</td>
                <td className="tabular-nums">{r.total}</td>
                <td className="w-48"><ProgressBar value={r.total ? (r.allocated / r.total) * 100 : 0} /></td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>
      <Section title="Bench">
        <ul className="grid gap-2 sm:grid-cols-2">
          {benchResourceIds.map((id) => {
            const p = getPerson(id);
            return (
              <li key={id} className="flex items-center justify-between rounded-lg border border-border bg-muted/30 px-3 py-2 text-sm">
                <span className="font-medium">{p.name}</span>
                <span className="text-xs text-muted-foreground">{p.role}</span>
              </li>
            );
          })}
        </ul>
      </Section>
    </div>
  );
}

function EscalationReport() {
  const open = issues.filter((i) => i.status === "open").length;
  const inProg = issues.filter((i) => i.status === "in_progress").length;
  const critical = issues.filter((i) => i.priority === "critical").length;
  const resolved = issues.filter((i) => i.status === "resolved" || i.status === "closed").length;

  return (
    <div className="grid gap-4">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <KPI label="Open" value={open} />
        <KPI label="In progress" value={inProg} />
        <KPI label="Critical" value={critical} />
        <KPI label="Resolved" value={resolved} />
      </div>
      <Section title="All escalations">
        <ul className="divide-y divide-border">
          {issues.map((i) => {
            const proj = projects.find((p) => p.id === i.projectId);
            const raiser = getPerson(i.raisedById);
            return (
              <li key={i.id} className="grid items-center gap-3 py-2.5 lg:grid-cols-[1.4fr,1fr,140px,140px,120px]">
                <div className="min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="text-xs font-medium text-muted-foreground">{issueTypeLabels[i.type]}</span>
                    <PriorityPill priority={i.priority} />
                  </div>
                  <p className="mt-1 line-clamp-2 text-sm">{i.description}</p>
                </div>
                <div className="text-xs">
                  <div className="font-medium">{proj?.name}</div>
                  <div className="text-muted-foreground">Raised by {raiser.name} · {i.raisedByRole}</div>
                </div>
                <IssueStatusPill status={i.status} />
                <span className="text-xs text-muted-foreground">→ {i.assignedToRole}</span>
                <span className="text-[11px] text-muted-foreground">{new Date(i.updatedAt).toLocaleDateString()}</span>
              </li>
            );
          })}
        </ul>
      </Section>
    </div>
  );
}

function HealthReport() {
  const green = projects.filter((p) => p.health === "green").length;
  const amber = projects.filter((p) => p.health === "amber").length;
  const red = projects.filter((p) => p.health === "red").length;

  return (
    <div className="grid gap-4">
      <div className="grid grid-cols-3 gap-3">
        <KPI label="Healthy" value={green} sub="Green" />
        <KPI label="At risk" value={amber} sub="Amber" />
        <KPI label="Critical" value={red} sub="Red" />
      </div>
      <Section title="Project health detail">
        <table className="w-full text-sm">
          <thead className="text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr><th className="py-2">Project</th><th>Client</th><th>Owner</th><th>Health</th><th>Progress</th><th>Spend</th></tr>
          </thead>
          <tbody className="divide-y divide-border">
            {projects.map((p) => {
              const pm = getPerson(p.pmId);
              const burn = p.budget ? Math.round((p.spent / p.budget) * 100) : 0;
              return (
                <tr key={p.id}>
                  <td className="py-2.5 font-medium">{p.name}</td>
                  <td className="text-xs">{clients.find((c) => c.id === p.clientId)?.name}</td>
                  <td className="text-xs">{pm.name}</td>
                  <td><HealthPill status={p.health} /></td>
                  <td className="w-40"><ProgressBar value={p.progress} /></td>
                  <td className={cn("text-xs tabular-nums", burn > 90 && "text-destructive font-semibold")}>{burn}%</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </Section>
    </div>
  );
}

function RevenueReport() {
  const byClient = clients.map((c) => {
    const projs = projects.filter((p) => p.clientId === c.id);
    const inv = invoices.filter((i) => projs.some((p) => p.id === i.projectId));
    const paid = inv.filter((i) => i.status === "paid").reduce((s, i) => s + i.invoiceAmount, 0);
    const raised = inv.filter((i) => i.status === "raised").reduce((s, i) => s + i.invoiceAmount, 0);
    const pending = inv.filter((i) => i.status === "pending").reduce((s, i) => s + i.invoiceAmount, 0);
    const overdue = inv.filter((i) => i.status === "overdue").reduce((s, i) => s + i.invoiceAmount, 0);
    return { c, paid, raised, pending, overdue, total: paid + raised + pending + overdue };
  });
  const totals = byClient.reduce((acc, r) => ({
    paid: acc.paid + r.paid, raised: acc.raised + r.raised,
    pending: acc.pending + r.pending, overdue: acc.overdue + r.overdue,
  }), { paid: 0, raised: 0, pending: 0, overdue: 0 });
  const fmt = (n: number) => `$${(n / 1000).toFixed(0)}K`;

  return (
    <div className="grid gap-4">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <KPI label="Revenue (paid)" value={fmt(totals.paid)} sub="Year-to-date" />
        <KPI label="In billing (raised)" value={fmt(totals.raised)} />
        <KPI label="Pending invoices" value={fmt(totals.pending)} />
        <KPI label="Overdue" value={fmt(totals.overdue)} sub="Collection risk" />
      </div>
      <Section title="Revenue by client">
        <table className="w-full text-sm">
          <thead className="text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr><th className="py-2">Client</th><th>Paid</th><th>Raised</th><th>Pending</th><th>Overdue</th><th>Total</th></tr>
          </thead>
          <tbody className="divide-y divide-border">
            {byClient.map((r) => (
              <tr key={r.c.id}>
                <td className="py-2.5 font-medium">{r.c.name}</td>
                <td className="tabular-nums text-success">{fmt(r.paid)}</td>
                <td className="tabular-nums">{fmt(r.raised)}</td>
                <td className="tabular-nums">{fmt(r.pending)}</td>
                <td className={cn("tabular-nums", r.overdue > 0 && "text-destructive font-semibold")}>{fmt(r.overdue)}</td>
                <td className="tabular-nums font-semibold">{fmt(r.total)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>
    </div>
  );
}

function ProfitabilityReport() {
  const rows = projects.map((p) => {
    const inv = invoices.filter((i) => i.projectId === p.id);
    const revenue = inv.filter((i) => i.status === "paid" || i.status === "raised").reduce((s, i) => s + i.invoiceAmount, 0);
    const margin = revenue - p.spent;
    const marginPct = revenue > 0 ? Math.round((margin / revenue) * 100) : 0;
    const burn = p.budget ? Math.round((p.spent / p.budget) * 100) : 0;
    return { p, revenue, margin, marginPct, burn };
  });
  const totalRev = rows.reduce((s, r) => s + r.revenue, 0);
  const totalSpend = projects.reduce((s, p) => s + p.spent, 0);
  const totalMargin = totalRev - totalSpend;
  const avgMarginPct = totalRev > 0 ? Math.round((totalMargin / totalRev) * 100) : 0;
  const fmt = (n: number) => `$${(n / 1000).toFixed(0)}K`;

  return (
    <div className="grid gap-4">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <KPI label="Total revenue" value={fmt(totalRev)} />
        <KPI label="Total spend" value={fmt(totalSpend)} />
        <KPI label="Gross margin" value={fmt(totalMargin)} sub={`${avgMarginPct}% portfolio margin`} />
        <KPI label="Projects in red burn" value={rows.filter((r) => r.burn > 90).length} sub=">90% budget consumed" />
      </div>
      <Section title="Project profitability">
        <table className="w-full text-sm">
          <thead className="text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr><th className="py-2">Project</th><th>Client</th><th>Revenue</th><th>Spend</th><th>Margin</th><th>Margin %</th><th>Burn</th></tr>
          </thead>
          <tbody className="divide-y divide-border">
            {rows.map((r) => (
              <tr key={r.p.id}>
                <td className="py-2.5 font-medium">{r.p.name}</td>
                <td className="text-xs">{clients.find((c) => c.id === r.p.clientId)?.name}</td>
                <td className="tabular-nums">{fmt(r.revenue)}</td>
                <td className="tabular-nums">{fmt(r.p.spent)}</td>
                <td className={cn("tabular-nums", r.margin < 0 && "text-destructive font-semibold")}>{fmt(r.margin)}</td>
                <td className={cn("tabular-nums", r.marginPct < 15 && "text-destructive", r.marginPct >= 30 && "text-success")}>{r.marginPct}%</td>
                <td className={cn("tabular-nums text-xs", r.burn > 90 && "text-destructive font-semibold")}>{r.burn}%</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Section>
    </div>
  );
}
