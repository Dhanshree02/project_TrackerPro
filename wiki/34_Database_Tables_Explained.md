# Database Tables — Explained (Simple)

> **Last Updated:** 2026-08-12
> **Checked against the live PostgreSQL 18 server** (localhost:5432).
> **Nothing in the database was changed to write this document.**

---

## 1. First — Why do I see "2 servers" with the same `trackerpro` database?

**Short answer:** You don't have two servers. You have **one PostgreSQL server** and **two saved connections to it** in pgAdmin.

pgAdmin has two saved entries, both pointing to the same local PostgreSQL 18 instance:

| Saved name in pgAdmin | Host | Port | Same server? |
|---|---|---|---|
| `Local PostgreSQL` | `127.0.0.1` | 5432 | Yes |
| `PostgreSQL 18` | `localhost` | 5432 | Yes |

`127.0.0.1` and `localhost` are the **same machine/port**, so both entries show the **exact same databases and tables** — that's why `trackerpro` appears under both with identical tables. It's just two bookmarks to one server, created when the server was registered twice.

- You can safely delete one of the two entries in pgAdmin (right-click → Delete Server). That only removes the bookmark — **it does not touch the actual server or any data.**
- The real server is the Windows service **`postgresql-x64-18`** running on port `5432`.

### And there are actually TWO databases (not two servers)

On that one server there are two application databases:

| Database | Owner | Used by Project Compass? |
|---|---|---|
| `trackerpro` | `trackerpro` | ✅ Yes — this is the app database (see connection string in `appsettings.json`) |
| `EmployeeManagementDB` | `emp_app_user` | ❌ No — leftover from a **separate, older employee-management prototype app** |

So what you saw as "2 servers with trackerpro" is really:
1. **1 server** registered twice in pgAdmin (shows the same `trackerpro` twice), **plus**
2. **1 extra database** (`EmployeeManagementDB`) that belongs to a different prototype and is **not connected to this project at all** (no connection string for it exists in the codebase).

> About Keka: onboarding / offboarding currently happens inside the **Keka app**, and the plan is to pull that data into this system via **Keka's API** later. No API is available yet, so **nothing is implemented for it** — and `EmployeeManagementDB` is not that integration either; it's just an old prototype that can be ignored (or dropped later if you want).

---

## 2. The `trackerpro` database (the real app database)

**7 business tables** + 1 bookkeeping table. Current row counts are shown next to each.

Why the schema is small: most modules (projects, tasks, timesheets, invoices, resources…) are **frontend demo/mock data** today. The backend only persists the pieces that genuinely need a server: **login/auth, RBAC, and client management**. When those modules get real backends later, their tables get added — nothing needs to be deleted or reduced now.

### Table overview

| Table | Rows | What it does |
|---|---|---|
| `users` | 21 | Everyone who can log in (employee info + login security) |
| `roles` | 13 | The RBAC roles (Admin, PMO, Employee, HR, …) + their permission matrix |
| `refresh_tokens` | 130 | Long-lived login sessions (keeps you logged in across page refreshes) |
| `role_permission_audits` | 14 | Audit trail: who changed which role permission, when, from → to |
| `clients` | 17 | Client companies (customer master data) |
| `client_assignments` | 4 | Which users are assigned to which clients (many-to-many) |
| `sub_ventures` | 57 | Sub-companies/entities under a client |
| `__EFMigrationsHistory` | 6 | EF Core bookkeeping (which migrations were applied) |

---

### `users` — the login + employee master

One row per person who can sign in. It doubles as the employee record (name, employee ID, department, designation).

| Column | Why it exists |
|---|---|
| `Id` | Primary key (UUID) |
| `Email` | Login name — unique, can't have two accounts on one email |
| `PasswordHash` | Bcrypt hash of the password — **never** the plain password |
| `Name` | Display name |
| `EmployeeId` | The employee code (unique per person) |
| `Department` / `SubDepartment` | Which department the person belongs to |
| `Designation` | Job title / role label |
| `Avatar` | Avatar reference for the UI |
| `RoleId` | FK → `roles.Id` — which RBAC role this user has |
| `IsActive` | Enable/disable login (inactive users can't sign in) |
| `MustChangePassword` | Force a password change on next login |
| `FailedLoginAttempts` | Count of wrong-password attempts (for lockout) |
| `LockedUntilUtc` | Auto-lockout time after too many failed attempts |
| `LastLoginAtUtc` | When the user last signed in |
| `PasswordChangedAtUtc` | When the password was last changed |
| `CreatedAtUtc` / `UpdatedAtUtc` | When the row was created / last modified |
| `CreatedBy` / `UpdatedBy` | Who created / last modified it |
| `DeletedAtUtc` | Soft delete — row is kept but "removed" when set |

---

### `roles` — RBAC roles + their permissions

One row per role (Admin, PMO, Business Owner, HOD, Engagement Manager, Senior PM, Project Manager, Employee, HR, Accounts & Finance, Sales & BD, …).

| Column | Why it exists |
|---|---|
| `Id` | Primary key (UUID) |
| `Name` | Unique code name for the role (used by the backend) |
| `DisplayName` | Human-friendly name shown in the UI |
| `Description` | What the role is for |
| `Permissions` | **JSONB** — the whole permission matrix for the role (module → submodule → action → allowed). Stored as JSON so no extra permission tables are needed |
| `IsSystemRole` | Protects built-in roles (e.g. Admin) from deletion |
| `IsActive` | Enable/disable the role |
| `CreatedAtUtc` / `UpdatedAtUtc` / `CreatedBy` / `UpdatedBy` / `DeletedAtUtc` | Standard audit columns (see `users`) |

---

### `refresh_tokens` — "keep me logged in" sessions

One row per active login session. Makes browser refresh / expired-JWT work without asking the user to log in again.

| Column | Why it exists |
|---|---|
| `Id` | Primary key (UUID) |
| `UserId` | FK → `users.Id` — whose session this is |
| `TokenHash` | SHA-256 hash of the refresh token (unique). **Only the hash is stored**, never the raw token — it lives in a secure HttpOnly cookie |
| `ExpiresAtUtc` | When the session dies (refresh tokens expire, e.g. 7 days) |
| `RevokedAtUtc` | When the session was cancelled (logout / replaced). Non-null = dead session |
| `ReplacedByTokenHash` | **Rotation** — when a token is refreshed, the new token's hash is recorded here so old tokens can be detected/rejected (theft protection) |
| `CreatedAtUtc` / `UpdatedAtUtc` / `CreatedBy` / `UpdatedBy` / `DeletedAtUtc` | Standard audit columns |

---

### `role_permission_audits` — audit log for permission changes

One row per permission change made by an admin (who, which role, which module/submodule/action, old value → new value, when).

| Column | Why it exists |
|---|---|
| `Id` | Primary key (UUID) |
| `RoleId` | FK → `roles.Id` (which role was changed) |
| `RoleName` | Role name copied in, so the log is readable even if the role is later renamed |
| `ModuleKey` / `ModuleLabel` | Which module was affected (e.g. `projects` / "Projects") |
| `SubmoduleKey` / `SubmoduleLabel` | Which submodule (e.g. `health` / "Health") — empty for module-level changes |
| `PermissionKey` | The action key (e.g. `projects.health.edit`) |
| `ActionLabel` | Human label (e.g. "Edit") |
| `ChangeType` | What happened: granted / revoked / reset… |
| `PreviousValue` | Allowed / Denied — before the change |
| `NewValue` | Allowed / Denied — after the change |
| `ChangedById` / `ChangedByName` | Which admin made the change |
| `CreatedAtUtc` | When the change happened |
| `UpdatedAtUtc` / `CreatedBy` / `UpdatedBy` / `DeletedAtUtc` | Standard audit columns |

---

### `clients` — client/customer master data

One row per client company (managed from the Customers module).

| Column | Why it exists |
|---|---|
| `Id` | Primary key (UUID) |
| `Name` | Client company name |
| `Industry` | What sector the client is in |
| `Logo` | Logo reference for the UI |
| `ClientType` | e.g. NEW / OLD client |
| `Status` | Active / inactive / etc. |
| `EngagementManager` | The engagement manager responsible for this client |
| `ContactName` / `ContactPhone` / `ContactEmail` / `ContactDesignation` / `ContactType` | Primary contact person details |
| `contacts` | **JSONB** — additional contacts (flexible list, no separate table needed) |
| `BusinessType` | Type of business |
| `City` / `Country` | Client location |
| `KycDocumentName` | KYC document reference (compliance) |
| `Notes` | Free-text notes |
| `CreatedAtUtc` / `UpdatedAtUtc` / `CreatedBy` / `UpdatedBy` / `DeletedAtUtc` | Standard audit columns |

---

### `client_assignments` — who works on which client

A simple **many-to-many** link table between `users` and `clients` (which users are assigned to which clients).

| Column | Why it exists |
|---|---|
| `ClientId` | FK → `clients.Id` |
| `UserId` | FK → `users.Id` |

Together (`ClientId`, `UserId`) form the primary key — a user can appear on many clients, a client can have many users, but the same pair can't repeat.

---

### `sub_ventures` — sub-companies under a client

One row per sub-company/entity that belongs to a client (a client can have many).

| Column | Why it exists |
|---|---|
| `Id` | Primary key (UUID) |
| `ClientId` | FK → `clients.Id` (which client this belongs to) |
| `Name` | Sub-venture name |
| `contacts` | **JSONB** — contact details for this sub-venture |
| `CreatedAtUtc` / `UpdatedAtUtc` / `CreatedBy` / `UpdatedBy` / `DeletedAtUtc` | Standard audit columns |

---

### `__EFMigrationsHistory` — EF Core bookkeeping (not business data)

Records which database migrations have been applied (currently 6: `InitialIdentity`, `AddUserSecurity`, `AddClientFormDetails`, `SubVentureContactsAndLogo`, `SubVentureTableAndLogoRule`, `RbacRoleManagement`). EF Core uses it to know the schema is up to date. **Do not delete rows from it.**

---

## 3. The `EmployeeManagementDB` database (old prototype — ignore)

Created by a **separate, older employee-management prototype** (different app, different database user `emp_app_user`). **Project Compass never connects to it.**

| Table | What it holds |
|---|---|
| `employees` | Employee master (EmployeeCode, FirstName, LastName, Email, Phone, Department, JobTitle, Status, HireDate, Salary, CreatedAt, UpdatedAt) |
| `users` | Login users for that prototype (Email, PasswordHash, FullName, Role, IsActive) |
| `__EFMigrationsHistory` | Migrations for that prototype |

Because onboarding/offboarding will eventually come from **Keka via API** (not yet available), this old prototype DB is not needed for that either. It's safe to leave alone; if you want, it can be dropped later — but **nothing in the current app depends on it**.

---

## 4. Relationship summary (trackerpro)

```
roles ──< users ──< refresh_tokens
  │            │
  │            └──< client_assignments >── clients ──< sub_ventures
  │
  └──< role_permission_audits
```

- `users.RoleId` → `roles.Id` (every user has one role)
- `refresh_tokens.UserId` → `users.Id` (many sessions per user)
- `client_assignments` = many-to-many between `users` and `clients`
- `sub_ventures.ClientId` → `clients.Id` (a client has many sub-ventures)
- `role_permission_audits.RoleId` → `roles.Id` (change history per role)

---

## 5. Notes / decisions

- **Nothing was deleted or simplified in the database** to write this doc — the user's instruction was to explain, not change. If you later want to drop `EmployeeManagementDB` or remove the duplicate pgAdmin bookmark, both are safe, but they're separate actions.
- Columns like `CreatedAtUtc`, `UpdatedAtUtc`, `CreatedBy`, `UpdatedBy`, `DeletedAtUtc` appear on almost every table — they're the project's standard **audit + soft-delete** convention, applied consistently.
- `jsonb` columns (`roles.Permissions`, `clients.contacts`, `sub_ventures.contacts`) are used on purpose: flexible, nested data without multiplying table count.
