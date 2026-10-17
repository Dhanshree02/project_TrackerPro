-- Drop parenthetical abbreviations from master.mst_roles display names (pms_uat).
-- Safe to re-run: only rows whose Name still ends with " (…)" are updated.

UPDATE master.mst_roles
SET "Name" = 'Leader'
WHERE "Name" = 'Leader (L)';

UPDATE master.mst_roles
SET "Name" = 'Team Leader'
WHERE "Name" = 'Team Leader (TL)';

UPDATE master.mst_roles
SET "Name" = 'Team Member'
WHERE "Name" = 'Team Member (TM)';

UPDATE master.mst_roles
SET "Name" = 'Manager'
WHERE "Name" = 'Manager (Mng.)';

UPDATE master.mst_roles
SET "Name" = 'Sr. Manager'
WHERE "Name" = 'Sr. Manager (Sr.Mng.)';

UPDATE master.mst_roles
SET "Name" = 'Head Of Department'
WHERE "Name" = 'Head Of Department (HOD)';
