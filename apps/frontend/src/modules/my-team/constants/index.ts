// ─── My Team — Constants ─────────────────────────────────────────────────────

import type { AttendanceType, SelectableAttendanceType, ShiftType } from "../types";

export const attendanceMeta: Record<
  AttendanceType,
  { label: string; solid: string; soft: string; textColor: string }
> = {
  onsite: {
    label: "Onsite",
    solid: "#8b75c8",   // purple
    soft:  "#ded7f0",
    textColor: "#ffffff",
  },
  wfh: {
    label: "Work From Home",
    solid: "#cf67bd",   // pink/magenta
    soft:  "#f0d7eb",
    textColor: "#ffffff",
  },
  leave: {
    label: "Leave",
    solid: "#49a6e9",   // blue
    soft:  "#cce4f7",
    textColor: "#ffffff",
  },
  weeklyOff: {
    label: "Weekly Off",
    solid: "#ffc02f",   // amber
    soft:  "#f9e7b8",
    textColor: "#ffffff",
  },
  holiday: {
    label: "Holiday",
    solid: "#a6c63a",   // green
    soft:  "#e2ecc0",
    textColor: "#ffffff",
  },
};

export const indicatorColors = {
  leave: "#49a6e9",
  multipleLeave: "#ff6161",
} as const;

/** Options shown in the per-cell attendance list. */
export const dropdownOptions: Array<{
  label: string;
  type: SelectableAttendanceType;
}> = [
  { label: "Onsite",         type: "onsite" },
  { label: "Work From Home", type: "wfh"    },
  { label: "Leave",          type: "leave"  },
  { label: "Clear",          type: "clear"  },
];

export const shiftMeta: Record<
  ShiftType,
  { label: string; chip: string; hours: string }
> = {
  Morning:   { label: "Morning",   chip: "M", hours: "06:00–14:00" },
  Afternoon: { label: "Afternoon", chip: "A", hours: "14:00–22:00" },
  Night:     { label: "Night",     chip: "N", hours: "22:00–06:00" },
  General:   { label: "General",   chip: "G", hours: "09:00–18:00" },
};

export const shiftOptions: ShiftType[] = ["Morning", "Afternoon", "Night", "General"];

/** Shared G/M/A/N badge — uniform square, font-medium for optical balance across letters. */
export const shiftChipClass =
  "flex h-[17px] w-[17px] shrink-0 items-center justify-center rounded-[3.5px] text-[9.5px] font-medium leading-none antialiased text-[#64748b] bg-[#eceef2] select-none";

export const DEFAULT_SHIFT: ShiftType = "General";

export const shiftKeyMap: Record<string, ShiftType> = {
  m: "Morning",
  a: "Afternoon",
  n: "Night",
  g: "General",
};

/** Name column width. Day columns use this as a minimum and grow with the window. */
export const CALENDAR_NAME_COL_PX = 240;
export const CALENDAR_DAY_COL_PX = 40;
export const CALENDAR_END_PAD_PX = 12;
export const CALENDAR_ROW_PX = 72;
export const CALENDAR_HEADER_PX = 44;

/** Formats a Date as "Jul 2026" */
export const monthFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  year: "numeric",
});

/** Formats a Date as "Mon", "Tue", … */
export const weekdayFormatter = new Intl.DateTimeFormat("en-US", {
  weekday: "short",
});
