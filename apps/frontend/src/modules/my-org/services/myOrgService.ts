// ─── My Org Service ───────────────────────────────────────────────────────────
// Currently returns dummy data. When APIs are ready, only this file changes.
// UI components must NOT be modified when switching to real API responses.

import { seedCategories } from "@/dummy-data/my-org/categories";
import { seedDocuments } from "@/dummy-data/my-org/documents";
import type { OrgCategory, OrgDocument } from "@/modules/my-org/types";

export const myOrgService = {
  /**
   * Returns all org categories.
   * Future: replace body with `await api.get("/my-org/categories")`
   */
  getCategories(): OrgCategory[] {
    return [...seedCategories];
  },

  /**
   * Returns all org documents.
   * Future: replace body with `await api.get("/my-org/documents")`
   */
  getDocuments(): OrgDocument[] {
    return [...seedDocuments];
  },
};
