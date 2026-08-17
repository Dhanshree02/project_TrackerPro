# Client Module — Completion Plan

> **Assignee:** Client module owner  \
> **Status:** 🟡 Core complete (backend + DB + frontend read path) — see checklist below  \
> **Stack:** ASP.NET Core 10 + EF Core 10 + PostgreSQL 16  \
> **Created:** 2026-08-07

---

## 1. Module Scope

The Client module covers the customer directory (TK partners + sub-ventures) used by the
`/customers` screens. It is the first backend module delivered on the .NET stack and the
reference pattern for every later module (Auth, Projects, WBS, …).

```
Frontend (customers.index.tsx) → GET /api/v1/clients → ClientService (role-scoped) → PostgreSQL
```

---

## 2. What is DONE ✅

### Backend (`apps/backend/`)
| Piece | Location | Notes |
|-------|----------|-------|
| `Client` entity + `ClientContact` + `ClientAssignment` | `apps/backend/Modules/Customers/Models/` | JSONB sub-ventures & contacts, soft delete via `BaseEntity` |
| `ClientType` / `ClientStatus` enums | `apps/backend/Modules/Customers/Models/` | mirrors frontend `"NEW" / "OLD"` |
| DTOs + FluentValidation validators | `apps/backend/Modules/Customers/` | name/industry required, email format, ≤20 sub-ventures |
| `IClientService` + scoping rules | `apps/backend/Modules/Customers/Services` + `apps/backend/Modules/Customers/Services/ClientService.cs` | global roles see all; SPM/EM see EM-name + explicit assignments; others assignments only |
| `ClientsController` | `apps/backend/Modules/Customers/Controllers/ClientsController.cs` | CRUD + soft delete, `[RequirePermission]` guards |
| EF configuration + migration | `Persistence/Configurations/ClientConfiguration.cs`, `Migrations/InitialIdentity` | `clients` + `client_assignments` tables |
| Seed (10 mock clients + 14 users + 12 roles) | `Persistence/Seeding/DbSeeder.cs` | deterministic ids, BCrypt `Password@123` demo creds |
| Dev DB bootstrap | `DbInitializerHostedService` | migrates + seeds on `dotnet run` (Development only) |

### API contract
| Method | Endpoint | Permission | Notes |
|--------|----------|-----------|-------|
| GET | `/api/v1/clients?page=&perPage=&search=` | `clients:read` | paged, search by name/industry |
| GET | `/api/v1/clients/{id}` | `clients:read` | |
| POST | `/api/v1/clients` | `clients:write` | validation via FluentValidation |
| PUT | `/api/v1/clients/{id}` | `clients:write` | partial update (null = unchanged) |
| DELETE | `/api/v1/clients/{id}` | `clients:write` | soft delete |

Response envelope: `{ data, meta, errors }` · camelCase · error codes `VALIDATION_ERROR / NOT_FOUND / UNAUTHORIZED / INTERNAL_ERROR`.

### Frontend (read path connected)
- `src/lib/api-client.ts` — fetch wrapper: `VITE_API_URL`, JWT header, refresh-on-401 rotation, dev demo auto-login
- `src/lib/api/clients.ts` — typed service + `mapApiClient()` DTO→`Client` mapping
- `customers.index.tsx` — loads clients from the API; **falls back to mock data when the backend is offline** (no regression)
- `.env.example` — documents `VITE_API_URL` + demo login vars

### Security applied
- JWT access (30 min) + rotating refresh (7 d, stored hashed) with reuse detection
- BCrypt cost-12 password hashing; demo users `MustChangePassword=true`
- Permission guards on every client endpoint; role-scoped queries in the service
- Soft delete + audit columns on all entities

---

## 3. Where to fill the connection links 🔗

### Database connection (backend → PostgreSQL)
| Where | What |
|-------|------|
| `apps/backend/appsettings.json` → `ConnectionStrings:DefaultConnection` | `Host=localhost;Port=5432;Database=trackerpro;Username=trackerpro;Password=trackerpro_dev` |
| Override (recommended for secrets) | `dotnet user-secrets set "ConnectionStrings:DefaultConnection" "…"` in `apps/backend` |
| Env-var override (production) | `ConnectionStrings__DefaultConnection=…` |

**One-time DB setup** (needs the postgres superuser password once):
```sql
CREATE ROLE trackerpro LOGIN PASSWORD 'trackerpro_dev';
CREATE DATABASE trackerpro OWNER trackerpro;
```
then `dotnet ef database update` (or just `dotnet run` — the dev bootstrap migrates + seeds automatically).

### Frontend → backend link
| Where | What |
|-------|------|
| `apps/frontend/.env` (copy of `.env.example`) → `VITE_API_URL` | `http://localhost:5194` (matches the API's `launchSettings.json`) |

---

## 4. What remains for FULL completion (next steps)

- [ ] **Create the database** (needs postgres password) and run the initial migration + seed
- [ ] Wire the **New Client onboarding stepper** to `POST /api/v1/clients` (currently saves to the dh-store mock)
- [ ] Wire **edit / soft-delete** actions in the UI
- [ ] `GET /api/v1/clients/{id}/projects` when the Projects module lands
- [ ] Client **detail page** (`customers.$clientId.tsx`) reads from API
- [ ] Upload KYC documents (file storage service — Phase 4 roadmap item)
- [ ] Integration tests for client CRUD + role scoping against a test database
- [ ] Normalize `client_contacts` to its own table if contact-level querying is needed

---

## 5. How to run & verify

```bash
# backend
cd apps/backend
dotnet run --project PMS.API.csproj        # migrates + seeds on first start (Development)
# Swagger: http://localhost:5194/swagger

# frontend
cd apps/frontend
cp .env.example .env                           # VITE_API_URL=http://localhost:5194
npm run dev                                    # http://localhost:6002/customers

# login (demo): dhanshree@acme.co / Password@123
```

Verify: Swagger → Authorize → login via `/auth/login` → copy token → call `GET /clients`.
Frontend: `/customers` shows the 10 seeded clients (backend online) or mock data (offline).

---

## 6. Next module

**Users & Auth — ✅ DONE** (see [[33_Users_Auth_Module_Plan]]).

Next up: **Projects** — client detail already expects `GET /clients/{id}/projects`; the
project lifecycle, stage tracker, prerequisites, and closure rules port from the frontend
mock data.

## Related
- [[31_Backend_Plan_DotNet]] — architecture & full roadmap
- [[21_API_Design_Draft]] — API conventions
- [[23_Security_and_RBAC]] — permission model
