// ─── My Team Page ─────────────────────────────────────────────────────────────

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  CalendarCog,
  ChevronLeft,
  ChevronRight,
  Eye,
  Search,
  UserPlus,
  Users,
  UsersRound,
  X,
  RotateCcw,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { RowsPerPageSelect } from "@/components/rows-per-page-select";
import { paginateSlice, paginationRange, totalPageCount } from "@/lib/pagination";
import { normalizeOnFloorRole } from "@/lib/on-floor-role";
import { cn, formatDateDMY } from "@/lib/utils";
import { toast } from "sonner";
import { teamDataService, type TeamCalendarPayload } from "./services/teamDataService";
import {
  attendanceMeta,
  CALENDAR_DAY_COL_PX,
  CALENDAR_END_PAD_PX,
  CALENDAR_HEADER_PX,
  CALENDAR_NAME_COL_PX,
  CALENDAR_ROW_PX,
  DEFAULT_SHIFT,
  monthFormatter,
  shiftKeyMap,
  shiftMeta,
  weekdayFormatter,
} from "./constants";
import {
  applyShiftToMemberDates,
  getDateKeysInRange,
  getDayIndicator,
  getMonFriKeys,
  isWeekendDate,
  makeDateKey,
  makeDateKeyFromDate,
  parseDateKey,
} from "./utils";
import type {
  CellRef,
  MemberScheduleConfig,
  OpenCell,
  PoolAllocationStatus,
  PoolAllocationType,
  SelectableAttendanceType,
  ShiftType,
  TeamMember,
  TeamMemberProjectAllocation,
  TeamSchedule,
} from "./types";
import { DEFAULT_MEMBER_SCHEDULE_CONFIG } from "./types";
import { CalendarDayCell } from "./components/CalendarDayCell";
import { MemberScheduleDialog } from "./components/MemberScheduleDialog";
import { Legend, ShiftChipLegend } from "./components/Legend";
import { PresenceCard, type ActiveFilter } from "./components/PresenceCard";
import { ShiftCoverageCard } from "./components/ShiftCoverageCard";

type Roster = "reportees" | "all";

function rosterCacheKey(month: Date, scope: Roster) {
  return `${month.getFullYear()}-${month.getMonth()}:${scope}`;
}

function getMemberLiveAllocationStatus(
  member: TeamMember,
  schedule: TeamSchedule,
  todayKey: string,
): PoolAllocationStatus {
  const todayEvent = schedule[member.id]?.[todayKey];
  if (todayEvent?.type === "leave" || member.employeeStatus === "On Leave") {
    return "On Leave";
  }
  const hasActiveAllocation =
    (member.allocationEndDate && member.allocationEndDate >= todayKey) ||
    Boolean(member.allocations?.some((a) => a.allocationEndDate >= todayKey));
  if (hasActiveAllocation || member.allocationStatus === "Occupied") {
    return "Occupied";
  }
  return "Free";
}

function resolveDayAllocation(
  member: TeamMember,
  dateKey: string,
): TeamMemberProjectAllocation | undefined {
  if (member.allocations && member.allocations.length > 0) {
    const match = member.allocations.find(
      (a) => a.allocationStartDate <= dateKey && dateKey <= a.allocationEndDate,
    );
    if (match) return match;
  }
  if (
    member.allocationStartDate &&
    member.allocationEndDate &&
    member.allocationStartDate <= dateKey &&
    dateKey <= member.allocationEndDate
  ) {
    return {
      projectId: member.id,
      projectName: member.allocatedProjectName || "Assigned Project",
      allocationType: member.allocationType || "Dedicated",
      allocationStartDate: member.allocationStartDate,
      allocationEndDate: member.allocationEndDate,
    };
  }
  return undefined;
}

function TeamAllocationStatusBadge({
  status,
  compact = false,
}: {
  status: PoolAllocationStatus;
  compact?: boolean;
}) {
  const styles: Record<PoolAllocationStatus, string> = {
    Occupied: "border-amber-500/35 bg-amber-500/12 text-amber-700 dark:text-amber-400",
    Free: "border-emerald-500/35 bg-emerald-500/12 text-emerald-700 dark:text-emerald-400",
    "On Leave": "border-rose-500/35 bg-rose-500/12 text-rose-700 dark:text-rose-400",
  };
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border font-semibold tracking-wide shadow-2xs whitespace-nowrap",
        compact ? "px-1.5 py-0 text-[9.5px] leading-[15px]" : "px-2.5 py-0.5 text-[11px]",
        styles[status],
      )}
    >
      {status}
    </span>
  );
}

function TeamAllocationTypeBadge({
  type,
  compact = false,
}: {
  type?: PoolAllocationType;
  compact?: boolean;
}) {
  if (!type) return null;
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border font-semibold whitespace-nowrap",
        compact ? "px-1.5 py-0 text-[9px] leading-[15px]" : "px-2.5 py-0.5 text-[11px]",
        type === "Dedicated"
          ? "border-indigo-500/30 bg-indigo-500/10 text-indigo-700 dark:text-indigo-300"
          : "border-sky-500/30 bg-sky-500/10 text-sky-700 dark:text-sky-300",
      )}
    >
      {type}
    </span>
  );
}

function TeamWorkloadTasksModal({
  member,
  liveStatus,
  onClose,
}: {
  member: TeamMember;
  liveStatus: PoolAllocationStatus;
  onClose: () => void;
}) {
  const isOnLeave = liveStatus === "On Leave";
  const allocations: TeamMemberProjectAllocation[] = useMemo(() => {
    if (member.allocations && member.allocations.length > 0) return member.allocations;
    if (member.allocationStartDate && member.allocationEndDate) {
      return [
        {
          projectId: member.id,
          projectName: member.allocatedProjectName || "Assigned Project",
          allocationType: member.allocationType || "Dedicated",
          allocationStartDate: member.allocationStartDate,
          allocationEndDate: member.allocationEndDate,
        },
      ];
    }
    return [];
  }, [member]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40 backdrop-blur-[1px]" onClick={onClose} />
      <div
        className="relative w-full max-w-2xl rounded-xl border border-border bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between border-b border-border pb-4 mb-5">
          <h2 className="text-base font-semibold text-foreground">
            {member.name} — Workload & Tasks
          </h2>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1 text-muted-foreground hover:bg-accent transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="grid gap-6 md:grid-cols-3">
          <div className="space-y-4">
            <div className="flex items-center gap-3 rounded-lg border border-border bg-accent/25 p-3">
              <div
                className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-xs font-bold text-white shadow-2xs"
                style={{ backgroundColor: member.avatarColor }}
              >
                {member.initials}
              </div>
              <div className="min-w-0">
                <div className="text-sm font-semibold truncate">{member.name}</div>
                <div className="text-[11px] text-muted-foreground">
                  {member.department || "—"} · {member.designation || "—"}
                </div>
                {member.employeeCode && (
                  <div className="text-[11px] text-muted-foreground font-mono">
                    {member.employeeCode}
                  </div>
                )}
                <div className="mt-1.5 flex flex-wrap items-center gap-1">
                  <TeamAllocationStatusBadge status={liveStatus} />
                  {member.allocationType && (
                    <TeamAllocationTypeBadge type={member.allocationType} />
                  )}
                </div>
                {isOnLeave && allocations.length > 0 && (
                  <div className="mt-1 text-[10px] text-muted-foreground">
                    Assigned to project (overridden by Leave today)
                  </div>
                )}
              </div>
            </div>
          </div>

          <div className="md:col-span-2 space-y-3">
            <h4 className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Active Project Allocation
            </h4>
            {allocations.length > 0 ? (
              <div className="space-y-2.5 max-h-[260px] overflow-y-auto pr-1">
                {allocations.map((alloc, idx) => (
                  <div
                    key={`${alloc.projectId}-${idx}`}
                    className="rounded-lg border border-border bg-card p-4 space-y-2"
                  >
                    <div className="flex flex-wrap items-center justify-between gap-2">
                      <div className="text-sm font-semibold text-foreground">
                        {alloc.projectName}
                      </div>
                      <TeamAllocationTypeBadge type={alloc.allocationType} />
                    </div>
                    <div className="text-xs text-muted-foreground">
                      <span className="font-medium text-foreground">Allocation Duration: </span>
                      {formatDateDMY(alloc.allocationStartDate)} → {formatDateDMY(alloc.allocationEndDate)}
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-sm text-muted-foreground">
                No active project allocation. Resource is currently free.
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function TeamRequestAllocationModal({
  member,
  colleagues,
  onClose,
}: {
  member: TeamMember;
  colleagues: TeamMember[];
  onClose: () => void;
}) {
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [comment, setComment] = useState("");
  const [taggedPeople, setTaggedPeople] = useState<TeamMember[]>([]);
  const [mentionQuery, setMentionQuery] = useState<string | null>(null);
  const [mentionIndex, setMentionIndex] = useState(-1);
  const [showDropdown, setShowDropdown] = useState(false);
  const [dropdownPosition, setDropdownPosition] = useState({ top: 0, left: 0 });

  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const managerDisplay = member.reportingManagerName?.trim() || "Reporting Manager";

  const filteredPeople = useMemo(() => {
    if (mentionQuery === null) return [];
    return colleagues
      .filter((p) => {
        return (
          p.name.toLowerCase().includes(mentionQuery.toLowerCase()) &&
          !taggedPeople.some((tp) => tp.id === p.id)
        );
      })
      .slice(0, 5);
  }, [mentionQuery, taggedPeople, colleagues]);

  const handleTextareaChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const value = e.target.value;
    setComment(value);

    const selectionStart = e.target.selectionStart;
    const beforeCursor = value.slice(0, selectionStart);
    const match = beforeCursor.match(/@(\w*)$/);
    if (match) {
      setMentionQuery(match[1]);
      setShowDropdown(true);
      if (textareaRef.current) {
        const textLines = beforeCursor.split("\n");
        const currentLine = textLines.length;
        const currentCol = textLines[textLines.length - 1].length;
        setDropdownPosition({
          top: currentLine * 20 + 35,
          left: Math.min(250, currentCol * 8 + 10),
        });
      }
    } else {
      setShowDropdown(false);
      setMentionQuery(null);
    }
  };

  const handleSelectPerson = (person: TeamMember) => {
    if (!textareaRef.current) return;
    const value = comment;
    const selectionStart = textareaRef.current.selectionStart;
    const beforeCursor = value.slice(0, selectionStart);
    const afterCursor = value.slice(selectionStart);

    const newBeforeCursor = beforeCursor.replace(/@(\w*)$/, `@${person.name} `);
    const newValue = newBeforeCursor + afterCursor;

    setComment(newValue);
    setTaggedPeople((prev) => {
      if (prev.some((p) => p.id === person.id)) return prev;
      return [...prev, person];
    });
    setShowDropdown(false);
    setMentionQuery(null);

    setTimeout(() => {
      if (textareaRef.current) {
        textareaRef.current.focus();
        const newCursorPos = newBeforeCursor.length;
        textareaRef.current.setSelectionRange(newCursorPos, newCursorPos);
      }
    }, 0);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (showDropdown && filteredPeople.length > 0) {
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setMentionIndex((prev) => (prev + 1) % filteredPeople.length);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setMentionIndex((prev) => (prev - 1 + filteredPeople.length) % filteredPeople.length);
      } else if (e.key === "Enter" || e.key === "Tab") {
        e.preventDefault();
        const selected = filteredPeople[mentionIndex >= 0 ? mentionIndex : 0];
        if (selected) handleSelectPerson(selected);
      } else if (e.key === "Escape") {
        e.preventDefault();
        setShowDropdown(false);
        setMentionQuery(null);
      }
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!startDate || !endDate) {
      toast.error("Please enter both start and end dates");
      return;
    }
    if (new Date(startDate) > new Date(endDate)) {
      toast.error("Start date cannot be after end date");
      return;
    }
    toast.success(`Allocation request for ${member.name} sent to ${managerDisplay}!`);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40 backdrop-blur-[1px]" onClick={onClose} />
      <div
        className="relative w-full max-w-lg rounded-xl border border-border bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between border-b border-border pb-4">
          <div>
            <h2 className="text-base font-semibold text-foreground">Request Allocation</h2>
            <p className="text-xs text-muted-foreground">
              Request allocation of {member.name}
              {member.employeeCode ? ` (ID: ${member.employeeCode})` : ""}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1 text-muted-foreground hover:bg-accent transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="my-4 rounded-lg bg-primary/5 border border-primary/10 p-3.5 flex items-center justify-between">
          <div>
            <div className="text-[10px] uppercase font-bold tracking-wider text-primary/80">
              Routing To:
            </div>
            <div className="mt-0.5 text-sm font-semibold text-foreground">
              {managerDisplay}
            </div>
            <div className="text-[11px] text-muted-foreground font-medium">
              Reporting Manager Action Center
            </div>
          </div>
          <span className="inline-flex rounded-full bg-primary/10 px-2 py-0.5 text-[10px] font-medium text-primary">
            Auto-Routed
          </span>
        </div>

        <form autoComplete="off" onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">
                Start Date
              </span>
              <input
                autoComplete="off"
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                required
              />
            </label>
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">End Date</span>
              <input
                autoComplete="off"
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="h-9 w-full rounded-md border border-input bg-card px-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring"
                required
              />
            </label>
          </div>

          <div className="relative">
            <label className="block">
              <span className="mb-1 block text-xs font-medium text-muted-foreground">
                Comments (Type @ to tag team members)
              </span>
              <textarea
                autoComplete="off"
                ref={textareaRef}
                value={comment}
                onChange={handleTextareaChange}
                onKeyDown={handleKeyDown}
                placeholder="Type @ to tag people from the directory..."
                className="w-full rounded-md border border-input bg-card p-3 text-sm text-foreground outline-none focus:ring-1 focus:ring-ring min-h-[100px] resize-none"
              />
            </label>

            {showDropdown && filteredPeople.length > 0 && (
              <div
                className="absolute z-50 w-56 rounded-md border border-border bg-popover text-popover-foreground shadow-lg overflow-hidden py-1"
                style={{ top: `${dropdownPosition.top}px`, left: `${dropdownPosition.left}px` }}
              >
                {filteredPeople.map((p, idx) => (
                  <button
                    key={p.id}
                    type="button"
                    onClick={() => handleSelectPerson(p)}
                    onMouseEnter={() => setMentionIndex(idx)}
                    className={cn(
                      "w-full text-left px-3 py-1.5 text-xs flex items-center gap-2 hover:bg-accent hover:text-accent-foreground",
                      (mentionIndex === idx || (mentionIndex === -1 && idx === 0)) &&
                        "bg-accent text-accent-foreground",
                    )}
                  >
                    <span
                      className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full text-[9px] font-bold text-white"
                      style={{ backgroundColor: p.avatarColor }}
                    >
                      {p.initials}
                    </span>
                    <span className="truncate">{p.name}</span>
                  </button>
                ))}
              </div>
            )}
          </div>

          {taggedPeople.length > 0 && (
            <div>
              <span className="block text-xs font-medium text-muted-foreground mb-1.5">
                Tagged CC's ({taggedPeople.length}):
              </span>
              <div className="flex flex-wrap gap-1.5">
                {taggedPeople.map((p) => (
                  <span
                    key={p.id}
                    className="inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary/5 px-2.5 py-0.5 text-xs text-primary font-medium shadow-xs"
                  >
                    <span>{p.name}</span>
                    <button
                      type="button"
                      onClick={() => setTaggedPeople((prev) => prev.filter((item) => item.id !== p.id))}
                      className="ml-1 rounded-full p-0.5 hover:bg-primary/10 text-primary/70 hover:text-primary transition-colors"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  </span>
                ))}
              </div>
            </div>
          )}

          <div className="flex items-center justify-end gap-2 border-t border-border pt-4 mt-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 shadow-sm transition-all"
            >
              Send Request
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export function MyTeamPage() {
  const [roster, setRoster] = useState<Roster>("reportees");
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);
  const [teamMembers, setTeamMembers] = useState<TeamMember[]>([]);
  const [teamSchedule, setTeamSchedule] = useState<TeamSchedule>({});
  const [memberConfigs, setMemberConfigs] = useState<Record<string, MemberScheduleConfig>>({});
  const [loading, setLoading] = useState(true);

  // ── UI state ─────────────────────────────────────────────────────────────────
  const [selectedMonth, setSelectedMonth] = useState(() => {
    const now = new Date();
    return new Date(now.getFullYear(), now.getMonth(), 1);
  });

  const [scheduleDialogMember, setScheduleDialogMember] = useState<TeamMember | null>(null);
  const [workloadMember, setWorkloadMember] = useState<TeamMember | null>(null);
  const [allocRequestMember, setAllocRequestMember] = useState<TeamMember | null>(null);

  const [searchQuery, setSearchQuery] = useState("");
  const [deptFilter, setDeptFilter] = useState("");
  const [onFloorRoleFilter, setOnFloorRoleFilter] = useState("");
  const [onFloorRoleMasterOptions, setOnFloorRoleMasterOptions] = useState<string[]>([]);
  const [allocStatusFilter, setAllocStatusFilter] = useState<"" | PoolAllocationStatus>("");
  const [allocTypeFilter, setAllocTypeFilter] = useState<"" | PoolAllocationType>("");

  const [activeFilter, setActiveFilter] = useState<ActiveFilter>({ kind: "all" });
  const [openCell, setOpenCell] = useState<OpenCell>(null);
  const teamCalendarRef = useRef<HTMLDivElement>(null);
  const [focusedCell, setFocusedCell] = useState<CellRef | null>(null);
  const [rangeAnchor, setRangeAnchor] = useState<CellRef | null>(null);
  const [lastUsedShift, setLastUsedShift] = useState<ShiftType | null>(null);

  // ── Derived calendar values ──────────────────────────────────────────────────
  const year = selectedMonth.getFullYear();
  const monthIndex = selectedMonth.getMonth();
  const daysInMonth = new Date(year, monthIndex + 1, 0).getDate();
  const calendarMinWidth = CALENDAR_NAME_COL_PX + daysInMonth * CALENDAR_DAY_COL_PX + CALENDAR_END_PAD_PX;
  const dayGridTemplate = `repeat(${daysInMonth}, minmax(${CALENDAR_DAY_COL_PX}px, 1fr))`;

  /** Hover `title` tooltips sit above the attendance popover and cover the name column. */
  useEffect(() => {
    if (!openCell) return;
    const root = teamCalendarRef.current;
    if (!root) return;
    root.querySelectorAll("[title]").forEach((el) => el.removeAttribute("title"));
  }, [openCell]);

  // today at midnight — locks past dates
  const today = useMemo(() => {
    const d = new Date();
    d.setHours(0, 0, 0, 0);
    return d;
  }, []);

  const days = useMemo(
    () => Array.from({ length: daysInMonth }, (_, i) => i + 1),
    [daysInMonth],
  );

  // ── Summary counts ───────────────────────────────────────────────────────────
  // Active today = everyone NOT on leave (default state for all employees).
  //   Onsite and WFH employees are still "active".
  //   Only "leave" removes someone from the active count.
  // WFH today   = explicitly marked wfh on today's date.
  // On leave    = explicitly marked leave on today's date.
  const totalMembers = teamMembers.length;

  // todayKey built from local date parts — avoids UTC timezone shift
  const todayKey = useMemo(() => {
    const d = today;
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  }, [today]);

  const { activeMembers, onsiteMembers, offsiteMembers, wfhMembers, onLeaveMembers } = useMemo(() => {
    const onsite: typeof teamMembers = [];
    const offsite: typeof teamMembers = [];
    const wfh: typeof teamMembers = [];
    const leave: typeof teamMembers = [];
    const active: typeof teamMembers = [];

    teamMembers.forEach((m) => {
      const event = teamSchedule[m.id]?.[todayKey];
      const type = event?.type;
      if (type === "leave") {
        leave.push(m);
      } else if (type === "wfh") {
        wfh.push(m);
        active.push(m);
      } else if (type === "onsite") {
        onsite.push(m);
        active.push(m);
      } else {
        // Default white (unmarked cell) is Offsite
        offsite.push(m);
        active.push(m);
      }
    });

    return {
      activeMembers: active,
      onsiteMembers: onsite,
      offsiteMembers: offsite,
      wfhMembers: wfh,
      onLeaveMembers: leave,
    };
  }, [teamMembers, teamSchedule, todayKey]);

  const shiftMembers = useMemo(() => {
    const map: Record<ShiftType, typeof teamMembers> = {
      General: [],
      Morning: [],
      Afternoon: [],
      Night: [],
    };
    teamMembers.forEach((m) => {
      const event = teamSchedule[m.id]?.[todayKey];
      const shift = event?.shift ?? DEFAULT_SHIFT;
      if (map[shift]) {
        map[shift].push(m);
      }
    });
    return map;
  }, [teamMembers, teamSchedule, todayKey]);

  const departmentOptions = useMemo(
    () =>
      [...new Set(teamMembers.map((m) => m.department).filter(Boolean))].sort((a, b) =>
        a.localeCompare(b),
      ),
    [teamMembers],
  );

  const onFloorRoleOptions = onFloorRoleMasterOptions;

  useEffect(() => {
    let cancelled = false;
    void teamDataService
      .getOnFloorRoleNames()
      .then((names) => {
        if (!cancelled) setOnFloorRoleMasterOptions(names);
      })
      .catch(() => {
        if (!cancelled) {
          toast.error("Could not load On Floor Role list from master catalog.");
          setOnFloorRoleMasterOptions([]);
        }
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const filteredMembers = useMemo(() => {
    let base = teamMembers;
    if (activeFilter.kind === "presence") {
      if (activeFilter.status === "onsite") base = onsiteMembers;
      else if (activeFilter.status === "offsite") base = offsiteMembers;
      else if (activeFilter.status === "wfh") base = wfhMembers;
      else if (activeFilter.status === "leave") base = onLeaveMembers;
    } else if (activeFilter.kind === "shift") {
      base = shiftMembers[activeFilter.shift as ShiftType] ?? teamMembers;
    }

    const q = searchQuery.trim().toLowerCase();
    return base.filter((m) => {
      if (deptFilter && m.department !== deptFilter) return false;
      if (
        onFloorRoleFilter &&
        normalizeOnFloorRole(m.jobRoleName) !== normalizeOnFloorRole(onFloorRoleFilter)
      ) {
        return false;
      }
      const liveStatus = getMemberLiveAllocationStatus(m, teamSchedule, todayKey);
      if (allocStatusFilter && liveStatus !== allocStatusFilter) return false;
      if (allocTypeFilter && m.allocationType !== allocTypeFilter) return false;
      if (q) {
        const hay = [
          m.name,
          m.employeeCode,
          m.department,
          m.designation,
          m.jobRoleName,
          m.reportingManagerName,
          m.allocatedProjectName,
          liveStatus,
          m.allocationType,
        ]
          .filter(Boolean)
          .join(" ")
          .toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }, [
    activeFilter,
    teamMembers,
    onsiteMembers,
    offsiteMembers,
    wfhMembers,
    onLeaveMembers,
    shiftMembers,
    searchQuery,
    deptFilter,
    onFloorRoleFilter,
    allocStatusFilter,
    allocTypeFilter,
    teamSchedule,
    todayKey,
  ]);

  const paginateRoster = roster === "all";
  const totalPages = totalPageCount(filteredMembers.length, pageSize);
  const currentPage = Math.min(page, totalPages);
  const visibleMembers = useMemo(
    () => (paginateRoster ? paginateSlice(filteredMembers, currentPage, pageSize) : filteredMembers),
    [paginateRoster, filteredMembers, currentPage, pageSize],
  );
  const pageRange = paginationRange(currentPage, pageSize, filteredMembers.length);

  useEffect(() => {
    setPage(1);
  }, [roster, activeFilter, pageSize, searchQuery, deptFilter, onFloorRoleFilter, allocStatusFilter, allocTypeFilter]);

  const rosterCache = useRef(new Map<string, TeamCalendarPayload>());
  const rosterInflight = useRef(new Map<string, Promise<TeamCalendarPayload>>());
  const liveRoster = useRef({ roster, month: selectedMonth, members: teamMembers, schedule: teamSchedule, configs: memberConfigs });
  liveRoster.current = { roster, month: selectedMonth, members: teamMembers, schedule: teamSchedule, configs: memberConfigs };

  const rememberLiveRoster = useCallback(() => {
    const live = liveRoster.current;
    if (live.members.length === 0) return;
    rosterCache.current.set(rosterCacheKey(live.month, live.roster), {
      members: live.members,
      schedule: live.schedule,
      configs: live.configs,
    });
  }, []);

  const showRoster = useCallback((data: TeamCalendarPayload) => {
    setTeamMembers(data.members);
    setTeamSchedule(data.schedule);
    setMemberConfigs(data.configs);
  }, []);

  const fetchRoster = useCallback((month: Date, scope: Roster) => {
    const key = rosterCacheKey(month, scope);
    const cached = rosterCache.current.get(key);
    if (cached) return Promise.resolve(cached);
    const pending = rosterInflight.current.get(key);
    if (pending) return pending;
    const start = new Date(month.getFullYear(), month.getMonth(), 1);
    const end = new Date(month.getFullYear(), month.getMonth() + 1, 0);
    let from = makeDateKeyFromDate(start);
    let to = makeDateKeyFromDate(end);
    if (todayKey < from) from = todayKey;
    if (todayKey > to) to = todayKey;
    const request = teamDataService.getCalendar(from, to, scope === "all").then((data) => {
      rosterCache.current.set(key, data);
      rosterInflight.current.delete(key);
      return data;
    }).catch((error: unknown) => {
      rosterInflight.current.delete(key);
      throw error;
    });
    rosterInflight.current.set(key, request);
    return request;
  }, [todayKey]);

  const loadCalendar = useCallback(async (month: Date) => {
    const scope = liveRoster.current.roster;
    const key = rosterCacheKey(month, scope);
    rosterCache.current.delete(key);
    const data = await fetchRoster(month, scope);
    rosterCache.current.set(key, data);
    const live = liveRoster.current;
    if (
      live.roster === scope
      && live.month.getFullYear() === month.getFullYear()
      && live.month.getMonth() === month.getMonth()
    ) {
      showRoster(data);
    }
  }, [fetchRoster, showRoster]);

  const selectRoster = (next: Roster) => {
    if (next === roster) return;
    rememberLiveRoster();
    const cached = rosterCache.current.get(rosterCacheKey(selectedMonth, next));
    setRoster(next);
    setPage(1);
    if (cached) showRoster(cached);
  };

  useEffect(() => {
    let cancelled = false;
    const key = rosterCacheKey(selectedMonth, roster);
    const cached = rosterCache.current.get(key);
    if (cached) {
      showRoster(cached);
      setLoading(false);
    } else {
      setLoading(true);
      setTeamMembers([]);
      fetchRoster(selectedMonth, roster)
        .then((data) => {
          if (!cancelled) showRoster(data);
        })
        .catch((error: unknown) => {
          if (!cancelled) {
            toast.error(error instanceof Error ? error.message : "Could not load the team calendar");
          }
        })
        .finally(() => {
          if (!cancelled) setLoading(false);
        });
    }
    const other: Roster = roster === "all" ? "reportees" : "all";
    void fetchRoster(selectedMonth, other).catch(() => undefined);
    return () => {
      cancelled = true;
    };
  }, [selectedMonth, roster, fetchRoster, showRoster]);

  const reportSaveError = useCallback((error: unknown) => {
    toast.error(error instanceof Error ? error.message : "Could not save the team calendar");
    void loadCalendar(selectedMonth).catch(() => undefined);
  }, [loadCalendar, selectedMonth]);

  // ── Handlers ─────────────────────────────────────────────────────────────────
  const isLockedMemberKey = (memberId: string, dateKey: string) => {
    const memberConfig = memberConfigs[memberId] || DEFAULT_MEMBER_SCHEDULE_CONFIG;
    const isHoliday = memberConfig.holidays.some((h) => h.date === dateKey);
    const date = parseDateKey(dateKey);
    date.setHours(0, 0, 0, 0);
    return date < today || isHoliday;
  };

  const handleSaveMemberSchedule = (memberId: string, updatedConfig: MemberScheduleConfig) => {
    setMemberConfigs((prev) => ({
      ...prev,
      [memberId]: updatedConfig,
    }));

    const workingDaysSet = new Set(updatedConfig.workingDays ?? [1, 2, 3, 4, 5]);

    // Synchronize schedule entries for this member
    setTeamSchedule((current) => {
      const next = { ...current };
      const memberSched = { ...(next[memberId] ?? {}) };

      // Clear removed custom holidays (preserve explicit attendance / shifts)
      const activeHolidayDates = new Set(updatedConfig.holidays.map((h) => h.date));
      for (const [dateKey, evt] of Object.entries(memberSched)) {
        if (evt.type === "holiday" && !activeHolidayDates.has(dateKey)) {
          delete memberSched[dateKey];
        }
      }

      // If dates are now weekly offs, clear any old weekday attendance so they show as Weekly Off
      for (const [dateKey, evt] of Object.entries(memberSched)) {
        const d = parseDateKey(dateKey);
        if (!workingDaysSet.has(d.getDay()) && evt.type !== "holiday") {
          delete memberSched[dateKey];
        }
      }

      // Add or update configured holidays
      for (const h of updatedConfig.holidays) {
        memberSched[h.date] = {
          type: "holiday",
          title: h.name,
        };
      }

      next[memberId] = memberSched;
      return next;
    });

    void teamDataService.saveSchedule(memberId, updatedConfig).catch(reportSaveError);
  };

  const changeMonth = (amount: number) => {
    setOpenCell(null);
    setFocusedCell(null);
    setRangeAnchor(null);
    setSelectedMonth(
      (c) => new Date(c.getFullYear(), c.getMonth() + amount, 1),
    );
  };

  const focusCell = (memberId: string, dateKey: string) => {
    setFocusedCell({ memberId, dateKey });
    requestAnimationFrame(() => {
      const button = document.querySelector<HTMLButtonElement>(`[data-cell="${memberId}-${dateKey}"]`);
      button?.focus();
    });
  };

  const writeShift = (memberId: string, dateKeys: string[], shift: ShiftType | undefined) => {
    setTeamSchedule((current) =>
      applyShiftToMemberDates(current, memberId, dateKeys, shift, (dateKey) =>
        isLockedMemberKey(memberId, dateKey),
      ),
    );
    if (shift) setLastUsedShift(shift);
    const unlocked = dateKeys.filter((dateKey) => !isLockedMemberKey(memberId, dateKey));
    if (!shift || unlocked.length === 0) return;
    void teamDataService.upsertDays({ employeeId: memberId, dates: unlocked, shift }).catch(reportSaveError);
  };

  const handleCellToggle = (memberId: string, date: Date, shiftKey: boolean) => {
    const dateKey = makeDateKeyFromDate(date);
    if (isLockedMemberKey(memberId, dateKey)) return;

    if (shiftKey && rangeAnchor?.memberId === memberId) {
      if (lastUsedShift) {
        writeShift(memberId, getDateKeysInRange(rangeAnchor.dateKey, dateKey), lastUsedShift);
        setOpenCell(null);
        return;
      }
      setOpenCell({ memberId, dateKey });
      return;
    }

    setRangeAnchor({ memberId, dateKey });
    setOpenCell((current) => {
      if (current?.memberId === memberId && current.dateKey === dateKey) return null;
      return { memberId, dateKey };
    });
  };

  const handleAttendanceSelect = (
    memberId: string,
    date: Date,
    type: SelectableAttendanceType,
  ) => {
    const dateKey = makeDateKeyFromDate(date);
    const existing = teamSchedule[memberId]?.[dateKey];
    setTeamSchedule((current) => {
      const currentEvent = current[memberId]?.[dateKey];
      const memberSchedule = { ...current[memberId] };
      if (type === "clear") {
        if (currentEvent?.shift) {
          memberSchedule[dateKey] = { shift: currentEvent.shift };
        } else {
          delete memberSchedule[dateKey];
        }
      } else if (type === "leave") {
        // Leave has NO shift data: completely clear shift and remove "G"
        memberSchedule[dateKey] = {
          type: "leave",
          title: attendanceMeta.leave.label,
          shift: undefined,
        };
      } else {
        memberSchedule[dateKey] = {
          ...currentEvent,
          type,
          title: attendanceMeta[type].label,
          shift: currentEvent?.shift ?? DEFAULT_SHIFT,
        };
      }
      return { ...current, [memberId]: memberSchedule };
    });

    // When clicked on leave, directly mark and close menu immediately (no waiting for shift)
    if (type === "leave") {
      setOpenCell(null);
    }

    if (!isLockedMemberKey(memberId, dateKey)) {
      void teamDataService
        .upsertDays({
          employeeId: memberId,
          dates: [dateKey],
          attendance: type,
          ...(type === "clear" || type === "leave"
            ? {}
            : { shift: existing?.shift ?? DEFAULT_SHIFT }),
        })
        .catch(reportSaveError);
    }
  };

  const handleShiftSelect = (
    memberId: string,
    date: Date,
    shift: ShiftType | "clear",
  ) => {
    const dateKey = makeDateKeyFromDate(date);
    const currentEvent = teamSchedule[memberId]?.[dateKey];
    // If user assigns a shift to a day that was on leave, clear leave so it becomes active
    if (currentEvent?.type === "leave") {
      setTeamSchedule((current) => {
        const memberSchedule = { ...current[memberId] };
        memberSchedule[dateKey] = {
          type: undefined,
          shift: shift === "clear" ? DEFAULT_SHIFT : shift,
        };
        return { ...current, [memberId]: memberSchedule };
      });
      void teamDataService
        .upsertDays({
          employeeId: memberId,
          dates: [dateKey],
          attendance: "clear",
          shift: shift === "clear" ? DEFAULT_SHIFT : shift,
        })
        .catch(reportSaveError);
    } else {
      writeShift(memberId, [dateKey], shift === "clear" ? DEFAULT_SHIFT : shift);
    }
    setOpenCell(null);
  };

  const handleApplyWeek = (memberId: string, date: Date) => {
    const keys = getMonFriKeys(date);
    const existingShift = teamSchedule[memberId]?.[makeDateKeyFromDate(date)]?.shift;
    const shift = existingShift ?? lastUsedShift ?? DEFAULT_SHIFT;
    writeShift(memberId, keys, shift);
    setOpenCell(null);
  };

  useEffect(() => {
    if (!focusedCell) return;

    const handler = (event: KeyboardEvent) => {
      if (event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement) {
        return;
      }

      if (event.key === "Escape") {
        setOpenCell(null);
        setRangeAnchor(null);
        return;
      }

      const mappedShift = shiftKeyMap[event.key.toLowerCase()];
      if (mappedShift && !event.metaKey && !event.ctrlKey && !event.altKey) {
        if (!isLockedMemberKey(focusedCell.memberId, focusedCell.dateKey)) {
          event.preventDefault();
          writeShift(focusedCell.memberId, [focusedCell.dateKey], mappedShift);
          setOpenCell(null);
        }
        return;
      }

      if (event.key === "Backspace" || event.key === "Delete") {
        if (!isLockedMemberKey(focusedCell.memberId, focusedCell.dateKey)) {
          event.preventDefault();
          writeShift(focusedCell.memberId, [focusedCell.dateKey], DEFAULT_SHIFT);
        }
        return;
      }

      const memberIndex = visibleMembers.findIndex((member) => member.id === focusedCell.memberId);
      const currentDay = parseDateKey(focusedCell.dateKey).getDate();
      if (memberIndex < 0) return;

      let nextMemberIndex = memberIndex;
      let nextDay = currentDay;
      if (event.key === "ArrowLeft") nextDay = currentDay - 1;
      else if (event.key === "ArrowRight") nextDay = currentDay + 1;
      else if (event.key === "ArrowUp") nextMemberIndex = memberIndex - 1;
      else if (event.key === "ArrowDown") nextMemberIndex = memberIndex + 1;
      else return;

      event.preventDefault();
      if (nextDay < 1 || nextDay > daysInMonth) return;
      if (nextMemberIndex < 0 || nextMemberIndex >= visibleMembers.length) return;

      setOpenCell(null);
      focusCell(visibleMembers[nextMemberIndex].id, makeDateKey(year, monthIndex, nextDay));
    };

    document.addEventListener("keydown", handler);
    return () => document.removeEventListener("keydown", handler);
  }, [focusedCell, visibleMembers, daysInMonth, year, monthIndex, memberConfigs, today, reportSaveError]);

  const hasActiveToolbarFilters = Boolean(
    searchQuery.trim() ||
      deptFilter ||
      onFloorRoleFilter ||
      allocStatusFilter ||
      allocTypeFilter ||
      activeFilter.kind !== "all",
  );

  const clearToolbarFilters = () => {
    setSearchQuery("");
    setDeptFilter("");
    setOnFloorRoleFilter("");
    setAllocStatusFilter("");
    setAllocTypeFilter("");
    setActiveFilter({ kind: "all" });
  };

  const filterSelectClass = (active: boolean) =>
    cn(
      "h-9 w-full rounded-md border bg-card px-3 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:border-primary transition-all",
      active
        ? "border-blue-500/50 font-medium text-foreground bg-blue-500/5"
        : "border-input text-muted-foreground",
    );

  // ── Render ────────────────────────────────────────────────────────────────────
  return (
    <AppShell
      title="Team Dashboard"
      subtitle="Reporting team, availability, and leave visibility"
    >
      <div className="space-y-4">
        <div className="flex gap-0.5 rounded-lg border border-border/80 bg-muted/60 p-1 text-xs shadow-inner w-fit">
          <button
            type="button"
            onClick={() => selectRoster("reportees")}
            aria-label="My reportees"
            className={`inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-all duration-150 ${
              roster === "reportees"
                ? "bg-blue-600 text-white shadow-xs"
                : "text-muted-foreground hover:text-foreground"
            }`}
          >
            <Users className="h-3.5 w-3.5" />
            My Reportees
          </button>
          <button
            type="button"
            onClick={() => selectRoster("all")}
            aria-label="All employees"
            className={`inline-flex items-center gap-1.5 rounded-md px-3 py-1.5 font-semibold transition-all duration-150 ${
              roster === "all"
                ? "bg-blue-600 text-white shadow-xs"
                : "text-muted-foreground hover:text-foreground"
            }`}
          >
            <UsersRound className="h-3.5 w-3.5" />
            All Employees
          </button>
        </div>
        {loading && teamMembers.length === 0 && (
          <p className="text-sm text-muted-foreground">Loading team calendar…</p>
        )}
        {!loading && teamMembers.length === 0 && (
          <p className="text-sm text-muted-foreground">
            {roster === "all"
              ? "No employees are in the database yet."
              : "No employees report to you yet."}
          </p>
        )}
        {/* Consolidated Minimalist Command Cards (Presence & Shift Coverage) */}
        <section className="grid gap-3.5 grid-cols-1 md:grid-cols-2">
          <PresenceCard
            totalMembers={totalMembers}
            activeMembers={activeMembers}
            onsiteMembers={onsiteMembers}
            offsiteMembers={offsiteMembers}
            wfhMembers={wfhMembers}
            onLeaveMembers={onLeaveMembers}
            activeFilter={activeFilter}
            onSelectFilter={setActiveFilter}
          />
          <ShiftCoverageCard
            totalMembers={totalMembers}
            shiftMembers={shiftMembers}
            activeFilter={activeFilter}
            onSelectFilter={setActiveFilter}
          />
        </section>

        {/* Team calendar */}
        <section>
          <div className="flex items-center justify-between gap-2 flex-wrap mb-3">
            <div>
              <h2 className="text-sm font-semibold">Team calendar & resource pool</h2>
            </div>

            {/* Filter badge if active */}
            {activeFilter.kind !== "all" && (
              <div className="flex items-center gap-2 rounded-full bg-primary/10 border border-primary/20 px-3 py-1 text-xs font-semibold text-primary">
                <span>
                  Filtered:{" "}
                  <strong>
                    {activeFilter.kind === "presence"
                      ? activeFilter.status === "onsite"
                        ? "Onsite"
                        : activeFilter.status === "offsite"
                        ? "Offsite"
                        : activeFilter.status === "wfh"
                        ? "WFH"
                        : "On Leave"
                      : `${activeFilter.shift} Shift`}
                  </strong>{" "}
                  ({filteredMembers.length} member{filteredMembers.length === 1 ? "" : "s"})
                </span>
                <button
                  type="button"
                  onClick={() => setActiveFilter({ kind: "all" })}
                  className="flex h-4 w-4 items-center justify-center rounded-full hover:bg-primary/20 transition-colors"
                  title="Clear filter"
                >
                  <X className="h-3 w-3" />
                </button>
              </div>
            )}
          </div>

          {/* Team calendar & resource pool filters (matches Employee Directory bar) */}
          <div className="mb-3 rounded-xl border border-border bg-card p-3.5 shadow-xs">
            <div className="flex flex-col md:flex-row items-stretch md:items-center gap-2.5">
              <div className="relative flex-1 min-w-[220px]">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="Search resource, ID, or project…"
                  className="h-9 w-full rounded-md border border-input bg-background pl-9 pr-8 text-xs font-normal text-foreground placeholder:text-muted-foreground outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:border-primary transition-all"
                />
                {searchQuery && (
                  <button
                    type="button"
                    onClick={() => setSearchQuery("")}
                    className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground p-0.5"
                    title="Clear search"
                  >
                    <X className="h-3.5 w-3.5" />
                  </button>
                )}
              </div>

              <div className="w-full md:w-44 shrink-0">
                <select
                  value={deptFilter}
                  onChange={(e) => setDeptFilter(e.target.value)}
                  aria-label="Filter by Department"
                  className={filterSelectClass(Boolean(deptFilter))}
                >
                  <option value="">All Departments</option>
                  {departmentOptions.map((dept) => (
                    <option key={dept} value={dept}>
                      {dept}
                    </option>
                  ))}
                </select>
              </div>

              <div className="w-full md:w-48 shrink-0">
                <select
                  value={onFloorRoleFilter}
                  onChange={(e) => setOnFloorRoleFilter(e.target.value)}
                  aria-label="Filter by On Floor Role"
                  className={filterSelectClass(Boolean(onFloorRoleFilter))}
                >
                  <option value="">All On Floor Roles</option>
                  {onFloorRoleOptions.map((role) => (
                    <option key={role} value={role}>
                      {role}
                    </option>
                  ))}
                </select>
              </div>

              <div className="w-full md:w-48 shrink-0">
                <select
                  value={allocStatusFilter}
                  onChange={(e) => setAllocStatusFilter(e.target.value as "" | PoolAllocationStatus)}
                  aria-label="Filter by Allocation Status"
                  className={filterSelectClass(Boolean(allocStatusFilter))}
                >
                  <option value="">All Allocation Statuses</option>
                  <option value="Free">Free</option>
                  <option value="Occupied">Occupied</option>
                  <option value="On Leave">On Leave</option>
                </select>
              </div>

              <div className="w-full md:w-44 shrink-0">
                <select
                  value={allocTypeFilter}
                  onChange={(e) => setAllocTypeFilter(e.target.value as "" | PoolAllocationType)}
                  aria-label="Filter by Allocation Type"
                  className={filterSelectClass(Boolean(allocTypeFilter))}
                >
                  <option value="">All Allocation Types</option>
                  <option value="Dedicated">Dedicated</option>
                  <option value="Shared">Shared</option>
                </select>
              </div>

              <div className="w-20 shrink-0 flex items-center">
                {hasActiveToolbarFilters && (
                  <button
                    type="button"
                    onClick={clearToolbarFilters}
                    className="h-9 inline-flex items-center justify-center gap-1.5 rounded-md border border-dashed border-border px-3 text-xs font-medium text-muted-foreground hover:bg-muted hover:text-foreground transition-colors"
                  >
                    <RotateCcw className="h-3.5 w-3.5" />
                    <span>Reset</span>
                  </button>
                )}
              </div>
            </div>
          </div>

          <div className="relative z-0 mt-5 isolate overflow-hidden rounded-[22px] bg-[#fbfbfc] shadow-[inset_0_0.5px_0_rgba(255,255,255,1),inset_0_0_0_0.5px_rgba(255,255,255,0.7),0_0_0_0.5px_rgba(0,0,0,0.18),0_18px_48px_-20px_rgba(15,23,42,0.28)]">
            <div className="border-b border-black/[0.06] bg-white/45 px-5 py-3.5 backdrop-blur-xl backdrop-saturate-150">
              {/* ── Month navigation ── */}
              <div className="flex items-center gap-3">
                {/* Month arrows */}
                <button
                  type="button"
                  aria-label="Previous month"
                  onClick={() => changeMonth(-1)}
                  className="flex h-6 w-6 items-center justify-center rounded-[3px] bg-[#5a49b8] text-white transition hover:bg-[#4e3fa4]"
                >
                  <ChevronLeft className="h-3.5 w-3.5" />
                </button>
                <span className="min-w-[76px] text-center text-xs font-semibold text-[#586174]">
                  {monthFormatter.format(selectedMonth)}
                </span>
                <button
                  type="button"
                  aria-label="Next month"
                  onClick={() => changeMonth(1)}
                  className="flex h-6 w-6 items-center justify-center rounded-[3px] bg-[#5a49b8] text-white transition hover:bg-[#4e3fa4]"
                >
                  <ChevronRight className="h-3.5 w-3.5" />
                </button>
              </div>
            </div>

            <div className="overflow-x-auto">
            <div
              ref={teamCalendarRef}
              data-team-calendar=""
              className="w-full"
              style={{ minWidth: calendarMinWidth }}
            >
              <div className="flex w-full border-b border-[#edf0f4]">
                <aside
                  className={`sticky left-0 flex shrink-0 flex-col border-r border-white/50 shadow-[inset_1px_0_0_rgba(255,255,255,0.7)] backdrop-blur-[28px] backdrop-saturate-150 ${
                    openCell
                      ? "z-[560] bg-white/98 dark:bg-slate-950/98"
                      : "z-10 bg-white/45"
                  }`}
                  style={{ width: CALENDAR_NAME_COL_PX }}
                >
                  <div
                    className="shrink-0 border-b border-black/[0.04]"
                    style={{ height: CALENDAR_HEADER_PX }}
                  />
                  {visibleMembers.map((member, memberIdx) => {
                    const viewOnly = roster === "all" && member.directReport === false;
                    const liveStatus = getMemberLiveAllocationStatus(member, teamSchedule, todayKey);
                    const isNameRowActive = openCell?.memberId === member.id;
                    const suppressNativeTitle = Boolean(openCell);
                    return (
                    <div
                      key={member.id}
                      className={`flex items-center gap-2.5 px-3 ${
                        memberIdx < visibleMembers.length - 1 ? "border-b border-[#edf0f4]" : ""
                      } ${isNameRowActive ? "relative z-[561] bg-white/98 dark:bg-slate-950/98" : ""}`}
                      style={{ height: CALENDAR_ROW_PX }}
                    >
                      <div
                        className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-[10px] font-bold text-white shadow-2xs"
                        style={{ backgroundColor: member.avatarColor }}
                      >
                        {member.initials}
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center justify-between gap-1">
                          <p
                            className="truncate text-[13px] font-semibold text-[#3d3d5c] leading-tight"
                            title={suppressNativeTitle ? undefined : member.name}
                          >
                            {member.name}
                          </p>
                          <div className="flex shrink-0 items-center gap-1">
                            <button
                              type="button"
                              onClick={() => setAllocRequestMember(member)}
                              className="flex h-6 w-6 shrink-0 items-center justify-center rounded-md border border-primary/20 bg-primary/5 text-primary hover:bg-primary/15 transition-colors"
                              title={`Request Allocation for ${member.name}`}
                              aria-label={`Request allocation for ${member.name}`}
                            >
                              <UserPlus className="h-3.5 w-3.5" />
                            </button>
                            <button
                              type="button"
                              onClick={() => setWorkloadMember(member)}
                              className="flex h-6 w-6 shrink-0 items-center justify-center rounded-md border border-black/10 bg-white/80 text-[#586174] hover:bg-[#f0eef9] hover:text-[#5a49b8] transition-colors"
                              title={`Workload & Tasks for ${member.name}`}
                              aria-label={`Workload and tasks for ${member.name}`}
                            >
                              <Eye className="h-3.5 w-3.5" />
                            </button>
                            {!viewOnly && (
                              <button
                                type="button"
                                onClick={() => setScheduleDialogMember(member)}
                                className="flex h-6 w-6 shrink-0 items-center justify-center rounded-md border border-transparent text-[#8b93a3] hover:border-black/10 hover:bg-[#f0eef9] hover:text-[#5a49b8] transition-all"
                                title={`Configure working days, holidays & comments for ${member.name}`}
                                aria-label={`Configure schedule for ${member.name}`}
                              >
                                <CalendarCog className="h-3.5 w-3.5" />
                              </button>
                            )}
                          </div>
                        </div>
                        <p
                          className="truncate text-[10.5px] text-[#8b93a3] leading-tight mt-0.5"
                          title={suppressNativeTitle ? undefined : member.designation}
                        >
                          {member.designation}
                        </p>
                        <div className="mt-1 flex items-center gap-1 flex-wrap">
                          <TeamAllocationStatusBadge status={liveStatus} compact />
                          {member.allocationType && (
                            <TeamAllocationTypeBadge type={member.allocationType} compact />
                          )}
                        </div>
                      </div>
                    </div>
                    );
                  })}
                </aside>

                <div
                  className="min-w-0 flex-1"
                  style={{ minWidth: daysInMonth * CALENDAR_DAY_COL_PX, paddingRight: CALENDAR_END_PAD_PX }}
                >
                  <div
                    className="grid w-full items-center border-b border-[#edf0f4]"
                    style={{ height: CALENDAR_HEADER_PX, gridTemplateColumns: dayGridTemplate }}
                  >
                      {days.map((day) => {
                        const date = new Date(year, monthIndex, day);
                        const weekday = weekdayFormatter.format(date).slice(0, 2);
                        const dateKey = makeDateKey(year, monthIndex, day);
                        const indicatorColor = getDayIndicator(teamSchedule, teamMembers, year, monthIndex, day);
                        const weekend = isWeekendDate(date);
                        const isToday = dateKey === todayKey;
                        const isPast = date < today && !isToday;
                        return (
                          <div
                            key={day}
                            className={`relative flex h-full items-center justify-center text-[11px] font-bold border-b border-r border-[#edf0f4] ${
                              isToday
                                ? "bg-primary/20 text-primary"
                                : isPast
                                  ? "bg-[#ebedf3] text-[#8a94a6]"
                                  : weekend
                                    ? "bg-[#f3f4f7] text-[#8a94a6]"
                                    : "bg-white text-[#334155]"
                            }`}
                          >
                            {weekday}
                            {indicatorColor && (
                              <span className="absolute bottom-1 left-1/2 h-[3px] w-[3px] -translate-x-1/2 rounded-full"
                                style={{ backgroundColor: indicatorColor }} />
                            )}
                          </div>
                        );
                      })}
                  </div>

                  {visibleMembers.map((member, memberIdx) => {
                    const viewOnly = roster === "all" && member.directReport === false;
                    const isLastRow = memberIdx === visibleMembers.length - 1;
                    const isRowActive = openCell?.memberId === member.id;
                    const memberConfig = memberConfigs[member.id] || DEFAULT_MEMBER_SCHEDULE_CONFIG;
                    const memberHolidaysMap = new Map(memberConfig.holidays.map((h) => [h.date, h]));
                    const workingDaysSet = new Set(memberConfig.workingDays ?? [1, 2, 3, 4, 5]);

                    return (
                      <div
                        key={member.id}
                        className={`grid w-full overflow-visible border-b border-[#edf0f4] last:border-b-0 ${
                          isRowActive ? "relative z-10" : "relative z-0"
                        }`}
                        style={{ height: CALENDAR_ROW_PX, gridTemplateColumns: dayGridTemplate }}
                      >
                        {days.map((day) => {
                          const date = new Date(year, monthIndex, day);
                          const dateKey = makeDateKeyFromDate(date);
                          const isOpen = openCell?.memberId === member.id && openCell.dateKey === dateKey;
                          const holidayEntry = memberHolidaysMap.get(dateKey);
                          const isHoliday = Boolean(holidayEntry);
                          const isWeeklyOff = !workingDaysSet.has(date.getDay());
                          const monFri = getMonFriKeys(date);
                          const dayAllocation = resolveDayAllocation(member, dateKey);

                          return (
                            <CalendarDayCell
                              key={`${member.id}-${dateKey}`}
                              memberId={member.id}
                              memberName={member.name}
                              date={date}
                              schedule={teamSchedule}
                              isOpen={isOpen}
                              isFocused={focusedCell?.memberId === member.id && focusedCell.dateKey === dateKey}
                              isPast={date < today}
                              readOnly={viewOnly}
                              isHoliday={isHoliday}
                              isToday={dateKey === todayKey}
                              isLastRow={isLastRow}
                              holidayName={holidayEntry?.name}
                              holidayComment={holidayEntry?.comment}
                              isWeeklyOff={isWeeklyOff}
                              weekRangeLabel={`${formatDateDMY(monFri[0])} to ${formatDateDMY(monFri[4])}`}
                              dayAllocation={dayAllocation}
                              onToggle={(shiftKey) => handleCellToggle(member.id, date, shiftKey)}
                              onClose={() => setOpenCell(null)}
                              onFocusCell={() => setFocusedCell({ memberId: member.id, dateKey })}
                              onSelectAttendance={(type) => handleAttendanceSelect(member.id, date, type)}
                              onSelectShift={(shift) => handleShiftSelect(member.id, date, shift)}
                              onApplyWeek={() => handleApplyWeek(member.id, date)}
                            />
                          );
                        })}
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
            </div>

              <div className="flex flex-wrap items-center gap-x-7 gap-y-4 border-t border-black/[0.06] bg-white/45 px-5 py-4 text-[11px] font-medium text-[#6f7685] backdrop-blur-xl backdrop-saturate-150">
                <Legend color={attendanceMeta.onsite.solid}    text="Onsite" />
                <Legend color={attendanceMeta.wfh.solid}       text="Work From Home" />
                <Legend color={attendanceMeta.leave.solid}     text="Leave" />
                <Legend color={attendanceMeta.weeklyOff.solid} text="Weekly Off" />
                <Legend color={attendanceMeta.holiday.solid}   text="Holiday" />
                <span className="h-3 w-px bg-[#e5e8ef]" />
                <ShiftChipLegend chip={shiftMeta.Morning.chip}   text="Morning" />
                <ShiftChipLegend chip={shiftMeta.Afternoon.chip} text="Afternoon" />
                <ShiftChipLegend chip={shiftMeta.Night.chip}     text="Night" />
                <ShiftChipLegend chip={shiftMeta.General.chip}   text="General (default)" />
                <span className="h-3 w-px bg-[#e5e8ef]" />
                <div className="flex items-center gap-1.5 whitespace-nowrap">
                  <span className="rounded bg-[#4f46e5] px-1.5 py-0.5 text-[8.5px] font-bold uppercase text-white">
                    DED
                  </span>
                  <span>Dedicated Project</span>
                </div>
                <div className="flex items-center gap-1.5 whitespace-nowrap">
                  <span className="rounded bg-[#0284c7] px-1.5 py-0.5 text-[8.5px] font-bold uppercase text-white">
                    SHR
                  </span>
                  <span>Shared Project</span>
                </div>
              </div>
              {paginateRoster && (
                <div className="flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-slate-300 dark:border-slate-700 bg-blue-50/80 dark:bg-blue-950/45 px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80">
                  <div className="flex items-center gap-3">
                    <span>
                      Showing{" "}
                      <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.from}</strong>
                      {" - "}
                      <strong className="font-semibold text-blue-950 dark:text-blue-100">{pageRange.to}</strong>
                      {" of "}
                      <strong className="font-semibold text-blue-950 dark:text-blue-100">{filteredMembers.length}</strong>
                      {" employees"}
                    </span>
                    <span className="text-slate-300 dark:text-slate-600">|</span>
                    <div className="flex items-center gap-1.5">
                      <span>Per page:</span>
                      <RowsPerPageSelect
                        value={pageSize}
                        onChange={setPageSize}
                        className="h-7 min-w-[3.25rem] rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-950/60 pl-2 pr-5 text-xs font-medium text-blue-950 dark:text-blue-100 outline-none cursor-pointer hover:bg-blue-100/50 dark:hover:bg-blue-900/40 transition-colors focus-visible:ring-1 focus-visible:ring-blue-500"
                      />
                    </div>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <button
                      type="button"
                      onClick={() => setPage((p) => Math.max(1, p - 1))}
                      disabled={currentPage <= 1}
                      className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
                    >
                      <ChevronLeft className="h-3.5 w-3.5" /> Previous
                    </button>
                    <span className="px-2 tabular-nums font-semibold text-blue-950 dark:text-blue-100">
                      {currentPage} / {totalPages}
                    </span>
                    <button
                      type="button"
                      onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                      disabled={currentPage >= totalPages}
                      className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
                    >
                      Next <ChevronRight className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
              )}
          </div>
        </section>

        {/* Per-Employee Working Days & Holidays Configuration Dialog */}
        <MemberScheduleDialog
          member={scheduleDialogMember}
          open={Boolean(scheduleDialogMember)}
          onOpenChange={(open) => {
            if (!open) setScheduleDialogMember(null);
          }}
          config={scheduleDialogMember ? memberConfigs[scheduleDialogMember.id] : undefined}
          onSave={handleSaveMemberSchedule}
        />

        {workloadMember && (
          <TeamWorkloadTasksModal
            member={workloadMember}
            liveStatus={getMemberLiveAllocationStatus(workloadMember, teamSchedule, todayKey)}
            onClose={() => setWorkloadMember(null)}
          />
        )}

        {allocRequestMember && (
          <TeamRequestAllocationModal
            member={allocRequestMember}
            colleagues={teamMembers}
            onClose={() => setAllocRequestMember(null)}
          />
        )}
      </div>
    </AppShell>
  );
}
