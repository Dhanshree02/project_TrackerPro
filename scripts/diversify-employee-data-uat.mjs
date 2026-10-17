/**
 * Vary reporting managers & joining dates; offboard some fully and some on notice period.
 *
 * Usage: node scripts/diversify-employee-data-uat.mjs
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

function psqlFile(sql) {
  execSync(`docker exec -i ${DB_CONTAINER} psql -U postgres -d ${PG_DB}`, {
    input: sql,
    encoding: "utf8",
    stdio: ["pipe", "inherit", "inherit"],
  });
}

function fetchJson(path, init) {
  return fetch(`${API}${path}`, init).then(async (res) => {
    const body = await res.json().catch(() => ({}));
    if (!res.ok) {
      const msg = body?.errors?.[0]?.message ?? res.statusText;
      throw new Error(`${path}: ${msg}`);
    }
    return body.data ?? body;
  });
}

async function main() {
  const adminRow = psql(
    `SELECT "Id", "WorkEmail" FROM resource.tbl_employees WHERE "EmployeeCode" = 'TK-0004' LIMIT 1`,
  );
  const [adminId, adminEmail] = adminRow.split("|");
  if (!adminId) throw new Error("TK-0004 not found");

  const headers = {
    "Content-Type": "application/json",
    "X-User-Email": adminEmail,
    "X-User-Role": "Admin",
    "X-User-Id": adminId,
  };

  console.log("Updating joining dates and reporting-manager hierarchy…");
  psqlFile(`
WITH ranked AS (
  SELECT e."Id",
         e."EmployeeCode",
         d."Name" AS dept,
         des."Name" AS desig,
         ROW_NUMBER() OVER (ORDER BY e."EmployeeCode") AS rn
  FROM resource.tbl_employees e
  JOIN master.mst_departments d ON d."Id" = e."DepartmentId"
  JOIN master.mst_designations des ON des."Id" = e."DesignationId"
),
leaders AS (
  SELECT
    (SELECT "Id" FROM resource.tbl_employees WHERE "EmployeeCode" = 'TK-0001' LIMIT 1) AS ceo_id,
    (SELECT "Id" FROM resource.tbl_employees WHERE "EmployeeCode" = 'TK-0002' LIMIT 1) AS coo_id,
    (SELECT "Id" FROM resource.tbl_employees WHERE "EmployeeCode" = 'TK-0003' LIMIT 1) AS cto_id,
    (SELECT "Id" FROM resource.tbl_employees WHERE "EmployeeCode" = 'TK-0004' LIMIT 1) AS admin_id
),
dept_heads AS (
  SELECT DISTINCT ON (r.dept)
    r.dept,
    r."Id" AS head_id
  FROM ranked r
  WHERE r.desig ILIKE '%Head%'
     OR r.desig ILIKE '%HOD%'
     OR r.desig ILIKE '%Director and Chief%'
     OR r.desig ILIKE '%Senior Manager%'
     OR r.desig ILIKE '%Delivery Account Manager%'
     OR r.desig ILIKE '%IT Admin%'
  ORDER BY r.dept,
    CASE
      WHEN r.desig ILIKE '%Director and Chief%' THEN 0
      WHEN r.desig ILIKE '%Head%' THEN 1
      WHEN r.desig ILIKE '%Senior Manager%' THEN 2
      ELSE 3
    END,
    r."EmployeeCode"
),
mgr_pick AS (
  SELECT DISTINCT ON (r.dept)
    r.dept,
    r."Id" AS mgr_id
  FROM ranked r
  WHERE r.desig ILIKE '%Manager%'
    AND r.desig NOT ILIKE '%Senior%'
    AND r.desig NOT ILIKE '%Account Manager%'
  ORDER BY r.dept, r."EmployeeCode"
),
resolved AS (
  SELECT
    r."Id",
    r."EmployeeCode",
    r.dept,
    r.desig,
    r.rn,
    l.ceo_id,
    l.coo_id,
    l.cto_id,
    l.admin_id,
    dh.head_id,
    mp.mgr_id
  FROM ranked r
  CROSS JOIN leaders l
  LEFT JOIN dept_heads dh ON dh.dept = r.dept
  LEFT JOIN mgr_pick mp ON mp.dept = r.dept
)
UPDATE resource.tbl_employees e
SET
  "JoiningDate" = DATE '2018-03-01' + (((resolved.rn * 23) % 2800)::integer),
  "ReportingManagerId" = CASE
    WHEN resolved."EmployeeCode" IN ('TK-0001', 'TK-0002', 'TK-0003', 'TK-0004') THEN NULL
    WHEN resolved.dept = 'Core' AND resolved.head_id IS NOT NULL AND resolved."Id" <> resolved.head_id
      THEN COALESCE(resolved.coo_id, resolved.ceo_id)
    WHEN resolved.dept LIKE 'Functional%' THEN
      CASE
        WHEN resolved."Id" = resolved.head_id THEN resolved.coo_id
        WHEN resolved.mgr_id IS NOT NULL AND resolved."Id" <> resolved.mgr_id THEN resolved.mgr_id
        ELSE COALESCE(resolved.head_id, resolved.coo_id, resolved.ceo_id)
      END
    WHEN resolved.dept LIKE 'Services%' THEN
      CASE
        WHEN resolved."Id" = resolved.head_id THEN resolved.cto_id
        WHEN resolved.mgr_id IS NOT NULL AND resolved."Id" <> resolved.mgr_id THEN resolved.mgr_id
        ELSE COALESCE(resolved.head_id, resolved.cto_id, resolved.coo_id)
      END
    WHEN resolved.dept LIKE 'R&D%' OR resolved.dept ILIKE '%Research%' THEN
      CASE
        WHEN resolved."Id" = resolved.head_id THEN resolved.cto_id
        ELSE COALESCE(resolved.mgr_id, resolved.head_id, resolved.cto_id)
      END
    ELSE COALESCE(resolved.head_id, resolved.coo_id, resolved.admin_id)
  END
FROM resolved
WHERE e."Id" = resolved."Id";
`);

  const statusResignReview = psql(
    `SELECT "Id" FROM master.mst_employee_statuses WHERE "Name" = 'Resignation Under Review' LIMIT 1;`,
  );
  const statusTerminated = psql(
    `SELECT "Id" FROM master.mst_employee_statuses WHERE "Name" = 'Terminated' LIMIT 1;`,
  );

  const today = new Date();
  const istOffset = 5.5 * 60 * 60 * 1000;
  const ist = new Date(today.getTime() + istOffset);
  const y = ist.getUTCFullYear();
  const m = String(ist.getUTCMonth() + 1).padStart(2, "0");
  const d = String(ist.getUTCDate()).padStart(2, "0");
  const todayStr = `${y}-${m}-${d}`;

  const past = new Date(ist);
  past.setUTCDate(past.getUTCDate() - 14);
  const pastStr = past.toISOString().slice(0, 10);

  const future = new Date(ist);
  future.setUTCDate(future.getUTCDate() + 30);
  const futureStr = future.toISOString().slice(0, 10);

  const resignPast = new Date(ist);
  resignPast.setUTCDate(resignPast.getUTCDate() - 30);
  const resignPastStr = resignPast.toISOString().slice(0, 10);

  const fullOffboard = ["TK-0097", "TK-0098", "TK-0099", "TK-0100", "TK-0101"];
  const noticeOffboard = ["TK-0092", "TK-0093", "TK-0094", "TK-0095", "TK-0096"];

  console.log("Offboarding (fully exited)…", fullOffboard.join(", "));
  for (const code of fullOffboard) {
    const exists = psql(
      `SELECT COUNT(*) FROM resource.tbl_employees WHERE "EmployeeCode" = '${code}'`,
    );
    if (exists === "0") {
      console.log("  skip (already exited)", code);
      continue;
    }
    await fetchJson(`/api/v1/employees/${code}/offboard`, {
      method: "POST",
      headers,
      body: JSON.stringify({
        resignationDate: resignPastStr,
        lastWorkingDay: pastStr,
        reasonForLeaving: "Career growth — UAT sample exit",
        noticePeriodServed: "Yes",
        exitType: "Resign",
        exitReason: "Better opportunity",
        employeeStatusId: statusTerminated || null,
      }),
    });
    console.log("  ✓", code);
  }

  console.log("Offboarding (notice period)…", noticeOffboard.join(", "));
  for (const code of noticeOffboard) {
    const exists = psql(
      `SELECT COUNT(*) FROM resource.tbl_employees WHERE "EmployeeCode" = '${code}'`,
    );
    if (exists === "0") {
      console.log("  skip (already exited)", code);
      continue;
    }
    await fetchJson(`/api/v1/employees/${code}/offboard`, {
      method: "POST",
      headers,
      body: JSON.stringify({
        resignationDate: todayStr,
        lastWorkingDay: futureStr,
        reasonForLeaving: "Serving notice — UAT sample",
        noticePeriodServed: "In progress",
        exitType: "Resign",
        exitReason: "Personal reasons",
        employeeStatusId: statusResignReview || null,
      }),
    });
    console.log("  ✓", code, `(LWD ${futureStr})`);
  }

  const counts = psql(
    `SELECT (SELECT COUNT(*) FROM resource.tbl_employees), (SELECT COUNT(*) FROM resource.tbl_exited_employees), (SELECT COUNT(*) FROM resource.tbl_employees WHERE "Status" ILIKE '%Notice%' OR "Status" = 'Resignation Under Review')`,
  );
  console.log("Done.", counts);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
