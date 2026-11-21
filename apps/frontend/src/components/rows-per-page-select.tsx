import { SearchableSelect } from "@/components/creatable-catalog-select";
import { PAGE_SIZE_ALL, PAGE_SIZE_OPTIONS } from "@/lib/pagination";

type RowsPerPageSelectProps = {
  value: number;
  onChange: (pageSize: number) => void;
};

export function RowsPerPageSelect({ value, onChange }: RowsPerPageSelectProps) {
  return (
    <SearchableSelect
      value={String(value)}
      onChange={(next) => onChange(Number(next))}
      placeholder="Rows"
      options={[
        ...PAGE_SIZE_OPTIONS.map((size) => ({ value: String(size), label: String(size) })),
        { value: String(PAGE_SIZE_ALL), label: "All" },
      ]}
      clearable={false}
      showSearch={false}
      className="w-[5.5rem] shrink-0"
      menuMinWidth={0}
      buttonClassName="h-8 w-full cursor-pointer border-border bg-background px-2.5 font-medium text-foreground shadow-none hover:bg-accent"
    />
  );
}
