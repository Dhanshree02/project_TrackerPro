// Lightweight cross-module store for Dhanshree workflows.
// Holds extra clients/projects created at runtime, plus issues, alerts,
// escalations, appreciations, interviews and prerequisite statuses.
// Uses useSyncExternalStore for reactive updates across modules.

import { useSyncExternalStore } from "react";
import {
  clients as baseClients,
  projects as baseProjects,
  timesheets as baseTimesheets,
  invoices as baseInvoices,
  type Client,
  type Project,
  getPerson,
  type TimesheetStatus,
  type TimesheetEntry,
  type CellCommentData,
  type CellCommentMessage,
} from "@/lib/mock-data";

import { type Billability, type ResourceType, getProjectEMs, getProjectPMs } from "@/lib/dh-helpers";

// ---------- Types ----------
export type IssueCategory =
  | "Technical Related Issues"
  | "Behavioral Related Issues"
  | "Process Related Issues";

export type DhIssueStatus = "Open" | "In Progress" | "Resolved";
export type DhPriority = "Low" | "Medium" | "High" | "Critical";

export interface DhComment {
  id: string;
  authorId: string;
  authorName: string;
  text: string;
  at: string;
}

export interface DhIssue {
  id: string;
  title: string;
  description: string;
  projectId: string;
  raisedById: string;
  raisedByName: string;
  raisedByRole: string;
  category: IssueCategory;
  priority: DhPriority;
  status: DhIssueStatus;
  attachmentName?: string;
  createdAt: string;
  comments: DhComment[];
  audit: { id: string; text: string; at: string }[];
}

export type AlertKind =
  | "Issue"
  | "Interview Rejected"
  | "Interview Selected"
  | "Escalation"
  | "Approval"
  | "Dependency";

export type AlertStatus = "Open" | "In Progress" | "Resolved" | "Closed" | "Acknowledged" | "Waiting for Client";

export interface DhAlert {
  id: string;
  title: string;
  kind: AlertKind;
  projectId?: string;
  raisedByName: string;
  audienceUserIds: string[]; // who sees it
  priority: DhPriority;
  status: AlertStatus;
  refId?: string; // issueId / interviewId
  createdAt: string;
  comments: DhComment[];
  // Governance additions:
  alertId?: string;
  description?: string;
  alertType?:
  | "Project Risk"
  | "Resource Risk"
  | "Technical Issue"
  | "Dependency Blocker"
  | "Escalation"
  | "Client Concern"
  | "Budget Concern"
  | "Schedule Delay"
  | "Quality Concern"
  | "Governance Alert";
  owner?: string;
  resolutionOwner?: string;
  escalationOwner?: string;
  resolutionDetails?: string;
  attachments?: string[];
  history?: { status: AlertStatus; at: string; updatedBy: string; details?: string }[];
  // Escalation additions:
  serviceName?: string;
  escalationType?: string;
  escalatedTo?: string[];
  expectedResolutionDate?: string;
}

export interface DhTimesheet {
  id: string;
  userId: string;
  userRole: "Employee" | "TL" | "PM" | "Senior PM" | "EM";
  weekStart: string;
  status: TimesheetStatus;
  entries: TimesheetEntry[];
  totalHours: number;
  submittedAt?: string;
  comments: DhComment[];
  history: {
    status: TimesheetStatus;
    at: string;
    updatedBy: string;
    comment: string;
  }[];
}

export interface DhCentralApproval {
  id: string;
  projectId: string;
  projectName: string;
  requestType:
  | "WBS Approval"
  | "Budget Approval"
  | "PM Assignment Approval"
  | "SPM Assignment Approval"
  | "Project Ready To Start Approval"
  | "Resource Allocation Approval"
  | "Client Requirement Approval"
  | "Timeline Extension Approval"
  | "Leadership Change Approval";
  requestedBy: string;
  requestedById: string;
  requestedDate: string;
  status: "Pending" | "Approved" | "Rejected" | "Hold" | "Request Changes";
  description: string;
  comments: DhComment[];
  history: {
    status: "Pending" | "Approved" | "Rejected" | "Hold" | "Request Changes";
    at: string;
    updatedBy: string;
    comment: string;
  }[];
  acknowledgedAt?: string;
}

// ---------- Leadership Change Request ----------
export type LeadershipRole = "Engagement Manager" | "Senior Project Manager" | "Project Manager" | "Team Lead";

export interface LeadershipChangeRequest {
  id: string;
  projectId: string;
  projectName: string;
  role: LeadershipRole;
  currentLeaderIds: string[];
  currentLeaderNames: string[];
  newLeaderIds: string[];
  newLeaderNames: string[];
  effectiveDate: string;
  changeReason: string;
  additionalComments: string;
  notifyPersonIds: string[];
  attachmentName?: string;
  requestedBy: string;
  requestedById: string;
  requestedDate: string;
  status: "Pending" | "Approved" | "Rejected" | "Request Changes";
  approvalId: string;
  auditHistory: {
    previousLeaderNames: string[];
    newLeaderNames: string[];
    changedBy: string;
    approvedBy?: string;
    effectiveDate: string;
    changeReason: string;
    approvalDate?: string;
    status: string;
  }[];
  createdAt: string;
}

export interface DhEscalation {
  id: string;
  projectId: string;
  title: string;
  severity: DhPriority;
  ownerId: string;
  ownerName: string;
  deadline: string;
  status: "Open" | "In Progress" | "Resolved";
  comments: DhComment[];
  createdAt: string;
}

export interface DhAppreciation {
  id: string;
  projectId: string;
  toUserId: string;
  toName: string;
  fromName: string;
  badge: "Star Performer" | "Team Player" | "Innovator" | "Client Champion";
  note: string;
  at: string;
}

export type InterviewStatus = "Pending" | "Selected" | "Rejected" | "Postponed";

export interface DhInterview {
  id: string;
  projectId: string;
  resourceId: string;
  resourceName: string;
  employeeId: string;
  clientName: string;
  projectName: string;
  interviewDate: string;
  interviewTime: string;
  interviewRound: string;
  interviewer: string;
  notes: string;
  status: InterviewStatus;
  resourceResponse?: { text: string; at: string };
  history: { status: InterviewStatus; at: string; updatedBy: string }[];
}

export type RequirementStatus = "Open" | "Under Review" | "Approved" | "Rejected" | "Implemented";

export interface DhAdditionalRequirement {
  id: string;
  projectId: string;
  requirementId: string;
  clientName: string;
  projectName: string;
  title: string;
  description: string;
  priority: DhPriority;
  requestedBy: string;
  requestedDate: string;
  attachmentName?: string;
  scopeCancellationService?: string;
  status: RequirementStatus;
  comments: DhComment[];
  history: { status: RequirementStatus; at: string; updatedBy: string; updatedByName: string }[];
  createdAt: string;
}

export type PrereqStatus = "Validation Pending" | "Validated";
export type PrereqCollectionStatus = "Initiated" | "Waiting For Client Response" | "Received";

export interface DhServicePrereq {
  serviceId: string;
  serviceName: string;
  collectionStatus: "Pending To Collect" | "Collected";
  validationStatus: "Pending To Validate" | "Validated";
  billingStatus?: "Advance Received" | "Advance Pending" | "Advance Not Required";
}

export interface DhInvoice {
  id: string;
  projectId: string;
  milestone: string;
  invoiceTargetDate: string;
  unitPrice: number;
  qty: number;
  currency: string;
  invoiceAmount: number;
  invoiceStatus: "Not Raised" | "Raised";
  invoiceNumber: string;
  paymentStatus: "Not Received" | "Received";
  paymentReceivedDate: string;
  raisedBy?: string;
  raisedDate?: string;
  paymentReceivedBy?: string;
}

export interface DhAuditTrailEntry {
  id: string;
  fieldChanged: "Collection Status" | "Validation Status" | "Billing Status" | "Ready To Start" | "Extension Request";
  updatedBy: string;
  updatedByName: string;
  date: string;
  time: string;
  oldStatus: string;
  newStatus: string;
}

export interface DhProjectPrereq {
  projectId: string;
  validation: PrereqStatus;
  collection: PrereqCollectionStatus;
  assignedPmIds: string[];
  assignedSpmIds: string[];
  isProjectReadyToStart?: boolean; // True when all conditions met
  acknowledgedByPmIds?: string[]; // PMs who acknowledged the assignment
  acknowledgedBySpmIds?: string[]; // SPMs who acknowledged the assignment
  services?: DhServicePrereq[];
  auditTrail?: DhAuditTrailEntry[];
}

export function getSeededServices(isReady: boolean): DhServicePrereq[] {
  if (isReady) {
    return [
      { serviceId: "s1", serviceName: "Application Testing", collectionStatus: "Collected", validationStatus: "Validated", billingStatus: "Advance Received" },
      { serviceId: "s2", serviceName: "SOC", collectionStatus: "Collected", validationStatus: "Validated", billingStatus: "Advance Received" },
      { serviceId: "s3", serviceName: "Infrastructure", collectionStatus: "Collected", validationStatus: "Validated", billingStatus: "Advance Received" },
      { serviceId: "s4", serviceName: "Development", collectionStatus: "Collected", validationStatus: "Validated", billingStatus: "Advance Received" },
      { serviceId: "s5", serviceName: "Migration", collectionStatus: "Collected", validationStatus: "Validated", billingStatus: "Advance Received" },
    ];
  } else {
    return [
      { serviceId: "s1", serviceName: "Application Testing", collectionStatus: "Collected", validationStatus: "Validated", billingStatus: "Advance Pending" },
      { serviceId: "s2", serviceName: "SOC", collectionStatus: "Collected", validationStatus: "Pending To Validate", billingStatus: "Advance Pending" },
      { serviceId: "s3", serviceName: "Infrastructure", collectionStatus: "Pending To Collect", validationStatus: "Pending To Validate", billingStatus: "Advance Pending" },
      { serviceId: "s4", serviceName: "Development", collectionStatus: "Collected", validationStatus: "Validated", billingStatus: "Advance Pending" },
      { serviceId: "s5", serviceName: "Migration", collectionStatus: "Collected", validationStatus: "Validated", billingStatus: "Advance Pending" },
    ];
  }
}

// ---------- Project Stages Tracker (Dhanshree Role Only) ----------
export type SalesStatus = "Pending" | "Assigned" | "Approval";
export type PMOStatus = "Prerequisite Collection" | "Validation" | "Ready To Start Project";
export type DeliveryStatus = "Ongoing" | "Completed" | "Cancelled" | "On Hold Internally" | "On Hold Externally" | "After Release";
export type AccountsStatus = "PO Pending" | "PO Received" | "PO Raised" | "Invoice Not Raised" | "Invoice Raised" | "Payment Pending" | "Payment Received" | "PO Not Raised";
export type PoStatus = "PO Pending" | "PO Received" | "PO Validated";
export type PaymentStatus = "Payment Pending" | "Payment Received";

export interface AccountsDetail {
  poStatus: PoStatus;
  paymentStatus: PaymentStatus;
}

export interface StageHistoryEntry {
  id: string;
  timestamp: string;
  action: string;
  updatedBy: string;
  updatedByName: string;
  previousStatus?: string;
  newStatus: string;
}

export interface ProjectStageData {
  stageName: "Sales" | "PMO" | "Delivery" | "Accounts";
  currentStatus: SalesStatus | PMOStatus | DeliveryStatus | AccountsStatus;
  isCompleted: boolean;
  isActive: boolean;
  history: StageHistoryEntry[];
}

export interface ProjectStagesTracker {
  projectId: string;
  stages: {
    sales: ProjectStageData;
    pmo: ProjectStageData;
    delivery: ProjectStageData;
    accounts: ProjectStageData;
  };
  accountsDetail?: AccountsDetail;
}

// ---------- Resources Module (Dhanshree Role Only) ----------
export type ResignationStatus = "Pending" | "Accepted" | "Retain";

export interface OnboardedResource {
  employeeId: string;
  name: string;
  department: string;
  subDepartment: string;
  joiningDate: string;
  designation: string;
  currentProject?: string;
  status: "Active" | "Probation";
}

export interface OffboardingResource {
  employeeId: string;
  name: string;
  department: string;
  subDepartment: string;
  resignationDate: string;
  lastWorkingDate?: string;
  resignationStatus: ResignationStatus;
}

export interface ExitedResource {
  employeeId: string;
  personId: string;
}

export interface TaskAssignmentHistoryEntry {
  id: string;
  taskId: string;
  action: "Assign" | "Unassign" | "Reassign";
  resourceId: string;
  resourceName: string;
  teamType: "Project Team" | "Shadow Team";
  timestamp: string;
  updatedBy: string;
}

export interface TaskAssignmentState {
  taskId: string;
  assigneeIds: string[];
  history: TaskAssignmentHistoryEntry[];
}

// ---------- WBS Draft ----------
export interface WbsDraft {
  id: string;
  projectName: string;
  clientId: string;
  clientName: string;
  salesPerson: string;
  savedBy: string;       // user name who saved the draft
  savedAt: string;       // ISO timestamp
  // Full form state for restoration
  formSnapshot: Record<string, unknown>;
}

export interface DhNotification {
  id: string;
  title: string;
  type: string;
  relatedProject: string;
  relatedTask?: string;
  raisedBy: string;
  createdAt: string;
  status: "Pending" | "Acknowledged";
  priority: "Low" | "Medium" | "High" | "Critical";
  unread: boolean;
  acknowledgedBy?: string;
  acknowledgedDate?: string;
  acknowledgedTime?: string;
  createdBy: string;
  createdDate: string;
  history: {
    action: string;
    date: string;
    time: string;
    by: string;
  }[];
}

interface DhState {
  extraClients: Client[];
  extraProjects: Project[];
  subVentureOverrides: Record<string, string[]>;
  wbsDrafts: WbsDraft[];
  issues: DhIssue[];
  alerts: DhAlert[];
  escalations: DhEscalation[];
  appreciations: DhAppreciation[];
  interviews: DhInterview[];
  requirements: DhAdditionalRequirement[];
  prereqs: Record<string, DhProjectPrereq>;
  projectStages: Record<string, ProjectStagesTracker>;
  taskAssignments: Record<string, TaskAssignmentState>;
  shadowTeams: Record<string, string[]>;
  shadowTeamDetails: Record<string, Record<string, { duration: string; billability: Billability; resourceType: ResourceType }>>;
  projectTeamDetails: Record<string, Record<string, { duration: string; billability: Billability; resourceType: ResourceType }>>;
  projectTeamAdditions: Record<string, string[]>;
  leadershipChangeRequests: LeadershipChangeRequest[];
  leadershipAssignments: Record<string, { emIds: string[]; spmIds: string[]; pmIds: string[]; tlIds: string[] }>;
  timesheets: DhTimesheet[];
  approvals: DhCentralApproval[];
  onboardedResources: OnboardedResource[];
  offboardingResources: OffboardingResource[];
  exitedResources: ExitedResource[];
  invoices: DhInvoice[];
  notifications: DhNotification[];
}

// ---------- Singleton ----------
const listeners = new Set<() => void>();
// snapshot is a shallow copy of state, replaced on every emit() so that
// useSyncExternalStore sees a new reference and triggers re-renders.
let snapshot: DhState;
const state: DhState = {
  extraClients: [],
  extraProjects: [],
  subVentureOverrides: {},
  wbsDrafts: [],
  onboardedResources: [
    { employeeId: "EMP-0021", name: "Priya Sharma", department: "Engineering", subDepartment: "Frontend", joiningDate: "2026-05-12", designation: "Software Engineer", currentProject: "Core Banking Modernization", status: "Probation" },
    { employeeId: "EMP-0022", name: "Rohan Mehta", department: "QA", subDepartment: "Automation", joiningDate: "2026-05-20", designation: "QA Engineer", currentProject: "Mobile Banking App v3", status: "Probation" },
    { employeeId: "EMP-0023", name: "Sneha Iyer", department: "Engineering", subDepartment: "Backend", joiningDate: "2026-04-30", designation: "Senior Software Engineer", currentProject: "Clinical Data Platform", status: "Active" },
    { employeeId: "EMP-0024", name: "Karthik Bose", department: "DevOps", subDepartment: "Infrastructure", joiningDate: "2026-06-01", designation: "DevOps Engineer", status: "Probation" },
  ],
  offboardingResources: [
    { employeeId: "EMP-0008", name: "Rahul Sharma", department: "Engineering", subDepartment: "Backend", resignationDate: "2026-05-10", lastWorkingDate: "2026-06-10", resignationStatus: "Accepted" },
    { employeeId: "EMP-0012", name: "Anjali Nair", department: "QA", subDepartment: "Manual Testing", resignationDate: "2026-05-25", resignationStatus: "Pending" },
    { employeeId: "EMP-0015", name: "Vivek Tiwari", department: "Engineering", subDepartment: "Frontend", resignationDate: "2026-04-18", resignationStatus: "Retain" },
  ],
  exitedResources: [
    { employeeId: "EMP-0003", personId: "u15" },
  ],
  issues: [
    {
      id: "dhi1",
      title: "Skill mismatch on payments squad",
      description: "Frontend engineer assigned to Kafka work — slowing sprint.",
      projectId: "p1",
      raisedById: "u5",
      raisedByName: "Nikhil Rao",
      raisedByRole: "TL",
      category: "Technical Related Issues",
      priority: "High",
      status: "Open",
      createdAt: new Date(Date.now() - 86400000 * 2).toISOString(),
      comments: [],
      audit: [{ id: "ax1", text: "Raised issue", at: new Date(Date.now() - 86400000 * 2).toISOString() }],
    },
  ],
  alerts: [
    {
      id: "ALT-ESC-001",
      alertId: "ESC-001",
      title: "Client production environment access pending",
      kind: "Escalation",
      projectId: "p1",
      raisedByName: "Dhanshree",
      audienceUserIds: ["u14", "u1", "u3", "u11", "u12"],
      priority: "Critical",
      status: "Open",
      createdAt: new Date(Date.now() - 86400000 * 2).toISOString(),
      comments: [
        { id: "cm-esc1", authorId: "u14", authorName: "Dhanshree", text: "We need the credentials immediately to begin the WBS verification.", at: new Date(Date.now() - 86400000 * 2).toISOString() }
      ],
      description: "Prerequisites for testing cannot continue as the client has not shared the OAuth production credentials.",
      alertType: "Escalation",
      owner: "Dhanshree",
      resolutionOwner: "Vikram Shah",
      escalationOwner: "Anita Desai",
      resolutionDetails: "Awaiting response from Northwind Bank IT Security team.",
      attachments: ["client_security_email.png"],
      serviceName: "Application Testing",
      escalationType: "Prerequisite Pending",
      escalatedTo: ["Vikram Shah", "Aarav Mehta", "Anita Desai"],
      expectedResolutionDate: new Date(Date.now() + 86400000 * 3).toISOString().slice(0, 10),
      history: [
        { status: "Open", at: new Date(Date.now() - 86400000 * 2).toISOString(), updatedBy: "Dhanshree", details: "Escalation raised from WBS prerequisite collection." }
      ]
    },
    {
      id: "ALT-001",
      alertId: "ALT-001",
      title: "Critical database bottleneck in production migration",
      kind: "Issue",
      projectId: "p1",
      raisedByName: "Nikhil Rao",
      audienceUserIds: ["u14", "u1", "u3"],
      priority: "Critical",
      status: "Open",
      createdAt: new Date(Date.now() - 86400000 * 1).toISOString(),
      comments: [
        { id: "cm-alt1", authorId: "u5", authorName: "Nikhil Rao", text: "CPU spikes to 98% during payments reconciliation runs.", at: new Date(Date.now() - 86400000 * 1).toISOString() }
      ],
      description: "CPU utilization spikes to 98% during payments reconciliation runs on Kafka cluster.",
      alertType: "Technical Issue",
      owner: "Nikhil Rao",
      resolutionOwner: "Vikram Shah",
      escalationOwner: "Aarav Mehta",
      resolutionDetails: "Tuning JVM heap size and buffer allocations is under analysis.",
      attachments: ["db_reconcile_spikes.log", "heap_dump.png"],
      history: [
        { status: "Open", at: new Date(Date.now() - 86400000 * 1).toISOString(), updatedBy: "Nikhil Rao", details: "Alert raised dynamically." }
      ]
    },
    {
      id: "ALT-002",
      alertId: "ALT-002",
      title: "Resource constraint on iOS development team",
      kind: "Dependency",
      projectId: "p2",
      raisedByName: "Vikram Shah",
      audienceUserIds: ["u14", "u3"],
      priority: "High",
      status: "In Progress",
      createdAt: new Date(Date.now() - 86400000 * 3).toISOString(),
      comments: [],
      description: "iOS lead is on unplanned medical leave for 2 weeks, pausing biometric auth implementation.",
      alertType: "Resource Risk",
      owner: "Vikram Shah",
      resolutionOwner: "Riya Kapoor",
      escalationOwner: "Anita Desai",
      attachments: [],
      history: [
        { status: "Open", at: new Date(Date.now() - 86400000 * 3).toISOString(), updatedBy: "Vikram Shah" },
        { status: "In Progress", at: new Date(Date.now() - 86400000 * 2).toISOString(), updatedBy: "Riya Kapoor", details: "Assigning standby engineer on bench." }
      ]
    },
    {
      id: "ALT-003",
      alertId: "ALT-003",
      title: "Third-party vendor API delay blocker",
      kind: "Dependency",
      projectId: "p3",
      raisedByName: "Sana Iyer",
      audienceUserIds: ["u14", "u4"],
      priority: "Critical",
      status: "Open",
      createdAt: new Date(Date.now() - 86400000 * 4).toISOString(),
      comments: [],
      description: "Integration endpoints for sandbox environment have not been delivered by vendor.",
      alertType: "Dependency Blocker",
      owner: "Sana Iyer",
      resolutionOwner: "Riya Kapoor",
      escalationOwner: "Anita Desai",
      attachments: [],
      history: [
        { status: "Open", at: new Date(Date.now() - 86400000 * 4).toISOString(), updatedBy: "Sana Iyer" }
      ]
    },
    {
      id: "ALT-004",
      alertId: "ALT-004",
      title: "Budget slippage warning: cloud costs",
      kind: "Issue",
      projectId: "p9",
      raisedByName: "Vikram Shah",
      audienceUserIds: ["u14", "u3"],
      priority: "Medium",
      status: "Open",
      createdAt: new Date(Date.now() - 86400000 * 5).toISOString(),
      comments: [],
      description: "Snowflake query costs have exceeded the monthly threshold by 35% due to unoptimized queries.",
      alertType: "Budget Concern",
      owner: "Vikram Shah",
      resolutionOwner: "Vikram Shah",
      escalationOwner: "Rahul Gupta",
      attachments: [],
      history: [
        { status: "Open", at: new Date(Date.now() - 86400000 * 5).toISOString(), updatedBy: "Vikram Shah" }
      ]
    }
  ],
  escalations: [
    {
      id: "esc1",
      projectId: "p3",
      title: "Vendor data feed slip risking UAT",
      severity: "Critical",
      ownerId: "u2",
      ownerName: "Riya Kapoor",
      deadline: new Date(Date.now() + 86400000 * 7).toISOString().slice(0, 10),
      status: "In Progress",
      comments: [],
      createdAt: new Date(Date.now() - 86400000 * 3).toISOString(),
    },
  ],
  appreciations: [
    {
      id: "ap1",
      projectId: "p2",
      toUserId: "u9",
      toName: "Dev Patel",
      fromName: "Vikram Shah",
      badge: "Star Performer",
      note: "Owned the biometric auth rollout end-to-end.",
      at: new Date(Date.now() - 86400000 * 4).toISOString(),
    },
  ],
  interviews: [
    {
      id: "iv1",
      projectId: "p1",
      resourceId: "u7",
      resourceName: "Arjun Singh",
      employeeId: "ENG-007",
      clientName: "Northwind Bank",
      projectName: "Core Banking Modernization",
      interviewDate: new Date(Date.now() + 86400000 * 2).toISOString().slice(0, 10),
      interviewTime: "10:00 AM",
      interviewRound: "Technical Round 1",
      interviewer: "Client Architect",
      notes: "Backend engineer for payments service",
      status: "Pending",
      history: [],
    },
  ],
  requirements: [],
  prereqs: {
    p1: { projectId: "p1", validation: "Validated", collection: "Received", assignedPmIds: ["u3"], assignedSpmIds: ["u1"], isProjectReadyToStart: true, acknowledgedByPmIds: ["u3"], acknowledgedBySpmIds: ["u1"], services: getSeededServices(true), auditTrail: [] },
    p2: { projectId: "p2", validation: "Validated", collection: "Received", assignedPmIds: ["u3"], assignedSpmIds: [], isProjectReadyToStart: false, acknowledgedByPmIds: [], acknowledgedBySpmIds: [], services: getSeededServices(false), auditTrail: [] },
    p3: { projectId: "p3", validation: "Validation Pending", collection: "Waiting For Client Response", assignedPmIds: [], assignedSpmIds: [], isProjectReadyToStart: false, acknowledgedByPmIds: [], acknowledgedBySpmIds: [], services: getSeededServices(false), auditTrail: [] },
    p4: { projectId: "p4", validation: "Validation Pending", collection: "Initiated", assignedPmIds: [], assignedSpmIds: [], isProjectReadyToStart: false, acknowledgedByPmIds: [], acknowledgedBySpmIds: [], services: getSeededServices(false), auditTrail: [] },
    p5: { projectId: "p5", validation: "Validated", collection: "Received", assignedPmIds: ["u3"], assignedSpmIds: [], isProjectReadyToStart: false, acknowledgedByPmIds: [], acknowledgedBySpmIds: [], services: getSeededServices(false), auditTrail: [] },
    p6: { projectId: "p6", validation: "Validated", collection: "Received", assignedPmIds: ["u4"], assignedSpmIds: ["u1"], isProjectReadyToStart: true, acknowledgedByPmIds: ["u4"], acknowledgedBySpmIds: ["u1"], services: getSeededServices(true), auditTrail: [] },
    p7: { projectId: "p7", validation: "Validation Pending", collection: "Initiated", assignedPmIds: [], assignedSpmIds: [], isProjectReadyToStart: false, acknowledgedByPmIds: [], acknowledgedBySpmIds: [], services: getSeededServices(false), auditTrail: [] },
    p8: { projectId: "p8", validation: "Validated", collection: "Received", assignedPmIds: ["u4"], assignedSpmIds: [], isProjectReadyToStart: false, acknowledgedByPmIds: [], acknowledgedBySpmIds: [], services: getSeededServices(false), auditTrail: [] },
    p9: { projectId: "p9", validation: "Validation Pending", collection: "Initiated", assignedPmIds: [], assignedSpmIds: [], isProjectReadyToStart: false, acknowledgedByPmIds: [], acknowledgedBySpmIds: [], services: getSeededServices(false), auditTrail: [] },
  },
  projectStages: {
    p1: {
      projectId: "p1",
      stages: {
        sales: {
          stageName: "Sales", currentStatus: "Approval", isCompleted: true, isActive: false, history: [
            { id: "sh1", timestamp: new Date(Date.now() - 86400000 * 30).toISOString(), action: "Project created", updatedBy: "u11", updatedByName: "Dhanshree", newStatus: "Pending" },
            { id: "sh2", timestamp: new Date(Date.now() - 86400000 * 28).toISOString(), action: "Sales assigned", updatedBy: "u11", updatedByName: "Dhanshree", previousStatus: "Pending", newStatus: "Assigned" },
            { id: "sh3", timestamp: new Date(Date.now() - 86400000 * 25).toISOString(), action: "Approval submitted", updatedBy: "u1", updatedByName: "Sana", previousStatus: "Assigned", newStatus: "Approval" },
          ]
        },
        pmo: {
          stageName: "PMO", currentStatus: "Ready To Start Project", isCompleted: true, isActive: false, history: [
            { id: "sh4", timestamp: new Date(Date.now() - 86400000 * 24).toISOString(), action: "Prerequisite collection started", updatedBy: "u3", updatedByName: "Vikram Shah", newStatus: "Prerequisite Collection" },
            { id: "sh5", timestamp: new Date(Date.now() - 86400000 * 15).toISOString(), action: "Validation in progress", updatedBy: "u8", updatedByName: "Engagement Manager", previousStatus: "Prerequisite Collection", newStatus: "Validation" },
            { id: "sh6", timestamp: new Date(Date.now() - 86400000 * 7).toISOString(), action: "PM/SPM assigned", updatedBy: "u11", updatedByName: "Dhanshree", previousStatus: "Validation", newStatus: "Ready To Start Project" },
          ]
        },
        delivery: {
          stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: true, history: [
            { id: "sh7", timestamp: new Date(Date.now() - 86400000 * 6).toISOString(), action: "Delivery started", updatedBy: "u3", updatedByName: "Vikram Shah", newStatus: "Ongoing" },
          ]
        },
        accounts: {
          stageName: "Accounts", currentStatus: "PO Raised", isCompleted: false, isActive: false, history: [
            { id: "sh8", timestamp: new Date(Date.now() - 86400000 * 8).toISOString(), action: "PO raised by client", updatedBy: "u15", updatedByName: "Accounts", newStatus: "PO Raised" },
          ]
        },
      },
      accountsDetail: { poStatus: "PO Received", paymentStatus: "Payment Pending" },
    },
    p2: {
      projectId: "p2",
      stages: {
        sales: { stageName: "Sales", currentStatus: "Approval", isCompleted: true, isActive: false, history: [] },
        pmo: { stageName: "PMO", currentStatus: "Ready To Start Project", isCompleted: true, isActive: false, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: true, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "Invoice Raised", isCompleted: false, isActive: false, history: [] },
      },
      accountsDetail: { poStatus: "PO Validated", paymentStatus: "Payment Received" },
    },
    p3: {
      projectId: "p3",
      stages: {
        sales: { stageName: "Sales", currentStatus: "Assigned", isCompleted: false, isActive: true, history: [] },
        pmo: { stageName: "PMO", currentStatus: "Prerequisite Collection", isCompleted: false, isActive: true, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "PO Not Raised", isCompleted: false, isActive: false, history: [] },
      },
    },
    p4: {
      projectId: "p4",
      stages: {
        sales: { stageName: "Sales", currentStatus: "Pending", isCompleted: false, isActive: true, history: [] },
        pmo: { stageName: "PMO", currentStatus: "Prerequisite Collection", isCompleted: false, isActive: false, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "PO Not Raised", isCompleted: false, isActive: false, history: [] },
      },
    },
    p5: {
      projectId: "p5",
      stages: {
        sales: { stageName: "Sales", currentStatus: "Approval", isCompleted: true, isActive: false, history: [] },
        pmo: { stageName: "PMO", currentStatus: "Validation", isCompleted: false, isActive: true, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "Invoice Not Raised", isCompleted: false, isActive: false, history: [] },
      },
    },
    p6: {
      projectId: "p6",
      stages: {
        sales: { stageName: "Sales", currentStatus: "Approval", isCompleted: true, isActive: false, history: [] },
        pmo: { stageName: "PMO", currentStatus: "Ready To Start Project", isCompleted: true, isActive: false, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Completed", isCompleted: true, isActive: false, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "Invoice Raised", isCompleted: false, isActive: true, history: [] },
      },
    },
    p7: {
      projectId: "p7",
      stages: {
        sales: { stageName: "Sales", currentStatus: "Assigned", isCompleted: false, isActive: true, history: [] },
        pmo: { stageName: "PMO", currentStatus: "Prerequisite Collection", isCompleted: false, isActive: true, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "PO Not Raised", isCompleted: false, isActive: false, history: [] },
      },
    },
    p8: {
      projectId: "p8",
      stages: {
        sales: { stageName: "Sales", currentStatus: "Approval", isCompleted: true, isActive: false, history: [] },
        pmo: { stageName: "PMO", currentStatus: "Validation", isCompleted: false, isActive: true, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "PO Raised", isCompleted: false, isActive: false, history: [] },
      },
    },
    p9: {
      projectId: "p9",
      stages: {
        sales: { stageName: "Sales", currentStatus: "Pending", isCompleted: false, isActive: true, history: [] },
        pmo: { stageName: "PMO", currentStatus: "Prerequisite Collection", isCompleted: false, isActive: true, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "PO Not Raised", isCompleted: false, isActive: false, history: [] },
      },
    },
  },
  taskAssignments: {},
  shadowTeams: {
    p1: ["u9"],
    p3: ["u6", "u10"],
    p5: ["u5"],
  },
  shadowTeamDetails: {
    p1: {
      u9: { duration: "02/01/2026 → 08/30/2026", billability: "Non-Billable", resourceType: "Shared Resource" }
    },
    p3: {
      u6: { duration: "03/01/2026 → 09/15/2026", billability: "Non-Billable", resourceType: "Shared Resource" },
      u10: { duration: "03/01/2026 → 09/15/2026", billability: "Non-Billable", resourceType: "Shared Resource" }
    },
    p5: {
      u5: { duration: "01/20/2026 → 08/10/2026", billability: "Non-Billable", resourceType: "Shared Resource" }
    }
  },
  projectTeamDetails: {},
  projectTeamAdditions: {},
  leadershipChangeRequests: [],
  leadershipAssignments: {},
  timesheets: baseTimesheets.map(t => ({
    ...t,
    comments: t.rejectionReason ? [{
      id: `init-c-${t.id}`,
      authorId: "u11", // PMO
      authorName: "Rahul Gupta",
      text: t.rejectionReason,
      at: t.submittedAt || new Date().toISOString()
    }] : [],
    history: [
      {
        status: "submitted",
        at: t.submittedAt || new Date().toISOString(),
        updatedBy: getPerson(t.userId)?.name || "Employee",
        comment: "Initial submission"
      },
      ...(t.status === "approved" || t.status === "rejected" ? [{
        status: t.status,
        at: new Date().toISOString(),
        updatedBy: "Rahul Gupta",
        comment: t.rejectionReason || "Approved"
      }] : [])
    ]
  })),
  approvals: [
    {
      id: "APP-001",
      projectId: "p1",
      projectName: "Core Banking Modernization",
      requestType: "WBS Approval",
      requestedBy: "Aarav Mehta",
      requestedById: "u1",
      requestedDate: "2026-05-28",
      status: "Pending",
      description: "Approve WBS revision for Open Banking API Gateway integration. Estimated budget is $1,200,000.",
      comments: [],
      history: []
    },
    {
      id: "APP-002",
      projectId: "p1",
      projectName: "Core Banking Modernization",
      requestType: "Budget Approval",
      requestedBy: "Vikram Shah",
      requestedById: "u3",
      requestedDate: "2026-05-29",
      status: "Pending",
      description: "Requesting additional budget allocation of $150,000 for infrastructure scaling under the Core Banking project.",
      comments: [],
      history: []
    },
    {
      id: "APP-003",
      projectId: "p3",
      projectName: "Clinical Data Platform",
      requestType: "Resource Allocation Approval",
      requestedBy: "Sana Iyer",
      requestedById: "u4",
      requestedDate: "2026-05-30",
      status: "Pending",
      description: "Allocate Arjun Singh (Engineer) to Clinical Data Platform. Required for API development.",
      comments: [],
      history: []
    },
    {
      id: "APP-004",
      projectId: "p2",
      projectName: "Mobile Banking App v3",
      requestType: "Project Ready To Start Approval",
      requestedBy: "Vikram Shah",
      requestedById: "u3",
      requestedDate: "2026-05-30",
      status: "Pending",
      description: "All validation pre-requisites are met for Mobile Banking App v3. Requesting project kick-off approval.",
      comments: [],
      history: []
    },
    {
      id: "APP-005",
      projectId: "p1",
      projectName: "Core Banking Modernization",
      requestType: "PM Assignment Approval",
      requestedBy: "Riya Kapoor",
      requestedById: "u2",
      requestedDate: "2026-05-31",
      status: "Pending",
      description: "Assign Vikram Shah as Project Manager for the Core Banking project.",
      comments: [],
      history: []
    }
  ],
  invoices: baseInvoices.map((inv, idx) => {
    let invStatus: "Not Raised" | "Raised" = "Not Raised";
    let payStatus: "Not Received" | "Received" = "Not Received";

    if (inv.status === "paid" || inv.status === "raised") {
      invStatus = "Raised";
    }
    if (inv.status === "paid" || inv.paymentStatus === "completed") {
      payStatus = "Received";
    }

    let milestone = `Milestone ${idx + 1}`;
    let invoiceTargetDate = inv.raisedOn || "2026-06-12";

    if (inv.projectId === "p1") {
      milestone = idx === 0 ? "Advance 70%" : "Final Delivery 30%";
      invoiceTargetDate = idx === 0 ? "02 Feb 2026" : "01 Sep 2026";
    } else if (inv.projectId === "p2") {
      milestone = idx === 0 ? "Advance 70%" : "Final Delivery 30%";
      invoiceTargetDate = idx === 0 ? "15 Jan 2026" : "30 Jun 2026";
    }

    return {
      id: `inv-${idx}`,
      projectId: inv.projectId,
      milestone,
      invoiceTargetDate,
      unitPrice: inv.unitPrice,
      qty: inv.qty,
      currency: inv.currency,
      invoiceAmount: inv.invoiceAmount,
      invoiceStatus: invStatus,
      invoiceNumber: invStatus === "Raised" ? `INV-2026-${String(idx + 1).padStart(3, '0')}` : "",
      paymentStatus: payStatus,
      paymentReceivedDate: inv.paymentReceivedDate ? new Date(inv.paymentReceivedDate).toLocaleDateString("en-GB", {
        day: "2-digit",
        month: "short",
        year: "numeric"
      }).replace(/ /g, '-') : "",
      raisedBy: invStatus === "Raised" ? "Dhanshree" : undefined,
      raisedDate: invStatus === "Raised" ? inv.raisedOn : undefined,
      paymentReceivedBy: payStatus === "Received" ? "Accounts" : undefined
    };
  }),
  notifications: [
    {
      id: "notif1",
      title: "Project Intake completed for Core Banking Modernization",
      type: "Project Ready To Start",
      relatedProject: "Core Banking Modernization",
      raisedBy: "Vikram Shah",
      createdAt: new Date(Date.now() - 3600000 * 2).toISOString(),
      status: "Pending",
      priority: "High",
      unread: true,
      createdBy: "Vikram Shah",
      createdDate: new Date(Date.now() - 3600000 * 2).toISOString().slice(0, 10),
      history: [{ action: "Notification created", date: new Date(Date.now() - 3600000 * 2).toISOString().slice(0, 10), time: new Date(Date.now() - 3600000 * 2).toTimeString().slice(0, 8), by: "Vikram Shah" }]
    },
    {
      id: "notif2",
      title: "Assigned task 'API Gateway setup' to Dev Patel",
      type: "New Task Assignment",
      relatedProject: "Core Banking Modernization",
      raisedBy: "Nikhil Rao",
      createdAt: new Date(Date.now() - 3600000 * 4).toISOString(),
      status: "Pending",
      priority: "Medium",
      unread: true,
      createdBy: "Nikhil Rao",
      createdDate: new Date(Date.now() - 3600000 * 4).toISOString().slice(0, 10),
      history: [{ action: "Notification created", date: new Date(Date.now() - 3600000 * 4).toISOString().slice(0, 10), time: new Date(Date.now() - 3600000 * 4).toTimeString().slice(0, 8), by: "Nikhil Rao" }]
    },
    {
      id: "notif3",
      title: "Arjun Singh selected for Northwind Client Interview",
      type: "Client Interview Selected",
      relatedProject: "Core Banking Modernization",
      raisedBy: "Riya Kapoor",
      createdAt: new Date(Date.now() - 86400000).toISOString(),
      status: "Pending",
      priority: "High",
      unread: true,
      createdBy: "Riya Kapoor",
      createdDate: new Date(Date.now() - 86400000).toISOString().slice(0, 10),
      history: [{ action: "Notification created", date: new Date(Date.now() - 86400000).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000).toTimeString().slice(0, 8), by: "Riya Kapoor" }]
    },
    {
      id: "notif4",
      title: "Dev Patel assigned to Core Banking Modernization shadow team",
      type: "Shadow Team Assignment",
      relatedProject: "Core Banking Modernization",
      raisedBy: "Rahul Gupta",
      createdAt: new Date(Date.now() - 86400000 * 2).toISOString(),
      status: "Pending",
      priority: "Low",
      unread: true,
      createdBy: "Rahul Gupta",
      createdDate: new Date(Date.now() - 86400000 * 2).toISOString().slice(0, 10),
      history: [{ action: "Notification created", date: new Date(Date.now() - 86400000 * 2).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 2).toTimeString().slice(0, 8), by: "Rahul Gupta" }]
    },
    {
      id: "notif5",
      title: "Timesheet rejected for Riya Kapoor for week ending 2026-05-10",
      type: "Timesheet Rejected",
      relatedProject: "Clinical Data Platform",
      raisedBy: "Rahul Gupta",
      createdAt: new Date(Date.now() - 86400000 * 3).toISOString(),
      status: "Pending",
      priority: "High",
      unread: true,
      createdBy: "Rahul Gupta",
      createdDate: new Date(Date.now() - 86400000 * 3).toISOString().slice(0, 10),
      history: [{ action: "Notification created", date: new Date(Date.now() - 86400000 * 3).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 3).toTimeString().slice(0, 8), by: "Rahul Gupta" }]
    },
    {
      id: "notif6",
      title: "WBS template assigned to Mobile Banking App v3",
      type: "WBS Assignment",
      relatedProject: "Mobile Banking App v3",
      raisedBy: "Dhanshree",
      createdAt: new Date(Date.now() - 86400000 * 4).toISOString(),
      status: "Acknowledged",
      priority: "Medium",
      unread: false,
      acknowledgedBy: "Dhanshree",
      acknowledgedDate: new Date(Date.now() - 86400000 * 4 + 3600000).toISOString().slice(0, 10),
      acknowledgedTime: new Date(Date.now() - 86400000 * 4 + 3600000).toTimeString().slice(0, 8),
      createdBy: "Dhanshree",
      createdDate: new Date(Date.now() - 86400000 * 4).toISOString().slice(0, 10),
      history: [
        { action: "Notification created", date: new Date(Date.now() - 86400000 * 4).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 4).toTimeString().slice(0, 8), by: "Dhanshree" },
        { action: "Notification acknowledged - Remarks: \"WBS checked.\"", date: new Date(Date.now() - 86400000 * 4 + 3600000).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 4 + 3600000).toTimeString().slice(0, 8), by: "Dhanshree" }
      ]
    },
    {
      id: "notif7",
      title: "New project 'Mobile Banking App v3' created and assigned",
      type: "New Project Assignment",
      relatedProject: "Mobile Banking App v3",
      raisedBy: "Rakesh Menon",
      createdAt: new Date(Date.now() - 86400000 * 5).toISOString(),
      status: "Acknowledged",
      priority: "Critical",
      unread: false,
      acknowledgedBy: "Dhanshree",
      acknowledgedDate: new Date(Date.now() - 86400000 * 5 + 3600000).toISOString().slice(0, 10),
      acknowledgedTime: new Date(Date.now() - 86400000 * 5 + 3600000).toTimeString().slice(0, 8),
      createdBy: "Rakesh Menon",
      createdDate: new Date(Date.now() - 86400000 * 5).toISOString().slice(0, 10),
      history: [
        { action: "Notification created", date: new Date(Date.now() - 86400000 * 5).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 5).toTimeString().slice(0, 8), by: "Rakesh Menon" },
        { action: "Notification acknowledged - Remarks: \"Project initialized.\"", date: new Date(Date.now() - 86400000 * 5 + 3600000).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 5 + 3600000).toTimeString().slice(0, 8), by: "Dhanshree" }
      ]
    },
    {
      id: "notif8",
      title: "Team allocated for Clinical Data Platform project",
      type: "Team Assignment",
      relatedProject: "Clinical Data Platform",
      raisedBy: "Sana Iyer",
      createdAt: new Date(Date.now() - 86400000 * 6).toISOString(),
      status: "Acknowledged",
      priority: "Medium",
      unread: false,
      acknowledgedBy: "Dhanshree",
      acknowledgedDate: new Date(Date.now() - 86400000 * 6 + 3600000).toISOString().slice(0, 10),
      acknowledgedTime: new Date(Date.now() - 86400000 * 6 + 3600000).toTimeString().slice(0, 8),
      createdBy: "Sana Iyer",
      createdDate: new Date(Date.now() - 86400000 * 6).toISOString().slice(0, 10),
      history: [
        { action: "Notification created", date: new Date(Date.now() - 86400000 * 6).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 6).toTimeString().slice(0, 8), by: "Sana Iyer" },
        { action: "Notification acknowledged - Remarks: \"Allocation approved.\"", date: new Date(Date.now() - 86400000 * 6 + 3600000).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 6 + 3600000).toTimeString().slice(0, 8), by: "Dhanshree" }
      ]
    },
    {
      id: "notif9",
      title: "Star Performer badge awarded to Dev Patel",
      type: "Appreciation Received",
      relatedProject: "Mobile Banking App v3",
      raisedBy: "Vikram Shah",
      createdAt: new Date(Date.now() - 86400000 * 7).toISOString(),
      status: "Acknowledged",
      priority: "Low",
      unread: false,
      acknowledgedBy: "Dhanshree",
      acknowledgedDate: new Date(Date.now() - 86400000 * 7 + 3600000).toISOString().slice(0, 10),
      acknowledgedTime: new Date(Date.now() - 86400000 * 7 + 3600000).toTimeString().slice(0, 8),
      createdBy: "Vikram Shah",
      createdDate: new Date(Date.now() - 86400000 * 7).toISOString().slice(0, 10),
      history: [
        { action: "Notification created", date: new Date(Date.now() - 86400000 * 7).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 7).toTimeString().slice(0, 8), by: "Vikram Shah" },
        { action: "Notification acknowledged - Remarks: \"Well done!\"", date: new Date(Date.now() - 86400000 * 7 + 3600000).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 7 + 3600000).toTimeString().slice(0, 8), by: "Dhanshree" }
      ]
    },
    {
      id: "notif10",
      title: "Issue 'Skill mismatch on payments squad' resolved",
      type: "Issue Resolved",
      relatedProject: "Core Banking Modernization",
      raisedBy: "Nikhil Rao",
      createdAt: new Date(Date.now() - 86400000 * 8).toISOString(),
      status: "Acknowledged",
      priority: "High",
      unread: false,
      acknowledgedBy: "Dhanshree",
      acknowledgedDate: new Date(Date.now() - 86400000 * 8 + 3600000).toISOString().slice(0, 10),
      acknowledgedTime: new Date(Date.now() - 86400000 * 8 + 3600000).toTimeString().slice(0, 8),
      createdBy: "Nikhil Rao",
      createdDate: new Date(Date.now() - 86400000 * 8).toISOString().slice(0, 10),
      history: [
        { action: "Notification created", date: new Date(Date.now() - 86400000 * 8).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 8).toTimeString().slice(0, 8), by: "Nikhil Rao" },
        { action: "Notification acknowledged - Remarks: \"Issue closed.\"", date: new Date(Date.now() - 86400000 * 8 + 3600000).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 8 + 3600000).toTimeString().slice(0, 8), by: "Dhanshree" }
      ]
    },
    {
      id: "notif11",
      title: "Timesheet approved for Aarav Mehta for week ending 2026-05-10",
      type: "Timesheet Approved",
      relatedProject: "Core Banking Modernization",
      raisedBy: "Rahul Gupta",
      createdAt: new Date(Date.now() - 86400000 * 9).toISOString(),
      status: "Acknowledged",
      priority: "Low",
      unread: false,
      acknowledgedBy: "Dhanshree",
      acknowledgedDate: new Date(Date.now() - 86400000 * 9 + 3600000).toISOString().slice(0, 10),
      acknowledgedTime: new Date(Date.now() - 86400000 * 9 + 3600000).toTimeString().slice(0, 8),
      createdBy: "Rahul Gupta",
      createdDate: new Date(Date.now() - 86400000 * 9).toISOString().slice(0, 10),
      history: [
        { action: "Notification created", date: new Date(Date.now() - 86400000 * 9).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 9).toTimeString().slice(0, 8), by: "Rahul Gupta" },
        { action: "Notification acknowledged - Remarks: \"Approved by PMO.\"", date: new Date(Date.now() - 86400000 * 9 + 3600000).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 9 + 3600000).toTimeString().slice(0, 8), by: "Dhanshree" }
      ]
    },
    {
      id: "notif12",
      title: "Prerequisite validation approval requested for Helix Pharma",
      type: "Approval Request",
      relatedProject: "Clinical Data Platform",
      raisedBy: "Sana Iyer",
      createdAt: new Date(Date.now() - 86400000 * 10).toISOString(),
      status: "Acknowledged",
      priority: "High",
      unread: false,
      acknowledgedBy: "Dhanshree",
      acknowledgedDate: new Date(Date.now() - 86400000 * 10 + 3600000).toISOString().slice(0, 10),
      acknowledgedTime: new Date(Date.now() - 86400000 * 10 + 3600000).toTimeString().slice(0, 8),
      createdBy: "Sana Iyer",
      createdDate: new Date(Date.now() - 86400000 * 10).toISOString().slice(0, 10),
      history: [
        { action: "Notification created", date: new Date(Date.now() - 86400000 * 10).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 10).toTimeString().slice(0, 8), by: "Sana Iyer" },
        { action: "Notification acknowledged - Remarks: \"Validation verified.\"", date: new Date(Date.now() - 86400000 * 10 + 3600000).toISOString().slice(0, 10), time: new Date(Date.now() - 86400000 * 10 + 3600000).toTimeString().slice(0, 8), by: "Dhanshree" }
      ]
    }
  ]
};

state.notifications.forEach((n, idx) => {
  const num = state.notifications.length - idx;
  n.id = `NTF-${String(num).padStart(3, '0')}`;
});

// Initialise snapshot after state definition
snapshot = { ...state };

function emit() {
  // Replace snapshot with a new shallow copy so useSyncExternalStore detects change
  snapshot = { ...state };
  listeners.forEach((l) => l());
}
function subscribe(l: () => void) {
  listeners.add(l);
  return () => listeners.delete(l);
}

// ---------- Selectors ----------
export function allClients(): Client[] {
  // Merge base clients with any runtime sub-venture additions — no duplication
  const merged = baseClients.map((c) => {
    const extra = state.subVentureOverrides[c.id];
    if (!extra || extra.length === 0) return c;
    return { ...c, subVentures: [...(c.subVentures ?? []), ...extra] };
  });
  return [...merged, ...state.extraClients];
}
export function allProjects(): Project[] {
  return [...baseProjects, ...state.extraProjects];
}
export function findProject(id: string): Project | undefined {
  return allProjects().find((p) => p.id === id);
}
export function findClient(id: string): Client | undefined {
  return allClients().find((c) => c.id === id);
}

// ---------- Actions ----------
let counter = 1;
const uid = (prefix: string) => `${prefix}${Date.now()}${counter++}`;

// Financial year runs April 1 → March 31.
// Returns the FY start year: e.g. April 2026–March 2027 → 2026
function getCurrentFYStart(): number {
  const now = new Date();
  return now.getMonth() >= 3 ? now.getFullYear() : now.getFullYear() - 1;
}

// FY start date as a comparable string "YYYY-04-01"
function getFYStartDate(fyStartYear: number): string {
  return `${fyStartYear}-04-01`;
}

// Next client sequential number → padded to 3 digits with "C" prefix e.g. "C011"
function getNextClientSeqId(): string {
  const n = allClients().length + 1;
  return "C" + String(n).padStart(3, "0");
}

// FY helper: given a date string, return which FY it belongs to (start year)
function getFYStartForDate(dateIso: string): number {
  const d = new Date(dateIso);
  const month = d.getMonth(); // 0=Jan, 3=Apr
  return month >= 3 ? d.getFullYear() : d.getFullYear() - 1;
}

// Next project sequential number → padded to 3 digits with "P" prefix e.g. "P001"
// Global across ALL clients, resets each financial year (April 1).
// Only counts projects that have an ASSIGNED wbsId in this FY — not all projects by startDate.
function getNextProjectSeqNum(): string {
  const fyStartYear = getCurrentFYStart();
  const fyPrefix = `IN-${fyStartYear}-${String(fyStartYear + 1).slice(-2)}-`;
  // Count base projects with a wbsId belonging to this FY
  const baseCount = baseProjects.filter((p) => p.wbsId?.startsWith(fyPrefix)).length;
  // Count extra projects created this FY (they always get wbsId on creation)
  const fyStart = getFYStartDate(fyStartYear);
  const fyEnd = getFYStartDate(fyStartYear + 1);
  const extraCount = state.extraProjects.filter((p) => {
    const d = p.projectIssuedDate ?? p.startDate ?? "";
    return d >= fyStart && d < fyEnd;
  }).length;
  return "P" + String(baseCount + extraCount + 1).padStart(3, "0");
}

// Build WBS ID: IN-YYYY-YY-CLIENTID-PROJECTID
// e.g. IN-2026-27-C011-P005
// - FY derived from today's date (April 1 boundary)
// - ClientID = position of client in allClients() padded to 3 digits with "C" prefix
// - ProjectID = global sequential count within this FY across all clients
export function buildWbsId(clientId: string): string {
  const fyStartYear = getCurrentFYStart();
  const fyEnd = String(fyStartYear + 1).slice(-2); // last 2 digits of next year
  const clientIdx = allClients().findIndex((c) => c.id === clientId);
  const paddedClientId = "C" + String(clientIdx + 1).padStart(3, "0");
  const projSeq = getNextProjectSeqNum();
  return `IN-${fyStartYear}-${fyEnd}-${paddedClientId}-${projSeq}`;
}

// Build the display Project ID: P001, P002… (FY-scoped)
export function buildProjectDisplayId(): string {
  return getNextProjectSeqNum();
}

export const dhStore = {
  addClient(input: Omit<Client, "id" | "logo"> & { logo?: string }) {
    const id = getNextClientSeqId();
    const logo = (input.logo ?? input.name.slice(0, 2)).toUpperCase();
    const c: Client = {
      id,
      name: input.name,
      industry: input.industry,
      contact: input.contact,
      logo,
      engagementManager: input.engagementManager,
      companyName: input.companyName,
      // If a sub-venture name was provided during onboarding, seed subVentures with it
      subVentures: input.companyName?.trim()
        ? [...(input.subVentures ?? []), input.companyName.trim()]
        : (input.subVentures ?? []),
    };
    state.extraClients.push(c);
    emit();
    return c;
  },

  // Add a new sub-venture name to an existing client's subVentures list
  addSubVenture(clientId: string, subVentureName: string) {
    const trimmed = subVentureName.trim();
    if (!trimmed) return;
    // For extra clients created at runtime, mutate directly
    const extra = state.extraClients.find((c) => c.id === clientId);
    if (extra) {
      extra.subVentures = [...(extra.subVentures ?? []), trimmed];
      emit();
      return;
    }
    // For base clients, store additions in subVentureOverrides — no duplicate client entries
    state.subVentureOverrides[clientId] = [
      ...(state.subVentureOverrides[clientId] ?? []),
      trimmed,
    ];
    emit();
  },
  // ── WBS Drafts ──
  saveDraft(draft: Omit<WbsDraft, "id">) {
    const id = uid("draft");
    // If a draft for the same projectName + clientId exists, overwrite it
    const idx = state.wbsDrafts.findIndex(
      (d) => d.projectName === draft.projectName && d.clientId === draft.clientId
    );
    const entry: WbsDraft = { ...draft, id };
    if (idx >= 0) state.wbsDrafts[idx] = entry;
    else state.wbsDrafts.unshift(entry);
    emit();
    return entry;
  },
  deleteDraft(draftId: string) {
    state.wbsDrafts = state.wbsDrafts.filter((d) => d.id !== draftId);
    emit();
  },

  addProject(input: {
    name: string;
    clientId: string;
    description: string;
    startDate: string;
    endDate: string;
    budget: number;
    wbsDetails?: any;
    wbsStatus?: "draft" | "approval_pending" | "ph_approved" | "accounts_approved" | "approved" | "started" | "assigned";
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
  }) {
    const id = uid("p");
    const seqId = getNextProjectSeqNum();
    const wbsAutoId = buildWbsId(input.clientId);
    const now = new Date().toISOString();

    // Auto-generate one task per WBS service row with real data
    const autoTasks: any[] = [];
    if (input.wbsDetails?.services) {
      input.wbsDetails.services.forEach((svc: any) => {
        autoTasks.push({
          id: `${id}-svc-${svc.id}`,
          title: svc.serviceName || svc.department,
          status: "todo" as const,
          assigneeId: "u3",
          dueDate: svc.endDate || input.endDate,
          progress: 0,
          serviceId: svc.id,
          wbsStartDate: svc.startDate,
          wbsEndDate: svc.endDate,
          estimatedHours: svc.totalHrs ?? (svc.totalDays ? svc.totalDays * 8 : svc.duration * 8),
          stage: "Not Started" as const,
        });
      });
    }

    const p: Project = {
      id,
      name: input.name,
      clientId: input.clientId,
      status: "ongoing",
      health: "green",
      progress: 0,
      pmId: "u3",
      tlId: "u5",
      teamIds: [],
      startDate: input.startDate,
      endDate: input.endDate,
      budget: input.budget,
      spent: 0,
      description: input.description,
      wbs: [],
      wbsDetails: input.wbsDetails,
      tasks: autoTasks,
      wbsStatus: input.wbsStatus ?? "draft",
      wbsSubStatus: input.wbsSubStatus ?? "Draft",
      engagementManager: input.engagementManager,
      salesPerson: input.salesPerson,
      contractType: input.contractType,
      projectType: input.projectType,
      projectIssuedDate: input.projectIssuedDate,
      currency: input.currency,
      taxPercent: input.taxPercent,
      totalHours: input.totalHours,
      totalDays: input.totalDays,
      invoiceValue: input.invoiceValue,
      sectionAComments: input.sectionAComments,
      sectionBComments: input.sectionBComments,
      projectSeqId: seqId,
      wbsId: wbsAutoId,
    };
    state.extraProjects.push(p);

    // Initialize stage tracker
    // "Create WBS" always sets sales stage to "Assigned" — the WBS has been
    // created and handed over by the sales person. "Approval" is only set when
    // explicitly sent for approval (approval_pending).
    const initialSalesStatus: SalesStatus =
      input.wbsStatus === "approval_pending" ? "Approval" : "Assigned";

    state.projectStages[id] = {
      projectId: id,
      stages: {
        sales: {
          stageName: "Sales",
          currentStatus: initialSalesStatus,
          isCompleted: initialSalesStatus === "Assigned",
          isActive: true,
          history: [{ id: uid("sh"), timestamp: now, action: "WBS created via WBS Form", updatedBy: "u14", updatedByName: "Dhanshree", newStatus: initialSalesStatus }],
        },
        pmo: { stageName: "PMO", currentStatus: "Prerequisite Collection", isCompleted: false, isActive: false, history: [] },
        delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
        accounts: { stageName: "Accounts", currentStatus: "PO Not Raised", isCompleted: false, isActive: false, history: [] },
      },
    };

    // Initialize prerequisite record — seed services from WBS so the
    // Service-wise Prerequisite Tracking table shows real service names
    const prereqServices: DhServicePrereq[] = input.wbsDetails?.services?.map((svc: any, i: number) => ({
      serviceId: svc.id ?? `svc-${i}`,
      serviceName: svc.serviceName ?? svc.department ?? `Service ${i + 1}`,
      collectionStatus: "Pending To Collect" as const,
      validationStatus: "Pending To Validate" as const,
      billingStatus: "Advance Pending" as const,
    })) ?? [];

    state.prereqs[id] = {
      projectId: id,
      validation: "Validation Pending",
      collection: "Initiated",
      assignedPmIds: [],
      assignedSpmIds: [],
      services: prereqServices,
      auditTrail: [],
    };

    // Create approval record if sent for approval
    if (input.wbsStatus === "approval_pending") {
      state.approvals.unshift({
        id: uid("APP"),
        projectId: id,
        projectName: input.name,
        requestType: "WBS Approval",
        requestedBy: "Dhanshree",
        requestedById: "u14",
        requestedDate: now.slice(0, 10),
        status: "Pending",
        description: `WBS Approval requested for project "${input.name}". Contract: ${input.contractType || "N/A"}. Project Value: ${input.currency || "INR"} ${(input.budget || 0).toLocaleString()}.`,
        comments: [],
        history: [],
      });
    }

    emit();
    return p;
  },

  raiseIssue(input: Omit<DhIssue, "id" | "createdAt" | "comments" | "audit" | "status"> & { status?: DhIssueStatus }) {
    const id = uid("dhi");
    const now = new Date().toISOString();
    const issue: DhIssue = {
      ...input, id, createdAt: now, status: input.status ?? "Open",
      comments: [],
      audit: [{ id: uid("a"), text: `Issue raised by ${input.raisedByName}`, at: now }],
    };
    state.issues.unshift(issue);
    // mirror to alerts for PM/SPM audience
    state.alerts.unshift({
      id: uid("al"),
      title: input.title,
      kind: "Issue",
      projectId: input.projectId,
      raisedByName: input.raisedByName,
      audienceUserIds: ["u1", "u3", "u4"], // SPM + PMs
      priority: input.priority,
      status: "Open",
      refId: id,
      createdAt: now,
      comments: [],
    });
    emit();
    return issue;
  },
  updateIssueStatus(id: string, status: DhIssueStatus, actorName: string) {
    const i = state.issues.find((x) => x.id === id);
    if (!i) return;
    i.status = status;
    i.audit.push({ id: uid("a"), text: `Status → ${status} by ${actorName}`, at: new Date().toISOString() });
    const alert = state.alerts.find((a) => a.refId === id);
    if (alert) alert.status = status === "Resolved" ? "Resolved" : "Acknowledged";
    emit();
  },
  commentOnIssue(id: string, c: Omit<DhComment, "id" | "at">) {
    const i = state.issues.find((x) => x.id === id);
    if (!i) return;
    const cm: DhComment = { ...c, id: uid("cm"), at: new Date().toISOString() };
    i.comments.push(cm);
    i.audit.push({ id: uid("a"), text: `${c.authorName} commented`, at: cm.at });
    const al = state.alerts.find((a) => a.refId === id);
    if (al) al.comments.push(cm);
    emit();
  },
  addEscalation(input: Omit<DhEscalation, "id" | "createdAt" | "comments" | "status"> & { status?: DhEscalation["status"] }) {
    const e: DhEscalation = { ...input, id: uid("esc"), createdAt: new Date().toISOString(), comments: [], status: input.status ?? "Open" };
    state.escalations.unshift(e);
    state.alerts.unshift({
      id: uid("al"), title: input.title, kind: "Escalation",
      projectId: input.projectId, raisedByName: input.ownerName,
      audienceUserIds: ["u1", "u3", "u4", "u11", "u12"],
      priority: input.severity, status: "Open",
      refId: e.id, createdAt: e.createdAt, comments: [],
    });
    emit();
    return e;
  },
  addEscalationAlert(input: {
    projectId: string;
    title: string;
    description: string;
    priority: DhPriority;
    raisedByName: string;
    serviceName: string;
    escalationType: string;
    escalatedTo: string[];
    expectedResolutionDate?: string;
    attachments?: string[];
  }) {
    const alertId = `ESC-${String(state.alerts.length + 1).padStart(3, '0')}`;
    const id = uid("al");
    const now = new Date().toISOString();
    const alert: DhAlert = {
      id,
      alertId,
      title: input.title,
      kind: "Escalation",
      projectId: input.projectId,
      raisedByName: input.raisedByName,
      audienceUserIds: ["u14", "u1", "u3", "u11", "u12"],
      priority: input.priority,
      status: "Open",
      createdAt: now,
      comments: [],
      description: input.description,
      alertType: "Escalation",
      owner: input.raisedByName,
      attachments: input.attachments || [],
      serviceName: input.serviceName,
      escalationType: input.escalationType,
      escalatedTo: input.escalatedTo,
      expectedResolutionDate: input.expectedResolutionDate,
      history: [
        { status: "Open", at: now, updatedBy: input.raisedByName, details: `Escalation raised for service ${input.serviceName}` }
      ]
    };
    state.alerts.unshift(alert);
    emit();
    return alert;
  },
  addAppreciation(input: Omit<DhAppreciation, "id" | "at">) {
    const a: DhAppreciation = { ...input, id: uid("ap"), at: new Date().toISOString() };
    state.appreciations.unshift(a);
    emit();
    return a;
  },
  addInterview(input: Omit<DhInterview, "id" | "history">) {
    const iv: DhInterview = { ...input, id: uid("iv"), history: [{ status: input.status, at: new Date().toISOString(), updatedBy: "system" }] };
    state.interviews.unshift(iv);
    // Notify resource via alert
    state.alerts.unshift({
      id: uid("al"),
      title: `Interview scheduled for ${input.clientName}`,
      kind: "Interview Rejected",
      projectId: input.projectId,
      raisedByName: "Engagement Manager",
      audienceUserIds: [input.resourceId],
      priority: "High",
      status: "Open",
      refId: iv.id,
      createdAt: new Date().toISOString(),
      comments: [],
    });
    emit();
    return iv;
  },
  updateInterviewStatus(id: string, status: InterviewStatus, updatedBy: string = "system") {
    const iv = state.interviews.find((x) => x.id === id);
    if (!iv) return;
    iv.status = status;
    iv.history.push({ status, at: new Date().toISOString(), updatedBy });
    // Create notification alert based on status
    const now = new Date().toISOString();
    if (status === "Selected" || status === "Rejected" || status === "Postponed") {
      const kindMap = {
        "Selected": "Interview Selected",
        "Rejected": "Interview Rejected",
        "Postponed": "Interview Rejected",
      };
      state.alerts.unshift({
        id: uid("al"),
        title: `${iv.resourceName}: Interview ${status} — ${iv.clientName}`,
        kind: kindMap[status] as AlertKind,
        projectId: iv.projectId,
        raisedByName: "Engagement Manager",
        audienceUserIds: [iv.resourceId],
        priority: "High",
        status: "Open",
        refId: id,
        createdAt: now,
        comments: [],
      });
    }
    emit();
  },
  submitInterviewResponse(id: string, text: string) {
    const iv = state.interviews.find((x) => x.id === id);
    if (!iv) return;
    iv.resourceResponse = { text, at: new Date().toISOString() };
    emit();
  },
  addRequirement(input: Omit<DhAdditionalRequirement, "id" | "history" | "createdAt" | "requirementId">) {
    const req: DhAdditionalRequirement = { ...input, id: uid("req"), requirementId: `REQ-${Date.now()}`, history: [{ status: input.status, at: new Date().toISOString(), updatedBy: "system", updatedByName: "System" }], createdAt: new Date().toISOString() };
    state.requirements.unshift(req);
    // Notify PM, SPM, EM, HOD, PMO
    state.alerts.unshift({
      id: uid("al"),
      title: `New requirement: ${req.title}`,
      kind: "Approval",
      projectId: req.projectId,
      raisedByName: req.requestedBy,
      audienceUserIds: ["u1", "u3", "u4", "u2", "u11", "u12"],
      priority: req.priority,
      status: "Open",
      refId: req.id,
      createdAt: req.createdAt,
      comments: [],
    });
    emit();
    return req;
  },
  updateRequirementStatus(id: string, status: RequirementStatus, updatedBy: string, updatedByName: string) {
    const req = state.requirements.find((x) => x.id === id);
    if (!req) return;
    req.status = status;
    req.history.push({ status, at: new Date().toISOString(), updatedBy, updatedByName });
    emit();
  },
  addRequirementComment(id: string, comment: Omit<DhComment, "id" | "at">) {
    const req = state.requirements.find((x) => x.id === id);
    if (!req) return;
    const cm: DhComment = { ...comment, id: uid("cm"), at: new Date().toISOString() };
    req.comments.push(cm);
    emit();
  },
  setPrereqValidation(projectId: string, s: PrereqStatus) {
    const p = state.prereqs[projectId] ?? { projectId, validation: "Validation Pending", collection: "NA", assignedPmIds: [], assignedSpmIds: [] };
    p.validation = s;
    state.prereqs[projectId] = p;
    emit();
  },
  setPrereqCollection(projectId: string, s: PrereqCollectionStatus) {
    const p = state.prereqs[projectId] ?? { projectId, validation: "Validation Pending", collection: "NA", assignedPmIds: [], assignedSpmIds: [] };
    p.collection = s;
    state.prereqs[projectId] = p;
    emit();
  },
  assignPMs(projectId: string, pmIds: string[], spmIds: string[]) {
    const p = state.prereqs[projectId];
    if (!p) return;
    p.assignedPmIds = pmIds;
    p.assignedSpmIds = spmIds;
    p.acknowledgedByPmIds = [];
    p.acknowledgedBySpmIds = [];
    emit();
  },
  acknowledgePmAssignment(projectId: string, pmId: string) {
    const p = state.prereqs[projectId];
    if (!p || !p.acknowledgedByPmIds) return;
    if (!p.acknowledgedByPmIds.includes(pmId)) {
      p.acknowledgedByPmIds.push(pmId);
    }
    emit();
  },
  acknowledgeSpmAssignment(projectId: string, spmId: string) {
    const p = state.prereqs[projectId];
    if (!p || !p.acknowledgedBySpmIds) return;
    if (!p.acknowledgedBySpmIds.includes(spmId)) {
      p.acknowledgedBySpmIds.push(spmId);
    }
    emit();
  },
  setProjectReadyToStart(projectId: string, isReady: boolean, updatedBy: string = "u14", updatedByName: string = "Dhanshree") {
    const p = state.prereqs[projectId];
    if (!p) return;
    p.isProjectReadyToStart = isReady;

    // Log audit entry
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const timeStr = now.toTimeString().slice(0, 8);

    if (!p.auditTrail) p.auditTrail = [];
    p.auditTrail.unshift({
      id: uid("aud"),
      fieldChanged: "Ready To Start",
      updatedBy,
      updatedByName,
      date: dateStr,
      time: timeStr,
      oldStatus: "Pending",
      newStatus: isReady ? "Ready To Start" : "Pending"
    });

    if (isReady) {
      const proj = allProjects().find(x => x.id === projectId);
      // Automatically send notifications (alerts) to PMs, SPMs, EM, HOD, PMO
      const targetAudience = Array.from(new Set([
        ...(p.assignedPmIds || []),
        ...(p.assignedSpmIds || []),
        "u1", "u2", "u3", "u4", "u11", "u12", "u14" // PMs, EM, HOD, PMO, Dhanshree
      ]));

      targetAudience.forEach(id => {
        state.alerts.unshift({
          id: uid("al"),
          alertId: uid("ALT"),
          title: `Project intake completed: ${proj?.name || "Ready to Start"}`,
          kind: "Approval",
          projectId,
          raisedByName: updatedByName,
          audienceUserIds: [id],
          priority: "Medium",
          status: "Open",
          createdAt: now.toISOString(),
          comments: [],
          description: `All service collection and validation prerequisites are completed, PM/SPM are assigned, and the project "${proj?.name}" is now marked "Ready To Start".`,
          alertType: "Governance Alert",
          owner: updatedByName,
          resolutionOwner: getPerson(id)?.name || "Team Member",
          escalationOwner: "Anita Desai",
          attachments: [],
          history: [{ status: "Open", at: now.toISOString(), updatedBy: updatedByName }]
        });
      });

      // Update delivery stage status to Ready To Start in project stages tracker
      this.updatePMOStage(projectId, "Ready To Start Project", "Project marked ready to start", updatedBy, updatedByName);
    }

    emit();
  },
  // Project Stages Tracker - Stage Update Methods (Dhanshree Role Only)
  updateStage(projectId: string, stageName: "sales" | "pmo" | "delivery" | "accounts", newStatus: string, action: string, updatedBy: string, updatedByName: string) {
    let tracker = state.projectStages[projectId];
    if (!tracker) {
      tracker = {
        projectId,
        stages: {
          sales: { stageName: "Sales", currentStatus: "Pending", isCompleted: false, isActive: true, history: [] },
          pmo: { stageName: "PMO", currentStatus: "Prerequisite Collection", isCompleted: false, isActive: false, history: [] },
          delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
          accounts: { stageName: "Accounts", currentStatus: "PO Not Raised", isCompleted: false, isActive: false, history: [] },
        },
      };
      state.projectStages[projectId] = tracker;
    }
    const stage = tracker.stages[stageName];
    const entry: StageHistoryEntry = {
      id: uid("sh"),
      timestamp: new Date().toISOString(),
      action,
      updatedBy,
      updatedByName,
      previousStatus: stage.currentStatus as any,
      newStatus: newStatus as any,
    };
    stage.history.push(entry);
    stage.currentStatus = newStatus as any;
    emit();
  },
  updateSalesStage(projectId: string, newStatus: SalesStatus, action: string, updatedBy: string, updatedByName: string) {
    this.updateStage(projectId, "sales", newStatus, action, updatedBy, updatedByName);
  },
  updatePMOStage(projectId: string, newStatus: PMOStatus, action: string, updatedBy: string, updatedByName: string) {
    this.updateStage(projectId, "pmo", newStatus, action, updatedBy, updatedByName);
  },
  updateDeliveryStage(projectId: string, newStatus: DeliveryStatus, action: string, updatedBy: string, updatedByName: string) {
    this.updateStage(projectId, "delivery", newStatus, action, updatedBy, updatedByName);
  },
  updateAccountsStage(projectId: string, newStatus: AccountsStatus, action: string, updatedBy: string, updatedByName: string) {
    this.updateStage(projectId, "accounts", newStatus, action, updatedBy, updatedByName);
  },
  // Auto-update PMO stage based on prerequisite changes
  syncPMOStageWithPrereqs(projectId: string, collection: PrereqCollectionStatus, validation: PrereqStatus, isReadyToStart?: boolean) {
    if (!state.projectStages[projectId]) {
      state.projectStages[projectId] = {
        projectId,
        stages: {
          sales: { stageName: "Sales", currentStatus: "Pending", isCompleted: false, isActive: true, history: [] },
          pmo: { stageName: "PMO", currentStatus: "Prerequisite Collection", isCompleted: false, isActive: false, history: [] },
          delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
          accounts: { stageName: "Accounts", currentStatus: "PO Not Raised", isCompleted: false, isActive: false, history: [] },
        },
      };
    }
    const tracker = state.projectStages[projectId];
    const pmoStage = tracker.stages.pmo;
    let newStatus: PMOStatus;
    let shouldUpdate = false;
    if (isReadyToStart) {
      newStatus = "Ready To Start Project";
      shouldUpdate = pmoStage.currentStatus !== newStatus;
    } else if (collection === "Received" && validation === "Validated") {
      newStatus = "Ready To Start Project";
      shouldUpdate = pmoStage.currentStatus !== newStatus;
    } else if (validation === "Validation Pending" && collection === "Received") {
      newStatus = "Validation";
      shouldUpdate = pmoStage.currentStatus !== newStatus;
    } else if (collection === "Initiated" || collection === "Waiting For Client Response") {
      newStatus = "Prerequisite Collection";
      shouldUpdate = pmoStage.currentStatus !== newStatus;
    } else {
      newStatus = "Prerequisite Collection";
      shouldUpdate = pmoStage.currentStatus !== newStatus;
    }
    if (shouldUpdate) {
      const entry: StageHistoryEntry = {
        id: uid("sh"),
        timestamp: new Date().toISOString(),
        action: "Auto-synced with prerequisite updates",
        updatedBy: "system",
        updatedByName: "System",
        previousStatus: pmoStage.currentStatus as any,
        newStatus: newStatus as any,
      };
      pmoStage.history.push(entry);
      pmoStage.currentStatus = newStatus;
      emit();
    }
  },
  ackAlert(id: string) {
    const a = state.alerts.find((x) => x.id === id);
    if (!a) return;
    a.status = "Acknowledged";
    emit();
  },
  resolveAlert(id: string) {
    const a = state.alerts.find((x) => x.id === id);
    if (!a) return;
    a.status = "Resolved";
    emit();
  },
  getTaskAssignment(projectId: string, taskId: string): TaskAssignmentState {
    let existing = state.taskAssignments[taskId];
    if (existing) return existing;

    const project = allProjects().find((p) => p.id === projectId);
    if (!project) return { taskId, assigneeIds: [], history: [] };

    const task = project.tasks.find((t) => t.id === taskId);
    if (!task) return { taskId, assigneeIds: [], history: [] };

    const idx = project.tasks.findIndex((x) => x.id === task.id);
    const extras = project.teamIds.filter((id) => id !== task.assigneeId).slice(0, idx % 2);
    const initialAssignees = [task.assigneeId, ...extras];

    const newState: TaskAssignmentState = {
      taskId,
      assigneeIds: initialAssignees,
      history: initialAssignees.map(id => {
        const p = getPerson(id);
        return {
          id: `h-${Date.now()}-${Math.random()}`,
          taskId,
          action: "Assign",
          resourceId: id,
          resourceName: p.name,
          teamType: "Project Team",
          timestamp: new Date().toISOString(),
          updatedBy: "Dhanshree",
        };
      })
    };
    state.taskAssignments[taskId] = newState;
    // emit so useDhStore subscribers (liveAssignments) see the seeded data immediately
    emit();
    return newState;
  },

  assignResourcesToTask(projectId: string, taskId: string, selectedIds: string[], updatedBy: string = "Dhanshree") {
    const current = this.getTaskAssignment(projectId, taskId);
    const prevIds = current.assigneeIds;

    // Find added and removed resources
    const added = selectedIds.filter(id => !prevIds.includes(id));
    const removed = prevIds.filter(id => !selectedIds.includes(id));

    const now = new Date().toISOString();
    const shadowTeamList = state.shadowTeams[projectId] ?? [];

    added.forEach(id => {
      const p = getPerson(id);
      const isShadow = shadowTeamList.includes(id);
      current.history.push({
        id: uid("h"),
        taskId,
        action: "Assign",
        resourceId: id,
        resourceName: p.name,
        teamType: isShadow ? "Shadow Team" : "Project Team",
        timestamp: now,
        updatedBy
      });
    });

    removed.forEach(id => {
      const p = getPerson(id);
      const isShadow = shadowTeamList.includes(id);
      current.history.push({
        id: uid("h"),
        taskId,
        action: "Unassign",
        resourceId: id,
        resourceName: p.name,
        teamType: isShadow ? "Shadow Team" : "Project Team",
        timestamp: now,
        updatedBy
      });
    });

    current.assigneeIds = selectedIds;
    emit();
  },

  // Update PM-editable actuals on a task; auto-calculates actualEndDate skipping weekends
  updateTaskActuals(projectId: string, taskId: string, patch: {
    actualStartDate?: string;
    actualEndDate?: string;
    utilizedHours?: number;
    stage?: "Ready to Start" | "Ongoing" | "Completed" | "On Hold (Internal)" | "On Hold (Client End)" | "After Release";
  }) {
    const proj = state.extraProjects.find((p) => p.id === projectId);
    if (!proj) return;
    const task = proj.tasks.find((t) => t.id === taskId);
    if (!task) return;
    if (patch.actualStartDate !== undefined) task.actualStartDate = patch.actualStartDate;
    if (patch.utilizedHours !== undefined) task.utilizedHours = patch.utilizedHours;
    if (patch.stage !== undefined) task.stage = patch.stage;
    // If actualEndDate is explicitly set (manual override), use it
    if (patch.actualEndDate !== undefined) {
      task.actualEndDate = patch.actualEndDate;
    } else if (task.actualStartDate && task.estimatedHours && !patch.actualEndDate) {
      // Auto-calc only if actualStartDate changed and no manual override
      const days = Math.ceil(task.estimatedHours / 8);
      let d = new Date(task.actualStartDate);
      let remaining = days;
      while (remaining > 0) {
        d.setDate(d.getDate() + 1);
        const dow = d.getDay();
        if (dow !== 0 && dow !== 6) remaining--;
      }
      const y = d.getFullYear();
      const m = String(d.getMonth() + 1).padStart(2, "0");
      const dd = String(d.getDate()).padStart(2, "0");
      task.actualEndDate = `${y}-${m}-${dd}`;
    }
    emit();
  },

  addShadowMember(projectId: string, memberId: string, duration: string, billability: Billability, resourceType: ResourceType) {
    // Always force shadow team values
    const fixedBillability: Billability = "Non-Billable";
    const fixedResourceType: ResourceType = "Shared Resource";

    const existingIds = state.shadowTeams[projectId] ?? [];
    const newIds = existingIds.includes(memberId) ? existingIds : [...existingIds, memberId];

    const existingDetails = state.shadowTeamDetails[projectId] ?? {};
    const newDetails = {
      ...existingDetails,
      [memberId]: { duration, billability: fixedBillability, resourceType: fixedResourceType },
    };

    // Replace top-level maps with new references so shallow snapshot copy triggers re-renders
    state.shadowTeams = { ...state.shadowTeams, [projectId]: newIds };
    state.shadowTeamDetails = { ...state.shadowTeamDetails, [projectId]: newDetails };
    emit();
  },

  removeShadowMember(projectId: string, memberId: string) {
    const existingIds = state.shadowTeams[projectId] ?? [];
    const existingDetails = state.shadowTeamDetails[projectId] ?? {};
    const newDetails = { ...existingDetails };
    delete newDetails[memberId];

    state.shadowTeams = { ...state.shadowTeams, [projectId]: existingIds.filter(id => id !== memberId) };
    state.shadowTeamDetails = { ...state.shadowTeamDetails, [projectId]: newDetails };
    emit();
  },

  updateShadowMember(projectId: string, memberId: string, patch: Partial<{ duration: string; billability: Billability; resourceType: ResourceType }>) {
    const existingDetails = state.shadowTeamDetails[projectId] ?? {};
    const existing = existingDetails[memberId] ?? { duration: "", billability: "Non-Billable" as Billability, resourceType: "Shared Resource" as ResourceType };
    // Always enforce fixed values for shadow team
    const newDetails = {
      ...existingDetails,
      [memberId]: {
        ...existing,
        duration: patch.duration ?? existing.duration,
        billability: "Non-Billable" as Billability,
        resourceType: "Shared Resource" as ResourceType,
      },
    };
    state.shadowTeamDetails = { ...state.shadowTeamDetails, [projectId]: newDetails };
    emit();
  },

  updateProjectTeamMember(projectId: string, memberId: string, patch: Partial<{ duration: string; billability: Billability; resourceType: ResourceType }>) {
    if (!state.projectTeamDetails[projectId]) {
      state.projectTeamDetails[projectId] = {};
    }
    state.projectTeamDetails[projectId][memberId] = {
      ...(state.projectTeamDetails[projectId][memberId] ?? {}),
      ...patch,
    } as { duration: string; billability: Billability; resourceType: ResourceType };
    emit();
  },

  addProjectTeamMember(projectId: string, memberId: string, duration: string, billability: Billability, resourceType: ResourceType) {
    if (!state.projectTeamAdditions[projectId]) {
      state.projectTeamAdditions[projectId] = [];
    }
    if (!state.projectTeamAdditions[projectId].includes(memberId)) {
      state.projectTeamAdditions[projectId].push(memberId);
    }
    if (!state.projectTeamDetails[projectId]) {
      state.projectTeamDetails[projectId] = {};
    }
    state.projectTeamDetails[projectId][memberId] = { duration, billability, resourceType };
    emit();
  },

  removeProjectTeamAddition(projectId: string, memberId: string) {
    if (state.projectTeamAdditions[projectId]) {
      state.projectTeamAdditions[projectId] = state.projectTeamAdditions[projectId].filter(id => id !== memberId);
    }
    if (state.projectTeamDetails[projectId]) {
      delete state.projectTeamDetails[projectId][memberId];
    }
    emit();
  },

  acknowledgeInterview(interviewId: string, alertId: string, actionTaken: string, remarks: string, authorId: string, authorName: string) {
    const iv = state.interviews.find((x) => x.id === interviewId);
    if (!iv) return;

    const now = new Date().toISOString();

    // Add history entry
    iv.history.push({
      status: iv.status,
      at: now,
      updatedBy: authorName,
    });

    // Set response
    if (remarks.trim()) {
      if (!iv.resourceResponse) {
        iv.resourceResponse = { text: remarks.trim(), at: now };
      } else {
        iv.resourceResponse.text += `\n[${actionTaken} - ${new Date(now).toLocaleDateString()}]: ${remarks.trim()}`;
      }
    } else {
      iv.resourceResponse = { text: `${actionTaken}`, at: now };
    }

    // Update alert status
    const alert = state.alerts.find(a => a.id === alertId);
    if (alert) {
      alert.status = "Acknowledged";
      if (remarks.trim()) {
        alert.comments.push({
          id: uid("cm"),
          authorId,
          authorName,
          text: `[${actionTaken}]: ${remarks.trim()}`,
          at: now
        });
      }
    }
    emit();
  },

  updateTimesheetStatus(id: string, status: TimesheetStatus, comment: string, updatedBy: string, updatedById: string) {
    const ts = state.timesheets.find((x) => x.id === id);
    if (!ts) return;
    ts.status = status;
    const now = new Date().toISOString();
    const cm: DhComment = {
      id: uid("cm"),
      authorId: updatedById,
      authorName: updatedBy,
      text: comment.trim(),
      at: now
    };
    ts.comments.push(cm);
    ts.history.push({
      status,
      at: now,
      updatedBy,
      comment: comment.trim()
    });

    // Notify employee via a DhAlert
    state.alerts.unshift({
      id: uid("al"),
      alertId: uid("ALT"),
      title: `Timesheet for week ${ts.weekStart} has been ${status}`,
      kind: status === "approved" ? "Approval" : "Issue",
      projectId: ts.entries[0]?.projectId,
      raisedByName: updatedBy,
      audienceUserIds: [ts.userId],
      priority: status === "rejected" ? "High" : "Medium",
      status: "Open",
      refId: ts.id,
      createdAt: now,
      comments: [cm],
      description: `Your timesheet submitted for week ${ts.weekStart} has been marked as ${status} by ${updatedBy}. Approver comments: ${comment.trim()}`,
      alertType: status === "rejected" ? "Governance Alert" : "Quality Concern",
      owner: updatedBy,
      resolutionOwner: getPerson(ts.userId)?.name || "Employee",
      escalationOwner: "Anita Desai",
      attachments: [],
      history: [
        { status: "Open", at: now, updatedBy }
      ]
    });
    emit();
  },

  submitMyTimesheet(userId: string, userRole: any, weekStart: string, entries: TimesheetEntry[], totalHours: number) {
    // Check if there is already a timesheet for this week for this user
    const existingIdx = state.timesheets.findIndex((x) => x.userId === userId && x.weekStart === weekStart);
    const now = new Date().toISOString();

    if (existingIdx >= 0) {
      // Overwrite/Update existing draft or resubmission
      const existing = state.timesheets[existingIdx];
      existing.status = "submitted";
      existing.entries = entries;
      existing.totalHours = totalHours;
      existing.submittedAt = now;
      existing.history.push({
        status: "submitted",
        at: now,
        updatedBy: getPerson(userId)?.name || "Employee",
        comment: "Timesheet resubmitted"
      });
    } else {
      const id = uid("ts");
      const ts: DhTimesheet = {
        id,
        userId,
        userRole,
        weekStart,
        status: "submitted",
        entries,
        totalHours,
        submittedAt: now,
        comments: [],
        history: [{
          status: "submitted",
          at: now,
          updatedBy: getPerson(userId)?.name || "Employee",
          comment: "Timesheet submitted"
        }]
      };
      state.timesheets.unshift(ts);
    }
    emit();
  },

  addCellComment(timesheetId: string, projectId: string, taskId: string, dayIndex: number, text: string, type: "comment" | "response" | "clarification_request", author: string) {
    const ts = state.timesheets.find((x) => x.id === timesheetId);
    if (!ts) return;
    const entry = ts.entries.find((e) => e.projectId === projectId && e.taskId === taskId);
    if (!entry) return;

    if (!entry.cellComments) {
      entry.cellComments = {};
    }
    if (!entry.cellComments[dayIndex]) {
      const legacyNote = entry.notes?.[dayIndex] || (dayIndex === 0 ? entry.note : undefined);
      entry.cellComments[dayIndex] = {
        status: "new",
        history: legacyNote && legacyNote.trim() ? [
          {
            author: getPerson(ts.userId)?.name || "Employee",
            text: legacyNote,
            type: "comment",
            createdAt: ts.submittedAt || new Date().toISOString()
          }
        ] : []
      };
    }

    const cell = entry.cellComments[dayIndex];
    cell.history.push({
      author,
      text,
      type,
      createdAt: new Date().toISOString()
    });

    if (type === "clarification_request") {
      cell.status = "clarification_requested";
    } else if (type === "response") {
      cell.status = "viewed";
    } else {
      cell.status = "new";
    }

    emit();
  },

  markCellCommentViewed(timesheetId: string, projectId: string, taskId: string, dayIndex: number) {
    const ts = state.timesheets.find((x) => x.id === timesheetId);
    if (!ts) return;
    const entry = ts.entries.find((e) => e.projectId === projectId && e.taskId === taskId);
    if (!entry) return;

    if (!entry.cellComments) {
      entry.cellComments = {};
    }
    if (!entry.cellComments[dayIndex]) {
      const legacyNote = entry.notes?.[dayIndex] || (dayIndex === 0 ? entry.note : undefined);
      if (legacyNote && legacyNote.trim()) {
        entry.cellComments[dayIndex] = {
          status: "viewed",
          history: [
            {
              author: getPerson(ts.userId)?.name || "Employee",
              text: legacyNote,
              type: "comment",
              createdAt: ts.submittedAt || new Date().toISOString()
            }
          ]
        };
        emit();
      }
    } else {
      const cell = entry.cellComments[dayIndex];
      if (cell.status === "new") {
        cell.status = "viewed";
        emit();
      }
    }
  },

  updateCentralApprovalStatus(id: string, status: DhCentralApproval["status"], comment: string, updatedBy: string, updatedById: string) {
    const app = state.approvals.find((x) => x.id === id);
    if (!app) return;
    app.status = status;
    const now = new Date().toISOString();
    const cm: DhComment = {
      id: uid("cm"),
      authorId: updatedById,
      authorName: updatedBy,
      text: comment.trim(),
      at: now
    };
    app.comments.push(cm);
    app.history.push({
      status,
      at: now,
      updatedBy,
      comment: comment.trim()
    });

    // Timeline Update Logic: If it is an extension request, and it is approved, automatically update the project's endDate!
    if (id.startsWith("APP-EXT-") && status === "Approved") {
      const proj = state.extraProjects.find(p => p.id === app.projectId) || baseProjects.find(p => p.id === app.projectId);
      if (proj) {
        // Parse requested new end date from description: "Timeline Extension: Requesting extension of X days. New End Date: YYYY-MM-DD. Reason: ..."
        const match = app.description.match(/New End Date:\s*([^\s\.]+)/);
        if (match && match[1]) {
          const oldEndDate = proj.endDate;
          proj.endDate = match[1];

          // Log audit entry
          const p = state.prereqs[app.projectId];
          if (p) {
            const currentDate = new Date();
            if (!p.auditTrail) p.auditTrail = [];
            p.auditTrail.unshift({
              id: uid("aud"),
              fieldChanged: "Extension Request",
              updatedBy: updatedById,
              updatedByName: updatedBy,
              date: currentDate.toISOString().slice(0, 10),
              time: currentDate.toTimeString().slice(0, 8),
              oldStatus: oldEndDate,
              newStatus: proj.endDate
            });
          }
        }
      }
    }

    // Notify requester via alert
    state.alerts.unshift({
      id: uid("al"),
      alertId: uid("ALT"),
      title: `${app.requestType} request has been ${status}`,
      kind: "Approval",
      projectId: app.projectId,
      raisedByName: updatedBy,
      audienceUserIds: [app.requestedById],
      priority: status === "Rejected" ? "High" : "Medium",
      status: "Open",
      refId: app.id,
      createdAt: now,
      comments: [cm],
      description: `The request for ${app.requestType} on project ${app.projectName} has been ${status} by ${updatedBy}. Comments: ${comment.trim()}`,
      alertType: "Governance Alert",
      owner: updatedBy,
      resolutionOwner: app.requestedBy,
      escalationOwner: "Anita Desai",
      attachments: [],
      history: [
        { status: "Open", at: now, updatedBy }
      ]
    });
    emit();
  },

  setServicePrereqStatus(
    projectId: string,
    serviceId: string,
    field: "collectionStatus" | "validationStatus" | "billingStatus",
    value: string,
    updatedById: string,
    updatedByName: string
  ) {
    const p = state.prereqs[projectId];
    if (!p) return;

    if (!p.services) {
      // No services seeded — initialize empty; new projects always get seeded
      // from WBS services in addProject. Only legacy base projects fall here.
      p.services = [];
    }

    const svc = p.services.find(s => s.serviceId === serviceId);
    if (!svc) return;

    const oldVal = svc[field];
    (svc as any)[field] = value;

    // Automatically disable validation dropdown and set status to "Pending To Validate" if collection is Pending To Collect
    if (field === "collectionStatus" && value === "Pending To Collect") {
      svc.validationStatus = "Pending To Validate";
    }

    // Push audit entry
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const timeStr = now.toTimeString().slice(0, 8);

    if (!p.auditTrail) p.auditTrail = [];
    p.auditTrail.unshift({
      id: uid("aud"),
      fieldChanged: field === "collectionStatus" ? "Collection Status" : field === "validationStatus" ? "Validation Status" : "Billing Status",
      updatedBy: updatedById,
      updatedByName,
      date: dateStr,
      time: timeStr,
      oldStatus: oldVal ?? "Advance Pending",
      newStatus: value
    });

    // Auto-calculate project level prerequisite validation and collection status
    const allCollected = p.services.every(s => s.collectionStatus === "Collected");
    const allValidated = p.services.every(s => s.validationStatus === "Validated");

    p.collection = allCollected ? "Received" : "Initiated";
    p.validation = allValidated ? "Validated" : "Validation Pending";

    emit();
  },

  submitExtensionRequest(
    projectId: string,
    newEndDate: string,
    extensionDays: number,
    reason: string,
    taggedApproverIds: string[],
    requestedByName: string,
    requestedById: string
  ) {
    const proj = allProjects().find(p => p.id === projectId);
    if (!proj) return;

    const appId = `APP-EXT-${Date.now()}`;

    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const timeStr = now.toTimeString().slice(0, 8);

    // Add to central approvals
    state.approvals.unshift({
      id: appId,
      projectId,
      projectName: proj.name,
      requestType: "Timeline Extension Approval",
      requestedBy: requestedByName,
      requestedById,
      requestedDate: dateStr,
      status: "Pending",
      description: `Timeline Extension: Requesting extension of ${extensionDays} days. New End Date: ${newEndDate}. Reason: ${reason.trim()}`,
      comments: [],
      history: []
    });

    // Send notifications (alerts) to all tagged approvers
    taggedApproverIds.forEach(id => {
      state.alerts.unshift({
        id: uid("al"),
        alertId: uid("ALT"),
        title: `Timeline Extension requested: ${proj.name}`,
        kind: "Approval",
        projectId,
        raisedByName: requestedByName,
        audienceUserIds: [id],
        priority: "High",
        status: "Open",
        refId: appId,
        createdAt: now.toISOString(),
        comments: [],
        description: `Dhanshree has submitted a timeline extension request of ${extensionDays} days for project "${proj.name}". Please review and approve.`,
        alertType: "Governance Alert",
        owner: requestedByName,
        resolutionOwner: getPerson(id)?.name || "Supervisor",
        escalationOwner: "Anita Desai",
        attachments: [],
        history: [{ status: "Open", at: now.toISOString(), updatedBy: requestedByName }]
      });
    });

    // Push entry to audit trail
    const p = state.prereqs[projectId];
    if (p) {
      if (!p.auditTrail) p.auditTrail = [];
      p.auditTrail.unshift({
        id: uid("aud"),
        fieldChanged: "Extension Request",
        updatedBy: requestedById,
        updatedByName: requestedByName,
        date: dateStr,
        time: timeStr,
        oldStatus: proj.endDate,
        newStatus: newEndDate
      });
    }

    emit();
    return appId;
  },

  updateLeadershipAssignment(projectId: string, role: LeadershipRole, ids: string[]) {
    const existing = state.leadershipAssignments[projectId] ?? { emIds: [], spmIds: [], pmIds: [], tlIds: [] };
    // Replace the entire projectId entry with a new object so shallow-copy snapshot
    // gets a new reference and useSyncExternalStore triggers re-renders correctly.
    state.leadershipAssignments = {
      ...state.leadershipAssignments,
      [projectId]: {
        ...existing,
        ...(role === "Engagement Manager"     ? { emIds:  ids } : {}),
        ...(role === "Senior Project Manager" ? { spmIds: ids } : {}),
        ...(role === "Project Manager"        ? { pmIds:  ids } : {}),
        ...(role === "Team Lead"              ? { tlIds:  ids } : {}),
      },
    };
    emit();
  },

  submitLeadershipChangeRequest(input: {
    projectId: string;
    role: LeadershipRole;
    currentLeaderIds: string[];
    currentLeaderNames: string[];
    newLeaderIds: string[];
    newLeaderNames: string[];
    effectiveDate: string;
    changeReason: string;
    additionalComments: string;
    notifyPersonIds: string[];
    attachmentName?: string;
    requestedBy: string;
    requestedById: string;
  }) {
    const proj = allProjects().find(p => p.id === input.projectId);
    if (!proj) return;

    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const timeStr = now.toTimeString().slice(0, 8);
    const reqId = uid("LCR");
    const appId = uid("APP-LCR");

    // Create central approval entry
    state.approvals.unshift({
      id: appId,
      projectId: input.projectId,
      projectName: proj.name,
      requestType: "Leadership Change Approval",
      requestedBy: input.requestedBy,
      requestedById: input.requestedById,
      requestedDate: dateStr,
      status: "Pending",
      description: `Leadership Change Request — ${input.role}: Replacing [${input.currentLeaderNames.join(", ")}] with [${input.newLeaderNames.join(", ")}]. Effective: ${input.effectiveDate}. Reason: ${input.changeReason.trim()}`,
      comments: [],
      history: [],
    });

    // Store the change request
    const lcr: LeadershipChangeRequest = {
      id: reqId,
      projectId: input.projectId,
      projectName: proj.name,
      role: input.role,
      currentLeaderIds: input.currentLeaderIds,
      currentLeaderNames: input.currentLeaderNames,
      newLeaderIds: input.newLeaderIds,
      newLeaderNames: input.newLeaderNames,
      effectiveDate: input.effectiveDate,
      changeReason: input.changeReason,
      additionalComments: input.additionalComments,
      notifyPersonIds: input.notifyPersonIds,
      attachmentName: input.attachmentName,
      requestedBy: input.requestedBy,
      requestedById: input.requestedById,
      requestedDate: dateStr,
      status: "Pending",
      approvalId: appId,
      auditHistory: [{
        previousLeaderNames: input.currentLeaderNames,
        newLeaderNames: input.newLeaderNames,
        changedBy: input.requestedBy,
        effectiveDate: input.effectiveDate,
        changeReason: input.changeReason,
        status: "Pending",
      }],
      createdAt: now.toISOString(),
    };
    state.leadershipChangeRequests.unshift(lcr);

    // Notify tagged people via alerts
    input.notifyPersonIds.forEach(id => {
      state.alerts.unshift({
        id: uid("al"),
        alertId: uid("ALT"),
        title: `Leadership Change Request — ${input.role}: ${proj.name}`,
        kind: "Approval",
        projectId: input.projectId,
        raisedByName: input.requestedBy,
        audienceUserIds: [id],
        priority: "High",
        status: "Open",
        refId: appId,
        createdAt: now.toISOString(),
        comments: [],
        description: `A leadership change has been requested for the ${input.role} role on project "${proj.name}". New leader(s): ${input.newLeaderNames.join(", ")}. Effective: ${input.effectiveDate}. Reason: ${input.changeReason.trim()}`,
        alertType: "Governance Alert",
        owner: input.requestedBy,
        resolutionOwner: getPerson(id)?.name || "Supervisor",
        escalationOwner: "Anita Desai",
        attachments: [],
        history: [{ status: "Open", at: now.toISOString(), updatedBy: input.requestedBy }],
      });
    });

    // Add notification
    const count = state.notifications.length + 1;
    state.notifications.unshift({
      id: `NTF-${String(count).padStart(3, '0')}`,
      title: `Leadership Change Request submitted — ${input.role}: ${proj.name}`,
      type: "Leadership Change",
      relatedProject: proj.name,
      raisedBy: input.requestedBy,
      createdAt: now.toISOString(),
      status: "Pending",
      priority: "High",
      unread: true,
      createdBy: input.requestedBy,
      createdDate: dateStr,
      history: [{ action: "Leadership change request submitted", date: dateStr, time: timeStr, by: input.requestedBy }],
    });

    emit();
    return reqId;
  },

  acknowledgeCentralApproval(id: string) {
    const app = state.approvals.find((x) => x.id === id);
    if (!app) return;
    app.acknowledgedAt = new Date().toISOString();
    emit();
  },

  updateGovernanceAlert(id: string, patch: Partial<{ status: AlertStatus; owner: string; resolutionOwner: string; escalationOwner: string; resolutionDetails: string }>, commentText?: string, actorId?: string, actorName?: string) {
    const al = state.alerts.find((x) => x.id === id);
    if (!al) return;

    const now = new Date().toISOString();

    if (patch.status && patch.status !== al.status) {
      if (!al.history) al.history = [];
      al.history.push({
        status: patch.status,
        at: now,
        updatedBy: actorName || "System",
        details: `Status transitioned from ${al.status} to ${patch.status}`
      });
      al.status = patch.status;
    }

    if (patch.owner !== undefined) al.owner = patch.owner;
    if (patch.resolutionOwner !== undefined) al.resolutionOwner = patch.resolutionOwner;
    if (patch.escalationOwner !== undefined) al.escalationOwner = patch.escalationOwner;
    if (patch.resolutionDetails !== undefined) al.resolutionDetails = patch.resolutionDetails;

    if (commentText && commentText.trim() && actorId && actorName) {
      al.comments.push({
        id: uid("cm"),
        authorId: actorId,
        authorName: actorName,
        text: commentText.trim(),
        at: now
      });
    }

    emit();
  },

  updateAccountsDetail(projectId: string, patch: Partial<AccountsDetail>) {
    let tracker = state.projectStages[projectId];
    if (!tracker) return;
    tracker.accountsDetail = { ...(tracker.accountsDetail ?? { poStatus: "PO Pending", paymentStatus: "Payment Pending" }), ...patch };
    emit();
  },

  updateOffboardingStatus(employeeId: string, patch: Partial<OffboardingResource>) {
    const idx = state.offboardingResources.findIndex(r => r.employeeId === employeeId);
    if (idx < 0) return;
    state.offboardingResources[idx] = { ...state.offboardingResources[idx], ...patch };
    emit();
  },

  raiseInvoice(projectId: string, invoiceId: string, invoiceNumber: string, updatedBy: string = "u14", updatedByName: string = "Dhanshree") {
    const inv = state.invoices.find((i) => i.id === invoiceId);
    if (!inv) return;

    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);

    state.invoices = state.invoices.map(i => i.id === invoiceId ? {
      ...i,
      invoiceStatus: "Raised",
      invoiceNumber: invoiceNumber,
      raisedBy: updatedByName,
      raisedDate: dateStr,
      paymentStatus: "Not Received",
      paymentReceivedDate: ""
    } : i);

    this.updateAccountsStage(projectId, "Invoice Raised", `Invoice raised: ${invoiceNumber}`, updatedBy, updatedByName);

    const proj = allProjects().find(x => x.id === projectId);
    const prereq = state.prereqs[projectId];

    const ems = proj ? getProjectEMs(proj).map(x => x.id) : [];
    const pms = proj ? getProjectPMs(proj).map(x => x.id) : [];
    const spms = prereq?.assignedSpmIds || [];

    const audience = Array.from(new Set([
      "u15", // Accounts Team
      "u12", // HOD
      ...pms,
      ...spms,
      ...ems
    ]));

    audience.forEach(userId => {
      const newAlert = {
        id: uid("al"),
        alertId: uid("ALT"),
        title: `Invoice Raised: ${invoiceNumber}`,
        kind: "Approval" as any,
        projectId,
        raisedByName: updatedByName,
        audienceUserIds: [userId],
        priority: "Medium" as any,
        status: "Open" as any,
        createdAt: now.toISOString(),
        comments: [],
        description: `Dhanshree has raised invoice "${invoiceNumber}" of amount ${inv.currency} ${inv.invoiceAmount.toLocaleString()} for project "${proj?.name || "Project"}".`,
        alertType: "Governance Alert" as any,
        owner: updatedByName,
        resolutionOwner: getPerson(userId)?.name || "Team Member",
        escalationOwner: "Anita Desai",
        attachments: [],
        history: [{ status: "Open" as any, at: now.toISOString(), updatedBy: updatedByName }]
      };
      state.alerts = [newAlert, ...state.alerts];
    });

    emit();
  },

  updatePaymentStatus(projectId: string, invoiceId: string, paymentStatus: "Not Received" | "Received", updatedBy: string = "u15", updatedByName: string = "Accounts Team") {
    const inv = state.invoices.find((i) => i.id === invoiceId);
    if (!inv) return;

    const now = new Date();

    let paymentReceivedDate = "";
    let paymentReceivedBy: string | undefined = undefined;

    if (paymentStatus === "Received") {
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      const d = String(now.getDate()).padStart(2, '0');
      const m = months[now.getMonth()];
      const y = now.getFullYear();
      paymentReceivedDate = `${d}-${m}-${y}`;
      paymentReceivedBy = updatedByName;
    }

    state.invoices = state.invoices.map(i => i.id === invoiceId ? {
      ...i,
      paymentStatus,
      paymentReceivedDate,
      paymentReceivedBy
    } : i);

    const updatedInv = state.invoices.find(i => i.id === invoiceId)!;

    if (paymentStatus === "Received") {
      this.updateAccountsStage(projectId, "Payment Received", `Payment received captured automatically for invoice ${updatedInv.invoiceNumber}`, updatedBy, updatedByName);

      const proj = allProjects().find(x => x.id === projectId);
      const prereq = state.prereqs[projectId];

      const ems = proj ? getProjectEMs(proj).map(x => x.id) : [];
      const pms = proj ? getProjectPMs(proj).map(x => x.id) : [];
      const spms = prereq?.assignedSpmIds || [];

      const audience = Array.from(new Set([
        "u12", // HOD
        ...pms,
        ...spms,
        ...ems
      ]));

      audience.forEach(userId => {
        const newAlert = {
          id: uid("al"),
          alertId: uid("ALT"),
          title: `Payment Received: ${updatedInv.invoiceNumber}`,
          kind: "Approval" as any,
          projectId,
          raisedByName: updatedByName,
          audienceUserIds: [userId],
          priority: "Medium" as any,
          status: "Open" as any,
          createdAt: now.toISOString(),
          comments: [],
          description: `Accounts Team has captured payment received for invoice "${updatedInv.invoiceNumber}" of amount ${updatedInv.currency} ${updatedInv.invoiceAmount.toLocaleString()} under project "${proj?.name || "Project"}".`,
          alertType: "Governance Alert" as any,
          owner: updatedByName,
          resolutionOwner: getPerson(userId)?.name || "Team Member",
          escalationOwner: "Anita Desai",
          attachments: [],
          history: [{ status: "Open" as any, at: now.toISOString(), updatedBy: updatedByName }]
        };
        state.alerts = [newAlert, ...state.alerts];
      });
    } else {
      this.updateAccountsStage(projectId, "Payment Pending", `Payment status reset to pending for invoice ${updatedInv.invoiceNumber}`, updatedBy, updatedByName);
    }

    emit();
  },

  cancelInvoice(projectId: string, invoiceId: string, updatedBy: string = "u14", updatedByName: string = "Dhanshree") {
    const inv = state.invoices.find((i) => i.id === invoiceId);
    if (!inv) return;

    state.invoices = state.invoices.map(i => i.id === invoiceId ? {
      ...i,
      invoiceStatus: "Not Raised",
      invoiceNumber: "",
      raisedBy: undefined,
      raisedDate: undefined,
      paymentStatus: "Not Received",
      paymentReceivedDate: ""
    } : i);

    this.updateAccountsStage(projectId, "Invoice Not Raised", `Invoice reset to not raised`, updatedBy, updatedByName);
    emit();
  },

  addNotification(input: {
    type: string;
    title: string;
    relatedProject: string;
    relatedTask?: string;
    raisedBy: string;
    priority: "Low" | "Medium" | "High" | "Critical";
  }) {
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const timeStr = now.toTimeString().slice(0, 8);
    const count = state.notifications.length + 1;
    const id = `NTF-${String(count).padStart(3, '0')}`;
    const notif: DhNotification = {
      id, title: input.title, type: input.type,
      relatedProject: input.relatedProject, relatedTask: input.relatedTask,
      raisedBy: input.raisedBy, createdAt: now.toISOString(),
      status: "Pending", priority: input.priority, unread: true,
      createdBy: input.raisedBy, createdDate: dateStr,
      history: [{ action: "Notification created", date: dateStr, time: timeStr, by: input.raisedBy }]
    };
    state.notifications.unshift(notif);
    emit();
    return notif;
  },

  acknowledgeNotification(id: string, userName: string, comment: string) {
    const notif = state.notifications.find((n) => n.id === id);
    if (!notif) return;
    const now = new Date();
    const dateStr = now.toISOString().slice(0, 10);
    const timeStr = now.toTimeString().slice(0, 8);
    notif.status = "Acknowledged";
    notif.unread = false;
    notif.acknowledgedBy = userName;
    notif.acknowledgedDate = dateStr;
    notif.acknowledgedTime = timeStr;
    notif.history.push({
      action: `Notification acknowledged - Remarks: "${comment.trim()}"`,
      date: dateStr, time: timeStr, by: userName
    });
    emit();
  },

  markNotificationAsRead(id: string) {
    const notif = state.notifications.find((n) => n.id === id);
    if (!notif) return;
    if (notif.unread) {
      notif.unread = false;
      notif.history.push({
        action: "Notification marked as read",
        date: new Date().toISOString().slice(0, 10),
        time: new Date().toTimeString().slice(0, 8),
        by: "System"
      });
      emit();
    }
  },
};

// ---------- Hooks ----------
export function useDhStore<T>(selector: (s: DhState) => T): T {
  return useSyncExternalStore(
    subscribe,
    // Always read from `snapshot` — a new object reference after every emit()
    // so React's Object.is comparison always detects a change.
    () => selector(snapshot),
    () => selector(snapshot),
  );
}
export function useDhSnapshot(): DhState {
  return useDhStore((s) => s);
}

export function canAssignPMs(projectId: string): boolean {
  const p = state.prereqs[projectId];
  if (!p) return false;
  return p.collection === "Received" && p.validation === "Validated";
}
export function getPrereq(projectId: string): DhProjectPrereq {
  return state.prereqs[projectId] ?? { projectId, validation: "Validation Pending", collection: "NA", assignedPmIds: [], assignedSpmIds: [], acknowledgedByPmIds: [], acknowledgedBySpmIds: [] };
}

// Project Stages Tracker - Helper functions
export function getProjectStages(projectId: string): ProjectStagesTracker {
  return state.projectStages[projectId] ?? {
    projectId,
    stages: {
      sales: { stageName: "Sales", currentStatus: "Pending", isCompleted: false, isActive: true, history: [] },
      pmo: { stageName: "PMO", currentStatus: "Prerequisite Collection", isCompleted: false, isActive: false, history: [] },
      delivery: { stageName: "Delivery", currentStatus: "Ongoing", isCompleted: false, isActive: false, history: [] },
      accounts: { stageName: "Accounts", currentStatus: "PO Not Raised", isCompleted: false, isActive: false, history: [] },
    },
  };
}
export function getStagesList(projectId: string): ProjectStageData[] {
  const tracker = getProjectStages(projectId);
  return [
    tracker.stages.sales,
    tracker.stages.pmo,
    tracker.stages.delivery,
    tracker.stages.accounts,
  ];
}
