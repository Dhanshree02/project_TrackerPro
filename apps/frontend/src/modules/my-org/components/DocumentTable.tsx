import type { OrgCategory, OrgDocument } from "../types";
import { DocumentRow } from "./DocumentRow";
import { PaginationFooter } from "./PaginationFooter";

export const PAGE_SIZE = 10;

const COL_HEADERS = [
  "File Name",
  "Category",
  "Size",
  "Last Updated",
  "Uploaded By",
];

interface DocumentTableProps {
  /** Already-paginated slice of filtered documents. */
  documents: OrgDocument[];
  categories: OrgCategory[];
  /** Total number of filtered documents (before pagination). */
  totalCount: number;
  page: number;
  totalPages: number;
  onPageChange: (p: number) => void;
}

export function DocumentTable({
  documents,
  categories,
  totalCount,
  page,
  totalPages,
  onPageChange,
}: DocumentTableProps) {
  return (
    <div className="flex-1 overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
      <table className="w-full text-sm">
        <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
          <tr>
            {COL_HEADERS.map((h) => (
              <th key={h} className="whitespace-nowrap px-4 py-3 font-medium">
                {h}
              </th>
            ))}
          </tr>
        </thead>

        <tbody className="divide-y divide-border">
          {documents.length === 0 ? (
            <tr>
              <td
                colSpan={COL_HEADERS.length}
                className="px-4 py-12 text-center text-sm text-muted-foreground"
              >
                No documents found.
              </td>
            </tr>
          ) : (
            documents.map((doc) => (
              <DocumentRow key={doc.id} document={doc} categories={categories} />
            ))
          )}
        </tbody>
      </table>

      <PaginationFooter
        page={page}
        totalPages={totalPages}
        totalCount={totalCount}
        pageSize={PAGE_SIZE}
        onPageChange={onPageChange}
      />
    </div>
  );
}
