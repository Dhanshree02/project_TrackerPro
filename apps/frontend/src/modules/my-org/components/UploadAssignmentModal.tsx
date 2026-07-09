import { useState } from "react";
import { X, FileText } from "lucide-react";
import type { OrgCategory } from "../types";
import { CategoryCard } from "./CategoryCard";
import { formatFileSize } from "../utils";

interface UploadAssignmentModalProps {
  file: File;
  categories: OrgCategory[];
  onAssign: (categoryId: string) => void;
  onCancel: () => void;
}

export function UploadAssignmentModal({
  file,
  categories,
  onAssign,
  onCancel,
}: UploadAssignmentModalProps) {
  const [selectedCategoryId, setSelectedCategoryId] = useState<string | null>(null);

  const handleSubmit = () => {
    if (!selectedCategoryId) return;
    onAssign(selectedCategoryId);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/40 backdrop-blur-[1px]"
        onClick={onCancel}
      />

      {/* Modal */}
      <div
        className="relative w-full max-w-lg rounded-xl border border-border bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-start justify-between border-b border-border pb-4">
          <div>
            <h2 className="text-base font-semibold text-foreground">
              Assign Document to Category
            </h2>
            <p className="mt-0.5 text-xs text-muted-foreground">
              Select a category for this file before uploading.
            </p>
          </div>
          <button
            onClick={onCancel}
            className="ml-4 shrink-0 rounded-md p-1 text-muted-foreground transition-colors hover:bg-accent"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* File info */}
        <div className="my-4 flex items-center gap-3 rounded-lg border border-border bg-muted/30 p-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-border bg-card">
            <FileText className="h-4 w-4 text-muted-foreground" />
          </div>
          <div className="min-w-0">
            <p className="truncate text-sm font-medium text-foreground">{file.name}</p>
            <p className="text-[11px] text-muted-foreground">{formatFileSize(file.size)}</p>
          </div>
        </div>

        {/* Category selection */}
        <div className="grid grid-cols-2 gap-3">
          {categories.map((cat) => (
            <CategoryCard
              key={cat.id}
              category={cat}
              docCount={0}
              isActive={selectedCategoryId === cat.id}
              onClick={() =>
                setSelectedCategoryId((prev) =>
                  prev === cat.id ? null : cat.id,
                )
              }
              hideCount
            />
          ))}
        </div>

        {/* Actions */}
        <div className="mt-5 flex items-center justify-end gap-2 border-t border-border pt-4">
          <button
            type="button"
            onClick={onCancel}
            className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={handleSubmit}
            disabled={!selectedCategoryId}
            className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground shadow-sm transition-all hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-40"
          >
            Upload Document
          </button>
        </div>
      </div>
    </div>
  );
}
