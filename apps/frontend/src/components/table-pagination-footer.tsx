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
        "sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-slate-300 dark:border-slate-700 bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80 shadow-xs"
      }
    >
      <div className="flex items-center gap-3">
        <span>
          Showing{" "}
          <strong className="font-semibold text-blue-950 dark:text-blue-100">
            {pageRange.from}
          </strong>{" "}
          -{" "}
          <strong className="font-semibold text-blue-950 dark:text-blue-100">
            {pageRange.to}
          </strong>{" "}
          of{" "}
          <strong className="font-semibold text-blue-950 dark:text-blue-100">
            {total}
          </strong>{" "}
          {itemLabel}
        </span>
        <span className="text-slate-300 dark:text-slate-600">|</span>
        <div className="flex items-center gap-1.5">
          <span>Per page:</span>
          <RowsPerPageSelect
            value={pageSize}
            onChange={(sz) => {
              onPageSizeChange(sz);
              onPageChange(1);
            }}
            className="h-7 min-w-[3.25rem] rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-950/60 pl-2 pr-5 text-xs font-medium text-blue-950 dark:text-blue-100 outline-none cursor-pointer hover:bg-blue-100/50 dark:hover:bg-blue-900/40 transition-colors focus-visible:ring-1 focus-visible:ring-blue-500"
          />
        </div>
      </div>

      <div className="flex items-center gap-1.5">
        <button
          type="button"
          onClick={() => onPageChange((p) => Math.max(1, (typeof p === "number" ? p : page) - 1))}
          disabled={page <= 1}
          className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
        >
          <ChevronLeft className="h-3.5 w-3.5" /> Previous
        </button>
        <span className="px-2 tabular-nums font-semibold text-blue-950 dark:text-blue-100">
          {page} / {totalPages}
        </span>
        <button
          type="button"
          onClick={() => onPageChange((p) => Math.min(totalPages, (typeof p === "number" ? p : page) + 1))}
          disabled={page >= totalPages}
          className="inline-flex items-center gap-1 rounded-md border border-slate-300 dark:border-slate-600 bg-white/90 dark:bg-blue-900/50 px-2.5 py-1 text-xs font-medium text-blue-950 dark:text-blue-100 hover:bg-blue-100/60 dark:hover:bg-blue-800/60 disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
        >
          Next <ChevronRight className="h-3.5 w-3.5" />
        </button>
      </div>
    </div>
  );
}
