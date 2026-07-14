// ─── My Team — Types ─────────────────────────────────────────────────────────

export type MemberStatus = "Active" | "WFH" | "On Leave";

/**
 * Attendance states visible in the calendar.
 * "onsite"    — explicitly marked as on-site (office)
 * "wfh"       — working from home
 * "leave"     — on leave
 * "weeklyOff" — auto-derived for Sat/Sun
 * "holiday"   — company-wide holiday (managed via Holiday Manager)
 */
export type AttendanceType = "onsite" | "wfh" | "leave" | "weeklyOff" | "holiday";

/**
 * Types the user can select from the per-cell dropdown.
 * "onsite" | "wfh" | "leave" — set an explicit status
 * "clear"                    — remove any explicit status (employee defaults to active)
 */
export type SelectableAttendanceType = "onsite" | "wfh" | "leave" | "clear";

export type ShiftType = "Morning" | "Afternoon" | "Night" | "General";

export type TeamMember = {
  id: string;
  name: string;
  initials: string;
  designation: string;
  department: string;
  status: MemberStatus;
  avatarColor: string;
};

export type CalendarEvent = {
  type: AttendanceType;
  title?: string;
  sequenceId?: string;
};

/** memberId → dateKey (YYYY-MM-DD) → event */
export type TeamSchedule = Record<string, Record<string, CalendarEvent>>;

export type ScheduleEntry = {
  memberId: string;
  date: string;
  type: AttendanceType;
  sequenceId?: string;
  title?: string;
};

/** A company-wide holiday on a specific date. */
export type HolidayEntry = {
  date: string;   // YYYY-MM-DD
  name: string;
};

export type OpenCell = { memberId: string; dateKey: string } | null;
