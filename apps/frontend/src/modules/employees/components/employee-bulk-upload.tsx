import { useRef, useState } from "react";
import {
  Download,
  Upload,
  X,
  UploadCloud,
  FileCheck2,
  RefreshCw,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
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
} from "@/modules/employees/api/employees";
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

      if (result.errors && result.errors.length > 0) {
        const detail = result.errors
          .slice(0, 4)
          .map((entry) => `Row ${entry.row}: ${entry.message}`)
          .join(" ");
        toast.error("Nothing was uploaded. Fix every row and try again.", {
          description: detail || "One or more rows are not valid.",
        });
      } else if (result.created > 0) {
        onImported();
        toast.success(
          `${result.created} resource${result.created === 1 ? "" : "s"} successfully imported!`,
        );
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
        <DialogContent
          disableAnimation
          overlayClassName="!duration-0 !animate-none"
          className="max-w-xl gap-0 overflow-hidden rounded-[20px] border-border/70 bg-card p-0 shadow-2xl !duration-0 !animate-none"
        >
          <div className="px-6 pb-2 pt-6">
            <DialogHeader className="space-y-1.5 text-left">
              <DialogTitle className="text-[17px] font-semibold tracking-[-0.022em] text-foreground">
                Bulk Upload Resources
              </DialogTitle>
              <DialogDescription className="text-[13px] leading-snug text-muted-foreground">
                Import several people at once. The Login Access column chooses Employee and login or Employee only for each row.
              </DialogDescription>
            </DialogHeader>
          </div>

          <div className="space-y-6 px-6 py-5">
            <div className="flex items-start justify-between gap-4">
              <div className="min-w-0 space-y-1">
                <h4 className="text-[15px] font-semibold tracking-[-0.016em] text-foreground">
                  Download a sample
                </h4>
                <p className="text-[13px] leading-snug text-muted-foreground">
                  Start from the Excel template. It already has the column names and one example row.
                </p>
              </div>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() => void handleDownloadSample()}
                disabled={downloadingSample || uploading}
                className="shrink-0"
              >
                <Download />
                {downloadingSample ? "Downloading…" : "Download"}
              </Button>
            </div>

            <div className="space-y-2">
              <div className="flex items-baseline justify-between gap-3">
                <h4 className="text-[15px] font-semibold tracking-[-0.016em] text-foreground">
                  Add the file
                </h4>
                <span className="text-[13px] text-muted-foreground">Excel, up to 5 MB</span>
              </div>

              <input
                ref={fileInputRef}
                type="file"
                accept=".xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                className="hidden"
                onChange={(e) => handleFileSelect(e.target.files?.[0])}
              />

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
                  "flex min-h-36 flex-col items-center justify-center rounded-2xl border px-6 py-8 text-center",
                  isDragging
                    ? "border-primary bg-primary/10"
                    : selectedFile
                      ? "cursor-default border-border bg-muted/40"
                      : "cursor-pointer border-border bg-muted/30 hover:bg-muted/50",
                )}
              >
                {selectedFile ? (
                  <div className="flex w-full items-center justify-between gap-3 text-left">
                    <div className="flex min-w-0 items-center gap-3">
                      <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-success/15 text-success">
                        <FileCheck2 className="h-5 w-5" />
                      </span>
                      <div className="min-w-0">
                        <p className="truncate text-[15px] font-semibold tracking-[-0.016em] text-foreground">
                          {selectedFile.name}
                        </p>
                        <p className="text-[13px] text-muted-foreground">
                          {(selectedFile.size / 1024).toFixed(1)} KB · Ready to import
                        </p>
                      </div>
                    </div>
                    <div className="flex shrink-0 items-center gap-1">
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        onClick={(e) => {
                          e.stopPropagation();
                          fileInputRef.current?.click();
                        }}
                      >
                        <RefreshCw />
                        Change
                      </Button>
                      <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        onClick={(e) => {
                          e.stopPropagation();
                          setSelectedFile(null);
                          if (fileInputRef.current) fileInputRef.current.value = "";
                        }}
                        aria-label="Remove file"
                      >
                        <X />
                      </Button>
                    </div>
                  </div>
                ) : (
                  <div className="space-y-2">
                    <UploadCloud className="mx-auto h-7 w-7 text-muted-foreground" strokeWidth={1.75} />
                    <p className="text-[15px] font-semibold tracking-[-0.016em] text-foreground">
                      Drop an Excel file here, or{" "}
                      <span className="text-primary">browse</span>
                    </p>
                    <p className="text-[13px] text-muted-foreground">.xlsx files up to 5 MB</p>
                  </div>
                )}
              </div>
            </div>
          </div>

          <div className="flex items-center justify-end gap-2 border-t border-border/70 px-6 py-4">
            <Button type="button" variant="outline" onClick={() => setIsOpen(false)} disabled={uploading}>
              Cancel
            </Button>
            <Button type="button" disabled={!selectedFile || uploading} onClick={() => void handleUpload()}>
              {uploading ? (
                <>
                  <RefreshCw className="animate-spin" />
                  Importing…
                </>
              ) : (
                <>
                  <Upload />
                  Import
                </>
              )}
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}
