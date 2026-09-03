import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useEffect, useMemo, useRef, useState, useTransition } from "react";
import {
  Upload,
  Search,
  Folder,
  FolderOpen,
  FileText,
  FileSpreadsheet,
  Presentation,
  Image as ImageIcon,
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
  Eye,
  History,
  ExternalLink,
  type LucideIcon,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { DocumentContentViewer } from "@/modules/my-org/components/DocumentContentViewer";
import { openDocumentInNewTab } from "@/lib/document-tab-viewer";
import {
  fetchRepositoryDocuments,
  fetchRepositoryCategoryCounts,
  fetchRepositoryAccessSummaries,
  fetchDocumentLogs,
  uploadRepositoryDocument,
  deleteRepositoryDocument,
  recordRepositoryDocumentView,
  getRepositoryDownloadUrl,
  getRepositoryPreviewUrl,
  isAllowedRepositoryFile,
  fetchRepositoryDepartments,
  ALLOWED_REPOSITORY_EXTENSIONS,
  type RepositoryItem,
  type RepositoryActivityLog,
  type DocumentAccessSummary,
  type DocumentAccessEntry,
  type RepositoryDepartmentOption,
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
  docm: "text-blue-500",
  xlsx: "text-emerald-500",
  xls: "text-emerald-500",
  xlsm: "text-emerald-500",
  xlsb: "text-emerald-500",
  csv: "text-emerald-500",
  pptx: "text-amber-500",
  ppt: "text-amber-500",
  pptm: "text-amber-500",
  txt: "text-slate-500",
  png: "text-purple-500",
  jpg: "text-purple-500",
  jpeg: "text-purple-500",
};

function getFileIconInfo(fileName: string) {
  const ext = fileName.split(".").pop()?.toLowerCase() ?? "";
  switch (ext) {
    case "pdf":
      return { Icon: FileText, color: "text-red-500", bg: "bg-red-500/10", label: "PDF" };
    case "doc":
    case "docx":
    case "docm":
      return { Icon: FileText, color: "text-blue-500", bg: "bg-blue-500/10", label: "Word" };
    case "xls":
    case "xlsx":
    case "xlsm":
    case "xlsb":
    case "csv":
      return {
        Icon: FileSpreadsheet,
        color: "text-emerald-600 dark:text-emerald-400",
        bg: "bg-emerald-500/10",
        label: ext === "csv" ? "CSV" : "Excel",
      };
    case "ppt":
    case "pptx":
    case "pptm":
      return {
        Icon: Presentation,
        color: "text-amber-600 dark:text-amber-400",
        bg: "bg-amber-500/10",
        label: "PowerPoint",
      };
    case "png":
    case "jpg":
    case "jpeg":
    case "webp":
    case "gif":
    case "svg":
      return {
        Icon: ImageIcon,
        color: "text-purple-600 dark:text-purple-400",
        bg: "bg-purple-500/10",
        label: "Image",
      };
    default:
      return {
        Icon: FileText,
        color: "text-muted-foreground",
        bg: "bg-muted",
        label: ext.toUpperCase() || "File",
      };
  }
}

function isValidFileType(fileName: string): boolean {
  return isAllowedRepositoryFile(fileName);
}

function formatFileSize(bytes: number): string {
  if (!bytes || bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"] as const;
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i] || "B"}`;
}

function formatLastUpdated(iso: string): string {
  if (!iso) return "—";
  const d = new Date(iso);
  if (isNaN(d.getTime())) return "—";
  return d.toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function formatExactDateTime(iso: string): string {
  if (!iso) return "—";
  const d = new Date(iso);
  if (isNaN(d.getTime())) return "—";
  return d.toLocaleDateString("en-GB", {
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
  if (isNaN(d.getTime())) return "";
  const diffSec = Math.floor((Date.now() - d.getTime()) / 1000);
  if (diffSec < 60) return "just now";
  const diffMin = Math.floor(diffSec / 60);
  if (diffMin < 60) return `${diffMin}m ago`;
  const diffHr = Math.floor(diffMin / 60);
  if (diffHr < 24) return `${diffHr}h ago`;
  const diffDays = Math.floor(diffHr / 24);
  if (diffDays < 30) return `${diffDays}d ago`;
  return formatLastUpdated(iso);
}

const AVATAR_COLORS = [
  "bg-blue-500/15 text-blue-600 dark:text-blue-400 border border-blue-500/30",
  "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border border-emerald-500/30",
  "bg-purple-500/15 text-purple-600 dark:text-purple-400 border border-purple-500/30",
  "bg-amber-500/15 text-amber-600 dark:text-amber-400 border border-amber-500/30",
  "bg-rose-500/15 text-rose-600 dark:text-rose-400 border border-rose-500/30",
  "bg-indigo-500/15 text-indigo-600 dark:text-indigo-400 border border-indigo-500/30",
  "bg-cyan-500/15 text-cyan-600 dark:text-cyan-400 border border-cyan-500/30",
];

function getAvatarColorClass(name: string): string {
  if (!name) return AVATAR_COLORS[0];
  let hash = 0;
  for (let i = 0; i < name.length; i++) {
    hash = name.charCodeAt(i) + ((hash << 5) - hash);
  }
  const index = Math.abs(hash) % AVATAR_COLORS.length;
  return AVATAR_COLORS[index];
}

function getInitials(name: string): string {
  if (!name) return "?";
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
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

// ─── Single Document Logs & History Modal ───────────────────────────────────────
function SingleDocumentLogsModal({
  document,
  onClose,
  onDownload,
  onPreview,
}: {
  document: RepositoryItem;
  onClose: () => void;
  onDownload: (docId: string, fileName: string) => void;
  onPreview: (doc: RepositoryItem) => void;
}) {
  const [logs, setLogs] = useState<RepositoryActivityLog[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const fileInfo = getFileIconInfo(document.fileName);
  const FileIcon = fileInfo.Icon;

  useEffect(() => {
    let isMounted = true;
    setIsLoading(true);
    fetchDocumentLogs(document.id)
      .then((data) => {
        if (isMounted) setLogs(data || []);
      })
      .catch(() => {
        if (isMounted) setLogs([]);
      })
      .finally(() => {
        if (isMounted) setIsLoading(false);
      });
    return () => {
      isMounted = false;
    };
  }, [document.id]);

  const filteredLogs = useMemo(() => {
    if (!searchTerm.trim()) return logs;
    const term = searchTerm.toLowerCase();
    return logs.filter(
      (l) =>
        l.performedBy.toLowerCase().includes(term) ||
        l.action.toLowerCase().includes(term) ||
        (l.details && l.details.toLowerCase().includes(term)),
    );
  }, [logs, searchTerm]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-xs" onClick={onClose} />
      <div
        className="relative flex w-full max-w-2xl flex-col rounded-2xl border border-border bg-card shadow-2xl animate-in fade-in zoom-in-95 duration-150 overflow-hidden"
        style={{ maxHeight: "88vh" }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="border-b border-border bg-muted/20 px-6 py-4">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-3 min-w-0">
              <div className={cn("flex h-10 w-10 shrink-0 items-center justify-center rounded-xl", fileInfo.bg)}>
                <FileIcon className={cn("h-5 w-5", fileInfo.color)} />
              </div>
              <div className="min-w-0">
                <div className="flex items-center gap-2">
                  <h2 className="text-base font-semibold text-foreground truncate max-w-md" title={document.fileName}>
                    {document.fileName}
                  </h2>
                  <span className="shrink-0 rounded-full border border-border bg-muted px-2 py-0.5 text-[10px] font-semibold text-muted-foreground">
                    {document.category}
                  </span>
                </div>
                <p className="text-xs text-muted-foreground mt-0.5">
                  Uploaded by <strong className="font-medium text-foreground">{document.uploadedBy}</strong> · {formatFileSize(document.size)} · {formatLastUpdated(document.lastUpdated)}
                </p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="shrink-0 rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          {/* Search */}
          <div className="relative mt-3">
            <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
            <input
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Search by employee name or action..."
              className="h-8 w-full rounded-md border border-input bg-background pl-8 pr-3 text-xs outline-none focus-visible:ring-1 focus-visible:ring-ring"
            />
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-2">
          {isLoading ? (
            <div className="py-12 text-center text-sm text-muted-foreground">
              <div className="inline-flex items-center gap-2">
                <div className="h-4 w-4 animate-spin rounded-full border-2 border-primary border-t-transparent" />
                Loading activity history...
              </div>
            </div>
          ) : filteredLogs.length === 0 ? (
            <div className="py-12 text-center text-sm text-muted-foreground">
              No activity logs recorded for this document yet.
            </div>
          ) : (
            <div className="divide-y divide-border/60 rounded-xl border border-border/80 bg-card overflow-hidden">
              {filteredLogs.map((log) => {
                const isUpload = log.action === "Uploaded";
                const isDownload = log.action === "Downloaded";
                const isView = log.action === "Viewed";
                const isDelete = log.action === "Deleted";

                return (
                  <div
                    key={log.id}
                    className="flex items-center justify-between gap-3 px-4 py-3 text-xs hover:bg-muted/30 transition-colors"
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div
                        className={cn(
                          "flex h-7 w-7 items-center justify-center rounded-full text-[10px] font-bold shrink-0 shadow-xs",
                          getAvatarColorClass(log.performedBy),
                        )}
                      >
                        {getInitials(log.performedBy)}
                      </div>
                      <div className="min-w-0">
                        <p className="font-semibold text-foreground truncate">
                          {log.performedBy}
                        </p>
                        <p className="text-[11px] text-muted-foreground truncate">
                          {log.details || `${log.performedBy} ${log.action.toLowerCase()} this document`}
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
                              : isView
                                ? "bg-purple-500/10 text-purple-600 dark:text-purple-400 border border-purple-500/20"
                                : isDelete
                                  ? "bg-destructive/10 text-destructive border border-destructive/20"
                                  : "bg-muted text-muted-foreground",
                        )}
                      >
                        {log.action}
                      </span>
                      <div className="text-right">
                        <p className="font-medium text-foreground tabular-nums text-[11px]">
                          {formatExactDateTime(log.createdAtUtc)}
                        </p>
                        <p className="text-[10px] text-muted-foreground">
                          {formatRelativeTime(log.createdAtUtc)}
                        </p>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Footer with Quick Actions */}
        <div className="flex items-center justify-between border-t border-border bg-muted/10 px-6 py-3">
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => onPreview(document)}
              className="inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium text-foreground hover:bg-accent transition-colors shadow-2xs"
            >
              <Eye className="h-3.5 w-3.5 text-primary" />
              Preview
            </button>
            <button
              type="button"
              onClick={() => onDownload(document.id, document.fileName)}
              className="inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium text-foreground hover:bg-accent transition-colors shadow-2xs"
            >
              <Download className="h-3.5 w-3.5 text-emerald-600" />
              Download
            </button>
          </div>
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

// ─── Document Preview Modal ───────────────────────────────────────────────────
function DocumentPreviewModal({
  document,
  onClose,
  onDownload,
}: {
  document: RepositoryItem;
  onClose: () => void;
  onDownload: (docId: string, fileName: string) => void;
}) {
  const ext = document.fileName.split(".").pop()?.toLowerCase() ?? "";
  const isPdf = ext === "pdf" || ["pptx", "ppt", "pptm"].includes(ext);
  const isImage = ["png", "jpg", "jpeg", "webp", "gif", "svg"].includes(ext);
  const isOfficeDoc = [
    "docx",
    "doc",
    "docm",
    "xlsx",
    "xls",
    "xlsm",
    "xlsb",
    "csv",
  ].includes(ext);
  const isText = ["txt", "log", "json", "xml", "md"].includes(ext);
  const previewUrl = getRepositoryPreviewUrl(document.id);
  const fileInfo = getFileIconInfo(document.fileName);
  const FileIcon = fileInfo.Icon;

  const [textContent, setTextContent] = useState<string | null>(null);
  const [isLoadingText, setIsLoadingText] = useState(isText);

  useEffect(() => {
    if (isText) {
      setIsLoadingText(true);
      fetch(previewUrl)
        .then((res) => (res.ok ? res.text() : Promise.reject(new Error("Failed to load text"))))
        .then((txt) => setTextContent(txt))
        .catch(() => setTextContent(null))
        .finally(() => setIsLoadingText(false));
    }
  }, [isText, previewUrl]);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-xs" onClick={onClose} />
      <div
        className={cn(
          "relative flex w-full flex-col rounded-2xl border border-border bg-card shadow-2xl animate-in fade-in zoom-in-95 duration-150 overflow-hidden",
          isPdf || isOfficeDoc ? "max-w-5xl h-[90vh]" : isImage ? "max-w-3xl max-h-[88vh]" : "max-w-3xl max-h-[85vh]",
        )}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between border-b border-border bg-muted/20 px-5 py-3.5 shrink-0">
          <div className="flex items-center gap-3 min-w-0">
            <div className={cn("flex h-8 w-8 shrink-0 items-center justify-center rounded-lg", fileInfo.bg)}>
              <FileIcon className={cn("h-4 w-4", fileInfo.color)} />
            </div>
            <div className="min-w-0">
              <h2 className="text-sm font-semibold text-foreground truncate max-w-md" title={document.fileName}>
                {document.fileName}
              </h2>
              <p className="text-[11px] text-muted-foreground">
                {fileInfo.label} · {formatFileSize(document.size)} · {document.category}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2 shrink-0">
            <button
              type="button"
              onClick={() => {
                void openDocumentInNewTab(document);
              }}
              className="inline-flex items-center gap-1.5 rounded-md border border-input bg-card px-3 py-1.5 text-xs font-medium text-foreground hover:bg-accent transition-colors shadow-2xs cursor-pointer"
              title="Open full document in a new browser tab"
            >
              <ExternalLink className="h-3.5 w-3.5" />
              Open in Tab
            </button>
            <button
              type="button"
              onClick={() => onDownload(document.id, document.fileName)}
              className="inline-flex items-center gap-1.5 rounded-md bg-primary px-3 py-1.5 text-xs font-medium text-primary-foreground hover:bg-primary/90 transition-colors shadow-2xs cursor-pointer"
            >
              <Download className="h-3.5 w-3.5" />
              Download
            </button>
            <button
              onClick={onClose}
              className="rounded-lg p-1.5 text-muted-foreground transition-colors hover:bg-accent hover:text-foreground cursor-pointer"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>

        {/* Content Body */}
        <div className="flex-1 overflow-auto bg-muted/10 flex items-stretch justify-center min-h-[300px]">
          {isPdf ? (
            <div className="w-full h-full p-3">
              <iframe
                src={`${previewUrl}#toolbar=1`}
                title={document.fileName}
                className="w-full h-full min-h-[520px] rounded-lg border border-border bg-white shadow-xs"
              />
            </div>
          ) : isImage ? (
            <div className="flex items-center justify-center p-4">
              <img
                src={previewUrl}
                alt={document.fileName}
                className="max-h-[68vh] max-w-full rounded-lg border border-border object-contain shadow-sm bg-background"
              />
            </div>
          ) : isOfficeDoc ? (
            <DocumentContentViewer
              previewUrl={previewUrl}
              fileName={document.fileName}
              onDownload={() => onDownload(document.id, document.fileName)}
            />
          ) : isText ? (
            <div className="w-full p-4">
              {isLoadingText ? (
                <div className="py-12 text-center text-sm text-muted-foreground">
                  <div className="inline-flex items-center gap-2">
                    <div className="h-4 w-4 animate-spin rounded-full border-2 border-primary border-t-transparent" />
                    Loading document preview...
                  </div>
                </div>
              ) : textContent !== null ? (
                <div className="w-full h-full max-h-[60vh] overflow-auto rounded-lg border border-border bg-background p-4 font-mono text-xs text-foreground whitespace-pre-wrap">
                  {textContent}
                </div>
              ) : (
                <div className="text-center py-8 text-sm text-muted-foreground">
                  Failed to load text preview. Please use the Download button.
                </div>
              )}
            </div>
          ) : (
            <div className="w-full max-w-md rounded-2xl border border-border bg-card p-6 shadow-sm text-center my-auto">
              <div className={cn("mx-auto flex h-16 w-16 items-center justify-center rounded-2xl", fileInfo.bg, "mb-4")}>
                <FileIcon className={cn("h-8 w-8", fileInfo.color)} />
              </div>
              <h3 className="text-base font-semibold text-foreground truncate px-2" title={document.fileName}>
                {document.fileName}
              </h3>
              <p className="text-xs text-muted-foreground mt-1">
                {fileInfo.label} Document · {formatFileSize(document.size)}
              </p>
              <div className="my-5 rounded-xl border border-border/80 bg-muted/30 p-3 text-left text-xs space-y-1.5">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Category:</span>
                  <span className="font-semibold text-foreground">{document.category}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Uploaded By:</span>
                  <span className="font-semibold text-foreground">{document.uploadedBy}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Last Updated:</span>
                  <span className="font-semibold text-foreground">{formatExactDateTime(document.lastUpdated)}</span>
                </div>
              </div>
              <div className="flex items-center justify-center gap-3">
                <button
                  type="button"
                  onClick={() => {
                    void openDocumentInNewTab(document);
                  }}
                  className="inline-flex items-center gap-2 rounded-lg border border-input bg-card px-4 py-2 text-sm font-medium text-foreground shadow-sm hover:bg-accent transition-all cursor-pointer"
                >
                  <ExternalLink className="h-4 w-4" />
                  Open in Tab
                </button>
                <button
                  type="button"
                  onClick={() => onDownload(document.id, document.fileName)}
                  className="inline-flex items-center gap-2 rounded-lg bg-primary px-5 py-2 text-sm font-medium text-primary-foreground shadow-sm hover:bg-primary/90 transition-all cursor-pointer"
                >
                  <Download className="h-4 w-4" />
                  Download File
                </button>
              </div>
            </div>
          )}
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
  onAssign: (categoryId: string, departmentIds: string[]) => void;
  onCancel: () => void;
}) {
  const [selectedCategoryId, setSelectedCategoryId] = useState<string | null>("tech-sops");
  const [departments, setDepartments] = useState<RepositoryDepartmentOption[]>([]);
  const [selectedDeptIds, setSelectedDeptIds] = useState<Set<string>>(new Set());
  const [departmentsLoading, setDepartmentsLoading] = useState(true);
  const [departmentsError, setDepartmentsError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setDepartmentsLoading(true);
    setDepartmentsError(null);
    fetchRepositoryDepartments()
      .then((rows) => {
        if (cancelled) return;
        setDepartments(rows);
        if (rows.length === 0) {
          setDepartmentsError("No active departments found. Add departments in Resources first.");
        }
      })
      .catch((err) => {
        if (cancelled) return;
        setDepartmentsError(err instanceof Error ? err.message : "Could not load departments.");
      })
      .finally(() => {
        if (!cancelled) setDepartmentsLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, []);

  const toggleDept = (id: string) => {
    setSelectedDeptIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const allSelected = departments.length > 0 && selectedDeptIds.size === departments.length;

  const canSubmit = Boolean(selectedCategoryId) && selectedDeptIds.size > 0 && !isUploading && !departmentsLoading;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/40 backdrop-blur-[1px]" onClick={onCancel} />
      <div
        className="relative w-full max-w-lg rounded-xl border border-border bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150 max-h-[92vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-start justify-between border-b border-border pb-4">
          <div>
            <h2 className="text-base font-semibold text-foreground">Assign Document to Category</h2>
            <p className="mt-0.5 text-xs text-muted-foreground">
              Choose a category and the departments that may view this file.
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

        {/* Department checklist */}
        <div className="mt-4">
          <div className="mb-2 flex items-center justify-between gap-2">
            <p className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
              Visible to departments
            </p>
            {departments.length > 0 && (
              <button
                type="button"
                disabled={isUploading}
                onClick={() =>
                  setSelectedDeptIds(allSelected ? new Set() : new Set(departments.map((d) => d.id)))
                }
                className="text-[11px] font-medium text-primary hover:underline cursor-pointer"
              >
                {allSelected ? "Clear all" : "Select all"}
              </button>
            )}
          </div>
          <div className="max-h-48 overflow-y-auto rounded-lg border border-border bg-muted/20 p-2">
            {departmentsLoading ? (
              <p className="px-2 py-3 text-xs text-muted-foreground">Loading departments…</p>
            ) : departmentsError ? (
              <p className="px-2 py-3 text-xs text-destructive">{departmentsError}</p>
            ) : (
              <ul className="space-y-0.5">
                {departments.map((dept) => {
                  const checked = selectedDeptIds.has(dept.id);
                  return (
                    <li key={dept.id}>
                      <label className="flex cursor-pointer items-center gap-2 rounded-md px-2 py-1.5 text-sm hover:bg-accent/60">
                        <input
                          type="checkbox"
                          checked={checked}
                          disabled={isUploading}
                          onChange={() => toggleDept(dept.id)}
                          className="h-3.5 w-3.5 rounded border-input accent-primary"
                        />
                        <span className="truncate text-foreground">{dept.name}</span>
                      </label>
                    </li>
                  );
                })}
              </ul>
            )}
          </div>
          {!departmentsLoading && !departmentsError && selectedDeptIds.size === 0 && (
            <p className="mt-1.5 text-[11px] text-muted-foreground">
              Check at least one department. Only people in those departments will see this document.
            </p>
          )}
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
            disabled={!canSubmit}
            onClick={() =>
              selectedCategoryId && onAssign(selectedCategoryId, Array.from(selectedDeptIds))
            }
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

  // Per-document History Logs modal state
  const [selectedDocForLogs, setSelectedDocForLogs] = useState<RepositoryItem | null>(null);

  // Document Preview modal state
  const [selectedDocForPreview, setSelectedDocForPreview] = useState<RepositoryItem | null>(null);

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

  useEffect(() => {
    void loadCategories();
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
        description:
          "Allowed formats: PDF (.pdf), Word (.doc, .docx), Excel (.xls, .xlsx, .xlsm, .csv), and PowerPoint (.ppt, .pptx).",
      });
      return;
    }

    setUploadedFile(file);
  };

  const handleAssignCategory = async (categoryId: string, departmentIds: string[]) => {
    if (!uploadedFile) return;
    if (departmentIds.length === 0) {
      toast.error("Select at least one department");
      return;
    }
    setIsUploading(true);
    try {
      const catMeta = categories.find((c) => c.id === categoryId);
      const backendCategory = catMeta?.backendKey ?? "Tech";

      await uploadRepositoryDocument(
        uploadedFile,
        backendCategory,
        user?.name || "Admin",
        departmentIds,
      );

      toast.success("Document uploaded successfully!");
      setUploadedFile(null);
      void loadCategories();
      void loadDocuments();
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

  const handlePreviewDoc = async (doc: RepositoryItem) => {
    setSelectedDocForPreview(doc);
    try {
      await recordRepositoryDocumentView(doc.id, user?.name || "Employee");
    } catch {
      // Best-effort
    }
  };

  const handleOpenDocLogs = (doc: RepositoryItem) => {
    setSelectedDocForLogs(doc);
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

  const canDeleteDoc = (doc: RepositoryItem) =>
    isDhanshree || doc.uploadedBy === user?.name || doc.uploadedBy === user?.email;

  const totalRepoDocuments = categories.reduce((sum, c) => sum + c.count, 0);

  return (
    <AppShell title="Repository" subtitle="Organization documents, SOPs & policies">
      {/* Hidden file input supporting PDF, Word, Excel, PowerPoint, Text, Image formats */}
      <input
        ref={fileInputRef}
        type="file"
        className="hidden"
        onChange={handleFileChange}
        accept=".pdf,.doc,.docx,.docm,.xls,.xlsx,.xlsm,.xlsb,.csv,.ppt,.pptx,.pptm,.txt,.png,.jpg,.jpeg,application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/vnd.ms-powerpoint,application/vnd.openxmlformats-officedocument.presentationml.presentation,text/csv,text/plain"
      />

      {/* Action header */}
      <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
        <p className="text-xs text-muted-foreground">
          Manage organizational documents, SOPs, and policy resources.
        </p>
        <div className="flex items-center gap-2">
          {!isReadOnlyViewer && (
            <button
              type="button"
              onClick={handleUploadClick}
              className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground shadow-sm transition-all hover:bg-primary/90"
            >
              <Upload className="h-4 w-4" />
              Upload Document
            </button>
          )}
        </div>
      </div>

      {/* Category cards */}
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
                    <th className="px-4 py-3 font-semibold">Departments</th>
                    <th className="px-4 py-3 font-semibold">Size</th>
                    <th className="px-4 py-3 font-semibold">Last Updated</th>
                    <th className="px-4 py-3 font-semibold">Uploaded By</th>
                    <th className="px-4 py-3 text-right font-semibold">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border">
                  {isLoading ? (
                    <tr>
                      <td colSpan={7} className="px-4 py-12 text-center text-sm text-muted-foreground">
                        Loading documents...
                      </td>
                    </tr>
                  ) : documents.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="px-4 py-12 text-center text-sm text-muted-foreground">
                        No documents found.
                      </td>
                    </tr>
                  ) : (
                    documents.map((doc) => {
                      const fileInfo = getFileIconInfo(doc.fileName);
                      const FileIcon = fileInfo.Icon;
                      const docExt = doc.fileName.split(".").pop()?.toLowerCase() ?? "";
                      const isOfficeDoc = [
                        "doc",
                        "docx",
                        "docm",
                        "xls",
                        "xlsx",
                        "xlsm",
                        "xlsb",
                        "ppt",
                        "pptx",
                        "pptm",
                      ].includes(docExt);

                      return (
                        <tr
                          key={doc.id}
                          className="border-b border-border transition-colors last:border-0 hover:bg-accent/20"
                        >
                          <td className="px-4 py-3">
                            <div className="flex items-center gap-2.5">
                              <div className={cn("flex h-7 w-7 shrink-0 items-center justify-center rounded-md", fileInfo.bg)}>
                                <FileIcon className={cn("h-4 w-4", fileInfo.color)} />
                              </div>
                              <span className="text-sm font-medium text-foreground truncate max-w-xs sm:max-w-sm" title={doc.fileName}>
                                {doc.fileName}
                              </span>
                            </div>
                          </td>
                          <td className="whitespace-nowrap px-4 py-3">
                            <span className="inline-flex items-center rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] font-medium text-muted-foreground">
                              {doc.category}
                            </span>
                          </td>
                          <td className="px-4 py-3 text-xs text-muted-foreground">
                            {doc.departments && doc.departments.length > 0 ? (
                              <span className="line-clamp-2" title={doc.departments.map((d) => d.name).join(", ")}>
                                {doc.departments.map((d) => d.name).join(", ")}
                              </span>
                            ) : (
                              <span className="text-muted-foreground/70">All</span>
                            )}
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
                            <div className="inline-flex items-center justify-end gap-1">
                              {/* 1. Preview Eye button */}
                              <button
                                type="button"
                                title={isOfficeDoc ? "Open in new tab" : "Preview document"}
                                onClick={() => handlePreviewDoc(doc)}
                                className="inline-flex items-center justify-center rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-primary/10 hover:text-primary"
                              >
                                <Eye className="h-4 w-4" />
                              </button>

                              {/* 2. View History / Logs button */}
                              <button
                                type="button"
                                title="View document history & logs"
                                onClick={() => handleOpenDocLogs(doc)}
                                className="inline-flex items-center justify-center rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-purple-500/10 hover:text-purple-600 dark:hover:text-purple-400"
                              >
                                <History className="h-4 w-4" />
                              </button>

                              {/* 3. Download button */}
                              <button
                                type="button"
                                title="Download document"
                                onClick={() => handleDownload(doc.id, doc.fileName)}
                                className="inline-flex items-center justify-center rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-emerald-500/10 hover:text-emerald-600 dark:hover:text-emerald-400"
                              >
                                <Download className="h-4 w-4" />
                              </button>

                              {/* 4. Delete button */}
                              {canDeleteDoc(doc) && (
                                <button
                                  type="button"
                                  title="Delete document"
                                  onClick={() => setPendingDeleteDoc(doc)}
                                  className="inline-flex items-center justify-center rounded-md p-1.5 text-muted-foreground transition-colors hover:bg-destructive/10 hover:text-destructive"
                                >
                                  <Trash2 className="h-4 w-4" />
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

      {/* Document-Specific History Logs Modal */}
      {selectedDocForLogs && (
        <SingleDocumentLogsModal
          document={selectedDocForLogs}
          onClose={() => setSelectedDocForLogs(null)}
          onDownload={handleDownload}
          onPreview={(doc) => {
            setSelectedDocForLogs(null);
            void handlePreviewDoc(doc);
          }}
        />
      )}

      {/* Document Preview Modal */}
      {selectedDocForPreview && (
        <DocumentPreviewModal
          document={selectedDocForPreview}
          onClose={() => setSelectedDocForPreview(null)}
          onDownload={handleDownload}
        />
      )}
    </AppShell>
  );
}
export default MyOrgPage;
