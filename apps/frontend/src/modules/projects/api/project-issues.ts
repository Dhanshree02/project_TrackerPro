import { apiFetch } from "@/lib/api-client";

export interface ProjectIssue {
  id: string;
  projectId: string;
  projectCode?: string | null;
  projectName: string;
  issueType: string;
  priority: "Low" | "Medium" | "High" | "Critical";
  subject: string;
  description: string;
  status: string;
  raisedByEmployeeId?: string | null;
  raisedByName: string;
  raisedByRole?: string | null;
  createdAtUtc: string;
}

export interface CreateProjectIssuePayload {
  projectId?: string;
  subject: string;
  description: string;
  issueType?: string;
  priority?: string;
}

export interface ProjectAlert {
  id: string;
  projectId: string;
  issueId?: string | null;
  title: string;
  description?: string | null;
  alertType: string;
  priority: "Low" | "Medium" | "High" | "Critical";
  status: "Open" | "Acknowledged" | "Resolved" | "Closed";
  raisedByEmployeeId?: string | null;
  raisedByName: string;
  createdAtUtc: string;
}

export interface AssignedProjectSummary {
  id: string;
  name: string;
  projectCode?: string | null;
  customerName?: string | null;
  status?: string | null;
}

export async function fetchMyAssignedProjects(): Promise<AssignedProjectSummary[]> {
  const res = await apiFetch<AssignedProjectSummary[]>("/api/v1/projects/my-assigned-projects");
  return res ?? [];
}

export async function fetchProjectIssues(projectId: string): Promise<ProjectIssue[]> {
  const res = await apiFetch<ProjectIssue[]>(`/api/v1/projects/${projectId}/issues`);
  return res ?? [];
}

export async function createProjectIssue(
  projectId: string,
  payload: CreateProjectIssuePayload,
): Promise<ProjectIssue> {
  return apiFetch<ProjectIssue>(`/api/v1/projects/${projectId}/issues`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function createProjectIssueDirect(
  payload: CreateProjectIssuePayload,
): Promise<ProjectIssue> {
  return apiFetch<ProjectIssue>("/api/v1/projects/issues", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function fetchProjectAlerts(projectId: string): Promise<ProjectAlert[]> {
  const res = await apiFetch<ProjectAlert[]>(`/api/v1/projects/${projectId}/alerts`);
  return res ?? [];
}

export async function updateAlertStatus(
  projectId: string,
  alertId: string,
  status: string,
): Promise<ProjectAlert> {
  return apiFetch<ProjectAlert>(`/api/v1/projects/${projectId}/alerts/${alertId}/status`, {
    method: "PUT",
    body: JSON.stringify({ status }),
  });
}
