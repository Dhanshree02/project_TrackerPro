import { Folder, FolderOpen } from "lucide-react";
import { cn } from "@/lib/utils";

interface FolderItemProps {
  label: string;
  count: number;
  isActive: boolean;
  onClick: () => void;
}

export function FolderItem({ label, count, isActive, onClick }: FolderItemProps) {
  const Icon = isActive ? FolderOpen : Folder;

  return (
    <button
      onClick={onClick}
      className={cn(
        "flex w-full items-center justify-between rounded-md px-2.5 py-2 text-left text-xs transition-colors",
        isActive
          ? "bg-primary/10 font-semibold text-primary"
          : "text-foreground/70 hover:bg-accent/40 hover:text-foreground",
      )}
    >
      <span className="flex min-w-0 items-center gap-2">
        <Icon className="h-3.5 w-3.5 shrink-0" />
        <span className="truncate">{label}</span>
      </span>
      <span
        className={cn(
          "ml-2 shrink-0 rounded-full px-1.5 py-0.5 text-[10px] font-semibold tabular-nums",
          isActive
            ? "bg-primary/15 text-primary"
            : "bg-muted text-muted-foreground",
        )}
      >
        {count}
      </span>
    </button>
  );
}
