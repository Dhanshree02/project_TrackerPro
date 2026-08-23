import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useRef, useState, useTransition } from "react";
import {
  Upload,
  Search,
  Folder,
  FolderOpen,
  FileText,
  ChevronLeft,
  ChevronRight,
  ChevronDown,
  ChevronUp,
  X,
  Code2,
  ClipboardList,
  Download,
  Trash2,
  AlertTriangle,
  ScrollText,
  Users,
  Clock,
  ArrowUpDown,
  Filter,
  CheckCircle2,
  type LucideIcon,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import {
  fetchRepositoryDocuments,
  fetchRepositoryCategoryCounts,
  fetchRepositoryAccessSummaries,
  uploadRepositoryDocument,
  deleteRepositoryDocument,
  recordRepositoryDocumentView,
  getRepositoryDownloadUrl,
  type RepositoryItem,
  type DocumentAccessSummary,
  type DocumentAccessEntry,
} from "@/lib/api/repository";

export const Route = createFileRoute("/my-org")({
  head: () => ({
    meta: [
      { title: "Repository — Pulse PMO" },
      {
        name: "description",
        content: "Organization documents, Standard Operating Procedures, and policy resources.",
      },
    ],
  }),
  component: MyOrgRoute,
});

function MyOrgRoute() {
  const { isDhanshree } = useRoleContext();
  const { hasPermission } = usePermissions();
  if (!isDhanshree && !hasPermission("repository.view")) return <Navigate to="/" />;
  return <MyOrgPage />;
}

// ─── Types & Constants ────────────────────────────────────────────────────────

type AccentColor = "blue" | "purple" | "green";

interface CategoryMeta {
  id: string;
  name: string;
  backendKey: string;
  description: string;
  iconName: string;
  accentColor: AccentColor;
  count: number;
}

const DEFAULT_CATEGORIES: CategoryMeta[] = [
  {
    id: "tech-sops",
    name: "Tech. SOPs",
    backendKey: "Tech",
    description: "Technical Standard Operating Procedures for engineering and infrastructure.",
    iconName: "Code2",
    accentColor: "blue",
    count: 0,
  },
  {
    id: "pms-sops",
    name: "PMS. SOPs",
    backendKey: "PMS",
    description: "Project Management System Standard Operating Procedures.",
    iconName: "ClipboardList",
    accentColor: "purple",
    count: 0,
  },
  {
    id: "policy-docs",
    name: "IMP Templates",
    backendKey: "IMP",
    description: "Important templates, company-wide policies, guidelines, and compliance documents.",
    iconName: "FileText",
    accentColor: "green",
    count: 0,
  },
];

const ICON_MAP: Record<string, LucideIcon> = {
  Code2,
  ClipboardList,
  FileText,
};

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
} as const;

const FILE_TYPE_COLORS: Record<string, string> = {
  pdf: "text-red-500",
  docx: "text-blue-500",
  doc: "text-blue-500",
};

const AVATAR_PALETTE = [
  "bg-blue-600 text-white ring-blue-700/20",
  "bg-emerald-600 text-white ring-emerald-700/20",
  "bg-violet-600 text-white ring-violet-700/20",
  "bg-amber-600 text-white ring-amber-700/20",
  "bg-rose-600 text-white ring-rose-700/20",
  "bg-indigo-600 text-white ring-indigo-700/20",
  "bg-teal-600 text-white ring-teal-700/20",
  "bg-orange-600 text-white ring-orange-700/20",
  "bg-cyan-600 text-white ring-cyan-700/20",
  "bg-pink-600 text-white ring-pink-700/20",
];

// ─── Utilities ────────────────────────────────────────────────────────────────

function formatFileSize(bytes: number): string {
  if (!bytes || bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"] as const;
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
}

function formatLastUpdated(iso: string): string {
  if (!iso) return "—";
  const d = new Date(iso);
  if (isNaN(d.getTime())) return "—";
  return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });
}

function formatExactDateTime(iso: string): string {
  if (!iso) return "—";
  const d = new Date(iso);
  if (isNaN(d.getTime())) return "—";
  return d.toLocaleString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });
}

function formatRelativeTime(iso: string): string {
  if (!iso) return "";
  const d = new Date(iso);
  const now = new Date();
  const diffMs = now.getTime() - d.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffMins < 1) return "Just now";
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays === 1) return "Yesterday";
  if (diffDays < 7) return `${diffDays}d ago`;
  return formatLastUpdated(iso);
}

function getInitials(name: string): string {
  if (!name) return "?";
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

function getAvatarColorClass(name: string): string {
  if (!name) return AVATAR_PALETTE[0];
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  const index = Math.abs(hash) % AVATAR_PALETTE.length;
  return AVATAR_PALETTE[index];
}

function isValidFileType(fileName: string): boolean {
  const ext = fileName.split(".").pop()?.toLowerCase();
  return ext === "pdf" || ext === "docx";
}

// ─── Collaborative Avatar Stack Component (Web Word Style) ───────────────────

function CollaborativeAvatarStack({
  accessors,
  maxDisplay = 3,
  onOpenDetails,
}: {
  accessors: DocumentAccessEntry[];
  maxDisplay?: number;
  onOpenDetails?: () => void;
}) {
  // Filter unique employees from accessors (excluding upload if download exists)
  const uniqueEmployees = useMemo(() => {
    const map = new Map<string, DocumentAccessEntry>();
    for (const a of accessors) {
      const key = a.employeeName.trim().toLowerCase();
      if (!map.has(key)) {
        map.set(key, a);
      }
    }
    return Array.from(map.values());
  }, [accessors]);

  if (uniqueEmployees.length === 0) {
    return (
      <span className="inline-flex items-center gap-1 text-[11px] text-muted-foreground/60 italic">
        No downloads yet
      </span>
    );
  }

  const visible = uniqueEmployees.slice(0, maxDisplay);
  const remainingCount = uniqueEmployees.length - maxDisplay;

  return (
    <div
      className="inline-flex items-center gap-2 cursor-pointer group"
      onClick={onOpenDetails}
      title="Click to view full employee download timestamps"
    >
      <div className="flex items-center -space-x-2 overflow-hidden py-1">
        {visible.map((emp, i) => (
          <div
            key={emp.logId || `${emp.employeeName}-${i}`}
            className={cn(
              "relative inline-flex h-7 w-7 items-center justify-center rounded-full text-[10px] font-bold ring-2 ring-card shadow-xs transition-transform duration-150 group-hover:scale-105 group-hover:z-10",
              getAvatarColorClass(emp.employeeName),
            )}
            title={`${emp.employeeName} (${emp.action} on ${formatExactDateTime(emp.accessedAtUtc)})`}
          >
            {getInitials(emp.employeeName)}
          </div>
        ))}
        {remainingCount > 0 && (
          <div
            className="relative inline-flex h-7 w-7 items-center justify-center rounded-full bg-muted border-2 border-card text-[10px] font-bold text-foreground ring-2 ring-card shadow-xs group-hover:bg-accent transition-colors"
            title={`${remainingCount} more employee${remainingCount > 1 ? "s" : ""}`}
          >
            +{remainingCount}
          </div>
        )}
      </div>

      <span className="text-[11px] font-medium text-muted-foreground group-hover:text-foreground transition-colors tabular-nums">
        {uniqueEmployees.length} {uniqueEmployees.length === 1 ? "employee" : "employees"}
      </span>
    </div>
  );
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function CategoryCard({
  category,
  docCount,
  isActive,
  onClick,
  hideCount = false,
}: {
  category: CategoryMeta;
  docCount: number;
  isActive: boolean;
  onClick: () => void;
  hideCount?: boolean;
}) {
  const Icon = ICON_MAP[category.iconName] ?? FileText;
  const accent = ACCENT[category.accentColor] ?? ACCENT.blue;

  return (
    <button
      type="button"
      onClick={onClick}
      className={cn(
        "flex flex-col gap-2 rounded-xl border p-4 text-left transition-all hover:shadow-sm",
        isActive ? `${accent.bg} ${accent.border}` : "border-border bg-card hover:bg-accent/30",
      )}
    >
      <div className={cn("flex h-8 w-8 items-center justify-center rounded-lg", accent.bg)}>
        <Icon className={cn("h-4 w-4", accent.icon)} />
      </div>
      <div>
        <p className="text-sm font-semibold leading-tight text-foreground">{category.name}</p>
        <p className="mt-0.5 text-[11px] leading-snug text-muted-foreground">
          {category.description}
        </p>
      </div>
      {!hideCount && (
        <p className={cn("text-xs font-medium", accent.count)}>
          {docCount} {docCount === 1 ? "document" : "documents"}
        </p>
      )}
    </button>
  );
}

function FolderItem({
  label,
  count,
  isActive,
  onClick,
}: {
  label: string;
  count: number;
  isActive: boolean;
  onClick: () => void;
}) {
  const Icon = isActive ? FolderOpen : Folder;
  return (
    <button
      type="button"
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
          isActive ? "bg-primary/15 text-primary" : "bg-muted text-muted-foreground",
        )}
      >
        {count}
      </span>
    </button>
  );
}

function CategorySidebar({
  categories,
  totalCount,
  activeCategoryId,
  searchQuery,
  onSearchChange,
  onSelectCategory,
}: {
  categories: CategoryMeta[];
  totalCount: number;
  activeCategoryId: string | null;
  searchQuery: string;
  onSearchChange: (v: string) => void;
  onSelectCategory: (id: string | null) => void;
}) {
  return (
    <aside className="w-52 shrink-0">
      <div className="rounded-xl border border-border bg-card p-3">
        <p className="mb-2.5 text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
          Folders
        </p>
        {/* Search */}
        <div className="relative">
          <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          <input
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search documents..."
            className="h-8 w-full rounded-md border border-input bg-background pl-7 pr-3 text-xs outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
        </div>
        {/* Folder list */}
        <div className="mt-2.5 flex flex-col gap-0.5">
          <FolderItem
            label="All Documents"
            count={totalCount}
            isActive={activeCategoryId === null}
            onClick={() => onSelectCategory(null)}
          />
          {categories.map((cat) => (
            <FolderItem
              key={cat.id}
              label={cat.name}
              count={cat.count}
              isActive={activeCategoryId === cat.id}
              onClick={() => onSelectCategory(cat.id)}
            />
          ))}
        </div>
      </div>
    </aside>
  );
}

// ── Delete confirmation dialog ──
function DeleteConfirmDialog({
  document,
  isDeleting,
  onConfirm,
  onCancel,
}: {
  document: RepositoryItem;
  isDeleting: boolean;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/50 backdrop-blur-[1px]" onClick={onCancel} />
      <div
        className="relative w-full max-w-md rounded-xl border border-destructive/30 bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-destructive/10">
            <AlertTriangle className="h-5 w-5 text-destructive" />
          </div>
          <div className="min-w-0">
            <h2 className="text-base font-semibold text-foreground">Delete Document?</h2>
            <p className="mt-1 text-xs text-muted-foreground">
              This action cannot be undone. The document will be permanently removed from the
              repository.
            </p>
          </div>
          <button
            onClick={onCancel}
            disabled={isDeleting}
            className="ml-auto shrink-0 rounded-md p-1 text-muted-foreground transition-colors hover:bg-accent"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="mt-4 flex items-center gap-3 rounded-lg border border-border bg-muted/30 p-3">
          <FileText className="h-4 w-4 shrink-0 text-destructive/70" />
          <div className="min-w-0">
            <p className="truncate text-sm font-medium text-foreground">{document.fileName}</p>
            <p className="text-[11px] text-muted-foreground">
              {formatFileSize(document.size)} · Uploaded by {document.uploadedBy}
            </p>
          </div>
        </div>

        <div className="mt-5 flex items-center justify-end gap-2 border-t border-border pt-4">
          <button
            type="button"
            disabled={isDeleting}
            onClick={onCancel}
            className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            Cancel
          </button>
          <button
            type="button"
            disabled={isDeleting}
            onClick={onConfirm}
            className="inline-flex items-center gap-2 rounded-md bg-destructive px-4 py-2 text-sm font-medium text-destructive-foreground shadow-sm transition-all hover:bg-destructive/90"
          >
            <Trash2 className="h-4 w-4" />
            {isDeleting ? "Deleting..." : "Yes, Delete"}
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Document Access & Download Logs Modal (Collaborative View) ───────────────

function DocumentAccessLogModal({
  summaries,
  isLoading,
  onClose,
  onDownloadDoc,
}: {
  summaries: DocumentAccessSummary[];
  isLoading: boolean;
  onClose: () => void;
  onDownloadDoc: (docId: string, fileName: string) => void;
}) {
  const [modalSearch, setModalSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("all");
  const [expandedDocId, setExpandedDocId] = useState<string | null>(null);

  // Compute summary stats
  const totalDownloads = useMemo(
    () => summaries.reduce((acc, s) => acc + s.totalDownloads, 0),
    [summaries],
  );

  const totalUniqueAccessors = useMemo(() => {
    const set = new Set<string>();
    summaries.forEach((s) => {
      s.accessors.forEach((a) => {
        if (a.employeeName) set.add(a.employeeName.trim().toLowerCase());
      });
    });
    return set.size;
  }, [summaries]);

  // Filter summaries
  const filteredSummaries = useMemo(() => {
    return summaries.filter((s) => {
      const matchCat =
        selectedCategory === "all" ||
        s.category.toLowerCase() === selectedCategory.toLowerCase();

      const searchLower = modalSearch.trim().toLowerCase();
      const matchSearch =
        !searchLower ||
        s.fileName.toLowerCase().includes(searchLower) ||
        s.uploadedBy.toLowerCase().includes(searchLower) ||
        s.accessors.some((a) =>
          a.employeeName.toLowerCase().includes(searchLower),
        );

      return matchCat && matchSearch;
    });
  }, [summaries, selectedCategory, modalSearch]);

  const toggleExpand = (docId: string) => {
    setExpandedDocId((prev) => (prev === docId ? null : docId));
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-xs" onClick={onClose} />
      <div
        className="relative flex w-full max-w-4xl flex-col rounded-2xl border border-border bg-card shadow-2xl animate-in fade-in zoom-in-95 duration-150 overflow-hidden"
        style={{ maxHeight: "88vh" }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="border-b border-border bg-muted/20 px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <Users className="h-5 w-5" />
              </div>
              <div>
                <h2 className="text-base font-semibold text-foreground">
                  Document Access & Download Logs
                </h2>
                <p className="text-xs text-muted-foreground">
                  Track uploaded documents and employees accessing or downloading each file.
                </p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          {/* Quick Metrics Bar */}
          <div className="mt-4 grid grid-cols-3 gap-3 border-t border-border/60 pt-3">
            <div className="flex items-center gap-2.5 rounded-lg border border-border/80 bg-background/80 px-3 py-2">
              <FileText className="h-4 w-4 text-blue-500 shrink-0" />
              <div>
                <p className="text-[11px] text-muted-foreground">Uploaded Documents</p>
                <p className="text-sm font-bold text-foreground tabular-nums">
                  {summaries.length}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2.5 rounded-lg border border-border/80 bg-background/80 px-3 py-2">
              <Download className="h-4 w-4 text-emerald-500 shrink-0" />
              <div>
                <p className="text-[11px] text-muted-foreground">Total Downloads</p>
                <p className="text-sm font-bold text-foreground tabular-nums">
                  {totalDownloads}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-2.5 rounded-lg border border-border/80 bg-background/80 px-3 py-2">
              <Users className="h-4 w-4 text-purple-500 shrink-0" />
              <div>
                <p className="text-[11px] text-muted-foreground">Active Employees</p>
                <p className="text-sm font-bold text-foreground tabular-nums">
                  {totalUniqueAccessors}
                </p>
              </div>
            </div>
          </div>

          {/* Controls: Search & Category Filter */}
          <div className="mt-3.5 flex flex-wrap items-center justify-between gap-2.5">
            <div className="relative flex-1 min-w-[220px]">
              <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
              <input
                value={modalSearch}
                onChange={(e) => setModalSearch(e.target.value)}
                placeholder="Search by document name or employee..."
                className="h-8 w-full rounded-md border border-input bg-background pl-8 pr-3 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring"
              />
            </div>
            <div className="flex items-center gap-1.5">
              {(["all", "Tech", "PMS", "IMP"] as const).map((cat) => (
                <button
                  key={cat}
                  type="button"
                  onClick={() => setSelectedCategory(cat)}
                  className={cn(
                    "rounded-md px-2.5 py-1 text-xs font-medium transition-colors",
                    selectedCategory === cat
                      ? "bg-primary text-primary-foreground shadow-2xs"
                      : "bg-muted/60 text-muted-foreground hover:bg-accent hover:text-foreground",
                  )}
                >
                  {cat === "all" ? "All Categories" : cat}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Content Body: List of Uploaded Documents with Collaborative Access Stacks */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-3">
          {isLoading ? (
            <div className="py-16 text-center text-sm text-muted-foreground">
              <div className="inline-flex items-center gap-2">
                <div className="h-4 w-4 animate-spin rounded-full border-2 border-primary border-t-transparent" />
                Loading document access history...
              </div>
            </div>
          ) : filteredSummaries.length === 0 ? (
            <div className="py-16 text-center text-sm text-muted-foreground">
              No matching documents or download logs found.
            </div>
          ) : (
            filteredSummaries.map((doc) => {
              const isExpanded = expandedDocId === doc.documentId;
              const ext = doc.fileName.split(".").pop()?.toLowerCase() ?? "";
              const isDocx = ext === "docx";

              return (
                <div
                  key={doc.documentId}
                  className={cn(
                    "rounded-xl border border-border bg-card transition-all overflow-hidden",
                    isExpanded ? "ring-1 ring-primary/30 shadow-sm" : "hover:border-border/80",
                  )}
                >
                  {/* Summary Bar */}
                  <div className="p-3.5 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    {/* Document Meta */}
                    <div className="flex items-start gap-3 min-w-0 flex-1">
                      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-border bg-muted/40 mt-0.5">
                        <FileText
                          className={cn(
                            "h-4 w-4",
                            isDocx ? "text-blue-500" : "text-red-500",
                          )}
                        />
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="flex flex-wrap items-center gap-2">
                          <p
                            className="text-sm font-semibold text-foreground truncate max-w-sm"
                            title={doc.fileName}
                          >
                            {doc.fileName}
                          </p>
                          <span
                            className={cn(
                              "inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-semibold",
                              doc.category.toUpperCase().includes("TECH")
                                ? "bg-blue-500/10 text-blue-600 dark:text-blue-400 border border-blue-500/20"
                                : doc.category.toUpperCase().includes("PMS")
                                  ? "bg-purple-500/10 text-purple-600 dark:text-purple-400 border border-purple-500/20"
                                  : "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20",
                            )}
                          >
                            {doc.category}
                          </span>
                        </div>
                        <p className="mt-0.5 text-[11px] text-muted-foreground">
                          Uploaded by <strong className="font-medium text-foreground">{doc.uploadedBy}</strong> · {formatFileSize(doc.size)} · {formatLastUpdated(doc.lastUpdated)}
                        </p>
                      </div>
                    </div>

                    {/* Collaborative User Avatar Stack (Web Word style) */}
                    <div className="flex items-center justify-between sm:justify-end gap-3 pl-12 sm:pl-0">
                      <CollaborativeAvatarStack
                        accessors={doc.accessors}
                        onOpenDetails={() => toggleExpand(doc.documentId)}
                      />

                      <div className="flex items-center gap-1.5 shrink-0">
                        <button
                          type="button"
                          onClick={() => onDownloadDoc(doc.documentId, doc.fileName)}
                          title="Download file"
                          className="inline-flex h-8 w-8 items-center justify-center rounded-md text-muted-foreground hover:bg-accent hover:text-foreground transition-colors"
                        >
                          <Download className="h-4 w-4" />
                        </button>
                        <button
                          type="button"
                          onClick={() => toggleExpand(doc.documentId)}
                          className={cn(
                            "inline-flex items-center gap-1 rounded-md px-2.5 py-1.5 text-xs font-medium transition-colors border",
                            isExpanded
                              ? "bg-accent text-foreground border-border"
                              : "border-border/60 bg-muted/40 text-muted-foreground hover:bg-accent hover:text-foreground",
                          )}
                        >
                          {isExpanded ? (
                            <>
                              Hide Log <ChevronUp className="h-3.5 w-3.5" />
                            </>
                          ) : (
                            <>
                              View History <ChevronDown className="h-3.5 w-3.5" />
                            </>
                          )}
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* Expanded Detailed Access History Table & Timestamps */}
                  {isExpanded && (
                    <div className="border-t border-border bg-muted/20 px-4 py-3 sm:px-6 sm:py-4 animate-in fade-in duration-150">
                      <div className="flex items-center justify-between mb-2.5">
                        <p className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                          <Clock className="h-3.5 w-3.5 text-muted-foreground" />
                          Complete Access & Download History ({doc.accessors.length})
                        </p>
                      </div>

                      {doc.accessors.length === 0 ? (
                        <p className="py-4 text-center text-xs text-muted-foreground">
                          No employee access logs recorded for this document yet.
                        </p>
                      ) : (
                        <div className="divide-y divide-border/60 rounded-lg border border-border/80 bg-background overflow-hidden">
                          {doc.accessors.map((log) => {
                            const isUpload = log.action === "Uploaded";
                            const isDownload = log.action === "Downloaded";

                            return (
                              <div
                                key={log.logId}
                                className="flex items-center justify-between gap-3 px-3.5 py-2.5 text-xs hover:bg-muted/30 transition-colors"
                              >
                                <div className="flex items-center gap-2.5 min-w-0">
                                  <div
                                    className={cn(
                                      "flex h-6 w-6 items-center justify-center rounded-full text-[10px] font-bold shrink-0",
                                      getAvatarColorClass(log.employeeName),
                                    )}
                                  >
                                    {getInitials(log.employeeName)}
                                  </div>
                                  <div className="min-w-0">
                                    <p className="font-semibold text-foreground truncate">
                                      {log.employeeName}
                                    </p>
                                    <p className="text-[11px] text-muted-foreground truncate">
                                      {log.details || `${log.employeeName} ${log.action.toLowerCase()} this file`}
                                    </p>
                                  </div>
                                </div>

                                <div className="flex items-center gap-3 shrink-0">
                                  <span
                                    className={cn(
                                      "inline-flex items-center rounded-full px-2 py-0.5 text-[10px] font-medium",
                                      isDownload
                                        ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20"
                                        : isUpload
                                          ? "bg-blue-500/10 text-blue-600 dark:text-blue-400 border border-blue-500/20"
                                          : "bg-muted text-muted-foreground",
                                    )}
                                  >
                                    {log.action}
                                  </span>
                                  <div className="text-right">
                                    <p className="font-medium text-foreground tabular-nums text-[11px]">
                                      {formatExactDateTime(log.accessedAtUtc)}
                                    </p>
                                    <p className="text-[10px] text-muted-foreground">
                                      {formatRelativeTime(log.accessedAtUtc)}
                                    </p>
                                  </div>
                                </div>
                              </div>
                            );
                          })}
                        </div>
                      )}
                    </div>
                  )}
                </div>
              );
            })
          )}
        </div>

        {/* Modal Footer */}
        <div className="flex items-center justify-between border-t border-border bg-muted/10 px-6 py-3 text-xs text-muted-foreground">
          <span>
            Showing <strong>{filteredSummaries.length}</strong> of{" "}
            <strong>{summaries.length}</strong> repository documents
          </span>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md border border-input bg-card px-4 py-1.5 text-xs font-medium text-foreground hover:bg-accent transition-colors shadow-2xs"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}

function UploadAssignmentModal({
  file,
  categories,
  isUploading,
  onAssign,
  onCancel,
}: {
  file: File;
  categories: CategoryMeta[];
  isUploading: boolean;
  onAssign: (categoryId: string) => void;
  onCancel: () => void;
}) {
  const [selectedCategoryId, setSelectedCategoryId] = useState<string | null>("tech-sops");

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40 backdrop-blur-[1px]" onClick={onCancel} />
      <div
        className="relative w-full max-w-lg rounded-xl border border-border bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between border-b border-border pb-4">
          <div>
            <h2 className="text-base font-semibold text-foreground">Assign Document to Category</h2>
            <p className="mt-0.5 text-xs text-muted-foreground">
              Select a category for this file before uploading.
            </p>
          </div>
          <button
            onClick={onCancel}
            disabled={isUploading}
            className="ml-4 shrink-0 rounded-md p-1 text-muted-foreground transition-colors hover:bg-accent"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* File info */}
        <div className="my-4 flex items-center gap-3 rounded-lg border border-border bg-muted/30 p-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-border bg-card">
            <FileText className="h-4 w-4 text-muted-foreground" />
          </div>
          <div className="min-w-0">
            <p className="truncate text-sm font-medium text-foreground">{file.name}</p>
            <p className="text-[11px] text-muted-foreground">{formatFileSize(file.size)}</p>
          </div>
        </div>

        {/* Category selection */}
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
          {categories.map((cat) => (
            <CategoryCard
              key={cat.id}
              category={cat}
              docCount={0}
              isActive={selectedCategoryId === cat.id}
              onClick={() => setSelectedCategoryId((prev) => (prev === cat.id ? null : cat.id))}
              hideCount
            />
          ))}
        </div>

        {/* Actions */}
        <div className="mt-5 flex items-center justify-end gap-2 border-t border-border pt-4">
          <button
            type="button"
            disabled={isUploading}
            onClick={onCancel}
            className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            Cancel
          </button>
          <button
            type="button"
            disabled={isUploading || !selectedCategoryId}
            onClick={() => selectedCategoryId && onAssign(selectedCategoryId)}
            className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground shadow-sm transition-all hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-40"
          >
            {isUploading ? "Uploading..." : "Upload Document"}
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Main Page Component ──────────────────────────────────────────────────────

function MyOrgPage() {
  const { isEmployee, isHr, isDhanshree, user } = useRoleContext();
  const isReadOnlyViewer = isEmployee || isHr;

  const [categories, setCategories] = useState<CategoryMeta[]>(DEFAULT_CATEGORIES);
  const [documents, setDocuments] = useState<RepositoryItem[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [totalPages, setTotalPages] = useState(1);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [activeCategoryId, setActiveCategoryId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");

  const [isLoading, setIsLoading] = useState(true);
  const [, startTransition] = useTransition();

  // Upload modal state
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);

  // Delete modal state
  const [pendingDeleteDoc, setPendingDeleteDoc] = useState<RepositoryItem | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  // Document Access Logs (Collaborative View) modal state
  const [showLog, setShowLog] = useState(false);
  const [accessSummaries, setAccessSummaries] = useState<DocumentAccessSummary[]>([]);
  const [isLoadingAccessSummaries, setIsLoadingAccessSummaries] = useState(false);

  const fileInputRef = useRef<HTMLInputElement>(null);

  // Load Categories & Counts
  const loadCategories = async () => {
    try {
      const serverCounts = await fetchRepositoryCategoryCounts();
      setCategories((prev) =>
        prev.map((cat) => {
          const matched = serverCounts.find(
            (sc) =>
              sc.id.toLowerCase() === cat.id.toLowerCase() ||
              sc.name.toLowerCase().includes(cat.backendKey.toLowerCase()),
          );
          return {
            ...cat,
            count: matched ? matched.documentCount : cat.count,
          };
        }),
      );
    } catch {
      // Best-effort
    }
  };

  // Load Documents from API
  const loadDocuments = async () => {
    setIsLoading(true);
    try {
      const activeCat = activeCategoryId
        ? categories.find((c) => c.id === activeCategoryId)?.backendKey
        : null;

      const res = await fetchRepositoryDocuments({
        page,
        perPage: pageSize,
        category: activeCat,
        search: searchQuery,
      });

      setDocuments(res.items || []);
      setTotalCount(res.total || 0);
      setTotalPages(Math.max(1, res.totalPages || 1));
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to load repository documents");
    } finally {
      setIsLoading(false);
    }
  };

  // Load Document Access Summaries for the Collaborative View Log
  const loadAccessSummaries = async () => {
    setIsLoadingAccessSummaries(true);
    try {
      const res = await fetchRepositoryAccessSummaries();
      setAccessSummaries(res || []);
    } catch {
      // Best effort
    } finally {
      setIsLoadingAccessSummaries(false);
    }
  };

  useEffect(() => {
    void loadCategories();
    void loadAccessSummaries();
  }, []);

  useEffect(() => {
    void loadDocuments();
  }, [page, pageSize, activeCategoryId, searchQuery]);

  const handleUploadClick = () => {
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
      fileInputRef.current.click();
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!isValidFileType(file.name)) {
      toast.error("Invalid file format", {
        description: "Only .pdf and .docx file formats are allowed.",
      });
      return;
    }

    setUploadedFile(file);
  };

  const handleAssignCategory = async (categoryId: string) => {
    if (!uploadedFile) return;
    setIsUploading(true);
    try {
      const catMeta = categories.find((c) => c.id === categoryId);
      const backendCategory = catMeta?.backendKey ?? "Tech";

      await uploadRepositoryDocument(uploadedFile, backendCategory, user?.name || "Admin");

      toast.success("Document uploaded successfully!");
      setUploadedFile(null);
      void loadCategories();
      void loadDocuments();
      void loadAccessSummaries();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Upload failed");
    } finally {
      setIsUploading(false);
    }
  };

  const handleConfirmDelete = async () => {
    if (!pendingDeleteDoc) return;
    setIsDeleting(true);
    try {
      await deleteRepositoryDocument(pendingDeleteDoc.id, user?.name || "Admin");
      toast.success("Document deleted");
      setPendingDeleteDoc(null);
      void loadCategories();
      void loadDocuments();
      void loadAccessSummaries();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Delete failed");
    } finally {
      setIsDeleting(false);
    }
  };

  const handleDownload = async (docId: string, fileName: string) => {
    try {
      // Record download activity with current employee
      await recordRepositoryDocumentView(docId, user?.name || "Employee");
      void loadAccessSummaries();
    } catch {
      // Best-effort
    }

    const url = getRepositoryDownloadUrl(docId);
    const link = document.createElement("a");
    link.href = url;
    link.download = fileName;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleSelectCategory = (id: string | null) => {
    startTransition(() => {
      setActiveCategoryId(id);
      setPage(1);
    });
  };

  const handleSearchChange = (v: string) => {
    startTransition(() => {
      setSearchQuery(v);
      setPage(1);
    });
  };

  const handleOpenLogs = () => {
    setShowLog(true);
    void loadAccessSummaries();
  };

  const canDeleteDoc = (doc: RepositoryItem) =>
    isDhanshree || doc.uploadedBy === user?.name || doc.uploadedBy === user?.email;

  const totalRepoDocuments = categories.reduce((sum, c) => sum + c.count, 0);

  // Total downloads count across all documents for button badge
  const totalDownloadsBadge = accessSummaries.reduce((sum, s) => sum + s.totalDownloads, 0);

  return (
    <AppShell title="Repository" subtitle="Organization documents, SOPs & policies">
      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        className="hidden"
        onChange={handleFileChange}
        accept=".pdf,.docx,application/pdf,application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      />

      {/* Action header */}
      <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
        <p className="text-xs text-muted-foreground">
          Manage organizational documents, SOPs, and policy resources.
        </p>
        <div className="flex items-center gap-2">
          {!isReadOnlyViewer && (
            <>
              {/* View Log button */}
              <button
                type="button"
                onClick={handleOpenLogs}
                className="inline-flex items-center gap-2 rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground shadow-sm transition-all hover:bg-accent"
              >
                <ScrollText className="h-4 w-4" />
                View Log
                {totalDownloadsBadge > 0 && (
                  <span className="rounded-full bg-primary/15 px-1.5 py-0.5 text-[10px] font-semibold text-primary">
                    {totalDownloadsBadge}
                  </span>
                )}
              </button>
              {/* Upload Document button */}
              <button
                type="button"
                onClick={handleUploadClick}
                className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground shadow-sm transition-all hover:bg-primary/90"
              >
                <Upload className="h-4 w-4" />
                Upload Document
              </button>
            </>
          )}
        </div>
      </div>

      {/* Category cards (Resized back to original KPI dimensions) */}
      <div className="mb-5 grid grid-cols-2 gap-3 sm:grid-cols-3">
        {categories.map((cat) => (
          <CategoryCard
            key={cat.id}
            category={cat}
            docCount={cat.count}
            isActive={activeCategoryId === cat.id}
            onClick={() => handleSelectCategory(activeCategoryId === cat.id ? null : cat.id)}
          />
        ))}
      </div>

      {/* Main content: sidebar + table */}
      <div className="flex gap-4">
        <CategorySidebar
          categories={categories}
          totalCount={totalRepoDocuments}
          activeCategoryId={activeCategoryId}
          searchQuery={searchQuery}
          onSearchChange={handleSearchChange}
          onSelectCategory={handleSelectCategory}
        />

        <div className="flex-1 min-w-0 flex flex-col gap-3">
          <div className="rounded-xl border border-border bg-card shadow-sm overflow-hidden flex flex-col">
            <div className="overflow-auto max-h-[calc(100vh-270px)] min-h-[380px]">
              <table className="w-full text-sm">
                <thead className="sticky top-0 z-10 bg-card text-left text-xs uppercase tracking-wide text-muted-foreground border-b border-border shadow-2xs">
                  <tr>
                    <th className="px-4 py-3 font-semibold">File Name</th>
                    <th className="px-4 py-3 font-semibold">Category</th>
                    <th className="px-4 py-3 font-semibold">Size</th>
                    <th className="px-4 py-3 font-semibold">Last Updated</th>
                    <th className="px-4 py-3 font-semibold">Uploaded By</th>
                    <th className="px-4 py-3 text-right font-semibold"></th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {isLoading ? (
                    <tr>
                      <td colSpan={6} className="px-4 py-12 text-center text-sm text-muted-foreground">
                        Loading documents...
                      </td>
                    </tr>
                  ) : documents.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="px-4 py-12 text-center text-sm text-muted-foreground">
                        No documents found.
                      </td>
                    </tr>
                  ) : (
                    documents.map((doc) => {
                      const ext = doc.fileName.split(".").pop()?.toLowerCase() ?? "";
                      const iconColor = FILE_TYPE_COLORS[ext] ?? "text-muted-foreground";

                      return (
                        <tr
                          key={doc.id}
                          className="border-b border-border transition-colors last:border-0 hover:bg-accent/20"
                        >
                          <td className="px-4 py-3">
                            <div className="flex items-center gap-2.5">
                              <FileText className={cn("h-4 w-4 shrink-0", iconColor)} />
                              <span className="text-sm font-medium text-foreground">{doc.fileName}</span>
                            </div>
                          </td>
                          <td className="whitespace-nowrap px-4 py-3">
                            <span className="inline-flex items-center rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] font-medium text-muted-foreground">
                              {doc.category}
                            </span>
                          </td>
                          <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
                            {formatFileSize(doc.size)}
                          </td>
                          <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
                            {formatLastUpdated(doc.lastUpdated)}
                          </td>
                          <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
                            {doc.uploadedBy}
                          </td>
                          <td className="whitespace-nowrap px-4 py-3 text-right">
                            <div className="inline-flex items-center justify-end gap-0.5">
                              <button
                                type="button"
                                title="Download document"
                                onClick={() => handleDownload(doc.id, doc.fileName)}
                                className="inline-flex items-center justify-center rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
                              >
                                <Download className="h-3.5 w-3.5" />
                              </button>
                              {canDeleteDoc(doc) && (
                                <button
                                type="button"
                                title="Delete document"
                                onClick={() => setPendingDeleteDoc(doc)}
                                className="inline-flex items-center justify-center rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-destructive/10 hover:text-destructive"
                              >
                                <Trash2 className="h-3.5 w-3.5" />
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>

          {/* Frozen / Sticky Pagination Footer */}
          <div className="sticky bottom-0 z-20 flex flex-col sm:flex-row items-center justify-between gap-3 border-t border-border bg-card px-4 py-3 text-xs text-muted-foreground shadow-xs">
            <div className="flex items-center gap-3">
              <span>
                Showing{" "}
                <strong className="font-semibold text-foreground">
                  {totalCount === 0 ? 0 : (page - 1) * pageSize + 1}
                </strong>
                –
                <strong className="font-semibold text-foreground">
                  {Math.min(page * pageSize, totalCount)}
                </strong>{" "}
                of <strong className="font-semibold text-foreground">{totalCount}</strong> documents
              </span>
              <span className="text-muted-foreground/40">|</span>
              <div className="flex items-center gap-1.5">
                <span>Per page:</span>
                <select
                  value={pageSize}
                  onChange={(e) => {
                    setPageSize(Number(e.target.value));
                    setPage(1);
                  }}
                  className="h-7 w-14 rounded-md border border-input bg-background pl-2 pr-5 text-xs font-medium text-foreground outline-none cursor-pointer hover:bg-muted/30 transition-colors"
                  aria-label="Rows per page"
                >
                  <option value={10}>10</option>
                  <option value={15}>15</option>
                  <option value={25}>25</option>
                  <option value={50}>50</option>
                  <option value={100}>100</option>
                </select>
              </div>
            </div>

            <div className="flex items-center gap-1.5">
              <button
                type="button"
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page <= 1}
                className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                <ChevronLeft className="h-3.5 w-3.5" /> Previous
              </button>
              <span className="px-2 tabular-nums font-semibold text-foreground">
                {page} / {totalPages}
              </span>
              <button
                type="button"
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={page >= totalPages}
                className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs font-medium text-foreground hover:bg-accent disabled:opacity-40 disabled:pointer-events-none shadow-2xs transition-colors"
              >
                Next <ChevronRight className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>
        </div>
      </div>
      </div>

      {/* Upload assignment modal */}
      {uploadedFile && (
        <UploadAssignmentModal
          file={uploadedFile}
          categories={categories}
          isUploading={isUploading}
          onAssign={handleAssignCategory}
          onCancel={() => setUploadedFile(null)}
        />
      )}

      {/* Delete confirmation modal */}
      {pendingDeleteDoc && (
        <DeleteConfirmDialog
          document={pendingDeleteDoc}
          isDeleting={isDeleting}
          onConfirm={handleConfirmDelete}
          onCancel={() => setPendingDeleteDoc(null)}
        />
      )}

      {/* Document Access Logs Modal (Web Word Collaborative Style) */}
      {showLog && (
        <DocumentAccessLogModal
          summaries={accessSummaries}
          isLoading={isLoadingAccessSummaries}
          onClose={() => setShowLog(false)}
          onDownloadDoc={handleDownload}
        />
      )}
    </AppShell>
  );
}
export default MyOrgPage;
