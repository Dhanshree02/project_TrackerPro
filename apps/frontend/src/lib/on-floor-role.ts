/**
 * On Floor Role rows live in PostgreSQL `resource.tbl_onfloorrole`.
 * Each row stores the designation, department, sub-department, and RBAC role ids.
 * APIs expose `jobRoleId` + `jobRoleName` from that table. RBAC access stays in `tbl_employees."Role"`.
 * Directory and Team Dashboard filters: `GET /api/v1/employees/meta/roles` and `GET /api/v1/my-team/on-floor-roles`.
 */
/** Canonical on-floor role names from docs/rbac.xlsx. */
export const ON_FLOOR_LEADER = "Leader";
export const ON_FLOOR_IT_ADMIN = "IT Admin";
export const ON_FLOOR_ACCOUNTS = "Accounts";
export const ON_FLOOR_HR = "HR";
export const ON_FLOOR_TEAM_MEMBER = "Team Member";
export const ON_FLOOR_TEAM_LEADER = "Team Leader";
export const ON_FLOOR_MANAGER = "Manager";
export const ON_FLOOR_PROJECT_MANAGER = "Project Manager";
export const ON_FLOOR_SENIOR_MANAGER = "Sr. Manager";
export const ON_FLOOR_HEAD_OF_DEPARTMENT = "Head Of Department";

export function isOnFloorProjectManager(emp: { jobRoleName?: string | null }): boolean {
  return matchesOnFloorRole(emp, ON_FLOOR_MANAGER) || matchesOnFloorRole(emp, ON_FLOOR_PROJECT_MANAGER);
}

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
