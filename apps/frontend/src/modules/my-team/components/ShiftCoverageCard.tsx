// ─── My Team — Shift Coverage Card (Minimal & Interactive) ───────────────────

import { Clock } from "lucide-react";
import type { ShiftType, TeamMember } from "../types";
import { shiftMeta } from "../constants";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import type { ActiveFilter } from "./PresenceCard";

interface ShiftCoverageCardProps {
  totalMembers: number;
  shiftMembers: Record<ShiftType, TeamMember[]>;
  activeFilter: ActiveFilter;
  onSelectFilter: (filter: ActiveFilter) => void;
}

const SHIFTS: ShiftType[] = ["General", "Morning", "Afternoon", "Night"];

const shiftPillStyles: Record<
  ShiftType,
  {
    chip: string;
    active: string;
    hover: string;
  }
> = {
  General: {
    chip: "bg-slate-200/90 text-slate-700 dark:bg-slate-700 dark:text-slate-200",
    active: "bg-slate-200/60 text-slate-900 ring-2 ring-slate-400/60 shadow-xs dark:bg-slate-800 dark:text-white dark:ring-slate-600",
    hover: "hover:bg-slate-100 dark:hover:bg-slate-800/60",
  },
  Morning: {
    chip: "bg-amber-200 text-amber-900 dark:bg-amber-900/60 dark:text-amber-200",
    active: "bg-amber-100 text-amber-950 ring-2 ring-amber-400/70 shadow-xs dark:bg-amber-950/70 dark:text-amber-200 dark:ring-amber-500",
    hover: "hover:bg-amber-50/80 dark:hover:bg-amber-950/40",
  },
  Afternoon: {
    chip: "bg-orange-200 text-orange-900 dark:bg-orange-900/60 dark:text-orange-200",
    active: "bg-orange-100 text-orange-950 ring-2 ring-orange-400/70 shadow-xs dark:bg-orange-950/70 dark:text-orange-200 dark:ring-orange-500",
    hover: "hover:bg-orange-50/80 dark:hover:bg-orange-950/40",
  },
  Night: {
    chip: "bg-indigo-200 text-indigo-900 dark:bg-indigo-900/60 dark:text-indigo-200",
    active: "bg-indigo-100 text-indigo-950 ring-2 ring-indigo-400/70 shadow-xs dark:bg-indigo-950/70 dark:text-indigo-200 dark:ring-indigo-500",
    hover: "hover:bg-indigo-50/80 dark:hover:bg-indigo-950/40",
  },
};

export function ShiftCoverageCard({
  totalMembers,
  shiftMembers,
  activeFilter,
  onSelectFilter,
}: ShiftCoverageCardProps) {
  const isShiftActive = activeFilter.kind === "shift";

  const totalScheduled = SHIFTS.reduce(
    (acc, shift) => acc + (shiftMembers[shift]?.length ?? 0),
    0,
  );

  const handleToggle = (shift: ShiftType) => {
    if (isShiftActive && activeFilter.shift === shift) {
      onSelectFilter({ kind: "all" });
    } else {
      onSelectFilter({ kind: "shift", shift });
    }
  };

  const renderTooltipContent = (shift: ShiftType, members: TeamMember[]) => (
    <TooltipContent
      side="bottom"
      sideOffset={6}
      className="z-50 w-56 rounded-xl border border-border/80 bg-popover/95 p-3 text-popover-foreground shadow-xl backdrop-blur-md"
    >
      <div className="mb-2 flex items-center justify-between border-b border-border/60 pb-1.5">
        <span className="text-[11px] font-semibold text-foreground">
          {shiftMeta[shift].label} Shift ({members.length})
        </span>
        <span className="text-[9.5px] font-medium text-muted-foreground">
          Click to filter
        </span>
      </div>
      {members.length === 0 ? (
        <p className="text-[11px] text-muted-foreground italic py-1">
          No members scheduled
        </p>
      ) : (
        <div className="space-y-1.5 max-h-40 overflow-y-auto pr-1">
          {members.map((m) => (
            <div key={m.id} className="flex items-center gap-2">
              <span
                className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full text-[9px] font-bold text-white shadow-2xs"
                style={{ backgroundColor: m.avatarColor }}
              >
                {m.initials}
              </span>
              <div className="min-w-0 flex-1">
                <p className="truncate text-xs font-medium leading-none text-foreground">
                  {m.name}
                </p>
                <p className="truncate text-[10px] text-muted-foreground leading-tight mt-0.5">
                  {m.designation}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </TooltipContent>
  );

  return (
    <TooltipProvider delayDuration={120}>
      <div className="relative flex flex-col justify-between rounded-2xl border border-black/[0.07] bg-white/75 p-4 shadow-2xs backdrop-blur-md transition-all hover:border-black/[0.12] dark:border-white/[0.08] dark:bg-slate-900/70">
        {/* Top Header: Title + Hero Stat */}
        <div className="flex items-center justify-between gap-2 pb-3 border-b border-black/[0.04] dark:border-white/[0.05]">
          <div className="flex items-center gap-2.5">
            <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-indigo-500/10 text-indigo-600 dark:bg-indigo-500/15 dark:text-indigo-400">
              <Clock className="h-4 w-4" />
            </div>
            <p className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
              Shift Coverage
            </p>
          </div>

          <div className="flex items-baseline justify-end gap-1 font-semibold leading-none">
            <span className="text-2xl font-bold tabular-nums tracking-tight text-foreground">
              {totalScheduled}
            </span>
            <span className="text-xs font-medium text-muted-foreground">
              /{totalMembers}
            </span>
            <span className="ml-1.5 rounded-full bg-indigo-500/10 px-2 py-0.5 text-[10.5px] font-semibold text-indigo-600 dark:bg-indigo-500/15 dark:text-indigo-400">
              Coverage
            </span>
          </div>
        </div>

        {/* Bottom: 4 Symmetrical Interactive Shift Chips */}
        <div className="pt-3 grid grid-cols-4 gap-2">
          {SHIFTS.map((shift) => {
            const meta = shiftMeta[shift];
            const members = shiftMembers[shift] ?? [];
            const isSelected = isShiftActive && activeFilter.shift === shift;
            const style = shiftPillStyles[shift];

            return (
              <Tooltip key={shift}>
                <TooltipTrigger asChild>
                  <button
                    type="button"
                    onClick={() => handleToggle(shift)}
                    className={`group flex items-center justify-between rounded-xl px-2.5 py-1.5 text-xs font-medium transition-all cursor-pointer ${
                      isSelected
                        ? style.active
                        : `bg-black/[0.03] text-foreground dark:bg-white/[0.05] ${style.hover}`
                    }`}
                  >
                    <div className="flex items-center gap-1.5 min-w-0">
                      <span
                        className={`flex h-4 w-4 shrink-0 items-center justify-center rounded-[3.5px] text-[9px] font-bold leading-none select-none ${style.chip}`}
                      >
                        {meta.chip}
                      </span>
                      <span className="truncate hidden sm:inline text-[11px] font-medium">
                        {meta.label}
                      </span>
                    </div>

                    <span
                      className={`rounded-md px-1.5 py-0.5 text-[10.5px] font-bold tabular-nums shrink-0 ml-1 ${
                        isSelected
                          ? "bg-black/10 text-foreground dark:bg-white/20"
                          : "bg-black/[0.06] text-foreground dark:bg-white/[0.1]"
                      }`}
                    >
                      {members.length}
                    </span>
                  </button>
                </TooltipTrigger>
                {renderTooltipContent(shift, members)}
              </Tooltip>
            );
          })}
        </div>
      </div>
    </TooltipProvider>
  );
}
