import { PAGE_SIZE_ALL, PAGE_SIZE_OPTIONS } from "@/lib/pagination";

type RowsPerPageSelectProps = {
  value: number;
  onChange: (pageSize: number) => void;
  className?: string;
};

export function RowsPerPageSelect({ value, onChange, className }: RowsPerPageSelectProps) {
  return (
    <select
      value={value}
      onChange={(e) => onChange(Number(e.target.value))}
      className={
        className ??
        "h-7 min-w-[3.25rem] rounded-md border border-input bg-background pl-2 pr-5 text-xs font-medium text-foreground outline-none cursor-pointer hover:bg-muted/30 transition-colors"
      }
      aria-label="Rows per page"
    >
      {PAGE_SIZE_OPTIONS.map((size) => (
        <option key={size} value={size}>
          {size}
        </option>
      ))}
      <option value={PAGE_SIZE_ALL}>All</option>
    </select>
  );
}
