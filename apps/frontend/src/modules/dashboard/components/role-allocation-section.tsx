import { useEffect, useState } from "react";
import { Bar, BarChart, CartesianGrid, LabelList, XAxis, YAxis } from "recharts";
import {
  ChartContainer,
  type ChartConfig,
} from "@/components/ui/chart";
import {
  dashboardPeriodLabel,
  fetchRoleAllocation,
  type DashboardPeriod,
  type MisDashboardView,
  type RoleAllocation,
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

const onsiteChartConfig = {
  onsiteTm: { label: "Onsite TM", color: "var(--chart-1)" },
  onsiteLeads: { label: "Onsite Leads", color: "var(--chart-5)" },
  onsitePm: { label: "Onsite PM", color: "var(--chart-4)" },
} satisfies ChartConfig;

export function RoleAllocationSection({
  period,
  view,
}: {
  period: DashboardPeriod;
  view: MisDashboardView;
}) {
  const [data, setData] = useState<RoleAllocation | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);

    fetchRoleAllocation(period, controller.signal)
      .then((result) => {
        if (!controller.signal.aborted) setData(result);
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted) return;
        const message = err instanceof Error ? err.message : "Could not load team allocation.";
        setError(message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
  }, [period, reloadKey]);

  const months = data?.months ?? [];
  const offsiteChartConfig = {
    m0: { label: months[0]?.month ?? "Month 1", color: "var(--chart-1)" },
    m1: { label: months[1]?.month ?? "Month 2", color: "var(--chart-5)" },
    m2: { label: months[2]?.month ?? "Month 3", color: "var(--chart-3)" },
  } satisfies ChartConfig;

  const offsiteChartData = [
    {
      role: "Offsite - TM",
      m0: months[0]?.offsiteTm ?? 0,
      m1: months[1]?.offsiteTm ?? 0,
      m2: months[2]?.offsiteTm ?? 0,
    },
    {
      role: "Offsite - Leads",
      m0: months[0]?.offsiteLeads ?? 0,
      m1: months[1]?.offsiteLeads ?? 0,
      m2: months[2]?.offsiteLeads ?? 0,
    },
    {
      role: "Offsite - PM",
      m0: months[0]?.offsitePm ?? 0,
      m1: months[1]?.offsitePm ?? 0,
      m2: months[2]?.offsitePm ?? 0,
    },
  ];

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-sm font-semibold">Team Allocation Onsite/Offsite ({dashboardPeriodLabel(period)})</h3>
          <p className="text-xs text-muted-foreground">Role wise count</p>
        </div>
        {!loading && !error && data && view !== "list" && (
          <GraphZoom
            title={`Team Allocation Onsite/Offsite (${dashboardPeriodLabel(period)})`}
            render={() => (
              <div className="grid gap-6 lg:grid-cols-2">
                <OnsiteAllocationChart months={months} />
                <OffsiteAllocationChart data={offsiteChartData} config={offsiteChartConfig} />
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
          <div className="min-w-0 space-y-4">
            {view !== "graph" && (
            <div className={misTableScroll}>
              <table className={`${misTable} min-w-[280px]`}>
                <thead>
                  <tr className={misHeadRow}>
                    <th className={misThLabel}>Role Wise Count</th>
                    {months.map((month) => (
                      <th key={month.month} className={misThNumber}>
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Onsite TM</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.onsiteTm}
                      </td>
                    ))}
                  </tr>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Onsite Leads</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.onsiteLeads}
                      </td>
                    ))}
                  </tr>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Onsite PM</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.onsitePm ?? 0}
                      </td>
                    ))}
                  </tr>
                </tbody>
              </table>
            </div>
            )}
            {view !== "list" && <OnsiteAllocationChart months={months} />}
          </div>

          <div className="min-w-0 space-y-4">
            {view !== "graph" && (
            <div className={misTableScroll}>
              <table className={`${misTable} min-w-[280px]`}>
                <thead>
                  <tr className={misHeadRow}>
                    <th className={misThLabel}>Role Wise Count</th>
                    {months.map((month) => (
                      <th key={month.month} className={misThNumber}>
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Offsite - TM</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.offsiteTm}
                      </td>
                    ))}
                  </tr>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Offsite - Leads</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.offsiteLeads}
                      </td>
                    ))}
                  </tr>
                  <tr className={misRow}>
                    <td className={misTdLabel}>Offsite - PM</td>
                    {months.map((month) => (
                      <td key={month.month} className={misTdNumber}>
                        {month.offsitePm}
                      </td>
                    ))}
                  </tr>
                </tbody>
              </table>
            </div>
            )}
            {view !== "list" && (
                <OffsiteAllocationChart data={offsiteChartData} config={offsiteChartConfig} />
            )}
          </div>
        </div>
      )}
    </article>
  );
}

function OnsiteAllocationChart({ months }: { months: RoleAllocation["months"] }) {
  const { hover, setHover, clear } = useColumnBarHover();
  const { hidden, toggle, isHidden, isGrowingIn } = useLegendSeriesToggle();
  return (
    <ChartDismiss onMouseLeave={clear}>
      <DashboardChartBody>
        {(tipAnchor) => (
      <div className="w-full">
      <ColumnBarHoverScope hover={hover}>
      <ChartContainer config={onsiteChartConfig} className="aspect-auto h-[260px] w-full">
        <BarChart data={months} margin={{ left: 8, right: 8, top: 16, bottom: 24 }} {...columnBarChart}>
          <CartesianGrid vertical={false} />
          <XAxis dataKey="month" tickLine={false} axisLine={false} tick={{ fontSize: 12 }} label={xAxisLabel("Month")} />
          <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={48} label={yAxisLabel("Count")} />
          <Bar
            isAnimationActive={isGrowingIn("onsiteTm")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="onsiteTm"
            fill="var(--color-onsiteTm)"
            radius={4}
            hide={isHidden("onsiteTm")}
            {...columnBarProps(
              "onsiteTm",
              setHover,
              "var(--color-onsiteTm)",
              4,
              tipAnchor,
              chartSeriesLabel(onsiteChartConfig, "onsiteTm"),
            )}
          >
            <LabelList dataKey="onsiteTm" position="top" className="fill-foreground" fontSize={10} />
          </Bar>
          <Bar
            isAnimationActive={isGrowingIn("onsiteLeads")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="onsiteLeads"
            fill="var(--color-onsiteLeads)"
            radius={4}
            hide={isHidden("onsiteLeads")}
            {...columnBarProps(
              "onsiteLeads",
              setHover,
              "var(--color-onsiteLeads)",
              4,
              tipAnchor,
              chartSeriesLabel(onsiteChartConfig, "onsiteLeads"),
            )}
          >
            <LabelList dataKey="onsiteLeads" position="top" className="fill-foreground" fontSize={10} />
          </Bar>
          <Bar
            isAnimationActive={isGrowingIn("onsitePm")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="onsitePm"
            fill="var(--color-onsitePm)"
            radius={4}
            hide={isHidden("onsitePm")}
            {...columnBarProps(
              "onsitePm",
              setHover,
              "var(--color-onsitePm)",
              4,
              tipAnchor,
              chartSeriesLabel(onsiteChartConfig, "onsitePm"),
            )}
          >
            <LabelList dataKey="onsitePm" position="top" className="fill-foreground" fontSize={10} />
          </Bar>
        </BarChart>
      </ChartContainer>
      </ColumnBarHoverScope>
      <ConfigToggleLegend config={onsiteChartConfig} hidden={hidden} onToggle={toggle} />
      </div>
        )}
      </DashboardChartBody>
    </ChartDismiss>
  );
}

function OffsiteAllocationChart({
  data,
  config,
}: {
  data: Array<{ role: string; m0: number; m1: number; m2: number }>;
  config: ChartConfig;
}) {
  const { hover, setHover, clear } = useColumnBarHover();
  const { hidden, toggle, isHidden, isGrowingIn } = useLegendSeriesToggle();
  return (
    <ChartDismiss onMouseLeave={clear}>
      <DashboardChartBody>
        {(tipAnchor) => (
      <div className="w-full">
      <ColumnBarHoverScope hover={hover}>
      <ChartContainer config={config} className="aspect-auto h-[280px] w-full">
        <BarChart data={data} margin={{ left: 8, right: 8, top: 16, bottom: 24 }} {...columnBarChart}>
          <CartesianGrid vertical={false} />
          <XAxis dataKey="role" tickLine={false} axisLine={false} interval={0} tick={{ fontSize: 11 }} label={xAxisLabel("Role")} />
          <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={48} label={yAxisLabel("Count")} />
          <Bar
            isAnimationActive={isGrowingIn("m0")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="m0"
            fill="var(--color-m0)"
            radius={4}
            hide={isHidden("m0")}
            {...columnBarProps("m0", setHover, "var(--color-m0)", 4, tipAnchor, chartSeriesLabel(config, "m0"))}
          >
            <LabelList dataKey="m0" position="top" className="fill-foreground" fontSize={10} />
          </Bar>
          <Bar
            isAnimationActive={isGrowingIn("m1")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="m1"
            fill="var(--color-m1)"
            radius={4}
            hide={isHidden("m1")}
            {...columnBarProps("m1", setHover, "var(--color-m1)", 4, tipAnchor, chartSeriesLabel(config, "m1"))}
          >
            <LabelList dataKey="m1" position="top" className="fill-foreground" fontSize={10} />
          </Bar>
          <Bar
            isAnimationActive={isGrowingIn("m2")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            dataKey="m2"
            fill="var(--color-m2)"
            radius={4}
            hide={isHidden("m2")}
            {...columnBarProps("m2", setHover, "var(--color-m2)", 4, tipAnchor, chartSeriesLabel(config, "m2"))}
          >
            <LabelList dataKey="m2" position="top" className="fill-foreground" fontSize={10} />
          </Bar>
        </BarChart>
      </ChartContainer>
      </ColumnBarHoverScope>
      <ConfigToggleLegend config={config} hidden={hidden} onToggle={toggle} />
      </div>
        )}
      </DashboardChartBody>
    </ChartDismiss>
  );
}
