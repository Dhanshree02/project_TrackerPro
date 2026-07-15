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
import { teamDataService } from "./services/teamDataService";
import {
  attendanceMeta,
  monthFormatter,
  weekdayFormatter,
} from "./constants";
import { getDayIndicator, makeDateKeyFromDate, makeDateKey } from "./utils";
import type {
  HolidayEntry,
  OpenCell,
  SelectableAttendanceType,
  ShiftType,
  TeamSchedule,
} from "./types";
import { CalendarDayCell } from "./components/CalendarDayCell";
import { Legend } from "./components/Legend";
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
        }
      }
    }
    return cleaned;
  });

  const [openCell, setOpenCell] = useState<OpenCell>(null);

  // ── Shift state — per member, persists across month navigation ──────────────
  const [memberShifts, setMemberShifts] = useState<Record<string, ShiftType | "">>(() =>
    Object.fromEntries(teamMembers.map((m) => [m.id, ""]))
  );

  const handleShiftChange = (memberId: string, shift: ShiftType | "") => {
    setMemberShifts((prev) => ({ ...prev, [memberId]: shift }));
  };

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
  const changeMonth = (amount: number) => {
    setOpenCell(null);
    setSelectedMonth(
      (c) => new Date(c.getFullYear(), c.getMonth() + amount, 1),
    );
  };

  const handleCellToggle = (memberId: string, date: Date) => {
    if (date < today) return; // past dates are read-only
    // Holiday cells are not user-editable per-member — skip
    const dateKey = makeDateKeyFromDate(date);
    if (holidayMap[dateKey]) return;
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
    if (type === "clear") {
      // Remove the attendance mark entirely
      setTeamSchedule((current) => {
        const memberSchedule = { ...current[memberId] };
        delete memberSchedule[dateKey];
        return { ...current, [memberId]: memberSchedule };
      });
    } else {
      setTeamSchedule((current) => ({
        ...current,
        [memberId]: {
          ...current[memberId],
          [dateKey]: { type, title: attendanceMeta[type].label },
        },
      }));
    }
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
        <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <h2 className="text-sm font-semibold">Team calendar</h2>
          <p className="mt-1 text-xs text-muted-foreground">
            Click any future date to mark leave. Use the holiday manager to add company-wide holidays.
          </p>

          <div className="mt-4 overflow-x-auto rounded-sm border border-[#e5e8ef] bg-white px-4 py-5">
            <div className="pb-32" style={{ minWidth: `${340 + daysInMonth * 28}px` }}>

              {/* ── Month navigation + Add Holiday button ── */}
              <div className="mb-4 flex items-center gap-3 flex-wrap">

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
                            ? `Selected: ${new Date(pickerSelectedDate + "T00:00:00").toLocaleDateString("en-US", { weekday: "short", day: "numeric", month: "short", year: "numeric" })}`
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
                        {new Date(h.date + "T00:00:00").toLocaleDateString("en-US", { day: "numeric", month: "short" })} · {h.name}
                        <button type="button" onClick={() => handleRemoveHoliday(h.date)}
                          className="ml-0.5 text-[#4a6b0a] hover:text-red-500" aria-label={`Remove ${h.name}`}>
                          <X className="h-2.5 w-2.5" />
                        </button>
                      </span>
                    ))}
                  </div>
                )}
              </div>

              {/* Day headers */}
              <div className="flex border-b border-[#edf0f4] pb-2">
                {/* Left panel: name col header + shift col header */}
                <div className="w-[340px] shrink-0 flex items-end">
                  <div className="w-[240px] shrink-0" />
                  <div className="w-[100px] shrink-0 text-[9px] font-bold text-[#9aa2b2] uppercase tracking-wide text-center">Shift</div>
                </div>
                <div className="grid" style={{ gridTemplateColumns: `repeat(${daysInMonth}, 28px)` }}>
                  {days.map((day) => {
                    const date = new Date(year, monthIndex, day);
                    const weekday = weekdayFormatter.format(date).slice(0, 2);
                    const indicatorColor = getDayIndicator(teamSchedule, teamMembers, year, monthIndex, day);
                    return (
                      <div key={day} className="relative flex h-[24px] items-start justify-center text-[10px] font-bold text-[#566073]">
                        {weekday}
                        {indicatorColor && (
                          <span className="absolute bottom-[1px] left-1/2 h-[3px] w-[3px] -translate-x-1/2 rounded-full"
                            style={{ backgroundColor: indicatorColor }} />
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Member rows */}
              <div className="divide-y divide-[#edf0f4]">
                {teamMembers.map((member) => (
                  <div key={member.id} className="relative flex min-h-[48px] items-center overflow-visible">

                    {/* ── Left panel: avatar+name | shift dropdown ── */}
                    <div className="flex w-[340px] shrink-0 items-center">

                      {/* Avatar + name — fixed 240px */}
                      <div className="flex w-[240px] shrink-0 items-center gap-2 pr-3">
                        <div
                          className="flex h-[24px] w-[24px] shrink-0 items-center justify-center rounded-full text-[9px] font-bold text-white"
                          style={{ backgroundColor: member.avatarColor }}
                        >
                          {member.initials}
                        </div>
                        <div className="min-w-0">
                          <p className="truncate text-xs font-semibold text-[#626b7c]">{member.name}</p>
                          <p className="truncate text-[9px] text-[#9aa1ae]">{member.designation}</p>
                        </div>
                      </div>

                      {/* Shift dropdown — 100px, right after the name, before calendar */}
                      <div className="w-[100px] shrink-0 border-l border-[#edf0f4] pl-2 pr-3">
                        <select
                          value={memberShifts[member.id] ?? ""}
                          onChange={(e) => handleShiftChange(member.id, e.target.value as ShiftType | "")}
                          className="h-7 w-full rounded-md border border-[#d1d5db] bg-white px-1.5 text-[10px] font-medium text-[#374151] outline-none focus:ring-1 focus:ring-[#5a49b8] cursor-pointer"
                          title="Select shift"
                        >
                          <option value="">Choose…</option>
                          <option value="Morning">Morning</option>
                          <option value="Afternoon">Afternoon</option>
                          <option value="Night">Night</option>
                          <option value="General">General</option>
                        </select>
                      </div>
                    </div>

                    {/* Calendar cells */}
                    <div className="grid overflow-visible"
                      style={{ gridTemplateColumns: `repeat(${daysInMonth}, 28px)` }}>
                      {days.map((day) => {
                        const date = new Date(year, monthIndex, day);
                        const dateKey = makeDateKeyFromDate(date);
                        const isOpen = openCell?.memberId === member.id && openCell.dateKey === dateKey;
                        const isHoliday = !!holidayMap[dateKey];

                        return (
                          <CalendarDayCell
                            key={`${member.id}-${dateKey}`}
                            memberId={member.id}
                            date={date}
                            schedule={teamSchedule}
                            isOpen={isOpen}
                            isPast={date < today}
                            isHoliday={isHoliday}
                            holidayName={holidayMap[dateKey]}
                            onToggle={() => handleCellToggle(member.id, date)}
                            onClose={() => setOpenCell(null)}
                            onSelect={(type) => handleAttendanceSelect(member.id, date, type)}
                          />
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>

              {/* Legend */}
              <div className="mt-6 flex flex-wrap items-center gap-x-6 gap-y-3 text-[10px] font-medium text-[#6f7685]">
                <Legend color={attendanceMeta.onsite.solid}    text="Onsite" />
                <Legend color={attendanceMeta.wfh.solid}       text="Work From Home" />
                <Legend color={attendanceMeta.leave.solid}     text="Leave" />
                <Legend color={attendanceMeta.weeklyOff.solid} text="Weekly Off" />
                <Legend color={attendanceMeta.holiday.solid}   text="Holiday" />
              </div>

            </div>
          </div>
        </section>
      </div>
    </AppShell>
  );
}
