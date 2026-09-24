# TrackerPro RBAC Master Catalog & Technical Integration Guide
## Complete Blueprint: Department & Designation to 3rd-Column RBAC Mapping (Approach 1)

---

## Table of Contents
1. [Executive Summary & Core Philosophy](#1-executive-summary--core-philosophy)
2. [Master RBAC Roles Catalog (27 Unique Roles)](#2-master-rbac-roles-catalog-27-unique-roles)
3. [Exhaustive Department → Designation → Role Mapping (60+ Designations)](#3-exhaustive-department--designation--role-mapping-60-designations)
4. [Granular Permission Catalog (Dot-Notation Tree)](#4-granular-permission-catalog-dot-notation-tree)
5. [Database Architecture & Schema (PostgreSQL DDL)](#5-database-architecture--schema-postgresql-ddl)
6. [Backend Implementation (.NET 10 Web API)](#6-backend-implementation-net-10-web-api)
7. [Frontend Implementation (React + TypeScript)](#7-frontend-implementation-react--typescript)
8. [Settings & Dynamic Administration](#8-settings--dynamic-administration)
9. [Step-by-Step Execution Checklist](#9-step-by-step-execution-checklist)

---

## 1. Executive Summary & Core Philosophy

In **TrackerPro (Pulse PMO)**, access control is implemented using **Approach 1 (Automated Designation-to-RBAC-Role Mapping)** combined with fine-grained **Permission-Based Access Control (PBAC)** and **Data Scoping**:

```
┌──────────────────────────┐      ┌──────────────────────────┐      ┌──────────────────────────┐
│      1. DEPARTMENT       │  +   │      2. DESIGNATION      │  ──> │    3. RBAC ROLE (Col 3)  │
│  (e.g., Services-Testing)│      │  (e.g., PenTester - I)   │      │(e.g., Testing-TeamMember)│
└──────────────────────────┘      └──────────────────────────┘      └────────────┬─────────────┘
                                                                                 │
                                                                                 ▼
┌──────────────────────────┐      ┌──────────────────────────┐      ┌──────────────────────────┐
│  6. API / UI ENFORCEMENT │ <──  │   5. JWT PERMISSIONS     │ <──  │   4. PERMISSIONS ARRAY   │
│  [RequirePermission]     │      │   Embedded in Auth Token │      │   Stored as JSONB in DB  │
└──────────────────────────┘      └──────────────────────────┘      └──────────────────────────┘
```

### Core Architecture Pillars:
1. **Clean Separation of HR Titles vs Security Roles**:
   - **Department** (`mst_departments`) defines the organizational branch (e.g. *Services - Testing*).
   - **Designation** (`mst_designations`) is the employee's HR job title (e.g. *PenTester - I*, *Associate Manager - I*).
   - **RBAC Role** (`roles`) defines the exact set of software permissions (e.g. *Testing-Team Member*, *Testing-Team Leader*).
2. **Automated Onboarding Assignment**:
   - Every designation stores a `DefaultRoleId` foreign key pointing directly to its corresponding Column 3 RBAC role.
   - Selecting a designation in the onboarding form **automatically pre-populates the RBAC role**.
3. **Dynamic Customization**:
   - Permissions for any role can be modified in real-time by administrators via **Settings > Roles & Permissions** without code deployments.

---

## 2. Master RBAC Roles Catalog (27 Unique Roles)

The entire organization operates across **27 discrete RBAC Access Roles** derived from Column 3 of the access matrix:

| # | Role Key (`roles.Name`) | Display Name | Category | Scope & Key Capabilities |
| :- | :--- | :--- | :--- | :--- |
| 1 | `CEO` | Chief Executive Officer | Core Executive | Global executive visibility, business analytics, all approvals. |
| 2 | `COO` | Chief Operating Officer | Core Executive | Operational oversight across all departments and projects. |
| 3 | `CTO` | Chief Technology Officer | Core Executive | Technical architecture, R&D governance, engineering oversight. |
| 4 | `IT Admin` | IT Administrator | Functional Support | IT infrastructure, corporate email domains, device & user setup. |
| 5 | `Accounts` | Accounts & Finance | Functional Support | Invoicing schedule, milestone payments, PO tracking, financial reports. |
| 6 | `HR` | Human Resources | Functional Support | Employee directory, onboarding/offboarding, skills, KPI/rating tabs. |
| 7 | `Sales Manager` | Sales Manager | Functional Support | Customer onboarding, client management, proposal drafting, pipeline. |
| 8 | `Sales team member` | Sales Team Member | Functional Support | Proposal drafting, pipeline viewing, sales reports. |
| 9 | `PMO` | Project Management Office | Functional Support | Global governance, WBS allocation, timesheet monitoring, approvals. |
| 10 | `EngagementManager` | Engagement Manager (EM) | Project Delivery | Customer relationship, client project overview, health & escalations. |
| 11 | `Intern` | Intern | Internship Program | Read-only training access to assigned tasks and document repository. |
| 12 | `Testing HOD` | Testing Head of Department | Services - Testing | Complete oversight of Testing department, health escalations, approvals. |
| 13 | `Testing Senior Manager` | Testing Senior Manager | Services - Testing | Delivery oversight across testing projects, QA resource management. |
| 14 | `Testing-Manager` | Testing Project Manager | Services - Testing | QA project tasks, test deliverables, defect tracking, QA timesheets. |
| 15 | `Testing-Team Leader` | Testing Team Leader | Services - Testing | Test run execution, defect triage, test task assignment, timesheet review. |
| 16 | `Testing-Team Member` | Testing Team Member | Services - Testing | Test execution, defect logging, task status updates, own timesheets. |
| 17 | `Consulting-HOD` | Consulting Head of Dept | Services - Consulting | Complete oversight of Consulting department, GRC engagements. |
| 18 | `Consulting-Senior Manager`| Consulting Senior Manager | Services - Consulting | Delivery oversight across consulting & audit projects. |
| 19 | `Consulting-Manager` | Consulting Project Manager| Services - Consulting | GRC audit projects, client deliverables, audit timesheet approvals. |
| 20 | `Consulting-Team Leader` | Consulting Team Leader | Services - Consulting | Senior audit execution, audit task assignment, timesheet review. |
| 21 | `Consulting-Team member` | Consulting Team Member | Services - Consulting | Audit checklists, evidence collection, task updates, own timesheets. |
| 22 | `SOC-HOD` | SOC Head of Department | Services - Operations | Complete oversight of SOC/Operations, 24/7 monitoring governance. |
| 23 | `SOC-Senior Manager` | SOC Senior Manager | Services - Operations | Operations delivery oversight, client SLA tracking, incident reviews. |
| 24 | `SOC-Manager` | SOC Manager | Services - Operations | Incident management, shift scheduling, operations timesheets. |
| 25 | `SOC-Team Leader` | SOC Shift / Team Leader | Services - Operations | Shift oversight, alert escalation, task assignments, timesheet review. |
| 26 | `SOC-Team Member` | SOC Team Member | Services - Operations | SIEM monitoring, alert analysis, shift logs, own timesheets. |
| 27 | `R&D - Team member` | R&D Team Member | R&D (Engineering) | Python/Tool development, sprint tasks, code repository, own timesheets. |

---

## 3. Exhaustive Department → Designation → Role Mapping (60+ Designations)

The following master lookup table maps every company designation to its default RBAC role:

| Department (Col 1) | Designation / Job Title (Col 2) | Default RBAC Role (Col 3) |
| :--- | :--- | :--- |
| **Core** | Director and Chief Executive | `CEO` |
| **Core** | Director and Chief Operating | `COO` |
| **Core** | Director and Chief Technology | `CTO` |
| **Functional - IT Administration** | IT Admin | `IT Admin` |
| **Functional - IT Administration** | Desktop Support Engineer - I | `IT Admin` |
| **Functional - IT Administration** | Desktop Support Engineer - II | `IT Admin` |
| **Functional - Accounts** | Accountant - I | `Accounts` |
| **Functional - Accounts** | Accountant - II | `Accounts` |
| **Functional - Accounts** | Accountant - III | `Accounts` |
| **Functional - Accounts** | Senior Accountant - I | `Accounts` |
| **Functional - Accounts** | Senior Accountant - II | `Accounts` |
| **Functional - Accounts** | Senior Accountant - III | `Accounts` |
| **Functional - HR** | HR Head | `HR` |
| **Functional - HR** | Recruitment Coordinator - I | `HR` |
| **Functional - HR** | Recruitment Coordinator - II | `HR` |
| **Functional - HR** | Senior HR Executive - I | `HR` |
| **Functional - HR** | Senior HR Executive - II | `HR` |
| **Functional - Sales** | Business Development Associate | `Sales Manager` |
| **Functional - Sales** | Customer Success Representative | `Sales Manager` |
| **Functional - Sales** | Director - Product Sales | `Sales team member` |
| **Functional - Sales** | Sales Associate | `Sales team member` |
| **Functional - Sales** | Associate Customer Success I | `Sales team member` |
| **Functional - Sales** | Associate Customer Success II | `Sales team member` |
| **Functional - Project Management** | Associate PMO - I | `PMO` |
| **Functional - Project Management** | Associate PMO - II | `PMO` |
| **Functional - Project Management** | Senior PMO - I | `PMO` |
| **Functional - Project Management** | Senior PMO - II | `PMO` |
| **Functional - Project Management** | Delivery Account Manager - I | `EngagementManager` |
| **Functional - Project Management** | Delivery Account Manager - II | `EngagementManager` |
| **Functional - Project Management** | Senior Delivery Account Manager I | `EngagementManager` |
| **Functional - Project Management** | Senior Delivery Account Manager II | `EngagementManager` |
| **R&D (Research & Development)** | Python Developer - I | `R&D - Team member` |
| **R&D (Research & Development)** | Python Developer - II | `R&D - Team member` |
| **R&D (Research & Development)** | Python Developer - III | `R&D - Team member` |
| **Services - Operations** | SOC Analyst - I | `SOC-Team Member` |
| **Services - Operations** | SOC Analyst - II | `SOC-Team Member` |
| **Services - Operations** | SOC Analyst - III | `SOC-Team Member` |
| **Services - Operations** | SOC Analyst - IV | `SOC-Team Member` |
| **Services - Operations** | SIEM Admin - I | `SOC-Team Member` |
| **Services - Operations** | SIEM Admin - II | `SOC-Team Member` |
| **Services - Operations** | SIEM Admin - III | `SOC-Team Member` |
| **Services - Operations** | SIEM Admin - IV | `SOC-Team Leader` |
| **Services - Operations** | SOC Consultant - I | `SOC-Team Member` |
| **Services - Operations** | SOC Consultant - II | `SOC-Team Member` |
| **Services - Operations** | SOC Shift Lead - I | `SOC-Team Leader` |
| **Services - Operations** | SOC Shift Lead - II | `SOC-Team Leader` |
| **Services - Operations** | SOC Lead - I | `SOC-Manager` |
| **Services - Operations** | SOC Lead - II | `SOC-Senior Manager` |
| **Services - Operations** | Principal Manager - I | `SOC-HOD` |
| **Services - Consulting** | GRC Auditor - I | `Consulting-Team member` |
| **Services - Consulting** | GRC Auditor - II | `Consulting-Team member` |
| **Services - Consulting** | GRC Auditor - III | `Consulting-Team member` |
| **Services - Consulting** | GRC Auditor - IV | `Consulting-Team member` |
| **Services - Consulting** | Senior GRC Auditor - I | `Consulting-Team Leader` |
| **Services - Consulting** | Senior GRC Auditor - II | `Consulting-Team Leader` |
| **Services - Consulting** | Associate Manager - III | `Consulting-Manager` |
| **Services - Consulting** | Manager - I | `Consulting-Senior Manager` |
| **Services - Consulting** | Senior Vice President - Principal | `Consulting-HOD` |
| **Services - Testing** | PenTester - I | `Testing-Team Member` |
| **Services - Testing** | PenTester - II | `Testing-Team Member` |
| **Services - Testing** | PenTester - III | `Testing-Team Member` |
| **Services - Testing** | PenTester - IV | `Testing-Team Member` |
| **Services - Testing** | Senior Pentester - I | `Testing-Team Member` |
| **Services - Testing** | Senior Pentester - II | `Testing-Team Member` |
| **Services - Testing** | Associate Manager - I | `Testing-Team Leader` |
| **Services - Testing** | Associate Manager - II | `Testing-Team Leader` |
| **Services - Testing** | Associate Manager - III | `Testing-Team Leader` |
| **Services - Testing** | Associate Project Manager | `Testing-Manager` |
| **Services - Testing** | Manager - I *(Yellow Highlight)* | `Testing Senior Manager` |
| **Services - Testing** | DevSecOps Practitioner - I | `Testing-Team Member` |
| **Services - Testing** | DevSecOps Practitioner - II | `Testing-Team Member` |
| **Services - Testing** | DevSecOps Practitioner - III | `Testing-Team Member` |
| **Services - Testing** | DevSecOps Associate | `Testing-Team Leader` |
| **Services - Testing** | DevSecOps Specialist - II | `Testing-Manager` |
| **Services - Testing** | Red Team Practitioner - II | `Testing-Team Member` |
| **Services - Testing** | Red Team Practitioner - III | `Testing-Team Member` |
| **Services - Testing** | Red Team Specialist - II | `Testing-Manager` |
| **Services - Testing** | Senior Cloud Security Consultant | `Testing-Manager` |
| **Services - Testing** | Associate AI Engineer - Contractor | `Testing-Team Member` |
| **Services - Testing** | Senior Vice President *(Yellow Highlight)* | `Testing HOD` |
| **Internship Program** | Intern | `Intern` |

---

## 4. Granular Permission Catalog (Dot-Notation Tree)

Permissions are organized into a 3-level tree (`module.submodule.action`):

```
MODULE  ──>  SUBMODULE  ──>  ACTION
Example: projects.health.raise-issue
```

### Complete Permission Reference:

#### 1. Dashboard
- `dashboard.view` — View PMO / Executive KPIs

#### 2. Action Center
- `action-center.view` — View approval queues, notifications, timers(start,resume,pause and stop)
- `action-center.acknowledge` — Approve or acknowledge tasks/alerts

#### 3. Projects
- **Root**: `projects.view`, `projects.create`, `projects.edit`, `projects.delete`, `projects.close`, `projects.approve`
- **Overview**: `projects.overview.view`, `projects.overview.edit`, `projects.overview.edit-pm`, `projects.overview.edit-tl`, `projects.overview.edit-spm`
- **Budget**: `projects.budget.view`
- **Team**: `projects.team.view`, `projects.team.assign`
- **Tasks**: `projects.task.view`, `projects.task.create`, `projects.task.edit`, `projects.task.assign`, `projects.task.update-status`
- **Health & Governance**: `projects.health.view`, `projects.health.raise-issue`, `projects.health.edit-issue`, `projects.health.resolve-issue`, `projects.health.comment`, `projects.health.manage`
- **Alerts & Escalations**: `projects.alerts.view`, `projects.alerts.create`, `projects.alerts.resolve`, `projects.escalation.view`, `projects.escalation.create`, `projects.escalation.resolve`
- **Invoice Schedule**: `projects.invoice-schedule.view`, `projects.invoice-schedule.manage`
- **WBS & Deliverables**: `projects.services-deliverables.view`, `projects.services-deliverables.manage`, `projects.wbs.pmo-intake`, `projects.wbs.project-allocation`

#### 4. Customers
- `customers.view` — View client directory and customer profiles
- `customers.create` — Onboard new client
- `customers.edit` — Update client metadata and contacts
- `customers.delete` — Archive/delete client
- `customers.approve` — Approve client onboarding workflow
- `customers.assign` — Assign Engagement Manager 

#### 5. Resources
- `resources.view` — View employee directory and bench status
- `resources.manage` — Add, onboard, and offboard employees
- `resources.directory.view` — View general profile information
- `resources.kpi.view` — Restricted tab: salary bands, ratings, performance KPIs
- `resources.profile.org` — View organization details tab
- `resources.profile.employment` — View employment status tab
- `resources.profile.skills` — View skills and certifications tab
- `resources.profile.finance` — View financial and compliance tab

#### 6. Reports
- `reports.view` — Access reports module
- `reports.export` — Export data to CSV/PDF
- `reports.finance.view` — View financial & margin analytics
- `reports.sales` — View sales conversion reports
- `reports.wbs-tracker` — View WBS progress tracker
- `reports.po-tracker` — View Purchase Order tracking
- `reports.invoice-tracker` — View billing & invoice payment tracker

#### 7. My Team & Timesheets
- `my-team.dashboard.view` — View team roster and allocation
- `my-team.timesheet-approval.view` — View subordinate timesheet submissions
- `my-team.timesheet-approval.approve` — Approve team timesheets
- `my-team.timesheet-approval.reject` — Reject team timesheets
- `my-team.my-timesheet.view` — Access own timesheet grid
- `my-team.my-timesheet.submit` — Submit weekly timesheet hours
- `my-team.my-timesheet.edit` — Modify draft timesheet logs

#### 8. Repository
- `repository.view` — Browse document folders and files
- `repository.upload` — Upload project documents
- `repository.download` — Download documents
- `repository.delete` — Delete documents
- `repository.logs` — View document access audit logs

#### 9. Settings
- `settings.view` — Access system settings
- `settings.roles.view` — View list of RBAC roles
- `settings.roles.manage` — Edit permission matrix for roles
- `settings.permissions.manage` — Manage user-level access
- `settings.masters.manage` — Manage company masters (Departments, Designations, Contract Types)
- `settings.audit.view` — View RBAC modification audit trail

---

## 5. Database Architecture & Schema (PostgreSQL DDL)

```sql
-- ============================================================================
-- 1. ROLES TABLE (Contains all 27 roles and JSONB permissions array)
-- ============================================================================
CREATE TABLE IF NOT EXISTS roles (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "Name" VARCHAR(100) NOT NULL UNIQUE,          -- Machine key e.g. 'Testing-Team Leader'
    "DisplayName" VARCHAR(150) NOT NULL,        -- User-friendly display name
    "Description" VARCHAR(500),
    "IsSystemRole" BOOLEAN NOT NULL DEFAULT true, -- System roles cannot be deleted
    "IsActive" BOOLEAN NOT NULL DEFAULT true,
    "Permissions" JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of canonical keys
    "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "UpdatedAtUtc" TIMESTAMPTZ,
    "CreatedBy" UUID,
    "UpdatedBy" UUID,
    "DeletedAtUtc" TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS "IX_roles_Name" ON roles ("Name");
CREATE INDEX IF NOT EXISTS "IX_roles_Permissions" ON roles USING gin ("Permissions");

-- ============================================================================
-- 2. DEPARTMENTS MASTER
-- ============================================================================
CREATE TABLE IF NOT EXISTS mst_departments (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "Code" VARCHAR(50) NOT NULL UNIQUE,
    "Name" VARCHAR(150) NOT NULL UNIQUE,
    "Description" VARCHAR(500),
    "IsActive" BOOLEAN NOT NULL DEFAULT true,
    "SortOrder" INT NOT NULL DEFAULT 0,
    "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "UpdatedAtUtc" TIMESTAMPTZ,
    "DeletedAtUtc" TIMESTAMPTZ
);

-- ============================================================================
-- 3. DESIGNATIONS MASTER (With Approach 1 DefaultRoleId Link)
-- ============================================================================
CREATE TABLE IF NOT EXISTS mst_designations (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "DepartmentId" UUID REFERENCES mst_departments("Id") ON DELETE SET NULL,
    "Name" VARCHAR(150) NOT NULL,
    "Description" VARCHAR(500),
    "DefaultRoleId" UUID REFERENCES roles("Id") ON DELETE SET NULL, -- Maps to Column 3!
    "IsActive" BOOLEAN NOT NULL DEFAULT true,
    "SortOrder" INT NOT NULL DEFAULT 0,
    "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "UpdatedAtUtc" TIMESTAMPTZ,
    "DeletedAtUtc" TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS "IX_mst_designations_DepartmentId" ON mst_designations ("DepartmentId");
CREATE INDEX IF NOT EXISTS "IX_mst_designations_DefaultRoleId" ON mst_designations ("DefaultRoleId");

-- ============================================================================
-- 4. USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "EmployeeCode" VARCHAR(30) UNIQUE,
    "Email" VARCHAR(255) NOT NULL UNIQUE,
    "PasswordHash" VARCHAR(255) NOT NULL,
    "FirstName" VARCHAR(100) NOT NULL,
    "LastName" VARCHAR(100) NOT NULL,
    "DepartmentId" UUID REFERENCES mst_departments("Id") ON DELETE RESTRICT,
    "DesignationId" UUID REFERENCES mst_designations("Id") ON DELETE RESTRICT,
    "RoleId" UUID NOT NULL REFERENCES roles("Id") ON DELETE RESTRICT,
    "IsActive" BOOLEAN NOT NULL DEFAULT true,
    "LastLoginAtUtc" TIMESTAMPTZ,
    "CreatedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "UpdatedAtUtc" TIMESTAMPTZ,
    "DeletedAtUtc" TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS "IX_users_Email" ON users ("Email");
CREATE INDEX IF NOT EXISTS "IX_users_RoleId" ON users ("RoleId");
CREATE INDEX IF NOT EXISTS "IX_users_DepartmentId" ON users ("DepartmentId");

-- ============================================================================
-- 5. ROLE PERMISSION AUDIT LOG TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS role_permission_audits (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "RoleId" UUID NOT NULL REFERENCES roles("Id") ON DELETE CASCADE,
    "Action" VARCHAR(50) NOT NULL,              -- 'UPDATED', 'RESET', 'CREATED'
    "PermissionsBefore" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "PermissionsAfter" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "ModifiedBy" UUID REFERENCES users("Id") ON DELETE SET NULL,
    "ModifiedAtUtc" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "Reason" VARCHAR(500)
);

CREATE INDEX IF NOT EXISTS "IX_role_permission_audits_RoleId" ON role_permission_audits ("RoleId");
```

---

## 6. Backend Implementation (.NET 10 Web API)

### 6.1. Role Baseline Matrix (`RoleBaselines.cs`)
```csharp
namespace PMS.API.Shared.Constants;

public static class RoleBaselines
{
    private static readonly Dictionary<string, string[]> Map = new(StringComparer.OrdinalIgnoreCase)
    {
        // ---- Super Admins & Core ----
        ["Admin"] = AllKeys(),
        ["CEO"] = AllKeys(),
        ["COO"] = [ "dashboard.view", "projects.view", "reports.view", "resources.view", "customers.view", "approvals.view", "wbs.view" ],
        ["CTO"] = [ "dashboard.view", "projects.view", "reports.view", "resources.view", "repository.view" ],

        // ---- Services: Testing ----
        ["Testing HOD"] = [
            "dashboard.view", "action-center.view", "projects.view", "projects.health.view", 
            "projects.health.manage", "reports.view", "resources.view", "my-team.timesheet-approval.approve"
        ],
        ["Testing Senior Manager"] = [
            "dashboard.view", "action-center.view", "projects.view", "projects.overview.view",
            "projects.health.view", "projects.health.raise-issue", "my-team.timesheet-approval.approve"
        ],
        ["Testing-Manager"] = [
            "dashboard.view", "projects.view", "projects.task.view", "projects.task.create", "projects.task.edit",
            "projects.task.assign", "projects.task.update-status", "projects.health.view", "projects.health.raise-issue",
            "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.timesheet-approval.approve"
        ],
        ["Testing-Team Leader"] = [
            "dashboard.view", "projects.view", "projects.task.view", "projects.task.edit",
            "projects.task.assign", "projects.task.update-status", "projects.health.raise-issue",
            "my-team.my-timesheet.view", "my-team.my-timesheet.submit", "my-team.timesheet-approval.view"
        ],
        ["Testing-Team Member"] = [
            "dashboard.view", "projects.view", "projects.task.view", "projects.task.update-status",
            "projects.health.raise-issue", "my-team.my-timesheet.view", "my-team.my-timesheet.submit"
        ],

        // ---- Additional 21 roles configured similarly ----
    };

    public static IReadOnlyList<string> For(string roleKey) =>
        Map.TryGetValue(roleKey, out var keys) ? keys : [];

    private static string[] AllKeys() => [.. PermissionCatalog.AllKeys()];
}
```

### 6.2. JWT Token Issuance with Permission Claims (`AuthService.cs`)
```csharp
public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request)
{
    var user = await _db.Users
        .Include(u => u.Role)
        .Include(u => u.Department)
        .Include(u => u.Designation)
        .FirstOrDefaultAsync(u => u.Email == request.Email);

    if (user == null || !_passwordHasher.Verify(request.Password, user.PasswordHash))
        throw new UnauthorizedAccessException("Invalid credentials.");

    var claims = new List<Claim>
    {
        new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
        new(ClaimTypes.Email, user.Email),
        new(ClaimTypes.Name, $"{user.FirstName} {user.LastName}"),
        new(ClaimTypes.Role, user.Role.Name),
        new("department_id", user.DepartmentId.ToString()),
        new("designation_id", user.DesignationId.ToString()),
    };

    // Embed all granular permissions from role JSONB into token
    foreach (var perm in user.Role.Permissions)
    {
        claims.Add(new Claim("permission", perm));
    }

    var token = _jwtGenerator.GenerateToken(claims);
    return new AuthResponseDto(token, user);
}
```

### 6.3. Endpoint Guard Attribute (`RequirePermissionAttribute.cs`)
```csharp
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
public sealed class RequirePermissionAttribute(string permission) : Attribute, IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;
        if (user.Identity?.IsAuthenticated != true)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        if (!user.HasClaim("permission", permission))
        {
            context.Result = new ForbidResult();
        }
    }
}
```

---

## 7. Frontend Implementation (React + TypeScript)

### 7.1. Employee Onboarding Form Auto-Mapping (Approach 1)
```tsx
import React, { useState } from "react";
import { useForm } from "react-hook-form";

export function EmployeeOnboardingModal({ departments, designations, roles, onSave }) {
  const [selectedDeptId, setSelectedDeptId] = useState<string>("");
  const form = useForm({
    defaultValues: {
      firstName: "",
      lastName: "",
      email: "",
      departmentId: "",
      designationId: "",
      roleId: "",
    }
  });

  // 1. Filter designations for chosen department
  const filteredDesignations = designations.filter(d => d.departmentId === selectedDeptId);

  // 2. Auto-Select Role on Designation Select (Approach 1)
  const handleDesignationChange = (designationId: string) => {
    form.setValue("designationId", designationId);
    
    const designation = designations.find(d => d.id === designationId);
    if (designation?.defaultRoleId) {
      // Auto-fills Column 3 RBAC role!
      form.setValue("roleId", designation.defaultRoleId);
    }
  };

  return (
    <form onSubmit={form.handleSubmit(onSave)}>
      {/* Department */}
      <label>Department</label>
      <select 
        value={selectedDeptId} 
        onChange={(e) => {
          setSelectedDeptId(e.target.value);
          form.setValue("departmentId", e.target.value);
        }}
      >
        <option value="">Select Department...</option>
        {departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
      </select>

      {/* Designation */}
      <label>Designation</label>
      <select 
        disabled={!selectedDeptId}
        onChange={(e) => handleDesignationChange(e.target.value)}
      >
        <option value="">Select Designation...</option>
        {filteredDesignations.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
      </select>

      {/* RBAC Role (Auto-Selected, Overridable by Admin) */}
      <label>Assigned RBAC Role</label>
      <select {...form.register("roleId")}>
        <option value="">Select Role...</option>
        {roles.map(r => <option key={r.id} value={r.id}>{r.displayName}</option>)}
      </select>

      <button type="submit">Onboard Employee</button>
    </form>
  );
}
```

### 7.2. Permission Checking Component (`<Can>`)
```tsx
import { ReactNode } from "react";
import { useAuth } from "@/lib/auth-context";

interface CanProps {
  permission: string;
  children: ReactNode;
  fallback?: ReactNode;
}

export function Can({ permission, children, fallback = null }: CanProps) {
  const { user } = useAuth();
  const hasPermission = user?.permissions?.includes(permission);

  return hasPermission ? <>{children}</> : <>{fallback}</>;
}
```

---

## 8. Settings & Dynamic Administration

### 1. Dynamic Roles Matrix UI (`/dh-settings-security-roles`)
- Displays all **27 Roles** in a grid view.
- Admins can expand any module (e.g. *Projects > Health*) and toggle individual action permissions (*Raise Issue*, *Edit Issue*, *Resolve Issue*).
- Clicking **Save** calls `PUT /api/v1/roles/{id}/permissions` and logs the change to `role_permission_audits`.
- Clicking **Reset to Baseline** restores the default permissions from `RoleBaselines.cs`.

### 2. Designation Master Management (`/dh-settings-masters`)
- Displays all designations grouped by department.
- Each row includes a dropdown for **Default RBAC Role**.
- If HR adds a new designation (e.g., `Senior AI Red Teamer`), they can select the default role (`Testing-Team Leader`) directly in the UI.

---

## 9. Step-by-Step Execution Checklist

- [x] **Step 1**: Finalize Master Catalog & 27 Roles in [RBAC_MASTER_CATALOG_AND_INTEGRATION_GUIDE.md](file:///c:/Users/Pradnya%20Kamble/Downloads/Talakunchi/project_TrackerPro/RBAC_MASTER_CATALOG_AND_INTEGRATION_GUIDE.md).
- [ ] **Step 2**: Create PostgreSQL Migration for `roles`, `mst_designations.DefaultRoleId`, and `role_permission_audits`.
- [ ] **Step 3**: Update `RoleBaselines.cs` and `DbSeeder.cs` with the full 27 role matrix and default designation mappings.
- [ ] **Step 4**: Update Frontend `catalog.ts` and `matrix.ts` with all 27 roles and permissions.
- [ ] **Step 5**: Integrate Auto-Selection logic into Employee Onboarding dialog in `resources.index.tsx`.
- [ ] **Step 6**: Test end-to-end user login, permission gating, and Settings modification.
