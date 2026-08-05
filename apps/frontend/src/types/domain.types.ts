import type { TimesheetStatus, TimesheetEntry } from "@/lib/mock-data";

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

export type AlertStatus = "Open" | "In Progress" | "Resolved" | "Closed" | "Acknowledged" | "Waiting for Customer";

export interface DhAlert {
  id: string;
  title: string;
  kind: AlertKind;
  projectId?: string;
  raisedByName: string;
  audienceUserIds: string[];
  priority: DhPriority;
  status: AlertStatus;
  refId?: string;
  createdAt: string;
  comments: DhComment[];
  alertId?: string;
  description?: string;
  alertType?:
    | "Project Risk"
    | "Resource Risk"
    | "Technical Issue"
    | "Dependency Blocker"
    | "Escalation"
    | "Customer Concern"
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
    | "Customer Requirement Approval"
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
  badge: "Star Performer" | "Team Player" | "Innovator" | "Customer Champion";
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
export type PrereqCollectionStatus = "Initiated" | "Waiting For Customer Response" | "Received";

export interface DhServicePrereq {
  serviceId: string;
  serviceName: string;
  collectionStatus: "Pending To Collect" | "Collected";
  validationStatus: "Pending To Validate" | "Validated";
  billingStatus?: "Advance Received" | "Advance Pending" | "Advance Not Required";
  isReady?: boolean;
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
  serviceId?: string;
  serviceName?: string;
  resourceLevel?: string;
}

export interface DhAuditTrailEntry {
  id: string;
  projectId: string;
  action: string;
  performedBy: string;
  timestamp: string;
  details?: string;
}
