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
  fetchOnsiteUtilization,
  type DashboardQuarter,
  type OnsiteUtilization,
} from "@/lib/api/dashboard";

const chartConfig = {
  totalOnsiteTeam: { label: "Total Onsite Team", color: "var(--chart-1)" },
  billable: { label: "Onsite Billable", color: "var(--chart-2)" },
  nonBillable: { label: "Onsite Non-billable", color: "var(--chart-4)" },
} satisfies ChartConfig;

export function OnsiteUtilizationSection({ quarter }: { quarter: DashboardQuarter }) {
  const [data, setData] = useState<OnsiteUtilization | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);

    fetchOnsiteUtilization(quarter, controller.signal)
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
  }, [quarter, reloadKey]);

  const months = data?.months ?? [];

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <h3 className="text-sm font-semibold">Team Utilization - Onsite ({quarter})</h3>
      <p className="text-xs text-muted-foreground">Resources assigned to onsite services</p>

      {loading && (
        <div className="mt-4 rounded-lg border border-border px-4 py-10 text-center text-sm text-muted-foreground">
          Loading {quarter}…
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
          <div className="overflow-x-auto">
            <table className="w-full min-w-[280px] text-sm">
              <thead>
                <tr className="border-b border-border text-xs text-muted-foreground">
                  <th className="py-2 pr-3 text-left font-medium">Project Type</th>
                  {months.map((month) => (
                    <th key={month.month} className="px-2 py-2 text-right font-medium">
                      {month.month}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                <tr className="border-b border-border">
                  <td className="py-2 pr-3">Total Onsite Team</td>
                  {months.map((month) => (
                    <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                      {month.totalOnsiteTeam}
                    </td>
                  ))}
                </tr>
                <tr className="border-b border-border">
                  <td className="py-2 pr-3">Onsite - Billable</td>
                  {months.map((month) => (
                    <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                      <div>{month.billable}</div>
                      <div className="text-xs text-muted-foreground">{month.billablePercentage}%</div>
                    </td>
                  ))}
                </tr>
                <tr>
                  <td className="py-2 pr-3">Onsite - Non billable</td>
                  {months.map((month) => (
                    <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                      <div>{month.nonBillable}</div>
                      <div className="text-xs text-muted-foreground">{month.nonBillablePercentage}%</div>
                    </td>
                  ))}
                </tr>
              </tbody>
            </table>
          </div>
          <ChartContainer config={chartConfig} className="aspect-auto h-[260px] w-full">
            <BarChart data={months} margin={{ left: 0, right: 8, top: 8 }}>
              <CartesianGrid vertical={false} />
              <XAxis dataKey="month" tickLine={false} axisLine={false} />
              <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={32} />
              <ChartTooltip content={<ChartTooltipContent />} />
              <ChartLegend content={<ChartLegendContent />} />
              <Bar dataKey="totalOnsiteTeam" fill="var(--color-totalOnsiteTeam)" radius={4} />
              <Bar dataKey="billable" fill="var(--color-billable)" radius={4} />
              <Bar dataKey="nonBillable" fill="var(--color-nonBillable)" radius={4} />
            </BarChart>
          </ChartContainer>
        </div>
      )}
    </article>
  );
}
