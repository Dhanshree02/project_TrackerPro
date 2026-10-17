-- Drop parenthetical abbreviations from master.mst_roles display names (pms_uat / any env).
-- Safe to re-run: only rows whose Name still uses the legacy label are updated.

UPDATE master.mst_roles
SET "Name" = 'Leader', "UpdatedAtUtc" = NOW()
WHERE "Name" IN ('Leader (L)', 'Leader(L)');

UPDATE master.mst_roles
SET "Name" = 'Team Leader', "UpdatedAtUtc" = NOW()
WHERE "Name" = 'Team Leader (TL)';

UPDATE master.mst_roles
SET "Name" = 'Team Member', "UpdatedAtUtc" = NOW()
WHERE "Name" = 'Team Member (TM)';

UPDATE master.mst_roles
SET "Name" = 'Manager', "UpdatedAtUtc" = NOW()
WHERE "Name" = 'Manager (Mng.)';

UPDATE master.mst_roles
SET "Name" = 'Sr. Manager', "UpdatedAtUtc" = NOW()
WHERE "Name" = 'Sr. Manager (Sr.Mng.)';

UPDATE master.mst_roles
SET "Name" = 'Head Of Department', "UpdatedAtUtc" = NOW()
WHERE "Name" = 'Head Of Department (HOD)';

-- Sync tbl_employees."Role" when it still stores the old on-floor label text (not RBAC names).
UPDATE resource.tbl_employees
SET "Role" = CASE "Role"
  WHEN 'Leader (L)' THEN 'Leader'
  WHEN 'Leader(L)' THEN 'Leader'
  WHEN 'Team Leader (TL)' THEN 'Team Leader'
  WHEN 'Team Member (TM)' THEN 'Team Member'
  WHEN 'Manager (Mng.)' THEN 'Manager'
  WHEN 'Sr. Manager (Sr.Mng.)' THEN 'Sr. Manager'
  WHEN 'Head Of Department (HOD)' THEN 'Head Of Department'
  ELSE "Role"
END,
"UpdatedAtUtc" = NOW()
WHERE "Role" IN (
  'Leader (L)', 'Leader(L)', 'Team Leader (TL)', 'Team Member (TM)',
  'Manager (Mng.)', 'Sr. Manager (Sr.Mng.)', 'Head Of Department (HOD)'
);
