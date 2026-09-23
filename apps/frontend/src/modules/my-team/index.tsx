// ─── My Team Page ─────────────────────────────────────────────────────────────

import { useCallback, useEffect, useMemo, useState } from "react";
import {
  CalendarCog,
  ChevronLeft,
  ChevronRight,
  X,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { formatDateDMY } from "@/lib/utils";
import { toast } from "sonner";
import { teamDataService } from "./services/teamDataService";
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
  SelectableAttendanceType,
  ShiftType,
  TeamMember,
  TeamSchedule,
} from "./types";
import { DEFAULT_MEMBER_SCHEDULE_CONFIG } from "./types";
import { CalendarDayCell } from "./components/CalendarDayCell";
import { MemberScheduleDialog } from "./components/MemberScheduleDialog";
import { Legend, ShiftChipLegend } from "./components/Legend";
import { PresenceCard, type ActiveFilter } from "./components/PresenceCard";
import { ShiftCoverageCard } from "./components/ShiftCoverageCard";

export function MyTeamPage() {
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

  const [activeFilter, setActiveFilter] = useState<ActiveFilter>({ kind: "all" });
  const [openCell, setOpenCell] = useState<OpenCell>(null);
  const [focusedCell, setFocusedCell] = useState<CellRef | null>(null);
  const [rangeAnchor, setRangeAnchor] = useState<CellRef | null>(null);
  const [lastUsedShift, setLastUsedShift] = useState<ShiftType | null>(null);

  // ── Derived calendar values ──────────────────────────────────────────────────
  const year = selectedMonth.getFullYear();
  const monthIndex = selectedMonth.getMonth();
  const daysInMonth = new Date(year, monthIndex + 1, 0).getDate();
  const calendarMinWidth = CALENDAR_NAME_COL_PX + daysInMonth * CALENDAR_DAY_COL_PX + CALENDAR_END_PAD_PX;
  const dayGridTemplate = `repeat(${daysInMonth}, minmax(${CALENDAR_DAY_COL_PX}px, 1fr))`;

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

  const { activeMembers, onsiteMembers, wfhMembers, onLeaveMembers } = useMemo(() => {
    const onsite: typeof teamMembers = [];
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
      } else if (m.status === "WFH") {
        wfh.push(m);
        active.push(m);
      } else if (m.status === "On Leave" && !event?.shift) {
        leave.push(m);
      } else {
        onsite.push(m);
        active.push(m);
      }
    });

    return { activeMembers: active, onsiteMembers: onsite, wfhMembers: wfh, onLeaveMembers: leave };
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

  const filteredMembers = useMemo(() => {
    if (activeFilter.kind === "all") return teamMembers;
    if (activeFilter.kind === "presence") {
      if (activeFilter.status === "onsite") return onsiteMembers;
      if (activeFilter.status === "wfh") return wfhMembers;
      if (activeFilter.status === "leave") return onLeaveMembers;
    }
    if (activeFilter.kind === "shift") {
      return shiftMembers[activeFilter.shift as ShiftType] ?? teamMembers;
    }
    return teamMembers;
  }, [activeFilter, teamMembers, onsiteMembers, wfhMembers, onLeaveMembers, shiftMembers]);

  const loadCalendar = useCallback(async (month: Date) => {
    const start = new Date(month.getFullYear(), month.getMonth(), 1);
    const end = new Date(month.getFullYear(), month.getMonth() + 1, 0);
    let from = makeDateKeyFromDate(start);
    let to = makeDateKeyFromDate(end);
    if (todayKey < from) from = todayKey;
    if (todayKey > to) to = todayKey;
    const data = await teamDataService.getCalendar(from, to);
    setTeamMembers(data.members);
    setTeamSchedule(data.schedule);
    setMemberConfigs(data.configs);
  }, [todayKey]);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    loadCalendar(selectedMonth)
      .catch((error: unknown) => {
        if (!cancelled) {
          toast.error(error instanceof Error ? error.message : "Could not load the team calendar");
        }
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [selectedMonth, loadCalendar]);

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
    if (!isLockedMemberKey(memberId, dateKey)) {
      void teamDataService
        .upsertDays({
          employeeId: memberId,
          dates: [dateKey],
          attendance: type,
          ...(type === "clear" ? {} : { shift: existing?.shift ?? DEFAULT_SHIFT }),
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
    writeShift(memberId, [dateKey], shift === "clear" ? DEFAULT_SHIFT : shift);
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

      const memberIndex = filteredMembers.findIndex((member) => member.id === focusedCell.memberId);
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
      if (nextMemberIndex < 0 || nextMemberIndex >= filteredMembers.length) return;

      setOpenCell(null);
      focusCell(filteredMembers[nextMemberIndex].id, makeDateKey(year, monthIndex, nextDay));
    };

    document.addEventListener("keydown", handler);
    return () => document.removeEventListener("keydown", handler);
  }, [focusedCell, filteredMembers, daysInMonth, year, monthIndex, memberConfigs, today, reportSaveError]);

  // ── Render ────────────────────────────────────────────────────────────────────
  return (
    <AppShell
      title="Team Dashboard"
      subtitle="Reporting team, availability, and leave visibility"
    >
      <div className="space-y-4">
        {loading && teamMembers.length === 0 && (
          <p className="text-sm text-muted-foreground">Loading team calendar…</p>
        )}
        {!loading && teamMembers.length === 0 && (
          <p className="text-sm text-muted-foreground">
            No employees are linked under you as Engagement Manager, Manager, or Project Manager yet.
          </p>
        )}
        {/* Consolidated Minimalist Command Cards (Presence & Shift Coverage) */}
        <section className="grid gap-3.5 grid-cols-1 md:grid-cols-2">
          <PresenceCard
            totalMembers={totalMembers}
            activeMembers={activeMembers}
            onsiteMembers={onsiteMembers}
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
          <div className="flex items-center justify-between gap-2 flex-wrap mb-1">
            <div>
              <h2 className="text-sm font-semibold">Team calendar</h2>
              <p className="mt-0.5 text-xs text-muted-foreground">
                Click a future day to set attendance and shift. Shift+Click applies the last shift across a range. Keys: M A N G.
              </p>
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

          <div className="mt-5 overflow-hidden rounded-[22px] bg-[#fbfbfc] shadow-[inset_0_0.5px_0_rgba(255,255,255,1),inset_0_0_0_0.5px_rgba(255,255,255,0.7),0_0_0_0.5px_rgba(0,0,0,0.18),0_18px_48px_-20px_rgba(15,23,42,0.28)]">
            <div className="relative z-30 border-b border-black/[0.06] bg-white/45 px-5 py-3.5 backdrop-blur-xl backdrop-saturate-150">
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
              className="w-full"
              style={{ minWidth: calendarMinWidth }}
            >
              <div className="flex w-full border-b border-[#edf0f4]">
                <aside
                  className="sticky left-0 z-10 flex shrink-0 flex-col border-r border-white/50 bg-white/45 shadow-[inset_1px_0_0_rgba(255,255,255,0.7)] backdrop-blur-[28px] backdrop-saturate-150"
                  style={{ width: CALENDAR_NAME_COL_PX }}
                >
                  <div
                    className="shrink-0 border-b border-black/[0.04]"
                    style={{ height: CALENDAR_HEADER_PX }}
                  />
                  {filteredMembers.map((member, memberIdx) => (
                    <div
                      key={member.id}
                      className={`flex items-center gap-2.5 px-3.5 ${
                        memberIdx < filteredMembers.length - 1 ? "border-b border-[#edf0f4]" : ""
                      }`}
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
                            title={member.name}
                          >
                            {member.name}
                          </p>
                          <button
                            type="button"
                            onClick={() => setScheduleDialogMember(member)}
                            className="flex h-6 w-6 shrink-0 items-center justify-center rounded-md border border-transparent text-[#8b93a3] hover:border-black/10 hover:bg-[#f0eef9] hover:text-[#5a49b8] transition-all"
                            title={`Configure working days, holidays & comments for ${member.name}`}
                            aria-label={`Configure schedule for ${member.name}`}
                          >
                            <CalendarCog className="h-3.5 w-3.5" />
                          </button>
                        </div>
                        <p className="truncate text-[11px] text-[#8b93a3] leading-tight mt-0.5">
                          {member.designation}
                        </p>
                      </div>
                    </div>
                  ))}
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

                  {filteredMembers.map((member, memberIdx) => {
                    const isLastRow = memberIdx === filteredMembers.length - 1;
                    const isRowActive = openCell?.memberId === member.id;
                    const memberConfig = memberConfigs[member.id] || DEFAULT_MEMBER_SCHEDULE_CONFIG;
                    const memberHolidaysMap = new Map(memberConfig.holidays.map((h) => [h.date, h]));
                    const workingDaysSet = new Set(memberConfig.workingDays ?? [1, 2, 3, 4, 5]);

                    return (
                      <div
                        key={member.id}
                        className={`grid w-full overflow-visible border-b border-[#edf0f4] last:border-b-0 ${
                          isRowActive ? "relative z-40" : "relative z-0"
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
                              isHoliday={isHoliday}
                              isToday={dateKey === todayKey}
                              isLastRow={isLastRow}
                              holidayName={holidayEntry?.name}
                              holidayComment={holidayEntry?.comment}
                              isWeeklyOff={isWeeklyOff}
                              weekRangeLabel={`${formatDateDMY(monFri[0])} to ${formatDateDMY(monFri[4])}`}
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
              </div>
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
      </div>
    </AppShell>
  );
}
