/**
 * Derives the project Start Date (earliest service start date)
 * and End Date (latest service end date) from the selected services.
 */
/** Calendar day from a date string. Blank and invalid values are ignored. */
function calendarDay(value?: string | null): string {
  if (typeof value !== "string") return "";
  const match = value.trim().match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (!match) return "";
  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  const utc = new Date(Date.UTC(year, month - 1, day));
  if (utc.getUTCFullYear() !== year || utc.getUTCMonth() !== month - 1 || utc.getUTCDate() !== day) return "";
  return `${match[1]}-${match[2]}-${match[3]}`;
}

export function deriveProjectDates(
  services: Array<{ startDate?: string | null; endDate?: string | null }> | undefined | null,
  fallbackStartDate?: string | null,
  fallbackEndDate?: string | null,
): { startDate: string; endDate: string } {
  const safeServices = services ?? [];

  const validStarts = safeServices
    .map((s) => calendarDay(s.startDate))
    .filter(Boolean)
    .sort();

  const validEnds = safeServices
    .map((s) => calendarDay(s.endDate))
    .filter(Boolean)
    .sort();

  const startDate =
    validStarts.length > 0
      ? validStarts[0]
      : calendarDay(fallbackStartDate) || new Date().toISOString().slice(0, 10);

  const endDate =
    validEnds.length > 0
      ? validEnds[validEnds.length - 1]
      : calendarDay(fallbackEndDate) || new Date(Date.now() + 86400000 * 90).toISOString().slice(0, 10);

  return { startDate, endDate };
}

/**
 * Formats a Date object or ISO / YYYY-MM-DD date string as DD/MM/YYYY (date/month/year).
 */
export function formatDateDMY(dateInput: Date | string | undefined | null): string {
  if (!dateInput) return "—";
  if (typeof dateInput === "string") {
    const trimmed = dateInput.trim();
    if (!trimmed) return "—";
    const match = trimmed.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (match) {
      const [, y, m, d] = match;
      return `${d}/${m}/${y}`;
    }
  }
  const dObj = dateInput instanceof Date ? dateInput : new Date(dateInput);
  if (isNaN(dObj.getTime())) return "—";
  const y = dObj.getFullYear();
  const m = String(dObj.getMonth() + 1).padStart(2, "0");
  const d = String(dObj.getDate()).padStart(2, "0");
  return `${d}/${m}/${y}`;
}

