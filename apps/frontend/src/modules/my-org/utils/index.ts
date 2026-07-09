// ─── My Org Utilities ─────────────────────────────────────────────────────────

import type { OrgDocument } from "@/modules/my-org/types";

/** Format raw bytes into a human-readable string: "2.4 MB", "512 KB" etc. */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"] as const;
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
}

/** Format an ISO date string (YYYY-MM-DD) into "10 Jun 2026" */
export function formatLastUpdated(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

/**
 * Filter documents by active category and/or search query.
 * Matches on: document name, uploaded-by name, file type.
 */
export function filterDocuments(
  documents: OrgDocument[],
  categoryId: string | null,
  searchQuery: string,
): OrgDocument[] {
  const q = searchQuery.trim().toLowerCase();
  return documents.filter((doc) => {
    const matchesCategory = !categoryId || doc.categoryId === categoryId;
    const matchesSearch =
      !q ||
      doc.name.toLowerCase().includes(q) ||
      doc.uploadedBy.toLowerCase().includes(q) ||
      doc.fileType.toLowerCase().includes(q);
    return matchesCategory && matchesSearch;
  });
}

/** Count how many documents belong to a specific category. */
export function getDocumentCountByCategory(
  documents: OrgDocument[],
  categoryId: string,
): number {
  return documents.filter((doc) => doc.categoryId === categoryId).length;
}

/** Generate a unique document ID for newly uploaded files. */
export function generateDocumentId(): string {
  return `doc-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
}

/** Return today's date as an ISO YYYY-MM-DD string. */
export function getTodayISO(): string {
  return new Date().toISOString().slice(0, 10);
}

/** Extract file extension from a filename (lower-cased). */
export function getFileExtension(filename: string): string {
  return filename.split(".").pop()?.toLowerCase() ?? "unknown";
}
