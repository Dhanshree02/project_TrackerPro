import { useEffect, useRef, useState } from "react";
import { Bar, BarChart, XAxis, YAxis } from "recharts";
import { ChartContainer, type ChartConfig } from "@/components/ui/chart";
import {
  getStackedSegmentShape,
  horizontalStackSegmentRadii,
  isMovingToAnotherBar,
  StackedBarHoverScope,
  useStackedBarHover,
} from "@/modules/dashboard/components/bar-emphasis";
import { DashboardBarCallout } from "@/modules/dashboard/components/dashboard-bar-callout";
import { barRectFromEvent, placeBarTipFlushAbove, useGraphZoomMotion, xAxisLabel, yAxisLabel } from "@/modules/dashboard/components/graph-frame";

const SEGMENT_COLORS = ["var(--chart-1)", "var(--chart-2)", "var(--chart-4)"];

const MONTH_NAMES: Record<string, string> = {
  Jan: "January",
  Feb: "February",
  Mar: "March",
  Apr: "April",
  May: "May",
  Jun: "June",
  Jul: "July",
  Aug: "August",
  Sep: "September",
  Oct: "October",
  Nov: "November",
  Dec: "December",
};

export type SegmentMonth = { month: string; year: number };

function monthLabel(month: SegmentMonth | undefined, index: number) {
  if (!month) return `Month ${index + 1}`;
  return `${month.month} ${month.year}`;
}

function fullMonthLabel(month: SegmentMonth | undefined, index: number) {
  if (!month) return `Month ${index + 1}`;
  return `${MONTH_NAMES[month.month] ?? month.month} ${month.year}`;
}

export function StackedMonthChart({
  rows,
  months,
  metric,
  formatValue,
  note,
  onPeerClear,
  resetSignal = 0,
  xLabel,
  yLabel,
}: {
  rows: Array<{ name: string; values: number[] }>;
  months: SegmentMonth[];
  metric: string;
  formatValue: (value: number) => string;
  note: string;
  onPeerClear?: () => void;
  /** Increment to clear hover when the paired chart is used. */
  resetSignal?: number;
  xLabel: string;
  yLabel?: string;
}) {
  const data = rows.map((row) => ({
    name: row.name,
    m0: row.values[0] ?? 0,
    m1: row.values[1] ?? 0,
    m2: row.values[2] ?? 0,
  }));
  const config = {
    m0: { label: monthLabel(months[0], 0), color: SEGMENT_COLORS[0] },
    m1: { label: monthLabel(months[1], 1), color: SEGMENT_COLORS[1] },
    m2: { label: monthLabel(months[2], 2), color: SEGMENT_COLORS[2] },
  } satisfies ChartConfig;
  const height = Math.max(220, rows.length * 36 + 28);
  const rootRef = useRef<HTMLDivElement>(null);
  const zoom = useGraphZoomMotion();
  const { hover, setHover, clear: clearHover } = useStackedBarHover();
  const [tip, setTip] = useState<{
    name: string;
    monthIndex: number;
    value: number;
    left: number;
    top: number;
  } | null>(null);
  const [intro, setIntro] = useState(true);

  useEffect(() => {
    const id = window.setTimeout(() => setIntro(false), 900);
    return () => window.clearTimeout(id);
  }, []);

  useEffect(() => {
    const onScroll = () => {
      setTip(null);
      clearHover();
    };
    document.addEventListener("scroll", onScroll, true);
    return () => document.removeEventListener("scroll", onScroll, true);
  }, [clearHover]);

  useEffect(() => {
    setTip(null);
    clearHover();
  }, [resetSignal, clearHover]);

  const leaveChart = () => {
    setTip(null);
    clearHover();
  };

  const openFromBar = (monthIndex: number, row: (typeof data)[number], event: unknown) => {
    onPeerClear?.();
    const rowKey = row.name;
    setHover({ rowKey, monthIndex });
    const value = monthIndex === 1 ? row.m1 : monthIndex === 2 ? row.m2 : row.m0;
    const rect = barRectFromEvent(event);
    if (!rect) return;
    const { left, top } = placeBarTipFlushAbove(rect);
    setTip({ name: row.name, monthIndex, value, left, top });
  };

  return (
    <div ref={rootRef} data-month-chart="" data-bar-axis="x" className="min-w-0">
      <div className="mb-2 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-muted-foreground">
        {months.map((month, index) => (
          <span key={monthLabel(month, index)} className="inline-flex items-center gap-1.5">
            <span className="h-2.5 w-2.5 rounded-[2px]" style={{ background: SEGMENT_COLORS[index] }} />
            {monthLabel(month, index)}
          </span>
        ))}
      </div>
      <StackedBarHoverScope hover={hover}>
      <ChartContainer
        config={config}
        className="aspect-auto w-full"
        style={{ height }}
        onMouseLeave={leaveChart}
      >
        <BarChart
          data={data}
          layout="vertical"
          margin={{ left: yLabel ? 28 : 8, right: 16, top: 4, bottom: 28 }}
          barCategoryGap="28%"
          barSize={16}
        >
          <XAxis type="number" allowDecimals={false} tickLine={false} axisLine={false} tick={{ fontSize: 11 }} label={xAxisLabel(xLabel)} />
          <YAxis
            type="category"
            dataKey="name"
            width={188}
            tickLine={false}
            axisLine={false}
            tick={{ fontSize: 11 }}
            label={yLabel ? yAxisLabel(yLabel) : undefined}
          />
          {[0, 1, 2].map((index) => (
            <Bar
              key={index}
              dataKey={`m${index}`}
              stackId="months"
              fill={SEGMENT_COLORS[index]}
              shape={getStackedSegmentShape(index, SEGMENT_COLORS[index], months.length || 3)}
              radius={horizontalStackSegmentRadii(index, months.length || 3)}
              isAnimationActive={!zoom && intro}
              animationDuration={800}
              onMouseEnter={(entry, _rowIndex, e) => {
                if (!entry || typeof entry !== "object" || !("name" in entry)) return;
                openFromBar(index, entry as (typeof data)[number], e);
              }}
              onMouseMove={(entry, _rowIndex, e) => {
                if (!entry || typeof entry !== "object" || !("name" in entry)) return;
                openFromBar(index, entry as (typeof data)[number], e);
              }}
              onMouseLeave={(_entry, _rowIndex, e) => {
                if (isMovingToAnotherBar(e)) return;
                setTip(null);
                clearHover();
              }}
            />
          ))}
        </BarChart>
      </ChartContainer>
      </StackedBarHoverScope>
      <p className="mt-2 text-[11px] leading-4 text-muted-foreground">{note}</p>
      {tip && (
        <DashboardBarCallout left={tip.left} top={tip.top}>
          <p className="font-medium text-foreground">{tip.name}</p>
          <p className="mt-1 text-muted-foreground">{fullMonthLabel(months[tip.monthIndex], tip.monthIndex)}</p>
          <p className="mt-1 text-foreground">
            {metric}: {formatValue(tip.value)}
          </p>
        </DashboardBarCallout>
      )}
    </div>
  );
}
