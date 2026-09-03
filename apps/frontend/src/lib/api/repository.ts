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
  departments?: { id: string; name: string }[];
}

export interface RepositoryDepartmentOption {
  id: string;
  code: string;
  name: string;
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

export const ALLOWED_REPOSITORY_EXTENSIONS = [
  "pdf",
  "doc",
  "docx",
  "docm",
  "xls",
  "xlsx",
  "xlsm",
  "xlsb",
  "csv",
  "ppt",
  "pptx",
  "pptm",
  "txt",
  "png",
  "jpg",
  "jpeg",
] as const;

export function isAllowedRepositoryFile(fileName: string): boolean {
  const ext = fileName.split(".").pop()?.toLowerCase();
  return ext ? (ALLOWED_REPOSITORY_EXTENSIONS as readonly string[]).includes(ext) : false;
}

export async function uploadRepositoryDocument(
  file: File,
  category: string,
  uploadedBy?: string,
  departmentIds?: string[],
): Promise<RepositoryItem> {
  if (!isAllowedRepositoryFile(file.name)) {
    throw new Error(
      "Allowed file formats: PDF (.pdf), Word (.doc, .docx), Excel (.xls, .xlsx, .xlsm, .csv), and PowerPoint (.ppt, .pptx).",
    );
  }

  if (!departmentIds?.length) {
    throw new Error("Select at least one department that may view this document.");
  }

  const formData = new FormData();
  formData.append("file", file);
  formData.append("category", category);
  if (uploadedBy) formData.append("uploadedBy", uploadedBy);
  for (const id of departmentIds) {
    formData.append("departmentIds", id);
  }

  return apiFetch<RepositoryItem>("/api/v1/repository/upload", {
    method: "POST",
    body: formData,
  });
}

export async function fetchRepositoryDepartments(): Promise<RepositoryDepartmentOption[]> {
  return (await apiFetch<RepositoryDepartmentOption[]>("/api/v1/repository/departments")) ?? [];
}

export function getRepositoryDownloadUrl(id: string): string {
  return `${API_BASE}/api/v1/repository/${id}/download`;
}

export function getRepositoryPreviewUrl(id: string): string {
  return `${API_BASE}/api/v1/repository/${id}/preview`;
}

export async function fetchDocumentLogs(id: string): Promise<RepositoryActivityLog[]> {
  return apiFetch<RepositoryActivityLog[]>(`/api/v1/repository/${id}/logs`);
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
