import { useRef, useState } from "react";
import { ChevronDown, Download, Upload } from "lucide-react";
import { toast } from "sonner";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
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
  type EmployeeBulkRowError,
} from "@/lib/api/employees";

export function EmployeeBulkUploadMenu({ onImported }: { onImported: () => void }) {
  const fileRef = useRef<HTMLInputElement>(null);
  const [busy, setBusy] = useState(false);
  const [rowErrors, setRowErrors] = useState<EmployeeBulkRowError[] | null>(null);

  const handleSample = async () => {
    try {
      await downloadEmployeeBulkSample();
      toast.success("Sample Excel downloaded");
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to download sample";
      toast.error(message);
    }
  };

  const handleFile = async (file: File | undefined) => {
    if (!file) return;
    setBusy(true);
    try {
      const result = await uploadEmployeeBulk(file);
      onImported();
      if (result.created > 0 && result.failed === 0) {
        toast.success(
          `${result.created} employee${result.created === 1 ? "" : "s"} added from Excel`,
        );
      } else if (result.created > 0) {
        toast.success(
          `${result.created} added, ${result.failed} skipped due to duplicate or invalid data`,
        );
      } else if (result.failed > 0) {
        toast.error("No employees were added. Check the errors and try again.");
      } else {
        toast.error("The Excel file has no employee rows to import.");
      }
      if (result.errors.length > 0) setRowErrors(result.errors);
    } catch (error: unknown) {
      const message = error instanceof Error ? error.message : "Failed to upload Excel file";
      toast.error(message);
    } finally {
      setBusy(false);
      if (fileRef.current) fileRef.current.value = "";
    }
  };

  return (
    <>
      <input
        ref={fileRef}
        type="file"
        accept=".xlsx,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        className="hidden"
        onChange={(e) => void handleFile(e.target.files?.[0])}
      />
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <button
            type="button"
            disabled={busy}
            className="inline-flex items-center gap-2 rounded-md border border-input bg-card px-4 py-2 text-sm font-medium text-foreground hover:bg-accent shadow-sm transition-all disabled:opacity-60"
          >
            <Upload className="h-4 w-4" />
            {busy ? "Uploading…" : "Bulk Upload"}
            <ChevronDown className="h-3.5 w-3.5 opacity-70" />
          </button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-48">
          <DropdownMenuItem
            disabled={busy}
            onSelect={() => fileRef.current?.click()}
          >
            <Upload className="h-4 w-4" />
            Upload
          </DropdownMenuItem>
          <DropdownMenuItem disabled={busy} onSelect={() => void handleSample()}>
            <Download className="h-4 w-4" />
            Sample download
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>

      <Dialog open={Boolean(rowErrors)} onOpenChange={(open) => !open && setRowErrors(null)}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Bulk upload errors</DialogTitle>
            <DialogDescription>
              Duplicate or invalid rows were skipped. Fix these in the Excel file and upload again.
            </DialogDescription>
          </DialogHeader>
          <div className="max-h-72 overflow-y-auto rounded-md border border-border">
            <ul className="divide-y divide-border text-sm">
              {(rowErrors ?? []).map((err) => (
                <li key={`${err.row}-${err.employeeCode ?? ""}-${err.message}`} className="px-3 py-2">
                  <span className="font-medium">Row {err.row}</span>
                  {err.employeeCode ? (
                    <span className="text-muted-foreground"> · {err.employeeCode}</span>
                  ) : null}
                  <p className="mt-0.5 text-xs text-destructive">{err.message}</p>
                </li>
              ))}
            </ul>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}
