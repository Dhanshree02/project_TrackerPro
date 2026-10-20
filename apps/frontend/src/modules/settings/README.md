# Settings (frontend only — backend TBD)

Pulse PMO **Settings** is implemented as a **frontend feature module** only. Routes:

- `/settings` — hub
- `/settings-masters` — project / customer / resource master UIs
- `/settings-security-roles` — roles matrix & user access (uses existing `/api/v1/rbac/*` until Settings API is defined)

## Current behavior

- **Masters screens** mix read-only catalog data (`GET /api/v1/catalogs/*`), local store state (`masters/`), and placeholder add/edit flows. There is **no** dedicated `/api/settings` backend module yet.
- **Do not** add new backend endpoints or migrations for Settings until product spec is agreed. Wire new APIs here when that lands.
- Shared read catalogs used across the app stay in `@/lib/api/catalogs.ts` (not under this module).

## Project masters (DB-backed)

- **Read:** `GET /api/v1/catalogs/service-hierarchy` (project onboarding + catalog store), `GET /api/v1/catalogs/project-masters` (flat list for Settings table).
- **Write:** `POST/PUT/DELETE /api/v1/catalogs/project-masters`, plus `POST service-groups`, `POST service-departments`, `POST project-masters/service-only`. Permission: `settings.masters.manage`.
- Data lives in `master.mst_service_groups` → `mst_service_departments` → `mst_service_sub_departments` → `mst_service_catalog` (tools, duration days, unit price).

## Out of scope (removed / not started)

- Root `SETTINGS_*` implementation guides (deleted from repo).
- Provisional address-cities POST/DELETE — removed; Resource Masters UI pending new API.
