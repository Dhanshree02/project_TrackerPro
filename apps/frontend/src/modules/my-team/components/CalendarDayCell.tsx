// ─── My Team — Calendar Day Cell ─────────────────────────────────────────────

import { useEffect, useRef } from "react";
import { attendanceMeta, dropdownOptions } from "../constants";
import { addDays, getEventByDate } from "../utils";
import type { AttendanceType, SelectableAttendanceType, TeamSchedule } from "../types";

interface CalendarDayCellProps {
  memberId: string;
  date: Date;
  schedule: TeamSchedule;
  isOpen: boolean;
  /** Past dates are read-only */
  isPast: boolean;
  /** This date has been declared a company holiday — not user-editable */
  isHoliday: boolean;
  /** Name of the holiday to show on hover */
  holidayName?: string;
  onToggle: () => void;
  onClose: () => void;
  /** null = clear/remove the attendance mark */
  onSelect: (type: SelectableAttendanceType) => void;
}

export function CalendarDayCell({
  memberId,
  date,
  schedule,
  isOpen,
  isPast,
  isHoliday,
  holidayName,
  onToggle,
  onClose,
  onSelect,
}: CalendarDayCellProps) {
  const cellRef = useRef<HTMLDivElement>(null);

  const event = getEventByDate(schedule, memberId, date);
  const previousEvent = getEventByDate(schedule, memberId, addDays(date, -1));
  const nextEvent     = getEventByDate(schedule, memberId, addDays(date, 1));

  const connectsPrevious = Boolean(
    event?.sequenceId && previousEvent?.sequenceId === event.sequenceId,
  );
  const connectsNext = Boolean(
    event?.sequenceId && nextEvent?.sequenceId === event.sequenceId,
  );
  const isConnected = connectsPrevious || connectsNext;

  const isLocked = isPast || isHoliday;

  const tooltipTitle = (() => {
    if (isHoliday && holidayName) return `Holiday: ${holidayName}`;
    if (event) return event.title ?? attendanceMeta[event.type as AttendanceType]?.label ?? "";
    if (isPast) return "Past date — read only";
    return "Mark attendance";
  })();

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
      className={`relative flex h-12 w-7 items-center justify-center overflow-visible text-[11px] font-semibold ${
        isOpen ? "z-[100]" : "z-0"
      }`}
    >
      {/* Pill connector for multi-day sequences */}
      {event && isConnected && (
        <span
          aria-hidden="true"
          className="absolute left-0 top-1/2 z-0 h-5 w-full -translate-y-1/2"
          style={{
            backgroundColor: attendanceMeta[event.type as AttendanceType]?.soft ?? "#eee",
            borderTopLeftRadius:     connectsPrevious ? 0 : 999,
            borderBottomLeftRadius:  connectsPrevious ? 0 : 999,
            borderTopRightRadius:    connectsNext ? 0 : 999,
            borderBottomRightRadius: connectsNext ? 0 : 999,
          }}
        />
      )}

      {/* Day number button */}
      <button
        type="button"
        onClick={isLocked ? undefined : onToggle}
        disabled={isLocked}
        title={tooltipTitle}
        className={`relative z-10 flex h-[22px] w-[22px] shrink-0 items-center justify-center rounded-full text-[11px] font-semibold transition focus:outline-none focus:ring-2 focus:ring-[#5a49b8]/40 ${
          isLocked
            ? "cursor-default opacity-60"
            : event
              ? "text-white shadow-[0_0_0_1px_rgba(255,255,255,0.25)] hover:scale-110"
              : "text-[#9aa2b2] hover:bg-[#f0eef9] hover:text-[#5a49b8] hover:scale-110"
        }`}
        style={
          event
            ? {
                backgroundColor: attendanceMeta[event.type as AttendanceType]?.solid,
                color: attendanceMeta[event.type as AttendanceType]?.textColor,
              }
            : undefined
        }
      >
        {date.getDate()}
      </button>

      {/* Dropdown — only for future, non-holiday dates */}
      {isOpen && !isLocked && (
        <div
          role="menu"
          className="absolute left-1/2 top-[38px] z-[120] w-[152px] -translate-x-1/2 rounded-lg border border-[#e1e4eb] bg-white p-1.5 shadow-[0_8px_24px_rgba(34,42,62,0.18)]"
        >
          {/* Caret */}
          <span className="absolute -top-1.5 left-1/2 h-3 w-3 -translate-x-1/2 rotate-45 border-l border-t border-[#e1e4eb] bg-white" />

          {dropdownOptions.map((option) => {
            const isClear = option.type === "clear";
            return (
              <button
                key={option.type}
                type="button"
                role="menuitem"
                onClick={(e) => { e.stopPropagation(); onSelect(option.type); }}
                className={`relative z-10 flex w-full items-center gap-2 rounded-md px-2.5 py-2 text-left text-[11px] font-medium transition hover:bg-[#f4f2fb] ${
                  isClear
                    ? "text-[#9aa2b2] mt-0.5 border-t border-[#f0f2f5]"
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
        </div>
      )}
    </div>
  );
}
