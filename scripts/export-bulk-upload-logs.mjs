import { execSync } from "child_process";
import fs from "fs";
import path from "path";

// Execute SQL via docker postgres container
function queryDb(sql) {
  const result = execSync('docker exec -i pms_postgres psql -U postgres -d trackerpro -t -A -F "\t"', {
    input: sql,
    encoding: "utf-8",
  });
  return result.trim().split("\n").filter(Boolean).map(row => row.split("\t"));
}

console.log("Fetching database employee entries and logs...");

const employeesSql = `
SELECT 
    e."EmployeeCode",
    e."FirstName" || ' ' || e."LastName" AS full_name,
    e."WorkEmail",
    COALESCE(d."Name", 'N/A') AS department,
    COALESCE(des."Name", 'N/A') AS designation,
    COALESCE(e."Role", 'N/A') AS role,
    COALESCE(e."Status", 'Active') AS status,
    COALESCE(e."JoiningDate"::text, 'N/A') AS joining_date,
    e."Id"::text AS employee_id,
    e."CreatedAtUtc"::text AS created_at_utc,
    COALESCE(u."Email", e."CreatedBy"::text, 'System Seed') AS created_by
FROM employees e
LEFT JOIN mst_departments d ON e."DepartmentId" = d."Id"
LEFT JOIN mst_designations des ON e."DesignationId" = des."Id"
LEFT JOIN users u ON e."CreatedBy" = u."Id"
ORDER BY e."CreatedAtUtc" DESC, e."EmployeeCode" ASC;
`;

const activityLogsSql = `
SELECT 
    l."Id"::text,
    l."EmployeeId"::text,
    e."EmployeeCode",
    e."FirstName" || ' ' || e."LastName" AS full_name,
    l."Action",
    l."PerformedByEmail",
    COALESCE(l."PerformedByName", 'N/A'),
    l."Details",
    l."CreatedAtUtc"::text
FROM employee_activity_logs l
LEFT JOIN employees e ON l."EmployeeId" = e."Id"
ORDER BY l."CreatedAtUtc" DESC;
`;

const employeeRows = queryDb(employeesSql);
const activityRows = queryDb(activityLogsSql);

const timestampStr = new Date().toISOString().replace(/[:.]/g, "-");
const nowFormatted = new Date().toLocaleString("en-GB", { timeZone: "UTC" }) + " UTC";

// Build formatted text log
let textLog = `========================================================================================================================
TRACKERPRO DATABASE BULK UPLOAD & EMPLOYEE ENTRY AUDIT LOG
Generated At: ${nowFormatted}
Total Database Employees : ${employeeRows.length}
Total Activity Log Events: ${activityRows.length}
========================================================================================================================

1. SUMMARY OF RECENT ACTIVITY LOGS (${activityRows.length} events)
------------------------------------------------------------------------------------------------------------------------
`;

if (activityRows.length === 0) {
  textLog += "No employee activity log events found.\n";
} else {
  for (const [id, empId, code, name, action, byEmail, byName, details, atUtc] of activityRows) {
    textLog += `[${atUtc}] ACTION: ${action} | EMPLOYEE: ${name || "Unknown"} (${code || "N/A"}) | BY: ${byName} (${byEmail})
             DETAILS: ${details}
             LOG ID : ${id} | EMPLOYEE ID: ${empId}\n\n`;
  }
}

textLog += `========================================================================================================================
2. ALL DATABASE EMPLOYEE RECORDS (${employeeRows.length} total entries)
------------------------------------------------------------------------------------------------------------------------
ROW | TK ID    | FULL NAME             | WORK EMAIL                     | DEPARTMENT                     | DESIGNATION / ROLE                  | STATUS | JOIN DATE  | CREATED AT (UTC)            | CREATED BY
------------------------------------------------------------------------------------------------------------------------
`;

const jsonEntries = [];
let rowIdx = 1;

for (const [code, fullName, email, dept, desig, role, status, joinDate, empId, createdAt, createdBy] of employeeRows) {
  const rNum = String(rowIdx++).padStart(3, " ");
  const tk = (code || "").padEnd(8, " ");
  const name = (fullName || "").padEnd(21, " ").slice(0, 21);
  const mail = (email || "").padEnd(30, " ").slice(0, 30);
  const dp = (dept || "").padEnd(30, " ").slice(0, 30);
  const dg = ((desig !== "N/A" ? desig : role) || "").padEnd(35, " ").slice(0, 35);
  const st = (status || "").padEnd(6, " ");
  const jd = (joinDate || "").padEnd(10, " ");
  const ca = (createdAt || "").padEnd(27, " ").slice(0, 27);

  textLog += `${rNum} | ${tk} | ${name} | ${mail} | ${dp} | ${dg} | ${st} | ${jd} | ${ca} | ${createdBy}\n`;

  jsonEntries.push({
    rowNumber: rowIdx - 1,
    employeeId: empId,
    employeeCode: code,
    fullName,
    workEmail: email,
    department: dept,
    designation: desig,
    role,
    status,
    joiningDate: joinDate,
    createdAtUtc: createdAt,
    createdBy,
  });
}

textLog += `========================================================================================================================
End of Log.
========================================================================================================================
`;

// Build CSV
let csv = "Row,TK ID,Full Name,Work Email,Department,Designation,Role,Status,Joining Date,Employee ID,CreatedAtUtc,CreatedBy\n";
for (const e of jsonEntries) {
  const esc = (val) => `"${String(val || "").replace(/"/g, '""')}"`;
  csv += `${e.rowNumber},${esc(e.employeeCode)},${esc(e.fullName)},${esc(e.workEmail)},${esc(e.department)},${esc(e.designation)},${esc(e.role)},${esc(e.status)},${esc(e.joiningDate)},${esc(e.employeeId)},${esc(e.createdAtUtc)},${esc(e.createdBy)}\n`;
}

// Ensure target directories
const dirs = [
  path.join(process.cwd(), "logs", "bulk_upload"),
  path.join(process.cwd(), "apps", "backend", "Log", "BulkUpload"),
];

for (const d of dirs) {
  fs.mkdirSync(d, { recursive: true });
  fs.writeFileSync(path.join(d, "database_employee_entries.log"), textLog, "utf-8");
  fs.writeFileSync(path.join(d, "database_employee_entries.json"), JSON.stringify({ metadata: { generatedAt: nowFormatted, total: jsonEntries.length }, employees: jsonEntries, activityLogs: activityRows }, null, 2), "utf-8");
  fs.writeFileSync(path.join(d, "database_employee_entries.csv"), csv, "utf-8");
  fs.writeFileSync(path.join(d, `bulk-upload-snapshot-${timestampStr}.log`), textLog, "utf-8");
}

console.log("Successfully generated bulk upload database logs at:");
for (const d of dirs) {
  console.log(" - " + path.join(d, "database_employee_entries.log"));
  console.log(" - " + path.join(d, "database_employee_entries.json"));
  console.log(" - " + path.join(d, "database_employee_entries.csv"));
}
