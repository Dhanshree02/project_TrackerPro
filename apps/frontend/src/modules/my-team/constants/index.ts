// ─── My Team — Constants ─────────────────────────────────────────────────────

import type { AttendanceType, SelectableAttendanceType } from "../types";

export const attendanceMeta: Record<
  AttendanceType,
  { label: string; solid: string; soft: string; textColor: string }
> = {
  active: {
    label: "Active Today",
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
  /** One person on leave */
  leave: "#49a6e9",
  /** Multiple people on leave */
  multipleLeave: "#ff6161",
} as const;

/** User-selectable options in the per-cell dropdown. */
export const dropdownOptions: Array<{
  label: string;
  type: SelectableAttendanceType;
}> = [
  { label: "Active",         type: "active" },
  { label: "Work From Home", type: "wfh"    },
  { label: "Leave",          type: "leave"  },
  { label: "Clear",          type: "clear"  },
];

/** Formats a Date as "Jul 2026" */
export const monthFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  year: "numeric",
});

/** Formats a Date as "Mon", "Tue", … */
export const weekdayFormatter = new Intl.DateTimeFormat("en-US", {
  weekday: "short",
});
