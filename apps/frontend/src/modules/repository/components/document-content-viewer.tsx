import { useEffect, useState } from "react";
import {
  FileText,
  FileSpreadsheet,
  Download,
  AlertCircle,
} from "lucide-react";
import { cn } from "@/lib/utils";

interface DocumentContentViewerProps {
  previewUrl: string;
  fileName: string;
  onDownload: () => void;
}

export function DocumentContentViewer({
  previewUrl,
  fileName,
  onDownload,
}: DocumentContentViewerProps) {
  const ext = fileName.split(".").pop()?.toLowerCase() ?? "";

  const isWord = ["docx", "doc", "docm"].includes(ext);
  const isExcel = ["xlsx", "xls", "xlsm", "xlsb", "csv"].includes(ext);

  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Word state
  const [wordHtml, setWordHtml] = useState<string | null>(null);

  // Excel state
  const [excelSheets, setExcelSheets] = useState<string[]>([]);
  const [activeSheetIndex, setActiveSheetIndex] = useState(0);
  const [sheetData, setSheetData] = useState<string[][]>([]);
  const [workbookRef, setWorkbookRef] = useState<{
    Sheets: Record<string, unknown>;
    SheetNames: string[];
  } | null>(null);

  useEffect(() => {
    let isCancelled = false;
    setIsLoading(true);
    setError(null);

    fetch(previewUrl)
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP error ${res.status}: ${res.statusText}`);
        return res.arrayBuffer();
      })
      .then(async (arrayBuffer) => {
        if (isCancelled) return;

        // ── 1. Word Handling ────────────────────────────────────────────────
        if (isWord) {
          try {
            const mammoth = await import("mammoth");
            const result = await mammoth.convertToHtml({ arrayBuffer });
            if (!isCancelled) {
              if (result.value && result.value.trim().length > 0) {
                setWordHtml(result.value);
              } else {
                const textDecoder = new TextDecoder("utf-8");
                const rawText = textDecoder.decode(arrayBuffer);
                const safeHtml = rawText
                  .replace(/&/g, "&amp;")
                  .replace(/</g, "&lt;")
                  .replace(/>/g, "&gt;")
                  .replace(/\n/g, "<br/>");
                setWordHtml(`<div class="whitespace-pre-wrap font-sans">${safeHtml}</div>`);
              }
            }
          } catch {
            try {
              const textDecoder = new TextDecoder("utf-8");
              const rawText = textDecoder.decode(arrayBuffer);
              if (rawText && rawText.trim().length > 0) {
                const printable = rawText.replace(/[^\x20-\x7E\t\n\r]/g, " ").trim();
                const safeHtml = printable
                  .replace(/&/g, "&amp;")
                  .replace(/</g, "&lt;")
                  .replace(/>/g, "&gt;")
                  .replace(/\n/g, "<br/>");
                if (!isCancelled) {
                  setWordHtml(`<div class="whitespace-pre-wrap font-sans text-sm leading-relaxed">${safeHtml}</div>`);
                }
              } else {
                if (!isCancelled) {
                  setError("Word document is empty.");
                }
              }
            } catch {
              if (!isCancelled) {
                setError("Failed to parse Word document. Please download to view.");
              }
            }
          }
        }
        // ── 2. Excel Handling ───────────────────────────────────────────────
        else if (isExcel) {
          try {
            const XLSX = await import("xlsx");
            const wb = XLSX.read(arrayBuffer, { type: "array" });
            if (!isCancelled) {
              setWorkbookRef(wb);
              setExcelSheets(wb.SheetNames || []);
              if (wb.SheetNames.length > 0) {
                loadExcelSheet(wb, wb.SheetNames[0]);
              }
            }
          } catch (err) {
            if (!isCancelled) {
              setError("Failed to parse Excel spreadsheet. Please download to view.");
            }
          }
        }
      })
      .catch((err) => {
        if (!isCancelled) {
          setError(err instanceof Error ? err.message : "Failed to load document content.");
        }
      })
      .finally(() => {
        if (!isCancelled) setIsLoading(false);
      });

    return () => {
      isCancelled = true;
    };
  }, [previewUrl, isWord, isExcel]);

  const loadExcelSheet = async (
    wb: { Sheets: Record<string, unknown>; SheetNames: string[] },
    sheetName: string,
  ) => {
    const XLSX = await import("xlsx");
    const ws = wb.Sheets[sheetName];
    if (!ws) {
      setSheetData([]);
      return;
    }
    const jsonData = XLSX.utils.sheet_to_json<string[]>(ws as Parameters<typeof XLSX.utils.sheet_to_json>[0], {
      header: 1,
      defval: "",
    });
    setSheetData(jsonData);
  };

  const handleSwitchExcelSheet = (index: number) => {
    setActiveSheetIndex(index);
    if (workbookRef && excelSheets[index]) {
      loadExcelSheet(workbookRef, excelSheets[index]);
    }
  };

  if (isLoading) {
    return (
      <div className="flex flex-col items-center justify-center py-16 text-center">
        <div className="h-8 w-8 animate-spin rounded-full border-3 border-primary border-t-transparent mb-3" />
        <p className="text-sm font-medium text-foreground">Rendering document...</p>
        <p className="text-xs text-muted-foreground mt-1">Extracting formatted content for in-browser view</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center max-w-md mx-auto">
        <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-destructive/10 text-destructive mb-3">
          <AlertCircle className="h-6 w-6" />
        </div>
        <h4 className="text-sm font-semibold text-foreground">Unable to Display Document</h4>
        <p className="text-xs text-muted-foreground mt-1 mb-4">{error}</p>
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={onDownload}
            className="inline-flex items-center gap-1.5 rounded-lg bg-primary px-4 py-2 text-xs font-medium text-primary-foreground shadow-xs hover:bg-primary/90"
          >
            <Download className="h-3.5 w-3.5" />
            Download to View
          </button>
        </div>
      </div>
    );
  }

  // ─── 1. Word Viewer (.docx, .doc) ──────────────────────────────────────────
  if (isWord && wordHtml) {
    return (
      <div className="flex flex-col h-full w-full">
        {/* Word Document Canvas */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 bg-muted/20">
          <div className="max-w-3xl mx-auto rounded-xl border border-border bg-card p-6 sm:p-10 shadow-sm text-foreground">
            <div
              className="prose prose-sm dark:prose-invert max-w-none text-foreground prose-headings:text-foreground prose-a:text-primary prose-table:border prose-th:border prose-th:bg-muted/50 prose-th:p-2 prose-td:border prose-td:p-2"
              dangerouslySetInnerHTML={{ __html: wordHtml }}
            />
          </div>
        </div>
      </div>
    );
  }

  // ─── 2. Excel Viewer (.xlsx, .xls, .csv) ────────────────────────────────────
  if (isExcel) {
    return (
      <div className="flex flex-col h-full w-full">
        {/* Excel Toolbar */}
        <div className="flex flex-wrap items-center justify-between gap-2 border-b border-border bg-muted/40 px-4 py-2.5 text-xs shrink-0">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1.5 text-muted-foreground">
              <FileSpreadsheet className="h-4 w-4 text-emerald-600" />
              <span className="font-semibold text-foreground">Excel Workbook</span>
            </div>
            {excelSheets.length > 1 && (
              <div className="flex items-center gap-1 overflow-x-auto max-w-md">
                {excelSheets.map((sheet, idx) => (
                  <button
                    key={sheet}
                    type="button"
                    onClick={() => handleSwitchExcelSheet(idx)}
                    className={cn(
                      "px-2.5 py-1 rounded-md text-[11px] font-medium transition-colors whitespace-nowrap cursor-pointer",
                      activeSheetIndex === idx
                        ? "bg-primary text-primary-foreground shadow-2xs font-semibold"
                        : "bg-card border border-input text-muted-foreground hover:bg-accent",
                    )}
                  >
                    {sheet}
                  </button>
                ))}
              </div>
            )}
          </div>

          <div className="text-[11px] text-muted-foreground">
            <span>Sheet: <strong className="text-foreground">{excelSheets[activeSheetIndex] || "Default"}</strong> ({sheetData.length} rows)</span>
          </div>
        </div>

        {/* Excel Data Grid */}
        <div className="flex-1 overflow-auto bg-muted/10 p-2 sm:p-4">
          {sheetData.length === 0 ? (
            <div className="py-12 text-center text-xs text-muted-foreground">This sheet is empty.</div>
          ) : (
            <div className="rounded-lg border border-border bg-card shadow-2xs overflow-hidden">
              <div className="overflow-x-auto max-h-[70vh]">
                <table className="w-full text-left text-xs border-collapse">
                  <tbody>
                    {sheetData.slice(0, 300).map((row, rowIdx) => {
                      const isHeader = rowIdx === 0;
                      return (
                        <tr
                          key={rowIdx}
                          className={cn(
                            "border-b border-border/70 transition-colors",
                            isHeader
                              ? "bg-muted/60 font-semibold sticky top-0 z-10 text-foreground"
                              : "hover:bg-accent/20 even:bg-muted/10",
                          )}
                        >
                          <td className="px-2.5 py-1.5 text-[10px] text-muted-foreground/60 border-r border-border/70 select-none text-center bg-muted/30 font-mono w-10">
                            {rowIdx + 1}
                          </td>
                          {row.map((cell, cellIdx) => (
                            <td
                              key={cellIdx}
                              className={cn(
                                "px-3 py-1.5 whitespace-nowrap border-r border-border/50 last:border-r-0 max-w-xs truncate",
                                isHeader ? "text-foreground font-semibold" : "text-foreground/90",
                              )}
                              title={String(cell)}
                            >
                              {String(cell || "")}
                            </td>
                          ))}
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
              <div className="border-t border-border bg-muted/30 px-3 py-1.5 text-[11px] text-muted-foreground flex justify-between">
                <span>
                  Showing {Math.min(sheetData.length, 300)} of {sheetData.length} rows
                </span>
                <span>Sheet: {excelSheets[activeSheetIndex] || "Default"}</span>
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  return null;
}
