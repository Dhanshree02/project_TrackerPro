export interface ServiceProgressItem {
  serviceId?: string;
  serviceName?: string;
  progress: number;
  isDeleted?: boolean;
  changeStatus?: string | null;
  deletedAtUtc?: string | null;
  status?: string | null;
}

/**
 * Checks whether a service is active (not deleted and not inactive).
 */
export function isActiveService(service: {
  isDeleted?: boolean;
  changeStatus?: string | null;
  deletedAtUtc?: string | null;
  status?: string | null;
}): boolean {
  if (service.isDeleted) return false;
  if (service.changeStatus && service.changeStatus.toLowerCase() === "deleted") return false;
  if (service.deletedAtUtc) return false;
  if (service.status && service.status.toLowerCase() === "inactive") return false;
  return true;
}

/**
 * Calculates individual service progress percentage based on task completion weights.
 * - Completed: weight 1.0
 * - Ongoing: weight 0.5
 * - Cancelled: excluded from total count and sum
 * - Other stages (Not Started, Stopped, etc.): weight 0.0
 * - Returns 0 if there are no non-cancelled tasks.
 * - Result is rounded to nearest whole percentage (0-100).
 */
export function calculateServiceProgressFromTasks(
  tasks: Array<{ stage: string }>
): {
  progress: number;
  totalTasks: number;
  completedTasks: number;
  ongoingTasks: number;
} {
  const nonCancelled = tasks.filter((t) => t.stage !== "Cancelled");
  const totalTasks = nonCancelled.length;
  if (totalTasks === 0) {
    return { progress: 0, totalTasks: 0, completedTasks: 0, ongoingTasks: 0 };
  }

  let completedTasks = 0;
  let ongoingTasks = 0;
  const sumWeights = nonCancelled.reduce((sum, t) => {
    if (t.stage === "Completed") {
      completedTasks += 1;
      return sum + 1;
    }
    if (t.stage === "Ongoing") {
      ongoingTasks += 1;
      return sum + 0.5;
    }
    return sum;
  }, 0);

  const progress = Math.round((sumWeights / totalTasks) * 100);
  return { progress, totalTasks, completedTasks, ongoingTasks };
}

/**
 * Computes overall project progress percentage as the arithmetic average of
 * active service progress percentages.
 *
 * Formula:
 * Overall Project Progress = Sum of All Active Service Progress Percentages / Total Number of Active Services
 *
 * Rules:
 * - Every active service carries equal weight (1 service = 1 unit of weight).
 * - Excludes inactive or deleted services from both numerator and denominator.
 * - Active services with 0% progress MUST be included in the denominator and numerator (+0).
 * - If no active services exist, returns 0.
 * - Result is rounded to the nearest whole integer using Math.round.
 */
export function computeOverallProjectProgress(
  services: ServiceProgressItem[]
): number {
  const activeServices = services.filter(isActiveService);
  if (activeServices.length === 0) return 0;

  const totalProgressSum = activeServices.reduce((acc, s) => {
    const val = Number.isFinite(s.progress) ? s.progress : 0;
    return acc + Math.max(0, Math.min(100, val));
  }, 0);

  return Math.round(totalProgressSum / activeServices.length);
}
