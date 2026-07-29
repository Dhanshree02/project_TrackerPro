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
