import { execSync } from "child_process";
import crypto from "crypto";
import fs from "fs";

const departments = [
  {
    name: "Core",
    code: "core",
    designations: [
      "Director and Chief Executive Officer",
      "Director and Chief Operating Officer",
      "Director and Chief Technology Officer",
    ],
  },
  {
    name: "Functional - IT Administration",
    code: "functional_it_administration",
    designations: [
      "IT Admin",
      "Desktop Support Engineer - I",
      "Desktop Support Engineer - II",
      "Intern",
    ],
  },
  {
    name: "Functional - Accounts",
    code: "functional_accounts",
    designations: [
      "Accountant - I",
      "Accountant - II",
      "Accountant - III",
      "Senior Accountant - I",
      "Senior Accountant - II",
      "Senior Accountant - III",
      "Intern",
    ],
  },
  {
    name: "Functional - HR",
    code: "functional_hr",
    designations: [
      "HR Head",
      "Recruitment Coordinator - I",
      "Recruitment Coordinator - II",
      "Senior HR Executive - I",
      "Senior HR Executive - II",
      "Intern",
    ],
  },
  {
    name: "Functional - Sales",
    code: "functional_sales",
    designations: [
      "Business Development Associate - I",
      "Customer Success Representative - II",
      "Director - Product Sales",
      "Sales Associate",
      "Associate Customer Success Representative - I",
      "Associate Customer Success Representative - II",
      "Intern",
    ],
  },
  {
    name: "Functional - Project Management",
    code: "functional_project_management",
    designations: [
      "Associate PMO - I",
      "Associate PMO - II",
      "Senior PMO - I",
      "Senior PMO - II",
      "Delivery Account Manager - I",
      "Delivery Account Manager - II",
      "Senior Delivery Account Manager - I",
      "Senior Delivery Account Manager - II",
      "Intern",
    ],
  },
  {
    name: "R&D (Research & Development)",
    code: "rd_research_and_development",
    designations: [
      "Python Developer - I",
      "Python Developer - II",
      "Python Developer - III",
      "Intern",
    ],
  },
  {
    name: "Services - Operations",
    code: "services_operations",
    designations: [
      "SOC Analyst - I",
      "SOC Analyst - II",
      "SOC Analyst - III",
      "SOC Analyst - IV",
      "SIEM Admin - I",
      "SIEM Admin - II",
      "SIEM Admin - III",
      "SIEM Admin - IV",
      "SOC Consultant - I",
      "SOC Consultant - II",
      "SOC Shift Lead - I",
      "SOC Shift Lead - II",
      "SOC Lead - I",
      "SOC Lead - II",
      "Principal Manager - I",
      "Intern",
    ],
  },
  {
    name: "Services - Consulting",
    code: "services_consulting",
    designations: [
      "GRC Auditor - I",
      "GRC Auditor - II",
      "GRC Auditor - III",
      "GRC Auditor - IV",
      "Senior GRC Auditor - I",
      "Senior GRC Auditor - II",
      "Associate Manager - III",
      "Senior Vice President - Principal Consultant",
      "Intern",
    ],
  },
  {
    name: "Services - Testing",
    code: "services_testing",
    designations: [
      "PenTester - I",
      "PenTester - II",
      "PenTester - III",
      "PenTester - IV",
      "Senior Pentester - I",
      "Senior Pentester - II",
      "Associate Manager - I",
      "Associate Manager - II",
      "Associate Manager - III",
      "Associate Project Manager",
      "Manager - I",
      "DevSecOps Practitioner - I",
      "DevSecOps Practitioner - II",
      "DevSecOps Practitioner - III",
      "DevSecOps Associate",
      "DevSecOps Specialist - II",
      "Red Team Practitioner - II",
      "Red Team Practitioner - III",
      "Red Team Specialist - II",
      "Senior Cloud Security Consultant - I",
      "Associate AI Engineer - Contractual",
      "Intern",
    ],
  },
];

function slugify(text) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .slice(0, 50);
}

const usedCodes = new Set();

function getUniqueCode(base) {
  let code = base.slice(0, 80);
  let counter = 1;
  while (usedCodes.has(code)) {
    code = `${base.slice(0, 75)}_${counter++}`;
  }
  usedCodes.add(code);
  return code;
}

let sql = `
-- 1. Detach old foreign keys in employees table
UPDATE employees SET "JobRoleId" = NULL WHERE "JobRoleId" IS NOT NULL;
UPDATE employees SET "DesignationId" = NULL WHERE "DesignationId" IS NOT NULL;
UPDATE employees SET "DepartmentId" = NULL WHERE "DepartmentId" IS NOT NULL;

-- 2. Clear old roles, designations, and departments
DELETE FROM mst_roles;
DELETE FROM mst_designations;
DELETE FROM mst_departments;

-- 3. Insert clean departments and designations
`;

for (const dept of departments) {
  const deptId = crypto.randomUUID();
  sql += `\nINSERT INTO mst_departments ("Id", "Code", "Name", "IsActive", "CreatedAtUtc") VALUES ('${deptId}', '${dept.code}', '${dept.name.replace(/'/g, "''")}', true, NOW());\n`;

  for (const desig of dept.designations) {
    const desigId = crypto.randomUUID();
    const desigSlug = slugify(desig);
    const deptPrefix = dept.code.slice(0, 20);
    const rawCode = `${deptPrefix}_${desigSlug}`;
    const code = getUniqueCode(rawCode);

    sql += `INSERT INTO mst_designations ("Id", "Code", "Name", "IsActive", "DepartmentId", "CreatedAtUtc") VALUES ('${desigId}', '${code}', '${desig.replace(/'/g, "''")}', true, '${deptId}', NOW());\n`;
  }
}

fs.writeFileSync("scripts/seed_departments_designations.sql", sql);
console.log("Generated scripts/seed_departments_designations.sql");
