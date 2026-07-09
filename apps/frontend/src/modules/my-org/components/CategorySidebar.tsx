import type { OrgCategory, OrgDocument } from "../types";
import { SidebarSearch } from "./SidebarSearch";
import { FolderList } from "./FolderList";

interface CategorySidebarProps {
  categories: OrgCategory[];
  /** Full (unfiltered) document list — drives folder counts. */
  documents: OrgDocument[];
  activeCategoryId: string | null;
  searchQuery: string;
  onSearchChange: (v: string) => void;
  onSelectCategory: (id: string | null) => void;
}

export function CategorySidebar({
  categories,
  documents,
  activeCategoryId,
  searchQuery,
  onSearchChange,
  onSelectCategory,
}: CategorySidebarProps) {
  return (
    <aside className="w-52 shrink-0">
      <div className="rounded-xl border border-border bg-card p-3">
        <p className="mb-2.5 text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
          Folders
        </p>
        <SidebarSearch value={searchQuery} onChange={onSearchChange} />
        <div className="mt-2.5">
          <FolderList
            categories={categories}
            documents={documents}
            activeCategoryId={activeCategoryId}
            onSelectCategory={onSelectCategory}
          />
        </div>
      </div>
    </aside>
  );
}
