import { useEffect, useState } from "react";
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
  dashboardPeriodLabel,
  fetchOffsiteTeamUtilization,
  type DashboardPeriod,
  type MisDashboardView,
  type OffsiteTeamUtilization,
} from "@/lib/api/dashboard";

export function OffsiteTeamUtilizationSection({
  period,
  view,
}: {
  period: DashboardPeriod;
  view: MisDashboardView;
}) {
  const [data, setData] = useState<OffsiteTeamUtilization | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);

    fetchOffsiteTeamUtilization(period, controller.signal)
      .then((result) => {
        if (!controller.signal.aborted) setData(result);
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted) return;
        const message = err instanceof Error ? err.message : "Could not load offsite team utilization.";
        setError(message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
  }, [period, reloadKey]);

  const months = data?.months ?? [];
  const strengthConfig = {
    s0: { label: months[0]?.month ?? "Month 1", color: "var(--chart-1)" },
    s1: { label: months[1]?.month ?? "Month 2", color: "var(--chart-2)" },
    s2: { label: months[2]?.month ?? "Month 3", color: "var(--chart-4)" },
  } satisfies ChartConfig;
  const utilizationConfig = {
    u0: { label: months[0]?.month ?? "Month 1", color: "var(--chart-1)" },
    u1: { label: months[1]?.month ?? "Month 2", color: "var(--chart-2)" },
    u2: { label: months[2]?.month ?? "Month 3", color: "var(--chart-4)" },
  } satisfies ChartConfig;

  const chartRows = (data?.departments ?? []).map((row) => ({
    department: row.department,
    s0: row.teamStrength[0] ?? 0,
    s1: row.teamStrength[1] ?? 0,
    s2: row.teamStrength[2] ?? 0,
    u0: row.utilization[0] ?? 0,
    u1: row.utilization[1] ?? 0,
    u2: row.utilization[2] ?? 0,
  }));
  const showChart = view !== "list";
  const showTable = view !== "graph";

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div>
        <h3 className="text-sm font-semibold">Team Utilization – Offsite</h3>
        <p className="text-xs text-muted-foreground">Offsite team strength and timesheet utilization by employee sub-department</p>
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

      {!loading && !error && data && data.departments.length === 0 && (
        <p className="mt-4 text-sm text-muted-foreground">No offsite employees for {dashboardPeriodLabel(period)}.</p>
      )}

      {!loading && !error && data && data.departments.length > 0 && (
        <div className="mt-4 space-y-6">
          {showChart && (
            <div className="grid gap-6 xl:grid-cols-2">
              <div className="min-w-0">
                <p className="mb-2 text-xs font-medium text-muted-foreground">Team Strength</p>
                <ChartContainer config={strengthConfig} className="aspect-auto w-full" style={{ height: Math.max(280, chartRows.length * 36 + 48) }}>
                  <BarChart data={chartRows} layout="vertical" margin={{ left: 8, right: 16, top: 8 }}>
                    <CartesianGrid horizontal={false} />
                    <XAxis type="number" allowDecimals={false} tickLine={false} axisLine={false} />
                    <YAxis type="category" dataKey="department" width={168} tickLine={false} axisLine={false} tick={{ fontSize: 10 }} />
                    <ChartTooltip content={<ChartTooltipContent />} />
                    <ChartLegend content={<ChartLegendContent />} />
                    <Bar dataKey="s0" fill="var(--color-s0)" radius={4} />
                    <Bar dataKey="s1" fill="var(--color-s1)" radius={4} />
                    <Bar dataKey="s2" fill="var(--color-s2)" radius={4} />
                  </BarChart>
                </ChartContainer>
              </div>
              <div className="min-w-0">
                <p className="mb-2 text-xs font-medium text-muted-foreground">Team Utilization %</p>
                <ChartContainer config={utilizationConfig} className="aspect-auto w-full" style={{ height: Math.max(280, chartRows.length * 36 + 48) }}>
                  <BarChart data={chartRows} layout="vertical" margin={{ left: 8, right: 16, top: 8 }}>
                    <CartesianGrid horizontal={false} />
                    <XAxis type="number" domain={[0, 100]} allowDecimals={false} tickLine={false} axisLine={false} unit="%" />
                    <YAxis type="category" dataKey="department" width={168} tickLine={false} axisLine={false} tick={{ fontSize: 10 }} />
                    <ChartTooltip content={<ChartTooltipContent />} />
                    <ChartLegend content={<ChartLegendContent />} />
                    <Bar dataKey="u0" fill="var(--color-u0)" radius={4} />
                    <Bar dataKey="u1" fill="var(--color-u1)" radius={4} />
                    <Bar dataKey="u2" fill="var(--color-u2)" radius={4} />
                  </BarChart>
                </ChartContainer>
              </div>
            </div>
          )}

          {showTable && (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[720px] text-sm">
                <thead>
                  <tr className="border-b border-border text-xs text-muted-foreground">
                    <th rowSpan={2} className="py-2 pr-3 text-left align-bottom font-medium">Department</th>
                    <th colSpan={months.length || 3} className="px-2 py-2 text-center font-medium">Team Strength</th>
                    <th colSpan={months.length || 3} className="px-2 py-2 text-center font-medium">Team Utilization %</th>
                  </tr>
                  <tr className="border-b border-border text-xs text-muted-foreground">
                    {months.map((month) => (
                      <th key={`s-${month.month}`} className="px-2 py-2 text-right font-medium">{month.month}</th>
                    ))}
                    {months.map((month) => (
                      <th key={`u-${month.month}`} className="px-2 py-2 text-right font-medium">{month.month}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {data.departments.map((row) => (
                    <tr key={row.department} className="border-b border-border last:border-0">
                      <td className="py-2 pr-3">{row.department}</td>
                      {months.map((month, index) => (
                        <td key={`s-${month.month}`} className="px-2 py-2 text-right tabular-nums">
                          {row.teamStrength[index] ?? 0}
                        </td>
                      ))}
                      {months.map((month, index) => (
                        <td key={`u-${month.month}`} className="px-2 py-2 text-right tabular-nums">
                          {row.utilization[index] ?? 0}%
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}
    </article>
  );
}
