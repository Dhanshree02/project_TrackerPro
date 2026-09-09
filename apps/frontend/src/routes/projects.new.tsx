/**
 * /projects/new — Full WBS Form Page (Dhanshree Role Only)
 * Exact layout from wbs-form 2.html, wired to dh-store.
 */
import { createFileRoute, Navigate, useNavigate, useSearch } from "@tanstack/react-router";
import { useEffect, useMemo, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ChevronDown } from "lucide-react";
import { toast } from "sonner";
import { useRoleContext } from "@/lib/role-context";
import { usePermissions } from "@/lib/permissions";
import {
  allClients,
  allProjects,
  dhStore,
  useDhStore,
  buildProjectDisplayId,
  buildWbsId,
} from "@/lib/dh-store";
import { fetchSubVentureSpocs } from "@/lib/sub-venture-spoc";
import { exportWbsWorkbook, type WbsExportInput } from "@/lib/wbs-excel-export";
import { WbsExcelPreviewModal } from "@/components/wbs-excel-preview";
import {
  countProjectsForClient,
  resolveOnboardingProjectName,
} from "@/lib/onboarding-project-name";

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

const DEPT_SERVICES: Record<
  string,
  { id: string; name: string; tool: string; unitPrice: number; days: number }[]
> = {
  "Penetration Testing": [
    {
      id: "PT001",
      name: "External Network Penetration Testing",
      tool: "Nessus, Metasploit",
      unitPrice: 60000,
      days: 5,
    },
    {
      id: "PT002",
      name: "Internal Network Penetration Testing",
      tool: "Burp Suite, Cobalt Strike",
      unitPrice: 75000,
      days: 6,
    },
    {
      id: "PT003",
      name: "Web Application Penetration Testing",
      tool: "Burp Suite, OWASP ZAP",
      unitPrice: 50000,
      days: 5,
    },
    {
      id: "PT004",
      name: "Mobile Application Penetration Testing",
      tool: "Frida, Burp Suite Mobile",
      unitPrice: 55000,
      days: 5,
    },
    {
      id: "PT005",
      name: "API Penetration Testing",
      tool: "Postman, Burp Suite",
      unitPrice: 40000,
      days: 4,
    },
    {
      id: "PT006",
      name: "Thick Client Penetration Testing",
      tool: "Burp Suite, API Fuzzer",
      unitPrice: 45000,
      days: 4,
    },
  ],
  "Vulnerability Assessment": [
    {
      id: "VA001",
      name: "Network Vulnerability Assessment",
      tool: "Nessus, OpenVAS, Qualys",
      unitPrice: 35000,
      days: 3,
    },
    {
      id: "VA002",
      name: "Web Application Vulnerability Assessment",
      tool: "Acunetix, Qualys, Rapid7",
      unitPrice: 40000,
      days: 4,
    },
    {
      id: "VA003",
      name: "Cloud Infrastructure Vulnerability Assessment",
      tool: "Dome9, CloudSploit",
      unitPrice: 50000,
      days: 4,
    },
  ],
  "Red Team & Adversary Simulation": [
    {
      id: "RT001",
      name: "Full Spectrum Red Team Exercise",
      tool: "Cobalt Strike, Metasploit, Mimikatz",
      unitPrice: 120000,
      days: 10,
    },
    {
      id: "RT002",
      name: "Targeted Red Team Engagement",
      tool: "Custom Tools, Cobalt Strike",
      unitPrice: 80000,
      days: 7,
    },
  ],
  "Cloud Security": [
    {
      id: "CS001",
      name: "AWS Security Assessment",
      tool: "Scout2, CloudMapper, AWS Inspector",
      unitPrice: 55000,
      days: 5,
    },
    {
      id: "CS002",
      name: "Azure Security Assessment",
      tool: "Azucar, Microsoft Defender, Qualys",
      unitPrice: 55000,
      days: 5,
    },
    {
      id: "CS003",
      name: "Google Cloud Security Assessment",
      tool: "GCP Security Command Center",
      unitPrice: 50000,
      days: 5,
    },
  ],
  "Code & Application Security": [
    {
      id: "CODE001",
      name: "Source Code Security Review",
      tool: "SonarQube, Checkmarx, Fortify",
      unitPrice: 65000,
      days: 6,
    },
    {
      id: "CODE002",
      name: "Static Application Security Testing (SAST)",
      tool: "Checkmarx, Veracode, Fortify",
      unitPrice: 70000,
      days: 7,
    },
    {
      id: "CODE003",
      name: "Dynamic Application Security Testing (DAST)",
      tool: "Burp Suite, Acunetix, AppScan",
      unitPrice: 60000,
      days: 6,
    },
  ],
  "Compliance & Audit": [
    {
      id: "COMP001",
      name: "ISO 27001 Security Audit",
      tool: "AuditBoard, Drata, Vanta",
      unitPrice: 85000,
      days: 8,
    },
    {
      id: "COMP002",
      name: "GDPR Compliance Assessment",
      tool: "OneTrust, TrustArc, Compliance.ai",
      unitPrice: 75000,
      days: 7,
    },
    {
      id: "COMP003",
      name: "PCI-DSS Compliance Assessment",
      tool: "Qualys, Rapid7, Nessus",
      unitPrice: 80000,
      days: 7,
    },
    {
      id: "COMP004",
      name: "SOC 2 Type II Audit",
      tool: "AuditBoard, Drata",
      unitPrice: 95000,
      days: 10,
    },
  ],
  "Social Engineering & Awareness": [
    {
      id: "SE001",
      name: "Phishing Campaign & Assessment",
      tool: "KnowBe4, Gophish, Phish Alert",
      unitPrice: 30000,
      days: 2,
    },
    {
      id: "SE002",
      name: "Security Awareness Training Program",
      tool: "LinkedIn Learning, KnowBe4, SANS",
      unitPrice: 45000,
      days: 4,
    },
    {
      id: "SE003",
      name: "Vishing & Pretexting Assessment",
      tool: "Custom, KnowBe4",
      unitPrice: 35000,
      days: 3,
    },
  ],
  "Forensics & Incident Response": [
    {
      id: "FOR001",
      name: "Digital Forensics Investigation",
      tool: "EnCase, FTK, Volatility, X-Ways",
      unitPrice: 90000,
      days: 8,
    },
    {
      id: "FOR002",
      name: "Incident Response & Containment",
      tool: "Splunk, ELK, Rapid7 InsightIDR",
      unitPrice: 75000,
      days: 7,
    },
    {
      id: "FOR003",
      name: "Malware Analysis",
      tool: "IDA Pro, Ghidra, Wireshark, Cuckoo",
      unitPrice: 70000,
      days: 6,
    },
  ],
  "Network & Infrastructure": [
    {
      id: "NET001",
      name: "Network Architecture Security Review",
      tool: "Nmap, Wireshark, NETMON",
      unitPrice: 55000,
      days: 5,
    },
    {
      id: "NET002",
      name: "Firewall & IDS/IPS Configuration Audit",
      tool: "Nessus, OpenVAS, Custom Scripts",
      unitPrice: 65000,
      days: 6,
    },
    {
      id: "NET003",
      name: "Network Segmentation Assessment",
      tool: "Nmap, Shodan, Custom Tools",
      unitPrice: 60000,
      days: 5,
    },
  ],
  "Threat Intelligence & Modeling": [
    {
      id: "THREAT001",
      name: "Threat Modeling & Risk Assessment",
      tool: "Microsoft Threat Modeling Tool, IriusRisk",
      unitPrice: 50000,
      days: 4,
    },
    {
      id: "THREAT002",
      name: "Cyber Threat Intelligence Report",
      tool: "MISP, Mandiant, CrowdStrike",
      unitPrice: 40000,
      days: 3,
    },
    {
      id: "THREAT003",
      name: "Attack Surface Analysis",
      tool: "Shodan, Censys, Rapid7 Sonar",
      unitPrice: 45000,
      days: 4,
    },
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
  "Short term (Ad-hoc)": [
    "100% Advance",
    "70% Advance + 30% on Delivery",
    "50% Advance + 50% on Delivery",
    "Custom",
  ],
  "Long Term": ["Monthly Arrears", "Monthly Advance", "Quarterly Arrears", "Quarterly Advance"],
};

const PAYMENT_TERMS_MAP: Record<string, string[]> = {
  "100% Advance": ["100% Before Project Start"],
  "70% Advance + 30% on Delivery": ["70% Advance", "30% on Final Delivery"],
  "50% Advance + 50% on Delivery": ["50% Advance", "50% on Final Delivery"],
  "50% Advance + 25% on Initial Assessment + 25% on Delivery": [
    "50% Advance",
    "25% on Initial Assessment",
    "25% on Final Delivery",
  ],
  "Monthly Arrears": ["End of Each Month"],
  "Monthly Advance": ["Start of Each Month"],
  "Quarterly Arrears": ["End of Each Quarter"],
  "Quarterly Advance": ["Start of Each Quarter"],
  Custom: ["Custom Terms"],
};

const INVOICE_TEMPLATES: Record<string, { milestone: string; pct: number }[]> = {
  "100% Advance": [{ milestone: "Advance 100%", pct: 100 }],
  "70% Advance + 30% on Delivery": [
    { milestone: "Advance 70%", pct: 70 },
    { milestone: "Final Delivery 30%", pct: 30 },
  ],
  "50% Advance + 50% on Delivery": [
    { milestone: "Advance 50%", pct: 50 },
    { milestone: "Final Delivery 50%", pct: 50 },
  ],
  "50% Advance + 25% on Initial Assessment + 25% on Delivery": [
    { milestone: "Advance 50%", pct: 50 },
    { milestone: "Initial Assessment 25%", pct: 25 },
    { milestone: "Final Delivery 25%", pct: 25 },
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
    { milestone: "30% on Delivery", pct: 30 },
  ],
  "50% Advance + 50% on Delivery": [
    { milestone: "50% Advance", pct: 50 },
    { milestone: "50% on Delivery", pct: 50 },
  ],
  "50% Advance + 25% on Initial Assessment + 25% on Delivery": [
    { milestone: "50% Advance", pct: 50 },
    { milestone: "25% on Initial Assessment", pct: 25 },
    { milestone: "25% on Delivery", pct: 25 },
  ],
};

/** Working hours represented by one duration day in the service table. */
const HOURS_PER_DAY = 8;

const RESOURCE_LEVELS = ["L1", "L2", "Senior"] as const;
type ResourceLevelName = (typeof RESOURCE_LEVELS)[number];
type ResourceDist = Record<ResourceLevelName, number>;
const EMPTY_DIST = (): ResourceDist => ({ L1: 0, L2: 0, Senior: 0 });

function distTotal(d: ResourceDist): number {
  return RESOURCE_LEVELS.reduce((sum, level) => sum + (Number(d[level]) || 0), 0);
}

function formatDist(d: ResourceDist): string {
  return RESOURCE_LEVELS.filter((level) => (d[level] || 0) > 0)
    .map((level) => `${level}=${d[level]}`)
    .join(", ");
}

function parseDist(raw: string | undefined): ResourceDist {
  const d = EMPTY_DIST();
  const s = (raw || "").trim();
  if (!s) return d;
  if ((RESOURCE_LEVELS as readonly string[]).includes(s)) {
    d[s as ResourceLevelName] = 1;
    return d;
  }
  for (const part of s.split(",")) {
    const m = part.trim().match(/^(L1|L2|Senior)\s*=\s*(\d+)$/i);
    if (m) d[m[1] as ResourceLevelName] = Number(m[2]);
  }
  return d;
}

/** Trim overflowing counts when Qty is reduced (Senior first, then L2, then L1). */
function clampDist(d: ResourceDist, qty: number): ResourceDist {
  const next = { ...EMPTY_DIST(), ...d };
  let extra = distTotal(next) - Math.max(0, qty);
  if (extra <= 0) return next;
  for (const level of [...RESOURCE_LEVELS].reverse()) {
    if (extra <= 0) break;
    const take = Math.min(next[level], extra);
    next[level] -= take;
    extra -= take;
  }
  return next;
}

function distToResourceLevel(d: ResourceDist, qty: number): string {
  if (qty <= 1) {
    return RESOURCE_LEVELS.find((level) => d[level] > 0) || "";
  }
  return formatDist(d);
}

const CURRENCY_SYMBOLS: Record<string, string> = {
  INR: "₹",
  USD: "$",
  EUR: "€",
  GBP: "£",
  AED: "د.إ",
  SGD: "S$",
  AUD: "A$",
  JPY: "¥",
  CAD: "C$",
  CHF: "Fr",
};

function currencyDisplay(code: string): string {
  const symbol = CURRENCY_SYMBOLS[code];
  return symbol ? `(${code}) ${symbol}` : code;
}

// ─── Types ──────────────────────────────────────────────────────────────────

interface ServiceRow {
  rowId: string;
  taskId: string;
  dept: string;
  name: string;
  qty: number;
  description: string;
  resourceLevel: string; // compact: "L1" when qty=1, "L1=2, L2=1" when qty>1
  resourceDist: ResourceDist; // requirement counts — not employee assignment
  frequency: string;
  location: string; // Delivery Model — dropdown (Onsite/Offsite/Hybrid)
  locationText: string; // Project Side — free text
  serviceModel: string;
  deliveryModel: string; // preserved for WBS record
  billingModel: string; // preserved for WBS record
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
  const { hasPermission } = usePermissions();
  const navigate = useNavigate();
  const extraCount = useDhStore((s) => s.extraClients.length + s.extraProjects.length);
  const clients = allClients();

  if (!isDhanshree && !hasPermission("projects.create")) return <Navigate to="/" />;

  // ── Working-day helpers (Mon–Fri only; Saturday and Sunday never count) ──
  function parseIsoDate(iso: string): Date | null {
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(iso);
    if (!m) return null;
    return new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]));
  }
  function formatIsoDate(d: Date): string {
    const y = d.getFullYear();
    const mo = String(d.getMonth() + 1).padStart(2, "0");
    const dd = String(d.getDate()).padStart(2, "0");
    return `${y}-${mo}-${dd}`;
  }
  function isWeekend(d: Date): boolean {
    const dow = d.getDay();
    return dow === 0 || dow === 6;
  }
  /** Inclusive working-day span: start Monday + 5 days → that Friday. */
  function addWorkingDays(startIso: string, days: number): string {
    const start = parseIsoDate(startIso);
    if (!start || days <= 0) return startIso || "";
    const d = new Date(start.getTime());
    let counted = 0;
    for (let i = 0; i < 3660; i++) {
      if (!isWeekend(d)) {
        counted++;
        if (counted >= days) return formatIsoDate(d);
      }
      d.setDate(d.getDate() + 1);
    }
    return formatIsoDate(d);
  }
  /** Weekdays from start through end, inclusive. Weekends are skipped. */
  function countWorkingDays(startIso: string, endIso: string): number {
    const start = parseIsoDate(startIso);
    const end = parseIsoDate(endIso);
    if (!start || !end || end < start) return 0;
    let count = 0;
    const d = new Date(start.getTime());
    while (d <= end) {
      if (!isWeekend(d)) count++;
      d.setDate(d.getDate() + 1);
    }
    return count;
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
  function computeEndDate(row: {
    startDate: string;
    frequency: string;
    durationDays: number;
  }): string {
    if (!row.startDate) return "";
    if (row.frequency === "Half yearly") return addCalendarMonths(row.startDate, 6);
    if (row.frequency === "Yearly") return addCalendarMonths(row.startDate, 12);
    if (row.durationDays > 0) return addWorkingDays(row.startDate, row.durationDays);
    return "";
  }

  function applyDurationDays<
    T extends {
      qty: number;
      durationDays: number;
      durationHrs: number;
      totalDays: number;
      totalHrs: number;
    },
  >(row: T, days: number): T {
    const d = Math.max(0, Number(days) || 0);
    row.durationDays = d;
    row.durationHrs = d * HOURS_PER_DAY;
    row.totalDays = Number(row.qty) * d;
    row.totalHrs = Number(row.qty) * row.durationHrs;
    return row;
  }

  const todayIso = new Date().toISOString().slice(0, 10);

  // ── Header fields ──
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
  const [renewalProject, setRenewalProject] = useState<ReturnType<typeof allProjects>[0] | null>(
    null,
  );

  const allProjectsList = allProjects();
  const filteredByWbs = allProjectsList.filter(
    (p) =>
      p.wbsId &&
      (wbsSearch.trim() === "" ||
        p.wbsId.toLowerCase().includes(wbsSearch.toLowerCase()) ||
        p.name.toLowerCase().includes(wbsSearch.toLowerCase())),
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
  const filteredSubVentures = clientSubVentures.filter(
    (sv) => svSearch.trim() === "" || sv.name.toLowerCase().includes(svSearch.toLowerCase()),
  );

  // Filtered client list for the combobox
  const filteredClients = clients.filter(
    (c) =>
      clientSearch.trim() === "" ||
      c.name.toLowerCase().includes(clientSearch.toLowerCase()) ||
      c.industry.toLowerCase().includes(clientSearch.toLowerCase()),
  );

  // WBS ID — recomputed from selected client + current FY + next project seq
  const wbsId = selectedClientId ? buildWbsId(selectedClientId) : "—";

  // ── Service picker ──
  const [pickerOpen, setPickerOpen] = useState(false);
  const [pickerDept, setPickerDept] = useState(Object.keys(DEPT_SERVICES)[0]);
  const [pickerSearch, setPickerSearch] = useState("");
  const [tempSelected, setTempSelected] = useState<Record<string, Record<string, boolean>>>({});
  const [selectedServices, setSelectedServices] = useState<Record<string, Record<string, boolean>>>(
    {},
  );
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

  // ── Export WBS ──
  const [exporting, setExporting] = useState(false);
  const [previewOpen, setPreviewOpen] = useState(false);
  const [previewInput, setPreviewInput] = useState<WbsExportInput | null>(null);
  const [downloading, setDownloading] = useState(false);

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
    if (snap.selectedClientId) setSelectedClientId(snap.selectedClientId);
    if (snap.selectedSubVenture) setSelectedSubVenture(snap.selectedSubVenture);
    if (snap.contractType) setContractType(snap.contractType);
    if (snap.engagementManager) setEngagementManager(snap.engagementManager);
    if (snap.salesPerson) setSalesPerson(snap.salesPerson);
    if (snap.projectType) setProjectType(snap.projectType);
    if (snap.billingModel) setBillingModel(snap.billingModel);
    if (snap.paymentTerms) setPaymentTerms(snap.paymentTerms);
    setCurrency("INR");
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
        if (snap.projectType === "Short term (Ad-hoc)") {
          updated.frequency = "Once";
        }
        return updated;
      });
      setServiceRows(sanitizedRows);
    }
    if (snap.invoiceRows?.length) {
      setInvoiceRows(
        snap.invoiceRows.map((inv: any) => ({
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
        })),
      );
    }
    // also restore client search display
    const restoredClient = clients.find((c) => c.id === snap.selectedClientId);
    if (restoredClient) setClientSearch(restoredClient.name);
    if (snap.selectedSubVenture) setSvSearch(snap.selectedSubVenture);
    toast.success("Draft loaded", { description: `"${draft.projectName || "Draft"}" restored.` });
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

  const renewalFieldsLocked = isRenewal && !!renewalProject;

  const projectName = useMemo(
    () =>
      resolveOnboardingProjectName({
        isRenewal: renewalFieldsLocked,
        previousProjectName: renewalProject?.name,
        clientName: selectedClient?.name ?? "",
        subVentureName: selectedSubVenture,
        serviceNames: serviceRows.map((r) => r.name),
        existingClientProjectCount: countProjectsForClient(allProjects(), selectedClientId),
      }),
    [
      renewalFieldsLocked,
      renewalProject?.name,
      selectedClient?.name,
      selectedSubVenture,
      serviceRows,
      selectedClientId,
      extraCount,
    ],
  );

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
          if (projectType === "Short term (Ad-hoc)" && updatedExisting.frequency !== "Once") {
            updatedExisting.frequency = "Once";
            updatedExisting.endDate = computeEndDate(updatedExisting);
          }
          rows.push(updatedExisting);
        } else {
          const isResource = DEPT_GROUPS[dept] === "Resource";
          const newRow = {
            rowId: svcId,
            taskId: `WBS-${String(rowNum + 1).padStart(2, "0")}`,
            dept,
            name: svc.name,
            qty: 1,
            description: "",
            resourceLevel: "",
            resourceDist: EMPTY_DIST(),
            frequency: projectType === "Short term (Ad-hoc)" ? "Once" : "",
            location: "",
            locationText: "",
            serviceModel: isResource ? "NA" : "",
            deliveryModel: "Remote",
            billingModel: "",
            deliveryFormat: "",
            tools: svc.tool,
            startDate: todayIso,
            endDate: "",
            durationDays: svc.days,
            durationHrs: svc.days * HOURS_PER_DAY,
            totalDays: svc.days,
            totalHrs: svc.days * HOURS_PER_DAY,
            unitPrice: svc.unitPrice,
            total: svc.unitPrice,
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
        if (field === "endDate") {
          applyDurationDays(updated, countWorkingDays(updated.startDate, String(value)));
        } else if (field === "durationDays") {
          applyDurationDays(updated, Number(value));
          if (updated.startDate && updated.durationDays > 0) {
            updated.endDate = addWorkingDays(updated.startDate, updated.durationDays);
          }
        } else if (field === "qty") {
          const qty = Math.max(1, Number(updated.qty) || 1);
          updated.qty = qty;
          updated.resourceDist = clampDist(updated.resourceDist || EMPTY_DIST(), qty);
          updated.resourceLevel = distToResourceLevel(updated.resourceDist, qty);
          updated.totalDays = Number(updated.qty) * Number(updated.durationDays);
          updated.totalHrs = Number(updated.qty) * Number(updated.durationHrs);
        } else if (field === "durationHrs") {
          updated.totalHrs = Number(updated.qty) * Number(updated.durationHrs);
        }
        // Start / frequency keep duration and move the end date (working days, or months for yearly)
        if (field === "startDate" || field === "frequency") {
          const newEnd = computeEndDate(updated);
          if (newEnd) updated.endDate = newEnd;
        }
        return updated;
      }),
    );
  }

  // Validate all service rows — returns first error message or null
  function validateServiceRows(): string | null {
    for (let i = 0; i < serviceRows.length; i++) {
      const r = serviceRows[i];
      const n = i + 1;
      if (!r.taskId.trim()) return `Row ${n}: Service ID is required`;
      if (!r.name.trim()) return `Row ${n}: Service Name is required`;
      if (r.qty <= 1) {
        if (!r.resourceLevel) return `Row ${n}: Resource Level is required`;
      } else if (distTotal(r.resourceDist || EMPTY_DIST()) !== Number(r.qty)) {
        const assigned = distTotal(r.resourceDist || EMPTY_DIST());
        return `Row ${n}: Resource Level distribution must equal Qty (${assigned}/${r.qty})`;
      }
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
  function updateInvoiceRowField<K extends keyof InvoiceRow>(
    rowId: string,
    field: K,
    value: InvoiceRow[K],
  ) {
    setInvoiceRows((prev) =>
      prev.map((r) => {
        if (r.rowId !== rowId) return r;
        return { ...r, [field]: value };
      }),
    );
  }

  // Hook to dynamically regenerate Invoice Rows based on WBS and Billing Model configuration
  const servicesDependency = JSON.stringify(
    serviceRows.map((r) => ({
      id: r.rowId,
      name: r.name,
      qty: r.qty,
      unitPrice: r.unitPrice,
      frequency: r.frequency,
    })),
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
    const getOrCreateRow = (
      serviceId: string,
      serviceName: string,
      milestone: string,
      unitPrice: number,
      qty: number,
      currency: string,
      calculatedAmount: number,
    ): InvoiceRow => {
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
          nextRows.push(
            getOrCreateRow(s.rowId, s.name, m.milestone, s.unitPrice, s.qty, currency, amount),
          );
        });
      });
    } else if (billingModel === "Custom") {
      serviceRows.forEach((s) => {
        const ordinals = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth"];
        customPayments.forEach((cp, idx) => {
          const baseLabel = cp.label.trim() || `${ordinals[idx] ?? `Payment ${idx + 1}`} Payment`;
          const milestone = `${baseLabel} (${Number(cp.pct) || 0}%)`;
          const amount = Math.round((s.unitPrice * s.qty * (Number(cp.pct) || 0)) / 100);
          nextRows.push(
            getOrCreateRow(s.rowId, s.name, milestone, s.unitPrice, s.qty, currency, amount),
          );
        });
      });
    } else if (billingModel === "Monthly Arrears" || billingModel === "Monthly Advance") {
      serviceRows.forEach((s) => {
        const periods = getMonthlyPeriods(s.frequency);
        for (let m = 1; m <= periods; m++) {
          const amount = Math.round((s.unitPrice * s.qty) / periods);
          nextRows.push(
            getOrCreateRow(s.rowId, s.name, `Month ${m}`, s.unitPrice, s.qty, currency, amount),
          );
        }
      });
    } else if (billingModel === "Quarterly Arrears" || billingModel === "Quarterly Advance") {
      serviceRows.forEach((s) => {
        const periods = getQuarterlyPeriods(s.frequency);
        for (let q = 1; q <= periods; q++) {
          const amount = Math.round((s.unitPrice * s.qty) / periods);
          nextRows.push(
            getOrCreateRow(s.rowId, s.name, `Quarter ${q}`, s.unitPrice, s.qty, currency, amount),
          );
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

  const deptsByGroup = allowedDepts.reduce(
    (acc, dept) => {
      const group = DEPT_GROUPS[dept] || "Scope";
      if (!acc[group]) acc[group] = [];
      acc[group].push(dept);
      return acc;
    },
    {} as Record<string, string[]>,
  );

  // ─── Picker count helper ─────────────────────────────────────────────────

  const pickerTotalSelected = Object.values(tempSelected).reduce(
    (sum, dept) => sum + Object.keys(dept).length,
    0,
  );

  const filteredPickerServices = (DEPT_SERVICES[pickerDept] || []).filter((s) =>
    s.name.toLowerCase().includes(pickerSearch.toLowerCase()),
  );

  // ─── Form actions ────────────────────────────────────────────────────────

  function buildWbsDetails() {
    return {
      contractType,
      projectType,
      salesPerson,
      engagementManager,
      currency,
      taxPercent,
      services: serviceRows.map((r) => ({
        id: r.rowId,
        department: r.dept,
        serviceName: r.name,
        qty: r.qty,
        description: r.description,
        resourceLevel: r.resourceLevel,
        resourceDist: r.resourceDist,
        frequency: r.frequency,
        location: r.location,
        locationText: r.locationText,
        serviceModel: r.serviceModel,
        deliveryModel: r.deliveryModel,
        // propagate the Section B billing model to every service row
        billingModel: billingModel || r.billingModel,
        finalDeliveryFormat: r.deliveryFormat,
        tools: r.tools,
        startDate: r.startDate,
        endDate: r.endDate,
        duration: r.durationDays,
        unitPrice: r.unitPrice,
        total: r.total,
        totalDays: r.totalDays,
        totalHrs: r.totalHrs,
      })),
      accounts: {
        poStatus,
        poNumber,
        poDate,
        billingModel,
        paymentTerms,
        targetDate,
        contactName,
        contactNumber,
        contactEmail,
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
    if (!projectName.trim()) {
      toast.error("Project Name is generated after customer, sub-venture, and services are selected");
      return;
    }
    if (!selectedClientId) {
      toast.error("Please select a customer");
      return;
    }
    const clientName = clients.find((c) => c.id === selectedClientId)?.name ?? selectedClientId;
    dhStore.saveDraft({
      projectName,
      clientId: selectedClientId,
      clientName,
      salesPerson,
      savedBy: "Dhanshree",
      savedAt: new Date().toISOString(),
      formSnapshot: {
        projectName,
        selectedClientId,
        selectedSubVenture,
        contractType,
        engagementManager,
        salesPerson,
        projectType,
        projectIssuedDate,
        billingModel,
        paymentTerms,
        currency,
        taxPercent,
        poStatus,
        poNumber,
        poDate,
        targetDate,
        contactName,
        contactNumber,
        contactEmail,
        sectionAComments,
        sectionBComments,
        serviceRows,
        invoiceRows,
      },
    });
    toast.success("Draft saved", { description: `"${projectName}" saved to your drafts.` });
  }

  function clearForm() {
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
    if (isRenewal && !renewalProject) {
      toast.error("Please select an existing project to renew");
      return;
    }
    if (!selectedClientId) {
      toast.error("Please select a customer");
      return;
    }
    if (!selectedSubVenture.trim()) {
      toast.error("Please select End Customer / Sub-venture");
      return;
    }
    if (serviceRows.length === 0) {
      toast.error("Please add at least one service");
      return;
    }
    if (!projectName.trim()) {
      toast.error(
        isRenewal
          ? "Selected project has no Project Name"
          : "Project Name is generated after customer, sub-venture, and services are selected",
      );
      return;
    }
    if (billingModel === "Custom") {
      const total = customPayments.reduce((s, p) => s + (Number(p.pct) || 0), 0);
      if (total !== 100) {
        toast.error(`Custom payment terms must total 100% (currently ${total}%)`);
        return;
      }
      // Serialize custom payments into paymentTerms string
      const serialized = customPayments
        .map((p, i) => `${p.pct}% ${p.label || `Payment ${i + 1}`}`)
        .join(" + ");
      setPaymentTerms(serialized);
    }
    const err = validateServiceRows();
    if (err) {
      toast.error(err);
      return;
    }

    // Derive project start/end from the service rows (earliest start → latest end)
    const allStarts = serviceRows
      .map((r) => r.startDate)
      .filter(Boolean)
      .sort();
    const allEnds = serviceRows
      .map((r) => r.endDate)
      .filter(Boolean)
      .sort();
    const projStart = allStarts[0] ?? new Date().toISOString().slice(0, 10);
    const projEnd =
      allEnds[allEnds.length - 1] ??
      new Date(Date.now() + 86400000 * 90).toISOString().slice(0, 10);

    const proj = dhStore.addProject({
      name: projectName,
      clientId: selectedClientId,
      description: sectionAComments,
      startDate: projStart,
      endDate: projEnd,
      budget: subtotal,
      wbsStatus: "assigned",
      wbsSubStatus: "WBS Assigned",
      engagementManager,
      salesPerson,
      contractType,
      projectType,
      projectIssuedDate,
      currency,
      taxPercent,
      totalHours,
      totalDays,
      invoiceValue: invoiceTarget,
      sectionAComments,
      sectionBComments,
      wbsDetails: buildWbsDetails(),
      subVenture: selectedSubVenture,
      renewedFromWbsId: isRenewal ? renewalProject?.wbsId : undefined,
    });
    toast.success("WBS created successfully");
    navigate({ to: "/projects/$projectId", params: { projectId: proj.id } });
  }

  /**
   * Same required fields as the onboarding form. Used by Export WBS so a missing
   * value is named in the error toast instead of producing an incomplete workbook.
   */
  function validateForWbsExport(): string | null {
    if (isRenewal && !renewalProject) return "Please select an existing project to renew";
    if (!selectedClientId) return "Please select TK Customer / Partner Name";
    if (!selectedSubVenture.trim()) return "Please select End Customer / Sub-venture";
    if (!contractType) return "Please select Contract Type";
    if (!salesPerson) return "Please select Sales Person";
    if (!projectType) return "Please select Project Type";
    if (serviceRows.length === 0) return "Please add at least one service";
    if (!projectName.trim()) {
      return "Project Name is generated after customer, sub-venture, and services are selected";
    }
    const rowErr = validateServiceRows();
    if (rowErr) return rowErr;
    if (!billingModel) return "Please select Billing Model";
    if (billingModel === "Custom") {
      const total = customPayments.reduce((s, p) => s + (Number(p.pct) || 0), 0);
      if (total !== 100) {
        return `Custom payment terms must total 100% (currently ${total}%)`;
      }
    }
    if (!poStatus) return "Please select PO Status";
    return null;
  }

  function collectWbsExportInput(spocs: Awaited<ReturnType<typeof fetchSubVentureSpocs>>): WbsExportInput {
    const departments = Array.from(new Set(serviceRows.map((r) => r.dept).filter(Boolean)));
    const environments = Array.from(
      new Set(serviceRows.map((r) => r.locationText.trim()).filter(Boolean)),
    );
    const paymentTermsValue =
      billingModel === "Custom"
        ? customPayments
            .map((p, i) => `${p.pct}% ${p.label || `Payment ${i + 1}`}`)
            .join(" + ")
        : paymentTerms;

    return {
      projectName,
      projectId,
      wbsId,
      wbsDate: projectIssuedDate,
      customerName: selectedClient?.name ?? "",
      subVentureName: selectedSubVenture,
      department: departments.join(", "),
      totalActivities: serviceRows.length,
      uatProductionEnv: environments.join(", ") || "NA",
      spocs,
      services: serviceRows.map((r) => ({
        serviceId: r.taskId,
        serviceName: r.name,
        qty: r.qty,
        resourceLevel: r.resourceLevel,
        description: r.description,
        frequency: r.frequency,
        location:
          r.location === "Onsite" && r.locationText.trim()
            ? `${r.location} — ${r.locationText.trim()}`
            : r.location,
        serviceModel: r.serviceModel,
        projectType,
        tools: r.tools,
        fileFormat: r.deliveryFormat,
        startDate: r.startDate,
        endDate: r.endDate,
        totalDays: r.totalDays,
      })),
      specialNote: sectionAComments,
      accounts: {
        billingModel,
        paymentTerms: paymentTermsValue,
        currency,
        currencySymbol: sym,
        poStatus,
        poNumber,
        poDate,
        targetDate,
        comments: sectionBComments,
      },
      invoices: invoiceRows.map((inv) => ({
        serviceName: inv.serviceName,
        milestone: inv.milestone,
        targetDate: inv.targetDate,
        unitPrice: inv.unitPrice,
        qty: inv.qty,
        currency: inv.currency,
        amount: inv.amount,
        invoiceStatus: inv.invoiceStatus,
        invoiceNumber: inv.invoiceNumber,
        paymentStatus: inv.paymentStatus,
        paymentDate: inv.paymentDate,
      })),
    };
  }

  /**
   * Validates the form, then opens a two-sheet preview. The Excel file is only
   * written to the Downloads folder after the user confirms Download Excel.
   */
  async function handleExport() {
    const err = validateForWbsExport();
    if (err) {
      toast.error(err);
      return;
    }

    setExporting(true);
    try {
      const spocs = await fetchSubVentureSpocs(selectedClientId, selectedSubVenture);
      if (spocs.length === 0) {
        toast.warning("No SPOC on this sub-venture", {
          description: "The WBS sheet will show “—” for Name / Contact No / Email ID.",
        });
      }
      setPreviewInput(collectWbsExportInput(spocs));
      setPreviewOpen(true);
    } catch (e) {
      console.error("WBS preview failed", e);
      toast.error("Could not prepare the WBS preview", {
        description: e instanceof Error ? e.message : "Try again.",
      });
    } finally {
      setExporting(false);
    }
  }

  async function handleDownloadFromPreview() {
    if (!previewInput) return;
    setDownloading(true);
    try {
      const fileName = await exportWbsWorkbook(previewInput);
      toast.success("Excel saved to Downloads", {
        description: `${fileName} is in your PC’s Downloads folder.`,
      });
    } catch (err) {
      console.error("Export WBS failed", err);
      toast.error("Download failed", {
        description: err instanceof Error ? err.message : "Could not save the WBS workbook.",
      });
    } finally {
      setDownloading(false);
    }
  }

  // ─── Render ──────────────────────────────────────────────────────────────

  return (
    <div
      style={{
        fontFamily: "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif",
        background: "#f9fafb",
        color: "#1f2937",
        minHeight: "100vh",
      }}
    >
      {/* ── Navbar ── */}
      <nav
        style={{
          background: "#1a5490",
          color: "#fff",
          padding: "12px 20px",
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          boxShadow: "0 2px 4px rgba(0,0,0,0.1)",
          position: "sticky",
          top: 0,
          zIndex: 100,
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 20, flex: 1 }}>
          <h1 style={{ fontSize: 16, fontWeight: 700 }}>WBS Management System</h1>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 12, fontSize: 13 }}>
          <span>Dhanshree</span>
          <span
            style={{
              background: "rgba(255,255,255,0.2)",
              padding: "4px 8px",
              borderRadius: 4,
              fontSize: 11,
              fontWeight: 600,
            }}
          >
            Sales
          </span>
          <button
            onClick={() => navigate({ to: "/projects" })}
            style={{
              background: "rgba(255,255,255,0.15)",
              color: "#fff",
              border: "1px solid rgba(255,255,255,0.3)",
              padding: "6px 12px",
              borderRadius: 4,
              cursor: "pointer",
              fontSize: 12,
            }}
          >
            ← Back to Projects
          </button>
        </div>
      </nav>

      {/* ── Content ── */}
      <div style={{ maxWidth: 1400, margin: "0 auto", padding: 20 }}>
        {/* Breadcrumb */}
        <div style={{ fontSize: 12, color: "#6b7280", marginBottom: 12 }}>
          <span
            onClick={() => navigate({ to: "/projects" })}
            style={{ color: "#1a84d4", cursor: "pointer", textDecoration: "none" }}
          >
            Projects
          </span>
          {" › "}Create WBS
        </div>

        {/* ── Renewal Checkbox + WBS ID Search ── */}
        <div
          style={{
            background: "#fff",
            border: "1px solid #d1d5db",
            borderRadius: 8,
            padding: "12px 16px",
            marginBottom: 16,
            display: "flex",
            alignItems: "flex-start",
            gap: 16,
            flexWrap: "wrap",
            boxShadow: "0 1px 3px rgba(0,0,0,0.04)",
          }}
        >
          {/* Checkbox */}
          <label
            style={{
              display: "flex",
              alignItems: "center",
              gap: 8,
              cursor: "pointer",
              userSelect: "none",
              fontSize: 13,
              fontWeight: 600,
              color: "#1f2937",
              flexShrink: 0,
              marginTop: 6,
            }}
          >
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
              <div
                style={{
                  fontSize: 11,
                  fontWeight: 600,
                  color: "#6b7280",
                  marginBottom: 4,
                  textTransform: "uppercase",
                  letterSpacing: "0.05em",
                }}
              >
                Search by WBS ID or Project Name
              </div>
              <div style={{ position: "relative" }}>
                <span
                  style={{
                    position: "absolute",
                    left: 10,
                    top: "50%",
                    transform: "translateY(-50%)",
                    color: "#9ca3af",
                    fontSize: 14,
                  }}
                >
                  🔍
                </span>
                <input
                  type="text"
                  value={wbsSearch}
                  placeholder="e.g. IN-2025-26-C001-P001 or project name…"
                  onFocus={() => setWbsDropOpen(true)}
                  onChange={(e) => {
                    setWbsSearch(e.target.value);
                    setWbsDropOpen(true);
                    setRenewalProject(null);
                  }}
                  onBlur={() => setTimeout(() => setWbsDropOpen(false), 150)}
                  style={{
                    ...inputStyle(false),
                    paddingLeft: 32,
                    paddingRight: renewalProject ? 28 : 12,
                  }}
                />
                {renewalProject && (
                  <span
                    onMouseDown={(e) => {
                      e.preventDefault();
                      clearForm();
                    }}
                    style={{
                      position: "absolute",
                      right: 8,
                      top: "50%",
                      transform: "translateY(-50%)",
                      color: "#9ca3af",
                      cursor: "pointer",
                      fontSize: 16,
                      lineHeight: 1,
                    }}
                  >
                    ×
                  </span>
                )}
                {wbsDropOpen && isRenewal && (
                  <div
                    style={{
                      position: "absolute",
                      top: "calc(100% + 4px)",
                      left: 0,
                      right: 0,
                      background: "#fff",
                      border: "1px solid #d1d5db",
                      borderRadius: 6,
                      boxShadow: "0 4px 16px rgba(0,0,0,0.12)",
                      zIndex: 300,
                      maxHeight: 260,
                      overflowY: "auto",
                    }}
                  >
                    {filteredByWbs.length === 0 ? (
                      <div style={{ padding: "12px 14px", fontSize: 12, color: "#6b7280" }}>
                        No projects with WBS ID match
                      </div>
                    ) : (
                      filteredByWbs.map((p) => {
                        const pAny = p as any;
                        const c = clients.find((c) => c.id === pAny.clientId);
                        return (
                          <div
                            key={pAny.id}
                            onMouseDown={() => {
                              setRenewalProject(p);
                              setWbsSearch(pAny.wbsId ?? pAny.id);
                              setSelectedClientId(pAny.clientId);
                              setClientSearch(c?.name ?? "");
                              setEngagementManager(
                                pAny.engagementManager ?? c?.engagementManager ?? "",
                              );
                              if (pAny.subVenture) {
                                setSelectedSubVenture(pAny.subVenture);
                                setSvSearch(pAny.subVenture);
                              } else {
                                setSelectedSubVenture("");
                                setSvSearch("");
                              }
                              // Renewal copies only customer, sub-venture, name, and EM.
                              // Do not bring over services, invoices, or other previous WBS fields.
                              setServiceRows([]);
                              setSelectedServices({});
                              setTempSelected({});
                              setInvoiceRows([]);
                              setWbsDropOpen(false);
                            }}
                            style={{
                              padding: "10px 14px",
                              cursor: "pointer",
                              borderBottom: "1px solid #f3f4f6",
                              background:
                                renewalProject?.id === pAny.id ? "#eff6ff" : "transparent",
                            }}
                          >
                            <div
                              style={{
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "space-between",
                                gap: 8,
                              }}
                            >
                              <div style={{ display: "flex", flexDirection: "column", gap: 2 }}>
                                <span style={{ fontSize: 11, color: "#6b7280" }}>
                                  {c?.name}
                                  {pAny.subVenture ? ` · ${pAny.subVenture}` : ""} · {pAny.wbsId}
                                </span>
                              </div>
                              <span
                                style={{
                                  fontSize: 10,
                                  fontWeight: 600,
                                  padding: "2px 8px",
                                  borderRadius: 12,
                                  background: "#dbeafe",
                                  color: "#1e40af",
                                  flexShrink: 0,
                                }}
                              >
                                Renewal
                              </span>
                            </div>
                          </div>
                        );
                      })
                    )}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        {/* ── Client Info Bar ── */}
        <div
          style={{
            background: "#fff",
            border: "1px solid #d1d5db",
            borderRadius: 8,
            padding: 16,
            marginBottom: 20,
            boxShadow: "0 1px 3px rgba(0,0,0,0.05)",
          }}
        >
          <div style={{ display: "flex", alignItems: "flex-start", gap: 16, flexWrap: "wrap" }}>
            {/* Avatar */}
            <div
              style={{
                width: 48,
                height: 48,
                borderRadius: "50%",
                background: selectedClient ? "#1a84d4" : "#d1d5db",
                color: "#fff",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                fontSize: 20,
                fontWeight: 700,
                flexShrink: 0,
                marginTop: 18,
              }}
            >
              {selectedClient?.logo?.charAt(0) || "?"}
            </div>

            {/* Fields */}
            <div style={{ flex: 1, minWidth: 260 }}>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
                {/* ── Client Name combobox ── */}
                <div>
                  <div
                    style={{
                      fontSize: 11,
                      fontWeight: 600,
                      color: "#6b7280",
                      marginBottom: 4,
                      textTransform: "uppercase",
                      letterSpacing: "0.05em",
                    }}
                  >
                    TK Customer / Partner Name <span style={{ color: "#ef4444" }}>*</span>
                  </div>
                  <div style={{ position: "relative" }}>
                    <input
                      type="text"
                      value={clientSearch}
                      placeholder="Search and select a customer…"
                      readOnly={renewalFieldsLocked}
                      onFocus={() => {
                        if (!renewalFieldsLocked) setClientDropOpen(true);
                      }}
                      onChange={(e) => {
                        if (renewalFieldsLocked) return;
                        setClientSearch(e.target.value);
                        setClientDropOpen(true);
                      }}
                      onBlur={() =>
                        setTimeout(() => {
                          setClientDropOpen(false);
                          if (!selectedClientId) setClientSearch("");
                          else
                            setClientSearch(
                              clients.find((c) => c.id === selectedClientId)?.name ?? "",
                            );
                        }, 150)
                      }
                      style={{
                        ...inputStyle(renewalFieldsLocked),
                        paddingRight: selectedClientId && !renewalFieldsLocked ? 48 : 32,
                      }}
                    />
                    {selectedClientId && !renewalFieldsLocked && (
                      <span
                        onMouseDown={() => {
                          setSelectedClientId("");
                          setClientSearch("");
                          setSvSearch("");
                          setSelectedSubVenture("");
                          setEngagementManager("");
                        }}
                        style={{
                          position: "absolute",
                          right: 28,
                          top: "50%",
                          transform: "translateY(-50%)",
                          color: "#9ca3af",
                          cursor: "pointer",
                          fontSize: 14,
                          lineHeight: 1,
                        }}
                        title="Clear customer"
                      >
                        ×
                      </span>
                    )}
                    {!renewalFieldsLocked && (
                    <ChevronDown
                      size={18}
                      strokeWidth={2.5}
                      style={{
                        position: "absolute",
                        right: 8,
                        top: "50%",
                        transform: "translateY(-50%)",
                        color: "#374151",
                        pointerEvents: "none",
                      }}
                    />
                    )}
                    {clientDropOpen && !renewalFieldsLocked && (
                      <div
                        style={{
                          position: "absolute",
                          top: "calc(100% + 4px)",
                          left: 0,
                          right: 0,
                          background: "#fff",
                          border: "1px solid #d1d5db",
                          borderRadius: 6,
                          boxShadow: "0 4px 16px rgba(0,0,0,0.12)",
                          zIndex: 300,
                          maxHeight: 240,
                          overflowY: "auto",
                        }}
                      >
                        {filteredClients.length === 0 ? (
                          <div style={{ padding: "10px 12px", fontSize: 12, color: "#6b7280" }}>
                            No customers match
                          </div>
                        ) : (
                          filteredClients.map((c) => (
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
                                padding: "9px 12px",
                                cursor: "pointer",
                                fontSize: 13,
                                borderBottom: "1px solid #f3f4f6",
                                background: c.id === selectedClientId ? "#eff6ff" : "transparent",
                                display: "flex",
                                alignItems: "center",
                                gap: 10,
                              }}
                            >
                              <span
                                style={{
                                  width: 28,
                                  height: 28,
                                  borderRadius: "50%",
                                  background: "#1a84d4",
                                  color: "#fff",
                                  display: "inline-flex",
                                  alignItems: "center",
                                  justifyContent: "center",
                                  fontSize: 11,
                                  fontWeight: 700,
                                  flexShrink: 0,
                                }}
                              >
                                {c.logo?.charAt(0)}
                              </span>
                              <div style={{ display: "flex", flexDirection: "column", gap: 1 }}>
                                <span style={{ fontWeight: 600, color: "#111827" }}>{c.name}</span>
                                <span style={{ fontSize: 11, color: "#6b7280" }}>
                                  {c.industry} · {c.subVentures?.length ?? 0} sub-ventures
                                </span>
                              </div>
                              {c.id === selectedClientId && (
                                <span
                                  style={{ marginLeft: "auto", color: "#1a84d4", fontSize: 13 }}
                                >
                                  ✓
                                </span>
                              )}
                            </div>
                          ))
                        )}
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
                  <div
                    style={{
                      fontSize: 11,
                      fontWeight: 600,
                      color: "#6b7280",
                      marginBottom: 4,
                      textTransform: "uppercase",
                      letterSpacing: "0.05em",
                    }}
                  >
                    End Customer Name / Sub-venture Name
                  </div>
                  <div style={{ position: "relative" }}>
                    <input
                      type="text"
                      value={svSearch}
                      placeholder={
                        selectedClientId
                          ? `Search sub-venture of ${selectedClient?.name}…`
                          : "Select a client first…"
                      }
                      disabled={!selectedClientId}
                      readOnly={renewalFieldsLocked}
                      onFocus={() => {
                        if (selectedClientId && !renewalFieldsLocked) setSvDropOpen(true);
                      }}
                      onChange={(e) => {
                        if (renewalFieldsLocked) return;
                        setSvSearch(e.target.value);
                        setSvDropOpen(true);
                      }}
                      onBlur={() =>
                        setTimeout(() => {
                          setSvDropOpen(false);
                          if (!selectedSubVenture) setSvSearch("");
                          else setSvSearch(selectedSubVenture);
                        }, 150)
                      }
                      style={{
                        ...inputStyle(!selectedClientId || renewalFieldsLocked),
                        paddingRight: selectedSubVenture && !renewalFieldsLocked ? 48 : 32,
                      }}
                    />
                    {selectedSubVenture && !renewalFieldsLocked && (
                      <span
                        onMouseDown={() => {
                          setSelectedSubVenture("");
                          setSvSearch("");
                        }}
                        style={{
                          position: "absolute",
                          right: 28,
                          top: "50%",
                          transform: "translateY(-50%)",
                          color: "#9ca3af",
                          cursor: "pointer",
                          fontSize: 14,
                          lineHeight: 1,
                        }}
                        title="Clear sub-venture"
                      >
                        ×
                      </span>
                    )}
                    {!renewalFieldsLocked && (
                    <ChevronDown
                      size={18}
                      strokeWidth={2.5}
                      style={{
                        position: "absolute",
                        right: 8,
                        top: "50%",
                        transform: "translateY(-50%)",
                        color: "#374151",
                        pointerEvents: "none",
                      }}
                    />
                    )}
                    {svDropOpen && selectedClientId && !renewalFieldsLocked && (
                      <div
                        style={{
                          position: "absolute",
                          top: "calc(100% + 4px)",
                          left: 0,
                          right: 0,
                          background: "#fff",
                          border: "1px solid #d1d5db",
                          borderRadius: 6,
                          boxShadow: "0 4px 16px rgba(0,0,0,0.12)",
                          zIndex: 300,
                          maxHeight: 220,
                          overflowY: "auto",
                        }}
                      >
                        {filteredSubVentures.length === 0 ? (
                          <div style={{ padding: "10px 12px", fontSize: 12, color: "#6b7280" }}>
                            No sub-ventures match
                          </div>
                        ) : (
                          filteredSubVentures.map((sv) => (
                            <div
                              key={sv.name}
                              onMouseDown={() => {
                                setSelectedSubVenture(sv.name);
                                setSvSearch(sv.name);
                                setSvDropOpen(false);
                              }}
                              style={{
                                padding: "8px 12px",
                                cursor: "pointer",
                                fontSize: 13,
                                borderBottom: "1px solid #f3f4f6",
                                background:
                                  sv.name === selectedSubVenture ? "#eff6ff" : "transparent",
                                display: "flex",
                                alignItems: "center",
                                justifyContent: "space-between",
                              }}
                            >
                              <span style={{ color: "#111827" }}>{sv.name}</span>
                              {sv.name === selectedSubVenture && (
                                <span style={{ color: "#1a84d4", fontSize: 13 }}>✓</span>
                              )}
                            </div>
                          ))
                        )}
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
            <div
              style={{
                display: "flex",
                flexDirection: "column",
                gap: 10,
                fontSize: 13,
                flexShrink: 0,
                alignSelf: "center",
              }}
            >
              <div style={{ display: "flex", gap: 20 }}>
                <div>
                  <div
                    style={{
                      color: "#6b7280",
                      fontSize: 11,
                      fontWeight: 600,
                      textTransform: "uppercase",
                    }}
                  >
                    Customer ID
                  </div>
                  <div style={{ fontWeight: 700, color: "#1a5490", fontSize: 14 }}>
                    {selectedClient
                      ? selectedClient.id.startsWith("C")
                        ? selectedClient.id
                        : "C" +
                          String(clients.findIndex((c) => c.id === selectedClientId) + 1).padStart(
                            3,
                            "0",
                          )
                      : "—"}
                  </div>
                </div>
                <div>
                  <div
                    style={{
                      color: "#6b7280",
                      fontSize: 11,
                      fontWeight: 600,
                      textTransform: "uppercase",
                    }}
                  >
                    Project ID
                  </div>
                  <div style={{ fontWeight: 700, color: "#1a5490", fontSize: 14 }}>
                    {buildProjectDisplayId()}
                  </div>
                </div>
              </div>
              <div>
                <div
                  style={{
                    color: "#6b7280",
                    fontSize: 11,
                    fontWeight: 600,
                    textTransform: "uppercase",
                  }}
                >
                  WBS ID
                </div>
                <div
                  style={{
                    fontWeight: 700,
                    color: "#059669",
                    fontSize: 14,
                    letterSpacing: "0.02em",
                  }}
                >
                  {wbsId}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* ── WBS Header Card ── */}
        <Card title="WBS Information">
          {/* Row 1: Project Name + Engagement Manager */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
              gap: 16,
              marginBottom: 16,
            }}
          >
            <FormGroup label="Project Name" required>
              <input
                type="text"
                value={projectName}
                readOnly
                placeholder={
                  isRenewal
                    ? "Same as the selected project"
                    : "Generated from customer, sub-venture, and services"
                }
                style={inputStyle(true)}
              />
            </FormGroup>
            <FormGroup label="Engagement Manager">
              <input type="text" value={engagementManager} readOnly style={inputStyle(true)} />
            </FormGroup>
          </div>
          {/* Row 2: Contract Type + Sales Person */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
              gap: 16,
              marginBottom: 16,
            }}
          >
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
                style={selectStyle(false)}
              >
                <option value="">Select Contract Type</option>
                <option value="Resource Based">Resource Based</option>
                <option value="Scope Based">Scope Based</option>
              </select>
            </FormGroup>
            <FormGroup label="Sales Person" required>
              <select
                value={salesPerson}
                onChange={(e) => setSalesPerson(e.target.value)}
                style={selectStyle(false)}
              >
                <option value="">Select Sales Person</option>
                <option value="Abhishek Sharma">Abhishek Sharma</option>
                <option value="Pradeep Singh">Pradeep Singh</option>
                <option value="Dhanshree">Dhanshree</option>
              </select>
            </FormGroup>
          </div>
          {/* Row 3: Project Type + Onboarding Date */}
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
              gap: 16,
            }}
          >
            <FormGroup label="Project Type" required>
              <select
                value={projectType}
                disabled={contractType === "Resource Based" || !contractType}
                onChange={(e) => {
                  const val = e.target.value;
                  setProjectType(val);
                  setBillingModel("");
                  setPaymentTerms("");
                  if (val === "Short term (Ad-hoc)") {
                    setServiceRows((prev) =>
                      prev.map((r) => {
                        const updated = { ...r, frequency: "Once" };
                        updated.endDate = computeEndDate(updated);
                        return updated;
                      }),
                    );
                  }
                }}
                style={selectStyle(contractType === "Resource Based" || !contractType)}
                title={!contractType ? "Select a Contract Type first" : ""}
              >
                {!contractType ? (
                  <option value="">Select Contract Type first</option>
                ) : contractType === "Resource Based" ? (
                  <option value="Long Term">Long Term</option>
                ) : (
                  <>
                    <option value="">Select Project Type</option>
                    <option value="Short term (Ad-hoc)">Short term (Ad-hoc)</option>
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
              opacity: contractType ? 1 : 0.6,
            }}
          >
            + Add Services
          </button>

          {/* Service tags */}
          {serviceRows.length > 0 && (
            <div
              style={{
                display: "flex",
                flexWrap: "wrap",
                gap: 8,
                marginBottom: 16,
                padding: 12,
                background: "#f3f4f6",
                borderRadius: 6,
              }}
            >
              {serviceRows.map((r) => (
                <div
                  key={r.rowId}
                  style={{
                    background: "#1a84d4",
                    color: "#fff",
                    padding: "6px 10px",
                    borderRadius: 4,
                    fontSize: 12,
                    display: "flex",
                    alignItems: "center",
                    gap: 6,
                  }}
                >
                  {r.name} ({r.dept})
                  <span
                    onClick={() => removeServiceRow(r.rowId)}
                    style={{ cursor: "pointer", fontWeight: "bold" }}
                  >
                    ×
                  </span>
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
                  <th style={{ ...thStyle, minWidth: 60 }}>Qty</th>
                  <th style={{ ...thStyle, minWidth: 160 }}>Resource Level</th>
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
                  <tr>
                    <td
                      colSpan={20}
                      style={{ ...tdStyle, textAlign: "center", color: "#6b7280", padding: 32 }}
                    >
                      No services added. Click "+ Add Services" to begin.
                    </td>
                  </tr>
                )}
                {serviceRows.map((r) => {
                  // helper: red border on empty required cells
                  const req = (val: string | number) =>
                    !val || (typeof val === "string" && !val.trim())
                      ? { ...tblInputStyle, border: "1.5px solid #ef4444" }
                      : tblInputStyle;
                  const reqSel = (val: string) =>
                    !val ? { ...tblSelectStyle, border: "1.5px solid #ef4444" } : tblSelectStyle;
                  const isOffsite = r.location === "Offsite";
                  return (
                    <tr key={r.rowId}>
                      <td style={tdStyle}>
                        <input
                          type="text"
                          value={r.dept}
                          readOnly
                          style={{ ...tblInputStyle, background: "#f3f4f6", minWidth: 140 }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="text"
                          value={r.taskId}
                          readOnly
                          title="Service ID is set when the service is added"
                          style={{
                            ...tblInputStyle,
                            minWidth: 100,
                            background: "#f3f4f6",
                            color: "#6b7280",
                            cursor: "not-allowed",
                          }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="text"
                          value={r.name}
                          readOnly
                          title="Service Name is set when the service is added"
                          style={{
                            ...tblInputStyle,
                            minWidth: 200,
                            background: "#f3f4f6",
                            color: "#6b7280",
                            cursor: "not-allowed",
                          }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="text"
                          value={r.description}
                          onChange={(e) => updateRow(r.rowId, "description", e.target.value)}
                          style={{ ...tblInputStyle, minWidth: 180 }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="number"
                          value={r.qty}
                          min={1}
                          onChange={(e) => updateRow(r.rowId, "qty", Number(e.target.value))}
                          style={{ ...tblInputStyle, minWidth: 60 }}
                        />
                      </td>
                      <td style={{ ...tdStyle, position: "relative", overflow: "visible" }}>
                        <ResourceLevelCell
                          qty={Number(r.qty) || 1}
                          resourceLevel={r.resourceLevel}
                          resourceDist={r.resourceDist || EMPTY_DIST()}
                          onChange={(level, dist) => {
                            setServiceRows((prev) =>
                              prev.map((row) =>
                                row.rowId === r.rowId
                                  ? { ...row, resourceLevel: level, resourceDist: dist }
                                  : row,
                              ),
                            );
                          }}
                        />
                      </td>
                      <td style={tdStyle}>
                        {projectType === "Short term (Ad-hoc)" ? (
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
                              textAlign: "center",
                            }}
                          />
                        ) : (
                          <select
                            value={r.frequency}
                            onChange={(e) => updateRow(r.rowId, "frequency", e.target.value)}
                            style={{ ...reqSel(r.frequency), minWidth: 120 }}
                          >
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
                              textAlign: "center",
                            }}
                          />
                        ) : (
                          <select
                            value={r.serviceModel}
                            onChange={(e) => updateRow(r.rowId, "serviceModel", e.target.value)}
                            style={{ ...reqSel(r.serviceModel), minWidth: 160 }}
                          >
                            <option value="">— Select —</option>
                            <option value="Initial Test">Initial Test</option>
                            <option value="Initial + 1 Re-test">Initial + 1 Re-test</option>
                            <option value="Initial + 2 Re-test">Initial + 2 Re-test</option>
                            <option value="Initial + 3 Re-test">Initial + 3 Re-test</option>
                          </select>
                        )}
                      </td>
                      <td style={tdStyle}>
                        <select
                          value={r.location}
                          onChange={(e) => {
                            updateRow(r.rowId, "location", e.target.value);
                            // clear locationText when switching away from Onsite
                            if (e.target.value !== "Onsite") updateRow(r.rowId, "locationText", "");
                          }}
                          style={{ ...reqSel(r.location), minWidth: 110 }}
                        >
                          <option value="">— Select —</option>
                          <option>Onsite</option>
                          <option>Offsite</option>
                          <option>Hybrid</option>
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
                              ? !r.locationText.trim()
                                ? { border: "1.5px solid #ef4444" }
                                : {}
                              : { background: "#f3f4f6", color: "#9ca3af", cursor: "not-allowed" }),
                          }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <select
                          value={r.deliveryFormat}
                          onChange={(e) => updateRow(r.rowId, "deliveryFormat", e.target.value)}
                          style={{ ...reqSel(r.deliveryFormat), minWidth: 140 }}
                        >
                          <option value="">— Select —</option>
                          <option value="PDF">PDF</option>
                          <option value="Excel">Excel</option>
                          <option value="Squad 1">Squad 1</option>
                          <option value="Other Toolbase">Other Toolbase</option>
                        </select>
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="text"
                          value={r.tools}
                          onChange={(e) => updateRow(r.rowId, "tools", e.target.value)}
                          style={{ ...req(r.tools), minWidth: 160 }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="date"
                          value={r.startDate}
                          onChange={(e) => updateRow(r.rowId, "startDate", e.target.value)}
                          style={{ ...req(r.startDate), minWidth: 140 }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="date"
                          value={r.endDate}
                          min={r.startDate || undefined}
                          onChange={(e) => updateRow(r.rowId, "endDate", e.target.value)}
                          style={{ ...req(r.endDate), minWidth: 140 }}
                          title="WBS End Date — weekends do not count toward Duration (Days)"
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="number"
                          min={1}
                          value={r.durationDays}
                          onChange={(e) =>
                            updateRow(r.rowId, "durationDays", Number(e.target.value))
                          }
                          style={{ ...req(r.durationDays), minWidth: 80 }}
                          title="Working days Mon–Fri between WBS Start and End"
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="number"
                          value={r.durationHrs}
                          readOnly
                          title={`${HOURS_PER_DAY} hours per duration day`}
                          style={{
                            ...tblInputStyle,
                            minWidth: 80,
                            background: "#f3f4f6",
                            color: "#6b7280",
                            cursor: "not-allowed",
                          }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="number"
                          value={r.totalDays}
                          readOnly
                          title="Qty × Duration (Days)"
                          style={{
                            ...tblInputStyle,
                            minWidth: 80,
                            background: "#f3f4f6",
                            color: "#6b7280",
                            cursor: "not-allowed",
                          }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="number"
                          value={r.totalHrs}
                          readOnly
                          title="Qty × Duration (Hrs)"
                          style={{
                            ...tblInputStyle,
                            minWidth: 80,
                            background: "#f3f4f6",
                            color: "#6b7280",
                            cursor: "not-allowed",
                          }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="number"
                          value={r.unitPrice}
                          min={0}
                          onChange={(e) => updateRow(r.rowId, "unitPrice", Number(e.target.value))}
                          style={{ ...req(r.unitPrice), minWidth: 100 }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <input
                          type="number"
                          value={r.total}
                          readOnly
                          style={{ ...tblInputStyle, background: "#f3f4f6", minWidth: 100 }}
                        />
                      </td>
                      <td style={tdStyle}>
                        <button
                          onClick={() => removeServiceRow(r.rowId)}
                          title="Remove row"
                          style={{
                            background: "#ef4444",
                            color: "#fff",
                            border: "none",
                            padding: "4px 8px",
                            borderRadius: 4,
                            cursor: "pointer",
                            fontSize: 11,
                          }}
                        >
                          ✕
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          {/* Invoice summary bar */}
          {serviceRows.length > 0 && (
            <div
              style={{
                background: "#f0f9ff",
                padding: 12,
                borderRadius: 6,
                marginTop: 16,
                display: "flex",
                justifyContent: "space-around",
                alignItems: "center",
                fontSize: 14,
                flexWrap: "wrap",
                gap: 16,
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 600 }}>Subtotal:</span>
                <span style={{ fontWeight: 600, color: "#1a5490" }}>
                  {sym}
                  {subtotal.toLocaleString()}
                </span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 600 }}>Tax (%):</span>
                <input
                  type="number"
                  value={taxPercent}
                  min={0}
                  max={100}
                  onChange={(e) => setTaxPercent(Number(e.target.value))}
                  style={{ width: 50, padding: 4, border: "1px solid #ccc", borderRadius: 4 }}
                />
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <span style={{ fontWeight: 600 }}>Invoice Target:</span>
                <span style={{ fontWeight: 600, color: "#1a5490" }}>
                  {sym}
                  {invoiceTarget.toLocaleString()}
                </span>
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
            <label style={{ fontWeight: 600, fontSize: 14, display: "block", marginBottom: 12 }}>
              Comments / Notes
            </label>
            <textarea
              value={sectionAComments}
              onChange={(e) => setSectionAComments(e.target.value)}
              placeholder="Add any remarks, scope notes, or delivery instructions..."
              style={{
                width: "100%",
                minHeight: 80,
                padding: 10,
                border: "1px solid #d1d5db",
                borderRadius: 6,
                fontFamily: "inherit",
                resize: "vertical",
                boxSizing: "border-box",
              }}
            />
          </div>
        </Card>

        {/* ── Section B ── */}
        <Card title="Section B: Accounts Team Details">
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
              gap: 16,
              marginBottom: 16,
            }}
          >
            <FormGroup label="Billing Model" required>
              <select
                value={billingModel}
                disabled={!projectType}
                onChange={(e) => onBillingModelChange(e.target.value)}
                style={selectStyle(!projectType)}
                title={!projectType ? "Select a Project Type in WBS Information first" : ""}
              >
                {!projectType ? (
                  <option value="">⚠ Select Project Type first</option>
                ) : (
                  <option value="">Select Billing Model</option>
                )}
                {(BILLING_MODELS[projectType] || []).map((m) => (
                  <option key={m} value={m}>
                    {m}
                  </option>
                ))}
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
                          onChange={(e) =>
                            setCustomPayments((prev) =>
                              prev.map((p, i) => (i === idx ? { ...p, label: e.target.value } : p)),
                            )
                          }
                          style={{ ...inputStyle(false), flex: 1, fontSize: 12 }}
                        />
                        <div
                          style={{ display: "flex", alignItems: "center", gap: 4, flexShrink: 0 }}
                        >
                          <input
                            type="number"
                            value={cp.pct}
                            min={0}
                            max={100}
                            onChange={(e) =>
                              setCustomPayments((prev) =>
                                prev.map((p, i) =>
                                  i === idx ? { ...p, pct: Number(e.target.value) } : p,
                                ),
                              )
                            }
                            className="no-spinner"
                            style={{
                              width: 64,
                              padding: "8px 6px",
                              border: "1px solid #d1d5db",
                              borderRadius: 6,
                              fontSize: 13,
                              textAlign: "right",
                            }}
                          />
                          <span style={{ fontSize: 13, fontWeight: 600, color: "#374151" }}>%</span>
                        </div>
                        {customPayments.length > 1 && (
                          <button
                            type="button"
                            onClick={() =>
                              setCustomPayments((prev) => prev.filter((_, i) => i !== idx))
                            }
                            style={{
                              background: "#fee2e2",
                              border: "1px solid #fca5a5",
                              color: "#dc2626",
                              borderRadius: 4,
                              padding: "4px 8px",
                              cursor: "pointer",
                              fontSize: 12,
                              fontWeight: 700,
                              flexShrink: 0,
                            }}
                            title="Remove payment"
                          >
                            ×
                          </button>
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
                      <div
                        style={{
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "space-between",
                          marginTop: 4,
                        }}
                      >
                        <button
                          type="button"
                          disabled={isFull}
                          onClick={() => {
                            const ordinals = [
                              "First",
                              "Second",
                              "Third",
                              "Fourth",
                              "Fifth",
                              "Sixth",
                            ];
                            const nextIdx = customPayments.length;
                            const label = `${ordinals[nextIdx] ?? `Payment ${nextIdx + 1}`} Payment`;
                            setCustomPayments((prev) => [...prev, { label, pct: 0 }]);
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
                        >
                          + Add Payment
                        </button>
                        <span
                          style={{
                            fontSize: 12,
                            fontWeight: 700,
                            color: isValid ? "#16a34a" : "#dc2626",
                          }}
                        >
                          Total: {total}%{" "}
                          {isValid
                            ? "✓"
                            : `— needs ${100 - total > 0 ? "+" : ""}${100 - total}% more`}
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
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
              gap: 16,
              marginBottom: 16,
            }}
          >
            <FormGroup label="Currency">
              <input
                type="text"
                value={currencyDisplay("INR")}
                readOnly
                style={inputStyle(true)}
              />
            </FormGroup>

            <FormGroup label="PO Status" required>
              <select
                value={poStatus}
                onChange={(e) => {
                  const val = e.target.value;
                  setPoStatus(val);
                  if (val !== "PO Received") setPoFile(null);
                }}
                style={selectStyle(false)}
              >
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
              <label
                style={{
                  fontWeight: 600,
                  fontSize: 14,
                  display: "block",
                  marginBottom: 10,
                  color: "#1a5490",
                }}
              >
                Invoice Scheduling
              </label>
              <div
                style={{
                  overflowX: "auto",
                  maxHeight: "400px",
                  border: "1px solid #e5e7eb",
                  borderRadius: 8,
                  boxShadow: "0 1px 3px rgba(0,0,0,0.02)",
                }}
              >
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
                          <th style={{ ...thStyleOverride, minWidth: 130 }}>
                            Date of Payment Received
                          </th>
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
                          case "#f0f7ff":
                            return "#e7f2ff";
                          case "#f0fdf4":
                            return "#e6faf0";
                          case "#fffbeb":
                            return "#fff9db";
                          case "#fdf2f8":
                            return "#fdf0f7";
                          case "#faf5ff":
                            return "#fbf3ff";
                          default:
                            return "#f9fafb";
                        }
                      };

                      const uniqueServiceIds = Array.from(
                        new Set(invoiceRows.map((r) => r.serviceId)),
                      );
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
                            <td style={{ ...tdStyleOverride, fontWeight: 500, color: "#374151" }}>
                              {inv.serviceName}
                            </td>

                            {/* Milestone / Period */}
                            <td style={tdStyleOverride}>
                              <span
                                style={{
                                  display: "inline-flex",
                                  alignItems: "center",
                                  background: "rgba(255, 255, 255, 0.7)",
                                  border: "1px solid rgba(0, 0, 0, 0.05)",
                                  color: "#374151",
                                  padding: "2px 8px",
                                  borderRadius: 12,
                                  fontSize: 10,
                                  fontWeight: 600,
                                }}
                              >
                                {inv.milestone}
                              </span>
                            </td>

                            {/* Invoice Target Date */}
                            <td style={tdStyleOverride}>
                              <input
                                type="date"
                                value={inv.targetDate}
                                onChange={(e) =>
                                  updateInvoiceRowField(inv.rowId, "targetDate", e.target.value)
                                }
                                style={invInputStyle}
                              />
                            </td>

                            {/* Unit Price */}
                            <td style={{ ...tdStyleOverride, fontWeight: 500 }}>
                              {CURRENCY_SYMBOLS[inv.currency] || ""}
                              {inv.unitPrice.toLocaleString()}
                            </td>

                            {/* Qty */}
                            <td style={tdStyleOverride}>{inv.qty}</td>

                            {/* Currency */}
                            <td style={{ ...tdStyleOverride, fontWeight: 500 }}>
                              {currencyDisplay(inv.currency)}
                            </td>

                            {/* Invoice Amount */}
                            <td style={{ ...tdStyleOverride, fontWeight: 600, color: "#1a5490" }}>
                              {CURRENCY_SYMBOLS[inv.currency] || ""}
                              {inv.amount.toLocaleString()}
                            </td>

                            {/* Invoice Status */}
                            <td style={tdStyleOverride}>
                              <select
                                value={inv.invoiceStatus}
                                onChange={(e) =>
                                  updateInvoiceRowField(inv.rowId, "invoiceStatus", e.target.value)
                                }
                                style={{ ...tblSelectStyle, textAlign: "center", textAlignLast: "center" }}
                              >
                                <option value="Not Raised">Not Raised</option>
                                <option value="Raised">Raised</option>
                              </select>
                            </td>

                            {/* Invoice Number */}
                            <td style={tdStyleOverride}>
                              <code
                                style={{
                                  fontFamily: "monospace",
                                  fontSize: 11,
                                  background: "rgba(255, 255, 255, 0.6)",
                                  padding: "2px 6px",
                                  border: "1px solid rgba(0, 0, 0, 0.08)",
                                  borderRadius: 4,
                                }}
                              >
                                {inv.invoiceNumber}
                              </code>
                            </td>

                            {/* Payment Status */}
                            <td style={tdStyleOverride}>
                              <select
                                value={inv.paymentStatus}
                                onChange={(e) =>
                                  updateInvoiceRowField(inv.rowId, "paymentStatus", e.target.value)
                                }
                                style={{ ...tblSelectStyle, textAlign: "center", textAlignLast: "center" }}
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
                                onChange={(e) =>
                                  updateInvoiceRowField(inv.rowId, "paymentDate", e.target.value)
                                }
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
                  <label
                    style={{
                      ...btnStyle("secondary"),
                      display: "inline-flex",
                      alignItems: "center",
                      gap: 6,
                      cursor: "pointer",
                    }}
                  >
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
                    <button
                      onClick={() => setPoFile(null)}
                      style={{
                        background: "none",
                        border: "none",
                        color: "#ef4444",
                        cursor: "pointer",
                        fontSize: 12,
                        fontWeight: 600,
                      }}
                    >
                      ✕ Remove
                    </button>
                  )}
                </div>
              </FormGroup>
            </div>
          )}

          {/* Comments B */}
          <div style={{ marginTop: 20, paddingTop: 16, borderTop: "1px solid #d1d5db" }}>
            <label style={{ fontWeight: 600, fontSize: 14, display: "block", marginBottom: 12 }}>
              Comments / Notes
            </label>
            <textarea
              value={sectionBComments}
              onChange={(e) => setSectionBComments(e.target.value)}
              placeholder="Add approval remarks, billing notes, or payment instructions..."
              style={{
                width: "100%",
                minHeight: 80,
                padding: 10,
                border: "1px solid #d1d5db",
                borderRadius: 6,
                fontFamily: "inherit",
                resize: "vertical",
                boxSizing: "border-box",
              }}
            />
          </div>
        </Card>

        {/* ── Workflow & Approval ── */}
        <Card title="Workflow & Approval Status">
          <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
            <button onClick={handleSaveDraft} style={btnStyle("primary")}>
              Save Draft
            </button>
            <button
              onClick={handleExport}
              disabled={exporting}
              style={{
                ...btnStyle("secondary"),
                ...(exporting ? { opacity: 0.6, cursor: "not-allowed" } : {}),
              }}
            >
              {exporting ? "Preparing preview…" : "Export WBS"}
            </button>
            <button onClick={handleAssignWbs} style={btnStyle("primary")}>
              Create WBS
            </button>
          </div>
        </Card>
      </div>
      {/* /content-wrapper */}

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
        <svg
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <polyline points="18 15 12 9 6 15" />
        </svg>
      </button>

      {/* ── Service Picker Modal ── */}
      {pickerOpen && (
        <div
          onClick={(e) => {
            if (e.target === e.currentTarget) setPickerOpen(false);
          }}
          style={{
            position: "fixed",
            inset: 0,
            background: "rgba(0,0,0,0.5)",
            zIndex: 1000,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <div
            style={{
              background: "#fff",
              borderRadius: 12,
              boxShadow: "0 20px 25px rgba(0,0,0,0.15)",
              width: "90%",
              maxWidth: 820,
              height: 600,
              maxHeight: "85vh",
              display: "flex",
              flexDirection: "column",
            }}
          >
            <div
              style={{
                padding: 20,
                borderBottom: "1px solid #d1d5db",
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <div style={{ fontSize: 18, fontWeight: 700, color: "#1a5490" }}>Select Services</div>
              <button
                onClick={() => setPickerOpen(false)}
                style={{ background: "none", border: "none", fontSize: 24, cursor: "pointer" }}
              >
                ×
              </button>
            </div>
            <div
              style={{
                flex: 1,
                overflowY: "auto",
                padding: 20,
                display: "grid",
                gridTemplateColumns: "220px 1fr",
                gap: 20,
              }}
            >
              {/* Dept list grouped by Contract Type groups (Resource/Scope) */}
              <div>
                <h4 style={{ marginBottom: 12, fontSize: 13, fontWeight: 700 }}>Departments</h4>
                <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
                  {Object.entries(deptsByGroup).map(([groupName, depts]) => (
                    <div key={groupName}>
                      <div
                        style={{
                          fontSize: 11,
                          fontWeight: 700,
                          color: "#6b7280",
                          textTransform: "uppercase",
                          letterSpacing: "0.05em",
                          marginBottom: 8,
                          borderBottom: "1px solid #e5e7eb",
                          paddingBottom: 4,
                        }}
                      >
                        {groupName} Group
                      </div>
                      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                        {depts.map((dept) => (
                          <div
                            key={dept}
                            onClick={() => setPickerDept(dept)}
                            style={{
                              padding: 10,
                              border: "1px solid #d1d5db",
                              borderRadius: 6,
                              cursor: "pointer",
                              display: "flex",
                              justifyContent: "space-between",
                              alignItems: "center",
                              background: dept === pickerDept ? "#dbeafe" : "#fff",
                              borderColor: dept === pickerDept ? "#1a84d4" : "#d1d5db",
                            }}
                          >
                            <span style={{ fontWeight: 600, fontSize: 12 }}>{dept}</span>
                            <span
                              style={{
                                background: "#1a84d4",
                                color: "#fff",
                                padding: "2px 6px",
                                borderRadius: 10,
                                fontSize: 10,
                                fontWeight: 600,
                              }}
                            >
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
                <input
                  type="text"
                  placeholder="Search services..."
                  value={pickerSearch}
                  onChange={(e) => setPickerSearch(e.target.value)}
                  style={{
                    width: "100%",
                    padding: 8,
                    border: "1px solid #d1d5db",
                    borderRadius: 6,
                    marginBottom: 12,
                    boxSizing: "border-box",
                  }}
                />
                <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                  {filteredPickerServices.map((svc) => {
                    const checked = !!(
                      tempSelected[pickerDept] && tempSelected[pickerDept][svc.id]
                    );
                    return (
                      <div
                        key={svc.id}
                        style={{
                          padding: 12,
                          border: "1px solid #d1d5db",
                          borderRadius: 6,
                          display: "flex",
                          alignItems: "center",
                          gap: 10,
                        }}
                      >
                        <input
                          type="checkbox"
                          checked={checked}
                          onChange={(e) => {
                            setTempSelected((prev) => {
                              const next = { ...prev };
                              if (!next[pickerDept]) next[pickerDept] = {};
                              if (e.target.checked) {
                                next[pickerDept] = { ...next[pickerDept], [svc.id]: true };
                              } else {
                                const d = { ...next[pickerDept] };
                                delete d[svc.id];
                                next[pickerDept] = d;
                              }
                              return next;
                            });
                          }}
                          style={{ width: 16, height: 16 }}
                        />
                        <div style={{ flex: 1 }}>
                          <div style={{ fontWeight: 600, fontSize: 13 }}>{svc.name}</div>
                          <div style={{ fontSize: 11, color: "#6b7280", marginTop: 2 }}>
                            {svc.tool} • ₹{svc.unitPrice.toLocaleString()} • {svc.days} days
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
            <div
              style={{
                padding: "16px 20px",
                borderTop: "1px solid #d1d5db",
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <span style={{ fontSize: 12, color: "#6b7280" }}>
                Selected: <strong>{pickerTotalSelected}</strong> services
              </span>
              <div style={{ display: "flex", gap: 10 }}>
                <button onClick={() => setPickerOpen(false)} style={btnStyle("secondary")}>
                  Cancel
                </button>
                <button onClick={confirmPicker} style={btnStyle("primary")}>
                  ✓ OK — Add to Table
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
      <WbsExcelPreviewModal
        open={previewOpen}
        input={previewInput}
        downloading={downloading}
        onClose={() => {
          if (downloading) return;
          setPreviewOpen(false);
        }}
        onDownload={() => {
          void handleDownloadFromPreview();
        }}
      />
    </div>
  );
}

// ─── Sub-components ──────────────────────────────────────────────────────────

function Card({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div
      style={{
        background: "#fff",
        border: "1px solid #d1d5db",
        borderRadius: 8,
        padding: 20,
        marginBottom: 20,
        boxShadow: "0 1px 3px rgba(0,0,0,0.05)",
      }}
    >
      <div
        style={{
          fontSize: 16,
          fontWeight: 700,
          color: "#1a5490",
          marginBottom: 16,
          paddingBottom: 12,
          borderBottom: "2px solid #1a84d4",
        }}
      >
        {title}
      </div>
      {children}
    </div>
  );
}

function FormGroup({
  label,
  required,
  locked,
  children,
}: {
  label: string;
  required?: boolean;
  locked?: boolean;
  children: React.ReactNode;
}) {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        gap: 6,
        background: locked ? "#f3f4f6" : "transparent",
        borderRadius: locked ? 6 : 0,
        padding: locked ? "4px 0" : 0,
      }}
    >
      <label style={{ fontSize: 13, fontWeight: 600, color: "#1f2937" }}>
        {label}
        {required && <span style={{ color: "#ef4444" }}> *</span>}
        {locked && <span style={{ fontSize: 12, marginLeft: 4 }}>🔒</span>}
      </label>
      {children}
    </div>
  );
}

// ─── Style helpers ────────────────────────────────────────────────────────────

const inputStyle = (locked: boolean): React.CSSProperties => ({
  padding: "10px 12px",
  border: "1px solid #d1d5db",
  borderRadius: 6,
  fontSize: 13,
  fontFamily: "inherit",
  width: "100%",
  boxSizing: "border-box",
  backgroundColor: locked ? "#f3f4f6" : "#fff",
  color: locked ? "#6b7280" : "#1f2937",
  cursor: locked ? "not-allowed" : "auto",
});

/** Dropdown arrow used on <select> fields so they don't look like plain text inputs. */
const SELECT_CHEVRON = `url("data:image/svg+xml,${encodeURIComponent(
  '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#374151" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"/></svg>',
)}")`;

const selectArrow = (locked: boolean): React.CSSProperties => ({
  paddingRight: 32,
  appearance: "none",
  WebkitAppearance: "none",
  MozAppearance: "none",
  backgroundColor: locked ? "#f3f4f6" : "#fff",
  backgroundImage: SELECT_CHEVRON,
  backgroundRepeat: "no-repeat",
  backgroundPosition: "right 10px center",
  backgroundSize: "16px 16px",
  cursor: locked ? "not-allowed" : "pointer",
});

const selectStyle = (locked: boolean): React.CSSProperties => ({
  ...inputStyle(locked),
  ...selectArrow(locked),
});

const tblInputStyle: React.CSSProperties = {
  width: "100%",
  minWidth: 120,
  padding: "6px 8px",
  border: "1px solid #d1d5db",
  borderRadius: 4,
  fontSize: 12,
  boxSizing: "border-box",
  fontFamily: "inherit",
};

const tblSelectStyle: React.CSSProperties = {
  ...tblInputStyle,
  ...selectArrow(false),
  padding: "6px 28px 6px 8px",
  backgroundPosition: "right 8px center",
  backgroundSize: "14px 14px",
};

const thStyle: React.CSSProperties = {
  padding: "10px 8px",
  textAlign: "left",
  fontWeight: 600,
  color: "#1f2937",
  border: "1px solid #d1d5db",
  whiteSpace: "nowrap",
  fontSize: 11,
};
const tdStyle: React.CSSProperties = {
  padding: "6px 8px",
  border: "1px solid #d1d5db",
  verticalAlign: "middle",
};
function btnStyle(variant: "primary" | "secondary"): React.CSSProperties {
  return {
    padding: "10px 16px",
    border: "none",
    borderRadius: 6,
    fontSize: 13,
    fontWeight: 600,
    cursor: "pointer",
    background: variant === "primary" ? "#1a84d4" : "#f3f4f6",
    color: variant === "primary" ? "#fff" : "#1f2937",
    transition: "all 0.2s",
  };
}

function ResourceLevelCell({
  qty,
  resourceLevel,
  resourceDist,
  onChange,
}: {
  qty: number;
  resourceLevel: string;
  resourceDist: ResourceDist;
  onChange: (level: string, dist: ResourceDist) => void;
}) {
  const [open, setOpen] = useState(false);
  const [draft, setDraft] = useState<ResourceDist>(resourceDist);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const popRef = useRef<HTMLDivElement>(null);
  const [pos, setPos] = useState({ top: 0, left: 0 });

  const assigned = distTotal(draft);
  const complete = assigned === qty;
  const committedAssigned = distTotal(resourceDist);
  const invalid = qty <= 1 ? !resourceLevel : committedAssigned !== qty;
  const label =
    qty <= 1
      ? resourceLevel || "— Select —"
      : formatDist(resourceDist) || "— Select —";

  function placePopover() {
    const rect = triggerRef.current?.getBoundingClientRect();
    if (!rect) return;
    const width = 280;
    const left = Math.min(rect.left, window.innerWidth - width - 8);
    setPos({ top: rect.bottom + 4, left: Math.max(8, left) });
  }

  function openPopover() {
    setDraft({ ...EMPTY_DIST(), ...resourceDist });
    placePopover();
    setOpen(true);
  }

  useEffect(() => {
    if (!open) return;
    placePopover();
    const onDoc = (e: MouseEvent) => {
      const t = e.target as Node;
      if (triggerRef.current?.contains(t) || popRef.current?.contains(t)) return;
      setOpen(false);
    };
    const onReposition = () => placePopover();
    document.addEventListener("mousedown", onDoc);
    window.addEventListener("resize", onReposition);
    window.addEventListener("scroll", onReposition, true);
    return () => {
      document.removeEventListener("mousedown", onDoc);
      window.removeEventListener("resize", onReposition);
      window.removeEventListener("scroll", onReposition, true);
    };
  }, [open]);

  function bump(level: ResourceLevelName, delta: number) {
    setDraft((prev) => {
      const next = { ...prev };
      const nextVal = next[level] + delta;
      if (nextVal < 0) return prev;
      if (delta > 0 && distTotal(next) >= qty) return prev;
      next[level] = nextVal;
      return next;
    });
  }

  if (qty <= 1) {
    return (
      <select
        value={RESOURCE_LEVELS.includes(resourceLevel as ResourceLevelName) ? resourceLevel : ""}
        onChange={(e) => {
          const v = e.target.value as ResourceLevelName | "";
          const dist = EMPTY_DIST();
          if (v) dist[v] = 1;
          onChange(v, dist);
        }}
        style={{ ...tblSelectStyle, minWidth: 110, ...(invalid ? { border: "1.5px solid #ef4444" } : {}) }}
      >
        <option value="">— Select —</option>
        {RESOURCE_LEVELS.map((level) => (
          <option key={level} value={level}>
            {level}
          </option>
        ))}
      </select>
    );
  }

  const plusDisabled = assigned >= qty;
  const popover = open
    ? createPortal(
        <div
          ref={popRef}
          style={{
            position: "fixed",
            top: pos.top,
            left: pos.left,
            width: 280,
            background: "#fff",
            border: "1px solid #d1d5db",
            borderRadius: 8,
            boxShadow: "0 8px 24px rgba(0,0,0,0.14)",
            zIndex: 1400,
            padding: 12,
            fontFamily: "inherit",
          }}
        >
          <div style={{ fontSize: 12, fontWeight: 700, color: "#1a5490", marginBottom: 10 }}>
            Resource Level Distribution
          </div>
          {RESOURCE_LEVELS.map((level) => (
            <div
              key={level}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                marginBottom: 8,
                gap: 8,
              }}
            >
              <span style={{ fontSize: 13, fontWeight: 600, color: "#1f2937", width: 64 }}>{level}</span>
              <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <button
                  type="button"
                  disabled={draft[level] <= 0}
                  onClick={() => bump(level, -1)}
                  style={stepperBtnStyle(draft[level] <= 0)}
                  aria-label={`Decrease ${level}`}
                >
                  −
                </button>
                <span
                  style={{
                    minWidth: 22,
                    textAlign: "center",
                    fontSize: 13,
                    fontWeight: 700,
                    color: "#1f2937",
                  }}
                >
                  {draft[level]}
                </span>
                <button
                  type="button"
                  disabled={plusDisabled}
                  onClick={() => bump(level, 1)}
                  style={stepperBtnStyle(plusDisabled)}
                  aria-label={`Increase ${level}`}
                >
                  +
                </button>
              </div>
            </div>
          ))}
          <div
            style={{
              fontSize: 12,
              fontWeight: 600,
              color: complete ? "#059669" : "#dc2626",
              margin: "6px 0 10px",
            }}
          >
            Assigned: {assigned} / {qty}
          </div>
          <div style={{ display: "flex", justifyContent: "flex-end" }}>
            <button
              type="button"
              disabled={!complete}
              onClick={() => {
                onChange(formatDist(draft), draft);
                setOpen(false);
              }}
              style={{
                ...btnStyle("primary"),
                padding: "6px 14px",
                fontSize: 12,
                opacity: complete ? 1 : 0.5,
                cursor: complete ? "pointer" : "not-allowed",
              }}
            >
              OK
            </button>
          </div>
        </div>,
        document.body,
      )
    : null;

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        onClick={() => (open ? setOpen(false) : openPopover())}
        title="Set how many L1 / L2 / Senior resources this service requires"
        style={{
          ...tblSelectStyle,
          minWidth: 160,
          textAlign: "left",
          color: formatDist(resourceDist) ? "#1f2937" : "#9ca3af",
          ...(invalid ? { border: "1.5px solid #ef4444" } : {}),
        }}
      >
        {label}
      </button>
      {popover}
    </>
  );
}

function stepperBtnStyle(disabled: boolean): React.CSSProperties {
  return {
    width: 26,
    height: 26,
    borderRadius: 4,
    border: "1px solid #d1d5db",
    background: disabled ? "#f3f4f6" : "#fff",
    color: disabled ? "#9ca3af" : "#1f2937",
    fontSize: 16,
    fontWeight: 700,
    lineHeight: 1,
    cursor: disabled ? "not-allowed" : "pointer",
    padding: 0,
  };
}
