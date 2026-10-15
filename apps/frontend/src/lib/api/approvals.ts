import { apiFetch } from "@/lib/api-client";

export interface ApprovalAuditItem {
  action: string;
  details?: string;
  timestampUtc: string;
  actorName?: string;
}

export interface ApprovalApiItem {
  id: string;
  requestCode: string;
  approvalType: string;
  projectId?: string | null;
  projectName?: string | null;
  employeeId?: string | null;
  employeeName?: string | null;
  department?: string | null;
  title: string;
  description: string;
  requestedByEmployeeId: string;
  requestedByName: string;
  requestedByRole: string;
  assignedApproverRole?: string | null;
  assignedApproverEmployeeId?: string | null;
  assignedApproverName?: string | null;
  status: "Pending" | "Approved" | "Rejected" | "RequestChanges" | "Hold" | string;
  priority: "Critical" | "High" | "Medium" | "Low";
  payloadJson: string;
  decisionNotes?: string | null;
  decidedAtUtc?: string | null;
  decidedByName?: string | null;
  auditHistory: ApprovalAuditItem[];
  createdAtUtc: string;
}

export interface ApprovalMetricsApi {
  total: number;
  pending: number;
  approved: number;
  rejected: number;
  scopeChanges: number;
  leadershipChanges: number;
  extensions: number;
}

export interface ApprovalQueryParams {
  search?: string;
  approvalType?: string;
  status?: string;
  projectId?: string;
  department?: string;
  page?: number;
  perPage?: number;
}

export interface PagedApprovalsResponse {
  items: ApprovalApiItem[];
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
}

export interface CreateApprovalPayload {
  approvalType: string;
  projectId?: string | null;
  projectName?: string | null;
  employeeId?: string | null;
  employeeName?: string | null;
  department?: string | null;
  title: string;
  description: string;
  requestedByEmployeeId: string;
  requestedByName: string;
  requestedByRole: string;
  assignedApproverRole?: string | null;
  assignedApproverEmployeeId?: string | null;
  assignedApproverName?: string | null;
  priority?: string;
  payloadJson?: string;
}

export async function fetchApprovals(params: ApprovalQueryParams = {}): Promise<PagedApprovalsResponse> {
  const q = new URLSearchParams();
  if (params.search) q.set("search", params.search);
  if (params.approvalType && params.approvalType !== "all") q.set("approvalType", params.approvalType);
  if (params.status && params.status !== "all") q.set("status", params.status);
  if (params.projectId && params.projectId !== "all") q.set("projectId", params.projectId);
  if (params.department && params.department !== "all") q.set("department", params.department);
  if (params.page) q.set("page", String(params.page));
  if (params.perPage) q.set("pageSize", String(params.perPage));

  const qs = q.toString();
  const url = `/api/v1/approvals${qs ? `?${qs}` : ""}`;
  return apiFetch<PagedApprovalsResponse>(url);
}

export async function fetchApprovalMetrics(): Promise<ApprovalMetricsApi> {
  return apiFetch<ApprovalMetricsApi>("/api/v1/approvals/metrics");
}

export async function fetchApprovalById(id: string): Promise<ApprovalApiItem> {
  return apiFetch<ApprovalApiItem>(`/api/v1/approvals/${id}`);
}

export async function createApprovalRequest(payload: CreateApprovalPayload): Promise<ApprovalApiItem> {
  return apiFetch<ApprovalApiItem>("/api/v1/approvals", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export async function submitApprovalAction(
  id: string,
  action: "Approve" | "Reject" | "RequestChanges" | "Hold",
  decisionNotes: string,
): Promise<ApprovalApiItem> {
  return apiFetch<ApprovalApiItem>(`/api/v1/approvals/${id}/action`, {
    method: "POST",
    body: JSON.stringify({ action, decisionNotes }),
  });
}
