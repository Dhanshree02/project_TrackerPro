// ─── My Org Page ─────────────────────────────────────────────────────────────
// Composes all My Org components and owns all page-level state.
// Data is fetched exclusively through the service layer.

import { useRef, useState } from "react";
import { AppShell } from "@/components/app-shell";
import { myOrgService } from "./services/myOrgService";
import {
  filterDocuments,
  generateDocumentId,
  getFileExtension,
  getTodayISO,
} from "./utils";
import type { OrgDocument } from "./types";

import { MyOrgHeader } from "./components/MyOrgHeader";
import { CategoryCard } from "./components/CategoryCard";
import { CategorySidebar } from "./components/CategorySidebar";
import { DocumentTable, PAGE_SIZE } from "./components/DocumentTable";
import { UploadAssignmentModal } from "./components/UploadAssignmentModal";

export function MyOrgPage() {
  // ── Data from service layer ─────────────────────────────────────────────────
  const categories = myOrgService.getCategories();
  const [documents, setDocuments] = useState<OrgDocument[]>(
    myOrgService.getDocuments(),
  );

  // ── UI state ────────────────────────────────────────────────────────────────
  const [activeCategoryId, setActiveCategoryId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [page, setPage] = useState(1);
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);

  // ── Hidden file input ───────────────────────────────────────────────────────
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleUploadClick = () => fileInputRef.current?.click();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) setUploadedFile(file);
    // Reset so the same file can be re-selected next time
    e.target.value = "";
  };

  // ── Upload assignment ───────────────────────────────────────────────────────
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
    // Auto-navigate to the assigned folder
    setActiveCategoryId(categoryId);
    setPage(1);
  };

  const handleCancelUpload = () => setUploadedFile(null);

  // ── Category selection ──────────────────────────────────────────────────────
  const handleSelectCategory = (id: string | null) => {
    setActiveCategoryId(id);
    setPage(1);
  };

  // ── Filtering + pagination (derived) ───────────────────────────────────────
  const filteredDocs = filterDocuments(documents, activeCategoryId, searchQuery);
  const totalPages = Math.max(1, Math.ceil(filteredDocs.length / PAGE_SIZE));
  const currentPage = Math.min(page, totalPages);
  const pagedDocs = filteredDocs.slice(
    (currentPage - 1) * PAGE_SIZE,
    currentPage * PAGE_SIZE,
  );

  // ── Search change (also resets page) ───────────────────────────────────────
  const handleSearchChange = (v: string) => {
    setSearchQuery(v);
    setPage(1);
  };

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
      <MyOrgHeader onUploadClick={handleUploadClick} />

      {/* Category cards — clicking toggles active folder filter */}
      <div className="mb-5 grid grid-cols-2 gap-3 sm:grid-cols-4">
        {categories.map((cat) => (
          <CategoryCard
            key={cat.id}
            category={cat}
            docCount={documents.filter((d) => d.categoryId === cat.id).length}
            isActive={activeCategoryId === cat.id}
            onClick={() =>
              handleSelectCategory(activeCategoryId === cat.id ? null : cat.id)
            }
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
          onCancel={handleCancelUpload}
        />
      )}
    </AppShell>
  );
}
