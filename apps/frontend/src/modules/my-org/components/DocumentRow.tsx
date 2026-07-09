import { FileText } from "lucide-react";
import type { OrgCategory, OrgDocument } from "../types";
import { formatFileSize, formatLastUpdated } from "../utils";

// ── File-type colour map ──────────────────────────────────────────────────────
const FILE_TYPE_COLORS: Record<string, string> = {
  pdf: "text-red-500",
  docx: "text-blue-500",
  doc: "text-blue-500",
  xlsx: "text-emerald-600",
  xls: "text-emerald-600",
  pptx: "text-orange-500",
  ppt: "text-orange-500",
  txt: "text-muted-foreground",
  csv: "text-teal-600",
};

interface DocumentRowProps {
  document: OrgDocument;
  categories: OrgCategory[];
}

export function DocumentRow({ document, categories }: DocumentRowProps) {
  const category = categories.find((c) => c.id === document.categoryId);
  const iconColor =
    FILE_TYPE_COLORS[document.fileType.toLowerCase()] ?? "text-muted-foreground";

  return (
    <tr className="border-b border-border transition-colors last:border-0 hover:bg-accent/20">
      {/* File Name */}
      <td className="px-4 py-3">
        <div className="flex items-center gap-2.5">
          <FileText className={`h-4 w-4 shrink-0 ${iconColor}`} />
          <span className="text-sm font-medium text-foreground">{document.name}</span>
        </div>
      </td>

      {/* Category */}
      <td className="whitespace-nowrap px-4 py-3">
        {category ? (
          <span className="inline-flex items-center rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] font-medium text-muted-foreground">
            {category.name}
          </span>
        ) : (
          <span className="text-xs text-muted-foreground">—</span>
        )}
      </td>

      {/* Size */}
      <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
        {formatFileSize(document.size)}
      </td>

      {/* Last Updated */}
      <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
        {formatLastUpdated(document.lastUpdated)}
      </td>

      {/* Uploaded By */}
      <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
        {document.uploadedBy}
      </td>
    </tr>
  );
}
