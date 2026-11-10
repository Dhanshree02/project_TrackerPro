import { apiFetch } from "@/lib/api-client";

export interface ApiProjectTeamMember {
  id: string;
  projectId: string;
  employeeId: string;
  employeeName: string;
  employeeCode: string;
  employeeEmail?: string | null;
  employeeRole?: string | null;
  departmentId?: string | null;
  department?: string | null;
  subDepartment?: string | null;
  allocationStartDate: string;
  allocationEndDate: string;
  billability: string;
  isTeamLead: boolean;
  resourceType: string;
  isShadowTeam: boolean;
  memberRole?: string | null;
  createdAtUtc: string;
  updatedAtUtc?: string | null;
}

export interface EmployeeAllocationBooking {
  projectId: string;
  projectName: string;
  startDate: string;
  endDate: string;
  resourceType: string;
}

export interface ApiProjectTeamCandidate {
  id: string;
  employeeCode: string;
  fullName: string;
  workEmail: string;
  role?: string | null;
  designation?: string | null;
  departmentId?: string | null;
  department?: string | null;
  subDepartment?: string | null;
}

export interface CreateProjectTeamMemberPayload {
  employeeId: string;
  allocationStartDate: string;
  allocationEndDate: string;
  billability: string;
  isTeamLead?: boolean;
  resourceType: string;
  isShadowTeam?: boolean;
}

export interface UpdateProjectTeamMemberPayload {
  allocationStartDate?: string;
  allocationEndDate?: string;
  billability?: string;
  isTeamLead?: boolean;
  resourceType?: string;
}

export interface ProjectResourceAllocationRequestDto {
  id: string;
  projectId: string;
  projectName?: string | null;
  employeeId: string;
  employeeName: string;
  employeeCode?: string | null;
  employeeEmail?: string | null;
  departmentId?: string | null;
  department?: string | null;
  subDepartment?: string | null;
  allocationStartDate: string;
  allocationEndDate: string;
  billability: string;
  isTeamLead: boolean;
  resourceType: string;
  isShadowTeam: boolean;
  status: string;
  requestedByEmployeeId?: string | null;
  requestedByName?: string | null;
  approverEmployeeId?: string | null;
  approverName?: string | null;
  commentsJson?: string | null;
  createdAtUtc: string;
  updatedAtUtc?: string | null;
}

export async function fetchProjectTeamMembers(
  projectId: string,
  options?: { shadow?: boolean },
): Promise<ApiProjectTeamMember[]> {
  const q = options?.shadow ? "?shadow=true" : "";
  const res = await apiFetch<ApiProjectTeamMember[]>(
    `/api/v1/projects/${projectId}/team-members${q}`,
  );
  return res ?? [];
}

export async function searchProjectTeamCandidates(
  projectId: string,
  search?: string,
  limit = 80,
  options?: { internsOnly?: boolean },
): Promise<ApiProjectTeamCandidate[]> {
  const q = new URLSearchParams();
  if (search?.trim()) q.set("search", search.trim());
  q.set("limit", String(limit));
  if (options?.internsOnly) q.set("internsOnly", "true");
  const qs = q.toString();
  const res = await apiFetch<ApiProjectTeamCandidate[]>(
    `/api/v1/projects/${projectId}/team-members/candidates${qs ? `?${qs}` : ""}`,
  );
  return res ?? [];
}

export async function fetchEmployeeAllocations(
  projectId: string,
  employeeId: string,
): Promise<EmployeeAllocationBooking[]> {
  const res = await apiFetch<EmployeeAllocationBooking[]>(
    `/api/v1/projects/${projectId}/team-members/allocations?employeeId=${encodeURIComponent(employeeId)}`,
  );
  return res ?? [];
}

export async function addProjectTeamMember(
  projectId: string,
  payload: CreateProjectTeamMemberPayload,
): Promise<ApiProjectTeamMember> {
  return apiFetch<ApiProjectTeamMember>(`/api/v1/projects/${projectId}/team-members`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function requestProjectTeamMemberAllocation(
  projectId: string,
  payload: CreateProjectTeamMemberPayload,
): Promise<ProjectResourceAllocationRequestDto> {
  return apiFetch<ProjectResourceAllocationRequestDto>(
    `/api/v1/projects/${projectId}/allocation-requests`,
    {
      method: "POST",
      body: JSON.stringify(payload),
    },
  );
}

export async function fetchPendingAllocationApprovals(): Promise<ProjectResourceAllocationRequestDto[]> {
  const res = await apiFetch<ProjectResourceAllocationRequestDto[]>(
    `/api/v1/action-centre/allocation-approvals`,
  );
  return res ?? [];
}

export async function fetchProjectAllocationRequests(
  projectId: string,
): Promise<ProjectResourceAllocationRequestDto[]> {
  const res = await apiFetch<ProjectResourceAllocationRequestDto[]>(
    `/api/v1/projects/${projectId}/allocation-requests`,
  );
  return res ?? [];
}

export async function takeResourceAllocationAction(
  projectId: string,
  requestId: string,
  status: "Approved" | "Rejected" | "Hold" | "Request Changes",
  comment?: string,
): Promise<ProjectResourceAllocationRequestDto> {
  return apiFetch<ProjectResourceAllocationRequestDto>(
    `/api/v1/projects/${projectId}/allocation-requests/${requestId}/action`,
    {
      method: "POST",
      body: JSON.stringify({ status, comment }),
    },
  );
}

export async function updateProjectTeamMember(
  projectId: string,
  memberId: string,
  payload: UpdateProjectTeamMemberPayload,
): Promise<ApiProjectTeamMember> {
  return apiFetch<ApiProjectTeamMember>(`/api/v1/projects/${projectId}/team-members/${memberId}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

export async function syncProjectLeadership(
  projectId: string,
  payload: { projectManagerIds?: string[]; seniorProjectManagerIds?: string[] },
): Promise<ApiProjectTeamMember[]> {
  const res = await apiFetch<ApiProjectTeamMember[]>(`/api/v1/projects/${projectId}/leadership`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
  return res ?? [];
}

export function isProjectManagerRole(role?: string | null): boolean {
  return role === "ProjectManager";
}

export function isSeniorProjectManagerRole(role?: string | null): boolean {
  return role === "SeniorProjectManager";
}

export function isManagerRole(role?: string | null): boolean {
  return isProjectManagerRole(role) || isSeniorProjectManagerRole(role);
}

export async function removeProjectTeamMember(projectId: string, memberId: string): Promise<void> {
  await apiFetch<boolean>(`/api/v1/projects/${projectId}/team-members/${memberId}`, {
    method: "DELETE",
  });
}

/** Parse UI duration "DD/MM/YYYY → DD/MM/YYYY" into ISO date strings. */
export function parseAllocationDuration(duration: string): { start: string; end: string } | null {
  const parts = duration.split(" → ").map((s) => s.trim());
  if (parts.length < 2 || !parts[0] || !parts[1]) return null;
  const start = toIsoDate(parts[0]);
  const end = toIsoDate(parts[1]);
  if (!start || !end) return null;
  return { start, end };
}

function toIsoDate(raw: string): string | null {
  // DD/MM/YYYY
  const dmy = raw.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (dmy) {
    const [, d, m, y] = dmy;
    return `${y}-${m.padStart(2, "0")}-${d.padStart(2, "0")}`;
  }
  // ISO already
  const iso = raw.match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (iso) return `${iso[1]}-${iso[2]}-${iso[3]}`;
  // M/D/YYYY fallback
  const mdY = raw.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (mdY) {
    const [, a, b, y] = mdY;
    const month = Number(a);
    const day = Number(b);
    if (month > 12) return `${y}-${b.padStart(2, "0")}-${a.padStart(2, "0")}`;
    return `${y}-${a.padStart(2, "0")}-${b.padStart(2, "0")}`;
  }
  return null;
}

export function formatAllocationDuration(start: string, end: string): string {
  const fmt = (iso: string) => {
    const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (!m) return iso;
    return `${m[3]}/${m[2]}/${m[1]}`;
  };
  return `${fmt(start)} → ${fmt(end)}`;
}


export interface EmployeeAssignedTaskDto {
  taskId: string;
  taskTitle: string;
  projectId: string;
  projectName: string;
  stage: string;
  progress: number;
  priority: string;
  role?: string | null;
  plannedStartDate?: string | null;
  plannedEndDate?: string | null;
  dueDate?: string | null;
}

export interface EmployeeAssignedProjectDto {
  projectId: string;
  projectName: string;
  projectStatus: string;
  role: string;
  allocationStartDate?: string | null;
  allocationEndDate?: string | null;
  billability?: string | null;
  resourceType?: string | null;
}

export interface EmployeeWorkloadDto {
  employeeId: string;
  employeeName: string;
  employeeCode?: string | null;
  role?: string | null;
  email?: string | null;
  assignedTasks: EmployeeAssignedTaskDto[];
  assignedProjects: EmployeeAssignedProjectDto[];
}

export async function fetchEmployeeWorkload(
  employeeId: string,
  projectId?: string,
): Promise<EmployeeWorkloadDto> {
  const url = projectId
    ? `/api/v1/projects/${projectId}/team-members/${employeeId}/workload`
    : `/api/v1/projects/resources/${employeeId}/workload`;
  return apiFetch<EmployeeWorkloadDto>(url);
}
