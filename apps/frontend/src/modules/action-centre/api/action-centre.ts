import { apiFetch } from "@/lib/api-client";

export interface ApiBucketTask {
  id: string;
  taskId: string;
  projectId: string;
  projectServiceId?: string | null;
  assignmentId?: string | null;
  employeeId: string;
  assignedById?: string | null;
  assignedByName?: string | null;
  taskTitle: string;
  projectName: string;
  priority: string;
  dueDate?: string | null;
  status: string;
  actualStartDate?: string | null;
  actualEndDate?: string | null;
  timerRunning: boolean;
  timerStartedAtUtc?: string | null;
  timerAccumulatedSeconds: number;
  elapsedTimeSeconds: number;
  utilizedHours: number;
  createdAtUtc: string;
}

export interface PagedResult<T> {
  items: T[];
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
}

export interface BucketTaskQueryParams {
  employeeId?: string;
  search?: string;
  status?: string;
  priority?: string;
  page?: number;
  pageSize?: number;
}

export async function fetchBucketList(params: BucketTaskQueryParams = {}): Promise<PagedResult<ApiBucketTask>> {
  const query = new URLSearchParams();
  if (params.employeeId) query.set("employeeId", params.employeeId);
  if (params.search) query.set("search", params.search);
  if (params.status && params.status !== "all") query.set("status", params.status);
  if (params.priority && params.priority !== "all") query.set("priority", params.priority);
  if (params.page) query.set("page", String(params.page));
  if (params.pageSize) query.set("pageSize", String(params.pageSize));

  const qs = query.toString();
  return apiFetch<PagedResult<ApiBucketTask>>(`/api/v1/action-centre/bucket-list${qs ? `?${qs}` : ""}`);
}

export async function startBucketTaskTimer(id: string): Promise<ApiBucketTask> {
  return apiFetch<ApiBucketTask>(`/api/v1/action-centre/bucket-list/${id}/start-timer`, {
    method: "POST",
  });
}

export async function pauseBucketTaskTimer(id: string): Promise<ApiBucketTask> {
  return apiFetch<ApiBucketTask>(`/api/v1/action-centre/bucket-list/${id}/pause-timer`, {
    method: "POST",
  });
}

export async function stopBucketTaskTimer(id: string): Promise<ApiBucketTask> {
  return apiFetch<ApiBucketTask>(`/api/v1/action-centre/bucket-list/${id}/stop-timer`, {
    method: "POST",
  });
}

export async function completeBucketTask(id: string): Promise<ApiBucketTask> {
  return apiFetch<ApiBucketTask>(`/api/v1/action-centre/bucket-list/${id}/complete`, {
    method: "POST",
  });
}

export async function updateBucketTaskStatus(id: string, status: string): Promise<ApiBucketTask> {
  return apiFetch<ApiBucketTask>(`/api/v1/action-centre/bucket-list/${id}/status`, {
    method: "PATCH",
    body: JSON.stringify({ status }),
  });
}
