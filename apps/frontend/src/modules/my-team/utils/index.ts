// ─── My Team — Utilities ─────────────────────────────────────────────────────
// Pure helper functions extracted from the original my-team.tsx.
// All functions are stateless and independently testable.

import type { CalendarEvent, ShiftType, TeamMember, TeamSchedule } from "../types";
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

/** Parse a YYYY-MM-DD key as a local Date (avoids UTC shift). */
export function parseDateKey(dateKey: string): Date {
  const [year, month, day] = dateKey.split("-").map(Number);
  return new Date(year, month - 1, day);
}

export function isWeekendDate(date: Date): boolean {
  const weekday = date.getDay();
  return weekday === 0 || weekday === 6;
}

/** Monday of the week containing `date` (local, week starts Monday). */
export function getWeekMonday(date: Date): Date {
  const result = new Date(date);
  result.setHours(0, 0, 0, 0);
  const weekday = result.getDay();
  const offset = weekday === 0 ? -6 : 1 - weekday;
  result.setDate(result.getDate() + offset);
  return result;
}

export function getMonFriKeys(date: Date): string[] {
  const monday = getWeekMonday(date);
  return [0, 1, 2, 3, 4].map((offset) => makeDateKeyFromDate(addDays(monday, offset)));
}

export function getDateKeysInRange(startKey: string, endKey: string): string[] {
  const start = parseDateKey(startKey);
  const end = parseDateKey(endKey);
  const [from, to] = start <= end ? [start, end] : [end, start];
  const keys: string[] = [];
  for (let cursor = new Date(from); cursor <= to; cursor = addDays(cursor, 1)) {
    keys.push(makeDateKeyFromDate(cursor));
  }
  return keys;
}

export function isDateLocked(
  dateKey: string,
  today: Date,
  holidayMap: Record<string, string>,
): boolean {
  const date = parseDateKey(dateKey);
  date.setHours(0, 0, 0, 0);
  return date < today || Boolean(holidayMap[dateKey]);
}

function stripEmptyEvent(event: CalendarEvent | undefined): CalendarEvent | undefined {
  if (!event) return undefined;
  if (event.type || event.shift || event.sequenceId) return event;
  return undefined;
}

/**
 * Apply or clear a shift on a member's dates. Skips locked days.
 * Preserves attendance / sequence. Deletes the entry when nothing remains.
 */
export function applyShiftToMemberDates(
  schedule: TeamSchedule,
  memberId: string,
  dateKeys: string[],
  shift: ShiftType | undefined,
  isLocked: (dateKey: string) => boolean,
): TeamSchedule {
  const nextMember = { ...(schedule[memberId] ?? {}) };

  for (const dateKey of dateKeys) {
    if (isLocked(dateKey)) continue;
    const existing = nextMember[dateKey];
    if (shift) {
      nextMember[dateKey] = { ...existing, shift };
      continue;
    }
    if (!existing) continue;
    const { shift: _removed, ...rest } = existing;
    const nextEvent = stripEmptyEvent(rest);
    if (nextEvent) nextMember[dateKey] = nextEvent;
    else delete nextMember[dateKey];
  }

  return { ...schedule, [memberId]: nextMember };
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
  isWeeklyOffDay?: boolean,
): CalendarEvent | undefined {
  if (isWeeklyOffDay !== undefined) {
    if (!isWeeklyOffDay) return undefined;
    return {
      type: "weeklyOff",
      title: attendanceMeta.weeklyOff.label,
      sequenceId: `off-${memberId}-${makeDateKeyFromDate(date)}`,
    };
  }

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
 * Explicit attendance wins; a shift-only weekday stays shift-only;
 * weekly offs pick up auto Weekly Off when attendance is unset.
 */
export function getEventByDate(
  schedule: TeamSchedule,
  memberId: string,
  date: Date,
  isWeeklyOffDay?: boolean,
): CalendarEvent | undefined {
  const explicitEvent = getExplicitEvent(schedule, memberId, date);
  const weeklyOff = getAutomaticWeeklyOff(schedule, memberId, date, isWeeklyOffDay);
  if (!explicitEvent) return weeklyOff;
  if (!weeklyOff) return explicitEvent;
  return {
    ...weeklyOff,
    ...explicitEvent,
    type: explicitEvent.type ?? weeklyOff.type,
    title: explicitEvent.title ?? weeklyOff.title,
    sequenceId: explicitEvent.sequenceId ?? weeklyOff.sequenceId,
    shift: explicitEvent.shift,
  };
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

  const leaveCount = events.filter((event) => event.type === "leave").length;

  if (leaveCount > 1) return indicatorColors.multipleLeave;
  if (leaveCount === 1) return indicatorColors.leave;

  return undefined;
}
