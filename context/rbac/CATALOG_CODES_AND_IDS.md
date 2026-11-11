# RBAC Catalog Codes and GUIDs Lookup

> **Canonical source:** Synchronized across `master.mst_modules`, `master.mst_submodules`, `master.mst_tabs`, `master.mst_widgets`, `apps/backend/Infrastructure/Authorization/RbacCatalogCodes.cs`, and `apps/frontend/src/lib/permissions.tsx`.

---

## 1. Top-Level Modules

| Module Name | String Code | Database UUID | Description |
|---|---|---|---|
| Dashboard | `dashboard` | `471bc977-be2e-449d-91e7-5c11cb9c4ec0` | Executive and managerial operational KPI widgets |
| Action Center | `action-centre`, `action-center` | `5a049953-8170-4ef4-a59e-43dc19e12de5` | Central task, approvals, and alert management |
| Projects | `projects` | `168b1296-de6a-4f9e-a3b9-617b83863736` | Project portfolio, WBS, team, and delivery health |
| Resources | `resources` | `715f79ce-51ea-46d3-b95d-8318840f90a6` | Personnel, employee directory, and offboarding |
| Customer | `customers`, `customer` | `4e57fd71-b53e-43c0-862e-5698e09c0922` | Client accounts, sub-ventures, and stakeholder SPOCs |
| Repository | `repository` | `c04c546e-0f2c-448d-b634-5d517843d365` | SOP and corporate document repository |
| My Team | `my-team` | `6055ce3c-b466-4354-ba9a-b4c309111e9d` | Team availability calendar, rosters, and timesheets |
| Settings | `settings` | `fcb69b3e-e5aa-49bb-921f-7793f0a8c90d` | Administrative masters, RBAC matrix, leave calendar |

---

## 2. Submodules

| Submodule Name | String Code | Parent Module | Database UUID |
|---|---|---|---|
| Employee Directory | `employee-directory` | Resources | `39dbd425-643b-47e9-9936-6bbae9ef5ef5` |
| Exit Summary | `exit-summary` | Resources | `526e2d0d-47d4-4814-9e5a-8f7c53af1432` |
| Team Dashboard | `team-dashboard` | My Team | `9854b7f3-8e7e-4ecb-864f-f2533ff295f9` |
| Timesheets | `timesheets` | My Team | `d67426d3-05df-4608-b8cf-c0ecfe698dc3` |
| Master Masters | `master` | Settings | `662d62ab-38b1-447e-876e-7f93bf2ba50e` |
| Roles & Permissions | `roles-permissions` | Settings | `e231d2d4-9ebb-4eb2-af48-fbe3b3b4ab90` |
| Project Detail | `project-detail` | Projects | `b8f7c125-0e5b-4e3d-98e3-542638fa0b21` |
| Customer Detail | `customer-detail` | Customer | `a7e6b014-9f4a-4d2c-87d2-431527ef9a10` |
| Employee Detail | `employee-detail` | Employee Directory | `e8f7c125-0e5b-4e3d-98e3-542638fa0b23` |

---

## 3. Tabs by Submodule / Module

### Team Dashboard Tabs (`SubModuleId = 9854b7f3-8e7e-4ecb-864f-f2533ff295f9`)
| Tab Name | String Code | Database UUID | SortOrder | Access Constraints |
|---|---|---|---|---|
| **My Team** | `my-team` / `my-team-tab` | `9854b7f3-0001-4000-8000-000000000001` | 5 | Strictly View-Only for peers (no editing shifts) |
| **My Reportees** | `my-reportees` | `b1e81c2a-34de-4dd4-b1f3-47387b8ed52b` | 10 | View & View+Manage for reporting managers |
| **All Employees** | `all-employees` | `552f9f86-4eb0-473a-8e39-9863cfefcea4` | 20 | View & View+Manage for executive/HR roles |

### Action Center Tabs (`ModuleId = 5a049953-8170-4ef4-a59e-43dc19e12de5`)
| Tab Name | String Code | Database UUID | SortOrder | Access Rules |
|---|---|---|---|---|
| **Bucket List** | `bucket-list` | `db9aa2d2-1876-4d81-9ff6-6b55be19fb7a` | 10 | Identical behavior for View and View+Manage (timers, tasks, comments) |
| **Approvals** | `approvals` | `a7bd6c40-4e96-4abb-be93-4ed4e4211978` | 20 | Only View hides "Actions" column; View+Manage enables approve/reject |
| **Alerts** | `alerts`, `action-alerts` | `5b828ae3-0b45-4a1c-a1cb-78b29e882cf3` | 30 | Only View hides "Actions" column; View+Manage enables review/governance |
| **Notifications** | `notifications` | `69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc` | 40 | View-only in practice, configurable View & View+Manage |

### Timesheets Tabs (`SubModuleId = d67426d3-05df-4608-b8cf-c0ecfe698dc3`)
| Tab Name | String Code | Database UUID | SortOrder | Constraints |
|---|---|---|---|---|
| **My Timesheet** | `my-timesheet` | `d67426d3-0001-4000-8000-000000000001` | 10 | View + Manage Only |
| **Timesheet History** | `timesheet-history` | `d67426d3-0001-4000-8000-000000000002` | 20 | View + Manage Only |
| **Timesheet Approval** | `timesheet-approval` | `d67426d3-0001-4000-8000-000000000003` | 30 | View + Manage Only |

### Project Detail Tabs (`SubModuleId = b8f7c125-0e5b-4e3d-98e3-542638fa0b21`)
| Tab Name | String Code | Database UUID | SortOrder |
|---|---|---|---|
| Overview | `project-overview` | `c1a11111-0001-4000-8000-000000000001` | 10 |
| WBS | `project-wbs` | `c1a11111-0001-4000-8000-000000000002` | 20 |
| Team | `project-team` | `c1a11111-0001-4000-8000-000000000003` | 30 |
| Tasks | `project-tasks` | `c1a11111-0001-4000-8000-000000000004` | 40 |
| Health | `project-health` | `c1a11111-0001-4000-8000-000000000005` | 50 |
| Invoices | `project-invoices` | `c1a11111-0001-4000-8000-000000000006` | 60 |

### Employee Detail Tabs (`SubModuleId = e8f7c125-0e5b-4e3d-98e3-542638fa0b23`)
| Tab Name | String Code | Database UUID | SortOrder |
|---|---|---|---|
| Personal Info | `employee-personal-info` | `e1a11111-0001-4000-8000-000000000001` | 10 |
| Organization Details | `employee-organization-details` | `e1a11111-0001-4000-8000-000000000002` | 20 |
| Employment & Bond | `employee-employment-bond` | `e1a11111-0001-4000-8000-000000000003` | 30 |
| Education & Experience | `employee-education-experience` | `e1a11111-0001-4000-8000-000000000004` | 40 |
| PMO & EM Information | `employee-pmo-em-information` | `e1a11111-0001-4000-8000-000000000005` | 50 |
| Activity Logs | `employee-activity-logs` | `e1a11111-0001-4000-8000-000000000006` | 60 |

---

## 4. Dashboard KPI Widgets (`ModuleId = 471bc977-be2e-449d-91e7-5c11cb9c4ec0`)

| Widget Name | String Code | Database UUID | SortOrder |
|---|---|---|---|
| Total Team Size | `total-team-size` | `682f26ec-e31d-43a0-82de-e915bab54b59` | 10 |
| Resource Boarding Details | `resource-boarding-details` | `9c916f1a-72e0-4d52-bec1-6d684e990c65` | 20 |
| Team Utilization – Onsite | `team-utilization-onsite` | `896c2166-8f1f-4ab8-873c-755ab3d051fb` | 30 |
| Team Utilization – Offsite | `team-utilization-offsite` | `2b83bafc-1c64-449c-a644-e8e19e0c0a48` | 40 |
| Team Utilization – Onsite (Project-wise) | `team-utilization-onsite-projects` | `7e3f4519-8acd-489f-a70a-ac39092fbd40` | 50 |
| Team Allocation Onsite/Offsite | `team-allocation-onsite-offsite` | `3c5780f7-e23d-48bd-b73e-51019dfbc2bd` | 60 |
| Team Resignation Count | `team-resignation-count` | `0d274292-537d-4c41-8e23-3df901304d71` | 70 |
| Team Capacity – Offsite | `team-capacity-offsite` | `d6dea306-2e8f-41a0-89c8-857cb96f5558` | 80 |

