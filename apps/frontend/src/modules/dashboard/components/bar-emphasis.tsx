import { createContext, useCallback, useContext, useState, type ReactElement, type ReactNode } from "react";
import type { BarProps, RectangleProps } from "recharts";
import { barRectFromEvent, type BarTipAnchorContextValue } from "@/modules/dashboard/components/graph-frame";
import { LEGEND_BAR_LAYOUT_MS } from "@/modules/dashboard/components/toggle-chart-legend";

type BarActiveShape = (props: unknown) => ReactElement;

/** Stacked chart: active month/series index; rowKey identifies the segment under the pointer. */
export type StackedHoverCell = { rowKey: string; monthIndex: number };

/** Grouped chart: active metric series (dataKey); categoryKey identifies the bar under the pointer. */
export type ColumnHoverCell = { categoryKey: string; dataKey: string };

/** Non-active series keep their hue but appear lighter (not grey). */
const INACTIVE_SERIES_OPACITY = 0.38;

const ColumnBarHoverContext = createContext<ColumnHoverCell | null>(null);
const StackedBarHoverContext = createContext<StackedHoverCell | null>(null);

export function ColumnBarHoverScope({ hover, children }: { hover: ColumnHoverCell | null; children: ReactNode }) {
  return <ColumnBarHoverContext.Provider value={hover}>{children}</ColumnBarHoverContext.Provider>;
}

export function StackedBarHoverScope({ hover, children }: { hover: StackedHoverCell | null; children: ReactNode }) {
  return <StackedBarHoverContext.Provider value={hover}>{children}</StackedBarHoverContext.Provider>;
}

export function useStackedBarHover() {
  const [hover, setHover] = useState<StackedHoverCell | null>(null);
  const clear = useCallback(() => setHover(null), []);
  return { hover, setHover, clear };
}

export function useColumnBarHover() {
  const [hover, setHover] = useState<ColumnHoverCell | null>(null);
  const clear = useCallback(() => setHover(null), []);
  return { hover, setHover, clear };
}

export function categoryKeyFromPayload(payload: Record<string, unknown> | undefined): string {
  if (!payload) return "";
  const raw =
    payload.month ?? payload.name ?? payload.role ?? payload.projectName ?? payload.department ?? payload.label;
  return raw != null ? String(raw) : "";
}

type ShapeProps = RectangleProps & { payload?: Record<string, unknown> };

/** Position only — do not animate height/width (that reads as bars “dropping” before hide). */
const LAYOUT_TRANSITION = `transform ${LEGEND_BAR_LAYOUT_MS}ms ease-out`;

export const HORIZONTAL_STACK_BAR_RADIUS = 4;

/** [topLeft, topRight, bottomRight, bottomLeft] for `layout="vertical"` horizontal bars. */
export function horizontalStackSegmentRadii(
  segmentIndex: number,
  segmentCount = 3,
): [number, number, number, number] {
  const r = HORIZONTAL_STACK_BAR_RADIUS;
  if (segmentCount <= 1) return [r, r, r, r];
  if (segmentIndex <= 0) return [r, 0, 0, r];
  if (segmentIndex >= segmentCount - 1) return [0, r, r, 0];
  return [0, 0, 0, 0];
}

function readStackSegmentValues(payload: Record<string, unknown> | undefined, segmentCount: number) {
  return Array.from({ length: segmentCount }, (_, i) => {
    const raw = payload?.[`m${i}`];
    const n = typeof raw === "number" ? raw : Number(raw ?? 0);
    return Number.isFinite(n) ? n : 0;
  });
}

/** Outer caps follow the first/last month with data on that row (Team Utilization %, etc.). */
export function horizontalStackSegmentRadiiForPayload(
  segmentIndex: number,
  payload: Record<string, unknown> | undefined,
  segmentCount = 3,
): [number, number, number, number] {
  const values = readStackSegmentValues(payload, segmentCount);
  if (values[segmentIndex]! <= 0) return [0, 0, 0, 0];

  let first = -1;
  let last = -1;
  for (let i = 0; i < segmentCount; i++) {
    if (values[i]! > 0) {
      if (first < 0) first = i;
      last = i;
    }
  }
  if (first < 0) return [0, 0, 0, 0];

  const r = HORIZONTAL_STACK_BAR_RADIUS;
  if (first === last) return [r, r, r, r];
  if (segmentIndex === first) return [r, 0, 0, r];
  if (segmentIndex === last) return [0, r, r, 0];
  return [0, 0, 0, 0];
}

function capCornerRadii(
  w: number,
  h: number,
  [tl, tr, br, bl]: [number, number, number, number],
): [number, number, number, number] {
  const max = Math.min(w, h) / 2;
  return [Math.min(tl, max), Math.min(tr, max), Math.min(br, max), Math.min(bl, max)];
}

function roundedRectPath(w: number, h: number, radii: [number, number, number, number]): string {
  if (w <= 0 || h <= 0) return "";
  const [tl, tr, br, bl] = capCornerRadii(w, h, radii);
  if (tl + tr + br + bl === 0) return `M 0,0 H ${w} V ${h} H 0 Z`;

  return [
    `M ${tl},0`,
    `H ${w - tr}`,
    tr > 0 ? `A ${tr},${tr} 0 0 1 ${w},${tr}` : `L ${w},0`,
    `V ${h - br}`,
    br > 0 ? `A ${br},${br} 0 0 1 ${w - br},${h}` : `L ${w},${h}`,
    `H ${bl}`,
    bl > 0 ? `A ${bl},${bl} 0 0 1 0,${h - bl}` : `L 0,${h}`,
    `V ${tl}`,
    tl > 0 ? `A ${tl},${tl} 0 0 1 ${tl},0` : `L 0,0`,
    "Z",
  ].join(" ");
}

function MisBarRect({
  x,
  y,
  width,
  height,
  color,
  radius,
  cornerRadii,
  dim,
}: {
  x: number;
  y: number;
  width: number;
  height: number;
  color: string;
  radius: number;
  cornerRadii?: [number, number, number, number];
  dim: boolean;
}) {
  const w = Math.max(width, 0);
  const h = Math.max(height, 0);
  const paintStyle = {
    cursor: "pointer" as const,
    fillOpacity: dim ? INACTIVE_SERIES_OPACITY : 1,
  };

  return (
    <g style={{ transform: `translate(${x}px, ${y}px)`, transition: LAYOUT_TRANSITION }}>
      {cornerRadii ? (
        <path
          className="mis-dashboard-bar"
          d={roundedRectPath(w, h, cornerRadii)}
          fill={color}
          pointerEvents="visiblePainted"
          style={paintStyle}
        />
      ) : (
        <rect
          className="mis-dashboard-bar"
          x={0}
          y={0}
          width={w}
          height={h}
          fill={color}
          rx={radius}
          ry={radius}
          pointerEvents="visiblePainted"
          style={paintStyle}
        />
      )}
    </g>
  );
}

const columnShapeCache = new Map<string, BarActiveShape>();
const rowShapeCache = new Map<string, BarActiveShape>();
const stackedShapeCache = new Map<string, BarActiveShape>();

function createColumnBarShape(dataKey: string, color: string, radius: number): BarActiveShape {
  function ColumnBarShapeView(props: unknown) {
    const hover = useContext(ColumnBarHoverContext);
    const { x = 0, y = 0, width = 0, height = 0 } = props as ShapeProps;
    const seriesActive = hover === null || hover.dataKey === dataKey;
    const dim = hover !== null && !seriesActive;

    return (
      <MisBarRect x={x} y={y} width={width} height={height} color={color} radius={radius} dim={dim} />
    );
  }
  ColumnBarShapeView.displayName = `ColumnBar_${dataKey}`;
  return ColumnBarShapeView;
}

function createRowBarShape(dataKey: string, color: string, radius: number): BarActiveShape {
  function RowBarShapeView(props: unknown) {
    const hover = useContext(ColumnBarHoverContext);
    const { x = 0, y = 0, width = 0, height = 0 } = props as ShapeProps;
    const seriesActive = hover === null || hover.dataKey === dataKey;
    const dim = hover !== null && !seriesActive;

    return (
      <MisBarRect x={x} y={y} width={width} height={height} color={color} radius={radius} dim={dim} />
    );
  }
  RowBarShapeView.displayName = `RowBar_${dataKey}`;
  return RowBarShapeView;
}

function createStackedSegmentShape(monthIndex: number, color: string, segmentCount: number): BarActiveShape {
  function StackedSegmentShapeView(props: unknown) {
    const hover = useContext(StackedBarHoverContext);
    const { x = 0, y = 0, width = 0, height = 0, payload } = props as ShapeProps;
    const seriesActive = hover === null || hover.monthIndex === monthIndex;
    const dim = hover !== null && !seriesActive;
    const cornerRadii = horizontalStackSegmentRadiiForPayload(monthIndex, payload, segmentCount);

    return (
      <MisBarRect
        x={x}
        y={y}
        width={width}
        height={height}
        color={color}
        radius={0}
        cornerRadii={cornerRadii}
        dim={dim}
      />
    );
  }
  StackedSegmentShapeView.displayName = `StackedBar_m${monthIndex}`;
  return StackedSegmentShapeView;
}

function cachedShape(
  cache: Map<string, BarActiveShape>,
  key: string,
  factory: () => BarActiveShape,
): BarActiveShape {
  let shape = cache.get(key);
  if (!shape) {
    shape = factory();
    cache.set(key, shape);
  }
  return shape;
}

/** Stable shape reference so Recharts keeps the same DOM rects (CSS transitions can run on exit). */
export function getColumnBarShape(dataKey: string, color: string, radius = 4): BarActiveShape {
  return cachedShape(columnShapeCache, `${dataKey}\0${color}\0${radius}`, () =>
    createColumnBarShape(dataKey, color, radius),
  );
}

export function getRowBarShape(dataKey: string, color: string, radius = 4): BarActiveShape {
  return cachedShape(rowShapeCache, `${dataKey}\0${color}\0${radius}`, () => createRowBarShape(dataKey, color, radius));
}

export function getStackedSegmentShape(monthIndex: number, color: string, segmentCount = 3): BarActiveShape {
  return cachedShape(stackedShapeCache, `${monthIndex}\0${color}\0${segmentCount}`, () =>
    createStackedSegmentShape(monthIndex, color, segmentCount),
  );
}

/** @deprecated Use getStackedSegmentShape inside StackedBarHoverScope. */
export function stackedSegmentShape(monthIndex: number, hover: StackedHoverCell | null, color: string): BarActiveShape {
  void hover;
  return getStackedSegmentShape(monthIndex, color);
}

/** True when pointer left one bar but entered another (avoid clearing highlight between bars). */
export function isMovingToAnotherBar(event: unknown): boolean {
  if (!event || typeof event !== "object") return false;
  const native =
    "nativeEvent" in event && event.nativeEvent instanceof MouseEvent
      ? event.nativeEvent
      : event instanceof MouseEvent
        ? event
        : null;
  if (!native) return false;
  const related = native.relatedTarget;
  return related instanceof Element && Boolean(related.closest(".mis-dashboard-bar"));
}

function readBarValue(entry: Record<string, unknown>, dataKey: string) {
  const raw = entry[dataKey];
  return typeof raw === "number" ? raw : Number(raw ?? 0);
}

export function bindColumnBarHover(
  dataKey: string,
  setHover: (cell: ColumnHoverCell | null) => void,
  fill: string,
  tipAnchor: Pick<BarTipAnchorContextValue, "setTip"> | null,
  seriesLabel?: string,
) {
  const apply = (entry: Record<string, unknown>, event: unknown) => {
    const categoryKey = categoryKeyFromPayload(entry);
    setHover({ categoryKey, dataKey });
    const rect = barRectFromEvent(event);
    if (rect && tipAnchor) {
      tipAnchor.setTip({
        rect,
        categoryKey,
        dataKey,
        seriesLabel: seriesLabel ?? dataKey,
        value: readBarValue(entry, dataKey),
        color: fill,
      });
    }
  };

  return {
    onMouseEnter: (entry: Record<string, unknown>, _index: number, event: unknown) => {
      apply(entry, event);
    },
    onMouseMove: (entry: Record<string, unknown>, _index: number, event: unknown) => {
      apply(entry, event);
    },
    onMouseLeave: (_entry: Record<string, unknown>, _index: number, event: unknown) => {
      if (isMovingToAnotherBar(event)) return;
      setHover(null);
      tipAnchor?.setTip(null);
    },
  };
}

export function columnBarProps(
  dataKey: string,
  setHover: (cell: ColumnHoverCell | null) => void,
  fill: string,
  radius = 4,
  tipAnchor: Pick<BarTipAnchorContextValue, "setTip"> | null = null,
  seriesLabel?: string,
): Pick<BarProps, "shape" | "onMouseEnter" | "onMouseMove" | "onMouseLeave"> {
  return {
    shape: getColumnBarShape(dataKey, fill, radius) as BarProps["shape"],
    ...bindColumnBarHover(dataKey, setHover, fill, tipAnchor, seriesLabel),
  };
}

export function rowBarProps(
  dataKey: string,
  setHover: (cell: ColumnHoverCell | null) => void,
  fill: string,
  radius = 4,
  tipAnchor: Pick<BarTipAnchorContextValue, "setTip"> | null = null,
  seriesLabel?: string,
): Pick<BarProps, "shape" | "onMouseEnter" | "onMouseMove" | "onMouseLeave"> {
  return {
    shape: getRowBarShape(dataKey, fill, radius) as BarProps["shape"],
    ...bindColumnBarHover(dataKey, setHover, fill, tipAnchor, seriesLabel),
  };
}
