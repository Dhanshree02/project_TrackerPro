import { describe, expect, it } from "vitest";
import {
  EMPTY_DOCS,
  EMPTY_ONBOARD,
  blankToNull,
  csvToList,
  digitsOnly,
  formatBytes,
  isValidAadhaar,
  isValidIfsc,
  isValidPan,
  toDirectoryStatus,
  validateOnboardDocs,
  validateOnboardField,
  validateOnboardFile,
  validateOnboardForm,
  PMO_DEPARTMENT_OPTIONS,
  PMO_DEPARTMENT_SUB_DEPARTMENTS,
  formatExpDisplay,
  computeTotalMonths,
  parseExpToYearsMonths,
  type OnboardDocs,
  type OnboardValues,
} from "./onboard-validation";
import {
  isoDateToday,
  isoDateYearsAgo,
  isValidEmail,
  isValidIndianPhone,
  phoneError,
  toTenDigitPhone,
} from "./form-validation";

describe("Onboarding Form Validation & Exception Handling", () => {
  describe("Personal Information Validation", () => {
    it("should fail when first name is empty or whitespace", () => {
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "" })).toBe(
        "First name is required",
      );
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "   " })).toBe(
        "First name is required",
      );
    });

    it("should fail when last name is empty or whitespace", () => {
      expect(validateOnboardField("lastName", { ...EMPTY_ONBOARD, lastName: "" })).toBe(
        "Last name is required",
      );
    });

    it("should fail when first name contains digits or invalid symbols", () => {
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "John123" })).toBe(
        "Only letters, spaces, hyphens, and apostrophes are allowed",
      );
    });

    it("should not require gender", () => {
      expect(validateOnboardField("gender", { ...EMPTY_ONBOARD, gender: "" })).toBeUndefined();
    });

    it("should enforce age limits if date of birth is provided", () => {
      expect(validateOnboardField("dateOfBirth", { ...EMPTY_ONBOARD, dateOfBirth: "" })).toBeUndefined();
      const minorDob = isoDateYearsAgo(17);
      expect(
        validateOnboardField("dateOfBirth", { ...EMPTY_ONBOARD, dateOfBirth: minorDob }),
      ).toBe("Employee must be at least 18 years old");
      const adultDob = isoDateYearsAgo(25);
      expect(
        validateOnboardField("dateOfBirth", { ...EMPTY_ONBOARD, dateOfBirth: adultDob }),
      ).toBeUndefined();
    });

    it("should require Current Address - City", () => {
      expect(validateOnboardField("address", { ...EMPTY_ONBOARD, address: "" })).toBe(
        "Current Address - City is required",
      );
      expect(
        validateOnboardField("address", { ...EMPTY_ONBOARD, address: "Andheri (Western Line)" }),
      ).toBeUndefined();
    });

    it("should require emergency contact name and phone", () => {
      expect(validateOnboardField("emergencyContactName", { ...EMPTY_ONBOARD, emergencyContactName: "" })).toBe(
        "Emergency contact name is required",
      );
      expect(validateOnboardField("emergencyContactName", { ...EMPTY_ONBOARD, emergencyContactName: "123" })).toBe(
        "Only letters, spaces, hyphens, and apostrophes are allowed",
      );
      expect(validateOnboardField("emergencyContactName", { ...EMPTY_ONBOARD, emergencyContactName: "Pooja Sharma" })).toBeUndefined();
    });

    it("should require phone and emergency contact", () => {
      expect(validateOnboardField("phone", { ...EMPTY_ONBOARD, phone: "" })).toBe(
        "Phone number is required",
      );
      expect(validateOnboardField("emergencyContact", { ...EMPTY_ONBOARD, emergencyContact: "" })).toBe(
        "Phone number is required",
      );
      expect(
        validateOnboardField("emergencyContact", { ...EMPTY_ONBOARD, emergencyContact: "9876543210" }),
      ).toBeUndefined();
    });

    it("should require relation with emergency contact", () => {
      expect(
        validateOnboardField("emergencyContactRelation", { ...EMPTY_ONBOARD, emergencyContactRelation: "" }),
      ).toBe("Relation with emergency contact is required");
      expect(
        validateOnboardField("emergencyContactRelation", { ...EMPTY_ONBOARD, emergencyContactRelation: "   " }),
      ).toBe("Relation with emergency contact is required");
      expect(
        validateOnboardField("emergencyContactRelation", { ...EMPTY_ONBOARD, emergencyContactRelation: "Father" }),
      ).toBeUndefined();
    });
  });

  describe("Organizational Placement Validation", () => {
    it("should require department, designation, manager, and work location (office is not required)", () => {
      expect(validateOnboardField("departmentId", { ...EMPTY_ONBOARD, departmentId: "" })).toBe(
        "Department is required",
      );
      expect(validateOnboardField("designationId", { ...EMPTY_ONBOARD, designationId: "" })).toBe(
        "Designation is required",
      );
      expect(validateOnboardField("reportingManagerId", { ...EMPTY_ONBOARD, reportingManagerId: "" })).toBe(
        "Reporting manager is required",
      );
      expect(validateOnboardField("workLocation", { ...EMPTY_ONBOARD, workLocation: "" })).toBe(
        "Work location is required",
      );
      expect(validateOnboardField("officeBranch", { ...EMPTY_ONBOARD, officeBranch: "" })).toBeUndefined();
    });
  });

  describe("Employment Terms Validation", () => {
    it("should require joining date, employee status, worker type, and bond fields", () => {
      expect(validateOnboardField("joiningDate", { ...EMPTY_ONBOARD, joiningDate: "" })).toBe(
        "Joining date is required",
      );
      expect(validateOnboardField("employeeStatusId", { ...EMPTY_ONBOARD, employeeStatusId: "" })).toBe(
        "Employee status is required",
      );
      expect(validateOnboardField("workerType", { ...EMPTY_ONBOARD, workerType: "" })).toBe(
        "Worker type is required",
      );
      expect(validateOnboardField("bondDelivered", { ...EMPTY_ONBOARD, bondDelivered: "" })).toBe(
        "Bond delivered is required",
      );
    });

    it("should require bond duration when bond is delivered", () => {
      expect(
        validateOnboardField("bondDurationMonths", {
          ...EMPTY_ONBOARD,
          bondDelivered: "Yes",
          bondDurationMonths: "",
        }),
      ).toBe("Bond duration is required when bond is delivered");
    });

    it("should reject past joining dates", () => {
      const pastDate = isoDateYearsAgo(1);
      expect(
        validateOnboardField("joiningDate", { ...EMPTY_ONBOARD, joiningDate: pastDate }),
      ).toBe("Date of joining must be today or a future date");
    });
  });

  describe("Payroll & Statutory Details Validation", () => {
    it("should allow optional PAN, Aadhaar, Bank Account, and IFSC when empty", () => {
      expect(validateOnboardField("pan", { ...EMPTY_ONBOARD, pan: "" })).toBeUndefined();
      expect(validateOnboardField("aadhaar", { ...EMPTY_ONBOARD, aadhaar: "" })).toBeUndefined();
      expect(validateOnboardField("bankAccount", { ...EMPTY_ONBOARD, bankAccount: "" })).toBeUndefined();
      expect(validateOnboardField("ifsc", { ...EMPTY_ONBOARD, ifsc: "" })).toBeUndefined();
    });

    it("should validate valid PAN, Aadhaar, and IFSC formats when provided", () => {
      expect(validateOnboardField("pan", { ...EMPTY_ONBOARD, pan: "ABCDE1234F" })).toBeUndefined();
      expect(validateOnboardField("pan", { ...EMPTY_ONBOARD, pan: "INVALID" })).toBe(
        "Enter a valid PAN (e.g. ABCDE1234F)",
      );
      expect(validateOnboardField("aadhaar", { ...EMPTY_ONBOARD, aadhaar: "234567890124" })).toBeUndefined();
      expect(validateOnboardField("ifsc", { ...EMPTY_ONBOARD, ifsc: "SBIN0001234" })).toBeUndefined();
    });
  });

  describe("PMO Section & Document Uploads", () => {
    it("should not block submission when document slots are empty", () => {
      const errors = validateOnboardDocs(EMPTY_DOCS);
      expect(Object.keys(errors).length).toBe(0);
    });

    it("should correctly map departments to sub-departments", () => {
      expect(PMO_DEPARTMENT_OPTIONS).toContain("Core");
      expect(PMO_DEPARTMENT_OPTIONS).toContain("Functional - Project Management");
      expect(PMO_DEPARTMENT_OPTIONS).toContain("Services - Testing");
      expect(PMO_DEPARTMENT_OPTIONS).toContain("Internship Program");

      expect(PMO_DEPARTMENT_SUB_DEPARTMENTS["Core"]).toEqual([
        "Leading Sales & A/C Dept.",
        "Leading Delivery Dept.",
        "Leading Compliance & HR Dept.",
      ]);

      expect(PMO_DEPARTMENT_SUB_DEPARTMENTS["Functional - Project Management"]).toEqual([
        "PMO (Project Management Office)",
        "EM (Engagement Manager)",
      ]);

      expect(PMO_DEPARTMENT_SUB_DEPARTMENTS["Services - Testing"]).toEqual([
        "Service - Testing - AppSec",
        "Service - Testing - Mobile",
        "Service - Testing - Infra",
        "Services - Testing - DevSecOps",
        "Services - Testing - Red Team",
        "Services - Testing - Cloud & AI",
      ]);

      expect(PMO_DEPARTMENT_SUB_DEPARTMENTS["Internship Program"]).toEqual([
        "Across all Sub Departments",
      ]);

      expect(PMO_DEPARTMENT_SUB_DEPARTMENTS["Functional - Accounts"]).toEqual(["-"]);
    });

    it("should allow PMO section fields", () => {
      expect(validateOnboardField("pmoDepartment", { ...EMPTY_ONBOARD, pmoDepartment: "Core" })).toBeUndefined();
      expect(validateOnboardField("subDepartment", { ...EMPTY_ONBOARD, subDepartment: "Leading Delivery Dept." })).toBeUndefined();
      expect(validateOnboardField("billableStatus", { ...EMPTY_ONBOARD, billableStatus: "Billable" })).toBeUndefined();
      expect(validateOnboardField("clientLocation", { ...EMPTY_ONBOARD, clientLocation: "Andheri (Western Line)" })).toBeUndefined();
      expect(validateOnboardField("projectType", { ...EMPTY_ONBOARD, projectType: "Long Term" })).toBeUndefined();
      expect(validateOnboardField("projectAllocated", { ...EMPTY_ONBOARD, projectAllocated: "Project Alpha" })).toBeUndefined();
      expect(validateOnboardField("clientEngManagerMapping", { ...EMPTY_ONBOARD, clientEngManagerMapping: "John Doe" })).toBeUndefined();
    });
  });

  describe("Work Email & Personal Email Conflicts", () => {
    it("should require work email and reject identical personal email", () => {
      expect(validateOnboardField("workEmail", { ...EMPTY_ONBOARD, workEmail: "" })).toBe(
        "Work email is required",
      );
      const values: OnboardValues = {
        ...EMPTY_ONBOARD,
        workEmail: "john.doe@company.com",
        personalEmail: "JOHN.DOE@COMPANY.COM",
      };
      expect(validateOnboardField("personalEmail", values)).toBe(
        "Personal email should be different from work email",
      );
    });
  });

  describe("Education & Passing Year Validation", () => {
    it("should require graduation degree name when graduation passing year is selected", () => {
      expect(
        validateOnboardField("gradDegree", { ...EMPTY_ONBOARD, gradYear: "2022", gradDegree: "" }),
      ).toBe("Graduation degree name is required when graduation passing year is selected");

      expect(
        validateOnboardField("gradDegree", { ...EMPTY_ONBOARD, gradYear: "2022", gradDegree: "   " }),
      ).toBe("Graduation degree name is required when graduation passing year is selected");

      expect(
        validateOnboardField("gradDegree", { ...EMPTY_ONBOARD, gradYear: "2022", gradDegree: "B.Tech" }),
      ).toBeUndefined();

      expect(
        validateOnboardField("gradDegree", { ...EMPTY_ONBOARD, gradYear: "", gradDegree: "" }),
      ).toBeUndefined();
    });

    it("should require graduation passing year when graduation degree is selected", () => {
      expect(
        validateOnboardField("gradYear", { ...EMPTY_ONBOARD, gradDegree: "B.Tech", gradYear: "" }),
      ).toBe("Graduation passing year is required when graduation degree is selected");

      expect(
        validateOnboardField("gradYear", { ...EMPTY_ONBOARD, gradDegree: "B.Tech", gradYear: "NA" }),
      ).toBe("Graduation passing year is required when graduation degree is selected");

      expect(
        validateOnboardField("gradYear", { ...EMPTY_ONBOARD, gradDegree: "B.Tech", gradYear: "2022" }),
      ).toBeUndefined();

      expect(
        validateOnboardField("gradYear", { ...EMPTY_ONBOARD, gradDegree: "", gradYear: "" }),
      ).toBeUndefined();
    });

    it("should require post graduation passing year whenever post graduation degree name is selected", () => {
      expect(
        validateOnboardField("postGradYear", { ...EMPTY_ONBOARD, postGradDegree: "MBA", postGradYear: "" }),
      ).toBe("Post graduation passing year is required when post graduation degree is selected");

      expect(
        validateOnboardField("postGradYear", { ...EMPTY_ONBOARD, postGradDegree: "MBA", postGradYear: "NA" }),
      ).toBe("Post graduation passing year is required when post graduation degree is selected");

      expect(
        validateOnboardField("postGradYear", { ...EMPTY_ONBOARD, postGradDegree: "MBA", postGradYear: "2024" }),
      ).toBeUndefined();

      expect(
        validateOnboardField("postGradYear", { ...EMPTY_ONBOARD, postGradDegree: "NA", postGradYear: "NA" }),
      ).toBeUndefined();

      expect(
        validateOnboardField("postGradYear", { ...EMPTY_ONBOARD, postGradDegree: "", postGradYear: "" }),
      ).toBeUndefined();
    });

    it("should validate post graduation passing year cannot be lower than graduation passing year", () => {
      expect(
        validateOnboardField("postGradYear", {
          ...EMPTY_ONBOARD,
          gradYear: "2022",
          postGradDegree: "MBA",
          postGradYear: "2020",
        }),
      ).toBe("Post graduation passing year cannot be lower than graduation passing year");

      expect(
        validateOnboardField("postGradYear", {
          ...EMPTY_ONBOARD,
          gradYear: "2022",
          postGradDegree: "MBA",
          postGradYear: "2022",
        }),
      ).toBeUndefined();

      expect(
        validateOnboardField("postGradYear", {
          ...EMPTY_ONBOARD,
          gradYear: "2022",
          postGradDegree: "MBA",
          postGradYear: "2024",
        }),
      ).toBeUndefined();

      expect(
        validateOnboardField("postGradYear", {
          ...EMPTY_ONBOARD,
          gradYear: "2022",
          postGradDegree: "NA",
          postGradYear: "NA",
        }),
      ).toBeUndefined();
    });
  });

  describe("Total exp & Relevant exp (Years & Months) Validation", () => {
    it("should format experience displays cleanly", () => {
      expect(formatExpDisplay("3", "6")).toBe("3 Years 6 Months");
      expect(formatExpDisplay("1", "1")).toBe("1 Year 1 Month");
      expect(formatExpDisplay("3", "0")).toBe("3 Years");
      expect(formatExpDisplay("0", "6")).toBe("6 Months");
      expect(formatExpDisplay("0", "0")).toBe("0");
    });

    it("should calculate total months correctly", () => {
      expect(computeTotalMonths("3", "6")).toBe(42);
      expect(computeTotalMonths("0", "11")).toBe(11);
      expect(computeTotalMonths("2", "0")).toBe(24);
    });

    it("should parse experience strings into years and months", () => {
      expect(parseExpToYearsMonths("3 Years 6 Months")).toEqual({ years: "3", months: "6" });
      expect(parseExpToYearsMonths("2 Years")).toEqual({ years: "2", months: "0" });
      expect(parseExpToYearsMonths("5 Months")).toEqual({ years: "0", months: "5" });
      expect(parseExpToYearsMonths("3.5")).toEqual({ years: "3", months: "6" });
      expect(parseExpToYearsMonths("0")).toEqual({ years: "0", months: "0" });
      expect(parseExpToYearsMonths("Fresher")).toEqual({ years: "0", months: "0" });
    });

    it("should enforce months between 0 and 11", () => {
      expect(
        validateOnboardField("priorTotalExpMonths", {
          ...EMPTY_ONBOARD,
          expType: "Experienced",
          priorTotalExpMonths: "14",
        }),
      ).toBe("Months must be between 0 and 11");

      expect(
        validateOnboardField("priorTotalExpMonths", {
          ...EMPTY_ONBOARD,
          expType: "Experienced",
          priorTotalExpMonths: "11",
        }),
      ).toBeUndefined();

      expect(
        validateOnboardField("priorRelevantExpMonths", {
          ...EMPTY_ONBOARD,
          expType: "Experienced",
          priorRelevantExpMonths: "15",
        }),
      ).toBe("Months must be between 0 and 11");
    });

    it("should reject relevant experience exceeding total experience", () => {
      expect(
        validateOnboardField("priorRelevantExpYears", {
          ...EMPTY_ONBOARD,
          expType: "Experienced",
          priorTotalExpYears: "2",
          priorTotalExpMonths: "6",
          priorRelevantExpYears: "3",
          priorRelevantExpMonths: "0",
        }),
      ).toBe("Relevant experience cannot be greater than total experience");

      expect(
        validateOnboardField("priorRelevantExpYears", {
          ...EMPTY_ONBOARD,
          expType: "Experienced",
          priorTotalExpYears: "3",
          priorTotalExpMonths: "0",
          priorRelevantExpYears: "2",
          priorRelevantExpMonths: "6",
        }),
      ).toBeUndefined();

      expect(
        validateOnboardField("priorRelevantExpYears", {
          ...EMPTY_ONBOARD,
          expType: "Fresher",
          priorTotalExpYears: "0",
          priorRelevantExpYears: "5",
        }),
      ).toBeUndefined();
    });
  });

  describe("Full Form Aggregation & Valid Employee Creation", () => {
    it("should pass cleanly when all required fields and documents are complete", () => {
      const validForm: OnboardValues = {
        ...EMPTY_ONBOARD,
        firstName: "Rajesh",
        lastName: "Sharma",
        workEmail: "rajesh.sharma@talakunchi.com",
        personalEmail: "",
        employeeCode: "TK-2045",
        phone: "9876543210",
        altPhone: "9876543211",
        emergencyContact: "9876543212",
        emergencyContactName: "Pooja Sharma",
        emergencyContactRelation: "Spouse",
        gender: "",
        address: "Andheri (Western Line)",
        departmentId: "DEPT-01",
        designationId: "DESIG-01",
        reportingManagerId: "MGR-01",
        workLocation: "Mumbai",
        officeBranch: "Andheri East",
        joiningDate: isoDateToday(),
        employeeStatusId: "status-active",
        workerType: "Permanent",
        bondDelivered: "No",
        bondDurationMonths: "0",
        pan: "ABCDE1234F",
        aadhaar: "234567890124",
        pfUan: "100987654321",
        bankAccount: "123456789012",
        ifsc: "SBIN0001234",
      };

      const errors = validateOnboardForm(validForm, ["TK-1001"]);
      expect(Object.keys(errors).length).toBe(0);
    });
  });
});
