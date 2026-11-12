import { apiFetch } from "@/lib/api-client";

export interface ProjectFeedbackDto {
  id: string;
  projectId: string;
  projectName?: string;
  employeeId: string;
  employeeName: string;
  employeeCode?: string;
  reportingManagerId?: string;
  reportingManagerName?: string;
  submittedByEmployeeId?: string;
  submittedByName: string;
  feedbackType: "DirectFeedback" | "FeedbackRequest";
  strengths?: string;
  areasOfImprovement?: string;
  comments?: string;
  rating?: number;
  requestNote?: string;
  status: string;
  commentsJson?: string;
  historyJson?: string;
  createdAtUtc: string;
}

export interface CreateProjectFeedbackPayload {
  employeeId: string;
  strengths?: string;
  areasOfImprovement?: string;
  comments?: string;
  rating?: number;
  feedbackType?: "DirectFeedback" | "FeedbackRequest";
  requestNote?: string;
}

export interface FeedbackApprovalActionPayload {
  status: string;
  comment?: string;
}

export async function createProjectFeedback(
  projectId: string,
  payload: CreateProjectFeedbackPayload,
): Promise<ProjectFeedbackDto> {
  const res = await apiFetch<ProjectFeedbackDto>(
    `/api/v1/projects/${encodeURIComponent(projectId)}/feedbacks`,
    {
      method: "POST",
      body: JSON.stringify(payload),
    },
  );
  if (!res) throw new Error("Failed to submit feedback");
  return res;
}

export async function fetchProjectFeedbacks(
  projectId: string,
  employeeId?: string,
): Promise<ProjectFeedbackDto[]> {
  const query = employeeId ? `?employeeId=${encodeURIComponent(employeeId)}` : "";
  const res = await apiFetch<ProjectFeedbackDto[]>(
    `/api/v1/projects/${encodeURIComponent(projectId)}/feedbacks${query}`,
  );
  return res ?? [];
}

export async function fetchPendingFeedbackApprovals(): Promise<ProjectFeedbackDto[]> {
  const res = await apiFetch<ProjectFeedbackDto[]>(
    `/api/v1/action-centre/feedback-approvals`,
  );
  return res ?? [];
}

export async function takeFeedbackApprovalAction(
  id: string,
  payload: FeedbackApprovalActionPayload,
): Promise<ProjectFeedbackDto> {
  const res = await apiFetch<ProjectFeedbackDto>(
    `/api/v1/action-centre/feedback-approvals/${encodeURIComponent(id)}/action`,
    {
      method: "POST",
      body: JSON.stringify(payload),
    },
  );
  if (!res) throw new Error("Failed to update feedback approval status");
  return res;
}
