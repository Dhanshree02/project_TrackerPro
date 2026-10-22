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
