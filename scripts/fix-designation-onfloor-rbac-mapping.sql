-- Department → Designation → On Floor Role → RBAC Role
--
-- Makes the chain consistent on an existing database and repairs employees whose
-- saved On Floor Role / RBAC Role / Department no longer match their designation.
-- Idempotent: safe to run more than once. No rows are deleted.
--
-- Run:  psql -h 127.0.0.1 -U postgres -d trackerpro_uat -f scripts/fix-designation-onfloor-rbac-mapping.sql

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. On Floor Role corrections on mst_roles (renamed in place so employee FKs stay valid)
-- ---------------------------------------------------------------------------

-- "Sales Manger" typo → "Sales Manager"
UPDATE mst_roles r
SET "Name" = 'Sales Manager',
    "UpdatedAtUtc" = NOW()
WHERE r."DeletedAtUtc" IS NULL
  AND r."Name" = 'Sales Manger';

-- SOC Lead - I is SOC-Manager in RBAC, so the On Floor Role is Manager (Mng.)
UPDATE mst_roles r
SET "Name" = 'Manager (Mng.)',
    "UpdatedAtUtc" = NOW()
FROM mst_designations d
JOIN mst_departments dp ON dp."Id" = d."DepartmentId"
WHERE r."DesignationId" = d."Id"
  AND r."DeletedAtUtc" IS NULL
  AND d."DeletedAtUtc" IS NULL
  AND dp."Name" = 'Services - Operations'
  AND d."Name" = 'SOC Lead - I'
  AND r."Name" <> 'Manager (Mng.)';

-- ---------------------------------------------------------------------------
-- 2. Exactly one active On Floor Role per designation.
--    When a designation has several active rows, keep the oldest and deactivate the rest.
-- ---------------------------------------------------------------------------
WITH ranked AS (
  SELECT r."Id",
         ROW_NUMBER() OVER (PARTITION BY r."DesignationId" ORDER BY r."CreatedAtUtc", r."Id") AS rn
  FROM mst_roles r
  WHERE r."DeletedAtUtc" IS NULL AND r."IsActive"
)
UPDATE mst_roles r
SET "IsActive" = FALSE,
    "UpdatedAtUtc" = NOW()
FROM ranked
WHERE r."Id" = ranked."Id" AND ranked.rn > 1;

-- ---------------------------------------------------------------------------
-- 3. Repair employees from their designation.
-- ---------------------------------------------------------------------------
WITH chain AS (
  SELECT d."Id" AS designation_id,
         d."DepartmentId" AS department_id,
         (SELECT r."Id" FROM mst_roles r
           WHERE r."DesignationId" = d."Id" AND r."DeletedAtUtc" IS NULL AND r."IsActive"
           ORDER BY r."CreatedAtUtc", r."Id" LIMIT 1) AS job_role_id,
         rb."Name" AS rbac_role
  FROM mst_designations d
  LEFT JOIN roles rb ON rb."Id" = d."DefaultRoleId" AND rb."DeletedAtUtc" IS NULL
  WHERE d."DeletedAtUtc" IS NULL
)
UPDATE employees e
SET "DepartmentId" = COALESCE(chain.department_id, e."DepartmentId"),
    "JobRoleId"    = COALESCE(chain.job_role_id, e."JobRoleId"),
    "Role"         = COALESCE(chain.rbac_role, e."Role"),
    "UpdatedAtUtc" = NOW()
FROM chain
WHERE e."DesignationId" = chain.designation_id
  AND e."DeletedAtUtc" IS NULL
  AND (
       e."DepartmentId" IS DISTINCT FROM COALESCE(chain.department_id, e."DepartmentId")
    OR e."JobRoleId"    IS DISTINCT FROM COALESCE(chain.job_role_id, e."JobRoleId")
    OR e."Role"         IS DISTINCT FROM COALESCE(chain.rbac_role, e."Role")
  );

-- Keep the linked login's department / designation text in step with the employee.
UPDATE users u
SET "Department"  = dp."Name",
    "Designation" = d."Name",
    "UpdatedAtUtc" = NOW()
FROM employees e
JOIN mst_designations d ON d."Id" = e."DesignationId"
LEFT JOIN mst_departments dp ON dp."Id" = e."DepartmentId"
WHERE e."DeletedAtUtc" IS NULL
  AND (u."Email" = e."WorkEmail" OR u."EmployeeId" = e."EmployeeCode")
  AND (u."Department" IS DISTINCT FROM dp."Name" OR u."Designation" IS DISTINCT FROM d."Name");

COMMIT;

-- ---------------------------------------------------------------------------
-- Review
-- ---------------------------------------------------------------------------
SELECT e."EmployeeCode",
       e."FirstName" || ' ' || e."LastName" AS employee,
       dp."Name" AS department,
       d."Name"  AS designation,
       r."Name"  AS on_floor_role,
       e."Role"  AS rbac_role
FROM employees e
LEFT JOIN mst_departments dp ON dp."Id" = e."DepartmentId"
LEFT JOIN mst_designations d ON d."Id" = e."DesignationId"
LEFT JOIN mst_roles r ON r."Id" = e."JobRoleId"
WHERE e."DeletedAtUtc" IS NULL
ORDER BY e."EmployeeCode";
