import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useMemo, useState } from "react";
import { BarChart3, TrendingUp, FileText, Receipt, Layers } from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { projects, clients, invoices } from "@/lib/mock-data";
import { ProgressBar } from "@/components/pills";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/dh-reports")({
  head: () => ({
    meta: [
      { title: "Reports — Pulse PMO" },
      { name: "description", content: "Sales, WBS, PO and invoice reports." },
    ],
  }),
  component: DhReportsPage,
});

const tabs = ["Sales Reports", "WBS Tracker", "PO Tracker", "Invoice Tracker"] as const;
type Tab = (typeof tabs)[number];
const tabIcons: Record<Tab, typeof BarChart3> = {
  "Sales Reports": TrendingUp,
  "WBS Tracker": Layers,
  "PO Tracker": FileText,
  "Invoice Tracker": Receipt,
};

function DhReportsPage() {
  const { isDhanshree } = useRoleContext();
  const [tab, setTab] = useState<Tab>("Sales Reports");

  if (!isDhanshree) return <Navigate to="/" />;

  return (
    <AppShell title="Reports" subtitle="Sales, delivery, finance and PO tracking">
      <div className="mb-4 flex gap-1 overflow-x-auto rounded-lg border border-border bg-card p-1 text-sm shadow-sm">
        {tabs.map((t) => {
          const Icon = tabIcons[t];
          return (
            <button key={t} onClick={() => setTab(t)}
              className={cn("inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-medium",
                tab === t ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground")}>
              <Icon className="h-3.5 w-3.5" /> {t}
            </button>
          );
        })}
      </div>

      {tab === "Sales Reports" && <SalesReports />}
      {tab === "WBS Tracker" && <WbsTracker />}
      {tab === "PO Tracker" && <POTracker />}
      {tab === "Invoice Tracker" && <InvoiceTracker />}
    </AppShell>
  );
}

function Kpi({ label, value, sub, tone = "default" }: { label: string; value: string | number; sub?: string; tone?: "default" | "success" | "warn" | "danger" }) {
  const toneCls = { default: "text-foreground", success: "text-success", warn: "text-warning-foreground", danger: "text-destructive" }[tone];
  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">{label}</div>
      <div className={cn("mt-2 text-2xl font-semibold tabular-nums", toneCls)}>{value}</div>
      {sub && <div className="mt-0.5 text-xs text-muted-foreground">{sub}</div>}
    </div>
  );
}

// ---------- Sales ----------
function SalesReports() {
  const totalRevenue = invoices.reduce((s, i) => s + i.invoiceAmount, 0);
  const paid = invoices.filter((i) => i.status === "paid").reduce((s, i) => s + i.invoiceAmount, 0);
  const pipeline = projects.filter((p) => p.status !== "completed").reduce((s, p) => s + p.budget, 0);

  const stages = [
    { name: "Qualified", count: 12, value: 2400000 },
    { name: "Proposal", count: 8, value: 1700000 },
    { name: "Negotiation", count: 5, value: 1200000 },
    { name: "Closed Won", count: 9, value: 2200000 },
  ];
  const maxStage = Math.max(...stages.map((s) => s.value));

  const byClient = clients.map((c) => {
    const cps = projects.filter((p) => p.clientId === c.id);
    const cinv = invoices.filter((i) => cps.some((p) => p.id === i.projectId));
    return { client: c, projects: cps.length, revenue: cinv.reduce((s, i) => s + i.invoiceAmount, 0) };
  });

  return (
    <>
      <div className="grid gap-3 sm:grid-cols-4">
        <Kpi label="Pipeline value" value={`₹${(pipeline / 1000000).toFixed(2)}M`} sub="Open opportunity value" />
        <Kpi label="Booked revenue" value={`₹${(totalRevenue / 1000000).toFixed(2)}M`} sub="Total invoiced" tone="success" />
        <Kpi label="Collected" value={`₹${(paid / 1000000).toFixed(2)}M`} tone="success" sub={`${Math.round((paid / totalRevenue) * 100)}% of invoiced`} />
        <Kpi label="Active clients" value={clients.length} sub="Across all industries" />
      </div>

      <div className="mt-4 grid gap-4 lg:grid-cols-2">
        <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <h3 className="mb-3 text-sm font-semibold">Sales pipeline</h3>
          <ul className="space-y-3">
            {stages.map((s) => (
              <li key={s.name}>
                <div className="mb-1 flex justify-between text-xs">
                  <span className="font-medium">{s.name}</span>
                  <span className="tabular-nums text-muted-foreground">{s.count} · ₹{(s.value / 1000000).toFixed(2)}M</span>
                </div>
                <div className="h-2 overflow-hidden rounded-full bg-muted">
                  <div className="h-full rounded-full bg-info" style={{ width: `${(s.value / maxStage) * 100}%` }} />
                </div>
              </li>
            ))}
          </ul>
        </section>

        <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <h3 className="mb-3 text-sm font-semibold">Revenue by client</h3>
          <table className="w-full text-sm">
            <thead className="text-left text-xs uppercase tracking-wide text-muted-foreground">
              <tr><th className="py-1.5 font-medium">Client</th><th className="py-1.5 font-medium">Projects</th><th className="py-1.5 text-right font-medium">Revenue</th></tr>
            </thead>
            <tbody className="divide-y divide-border">
              {byClient.map((r) => (
                <tr key={r.client.id}>
                  <td className="py-2 font-medium">{r.client.name}</td>
                  <td className="py-2 tabular-nums text-muted-foreground">{r.projects}</td>
                  <td className="py-2 text-right tabular-nums">₹{(r.revenue / 1000000).toFixed(2)}M</td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      </div>
    </>
  );
}

// ---------- WBS Tracker ----------
function WbsTracker() {
  const rows = useMemo(() => projects.map((p) => {
    const tasks = p.tasks.length;
    const done = p.tasks.filter((t) => t.status === "done").length;
    const milestone = p.wbs[Math.min(2, p.wbs.length - 1)];
    return { p, tasks, done, milestonePct: milestone?.progress ?? 0, delayed: p.health === "red" };
  }), []);

  return (
    <>
      <div className="grid gap-3 sm:grid-cols-4">
        <Kpi label="Total WBS items" value={rows.length} />
        <Kpi label="On track" value={rows.filter((r) => !r.delayed).length} tone="success" />
        <Kpi label="Delayed" value={rows.filter((r) => r.delayed).length} tone="danger" />
        <Kpi label="Avg completion" value={`${Math.round(rows.reduce((s, r) => s + r.p.progress, 0) / rows.length)}%`} />
      </div>

      <div className="mt-4 overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium">Project</th>
              <th className="px-3 py-2 font-medium">Client</th>
              <th className="px-3 py-2 font-medium">Tasks</th>
              <th className="px-3 py-2 font-medium">Milestone</th>
              <th className="px-3 py-2 font-medium">Completion</th>
              <th className="px-3 py-2 font-medium">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {rows.map((r) => {
              const c = clients.find((c) => c.id === r.p.clientId);
              return (
                <tr key={r.p.id} className="hover:bg-accent/30">
                  <td className="px-3 py-2.5 font-medium">{r.p.name}</td>
                  <td className="px-3 py-2.5 text-muted-foreground">{c?.name}</td>
                  <td className="px-3 py-2.5 tabular-nums">{r.done}/{r.tasks}</td>
                  <td className="px-3 py-2.5 tabular-nums">{r.milestonePct}%</td>
                  <td className="px-3 py-2.5">
                    <div className="flex items-center gap-2">
                      <ProgressBar value={r.p.progress} className="w-28" />
                      <span className="text-xs tabular-nums text-muted-foreground">{r.p.progress}%</span>
                    </div>
                  </td>
                  <td className="px-3 py-2.5">
                    {r.delayed ? (
                      <span className="inline-flex items-center rounded-full border border-destructive/30 bg-destructive/10 px-2 py-0.5 text-[11px] font-medium text-destructive">Delayed</span>
                    ) : (
                      <span className="inline-flex items-center rounded-full border border-success/30 bg-success/10 px-2 py-0.5 text-[11px] font-medium text-success">On track</span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ---------- PO Tracker ----------
function POTracker() {
  const poRows = projects.slice(0, 8).map((p, i) => {
    const c = clients.find((c) => c.id === p.clientId)!;
    const statuses = ["pending", "approved", "approved", "closed", "approved", "pending", "approved", "closed"] as const;
    const issue = new Date(p.startDate);
    const expiry = new Date(p.endDate);
    return {
      no: `PO-${2026000 + i + 1}`,
      client: c, project: p,
      amount: p.budget, status: statuses[i],
      issue: issue.toISOString().slice(0, 10),
      expiry: expiry.toISOString().slice(0, 10),
    };
  });
  const pillCls = (s: "pending" | "approved" | "closed") => ({
    pending: "border-warning/40 bg-warning/15 text-warning-foreground",
    approved: "border-info/30 bg-info/10 text-info",
    closed: "border-muted-foreground/30 bg-muted text-muted-foreground",
  }[s]);

  return (
    <>
      <div className="grid gap-3 sm:grid-cols-4">
        <Kpi label="Total POs" value={poRows.length} />
        <Kpi label="Pending" value={poRows.filter((r) => r.status === "pending").length} tone="warn" />
        <Kpi label="Approved" value={poRows.filter((r) => r.status === "approved").length} tone="success" />
        <Kpi label="Total value" value={`₹${(poRows.reduce((s, r) => s + r.amount, 0) / 1000000).toFixed(2)}M`} />
      </div>
      <div className="mt-4 overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium">PO Number</th>
              <th className="px-3 py-2 font-medium">Client</th>
              <th className="px-3 py-2 font-medium">Project</th>
              <th className="px-3 py-2 font-medium">Amount</th>
              <th className="px-3 py-2 font-medium">Status</th>
              <th className="px-3 py-2 font-medium">Issue Date</th>
              <th className="px-3 py-2 font-medium">Expiry Date</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {poRows.map((r) => (
              <tr key={r.no} className="hover:bg-accent/30">
                <td className="px-3 py-2.5 font-mono text-xs">{r.no}</td>
                <td className="px-3 py-2.5 font-medium">{r.client.name}</td>
                <td className="px-3 py-2.5 text-muted-foreground">{r.project.name}</td>
                <td className="px-3 py-2.5 tabular-nums">₹{(r.amount / 1000).toFixed(0)}k</td>
                <td className="px-3 py-2.5">
                  <span className={cn("inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium capitalize", pillCls(r.status))}>{r.status}</span>
                </td>
                <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">{r.issue}</td>
                <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">{r.expiry}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

// ---------- Invoice Tracker ----------
function InvoiceTracker() {
  const rows = invoices.map((inv, i) => {
    const p = projects.find((p) => p.id === inv.projectId)!;
    const c = clients.find((c) => c.id === p.clientId)!;
    const due = new Date(inv.raisedOn); due.setDate(due.getDate() + 30);
    const paidAmt = inv.status === "paid" ? inv.invoiceAmount : inv.status === "pending" ? Math.round(inv.invoiceAmount * 0.3) : 0;
    const due30 = due.toISOString().slice(0, 10);
    const isPartial = paidAmt > 0 && paidAmt < inv.invoiceAmount;
    const status: "paid" | "partial" | "pending" | "overdue" =
      inv.status === "paid" ? "paid" : inv.status === "overdue" ? "overdue" : isPartial ? "partial" : "pending";
    return { no: `INV-${4000 + i + 1}`, client: c, project: p, amount: inv.invoiceAmount, paid: paidAmt, due: inv.invoiceAmount - paidAmt, dueDate: due30, status };
  });

  const pillCls = (s: "paid" | "partial" | "pending" | "overdue") => ({
    paid: "border-success/30 bg-success/10 text-success",
    partial: "border-info/30 bg-info/10 text-info",
    pending: "border-warning/40 bg-warning/15 text-warning-foreground",
    overdue: "border-destructive/30 bg-destructive/10 text-destructive",
  }[s]);

  return (
    <>
      <div className="grid gap-3 sm:grid-cols-4">
        <Kpi label="Total invoices" value={rows.length} />
        <Kpi label="Paid" value={rows.filter((r) => r.status === "paid").length} tone="success" />
        <Kpi label="Overdue" value={rows.filter((r) => r.status === "overdue").length} tone="danger" />
        <Kpi label="Outstanding" value={`₹${(rows.reduce((s, r) => s + r.due, 0) / 1000000).toFixed(2)}M`} tone="warn" />
      </div>
      <div className="mt-4 overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
        <table className="w-full text-sm">
          <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
            <tr>
              <th className="px-3 py-2 font-medium">Invoice</th>
              <th className="px-3 py-2 font-medium">Client</th>
              <th className="px-3 py-2 font-medium">Project</th>
              <th className="px-3 py-2 font-medium">Amount</th>
              <th className="px-3 py-2 font-medium">Paid</th>
              <th className="px-3 py-2 font-medium">Due</th>
              <th className="px-3 py-2 font-medium">Due Date</th>
              <th className="px-3 py-2 font-medium">Status</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {rows.map((r) => (
              <tr key={r.no} className="hover:bg-accent/30">
                <td className="px-3 py-2.5 font-mono text-xs">{r.no}</td>
                <td className="px-3 py-2.5 font-medium">{r.client.name}</td>
                <td className="px-3 py-2.5 text-muted-foreground">{r.project.name}</td>
                <td className="px-3 py-2.5 tabular-nums">₹{(r.amount / 1000).toFixed(0)}k</td>
                <td className="px-3 py-2.5 tabular-nums text-success">₹{(r.paid / 1000).toFixed(0)}k</td>
                <td className="px-3 py-2.5 tabular-nums text-destructive">₹{(r.due / 1000).toFixed(0)}k</td>
                <td className="px-3 py-2.5 text-xs tabular-nums text-muted-foreground">{r.dueDate}</td>
                <td className="px-3 py-2.5">
                  <span className={cn("inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium capitalize", pillCls(r.status))}>{r.status}</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
