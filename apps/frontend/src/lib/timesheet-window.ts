function startOfToday() {
  const date = new Date();
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function parseIsoDate(iso: string) {
  const [year, month, day] = iso.split("-").map(Number);
  return new Date(year, (month || 1) - 1, day || 1);
}

function addDays(date: Date, days: number) {
  const next = new Date(date);
  next.setDate(next.getDate() + days);
  return next;
}

/** Inclusive window: one week before today through two days ahead. */
function windowBounds(today = startOfToday()) {
  return { earliest: addDays(today, -7), latest: addDays(today, 2) };
}

export function isTimesheetDayOpen(weekStart: string, dayIndex: number, today = startOfToday()) {
  const date = addDays(parseIsoDate(weekStart), dayIndex);
  const { earliest, latest } = windowBounds(today);
  return date >= earliest && date <= latest;
}

export function canShiftTimesheetWeek(weekStart: string, deltaDays: number, today = startOfToday()) {
  const nextMonday = addDays(parseIsoDate(weekStart), deltaDays);
  const nextSunday = addDays(nextMonday, 6);
  const { earliest, latest } = windowBounds(today);
  return nextSunday >= earliest && nextMonday <= latest;
}
