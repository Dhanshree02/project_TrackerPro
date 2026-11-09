import { useState, useRef, useId } from "react";
import * as XLSX from "xlsx";
import {
  Upload,
  FileSpreadsheet,
  Download,
  X,
  AlertCircle,
  CheckCircle2,
  FileText,
  Loader2,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import {
  bulkCreateLeaveCalendarHolidays,
  type UpsertLeaveCalendarHolidayPayload,
} from "@/modules/settings/api/leave-calendar";

interface HolidayBulkUploadDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  selectedYear: number;
  onImportSuccess: () => void;
}

interface ParsedHolidayRow {
  rowNumber: number;
  date: string; // YYYY-MM-DD
  name: string;
  isValid: boolean;
  error?: string;
  formattedDateLabel?: string;
}

/**
 * Generates and downloads a sample Excel (.xlsx) file with sample holiday dates and names.
 */
export function downloadHolidaySampleExcel(year: number) {
  const sampleData = [
    { Date: `${year}-01-01`, "Holiday Name": "New Year's Day" },
    { Date: `${year}-01-26`, "Holiday Name": "Republic Day" },
    { Date: `${year}-03-03`, "Holiday Name": "Holi" },
    { Date: `${year}-03-20`, "Holiday Name": "Id-ul-Fitr (Ramzan Eid)" },
    { Date: `${year}-04-03`, "Holiday Name": "Good Friday" },
    { Date: `${year}-04-14`, "Holiday Name": "Dr. Ambedkar Jayanti" },
    { Date: `${year}-05-01`, "Holiday Name": "Maharashtra Day / May Day" },
    { Date: `${year}-08-15`, "Holiday Name": "Independence Day" },
    { Date: `${year}-09-14`, "Holiday Name": "Ganesh Chaturthi" },
    { Date: `${year}-10-02`, "Holiday Name": "Mahatma Gandhi Jayanti" },
    { Date: `${year}-10-20`, "Holiday Name": "Dussehra (Vijaya Dashami)" },
    { Date: `${year}-11-08`, "Holiday Name": "Diwali (Laxmi Pujan)" },
    { Date: `${year}-11-09`, "Holiday Name": "Diwali (Balipratipada)" },
    { Date: `${year}-12-25`, "Holiday Name": "Christmas" },
  ];

  const worksheet = XLSX.utils.json_to_sheet(sampleData);

  // Set column widths
  worksheet["!cols"] = [
    { wch: 16 }, // Date
    { wch: 36 }, // Holiday Name
  ];

  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, "Holidays");

  const fileName = `Holiday_Calendar_Sample_${year}.xlsx`;
  const wbout = XLSX.write(workbook, { bookType: "xlsx", type: "array" });
  const blob = new Blob([wbout], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = fileName;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

/**
 * Normalizes any date representation (Excel serial, JS Date, string) into YYYY-MM-DD.
 */
export function normalizeDateString(rawVal: unknown): string | null {
  if (rawVal === null || rawVal === undefined) return null;

  // Case 1: Already JS Date object
  if (rawVal instanceof Date && !isNaN(rawVal.getTime())) {
    const y = rawVal.getFullYear();
    const m = String(rawVal.getMonth() + 1).padStart(2, "0");
    const d = String(rawVal.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  }

  // Case 2: Excel serial number (e.g. 46048)
  if (typeof rawVal === "number" && rawVal > 0) {
    const parsedDate = new Date(Math.round((rawVal - 25569) * 86400 * 1000));
    if (!isNaN(parsedDate.getTime())) {
      const y = parsedDate.getFullYear();
      const m = String(parsedDate.getMonth() + 1).padStart(2, "0");
      const d = String(parsedDate.getDate()).padStart(2, "0");
      return `${y}-${m}-${d}`;
    }
  }

  const str = String(rawVal).trim();
  if (!str) return null;

  // Case 3: YYYY-MM-DD or YYYY/MM/DD
  const isoMatch = str.match(/^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})$/);
  if (isoMatch) {
    const y = isoMatch[1];
    const m = String(Number(isoMatch[2])).padStart(2, "0");
    const d = String(Number(isoMatch[3])).padStart(2, "0");
    return `${y}-${m}-${d}`;
  }

  // Case 4: DD-MM-YYYY or DD/MM/YYYY
  const dmyMatch = str.match(/^(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})$/);
  if (dmyMatch) {
    const d = String(Number(dmyMatch[1])).padStart(2, "0");
    const m = String(Number(dmyMatch[2])).padStart(2, "0");
    const y = dmyMatch[3];
    return `${y}-${m}-${d}`;
  }

  // Case 5: Standard Date parse fallback
  const fallbackDate = new Date(str);
  if (!isNaN(fallbackDate.getTime())) {
    const y = fallbackDate.getFullYear();
    const m = String(fallbackDate.getMonth() + 1).padStart(2, "0");
    const d = String(fallbackDate.getDate()).padStart(2, "0");
    return `${y}-${m}-${d}`;
  }

  return null;
}

export function formatDateDisplay(isoDate: string): string {
  try {
    const [y, m, d] = isoDate.split("-").map(Number);
    const date = new Date(y, m - 1, d);
    return date.toLocaleDateString("en-US", {
      weekday: "short",
      day: "numeric",
      month: "short",
      year: "numeric",
    });
  } catch {
    return isoDate;
  }
}

export function HolidayBulkUploadDialog({
  open,
  onOpenChange,
  selectedYear,
  onImportSuccess,
}: HolidayBulkUploadDialogProps) {
  const fileInputId = useId();
  const fileInputRef = useRef<HTMLInputElement>(null);

  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [isDragging, setIsDragging] = useState<boolean>(false);
  const [parsing, setParsing] = useState<boolean>(false);
  const [importing, setImporting] = useState<boolean>(false);

  const [parsedRows, setParsedRows] = useState<ParsedHolidayRow[]>([]);
  const [parseError, setParseError] = useState<string | null>(null);

  const resetState = () => {
    setSelectedFile(null);
    setParsedRows([]);
    setParseError(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const handleClose = () => {
    if (importing) return;
    resetState();
    onOpenChange(false);
  };

  const handleDownloadSample = () => {
    try {
      downloadHolidaySampleExcel(selectedYear);
      toast.success(`Holiday calendar sample template downloaded.`);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to download sample file");
    }
  };

  const processFile = async (file: File) => {
    const ext = file.name.split(".").pop()?.toLowerCase();
    if (!["xlsx", "xls", "csv"].includes(ext || "")) {
      toast.error("Invalid file format. Please upload an Excel (.xlsx, .xls) or CSV file.");
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      toast.error("File is too large. Maximum size is 5 MB.");
      return;
    }

    setSelectedFile(file);
    setParsing(true);
    setParseError(null);

    try {
      const buffer = await file.arrayBuffer();
      const workbook = XLSX.read(buffer, { type: "array", cellDates: true });
      const firstSheetName = workbook.SheetNames[0];

      if (!firstSheetName) {
        throw new Error("The Excel workbook is empty.");
      }

      const worksheet = workbook.Sheets[firstSheetName];
      const rawRows = XLSX.utils.sheet_to_json<unknown[]>(worksheet, {
        header: 1,
        blankrows: false,
      });

      if (!rawRows || rawRows.length < 2) {
        throw new Error("The Excel sheet does not contain enough rows (header + at least 1 holiday row required).");
      }

      // Detect header columns
      const headerRow = rawRows[0] as unknown[];
      let dateColIdx = -1;
      let nameColIdx = -1;

      for (let i = 0; i < headerRow.length; i++) {
        const headerStr = String(headerRow[i] ?? "").trim().toLowerCase();
        if (headerStr.includes("date")) {
          dateColIdx = i;
        } else if (headerStr.includes("name") || headerStr.includes("holiday")) {
          nameColIdx = i;
        }
      }

      // Default fallback if headers were not named standardly
      if (dateColIdx === -1) dateColIdx = 0;
      if (nameColIdx === -1) nameColIdx = 1;

      const rows: ParsedHolidayRow[] = [];
      const seenDates = new Set<string>();

      for (let i = 1; i < rawRows.length; i++) {
        const row = rawRows[i] as unknown[];
        if (!row || row.length === 0) continue;

        const rawDate = row[dateColIdx];
        const rawName = row[nameColIdx];

        // Skip completely empty rows
        if ((rawDate === undefined || rawDate === null || rawDate === "") &&
            (rawName === undefined || rawName === null || rawName === "")) {
          continue;
        }

        const dateStr = normalizeDateString(rawDate);
        const nameStr = String(rawName ?? "").trim();

        const rowNumber = i + 1; // 1-based index matching Excel row numbers

        if (!dateStr) {
          rows.push({
            rowNumber,
            date: "",
            name: nameStr,
            isValid: false,
            error: "Invalid or missing date",
          });
          continue;
        }

        if (!nameStr) {
          rows.push({
            rowNumber,
            date: dateStr,
            name: "",
            isValid: false,
            error: "Missing holiday name",
            formattedDateLabel: formatDateDisplay(dateStr),
          });
          continue;
        }

        // Check for duplicates within the uploaded file
        if (seenDates.has(dateStr)) {
          rows.push({
            rowNumber,
            date: dateStr,
            name: nameStr,
            isValid: true,
            error: "Duplicate date (will overwrite previous entry for this date)",
            formattedDateLabel: formatDateDisplay(dateStr),
          });
        } else {
          seenDates.add(dateStr);
          rows.push({
            rowNumber,
            date: dateStr,
            name: nameStr,
            isValid: true,
            formattedDateLabel: formatDateDisplay(dateStr),
          });
        }
      }

      if (rows.length === 0) {
        throw new Error("No data rows found in the sheet.");
      }

      setParsedRows(rows);
    } catch (err) {
      const msg = err instanceof Error ? err.message : "Failed to parse Excel file";
      setParseError(msg);
      toast.error(msg);
    } finally {
      setParsing(false);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      void processFile(file);
    }
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    const file = e.dataTransfer.files?.[0];
    if (file) {
      void processFile(file);
    }
  };

  const validRows = parsedRows.filter((r) => r.isValid);
  const invalidRows = parsedRows.filter((r) => !r.isValid);

  const handleImport = async () => {
    if (validRows.length === 0) {
      toast.error("No valid holiday rows to import.");
      return;
    }

    setImporting(true);
    try {
      // Map deduplicating by date
      const payloadMap = new Map<string, UpsertLeaveCalendarHolidayPayload>();
      for (const row of validRows) {
        payloadMap.set(row.date, {
          date: row.date,
          name: row.name,
        });
      }
      const payload = Array.from(payloadMap.values());

      await bulkCreateLeaveCalendarHolidays(payload);
      toast.success(
        `Successfully imported ${payload.length} holiday${payload.length === 1 ? "" : "s"}!`
      );
      onImportSuccess();
      handleClose();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Failed to import holidays");
    } finally {
      setImporting(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent
        disableAnimation
        overlayClassName="!duration-0 !animate-none"
        className="sm:max-w-xl max-h-[90vh] flex flex-col p-0 overflow-hidden !duration-0 !animate-none"
      >
        <DialogHeader className="p-6 pb-4 border-b border-border/60">
          <div className="flex items-center gap-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
              <FileSpreadsheet className="h-5 w-5" />
            </div>
            <div>
              <DialogTitle className="text-base font-bold text-foreground">
                Bulk Upload Holidays
              </DialogTitle>
              <DialogDescription className="text-xs text-muted-foreground mt-0.5">
                Import full year holidays using an Excel sheet (.xlsx, .xls, .csv).
              </DialogDescription>
            </div>
          </div>
        </DialogHeader>

        <div className="flex-1 overflow-y-auto p-6 space-y-4">
          {/* ── Sample Excel Download Card ── */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 p-3.5 rounded-xl border border-emerald-500/20 bg-emerald-500/5">
            <div className="space-y-0.5">
              <div className="flex items-center gap-1.5 text-xs font-semibold text-emerald-900 dark:text-emerald-200">
                <FileText className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400" />
                <span>Sample Excel Template</span>
              </div>
              <p className="text-[11px] text-muted-foreground">
                Download a pre-formatted template with columns: <strong className="font-semibold text-foreground">Date</strong> and <strong className="font-semibold text-foreground">Holiday Name</strong>.
              </p>
            </div>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handleDownloadSample}
              className="h-8 text-xs shrink-0 border-emerald-600/30 text-emerald-700 dark:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-950/40 gap-1.5 font-medium"
            >
              <Download className="h-3.5 w-3.5" />
              <span>Download Sample (.xlsx)</span>
            </Button>
          </div>

          {/* ── File Upload Dropzone ── */}
          {!selectedFile ? (
            <div
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              onDrop={handleDrop}
              className={`relative flex flex-col items-center justify-center p-8 rounded-xl border-2 border-dashed cursor-pointer ${
                isDragging
                  ? "border-emerald-500 bg-emerald-50/50 dark:bg-emerald-950/20"
                  : "border-border/80 hover:border-emerald-500/60 bg-muted/20 hover:bg-muted/40"
              }`}
              onClick={() => fileInputRef.current?.click()}
            >
              <input
                id={fileInputId}
                ref={fileInputRef}
                type="file"
                accept=".xlsx,.xls,.csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/vnd.ms-excel,text/csv"
                onChange={handleFileChange}
                className="hidden"
              />
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 mb-3">
                <Upload className="h-6 w-6" />
              </div>
              <p className="text-xs font-semibold text-foreground">
                Click to browse or drag and drop your file here
              </p>
              <p className="text-[11px] text-muted-foreground mt-1">
                Supports Microsoft Excel (.xlsx, .xls) and CSV (Max 5 MB)
              </p>
            </div>
          ) : (
            /* ── File Selected & Preview Mode ── */
            <div className="space-y-4">
              {/* File Info Bar */}
              <div className="flex items-center justify-between p-3 rounded-lg border border-border bg-card">
                <div className="flex items-center gap-2.5 min-w-0">
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-md bg-emerald-500/10 text-emerald-600">
                    <FileSpreadsheet className="h-4 w-4" />
                  </div>
                  <div className="min-w-0">
                    <p className="text-xs font-semibold text-foreground truncate max-w-xs sm:max-w-sm">
                      {selectedFile.name}
                    </p>
                    <p className="text-[10px] text-muted-foreground">
                      {(selectedFile.size / 1024).toFixed(1)} KB
                    </p>
                  </div>
                </div>
                <Button
                  type="button"
                  variant="ghost"
                  size="icon"
                  onClick={resetState}
                  disabled={importing}
                  className="h-7 w-7 text-muted-foreground hover:text-foreground"
                  title="Remove and choose another file"
                >
                  <X className="h-4 w-4" />
                </Button>
              </div>

              {parsing ? (
                <div className="py-8 flex flex-col items-center justify-center text-xs text-muted-foreground gap-2">
                  <Loader2 className="h-5 w-5 animate-spin text-primary" />
                  <span>Parsing Excel data...</span>
                </div>
              ) : parseError ? (
                <div className="p-3.5 rounded-lg border border-destructive/30 bg-destructive/10 text-destructive text-xs flex items-start gap-2">
                  <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
                  <span>{parseError}</span>
                </div>
              ) : (
                <>
                  {/* Summary Badges */}
                  <div className="flex flex-wrap items-center gap-2">
                    <Badge variant="outline" className="border-emerald-500/40 bg-emerald-500/10 text-emerald-700 dark:text-emerald-300 text-xs px-2.5 py-1 flex items-center gap-1.5">
                      <CheckCircle2 className="h-3.5 w-3.5" />
                      <span>{validRows.length} valid holiday{validRows.length === 1 ? "" : "s"} ready</span>
                    </Badge>

                    {invalidRows.length > 0 && (
                      <Badge variant="outline" className="border-destructive/40 bg-destructive/10 text-destructive text-xs px-2.5 py-1 flex items-center gap-1.5">
                        <AlertCircle className="h-3.5 w-3.5" />
                        <span>{invalidRows.length} row{invalidRows.length === 1 ? "" : "s"} skipped</span>
                      </Badge>
                    )}
                  </div>

                  {/* Preview Table */}
                  <div className="rounded-lg border border-border overflow-hidden">
                    <div className="bg-muted/50 px-3 py-2 border-b border-border text-[11px] font-semibold text-muted-foreground flex justify-between items-center">
                      <span>Preview ({parsedRows.length} rows detected)</span>
                      <span className="text-[10px] font-normal">Target Year: {selectedYear}</span>
                    </div>

                    <div className="max-h-56 overflow-y-auto">
                      <table className="w-full text-left text-xs">
                        <thead className="bg-muted/30 border-b border-border text-muted-foreground sticky top-0">
                          <tr>
                            <th className="py-1.5 px-3 w-10 text-center">#</th>
                            <th className="py-1.5 px-3 w-36">Date</th>
                            <th className="py-1.5 px-3">Holiday Name</th>
                            <th className="py-1.5 px-3 w-28 text-right">Status</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-border/50">
                          {parsedRows.map((row) => (
                            <tr
                              key={`preview-${row.rowNumber}`}
                              className={row.isValid ? "hover:bg-muted/20" : "bg-destructive/5 hover:bg-destructive/10"}
                            >
                              <td className="py-2 px-3 text-center text-[10px] text-muted-foreground font-mono">
                                {row.rowNumber}
                              </td>
                              <td className="py-2 px-3 font-medium whitespace-nowrap">
                                {row.date ? (
                                  <div>
                                    <div className="font-mono text-[11px]">{row.date}</div>
                                    <div className="text-[10px] text-muted-foreground">
                                      {row.formattedDateLabel}
                                    </div>
                                  </div>
                                ) : (
                                  <span className="text-destructive italic text-[11px]">—</span>
                                )}
                              </td>
                              <td className="py-2 px-3">
                                <span className={row.name ? "font-semibold text-foreground" : "text-destructive italic text-[11px]"}>
                                  {row.name || "Missing Name"}
                                </span>
                              </td>
                              <td className="py-2 px-3 text-right">
                                {row.isValid ? (
                                  <span className="inline-flex items-center text-[10px] font-semibold text-emerald-600 dark:text-emerald-400">
                                    Valid
                                  </span>
                                ) : (
                                  <span
                                    className="inline-flex items-center text-[10px] font-semibold text-destructive truncate max-w-[100px]"
                                    title={row.error}
                                  >
                                    {row.error}
                                  </span>
                                )}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </>
              )}
            </div>
          )}
        </div>

        <DialogFooter className="p-4 border-t border-border/60 bg-muted/20 flex flex-row items-center justify-between sm:justify-between gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleClose}
            disabled={importing}
            className="h-8 text-xs"
          >
            Cancel
          </Button>

          <Button
            type="button"
            size="sm"
            onClick={handleImport}
            disabled={importing || validRows.length === 0}
            className="h-8 text-xs gap-1.5 bg-primary hover:bg-primary/90 text-primary-foreground font-semibold"
          >
            {importing ? (
              <>
                <Loader2 className="h-3.5 w-3.5 animate-spin" />
                <span>Importing...</span>
              </>
            ) : (
              <>
                <Upload className="h-3.5 w-3.5" />
                <span>Import {validRows.length} Holiday{validRows.length === 1 ? "" : "s"}</span>
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
