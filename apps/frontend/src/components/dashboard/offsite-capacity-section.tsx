import { useEffect, useState } from "react";
import {
  dashboardPeriodLabel,
  fetchOffsiteCapacity,
  type DashboardPeriod,
  type MisDashboardView,
  type OffsiteCapacity,
  type OffsiteCapacityRow,
} from "@/lib/api/dashboard";
import { GraphZoom } from "@/components/dashboard/graph-frame";
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
import { StackedMonthChart } from "@/components/dashboard/segmented-month-chart";

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
  const monthKey = months.map((month) => `${month.month}-${month.year}`).join("|");
  const [appReset, setAppReset] = useState(0);
  const [ipReset, setIpReset] = useState(0);
  useEffect(() => {
    setAppReset((n) => n + 1);
    setIpReset((n) => n + 1);
  }, [monthKey]);
  const appRows = departments.filter((row) => row.capacityUnit === "apps");
  const ipRows = departments.filter((row) => row.capacityUnit === "ips");

  return (
    <article className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h3 className="text-sm font-semibold">Team Capacity – Offsite ({dashboardPeriodLabel(period)})</h3>
          <p className="text-xs text-muted-foreground">
            Offsite employees by sub-department. Effective days are {data?.calendarDays ?? 21} × TM.
          </p>
        </div>
        {!loading && !error && data && showChart && departments.length > 0 && (
          <GraphZoom
            title={`Team Capacity – Offsite (${dashboardPeriodLabel(period)})`}
            render={() => (
              <div className="grid gap-6 xl:grid-cols-2">
                <CapacityChart title="Application capacity" subtitle="7 days per app" rows={appRows} months={months} resetSignal={appReset} onPeerClear={() => setIpReset((n) => n + 1)} />
                <CapacityChart title="IP capacity" subtitle="10 IPs per day" rows={ipRows} months={months} resetSignal={ipReset} onPeerClear={() => setAppReset((n) => n + 1)} />
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
                resetSignal={appReset}
                onPeerClear={() => setIpReset((n) => n + 1)}
              />
              <CapacityChart
                title="IP capacity"
                subtitle="10 IPs per day"
                rows={ipRows}
                months={months}
                resetSignal={ipReset}
                onPeerClear={() => setAppReset((n) => n + 1)}
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
  resetSignal,
  onPeerClear,
}: {
  title: string;
  subtitle: string;
  rows: OffsiteCapacityRow[];
  months: OffsiteCapacity["months"];
  resetSignal?: number;
  onPeerClear?: () => void;
}) {
  const chartRows = rows.map((row) => ({
    name: row.subDepartment,
    values: row.monthlyCapacity.map((value) => value ?? 0),
  }));
  const metric = title.toLowerCase().includes("ip") ? "IP capacity" : "Application capacity";

  return (
    <div className="min-w-0">
      <p className="text-xs font-semibold">{title}</p>
      <p className="mb-2 text-xs text-muted-foreground">{subtitle}</p>
      {rows.length === 0 ? (
        <p className="text-sm text-muted-foreground">No sub-departments use this effort rule.</p>
      ) : (
        <StackedMonthChart
          rows={chartRows}
          months={months}
          metric={metric}
          formatValue={(value) => value.toLocaleString("en-IN")}
          note={
            metric === "IP capacity"
              ? "Each colored piece is that month's IP capacity. The pieces sit side by side, so the full bar is not one month's capacity."
              : "Each colored piece is that month's application capacity. The pieces sit side by side, so the full bar is not one month's capacity."
          }
          xLabel={metric === "IP capacity" ? "IP capacity" : "Application capacity"}
          resetSignal={resetSignal}
          onPeerClear={onPeerClear}
        />
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
      <div className={misTableScroll}>
        <table className={`${misTable} min-w-[720px]`}>
          <thead>
            <tr className={misHeadRow}>
              <th className={misThLabel}>Sub-department</th>
              <th className={misThNumber}>TM</th>
              <th className={misThNumber}>Effective Days</th>
              <th className={misThLabel}>Effort</th>
              <th className={misThNumber}>Monthly Capacity</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => {
              const tm = row.tm[monthIndex] ?? 0;
              const effective = row.effectiveDays[monthIndex] ?? 0;
              const capacity = row.monthlyCapacity[monthIndex];
              return (
                <tr key={row.subDepartment} className={misRow}>
                  <td className={misTdLabel} title={row.subDepartment}>{row.subDepartment}</td>
                  <td className={misTdNumber}>{formatCount(tm)}</td>
                  <td className={misTdNumber}>
                    {calendarDays} × {formatCount(tm)} = {formatCount(effective)}
                  </td>
                  <td className={misTdLabel}>{row.effort ?? "—"}</td>
                  <td className={misTdNumber}>{capacity == null ? "—" : formatCount(capacity)}</td>
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
