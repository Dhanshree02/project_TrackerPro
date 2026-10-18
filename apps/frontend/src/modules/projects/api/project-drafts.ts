import { apiFetch } from "@/lib/api-client";
import type { PagedResult } from "./projects";

export interface ProjectDraftListDto {
  id: string;
  projectName: string;
  clientId: string | null;
  clientName: string | null;
  salesPerson: string | null;
  createdByName: string;
  updatedByName: string | null;
  status: string;
  rowVersion: number;
  createdAtUtc: string;
  updatedAtUtc: string | null;
}

export interface ProjectDraftDto extends ProjectDraftListDto {
  formSnapshotJson: string;
}

export interface CreateProjectDraftPayload {
  projectName: string;
  clientId?: string | null;
  clientName?: string | null;
  salesPerson?: string | null;
  savedByName: string;
  formSnapshotJson: string;
}

export interface UpdateProjectDraftPayload {
  projectName: string;
  clientId?: string | null;
  clientName?: string | null;
  salesPerson?: string | null;
  savedByName: string;
  formSnapshotJson: string;
  rowVersion: number;
}

export interface ProjectDraftQueryParams {
  page?: number;
  perPage?: number;
  search?: string;
}

/**
 * Fetch all shared active drafts from PostgreSQL backend.
 */
export async function fetchProjectDrafts(
  params?: ProjectDraftQueryParams,
): Promise<PagedResult<ProjectDraftListDto>> {
  const qs = new URLSearchParams();
  if (params?.page) qs.set("page", String(params.page));
  if (params?.perPage) qs.set("perPage", String(params.perPage));
  if (params?.search) qs.set("search", params.search.trim());

  const query = qs.toString() ? `?${qs.toString()}` : "";
  return apiFetch<PagedResult<ProjectDraftListDto>>(`/api/v1/project-drafts${query}`);
}

/**
 * Fetch single draft by ID including its complete form snapshot.
 */
export async function fetchProjectDraftById(id: string): Promise<ProjectDraftDto> {
  return apiFetch<ProjectDraftDto>(`/api/v1/project-drafts/${id}`);
}

/**
 * Create a new draft in the PostgreSQL database.
 */
export async function createProjectDraft(
  payload: CreateProjectDraftPayload,
): Promise<ProjectDraftDto> {
  return apiFetch<ProjectDraftDto>("/api/v1/project-drafts", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/**
 * Update an existing draft with optimistic concurrency check.
 */
export async function updateProjectDraft(
  id: string,
  payload: UpdateProjectDraftPayload,
): Promise<ProjectDraftDto> {
  return apiFetch<ProjectDraftDto>(`/api/v1/project-drafts/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

/**
 * Soft delete a draft from the database.
 */
export async function deleteProjectDraft(id: string): Promise<void> {
  await apiFetch(`/api/v1/project-drafts/${id}`, {
    method: "DELETE",
  });
}

/**
 * Mark a draft as converted after the real project/WBS is created.
 */
export async function markDraftConverted(id: string): Promise<void> {
  try {
    await apiFetch(`/api/v1/project-drafts/${id}/convert`, {
      method: "PATCH",
    });
  } catch (err) {
    console.warn("Failed to mark draft as converted:", err);
  }
}
