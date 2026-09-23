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
  /** Absent when the day only has a shift assigned. */
  type?: AttendanceType;
  title?: string;
  sequenceId?: string;
  shift?: ShiftType;
};

/** memberId → dateKey (YYYY-MM-DD) → event */
export type TeamSchedule = Record<string, Record<string, CalendarEvent>>;

export type ScheduleEntry = {
  memberId: string;
  date: string;
  type?: AttendanceType;
  sequenceId?: string;
  title?: string;
  shift?: ShiftType;
};

export type CellRef = { memberId: string; dateKey: string };

/** A company-wide holiday on a specific date. */
export type HolidayEntry = {
  date: string;   // YYYY-MM-DD
  name: string;
};

/** Individual holiday for an employee (e.g. onsite client or regional holiday). */
export type MemberHoliday = {
  date: string;     // YYYY-MM-DD
  name: string;
  comment?: string;
};

/** Per-employee work schedule configuration. */
export type MemberScheduleConfig = {
  /** Days of the week employee works. 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat */
  workingDays: number[];
  /** Custom holidays configured for this specific employee */
  holidays: MemberHoliday[];
  /** Context notes or schedule comments (e.g., onsite client location, special timings) */
  notes?: string;
};

export const DEFAULT_MEMBER_SCHEDULE_CONFIG: MemberScheduleConfig = {
  workingDays: [1, 2, 3, 4, 5], // Mon–Fri
  holidays: [],
  notes: "",
};

export type OpenCell = { memberId: string; dateKey: string } | null;

