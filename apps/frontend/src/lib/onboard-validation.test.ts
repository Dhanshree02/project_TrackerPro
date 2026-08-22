import { describe, expect, it } from "vitest";
import {
  EMPTY_ONBOARD,
  blankToNull,
  csvToList,
  digitsOnly,
  formatBytes,
  isValidAadhaar,
  isValidIfsc,
  isValidPan,
  toDirectoryStatus,
  validateOnboardField,
  validateOnboardFile,
  validateOnboardForm,
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
  describe("First Name and Last Name Validation", () => {
    it("should fail when first name is empty or whitespace", () => {
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "" })).toBe(
        "First name is required",
      );
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "   " })).toBe(
        "First name is required",
      );
    });

    it("should fail when first name contains digits or invalid symbols", () => {
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "John123" })).toBe(
        "Only letters, spaces, hyphens, and apostrophes are allowed",
      );
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "Jane@Doe" })).toBe(
        "Only letters, spaces, hyphens, and apostrophes are allowed",
      );
    });

    it("should accept valid names with hyphens, spaces, and apostrophes", () => {
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "Jean-Luc" })).toBeUndefined();
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: "Mary Jane" })).toBeUndefined();
      expect(validateOnboardField("lastName", { ...EMPTY_ONBOARD, lastName: "O'Connor" })).toBeUndefined();
    });

    it("should fail when name exceeds 120 characters", () => {
      const longName = "A".repeat(121);
      expect(validateOnboardField("firstName", { ...EMPTY_ONBOARD, firstName: longName })).toBe(
        "First name must be 120 characters or less",
      );
    });
  });

  describe("Work Email & Username Validation", () => {
    it("should require work email", () => {
      expect(validateOnboardField("workEmail", { ...EMPTY_ONBOARD, workEmail: "" })).toBe(
        "Work email is required",
      );
    });

    it("should reject invalid email local parts (usernames)", () => {
      expect(
        validateOnboardField("workEmail", { ...EMPTY_ONBOARD, workEmail: "john..doe@domain.com" }),
      ).toBe("Username can only contain letters, numbers, and '.'");

      expect(
        validateOnboardField("workEmail", { ...EMPTY_ONBOARD, workEmail: ".johndoe@domain.com" }),
      ).toBe("Username can only contain letters, numbers, and '.'");
    });

    it("should accept well-formed work emails", () => {
      expect(
        validateOnboardField("workEmail", { ...EMPTY_ONBOARD, workEmail: "john.doe@company.com" }),
      ).toBeUndefined();
      expect(
        validateOnboardField("workEmail", { ...EMPTY_ONBOARD, workEmail: "sarah123@sub.domain.org" }),
      ).toBeUndefined();
    });
  });

  describe("Personal Email & Conflict Exception", () => {
    it("should allow empty personal email since it is optional", () => {
      expect(validateOnboardField("personalEmail", { ...EMPTY_ONBOARD, personalEmail: "" })).toBeUndefined();
    });

    it("should reject malformed personal email formats", () => {
      expect(
        validateOnboardField("personalEmail", { ...EMPTY_ONBOARD, personalEmail: "notanemail" }),
      ).toBe("Enter a valid email address (for example name@company.com)");

      expect(
        validateOnboardField("personalEmail", { ...EMPTY_ONBOARD, personalEmail: "user@domain" }),
      ).toBe("Enter a valid email address (for example name@company.com)");
    });

    it("should reject personal email identical to work email (case-insensitive)", () => {
      const values: OnboardValues = {
        ...EMPTY_ONBOARD,
        workEmail: "john.doe@company.com",
        personalEmail: "JOHN.DOE@COMPANY.COM",
      };
      expect(validateOnboardField("personalEmail", values)).toBe(
        "Personal email should be different from work email",
      );
    });

    it("should accept valid distinct personal email", () => {
      const values: OnboardValues = {
        ...EMPTY_ONBOARD,
        workEmail: "john.doe@company.com",
        personalEmail: "john.personal@gmail.com",
      };
      expect(validateOnboardField("personalEmail", values)).toBeUndefined();
    });
  });

  describe("Employee ID / Code & Uniqueness Exception", () => {
    it("should require employee code", () => {
      expect(validateOnboardField("employeeCode", { ...EMPTY_ONBOARD, employeeCode: "" })).toBe(
        "Employee ID is required",
      );
    });

    it("should reject invalid characters in employee code", () => {
      expect(validateOnboardField("employeeCode", { ...EMPTY_ONBOARD, employeeCode: "EMP#001" })).toBe(
        "Use letters, numbers, dot, hyphen or underscore",
      );
      expect(validateOnboardField("employeeCode", { ...EMPTY_ONBOARD, employeeCode: "EMP 001" })).toBe(
        "Use letters, numbers, dot, hyphen or underscore",
      );
    });

    it("should reject duplicate employee IDs (case-insensitive)", () => {
      const existing = ["EMP-001", "EMP-002", "TRACKER-100"];
      expect(
        validateOnboardField(
          "employeeCode",
          { ...EMPTY_ONBOARD, employeeCode: "emp-001" },
          existing,
        ),
      ).toBe("This employee ID already exists");
    });

    it("should accept unique valid employee codes", () => {
      const existing = ["EMP-001", "EMP-002"];
      expect(
        validateOnboardField(
          "employeeCode",
          { ...EMPTY_ONBOARD, employeeCode: "EMP-003" },
          existing,
        ),
      ).toBeUndefined();
    });
  });

  describe("Phone Number Validation & Edge Cases", () => {
    it("should sanitize and strip leading +91 / 0 correctly", () => {
      expect(toTenDigitPhone("+91 98765 43210")).toBe("9876543210");
      expect(toTenDigitPhone("09876543210")).toBe("9876543210");
    });

    it("should reject phones shorter than 10 digits", () => {
      expect(phoneError("987654")).toBe("Enter a 10-digit mobile number");
    });

    it("should reject phones not starting with 6, 7, 8, or 9", () => {
      expect(phoneError("5123456789")).toBe("Must start with 6, 7, 8, or 9");
      expect(phoneError("1234567890")).toBe("Must start with 6, 7, 8, or 9");
    });

    it("should reject repeated 10-digit bogus numbers", () => {
      expect(phoneError("9999999999")).toBe("Invalid repeated phone number");
      expect(phoneError("8888888888")).toBe("Invalid repeated phone number");
    });

    it("should accept valid Indian mobile numbers", () => {
      expect(isValidIndianPhone("9876543210")).toBe(true);
      expect(isValidIndianPhone("7012345678")).toBe(true);
      expect(isValidIndianPhone("6123456789")).toBe(true);
      expect(phoneError("9876543210")).toBeUndefined();
    });
  });

  describe("Date of Birth & Age Constraints", () => {
    it("should reject applicants under 18 years old", () => {
      const minorDob = isoDateYearsAgo(17); // 17 years old
      expect(
        validateOnboardField("dateOfBirth", { ...EMPTY_ONBOARD, dateOfBirth: minorDob }),
      ).toBe("Employee must be at least 18 years old");
    });

    it("should accept applicants 18 years or older", () => {
      const adultDob = isoDateYearsAgo(25);
      expect(
        validateOnboardField("dateOfBirth", { ...EMPTY_ONBOARD, dateOfBirth: adultDob }),
      ).toBeUndefined();
    });

    it("should reject implausible DOB over 100 years ago", () => {
      const ancientDob = isoDateYearsAgo(105);
      expect(
        validateOnboardField("dateOfBirth", { ...EMPTY_ONBOARD, dateOfBirth: ancientDob }),
      ).toBe("Enter a valid date of birth");
    });
  });

  describe("Joining Date Validation", () => {
    it("should reject joining date in the past", () => {
      const pastDate = isoDateYearsAgo(1);
      expect(
        validateOnboardField("joiningDate", { ...EMPTY_ONBOARD, joiningDate: pastDate }),
      ).toBe("Date of joining must be today or a future date");
    });

    it("should accept today or future joining date", () => {
      expect(
        validateOnboardField("joiningDate", { ...EMPTY_ONBOARD, joiningDate: isoDateToday() }),
      ).toBeUndefined();
    });
  });

  describe("Probation and Notice Period Constraints", () => {
    it("should validate probation period between 0 and 36 months", () => {
      expect(
        validateOnboardField("probationPeriod", { ...EMPTY_ONBOARD, probationPeriod: "6" }),
      ).toBeUndefined();
      expect(
        validateOnboardField("probationPeriod", { ...EMPTY_ONBOARD, probationPeriod: "40" }),
      ).toBe("Enter months between 0 and 36");
      expect(
        validateOnboardField("probationPeriod", { ...EMPTY_ONBOARD, probationPeriod: "-2" }),
      ).toBe("Enter months between 0 and 36");
    });

    it("should validate notice period between 0 and 365 days", () => {
      expect(
        validateOnboardField("noticePeriod", { ...EMPTY_ONBOARD, noticePeriod: "90" }),
      ).toBeUndefined();
      expect(
        validateOnboardField("noticePeriod", { ...EMPTY_ONBOARD, noticePeriod: "400" }),
      ).toBe("Enter days between 0 and 365");
    });
  });

  describe("Statutory Identity Verification (PAN, Aadhaar, PF/UAN, IFSC, Bank)", () => {
    it("should validate Indian PAN format (5 letters, 4 digits, 1 letter)", () => {
      expect(isValidPan("ABCDE1234F")).toBe(true);
      expect(isValidPan("abcde1234f")).toBe(true);
      expect(isValidPan("12345ABCDE")).toBe(false);
      expect(isValidPan("ABCDE12345")).toBe(false);
      expect(isValidPan("ABCD12345F")).toBe(false);
    });

    it("should validate Aadhaar with Verhoeff checksum algorithm", () => {
      // All zeros must fail
      expect(isValidAadhaar("000000000000")).toBe(false);
      // Less than 12 digits must fail
      expect(isValidAadhaar("123456")).toBe(false);
      // Valid known Verhoeff Aadhaar numbers
      expect(isValidAadhaar("234567890124")).toBe(true);
      // Corrupting last check digit must fail
      expect(isValidAadhaar("234567890125")).toBe(false);
    });

    it("should validate PF/UAN format (exactly 12 numeric digits)", () => {
      expect(
        validateOnboardField("pfUan", { ...EMPTY_ONBOARD, pfUan: "100987654321" }),
      ).toBeUndefined();
      expect(
        validateOnboardField("pfUan", { ...EMPTY_ONBOARD, pfUan: "100987654" }),
      ).toBe("UAN must be a valid 12-digit number");
      expect(
        validateOnboardField("pfUan", { ...EMPTY_ONBOARD, pfUan: "10098765432A" }),
      ).toBe("Only numbers are allowed");
    });

    it("should validate Bank Account number (9 to 18 digits)", () => {
      expect(
        validateOnboardField("bankAccount", { ...EMPTY_ONBOARD, bankAccount: "123456789012" }),
      ).toBeUndefined();
      expect(
        validateOnboardField("bankAccount", { ...EMPTY_ONBOARD, bankAccount: "1234" }),
      ).toBe("Enter a valid bank account number (9–18 digits)");
      expect(
        validateOnboardField("bankAccount", { ...EMPTY_ONBOARD, bankAccount: "12345678901234567890" }),
      ).toBe("Enter a valid bank account number (9–18 digits)");
    });

    it("should validate IFSC Code format (4 letters, '0', 6 alphanumeric)", () => {
      expect(isValidIfsc("SBIN0001234")).toBe(true);
      expect(isValidIfsc("HDFC0000001")).toBe(true);
      expect(isValidIfsc("sbin0001234")).toBe(true);
      // 5th character not 0
      expect(isValidIfsc("SBIN1001234")).toBe(false);
      // Invalid length
      expect(isValidIfsc("SBIN00012")).toBe(false);
    });
  });

  describe("Document File Upload Verification", () => {
    it("should reject disallowed extensions (.exe, .zip, .txt)", () => {
      const exeFile = new File(["dummy"], "malware.exe", { type: "application/x-msdownload" });
      expect(validateOnboardFile(exeFile)).toBe("Only PDF, JPG or PNG files are allowed");

      const zipFile = new File(["dummy"], "archive.zip", { type: "application/zip" });
      expect(validateOnboardFile(zipFile)).toBe("Only PDF, JPG or PNG files are allowed");
    });

    it("should reject files exceeding 5 MB", () => {
      const bigContent = new Uint8Array(6 * 1024 * 1024); // 6 MB
      const bigFile = new File([bigContent], "huge_resume.pdf", { type: "application/pdf" });
      expect(validateOnboardFile(bigFile)).toBe("File must be 5 MB or smaller");
    });

    it("should accept valid PDF and image files within 5 MB", () => {
      const pdfFile = new File(["%PDF-1.4..."], "resume.pdf", { type: "application/pdf" });
      expect(validateOnboardFile(pdfFile)).toBeUndefined();

      const imgFile = new File(["imgdata"], "pan_card.jpg", { type: "image/jpeg" });
      expect(validateOnboardFile(imgFile)).toBeUndefined();
    });
  });

  describe("Comprehensive Form-level Validation & Transformation Helpers", () => {
    it("should accumulate errors for all invalid required fields in empty form", () => {
      const errors = validateOnboardForm(EMPTY_ONBOARD);
      expect(errors.firstName).toBe("First name is required");
      expect(errors.lastName).toBe("Last name is required");
      expect(errors.workEmail).toBe("Work email is required");
      expect(errors.employeeCode).toBe("Employee ID is required");
    });

    it("should pass cleanly when all fields are valid", () => {
      const validForm: OnboardValues = {
        ...EMPTY_ONBOARD,
        firstName: "Rajesh",
        lastName: "Sharma",
        workEmail: "rajesh.sharma@company.com",
        personalEmail: "rajesh.personal@gmail.com",
        employeeCode: "EMP-2045",
        phone: "9876543210",
        altPhone: "9876543211",
        emergencyContact: "9876543212",
        dateOfBirth: "1995-05-15",
        joiningDate: isoDateToday(),
        pan: "ABCDE1234F",
        aadhaar: "234567890124",
        pfUan: "100987654321",
        bankAccount: "123456789012",
        ifsc: "SBIN0001234",
        probationPeriod: "6",
        noticePeriod: "90",
      };

      const errors = validateOnboardForm(validForm, ["EMP-1001"]);
      expect(Object.keys(errors).length).toBe(0);
    });

    it("should map employment statuses accurately to directory status", () => {
      expect(toDirectoryStatus("Active - Probation")).toBe("Probation");
      expect(toDirectoryStatus("Resignation - Under Review")).toBe("Notice Period");
      expect(toDirectoryStatus("Inactive - After Onboarding")).toBe("Inactive");
      expect(toDirectoryStatus("Active")).toBe("Active");
    });

    it("should split CSV lists and format bytes cleanly", () => {
      expect(csvToList("React, TypeScript; Node.js , Next.js")).toEqual([
        "React",
        "TypeScript",
        "Node.js",
        "Next.js",
      ]);
      expect(blankToNull("   ")).toBeNull();
      expect(blankToNull("Value")).toBe("Value");
      expect(formatBytes(500)).toBe("500 B");
      expect(formatBytes(1536)).toBe("1.5 KB");
      expect(formatBytes(2097152)).toBe("2.0 MB");
    });
  });
});
