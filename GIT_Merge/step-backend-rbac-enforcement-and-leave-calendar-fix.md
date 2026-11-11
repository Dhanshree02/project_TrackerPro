# Merge Context: Backend RBAC API Enforcement, Project Detail Permissions & Leave Calendar Fix

- **Branch:** `uat_clean10`
- **Date:** 2026-11-11
- **Author:** Omkar Gaikwad / AI Pair Programming

---

## 🎯 Purpose of Changes
1. **Strict Backend-Enforced RBAC (`[RequireRbac]`)**:
   - Frontend-only permission restrictions are not enough; all sensitive write/manage endpoints across Projects, Drafts, Customers, Repository, Employees, and Timesheets are now guarded by a high-priority action filter that verifies permissions directly in PostgreSQL (`auth.tbl_role_permissions`) and returns `403 Forbidden` (`FORBIDDEN`) on unauthorized access.
   - In-memory caching with 5-minute TTL per role is invalidated immediately upon permission updates in Settings.
   - `Admin` role automatically bypasses all restrictions.

2. **Roles & Permissions - Project Detail Submodule & Child Tabs**:
   - Fixed `Project Detail` submodule row in Settings -> Roles & Permissions so that it is no longer restricted to view-only.
   - Enabled `View + Manage` radio button for `Project Detail`.
   - Fixed child tabs under `Project Detail` (`Overview`, `WBS`, `Team`, `Tasks`, `Health` and their nested subtabs) so their `View + Manage` radio buttons activate cleanly when `Project Detail` is granted `View + Manage`.

3. **Granular Project Tab Permissions (Frontend & Backend)**:
   - **Projects Root:** View only hides "New Project" and "Drafts" buttons and blocks `/projects/new` onboarding route.
   - **WBS Tab:** View-only disables/hides edit service, assign PM/SPM, collection status, validation status, billing status, ready to start, and escalation. View+Manage grants full update access.
   - **Team Tab:** View-only hides "Add Team Member" button. View+Manage allows member allocation and removal.
   - **Tasks Tab:** View-only hides "Add Task", "Edit Task", and "Assign Task". View+Manage allows full task management.
   - **Overview Tab:** View-only disables Senior Project Managers, Project Managers, and Team Leads assignment controls. View+Manage allows modifying leadership assignments.
   - **Project Stage:** Restored display and tracking.

4. **Health Tab & Subtabs RBAC Enforcement (Frontend & Backend)**:
   - **Roles & Permissions Matrix:**
     - `Alerts` and `Escalation` subtabs are marked view-only (no "View + Manage" radio button) since they contain monitoring data and no management workflows on this tab.
     - `Issues`, `Appreciation`, `Customer Engagement`, and `Extension Request` display both "Only view" and "View + Manage" radio buttons.
   - **Backend API Endpoints (`[RequireRbac]`):**
     - `health-issues` (Manage): `POST /api/v1/projects/{projectId}/issues`, `POST /api/v1/projects/issues` (Direct).
     - `health-appreciation` (Manage): `POST /api/v1/projects/{projectId}/appreciations`.
     - `health-customer-engagement` (Manage): `POST /api/v1/projects/{projectId}/interviews`, `PUT /api/v1/projects/{projectId}/interviews/{interviewId}`, `POST /api/v1/projects/{projectId}/additional-requirements`, `POST /api/v1/projects/{projectId}/additional-requirements/{id}/approve`, `POST /api/v1/projects/{projectId}/additional-requirements/{id}/reject`, `POST /api/v1/projects/{projectId}/additional-requirements/{id}/action`, `POST /api/v1/projects/{projectId}/additional-requirements/{id}/comments`.
     - `health-extension-request` (Manage): `POST /api/v1/projects/{projectId}/extension-requests`, `POST /api/v1/projects/{projectId}/extension-requests/{requestId}/approve`, `POST /api/v1/projects/{projectId}/extension-requests/{requestId}/reject`, `POST /api/v1/projects/{projectId}/extension-requests/{requestId}/action`, `POST /api/v1/projects/{projectId}/extension-requests/{requestId}/comments`.
   - **Frontend UI Gating:**
     - `Issues`: "Raise Issues Alerts" button is hidden when role has only View access.
     - `Appreciation`: "Appreciation" button is hidden when role has only View access.
     - `Customer Engagement`: "Schedule Interview", "Log Requirement", and interview "Edit Result" / "Reschedule" buttons are hidden when role has only View access. Discussion comment input is disabled in view-only mode.
     - `Extension Request`: "Extension Request" button and "Review Detail" button are hidden when role has only View access.
     - Dynamic Subtab Tabs: Health subtabs are shown only if the user has `canView` for that respective subtab.

5. **Team Dashboard RBAC Enforcement (3 Dedicated Subtabs: My Team, My Reportees, All Employees)**:
   - **3 Dedicated, Permanent Subtabs (Option A):**
     - `[ My Team ]` (`scope: "team"`, code: `"my-team"`): Shows colleagues/squad under the same Reporting Manager (`e.ReportingManagerId == caller.ReportingManagerId`). Available to every employee. Strictly `viewOnly` for peers (cells locked, schedule/allocation buttons hidden, no editing peers).
     - `[ My Reportees ]` (`scope: "reportees"`, code: `"my-reportees"`): Shows direct reports (`e.ReportingManagerId == caller.Id`). For managers, grants full schedule and shift management controls (`canManage("my-reportees")`). For individual contributors with 0 reportees, displays friendly empty state: "No employees report to you yet."
     - `[ All Employees ]` (`scope: "all"`, code: `"all-employees"`): Shows the company-wide employee directory, governed by `all-employees` RBAC permissions.
   - **Resolution of Tab Label Glitch (Static & Permanent Labels):**
     - Tab labels are fixed and permanent (`My Team`, `My Reportees`, `All Employees`).
     - Switching between rosters (e.g. from `My Team` to `All Employees` and back) never flips or reverts tab names.
     - Automatically defaults individual contributors (0 direct reports) to the "My Team" view so they immediately see their squad.
     - Automatically defaults managers (who have direct reports) to the "My Reportees" view while providing a 1-click tab to view their peer team under their director/VP.
   - **Strict Peer Security Boundary (100% View-Only for Everyone on "My Team")**:
     - The `My Team` tab (`roster === "team"`) is strictly locked to `viewOnly = true` for **all users, including Admin and Dhanshree**.
     - Management buttons (`CalendarCog`, `UserPlus`) are completely hidden.
     - Day cells are strictly locked (`readOnly = true`); clicking a day cell does not mount or open any attendance/shift edit popovers.
     - Handlers (`handleCellToggle`, `handleAttendanceSelect`, `handleShiftSelect`, `handleApplyWeek`, `writeShift`, `handleSaveMemberSchedule`) immediately exit if `roster === "team"`.
     - In the backend (`RequireTeamMemberAsync`), mutating schedules or shifts strictly requires direct management (`e.ReportingManagerId == caller.Id`), guaranteeing that peers can NEVER modify another peer's schedule or shifts even if they hold elevated manage permissions elsewhere.
   - **Backend API Endpoints (`[RequireRbac]` & Scope Scoping):**
     - `GET /api/v1/my-team/calendar?from=...&to=...&scope=[team|reportees|all]`:
       - Accepts explicit `scope` query parameter.
       - Returns `HasDirectReports` boolean in `TeamCalendarDto` so frontend dynamically knows caller's direct report status.
       - `scope=team` resolves peers under caller's reporting manager with `isPeerTeam: true`.
       - `scope=reportees` resolves direct reports with `isPeerTeam: false`.
       - `scope=all` resolves all active employees across the company.
     - `PUT /api/v1/my-team/days`: Guarded with `[RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.Manage, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees)]`.
     - `PUT /api/v1/my-team/members/{employeeId:guid}/schedule`: Guarded with `[RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.Manage, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees)]`.

6. **Team Dashboard & Holiday Calendar Database Fix**:
   - Resolved runtime error: `42P01: relation "master.mst_leave_calendar" does not exist` on `/team-dashboard`.
   - Added missing columns (`Tag`, `Color`, `Description`), constraints, and indexes (`IX_mst_leave_calendar_HolidayDate`, `IX_mst_leave_calendar_Year`).
   - Seeded all 15 company holidays for 2026 across all databases (`pms_uat_clean`, `pms_uat`, `pms_development`, `pms_deployment`, `trackerpro`).
   - Synchronized schema and `COPY` data in `database/pms_uat.sql` and `database/trackerpro-uat.sql`.

7. **Resolution of "You do not have permission to view this section" (Unconfigured Roles & Lookup Dependencies)**:
   - **Frontend/Backend Parity for Unconfigured Roles:**
     - In `auth.tbl_roles`, 25 out of 29 roles (e.g. `Consulting-Team member`, `Intern`, etc.) did not yet have explicit rows configured in `auth.tbl_role_permissions`.
     - Frontend `permissions.tsx` defaults `canView` to `true` when `permissionMap.size === 0` to allow newly created or unmigrated roles basic viewing access.
     - Backend `RbacAuthorizationService.cs` was returning `false` for everything when `perms.Count == 0`, causing backend 403 Forbidden toasts on every route navigation.
     - Updated `RbacAuthorizationService.cs` to align with the frontend: unconfigured roles default `View` to allowed (except strict security items: `repository`, `settings`, `master`, `roles-permissions`), while `Manage` remains strictly blocked (`false`) until explicitly configured by Admin in Settings.
   - **Cross-Module Lookup Permissions:**
     - `ClientsController.cs` (`GET /api/v1/clients` and `GET /api/v1/clients/{id}`): Added fallback RBAC codes `"projects"`, `"project-detail"` so users viewing projects can load client lookups without requiring direct `customers` module permission.
     - `EmployeesController.cs` (`GET /api/v1/employees` and `GET /api/v1/employees/{idOrCode}`): Added fallback RBAC codes `"projects"`, `"project-detail"`, `"team-dashboard"`, `"my-reportees"`, `"all-employees"`, `"timesheets"`, `"action-centre"`, `"action-center"` so employee dropdowns work seamlessly across the entire application without requiring explicit `resources` / `employee-directory` permission.

8. **Action Center RBAC Enforcement (Bucket List, Approvals, Alerts, Notifications)**:
   - **Bucket List:**
     - User specification: Identical full access for both "Only view" and "View + Manage".
     - Backend: All bucket list endpoints (`GetBucketList`, `GetBucketTaskById`, `StartTimer`, `PauseTimer`, `StopTimer`, `CompleteTask`, `UpdateStatus`, `SyncAssignments`) require `RbacAccessType.View` (`[RequireRbac("bucket-list", RbacAccessType.View, "action-centre", "action-center")]`).
     - Frontend: Full timer, status change, and task actions remain available to all users with view access.
   - **Approvals:**
     - User specification: "View + Manage will have access to Actions this column, only view will not have access to it."
     - Backend: Read endpoints (`GetApprovals`, `GetPendingAllocationApprovals`) require `RbacAccessType.View`; mutating action endpoint (`TakeAllocationApprovalAction`) requires `RbacAccessType.Manage`. Fallbacks added to `ProjectsController.cs` for extension and additional requirement approvals so managers with Approvals access can act seamlessly.
     - Frontend: In the Approvals table, the "Actions" column header (`<th>Actions</th>`) and row action cell (`<td><button>View</button></td>`) are only rendered if `canManageApprovals`. Inside the review modal, action buttons (`Hold`, `Request Changes`, `Reject`, `Approve`) and the mandatory comments textarea are only rendered if `canManageApprovals`.
   - **Alerts:**
     - User specification: "View + Manage will have access to Actions this column, only view will not have access to it."
     - Backend: Read endpoints (`GetAlerts`, `DownloadAlertAttachment`) require `RbacAccessType.View`; mutating endpoint (`UpdateAlertGovernance`) requires `RbacAccessType.Manage`.
     - Frontend: In the Alerts table, the "Actions" column header (`<th>Actions</th>`) and row action cell (`<td><button>Review details</button></td>`) are only rendered if `canManageAlerts`. Inside the alert review modal, editing controls, status selectors, and action buttons (`Approve`, `Reject`, `Save Governance Changes`) are hidden/disabled if `!canManageAlerts`, showing only a "Close" button.
   - **Notifications:**
     - User specification: Kept configurable with both "Only view" and "View + Manage" options in Settings -> Roles & Permissions.
     - Backend: `GetNotifications` and `MarkNotificationAsRead` require `RbacAccessType.View`.
   - **Action Center Tab Visibility:**
     - Replaced hardcoded role arrays (`employeeTabCodes`, `salesTabCodes`, `pmoTabCodes`) with dynamic RBAC gating: `visibleTabs = actionTabs.filter(tab => canView(tab.code))`.
     - Added graceful empty state when a user has no permitted Action Center tabs.

---

## 🟢 Files & Features to MERGE (Safe & Intended)

### 1. Backend Authorization & RBAC Infrastructure
- **`apps/backend/Infrastructure/Authorization/RbacAccessType.cs`** *(New)*:
  - Enum defining access levels: `View`, `Manage`.
- **`apps/backend/Infrastructure/Authorization/RbacCatalogCodes.cs`** *(New)*:
  - Strongly typed catalog code constants mapping modules, submodules, and tabs to database catalog GUIDs.
- **`apps/backend/Infrastructure/Authorization/IRbacAuthorizationService.cs`** & **`RbacAuthorizationService.cs`** *(New)*:
  - Service checking role permissions against `auth.tbl_role_permissions`.
  - In-memory caching with 5-minute TTL per role.
  - Method `InvalidateRoleCache(Guid roleId)` to bust cache on permission save.
  - Automatic `Admin` role bypass.
- **`apps/backend/Infrastructure/Authorization/RequireRbacAttribute.cs`** *(New)*:
  - Action filter attribute (`IAsyncActionFilter, IOrderedFilter`) with `Order = -100`.
  - Runs before validation filters and returns standard `403 Forbidden` (`FORBIDDEN`).
- **`apps/backend/Configuration/DependencyInjectionExtensions.cs`**:
  - Registered `AddMemoryCache()` and `IRbacAuthorizationService` scoped service.
- **`apps/backend/Modules/Users/Services/UserService.cs`**:
  - Calls `_rbacAuthService.InvalidateRoleCache(roleId)` in `UpdateRolePermissionsAsync` to invalidate cached permissions instantly.

### 2. Backend Controllers Enforced with `[RequireRbac]`
- **`apps/backend/Modules/Projects/Controllers/ProjectsController.cs`**:
  - `POST /api/v1/projects` (Create project): `[RequireRbac(RbacCatalogCodes.Projects, RbacAccessType.Manage)]`
  - `PUT /api/v1/projects/{id}` & `PATCH /api/v1/projects/{id}`: `[RequireRbac(RbacCatalogCodes.ProjectDetail, RbacAccessType.Manage)]`
  - Assign SPM/PM/TL, WBS status updates, team member assignments, task creation/assignments enforced with appropriate catalog codes.
  - **Health Subtabs Backend Protection**:
    - `health-issues` (Manage): `POST /api/v1/projects/{projectId}/issues`, `POST /api/v1/projects/issues` (Direct).
    - `health-appreciation` (Manage): `POST /api/v1/projects/{projectId}/appreciations`.
    - `health-customer-engagement` (Manage): `POST /api/v1/projects/{projectId}/interviews`, `PUT /api/v1/projects/{projectId}/interviews/{interviewId}`, `POST /api/v1/projects/{projectId}/additional-requirements`, `POST /api/v1/projects/{projectId}/additional-requirements/{id}/approve`, `POST /api/v1/projects/{projectId}/additional-requirements/{id}/reject`, `POST /api/v1/projects/{projectId}/additional-requirements/{id}/action`, `POST /api/v1/projects/{projectId}/additional-requirements/{id}/comments`.
    - `health-extension-request` (Manage): `POST /api/v1/projects/{projectId}/extension-requests`, `POST /api/v1/projects/{projectId}/extension-requests/{requestId}/approve`, `POST /api/v1/projects/{projectId}/extension-requests/{requestId}/reject`, `POST /api/v1/projects/{projectId}/extension-requests/{requestId}/action`, `POST /api/v1/projects/{projectId}/extension-requests/{requestId}/comments`.
- **`apps/backend/Modules/Projects/Controllers/ProjectDraftsController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.Projects, RbacAccessType.Manage)]` on creating/updating drafts.
- **`apps/backend/Modules/Customers/Controllers/ClientsController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.Customers, RbacAccessType.Manage)]` on creating and modifying clients.
  - `[RequireRbac("customers", RbacAccessType.View, "projects", "project-detail")]` on client listings and lookups.
- **`apps/backend/Modules/Repository/Controllers/RepositoryController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.Repository, RbacAccessType.Manage)]` on document upload and deletion.
- **`apps/backend/Modules/Resources/Controllers/EmployeesController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.EmployeeDirectory, RbacAccessType.Manage)]` on creating employees, bulk upload, editing profiles, and offboarding.
  - `[RequireRbac("employee-directory", RbacAccessType.View, "resources", "projects", "project-detail", "team-dashboard", "my-reportees", "all-employees", "timesheets", "action-centre", "action-center")]` on employee listings and dropdown lookups.
- **`apps/backend/Modules/Timesheets/Controllers/TimesheetsController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.Timesheets, RbacAccessType.Manage)]` on approving timesheets.
- **`apps/backend/Modules/MyTeam/Controllers/MyTeamController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.Manage)]` on `PUT /api/v1/my-team/days` and `PUT /api/v1/my-team/members/{employeeId}/schedule`.
  - `[RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.View)]` on `GET /api/v1/my-team/calendar` and `GET /api/v1/my-team/on-floor-roles`.
- **`apps/backend/Middleware/DevelopmentAuthBypassMiddleware.cs`**:
  - Populates authenticated user claims and active role identity in development for consistent RBAC filtering.

- **`apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`**:
  - Decorated class with `[RequireRbac("action-centre", RbacAccessType.View, "action-center")]`.
  - Decorated Bucket List endpoints with `[RequireRbac("bucket-list", RbacAccessType.View, "action-centre", "action-center")]` (both view and view+manage have full access).
  - Decorated Approvals endpoints with `[RequireRbac("approvals", RbacAccessType.View, "action-centre", "action-center")]` for reads, and `[RequireRbac("approvals", RbacAccessType.Manage)]` for `allocation-approvals/{id}/action`.
  - Decorated Alerts endpoints with `[RequireRbac("alerts", RbacAccessType.View, "action-alerts", "action-centre", "action-center")]` for reads, and `[RequireRbac("alerts", RbacAccessType.Manage, "action-alerts")]` for `alerts/{id}/governance`.
  - Decorated Notifications endpoints with `[RequireRbac("notifications", RbacAccessType.View, "action-centre", "action-center")]`.

### 3. Frontend Roles & Permissions & UI Gating
- **`apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`**:
  - Dynamically filtered Action Center tabs by `canView(tab.code)` with graceful empty state fallback.
  - In `ApprovalsTab`: gated table "Actions" column (`<th>` and `<td><button>View</button></td>`) behind `canManageApprovals`. Inside modal, gated action comment box and action buttons behind `canManageApprovals`.
  - In `AlertsTab`: gated table "Actions" column (`<th>` and `<td><button>Review details</button></td>`) behind `canManageAlerts`. Inside modal, gated status switcher and update/approve/reject buttons behind `canManageAlerts` (rendering only a "Close" button for view-only).
- **`apps/frontend/src/modules/settings/pages/roles-permissions-page.tsx`**:
  - Removed `isProjectDetail` from `isViewOnlyRow`.
  - Restored `View + Manage` radio button for `Project Detail`.
  - Restored hierarchical cascade so child tabs under `Project Detail` (`Overview`, `WBS`, `Team`, `Tasks`, `Health`) allow selecting `View + Manage`.
  - Marked `Alerts` and `Escalation` under `Health` as view-only rows (hides the inapplicable `View + Manage` radio button).
  - Maintained `Issues`, `Appreciation`, `Customer Engagement`, and `Extension Request` as configurable with both `Only view` and `View + Manage`.
- **`apps/frontend/src/lib/permissions.tsx`**:
  - Added helper permission checks: `canManageProjects()`, `canManageProjectDetail()`, `canManageWBS()`, `canManageTeam()`, `canManageTasks()`, `canManageOverview()`.
- **`apps/frontend/src/modules/projects/pages/projects-list-page.tsx`**:
  - Hides "New Project" and "Drafts" action buttons when role has only View access to Projects.
- **`apps/frontend/src/modules/projects/pages/project-onboarding-page.tsx`**:
  - Blocks navigating to project onboarding wizard if role lacks Manage access to Projects.
- **`apps/frontend/src/modules/projects/pages/project-detail-page.tsx`**:
  - Stage indicator display restored.
  - Buttons and inputs in WBS, Team, Tasks, and Overview tabs conditionally hidden or disabled based on specific tab access.
  - **Health Subtabs Action Gating**:
    - `Issues`: "Raise Issues Alerts" button gated by `canManage("health-issues")`.
    - `Appreciation`: "Appreciation" button gated by `canManage("health-appreciation")`.
    - `Customer Engagement`: "Schedule Interview", "Log Requirement", and interview "Edit Result" / "Reschedule" buttons gated by `canManage("health-customer-engagement")`.
    - `Extension Request`: "Extension Request" and "Review Detail" buttons gated by `canManage("health-extension-request")`.
    - Subtab navigation tabs dynamically rendered based on `canView` for each subtab.
- **`apps/frontend/src/modules/my-team/index.tsx`**:
  - Gated Schedule & Holidays (`CalendarCog` button) behind `View + Manage` on the active roster tab (`!viewOnly`). Hidden in view-only.
  - Gated Request Allocation (`UserPlus` button) behind `View + Manage` on the active roster tab (`!viewOnly`). Hidden in view-only.
  - Calendar day cells set to `readOnly = true` (`isLocked = true`) when role has only View access to the active roster, preventing shifts and attendance status modification.
  - Handlers (`handleSaveMemberSchedule`, `writeShift`, `handleCellToggle`, `handleAttendanceSelect`, `handleShiftSelect`) enforce `canManageActiveRoster` checks before mutating.
  - Roster tabs (`My Reportees`, `All Employees`) dynamically filtered by `canView(tab.code)`.
  - Added empty state if user has no view access to any roster.
- **`apps/frontend/src/routes/my-team.index.tsx`**:
  - Direct route guard checks `canView("team-dashboard")`, `canView("my-team")`, `canView("my-reportees")`, or `canView("all-employees")` (with Admin/Dhanshree bypass) and redirects unauthorized users to `/`.

### 4. Team Dashboard "My Team" Tab in RBAC Catalog
- **`master.mst_tabs` Database Table**:
  - Inserted "My Team" tab row: `Id = 9854b7f3-0001-4000-8000-000000000001`, `Code = my-team`, `Name = My Team`, `SortOrder = 5`, `SubModuleId = 9854b7f3-8e7e-4ecb-864f-f2533ff295f9` (`team-dashboard`).
  - Added to `database/pms_uat.sql` and `database/trackerpro-uat.sql`.
- **`apps/frontend/src/modules/settings/pages/roles-permissions-page.tsx`**:
  - Enforced `isMyTeamTab` as view-only (`isViewOnlyRow`), so only "Only view" is configurable in the matrix (preserving peer schedule protection).
- **`apps/frontend/src/lib/permissions.tsx` & `apps/frontend/src/modules/my-team/index.tsx`**:
  - Registered `9854b7f3-0001-4000-8000-000000000001` under parent `team-dashboard` without conflicting with top-level `my-team` module.
  - Added support for `canView("9854b7f3-0001-4000-8000-000000000001")` in `visibleRosterTabs` and route guards.
- **`context/` Knowledge Repository**:
  - Created structured repository context under `context/` with subfolders (`rbac/`, `modules/`, `database/`, `environment/`) and master `INDEX.md` for fast, zero-delay memory recall.

### 5. Database Dumps & Schema
- **`database/pms_uat.sql` & `database/trackerpro-uat.sql`**:
  - Added `master.mst_leave_calendar` table definition with `Tag`, `Color`, `Description`.
  - Added `IX_mst_leave_calendar_Year` index.
  - Added `COPY master.mst_leave_calendar` data block with 15 company holidays for 2026.
- **`scripts/create-leave-calendar-table.sql`**:
  - Reference SQL script used to initialize `master.mst_leave_calendar` and 2026 holiday entries.

---

## 🔴 Features to Leave UNTOUCHED / DO NOT Overwrite

- **Existing Authentication Token Service**: Do not modify `apps/backend/Modules/Auth/Services/TokenService.cs` or baseline password hashing logic.
- **Admin Full Access Bypass**: Admin role must remain fully bypassed across all endpoints and UI modules without requiring explicit permissions.
- **Database Connection Strings in Dev**: Keep local environment secrets and development connection strings untouched.

---

## 🧪 Verification Summary
- **Backend Authorization Tests**: Verified directly via `curl` against Docker backend on port 52815; unauthorized roles receive HTTP 403 Forbidden with `{ "code": "FORBIDDEN" }`, while authorized roles and Admin receive HTTP 200 OK.
- **Health Tab RBAC Endpoints**: Enforced across 15 mutating endpoints for issues, appreciations, customer engagement interviews & additional requirements, and extension requests.
- **Team Dashboard Backend RBAC**: Verified `PUT /api/v1/my-team/days` and `PUT /api/v1/my-team/members/{id}/schedule` return HTTP 403 Forbidden (`FORBIDDEN`) for view-only/unauthorized roles, and allow authorized roles / Admin.
- **Team Dashboard Calendar**: Verified `GET /api/v1/my-team/calendar?from=2026-11-01&to=2026-11-30` returns 200 OK with company holidays.
- **Frontend Test Suite**: All 128 tests in `apps/frontend` pass without errors (`npm test --prefix apps/frontend`).
- **Production Frontend Build**: `npm run build --prefix apps/frontend` completes cleanly with 0 errors.
- **Docker Production Images**: Rebuilt both `pms-backend:uat-clean` and `pms-frontend:uat-clean` containers and verified running healthy on respective ports.

