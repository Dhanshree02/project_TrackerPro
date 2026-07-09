export type Role = "senior_pm" | "engagement_manager" | "pmo" | "hod" | "business_owner" | "dhanshree";

export type ProjectStatus = "ongoing" | "completed" | "on_hold";
export type HealthStatus = "green" | "amber" | "red";
export type TaskStatus = "todo" | "in_progress" | "review" | "done";
export type IssuePriority = "low" | "medium" | "high" | "critical";
export type IssueStatus = "open" | "in_progress" | "resolved" | "closed";
export type IssueType =
  | "scope_change"
  | "resource_shortage"
  | "delay"
  | "escalation"
  | "client_issue"
  | "internal_blocker";
export type IssueRoleTarget = "PM" | "Senior PM" | "EM" | "PMO" | "HOD";
export type TimesheetStatus = "draft" | "submitted" | "approved" | "rejected";

export interface Person {
  id: string;
  name: string;
  role: string;
  avatar: string;
  email: string;
}

export interface Task {
  id: string;
  title: string;
  status: TaskStatus;
  assigneeId: string;
  dueDate: string;
  progress: number;
  // WBS-linked fields (populated when project is created via Assign WBS)
  serviceId?: string;
  wbsStartDate?: string;
  wbsEndDate?: string;
  estimatedHours?: number;
  // PM-editable actuals
  actualStartDate?: string;
  actualEndDate?: string;   // auto-calculated from actualStartDate + estimatedHours (skip weekends)
  utilizedHours?: number;
  stage?: "Not Started" | "Completed" | "On Hold (Internal)" | "On Hold (Client End)" | "After Release";
}

export interface WBSNode {
  id: string;
  name: string;
  progress: number;
  children?: WBSNode[];
}

export interface WbsService {
  id: string;
  department: string;
  serviceName: string;
  qty: number;
  description: string;
  frequency: string;
  location: string;
  locationText?: string;
  serviceModel: string;
  deliveryModel: string;
  finalDeliveryFormat: string;
  billingModel: string;
  tools: string;
  startDate: string;
  endDate: string;
  duration: number;
  totalDays: number;
  totalHrs: number;
  unitPrice: number;
  total: number;
}

export interface WbsInvoice {
  id: string;
  milestone: string;
  amount: number;
  invoiceDate: string;
  remarks: string;
}

export interface WBSDetails {
  contractType: string;
  projectType: string;
  salesPerson: string;
  currency: string;
  services: WbsService[];
  accounts: {
    poStatus: string;
    poNumber?: string;
    poDate?: string;
    billingModel: string;
    paymentTerms: string;
    targetDate?: string;
    contactName?: string;
    contactNumber?: string;
    contactEmail?: string;
    invoices: WbsInvoice[];
  };
}

export type WbsStatus = "draft" | "approval_pending" | "ph_approved" | "accounts_approved" | "approved" | "started" | "assigned";

export interface Project {
  id: string;
  name: string;
  clientId: string;
  status: ProjectStatus;
  health: HealthStatus;
  progress: number;
  pmId: string;
  tlId: string;
  teamIds: string[];
  shadowTeamIds?: string[]; // Dhanshree: backup/support resources
  startDate: string;
  endDate: string;
  budget: number;
  spent: number;
  description: string;
  wbs: WBSNode[];
  wbsDetails?: WBSDetails;
  tasks: Task[];
  // WBS Form extended fields (Dhanshree role)
  wbsStatus?: WbsStatus;
  wbsSubStatus?: string;
  engagementManager?: string;
  salesPerson?: string;
  contractType?: string;
  projectType?: string;
  projectIssuedDate?: string;
  currency?: string;
  taxPercent?: number;
  totalHours?: number;
  totalDays?: number;
  invoiceValue?: number;
  sectionAComments?: string;
  sectionBComments?: string;
  projectSeqId?: string; // FY-scoped sequential ID e.g. "P001" — resets each April 1
  wbsId?: string;        // Full WBS ID e.g. "IN-2026-27-C011-P001"
  subVenture?: string;   // Sub-venture name this project is under
}


export interface Client {
  id: string;
  name: string;
  industry: string;
  logo: string;
  contact: string;
  clientType?: "NEW" | "OLD";
  previousPmIds?: string[];
  engagementManager?: string;
  companyName?: string;
  subVentures?: string[]; // list of sub-ventures / end-customer divisions
}

export interface IssueComment {
  id: string;
  authorId: string;
  text: string;
  createdAt: string;
}

export interface IssueAuditEntry {
  id: string;
  actorId: string;
  action: string;
  at: string;
}

export interface Issue {
  id: string;
  clientId: string;
  projectId: string;
  type: IssueType;
  description: string;
  priority: IssuePriority;
  status: IssueStatus;
  raisedById: string;
  raisedByRole: "TL" | "PM" | "Senior PM" | "EM";
  assignedToId: string;
  assignedToRole: IssueRoleTarget;
  createdAt: string;
  updatedAt: string;
  comments: IssueComment[];
  audit: IssueAuditEntry[];
  resolution?: string;
  taggedUserIds: string[];
}

export interface CellCommentMessage {
  author: string;
  text: string;
  type: "comment" | "response" | "clarification_request";
  createdAt: string; // ISO datetime
}

export interface CellCommentData {
  status: "new" | "viewed" | "clarification_requested";
  history: CellCommentMessage[];
}

export interface TimesheetEntry {
  taskId: string;
  projectId: string;
  hours: number[]; // 7 days, Mon-Sun
  note?: string;
  notes?: string[];
  cellComments?: Record<number, CellCommentData>;
}

export interface Timesheet {
  id: string;
  userId: string;
  userRole: "Employee" | "TL" | "PM" | "Senior PM" | "EM";
  weekStart: string;
  status: TimesheetStatus;
  entries: TimesheetEntry[];
  totalHours: number;
  submittedAt?: string;
  rejectionReason?: string;
}

// ---------- People ----------
export const people: Person[] = [
  { id: "u1", name: "Aarav Mehta", role: "Senior PM", avatar: "AM", email: "aarav@acme.co" },
  { id: "u2", name: "Riya Kapoor", role: "Engagement Manager", avatar: "RK", email: "riya@acme.co" },
  { id: "u3", name: "Vikram Shah", role: "PM", avatar: "VS", email: "vikram@acme.co" },
  { id: "u4", name: "Sana Iyer", role: "PM", avatar: "SI", email: "sana@acme.co" },
  { id: "u5", name: "Nikhil Rao", role: "TL", avatar: "NR", email: "nikhil@acme.co" },
  { id: "u6", name: "Priya Verma", role: "TL", avatar: "PV", email: "priya@acme.co" },
  { id: "u7", name: "Arjun Singh", role: "Engineer", avatar: "AS", email: "arjun@acme.co" },
  { id: "u8", name: "Meera Joshi", role: "Engineer", avatar: "MJ", email: "meera@acme.co" },
  { id: "u9", name: "Dev Patel", role: "Engineer", avatar: "DP", email: "dev@acme.co" },
  { id: "u10", name: "Kavya Nair", role: "Designer", avatar: "KN", email: "kavya@acme.co" },
  { id: "u11", name: "Rahul Gupta", role: "PMO", avatar: "RG", email: "rahul@acme.co" },
  { id: "u12", name: "Anita Desai", role: "HOD", avatar: "AD", email: "anita@acme.co" },
  { id: "u13", name: "Vikrant Malhotra", role: "Business Owner", avatar: "VM", email: "vikrant@acme.co" },
  { id: "u14", name: "Dhanshree", role: "Dhanshree", avatar: "DS", email: "dhanshree@acme.co" },
];

export const getPerson = (id: string) => people.find((p) => p.id === id)!;

// ---------- Clients ----------
export const clients: Client[] = [
  {
    id: "c1", name: "Northwind Bank", industry: "Banking", logo: "NB",
    contact: "ops@northwind.com", clientType: "OLD", previousPmIds: ["u3", "u4"],
    engagementManager: "Rahul Sharma", companyName: "Northwind Financial Services",
    subVentures: ["Northwind Retail Banking", "Northwind Corporate Banking", "Northwind Digital Payments", "Northwind Treasury Services", "Northwind Wealth Management"],
  },
  {
    id: "c2", name: "Helix Pharma", industry: "Healthcare", logo: "HP",
    contact: "it@helix.com", clientType: "OLD", previousPmIds: ["u3", "u4", "u5"],
    engagementManager: "Pradeep Singh", companyName: "Helix Life Sciences",
    subVentures: ["Helix Clinical Research", "Helix Biotech Division", "Helix Manufacturing", "Helix Global Healthcare", "Helix Medical Devices"],
  },
  {
    id: "c3", name: "Orbit Retail", industry: "Retail", logo: "OR",
    contact: "tech@orbit.com", clientType: "OLD", previousPmIds: ["u3"],
    engagementManager: "Riya Kapoor", companyName: "Orbit Commerce Pvt Ltd",
    subVentures: ["Orbit E-Commerce", "Orbit Hypermarket", "Orbit Fashion", "Orbit Supply Chain", "Orbit Digital Commerce"],
  },
  {
    id: "c4", name: "Zenith Logistics", industry: "Logistics", logo: "ZL",
    contact: "pm@zenith.com", clientType: "NEW", previousPmIds: [],
    engagementManager: "Rahul Sharma", companyName: "Zenith Supply Chain",
    subVentures: ["Zenith Freight Services", "Zenith Warehouse Operations", "Zenith International Logistics", "Zenith Fleet Management", "Zenith Express Delivery"],
  },
  {
    id: "c5", name: "Lumen Energy", industry: "Energy", logo: "LE",
    contact: "digital@lumen.com", clientType: "OLD", previousPmIds: ["u4", "u5"],
    engagementManager: "Pradeep Singh", companyName: "Lumen Power Solutions",
    subVentures: ["Lumen Renewable Energy", "Lumen Power Distribution", "Lumen Smart Grid", "Lumen Solar Division", "Lumen Energy Consulting"],
  },
  {
    id: "c6", name: "CloudSync AI", industry: "Technology", logo: "CA",
    contact: "contact@cloudsync.com", clientType: "NEW", previousPmIds: [],
    engagementManager: "Riya Kapoor", companyName: "CloudSync Technologies",
    subVentures: ["CloudSync AI Platform", "CloudSync Cloud Infrastructure", "CloudSync Data Engineering", "CloudSync Machine Learning", "CloudSync Enterprise Solutions"],
  },
  {
    id: "c7", name: "FinTech Global", industry: "Finance", logo: "FG",
    contact: "dev@fintechglobal.com", clientType: "OLD", previousPmIds: ["u3", "u4"],
    engagementManager: "Rahul Sharma", companyName: "FinTech Global Ltd",
    subVentures: ["FinTech Digital Banking", "FinTech Payment Solutions", "FinTech Lending", "FinTech Investment Services", "FinTech Risk & Compliance"],
  },
  {
    id: "c8", name: "MediCare Plus", industry: "Healthcare", logo: "MP",
    contact: "tech@medicareplus.com", clientType: "NEW", previousPmIds: [],
    engagementManager: "Pradeep Singh", companyName: "MediCare Health Solutions",
    subVentures: ["MediCare Hospital Systems", "MediCare Telemedicine", "MediCare Diagnostics", "MediCare Health Analytics", "MediCare Patient Services"],
  },
  {
    id: "c9", name: "EcoGreen Solutions", industry: "Environment", logo: "EG",
    contact: "projects@ecogreen.com", clientType: "OLD", previousPmIds: ["u5"],
    engagementManager: "Riya Kapoor", companyName: "EcoGreen Sustainability",
    subVentures: ["EcoGreen Waste Management", "EcoGreen Sustainability Consulting", "EcoGreen Renewable Projects", "EcoGreen Water Management", "EcoGreen Carbon Solutions"],
  },
  {
    id: "c10", name: "AutoDrive Systems", industry: "Automotive", logo: "AD",
    contact: "engineering@autodrive.com", clientType: "OLD", previousPmIds: ["u3", "u4", "u5"],
    engagementManager: "Rahul Sharma", companyName: "AutoDrive Technologies",
    subVentures: ["AutoDrive Connected Vehicles", "AutoDrive Autonomous Systems", "AutoDrive EV Solutions", "AutoDrive Manufacturing", "AutoDrive Smart Mobility"],
  },
];

// Senior PM (u1) is assigned c1, c2, c3. EM (u2) is assigned c2, c4, c5. PMO (u11) sees everything.
export const assignments: Record<Role, string[]> = {
  senior_pm: ["c1", "c2", "c3"],
  engagement_manager: ["c2", "c4", "c5", "c6"],
  pmo: ["c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10"],
  hod: ["c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10"],
  business_owner: ["c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10"],
  dhanshree: ["c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "c10"],
};

// PM "buckets" — capacity tracking
export const pmBuckets: { pmId: string; capacity: number; allocated: number }[] = [
  { pmId: "u3", capacity: 100, allocated: 92 },
  { pmId: "u4", capacity: 100, allocated: 78 },
];

// On-bench resources
export const benchResourceIds: string[] = ["u9", "u10"];

// Invoice tracking by project
export type InvoiceStatus = "raised" | "pending" | "paid" | "overdue";
export type PaymentStatus = "not_initiated" | "pending" | "completed" | "overdue";
export const invoices: { projectId: string; unitPrice: number; qty: number; currency: string; invoiceAmount: number; status: InvoiceStatus; paymentStatus: PaymentStatus; raisedOn: string; paymentReceivedDate?: string }[] = [
  { projectId: "p1", unitPrice: 80000, qty: 4, currency: "USD", invoiceAmount: 320000, status: "paid", paymentStatus: "completed", raisedOn: "2026-04-02", paymentReceivedDate: "2026-04-15" },
  { projectId: "p1", unitPrice: 60000, qty: 3, currency: "USD", invoiceAmount: 180000, status: "raised", paymentStatus: "pending", raisedOn: "2026-05-02" },
  { projectId: "p2", unitPrice: 40000, qty: 4, currency: "USD", invoiceAmount: 160000, status: "paid", paymentStatus: "completed", raisedOn: "2026-04-10", paymentReceivedDate: "2026-04-20" },
  { projectId: "p3", unitPrice: 60000, qty: 4, currency: "USD", invoiceAmount: 240000, status: "overdue", paymentStatus: "overdue", raisedOn: "2026-03-25" },
  { projectId: "p4", unitPrice: 30000, qty: 3, currency: "USD", invoiceAmount: 90000, status: "pending", paymentStatus: "pending", raisedOn: "2026-05-01" },
  { projectId: "p5", unitPrice: 70000, qty: 3, currency: "USD", invoiceAmount: 210000, status: "raised", paymentStatus: "pending", raisedOn: "2026-04-28" },
  { projectId: "p6", unitPrice: 70000, qty: 4, currency: "USD", invoiceAmount: 280000, status: "paid", paymentStatus: "completed", raisedOn: "2026-03-30", paymentReceivedDate: "2026-04-10" },
  { projectId: "p7", unitPrice: 35000, qty: 4, currency: "USD", invoiceAmount: 140000, status: "pending", paymentStatus: "pending", raisedOn: "2026-05-05" },
  { projectId: "p8", unitPrice: 62000, qty: 5, currency: "USD", invoiceAmount: 310000, status: "raised", paymentStatus: "pending", raisedOn: "2026-04-22" },
  { projectId: "p9", unitPrice: 52000, qty: 5, currency: "USD", invoiceAmount: 260000, status: "raised", paymentStatus: "pending", raisedOn: "2026-04-30" },
  { projectId: "p10", unitPrice: 70000, qty: 4, currency: "USD", invoiceAmount: 280000, status: "paid", paymentStatus: "completed", raisedOn: "2026-04-15", paymentReceivedDate: "2026-04-25" },
  { projectId: "p10", unitPrice: 67000, qty: 5, currency: "USD", invoiceAmount: 335000, status: "pending", paymentStatus: "pending", raisedOn: "2026-05-10" },
  { projectId: "p11", unitPrice: 50000, qty: 4, currency: "USD", invoiceAmount: 200000, status: "paid", paymentStatus: "completed", raisedOn: "2026-04-05", paymentReceivedDate: "2026-04-18" },
  { projectId: "p11", unitPrice: 45000, qty: 4, currency: "USD", invoiceAmount: 180000, status: "raised", paymentStatus: "pending", raisedOn: "2026-05-08" },
  { projectId: "p12", unitPrice: 70000, qty: 5, currency: "USD", invoiceAmount: 350000, status: "pending", paymentStatus: "pending", raisedOn: "2026-04-18" },
  { projectId: "p13", unitPrice: 60000, qty: 4, currency: "USD", invoiceAmount: 240000, status: "paid", paymentStatus: "completed", raisedOn: "2026-04-25", paymentReceivedDate: "2026-05-05" },
  { projectId: "p13", unitPrice: 43000, qty: 5, currency: "USD", invoiceAmount: 215000, status: "raised", paymentStatus: "pending", raisedOn: "2026-05-12" },
  { projectId: "p14", unitPrice: 76000, qty: 5, currency: "USD", invoiceAmount: 380000, status: "raised", paymentStatus: "pending", raisedOn: "2026-04-20" },
];

// Allocation history — ownership/assignment changes maintained by PMO
export interface AllocationEvent {
  id: string;
  projectId: string;
  action: string; // e.g. "Assigned PM", "Reassigned Senior PM"
  actorId: string; // PMO who did it
  fromId?: string;
  toId: string;
  at: string;
}
export const allocationHistory: AllocationEvent[] = [
  { id: "al1", projectId: "p1", action: "Assigned Senior PM", actorId: "u11", toId: "u1", at: "2026-02-01T10:00:00Z" },
  { id: "al2", projectId: "p1", action: "Assigned Project Manager", actorId: "u11", toId: "u3", at: "2026-02-01T10:05:00Z" },
  { id: "al3", projectId: "p3", action: "Assigned Engagement Manager", actorId: "u11", toId: "u2", at: "2026-03-01T09:00:00Z" },
  { id: "al4", projectId: "p7", action: "Reassigned Project Manager", actorId: "u11", fromId: "u4", toId: "u3", at: "2026-04-12T14:30:00Z" },
];

// ---------- Projects ----------
// Helper to add N working days to a YYYY-MM-DD string
function addWd(iso: string, days: number): string {
  const d = new Date(iso);
  let r = days;
  while (r > 0) { d.setDate(d.getDate() + 1); if (d.getDay() !== 0 && d.getDay() !== 6) r--; }
  return d.toISOString().slice(0, 10);
}

// Sub-venture map: projectId → sub-venture name (randomly pre-assigned from client sub-ventures)
const PROJECT_SUBVENTURES: Record<string, string> = {
  p1: "Northwind Retail Banking", p2: "Northwind Digital Payments",
  p3: "Helix Clinical Research", p4: "Helix Biotech Division",
  p5: "Orbit E-Commerce", p6: "Orbit Hypermarket",
  p7: "Zenith Freight Services", p8: "Zenith Warehouse Operations",
  p9: "Lumen Smart Grid", p10: "CloudSync AI Platform",
  p11: "FinTech Digital Banking", p12: "MediCare Hospital Systems",
  p13: "EcoGreen Sustainability Consulting", p14: "AutoDrive Autonomous Systems",
  p15: "Northwind Corporate Banking", p16: "Northwind Treasury Services",
  p17: "Northwind Wealth Management", p18: "Northwind Financial Services",
  p19: "Helix Manufacturing", p20: "Helix Global Healthcare",
  p21: "Helix Medical Devices", p22: "Orbit Fashion",
  p23: "Orbit Supply Chain", p24: "Orbit Digital Commerce",
  p25: "Zenith International Logistics", p26: "Zenith Fleet Management",
  p27: "Lumen Renewable Energy", p28: "Lumen Power Distribution",
  p29: "Lumen Solar Division", p30: "CloudSync Data Engineering",
  p31: "CloudSync Machine Learning", p32: "FinTech Payment Solutions",
  p33: "FinTech Risk & Compliance", p34: "FinTech Lending",
  p35: "MediCare Telemedicine", p36: "MediCare Diagnostics",
  p37: "MediCare Patient Services", p38: "EcoGreen Waste Management",
  p39: "EcoGreen Renewable Projects", p40: "EcoGreen Water Management",
  p41: "AutoDrive Connected Vehicles", p42: "AutoDrive EV Solutions",
  p43: "AutoDrive Manufacturing",
};

const SERVICE_IDS = ["PT001", "PT002", "VA001", "CS001", "CODE001", "COMP001", "SE001", "FOR001", "NET001", "THREAT001", "RT001", "PT003"];
const STAGES: Array<Task["stage"]> = ["Not Started", "Completed", "On Hold (Internal)", "Not Started", "Completed", "After Release"];

const mkTasks = (prefix: string, assignees: string[]): Task[] => {
  const base = "2026-04-01";
  return [
    { id: `${prefix}-t1`, title: "External Network Penetration Testing", status: "done", assigneeId: assignees[0], dueDate: "2026-04-12", progress: 100, serviceId: SERVICE_IDS[0], wbsStartDate: base, wbsEndDate: addWd(base, 5), estimatedHours: 40, stage: "Completed" },
    { id: `${prefix}-t2`, title: "Web Application Penetration Testing", status: "done", assigneeId: assignees[1] ?? assignees[0], dueDate: "2026-04-22", progress: 100, serviceId: SERVICE_IDS[2], wbsStartDate: addWd(base, 6), wbsEndDate: addWd(base, 10), estimatedHours: 32, stage: "Completed" },
    { id: `${prefix}-t3`, title: "Cloud Infrastructure Assessment", status: "in_progress", assigneeId: assignees[2] ?? assignees[0], dueDate: "2026-05-18", progress: 65, serviceId: SERVICE_IDS[3], wbsStartDate: addWd(base, 11), wbsEndDate: addWd(base, 16), estimatedHours: 40, stage: "Not Started" },
    { id: `${prefix}-t4`, title: "Source Code Security Review", status: "in_progress", assigneeId: assignees[1] ?? assignees[0], dueDate: "2026-05-22", progress: 40, serviceId: SERVICE_IDS[4], wbsStartDate: addWd(base, 17), wbsEndDate: addWd(base, 24), estimatedHours: 48, stage: "Not Started" },
    { id: `${prefix}-t5`, title: "ISO 27001 Security Audit", status: "review", assigneeId: assignees[0], dueDate: "2026-06-04", progress: 20, serviceId: SERVICE_IDS[5], wbsStartDate: addWd(base, 25), wbsEndDate: addWd(base, 35), estimatedHours: 64, stage: "On Hold (Internal)" },
    { id: `${prefix}-t6`, title: "Phishing Campaign & Assessment", status: "todo", assigneeId: assignees[2] ?? assignees[0], dueDate: "2026-06-12", progress: 0, serviceId: SERVICE_IDS[6], wbsStartDate: addWd(base, 36), wbsEndDate: addWd(base, 38), estimatedHours: 16, stage: "Not Started" },
  ];
};

const mkWbs = (): WBSNode[] => [
  {
    id: "w1", name: "1. Discovery", progress: 100,
    children: [
      { id: "w1.1", name: "1.1 Stakeholder interviews", progress: 100 },
      { id: "w1.2", name: "1.2 Requirements doc", progress: 100 },
    ],
  },
  {
    id: "w2", name: "2. Design", progress: 80,
    children: [
      { id: "w2.1", name: "2.1 Architecture", progress: 100 },
      { id: "w2.2", name: "2.2 UI mockups", progress: 60 },
    ],
  },
  {
    id: "w3", name: "3. Build", progress: 50,
    children: [
      { id: "w3.1", name: "3.1 Backend APIs", progress: 65 },
      { id: "w3.2", name: "3.2 Frontend", progress: 40 },
    ],
  },
  { id: "w4", name: "4. Launch", progress: 10 },
];

export const projects: Project[] = [
  {
    id: "p1", name: "Core Banking Modernization", clientId: "c1", wbsId: "IN-2025-26-C001-P006",
    subVenture: PROJECT_SUBVENTURES["p1"],
    status: "ongoing", health: "amber", progress: 62,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u8", "u10"], shadowTeamIds: ["u9"],
    startDate: "2026-02-01", endDate: "2026-08-30",
    budget: 1200000, spent: 740000,
    description: "Modernize legacy core banking platform to a cloud-native microservices stack.",
    wbs: mkWbs(), tasks: mkTasks("p1", ["u5", "u7", "u8"]),
  },
  {
    id: "p2", name: "Mobile Banking App v3", clientId: "c1", wbsId: "IN-2025-26-C001-P002",
    status: "ongoing", health: "green", progress: 78,
    pmId: "u3", tlId: "u6", teamIds: ["u9", "u10"],
    startDate: "2026-01-15", endDate: "2026-06-30",
    budget: 480000, spent: 360000,
    description: "Next-gen mobile app with biometric auth and real-time payments.",
    wbs: mkWbs(), tasks: mkTasks("p2", ["u6", "u9", "u10"]),
  },
  {
    id: "p3", name: "Clinical Data Platform", clientId: "c2", wbsId: "IN-2025-26-C002-P011",
    status: "ongoing", health: "red", progress: 35,
    pmId: "u4", tlId: "u5", teamIds: ["u7", "u8", "u9"], shadowTeamIds: ["u6", "u10"],
    startDate: "2026-03-01", endDate: "2026-09-15",
    budget: 950000, spent: 410000,
    description: "Unified clinical trials data platform with HIPAA compliance.",
    wbs: mkWbs(), tasks: mkTasks("p3", ["u5", "u7", "u8"]),
  },
  {
    id: "p4", name: "Pharma Sales Dashboard", clientId: "c2", wbsId: "IN-2025-26-C002-P008",
    status: "on_hold", health: "amber", progress: 45,
    pmId: "u4", tlId: "u6", teamIds: ["u8", "u10"],
    startDate: "2026-02-10", endDate: "2026-07-20",
    budget: 320000, spent: 180000,
    description: "Sales analytics dashboard with territory performance views.",
    wbs: mkWbs(), tasks: mkTasks("p4", ["u6", "u8", "u10"]),
  },
  {
    id: "p5", name: "Omnichannel Commerce", clientId: "c3", wbsId: "IN-2025-26-C003-P004",
    status: "ongoing", health: "green", progress: 58,
    pmId: "u3", tlId: "u6", teamIds: ["u7", "u9", "u10"], shadowTeamIds: ["u5"],
    startDate: "2026-01-20", endDate: "2026-08-10",
    budget: 760000, spent: 420000,
    description: "Unified storefront across web, mobile and in-store kiosks.",
    wbs: mkWbs(), tasks: mkTasks("p5", ["u6", "u7", "u9"]),
  },
  {
    id: "p6", name: "POS Migration", clientId: "c3", wbsId: "IN-2024-25-C003-P002",
    status: "completed", health: "green", progress: 100,
    pmId: "u4", tlId: "u5", teamIds: ["u8", "u9"],
    startDate: "2025-09-01", endDate: "2026-03-30",
    budget: 280000, spent: 265000,
    description: "Migrated 1,200 POS terminals to new cloud-managed platform.",
    wbs: mkWbs(), tasks: mkTasks("p6", ["u5", "u8", "u9"]),
  },
  {
    id: "p7", name: "Fleet Tracking System", clientId: "c4", wbsId: "IN-2025-26-C004-P009",
    status: "ongoing", health: "amber", progress: 48,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u9"],
    startDate: "2026-02-15", endDate: "2026-09-01",
    budget: 540000, spent: 280000,
    description: "Real-time GPS tracking and route optimization for 5,000 vehicles.",
    wbs: mkWbs(), tasks: mkTasks("p7", ["u5", "u7", "u9"]),
  },
  {
    id: "p8", name: "Warehouse Automation", clientId: "c4", wbsId: "IN-2025-26-C004-P001",
    status: "ongoing", health: "green", progress: 70,
    pmId: "u4", tlId: "u6", teamIds: ["u8", "u10"],
    startDate: "2026-01-05", endDate: "2026-07-15",
    budget: 890000, spent: 600000,
    description: "Robotics + WMS integration across 4 distribution centers.",
    wbs: mkWbs(), tasks: mkTasks("p8", ["u6", "u8", "u10"]),
  },
  {
    id: "p9", name: "Smart Grid Analytics", clientId: "c5", wbsId: "IN-2025-26-C005-P010",
    status: "ongoing", health: "amber", progress: 55,
    pmId: "u3", tlId: "u6", teamIds: ["u7", "u8", "u9"],
    startDate: "2026-02-20", endDate: "2026-10-10",
    budget: 1050000, spent: 510000,
    description: "Predictive load balancing and outage detection across the grid.",
    wbs: mkWbs(), tasks: mkTasks("p9", ["u6", "u7", "u8"]),
  },
  {
    id: "p10", name: "AI-Powered Analytics Platform", clientId: "c6", wbsId: "IN-2025-26-C006-P012",
    status: "ongoing", health: "green", progress: 82,
    pmId: "u3", tlId: "u5", teamIds: ["u5", "u7", "u8"],
    startDate: "2026-03-01", endDate: "2026-08-30",
    budget: 750000, spent: 615000,
    description: "Machine learning pipeline for real-time data analytics and insights.",
    wbs: mkWbs(), tasks: mkTasks("p10", ["u5", "u7", "u8"]),
  },
  {
    id: "p11", name: "Digital Wallet MVP", clientId: "c7", wbsId: "IN-2025-26-C007-P003",
    status: "ongoing", health: "green", progress: 65,
    pmId: "u4", tlId: "u6", teamIds: ["u6", "u9", "u10"],
    startDate: "2026-01-15", endDate: "2026-06-20",
    budget: 580000, spent: 377000,
    description: "Mobile-first digital payment wallet with blockchain security.",
    wbs: mkWbs(), tasks: mkTasks("p11", ["u6", "u9", "u10"]),
  },
  {
    id: "p12", name: "Hospital Management System", clientId: "c8", wbsId: "IN-2025-26-C008-P007",
    status: "ongoing", health: "amber", progress: 48,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u8", "u9"],
    startDate: "2026-02-10", endDate: "2026-09-25",
    budget: 920000, spent: 441600,
    description: "Comprehensive EHR and patient management system for 50+ hospitals.",
    wbs: mkWbs(), tasks: mkTasks("p12", ["u7", "u8", "u9"]),
  },
  {
    id: "p13", name: "Carbon Tracking Platform", clientId: "c9", wbsId: "IN-2025-26-C009-P005",
    status: "ongoing", health: "green", progress: 71,
    pmId: "u4", tlId: "u6", teamIds: ["u5", "u8", "u10"],
    startDate: "2026-01-20", endDate: "2026-07-31",
    budget: 640000, spent: 454400,
    description: "Enterprise platform for monitoring and reducing carbon footprint.",
    wbs: mkWbs(), tasks: mkTasks("p13", ["u5", "u8", "u10"]),
  },
  {
    id: "p14", name: "Autonomous Vehicle Control", clientId: "c10", wbsId: "IN-2025-26-C010-P013",
    status: "ongoing", health: "red", progress: 38,
    pmId: "u3", tlId: "u5", teamIds: ["u6", "u7", "u9"],
    startDate: "2026-03-10", endDate: "2026-11-15",
    budget: 1200000, spent: 456000,
    description: "Advanced control system for autonomous vehicle fleet management.",
    wbs: mkWbs(), tasks: mkTasks("p14", ["u6", "u7", "u9"]),
  },

  // ── C1: Northwind Bank — extra projects ──
  {
    id: "p15", name: "Internet Banking Portal", clientId: "c1", wbsId: "IN-2024-25-C001-P003",
    status: "completed", health: "green", progress: 100,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u8"],
    startDate: "2024-06-01", endDate: "2025-01-15",
    budget: 520000, spent: 510000,
    description: "Full-featured internet banking portal with 2FA and real-time notifications.",
    wbs: mkWbs(), tasks: mkTasks("p15", ["u6", "u7", "u8"]),
  },
  {
    id: "p16", name: "Fraud Detection ML Model", clientId: "c1", wbsId: "IN-2023-24-C001-P006",
    status: "completed", health: "green", progress: 100,
    pmId: "u3", tlId: "u5", teamIds: ["u8", "u9"],
    startDate: "2024-02-01", endDate: "2024-10-30",
    budget: 680000, spent: 665000,
    description: "Machine learning pipeline for real-time transaction fraud detection.",
    wbs: mkWbs(), tasks: mkTasks("p16", ["u5", "u8", "u9"]),
  },
  {
    id: "p17", name: "API Gateway Revamp", clientId: "c1", wbsId: "IN-2026-27-C001-P001",
    status: "ongoing", health: "green", progress: 0,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u10"],
    startDate: "2026-06-01", endDate: "2026-12-31",
    budget: 390000, spent: 0,
    description: "Rebuild API gateway with rate limiting, OAuth 2.0 and developer portal.",
    wbs: mkWbs(), tasks: mkTasks("p17", ["u5", "u7", "u10"]),
  },
  {
    id: "p18", name: "Loan Origination System", clientId: "c1", wbsId: "IN-2023-24-C001-P005",
    status: "completed", health: "amber", progress: 72,
    pmId: "u4", tlId: "u6", teamIds: ["u8", "u9"],
    startDate: "2023-09-01", endDate: "2024-04-30",
    budget: 450000, spent: 420000,
    description: "End-to-end digital loan origination and approval workflow system.",
    wbs: mkWbs(), tasks: mkTasks("p18", ["u6", "u8", "u9"]),
  },

  // ── C2: Helix Pharma — extra projects ──
  {
    id: "p19", name: "Lab Information System", clientId: "c2", wbsId: "IN-2023-24-C002-P007",
    status: "completed", health: "green", progress: 100,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u8", "u10"],
    startDate: "2024-01-10", endDate: "2024-09-20",
    budget: 610000, spent: 590000,
    description: "Digital laboratory information system for sample tracking and reporting.",
    wbs: mkWbs(), tasks: mkTasks("p19", ["u5", "u7", "u8"]),
  },
  {
    id: "p20", name: "Regulatory Compliance Portal", clientId: "c2", wbsId: "IN-2026-27-C002-P002",
    status: "ongoing", health: "green", progress: 0,
    pmId: "u4", tlId: "u6", teamIds: ["u9", "u10"],
    startDate: "2026-06-10", endDate: "2026-12-20",
    budget: 280000, spent: 0,
    description: "Centralized portal for managing FDA/EMA regulatory submissions.",
    wbs: mkWbs(), tasks: mkTasks("p20", ["u6", "u9", "u10"]),
  },
  {
    id: "p21", name: "Drug Trial Management", clientId: "c2", wbsId: "IN-2023-24-C002-P002",
    status: "completed", health: "amber", progress: 68,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u9"],
    startDate: "2023-05-01", endDate: "2024-01-31",
    budget: 730000, spent: 690000,
    description: "Phase II/III clinical trial participant management and data collection.",
    wbs: mkWbs(), tasks: mkTasks("p21", ["u5", "u7", "u9"]),
  },

  // ── C3: Orbit Retail — extra projects ──
  {
    id: "p22", name: "Loyalty Rewards Platform", clientId: "c3", wbsId: "IN-2023-24-C003-P008",
    status: "completed", health: "green", progress: 100,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u8"],
    startDate: "2024-03-01", endDate: "2024-11-30",
    budget: 340000, spent: 330000,
    description: "Points-based loyalty engine with gamification for 5M+ customers.",
    wbs: mkWbs(), tasks: mkTasks("p22", ["u6", "u7", "u8"]),
  },
  {
    id: "p23", name: "Inventory AI Forecasting", clientId: "c3",
    status: "ongoing", health: "green", progress: 0,
    pmId: "u3", tlId: "u5", teamIds: ["u8", "u10"],
    startDate: "2026-06-05", endDate: "2026-11-30",
    budget: 420000, spent: 0,
    description: "AI-driven demand forecasting and automated replenishment system.",
    wbs: mkWbs(), tasks: mkTasks("p23", ["u5", "u8", "u10"]),
  },
  {
    id: "p24", name: "Customer Data Platform", clientId: "c3",
    status: "completed", health: "amber", progress: 55,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u9"],
    startDate: "2023-01-15", endDate: "2023-09-30",
    budget: 490000, spent: 460000,
    description: "Unified customer data platform integrating 12 data sources.",
    wbs: mkWbs(), tasks: mkTasks("p24", ["u6", "u7", "u9"]),
  },

  // ── C4: Zenith Logistics — extra projects ──
  {
    id: "p25", name: "Supply Chain Visibility", clientId: "c4",
    status: "completed", health: "green", progress: 100,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u8", "u9"],
    startDate: "2024-04-01", endDate: "2024-12-15",
    budget: 570000, spent: 555000,
    description: "End-to-end supply chain visibility platform with IoT sensor integration.",
    wbs: mkWbs(), tasks: mkTasks("p25", ["u5", "u7", "u8"]),
  },
  {
    id: "p26", name: "Driver Mobile App", clientId: "c4",
    status: "ongoing", health: "green", progress: 0,
    pmId: "u4", tlId: "u6", teamIds: ["u9", "u10"],
    startDate: "2026-06-15", endDate: "2026-11-20",
    budget: 220000, spent: 0,
    description: "Driver-facing mobile app for route optimization and POD collection.",
    wbs: mkWbs(), tasks: mkTasks("p26", ["u6", "u9", "u10"]),
  },

  // ── C5: Lumen Energy — extra projects ──
  {
    id: "p27", name: "Renewable Energy Dashboard", clientId: "c5",
    status: "completed", health: "green", progress: 100,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u8"],
    startDate: "2024-02-01", endDate: "2024-10-31",
    budget: 460000, spent: 445000,
    description: "Executive dashboard for real-time monitoring of solar and wind assets.",
    wbs: mkWbs(), tasks: mkTasks("p27", ["u6", "u7", "u8"]),
  },
  {
    id: "p28", name: "Customer Energy Portal", clientId: "c5",
    status: "ongoing", health: "green", progress: 0,
    pmId: "u3", tlId: "u5", teamIds: ["u8", "u9"],
    startDate: "2026-06-08", endDate: "2026-12-15",
    budget: 310000, spent: 0,
    description: "Self-service portal for residential customers to track usage and billing.",
    wbs: mkWbs(), tasks: mkTasks("p28", ["u5", "u8", "u9"]),
  },
  {
    id: "p29", name: "Grid Modernization Program", clientId: "c5",
    status: "completed", health: "amber", progress: 61,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u10"],
    startDate: "2023-06-01", endDate: "2024-03-31",
    budget: 870000, spent: 840000,
    description: "Phase 1 smart meter rollout across 3 states.",
    wbs: mkWbs(), tasks: mkTasks("p29", ["u6", "u7", "u10"]),
  },

  // ── C6: CloudSync AI — extra projects ──
  {
    id: "p30", name: "Data Lakehouse Migration", clientId: "c6",
    status: "ongoing", health: "green", progress: 0,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u8", "u10"],
    startDate: "2026-06-01", endDate: "2026-11-30",
    budget: 490000, spent: 0,
    description: "Migrate 3PB data warehouse to modern lakehouse architecture on Snowflake.",
    wbs: mkWbs(), tasks: mkTasks("p30", ["u5", "u7", "u8"]),
  },
  {
    id: "p31", name: "MLOps Framework", clientId: "c6",
    status: "completed", health: "green", progress: 100,
    pmId: "u4", tlId: "u6", teamIds: ["u8", "u9"],
    startDate: "2024-03-15", endDate: "2024-11-30",
    budget: 380000, spent: 365000,
    description: "Production ML model lifecycle management with drift detection and retraining.",
    wbs: mkWbs(), tasks: mkTasks("p31", ["u6", "u8", "u9"]),
  },

  // ── C7: FinTech Global — extra projects ──
  {
    id: "p32", name: "Cross-Border Payments", clientId: "c7",
    status: "ongoing", health: "amber", progress: 0,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u8"],
    startDate: "2026-06-12", endDate: "2027-01-31",
    budget: 920000, spent: 0,
    description: "SWIFT-compliant cross-border payment rails for 40+ countries.",
    wbs: mkWbs(), tasks: mkTasks("p32", ["u6", "u7", "u8"]),
  },
  {
    id: "p33", name: "KYC Automation", clientId: "c7",
    status: "completed", health: "green", progress: 100,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u9", "u10"],
    startDate: "2024-01-01", endDate: "2024-08-31",
    budget: 540000, spent: 525000,
    description: "AI-driven KYC document verification reducing manual review by 80%.",
    wbs: mkWbs(), tasks: mkTasks("p33", ["u5", "u7", "u9"]),
  },
  {
    id: "p34", name: "Open Banking API Suite", clientId: "c7",
    status: "completed", health: "amber", progress: 44,
    pmId: "u4", tlId: "u6", teamIds: ["u8", "u10"],
    startDate: "2023-03-01", endDate: "2023-10-15",
    budget: 320000, spent: 300000,
    description: "PSD2-compliant open banking API suite for third-party integrators.",
    wbs: mkWbs(), tasks: mkTasks("p34", ["u6", "u8", "u10"]),
  },

  // ── C8: MediCare Plus — extra projects ──
  {
    id: "p35", name: "Telemedicine Platform", clientId: "c8",
    status: "completed", health: "green", progress: 100,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u8", "u10"],
    startDate: "2024-05-01", endDate: "2025-01-15",
    budget: 670000, spent: 650000,
    description: "HIPAA-compliant video consultation and remote monitoring platform.",
    wbs: mkWbs(), tasks: mkTasks("p35", ["u6", "u7", "u8"]),
  },
  {
    id: "p36", name: "Insurance Claims Automation", clientId: "c8",
    status: "ongoing", health: "green", progress: 0,
    pmId: "u3", tlId: "u5", teamIds: ["u8", "u9"],
    startDate: "2026-06-20", endDate: "2026-12-31",
    budget: 380000, spent: 0,
    description: "AI-powered claims processing reducing settlement time from 30 to 3 days.",
    wbs: mkWbs(), tasks: mkTasks("p36", ["u5", "u8", "u9"]),
  },
  {
    id: "p37", name: "Patient Engagement App", clientId: "c8",
    status: "completed", health: "amber", progress: 52,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u10"],
    startDate: "2023-07-01", endDate: "2024-03-31",
    budget: 290000, spent: 270000,
    description: "Patient-facing app for appointment booking, reminders and health records.",
    wbs: mkWbs(), tasks: mkTasks("p37", ["u6", "u7", "u10"]),
  },

  // ── C9: EcoGreen Solutions — extra projects ──
  {
    id: "p38", name: "ESG Reporting Engine", clientId: "c9",
    status: "completed", health: "green", progress: 100,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u8"],
    startDate: "2024-02-15", endDate: "2024-10-30",
    budget: 420000, spent: 405000,
    description: "Automated ESG data aggregation and reporting aligned to GRI and TCFD standards.",
    wbs: mkWbs(), tasks: mkTasks("p38", ["u5", "u7", "u8"]),
  },
  {
    id: "p39", name: "Waste Management IoT", clientId: "c9",
    status: "ongoing", health: "green", progress: 0,
    pmId: "u4", tlId: "u6", teamIds: ["u8", "u9", "u10"],
    startDate: "2026-06-18", endDate: "2026-12-20",
    budget: 360000, spent: 0,
    description: "Smart bin monitoring network with route optimization for waste collectors.",
    wbs: mkWbs(), tasks: mkTasks("p39", ["u6", "u8", "u9"]),
  },
  {
    id: "p40", name: "Water Quality Platform", clientId: "c9",
    status: "completed", health: "amber", progress: 48,
    pmId: "u3", tlId: "u5", teamIds: ["u7", "u10"],
    startDate: "2023-04-01", endDate: "2023-11-30",
    budget: 310000, spent: 290000,
    description: "IoT sensor network for real-time water quality monitoring across 200 sites.",
    wbs: mkWbs(), tasks: mkTasks("p40", ["u5", "u7", "u10"]),
  },

  // ── C10: AutoDrive Systems — extra projects ──
  {
    id: "p41", name: "ADAS Integration Suite", clientId: "c10",
    status: "completed", health: "green", progress: 100,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u8", "u9"],
    startDate: "2024-01-20", endDate: "2024-11-30",
    budget: 980000, spent: 960000,
    description: "Advanced driver-assistance system integration for 3 OEM partners.",
    wbs: mkWbs(), tasks: mkTasks("p41", ["u6", "u7", "u8"]),
  },
  {
    id: "p42", name: "V2X Communication Platform", clientId: "c10",
    status: "ongoing", health: "amber", progress: 0,
    pmId: "u3", tlId: "u5", teamIds: ["u8", "u9"],
    startDate: "2026-06-25", endDate: "2027-02-28",
    budget: 1100000, spent: 0,
    description: "Vehicle-to-everything communication layer for smart city integration.",
    wbs: mkWbs(), tasks: mkTasks("p42", ["u5", "u8", "u9"]),
  },
  {
    id: "p43", name: "OBD Diagnostics Cloud", clientId: "c10",
    status: "completed", health: "amber", progress: 38,
    pmId: "u4", tlId: "u6", teamIds: ["u7", "u10"],
    startDate: "2023-08-01", endDate: "2024-04-30",
    budget: 430000, spent: 400000,
    description: "Cloud-based OBD-II diagnostics aggregation for fleet health monitoring.",
    wbs: mkWbs(), tasks: mkTasks("p43", ["u6", "u7", "u10"]),
  },
];

// Apply sub-venture names to all projects from the map
projects.forEach((p) => { if (!p.subVenture && PROJECT_SUBVENTURES[p.id]) p.subVenture = PROJECT_SUBVENTURES[p.id]; });

export { PROJECT_SUBVENTURES };


export const issues: Issue[] = [
  {
    id: "i1", clientId: "c1", projectId: "p1",
    type: "resource_shortage", priority: "high", status: "open",
    description: "Need 2 additional senior backend engineers to hit the May milestone for the payments service.",
    raisedById: "u3", raisedByRole: "PM",
    assignedToId: "u1", assignedToRole: "Senior PM",
    createdAt: "2026-05-04T09:20:00Z", updatedAt: "2026-05-09T11:00:00Z",
    comments: [
      { id: "c1", authorId: "u3", text: "Velocity dropping; sprint burndown is flat for 5 days.", createdAt: "2026-05-04T09:20:00Z" },
      { id: "c2", authorId: "u1", text: "Let me check the bench. Can you share the skill mix?", createdAt: "2026-05-05T10:10:00Z" },
      { id: "c3", authorId: "u3", text: "Java + Kafka, 5+ years.", createdAt: "2026-05-06T08:30:00Z" },
    ],
    audit: [
      { id: "a1", actorId: "u3", action: "Raised issue", at: "2026-05-04T09:20:00Z" },
      { id: "a2", actorId: "u1", action: "Acknowledged", at: "2026-05-05T10:10:00Z" },
    ],
    taggedUserIds: ["u2", "u11", "u12"],
  },

  {
    id: "i2", clientId: "c2", projectId: "p3",
    type: "delay", priority: "critical", status: "in_progress",
    description: "Vendor data feed delayed by 3 weeks. Triggers downstream slip on UAT.",
    raisedById: "u4", raisedByRole: "PM",
    assignedToId: "u2", assignedToRole: "EM",
    createdAt: "2026-05-02T07:00:00Z", updatedAt: "2026-05-10T14:00:00Z",
    comments: [
      { id: "c4", authorId: "u4", text: "Need EM to escalate to client procurement.", createdAt: "2026-05-02T07:00:00Z" },
      { id: "c5", authorId: "u2", text: "Set up a steerco for Tue. Looping HOD.", createdAt: "2026-05-03T09:00:00Z" },
    ],
    audit: [
      { id: "a3", actorId: "u4", action: "Raised issue", at: "2026-05-02T07:00:00Z" },
      { id: "a4", actorId: "u2", action: "Status → In Progress", at: "2026-05-03T09:00:00Z" },
    ],
    taggedUserIds: ["u1", "u11", "u12"],
  },

  {
    id: "i3", clientId: "c4", projectId: "p7",
    type: "scope_change", priority: "medium", status: "open",
    description: "Client wants to add iOS driver app — not in original SOW.",
    raisedById: "u3", raisedByRole: "PM",
    assignedToId: "u2", assignedToRole: "EM",
    createdAt: "2026-05-07T11:30:00Z", updatedAt: "2026-05-08T09:00:00Z",
    comments: [
      { id: "c6", authorId: "u3", text: "Need a CR or a separate workstream.", createdAt: "2026-05-07T11:30:00Z" },
    ],
    audit: [{ id: "a5", actorId: "u3", action: "Raised issue", at: "2026-05-07T11:30:00Z" }],
    taggedUserIds: ["u1", "u11"],
  },

  {
    id: "i4", clientId: "c1", projectId: "p2",
    type: "client_issue", priority: "medium", status: "resolved",
    description: "Client security review flagged 3 medium issues in mobile auth flow.",
    raisedById: "u5", raisedByRole: "TL",
    assignedToId: "u3", assignedToRole: "PM",
    createdAt: "2026-04-20T08:00:00Z", updatedAt: "2026-04-29T17:00:00Z",
    comments: [
      { id: "c7", authorId: "u5", text: "Patches ready for review.", createdAt: "2026-04-22T08:00:00Z" },
      { id: "c8", authorId: "u3", text: "Approved. Closing.", createdAt: "2026-04-29T17:00:00Z" },
    ],
    audit: [
      { id: "a6", actorId: "u5", action: "Raised issue", at: "2026-04-20T08:00:00Z" },
      { id: "a7", actorId: "u3", action: "Resolved", at: "2026-04-29T17:00:00Z" },
    ],
    taggedUserIds: ["u1", "u11"],
  },

  {
    id: "i5", clientId: "c5", projectId: "p9",
    type: "internal_blocker", priority: "high", status: "open",
    description: "Cloud cost overrun — need finance approval to expand Snowflake warehouse.",
    raisedById: "u3", raisedByRole: "PM",
    assignedToId: "u2", assignedToRole: "EM",
    createdAt: "2026-05-09T13:00:00Z", updatedAt: "2026-05-09T13:00:00Z",
    comments: [],
    audit: [{ id: "a8", actorId: "u3", action: "Raised issue", at: "2026-05-09T13:00:00Z" }],
    taggedUserIds: ["u1", "u11", "u12"],
  },

];

export const timesheets: Timesheet[] = [
  {
    id: "ts1", userId: "u3", userRole: "PM", weekStart: "2026-05-04",
    status: "submitted", totalHours: 42, submittedAt: "2026-05-09T18:00:00Z",
    entries: [
      { taskId: "p1-t3", projectId: "p1", hours: [3, 4, 3, 4, 2, 0, 0], note: "Steerco prep + sprint review" },
      { taskId: "p2-t4", projectId: "p2", hours: [2, 2, 3, 2, 3, 0, 0] },
      { taskId: "p5-t5", projectId: "p5", hours: [3, 2, 2, 3, 4, 0, 0] },
    ],
  },
  {
    id: "ts2", userId: "u4", userRole: "PM", weekStart: "2026-05-04",
    status: "submitted", totalHours: 40, submittedAt: "2026-05-09T19:30:00Z",
    entries: [
      { taskId: "p3-t3", projectId: "p3", hours: [4, 4, 4, 4, 4, 0, 0] },
      { taskId: "p4-t4", projectId: "p4", hours: [4, 4, 4, 4, 4, 0, 0] },
    ],
  },
  {
    id: "ts3", userId: "u3", userRole: "PM", weekStart: "2026-04-27",
    status: "approved", totalHours: 41, submittedAt: "2026-05-02T17:00:00Z",
    entries: [
      { taskId: "p1-t2", projectId: "p1", hours: [4, 5, 4, 4, 4, 0, 0] },
      { taskId: "p2-t3", projectId: "p2", hours: [4, 3, 4, 4, 5, 0, 0] },
    ],
  },
  {
    id: "ts4", userId: "u4", userRole: "PM", weekStart: "2026-04-27",
    status: "rejected", totalHours: 38, submittedAt: "2026-05-02T18:00:00Z",
    rejectionReason: "Hours on p4 inconsistent with on-hold status. Please revise.",
    entries: [
      { taskId: "p3-t2", projectId: "p3", hours: [4, 4, 4, 4, 4, 0, 0] },
      { taskId: "p4-t3", projectId: "p4", hours: [4, 4, 4, 3, 3, 0, 0] },
    ],
  },
  {
    id: "ts5", userId: "u1", userRole: "Senior PM", weekStart: "2026-05-04",
    status: "submitted", totalHours: 44, submittedAt: "2026-05-09T20:00:00Z",
    entries: [
      { taskId: "p1-t5", projectId: "p1", hours: [4, 5, 4, 5, 4, 0, 0], note: "Steerco + portfolio reviews" },
      { taskId: "p2-t5", projectId: "p2", hours: [3, 3, 3, 3, 3, 0, 0] },
      { taskId: "p5-t5", projectId: "p5", hours: [1, 2, 1, 2, 1, 0, 0] },
    ],
  },
  {
    id: "ts6", userId: "u2", userRole: "EM", weekStart: "2026-05-04",
    status: "submitted", totalHours: 41, submittedAt: "2026-05-09T20:30:00Z",
    entries: [
      { taskId: "p3-t5", projectId: "p3", hours: [4, 4, 5, 4, 4, 0, 0], note: "Client steerco for vendor escalation" },
      { taskId: "p7-t5", projectId: "p7", hours: [3, 3, 3, 3, 3, 0, 0] },
      { taskId: "p9-t5", projectId: "p9", hours: [1, 1, 1, 1, 1, 0, 0] },
    ],
  },
  {
    id: "ts7", userId: "u1", userRole: "Senior PM", weekStart: "2026-04-27",
    status: "approved", totalHours: 42, submittedAt: "2026-05-02T19:00:00Z",
    entries: [
      { taskId: "p1-t4", projectId: "p1", hours: [4, 5, 4, 4, 4, 0, 0] },
      { taskId: "p2-t4", projectId: "p2", hours: [4, 3, 4, 3, 3, 0, 0] },
    ],
  },
];

export const issueTypeLabels: Record<IssueType, string> = {
  scope_change: "Scope Change",
  resource_shortage: "Resource Shortage",
  delay: "Delay",
  escalation: "Escalation",
  client_issue: "Client Issue",
  internal_blocker: "Internal Blocker",
};

export const projectStatusLabels: Record<ProjectStatus, string> = {
  ongoing: "Ongoing",
  completed: "Completed",
  on_hold: "On Hold",
};

export const taskStatusLabels: Record<TaskStatus, string> = {
  todo: "To Do",
  in_progress: "In Progress",
  review: "In Review",
  done: "Done",
};

// ---------- WBS Allocation (Sales → PMO intake) ----------
export type WbsRequestStatus = "new" | "under_allocation" | "assigned" | "active" | "closed";
export type AllocationRoleSlot = "spm" | "em" | "pm";

export interface PersonWorkload {
  personId: string;
  activeProjects: number;
  utilization: number; // 0-100%
  availableFrom: string; // ISO date
  skills: string[];
  onBench: boolean;
}

export interface WbsAllocationSlot {
  role: AllocationRoleSlot;
  personId?: string;
  assignedAt?: string;
}

export interface WbsAllocationAuditEntry {
  id: string;
  actorId: string;
  action: string;
  at: string;
}

export type WbsComplexity = "Low" | "Medium" | "High";

export interface WbsRequest {
  id: string;
  code: string;             // e.g. "WBS-2026-014"
  clientId: string;
  projectName: string;
  scope: string;
  modules: string[];
  deliverables: string[];
  complexity: WbsComplexity;
  teamSize: number;
  requiredRoles: AllocationRoleSlot[];
  skillNeeds: string[];
  timelineStart: string;
  timelineEnd: string;
  resourceCount: number;
  estBudget: number;
  receivedFrom: string;     // sales person name
  receivedAt: string;
  status: WbsRequestStatus;
  slots: WbsAllocationSlot[];
  audit: WbsAllocationAuditEntry[];
}

export const personWorkload: PersonWorkload[] = [
  { personId: "u1", activeProjects: 4, utilization: 85, availableFrom: "2026-06-15", skills: ["BFSI", "Programme", "Cloud"], onBench: false },
  { personId: "u2", activeProjects: 3, utilization: 70, availableFrom: "2026-05-25", skills: ["Healthcare", "Retail", "Client mgmt"], onBench: false },
  { personId: "u3", activeProjects: 4, utilization: 92, availableFrom: "2026-07-01", skills: ["Java", "Kafka", "Banking"], onBench: false },
  { personId: "u4", activeProjects: 3, utilization: 78, availableFrom: "2026-06-05", skills: ["Pharma", "Data", "Analytics"], onBench: false },
];

export const wbsRequests: WbsRequest[] = [
  {
    id: "wbs1", code: "WBS-2026-014", clientId: "c1",
    projectName: "Open Banking API Gateway",
    scope: "Build PSD2-compliant API gateway with OAuth2, consent mgmt and developer portal. 6-month delivery in 3 phases.",
    modules: ["Auth & OAuth2", "Consent Management", "API Gateway", "Developer Portal", "Audit & Logging"],
    deliverables: ["Architecture blueprint", "Production gateway", "Sandbox environment", "Partner onboarding kit", "Compliance report"],
    complexity: "High", teamSize: 14,
    requiredRoles: ["spm", "em", "pm"],
    skillNeeds: ["Banking", "Java", "Kafka", "API security"],
    timelineStart: "2026-06-01", timelineEnd: "2026-12-15",
    resourceCount: 14, estBudget: 1450000,
    receivedFrom: "Sales · Karan Bhatia", receivedAt: "2026-05-10T09:00:00Z",
    status: "new",
    slots: [{ role: "spm" }, { role: "em" }, { role: "pm" }],
    audit: [{ id: "wa1", actorId: "u11", action: "WBS received from Sales", at: "2026-05-10T09:00:00Z" }],
  },
  {
    id: "wbs2", code: "WBS-2026-013", clientId: "c2",
    projectName: "Patient Engagement Mobile",
    scope: "Cross-platform patient app: appointment booking, e-prescriptions, vitals tracking, HIPAA logging.",
    modules: ["Appointments", "E-Prescriptions", "Vitals & Wearables", "Notifications", "HIPAA Audit"],
    deliverables: ["iOS & Android apps", "Backend services", "HIPAA audit pack", "Pilot rollout plan"],
    complexity: "Medium", teamSize: 9,
    requiredRoles: ["em", "pm"],
    skillNeeds: ["Healthcare", "React Native", "HIPAA"],
    timelineStart: "2026-05-20", timelineEnd: "2026-11-10",
    resourceCount: 9, estBudget: 720000,
    receivedFrom: "Sales · Neha Arora", receivedAt: "2026-05-08T10:30:00Z",
    status: "under_allocation",
    slots: [
      { role: "em", personId: "u2", assignedAt: "2026-05-09T11:00:00Z" },
      { role: "pm" },
    ],
    audit: [
      { id: "wa2", actorId: "u11", action: "WBS received from Sales", at: "2026-05-08T10:30:00Z" },
      { id: "wa3", actorId: "u11", action: "Started allocation review", at: "2026-05-09T09:00:00Z" },
      { id: "wa4", actorId: "u11", action: "Assigned Engagement Manager → Riya Kapoor", at: "2026-05-09T11:00:00Z" },
    ],
  },
  {
    id: "wbs3", code: "WBS-2026-012", clientId: "c3",
    projectName: "Loyalty Program Revamp",
    scope: "Replatform loyalty engine with tier-based rewards and partner integrations.",
    modules: ["Tier Engine", "Rewards Catalog", "Partner Integrations", "Member Portal"],
    deliverables: ["Loyalty platform", "Partner SDK", "Member portal", "Migration scripts"],
    complexity: "Medium", teamSize: 8,
    requiredRoles: ["spm", "pm"],
    skillNeeds: ["Retail", "Microservices", "Promotions"],
    timelineStart: "2026-06-10", timelineEnd: "2026-10-30",
    resourceCount: 8, estBudget: 540000,
    receivedFrom: "Sales · Karan Bhatia", receivedAt: "2026-05-05T08:00:00Z",
    status: "assigned",
    slots: [
      { role: "spm", personId: "u1", assignedAt: "2026-05-06T15:00:00Z" },
      { role: "pm", personId: "u4", assignedAt: "2026-05-06T15:05:00Z" },
    ],
    audit: [
      { id: "wa5", actorId: "u11", action: "WBS received from Sales", at: "2026-05-05T08:00:00Z" },
      { id: "wa6", actorId: "u11", action: "Assigned Senior PM → Aarav Mehta", at: "2026-05-06T15:00:00Z" },
      { id: "wa7", actorId: "u11", action: "Assigned Project Manager → Sana Iyer", at: "2026-05-06T15:05:00Z" },
      { id: "wa8", actorId: "u11", action: "Allocation confirmed", at: "2026-05-06T15:10:00Z" },
    ],
  },
  {
    id: "wbs4", code: "WBS-2026-011", clientId: "c4",
    projectName: "Last-Mile Routing AI",
    scope: "ML-driven route optimisation for 5K-vehicle fleet, with real-time re-routing.",
    modules: ["Telematics Ingest", "ML Routing Engine", "Driver App", "Ops Console"],
    deliverables: ["Routing engine", "Driver mobile app", "Ops dashboard", "Model retraining pipeline"],
    complexity: "High", teamSize: 12,
    requiredRoles: ["spm", "em", "pm"],
    skillNeeds: ["Logistics", "ML", "GIS"],
    timelineStart: "2026-04-01", timelineEnd: "2026-12-20",
    resourceCount: 12, estBudget: 980000,
    receivedFrom: "Sales · Neha Arora", receivedAt: "2026-03-28T07:00:00Z",
    status: "active",
    slots: [
      { role: "spm", personId: "u1", assignedAt: "2026-03-29T10:00:00Z" },
      { role: "em", personId: "u2", assignedAt: "2026-03-29T10:05:00Z" },
      { role: "pm", personId: "u3", assignedAt: "2026-03-29T10:10:00Z" },
    ],
    audit: [
      { id: "wa9", actorId: "u11", action: "WBS received from Sales", at: "2026-03-28T07:00:00Z" },
      { id: "wa10", actorId: "u11", action: "Allocation completed", at: "2026-03-29T10:15:00Z" },
      { id: "wa11", actorId: "u11", action: "Project kicked-off", at: "2026-04-01T09:00:00Z" },
    ],
  },
  {
    id: "wbs5", code: "WBS-2026-009", clientId: "c5",
    projectName: "Grid Outage Predictor",
    scope: "Predictive outage model + ops dashboard, integrated with SCADA feeds.",
    modules: ["SCADA Connector", "Predictive Model", "Ops Dashboard", "Alerting"],
    deliverables: ["Outage model", "Ops dashboard", "Runbook"],
    complexity: "Low", teamSize: 7,
    requiredRoles: ["em", "pm"],
    skillNeeds: ["Energy", "Data", "Python"],
    timelineStart: "2026-02-01", timelineEnd: "2026-05-15",
    resourceCount: 7, estBudget: 410000,
    receivedFrom: "Sales · Karan Bhatia", receivedAt: "2026-01-22T08:00:00Z",
    status: "closed",
    slots: [
      { role: "em", personId: "u2", assignedAt: "2026-01-23T10:00:00Z" },
      { role: "pm", personId: "u4", assignedAt: "2026-01-23T10:05:00Z" },
    ],
    audit: [
      { id: "wa12", actorId: "u11", action: "WBS received from Sales", at: "2026-01-22T08:00:00Z" },
      { id: "wa13", actorId: "u11", action: "Allocation completed", at: "2026-01-23T10:10:00Z" },
      { id: "wa14", actorId: "u11", action: "Project closed", at: "2026-05-15T17:00:00Z" },
    ],
  },
];

export const wbsStatusLabels: Record<WbsRequestStatus, string> = {
  new: "New",
  under_allocation: "Under Allocation",
  assigned: "Assigned",
  active: "Active",
  closed: "Closed",
};

export const allocationRoleLabels: Record<AllocationRoleSlot, string> = {
  spm: "Senior Project Manager",
  em: "Engagement Manager",
  pm: "Project Manager",
};

