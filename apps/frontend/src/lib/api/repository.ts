import { apiFetch, API_BASE } from "../api-client";

export interface RepositoryItem {
  id: string;
  fileName: string;
  category: "Tech" | "PMS" | "IMP" | string;
  size: number;
  lastUpdated: string;
  uploadedBy: string;
  filePath: string;
  createdAtUtc: string;
}

export interface RepositoryActivityLog {
  id: string;
  action: "Uploaded" | "Deleted" | "Downloaded" | string;
  documentId?: string | null;
  fileName: string;
  category: string;
  performedBy: string;
  details?: string | null;
  createdAtUtc: string;
}

export interface RepositoryCategoryCount {
  id: string;
  name: string;
  description: string;
  documentCount: number;
}

export interface PagedRepositoryResult {
  items: RepositoryItem[];
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
}

export async function fetchRepositoryDocuments(params: {
  page?: number;
  perPage?: number;
  category?: string | null;
  search?: string | null;
}): Promise<PagedRepositoryResult> {
  const query = new URLSearchParams();
  if (params.page) query.set("page", params.page.toString());
  if (params.perPage) query.set("perPage", params.perPage.toString());
  if (params.category && params.category !== "all") query.set("category", params.category);
  if (params.search?.trim()) query.set("search", params.search.trim());

  const qs = query.toString();
  return apiFetch<PagedRepositoryResult>(`/api/v1/repository${qs ? `?${qs}` : ""}`);
}

export async function uploadRepositoryDocument(
  file: File,
  category: string,
  uploadedBy?: string,
): Promise<RepositoryItem> {
  const ext = file.name.split(".").pop()?.toLowerCase();
  if (ext !== "pdf" && ext !== "docx") {
    throw new Error("Only .pdf and .docx file formats are allowed. Rejecting other file types.");
  }

  const formData = new FormData();
  formData.append("file", file);
  formData.append("category", category);
  if (uploadedBy) formData.append("uploadedBy", uploadedBy);

  return apiFetch<RepositoryItem>("/api/v1/repository/upload", {
    method: "POST",
    body: formData,
  });
}

export function getRepositoryDownloadUrl(id: string): string {
  return `${API_BASE}/api/v1/repository/${id}/download`;
}

export async function deleteRepositoryDocument(id: string, deletedBy?: string): Promise<boolean> {
  const query = deletedBy ? `?deletedBy=${encodeURIComponent(deletedBy)}` : "";
  return apiFetch<boolean>(`/api/v1/repository/${id}${query}`, {
    method: "DELETE",
  });
}

export async function recordRepositoryDocumentView(id: string, viewer?: string): Promise<boolean> {
  const query = viewer ? `?viewer=${encodeURIComponent(viewer)}` : "";
  return apiFetch<boolean>(`/api/v1/repository/${id}/view${query}`, {
    method: "POST",
  });
}

export interface DocumentAccessEntry {
  logId: string;
  employeeName: string;
  action: "Downloaded" | "Viewed" | "Uploaded" | string;
  accessedAtUtc: string;
  details?: string | null;
}

export interface DocumentAccessSummary {
  documentId: string;
  fileName: string;
  category: string;
  size: number;
  lastUpdated: string;
  uploadedBy: string;
  totalDownloads: number;
  uniqueEmployeeCount: number;
  accessors: DocumentAccessEntry[];
}

export async function fetchRepositoryAccessSummaries(params?: {
  category?: string | null;
  search?: string | null;
}): Promise<DocumentAccessSummary[]> {
  const query = new URLSearchParams();
  if (params?.category && params.category !== "all") query.set("category", params.category);
  if (params?.search?.trim()) query.set("search", params.search.trim());

  const qs = query.toString();
  return apiFetch<DocumentAccessSummary[]>(`/api/v1/repository/access-summaries${qs ? `?${qs}` : ""}`);
}

export async function fetchRepositoryActivityLogs(limit = 100): Promise<RepositoryActivityLog[]> {
  return apiFetch<RepositoryActivityLog[]>(`/api/v1/repository/logs?limit=${limit}`);
}

export async function fetchRepositoryCategoryCounts(): Promise<RepositoryCategoryCount[]> {
  return apiFetch<RepositoryCategoryCount[]>("/api/v1/repository/categories");
}
