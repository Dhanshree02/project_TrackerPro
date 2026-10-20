import { apiFetch } from "@/lib/api-client";

export type InterviewResult = "Pending" | "Selected" | "Rejected" | "Postponed";

export interface ProjectInterview {
  id: string;
  projectId: string;
  employeeId: string;
  resourceName: string;
  interviewDate: string;
  interviewTime: string;
  result: InterviewResult;
  comments?: string | null;
  createdAtUtc: string;
  updatedAtUtc?: string | null;
}

export async function fetchProjectInterviews(projectId: string): Promise<ProjectInterview[]> {
  const res = await apiFetch<ProjectInterview[]>(`/api/v1/projects/${projectId}/interviews`);
  return res ?? [];
}

export async function createProjectInterview(
  projectId: string,
  payload: { employeeId: string; interviewDate: string; interviewTime: string },
): Promise<ProjectInterview> {
  return apiFetch<ProjectInterview>(`/api/v1/projects/${projectId}/interviews`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function updateProjectInterview(
  projectId: string,
  interviewId: string,
  payload: {
    result?: InterviewResult;
    comments?: string | null;
    interviewDate?: string;
    interviewTime?: string;
  },
): Promise<ProjectInterview> {
  return apiFetch<ProjectInterview>(`/api/v1/projects/${projectId}/interviews/${interviewId}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}
