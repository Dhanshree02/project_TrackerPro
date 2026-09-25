import type { AuthUser } from "@/lib/api-client";
import { DEFAULT_ROLE_PERMISSIONS } from "@/lib/rbac";

/**
 * 27 discrete system roles derived from the RBAC Master Catalog & Integration Guide.
 * Older legacy roles have been completely removed.
 */
export type DemoRoleKey =
  | "Admin"
  | "CEO"
  | "COO"
  | "CTO"
  | "IT Admin"
  | "Accounts"
  | "HR"
  | "Sales Manager"
  | "Sales team member"
  | "PMO"
  | "EngagementManager"
  | "Intern"
  | "Testing HOD"
  | "Testing Senior Manager"
  | "Testing-Manager"
  | "Testing-Team Leader"
  | "Testing-Team Member"
  | "Consulting-HOD"
  | "Consulting-Senior Manager"
  | "Consulting-Manager"
  | "Consulting-Team Leader"
  | "Consulting-Team member"
  | "SOC-HOD"
  | "SOC-Senior Manager"
  | "SOC-Manager"
  | "SOC-Team Leader"
  | "SOC-Team Member"
  | "R&D - Team member";

export const DEMO_ROLE_STORAGE_KEY = "pulse-demo-role";
export const DEMO_PASSWORD = "Password@123";

export interface DemoPersona {
  key: DemoRoleKey;
  label: string;
  category: string;
  email: string;
  name: string;
  id: string;
  avatar: string;
  permissions: string[];
}

export const DEMO_PERSONAS: DemoPersona[] = [
  // ── Executive Leadership & Administration ──
  {
    key: "Admin",
    label: "Admin",
    category: "Executive Leadership",
    email: "admin@acme.co",
    name: "Admin User",
    id: "u15",
    avatar: "AU",
    permissions: DEFAULT_ROLE_PERMISSIONS["Admin"] ?? DEFAULT_ROLE_PERMISSIONS["CEO"] ?? [],
  },
  {
    key: "CEO",
    label: "CEO",
    category: "Executive Leadership",
    email: "vikrant@acme.co",
    name: "Vikrant Malhotra",
    id: "u13",
    avatar: "VM",
    permissions: DEFAULT_ROLE_PERMISSIONS["CEO"] ?? [],
  },
  {
    key: "COO",
    label: "COO",
    category: "Executive Leadership",
    email: "dhanshree@acme.co",
    name: "Dhanshree Pansare",
    id: "u14",
    avatar: "DP",
    permissions: DEFAULT_ROLE_PERMISSIONS["COO"] ?? [],
  },
  {
    key: "CTO",
    label: "CTO",
    category: "Executive Leadership",
    email: "kunal.deshmukh@acme.co",
    name: "Kunal Deshmukh",
    id: "u19",
    avatar: "KD",
    permissions: DEFAULT_ROLE_PERMISSIONS["CTO"] ?? [],
  },

  // ── Functional Support ──
  {
    key: "IT Admin",
    label: "IT Admin",
    category: "Functional Support",
    email: "itadmin@acme.co",
    name: "IT Admin User",
    id: "u32",
    avatar: "IT",
    permissions: DEFAULT_ROLE_PERMISSIONS["IT Admin"] ?? [],
  },
  {
    key: "Accounts",
    label: "Accounts & Finance",
    category: "Functional Support",
    email: "accounts@acme.co",
    name: "Accounts User",
    id: "u17",
    avatar: "AC",
    permissions: DEFAULT_ROLE_PERMISSIONS["Accounts"] ?? [],
  },
  {
    key: "HR",
    label: "Human Resources",
    category: "Functional Support",
    email: "hr@acme.co",
    name: "HR User",
    id: "u16",
    avatar: "HU",
    permissions: DEFAULT_ROLE_PERMISSIONS["HR"] ?? [],
  },

  // ── Sales & Marketing ──
  {
    key: "Sales Manager",
    label: "Sales Manager",
    category: "Sales & Marketing",
    email: "sales@acme.co",
    name: "Sales User",
    id: "u18",
    avatar: "SU",
    permissions: DEFAULT_ROLE_PERMISSIONS["Sales Manager"] ?? [],
  },
  {
    key: "Sales team member",
    label: "Sales Team Member",
    category: "Sales & Marketing",
    email: "pooja.sharma@acme.co",
    name: "Pooja Sharma",
    id: "u20",
    avatar: "PS",
    permissions: DEFAULT_ROLE_PERMISSIONS["Sales team member"] ?? [],
  },

  // ── Project Governance ──
  {
    key: "PMO",
    label: "PMO",
    category: "Project Governance",
    email: "rahul@acme.co",
    name: "Rahul Gupta",
    id: "u11",
    avatar: "RG",
    permissions: DEFAULT_ROLE_PERMISSIONS["PMO"] ?? [],
  },
  {
    key: "EngagementManager",
    label: "Engagement Manager",
    category: "Project Governance",
    email: "riya@acme.co",
    name: "Riya Kapoor",
    id: "u2",
    avatar: "RK",
    permissions: DEFAULT_ROLE_PERMISSIONS["EngagementManager"] ?? [],
  },

  // ── Delivery - Testing / QA ──
  {
    key: "Testing HOD",
    label: "Testing HOD",
    category: "Delivery - Testing / QA",
    email: "girish.shenoy@acme.co",
    name: "Girish Shenoy",
    id: "u22",
    avatar: "GS",
    permissions: DEFAULT_ROLE_PERMISSIONS["Testing HOD"] ?? [],
  },
  {
    key: "Testing Senior Manager",
    label: "Testing Senior Manager",
    category: "Delivery - Testing / QA",
    email: "suresh.pillai@acme.co",
    name: "Suresh Pillai",
    id: "u23",
    avatar: "SP",
    permissions: DEFAULT_ROLE_PERMISSIONS["Testing Senior Manager"] ?? [],
  },
  {
    key: "Testing-Manager",
    label: "Testing Manager",
    category: "Delivery - Testing / QA",
    email: "manoj.bhatt@acme.co",
    name: "Manoj Bhatt",
    id: "u24",
    avatar: "MB",
    permissions: DEFAULT_ROLE_PERMISSIONS["Testing-Manager"] ?? [],
  },
  {
    key: "Testing-Team Leader",
    label: "Testing Team Leader",
    category: "Delivery - Testing / QA",
    email: "kiran.mathur@acme.co",
    name: "Kiran Mathur",
    id: "u25",
    avatar: "KM",
    permissions: DEFAULT_ROLE_PERMISSIONS["Testing-Team Leader"] ?? [],
  },
  {
    key: "Testing-Team Member",
    label: "Testing Team Member",
    category: "Delivery - Testing / QA",
    email: "arjun@acme.co",
    name: "Arjun Singh",
    id: "u7",
    avatar: "AS",
    permissions: DEFAULT_ROLE_PERMISSIONS["Testing-Team Member"] ?? [],
  },

  // ── Delivery - Consulting & GRC ──
  {
    key: "Consulting-HOD",
    label: "Consulting HOD",
    category: "Delivery - Consulting & GRC",
    email: "anita@acme.co",
    name: "Anita Desai",
    id: "u12",
    avatar: "AD",
    permissions: DEFAULT_ROLE_PERMISSIONS["Consulting-HOD"] ?? [],
  },
  {
    key: "Consulting-Senior Manager",
    label: "Consulting Senior Manager",
    category: "Delivery - Consulting & GRC",
    email: "aarav@acme.co",
    name: "Aarav Mehta",
    id: "u1",
    avatar: "AM",
    permissions: DEFAULT_ROLE_PERMISSIONS["Consulting-Senior Manager"] ?? [],
  },
  {
    key: "Consulting-Manager",
    label: "Consulting Manager",
    category: "Delivery - Consulting & GRC",
    email: "sana@acme.co",
    name: "Sana Iyer",
    id: "u4",
    avatar: "SI",
    permissions: DEFAULT_ROLE_PERMISSIONS["Consulting-Manager"] ?? [],
  },
  {
    key: "Consulting-Team Leader",
    label: "Consulting Team Leader",
    category: "Delivery - Consulting & GRC",
    email: "priya@acme.co",
    name: "Priya Verma",
    id: "u6",
    avatar: "PV",
    permissions: DEFAULT_ROLE_PERMISSIONS["Consulting-Team Leader"] ?? [],
  },
  {
    key: "Consulting-Team member",
    label: "Consulting Team Member",
    category: "Delivery - Consulting & GRC",
    email: "swati.mishra@acme.co",
    name: "Swati Mishra",
    id: "u26",
    avatar: "SM",
    permissions: DEFAULT_ROLE_PERMISSIONS["Consulting-Team member"] ?? [],
  },

  // ── Delivery - SOC & Operations ──
  {
    key: "SOC-HOD",
    label: "SOC HOD",
    category: "Delivery - SOC & Operations",
    email: "rajesh.kadam@acme.co",
    name: "Rajesh Kadam",
    id: "u27",
    avatar: "RK",
    permissions: DEFAULT_ROLE_PERMISSIONS["SOC-HOD"] ?? [],
  },
  {
    key: "SOC-Senior Manager",
    label: "SOC Senior Manager",
    category: "Delivery - SOC & Operations",
    email: "deepak.sawant@acme.co",
    name: "Deepak Sawant",
    id: "u28",
    avatar: "DS",
    permissions: DEFAULT_ROLE_PERMISSIONS["SOC-Senior Manager"] ?? [],
  },
  {
    key: "SOC-Manager",
    label: "SOC Manager",
    category: "Delivery - SOC & Operations",
    email: "vikram@acme.co",
    name: "Vikram Shah",
    id: "u3",
    avatar: "VS",
    permissions: DEFAULT_ROLE_PERMISSIONS["SOC-Manager"] ?? [],
  },
  {
    key: "SOC-Team Leader",
    label: "SOC Team Leader",
    category: "Delivery - SOC & Operations",
    email: "amit.pandey@acme.co",
    name: "Amit Pandey",
    id: "u29",
    avatar: "AP",
    permissions: DEFAULT_ROLE_PERMISSIONS["SOC-Team Leader"] ?? [],
  },
  {
    key: "SOC-Team Member",
    label: "SOC Team Member",
    category: "Delivery - SOC & Operations",
    email: "pooja.nair@acme.co",
    name: "Pooja Nair",
    id: "u30",
    avatar: "PN",
    permissions: DEFAULT_ROLE_PERMISSIONS["SOC-Team Member"] ?? [],
  },

  // ── Research & Development ──
  {
    key: "R&D - Team member",
    label: "R&D Team Member",
    category: "Research & Development",
    email: "kavya.desai@acme.co",
    name: "Kavya Desai",
    id: "u31",
    avatar: "KD",
    permissions: DEFAULT_ROLE_PERMISSIONS["R&D - Team member"] ?? [],
  },

  // ── Internship Program ──
  {
    key: "Intern",
    label: "Intern",
    category: "Internship Program",
    email: "ananya.verma@acme.co",
    name: "Ananya Verma",
    id: "u21",
    avatar: "AV",
    permissions: DEFAULT_ROLE_PERMISSIONS["Intern"] ?? [],
  },
];

export function isDemoRoleKey(value: string | null | undefined): value is DemoRoleKey {
  return DEMO_PERSONAS.some((p) => p.key === value);
}

export function getStoredDemoRole(): DemoRoleKey {
  if (typeof window === "undefined") return "CEO";
  const stored = window.localStorage.getItem(DEMO_ROLE_STORAGE_KEY);
  return isDemoRoleKey(stored) ? stored : "CEO";
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
