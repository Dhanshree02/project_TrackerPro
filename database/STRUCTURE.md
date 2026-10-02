# TrackerPro Target Data Structure

This document is the north-star schema map for module-by-module backend delivery.

## Physical layout

PostgreSQL schemas match product modules. `__EFMigrationsHistory` stays in `public`.

| Schema | What lives there |
| --- | --- |
| `auth` | `tbl_users`, `tbl_roles`, `tbl_refresh_tokens`, `log_role_permission_audits`, `tbl_role_widget_permissions`, `vw_role_widget_matrix` |
| `master` | every `mst_` catalog, including service catalog and the widget catalog |
| `resource` | `tbl_employees`, `tbl_exited_employees`, `log_employee_activity` |
| `customer` | `tbl_clients`, `tbl_sub_ventures`, `tbl_client_contacts`, `tbl_client_assignments` |
| `project` | `tbl_projects` and the service, task, team, invoice, document, and draft tables. Assignment history is `log_project_task_assignments` |
| `timesheet` | `tbl_timesheets`, entry tables, and team schedule tables |
| `repository` | `tbl_repository_items`, `tbl_repository_departments`, `log_repository_activity` |

Prefixes: `mst_` catalog, `tbl_` business table, `log_` activity or audit, `vw_` view, `fnc_` function. `auth.tbl_roles` is RBAC. `master.mst_roles` is the job-title catalog.

## Current implementation status

- Implemented (Core & Auth): `users`, `roles`, `refresh_tokens`, `role_permission_audits`, `clients`, `sub_ventures`, `client_assignments`, `client_contacts`
- Implemented (Resources & Catalogs Phase I): `mst_departments`, `mst_designations`, `mst_industries`, `mst_countries`, `mst_cities`, `mst_nationalities`, `mst_roles`, `mst_salary_bands`, `employees`, `exited_employees`
- Implemented (Projects & Services Module): `mst_service_groups`, `mst_service_departments`, `mst_service_sub_departments`, `mst_service_catalog`, `projects`, `project_services`, `project_service_resource_levels`, `project_tasks`, `project_task_assignments`, `project_invoices`, `project_documents`
- Deferred modules: timesheets, approvals/action centre, analytics


## Identity and auth

- Authentication tables are intentionally frozen in this phase.
- Existing local auth/JWT remains for development use.
- Microsoft 365 auth integration will define the future identity model.
- Do not redesign `users`/`roles` in Phase I.

## Canonical domain spine

`employees -> clients -> projects -> tasks/timesheets -> approvals/action-centre`

## Customer alignment notes

- `clients` keeps API-compatible string fields (`Industry`, `EngagementManager`, `City`, `Country`) for frontend stability.
- FK columns were added for normalization: `IndustryId -> mst_industries`, `EngagementManagerId -> employees`, `CountryId -> mst_countries`, `CityId -> mst_cities`.
- Contacts are normalized in `client_contacts` (client-level and sub-venture-level).
- Geo lookups live in `mst_countries` / `mst_cities` (city always belongs to a country) and are shared by any form that currently uses country/city text fields.
- Nationality lookups live in `mst_nationalities` (`GET /api/v1/catalogs/nationalities`).

## Resources phase I notes

- Primary operational table: `employees` (string `Nationality`/`Role`/`SalaryBand` plus FKs `NationalityId -> mst_nationalities`, `JobRoleId -> mst_roles`, `SalaryBandId -> mst_salary_bands`)
- Offboard archive: `exited_employees`
- Org catalogs cascade on onboard: department (`mst_departments`) → designation (`mst_designations.DepartmentId`) → job role (`mst_roles.DesignationId`). Users can add new rows to those catalogs from the form.
- Salary bands are L1–L5 in `mst_salary_bands`. Probation period is months; notice period is days.
- Pool/allocation workflow is explicitly deferred until Action Centre backend is available.
