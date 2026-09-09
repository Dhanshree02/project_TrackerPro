import type { AuthUser } from "@/lib/api-client";
import type { Role } from "@/lib/mock-data";
import { DEFAULT_ROLE_PERMISSIONS, permissionsForRole } from "@/lib/rbac";

/** Demo personas that can be switched from the topbar without a login page. */
export type DemoRoleKey =
  | "Employee"
  | "Hr"
  | "ProjectManager"
  | "SeniorPm"
  | "EngagementManager"
  | "Pmo"
  | "Hod"
  | "BusinessOwner"
  | "Accounts"
  | "Sales"
  | "Admin";

export const DEMO_ROLE_STORAGE_KEY = "pulse-demo-role";
export const DEMO_PASSWORD = "Password@123";

export interface DemoPersona {
  key: DemoRoleKey;
  role: Role;
  label: string;
  email: string;
  name: string;
  id: string;
  avatar: string;
  permissions: string[];
}

export const DEMO_ROLE_MAP: Record<DemoRoleKey, Role> = {
  Employee: "employee",
  Hr: "hr",
  ProjectManager: "pm",
  SeniorPm: "senior_pm",
  EngagementManager: "engagement_manager",
  Pmo: "pmo",
  Hod: "hod",
  BusinessOwner: "business_owner",
  Accounts: "accounts_finance",
  Sales: "sales_bd",
  Admin: "dhanshree",
};

export const DEMO_PERSONAS: DemoPersona[] = [
  {
    key: "Employee",
    role: "employee",
    label: "Employee",
    email: "arjun@acme.co",
    name: "Arjun Singh",
    id: "u7",
    avatar: "AS",
    permissions: DEFAULT_ROLE_PERMISSIONS.employee,
  },
  {
    key: "Hr",
    role: "hr",
    label: "HR",
    email: "hr@acme.co",
    name: "HR User",
    id: "u16",
    avatar: "HU",
    permissions: DEFAULT_ROLE_PERMISSIONS.hr,
  },
  {
    key: "ProjectManager",
    role: "pm",
    label: "Project Manager",
    email: "vikram@acme.co",
    name: "Vikram Shah",
    id: "u3",
    avatar: "VS",
    permissions: DEFAULT_ROLE_PERMISSIONS.pm,
  },
  {
    key: "SeniorPm",
    role: "senior_pm",
    label: "Senior Project Manager",
    email: "aarav@acme.co",
    name: "Aarav Mehta",
    id: "u1",
    avatar: "AM",
    permissions: DEFAULT_ROLE_PERMISSIONS.senior_pm,
  },
  {
    key: "EngagementManager",
    role: "engagement_manager",
    label: "Engagement Manager",
    email: "riya@acme.co",
    name: "Riya Kapoor",
    id: "u2",
    avatar: "RK",
    permissions: DEFAULT_ROLE_PERMISSIONS.engagement_manager,
  },
  {
    key: "Pmo",
    role: "pmo",
    label: "PMO",
    email: "rahul@acme.co",
    name: "Rahul Gupta",
    id: "u11",
    avatar: "RG",
    permissions: DEFAULT_ROLE_PERMISSIONS.pmo,
  },
  {
    key: "Hod",
    role: "hod",
    label: "HOD",
    email: "anita@acme.co",
    name: "Anita Desai",
    id: "u12",
    avatar: "AD",
    permissions: DEFAULT_ROLE_PERMISSIONS.hod,
  },
  {
    key: "BusinessOwner",
    role: "business_owner",
    label: "Business Owner",
    email: "vikrant@acme.co",
    name: "Vikrant Malhotra",
    id: "u13",
    avatar: "VM",
    permissions: DEFAULT_ROLE_PERMISSIONS.business_owner,
  },
  {
    key: "Accounts",
    role: "accounts_finance",
    label: "Accounts & Finance",
    email: "accounts@acme.co",
    name: "Accounts User",
    id: "u17",
    avatar: "AC",
    permissions: DEFAULT_ROLE_PERMISSIONS.accounts_finance,
  },
  {
    key: "Sales",
    role: "sales_bd",
    label: "Sales & BD",
    email: "sales@acme.co",
    name: "Sales User",
    id: "u18",
    avatar: "SU",
    permissions: DEFAULT_ROLE_PERMISSIONS.sales_bd,
  },
  {
    key: "Admin",
    role: "dhanshree",
    label: "Admin",
    email: "admin@acme.co",
    name: "Admin User",
    id: "u15",
    avatar: "AU",
    permissions: DEFAULT_ROLE_PERMISSIONS.dhanshree,
  },
];

export function isDemoRoleKey(value: string | null | undefined): value is DemoRoleKey {
  return DEMO_PERSONAS.some((p) => p.key === value);
}

export function getStoredDemoRole(): DemoRoleKey {
  if (typeof window === "undefined") return "Employee";
  const stored = window.localStorage.getItem(DEMO_ROLE_STORAGE_KEY);
  return isDemoRoleKey(stored) ? stored : "Employee";
}

export function setStoredDemoRole(role: DemoRoleKey): void {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(DEMO_ROLE_STORAGE_KEY, role);
}

export function getDynamicPermissionsForDemoRole(roleKey: DemoRoleKey): string[] {
  const targetRole = DEMO_ROLE_MAP[roleKey] ?? "employee";
  return permissionsForRole(targetRole);
}

export function getDemoPersona(role: DemoRoleKey): DemoPersona {
  const base = DEMO_PERSONAS.find((p) => p.key === role) ?? DEMO_PERSONAS[0];
  const dynamicPermissions = getDynamicPermissionsForDemoRole(role);
  return {
    ...base,
    permissions: dynamicPermissions,
  };
}

export function mockAuthUser(role: DemoRoleKey): AuthUser {
  const persona = getDemoPersona(role);
  return {
    id: persona.id,
    email: persona.email,
    name: persona.name,
    role: persona.key,
    mustChangePassword: false,
    permissions: persona.permissions,
  };
}
