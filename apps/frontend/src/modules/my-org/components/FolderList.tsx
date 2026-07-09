import type { OrgCategory, OrgDocument } from "../types";
import { getDocumentCountByCategory } from "../utils";
import { FolderItem } from "./FolderItem";

interface FolderListProps {
  categories: OrgCategory[];
  /** All documents — used to compute per-folder counts (unaffected by active filter). */
  documents: OrgDocument[];
  activeCategoryId: string | null;
  onSelectCategory: (id: string | null) => void;
}

export function FolderList({
  categories,
  documents,
  activeCategoryId,
  onSelectCategory,
}: FolderListProps) {
  return (
    <div className="flex flex-col gap-0.5">
      {/* "All" pseudo-folder */}
      <FolderItem
        label="All Documents"
        count={documents.length}
        isActive={activeCategoryId === null}
        onClick={() => onSelectCategory(null)}
      />

      {categories.map((cat) => (
        <FolderItem
          key={cat.id}
          label={cat.name}
          count={getDocumentCountByCategory(documents, cat.id)}
          isActive={activeCategoryId === cat.id}
          onClick={() => onSelectCategory(cat.id)}
        />
      ))}
    </div>
  );
}
