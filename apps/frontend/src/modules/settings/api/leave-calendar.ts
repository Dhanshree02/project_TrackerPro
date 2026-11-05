import { apiFetch } from "@/lib/api-client";

export interface LeaveCalendarHoliday {
  id: string;
  date: string; // YYYY-MM-DD
  name: string;
  tag: string;
  color: string;
  description?: string | null;
  year: number;
  createdAtUtc?: string;
}

export interface UpsertLeaveCalendarHolidayPayload {
  date: string;
  name: string;
  tag: string;
  color: string;
  description?: string | null;
}

const STORAGE_KEY = "tk_pms_leave_calendar_holidays_v1";

export const DEFAULT_HOLIDAY_PRESETS: Array<Omit<LeaveCalendarHoliday, "id">> = [
  { date: "2026-01-01", name: "New Year's Day", tag: "Optional Holiday", color: "#0ea5e9", description: "First day of the year", year: 2026 },
  { date: "2026-01-26", name: "Republic Day", tag: "National Holiday", color: "#10b981", description: "Constitution of India commemoration", year: 2026 },
  { date: "2026-03-03", name: "Holi", tag: "Festival", color: "#ec4899", description: "Festival of Colours", year: 2026 },
  { date: "2026-03-20", name: "Id-ul-Fitr (Ramzan Eid)", tag: "Festival", color: "#8b5cf6", description: "Islamic festival marking end of Ramadan", year: 2026 },
  { date: "2026-04-03", name: "Good Friday", tag: "Public Holiday", color: "#3b82f6", description: "Christian public holiday", year: 2026 },
  { date: "2026-04-14", name: "Dr. Ambedkar Jayanti", tag: "Public Holiday", color: "#6366f1", description: "Birth anniversary of Dr. B. R. Ambedkar", year: 2026 },
  { date: "2026-05-01", name: "Maharashtra Day / May Day", tag: "Regional Holiday", color: "#f59e0b", description: "State holiday & Workers Day", year: 2026 },
  { date: "2026-05-27", name: "Bakrid / Id-ul-Zuha", tag: "Festival", color: "#8b5cf6", description: "Feast of Sacrifice", year: 2026 },
  { date: "2026-08-15", name: "Independence Day", tag: "National Holiday", color: "#10b981", description: "Indian Independence Day", year: 2026 },
  { date: "2026-09-14", name: "Ganesh Chaturthi", tag: "Festival", color: "#f97316", description: "Vinayaka Chaturthi", year: 2026 },
  { date: "2026-10-02", name: "Mahatma Gandhi Jayanti", tag: "National Holiday", color: "#10b981", description: "Birth anniversary of Mahatma Gandhi", year: 2026 },
  { date: "2026-10-20", name: "Dussehra (Vijaya Dashami)", tag: "Festival", color: "#ef4444", description: "Victory of Good over Evil", year: 2026 },
  { date: "2026-11-08", name: "Diwali (Laxmi Pujan)", tag: "Festival", color: "#eab308", description: "Festival of Lights - Laxmi Pujan", year: 2026 },
  { date: "2026-11-09", name: "Diwali (Balipratipada)", tag: "Festival", color: "#f59e0b", description: "New Year Celebration", year: 2026 },
  { date: "2026-12-25", name: "Christmas", tag: "Public Holiday", color: "#10b981", description: "Christmas celebration", year: 2026 },
];

export const PRESET_TAGS = [
  { name: "National Holiday", defaultColor: "#10b981" },
  { name: "Public Holiday",   defaultColor: "#3b82f6" },
  { name: "Festival",         defaultColor: "#ec4899" },
  { name: "Regional Holiday", defaultColor: "#f59e0b" },
  { name: "Optional Holiday", defaultColor: "#0ea5e9" },
  { name: "Company Holiday",  defaultColor: "#14b8a6" },
];

export const PRESET_COLORS = [
  { label: "Emerald", hex: "#10b981" },
  { label: "Leaf Green", hex: "#a6c63a" },
  { label: "Blue", hex: "#3b82f6" },
  { label: "Indigo", hex: "#6366f1" },
  { label: "Purple", hex: "#8b5cf6" },
  { label: "Pink", hex: "#ec4899" },
  { label: "Orange", hex: "#f97316" },
  { label: "Amber", hex: "#f59e0b" },
  { label: "Gold", hex: "#eab308" },
  { label: "Coral Red", hex: "#ef4444" },
  { label: "Cyan", hex: "#06b6d4" },
  { label: "Teal", hex: "#14b8a6" },
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

