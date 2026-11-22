import { ChevronDown, ChevronUp } from "lucide-react";
import { cn } from "@/lib/utils";

/** Column header used by every list table. The arrow shows only on the sorted column. */
export function SortableColumnHeader<T extends string>({
  label,
  column,
  sortKey,
  sortDir,
  onSort,
  className,
  align = "left",
}: {
  label: string;
  column: T;
  sortKey: T;
  sortDir: "asc" | "desc";
  onSort: (column: T) => void;
  className?: string;
  align?: "left" | "right";
}) {
  const active = sortKey === column;
  return (
    <th
      className={cn(
        "whitespace-nowrap px-4 py-3.5 align-middle",
        align === "right" ? "text-right" : "text-left",
        className,
      )}
    >
      <button
        type="button"
        onClick={() => onSort(column)}
        className={cn(
          "inline-flex items-center gap-1.5 whitespace-nowrap text-[13px] font-semibold tracking-[-0.01em] select-none",
          align === "right" ? "ml-auto" : "text-left",
          active ? "text-foreground" : "text-muted-foreground hover:text-foreground",
        )}
        aria-sort={active ? (sortDir === "asc" ? "ascending" : "descending") : "none"}
        aria-label={`Sort by ${label}`}
      >
        <span>{label}</span>
        {active &&
          (sortDir === "desc" ? (
            <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
          ) : (
            <ChevronUp className="h-3.5 w-3.5 text-muted-foreground" />
          ))}
      </button>
    </th>
  );
}

export function toggleColumnSort<T extends string>(
  column: T,
  sortKey: T,
  setSortKey: (column: T) => void,
  setSortDir: (dir: "asc" | "desc" | ((dir: "asc" | "desc") => "asc" | "desc")) => void,
) {
  if (sortKey === column) setSortDir((dir) => (dir === "asc" ? "desc" : "asc"));
  else {
    setSortKey(column);
    setSortDir("asc");
  }
}

export function compareSortValues(a: string | number, b: string | number, dir: "asc" | "desc") {
  const sign = dir === "asc" ? 1 : -1;
  if (typeof a === "number" && typeof b === "number") return (a - b) * sign;
  return String(a).localeCompare(String(b), undefined, { numeric: true, sensitivity: "base" }) * sign;
}
