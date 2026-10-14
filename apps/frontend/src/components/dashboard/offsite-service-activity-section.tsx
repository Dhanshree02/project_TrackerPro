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
  fetchOffsiteServiceActivity,
  type DashboardQuarter,
  type MisDashboardView,
  type OffsiteServiceActivity,
} from "@/lib/api/dashboard";

export function OffsiteServiceActivitySection({
  quarter,
  view,
}: {
  quarter: DashboardQuarter;
  view: MisDashboardView;
}) {
  const [data, setData] = useState<OffsiteServiceActivity | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);

    fetchOffsiteServiceActivity(quarter, controller.signal)
      .then((result) => {
        if (!controller.signal.aborted) setData(result);
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted) return;
        const message = err instanceof Error ? err.message : "Could not load offsite service activity.";
        setError(message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
  }, [quarter, reloadKey]);

  const months = data?.months ?? [];
  const chartConfig = {
    m0: { label: months[0]?.month ?? "Month 1", color: "var(--chart-1)" },
    m1: { label: months[1]?.month ?? "Month 2", color: "var(--chart-2)" },
    m2: { label: months[2]?.month ?? "Month 3", color: "var(--chart-4)" },
  } satisfies ChartConfig;

  const chartRows = (data?.departments ?? []).map((row) => ({
    department: row.department,
    m0: row.monthlyCounts[0] ?? 0,
    m1: row.monthlyCounts[1] ?? 0,
    m2: row.monthlyCounts[2] ?? 0,
  }));
  const showChart = view !== "list";
  const showTable = view !== "graph";

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div>
        <h3 className="text-sm font-semibold">Service Activity Count – Offsite</h3>
        <p className="text-xs text-muted-foreground">Offsite resources by service department</p>
      </div>

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

      {!loading && !error && data && data.departments.length === 0 && (
        <p className="mt-4 text-sm text-muted-foreground">No offsite service assignments for {quarter}.</p>
      )}

      {!loading && !error && data && data.departments.length > 0 && (
        <div className={`mt-4 grid gap-6 ${showChart && showTable ? "xl:grid-cols-2" : ""}`}>
          {showChart && (
            <ChartContainer config={chartConfig} className="aspect-auto w-full min-w-0" style={{ height: Math.max(260, chartRows.length * 48 + 48) }}>
              <BarChart data={chartRows} layout="vertical" margin={{ left: 8, right: 16, top: 8 }}>
                <CartesianGrid horizontal={false} />
                <XAxis type="number" allowDecimals={false} tickLine={false} axisLine={false} />
                <YAxis type="category" dataKey="department" width={180} tickLine={false} axisLine={false} tick={{ fontSize: 11 }} />
                <ChartTooltip content={<ChartTooltipContent />} />
                <ChartLegend content={<ChartLegendContent />} />
                <Bar dataKey="m0" fill="var(--color-m0)" radius={4} />
                <Bar dataKey="m1" fill="var(--color-m1)" radius={4} />
                <Bar dataKey="m2" fill="var(--color-m2)" radius={4} />
              </BarChart>
            </ChartContainer>
          )}

          {showTable && (
            <div className="min-w-0 overflow-x-auto">
              <table className="w-full min-w-[420px] text-sm">
                <thead>
                  <tr className="border-b border-border text-xs text-muted-foreground">
                    <th className="py-2 pr-3 text-left font-medium">Department</th>
                    {months.map((month) => (
                      <th key={month.month} className="px-2 py-2 text-right font-medium">
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {data.departments.map((row) => (
                    <tr key={row.department} className="border-b border-border last:border-0">
                      <td className="py-2 pr-3">{row.department}</td>
                      {months.map((month, index) => (
                        <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                          {row.monthlyCounts[index] ?? 0}
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
