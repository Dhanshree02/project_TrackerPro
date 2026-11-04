import { apiFetch } from "@/lib/api-client";

export interface ProjectAppreciation {
  id: string;
  projectId: string;
  recipientEmployeeId: string;
  recipientName: string;
  recipientEmail?: string | null;
  recipientRole?: string | null;
  badge: string;
  message: string;
  givenByEmployeeId?: string | null;
  givenByName: string;
  createdAtUtc: string;
}

export interface CreateProjectAppreciationPayload {
  recipientEmployeeId: string;
  badge: string;
  message: string;
}

export async function fetchProjectAppreciations(projectId: string): Promise<ProjectAppreciation[]> {
  const res = await apiFetch<ProjectAppreciation[]>(`/api/v1/projects/${projectId}/appreciations`);
  return res ?? [];
}

export async function createProjectAppreciation(
  projectId: string,
  payload: CreateProjectAppreciationPayload
): Promise<ProjectAppreciation> {
  return apiFetch<ProjectAppreciation>(`/api/v1/projects/${projectId}/appreciations`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}
