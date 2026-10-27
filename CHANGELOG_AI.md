# AI-Assisted Development Changelog (`CHANGELOG_AI.md`)

This file tracks all significant modifications made by AI assistants across the repository (Frontend, Backend, Database schema/migrations, APIs, business logic, configuration, and bug fixes). Its purpose is to maintain a clear audit trail, aid pre-merge reviews, and prevent accidental regression or loss of functionality during branch merges.

---

## Change Log Template

Whenever a new feature, bug fix, or refactor is performed by AI, append an entry following this format:

```markdown
### [YYYY-MM-DD] <Feature or Task Title>

- **Branch**: `<branch-name>`
- **Purpose**: Brief description of the objective and requirements.

#### 📁 Files Affected
- **Created**: `path/to/file`
- **Modified**: `path/to/file`
- **Deleted**: `path/to/file`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**: e.g., `schema.table_name` (added `ColumnName`, etc.)
- **Migrations**: New or executed migration files, raw scripts applied.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**: Added, modified, or removed API routes.
- **Business Logic**: Key service/logic changes or behavioral alterations.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Explicit notes on functionality, shared contracts, or interfaces that must not be broken.
```

---

## 🚀 Pre-Merge Summary: `sahil-action-backend`

- **Branch**: `sahil-action-backend`
- **Base / Target**: `uat_clean` (fast-forwarded from `origin/uat_clean` at `7e831e3`)
- **Primary Modules Touched**: Projects (WBS Services, Task Hierarchy, Service Prerequisite Tracking, Invoice Scheduling, Subtotal & Grand Total rollups)
- **Status**: Tested, verified, dev servers running, zero build errors.

### Complete Inventory of Files Changed in this Branch

| Category | File Path | Status | Summary of Changes |
| :--- | :--- | :--- | :--- |
| **Backend - Entity Models** | `apps/backend/Modules/Projects/Models/ProjectServiceEntity.cs` | Modified | Added `ChangeStatus`, `OriginalQty`, `PendingQty`, `PendingResourceLevel`, `PendingUnitPrice`, `ModCollectionStatus`, `ModValidationStatus`, `ModBillingStatus`, `ModIsReady`. |
| **Backend - Entity Models** | `apps/backend/Modules/Projects/Models/ProjectInvoice.cs` | Modified | Added `ProjectServiceId` foreign key and `ProjectService` navigation property. |
| **Backend - EF Core Configurations** | `apps/backend/Infrastructure/Persistence/Configurations/ProjectServiceConfiguration.cs` | Modified | Mapped change status and modification columns to PostgreSQL `project.tbl_project_services`. |
| **Backend - EF Core Configurations** | `apps/backend/Infrastructure/Persistence/Configurations/ProjectInvoiceConfiguration.cs` | Modified | Mapped `ProjectServiceId`, created index and foreign key with `SetNull` delete behavior. |
| **Backend - DTOs** | `apps/backend/Modules/Projects/DTOs/ProjectServiceDtos.cs` | Modified | Added modification fields, `GenerateInvoices`, and `ServiceModificationImpactDto`. |
| **Backend - DTOs** | `apps/backend/Modules/Projects/DTOs/ProjectInvoiceDtos.cs` | Modified | Added `ProjectServiceId`, `DeletedAtUtc`, `IsDeleted` to invoice DTOs and requests. |
| **Backend - DTOs** | `apps/backend/Modules/Projects/DTOs/ProjectTaskDtos.cs` | Modified | Added `DeletedAtUtc` and `IsDeleted` to `ProjectTaskDto`. |
| **Backend - App Services** | `apps/backend/Modules/Projects/Services/IProjectAppService.cs` | Modified | Contract updates for service modifications, soft deletes, invoice inclusion, impact check. |
| **Backend - App Services** | `apps/backend/Modules/Projects/Services/ProjectAppService.cs` | Modified | Implemented `AddProjectServiceAsync` (with invoice schedule generation by frequency), `UpdateProjectServiceAsync` (consecutive modifications `1 ➔ 4 ➔ 2`), `ApplyServiceModificationAsync`, soft-deletion cascades for services & invoices, subtotal & rollup recalculations. |
| **Backend - Task Services** | `apps/backend/Modules/Projects/Services/IProjectTaskService.cs` | Modified | Added `GetModificationImpactAsync` and `DeactivateExcessTaskBranchesAsync`. |
| **Backend - Task Services** | `apps/backend/Modules/Projects/Services/ProjectTaskService.cs` | Modified | Added branch deactivation logic for downward modifications and idempotent AP branch generation for upward modifications. |
| **Backend - Controllers** | `apps/backend/Modules/Projects/Controllers/ProjectsController.cs` | Modified | Added `includeDeleted` query parameter to `/services`, `/tasks`, and `/invoices`; added `/modification-impact` and `/apply-modification` endpoints. |
| **Backend - Middleware & Exceptions** | `apps/backend/Shared/Exceptions/BusinessExceptions.cs` | Modified | Added `BadRequestException`. |
| **Backend - Middleware & Exceptions** | `apps/backend/Middleware/ExceptionHandlingMiddleware.cs` | Modified | Mapped `BadRequestException` to HTTP 400. |
| **Backend - Configuration** | `apps/backend/appsettings.Development.json` | Modified | Set local development connection string `trackerpro`. |
| **Frontend - API & Domain** | `apps/frontend/src/lib/domain-models.ts` | Modified | Added change management fields to `WbsService` domain model. |
| **Frontend - API & Domain** | `apps/frontend/src/modules/projects/api/projects.ts` | Modified | Added API functions, payloads, and mappers for service modifications, impact checks, invoices, and `includeDeleted` flags. |
| **Frontend - UI Components** | `apps/frontend/src/modules/projects/components/edit-services-modal.tsx` | Created | Full 24-column modal for Section A service management, inline drawer for consecutive modifications, impact checking, and sticky Actions column. |
| **Frontend - Pages** | `apps/frontend/src/modules/projects/pages/project-detail-page.tsx` | Modified | WBS tab integration, persistent status badges (`Newly Added`, `Modified`), dynamic prerequisite rows, invoice schedule with `Service Name`, dynamic subtotal and tax percentage recalculations. |
| **Frontend - Pages** | `apps/frontend/src/modules/projects/pages/project-onboarding-page.tsx` | Modified | Explicitly set `generateInvoices: false` on onboarding submission to preserve custom milestone scheduling. |
| **Frontend - Generated Routes** | `apps/frontend/src/routeTree.gen.ts` | Modified | Route tree synchronization. |
| **Rules & Documentation** | `.cursor/rules/current-work.mdc` | Modified | Synchronized working branch notes and status. |
| **Rules & Documentation** | `CHANGELOG_AI.md` | Created | Complete change log and pre-merge audit trail. |

### Database Schema Alterations Applied

1. **`project.tbl_project_services`**:
   - `"ChangeStatus" character varying(50) NOT NULL DEFAULT 'Active'`
   - `"OriginalQty" integer NULL`
   - `"PendingQty" integer NULL`
   - `"PendingResourceLevel" character varying(500) NULL`
   - `"PendingUnitPrice" numeric(18,2) NULL`
   - `"ModCollectionStatus" character varying(50) NULL`
   - `"ModValidationStatus" character varying(50) NULL`
   - `"ModBillingStatus" character varying(50) NULL`
   - `"ModIsReady" boolean NULL`

2. **`project.tbl_project_invoices`**:
   - `"ProjectServiceId" uuid NULL`
   - Index `"IX_tbl_project_invoices_ProjectServiceId"` ON `project.tbl_project_invoices ("ProjectServiceId")`
   - Foreign key constraint `"FK_tbl_project_invoices_tbl_project_services_ProjectServiceId"` (`ON DELETE SET NULL`)
   - Data backfill: Backfilled `"ServiceName"` and `"ProjectServiceId"` for existing rows.

---

## Log Entries

### [2026-10-22] Branch Setup & UAT Database Migration to `10.50.30.152`

- **Branch**: `sahil-action-backend` (created from `origin/uat_clean` at commit `6f05e90`)
- **Purpose**: Create dedicated feature branch `sahil-action-backend`, sync with remote `origin/uat_clean`, switch database connection to active UAT host `10.50.30.152:41763/pms_uat_clean`, and verify end-to-end backend and frontend dev server startup.

#### 📁 Files Affected
- **Created**:
  - `CHANGELOG_AI.md` (AI change tracking ledger)
- **Modified**:
  - `.env` (updated `ConnectionStrings__DefaultConnection` host from `10.50.30.158` / `localhost` to `10.50.30.152:41763`, target database `pms_uat_clean`)
  - `apps/backend/appsettings.Development.json` (updated `ConnectionStrings:DefaultConnection` to `Host=10.50.30.152;Port=41763;Database=pms_uat_clean`)
  - `apps/frontend/src/routeTree.gen.ts` (regenerated routes by TanStack router on dev server boot)

#### 🗄️ Database & Schema Changes
- **Database Target**: `pms_uat_clean` on `10.50.30.152:41763` (PostgreSQL 16/18)
- **Tables / Columns Adjusted**:
  - `master.mst_org_role_map`: Added column `"SubDepartment" character varying(250)` to align with EF Core model entity mapping in `MstOrgRoleMap.cs` while preserving existing `SubDepartmentId` column.
  - `resource.tbl_onfloorrole_subdepartment`: Created updatable view pointing to `master.mst_onfloorrole_sub_departments` to satisfy EF Core table configuration `OnFloorRoleSubDepartmentConfiguration` mapped to `resource.tbl_onfloorrole_subdepartment`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**: None modified in this setup session.
- **Business Logic**: Startup lifecycle in `OrgRoleMatrixHostedService` executed successfully without crashing on baseline seeding and sub-department link synchronization.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Database Connection**: Must stay configured for `Host=10.50.30.152;Port=41763;Database=pms_uat_clean`.
- **Org Role Mapping Entity**: `MstOrgRoleMap` entity and `master.mst_org_role_map` schema compatibility requires both `SubDepartment` and `SubDepartmentId` columns.
- **On-Floor Sub-Department View**: Keep `resource.tbl_onfloorrole_subdepartment` view synchronized with `master.mst_onfloorrole_sub_departments`.
- **Ports In Use**:
  - Frontend: `http://localhost:3000` (proxies `/api` to port 5194)
  - Backend: `http://localhost:5194`

---

### [2026-10-23] Switch to Local PostgreSQL Database (`trackerpro`) & Runtime Execution

- **Branch**: `sahil-action-backend`
- **Purpose**: Connect the project backend to the local PostgreSQL database (`trackerpro` on `localhost:5432`) as requested by the user, and start both the ASP.NET Core backend and Vite frontend services.

#### 📁 Files Affected
- **Modified**:
  - `.env` (configured active `ConnectionStrings__DefaultConnection` for `Host=localhost;Port=5432;Database=trackerpro;Username=trackerpro;Password=trackerpro_dev`)
  - `apps/backend/appsettings.Development.json` (configured active `ConnectionStrings:DefaultConnection` for `Host=localhost;Port=5432;Database=trackerpro;Username=trackerpro;Password=trackerpro_dev`)
  - `CHANGELOG_AI.md` (recorded change entry)

#### 🗄️ Database & Schema Changes
- **Database Target**: `trackerpro` on `localhost:5432` (PostgreSQL 18)
- **Tables / Columns Verified**:
  - Verified `master.mst_org_role_map` contains `"SubDepartment"` column.
  - Verified `resource.tbl_onfloorrole_subdepartment` view exists.
  - No new schema modifications or migrations required.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**: None modified.
- **Business Logic**: Verified full startup flow (`OrgRoleMatrixHostedService`, RBAC mappings) against local `trackerpro` instance.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Database Connection**: Currently using local database `Host=localhost;Port=5432;Database=trackerpro;Username=trackerpro;Password=trackerpro_dev`.
- **Ports In Use**:
  - Frontend: `http://localhost:3000`
  - Backend: `http://localhost:5194`

---

### [2026-10-23] WBS Service Change Management — Add, Modify, and Soft Delete Services

- **Branch**: `sahil-action-backend`
- **Purpose**: Implement full lifecycle Service Change Management for the Project Details page (`/projects/$projectId`), covering:
  1. **Services & Deliverables from WBS**: Added "Edit Services" modal action and status badges (`Newly Added`, `Modification Pending`, `Deleted`), with an optional toggle for viewing inactive/deleted services.
  2. **Service-wise Prerequisite Tracking**: Support newly added services (checks must pass before "Ready to Start") and pending modifications (linked modification prerequisite sub-row with approval workflow), while excluding deleted services.
  3. **Tasks Hierarchy**: Prevent immediate task generation upon adding or modifying services; generate tasks only when prerequisite criteria pass and "Ready to Start" is triggered; for quantity increases (e.g., 2 -> 3), idempotently create only additional branches (e.g. AP3) without altering or resetting existing tasks, stages, timers, or assignments; for quantity decreases, perform impact analysis on assigned tasks and utilized hours, safely soft-deleting excess AP branches; for service deletion, perform soft-deletion across service and related task branches.

#### 📁 Files Affected
- **Created**:
  - `apps/frontend/src/modules/projects/components/edit-services-modal.tsx`: Reusable drawer/modal for managing project services (add new service via catalog hierarchy, modify quantity & resource-level distribution, soft delete with impact confirmation, review pending batch changes before saving).
- **Modified**:
  - `apps/backend/Modules/Projects/Models/ProjectServiceEntity.cs`: Added properties `ChangeStatus`, `OriginalQty`, `PendingQty`, `PendingResourceLevel`, `PendingUnitPrice`, `ModCollectionStatus`, `ModValidationStatus`, `ModBillingStatus`, `ModIsReady`.
  - `apps/backend/Infrastructure/Persistence/Configurations/ProjectServiceConfiguration.cs`: Mapped new columns with PascalCase quoted identifiers.
  - `apps/backend/Modules/Projects/DTOs/ProjectServiceDtos.cs`: Updated DTOs `ProjectServiceDto`, `UpdateServicePrerequisiteRequest`, `UpdateProjectServiceRequest`, and added `ServiceModificationImpactDto`.
  - `apps/backend/Modules/Projects/DTOs/ProjectTaskDtos.cs`: Added `DeletedAtUtc` and `IsDeleted` flags to `ProjectTaskDto`.
  - `apps/backend/Shared/Exceptions/BusinessExceptions.cs`: Added `BadRequestException`.
  - `apps/backend/Middleware/ExceptionHandlingMiddleware.cs`: Mapped `BadRequestException` to HTTP 400 Bad Request.
  - `apps/backend/Modules/Projects/Services/IProjectTaskService.cs` & `ProjectTaskService.cs`:
    - Updated `GenerateMissingTasksAsync` to generate tasks exclusively for active, ready services (`s.IsReady && s.DeletedAtUtc == null`).
    - Added `GetModificationImpactAsync(projectId, serviceId, targetQty)`: Checks AP branches beyond `targetQty` for assigned tasks, logged hours, and completed work.
    - Added `DeactivateExcessTaskBranchesAsync(projectId, serviceId, keepQty)`: Soft-deletes excess AP branches while retaining audit history.
  - `apps/backend/Modules/Projects/Services/IProjectAppService.cs` & `ProjectAppService.cs`:
    - Injected `IProjectTaskService`.
    - Added `includeDeleted` support to `GetProjectServicesAsync` and `GetProjectTasksAsync` using EF Core `.IgnoreQueryFilters()`.
    - Updated `AddProjectServiceAsync`: Sets `ChangeStatus = "Newly Added"` and `IsReady = false`, without prematurely generating tasks.
    - Updated `UpdateProjectServiceAsync`: Supports `AsPendingModification = true`, staging changes under `ChangeStatus = "Modification Pending"`.
    - Updated `UpdateServicePrerequisiteAsync`: Supports prerequisite state transitions for both new additions and pending modifications, triggering `GenerateMissingTasksAsync` upon `IsReady = true`.
    - Added `ApplyServiceModificationAsync`: Applies approved pending configuration to the service, and coordinates task branch additions or safe deactivation.
    - Added `GetServiceModificationImpactAsync`: Exposes impact metrics for quantity reductions.
    - Updated `DeleteProjectServiceAsync`: Soft-deletes service and child task branches.
  - `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`:
    - Added query parameter `includeDeleted` to `GET /services` and `GET /tasks`.
    - Added `GET /services/{serviceId}/modification-impact?targetQty={n}`.
    - Added `POST /services/{serviceId}/apply-modification`.
  - `apps/frontend/src/modules/projects/api/projects.ts`: Updated API interfaces, payloads, mappers, and added API client functions (`fetchServiceModificationImpact`, `applyServiceModification`, `includeDeleted` flags).
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Added "Edit Services" trigger button and "Show Inactive/Deleted" toggle in `WbsTab`.
    - Added status badges (`Newly Added`, `Modification Pending`, `Deleted`) to WBS Services table.
    - Updated `WbsPrerequisiteSection` to display pending modifications as nested sub-rows with review/approval controls and "Ready to Apply" action.
    - Inactive and deleted services excluded from active prerequisite workflows and progress metrics.
    - Fixed missing component imports (`Button`, `Badge`, `Edit2`) in WbsTab.
  - `apps/frontend/src/lib/domain-models.ts`:
    - Added change management optional fields to `WbsService` interface.
  - `CHANGELOG_AI.md`: Recorded change log entry.

#### 🗄️ Database & Schema Changes
- **Table**: `project.tbl_project_services`
- **Columns Added**:
  - `"ChangeStatus" character varying(50) NOT NULL DEFAULT 'Active'`
  - `"OriginalQty" integer NULL`
  - `"PendingQty" integer NULL`
  - `"PendingResourceLevel" character varying(500) NULL`
  - `"PendingUnitPrice" numeric(18,2) NULL`
  - `"ModCollectionStatus" character varying(50) NULL`
  - `"ModValidationStatus" character varying(50) NULL`
  - `"ModBillingStatus" character varying(50) NULL`
  - `"ModIsReady" boolean NULL`

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/projects/{projectId}/services?includeDeleted={bool}`: Returns active services or both active + soft-deleted services.
  - `GET /api/v1/projects/{projectId}/tasks?includeDeleted={bool}`: Returns active tasks or both active + soft-deleted tasks.
  - `POST /api/v1/projects/{projectId}/services`: Adds new service with `ChangeStatus = 'Newly Added'`, `IsReady = false`.
  - `PUT /api/v1/projects/{projectId}/services/{serviceId}`: With `asPendingModification = true`, stages pending quantity/resource levels without altering active tasks.
  - `PATCH /api/v1/projects/{projectId}/services/{serviceId}/prerequisite`: Updates baseline or modification prerequisite statuses; activates tasks on `IsReady = true`.
  - `GET /api/v1/projects/{projectId}/services/{serviceId}/modification-impact?targetQty={n}`: Inspects excess AP branches for assigned members, hours logged, and completion state.
  - `POST /api/v1/projects/{projectId}/services/{serviceId}/apply-modification`: Approves pending modification and applies incremental branch changes.
  - `DELETE /api/v1/projects/{projectId}/services/{serviceId}`: Performs soft-delete on service and child tasks (`DeletedAtUtc = now()`).
- **Business Logic**:
  - Idempotent task generation preserves all existing task IDs, stages, assigned resources, timesheets, and timer records.
  - Zero premature task generation prior to prerequisite sign-off.
  - Downward quantity reductions inspect branch impact and require explicit user confirmation.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Database Schema**: Column names in `project.tbl_project_services` must remain quoted PascalCase (e.g. `"ChangeStatus"`) to match Npgsql EF Core mappings.
- **Project Onboarding Form (`/projects/new`)**: Left completely intact; uses shared `fetchServiceHierarchy()` and resource-level validation rules without modification to onboarding workflows.
- **Global Query Filter**: Soft deletion pattern uses `DeletedAtUtc == null` with `.IgnoreQueryFilters()` explicitly used when audit views are toggled.

---

### [2026-10-23] WBS Service Management Parity with Project Onboarding Section A

- **Branch**: `sahil-action-backend`
- **Purpose**: Align the **Manage Project Services (WBS)** modal with the exact service catalog hierarchy, columns, calculations, and rules used in **Section A: PMO Team Details** during Project Onboarding:
  1. **Contract Type Filtering**: If contract type is "Resource" (or Resource-based), departments are loaded strictly from the Resource Group in `fetchServiceHierarchy()` with Service Model defaulting to `"NA"`. If Scope, departments load from the Scope Group.
  2. **Catalog Service Dropdown Removed**: Removed the separate "Catalog Service" dropdown. Under the selected Sub-Department, the Service Name is chosen directly from the master services under that sub-department, auto-populating default tools, default unit price, default duration days, and computing end date and totals.
  3. **Section A Columns & Predefined Lists**: The Add Service form and the Current Services (WBS) table now include all 24 columns: `Department`, `Sub-Department`, `Service ID` (`WBS-XX`), `Service Name`, `Description`, `Qty`, `Resource Level` (`ResourceDistSelector`), `Frequency` (`Once`, `Half yearly`, `Yearly`), `Service Model` (`NA` or Scope re-test options), `Delivery Model` (`Onsite`, `Offsite`, `Hybrid`), `Delivery Site` (required for Onsite), `Final Delivery Format` (`PDF`, `Excel`, `Squad 1`, `Other Toolbase`), `Tools`, `WBS Start Date`, `WBS End Date`, `Duration (Days)`, `Duration (Hrs)`, `Total Days`, `Total Hrs`, `Unit Price`, `Total`, `Status`, `Actions`.
  4. **Working-Day Date Logic**: Implemented working day calculations (`addWorkingDays`, `countWorkingDays`, `snapToNextWorkingDay`, `addCalendarMonths`, `computeEndDate`) to accurately calculate WBS End Date and durations.
  5. **Prerequisite & Task Generation Preserved**: Newly added services appear in Service-wise Prerequisite Tracking (bypassing collection/validation if Resource per project rules). Tasks are generated only upon Ready to Start with full AP branch and folder structure.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/components/edit-services-modal.tsx`:
    - Added `isResourceContract`, `isScopeContract`, and working-day date math helpers.
    - Updated contract type-driven group filtering (`targetHierarchyGroup`, `departmentsList`, `subDepartmentsList`, `availableServicesList`).
    - Removed redundant `Catalog Service` field and replaced with master catalog Service Name selector + custom option.
    - Added all Section A columns with their exact predefined dropdown lists, default values, and computed fields.
    - Expanded Current Services table to display all 24 columns with horizontal scroll and responsive layout.
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Passed `contractType`, `projectType`, `projectStartDate`, `projectEndDate` into `EditServicesModal`.
    - Updated `WbsPrerequisiteSection` to auto-treat Resource contract services as `isResourceDept` (`NA` for collection and validation).
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - Updated `isResourceDept` detection in `AddProjectServiceAsync` and `UpdateProjectServiceAsync` to include `ServiceModel == "NA"` and `project.ContractType.Contains("Resource")`.
  - `CHANGELOG_AI.md`: Recorded change entry.

---

### [2026-10-23] Dynamic Prerequisite Tracking for Added & Modified Services and Task Tree Merging (AP1, AP2)

- **Branch**: `sahil-action-backend`
- **Purpose**: Fully wire and synchronize added and modified services between **Services & Deliverables from WBS**, **Service-wise Prerequisite Tracking**, and the **Tasks** tab:
  1. **Dynamic Service Prerequisite Tracking**: `WbsPrerequisiteSection` now accepts and prioritizes live services (`rawServices` from `fetchProjectServices`) rather than the stale initial project snapshot (`project.wbsDetails.services`), dynamically reflecting newly added and modified services immediately.
  2. **Dedicated Modification Line in Prerequisite Tracking**: When an existing service is modified (e.g. Qty changed from 1 to 2 in Edit Services), its baseline row is retained (showing `✓ Started`), and a distinct new line is added right below it displaying `Modified (Qty 1 ➔ 2)` with independent Collection, Validation, and Billing status controls.
  3. **"Start" Action for Added & Modified Services**:
     - For a newly added service: Completing prerequisite checks enables the **Start** button, which calls `updateServicePrerequisite(projectId, serviceId, { isReady: true })`, generates initial tasks, marks the service active, and updates the status to `✓ Started`.
     - For a modified service: Validating the modification line enables the dedicated **Start** button, which calls `updateServicePrerequisite(projectId, serviceId, { modIsReady: true })`. This triggers `ApplyServiceModificationAsync` on the backend, updating the service's active quantity, generating the incremental task branches (e.g., adding `AP2` while preserving all existing `AP1` tasks, assignees, stages, and timers), and clearing the modification line.
  4. **Tasks Tab Dynamic Tree & AP Branch Rendering**: Updated `buildServiceTree` in `project-detail-page.tsx` to accept live services (`apiServices`) and exclude deleted services. When `DhTasksTab` loads the updated services and tasks, `buildServiceTree` constructs the tree using the new quantity (e.g. `apList = ["AP1", "AP2"]`), and `applyPersistedTasks` maps the persisted tasks onto `AP1` and `AP2` under the appropriate service folder.
  5. **Clean Zero-Downtime Verification**: Verified full frontend build with `npm run build` (0 errors) and validated backend `/health` endpoint on port 5194.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Updated `WbsPrerequisiteSection` props to accept `liveServices?: ApiProjectService[]`.
    - Passed `liveServices={rawServices}` and `onServicesRefreshed` in both `WbsTab` instances.
    - Updated `WbsPrerequisiteSection` to derive `effectiveServices` from `liveServices` (fallback to `wbsDetails.services`), correctly computing `servicesList`, `activeServicesList`, `allCollected`, and `allValidated`.
    - Added a dedicated, styled **Modified** line in the Service-wise Prerequisite Tracking table for services with `isModPending`, with status selectors and an active **Start** button.
    - Updated baseline service row Ready button label to **Start** (green) and modification row button label to **Start** (amber).
    - Updated `buildServiceTree(project, store, liveServices)` to accept live services, filter deleted items, and dynamically construct `apList` for arbitrary quantities (`AP1`, `AP2`, etc.).
    - In `DhTasksTab`, passed `apiServices` into `buildServiceTree(project, dhStore, apiServices)` and included `apiServices` in `useMemo` dependency array.
  - `CHANGELOG_AI.md`: Recorded change entry.

#### 🗄️ Database & Schema Changes
- **Tables Affected**: `project.tbl_project_services`, `project.tbl_project_tasks`.
- **Logic**: No new columns needed; leveraged existing `ChangeStatus`, `PendingQty`, `ModCollectionStatus`, `ModValidationStatus`, `ModBillingStatus`, `ModIsReady`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `PATCH /api/v1/projects/{projectId}/services/{serviceId}/prerequisite`: Invoked with `{ isReady: true }` when starting a newly added service, or `{ modIsReady: true }` when starting a modified service.
- **Business Logic**:
  - Prerequisite tracking rows dynamically update without full page reloads upon service edits.
  - Starting a modified service increments AP branches from AP1 to AP2 (or decreases with branch deactivation) without corrupting existing task progress or team member assignments.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Existing Task Integrity**: Idempotent branch expansion via `ProjectTaskService.GenerateMissingTasksAsync` adds only new `phase` keys (e.g. `AP2`) while keeping existing tasks, timers, and assignments intact.
- **Onboarding Section A**: Project creation / onboarding flow remains unmodified.
- **Local Database Target**: Local PostgreSQL 18 `trackerpro` on port 5432.

---

### [2026-10-23] Persistent Service Status Post-Start & Modify Drawer UI Optimization

- **Branch**: `sahil-action-backend`
- **Purpose**:
  1. **Persistent State for Added & Modified Services**: Prevent newly added and modified services from reverting or disappearing from the **Services & Deliverables from WBS** table and the **Service-wise Prerequisite Tracking** table once the "Start" action is clicked.
  2. **UI State Transition on "Start"**: Instead of removing rows or wiping badges upon clicking Start, transition the row state gracefully to **`✓ Started`** with clear audit badges.
  3. **Modify Drawer UI Polish**: Fix excessive horizontal spacing between `Target Quantity` and `Resource Level Distribution` inside the inline modification drawer of the **Manage Project Services (WBS)** modal.

#### 📁 Files Affected
- **Modified**:
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - `UpdateServicePrerequisiteAsync`: Maintained `ChangeStatus = "Newly Added"` upon `isReady = true` instead of resetting to `"Active"`.
    - `ApplyServiceModificationAsync`: Set `ChangeStatus = "Modified"` and `ModIsReady = true` upon approving and starting modifications, retaining `OriginalQty` and `PendingQty` while generating delta task branches (e.g. `AP2`).
    - `UpdateProjectServiceAsync`: Permitted modifications on services with status `"Active"`, `"Modified"`, or `"Newly Added"`, preserving baseline `OriginalQty`.
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - **Services & Deliverables Table**: Added persistent `Modified ({svc.originalQty ?? svc.qty} ➔ {svc.qty})` badge and emerald arrow indicator for quantity changes; preserved `Newly Added` badge after start.
    - **Service-wise Prerequisite Tracking Table**:
      - Baseline row for newly added service remains in the table with its badge, transitioning the action button to **`✓ Started`**.
      - Modification row remains visible when `isModified && wbsSvc.modIsReady`, highlighted with an emerald badge, retaining quantity delta text, displaying **`✓ Started`** in the Ready column, and showing `Applied` in the Escalation column.
  - `apps/frontend/src/modules/projects/components/edit-services-modal.tsx`:
    - Redesigned the inline modify drawer into a compact `max-w-3xl` card with `flex flex-wrap items-end gap-5`.
    - Constrained `Target Quantity` to `w-32` and `Resource Level Distribution` to `flex-1 max-w-md`, removing wide spacing across large screens.
    - Fixed closing JSX tags in the table row expansion.
  - `CHANGELOG_AI.md`: Appended change log entry.

#### 🗄️ Database & Schema Changes
- **Tables Affected**: `project.tbl_project_services`
- **Logic**: No schema migration required; utilized existing `ChangeStatus`, `OriginalQty`, `PendingQty`, `ModIsReady` fields with new `"Modified"` state lifecycle.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `PATCH /api/v1/projects/{projectId}/services/{serviceId}/prerequisite`: Transitions service status while preserving audit status identifiers (`"Newly Added"` / `"Modified"`).
- **Business Logic**:
  - Clear state machine: `"Active"` -> `"Newly Added"` (remains post-start with `isReady = true`) and `"Active"`/`"Newly Added"` -> `"Modification Pending"` -> `"Modified"` (remains post-start with `modIsReady = true`).
  - Idempotent task tree generation preserved.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Branch Task Idempotency**: Existing task IDs, assigned team members, stages, and logged timesheets are preserved.
- **Section A Onboarding**: Project Onboarding (`/projects/new`) logic remains untouched.
- **Local Database Target**: Local PostgreSQL 18 `trackerpro` on port 5432.

---

### [2026-10-23] WBS Edit Services Modal — Opaque Actions Column & "Modify" Action Rename

- **Branch**: `sahil-action-backend`
- **Purpose**:
  1. Fix transparent background on the sticky right-pinned **Actions** column in the **Manage Project Services (WBS)** modal table so horizontal scrolling does not show table data through the sticky column.
  2. Change background to solid full white (`bg-white`) with clean elevation shadow and left border.
  3. Rename action button from `"Modify Qty"` to `"Modify"`.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/components/edit-services-modal.tsx`:
    - Changed `th` and `td` of the sticky Actions column to use solid white `bg-white` with `shadow-[-4px_0_6px_-2px_rgba(0,0,0,0.06)]` and `border-l border-border/40`.
    - Renamed button text from `"Modify Qty"` to `"Modify"`.
  - `CHANGELOG_AI.md`: Recorded change entry.

#### 🗄️ Database & Schema Changes
- None (UI styling and label adjustment only).

#### 🔌 APIs & Business Logic Changed
- None (Pure frontend UI styling).

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Sticky Column Positioning**: Kept `sticky right-0` alignment and z-index elevation (`z-20` on header, `z-10` on body cell) intact.

---

### [2026-10-23] Invoice Schedule — Service Name Column Addition & Database Verification

- **Branch**: `sahil-action-backend`
- **Purpose**:
  1. Validate that the Invoice Schedule data originates from and saves to the database table (`project.tbl_project_invoices`).
  2. Add the **`Service Name`** column directly before the **`Milestone/Period`** column in the **Invoice Schedule** section table of the Project Details page (`/projects/$projectId`).
  3. Ensure that backend APIs (`GetProjectInvoicesAsync`, `GetProjectInvoiceByIdAsync`, `AutoGenerateInvoicesAsync`) return and populate `ServiceName` from the database, with automatic fallback resolution to project services when needed.
  4. Backfilled historical invoice records in PostgreSQL `project.tbl_project_invoices` where `ServiceName` was null using matching project services.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - In `WbsTab` Invoice Schedule: Added `<th className="px-3 py-2 font-medium">Service Name</th>` before `Milestone/Period`, and `<td className="px-3 py-2 font-semibold text-foreground whitespace-nowrap">{displayServiceName}</td>` before `inv.milestone`. Updated empty row colSpan from 5 to 6.
    - In Fallback WbsTab: Added `Service Name` header and sample cell before `Milestone/Period`.
    - In Invoices Tab (PMO & Non-PMO tables): Added `Service Name` header and cell before `Milestone`, updating empty colSpans.
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - Updated `GetProjectInvoicesAsync` and `GetProjectInvoiceByIdAsync` to supply `fallbackServiceName` from project services when invoice `ServiceName` is null.
    - Updated `AutoGenerateInvoicesAsync` to query `db.ProjectServices` and assign `defaultServiceName` directly onto newly generated `ProjectInvoice` entities.
    - Updated `MapToInvoiceDto` to accept optional `fallbackServiceName`.
  - `CHANGELOG_AI.md`: Recorded change entry.

#### 🗄️ Database & Schema Changes
- **Table**: `project.tbl_project_invoices`
- **Verification & Data Fix**:
  - Verified table already contains `"ServiceName" character varying(255)`.
  - Executed SQL update to populate `"ServiceName"` for 32 historical invoice rows using the corresponding project's active services. 100% of rows now have `ServiceName`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/projects/{projectId}/invoices`: Guarantees `serviceName` is populated on every returned `ProjectInvoiceDto`.
  - `POST /api/v1/projects/{projectId}/invoices`: Persists `serviceName` to `project.tbl_project_invoices`.
- **Business Logic**:
  - Added robust fallback logic: `inv.serviceName` -> matched service from `wbsDetails.services` -> single project service -> `"—"`.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Database Schema**: PascalCase quoted identifier `"ServiceName"` on `project.tbl_project_invoices`.
- **Project Onboarding (`/projects/new`)**: Section B invoice schedule creation and `createProjectInvoice` payload flow preserved intact.

---

### [2026-10-23] WBS Edit Services Modal — Modify Drawer Layout Alignment & Button Repositioning

- **Branch**: `sahil-action-backend`
- **Purpose**:
  1. Equalize the widths of `Target Quantity` and `Resource Level Distribution` fields (`w-48` each).
  2. Reduce gap between the two fields to `gap-3` so they sit immediately next to each other with no awkward gap.
  3. Relocate the `Cancel` and `Stage Modification` buttons directly below the `Resource Level Distribution` field instead of floating in a separate bottom bar.
  4. Constrain the modification drawer card width to `max-w-xl` for a compact, neat appearance.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/components/edit-services-modal.tsx`:
    - Updated drawer container to `max-w-xl`.
    - Set both `Target Quantity` and `Resource Level Distribution` wrappers to matching width `w-48` with tight `gap-3`.
    - Moved `Cancel` and `Stage Modification` action buttons directly beneath `Resource Level Distribution`.
  - `CHANGELOG_AI.md`: Appended change log entry.

#### 🗄️ Database & Schema Changes
- None (pure UI layout and positioning refinement).

#### 🔌 APIs & Business Logic Changed
- None (UI layout refinement).

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Staging modification logic (`stageModification`), quantity validation, and downward impact detection (`checkModificationImpact`) preserved intact.

---

### [2026-10-23] Dynamic Invoice Schedule Generation on Adding Services & Soft-Deletion on Removal

- **Branch**: `sahil-action-backend`
- **Purpose**:
  1. **Automatic Invoice Generation upon Adding Services**: When a new service is added to a project (via WBS "Edit Services"), invoice schedule rows are automatically generated in `project.tbl_project_invoices` based on the service's `Frequency` field:
     - `Once` (default): 1 invoice row (`Month 1`) for 100% of the service total.
     - `Half yearly`: 6 monthly invoice rows (`Month 1` to `Month 6`), evenly dividing the service total with exact reconciliation on the 6th month.
     - `Yearly` / `One year`: 12 monthly invoice rows (`Month 1` to `Month 12`), evenly dividing the service total with exact reconciliation on the 12th month.
     - Invoice due dates start from `service.StartDate` (or `project.StartDate`) and increment by 1 month per period (`startDate.AddMonths(m - 1)`).
     - New invoice rows link directly to the service via foreign key `ProjectServiceId`, service name, quantity, unit price, and currency.
  2. **Soft Deletion of Service Invoices on Service Removal**:
     - When an existing or added service is removed/deleted via `DeleteProjectServiceAsync`, all associated invoice rows (`ProjectServiceId == serviceId` or fallback by name) are soft-deleted (`DeletedAtUtc = DateTime.UtcNow`) rather than physically deleted.
     - `RecalculateProjectInvoiceRollupAsync` is triggered to recalculate `project.InvoiceValue` using active invoices only.
  3. **WBS Invoice Schedule UI Tracking for Inactive/Deleted Rows**:
     - When "Show Inactive/Deleted" checkbox is unchecked: soft-deleted invoices are hidden.
     - When "Show Inactive/Deleted" checkbox is checked: soft-deleted invoices are displayed with strike-through styling (`opacity-60 bg-muted/30 line-through`), a `Deleted` badge in the Service Name column, and "Raise Invoice" is disabled (`—`).
     - Real-time refresh synchronizes both WBS tab and parent project state immediately upon adding or removing services.

#### 📁 Files Affected
- **Modified**:
  - `apps/backend/Modules/Projects/Models/ProjectInvoice.cs`:
    - Added `public Guid? ProjectServiceId { get; set; }` and navigation property `public ProjectServiceEntity? ProjectService { get; set; }`.
  - `apps/backend/Infrastructure/Persistence/Configurations/ProjectInvoiceConfiguration.cs`:
    - Added configuration for `ProjectServiceId`, index `IX_tbl_project_invoices_ProjectServiceId`, and foreign key relationship to `ProjectService` with `OnDelete(DeleteBehavior.SetNull)`.
  - `apps/backend/Modules/Projects/DTOs/ProjectInvoiceDtos.cs`:
    - Added `Guid? ProjectServiceId = null`, `DateTime? DeletedAtUtc = null`, `bool IsDeleted = false` to `ProjectInvoiceDto`.
    - Added `Guid? ProjectServiceId = null` to `CreateProjectInvoiceRequest` and `UpdateProjectInvoiceRequest`.
  - `apps/backend/Modules/Projects/DTOs/ProjectServiceDtos.cs`:
    - Added `bool GenerateInvoices = true` to `CreateProjectServiceRequest`.
  - `apps/backend/Modules/Projects/Services/IProjectAppService.cs`:
    - Added `bool includeDeleted = false` parameter to `GetProjectInvoicesAsync(Guid projectId, bool includeDeleted = false, CancellationToken ct = default)`.
  - `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`:
    - Added `[FromQuery] bool includeDeleted = false` parameter to `GetProjectInvoices` endpoint.
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - In `AddProjectServiceAsync`: Added invoice schedule generation logic based on `Frequency` (`Once` -> 1 month, `Half yearly` -> 6 months, `Yearly` -> 12 months) with period amounts, sequential sort order, and rollup recalculation when `request.GenerateInvoices` is true.
    - In `DeleteProjectServiceAsync`: Soft-deletes related invoices in `db.ProjectInvoices` matching `ProjectServiceId == serviceId` or service name, and triggers `RecalculateProjectInvoiceRollupAsync`.
    - In `GetProjectInvoicesAsync`: Added `includeDeleted` support using EF Core `.IgnoreQueryFilters()`.
    - In `CreateProjectInvoiceAsync` & `UpdateProjectInvoiceAsync`: Mapped `ProjectServiceId`.
    - In `RecalculateProjectInvoiceRollupAsync`: Changed sum to handle nullable `TotalAmount` and update `project.InvoiceValue` cleanly.
    - In `MapToInvoiceDto`: Mapped `ProjectServiceId`, `DeletedAtUtc`, and `IsDeleted`.
  - `apps/frontend/src/modules/projects/api/projects.ts`:
    - Added `projectServiceId`, `deletedAtUtc`, `isDeleted` to `ApiProjectInvoice`.
    - Added `generateInvoices?: boolean` to `CreateProjectServicePayload`.
    - Added `projectServiceId?: string | null` to `CreateProjectInvoicePayload`.
    - Updated `fetchProjectInvoices(projectId: string, includeDeleted = false)` to pass query param `?includeDeleted=true`.
    - Updated `mapApiInvoiceToScheduleRow` to expose `projectServiceId`, `deletedAtUtc`, and `isDeleted`.
    - Updated `toCreateInvoicePayload` to pass `projectServiceId`.
  - `apps/frontend/src/modules/projects/pages/project-onboarding-page.tsx`:
    - Set `generateInvoices: false` when creating initial services on onboarding submission to prevent duplicate invoice generation with onboarding's custom/configured milestones.
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Filtered out soft-deleted invoices from `raisedInvoices` in parent page state.
    - Added `refreshProjectInvoices` callback passed down to `WbsTab` as `onInvoicesRefreshed`.
    - In `WbsTab`: Added state `apiWbsInvoices` and `loadInvoices` hook triggered on `refreshCount` and `showDeletedServices`.
    - Filtered displayed invoices based on `showDeletedServices`.
    - Rendered soft-deleted invoices with `opacity-60 bg-muted/30 line-through`, a `Deleted` badge, and disabled "Raise Invoice" (`—`).
    - Recalculated `totalServices` in WBS info card to sum only active services (`!s.isDeleted && s.changeStatus !== "Deleted"`).
    - Synchronized invoice date changes optimistically in local state.
  - `CHANGELOG_AI.md`: Recorded change entry.

#### 🗄️ Database & Schema Changes
- **Table**: `project.tbl_project_invoices`
  - Added column `"ProjectServiceId" uuid NULL`.
  - Created index `"IX_tbl_project_invoices_ProjectServiceId"` ON `project.tbl_project_invoices ("ProjectServiceId")`.
  - Added foreign key constraint `"FK_tbl_project_invoices_tbl_project_services_ProjectServiceId"` pointing to `project.tbl_project_services ("Id") ON DELETE SET NULL`.
  - Backfilled existing 39 historical invoice rows with their respective `"ProjectServiceId"` by matching `ProjectId` and `ServiceName`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/projects/{projectId}/invoices?includeDeleted=false`: Returns only active invoices (default).
  - `GET /api/v1/projects/{projectId}/invoices?includeDeleted=true`: Returns both active and soft-deleted invoices with `deletedAtUtc` and `isDeleted = true`.
  - `POST /api/v1/projects/{projectId}/services`: Now supports `generateInvoices: true` (default) to generate monthly invoice milestones automatically per frequency rules.
  - `DELETE /api/v1/projects/{projectId}/services/{serviceId}`: Soft-deletes child tasks and associated invoice rows (`DeletedAtUtc = DateTime.UtcNow`), updating project invoice rollups.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Onboarding (`/projects/new`)**: Preserved custom invoice scheduling logic by explicitly passing `generateInvoices: false` during initial service creation.
- **Invoice Frequencies**: Frequency mapping strictly preserved (`Once` -> 1 month, `Half yearly` -> 6 months, `Yearly` -> 12 months).
- **Soft-Delete Invariant**: Deleting a service or invoice must NEVER issue physical hard DELETEs from database; records must preserve `DeletedAtUtc`.

---

### [2026-10-23] Consecutive Service Modifications Workflow & Dynamic Services Subtotal & Grand Total Recalculation

- **Branch**: `sahil-action-backend`
- **Purpose**:
  1. **Consecutive/Re-modification of Services**:
     - Fixed `OriginalQty` tracking bug in `ProjectAppService.UpdateProjectServiceAsync`: Previously, `service.OriginalQty = service.OriginalQty.HasValue ? service.OriginalQty : service.Qty;` locked `OriginalQty` permanently to the initial quantity (1). When a service was modified a second time (e.g. from 4 down to 2), `OriginalQty` remained 1, making `ApplyServiceModificationAsync` mistakenly think quantity was *increasing* (2 > 1) instead of decreasing (4 -> 2).
     - Now dynamically captures `service.OriginalQty = service.Qty;` (the current active quantity) on each staged modification, allowing any number of consecutive modifications (e.g. 1 ➔ 4, then 4 ➔ 2, then 2 ➔ 3).
     - Supported `ChangeStatus == "Modification Pending"` in `UpdateProjectServiceAsync` so editing an unapplied pending modification refreshes target quantity cleanly.
     - Reset prerequisite workflow statuses (`ModCollectionStatus`, `ModValidationStatus`, `ModBillingStatus`, `ModIsReady = false`) so re-modified services cleanly generate an actionable modification row in **Service-wise Prerequisite Tracking** displaying `Qty 4 ➔ 2`.
     - In `ApplyServiceModificationAsync`: Compares `newQty` against `oldQty`. If `newQty < oldQty`, calls `taskService.DeactivateExcessTaskBranchesAsync(projectId, serviceId, newQty)`, removing excess branches (e.g. AP3 and AP4) and leaving active branches (AP1 and AP2). If `newQty > oldQty`, calls `taskService.GenerateMissingTasksAsync(projectId)`.
     - Automatically updates linked `ProjectInvoice` rows for the modified service (`Qty`, `UnitPrice`, `Amount`, `TaxAmount`, `TotalAmount`) and recalculates `project.InvoiceValue`.
  2. **Services Subtotal and Grand Total Maintenance**:
     - In `WbsTab` (`project-detail-page.tsx`):
       - `totalServices` calculates the sum of active services using `effectiveQty` (`pendingQty` when `Modification Pending` else `qty`) and `effectiveUnitPrice`, immediately reflecting quantity increases or decreases on the Services Subtotal.
       - Replaced hardcoded 18% tax calculation with dynamic project tax rate: `taxPercent = project.taxPercent ?? project.wbsDetails?.accounts?.taxPercent ?? 18`.
       - Tax amount: `tax = Math.round(totalServices * (taxPercent / 100) * 100) / 100`.
       - Grand total: `grandTotal = totalServices + tax`.
       - Displayed dynamic label `Tax ({taxPercent}%)` and formatted amount `{currency} {tax.toLocaleString()}`.
       - Added `Unit Price` and `Total` columns to the "Services & Deliverables from WBS" table when `!hideAmounts`.
       - Dynamically displayed `Total Days` and `Total Hours` reflecting pending quantities.
     - In `WbsSummaryCard` (`project-detail-page.tsx`):
       - Updated `totalServices`, `taxAmount`, and `grandTotal` to respect dynamic tax percentage and pending quantities.
     - In `edit-services-modal.tsx`:
       - Recalculated `Total Days`, `Total Hrs`, and `Total` for staged modification rows in real time.

#### 📁 Files Affected
- **Modified**:
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - Updated `UpdateProjectServiceAsync`: Dynamically set `OriginalQty = service.Qty`, added support for `ChangeStatus == "Modification Pending"`, reset modification prerequisite statuses, updated linked invoices on direct changes.
    - Updated `ApplyServiceModificationAsync`: Updated linked `ProjectInvoice` rows proportionally to the new quantity and unit price, triggered `RecalculateProjectInvoiceRollupAsync`, and invoked `DeactivateExcessTaskBranchesAsync` when decreasing quantity or `GenerateMissingTasksAsync` when increasing quantity.
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - In `WbsTab`: Updated `totalServices` calculation to evaluate `effectiveQty` and `effectiveUnitPrice`, dynamic `taxPercent`, `tax`, and `grandTotal`. Added `Unit Price` and `Total` columns to Services table.
    - In `WbsSummaryCard`: Updated `totalServices`, dynamic `taxAmount`, and `grandTotal`.
  - `apps/frontend/src/modules/projects/components/edit-services-modal.tsx`:
    - Recalculated total days, hours, and total amount when `stagedMod` is present.
  - `CHANGELOG_AI.md`: Recorded change entry.

#### 🗄️ Database & Schema Changes
- None required (utilized existing columns `OriginalQty`, `PendingQty`, `ChangeStatus`, `ModIsReady`, `ProjectServiceId`, `DeletedAtUtc`).

#### 🔌 APIs & Business Logic Changed
- **APIs**:
  - `PUT /api/v1/projects/{projectId}/services/{serviceId}`: With `asPendingModification = true`, accurately updates `originalQty` to current active `qty`, sets `pendingQty`, resets `modIsReady = false`, and updates status to `Modification Pending`.
  - `PATCH /api/v1/projects/{projectId}/services/{serviceId}/prerequisite`: With `modIsReady = true`, applies modification, triggers task expansion or branch reduction via `DeactivateExcessTaskBranchesAsync`, updates linked invoices, and recalculates project totals.
- **Business Logic**: Consecutive service modifications seamlessly update tasks, invoices, subtotal, and grand total.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- **Branch Naming**: AP numbers (`AP1`, `AP2`, ..., `APn`) parsed strictly via `ParseApNumber` in `ProjectTaskService`. Deactivating excess branches removes only tasks where `AP number > keepQty`.
- **Soft-Delete Invariant**: Linked invoice queries and rollups filter by `DeletedAtUtc == null`.
- **Tax Calculation**: Tax percentage formula `totalServices * (taxPercent / 100)` strictly respected across all WBS views.






