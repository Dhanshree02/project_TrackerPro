# Merge Context: RBAC Dashboard & Repository Module Access Control

## Overview
This work implements clean-slate Role-Based Access Control (RBAC) following [`omkar_rbac.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/omkar_rbac.md), covering:
1. **Roles & Permissions Management (`/settings-security-roles`)**:
   - RBAC dropdown loads active roles directly from `auth.tbl_roles`.
   - Dynamic fetching of permissions on role change.
   - **Save Changes** and **Reset** buttons with unsaved state tracking.
   - View + Manage disabled for Dashboard module and widgets (`—`).
   - View + Manage enabled for functional modules like Repository.
2. **Dashboard Module & Widgets Access**:
   - Dashboard Module has View toggle only (`CanView`).
   - 8 Dashboard widgets are modifiable only if parent Dashboard module is View.
   - Dynamic hiding of widgets in `TeamMisSection` based on role permissions.
3. **Repository Module Access**:
   - Controlled by `canView("repository")` and `canManage("repository")`.
   - **No Access**: Module hidden in sidebar; route blocked.
   - **Only view (`CanView = 1, CanManage = 0`)**:
     - Visible in sidebar.
     - Full browsing, search, document preview, download, activity logs, access summaries, and pagination.
     - **Upload Document** button is hidden.
     - **Delete** button (trash icon in document rows) is hidden.
   - **View + Manage (`CanView = 1, CanManage = 1`)**:
     - Upload Document button visible and functional.
     - Delete button visible and functional.
     - All read-only functions active.
4. **Switch User / Employee Persona**:
   - Topbar dropdown displays only employee Name and exact RBAC `DisplayName` matching the dropdown.
   - Switching user automatically updates `PermissionProvider` to enforce that role's active permissions from `auth.tbl_role_permissions`.
5. **Catalog Submodule Addition & Customer Detail RBAC**:
   - Submodule `Customer Detail` (`customer-detail`, ID `a7e6b014-9f4a-4d2c-87d2-431527ef9a10`) in `master.mst_submodules` under parent `Customer` (`customers`).
   - Appears in `/settings-security-roles` as an expandable child submodule with View and View+Manage assignment options.
   - **View only (`CanView = 1, CanManage = 0`)**:
     - User can view customer details, sub-ventures, SPOC contacts, project lists, and KYC documents.
     - **Edit Customer** button is **hidden**.
     - **Change Engagement Manager (EM)** button is **hidden**.
     - **Change Sales Manager (SM)** button is **hidden**.
   - **View + Manage (`CanView = 1, CanManage = 1`)**:
     - User can edit customer details via `NewClientModal`.
     - User can change Engagement Manager via EM picker modal.
     - User can change Sales Manager via SM picker modal.
   - **No Access**: Navigation to `/customers/$clientId` redirects to `/access-denied`.
6. **Roles & Permissions Radio Button Fix**:
   - Fixed bug in `roles-permissions-page.tsx` where Column 3 ("Only view") evaluated `checked={access === "view" || access === "view-manage"}` causing both radio buttons to be checked simultaneously and native browser desynchronization.
   - Fixed conflicting `onClick` and `onChange` in `AccessRadio` by implementing unified `handleClick` that cleanly toggles between View and View+Manage on single click, and clears (`null`) when clicking an already-checked radio.
   - Added `saving` disable lock during in-flight permission saves.
7. **Project Detail Submodule Addition**:
   - Added submodule `Project Detail` (`project-detail`, ID `b8f7c125-0e5b-4e3d-98e3-542638fa0b21`) in `master.mst_submodules` under parent `Projects` (`projects`).
   - Appears in `/settings-security-roles` as an expandable child submodule under Projects with View and View+Manage assignment options.
   - Guarded `/projects/$projectId` with `canView("project-detail")`.
8. **Project Detail Tabs & Health Sub-Tabs in Database (`master.mst_tabs`)**:
   - Added 6 tabs under `Project Detail` (`SubModuleId = b8f7c125-0e5b-4e3d-98e3-542638fa0b21`): `Overview`, `WBS`, `Team`, `Tasks`, `Health`, `Invoices`.
   - Added 6 sub-tabs under `Health` (`TabId = c1a11111-0001-4000-8000-000000000005`): `Issues`, `Alerts`, `Escalations`, `Appreciation`, `Customer Engagement`, `Extension Request`.
   - Updated `permissions.tsx` to recursively register nested tab hierarchies and enforce parent access.

## Files Modified
- [`omkar_rbac.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/omkar_rbac.md)
- [`apps/backend/Infrastructure/Persistence/AppDbContext.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Infrastructure/Persistence/AppDbContext.cs)
- [`apps/backend/Infrastructure/Persistence/Configurations/UserConfiguration.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Infrastructure/Persistence/Configurations/UserConfiguration.cs)
- [`apps/backend/Modules/Users/Models/RolePermission.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Modules/Users/Models/RolePermission.cs)
- [`apps/backend/Modules/Users/DTOs/UserDtos.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Modules/Users/DTOs/UserDtos.cs)
- [`apps/backend/Modules/Users/Services/IUserService.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Modules/Users/Services/IUserService.cs)
- [`apps/backend/Modules/Users/Services/UserService.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Modules/Users/Services/UserService.cs)
- [`apps/backend/Modules/Users/Controllers/UsersController.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Modules/Users/Controllers/UsersController.cs)
- [`apps/frontend/src/lib/permissions.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/lib/permissions.tsx)
- [`apps/frontend/src/lib/api/users.ts`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/lib/api/users.ts)
- [`apps/frontend/src/modules/settings/pages/roles-permissions-page.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/modules/settings/pages/roles-permissions-page.tsx)
- [`apps/frontend/src/modules/customers/pages/customer-detail-page.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/modules/customers/pages/customer-detail-page.tsx)
- [`apps/frontend/src/modules/projects/pages/project-detail-page.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/modules/projects/pages/project-detail-page.tsx)
- [`apps/frontend/src/modules/dashboard/components/team-mis-section.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/modules/dashboard/components/team-mis-section.tsx)
- [`apps/frontend/src/modules/dashboard/pages/mis-dashboard-page.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/modules/dashboard/pages/mis-dashboard-page.tsx)
- [`apps/frontend/src/modules/repository/pages/repository-page.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/modules/repository/pages/repository-page.tsx)
- [`apps/frontend/src/components/app-topbar.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/components/app-topbar.tsx)
- [`apps/frontend/src/lib/role-context.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/lib/role-context.tsx)
- [`apps/frontend/src/lib/employee-personas.ts`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/lib/employee-personas.ts)
