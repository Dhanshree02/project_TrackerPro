// ─── My Team — Shift Summary Card (Compact Sub-KPI) ──────────────────────────

import { shiftMeta } from "../constants";
import type { ShiftType } from "../types";

interface ShiftSummaryCardProps {
  shift: ShiftType;
  count: number;
  totalMembers: number;
}

const shiftTheme: Record<
  ShiftType,
  { badge: string; borderHover: string }
> = {
  General: {
    badge: "bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-200 border border-slate-200/80 dark:border-slate-700",
    borderHover: "hover:border-slate-300 dark:hover:border-slate-700",
  },
  Morning: {
    badge: "bg-amber-100 text-amber-800 dark:bg-amber-950/60 dark:text-amber-300 border border-amber-200/80 dark:border-amber-900/50",
    borderHover: "hover:border-amber-300 dark:hover:border-amber-800",
  },
  Afternoon: {
    badge: "bg-orange-100 text-orange-800 dark:bg-orange-950/60 dark:text-orange-300 border border-orange-200/80 dark:border-orange-900/50",
    borderHover: "hover:border-orange-300 dark:hover:border-orange-800",
  },
  Night: {
    badge: "bg-indigo-100 text-indigo-800 dark:bg-indigo-950/60 dark:text-indigo-300 border border-indigo-200/80 dark:border-indigo-900/50",
    borderHover: "hover:border-indigo-300 dark:hover:border-indigo-800",
  },
};

export function ShiftSummaryCard({
  shift,
  count,
  totalMembers,
}: ShiftSummaryCardProps) {
  const meta = shiftMeta[shift];
  const theme = shiftTheme[shift];

  return (
    <div
      className={`flex items-center justify-between rounded-xl border border-border/80 bg-card px-3.5 py-2.5 shadow-2xs transition-all hover:shadow-xs ${theme.borderHover}`}
    >
      <div className="flex items-center gap-2.5 min-w-0">
        <span
          className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-md text-[11px] font-bold leading-none select-none ${theme.badge}`}
        >
          {meta.chip}
        </span>
        <span className="text-xs font-semibold text-foreground truncate">
          {meta.label} Shift
        </span>
      </div>

      <div className="text-right pl-2 shrink-0">
        <span className="text-base font-bold tabular-nums text-foreground leading-none">
          {count}
        </span>
        <span className="text-[11px] text-muted-foreground font-medium leading-none ml-0.5">
          /{totalMembers}
        </span>
      </div>
    </div>
  );
}
