# Omkar RBAC Master Specification

> **CORE PRINCIPLE:** All legacy logic, old permission tables, baseline JSON/matrix rules, and historical assumptions for RBAC access are **completely discarded**. We are building a fresh, clean-slate RBAC architecture designed directly by Omkar. This document is the single source of truth.

---

## 1. Database & Infrastructure Context

- **Database Server:** PostgreSQL 16 container (`pms_uat_db`)
- **Active Database Name:** `pms_uat_clean`
- **Frontend Container:** `pms_uat_clean_frontend` (Port `39107`)
- **Backend Container:** `pms_uat_clean_backend` (Port `52815`)

---

## 2. Frontend Page: "Roles & Permissions"

- **File Path:** [`apps/frontend/src/modules/settings/pages/roles-permissions-page.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/modules/settings/pages/roles-permissions-page.tsx)
- **Route:** `/settings-security-roles`
- **UI Elements:**
  1. **RBAC Role Dropdown:** Loads active roles for assignment.
  2. **Hierarchical Catalog Table:**
     - **Module** (expandable row with chevron)
     - **Type** badge (`Module`, `Sub module`, `Widget`, `Tab`)
     - **Only view** radio button (`view`)
     - **View + Manage** radio button (`view-manage`)

---

## 3. Database Tables & Columns Mapping

Here is the exact mapping of what is currently connected:

### A. Role Selection Source
- **Database Table:** `auth.tbl_roles`
- **Backend API:** `GET /api/v1/users/roles` via `fetchRoles()`
- **Columns Used:**
  - `Id` (`uuid`) → Selected `roleId` in state
  - `Name` (`varchar(50)`) → System role identifier (e.g. `Admin`, `ProjectManager`)
  - `DisplayName` (`varchar(100)`) → Label shown in dropdown
  - `IsActive` (`boolean`) → Filter condition (`role.isActive == true`)
  - `IsSystemRole` (`boolean`)

### B. Access Catalog Hierarchy Sources
- **Backend API:** `GET /api/v1/catalogs/modules` via `fetchSidebarModules()`
- **Hierarchy Data:**

| Level / Type | Database Table | Key Columns Connected | Description |
| :--- | :--- | :--- | :--- |
| **Module** | `master.mst_modules` | `Id`, `Code`, `Name`, `Route`, `IconKey`, `SortOrder`, `IsActive` | Top-level sidebar items (Dashboard, Projects, Resources, Settings, etc.) |
| **Sub module** | `master.mst_submodules` | `Id`, `Code`, `Name`, `Route`, `SortOrder`, `IsActive`, `ModuleId`, `ParentId` | Sub-items (Customer Detail, Employee Directory, Exit Summary, Master, Roles & Permissions, Timesheets) |
| **Widget** | `master.mst_widgets` | `Id`, `Code`, `Name`, `SortOrder`, `IsActive`, `ParentId` | Dashboard cards/charts (Total Team Size, Team Utilization, etc.) |
| **Tab** | `master.mst_tabs` | `Id`, `Code`, `Name`, `SortOrder`, `IsActive`, `ModuleId`, `SubModuleId`, `TabId` | Screen tabs (Alerts, Notifications, Approvals, All Employees, etc.) |

### C. Permissions Storage Architecture (Approved: Option 1)
We will use a single, unified permission table: **`auth.tbl_role_permissions`**

- **Table Name:** `auth.tbl_role_permissions`
- **Columns:**
  - `Id` (`uuid`, PK, default `gen_random_uuid()`)
  - `RoleId` (`uuid`, FK → `auth.tbl_roles.Id` ON DELETE CASCADE)
  - `ItemId` (`uuid`, NOT NULL) — ID of the Module, Submodule, Widget, or Tab
  - `ItemType` (`varchar(20)`, NOT NULL) — `'module'`, `'submodule'`, `'widget'`, or `'tab'`
  - `CanView` (`smallint`, NOT NULL, default 0) — `0` = No view, `1` = View access
  - `CanManage` (`smallint`, NOT NULL, default 0) — `0` = No manage, `1` = View + Manage access
  - `CreatedAtUtc` (`timestamptz`, NOT NULL, default `now()`)
  - `UpdatedAtUtc` (`timestamptz`, NULL)
  - `CreatedBy` (`uuid`, NULL)
  - `UpdatedBy` (`uuid`, NULL)
- **Constraints & Indexes:**
  - `UQ_role_item_permissions`: Unique on `("RoleId", "ItemId")`
  - `CHK_can_view_binary`: `CHECK ("CanView" IN (0, 1))`
  - `CHK_can_manage_binary`: `CHECK ("CanManage" IN (0, 1))`
  - `CHK_manage_requires_view`: `CHECK ("CanManage" = 0 OR "CanView" = 1)`
  - Index on `RoleId` for high-performance role-permission lookups.

---

## 4. Radio Button Actions & Rules

### Core Rules for State:
- **Only view**: `CanView = 1, CanManage = 0`
- **View + Manage**: `CanView = 1, CanManage = 1`
- **No access / cleared**: `CanView = 0, CanManage = 0` (or record removed)

---

### A. Dashboard Module & Widgets Rules (First Target)

1. **Dashboard Module (`master.mst_modules`, Code = `'dashboard'`):**
   - **Nature:** Dashboard is purely informational; nothing inside the Dashboard module itself is "manageable".
   - **Manage Radio Button:** Disabled / not applicable for Dashboard.
   - **When View is ON (`CanView = 1`):**
     - The Dashboard module is **visible** in the application sidebar for that RBAC role.
     - The widgets under Dashboard become **enabled and modifiable** in the Roles & Permissions matrix.
   - **When View is OFF (`CanView = 0` / cleared):**
     - The Dashboard module is **hidden** (not visible) for that RBAC role.
     - All widgets under Dashboard are automatically turned **OFF** and disabled in the UI.

2. **Dashboard Widgets (`master.mst_widgets` under Dashboard):**
   - **Prerequisite:** Widgets can **only** be modified if the parent Dashboard module has **View** turned ON.
   - **Nature:** Widgets are display cards / charts (e.g., Total Team Size, Team Utilization Onsite/Offsite, Team Capacity, Resource Boarding Details); they only have a **View** toggle.
   - **When Widget View is ON (`CanView = 1`):**
     - The widget is **visible** on the Dashboard screen when logged in under that RBAC role.
   - **When Widget View is OFF (`CanView = 0` / cleared):**
     - The widget is **hidden / not visible** on the Dashboard for that RBAC role.

---

### B. Repository Module Rules (`master.mst_modules`, Code = `'repository'`)

1. **Module Overview:**
   - Organizational document management repository (Tech, PMS, IMP, SOPs, policies).
   - Supports both **Only view** (`CanView = 1, CanManage = 0`) and **View + Manage** (`CanView = 1, CanManage = 1`).

2. **When View is OFF (`CanView = 0` / cleared / no record):**
   - The Repository link is **hidden** from the sidebar navigation.
   - Direct navigation to `/repository` blocks access and redirects to `/access-denied` (or first permitted route).

3. **When "Only view" is ON (`CanView = 1, CanManage = 0`):**
   - The Repository link is **visible** in the sidebar navigation.
   - User has access to browse categories (All, Tech, PMS, IMP), search documents, preview documents (in-modal or new tab), download documents, inspect document activity logs and access summaries, and use pagination.
   - **Upload Document** button is **hidden**.
   - **Delete** button (trash icon in document rows) is **hidden**.

4. **When "View + Manage" is ON (`CanView = 1, CanManage = 1`):**
   - The Repository link is **visible** in the sidebar navigation.
   - User has full access to browse, search, preview, download, inspect logs, and use pagination.
   - **Upload Document** button is **visible and active** (opens file selector and upload category/department assignment modal).
   - **Delete** button is **visible and active** (opens delete confirmation dialog to remove document).

---

### C. Customer Module & Customer Detail Submodule Rules

- **Parent Module:** `master.mst_modules` (`Code = 'customers'`, `Id = 4e57fd71-b53e-43c0-862e-5698e09c0922`)
- **Submodule:** `master.mst_submodules` (`Code = 'customer-detail'`, `Name = 'Customer Detail'`, `Id = a7e6b014-9f4a-4d2c-87d2-431527ef9a10`, `Parent = Customer`)

1. **Hierarchy Rules:**
   - Submodule `Customer Detail` requires parent `Customer` view access to be viewable.
   - Submodule `Customer Detail` can only receive `View + Manage` if the parent `Customer` module has `View + Manage`.

2. **When View is OFF (`CanView = 0` / cleared / no record):**
   - Access to customer detail screens (`/customers/$clientId`) is blocked and redirects to `/access-denied`.

3. **When "Only view" is ON (`CanView = 1, CanManage = 0`):**
   - User can access and view the Customer Detail screen (`/customers/$clientId`).
   - User can view all customer information, sub-ventures, SPOC contacts, project lists, and KYC documents.
   - **Edit Customer** button is **hidden**.
   - **Change Engagement Manager (EM)** button is **hidden**.
   - **Change Sales Manager (SM)** button is **hidden**.

4. **When "View + Manage" is ON (`CanView = 1, CanManage = 1`):**
   - User has all viewing capabilities above.
   - **Edit Customer** button is **visible and active** (opens edit modal).
   - **Change Engagement Manager (EM)** button is **visible and active** (opens EM picker modal and allows reassignment).
   - **Change Sales Manager (SM)** button is **visible and active** (opens SM picker modal and allows reassignment).

---

### D. Project Module & Project Detail Submodule Rules

- **Parent Module:** `master.mst_modules` (`Code = 'projects'`, `Name = 'Projects'`, `Id = 168b1296-de6a-4f9e-a3b9-617b83863736`)
- **Submodule:** `master.mst_submodules` (`Code = 'project-detail'`, `Name = 'Project Detail'`, `Id = b8f7c125-0e5b-4e3d-98e3-542638fa0b21`, `Parent = Projects`)

- **Tabs under Project Detail (`master.mst_tabs` where `SubModuleId = b8f7c125-0e5b-4e3d-98e3-542638fa0b21`):**
  1. `Overview` (`Code = 'project-overview'`, `Id = c1a11111-0001-4000-8000-000000000001`)
  2. `WBS` (`Code = 'project-wbs'`, `Id = c1a11111-0001-4000-8000-000000000002`)
  3. `Team` (`Code = 'project-team'`, `Id = c1a11111-0001-4000-8000-000000000003`)
  4. `Tasks` (`Code = 'project-tasks'`, `Id = c1a11111-0001-4000-8000-000000000004`)
  5. `Health` (`Code = 'project-health'`, `Id = c1a11111-0001-4000-8000-000000000005`)
  6. `Invoices` (`Code = 'project-invoices'`, `Id = c1a11111-0001-4000-8000-000000000006`, *Hidden / Inactive*)

- **Sub-Tabs under Overview (`master.mst_tabs` where `TabId = c1a11111-0001-4000-8000-000000000001`):**
  1. `Senior Project Managers` (`Code = 'overview-senior-project-managers'`, `Id = c1a11111-0003-4000-8000-000000000002`)
  2. `Project Managers` (`Code = 'overview-project-managers'`, `Id = c1a11111-0003-4000-8000-000000000003`)
  3. `Team Leads` (`Code = 'overview-team-leads'`, `Id = c1a11111-0003-4000-8000-000000000004`)
  *(Note: `Budget` [Code = 'overview-budget'] is excluded / inactive as budget is not included)*

- **Sub-Tabs under Health (`master.mst_tabs` where `TabId = c1a11111-0001-4000-8000-000000000005`):**
  1. `Issues` (`Code = 'health-issues'`, `Id = c1a11111-0002-4000-8000-000000000001`)
  2. `Alerts` (`Code = 'health-alerts'`, `Id = c1a11111-0002-4000-8000-000000000002`)
  3. `Escalations` (`Code = 'health-escalations'`, `Id = c1a11111-0002-4000-8000-000000000003`)
  4. `Appreciation` (`Code = 'health-appreciation'`, `Id = c1a11111-0002-4000-8000-000000000004`)
  5. `Customer Engagement` (`Code = 'health-customer-engagement'`, `Id = c1a11111-0002-4000-8000-000000000005`)
  6. `Extension Request` (`Code = 'health-extension-request'`, `Id = c1a11111-0002-4000-8000-000000000006`)

1. **Hierarchy Rules:**
   - Submodule `Project Detail` requires parent `Projects` view access to be viewable.
   - Submodule `Project Detail` can only receive `View + Manage` if the parent `Projects` module has `View + Manage`.
   - Direct tabs under `Project Detail` require `Project Detail` view access to be viewable.
   - Sub-tabs under `Overview` require parent `Overview` tab view access to be viewable.
   - Sub-tabs under `Health` require parent `Health` tab view access to be viewable.
   - Any child tab can only receive `View + Manage` if its parent has `View + Manage`.

2. **When View is OFF (`CanView = 0` / cleared / no record):**
   - Access to project detail screens (`/projects/$projectId`) is blocked and redirects to `/access-denied`.

3. **When "Only view" is ON (`CanView = 1, CanManage = 0`):**
   - User can access and view the Project Detail screen (`/projects/$projectId`).
   - Read-only access to project overview, stages, tasks, timeline, and deliverables.

4. **When "View + Manage" is ON (`CanView = 1, CanManage = 1`):**
   - User has full access to view and manage project details, stages, PO documents, and assignments.

### E. Resources Module & Employee Detail Submodule Rules

- **Parent Module:** `master.mst_modules` (`Code = 'resources'`, `Name = 'Resources'`, `Id = 715f79ce-51ea-46d3-b95d-8318840f90a6`)
- **Parent Submodule:** `master.mst_submodules` (`Code = 'employee-directory'`, `Name = 'Employee Directory'`, `Id = 39dbd425-643b-47e9-9936-6bbae9ef5ef5`, `Parent = Resources`)
- **Child Submodule:** `master.mst_submodules` (`Code = 'employee-detail'`, `Name = 'Employee Detail'`, `Id = e8f7c125-0e5b-4e3d-98e3-542638fa0b23`, `Parent = Employee Directory`)

- **Tabs under Employee Detail (`master.mst_tabs` where `SubModuleId = e8f7c125-0e5b-4e3d-98e3-542638fa0b23`):**
  1. `Personal Information` (`Code = 'employee-personal-info'`, `Id = e1a11111-0001-4000-8000-000000000001`)
  2. `Organization Details` (`Code = 'employee-organization-details'`, `Id = e1a11111-0001-4000-8000-000000000002`)
  3. `Employment & Bond` (`Code = 'employee-employment-bond'`, `Id = e1a11111-0001-4000-8000-000000000003`)
  4. `Education & Experience` (`Code = 'employee-education-experience'`, `Id = e1a11111-0001-4000-8000-000000000004`)
  5. `PMO & EM Information` (`Code = 'employee-pmo-em-information'`, `Id = e1a11111-0001-4000-8000-000000000005`)
  6. `Activity Logs` (`Code = 'employee-activity-logs'`, `Id = e1a11111-0001-4000-8000-000000000006`)

1. **Hierarchy Rules:**
   - Submodule `Employee Detail` requires parent `Employee Directory` view access to be viewable.
   - Submodule `Employee Detail` can only receive `View + Manage` if `Employee Directory` has `View + Manage`.
   - Tabs under `Employee Detail` require `Employee Detail` view access to be viewable.
   - Any tab under `Employee Detail` can only receive `View + Manage` if `Employee Detail` has `View + Manage`.

2. **When View is OFF (`CanView = 0` / cleared / no record):**
   - Access to employee detail screens (`/employee-directory/$id`) is blocked and redirects to `/access-denied`.

3. **When "Only view" is ON (`CanView = 1, CanManage = 0`):**
   - User can access and view the Employee Profile screen (`/employee-directory/$id`) with allowed tabs.
   - `Edit Profile` and `Offboard Employee` action buttons are hidden.

4. **When "View + Manage" is ON (`CanView = 1, CanManage = 1`):**
   - User has full access to view employee profile, edit profile, and manage offboarding.

---

### F. My Team Module & Timesheets Submodule Rules

- **Parent Module:** `master.mst_modules` (`Code = 'my-team'`, `Name = 'My Team'`, `Id = 6055ce3c-b466-4354-ba9a-b4c309111e9d`)
- **Parent Submodule:** `master.mst_submodules` (`Code = 'timesheets'`, `Name = 'Timesheets'`, `Id = d67426d3-05df-4608-b8cf-c0ecfe698dc3`, `Parent = My Team`)

- **Tabs under Timesheets (`master.mst_tabs` where `SubModuleId = d67426d3-05df-4608-b8cf-c0ecfe698dc3`):**
  1. `My Timesheet` (`Code = 'my-timesheet'`, `Id = d67426d3-0001-4000-8000-000000000001`, `SortOrder = 10`)
  2. `Timesheet History` (`Code = 'timesheet-history'`, `Id = d67426d3-0001-4000-8000-000000000002`, `SortOrder = 20`)
  3. `Timesheet Approval` (`Code = 'timesheet-approval'`, `Id = d67426d3-0001-4000-8000-000000000003`, `SortOrder = 30`)

1. **Hierarchy Rules:**
   - Submodule `Timesheets` requires parent `My Team` view access to be viewable in navigation.
   - Tabs (`My Timesheet`, `Timesheet History`, `Timesheet Approval`) require parent `Timesheets` view access to be viewable.
   - Any tab under `Timesheets` can only receive `View + Manage` if parent `Timesheets` has `View + Manage`.

2. **When View is OFF (`CanView = 0` / cleared / no record):**
   - Access to timesheets screens (`/my-team/timesheets`) is blocked and redirects to `/access-denied`.

3. **When "Only view" is ON (`CanView = 1, CanManage = 0`):**
   - User can view timesheet data, history, and approval logs in read-only mode.

4. **When "View + Manage" is ON (`CanView = 1, CanManage = 1`):**
   - User has full access to log hours, submit timesheet drafts, approve/reject subordinate timesheets.

---

## 5. Persistence Workflow & Radio Button Behavior (Save & Reset)

- **Endpoints:**
  - `GET /api/v1/roles/{roleId}/permissions`: Loads all active permissions for the role.
  - `PUT /api/v1/roles/{roleId}/permissions`: Bulk upserts permissions into `auth.tbl_role_permissions`.
- **UI Behavior & Radio Button Fix:**
  - **Auto-load**: Selecting an RBAC role from the dropdown automatically fetches its existing permissions from the database.
  - **Reset Button**: Discards uncommitted radio button changes and reverts to the last saved state from the database.
  - **Save Changes Button**: Enabled whenever unsaved modifications exist. Commits changes directly to `auth.tbl_role_permissions` and displays a saved confirmation badge.
  - **Mutually Exclusive Radio States**: "Only view" (`access === "view"`) and "View + Manage" (`access === "view-manage"`) are strictly separated; selecting one unchecks the other cleanly.
  - **Single Click Selection & Deselection**: Clicking an unselected radio button instantly selects it. Clicking an already-selected radio button cleanly clears the row (`null`) without native browser desync or delayed save reflection.
  - **Save In-Flight Lock**: While saving is in progress (`saving = true`), radio buttons are disabled to prevent state race conditions.

