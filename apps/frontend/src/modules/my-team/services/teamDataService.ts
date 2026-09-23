import { apiFetch } from "@/lib/api-client";
import { attendanceMeta } from "@/modules/my-team/constants";
import type {
  AttendanceType,
  MemberScheduleConfig,
  SelectableAttendanceType,
  ShiftType,
  TeamMember,
  TeamSchedule,
} from "@/modules/my-team/types";

const AVATAR_COLORS = ["#40aaf2", "#8b75c8", "#cf67bd", "#55b7a4", "#ef9b52", "#5a49b8"];

export interface TeamCalendarPayload {
  members: TeamMember[];
  schedule: TeamSchedule;
  configs: Record<string, MemberScheduleConfig>;
}

interface CalendarResponse {
  members: Array<{
    id: string;
    name: string;
    initials: string;
    designation: string;
    department: string;
  }>;
  entries: Array<{
    employeeId: string;
    date: string;
    attendance?: string | null;
    shift?: string | null;
  }>;
  schedules: Array<{
    employeeId: string;
    workingDays: number[];
    notes?: string | null;
    holidays: Array<{ date: string; name: string; comment?: string | null }>;
  }>;
}

function avatarColor(id: string): string {
  let hash = 0;
  for (const ch of id) hash = (hash + ch.charCodeAt(0)) % AVATAR_COLORS.length;
  return AVATAR_COLORS[hash];
}

function isAttendance(value: string | null | undefined): value is AttendanceType {
  return value === "onsite" || value === "wfh" || value === "leave";
}

function isShift(value: string | null | undefined): value is ShiftType {
  return value === "Morning" || value === "Afternoon" || value === "Night" || value === "General";
}

export const teamDataService = {
  async getCalendar(from: string, to: string): Promise<TeamCalendarPayload> {
    const data = await apiFetch<CalendarResponse>(
      `/api/v1/my-team/calendar?from=${encodeURIComponent(from)}&to=${encodeURIComponent(to)}`,
    );

    const members: TeamMember[] = data.members.map((member) => ({
      id: member.id,
      name: member.name,
      initials: member.initials,
      designation: member.designation,
      department: member.department,
      status: "Active",
      avatarColor: avatarColor(member.id),
    }));

    const schedule: TeamSchedule = {};
    for (const member of members) schedule[member.id] = {};
    for (const entry of data.entries) {
      if (!schedule[entry.employeeId]) continue;
      const type = isAttendance(entry.attendance) ? entry.attendance : undefined;
      const shift = isShift(entry.shift) ? entry.shift : undefined;
      if (!type && !shift) continue;
      schedule[entry.employeeId][entry.date] = {
        type,
        title: type ? attendanceMeta[type].label : undefined,
        shift,
      };
    }

    const configs: Record<string, MemberScheduleConfig> = {};
    for (const member of members) {
      const saved = data.schedules.find((row) => row.employeeId === member.id);
      configs[member.id] = {
        workingDays: saved?.workingDays?.length ? saved.workingDays : [1, 2, 3, 4, 5],
        notes: saved?.notes ?? "",
        holidays: (saved?.holidays ?? []).map((holiday) => ({
          date: holiday.date,
          name: holiday.name,
          comment: holiday.comment ?? undefined,
        })),
      };
    }

    return { members, schedule, configs };
  },

  upsertDays(body: {
    employeeId: string;
    dates: string[];
    attendance?: SelectableAttendanceType;
    shift?: ShiftType;
  }): Promise<boolean> {
    return apiFetch<boolean>("/api/v1/my-team/days", {
      method: "PUT",
      body: JSON.stringify(body),
    });
  },

  saveSchedule(employeeId: string, config: MemberScheduleConfig): Promise<boolean> {
    return apiFetch<boolean>(`/api/v1/my-team/members/${employeeId}/schedule`, {
      method: "PUT",
      body: JSON.stringify({
        workingDays: config.workingDays,
        notes: config.notes ?? "",
        holidays: config.holidays.map((holiday) => ({
          date: holiday.date,
          name: holiday.name,
          comment: holiday.comment ?? null,
        })),
      }),
    });
  },
};
