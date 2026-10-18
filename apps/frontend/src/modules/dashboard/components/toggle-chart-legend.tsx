import { useCallback, useState } from "react";
import type { ChartConfig } from "@/components/ui/chart";
import { cn } from "@/lib/utils";

/** Grouped-bar relayout when a legend series is hidden (see `bar-emphasis` layout transition). */
export const LEGEND_BAR_LAYOUT_MS = 800;

/** Recharts grow when a struck legend series is shown again. */
export const LEGEND_BAR_GROW_MS = 800;

export function useLegendSeriesToggle() {
  const [hidden, setHidden] = useState<Set<string>>(() => new Set());
  const [growingIn, setGrowingIn] = useState<Set<string>>(() => new Set());

  const toggle = useCallback((dataKey: string) => {
    setHidden((prev) => {
      const next = new Set(prev);
      if (next.has(dataKey)) {
        next.delete(dataKey);
        setGrowingIn((g) => new Set(g).add(dataKey));
        window.setTimeout(() => {
          setGrowingIn((g) => {
            if (!g.has(dataKey)) return g;
            const cleared = new Set(g);
            cleared.delete(dataKey);
            return cleared;
          });
        }, LEGEND_BAR_GROW_MS);
      } else {
        next.add(dataKey);
      }
      return next;
    });
  }, []);

  const isHidden = useCallback((dataKey: string) => hidden.has(dataKey), [hidden]);
  const isGrowingIn = useCallback((dataKey: string) => growingIn.has(dataKey), [growingIn]);

  return { hidden, toggle, isHidden, isGrowingIn };
}

/** Clickable legend under the chart (always visible; not clipped by Recharts layout). */
export function ConfigToggleLegend({
  config,
  hidden,
  onToggle,
  className,
}: {
  config: ChartConfig;
  hidden: ReadonlySet<string>;
  onToggle: (dataKey: string) => void;
  className?: string;
}) {
  const entries = Object.entries(config);

  return (
    <div
      className={cn(
        "flex flex-wrap items-center justify-center gap-x-4 gap-y-1 border-t border-border/40 pt-3 text-xs",
        className,
      )}
    >
      {entries.map(([dataKey, item]) => {
        const off = hidden.has(dataKey);
        const color =
          item && "color" in item && typeof item.color === "string" ? item.color : "var(--chart-1)";
        return (
          <button
            key={dataKey}
            type="button"
            aria-pressed={!off}
            onClick={() => onToggle(dataKey)}
            className={cn(
              "flex cursor-pointer items-center gap-1.5 rounded-sm border-0 bg-transparent p-0 text-xs text-foreground hover:opacity-80",
            )}
          >
            <span
              className="h-2 w-2 shrink-0 rounded-[2px]"
              style={{ backgroundColor: color, opacity: off ? 0.45 : 1 }}
            />
            <span className={cn(off && "text-muted-foreground line-through decoration-foreground/70")}>
              {item.label ?? dataKey}
            </span>
          </button>
        );
      })}
    </div>
  );
}
