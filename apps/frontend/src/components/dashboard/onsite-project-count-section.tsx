import { useEffect, useMemo, useState } from "react";
import { Bar, BarChart, CartesianGrid, LabelList, XAxis, YAxis } from "recharts";
import {
  ChartContainer,
  type ChartConfig,
} from "@/components/ui/chart";
import {
  dashboardPeriodLabel,
  fetchOnsiteProjectCounts,
  type DashboardPeriod,
  type MisDashboardView,
  type OnsiteProjectCounts,
} from "@/lib/api/dashboard";
import { ColumnBarHoverScope, rowBarProps, useColumnBarHover } from "@/components/dashboard/bar-emphasis";
import {
  ConfigToggleLegend,
  LEGEND_BAR_GROW_MS,
  useLegendSeriesToggle,
} from "@/components/dashboard/toggle-chart-legend";
import {
  ChartDismiss,
  DashboardChartBody,
  chartSeriesLabel,
  GraphZoom,
  rowBarChart,
  xAxisLabel,
  yAxisLabel,
} from "@/components/dashboard/graph-frame";
import {
  misHeadRow,
  misRow,
  misTable,
  misTableScroll,
  misTdLabel,
  misTdNumber,
  misThLabel,
  misThNumber,
} from "@/components/dashboard/dashboard-table";

const PAGE_SIZE = 8;

export function OnsiteProjectCountSection({
  period,
  view,
}: {
  period: DashboardPeriod;
  view: MisDashboardView;
}) {
  const [data, setData] = useState<OnsiteProjectCounts | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [chartLimit, setChartLimit] = useState(10);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);
    setPage(1);

    fetchOnsiteProjectCounts(period, controller.signal)
      .then((result) => {
        if (!controller.signal.aborted) setData(result);
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted) return;
        const message = err instanceof Error ? err.message : "Could not load project onsite counts.";
        setError(message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
  }, [period, reloadKey]);

  const months = data?.months ?? [];
  const filtered = useMemo(() => {
    const needle = search.trim().toLowerCase();
    const projects = data?.projects ?? [];
    if (!needle) return projects;
    return projects.filter((project) => project.projectName.toLowerCase().includes(needle));
  }, [data, search]);

  const pageCount = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const safePage = Math.min(page, pageCount);
  const pageRows = filtered.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE);
  const chartRows = (chartLimit === 0 ? filtered : filtered.slice(0, chartLimit)).map((project) => ({
    projectName: project.projectName,
    m0: project.monthlyCounts[0] ?? 0,
    m1: project.monthlyCounts[1] ?? 0,
    m2: project.monthlyCounts[2] ?? 0,
  }));
  const showChart = view !== "list";
  const showTable = view !== "graph";

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h3 className="text-sm font-semibold">Team Utilization – Onsite: Project-wise Resource Count</h3>
          <p className="text-xs text-muted-foreground">People assigned to the project's onsite services</p>
        </div>
        <div className="flex items-end gap-2">
        {showChart && !loading && !error && data && filtered.length > 0 && (
          <GraphZoom
            title="Team Utilization – Onsite: Project-wise Resource Count"
            render={() => <ProjectCountChart chartRows={chartRows} months={months} />}
          />
        )}
        {!loading && !error && data && data.projects.length > 0 && (
          <label className="flex items-center gap-2 text-xs text-muted-foreground">
            Search
            <input
              value={search}
              onChange={(event) => {
                setSearch(event.target.value);
                setPage(1);
              }}
              placeholder="Project name"
              className="h-8 w-44 rounded-md border border-input bg-card px-2 text-xs text-foreground"
            />
          </label>
        )}
        </div>
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

      {!loading && !error && data && filtered.length === 0 && (
        <p className="mt-4 text-sm text-muted-foreground">No onsite project assignments for {dashboardPeriodLabel(period)}.</p>
      )}

      {!loading && !error && data && filtered.length > 0 && (
        <div className={`mt-4 grid gap-6 ${showChart && showTable ? "xl:grid-cols-2" : ""}`}>
          {showChart && (
            <div className="min-w-0">
              <div className="mb-2 flex flex-wrap items-center justify-between gap-2 text-xs text-muted-foreground">
                <span>
                  Showing {chartRows.length} of {filtered.length} projects
                </span>
                <label className="flex items-center gap-2">
                  Chart projects
                  <select
                    value={chartLimit}
                    onChange={(event) => setChartLimit(Number(event.target.value))}
                    className="h-8 min-w-[7rem] rounded-md border border-input bg-card py-0 pl-2 pr-8 text-xs text-foreground"
                  >
                    <option value={10}>Top 10</option>
                    <option value={20}>Top 20</option>
                    <option value={50}>Top 50</option>
                    <option value={0}>All</option>
                  </select>
                </label>
              </div>
              <ProjectCountChart
                chartRows={chartRows}
                months={months}
                yAxisWidth={150}
                truncateProjectNames
              />
            </div>
          )}

          {showTable && (
            <div className="min-w-0">
              <div className={misTableScroll}>
                <table className={`${misTable} min-w-[520px]`}>
                  <thead>
                    <tr className={misHeadRow}>
                      <th className={misThLabel}>Project Name</th>
                      <th className={misThNumber}>Onsite Resource Count</th>
                      {months.map((month) => (
                        <th key={month.month} className={misThNumber}>
                          {month.month}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {pageRows.map((project) => (
                      <tr key={project.projectName} className={misRow}>
                        <td className={misTdLabel} title={project.projectName}>{project.projectName}</td>
                        <td className={misTdNumber}>{project.onsiteResourceCount}</td>
                        {months.map((month, index) => (
                          <td key={month.month} className={misTdNumber}>
                            {project.monthlyCounts[index] ?? 0}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="mt-3 flex items-center justify-between text-xs text-muted-foreground">
                <span>
                  Showing {(safePage - 1) * PAGE_SIZE + 1}–{Math.min(safePage * PAGE_SIZE, filtered.length)} of {filtered.length}
                </span>
                <div className="flex gap-2">
                  <button
                    type="button"
                    disabled={safePage <= 1}
                    onClick={() => setPage((current) => Math.max(1, current - 1))}
                    className="rounded-md border border-input bg-card px-2 py-1 disabled:opacity-40"
                  >
                    Previous
                  </button>
                  <button
                    type="button"
                    disabled={safePage >= pageCount}
                    onClick={() => setPage((current) => current + 1)}
                    className="rounded-md border border-input bg-card px-2 py-1 disabled:opacity-40"
                  >
                    Next
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      )}
    </article>
  );
}

function ProjectCountChart({
  chartRows,
  months,
  yAxisWidth = 180,
  truncateProjectNames = false,
}: {
  chartRows: Array<{ projectName: string; m0: number; m1: number; m2: number }>;
  months: OnsiteProjectCounts["months"];
  yAxisWidth?: number;
  truncateProjectNames?: boolean;
}) {
  const { hover, setHover, clear } = useColumnBarHover();
  const { hidden, toggle, isHidden, isGrowingIn } = useLegendSeriesToggle();
  const chartConfig = {
    m0: { label: months[0]?.month ?? "Month 1", color: "var(--chart-1)" },
    m1: { label: months[1]?.month ?? "Month 2", color: "var(--chart-2)" },
    m2: { label: months[2]?.month ?? "Month 3", color: "var(--chart-4)" },
  } satisfies ChartConfig;

  return (
    <ChartDismiss onMouseLeave={clear}>
      <DashboardChartBody>
        {(tipAnchor) => (
      <div className="w-full">
      <ColumnBarHoverScope hover={hover}>
      <ChartContainer
        config={chartConfig}
        className="aspect-auto w-full"
        style={{ height: Math.max(240, chartRows.length * 56 + 36) }}
      >
        <BarChart data={chartRows} layout="vertical" margin={{ left: 28, right: 28, top: 8, bottom: 28 }} {...rowBarChart}>
          <CartesianGrid horizontal={false} />
          <XAxis type="number" allowDecimals={false} tickLine={false} axisLine={false} label={xAxisLabel("Onsite resource count")} />
          <YAxis
            type="category"
            dataKey="projectName"
            width={yAxisWidth}
            tickLine={false}
            axisLine={false}
            tick={{ fontSize: 10 }}
            tickFormatter={
              truncateProjectNames
                ? (value: string) => (value.length > 26 ? `${value.slice(0, 24)}…` : value)
                : undefined
            }
            label={yAxisLabel("Project")}
          />
          <Bar
            isAnimationActive={isGrowingIn("m0")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            maxBarSize={16}
            dataKey="m0"
            fill="var(--color-m0)"
            radius={4}
            hide={isHidden("m0")}
            {...rowBarProps("m0", setHover, "var(--color-m0)", 4, tipAnchor, chartSeriesLabel(chartConfig, "m0"))}
          >
            <LabelList dataKey="m0" position="right" className="fill-foreground" fontSize={10} />
          </Bar>
          <Bar
            isAnimationActive={isGrowingIn("m1")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            maxBarSize={16}
            dataKey="m1"
            fill="var(--color-m1)"
            radius={4}
            hide={isHidden("m1")}
            {...rowBarProps("m1", setHover, "var(--color-m1)", 4, tipAnchor, chartSeriesLabel(chartConfig, "m1"))}
          >
            <LabelList dataKey="m1" position="right" className="fill-foreground" fontSize={10} />
          </Bar>
          <Bar
            isAnimationActive={isGrowingIn("m2")}
            animationDuration={LEGEND_BAR_GROW_MS}
            minPointSize={6}
            maxBarSize={16}
            dataKey="m2"
            fill="var(--color-m2)"
            radius={4}
            hide={isHidden("m2")}
            {...rowBarProps("m2", setHover, "var(--color-m2)", 4, tipAnchor, chartSeriesLabel(chartConfig, "m2"))}
          >
            <LabelList dataKey="m2" position="right" className="fill-foreground" fontSize={10} />
          </Bar>
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
