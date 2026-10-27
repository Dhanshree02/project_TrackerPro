import type { ApiEmployeeListItem } from "@/modules/employees/api/employees";
import { fetchAllEmployees } from "@/modules/employees/api/employees";
import { formatOnFloorRoleDisplay } from "@/lib/on-floor-role";
import { findOrgRoleRow } from "@/lib/org-role-matrix";
import { formatSubDepartmentDisplay } from "@/lib/sub-department";
import type { DemoPersona } from "@/lib/user-personas";

/**
 * Data linkage (PostgreSQL):
 *
 * Department     → master.mst_departments (employee.DepartmentId)
 * Designation    → master.mst_designations (employee.DesignationId); may define default sub-dept
 * Sub-Department → resource.tbl_employees."SubDepartment" (comma-split in UI filters)
 * On Floor Role  → no longer stored. jobRoleName stays empty until roles are rebuilt.
 * RBAC Access    → auth.tbl_users."RoleId" → auth.tbl_roles."Name"
 *                  + profile copy on resource.tbl_employees."Role" (Assigned RBAC Role at onboard)
 *
 * Switch user uses RBAC access for permissions; list shows designation + on-floor + access separately.
 */

let cachedPersonas: DemoPersona[] | null = null;
let loadPromise: Promise<DemoPersona[]> | null = null;

/** Super Admin login (full RBAC), not the same as IT Admin profile staff. */
export const SUPER_ADMIN_EMPLOYEE_CODE = "TK-0004";
export const SUPER_ADMIN_EMAIL = "admin@talakunchi.com";

const initialsOf = (name: string) =>
  name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((w) => w[0]?.toUpperCase())
    .join("") || "?";

export function isSuperAdminEmployee(item: ApiEmployeeListItem): boolean {
  const code = item.employeeCode.trim();
  const email = item.workEmail.trim().toLowerCase();
  return code === SUPER_ADMIN_EMPLOYEE_CODE || email === SUPER_ADMIN_EMAIL;
}

/** IT operations staff — restricted RBAC vs Super Admin. */
export function isItAdminProfile(item: ApiEmployeeListItem): boolean {
  if (isSuperAdminEmployee(item)) return false;
  const floor = (item.jobRoleName || item.jobRole || item.role || "").trim();
  const desig = (item.designation || "").toLowerCase();
  const dept = (item.department || "").toLowerCase();
  if (floor === "IT Admin" || desig === "it admin") return true;
  return dept.includes("it administration") && (desig.includes("it admin") || desig.includes("desktop support"));
}

/** Assigned RBAC role stored on the employee row at onboarding (not on-floor title). */
export function profileAssignedAccessRole(item: ApiEmployeeListItem): string | undefined {
  const raw = (item.role || "").trim();
  if (!raw) return undefined;
  const floorish = formatOnFloorRoleDisplay(raw).toLowerCase();
  const onFloorOnly = new Set([
    "leader",
    "team member",
    "team leader",
    "manager",
    "sr. manager",
    "head of department",
    "it admin",
    "accounts",
    "hr",
    "project manager",
  ]);
  if (onFloorOnly.has(floorish)) return undefined;
  return raw;
}

/** On-floor role label only — never use tbl_employees.Role (RBAC text). */
export function resolveOnFloorRoleLabel(item: ApiEmployeeListItem): string {
  const label = formatOnFloorRoleDisplay(item.jobRoleName || item.jobRole || "");
  return label || "—";
}

/**
 * RBAC access role for permissions (User Role Access → else profile Assigned RBAC → else heuristic).
 */
export function mapEmployeeAccessRoleKey(item: ApiEmployeeListItem, accessRoleFromDb?: string): string {
  const fromLogin = accessRoleFromDb?.trim();
  if (fromLogin) return fromLogin;

  const rawRole = (item.role || "").trim();
  if (rawRole) return rawRole;

  if (isSuperAdminEmployee(item)) return "Admin";

  const mapped = findOrgRoleRow(item.department, item.designation);
  if (mapped) return mapped.rbacRole;

  if (isItAdminProfile(item)) return "IT Admin";

  const floor = formatOnFloorRoleDisplay(item.jobRoleName || item.jobRole || "").toLowerCase();
  const desig = (item.designation || "").toLowerCase();
  const dept = (item.department || "").toLowerCase();

  if (/intern/i.test(item.employeeCode) || desig.includes("intern")) return "Intern";
  if (desig.includes("chief executive") || desig.includes("ceo")) return "CEO";
  if (desig.includes("chief operating") || desig.includes("coo")) return "COO";
  if (desig.includes("chief technology") || desig.includes("cto")) return "CTO";
  if (desig.includes("engagement manager")) return "EngagementManager";
  if (desig.includes("sales")) return desig.includes("manager") ? "Sales Manager" : "Sales team member";
  if (desig.includes("account")) return "Accounts";
  if (floor.includes("head of department") || desig.includes("head of department")) return "Testing HOD";
  if (floor.includes("sr. manager") || desig.includes("senior manager")) return "Testing Senior Manager";
  if (floor.includes("manager") || desig.includes("project manager")) return "Testing-Manager";
  if (floor.includes("team leader") || floor === "leader") return "Testing-Team Leader";
  if (floor.includes("team member")) {
    if (dept.includes("consulting")) return "Consulting-Team member";
    if (dept.includes("soc")) return "SOC-Team Member";
    if (dept.includes("r&d") || dept.includes("research")) return "R&D - Team member";
    return "Testing-Team Member";
  }
  if (floor === "hr" || desig.includes("human resource")) return "HR";
  return "Testing-Team Member";
}

function permissionsForRoleKey(_roleKey: string): string[] {
  return [];
}

export function employeeListItemToPersona(
  item: ApiEmployeeListItem,
  accessRoleFromDb?: string,
): DemoPersona {
  const accessRole = mapEmployeeAccessRoleKey(item, accessRoleFromDb);
  const department = (item.department || "Other").trim();
  const designation = (item.designation || "—").trim();
  const subDepartment = formatSubDepartmentDisplay(item.subDepartment) || undefined;
  const onFloorRole = resolveOnFloorRoleLabel(item);
  const code = item.employeeCode.trim();
  return {
    key: code,
    code,
    label: designation,
    category: department,
    email: item.workEmail.trim(),
    name: item.fullName.trim(),
    id: item.id,
    avatar: initialsOf(item.fullName),
    department,
    designation,
    subDepartment,
    onFloorRole,
    accessRole,
    roleKey: accessRole,
    permissions: permissionsForRoleKey(accessRole),
  };
}

export function getCachedEmployeePersonas(): DemoPersona[] {
  return cachedPersonas ?? [];
}

/** Primary line under name in Switch User (org structure, not RBAC). */
export function personaOrgSubtitle(persona: DemoPersona): string {
  const parts: string[] = [];
  if (persona.designation && persona.designation !== "—") parts.push(persona.designation);
  if (persona.onFloorRole && persona.onFloorRole !== "—") parts.push(persona.onFloorRole);
  if (persona.subDepartment) parts.push(persona.subDepartment);
  return parts.length > 0 ? parts.join(" · ") : persona.label;
}

export function findEmployeePersona(roleOrKey: string): DemoPersona | undefined {
  const normalized = (roleOrKey || "").trim().toLowerCase();
  if (!normalized) return undefined;
  return getCachedEmployeePersonas().find(
    (p) =>
      p.key.toLowerCase() === normalized ||
      p.code.toLowerCase() === normalized ||
      p.email.toLowerCase() === normalized ||
      p.id.toLowerCase() === normalized,
  );
}

export function isEmployeePersonaKey(value: string | null | undefined): boolean {
  if (!value) return false;
  const normalized = value.trim().toLowerCase();
  if (findEmployeePersona(normalized)) return true;
  if (/^tk-\d{4}$/i.test(value.trim())) {
    return getCachedEmployeePersonas().some((p) => p.code.toLowerCase() === normalized);
  }
  return false;
}

export async function loadEmployeePersonas(force = false): Promise<DemoPersona[]> {
  if (!force && cachedPersonas) return cachedPersonas;
  if (!force && loadPromise) return loadPromise;

  loadPromise = fetchAllEmployees()
    .then((items) => {
      const personas = items
        .map((item) => employeeListItemToPersona(item))
        .sort((a, b) => a.code.localeCompare(b.code, undefined, { numeric: true }));
      cachedPersonas = personas;
      return personas;
    })
    .catch(() => cachedPersonas ?? [])
    .finally(() => {
      loadPromise = null;
    });

  return loadPromise;
}
