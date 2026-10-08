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

---

## 3. How the 0 and 1 System Operates

```
Matrix Setting (Database)
├── View = 0, Manage = 0  ──> Module/Tab hidden from navigation; route redirects to "/"
├── View = 1, Manage = 0  ──> Page, tables, search, filters & details are VISIBLE;
│                             all action buttons (+ New, Edit, Delete, Change, Submit) are HIDDEN
└── View = 1, Manage = 1  ──> Full access: page visible + action buttons visible & functional
```


