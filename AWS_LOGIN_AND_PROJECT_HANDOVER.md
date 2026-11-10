# 🚀 Project Knowledge Base & AWS Login Handover Guide

> **Prepared For:** Kiro (AWS & Cloud Infrastructure Specialist)  
> **Project:** Talakunchi AI PMS / TrackerPro / Pulse PMO  
> **Current Workspace:** `PMS_uat_clean` (Branch: `uat_clean9` / `uat_clean8`)  
> **Date:** November 2026  
> **Document Purpose:** Complete knowledge base covering system architecture, domain models, database schemas, current authentication mechanisms, and an exact blueprint for implementing AWS Login (Cognito / OIDC / ALB).

---

## Table of Contents

1. [Executive Summary & Business Domain](#1-executive-summary--business-domain)
2. [High-Level Architecture & Tech Stack](#2-high-level-architecture--tech-stack)
3. [Current Dev Authentication vs. Target AWS Auth](#3-current-dev-authentication-vs-target-aws-auth)
4. [User Identity & Employee Data Model](#4-user-identity--employee-data-model)
5. [Role-Based Access Control (RBAC) System](#5-role-based-access-control-rbac-system)
6. [Key Application Modules & Workflows](#6-key-application-modules--workflows)
7. [Step-by-Step AWS Login Implementation Plan for Kiro](#7-step-by-step-aws-login-implementation-plan-for-kiro)
8. [Docker & Local Environment Reference](#8-docker--local-environment-reference)

---

## 1. Executive Summary & Business Domain

**Talakunchi AI PMS (TrackerPro / Pulse PMO)** is an enterprise Project Management & Resource Management System built for an IT professional services and cybersecurity consulting organization (Talakunchi / Aditya Birla). 

The platform connects four key operational pillars:
1. **Resource & Talent Management:** Employee directory, skillsets, onboarding/offboarding, profile details, and employment bonds.
2. **Customer & Venture Management:** Client records, ventures, sub-ventures, SPOCs, Sales Managers (SM), and Engagement Managers (EM).
3. **Project & Delivery Governance:** Full project lifecycle from draft proposal/WBS to execution, service catalogs, milestone tracking, team assignments, escalations, and health metrics.
4. **Operations & Timesheets:** Weekly employee timesheet submissions and manager approvals, team availability calendar, shift coverage, company leave calendar, and a centralized Action Center.

```
+-----------------------------------------------------------------------------------+
|                                 PULSE PMO (PMS)                                   |
+-------------------+--------------------+---------------------+--------------------+
|  Resources & HR   | Customers & Sales  | Projects & Delivery | Operations & Team  |
| - Directory       | - Clients          | - WBS Onboarding    | - My Team Roster   |
| - Detail Profiles | - Sub-ventures     | - Service Catalog   | - Shift Coverage   |
| - Exit Summary    | - EM / SM Mapping  | - Health & Alerts   | - Timesheets       |
| - Bulk Upload     | - Contacts / SPOCs | - Team Allocations  | - Action Center    |
+-------------------+--------------------+---------------------+--------------------+
```

---

## 2. High-Level Architecture & Tech Stack

### Frontend Application
- **Framework:** React 19 with TypeScript.
- **Routing & SSR:** TanStack Router (`@tanstack/react-router`) with TanStack React Start client.
- **State & Data Fetching:** TanStack React Query (`@tanstack/react-query`), custom React contexts (`AuthProvider`, `RoleProvider`, `PermissionProvider`), and Zustand stores (`dh-store.ts`, `workspace-store.ts`).
- **Styling & UI:** Tailwind CSS, Radix UI primitives, Lucide React icons, Sonner toasts.
- **Build Tool:** Vite 7.
- **Current Port:** `3000` (Docker host port `39107`).

### Backend Web API
- **Framework:** ASP.NET Core 10 (C# / .NET 10.0 Web API).
- **ORM / Persistence:** Entity Framework Core (EF Core 10) with PostgreSQL driver (`Npgsql.EntityFrameworkCore.PostgreSQL`).
- **Logging:** Serilog structured logging.
- **Documentation:** Swagger / OpenAPI UI at `/swagger`.
- **Current Port:** `8080` (Docker host port `52815`).

### Database Engine
- **Engine:** PostgreSQL 16 (running in Docker container `pms_uat_db`).
- **Active Database Name:** `pms_uat_clean` (Shared container also holds `pms_uat`, `pms_development`, `pms_deployment`).
- **Port:** `5432` (Docker host port `41763`).
- **PostgreSQL Schemas (8 distinct schemas):**
  1. `auth`: User accounts, passwords, refresh tokens, system roles, and granular role permissions.
  2. `master`: System masters, service catalogs, departments, designations, leave calendar, and navigation catalog tables.
  3. `resource`: Employee profiles, personal data, certifications, experience, activity logs.
  4. `customer`: Clients, ventures, sub-ventures, contact persons/SPOCs.
  5. `project`: Projects, project services, draft WBS proposals, milestones, project team allocations, health escalations, alerts.
  6. `timesheet`: Timesheet weeks, timesheet entries, daily hours, and approvals.
  7. `action`: Bucket list tasks, approval requests, central notifications.
  8. `repository`: Document files, folder hierarchy, departmental file permissions.

---

## 3. Current Dev Authentication vs. Target AWS Auth

### Current Development Mode (How it works right now)
Currently, production login has not been connected. The application runs in a **Development Bypass Mode**:

```
+-------------------------------------------------------------+
| FRONTEND                                                    |
| 1. User picks persona in User Switcher dropdown             |
| 2. Stored in localStorage ('dh_demo_role')                  |
| 3. api-client.ts attaches headers on all HTTP requests:     |
|    - X-User-Email: <email>                                  |
|    - X-User-Role: <roleName>                                |
|    - X-User-Id: <uuid>                                      |
+------------------------------+------------------------------+
                               |
                               v
+-------------------------------------------------------------+
| BACKEND                                                     |
| 1. DevelopmentAuthBypassMiddleware.cs intercepts request    |
| 2. Extracts X-User-Email & X-User-Role                      |
| 3. Queries auth.tbl_users to confirm role                   |
| 4. Constructs ClaimsPrincipal with:                         |
|    - Sub (UserId)                                           |
|    - Email                                                  |
|    - Name                                                   |
|    - Role                                                   |
+-------------------------------------------------------------+
```

### Pre-Configured Backend JWT Pipeline
The backend is already architected for standard JWT Bearer tokens in [`apps/backend/Program.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Program.cs#L58-L88):
```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(o => {
        o.TokenValidationParameters = new TokenValidationParameters {
            ValidateIssuer = true,
            ValidIssuer = jwt["Issuer"],
            ValidateAudience = true,
            ValidAudience = jwt["Audience"],
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
            ValidateLifetime = true,
            NameClaimType = ClaimTypes.Name,
            RoleClaimType = ClaimTypes.Role,
        };
    });

builder.Services.AddAuthorization(o =>
    o.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build());
```

---

## 4. User Identity & Employee Data Model

There is a fundamental separation between a **Login Account** and an **Employee Profile**:

```
+------------------------------------+          +------------------------------------+
|          auth.tbl_users            |          |       resource.tbl_employees       |
+------------------------------------+          +------------------------------------+
| Id (UUID)                          |<-------->| Id (UUID)                          |
| Email (varchar 255)                | (1-to-1) | UserId (UUID, optional link)       |
| PasswordHash (text)                |  via     | Email (varchar 255)                |
| Name (varchar 200)                 |  Email   | EmployeeCode (e.g. "TK-0018")      |
| RoleId (UUID -> auth.tbl_roles)    |          | FirstName, LastName                |
| IsActive (boolean)                 |          | DepartmentId, DesignationId        |
+------------------------------------+          +------------------------------------+
```

### Key Tables in `auth` Schema:
1. `auth.tbl_users`:
   - `Id`: Primary key (UUID).
   - `Email`: Unique email (e.g. `admin@talakunchi.com`, `dhanshree.p@talakunchi.com`).
   - `Name`: Full display name.
   - `RoleId`: References `auth.tbl_roles.Id`.
   - `IsActive`: Whether account is active.
2. `auth.tbl_roles`:
   - `Id`: Primary key (UUID).
   - `Name`: System role identifier (e.g. `Admin`, `ProjectManager`, `Employee`, `HR`, `Accounts`, `Sales`).
   - `DisplayName`: Human-readable label (e.g. "Project Manager", "Super Administrator").
3. `auth.tbl_role_permissions`:
   - Links `RoleId` to catalog items (`mst_modules`, `mst_submodules`, `mst_widgets`, `mst_tabs`).
   - `CanView` (`0` or `1`)
   - `CanManage` (`0` or `1`)

---

## 5. Role-Based Access Control (RBAC) System

### Frontend Permission Evaluation ([`apps/frontend/src/lib/permissions.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/lib/permissions.tsx))
The frontend RBAC provider resolves permissions through three core functions:
- `canView(codeOrId: string): boolean`: Determines whether a module, page, widget, or tab is visible.
- `canManage(codeOrId: string): boolean`: Determines whether write/create/edit/delete buttons are unlocked.
- `hasPermission(key: string): boolean`: Used for route guards in navigation (`navigation.tsx`).

### Core RBAC Rules:
1. **Super Admin Bypass:** The `Admin` role automatically has full view and manage access across all modules without querying `tbl_role_permissions`.
2. **Settings Isolation:** The `Settings` module (`Roles & Permissions`, `Master`) is permanently reserved for `Admin` and is excluded from the RBAC table to prevent circular access lockout loops.
3. **Parent-Child Inheritance:** A submodule or tab cannot be viewed if its parent module is revoked (`canView(parent) == false`).
4. **Manage Strictness:** `canManage` never inherits automatically; it must be explicitly granted on the item AND its parent.

---

## 6. Key Application Modules & Workflows

| Module | Route | Purpose | Key Actions & Endpoints |
| :--- | :--- | :--- | :--- |
| **Dashboard** | `/` | Executive MIS Dashboard with team size, boarding, utilization & capacity | `GET /api/v1/dashboard/*` |
| **Action Center** | `/action-centre` | Unified inbox for tasks, approvals, and alert notifications | `GET/POST /api/v1/action-centre/*` |
| **Projects** | `/projects` | Project directory, draft proposals, full WBS onboarding | `GET/POST /api/v1/projects/*`, `/api/v1/project-drafts/*` |
| **Project Detail** | `/projects/$projectId` | Overview, WBS, Team allocation, Service tasks, Health escalations | `GET/PUT /api/v1/projects/{id}/*` |
| **Resources** | `/employee-directory` | Employee directory, search, filter, bulk upload from Excel | `GET/POST /api/v1/employees/*` |
| **Employee Detail**| `/employee-directory/$id`| Personal info, Org details, Bond info, Experience, Logs | `GET/PUT /api/v1/employees/{id}/*` |
| **Exit Summary** | `/exit-summary` | Historical record of resigned/exited employees | `GET /api/v1/employees/exited` |
| **Customer** | `/customers` | Client directory, venture/sub-venture hierarchy, EM/SM mapping | `GET/POST /api/v1/clients/*` |
| **Repository** | `/repository` | Corporate document repository with folder trees & departmental access | `GET/POST /api/v1/repository/*` |
| **My Team** | `/my-team/` | Team availability calendar, shift coverage, company leave calendar | `GET /api/v1/my-team/calendar` |
| **Timesheets** | `/my-team/timesheets` | Weekly timesheet entry, historical logs, manager approval workflows | `GET/POST /api/v1/timesheets/*` |
| **Settings** | `/settings-masters` | Master tables, Leave Calendar bulk upload, metadata management | `GET/POST /api/v1/leave-calendar/*`, `/api/v1/catalogs/*` |
| **Security Roles**| `/settings-security-roles`| RBAC configuration matrix to grant view/manage permissions per role | `GET/PUT /api/v1/roles/{id}/permissions` |

---

## 7. Step-by-Step AWS Login Implementation Plan for Kiro

Kiro can implement AWS authentication using either **Option A (AWS Cognito User Pool)** or **Option B (AWS Application Load Balancer with OIDC)**. Below is the blueprint for **AWS Cognito (Recommended)**.

### Target Authentication Flow:
```
[User Browser] 
      │ 
      ▼
1. User clicks "Sign In" -> Redirects to AWS Cognito Hosted UI / SAML / Microsoft SSO
      │ 
      ▼
2. User authenticates via AWS Cognito
      │ 
      ▼
3. Cognito redirects to Frontend callback: `http://<domain>/auth/callback?code=...`
      │ 
      ▼
4. Frontend exchanges code for Cognito JWT tokens (ID Token & Access Token)
      │ 
      ▼
5. Frontend stores token & attaches: `Authorization: Bearer <accessToken>` on all requests
      │ 
      ▼
6. Backend ASP.NET Core validates Cognito JWT against AWS JWKS endpoint:
   `https://cognito-idp.<region>.amazonaws.com/<userPoolId>/.well-known/jwks.json`
      │ 
      ▼
7. Backend extracts `email`, finds/provisions user in `auth.tbl_users`, sets `ClaimsPrincipal`.
```

---

### Step 1: Backend Configuration (`apps/backend`)

#### 1.1 Update `appsettings.json`:
Add the AWS Cognito configuration block:
```json
{
  "Aws": {
    "Region": "ap-south-1",
    "Cognito": {
      "UserPoolId": "ap-south-1_xxxxxxxxx",
      "AppClientId": "xxxxxxxxxxxxxxxxxxxxxxxxxx",
      "Authority": "https://cognito-idp.ap-south-1.amazonaws.com/ap-south-1_xxxxxxxxx"
    }
  }
}
```

#### 1.2 Update JWT Bearer Configuration in [`apps/backend/Program.cs`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/backend/Program.cs):
Replace the symmetric key validation with Cognito's OIDC Authority / JWKS:
```csharp
var cognitoAuthority = builder.Configuration["Aws:Cognito:Authority"];
var cognitoClientId = builder.Configuration["Aws:Cognito:AppClientId"];

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = cognitoAuthority;
        options.Audience = cognitoClientId;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = cognitoAuthority,
            ValidateAudience = true,
            ValidAudience = cognitoClientId,
            ValidateLifetime = true,
            NameClaimType = "cognito:username",
            RoleClaimType = ClaimTypes.Role
        };
    });
```

#### 1.3 Update or Remove `DevelopmentAuthBypassMiddleware.cs`:
In production/UAT mode, disable `DevelopmentAuthBypassMiddleware` so requests must present a valid Bearer token. Add a claims enrichment step or middleware to map the Cognito `email` claim to the local `auth.tbl_users` record:
```csharp
// Claims Enrichment Middleware
app.Use(async (context, next) =>
{
    if (context.User.Identity?.IsAuthenticated == true)
    {
        var email = context.User.FindFirst("email")?.Value;
        if (!string.IsNullOrEmpty(email))
        {
            var db = context.RequestServices.GetRequiredService<AppDbContext>();
            var user = await db.Users.Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower());
            
            if (user != null)
            {
                var appIdentity = new ClaimsIdentity(new[]
                {
                    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                    new Claim(ClaimTypes.Role, user.Role?.Name ?? "Employee")
                });
                context.User.AddIdentity(appIdentity);
            }
        }
    }
    await next(context);
});
```

---

### Step 2: Frontend Configuration (`apps/frontend`)

#### 2.1 Update [`apps/frontend/src/lib/api-client.ts`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/lib/api-client.ts):
Update `apiFetch` to pass the Bearer token instead of `X-User-Email`:
```typescript
function authHeaders(init?: HeadersInit): Headers {
  const headers = new Headers(init);
  const token = localStorage.getItem("access_token");
  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }
  return headers;
}
```

#### 2.2 Update [`apps/frontend/src/lib/auth-context.tsx`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/apps/frontend/src/lib/auth-context.tsx):
- Integrate AWS Amplify Auth library (`aws-amplify`) or standard OAuth2/OIDC redirect client.
- When `access_token` is not present, redirect the browser to the Cognito Hosted UI / Login URL.
- On return from Cognito (`/auth/callback`), extract tokens, save to `localStorage` / Secure Cookie, and set user state.

---

### Step 3: Just-In-Time (JIT) User Provisioning

When a user logs in via AWS Cognito for the first time:
1. Backend checks if `auth.tbl_users` contains their `email`.
2. If the user already exists: load their assigned role (`RoleId`) and permissions.
3. If the user is new:
   - Check if an employee record exists in `resource.tbl_employees` matching that `email`.
   - Create a row in `auth.tbl_users` with default role (`Employee` or role assigned in Cognito user groups).
   - Link `auth.tbl_users.Id` to `resource.tbl_employees.UserId`.

---

## 8. Docker & Local Environment Reference

### Running Containers:
| Container Name | Image Name | Internal Port | Host Port | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `pms_uat_clean_backend` | `pms-backend:uat-clean` | `8080` | `52815` | ASP.NET Core API |
| `pms_uat_clean_frontend` | `pms-frontend:uat-clean` | `3000` | `39107` | React 19 Frontend |
| `pms_uat_db` | `postgres:16-alpine` | `5432` | `41763` | PostgreSQL Database |

### Common Docker Commands:
```bash
# View container status
docker ps

# Build backend and frontend
docker compose -f docker-compose.uat-clean.yml -p pms_uat_clean build

# Start the stack in background
docker compose -f docker-compose.uat-clean.yml -p pms_uat_clean up -d

# Restart a specific service (e.g. backend after code change)
docker compose -f docker-compose.uat-clean.yml -p pms_uat_clean up -d --force-recreate backend

# View live backend logs
docker logs -f pms_uat_clean_backend

# Execute PostgreSQL query directly in container
docker exec -i pms_uat_db psql -U postgres -d pms_uat_clean -c "SELECT count(*) FROM auth.tbl_users;"
```

### Database SQL Snapshot Files:
- Primary UAT dump: [`database/pms_uat.sql`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/database/pms_uat.sql)
- Mirror dump: [`database/trackerpro-uat.sql`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/database/trackerpro-uat.sql)

---

## 9. Contacts & Ownership

- **Lead Application Engineer:** Omkar Gaikwad
- **AWS Infrastructure & Login Setup:** Kiro
- **Current Git Branch:** `uat_clean9` (Remote: `origin/uat_clean9`)
