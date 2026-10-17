import { useEffect, useRef, useState } from "react";
import { Bar, BarChart, XAxis, YAxis } from "recharts";
import { ChartContainer, type ChartConfig } from "@/components/ui/chart";
import { placeCursorTip, useGraphZoomMotion, xAxisLabel, yAxisLabel } from "@/components/dashboard/graph-frame";

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
  selected,
  onSelect,
  xLabel,
  yLabel,
}: {
  rows: Array<{ name: string; values: number[] }>;
  months: SegmentMonth[];
  metric: string;
  formatValue: (value: number) => string;
  note: string;
  selected: number | null;
  onSelect: (index: number | null) => void;
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
  const [tip, setTip] = useState<{ name: string; monthIndex: number; value: number; x: number; y: number } | null>(null);
  const [intro, setIntro] = useState(true);

  useEffect(() => {
    const id = window.setTimeout(() => setIntro(false), 900);
    return () => window.clearTimeout(id);
  }, []);

  useEffect(() => {
    const onPointerDown = (event: PointerEvent) => {
      const root = rootRef.current;
      const target = event.target;
      if (!root || !(target instanceof Node) || root.contains(target)) return;
      setTip(null);
      if (!(target instanceof Element) || !target.closest("[data-month-chart]")) onSelect(null);
    };
    document.addEventListener("pointerdown", onPointerDown, true);
    const onScroll = () => setTip(null);
    document.addEventListener("scroll", onScroll, true);
    return () => {
      document.removeEventListener("pointerdown", onPointerDown, true);
      document.removeEventListener("scroll", onScroll, true);
    };
  }, [onSelect]);

  const choose = (index: number) => {
    onSelect(selected === index ? null : index);
    setTip(null);
  };

  const openTip = (index: number, name: string, value: number, x: number, y: number) => {
    setTip({ name, monthIndex: index, value, x, y });
    onSelect(index);
  };

  const openFromClick = (event: { clientX: number; clientY: number; target: EventTarget | null }) => {
    const root = rootRef.current;
    if (!root) return;
    if (event.target instanceof Element && event.target.closest("button")) return;
    const paths = [...root.querySelectorAll<SVGGraphicsElement>(".recharts-bar-rectangle path")];
    const hit = paths.findIndex((path) => {
      const box = path.getBoundingClientRect();
      return (
        event.clientX >= box.left - 4 &&
        event.clientX <= box.right + 4 &&
        event.clientY >= box.top - 8 &&
        event.clientY <= box.bottom + 8
      );
    });
    if (hit >= 0 && data.length > 0) {
      const monthIndex = Math.min(2, Math.floor(hit / data.length));
      const row = data[hit % data.length];
      if (!row) return;
      const value = monthIndex === 1 ? row.m1 : monthIndex === 2 ? row.m2 : row.m0;
      openTip(monthIndex, row.name, value, event.clientX, event.clientY);
      return;
    }
    const ticks = [...root.querySelectorAll(".recharts-yAxis .recharts-cartesian-axis-tick")];
    let closest: { name: string; dist: number } | null = null;
    for (const tick of ticks) {
      const box = tick.getBoundingClientRect();
      const dist = Math.abs(event.clientY - (box.top + box.height / 2));
      const name = tick.querySelector("text")?.textContent?.trim() ?? "";
      if (!closest || dist < closest.dist) closest = { name, dist };
    }
    if (!closest || closest.dist > 40) return;
    const compact = (value: string) => value.replace(/\s+/g, "").toLowerCase();
    const row = data.find((item) => compact(item.name) === compact(closest.name));
    if (!row) return;
    const surface = root.querySelector(".recharts-cartesian-grid") ?? root.querySelector(".recharts-surface");
    if (!surface) return;
    const box = surface.getBoundingClientRect();
    const ratio = (event.clientX - box.left) / Math.max(box.width, 1);
    const monthIndex = Math.min(2, Math.max(0, Math.floor(ratio * 3)));
    const value = monthIndex === 1 ? row.m1 : monthIndex === 2 ? row.m2 : row.m0;
    openTip(monthIndex, row.name, value, event.clientX, event.clientY);
  };

  return (
    <div ref={rootRef} data-month-chart="" data-bar-axis="x" className="min-w-0" onClick={openFromClick}>
      <div className="mb-2 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs">
        {months.map((month, index) => {
          const active = selected === null || selected === index;
          return (
            <button
              key={monthLabel(month, index)}
              type="button"
              onClick={() => choose(index)}
              className={`inline-flex items-center gap-1.5 rounded-md px-1.5 py-0.5 transition-opacity ${
                selected === index ? "bg-accent font-semibold text-foreground" : "text-muted-foreground"
              }`}
              style={{ opacity: active ? 1 : 0.4 }}
            >
              <span className="h-2.5 w-2.5 rounded-[2px]" style={{ background: SEGMENT_COLORS[index] }} />
              {monthLabel(month, index)}
            </button>
          );
        })}
      </div>
      {selected !== null && (
        <p className="mb-2 text-xs font-medium text-foreground">Selected: {fullMonthLabel(months[selected], selected)}</p>
      )}
      <ChartContainer config={config} className="aspect-auto w-full" style={{ height }}>
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
              fillOpacity={selected === null || selected === index ? 1 : 0.28}
              radius={0}
              isAnimationActive={!zoom && intro}
              animationDuration={800}
              cursor="pointer"
            />
          ))}
        </BarChart>
      </ChartContainer>
      <p className="mt-2 text-[11px] leading-4 text-muted-foreground">{note}</p>
      {tip && (
        <div
          className="pointer-events-none fixed z-[90] min-w-40 rounded-lg border border-border bg-card px-3 py-2 text-xs shadow-lg"
          style={{ left: placeCursorTip(tip.x, tip.y).x, top: placeCursorTip(tip.x, tip.y).y }}
        >
          <p className="font-medium text-foreground">{tip.name}</p>
          <p className="mt-1 text-muted-foreground">{fullMonthLabel(months[tip.monthIndex], tip.monthIndex)}</p>
          <p className="mt-1 text-foreground">
            {metric}: {formatValue(tip.value)}
          </p>
        </div>
      )}
    </div>
  );
}
