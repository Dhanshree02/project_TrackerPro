// ─── My Team — Constants ─────────────────────────────────────────────────────
// All static lookup tables and formatters for the My Team module.
// Reused by components, utils, and the service layer.

import type { AttendanceType, SelectableAttendanceType } from "../types";

export const attendanceMeta: Record<
  AttendanceType,
  { label: string; solid: string; soft: string; textColor: string }
> = {
  wfh: {
    label: "Work from home",
    solid: "#8b75c8",
    soft: "#ded7f0",
    textColor: "#ffffff",
  },
  onDuty: {
    label: "On duty",
    solid: "#cf67bd",
    soft: "#f0d7eb",
    textColor: "#ffffff",
  },
  paidLeave: {
    label: "Paid Leave",
    solid: "#74cbd4",
    soft: "#ccecef",
    textColor: "#ffffff",
  },
  unpaidLeave: {
    label: "Unpaid Leave",
    solid: "#cfc4a2",
    soft: "#eae5d5",
    textColor: "#ffffff",
  },
  noAttendance: {
    label: "Leave due to No Attendance",
    solid: "#f47f82",
    soft: "#f8d1d2",
    textColor: "#ffffff",
  },
  weeklyOff: {
    label: "Weekly off",
    solid: "#ffc02f",
    soft: "#f9e7b8",
    textColor: "#ffffff",
  },
  holiday: {
    label: "Holiday",
    solid: "#a6c63a",
    soft: "#e2ecc0",
    textColor: "#ffffff",
  },
};

export const indicatorColors = {
  /** Single person on leave */
  leave: "#49a6e9",
  /** Multiple people on leave on the same day */
  multipleLeave: "#ff6161",
} as const;

export const dropdownOptions: Array<{
  label: string;
  type: SelectableAttendanceType;
}> = [
  { label: "Leave", type: "paidLeave" },
  { label: "Holiday", type: "holiday" },
  { label: "Work from home", type: "wfh" },
];

/** Formats a Date as "Jun 2026" */
export const monthFormatter = new Intl.DateTimeFormat("en-US", {
  month: "short",
  year: "numeric",
});

/** Formats a Date as "Mon", "Tue", … */
export const weekdayFormatter = new Intl.DateTimeFormat("en-US", {
  weekday: "short",
});
