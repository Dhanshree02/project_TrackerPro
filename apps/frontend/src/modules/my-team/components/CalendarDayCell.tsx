// ─── My Team — Calendar Day Cell ─────────────────────────────────────────────

import { formatDateDMY } from "@/lib/utils";
import {
  attendanceMeta,
  dropdownOptions,
  shiftMeta,
  shiftOptions,
  weekdayFormatter,
  CALENDAR_ROW_PX,
  DEFAULT_SHIFT,
  shiftChipClass,
} from "../constants";
import { getEventByDate, isWeekendDate } from "../utils";
import type { AttendanceType, SelectableAttendanceType, ShiftType, TeamSchedule } from "../types";
import {
  Popover,
  PopoverAnchor,
  PopoverContent,
} from "@/components/ui/popover";
import * as PopoverPrimitive from "@radix-ui/react-popover";

interface CalendarDayCellProps {
  memberId: string;
  memberName: string;
  date: Date;
  schedule: TeamSchedule;
  isOpen: boolean;
  isFocused: boolean;
  isPast: boolean;
  /** This date has been declared a company holiday — not user-editable */
  isHoliday: boolean;
  /** Name of the holiday to show on hover */
  holidayName?: string;
  isToday?: boolean;
  isLastRow?: boolean;
  weekRangeLabel: string;
  onToggle: (shiftKey: boolean) => void;
  onClose: () => void;
  onFocusCell: () => void;
  onSelectAttendance: (type: SelectableAttendanceType) => void;
  onSelectShift: (shift: ShiftType | "clear") => void;
  onApplyWeek: () => void;
}

function buildTooltip(args: {
  memberName: string;
  date: Date;
  isHoliday: boolean;
  holidayName?: string;
  isPast: boolean;
  attendanceLabel?: string;
  shift?: ShiftType;
}): string {
  const dmy = formatDateDMY(args.date);
  if (args.isHoliday && args.holidayName) return `Holiday: ${args.holidayName} · ${dmy}`;

  const shiftLabel = `${args.shift ?? DEFAULT_SHIFT} (${shiftMeta[args.shift ?? DEFAULT_SHIFT].hours})`;
  const attendance = args.attendanceLabel ?? (args.isPast ? "Unmarked" : "Available to schedule");

  if (args.isPast && !args.attendanceLabel && !args.shift) {
    return `Past date (Read only) · ${dmy}`;
  }

  return `${args.memberName} · ${dmy} · ${shiftLabel} · ${attendance}`;
}

export function CalendarDayCell({
  memberId,
  memberName,
  date,
  schedule,
  isOpen,
  isFocused,
  isPast,
  isHoliday,
  holidayName,
  isToday = false,
  isLastRow = false,
  weekRangeLabel,
  onToggle,
  onClose,
  onFocusCell,
  onSelectAttendance,
  onSelectShift,
  onApplyWeek,
}: CalendarDayCellProps) {
  const dateKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;

  const event = getEventByDate(schedule, memberId, date);
  const attendanceType = event?.type;
  const displayShift = event?.shift ?? DEFAULT_SHIFT;
  const isLocked = isPast || isHoliday;
  const isWeekend = isWeekendDate(date);

  const attendanceLabel = attendanceType
    ? event?.title ?? attendanceMeta[attendanceType].label
    : undefined;

  const tooltipTitle = buildTooltip({
    memberName,
    date,
    isHoliday,
    holidayName,
    isPast,
    attendanceLabel,
    shift: displayShift,
  });

  // Prefer opening to the side that has the most room (left if late in month, right otherwise)
  const preferredSide = date.getDate() > 18 ? "left" : "right";

  return (
    <Popover
      open={isOpen && !isLocked}
      onOpenChange={(open) => {
        if (!open) onClose();
      }}
    >
      <PopoverAnchor asChild>
        <div
          style={{ width: "100%", height: CALENDAR_ROW_PX }}
          className={`relative flex flex-col items-center justify-center overflow-visible border-r border-[#edf0f4] dark:border-slate-800 ${
            !isLastRow ? "border-b border-[#edf0f4] dark:border-slate-800" : ""
          } ${
            isToday
              ? "bg-primary/20 dark:bg-primary/25"
              : isPast
                ? "bg-[#ebedf3] dark:bg-slate-800/70"
                : isHoliday
                  ? "bg-[#f4f9e8] dark:bg-[#202713]"
                  : isWeekend
                    ? "bg-[#f3f4f7] dark:bg-slate-800/40"
                    : "bg-white dark:bg-slate-900"
          }`}
        >
          <div className="relative flex h-7 w-full items-center justify-center">
            <button
              type="button"
              data-cell={`${memberId}-${dateKey}`}
              aria-disabled={isLocked}
              aria-label={`${memberName} ${formatDateDMY(date)}`}
              onFocus={onFocusCell}
              onClick={(mouseEvent) => {
                onFocusCell();
                if (isLocked) return;
                onToggle(mouseEvent.shiftKey);
              }}
              title={tooltipTitle}
              className={`relative z-10 p-0 m-0 flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-xs font-semibold leading-none tabular-nums text-center focus:outline-none ${
                isFocused
                  ? "ring-2 ring-[#5a49b8]/50 ring-offset-1"
                  : "focus:ring-2 focus:ring-[#5a49b8]/40"
              } ${
                isLocked
                  ? "cursor-not-allowed text-[#94a3b8] dark:text-slate-500 opacity-70"
                  : attendanceType
                    ? "text-white shadow-[0_0_0_1px_rgba(255,255,255,0.25)]"
                    : isToday
                      ? "text-primary font-bold cursor-pointer"
                      : "text-[#1e293b] dark:text-slate-100 font-bold cursor-pointer"
              }`}
              style={
                attendanceType
                  ? {
                      backgroundColor: attendanceMeta[attendanceType]?.solid,
                      color: attendanceMeta[attendanceType]?.textColor,
                    }
                  : undefined
              }
            >
              <span className="flex items-center justify-center leading-none text-center -mt-[0.5px]">
                {date.getDate()}
              </span>
            </button>
          </div>

          <span
            className={`mt-1 ${shiftChipClass} ${
              isPast ? "opacity-75 grayscale-[25%]" : ""
            }`}
          >
            {shiftMeta[displayShift].chip}
          </span>
        </div>
      </PopoverAnchor>

      {/* Screen-aware Portal Popover: opens side-by-side or best fit, no scrollbars */}
      <PopoverContent
        side={preferredSide}
        align="center"
        sideOffset={10}
        collisionPadding={16}
        className="z-[200] w-[230px] rounded-2xl border border-white/60 bg-white/80 p-2.5 shadow-[0_20px_50px_rgba(15,23,42,0.22),0_0_0_1px_rgba(0,0,0,0.06)] backdrop-blur-[32px] backdrop-saturate-180 dark:bg-slate-900/85 dark:border-white/10 outline-none"
      >
        <PopoverPrimitive.Arrow
          className="fill-white/80 stroke-white/60 dark:fill-slate-900/85 dark:stroke-white/10"
          width={12}
          height={6}
        />

        {/* Header with Date & Member */}
        <div className="relative z-10 px-1 pb-1.5 border-b border-black/[0.06] dark:border-white/[0.08] mb-1.5">
          <p className="text-[11.5px] font-bold text-[#1e293b] dark:text-white leading-tight">
            {formatDateDMY(date)}
          </p>
          <p className="text-[9.5px] font-medium text-[#64748b] leading-tight mt-0.5 truncate">
            {weekdayFormatter.format(date)} · {memberName}
          </p>
        </div>

        {/* Attendance options */}
        <p className="relative z-10 px-1 pb-0.5 text-[9px] font-bold uppercase tracking-wider text-[#9aa2b2]">
          Attendance
        </p>
        <div className="relative z-10 space-y-0.5">
          {dropdownOptions.map((option) => {
            const isClear = option.type === "clear";
            const isActive = !isClear && attendanceType === option.type;
            return (
              <button
                key={option.type}
                type="button"
                onClick={(clickEvent) => {
                  clickEvent.stopPropagation();
                  onSelectAttendance(option.type);
                }}
                className={`flex w-full items-center gap-2 rounded-xl px-2.5 py-1 text-left text-[11px] font-medium transition-all ${
                  isClear
                    ? "mt-1 border-t border-black/[0.05] dark:border-white/[0.08] pt-1.5 text-[#8b93a3] hover:bg-black/[0.04]"
                    : isActive
                      ? "bg-white/85 text-[#5a49b8] shadow-xs ring-1 ring-[#5a49b8]/30 font-semibold dark:bg-slate-800"
                      : "text-[#475569] hover:bg-white/60 dark:text-slate-300 dark:hover:bg-white/10"
                }`}
              >
                {isClear ? (
                  <span className="h-2.5 w-2.5 shrink-0 rounded-full border border-[#d1d5db]" />
                ) : (
                  <span
                    className="h-2.5 w-2.5 shrink-0 rounded-full shadow-2xs"
                    style={{
                      backgroundColor:
                        attendanceMeta[option.type as AttendanceType]?.solid,
                    }}
                  />
                )}
                {option.label}
              </button>
            );
          })}
        </div>

        {/* Shift options */}
        <p className="relative z-10 mt-2 px-1 pb-0.5 text-[9px] font-bold uppercase tracking-wider text-[#9aa2b2]">
          Shift
        </p>
        <div className="relative z-10 mb-1 grid grid-cols-4 gap-1 px-0.5">
          {shiftOptions.map((shift) => {
            const meta = shiftMeta[shift];
            const isActive = displayShift === shift;
            return (
              <button
                key={shift}
                type="button"
                title={`${meta.label} (${meta.hours})`}
                onClick={(clickEvent) => {
                  clickEvent.stopPropagation();
                  onSelectShift(shift);
                }}
                className={`flex flex-col items-center rounded-xl px-1 py-1.5 text-[10px] font-semibold transition-all ${
                  isActive
                    ? "bg-white/90 text-[#1e293b] shadow-xs ring-2 ring-primary/40 dark:bg-slate-800 dark:text-white"
                    : "bg-black/[0.03] text-[#64748b] hover:bg-white/60 dark:bg-white/[0.05] dark:hover:bg-white/10"
                }`}
              >
                <span className="text-[11px] font-bold">{meta.chip}</span>
                <span className="text-[8px] font-medium opacity-80">
                  {meta.label.slice(0, 3)}
                </span>
              </button>
            );
          })}
        </div>

        <div className="relative z-10 mt-1.5 border-t border-black/[0.06] dark:border-white/[0.08] pt-1.5">
          <button
            type="button"
            onClick={(clickEvent) => {
              clickEvent.stopPropagation();
              onApplyWeek();
            }}
            className="w-full rounded-xl px-2.5 py-1.5 text-left text-[10.5px] font-semibold text-[#5a49b8] transition-all hover:bg-white/70 dark:hover:bg-white/10 flex items-center justify-between"
          >
            <span>Apply Mon–Fri</span>
            <span className="text-[9.5px] font-normal text-muted-foreground">
              ({weekRangeLabel})
            </span>
          </button>
        </div>
      </PopoverContent>
    </Popover>
  );
}
