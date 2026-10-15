import { apiFetch } from "@/lib/api-client";

export interface IssueAuditEntry {
  action: string;
  details: string;
  timestampUtc: string;
  actorName?: string | null;
}

export interface ProjectIssueApiItem {
  id: string;
  projectId: string;
  projectName: string;
  projectCode: string;
  title: string;
  description: string;
  category: "Technical Related Issues" | "Behavioral Related Issues" | "Process Related Issues" | string;
  priority: "Low" | "Medium" | "High" | "Critical" | string;
  status: "Open" | "In Progress" | "Resolved" | "Closed" | string;
  raisedByEmployeeId?: string | null;
  raisedByName: string;
  raisedByRole: string;
  escalationLevel: number;
  currentAssigneeRole: "PM" | "SPM" | "EM" | "PMO" | "HOD" | "CEO" | string;
  currentAssigneeEmployeeId?: string | null;
  currentAssigneeName?: string | null;
  dottedLineManagerId?: string | null;
  dottedLineManagerName?: string | null;
  daysElapsed: number;
  hoursUntilNextEscalation: number;
  createdAtUtc: string;
  lastEscalatedAtUtc?: string | null;
  resolvedAtUtc?: string | null;
  resolvedByName?: string | null;
  resolutionNotes?: string | null;
  auditHistory: IssueAuditEntry[];
}

export interface CreateIssueInput {
  projectId: string;
  title: string;
  description: string;
  category: string;
  priority: string;
  raisedByEmployeeId?: string;
  raisedByName?: string;
  raisedByRole?: string;
}

export interface IssueProjectOption {
  id: string;
  name: string;
  projectCode: string;
}

export interface IssueFilters {
  projectId?: string;
  status?: string;
  escalationLevel?: number;
  assigneeRole?: string;
}

/**
 * Fetches available active project options for issue creation dropdown.
 * Accessible to all roles including Team Members and Team Leaders.
 */
export async function fetchIssueProjectOptionsApi(): Promise<IssueProjectOption[]> {
  const res = await apiFetch<IssueProjectOption[]>("/api/v1/issues/project-options");
  return res || [];
}

/**
 * Creates a new project issue in PostgreSQL.
 * Routes directly to Dotted-Line Reporting Manager (PM) with 2-day SLA auto-escalation.
 */
export async function createIssueApi(input: CreateIssueInput): Promise<ProjectIssueApiItem> {
  return await apiFetch<ProjectIssueApiItem>("/api/v1/issues", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(input),
  });
}

/**
 * Fetches all project issues with optional filters.
 */
export async function fetchIssuesApi(filters?: IssueFilters): Promise<ProjectIssueApiItem[]> {
  const params = new URLSearchParams();
  if (filters?.projectId) params.set("projectId", filters.projectId);
  if (filters?.status) params.set("status", filters.status);
  if (filters?.escalationLevel) params.set("escalationLevel", String(filters.escalationLevel));
  if (filters?.assigneeRole) params.set("assigneeRole", filters.assigneeRole);

  const query = params.toString();
  const res = await apiFetch<ProjectIssueApiItem[]>(`/api/v1/issues${query ? `?${query}` : ""}`);
  return res || [];
}

/**
 * Fetches issues specifically for a given project.
 */
export async function fetchProjectIssuesApi(projectId: string): Promise<ProjectIssueApiItem[]> {
  const res = await apiFetch<ProjectIssueApiItem[]>(`/api/v1/projects/${projectId}/issues`);
  return res || [];
}

/**
 * Updates status of an issue (e.g. Open → In Progress → Resolved → Closed).
 */
export async function updateIssueStatusApi(
  id: string,
  status: string,
  resolutionNotes?: string,
  actorName?: string,
): Promise<ProjectIssueApiItem> {
  return await apiFetch<ProjectIssueApiItem>(`/api/v1/issues/${id}/status`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status, resolutionNotes, actorName }),
  });
}

/**
 * Manually escalates an issue to the next level before the 2-day SLA window.
 */
export async function escalateIssueManuallyApi(
  id: string,
  actorName: string,
  notes?: string,
): Promise<ProjectIssueApiItem> {
  const params = new URLSearchParams({ actorName });
  if (notes) params.set("notes", notes);
  return await apiFetch<ProjectIssueApiItem>(`/api/v1/issues/${id}/escalate?${params.toString()}`, {
    method: "POST",
  });
}
