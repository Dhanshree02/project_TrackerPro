import type { AuthUser } from "@/lib/api-client";

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
  label: string;
  email: string;
  name: string;
  id: string;
  avatar: string;
  permissions: string[];
}

const EMPLOYEE_PERMS = [
  "dashboard.view",
  "action-center.view",
  "projects.view",
  "projects.assigned-projects.view",
  "projects.task.view",
  "projects.task.update-status",
  "resources.view",
  "resources.directory.view",
  "repository.view",
  "my-team.dashboard.view",
  "my-team.my-timesheet.view",
  "my-team.my-timesheet.submit",
  "my-team.my-timesheet.edit",
  "timesheets:submit",
  "issues:raise",
];

const HR_PERMS = [
  "resources.view",
  "resources.directory.view",
  "resources.manage",
  "repository.view",
  "resources:manage",
];

const PM_PERMS = [
  "dashboard.view",
  "action-center.view",
  "projects.view",
  "projects.overview.view",
  "projects.overview.edit",
  "projects.budget.view",
  "projects.team.view",
  "projects.task.view",
  "projects.task.create",
  "projects.task.edit",
  "projects.task.assign",
  "projects.task.update-status",
  "projects.health.view",
  "projects.health.raise-issue",
  "projects.health.edit-issue",
  "projects.health.resolve-issue",
  "projects.health-issues.view",
  "projects.alerts.view",
  "projects.escalation.view",
  "resources.view",
  "resources.directory.view",
  "customers.view",
  "repository.view",
  "my-team.dashboard.view",
  "my-team.timesheet-approval.view",
  "my-team.timesheet-approval.approve",
  "my-team.my-timesheet.view",
  "my-team.my-timesheet.submit",
  "projects:read",
  "projects:write",
  "issues:raise",
  "timesheets:submit",
  "timesheets:approve",
];

const EM_PERMS = [
  ...PM_PERMS,
  "projects.communication.view",
  "projects.communication.create",
];

const PMO_PERMS = [
  "dashboard.view",
  "action-center.view",
  "projects.view",
  "projects.overview.view",
  "projects.invoice-schedule.view",
  "projects.health.view",
  "reports.view",
  "reports.export",
  "resources.view",
  "resources.directory.view",
  "customers.view",
  "repository.view",
  "my-team.dashboard.view",
  "projects:read",
  "clients:read",
  "reports:read",
];

const HOD_PERMS = [
  ...PMO_PERMS,
  "approvals.view",
  "approvals.approve",
  "my-team.timesheet-approval.view",
  "my-team.timesheet-approval.approve",
];

const ACCOUNTS_PERMS = [
  "dashboard.view",
  "projects.view",
  "projects.overview.view",
  "projects.invoice-schedule.view",
  "projects.invoice-schedule.manage",
  "reports.view",
  "reports.finance.view",
  "resources.view",
  "resources.directory.view",
  "customers.view",
  "customers.create",
  "customers.edit",
  "repository.view",
  "clients:read",
  "clients:write",
  "invoices:raise",
  "invoices:payment",
  "reports:read",
];

const SALES_PERMS = [
  "dashboard.view",
  "action-center.view",
  "projects.view",
  "projects.create",
  "projects.overview.view",
  "projects.health.view",
  "reports.view",
  "resources.view",
  "resources.directory.view",
  "customers.view",
  "customers.create",
  "customers.edit",
  "repository.view",
  "clients:write",
  "clients:read",
  "projects:write",
  "projects:read",
];

const ADMIN_PERMS = [
  ...new Set([
    ...EMPLOYEE_PERMS,
    ...HR_PERMS,
    ...PM_PERMS,
    ...EM_PERMS,
    ...PMO_PERMS,
    ...HOD_PERMS,
    ...ACCOUNTS_PERMS,
    ...SALES_PERMS,
    "projects.create",
    "wbs.allocate",
    "wbs.view",
    "portfolio.view",
    "settings.view",
    "customers.approve",
    "users:manage",
    "roles:manage",
  ]),
];

export const DEMO_PERSONAS: DemoPersona[] = [
  {
    key: "Employee",
    label: "Employee",
    email: "arjun@acme.co",
    name: "Arjun Singh",
    id: "u7",
    avatar: "AS",
    permissions: EMPLOYEE_PERMS,
  },
  {
    key: "Hr",
    label: "HR",
    email: "hr@acme.co",
    name: "HR User",
    id: "u16",
    avatar: "HU",
    permissions: HR_PERMS,
  },
  {
    key: "ProjectManager",
    label: "Project Manager",
    email: "vikram@acme.co",
    name: "Vikram Shah",
    id: "u3",
    avatar: "VS",
    permissions: PM_PERMS,
  },
  {
    key: "SeniorPm",
    label: "Senior Project Manager",
    email: "aarav@acme.co",
    name: "Aarav Mehta",
    id: "u1",
    avatar: "AM",
    permissions: PM_PERMS,
  },
  {
    key: "EngagementManager",
    label: "Engagement Manager",
    email: "riya@acme.co",
    name: "Riya Kapoor",
    id: "u2",
    avatar: "RK",
    permissions: EM_PERMS,
  },
  {
    key: "Pmo",
    label: "PMO",
    email: "rahul@acme.co",
    name: "Rahul Gupta",
    id: "u11",
    avatar: "RG",
    permissions: PMO_PERMS,
  },
  {
    key: "Hod",
    label: "HOD",
    email: "anita@acme.co",
    name: "Anita Desai",
    id: "u12",
    avatar: "AD",
    permissions: HOD_PERMS,
  },
  {
    key: "BusinessOwner",
    label: "Business Owner",
    email: "vikrant@acme.co",
    name: "Vikrant Malhotra",
    id: "u13",
    avatar: "VM",
    permissions: PMO_PERMS,
  },
  {
    key: "Accounts",
    label: "Accounts & Finance",
    email: "accounts@acme.co",
    name: "Accounts User",
    id: "u17",
    avatar: "AC",
    permissions: ACCOUNTS_PERMS,
  },
  {
    key: "Sales",
    label: "Sales & BD",
    email: "sales@acme.co",
    name: "Sales User",
    id: "u18",
    avatar: "SU",
    permissions: SALES_PERMS,
  },
  {
    key: "Admin",
    label: "Admin",
    email: "admin@acme.co",
    name: "Admin User",
    id: "u15",
    avatar: "AU",
    permissions: ADMIN_PERMS,
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

export function getDemoPersona(role: DemoRoleKey): DemoPersona {
  return DEMO_PERSONAS.find((p) => p.key === role) ?? DEMO_PERSONAS[0];
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
