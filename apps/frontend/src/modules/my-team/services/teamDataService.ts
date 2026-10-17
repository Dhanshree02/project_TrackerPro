import { apiFetch } from "@/lib/api-client";
import { fetchAllEmployees, fetchJobRoleOptions } from "@/lib/api/employees";
import { uniqueOnFloorRoleLabels } from "@/lib/on-floor-role";
import { attendanceMeta } from "@/modules/my-team/constants";
import type {
  AttendanceType,
  MemberScheduleConfig,
  PoolAllocationStatus,
  PoolAllocationType,
  SelectableAttendanceType,
  ShiftType,
  TeamMember,
  TeamMemberProjectAllocation,
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
    jobRoleName?: string | null;
    directReport?: boolean;
    employeeCode?: string | null;
    reportingManagerName?: string | null;
    status?: string | null;
    allocationStatus?: string | null;
    allocationType?: string | null;
    allocationStartDate?: string | null;
    allocationEndDate?: string | null;
    allocatedProjectName?: string | null;
    allocations?: Array<{
      projectId: string;
      projectName: string;
      allocationType: string;
      allocationStartDate: string;
      allocationEndDate: string;
      billability?: string | null;
      memberRole?: string | null;
    }> | null;
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

function normalizeAllocationType(val?: string | null): PoolAllocationType | undefined {
  if (!val) return undefined;
  return val.toLowerCase().startsWith("shared") ? "Shared" : "Dedicated";
}

function normalizeAllocationStatus(val?: string | null): PoolAllocationStatus | undefined {
  if (val === "On Leave" || val === "Occupied" || val === "Free") return val;
  return undefined;
}

let employeeOnFloorRoleById: Promise<Map<string, string>> | null = null;

async function loadEmployeeOnFloorRoleById(): Promise<Map<string, string>> {
  if (!employeeOnFloorRoleById) {
    employeeOnFloorRoleById = fetchAllEmployees()
      .then((rows) => {
        const map = new Map<string, string>();
        for (const row of rows) {
          const role = (row.jobRoleName ?? row.jobRole ?? "").trim();
          if (role) map.set(row.id, role);
        }
        return map;
      })
      .catch((error) => {
        employeeOnFloorRoleById = null;
        throw error;
      });
  }
  return employeeOnFloorRoleById;
}

async function attachOnFloorRoles(members: TeamMember[]): Promise<TeamMember[]> {
  if (members.length === 0) return members;
  if (members.every((m) => m.jobRoleName)) return members;

  const byId = await loadEmployeeOnFloorRoleById();
  return members.map((member) => {
    if (member.jobRoleName) return member;
    const role = byId.get(member.id);
    return role ? { ...member, jobRoleName: role } : member;
  });
}

export const teamDataService = {
  /** Active on-floor role names from master.mst_roles. */
  async getOnFloorRoleNames(): Promise<string[]> {
    try {
      const fromTeam = await apiFetch<string[]>("/api/v1/my-team/on-floor-roles");
      const labels = uniqueOnFloorRoleLabels(fromTeam ?? []);
      if (labels.length > 0) return labels;
    } catch {
      // UAT images built before my-team/on-floor-roles still load via meta/roles.
    }
    try {
      const byId = await loadEmployeeOnFloorRoleById();
      const fromRoster = uniqueOnFloorRoleLabels(byId.values());
      if (fromRoster.length > 0) return fromRoster;
    } catch {
      // fall through to designation catalog
    }
    const catalog = await fetchJobRoleOptions();
    return uniqueOnFloorRoleLabels(catalog.map((row) => row.name));
  },

  async getCalendar(from: string, to: string, allEmployees = false): Promise<TeamCalendarPayload> {
    const scope = allEmployees ? "&all=true" : "";
    const data = await apiFetch<CalendarResponse>(
      `/api/v1/my-team/calendar?from=${encodeURIComponent(from)}&to=${encodeURIComponent(to)}${scope}`,
    );

    const members: TeamMember[] = data.members.map((member) => {
      const allocations: TeamMemberProjectAllocation[] = (member.allocations ?? []).map((a) => ({
        projectId: a.projectId,
        projectName: a.projectName,
        allocationType: normalizeAllocationType(a.allocationType) ?? "Dedicated",
        allocationStartDate: a.allocationStartDate.slice(0, 10),
        allocationEndDate: a.allocationEndDate.slice(0, 10),
        billability: a.billability ?? undefined,
        memberRole: a.memberRole ?? undefined,
      }));

      return {
        id: member.id,
        name: member.name,
        initials: member.initials,
        designation: member.designation,
        department: member.department,
        jobRoleName: member.jobRoleName?.trim() || undefined,
        status: "Active",
        avatarColor: avatarColor(member.id),
        directReport: member.directReport !== false,
        employeeCode: member.employeeCode ?? undefined,
        reportingManagerName: member.reportingManagerName ?? undefined,
        employeeStatus: member.status ?? undefined,
        allocationStatus: normalizeAllocationStatus(member.allocationStatus),
        allocationType: normalizeAllocationType(member.allocationType),
        allocationStartDate: member.allocationStartDate?.slice(0, 10) ?? undefined,
        allocationEndDate: member.allocationEndDate?.slice(0, 10) ?? undefined,
        allocatedProjectName: member.allocatedProjectName ?? undefined,
        allocations,
      };
    });

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

    const scheduleByEmployee = new Map(data.schedules.map((row) => [row.employeeId, row]));
    const configs: Record<string, MemberScheduleConfig> = {};
    for (const member of members) {
      const saved = scheduleByEmployee.get(member.id);
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

    const membersWithRoles = await attachOnFloorRoles(members);

    return { members: membersWithRoles, schedule, configs };
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
