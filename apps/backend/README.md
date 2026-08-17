# PMS Backend

ASP.NET Core 10 + PostgreSQL backend for **Pulse PMO** (Project Compass) — the enterprise
PMO, resource management, timesheet, approval and finance platform. The project is a single
`PMS.API` web application (the GitHub repo is `project_TrackerPro`; internally it is called **PMS**).

> Full architecture & roadmap: [`wiki/31_Backend_Plan_DotNet.md`](../../wiki/31_Backend_Plan_DotNet.md)

## Solution structure

```
apps/backend/
├── PMS.slnx                       # Solution (slnx, matches repo convention)
├── PMS.API.csproj                 # The single ASP.NET Core Web API project
├── Program.cs                     # Host bootstrap (Serilog, controllers, JWT, pipeline)
├── appsettings.json               # Connection string, JWT, CORS, Serilog
├── appsettings.Development.json   # Dev-only settings (Database:AutoMigrate)
├── Properties/launchSettings.json # Dev launch profiles
├── Configuration/                 # DI registrations (DependencyInjectionExtensions.cs)
├── Infrastructure/
│   ├── Authentication/            # JWT tokens, BCrypt, login rate limiting
│   ├── Authorization/             # Permission guards, current-user resolution
│   ├── Cache/                     # Reserved for future use
│   ├── Persistence/               # EF Core DbContext, configurations, seeding
│   └── Swagger/                   # OpenAPI (Swagger) setup
├── Jobs/                          # Reserved for Hangfire background jobs
├── Logs/                          # Serilog runtime logs
├── Middleware/                    # Exception handling, validation filter
├── Migrations/                    # EF Core migrations
├── Modules/                       # Business modules (see Modules/README.md)
│   ├── Auth/                      # login, refresh, logout, me, change-password
│   ├── Customers/                 # clients — CRUD + data scoping
│   ├── Users/                     # users & roles management
│   ├── Health/                    # health endpoint
│   └── (ActionCentre, Dashboard, MyTeam, Projects, Reports, Repository,
│        Resources, Settings)      # reserved for future modules
├── Shared/
│   ├── Common/                    # Models (BaseEntity), Repositories, Wrappers (ApiResponse, PagedResult)
│   ├── Constants/                 # Permissions
│   └── Exceptions/                # Business exceptions
├── tests/
│   ├── PMS.UnitTests/             # Fast unit tests (JWT, pagination, domain rules)
│   └── PMS.IntegrationTests/      # API smoke tests (WebApplicationFactory)
├── docker-compose.yml             # Local PostgreSQL 16
├── .env.example                   # Environment variable reference
└── README.md
```

## Prerequisites

- [.NET SDK 10](https://dotnet.microsoft.com/download) (verified: 10.0.302)
- PostgreSQL 16 — either an existing install or:
  ```bash
  docker compose up -d
  ```
- A `trackerpro` database/user (the `DefaultConnection` in `appsettings.json` assumes
  `Host=localhost;Port=5432;Database=trackerpro;Username=trackerpro;Password=trackerpro_dev`)

## Run

```bash
cd apps/backend
dotnet restore
dotnet run --project PMS.API.csproj
```

- API: `http://localhost:5194` (see `Properties/launchSettings.json`)
- Swagger UI: `/swagger`
- Health check: `/api/v1/health` → `{ "data": { "status": "ok" }, ... }`

## Tests

```bash
dotnet test tests/PMS.UnitTests          # no external dependencies
dotnet test tests/PMS.IntegrationTests   # requires a running PostgreSQL
```

## Smoke test (live API)

With the API running, verify the **Customer (Clients) module** end-to-end:

```bash
cd apps/backend
dotnet run --project PMS.API.csproj      # terminal 1 — start the API
bash scripts/smoke-test-customers.sh     # terminal 2 — run the checks
```

The script logs in as the demo admin (`dhanshree@acme.co` / `Password@123`) and exercises
health, login, auth guard (401), list, get, create, update, validation (400) and soft-delete,
printing `PASS`/`FAIL` per step plus a final verdict. Exit code `0` = all checks passed.
Override the credentials with `SMOKE_EMAIL` / `SMOKE_PASSWORD` if needed.

## Project layout rules

- **Single project:** everything lives in `PMS.API` — folders follow the layout above and
  namespaces mirror the folder names (`PMS.API.Modules.Customers.Controllers`,
  `PMS.API.Shared.Common.Wrappers`, …).
- **Modules:** every business module is a folder under `Modules/<Module>/` with
  `Controllers/`, `DTOs/`, `Models/`, `Services/`, `Validators/` (see `Modules/README.md`).
- **Permissions:** never hardcode roles in controllers — use
  `[RequirePermission(Permissions.X)]` with keys from `Shared/Constants/Permissions.cs`.
- **Audit columns:** all entities derive from `BaseEntity` (created/updated/soft-delete).
- **Naming:** tables are lowercase snake_case (e.g. `refresh_tokens`); C# types PascalCase.

## Demo data (Development)

On first start the API auto-applies migrations and seeds (see `Database:AutoMigrate` in
`appsettings.Development.json`):

- **Users:** the 14 people from `mock-data.ts` (e.g. `dhanshree@acme.co`, `rahul@acme.co`,
  `riya@acme.co`) — password `Password@123`, `MustChangePassword = true`
- **Roles:** 12 roles with permission sets matching the RBAC matrix
- **Clients:** the 10 mock clients (`Northwind Bank`, `Helix Pharma`, …) with sub-ventures & contacts

Log in as the admin for full visibility: `dhanshree@acme.co` / `Password@123`.
The frontend auto-logs-in with these demo credentials when `VITE_DEMO_LOGIN=true` (default).

## Security defaults (do not weaken)

- BCrypt (work factor 12) password hashing — see `IPasswordHasher`
- JWT access tokens (30 min) + rotating refresh tokens (stored hashed) — see `JwtTokenService`
- `[RequirePermission]` guards on every endpoint
- CORS restricted to configured frontend origins
- Serilog structured logging; global exception handler returns the standard envelope
- `Jwt:SigningKey` and connection strings come from secrets/env in anything but local dev
