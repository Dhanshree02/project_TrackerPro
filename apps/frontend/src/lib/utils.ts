import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Robust date formatter supporting Date, ISO strings, and fallback display.
 */
export function formatDate(dateStr?: string | Date | null, fallback = "—"): string {
  if (!dateStr) return fallback;
  const d = typeof dateStr === "string" ? new Date(dateStr) : dateStr;
  if (isNaN(d.getTime())) return fallback;
  return d.toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" });
}

/**
 * Robust date formatter returning strict DD-MM-YYYY format (e.g. 15-05-2026).
 */
export function formatDateDMY(value?: string | Date | null, fallback = "—"): string {
  if (!value) return fallback;
  if (typeof value === "string") {
    const trimmed = value.trim();
    if (!trimmed || trimmed === "—" || trimmed === "NA" || trimmed === "null" || trimmed === "undefined") {
      return fallback;
    }
    // Match YYYY-MM-DD or YYYY-MM-DDT...
    const isoMatch = trimmed.match(/^(\d{4})-(\d{2})-(\d{2})/);
    if (isoMatch) {
      return `${isoMatch[3]}-${isoMatch[2]}-${isoMatch[1]}`;
    }
    // Match already DD-MM-YYYY
    const dmyMatch = trimmed.match(/^(\d{2})-(\d{2})-(\d{4})/);
    if (dmyMatch) {
      return trimmed;
    }
  }
  const d = typeof value === "string" ? new Date(value) : value;
  if (Number.isNaN(d.getTime())) return typeof value === "string" ? value : fallback;
  const dd = String(d.getDate()).padStart(2, "0");
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const yyyy = d.getFullYear();
  return `${dd}-${mm}-${yyyy}`;
}


/**
 * Currency formatter helper.
 */
export function formatCurrency(amount: number, currency = "INR"): string {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency,
    maximumFractionDigits: 0,
  }).format(amount);
}

/**
 * Format ID string helpers (CL-XXXXXX, PR-XXXXXX).
 */
export const fmtClientId = (id: string) => `CL-${id.replace(/\D/g, "").padStart(6, "0")}`;
export const fmtProjectId = (id: string) => `PR-${id.replace(/\D/g, "").padStart(6, "0")}`;
