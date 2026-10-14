import { useEffect, useMemo, useState } from "react";
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
  fetchOnsiteProjectCounts,
  type DashboardPeriod,
  type MisDashboardView,
  type OnsiteProjectCounts,
} from "@/lib/api/dashboard";

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
  const chartConfig = {
    m0: { label: months[0]?.month ?? "Month 1", color: "var(--chart-1)" },
    m1: { label: months[1]?.month ?? "Month 2", color: "var(--chart-2)" },
    m2: { label: months[2]?.month ?? "Month 3", color: "var(--chart-4)" },
  } satisfies ChartConfig;

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
                    className="h-8 rounded-md border border-input bg-card px-2 text-xs text-foreground"
                  >
                    <option value={10}>Top 10</option>
                    <option value={20}>Top 20</option>
                    <option value={50}>Top 50</option>
                    <option value={0}>All</option>
                  </select>
                </label>
              </div>
              <ChartContainer
                config={chartConfig}
                className="aspect-auto w-full"
                style={{ height: Math.max(260, chartRows.length * 42 + 48) }}
              >
                <BarChart data={chartRows} layout="vertical" margin={{ left: 8, right: 24, top: 8 }}>
                  <CartesianGrid horizontal={false} />
                  <XAxis type="number" allowDecimals={false} tickLine={false} axisLine={false} />
                  <YAxis
                    type="category"
                    dataKey="projectName"
                    width={150}
                    tickLine={false}
                    axisLine={false}
                    tick={{ fontSize: 10 }}
                    tickFormatter={(value: string) => (value.length > 26 ? `${value.slice(0, 24)}…` : value)}
                  />
                  <ChartTooltip content={<ChartTooltipContent />} />
                  <ChartLegend content={<ChartLegendContent />} />
                  <Bar dataKey="m0" fill="var(--color-m0)" radius={4}>
                    <LabelList dataKey="m0" position="right" className="fill-foreground" fontSize={10} />
                  </Bar>
                  <Bar dataKey="m1" fill="var(--color-m1)" radius={4}>
                    <LabelList dataKey="m1" position="right" className="fill-foreground" fontSize={10} />
                  </Bar>
                  <Bar dataKey="m2" fill="var(--color-m2)" radius={4}>
                    <LabelList dataKey="m2" position="right" className="fill-foreground" fontSize={10} />
                  </Bar>
                </BarChart>
              </ChartContainer>
            </div>
          )}

          {showTable && (
            <div className="min-w-0">
              <div className="overflow-x-auto">
                <table className="w-full min-w-[520px] text-sm">
                  <thead>
                    <tr className="border-b border-border text-xs text-muted-foreground">
                      <th className="py-2 pr-3 text-left font-medium">Project Name</th>
                      <th className="px-2 py-2 text-right font-medium">Onsite Resource Count</th>
                      {months.map((month) => (
                        <th key={month.month} className="px-2 py-2 text-right font-medium">
                          {month.month}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {pageRows.map((project) => (
                      <tr key={project.projectName} className="border-b border-border last:border-0">
                        <td className="py-2 pr-3">{project.projectName}</td>
                        <td className="px-2 py-2 text-right tabular-nums">{project.onsiteResourceCount}</td>
                        {months.map((month, index) => (
                          <td key={month.month} className="px-2 py-2 text-right tabular-nums">
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
