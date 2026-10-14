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
  fetchResignationCounts,
  type DashboardPeriod,
  type MisDashboardView,
  type ResignationCountRow,
  type ResignationCounts,
} from "@/lib/api/dashboard";

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
      <h3 className="text-sm font-semibold">Team Resignation Count – Onsite/Offsite ({dashboardPeriodLabel(period)})</h3>
      <p className="text-xs text-muted-foreground">Role counts for the selected period. Bond Free is bond status No. On Paper is a resignation in this period.</p>

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
  return (
    <div className="min-w-0 space-y-4">
      <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">{title}</p>
      {showChart && (
        <ChartContainer config={chartConfig} className="aspect-auto w-full" style={{ height: 320 }}>
          <BarChart data={rows} margin={{ left: 0, right: 8, top: 8, bottom: 8 }}>
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
            />
            <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={32} />
            <ChartTooltip content={<ChartTooltipContent />} />
            <ChartLegend content={<ChartLegendContent />} />
            <Bar dataKey="totalCount" fill="var(--color-totalCount)" radius={4} />
            <Bar dataKey="bondFree" fill="var(--color-bondFree)" radius={4} />
            <Bar dataKey="onPaper" fill="var(--color-onPaper)" radius={4} />
          </BarChart>
        </ChartContainer>
      )}
      {showTable && <RoleTable rows={rows} />}
    </div>
  );
}

function RoleTable({ rows }: { rows: ResignationCountRow[] }) {
  return (
    <div className="overflow-x-auto rounded-lg border border-amber-200">
      <table className="w-full min-w-[320px] text-sm">
        <thead>
          <tr className="bg-amber-300 text-xs text-amber-950">
            <th className="px-3 py-2 text-left font-semibold">Team Role</th>
            <th className="px-3 py-2 text-right font-semibold">Total Count</th>
            <th className="px-3 py-2 text-right font-semibold">Bond Free</th>
            <th className="px-3 py-2 text-right font-semibold">On Paper</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.role} className="border-t border-amber-100 bg-amber-50/70">
              <td className="px-3 py-2">{row.role}</td>
              <td className="px-3 py-2 text-right tabular-nums">{row.totalCount}</td>
              <td className="px-3 py-2 text-right tabular-nums">{row.bondFree}</td>
              <td className="px-3 py-2 text-right tabular-nums">{row.onPaper}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
