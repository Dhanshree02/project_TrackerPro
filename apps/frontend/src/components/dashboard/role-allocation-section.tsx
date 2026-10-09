import { useEffect, useState } from "react";
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
  fetchRoleAllocation,
  type DashboardQuarter,
  type RoleAllocation,
} from "@/lib/api/dashboard";

const onsiteChartConfig = {
  onsiteTm: { label: "Onsite TM", color: "var(--chart-1)" },
  onsiteLeads: { label: "Onsite Leads", color: "var(--chart-5)" },
} satisfies ChartConfig;

export function RoleAllocationSection({ quarter }: { quarter: DashboardQuarter }) {
  const [data, setData] = useState<RoleAllocation | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);
    setData(null);

    fetchRoleAllocation(quarter, controller.signal)
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
  }, [quarter, reloadKey]);

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
      <h3 className="text-sm font-semibold">Team Allocation Onsite/Offsite ({quarter})</h3>
      <p className="text-xs text-muted-foreground">Role wise count</p>

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
          <div className="min-w-0 space-y-4">
            <div className="overflow-x-auto">
              <table className="w-full min-w-[280px] text-sm">
                <thead>
                  <tr className="border-b border-border text-xs text-muted-foreground">
                    <th className="py-2 pr-3 text-left font-medium">Role Wise Count</th>
                    {months.map((month) => (
                      <th key={month.month} className="px-2 py-2 text-right font-medium">
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  <tr className="border-b border-border">
                    <td className="py-2 pr-3">Onsite TM</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        {month.onsiteTm}
                      </td>
                    ))}
                  </tr>
                  <tr>
                    <td className="py-2 pr-3">Onsite Leads</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        {month.onsiteLeads}
                      </td>
                    ))}
                  </tr>
                </tbody>
              </table>
            </div>
            <ChartContainer config={onsiteChartConfig} className="aspect-auto h-[260px] w-full">
              <BarChart data={months} margin={{ left: 0, right: 8, top: 16 }}>
                <CartesianGrid vertical={false} />
                <XAxis dataKey="month" tickLine={false} axisLine={false} />
                <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={32} />
                <ChartTooltip content={<ChartTooltipContent />} />
                <ChartLegend content={<ChartLegendContent />} />
                <Bar dataKey="onsiteTm" fill="var(--color-onsiteTm)" radius={4}>
                  <LabelList dataKey="onsiteTm" position="top" className="fill-foreground" fontSize={10} />
                </Bar>
                <Bar dataKey="onsiteLeads" fill="var(--color-onsiteLeads)" radius={4}>
                  <LabelList dataKey="onsiteLeads" position="top" className="fill-foreground" fontSize={10} />
                </Bar>
              </BarChart>
            </ChartContainer>
          </div>

          <div className="min-w-0 space-y-4">
            <div className="overflow-x-auto">
              <table className="w-full min-w-[280px] text-sm">
                <thead>
                  <tr className="border-b border-border text-xs text-muted-foreground">
                    <th className="py-2 pr-3 text-left font-medium">Role Wise Count</th>
                    {months.map((month) => (
                      <th key={month.month} className="px-2 py-2 text-right font-medium">
                        {month.month}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  <tr className="border-b border-border">
                    <td className="py-2 pr-3">Offsite - TM</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        {month.offsiteTm}
                      </td>
                    ))}
                  </tr>
                  <tr className="border-b border-border">
                    <td className="py-2 pr-3">Offsite - Leads</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        {month.offsiteLeads}
                      </td>
                    ))}
                  </tr>
                  <tr>
                    <td className="py-2 pr-3">Offsite - PM</td>
                    {months.map((month) => (
                      <td key={month.month} className="px-2 py-2 text-right tabular-nums">
                        {month.offsitePm}
                      </td>
                    ))}
                  </tr>
                </tbody>
              </table>
            </div>
            <ChartContainer config={offsiteChartConfig} className="aspect-auto h-[280px] w-full">
              <BarChart data={offsiteChartData} margin={{ left: 0, right: 8, top: 16 }}>
                <CartesianGrid vertical={false} />
                <XAxis dataKey="role" tickLine={false} axisLine={false} interval={0} tick={{ fontSize: 11 }} />
                <YAxis allowDecimals={false} tickLine={false} axisLine={false} width={32} />
                <ChartTooltip content={<ChartTooltipContent />} />
                <ChartLegend content={<ChartLegendContent />} />
                <Bar dataKey="m0" fill="var(--color-m0)" radius={4}>
                  <LabelList dataKey="m0" position="top" className="fill-foreground" fontSize={10} />
                </Bar>
                <Bar dataKey="m1" fill="var(--color-m1)" radius={4}>
                  <LabelList dataKey="m1" position="top" className="fill-foreground" fontSize={10} />
                </Bar>
                <Bar dataKey="m2" fill="var(--color-m2)" radius={4}>
                  <LabelList dataKey="m2" position="top" className="fill-foreground" fontSize={10} />
                </Bar>
              </BarChart>
            </ChartContainer>
          </div>
        </div>
      )}
    </article>
  );
}
