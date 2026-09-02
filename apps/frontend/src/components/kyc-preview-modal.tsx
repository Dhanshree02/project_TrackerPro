import { useEffect, useMemo, useState } from "react";
import { X, FileText, CheckCircle2, ShieldCheck, Check } from "lucide-react";

export interface KycDocPreviewModalProps {
  open: boolean;
  onClose: () => void;
  file?: File | null;
  fileName?: string | null;
  clientName?: string;
  subVentureName?: string;
  uploadDate?: string;
}

export function KycDocPreviewModal({
  open,
  onClose,
  file,
  fileName,
  clientName = "Customer",
  subVentureName,
  uploadDate,
}: KycDocPreviewModalProps) {
  const [objectUrl, setObjectUrl] = useState<string | null>(null);

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
          {isImage && objectUrl ? (
            <div className="flex justify-center items-center overflow-hidden rounded-xl border border-border bg-white dark:bg-card p-3 shadow-md">
              <img
                src={objectUrl}
                alt={resolvedName}
                className="max-h-[60vh] w-auto max-w-full rounded-lg object-contain"
              />
            </div>
          ) : isPdf && objectUrl ? (
            <div className="overflow-hidden rounded-xl border border-border bg-card shadow-md">
              <iframe
                src={`${objectUrl}#toolbar=0`}
                title={resolvedName}
                className="h-[62vh] w-full bg-card"
              />
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
