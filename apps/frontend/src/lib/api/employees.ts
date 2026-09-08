import { apiFetch, apiDownload } from "@/lib/api-client";
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
  emergencyContactName?: string | null;
  emergencyContactRelation?: string | null;
  pan?: string | null;
  bankAccount?: string | null;
  pfUan?: string | null;
  aadhaar?: string | null;
  education?: string | null;
  skills?: string[] | null;
  certifications?: string[] | null;
  languages?: string[] | null;
  role?: string | null;
  businessUnit?: string | null;
  team?: string | null;
  experience?: string | null;
  previousCompany?: string | null;
  pmoDepartment?: string | null;
  subDepartment?: string | null;
  billableStatus?: string | null;
  clientLocation?: string | null;
  projectType?: string | null;
  projectAllocated?: string | null;
  clientEngManagerMapping?: string | null;
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
  emergencyContactName?: string | null;
  emergencyContactRelation?: string | null;
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
  aadhaar?: string | null;
  bankAccount?: string | null;
  salaryBand?: string | null;
  pfUan?: string | null;
  taxRegime?: string | null;
  complianceStatus?: string | null;
  pmoDepartment?: string | null;
  subDepartment?: string | null;
  billableStatus?: string | null;
  clientLocation?: string | null;
  projectType?: string | null;
  projectAllocated?: string | null;
  clientEngManagerMapping?: string | null;
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

export interface EmployeeBulkRowError {
  row: number;
  employeeCode?: string | null;
  message: string;
}

export interface EmployeeBulkUploadResult {
  created: number;
  failed: number;
  errors: EmployeeBulkRowError[];
}

export async function downloadEmployeeBulkSample(): Promise<void> {
  await apiDownload("/api/v1/employees/bulk/sample", "employee-bulk-upload-sample.xlsx");
}

export async function uploadEmployeeBulk(file: File): Promise<EmployeeBulkUploadResult> {
  const ext = file.name.split(".").pop()?.toLowerCase();
  if (ext !== "xlsx") {
    throw new Error("Only Excel (.xlsx) files are allowed");
  }
  const formData = new FormData();
  formData.append("file", file);
  return apiFetch<EmployeeBulkUploadResult>("/api/v1/employees/bulk", {
    method: "POST",
    body: formData,
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

export async function fetchEmployeeStatusOptions(onboardingOnly = false): Promise<ApiMetaOption[]> {
  const query = onboardingOnly ? "?onboardingOnly=true" : "";
  return (await apiFetch<ApiMetaOption[]>(`/api/v1/employees/meta/employee-statuses${query}`)) ?? [];
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
    emergencyContactName: item.emergencyContactName ?? "",
    emergencyContactRelation: item.emergencyContactRelation ?? "",
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
    aadhaar: "",
    bankAccount: item.bankAccount ?? "",
    salaryBand: "",
    pfUan: item.pfUan ?? "",
    taxRegime: "",
    pmoDepartment: item.pmoDepartment ?? "",
    subDepartment: item.subDepartment ?? "",
    billableStatus: item.billableStatus ?? "",
    clientLocation: item.clientLocation ?? "",
    projectType: item.projectType ?? "",
    projectAllocated: item.projectAllocated ?? "",
    clientEngManagerMapping: item.clientEngManagerMapping ?? "",
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
    emergencyContactName: detail.emergencyContactName ?? "",
    emergencyContactRelation: detail.emergencyContactRelation ?? "",
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
    aadhaar: detail.aadhaar ?? "",
    bankAccount: detail.bankAccount ?? "",
    salaryBand: detail.salaryBand ?? "",
    pfUan: detail.pfUan ?? "",
    taxRegime: detail.taxRegime ?? "",
    pmoDepartment: detail.pmoDepartment ?? "",
    subDepartment: detail.subDepartment ?? "",
    billableStatus: detail.billableStatus ?? "",
    clientLocation: detail.clientLocation ?? "",
    projectType: detail.projectType ?? "",
    projectAllocated: detail.projectAllocated ?? "",
    clientEngManagerMapping: detail.clientEngManagerMapping ?? "",
    complianceStatus: (detail.complianceStatus as Employee["complianceStatus"]) || "Pending",
  };
}

export async function uploadEmployeeDocuments(
  employeeCode: string,
  category: string,
  files: File[],
): Promise<void> {
  if (!files || files.length === 0) return;
  const formData = new FormData();
  formData.append("category", category);
  for (const file of files) {
    formData.append("files", file);
  }
  await apiFetch(`/api/v1/storage/employees/${encodeURIComponent(employeeCode)}/documents`, {
    method: "POST",
    body: formData,
  });
}


export const DEFAULT_CERTIFICATIONS: ApiMetaOption[] = [
  { id: "cert-1", code: "ceh", name: "Certified Ethical Hacker (CEH)" },
  { id: "cert-2", code: "comptia_sec", name: "CompTIA Security+" },
  { id: "cert-3", code: "ecppt", name: "eCPPT" },
  { id: "cert-4", code: "cpts", name: "cPTS" },
  { id: "cert-5", code: "crtp", name: "CRTP" },
  { id: "cert-6", code: "lpt", name: "Licensed Penetration Tester (LPT)" },
  { id: "cert-7", code: "pnpt", name: "PNPT" },
  { id: "cert-8", code: "crte", name: "CRTE" },
  { id: "cert-9", code: "crt", name: "CRT" },
  { id: "cert-10", code: "oscp", name: "Offensive Security Certified Professional (OSCP)" },
  { id: "cert-11", code: "oswp", name: "Offensive Security Wireless Professional (OSWP)" },
  { id: "cert-12", code: "oswe", name: "Offensive Security Web Expert (OSWE)" },
  { id: "cert-13", code: "osep", name: "Offensive Security Experienced Penetration Tester (OSEP)" },
  { id: "cert-14", code: "osce3", name: "Offensive Security Certified Expert 3 (OSCE3)" },
  { id: "cert-15", code: "iso27001", name: "ISO 27001" },
  { id: "cert-16", code: "iso22301", name: "ISO 22301" },
  { id: "cert-17", code: "iso42001", name: "ISO/IEC 42001" },
  { id: "cert-18", code: "ccsp", name: "Certified Cloud Security Professional (CCSP)" },
  { id: "cert-19", code: "cisa", name: "Certified Information Systems Auditor (CISA)" },
  { id: "cert-20", code: "cism", name: "Certified Information Security Manager (CISM)" },
  { id: "cert-21", code: "cissp", name: "Certified Information Systems Security Professional (CISSP)" },
  { id: "cert-22", code: "crisc", name: "Certified in Risk and Information Systems Control (CRISC)" },
  { id: "cert-23", code: "ecih", name: "EC-Council Certified Incident Handler (ECIH)" },
  { id: "cert-24", code: "ctia", name: "Certified Threat Intelligence Analyst (CTIA)" },
  { id: "cert-25", code: "btl1_2", name: "Blue Team Level 1 and 2" },
  { id: "cert-26", code: "ecthp", name: "eLearnSecurity Certified Threat Hunting Professional (eCTHP)" },
  { id: "cert-27", code: "ecir", name: "eLearnSecurity Certified Incident Responder (eCIR)" },
  { id: "cert-28", code: "ecdfp", name: "eLearnSecurity Certified Digital Forensics Professional (eCDFP)" },
  { id: "cert-29", code: "osda", name: "OffSec Foundational Security Operations and Defensive Analysis (OSDA)" },
];

export const DEFAULT_GRADUATION_DEGREES: ApiMetaOption[] = [
  { id: "grad-1", code: "be", name: "BE" },
  { id: "grad-2", code: "btech", name: "B.Tech" },
  { id: "grad-3", code: "bsc", name: "B.Sc" },
  { id: "grad-4", code: "bcom", name: "B.Com" },
  { id: "grad-5", code: "bca", name: "BCA" },
  { id: "grad-6", code: "ba", name: "B.A." },
  { id: "grad-7", code: "bpharm", name: "B.Pharm" },
  { id: "grad-8", code: "bba", name: "BBA" },
  { id: "grad-9", code: "bs", name: "BS" },
];

export const DEFAULT_POST_GRADUATION_DEGREES: ApiMetaOption[] = [
  { id: "pgrad-1", code: "na", name: "NA" },
  { id: "pgrad-2", code: "mca", name: "MCA" },
  { id: "pgrad-3", code: "mba", name: "MBA" },
  { id: "pgrad-4", code: "mtech", name: "M.Tech" },
  { id: "pgrad-5", code: "me", name: "ME" },
  { id: "pgrad-6", code: "msc", name: "M.Sc" },
  { id: "pgrad-7", code: "ms", name: "MS" },
  { id: "pgrad-8", code: "mcom", name: "M.Com" },
  { id: "pgrad-9", code: "ma", name: "M.A." },
];

export async function fetchCertificationOptions(): Promise<ApiMetaOption[]> {
  try {
    const list = await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/certifications");
    return list && list.length > 0 ? list : DEFAULT_CERTIFICATIONS;
  } catch {
    return DEFAULT_CERTIFICATIONS;
  }
}

export async function createCertificationOption(name: string): Promise<ApiMetaOption> {
  try {
    return await apiFetch<ApiMetaOption>("/api/v1/employees/meta/certifications", {
      method: "POST",
      body: JSON.stringify({ name }),
    });
  } catch {
    const code = name.toLowerCase().replace(/[^a-z0-9]/g, "_");
    return { id: `__new__${name}`, code, name };
  }
}

export async function fetchGraduationDegreeOptions(): Promise<ApiMetaOption[]> {
  try {
    const list = await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/graduation-degrees");
    return list && list.length > 0 ? list : DEFAULT_GRADUATION_DEGREES;
  } catch {
    return DEFAULT_GRADUATION_DEGREES;
  }
}

export async function createGraduationDegreeOption(name: string): Promise<ApiMetaOption> {
  try {
    return await apiFetch<ApiMetaOption>("/api/v1/employees/meta/graduation-degrees", {
      method: "POST",
      body: JSON.stringify({ name }),
    });
  } catch {
    const code = name.toLowerCase().replace(/[^a-z0-9]/g, "_");
    return { id: `__new__${name}`, code, name };
  }
}

export async function fetchPostGraduationDegreeOptions(): Promise<ApiMetaOption[]> {
  try {
    const list = await apiFetch<ApiMetaOption[]>("/api/v1/employees/meta/post-graduation-degrees");
    return list && list.length > 0 ? list : DEFAULT_POST_GRADUATION_DEGREES;
  } catch {
    return DEFAULT_POST_GRADUATION_DEGREES;
  }
}

export async function createPostGraduationDegreeOption(name: string): Promise<ApiMetaOption> {
  try {
    return await apiFetch<ApiMetaOption>("/api/v1/employees/meta/post-graduation-degrees", {
      method: "POST",
      body: JSON.stringify({ name }),
    });
  } catch {
    const code = name.toLowerCase().replace(/[^a-z0-9]/g, "_");
    return { id: `__new__${name}`, code, name };
  }
}
