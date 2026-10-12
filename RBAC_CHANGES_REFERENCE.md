# RBAC Code Changes Reference Guide
*(Confidential / Internal Developer Reference)*

This document details all code changes made across the application for Role-Based Access Control (RBAC), specifically covering the **View (`0` / `1`)** and **Manage (`0` / `1`)** permission enforcement, route protection, and action button visibility.

---

## 1. Summary of Modified Files

| # | File Path | Layer | Purpose / Change Summary |
|---|---|---|---|
| **1** | `apps/frontend/src/routes/customers.$clientId.tsx` | Frontend (UI) | Added dynamic `canManageCustomer` check to reveal/hide **Change Engagement Manager** and **Change Sales Manager** buttons based on `Manage = 1 / 0`. Removed hardcoded `!isSales` restriction. |
| **2** | `apps/backend/Modules/Rbac/RbacAccessService.cs` | Backend (API) | Added `"customers.edit"` claim to the `manage == 1` block for Customers/Customer profile so frontend tokens receive both `customers.manage` and `customers.edit`. |
| **3** | `apps/frontend/src/lib/role-context.tsx` | Frontend (State) | Made `isViewOnly` dynamic based on `hasProjectManage` (`projects.manage`, `projects.create`, `projects:write`) rather than hardcoded role names (`isBO \|\| isHOD`). |
| **4** | `apps/frontend/src/routes/projects.$projectId.tsx` | Frontend (UI) | Changed Tasks and Team tabs to use `readOnly={isViewOnly}` instead of `readOnly={isViewOnly \|\| isSales}`, allowing roles with `Manage = 1` to edit and locking `Manage = 0` to read-only. |
| **5** | `apps/frontend/src/routes/projects.index.tsx` | Frontend (UI) | Added `projects.view` route guard (redirects to `/` instead of 403) and guarded the `+ New Project` button with `hasPermission("projects.create")`. |
| **6** | `apps/frontend/src/routes/projects.new.tsx` | Frontend (UI) | Added route guard preventing direct URL access (`/projects/new`) for users whose role has `projects.create = 0`. |
| **7** | `apps/frontend/src/routes/customers.index.tsx` | Frontend (UI) | Guarded `+ New Customer` onboarding button with `canCreateClient` checking `customers.create`. |
| **8** | `apps/frontend/src/routes/access-denied.tsx` | Frontend (UI) | Replaced the 403 Access Denied page with automatic `<Navigate to="/" replace />` to prevent 403 screens entirely. |
| **9** | `apps/frontend/src/components/app-shell.tsx` | Frontend (UI) | Replaced unauthorized route bounces to redirect cleanly to `/` rather than `/access-denied`. |
| **10** | `apps/frontend/src/routes/timesheet.tsx` | Frontend (UI) | Replaced unauthorized bounce to redirect to `/` instead of `/access-denied`. |
| **11** | `apps/frontend/src/routes/dh-settings-security-roles.tsx` | Frontend (UI) | Added hierarchical cascade logic: when a parent Module/Submodule View or Manage is toggled, all child widgets/tabs update automatically. |
| **12** | `apps/frontend/src/routes/action-centre.tsx` | Frontend (UI) | Guarded `Approve`, `Reject`, `Hold`, `Request Changes`, `Acknowledge`, `Start Task` timers, and `Raise Issue` buttons with dynamic `canManageApprovals`, `canManageTimer`, and `canManageAlerts`. When Manage = 0, action buttons disappear and pages switch to read-only. |
| **13** | `apps/frontend/src/components/masters/project-masters-section.tsx` | Frontend (UI) | Department/Sub-department service hierarchy filtering. |
| **14** | `apps/frontend/src/lib/masters/project-catalog-store.ts` | Frontend (State) | Case-insensitive and trimmed department/service matching. |
| **15** | `apps/frontend/src/routes/projects.new.tsx` | Frontend (UI) | Live sync of DB service catalog to project onboarding form. |
| **16** | `apps/backend/Modules/Resources/DTOs/ResourceMastersDtos.cs` | Backend (DTO) | Safe string `AssignedRbacRoleId` model binding. |
| **17** | `apps/backend/Modules/Resources/Controllers/ResourceMastersController.cs` | Backend (API) | Safe role resolution and auto-provisioning for custom roles. |
| **18** | `apps/frontend/src/lib/api-client.ts` | Frontend (API) | Enhanced `ValidationProblemDetails` error extraction. |
| **19** | `apps/frontend/src/lib/api/resource-masters.ts` | Frontend (API) | Valid GUID sanitize for hierarchy requests. |
| **20** | `apps/frontend/src/components/masters/resource-masters-section.tsx` | Frontend (UI) | Live RBAC role dropdown options and clean role mapping. |
| **21** | `apps/frontend/src/modules/my-team/index.tsx` | Frontend (UI) | Granular `canViewTeam` and `canManageTeam` permission checks. When `Manage = 0` (`viewOnly`), blocks shift editing, cell clicks, attendance picking, weekly apply, schedule saving, keyboard shortcuts (`G`, `M`, `A`, `N`, `Backspace`), hides schedule config cog, and marks calendar cells `readOnly`. |
| **22** | `apps/frontend/src/routes/my-team.timesheets.tsx` | Frontend (UI) | Added `canManageApproval` guard for Timesheet Approval submodule. When `Manage = 0`, details drawer opens in read-only mode and action buttons (Approve, Reject, Request Changes) are completely hidden. |
| **23** | `apps/frontend/src/lib/navigation.tsx` | Frontend (Nav) | Removed parent module fallback permissions (`"My team:view"`, `"resources.view"`, `"settings.view"`) from submodules. Now when a submodule (`Team Dashboard`, `Resource Pool`, `Masters`) has `CanView = 0`, it is strictly hidden from the sidebar and route guards redirect direct URLs to `/`. |
| **24** | `apps/backend/Modules/Rbac/RbacAccessService.cs` | Backend (API) | Isolated `Bridge()` mapping for `"My team"` so `Permissions.MyTeamDashboardView` and `my-team.team-dashboard.view` are strictly issued only when leaf is `"Team Dashboard"` and `view == 1`. Issue `my-team.team-dashboard.manage` only when `manage == 1`. |
| **25** | `apps/frontend/src/routes/dh-employee-directory.$id.tsx` | Frontend (UI) | Dynamic `canEditProfile` and `canOffboard` checking `resources.manage` / `Resource:manage` / `resources.profile.edit`. When `Manage = 0`, profile is locked to basic details and edit/offboard action buttons are hidden. |
| **26** | `apps/frontend/src/routes/my-org.tsx` | Frontend (UI) | Dynamic `canManageRepository` checking `repository.manage` / `Repository:manage` / `repository.upload`. When `Manage = 0`, document upload and delete actions are hidden and disabled. |
| **27** | `apps/frontend/src/routes/dh-reports.tsx` & `reports.tsx` | Frontend (UI) | Granular tab and widget visibility driven strictly by `0` / `1` permissions for Sales, WBS Tracker, PO Tracker, and Invoice Tracker reports. |
| **28** | `apps/backend/Modules/Rbac/rbac-baseline.json` & DB Sync | Config & DB | Removed whole Projects module for IT Admin (`[0, 0]`). Removed `Start timer` and confirmed `Team`, `Task`, `Health` have No Access (`[0, 0]`) for Accounts. Synchronized live DB. |
| **29** | `apps/frontend/src/routes/action-centre.tsx` & `projects.$projectId.tsx` | Frontend (UI) | Strictly isolated `canViewTimer` and `canManageTimer` to `Action Center\|Bucket List\|Start timer` (removed parent `Bucket List:manage` leak). Removed `"projects.view"` fallback from `Team`, `Tasks`, and `Health` tabs in project detail, guaranteeing they honor `[0, 0]` NO ACCESS. |
| **30** | `apps/backend/Shared/Constants/RoleBaselines.cs` & Baseline HR | Config & Backend | Verified HR baseline: all Dashboard, Action Center, Projects, Reports, Customers, Repository, My team set to `[0, 0]`. Resource module (Personal Info, Org details, Employment, Education, Exit Summary) set to Manage `[1, 1]`, PMO info & Activity logs & Resource pool set to View `[1, 0]`, and Resource Master set to Manage `[1, 1]`. Removed repository permissions from HR fallback. |
| **31** | `apps/backend/Shared/Constants/RoleBaselines.cs` & Baseline Sales Roles | Config & Backend | Verified `Sales Manager` and `Sales team member` baselines: both exact 100% matches in baseline JSON and PostgreSQL database. Removed `my-team` and timesheet claims from `Sales Manager`, and removed `dashboard.view`, `my-team`, and client write claims from `Sales team member` in `RoleBaselines.cs`. |
| **32** | `apps/backend/Modules/Rbac/RbacAccessService.cs` & `apps/frontend/src/routes/projects.$projectId.tsx` | Full Stack | Granular Project UI guards and Backend Claim Bridge for Sales Roles (view-only team, tasks, PMO intake, invoices, escalations). |
| **33** | `apps/backend/Shared/Constants/RoleBaselines.cs`, `RbacAccessService.cs`, `projects.$projectId.tsx` | Full Stack | Restored Project Onboarding (`projects.create`, `projects.drafts`) and Additional Customer Requirement Manage (`[1, 1]`) for Sales Manager while keeping Sales Team Member strictly view-only. |
| **34** | `apps/backend/Shared/Constants/RoleBaselines.cs`, `RbacAccessService.cs`, `matrix.ts` | Full Stack | Verified 100% match for PMO and Engagement Manager (EM) across all 49 baseline items in DB and baseline JSON. Added seamless role name normalization (`Engagement Manager` / `EM` -> `EngagementManager`, `Project Management Office` -> `PMO`) across API endpoints and fallback mappings. |
| **35** | `apps/frontend/src/routes/projects.index.tsx`, `projects.new.tsx`, `RbacAccessService.cs` | Full Stack | Hidden `+ New Project` and `Drafts` buttons for PMO and Engagement Manager in Projects module, and blocked direct navigation to `/projects/new`. |
| **36** | `apps/backend/Modules/Rbac/rbac-baseline.json`, `RoleBaselines.cs`, `matrix.ts`, DB | Full Stack | Verified 100% exact match across all 49 baseline items for `R&D — Team Member` and `SOC Operations — Team Member`. Revoked Resource access (`[0, 0]`), synchronized DB, backend baseline constants, static matrix, and role name normalization. |
| **37** | `apps/backend/Modules/Rbac/rbac-baseline.json`, `RoleBaselines.cs`, `matrix.ts`, DB, `my-team.index.tsx` | Full Stack | Set `Team Dashboard` to NO ACCESS (`[0, 0]`) for `SOC-Team Member`, leaving only `Timesheets` accessible under `My Team`. Isolated `MyTeamDashboardView` claim in backend and added auto-redirect to `/my-team/timesheets`. |
| **38** | `apps/backend/Modules/Rbac/rbac-baseline.json`, `RoleBaselines.cs`, `RbacAccessService.cs`, `matrix.ts`, DB | Full Stack | Verified 100% exact match across all 49 baseline items for `SOC - Team Leader` (`SOC-Team Leader`). Revoked Resource Directory & Details tabs (`[0, 0]`), confirmed Resource Pool (`[1, 1]`) and Exit Summary (`[1, 0]`), synchronized live DB, backend baseline constants, static matrix, and role name normalization. |
| **39** | `apps/frontend/src/routes/projects.index.tsx` & `projects.$projectId.tsx` | Frontend | Resolved 403 Forbidden error on Projects page for roles lacking Customers or Resource module access (`SOC Team Member`, `SOC Team Lead`, `R&D Team Member`). Made secondary client/employee enrichment fault-tolerant with `.catch()` and synthesized client metadata from `ProjectDto`. |
| **40** | `navigation.tsx`, `dh-employee-directory.index.tsx`, `projects.$projectId.tsx` | Frontend (UI) | Isolated Resource Directory vs Resource Pool navigation and routes (Resource Directory hidden for `SOC-Team Leader`, Resource Pool active with Manage access); restored Project Overview leadership cards (`Sr. PM`, `PM`, `Team Lead`) as View-Only (`[1, 0]`) for `R&D - Team member` and `SOC-Team Member`. |
| **41** | `rbac-baseline.json`, `RoleBaselines.cs`, `RbacAccessService.cs`, `matrix.ts`, DB | Full Stack | Synchronized 100% exact baseline for `Consulting-Team member` and `Consulting-Team Leader` across all 49 items: revoked Resource Directory & Details (`[0, 0]`), revoked Team Dashboard (`[0, 0]`) for Consulting Team Member, verified Resource Pool Manage (`[1, 1]`) and Team/Task Manage (`[1, 1]`) for Consulting Team Leader, and synchronized live DB and static matrices. |
| **42** | `rbac-baseline.json`, `RoleBaselines.cs`, `RbacAccessService.cs`, `matrix.ts`, DB | Full Stack | Synchronized 100% exact baseline for `Testing-Team Member` and `Testing-Team Leader` across all 49 items: revoked Resource Directory & Details (`[0, 0]`), preserved Team Dashboard View (`[1, 0]`) for Testing Team Member and Manage (`[1, 1]`) for Testing Team Leader, verified Resource Pool Manage (`[1, 1]`) and Team/Task Manage (`[1, 1]`) for Testing Team Leader, and synchronized live DB and static matrices. |
| **43** | `rbac-baseline.json`, `RoleBaselines.cs`, `RbacAccessService.cs`, `matrix.ts`, DB | Full Stack | Verified 100% baseline match across all 49 items for `SOC - Manager`, `Consulting - Manager`, and `Testing - Manager`: Dashboard (all View), Action Center (all Manage), Projects (Budget/Billing/Invoices NO ACCESS; Sr. PM/PM/TL/PMO Intake View; Team/Tasks/Health Manage), Reports (WBS & PO Tracker View; Sales/Invoices NO ACCESS), Resource (Directory tabs View except Education & Experience Manage; Activity Logs NO ACCESS; Resource Pool Manage; Exit Summary View), Customer Profile (View), Repository (View), My team (all Manage), Settings (all NO ACCESS). Added backend fallback constants, role normalization, frontend role aliases, static `MANAGER_CORE` matrix, and reset DB permissions. |
| **44** | `navigation.tsx`, `employee-form-modal.tsx` | Frontend (UI) | Unified Resource Directory and Resource Pool under Resources sidebar into a single entry for roles having both; enforced section-level RBAC in `EmployeeFormModal` so when a Project Manager, PMO, or Engagement Manager edits an employee profile, all sections (Personal, Org Assignment, Employment, PMO) are locked to View Only and uneditable (`disabled` + `pointer-events-none`) except Education & Experience which remains active and editable. |



---

## 2. Detailed Code Changes by File

---

### File 1: `apps/frontend/src/routes/customers.$clientId.tsx`
* **Problem**: Setting `Manage = 1` for "Customer profile" was not showing the "Change" buttons for Engagement Manager and Sales Manager because the code strictly checked `customers.edit` and had a hardcoded `&& !isSales` blocker.
* **Changes**:
  1. **Lines 123–128**: Added dynamic permission resolver:
     ```tsx
     const canManageCustomer =
       isAdmin ||
       isDhanshree ||
       hasPermission("customers.manage") ||
       hasPermission("clients:write") ||
       hasPermission("customers.edit");
     ```
  2. **Lines 590–598** (Change Engagement Manager):
     ```tsx
     // Before:
     {(isAdmin || isDhanshree || hasPermission("customers.edit") || hasPermission("customers.change_em")) && !isSales && (
       <button onClick={openEmPicker}>Change</button>
     )}

     // After:
     {(canManageCustomer || hasPermission("customers.change_em")) && (
       <button onClick={openEmPicker}>Change</button>
     )}
     ```
  3. **Lines 624–632** (Change Sales Manager):
     ```tsx
     // Before:
     {(isAdmin || isDhanshree || hasPermission("customers.edit") || hasPermission("customers.change_sm")) && (
       <button onClick={openSmPicker}>Change</button>
     )}

     // After:
     {(canManageCustomer || hasPermission("customers.change_sm")) && (
       <button onClick={openSmPicker}>Change</button>
     )}
     ```

---

### File 2: `apps/backend/Modules/Rbac/RbacAccessService.cs`
* **Problem**: When a user logged in, their JWT/token permissions only included `customers.manage` and `clients:write`, but did not include `customers.edit`.
* **Changes**:
  * **Line 705**: In the `Bridge()` method under `manage == 1`:
    ```csharp
    case "Customers":
        if (leaf.Equals("Customers Card", StringComparison.OrdinalIgnoreCase) ||
            leaf.Equals("Customers", StringComparison.OrdinalIgnoreCase) ||
            leaf.Equals("Customer profile", StringComparison.OrdinalIgnoreCase))
        {
            claims.Add(Permissions.ClientsWrite);
            claims.Add("customers.create");
            claims.Add("customers.manage");
            claims.Add("customers.edit"); // <-- Added
        }
        break;
    ```

---

### File 3: `apps/frontend/src/lib/role-context.tsx`
* **Problem**: `isViewOnly` was hardcoded to `const isViewOnly = isBO || isHOD || backendRole === "Intern";`. Roles like PMO or Sales with `Manage = 0` were not treated as view-only, while HODs with `Manage = 1` were blocked from editing.
* **Changes**:
  * **Lines 310–325**: Made `isViewOnly` evaluate the dynamic RBAC database permissions:
    ```tsx
    const hasProjectManage =
      isAdmin ||
      isDhanshree ||
      (authUser?.permissions && authUser.permissions.length > 0
        ? Boolean(
            authUser.permissions.some(
              (p) =>
                p === "projects.manage" ||
                p === "projects.create" ||
                p === "projects:write" ||
                p === "projects.wbs.allocate",
            ),
          )
        : !(isBO || isHOD || backendRole === "Intern"));

    const isViewOnly = !hasProjectManage || backendRole === "Intern";
    ```

---

### File 4: `apps/frontend/src/routes/projects.$projectId.tsx`
* **Problem**: Tasks and Team tabs checked `readOnly={isViewOnly || isSales}` which unconditionally locked out Sales roles even when granted Manage = 1.
* **Changes**:
  * **Lines 1214 & 1221**:
    ```tsx
    // Before:
    <DhTasksTab project={project} readOnly={isViewOnly || isSales} />
    <DhTeamTab project={project} readOnly={isViewOnly || isSales} />

    // After:
    <DhTasksTab project={project} readOnly={isViewOnly} />
    <DhTeamTab project={project} readOnly={isViewOnly} />
    ```

---

### File 5: `apps/frontend/src/routes/projects.index.tsx`
* **Changes**:
  * **Line 264**: Added View permission check redirecting to `/` if unauthorized:
    ```tsx
    if (!isDhanshree && !hasPermission("projects.view")) {
      return <Navigate to="/" />;
    }
    ```
  * **Lines 351–358**: Guarded `+ New Project` button so it only renders when `projects.create` (Manage = 1) is true:
    ```tsx
    {hasPermission("projects.create") && (
      <button onClick={() => navigate({ to: "/projects/new" })}>
        <Plus className="h-4 w-4" /> New Project
      </button>
    )}
    ```

---

### File 6: `apps/frontend/src/routes/projects.new.tsx`
* **Changes**:
  * **Line 590**: Added direct route URL guard:
    ```tsx
    if (!isDhanshree && !hasPermission("projects.create")) {
      return <Navigate to="/" />;
    }
    ```

---

### File 7: `apps/frontend/src/routes/customers.index.tsx`
* **Changes**:
  * **Lines 296–304**: Evaluates `canCreateClient`:
    ```tsx
    const canCreateClient =
      isAdmin ||
      isDhanshree ||
      (can ? can("customers.create") : false) ||
      Boolean(authUser?.permissions?.some((p) => p === "customers.create" || p === "clients:write"));
    ```
  * **Lines 441–448**: Guarded `+ New Customer` button:
    ```tsx
    {canCreateClient && (
      <button onClick={() => setOpenNew(true)}>
        <Plus className="h-4 w-4" /> New Customer
      </button>
    )}
    ```

---

### File 8: `apps/frontend/src/routes/access-denied.tsx`
* **Changes**: Replaced the 403 page UI with a silent automatic redirect:
  ```tsx
  export function RouteComponent() {
    return <Navigate to="/" replace />;
  }
  ```

---

### File 9: `apps/frontend/src/components/app-shell.tsx` & File 10: `timesheet.tsx`
* **Changes**: Replaced `to: "/access-denied"` redirects with `to: "/"`:
  ```tsx
  // app-shell.tsx Line 53
  navigate({ to: "/" });

  // timesheet.tsx Line 80
  if (!hasPermission("my-team.my-timesheet.view")) return <Navigate to="/" replace />;
  ```

---

### File 11: `apps/frontend/src/routes/dh-settings-security-roles.tsx`
* **Changes**: Added hierarchical auto-cascade:
  * When a parent Module's View is toggled to `0`, all its submodules, widgets, and tabs automatically flip to `0`.
  * When a parent Manage is toggled, child Manage actions follow accordingly.

---

### File 12: `apps/frontend/src/routes/action-centre.tsx`
* **Problem**: Action buttons were hardcoded to `!isBO`. Any non-BO user saw the action buttons even when their role was configured with `Manage = 0`.
* **Changes**:
  1. **Approvals Tab (`ApprovalsTab`)**:
     - Added `canManageApprovals` evaluating `action-center.manage`, `approvals.manage`, and `Action Center|Approvals:manage`.
     - Guarded `Acknowledge` button (Line 805).
     - Guarded mandatory comments textarea and `Hold`, `Request Changes`, `Reject`, and `Approve` buttons (Lines 913–965).
     - When `Manage = 0`, View-Only users can inspect requests, read details and audit logs, but cannot perform any actions.
  2. **Bucket List Tab (`BucketListRow` & `BucketList`)**:
     - Added `canManageTimer`: Guards `Start Task`, `Pause`, `Resume`, and `Stop` timer action buttons.
     - Added `canRaiseIssue`: Guards the `+ Raise Issue` button.
  3. **Alerts Tab (`AlertsTab`)**:
     - Added `canManageAlerts`: Guards `Approve`, `Reject`, `Update`, and `Save Governance Changes` action buttons. When `Manage = 0`, only the "Close" button is available.

---

### File 13: `apps/frontend/src/components/masters/project-masters-section.tsx`
* **Problem**: In Project Masters, when selecting a Department and Sub-Department, the Service field was either locked or falling back to a global catalog containing all 39 services across all unrelated departments. Furthermore, if a department had no sub-departments, the Service field was permanently disabled.
* **Changes**:
  1. **`availableSubDepartmentsForDept`**:
     - Stripped out `"—"` and `"-"` placeholders from selectable sub-departments so they don't appear in the dropdown.
  2. **`catalogServicesForDept`**:
     - Added case-insensitive and `.trim()` matching against PostgreSQL `hierarchy`, in-memory `store`, and database `items`.
     - When a Sub-Department is selected, strictly narrows services down to that Sub-Department.
     - When no Sub-Department is selected yet, lists all services belonging to the selected Department.
  3. **`filteredServicesForDept`**:
     - Removed fallback to `propsServices || storeAllServices` (which previously leaked services from all other departments).
     - Services dropdown now displays strictly the services of the selected Department and Sub-Department.
  4. **Form Controls (Service Dropdown & [+] Button)**:
     - Changed `disabled={!selectedSubDepartment}` to `disabled={!selectedDepartment}` so the field unlocks as soon as Department is selected.
     - Auto-selects Sub-Department if a service is picked before choosing Sub-Department.
  5. **Edit Modal**:
     - Mirrored the exact same scoped, case-insensitive, and trimmed service filtering logic to `availableSubDepartmentsForEditDept` and `catalogServicesForEditDept`.

---

### File 14: `apps/frontend/src/lib/masters/project-catalog-store.ts`
* **Changes**:
  - `getServicesForDepartment`: Made department lookup case-insensitive and trimmed against `deptServices` keys, and made sub-department matching case-insensitive and trimmed.
  - `getSubDepartmentsForDepartment`: Made department key lookup case-insensitive and trimmed against `deptSubDepts` and `deptServices` keys.

---

### File 15: `apps/frontend/src/routes/projects.new.tsx`
* **Problem**: In the Project Onboarding Form (`/projects/new`), newly added departments, sub-departments, and services from PostgreSQL were not appearing in the Service Picker modal. This happened because `subDeptsForDept` and `findCatalogService` were reading from a hardcoded in-memory constant `DEPT_SERVICES` that was never updated when `dbServiceHierarchy` loaded from PostgreSQL.
* **Changes**:
  - In `dynamicDeptServices`, synchronized the loaded database hierarchy into `DEPT_SERVICES` via `Object.assign(DEPT_SERVICES, map)` and `Object.assign(DEPT_GROUPS, map)`.
  - Allowed departments with direct services or empty initial sub-departments to display properly in the tree.
  - Added real-time window listeners for `trackerpro:catalog_updated` and `focus` so that adding a department or service in Project Masters immediately updates the Project Onboarding Form without needing a hard browser restart.

### File 16: `apps/backend/Modules/Resources/DTOs/ResourceMastersDtos.cs`
* **Problem**: Adding or editing Department Hierarchy Configuration caused `Request failed (400)`. In `CreateResourceHierarchyRequest` and `UpdateResourceHierarchyRequest`, `AssignedRbacRoleId` was typed strictly as `Guid?`. When the frontend passed an empty string, null string, or synthetic custom role ID (`rbac-custom-...` or `rbac-...`), ASP.NET Core model binding rejected the request with `ValidationProblemDetails` before the controller action could even execute.
* **Changes**:
  - Changed `Guid? AssignedRbacRoleId` to `string? AssignedRbacRoleId` in both `CreateResourceHierarchyRequest` and `UpdateResourceHierarchyRequest` so that model binding never fails regardless of string format.

---

### File 17: `apps/backend/Modules/Resources/Controllers/ResourceMastersController.cs`
* **Changes**:
  - Added `ResolveRbacRoleIdAsync(string? roleIdStr, string? roleCode, string? roleName, CancellationToken ct)` helper:
    1. Checks if `roleIdStr` is a valid `Guid` that exists in `db.Roles`.
    2. If not, matches by `roleCode` in `db.Roles`.
    3. If not, matches by `roleName` (display name or name) in `db.Roles`.
    4. If the user created a brand new custom RBAC role via `[+]` that does not exist in `db.Roles` yet, auto-provisions the role in `auth.tbl_roles` with `IsActive = true` and links it.
  - In `CreateHierarchy`: Resolved `rbacRoleId` safely with `ResolveRbacRoleIdAsync` and assigned it to `desig.DefaultRoleId`.
  - In `UpdateHierarchy`: Resolved `resolvedRoleId` safely with `ResolveRbacRoleIdAsync` for both role and designation updates.

---

### File 18: `apps/frontend/src/lib/api-client.ts`
* **Problem**: When any ASP.NET Core validation problem occurred (`ValidationProblemDetails`), `errors` is an object of field names to arrays (`{ field: string[] }`). The client previously only checked `errors?.[0]?.message`, resulting in undefined and falling back to opaque `Request failed (400)`.
* **Changes**:
  - Enhanced error parsing in `apiFetch` to check for `ValidationProblemDetails` object structures (`Object.values(env.errors).flat()`) and titles, displaying human-readable validation messages.

---

### File 19: `apps/frontend/src/lib/api/resource-masters.ts`
* **Problem**: `createResourceHierarchy` was sending `departmentCode: item.departmentId` (passing UUIDs into code fields) and passing invalid/temporary strings into `assignedRbacRoleId`.
* **Changes**:
  - Added `isValidGuid` helper to ensure only RFC 4122 GUIDs are transmitted as `assignedRbacRoleId`; non-guid strings and empty values are sent as `undefined` so that role name and code matching is performed cleanly.
  - Removed accidental assignment of internal entity IDs to code fields (`departmentCode: item.departmentId`).

---

### File 20: `apps/frontend/src/components/masters/resource-masters-section.tsx`
* **Changes**:
  - Imported `fetchRbacRoles` from `@/lib/api/resource-masters` and added a `useEffect` on mount to fetch live RBAC roles from PostgreSQL (`/api/v1/resource-masters/rbac-roles`).
  - Merged `dbRbacRoles` into `availableRbacRoles` useMemo.
  - Eliminated fake temporary ID synthesis (`rbac-${Date.now()}` and `rbac-custom-${Date.now()}`), replacing them with clean string matching.
  - Updated `handleAddSubmit` and `handleSaveEdit` to cleanly pass `assignedRbacRoleId: rbacMeta?.id || undefined`.

### File 21: `apps/frontend/src/modules/my-team/index.tsx`
* **Problem**: In the Team Dashboard (`/my-team`), users with `Manage = 0` (such as CEO) could still click calendar day cells, change employee shifts, toggle attendance, apply weekly patterns, save schedule configurations, and trigger keyboard shortcuts (`G`, `M`, `A`, `N`, `Backspace`) to alter shift data. Additionally, direct URL access was not cleanly redirecting when `View = 0`.
* **Changes**:
  1. **Dynamic Permission Resolvers (Lines 70–80)**:
     ```tsx
     const canViewTeam =
       isAdmin ||
       isDhanshree ||
       hasAny("My team|Team Dashboard:view", "my-team.team-dashboard.view");

     const canManageTeam =
       isAdmin ||
       isDhanshree ||
       hasAny("My team|Team Dashboard:manage", "my-team.team-dashboard.manage");

     const viewOnly = !canManageTeam;
     ```
  2. **Route Guard (Lines 578–580)**:
     ```tsx
     if (!canViewTeam && !isAdmin && !isDhanshree) {
       return <Navigate to="/" replace />;
     }
     ```
  3. **Mutations Blocked When `viewOnly = true`**:
     - `writeShift`: Early exit `if (viewOnly) return;`.
     - `handleCellToggle`: Early exit `if (viewOnly) return;`.
     - `handleAttendanceSelect`: Early exit `if (viewOnly) return;`.
     - `handleShiftSelect`: Early exit `if (viewOnly) return;`.
     - `handleApplyWeek`: Early exit `if (viewOnly) return;`.
     - `handleSaveMemberSchedule`: Early exit `if (viewOnly) return;`.
     - `document.addEventListener("keydown", handler)`: Early exit `if (viewOnly) return;` skips keyboard event execution.
  4. **UI Elements Locked / Hidden**:
     - `CalendarCog` configuration button is hidden when `viewOnly = true`.
     - `CalendarDayCell` passed `readOnly={viewOnly}` to lock Radix Popovers from opening.

---

### File 22: `apps/frontend/src/routes/my-team.timesheets.tsx`
* **Problem**: In Timesheets Approval, when a role had `Manage = 0` (e.g. CEO), they could still see the action buttons in the slideover/drawer and perform approval actions.
* **Changes**:
  1. **Dynamic `canManageApproval` Guard**:
     ```tsx
     const canManageApproval =
       isAdmin ||
       isDhanshree ||
       hasAny(
         "My team|Timesheets|Timesheet Approval:manage",
         "my-team.timesheets.manage",
         "timesheets.monitor"
       );
     ```
  2. **Details Drawer Read-Only**:
     - When `canManageApproval = false`, the `Approve`, `Reject`, and `Request Changes` buttons are hidden.
     - Timesheet details are displayed in read-only inspection mode.

---

### File 23: `apps/frontend/src/lib/navigation.tsx`
* **Problem**: Submodules in `NAV_ITEMS` included parent module permissions in their `permission` array (e.g., `Team Dashboard` had `"My team:view"`, `Resource Pool` had `"resources.view"`, and `Masters` had `"settings.view"`). When an admin unchecked a submodule (`CanView = 0`), the sidebar still showed it because the parent module was checked.
* **Changes**:
  1. **Strict Submodule Permissions (`NAV_ITEMS`)**:
     - `Team Dashboard`: Requires strictly `["My team|Team Dashboard:view", "my-team.team-dashboard.view"]`.
     - `Timesheets`: Requires strictly `["My team|Timesheets:view", "my-team.timesheets.view", "My team|Timesheets|My timsheet:view", "My team|Timesheets|Timesheet Approval:view"]`.
     - `Directory & Resource Pool`: Removed generic `"resources.view"` parent fallback.
     - `Settings > Masters`: Removed generic `"settings.view"` parent fallback; requires specific Masters permissions.
     - `Settings > Roles & Permissions`: Added `"Settings|Role:view"` and `"Settings|Moduleswise Access:view"`.
  2. **Route Guards (`ROUTE_PERMISSIONS`)**:
     - `/my-team`: Strictly checks `["My team|Team Dashboard:view", "my-team.team-dashboard.view"]`.
     - `/dh-settings-masters`: Removed `"settings.view"` fallback so direct URL access redirects to `/` if Masters is unchecked.

---

### File 24: `apps/backend/Modules/Rbac/RbacAccessService.cs`
* **Problem**: In the backend `Bridge()` method, any row under `"My team"` with `CanView == 1` was issuing `Permissions.MyTeamDashboardView` (`my-team.dashboard.view`) and `my-team.team-dashboard.view`. This leaked view claims even when `Team Dashboard` had `CanView = 0` in `tbl_role_widget_permissions`.
* **Changes**:
  1. **`Bridge()` View Block (Lines 634–648)**:
     ```csharp
     case "My team":
         if (leaf.Equals("Team Dashboard", StringComparison.OrdinalIgnoreCase))
         {
             claims.Add(Permissions.MyTeamDashboardView);
             claims.Add("my-team.team-dashboard.view");
         }
         else if (leaf.Equals("Timesheets", StringComparison.OrdinalIgnoreCase))
         {
             claims.Add("my-team.timesheets.view");
         }
         else if (leaf.Equals("My team", StringComparison.OrdinalIgnoreCase))
         {
             claims.Add("my-team.view");
         }
         break;
     ```
  2. **`Bridge()` Manage Block (Lines 746–759)**:
     ```csharp
     case "My team":
         if (leaf.Equals("Team Dashboard", StringComparison.OrdinalIgnoreCase))
         {
             claims.Add("my-team.team-dashboard.manage");
         }
         else if (leaf.Equals("Timesheets", StringComparison.OrdinalIgnoreCase))
         {
             claims.Add("my-team.timesheets.manage");
         }
         else if (leaf.Equals("My team", StringComparison.OrdinalIgnoreCase))
         {
             claims.Add("my-team.manage");
         }
         break;
     ```

---

### File 25: `apps/frontend/src/routes/dh-employee-directory.$id.tsx`
* **Problem**: In the Employee Profile page, the "Edit Profile" and "Offboard Employee" buttons were checking role names and lacked granular check against `Manage = 0`.
* **Changes**:
  1. **Dynamic Permission Guards (Lines 438–453)**:
     ```tsx
     const canEditProfile =
       isAdmin ||
       isDhanshree ||
       hasPermission("resources.manage") ||
       hasPermission("Resource:manage") ||
       hasPermission("resources.profile.edit");

     const canOffboard =
       isAdmin ||
       isDhanshree ||
       hasPermission("resources.manage") ||
       hasPermission("Resource:manage") ||
       hasPermission("resources.profile.offboard");

     const basicOnly = !canEditProfile;
     ```
  2. When `canEditProfile = false`, "Edit Profile" modal button is hidden.
  3. When `canOffboard = false`, "Offboard Employee" button is hidden.

---

### File 26: `apps/frontend/src/routes/my-org.tsx`
* **Problem**: In the Repository module, document upload and delete actions were available to view-only users.
* **Changes**:
  1. **Dynamic `canManageRepository` Guard (Lines 1175–1184)**:
     ```tsx
     const canManageRepository =
       isAdmin ||
       isDhanshree ||
       hasPermission("repository.manage") ||
       hasPermission("Repository:manage") ||
       hasPermission("repository.upload") ||
       hasPermission("Repository|Upload:manage");

     const isReadOnlyViewer = !canManageRepository;
     ```
  2. When `isReadOnlyViewer = true`:
     - "+ Upload Document" button and upload dialog are completely hidden.
     - Document delete action icons/buttons are hidden and blocked.

---

### File 27: `apps/frontend/src/routes/dh-reports.tsx` & `reports.tsx`
* **Problem**: Reports submodules (Sales, WBS Tracker, PO Tracker, Invoice Tracker) were not strictly following the 0/1 permission matrix.
* **Changes**:
  1. Filtered report navigation tabs and report views by exact permissions (`reports.sales`, `reports.wbs_tracker`, `reports.po_tracker`, `reports.invoice_tracker`).
  2. Direct URL access to disabled report tabs automatically switches to the first authorized report tab or redirects to `/`.

---

### File 28: `apps/backend/Modules/Rbac/rbac-baseline.json` & Baseline Sync
* **Requirement**:
  1. **IT Admin**: Entire `Projects` module removed from baseline (`[0, 0]` for all 17 leaves under Projects: Budget, Extension Request, Sr. PM, PM, Team leads, Billing Info, Intake Workflow, Invoice Schedule, Team, Task, Health issues/alerts/escalation/appreciation/customer engagement, and Invoice).
  2. **Accounts**: Removed `Start timer` in Action Center Bucket List (`[0, 0]`). Confirmed that under Projects, `Team`, `Task`, and `Health` (all 6 items) have `[0, 0]` (No Access).
* **Changes**:
  - Updated all 17 Projects leaves in `apps/backend/Modules/Rbac/rbac-baseline.json` for `IT Admin` to `[0, 0]`.
  - Confirmed `Start timer` and Projects `Team`, `Task`, `Health` in `rbac-baseline.json` for `Accounts` are `[0, 0]`.
  - Synchronized live PostgreSQL database (`auth.tbl_role_widget_permissions`) via `POST /api/v1/rbac/matrix/reset`.
  - Updated `apps/backend/Shared/Constants/RoleBaselines.cs` fallback definitions.

---

### File 29: `apps/frontend/src/routes/action-centre.tsx` & `projects.$projectId.tsx`
* **Problem**: 
  1. `BucketListRow` timer was checking `Action Center|Bucket List:manage` and lacked a `canViewTimer` guard, which caused roles with `Raise issues = 1` (like IT Admin and Accounts) to see timer controls and buttons even when `Start timer = NO ACCESS [0, 0]`.
  2. `projects.$projectId.tsx` had hardcoded `"projects.view"` fallback on `canViewTeam`, `canViewTasks`, and `canViewHealth`. Any role with top-level project view access (such as Accounts) had these tabs automatically exposed despite baseline being `[0, 0]`.
* **Changes**:
  1. In `action-centre.tsx`: strictly scoped `canViewTimer` and `canManageTimer` to `Action Center|Bucket List|Start timer`. Guarded table header, rows, and empty state so the timer column and all timer buttons are completely hidden when `Start timer = NO ACCESS`.
  2. In `projects.$projectId.tsx`: removed `"projects.view"` fallback from `canViewTeam`, `canViewTasks`, and `canViewHealth`. Added strict granular permission checks (`Projects|projects Cards|Team:view`, `Task:view`, `Health:view`).

---

### File 30: `apps/backend/Shared/Constants/RoleBaselines.cs` & Baseline HR Verification
* **Requirements**:
  - **HR Role Baseline**:
    - Dashboard: All 5 items NO ACCESS `[0, 0]`
    - Action Center: All 5 items NO ACCESS `[0, 0]`
    - Projects: All 17 items NO ACCESS `[0, 0]`
    - Reports: All 4 items NO ACCESS `[0, 0]`
    - Resource: Personal Info, Org details, Employment, Education, Exit Summary = MANAGE `[1, 1]`; PMO info, Activity logs, Resource Pool = VIEW `[1, 0]`
    - Customers: NO ACCESS `[0, 0]`
    - Repository: NO ACCESS `[0, 0]`
    - My team: All items NO ACCESS `[0, 0]`
    - Settings: Resource Master = MANAGE `[1, 1]`; Project/Customer Masters & Roles = NO ACCESS `[0, 0]`
* **Verification & Changes**:
  - Verified active DB `auth.vw_role_widget_matrix` and `rbac-baseline.json`: already an exact 100% match.
  - In `RoleBaselines.cs`: removed repository claims (`repository.view`, `repository.upload`, `repository.download`) from the `HR` and `Hr` fallback lists so Repository is never accessible even in fallback scenarios.

---

### File 31: `apps/backend/Shared/Constants/RoleBaselines.cs` & Baseline Sales Roles Verification
* **Requirements**:
  1. **Sales Manager**:
     - Dashboard: All 5 items = VIEW `[1, 0]`
     - Action Center: Bucket List Raise issues, Approvals, Alerts, Notifications = MANAGE `[1, 1]`; Start timer = NO ACCESS `[0, 0]`
     - Projects: Budget = MANAGE `[1, 1]`; Sr. PM, PM, Team leads, Intake Workflow, Team, Task, Health issues/alerts/escalation/appreciation/interview scheduling, Invoice = VIEW `[1, 0]`; Additional customer Requirement = MANAGE `[1, 1]`; Extension Request, Billing Info, Invoice Schedule = NO ACCESS `[0, 0]`
     - Reports: Sales Report = MANAGE `[1, 1]`; WBS, PO, Invoice Tracker = VIEW `[1, 0]`
     - Resource: Personal Info, Org details, Employment, PMO info = VIEW `[1, 0]`; Education, Activity logs, Resource pool, Exit summary = NO ACCESS `[0, 0]`
     - Customers: Customer profile = MANAGE `[1, 1]`
     - Repository: VIEW `[1, 0]`
     - My team: All items = NO ACCESS `[0, 0]`
     - Settings: Project Masters, Customer Masters = VIEW `[1, 0]`; Roles & Resource Master = NO ACCESS `[0, 0]`
  2. **Sales team member**:
     - Dashboard: All 5 items = NO ACCESS `[0, 0]`
     - Action Center: Bucket List Raise issues = MANAGE `[1, 1]`; Approvals, Alerts, Notifications = VIEW `[1, 0]`; Start timer = NO ACCESS `[0, 0]`
     - Projects: Budget, Sr. PM, PM, Team leads, Intake Workflow, Team, Task, Health (all 6 items), Invoice = VIEW `[1, 0]`; Extension Request, Billing Info, Invoice Schedule = NO ACCESS `[0, 0]`
     - Reports: All 4 items = VIEW `[1, 0]`
     - Resource: Personal Info, Org details, Employment, PMO info = VIEW `[1, 0]`; Education, Activity logs, Resource pool, Exit summary = NO ACCESS `[0, 0]`
     - Customers: Customer profile = VIEW `[1, 0]`
     - Repository: VIEW `[1, 0]`
     - My team: All items = NO ACCESS `[0, 0]`
     - Settings: Project Masters, Customer Masters = VIEW `[1, 0]`; Roles & Resource Master = NO ACCESS `[0, 0]`
* **Verification & Changes**:
  - Both roles were checked in `rbac-baseline.json` and in PostgreSQL `auth.vw_role_widget_matrix`: **exact 100% matches across all modules, submodules, and widgets**.
  - In `RoleBaselines.cs`: removed `my-team` and timesheet claims from `Sales Manager`, and removed `dashboard.view`, `my-team`, and customer write claims from `Sales team member` fallback lists to ensure no unintended permissions leak even in fallback scenarios.

### File 32: Sales Roles Granular Project UI Guards & Backend Claim Bridge
* **Problem**:
  1. Even though `rbac-baseline.json` and PostgreSQL `vw_role_widget_matrix` configured Sales Manager with VIEW `[1, 0]` for Team, Tasks, WBS PMO Intake, Health (Issues, Alerts, Escalation, Appreciation), and Invoice, the backend `Bridge()` in `RbacAccessService.cs` was synthesizing `projects.manage`, `projects.create`, and `projects:write` merely because Budget and Additional customer Requirement had `Manage = 1`.
  2. In frontend `role-context.tsx`, `hasProjectManage` checked `projects.manage` / `projects:write`, marking `isViewOnly = false` for the entire project, which exposed write actions in Team, Tasks, PMO Intake, and Health tabs.
  3. For Sales team member, `Customer Engagement > Additional customer requirement` should be VIEW only (`[1, 0]`), Invoice should be VIEW only (`[1, 0]`), and all 4 Reports should be VIEW only (`[1, 0]`).
* **Changes**:
  1. **Backend `RbacAccessService.cs` (`Bridge`)**:
     - Updated `Bridge()` to inspect `RoleBaselines.For(roleName)`.
     - Stopped granting broad `projects.manage`, `projects.create`, and `projects:write` claims when the baseline role does not include project write permissions.
  2. **Frontend `projects.$projectId.tsx`**:
     - Granular manage claims: Defined `canManageTeam`, `canManageTasks`, `canManagePmoIntake`, and `canManageInvoice`.
     - Tasks tab: Passed `readOnly={!canManageTasks}`.
     - Team tab: Passed `readOnly={!canManageTeam}`.
     - Invoice tab: `invoiceEditable = canManageInvoice && !isViewOnly`.
     - Health tab:
       - Defined `canManageIssues`, `canManageEscalations`, `canManageAppreciation` using exact submodule manage claims.
       - `HealthAppreciationPanel`: Guarded `+ Appreciate Member` button with `canAppreciate` and removed `isSales` bypass.
       - `HealthEscalationsPanel`: In escalation review details modal, disabled status selection, resolution notes textarea, and hid "Save Changes" button when `!canRaise`.
       - `AdditionalRequirementsPanel`: Guarded `+ Log Requirement` button with `canManageRequirement` (`Projects|projects Cards|Health|Customer Engagment|Additional customer Requirement:manage`).
       - `RequirementDetailsModal`: Made status select disabled and discussion comment post form hidden when `!canManage`.
     - WBS PMO Intake Workflow (`WbsPrerequisiteSection`):
       - Made Project Allocation and Service tracking table visible to view-only users.
       - Guarded "Assign PM" and "Assign SPM" buttons with `{canManagePmoIntake && !isViewOnly && (...) }`.
       - Service tracking table: Disabled `collectionStatus`, `validationStatus`, and `billingStatus` dropdown selects, and disabled "Ready to Start" button when `!canManagePmoIntake || isViewOnly`.
       - Table Escalation column: Guarded "Raise Escalation" button with `canManageEscalations`.
  3. **Frontend `matrix.ts`**:
     - Cleaned up leftover claims (`projects.create`, `projects.drafts`, `my_team.dashboard`, `timesheet.my`, `customers.create`) from Sales Manager and Sales team member static matrix fallback definitions.

---

### File 33: Sales Manager Project Onboarding & Additional Customer Requirement Manage
* **User Requirements**:
  1. **Sales Manager - Project Onboarding Action**: Sales Manager can onboard new projects. Restore the `+ New Project` button in Project Profile / projects index (`/projects/new`) and the Saved Drafts drawer.
  2. **Health > Customer Engagement > Additional Customer Requirement**: Confirm Sales Manager has MANAGE access (`[1, 1]`) in the baseline and in the UI so they can add/log additional customer requirements, change requirement status, and participate in discussion comments.
  3. **Sales Team Member**: Baseline remains VIEW ONLY (`[1, 0]`) for `Additional Customer Requirement`, Invoice (`[1, 0]`), and all 4 Reports (`[1, 0]`).
* **Root Causes**:
  - The `+ New Project` button in `apps/frontend/src/routes/projects.index.tsx` and the route `/projects/new` check `hasPermission("projects.create")`. When `projects.create` was stripped to prevent general project management, the button and drafts panel were completely hidden.
  - In `apps/frontend/src/routes/projects.$projectId.tsx`, `canManageRequirement` in `AdditionalRequirementsPanel` was wrapped with `!isViewOnly && (...)`. Because Sales Manager has `projects.manage = false`, `isViewOnly` was `true`, which blocked the `+ Log Requirement` button and status/comment edits even though the matrix had Manage `[1, 1]`.
* **Changes Made**:
  1. **Backend Baseline (`RoleBaselines.cs`)**:
     - Added `"projects.create"`, `"projects.drafts"`, and `"projects.health.requirements.manage"` to `RoleBaselines` for `"Sales Manager"`.
  2. **Backend Claim Bridge (`RbacAccessService.cs`)**:
     - Added specific branch:
       ```csharp
       else if (baseRoleClaims.Contains("projects.create"))
       {
           // Sales Manager can onboard/create new projects & drafts without general project management:
           claims.Add("projects.create");
           claims.Add("projects.drafts");
       }
       ```
       This allows project onboarding without granting broad `projects.manage` / `projects:write` (which keeps Team, Tasks, PMO intake, and Invoices read-only).
  3. **Frontend Static Matrix (`matrix.ts`)**:
     - Added `"projects.create"`, `"projects.drafts"`, and `"projects.health.requirements.manage"` to `"Sales Manager"`.
  4. **Frontend UI Permission Guard (`projects.$projectId.tsx`)**:
     - Decoupled `canManageRequirement` from `isViewOnly`:
       ```tsx
       const canManageRequirement =
         isAdmin ||
         isDhanshree ||
         hasAny(
           "Projects|projects Cards|Health|Customer Engagment|Additional customer Requirement:manage",
           "projects.health.requirements.manage",
         );
       ```
     - `+ Log Requirement` button is visible and active for Sales Manager.
     - `RequirementDetailsModal`: status dropdown and comment submission are fully editable for Sales Manager.
     - Sales Team Member has `manage = 0`, keeping the panel in read-only mode (`+ Log Requirement` hidden, modal read-only).

---

### File 34: PMO & Engagement Manager (EM) Baseline Verification & Role Normalization
* **Verification Results**:
  - Both **PMO (Project Management Office)** and **EM (Engagement Manager)** were validated across all 49 leaves against `rbac-baseline.json` and PostgreSQL `auth.tbl_role_widget_permissions` / `auth.vw_role_widget_matrix`.
  - **Results**: **100% exact match across all 49 items for both roles**.
    - **PMO**: All 5 Dashboard items MANAGE `[1, 1]`; Action Center Raise issues, Approvals, Alerts, Notifications MANAGE `[1, 1]`, Start timer NO ACCESS `[0, 0]`; Projects Extension Request, SPM, PM, TL, PMO Intake, Team, Tasks, Health (Issues, Alerts, Escalation, Appreciation, Interview Scheduling) MANAGE `[1, 1]`; Additional customer Requirement VIEW `[1, 0]`; Budget, Billing Info, Invoice Schedule, and Invoice NO ACCESS `[0, 0]`; Reports WBS Tracker MANAGE `[1, 1]`, PO Tracker VIEW `[1, 0]`, Sales & Invoice NO ACCESS `[0, 0]`; Resource Education MANAGE `[1, 1]`, Pool MANAGE `[1, 1]`, Personal/Org/Employment/PMO/Activity Logs/Exit Summary VIEW `[1, 0]`; Customers VIEW `[1, 0]`; Repository MANAGE `[1, 1]`; My team Team Dashboard, My timesheet, Timesheet Approval MANAGE `[1, 1]`; Settings Moduleswise Access, User Role Access, Project Masters MANAGE `[1, 1]`, Customer & Resource Masters VIEW `[1, 0]`.
    - **EM (Engagement Manager)**: All 5 Dashboard items VIEW `[1, 0]`; Action Center Raise issues, Approvals, Alerts, Notifications MANAGE `[1, 1]`, Start timer NO ACCESS `[0, 0]`; Projects SPM, PM, TL, PMO Intake VIEW `[1, 0]`, Budget, Extension Request, Billing Info, Invoice Schedule, and Invoice NO ACCESS `[0, 0]`, Team, Tasks, Health (all 6 items including Additional customer Requirement) MANAGE `[1, 1]`; Reports WBS & PO Tracker VIEW `[1, 0]`, Sales & Invoice NO ACCESS `[0, 0]`; Resource Education MANAGE `[1, 1]`, Pool MANAGE `[1, 1]`, Personal/Org/Employment/PMO/Exit Summary VIEW `[1, 0]`, Activity Logs NO ACCESS `[0, 0]`; Customers VIEW `[1, 0]`; Repository VIEW `[1, 0]`; My team Team Dashboard VIEW `[1, 0]`, My timesheet & Timesheet Approval MANAGE `[1, 1]`; Settings all 5 items VIEW `[1, 0]`.
* **Fixes & Enhancements**:
  1. **Role Name Normalization (`RbacAccessService.cs`)**:
     - Added `NormalizeRoleName` mapping friendly alias strings (`"Engagement Manager"`, `"engagement_manager"`, `"EM"` -> `"EngagementManager"`, `"Project Management Office"`, `"pmo"` -> `"PMO"`, `"Senior Project Manager"`, `"senior_pm"`, `"SPM"` -> `"SeniorPm"`, `"Project Manager"`, `"pm"` -> `"ProjectManager"`).
     - Applied `NormalizeRoleName` in `GetClaimsAsync`, `GetMatrixAsync`, `SaveAsync`, `ResetToDefaultAsync`, and `RoleIdAsync` so API requests querying by friendly display name never trigger a 500 "Role not found" error.
  2. **Baseline Fallback Sync (`RoleBaselines.cs`)**:
     - Synchronized `PMO`, `Pmo`, and added `Project Management Office`. Removed `projects.budget.view` (since Budget is NO ACCESS `[0, 0]`), ensured `Permissions.ProjectsWrite` and `projects.manage` are present.
     - Synchronized `EngagementManager`, and added `Engagement Manager` and `EM` entries. Removed `projects.budget.view`, `projects.overview.edit`, and `customers.edit`. Added `projects.health.requirements.manage`.
  3. **Frontend Static Matrix Sync (`matrix.ts`)**:
     - Synchronized `PMO_CORE`: removed `reports.sales`, `reports.invoice_tracker`, `projects.tab.invoices`, `customers.create`, `customers.change_em`, and added `action.raise_issue`.
     - In `EngagementManager`: filtered out `action.bucket_timer`.

---

### File 35: PMO & Engagement Manager Project Onboarding & Drafts Button Hiding
* **Requirement**: In PMO and Engagement Manager roles, project onboarding (`+ New Project` button) and `Drafts` button were visible in the Projects module. Because neither role has access to onboard new projects (project creation is restricted to Admin/Dhanshree and Sales Manager), these buttons must be hidden, and direct URL access to `/projects/new` must be blocked.
* **Changes Made**:
  1. **Frontend `projects.index.tsx`**:
     - Updated `canCreateProject` to enforce `!isPMO && !isEngagementManager`:
       ```tsx
       const canCreateProject =
         (isAdmin || isDhanshree || hasPermission("projects.create")) &&
         !isPMO &&
         !isEngagementManager;
       ```
     - Guarded `Drafts` button with `canViewDrafts`:
       ```tsx
       const canViewDrafts =
         (isAdmin || isDhanshree || hasPermission("projects.drafts") || hasPermission("projects.create")) &&
         !isEmployee &&
         !isPMO &&
         !isEngagementManager;
       ```
     - Replaced button checks with `canViewDrafts` and `canCreateProject`.
  2. **Frontend `projects.new.tsx`**:
     - Hardened route guard: redirects PMO and Engagement Manager to `/` if they attempt to access `/projects/new` directly.
  3. **Backend `RbacAccessService.cs`**:
     - Separated `projects.create` and `projects.drafts` from general project management so roles with `Permissions.ProjectsWrite` (like PMO and Engagement Manager) do not inherit project onboarding claims unless explicitly present in their baseline.

---

### File 36: R&D — Team Member & SOC Operations — Team Member Baseline Synchronization
* **Verification & Comparison**:
  - Validated all 49 leaves for both **R&D — Team Member (`R&D - Team member`)** and **SOC Operations — Team Member (`SOC-Team Member`)** against `rbac-baseline.json` and PostgreSQL database `auth.tbl_role_widget_permissions`.
  - **Identified Gaps**:
    - Both roles had residual access (`[1, 0]` and `[1, 1]`) to Resource Directory and Resource Details tabs (`Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`). According to the user baseline, all Resource items must be strictly NO ACCESS (`[0, 0]`).
    - In `RoleBaselines.cs` and `matrix.ts`, R&D had leftover Dashboard (`dashboard.view`), Task (`projects.task.view`), Repository upload (`repository.upload`), and My team claims, but was missing Action Center (Bucket List, Raise issue, Start timer, Alerts, Notifications) and Project Overview managers (Sr PM, PM, TL).
    - In `RoleBaselines.cs` and `matrix.ts`, SOC Team Member had leftover Dashboard (`dashboard.view`), Task (`projects.task.view`), and Health (`projects.health.raise-issue`), but was missing Action Center (Bucket List, Raise issue, Start timer, Notifications - Alerts NO ACCESS) and Project Overview managers (Sr PM, PM, TL).
* **Changes Made**:
  1. **`rbac-baseline.json`**:
     - Updated all 5 Resource leaves to `[0, 0]` for both roles. Both roles are now a 100% exact match across all 49 leaves.
  2. **PostgreSQL Database (`auth.tbl_role_widget_permissions`)**:
     - Updated `CanView = 0, CanManage = 0` for all Resource widgets and parent nodes for both role IDs.
  3. **Backend `RoleBaselines.cs`**:
     - Updated `["R&D - Team member"]` and added alias `["R&D Team Member"]` with clean claims matching the baseline.
     - Updated `["SOC-Team Member"]` and added alias `["SOC Team Member"]` with clean claims matching the baseline.
  4. **Backend `RbacAccessService.cs`**:
     - Added role name normalization mapping for `"R&D Team Member"`, `"R&D — Team Member"`, `"R&D -Team member"` -> `"R&D - Team member"` and `"SOC Team Member"`, `"SOC Operations — Team Member"`, `"SOC - Team Member"` -> `"SOC-Team Member"`.
  5. **Frontend `matrix.ts` & `role-context.tsx`**:
     - Updated static permission arrays for `"R&D - Team member"` and `"SOC-Team Member"` (and their display aliases).
     - Added backend role mapping aliases in `roleFromBackend`.

---

### File 37: SOC Operations — Team Member Team Dashboard Hiding
* **Requirement**: For `SOC Operations — Team Member` (`SOC-Team Member`), the `Team Dashboard` submodule under `My Team` should NOT be visible (`NO ACCESS [0, 0]`), while `Timesheets` remains visible (`My timesheet`: MANAGE `[1, 1]`, `Timesheet Approval`: VIEW `[1, 0]`).
* **Changes Made**:
  1. **`rbac-baseline.json`**:
     - Updated leaf 42 (`My team > Team Dashboard`) for `SOC-Team Member` to `[0, 0]`.
  2. **PostgreSQL Database (`auth.tbl_role_widget_permissions`)**:
     - Set `CanView = 0, CanManage = 0` for widget `Team Dashboard` for role `SOC-Team Member`.
  3. **Backend `RoleBaselines.cs`**:
     - Removed `"my-team.dashboard.view"` from `["SOC-Team Member"]` and `["SOC Team Member"]`.
  4. **Backend `RbacAccessService.cs`**:
     - In `Bridge`, isolated `Permissions.MyTeamDashboardView` and `"my-team.team-dashboard.view"` so they are strictly issued only when the leaf is `"Team Dashboard"` and `view == 1` (never leaked from other `My team` leaves like timesheet).
  5. **Frontend `matrix.ts`**:
     - Removed `"my_team.dashboard"` from `"SOC-Team Member"` and `"SOC Team Member"`.
  6. **Frontend `my-team.index.tsx`**:
     - Added route guard: if user lacks `Team Dashboard:view` permission, automatically redirects to `/my-team/timesheets` instead of displaying the Team Dashboard.

---

### File 38: SOC — Team Leader Baseline Comparison & Synchronization
* **Baseline Verification & Comparison**:
  - Validated all 49 leaves for **SOC - Team Leader (`SOC-Team Leader`)** against user specifications, `rbac-baseline.json`, and PostgreSQL database `auth.tbl_role_widget_permissions`.
  - **Discrepancies Identified**:
    - **Resource Directory & Details**: Had residual access (`[1, 0]` and `[1, 1]`) across leaves #32–#36 (`Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`). User specification strictly mandates `NO ACCESS [0, 0]` for all Resource Directory / Details tabs, while `Resource Pool` is `MANAGE [1, 1]` and `Exit Summary` is `VIEW [1, 0]`.
    - **Backend `RoleBaselines.cs`**: `SOC-Team Leader` had leftover `"dashboard.view"` (Dashboard is strictly NO ACCESS), and lacked Action Center permissions (`action-center.view`, `action-center.manage`, `action.bucket_list`, `action.raise_issue`, `action.bucket_timer`, `action.alerts`, `action.notifications`), Resource Pool (`resources.pool`, `resources.pool.manage`), Exit Summary (`resources.exit_summary`, `resources.exit_summary.view`), and Project Overview view claims (`projects.overview.view_spm`, `projects.overview.view_pm`, `projects.overview.view_tl`).
    - **Backend `RbacAccessService.cs`**: Missing normalization mapping for aliases `"SOC Team Leader"`, `"SOC Shift / Team Leader"`, `"SOC - Team Leader"`, and `"SOC-TL"`.
    - **Frontend `matrix.ts` & `role-context.tsx`**: Static permissions array in `matrix.ts` had `"dashboard.view"`, missed Action Center and Resource Pool/Exit Summary keys, and was missing aliases.
* **Changes Made**:
  1. **`rbac-baseline.json`**:
     - Updated leaves #32–#36 to `[0, 0]` for `SOC-Team Leader`. Verified with comparison script: 0 differences remaining across all 49 leaves (100% exact match).
  2. **PostgreSQL Database (`auth.tbl_role_widget_permissions`)**:
     - Executed update for `SOC-Team Leader` (Role ID `aba61e5b-422a-4461-b9da-8dba8f6d3f85`), setting `CanView = 0, CanManage = 0` on all Resource Directory and Resource Details widgets and parent nodes.
     - Confirmed `Resource Pool` remains `CanView = 1, CanManage = 1` and `Exit Summary` remains `CanView = 1, CanManage = 0`.
  3. **Backend `RoleBaselines.cs`**:
     - Updated `["SOC-Team Leader"]` and added alias keys `["SOC Team Leader"]` and `["SOC Shift / Team Leader"]` matching the exact baseline.
  4. **Backend `RbacAccessService.cs`**:
     - Added normalization aliases for `"SOC Shift / Team Leader"`, `"SOC Team Leader"`, `"SOC - Team Leader"`, and `"SOC-TL"` mapping directly to `"SOC-Team Leader"`.
  5. **Frontend `matrix.ts` & `role-context.tsx`**:
     - Updated `matrix.ts` for `"SOC-Team Leader"` and added `"SOC Team Leader"` alias.
     - Added `"SOC Team Leader"`, `"SOC Shift / Team Leader"`, and `"SOC - Team Leader"` to `roleFromBackend` in `role-context.tsx`.

---

### File 39: Project Loading Fault Tolerance for Roles Without Customer / Resource Access
* **Problem**:
  - When switching to **SOC Team Member**, **SOC Team Lead**, or **R&D Team Member**, navigating to `/projects` showed:
    ```
    Could not load projects from the database
    Request failed (403)
    Start the API with dotnet run --project apps/backend/PMS.API.csproj --urls http://localhost:5194 against local Postgres, then refresh.
    ```
  - **Root Cause**:
    - The projects endpoint `/api/v1/projects` returns `200 OK` (these roles have `Permissions.ProjectsRead`).
    - However, `projects.index.tsx` executed `Promise.all([ fetchProjects(), fetchClients(), fetchEmployees() ])`.
    - Because `SOC Team Leader`, `SOC Team Member`, and `R&D Team Member` have `NO ACCESS [0, 0]` to **Customers** (`/api/v1/clients`), the backend correctly returned `403 Forbidden`.
    - Similarly, `SOC Team Member` and `R&D Team Member` have `NO ACCESS [0, 0]` to **Resource Directory** (`/api/v1/employees`), returning `403 Forbidden`.
    - An uncaught error in any promise caused `Promise.all` to reject, triggering the error screen and hiding all projects.
* **Fix Applied**:
  1. **Fault-Tolerant Fetching** ([`projects.index.tsx`](file:///c:/Users/Pradnya%20Kamble/Downloads/Talakunchi/project_TrackerPro/apps/frontend/src/routes/projects.index.tsx)):
     - Added `.catch(() => [] as ApiClient[])` to `fetchClients` and `.catch(() => null)` to `fetchEmployees`.
     - Only `fetchProjects()` determines page success.
  2. **Metadata Synthesis**:
     - `ProjectDto` already includes `ClientName` and `ClientLogo`. When `dbClients` is empty (user lacks Customers module permissions), `projects.index.tsx` synthesizes client fallback records directly from project records.
     - Added `clientName: p.clientName ?? undefined` to mapped project items.
  3. **Project Details** ([`projects.$projectId.tsx`](file:///c:/Users/Pradnya%20Kamble/Downloads/Talakunchi/project_TrackerPro/apps/frontend/src/routes/projects.$projectId.tsx)):
     - Updated client fallback to use `(project as any).clientName || "Client"` when client is not found in client directory.

---

### File 40: Resource Directory vs Resource Pool Isolation & Project Overview Leadership View-Only

* **Requirements**:
  1. **SOC Team Leader (`SOC-Team Leader`)**:
     - `Resource Directory` must be **HIDDEN** (`[0, 0]`).
     - `Resource Pool` must remain **ACCESSIBLE with MANAGE access** (`[1, 1]`).
  2. **R&D Team Member (`R&D - Team member`)** & **SOC Team Member (`SOC-Team Member`)**:
     - In **Project Overview**, `Senior Project Manager`, `Project Manager`, and `Team Lead` cards were previously hidden because they were grouped with editing capabilities.
     - They must now be **VISIBLE in VIEW-ONLY mode** (`[1, 0]`, displaying contacts and assignments without edit/assign buttons).

* **Root Causes**:
  - In `navigation.tsx`, Directory and Resource Pool were bundled into a single sidebar sub-item (`Directory & Resource Pool`). When any role had access to either, both tabs were accessible in the UI.
  - In `dh-employee-directory.index.tsx`, `canViewDirectory` fell back to `resources.view`. Because any user with Resource Pool access had the parent module view claim, the directory tab remained accessible.
  - In `projects.$projectId.tsx`, the leadership assignment section (`showLeadership`) required `isPmFamily`, `isPmoFamily`, `isAccounts`, `isSales`, or `canManage...`. Roles configured with View-only (`[1, 0]`) did not satisfy these checks, hiding the leadership section entirely. Furthermore, when `showSidebar` was false (since team members have NO ACCESS to Extension Request or Customers), the leadership grid didn't render.

* **Changes Made**:
  1. **Sidebar Navigation Split** ([`navigation.tsx`](file:///c:/Users/Pradnya%20Kamble/Downloads/Talakunchi/project_TrackerPro/apps/frontend/src/lib/navigation.tsx)):
     - Split into two independent sub-items under Resource:
       - `Resource Directory`: requires `["Resource|Resource Directory:view", "resources.directory.view"]`.
       - `Resource Pool`: targets `/dh-employee-directory` with `search: { tab: "pool" }`, requires `["Resource|Reource Pool:view", "Resource|Resource Pool:view", "resources.pool.view", "resources.pool"]`.
     - When `Resource Directory` is `[0, 0]`, it is automatically hidden from the sidebar.
  2. **Directory & Pool Page Decoupling** ([`dh-employee-directory.index.tsx`](file:///c:/Users/Pradnya%20Kamble/Downloads/Talakunchi/project_TrackerPro/apps/frontend/src/routes/dh-employee-directory.index.tsx)):
     - Removed parent module claim from `canViewDirectory`, strictly requiring `Resource|Resource Directory:view` or `resources.directory.view`.
     - When `canViewDirectory = false` and `canViewPool = true`:
       - The `[Directory] / [Resource Pool]` switcher tabs are hidden.
       - The page strictly defaults and locks to the `"pool"` tab.
       - Employee links in the pool table open the allocation/workload modal in view mode instead of navigating to the blocked employee detail page.
       - Defined `canManagePool` (`Resource|Reource Pool:manage`, `Resource|Resource Pool:manage`, `resources.pool.manage`) which guards the `+ Request Allocation` button.
  3. **Employee Detail Route Guard** ([`dh-employee-directory.$id.tsx`](file:///c:/Users/Pradnya%20Kamble/Downloads/Talakunchi/project_TrackerPro/apps/frontend/src/routes/dh-employee-directory.$id.tsx)):
     - Direct URL navigation to `/dh-employee-directory/$id` redirects users without directory view access cleanly to `/dh-employee-directory?tab=pool`.
  4. **Project Overview Leadership Cards Restored as View-Only** ([`projects.$projectId.tsx`](file:///c:/Users/Pradnya%20Kamble/Downloads/Talakunchi/project_TrackerPro/apps/frontend/src/routes/projects.$projectId.tsx)):
     - Added granular view flags: `canViewSpm`, `canViewPm`, `canViewTl` checking exact baseline claims (`Projects|projects Cards|Overview|Sr.project Manger:view`, `Project manager:view`, `Team leads:view`).
     - Added `canViewSpm || canViewPm || canViewTl` into `showLeadership`.
     - Decoupled `showSidebar` (`canViewCustomer || canManageExtension || canViewExtension`) from leadership rendering so that the leadership grid renders cleanly across 3 columns when the sidebar is hidden.
     - Passed `viewOnly={!canManage...}` to SPM, PM, and TL blocks: Team members can see assigned Senior Project Managers, Project Managers, and Team Leads in read-only mode with assign/edit buttons completely hidden.
     - Destructured `isAdmin` from `useRoleContext()` in `OverviewTab` resolving runtime `ReferenceError: isAdmin is not defined`.

---

### File 41: Consulting — Team Member & Consulting — Team Leader Baseline Synchronization

* **Requirements**:
  1. **Consulting -Team member (`Consulting-Team member`)**:
     - Action Center: Bucket List Raise issues (`[1, 1]`), Start timer (`[1, 1]`), Notifications (`[1, 1]`); Approvals & Alerts (`[0, 0]`).
     - Projects: Overview Sr. Project Manager (`[1, 0]`), Project Manager (`[1, 0]`), Team leads (`[1, 0]`); Budget, Extension Request, WBS, Team, Task, Health (all 6 items), and Invoices strictly NO ACCESS (`[0, 0]`).
     - Reports: All 4 reports NO ACCESS (`[0, 0]`).
     - Resource: All Resource Directory tabs, Resource Pool, and Exit Summary strictly NO ACCESS (`[0, 0]`).
     - Customers: NO ACCESS (`[0, 0]`).
     - Repository: VIEW (`[1, 0]`).
     - My team: Team Dashboard strictly NO ACCESS (`[0, 0]`); My timesheet MANAGE (`[1, 1]`); Timesheet Approval VIEW (`[1, 0]`).
     - Settings: All items NO ACCESS (`[0, 0]`).
  2. **Consulting - Team Leader (`Consulting-Team Leader`)**:
     - Action Center: Bucket List Raise issues (`[1, 1]`), Start timer (`[1, 1]`), Alerts VIEW (`[1, 0]`), Notifications MANAGE (`[1, 1]`); Approvals NO ACCESS (`[0, 0]`).
     - Projects: Overview Sr. PM, PM, Team leads VIEW (`[1, 0]`); Team MANAGE (`[1, 1]`), Task MANAGE (`[1, 1]`); Health Issues, Alerts, Escalation, Appreciation, Interview Scheduling, Additional customer Requirement VIEW (`[1, 0]`); Budget, Extension Request, WBS, Invoices NO ACCESS (`[0, 0]`).
     - Reports: All 4 reports NO ACCESS (`[0, 0]`).
     - Resource: Resource Directory & Details strictly NO ACCESS (`[0, 0]`); Resource Pool MANAGE (`[1, 1]`); Exit Summary VIEW (`[1, 0]`).
     - Customers: NO ACCESS (`[0, 0]`).
     - Repository: VIEW (`[1, 0]`).
     - My team: Team Dashboard MANAGE (`[1, 1]`); My timesheet MANAGE (`[1, 1]`); Timesheet Approval MANAGE (`[1, 1]`).
     - Settings: All items NO ACCESS (`[0, 0]`).

* **Discrepancies Identified in Existing Configuration**:
  - `Consulting-Team member`: had residual access (`[1, 0]` and `[1, 1]`) to Resource Directory & Details (`Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`), and had Team Dashboard set to `[1, 0]` (which must be `[0, 0]`).
  - `Consulting-Team Leader`: had residual access (`[1, 0]` and `[1, 1]`) to Resource Directory & Details (`Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`).
  - `RoleBaselines.cs`: Completely lacked entries for `Consulting-Team member` and `Consulting-Team Leader` (falling back to empty arrays).
  - `RbacAccessService.cs`: Lacked role normalization for variations like `"Consulting -Team member"`, `"Consulting - Team member"`, `"Consulting - Team Leader"`, etc.
  - `matrix.ts`: Had stale keys (`dashboard.view`, `my_team.dashboard` for team member, missing Action Center and Overview leadership keys).

* **Changes Made**:
  1. **`rbac-baseline.json`**:
     - Updated all leaves for `Consulting-Team member` and `Consulting-Team Leader`. Verified with script: 100% exact match across all 49 leaves.
  2. **PostgreSQL Database (`auth.tbl_role_widget_permissions`)**:
     - Reset permissions directly from baseline via `POST /api/v1/rbac/matrix/reset` for both `Consulting-Team member` and `Consulting-Team Leader`. Verified effective permissions via `GET /api/v1/rbac/effective`.
  3. **Backend `RoleBaselines.cs`**:
     - Added baseline dictionaries and aliases for `["Consulting-Team Leader"]`, `["Consulting - Team Leader"]`, `["Consulting Team Leader"]`, `["Consulting-Team member"]`, `["Consulting -Team member"]`, `["Consulting - Team member"]`, and `["Consulting Team Member"]`.
  4. **Backend `RbacAccessService.cs`**:
     - Added normalization aliases in `NormalizeRoleName` mapping all spelling variants directly to `"Consulting-Team member"` and `"Consulting-Team Leader"`.
  5. **Frontend `role-context.tsx` & `matrix.ts`**:
     - Added display name and role aliases in `roleFromBackend`.
     - Updated static matrix definitions in `matrix.ts` for both roles and their aliases to exactly mirror the baseline.

---

### File 42: Testing — Team Member & Testing — Team Leader Baseline Synchronization

* **Requirements**:
  1. **Testing - Team Member (`Testing-Team Member`)**:
     - Action Center: Bucket List Raise issues (`[1, 1]`), Start timer (`[1, 1]`), Notifications (`[1, 1]`); Approvals & Alerts (`[0, 0]`).
     - Projects: Overview Sr. Project Manager (`[1, 0]`), Project Manager (`[1, 0]`), Team leads (`[1, 0]`); Budget, Extension Request, WBS, Team, Task, Health (all 6 items), and Invoices strictly NO ACCESS (`[0, 0]`).
     - Reports: All 4 reports NO ACCESS (`[0, 0]`).
     - Resource: All Resource Directory tabs, Resource Pool, and Exit Summary strictly NO ACCESS (`[0, 0]`).
     - Customers: NO ACCESS (`[0, 0]`).
     - Repository: VIEW (`[1, 0]`).
     - My team: Team Dashboard VIEW (`[1, 0]`) *(read-only shift inspection; editing/shift assignments locked)*; My timesheet MANAGE (`[1, 1]`); Timesheet Approval VIEW (`[1, 0]`).
     - Settings: All items NO ACCESS (`[0, 0]`).
  2. **Testing - Team Leader (`Testing-Team Leader`)**:
     - Action Center: Bucket List Raise issues (`[1, 1]`), Start timer (`[1, 1]`), Alerts VIEW (`[1, 0]`), Notifications MANAGE (`[1, 1]`); Approvals NO ACCESS (`[0, 0]`).
     - Projects: Overview Sr. PM, PM, Team leads VIEW (`[1, 0]`); Team MANAGE (`[1, 1]`), Task MANAGE (`[1, 1]`); Health Issues, Alerts, Escalation, Appreciation, Interview Scheduling, Additional customer Requirement VIEW (`[1, 0]`); Budget, Extension Request, WBS, Invoices NO ACCESS (`[0, 0]`).
     - Reports: All 4 reports NO ACCESS (`[0, 0]`).
     - Resource: Resource Directory & Details strictly NO ACCESS (`[0, 0]`); Resource Pool MANAGE (`[1, 1]`); Exit Summary VIEW (`[1, 0]`).
     - Customers: NO ACCESS (`[0, 0]`).
     - Repository: VIEW (`[1, 0]`).
     - My team: Team Dashboard MANAGE (`[1, 1]`); My timesheet MANAGE (`[1, 1]`); Timesheet Approval MANAGE (`[1, 1]`).
     - Settings: All items NO ACCESS (`[0, 0]`).

* **Discrepancies Identified in Existing Configuration**:
  - `Testing-Team Member`: had residual access (`[1, 0]` and `[1, 1]`) to Resource Directory & Details (`Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`). Team Dashboard was correctly configured with VIEW `[1, 0]`.
  - `Testing-Team Leader`: had residual access (`[1, 0]` and `[1, 1]`) to Resource Directory & Details (`Personal Information`, `orgnization deatile`, `employment and bond`, `Eduacation and experience`, `Pmo information`).
  - `RoleBaselines.cs`: Completely lacked entries for `Testing-Team Member` and `Testing-Team Leader` (falling back to empty arrays).
  - `RbacAccessService.cs`: Lacked role normalization for variations like `"Testing - Team Member"`, `"Testing - Team Leader"`, etc.
  - `matrix.ts`: Had legacy keys (`dashboard.view`, `projects.tab.team`, `projects.tab.tasks` for team member, missing Action Center and Overview leadership keys).

* **Changes Made**:
  1. **`rbac-baseline.json`**:
     - Updated all leaves for `Testing-Team Member` and `Testing-Team Leader`. Verified with script: 100% exact match across all 49 leaves.
  2. **PostgreSQL Database (`auth.tbl_role_widget_permissions`)**:
     - Reset permissions directly from baseline via `POST /api/v1/rbac/matrix/reset` for both `Testing-Team Member` and `Testing-Team Leader`. Verified effective permissions via `GET /api/v1/rbac/effective`.
  3. **Backend `RoleBaselines.cs`**:
     - Added baseline dictionaries and aliases for `["Testing-Team Leader"]`, `["Testing - Team Leader"]`, `["Testing Team Leader"]`, `["Testing-Team Member"]`, `["Testing - Team Member"]`, `["Testing Team Member"]`, and `["Testing -Team member"]`.
  4. **Backend `RbacAccessService.cs`**:
     - Added normalization aliases in `NormalizeRoleName` mapping all spelling variants directly to `"Testing-Team Member"` and `"Testing-Team Leader"`.
  5. **Frontend `role-context.tsx` & `matrix.ts`**:
     - Added display name and role aliases in `roleFromBackend`.
     - Updated static matrix definitions in `matrix.ts` for both roles and their aliases to exactly mirror the baseline.


---

### 43. `SOC - Manager`, `Consulting - Manager`, and `Testing - Manager` Baseline Verification & Synchronization

* **Baseline Comparison Summary**:
  - All three Manager roles (`SOC - Manager`, `Consulting - Manager`, `Testing - Manager`) share an identical permission profile across all 49 leaves in the RBAC hierarchy.
  - **Dashboard**: All 5 leaves = `VIEW [1, 0]` (KPI'S, Assigned Projects, Pending issues, Project status, Pending approvals).
  - **Action Center**: All 5 leaves = `MANAGE [1, 1]` (Bucket List: Raise issues, Start timer; Approvals, Alerts, Notifications).
  - **Projects > Overview**: Budget = `NO ACCESS [0, 0]`, Extension Request = `NO ACCESS [0, 0]`, Sr.project Manger = `VIEW [1, 0]`, Project manager = `VIEW [1, 0]`, Team leads = `VIEW [1, 0]`.
  - **Projects > WBS**: Billing Information = `NO ACCESS [0, 0]`, PMO Intake & Prerequisite Workflow = `VIEW [1, 0]`, Invoice Schedule = `NO ACCESS [0, 0]`.
  - **Projects > Cards**: Team = `MANAGE [1, 1]`, Task = `MANAGE [1, 1]`.
  - **Projects > Health**: Issues = `MANAGE [1, 1]`, Alerts = `MANAGE [1, 1]`, Escalation = `MANAGE [1, 1]`, Appreciation = `MANAGE [1, 1]`, Customer Engagement > Interview Scheduling = `MANAGE [1, 1]`, Additional customer Requirement = `MANAGE [1, 1]`.
  - **Projects > Invoices**: `NO ACCESS [0, 0]`.
  - **Reports**: Sales Report = `NO ACCESS [0, 0]`, WBS Tracker = `VIEW [1, 0]`, PO Tracker = `VIEW [1, 0]`, Invoice tracker = `NO ACCESS [0, 0]`.
  - **Resource > Resource Directory**: Personal Information = `VIEW [1, 0]`, organization details = `VIEW [1, 0]`, employment and bond = `VIEW [1, 0]`, Education and experience = `MANAGE [1, 1]`, PMO information = `VIEW [1, 0]`, Activity Logs = `NO ACCESS [0, 0]`.
  - **Resource**: Resource Pool = `MANAGE [1, 1]`, Exit Summary = `VIEW [1, 0]`.
  - **Customers**: Customer profile = `VIEW [1, 0]`.
  - **Repository**: `VIEW [1, 0]`.
  - **My team**: Team Dashboard = `MANAGE [1, 1]`, My timesheet = `MANAGE [1, 1]`, Timesheet Approval = `MANAGE [1, 1]`.
  - **Settings**: All 5 leaves = `NO ACCESS [0, 0]`.

* **Baseline Comparison Results**:
  - `apps/backend/Modules/Rbac/rbac-baseline.json` already contained 100% exact matches across all 49 leaves for `SOC-Manager`, `Consulting-Manager`, and `Testing-Manager`.
  - `RoleBaselines.cs`: Lacked explicit baseline dictionaries for the Manager roles, risking empty fallbacks if DB queries fail.
  - `RbacAccessService.cs`: Lacked name normalization mappings for spaced/hyphenated variations (e.g., `"SOC - Manager"`, `"SOC Manager"`, etc.).
  - `matrix.ts`: Manager roles were mapped to `PM_CORE`, which lacked `my_team.dashboard`, `reports.wbs_tracker`, and `reports.po_tracker`.

* **Changes Made**:
  1. **PostgreSQL Database (`auth.tbl_role_widget_permissions`)**:
     - Reset permissions directly from baseline JSON via `POST /api/v1/rbac/matrix/reset` for `SOC-Manager`, `Consulting-Manager`, and `Testing-Manager`. Verified effective claims via `GET /api/v1/rbac/effective`.
  2. **Backend `RoleBaselines.cs`**:
     - Created `ManagerKeys()` helper containing the exact claims for all 49 leaves.
     - Registered entries for `SOC-Manager`, `SOC - Manager`, `SOC Manager`, `Consulting-Manager`, `Consulting - Manager`, `Consulting Manager`, `Testing-Manager`, `Testing - Manager`, and `Testing Manager`.
  3. **Backend `RbacAccessService.cs`**:
     - Added normalization aliases in `NormalizeRoleName` mapping spaced/hyphenated variations directly to their standard DB role names.
  4. **Frontend `role-context.tsx` & `matrix.ts`**:
     - Added role display mapping and aliases in `roleFromBackend`.
     - Defined dedicated `MANAGER_CORE` permission map in `matrix.ts` and assigned it to `Testing-Manager`, `Consulting-Manager`, `SOC-Manager`, and their aliases.


---

### 44. Resources Sidebar Unification & Project Manager Section-Level Profile Edit RBAC

* **Sidebar Navigation Unification**:
  - **Issue**: For Project Managers (`SOC - Manager`, `Consulting - Manager`, `Testing - Manager`), both `Resource Directory` (View) and `Resource Pool` (Manage) permissions were enabled. Because both were granted, the sidebar dropdown rendered two separate links (`Resource Directory` and `Resource Pool`), both pointing to `/dh-employee-directory`.
  - **Resolution**: Updated `filterNavItems` in `apps/frontend/src/lib/navigation.tsx` so that when a role has access to both `Resource Directory` and `Resource Pool`, they are automatically unified into a single clean `Resource Directory` link under `Resources`. Roles with only `Resource Pool` access (such as Team Leaders) continue to see `Resource Pool`.

* **Section-Level Profile Edit Restriction**:
  - **Issue**: When a PM, PMO, or Engagement Manager opened an employee's profile and clicked "Edit Profile", all five canonical sections (Personal Information, Organization Assignment, Employment Information, Education & Experience, PMO Information) were fully interactive and editable, despite these roles having `View [1, 0]` on Personal, Org, Employment, and PMO, and `Manage [1, 1]` ONLY on Education & Experience.
  - **Resolution**:
    1. In `apps/frontend/src/components/employee-form-modal.tsx`, integrated `useRoleContext()` and `usePermissions()` to compute granular `canManagePersonal`, `canManageOrg`, `canManageEmployment`, `canManageEducation`, and `canManagePmo`.
    2. Passed `disabled={mode === "edit" && !canManageSection}` to each `<FormSection>`. When disabled, the section displays a `View Only` badge and applies `pointer-events-none opacity-60` to its fieldset, preventing any click, focus, or edit.
    3. For Project Managers, PMO, and Engagement Managers (`isLimitedEditor`), Sections 1, 2, 3, and 5 are completely uneditable (`View Only`), while Section 4 (`Education & Experience`) remains active and editable.
### 45. SOC - Senior Manager & SOC - HOD Baseline Alignment and Synchronization

* **Full 49-Leaf Baseline Verification & Reset**:
  - Point-by-point cross-comparison between user specifications and `apps/backend/Modules/Rbac/rbac-baseline.json` confirmed 100% exact alignment across all 49 catalog leaves for both `SOC-Senior Manager` and `SOC-HOD`.
  - Executed database matrix reset via `POST /api/v1/rbac/matrix/reset` for both roles, updating `auth.tbl_role_widget_permissions` in PostgreSQL with exact `CanView` and `CanManage` grants.
* **Exact Leaf Breakdown**:
  1. **Dashboard** (5 leaves): All `[1, 0]` (`VIEW`) for both roles.
  2. **Action Center** (5 leaves):
     - `Start timer`: `[0, 0]` (`NO ACCESS`) for both roles.
     - `Raise issues`, `Approvals`, `Alerts`, `Notifications`: `[1, 1]` (`MANAGE`) for both roles.
  3. **Projects Cards > Overview** (5 leaves):
     - `Budget`: `[0, 0]` (`NO ACCESS`) for **Senior Manager**; `[1, 0]` (`VIEW`) for **HOD**.
     - `Extension Request`: `[0, 0]` (`NO ACCESS`) for both roles.
     - `Sr.project Manger`, `Project manager`, `Team leads`: `[1, 0]` (`VIEW`) for both roles.
  4. **Projects Cards > WBS** (3 leaves):
     - `Billing Information`: `[0, 0]` (`NO ACCESS`) for **Senior Manager**; `[1, 0]` (`VIEW`) for **HOD**.
     - `PMO Intake & Prerequisite Workflow`: `[1, 0]` (`VIEW`) for both roles.
     - `Invoice Schedule`: `[0, 0]` (`NO ACCESS`) for both roles.
  5. **Projects Cards > Team & Task** (2 leaves):
     - `Team`: `[1, 0]` (`VIEW`) for both roles.
     - `Task`: `[1, 0]` (`VIEW`) for both roles.
  6. **Projects Cards > Health** (6 leaves):
     - `Issues`, `Alerts`, `Escalation`, `Appreciation`, `Additional customer Requirement`: `[1, 1]` (`MANAGE`) for both roles.
     - `Interview Scheduling`: `[1, 0]` (`VIEW`) for both roles.
  7. **Projects Cards > Invoice** (1 leaf):
     - `Invoice`: `[0, 0]` (`NO ACCESS`) for **Senior Manager**; `[1, 0]` (`VIEW`) for **HOD**.
  8. **Reports** (4 leaves):
     - `Sales Report`, `Invoice tracker`: `[0, 0]` (`NO ACCESS`) for both roles.
     - `WBS Tracker`, `PO Tracker`: `[1, 0]` (`VIEW`) for both roles.
  9. **Resource** (8 leaves):
     - `Personal Information`, `Organization details`, `Employment and bond`, `PMO information`, `Exit Summary`: `[1, 0]` (`VIEW`) for both roles.
     - `Education and experience`, `Resource Pool`: `[1, 1]` (`MANAGE`) for both roles.
     - `Activity Logs`: `[0, 0]` (`NO ACCESS`) for both roles.
  10. **Customers & Repository** (2 leaves):
      - `Customer profile`: `[1, 0]` (`VIEW`) for both roles.
      - `Repository`: `[1, 0]` (`VIEW`) for both roles.
  11. **My Team** (3 leaves):
      - `Team Dashboard`, `My timesheet`, `Timesheet Approval`: `[1, 1]` (`MANAGE`) for both roles.
  12. **Settings** (5 leaves):
      - `Moduleswise Access`, `User Role Access`, `Project Masters`, `Customer Masters`, `Resource Master`: `[1, 0]` (`VIEW`) for both roles.
* **Component-Level Dynamic Guards**:
  - In `apps/frontend/src/routes/projects.$projectId.tsx`:
    - Updated `OverviewTab` and `WbsTab` so that budget amounts and budget burn are strictly driven by `canViewBudget` (derived from `Projects|projects Cards|Overview|Budget:view`).
    - Guarded WBS `Billing Information` cards with `canViewBilling` (`Projects|projects Cards|WBS|Billing Information:view`), ensuring Billing Information is hidden for Senior Manager (`[0, 0]`) and visible for HOD (`[1, 0]`).
    - Guarded WBS `Invoice Schedule` with `canViewInvoiceSchedule` (`Projects|projects Cards|WBS|Invoice Schedule:view`), ensuring it is hidden for both (`[0, 0]`).
    - Invoices tab visibility is guarded with `canViewInvoices` (`Projects|projects Cards|Invoice:view`), remaining hidden for Senior Manager (`[0, 0]`) and visible for HOD (`[1, 0]`).
* **Backend Normalization & Fallbacks**:
  - In `apps/backend/Modules/Rbac/RbacAccessService.cs`, updated `NormalizeRoleName` with aliases for `SOC - Senior Manager`, `SOC Senior Manager`, `SOC - HOD`, `SOC HOD`, and `SOC Head of Department`.
  - In `apps/backend/Shared/Constants/RoleBaselines.cs`, aligned `SOC-Senior Manager` and `SOC-HOD` baseline lists to accurately reflect these grants.
  - In `apps/frontend/src/lib/rbac/matrix.ts`, configured `SOC_SENIOR_MANAGER_CORE` and `SOC_HOD_CORE`.
### 46. Project Health Granular RBAC: Full View/Manage with View-Only Interview Scheduling

* **Requirement**:
  - For `SOC - Senior Manager` and `SOC - HOD`, the entire **Project Health** tab must have both **VIEW** and **MANAGE** access across all sections (Issues, Alerts, Escalations, Appreciation, Additional Customer Requirement), **EXCEPT Interview Scheduling**, which must be strictly **VIEW ONLY**.
* **Fixes & Refinements**:
  1. **Decoupled from Global `isViewOnly`**:
     - Removed legacy `!isViewOnly` gating in `HealthTab` for `canManageIssues`, `canManageEscalations`, and `canManageAppreciation`. Permissions are now directly driven by granular database matrix rights (`Projects|projects Cards|Health|Issues:manage`, `Projects|projects Cards|Health|Escalation:manage`, `Projects|projects Cards|Health|Appreciation:manage`, `Projects|projects Cards|Health|Aletrs:manage`).
  2. **Alerts Management (`HealthAlertsPanel`)**:
     - Connected `canManageAlerts` to `HealthAlertsPanel`. Users with manage access can now directly acknowledge (`Acknowledge`) and resolve (`Resolve`) project alerts within the Health tab.
  3. **Issues Management (`HealthIssuesPanel`)**:
     - Users with manage access can raise issues and update issue statuses (`open`, `in_progress`, `resolved`, `closed`). For view-only roles, a read-only status badge is rendered.
  4. **Strict Isolation of Interview Scheduling (`DhClientEngagementTab` & `ClientCommTab`)**:
     - Removed broad `projects.health.customer_engagement.manage` check from `isEM`.
     - `isEM` now strictly requires explicit `Interview Scheduling:manage` (`Projects|projects Cards|Health|Customer Engagment|Interview Scheduling:manage` or `projects.health.interviews.manage`).
     - Because `SOC - Senior Manager` and `SOC - HOD` have `CanManage: 0` for Interview Scheduling, `isEM` evaluates to `false`. The `Schedule Interview` button and status update dropdowns are hidden, rendering the interviews strictly in **VIEW ONLY** mode.
     - `Additional Customer Requirement` remains fully manageable (`canManageRequirement: true`) via `Projects|projects Cards|Health|Customer Engagment|Additional customer Requirement:manage`.

---

## 3. How the 0 and 1 System Operates


```
Matrix Setting (Database)
├── View = 0, Manage = 0  ──> Module/Tab hidden from navigation; route redirects to "/"
├── View = 1, Manage = 0  ──> Page, tables, search, filters & details are VISIBLE;
│                             all action buttons (+ New, Edit, Delete, Change, Submit) are HIDDEN
└── View = 1, Manage = 1  ──> Full access: page visible + action buttons visible & functional
```


