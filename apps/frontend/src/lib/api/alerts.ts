import { apiFetch } from "@/lib/api-client";

export interface AlertAuditItem {
  action: string;
  details?: string;
  timestampUtc: string;
  actorName?: string;
}

export interface AlertApiItem {
  id: string;
  alertCode: string;
  title: string;
  description: string;
  category: "DeliveryTatBreach" | "EscalationTatBreach" | "ChangeManagementTatBreach" | "DailyOnBenchCount" | "TimesheetTatBreach" | string;
  severity: "Critical" | "High" | "Medium" | "Low";
  status: "Open" | "Acknowledged" | "InProgress" | "Resolved" | "Closed";
  projectId?: string | null;
  projectName?: string | null;
  clientId?: string | null;
  clientName?: string | null;
  sourceEntity: string;
  sourceEntityId?: string | null;
  triggerCondition: string;
  ownerEmployeeId?: string | null;
  ownerName?: string | null;
  resolutionDetails?: string | null;
  acknowledgedAtUtc?: string | null;
  acknowledgedByName?: string | null;
  resolvedAtUtc?: string | null;
  resolvedByName?: string | null;
  auditHistory: AlertAuditItem[];
  createdAtUtc: string;
}

export interface AlertMetricsApi {
  total: number;
  open: number;
  critical: number;
  resolved: number;
  escalated: number;
}

export interface AlertQueryParams {
  search?: string;
  category?: string;
  severity?: string;
  status?: string;
  projectId?: string;
  page?: number;
  perPage?: number;
}

export interface PagedAlertsResponse {
  items: AlertApiItem[];
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
}

export interface BenchEmployeeItem {
  id: string;
  employeeCode: string;
  name: string;
  department: string;
  designation: string;
  role: string;
  reportingManagerName?: string | null;
}

export interface BenchResourceSnapshotApi {
  id: string;
  snapshotDate: string;
  timeSlot: string;
  totalBenchCount: number;
  billableCount: number;
  nonBillableCount: number;
  departmentBreakdown: Record<string, number>;
  employeeList: BenchEmployeeItem[];
  createdAtUtc: string;
}

/**
 * Fetch paginated alerts with filters
 */
export async function fetchAlertsApi(params?: AlertQueryParams): Promise<PagedAlertsResponse> {
  const query = new URLSearchParams();
  if (params?.search) query.set("search", params.search);
  if (params?.category) query.set("category", params.category);
  if (params?.severity) query.set("severity", params.severity);
  if (params?.status) query.set("status", params.status);
  if (params?.projectId) query.set("projectId", params.projectId);
  if (params?.page) query.set("page", params.page.toString());
  if (params?.perPage) query.set("perPage", params.perPage.toString());

  const qs = query.toString();
  const url = `/api/v1/alerts${qs ? `?${qs}` : ""}`;
  return await apiFetch<PagedAlertsResponse>(url);
}

/**
 * Fetch alert metrics summary (total, open, critical, resolved, escalated)
 */
export async function fetchAlertMetricsApi(): Promise<AlertMetricsApi> {
  return await apiFetch<AlertMetricsApi>("/api/v1/alerts/metrics");
}

/**
 * Acknowledge an active alert
 */
export async function acknowledgeAlertApi(id: string, notes?: string): Promise<AlertApiItem> {
  return await apiFetch<AlertApiItem>(`/api/v1/alerts/${id}/acknowledge`, {
    method: "POST",
    body: JSON.stringify({ notes }),
  });
}

/**
 * Resolve an active alert with resolution details
 */
export async function resolveAlertApi(id: string, resolutionDetails: string): Promise<AlertApiItem> {
  return await apiFetch<AlertApiItem>(`/api/v1/alerts/${id}/resolve`, {
    method: "POST",
    body: JSON.stringify({ resolutionDetails }),
  });
}

/**
 * Trigger an on-demand full evaluation scan across all 5 BRD categories
 */
export async function triggerAlertScanApi(): Promise<{ scannedCount: number; message: string }> {
  return await apiFetch<{ scannedCount: number; message: string }>("/api/v1/alerts/scan", {
    method: "POST",
  });
}

/**
 * Fetch historical bench resource snapshots (10:30 AM, 2:30 PM, 6:30 PM IST)
 */
export async function fetchBenchSnapshotsApi(date?: string): Promise<BenchResourceSnapshotApi[]> {
  const qs = date ? `?date=${encodeURIComponent(date)}` : "";
  return await apiFetch<BenchResourceSnapshotApi[]>(`/api/v1/alerts/bench-snapshots${qs}`);
}
