/**
 * On-screen facsimile of the two-sheet WBS workbook.
 *
 * Shown after Export WBS validation passes, so the user can review WBS Details
 * and Accounts Details before the file is written to the Downloads folder.
 */
import { useEffect, useState, type CSSProperties, type ReactNode } from "react";
import { createPortal } from "react-dom";
import { Download, X } from "lucide-react";
import type { WbsExportInput } from "@/lib/wbs-excel-export";
import { wbsWorkbookFileName } from "@/lib/wbs-excel-export";

const BRAND = "#1a5490";
const BAND = "#dce6f1";
const HEAD = "#eaf1f8";
const LABEL = "#f3f4f6";
const NOTE = "#fff3b0";
const BORDER = "1px solid #111827";
const DASH = "—";

const WBS_HEADERS = [
  "Service ID",
  "Service Name",
  "Service Quantity",
  "Resource Level",
  "Service Description",
  "Service Frequency",
  "Service Location",
  "Service Model",
  "Project Type",
  "Tools",
  "File Format",
  "Start Date",
  "End Date",
  "Tentative Total Days",
] as const;

const ACCOUNT_HEADERS = [
  "Service Name",
  "Milestone / Period",
  "Invoice Target Date",
  "Unit Price",
  "Qty",
  "Currency",
  "Invoice Amount",
  "Invoice Status",
  "Invoice Number",
  "Payment Status",
  "Date of Payment Received",
] as const;

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function text(v: unknown): string {
  const s = v === null || v === undefined ? "" : String(v).trim();
  return s === "" ? DASH : s;
}

function formatDate(iso: string): string {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec((iso ?? "").trim());
  if (!m) return DASH;
  return `${m[3]}-${MONTHS[Number(m[2]) - 1]}-${m[1]}`;
}

function formatMoney(amount: number, symbol: string): string {
  const n = Number(amount) || 0;
  return `${symbol || ""}${n.toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function joinSpocs(input: WbsExportInput, pick: "name" | "phone" | "email"): string {
  const vals = (input.spocs ?? [])
    .map((s) => s[pick].trim())
    .filter(Boolean);
  return vals.length ? Array.from(new Set(vals)).join(" / ") : DASH;
}

const cell: CSSProperties = {
  border: BORDER,
  padding: "6px 8px",
  fontSize: 11,
  verticalAlign: "middle",
  background: "#fff",
  color: "#111827",
};

const labelCell: CSSProperties = {
  ...cell,
  fontWeight: 700,
  background: LABEL,
  whiteSpace: "nowrap",
};

const bannerCell: CSSProperties = {
  ...cell,
  fontWeight: 700,
  background: BAND,
  color: BRAND,
  textAlign: "center",
};

const headCell: CSSProperties = {
  ...cell,
  fontWeight: 700,
  background: HEAD,
  textAlign: "center",
  whiteSpace: "nowrap",
};

function Field({
  label,
  value,
  valueColSpan = 1,
}: {
  label: string;
  value: ReactNode;
  valueColSpan?: number;
}) {
  return (
    <>
      <td style={labelCell}>{label}</td>
      <td colSpan={valueColSpan} style={cell}>
        {value}
      </td>
    </>
  );
}

function WbsSheet({ input }: { input: WbsExportInput }) {
  const totalDays = input.services.reduce((s, r) => s + (Number(r.totalDays) || 0), 0);
  return (
    <table style={{ borderCollapse: "collapse", width: "100%", minWidth: 1100, fontFamily: "Arial, sans-serif" }}>
      <colgroup>
        {WBS_HEADERS.map((h) => (
          <col key={h} />
        ))}
      </colgroup>
      <tbody>
        <tr>
          <td
            colSpan={2}
            rowSpan={2}
            style={{
              ...cell,
              textAlign: "center",
              fontWeight: 800,
              fontSize: 16,
              color: BRAND,
              letterSpacing: "0.04em",
            }}
          >
            TALAKUNCHI
          </td>
          <td
            colSpan={9}
            rowSpan={2}
            style={{
              ...cell,
              textAlign: "center",
              fontWeight: 800,
              fontSize: 20,
              textDecoration: "underline",
            }}
          >
            Work Breakdown Structure
          </td>
          <td
            colSpan={3}
            rowSpan={2}
            style={{ ...cell, background: HEAD, textAlign: "center", fontWeight: 700, color: BRAND }}
          >
            {text(input.customerName)}
          </td>
        </tr>
        <tr />
        <tr>
          <Field label="Project Name" value={text(input.projectName)} valueColSpan={4} />
          <Field label="Project ID" value={text(input.projectId)} valueColSpan={2} />
          <td style={labelCell}>WBS Date</td>
          <td colSpan={4} style={cell}>
            {formatDate(input.wbsDate)}
          </td>
        </tr>
        <tr>
          <Field label="Customer / Partner" value={text(input.customerName)} valueColSpan={4} />
          <Field label="End Customer / Sub-Venture" value={text(input.subVentureName)} valueColSpan={2} />
          <td style={labelCell}>WBS ID</td>
          <td colSpan={4} style={cell}>
            {text(input.wbsId)}
          </td>
        </tr>
        <tr>
          <td rowSpan={4} style={{ ...bannerCell, writingMode: "vertical-rl", transform: "rotate(180deg)" }}>
            Brief Details
          </td>
          <td colSpan={4} style={bannerCell}>
            SOW Details
          </td>
          <td colSpan={9} style={bannerCell}>
            SPOC Details
          </td>
        </tr>
        <tr>
          <td style={labelCell}>Department</td>
          <td colSpan={3} style={cell}>
            {text(input.department)}
          </td>
          <td colSpan={2} style={labelCell}>
            Name
          </td>
          <td colSpan={7} style={cell}>
            {joinSpocs(input, "name")}
          </td>
        </tr>
        <tr>
          <td style={labelCell}>Total Activities</td>
          <td colSpan={3} style={cell}>
            {input.totalActivities}
          </td>
          <td colSpan={2} style={labelCell}>
            Contact No
          </td>
          <td colSpan={7} style={cell}>
            {joinSpocs(input, "phone")}
          </td>
        </tr>
        <tr>
          <td style={labelCell}>UAT/Production env.</td>
          <td colSpan={3} style={cell}>
            {text(input.uatProductionEnv)}
          </td>
          <td colSpan={2} style={labelCell}>
            Email ID
          </td>
          <td colSpan={7} style={cell}>
            {joinSpocs(input, "email")}
          </td>
        </tr>
        <tr>
          <td colSpan={11} style={bannerCell}>
            Service Description
          </td>
          <td colSpan={3} style={bannerCell}>
            Duration
          </td>
        </tr>
        <tr>
          {WBS_HEADERS.map((h) => (
            <th key={h} style={headCell}>
              {h}
            </th>
          ))}
        </tr>
        {input.services.length === 0 ? (
          <tr>
            <td colSpan={14} style={{ ...cell, textAlign: "center", fontStyle: "italic", color: "#6b7280" }}>
              No services added.
            </td>
          </tr>
        ) : (
          input.services.map((s) => (
            <tr key={s.serviceId + s.serviceName}>
              <td style={{ ...cell, textAlign: "center" }}>{text(s.serviceId)}</td>
              <td style={cell}>{text(s.serviceName)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{s.qty}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(s.resourceLevel)}</td>
              <td style={{ ...cell, maxWidth: 280 }}>{text(s.description)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(s.frequency)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(s.location)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(s.serviceModel)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(s.projectType)}</td>
              <td style={cell}>{text(s.tools)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(s.fileFormat)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{formatDate(s.startDate)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{formatDate(s.endDate)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{s.totalDays}</td>
            </tr>
          ))
        )}
        <tr>
          <td colSpan={13} style={{ ...labelCell, textAlign: "right" }}>
            Total
          </td>
          <td style={{ ...labelCell, textAlign: "center" }}>{totalDays}</td>
        </tr>
        <tr>
          <td colSpan={2} style={labelCell}>
            Special Note:-
          </td>
          <td colSpan={12} style={{ ...cell, background: NOTE, color: "#7c2d12" }}>
            {text(input.specialNote)}
          </td>
        </tr>
      </tbody>
    </table>
  );
}

function AccountsSheet({ input }: { input: WbsExportInput }) {
  const money = (n: number) => formatMoney(n, input.accounts.currencySymbol);
  const total = input.invoices.reduce((s, i) => s + (Number(i.amount) || 0), 0);
  return (
    <table style={{ borderCollapse: "collapse", width: "100%", minWidth: 980, fontFamily: "Arial, sans-serif" }}>
      <tbody>
        <tr>
          <td
            colSpan={11}
            style={{
              ...cell,
              background: BRAND,
              color: "#fff",
              textAlign: "center",
              fontWeight: 800,
              fontSize: 18,
              padding: 10,
            }}
          >
            Accounts Details
          </td>
        </tr>
        <tr>
          <td colSpan={11} style={bannerCell}>
            Project / Billing Information
          </td>
        </tr>
        <tr>
          <Field label="Project Name" value={text(input.projectName)} valueColSpan={2} />
          <Field label="Project ID" value={text(input.projectId)} valueColSpan={2} />
          <Field label="WBS ID" value={text(input.wbsId)} valueColSpan={3} />
        </tr>
        <tr>
          <Field label="Customer / Partner" value={text(input.customerName)} valueColSpan={2} />
          <Field label="Sub-Venture" value={text(input.subVentureName)} valueColSpan={2} />
          <Field label="Currency" value={text(input.accounts.currency)} valueColSpan={3} />
        </tr>
        <tr>
          <Field label="Billing Model" value={text(input.accounts.billingModel)} valueColSpan={2} />
          <Field label="Payment Terms" value={text(input.accounts.paymentTerms)} valueColSpan={2} />
          <Field label="PO Status" value={text(input.accounts.poStatus)} valueColSpan={3} />
        </tr>
        <tr>
          <Field label="PO Number" value={text(input.accounts.poNumber)} valueColSpan={2} />
          <Field label="PO Date" value={formatDate(input.accounts.poDate)} valueColSpan={2} />
          <Field label="Target Date" value={formatDate(input.accounts.targetDate)} valueColSpan={3} />
        </tr>
        <tr>
          <td colSpan={11} style={{ ...bannerCell, paddingTop: 10 }}>
            Invoice Scheduling
          </td>
        </tr>
        <tr>
          {ACCOUNT_HEADERS.map((h) => (
            <th key={h} style={headCell}>
              {h}
            </th>
          ))}
        </tr>
        {input.invoices.length === 0 ? (
          <tr>
            <td colSpan={11} style={{ ...cell, textAlign: "center", fontStyle: "italic", color: "#6b7280" }}>
              No invoice schedule generated — select a Billing Model in Section B.
            </td>
          </tr>
        ) : (
          input.invoices.map((inv, i) => (
            <tr key={`${inv.invoiceNumber}-${i}`}>
              <td style={cell}>{text(inv.serviceName)}</td>
              <td style={cell}>{text(inv.milestone)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{formatDate(inv.targetDate)}</td>
              <td style={{ ...cell, textAlign: "right" }}>{money(inv.unitPrice)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{inv.qty}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(inv.currency)}</td>
              <td style={{ ...cell, textAlign: "right" }}>{money(inv.amount)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(inv.invoiceStatus)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(inv.invoiceNumber)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{text(inv.paymentStatus)}</td>
              <td style={{ ...cell, textAlign: "center" }}>{formatDate(inv.paymentDate)}</td>
            </tr>
          ))
        )}
        <tr>
          <td colSpan={6} style={{ ...labelCell, textAlign: "right" }}>
            Total Invoice Value
          </td>
          <td colSpan={5} style={{ ...labelCell, textAlign: "right" }}>
            {money(total)}
          </td>
        </tr>
        <tr>
          <td colSpan={11} style={bannerCell}>
            Comments / Notes
          </td>
        </tr>
        <tr>
          <td colSpan={11} style={{ ...cell, minHeight: 48, verticalAlign: "top" }}>
            {text(input.accounts.comments)}
          </td>
        </tr>
      </tbody>
    </table>
  );
}

export function WbsExcelPreviewModal({
  open,
  input,
  downloading,
  onClose,
  onDownload,
}: {
  open: boolean;
  input: WbsExportInput | null;
  downloading: boolean;
  onClose: () => void;
  onDownload: () => void;
}) {
  const [tab, setTab] = useState<"wbs" | "accounts">("wbs");
  useEffect(() => {
    if (open) setTab("wbs");
  }, [open]);
  if (!open || !input || typeof document === "undefined") return null;

  const fileName = wbsWorkbookFileName(input.wbsId);

  return createPortal(
    <div
      role="dialog"
      aria-modal="true"
      aria-label="WBS Excel preview"
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 1600,
        background: "rgba(17,24,39,0.55)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: 16,
      }}
      onClick={(e) => {
        if (e.target === e.currentTarget && !downloading) onClose();
      }}
    >
      <div
        style={{
          width: "min(1280px, 96vw)",
          height: "min(88vh, 920px)",
          background: "#fff",
          borderRadius: 12,
          boxShadow: "0 20px 50px rgba(0,0,0,0.28)",
          display: "flex",
          flexDirection: "column",
          overflow: "hidden",
          fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif",
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            gap: 12,
            padding: "12px 16px",
            background: BRAND,
            color: "#fff",
          }}
        >
          <div>
            <div style={{ fontSize: 15, fontWeight: 700 }}>WBS Preview</div>
            <div style={{ fontSize: 12, opacity: 0.85 }}>{fileName} — review both sheets, then download</div>
          </div>
          <button
            type="button"
            onClick={onClose}
            disabled={downloading}
            aria-label="Close preview"
            style={{
              background: "transparent",
              border: "none",
              color: "#fff",
              cursor: downloading ? "not-allowed" : "pointer",
              padding: 4,
            }}
          >
            <X size={20} />
          </button>
        </div>

        <div style={{ display: "flex", gap: 0, borderBottom: "1px solid #e5e7eb", background: "#f9fafb" }}>
          {(
            [
              ["wbs", "WBS Details"],
              ["accounts", "Accounts Details"],
            ] as const
          ).map(([id, label]) => (
            <button
              key={id}
              type="button"
              onClick={() => setTab(id)}
              style={{
                padding: "10px 18px",
                border: "none",
                background: "transparent",
                fontWeight: 700,
                fontSize: 13,
                color: tab === id ? BRAND : "#6b7280",
                borderBottom: tab === id ? `3px solid ${BRAND}` : "3px solid transparent",
                cursor: "pointer",
              }}
            >
              {label}
            </button>
          ))}
        </div>

        <div style={{ flex: 1, overflow: "auto", padding: 16, background: "#f3f4f6" }}>
          <div
            style={{
              background: "#fff",
              padding: 8,
              border: "1px solid #d1d5db",
              boxShadow: "0 1px 2px rgba(0,0,0,0.04)",
            }}
          >
            {tab === "wbs" ? <WbsSheet input={input} /> : <AccountsSheet input={input} />}
          </div>
        </div>

        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            gap: 12,
            padding: "12px 16px",
            borderTop: "1px solid #e5e7eb",
            background: "#fff",
          }}
        >
          <div style={{ fontSize: 12, color: "#6b7280" }}>
            Download saves <strong>{fileName}</strong> to your PC’s Downloads folder.
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            <button
              type="button"
              onClick={onClose}
              disabled={downloading}
              style={{
                padding: "10px 16px",
                border: "1px solid #d1d5db",
                borderRadius: 6,
                background: "#fff",
                fontWeight: 600,
                fontSize: 13,
                cursor: downloading ? "not-allowed" : "pointer",
              }}
            >
              Close
            </button>
            <button
              type="button"
              onClick={onDownload}
              disabled={downloading}
              style={{
                padding: "10px 16px",
                border: "none",
                borderRadius: 6,
                background: "#1a84d4",
                color: "#fff",
                fontWeight: 600,
                fontSize: 13,
                cursor: downloading ? "not-allowed" : "pointer",
                display: "flex",
                alignItems: "center",
                gap: 6,
                opacity: downloading ? 0.7 : 1,
              }}
            >
              <Download size={16} />
              {downloading ? "Downloading…" : "Download Excel"}
            </button>
          </div>
        </div>
      </div>
    </div>,
    document.body,
  );
}
