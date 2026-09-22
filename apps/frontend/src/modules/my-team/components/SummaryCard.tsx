// ─── My Team — Summary Card (Primary Availability KPI) ───────────────────────

import type { LucideIcon } from "lucide-react";

export type SummaryCardVariant = "emerald" | "blue" | "violet" | "rose" | "primary";

interface SummaryCardProps {
  label: string;
  current: number;
  total: number;
  icon: LucideIcon;
  variant?: SummaryCardVariant;
  subtitle?: string;
}

const variantStyles: Record<
  SummaryCardVariant,
  { iconBg: string; textAccent: string }
> = {
  emerald: {
    iconBg: "bg-emerald-500/10 text-emerald-600 dark:bg-emerald-500/15 dark:text-emerald-400",
    textAccent: "text-emerald-600 dark:text-emerald-400",
  },
  blue: {
    iconBg: "bg-blue-500/10 text-blue-600 dark:bg-blue-500/15 dark:text-blue-400",
    textAccent: "text-blue-600 dark:text-blue-400",
  },
  violet: {
    iconBg: "bg-violet-500/10 text-violet-600 dark:bg-violet-500/15 dark:text-violet-400",
    textAccent: "text-violet-600 dark:text-violet-400",
  },
  rose: {
    iconBg: "bg-rose-500/10 text-rose-600 dark:bg-rose-500/15 dark:text-rose-400",
    textAccent: "text-rose-600 dark:text-rose-400",
  },
  primary: {
    iconBg: "bg-primary/10 text-primary",
    textAccent: "text-primary",
  },
};

export function SummaryCard({
  label,
  current,
  total,
  icon: Icon,
  variant = "primary",
  subtitle,
}: SummaryCardProps) {
  const styles = variantStyles[variant];

  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-2xs transition-all hover:shadow-xs">
      <div className="flex items-start justify-between">
        <div className="min-w-0 flex-1">
          <p className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground truncate">
            {label}
          </p>

          <p className="mt-2 flex items-baseline gap-1 font-semibold leading-none">
            <span className="text-2xl font-bold tabular-nums text-foreground">
              {current}
            </span>
            <span className="text-xs font-medium text-muted-foreground">
              /{total}
            </span>
          </p>

          {subtitle && (
            <p className="mt-1.5 text-[11px] text-muted-foreground font-normal truncate">
              {subtitle}
            </p>
          )}
        </div>

        <div className={`rounded-xl p-2.5 shrink-0 ${styles.iconBg}`}>
          <Icon className="h-4 w-4" />
        </div>
      </div>
    </div>
  );
}
