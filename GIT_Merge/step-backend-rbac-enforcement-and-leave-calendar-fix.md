# Merge Context: Backend RBAC API Enforcement, Project Detail Permissions, Team Dashboard Governance & Userwise Role Access

- **Branch:** `uat_clean10`
- **Date:** 2026-11-12
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
   - **3 Dedicated, Permanent Subtabs:**
     - `[ My Team ]` (`scope: "team"`, code: `"my-team"`): Shows colleagues/squad under the same Reporting Manager (`e.ReportingManagerId == caller.ReportingManagerId`). Available to every employee. Strictly `viewOnly` for peers (cells locked, schedule/allocation buttons hidden, no editing peers).
     - `[ My Reportees ]` (`scope: "reportees"`, code: `"my-reportees"`): Shows direct reports (`e.ReportingManagerId == caller.Id`). For managers, grants full schedule and shift management controls (`canManage("my-reportees")`). For individual contributors with 0 reportees, the tab is hidden dynamically.
     - `[ All Employees ]` (`scope: "all"`, code: `"all-employees"`): Shows company-wide roster, governed by `all-employees` RBAC permissions (with request allocation, workloads, and task view options).
   - **Strict Peer Security Boundary (100% View-Only for Everyone on "My Team")**:
     - The `My Team` tab (`roster === "team"`) is strictly locked to `viewOnly = true` for **all users, including Admin and Dhanshree**.
     - Management buttons (`CalendarCog`, `UserPlus`) are completely hidden.
     - Day cells are strictly locked (`readOnly = true`); clicking a day cell does not mount or open any attendance/shift edit popovers.
     - Handlers (`handleCellToggle`, `handleAttendanceSelect`, `handleShiftSelect`, `handleApplyWeek`, `writeShift`, `handleSaveMemberSchedule`) immediately exit if `roster === "team"`.
     - In backend (`RequireTeamMemberAsync`), mutating schedules or shifts strictly requires direct management (`e.ReportingManagerId == caller.Id`), guaranteeing peers cannot modify another peer's schedule or shifts even if they hold elevated manage permissions elsewhere.
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

7. **Resolution of Unconfigured Roles & Lookup Dependencies**:
   - **Frontend/Backend Parity for Unconfigured Roles:**
     - Frontend `permissions.tsx` defaults `canView` to `true` when `permissionMap.size === 0` to allow newly created or unmigrated roles basic viewing access.
     - Updated `RbacAuthorizationService.cs` to align with frontend: unconfigured roles default `View` to allowed (except strict security items: `repository`, `settings`, `master`, `roles-permissions`), while `Manage` remains strictly blocked (`false`) until explicitly configured by Admin in Settings.
   - **Cross-Module Lookup Permissions:**
     - `ClientsController.cs` (`GET /api/v1/clients` and `GET /api/v1/clients/{id}`): Added fallback RBAC codes `"projects"`, `"project-detail"` so users viewing projects can load client lookups without requiring direct `customers` module permission.
     - `EmployeesController.cs` (`GET /api/v1/employees` and `GET /api/v1/employees/{idOrCode}`): Added fallback RBAC codes `"projects"`, `"project-detail"`, `"team-dashboard"`, `"my-reportees"`, `"all-employees"`, `"timesheets"`, `"action-centre"`, `"action-center"` so employee dropdowns work seamlessly across the entire application without requiring explicit `resources` / `employee-directory` permission.

8. **Action Center RBAC Enforcement (Bucket List, Approvals, Alerts, Notifications)**:
   - **Bucket List:**
     - Full access for both "Only view" and "View + Manage" (`[RequireRbac("bucket-list", RbacAccessType.View, "action-centre", "action-center")]`).
   - **Approvals:**
     - Read endpoints require `RbacAccessType.View`; mutating action endpoint (`TakeAllocationApprovalAction`) requires `RbacAccessType.Manage`.
     - In frontend table, "Actions" column and modal review actions (`Hold`, `Request Changes`, `Reject`, `Approve`, and comments) are rendered only if `canManageApprovals`.
   - **Alerts:**
     - Read endpoints require `RbacAccessType.View`; mutating endpoint (`UpdateAlertGovernance`) requires `RbacAccessType.Manage`.
     - In frontend table, "Actions" column and review modal actions (`Approve`, `Reject`, `Save Governance Changes`) are rendered only if `canManageAlerts` (view-only shows "Close" button).
   - **Notifications:**
     - Configurable with both "Only view" and "View + Manage" options.
   - **Action Center Tab Visibility:**
     - Dynamically filtered tabs by `canView(tab.code)` with graceful empty state fallback.

9. **Locking RBAC Baseline Defaults (`DefaultCanView` & `DefaultCanManage`)**:
   - Added `DefaultCanView` and `DefaultCanManage` columns in `auth.tbl_role_permissions`.
   - Locked and seeded the official default baseline permissions for all 28 non-admin roles based on baseline matrix specifications.
   - Added "Reset to Baseline" button in Rolewise Access to instantly restore any role's permissions back to its locked baseline.
   - Backend endpoint `POST /api/v1/roles/{id}/permissions/reset-default` updates `can_view` and `can_manage` to match `default_can_view` and `default_can_manage` and invalidates the cached permissions.

10. **My Team Dashboard Refinements (Reportee Gating, Admin Free Date Editing & Filter Cleanup)**:
    - **Reportee Tab Dynamic Gating**:
      - If an employee has no reportees (`hasDirectReports === false`), or if their role does not have access to view reportees, the `My Reportees` tab is hidden dynamically.
    - **Admin Past & Holiday Date Editing**:
      - For Admin role (and Super Admin / Dhanshree), all dates (including past dates and official company holidays) are editable on Team Dashboard so admins can retrospectively adjust schedules/shifts when genuine exceptions or missouts occur.
    - **Filter Cleanup**:
      - Removed redundant dropdown filters beside the search bar on `My Team -> My Team` tab.
    - **Strict Schedule & Shift Editing Boundary**:
      - Resource allocation and editing schedules/time shifts are exclusively restricted to the `My Reportees` tab. View-only on `My Team` tab. On `All Employees`, only request allocation, workloads, and tasks options are available.

11. **Userwise Access in Roles & Permissions (`/settings-security-roles`)**:
    - **Internal Tabs Switcher**:
      - Added switch bar with two tabs: **Rolewise Access** (matrix configuration) and **Userwise Access** (employee role assignment).
      - Styled with active blue tab design (`bg-blue-600 text-white shadow-xs`) with `ShieldCheck` and `Users` icons, matching Employee Directory and My Team.
      - Removed duplicate repeating `Roles & Permissions` header title and description block above the switch bar.
    - **Userwise Access Table**:
      - Displays all employees with Employee Name (avatar, code, work email), Department, Original RBAC Role, Assigned RBAC Role (department-restricted dropdown), and Action (Reset button).
      - Dropdown strictly filters role options to the employee's specific department using canonical department role mappings across all 10 departments (`CanonicalDepartmentRoles`).
      - Super Admin role is protected and locked from modification.
      - "Switched from original" indicator badge with animated pulse when an employee's role differs from baseline.
    - **Confirmation Windows / Modals**:
      - Confirmation dialog triggered upon selecting a new role from the dropdown before applying any change. Shows employee preview card, current $\rightarrow$ new role transition box, explanatory text, and Cancel / Confirm Switch buttons.
      - Individual Reset button on each switched row prompts with a confirmation modal before reverting the employee to original role.
    - **Overall Reset**:
      - Added an "Overall Reset" action button in the filter header bar with a badge indicating the count of switched employees.
      - Disabled when 0 employees are switched.
      - Prompts with a confirmation modal and atomically reverts all switched employees back to their original department baseline roles via `POST /api/v1/roles/user-access/reset-all`.
    - **Pagination Dropdown Fix**:
      - Supports all page size options: 10, 15, 25, 50, 100, and "All" (`PAGE_SIZE_ALL = 0`).
      - Fixed frontend API `perPage: 0` query param handling and backend clamping (`perPage <= 0 ? 1000 : Math.Clamp(perPage, 1, 1000)`).
      - Utilizes client-side slicing (`paginateSlice`, `paginationRange`, `totalPageCount`) for instant, lag-free paging, sorting, and filtering over the complete employee roster.

12. **Header Financial Year App-Wide Filter & Global Search (Separate Features)** (2026-11-12):
    - The calendar beside the header search is the financial year for the whole app (April–March). One year or several can be selected. **All years** clears it. The choice is kept in `localStorage` (`pulse-financial-years`) and shared through `FinancialYearProvider`.
    - Search does not use that calendar. It still finds employees, TK IDs, customers, sub-ventures, projects, tasks, and repository documents.
    - Lists follow every selected year: projects (start/end overlap, or the year in the WBS id), customers and their project counts, customer-detail projects, employee directory (still employed during that year, using joining date through today), exit summary (last working day or exit date in the year), repository documents (created or last updated in the year), and the timesheet project list.
    - Dashboard graphs follow the latest selected year. A past year moves the rolling window to the last three months of that year (`FinancialQuarter.Resolve`).
    - Task lookup for search is `GET /api/v1/projects/task-search`. Customer search also matches `SubVentureCode`.
    - A task result opens that project’s Tasks tab (`#tasks`). A sub-venture opens the customer with that sub-venture selected (`#sv=`). A document opens Repository with that file name in the search (`#q=`).
    - Top-right toasts stay for 3 seconds (`toastOptions.duration` in `sonner.tsx`).
    - Customers list view reads `isClientActive` from the enriched row so the Status cell no longer throws.

---

## 🟢 Files & Features to MERGE (Safe & Intended)

### 1. Backend Authorization & RBAC Infrastructure
- **`apps/backend/Infrastructure/Authorization/RbacAccessType.cs`**:
  - Enum defining access levels: `View`, `Manage`.
- **`apps/backend/Infrastructure/Authorization/RbacCatalogCodes.cs`**:
  - Strongly typed catalog code constants mapping modules, submodules, and tabs to database catalog GUIDs.
- **`apps/backend/Infrastructure/Authorization/IRbacAuthorizationService.cs` & `RbacAuthorizationService.cs`**:
  - Service checking role permissions against `auth.tbl_role_permissions`.
  - In-memory caching with 5-minute TTL per role.
  - Method `InvalidateRoleCache(Guid roleId)` to bust cache on permission save.
  - Automatic `Admin` role bypass.
- **`apps/backend/Infrastructure/Authorization/RequireRbacAttribute.cs`**:
  - Action filter attribute (`IAsyncActionFilter, IOrderedFilter`) with `Order = -100`.
  - Runs before validation filters and returns standard `403 Forbidden` (`FORBIDDEN`).
- **`apps/backend/Configuration/DependencyInjectionExtensions.cs`**:
  - Registered `AddMemoryCache()` and `IRbacAuthorizationService` scoped service.
- **`apps/backend/Modules/Users/Services/UserService.cs`**:
  - Invalidation of cached permissions on update (`InvalidateRoleCache`).
  - Added userwise role access management methods: `GetUserRoleAccessListAsync`, `UpdateUserRoleAccessAsync`, `ResetUserRoleAccessAsync`, `ResetAllUserRoleAccessAsync`, `GetDepartmentRolesAsync`, `ResetRolePermissionsToDefaultAsync`.
  - Canonical department role mapping dictionary (`CanonicalDepartmentRoles`) for all 10 departments.
- **`apps/backend/Modules/Users/Controllers/UsersController.cs`**:
  - `GET /api/v1/roles/user-access`: Returns paginated/all employee user access records with search, department filtering, and department-scoped role options.
  - `PUT /api/v1/roles/user-access/{employeeId}`: Validates department scope, updates `resource.tbl_employees.Role`, syncs `auth.tbl_users.RoleId`.
  - `POST /api/v1/roles/user-access/{employeeId}/reset`: Resets single employee to original role.
  - `POST /api/v1/roles/user-access/reset-all`: Bulk resets all switched employees back to baseline original roles.
  - `GET /api/v1/roles/department-roles`: Returns canonical department-to-roles dictionary.
  - `POST /api/v1/roles/{id}/permissions/reset-default`: Resets role permissions to baseline default.

### 2. Backend Controllers Enforced with `[RequireRbac]`
- **`apps/backend/Modules/Projects/Controllers/ProjectsController.cs`**:
  - `POST /api/v1/projects` (Create project): `[RequireRbac(RbacCatalogCodes.Projects, RbacAccessType.Manage)]`
  - `PUT /api/v1/projects/{id}` & `PATCH /api/v1/projects/{id}`: `[RequireRbac(RbacCatalogCodes.ProjectDetail, RbacAccessType.Manage)]`
  - Health subtabs protection for issues, appreciations, interviews, requirements, and extension requests.
- **`apps/backend/Modules/Projects/Controllers/ProjectDraftsController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.Projects, RbacAccessType.Manage)]` on creating/updating drafts.
- **`apps/backend/Modules/Customers/Controllers/ClientsController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.Customers, RbacAccessType.Manage)]` on creating and modifying clients.
  - `[RequireRbac("customers", RbacAccessType.View, "projects", "project-detail")]` on client listings and lookups.
- **`apps/backend/Modules/Repository/Controllers/RepositoryController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.Repository, RbacAccessType.Manage)]` on document upload and deletion.
- **`apps/backend/Modules/Resources/Controllers/EmployeesController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.EmployeeDirectory, RbacAccessType.Manage)]` on creating employees, bulk upload, editing profiles, and offboarding.
  - `[RequireRbac("employee-directory", RbacAccessType.View, ...)]` on employee listings and dropdown lookups.
- **`apps/backend/Modules/Timesheets/Controllers/TimesheetsController.cs`**:
  - `[RequireRbac(RbacCatalogCodes.Timesheets, RbacAccessType.Manage)]` on approving timesheets.
- **`apps/backend/Modules/MyTeam/Controllers/MyTeamController.cs` & `MyTeamService.cs`**:
  - Enforced `[RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.Manage)]` on calendar schedule and shift mutations.
  - Admin date unlock logic allowing editing past dates and holidays for admin role.
- **`apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`**:
  - Gated Bucket List, Approvals, Alerts, and Notifications endpoints with explicit `View` vs `Manage` action filters.

### 3. Frontend Roles & Permissions & UI Gating
- **`apps/frontend/src/modules/settings/pages/roles-permissions-page.tsx`**:
  - Internal tab switcher for `Rolewise Access` and `Userwise Access` with blue active styling (`bg-blue-600 text-white shadow-xs`).
  - Removed duplicate repeating `Roles & Permissions` title and subtitle block.
  - "Reset to Baseline" button in Rolewise Access.
  - Userwise Access view with table, department-scoped role select, role switch confirmation modal, single reset confirmation modal, overall reset button and modal, and client-side pagination.
- **`apps/frontend/src/lib/api/users.ts`**:
  - Added frontend API client functions: `fetchUserRoleAccessList`, `updateUserRoleAccess`, `resetUserRoleAccess`, `resetAllUserRoleAccess`, `fetchDepartmentRoles`, `resetRolePermissionsToDefault`.
- **`apps/frontend/src/modules/my-team/index.tsx`**:
  - Removed search bar filters on My Team tab.
  - Hidden My Reportees tab if caller has no reportees or no reportees view permission.
  - Restricted schedule and shift editing strictly to My Reportees tab. View-only on My Team tab.
- **`apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`**:
  - Dynamically filtered Action Center tabs by `canView(tab.code)`.
  - In `ApprovalsTab` and `AlertsTab`: gated table "Actions" column and review modal actions behind manage permissions.
- **`apps/frontend/src/lib/permissions.tsx`**:
  - Added helper permission checks: `canManageProjects()`, `canManageProjectDetail()`, `canManageWBS()`, `canManageTeam()`, `canManageTasks()`, `canManageOverview()`.
- **`apps/frontend/src/modules/projects/pages/project-detail-page.tsx`**:
  - Stage indicator display restored.
  - Buttons and inputs in WBS, Team, Tasks, Overview, and Health subtabs conditionally hidden or disabled based on specific tab access.

### 4. Database Schema & Seed Data
- **`resource.tbl_employees`**:
  - Added `OriginalRole` column to persist and track baseline RBAC role.
  - Seeded initial baseline roles for all existing employees.
- **`auth.tbl_role_permissions`**:
  - Added `DefaultCanView` and `DefaultCanManage` columns.
  - Locked and seeded default baseline permissions across all 28 non-admin roles.
- **`master.mst_tabs`**:
  - Inserted "My Team" tab row (`9854b7f3-0001-4000-8000-000000000001`) under `team-dashboard`.
- **`master.mst_leave_calendar`**:
  - Table definition and seeded 15 company holidays for 2026.
- **`database/pms_uat.sql` & `database/trackerpro-uat.sql`**:
  - Full schema and seed data dumps synchronized from live `pms_uat_clean` database.

### 5. App-wide Financial Year, Global Search, and Task Lookup (2026-11-12)
- **`apps/frontend/src/lib/financial-year.tsx`** *(New)*:
  - `FinancialYearProvider`, `useFinancialYear`, `FinancialYearFilter`, and `inFinancialYears`.
  - Empty selection means every year. A missing end date counts as today, so current employees stay in the current year.
- **`apps/frontend/src/routes/__root.tsx`**:
  - Wraps the app in `FinancialYearProvider`.
- **`apps/frontend/src/components/app-topbar.tsx`** & **`apps/frontend/src/components/global-search.tsx`** *(search is new)*:
  - Search and the financial-year button sit side by side. Search no longer filters by year.
- **`apps/frontend/src/components/ui/sonner.tsx`**:
  - Top-right toast duration is 3000 ms.
- **List screens that follow the selected years**:
  - `projects-list-page.tsx`, `customers-list-page.tsx`, `customer-detail-page.tsx`
  - `employee-directory-page.tsx`, `exit-summary-page.tsx`
  - `repository-page.tsx`, `timesheets-page.tsx`
- **Dashboard**:
  - `dashboard.ts` sends `financialYear` (latest selected year).
  - `team-mis-section.tsx` and the six MIS sections refetch when that year changes.
  - `FinancialQuarter.cs` anchors a past year’s rolling window on 31 March of that year.
- **Task search**:
  - `ProjectsController.cs` `GET /api/v1/projects/task-search` (`[RequireRbac("projects", View)]`).
  - `ProjectAppService.SearchTasksAsync`, `TaskSearchHitDto`, frontend `searchProjectTasks`.
  - `project-detail-page.tsx` opens the Tasks tab from `#tasks`.
- **`ClientService.cs`** and **`clients.ts`**:
  - Client search includes `SubVentureCode`. `fetchClients` passes the search string.

---

## 🔴 Features to Leave UNTOUCHED / DO NOT Overwrite

- **Existing Authentication Token Service**: Do not modify `apps/backend/Modules/Auth/Services/TokenService.cs` or baseline password hashing logic.
- **Admin Full Access Bypass**: Admin role must remain fully bypassed across all endpoints and UI modules without requiring explicit permissions.
- **Database Connection Strings in Dev**: Keep local environment secrets and development connection strings untouched.

---

## 🧪 Verification Summary
- **Backend Authorization Tests**: Verified directly via `curl` against Docker backend on port 52815; unauthorized roles receive HTTP 403 Forbidden with `{ "code": "FORBIDDEN" }`, while authorized roles and Admin receive HTTP 200 OK.
- **Userwise Access Endpoints**: Verified `GET /api/v1/roles/user-access?perPage=0` returns all employees. Verified role switching (`PUT`), single reset (`POST .../reset`), and bulk reset (`POST .../reset-all`) via `curl` against Docker backend.
- **Confirmation Modals**: Verified dropdown role change modal, single reset modal, and overall reset modal dialogs.
- **Pagination Dropdown**: Verified 10, 15, 25, 50, 100, and "All" page size options work seamlessly with instant client-side slicing and accurate page ranges.
- **Active Blue Switch Bar Styling**: Verified Rolewise Access and Userwise Access buttons render with blue pill styling (`bg-blue-600 text-white shadow-xs`) with icons.
- **Health Tab RBAC Endpoints**: Enforced across 15 mutating endpoints for issues, appreciations, customer engagement interviews & additional requirements, and extension requests.
- **Team Dashboard Backend RBAC**: Verified `PUT /api/v1/my-team/days` and `PUT /api/v1/my-team/members/{id}/schedule` return HTTP 403 Forbidden (`FORBIDDEN`) for view-only/unauthorized roles, and allow authorized roles / Admin.
- **Financial Year & Global Search**: Verified with FY 2020-21 selected: projects and customers lists filtered appropriately, employee directory showed active roster within that window, global search independently found employees, customers, 2026 projects, and tasks across years. Dashboard charts correctly respected the selected financial year.
- **Frontend Test Suite**: All 128 tests in `apps/frontend` pass without errors (`npm test --prefix apps/frontend -- --run`).
- **Production Frontend Build**: `npm run build --prefix apps/frontend` completes cleanly with 0 errors.
- **Docker Production Images**: Rebuilt both `pms-backend:uat-clean` and `pms-frontend:uat-clean` containers and verified running healthy on respective ports.
