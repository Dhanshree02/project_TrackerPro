// ─── My Team Page ─────────────────────────────────────────────────────────────
// Composes all My Team components and owns all page-level state.
// Data is fetched exclusively through the service layer — the UI never
// imports dummy data directly so switching to APIs requires no UI changes.

import { useMemo, useState } from "react";
import {
  BriefcaseBusiness,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  Users,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { teamDataService } from "./services/teamDataService";
import {
  attendanceMeta,
  indicatorColors,
  monthFormatter,
  weekdayFormatter,
} from "./constants";
import { getDayIndicator, makeDateKeyFromDate } from "./utils";
import type { OpenCell, SelectableAttendanceType, TeamSchedule } from "./types";
import { CalendarDayCell } from "./components/CalendarDayCell";
import { Legend, SmallDot } from "./components/Legend";
import { SummaryCard } from "./components/SummaryCard";

export function MyTeamPage() {
  // ── Data from service layer ──────────────────────────────────────────────────
  // useMemo so the array reference is stable and the schedule initialiser only
  // runs once — exactly the same behaviour as the original createTeamSchedule().
  const teamMembers = useMemo(() => teamDataService.getTeamMembers(), []);

  // ── UI state ─────────────────────────────────────────────────────────────────
  const [selectedMonth, setSelectedMonth] = useState(
    () => new Date(2026, 5, 1), // June 2026 — same default as original
  );

  const [teamSchedule, setTeamSchedule] = useState<TeamSchedule>(
    () => teamDataService.createInitialSchedule(teamMembers),
  );

  const [openCell, setOpenCell] = useState<OpenCell>(null);

  // ── Derived calendar values ──────────────────────────────────────────────────
  const year = selectedMonth.getFullYear();
  const monthIndex = selectedMonth.getMonth();
  const daysInMonth = new Date(year, monthIndex + 1, 0).getDate();

  const days = useMemo(
    () => Array.from({ length: daysInMonth }, (_, i) => i + 1),
    [daysInMonth],
  );

  // ── Summary counts ───────────────────────────────────────────────────────────
  const totalMembers = teamMembers.length;
  const activeCount = teamMembers.filter((m) => m.status === "Active").length;
  const wfhCount = teamMembers.filter((m) => m.status === "WFH").length;
  const onLeaveCount = teamMembers.filter((m) => m.status === "On Leave").length;

  // ── Handlers ─────────────────────────────────────────────────────────────────
  const changeMonth = (amount: number) => {
    setOpenCell(null);
    setSelectedMonth(
      (current) =>
        new Date(current.getFullYear(), current.getMonth() + amount, 1),
    );
  };

  const handleCellToggle = (memberId: string, date: Date) => {
    const dateKey = makeDateKeyFromDate(date);
    setOpenCell((current) => {
      if (current?.memberId === memberId && current.dateKey === dateKey) {
        return null;
      }
      return { memberId, dateKey };
    });
  };

  const handleAttendanceSelect = (
    memberId: string,
    date: Date,
    type: SelectableAttendanceType,
  ) => {
    const dateKey = makeDateKeyFromDate(date);
    setTeamSchedule((current) => ({
      ...current,
      [memberId]: {
        ...current[memberId],
        [dateKey]: {
          type,
          title: attendanceMeta[type].label,
        },
      },
    }));
    setOpenCell(null);
  };

  // ── Render ────────────────────────────────────────────────────────────────────
  return (
    <AppShell
      title="My Team"
      subtitle="Reporting team, availability, and leave visibility"
    >
      <div className="space-y-4">
        {/* Summary cards */}
        <section className="grid gap-3 md:grid-cols-3">
          <SummaryCard
            label="Active today"
            current={activeCount}
            total={totalMembers}
            icon={Users}
          />

          <SummaryCard
            label="WFH today"
            current={wfhCount}
            total={totalMembers}
            icon={BriefcaseBusiness}
          />

          <SummaryCard
            label="On leave today"
            current={onLeaveCount}
            total={totalMembers}
            icon={CalendarDays}
          />
        </section>

        {/* Team calendar */}
        <section className="rounded-xl border border-border bg-card p-4 shadow-sm">
          <h2 className="text-sm font-semibold">Team calendar</h2>

          <p className="mt-1 text-xs text-muted-foreground">
            Click any date to mark leave, holiday, or work from home
          </p>

          <div className="mt-4 overflow-x-auto rounded-sm border border-[#e5e8ef] bg-white px-4 py-5">
            <div
              className="pb-32"
              style={{ minWidth: `${300 + daysInMonth * 28}px` }}
            >
              {/* Month navigation */}
              <div className="mb-4 flex items-center gap-2">
                <button
                  type="button"
                  aria-label="Previous month"
                  onClick={() => changeMonth(-1)}
                  className="flex h-5 w-5 items-center justify-center rounded-[3px] bg-[#5a49b8] text-white transition hover:bg-[#4e3fa4]"
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
                  className="flex h-5 w-5 items-center justify-center rounded-[3px] bg-[#5a49b8] text-white transition hover:bg-[#4e3fa4]"
                >
                  <ChevronRight className="h-3.5 w-3.5" />
                </button>
              </div>

              {/* Day headers with leave indicators */}
              <div className="flex border-b border-[#edf0f4] pb-2">
                <div className="w-[300px] shrink-0" />

                <div
                  className="grid"
                  style={{
                    gridTemplateColumns: `repeat(${daysInMonth}, 28px)`,
                  }}
                >
                  {days.map((day) => {
                    const date = new Date(year, monthIndex, day);
                    const weekday = weekdayFormatter.format(date).slice(0, 2);
                    const indicatorColor = getDayIndicator(
                      teamSchedule,
                      teamMembers,
                      year,
                      monthIndex,
                      day,
                    );

                    return (
                      <div
                        key={day}
                        className="relative flex h-[24px] items-start justify-center text-[10px] font-bold text-[#566073]"
                      >
                        {weekday}

                        {indicatorColor && (
                          <span
                            className="absolute bottom-[1px] left-1/2 h-[3px] w-[3px] -translate-x-1/2 rounded-full"
                            style={{ backgroundColor: indicatorColor }}
                          />
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Member rows */}
              <div className="divide-y divide-[#edf0f4]">
                {teamMembers.map((member) => (
                  <div
                    key={member.id}
                    className="relative flex min-h-[48px] items-center overflow-visible"
                  >
                    {/* Member identity */}
                    <div className="flex w-[300px] shrink-0 items-center gap-2.5 pr-4">
                      <div
                        className="flex h-[24px] w-[24px] shrink-0 items-center justify-center rounded-full text-[9px] font-bold text-white"
                        style={{ backgroundColor: member.avatarColor }}
                      >
                        {member.initials}
                      </div>

                      <div className="min-w-0">
                        <p className="truncate text-xs font-semibold text-[#626b7c]">
                          {member.name}
                        </p>
                        <p className="truncate text-[9px] text-[#9aa1ae]">
                          {member.designation}
                        </p>
                      </div>
                    </div>

                    {/* Calendar cells for this member */}
                    <div
                      className="grid overflow-visible"
                      style={{
                        gridTemplateColumns: `repeat(${daysInMonth}, 28px)`,
                      }}
                    >
                      {days.map((day) => {
                        const date = new Date(year, monthIndex, day);
                        const dateKey = makeDateKeyFromDate(date);
                        const isOpen =
                          openCell?.memberId === member.id &&
                          openCell.dateKey === dateKey;

                        return (
                          <CalendarDayCell
                            key={`${member.id}-${dateKey}`}
                            memberId={member.id}
                            date={date}
                            schedule={teamSchedule}
                            isOpen={isOpen}
                            onToggle={() =>
                              handleCellToggle(member.id, date)
                            }
                            onClose={() => setOpenCell(null)}
                            onSelect={(type) =>
                              handleAttendanceSelect(member.id, date, type)
                            }
                          />
                        );
                      })}
                    </div>
                  </div>
                ))}
              </div>

              {/* Legend */}
              <div className="mt-6 flex flex-wrap items-center gap-x-6 gap-y-3 text-[10px] font-medium text-[#6f7685]">
                <Legend
                  color={attendanceMeta.wfh.solid}
                  text="Work from home"
                />
                <Legend
                  color={attendanceMeta.onDuty.solid}
                  text="On duty"
                />
                <Legend
                  color={attendanceMeta.paidLeave.solid}
                  text="Paid Leave"
                />
                <Legend
                  color={attendanceMeta.unpaidLeave.solid}
                  text="Unpaid Leave"
                />
                <Legend
                  color={attendanceMeta.noAttendance.solid}
                  text="Leave due to No Attendance"
                />
                <Legend
                  color={attendanceMeta.weeklyOff.solid}
                  text="Weekly off"
                />
                <Legend
                  color={attendanceMeta.holiday.solid}
                  text="Holiday"
                />
                <SmallDot
                  color={indicatorColors.leave}
                  text="Someone on Leave"
                />
                <SmallDot
                  color={indicatorColors.multipleLeave}
                  text="Multiple Leave on a day"
                />
              </div>
            </div>
          </div>
        </section>
      </div>
    </AppShell>
  );
}
