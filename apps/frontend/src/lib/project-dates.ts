/**
 * Derives the project Start Date (earliest service start date)
 * and End Date (latest service end date) from the selected services.
 */
export function deriveProjectDates(
  services: Array<{ startDate?: string | null; endDate?: string | null }> | undefined | null,
  fallbackStartDate?: string | null,
  fallbackEndDate?: string | null,
): { startDate: string; endDate: string } {
  const safeServices = services ?? [];

  const validStarts = safeServices
    .map((s) => (typeof s.startDate === "string" ? s.startDate.trim() : ""))
    .filter((d) => Boolean(d && !isNaN(new Date(d).getTime())))
    .sort((a, b) => new Date(a).getTime() - new Date(b).getTime());

  const validEnds = safeServices
    .map((s) => (typeof s.endDate === "string" ? s.endDate.trim() : ""))
    .filter((d) => Boolean(d && !isNaN(new Date(d).getTime())))
    .sort((a, b) => new Date(a).getTime() - new Date(b).getTime());

  const startDate =
    validStarts.length > 0
      ? validStarts[0]
      : fallbackStartDate?.trim() || new Date().toISOString().slice(0, 10);

  const endDate =
    validEnds.length > 0
      ? validEnds[validEnds.length - 1]
      : fallbackEndDate?.trim() || new Date(Date.now() + 86400000 * 90).toISOString().slice(0, 10);

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

