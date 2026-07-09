// ─── My Org — Types ──────────────────────────────────────────────────────────

export type AccentColor = "blue" | "purple" | "green" | "amber";

export interface OrgCategory {
  id: string;
  name: string;
  description: string;
  /** Key into the icon lookup map in CategoryCard */
  iconName: string;
  accentColor: AccentColor;
}

export interface OrgDocument {
  id: string;
  name: string;
  categoryId: string;
  /** File size in bytes */
  size: number;
  /** File extension, e.g. "pdf", "docx" */
  fileType: string;
  /** ISO date string YYYY-MM-DD */
  lastUpdated: string;
  uploadedBy: string;
}
