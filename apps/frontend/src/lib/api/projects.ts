import { apiFetch, API_BASE } from "@/lib/api-client";

export interface ApiProject {
  id: string;
  projectCode: string;
  wbsId?: string | null;
  name: string;
  description?: string | null;
  clientId: string;
  clientName: string;
  clientLogo?: string | null;
  subVentureId?: string | null;
  subVentureName?: string | null;
  status: string;
  health: string;
  progress: number;
  contractType?: string | null;
  projectType?: string | null;
  currency: string;
  taxPercent: number;
  startDate?: string | null;
  endDate?: string | null;
  budget?: number | null;
  spent: number;
  totalHours?: number | null;
  totalDays?: number | null;
  invoiceValue?: number | null;
  projectManagerId?: string | null;
  projectManagerName?: string | null;
  teamLeadId?: string | null;
  teamLeadName?: string | null;
  engagementManager?: string | null;
  engagementManagerId?: string | null;
  salesPerson?: string | null;
  salesPersonId?: string | null;
  projectIssuedDate?: string | null;
  sectionAComments?: string | null;
  sectionBComments?: string | null;
  wbsStatus: string;
  wbsSubStatus?: string | null;
  renewedFromProjectId?: string | null;
  renewedFromWbsId?: string | null;
  poStatus?: string | null;
  poNumber?: string | null;
  poDate?: string | null;
  billingModel?: string | null;
  paymentTerms?: string | null;
  targetDate?: string | null;
  accountContactName?: string | null;
  accountContactPhone?: string | null;
  accountContactEmail?: string | null;
  createdAtUtc: string;
  updatedAtUtc?: string | null;
}

export interface NextProjectCodeResult {
  projectSeqId: string;
  wbsId: string;
  financialYear: string;
  clientProjectCount: number;
  formattedClientProjectCount: string;
}

export interface ProjectQueryParams {
  clientId?: string;
  status?: string;
  wbsStatus?: string;
  search?: string;
  page?: number;
  perPage?: number;
  sortBy?: string;
  sortDescending?: boolean;
}

export interface PagedResult<T> {
  items: T[];
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
}

export interface CreateProjectPayload {
  clientId: string;
  subVentureId?: string | null;
  name?: string | null;
  description?: string | null;
  status?: string;
  health?: string;
  projectCode?: string | null;
  wbsId?: string | null;
  contractType?: string | null;
  projectType?: string | null;
  currency?: string;
  taxPercent?: number;
  startDate?: string | null;
  endDate?: string | null;
  budget?: number | null;
  totalHours?: number | null;
  totalDays?: number | null;
  invoiceValue?: number | null;
  projectManagerId?: string | null;
  teamLeadId?: string | null;
  engagementManager?: string | null;
  engagementManagerId?: string | null;
  salesPerson?: string | null;
  salesPersonId?: string | null;
  projectIssuedDate?: string | null;
  sectionAComments?: string | null;
  sectionBComments?: string | null;
  wbsStatus?: string;
  wbsSubStatus?: string | null;
  renewedFromProjectId?: string | null;
  renewedFromWbsId?: string | null;
  poStatus?: string | null;
  poNumber?: string | null;
  poDate?: string | null;
  billingModel?: string | null;
  paymentTerms?: string | null;
  targetDate?: string | null;
  accountContactName?: string | null;
  accountContactPhone?: string | null;
  accountContactEmail?: string | null;
  subDepartmentNames?: string[] | null;
}

export interface UpdateProjectPayload {
  name: string;
  description?: string | null;
  status?: string | null;
  health?: string | null;
  progress?: number | null;
  contractType?: string | null;
  projectType?: string | null;
  currency?: string | null;
  taxPercent?: number | null;
  startDate?: string | null;
  endDate?: string | null;
  budget?: number | null;
  spent?: number | null;
  totalHours?: number | null;
  totalDays?: number | null;
  invoiceValue?: number | null;
  projectManagerId?: string | null;
  teamLeadId?: string | null;
  engagementManager?: string | null;
  engagementManagerId?: string | null;
  salesPerson?: string | null;
  salesPersonId?: string | null;
  projectIssuedDate?: string | null;
  sectionAComments?: string | null;
  sectionBComments?: string | null;
  wbsStatus?: string | null;
  wbsSubStatus?: string | null;
  poStatus?: string | null;
  poNumber?: string | null;
  poDate?: string | null;
  billingModel?: string | null;
  paymentTerms?: string | null;
  targetDate?: string | null;
  accountContactName?: string | null;
  accountContactPhone?: string | null;
  accountContactEmail?: string | null;
}

// ── Project Services ──

export interface ProjectServiceResourceLevelDto {
  level: string;
  count: number;
}

export interface ApiProjectService {
  id: string;
  projectId: string;
  serviceCatalogId?: string | null;
  taskId?: string | null;
  department: string;
  subDepartment?: string | null;
  serviceName: string;
  qty: number;
  description?: string | null;
  resourceLevel?: string | null;
  frequency?: string | null;
  location?: string | null;
  locationText?: string | null;
  serviceModel?: string | null;
  deliveryModel?: string | null;
  finalDeliveryFormat?: string | null;
  billingModel?: string | null;
  tools?: string | null;
  startDate?: string | null;
  endDate?: string | null;
  durationDays?: number | null;
  durationHours?: number | null;
  totalDays?: number | null;
  totalHours?: number | null;
  unitPrice?: number | null;
  total?: number | null;
  sortOrder: number;
  resourceLevels: ProjectServiceResourceLevelDto[];
}

export interface CreateProjectServicePayload {
  serviceCatalogId?: string | null;
  taskId?: string | null;
  department: string;
  subDepartment?: string | null;
  serviceName: string;
  qty?: number;
  description?: string | null;
  resourceLevel?: string | null;
  frequency?: string | null;
  location?: string | null;
  locationText?: string | null;
  serviceModel?: string | null;
  deliveryModel?: string | null;
  finalDeliveryFormat?: string | null;
  billingModel?: string | null;
  tools?: string | null;
  startDate?: string | null;
  endDate?: string | null;
  durationDays?: number | null;
  unitPrice?: number | null;
  sortOrder?: number;
  resourceLevels?: ProjectServiceResourceLevelDto[] | null;
}

// ── Project Tasks & Assignments ──

export interface ApiProjectTask {
  id: string;
  projectId: string;
  projectServiceId?: string | null;
  serviceName?: string | null;
  title: string;
  description?: string | null;
  period?: string | null;
  phase?: string | null;
  stage: string;
  priority: string;
  plannedStartDate?: string | null;
  plannedEndDate?: string | null;
  actualStartDate?: string | null;
  actualEndDate?: string | null;
  estimatedHours?: number | null;
  utilizedHours: number;
  progress: number;
  sortOrder: number;
  assignments: ApiProjectTaskAssignment[];
}

export interface CreateProjectTaskPayload {
  projectServiceId?: string | null;
  title: string;
  description?: string | null;
  period?: string | null;
  phase?: string | null;
  stage?: string;
  priority?: string;
  plannedStartDate?: string | null;
  plannedEndDate?: string | null;
  actualStartDate?: string | null;
  actualEndDate?: string | null;
  estimatedHours?: number | null;
  progress?: number;
  sortOrder?: number;
}

export interface UpdateProjectTaskPayload {
  title: string;
  description?: string | null;
  period?: string | null;
  phase?: string | null;
  stage?: string;
  priority?: string;
  plannedStartDate?: string | null;
  plannedEndDate?: string | null;
  actualStartDate?: string | null;
  actualEndDate?: string | null;
  estimatedHours?: number | null;
  progress?: number;
  sortOrder?: number;
}

export interface ApiProjectTaskAssignment {
  id: string;
  taskId: string;
  employeeId: string;
  employeeName: string;
  employeeCode: string;
  workEmail: string;
  role: string;
  allocatedHours?: number | null;
  utilizedHours: number;
  timerStartedAtUtc?: string | null;
  timerAccumulatedSeconds: number;
  isTimerRunning: boolean;
  currentElapsedSeconds: number;
  isActive: boolean;
}

export interface CreateTaskAssignmentPayload {
  employeeId: string;
  role?: string;
  allocatedHours?: number | null;
}

export interface UpdateTaskAssignmentPayload {
  role?: string;
  allocatedHours?: number | null;
  utilizedHours?: number;
  isActive?: boolean;
}

// ── Project Invoices ──

export interface ApiProjectInvoice {
  id: string;
  projectId: string;
  milestoneName: string;
  percentage?: number | null;
  amount: number;
  taxAmount: number;
  totalAmount: number;
  status: string;
  invoiceNumber?: string | null;
  invoiceDate?: string | null;
  dueDate?: string | null;
  paymentDate?: string | null;
  remarks?: string | null;
  sortOrder: number;
  createdAtUtc: string;
}

export interface CreateProjectInvoicePayload {
  milestoneName: string;
  percentage?: number | null;
  amount: number;
  taxAmount?: number;
  totalAmount?: number;
  status?: string;
  invoiceNumber?: string | null;
  invoiceDate?: string | null;
  dueDate?: string | null;
  paymentDate?: string | null;
  remarks?: string | null;
  sortOrder?: number;
}

// ── Project Documents ──

export interface ApiProjectDocument {
  id: string;
  projectId: string;
  fileName: string;
  category: string;
  size: number;
  uploadedBy: string;
  filePath: string;
  poNumber?: string | null;
  poDate?: string | null;
  uploadedAtUtc: string;
}

// ── WBS Draft & Publishing ──

export interface SaveWbsDraftPayload {
  sectionAComments?: string | null;
  sectionBComments?: string | null;
  wbsSubStatus?: string;
  services?: CreateProjectServicePayload[] | null;
  tasks?: CreateProjectTaskPayload[] | null;
}

export interface WbsPublishResult {
  projectId: string;
  wbsId: string;
  wbsStatus: string;
  wbsSubStatus: string;
  serviceCount: number;
  taskCount: number;
  totalBudget: number;
  totalHours: number;
  publishedAtUtc: string;
}

// ── API Caller Functions ──

/** GET /api/v1/projects */
export async function fetchProjects(params?: ProjectQueryParams): Promise<PagedResult<ApiProject>> {
  const query = new URLSearchParams();
  if (params?.clientId) query.set("clientId", params.clientId);
  if (params?.status) query.set("status", params.status);
  if (params?.wbsStatus) query.set("wbsStatus", params.wbsStatus);
  if (params?.search) query.set("search", params.search);
  if (params?.page) query.set("page", String(params.page));
  if (params?.perPage) {
    query.set("perPage", String(params.perPage));
    query.set("pageSize", String(params.perPage));
  }
  if (params?.sortBy) query.set("sortBy", params.sortBy);
  if (params?.sortDescending !== undefined) query.set("sortDescending", String(params.sortDescending));

  const qs = query.toString();
  const res = await apiFetch<PagedResult<ApiProject>>(`/api/v1/projects${qs ? `?${qs}` : ""}`);
  return res ?? { items: [], page: 1, perPage: 20, total: 0, totalPages: 0 };
}

/** Map backend ApiProject to frontend Project model */
export function mapApiProjectToProject(
  ap: ApiProject,
  apiServices?: ApiProjectService[],
  apiInvoices?: ApiProjectInvoice[]
): any {
  const rawServices: any[] = (apiServices ?? (ap as any).services ?? (ap as any).projectServices ?? []);
  const services = rawServices.map((s: any, idx: number) => ({
    id: s.id ?? s.taskId ?? `s-${idx}`,
    department: s.department || "Engineering",
    subDepartment: s.subDepartment || "",
    serviceName: s.serviceName || `Service ${idx + 1}`,
    description: s.description || "",
    resourceLevel: s.resourceLevel || "",
    qty: s.qty || 1,
    frequency: s.frequency || "Once",
    serviceModel: s.serviceModel || "Initial Test",
    deliveryModel: s.deliveryModel || "Offshore",
    location: s.location || "Offshore",
    locationText: s.locationText || "",
    finalDeliveryFormat: s.finalDeliveryFormat || "Report",
    tools: s.tools || "Jira",
    billingModel: s.billingModel || ap.billingModel || "Fixed Price",
    startDate: s.startDate ? String(s.startDate) : (ap.startDate ? String(ap.startDate) : ""),
    endDate: s.endDate ? String(s.endDate) : (ap.endDate ? String(ap.endDate) : ""),
    duration: s.durationDays || 30,
    durationDays: s.durationDays || 30,
    durationHours: s.durationHours || ((s.durationDays || 30) * 8),
    totalDays: s.totalDays || s.durationDays || 30,
    totalHrs: s.totalHours || s.durationHours || ((s.totalDays || s.durationDays || 30) * 8),
    unitPrice: s.unitPrice || 0,
    total: s.total || ((s.unitPrice || 0) * (s.qty || 1)),
  }));

  const rawInvoices: any[] = (apiInvoices ?? (ap as any).invoices ?? (ap as any).projectInvoices ?? []);
  const invoices = rawInvoices.map((inv: any, idx: number) => ({
    id: inv.id ?? `inv-${idx}`,
    serviceId: inv.projectServiceId ?? "",
    serviceName: inv.serviceName ?? "",
    milestone: inv.milestoneName ?? inv.milestone ?? `Milestone ${idx + 1}`,
    targetDate: inv.invoiceDate ?? inv.dueDate ?? inv.targetDate ?? "",
    invoiceDate: inv.invoiceDate ?? inv.dueDate ?? inv.targetDate ?? "",
    unitPrice: inv.amount ?? 0,
    amount: inv.amount ?? 0,
    status: inv.status ?? "Not Raised",
    remarks: inv.remarks ?? inv.invoiceNumber ?? "",
  }));

  const wbsDetails = {
    contractType: ap.contractType ?? undefined,
    projectType: ap.projectType ?? undefined,
    engagementManager: ap.engagementManager ?? undefined,
    salesPerson: ap.salesPerson ?? undefined,
    currency: ap.currency ?? "INR",
    taxPercent: ap.taxPercent ?? 18,
    services,
    accounts: {
      poStatus: ap.poStatus || undefined,
      poNumber: ap.poNumber || undefined,
      poDate: ap.poDate ? String(ap.poDate) : undefined,
      billingModel: ap.billingModel || undefined,
      paymentTerms: ap.paymentTerms || undefined,
      targetDate: ap.targetDate ? String(ap.targetDate) : undefined,
      contactName: ap.accountContactName || undefined,
      contactNumber: ap.accountContactPhone || undefined,
      contactEmail: ap.accountContactEmail || undefined,
      invoices,
    },
  };

  const validStarts = services
    .map((s: any) => (typeof s.startDate === "string" ? s.startDate.trim() : ""))
    .filter((d: string) => Boolean(d && !isNaN(new Date(d).getTime())))
    .sort((a: string, b: string) => new Date(a).getTime() - new Date(b).getTime());

  const validEnds = services
    .map((s: any) => (typeof s.endDate === "string" ? s.endDate.trim() : ""))
    .filter((d: string) => Boolean(d && !isNaN(new Date(d).getTime())))
    .sort((a: string, b: string) => new Date(a).getTime() - new Date(b).getTime());

  const projectStartDate = validStarts.length > 0
    ? validStarts[0]
    : (ap.startDate ? String(ap.startDate) : new Date().toISOString().slice(0, 10));

  const projectEndDate = validEnds.length > 0
    ? validEnds[validEnds.length - 1]
    : (ap.endDate ? String(ap.endDate) : new Date(Date.now() + 30 * 86400000).toISOString().slice(0, 10));

  return {
    id: ap.id,
    name: ap.name || ap.projectCode || "Untitled Project",
    clientId: ap.clientId,
    status: (ap.status?.toLowerCase() as any) || "ongoing",
    health: (ap.health?.toLowerCase() as any) || "green",
    progress: ap.progress ?? 0,
    pmId: ap.projectManagerId ?? "u2",
    tlId: ap.teamLeadId ?? "",
    teamIds: [],
    startDate: projectStartDate,
    endDate: projectEndDate,
    budget: ap.budget ?? ap.invoiceValue ?? 0,
    spent: ap.spent ?? 0,
    description: ap.description || "",
    wbs: [],
    tasks: [],
    wbsDetails,
    wbsId: ap.wbsId ?? undefined,
    projectSeqId: ap.projectCode,
    subVenture: ap.subVentureName ?? undefined,
    contractType: ap.contractType ?? undefined,
    projectType: ap.projectType ?? undefined,
    engagementManager: ap.engagementManager ?? undefined,
    salesPerson: ap.salesPerson ?? undefined,
    projectIssuedDate: ap.projectIssuedDate ? String(ap.projectIssuedDate) : undefined,
    currency: ap.currency ?? "INR",
    taxPercent: ap.taxPercent ?? 18,
    sectionAComments: ap.sectionAComments ?? undefined,
    sectionBComments: ap.sectionBComments ?? undefined,
    wbsStatus: (ap.wbsStatus?.toLowerCase() as any) || "draft",
    wbsSubStatus: ap.wbsSubStatus ?? undefined,
    renewedFromProjectId: ap.renewedFromProjectId ?? undefined,
    renewedFromWbsId: ap.renewedFromWbsId ?? undefined,
    projectManagerId: ap.projectManagerId ?? undefined,
    projectManagerName: ap.projectManagerName ?? undefined,
    teamLeadId: ap.teamLeadId ?? undefined,
    teamLeadName: ap.teamLeadName ?? undefined,
  };
}

/** GET /api/v1/projects/{id} */
export async function fetchProject(id: string): Promise<ApiProject | null> {
  return apiFetch<ApiProject>(`/api/v1/projects/${id}`);
}

/** GET /api/v1/projects/next-code?clientId= */
export async function fetchNextProjectCode(clientId: string): Promise<NextProjectCodeResult | null> {
  return apiFetch<NextProjectCodeResult>(`/api/v1/projects/next-code?clientId=${encodeURIComponent(clientId)}`);
}

/** POST /api/v1/projects */
export async function createProject(payload: CreateProjectPayload): Promise<ApiProject> {
  return apiFetch<ApiProject>("/api/v1/projects", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** PUT /api/v1/projects/{id} */
export async function updateProject(id: string, payload: UpdateProjectPayload): Promise<ApiProject> {
  return apiFetch<ApiProject>(`/api/v1/projects/${id}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

/** DELETE /api/v1/projects/{id} */
export async function deleteProject(id: string): Promise<boolean> {
  return apiFetch<boolean>(`/api/v1/projects/${id}`, { method: "DELETE" });
}

/** PATCH /api/v1/projects/{id}/status */
export async function updateProjectStatus(id: string, status: string): Promise<ApiProject> {
  return apiFetch<ApiProject>(`/api/v1/projects/${id}/status`, {
    method: "PATCH",
    body: JSON.stringify({ status }),
  });
}

/** PATCH /api/v1/projects/{id}/wbs-status */
export async function updateWbsStatus(id: string, wbsStatus: string, wbsSubStatus?: string): Promise<ApiProject> {
  return apiFetch<ApiProject>(`/api/v1/projects/${id}/wbs-status`, {
    method: "PATCH",
    body: JSON.stringify({ wbsStatus, wbsSubStatus }),
  });
}

// ── Project Services Methods ──

/** GET /api/v1/projects/{projectId}/services */
export async function fetchProjectServices(projectId: string): Promise<ApiProjectService[]> {
  return (await apiFetch<ApiProjectService[]>(`/api/v1/projects/${projectId}/services`)) ?? [];
}

/** POST /api/v1/projects/{projectId}/services */
export async function addProjectService(projectId: string, payload: CreateProjectServicePayload): Promise<ApiProjectService> {
  return apiFetch<ApiProjectService>(`/api/v1/projects/${projectId}/services`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** PUT /api/v1/projects/{projectId}/services/{serviceId} */
export async function updateProjectService(
  projectId: string,
  serviceId: string,
  payload: CreateProjectServicePayload
): Promise<ApiProjectService> {
  return apiFetch<ApiProjectService>(`/api/v1/projects/${projectId}/services/${serviceId}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

/** DELETE /api/v1/projects/{projectId}/services/{serviceId} */
export async function deleteProjectService(projectId: string, serviceId: string): Promise<boolean> {
  return apiFetch<boolean>(`/api/v1/projects/${projectId}/services/${serviceId}`, { method: "DELETE" });
}

// ── Project Tasks Methods ──

/** GET /api/v1/projects/{projectId}/tasks */
export async function fetchProjectTasks(projectId: string, period?: string, phase?: string, stage?: string): Promise<ApiProjectTask[]> {
  const query = new URLSearchParams();
  if (period) query.set("period", period);
  if (phase) query.set("phase", phase);
  if (stage) query.set("stage", stage);
  const qs = query.toString();

  return (await apiFetch<ApiProjectTask[]>(`/api/v1/projects/${projectId}/tasks${qs ? `?${qs}` : ""}`)) ?? [];
}

/** POST /api/v1/projects/{projectId}/tasks */
export async function createProjectTask(projectId: string, payload: CreateProjectTaskPayload): Promise<ApiProjectTask> {
  return apiFetch<ApiProjectTask>(`/api/v1/projects/${projectId}/tasks`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** PUT /api/v1/projects/{projectId}/tasks/{taskId} */
export async function updateProjectTask(projectId: string, taskId: string, payload: UpdateProjectTaskPayload): Promise<ApiProjectTask> {
  return apiFetch<ApiProjectTask>(`/api/v1/projects/${projectId}/tasks/${taskId}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

/** PATCH /api/v1/projects/{projectId}/tasks/{taskId}/stage */
export async function updateTaskStage(projectId: string, taskId: string, stage: string): Promise<ApiProjectTask> {
  return apiFetch<ApiProjectTask>(`/api/v1/projects/${projectId}/tasks/${taskId}/stage`, {
    method: "PATCH",
    body: JSON.stringify({ stage }),
  });
}

/** DELETE /api/v1/projects/{projectId}/tasks/{taskId} */
export async function deleteProjectTask(projectId: string, taskId: string): Promise<boolean> {
  return apiFetch<boolean>(`/api/v1/projects/${projectId}/tasks/${taskId}`, { method: "DELETE" });
}

// ── Task Assignments & Timer Methods ──

/** POST /api/v1/projects/{projectId}/tasks/{taskId}/assignments */
export async function addTaskAssignment(
  projectId: string,
  taskId: string,
  payload: CreateTaskAssignmentPayload
): Promise<ApiProjectTaskAssignment> {
  return apiFetch<ApiProjectTaskAssignment>(`/api/v1/projects/${projectId}/tasks/${taskId}/assignments`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** POST /api/v1/projects/{projectId}/tasks/{taskId}/assignments/{assignmentId}/timer/start */
export async function startTaskTimer(
  projectId: string,
  taskId: string,
  assignmentId: string
): Promise<ApiProjectTaskAssignment> {
  return apiFetch<ApiProjectTaskAssignment>(`/api/v1/projects/${projectId}/tasks/${taskId}/assignments/${assignmentId}/timer/start`, {
    method: "POST",
  });
}

/** POST /api/v1/projects/{projectId}/tasks/{taskId}/assignments/{assignmentId}/timer/stop */
export async function stopTaskTimer(
  projectId: string,
  taskId: string,
  assignmentId: string
): Promise<ApiProjectTaskAssignment> {
  return apiFetch<ApiProjectTaskAssignment>(`/api/v1/projects/${projectId}/tasks/${taskId}/assignments/${assignmentId}/timer/stop`, {
    method: "POST",
  });
}

// ── Project Invoices Methods ──

/** GET /api/v1/projects/{projectId}/invoices */
export async function fetchProjectInvoices(projectId: string): Promise<ApiProjectInvoice[]> {
  return (await apiFetch<ApiProjectInvoice[]>(`/api/v1/projects/${projectId}/invoices`)) ?? [];
}

/** POST /api/v1/projects/{projectId}/invoices */
export async function createProjectInvoice(projectId: string, payload: CreateProjectInvoicePayload): Promise<ApiProjectInvoice> {
  return apiFetch<ApiProjectInvoice>(`/api/v1/projects/${projectId}/invoices`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** PUT /api/v1/projects/{projectId}/invoices/{invoiceId} */
export async function updateProjectInvoice(
  projectId: string,
  invoiceId: string,
  payload: CreateProjectInvoicePayload
): Promise<ApiProjectInvoice> {
  return apiFetch<ApiProjectInvoice>(`/api/v1/projects/${projectId}/invoices/${invoiceId}`, {
    method: "PUT",
    body: JSON.stringify(payload),
  });
}

/** DELETE /api/v1/projects/{projectId}/invoices/{invoiceId} */
export async function deleteProjectInvoice(projectId: string, invoiceId: string): Promise<boolean> {
  return apiFetch<boolean>(`/api/v1/projects/${projectId}/invoices/${invoiceId}`, { method: "DELETE" });
}

// ── Project Documents Methods ──

/** GET /api/v1/projects/{projectId}/documents */
export async function fetchProjectDocuments(projectId: string): Promise<ApiProjectDocument[]> {
  return (await apiFetch<ApiProjectDocument[]>(`/api/v1/projects/${projectId}/documents`)) ?? [];
}

/** POST /api/v1/projects/{projectId}/documents */
export async function uploadProjectDocument(
  projectId: string,
  file: File,
  category = "PO",
  poNumber?: string,
  poDate?: string
): Promise<ApiProjectDocument> {
  const formData = new FormData();
  formData.append("file", file);
  formData.append("category", category);
  if (poNumber) formData.append("poNumber", poNumber);
  if (poDate) formData.append("poDate", poDate);

  return apiFetch<ApiProjectDocument>(`/api/v1/projects/${projectId}/documents`, {
    method: "POST",
    body: formData,
  });
}

/** Download Project Document URL */
export function getProjectDocumentDownloadUrl(projectId: string, documentId: string): string {
  return `${API_BASE}/api/v1/projects/${projectId}/documents/${documentId}/download`;
}

// ── WBS Draft & Renewal Methods ──

/** POST /api/v1/projects/{projectId}/wbs/draft */
export async function saveWbsDraft(projectId: string, payload: SaveWbsDraftPayload): Promise<ApiProject> {
  return apiFetch<ApiProject>(`/api/v1/projects/${projectId}/wbs/draft`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

/** POST /api/v1/projects/{projectId}/wbs/publish */
export async function publishWbs(projectId: string, publishComments?: string): Promise<WbsPublishResult> {
  return apiFetch<WbsPublishResult>(`/api/v1/projects/${projectId}/wbs/publish`, {
    method: "POST",
    body: JSON.stringify({ publishComments }),
  });
}

/** POST /api/v1/projects/{projectId}/renew */
export async function renewProject(
  projectId: string,
  payload: { name?: string; startDate?: string; endDate?: string; budget?: number }
): Promise<ApiProject> {
  return apiFetch<ApiProject>(`/api/v1/projects/${projectId}/renew`, {
    method: "POST",
    body: JSON.stringify(payload),
  });
}
