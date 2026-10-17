/**
 * Create login accounts with correct **access roles** (User Role Access):
 * TK-0004 → Admin (super admin), IT Admin profile staff → IT Admin.
 *
 * Usage: node scripts/sync-auth-access-uat.mjs
 */
import { execSync } from "child_process";

const API = process.env.PMS_API_URL ?? "http://localhost:52814";
const DB_CONTAINER = process.env.PMS_DB_CONTAINER ?? "pms_uat_db";
const PG_DB = process.env.PMS_DATABASE ?? "pms_uat";

function psql(sql) {
  return execSync(
    `docker exec ${DB_CONTAINER} psql -U postgres -d ${PG_DB} -t -A -F '|' -c ${JSON.stringify(sql)}`,
    { encoding: "utf8" },
  ).trim();
}

async function apiJson(path, init) {
  const res = await fetch(`${API}${path}`, init);
  const body = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = body?.errors?.[0]?.message ?? res.statusText;
    throw new Error(`${path}: ${msg}`);
  }
  return body.data ?? body;
}

async function main() {
  const adminRow = psql(
    `SELECT "Id", "WorkEmail" FROM resource.tbl_employees WHERE "EmployeeCode" = 'TK-0004' LIMIT 1`,
  );
  const [adminId, adminEmail] = adminRow.split("|");
  const headers = {
    "Content-Type": "application/json",
    "X-User-Email": adminEmail || "admin@talakunchi.com",
    "X-User-Role": "Admin",
    "X-User-Id": adminId,
  };

  const targets = psql(
    `SELECT e."EmployeeCode", e."WorkEmail", e."FirstName" || ' ' || e."LastName", d."Name", des."Name" FROM resource.tbl_employees e JOIN master.mst_departments d ON d."Id" = e."DepartmentId" JOIN master.mst_designations des ON des."Id" = e."DesignationId" LEFT JOIN master.mst_roles r ON r."Id" = e."JobRoleId" WHERE e."EmployeeCode" = 'TK-0004' OR des."Name" ILIKE 'IT Admin%' OR r."Name" = 'IT Admin' ORDER BY e."EmployeeCode"`,
  );

  for (const line of targets.split("\n").filter(Boolean)) {
    const [code, email, name, dept, desig] = line.split("|");
    const accessRole = code === "TK-0004" ? "Admin" : "IT Admin";
    const existing = psql(
      `SELECT COUNT(*) FROM auth.tbl_users WHERE lower("Email") = lower('${email.replace(/'/g, "''")}')`,
    );
    if (existing !== "0") {
      console.log("skip (user exists)", code, email);
      continue;
    }
    await apiJson("/api/v1/users", {
      method: "POST",
      headers,
      body: JSON.stringify({
        email,
        name,
        employeeId: code,
        role: accessRole,
        department: dept,
        designation: desig,
      }),
    });
    console.log("created", code, "→", accessRole);
  }

  console.log("Done. User Role Access now drives permissions when switching by email.");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
