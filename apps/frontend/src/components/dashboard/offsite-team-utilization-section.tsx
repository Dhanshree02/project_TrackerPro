import { useEffect, useState } from "react";
import {
  dashboardPeriodLabel,
  fetchOffsiteTeamUtilization,
  type DashboardPeriod,
  type MisDashboardView,
  type OffsiteTeamUtilization,
} from "@/lib/api/dashboard";
import { GraphZoom } from "@/components/dashboard/graph-frame";
import {
  misGroupEdge,
  misRow,
  misTable,
  misTableScroll,
  misTdLabel,
  misTdNumber,
  misThGroup,
  misThLabel,
  misThNumber,
} from "@/components/dashboard/dashboard-table";
import { StackedMonthChart } from "@/components/dashboard/segmented-month-chart";

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
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-sm font-semibold">Team Utilization – Offsite</h3>
          <p className="text-xs text-muted-foreground">Offsite team strength and timesheet utilization by employee sub-department</p>
        </div>
        {showChart && data && data.departments.length > 0 && (
          <GraphZoom title="Team Utilization – Offsite" render={() => <OffsiteCharts chartRows={chartRows} months={months} />} />
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

      {!loading && !error && data && data.departments.length === 0 && (
        <p className="mt-4 text-sm text-muted-foreground">No offsite employees for {dashboardPeriodLabel(period)}.</p>
      )}

      {!loading && !error && data && data.departments.length > 0 && (
        <div className="mt-4 space-y-6">
          {showChart && <OffsiteCharts chartRows={chartRows} months={months} />}

          {showTable && (
            <div className={misTableScroll}>
              <table className={`${misTable} min-w-[720px]`}>
                <thead>
                  <tr>
                    <th rowSpan={2} className={`${misThLabel} bg-blue-50 text-blue-900 dark:bg-blue-950/80 dark:text-blue-100`}>Department</th>
                    <th colSpan={months.length || 3} className={`${misThGroup} border-b border-blue-200 bg-blue-100 text-blue-950 dark:border-blue-800 dark:bg-blue-900 dark:text-blue-50`}>Team Strength</th>
                    <th colSpan={months.length || 3} className={`${misThGroup} ${misGroupEdge} border-b border-blue-200 bg-blue-100 text-blue-950 dark:border-blue-800 dark:bg-blue-900 dark:text-blue-50`}>Team Utilization %</th>
                  </tr>
                  <tr>
                    {months.map((month) => (
                      <th key={`s-${month.month}`} className={`${misThNumber} bg-blue-100 text-blue-950 dark:bg-blue-900 dark:text-blue-50`}>{month.month}</th>
                    ))}
                    {months.map((month, index) => (
                      <th key={`u-${month.month}`} className={`${misThNumber} bg-blue-100 text-blue-950 dark:bg-blue-900 dark:text-blue-50${index === 0 ? ` ${misGroupEdge}` : ""}`}>{month.month}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {data.departments.map((row) => (
                    <tr key={row.department} className={misRow}>
                      <td className={misTdLabel} title={row.department}>{row.department}</td>
                      {months.map((month, index) => (
                        <td key={`s-${month.month}`} className={misTdNumber}>
                          {row.teamStrength[index] ?? 0}
                        </td>
                      ))}
                      {months.map((month, index) => (
                        <td key={`u-${month.month}`} className={index === 0 ? `${misTdNumber} ${misGroupEdge}` : misTdNumber}>
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

function OffsiteCharts({
  chartRows,
  months,
}: {
  chartRows: Array<{
    department: string;
    s0: number;
    s1: number;
    s2: number;
    u0: number;
    u1: number;
    u2: number;
  }>;
  months: OffsiteTeamUtilization["months"];
}) {
  const monthKey = months.map((month) => `${month.month}-${month.year}`).join("|");
  const [selected, setSelected] = useState<number | null>(null);
  useEffect(() => {
    setSelected(null);
  }, [monthKey]);

  const strengthRows = chartRows.map((row) => ({ name: row.department, values: [row.s0, row.s1, row.s2] }));
  const utilizationRows = chartRows.map((row) => ({ name: row.department, values: [row.u0, row.u1, row.u2] }));

  return (
    <div className="grid gap-6 xl:grid-cols-2">
      <div className="min-w-0">
        <p className="mb-2 text-xs font-medium text-muted-foreground">Team Strength</p>
        <StackedMonthChart
          rows={strengthRows}
          months={months}
          metric="Team strength"
          formatValue={(value) => value.toLocaleString("en-IN")}
          note="Each colored piece is that month's offsite headcount. The pieces sit side by side, so the full bar is not a combined team size."
          xLabel="Team strength"
          selected={selected}
          onSelect={setSelected}
        />
      </div>
      <div className="min-w-0">
        <p className="mb-2 text-xs font-medium text-muted-foreground">Team Utilization %</p>
        <StackedMonthChart
          rows={utilizationRows}
          months={months}
          metric="Team utilization"
          formatValue={(value) => `${value}%`}
          note="Each colored piece is that month's utilization percentage. The pieces sit side by side, so the full bar is not one combined utilization percentage."
          xLabel="Utilization %"
          selected={selected}
          onSelect={setSelected}
        />
      </div>
    </div>
  );
}
