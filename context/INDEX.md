# TrackerPro PMS — Master Context & Fast-Recall Index

> **Purpose:** This directory serves as the centralized knowledge repository for the TrackerPro PMS codebase. Any agent or developer can immediately reference these documents to recall architecture, RBAC mappings, database schemas, and module business logic without performing expensive whole-repo scans.

---

## ⚡ Quick Navigation

| Domain | File Path | Summary |
|---|---|---|
| **Master RBAC Architecture** | [`context/rbac/RBAC_ARCHITECTURE.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/rbac/RBAC_ARCHITECTURE.md) | End-to-end RBAC design: frontend provider, backend `[RequireRbac]` attribute, Redis/Memory cache, role resolution. |
| **Catalog Codes & GUIDs** | [`context/rbac/CATALOG_CODES_AND_IDS.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/rbac/CATALOG_CODES_AND_IDS.md) | Canonical lookup table mapping string codes to DB UUIDs across modules, submodules, tabs, and widgets. |
| **Permission Rules & Constraints** | [`context/rbac/PERMISSION_RULES.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/rbac/PERMISSION_RULES.md) | Inheritance rules, default fallback policy for unconfigured roles, view-only rows, and peer protection constraints. |
| **Roles & Demo Personas** | [`context/rbac/ROLES_AND_PERSONAS.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/rbac/ROLES_AND_PERSONAS.md) | Inventory of all 29 system roles, demo switcher personas, and authentication bypass headers. |
| **Team Dashboard** | [`context/modules/TEAM_DASHBOARD.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/modules/TEAM_DASHBOARD.md) | 3 Rosters (`My Team`, `My Reportees`, `All Employees`), peer view-only restrictions, calendar & shift APIs. |
| **Action Center** | [`context/modules/ACTION_CENTER.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/modules/ACTION_CENTER.md) | 4 Tabs (`Bucket List`, `Approvals`, `Alerts`, `Notifications`), view vs manage gating, Actions column rules. |
| **Projects & Health** | [`context/modules/PROJECTS.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/modules/PROJECTS.md) | Project directory, WBS, Team, Health, Invoices, central approvals, budget & role breakdowns. |
| **Timesheets** | [`context/modules/TIMESHEETS.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/modules/TIMESHEETS.md) | My Timesheet, Timesheet History, Timesheet Approval, daily 8h/24h caps, approval workflows. |
| **Customers** | [`context/modules/CUSTOMERS.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/modules/CUSTOMERS.md) | Customer directory, sub-ventures, contacts, KYC documents, SPOC management. |
| **Resources & Directory** | [`context/modules/RESOURCES.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/modules/RESOURCES.md) | Employee directory, 6 detail tabs, exit summary, onboarding & offboarding workflows. |
| **Dashboard** | [`context/modules/DASHBOARD.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/modules/DASHBOARD.md) | 8 KPI widgets, onsite/offsite utilization, boarding trends, capacity charts. |
| **Settings & Masters** | [`context/modules/SETTINGS.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/modules/SETTINGS.md) | Resource masters, project masters, leave calendar, and the Roles & Permissions administration matrix. |
| **Database Schema** | [`context/database/SCHEMA_OVERVIEW.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/database/SCHEMA_OVERVIEW.md) | PostgreSQL schemas (`master`, `auth`, `project`, `resource`, `action`, `timesheet`). |
| **Catalog Tables** | [`context/database/CATALOG_TABLES.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/database/CATALOG_TABLES.md) | Structure of `mst_modules`, `mst_submodules`, `mst_tabs`, `mst_widgets`, and foreign keys. |
| **Docker & Runtime Ports** | [`context/environment/DOCKER_AND_PORTS.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/environment/DOCKER_AND_PORTS.md) | Container names, mapped ports, db credentials, hot reload & container build commands. |

---

## 🎯 High-Frequency Quick Reference

### 1. Active Docker Services
- **Database:** `pms_uat_db` (Postgres 16 Alpine) -> Port `41763` (External) / `5432` (Internal) -> DB: `pms_uat_clean`, User: `postgres`, Pass: `postgres`.
- **Backend (.NET 10 API):** `pms_uat_clean_backend` -> Port `52815` (External) / `8080` (Internal).
- **Frontend (React 19 / TanStack):** `pms_uat_clean_frontend` -> Port `39107` (External) / `3000` (Internal).
- **PgAdmin:** `pms_pgadmin` -> Port `46382`.

### 2. Critical Top-Level Module UUIDs
- **Dashboard:** `471bc977-be2e-449d-91e7-5c11cb9c4ec0` (`dashboard`)
- **Action Center:** `5a049953-8170-4ef4-a59e-43dc19e12de5` (`action-centre`)
- **Projects:** `168b1296-de6a-4f9e-a3b9-617b83863736` (`projects`)
- **Resources:** `715f79ce-51ea-46d3-b95d-8318840f90a6` (`resources`)
- **Customer:** `4e57fd71-b53e-43c0-862e-5698e09c0922` (`customers`)
- **Repository:** `c04c546e-0f2c-448d-b634-5d517843d365` (`repository`)
- **My Team:** `6055ce3c-b466-4354-ba9a-b4c309111e9d` (`my-team`)
- **Settings:** `fcb69b3e-e5aa-49bb-921f-7793f0a8c90d` (`settings`)

### 3. Submodule & Key Tab UUIDs
- **Team Dashboard:** Submodule `9854b7f3-8e7e-4ecb-864f-f2533ff295f9`
  - `My Team`: Tab `9854b7f3-0001-4000-8000-000000000001` (Code: `my-team` / `my-team-tab`, Sort: 5, strictly view-only)
  - `My Reportees`: Tab `b1e81c2a-34de-4dd4-b1f3-47387b8ed52b` (Code: `my-reportees`, Sort: 10)
  - `All Employees`: Tab `552f9f86-4eb0-473a-8e39-9863cfefcea4` (Code: `all-employees`, Sort: 20)
- **Action Center:** Module `5a049953-8170-4ef4-a59e-43dc19e12de5`
  - `Bucket List`: Tab `db9aa2d2-1876-4d81-9ff6-6b55be19fb7a` (Code: `bucket-list`, Sort: 10)
  - `Approvals`: Tab `a7bd6c40-4e96-4abb-be93-4ed4e4211978` (Code: `approvals`, Sort: 20)
  - `Alerts`: Tab `5b828ae3-0b45-4a1c-a1cb-78b29e882cf3` (Code: `alerts`, Sort: 30)
  - `Notifications`: Tab `69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc` (Code: `notifications`, Sort: 40)
- **Timesheets:** Submodule `d67426d3-05df-4608-b8cf-c0ecfe698dc3`
  - `My Timesheet`: Tab `d67426d3-0001-4000-8000-000000000001`
  - `Timesheet History`: Tab `d67426d3-0001-4000-8000-000000000002`
  - `Timesheet Approval`: Tab `d67426d3-0001-4000-8000-000000000003`

### 4. Golden Rules for Agents
1. **Never grep/scan the entire `apps/` tree blindly** — consult [`context/INDEX.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/INDEX.md) and [`context/rbac/CATALOG_CODES_AND_IDS.md`](file:///Users/omkargaikwad/Downloads/Talakunchi_AI_PMS/PMS_uat_clean/context/rbac/CATALOG_CODES_AND_IDS.md) first.
2. **Synchronize DB and Catalog Codes** — Whenever adding a tab or submodule, update:
   - PostgreSQL (`master.mst_tabs` or `master.mst_submodules`)
   - `apps/backend/Infrastructure/Authorization/RbacCatalogCodes.cs`
   - `apps/frontend/src/lib/permissions.tsx`
   - SQL dumps: `database/pms_uat.sql` and `database/trackerpro-uat.sql`
3. **Peer Data Isolation** — In Team Dashboard, peer employees can only view each other's schedules and shifts. All editing/management controls are strictly disabled on the "My Team" roster.

