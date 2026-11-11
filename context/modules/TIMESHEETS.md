# Timesheets Module Context

## 1. Overview
Timesheets is a submodule under My Team (`my-team` -> `timesheets`).
- Submodule UUID: `d67426d3-05df-4608-b8cf-c0ecfe698dc3` (`timesheets`)

## 2. 3 Tabs
- **My Timesheet (`d67426d3-0001-4000-8000-000000000001`):** Daily project hour logging with validation: daily cap of 8h standard, 24h absolute maximum.
- **Timesheet History (`d67426d3-0001-4000-8000-000000000002`):** Historical submissions and approvals per week.
- **Timesheet Approval (`d67426d3-0001-4000-8000-000000000003`):** Reporting manager review inbox to approve or reject submitted employee timesheets.

## 3. RBAC Rule
In Roles & Permissions matrix, all timesheet rows are `isViewManageOnlyRow` (must have View + Manage enabled).

