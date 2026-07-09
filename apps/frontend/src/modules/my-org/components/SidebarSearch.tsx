import { Search } from "lucide-react";

interface SidebarSearchProps {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
}

export function SidebarSearch({
  value,
  onChange,
  placeholder = "Search documents...",
}: SidebarSearchProps) {
  return (
    <div className="relative">
      <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="h-8 w-full rounded-md border border-input bg-background pl-7 pr-3 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
      />
    </div>
  );
}
