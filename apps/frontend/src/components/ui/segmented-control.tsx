import { useCallback, useLayoutEffect, useRef, useState, type ReactNode } from "react";
import { cn } from "@/lib/utils";

export type SegmentOption<T extends string> = {
  value: T;
  label: ReactNode;
};

/**
 * Shared pill switch. The track is system gray. The selected piece is a white
 * pill in both themes, with dark text, and it slides to the chosen option.
 */
export function SegmentedControl<T extends string>({
  value,
  onChange,
  options,
  size = "md",
  className,
  ariaLabel,
}: {
  value: T;
  onChange: (value: T) => void;
  options: SegmentOption<T>[];
  size?: "sm" | "md";
  className?: string;
  ariaLabel?: string;
}) {
  const rootRef = useRef<HTMLDivElement>(null);
  const seen = useRef(false);
  const [thumb, setThumb] = useState<{ x: number; y: number; w: number; h: number } | null>(null);

  const measure = useCallback(() => {
    const root = rootRef.current;
    if (!root) return;
    const selected = root.querySelector<HTMLElement>('[data-selected="true"]');
    if (!selected) return;
    setThumb({
      x: selected.offsetLeft,
      y: selected.offsetTop,
      w: selected.offsetWidth,
      h: selected.offsetHeight,
    });
  }, []);

  useLayoutEffect(() => {
    measure();
    seen.current = true;
  }, [measure, value, options]);

  useLayoutEffect(() => {
    const root = rootRef.current;
    if (!root) return;
    const observer = new ResizeObserver(measure);
    observer.observe(root);
    return () => observer.disconnect();
  }, [measure]);

  return (
    <div
      ref={rootRef}
      role="tablist"
      aria-label={ariaLabel}
      className={cn(
        "relative inline-flex w-fit max-w-full flex-wrap items-center gap-1 rounded-full bg-[var(--segment-track)] p-1",
        className,
      )}
    >
      {thumb && (
        <span
          aria-hidden
          className="pointer-events-none absolute rounded-full bg-[var(--segment-thumb)] shadow-[0_1px_2px_rgba(0,0,0,0.08),0_2px_8px_rgba(0,0,0,0.12)]"
          style={{
            left: thumb.x,
            top: thumb.y,
            width: thumb.w,
            height: thumb.h,
            transition: seen.current
              ? "left 220ms cubic-bezier(0.2, 0.85, 0.3, 1), width 220ms cubic-bezier(0.2, 0.85, 0.3, 1), top 220ms cubic-bezier(0.2, 0.85, 0.3, 1)"
              : "none",
          }}
        />
      )}
      {options.map((option) => {
        const selected = option.value === value;
        return (
          <button
            key={option.value}
            type="button"
            role="tab"
            aria-selected={selected}
            data-selected={selected ? "true" : "false"}
            onClick={() => onChange(option.value)}
            className={cn(
              "relative z-10 inline-flex items-center justify-center gap-1.5 whitespace-nowrap rounded-full font-medium tracking-[-0.016em] transition-colors duration-200",
              size === "sm" ? "px-3.5 py-1.5 text-xs" : "px-4 py-2 text-sm",
              selected ? "text-[var(--segment-thumb-foreground)]" : "text-muted-foreground hover:text-foreground",
            )}
          >
            {option.label}
          </button>
        );
      })}
    </div>
  );
}
