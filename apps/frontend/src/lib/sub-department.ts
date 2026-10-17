/** Display label: "Leading Delivery Dept." → "Leading Delivery Department". */
export function formatSubDepartmentDisplay(value?: string | null): string {
  const trimmed = (value ?? "").replace(/\s+/g, " ").trim();
  if (!trimmed || trimmed === "—" || trimmed === "-") return trimmed;
  return trimmed.replace(/ Dept\./g, " Department");
}

export function normalizeSubDepartmentKey(value?: string | null): string {
  return formatSubDepartmentDisplay(value).toLowerCase();
}
