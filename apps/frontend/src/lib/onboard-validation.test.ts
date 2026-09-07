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
    it("should require PAN, Aadhaar, Bank Account, and IFSC", () => {
      expect(validateOnboardField("pan", { ...EMPTY_ONBOARD, pan: "" })).toBe(
        "PAN number is required",
      );
      expect(validateOnboardField("aadhaar", { ...EMPTY_ONBOARD, aadhaar: "" })).toBe(
        "Aadhaar number is required",
      );
      expect(validateOnboardField("bankAccount", { ...EMPTY_ONBOARD, bankAccount: "" })).toBe(
        "Bank account number is required",
      );
      expect(validateOnboardField("ifsc", { ...EMPTY_ONBOARD, ifsc: "" })).toBe(
        "IFSC code is required",
      );
    });

    it("should validate valid PAN, Aadhaar, and IFSC formats", () => {
      expect(validateOnboardField("pan", { ...EMPTY_ONBOARD, pan: "ABCDE1234F" })).toBeUndefined();
      expect(validateOnboardField("aadhaar", { ...EMPTY_ONBOARD, aadhaar: "234567890124" })).toBeUndefined();
      expect(validateOnboardField("ifsc", { ...EMPTY_ONBOARD, ifsc: "SBIN0001234" })).toBeUndefined();
    });
  });

  describe("Mandatory Document Uploads Validation", () => {
    it("should require Resume, PAN Card, and Aadhaar Card uploads", () => {
      const errors = validateOnboardDocs(EMPTY_DOCS);
      expect(errors.Resume).toBe("Resume is required");
      expect(errors["PAN Card"]).toBe("PAN card is required");
      expect(errors["Aadhaar Card"]).toBe("Aadhaar card is required");
    });

    it("should pass when mandatory documents are attached", () => {
      const docsWithFiles: OnboardDocs = {
        ...EMPTY_DOCS,
        Resume: new File(["resume data"], "resume.pdf", { type: "application/pdf" }),
        "PAN Card": new File(["pan data"], "pan.jpg", { type: "image/jpeg" }),
        "Aadhaar Card": new File(["aadhaar data"], "aadhaar.pdf", { type: "application/pdf" }),
      };
      const errors = validateOnboardDocs(docsWithFiles);
      expect(errors.Resume).toBeUndefined();
      expect(errors["PAN Card"]).toBeUndefined();
      expect(errors["Aadhaar Card"]).toBeUndefined();
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
