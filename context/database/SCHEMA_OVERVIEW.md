# PostgreSQL Schemas Overview

The TrackerPro PMS database (`pms_uat_clean`) contains 6 core schemas:

## 1. `master` Schema
Holds static reference masters and the dynamic RBAC catalog:
- `mst_modules`: Root modules
- `mst_submodules`: Submodules and child containers
- `mst_tabs`: Submodule/module tabs
- `mst_widgets`: Dashboard KPI widgets
- Geo & HR masters: `mst_countries`, `mst_cities`, `mst_departments`, `mst_designations`, `mst_onfloorrole_sub_departments`, `mst_leave_calendar`, etc.

## 2. `auth` Schema
- `tbl_roles`: Role definitions (29 roles)
- `tbl_role_permissions`: Assigned permissions per role (`RoleId`, `ItemId`, `CanView`, `CanManage`)
- `log_role_permission_audits`: Permission change audit records
- `tbl_users`: System user credentials and role attachments

## 3. `resource` Schema
- `tbl_employees`: Core employee records, personal info, contacts, department, reporting manager
- `tbl_onfloorrole`: On-floor role assignments

## 4. `project` Schema
- `tbl_projects`: Projects, billing types, client links
- `tbl_project_wbs`: Milestones, tasks, work breakdown
- `tbl_project_allocations`: Team member assignments and percentages
- `tbl_project_health`: Health indicators and status
- `tbl_project_issues`: Reported issues

## 5. `action` Schema
- `tbl_bucket_tasks`: Individual bucket list tasks, timers, hours
- `tbl_action_alerts`: Governance and milestone alerts
- `tbl_allocation_approvals`: Resource allocation and extension requests

## 6. `timesheet` Schema
- `tbl_timesheets`: Weekly timesheet submissions
- `tbl_timesheet_entries`: Daily logged hours per project/task

