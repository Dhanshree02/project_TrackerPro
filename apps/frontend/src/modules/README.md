# Feature modules (Pulse PMO frontend)

TanStack Router **must** keep route definitions in `src/routes/` (file-based routing). Each route file stays a thin shell: `createFileRoute` + metadata + import from here.

## Layout

```
modules/<feature>/
  index.ts              # public exports for routes and other modules
  pages/                # screen components wired by routes/*.tsx
  components/           # UI used only within this feature
  api/                  # HTTP for this domain (uses @/lib/api-client)
  services/             # optional orchestration (see my-team)
  types/ constants/ utils/
```

## Modules (complete)

| Module | Routes | Notes |
|--------|--------|--------|
| `dashboard` | `/` | MIS charts + `api/dashboard` |
| `repository` | `/repository` | includes document viewer |
| `settings` | `/settings*`, masters UI | `masters/` store + catalog sections |
| `employees` | `/employee-directory*`, `/exit-summary`, `/resources*` redirects | form modal, bulk upload |
| `customers` | `/customers*` | KYC modal, detail loader |
| `projects` | `/projects*` | onboarding, detail loader, WBS preview |
| `timesheets` | `/my-team/timesheets` | |
| `action-centre` | `/action-centre` | |
| `health` | `/health-*` | |
| `my-team` | `/my-team` | calendar (pre-existing) |

Shared shell (`app-shell`, `app-sidebar`, `ui/*`) stays in `src/components/`. Cross-cutting `lib/api/catalogs.ts` and `lib/api/users.ts` stay in `lib/api` (master/auth catalogs used by many modules).
