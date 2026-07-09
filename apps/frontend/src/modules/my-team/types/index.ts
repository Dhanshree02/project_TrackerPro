// ─── My Team — Types ─────────────────────────────────────────────────────────

export type MemberStatus = "Active" | "WFH" | "On Leave";

export type AttendanceType =
  | "wfh"
  | "onDuty"
  | "paidLeave"
  | "unpaidLeave"
  | "noAttendance"
  | "weeklyOff"
  | "holiday";

export type SelectableAttendanceType = "paidLeave" | "holiday" | "wfh";

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

export type OpenCell = { memberId: string; dateKey: string } | null;
