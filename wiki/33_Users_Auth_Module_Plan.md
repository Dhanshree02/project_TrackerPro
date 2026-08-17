# Users & Auth Module — Completion Plan

> **Status:** ✅ Complete (backend + frontend + DB)  \
> **Date:** 2026-08-07  \
> **Stack:** ASP.NET Core 10 + PostgreSQL 16

---

## 1. Scope

Real authentication and user administration: the frontend role-switcher placeholder is
replaced by a secure login, and admins can manage users, roles, and access. This is the
security backbone every later module builds on.

```
Login page → POST /auth/login → JWT (access + rotating refresh) → /auth/me → app
Admin    → /users → user CRUD, role change, reset password, activate/deactivate
```

---

## 2. What is DONE ✅

### Backend
| Piece | Location |
|-------|----------|
| Account lockout (5 failures → 15 min lock) + `LastLoginAtUtc` tracking | `AuthService` + `User` entity (`AddUserSecurity` migration) |
| Brute-force rate limiting on `/auth/login` (10/15 min per IP) | `LoginRateLimiter` (in-memory; Redis later) |
| `PUT /auth/change-password` — verifies current, enforces strength, revokes all sessions | `AuthService.ChangePasswordAsync` |
| `MustChangePassword` flag on profile + reset path | `AuthService` / `UserService` |
| Users API — list/search/role-filter, get, create, update, reset-password | `UsersController` + `UserService` |
| Roles API — `GET /roles` with permission sets | `RolesController` |
| Business errors → proper HTTP codes: 401 / 403 / 404 / 409 / 429 / 400 | `BusinessExceptions` + `ExceptionHandlingMiddleware` + `ValidationFilter` |
| FluentValidation enforced on every action (global filter) | `ValidationFilter` |
| Role change / password reset revoke active sessions immediately | `UserService` |
| **Self-guard:** admins cannot deactivate or demote their own account (no self-service recovery ⇒ permanent-lockout protection) | `UserService.UpdateUserAsync` |
| **Last-admin guard:** the `users:manage` capability can never drop to zero — deactivating/demoting the last active user manager is rejected with 403 | `UserService.IsLastUserManagerAsync` |
| Seed: 12 roles with permission sets, 14 users (BCrypt per-user salt) | `DbSeeder` |

### API contract (new)
| Method | Endpoint | Permission |
|--------|----------|-----------|
| POST | `/api/v1/auth/login` | anonymous (rate-limited) |
| POST | `/api/v1/auth/refresh` | anonymous |
| PUT | `/api/v1/auth/change-password` | authenticated |
| POST | `/api/v1/auth/logout` | authenticated |
| GET | `/api/v1/auth/me` | authenticated |
| GET/POST | `/api/v1/users`, `/api/v1/users/{id}` | `users:manage` (PMO, Dhanshree) |
| PUT | `/api/v1/users/{id}`, `/api/v1/users/{id}/reset-password` | `users:manage` |
| GET | `/api/v1/roles` | `users:manage` |

### Frontend
| Piece | Location |
|-------|----------|
| Login page (`/login`) — real credentials, error handling, demo hint | `routes/login.tsx` |
| `AuthProvider` — session restore on boot, login/logout | `lib/auth-context.tsx` |
| Session persistence — refresh token in localStorage, access token in memory | `lib/api-client.ts` |
| Single-flight refresh — prevents the reuse-detection race on concurrent loads | `lib/api-client.ts` |
| Refresh-race guard — logout while a refresh is in flight cannot resurrect the session | `lib/api-client.ts` |
| Bodyless (204) responses handled — no more `reading 'data' of null` on change-password | `lib/api-client.ts` |
| **Force-password-change screen** (`/change-password`) — every `AppShell` page redirects here while `mustChangePassword=true`; after change the flag clears and the app unlocks | `routes/change-password.tsx` + `components/app-shell.tsx` |
| Auth gate — every `AppShell` page redirects to `/login` when unauthenticated | `components/app-shell.tsx` |
| Role initialized from the authenticated user's backend role | `lib/role-context.tsx` |
| Sign-out button + real user avatar in the topbar | `components/app-topbar.tsx` |
| Users admin page — search, role filter, create modal, role change, activate/deactivate, reset password | `routes/users.tsx` + `lib/api/users.ts` |
| Sidebar "Users & Access" entry (Dhanshree + PMO) | `components/app-sidebar.tsx` |

### Verified end-to-end (live)
- Login → dashboard as **Dhanshree** (real profile, real avatar) ✅
- Session survives reload (refresh rotation) ✅
- `/customers` loads the 10 API-seeded clients ✅
- `/users` lists users, shows last-login, change-pw badges ✅
- Lockout: 5 wrong passwords → "Account locked. Try again in 15 minute(s)." ✅
- Admin reset unlocks the account; password change revokes old sessions ✅
- Non-admin (Employee) gets 403 on `/users`; duplicate email → 409; validation → 400 ✅

---

## 3. Security decisions & known trade-offs

| Decision | Note |
|----------|------|
| Refresh token in `localStorage` | XSS-exposed by design (mitigated by rotation + 7-day expiry + family revocation). **Production hardening:** move to an httpOnly `SameSite=Strict` cookie. |
| Access token in memory only | Survives page reload via refresh token; XSS cannot read it. |
| In-memory rate limiter | Fine for single instance; swap to Redis when scaling horizontally. |
| Backend role → frontend role mapping | The frontend implements 6 role views; the other 6 backend roles map to a conservative view. Backend still enforces real permissions. |
| Lockout is per-account (DB), rate limit is per-IP (memory) | Two independent brute-force layers. |

---

## 4. What remains (next module candidates)

1. **Projects module** — client detail already expects `GET /clients/{id}/projects`; project lifecycle, stages, prerequisites.
2. ~~**Force-password-change UI**~~ — **done** (see `routes/change-password.tsx`).
3. **Login hardening extras** — login audit events, 2FA/TOTP, security headers middleware, httpOnly-cookie token transport.
4. **Notification module** — welcome emails, password-reset emails.

## Related
- [[31_Backend_Plan_DotNet]] — architecture & roadmap
- [[32_Client_Module_Plan]] — client module (completed earlier)
- [[23_Security_and_RBAC]] — permission model
