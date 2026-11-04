import { apiFetch } from "@/lib/api-client";

export interface ProjectAdditionalRequirement {
  id: string;
  requirementId: string;
  projectId: string;
  clientName?: string | null;
  projectName?: string | null;
  requirementType: string;
  title: string;
  description: string;
  priority: string;
  requestedByEmployeeId?: string | null;
  requestedByName: string;
  requestedDate: string;
  attachmentFileName?: string | null;
  attachmentPath?: string | null;
  scopeCancellationService?: string | null;
  status: string;
  approvedAtUtc?: string | null;
  approvedByEmployeeId?: string | null;
  approvedByName?: string | null;
  approvalComments?: string | null;
  commentsJson: string;
  historyJson: string;
  createdAtUtc: string;
}

export async function fetchProjectAdditionalRequirements(
  projectId: string
): Promise<ProjectAdditionalRequirement[]> {
  const res = await apiFetch<ProjectAdditionalRequirement[]>(
    `/api/v1/projects/${projectId}/additional-requirements`
  );
  return res ?? [];
}

export async function createProjectAdditionalRequirement(
  projectId: string,
  formData: FormData
): Promise<ProjectAdditionalRequirement> {
  return apiFetch<ProjectAdditionalRequirement>(
    `/api/v1/projects/${projectId}/additional-requirements`,
    {
      method: "POST",
      body: formData,
    }
  );
}

export async function approveProjectAdditionalRequirement(
  projectId: string,
  requirementId: string,
  comment: string
): Promise<ProjectAdditionalRequirement> {
  return apiFetch<ProjectAdditionalRequirement>(
    `/api/v1/projects/${projectId}/additional-requirements/${requirementId}/approve`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ comment }),
    }
  );
}

export async function rejectProjectAdditionalRequirement(
  projectId: string,
  requirementId: string,
  comment: string
): Promise<ProjectAdditionalRequirement> {
  return apiFetch<ProjectAdditionalRequirement>(
    `/api/v1/projects/${projectId}/additional-requirements/${requirementId}/reject`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ comment }),
    }
  );
}

export async function fetchPendingApprovals(): Promise<ProjectAdditionalRequirement[]> {
  const res = await apiFetch<ProjectAdditionalRequirement[]>(
    `/api/v1/action-centre/approvals`
  );
  return res ?? [];
}
