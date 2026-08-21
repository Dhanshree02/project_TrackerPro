import { cn } from "@/lib/utils";

/** Max lengths aligned to field purpose / DB columns. */
export const FIELD_MAX = {
  clientName: 255,
  subVentureName: 255,
  projectName: 255,
  personName: 150,
  firstName: 120,
  lastName: 120,
  engagementManager: 120,
  designation: 120,
  industry: 100,
  nationality: 80,
  address: 500,
  email: 255,
  phone: 10,
  notes: 2000,
  employeeCode: 20,
  text: 255,
  team: 120,
  assetId: 80,
  exitComment: 500,
  education: 255,
  certifications: 255,
  skills: 255,
  experience: 80,
  previousCompany: 160,
  pan: 10,
  aadhaar: 12,
  pfUan: 12,
  bankAccount: 18,
  ifsc: 11,
  catalogName: 150,
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

export function isCompletePhone(value: string): boolean {
  return toTenDigitPhone(value).length === FIELD_MAX.phone;
}

/**
 * Live phone error. Empty is OK unless `required`.
 * Fewer than 10 digits → red box + message.
 */
export function phoneError(value: string, required = false): string | undefined {
  const digits = value.replace(/\D/g, "");
  if (!digits) return required ? "Phone number is required" : undefined;
  if (digits.length < FIELD_MAX.phone) return "Enter a 10-digit phone number";
  return undefined;
}

/**
 * Email must include a single @ with text on both sides.
 * Other punctuation (dots in the domain) is allowed; spaces are not.
 */
export function isValidEmail(value: string): boolean {
  const v = value.trim();
  if (!v) return false;
  const at = v.indexOf("@");
  if (at <= 0 || at !== v.lastIndexOf("@") || at === v.length - 1) return false;
  if (/\s/.test(v)) return false;
  return true;
}

export function emailError(value: string, required = false): string | undefined {
  const v = value.trim();
  if (!v) return required ? "Email is required" : undefined;
  if (!v.includes("@") || !isValidEmail(v)) return "Enter a valid email (must include @)";
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

/** Keep letters and spaces only (first/last name). */
export function toLettersName(value: string): string {
  return value.replace(/[^A-Za-z ]/g, "");
}

export function isLettersName(value: string): boolean {
  return /^[A-Za-z]+(?: [A-Za-z]+)*$/.test(value.trim());
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
