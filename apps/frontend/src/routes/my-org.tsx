import { createFileRoute, Navigate } from "@tanstack/react-router";
import { useRef, useState } from "react";
import {
  Upload,
  Search,
  Folder,
  FolderOpen,
  FileText,
  ChevronLeft,
  ChevronRight,
  X,
  Code2,
  ClipboardList,
  type LucideIcon,
} from "lucide-react";
import { AppShell } from "@/components/app-shell";
import { useRoleContext } from "@/lib/role-context";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/my-org")({
  head: () => ({
    meta: [
      { title: "My Org — Pulse PMO" },
      {
        name: "description",
        content:
          "Organization documents, Standard Operating Procedures, and policy resources.",
      },
    ],
  }),
  component: MyOrgRoute,
});

function MyOrgRoute() {
  const { isDhanshree } = useRoleContext();
  if (!isDhanshree) return <Navigate to="/" />;
  return <MyOrgPage />;
}

// ─── Types ────────────────────────────────────────────────────────────────────

type AccentColor = "blue" | "purple" | "green" | "amber";

interface OrgCategory {
  id: string;
  name: string;
  description: string;
  iconName: string;
  accentColor: AccentColor;
}

interface OrgDocument {
  id: string;
  name: string;
  categoryId: string;
  /** File size in bytes */
  size: number;
  /** File extension, e.g. "pdf", "docx" */
  fileType: string;
  /** ISO date string YYYY-MM-DD */
  lastUpdated: string;
  uploadedBy: string;
}

// ─── Seed Data ────────────────────────────────────────────────────────────────

const seedCategories: OrgCategory[] = [
  {
    id: "tech-sops",
    name: "Tech. SOPs",
    description: "Technical Standard Operating Procedures for engineering and infrastructure.",
    iconName: "Code2",
    accentColor: "blue",
  },
  {
    id: "pms-sops",
    name: "PMS. SOPs",
    description: "Project Management System Standard Operating Procedures.",
    iconName: "ClipboardList",
    accentColor: "purple",
  },
  {
    id: "policy-docs",
    name: "IMP Templates",
    description: "Important templates, company-wide policies, guidelines, and compliance documents.",
    iconName: "FileText",
    accentColor: "green",
  },
];

const seedDocuments: OrgDocument[] = [
  // ── Tech. SOPs ──
  { id: "doc-001", name: "API Gateway Configuration Guide.pdf", categoryId: "tech-sops", size: 2457600, fileType: "pdf", lastUpdated: "2026-06-10", uploadedBy: "Rahul Gupta" },
  { id: "doc-002", name: "CI-CD Pipeline Setup Procedures.docx", categoryId: "tech-sops", size: 1048576, fileType: "docx", lastUpdated: "2026-05-22", uploadedBy: "Vikram Shah" },
  { id: "doc-003", name: "Database Backup and Recovery SOP.pdf", categoryId: "tech-sops", size: 3145728, fileType: "pdf", lastUpdated: "2026-04-15", uploadedBy: "Aarav Mehta" },
  { id: "doc-004", name: "Security Incident Response Plan.pdf", categoryId: "tech-sops", size: 1572864, fileType: "pdf", lastUpdated: "2026-06-01", uploadedBy: "Rahul Gupta" },
  // ── PMS. SOPs ──
  { id: "doc-005", name: "Project Onboarding Checklist.pdf", categoryId: "pms-sops", size: 524288, fileType: "pdf", lastUpdated: "2026-06-12", uploadedBy: "Riya Kapoor" },
  { id: "doc-006", name: "WBS Creation Guidelines.docx", categoryId: "pms-sops", size: 786432, fileType: "docx", lastUpdated: "2026-05-30", uploadedBy: "Aarav Mehta" },
  { id: "doc-007", name: "Timesheet Submission Process.pdf", categoryId: "pms-sops", size: 409600, fileType: "pdf", lastUpdated: "2026-04-20", uploadedBy: "Riya Kapoor" },
  { id: "doc-008", name: "Resource Allocation SOP.pdf", categoryId: "pms-sops", size: 655360, fileType: "pdf", lastUpdated: "2026-06-05", uploadedBy: "Rahul Gupta" },
  { id: "doc-009", name: "Change Request Management Process.docx", categoryId: "pms-sops", size: 327680, fileType: "docx", lastUpdated: "2026-05-18", uploadedBy: "Aarav Mehta" },
  // ── IMP Templates ──
  { id: "doc-010", name: "Code of Conduct 2026.pdf", categoryId: "policy-docs", size: 1048576, fileType: "pdf", lastUpdated: "2026-01-05", uploadedBy: "Vikrant Malhotra" },
  { id: "doc-011", name: "Remote Work Policy.pdf", categoryId: "policy-docs", size: 614400, fileType: "pdf", lastUpdated: "2026-03-10", uploadedBy: "Vikrant Malhotra" },
  { id: "doc-012", name: "Data Privacy and GDPR Guidelines.pdf", categoryId: "policy-docs", size: 2097152, fileType: "pdf", lastUpdated: "2026-02-14", uploadedBy: "Anita Desai" },
  { id: "doc-013", name: "Leave and Attendance Policy.pdf", categoryId: "policy-docs", size: 819200, fileType: "pdf", lastUpdated: "2026-04-01", uploadedBy: "Anita Desai" },
];

// ─── Utilities ────────────────────────────────────────────────────────────────

function formatFileSize(bytes: number): string {
  if (bytes === 0) return "0 B";
  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB"] as const;
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(1))} ${sizes[i]}`;
}

function formatLastUpdated(iso: string): string {
  const d = new Date(iso);
  return d.toLocaleDateString("en-GB", { day: "2-digit", month: "short", year: "numeric" });
}

function filterDocuments(
  documents: OrgDocument[],
  categoryId: string | null,
  searchQuery: string,
): OrgDocument[] {
  const q = searchQuery.trim().toLowerCase();
  return documents.filter((doc) => {
    const matchesCategory = !categoryId || doc.categoryId === categoryId;
    const matchesSearch =
      !q ||
      doc.name.toLowerCase().includes(q) ||
      doc.uploadedBy.toLowerCase().includes(q) ||
      doc.fileType.toLowerCase().includes(q);
    return matchesCategory && matchesSearch;
  });
}

function generateDocumentId(): string {
  return `doc-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
}

function getTodayISO(): string {
  return new Date().toISOString().slice(0, 10);
}

function getFileExtension(filename: string): string {
  return filename.split(".").pop()?.toLowerCase() ?? "unknown";
}

// ─── Constants ────────────────────────────────────────────────────────────────

const PAGE_SIZE = 10;

const ICON_MAP: Record<string, LucideIcon> = {
  Code2,
  ClipboardList,
  FileText,
};

const ACCENT = {
  blue:   { bg: "bg-blue-500/10",    border: "border-blue-500/20",    icon: "text-blue-600 dark:text-blue-400",       count: "text-blue-700 dark:text-blue-300" },
  purple: { bg: "bg-purple-500/10",  border: "border-purple-500/20",  icon: "text-purple-600 dark:text-purple-400",   count: "text-purple-700 dark:text-purple-300" },
  green:  { bg: "bg-emerald-500/10", border: "border-emerald-500/20", icon: "text-emerald-600 dark:text-emerald-400", count: "text-emerald-700 dark:text-emerald-300" },
  amber:  { bg: "bg-amber-500/10",   border: "border-amber-500/20",   icon: "text-amber-600 dark:text-amber-400",     count: "text-amber-700 dark:text-amber-300" },
} as const;

const FILE_TYPE_COLORS: Record<string, string> = {
  pdf:  "text-red-500",
  docx: "text-blue-500",
  doc:  "text-blue-500",
  xlsx: "text-emerald-600",
  xls:  "text-emerald-600",
  pptx: "text-orange-500",
  ppt:  "text-orange-500",
  txt:  "text-muted-foreground",
  csv:  "text-teal-600",
};

const COL_HEADERS = ["File Name", "Category", "Size", "Last Updated", "Uploaded By"];

// ─── Sub-components ───────────────────────────────────────────────────────────

function CategoryCard({
  category,
  docCount,
  isActive,
  onClick,
  hideCount = false,
}: {
  category: OrgCategory;
  docCount: number;
  isActive: boolean;
  onClick: () => void;
  hideCount?: boolean;
}) {
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
      <div className={cn("flex h-8 w-8 items-center justify-center rounded-lg", accent.bg)}>
        <Icon className={cn("h-4 w-4", accent.icon)} />
      </div>
      <div>
        <p className="text-sm font-semibold leading-tight text-foreground">{category.name}</p>
        <p className="mt-0.5 text-[11px] leading-snug text-muted-foreground">{category.description}</p>
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
  documents,
  activeCategoryId,
  searchQuery,
  onSearchChange,
  onSelectCategory,
}: {
  categories: OrgCategory[];
  documents: OrgDocument[];
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
            count={documents.length}
            isActive={activeCategoryId === null}
            onClick={() => onSelectCategory(null)}
          />
          {categories.map((cat) => (
            <FolderItem
              key={cat.id}
              label={cat.name}
              count={documents.filter((d) => d.categoryId === cat.id).length}
              isActive={activeCategoryId === cat.id}
              onClick={() => onSelectCategory(cat.id)}
            />
          ))}
        </div>
      </div>
    </aside>
  );
}

function DocumentRow({ document, categories }: { document: OrgDocument; categories: OrgCategory[] }) {
  const category = categories.find((c) => c.id === document.categoryId);
  const iconColor = FILE_TYPE_COLORS[document.fileType.toLowerCase()] ?? "text-muted-foreground";

  return (
    <tr className="border-b border-border transition-colors last:border-0 hover:bg-accent/20">
      <td className="px-4 py-3">
        <div className="flex items-center gap-2.5">
          <FileText className={`h-4 w-4 shrink-0 ${iconColor}`} />
          <span className="text-sm font-medium text-foreground">{document.name}</span>
        </div>
      </td>
      <td className="whitespace-nowrap px-4 py-3">
        {category ? (
          <span className="inline-flex items-center rounded-full border border-border bg-muted px-2 py-0.5 text-[11px] font-medium text-muted-foreground">
            {category.name}
          </span>
        ) : (
          <span className="text-xs text-muted-foreground">—</span>
        )}
      </td>
      <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
        {formatFileSize(document.size)}
      </td>
      <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
        {formatLastUpdated(document.lastUpdated)}
      </td>
      <td className="whitespace-nowrap px-4 py-3 text-sm text-muted-foreground">
        {document.uploadedBy}
      </td>
    </tr>
  );
}

function DocumentTable({
  documents,
  categories,
  totalCount,
  page,
  totalPages,
  onPageChange,
}: {
  documents: OrgDocument[];
  categories: OrgCategory[];
  totalCount: number;
  page: number;
  totalPages: number;
  onPageChange: (p: number) => void;
}) {
  const from = totalCount === 0 ? 0 : (page - 1) * PAGE_SIZE + 1;
  const to = Math.min(page * PAGE_SIZE, totalCount);

  return (
    <div className="flex-1 overflow-x-auto rounded-xl border border-border bg-card shadow-sm">
      <table className="w-full text-sm">
        <thead className="bg-muted/40 text-left text-xs uppercase tracking-wide text-muted-foreground">
          <tr>
            {COL_HEADERS.map((h) => (
              <th key={h} className="whitespace-nowrap px-4 py-3 font-medium">
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-border">
          {documents.length === 0 ? (
            <tr>
              <td colSpan={COL_HEADERS.length} className="px-4 py-12 text-center text-sm text-muted-foreground">
                No documents found.
              </td>
            </tr>
          ) : (
            documents.map((doc) => (
              <DocumentRow key={doc.id} document={doc} categories={categories} />
            ))
          )}
        </tbody>
      </table>

      {/* Pagination footer */}
      <div className="flex items-center justify-between border-t border-border bg-muted/10 px-4 py-3 text-xs text-muted-foreground">
        <span>
          {totalCount === 0
            ? "No documents"
            : `Showing ${from}–${to} of ${totalCount} document${totalCount !== 1 ? "s" : ""}`}
        </span>
        <div className="flex items-center gap-1.5">
          <button
            onClick={() => onPageChange(Math.max(1, page - 1))}
            disabled={page <= 1}
            className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1.5 transition-colors hover:bg-accent disabled:cursor-not-allowed disabled:opacity-40"
          >
            <ChevronLeft className="h-3.5 w-3.5" /> Previous
          </button>
          <span className="px-2 font-medium tabular-nums">{page} / {totalPages}</span>
          <button
            onClick={() => onPageChange(Math.min(totalPages, page + 1))}
            disabled={page >= totalPages}
            className="inline-flex items-center gap-1 rounded-md border border-input px-2.5 py-1.5 transition-colors hover:bg-accent disabled:cursor-not-allowed disabled:opacity-40"
          >
            Next <ChevronRight className="h-3.5 w-3.5" />
          </button>
        </div>
      </div>
    </div>
  );
}

function UploadAssignmentModal({
  file,
  categories,
  onAssign,
  onCancel,
}: {
  file: File;
  categories: OrgCategory[];
  onAssign: (categoryId: string) => void;
  onCancel: () => void;
}) {
  const [selectedCategoryId, setSelectedCategoryId] = useState<string | null>(null);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/40 backdrop-blur-[1px]" onClick={onCancel} />

      {/* Modal */}
      <div
        className="relative w-full max-w-lg rounded-xl border border-border bg-card p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-start justify-between border-b border-border pb-4">
          <div>
            <h2 className="text-base font-semibold text-foreground">Assign Document to Category</h2>
            <p className="mt-0.5 text-xs text-muted-foreground">
              Select a category for this file before uploading.
            </p>
          </div>
          <button
            onClick={onCancel}
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
        <div className="grid grid-cols-2 gap-3">
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
            onClick={onCancel}
            className="rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={() => selectedCategoryId && onAssign(selectedCategoryId)}
            disabled={!selectedCategoryId}
            className="rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground shadow-sm transition-all hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-40"
          >
            Upload Document
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Page Component ───────────────────────────────────────────────────────────

function MyOrgPage() {
  const categories = [...seedCategories];
  const [documents, setDocuments] = useState<OrgDocument[]>([...seedDocuments]);

  const [activeCategoryId, setActiveCategoryId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [page, setPage] = useState(1);
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);

  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleUploadClick = () => fileInputRef.current?.click();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) setUploadedFile(file);
    e.target.value = "";
  };

  const handleAssignCategory = (categoryId: string) => {
    if (!uploadedFile) return;
    const newDoc: OrgDocument = {
      id: generateDocumentId(),
      name: uploadedFile.name,
      categoryId,
      size: uploadedFile.size,
      fileType: getFileExtension(uploadedFile.name),
      lastUpdated: getTodayISO(),
      uploadedBy: "Admin",
    };
    setDocuments((prev) => [newDoc, ...prev]);
    setUploadedFile(null);
    setActiveCategoryId(categoryId);
    setPage(1);
  };

  const handleSelectCategory = (id: string | null) => {
    setActiveCategoryId(id);
    setPage(1);
  };

  const handleSearchChange = (v: string) => {
    setSearchQuery(v);
    setPage(1);
  };

  const filteredDocs = filterDocuments(documents, activeCategoryId, searchQuery);
  const totalPages = Math.max(1, Math.ceil(filteredDocs.length / PAGE_SIZE));
  const currentPage = Math.min(page, totalPages);
  const pagedDocs = filteredDocs.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  return (
    <AppShell title="My Org" subtitle="Organization documents, SOPs & policies">
      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        className="hidden"
        onChange={handleFileChange}
        accept=".pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx,.txt,.csv"
      />

      {/* Action header */}
      <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
        <p className="text-xs text-muted-foreground">
          Manage organizational documents, SOPs, and policy resources.
        </p>
        <button
          onClick={handleUploadClick}
          className="inline-flex items-center gap-2 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground shadow-sm transition-all hover:bg-primary/90"
        >
          <Upload className="h-4 w-4" />
          Upload Document
        </button>
      </div>

      {/* Category cards */}
      <div className="mb-5 grid grid-cols-2 gap-3 sm:grid-cols-4">
        {categories.map((cat) => (
          <CategoryCard
            key={cat.id}
            category={cat}
            docCount={documents.filter((d) => d.categoryId === cat.id).length}
            isActive={activeCategoryId === cat.id}
            onClick={() => handleSelectCategory(activeCategoryId === cat.id ? null : cat.id)}
          />
        ))}
      </div>

      {/* Main content: sidebar + table */}
      <div className="flex gap-4">
        <CategorySidebar
          categories={categories}
          documents={documents}
          activeCategoryId={activeCategoryId}
          searchQuery={searchQuery}
          onSearchChange={handleSearchChange}
          onSelectCategory={handleSelectCategory}
        />
        <DocumentTable
          documents={pagedDocs}
          categories={categories}
          totalCount={filteredDocs.length}
          page={currentPage}
          totalPages={totalPages}
          onPageChange={setPage}
        />
      </div>

      {/* Upload assignment modal */}
      {uploadedFile && (
        <UploadAssignmentModal
          file={uploadedFile}
          categories={categories}
          onAssign={handleAssignCategory}
          onCancel={() => setUploadedFile(null)}
        />
      )}
    </AppShell>
  );
}
