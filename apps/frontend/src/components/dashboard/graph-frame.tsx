import { createContext, useContext, useEffect, useRef, useState, type ReactNode } from "react";
import { createPortal } from "react-dom";
import { Maximize2, X } from "lucide-react";

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

const CURSOR_TIP_STYLE = `[data-cursor-tip] .recharts-tooltip-wrapper{position:fixed!important;left:var(--tip-x,0px)!important;top:var(--tip-y,0px)!important;transform:none!important;margin:0!important;z-index:70}
@keyframes graph-bar-grow-y{from{transform:scaleY(0)}to{transform:scaleY(1)}}
@keyframes graph-bar-grow-x{from{transform:scaleX(0)}to{transform:scaleX(1)}}
[data-graph-zoom] .recharts-bar-rectangle{transform-box:fill-box;transform-origin:50% 100%;animation:graph-bar-grow-y .8s ease-out both}
[data-graph-zoom] [data-bar-axis="x"] .recharts-bar-rectangle{transform-origin:0 50%;animation:graph-bar-grow-x .8s ease-out both}`;

const GraphZoomMotionContext = createContext(false);

/** True while the chart is drawn inside the expanded window, so those bars play their entrance animation. */
export function useGraphZoomMotion() {
  return useContext(GraphZoomMotionContext);
}

/** Keeps the details window beside the pointer, flipping inward when it would leave the screen. */
export function placeCursorTip(clientX: number, clientY: number) {
  const width = 240;
  const height = 150;
  const gap = 14;
  let x = clientX + gap;
  let y = clientY + gap;
  if (x + width > window.innerWidth - 8) x = Math.max(8, clientX - width - gap);
  if (y + height > window.innerHeight - 8) y = Math.max(8, clientY - height - gap);
  return { x, y };
}

/** Clicking a bar opens the tooltip at the cursor. A click anywhere else hides it without redrawing the chart. */
export function ChartDismiss({ children }: { children: ReactNode }) {
  const ref = useRef<HTMLDivElement>(null);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    if (!document.getElementById("cursor-tip-style")) {
      const style = document.createElement("style");
      style.id = "cursor-tip-style";
      style.textContent = CURSOR_TIP_STYLE;
      document.head.appendChild(style);
    }
    const onPointerDown = (event: PointerEvent) => {
      const root = ref.current;
      const target = event.target;
      if (!root || !(target instanceof Node)) return;
      const inside = root.contains(target);
      setDismissed(!inside);
      if (!inside) return;
      const { x, y } = placeCursorTip(event.clientX, event.clientY);
      root.style.setProperty("--tip-x", `${x}px`);
      root.style.setProperty("--tip-y", `${y}px`);
    };
    document.addEventListener("pointerdown", onPointerDown, true);
    const onScroll = () => setDismissed(true);
    document.addEventListener("scroll", onScroll, true);
    return () => {
      document.removeEventListener("pointerdown", onPointerDown, true);
      document.removeEventListener("scroll", onScroll, true);
    };
  }, []);

  return (
    <div ref={ref} data-cursor-tip="" className={dismissed ? "[&_.recharts-tooltip-wrapper]:!invisible" : undefined}>
      {children}
    </div>
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
