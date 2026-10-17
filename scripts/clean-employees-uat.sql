-- Wipe employee-linked data on pms_uat (masters unchanged).
-- Run: docker exec -i pms_uat_db psql -U postgres -d pms_uat -v ON_ERROR_STOP=1 < scripts/clean-employees-uat.sql

BEGIN;

DELETE FROM timesheet.tbl_timesheet_entry_days;
DELETE FROM timesheet.tbl_timesheet_entries;
DELETE FROM timesheet.tbl_timesheets;
DELETE FROM timesheet.tbl_team_day_entries;
DELETE FROM timesheet.tbl_team_member_holidays;
DELETE FROM timesheet.tbl_team_member_schedules;

DELETE FROM project.log_project_task_assignments;
DELETE FROM project.tbl_project_task_assignments;
DELETE FROM project.tbl_project_team_members;

UPDATE project.tbl_projects
SET "EngagementManagerId" = NULL,
    "ProjectManagerId" = NULL,
    "TeamLeadId" = NULL,
    "SalesPersonId" = NULL;

UPDATE customer.tbl_clients
SET "EngagementManagerId" = NULL,
    "SalesManagerId" = NULL;

DELETE FROM master.mst_reporting_managers;
DELETE FROM resource.log_employee_activity;
DELETE FROM resource.tbl_exited_employees;

UPDATE resource.tbl_employees
SET "ReportingManagerId" = NULL,
    "UserId" = NULL;

DELETE FROM auth.tbl_refresh_tokens;
DELETE FROM auth.tbl_users;
DELETE FROM resource.tbl_employees;

COMMIT;
