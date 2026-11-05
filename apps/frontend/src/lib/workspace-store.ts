// Lightweight cross-module store for Pulse PMO workflows.







// Holds runtime alerts, escalations, appreciations, interviews and prerequisite statuses.







// Uses useSyncExternalStore for reactive updates across modules.















import { useSyncExternalStore } from "react";







import { composeWbsId } from "@/lib/wbs-id";







import {







  clients as baseClients,







  projects as baseProjects,







  timesheets as baseTimesheets,







  invoices as baseInvoices,







  clientLogo,







  type Client,







  type ClientSubVenture,







  type Project,







  type Person,







  getPerson,







  registerPeople as registerPeopleInDirectory,







  hydrateKnownPeople,







  type TimesheetStatus,







  type TimesheetEntry,







  type TimesheetEntryDecision,







  type CellCommentData,







  type CellCommentMessage,







} from "@/lib/domain-models";















import {







  type Billability,







  type ResourceType,







  getProjectEMs,







  getProjectPMs,







} from "@/lib/project-helpers";















export const DEPT_GROUPS: Record<string, "Resource" | "Scope"> = {







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















export type AlertStatus =







  | "Open"







  | "In Progress"







  | "Resolved"







  | "Closed"







  | "Acknowledged"







  | "Waiting for Customer";















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















// ---------- Leadership Change Request ----------







export type LeadershipRole =







  | "Engagement Manager"







  | "Senior Project Manager"







  | "Project Manager"







  | "Team Lead";















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







  approvedAtUtc?: string;







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







  approvedAtUtc?: string;







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







  approvedAtUtc?: string;







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







  fieldChanged:







    | "Collection Status"







    | "Validation Status"







    | "Billing Status"







    | "Ready To Start"







    | "Extension Request";







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







      {







        serviceId: "s1",







        serviceName: "Application Testing",







        collectionStatus: "Collected",







        validationStatus: "Validated",







        billingStatus: "Advance Received",







        isReady: true,







      },







      {







        serviceId: "s2",







        serviceName: "SOC",







        collectionStatus: "Collected",







        validationStatus: "Validated",







        billingStatus: "Advance Received",







        isReady: true,







      },







      {







        serviceId: "s3",







        serviceName: "Infrastructure",







        collectionStatus: "Collected",







        validationStatus: "Validated",







        billingStatus: "Advance Received",







        isReady: true,







      },







      {







        serviceId: "s4",







        serviceName: "Development",







        collectionStatus: "Collected",







        validationStatus: "Validated",







        billingStatus: "Advance Received",







        isReady: true,







      },







      {







        serviceId: "s5",







        serviceName: "Migration",







        collectionStatus: "Collected",







        validationStatus: "Validated",







        billingStatus: "Advance Received",







        isReady: true,







      },







    ];







  } else {







    return [







      {







        serviceId: "s1",







        serviceName: "Application Testing",







        collectionStatus: "Collected",







        validationStatus: "Validated",







        billingStatus: "Advance Pending",







        isReady: false,







      },







      {







        serviceId: "s2",







        serviceName: "SOC",







        collectionStatus: "Collected",







        validationStatus: "Pending To Validate",







        billingStatus: "Advance Pending",







        isReady: false,







      },







      {







        serviceId: "s3",







        serviceName: "Infrastructure",







        collectionStatus: "Pending To Collect",







        validationStatus: "Pending To Validate",







        billingStatus: "Advance Pending",







        isReady: false,







      },







      {







        serviceId: "s4",







        serviceName: "Development",







        collectionStatus: "Collected",







        validationStatus: "Validated",







        billingStatus: "Advance Pending",







        isReady: false,







      },







      {







        serviceId: "s5",







        serviceName: "Migration",







        collectionStatus: "Collected",







        validationStatus: "Validated",







        billingStatus: "Advance Pending",







        isReady: false,







      },







    ];







  }







}















// ---------- Project Stages Tracker (Dhanshree Role Only) ----------







export type SalesStatus = "Pending" | "Assigned" | "Approval" | "WBS Approval Completed";







export type PMOStatus =







  | "Prerequisite Collection"







  | "Validation"







  | "Ready To Start Project"







  | "Project Allocation Completed";







export type DeliveryStatus =







  | "Ongoing"







  | "Completed"







  | "Cancelled"







  | "On Hold Internally"







  | "On Hold Externally"







  | "After Release"







  | "Certification Released";







export type AccountsStatus =







  | "PO Pending"







  | "PO Received"







  | "PO Raised"







  | "Invoice Not Raised"







  | "Invoice Raised"







  | "Payment Pending"







  | "Payment Received"







  | "PO Not Raised";







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















export interface DhBucketTask {







  id: string;







  taskId: string;







  taskTitle: string;







  projectId: string;







  projectName: string;







  priority: "low" | "medium" | "high" | "critical";







  dueDate: string;







  employeeId: string;







  assignedById: string;







  status: "Not Started" | "Ongoing" | "Paused" | "Completed" | "Stopped";







  startedAt?: string;







  completedAt?: string;







  elapsedTime: number; // in seconds







  timerRunning: boolean;







  lastStartedAt?: string;







}















// ---------- WBS Draft ----------







export interface WbsDraft {







  id: string;







  projectName: string;







  clientId: string;







  clientName: string;







  salesPerson: string;







  savedBy: string; // user name who saved the draft







  savedAt: string; // ISO timestamp







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















export interface PoDocumentRef {







  fileName: string;







  dataUrl: string;







}















interface DhState {







  extraClients: Client[];







  extraProjects: Project[];







  /** PO files attached at onboarding or later from the project Invoices tab. */







  poDocuments: Record<string, PoDocumentRef>;







  subVentureOverrides: Record<string, ClientSubVenture[]>;







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







  shadowTeamDetails: Record<







    string,







    Record<string, { duration: string; billability: Billability; resourceType: ResourceType }>







  >;







  projectTeamDetails: Record<







    string,







    Record<string, { duration: string; billability: Billability; resourceType: ResourceType }>







  >;







  projectTeamAdditions: Record<string, string[]>;







  projectTeamRemovals: Record<string, string[]>;







  leadershipChangeRequests: LeadershipChangeRequest[];







  leadershipAssignments: Record<







    string,







    { emIds: string[]; spmIds: string[]; pmIds: string[]; tlIds: string[]; teamLeadsSynced?: boolean }







  >;







  /** Cached id→person for API employees so leadership chips show names immediately. */







  knownPeople: Record<string, Person>;







  timesheets: DhTimesheet[];







  approvals: DhCentralApproval[];







  onboardedResources: OnboardedResource[];







  offboardingResources: OffboardingResource[];







  exitedResources: ExitedResource[];







  invoices: DhInvoice[];







  notifications: DhNotification[];







  treeTaskStates: Record<







    string,







    Record<







      string,







      { actualStartDate: string; actualEndDate: string; stage: string; assigneeIds: string[] }







    >







  >;







  bucketTasks: DhBucketTask[];







}















// ---------- Singleton ----------







const listeners = new Set<() => void>();







// snapshot is a shallow copy of state, replaced on every emit() so that







// useSyncExternalStore sees a new reference and triggers re-renders.







let snapshot: DhState;







const state: DhState = {







  extraClients: [],







  extraProjects: [],







  poDocuments: {},







  subVentureOverrides: {},







  wbsDrafts: [],







  onboardedResources: [],







  offboardingResources: [],







  exitedResources: [],







  issues: [],







  alerts: [],







  escalations: [],







  appreciations: [],







  interviews: [],







  requirements: [],







  prereqs: {},







  projectStages: {},







  taskAssignments: {},







  shadowTeams: {},







  shadowTeamDetails: {},







  projectTeamDetails: {},







  projectTeamAdditions: {},







  projectTeamRemovals: {},







  leadershipChangeRequests: [],







  leadershipAssignments: {},







  knownPeople: {},







  timesheets: [],







  approvals: [],







  invoices: [],







  notifications: [],







  treeTaskStates: {},







  bucketTasks: [],







};















const PERSIST_KEY = "trackerpro_store_state_clean_v1";















function loadPersistedState() {







  if (typeof window === "undefined") return;







  try {







    const raw = window.localStorage.getItem(PERSIST_KEY);







    if (!raw) return;







    const data = JSON.parse(raw);







    if (data && typeof data === "object") {
      // Ensure chat and requirements are never stored/loaded from browser memory
      delete (data as any).comments;
      delete (data as any).requirements;







      if (Array.isArray(data.extraProjects)) state.extraProjects = data.extraProjects;







      if (Array.isArray(data.extraClients)) state.extraClients = data.extraClients;







      if (data.leadershipAssignments) state.leadershipAssignments = { ...state.leadershipAssignments, ...data.leadershipAssignments };







      if (data.knownPeople && typeof data.knownPeople === "object") {







        state.knownPeople = { ...state.knownPeople, ...data.knownPeople };







        hydrateKnownPeople(state.knownPeople);







      }







      if (data.prereqs) state.prereqs = { ...state.prereqs, ...data.prereqs };







      if (Array.isArray(data.invoices)) state.invoices = data.invoices;







      if (Array.isArray(data.wbsDrafts)) state.wbsDrafts = data.wbsDrafts;







      if (data.serviceAllocationRows) state.serviceAllocationRows = { ...state.serviceAllocationRows, ...data.serviceAllocationRows };







      if (Array.isArray(data.extensionRequests)) state.extensionRequests = data.extensionRequests;







      if (Array.isArray(data.issues)) state.issues = data.issues;







      if (Array.isArray(data.alerts)) state.alerts = data.alerts;







      if (Array.isArray(data.appreciations)) state.appreciations = data.appreciations;







    }







  } catch (err) {







    console.warn("Failed to load persisted TrackerPro store state:", err);







  }







}















let persistTimer: any = null;















function persistState() {







  if (typeof window === "undefined") return;







  if (persistTimer) clearTimeout(persistTimer);







  persistTimer = setTimeout(() => {







    try {







      const toSave = {







        extraProjects: state.extraProjects,







        extraClients: state.extraClients,







        leadershipAssignments: state.leadershipAssignments,







        knownPeople: state.knownPeople,







        prereqs: state.prereqs,







        invoices: state.invoices,







        wbsDrafts: state.wbsDrafts,







        serviceAllocationRows: state.serviceAllocationRows,







        extensionRequests: state.extensionRequests,







        issues: state.issues,







        alerts: state.alerts,







        appreciations: state.appreciations,







      };







      window.localStorage.setItem(PERSIST_KEY, JSON.stringify(toSave));







    } catch (err) {







      console.warn("Failed to persist TrackerPro store state:", err);







    }







  }, 100);







}















// Hydrate state from localStorage on init







loadPersistedState();















// Initialise snapshot after state definition and hydration







snapshot = { ...state };















function emit() {







  persistState();







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















// Known client sequential codes mapped by client ID (e.g. GUID -> "C018")







const knownClientCodes: Record<string, string> = {};







const knownClientOrder: string[] = [];















/** Registers a client ID with its sequential customer code (e.g. "C018"). */







export function registerClientCode(id: string, code: string): void {







  if (!id || !code) return;







  const trimmedId = id.trim();







  const trimmedCode = code.trim();







  const cMatch = /^(?:CUST-|CL-|C-?)0*(\d+)$/i.exec(trimmedCode);







  const formatted = cMatch && cMatch[1] ? `C${cMatch[1].padStart(3, "0")}` : trimmedCode;







  knownClientCodes[trimmedId] = formatted;







  if (!knownClientOrder.includes(trimmedId)) {







    knownClientOrder.push(trimmedId);







  }







}















/** Registers a batch of clients (from API or store) to ensure deterministic C0xx customer codes. */







export function registerClients(







  clientsList: Array<{ id: string; clientCode?: string | null; createdAtUtc?: string; name?: string }>,







): void {







  if (!Array.isArray(clientsList) || clientsList.length === 0) return;















  // Sort by createdAtUtc if available, preserving creation order







  const sorted = [...clientsList].sort((a, b) => {







    if (a.createdAtUtc && b.createdAtUtc) {







      return new Date(a.createdAtUtc).getTime() - new Date(b.createdAtUtc).getTime();







    }







    return 0;







  });















  for (let i = 0; i < sorted.length; i++) {







    const c = sorted[i];







    if (!c?.id) continue;







    if (c.clientCode) {







      registerClientCode(c.id, c.clientCode);







    } else if (!knownClientCodes[c.id.trim()]) {







      const code = `C${String(i + 1).padStart(3, "0")}`;







      registerClientCode(c.id, code);







    }







  }







}















/** Returns the next sequential customer ID e.g. "C018" */







export function getNextClientCode(): string {







  let maxSeq = 0;







  // Check knownClientCodes







  for (const code of Object.values(knownClientCodes)) {







    const m = /^C(\d+)$/i.exec(code);







    if (m && m[1]) {







      const n = parseInt(m[1], 10);







      if (n > maxSeq) maxSeq = n;







    }







  }







  // Check allClients()







  try {







    const list = allClients();







    if (list.length > maxSeq) maxSeq = list.length;







    for (const c of list) {







      const raw = c.clientCode || c.id;







      const m = /^(?:CUST-|CL-|C-?)0*(\d+)$/i.exec(raw);







      if (m && m[1]) {







        const n = parseInt(m[1], 10);







        if (n > maxSeq) maxSeq = n;







      }







    }







  } catch {}







  return `C${String(maxSeq + 1).padStart(3, "0")}`;







}















// Next client sequential number → padded to 3 digits with "C" prefix e.g. "C018"







function getNextClientSeqId(): string {







  return getNextClientCode();







}















function patchProjectWbsInvoice(







  projectId: string,







  invoiceId: string,







  patch: Record<string, unknown>,







) {







  const apply = (proj: Project | undefined) => {







    const list = proj?.wbsDetails?.accounts?.invoices as any[] | undefined;







    if (!list) return;







    proj!.wbsDetails!.accounts.invoices = list.map((inv) =>







      inv.id === invoiceId ? { ...inv, ...patch } : inv,







    );







  };







  apply(state.extraProjects.find((p) => p.id === projectId));







  apply(baseProjects.find((p) => p.id === projectId));







}















// FY helper: given a date string, return which FY it belongs to (start year)







function getFYStartForDate(dateIso: string): number {







  const d = new Date(dateIso);







  const month = d.getMonth(); // 0=Jan, 3=Apr







  return month >= 3 ? d.getFullYear() : d.getFullYear() - 1;







}















// Formats a deterministic, consistent Customer ID e.g. C018, matching Customer 360 & WBS ID format







export function formatCustomerId(id?: string | null): string {







  if (!id) return "—";







  const trimmed = id.trim();















  // 1. Direct registry lookup







  if (knownClientCodes[trimmed]) {







    return knownClientCodes[trimmed];







  }















  // 2. If it already starts with CUST-, CL-, C-, or C followed by digits (e.g. C042, C42, CUST-042)







  const cMatch = /^(?:CUST-|CL-|C-?)0*(\d+)$/i.exec(trimmed);







  if (cMatch && cMatch[1]) {







    const formatted = `C${cMatch[1].padStart(3, "0")}`;







    knownClientCodes[trimmed] = formatted;







    return formatted;







  }















  if (/^c(\d+)$/i.test(trimmed)) {







    const num = trimmed.slice(1);







    const formatted = `C${num.padStart(3, "0")}`;







    knownClientCodes[trimmed] = formatted;







    return formatted;







  }















  // 3. Look up client in allClients()







  try {







    const clientsList = allClients();







    const found = clientsList.find((c) => c.id === trimmed);







    if (found?.clientCode) {







      const formatted = formatCustomerId(found.clientCode);







      knownClientCodes[trimmed] = formatted;







      return formatted;







    }







    const idx = clientsList.findIndex((c) => c.id === trimmed);







    if (idx >= 0) {







      const formatted = `C${String(idx + 1).padStart(3, "0")}`;







      knownClientCodes[trimmed] = formatted;







      return formatted;







    }







  } catch {







    // fallback if store not yet initialized







  }















  // 4. If numeric string e.g. "42"







  if (/^\d+$/.test(trimmed)) {







    const formatted = `C${trimmed.padStart(3, "0")}`;







    knownClientCodes[trimmed] = formatted;







    return formatted;







  }















  // 5. Sequential fallback for raw GUIDs (strictly sequential, NEVER random hash):







  // Assign the next sequential code and register it permanently so it never changes







  const nextSeq = getNextClientCode();







  knownClientCodes[trimmed] = nextSeq;







  return nextSeq;







}















// Next project sequential number → padded to 3 digits with "P" prefix e.g. "P044", "P045"







// Determines the next highest sequence number across all projects in the system.







function getNextProjectSeqNum(): string {







  const all = allProjects();







  let maxNum = 0;







  for (const p of all) {







    const idMatch = /^p(\d+)$/i.exec(p.id);







    if (idMatch && idMatch[1]) {







      const num = parseInt(idMatch[1], 10);







      if (num > maxNum) maxNum = num;







    }







    if (p.projectSeqId) {







      const pSeqMatch = /^P(\d+)$/i.exec(p.projectSeqId);







      if (pSeqMatch && pSeqMatch[1]) {







        const num = parseInt(pSeqMatch[1], 10);







        if (num > maxNum) maxNum = num;







      }







    }







    if (p.wbsId) {







      const wbsMatch = /[/-]P(\d+)$/i.exec(p.wbsId);







      if (wbsMatch && wbsMatch[1]) {







        const num = parseInt(wbsMatch[1], 10);







        if (num > maxNum) maxNum = num;







      }







    }







  }







  const nextNum = Math.max(maxNum + 1, all.length + 1);







  return "P" + String(nextNum).padStart(3, "0");







}















// Build WBS ID. With a sub-venture id: IN-2026-27/C013-01/P056.







// Without one, the previous hyphen form is kept for local fallback only.







export function buildWbsId(clientId: string, projectSeqIdParam?: string, subVentureCode?: string): string {







  const fyStartYear = getCurrentFYStart();







  const fyEnd = String(fyStartYear + 1).slice(-2); // last 2 digits of next year







  const fy = `${fyStartYear}-${fyEnd}`;







  const projSeq = projectSeqIdParam || getNextProjectSeqNum();







  if (subVentureCode) return composeWbsId(fy, subVentureCode, projSeq);















  const paddedClientId = formatCustomerId(clientId);







  const safeCustCode = (paddedClientId && paddedClientId !== "—") ? paddedClientId : "C001";







  return `IN-${fy}-${safeCustCode}-${projSeq}`;







}















// Build the display Project ID: P044, P045… (system sequential)







export function buildProjectDisplayId(): string {







  return getNextProjectSeqNum();







}















export const dhStore = {







  addClient(input: Omit<Client, "id" | "logo"> & { logo?: string }) {







    const id = getNextClientSeqId();







    // Logo is always derived from the client name: first + last letter.







    const logo = (clientLogo(input.name) || input.logo || "•").toUpperCase();







    const c: Client = {







      id,







      name: input.name,







      industry: input.industry,







      contact: input.contact,







      logo,







      engagementManager: input.engagementManager,







      salesManager: input.salesManager,







      // Sub-ventures (with their own contacts) come through in the payload already.







      subVentures: input.subVentures ?? [],







      contactName: input.contactName,







      contactPhone: input.contactPhone,







      contactDesignation: input.contactDesignation,







      contactType: input.contactType,







      contacts: input.contacts,







    };







    state.extraClients.push(c);







    emit();







    return c;







  },















  // Add a new sub-venture (with its own SPOC contacts + notes) to an existing client.







  addSubVenture(clientId: string, subVentureName: string, newContacts?: any[], notes?: string) {







    const trimmed = subVentureName.trim();







    const validContacts = newContacts







      ? newContacts.filter((c) => c.name?.trim() && c.email?.trim())







      : [];







    if (!trimmed) {







      emit();







      return;







    }







    const noteText = notes?.trim() || undefined;







    const subVenture: ClientSubVenture = {







      name: trimmed,







      contacts: validContacts.length > 0 ? validContacts : undefined,







      notes: noteText,







    };















    // For extra clients created at runtime, mutate directly







    const extra = state.extraClients.find((c) => c.id === clientId);







    if (extra) {







      if (!extra.subVentures?.some((sv) => sv.name === trimmed)) {







        extra.subVentures = [...(extra.subVentures ?? []), subVenture];







      }







      if (validContacts.length > 0) {







        extra.contacts = [...(extra.contacts ?? []), ...validContacts];







      }







      emit();







      return;







    }







    // For base clients, store additions in subVentureOverrides and append contacts







    if (!state.subVentureOverrides[clientId]?.some((sv) => sv.name === trimmed)) {







      state.subVentureOverrides[clientId] = [







        ...(state.subVentureOverrides[clientId] ?? []),







        subVenture,







      ];







    }







    if (validContacts.length > 0) {







      const base = baseClients.find((c) => c.id === clientId);







      if (base) {







        base.contacts = [...(base.contacts ?? []), ...validContacts];







      }







    }







    emit();







  },







  // ── WBS Drafts ──







  saveDraft(draft: Omit<WbsDraft, "id">) {







    const id = uid("draft");







    // If a draft for the same projectName + clientId exists, overwrite it







    const idx = state.wbsDrafts.findIndex(







      (d) => d.projectName === draft.projectName && d.clientId === draft.clientId,







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







    wbsStatus?:







      | "draft"







      | "approval_pending"







      | "ph_approved"







      | "accounts_approved"







      | "approved"







      | "started"







      | "assigned";







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







    subVenture?: string;







    renewedFromWbsId?: string;







    renewedFromProjectId?: string;







    isRenewal?: boolean;







    wbsId?: string;







    projectSeqId?: string;







  }) {







    const id = input.id || uid("p");







    const seqId = input.projectSeqId || getNextProjectSeqNum();







    const wbsAutoId = input.wbsId || buildWbsId(input.clientId);







    const now = new Date().toISOString();















    // Auto-generate one task per WBS service row with real data







    const autoTasks: any[] = [];







    if (input.wbsDetails?.services) {







      input.wbsDetails.services.forEach((svc: any) => {







        autoTasks.push({







          id: `${id}-svc-${svc.id}`,







          title: svc.serviceName || svc.department,







          status: "todo" as const,







          assigneeId: "",







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







      pmId: "",







      tlId: "",







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







      subVenture: input.subVenture,







      renewedFromWbsId: input.renewedFromWbsId?.trim() || undefined,







      renewedFromProjectId: input.renewedFromProjectId?.trim() || undefined,







      isRenewal: Boolean(input.isRenewal || input.renewedFromWbsId?.trim() || input.renewedFromProjectId?.trim()),







    };







    state.extraProjects.push(p);















    const poName = input.wbsDetails?.accounts?.poFileName as string | undefined;







    const poData = input.wbsDetails?.accounts?.poFileDataUrl as string | undefined;







    if (poName && poData) {







      state.poDocuments = { ...state.poDocuments, [id]: { fileName: poName, dataUrl: poData } };







    }















    // Populate state.invoices with the project's invoices if they exist







    if (input.wbsDetails?.accounts?.invoices) {







      input.wbsDetails.accounts.invoices.forEach((inv: any, idx: number) => {







        state.invoices.push({







          id: inv.id || `${id}-inv-${idx}`,







          projectId: id,







          milestone: inv.milestone,







          invoiceTargetDate: inv.targetDate || inv.invoiceDate || "",







          unitPrice: inv.unitPrice || 0,







          qty: inv.qty || 1,







          currency: inv.currency || input.currency || "INR",







          invoiceAmount: inv.amount || 0,







          invoiceStatus: inv.invoiceStatus === "Raised" ? "Raised" : "Not Raised",







          invoiceNumber: inv.invoiceNumber || "",







          paymentStatus: inv.paymentStatus === "Received" ? "Received" : "Not Received",







          paymentReceivedDate: inv.paymentDate || "",







          raisedBy: inv.invoiceStatus === "Raised" ? "Dhanshree" : undefined,







          raisedDate:







            inv.invoiceStatus === "Raised" ? inv.targetDate || inv.invoiceDate : undefined,







          paymentReceivedBy: inv.paymentStatus === "Received" ? "Accounts" : undefined,







          serviceId: inv.serviceId,







          serviceName: inv.serviceName,







          resourceLevel: inv.resourceLevel,







        });







      });







    }















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







          history: [







            {







              id: uid("sh"),







              timestamp: now,







              action: "WBS created via WBS Form",







              updatedBy: "u14",







              updatedByName: "Dhanshree",







              newStatus: initialSalesStatus,







            },







          ],







        },







        pmo: {







          stageName: "PMO",







          currentStatus: "Prerequisite Collection",







          isCompleted: false,







          isActive: false,







          history: [],







        },







        delivery: {







          stageName: "Delivery",







          currentStatus: "Ongoing",







          isCompleted: false,







          isActive: false,







          history: [],







        },







        accounts: {







          stageName: "Accounts",







          currentStatus:







            input.wbsDetails?.accounts?.poStatus === "PO Received"







              ? "PO Received"







              : input.wbsDetails?.accounts?.poStatus === "PO Pending"







                ? "PO Pending"







                : "PO Not Raised",







          isCompleted: false,







          isActive: false,







          history: [],







        },







      },







    };















    const onboardPo = input.wbsDetails?.accounts?.poStatus;







    if (onboardPo === "PO Received" || onboardPo === "PO Pending") {







      state.projectStages[id].accountsDetail = {







        poStatus: onboardPo === "PO Received" ? "PO Received" : "PO Pending",







        paymentStatus: "Payment Pending",







      };







    }















    // Initialize prerequisite record — seed services from WBS so the







    // Service-wise Prerequisite Tracking table shows real service names







    const prereqServices: DhServicePrereq[] =







      input.wbsDetails?.services?.map((svc: any, i: number) => {







        const isResourceDept = DEPT_GROUPS[svc.department] === "Resource";







        return {







          serviceId: svc.id ?? `svc-${i}`,







          serviceName: svc.serviceName ?? svc.department ?? `Service ${i + 1}`,







          collectionStatus: (isResourceDept ? "NA" : "Pending To Collect") as any,







          validationStatus: (isResourceDept ? "NA" : "Pending To Validate") as any,







          billingStatus: "Advance Pending" as const,







          isReady: false,







        };







      }) ?? [];















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















  attachPoDocument(projectId: string, fileName: string, dataUrl: string) {







    state.poDocuments = {







      ...state.poDocuments,







      [projectId]: { fileName, dataUrl },







    };















    const applyToProject = (proj: Project | undefined) => {







      if (!proj) return;







      if (!proj.wbsDetails) return;







      if (!proj.wbsDetails.accounts) return;







      proj.wbsDetails.accounts.poFileName = fileName;







      proj.wbsDetails.accounts.poFileDataUrl = dataUrl;







      const current = proj.wbsDetails.accounts.poStatus;







      if (current !== "PO Not Required") {







        proj.wbsDetails.accounts.poStatus = "PO Received";







      }







    };







    applyToProject(state.extraProjects.find((p) => p.id === projectId));







    applyToProject(baseProjects.find((p) => p.id === projectId));















    const tracker = state.projectStages[projectId];







    if (tracker) {







      const nextStatus =







        tracker.stages.accounts.currentStatus === "PO Not Raised" ||







        tracker.stages.accounts.currentStatus === "PO Pending"







          ? "PO Received"







          : tracker.stages.accounts.currentStatus;







      state.projectStages = {







        ...state.projectStages,







        [projectId]: {







          ...tracker,







          accountsDetail: {







            ...(tracker.accountsDetail ?? { poStatus: "PO Pending", paymentStatus: "Payment Pending" }),







            poStatus: "PO Received",







          },







          stages: {







            ...tracker.stages,







            accounts: {







              ...tracker.stages.accounts,







              currentStatus: nextStatus,







            },







          },







        },







      };







    }







    emit();







  },















  raiseIssue(







    input: Omit<DhIssue, "id" | "createdAt" | "comments" | "audit" | "status"> & {







      status?: DhIssueStatus;







      audienceUserIds?: string[];







    },







  ) {







    const id = uid("dhi");







    const now = new Date().toISOString();







    const issue: DhIssue = {







      ...input,







      id,







      createdAt: now,







      status: input.status ?? "Open",







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







      audienceUserIds: input.audienceUserIds || ["u1", "u3", "u4"], // SPM + PMs







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







    i.audit.push({







      id: uid("a"),







      text: `Status → ${status} by ${actorName}`,







      at: new Date().toISOString(),







    });







    const alert = state.alerts.find((a) => a.refId === id);







    if (alert) alert.status = status === "Resolved" ? "Resolved" : "Acknowledged";







    emit();







  },







  commentOnIssue(id: string, c: Omit<DhComment, "id" | "at">) {







    const i = state.issues.find((x) => x.id === id);







    if (!i) return;







        const cm: DhComment = {
      id: uid("cm"),
      authorId: updatedById,
      authorName: updatedBy,
      text: comment.trim(),
      at: now,
    };
    if (comment.trim()) {
      if (!app.comments) app.comments = [];
      const alreadyHasComment = app.comments.some(
        (c) => c.text.trim() === cm.text.trim() && (c.authorName === cm.authorName || c.authorId === cm.authorId)
      );
      if (!alreadyHasComment) {
        app.comments.push(cm);
      }
    }
    if (!app.history) app.history = [];
    const alreadyHasHistory = app.history.some(
      (h) => h.status === status && (h.comment || "").trim() === comment.trim() && h.updatedBy === updatedBy
    );
    if (!alreadyHasHistory) {
      app.history.push({
        status,
        at: now,
        updatedBy,
        comment: comment.trim(),
      });
    }
    if (app.requestType === "Customer Requirement Approval") {
      const rawReqId = id.replace(/^APP-REQ-/, "");
      const req = state.requirements.find((r) => r.id === rawReqId || r.requirementId === rawReqId);
      if (req) {
        req.status = status === "Approved" ? "Approved" : status === "Rejected" ? "Rejected" : status === "Hold" ? "Hold" : status === "Request Changes" ? "Request Changes" : "Open";
        if (status === "Approved") {
          req.approvedAtUtc = now;
        }
        if (!req.comments) req.comments = [];
        if (!req.comments.some((c) => c.text === cm.text && c.authorName === cm.authorName)) {
          req.comments.push(cm);
        }
        if (!req.history) req.history = [];
        req.history.push({
          status: req.status,
          at: now,
          updatedBy: updatedById,
          updatedByName: updatedBy,
          comment: comment.trim(),
        });
        state.requirements = [...state.requirements];
      }
    }







    // Timeline Update Logic: If it is an extension request, and it is approved, automatically update the project's endDate!







    if (id.startsWith("APP-EXT-") && status === "Approved") {







      const proj =







        state.extraProjects.find((p) => p.id === app.projectId) ||







        baseProjects.find((p) => p.id === app.projectId);







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







              newStatus: proj.endDate,







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







      history: [{ status: "Open", at: now, updatedBy }],







    });







    emit();







  },















  setServicePrereqStatus(







    projectId: string,







    serviceId: string,







    field: "collectionStatus" | "validationStatus" | "billingStatus",







    value: string,







    updatedById: string,







    updatedByName: string,







  ) {







    const currentPrereq = state.prereqs[projectId] || {







      projectId,







      validation: "Validation Pending",







      collection: "Initiated",







      assignedPmIds: [],







      assignedSpmIds: [],







      services: [],







      auditTrail: [],







    };















    const rawSvcs =







      allProjects().find((x) => x.id === projectId)?.wbsDetails?.services ?? [];







    let servicesList = currentPrereq.services ? [...currentPrereq.services] : [];















    let svcIndex = servicesList.findIndex(







      (s) => s.serviceId === serviceId || s.serviceName === serviceId,







    );







    let oldVal = "Advance Pending";















    if (svcIndex === -1) {







      const matched = rawSvcs.find(







        (x: any, i: number) =>







          (x.id ?? `svc-${i}`) === serviceId || x.serviceName === serviceId,







      );







      const isResourceDept = matched







        ? DEPT_GROUPS[matched.department] === "Resource"







        : false;







      const newSvc: DhServicePrereq = {







        serviceId,







        serviceName: matched?.serviceName ?? matched?.department ?? serviceId,







        collectionStatus: (isResourceDept ? "NA" : "Pending To Collect") as any,







        validationStatus: (isResourceDept ? "NA" : "Pending To Validate") as any,







        billingStatus: "Advance Pending" as const,







        isReady: false,







        [field]: value,







      };







      if (field === "collectionStatus" && value === "Pending To Collect") {







        newSvc.validationStatus = "Pending To Validate";







      }







      servicesList.push(newSvc);







    } else {







      const existing = servicesList[svcIndex];







      oldVal = (existing as any)[field] ?? "Advance Pending";







      const updatedSvc = {







        ...existing,







        [field]: value,







      };







      if (field === "collectionStatus" && value === "Pending To Collect") {







        updatedSvc.validationStatus = "Pending To Validate";







      }







      servicesList[svcIndex] = updatedSvc;







    }















    const now = new Date();







    const dateStr = now.toISOString().slice(0, 10);







    const timeStr = now.toTimeString().slice(0, 8);















    const auditTrail = [







      {







        id: uid("aud"),







        fieldChanged:







          field === "collectionStatus"







            ? ("Collection Status" as const)







            : field === "validationStatus"







              ? ("Validation Status" as const)







              : ("Billing Status" as const),







        updatedBy: updatedById,







        updatedByName,







        date: dateStr,







        time: timeStr,







        oldStatus: oldVal,







        newStatus: value,







      },







      ...(currentPrereq.auditTrail || []),







    ];















    const allCollected = servicesList.every(







      (s) => s.collectionStatus === "Collected" || s.collectionStatus === "NA",







    );







    const allValidated = servicesList.every(







      (s) => s.validationStatus === "Validated" || s.validationStatus === "NA",







    );















    state.prereqs = {







      ...state.prereqs,







      [projectId]: {







        ...currentPrereq,







        services: servicesList,







        auditTrail,







        collection: allCollected ? "Received" : "Initiated",







        validation: allValidated ? "Validated" : "Validation Pending",







      },







    };















    emit();







  },















  replaceServicePrereqRows(projectId: string, services: DhServicePrereq[]) {







    const currentPrereq = state.prereqs[projectId] || {







      projectId,







      validation: "Validation Pending" as const,







      collection: "Initiated" as const,







      assignedPmIds: [],







      assignedSpmIds: [],







      services: [],







      auditTrail: [],







    };







    state.prereqs = {







      ...state.prereqs,







      [projectId]: {







        ...currentPrereq,







        services,







      },







    };







    emit();







  },















  setServicePrereqReady(projectId: string, serviceId: string, isReady: boolean) {







    const currentPrereq = state.prereqs[projectId] || {







      projectId,







      validation: "Validation Pending",







      collection: "Initiated",







      assignedPmIds: [],







      assignedSpmIds: [],







      services: [],







      auditTrail: [],







    };















    const rawSvcs =







      allProjects().find((x) => x.id === projectId)?.wbsDetails?.services ?? [];







    let servicesList = currentPrereq.services ? [...currentPrereq.services] : [];







    let svcIndex = servicesList.findIndex(







      (s) => s.serviceId === serviceId || s.serviceName === serviceId,







    );















    if (svcIndex === -1) {







      const matched = rawSvcs.find(







        (x: any, i: number) =>







          (x.id ?? `svc-${i}`) === serviceId || x.serviceName === serviceId,







      );







      const isResourceDept = matched







        ? DEPT_GROUPS[matched.department] === "Resource"







        : false;







      servicesList.push({







        serviceId,







        serviceName: matched?.serviceName ?? matched?.department ?? serviceId,







        collectionStatus: (isResourceDept ? "NA" : "Collected") as any,







        validationStatus: (isResourceDept ? "NA" : "Validated") as any,







        billingStatus: "Advance Received" as const,







        isReady,







      });







    } else {







      servicesList[svcIndex] = {







        ...servicesList[svcIndex],







        isReady,







      };







    }















    state.prereqs = {







      ...state.prereqs,







      [projectId]: {







        ...currentPrereq,







        services: servicesList,







      },







    };















    emit();







  },















  submitExtensionRequest(







    projectId: string,







    newEndDate: string,







    extensionDays: number,







    reason: string,







    taggedApproverIds: string[],







    requestedByName: string,







    requestedById: string,







  ) {







    const proj = allProjects().find((p) => p.id === projectId);







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







      history: [],







    });















    // Send notifications (alerts) to all tagged approvers







    taggedApproverIds.forEach((id) => {







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







        history: [{ status: "Open", at: now.toISOString(), updatedBy: requestedByName }],







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







        newStatus: newEndDate,







      });







    }















    emit();







    return appId;







  },















  updateLeadershipAssignment(







    projectId: string,







    role: LeadershipRole,







    ids: string[],







    people?: Array<{ id: string; name: string; role?: string; avatar?: string; email?: string }>,







  ) {







    if (people?.length) {







      registerPeopleInDirectory(people);







      const nextKnown = { ...state.knownPeople };







      for (const e of people) {







        if (!e?.id || !e?.name?.trim()) continue;







        nextKnown[e.id] = getPerson(e.id);







      }







      state.knownPeople = nextKnown;







    }







    const existing = state.leadershipAssignments[projectId] ?? {







      emIds: [],







      spmIds: [],







      pmIds: [],







      tlIds: [],







    };







    // Replace the entire projectId entry with a new object so shallow-copy snapshot







    // gets a new reference and useSyncExternalStore triggers re-renders correctly.







    state.leadershipAssignments = {







      ...state.leadershipAssignments,







      [projectId]: {







        ...existing,







        ...(role === "Engagement Manager" ? { emIds: ids } : {}),







        ...(role === "Senior Project Manager" ? { spmIds: ids } : {}),







        ...(role === "Project Manager" ? { pmIds: ids } : {}),







        ...(role === "Team Lead" ? { tlIds: ids, teamLeadsSynced: true } : {}),







      },







    };







    // Keep state.prereqs synced as well







    if (role === "Project Manager" || role === "Senior Project Manager" || role === "Team Lead") {







      if (!state.prereqs[projectId]) {







        state.prereqs[projectId] = {







          projectId,







          validation: "Validation Pending",







          collection: "NA",







          assignedPmIds: [],







          assignedSpmIds: [],







          isProjectReadyToStart: false,







          services: [],







          auditTrail: [],







        };







      }







      const p = state.prereqs[projectId];







      if (role === "Project Manager") p.assignedPmIds = [...ids];







      if (role === "Senior Project Manager") p.assignedSpmIds = [...ids];







      if (role === "Team Lead") p.assignedTlIds = [...ids];







    }







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







    const proj = allProjects().find((p) => p.id === input.projectId);







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







      auditHistory: [







        {







          previousLeaderNames: input.currentLeaderNames,







          newLeaderNames: input.newLeaderNames,







          changedBy: input.requestedBy,







          effectiveDate: input.effectiveDate,







          changeReason: input.changeReason,







          status: "Pending",







        },







      ],







      createdAt: now.toISOString(),







    };







    state.leadershipChangeRequests.unshift(lcr);















    // Notify tagged people via alerts







    input.notifyPersonIds.forEach((id) => {







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







      id: `NTF-${String(count).padStart(3, "0")}`,







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







      history: [







        {







          action: "Leadership change request submitted",







          date: dateStr,







          time: timeStr,







          by: input.requestedBy,







        },







      ],







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















  updateGovernanceAlert(







    id: string,







    patch: Partial<{







      status: AlertStatus;







      owner: string;







      resolutionOwner: string;







      escalationOwner: string;







      resolutionDetails: string;







    }>,







    commentText?: string,







    actorId?: string,







    actorName?: string,







  ) {







    const al = state.alerts.find((x) => x.id === id);







    if (!al) return;















    const now = new Date().toISOString();















    if (patch.status && patch.status !== al.status) {







      if (!al.history) al.history = [];







      al.history.push({







        status: patch.status,







        at: now,







        updatedBy: actorName || "System",







        details: `Status transitioned from ${al.status} to ${patch.status}`,







      });







      al.status = patch.status;







    }















    if (patch.owner !== undefined) al.owner = patch.owner;







    if (patch.resolutionOwner !== undefined) al.resolutionOwner = patch.resolutionOwner;







    if (patch.escalationOwner !== undefined) al.escalationOwner = patch.escalationOwner;







    if (patch.resolutionDetails !== undefined) al.resolutionDetails = patch.resolutionDetails;















    if (commentText && commentText.trim() && actorId && actorName) {







      if (!al.comments) al.comments = [];







      al.comments.push({







        id: uid("cm"),







        authorId: actorId,







        authorName: actorName,







        text: commentText.trim(),







        at: now,







      });







    }















    emit();







  },















  updateAccountsDetail(projectId: string, patch: Partial<AccountsDetail>) {







    let tracker = state.projectStages[projectId];







    if (!tracker) return;







    tracker.accountsDetail = {







      ...(tracker.accountsDetail ?? { poStatus: "PO Pending", paymentStatus: "Payment Pending" }),







      ...patch,







    };







    emit();







  },















  updateOffboardingStatus(employeeId: string, patch: Partial<OffboardingResource>) {







    const idx = state.offboardingResources.findIndex((r) => r.employeeId === employeeId);







    if (idx < 0) return;







    state.offboardingResources[idx] = { ...state.offboardingResources[idx], ...patch };







    emit();







  },















  raiseInvoice(







    projectId: string,







    invoiceId: string,







    invoiceNumber: string,







    updatedBy: string = "u14",







    updatedByName: string = "Dhanshree",







  ) {







    const inv = state.invoices.find((i) => i.id === invoiceId);







    if (!inv) return;















    const now = new Date();







    const dateStr = now.toISOString().slice(0, 10);















    state.invoices = state.invoices.map((i) =>







      i.id === invoiceId







        ? {







            ...i,







            invoiceStatus: "Raised",







            invoiceNumber: invoiceNumber,







            raisedBy: updatedByName,







            raisedDate: dateStr,







            paymentStatus: "Not Received",







            paymentReceivedDate: "",







          }







        : i,







    );















    patchProjectWbsInvoice(projectId, invoiceId, {







      invoiceStatus: "Raised",







      invoiceNumber,







      remarks: invoiceNumber,







      paymentStatus: "Not Received",







      paymentDate: "",







    });















    this.updateAccountsStage(







      projectId,







      "Invoice Raised",







      `Invoice raised: ${invoiceNumber}`,







      updatedBy,







      updatedByName,







    );















    const proj = allProjects().find((x) => x.id === projectId);







    const prereq = state.prereqs[projectId];















    const ems = proj ? getProjectEMs(proj).map((x) => x.id) : [];







    const pms = proj ? getProjectPMs(proj).map((x) => x.id) : [];







    const spms = prereq?.assignedSpmIds || [];















    const audience = Array.from(







      new Set([







        "u15", // Accounts Team







        "u12", // HOD







        ...pms,







        ...spms,







        ...ems,







      ]),







    );















    audience.forEach((userId) => {







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







        history: [{ status: "Open" as any, at: now.toISOString(), updatedBy: updatedByName }],







      };







      state.alerts = [newAlert, ...state.alerts];







    });















    emit();







  },















  updatePaymentStatus(







    projectId: string,







    invoiceId: string,







    paymentStatus: "Not Received" | "Received",







    updatedBy: string = "u15",







    updatedByName: string = "Accounts Team",







  ) {







    const inv = state.invoices.find((i) => i.id === invoiceId);







    if (!inv) return;















    const now = new Date();















    let paymentReceivedDate = "";







    let paymentReceivedBy: string | undefined = undefined;















    if (paymentStatus === "Received") {







      const y = now.getFullYear();







      const m = String(now.getMonth() + 1).padStart(2, "0");







      const d = String(now.getDate()).padStart(2, "0");







      paymentReceivedDate = inv.paymentReceivedDate || `${y}-${m}-${d}`;







      paymentReceivedBy = updatedByName;







    }















    state.invoices = state.invoices.map((i) =>







      i.id === invoiceId







        ? {







            ...i,







            paymentStatus,







            paymentReceivedDate,







            paymentReceivedBy,







          }







        : i,







    );















    patchProjectWbsInvoice(projectId, invoiceId, {







      paymentStatus,







      paymentDate: paymentReceivedDate,







    });















    const updatedInv = state.invoices.find((i) => i.id === invoiceId)!;















    if (paymentStatus === "Received") {







      this.updateAccountsStage(







        projectId,







        "Payment Received",







        `Payment received captured automatically for invoice ${updatedInv.invoiceNumber}`,







        updatedBy,







        updatedByName,







      );















      const proj = allProjects().find((x) => x.id === projectId);







      const prereq = state.prereqs[projectId];















      const ems = proj ? getProjectEMs(proj).map((x) => x.id) : [];







      const pms = proj ? getProjectPMs(proj).map((x) => x.id) : [];







      const spms = prereq?.assignedSpmIds || [];















      const audience = Array.from(







        new Set([







          "u12", // HOD







          ...pms,







          ...spms,







          ...ems,







        ]),







      );















      audience.forEach((userId) => {







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







          history: [{ status: "Open" as any, at: now.toISOString(), updatedBy: updatedByName }],







        };







        state.alerts = [newAlert, ...state.alerts];







      });







    } else {







      this.updateAccountsStage(







        projectId,







        "Payment Pending",







        `Payment status reset to pending for invoice ${updatedInv.invoiceNumber}`,







        updatedBy,







        updatedByName,







      );







    }















    emit();







  },















  cancelInvoice(







    projectId: string,







    invoiceId: string,







    updatedBy: string = "u14",







    updatedByName: string = "Dhanshree",







  ) {







    const inv = state.invoices.find((i) => i.id === invoiceId);







    if (!inv) return;















    state.invoices = state.invoices.map((i) =>







      i.id === invoiceId







        ? {







            ...i,







            invoiceStatus: "Not Raised",







            invoiceNumber: "",







            raisedBy: undefined,







            raisedDate: undefined,







            paymentStatus: "Not Received",







            paymentReceivedDate: "",







          }







        : i,







    );















    patchProjectWbsInvoice(projectId, invoiceId, {







      invoiceStatus: "Not Raised",







      invoiceNumber: "",







      remarks: "",







      paymentStatus: "Not Received",







      paymentDate: "",







    });















    this.updateAccountsStage(







      projectId,







      "Invoice Not Raised",







      `Invoice reset to not raised`,







      updatedBy,







      updatedByName,







    );







    emit();







  },















  syncProjectInvoices(projectId: string, invoices: any[]) {







    if (!invoices || !Array.isArray(invoices)) return;















    const existingMap = new Map(







      state.invoices.filter((i) => i.projectId === projectId).map((i) => [i.id, i]),







    );















    const mergedInvoices: DhInvoice[] = invoices.map((inv: any, idx: number) => {







      const existing = existingMap.get(inv.id);







      const isRaised =







        inv.invoiceStatus === "Raised" ||







        inv.status === "Raised" ||







        inv.status === "Paid" ||







        inv.paymentStatus === "Received";







      const isPaid =







        inv.paymentStatus === "Received" ||







        inv.status === "Paid" ||







        Boolean(inv.paymentDate || inv.paymentReceivedDate);















      return {







        id: inv.id || `${projectId}-inv-${idx}`,







        projectId,







        milestone: inv.milestone || inv.milestoneName || `Milestone ${idx + 1}`,







        invoiceTargetDate:







          inv.invoiceTargetDate ||







          inv.targetDate ||







          inv.invoiceDate ||







          existing?.invoiceTargetDate ||







          "",







        unitPrice: inv.unitPrice ?? inv.amount ?? 0,







        qty: inv.qty || 1,







        currency: inv.currency || "INR",







        invoiceAmount: inv.invoiceAmount || inv.amount || 0,







        invoiceStatus: isRaised ? "Raised" : "Not Raised",







        invoiceNumber: inv.invoiceNumber || existing?.invoiceNumber || "",







        paymentStatus: isPaid ? "Received" : "Not Received",







        paymentReceivedDate:







          inv.paymentReceivedDate || inv.paymentDate || existing?.paymentReceivedDate || "",







        raisedBy: existing?.raisedBy || (isRaised ? "Dhanshree" : undefined),







        raisedDate:







          existing?.raisedDate ||







          inv.raisedDate ||







          (isRaised ? inv.targetDate || inv.invoiceDate : undefined),







        paymentReceivedBy:







          existing?.paymentReceivedBy || (isPaid ? "Accounts" : undefined),







        serviceId: inv.serviceId,







        serviceName: inv.serviceName,







        resourceLevel: inv.resourceLevel,







      };







    });















    state.invoices = [







      ...state.invoices.filter((i) => i.projectId !== projectId),







      ...mergedInvoices,







    ];







    emit();







  },















  updateInvoiceTargetDate(projectId: string, invoiceId: string, targetDate: string) {







    state.invoices = state.invoices.map((i) =>







      i.id === invoiceId ? { ...i, invoiceTargetDate: targetDate } : i,







    );







    patchProjectWbsInvoice(projectId, invoiceId, { targetDate, invoiceDate: targetDate });







    emit();







  },















  updatePaymentReceivedDate(projectId: string, invoiceId: string, date: string) {







    const inv = state.invoices.find((i) => i.id === invoiceId);







    if (!inv) return;















    const paymentStatus = date.trim() ? "Received" : "Not Received";















    state.invoices = state.invoices.map((i) =>







      i.id === invoiceId







        ? {







            ...i,







            paymentReceivedDate: date,







            paymentStatus,







            paymentReceivedBy: date.trim() ? "Accounts" : undefined,







          }







        : i,







    );







    patchProjectWbsInvoice(projectId, invoiceId, { paymentDate: date, paymentStatus });







    emit();







  },















  archiveProject(







    projectId: string,







    updatedBy: string = "u14",







    updatedByName: string = "Dhanshree",







  ) {







    const bp = baseProjects.find((p) => p.id === projectId);







    if (bp) {







      bp.status = "completed" as any;







    }







    const ep = state.extraProjects.find((p) => p.id === projectId);







    if (ep) {







      ep.status = "completed" as any;







    }







    if (state.projectStages[projectId]) {







      const stg = state.projectStages[projectId].stages;







      stg.sales.isCompleted = true;







      stg.pmo.isCompleted = true;







      stg.delivery.isCompleted = true;







      stg.accounts.isCompleted = true;







      stg.accounts.currentStatus = "Payment Received";







    }







    emit();







  },















  setNotifications(notifications: DhNotification[]) {







    state.notifications = Array.isArray(notifications) ? notifications : [];







    emit();







  },

  setRequirements(requirements: DhAdditionalRequirement[]) {

    state.requirements = Array.isArray(requirements) ? requirements : [];

    emit();

  },
  mergeRequirements(requirements: DhAdditionalRequirement[]) {
    if (!Array.isArray(requirements)) return;
    requirements.forEach((req) => {
      const idx = state.requirements.findIndex((r) => r.id === req.id || r.requirementId === req.requirementId);
      if (idx >= 0) {
        const existing = state.requirements[idx];
        const mergedComments = (req.comments && req.comments.length > 0) ? req.comments : (existing.comments || []);
        const mergedHistory = (req.history && req.history.length > 0) ? req.history : (existing.history || []);
        state.requirements[idx] = { ...existing, ...req, comments: mergedComments, history: mergedHistory };
      } else {
        state.requirements.push(req);
      }
    });
    state.requirements = [...state.requirements];
    emit();
  },

  setApprovals(approvals: DhCentralApproval[]) {

    state.approvals = Array.isArray(approvals) ? approvals : [];

    emit();

  },

  mergeApprovals(approvals: DhCentralApproval[]) {

    if (!Array.isArray(approvals)) return;

    approvals.forEach((app) => {

      const idx = state.approvals.findIndex((a) => a.id === app.id);

      if (idx >= 0) {

        state.approvals[idx] = { ...state.approvals[idx], ...app };

      } else {

        state.approvals.unshift(app);

      }

    });

    emit();

  },















  setAlerts(alerts: DhAlert[]) {







    state.alerts = Array.isArray(alerts)







      ? alerts.map((a) => ({







          ...a,







          comments: Array.isArray(a.comments) ? a.comments : [],







          attachments: Array.isArray(a.attachments) ? a.attachments : [],







          history: Array.isArray(a.history) ? a.history : [],







        }))







      : [];







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







    const id = `NTF-${String(count).padStart(3, "0")}`;







    const notif: DhNotification = {







      id,







      title: input.title,







      type: input.type,







      relatedProject: input.relatedProject,







      relatedTask: input.relatedTask,







      raisedBy: input.raisedBy,







      createdAt: now.toISOString(),







      status: "Pending",







      priority: input.priority,







      unread: true,







      createdBy: input.raisedBy,







      createdDate: dateStr,







      history: [







        { action: "Notification created", date: dateStr, time: timeStr, by: input.raisedBy },







      ],







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







      date: dateStr,







      time: timeStr,







      by: userName,







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







        by: "System",







      });







      emit();







    }







  },















  // ── Tree Task State (hierarchical task tree) ──────────────────────────────







  getTreeTaskState(







    projectId: string,







    taskId: string,







  ): { actualStartDate: string; actualEndDate: string; stage: string; assigneeIds: string[] } {







    return (







      state.treeTaskStates[projectId]?.[taskId] ?? {







        actualStartDate: "",







        actualEndDate: "",







        stage: "Not Started",







        assigneeIds: [],







      }







    );







  },







  updateTreeTaskState(







    projectId: string,







    taskId: string,







    patch: Partial<{







      actualStartDate: string;







      actualEndDate: string;







      stage: string;







      assigneeIds: string[];







    }>,







  ) {







    if (!state.treeTaskStates[projectId]) state.treeTaskStates[projectId] = {};







    const prev = state.treeTaskStates[projectId][taskId] ?? {







      actualStartDate: "",







      actualEndDate: "",







      stage: "Not Started",







      assigneeIds: [],







    };







    state.treeTaskStates[projectId][taskId] = { ...prev, ...patch };







    // Replace top-level reference so snapshot sees new object







    state.treeTaskStates = { ...state.treeTaskStates };







    emit();







  },







  getTreeTaskAssignees(projectId: string, taskId: string): string[] {







    return state.treeTaskStates[projectId]?.[taskId]?.assigneeIds ?? [];







  },







  getTreeTaskAssignment(projectId: string, taskId: string): TaskAssignmentState {







    let existing = state.taskAssignments[taskId];







    if (existing) return existing;







    const newState: TaskAssignmentState = {







      taskId,







      assigneeIds: [],







      history: [],







    };







    state.taskAssignments[taskId] = newState;







    emit();







    return newState;







  },







  assignResourcesToTreeTask(







    projectId: string,







    taskId: string,







    selectedIds: string[],







    taskTitle?: string,







    dueDate?: string,







    priority?: "low" | "medium" | "high" | "critical",







    updatedBy: string = "u14",







  ) {







    const current = this.getTreeTaskAssignment(projectId, taskId);







    const prevIds = current.assigneeIds;







    const added = selectedIds.filter((id) => !prevIds.includes(id));







    const removed = prevIds.filter((id) => !selectedIds.includes(id));







    const now = new Date().toISOString();







    const shadowTeamList = state.shadowTeams[projectId] ?? [];















    added.forEach((id) => {







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







        updatedBy,







      });







    });







    removed.forEach((id) => {







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







        updatedBy,







      });







    });







    current.assigneeIds = selectedIds;















    if (!state.treeTaskStates[projectId]) state.treeTaskStates[projectId] = {};







    const prev = state.treeTaskStates[projectId][taskId] ?? {







      actualStartDate: "",







      actualEndDate: "",







      stage: "Not Started",







      assigneeIds: [],







    };















    let newStage = prev.stage;







    if (selectedIds.length > 0) {







      if (prev.stage === "Not Started" || !prev.stage) {







        newStage = "Assigned";







      }







    } else {







      if (prev.stage === "Assigned") {







        newStage = "Not Started";







      }







    }















    state.treeTaskStates[projectId][taskId] = {







      ...prev,







      assigneeIds: selectedIds,







      stage: newStage,







    };







    state.treeTaskStates = { ...state.treeTaskStates };















    // Update bucket tasks







    const proj = allProjects().find((p) => p.id === projectId);







    const projectName = proj?.name || "Project";















    if (!state.bucketTasks) state.bucketTasks = [];















    // Remove bucket tasks for unassigned resources







    state.bucketTasks = state.bucketTasks.filter((bt) => {







      if (bt.taskId === taskId) {







        return selectedIds.includes(bt.employeeId);







      }







      return true;







    });















    // Add new bucket tasks for assigned resources







    selectedIds.forEach((empId) => {







      const bucketTaskId = `${taskId}-${empId}`;







      const exists = state.bucketTasks.some((bt) => bt.id === bucketTaskId);







      if (!exists) {







        state.bucketTasks.push({







          id: bucketTaskId,







          taskId,







          taskTitle: taskTitle || "Execute Task",







          projectId,







          projectName,







          priority: priority || "medium",







          dueDate:







            dueDate ||







            proj?.endDate ||







            new Date(Date.now() + 7 * 86400000).toISOString().slice(0, 10),







          employeeId: empId,







          assignedById: updatedBy,







          status: "Not Started",







          elapsedTime: 0,







          timerRunning: false,







        });







      }







    });















    emit();







  },















  startBucketTask(bucketTaskId: string) {







    const bt = state.bucketTasks.find((x) => x.id === bucketTaskId);







    if (!bt) return;







    const now = new Date().toISOString();







    bt.status = "Ongoing";







    bt.timerRunning = true;







    bt.lastStartedAt = now;







    if (!bt.startedAt) {







      bt.startedAt = now;







    }















    // Sync back to project treeTaskState







    const treeState = state.treeTaskStates[bt.projectId]?.[bt.taskId];







    if (treeState) {







      if (treeState.stage === "Not Started" || treeState.stage === "Assigned") {







        treeState.stage = "Ongoing";







        if (!treeState.actualStartDate) {







          treeState.actualStartDate = now.slice(0, 10);







        }







        state.treeTaskStates = { ...state.treeTaskStates };







      }







    }







    emit();







  },















  pauseBucketTask(bucketTaskId: string) {







    const bt = state.bucketTasks.find((x) => x.id === bucketTaskId);







    if (!bt) return;







    if (bt.timerRunning && bt.lastStartedAt) {







      const elapsed = Math.floor((Date.now() - new Date(bt.lastStartedAt).getTime()) / 1000);







      bt.elapsedTime += Math.max(0, elapsed);







    }







    bt.status = "Paused";







    bt.timerRunning = false;







    bt.lastStartedAt = undefined;







    emit();







  },















  stopBucketTask(bucketTaskId: string) {







    const bt = state.bucketTasks.find((x) => x.id === bucketTaskId);







    if (!bt) return;







    if (bt.timerRunning && bt.lastStartedAt) {







      const elapsed = Math.floor((Date.now() - new Date(bt.lastStartedAt).getTime()) / 1000);







      bt.elapsedTime += Math.max(0, elapsed);







    }







    bt.status = "Stopped";







    bt.timerRunning = false;







    bt.lastStartedAt = undefined;







    emit();







  },















  resumeBucketTask(bucketTaskId: string) {







    const bt = state.bucketTasks.find((x) => x.id === bucketTaskId);







    if (!bt) return;







    const now = new Date().toISOString();







    bt.status = "Ongoing";







    bt.timerRunning = true;







    bt.lastStartedAt = now;







    emit();







  },















  completeBucketTask(bucketTaskId: string) {







    const bt = state.bucketTasks.find((x) => x.id === bucketTaskId);







    if (!bt) return;







    const now = new Date().toISOString();







    if (bt.timerRunning && bt.lastStartedAt) {







      const elapsed = Math.floor((Date.now() - new Date(bt.lastStartedAt).getTime()) / 1000);







      bt.elapsedTime += Math.max(0, elapsed);







    }







    bt.status = "Completed";







    bt.timerRunning = false;







    bt.lastStartedAt = undefined;







    bt.completedAt = now;















    // Check other bucket tasks for the same tree task







    const siblingTasks = state.bucketTasks.filter((x) => x.taskId === bt.taskId);







    const allCompleted = siblingTasks.every((x) => x.status === "Completed");















    const treeState = state.treeTaskStates[bt.projectId]?.[bt.taskId];







    if (treeState) {







      if (allCompleted) {







        treeState.stage = "Completed";







        treeState.actualEndDate = now.slice(0, 10);







      } else {







        treeState.stage = "Ongoing";







      }







      state.treeTaskStates = { ...state.treeTaskStates };







    }







    emit();







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







  return (







    state.prereqs[projectId] ?? {







      projectId,







      validation: "Validation Pending",







      collection: "NA",







      assignedPmIds: [],







      assignedSpmIds: [],







      acknowledgedByPmIds: [],







      acknowledgedBySpmIds: [],







    }







  );







}















// Project Stages Tracker - Helper functions







export function getProjectStages(projectId: string): ProjectStagesTracker {







  return (







    state.projectStages[projectId] ?? {







      projectId,







      stages: {







        sales: {







          stageName: "Sales",







          currentStatus: "Pending",







          isCompleted: false,







          isActive: true,







          history: [],







        },







        pmo: {







          stageName: "PMO",







          currentStatus: "Prerequisite Collection",







          isCompleted: false,







          isActive: false,







          history: [],







        },







        delivery: {







          stageName: "Delivery",







          currentStatus: "Ongoing",







          isCompleted: false,







          isActive: false,







          history: [],







        },







        accounts: {







          stageName: "Accounts",







          currentStatus: "PO Not Raised",







          isCompleted: false,







          isActive: false,







          history: [],







        },







      },







    }







  );







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




