// ─── My Team — Calendar Day Cell ─────────────────────────────────────────────
// Renders a single day cell in the team calendar grid.
// Handles the pill-connector visual for multi-day sequences,
// the coloured circle button, and the attendance dropdown menu.

import { useEffect, useRef } from "react";
import { attendanceMeta, dropdownOptions } from "../constants";
import { addDays, getEventByDate } from "../utils";
import type { SelectableAttendanceType, TeamSchedule } from "../types";

interface CalendarDayCellProps {
  memberId: string;
  date: Date;
  schedule: TeamSchedule;
  isOpen: boolean;
  onToggle: () => void;
  onClose: () => void;
  onSelect: (type: SelectableAttendanceType) => void;
}

export function CalendarDayCell({
  memberId,
  date,
  schedule,
  isOpen,
  onToggle,
  onClose,
  onSelect,
}: CalendarDayCellProps) {
  const cellRef = useRef<HTMLDivElement>(null);

  const event = getEventByDate(schedule, memberId, date);
  const previousEvent = getEventByDate(schedule, memberId, addDays(date, -1));
  const nextEvent = getEventByDate(schedule, memberId, addDays(date, 1));

  const connectsPrevious = Boolean(
    event?.sequenceId && previousEvent?.sequenceId === event.sequenceId,
  );
  const connectsNext = Boolean(
    event?.sequenceId && nextEvent?.sequenceId === event.sequenceId,
  );
  const isConnected = connectsPrevious || connectsNext;

  // Close the dropdown when a click lands outside this cell.
  useEffect(() => {
    if (!isOpen) return;

    const handleOutsideClick = (mouseEvent: MouseEvent) => {
      if (
        cellRef.current &&
        !cellRef.current.contains(mouseEvent.target as Node)
      ) {
        onClose();
      }
    };

    document.addEventListener("mousedown", handleOutsideClick);
    return () => document.removeEventListener("mousedown", handleOutsideClick);
  }, [isOpen, onClose]);

  return (
    <div
      ref={cellRef}
      className={`relative flex h-12 w-7 items-center justify-center overflow-visible text-[11px] font-semibold ${
        isOpen ? "z-[100]" : "z-0"
      }`}
    >
      {/* Pill connector background for multi-day sequences */}
      {event && isConnected && (
        <span
          aria-hidden="true"
          className="absolute left-0 top-1/2 z-0 h-5 w-full -translate-y-1/2"
          style={{
            backgroundColor: attendanceMeta[event.type].soft,
            borderTopLeftRadius: connectsPrevious ? 0 : 999,
            borderBottomLeftRadius: connectsPrevious ? 0 : 999,
            borderTopRightRadius: connectsNext ? 0 : 999,
            borderBottomRightRadius: connectsNext ? 0 : 999,
          }}
        />
      )}

      {/* Day number button */}
      <button
        type="button"
        onClick={onToggle}
        title={
          event
            ? (event.title ?? attendanceMeta[event.type].label)
            : "Add attendance event"
        }
        className={`relative z-10 flex h-[22px] w-[22px] shrink-0 items-center justify-center rounded-full text-[11px] font-semibold transition hover:scale-110 focus:outline-none focus:ring-2 focus:ring-[#5a49b8]/40 ${
          event
            ? "text-white shadow-[0_0_0_1px_rgba(255,255,255,0.25)]"
            : "text-[#9aa2b2] hover:bg-[#f0eef9] hover:text-[#5a49b8]"
        }`}
        style={
          event
            ? {
                backgroundColor: attendanceMeta[event.type].solid,
                color: attendanceMeta[event.type].textColor,
              }
            : undefined
        }
      >
        {date.getDate()}
      </button>

      {/* Attendance dropdown */}
      {isOpen && (
        <div
          role="menu"
          className="absolute left-1/2 top-[38px] z-[120] w-[152px] -translate-x-1/2 rounded-lg border border-[#e1e4eb] bg-white p-1.5 shadow-[0_8px_24px_rgba(34,42,62,0.18)]"
        >
          {/* Caret */}
          <span className="absolute -top-1.5 left-1/2 h-3 w-3 -translate-x-1/2 rotate-45 border-l border-t border-[#e1e4eb] bg-white" />

          {dropdownOptions.map((option) => (
            <button
              key={option.type}
              type="button"
              role="menuitem"
              onClick={(clickEvent) => {
                clickEvent.stopPropagation();
                onSelect(option.type);
              }}
              className="relative z-10 flex w-full items-center gap-2 rounded-md px-2.5 py-2 text-left text-[11px] font-medium text-[#596274] transition hover:bg-[#f4f2fb]"
            >
              <span
                className="h-2.5 w-2.5 shrink-0 rounded-full"
                style={{ backgroundColor: attendanceMeta[option.type].solid }}
              />
              {option.label}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
