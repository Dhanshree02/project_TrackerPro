import { createFileRoute, Link } from "@tanstack/react-router";
import {
  Briefcase,
  AlertTriangle,
  CheckCircle2,
  Users,
  TrendingUp,
  Clock,
  ArrowRight,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext, roleLabels } from "@/lib/role-context";
import { HealthPill, StatusPill, ProgressBar, PriorityPill, IssueStatusPill } from "@/components/pills";
import { getPerson, projectStatusLabels, issueTypeLabels, invoices, benchResourceIds, pmBuckets } from "@/lib/mock-data";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Dashboard — Pulse PMO" },
      { name: "description", content: "Track assigned projects, health, and pending approvals at a glance." },
    ],
  }),
  component: Dashboard,
});

function Stat({ label, value, sub, icon: Icon, tone = "default" }: {
  label: string; value: string | number; sub?: string;
  icon: React.ComponentType<{ className?: string }>;
  tone?: "default" | "success" | "warn" | "danger" | "info";
}) {
  const toneCls = {
    default: "bg-accent/40 text-accent-foreground",
    success: "bg-success/10 text-success",
    warn: "bg-warning/15 text-warning-foreground",
    danger: "bg-destructive/10 text-destructive",
    info: "bg-info/10 text-info",
  }[tone];
  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="flex items-center justify-between">
        <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">{label}</span>
        <span className={`flex h-8 w-8 items-center justify-center rounded-lg ${toneCls}`}>
          <Icon className="h-4 w-4" />
        </span>
      </div>
      <div className="mt-3 text-2xl font-semibold tabular-nums">{value}</div>
      {sub && <div className="mt-1 text-xs text-muted-foreground">{sub}</div>}
    </div>
  );
}

function Dashboard() {
  const { user, role, isPMO, isBO, assignedProjects, assignedIssues, pendingTimesheets } = useRoleContext();
  const showExec = isPMO || isBO;

  const ongoing = assignedProjects.filter((p) => p.status === "ongoing").length;
  const completed = assignedProjects.filter((p) => p.status === "completed").length;
  const onHold = assignedProjects.filter((p) => p.status === "on_hold").length;
  const red = assignedProjects.filter((p) => p.health === "red").length;
  const amber = assignedProjects.filter((p) => p.health === "amber").length;
  const green = assignedProjects.filter((p) => p.health === "green").length;
  const openIssues = assignedIssues.filter((i) => i.status === "open").length;

  const teamSet = new Set<string>();
  assignedProjects.forEach((p) => {
    teamSet.add(p.pmId); teamSet.add(p.tlId); p.teamIds.forEach((id) => teamSet.add(id));
  });

  const recentIssues = [...assignedIssues]
    .sort((a, b) => b.updatedAt.localeCompare(a.updatedAt))
    .slice(0, 4);

  const projectIds = new Set(assignedProjects.map((p) => p.id));
  const visibleInvoices = invoices.filter((i) => projectIds.has(i.projectId));
  const invRaised = visibleInvoices.filter((i) => i.status === "raised").length;
  const invPaid = visibleInvoices.filter((i) => i.status === "paid").length;
  const invOverdue = visibleInvoices.filter((i) => i.status === "overdue").length;

  return (
    <AppShell
      title={`Welcome back, ${user.name.split(" ")[0]}`}
      subtitle={`${roleLabels[role]} · ${assignedProjects.length} projects across ${new Set(assignedProjects.map((p) => p.clientId)).size} clients${isBO ? " · executive overview" : isPMO ? " · governance + allocation view" : ""}`}
    >
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Stat label="Ongoing" value={ongoing} sub={`${completed} completed · ${onHold} on hold`} icon={Briefcase} tone="info" />
        <Stat label="At Risk + Critical" value={red + amber} sub={`${red} critical · ${amber} at risk · ${green} healthy`} icon={AlertTriangle} tone={red > 0 ? "danger" : "warn"} />
        <Stat label={isBO ? "Open escalations" : showExec ? "Pending approvals (all)" : "Pending Approvals"} value={isBO ? openIssues : pendingTimesheets.length} sub={isBO ? "Strategic issues to review" : isPMO ? "PM/TL/Employee timesheets in flow" : "PM timesheets awaiting review"} icon={CheckCircle2} tone="warn" />
        <Stat label={showExec ? "Invoices · raised" : "People on Projects"} value={showExec ? invRaised : teamSet.size} sub={showExec ? `${invPaid} paid · ${invOverdue} overdue` : "Across PM, TL and engineers"} icon={showExec ? CheckCircle2 : Users} tone={showExec && invOverdue > 0 ? "danger" : "default"} />
      </div>

      {showExec && (
        <div className="mt-4 grid gap-3 lg:grid-cols-3">
          <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold">PM buckets</h2>
              <Users className="h-4 w-4 text-muted-foreground" />
            </div>
            <ul className="mt-3 space-y-2">
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
          </section>
          <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold">On-bench resources</h2>
              <Users className="h-4 w-4 text-muted-foreground" />
            </div>
            <div className="mt-2 text-2xl font-semibold tabular-nums">{benchResourceIds.length}</div>
            <p className="text-xs text-muted-foreground">Available for allocation</p>
            <Link to="/resources" className="mt-2 inline-flex items-center gap-1 text-xs font-medium text-primary hover:underline">
              View directory <ArrowRight className="h-3 w-3" />
            </Link>
          </section>
          <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
            <div className="flex items-center justify-between">
              <h2 className="text-sm font-semibold">Invoice status</h2>
              <CheckCircle2 className="h-4 w-4 text-muted-foreground" />
            </div>
            <ul className="mt-2 space-y-1.5 text-xs">
              <li className="flex justify-between"><span>Raised</span><span className="font-semibold tabular-nums">{invRaised}</span></li>
              <li className="flex justify-between"><span>Paid</span><span className="font-semibold text-success tabular-nums">{invPaid}</span></li>
              <li className="flex justify-between"><span>Overdue</span><span className="font-semibold text-destructive tabular-nums">{invOverdue}</span></li>
              <li className="flex justify-between"><span>Pending</span><span className="font-semibold tabular-nums">{visibleInvoices.filter((i) => i.status === "pending").length}</span></li>
            </ul>
          </section>
        </div>
      )}

      <div className="mt-6 grid gap-6 lg:grid-cols-3">
        <section className="lg:col-span-2 rounded-xl border border-border bg-card shadow-sm">
          <header className="flex items-center justify-between border-b border-border px-4 py-3">
            <div>
              <h2 className="text-sm font-semibold">Assigned projects</h2>
              <p className="text-xs text-muted-foreground">Health, status and progress</p>
            </div>
            <Link to="/clients" className="inline-flex items-center gap-1 text-xs font-medium text-primary hover:underline">
              View all <ArrowRight className="h-3 w-3" />
            </Link>
          </header>
          <ul className="divide-y divide-border">
            {assignedProjects.slice(0, 6).map((p) => {
              const pm = getPerson(p.pmId);
              return (
                <li key={p.id}>
                  <Link
                    to="/projects/$projectId"
                    params={{ projectId: p.id }}
                    className="flex items-center gap-4 px-4 py-3 hover:bg-accent/40"
                  >
                    <div className="min-w-0 flex-1">
                      <div className="flex flex-wrap items-center gap-2">
                        <span className="truncate text-sm font-medium">{p.name}</span>
                        <HealthPill status={p.health} />
                        <StatusPill status={p.status} />
                      </div>
                      <div className="mt-1 text-xs text-muted-foreground">
                        PM · {pm.name} · ends {new Date(p.endDate).toLocaleDateString()}
                      </div>
                      <div className="mt-2 flex items-center gap-3">
                        <ProgressBar value={p.progress} className="max-w-[260px]" />
                        <span className="text-xs tabular-nums text-muted-foreground">{p.progress}%</span>
                      </div>
                    </div>
                    <ArrowRight className="hidden h-4 w-4 text-muted-foreground sm:block" />
                  </Link>
                </li>
              );
            })}
          </ul>
        </section>

        <section className="rounded-xl border border-border bg-card shadow-sm">
          <header className="flex items-center justify-between border-b border-border px-4 py-3">
            <div>
              <h2 className="text-sm font-semibold">Pending issues</h2>
              <p className="text-xs text-muted-foreground">Latest activity</p>
            </div>
            <Link to="/health" className="inline-flex items-center gap-1 text-xs font-medium text-primary hover:underline">
              Open <ArrowRight className="h-3 w-3" />
            </Link>
          </header>
          <ul className="divide-y divide-border">
            {recentIssues.map((i) => (
              <li key={i.id} className="px-4 py-3">
                <div className="flex items-center justify-between gap-2">
                  <span className="text-xs font-medium text-muted-foreground">{issueTypeLabels[i.type]}</span>
                  <PriorityPill priority={i.priority} />
                </div>
                <p className="mt-1 line-clamp-2 text-sm">{i.description}</p>
                <div className="mt-2 flex items-center justify-between">
                  <IssueStatusPill status={i.status} />
                  <span className="text-[11px] text-muted-foreground">{new Date(i.updatedAt).toLocaleDateString()}</span>
                </div>
              </li>
            ))}
            {recentIssues.length === 0 && (
              <li className="px-4 py-8 text-center text-sm text-muted-foreground">No issues raised</li>
            )}
          </ul>
        </section>
      </div>

      <div className="mt-6 grid gap-6 lg:grid-cols-2">
        <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold">Project status mix</h2>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </div>
          <div className="mt-4 space-y-3">
            {[
              { k: "ongoing", n: ongoing, cls: "bg-info" },
              { k: "completed", n: completed, cls: "bg-success" },
              { k: "on_hold", n: onHold, cls: "bg-muted-foreground/40" },
            ].map((row) => {
              const pct = assignedProjects.length ? (row.n / assignedProjects.length) * 100 : 0;
              return (
                <div key={row.k}>
                  <div className="mb-1 flex justify-between text-xs">
                    <span>{projectStatusLabels[row.k as keyof typeof projectStatusLabels]}</span>
                    <span className="tabular-nums text-muted-foreground">{row.n}</span>
                  </div>
                  <div className="h-2 overflow-hidden rounded-full bg-muted">
                    <div className={`h-full ${row.cls}`} style={{ width: `${pct}%` }} />
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold">Pending approvals</h2>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </div>
          <ul className="mt-3 divide-y divide-border">
            {pendingTimesheets.map((ts) => {
              const u = getPerson(ts.userId);
              return (
                <li key={ts.id} className="flex items-center justify-between py-2">
                  <div>
                    <div className="text-sm font-medium">{u.name}</div>
                    <div className="text-xs text-muted-foreground">Week of {ts.weekStart} · {ts.totalHours}h</div>
                  </div>
                  <Link
                    to="/approvals"
                    className="rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent"
                  >
                    Review
                  </Link>
                </li>
              );
            })}
            {pendingTimesheets.length === 0 && (
              <li className="py-6 text-center text-sm text-muted-foreground">All caught up</li>
            )}
          </ul>
        </section>
      </div>
    </AppShell>
  );
}
