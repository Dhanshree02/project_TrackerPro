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

export const ONBOARD_DOC_SLOTS = [
  "Resume",
  "PAN Card",
  "Aadhaar Card",
  "Offer Letter",
  "Education Certs",
  "Experience Letters",
] as const;

export type OnboardDocSlot = (typeof ONBOARD_DOC_SLOTS)[number];

export const MANDATORY_DOC_SLOTS: OnboardDocSlot[] = ["Resume", "PAN Card", "Aadhaar Card"];

export const DOC_EXT = [".pdf", ".jpg", ".jpeg", ".png"];
export const MAX_DOC_BYTES = 5 * 1024 * 1024; // 5 MB

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
  | "category"
  | "assetId"
  | "status"
  | "exitType"
  | "exitReason"
  | "probationPeriod"
  | "noticePeriod"
  | "salaryBandId"
  | "education"
  | "certifications"
  | "technicalSkills"
  | "functionalSkills"
  | "experience"
  | "previousCompany"
  | "employmentType"
  | "contractType"
  | "bondStatus"
  | "languages"
  | "pan"
  | "aadhaar"
  | "pfUan"
  | "bankAccount"
  | "ifsc"
  | "joiningDate"
  | "reportingManagerId";

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
  departmentId: "",
  designationId: "",
  jobRoleId: "",
  businessUnit: "Talakunchi Networks Private Limited",
  team: "",
  projectSite: "",
  workLocation: "",
  officeBranch: "",
  category: "",
  assetId: "",
  status: "Active",
  exitType: "NA",
  exitReason: "",
  probationPeriod: "",
  noticePeriod: "",
  salaryBandId: "",
  education: "",
  certifications: "",
  technicalSkills: "",
  functionalSkills: "",
  experience: "",
  previousCompany: "",
  employmentType: "Full-Time",
  contractType: "",
  bondStatus: "",
  languages: "",
  pan: "",
  aadhaar: "",
  pfUan: "",
  bankAccount: "",
  ifsc: "",
  joiningDate: "",
  reportingManagerId: "",
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
  "address",
  "departmentId",
  "designationId",
  "jobRoleId",
  "reportingManagerId",
  "workLocation",
  "joiningDate",
  "status",
  "employmentType",
  "probationPeriod",
  "noticePeriod",
  "pan",
  "aadhaar",
  "pfUan",
  "bankAccount",
  "ifsc",
  "salaryBandId",
];

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

export function validateOnboardField(
  field: OnboardField,
  values: OnboardValues,
  existingCodes: string[] = [],
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
    case "joiningDate": {
      const v = (values.joiningDate || "").trim();
      if (!v) return "Joining date is required";
      if (v < isoDateToday()) return "Date of joining must be today or a future date";
      return undefined;
    }
    case "status": {
      const v = (values.status || "").trim();
      if (!v) return "Employment status is required";
      return undefined;
    }
    case "employmentType": {
      const v = (values.employmentType || "").trim();
      if (!v) return "Employment type is required";
      return undefined;
    }
    case "salaryBandId": {
      const v = (values.salaryBandId || "").trim();
      if (!v) return "Salary band is required";
      return undefined;
    }
    case "jobRoleId":
      return undefined;
    case "probationPeriod": {
      const v = (values.probationPeriod || "").trim();
      if (!v) return undefined;
      const n = Number(v);
      if (!Number.isInteger(n) || n < 0 || n > 36) return "Enter months between 0 and 36";
      return undefined;
    }
    case "noticePeriod": {
      const v = (values.noticePeriod || "").trim();
      if (!v) return undefined;
      const n = Number(v);
      if (!Number.isInteger(n) || n < 0 || n > 365) return "Enter days between 0 and 365";
      return undefined;
    }
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
      if (!v) return "PAN number is required";
      if (!isValidPan(v)) return "Enter a valid PAN (e.g. ABCDE1234F)";
      return undefined;
    }
    case "aadhaar": {
      const v = (values.aadhaar || "").trim();
      if (!v) return "Aadhaar number is required";
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
      if (!v) return "Bank account number is required";
      if (/\D/.test(v)) return "Only numbers are allowed";
      const n = digitsOnly(v);
      if (n.length < 9 || n.length > 18) return "Enter a valid bank account number (9–18 digits)";
      return undefined;
    }
    case "ifsc": {
      const v = (values.ifsc || "").trim();
      if (!v) return "IFSC code is required";
      if (!isValidIfsc(v)) return "Enter a valid IFSC (e.g. SBIN0001234)";
      return undefined;
    }
    case "businessUnit":
    case "team":
    case "projectSite":
    case "category":
    case "assetId":
    case "exitType":
    case "exitReason":
    case "education":
    case "certifications":
    case "technicalSkills":
    case "functionalSkills":
    case "experience":
    case "previousCompany":
    case "contractType":
    case "bondStatus":
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
): OnboardErrors {
  const errors: OnboardErrors = {};
  ONBOARD_FIELDS.forEach((field) => {
    const message = validateOnboardField(field, values, existingCodes);
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
  if (!docs.Resume) {
    errors.Resume = "Resume is required";
  } else {
    const err = validateOnboardFile(docs.Resume);
    if (err) errors.Resume = err;
  }

  if (!docs["PAN Card"]) {
    errors["PAN Card"] = "PAN card is required";
  } else {
    const err = validateOnboardFile(docs["PAN Card"]);
    if (err) errors["PAN Card"] = err;
  }

  if (!docs["Aadhaar Card"]) {
    errors["Aadhaar Card"] = "Aadhaar card is required";
  } else {
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
