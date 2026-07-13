// ─── My Team — Types ─────────────────────────────────────────────────────────

export type MemberStatus = "Active" | "WFH" | "On Leave";

/** Four visible attendance states shown in the calendar. */
export type AttendanceType = "active" | "wfh" | "leave" | "weeklyOff" | "holiday";

/** User-selectable per cell: active, leave, wfh, or clear (removes the mark). */
export type SelectableAttendanceType = "active" | "leave" | "wfh" | "clear";

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
