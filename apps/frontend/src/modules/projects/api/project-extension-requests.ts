import { apiFetch } from "@/lib/api-client";

export interface ExtensionApprover {
  employeeId: string;
  name: string;
  employeeCode?: string | null;
  subDepartment: string;
  status: string;
}

export interface ProjectExtensionRequest {
  id: string;
  projectId: string;
  currentEndDate: string;
  requestedEndDate: string;
  extensionDays: number;
  reason: string;
  status: string;
  requestedByName: string;
  createdAtUtc: string;
  approvers: ExtensionApprover[];
  projectName?: string | null;
  projectCode?: string | null;
}

export interface PendingExtensionApproval {
  id: string;
  projectId: string;
  projectName: string;
  projectCode?: string | null;
  currentEndDate: string;
  requestedEndDate: string;
  extensionDays: number;
  reason: string;
  status: string;
  requestedByEmployeeId?: string | null;
  requestedByName: string;
  createdAtUtc: string;
  approvers: ExtensionApprover[];
}

export async function fetchExtensionApprovers(): Promise<ExtensionApprover[]> {
  const res = await apiFetch<ExtensionApprover[]>("/api/v1/projects/extension-approvers");
  return res ?? [];
}

export async function fetchProjectExtensionRequests(projectId: string): Promise<ProjectExtensionRequest[]> {
  const res = await apiFetch<ProjectExtensionRequest[]>(`/api/v1/projects/${projectId}/extension-requests`);
  return res ?? [];
}

export async function createProjectExtensionRequest(
  projectId: string,
  payload: { requestedEndDate: string; reason: string; approverEmployeeIds: string[] },
): Promise<ProjectExtensionRequest> {
  return apiFetch<ProjectExtensionRequest>(`/api/v1/projects/${projectId}/extension-requests`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function fetchPendingExtensionApprovals(): Promise<PendingExtensionApproval[]> {
  const res = await apiFetch<PendingExtensionApproval[]>("/api/v1/projects/extension-requests/pending-approvals");
  return res ?? [];
}

export async function approveProjectExtensionRequest(
  projectId: string,
  extensionRequestId: string,
  comment: string,
): Promise<ProjectExtensionRequest> {
  return apiFetch<ProjectExtensionRequest>(
    `/api/v1/projects/${projectId}/extension-requests/${extensionRequestId}/approve`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ comment }),
    },
  );
}

export async function rejectProjectExtensionRequest(
  projectId: string,
  extensionRequestId: string,
  comment: string,
): Promise<ProjectExtensionRequest> {
  return apiFetch<ProjectExtensionRequest>(
    `/api/v1/projects/${projectId}/extension-requests/${extensionRequestId}/reject`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ comment }),
    },
  );
}
