import React from "react";
import { cn } from "@/lib/utils";

export interface KpiCardProps {
  label: string;
  value: string | number;
  sub?: string;
  tone?: "default" | "success" | "warn" | "danger";
  className?: string;
}

export function KpiCard({ label, value, sub, tone = "default", className }: KpiCardProps) {
  const toneCls = {
    default: "text-foreground",
    success: "text-emerald-600 dark:text-emerald-400",
    warn: "text-amber-600 dark:text-amber-400",
    danger: "text-destructive",
  }[tone];

  return (
    <div className={cn("rounded-xl border border-border bg-card p-4 shadow-sm", className)}>
      <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">{label}</div>
      <div className={cn("mt-2 text-2xl font-semibold tabular-nums", toneCls)}>{value}</div>
      {sub && <div className="mt-1 text-[11px] text-muted-foreground">{sub}</div>}
    </div>
  );
}

export { KpiCard as KPI, KpiCard as Kpi };
