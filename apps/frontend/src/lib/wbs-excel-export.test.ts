import { describe, expect, it } from "vitest";
import { buildWbsWorkbook, wbsWorkbookFileName, type WbsExportInput } from "./wbs-excel-export";

const input: WbsExportInput = {
  projectName: "Paymentz Annual Audit",
  projectId: "PRJ-2026-0007",
  wbsId: "IN/2025/26/398/270",
  wbsDate: "2026-03-06",
  customerName: "Paymentz Pvt Ltd",
  subVentureName: "Paymentz Retail",
  department: "Penetration Testing, Consulting",
  totalActivities: 2,
  uatProductionEnv: "NA",
  spocs: [{ name: "Raj Agarwal", phone: "9321534566", email: "raj.agarwal@paymentz.com", designation: "CISO" }],
  services: [
    {
      serviceId: "WBS-01",
      serviceName: "External Network Penetration Testing",
      qty: 4,
      resourceLevel: "L1=2, L2=1, Senior=1",
      description: "SAR and IS Audit per RBI circular",
      frequency: "Once",
      location: "Onsite — Mumbai HO",
      serviceModel: "Initial + 1 Re-test",
      projectType: "Annual",
      tools: "Nessus, Metasploit",
      fileFormat: "PDF",
      startDate: "2026-03-06",
      endDate: "2026-04-06",
      totalDays: 20,
    },
    {
      serviceId: "WBS-02",
      serviceName: "Cyber Security Audit",
      qty: 1,
      resourceLevel: "Senior",
      description: "Master directions on cyber resilience",
      frequency: "Yearly",
      location: "Offsite",
      serviceModel: "Initial Test",
      projectType: "Annual",
      tools: "Hybrid",
      fileFormat: "Excel",
      startDate: "2026-03-06",
      endDate: "2026-04-06",
      totalDays: 11,
    },
  ],
  specialNote: "Kick-Off to be scheduled for 9th March",
  accounts: {
    billingModel: "Quarterly Arrears",
    paymentTerms: "Net 30",
    currency: "INR",
    currencySymbol: "₹",
    poStatus: "Received",
    poNumber: "PO-8842",
    poDate: "2026-03-02",
    targetDate: "2026-04-10",
    comments: "Invoice to accounts@paymentz.com with the WBS attached.",
  },
  invoices: [
    {
      serviceName: "External Network Penetration Testing",
      milestone: "Quarter 1",
      targetDate: "2026-06-30",
      unitPrice: 60000,
      qty: 4,
      currency: "INR",
      amount: 240000,
      invoiceStatus: "Not Raised",
      invoiceNumber: "INV-2026-0001",
      paymentStatus: "Not Received",
      paymentDate: "",
    },
    {
      serviceName: "Cyber Security Audit",
      milestone: "Quarter 1",
      targetDate: "",
      unitPrice: 80000,
      qty: 1,
      currency: "INR",
      amount: 20000,
      invoiceStatus: "Not Raised",
      invoiceNumber: "INV-2026-0002",
      paymentStatus: "Not Received",
      paymentDate: "",
    },
  ],
};

describe("buildWbsWorkbook", () => {
  it("produces WBS Details + Accounts Details with the expected layout", async () => {
    const wb = await buildWbsWorkbook(input);
    expect(wb.worksheets.map((w) => w.name)).toEqual(["WBS Details", "Accounts Details"]);

    const wbs = wb.getWorksheet("WBS Details")!;
    expect(wbs.getCell("C1").value).toBe("Work Breakdown Structure");
    expect(wbs.getCell("B3").value).toBe("Paymentz Annual Audit");
    expect(wbs.getCell("H4").value).toBe("Paymentz Retail");
    expect(wbs.getCell("K4").value).toBe("IN/2025/26/398/270");
    expect(wbs.getCell("A5").value).toBe("Brief Details");
    expect(wbs.getCell("C7").value).toBe(2);
    expect(wbs.getCell("H6").value).toBe("Raj Agarwal");
    expect(wbs.getCell("H7").value).toBe("9321534566");
    expect(wbs.getCell("H8").value).toBe("raj.agarwal@paymentz.com");
    expect(wbs.getCell("A10").value).toBe("Service ID");
    expect(wbs.getCell("D10").value).toBe("Resource Level");
    expect(wbs.getCell("H10").value).toBe("Service Model");
    expect(wbs.getCell("N10").value).toBe("Tentative Total Days");
    expect(wbs.getCell("D11").value).toBe("L1=2, L2=1, Senior=1");
    expect(wbs.getCell("L11").value).toBeInstanceOf(Date);
    expect((wbs.getCell("L11").value as Date).toISOString().slice(0, 10)).toBe("2026-03-06");
    expect(wbs.getCell("A13").value).toBe("Total");
    expect(wbs.getCell("N13").value).toBe(31);
    expect(wbs.getCell("A15").value).toBe("Special Note:-");
    expect(wbs.getCell("B15").value).toBe("Kick-Off to be scheduled for 9th March");
    expect(wbs.pageSetup.orientation).toBe("landscape");
    expect(wbs.getCell("D11").border?.top?.style).toBe("thin");
    expect(wbs.views?.[0]?.state).not.toBe("frozen");

    // One WBS document only — header / SOW / SPOC must not reappear below the table.
    let specialNoteCount = 0;
    let titleAfterHeader = false;
    let briefAfterSow = false;
    wbs.eachRow({ includeEmpty: false }, (row, n) => {
      row.eachCell({ includeEmpty: false }, (cell) => {
        if (cell.value === "Special Note:-") specialNoteCount++;
        if (n > 2 && cell.value === "Work Breakdown Structure") titleAfterHeader = true;
        if (n > 8 && cell.value === "Brief Details") briefAfterSow = true;
      });
    });
    expect(specialNoteCount).toBe(1);
    expect(titleAfterHeader).toBe(false);
    expect(briefAfterSow).toBe(false);
    expect(wbs.rowCount).toBe(15);

    const acc = wb.getWorksheet("Accounts Details")!;
    let wbsTitleOnAccounts = false;
    acc.eachRow({ includeEmpty: false }, (row) => {
      row.eachCell({ includeEmpty: false }, (cell) => {
        if (cell.value === "Work Breakdown Structure") wbsTitleOnAccounts = true;
      });
    });
    expect(wbsTitleOnAccounts).toBe(false);
    expect(acc.getCell("A1").value).toBe("Accounts Details");
    expect(acc.getCell("A2").value).toBe("Project / Billing Information");
    expect(acc.getCell("B5").value).toBe("Quarterly Arrears");
    expect(acc.getCell("E5").value).toBe("Net 30");
    expect(acc.getCell("E4").value).toBe("Paymentz Retail");
    expect(acc.getCell("I4").value).toBe("INR");
    expect(acc.getCell("I5").value).toBe("Received");
    expect(acc.getCell("A8").value).toBe("Invoice Scheduling");
    expect(acc.getCell("A9").value).toBe("Service Name");
    expect(acc.getCell("K9").value).toBe("Date of Payment Received");
    expect(acc.getCell("B10").value).toBe("Quarter 1");
    expect(acc.getCell("G10").value).toBe(240000);
    expect(acc.getCell("G10").numFmt).toBe('"₹" #,##0.00');
    expect(acc.getCell("A12").value).toBe("Total Invoice Value");
    expect(acc.getCell("G12").value).toBe(260000);
    expect(acc.getCell("A14").value).toBe("Comments / Notes");
    expect(acc.getCell("A15").value).toContain("accounts@paymentz.com");
    expect(acc.views?.[0]?.state).not.toBe("frozen");

    // One Accounts document only — billing / invoice header must not reappear below.
    let accountsTitleAfterFirst = false;
    let billingAfterHeader = false;
    let invoiceBannerAfterTable = false;
    const commentsRows = new Set<number>();
    acc.eachRow({ includeEmpty: false }, (row, n) => {
      row.eachCell({ includeEmpty: false }, (cell) => {
        if (n > 1 && cell.value === "Accounts Details") accountsTitleAfterFirst = true;
        if (n > 2 && cell.value === "Project / Billing Information") billingAfterHeader = true;
        if (n > 8 && cell.value === "Invoice Scheduling") invoiceBannerAfterTable = true;
        if (cell.value === "Comments / Notes") commentsRows.add(n);
      });
    });
    expect(accountsTitleAfterFirst).toBe(false);
    expect(billingAfterHeader).toBe(false);
    expect(invoiceBannerAfterTable).toBe(false);
    expect(commentsRows.size).toBe(1);
    expect(acc.rowCount).toBe(15);
  }, 60000);

  it("names the download file from the WBS ID", () => {
    expect(wbsWorkbookFileName("IN-2026-27-C002-P004")).toBe("IN-2026-27-C002-P004.xlsx");
    expect(wbsWorkbookFileName("IN/2025/26/398/270")).toBe("IN-2025-26-398-270.xlsx");
  });

  it("serialises to a readable xlsx buffer", async () => {
    const wb = await buildWbsWorkbook(input);
    const buffer = await wb.xlsx.writeBuffer();
    const bytes = new Uint8Array(buffer as ArrayBuffer);
    expect(bytes[0]).toBe(0x50);
    expect(bytes[1]).toBe(0x4b);
    expect(bytes.length).toBeGreaterThan(4000);
  }, 60000);
});
