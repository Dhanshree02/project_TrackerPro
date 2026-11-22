import { ChevronLeft, ChevronRight } from "lucide-react";
import { RowsPerPageSelect } from "@/components/rows-per-page-select";
import { paginationRange, totalPageCount } from "@/lib/pagination";

export interface TablePaginationFooterProps {
  page: number;
  pageSize: number;
  total: number;
  itemLabel?: string;
  onPageChange: (p: number | ((prev: number) => number)) => void;
  onPageSizeChange: (size: number) => void;
  className?: string;
}

export function TablePaginationFooter({
  page,
  pageSize,
  total,
  itemLabel = "items",
  onPageChange,
  onPageSizeChange,
  className,
}: TablePaginationFooterProps) {
  const totalPages = totalPageCount(total, pageSize);
  const pageRange = paginationRange(page, pageSize, total);

  return (
    <div
      className={
        className ??
        "sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-border bg-card/95 backdrop-blur-md px-4 py-3 text-xs text-muted-foreground shadow-xs"
      }
    >
      <div className="flex items-center gap-3">
        <span>
          Showing{" "}
          <strong className="font-semibold text-foreground">
            {pageRange.from}
          </strong>{" "}
          -{" "}
          <strong className="font-semibold text-foreground">
            {pageRange.to}
          </strong>{" "}
          of{" "}
          <strong className="font-semibold text-foreground">
            {total}
          </strong>{" "}
          {itemLabel}
        </span>
        <span className="text-border">|</span>
        <div className="flex items-center gap-1.5">
          <span>Per page:</span>
          <RowsPerPageSelect
            value={pageSize}
            onChange={(sz) => {
              onPageSizeChange(sz);
              onPageChange(1);
            }}
          />
        </div>
      </div>

      <div className="flex items-center gap-1.5">
        <button
          type="button"
          onClick={() => onPageChange((p) => Math.max(1, (typeof p === "number" ? p : page) - 1))}
          disabled={page <= 1}
          className="inline-flex items-center gap-1 rounded-md border border-border bg-background px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
        >
          <ChevronLeft className="h-3.5 w-3.5" /> Previous
        </button>
        <span className="px-2 tabular-nums font-semibold text-foreground">
          {page} / {totalPages}
        </span>
        <button
          type="button"
          onClick={() => onPageChange((p) => Math.min(totalPages, (typeof p === "number" ? p : page) + 1))}
          disabled={page >= totalPages}
          className="inline-flex items-center gap-1 rounded-md border border-border bg-background px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
        >
          Next <ChevronRight className="h-3.5 w-3.5" />
        </button>
      </div>
    </div>
  );
}
