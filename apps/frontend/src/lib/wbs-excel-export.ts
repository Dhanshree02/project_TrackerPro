/**
 * Builds the "Export WBS" workbook from the Project Onboarding form.
 *
 * Two sheets: "WBS Details" (laid out like the company WBS template) and
 * "Accounts Details" (Section B + the invoice schedule the form already
 * generated). This module only formats data — every value is passed in from the
 * onboarding state, so no business rule is duplicated here.
 */
import type { Borders, Fill, Worksheet } from "exceljs";
import type { SpocContact } from "@/lib/sub-venture-spoc";

const COMPANY_NAME = "TALAKUNCHI";

const BRAND = "FF1A5490";
const BAND_FILL = "FFDCE6F1";
const HEAD_FILL = "FFEAF1F8";
const LABEL_FILL = "FFF3F4F6";
const NOTE_FILL = "FFFFF3B0";

export interface WbsExportService {
  serviceId: string;
  serviceName: string;
  qty: number;
  resourceLevel: string;
  description: string;
  frequency: string;
  location: string;
  serviceModel: string;
  projectType: string;
  tools: string;
  fileFormat: string;
  startDate: string;
  endDate: string;
  totalDays: number;
}

export interface WbsExportInvoice {
  serviceName: string;
  milestone: string;
  targetDate: string;
  unitPrice: number;
  qty: number;
  currency: string;
  amount: number;
  invoiceStatus: string;
  invoiceNumber: string;
  paymentStatus: string;
  paymentDate: string;
}

export interface WbsExportInput {
  projectName: string;
  projectId: string;
  wbsId: string;
  wbsDate: string;
  customerName: string;
  subVentureName: string;
  department: string;
  totalActivities: number;
  uatProductionEnv: string;
  spocs: SpocContact[];
  services: WbsExportService[];
  specialNote: string;
  accounts: {
    billingModel: string;
    paymentTerms: string;
    currency: string;
    currencySymbol: string;
    poStatus: string;
    poNumber: string;
    poDate: string;
    targetDate: string;
    comments: string;
  };
  invoices: WbsExportInvoice[];
}

// ─── Small style helpers ─────────────────────────────────────────────────────

const THIN: Partial<Borders> = {
  top: { style: "thin", color: { argb: "FF000000" } },
  left: { style: "thin", color: { argb: "FF000000" } },
  bottom: { style: "thin", color: { argb: "FF000000" } },
  right: { style: "thin", color: { argb: "FF000000" } },
};

const fill = (argb: string): Fill => ({ type: "pattern", pattern: "solid", fgColor: { argb } });

const DASH = "—";

function text(v: unknown): string {
  const s = v === null || v === undefined ? "" : String(v).trim();
  return s === "" ? DASH : s;
}

/** "YYYY-MM-DD" → a UTC-midnight Date so ExcelJS writes an exact day serial. */
function toExcelDate(iso: string): Date | null {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec((iso ?? "").trim());
  if (!m) return null;
  return new Date(Date.UTC(Number(m[1]), Number(m[2]) - 1, Number(m[3])));
}

const DATE_FMT = "dd-mmm-yyyy";

/** Excel number format for the workbook currency, e.g. '"₹" #,##0.00'. */
function currencyFormat(symbol: string): string {
  const s = (symbol || "").replace(/"/g, "");
  return s ? `"${s}" #,##0.00` : "#,##0.00";
}

/** Applies borders (and optionally a fill) to every cell of an "A1:D4" range. */
function frame(ws: Worksheet, range: string, opts: { fillArgb?: string } = {}) {
  const [from, to] = range.split(":");
  const a = ws.getCell(from);
  const b = ws.getCell(to ?? from);
  for (let r = Number(a.row); r <= Number(b.row); r++) {
    for (let c = Number(a.col); c <= Number(b.col); c++) {
      const cell = ws.getCell(r, c);
      cell.border = THIN;
      if (opts.fillArgb) cell.fill = fill(opts.fillArgb);
    }
  }
}

/** Merged section banner, e.g. "SOW Details" / "Service Description". */
function banner(ws: Worksheet, range: string, label: string, fillArgb = BAND_FILL) {
  ws.mergeCells(range);
  const cell = ws.getCell(range.split(":")[0]);
  cell.value = label;
  cell.font = { bold: true, size: 11, color: { argb: BRAND } };
  cell.alignment = { horizontal: "center", vertical: "middle" };
  frame(ws, range, { fillArgb });
}

/** Bold label cell + merged value cell. */
function field(ws: Worksheet, labelRange: string, label: string, valueRange: string, value: unknown) {
  if (labelRange.includes(":")) ws.mergeCells(labelRange);
  if (valueRange.includes(":")) ws.mergeCells(valueRange);

  const l = ws.getCell(labelRange.split(":")[0]);
  l.value = label;
  l.font = { bold: true, size: 10 };
  l.alignment = { horizontal: "left", vertical: "middle" };
  frame(ws, labelRange, { fillArgb: LABEL_FILL });

  const v = ws.getCell(valueRange.split(":")[0]);
  v.value = typeof value === "number" ? value : text(value);
  v.font = { size: 10 };
  v.alignment = { horizontal: "left", vertical: "middle", wrapText: true };
  frame(ws, valueRange);
}

/**
 * Renders the company wordmark as a PNG so the header carries a real logo image
 * instead of plain text. Returns null outside the browser (SSR) or if the canvas
 * is unavailable, in which case the caller falls back to a styled text cell.
 */
function companyLogoPng(): string | null {
  if (typeof document === "undefined") return null;
  try {
    const w = 480;
    const h = 140;
    const canvas = document.createElement("canvas");
    canvas.width = w;
    canvas.height = h;
    const ctx = canvas.getContext("2d");
    if (!ctx) return null;

    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, w, h);

    ctx.fillStyle = "#1a5490";
    ctx.fillRect(24, 42, 56, 56);
    ctx.fillStyle = "#ffffff";
    ctx.font = "bold 38px Arial, sans-serif";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("T", 52, 72);

    ctx.fillStyle = "#1a5490";
    ctx.font = "bold 40px Arial, sans-serif";
    ctx.textAlign = "left";
    ctx.fillText(COMPANY_NAME, 96, 62);

    ctx.fillStyle = "#6b7280";
    ctx.font = "16px Arial, sans-serif";
    ctx.fillText("Work Breakdown Structure", 98, 94);

    return canvas.toDataURL("image/png");
  } catch {
    return null;
  }
}

function triggerDownload(buffer: ArrayBuffer, fileName: string) {
  const blob = new Blob([buffer], {
    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = fileName;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

/**
 * Browser download name is the WBS ID, e.g. `IN-2026-27-C002-P004.xlsx`.
 * Illegal filename characters (`/ \ : * ? " < > |`) become hyphens.
 */
export function wbsWorkbookFileName(wbsId: string): string {
  const cleaned = (wbsId || "")
    .replace(/[\\/:*?"<>|]+/g, "-")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "")
    .trim();
  if (!cleaned || cleaned === "—" || cleaned === "-") return "WBS.xlsx";
  return `${cleaned}.xlsx`;
}

// ─── Sheet 1: WBS Details ────────────────────────────────────────────────────

const WBS_COLUMNS: { header: string; width: number }[] = [
  { header: "Service ID", width: 18 },
  { header: "Service Name", width: 26 },
  { header: "Service Quantity", width: 10 },
  { header: "Resource Level", width: 18 },
  { header: "Service Description", width: 44 },
  { header: "Service Frequency", width: 12 },
  { header: "Service Location", width: 16 },
  { header: "Service Model", width: 16 },
  { header: "Project Type", width: 14 },
  { header: "Tools", width: 20 },
  { header: "File Format", width: 12 },
  { header: "Start Date", width: 14 },
  { header: "End Date", width: 14 },
  { header: "Tentative Total Days", width: 13 },
];

function buildWbsSheet(ws: Worksheet, input: WbsExportInput, logo: string | null, addImage: (b64: string) => number) {
  // Width only — passing `header` here would make ExcelJS write a second header row at row 1.
  ws.columns = WBS_COLUMNS.map((c) => ({ width: c.width }));

  // ── Title band (rows 1–2) ──
  ws.getRow(1).height = 26;
  ws.getRow(2).height = 26;

  ws.mergeCells("A1:B2");
  frame(ws, "A1:B2");
  if (logo) {
    addImage(logo);
  } else {
    const l = ws.getCell("A1");
    l.value = COMPANY_NAME;
    l.font = { bold: true, size: 16, color: { argb: BRAND } };
    l.alignment = { horizontal: "center", vertical: "middle" };
  }

  ws.mergeCells("C1:K2");
  const title = ws.getCell("C1");
  title.value = "Work Breakdown Structure";
  title.font = { bold: true, size: 20, underline: true, color: { argb: "FF111827" } };
  title.alignment = { horizontal: "center", vertical: "middle" };
  frame(ws, "C1:K2");

  ws.mergeCells("L1:N2");
  const clientCell = ws.getCell("L1");
  clientCell.value = text(input.customerName);
  clientCell.font = { bold: true, size: 12, color: { argb: BRAND } };
  clientCell.alignment = { horizontal: "center", vertical: "middle", wrapText: true };
  frame(ws, "L1:N2", { fillArgb: HEAD_FILL });

  // ── Project information (rows 3–4) ──
  ws.getRow(3).height = 20;
  ws.getRow(4).height = 20;

  field(ws, "A3", "Project Name", "B3:E3", input.projectName);
  field(ws, "F3:G3", "Project ID", "H3:I3", input.projectId);
  field(ws, "J3", "WBS Date", "K3:N3", input.wbsDate);
  const wbsDate = toExcelDate(input.wbsDate);
  if (wbsDate) {
    const c = ws.getCell("K3");
    c.value = wbsDate;
    c.numFmt = DATE_FMT;
  }

  field(ws, "A4", "Customer / Partner", "B4:E4", input.customerName);
  field(ws, "F4:G4", "End Customer / Sub-Venture", "H4:I4", input.subVentureName);
  field(ws, "J4", "WBS ID", "K4:N4", input.wbsId);

  // ── Brief details: SOW + SPOC (rows 5–8) ──
  ws.mergeCells("A5:A8");
  const brief = ws.getCell("A5");
  brief.value = "Brief Details";
  brief.font = { bold: true, size: 11, color: { argb: BRAND } };
  brief.alignment = { horizontal: "center", vertical: "middle", wrapText: true };
  frame(ws, "A5:A8", { fillArgb: BAND_FILL });

  banner(ws, "B5:E5", "SOW Details");
  banner(ws, "F5:N5", "SPOC Details");

  // Merged cells never auto-fit, so the SOW / SPOC rows need explicit heights.
  for (let r = 5; r <= 8; r++) ws.getRow(r).height = 19;

  field(ws, "B6", "Department", "C6:E6", input.department);
  field(ws, "B7", "Total Activities", "C7:E7", input.totalActivities);
  field(ws, "B8", "UAT/Production env.", "C8:E8", input.uatProductionEnv);

  const spocs = input.spocs ?? [];
  const join = (pick: (s: SpocContact) => string) => {
    const vals = spocs.map(pick).map((v) => v.trim()).filter(Boolean);
    return vals.length ? Array.from(new Set(vals)).join(" / ") : "";
  };
  field(ws, "F6:G6", "Name", "H6:N6", join((s) => s.name));
  field(ws, "F7:G7", "Contact No", "H7:N7", join((s) => s.phone));
  field(ws, "F8:G8", "Email ID", "H8:N8", join((s) => s.email));

  // ── Service table (rows 9 group header, 10 column headers) ──
  banner(ws, "A9:K9", "Service Description");
  banner(ws, "L9:N9", "Duration");

  const headerRow = ws.getRow(10);
  headerRow.height = 34;
  WBS_COLUMNS.forEach((col, i) => {
    const cell = headerRow.getCell(i + 1);
    cell.value = col.header;
    cell.font = { bold: true, size: 10, color: { argb: "FF111827" } };
    cell.alignment = { horizontal: "center", vertical: "middle", wrapText: true };
    cell.fill = fill(HEAD_FILL);
    cell.border = THIN;
  });

  let r = 11;
  for (const s of input.services) {
    const row = ws.getRow(r);
    row.getCell(1).value = text(s.serviceId);
    row.getCell(2).value = text(s.serviceName);
    row.getCell(3).value = Number(s.qty) || 0;
    row.getCell(4).value = text(s.resourceLevel);
    row.getCell(5).value = text(s.description);
    row.getCell(6).value = text(s.frequency);
    row.getCell(7).value = text(s.location);
    row.getCell(8).value = text(s.serviceModel);
    row.getCell(9).value = text(s.projectType);
    row.getCell(10).value = text(s.tools);
    row.getCell(11).value = text(s.fileFormat);

    const start = toExcelDate(s.startDate);
    const end = toExcelDate(s.endDate);
    row.getCell(12).value = start ?? DASH;
    row.getCell(13).value = end ?? DASH;
    if (start) row.getCell(12).numFmt = DATE_FMT;
    if (end) row.getCell(13).numFmt = DATE_FMT;
    row.getCell(14).value = Number(s.totalDays) || 0;

    for (let c = 1; c <= WBS_COLUMNS.length; c++) {
      const cell = row.getCell(c);
      cell.border = THIN;
      cell.font = { size: 10 };
      const centered = [3, 6, 7, 8, 9, 11, 12, 13, 14].includes(c);
      cell.alignment = {
        horizontal: centered ? "center" : "left",
        vertical: "middle",
        wrapText: true,
      };
    }
    r++;
  }

  if (input.services.length === 0) {
    ws.mergeCells(`A${r}:N${r}`);
    const empty = ws.getCell(`A${r}`);
    empty.value = "No services added.";
    empty.alignment = { horizontal: "center", vertical: "middle" };
    empty.font = { size: 10, italic: true, color: { argb: "FF6B7280" } };
    frame(ws, `A${r}:N${r}`);
    r++;
  }

  // ── Total row ──
  const totalRow = r;
  ws.mergeCells(`A${totalRow}:M${totalRow}`);
  const totalLabel = ws.getCell(`A${totalRow}`);
  totalLabel.value = "Total";
  totalLabel.font = { bold: true, size: 10 };
  totalLabel.alignment = { horizontal: "right", vertical: "middle" };
  frame(ws, `A${totalRow}:M${totalRow}`, { fillArgb: LABEL_FILL });

  const totalDays = input.services.reduce((sum, s) => sum + (Number(s.totalDays) || 0), 0);
  const totalCell = ws.getCell(`N${totalRow}`);
  totalCell.value = totalDays;
  totalCell.font = { bold: true, size: 10 };
  totalCell.alignment = { horizontal: "center", vertical: "middle" };
  totalCell.border = THIN;
  totalCell.fill = fill(LABEL_FILL);

  // ── Special note ──
  const noteRow = totalRow + 2;
  const noteLabel = ws.getCell(`A${noteRow}`);
  noteLabel.value = "Special Note:-";
  noteLabel.font = { bold: true, size: 10 };
  noteLabel.alignment = { horizontal: "left", vertical: "middle" };
  noteLabel.border = THIN;
  noteLabel.fill = fill(LABEL_FILL);

  ws.mergeCells(`B${noteRow}:N${noteRow}`);
  const note = ws.getCell(`B${noteRow}`);
  note.value = text(input.specialNote);
  note.font = { size: 10, color: { argb: "FF7C2D12" } };
  note.alignment = { horizontal: "left", vertical: "middle", wrapText: true };
  frame(ws, `B${noteRow}:N${noteRow}`, { fillArgb: NOTE_FILL });
  ws.getRow(noteRow).height = 32;

  // Do not freeze the header block. Freezing rows 1–10 made the WBS header stay
  // on screen while scrolling the service table, which looked like a second copy.
  ws.views = [{ state: "normal", showGridLines: true }];
  ws.pageSetup = {
    orientation: "landscape",
    paperSize: 9,
    fitToPage: true,
    fitToWidth: 1,
    fitToHeight: 0,
    horizontalCentered: true,
    margins: { left: 0.3, right: 0.3, top: 0.4, bottom: 0.4, header: 0.2, footer: 0.2 },
  };
}

// ─── Sheet 2: Accounts Details ───────────────────────────────────────────────

const ACCOUNT_COLUMNS: { header: string; width: number }[] = [
  { header: "Service Name", width: 30 },
  { header: "Milestone / Period", width: 24 },
  { header: "Invoice Target Date", width: 16 },
  { header: "Unit Price", width: 15 },
  { header: "Qty", width: 7 },
  { header: "Currency", width: 10 },
  { header: "Invoice Amount", width: 17 },
  { header: "Invoice Status", width: 15 },
  { header: "Invoice Number", width: 18 },
  { header: "Payment Status", width: 16 },
  { header: "Date of Payment Received", width: 20 },
];

function buildAccountsSheet(ws: Worksheet, input: WbsExportInput) {
  // Width only — passing `header` here would make ExcelJS write a second header row at row 1.
  ws.columns = ACCOUNT_COLUMNS.map((c) => ({ width: c.width }));
  const money = currencyFormat(input.accounts.currencySymbol);

  ws.mergeCells("A1:K1");
  const title = ws.getCell("A1");
  title.value = "Accounts Details";
  title.font = { bold: true, size: 18, color: { argb: "FFFFFFFF" } };
  title.alignment = { horizontal: "center", vertical: "middle" };
  frame(ws, "A1:K1", { fillArgb: BRAND });
  ws.getRow(1).height = 30;

  banner(ws, "A2:K2", "Project / Billing Information");

  // Info rows are merged, and Excel never auto-fits merged cells — give them a
  // height that comfortably holds one line so long values are not clipped.
  for (let r = 3; r <= 6; r++) ws.getRow(r).height = 20;

  field(ws, "A3", "Project Name", "B3:C3", input.projectName);
  field(ws, "D3", "Project ID", "E3:G3", input.projectId);
  field(ws, "H3", "WBS ID", "I3:K3", input.wbsId);

  field(ws, "A4", "Customer / Partner", "B4:C4", input.customerName);
  field(ws, "D4", "Sub-Venture", "E4:G4", input.subVentureName);
  field(ws, "H4", "Currency", "I4:K4", input.accounts.currency);

  field(ws, "A5", "Billing Model", "B5:C5", input.accounts.billingModel);
  field(ws, "D5", "Payment Terms", "E5:G5", input.accounts.paymentTerms);
  field(ws, "H5", "PO Status", "I5:K5", input.accounts.poStatus);

  field(ws, "A6", "PO Number", "B6:C6", input.accounts.poNumber);
  field(ws, "D6", "PO Date", "E6:G6", input.accounts.poDate);
  field(ws, "H6", "Target Date", "I6:K6", input.accounts.targetDate);

  const poDate = toExcelDate(input.accounts.poDate);
  if (poDate) {
    const c = ws.getCell("E6");
    c.value = poDate;
    c.numFmt = DATE_FMT;
    c.alignment = { horizontal: "left", vertical: "middle" };
  }
  const target = toExcelDate(input.accounts.targetDate);
  if (target) {
    const c = ws.getCell("I6");
    c.value = target;
    c.numFmt = DATE_FMT;
    c.alignment = { horizontal: "left", vertical: "middle" };
  }

  banner(ws, "A8:K8", "Invoice Scheduling");

  const headerRow = ws.getRow(9);
  headerRow.height = 30;
  ACCOUNT_COLUMNS.forEach((col, i) => {
    const cell = headerRow.getCell(i + 1);
    cell.value = col.header;
    cell.font = { bold: true, size: 10, color: { argb: "FF111827" } };
    cell.alignment = { horizontal: "center", vertical: "middle", wrapText: true };
    cell.fill = fill(HEAD_FILL);
    cell.border = THIN;
  });

  let r = 10;
  for (const inv of input.invoices) {
    const row = ws.getRow(r);
    row.getCell(1).value = text(inv.serviceName);
    row.getCell(2).value = text(inv.milestone);

    const targetDate = toExcelDate(inv.targetDate);
    row.getCell(3).value = targetDate ?? DASH;
    if (targetDate) row.getCell(3).numFmt = DATE_FMT;

    row.getCell(4).value = Number(inv.unitPrice) || 0;
    row.getCell(4).numFmt = money;
    row.getCell(5).value = Number(inv.qty) || 0;
    row.getCell(6).value = text(inv.currency);
    row.getCell(7).value = Number(inv.amount) || 0;
    row.getCell(7).numFmt = money;
    row.getCell(8).value = text(inv.invoiceStatus);
    row.getCell(9).value = text(inv.invoiceNumber);
    row.getCell(10).value = text(inv.paymentStatus);

    const paid = toExcelDate(inv.paymentDate);
    row.getCell(11).value = paid ?? DASH;
    if (paid) row.getCell(11).numFmt = DATE_FMT;

    for (let c = 1; c <= ACCOUNT_COLUMNS.length; c++) {
      const cell = row.getCell(c);
      cell.border = THIN;
      cell.font = { size: 10 };
      const right = c === 4 || c === 7;
      const centered = [3, 5, 6, 8, 9, 10, 11].includes(c);
      cell.alignment = {
        horizontal: right ? "right" : centered ? "center" : "left",
        vertical: "middle",
        wrapText: true,
      };
    }
    r++;
  }

  if (input.invoices.length === 0) {
    ws.mergeCells(`A${r}:K${r}`);
    const empty = ws.getCell(`A${r}`);
    empty.value = "No invoice schedule generated — select a Billing Model in Section B.";
    empty.alignment = { horizontal: "center", vertical: "middle" };
    empty.font = { size: 10, italic: true, color: { argb: "FF6B7280" } };
    frame(ws, `A${r}:K${r}`);
    r++;
  }

  const totalRow = r;
  ws.mergeCells(`A${totalRow}:F${totalRow}`);
  const label = ws.getCell(`A${totalRow}`);
  label.value = "Total Invoice Value";
  label.font = { bold: true, size: 10 };
  label.alignment = { horizontal: "right", vertical: "middle" };
  frame(ws, `A${totalRow}:F${totalRow}`, { fillArgb: LABEL_FILL });

  const sum = input.invoices.reduce((s, i) => s + (Number(i.amount) || 0), 0);
  const sumCell = ws.getCell(`G${totalRow}`);
  sumCell.value = sum;
  sumCell.numFmt = money;
  sumCell.font = { bold: true, size: 10 };
  sumCell.alignment = { horizontal: "right", vertical: "middle" };
  frame(ws, `G${totalRow}:K${totalRow}`, { fillArgb: LABEL_FILL });

  const commentsHeader = totalRow + 2;
  banner(ws, `A${commentsHeader}:K${commentsHeader}`, "Comments / Notes");

  const commentsRow = commentsHeader + 1;
  ws.mergeCells(`A${commentsRow}:K${commentsRow}`);
  const comments = ws.getCell(`A${commentsRow}`);
  comments.value = text(input.accounts.comments);
  comments.font = { size: 10 };
  comments.alignment = { horizontal: "left", vertical: "top", wrapText: true };
  frame(ws, `A${commentsRow}:K${commentsRow}`);
  ws.getRow(commentsRow).height = 64;

  // Do not freeze the billing + invoice header. Freezing rows 1–9 kept the
  // Accounts title and billing grid on screen while scrolling, which looked
  // like a second copy of the sheet.
  ws.views = [{ state: "normal", showGridLines: true }];
  ws.pageSetup = {
    orientation: "landscape",
    paperSize: 9,
    fitToPage: true,
    fitToWidth: 1,
    fitToHeight: 0,
    horizontalCentered: true,
    margins: { left: 0.3, right: 0.3, top: 0.4, bottom: 0.4, header: 0.2, footer: 0.2 },
  };
}

// ─── Entry point ─────────────────────────────────────────────────────────────

/** Builds the two-sheet workbook. Exported separately so it can be unit-tested. */
export async function buildWbsWorkbook(input: WbsExportInput) {
  const mod = await import("exceljs");
  const ExcelJS = (mod as unknown as { default?: typeof mod }).default ?? mod;

  const workbook = new ExcelJS.Workbook();
  workbook.creator = COMPANY_NAME;
  workbook.created = new Date();

  const wbsSheet = workbook.addWorksheet("WBS Details");
  const logo = companyLogoPng();
  buildWbsSheet(wbsSheet, input, logo, (base64) => {
    const id = workbook.addImage({ base64, extension: "png" });
    wbsSheet.addImage(id, {
      tl: { col: 0.15, row: 0.15 },
      ext: { width: 168, height: 46 },
      editAs: "oneCell",
    });
    return id;
  });

  const accountsSheet = workbook.addWorksheet("Accounts Details");
  buildAccountsSheet(accountsSheet, input);
  return workbook;
}

/** Builds `{WBS-ID}.xlsx` and starts a normal browser download into the user's Downloads folder. */
export async function exportWbsWorkbook(input: WbsExportInput): Promise<string> {
  const workbook = await buildWbsWorkbook(input);
  const buffer = await workbook.xlsx.writeBuffer();
  const fileName = wbsWorkbookFileName(input.wbsId);
  triggerDownload(buffer as ArrayBuffer, fileName);
  return fileName;
}
