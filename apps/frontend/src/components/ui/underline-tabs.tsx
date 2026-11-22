import { useCallback, useLayoutEffect, useRef, useState, type ReactNode } from "react";
import { cn } from "@/lib/utils";

export type UnderlineTabOption<T extends string> = {
  value: T;
  label: ReactNode;
};

/**
 * Apple text tabs. The chosen label is the primary text color. A short line
 * under that label slides when the selection changes.
 */
export function UnderlineTabs<T extends string>({
  value,
  onChange,
  options,
  className,
}: {
  value: T;
  onChange: (value: T) => void;
  options: UnderlineTabOption<T>[];
  className?: string;
}) {
  const rootRef = useRef<HTMLDivElement>(null);
  const seen = useRef(false);
  const [line, setLine] = useState<{ x: number; w: number } | null>(null);

  const measure = useCallback(() => {
    const root = rootRef.current;
    if (!root) return;
    const selected = root.querySelector<HTMLElement>('[data-selected="true"]');
    const label = selected?.querySelector<HTMLElement>("[data-tab-label]");
    const target = label ?? selected;
    if (!selected || !target) return;
    let x = 0;
    let node: HTMLElement | null = target;
    while (node && node !== root) {
      x += node.offsetLeft;
      node = node.offsetParent instanceof HTMLElement ? node.offsetParent : null;
    }
    setLine({ x, w: target.offsetWidth });
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
      className={cn("relative flex items-end border-b border-border", className)}
    >
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
              "relative px-4 py-2.5 text-sm transition-colors",
              selected ? "font-semibold text-foreground" : "font-medium text-muted-foreground hover:text-foreground",
            )}
          >
            <span data-tab-label="" className="inline-flex items-center gap-2">
              {option.label}
            </span>
          </button>
        );
      })}
      {line && (
        <span
          aria-hidden
          className="pointer-events-none absolute bottom-0 h-0.5 rounded-full bg-foreground"
          style={{
            left: line.x,
            width: line.w,
            transition: seen.current
              ? "left 220ms cubic-bezier(0.2, 0.85, 0.3, 1), width 220ms cubic-bezier(0.2, 0.85, 0.3, 1)"
              : "none",
          }}
        />
      )}
    </div>
  );
}
