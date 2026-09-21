# Implementation Guide: Settings, Masters & Role-Based Access Control (RBAC)
## TrackerPro / Pulse PMO — Technical Reference

---

## Table of Contents
1. [How the System Works — Big Picture](#1-how-the-system-works--big-picture)
2. [Understanding the Permission System](#2-understanding-the-permission-system)
3. [System Roles and Their Access Levels](#3-system-roles-and-their-access-levels)
4. [Part A: Implementing Settings & Masters Module (Backend)](#4-part-a-implementing-settings--masters-module-backend)
5. [Part B: Implementing Settings & Masters (Frontend)](#5-part-b-implementing-settings--masters-frontend)
6. [Part C: Implementing RBAC — Module Access Control (Backend)](#6-part-c-implementing-rbac--module-access-control-backend)
7. [Part D: Implementing RBAC — User Access (Frontend)](#7-part-d-implementing-rbac--user-access-frontend)
8. [How Everything Connects in the Database](#8-how-everything-connects-in-the-database)
9. [Step-by-Step Checklist](#9-step-by-step-checklist)

---

## 1. How the System Works — Big Picture

There are **two modules** you need to implement:

### Module A — Settings & Masters
This module lets administrators configure **lookup data** used throughout the app.
For example:
- What contract types exist (Scope Based, Time & Materials, Fixed Bid)
- What departments exist (Engineering, Product, Delivery)
- What industries clients can belong to (Healthcare, BFSI, SaaS)
- What countries and cities are available during onboarding

Without this data in the database, dropdowns and selectors across the entire app will be empty.

### Module B — User & Module Access (RBAC)
This module controls **who can do what** in the app.
For example:
- A `sales` user can create clients and view projects but cannot manage roles or access timesheets.
- An `hr` user can only manage resources and view the repository — nothing else.
- A `pmo` user can see everything but cannot create or edit.
- `Dhanshree` is the super-admin and has access to everything.

```
┌─────────────────────────────────────────────────────────────────┐
│                         TRACKERP PRO                            │
│                                                                 │
│   User Logs In → JWT Created with Permissions Embedded          │
│          ↓                                                      │
│   Role "senior_pm" → Permissions Array in JWT:                  │
│   ["dashboard.view", "projects.view", "projects.overview.edit", │
│    "projects.health.raise-issue", "customers.view", ...]        │
│          ↓                                                      │
│   Every API Request checks: "Does this token have permission X?"│
│   Every UI button checks:   "Does this user have permission X?" │
│          ↓                                                      │
│   ✅ Has permission → Show button / Allow API call              │
│   ❌ No permission  → Hide button / Return 403 Forbidden        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Understanding the Permission System

The app uses a **3-level permission hierarchy**, already defined in
`apps/backend/Shared/Constants/PermissionCatalog.cs`:

```
MODULE → SUBMODULE → ACTION

Example:
  projects   →  health       →  raise-issue
  projects   →  team         →  assign
  customers  →  (root)       →  create
  settings   →  roles        →  manage
```

The full canonical key in **dot notation** is:
```
projects.health.raise-issue
projects.team.assign
customers.create
settings.roles.manage
```

These keys are stored as a **JSONB array** directly on each `roles` row in the database:
```json
["dashboard.view", "projects.view", "projects.team.assign", "customers.view"]
```

When a user logs in, all the keys from their role are embedded into their **JWT token as claims**.

### Complete Module → Permission Key Reference

| Module | Submodule | Permission Key | What It Allows |
| :--- | :--- | :--- | :--- |
| Dashboard | — | `dashboard.view` | See the PMO dashboard KPIs |
| Action Center | — | `action-center.view` | See the approval queue |
| Projects | Root | `projects.view` | See project list |
| Projects | Root | `projects.create` | Create new projects |
| Projects | Root | `projects.edit` | Edit project details |
| Projects | Root | `projects.delete` | Archive/delete projects |
| Projects | Root | `projects.close` | Close/complete projects |
| Projects | Root | `projects.approve` | Approve project requests |
| Projects | Overview | `projects.overview.view` | View project details tab |
| Projects | Overview | `projects.overview.edit` | Edit project overview |
| Projects | Budget | `projects.budget.view` | View budget tab |
| Projects | Team | `projects.team.view` | View team members |
| Projects | Team | `projects.team.assign` | Add/remove team members |
| Projects | Task | `projects.task.view` | View project tasks |
| Projects | Task | `projects.task.create` | Create new tasks |
| Projects | Task | `projects.task.edit` | Edit task details |
| Projects | Task | `projects.task.assign` | Assign tasks to members |
| Projects | Task | `projects.task.update-status` | Change task status |
| Projects | Health | `projects.health.view` | View health dashboard |
| Projects | Health | `projects.health.raise-issue` | Log a new issue |
| Projects | Health | `projects.health.edit-issue` | Modify an existing issue |
| Projects | Health | `projects.health.resolve-issue` | Mark issue as resolved |
| Projects | Health | `projects.health.comment` | Add comments to issues |
| Projects | Alerts | `projects.alerts.view` | View risk alerts |
| Projects | Alerts | `projects.alerts.create` | Create new alert |
| Projects | Alerts | `projects.alerts.resolve` | Dismiss/resolve alert |
| Projects | Escalation | `projects.escalation.view` | View escalations |
| Projects | Escalation | `projects.escalation.create` | Raise an escalation |
| Projects | Escalation | `projects.escalation.resolve` | Resolve escalation |
| Projects | Invoice | `projects.invoice-schedule.view` | View invoice tab |
| Projects | Invoice | `projects.invoice-schedule.manage` | Create/edit invoices |
| Projects | WBS | `projects.services-deliverables.view` | View deliverables |
| Projects | WBS | `projects.services-deliverables.manage` | Edit WBS scope |
| Customers | Root | `customers.view` | See client list |
| Customers | Root | `customers.create` | Add new client |
| Customers | Root | `customers.edit` | Edit client details |
| Customers | Root | `customers.delete` | Delete client record |
| Customers | Root | `customers.approve` | Approve client onboarding |
| Customers | Root | `customers.assign` | Assign users to a client |
| Resources | Root | `resources.view` | See employee directory |
| Resources | Root | `resources.manage` | Add/edit employees |
| Resources | Directory | `resources.directory.view` | Access employee profiles |
| Resources | KPI | `resources.kpi.view` | See salary, KPI, rating data |
| Reports | Root | `reports.view` | View reports |
| Reports | Root | `reports.export` | Export reports to CSV/PDF |
| Reports | Finance | `reports.finance.view` | Access finance-only reports |
| My Team | Dashboard | `my-team.dashboard.view` | See subordinates overview |
| My Team | Timesheets | `my-team.timesheet-approval.view` | See team timesheets |
| My Team | Timesheets | `my-team.timesheet-approval.approve` | Approve team timesheets |
| My Team | Timesheets | `my-team.timesheet-approval.reject` | Reject team timesheets |
| My Team | My Timesheet | `my-team.my-timesheet.view` | View own timesheet |
| My Team | My Timesheet | `my-team.my-timesheet.submit` | Submit own timesheet |
| My Team | My Timesheet | `my-team.my-timesheet.edit` | Edit own timesheet |
| WBS | Root | `wbs.view` | View WBS allocation |
| WBS | Root | `wbs.allocate` | Allocate resources to WBS |
| Approvals | Root | `approvals.view` | See all approval requests |
| Approvals | Root | `approvals.approve` | Approve requests |
| Approvals | Root | `approvals.reject` | Reject requests |
| Repository | Root | `repository.view` | View document repository |
| Portfolio | Root | `portfolio.view` | View portfolio dashboard |
| Settings | Root | `settings.view` | Access Settings pages |
| Settings | Roles | `settings.roles.view` | View roles list |
| Settings | Roles | `settings.roles.manage` | Create/edit roles & permissions |
| Settings | Permissions | `settings.permissions.manage` | Manage user-level permissions |
| Settings | Audit | `settings.audit.view` | View permission audit log |

---

## 3. System Roles and Their Access Levels

These roles are **seeded automatically** from `apps/backend/Shared/Constants/RoleBaselines.cs`.
They cannot be deleted (they have `IsSystemRole = true`).

| Role Key | Display Name | Access Level Summary |
| :--- | :--- | :--- |
| `Dhanshree` | Super Admin | **ALL permissions** — no restrictions |
| `Admin` | Administrator | **ALL permissions** — full access |
| `Pmo` | PMO Officer | View-only governance across all modules: projects, reports, resources, WBS, approvals |
| `Hod` | Head of Department | Full view + health management, team timesheet approval, client approval |
| `BusinessOwner` | Business Owner | Executive read-only: projects, reports, resources, customers, portfolio |
| `SeniorPm` | Senior Project Manager | Full project management, team assignment, health issues, timesheet approval |
| `EngagementManager` | Engagement Manager | Same as SeniorPm + client management for assigned accounts |
| `ProjectManager` | Project Manager | Project tasks, health, team, own timesheets, approve subordinate timesheets |
| `TeamLead` | Team Lead | Task updates, timesheet submission |
| `Employee` | Employee | Only assigned tasks, own timesheets, view resources & repository |
| `Hr` | HR | Resources management + repository access only |
| `Accounts` | Accounts & Finance | Invoice management, finance reports, client and project read-only |
| `Sales` | Sales / BD | Create clients, view projects, create projects, own timesheets |

---

## 4. Part A: Implementing Settings & Masters Module (Backend)

### What already exists in the database
The following master tables **already exist and are migrated** in PostgreSQL:
- `mst_departments` — Department catalog (Engineering, Design, Delivery, etc.)
- `mst_designations` — Job designations linked to departments
- `mst_roles` — Job roles linked to designations
- `mst_industries` — Industry verticals for client categorization
- `mst_countries` and `mst_cities` — Geographical catalog
- `mst_work_locations` and `mst_offices` — Work location hierarchy
- `mst_salary_bands` — Compensation band levels
- `mst_email_domains` — Allowed corporate email domains
- `mst_certifications`, `mst_graduation_degrees`, `mst_post_graduation_degrees` — Education catalog

### What needs to be added

#### Step A-1: Add `mst_contract_types` Table (Project Masters)

This table does **not yet exist** as a formal EF entity. Currently contract types are stored locally in frontend. Create the migration:

```sql
-- New migration: AddProjectMasterCatalog
CREATE TABLE IF NOT EXISTS mst_contract_types (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "Code" VARCHAR(80) NOT NULL UNIQUE,           -- 'scope_based', 'time_and_materials', 'fixed_bid'
    "Name" VARCHAR(150) NOT NULL UNIQUE,           -- 'Scope Based', 'Time & Materials', 'Fixed Bid'
    "Description" VARCHAR(500),
    "IsActive" BOOLEAN NOT NULL DEFAULT true,
    "SortOrder" INT NOT NULL DEFAULT 0,
    "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "UpdatedAtUtc" TIMESTAMPTZ,
    "CreatedBy" UUID,
    "UpdatedBy" UUID,
    "DeletedAtUtc" TIMESTAMPTZ
);

-- Seed default values
INSERT INTO mst_contract_types ("Id", "Code", "Name", "SortOrder", "IsActive", "CreatedAtUtc") VALUES
(gen_random_uuid(), 'scope_based', 'Scope Based', 1, true, now()),
(gen_random_uuid(), 'time_and_materials', 'Time & Materials', 2, true, now()),
(gen_random_uuid(), 'fixed_bid', 'Fixed Bid', 3, true, now()),
(gen_random_uuid(), 'retainer', 'Retainer', 4, true, now()),
(gen_random_uuid(), 'ad_hoc', 'Short Term (Ad-hoc)', 5, true, now())
ON CONFLICT ("Code") DO NOTHING;
```

#### Step A-2: Add `app_settings` Table (Global Configuration)

```sql
CREATE TABLE IF NOT EXISTS app_settings (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "Category" VARCHAR(80) NOT NULL,              -- 'Timesheet', 'Financial', 'Security', 'Branding'
    "Key" VARCHAR(120) NOT NULL UNIQUE,           -- 'Timesheet.WeeklyLockDay', 'Fiscal.YearStartMonth'
    "Value" TEXT NOT NULL,
    "ValueType" VARCHAR(30) NOT NULL DEFAULT 'String', -- 'String', 'Number', 'Boolean', 'Json'
    "Description" VARCHAR(500),
    "IsEncrypted" BOOLEAN NOT NULL DEFAULT false,
    "IsSystem" BOOLEAN NOT NULL DEFAULT false,
    "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "UpdatedAtUtc" TIMESTAMPTZ,
    "CreatedBy" UUID,
    "UpdatedBy" UUID,
    "DeletedAtUtc" TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS "IX_app_settings_Category" ON app_settings ("Category");

-- Seed default system settings
INSERT INTO app_settings ("Id", "Category", "Key", "Value", "ValueType", "Description", "IsSystem", "CreatedAtUtc") VALUES
(gen_random_uuid(), 'Timesheet', 'Timesheet.WeeklyLockDay', 'Friday', 'String', 'Day after which weekly timesheets are locked for editing', true, now()),
(gen_random_uuid(), 'Timesheet', 'Timesheet.LockAfterDays', '7', 'Number', 'Number of days after period end before timesheet is locked', true, now()),
(gen_random_uuid(), 'Financial', 'Financial.DefaultCurrency', 'INR', 'String', 'Default currency for billing and invoices', true, now()),
(gen_random_uuid(), 'Financial', 'Financial.FiscalYearStartMonth', '4', 'Number', 'Month number when fiscal year begins (1=Jan, 4=Apr)', true, now()),
(gen_random_uuid(), 'Security', 'Security.PasswordMinLength', '8', 'Number', 'Minimum password length for user accounts', true, now()),
(gen_random_uuid(), 'Security', 'Security.MaxFailedLoginAttempts', '5', 'Number', 'Maximum failed login attempts before lockout', true, now()),
(gen_random_uuid(), 'Security', 'Security.LockoutDurationMinutes', '15', 'Number', 'Duration of lockout in minutes after max failures', true, now())
ON CONFLICT ("Key") DO NOTHING;
```

#### Step A-3: Register in `AppDbContext.cs`
In `apps/backend/Infrastructure/Persistence/AppDbContext.cs`, add:

```csharp
// In the DbSet registrations section (after existing sets)
public DbSet<MstContractType> ContractTypes => Set<MstContractType>();
public DbSet<AppSetting> AppSettings => Set<AppSetting>();
```

#### Step A-4: Create the Settings Controller
Create `apps/backend/Modules/Settings/Controllers/SettingsController.cs`:

```csharp
[ApiController]
[Route("api/settings")]
[Authorize]
public class SettingsController(AppDbContext db) : ControllerBase
{
    // ── Masters: Departments ─────────────────────────────────────
    [HttpGet("masters/departments")]
    [RequirePermission("settings.view")]
    public async Task<IActionResult> GetDepartments() =>
        Ok(await db.Departments.Where(d => d.DeletedAtUtc == null)
            .Select(d => new { d.Id, d.Code, d.Name, d.IsActive })
            .OrderBy(d => d.Name).ToListAsync());

    [HttpPost("masters/departments")]
    [RequirePermission("settings.roles.manage")]
    public async Task<IActionResult> AddDepartment([FromBody] AddDepartmentDto dto)
    {
        if (await db.Departments.AnyAsync(d => d.Name == dto.Name && d.DeletedAtUtc == null))
            return Conflict(new { message = $"Department '{dto.Name}' already exists." });

        var dept = new MstDepartment { Code = dto.Code, Name = dto.Name };
        db.Departments.Add(dept);
        await db.SaveChangesAsync();
        return Ok(dept);
    }

    // ── Masters: Contract Types ──────────────────────────────────
    [HttpGet("masters/contract-types")]
    [RequirePermission("settings.view")]
    public async Task<IActionResult> GetContractTypes() =>
        Ok(await db.ContractTypes.Where(c => c.DeletedAtUtc == null)
            .OrderBy(c => c.SortOrder).ToListAsync());

    [HttpPost("masters/contract-types")]
    [RequirePermission("settings.roles.manage")]
    public async Task<IActionResult> AddContractType([FromBody] AddContractTypeDto dto)
    {
        if (await db.ContractTypes.AnyAsync(c => c.Name == dto.Name && c.DeletedAtUtc == null))
            return Conflict(new { message = $"Contract type '{dto.Name}' already exists." });

        var ct = new MstContractType { Code = dto.Code, Name = dto.Name };
        db.ContractTypes.Add(ct);
        await db.SaveChangesAsync();
        return Ok(ct);
    }

    // ── App Settings ──────────────────────────────────────────────
    [HttpGet("app-config/{category}")]
    [RequirePermission("settings.view")]
    public async Task<IActionResult> GetSettingsByCategory(string category) =>
        Ok(await db.AppSettings.Where(s => s.Category == category && s.DeletedAtUtc == null)
            .Select(s => new { s.Key, s.Value, s.ValueType, s.Description, s.IsSystem })
            .ToListAsync());

    [HttpPut("app-config/{key}")]
    [RequirePermission("settings.roles.manage")]
    public async Task<IActionResult> UpdateSetting(string key, [FromBody] UpdateSettingDto dto)
    {
        var setting = await db.AppSettings.FirstOrDefaultAsync(s => s.Key == key);
        if (setting is null) return NotFound();
        setting.Value = dto.Value;
        await db.SaveChangesAsync();
        return Ok(setting);
    }
}
```

---

## 5. Part B: Implementing Settings & Masters (Frontend)

### What currently happens
The frontend `apps/frontend/src/lib/masters/use-masters.ts` loads data from **localStorage** as a fallback. This means:
- Data is stored in the browser only — it is not shared between users.
- If someone clears their browser, all masters are lost.
- There is no audit trail.

### What to change: Replace localStorage with API calls

Update `apps/frontend/src/lib/masters/use-masters.ts`:

```typescript
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { apiClient } from "@/lib/api-client";  // your axios instance
import { toast } from "sonner";
import type { ProjectMasterItem, CustomerMasterCategory } from "./types";

export function useMastersStore() {
  const queryClient = useQueryClient();

  // ── 1. Fetch Departments ───────────────────────────────────────
  const { data: departments = [] } = useQuery({
    queryKey: ["masters", "departments"],
    queryFn: () => apiClient.get("/api/settings/masters/departments").then(r => r.data),
  });

  // ── 2. Fetch Contract Types ────────────────────────────────────
  const { data: contractTypes = [] } = useQuery({
    queryKey: ["masters", "contract-types"],
    queryFn: () => apiClient.get("/api/settings/masters/contract-types").then(r => r.data),
  });

  // ── 3. Add Department ─────────────────────────────────────────
  const addDepartment = useMutation({
    mutationFn: (name: string) =>
      apiClient.post("/api/settings/masters/departments", {
        code: name.toLowerCase().replace(/\s+/g, "_"),
        name,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["masters", "departments"] });
      toast.success("Department added");
    },
    onError: (err: any) => toast.error(err.response?.data?.message || "Failed"),
  });

  // ── 4. Add Contract Type ──────────────────────────────────────
  const addContractType = useMutation({
    mutationFn: (name: string) =>
      apiClient.post("/api/settings/masters/contract-types", {
        code: name.toLowerCase().replace(/\s+/g, "_"),
        name,
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["masters", "contract-types"] });
      toast.success("Contract type added");
    },
  });

  return {
    departments,
    contractTypes,
    addDepartment: (name: string) => addDepartment.mutateAsync(name),
    addContractType: (name: string) => addContractType.mutateAsync(name),
  };
}
```

---

## 6. Part C: Implementing RBAC — Module Access Control (Backend)

### How it works step by step

```
User Logs In (POST /api/auth/login)
        ↓
AuthService loads user → loads user.Role → loads role.Permissions (JSONB array)
        ↓
Builds JWT with Permission Claims:
  { "sub": "user-uuid", "email": "...", "role": "senior_pm",
    "permission": "dashboard.view",
    "permission": "projects.view",
    "permission": "projects.health.raise-issue",
    ... }
        ↓
Client sends JWT in every request header: Authorization: Bearer <token>
        ↓
[RequirePermission("projects.team.assign")] attribute runs
        ↓
Checks: Does this token have a claim { type="permission", value="projects.team.assign" }?
  ✅ Yes → Request proceeds
  ❌ No  → Returns 403 Forbidden
```

### Step C-1: `RequirePermissionAttribute` (Already partially exists)

In `apps/backend/Infrastructure/Authorization/RequirePermissionAttribute.cs`:

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

[AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, AllowMultiple = true)]
public class RequirePermissionAttribute(string permission)
    : AuthorizeAttribute, IAsyncAuthorizationFilter
{
    public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;

        // Not authenticated at all
        if (!user.Identity?.IsAuthenticated ?? true)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        // Dhanshree and Admin bypass ALL permission checks
        if (user.IsInRole("Dhanshree") || user.IsInRole("Admin"))
            return;

        // Check for the exact permission claim in the JWT
        var hasPermission = user.Claims
            .Any(c => c.Type == "permission" && c.Value == permission);

        if (!hasPermission)
            context.Result = new ForbidResult(); // Returns 403
    }
}
```

### Step C-2: Embed Permissions in JWT at Login

In `apps/backend/Infrastructure/Authentication/AuthService.cs`, when building the JWT token:

```csharp
// Load role with its permissions
var user = await db.Users
    .Include(u => u.Role)
    .FirstOrDefaultAsync(u => u.Email == loginEmail && u.IsActive);

var claims = new List<Claim>
{
    new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
    new(JwtRegisteredClaimNames.Email, user.Email),
    new("employee_id", user.EmployeeId),
    new(ClaimTypes.Role, user.Role?.Name ?? "Employee"),
};

// Add EVERY permission the role grants as a separate JWT claim
// This is why role.Permissions is a JSONB array — each key becomes a claim
if (user.Role?.Permissions != null)
{
    foreach (var permission in user.Role.Permissions)
    {
        claims.Add(new Claim("permission", permission));
    }
}

// Dhanshree flag for super-admin bypass
if (user.Role?.Name == "Dhanshree")
    claims.Add(new Claim("is_super_admin", "true"));
```

### Step C-3: Roles API (For the `/dh-settings-security-roles` Page)

In `apps/backend/Modules/Users/Controllers/UsersController.cs`, expose endpoints:

```csharp
// GET all roles with their permissions (for the Security Roles settings page)
[HttpGet("roles")]
[RequirePermission("settings.roles.view")]
public async Task<IActionResult> GetRoles() =>
    Ok(await db.Roles
        .Where(r => r.DeletedAtUtc == null)
        .Select(r => new {
            r.Id, r.Name, r.DisplayName, r.Description,
            r.IsSystemRole, r.IsActive, r.Permissions
        })
        .ToListAsync());

// PUT update role permissions (triggered when admin saves role matrix)
[HttpPut("roles/{id:guid}/permissions")]
[RequirePermission("settings.roles.manage")]
public async Task<IActionResult> UpdateRolePermissions(
    Guid id, [FromBody] UpdateRolePermissionsDto dto)
{
    var role = await db.Roles.FindAsync(id);
    if (role is null) return NotFound();
    if (role.IsSystemRole && !currentUser.IsSuperAdmin)
        return Forbid(); // Only super-admins can edit system roles

    // Record the change in audit log
    var audit = new RolePermissionAudit
    {
        RoleId = id,
        Action = "PermissionsUpdated",
        PermissionsBefore = role.Permissions,
        PermissionsAfter = dto.Permissions,
        ModifiedBy = currentUser.UserId,
        ModifiedAtUtc = DateTime.UtcNow,
        Reason = dto.Reason,
    };
    db.RolePermissionAudits.Add(audit);

    role.Permissions = dto.Permissions;
    await db.SaveChangesAsync();
    return Ok(new { message = "Permissions updated" });
}
```

### Step C-4: Data Scoping — Row-Level Security

This controls which specific rows of data a user can see (e.g., only their assigned clients):

```csharp
public async Task<List<ClientDto>> GetScopedClientsAsync(Guid userId)
{
    var user = await db.Users.Include(u => u.Role).FirstAsync(u => u.Id == userId);

    // PMO, Management, Dhanshree, Admin — see ALL clients
    bool isGlobalViewer = user.Role?.Name is "Dhanshree" or "Admin" or "Pmo"
                          or "BusinessOwner" or "Hod";

    if (isGlobalViewer)
        return await db.Clients.Where(c => c.DeletedAtUtc == null)
                       .Select(c => c.ToDto()).ToListAsync();

    // Engagement Managers see clients where they are the assigned EM
    // Sales Managers see clients where they are the assigned SM
    // Others see only explicitly assigned clients via client_assignments
    return await db.Clients
        .Where(c => c.DeletedAtUtc == null && (
            c.EngagementManagerId == userId ||
            c.SalesManagerId == userId ||
            c.Assignments.Any(a => a.UserId == userId)))
        .Select(c => c.ToDto()).ToListAsync();
}
```

---

## 7. Part D: Implementing RBAC — User Access (Frontend)

### How the frontend knows what to show

When a user logs in, the **JWT token is decoded** in the frontend and permissions are stored in a context. The existing `usePermissions()` hook reads these.

### Step D-1: Permission Gate Component (Conditional Rendering)

Create `apps/frontend/src/components/permission-gate.tsx`:

```tsx
import { usePermissions } from "@/lib/permissions";

interface Props {
  permission: string;
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export function PermissionGate({ permission, children, fallback = null }: Props) {
  const { hasPermission } = usePermissions();
  return hasPermission(permission) ? <>{children}</> : <>{fallback}</>;
}
```

Usage in any component:
```tsx
// Add button only shows if user has permission to create
<PermissionGate permission="settings.roles.manage">
  <Button onClick={handleAddRole}>+ Add Role</Button>
</PermissionGate>

// Edit is always visible but disabled if no permission
<Button disabled={!hasPermission("customers.edit")} onClick={handleEdit}>
  Edit
</Button>
```

### Step D-2: Route Protection in TanStack Router

Protect the settings routes so unauthorized users are redirected:

```tsx
// In dh-settings-masters.tsx — already uses: can("settings.view")
// In dh-settings-security-roles.tsx — add:

export const Route = createFileRoute("/dh-settings-security-roles")({
  beforeLoad: ({ context }) => {
    const { hasPermission, isDhanshree } = context.auth;
    if (!isDhanshree && !hasPermission("settings.roles.view")) {
      throw redirect({ to: "/access-denied" });
    }
  },
  component: SecurityRolesPage,
});
```

### Step D-3: Permission-Aware API Requests

The `apiClient` should automatically attach the JWT. Example setup:

```typescript
// apps/frontend/src/lib/api-client.ts
import axios from "axios";

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? "http://localhost:5000",
});

// Attach JWT automatically before every request
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem("access_token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Handle 401 and 403 globally
apiClient.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      // Token expired → redirect to login
      window.location.href = "/login";
    }
    if (err.response?.status === 403) {
      // Access denied → show toast
      toast.error("You don't have permission to do this.");
    }
    return Promise.reject(err);
  }
);
```

---

## 8. How Everything Connects in the Database

```
┌──────────────────────────────────────────────────────────────┐
│ SETTINGS DOMAIN (Masters & Configuration)                    │
│                                                              │
│  mst_contract_types ─────────────────────────────────────┐  │
│  mst_departments ────────────── mst_designations         │  │
│       │                               │                  │  │
│       ↓                               ↓                  │  │
│  employees.DepartmentId          employees.DesignationId │  │
│  employees.JobRoleId (via mst_roles)                     │  │
│                                                          │  │
│  mst_industries ──────────────── clients.IndustryId      │  │
│  mst_countries ───────────────── clients.CountryId       │  │
│  mst_cities ──────────────────── clients.CityId          │  │
│  mst_work_locations ──────────── mst_offices             │  │
│  mst_salary_bands ────────────── employees.SalaryBandId  │  │
│                                                          │  │
│  app_settings (Key-Value Store for Global Config)        │  │
└──────────────────────────────────────────────────────────┘  │
                                                              │
┌──────────────────────────────────────────────────────────────┐
│ RBAC DOMAIN (Security & Access Control)                      │
│                                                              │
│  roles (IsSystemRole, Permissions JSONB[])                   │
│       │                                                      │
│       ├──────────────────────────────── users.RoleId         │
│       │                                    │                 │
│       └── role_permission_audits.RoleId    ↓                 │
│                                       refresh_tokens         │
│                                       client_assignments     │
│                                       (Data Scoping)         │
└──────────────────────────────────────────────────────────────┘
```

---

## 9. Step-by-Step Checklist

### Backend Tasks
- [ ] Create `MstContractType` EF Core model in `Modules/Settings/Models/`
- [ ] Create `AppSetting` EF Core model in `Modules/Settings/Models/`
- [ ] Register both `DbSet<>` in `AppDbContext.cs`
- [ ] Run EF migration: `dotnet ef migrations add AddContractTypesAndAppSettings`
- [ ] Apply migration: `dotnet ef database update`
- [ ] Seed default contract types and system app settings in `DbSeeder.cs`
- [ ] Create `SettingsController.cs` with CRUD endpoints for departments, contract types, app settings
- [ ] Verify `RequirePermissionAttribute` reads the `"permission"` claim from JWT
- [ ] Verify `AuthService` embeds all `role.Permissions` as JWT claims during login
- [ ] Add `UpdateRolePermissions` endpoint with `RolePermissionAudit` insertion
- [ ] Implement data-scoping in `ClientService`, `ProjectService`, and `ResourceService`

### Frontend Tasks
- [ ] Create `src/lib/api-client.ts` with JWT interceptor and 401/403 global handling
- [ ] Update `use-masters.ts` to use React Query against the backend API
- [ ] Create `PermissionGate` component in `src/components/permission-gate.tsx`
- [ ] Add `beforeLoad` guards to `/dh-settings-masters` and `/dh-settings-security-roles` routes
- [ ] Connect `/dh-settings-security-roles` page to `GET /api/users/roles` and `PUT /api/users/roles/{id}/permissions`
- [ ] Verify that action buttons (Add/Edit/Delete) are hidden or disabled based on permissions

### Testing Checklist
- [ ] Login as `Employee` role → Settings pages redirect to `/access-denied`
- [ ] Login as `Pmo` role → Settings read-only view, no Add/Edit buttons visible
- [ ] Login as `Dhanshree` → Full access to all settings and role management
- [ ] Attempt `PUT /api/users/roles/{id}/permissions` without `settings.roles.manage` permission → `403 Forbidden`
- [ ] Verify `role_permission_audits` row is inserted after every permission change
- [ ] Verify `Accounts` role can only see Finance reports (no customer edit, no HR, no settings)
