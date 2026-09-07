import { execSync } from "child_process";

function queryDb(sql) {
  const result = execSync('docker exec -i pms_postgres psql -U postgres -d trackerpro -t -A -F "\t"', {
    input: sql,
    encoding: "utf-8",
  });
  return result.trim().split("\n").filter(Boolean).map(row => row.split("\t"));
}

function execDb(sql) {
  execSync('docker exec -i pms_postgres psql -U postgres -d trackerpro', {
    input: sql,
    encoding: "utf-8",
    stdio: "inherit",
  });
}

// 1. Fetch departments
const deptRows = queryDb('SELECT "Id", "Name" FROM mst_departments;');
const deptsByName = new Map(deptRows.map(([id, name]) => [name, id]));

// 2. Fetch designations
const desigRows = queryDb('SELECT d."Id", d."Name", d."DepartmentId" FROM mst_designations d;');
// Map (deptId + "::" + desigName) -> desigId
const desigMap = new Map();
for (const [id, name, deptId] of desigRows) {
  desigMap.set(`${deptId}::${name}`, id);
}

// 3. Realistic assignment mapping for each employee by code
const assignmentPlan = {
  // Core (Executive)
  "EMP-3456": { dept: "Core", desig: "Director and Chief Executive Officer" },

  // Functional - Project Management
  "EMP-1024": { dept: "Functional - Project Management", desig: "Senior Delivery Account Manager - II" },
  "EMP-1023": { dept: "Functional - Project Management", desig: "Senior Delivery Account Manager - I" },
  "EMP-1021": { dept: "Functional - Project Management", desig: "Delivery Account Manager - II" },
  "EMP-1022": { dept: "Functional - Project Management", desig: "Delivery Account Manager - I" },
  "EMP-1016": { dept: "Functional - Project Management", desig: "Senior PMO - I" },
  "EMP-1010": { dept: "Functional - Project Management", desig: "Associate PMO - I" },

  // Functional - Accounts
  "EMP-1007": { dept: "Functional - Accounts", desig: "Senior Accountant - I" },
  "EMP-8163": { dept: "Functional - Accounts", desig: "Accountant - II" },

  // Functional - HR
  "EMP-1008": { dept: "Functional - HR", desig: "HR Head" },
  "EMP-1019": { dept: "Functional - HR", desig: "Senior HR Executive - I" },

  // Functional - Sales
  "EMP-1009": { dept: "Functional - Sales", desig: "Business Development Associate - I" },
  "EMP-1020": { dept: "Functional - Sales", desig: "Sales Associate" },

  // Functional - IT Administration
  "EMP-1014": { dept: "Functional - IT Administration", desig: "Desktop Support Engineer - I" },
  "EMP-9301": { dept: "Functional - IT Administration", desig: "Desktop Support Engineer - II" },

  // R&D (Research & Development)
  "EMP-1013": { dept: "R&D (Research & Development)", desig: "Python Developer - II" },
  "EMP-3021": { dept: "R&D (Research & Development)", desig: "Python Developer - I" },
  "EMP-9729": { dept: "R&D (Research & Development)", desig: "Python Developer - III" },

  // Services - Operations
  "EMP-1003": { dept: "Services - Operations", desig: "SOC Lead - I" },
  "EMP-1004": { dept: "Services - Operations", desig: "SOC Analyst - II" },
  "EMP-1018": { dept: "Services - Operations", desig: "SOC Analyst - I" },
  "EMP-1006": { dept: "Services - Operations", desig: "SIEM Admin - II" },
  "EMP-7266": { dept: "Services - Operations", desig: "SIEM Admin - I" },

  // Services - Consulting
  "EMP-1011": { dept: "Services - Consulting", desig: "GRC Auditor - II" },
  "EMP-1015": { dept: "Services - Consulting", desig: "GRC Auditor - I" },

  // Services - Testing
  "EMP-1001": { dept: "Services - Testing", desig: "PenTester - II" },
  "EMP-1017": { dept: "Services - Testing", desig: "PenTester - I" },
  "EMP-8103": { dept: "Services - Testing", desig: "Senior Pentester - I" },
  "EMP-1002": { dept: "Services - Testing", desig: "DevSecOps Practitioner - II" },
  "EMP-5886": { dept: "Services - Testing", desig: "DevSecOps Practitioner - I" },
  "EMP-SAMPLE": { dept: "Services - Testing", desig: "DevSecOps Associate" },
  "EMP-1012": { dept: "Services - Testing", desig: "Red Team Practitioner - II" },
  "EMP-1005": { dept: "Services - Testing", desig: "Associate Project Manager" },
};

console.log("Generating update statements...");
let updateSql = "BEGIN;\n";

for (const [code, { dept, desig }] of Object.entries(assignmentPlan)) {
  const deptId = deptsByName.get(dept);
  if (!deptId) throw new Error(`Department not found: ${dept}`);

  const desigId = desigMap.get(`${deptId}::${desig}`);
  if (!desigId) throw new Error(`Designation not found: ${desig} in ${dept}`);

  updateSql += `UPDATE employees SET "DepartmentId" = '${deptId}', "DesignationId" = '${desigId}', "Role" = '${desig.replace(/'/g, "''")}' WHERE "EmployeeCode" = '${code}';\n`;
}

updateSql += "COMMIT;\n";

import fs from "fs";

fs.writeFileSync("scripts/update_employees.sql", updateSql);
console.log("Generated scripts/update_employees.sql successfully!");
