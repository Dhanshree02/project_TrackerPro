import {
  FIELD_MAX,
  emailError,
  isAllowedWorkEmailDomain,
  isoDateToday,
  isoDateYearsAgo,
  isLettersName,
  isValidEmailLocalPart,
  isValidTkId,
  phoneError,
} from "@/lib/form-validation";
import type { Employee } from "@/lib/employee-data";

export const ONBOARD_DOC_SLOTS = [
  "Resume",
  "PAN Card",
  "Aadhaar Card",
  "Offer Letter",
  "Education Certs",
  "Experience Letters",
] as const;

export type OnboardDocSlot = (typeof ONBOARD_DOC_SLOTS)[number];

export const MANDATORY_DOC_SLOTS: OnboardDocSlot[] = [];

export const BILLABLE_STATUS_OPTIONS = ["Billable", "Non-Billable"] as const;
export type BillableStatusOption = (typeof BILLABLE_STATUS_OPTIONS)[number];

export const PROJECT_TYPE_OPTIONS = ["Long Term", "Short Term"] as const;
export type ProjectTypeOption = (typeof PROJECT_TYPE_OPTIONS)[number];

export const PMO_DEPARTMENT_SUB_DEPARTMENTS: Record<string, string[]> = {
  "Core": [
    "Leading Sales & A/C Dept.",
    "Leading Delivery Dept.",
    "Leading Compliance & HR Dept.",
  ],
  "Functional - IT Administration": ["-"],
  "Functional - Accounts": ["-"],
  "Functional - HR": ["-"],
  "Functional - Sales": ["-"],
  "Functional - Project Management": [
    "PMO (Project Management Office)",
    "EM (Engagement Manager)",
  ],
  "R&D (Research & Development)": ["-"],
  "Services - Operations": ["-"],
  "Services - Consulting": ["-"],
  "Services - Testing": [
    "Service - Testing - AppSec",
    "Service - Testing - Mobile",
    "Service - Testing - Infra",
    "Services - Testing - DevSecOps",
    "Services - Testing - Red Team",
    "Services - Testing - Cloud & AI",
  ],
  "Internship Program": [
    "Across all Sub Departments",
  ],
};

export const PMO_DEPARTMENT_OPTIONS = Object.keys(PMO_DEPARTMENT_SUB_DEPARTMENTS);

export const DOC_EXT = [".pdf", ".jpg", ".jpeg", ".png"];
export const MAX_DOC_BYTES = 5 * 1024 * 1024; // 5 MB

export const EMERGENCY_RELATION_OPTIONS = [
  "Father",
  "Mother",
  "Spouse",
  "Brother",
  "Sister",
  "Son",
  "Daughter",
  "Guardian",
  "Friend",
  "Other",
] as const;

export type EmergencyRelationOption = (typeof EMERGENCY_RELATION_OPTIONS)[number];

export type OnboardField =
  | "firstName"
  | "lastName"
  | "workEmail"
  | "personalEmail"
  | "employeeCode"
  | "phone"
  | "altPhone"
  | "emergencyContact"
  | "emergencyContactName"
  | "emergencyContactRelation"
  | "gender"
  | "dateOfBirth"
  | "maritalStatus"
  | "nationalityId"
  | "address"
  | "departmentId"
  | "designationId"
  | "jobRoleId"
  | "businessUnit"
  | "team"
  | "projectSite"
  | "workLocation"
  | "officeBranch"
  | "assetId"
  | "exitType"
  | "exitReason"
  | "employeeStatusId"
  | "workerType"
  | "bondDelivered"
  | "bondDurationMonths"
  | "gradDegree"
  | "gradYear"
  | "postGradDegree"
  | "postGradYear"
  | "expType"
  | "priorTotalExp"
  | "priorTotalExpYears"
  | "priorTotalExpMonths"
  | "priorRelevantExp"
  | "priorRelevantExpYears"
  | "priorRelevantExpMonths"
  | "education"
  | "certifications"
  | "technicalSkills"
  | "functionalSkills"
  | "experience"
  | "previousCompany"
  | "languages"
  | "pan"
  | "aadhaar"
  | "pfUan"
  | "bankAccount"
  | "ifsc"
  | "joiningDate"
  | "reportingManagerId"
  | "pmoDepartment"
  | "subDepartment"
  | "billableStatus"
  | "clientLocation"
  | "projectType"
  | "projectAllocated"
  | "clientEngManagerMapping"
  | "probationStatus";

export type OnboardErrors = Partial<Record<OnboardField, string>>;
export type OnboardValues = Record<OnboardField, string>;

export type OnboardDocs = {
  Resume: File | null;
  "PAN Card": File | null;
  "Aadhaar Card": File | null;
  "Offer Letter": File | null;
  "Education Certs": File[];
  "Experience Letters": File[];
};

export type OnboardDocErrors = Partial<Record<OnboardDocSlot, string>>;

export const EMPTY_ONBOARD: OnboardValues = {
  firstName: "",
  lastName: "",
  workEmail: "",
  personalEmail: "",
  employeeCode: "",
  phone: "",
  altPhone: "",
  gender: "",
  dateOfBirth: "",
  maritalStatus: "",
  nationalityId: "",
  address: "",
  emergencyContact: "",
  emergencyContactName: "",
  emergencyContactRelation: "",
  departmentId: "",
  designationId: "",
  jobRoleId: "",
  businessUnit: "Talakunchi Networks Private Limited",
  team: "",
  projectSite: "",
  workLocation: "",
  officeBranch: "",
  assetId: "",
  employeeStatusId: "",
  workerType: "Permanent",
  bondDelivered: "No",
  bondDurationMonths: "0",
  exitType: "NA",
  exitReason: "",
  gradDegree: "",
  gradYear: "",
  postGradDegree: "NA",
  postGradYear: "NA",
  expType: "Fresher",
  priorTotalExp: "0",
  priorTotalExpYears: "0",
  priorTotalExpMonths: "0",
  priorRelevantExp: "0",
  priorRelevantExpYears: "0",
  priorRelevantExpMonths: "0",
  education: "",
  certifications: "",
  technicalSkills: "",
  functionalSkills: "",
  experience: "",
  previousCompany: "",
  languages: "",
  pan: "",
  aadhaar: "",
  pfUan: "",
  bankAccount: "",
  ifsc: "",
  joiningDate: "",
  reportingManagerId: "",
  pmoDepartment: "",
  subDepartment: "",
  billableStatus: "Billable",
  clientLocation: "",
  projectType: "Long Term",
  projectAllocated: "",
  clientEngManagerMapping: "",
  probationStatus: "Ongoing",
};

export const EMPTY_DOCS: OnboardDocs = {
  Resume: null,
  "PAN Card": null,
  "Aadhaar Card": null,
  "Offer Letter": null,
  "Education Certs": [],
  "Experience Letters": [],
};

export const ONBOARD_FIELDS: OnboardField[] = [
  "firstName",
  "lastName",
  "workEmail",
  "employeeCode",
  "phone",
  "altPhone",
  "emergencyContact",
  "emergencyContactName",
  "emergencyContactRelation",
  "address",
  "departmentId",
  "designationId",
  "jobRoleId",
  "reportingManagerId",
  "workLocation",
  "joiningDate",
  "employeeStatusId",
  "workerType",
  "bondDelivered",
  "bondDurationMonths",
  "gradDegree",
  "gradYear",
  "postGradDegree",
  "postGradYear",
  "priorTotalExpMonths",
  "priorRelevantExpMonths",
  "priorRelevantExpYears",
  "pmoDepartment",
  "subDepartment",
  "billableStatus",
  "clientLocation",
  "projectType",
  "projectAllocated",
  "clientEngManagerMapping",
];

export function formatExpDisplay(years: string | number, months: string | number): string {
  const y = parseInt(String(years || "0"), 10) || 0;
  const m = parseInt(String(months || "0"), 10) || 0;
  if (y === 0 && m === 0) return "0";
  const parts: string[] = [];
  if (y > 0) parts.push(`${y} ${y === 1 ? "Year" : "Years"}`);
  if (m > 0) parts.push(`${m} ${m === 1 ? "Month" : "Months"}`);
  return parts.join(" ");
}

export function computeTotalMonths(years: string | number, months: string | number): number {
  const y = parseInt(String(years || "0"), 10) || 0;
  const m = parseInt(String(months || "0"), 10) || 0;
  return y * 12 + m;
}

export function parseExpToYearsMonths(val?: string | null): { years: string; months: string } {
  if (!val || val === "0" || val === "Fresher") return { years: "0", months: "0" };
  const ymMatch = val.match(/(\d+)\s*(?:years?|yrs?)(?:\s*(\d+)\s*(?:months?|mos?))?/i);
  if (ymMatch) {
    return {
      years: ymMatch[1] || "0",
      months: ymMatch[2] || "0",
    };
  }
  const mMatch = val.match(/^(\d+)\s*(?:months?|mos?)$/i);
  if (mMatch) {
    return { years: "0", months: mMatch[1] || "0" };
  }
  const num = parseFloat(val);
  if (!isNaN(num) && num >= 0) {
    const y = Math.floor(num);
    const m = Math.round((num - y) * 12);
    return { years: String(y), months: String(m) };
  }
  return { years: "0", months: "0" };
}

export const MAX_ADULT_DOB = isoDateYearsAgo(18);
export const MIN_DOB = isoDateYearsAgo(100);

export function digitsOnly(value: string): string {
  return (value || "").replace(/\D/g, "");
}

/** Verhoeff checksum used by Aadhaar. */
export function isValidAadhaar(value: string): boolean {
  const digits = digitsOnly(value);
  if (digits.length !== 12 || /^0+$/.test(digits)) return false;
  const d = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
    [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
    [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
    [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
    [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
    [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
    [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
    [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
    [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
  ];
  const p = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
    [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
    [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
    [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
    [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
    [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
    [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
  ];
  let c = 0;
  const reversed = digits.split("").reverse().map(Number);
  for (let i = 0; i < reversed.length; i++) c = d[c][p[i % 8][reversed[i]]];
  return c === 0;
}

export function isValidPan(value: string): boolean {
  return /^[A-Z]{5}[0-9]{4}[A-Z]$/.test((value || "").trim().toUpperCase());
}

export function isValidIfsc(value: string): boolean {
  return /^[A-Z]{4}0[A-Z0-9]{6}$/.test((value || "").trim().toUpperCase());
}

export function formatBytes(n: number): string {
  if (n < 1024) return `${n} B`;
  if (n < 1024 * 1024) return `${(n / 1024).toFixed(1)} KB`;
  return `${(n / (1024 * 1024)).toFixed(1)} MB`;
}

export type ValidationOptions = {
  isEdit?: boolean;
};

export function validateOnboardField(
  field: OnboardField,
  values: OnboardValues,
  existingCodes: string[] = [],
  options?: ValidationOptions,
): string | undefined {
  switch (field) {
    case "firstName": {
      const v = (values.firstName || "").trim();
      if (!v) return "First name is required";
      if (v.length > 120) return "First name must be 120 characters or less";
      if (!isLettersName(v)) return "Only letters, spaces, hyphens, and apostrophes are allowed";
      return undefined;
    }
    case "lastName": {
      const v = (values.lastName || "").trim();
      if (!v) return "Last name is required";
      if (v.length > 120) return "Last name must be 120 characters or less";
      if (!isLettersName(v)) return "Only letters, spaces, hyphens, and apostrophes are allowed";
      return undefined;
    }
    case "emergencyContactName": {
      const v = (values.emergencyContactName || "").trim();
      if (!v) return "Emergency contact name is required";
      if (v.length < 2) return "Emergency contact name must be at least 2 characters";
      if (v.length > 100) return "Emergency contact name must be 100 characters or less";
      if (!isLettersName(v)) return "Only letters, spaces, hyphens, and apostrophes are allowed";
      return undefined;
    }
    case "emergencyContactRelation": {
      const v = (values.emergencyContactRelation || "").trim();
      if (!v) return "Relation with emergency contact is required";
      return undefined;
    }
    case "gender": {
      return undefined;
    }
    case "dateOfBirth": {
      const v = (values.dateOfBirth || "").trim();
      if (!v) return undefined;
      if (v > MAX_ADULT_DOB) return "Employee must be at least 18 years old";
      if (v < MIN_DOB) return "Enter a valid date of birth";
      return undefined;
    }
    case "maritalStatus": {
      return undefined;
    }
    case "nationalityId": {
      return undefined;
    }
    case "address": {
      const v = (values.address || "").trim();
      if (!v) return "Current Address - City is required";
      return undefined;
    }
    case "departmentId": {
      const v = (values.departmentId || "").trim();
      if (!v) return "Department is required";
      return undefined;
    }
    case "designationId": {
      const v = (values.designationId || "").trim();
      if (!v) return "Designation is required";
      return undefined;
    }
    case "reportingManagerId": {
      const v = (values.reportingManagerId || "").trim();
      if (!v) return "Reporting manager is required";
      return undefined;
    }
    case "workLocation": {
      const v = (values.workLocation || "").trim();
      if (!v) return "Work location is required";
      return undefined;
    }
    case "officeBranch": {
      return undefined;
    }
    case "employeeStatusId": {
      const v = (values.employeeStatusId || "").trim();
      if (!v) return "Employee status is required";
      return undefined;
    }
    case "workerType": {
      const v = (values.workerType || "").trim();
      if (!v) return "Worker type is required";
      return undefined;
    }
    case "bondDelivered": {
      const v = (values.bondDelivered || "").trim();
      if (!v) return "Bond delivered is required";
      return undefined;
    }
    case "bondDurationMonths": {
      const v = (values.bondDurationMonths || "").trim();
      if (values.bondDelivered !== "Yes") return undefined;
      if (!v) return "Bond duration is required when bond is delivered";
      const n = Number(v);
      if (!Number.isInteger(n) || n <= 0 || n > 120) return "Enter bond duration in months (1–120)";
      return undefined;
    }
    case "joiningDate": {
      if (options?.isEdit) return undefined;
      const v = (values.joiningDate || "").trim();
      if (!v) return "Joining date is required";
      if (v < isoDateToday()) return "Date of joining must be today or a future date";
      return undefined;
    }
    case "jobRoleId":
      return undefined;
    case "workEmail": {
      const v = (values.workEmail || "").trim();
      if (!v) return "Work email is required";
      const atIdx = v.indexOf("@");
      if (atIdx <= 0) return "Enter a valid username (e.g. john.doe)";
      const local = v.slice(0, atIdx);
      if (!isValidEmailLocalPart(local)) return "Username can only contain letters, numbers, and '.'";
      const domain = v.slice(atIdx + 1);
      if (!isAllowedWorkEmailDomain(domain)) {
        return "Only @talakunchi.com, @talakunchi.in, and @squad1.io domains are allowed";
      }
      return emailError(v, true);
    }
    case "personalEmail": {
      const v = (values.personalEmail || "").trim();
      if (!v) return undefined;
      const mailErr = emailError(v);
      if (mailErr) return mailErr;
      if (v.toLowerCase() === (values.workEmail || "").trim().toLowerCase()) {
        return "Personal email should be different from work email";
      }
      return undefined;
    }
    case "employeeCode": {
      const v = (values.employeeCode || "").trim();
      if (!v) return "TK ID is required";
      if (!isValidTkId(v)) return "Enter a 4-digit number (e.g. TK-0001)";
      if (existingCodes.some((c) => c.toLowerCase() === v.toLowerCase())) {
        return "This TK ID already exists";
      }
      return undefined;
    }
    case "phone": {
      return phoneError(values.phone, true);
    }
    case "altPhone": {
      return phoneError(values.altPhone, false);
    }
    case "emergencyContact": {
      return phoneError(values.emergencyContact, true);
    }
    case "pan": {
      const v = (values.pan || "").trim();
      if (!v) return undefined;
      if (!isValidPan(v)) return "Enter a valid PAN (e.g. ABCDE1234F)";
      return undefined;
    }
    case "aadhaar": {
      const v = (values.aadhaar || "").trim();
      if (!v) return undefined;
      if (/\D/.test(v.replace(/\s/g, ""))) return "Only numbers are allowed";
      if (!isValidAadhaar(v)) return "Enter a valid 12-digit Aadhaar number";
      return undefined;
    }
    case "pfUan": {
      const v = (values.pfUan || "").trim();
      if (!v) return undefined;
      if (/\D/.test(v)) return "Only numbers are allowed";
      if (digitsOnly(v).length !== 12) return "UAN must be a valid 12-digit number";
      return undefined;
    }
    case "bankAccount": {
      const v = (values.bankAccount || "").trim();
      if (!v) return undefined;
      if (/\D/.test(v)) return "Only numbers are allowed";
      const n = digitsOnly(v);
      if (n.length < 9 || n.length > 18) return "Enter a valid bank account number (9–18 digits)";
      return undefined;
    }
    case "ifsc": {
      const v = (values.ifsc || "").trim();
      if (!v) return undefined;
      if (!isValidIfsc(v)) return "Enter a valid IFSC (e.g. SBIN0001234)";
      return undefined;
    }
    case "pmoDepartment":
    case "subDepartment":
    case "billableStatus":
    case "clientLocation":
    case "projectType":
    case "projectAllocated":
    case "clientEngManagerMapping":
      return undefined;
    case "businessUnit":
    case "team":
    case "projectSite":
    case "assetId":
    case "exitType":
    case "exitReason":
    case "expType":
      return undefined;
    case "gradDegree": {
      const hasGradYear = !!(values.gradYear || "").trim() && values.gradYear !== "NA";
      const v = (values.gradDegree || "").trim();
      if (hasGradYear && (!v || v === "NA")) {
        return "Graduation degree name is required when graduation passing year is selected";
      }
      return undefined;
    }
    case "gradYear": {
      const hasGradDegree = !!(values.gradDegree || "").trim() && values.gradDegree !== "NA";
      const v = (values.gradYear || "").trim();
      if (hasGradDegree && (!v || v === "NA")) {
        return "Graduation passing year is required when graduation degree is selected";
      }
      if (!v || v === "NA") return undefined;
      const currentYear = new Date().getFullYear();
      const yr = parseInt(v, 10);
      if (isNaN(yr) || yr < 1950 || yr > currentYear) {
        return `Graduation year must be between 1950 and ${currentYear}`;
      }
      return undefined;
    }
    case "postGradDegree": {
      const hasPostGradYear = !!(values.postGradYear || "").trim() && values.postGradYear !== "NA";
      const v = (values.postGradDegree || "").trim();
      if (hasPostGradYear && (!v || v === "NA")) {
        return "Post graduation degree name is required when post graduation passing year is selected";
      }
      return undefined;
    }
    case "postGradYear": {
      const hasPostGradDegree = !!(values.postGradDegree || "").trim() && values.postGradDegree !== "NA";
      const v = (values.postGradYear || "").trim();
      if (hasPostGradDegree && (!v || v === "NA")) {
        return "Post graduation passing year is required when post graduation degree is selected";
      }
      if (!v || v === "NA") return undefined;
      const currentYear = new Date().getFullYear();
      const yr = parseInt(v, 10);
      if (isNaN(yr) || yr < 1950 || yr > currentYear) {
        return `Post graduation year must be between 1950 and ${currentYear}`;
      }
      if (values.gradYear && values.gradYear !== "NA") {
        const gradYr = parseInt(values.gradYear, 10);
        if (!isNaN(gradYr) && yr < gradYr) {
          return "Post graduation passing year cannot be lower than graduation passing year";
        }
      }
      return undefined;
    }
    case "priorTotalExpMonths": {
      if (values.expType === "Fresher") return undefined;
      const mStr = (values.priorTotalExpMonths || "").trim();
      if (!mStr) return undefined;
      const m = parseInt(mStr, 10);
      if (isNaN(m) || m < 0 || m > 11) {
        return "Months must be between 0 and 11";
      }
      return undefined;
    }
    case "priorRelevantExpMonths": {
      if (values.expType === "Fresher") return undefined;
      const mStr = (values.priorRelevantExpMonths || "").trim();
      if (!mStr) return undefined;
      const m = parseInt(mStr, 10);
      if (isNaN(m) || m < 0 || m > 11) {
        return "Months must be between 0 and 11";
      }
      return undefined;
    }
    case "priorTotalExp":
    case "priorTotalExpYears": {
      if (values.expType === "Fresher") return undefined;
      const yStr = (values.priorTotalExpYears || "").trim();
      if (yStr) {
        const y = parseInt(yStr, 10);
        if (isNaN(y) || y < 0) {
          return "Years must be a non-negative number";
        }
      }
      return undefined;
    }
    case "priorRelevantExp":
    case "priorRelevantExpYears": {
      if (values.expType === "Fresher") return undefined;
      const totY = parseInt(values.priorTotalExpYears || "0", 10) || 0;
      const totM = parseInt(values.priorTotalExpMonths || "0", 10) || 0;
      const relY = parseInt(values.priorRelevantExpYears || "0", 10) || 0;
      const relM = parseInt(values.priorRelevantExpMonths || "0", 10) || 0;
      const totalMonths = totY * 12 + totM;
      const relMonths = relY * 12 + relM;
      if (relMonths > totalMonths) {
        return "Relevant experience cannot be greater than total experience";
      }
      if (
        values.priorTotalExp &&
        values.priorRelevantExp &&
        !values.priorTotalExpYears &&
        !values.priorRelevantExpYears
      ) {
        const totalNum = parseFloat(values.priorTotalExp);
        const relNum = parseFloat(values.priorRelevantExp);
        if (!isNaN(totalNum) && !isNaN(relNum) && relNum > totalNum) {
          return "Relevant experience cannot be greater than total experience";
        }
      }
      return undefined;
    }
    case "education":
    case "certifications":
    case "technicalSkills":
    case "functionalSkills":
    case "experience":
    case "previousCompany":
    case "languages":
      return undefined;
  }
}

export function csvToList(value: string): string[] {
  return (value || "")
    .split(/[,;]/)
    .map((part) => part.trim())
    .filter(Boolean)
    .map((part) => part.slice(0, 120));
}

export function blankToNull(value: string): string | null {
  const trimmed = (value || "").trim();
  return trimmed ? trimmed : null;
}

export function toDirectoryStatus(employmentStatus: string): string {
  switch (employmentStatus) {
    case "Active - Probation":
      return "Probation";
    case "Resignation - Under Review":
    case "Resignation - Accepted":
      return "Notice Period";
    case "Inactive - After Onboarding":
      return "Inactive";
    default:
      return "Active";
  }
}

export function validateOnboardForm(
  values: OnboardValues,
  existingCodes: string[] = [],
  options?: ValidationOptions,
): OnboardErrors {
  const errors: OnboardErrors = {};
  ONBOARD_FIELDS.forEach((field) => {
    const message = validateOnboardField(field, values, existingCodes, options);
    if (message) errors[field] = message;
  });
  return errors;
}

export function validateOnboardFile(file: File): string | undefined {
  if (!file) return "File is required";
  const name = file.name || "";
  const ext = name.includes(".") ? `.${name.split(".").pop()!.toLowerCase()}` : "";
  if (!DOC_EXT.includes(ext)) return "Only PDF, JPG or PNG files are allowed";
  if (file.size > MAX_DOC_BYTES) return "File must be 5 MB or smaller";
  return undefined;
}

export function validateOnboardDocs(docs: OnboardDocs): OnboardDocErrors {
  const errors: OnboardDocErrors = {};
  if (docs.Resume) {
    const err = validateOnboardFile(docs.Resume);
    if (err) errors.Resume = err;
  }

  if (docs["PAN Card"]) {
    const err = validateOnboardFile(docs["PAN Card"]);
    if (err) errors["PAN Card"] = err;
  }

  if (docs["Aadhaar Card"]) {
    const err = validateOnboardFile(docs["Aadhaar Card"]);
    if (err) errors["Aadhaar Card"] = err;
  }

  if (docs["Offer Letter"]) {
    const err = validateOnboardFile(docs["Offer Letter"]);
    if (err) errors["Offer Letter"] = err;
  }

  if (Array.isArray(docs["Education Certs"])) {
    for (const f of docs["Education Certs"]) {
      const err = validateOnboardFile(f);
      if (err) {
        errors["Education Certs"] = err;
        break;
      }
    }
  }

  if (Array.isArray(docs["Experience Letters"])) {
    for (const f of docs["Experience Letters"]) {
      const err = validateOnboardFile(f);
      if (err) {
        errors["Experience Letters"] = err;
        break;
      }
    }
  }

  return errors;
}

export function employeeToOnboardValues(emp: Employee): OnboardValues {
  const parseYAndM = (str?: string): { years: string; months: string } => {
    if (!str || str === "Fresher" || str === "—") return { years: "0", months: "0" };
    const yMatch = str.match(/(\d+)\s*(?:Yrs?|years?)/i);
    const mMatch = str.match(/(\d+)\s*(?:Mos?|months?)/i);
    if (yMatch || mMatch) {
      return { years: yMatch ? yMatch[1] : "0", months: mMatch ? mMatch[1] : "0" };
    }
    const num = Number.parseFloat(str);
    if (!Number.isNaN(num)) {
      const y = Math.floor(num);
      const m = Math.round((num - y) * 12);
      return { years: String(y), months: String(m) };
    }
    return { years: "0", months: "0" };
  };

  const totalExpParsed = parseYAndM(emp.priorTotalExp || emp.experience);
  const relevantExpParsed = parseYAndM(emp.priorRelevantExp);

  let workerType = emp.workerType || "";
  if (!workerType) {
    if (emp.category?.includes("Intern")) workerType = "Intern";
    else if (emp.category?.includes("Contract")) workerType = "Contract";
    else workerType = "Permanent";
  }

  let bondDelivered = emp.bondDelivered || "";
  if (!bondDelivered) {
    bondDelivered = emp.category?.includes("Bond") && !emp.category?.includes("Without Bond") ? "Yes" : "No";
  }

  return {
    firstName: emp.firstName || "",
    lastName: emp.lastName || "",
    workEmail: emp.email || "",
    personalEmail: emp.personalEmail || "",
    employeeCode: emp.id || "",
    phone: emp.phone || "",
    altPhone: emp.altPhone || "",
    gender: emp.gender || "",
    dateOfBirth: emp.dob || "",
    maritalStatus: emp.maritalStatus || "",
    nationalityId: "",
    address: emp.address || "",
    emergencyContact: emp.emergencyContact || "",
    emergencyContactName: emp.emergencyContactName || "",
    emergencyContactRelation: emp.emergencyContactRelation || "",
    departmentId: emp.departmentId || "",
    designationId: emp.designationId || "",
    jobRoleId: emp.jobRoleId || "",
    businessUnit: emp.businessUnit || "Talakunchi Networks Private Limited",
    team: emp.team || "",
    projectSite: emp.projectSite || "",
    workLocation: emp.workLocation || "",
    officeBranch: emp.officeBranch || "",
    assetId: emp.assetId || "",
    employeeStatusId: emp.employeeStatusId || "",
    workerType,
    bondDelivered,
    bondDurationMonths: String(emp.bondDurationMonths ?? (bondDelivered === "Yes" ? "24" : "0")),
    exitType: emp.exitType || "NA",
    exitReason: emp.exitReason || "",
    gradDegree: emp.gradDegree || "",
    gradYear: emp.gradYear || "",
    postGradDegree: emp.postGradDegree || "NA",
    postGradYear: emp.postGradYear || "NA",
    expType: emp.expType || (emp.experience === "Fresher" ? "Fresher" : (totalExpParsed.years !== "0" || totalExpParsed.months !== "0" ? "Experienced" : "Fresher")),
    priorTotalExp: emp.priorTotalExp || emp.experience || "0",
    priorTotalExpYears: totalExpParsed.years,
    priorTotalExpMonths: totalExpParsed.months,
    priorRelevantExp: emp.priorRelevantExp || "0",
    priorRelevantExpYears: relevantExpParsed.years,
    priorRelevantExpMonths: relevantExpParsed.months,
    education: emp.education || "",
    certifications: Array.isArray(emp.certifications) ? emp.certifications.join(", ") : (emp.certifications || ""),
    technicalSkills: "",
    functionalSkills: "",
    experience: emp.experience || "",
    previousCompany: emp.previousCompany || "",
    languages: Array.isArray(emp.languages) ? emp.languages.join(", ") : (emp.languages || ""),
    pan: emp.pan || "",
    aadhaar: emp.aadhaar || "",
    pfUan: emp.pfUan || "",
    bankAccount: emp.bankAccount || "",
    ifsc: "",
    joiningDate: emp.joiningDate || "",
    reportingManagerId: emp.reportingManagerId || "",
    pmoDepartment: emp.pmoDepartment || "",
    subDepartment: emp.subDepartment || "",
    billableStatus: emp.billableStatus || "Billable",
    clientLocation: emp.clientLocation || "",
    projectType: emp.projectType || "Long Term",
    projectAllocated: emp.projectAllocated || "",
    clientEngManagerMapping: emp.clientEngManagerMapping || "",
    probationStatus: emp.probationStatus || "Ongoing",
  };
}
