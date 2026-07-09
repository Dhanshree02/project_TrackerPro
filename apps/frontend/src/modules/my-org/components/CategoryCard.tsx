import {
  Code2,
  ClipboardList,
  FileText,
  Headphones,
  type LucideIcon,
} from "lucide-react";
import { cn } from "@/lib/utils";
import type { OrgCategory } from "../types";

// ── Icon lookup ───────────────────────────────────────────────────────────────
// Keys must match the `iconName` values in dummy-data/my-org/categories.ts
const ICON_MAP: Record<string, LucideIcon> = {
  Code2,
  ClipboardList,
  FileText,
  Headphones,
};

// ── Accent colour tokens ──────────────────────────────────────────────────────
const ACCENT = {
  blue: {
    bg: "bg-blue-500/10",
    border: "border-blue-500/20",
    icon: "text-blue-600 dark:text-blue-400",
    count: "text-blue-700 dark:text-blue-300",
  },
  purple: {
    bg: "bg-purple-500/10",
    border: "border-purple-500/20",
    icon: "text-purple-600 dark:text-purple-400",
    count: "text-purple-700 dark:text-purple-300",
  },
  green: {
    bg: "bg-emerald-500/10",
    border: "border-emerald-500/20",
    icon: "text-emerald-600 dark:text-emerald-400",
    count: "text-emerald-700 dark:text-emerald-300",
  },
  amber: {
    bg: "bg-amber-500/10",
    border: "border-amber-500/20",
    icon: "text-amber-600 dark:text-amber-400",
    count: "text-amber-700 dark:text-amber-300",
  },
} as const;

interface CategoryCardProps {
  category: OrgCategory;
  docCount: number;
  isActive: boolean;
  onClick: () => void;
  /** When true (e.g. inside UploadAssignmentModal) hides the document count. */
  hideCount?: boolean;
}

export function CategoryCard({
  category,
  docCount,
  isActive,
  onClick,
  hideCount = false,
}: CategoryCardProps) {
  const Icon = ICON_MAP[category.iconName] ?? FileText;
  const accent = ACCENT[category.accentColor] ?? ACCENT.blue;

  return (
    <button
      onClick={onClick}
      className={cn(
        "flex flex-col gap-2 rounded-xl border p-4 text-left transition-all hover:shadow-sm",
        isActive
          ? `${accent.bg} ${accent.border}`
          : "border-border bg-card hover:bg-accent/30",
      )}
    >
      {/* Icon */}
      <div className={cn("flex h-8 w-8 items-center justify-center rounded-lg", accent.bg)}>
        <Icon className={cn("h-4 w-4", accent.icon)} />
      </div>

      {/* Name + description */}
      <div>
        <p className="text-sm font-semibold leading-tight text-foreground">
          {category.name}
        </p>
        <p className="mt-0.5 text-[11px] leading-snug text-muted-foreground">
          {category.description}
        </p>
      </div>

      {/* Document count */}
      {!hideCount && (
        <p className={cn("text-xs font-medium", accent.count)}>
          {docCount} {docCount === 1 ? "document" : "documents"}
        </p>
      )}
    </button>
  );
}
