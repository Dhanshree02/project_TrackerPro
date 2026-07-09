// ─── My Team — Utilities ─────────────────────────────────────────────────────
// Pure helper functions extracted from the original my-team.tsx.
// All functions are stateless and independently testable.

import type { CalendarEvent, TeamMember, TeamSchedule } from "../types";
import { attendanceMeta, indicatorColors } from "../constants";

// ── Date helpers ──────────────────────────────────────────────────────────────

/** Returns a zero-padded YYYY-MM-DD key from individual parts. */
export function makeDateKey(
  year: number,
  monthIndex: number,
  day: number,
): string {
  return `${year}-${String(monthIndex + 1).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
}

/** Returns a YYYY-MM-DD key from a Date object. */
export function makeDateKeyFromDate(date: Date): string {
  return makeDateKey(date.getFullYear(), date.getMonth(), date.getDate());
}

/** Returns a new Date shifted by `amount` days (positive = forward). */
export function addDays(date: Date, amount: number): Date {
  const result = new Date(date);
  result.setDate(result.getDate() + amount);
  return result;
}

// ── Schedule helpers ──────────────────────────────────────────────────────────

/**
 * Returns an explicitly set calendar event for a member on a given date,
 * or undefined if no event has been set.
 */
export function getExplicitEvent(
  schedule: TeamSchedule,
  memberId: string,
  date: Date,
): CalendarEvent | undefined {
  return schedule[memberId]?.[makeDateKeyFromDate(date)];
}

/**
 * Given any Saturday or Sunday, returns the matching Saturday + Sunday pair.
 */
export function getWeekendDates(date: Date): {
  saturday: Date;
  sunday: Date;
} {
  if (date.getDay() === 6) {
    return { saturday: new Date(date), sunday: addDays(date, 1) };
  }
  return { saturday: addDays(date, -1), sunday: new Date(date) };
}

/**
 * Automatically derives a Weekly Off event for any Saturday or Sunday,
 * inheriting the sequence ID from the adjacent Friday or Monday so that
 * the pill connector renders correctly across the weekend boundary.
 *
 * Returns undefined for weekday dates.
 */
export function getAutomaticWeeklyOff(
  schedule: TeamSchedule,
  memberId: string,
  date: Date,
): CalendarEvent | undefined {
  const weekday = date.getDay();
  if (weekday !== 0 && weekday !== 6) return undefined;

  const { saturday, sunday } = getWeekendDates(date);
  const friday = addDays(saturday, -1);
  const monday = addDays(sunday, 1);

  const fridayEvent = getExplicitEvent(schedule, memberId, friday);
  const mondayEvent = getExplicitEvent(schedule, memberId, monday);

  // Do not inherit a holiday's sequence — holidays stand on their own.
  const fridaySequence =
    fridayEvent?.type !== "holiday" ? fridayEvent?.sequenceId : undefined;
  const mondaySequence =
    mondayEvent?.type !== "holiday" ? mondayEvent?.sequenceId : undefined;

  return {
    type: "weeklyOff",
    title: attendanceMeta.weeklyOff.label,
    sequenceId:
      fridaySequence ??
      mondaySequence ??
      `weekend-${memberId}-${makeDateKeyFromDate(saturday)}`,
  };
}

/**
 * Returns the calendar event for a member on a given date.
 * Explicit events take priority; weekends fall back to an auto Weekly Off.
 */
export function getEventByDate(
  schedule: TeamSchedule,
  memberId: string,
  date: Date,
): CalendarEvent | undefined {
  const explicitEvent = getExplicitEvent(schedule, memberId, date);
  if (explicitEvent) return explicitEvent;
  return getAutomaticWeeklyOff(schedule, memberId, date);
}

// ── Header indicator helper ───────────────────────────────────────────────────

/**
 * Returns the dot colour to display beneath a day-of-month header:
 * - Red dot   → multiple people on leave that day
 * - Blue dot  → exactly one person on leave
 * - Purple dot→ at least one person WFH (no leave)
 * - undefined → nothing to highlight
 */
export function getDayIndicator(
  schedule: TeamSchedule,
  teamMembers: TeamMember[],
  year: number,
  monthIndex: number,
  day: number,
): string | undefined {
  const date = new Date(year, monthIndex, day);

  const events = teamMembers
    .map((member) => getEventByDate(schedule, member.id, date))
    .filter((event): event is CalendarEvent => Boolean(event));

  const leaveCount = events.filter((event) =>
    ["paidLeave", "unpaidLeave", "noAttendance"].includes(event.type),
  ).length;

  if (leaveCount > 1) return indicatorColors.multipleLeave;
  if (leaveCount === 1) return indicatorColors.leave;
  if (events.some((event) => event.type === "wfh")) return attendanceMeta.wfh.solid;

  return undefined;
}
