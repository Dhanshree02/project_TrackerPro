  export type Role =
  | "Admin"
  | "senior_pm"
  | "engagement_manager"
  | "pmo"
  | "hod"
  | "business_owner"
  | "dhanshree"
  | "employee"
  | "pm"
  | "hr"
  | "accounts_finance"
  | "sales_bd"
  | "CEO"
  | "COO"
  | "CTO"
  | "IT Admin"
  | "Accounts"
  | "HR"
  | "Sales Manager"
  | "Sales team member"
  | "PMO"
  | "EngagementManager"
  | "Intern"
  | "Testing HOD"
  | "Testing Senior Manager"
  | "Testing-Manager"
  | "Testing-Team Leader"
  | "Testing-Team Member"
  | "Consulting-HOD"
  | "Consulting-Senior Manager"
  | "Consulting-Manager"
  | "Consulting-Team Leader"
  | "Consulting-Team member"
  | "SOC-HOD"
  | "SOC-Senior Manager"
  | "SOC-Manager"
  | "SOC-Team Leader"
  | "SOC-Team Member"
  | "R&D - Team member";

export type ProjectStatus = "ongoing" | "completed" | "on_hold" | "archived";
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
  serviceId?: string;
  wbsStartDate?: string;
  wbsEndDate?: string;
  estimatedHours?: number;
  actualStartDate?: string;
  actualEndDate?: string;
  utilizedHours?: number;
  stage?:
  | "Ready to Start"
  | "Ongoing"
  | "Completed"
  | "On Hold (Internal)"
  | "On Hold (Client End)"
  | "After Release";
}

export interface WBSNode {
  id: string;
  name: string;
  progress: number;
  children?: WBSNode[];
}

export interface WbsService {
  id: string;
  taskId?: string;
  department: string;
  subDepartment?: string;
  serviceName: string;
  qty: number;
  description: string;
  resourceLevel?: string;
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
  collectionStatus?: string;
  validationStatus?: string;
  billingStatus?: string;
  isReady?: boolean;
  changeStatus?: string;
  originalQty?: number | null;
  pendingQty?: number | null;
  pendingResourceLevel?: string | null;
  pendingUnitPrice?: number | null;
  modCollectionStatus?: string | null;
  modValidationStatus?: string | null;
  modBillingStatus?: string | null;
  modIsReady?: boolean | null;
  deletedAtUtc?: string | null;
  isDeleted?: boolean;
}

export interface WbsInvoice {
  id: string;
  milestone: string;
  amount: number;
  invoiceDate: string;
  remarks: string;
  serviceId?: string;
  serviceName?: string;
  resourceLevel?: string;
}

export interface WBSDetails {
  contractType: string;
  projectType: string;
  salesPerson: string;
  engagementManager?: string;
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
    poFileName?: string;
    poFileDataUrl?: string;
    invoices: WbsInvoice[];
  };
}

export type WbsStatus =
  | "draft"
  | "approval_pending"
  | "ph_approved"
  | "accounts_approved"
  | "approved"
  | "started"
  | "assigned";

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
  shadowTeamIds?: string[];
  startDate: string;
  endDate: string;
  budget: number;
  spent: number;
  description: string;
  wbs: WBSNode[];
  wbsDetails?: WBSDetails;
  tasks: Task[];
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
  projectSeqId?: string;
  wbsId?: string;
  subVenture?: string;
  renewedFromWbsId?: string;
  renewedFromProjectId?: string;
  isRenewal?: boolean;
  projectManagerId?: string;
  projectManagerName?: string;
  projectManagers?: { employeeId: string; name: string }[];
  seniorProjectManagers?: { employeeId: string; name: string }[];
  teamLeads?: { employeeId: string; name: string }[];
  teamLeadId?: string;
  teamLeadName?: string;
  seniorProjectManager?: string;
}

export interface ClientContact {
  name: string;
  email: string;
  phone?: string;
  designation?: string;
  contactType?: string;
  country?: string;
  phoneCode?: string;
}

export interface ClientSubVenture {
  id?: string;
  name: string;
  contacts?: ClientContact[];
  notes?: string;
  kycDocumentName?: string;
  kycDocumentPath?: string;
}

export function clientLogo(name: string): string {
  const t = (name ?? "").trim();
  if (!t) return "";
  const words = t.split(/\s+/).filter(Boolean);
  return words
    .slice(0, 2)
    .map((w) => w[0])
    .join("")
    .toUpperCase();
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
  salesManager?: string;
  subVentures?: ClientSubVenture[];
  contactName?: string;
  contactPhone?: string;
  contactDesignation?: string;
  contactType?: string;
  city?: string;
  country?: string;
  businessType?: string;
  billingMedium?: string;
  groupSpocName?: string;
  groupSpocPhoneCode?: string;
  groupSpocContact?: string;
  notes?: string;
  kycDocumentName?: string;
  kycDocumentPath?: string;
  customerSince?: string;
  createdByName?: string;
  clientCode?: string;
  contacts?: ClientContact[];
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
  createdAt: string;
}

export interface CellCommentData {
  status: "new" | "viewed" | "clarification_requested";
  history: CellCommentMessage[];
}

export type TimesheetEntryDecision = "approved" | "rejected" | "change_requested";

export interface TimesheetEntry {
  taskId: string;
  projectId: string;
  hours: number[];
  note?: string;
  notes?: string[];
  cellComments?: Record<number, CellCommentData>;
  reviewDecision?: TimesheetEntryDecision;
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

// ---------- Runtime Person Directory (DB Employees) ----------
export const people: Person[] = [];

const knownPeople: Record<string, Person> = {};

function initialsFromName(name: string): string {
  return (
    name
      .split(/\s+/)
      .filter(Boolean)
      .map((w) => w[0])
      .join("")
      .slice(0, 2)
      .toUpperCase() || "?"
  );
}

export function registerPeople(
  entries: Array<{ id: string; name: string; role?: string; avatar?: string; email?: string }>,
): void {
  for (const e of entries) {
    if (!e?.id || !e?.name?.trim()) continue;
    const name = e.name.trim();
    const prev = knownPeople[e.id];
    knownPeople[e.id] = {
      id: e.id,
      name,
      role: e.role || prev?.role || "User",
      avatar: e.avatar || prev?.avatar || initialsFromName(name),
      email: e.email || prev?.email || "",
    };
  }
}

export function getKnownPeopleSnapshot(): Record<string, Person> {
  return { ...knownPeople };
}

export function hydrateKnownPeople(map: Record<string, Person> | null | undefined): void {
  if (!map || typeof map !== "object") return;
  for (const [id, p] of Object.entries(map)) {
    if (p?.id && p?.name) knownPeople[id] = p;
  }
}

export const getPerson = (id: string) => {
  const key = (id || "").trim();
  if (!key) {
    return { id: "unknown", name: "Unknown User", role: "User", avatar: "?", email: "" };
  }
  if (knownPeople[key]) return knownPeople[key];
  const knownByName = Object.values(knownPeople).find(
    (p) => p.name.toLowerCase() === key.toLowerCase(),
  );
  if (knownByName) return knownByName;
  return {
      id: key,
      name: key,
      role: "User",
      avatar: key.slice(0, 2).toUpperCase(),
      email: "",
  };
};

// ---------- Empty Legacy Arrays (All data is DB-driven) ----------
export const clients: Client[] = [];

export const assignments: Record<Role, string[]> = {
  Admin: [],
  CEO: [],
  COO: [],
  CTO: [],
  "IT Admin": [],
  Accounts: [],
  HR: [],
  "Sales Manager": [],
  "Sales team member": [],
  PMO: [],
  EngagementManager: [],
  Intern: [],
  "Testing HOD": [],
  "Testing Senior Manager": [],
  "Testing-Manager": [],
  "Testing-Team Leader": [],
  "Testing-Team Member": [],
  "Consulting-HOD": [],
  "Consulting-Senior Manager": [],
  "Consulting-Manager": [],
  "Consulting-Team Leader": [],
  "Consulting-Team member": [],
  "SOC-HOD": [],
  "SOC-Senior Manager": [],
  "SOC-Manager": [],
  "SOC-Team Leader": [],
  "SOC-Team Member": [],
  "R&D - Team member": [],
  senior_pm: [],
  engagement_manager: [],
  pmo: [],
  hod: [],
  business_owner: [],
  dhanshree: [],
  employee: [],
  pm: [],
  hr: [],
  accounts_finance: [],
  sales_bd: [],
};

export const pmBuckets: { pmId: string; capacity: number; allocated: number }[] = [];
export const benchResourceIds: string[] = [];

export type InvoiceStatus = "raised" | "pending" | "paid" | "overdue";
export type PaymentStatus = "not_initiated" | "pending" | "completed" | "overdue";
export const invoices: {
  projectId: string;
  unitPrice: number;
  qty: number;
  currency: string;
  invoiceAmount: number;
  status: InvoiceStatus;
  paymentStatus: PaymentStatus;
  raisedOn: string;
  paymentReceivedDate?: string;
}[] = [];

export interface AllocationEvent {
  id: string;
  projectId: string;
  action: string;
  actorId: string;
  fromId?: string;
  toId: string;
  at: string;
}
export const allocationHistory: AllocationEvent[] = [];

export const PROJECT_SUBVENTURES: Record<string, string> = {};
export const projects: Project[] = [];
export const issues: Issue[] = [];
export const timesheets: Timesheet[] = [];

export const issueTypeLabels: Record<IssueType, string> = {
  scope_change: "Scope Change",
  resource_shortage: "Resource Shortage",
  delay: "Delay",
  escalation: "Escalation",
  client_issue: "Customer Issue",
  internal_blocker: "Internal Blocker",
};

export const projectStatusLabels: Record<ProjectStatus, string> = {
  ongoing: "Ongoing",
  completed: "Completed",
  on_hold: "On Hold",
  archived: "Archived",
};

export const taskStatusLabels: Record<TaskStatus, string> = {
  todo: "To Do",
  in_progress: "In Progress",
  review: "In Review",
  done: "Done",
};

export type WbsRequestStatus = "new" | "under_allocation" | "assigned" | "active" | "closed";
export type AllocationRoleSlot = "spm" | "em" | "pm";

export interface PersonWorkload {
  personId: string;
  activeProjects: number;
  utilization: number;
  availableFrom: string;
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
  code: string;
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
  receivedFrom: string;
  receivedAt: string;
  status: WbsRequestStatus;
  slots: WbsAllocationSlot[];
  audit: WbsAllocationAuditEntry[];
}

export const personWorkload: PersonWorkload[] = [];
export const wbsRequests: WbsRequest[] = [];

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
