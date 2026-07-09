// ─── My Team — Summary Card ───────────────────────────────────────────────────

import type { LucideIcon } from "lucide-react";

interface SummaryCardProps {
  label: string;
  current: number;
  total: number;
  icon: LucideIcon;
}

export function SummaryCard({
  label,
  current,
  total,
  icon: Icon,
}: SummaryCardProps) {
  return (
    <div className="rounded-xl border border-border bg-card p-4 shadow-sm">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
            {label}
          </p>

          <p className="mt-2 flex items-baseline gap-1 font-semibold">
            <span className="text-2xl">{current}</span>
            <span className="text-base text-muted-foreground">/{total}</span>
          </p>
        </div>

        <div className="rounded-lg bg-primary/10 p-2 text-primary">
          <Icon className="h-4 w-4" />
        </div>
      </div>
    </div>
  );
}
