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
  fetchOffsiteCapacity,
  type DashboardPeriod,
  type MisDashboardView,
  type OffsiteCapacity,
  type OffsiteCapacityRow,
} from "@/lib/api/dashboard";

const monthColors = ["var(--chart-1)", "var(--chart-2)", "var(--chart-4)"];

export function OffsiteCapacitySection({
  period,
  view,
}: {
  period: DashboardPeriod;
  view: MisDashboardView;
}) {
  const [data, setData] = useState<OffsiteCapacity | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);

    fetchOffsiteCapacity(period, controller.signal)
      .then((result) => {
        if (!controller.signal.aborted) setData(result);
      })
      .catch((err: unknown) => {
        if (controller.signal.aborted) return;
        const message = err instanceof Error ? err.message : "Could not load offsite capacity.";
        setError(message);
      })
      .finally(() => {
        if (!controller.signal.aborted) setLoading(false);
      });

    return () => controller.abort();
  }, [period, reloadKey]);

  const showChart = view !== "list";
  const showTable = view !== "graph";
  const months = data?.months ?? [];
  const departments = data?.departments ?? [];
  const appRows = departments.filter((row) => row.capacityUnit === "apps");
  const ipRows = departments.filter((row) => row.capacityUnit === "ips");

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <h3 className="text-sm font-semibold">Team Capacity – Offsite ({dashboardPeriodLabel(period)})</h3>
      <p className="text-xs text-muted-foreground">
        Offsite employees by sub-department. Effective days are {data?.calendarDays ?? 21} × TM.
      </p>

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

      {!loading && !error && data && departments.length === 0 && (
        <p className="mt-4 text-sm text-muted-foreground">No offsite sub-departments for {dashboardPeriodLabel(period)}.</p>
      )}

      {!loading && !error && data && departments.length > 0 && (
        <div className="mt-4 space-y-6">
          {showChart && (
            <div className="grid gap-6 xl:grid-cols-2">
              <CapacityChart
                title="Application capacity"
                subtitle="7 days per app"
                rows={appRows}
                months={months}
              />
              <CapacityChart
                title="IP capacity"
                subtitle="10 IPs per day"
                rows={ipRows}
                months={months}
              />
            </div>
          )}

          {showTable && months.map((month, index) => (
            <MonthTable
              key={`${month.month}-${month.year}`}
              title={`${month.month} ${month.year}`}
              calendarDays={data.calendarDays}
              rows={departments}
              monthIndex={index}
            />
          ))}
        </div>
      )}
    </article>
  );
}

function CapacityChart({
  title,
  subtitle,
  rows,
  months,
}: {
  title: string;
  subtitle: string;
  rows: OffsiteCapacityRow[];
  months: OffsiteCapacity["months"];
}) {
  const config = {
    m0: { label: months[0] ? `${months[0].month} ${months[0].year}` : "Month 1", color: monthColors[0] },
    m1: { label: months[1] ? `${months[1].month} ${months[1].year}` : "Month 2", color: monthColors[1] },
    m2: { label: months[2] ? `${months[2].month} ${months[2].year}` : "Month 3", color: monthColors[2] },
  } satisfies ChartConfig;

  const chartRows = rows.map((row) => ({
    subDepartment: row.subDepartment,
    m0: row.monthlyCapacity[0] ?? 0,
    m1: row.monthlyCapacity[1] ?? 0,
    m2: row.monthlyCapacity[2] ?? 0,
  }));

  return (
    <div className="min-w-0">
      <p className="text-xs font-semibold">{title}</p>
      <p className="mb-2 text-xs text-muted-foreground">{subtitle}</p>
      {rows.length === 0 ? (
        <p className="text-sm text-muted-foreground">No sub-departments use this effort rule.</p>
      ) : (
        <ChartContainer config={config} className="aspect-auto w-full" style={{ height: Math.max(280, chartRows.length * 36 + 56) }}>
          <BarChart data={chartRows} layout="vertical" margin={{ left: 8, right: 16, top: 8 }}>
            <CartesianGrid horizontal={false} />
            <XAxis type="number" allowDecimals={false} tickLine={false} axisLine={false} />
            <YAxis type="category" dataKey="subDepartment" width={210} tickLine={false} axisLine={false} tick={{ fontSize: 10 }} />
            <ChartTooltip content={<ChartTooltipContent />} />
            <ChartLegend content={<ChartLegendContent />} />
            <Bar dataKey="m0" fill="var(--color-m0)" radius={4} />
            <Bar dataKey="m1" fill="var(--color-m1)" radius={4} />
            <Bar dataKey="m2" fill="var(--color-m2)" radius={4} />
          </BarChart>
        </ChartContainer>
      )}
    </div>
  );
}

function MonthTable({
  title,
  calendarDays,
  rows,
  monthIndex,
}: {
  title: string;
  calendarDays: number;
  rows: OffsiteCapacityRow[];
  monthIndex: number;
}) {
  return (
    <div>
      <p className="mb-2 text-xs font-semibold">{title}</p>
      <div className="overflow-x-auto">
        <table className="w-full min-w-[720px] text-sm">
          <thead>
            <tr className="border-b border-border text-xs text-muted-foreground">
              <th className="py-2 pr-3 text-left font-medium">Sub-department</th>
              <th className="px-2 py-2 text-right font-medium">TM</th>
              <th className="px-2 py-2 text-right font-medium">Effective Days</th>
              <th className="px-2 py-2 text-left font-medium">Effort</th>
              <th className="px-2 py-2 text-right font-medium">Monthly Capacity</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => {
              const tm = row.tm[monthIndex] ?? 0;
              const effective = row.effectiveDays[monthIndex] ?? 0;
              const capacity = row.monthlyCapacity[monthIndex];
              return (
                <tr key={row.subDepartment} className="border-b border-border last:border-0">
                  <td className="py-2 pr-3">{row.subDepartment}</td>
                  <td className="px-2 py-2 text-right tabular-nums">{formatCount(tm)}</td>
                  <td className="px-2 py-2 text-right tabular-nums">
                    {calendarDays} × {formatCount(tm)} = {formatCount(effective)}
                  </td>
                  <td className="px-2 py-2">{row.effort ?? "—"}</td>
                  <td className="px-2 py-2 text-right tabular-nums">{capacity == null ? "—" : formatCount(capacity)}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function formatCount(value: number) {
  return value.toLocaleString("en-IN");
}
