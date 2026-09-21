// ─── My Team — Calendar Day Cell ─────────────────────────────────────────────

import { useEffect, useRef } from "react";
import { formatDateDMY } from "@/lib/utils";
import { attendanceMeta, dropdownOptions, shiftMeta, shiftOptions, weekdayFormatter, CALENDAR_ROW_PX, DEFAULT_SHIFT, shiftChipClass } from "../constants";
import { getEventByDate, isWeekendDate } from "../utils";
import type { AttendanceType, SelectableAttendanceType, ShiftType, TeamSchedule } from "../types";

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
  const attendance = args.attendanceLabel ?? (args.isPast ? "Unmarked" : "Unmarked");

  if (args.isPast && !args.attendanceLabel && !args.shift) {
    return `Past date — read only · ${dmy}`;
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
  weekRangeLabel,
  onToggle,
  onClose,
  onFocusCell,
  onSelectAttendance,
  onSelectShift,
  onApplyWeek,
}: CalendarDayCellProps) {
  const cellRef = useRef<HTMLDivElement>(null);
  const dateKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;

  const event = getEventByDate(schedule, memberId, date);
  const attendanceType = event?.type;
  const displayShift = event?.shift ?? DEFAULT_SHIFT;
  const isLocked = isPast || isHoliday;
  const isWeekend = isWeekendDate(date);
  const alignEnd = date.getDate() > 24;

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

  useEffect(() => {
    if (!isOpen) return;
    const handler = (mouseEvent: MouseEvent) => {
      if (cellRef.current && !cellRef.current.contains(mouseEvent.target as Node)) {
        onClose();
      }
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [isOpen, onClose]);

  return (
    <div
      ref={cellRef}
      style={{ width: "100%", height: CALENDAR_ROW_PX }}
      className={`relative flex flex-col items-center justify-center overflow-visible ${
        isOpen ? "z-[100]" : "z-0"
      } ${
        isToday
          ? "bg-primary/15"
          : isHoliday
            ? "bg-[#f4f9e8]"
            : isWeekend
              ? "bg-[#f4f5f8]"
              : ""
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
          className={`relative z-10 flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-xs font-semibold transition focus:outline-none ${
            isFocused
              ? "ring-2 ring-[#5a49b8]/50 ring-offset-1"
              : "focus:ring-2 focus:ring-[#5a49b8]/40"
          } ${
            isLocked
              ? "cursor-default opacity-60"
              : attendanceType
                ? "text-white shadow-[0_0_0_1px_rgba(255,255,255,0.25)] hover:scale-110"
                : isToday
                  ? "bg-primary/15 text-primary hover:bg-primary/25 hover:scale-110"
                  : "text-[#9aa2b2] hover:bg-[#f0eef9] hover:text-[#5a49b8] hover:scale-110"
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
          {date.getDate()}
        </button>
      </div>

      <span className={`mt-1 ${shiftChipClass}`}>
        {shiftMeta[displayShift].chip}
      </span>

      {isOpen && !isLocked && (
        <div
          role="menu"
          className={`absolute top-[62px] z-[120] w-[220px] rounded-xl border border-[#e1e4eb]/80 bg-white/95 p-2 shadow-lg backdrop-blur-md ${
            alignEnd ? "right-0" : "left-1/2 -translate-x-1/2"
          }`}
        >
          <span
            className={`absolute -top-1.5 h-3 w-3 rotate-45 border-l border-t border-[#e1e4eb] bg-white/95 ${
              alignEnd ? "right-3" : "left-1/2 -translate-x-1/2"
            }`}
          />

          <p className="relative z-10 px-1.5 pb-1 text-[10px] font-semibold text-[#3d3d5c]">
            {weekdayFormatter.format(date)} · {formatDateDMY(date)}
          </p>

          <p className="relative z-10 px-1.5 pb-0.5 text-[9px] font-bold uppercase tracking-wide text-[#9aa2b2]">
            Attendance
          </p>
          {dropdownOptions.map((option) => {
            const isClear = option.type === "clear";
            const isActive = !isClear && attendanceType === option.type;
            return (
              <button
                key={option.type}
                type="button"
                role="menuitem"
                onClick={(clickEvent) => {
                  clickEvent.stopPropagation();
                  onSelectAttendance(option.type);
                }}
                className={`relative z-10 flex w-full items-center gap-2 rounded-md px-2 py-1 text-left text-[11px] font-medium transition hover:bg-[#f4f2fb] ${
                  isClear
                    ? "mt-0.5 border-t border-[#f0f2f5] text-[#9aa2b2]"
                    : isActive
                      ? "bg-[#f4f2fb] text-[#5a49b8]"
                      : "text-[#596274]"
                }`}
              >
                {isClear ? (
                  <span className="h-2.5 w-2.5 shrink-0 rounded-full border border-[#d1d5db]" />
                ) : (
                  <span
                    className="h-2.5 w-2.5 shrink-0 rounded-full"
                    style={{ backgroundColor: attendanceMeta[option.type as AttendanceType]?.solid }}
                  />
                )}
                {option.label}
              </button>
            );
          })}

          <p className="relative z-10 mt-1 px-1.5 pb-0.5 text-[9px] font-bold uppercase tracking-wide text-[#9aa2b2]">
            Shift
          </p>
          <div className="relative z-10 mb-1 grid grid-cols-4 gap-1 px-1">
            {shiftOptions.map((shift) => {
              const meta = shiftMeta[shift];
              const isActive = displayShift === shift;
              return (
                <button
                  key={shift}
                  type="button"
                  role="menuitem"
                  title={`${meta.label} (${meta.hours})`}
                  onClick={(clickEvent) => {
                    clickEvent.stopPropagation();
                    onSelectShift(shift);
                  }}
                  className={`flex flex-col items-center rounded-lg px-1 py-1.5 text-[10px] font-semibold transition ${
                    isActive
                      ? "bg-[#eceef2] text-[#4b5563]"
                      : "bg-[#f7f8fa] text-[#6b7280] hover:bg-[#eceef2]"
                  }`}
                >
                  <span className="text-[11px] font-bold">{meta.chip}</span>
                  <span className="text-[8px] font-medium opacity-80">{meta.label.slice(0, 3)}</span>
                </button>
              );
            })}
          </div>
          <button
            type="button"
            role="menuitem"
            onClick={(clickEvent) => {
              clickEvent.stopPropagation();
              onSelectShift("clear");
            }}
            className="relative z-10 mt-0.5 flex w-full items-center gap-2 rounded-md border-t border-[#f0f2f5] px-2 py-1 text-left text-[11px] font-medium text-[#9aa2b2] transition hover:bg-[#f4f2fb]"
          >
            <span className="h-2.5 w-2.5 shrink-0 rounded-full border border-[#d1d5db]" />
            Clear shift (General)
          </button>

          <div className="relative z-10 mt-1.5 border-t border-[#f0f2f5] pt-1.5">
            <button
              type="button"
              onClick={(clickEvent) => {
                clickEvent.stopPropagation();
                onApplyWeek();
              }}
              className="w-full rounded-md px-2 py-1.5 text-left text-[10px] font-medium text-[#5a49b8] transition hover:bg-[#f4f2fb]"
            >
              Apply to Mon–Fri ({weekRangeLabel})
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
