// ─── My Team Page ─────────────────────────────────────────────────────────────

import { useEffect, useMemo, useRef, useState } from "react";
import {
  BriefcaseBusiness,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  Users,
  Plus,
  X,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { formatDateDMY } from "@/lib/utils";
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
  isDateLocked,
  isWeekendDate,
  makeDateKey,
  makeDateKeyFromDate,
  parseDateKey,
} from "./utils";
import type {
  CellRef,
  HolidayEntry,
  OpenCell,
  SelectableAttendanceType,
  ShiftType,
  TeamSchedule,
} from "./types";
import { CalendarDayCell } from "./components/CalendarDayCell";
import { Legend, ShiftChipLegend } from "./components/Legend";
import { SummaryCard } from "./components/SummaryCard";

export function MyTeamPage() {
  const teamMembers = useMemo(() => teamDataService.getTeamMembers(), []);

  // ── UI state ─────────────────────────────────────────────────────────────────
  const [selectedMonth, setSelectedMonth] = useState(() => {
    const now = new Date();
    return new Date(now.getFullYear(), now.getMonth(), 1);
  });

  const [teamSchedule, setTeamSchedule] = useState<TeamSchedule>(() => {
    const raw = teamDataService.createInitialSchedule(teamMembers);
    // Build today's key using LOCAL date (avoids UTC timezone shift)
    const now = new Date();
    const todayKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;

    const cleaned: TeamSchedule = {};
    for (const memberId of Object.keys(raw)) {
      cleaned[memberId] = {};
      for (const [dateKey, event] of Object.entries(raw[memberId])) {
        const isFuture = dateKey > todayKey;
        const shouldStrip = isFuture && (event.type === "onsite" || event.type === "wfh" || event.type === "holiday");
        if (!shouldStrip) {
          cleaned[memberId][dateKey] = event;
        } else if (event.shift) {
          cleaned[memberId][dateKey] = { shift: event.shift };
        }
      }
    }
    return cleaned;
  });

  const [openCell, setOpenCell] = useState<OpenCell>(null);
  const [focusedCell, setFocusedCell] = useState<CellRef | null>(null);
  const [rangeAnchor, setRangeAnchor] = useState<CellRef | null>(null);
  const [lastUsedShift, setLastUsedShift] = useState<ShiftType | null>(null);

  // ── Holiday popover state ────────────────────────────────────────────────────
  const [holidays, setHolidays] = useState<HolidayEntry[]>([]);
  const [holidayPanelOpen, setHolidayPanelOpen] = useState(false);
  const [holidayName, setHolidayName] = useState("");
  const [holidayError, setHolidayError] = useState("");
  // mini-calendar inside the popover
  const [pickerMonth, setPickerMonth] = useState(() => {
    const now = new Date();
    return new Date(now.getFullYear(), now.getMonth(), 1);
  });
  const [pickerSelectedDate, setPickerSelectedDate] = useState<string>(""); // YYYY-MM-DD
  const holidayBtnRef = useRef<HTMLDivElement>(null);

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

  // mini-calendar derived values
  const pickerYear       = pickerMonth.getFullYear();
  const pickerMonthIndex = pickerMonth.getMonth();
  const pickerDaysInMonth = new Date(pickerYear, pickerMonthIndex + 1, 0).getDate();
  const pickerFirstDow   = new Date(pickerYear, pickerMonthIndex, 1).getDay(); // 0=Sun

  const days = useMemo(
    () => Array.from({ length: daysInMonth }, (_, i) => i + 1),
    [daysInMonth],
  );

  // Build a map of dateKey → holiday name so CalendarDayCell can display the name on hover
  const holidayMap = useMemo(() => {
    const map: Record<string, string> = {};
    holidays.forEach((h) => { map[h.date] = h.name; });
    return map;
  }, [holidays]);

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

  const { activeCount, wfhCount, onLeaveCount, onsiteCount } = useMemo(() => {
    let wfh = 0, onLeave = 0, onsite = 0;
    teamMembers.forEach((m) => {
      const event = teamSchedule[m.id]?.[todayKey];
      const type = event?.type;
      if (type === "leave") {
        onLeave++;
      } else if (type === "wfh") {
        wfh++;
      } else if (type === "onsite") {
        onsite++;
      }
    });
    return { activeCount: totalMembers - onLeave, wfhCount: wfh, onLeaveCount: onLeave, onsiteCount: onsite };
  }, [teamMembers, teamSchedule, todayKey, totalMembers]);

  // ── Handlers ─────────────────────────────────────────────────────────────────
  const isLockedKey = (dateKey: string) => isDateLocked(dateKey, today, holidayMap);

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
    setTeamSchedule((current) => applyShiftToMemberDates(current, memberId, dateKeys, shift, isLockedKey));
    if (shift) setLastUsedShift(shift);
  };

  const handleCellToggle = (memberId: string, date: Date, shiftKey: boolean) => {
    const dateKey = makeDateKeyFromDate(date);
    if (date < today || holidayMap[dateKey]) return;

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
    setTeamSchedule((current) => {
      const existing = current[memberId]?.[dateKey];
      const memberSchedule = { ...current[memberId] };
      if (type === "clear") {
        if (existing?.shift) {
          memberSchedule[dateKey] = { shift: existing.shift };
        } else {
          delete memberSchedule[dateKey];
        }
      } else {
        memberSchedule[dateKey] = {
          ...existing,
          type,
          title: attendanceMeta[type].label,
          shift: existing?.shift ?? DEFAULT_SHIFT,
        };
      }
      return { ...current, [memberId]: memberSchedule };
    });
    setOpenCell(null);
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

  // Close holiday panel when clicking outside
  useEffect(() => {
    if (!holidayPanelOpen) return;
    const handler = (e: MouseEvent) => {
      if (holidayBtnRef.current && !holidayBtnRef.current.contains(e.target as Node)) {
        setHolidayPanelOpen(false);
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [holidayPanelOpen]);

  useEffect(() => {
    if (!focusedCell || holidayPanelOpen) return;

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
        if (!isLockedKey(focusedCell.dateKey)) {
          event.preventDefault();
          writeShift(focusedCell.memberId, [focusedCell.dateKey], mappedShift);
          setOpenCell(null);
        }
        return;
      }

      if (event.key === "Backspace" || event.key === "Delete") {
        if (!isLockedKey(focusedCell.dateKey)) {
          event.preventDefault();
          writeShift(focusedCell.memberId, [focusedCell.dateKey], DEFAULT_SHIFT);
        }
        return;
      }

      const memberIndex = teamMembers.findIndex((member) => member.id === focusedCell.memberId);
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
      if (nextMemberIndex < 0 || nextMemberIndex >= teamMembers.length) return;

      setOpenCell(null);
      focusCell(teamMembers[nextMemberIndex].id, makeDateKey(year, monthIndex, nextDay));
    };

    document.addEventListener("keydown", handler);
    return () => document.removeEventListener("keydown", handler);
  }, [focusedCell, holidayPanelOpen, teamMembers, daysInMonth, year, monthIndex, holidayMap, today]);

  // Add a holiday — applies to ALL team members on that date
  const handleAddHoliday = () => {
    setHolidayError("");
    if (!pickerSelectedDate) { setHolidayError("Please select a date."); return; }
    if (!holidayName.trim()) { setHolidayError("Please enter a holiday name."); return; }
    if (holidays.some((h) => h.date === pickerSelectedDate)) {
      setHolidayError("A holiday already exists on this date."); return;
    }

    const entry: HolidayEntry = { date: pickerSelectedDate, name: holidayName.trim() };
    setHolidays((prev) => [...prev, entry]);

    // Apply to every team member on that date
    setTeamSchedule((current) => {
      const next = { ...current };
      teamMembers.forEach((m) => {
        next[m.id] = {
          ...next[m.id],
          [pickerSelectedDate]: { type: "holiday", title: holidayName.trim() },
        };
      });
      return next;
    });

    // Reset panel
    setPickerSelectedDate("");
    setHolidayName("");
    setHolidayPanelOpen(false);
  };

  const handleRemoveHoliday = (dateKey: string) => {
    setHolidays((prev) => prev.filter((h) => h.date !== dateKey));
    // Remove the holiday event from all team members
    setTeamSchedule((current) => {
      const next = { ...current };
      teamMembers.forEach((m) => {
        if (next[m.id]?.[dateKey]?.type === "holiday") {
          const memberSchedule = { ...next[m.id] };
          delete memberSchedule[dateKey];
          next[m.id] = memberSchedule;
        }
      });
      return next;
    });
  };

  // ── Render ────────────────────────────────────────────────────────────────────
  return (
    <AppShell
      title="Team Dashboard"
      subtitle="Reporting team, availability, and leave visibility"
    >
      <div className="space-y-4">
        {/* Summary cards */}
        <section className="grid gap-3 md:grid-cols-4">
          <SummaryCard label="On leave today" current={onLeaveCount} total={totalMembers} icon={CalendarDays}     />
          <SummaryCard label="Active today"   current={activeCount}  total={totalMembers} icon={Users}            />
          <SummaryCard label="Onsite today"   current={onsiteCount}  total={totalMembers} icon={BriefcaseBusiness} />
          <SummaryCard label="WFH today"      current={wfhCount}     total={totalMembers} icon={BriefcaseBusiness} />
          
        </section>

        {/* Team calendar */}
        <section>
          <h2 className="text-sm font-semibold">Team calendar</h2>
          <p className="mt-1 text-xs text-muted-foreground">
            Click a future day to set attendance and shift. Shift+Click applies the last shift across a range. Keys: M A N G.
          </p>

          <div className="mt-5 overflow-hidden rounded-[22px] bg-[#fbfbfc] shadow-[inset_0_0.5px_0_rgba(255,255,255,1),inset_0_0_0_0.5px_rgba(255,255,255,0.7),0_0_0_0.5px_rgba(0,0,0,0.18),0_18px_48px_-20px_rgba(15,23,42,0.28)]">
            <div className="border-b border-black/[0.06] bg-white/45 px-5 py-3.5 backdrop-blur-xl backdrop-saturate-150">
              {/* ── Month navigation + Add Holiday button ── */}
              <div className="flex items-center gap-3 flex-wrap">

                {/* Month arrows */}
                <button type="button" aria-label="Previous month" onClick={() => changeMonth(-1)}
                  className="flex h-6 w-6 items-center justify-center rounded-[3px] bg-[#5a49b8] text-white transition hover:bg-[#4e3fa4]">
                  <ChevronLeft className="h-3.5 w-3.5" />
                </button>
                <span className="min-w-[76px] text-center text-xs font-semibold text-[#586174]">
                  {monthFormatter.format(selectedMonth)}
                </span>
                <button type="button" aria-label="Next month" onClick={() => changeMonth(1)}
                  className="flex h-6 w-6 items-center justify-center rounded-[3px] bg-[#5a49b8] text-white transition hover:bg-[#4e3fa4]">
                  <ChevronRight className="h-3.5 w-3.5" />
                </button>

                {/* Add Holiday button + popover */}
                <div ref={holidayBtnRef} className="relative ml-2">
                  <button
                    type="button"
                    onClick={() => {
                      setHolidayPanelOpen((o) => !o);
                      setHolidayError("");
                    }}
                    className="inline-flex items-center gap-1.5 rounded-md border border-[#a6c63a] bg-[#f4f9e8] px-3 py-1 text-[11px] font-semibold text-[#4a6b0a] transition hover:bg-[#e2ecc0]"
                  >
                    <Plus className="h-3.5 w-3.5" />
                    Add Holiday
                  </button>

                  {/* Popover panel */}
                  {holidayPanelOpen && (
                    <div className="absolute left-0 top-[calc(100%+6px)] z-[200] w-[260px] rounded-xl border border-[#e1e4eb] bg-white shadow-[0_8px_32px_rgba(34,42,62,0.16)]">
                      {/* Caret */}
                      <span className="absolute -top-[7px] left-5 h-3.5 w-3.5 rotate-45 border-l border-t border-[#e1e4eb] bg-white" />

                      {/* Mini calendar header */}
                      <div className="flex items-center justify-between border-b border-[#f0f2f5] px-3 py-2">
                        <button type="button" onClick={() => setPickerMonth((m) => new Date(m.getFullYear(), m.getMonth() - 1, 1))}
                          className="flex h-5 w-5 items-center justify-center rounded hover:bg-[#f0eef9] text-[#5a49b8]">
                          <ChevronLeft className="h-3 w-3" />
                        </button>
                        <span className="text-[11px] font-semibold text-[#3d3d5c]">
                          {new Intl.DateTimeFormat("en-US", { month: "long", year: "numeric" }).format(pickerMonth)}
                        </span>
                        <button type="button" onClick={() => setPickerMonth((m) => new Date(m.getFullYear(), m.getMonth() + 1, 1))}
                          className="flex h-5 w-5 items-center justify-center rounded hover:bg-[#f0eef9] text-[#5a49b8]">
                          <ChevronRight className="h-3 w-3" />
                        </button>
                      </div>

                      {/* Day-of-week labels */}
                      <div className="grid grid-cols-7 px-2 pt-2">
                        {["Su","Mo","Tu","We","Th","Fr","Sa"].map((d) => (
                          <div key={d} className="flex h-6 items-center justify-center text-[9px] font-bold text-[#9aa2b2]">{d}</div>
                        ))}
                      </div>

                      {/* Day grid */}
                      <div className="grid grid-cols-7 px-2 pb-2">
                        {/* Leading empty cells */}
                        {Array.from({ length: pickerFirstDow }).map((_, i) => (
                          <div key={`e${i}`} />
                        ))}
                        {Array.from({ length: pickerDaysInMonth }, (_, i) => i + 1).map((day) => {
                          const dateKey = makeDateKey(pickerYear, pickerMonthIndex, day);
                          const cellDate = new Date(pickerYear, pickerMonthIndex, day);
                          cellDate.setHours(0, 0, 0, 0);
                          const isPast = cellDate <= today; // past AND today are not selectable
                          const isSelected = pickerSelectedDate === dateKey;
                          const hasHoliday = holidays.some((h) => h.date === dateKey);
                          return (
                            <button
                              key={day}
                              type="button"
                              disabled={isPast || hasHoliday}
                              onClick={() => { setPickerSelectedDate(dateKey); setHolidayError(""); }}
                              className={`flex h-7 w-7 items-center justify-center rounded-full text-[11px] font-medium transition
                                ${isSelected ? "bg-[#a6c63a] text-white font-bold" : ""}
                                ${hasHoliday && !isSelected ? "bg-[#e2ecc0] text-[#4a6b0a] cursor-not-allowed" : ""}
                                ${isPast ? "text-[#c8cdd6] cursor-not-allowed" : !isSelected && !hasHoliday ? "text-[#374151] hover:bg-[#f0eef9] hover:text-[#5a49b8]" : ""}
                              `}
                            >
                              {day}
                            </button>
                          );
                        })}
                      </div>

                      {/* Selected date display */}
                      <div className="border-t border-[#f0f2f5] px-3 py-2">
                        <p className="mb-1 text-[10px] font-medium text-[#6b7280]">
                          {pickerSelectedDate
                            ? `Selected: ${formatDateDMY(pickerSelectedDate)}`
                            : "Select a future date above"}
                        </p>
                        {/* Holiday name input */}
                        <input
                          type="text"
                          value={holidayName}
                          onChange={(e) => { setHolidayName(e.target.value); setHolidayError(""); }}
                          placeholder="Holiday name (e.g. Diwali)"
                          className="w-full rounded border border-[#d1d5db] px-2 py-1 text-xs text-[#1f2937] outline-none focus:ring-1 focus:ring-[#a6c63a]"
                        />
                        {holidayError && (
                          <p className="mt-1 text-[10px] text-red-500">{holidayError}</p>
                        )}
                        <button
                          type="button"
                          onClick={handleAddHoliday}
                          className="mt-2 w-full rounded-md bg-[#a6c63a] py-1.5 text-[11px] font-semibold text-white transition hover:bg-[#8fab28]"
                        >
                          Save Holiday
                        </button>
                      </div>
                    </div>
                  )}
                </div>

                {/* Saved holiday chips */}
                {holidays.length > 0 && (
                  <div className="flex flex-wrap gap-1.5 ml-1">
                    {holidays.map((h) => (
                      <span key={h.date}
                        className="inline-flex items-center gap-1 rounded-full border border-[#c9dfa0] bg-[#f0f7db] px-2 py-0.5 text-[10px] font-semibold text-[#4a6b0a]">
                        {formatDateDMY(h.date)} · {h.name}
                        <button type="button" onClick={() => handleRemoveHoliday(h.date)}
                          className="ml-0.5 text-[#4a6b0a] hover:text-red-500" aria-label={`Remove ${h.name}`}>
                          <X className="h-2.5 w-2.5" />
                        </button>
                      </span>
                    ))}
                  </div>
                )}
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
                  {teamMembers.map((member) => (
                    <div
                      key={member.id}
                      className="flex items-center gap-3 px-4"
                      style={{ height: CALENDAR_ROW_PX }}
                    >
                      <div
                        className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-[10px] font-bold text-white"
                        style={{ backgroundColor: member.avatarColor }}
                      >
                        {member.initials}
                      </div>
                      <div className="min-w-0">
                        <p className="truncate text-sm font-semibold text-[#3d3d5c]">{member.name}</p>
                        <p className="truncate text-[11px] text-[#8b93a3]">{member.designation}</p>
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
                        const holiday = Boolean(holidayMap[dateKey]);
                        const isToday = dateKey === todayKey;
                        return (
                          <div
                            key={day}
                            className={`relative flex h-full items-center justify-center text-[11px] font-bold ${
                              isToday
                                ? "bg-primary/15 text-primary"
                                : holiday
                                  ? "bg-[#f4f9e8] text-[#566073]"
                                  : weekend
                                    ? "bg-[#f4f5f8] text-[#566073]"
                                    : "text-[#566073]"
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

                  {teamMembers.map((member) => (
                    <div
                      key={member.id}
                      className="grid w-full overflow-visible border-b border-[#edf0f4] last:border-b-0"
                      style={{ height: CALENDAR_ROW_PX, gridTemplateColumns: dayGridTemplate }}
                    >
                        {days.map((day) => {
                          const date = new Date(year, monthIndex, day);
                          const dateKey = makeDateKeyFromDate(date);
                          const isOpen = openCell?.memberId === member.id && openCell.dateKey === dateKey;
                          const isHoliday = !!holidayMap[dateKey];
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
                              holidayName={holidayMap[dateKey]}
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
                  ))}
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
      </div>
    </AppShell>
  );
}
