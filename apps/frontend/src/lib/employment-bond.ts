export const WORKER_TYPES = ["Permanent", "Contract", "Intern"] as const;

export const BOND_DELIVERED_OPTIONS = ["Yes", "No"] as const;

export type WorkerType = (typeof WORKER_TYPES)[number];
export type BondDelivered = (typeof BOND_DELIVERED_OPTIONS)[number];

function addMonthsToIsoDate(isoDate: string, months: number): string | null {
  const parts = isoDate.split("-").map(Number);
  if (parts.length !== 3 || parts.some((n) => Number.isNaN(n))) return null;
  const [year, month, day] = parts;
  const date = new Date(year, month - 1, day);
  if (Number.isNaN(date.getTime())) return null;
  date.setMonth(date.getMonth() + months);
  const yy = date.getFullYear();
  const mm = String(date.getMonth() + 1).padStart(2, "0");
  const dd = String(date.getDate()).padStart(2, "0");
  return `${yy}-${mm}-${dd}`;
}

function isoDateTodayLocal(): string {
  const now = new Date();
  const yy = now.getFullYear();
  const mm = String(now.getMonth() + 1).padStart(2, "0");
  const dd = String(now.getDate()).padStart(2, "0");
  return `${yy}-${mm}-${dd}`;
}

export function computeBondExpiryDate(
  joiningDate: string,
  bondDelivered: string,
  durationMonths: string,
): string | null {
  if (bondDelivered !== "Yes") return null;
  const months = Number(durationMonths);
  if (!joiningDate || !Number.isInteger(months) || months <= 0) return null;
  return addMonthsToIsoDate(joiningDate, months);
}

export function formatBondExpiryDisplay(
  joiningDate: string,
  bondDelivered: string,
  durationMonths: string,
): string {
  if (bondDelivered !== "Yes") return "No";
  const expiry = computeBondExpiryDate(joiningDate, bondDelivered, durationMonths);
  return expiry ?? "—";
}

export function computeBondStatus(
  bondDelivered: string,
  joiningDate: string,
  durationMonths: string,
): string {
  if (bondDelivered !== "Yes") return "No bond";
  const expiry = computeBondExpiryDate(joiningDate, bondDelivered, durationMonths);
  if (!expiry) return "No bond";
  const today = isoDateTodayLocal();
  return expiry >= today ? "In bond" : "Expired";
}
