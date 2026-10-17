/**
 * On Floor Role catalog lives in PostgreSQL `master.mst_roles` (employee FK: `JobRoleId`).
 * Team Dashboard filter: `GET /api/v1/my-team/on-floor-roles`. Onboarding: `GET /api/v1/employees/meta/roles`.
 */
/** Canonical on-floor role names (no parenthetical abbreviations). */
export const ON_FLOOR_LEADER = "Leader";
export const ON_FLOOR_TEAM_MEMBER = "Team Member";
export const ON_FLOOR_TEAM_LEADER = "Team Leader";
export const ON_FLOOR_MANAGER = "Manager";
export const ON_FLOOR_SENIOR_MANAGER = "Sr. Manager";
export const ON_FLOOR_HEAD_OF_DEPARTMENT = "Head Of Department";

/** Removes trailing abbreviation suffixes such as "Leader (L)" → "Leader". */
export function formatOnFloorRoleDisplay(value?: string | null): string {
  const trimmed = (value ?? "").replace(/\s+/g, " ").trim();
  if (!trimmed) return "";
  return trimmed.replace(/\s+\([^)]+\)\s*$/, "").trim();
}

/** Case-insensitive match key for on-floor role names (abbreviations stripped). */
export function normalizeOnFloorRole(value?: string | null): string {
  return formatOnFloorRoleDisplay(value).toLowerCase();
}

export function matchesOnFloorRole(
  emp: { jobRoleName?: string | null },
  roleName: string,
): boolean {
  return normalizeOnFloorRole(emp.jobRoleName) === normalizeOnFloorRole(roleName);
}

/** Distinct display labels for filter dropdowns (master.mst_roles names). */
export function uniqueOnFloorRoleLabels(names: Iterable<string | null | undefined>): string[] {
  const set = new Set<string>();
  for (const raw of names) {
    const label = formatOnFloorRoleDisplay(raw) || (raw ?? "").trim();
    if (label) set.add(label);
  }
  return [...set].sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }));
}
