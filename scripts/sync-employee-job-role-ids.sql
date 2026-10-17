-- Map resource.tbl_employees."JobRoleId" → master.mst_roles for each employee's designation.
-- Run on pms_uat (e.g. pgAdmin or: psql -h localhost -p 41763 -U postgres -d pms_uat -f scripts/sync-employee-job-role-ids.sql)
--
-- Rules:
-- 1. Keep JobRoleId when it already points to an active mst_roles row for that employee's DesignationId.
-- 2. Otherwise set JobRoleId to the earliest-created active role for that designation (same as bulk upload / API default).

BEGIN;

UPDATE resource.tbl_employees AS e
SET "JobRoleId" = pick.role_id,
    "UpdatedAtUtc" = NOW() AT TIME ZONE 'utc'
FROM (
    SELECT
        emp."Id" AS employee_id,
        (
            SELECT r."Id"
            FROM master.mst_roles AS r
            WHERE r."DesignationId" = emp."DesignationId"
              AND r."IsActive" = TRUE
              AND r."DeletedAtUtc" IS NULL
            ORDER BY r."CreatedAtUtc", r."Name"
            LIMIT 1
        ) AS role_id
    FROM resource.tbl_employees AS emp
    WHERE emp."DeletedAtUtc" IS NULL
      AND emp."DesignationId" IS NOT NULL
) AS pick
WHERE e."Id" = pick.employee_id
  AND pick.role_id IS NOT NULL
  AND (
      e."JobRoleId" IS NULL
      OR NOT EXISTS (
          SELECT 1
          FROM master.mst_roles AS r
          WHERE r."Id" = e."JobRoleId"
            AND r."DesignationId" = e."DesignationId"
            AND r."IsActive" = TRUE
            AND r."DeletedAtUtc" IS NULL
      )
  );

COMMIT;

-- Verification (should return 0 rows for "needs_fix"):
SELECT
    e."EmployeeCode",
    e."FirstName",
    e."LastName",
    d."Name" AS designation,
    jr."Name" AS on_floor_role,
    jr."DesignationId" AS role_designation_id,
    e."DesignationId" AS employee_designation_id
FROM resource.tbl_employees AS e
LEFT JOIN master.mst_designations AS d ON d."Id" = e."DesignationId"
LEFT JOIN master.mst_roles AS jr ON jr."Id" = e."JobRoleId"
WHERE e."DeletedAtUtc" IS NULL
  AND e."DesignationId" IS NOT NULL
  AND (
      e."JobRoleId" IS NULL
      OR jr."Id" IS NULL
      OR jr."DesignationId" <> e."DesignationId"
      OR jr."IsActive" IS NOT TRUE
      OR jr."DeletedAtUtc" IS NOT NULL
  )
ORDER BY e."EmployeeCode";
