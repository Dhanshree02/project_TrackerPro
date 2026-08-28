import { useRef, useState } from "react";
import {
  Download,
  Upload,
  FileSpreadsheet,
  X,
  UploadCloud,
  FileCheck2,
  RefreshCw,
} from "lucide-react";
import { toast } from "sonner";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  downloadEmployeeBulkSample,
  uploadEmployeeBulk,
} from "@/lib/api/employees";
import { cn } from "@/lib/utils";

export function EmployeeBulkUploadMenu({
  onImported,
  className,
}: {
  onImported: () => void;
  className?: string;
}) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [downloadingSample, setDownloadingSample] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleDownloadSample = async () => {
    setDownloadingSample(true);
    try {
      await downloadEmployeeBulkSample();
      toast.success("Sample Excel template downloaded successfully");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to download sample file";
      toast.error(message);
    } finally {
      setDownloadingSample(false);
    }
  };

  const handleFileSelect = (file: File | undefined) => {
    if (!file) return;

    const ext = file.name.split(".").pop()?.toLowerCase();
    if (ext !== "xlsx") {
      toast.error("Invalid file format. Please attach an Excel (.xlsx) file.");
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      toast.error("File is too large. Maximum size allowed is 5 MB.");
      return;
    }

    setSelectedFile(file);
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      toast.error("Please attach an Excel (.xlsx) file first.");
      return;
    }

    setUploading(true);

    try {
      const result = await uploadEmployeeBulk(selectedFile);

      if (result.created > 0) {
        onImported();
        toast.success(
          `${result.created} resource${result.created === 1 ? "" : "s"} successfully imported!`,
        );
      }

      if (result.errors && result.errors.length > 0) {
        if (result.created === 0) {
          toast.error("No resources were imported. Check Excel data and try again.");
        } else {
          toast.warning(
            `${result.created} imported, ${result.failed} row${result.failed === 1 ? "" : "s"} skipped due to duplicate or invalid data.`,
          );
        }
      }

      if (result.created > 0 || (result.errors && result.errors.length > 0)) {
        setIsOpen(false);
        resetModal();
      }
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to upload and import file";
      toast.error(message);
    } finally {
      setUploading(false);
    }
  };

  const resetModal = () => {
    setSelectedFile(null);
    setIsDragging(false);
    if (fileInputRef.current) fileInputRef.current.value = "";
  };

  return (
    <>
      {/* Trigger Button */}
      <button
        type="button"
        onClick={() => {
          resetModal();
          setIsOpen(true);
        }}
        className={cn(
          "inline-flex items-center gap-2 rounded-md border border-input bg-card px-3.5 py-2 text-sm font-medium text-foreground hover:bg-accent shadow-2xs transition-colors cursor-pointer",
          className,
        )}
      >
        <Upload className="h-4 w-4 text-primary" />
        <span>Bulk Upload</span>
      </button>

      {/* Pop-out Modal Window */}
      <Dialog
        open={isOpen}
        onOpenChange={(open) => {
          setIsOpen(open);
          if (!open) resetModal();
        }}
      >
        <DialogContent className="max-w-xl p-0 overflow-hidden border-border bg-card shadow-2xl rounded-xl">
          {/* Header */}
          <div className="border-b border-border/80 bg-muted/40 px-6 py-4">
            <DialogHeader className="space-y-1">
              <div className="flex items-center gap-2.5">
                <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary">
                  <FileSpreadsheet className="h-4 w-4" />
                </span>
                <DialogTitle className="text-base font-semibold text-foreground">
                  Bulk Upload Resources
                </DialogTitle>
              </div>
              <DialogDescription className="text-xs text-muted-foreground">
                Import multiple resource records at once using the pre-formatted Excel template.
              </DialogDescription>
            </DialogHeader>
          </div>

          <div className="p-6 space-y-5">
            {/* Step 1: Download Sample Template */}
            <div className="rounded-lg border border-border/90 bg-muted/20 p-4">
              <div className="flex items-center justify-between gap-3">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <span className="flex h-5 w-5 items-center justify-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
                      1
                    </span>
                    <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">
                      Download Sample Template
                    </h4>
                  </div>
                  <p className="text-xs text-muted-foreground">
                    Get the standard Excel (.xlsx) template with predefined headers and sample data.
                  </p>
                </div>

                <button
                  type="button"
                  onClick={() => void handleDownloadSample()}
                  disabled={downloadingSample || uploading}
                  className="inline-flex shrink-0 items-center gap-1.5 rounded-md border border-primary/40 bg-primary/10 px-3 py-1.5 text-xs font-semibold text-primary hover:bg-primary/20 transition-colors cursor-pointer disabled:opacity-50 shadow-2xs"
                >
                  <Download className="h-3.5 w-3.5" />
                  {downloadingSample ? "Downloading…" : "Download Sample (.xlsx)"}
                </button>
              </div>
            </div>

            {/* Step 2: Drag & Drop Upload Dropzone */}
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="flex h-5 w-5 items-center justify-center rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
                    2
                  </span>
                  <h4 className="text-xs font-semibold uppercase tracking-wider text-foreground">
                    Attach Excel File
                  </h4>
                </div>
                <span className="text-[10px] text-muted-foreground">Max 5 MB (.xlsx only)</span>
              </div>

              {/* Hidden File Input */}
              <input
                ref={fileInputRef}
                type="file"
                accept=".xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                className="hidden"
                onChange={(e) => handleFileSelect(e.target.files?.[0])}
              />

              {/* Dropzone Container */}
              <div
                onDragOver={(e) => {
                  e.preventDefault();
                  setIsDragging(true);
                }}
                onDragLeave={() => setIsDragging(false)}
                onDrop={(e) => {
                  e.preventDefault();
                  setIsDragging(false);
                  handleFileSelect(e.dataTransfer.files?.[0]);
                }}
                onClick={() => !selectedFile && fileInputRef.current?.click()}
                className={cn(
                  "relative flex flex-col items-center justify-center rounded-lg border-2 border-dashed p-6 text-center transition-all cursor-pointer",
                  isDragging
                    ? "border-primary bg-primary/10 scale-[1.01]"
                    : selectedFile
                      ? "border-success/60 bg-success/5 cursor-default"
                      : "border-border/90 bg-muted/10 hover:bg-muted/30 hover:border-primary/50",
                )}
              >
                {selectedFile ? (
                  <div className="flex w-full items-center justify-between gap-3 text-left">
                    <div className="flex items-center gap-3 min-w-0">
                      <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-success/15 text-success">
                        <FileCheck2 className="h-6 w-6" />
                      </span>
                      <div className="min-w-0">
                        <p className="truncate text-xs font-semibold text-foreground">
                          {selectedFile.name}
                        </p>
                        <p className="text-[11px] text-muted-foreground">
                          {(selectedFile.size / 1024).toFixed(1)} KB · Ready to import
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-2 shrink-0">
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          fileInputRef.current?.click();
                        }}
                        className="inline-flex items-center gap-1 rounded-md border border-input bg-card px-2.5 py-1 text-xs font-medium text-muted-foreground hover:text-foreground hover:bg-accent transition-colors cursor-pointer"
                        title="Change file"
                      >
                        <RefreshCw className="h-3 w-3" /> Change
                      </button>
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedFile(null);
                          if (fileInputRef.current) fileInputRef.current.value = "";
                        }}
                        className="rounded-md p-1 hover:bg-destructive/10 hover:text-destructive text-muted-foreground transition-colors cursor-pointer"
                        title="Remove file"
                      >
                        <X className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                ) : (
                  <div className="py-2 space-y-2">
                    <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 text-primary">
                      <UploadCloud className="h-5 w-5 animate-pulse" />
                    </div>
                    <div className="space-y-1">
                      <p className="text-xs font-medium text-foreground">
                        Drag and drop your Excel file here, or{" "}
                        <span className="text-primary font-semibold underline underline-offset-2">
                          browse
                        </span>
                      </p>
                      <p className="text-[11px] text-muted-foreground">
                        Supports standard Microsoft Excel (.xlsx) workbooks up to 5 MB
                      </p>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Footer Action Bar */}
          <div className="flex items-center justify-between border-t border-border bg-muted/20 px-6 py-4">
            <button
              type="button"
              onClick={() => setIsOpen(false)}
              disabled={uploading}
              className="rounded-md border border-input bg-card px-4 py-2 text-xs font-medium text-foreground hover:bg-accent transition-colors cursor-pointer disabled:opacity-50"
            >
              Cancel
            </button>

            <button
              type="button"
              disabled={!selectedFile || uploading}
              onClick={() => void handleUpload()}
              className="inline-flex items-center gap-1.5 rounded-md bg-primary px-5 py-2 text-xs font-semibold text-primary-foreground hover:bg-primary/90 disabled:opacity-50 transition-colors shadow-2xs cursor-pointer"
            >
              {uploading ? (
                <>
                  <RefreshCw className="h-3.5 w-3.5 animate-spin" />
                  Importing Resources…
                </>
              ) : (
                <>
                  <Upload className="h-3.5 w-3.5" />
                  Upload & Import Resources
                </>
              )}
            </button>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}
