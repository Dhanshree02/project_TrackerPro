/** Canonical map from docs/rbac.xlsx. Keys stay the existing auth.tbl_roles names. */

export const ON_FLOOR_ROLES = [
  "Leader",
  "IT Admin",
  "Accounts",
  "HR",
  "Manager",
  "Team Member",
  "Team Leader",
  "Project Manager",
  "Sr. Manager",
  "Head Of Department",
] as const;

export type OnFloorRole = (typeof ON_FLOOR_ROLES)[number];

export interface OrgRoleRow {
  department: string;
  designation: string;
  subDepartment: string;
  onFloorRole: OnFloorRole;
  rbacRole: string;
}

const TESTING_CORE =
  "Service - Testing - AppSec, Service - Testing - Mobile, Service - Testing - Infra";

const ROWS: OrgRoleRow[] = [
  { department: "Core", designation: "Director and Chief Executive Officer", subDepartment: "Leading Sales & A/C Department", onFloorRole: "Leader", rbacRole: "CEO" },
  { department: "Core", designation: "Director and Chief Operating Officer", subDepartment: "Leading Delivery Department", onFloorRole: "Leader", rbacRole: "COO" },
  { department: "Core", designation: "Director and Chief Technology Officer", subDepartment: "Leading Compliance & HR Department", onFloorRole: "Leader", rbacRole: "CTO" },
  { department: "Functional - IT Administration", designation: "IT Admin", subDepartment: "Functional - IT Administration", onFloorRole: "IT Admin", rbacRole: "IT Admin" },
  { department: "Functional - IT Administration", designation: "Desktop Support Engineer - I", subDepartment: "Functional - IT Administration", onFloorRole: "IT Admin", rbacRole: "IT Admin" },
  { department: "Functional - IT Administration", designation: "Desktop Support Engineer - II", subDepartment: "Functional - IT Administration", onFloorRole: "IT Admin", rbacRole: "IT Admin" },
  { department: "Functional - Accounts", designation: "Accountant - I", subDepartment: "Functional - Accounts", onFloorRole: "Accounts", rbacRole: "Accounts" },
  { department: "Functional - Accounts", designation: "Accountant - II", subDepartment: "Functional - Accounts", onFloorRole: "Accounts", rbacRole: "Accounts" },
  { department: "Functional - Accounts", designation: "Accountant - III", subDepartment: "Functional - Accounts", onFloorRole: "Accounts", rbacRole: "Accounts" },
  { department: "Functional - Accounts", designation: "Senior Accountant - I", subDepartment: "Functional - Accounts", onFloorRole: "Accounts", rbacRole: "Accounts" },
  { department: "Functional - Accounts", designation: "Senior Accountant - II", subDepartment: "Functional - Accounts", onFloorRole: "Accounts", rbacRole: "Accounts" },
  { department: "Functional - Accounts", designation: "Senior Accountant - III", subDepartment: "Functional - Accounts", onFloorRole: "Accounts", rbacRole: "Accounts" },
  { department: "Functional - HR", designation: "HR Head", subDepartment: "Functional - HR", onFloorRole: "HR", rbacRole: "HR" },
  { department: "Functional - HR", designation: "Recruitment Coordinator - I", subDepartment: "Functional - HR", onFloorRole: "HR", rbacRole: "HR" },
  { department: "Functional - HR", designation: "Recruitment Coordinator - II", subDepartment: "Functional - HR", onFloorRole: "HR", rbacRole: "HR" },
  { department: "Functional - HR", designation: "Senior HR Executive - I", subDepartment: "Functional - HR", onFloorRole: "HR", rbacRole: "HR" },
  { department: "Functional - HR", designation: "Senior HR Executive - II", subDepartment: "Functional - HR", onFloorRole: "HR", rbacRole: "HR" },
  { department: "Functional - Sales", designation: "Business Development Associate - I", subDepartment: "Functional - Sales", onFloorRole: "Manager", rbacRole: "Sales Manager" },
  { department: "Functional - Sales", designation: "Customer Success Representative - II", subDepartment: "Functional - Sales", onFloorRole: "Manager", rbacRole: "Sales Manager" },
  { department: "Functional - Sales", designation: "Director - Product Sales", subDepartment: "Functional - Sales", onFloorRole: "Team Member", rbacRole: "Sales team member" },
  { department: "Functional - Sales", designation: "Sales Associate", subDepartment: "Functional - Sales", onFloorRole: "Team Member", rbacRole: "Sales team member" },
  { department: "Functional - Sales", designation: "Associate Customer Success Representative - I", subDepartment: "Functional - Sales", onFloorRole: "Team Member", rbacRole: "Sales team member" },
  { department: "Functional - Sales", designation: "Associate Customer Success Representative - II", subDepartment: "Functional - Sales", onFloorRole: "Team Member", rbacRole: "Sales team member" },
  { department: "Functional - Project Management", designation: "Associate PMO - I", subDepartment: "PMO (Project Management Office)", onFloorRole: "Team Member", rbacRole: "PMO" },
  { department: "Functional - Project Management", designation: "Associate PMO - II", subDepartment: "PMO (Project Management Office)", onFloorRole: "Team Member", rbacRole: "PMO" },
  { department: "Functional - Project Management", designation: "Senior PMO - I", subDepartment: "PMO (Project Management Office)", onFloorRole: "Team Leader", rbacRole: "PMO" },
  { department: "Functional - Project Management", designation: "Senior PMO - II", subDepartment: "PMO (Project Management Office)", onFloorRole: "Manager", rbacRole: "PMO" },
  { department: "Functional - Project Management", designation: "Delivery Account Manager - I", subDepartment: "EM (Engagement Manager)", onFloorRole: "Team Member", rbacRole: "EngagementManager" },
  { department: "Functional - Project Management", designation: "Delivery Account Manager - II", subDepartment: "EM (Engagement Manager)", onFloorRole: "Team Member", rbacRole: "EngagementManager" },
  { department: "Functional - Project Management", designation: "Senior Delivery Account Manager - I", subDepartment: "EM (Engagement Manager)", onFloorRole: "Team Leader", rbacRole: "EngagementManager" },
  { department: "Functional - Project Management", designation: "Senior Delivery Account Manager - II", subDepartment: "EM (Engagement Manager)", onFloorRole: "Manager", rbacRole: "EngagementManager" },
  { department: "R&D (Research & Development)", designation: "Python Developer - I", subDepartment: "R&D (Research & Development)", onFloorRole: "Team Member", rbacRole: "R&D - Team member" },
  { department: "R&D (Research & Development)", designation: "Python Developer - II", subDepartment: "R&D (Research & Development)", onFloorRole: "Team Member", rbacRole: "R&D - Team member" },
  { department: "R&D (Research & Development)", designation: "Python Developer - III", subDepartment: "R&D (Research & Development)", onFloorRole: "Team Member", rbacRole: "R&D - Team member" },
  { department: "Services - Operations", designation: "SOC Analyst - I", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SOC Analyst - II", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SOC Analyst - III", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SOC Analyst - IV", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SIEM Admin - I", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SIEM Admin - II", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SIEM Admin - III", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SIEM Admin - IV", subDepartment: "Services - Operations", onFloorRole: "Team Leader", rbacRole: "SOC-Team Leader" },
  { department: "Services - Operations", designation: "SOC Consultant - I", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SOC Consultant - II", subDepartment: "Services - Operations", onFloorRole: "Team Member", rbacRole: "SOC-Team Member" },
  { department: "Services - Operations", designation: "SOC Shift Lead - I", subDepartment: "Services - Operations", onFloorRole: "Team Leader", rbacRole: "SOC-Team Leader" },
  { department: "Services - Operations", designation: "SOC Shift Lead - II", subDepartment: "Services - Operations", onFloorRole: "Team Leader", rbacRole: "SOC-Team Leader" },
  { department: "Services - Operations", designation: "SOC Lead - I", subDepartment: "Services - Operations", onFloorRole: "Project Manager", rbacRole: "SOC-Manager" },
  { department: "Services - Operations", designation: "SOC Lead - II", subDepartment: "Services - Operations", onFloorRole: "Sr. Manager", rbacRole: "SOC-Senior Manager" },
  { department: "Services - Operations", designation: "Principal Manager - I", subDepartment: "Services - Operations", onFloorRole: "Head Of Department", rbacRole: "SOC-HOD" },
  { department: "Services - Consulting", designation: "GRC Auditor - I", subDepartment: "Services - Consulting", onFloorRole: "Team Member", rbacRole: "Consulting-Team member" },
  { department: "Services - Consulting", designation: "GRC Auditor - II", subDepartment: "Services - Consulting", onFloorRole: "Team Member", rbacRole: "Consulting-Team member" },
  { department: "Services - Consulting", designation: "GRC Auditor - III", subDepartment: "Services - Consulting", onFloorRole: "Team Member", rbacRole: "Consulting-Team member" },
  { department: "Services - Consulting", designation: "GRC Auditor - IV", subDepartment: "Services - Consulting", onFloorRole: "Team Member", rbacRole: "Consulting-Team member" },
  { department: "Services - Consulting", designation: "Senior GRC Auditor - I", subDepartment: "Services - Consulting", onFloorRole: "Team Leader", rbacRole: "Consulting-Team Leader" },
  { department: "Services - Consulting", designation: "Senior GRC Auditor - II", subDepartment: "Services - Consulting", onFloorRole: "Team Leader", rbacRole: "Consulting-Team Leader" },
  { department: "Services - Consulting", designation: "Associate Manager - III", subDepartment: "Services - Consulting", onFloorRole: "Manager", rbacRole: "Consulting-Manager" },
  { department: "Services - Consulting", designation: "Senior Vice President - Principal Consultant", subDepartment: "Services - Consulting", onFloorRole: "Head Of Department", rbacRole: "Consulting-HOD" },
  { department: "Services - Testing", designation: "PenTester - I", subDepartment: TESTING_CORE, onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "PenTester - II", subDepartment: TESTING_CORE, onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "PenTester - III", subDepartment: TESTING_CORE, onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "PenTester - IV", subDepartment: TESTING_CORE, onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "Senior Pentester - I", subDepartment: TESTING_CORE, onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "Senior Pentester - II", subDepartment: TESTING_CORE, onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "Associate Manager - I", subDepartment: TESTING_CORE, onFloorRole: "Team Leader", rbacRole: "Testing-Team Leader" },
  { department: "Services - Testing", designation: "Associate Manager - II", subDepartment: TESTING_CORE, onFloorRole: "Team Leader", rbacRole: "Testing-Team Leader" },
  { department: "Services - Testing", designation: "Associate Manager - III", subDepartment: TESTING_CORE, onFloorRole: "Team Leader", rbacRole: "Testing-Team Leader" },
  { department: "Services - Testing", designation: "Associate Project Manager", subDepartment: TESTING_CORE, onFloorRole: "Manager", rbacRole: "Testing-Manager" },
  { department: "Services - Testing", designation: "Manager - I", subDepartment: TESTING_CORE, onFloorRole: "Sr. Manager", rbacRole: "Testing Senior Manager" },
  { department: "Services - Testing", designation: "DevSecOps Practitioner - I", subDepartment: "Services - Testing - DevSecOps", onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "DevSecOps Practitioner - II", subDepartment: "Services - Testing - DevSecOps", onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "DevSecOps Practitioner - III", subDepartment: "Services - Testing - DevSecOps", onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "DevSecOps Associate", subDepartment: "Services - Testing - DevSecOps", onFloorRole: "Team Leader", rbacRole: "Testing-Team Leader" },
  { department: "Services - Testing", designation: "DevSecOps Specialist - II", subDepartment: "Services - Testing - DevSecOps", onFloorRole: "Manager", rbacRole: "Testing-Manager" },
  { department: "Services - Testing", designation: "Red Team Practitioner - II", subDepartment: "Services - Testing - Red Team", onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "Red Team Practitioner - III", subDepartment: "Services - Testing - Red Team", onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Services - Testing", designation: "Red Team Specialist - II", subDepartment: "Services - Testing - Red Team", onFloorRole: "Manager", rbacRole: "Testing-Manager" },
  { department: "Services - Testing", designation: "Senior Cloud Security Consultant - I", subDepartment: "Services - Testing - Cloud & AI", onFloorRole: "Manager", rbacRole: "Testing-Manager" },
  { department: "Services - Testing", designation: "Associate AI Engineer - Contractual", subDepartment: "Services - Testing - Cloud & AI", onFloorRole: "Team Member", rbacRole: "Testing-Team Member" },
  { department: "Internship Program", designation: "Intern", subDepartment: "Across all Sub Departments", onFloorRole: "Team Member", rbacRole: "Intern" },
];

function norm(value?: string | null): string {
  return (value ?? "").replace(/\u00a0/g, " ").replace(/\s+/g, " ").trim().toLowerCase();
}

const BY_KEY = new Map(ROWS.map((row) => [`${norm(row.department)}|${norm(row.designation)}`, row]));

export function findOrgRoleRow(department?: string | null, designation?: string | null): OrgRoleRow | undefined {
  if (norm(designation) === "intern") {
    return {
      department: department?.trim() || "Internship Program",
      designation: "Intern",
      subDepartment: "Across all Sub Departments",
      onFloorRole: "Team Member",
      rbacRole: "Intern",
    };
  }
  if (!department || !designation) return undefined;
  return BY_KEY.get(`${norm(department)}|${norm(designation)}`);
}

export function rbacKeyFromExcel(value?: string | null): string {
  const raw = (value ?? "").trim();
  if (!raw) return "";
  const aliases: Record<string, string> = {
    "sales team member": "Sales team member",
    "pmo (project management office)": "PMO",
    "em (engagement manager)": "EngagementManager",
    "r&d -team member": "R&D - Team member",
    "soc- team member": "SOC-Team Member",
    "soc- team leader": "SOC-Team Leader",
    "soc- manager": "SOC-Manager",
    "soc- senior manager": "SOC-Senior Manager",
    "soc- hod": "SOC-HOD",
    "consulting -team member": "Consulting-Team member",
    "consulting -team leader": "Consulting-Team Leader",
    "testing- senior manager": "Testing Senior Manager",
  };
  return aliases[norm(raw)] ?? raw;
}
