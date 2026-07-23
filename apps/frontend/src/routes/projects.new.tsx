/**
 * /projects/new — Full WBS Form Page (Dhanshree Role Only)
 * Exact layout from wbs-form 2.html, wired to dh-store.
 */
import { createFileRoute, Navigate, useNavigate, useSearch } from "@tanstack/react-router";
import { useEffect, useRef, useState } from "react";
import { toast } from "sonner";
import { useRoleContext } from "@/lib/role-context";
import { allClients, allProjects, dhStore, useDhStore, buildProjectDisplayId, buildWbsId } from "@/lib/dh-store";

export const Route = createFileRoute("/projects/new")({
  validateSearch: (search: Record<string, unknown>): { draftId?: string } => ({
    draftId: typeof search.draftId === "string" ? search.draftId : undefined,
  }),
  head: () => ({
    meta: [{ title: "New Project — WBS Form" }],
  }),
  component: WbsNewProjectPage,
});

// ─── Constants (from HTML) ───────────────────────────────────────────────────

const DEPT_SERVICES: Record<string, { id: string; name: string; tool: string; unitPrice: number; days: number }[]> = {
  "Penetration Testing": [
    { id: "PT001", name: "External Network Penetration Testing", tool: "Nessus, Metasploit", unitPrice: 60000, days: 5 },
    { id: "PT002", name: "Internal Network Penetration Testing", tool: "Burp Suite, Cobalt Strike", unitPrice: 75000, days: 6 },
    { id: "PT003", name: "Web Application Penetration Testing", tool: "Burp Suite, OWASP ZAP", unitPrice: 50000, days: 5 },
    { id: "PT004", name: "Mobile Application Penetration Testing", tool: "Frida, Burp Suite Mobile", unitPrice: 55000, days: 5 },
    { id: "PT005", name: "API Penetration Testing", tool: "Postman, Burp Suite", unitPrice: 40000, days: 4 },
    { id: "PT006", name: "Thick Client Penetration Testing", tool: "Burp Suite, API Fuzzer", unitPrice: 45000, days: 4 },
  ],
  "Vulnerability Assessment": [
    { id: "VA001", name: "Network Vulnerability Assessment", tool: "Nessus, OpenVAS, Qualys", unitPrice: 35000, days: 3 },
    { id: "VA002", name: "Web Application Vulnerability Assessment", tool: "Acunetix, Qualys, Rapid7", unitPrice: 40000, days: 4 },
    { id: "VA003", name: "Cloud Infrastructure Vulnerability Assessment", tool: "Dome9, CloudSploit", unitPrice: 50000, days: 4 },
  ],
  "Red Team & Adversary Simulation": [
    { id: "RT001", name: "Full Spectrum Red Team Exercise", tool: "Cobalt Strike, Metasploit, Mimikatz", unitPrice: 120000, days: 10 },
    { id: "RT002", name: "Targeted Red Team Engagement", tool: "Custom Tools, Cobalt Strike", unitPrice: 80000, days: 7 },
  ],
  "Cloud Security": [
    { id: "CS001", name: "AWS Security Assessment", tool: "Scout2, CloudMapper, AWS Inspector", unitPrice: 55000, days: 5 },
    { id: "CS002", name: "Azure Security Assessment", tool: "Azucar, Microsoft Defender, Qualys", unitPrice: 55000, days: 5 },
    { id: "CS003", name: "Google Cloud Security Assessment", tool: "GCP Security Command Center", unitPrice: 50000, days: 5 },
  ],
  "Code & Application Security": [
    { id: "CODE001", name: "Source Code Security Review", tool: "SonarQube, Checkmarx, Fortify", unitPrice: 65000, days: 6 },
    { id: "CODE002", name: "Static Application Security Testing (SAST)", tool: "Checkmarx, Veracode, Fortify", unitPrice: 70000, days: 7 },
    { id: "CODE003", name: "Dynamic Application Security Testing (DAST)", tool: "Burp Suite, Acunetix, AppScan", unitPrice: 60000, days: 6 },
  ],
  "Compliance & Audit": [
    { id: "COMP001", name: "ISO 27001 Security Audit", tool: "AuditBoard, Drata, Vanta", unitPrice: 85000, days: 8 },
    { id: "COMP002", name: "GDPR Compliance Assessment", tool: "OneTrust, TrustArc, Compliance.ai", unitPrice: 75000, days: 7 },
    { id: "COMP003", name: "PCI-DSS Compliance Assessment", tool: "Qualys, Rapid7, Nessus", unitPrice: 80000, days: 7 },
    { id: "COMP004", name: "SOC 2 Type II Audit", tool: "AuditBoard, Drata", unitPrice: 95000, days: 10 },
  ],
  "Social Engineering & Awareness": [
    { id: "SE001", name: "Phishing Campaign & Assessment", tool: "KnowBe4, Gophish, Phish Alert", unitPrice: 30000, days: 2 },
    { id: "SE002", name: "Security Awareness Training Program", tool: "LinkedIn Learning, KnowBe4, SANS", unitPrice: 45000, days: 4 },
    { id: "SE003", name: "Vishing & Pretexting Assessment", tool: "Custom, KnowBe4", unitPrice: 35000, days: 3 },
  ],
  "Forensics & Incident Response": [
    { id: "FOR001", name: "Digital Forensics Investigation", tool: "EnCase, FTK, Volatility, X-Ways", unitPrice: 90000, days: 8 },
    { id: "FOR002", name: "Incident Response & Containment", tool: "Splunk, ELK, Rapid7 InsightIDR", unitPrice: 75000, days: 7 },
    { id: "FOR003", name: "Malware Analysis", tool: "IDA Pro, Ghidra, Wireshark, Cuckoo", unitPrice: 70000, days: 6 },
  ],
  "Network & Infrastructure": [
    { id: "NET001", name: "Network Architecture Security Review", tool: "Nmap, Wireshark, NETMON", unitPrice: 55000, days: 5 },
    { id: "NET002", name: "Firewall & IDS/IPS Configuration Audit", tool: "Nessus, OpenVAS, Custom Scripts", unitPrice: 65000, days: 6 },
    { id: "NET003", name: "Network Segmentation Assessment", tool: "Nmap, Shodan, Custom Tools", unitPrice: 60000, days: 5 },
  ],
  "Threat Intelligence & Modeling": [
    { id: "THREAT001", name: "Threat Modeling & Risk Assessment", tool: "Microsoft Threat Modeling Tool, IriusRisk", unitPrice: 50000, days: 4 },
    { id: "THREAT002", name: "Cyber Threat Intelligence Report", tool: "MISP, Mandiant, CrowdStrike", unitPrice: 40000, days: 3 },
    { id: "THREAT003", name: "Attack Surface Analysis", tool: "Shodan, Censys, Rapid7 Sonar", unitPrice: 45000, days: 4 },
  ],
};

const DEPT_GROUPS: Record<string, "Resource" | "Scope"> = {
  "Penetration Testing": "Scope",
  "Vulnerability Assessment": "Scope",
  "Red Team & Adversary Simulation": "Resource",
  "Cloud Security": "Resource",
  "Code & Application Security": "Scope",
  "Compliance & Audit": "Resource",
  "Social Engineering & Awareness": "Scope",
  "Forensics & Incident Response": "Resource",
  "Network & Infrastructure": "Scope",
  "Threat Intelligence & Modeling": "Resource",
};

const BILLING_MODELS: Record<string, string[]> = {
  "Ad-Hoc": ["100% Advance", "70% Advance + 30% on Delivery", "50% Advance + 50% on Delivery", "Custom"],
  "Long Term": ["Monthly Arrears", "Monthly Advance", "Quarterly Arrears", "Quarterly Advance"],
};

const PAYMENT_TERMS_MAP: Record<string, string[]> = {
  "100% Advance": ["100% Before Project Start"],
  "70% Advance + 30% on Delivery": ["70% Advance", "30% on Final Delivery"],
  "50% Advance + 50% on Delivery": ["50% Advance", "50% on Final Delivery"],
  "50% Advance + 25% on Initial Assessment + 25% on Delivery": ["50% Advance", "25% on Initial Assessment", "25% on Final Delivery"],
  "Monthly Arrears": ["End of Each Month"],
  "Monthly Advance": ["Start of Each Month"],
  "Quarterly Arrears": ["End of Each Quarter"],
  "Quarterly Advance": ["Start of Each Quarter"],
  "Custom": ["Custom Terms"],
};

const INVOICE_TEMPLATES: Record<string, { milestone: string; pct: number }[]> = {
  "100% Advance": [{ milestone: "Advance 100%", pct: 100 }],
  "70% Advance + 30% on Delivery": [{ milestone: "Advance 70%", pct: 70 }, { milestone: "Final Delivery 30%", pct: 30 }],
  "50% Advance + 50% on Delivery": [{ milestone: "Advance 50%", pct: 50 }, { milestone: "Final Delivery 50%", pct: 50 }],
  "50% Advance + 25% on Initial Assessment + 25% on Delivery": [
    { milestone: "Advance 50%", pct: 50 }, { milestone: "Initial Assessment 25%", pct: 25 }, { milestone: "Final Delivery 25%", pct: 25 },
  ],
  "Monthly Arrears": [{ milestone: "Monthly Arrears", pct: 100 }],
  "Monthly Advance": [{ milestone: "Monthly Advance", pct: 100 }],
  "Quarterly Arrears": [{ milestone: "Quarterly Arrears", pct: 100 }],
  "Quarterly Advance": [{ milestone: "Quarterly Advance", pct: 100 }],
};

const PERCENTAGE_MILESTONES: Record<string, { milestone: string; pct: number }[]> = {
  "100% Advance": [{ milestone: "100% Advance", pct: 100 }],
  "70% Advance + 30% on Delivery": [
    { milestone: "70% Advance", pct: 70 },
    { milestone: "30% on Delivery", pct: 30 }
  ],
  "50% Advance + 50% on Delivery": [
    { milestone: "50% Advance", pct: 50 },
    { milestone: "50% on Delivery", pct: 50 }
  ],
  "50% Advance + 25% on Initial Assessment + 25% on Delivery": [
    { milestone: "50% Advance", pct: 50 },
    { milestone: "25% on Initial Assessment", pct: 25 },
    { milestone: "25% on Delivery", pct: 25 }
  ],
};

const CURRENCY_SYMBOLS: Record<string, string> = {
  INR: "₹", USD: "$", EUR: "€", GBP: "£", AED: "د.إ", SGD: "S$", AUD: "A$", JPY: "¥", CAD: "C$", CHF: "Fr",
};

// ─── Types ──────────────────────────────────────────────────────────────────

interface ServiceRow {
  rowId: string;
  taskId: string;
  dept: string;
  name: string;
  qty: number;
  description: string;
  resourceLevel: string;  // Resource Level — dropdown (L1/L2/Senior)
  frequency: string;
  location: string;       // Delivery Model — dropdown (Onsite/Offsite/Hybrid)
  locationText: string;   // Project Side — free text
  serviceModel: string;
  deliveryModel: string;  // preserved for WBS record
  billingModel: string;   // preserved for WBS record
  deliveryFormat: string;
  tools: string;
  startDate: string;
  endDate: string;
  durationDays: number;
  durationHrs: number;
  totalDays: number;
  totalHrs: number;
  unitPrice: number;
  total: number;
}

interface InvoiceRow {
  rowId: string;
  serviceId: string;
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
  invoiceDate?: string;
  description?: string;
}

// ─── Main Component ──────────────────────────────────────────────────────────

function WbsNewProjectPage() {
  const { isDhanshree } = useRoleContext();
  const navigate = useNavigate();
  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);
  const clients = allClients();

  if (!isDhanshree) return <Navigate to="/" />;

  // ── Working-day helpers ──────────────────────────────────────────────────
  // Add N working days (Mon–Fri) to a YYYY-MM-DD string, returns YYYY-MM-DD
  function addWorkingDays(startIso: string, days: number): string {
    const d = new Date(startIso);
    let remaining = days;
    while (remaining > 0) {
      d.setDate(d.getDate() + 1);
      const dow = d.getDay(); // 0=Sun, 6=Sat
      if (dow !== 0 && dow !== 6) remaining--;
    }
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, "0");
    const dd = String(d.getDate()).padStart(2, "0");
    return `${y}-${m}-${dd}`;
  }

  // Add N calendar months to a YYYY-MM-DD string, returns YYYY-MM-DD
  function addCalendarMonths(startIso: string, months: number): string {
    const d = new Date(startIso);
    d.setMonth(d.getMonth() + months);
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, "0");
    const dd = String(d.getDate()).padStart(2, "0");
    return `${y}-${m}-${dd}`;
  }

  // Compute end date from a row based on its frequency and duration
  function computeEndDate(row: { startDate: string; frequency: string; totalDays: number }): string {
    if (!row.startDate) return "";
    if (row.frequency === "Half yearly") return addCalendarMonths(row.startDate, 6);
    if (row.frequency === "Yearly") return addCalendarMonths(row.startDate, 12);
    // Once (or any other) — use working days from totalDays
    if (row.totalDays > 0) return addWorkingDays(row.startDate, row.totalDays);
    return "";
  }

  const todayIso = new Date().toISOString().slice(0, 10);

  // ── Header fields ──
  const [projectName, setProjectName] = useState("");
  const projectId = buildProjectDisplayId();
  const [contractType, setContractType] = useState("");
  const [engagementManager, setEngagementManager] = useState("");
  const [salesPerson, setSalesPerson] = useState("");
  const [projectType, setProjectType] = useState("");
  const [projectIssuedDate] = useState(() => new Date().toISOString().slice(0, 10));

  // ── Renewal mode ──
  const [isRenewal, setIsRenewal] = useState(false);
  const [wbsSearch, setWbsSearch] = useState("");
  const [wbsDropOpen, setWbsDropOpen] = useState(false);
  const [renewalProject, setRenewalProject] = useState<ReturnType<typeof allProjects>[0] | null>(null);

  const allProjectsList = allProjects();
  const filteredByWbs = allProjectsList.filter((p) =>
    p.wbsId && (
      wbsSearch.trim() === "" ||
      p.wbsId.toLowerCase().includes(wbsSearch.toLowerCase()) ||
      p.name.toLowerCase().includes(wbsSearch.toLowerCase())
    )
  );

  // ── Client selection (searchable combobox) ──
  const [clientSearch, setClientSearch] = useState("");
  const [clientDropOpen, setClientDropOpen] = useState(false);
  const [selectedClientId, setSelectedClientId] = useState("");
  const selectedClient = clients.find((c) => c.id === selectedClientId) ?? null;

  // ── Sub-venture (searchable, depends on selected client) ──
  const [svSearch, setSvSearch] = useState("");
  const [svDropOpen, setSvDropOpen] = useState(false);
  const [selectedSubVenture, setSelectedSubVenture] = useState("");

  const clientSubVentures = selectedClient?.subVentures ?? [];
  const filteredSubVentures = clientSubVentures.filter((sv) =>
    svSearch.trim() === "" ||
    sv.toLowerCase().includes(svSearch.toLowerCase())
  );

  // Filtered client list for the combobox
  const filteredClients = clients.filter((c) =>
    clientSearch.trim() === "" ||
    c.name.toLowerCase().includes(clientSearch.toLowerCase()) ||
    (c.companyName ?? "").toLowerCase().includes(clientSearch.toLowerCase())
  );

  // WBS ID — recomputed from selected client + current FY + next project seq
  const wbsId = selectedClientId ? buildWbsId(selectedClientId) : "—";

  // ── Service picker ──
  const [pickerOpen, setPickerOpen] = useState(false);
  const [pickerDept, setPickerDept] = useState(Object.keys(DEPT_SERVICES)[0]);
  const [pickerSearch, setPickerSearch] = useState("");
  const [tempSelected, setTempSelected] = useState<Record<string, Record<string, boolean>>>({});
  const [selectedServices, setSelectedServices] = useState<Record<string, Record<string, boolean>>>({});
  const [serviceRows, setServiceRows] = useState<ServiceRow[]>([]);

  // ── Section B ──
  const [billingModel, setBillingModel] = useState("");
  const [paymentTerms, setPaymentTerms] = useState("");
  const [customPayments, setCustomPayments] = useState<{ label: string; pct: number }[]>([
    { label: "First Payment", pct: 100 },
  ]);
  const [currency, setCurrency] = useState("INR");
  const [poStatus, setPoStatus] = useState("");
  const [poNumber, setPoNumber] = useState("");
  const [poDate, setPoDate] = useState("");
  const [targetDate, setTargetDate] = useState("");
  const [contactName, setContactName] = useState("");
  const [contactNumber, setContactNumber] = useState("");
  const [contactEmail, setContactEmail] = useState("");
  const [invoiceRows, setInvoiceRows] = useState<InvoiceRow[]>([]);
  const [hoveredInvoiceRowId, setHoveredInvoiceRowId] = useState<string | null>(null);

  // ── Tax ──
  const [taxPercent, setTaxPercent] = useState(18);

  // ── Comments ──
  const [sectionAComments, setSectionAComments] = useState("");
  const [sectionBComments, setSectionBComments] = useState("");

  // ── PO File ──
  const [poFile, setPoFile] = useState<File | null>(null);

  // ── Scroll-to-top ──
  const [showScrollTop, setShowScrollTop] = useState(false);
  useEffect(() => {
    const onScroll = () => setShowScrollTop(window.scrollY > 300);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  // ── Draft restoration ──
  const { draftId } = useSearch({ from: "/projects/new" });
  const drafts = useDhStore((s) => s.wbsDrafts);
  useEffect(() => {
    if (!draftId) return;
    const draft = drafts.find((d) => d.id === draftId);
    if (!draft) return;
    const snap = draft.formSnapshot as any;
    if (snap.projectName) setProjectName(snap.projectName);
    if (snap.selectedClientId) setSelectedClientId(snap.selectedClientId);
    if (snap.selectedSubVenture) setSelectedSubVenture(snap.selectedSubVenture);
    if (snap.contractType) setContractType(snap.contractType);
    if (snap.engagementManager) setEngagementManager(snap.engagementManager);
    if (snap.salesPerson) setSalesPerson(snap.salesPerson);
    if (snap.projectType) setProjectType(snap.projectType);
    if (snap.billingModel) setBillingModel(snap.billingModel);
    if (snap.paymentTerms) setPaymentTerms(snap.paymentTerms);
    if (snap.currency) setCurrency(snap.currency);
    if (snap.taxPercent != null) setTaxPercent(snap.taxPercent);
    if (snap.poStatus) setPoStatus(snap.poStatus);
    if (snap.poNumber) setPoNumber(snap.poNumber);
    if (snap.poDate) setPoDate(snap.poDate);
    if (snap.targetDate) setTargetDate(snap.targetDate);
    if (snap.contactName) setContactName(snap.contactName);
    if (snap.contactNumber) setContactNumber(snap.contactNumber);
    if (snap.contactEmail) setContactEmail(snap.contactEmail);
    if (snap.sectionAComments) setSectionAComments(snap.sectionAComments);
    if (snap.sectionBComments) setSectionBComments(snap.sectionBComments);
    if (snap.serviceRows?.length) {
      const sanitizedRows = snap.serviceRows.map((r: any) => {
        let updated = { ...r };
        if (DEPT_GROUPS[r.dept] === "Resource") {
          updated.serviceModel = "NA";
        }
        if (snap.projectType === "Ad-Hoc") {
          updated.frequency = "Once";
        }
        return updated;
      });
      setServiceRows(sanitizedRows);
    }
    if (snap.invoiceRows?.length) {
      setInvoiceRows(snap.invoiceRows.map((inv: any) => ({
        rowId: inv.rowId || inv.id || "",
        serviceId: inv.serviceId || "",
        serviceName: inv.serviceName || "",
        milestone: inv.milestone || "",
        targetDate: inv.targetDate || inv.invoiceDate || "",
        unitPrice: inv.unitPrice || inv.amount || 0,
        qty: inv.qty || 1,
        currency: inv.currency || "INR",
        amount: inv.amount || 0,
        invoiceStatus: inv.invoiceStatus || "Not Raised",
        invoiceNumber: inv.invoiceNumber || inv.remarks || "",
        paymentStatus: inv.paymentStatus || "Not Received",
        paymentDate: inv.paymentDate || "",
      })));
    }
    // also restore client search display
    const restoredClient = clients.find((c) => c.id === snap.selectedClientId);
    if (restoredClient) setClientSearch(restoredClient.name);
    if (snap.selectedSubVenture) setSvSearch(snap.selectedSubVenture);
    toast.success("Draft loaded", { description: `"${draft.projectName}" restored.` });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [draftId]);

  // ── Computed totals ──
  const subtotal = serviceRows.reduce((s, r) => s + r.total, 0);
  const tax = subtotal * (taxPercent / 100);
  const invoiceTarget = subtotal + tax;
  const totalHours = serviceRows.reduce((s, r) => s + r.totalHrs, 0);
  const totalDays = serviceRows.reduce((s, r) => s + r.totalDays, 0);
  const billSubtotal = invoiceRows.reduce((s, r) => s + r.amount, 0);
  const billTax = billSubtotal * 0.18;
  const billGrandTotal = billSubtotal + billTax;
  const sym = CURRENCY_SYMBOLS[currency] || currency;

  // ─── Service picker helpers ──────────────────────────────────────────────

  function openPicker() {
    setTempSelected(JSON.parse(JSON.stringify(selectedServices)));
    setPickerOpen(true);
    const depts = Object.keys(DEPT_SERVICES).filter((dept) => {
      const group = DEPT_GROUPS[dept];
      if (contractType === "Resource Based") return group === "Resource";
      if (contractType === "Scope Based") return group === "Scope";
      return true;
    });
    setPickerDept(depts[0] || "");
    setPickerSearch("");
  }

  function confirmPicker() {
    const newSelected = JSON.parse(JSON.stringify(tempSelected));
    setSelectedServices(newSelected);
    setPickerOpen(false);
    // Rebuild service rows
    const rows: ServiceRow[] = [];
    let rowNum = 1;
    Object.entries(newSelected).forEach(([dept, svcs]) => {
      Object.keys(svcs as Record<string, boolean>).forEach((svcId) => {
        const svc = DEPT_SERVICES[dept]?.find((s) => s.id === svcId);
        if (!svc) return;
        const existing = serviceRows.find((r) => r.rowId === svcId);
        if (existing) {
          const updatedExisting = { ...existing };
          if (DEPT_GROUPS[dept] === "Resource" && updatedExisting.serviceModel !== "NA") {
            updatedExisting.serviceModel = "NA";
          }
          if (projectType === "Ad-Hoc" && updatedExisting.frequency !== "Once") {
            updatedExisting.frequency = "Once";
            updatedExisting.endDate = computeEndDate(updatedExisting);
          }
          rows.push(updatedExisting);
        }
        else {
          const isResource = DEPT_GROUPS[dept] === "Resource";
          const newRow = {
            rowId: svcId, taskId: `WBS-${String(rowNum + 1).padStart(2, "0")}`,
            dept, name: svc.name, qty: 1, description: "", resourceLevel: "", frequency: projectType === "Ad-Hoc" ? "Once" : "",
            location: "", locationText: "", serviceModel: isResource ? "NA" : "",
            deliveryModel: "Remote", billingModel: "",
            deliveryFormat: "", tools: svc.tool,
            startDate: todayIso, endDate: "",
            durationDays: svc.days, durationHrs: svc.days * 8,
            totalDays: svc.days, totalHrs: svc.days * 8, unitPrice: svc.unitPrice, total: svc.unitPrice,
          };
          newRow.endDate = computeEndDate(newRow);
          rows.push(newRow);
        }
        rowNum++;
      });
    });
    // Remove deselected rows
    setServiceRows(rows);
  }

  function removeServiceRow(rowId: string) {
    setServiceRows((prev) => prev.filter((r) => r.rowId !== rowId));
    setSelectedServices((prev) => {
      const next = { ...prev };
      Object.keys(next).forEach((dept) => {
        if (next[dept][rowId]) {
          const d = { ...next[dept] };
          delete d[rowId];
          if (Object.keys(d).length === 0) delete next[dept];
          else next[dept] = d;
        }
      });
      return next;
    });
  }

  function updateRow<K extends keyof ServiceRow>(rowId: string, field: K, value: ServiceRow[K]) {
    setServiceRows((prev) =>
      prev.map((r) => {
        if (r.rowId !== rowId) return r;
        const updated = { ...r, [field]: value };
        // Recalculate total when qty or unitPrice changes
        if (field === "qty" || field === "unitPrice") {
          updated.total = Number(updated.qty) * Number(updated.unitPrice);
        }
        // Recalculate totalDays and totalHrs when qty or durationDays/Hrs changes
        if (field === "qty" || field === "durationDays") {
          updated.totalDays = Number(updated.qty) * Number(updated.durationDays);
        }
        if (field === "qty" || field === "durationHrs") {
          updated.totalHrs = Number(updated.qty) * Number(updated.durationHrs);
        }
        // Auto-compute WBS End Date whenever startDate, duration, qty, or frequency changes
        if (field === "startDate" || field === "qty" || field === "durationDays" || field === "frequency") {
          // If durationDays just changed, recalc totalDays first so computeEndDate uses the new value
          const totalDaysForCalc =
            field === "durationDays"
              ? Number(updated.qty) * Number(value)
              : updated.totalDays;
          const rowForCalc = { ...updated, totalDays: totalDaysForCalc };
          const newEnd = computeEndDate(rowForCalc);
          if (newEnd) updated.endDate = newEnd;
        }
        return updated;
      })
    );
  }

  // Validate all service rows — returns first error message or null
  function validateServiceRows(): string | null {
    for (let i = 0; i < serviceRows.length; i++) {
      const r = serviceRows[i];
      const n = i + 1;
      if (!r.taskId.trim()) return `Row ${n}: Service ID is required`;
      if (!r.name.trim()) return `Row ${n}: Service Name is required`;
      if (!r.frequency) return `Row ${n}: Frequency is required`;
      if (!r.location) return `Row ${n}: Delivery Model is required`;
      if (r.location === "Onsite" && !r.locationText.trim())
        return `Row ${n}: Project Side is required for Onsite`;
      if (!r.serviceModel) return `Row ${n}: Service Model is required`;
      if (!r.deliveryFormat.trim()) return `Row ${n}: Final Delivery Format is required`;
      if (!r.tools.trim()) return `Row ${n}: Tools is required`;
      if (!r.startDate) return `Row ${n}: WBS Start Date is required`;
      if (!r.endDate) return `Row ${n}: WBS End Date is required`;
      if (!r.durationDays) return `Row ${n}: Duration (Days) is required`;
      if (!r.durationHrs) return `Row ${n}: Duration (Hrs) is required`;
      if (!r.totalDays) return `Row ${n}: Total Days is required`;
      if (!r.totalHrs) return `Row ${n}: Total Hrs is required`;
      if (!r.unitPrice) return `Row ${n}: Unit Price is required`;
    }
    return null;
  }

  // ─── Billing model change ────────────────────────────────────────────────

  function onBillingModelChange(model: string) {
    setBillingModel(model);
    // Payment Terms is only editable when Custom — always clear it on any change
    setPaymentTerms("");
    // Reset custom payments back to default when switching billing model
    setCustomPayments([{ label: "First Payment", pct: 100 }]);
  }

  // Helper to update specific fields on an invoice row
  function updateInvoiceRowField<K extends keyof InvoiceRow>(rowId: string, field: K, value: InvoiceRow[K]) {
    setInvoiceRows((prev) =>
      prev.map((r) => {
        if (r.rowId !== rowId) return r;
        return { ...r, [field]: value };
      })
    );
  }

  // Hook to dynamically regenerate Invoice Rows based on WBS and Billing Model configuration
  const servicesDependency = JSON.stringify(
    serviceRows.map(r => ({
      id: r.rowId,
      name: r.name,
      qty: r.qty,
      unitPrice: r.unitPrice,
      frequency: r.frequency,
    }))
  );

  useEffect(() => {
    if (!billingModel) {
      setInvoiceRows([]);
      return;
    }

    const currentYear = new Date().getFullYear();
    let nextSeq = 1;
    // Look up max invoice number sequence from CURRENT invoiceRows to preserve numbering
    invoiceRows.forEach((r) => {
      const prefix = `INV-${currentYear}-`;
      if (r.invoiceNumber && r.invoiceNumber.startsWith(prefix)) {
        const seqStr = r.invoiceNumber.replace(prefix, "");
        const seq = parseInt(seqStr, 10);
        if (!isNaN(seq) && seq >= nextSeq) {
          nextSeq = seq + 1;
        }
      }
    });

    const nextRows: InvoiceRow[] = [];

    // Helper to build a row (preserving if match exists)
    const getOrCreateRow = (serviceId: string, serviceName: string, milestone: string, unitPrice: number, qty: number, currency: string, calculatedAmount: number): InvoiceRow => {
      const lookupKey = `${serviceId}::${milestone}`;
      const existing = invoiceRows.find((r) => r.rowId === lookupKey);

      if (existing) {
        // Preserve existing user-entered fields, but update calculated fields (currency, amount, serviceName)
        return {
          ...existing,
          serviceName,
          unitPrice,
          qty,
          currency,
          amount: calculatedAmount,
        };
      } else {
        // Generate new invoice number
        const invoiceNumber = `INV-${currentYear}-${String(nextSeq).padStart(4, "0")}`;
        nextSeq++;

        return {
          rowId: lookupKey,
          serviceId,
          serviceName,
          milestone,
          targetDate: "",
          unitPrice,
          qty,
          currency,
          amount: calculatedAmount,
          invoiceStatus: "Not Raised",
          invoiceNumber,
          paymentStatus: "Not Received",
          paymentDate: "",
        };
      }
    };

    const getMonthlyPeriods = (freq: string): number => {
      if (freq === "Once") return 1;
      if (freq === "Half yearly") return 6;
      if (freq === "Yearly") return 12;
      return 1;
    };

    const getQuarterlyPeriods = (freq: string): number => {
      if (freq === "Once") return 1;
      if (freq === "Half yearly") return 2;
      if (freq === "Yearly") return 4;
      return 1;
    };

    // 2. Generate rows based on Billing Model
    if (PERCENTAGE_MILESTONES[billingModel]) {
      const milestones = PERCENTAGE_MILESTONES[billingModel];
      serviceRows.forEach((s) => {
        milestones.forEach((m) => {
          const amount = Math.round((s.unitPrice * s.qty * m.pct) / 100);
          nextRows.push(getOrCreateRow(s.rowId, s.name, m.milestone, s.unitPrice, s.qty, currency, amount));
        });
      });
    } else if (billingModel === "Custom") {
      serviceRows.forEach((s) => {
        const ordinals = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth"];
        customPayments.forEach((cp, idx) => {
          const baseLabel = cp.label.trim() || `${ordinals[idx] ?? `Payment ${idx + 1}`} Payment`;
          const milestone = `${baseLabel} (${Number(cp.pct) || 0}%)`;
          const amount = Math.round((s.unitPrice * s.qty * (Number(cp.pct) || 0)) / 100);
          nextRows.push(getOrCreateRow(s.rowId, s.name, milestone, s.unitPrice, s.qty, currency, amount));
        });
      });
    } else if (billingModel === "Monthly Arrears" || billingModel === "Monthly Advance") {
      serviceRows.forEach((s) => {
        const periods = getMonthlyPeriods(s.frequency);
        for (let m = 1; m <= periods; m++) {
          const amount = Math.round((s.unitPrice * s.qty) / periods);
          nextRows.push(getOrCreateRow(s.rowId, s.name, `Month ${m}`, s.unitPrice, s.qty, currency, amount));
        }
      });
    } else if (billingModel === "Quarterly Arrears" || billingModel === "Quarterly Advance") {
      serviceRows.forEach((s) => {
        const periods = getQuarterlyPeriods(s.frequency);
        for (let q = 1; q <= periods; q++) {
          const amount = Math.round((s.unitPrice * s.qty) / periods);
          nextRows.push(getOrCreateRow(s.rowId, s.name, `Quarter ${q}`, s.unitPrice, s.qty, currency, amount));
        }
      });
    }

    setInvoiceRows(nextRows);
  }, [billingModel, currency, servicesDependency, JSON.stringify(customPayments)]);

  // Filter departments based on Contract Type
  const allowedDepts = Object.keys(DEPT_SERVICES).filter((dept) => {
    const group = DEPT_GROUPS[dept];
    if (contractType === "Resource Based") return group === "Resource";
    if (contractType === "Scope Based") return group === "Scope";
    return true;
  });

  const deptsByGroup = allowedDepts.reduce((acc, dept) => {
    const group = DEPT_GROUPS[dept] || "Scope";
    if (!acc[group]) acc[group] = [];
    acc[group].push(dept);
    return acc;
  }, {} as Record<string, string[]>);

  // ─── Picker count helper ─────────────────────────────────────────────────

  const pickerTotalSelected = Object.values(tempSelected).reduce(
    (sum, dept) => sum + Object.keys(dept).length, 0
  );

  const filteredPickerServices = (DEPT_SERVICES[pickerDept] || []).filter((s) =>
    s.name.toLowerCase().includes(pickerSearch.toLowerCase())
  );

  // ─── Form actions ────────────────────────────────────────────────────────

  function buildWbsDetails() {
    return {
      contractType, projectType, salesPerson, engagementManager,
      currency, taxPercent,
      services: serviceRows.map((r) => ({
        id: r.rowId, department: r.dept, serviceName: r.name,
        qty: r.qty, description: r.description, resourceLevel: r.resourceLevel, frequency: r.frequency,
        location: r.location, locationText: r.locationText, serviceModel: r.serviceModel,
        deliveryModel: r.deliveryModel,
        // propagate the Section B billing model to every service row
        billingModel: billingModel || r.billingModel,
        finalDeliveryFormat: r.deliveryFormat,
        tools: r.tools, startDate: r.startDate, endDate: r.endDate,
        duration: r.durationDays, unitPrice: r.unitPrice, total: r.total,
        totalDays: r.totalDays, totalHrs: r.totalHrs,
      })),
      accounts: {
        poStatus, poNumber, poDate, billingModel, paymentTerms, targetDate,
        contactName, contactNumber, contactEmail,
        poFileName: poFile ? poFile.name : "",
        invoices: invoiceRows.map((inv) => {
          const svcRow = serviceRows.find((s) => s.rowId === inv.serviceId);
          return {
            id: inv.rowId,
            serviceId: inv.serviceId,
            serviceName: inv.serviceName,
            milestone: inv.milestone,
            targetDate: inv.targetDate,
            invoiceDate: inv.targetDate, // compatibility
            unitPrice: inv.unitPrice,
            qty: inv.qty,
            currency: inv.currency,
            amount: inv.amount,
            invoiceStatus: inv.invoiceStatus,
            invoiceNumber: inv.invoiceNumber,
            paymentStatus: inv.paymentStatus,
            paymentDate: inv.paymentDate,
            remarks: inv.invoiceNumber, // compatibility
            resourceLevel: svcRow?.resourceLevel || "",
          };
        }),
      },
    };
  }

  function handleSaveDraft() {
    if (!projectName.trim()) { toast.error("Project Name is required"); return; }
    if (!selectedClientId) { toast.error("Please select a client"); return; }
    const clientName = clients.find((c) => c.id === selectedClientId)?.name ?? selectedClientId;
    dhStore.saveDraft({
      projectName,
      clientId: selectedClientId,
      clientName,
      salesPerson,
      savedBy: "Dhanshree",
      savedAt: new Date().toISOString(),
      formSnapshot: {
        projectName, selectedClientId, selectedSubVenture,
        contractType, engagementManager, salesPerson, projectType, projectIssuedDate,
        billingModel, paymentTerms, currency, taxPercent,
        poStatus, poNumber, poDate, targetDate,
        contactName, contactNumber, contactEmail,
        sectionAComments, sectionBComments,
        serviceRows, invoiceRows,
      },
    });
    toast.success("Draft saved", { description: `"${projectName}" saved to your drafts.` });
  }

  function clearForm() {
    setProjectName("");
    setWbsSearch("");
    setRenewalProject(null);
    setSelectedClientId("");
    setClientSearch("");
    setEngagementManager("");
    setSalesPerson("");
    setProjectType("");
    setContractType("");
    setBillingModel("");
    setPaymentTerms("");
    setCustomPayments([{ label: "First Payment", pct: 100 }]);
    setCurrency("INR");
    setTaxPercent(18);
    setPoStatus("");
    setPoNumber("");
    setPoDate("");
    setTargetDate("");
    setContactName("");
    setContactNumber("");
    setContactEmail("");
    setSectionAComments("");
    setSectionBComments("");
    setServiceRows([]);
    setSelectedServices({});
    setTempSelected({});
    setInvoiceRows([]);
    setSelectedSubVenture("");
    setSvSearch("");
  }

  function handleAssignWbs() {
    if (!projectName.trim()) { toast.error("Project Name is required"); return; }
    if (!selectedClientId) { toast.error("Please select a client"); return; }
    if (serviceRows.length === 0) { toast.error("Please add at least one service"); return; }
    if (billingModel === "Custom") {
      const total = customPayments.reduce((s, p) => s + (Number(p.pct) || 0), 0);
      if (total !== 100) {
        toast.error(`Custom payment terms must total 100% (currently ${total}%)`);
        return;
      }
      // Serialize custom payments into paymentTerms string
      const serialized = customPayments.map((p, i) => `${p.pct}% ${p.label || `Payment ${i + 1}`}`).join(" + ");
      setPaymentTerms(serialized);
    }
    const err = validateServiceRows();
    if (err) { toast.error(err); return; }

    // Derive project start/end from the service rows (earliest start → latest end)
    const allStarts = serviceRows.map(r => r.startDate).filter(Boolean).sort();
    const allEnds = serviceRows.map(r => r.endDate).filter(Boolean).sort();
    const projStart = allStarts[0] ?? new Date().toISOString().slice(0, 10);
    const projEnd = allEnds[allEnds.length - 1] ?? new Date(Date.now() + 86400000 * 90).toISOString().slice(0, 10);

    const proj = dhStore.addProject({
      name: projectName, clientId: selectedClientId,
      description: sectionAComments,
      startDate: projStart,
      endDate: projEnd,
      budget: subtotal,
      wbsStatus: "assigned", wbsSubStatus: "WBS Assigned",
      engagementManager, salesPerson, contractType, projectType,
      projectIssuedDate, currency, taxPercent, totalHours, totalDays,
      invoiceValue: invoiceTarget, sectionAComments, sectionBComments,
      wbsDetails: buildWbsDetails(),
      subVenture: selectedSubVenture,
    });
    toast.success("WBS created successfully");
    navigate({ to: "/projects/$projectId", params: { projectId: proj.id } });
  }

  function handleExport() {
    toast.info("Export WBS", { description: "Use browser Print (Ctrl+P) to save as PDF." });
    window.print();
  }

  // ─── Render ──────────────────────────────────────────────────────────────

  return (
    <div style={{ fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif", background: "#f9fafb", color: "#1f2937", minHeight: "100vh" }}>

      {/* ── Navbar ── */}
      <nav style={{ background: "#1a5490", color: "#fff", padding: "12px 20px", display: "flex", justifyContent: "space-between", alignItems: "center", boxShadow: "0 2px 4px rgba(0,0,0,0.1)", position: "sticky", top: 0, zIndex: 100 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 20, flex: 1 }}>
          <h1 style={{ fontSize: 16, fontWeight: 700 }}>WBS Management System</h1>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 12, fontSize: 13 }}>
          <span>Dhanshree</span>
          <span style={{ background: "rgba(255,255,255,0.2)", padding: "4px 8px", borderRadius: 4, fontSize: 11, fontWeight: 600 }}>Sales</span>
          <button onClick={() => navigate({ to: "/projects" })} style={{ background: "rgba(255,255,255,0.15)", color: "#fff", border: "1px solid rgba(255,255,255,0.3)", padding: "6px 12px", borderRadius: 4, cursor: "pointer", fontSize: 12 }}>
            ← Back to Projects
          </button>
        </div>
      </nav>

      {/* ── Content ── */}
      <div style={{ maxWidth: 1400, margin: "0 auto", padding: 20 }}>

        {/* Breadcrumb */}
        <div style={{ fontSize: 12, color: "#6b7280", marginBottom: 12 }}>
          <span onClick={() => navigate({ to: "/projects" })} style={{ color: "#1a84d4", cursor: "pointer", textDecoration: "none" }}>Projects</span>
          {" › "}Create WBS
        </div>

        {/* ── Renewal Checkbox + WBS ID Search ── */}
        <div style={{ background: "#fff", border: "1px solid #d1d5db", borderRadius: 8, padding: "12px 16px", marginBottom: 16, display: "flex", alignItems: "flex-start", gap: 16, flexWrap: "wrap", boxShadow: "0 1px 3px rgba(0,0,0,0.04)" }}>
          {/* Checkbox */}
          <label style={{ display: "flex", alignItems: "center", gap: 8, cursor: "pointer", userSelect: "none", fontSize: 13, fontWeight: 600, color: "#1f2937", flexShrink: 0, marginTop: 6 }}>
            <input
              type="checkbox"
              checked={isRenewal}
              onChange={(e) => {
                setIsRenewal(e.target.checked);
                clearForm();
              }}
              style={{ width: 16, height: 16, accentColor: "#1a84d4", cursor: "pointer" }}
            />
            Renewal Project
          </label>

          {/* WBS ID Search — shown only when renewal is checked */}
          {isRenewal && (
            <div style={{ flex: 1, minWidth: 280 }}>
              <div style={{ fontSize: 11, fontWeight: 600, color: "#6b7280", marginBottom: 4, textTransform: "uppercase", letterSpacing: "0.05em" }}>
                Search by WBS ID or Project Name
              </div>
              <div style={{ position: "relative" }}>
                <span style={{ position: "absolute", left: 10, top: "50%", transform: "translateY(-50%)", color: "#9ca3af", fontSize: 14 }}>🔍</span>
                <input
                  type="text"
                  value={wbsSearch}
                  placeholder="e.g. IN-2025-26-C001-P001 or project name…"
                  onFocus={() => setWbsDropOpen(true)}
                  onChange={(e) => { setWbsSearch(e.target.value); setWbsDropOpen(true); setRenewalProject(null); }}
                  onBlur={() => setTimeout(() => setWbsDropOpen(false), 150)}
                  style={{ ...inputStyle(false), paddingLeft: 32, paddingRight: renewalProject ? 28 : 12 }}
                />
                {renewalProject && (
                  <span
                    onMouseDown={() => { setRenewalProject(null); setWbsSearch(""); }}
                    style={{ position: "absolute", right: 8, top: "50%", transform: "translateY(-50%)", color: "#9ca3af", cursor: "pointer", fontSize: 16, lineHeight: 1 }}
                  >×</span>
                )}
                {wbsDropOpen && isRenewal && (
                  <div style={{ position: "absolute", top: "calc(100% + 4px)", left: 0, right: 0, background: "#fff", border: "1px solid #d1d5db", borderRadius: 6, boxShadow: "0 4px 16px rgba(0,0,0,0.12)", zIndex: 300, maxHeight: 260, overflowY: "auto" }}>
                    {filteredByWbs.length === 0 ? (
                      <div style={{ padding: "12px 14px", fontSize: 12, color: "#6b7280" }}>No projects with WBS ID match</div>
                    ) : filteredByWbs.map((p) => {
                      const pAny = p as any;
                      const c = clients.find((c) => c.id === pAny.clientId);
                      return (
                        <div
                          key={pAny.id}
                          onMouseDown={() => {
                            setRenewalProject(p);
                            setWbsSearch(pAny.wbsId ?? pAny.id);
                            
                            // Auto-fill all project metadata
                            setProjectName(pAny.name);
                            setSelectedClientId(pAny.clientId);
                            setClientSearch(c?.name ?? "");
                            setEngagementManager(pAny.engagementManager ?? c?.engagementManager ?? "");
                            setSalesPerson(pAny.salesPerson ?? "");
                            setProjectType(pAny.projectType ?? "");
                            setContractType(pAny.contractType ?? "");
                            
                            // Section B values
                            const bModel = pAny.wbsDetails?.accounts?.billingModel ?? pAny.billingModel ?? "";
                            setBillingModel(bModel);
                            setPaymentTerms(pAny.wbsDetails?.accounts?.paymentTerms ?? pAny.paymentTerms ?? "");
                            setCurrency(pAny.currency ?? "INR");
                            setTaxPercent(pAny.taxPercent ?? 18);
                            setPoStatus(pAny.wbsDetails?.accounts?.poStatus ?? pAny.poStatus ?? "");
                            setPoNumber(pAny.wbsDetails?.accounts?.poNumber ?? pAny.poNumber ?? "");
                            setPoDate(pAny.wbsDetails?.accounts?.poDate ?? pAny.poDate ?? "");
                            setTargetDate(pAny.wbsDetails?.accounts?.targetDate ?? pAny.targetDate ?? "");
                            setContactName(pAny.wbsDetails?.accounts?.contactName ?? pAny.contactName ?? "");
                            setContactNumber(pAny.wbsDetails?.accounts?.contactNumber ?? pAny.contactNumber ?? "");
                            setContactEmail(pAny.wbsDetails?.accounts?.contactEmail ?? pAny.contactEmail ?? "");
                            setSectionAComments(pAny.sectionAComments ?? pAny.description ?? "");
                            setSectionBComments(pAny.sectionBComments ?? "");

                            if (pAny.subVenture) {
                              setSelectedSubVenture(pAny.subVenture);
                              setSvSearch(pAny.subVenture);
                            } else {
                              setSelectedSubVenture("");
                              setSvSearch("");
                            }

                            // Load services
                            let servicesList: any[] = [];
                            if (pAny.wbsDetails?.services) {
                              servicesList = pAny.wbsDetails.services;
                            } else if (pAny.tasks && pAny.tasks.length > 0) {
                              servicesList = pAny.tasks.map((task: any, idx: number) => {
                                let deptName = "Cyber Security";
                                for (const [dept, svcs] of Object.entries(DEPT_SERVICES)) {
                                  if (svcs.some((s: any) => s.id === task.serviceId || s.name === task.title)) {
                                    deptName = dept;
                                    break;
                                  }
                                }
                                return {
                                  id: task.serviceId || `svc-${idx}`,
                                  department: deptName,
                                  serviceName: task.title,
                                  qty: 1,
                                  description: "",
                                  resourceLevel: "",
                                  frequency: "Once",
                                  location: "Offshore",
                                  locationText: "",
                                  serviceModel: "NA",
                                  deliveryModel: "Remote",
                                  finalDeliveryFormat: "Report",
                                  billingModel: "Fixed Bid",
                                  tools: "",
                                  startDate: task.wbsStartDate || pAny.startDate,
                                  endDate: task.wbsEndDate || task.dueDate || pAny.endDate,
                                  duration: task.estimatedHours ? Math.ceil(task.estimatedHours / 8) : 5,
                                  totalDays: task.estimatedHours ? Math.ceil(task.estimatedHours / 8) : 5,
                                  totalHrs: task.estimatedHours || 40,
                                  unitPrice: 5000,
                                  total: (task.estimatedHours || 40) * 125,
                                };
                              });
                            }

                            if (servicesList.length > 0) {
                              const restoredRows = servicesList.map((svc: any) => ({
                                rowId: svc.id,
                                dept: svc.department,
                                taskId: svc.id,
                                name: svc.serviceName,
                                description: svc.description || "",
                                qty: svc.qty || 1,
                                resourceLevel: svc.resourceLevel || "",
                                frequency: svc.frequency || "",
                                serviceModel: svc.serviceModel || "",
                                location: svc.location || "",
                                locationText: svc.locationText || "",
                                deliveryFormat: svc.finalDeliveryFormat || svc.deliveryFormat || "",
                                tools: svc.tools || "",
                                startDate: svc.startDate || todayIso,
                                endDate: svc.endDate || "",
                                durationDays: svc.duration || svc.durationDays || 0,
                                durationHrs: (svc.duration || svc.durationDays || 0) * 8,
                                totalDays: svc.totalDays || svc.duration || 0,
                                totalHrs: svc.totalHrs || (svc.totalDays || svc.duration || 0) * 8,
                                unitPrice: svc.unitPrice || 0,
                                total: svc.total || 0,
                                deliveryModel: svc.deliveryModel || "Remote",
                                billingModel: svc.billingModel || bModel || "",
                              }));
                              setServiceRows(restoredRows);

                              const selObj: Record<string, Record<string, boolean>> = {};
                              restoredRows.forEach((row) => {
                                if (!selObj[row.dept]) selObj[row.dept] = {};
                                selObj[row.dept][row.rowId] = true;
                              });
                              setSelectedServices(selObj);
                              setTempSelected(selObj);
                            } else {
                              setServiceRows([]);
                              setSelectedServices({});
                              setTempSelected({});
                            }

                            // Load invoices
                            if (pAny.wbsDetails?.accounts?.invoices) {
                              const restoredInvoices = pAny.wbsDetails.accounts.invoices.map((inv: any) => ({
                                rowId: inv.id,
                                serviceId: inv.serviceId || "",
                                serviceName: inv.serviceName || "",
                                milestone: inv.milestone,
                                targetDate: inv.targetDate || inv.invoiceDate || "",
                                unitPrice: inv.unitPrice || inv.amount || 0,
                                qty: inv.qty || 1,
                                currency: inv.currency || pAny.currency || "INR",
                                amount: inv.amount,
                                invoiceStatus: inv.invoiceStatus || "Not Raised",
                                invoiceNumber: inv.invoiceNumber || inv.remarks || "",
                                paymentStatus: inv.paymentStatus || "Not Received",
                                paymentDate: inv.paymentDate || "",
                                invoiceDate: inv.invoiceDate || "",
                                description: inv.remarks || "",
                              }));
                              setInvoiceRows(restoredInvoices);
                            } else {
                              setInvoiceRows([]);
                            }

                            setWbsDropOpen(false);
                          }}
                          style={{ padding: "10px 14px", cursor: "pointer", borderBottom: "1px solid #f3f4f6", background: renewalProject?.id === pAny.id ? "#eff6ff" : "transparent" }}
                        >
                          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8 }}>
                            <div style={{ display: "flex", flexDirection: "column", gap: 2 }}>
                              <span style={{ fontSize: 11, color: "#6b7280" }}>{c?.name}{pAny.subVenture ? ` · ${pAny.subVenture}` : ""} · {pAny.wbsId}</span>
                            </div>
                            <span style={{ fontSize: 10, fontWeight: 600, padding: "2px 8px", borderRadius: 12, background: "#dbeafe", color: "#1e40af", flexShrink: 0 }}>Renewal</span>
                          </div>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        {/* ── Client Info Bar ── */}
        <div style={{ background: "#fff", border: "1px solid #d1d5db", borderRadius: 8, padding: 16, marginBottom: 20, boxShadow: "0 1px 3px rgba(0,0,0,0.05)" }}>
          <div style={{ display: "flex", alignItems: "flex-start", gap: 16, flexWrap: "wrap" }}>

            {/* Avatar */}
            <div style={{ width: 48, height: 48, borderRadius: "50%", background: selectedClient ? "#1a84d4" : "#d1d5db", color: "#fff", display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20, fontWeight: 700, flexShrink: 0, marginTop: 18 }}>
              {selectedClient?.logo?.charAt(0) || "?"}
            </div>

            {/* Fields */}
            <div style={{ flex: 1, minWidth: 260 }}>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>

                {/* ── Client Name combobox ── */}
                <div>
                  <div style={{ fontSize: 11, fontWeight: 600, color: "#6b7280", marginBottom: 4, textTransform: "uppercase", letterSpacing: "0.05em" }}>
                    TK Customer / Partner Name <span style={{ color: "#ef4444" }}>*</span>
                  </div>
                  <div style={{ position: "relative" }}>
                    <input
                      type="text"
                      value={clientSearch}
                      placeholder="Search and select a client…"
                      onFocus={() => setClientDropOpen(true)}
                      onChange={(e) => { setClientSearch(e.target.value); setClientDropOpen(true); }}
                      onBlur={() => setTimeout(() => {
                        setClientDropOpen(false);
                        if (!selectedClientId) setClientSearch("");
                        else setClientSearch(clients.find((c) => c.id === selectedClientId)?.name ?? "");
                      }, 150)}
                      style={{ ...inputStyle(false), paddingRight: 28 }}
                    />
                    {/* Clear icon when a client is selected */}
                    {selectedClientId && (
                      <span
                        onMouseDown={() => {
                          setSelectedClientId("");
                          setClientSearch("");
                          setSvSearch("");
                          setSelectedSubVenture("");
                          setEngagementManager("");
                        }}
                        style={{ position: "absolute", right: 8, top: "50%", transform: "translateY(-50%)", color: "#9ca3af", cursor: "pointer", fontSize: 14, lineHeight: 1 }}
                        title="Clear client"
                      >×</span>
                    )}
                    {!selectedClientId && (
                      <span style={{ position: "absolute", right: 8, top: "50%", transform: "translateY(-50%)", color: "#9ca3af", pointerEvents: "none", fontSize: 11 }}>▾</span>
                    )}
                    {clientDropOpen && (
                      <div style={{ position: "absolute", top: "calc(100% + 4px)", left: 0, right: 0, background: "#fff", border: "1px solid #d1d5db", borderRadius: 6, boxShadow: "0 4px 16px rgba(0,0,0,0.12)", zIndex: 300, maxHeight: 240, overflowY: "auto" }}>
                        {filteredClients.length === 0 ? (
                          <div style={{ padding: "10px 12px", fontSize: 12, color: "#6b7280" }}>No clients match</div>
                        ) : filteredClients.map((c) => (
                          <div
                            key={c.id}
                            onMouseDown={() => {
                              setSelectedClientId(c.id);
                              setClientSearch(c.name);
                              setEngagementManager(c.engagementManager ?? "");
                              // Reset sub-venture when client changes
                              setSvSearch("");
                              setSelectedSubVenture("");
                              setClientDropOpen(false);
                            }}
                            style={{
                              padding: "9px 12px", cursor: "pointer", fontSize: 13,
                              borderBottom: "1px solid #f3f4f6",
                              background: c.id === selectedClientId ? "#eff6ff" : "transparent",
                              display: "flex", alignItems: "center", gap: 10,
                            }}
                          >
                            <span style={{ width: 28, height: 28, borderRadius: "50%", background: "#1a84d4", color: "#fff", display: "inline-flex", alignItems: "center", justifyContent: "center", fontSize: 11, fontWeight: 700, flexShrink: 0 }}>{c.logo?.charAt(0)}</span>
                            <div style={{ display: "flex", flexDirection: "column", gap: 1 }}>
                              <span style={{ fontWeight: 600, color: "#111827" }}>{c.name}</span>
                              <span style={{ fontSize: 11, color: "#6b7280" }}>{c.industry} · {c.subVentures?.length ?? 0} sub-ventures</span>
                            </div>
                            {c.id === selectedClientId && <span style={{ marginLeft: "auto", color: "#1a84d4", fontSize: 13 }}>✓</span>}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                  {selectedClient && (
                    <div style={{ fontSize: 11, color: "#6b7280", marginTop: 3 }}>
                      {selectedClient.industry} · {selectedClient.contact}
                    </div>
                  )}
                </div>

                {/* ── Sub-venture combobox ── */}
                <div>
                  <div style={{ fontSize: 11, fontWeight: 600, color: "#6b7280", marginBottom: 4, textTransform: "uppercase", letterSpacing: "0.05em" }}>
                    End Customer Name / Sub-venture Name
                  </div>
                  <div style={{ position: "relative" }}>
                    <input
                      type="text"
                      value={svSearch}
                      placeholder={selectedClientId ? `Search sub-venture of ${selectedClient?.name}…` : "Select a client first…"}
                      disabled={!selectedClientId}
                      onFocus={() => { if (selectedClientId) setSvDropOpen(true); }}
                      onChange={(e) => { setSvSearch(e.target.value); setSvDropOpen(true); }}
                      onBlur={() => setTimeout(() => {
                        setSvDropOpen(false);
                        if (!selectedSubVenture) setSvSearch("");
                        else setSvSearch(selectedSubVenture);
                      }, 150)}
                      style={{ ...inputStyle(!selectedClientId), paddingRight: 28 }}
                    />
                    {selectedSubVenture && (
                      <span
                        onMouseDown={() => { setSelectedSubVenture(""); setSvSearch(""); }}
                        style={{ position: "absolute", right: 8, top: "50%", transform: "translateY(-50%)", color: "#9ca3af", cursor: "pointer", fontSize: 14, lineHeight: 1 }}
                        title="Clear sub-venture"
                      >×</span>
                    )}
                    {!selectedSubVenture && (
                      <span style={{ position: "absolute", right: 8, top: "50%", transform: "translateY(-50%)", color: "#9ca3af", pointerEvents: "none", fontSize: 11 }}>▾</span>
                    )}
                    {svDropOpen && selectedClientId && (
                      <div style={{ position: "absolute", top: "calc(100% + 4px)", left: 0, right: 0, background: "#fff", border: "1px solid #d1d5db", borderRadius: 6, boxShadow: "0 4px 16px rgba(0,0,0,0.12)", zIndex: 300, maxHeight: 220, overflowY: "auto" }}>
                        {filteredSubVentures.length === 0 ? (
                          <div style={{ padding: "10px 12px", fontSize: 12, color: "#6b7280" }}>No sub-ventures match</div>
                        ) : filteredSubVentures.map((sv) => (
                          <div
                            key={sv}
                            onMouseDown={() => {
                              setSelectedSubVenture(sv);
                              setSvSearch(sv);
                              setSvDropOpen(false);
                            }}
                            style={{
                              padding: "8px 12px", cursor: "pointer", fontSize: 13,
                              borderBottom: "1px solid #f3f4f6",
                              background: sv === selectedSubVenture ? "#eff6ff" : "transparent",
                              display: "flex", alignItems: "center", justifyContent: "space-between",
                            }}
                          >
                            <span style={{ color: "#111827" }}>{sv}</span>
                            {sv === selectedSubVenture && <span style={{ color: "#1a84d4", fontSize: 13 }}>✓</span>}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                  {selectedClientId && (
                    <div style={{ fontSize: 11, color: "#6b7280", marginTop: 3 }}>
                      {clientSubVentures.length} sub-ventures available
                    </div>
                  )}
                </div>

              </div>
            </div>

            {/* IDs panel */}
            <div style={{ display: "flex", flexDirection: "column", gap: 10, fontSize: 13, flexShrink: 0, alignSelf: "center" }}>
              <div style={{ display: "flex", gap: 20 }}>
                <div>
                  <div style={{ color: "#6b7280", fontSize: 11, fontWeight: 600, textTransform: "uppercase" }}>Client ID</div>
                  <div style={{ fontWeight: 700, color: "#1a5490", fontSize: 14 }}>
                    {selectedClient ? (selectedClient.id.startsWith("C") ? selectedClient.id : "C" + String(clients.findIndex((c) => c.id === selectedClientId) + 1).padStart(3, "0")) : "—"}
                  </div>
                </div>
                <div>
                  <div style={{ color: "#6b7280", fontSize: 11, fontWeight: 600, textTransform: "uppercase" }}>Project ID</div>
                  <div style={{ fontWeight: 700, color: "#1a5490", fontSize: 14 }}>{buildProjectDisplayId()}</div>
                </div>
              </div>
              <div>
                <div style={{ color: "#6b7280", fontSize: 11, fontWeight: 600, textTransform: "uppercase" }}>WBS ID</div>
                <div style={{ fontWeight: 700, color: "#059669", fontSize: 14, letterSpacing: "0.02em" }}>{wbsId}</div>
              </div>
            </div>

          </div>
        </div>

        {/* ── WBS Header Card ── */}
        <Card title="WBS Information">
          {/* Row 1: Project Name + Engagement Manager */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 16, marginBottom: 16 }}>
            <FormGroup label="Project Name" required>
              <input type="text" value={projectName} onChange={(e) => setProjectName(e.target.value)} style={inputStyle(false)} />
            </FormGroup>
            <FormGroup label="Engagement Manager">
              <input type="text" value={engagementManager} readOnly style={inputStyle(true)} />
            </FormGroup>
          </div>
          {/* Row 2: Contract Type + Sales Person */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 16, marginBottom: 16 }}>
            <FormGroup label="Contract Type" required>
              <select
                value={contractType}
                onChange={(e) => {
                  const val = e.target.value;
                  setContractType(val);
                  if (val === "Resource Based") {
                    setProjectType("Long Term");
                  } else {
                    setProjectType("");
                  }
                  setBillingModel("");
                  setPaymentTerms("");
                }}
                style={inputStyle(false)}
              >
                <option value="">Select Contract Type</option>
                <option value="Resource Based">Resource Based</option>
                <option value="Scope Based">Scope Based</option>
              </select>
            </FormGroup>
            <FormGroup label="Sales Person" required>
              <select value={salesPerson} onChange={(e) => setSalesPerson(e.target.value)} style={inputStyle(false)}>
                <option value="">Select Sales Person</option>
                <option value="Abhishek Sharma">Abhishek Sharma</option>
                <option value="Pradeep Singh">Pradeep Singh</option>
                <option value="Dhanshree">Dhanshree</option>
              </select>
            </FormGroup>
          </div>
          {/* Row 3: Project Type + Onboarding Date */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 16 }}>
            <FormGroup label="Project Type" required>
              <select
                value={projectType}
                disabled={contractType === "Resource Based" || !contractType}
                onChange={(e) => {
                  const val = e.target.value;
                  setProjectType(val);
                  setBillingModel("");
                  setPaymentTerms("");
                  if (val === "Ad-Hoc") {
                    setServiceRows((prev) =>
                      prev.map((r) => {
                        const updated = { ...r, frequency: "Once" };
                        updated.endDate = computeEndDate(updated);
                        return updated;
                      })
                    );
                  }
                }}
                style={inputStyle(contractType === "Resource Based" || !contractType)}
                title={!contractType ? "Select a Contract Type first" : ""}
              >
                {!contractType ? (
                  <option value="">Select Contract Type first</option>
                ) : contractType === "Resource Based" ? (
                  <option value="Long Term">Long Term</option>
                ) : (
                  <>
                    <option value="">Select Project Type</option>
                    <option value="Ad-Hoc">Ad-Hoc</option>
                    <option value="Long Term">Long Term</option>
                  </>
                )}
              </select>
            </FormGroup>
            <FormGroup label="Project Onboarding Date" required>
              <input type="date" value={projectIssuedDate} readOnly style={inputStyle(true)} />
            </FormGroup>
          </div>
        </Card>

        {/* ── Section A ── */}
        <Card title="Section A: PMO Team Details">
          <button
            onClick={openPicker}
            disabled={!contractType}
            title={!contractType ? "Please select a Contract Type first" : ""}
            style={{
              ...btnStyle(contractType ? "primary" : "secondary"),
              marginBottom: 12,
              cursor: contractType ? "pointer" : "not-allowed",
              opacity: contractType ? 1 : 0.6
            }}
          >
            + Add Services
          </button>

          {/* Service tags */}
          {serviceRows.length > 0 && (
            <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 16, padding: 12, background: "#f3f4f6", borderRadius: 6 }}>
              {serviceRows.map((r) => (
                <div key={r.rowId} style={{ background: "#1a84d4", color: "#fff", padding: "6px 10px", borderRadius: 4, fontSize: 12, display: "flex", alignItems: "center", gap: 6 }}>
                  {r.name} ({r.dept})
                  <span onClick={() => removeServiceRow(r.rowId)} style={{ cursor: "pointer", fontWeight: "bold" }}>×</span>
                </div>
              ))}
            </div>
          )}

          {/* Service table */}
          <div style={{ overflowX: "auto" }}>
            <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
              <thead style={{ background: "#f3f4f6" }}>
                <tr>
                  <th style={{ ...thStyle, minWidth: 140 }}>Department</th>
                  <th style={{ ...thStyle, minWidth: 100 }}>Service ID</th>
                  <th style={{ ...thStyle, minWidth: 200 }}>Service Name</th>
                  <th style={{ ...thStyle, minWidth: 180 }}>Description</th>
                  <th style={{ ...thStyle, minWidth: 110 }}>Resource Level</th>
                  <th style={{ ...thStyle, minWidth: 60 }}>Qty</th>
                  <th style={{ ...thStyle, minWidth: 120 }}>Frequency</th>
                  <th style={{ ...thStyle, minWidth: 160 }}>Service Model</th>
                  <th style={{ ...thStyle, minWidth: 110 }}>Delivery Model</th>
                  <th style={{ ...thStyle, minWidth: 140 }}>Delivery Site</th>
                  <th style={{ ...thStyle, minWidth: 140 }}>Final Delivery Format</th>
                  <th style={{ ...thStyle, minWidth: 160 }}>Tools</th>
                  <th style={{ ...thStyle, minWidth: 140 }}>WBS Start Date</th>
                  <th style={{ ...thStyle, minWidth: 140 }}>WBS End Date</th>
                  <th style={{ ...thStyle, minWidth: 80 }}>Duration (Days)</th>
                  <th style={{ ...thStyle, minWidth: 80 }}>Duration (Hrs)</th>
                  <th style={{ ...thStyle, minWidth: 80 }}>Total Days</th>
                  <th style={{ ...thStyle, minWidth: 80 }}>Total Hrs</th>
                  <th style={{ ...thStyle, minWidth: 100 }}>Unit Price</th>
                  <th style={{ ...thStyle, minWidth: 100 }}>Total</th>
                  <th style={{ ...thStyle, minWidth: 50 }}></th>
                </tr>
              </thead>
              <tbody>
                {serviceRows.length === 0 && (
                  <tr><td colSpan={20} style={{ ...tdStyle, textAlign: "center", color: "#6b7280", padding: 32 }}>No services added. Click "+ Add Services" to begin.</td></tr>
                )}
                {serviceRows.map((r) => {
                  // helper: red border on empty required cells
                  const req = (val: string | number) =>
                    !val || (typeof val === "string" && !val.trim())
                      ? { ...tblInputStyle, border: "1.5px solid #ef4444" }
                      : tblInputStyle;
                  const reqSel = (val: string) =>
                    !val ? { ...tblInputStyle, border: "1.5px solid #ef4444" } : tblInputStyle;
                  const isOffsite = r.location === "Offsite";
                  return (
                    <tr key={r.rowId}>
                      <td style={tdStyle}><input type="text" value={r.dept} readOnly style={{ ...tblInputStyle, background: "#f3f4f6", minWidth: 140 }} /></td>
                      <td style={tdStyle}><input type="text" value={r.taskId} onChange={(e) => updateRow(r.rowId, "taskId", e.target.value)} style={{ ...req(r.taskId), minWidth: 100 }} /></td>
                      <td style={tdStyle}><input type="text" value={r.name} onChange={(e) => updateRow(r.rowId, "name", e.target.value)} style={{ ...req(r.name), minWidth: 200 }} /></td>
                      <td style={tdStyle}><input type="text" value={r.description} onChange={(e) => updateRow(r.rowId, "description", e.target.value)} style={{ ...tblInputStyle, minWidth: 180 }} /></td>
                      <td style={tdStyle}>
                        <select value={r.resourceLevel} onChange={(e) => updateRow(r.rowId, "resourceLevel", e.target.value)} style={{ ...tblInputStyle, minWidth: 110 }}>
                          <option value="">— Select —</option>
                          <option value="L1">L1</option>
                          <option value="L2">L2</option>
                          <option value="Senior">Senior</option>
                        </select>
                      </td>
                      <td style={tdStyle}><input type="number" value={r.qty} min={1} onChange={(e) => updateRow(r.rowId, "qty", Number(e.target.value))} style={{ ...tblInputStyle, minWidth: 60 }} /></td>
                      <td style={tdStyle}>
                        {projectType === "Ad-Hoc" ? (
                          <input
                            type="text"
                            value="Once"
                            readOnly
                            style={{
                              ...tblInputStyle,
                              background: "#f3f4f6",
                              color: "#9ca3af",
                              cursor: "not-allowed",
                              minWidth: 120,
                              textAlign: "center"
                            }}
                          />
                        ) : (
                          <select value={r.frequency} onChange={(e) => updateRow(r.rowId, "frequency", e.target.value)} style={{ ...reqSel(r.frequency), minWidth: 120 }}>
                            <option value="">— Select —</option>
                            <option value="Once">Once</option>
                            <option value="Half yearly">Half yearly</option>
                            <option value="Yearly">Yearly</option>
                          </select>
                        )}
                      </td>
                      <td style={tdStyle}>
                        {DEPT_GROUPS[r.dept] === "Resource" ? (
                          <input
                            type="text"
                            value="NA"
                            readOnly
                            style={{
                              ...tblInputStyle,
                              background: "#f3f4f6",
                              color: "#9ca3af",
                              cursor: "not-allowed",
                              minWidth: 160,
                              textAlign: "center"
                            }}
                          />
                        ) : (
                          <select value={r.serviceModel} onChange={(e) => updateRow(r.rowId, "serviceModel", e.target.value)} style={{ ...reqSel(r.serviceModel), minWidth: 160 }}>
                            <option value="">— Select —</option>
                            <option value="Initial Test">Initial Test</option>
                            <option value="Initial + 1 Re-test">Initial + 1 Re-test</option>
                            <option value="Initial + 2 Re-test">Initial + 2 Re-test</option>
                            <option value="Initial + 3 Re-test">Initial + 3 Re-test</option>
                          </select>
                        )}
                      </td>
                      <td style={tdStyle}>
                        <select value={r.location} onChange={(e) => {
                          updateRow(r.rowId, "location", e.target.value);
                          // clear locationText when switching away from Onsite
                          if (e.target.value !== "Onsite") updateRow(r.rowId, "locationText", "");
                        }} style={{ ...reqSel(r.location), minWidth: 110 }}>
                          <option value="">— Select —</option>
                          <option>Onsite</option><option>Offsite</option><option>Hybrid</option>
                        </select>
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="text"
                          value={r.locationText}
                          onChange={(e) => updateRow(r.rowId, "locationText", e.target.value)}
                          placeholder={r.location === "Onsite" ? "Enter location…" : "—"}
                          readOnly={r.location !== "Onsite"}
                          style={{
                            ...tblInputStyle,
                            minWidth: 140,
                            ...(r.location === "Onsite"
                              ? (!r.locationText.trim() ? { border: "1.5px solid #ef4444" } : {})
                              : { background: "#f3f4f6", color: "#9ca3af", cursor: "not-allowed" }),
                          }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <select value={r.deliveryFormat} onChange={(e) => updateRow(r.rowId, "deliveryFormat", e.target.value)} style={{ ...reqSel(r.deliveryFormat), minWidth: 140 }}>
                          <option value="">— Select —</option>
                          <option value="PDF">PDF</option>
                          <option value="Excel">Excel</option>
                          <option value="Squad 1">Squad 1</option>
                          <option value="Other Toolbase">Other Toolbase</option>
                        </select>
                      </td>
                      <td style={tdStyle}><input type="text" value={r.tools} onChange={(e) => updateRow(r.rowId, "tools", e.target.value)} style={{ ...req(r.tools), minWidth: 160 }} /></td>
                      <td style={tdStyle}><input type="date" value={r.startDate} onChange={(e) => updateRow(r.rowId, "startDate", e.target.value)} style={{ ...req(r.startDate), minWidth: 140 }} /></td>
                      <td style={tdStyle}><input type="date" value={r.endDate} onChange={(e) => updateRow(r.rowId, "endDate", e.target.value)} style={{ ...req(r.endDate), minWidth: 140 }} title="WBS End Date" /></td>
                      <td style={tdStyle}><input type="number" value={r.durationDays} onChange={(e) => updateRow(r.rowId, "durationDays", Number(e.target.value))} style={{ ...req(r.durationDays), minWidth: 80 }} /></td>
                      <td style={tdStyle}><input type="number" value={r.durationHrs} onChange={(e) => updateRow(r.rowId, "durationHrs", Number(e.target.value))} style={{ ...req(r.durationHrs), minWidth: 80 }} /></td>
                      <td style={tdStyle}><input type="number" value={r.totalDays} onChange={(e) => updateRow(r.rowId, "totalDays", Number(e.target.value))} style={{ ...req(r.totalDays), minWidth: 80 }} /></td>
                      <td style={tdStyle}><input type="number" value={r.totalHrs} onChange={(e) => updateRow(r.rowId, "totalHrs", Number(e.target.value))} style={{ ...req(r.totalHrs), minWidth: 80 }} /></td>
                      <td style={tdStyle}><input type="number" value={r.unitPrice} min={0} onChange={(e) => updateRow(r.rowId, "unitPrice", Number(e.target.value))} style={{ ...req(r.unitPrice), minWidth: 100 }} /></td>
                      <td style={tdStyle}><input type="number" value={r.total} readOnly style={{ ...tblInputStyle, background: "#f3f4f6", minWidth: 100 }} /></td>
                      <td style={tdStyle}>
                        <button
                          onClick={() => removeServiceRow(r.rowId)}
                          title="Remove row"
                          style={{ background: "#ef4444", color: "#fff", border: "none", padding: "4px 8px", borderRadius: 4, cursor: "pointer", fontSize: 11 }}
                        >✕</button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* Invoice summary bar */}
          {serviceRows.length > 0 && (
            <div style={{ background: "#f0f9ff", padding: 12, borderRadius: 6, marginTop: 16, display: "flex", justifyContent: "space-around", alignItems: "center", fontSize: 14, flexWrap: "wrap", gap: 16 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 600 }}>Subtotal:</span>
                <span style={{ fontWeight: 600, color: "#1a5490" }}>{sym}{subtotal.toLocaleString()}</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 600 }}>Tax (%):</span>
                <input type="number" value={taxPercent} min={0} max={100} onChange={(e) => setTaxPercent(Number(e.target.value))} style={{ width: 50, padding: 4, border: "1px solid #ccc", borderRadius: 4 }} />
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 600 }}>Invoice Target:</span>
                <span style={{ fontWeight: 600, color: "#1a5490" }}>{sym}{invoiceTarget.toLocaleString()}</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 600 }}>Total Hours:</span>
                <span style={{ fontWeight: 600, color: "#666" }}>{totalHours} hrs</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 600 }}>Total Days:</span>
                <span style={{ fontWeight: 600, color: "#666" }}>{totalDays} days</span>
              </div>
            </div>
          )}

          {/* Comments A */}
          <div style={{ marginTop: 20, paddingTop: 16, borderTop: "1px solid #d1d5db" }}>
            <label style={{ fontWeight: 600, fontSize: 14, display: "block", marginBottom: 12 }}>Comments / Notes</label>
            <textarea value={sectionAComments} onChange={(e) => setSectionAComments(e.target.value)} placeholder="Add any remarks, scope notes, or delivery instructions..." style={{ width: "100%", minHeight: 80, padding: 10, border: "1px solid #d1d5db", borderRadius: 6, fontFamily: "inherit", resize: "vertical", boxSizing: "border-box" }} />
          </div>
        </Card>

        {/* ── Section B ── */}
        <Card title="Section B: Accounts Team Details">
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 16, marginBottom: 16 }}>
            <FormGroup label="Billing Model" required>
              <select
                value={billingModel}
                disabled={!projectType}
                onChange={(e) => onBillingModelChange(e.target.value)}
                style={inputStyle(!projectType)}
                title={!projectType ? "Select a Project Type in WBS Information first" : ""}
              >
                {!projectType
                  ? <option value="">⚠ Select Project Type first</option>
                  : <option value="">Select Billing Model</option>
                }
                {(BILLING_MODELS[projectType] || []).map((m) => <option key={m} value={m}>{m}</option>)}
              </select>
            </FormGroup>
            <FormGroup label={`Payment Terms${billingModel === "Custom" ? " *" : ""}`}>
              {billingModel === "Custom" ? (
                <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                  {customPayments.map((cp, idx) => {
                    const ordinals = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth"];
                    const defaultLabel = `${ordinals[idx] ?? `Payment ${idx + 1}`} Payment`;
                    return (
                      <div key={idx} style={{ display: "flex", alignItems: "center", gap: 8 }}>
                        <input
                          type="text"
                          value={cp.label}
                          placeholder={defaultLabel}
                          onChange={(e) => setCustomPayments(prev => prev.map((p, i) => i === idx ? { ...p, label: e.target.value } : p))}
                          style={{ ...inputStyle(false), flex: 1, fontSize: 12 }}
                        />
                        <div style={{ display: "flex", alignItems: "center", gap: 4, flexShrink: 0 }}>
                          <input
                            type="number"
                            value={cp.pct}
                            min={0}
                            max={100}
                            onChange={(e) => setCustomPayments(prev => prev.map((p, i) => i === idx ? { ...p, pct: Number(e.target.value) } : p))}
                            className="no-spinner"
                            style={{ width: 64, padding: "8px 6px", border: "1px solid #d1d5db", borderRadius: 6, fontSize: 13, textAlign: "right" }}
                          />
                          <span style={{ fontSize: 13, fontWeight: 600, color: "#374151" }}>%</span>
                        </div>
                        {customPayments.length > 1 && (
                          <button
                            type="button"
                            onClick={() => setCustomPayments(prev => prev.filter((_, i) => i !== idx))}
                            style={{ background: "#fee2e2", border: "1px solid #fca5a5", color: "#dc2626", borderRadius: 4, padding: "4px 8px", cursor: "pointer", fontSize: 12, fontWeight: 700, flexShrink: 0 }}
                            title="Remove payment"
                          >×</button>
                        )}
                      </div>
                    );
                  })}
                  {/* Running total + add button */}
                  {(() => {
                    const total = customPayments.reduce((s, p) => s + (Number(p.pct) || 0), 0);
                    const isValid = total === 100;
                    const isFull = total >= 100;
                    return (
                      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: 4 }}>
                        <button
                          type="button"
                          disabled={isFull}
                          onClick={() => {
                            const ordinals = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth"];
                            const nextIdx = customPayments.length;
                            const label = `${ordinals[nextIdx] ?? `Payment ${nextIdx + 1}`} Payment`;
                            setCustomPayments(prev => [...prev, { label, pct: 0 }]);
                          }}
                          style={{
                            background: isFull ? "#f3f4f6" : "#eff6ff",
                            border: isFull ? "1px solid #e5e7eb" : "1px solid #bfdbfe",
                            color: isFull ? "#9ca3af" : "#1d4ed8",
                            borderRadius: 4,
                            padding: "5px 12px",
                            cursor: isFull ? "not-allowed" : "pointer",
                            fontSize: 12,
                            fontWeight: 600,
                            opacity: isFull ? 0.6 : 1,
                          }}
                        >+ Add Payment</button>
                        <span style={{ fontSize: 12, fontWeight: 700, color: isValid ? "#16a34a" : "#dc2626" }}>
                          Total: {total}% {isValid ? "✓" : `— needs ${100 - total > 0 ? "+" : ""}${100 - total}% more`}
                        </span>
                      </div>
                    );
                  })()}
                </div>
              ) : (
                <input
                  type="text"
                  value={paymentTerms}
                  readOnly
                  placeholder={billingModel ? "Auto-set by billing model" : "—"}
                  style={inputStyle(true)}
                />
              )}
            </FormGroup>
          </div>

          {/* Currency & PO Status */}
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 16, marginBottom: 16 }}>
            <FormGroup label="Currency">
              <div style={{ display: "flex", alignItems: "center", gap: 10, padding: "8px 10px", background: "#f3f4f6", borderRadius: 6, height: 38, boxSizing: "border-box" }}>
                <select value={currency} onChange={(e) => setCurrency(e.target.value)} style={{ ...inputStyle(false), flex: "0 0 100px", height: 26, padding: "2px 6px", fontSize: 12 }}>
                  {Object.keys(CURRENCY_SYMBOLS).map((c) => <option key={c} value={c}>{c} — {CURRENCY_SYMBOLS[c]}</option>)}
                </select>
                <span style={{ fontSize: 11, color: "#6b7280", whiteSpace: "nowrap" }}>1 {currency} = {CURRENCY_SYMBOLS[currency]}{currency === "INR" ? "1.00" : "varies"}</span>
              </div>
            </FormGroup>

            <FormGroup label="PO Status" required>
              <select value={poStatus} onChange={(e) => {
                const val = e.target.value;
                setPoStatus(val);
                if (val !== "PO Received") setPoFile(null);
              }} style={inputStyle(false)}>
                <option value="">Select PO Status</option>
                <option value="PO Received">PO Received</option>
                <option value="PO Pending">PO Pending</option>
                <option value="PO Not Required">PO Not Required</option>
              </select>
            </FormGroup>
          </div>

          {/* Invoice Scheduling Section */}
          {billingModel && invoiceRows.length > 0 && (
            <div style={{ marginTop: 24, marginBottom: 24 }}>
              <label style={{ fontWeight: 600, fontSize: 14, display: "block", marginBottom: 10, color: "#1a5490" }}>
                Invoice Scheduling
              </label>
              <div style={{ overflowX: "auto", maxHeight: "400px", border: "1px solid #e5e7eb", borderRadius: 8, boxShadow: "0 1px 3px rgba(0,0,0,0.02)" }}>
                <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
                  <thead style={{ background: "#f9fafb", position: "sticky", top: 0, zIndex: 10 }}>
                    {(() => {
                      const thStyleOverride: React.CSSProperties = {
                        padding: "12px 10px",
                        fontWeight: 600,
                        color: "#4b5563",
                        borderBottom: "2px solid #e5e7eb",
                        textAlign: "center",
                        verticalAlign: "middle",
                        fontSize: 11,
                        textTransform: "uppercase",
                        letterSpacing: "0.05em",
                      };
                      return (
                        <tr>
                          <th style={{ ...thStyleOverride, minWidth: 160 }}>Service Name</th>
                          <th style={{ ...thStyleOverride, minWidth: 140 }}>Milestone / Period</th>
                          <th style={{ ...thStyleOverride, minWidth: 130 }}>Invoice Target Date</th>
                          <th style={{ ...thStyleOverride, minWidth: 100 }}>Unit Price</th>
                          <th style={{ ...thStyleOverride, minWidth: 60 }}>Qty</th>
                          <th style={{ ...thStyleOverride, minWidth: 80 }}>Currency</th>
                          <th style={{ ...thStyleOverride, minWidth: 120 }}>Invoice Amount</th>
                          <th style={{ ...thStyleOverride, minWidth: 120 }}>Invoice Status</th>
                          <th style={{ ...thStyleOverride, minWidth: 130 }}>Invoice Number</th>
                          <th style={{ ...thStyleOverride, minWidth: 120 }}>Payment Status</th>
                          <th style={{ ...thStyleOverride, minWidth: 130 }}>Date of Payment Received</th>
                        </tr>
                      );
                    })()}
                  </thead>
                  <tbody>
                    {(() => {
                      const serviceGroupColors = [
                        "#f0f7ff", // Soft Pastel Blue (Azure-like)
                        "#f0fdf4", // Soft Pastel Green (Google Cloud-like)
                        "#fffbeb", // Soft Pastel Yellow/Amber
                        "#fdf2f8", // Soft Pastel Pink
                        "#faf5ff", // Soft Pastel Purple
                      ];
                      
                      const getHoverColor = (color: string) => {
                        switch (color) {
                          case "#f0f7ff": return "#e7f2ff";
                          case "#f0fdf4": return "#e6faf0";
                          case "#fffbeb": return "#fff9db";
                          case "#fdf2f8": return "#fdf0f7";
                          case "#faf5ff": return "#fbf3ff";
                          default: return "#f9fafb";
                        }
                      };

                      const uniqueServiceIds = Array.from(new Set(invoiceRows.map(r => r.serviceId)));
                      const serviceColorMap: Record<string, string> = {};
                      uniqueServiceIds.forEach((id, idx) => {
                        serviceColorMap[id] = serviceGroupColors[idx % serviceGroupColors.length];
                      });

                      const tdStyleOverride: React.CSSProperties = {
                        padding: "10px 8px",
                        borderBottom: "1px solid #f3f4f6",
                        verticalAlign: "middle",
                        textAlign: "center",
                        fontSize: 12,
                      };

                      const invInputStyle: React.CSSProperties = {
                        ...tblInputStyle,
                        textAlign: "center",
                        textAlignLast: "center",
                        margin: "0 auto",
                      };

                      return invoiceRows.map((inv) => {
                        const isHovered = hoveredInvoiceRowId === inv.rowId;
                        const baseBg = serviceColorMap[inv.serviceId] || "#ffffff";
                        const bg = isHovered ? getHoverColor(baseBg) : baseBg;

                        const rowStyle: React.CSSProperties = {
                          backgroundColor: bg,
                          transition: "background-color 0.15s ease",
                        };

                        return (
                          <tr
                            key={inv.rowId}
                            style={rowStyle}
                            onMouseEnter={() => setHoveredInvoiceRowId(inv.rowId)}
                            onMouseLeave={() => setHoveredInvoiceRowId(null)}
                          >
                            {/* Service Name */}
                            <td style={{ ...tdStyleOverride, fontWeight: 500, color: "#374151" }}>{inv.serviceName}</td>
                            
                            {/* Milestone / Period */}
                            <td style={tdStyleOverride}>
                              <span style={{ display: "inline-flex", alignItems: "center", background: "rgba(255, 255, 255, 0.7)", border: "1px solid rgba(0, 0, 0, 0.05)", color: "#374151", padding: "2px 8px", borderRadius: 12, fontSize: 10, fontWeight: 600 }}>
                                {inv.milestone}
                              </span>
                            </td>

                            {/* Invoice Target Date */}
                            <td style={tdStyleOverride}>
                              <input
                                type="date"
                                value={inv.targetDate}
                                onChange={(e) => updateInvoiceRowField(inv.rowId, "targetDate", e.target.value)}
                                style={invInputStyle}
                              />
                            </td>

                            {/* Unit Price */}
                            <td style={{ ...tdStyleOverride, fontWeight: 500 }}>
                              {CURRENCY_SYMBOLS[inv.currency] || ""}{inv.unitPrice.toLocaleString()}
                            </td>

                            {/* Qty */}
                            <td style={tdStyleOverride}>{inv.qty}</td>

                            {/* Currency */}
                            <td style={{ ...tdStyleOverride, fontWeight: 500 }}>{inv.currency}</td>

                            {/* Invoice Amount */}
                            <td style={{ ...tdStyleOverride, fontWeight: 600, color: "#1a5490" }}>
                              {CURRENCY_SYMBOLS[inv.currency] || ""}{inv.amount.toLocaleString()}
                            </td>

                            {/* Invoice Status */}
                            <td style={tdStyleOverride}>
                              <select
                                value={inv.invoiceStatus}
                                onChange={(e) => updateInvoiceRowField(inv.rowId, "invoiceStatus", e.target.value)}
                                style={invInputStyle}
                              >
                                <option value="Not Raised">Not Raised</option>
                                <option value="Raised">Raised</option>
                              </select>
                            </td>

                            {/* Invoice Number */}
                            <td style={tdStyleOverride}>
                              <code style={{ fontFamily: "monospace", fontSize: 11, background: "rgba(255, 255, 255, 0.6)", padding: "2px 6px", border: "1px solid rgba(0, 0, 0, 0.08)", borderRadius: 4 }}>
                                {inv.invoiceNumber}
                              </code>
                            </td>

                            {/* Payment Status */}
                            <td style={tdStyleOverride}>
                              <select
                                value={inv.paymentStatus}
                                onChange={(e) => updateInvoiceRowField(inv.rowId, "paymentStatus", e.target.value)}
                                style={invInputStyle}
                              >
                                <option value="Not Received">Not Received</option>
                                <option value="Received">Received</option>
                              </select>
                            </td>

                            {/* Date of Payment Received */}
                            <td style={tdStyleOverride}>
                              <input
                                type="date"
                                value={inv.paymentDate}
                                onChange={(e) => updateInvoiceRowField(inv.rowId, "paymentDate", e.target.value)}
                                style={invInputStyle}
                              />
                            </td>
                          </tr>
                        );
                      });
                    })()}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* PO Details (conditional) */}
          {poStatus === "PO Received" && (
            <div style={{ marginBottom: 16 }}>
              <FormGroup label="Attach PO Document">
                <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                  <label style={{ ...btnStyle("secondary"), display: "inline-flex", alignItems: "center", gap: 6, cursor: "pointer" }}>
                    📎 Choose File
                    <input
                      type="file"
                      accept=".pdf,.doc,.docx,.xls,.xlsx,.png,.jpg,.jpeg"
                      onChange={(e) => setPoFile(e.target.files?.[0] ?? null)}
                      style={{ display: "none" }}
                    />
                  </label>
                  <span style={{ fontSize: 12, color: poFile ? "#1f2937" : "#6b7280" }}>
                    {poFile ? poFile.name : "No file selected"}
                  </span>
                  {poFile && (
                    <button onClick={() => setPoFile(null)} style={{ background: "none", border: "none", color: "#ef4444", cursor: "pointer", fontSize: 12, fontWeight: 600 }}>✕ Remove</button>
                  )}
                </div>
              </FormGroup>
            </div>
          )}


          {/* Comments B */}
          <div style={{ marginTop: 20, paddingTop: 16, borderTop: "1px solid #d1d5db" }}>
            <label style={{ fontWeight: 600, fontSize: 14, display: "block", marginBottom: 12 }}>Comments / Notes</label>
            <textarea value={sectionBComments} onChange={(e) => setSectionBComments(e.target.value)} placeholder="Add approval remarks, billing notes, or payment instructions..." style={{ width: "100%", minHeight: 80, padding: 10, border: "1px solid #d1d5db", borderRadius: 6, fontFamily: "inherit", resize: "vertical", boxSizing: "border-box" }} />
          </div>
        </Card>

        {/* ── Workflow & Approval ── */}
        <Card title="Workflow & Approval Status">
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
            <button onClick={handleSaveDraft} style={btnStyle("primary")}>Save Draft</button>
            <button onClick={handleExport} style={btnStyle("secondary")}>Export WBS</button>
            <button onClick={handleAssignWbs} style={btnStyle("primary")}>Create WBS</button>
          </div>
        </Card>

      </div>{/* /content-wrapper */}

      {/* ── Scroll to top ── */}
      <button
        onClick={() => window.scrollTo({ top: 0, behavior: "smooth" })}
        title="Scroll to top"
        style={{
          position: "fixed",
          bottom: 32,
          right: 24,
          zIndex: 999,
          width: 44,
          height: 44,
          borderRadius: "50%",
          background: "#1a84d4",
          color: "#fff",
          border: "none",
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          boxShadow: "0 4px 14px rgba(26,132,212,0.45)",
          opacity: showScrollTop ? 1 : 0,
          pointerEvents: showScrollTop ? "auto" : "none",
          transform: showScrollTop ? "translateY(0)" : "translateY(12px)",
          transition: "opacity 0.3s ease, transform 0.3s ease",
        }}
        aria-label="Scroll to top"
      >
        {/* Upward chevron */}
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="18 15 12 9 6 15" />
        </svg>
      </button>

      {/* ── Service Picker Modal ── */}
      {pickerOpen && (
        <div onClick={(e) => { if (e.target === e.currentTarget) setPickerOpen(false); }} style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", zIndex: 1000, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <div style={{ background: "#fff", borderRadius: 12, boxShadow: "0 20px 25px rgba(0,0,0,0.15)", width: "90%", maxWidth: 820, height: 600, maxHeight: "85vh", display: "flex", flexDirection: "column" }}>
            <div style={{ padding: 20, borderBottom: "1px solid #d1d5db", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div style={{ fontSize: 18, fontWeight: 700, color: "#1a5490" }}>Select Services</div>
              <button onClick={() => setPickerOpen(false)} style={{ background: "none", border: "none", fontSize: 24, cursor: "pointer" }}>×</button>
            </div>
            <div style={{ flex: 1, overflowY: "auto", padding: 20, display: "grid", gridTemplateColumns: "220px 1fr", gap: 20 }}>
              {/* Dept list grouped by Contract Type groups (Resource/Scope) */}
              <div>
                <h4 style={{ marginBottom: 12, fontSize: 13, fontWeight: 700 }}>Departments</h4>
                <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
                  {Object.entries(deptsByGroup).map(([groupName, depts]) => (
                    <div key={groupName}>
                      <div style={{ fontSize: 11, fontWeight: 700, color: "#6b7280", textTransform: "uppercase", letterSpacing: "0.05em", marginBottom: 8, borderBottom: "1px solid #e5e7eb", paddingBottom: 4 }}>
                        {groupName} Group
                      </div>
                      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                        {depts.map((dept) => (
                          <div key={dept} onClick={() => setPickerDept(dept)} style={{ padding: 10, border: "1px solid #d1d5db", borderRadius: 6, cursor: "pointer", display: "flex", justifyContent: "space-between", alignItems: "center", background: dept === pickerDept ? "#dbeafe" : "#fff", borderColor: dept === pickerDept ? "#1a84d4" : "#d1d5db" }}>
                            <span style={{ fontWeight: 600, fontSize: 12 }}>{dept}</span>
                            <span style={{ background: "#1a84d4", color: "#fff", padding: "2px 6px", borderRadius: 10, fontSize: 10, fontWeight: 600 }}>
                              {tempSelected[dept] ? Object.keys(tempSelected[dept]).length : 0}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              {/* Services list */}
              <div>
                <input type="text" placeholder="Search services..." value={pickerSearch} onChange={(e) => setPickerSearch(e.target.value)} style={{ width: "100%", padding: 8, border: "1px solid #d1d5db", borderRadius: 6, marginBottom: 12, boxSizing: "border-box" }} />
                <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                  {filteredPickerServices.map((svc) => {
                    const checked = !!(tempSelected[pickerDept] && tempSelected[pickerDept][svc.id]);
                    return (
                      <div key={svc.id} style={{ padding: 12, border: "1px solid #d1d5db", borderRadius: 6, display: "flex", alignItems: "center", gap: 10 }}>
                        <input type="checkbox" checked={checked} onChange={(e) => {
                          setTempSelected((prev) => {
                            const next = { ...prev };
                            if (!next[pickerDept]) next[pickerDept] = {};
                            if (e.target.checked) { next[pickerDept] = { ...next[pickerDept], [svc.id]: true }; }
                            else { const d = { ...next[pickerDept] }; delete d[svc.id]; next[pickerDept] = d; }
                            return next;
                          });
                        }} style={{ width: 16, height: 16 }} />
                        <div style={{ flex: 1 }}>
                          <div style={{ fontWeight: 600, fontSize: 13 }}>{svc.name}</div>
                          <div style={{ fontSize: 11, color: "#6b7280", marginTop: 2 }}>{svc.tool} • ₹{svc.unitPrice.toLocaleString()} • {svc.days} days</div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
            <div style={{ padding: "16px 20px", borderTop: "1px solid #d1d5db", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontSize: 12, color: "#6b7280" }}>Selected: <strong>{pickerTotalSelected}</strong> services</span>
              <div style={{ display: "flex", gap: 10 }}>
                <button onClick={() => setPickerOpen(false)} style={btnStyle("secondary")}>Cancel</button>
                <button onClick={confirmPicker} style={btnStyle("primary")}>✓ OK — Add to Table</button>
              </div>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}

// ─── Sub-components ──────────────────────────────────────────────────────────

function Card({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ background: "#fff", border: "1px solid #d1d5db", borderRadius: 8, padding: 20, marginBottom: 20, boxShadow: "0 1px 3px rgba(0,0,0,0.05)" }}>
      <div style={{ fontSize: 16, fontWeight: 700, color: "#1a5490", marginBottom: 16, paddingBottom: 12, borderBottom: "2px solid #1a84d4" }}>{title}</div>
      {children}
    </div>
  );
}

function FormGroup({ label, required, locked, children }: { label: string; required?: boolean; locked?: boolean; children: React.ReactNode }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 6, background: locked ? "#f3f4f6" : "transparent", borderRadius: locked ? 6 : 0, padding: locked ? "4px 0" : 0 }}>
      <label style={{ fontSize: 13, fontWeight: 600, color: "#1f2937" }}>
        {label}{required && <span style={{ color: "#ef4444" }}> *</span>}{locked && <span style={{ fontSize: 12, marginLeft: 4 }}>🔒</span>}
      </label>
      {children}
    </div>
  );
}


// ─── Style helpers ────────────────────────────────────────────────────────────

const inputStyle = (locked: boolean): React.CSSProperties => ({
  padding: "10px 12px", border: "1px solid #d1d5db", borderRadius: 6, fontSize: 13,
  fontFamily: "inherit", width: "100%", boxSizing: "border-box",
  background: locked ? "#f3f4f6" : "#fff",
  color: locked ? "#6b7280" : "#1f2937",
  cursor: locked ? "not-allowed" : "auto",
});

const thStyle: React.CSSProperties = {
  padding: "10px 8px", textAlign: "left", fontWeight: 600, color: "#1f2937",
  border: "1px solid #d1d5db", whiteSpace: "nowrap", fontSize: 11,
};
const tdStyle: React.CSSProperties = {
  padding: "6px 8px", border: "1px solid #d1d5db", verticalAlign: "middle",
};
const tblInputStyle: React.CSSProperties = {
  width: "100%", minWidth: 120, padding: "6px 8px", border: "1px solid #d1d5db",
  borderRadius: 4, fontSize: 12, boxSizing: "border-box", fontFamily: "inherit",
};

function btnStyle(variant: "primary" | "secondary"): React.CSSProperties {
  return {
    padding: "10px 16px", border: "none", borderRadius: 6, fontSize: 13, fontWeight: 600, cursor: "pointer",
    background: variant === "primary" ? "#1a84d4" : "#f3f4f6",
    color: variant === "primary" ? "#fff" : "#1f2937",
    transition: "all 0.2s",
  };
}
