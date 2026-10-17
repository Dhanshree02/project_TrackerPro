import type { CSSProperties, ReactNode } from "react";
import { cn } from "@/lib/utils";

/** `down` = tail on bottom (callout above bar). `up` = tail on top (WhatsApp-style, callout below anchor). */
export type BarCalloutTail = "down" | "up";

function CalloutTail({ direction }: { direction: BarCalloutTail }) {
  const up = direction === "up";
  return (
    <svg
      width={16}
      height={8}
      viewBox="0 0 16 8"
      className={cn("mx-auto block shrink-0 text-border", up ? "-mb-px rotate-180" : "-mt-px")}
      aria-hidden
    >
      <path
        d="M0 0.5 L8 7.5 L16 0.5 Z"
        className="fill-card stroke-current"
        strokeWidth="1"
        strokeLinejoin="round"
      />
    </svg>
  );
}

const bodyClass =
  "min-w-36 rounded-2xl border border-border bg-card px-3 py-2.5 text-xs shadow-md ring-1 ring-black/[0.04] dark:ring-white/[0.06]";

/** Rounded callout with centered tail. Anchor `(left, top)` is where the tail tip touches the chart. */
export function DashboardBarCallout({
  left,
  top,
  tail = "down",
  className,
  style,
  children,
}: {
  left: number;
  top: number;
  tail?: BarCalloutTail;
  className?: string;
  style?: CSSProperties;
  children: ReactNode;
}) {
  const above = tail === "down";

  return (
    <div
      className="pointer-events-none fixed z-[90]"
      style={{
        left,
        top,
        transform: above ? "translate(-50%, -100%)" : "translate(-50%, 0)",
        ...style,
      }}
    >
      <div className="flex flex-col items-stretch">
        {tail === "up" ? <CalloutTail direction="up" /> : null}
        <div className={cn(bodyClass, className)}>{children}</div>
        {tail === "down" ? <CalloutTail direction="down" /> : null}
      </div>
    </div>
  );
}
