import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { Bar, BarChart, CartesianGrid, XAxis, YAxis } from "recharts";
import {
  ChartContainer,
  ChartLegend,
  ChartLegendContent,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from "@/components/ui/chart";
import {
  currentDashboardQuarter,
  fetchTeamSummary,
  type DashboardQuarter,
  type TeamSummary,
} from "@/lib/api/dashboard";
import { OnsiteUtilizationSection } from "@/components/dashboard/onsite-utilization-section";
import { RoleAllocationSection } from "@/components/dashboard/role-allocation-section";

const QUARTERS: DashboardQuarter[] = ["Q1", "Q2", "Q3", "Q4"];

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
  const [quarter, setQuarter] = useState<DashboardQuarter>(currentDashboardQuarter);
  const [summary, setSummary] = useState<TeamSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const scrollLock = useRef<number | null>(null);

  const changeQuarter = (next: DashboardQuarter) => {
    if (next === quarter) return;
    scrollLock.current = window.scrollY;
    setQuarter(next);
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

    fetchTeamSummary(quarter, controller.signal)
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
  }, [quarter, reloadKey]);

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
        <div className="flex items-center gap-2">
          <label htmlFor="mis-quarter" className="text-xs font-medium text-muted-foreground">
            Quarter
          </label>
          <select
            id="mis-quarter"
            value={quarter}
            onChange={(event) => changeQuarter(event.target.value as DashboardQuarter)}
            className="h-9 w-24 rounded-md border border-input bg-card px-2 text-xs shadow-sm"
          >
            {QUARTERS.map((item) => (
              <option key={item} value={item}>
                {item}
              </option>
            ))}
          </select>
        </div>
      </div>

      {loading && !summary && (
        <div className="rounded-xl border border-border bg-card px-4 py-10 text-center text-sm text-muted-foreground shadow-sm">
          Loading {quarter}…
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
              Loading {quarter}…
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
            <h3 className="text-sm font-semibold">Total Team Size</h3>
            <p className="text-xs text-muted-foreground">Onsite and offsite at each month end</p>
            <div className="mt-4 overflow-x-auto">
              <table className="w-full min-w-[280px] text-sm">
                <thead>
                  <tr className="border-b border-border text-xs text-muted-foreground">
                    <th className="py-2 pr-3 text-left font-medium">Teams</th>
                    {months.map((month) => (
                      <th key={month.month} className="px-2 py-2 text-right font-medium">
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  <tr className="border-b border-border">
                    <td className="py-2 pr-3">Total Team Size</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        {month.totalTeamSize}
                      </td>
                    ))}
                  </tr>
                  <tr className="border-b border-border">
                    <td className="py-2 pr-3">Onsite Team</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        <div>{month.onsiteTeam}</div>
                        <div className="text-xs text-muted-foreground">{month.onsitePercentage}%</div>
                      </td>
                    ))}
                  </tr>
                  <tr>
                    <td className="py-2 pr-3">Offsite Team</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        <div>{month.offsiteTeam}</div>
                        <div className="text-xs text-muted-foreground">{month.offsitePercentage}%</div>
                      </td>
                    ))}
                  </tr>
                </tbody>
              </table>
            </div>
            <ChartContainer config={teamChartConfig} className="mt-4 aspect-auto h-[260px] w-full">
              <BarChart data={months} margin={{ left: 0, right: 8, top: 8 }}>
                <CartesianGrid vertical={false} />
                <XAxis dataKey="month" tickLine={false} axisLine={false} />
                <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={32} />
                <ChartTooltip content={<ChartTooltipContent />} />
                <ChartLegend content={<ChartLegendContent />} />
                <Bar dataKey="totalTeamSize" fill="var(--color-totalTeamSize)" radius={4} />
                <Bar dataKey="onsiteTeam" fill="var(--color-onsiteTeam)" radius={4} />
                <Bar dataKey="offsiteTeam" fill="var(--color-offsiteTeam)" radius={4} />
              </BarChart>
            </ChartContainer>
          </article>

          <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
            <h3 className="text-sm font-semibold">Resource Boarding Details</h3>
            <p className="text-xs text-muted-foreground">Joins and last working days in each month</p>
            <div className="mt-4 overflow-x-auto">
              <table className="w-full min-w-[280px] text-sm">
                <thead>
                  <tr className="border-b border-border text-xs text-muted-foreground">
                    <th className="py-2 pr-3 text-left font-medium">Resource Boarding Details</th>
                    {months.map((month) => (
                      <th key={month.month} className="px-2 py-2 text-right font-medium">
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  <tr className="border-b border-border">
                    <td className="py-2 pr-3">On-boarding</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        {month.onboarding}
                      </td>
                    ))}
                  </tr>
                  <tr>
                    <td className="py-2 pr-3">Off-boarding</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        {month.offboarding}
                      </td>
                    ))}
                  </tr>
                </tbody>
              </table>
            </div>
            <ChartContainer config={boardingChartConfig} className="mt-4 aspect-auto h-[260px] w-full">
              <BarChart data={months} margin={{ left: 0, right: 8, top: 8 }}>
                <CartesianGrid vertical={false} />
                <XAxis dataKey="month" tickLine={false} axisLine={false} />
                <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={32} />
                <ChartTooltip content={<ChartTooltipContent />} />
                <ChartLegend content={<ChartLegendContent />} />
                <Bar dataKey="onboarding" fill="var(--color-onboarding)" radius={4} />
                <Bar dataKey="offboarding" fill="var(--color-offboarding)" radius={4} />
              </BarChart>
            </ChartContainer>
          </article>
        </div>
        </div>
      )}

      <OnsiteUtilizationSection quarter={quarter} />
      <RoleAllocationSection quarter={quarter} />
    </section>
  );
}
