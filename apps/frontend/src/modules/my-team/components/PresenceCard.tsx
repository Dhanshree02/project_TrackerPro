// ─── My Team — Presence & Availability Card (Minimal & Interactive) ───────────

import { Building2, CalendarOff, Home, UserCheck } from "lucide-react";
import type { TeamMember } from "../types";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

export type ActiveFilter =
  | { kind: "all" }
  | { kind: "presence"; status: "onsite" | "wfh" | "leave" }
  | { kind: "shift"; shift: string };

interface PresenceCardProps {
  totalMembers: number;
  activeMembers: TeamMember[];
  onsiteMembers: TeamMember[];
  wfhMembers: TeamMember[];
  onLeaveMembers: TeamMember[];
  activeFilter: ActiveFilter;
  onSelectFilter: (filter: ActiveFilter) => void;
}

export function PresenceCard({
  totalMembers,
  activeMembers,
  onsiteMembers,
  wfhMembers,
  onLeaveMembers,
  activeFilter,
  onSelectFilter,
}: PresenceCardProps) {
  const isPresentActive = activeFilter.kind === "presence";
  const presencePercent =
    totalMembers > 0
      ? Math.round((activeMembers.length / totalMembers) * 100)
      : 0;

  const handleToggle = (status: "onsite" | "wfh" | "leave") => {
    if (isPresentActive && activeFilter.status === status) {
      onSelectFilter({ kind: "all" });
    } else {
      onSelectFilter({ kind: "presence", status });
    }
  };

  const renderTooltipContent = (title: string, members: TeamMember[]) => (
    <TooltipContent
      side="bottom"
      sideOffset={6}
      className="z-50 w-56 rounded-xl border border-border/80 bg-popover/95 p-3 text-popover-foreground shadow-xl backdrop-blur-md"
    >
      <div className="mb-2 flex items-center justify-between border-b border-border/60 pb-1.5">
        <span className="text-[11px] font-semibold text-foreground">
          {title} ({members.length})
        </span>
        <span className="text-[9.5px] font-medium text-muted-foreground">
          Click to filter
        </span>
      </div>
      {members.length === 0 ? (
        <p className="text-[11px] text-muted-foreground italic py-1">
          No members
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
            <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600 dark:bg-emerald-500/15 dark:text-emerald-400">
              <UserCheck className="h-4 w-4" />
            </div>
            <p className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">
              Team Availability
            </p>
          </div>

          <div className="flex items-baseline justify-end gap-1 font-semibold leading-none">
            <span className="text-2xl font-bold tabular-nums tracking-tight text-foreground">
              {activeMembers.length}
            </span>
            <span className="text-xs font-medium text-muted-foreground">
              /{totalMembers}
            </span>
            <span className="ml-1.5 rounded-full bg-emerald-500/10 px-2 py-0.5 text-[10.5px] font-semibold text-emerald-600 dark:bg-emerald-500/15 dark:text-emerald-400">
              {presencePercent}%
            </span>
          </div>
        </div>

        {/* Bottom: Interactive Pills */}
        <div className="pt-3 flex items-center gap-2 flex-wrap">
          {/* Onsite Pill */}
          <Tooltip>
            <TooltipTrigger asChild>
              <button
                type="button"
                onClick={() => handleToggle("onsite")}
                className={`group flex items-center gap-2 rounded-xl px-3 py-1.5 text-xs font-medium transition-all cursor-pointer ${
                  isPresentActive && activeFilter.status === "onsite"
                    ? "bg-[#8b75c8]/20 text-[#5f4999] ring-2 ring-[#8b75c8]/50 shadow-xs dark:bg-[#8b75c8]/30 dark:text-violet-200"
                    : "bg-black/[0.03] text-foreground hover:bg-black/[0.06] dark:bg-white/[0.05] dark:hover:bg-white/[0.1]"
                }`}
              >
                <span className="flex h-4 w-4 items-center justify-center rounded-full bg-[#8b75c8]/20 text-[#8b75c8]">
                  <Building2 className="h-2.5 w-2.5" />
                </span>
                <span>Onsite</span>
                <span
                  className={`rounded-md px-1.5 py-0.5 text-[10.5px] font-bold tabular-nums ${
                    isPresentActive && activeFilter.status === "onsite"
                      ? "bg-[#8b75c8] text-white"
                      : "bg-black/[0.06] text-foreground dark:bg-white/[0.1]"
                  }`}
                >
                  {onsiteMembers.length}
                </span>
              </button>
            </TooltipTrigger>
            {renderTooltipContent("Onsite Today", onsiteMembers)}
          </Tooltip>

          {/* WFH Pill */}
          <Tooltip>
            <TooltipTrigger asChild>
              <button
                type="button"
                onClick={() => handleToggle("wfh")}
                className={`group flex items-center gap-2 rounded-xl px-3 py-1.5 text-xs font-medium transition-all cursor-pointer ${
                  isPresentActive && activeFilter.status === "wfh"
                    ? "bg-[#cf67bd]/20 text-[#9b3a8a] ring-2 ring-[#cf67bd]/50 shadow-xs dark:bg-[#cf67bd]/30 dark:text-pink-200"
                    : "bg-black/[0.03] text-foreground hover:bg-black/[0.06] dark:bg-white/[0.05] dark:hover:bg-white/[0.1]"
                }`}
              >
                <span className="flex h-4 w-4 items-center justify-center rounded-full bg-[#cf67bd]/20 text-[#cf67bd]">
                  <Home className="h-2.5 w-2.5" />
                </span>
                <span>WFH</span>
                <span
                  className={`rounded-md px-1.5 py-0.5 text-[10.5px] font-bold tabular-nums ${
                    isPresentActive && activeFilter.status === "wfh"
                      ? "bg-[#cf67bd] text-white"
                      : "bg-black/[0.06] text-foreground dark:bg-white/[0.1]"
                  }`}
                >
                  {wfhMembers.length}
                </span>
              </button>
            </TooltipTrigger>
            {renderTooltipContent("Working From Home", wfhMembers)}
          </Tooltip>

          {/* On Leave Pill */}
          <Tooltip>
            <TooltipTrigger asChild>
              <button
                type="button"
                onClick={() => handleToggle("leave")}
                className={`group flex items-center gap-2 rounded-xl px-3 py-1.5 text-xs font-medium transition-all cursor-pointer ${
                  isPresentActive && activeFilter.status === "leave"
                    ? "bg-[#49a6e9]/20 text-[#1f73ad] ring-2 ring-[#49a6e9]/50 shadow-xs dark:bg-[#49a6e9]/30 dark:text-sky-200"
                    : "bg-black/[0.03] text-foreground hover:bg-black/[0.06] dark:bg-white/[0.05] dark:hover:bg-white/[0.1]"
                }`}
              >
                <span className="flex h-4 w-4 items-center justify-center rounded-full bg-[#49a6e9]/20 text-[#49a6e9]">
                  <CalendarOff className="h-2.5 w-2.5" />
                </span>
                <span>On Leave</span>
                <span
                  className={`rounded-md px-1.5 py-0.5 text-[10.5px] font-bold tabular-nums ${
                    isPresentActive && activeFilter.status === "leave"
                      ? "bg-[#49a6e9] text-white"
                      : "bg-black/[0.06] text-foreground dark:bg-white/[0.1]"
                  }`}
                >
                  {onLeaveMembers.length}
                </span>
              </button>
            </TooltipTrigger>
            {renderTooltipContent("On Leave Today", onLeaveMembers)}
          </Tooltip>
        </div>
      </div>
    </TooltipProvider>
  );
}
