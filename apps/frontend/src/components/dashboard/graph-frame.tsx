import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from "react";
import { createPortal } from "react-dom";
import { Maximize2, X } from "lucide-react";
import { DashboardBarCallout } from "@/components/dashboard/dashboard-bar-callout";
import type { ChartConfig } from "@/components/ui/chart";

export function chartSeriesLabel(config: ChartConfig, dataKey: string): string {
  const label = config[dataKey]?.label;
  return typeof label === "string" ? label : dataKey;
}

/** Column charts: bars in one category stay together and fill that month's slot. */
export const columnBarChart = {
  barGap: 4,
  barCategoryGap: "10%",
} as const;

/** Row charts: month bars stay in a tight group beside each category. */
export const rowBarChart = {
  barGap: 2,
  barCategoryGap: "18%",
} as const;

const axisLabelStyle = { fontSize: 11, fill: "currentColor", textAnchor: "middle" as const };

export function xAxisLabel(value: string) {
  return { value, position: "insideBottom" as const, offset: -2, style: axisLabelStyle };
}

export function yAxisLabel(value: string) {
  return { value, angle: -90, position: "insideLeft" as const, offset: 4, style: axisLabelStyle };
}

const CHART_TIP_STYLE = `[data-chart-tip] .recharts-bar-rectangle,[data-month-chart] .recharts-bar-rectangle{cursor:default}
[data-chart-tip] .mis-dashboard-bar,[data-month-chart] .mis-dashboard-bar{cursor:pointer}
@keyframes graph-bar-grow-y{from{transform:scaleY(0)}to{transform:scaleY(1)}}
@keyframes graph-bar-grow-x{from{transform:scaleX(0)}to{transform:scaleX(1)}}
[data-graph-zoom] .recharts-bar-rectangle{transform-box:fill-box;transform-origin:50% 100%;animation:graph-bar-grow-y .8s ease-out both}
[data-graph-zoom] [data-bar-axis="x"] .recharts-bar-rectangle{transform-origin:0 50%;animation:graph-bar-grow-x .8s ease-out both}`;

const GraphZoomMotionContext = createContext(false);

/** True while the chart is drawn inside the expanded window, so those bars play their entrance animation. */
export function useGraphZoomMotion() {
  return useContext(GraphZoomMotionContext);
}

const TIP_BOX = { width: 220, height: 120, gap: 8 };

function clampTipPosition(x: number, y: number) {
  const { width, height } = TIP_BOX;
  return {
    x: Math.max(8, Math.min(x, window.innerWidth - width - 8)),
    y: Math.max(8, Math.min(y, window.innerHeight - height - 8)),
  };
}

/** Bar element from a Recharts bar mouse event. */
export function barRectFromEvent(event: unknown): DOMRect | null {
  if (!event || typeof event !== "object") return null;
  const native =
    "nativeEvent" in event && event.nativeEvent && typeof event.nativeEvent === "object"
      ? (event.nativeEvent as MouseEvent)
      : null;
  const target = native?.target ?? (event as MouseEvent).target;
  if (!(target instanceof Element)) return null;
  const hit =
    target.closest(".recharts-bar-rectangle") ??
    target.closest("rect") ??
    (target instanceof SVGGraphicsElement ? target : null);
  if (!(hit instanceof Element)) return null;
  const rect = hit.getBoundingClientRect();
  return rect.width > 0 || rect.height > 0 ? rect : null;
}

export type BarTipDetails = {
  rect: DOMRect;
  categoryKey: string;
  dataKey: string;
  seriesLabel: string;
  value: number;
  color: string;
};

export type BarTipAnchorContextValue = {
  tip: BarTipDetails | null;
  setTip: (tip: BarTipDetails | null) => void;
};

const BarTipAnchorContext = createContext<BarTipAnchorContextValue | null>(null);

export function useBarTipAnchor() {
  return useContext(BarTipAnchorContext);
}

/** Render prop: must be a direct child of `ChartDismiss`. */
export function DashboardChartBody({
  children,
}: {
  children: (anchor: BarTipAnchorContextValue) => ReactNode;
}) {
  const anchor = useBarTipAnchor();
  if (!anchor) return null;
  return <>{children(anchor)}</>;
}

export type BarTipPosition = {
  left: number;
  top: number;
};

/** Fixed-position tooltip anchored to a bar (not the pointer). */
export function placeBarTip(rect: DOMRect, placement: "above" | "right" = "above"): BarTipPosition {
  const { width, height, gap } = TIP_BOX;
  let x: number;
  let y: number;
  if (placement === "right") {
    x = rect.right + gap;
    y = rect.top + rect.height / 2 - height / 2;
  } else {
    x = rect.left + rect.width / 2 - width / 2;
    y = rect.top - height - gap;
  }
  const clamped = clampTipPosition(x, y);
  return { left: clamped.x, top: clamped.y };
}

/** Bottom of tooltip flush with the top of the bar (stacked horizontal segments). */
export function placeBarTipFlushAbove(rect: DOMRect): BarTipPosition {
  const centerX = rect.left + rect.width / 2;
  const halfW = TIP_BOX.width / 2;
  const left = Math.max(8 + halfW, Math.min(centerX, window.innerWidth - halfW - 8));
  return { left, top: rect.top };
}

/** Tooltip callout above the hovered bar (portal; works with custom bar shapes). */
export function DashboardBarTooltip() {
  const anchor = useBarTipAnchor();
  if (!anchor?.tip) return null;
  const { rect, categoryKey, seriesLabel, value, color } = anchor.tip;
  const { left, top } = placeBarTipFlushAbove(rect);
  return createPortal(
    <DashboardBarCallout left={left} top={top}>
      <p className="font-medium text-foreground">{categoryKey}</p>
      <p className="mt-1 flex items-center gap-2 text-foreground">
        <span className="h-2 w-2 shrink-0 rounded-[2px]" style={{ backgroundColor: color }} />
        <span>
          {seriesLabel}: {value.toLocaleString("en-IN")}
        </span>
      </p>
    </DashboardBarCallout>,
    document.body,
  );
}

/** Chart shell: pointer cursor on bars; pairs with `DashboardBarTooltip` + `useBarTipAnchor`. */
export function ChartDismiss({ children, onMouseLeave }: { children: ReactNode; onMouseLeave?: () => void }) {
  const [tip, setTip] = useState<BarTipDetails | null>(null);

  useEffect(() => {
    if (!document.getElementById("chart-tip-style")) {
      const style = document.createElement("style");
      style.id = "chart-tip-style";
      style.textContent = CHART_TIP_STYLE;
      document.head.appendChild(style);
    }
  }, []);

  const handleLeave = () => {
    setTip(null);
    onMouseLeave?.();
  };

  return (
    <BarTipAnchorContext.Provider value={{ tip, setTip }}>
      <div data-chart-tip="" onMouseLeave={handleLeave}>
        {children}
      </div>
      <DashboardBarTooltip />
    </BarTipAnchorContext.Provider>
  );
}

export function GraphZoom({ title, render }: { title: string; render: () => ReactNode }) {
  const [open, setOpen] = useState(false);
  const [ready, setReady] = useState(false);
  const bodyRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) {
      setReady(false);
      return;
    }
    let frame = 0;
    const measure = () => {
      const body = bodyRef.current;
      if (body && body.clientWidth > 80 && body.clientHeight > 80) {
        setReady(true);
        return;
      }
      frame = requestAnimationFrame(measure);
    };
    frame = requestAnimationFrame(measure);
    const onKey = (event: KeyboardEvent) => {
      if (event.key === "Escape") setOpen(false);
    };
    document.addEventListener("keydown", onKey);
    const previous = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      cancelAnimationFrame(frame);
      document.removeEventListener("keydown", onKey);
      document.body.style.overflow = previous;
    };
  }, [open]);

  return (
    <>
      <button
        type="button"
        aria-label={`Expand ${title}`}
        title="Expand"
        onClick={() => setOpen(true)}
        className="grid h-8 w-8 shrink-0 place-items-center rounded-md border border-border bg-card text-muted-foreground hover:bg-accent hover:text-foreground"
      >
        <Maximize2 className="h-4 w-4" />
      </button>
      {open &&
        createPortal(
          <div
            className="fixed inset-0 z-[80] flex items-center justify-center bg-black/70 p-4 sm:p-8"
            onMouseDown={() => setOpen(false)}
          >
            <div
              role="dialog"
              aria-modal="true"
              aria-label={title}
              className="flex max-h-[92vh] w-full max-w-6xl flex-col overflow-hidden rounded-xl border border-border bg-card shadow-2xl"
              onMouseDown={(event) => event.stopPropagation()}
            >
              <div className="flex items-center justify-between gap-3 border-b border-border px-5 py-3">
                <h3 className="text-sm font-semibold">{title}</h3>
                <button
                  type="button"
                  aria-label="Close"
                  onClick={() => setOpen(false)}
                  className="grid h-8 w-8 place-items-center rounded-md border border-border text-muted-foreground hover:bg-accent hover:text-foreground"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>
              <div ref={bodyRef} data-graph-zoom="" className="min-h-[68vh] flex-1 overflow-auto p-5 [&_[data-chart]]:!h-[68vh]">
                <GraphZoomMotionContext.Provider value={ready}>{ready ? render() : null}</GraphZoomMotionContext.Provider>
              </div>
            </div>
          </div>,
          document.body,
        )}
    </>
  );
}
