import { useEffect, useState } from "react";
import { Bar, BarChart, CartesianGrid, XAxis, YAxis } from "recharts";
import {
  ChartContainer,
  type ChartConfig,
} from "@/components/ui/chart";
import {
  fetchOnsiteUtilization,
  dashboardPeriodLabel,
  type DashboardPeriod,
  type MisDashboardView,
  type OnsiteUtilization,
} from "@/lib/api/dashboard";
import { ColumnBarHoverScope, columnBarProps, useColumnBarHover } from "@/components/dashboard/bar-emphasis";
import {
  ConfigToggleLegend,
  LEGEND_BAR_GROW_MS,
  useLegendSeriesToggle,
} from "@/components/dashboard/toggle-chart-legend";
import {
  ChartDismiss,
  columnBarChart,
  DashboardChartBody,
  chartSeriesLabel,
  GraphZoom,
  xAxisLabel,
  yAxisLabel,
} from "@/components/dashboard/graph-frame";
import {
  misHeadRow,
  misRow,
  misTable,
  misTableScroll,
  misTdLabel,
  misTdNote,
  misTdNumber,
  misThLabel,
  misThNumber,
} from "@/components/dashboard/dashboard-table";

const chartConfig = {
  totalOnsiteTeam: { label: "Total Onsite Team", color: "var(--chart-1)" },
  billable: { label: "Onsite Billable", color: "var(--chart-2)" },
  nonBillable: { label: "Onsite Non-billable", color: "var(--chart-4)" },
} satisfies ChartConfig;

export function OnsiteUtilizationSection({
  period,
  view,
}: {
  period: DashboardPeriod;
  view: MisDashboardView;
}) {
  const [data, setData] = useState<OnsiteUtilization | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);

    fetchOnsiteUtilization(period, controller.signal)
      .then((result) => {
        if (!controller.signal.aborted) setData(result);
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted) return;
        const message = err instanceof Error ? err.message : "Could not load onsite utilization.";
        setError(message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
  }, [period, reloadKey]);

  const months = data?.months ?? [];

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-sm font-semibold">Team Utilization - Onsite ({dashboardPeriodLabel(period)})</h3>
          <p className="text-xs text-muted-foreground">Onsite employees by billable status</p>
        </div>
        {!loading && !error && data && view !== "list" && (
          <GraphZoom title={`Team Utilization - Onsite (${dashboardPeriodLabel(period)})`} render={() => <OnsiteChart months={months} />} />
        )}
      </div>

      {loading && (
        <div className="mt-4 rounded-lg border border-border px-4 py-10 text-center text-sm text-muted-foreground">
          Loading {dashboardPeriodLabel(period)}…
        </div>
      )}

      {!loading && error && (
        <div className="mt-4 rounded-lg border border-destructive/30 px-4 py-8 text-center">
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

      {!loading && !error && data && (
        <div className={`mt-4 grid gap-6 ${view === "both" ? "lg:grid-cols-2" : ""}`}>
          {view !== "graph" && (
          <div className={misTableScroll}>
            <table className={`${misTable} min-w-[280px]`}>
              <thead>
                <tr className={misHeadRow}>
                  <th className={misThLabel}>Project Type</th>
                  {months.map((month) => (
                    <th key={month.month} className={misThNumber}>
                      {month.month}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                <tr className={misRow}>
                  <td className={misTdLabel}>Total Onsite Team</td>
                  {months.map((month) => (
                    <td key={month.month} className={misTdNumber}>
                      {month.totalOnsiteTeam}
                    </td>
                  ))}
                </tr>
                <tr className={misRow}>
                  <td className={misTdLabel}>Onsite - Billable</td>
                  {months.map((month) => (
                    <td key={month.month} className={misTdNumber}>
                      <div>{month.billable}</div>
                      <div className={misTdNote}>{month.billablePercentage}%</div>
                    </td>
                  ))}
                </tr>
                <tr className={misRow}>
                  <td className={misTdLabel}>Onsite - Non billable</td>
                  {months.map((month) => (
                    <td key={month.month} className={misTdNumber}>
                      <div>{month.nonBillable}</div>
                      <div className={misTdNote}>{month.nonBillablePercentage}%</div>
                    </td>
                  ))}
                </tr>
              </tbody>
            </table>
          </div>
          )}
          {view !== "list" && <OnsiteChart months={months} />}
        </div>
      )}
    </article>
  );
}

function OnsiteChart({ months }: { months: OnsiteUtilization["months"] }) {
  const { hover, setHover, clear } = useColumnBarHover();
  const { hidden, toggle, isHidden, isGrowingIn } = useLegendSeriesToggle();
  return (
    <ChartDismiss onMouseLeave={clear}>
      <DashboardChartBody>
        {(tipAnchor) => (
      <div className="w-full">
      <ColumnBarHoverScope hover={hover}>
      <ChartContainer config={chartConfig} className="aspect-auto h-[260px] w-full">
        <BarChart data={months} margin={{ left: 8, right: 8, top: 16, bottom: 24 }} {...columnBarChart}>
          <CartesianGrid vertical={false} />
          <XAxis dataKey="month" tickLine={false} axisLine={false} tick={{ fontSize: 12 }} label={xAxisLabel("Month")} />
          <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={48} tick={{ fontSize: 12 }} label={yAxisLabel("Count")} />
          <Bar
            isAnimationActive={isGrowingIn("totalOnsiteTeam")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="totalOnsiteTeam"
            fill="var(--color-totalOnsiteTeam)"
            radius={4}
            hide={isHidden("totalOnsiteTeam")}
            {...columnBarProps(
              "totalOnsiteTeam",
              setHover,
              "var(--color-totalOnsiteTeam)",
              4,
              tipAnchor,
              chartSeriesLabel(chartConfig, "totalOnsiteTeam"),
            )}
          />
          <Bar
            isAnimationActive={isGrowingIn("billable")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="billable"
            fill="var(--color-billable)"
            radius={4}
            hide={isHidden("billable")}
            {...columnBarProps(
              "billable",
              setHover,
              "var(--color-billable)",
              4,
              tipAnchor,
              chartSeriesLabel(chartConfig, "billable"),
            )}
          />
          <Bar
            isAnimationActive={isGrowingIn("nonBillable")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="nonBillable"
            fill="var(--color-nonBillable)"
            radius={4}
            hide={isHidden("nonBillable")}
            {...columnBarProps(
              "nonBillable",
              setHover,
              "var(--color-nonBillable)",
              4,
              tipAnchor,
              chartSeriesLabel(chartConfig, "nonBillable"),
            )}
          />
        </BarChart>
      </ChartContainer>
      </ColumnBarHoverScope>
      <ConfigToggleLegend config={chartConfig} hidden={hidden} onToggle={toggle} />
      </div>
        )}
      </DashboardChartBody>
    </ChartDismiss>
  );
}
