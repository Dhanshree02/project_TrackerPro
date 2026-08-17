# Backend Plan — .NET + PostgreSQL

> **Status:** ✅ Scaffold complete — `apps/backend/` solution builds & boots  \
> **Date:** 2026-08-07  \
> **Stack:** .NET 10 (ASP.NET Core) + PostgreSQL 16 + EF Core 10  \
> **Supersedes:** The FastAPI drafts in [[22_Backend_Architecture_Draft]], [[Backend_Master_Plan]] and [[BACKEND_DEVELOPMENT_PHASES]]. The domain design, database schema ideas and API conventions from those docs are carried over; only the implementation stack changes.

---

## 1. Project Analysis (what we learned)

Pulse PMO is a **frontend-only SPA today (~80% complete)**. All data lives in
`apps/frontend/src/lib/mock-data.ts` and `dh-store.ts`; there is no backend and **no security**
(the role switcher lets anyone impersonate any role).

| Module | Frontend source | What it needs from the backend |
|--------|-----------------|--------------------------------|
| Auth / Users | `role-context.tsx`, mock `people[]` | Login, JWT, RBAC, user CRUD |
| Clients | `customers.*.tsx` | Client CRUD + role-scoped visibility |
| Projects | `projects.*.tsx`, `portfolio.tsx` | Lifecycle, stages, prerequisites, closure |
| WBS | `wbs-allocation.tsx`, `allocation.tsx` | WBS intake, allocation, smart fit-score suggestions |
| Tasks | project detail tabs, PM buckets | Task CRUD, assignment, buckets |
| Timesheets | `timesheet.tsx`, `my-team.timesheets.tsx` | Weekly submission, multi-level approval |
| Issues / Health | `health*.tsx` | Issue CRUD, comments, escalation, interviews |
| Resources | `resources.tsx`, `dh-*` | Workload, bench, onboarding/offboarding |
| Finance | project detail invoices tab | Invoices, PO, payment status |
| Notifications | topbar bell (mock) | In-app + email notifications |
| Reports | `reports.tsx`, `dh-reports.tsx` | Aggregations, KPI dashboards |
| Audit | entity-level arrays | Centralized `audit_log` |

**Key constraints for the backend:**
- **Security is greenfield** — build auth/RBAC correctly from day one (Phase 1).
- **Data shapes are already defined** by the frontend types — the API must return
  compatible shapes so routes can be migrated incrementally (per wiki/30).
- **Roles are 12** (`pmo`, `hod`, `business_owner`, `dhanshree`, `sales`, `accounts`, `hr`,
  `senior_pm`, `engagement_manager`, `pm`, `tl`, `employee`) — mapped in `UserRole` enum.
- **Company product, module-by-module delivery** — a modular monolith with feature folders
  keeps each module independently shippable.

---

## 2. Stack Decision

| Layer | Choice | Why |
|-------|--------|-----|
| Framework | **ASP.NET Core 10 (controllers)** | LTS, enterprise standard, strong typing, first-party JWT/EF integration |
| Language | C# 13 | Static typing catches API/contract drift at compile time |
| ORM | **EF Core 10 + Npgsql** | Mature migrations (`dotnet ef`), LINQ, PostgreSQL provider |
| Database | **PostgreSQL 16** | JSONB, arrays, enums, full-text search, row-level security option |
| Auth | JWT Bearer + BCrypt | Industry standard; refresh-token rotation |
| Validation | FluentValidation | Declarative request validation, testable |
| Logging | Serilog | Structured logs, file + console sinks |
| Docs | Swashbuckle / OpenAPI | Swagger UI for the frontend team to test against |
| Testing | xUnit | Unit + integration (`WebApplicationFactory`) |
| Container | Docker Compose (dev) | Reproducible PostgreSQL |

> **Why not FastAPI?** Nothing wrong with it — the project team has decided on .NET.
> The API design (paths, envelope, pagination) is stack-agnostic and carries over as-is.

---

## 3. Architecture

**Modular monolith** on a **Clean Architecture core** — one deployable, module-by-module delivery.

```
┌──────────────────────────────────────────────────────────┐
│ PMS.API  — single ASP.NET Core web project (modular        │
│           monolith; folders mirror namespaces)             │
├──────────────────────────────────────────────────────────┤
│ Modules/         Auth · Customers · Users · Health (+future)│
│ Infrastructure/  Authentication · Authorization ·           │
│                  Persistence · Swagger · Cache (reserved)  │
│ Shared/          Common · Constants · Exceptions           │
│ Middleware/      ExceptionHandlingMiddleware, ValidationFilter
└──────────────────────────────────────────────────────────┘
                        │
                  PostgreSQL 16
```

The single `PMS.API` project holds everything — folders mirror the `PMS.API.*` namespaces.
No EF/HTTP coupling concerns across projects because there is one assembly.

### Created structure (`apps/backend/`)

```
apps/backend/
├── PMS.slnx                        # solution
├── PMS.API.csproj                  # single web project
├── Program.cs, appsettings.json, appsettings.Development.json, Properties/
├── Configuration/                  # DependencyInjectionExtensions.cs → AddApplicationServices()
├── Infrastructure/
│   ├── Authentication/             # JwtOptions, JwtTokenService, IPasswordHasher, AuthService, LoginRateLimiter
│   ├── Authorization/              # RequirePermissionAttribute, ICurrentUserService, CurrentUserService
│   ├── Persistence/                # AppDbContext, Configurations/, Seeding/, DesignTimeDbContextFactory
│   ├── Swagger/                    # SwaggerExtensions.cs → AddSwaggerDocs()
│   └── Cache/                      # reserved for future use
├── Jobs/                           # reserved for Hangfire background jobs
├── Logs/                           # Serilog runtime logs
├── Middleware/                     # ExceptionHandlingMiddleware, ValidationFilter
├── Migrations/                     # EF Core migrations
├── Modules/                        # business modules — see Modules/README.md
│   ├── Auth/                       # login, refresh, logout, me, change-password
│   ├── Customers/                  # clients — CRUD + data scoping
│   ├── Users/                      # users & roles management
│   ├── Health/                     # health endpoint
│   └── (ActionCentre, Dashboard, MyTeam, Projects, Reports, Repository,
│        Resources, Settings)       # reserved for future modules
├── Shared/
│   ├── Common/                     # Models/ (BaseEntity), Repositories/ (reserved), Wrappers/ (ApiResponse, PagedResult)
│   ├── Constants/                  # Permissions
│   └── Exceptions/                 # NotFoundException, ConflictException, ForbiddenException
├── tests/                          # PMS.UnitTests (JWT, pagination) + PMS.IntegrationTests (smoke)
├── docker-compose.yml              # PostgreSQL 16
├── .env.example
└── README.md
```

**Already verified:** `dotnet build` → 0 errors/0 warnings · 5/5 unit tests pass · API boots,
`/api/v1/health` returns `{ data, meta, errors }`, Swagger serves OpenAPI 3.0.

---

## 4. Security Plan (company-grade)

| Threat | Control | Where |
|--------|---------|-------|
| Stolen credentials | BCrypt (cost 12) password hashing | `IPasswordHasher` |
| Token theft | 30-min access tokens + rotating refresh tokens (stored **hashed**) | `JwtTokenService` |
| Privilege escalation | Permission-based guards — `[RequirePermission(Permissions.X)]`, claims carry permissions | `RequirePermissionAttribute` |
| Data leakage | Role-scoped queries (SPM sees only assigned clients, PMO sees all) | per-feature services (Phase 2) |
| Broken access control | Global soft-delete filters + audit columns on every entity | `BaseEntity`, `AddSoftDeleteFilter` |
| Injection | EF Core parameterized queries; never raw SQL with user input | EF Core |
| XSS / CSRF | JWT in `Authorization` header (no cookies → no CSRF surface); CSP on frontend | — |
| Brute force | Rate limiting (add `AspNetCoreRateLimit` in Phase 1 hardening) | planned |
| Secret leakage | `Jwt:SigningKey`, connection strings from env/user-secrets; `.env` git-ignored | `.env.example` |
| Auditability | Every state change writes to `audit_log` (actor, entity, old/new JSONB) | Phase 5 |
| Security headers | HTTPS redirect, `AddSecurityHeaders` middleware | Phase 1 hardening |

**Phase 1 hardening checklist (after auth works):** rate limiting, security headers,
login lockout after N failures, `MustChangePassword` flow, email verification.

---

## 5. API Conventions (unchanged from the design draft)

- Base path: `/api/v1/...`
- Auth: `Authorization: Bearer <JWT>`
- Envelope: `{ "data": …, "meta": { total, page, per_page }, "errors": […] }`
- Pagination: `?page=1&per_page=20`; sorting `?sort=name&order=asc`; filtering by query params
- Error codes: `VALIDATION_ERROR`, `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`, `INTERNAL_ERROR`

---

## 6. Module-by-Module Roadmap (what to do next)

Order is chosen so each phase delivers a usable slice and the security backbone exists first.

| Phase | Modules | Scope | Est. |
|-------|---------|-------|------|
| **1** | **Auth & RBAC** | Users, Roles, Permissions seed; login/refresh/logout/me; `dotnet ef` initial migration; seed users from `mock-data.ts` `people[]`; replace the frontend role switcher with a real login | 2–3 wks |
| **2** | **Clients, Projects, WBS, Tasks** | CRUD APIs + role-scoped data; project stages + prerequisites; WBS allocation with the `fitScore` algorithm ported from `dh-helpers.ts`; seed clients/projects/WBS | 4–5 wks |
| **3** | **Issues, Approvals** | Issue CRUD + comments + escalation; generic approval workflow engine (state machine) reused by timesheets later | 3 wks |
| **4** | **Resources, Timesheets** | Workload/utilization; PM buckets; weekly timesheet submit → multi-level approve/reject; cell comments | 3 wks |
| **5** | **Notifications, Audit** | In-app + email notifications; centralized `audit_log` with automatic capture | 2 wks |
| **6** | **Finance** | Invoices, POs, payment status, tax calc; closure validation rules | 2 wks |
| **7** | **Reports** | Aggregation endpoints, materialized views, export groundwork | 2 wks |

**Parallel tracks that start in Phase 1:** (a) frontend API client (`src/lib/api.ts`) with
`fetch` wrapper + token refresh + 401 redirect; (b) incremental route migration using React Query.

### Immediate next steps (right after this scaffold)

1. **Create the `trackerpro` database** (the local Postgres on :5432 is already running)
   and run the initial migration: `dotnet ef migrations add InitialIdentity` then `dotnet ef database update`.
2. **Implement Phase 1 auth** — `AuthService` (login/refresh/logout/me), seed roles + users
   with BCrypt hashes, then swap the frontend role switcher for a login form.
3. **Add the API client + token storage** on the frontend (httpOnly cookie option or
   in-memory + refresh rotation).
4. **Seed real data** — a seed script that mirrors `mock-data.ts` so every existing screen
   keeps working while being migrated module by module.

---

## 7. Open decisions to confirm

- **JWT storage on the frontend:** httpOnly cookie (more secure, needs CSRF handling for
  cookie-based APIs) vs. in-memory + refresh rotation (survives browser refresh poorly).
  → Recommend httpOnly cookie served by the API over `Set-Cookie`, with a `/auth/csrf` token.
- **Refresh token rotation policy:** rotate on every refresh, revoke family on reuse (detect theft).
- **Deployment target:** Railway/Render (fastest), Azure App Service (company standard?), or
  AWS ECS. Containerized either way.
- **Row-Level Security:** for a company this size, per-role query scoping in services is
  simpler than Postgres RLS — adopt RLS later if tenant isolation is needed.

---

## Related Documents

- [[20_Database_Design_Draft]] — schema to port into EF Core migrations
- [[21_API_Design_Draft]] — endpoint specifications
- [[23_Security_and_RBAC]] — permission map (mirrored in `Permissions.cs`)
- [[24_Audit_Logging]] — audit_log design
- [[30_Future_Backend_Implementation]] — incremental migration strategy
- [[28_Development_Roadmap]] — overall roadmap
