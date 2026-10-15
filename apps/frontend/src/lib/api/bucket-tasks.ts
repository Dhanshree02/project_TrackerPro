import { apiFetch } from "@/lib/api-client";

export interface BucketTaskApiItem {
  assignmentId: string;
  taskId: string;
  taskTitle: string;
  projectId: string;
  projectName: string;
  projectCode?: string | null;
  priority: "low" | "medium" | "high" | "critical";
  dueDate?: string | null;
  isOverdue: boolean;
  status: "Not Started" | "Ongoing" | "Paused" | "Stopped" | "Completed";
  employeeId: string;
  employeeName: string;
  assignedByName?: string | null;
  startedAtUtc?: string | null;
  completedAtUtc?: string | null;
  elapsedSeconds: number;
  isTimerRunning: boolean;
  timerStartedAtUtc?: string | null;
  estimatedHours: number;
  utilizedHours: number;
  remainingHours: number;
}

export interface BucketTaskFilters {
  search?: string;
  status?: string;
  priority?: string;
  projectId?: string;
  employeeId?: string;
  overdueOnly?: boolean;
  page?: number;
  perPage?: number;
}

export interface PagedBucketTasks {
  items: BucketTaskApiItem[];
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
}

export interface TimerActionResponse {
  assignmentId: string;
  taskId: string;
  employeeId: string;
  status: string;
  isTimerRunning: boolean;
  timerStartedAtUtc?: string | null;
  totalAccumulatedSeconds: number;
  utilizedHours: number;
  message: string;
}

/**
 * Fetches assigned bucket list tasks for the current employee (or specified employee).
 */
export async function fetchBucketTasks(filters: BucketTaskFilters = {}): Promise<PagedBucketTasks> {
  const params = new URLSearchParams();
  if (filters.search) params.set("search", filters.search);
  if (filters.status && filters.status !== "all") params.set("status", filters.status);
  if (filters.priority && filters.priority !== "all") params.set("priority", filters.priority);
  if (filters.projectId) params.set("projectId", filters.projectId);
  if (filters.employeeId) params.set("employeeId", filters.employeeId);
  if (filters.overdueOnly !== undefined) params.set("overdueOnly", String(filters.overdueOnly));
  if (filters.page) params.set("page", String(filters.page));
  if (filters.perPage) params.set("perPage", String(filters.perPage));

  const qs = params.toString() ? `?${params.toString()}` : "";
  const res = await apiFetch<PagedBucketTasks>(`/api/v1/action-centre/bucket-tasks${qs}`);
  return res ?? { items: [], total: 0, page: 1, perPage: 50, totalPages: 0 };
}

/**
 * Starts the live timer for an assigned task.
 */
export async function startBucketTimer(assignmentId: string): Promise<TimerActionResponse | null> {
  return await apiFetch<TimerActionResponse>(`/api/v1/action-centre/bucket-tasks/${assignmentId}/start`, {
    method: "POST",
  });
}

/**
 * Pauses the live timer for an assigned task.
 */
export async function pauseBucketTimer(assignmentId: string): Promise<TimerActionResponse | null> {
  return await apiFetch<TimerActionResponse>(`/api/v1/action-centre/bucket-tasks/${assignmentId}/pause`, {
    method: "POST",
  });
}

/**
 * Resumes the live timer for an assigned task.
 */
export async function resumeBucketTimer(assignmentId: string): Promise<TimerActionResponse | null> {
  return await apiFetch<TimerActionResponse>(`/api/v1/action-centre/bucket-tasks/${assignmentId}/resume`, {
    method: "POST",
  });
}

/**
 * Completes the task assignment and synchronizes with Projects module.
 */
export async function completeBucketTask(assignmentId: string): Promise<TimerActionResponse | null> {
  return await apiFetch<TimerActionResponse>(`/api/v1/action-centre/bucket-tasks/${assignmentId}/complete`, {
    method: "POST",
  });
}
