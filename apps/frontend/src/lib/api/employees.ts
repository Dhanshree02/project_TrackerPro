import { apiFetch } from "@/lib/api-client";
import type { Employee } from "@/lib/employee-data";

export interface ApiEmployeeListItem {
  id: string;
  employeeCode: string;
  fullName: string;
  workEmail: string;
  department?: string | null;
  designation?: string | null;
  reportingManagerName?: string | null;
  joiningDate?: string | null;
  workLocation?: string | null;
  officeBranch?: string | null;
  category?: string | null;
  projectSite?: string | null;
  kpiScore?: number | null;
  status?: string | null;
  createdAtUtc: string;
  personalEmail?: string | null;
  phone?: string | null;
  altPhone?: string | null;
  emergencyContact?: string | null;
  pan?: string | null;
  bankAccount?: string | null;
  pfUan?: string | null;
  education?: string | null;
  skills?: string[] | null;
  certifications?: string[] | null;
  languages?: string[] | null;
  role?: string | null;
  businessUnit?: string | null;
  team?: string | null;
  experience?: string | null;
  previousCompany?: string | null;
}

export interface ApiEmployeeDetail {
  id: string;
  employeeCode: string;
  firstName: string;
  lastName: string;
  workEmail: string;
  personalEmail?: string | null;
  phone?: string | null;
  altPhone?: string | null;
  gender?: string | null;
  dateOfBirth?: string | null;
  address?: string | null;
  emergencyContact?: string | null;
  maritalStatus?: string | null;
  nationality?: string | null;
  department?: string | null;
  designation?: string | null;
  role?: string | null;
  reportingManagerId?: string | null;
  reportingManagerName?: string | null;
  businessUnit?: string | null;
  workLocation?: string | null;
  officeBranch?: string | null;
  category?: string | null;
  team?: string | null;
  joiningDate?: string | null;
  status?: string | null;
  confirmationStatus?: string | null;
  probationStatus?: string | null;
  experience?: string | null;
  previousCompany?: string | null;
  employmentType?: string | null;
  contractType?: string | null;
  bondStatus?: string | null;
  noticePeriod?: string | null;
  projectSite?: string | null;
  assetId?: string | null;
  exitType?: string | null;
  exitReason?: string | null;
  education?: string | null;
  skills: string[];
  certifications: string[];
  languages: string[];
  kpiScore?: number | null;
  quarterlyKpi?: number | null;
  annualRating?: number | null;
  goalCompletion?: number | null;
  attendance?: number | null;
  reportingEfficiency?: number | null;
  promotionReadiness?: string | null;
  managerFeedback?: string | null;
  pan?: string | null;
  bankAccount?: string | null;
  salaryBand?: string | null;
  pfUan?: string | null;
  taxRegime?: string | null;
  complianceStatus?: string | null;
}

export interface ApiExitedEmployee {
  id: string;
  originalEmployeeId: string;
  employeeCode: string;
  fullName: string;
  lastWorkingDay?: string | null;
  exitType?: string | null;
  exitReason?: string | null;
  exitedAtUtc: string;
  departmentName?: string | null;
  designationName?: string | null;
  reasonForLeaving?: string | null;
}

export interface ApiMetaOption {
  id: string;
  code: string;
  name: string;
  parentId?: string | null;
}

interface PagedEnvelope<T> {
  items: T[];
  page: number;
  perPage: number;
  total: number;
  totalPages: number;
}

export async function fetchEmployees(params: {
  page?: number;
  perPage?: number;
  search?: string;
  departmentId?: string;
  designationId?: string;
  status?: string;
} = {}): Promise<PagedEnvelope<ApiEmployeeListItem>> {
  const query = new URLSearchParams();
  if (params.page) query.set("page", String(params.page));
  if (params.perPage) query.set("perPage", String(params.perPage));
  if (params.search) query.set("search", params.search);
  if (params.departmentId) query.set("departmentId", params.departmentId);
  if (params.designationId) query.set("designationId", params.designationId);
  if (params.status) query.set("status", params.status);
  return apiFetch<PagedEnvelope<ApiEmployeeListItem>>(`/api/v1/employees?${query.toString()}`);
}

export async function fetchEmployee(id: string): Promise<ApiEmployeeDetail> {
  return apiFetch<ApiEmployeeDetail>(`/api/v1/employees/${encodeURIComponent(id)}`);
}

export async function createEmployee(input: Record<string, unknown>): Promise<ApiEmployeeDetail> {
  return apiFetch<ApiEmployeeDetail>("/api/v1/employees", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateEmployee(
  id: string,
  input: Record<string, unknown>,
): Promise<ApiEmployeeDetail> {
  return apiFetch<ApiEmployeeDetail>(`/api/v1/employees/${encodeURIComponent(id)}`, {
    method: "PUT",
    body: JSON.stringify(input),
  });
}

export async function offboardEmployee(
  id: string,
  input: Record<string, unknown>,
): Promise<ApiExitedEmployee> {
  return apiFetch<ApiExitedEmployee>(`/api/v1/employees/${encodeURIComponent(id)}/offboard`, {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function fetchExitedEmployees(
  page = 1,
  perPage = 20,
  search?: string,
): Promise<PagedEnvelope<ApiExitedEmployee>> {
  const query = new URLSearchParams();
  query.set("page", String(page));
  query.set("perPage", String(perPage));
  if (search) query.set("search", search);
  return apiFetch<PagedEnvelope<ApiExitedEmployee>>(`/api/v1/employees/exited?${query.toString()}`);
}

export async function fetchDepartmentOptions(): Promise<ApiMetaOption[]> {
  return (await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/departments")) ?? [];
}

export async function fetchDesignationOptions(departmentId?: string): Promise<ApiMetaOption[]> {
  const query = departmentId ? `?departmentId=${encodeURIComponent(departmentId)}` : "";
  return (await apiFetch<ApiMetaOption[]>(`/api/v1/employees/meta/designations${query}`)) ?? [];
}

export async function fetchNationalityOptions(): Promise<ApiMetaOption[]> {
  return (await apiFetch<ApiMetaOption[]>("/api/v1/catalogs/nationalities")) ?? [];
}

export async function fetchJobRoleOptions(designationId?: string): Promise<ApiMetaOption[]> {
  const query = designationId ? `?designationId=${encodeURIComponent(designationId)}` : "";
  return (await apiFetch<ApiMetaOption[]>(`/api/v1/employees/meta/roles${query}`)) ?? [];
}

export async function fetchSalaryBandOptions(): Promise<ApiMetaOption[]> {
  return (await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/salary-bands")) ?? [];
}

export async function fetchEmailDomainOptions(): Promise<ApiMetaOption[]> {
  return (await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/email-domains")) ?? [];
}

export async function fetchReportingManagerOptions(): Promise<ApiMetaOption[]> {
  return (await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/reporting-managers")) ?? [];
}

export async function fetchBusinessUnitOptions(): Promise<ApiMetaOption[]> {
  return (await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/business-units")) ?? [];
}

export async function fetchWorkLocationOptions(): Promise<ApiMetaOption[]> {
  return (await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/work-locations")) ?? [];
}

export async function fetchOfficeOptions(workLocationId?: string): Promise<ApiMetaOption[]> {
  const query = workLocationId ? `?workLocationId=${encodeURIComponent(workLocationId)}` : "";
  return (await apiFetch<ApiMetaOption[]>(`/api/v1/employees/meta/offices${query}`)) ?? [];
}

export async function createDepartmentOption(name: string): Promise<ApiMetaOption> {
  return apiFetch<ApiMetaOption>("/api/v1/employees/meta/departments", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

export async function createDesignationOption(
  name: string,
  departmentId: string,
): Promise<ApiMetaOption> {
  return apiFetch<ApiMetaOption>("/api/v1/employees/meta/designations", {
    method: "POST",
    body: JSON.stringify({ name, parentId: departmentId }),
  });
}

export async function createJobRoleOption(
  name: string,
  designationId: string,
): Promise<ApiMetaOption> {
  return apiFetch<ApiMetaOption>("/api/v1/employees/meta/roles", {
    method: "POST",
    body: JSON.stringify({ name, parentId: designationId }),
  });
}

export async function createReportingManagerOption(name: string): Promise<ApiMetaOption> {
  return apiFetch<ApiMetaOption>("/api/v1/employees/meta/reporting-managers", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

export async function createBusinessUnitOption(name: string): Promise<ApiMetaOption> {
  return apiFetch<ApiMetaOption>("/api/v1/employees/meta/business-units", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

export async function createWorkLocationOption(name: string): Promise<ApiMetaOption> {
  return apiFetch<ApiMetaOption>("/api/v1/employees/meta/work-locations", {
    method: "POST",
    body: JSON.stringify({ name }),
  });
}

export async function createOfficeOption(
  name: string,
  workLocationId?: string,
): Promise<ApiMetaOption> {
  return apiFetch<ApiMetaOption>("/api/v1/employees/meta/offices", {
    method: "POST",
    body: JSON.stringify({ name, parentId: workLocationId }),
  });
}

export async function fetchAllExitedEmployees(): Promise<ApiExitedEmployee[]> {
  const first = await fetchExitedEmployees(1, 100);
  const all = [...(first.items ?? [])];
  for (let p = 2; p <= first.totalPages; p++) {
    const next = await fetchExitedEmployees(p, 100);
    all.push(...(next.items ?? []));
  }
  return all;
}

export async function fetchAllEmployees(): Promise<ApiEmployeeListItem[]> {
  const first = await fetchEmployees({ page: 1, perPage: 100 });
  const all = [...(first.items ?? [])];
  for (let p = 2; p <= first.totalPages; p++) {
    const next = await fetchEmployees({ page: p, perPage: 100 });
    all.push(...(next.items ?? []));
  }
  return all;
}

function toDateInputValue(value?: string | null): string {
  if (!value) return "";
  return value.slice(0, 10);
}

export function toUiEmployeeFromList(item: ApiEmployeeListItem): Employee {
  const [firstName = "", ...rest] = item.fullName.trim().split(/\s+/);
  const lastName = rest.join(" ");
  return {
    id: item.employeeCode,
    firstName,
    lastName,
    email: item.workEmail,
    personalEmail: item.personalEmail ?? "",
    phone: item.phone ?? "",
    altPhone: item.altPhone ?? "",
    gender: "",
    dob: "",
    address: "",
    emergencyContact: item.emergencyContact ?? "",
    maritalStatus: "",
    nationality: "",
    department: item.department ?? "—",
    designation: item.designation ?? "—",
    role: item.role ?? "Employee",
    reportingManager: item.reportingManagerName?.trim() || "—",
    businessUnit: item.businessUnit ?? "",
    workLocation: item.workLocation ?? "",
    officeBranch: item.officeBranch ?? "",
    category: (item.category as Employee["category"]) || "Permanent - Without Bond",
    team: item.team ?? "",
    joiningDate: toDateInputValue(item.joiningDate) || "—",
    status: (item.status as Employee["status"]) ?? "Active",
    confirmationStatus: "Active",
    probationStatus: "",
    experience: item.experience ?? "",
    previousCompany: item.previousCompany ?? "",
    employmentType: "",
    contractType: "",
    bondStatus: "",
    noticePeriod: "",
    projectSite:
      item.projectSite === "Onsite" || item.projectSite === "Offsite"
        ? item.projectSite
        : ("" as Employee["projectSite"]),
    assetId: "",
    exitType: "NA",
    exitReason: "",
    education: item.education ?? "",
    skills: item.skills ?? [],
    certifications: item.certifications ?? [],
    languages: item.languages ?? [],
    kpiScore: item.kpiScore ?? 0,
    quarterlyKpi: 0,
    annualRating: 0,
    goalCompletion: 0,
    attendance: 0,
    reportingEfficiency: 0,
    promotionReadiness: "",
    managerFeedback: "",
    pan: item.pan ?? "",
    bankAccount: item.bankAccount ?? "",
    salaryBand: "",
    pfUan: item.pfUan ?? "",
    taxRegime: "",
    complianceStatus: "Pending",
  };
}

export function toUiEmployee(detail: ApiEmployeeDetail): Employee {
  return {
    id: detail.employeeCode,
    firstName: detail.firstName,
    lastName: detail.lastName,
    email: detail.workEmail,
    personalEmail: detail.personalEmail ?? "",
    phone: detail.phone ?? "",
    altPhone: detail.altPhone ?? "",
    gender: detail.gender ?? "",
    dob: toDateInputValue(detail.dateOfBirth),
    address: detail.address ?? "",
    emergencyContact: detail.emergencyContact ?? "",
    maritalStatus: detail.maritalStatus ?? "",
    nationality: detail.nationality ?? "",
    department: detail.department ?? "",
    designation: detail.designation ?? "",
    role: detail.role ?? "Employee",
    reportingManager: detail.reportingManagerName?.trim() || "—",
    businessUnit: detail.businessUnit ?? "",
    workLocation: detail.workLocation ?? "",
    officeBranch: detail.officeBranch ?? "",
    category: (detail.category as Employee["category"]) || "Permanent - Without Bond",
    team: detail.team ?? "",
    joiningDate: toDateInputValue(detail.joiningDate),
    status: (detail.status as Employee["status"]) ?? "Active",
    confirmationStatus: (detail.confirmationStatus as Employee["confirmationStatus"]) || "Active",
    probationStatus: detail.probationStatus ?? "",
    experience: detail.experience ?? "",
    previousCompany: detail.previousCompany ?? "",
    employmentType: detail.employmentType ?? "",
    contractType: detail.contractType ?? "",
    bondStatus: detail.bondStatus ?? "",
    noticePeriod: detail.noticePeriod ?? "",
    projectSite: detail.projectSite ?? "Offsite",
    assetId: detail.assetId ?? "",
    exitType: (detail.exitType as Employee["exitType"]) || "NA",
    exitReason: detail.exitReason?.trim() ? detail.exitReason : "NA",
    education: detail.education ?? "",
    skills: detail.skills ?? [],
    certifications: detail.certifications ?? [],
    languages: detail.languages ?? [],
    kpiScore: detail.kpiScore ?? 0,
    quarterlyKpi: detail.quarterlyKpi ?? 0,
    annualRating: detail.annualRating ?? 0,
    goalCompletion: detail.goalCompletion ?? 0,
    attendance: detail.attendance ?? 0,
    reportingEfficiency: detail.reportingEfficiency ?? 0,
    promotionReadiness: detail.promotionReadiness ?? "",
    managerFeedback: detail.managerFeedback ?? "",
    pan: detail.pan ?? "",
    bankAccount: detail.bankAccount ?? "",
    salaryBand: detail.salaryBand ?? "",
    pfUan: detail.pfUan ?? "",
    taxRegime: detail.taxRegime ?? "",
    complianceStatus: (detail.complianceStatus as Employee["complianceStatus"]) || "Pending",
  };
}
