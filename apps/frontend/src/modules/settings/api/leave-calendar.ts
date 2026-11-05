import { apiFetch } from "@/lib/api-client";

export interface LeaveCalendarHoliday {
  id: string;
  date: string; // YYYY-MM-DD
  name: string;
  year: number;
  createdAtUtc?: string;
}

export interface UpsertLeaveCalendarHolidayPayload {
  date: string;
  name: string;
}

const STORAGE_KEY = "tk_pms_holiday_calendar_holidays_v2";

export const DEFAULT_HOLIDAY_PRESETS: Array<Omit<LeaveCalendarHoliday, "id">> = [
  { date: "2026-01-01", name: "New Year's Day", year: 2026 },
  { date: "2026-01-26", name: "Republic Day", year: 2026 },
  { date: "2026-03-03", name: "Holi", year: 2026 },
  { date: "2026-03-20", name: "Id-ul-Fitr (Ramzan Eid)", year: 2026 },
  { date: "2026-04-03", name: "Good Friday", year: 2026 },
  { date: "2026-04-14", name: "Dr. Ambedkar Jayanti", year: 2026 },
  { date: "2026-05-01", name: "Maharashtra Day / May Day", year: 2026 },
  { date: "2026-05-27", name: "Bakrid / Id-ul-Zuha", year: 2026 },
  { date: "2026-08-15", name: "Independence Day", year: 2026 },
  { date: "2026-09-14", name: "Ganesh Chaturthi", year: 2026 },
  { date: "2026-10-02", name: "Mahatma Gandhi Jayanti", year: 2026 },
  { date: "2026-10-20", name: "Dussehra (Vijaya Dashami)", year: 2026 },
  { date: "2026-11-08", name: "Diwali (Laxmi Pujan)", year: 2026 },
  { date: "2026-11-09", name: "Diwali (Balipratipada)", year: 2026 },
  { date: "2026-12-25", name: "Christmas", year: 2026 },
];

export function getLocalFallbackHolidays(): LeaveCalendarHoliday[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed) && parsed.length > 0) return parsed;
    }
  } catch {
    // ignore
  }

  const seeded: LeaveCalendarHoliday[] = DEFAULT_HOLIDAY_PRESETS.map((p, idx) => ({
    ...p,
    id: `local-holiday-${idx + 1}`,
    createdAtUtc: new Date().toISOString(),
  }));
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(seeded));
  } catch {
    // ignore
  }
  return seeded;
}

export function saveLocalHolidays(holidays: LeaveCalendarHoliday[]): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(holidays));
    window.dispatchEvent(new CustomEvent("tk:leave-calendar-updated", { detail: holidays }));
  } catch {
    // ignore
  }
}

export async function fetchLeaveCalendarHolidays(year?: number): Promise<LeaveCalendarHoliday[]> {
  try {
    const url = year ? `/api/v1/leave-calendar?year=${year}` : "/api/v1/leave-calendar";
    const data = await apiFetch<LeaveCalendarHoliday[]>(url);
    if (Array.isArray(data) && data.length > 0) {
      saveLocalHolidays(data);
      return data;
    }
  } catch {
    // fallback if API not reachable or table missing
  }

  const locals = getLocalFallbackHolidays();
  if (year) {
    return locals.filter((h) => h.year === year || Number(h.date.slice(0, 4)) === year);
  }
  return locals;
}

export async function createLeaveCalendarHoliday(
  payload: UpsertLeaveCalendarHolidayPayload
): Promise<LeaveCalendarHoliday> {
  const year = Number(payload.date.slice(0, 4));
  let created: LeaveCalendarHoliday;

  try {
    created = await apiFetch<LeaveCalendarHoliday>("/api/v1/leave-calendar", {
      method: "POST",
      body: JSON.stringify(payload),
    });
  } catch {
    created = {
      id: `local-holiday-${Date.now()}`,
      ...payload,
      year,
      createdAtUtc: new Date().toISOString(),
    };
  }

  const current = getLocalFallbackHolidays().filter((h) => h.date !== created.date);
  current.push(created);
  saveLocalHolidays(current);
  return created;
}

export async function updateLeaveCalendarHoliday(
  id: string,
  payload: UpsertLeaveCalendarHolidayPayload
): Promise<LeaveCalendarHoliday> {
  const year = Number(payload.date.slice(0, 4));
  let updated: LeaveCalendarHoliday;

  try {
    updated = await apiFetch<LeaveCalendarHoliday>(`/api/v1/leave-calendar/${id}`, {
      method: "PUT",
      body: JSON.stringify(payload),
    });
  } catch {
    updated = {
      id,
      ...payload,
      year,
      createdAtUtc: new Date().toISOString(),
    };
  }

  const current = getLocalFallbackHolidays().map((h) => (h.id === id ? updated : h));
  saveLocalHolidays(current);
  return updated;
}

export async function deleteLeaveCalendarHoliday(id: string): Promise<boolean> {
  try {
    await apiFetch(`/api/v1/leave-calendar/${id}`, { method: "DELETE" });
  } catch {
    // local fallback
  }

  const current = getLocalFallbackHolidays().filter((h) => h.id !== id);
  saveLocalHolidays(current);
  return true;
}

export async function bulkCreateLeaveCalendarHolidays(
  holidays: UpsertLeaveCalendarHolidayPayload[]
): Promise<LeaveCalendarHoliday[]> {
  try {
    const res = await apiFetch<LeaveCalendarHoliday[]>("/api/v1/leave-calendar/bulk", {
      method: "POST",
      body: JSON.stringify(holidays),
    });
    if (Array.isArray(res) && res.length > 0) {
      saveLocalHolidays(res);
      return res;
    }
  } catch {
    // local fallback
  }

  const current = getLocalFallbackHolidays();
  const dateMap = new Map(current.map((h) => [h.date, h]));
  for (const h of holidays) {
    const year = Number(h.date.slice(0, 4));
    dateMap.set(h.date, {
      id: `local-holiday-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
      ...h,
      year,
      createdAtUtc: new Date().toISOString(),
    });
  }
  const merged = Array.from(dateMap.values()).sort((a, b) => a.date.localeCompare(b.date));
  saveLocalHolidays(merged);
  return merged;
}
