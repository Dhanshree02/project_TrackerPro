import { cn } from "@/lib/utils";

/** Max lengths aligned to field purpose / DB columns (all text boxes and text areas max 200 characters). */
export const FIELD_MAX = {
  clientName: 200,
  subVentureName: 200,
  projectName: 200,
  personName: 200,
  firstName: 200,
  lastName: 200,
  engagementManager: 200,
  salesManager: 200,
  designation: 200,
  industry: 200,
  nationality: 200,
  address: 200,
  email: 200,
  phone: 10,
  notes: 200,
  employeeCode: 200,
  text: 200,
  team: 200,
  assetId: 200,
  exitComment: 200,
  education: 200,
  certifications: 200,
  skills: 200,
  experience: 200,
  previousCompany: 200,
  pan: 10,
  aadhaar: 12,
  pfUan: 12,
  bankAccount: 18,
  ifsc: 11,
  catalogName: 200,
  probationMonths: 2,
  noticeDays: 3,
} as const;

export const invalidFieldCls =
  "border-destructive focus-visible:ring-destructive";

export function fieldInputCls(base: string, invalid: boolean): string {
  return cn(base, invalid && invalidFieldCls);
}

/** Keep at most 10 digits (strips +91 / leading 0 on paste). */
export function toTenDigitPhone(value: string): string {
  let digits = value.replace(/\D/g, "");
  if (digits.startsWith("91") && digits.length > 10) digits = digits.slice(2);
  if (digits.startsWith("0") && digits.length === 11) digits = digits.slice(1);
  return digits.slice(0, FIELD_MAX.phone);
}

export function isValidIndianPhone(value?: string | null): boolean {
  const digits = toTenDigitPhone(value ?? "");
  if (digits.length !== 10) return false;
  if (!/^[6-9]\d{9}$/.test(digits)) return false;
  if (/^(\d)\1{9}$/.test(digits)) return false;
  return true;
}

export function isCompletePhone(value?: string | null): boolean {
  return isValidIndianPhone(value);
}

/**
 * Live phone error for Indian mobile numbers.
 * Empty is OK unless `required`.
 * Validates: 10 digits, starts with 6-9, non-repeated digits.
 */
export function phoneError(value?: string | null, required = false): string | undefined {
  const digits = toTenDigitPhone(value ?? "");
  if (!digits) return required ? "Phone number is required" : undefined;
  if (digits.length < FIELD_MAX.phone) return "Enter a 10-digit mobile number";
  if (!/^[6-9]/.test(digits)) return "Must start with 6, 7, 8, or 9";
  if (/^(\d)\1{9}$/.test(digits)) return "Invalid repeated phone number";
  return undefined;
}

/**
 * Trim then require local@domain with a real TLD (e.g. name@company.com).
 * Letters, digits, dot, underscore, and hyphen only — the only other symbol allowed is @.
 * Rejects sahil@, @gmail.com, sahil@gmail, sahil#x@gmail.com, sahil+tag@gmail.com.
 */
export function normalizeEmail(value: string): string {
  return value.trim();
}

function isEmailLocalPart(value: string): boolean {
  return /^[A-Za-z0-9](?:[A-Za-z0-9._-]*[A-Za-z0-9])?$/.test(value) && !value.includes("..");
}

function isEmailDomainLabel(value: string): boolean {
  return /^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$/.test(value);
}

export function isValidEmail(value: string): boolean {
  const email = normalizeEmail(value);
  if (!email || email.length > FIELD_MAX.email) return false;
  if (/\s/.test(email)) return false;

  const at = email.indexOf("@");
  if (at <= 0 || at !== email.lastIndexOf("@") || at === email.length - 1) return false;

  const local = email.slice(0, at);
  const domain = email.slice(at + 1);
  if (!isEmailLocalPart(local)) return false;
  if (domain.startsWith(".") || domain.endsWith(".") || domain.includes("..")) return false;

  const lastDot = domain.lastIndexOf(".");
  if (lastDot <= 0) return false;

  const tld = domain.slice(lastDot + 1);
  if (tld.length < 2 || !/^[A-Za-z]+$/.test(tld)) return false;

  const labels = domain.split(".");
  if (labels.some((label) => !isEmailDomainLabel(label))) return false;

  return true;
}

export const EMAIL_INVALID_MESSAGE =
  "Enter a valid email address (for example name@company.com)";

export function emailError(value: string, required = false): string | undefined {
  const v = normalizeEmail(value);
  if (!v) return required ? "Email is required" : undefined;
  if (!isValidEmail(v)) return EMAIL_INVALID_MESSAGE;
  if (v.length > FIELD_MAX.email) return `Email must be ${FIELD_MAX.email} characters or less`;
  return undefined;
}

export function maxLenError(
  value: string,
  max: number,
  label: string,
): string | undefined {
  if (value.length > max) return `${label} must be ${max} characters or less`;
  return undefined;
}

/** Keep at most `max` digits. */
export function toDigits(value: string, max = 10): string {
  return value.replace(/\D/g, "").slice(0, max);
}

/** Keep letters, digits, `.` `_` `-`, and a single `@`. Strips `# $ % ^ & *` etc. as you type. */
export function toEmailInput(value: string): string {
  const stripped = value.replace(/[^A-Za-z0-9._@-]/g, "");
  const at = stripped.indexOf("@");
  const next =
    at === -1
      ? stripped
      : stripped.slice(0, at + 1) + stripped.slice(at + 1).replace(/@/g, "");
  return next.slice(0, FIELD_MAX.email);
}
export function toLettersName(value: string): string {
  return value.replace(/[^A-Za-z '\-]/g, "");
}

export function isLettersName(value: string): boolean {
  return /^[A-Za-z]+(?:['\s\-][A-Za-z]+)*$/.test(value.trim());
}

/** Keep alphanumeric characters and "." for username/local part of work email. */
export function toEmailLocalPart(value: string): string {
  return value.replace(/[^A-Za-z0-9.]/g, "").slice(0, 64);
}

export function isValidEmailLocalPart(value: string): boolean {
  const v = value.trim();
  if (!v || v.length > 64) return false;
  if (v.startsWith(".") || v.endsWith(".") || v.includes("..")) return false;
  return /^[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)*$/.test(v);
}

/** Strict allowed domains for company work emails: @talakunchi.com, @talakunchi.in, @squad1.io */
export const ALLOWED_WORK_EMAIL_DOMAINS = [
  "talakunchi.com",
  "talakunchi.in",
  "squad1.io",
] as const;

export type AllowedWorkEmailDomain = (typeof ALLOWED_WORK_EMAIL_DOMAINS)[number];

export const ALLOWED_WORK_EMAIL_DOMAIN_OPTIONS = [
  { id: "talakunchi_com", code: "@talakunchi.com", name: "talakunchi.com" },
  { id: "talakunchi_in", code: "@talakunchi.in", name: "talakunchi.in" },
  { id: "squad1_io", code: "@squad1.io", name: "squad1.io" },
];

export function isAllowedWorkEmailDomain(domain: string): boolean {
  const clean = domain.replace(/^@/, "").toLowerCase().trim();
  return ALLOWED_WORK_EMAIL_DOMAINS.includes(clean as AllowedWorkEmailDomain);
}

/** TK ID = `<prefix>-<4 digits>`; TK for employees, TKI for interns. */
export const TK_ID_PREFIXES = ["TK", "TKI"] as const;
export type TkIdPrefix = (typeof TK_ID_PREFIXES)[number];
export const TK_ID_DIGITS = 4;
export const TK_ID_PATTERN = /^(TK|TKI)-\d{4}$/;

export function isValidTkId(code: string): boolean {
  return TK_ID_PATTERN.test(code.trim().toUpperCase());
}

export function joinTkId(prefix: string, digits: string): string {
  return digits ? `${prefix}-${digits}` : "";
}

/** Split `TK-0012` → `{ prefix: "TK", digits: "0012" }`. Unknown formats keep TK + digits found. */
export function splitTkId(code: string): { prefix: TkIdPrefix; digits: string } {
  const upper = code.trim().toUpperCase();
  const m = upper.match(/^(TKI|TK)-?(\d*)/);
  if (m) {
    return { prefix: m[1] as TkIdPrefix, digits: m[2].slice(0, TK_ID_DIGITS) };
  }
  return { prefix: "TK", digits: upper.replace(/\D/g, "").slice(0, TK_ID_DIGITS) };
}

/** Local calendar date as `YYYY-MM-DD`. */
export function isoDateToday(from = new Date()): string {
  return isoDateYearsAgo(0, from);
}

/** Local calendar date `years` before today, as `YYYY-MM-DD`. */
export function isoDateYearsAgo(years: number, from = new Date()): string {
  const d = new Date(from.getFullYear() - years, from.getMonth(), from.getDate());
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

