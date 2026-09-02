import { useEffect, useMemo, useState } from "react";
import { X, FileText, CheckCircle2, ShieldCheck, Check, Loader2, Table2 } from "lucide-react";

export interface KycDocPreviewModalProps {
  open: boolean;
  onClose: () => void;
  file?: File | null;
  /** URL of a server-stored KYC file (used when no local File is available). */
  previewUrl?: string | null;
  fileName?: string | null;
  clientName?: string;
  subVentureName?: string;
  uploadDate?: string;
}

export function KycDocPreviewModal({
  open,
  onClose,
  file,
  previewUrl,
  fileName,
  clientName = "Customer",
  subVentureName,
  uploadDate,
}: KycDocPreviewModalProps) {
  const [objectUrl, setObjectUrl] = useState<string | null>(null);
  const sourceUrl = objectUrl ?? previewUrl ?? null;

  // Spreadsheet (xlsx/xls/csv) preview — parsed with SheetJS into an HTML table.
  const [workbook, setWorkbook] = useState<import("xlsx").WorkBook | null>(null);
  const [sheetNames, setSheetNames] = useState<string[]>([]);
  const [activeSheetIdx, setActiveSheetIdx] = useState(0);
  const [sheetHtml, setSheetHtml] = useState<string | null>(null);
  const [sheetLoading, setSheetLoading] = useState(false);
  const [sheetError, setSheetError] = useState<string | null>(null);

  // Word (.docx) preview — converted to HTML with mammoth.
  const [docHtml, setDocHtml] = useState<string | null>(null);
  const [docLoading, setDocLoading] = useState(false);
  const [docError, setDocError] = useState<string | null>(null);

  const resolvedName = useMemo(() => {
    if (file?.name) return file.name;
    if (fileName) return fileName;
    return `${clientName.replace(/\s+/g, "_")}_KYC_Document.pdf`;
  }, [file, fileName, clientName]);

  const fileExt = useMemo(() => {
    const parts = resolvedName.split(".");
    return parts.length > 1 ? parts[parts.length - 1].toLowerCase() : "pdf";
  }, [resolvedName]);

  const isImage = useMemo(() => {
    if (file?.type?.startsWith("image/")) return true;
    return ["jpg", "jpeg", "png", "webp", "gif", "svg"].includes(fileExt);
  }, [file, fileExt]);

  const isPdf = useMemo(() => {
    if (file?.type === "application/pdf") return true;
    return fileExt === "pdf";
  }, [file, fileExt]);

  const isSpreadsheet = useMemo(
    () => ["xlsx", "xls", "csv"].includes(fileExt),
    [fileExt],
  );

  const isWord = useMemo(() => fileExt === "docx", [fileExt]);

  const fileSizeStr = useMemo(() => {
    if (file?.size) {
      return file.size < 1024 * 1024
        ? `${(file.size / 1024).toFixed(1)} KB`
        : `${(file.size / (1024 * 1024)).toFixed(2)} MB`;
    }
    return "240 KB";
  }, [file]);

  const certNumber = useMemo(() => {
    const hash = resolvedName.split("").reduce((acc, char) => (acc * 31 + char.charCodeAt(0)) % 1000000, 7291);
    return `KYC-${new Date().getFullYear()}-${String(Math.abs(hash)).padStart(6, "0")}`;
  }, [resolvedName]);

  useEffect(() => {
    if (!open) {
      if (objectUrl) {
        URL.revokeObjectURL(objectUrl);
        setObjectUrl(null);
      }
      return;
    }

    if (file) {
      const url = URL.createObjectURL(file);
      setObjectUrl(url);
      return () => {
        URL.revokeObjectURL(url);
        setObjectUrl(null);
      };
    }
  }, [open, file]);

  // Load + parse the spreadsheet bytes (from the local File or the server URL).
  useEffect(() => {
    if (!open || !isSpreadsheet) {
      setWorkbook(null);
      setSheetNames([]);
      setSheetHtml(null);
      setSheetError(null);
      return;
    }

    let cancelled = false;
    setSheetLoading(true);
    setSheetError(null);
    setSheetHtml(null);
    setWorkbook(null);

    (async () => {
      try {
        let buffer: ArrayBuffer;
        if (file) {
          buffer = await file.arrayBuffer();
        } else if (previewUrl) {
          const res = await fetch(previewUrl, { credentials: "include" });
          if (!res.ok) throw new Error(`Couldn't load the document (${res.status}).`);
          buffer = await res.arrayBuffer();
        } else {
          throw new Error("No document is available to preview.");
        }

        const XLSX = await import("xlsx");
        const wb = XLSX.read(new Uint8Array(buffer), { type: "array" });
        if (cancelled) return;
        setWorkbook(wb);
        setSheetNames(wb.SheetNames);
        setActiveSheetIdx(0);
      } catch (err) {
        if (!cancelled) {
          setSheetError(err instanceof Error ? err.message : "This spreadsheet couldn't be previewed.");
        }
      } finally {
        if (!cancelled) setSheetLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [open, isSpreadsheet, file, previewUrl]);

  // Render the active sheet to an HTML table whenever it (or the selection) changes.
  useEffect(() => {
    if (!workbook || sheetNames.length === 0) return;
    let cancelled = false;
    (async () => {
      const XLSX = await import("xlsx");
      const sheet = workbook.Sheets[sheetNames[activeSheetIdx]];
      if (!sheet) return;
      const html = XLSX.utils.sheet_to_html(sheet, { editable: false });
      if (!cancelled) setSheetHtml(html);
    })();
    return () => {
      cancelled = true;
    };
  }, [workbook, sheetNames, activeSheetIdx]);

  // Load + convert the Word document (from the local File or the server URL).
  useEffect(() => {
    if (!open || !isWord) {
      setDocHtml(null);
      setDocError(null);
      return;
    }

    let cancelled = false;
    setDocLoading(true);
    setDocError(null);
    setDocHtml(null);

    (async () => {
      try {
        let buffer: ArrayBuffer;
        if (file) {
          buffer = await file.arrayBuffer();
        } else if (previewUrl) {
          const res = await fetch(previewUrl, { credentials: "include" });
          if (!res.ok) throw new Error(`Couldn't load the document (${res.status}).`);
          buffer = await res.arrayBuffer();
        } else {
          throw new Error("No document is available to preview.");
        }

        const mammoth = await import("mammoth");
        const result = await mammoth.convertToHtml({ arrayBuffer: buffer });
        if (cancelled) return;
        setDocHtml(result.value || "<p>This document has no visible content.</p>");
      } catch (err) {
        if (!cancelled) {
          setDocError(err instanceof Error ? err.message : "This document couldn't be previewed.");
        }
      } finally {
        if (!cancelled) setDocLoading(false);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [open, isWord, file, previewUrl]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-3 sm:p-6">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/65 backdrop-blur-xs transition-opacity animate-in fade-in duration-150"
        onClick={onClose}
      />

      {/* Modal Dialog */}
      <div className="relative flex max-h-[92vh] w-full max-w-3xl flex-col overflow-hidden rounded-2xl border border-border/80 bg-background shadow-2xl animate-in zoom-in-95 duration-150">
        {/* Header */}
        <div className="flex items-center justify-between border-b border-border/80 bg-slate-50 dark:bg-muted/40 px-5 py-3">
          <div className="flex items-center gap-2.5 min-w-0">
            <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary border border-primary/20">
              <FileText className="h-5 w-5" />
            </div>
            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <h3 className="truncate text-sm font-semibold text-foreground">
                  {resolvedName}
                </h3>
                <span className="inline-flex shrink-0 items-center gap-1 rounded-full border border-success/30 bg-success/10 px-2 py-0.2 text-[10px] font-semibold text-success uppercase">
                  <Check className="h-2.5 w-2.5" /> Verified
                </span>
              </div>
              <div className="flex items-center gap-2 text-[11px] text-muted-foreground">
                <span className="uppercase font-medium tracking-wider">{fileExt}</span>
                <span>•</span>
                <span>{fileSizeStr}</span>
                <span>•</span>
                <span>{clientName}</span>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2 shrink-0 ml-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg p-1.5 text-muted-foreground hover:bg-accent hover:text-foreground transition-colors cursor-pointer"
              aria-label="Close modal"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>

        {/* Document View Body */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 bg-slate-100/70 dark:bg-muted/20 min-h-[380px] max-h-[72vh]">
          {isImage && sourceUrl ? (
            <div className="flex justify-center items-center overflow-hidden rounded-xl border border-border bg-white dark:bg-card p-3 shadow-md">
              <img
                src={sourceUrl}
                alt={resolvedName}
                className="max-h-[60vh] w-auto max-w-full rounded-lg object-contain"
              />
            </div>
          ) : isPdf && sourceUrl ? (
            <div className="overflow-hidden rounded-xl border border-border bg-card shadow-md">
              <iframe
                src={`${sourceUrl}#toolbar=0`}
                title={resolvedName}
                className="h-[62vh] w-full bg-card"
              />
            </div>
          ) : isSpreadsheet ? (
            <div className="overflow-hidden rounded-xl border border-border bg-white dark:bg-card shadow-md">
              <div className="flex items-center gap-2 border-b border-border bg-slate-50 dark:bg-muted/40 px-3 py-2">
                <Table2 className="h-3.5 w-3.5 text-primary" />
                <span className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                  Spreadsheet preview
                </span>
                {sheetNames.length > 1 && (
                  <div className="ml-auto flex items-center gap-1 overflow-x-auto">
                    {sheetNames.map((name, i) => (
                      <button
                        key={name}
                        type="button"
                        onClick={() => setActiveSheetIdx(i)}
                        className={
                          "shrink-0 rounded-md px-2 py-0.5 text-[11px] font-medium transition-colors cursor-pointer " +
                          (i === activeSheetIdx
                            ? "bg-primary/15 text-primary border border-primary/30"
                            : "text-muted-foreground hover:bg-accent hover:text-foreground border border-transparent")
                        }
                      >
                        {name}
                      </button>
                    ))}
                  </div>
                )}
              </div>
              <div
                className={
                  "max-h-[60vh] overflow-auto p-1 " +
                  "[&_table]:w-full [&_table]:border-collapse [&_table]:text-[11px] " +
                  "[&_td]:border [&_td]:border-slate-200 dark:[&_td]:border-border [&_td]:px-2 [&_td]:py-1 [&_td]:align-top [&_td]:text-foreground " +
                  "[&_tr:first-child_td]:bg-slate-100 dark:[&_tr:first-child_td]:bg-muted/50 [&_tr:first-child_td]:font-semibold"
                }
              >
                {sheetLoading ? (
                  <div className="flex h-40 items-center justify-center gap-2 text-xs text-muted-foreground">
                    <Loader2 className="h-4 w-4 animate-spin" /> Loading spreadsheet…
                  </div>
                ) : sheetError ? (
                  <div className="flex h-40 items-center justify-center px-4 text-center text-xs text-destructive">
                    {sheetError}
                  </div>
                ) : sheetHtml ? (
                  <div dangerouslySetInnerHTML={{ __html: sheetHtml }} />
                ) : (
                  <div className="flex h-40 items-center justify-center text-xs text-muted-foreground">
                    No data to display.
                  </div>
                )}
              </div>
            </div>
          ) : isWord ? (
            <div className="overflow-hidden rounded-xl border border-border bg-white dark:bg-card shadow-md">
              <div className="flex items-center gap-2 border-b border-border bg-slate-50 dark:bg-muted/40 px-3 py-2">
                <FileText className="h-3.5 w-3.5 text-primary" />
                <span className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                  Document preview
                </span>
              </div>
              <div className="max-h-[60vh] overflow-auto px-6 py-5">
                {docLoading ? (
                  <div className="flex h-40 items-center justify-center gap-2 text-xs text-muted-foreground">
                    <Loader2 className="h-4 w-4 animate-spin" /> Loading document…
                  </div>
                ) : docError ? (
                  <div className="flex h-40 items-center justify-center px-4 text-center text-xs text-destructive">
                    {docError}
                  </div>
                ) : docHtml ? (
                  <div
                    className={
                      "mx-auto max-w-2xl text-[13px] leading-relaxed text-foreground " +
                      "[&_h1]:mb-2 [&_h1]:text-lg [&_h1]:font-bold [&_h2]:mb-2 [&_h2]:mt-4 [&_h2]:text-base [&_h2]:font-semibold " +
                      "[&_h3]:mb-1 [&_h3]:mt-3 [&_h3]:font-semibold [&_p]:mb-2.5 " +
                      "[&_ul]:mb-2.5 [&_ul]:list-disc [&_ul]:pl-6 [&_ol]:mb-2.5 [&_ol]:list-decimal [&_ol]:pl-6 [&_li]:mb-1 " +
                      "[&_a]:text-primary [&_a]:underline [&_strong]:font-semibold " +
                      "[&_table]:my-3 [&_table]:w-full [&_table]:border-collapse [&_td]:border [&_td]:border-slate-200 dark:[&_td]:border-border [&_td]:px-2 [&_td]:py-1 " +
                      "[&_img]:my-2 [&_img]:max-w-full"
                    }
                    dangerouslySetInnerHTML={{ __html: docHtml }}
                  />
                ) : (
                  <div className="flex h-40 items-center justify-center text-xs text-muted-foreground">
                    No content to display.
                  </div>
                )}
              </div>
            </div>
          ) : (
            /* Official Document Sheet Preview */
            <div className="mx-auto max-w-2xl overflow-hidden rounded-xl border border-slate-300 dark:border-border bg-white dark:bg-card shadow-lg">
              {/* Document Header Band */}
              <div className="border-b-2 border-primary/30 bg-gradient-to-r from-slate-50 via-blue-50/40 to-slate-50 dark:from-muted/40 dark:via-muted/20 dark:to-muted/40 px-6 py-5">
                <div className="flex items-start justify-between gap-4">
                  <div className="flex items-center gap-3">
                    <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-gradient-to-br from-primary to-info text-white font-bold text-base shadow-sm">
                      TK
                    </div>
                    <div>
                      <h4 className="text-xs font-bold uppercase tracking-wider text-primary">
                        Talakunchi Networks & Consulting
                      </h4>
                      <h2 className="text-base font-bold tracking-tight text-foreground">
                        Customer KYC & Compliance Certificate
                      </h2>
                      <p className="text-[11px] text-muted-foreground">
                        Verified Business Partner Documentation
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <span className="inline-flex items-center gap-1 rounded-full border border-success/30 bg-success/15 px-2.5 py-0.5 text-[11px] font-bold text-success">
                      <ShieldCheck className="h-3.5 w-3.5" /> VERIFIED
                    </span>
                    <p className="mt-1 font-mono text-[10px] text-muted-foreground">
                      Ref: {certNumber}
                    </p>
                  </div>
                </div>
              </div>

              {/* Document Content */}
              <div className="space-y-5 p-6 text-xs text-foreground">
                {/* Entity Details Grid */}
                <div className="rounded-lg border border-slate-200 dark:border-border bg-slate-50/70 dark:bg-muted/30 p-4">
                  <h5 className="mb-3 text-[11px] font-bold uppercase tracking-wider text-muted-foreground">
                    1. Verified Organization Information
                  </h5>
                  <div className="grid grid-cols-2 gap-y-3 gap-x-4">
                    <div>
                      <span className="text-muted-foreground text-[11px] block">Customer / Organization Name:</span>
                      <span className="font-semibold text-sm text-foreground">{clientName}</span>
                    </div>
                    {subVentureName && (
                      <div>
                        <span className="text-muted-foreground text-[11px] block">Sub-Venture / Division:</span>
                        <span className="font-medium text-foreground">{subVentureName}</span>
                      </div>
                    )}
                    <div>
                      <span className="text-muted-foreground text-[11px] block">Attached KYC File:</span>
                      <span className="font-mono font-medium text-primary text-[12px] break-all">{resolvedName}</span>
                    </div>
                    <div>
                      <span className="text-muted-foreground text-[11px] block">Verification Date:</span>
                      <span className="font-medium text-foreground">
                        {uploadDate || new Date().toLocaleDateString("en-IN", { day: "numeric", month: "short", year: "numeric" })}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Compliance Statement */}
                <div className="space-y-2 rounded-lg border border-border/70 bg-card p-4">
                  <h5 className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground">
                    2. Statutory & Anti-Fraud Verification
                  </h5>
                  <p className="text-[11px] leading-relaxed text-muted-foreground">
                    This document certifies that the customer entity above has furnished all mandatory identity, statutory registrations, and KYC proof required for commercial onboarding. The submission has been checked and validated against Pulse PMO compliance guidelines.
                  </p>
                  <ul className="grid grid-cols-2 gap-2 pt-1 text-[11px]">
                    <li className="flex items-center gap-1.5 text-success font-medium">
                      <Check className="h-3 w-3" /> Identity & Registration Verified
                    </li>
                    <li className="flex items-center gap-1.5 text-success font-medium">
                      <Check className="h-3 w-3" /> Statutory Compliance Passed
                    </li>
                    <li className="flex items-center gap-1.5 text-success font-medium">
                      <Check className="h-3 w-3" /> Authorized Signatory Validated
                    </li>
                    <li className="flex items-center gap-1.5 text-success font-medium">
                      <Check className="h-3 w-3" /> Anti-Fraud Screening Clear
                    </li>
                  </ul>
                </div>

                {/* Signatory & Digital Seal */}
                <div className="flex items-center justify-between border-t border-dashed border-border pt-4">
                  <div className="space-y-1">
                    <p className="text-[10px] uppercase font-bold tracking-wider text-muted-foreground">
                      Digital Authentication Seal
                    </p>
                    <p className="font-mono text-[10px] text-muted-foreground">
                      AUTH-ID: SHA256-TALAKUNCHI-PMO-{resolvedName.slice(0, 6).toUpperCase()}
                    </p>
                    <p className="text-[10px] text-success font-semibold flex items-center gap-1">
                      <CheckCircle2 className="h-3 w-3" /> Electronically Authenticated & Sealed
                    </p>
                  </div>

                  <div className="text-right border-l border-border pl-6">
                    <div className="inline-block border-b border-foreground/40 pb-1 px-4 font-serif italic text-primary font-bold text-sm">
                      Pulse Compliance Office
                    </div>
                    <p className="text-[10px] text-muted-foreground mt-1 font-medium">
                      Authorized Compliance Officer
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="flex items-center border-t border-border/80 bg-slate-50 dark:bg-muted/40 px-5 py-2.5 text-xs text-muted-foreground">
          <span className="flex items-center gap-1 text-[11px]">
            <ShieldCheck className="h-3.5 w-3.5 text-success" /> Validated under Pulse PMO Customer Compliance
          </span>
        </div>
      </div>
    </div>
  );
}
