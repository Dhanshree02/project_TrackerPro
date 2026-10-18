import { useEffect, useState } from "react";
import { Bar, BarChart, CartesianGrid, XAxis, YAxis } from "recharts";
import {
  ChartContainer,
  type ChartConfig,
} from "@/components/ui/chart";
import {
  dashboardPeriodLabel,
  fetchResignationCounts,
  type DashboardPeriod,
  type MisDashboardView,
  type ResignationCountRow,
  type ResignationCounts,
} from "@/modules/dashboard/api/dashboard";
import { ColumnBarHoverScope, columnBarProps, useColumnBarHover } from "@/modules/dashboard/components/bar-emphasis";
import {
  ConfigToggleLegend,
  LEGEND_BAR_GROW_MS,
  useLegendSeriesToggle,
} from "@/modules/dashboard/components/toggle-chart-legend";
import {
  ChartDismiss,
  columnBarChart,
  DashboardChartBody,
  chartSeriesLabel,
  GraphZoom,
  xAxisLabel,
  yAxisLabel,
} from "@/modules/dashboard/components/graph-frame";
import {
  misHeadRow,
  misRow,
  misTable,
  misTableScroll,
  misTdLabel,
  misTdNumber,
  misThLabel,
  misThNumber,
} from "@/modules/dashboard/components/dashboard-table";

const chartConfig = {
  totalCount: { label: "Total Count", color: "var(--chart-1)" },
  bondFree: { label: "Bond Free", color: "var(--chart-2)" },
  onPaper: { label: "On Paper", color: "var(--chart-4)" },
} satisfies ChartConfig;

export function ResignationCountSection({
  period,
  view,
}: {
  period: DashboardPeriod;
  view: MisDashboardView;
}) {
  const [data, setData] = useState<ResignationCounts | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);

    fetchResignationCounts(period, controller.signal)
      .then((result) => {
        if (!controller.signal.aborted) setData(result);
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted) return;
        const message = err instanceof Error ? err.message : "Could not load resignation counts.";
        setError(message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
  }, [period, reloadKey]);

  const showChart = view !== "list";
  const showTable = view !== "graph";

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-sm font-semibold">Team Resignation Count – Onsite/Offsite ({dashboardPeriodLabel(period)})</h3>
          <p className="text-xs text-muted-foreground">Role counts for the selected period. Bond Free is bond status No bond. On Paper is a resignation in this period.</p>
        </div>
        {!loading && !error && data && showChart && (
          <GraphZoom
            title={`Team Resignation Count – Onsite/Offsite (${dashboardPeriodLabel(period)})`}
            render={() => (
              <div className="grid gap-6 lg:grid-cols-2">
                <RolePanel title="Offsite" rows={data.offsite} showChart showTable={false} />
                <RolePanel title="Onsite" rows={data.onsite} showChart showTable={false} />
              </div>
            )}
          />
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
        <div className="mt-4 grid gap-6 lg:grid-cols-2">
          <RolePanel title="Offsite" rows={data.offsite} showChart={showChart} showTable={showTable} />
          <RolePanel title="Onsite" rows={data.onsite} showChart={showChart} showTable={showTable} />
        </div>
      )}
    </article>
  );
}

function RolePanel({
  title,
  rows,
  showChart,
  showTable,
}: {
  title: string;
  rows: ResignationCountRow[];
  showChart: boolean;
  showTable: boolean;
}) {
  const { hover, setHover, clear } = useColumnBarHover();
  const { hidden, toggle, isHidden, isGrowingIn } = useLegendSeriesToggle();
  return (
    <div className="min-w-0 space-y-4">
      <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">{title}</p>
      {showChart && (
        <ChartDismiss onMouseLeave={clear}>
        <DashboardChartBody>
          {(tipAnchor) => (
        <div className="w-full">
        <ColumnBarHoverScope hover={hover}>
        <ChartContainer config={chartConfig} className="aspect-auto w-full" style={{ height: 320 }}>
          <BarChart data={rows} margin={{ left: 8, right: 8, top: 8, bottom: 28 }} {...columnBarChart}>
            <CartesianGrid vertical={false} />
            <XAxis
              dataKey="role"
              interval={0}
              tickLine={false}
              axisLine={false}
              tick={{ fontSize: 10 }}
              angle={-24}
              textAnchor="end"
              height={72}
              label={xAxisLabel("Role")}
            />
            <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={48} label={yAxisLabel("Count")} />
            <Bar
              isAnimationActive={isGrowingIn("totalCount")}
              animationDuration={LEGEND_BAR_GROW_MS}
              minPointSize={6}
              dataKey="totalCount"
              fill="var(--color-totalCount)"
              radius={4}
              hide={isHidden("totalCount")}
              {...columnBarProps(
                "totalCount",
                setHover,
                "var(--color-totalCount)",
                4,
                tipAnchor,
                chartSeriesLabel(chartConfig, "totalCount"),
              )}
            />
            <Bar
              isAnimationActive={isGrowingIn("bondFree")}
              animationDuration={LEGEND_BAR_GROW_MS}
              minPointSize={6}
              dataKey="bondFree"
              fill="var(--color-bondFree)"
              radius={4}
              hide={isHidden("bondFree")}
              {...columnBarProps(
                "bondFree",
                setHover,
                "var(--color-bondFree)",
                4,
                tipAnchor,
                chartSeriesLabel(chartConfig, "bondFree"),
              )}
            />
            <Bar
              isAnimationActive={isGrowingIn("onPaper")}
              animationDuration={LEGEND_BAR_GROW_MS}
              minPointSize={6}
              dataKey="onPaper"
              fill="var(--color-onPaper)"
              radius={4}
              hide={isHidden("onPaper")}
              {...columnBarProps(
                "onPaper",
                setHover,
                "var(--color-onPaper)",
                4,
                tipAnchor,
                chartSeriesLabel(chartConfig, "onPaper"),
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
      )}
      {showTable && <RoleTable rows={rows} />}
    </div>
  );
}

function RoleTable({ rows }: { rows: ResignationCountRow[] }) {
  return (
    <div className={misTableScroll}>
      <table className={`${misTable} min-w-[320px]`}>
        <thead>
          <tr className={misHeadRow}>
            <th className={misThLabel}>Team Role</th>
            <th className={misThNumber}>Total Count</th>
            <th className={misThNumber}>Bond Free</th>
            <th className={misThNumber}>On Paper</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.role} className={misRow}>
              <td className={misTdLabel}>{row.role}</td>
              <td className={misTdNumber}>{row.totalCount}</td>
              <td className={misTdNumber}>{row.bondFree}</td>
              <td className={misTdNumber}>{row.onPaper}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
