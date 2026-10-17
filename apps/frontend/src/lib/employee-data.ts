// Employee Directory types
// ---------------------------------------------------

export type EmployeeStatus =
  | "Active"
  | "Probation"
  | "Resignation Under Review"
  | "Notice Period"
  | "Inactive"
  | "On Leave";
export type ConfirmationStatus =
  | "Active - Probation"
  | "Active"
  | "Resignation - Under Review"
  | "Resignation - Accepted"
  | "Inactive - After Onboarding";
export type ComplianceStatus = "Compliant" | "Pending" | "Non-Compliant";

export interface Employee {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
  personalEmail: string;
  phone: string;
  altPhone: string;
  gender: string;
  dob: string;
  address: string;
  emergencyContact: string;
  emergencyContactName?: string;
  emergencyContactRelation?: string;
  maritalStatus: string;
  nationality: string;
  // org
  department: string;
  departmentId?: string;
  designation: string;
  designationId?: string;
  role: string;
  jobRoleId?: string;
  reportingManager: string;
  reportingManagerId?: string;
  businessUnit: string;
  workLocation: string;
  officeBranch: string;
  category:
    | "Permanent - Bond"
    | "Permanent - Without Bond"
    | "Contract-based"
    | "Intern - Paid"
    | "Intern - Unpaid";
  workerType?: string;
  team: string;
  // employment
  joiningDate: string;
  status: EmployeeStatus;
  employeeStatusId?: string;
  confirmationStatus: ConfirmationStatus;
  probationStatus: string;
  gradDegree: string;
  gradYear: string;
  postGradDegree: string;
  postGradYear: string;
  expType: "Fresher" | "Experienced";
  priorTotalExp: string;
  priorRelevantExp: string;
  experience: string;
  previousCompany: string;
  employmentType: string;
  contractType: string;
  bondDelivered?: string;
  bondDurationMonths?: number | string;
  bondExpiryDate?: string;
  bondStatus: string;
  noticePeriod: string;
  // site details & assets
  projectSite: string;
  assetId: string;
  exitType: "NA" | "Resign" | "Absconded" | "Terminated" | "Suspension";
  exitReason: string;
  // PMO details
  pmoDepartment?: string;
  subDepartment?: string;
  billableStatus?: string;
  clientLocation?: string;
  projectType?: string;
  projectAllocated?: string;
  clientEngManagerMapping?: string;
  todayAttendance?: string;
  allocationStatus?: "Occupied" | "Free" | "On Leave";
  allocationType?: "Shared" | "Dedicated" | "";
  allocationStartDate?: string;
  allocationEndDate?: string;
  allocatedProjectName?: string;
  // skills
  education: string;
  skills: string[];
  certifications: string[];
  languages: string[];
  // kpi
  kpiScore: number;
  quarterlyKpi: number;
  annualRating: number;
  goalCompletion: number;
  attendance: number;
  reportingEfficiency: number;
  promotionReadiness: string;
  managerFeedback: string;
  // finance
  pan: string;
  aadhaar: string;
  bankAccount: string;
  salaryBand: string;
  pfUan: string;
  taxRegime: string;
  complianceStatus: ComplianceStatus;
  calendarOverrides?: Record<
    string,
    {
      type: "Working" | "W-OFF" | "Leave" | "Holiday";
      shift?: string;
      leaveType?: string;
      reason?: string;
    }
  >;
}
