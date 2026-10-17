/**
 * Clean pms_uat employees, recreate Admin (TK-0004), then bulk-upload one row per
 * valid Department + Designation + Sub-Department combination from masters.
 *
 * Usage (from repo root):
 *   node scripts/reseed-employee-dept-matrix.mjs
 *
 * Requires: Docker (pms_uat_db, pms_uat_backend), exceljs (scripts/employee-reseed/node_modules).
 */
import { execSync } from "child_process";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { createRequire } from "module";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(path.join(__dirname, "employee-reseed", "package.json"));
const ExcelJS = require("exceljs");
const REPO_ROOT = path.resolve(__dirname, "..");
const API = process.env.PMS_API_URL ?? "http://localhost:52814";
const DB_CONTAINER = process.env.PMS_DB_CONTAINER ?? "pms_uat_db";
const PG_DB = process.env.PMS_DATABASE ?? "pms_uat";

const HEADERS = [
  "TK ID",
  "First Name",
  "Last Name",
  "Work Email",
  "Phone (Personal)",
  "Alternate Contact Number",
  "Current Address - City",
  "Emergency Contact Name",
  "Emergency Contact Number",
  "Relation with Emergency Contact",
  "Department",
  "Designation",
  "Sub-Department",
  "Business Unit",
  "Reporting Manager Code",
  "Work Location",
  "Location (Onsite)",
  "Date of Joining",
  "Asset ID",
  "Employee Status",
  "Worker Type",
  "Bond Delivered",
  "Bond Duration (Months)",
  "Bond Expiry Date",
  "Bond Status",
  "Graduation Degree Name",
  "Graduation - Passing Year",
  "Post Graduation Degree Name",
  "Post Graduation - Passing Year",
  "Exp / Fresher",
  "Prior Total Exp (Years)",
  "Prior Total Exp (Months)",
  "Prior Relevant Exp (Years)",
  "Prior Relevant Exp (Months)",
  "Certification Details",
];

/** Valid for onboarding: letters, spaces, hyphens, apostrophes only. */
const INDIAN_FIRST_NAMES = [
  "Aarav", "Vihaan", "Arjun", "Reyansh", "Advait", "Krishna", "Ishaan", "Shaurya",
  "Rohan", "Karan", "Aditya", "Vikram", "Rahul", "Nikhil", "Siddharth", "Amit",
  "Varun", "Kunal", "Manish", "Pradeep", "Rajesh", "Deepak", "Girish", "Suresh",
  "Alok", "Dev", "Harsh", "Omkar", "Yash", "Kabir", "Vivaan", "Atharv",
  "Ananya", "Priya", "Sneha", "Kavya", "Ira", "Meera", "Divya", "Pooja",
  "Swati", "Tanvi", "Neha", "Riya", "Shreya", "Aisha", "Simran", "Bhavna",
  "Nidhi", "Aditi", "Sana", "Anita", "Lakshmi", "Pallavi", "Trisha", "Ishita",
];

const INDIAN_LAST_NAMES = [
  "Sharma", "Patel", "Reddy", "Nair", "Iyer", "Menon", "Pillai", "Kulkarni",
  "Desai", "Mehta", "Joshi", "Kapoor", "Malhotra", "Chopra", "Bose", "Verma",
  "Singh", "Gupta", "Rao", "Nambiar", "Saxena", "Mishra", "Pandey", "Khanna",
  "Deshmukh", "Kadam", "Sawant", "Shenoy", "Mathur", "Bhatt", "Choudhary", "Jain",
  "Gaikwad", "Pansare", "Deshpande", "Kaur", "Wardhan", "Mehra", "Roy", "Sengupta",
];

const EMERGENCY_RELATIONS = ["Father", "Mother", "Spouse", "Sibling", "Guardian"];

function seededShuffle(items, seed) {
  const arr = [...items];
  let state = seed >>> 0;
  for (let i = arr.length - 1; i > 0; i -= 1) {
    state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
    const j = state % (i + 1);
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function buildIndianNamePool(count) {
  const pairs = [];
  for (const firstName of INDIAN_FIRST_NAMES) {
    for (const lastName of INDIAN_LAST_NAMES) {
      pairs.push({ firstName, lastName });
    }
  }
  return seededShuffle(pairs, 20261016).slice(0, count);
}

function psql(sql) {
  return execSync(
    `docker exec -i ${DB_CONTAINER} psql -U postgres -d ${PG_DB} -t -A -F '|' -v ON_ERROR_STOP=1`,
    { input: sql, encoding: "utf-8" },
  ).trim();
}

function psqlFile(relativePath) {
  const full = path.join(REPO_ROOT, relativePath);
  execSync(`docker exec -i ${DB_CONTAINER} psql -U postgres -d ${PG_DB} -v ON_ERROR_STOP=1`, {
    input: fs.readFileSync(full, "utf-8"),
    stdio: ["pipe", "inherit", "inherit"],
  });
}

function todayDdMmYyyyIst() {
  const fmt = new Intl.DateTimeFormat("en-GB", {
    timeZone: "Asia/Kolkata",
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
  return fmt.format(new Date());
}

function fetchCombos() {
  const sql = `
SELECT department, designation, subdept
FROM (
  SELECT d."Name" AS department,
         des."Name" AS designation,
         trim(s) AS subdept
  FROM master.mst_designations des
  JOIN master.mst_departments d ON des."DepartmentId" = d."Id"
  CROSS JOIN LATERAL unnest(
    CASE WHEN COALESCE(trim(des."SubDepartment"), '') = ''
         THEN ARRAY['']::text[]
         ELSE (SELECT array_agg(DISTINCT trim(x) ORDER BY trim(x))
               FROM unnest(string_to_array(des."SubDepartment", ',')) x
               WHERE trim(x) <> '')
    END
  ) s
  WHERE des."DeletedAtUtc" IS NULL AND des."IsActive"
    AND d."DeletedAtUtc" IS NULL AND d."IsActive"
) q
ORDER BY department, designation, subdept;
`;
  return psql(sql)
    .split("\n")
    .filter(Boolean)
    .map((line) => {
      const [department, designation, subDepartment] = line.split("|");
      return { department, designation, subDepartment: subDepartment ?? "" };
    });
}

async function apiPostJson(urlPath, body) {
  const res = await fetch(`${API}${urlPath}`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  let json;
  try {
    json = JSON.parse(text);
  } catch {
    throw new Error(`Non-JSON ${res.status} from ${urlPath}: ${text.slice(0, 500)}`);
  }
  if (!res.ok) {
    const msg = json?.errors?.[0]?.message ?? json?.message ?? text;
    throw new Error(`API ${res.status} ${urlPath}: ${msg}`);
  }
  return json.data ?? json;
}

async function createBootstrapAdmin() {
  const metaLine = psql(
    "SELECT d.\"Id\", des.\"Id\", st.\"Id\" FROM master.mst_designations des " +
      "JOIN master.mst_departments d ON des.\"DepartmentId\" = d.\"Id\" " +
      "CROSS JOIN master.mst_employee_statuses st " +
      "WHERE d.\"Name\" = 'Functional - IT Administration' AND des.\"Name\" = 'IT Admin' " +
      "AND st.\"Name\" = 'Active' AND st.\"DeletedAtUtc\" IS NULL LIMIT 1;",
  )
    .split("\n")
    .filter(Boolean)[0];
  if (!metaLine) throw new Error("Could not resolve IT Admin / Active status for bootstrap admin.");
  const idParts = metaLine.split("|");
  const [deptId, desigId, statusId] = idParts.map((v) => v.trim());
  if (!deptId || !desigId) {
    throw new Error(`Bootstrap meta parse failed: ${JSON.stringify(metaLine)}`);
  }
  const joining = todayDdMmYyyyIst();
  const [dd, mm, yyyy] = joining.split("/");
  const joiningIso = `${yyyy}-${mm}-${dd}`;

  await apiPostJson("/api/v1/employees", {
    employeeCode: "TK-0004",
    firstName: "Admin",
    lastName: "User",
    workEmail: "admin@talakunchi.com",
    phone: "9820000004",
    address: "Andheri (Western Line)",
    departmentId: deptId,
    designationId: desigId,
    employeeStatusId: statusId,
    subDepartment: "Functional - IT Administration",
    workLocation: "Suvidha Square, Andheri",
    joiningDate: joiningIso,
    status: "Active",
    employmentType: "Permanent",
    bondDelivered: "No",
  });
  console.log("Created bootstrap Admin User (TK-0004).");
}

function nextPermanentCode(counter) {
  let n = counter;
  if (n >= 4) n += 1;
  return `TK-${String(n).padStart(4, "0")}`;
}

function buildRow(index, combo, joining, person, emergencyContact) {
  const isIntern = combo.designation.toLowerCase() === "intern";
  const code = isIntern
    ? `TKI-${String(++index.intern).padStart(4, "0")}`
    : nextPermanentCode(++index.perm);
  const phone = String(9820010000 + index.row);
  const slug = (s) => s.toLowerCase().replace(/[^a-z]/g, "");
  const workEmail = `${slug(person.firstName)}.${slug(person.lastName)}.${code.toLowerCase()}@talakunchi.com`;
  const emergencyPhone = String(9810000000 + ((index.row * 17) % 9000000) + 1000000).slice(0, 10);
  const relation = EMERGENCY_RELATIONS[index.row % EMERGENCY_RELATIONS.length];

  return [
    code,
    person.firstName,
    person.lastName,
    workEmail,
    phone,
    "",
    "Andheri (Western Line)",
    `${emergencyContact.firstName} ${emergencyContact.lastName}`,
    emergencyPhone,
    relation,
    combo.department,
    combo.designation,
    combo.subDepartment,
    "Talakunchi Networks Private Limited",
    "TK-0004",
    "Suvidha Square, Andheri",
    "",
    joining,
    "",
    "Active",
    isIntern ? "Intern" : "Permanent",
    isIntern ? "No" : "Yes",
    isIntern ? "0" : "24",
    "",
    isIntern ? "No Bond" : "Active",
    "BE",
    "2020",
    "NA",
    "NA",
    isIntern ? "Fresher" : "Experienced",
    isIntern ? "0" : "2",
    "0",
    isIntern ? "0" : "2",
    "0",
    "",
  ];
}

async function buildWorkbook(combos, outPath) {
  const joining = todayDdMmYyyyIst();
  const names = buildIndianNamePool(combos.length);
  const emergencyNames = buildIndianNamePool(combos.length + 20);
  const wb = new ExcelJS.Workbook();
  const sheet = wb.addWorksheet("Employees");
  sheet.addRow(HEADERS);

  const index = { row: 0, perm: 0, intern: 0 };
  for (const combo of combos) {
    index.row += 1;
    const person = names[index.row - 1];
    const emergencyContact = emergencyNames[index.row + 7];
    sheet.addRow(buildRow(index, combo, joining, person, emergencyContact));
  }

  await wb.xlsx.writeFile(outPath);
  return combos.length;
}

async function bulkUpload(filePath) {
  const buf = fs.readFileSync(filePath);
  const form = new FormData();
  form.append("file", new Blob([buf]), path.basename(filePath));

  const res = await fetch(`${API}/api/v1/employees/bulk`, {
    method: "POST",
    body: form,
  });
  const json = await res.json();
  if (!res.ok) {
    throw new Error(`Bulk upload failed: ${JSON.stringify(json)}`);
  }
  const data = json.data ?? json;
  if (data.errors?.length) {
    console.error(JSON.stringify(data.errors, null, 2));
    throw new Error(`Bulk upload rejected ${data.errors.length} row(s).`);
  }
  return data;
}

async function verifyCoverage(expected) {
  const sql = `
WITH expanded AS (
  SELECT d."Name" AS dept, des."Name" AS desig, trim(s) AS subdept
  FROM master.mst_designations des
  JOIN master.mst_departments d ON des."DepartmentId" = d."Id"
  CROSS JOIN LATERAL unnest(
    CASE WHEN COALESCE(trim(des."SubDepartment"), '') = '' THEN ARRAY['']::text[]
         ELSE (SELECT array_agg(DISTINCT trim(x) ORDER BY trim(x))
               FROM unnest(string_to_array(des."SubDepartment", ',')) x WHERE trim(x) <> '')
    END
  ) s
  WHERE des."DeletedAtUtc" IS NULL AND des."IsActive"
    AND d."DeletedAtUtc" IS NULL AND d."IsActive"
),
employees AS (
  SELECT d."Name" AS dept, des."Name" AS desig, COALESCE(e."SubDepartment", '') AS subdept
  FROM resource.tbl_employees e
  LEFT JOIN master.mst_departments d ON e."DepartmentId" = d."Id"
  LEFT JOIN master.mst_designations des ON e."DesignationId" = des."Id"
  WHERE e."DeletedAtUtc" IS NULL AND e."EmployeeCode" <> 'TK-0004'
)
SELECT
  (SELECT COUNT(*) FROM expanded) AS expected,
  (SELECT COUNT(*) FROM employees) AS seeded,
  (SELECT COUNT(*) FROM expanded ex
   WHERE NOT EXISTS (
     SELECT 1 FROM employees em
     WHERE lower(em.dept) = lower(ex.dept)
       AND lower(em.desig) = lower(ex.desig)
       AND lower(trim(em.subdept)) = lower(trim(ex.subdept))
   )) AS missing;
`;
  const [expectedCount, seeded, missing] = psql(sql).split("|").map((n) => Number(n));
  console.log(`Coverage: expected=${expectedCount}, matrix employees=${seeded}, missing=${missing}`);
  if (missing !== 0 || seeded !== expected) {
    throw new Error("Department / designation / sub-department coverage check failed.");
  }
  if (expected !== expectedCount) {
    throw new Error(`Script expected ${expected} combos but DB expects ${expectedCount}.`);
  }
}

async function main() {
  console.log("Cleaning employee data on pms_uat…");
  psqlFile("scripts/clean-employees-uat.sql");

  const combos = fetchCombos();
  console.log(`Loaded ${combos.length} department / designation / sub-department combinations.`);

  await createBootstrapAdmin();

  const outPath = path.join(REPO_ROOT, "scripts", "employee-dept-matrix-upload.xlsx");
  const rowCount = await buildWorkbook(combos, outPath);
  console.log(`Wrote ${rowCount} rows to ${outPath}`);

  const result = await bulkUpload(outPath);
  console.log(`Bulk upload: created=${result.created}, errors=${result.errorCount ?? 0}`);

  const total = psql('SELECT COUNT(*) FROM resource.tbl_employees WHERE "DeletedAtUtc" IS NULL;');
  console.log(`Active employees in DB: ${total} (includes TK-0004 admin).`);

  await verifyCoverage(combos.length);
  console.log("Done.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
