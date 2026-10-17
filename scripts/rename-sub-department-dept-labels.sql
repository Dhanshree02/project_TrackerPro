-- Use full word "Department" instead of "Dept." in sub-department labels (pms_uat).

UPDATE master.mst_designations
SET "SubDepartment" = REPLACE("SubDepartment", ' Dept.', ' Department')
WHERE "SubDepartment" LIKE '% Dept.%';

UPDATE resource.tbl_employees
SET "SubDepartment" = REPLACE("SubDepartment", ' Dept.', ' Department')
WHERE "SubDepartment" LIKE '% Dept.%';

UPDATE project.tbl_project_team_members
SET "SubDepartment" = REPLACE("SubDepartment", ' Dept.', ' Department')
WHERE "SubDepartment" LIKE '% Dept.%';
