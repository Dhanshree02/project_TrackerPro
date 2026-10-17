import type { ApiEmployeeListItem } from "@/lib/api/employees";
import { fetchAllEmployees } from "@/lib/api/employees";
import { apiFetch } from "@/lib/api-client";
import { DEFAULT_ROLE_PERMISSIONS } from "@/lib/rbac";
import type { DemoPersona } from "@/lib/demo-roles";

let cachedPersonas: DemoPersona[] | null = null;
let loadPromise: Promise<DemoPersona[]> | null = null;

/** Super Admin login (full RBAC), not the same as IT Admin profile staff. */
export const SUPER_ADMIN_EMPLOYEE_CODE = "TK-0004";
export const SUPER_ADMIN_EMAIL = "admin@talakunchi.com";

interface UserAccessApiRow {
  employeeCode: string;
  email: string;
  accessRole: string;
}

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

/** Map employee profile to an RBAC role key when User Role Access has no row yet. */
export function mapEmployeeAccessRoleKey(item: ApiEmployeeListItem, accessRoleFromDb?: string): string {
  const fromDb = accessRoleFromDb?.trim();
  if (fromDb) return fromDb;
  if (isSuperAdminEmployee(item)) return "Admin";
  if (isItAdminProfile(item)) return "IT Admin";

  const floor = (item.jobRoleName || item.jobRole || item.role || "").trim();
  const desig = (item.designation || "").toLowerCase();
  if (/intern/i.test(item.employeeCode) || desig.includes("intern")) return "Intern";
  if (floor.includes("HOD") || desig.includes("head of department")) return "Testing HOD";
  if (floor.includes("Sr. Manager") || desig.includes("senior manager")) return "Testing Senior Manager";
  if (floor.includes("Manager") || desig.includes("project manager")) {
    if (desig.includes("engagement")) return "EngagementManager";
    if (desig.includes("sales")) return "Sales Manager";
    if (desig.includes("account")) return "Accounts";
    return "Testing-Manager";
  }
  if (floor.includes("Team Leader") || floor.includes("Leader")) return "Testing-Team Leader";
  if (floor.includes("Team Member")) return "Testing-Team Member";
  if (floor === "HR") return "HR";
  if (floor === "Accounts") return "Accounts";
  if (floor === "Project Manager") return "Testing-Manager";
  if (desig.includes("chief executive") || desig.includes("ceo")) return "CEO";
  if (desig.includes("chief operating") || desig.includes("coo")) return "COO";
  if (desig.includes("chief technology") || desig.includes("cto")) return "CTO";
  return floor || "Testing-Team Member";
}

function permissionsForRoleKey(roleKey: string): string[] {
  return DEFAULT_ROLE_PERMISSIONS[roleKey as keyof typeof DEFAULT_ROLE_PERMISSIONS] ?? [];
}

export function employeeListItemToPersona(
  item: ApiEmployeeListItem,
  accessRoleFromDb?: string,
): DemoPersona {
  const roleKey = mapEmployeeAccessRoleKey(item, accessRoleFromDb);
  const department = (item.department || "Other").trim();
  const designation = (item.designation || roleKey).trim();
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
    roleKey,
    permissions: permissionsForRoleKey(roleKey),
  };
}

export function getCachedEmployeePersonas(): DemoPersona[] {
  return cachedPersonas ?? [];
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

async function loadAccessRoleByCode(): Promise<Map<string, string>> {
  try {
    const rows = await apiFetch<UserAccessApiRow[]>("/api/v1/rbac/user-access");
    const map = new Map<string, string>();
    for (const row of rows ?? []) {
      const role = row.accessRole?.trim();
      if (row.employeeCode && role) map.set(row.employeeCode.trim(), role);
    }
    return map;
  } catch {
    return new Map();
  }
}

export async function loadEmployeePersonas(force = false): Promise<DemoPersona[]> {
  if (!force && cachedPersonas) return cachedPersonas;
  if (!force && loadPromise) return loadPromise;

  loadPromise = Promise.all([fetchAllEmployees(), loadAccessRoleByCode()])
    .then(([items, accessByCode]) => {
      const personas = items
        .map((item) => employeeListItemToPersona(item, accessByCode.get(item.employeeCode.trim())))
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
