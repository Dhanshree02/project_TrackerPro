# Merge Context: Commit 7e831e3

- **Commit Hash:** `7e831e3aacb04e0e713cb7f340391d7ca525d073`
- **Branch:** `uat_clean`
- **Author:** Omkar Gaikwad
- **Commit Title:** `feat(uat_clean): persist the access catalog, extensions, and escalations`

---

## 🎯 Purpose of This Commit
Introduced database persistence for the access catalog (modules, submodules, widgets, tabs), created the initial **Roles & Permissions** settings page in the frontend, and added project extension requests & service escalations.

---

## 🟢 Features to MERGE (Safe & Intended)

### 1. Roles & Permissions (Frontend)
- **New Page**: `apps/frontend/src/modules/settings/pages/roles-permissions-page.tsx`
  - Allows selecting an active RBAC role from `auth.tbl_roles`.
  - Displays hierarchical tree: Modules -> Submodules -> Widgets -> Tabs.
  - Interactive radio buttons for **Only view** and **View + Manage**.
- **Route**: `apps/frontend/src/routes/settings-security-roles.tsx` registered at `/settings-security-roles`.
- **API Client**: `fetchSidebarModules()` in `apps/frontend/src/lib/api/catalogs.ts` calling `/api/v1/catalogs/modules`.

### 2. Access Catalog Master Tables (Backend & DB)
- **Database Tables**:
  - `master.mst_modules`: Sidebar parent modules (`dashboard`, `projects`, `resources`, `settings`, etc.).
  - `master.mst_submodules`: Child pages under modules (e.g. `employee-directory`, `master`, `roles-permissions`).
  - `master.mst_widgets`: Granular dashboard cards/widgets (e.g. `team-resignation-count`, `team-utilization`).
  - `master.mst_tabs`: Page tab bars (e.g. `alerts`, `approvals`, `all-employees`, `my-reportees`).
- **Catalog Seeder**: `apps/backend/Infrastructure/Persistence/Seeding/ModuleCatalogSync.cs` keeps DB catalog synced.
- **API Endpoint**: `GET /api/v1/catalogs/modules` returning hierarchical DTO tree.

### 3. Project Extensions & Service Escalations
- **Backend Models & Controllers**:
  - `ProjectExtensionRequest` & `ProjectServiceEscalation` in `apps/backend/Modules/Projects/`.
- **Frontend Integration**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx` tabs for extensions and escalations.

---

## 🔴 Features to Leave UNTOUCHED / DO NOT Overwrite
- **Existing User/Auth Flow**: Do not touch `apps/backend/Modules/Auth/Services/TokenService.cs` or baseline password hashing.
- **Database Migrations on Target Branch**: If merging into a branch that already has different migration hashes, do not blindly overwrite `AppDbContextModelSnapshot.cs`; run an EF Core reconciliation instead.
- **Local SQLite / dev configs**: Keep target branch `.env` and `appsettings.Development.json` connection strings untouched.

---

## 📁 File Structure Rule for `GIT_Merge`
- Latest commit documentation file lives in `GIT_Merge/`.
- Prior commit documentation files must be moved into `GIT_Merge/archive/`.
