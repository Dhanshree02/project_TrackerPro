import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { Bar, BarChart, CartesianGrid, LabelList, XAxis, YAxis } from "recharts";
import {
  ChartContainer,
  ChartLegend,
  ChartLegendContent,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from "@/components/ui/chart";
import {
  dashboardPeriodLabel,
  fetchTeamSummary,
  type DashboardPeriod,
  type MisDashboardView,
  type TeamSummary,
} from "@/lib/api/dashboard";
import { OffsiteTeamUtilizationSection } from "@/components/dashboard/offsite-team-utilization-section";
import { OnsiteProjectCountSection } from "@/components/dashboard/onsite-project-count-section";
import { OnsiteUtilizationSection } from "@/components/dashboard/onsite-utilization-section";
import { ResignationCountSection } from "@/components/dashboard/resignation-count-section";
import { OffsiteCapacitySection } from "@/components/dashboard/offsite-capacity-section";
import { ChartDismiss, columnBarChart, GraphZoom, useGraphZoomMotion, xAxisLabel, yAxisLabel } from "@/components/dashboard/graph-frame";
import {
  misRow,
  misTable,
  misTableScroll,
  misTdLabel,
  misTdNote,
  misTdNumber,
  misThLabel,
  misThNumber,
  misHeadRow,
} from "@/components/dashboard/dashboard-table";
import { RoleAllocationSection } from "@/components/dashboard/role-allocation-section";

const PERIODS: { id: DashboardPeriod; label: string }[] = [
  { id: "rolling", label: "Last 3 Months" },
  { id: "Q1", label: "Q1" },
  { id: "Q2", label: "Q2" },
  { id: "Q3", label: "Q3" },
  { id: "Q4", label: "Q4" },
];

const VIEWS: { id: MisDashboardView; label: string }[] = [
  { id: "graph", label: "Graph View" },
  { id: "list", label: "List View" },
  { id: "both", label: "Graph and List" },
];

const teamChartConfig = {
  totalTeamSize: { label: "Total Team Size", color: "var(--chart-1)" },
  onsiteTeam: { label: "Onsite Team", color: "var(--chart-2)" },
  offsiteTeam: { label: "Offsite Team", color: "var(--chart-4)" },
} satisfies ChartConfig;

const boardingChartConfig = {
  onboarding: { label: "On-boarding", color: "var(--chart-1)" },
  offboarding: { label: "Off-boarding", color: "var(--chart-5)" },
} satisfies ChartConfig;

export function TeamMisSection() {
  const [period, setPeriod] = useState<DashboardPeriod>("rolling");
  const [view, setView] = useState<MisDashboardView>("graph");
  const [summary, setSummary] = useState<TeamSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const scrollLock = useRef<number | null>(null);

  const changePeriod = (next: DashboardPeriod) => {
    if (next === period) return;
    scrollLock.current = window.scrollY;
    setSummary(null);
    setPeriod(next);
  };

  useLayoutEffect(() => {
    if (scrollLock.current === null) return;
    const top = scrollLock.current;
    window.scrollTo(window.scrollX, top);
    if (!loading) scrollLock.current = null;
  });

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);

    fetchTeamSummary(period, controller.signal)
      .then((data) => {
        if (!controller.signal.aborted) setSummary(data);
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted) return;
        const message = err instanceof Error ? err.message : "Could not load the dashboard.";
        setError(message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
  }, [period, reloadKey]);

  const months = summary?.months ?? [];
  const fyLabel = summary
    ? `FY ${summary.financialYear}–${String(summary.financialYear + 1).slice(-2)}`
    : null;

  return (
    <section className="mt-6 space-y-4">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 className="text-sm font-semibold">MIS</h2>
          <p className="text-xs text-muted-foreground">
            Team size and resource boarding
            {fyLabel ? ` · ${fyLabel}` : ""}
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <div className="inline-flex rounded-lg border border-border bg-muted/40 p-0.5 text-xs" role="group" aria-label="Dashboard view">
            {VIEWS.map((item) => (
              <button
                key={item.id}
                type="button"
                aria-pressed={view === item.id}
                onClick={() => setView(item.id)}
                className={
                  view === item.id
                    ? "rounded-md bg-card px-3 py-1.5 font-medium text-foreground shadow-sm"
                    : "rounded-md px-3 py-1.5 font-medium text-muted-foreground hover:text-foreground"
                }
              >
                {item.label}
              </button>
            ))}
          </div>
          <label htmlFor="mis-quarter" className="text-xs font-medium text-muted-foreground">
            Period
          </label>
          <select
            id="mis-quarter"
            value={period}
            onChange={(event) => changePeriod(event.target.value as DashboardPeriod)}
            className="h-9 w-36 rounded-md border border-input bg-card px-2 text-xs shadow-sm"
          >
            {PERIODS.map((item) => (
              <option key={item.id} value={item.id}>
                {item.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      {loading && !summary && (
        <div className="rounded-xl border border-border bg-card px-4 py-10 text-center text-sm text-muted-foreground shadow-sm">
          Loading {dashboardPeriodLabel(period)}…
        </div>
      )}

      {!loading && error && !summary && (
        <div className="rounded-xl border border-destructive/30 bg-card px-4 py-8 text-center shadow-sm">
          <p className="text-sm text-destructive">{error}</p>
          <button
            type="button"
            onClick={() => setReloadKey((key) => key + 1)}
            className="mt-3 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent"
          >
            Retry
          </button>
        </div>
      )}

      {summary && (
        <div className="relative">
          {loading && (
            <div className="absolute inset-0 z-10 flex items-center justify-center rounded-xl bg-background/70 text-sm text-muted-foreground">
              Loading {dashboardPeriodLabel(period)}…
            </div>
          )}
          {error && (
            <div className="absolute inset-0 z-10 flex flex-col items-center justify-center rounded-xl bg-background/80">
              <p className="text-sm text-destructive">{error}</p>
              <button
                type="button"
                onClick={() => setReloadKey((key) => key + 1)}
                className="mt-3 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium hover:bg-accent"
              >
                Retry
              </button>
            </div>
          )}
        <div className={`grid gap-6 lg:grid-cols-2 ${loading || error ? "invisible" : ""}`}>
          <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
            <div className="flex items-start justify-between gap-3">
              <div>
                <h3 className="text-sm font-semibold">Total Team Size</h3>
                <p className="text-xs text-muted-foreground">Onsite and offsite at each month end</p>
              </div>
              {view !== "list" && <GraphZoom title="Total Team Size" render={() => <TotalTeamChart months={months} />} />}
            </div>
            {view !== "graph" && (
            <div className={`mt-4 ${misTableScroll}`}>
              <table className={`${misTable} min-w-[280px]`}>
                <thead>
                  <tr className={misHeadRow}>
                    <th className={misThLabel}>Teams</th>
                    {months.map((month) => (
                      <th key={month.month} className={misThNumber}>
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Total Team Size</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.totalTeamSize}
                      </td>
                    ))}
                  </tr>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Onsite Team</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        <div>{month.onsiteTeam}</div>
                        <div className={misTdNote}>{month.onsitePercentage}%</div>
                      </td>
                    ))}
                  </tr>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Offsite Team</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        <div>{month.offsiteTeam}</div>
                        <div className={misTdNote}>{month.offsitePercentage}%</div>
                      </td>
                    ))}
                  </tr>
                </tbody>
              </table>
            </div>
            )}
            {view !== "list" && <TotalTeamChart months={months} />}
          </article>

          <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
            <div className="flex items-start justify-between gap-3">
              <div>
                <h3 className="text-sm font-semibold">Resource Boarding Details</h3>
                <p className="text-xs text-muted-foreground">Joins and last working days in each month</p>
              </div>
              {view !== "list" && <GraphZoom title="Resource Boarding Details" render={() => <BoardingChart months={months} />} />}
            </div>
            {view !== "graph" && (
            <div className={`mt-4 ${misTableScroll}`}>
              <table className={`${misTable} min-w-[280px]`}>
                <thead>
                  <tr className={misHeadRow}>
                    <th className={misThLabel}>Resource Boarding Details</th>
                    {months.map((month) => (
                      <th key={month.month} className={misThNumber}>
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  <tr className={misRow}>
                    <td className={misTdLabel}>On-boarding</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.onboarding}
                      </td>
                    ))}
                  </tr>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Off-boarding</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.offboarding}
                      </td>
                    ))}
                  </tr>
                </tbody>
              </table>
            </div>
            )}
            {view !== "list" && <BoardingChart months={months} />}
          </article>
        </div>
        </div>
      )}

      <OnsiteUtilizationSection period={period} view={view} />
      <OffsiteTeamUtilizationSection period={period} view={view} />
      <OnsiteProjectCountSection period={period} view={view} />
      <RoleAllocationSection period={period} view={view} />
      <ResignationCountSection period={period} view={view} />
      <OffsiteCapacitySection period={period} view={view} />
    </section>
  );
}

function TotalTeamChart({ months }: { months: TeamSummary["months"] }) {
  const zoom = useGraphZoomMotion();
  return (
    <ChartDismiss>
      <ChartContainer config={teamChartConfig} className="mt-4 aspect-auto h-[260px] w-full">
        <BarChart data={months} margin={{ left: 8, right: 8, top: 16, bottom: 24 }} {...columnBarChart}>
          <CartesianGrid vertical={false} />
          <XAxis dataKey="month" tickLine={false} axisLine={false} tick={{ fontSize: 12 }} label={xAxisLabel("Month")} />
          <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={48} tick={{ fontSize: 12 }} label={yAxisLabel("Team size")} />
          <ChartTooltip trigger="click" cursor={false} content={<ChartTooltipContent />} />
          <ChartLegend content={<ChartLegendContent />} />
          <Bar isAnimationActive={!zoom} animationDuration={800} minPointSize={6} dataKey="totalTeamSize" fill="var(--color-totalTeamSize)" radius={4} />
          <Bar isAnimationActive={!zoom} animationDuration={800} minPointSize={6} dataKey="onsiteTeam" fill="var(--color-onsiteTeam)" radius={4}>
            <LabelList dataKey="onsiteTeam" position="top" className="fill-foreground" fontSize={11} />
          </Bar>
          <Bar isAnimationActive={!zoom} animationDuration={800} minPointSize={6} dataKey="offsiteTeam" fill="var(--color-offsiteTeam)" radius={4} />
        </BarChart>
      </ChartContainer>
    </ChartDismiss>
  );
}

function BoardingChart({ months }: { months: TeamSummary["months"] }) {
  const zoom = useGraphZoomMotion();
  return (
    <ChartDismiss>
      <ChartContainer config={boardingChartConfig} className="mt-4 aspect-auto h-[260px] w-full">
        <BarChart data={months} margin={{ left: 8, right: 8, top: 12, bottom: 24 }} {...columnBarChart}>
          <CartesianGrid vertical={false} />
          <XAxis dataKey="month" tickLine={false} axisLine={false} tick={{ fontSize: 12 }} label={xAxisLabel("Month")} />
          <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={48} tick={{ fontSize: 12 }} label={yAxisLabel("Count")} />
          <ChartTooltip trigger="click" cursor={false} content={<ChartTooltipContent />} />
          <ChartLegend content={<ChartLegendContent />} />
          <Bar isAnimationActive={!zoom} animationDuration={800} minPointSize={6} dataKey="onboarding" fill="var(--color-onboarding)" radius={4} />
          <Bar isAnimationActive={!zoom} animationDuration={800} minPointSize={6} dataKey="offboarding" fill="var(--color-offboarding)" radius={4} />
        </BarChart>
      </ChartContainer>
    </ChartDismiss>
  );
}
