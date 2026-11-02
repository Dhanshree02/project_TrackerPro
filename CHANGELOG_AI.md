# AI-Assisted Development Changelog (`CHANGELOG_AI.md`)

This file tracks all significant backend, database, API, and architectural changes across the project. Its purpose is to maintain a clear audit trail, aid code reviews, and prevent regressions.

---

## Change Log Template

Whenever a new feature, database migration, API route, or business logic change is implemented, an entry will be added following this format:

```markdown
### [YYYY-MM-DD] <Feature or Task Title>

- **Branch**: `<branch-name>`
- **Module**: <Module Name>
- **Purpose**: Brief description of the objective and requirements.

#### 📁 Files Affected
- **Created**: `path/to/file`
- **Modified**: `path/to/file`
- **Deleted**: `path/to/file`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**: e.g., `schema.table_name` (added columns, constraints, etc.)
- **Migrations / Scripts**: Migration files or raw SQL applied.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**: Added, modified, or removed API routes.
- **Business Logic**: Key service/logic changes or behavioral alterations.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Explicit notes on functionality, shared contracts, or interfaces that must not be broken.
```

---

## Log Entries

### [2026-11-02] Eliminate Tasks Tab AP1 Flicker, Seed All Service Abbreviations, and Enforce Mandatory Abbreviation

- **Branch**: `uat_clean3`
- **Module**: Masters (Project Masters), Projects (Project Tasks Tab), Database
- **Purpose**:
  1. Eliminate the 1-second delay/flicker where task folders briefly displayed `AP1` before switching to abbreviation labels on the Tasks tab.
  2. Populate distinct service abbreviations for all 29 services in `master.mst_service_catalog` that previously lacked them, and backfill existing project services and tasks.
  3. Enforce `Service Abbreviation` as a strictly mandatory field in Settings → Project Masters across the main creation form, edit modal, and new service modal on both frontend and backend.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Migrations/20261102120000_SeedAllServiceAbbreviations.cs`
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Initialized `serviceCatalogAbbrCache` with `defaultCatalogAbbrs` covering all standard catalog services from frame 0.
    - Added catalog ID and substring/containment fallbacks in `buildServiceTree`.
    - Added `apiTasksLoading` state to `DhTasksTab` to render a clean `Loading tasks…` spinner with `Loader2` while API services and persisted tasks are resolving, eliminating the un-hydrated `AP1` flash.
  - `apps/frontend/src/modules/settings/components/masters/project-masters-section.tsx`:
    - Added red asterisk `*` indicating mandatory status for `Service Abbreviation` across top form, edit modal, and add service modal.
    - Added client-side validation requiring non-empty `abbreviation.trim()` in `handleAddSubmit`, `handleEditSubmit`, and `handleSaveNewService`.
  - `apps/backend/Modules/Catalogs/Services/ProjectMastersService.cs`:
    - Updated `ValidateMasterFields` to require `abbreviation` and throw a `ConflictException` if missing or whitespace.
    - Enforced mandatory abbreviation validation in `CreateAsync`, `UpdateAsync`, and `CreateServiceOnlyAsync`.
  - `database/pms_uat.sql`:
    - Refreshed SQL snapshot from live `pms_uat_clean` database including all seeded abbreviations and cleaned orphan tasks.

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `master.mst_service_catalog`: Updated all 29 rows where `Abbreviation` was NULL/empty to distinct abbreviations (e.g. `WAPT`, `MAPT`, `APIPT`, `WAVA`, `CIVA`, `TRTE`, `AZURE`, `GCP`, `SCSR`, `SAST`, `DAST`, `GDPR`, `PCI`, `SOC2`, `PHISH`, `SATP`, `VPA`, `DFI`, `IRC`, `MA`, `NASR`, `FICA`, `NSA`, `TMRA`, `CTIR`, `ASA`, `SOC`, `FSF`, `SRV1`).
  - `project.tbl_project_services`: Backfilled `ServiceAbbreviation` and `ServiceCatalogId` for existing unlinked services.
  - `project.tbl_project_tasks`: Cleaned orphan duplicate `AP` tasks and updated remaining `Phase` records to match the service abbreviation sequence (e.g. `AZURE1`, `TKPT1`, `CS1`).
- **Migrations / Scripts**:
  - Applied SQL migration to PostgreSQL database `pms_uat_clean` and created EF migration `20261102120000_SeedAllServiceAbbreviations.cs`.

#### 🔌 APIs & Business Logic Changed
- **Business Logic**:
  - `POST /api/v1/catalogs/service-masters` & `PUT /api/v1/catalogs/service-masters/{id}`: Now validate that `Abbreviation` is present and non-empty.
  - `GET /api/v1/catalogs/service-hierarchy`: Returns populated `abbreviation` for 100% of services (36/36).
  - Tasks Tab folder generation: Synchronously resolves abbreviations on render, eliminating any delay or fallback to generic `AP1`.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Task quantity sequencing (`{abbr}1`, `{abbr}2`, `{abbr}3`), quarter hierarchies, estimated hours, time tracking, and team assignments are fully preserved.

---

### [2026-11-02] Project Masters Edit Modal Duration & Unit Price Pre-population and Robust Cascading

- **Branch**: `uat_clean3`
- **Module**: Settings (Project Masters), API
- **Purpose**:
  1. Fix the bug where opening the Edit Modal for a service master did not populate `Duration (Days)` and `Unit Price (₹)`.
  2. Ensure that users can update only the single field they wish to change without being forced to re-enter all fields or facing validation errors on existing fields.
  3. Ensure robust cascading: changing contract type, department, or sub-department in the Edit Modal automatically populates default tools, duration, unit price, and abbreviation rather than wiping fields blank.
  4. Fix layout in the Edit Modal so Sub-department, Service, and Service Abbreviation sit on a clean 3-column responsive row.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/settings/components/masters/project-masters-section.tsx`:
    - Imported `parseDurationDays` from `@/modules/settings/api/project-masters` in `project-masters-section.tsx` (resolving an unhandled runtime `ReferenceError` during `openEditModal` that prevented `setEditDuration` and `setEditUnitPrice` from executing).
    - Updated `openEditModal` to safely parse and pre-populate `Duration (Days)` and `Unit Price (₹)` from row item data, with automatic fallback to catalog hierarchy (`matchedSvc.days`, `matchedSvc.unitPrice`) or standard sensible defaults (`5` days, `₹50,000`).
    - Enhanced `handleEditServiceChange` to match services case-insensitively and populate duration, unit price, tools, and abbreviation without overwriting with empty values.
    - Updated `handleEditDepartmentChange` and `handleEditSubDepartmentChange` to automatically cascade to the first available service and its defined parameters rather than clearing duration and unit price to blank.
    - Updated top Add Form `handleServiceChange` with case-insensitive matching and non-empty fallback defaults.
    - Fixed Edit Modal layout to responsive `grid-cols-1 sm:grid-cols-3` for Sub-department, Service, and Service Abbreviation.
  - `apps/frontend/src/modules/settings/api/project-masters.ts`:
    - Hardened `parseDurationDays` to accept `string | number | null | undefined` and safely handle numeric values without calling `.match()` on non-strings.
    - Updated `rowToProjectMasterItem` to guarantee a non-empty `duration` string (`days > 0 ? '${days} Days' : '5 Days'`).

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `master.mst_service_catalog`: Backfilled `DefaultDurationDays = 5`, `DefaultUnitPrice = 50000`, `DefaultTools = 'TBD'` for the legacy `fsf` catalog entry so that all 36 active catalog services have non-null duration and pricing.

#### 🔌 APIs & Business Logic Changed
- **Business Logic**:
  - All form fields in the Edit Modal come fully pre-filled with the service's existing saved values.
  - Editing any single field (e.g. only duration, only price, only abbreviation, or only tools) allows immediate submission without re-entering other values.
  - Re-selecting a service from the dropdown automatically populates the service catalog's defaults for tools, duration, and unit price.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Existing onboarding project setup, project detail pages, service hierarchy endpoints, and task calculation logic remain fully intact.

---

### [2026-11-02] Fix onServicesRefreshed Scope Reference and Lock Started Service Prerequisite Statuses

- **Branch**: `uat_clean3`
- **Module**: Projects (Project Detail Page - WBS & Prerequisite Tracking)
- **Purpose**:
  1. Fix the runtime error `onServicesRefreshed is not defined` triggered when modifying/adding services in `EditServicesModal` or updating prerequisite tracking.
  2. Enforce read-only state for `Billing Status`, `Validation Status`, and `Collection Status` once a service is started (`isReady: true`), preventing inconsistent modifications to active services.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Added missing `onServicesRefreshed` to destructured props in `WbsTab` parameter list.
    - Updated `WbsPrerequisiteSection` service tracking table to disable `collectionStatus`, `validationStatus`, and `billingStatus` select inputs once `isReady` is `true`.
    - Added guard in `handleServiceChange` to reject edits on services that are already started.

#### 🔌 APIs & Business Logic Changed
- **Business Logic**:
  - Prerequisite statuses (`collectionStatus`, `validationStatus`, `billingStatus`) are editable only while the service is in pre-delivery state.
  - Once the PM/Dhanshree clicks "Start" (`isReady: true`), the service prerequisites lock into read-only mode with disabled styling (`cursor-not-allowed`).
  - Calling `onServicesRefreshed?.()` in `EditServicesModal` and `WbsPrerequisiteSection` resolves cleanly to trigger project data re-fetch.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Modification section tracking, task generation on service start, and prerequisite audit logging remain intact.

---

### [2026-11-02] Add and Edit Tasks Under Individual Services

- **Branch**: `uat_clean3`
- **Module**: Projects (Project Detail Page - Tasks Tab), Database
- **Purpose**:
  1. Implement "+ Add Task" and "Edit" action controls immediately after the Stage column in the leaf task section of the Project Tasks tab.
  2. Implement clean "Add Task Modal" featuring Task Type toggle (`Managerial Task` / `Training/Learning`), mandatory validated Task Title input, and duplicate submission prevention.
  3. Associate added tasks directly with the parent project and selected service, generating a unique Task ID (`Task 01`, `Task 02`, `Task 03`, ...) following existing conventions, defaulting stage to "Not Started", and integrating into assignments, timers, and progress workflows.
  4. Implement "Edit Task Modal" allowing users to rename existing tasks without altering Task ID, execution history, dates, or resource assignments.
  5. Add `TaskType` column to `project.tbl_project_tasks` and update backend models, DTOs, services, and migrations.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Migrations/20261102144000_AddProjectTaskType.cs`: EF Core migration adding `TaskType` (`character varying(50)`) column to `project.tbl_project_tasks`.
- **Modified**:
  - `apps/backend/Modules/Projects/Models/ProjectTask.cs`:
    - Added `public string? TaskType { get; set; }` property.
  - `apps/backend/Modules/Projects/DTOs/ProjectTaskDtos.cs`:
    - Added `string? TaskType = null` to `ProjectTaskDto`, `CreateProjectTaskRequest`, and `UpdateProjectTaskRequest`.
    - Updated default `Stage` in `CreateProjectTaskRequest` to `"Not Started"`.
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - In `CreateProjectTaskAsync`: Added validations for non-empty title, validated `TaskType` against allowed options (`Managerial Task`, `Training/Learning`), set default stage to `"Not Started"`, and mapped `TaskType`.
    - In `UpdateProjectTaskAsync`: Added non-empty title validation, mapped updated title and `TaskType`.
    - In `MapToTaskDto`: Mapped `TaskType`.
  - `apps/backend/Modules/Projects/Services/ProjectTaskService.cs`:
    - Passed `TaskType` when generating project task DTOs.
  - `apps/frontend/src/modules/projects/api/projects.ts`:
    - Added `taskType?: string | null` to `ApiProjectTask`, `CreateProjectTaskPayload`, and `UpdateProjectTaskPayload`.
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Extended `TreeTask` interface with `taskTitle?: string` and `taskType?: string | null`.
    - Extended `TreeRow` for `type: "ap"` with `quarter?: QuarterFolder | null` to pass quarter context when adding tasks.
    - Updated `applyPersistedTasks` to dynamically assemble and merge all persisted tasks for each AP folder, generating consistent Task IDs (`Task 01`, `Task 02`, etc.) while displaying custom/renamed task titles.
    - Added compact action controls immediately after the `Stage` column in each leaf task row (`Edit` and `+ Add Task`) and in the table header.
    - Added `AddTaskModal` with `Managerial Task` / `Training/Learning` toggle buttons, mandatory task title input, duplicate prevention, and clean cancel/add buttons.
    - Added `EditTaskModal` with pre-populated existing task title, strict title-only editing, duplicate prevention, and save changes.
  - `database/pms_uat.sql`:
    - Updated `CREATE TABLE project.tbl_project_tasks` schema to include `"TaskType" character varying(50)`.

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_project_tasks`: Added column `"TaskType" character varying(50)` (nullable).
- **Migrations / Scripts**:
  - Executed `ALTER TABLE project.tbl_project_tasks ADD COLUMN IF NOT EXISTS "TaskType" character varying(50);` on `pms_uat_clean`.
  - Added EF Core migration `20261102144000_AddProjectTaskType.cs`.
  - Updated snapshot in `database/pms_uat.sql`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `POST /api/v1/projects/{projectId}/tasks`: Accepts `taskType` (`Managerial Task` or `Training/Learning`), validates non-empty title and allowed task type, associates with `projectServiceId`, defaults stage to `Not Started`.
  - `PUT /api/v1/projects/{projectId}/tasks/{taskId}`: Updates task title with non-empty validation while preserving `taskType`, assignments, and execution history.
- **Business Logic**:
  - Leaf task sections now support adding multiple tasks under any service.
  - Newly added tasks automatically participate in assignment, timers, stage updates, and progress calculations.
  - Renaming tasks preserves their generated `Task ID` (`Task 01`, `Task 02`, etc.) and all execution tracking.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Existing auto-generated service model tasks, AP folder numbering logic, quarter hierarchies, timers, and utilized hours are 100% preserved.

---

### [2026-11-02] Fix Add Task ReferenceError, Refine Edit/Add Column, and Direct Renamed Task Title Rendering

- **Branch**: `uat_clean3`
- **Module**: Projects (Project Detail Page - Tasks Tab)
- **Purpose**:
  1. Fix runtime `ReferenceError: createProjectTask is not defined` when creating a task by adding `createProjectTask` to the import list in `project-detail-page.tsx`.
  2. Simplify leaf task table column header: remove the redundant "+ Add Task" button from the header cell and set clean header text `Edit / Add`.
  3. Update leaf task title rendering: display the renamed task name directly (e.g., `testing` instead of `Task 01 (testing)`).
  4. Update Edit Task modal header to display the current task title dynamically.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Imported `createProjectTask` from `@/modules/projects/api/projects`.
    - Replaced the action header cell containing the button with `<th className="... whitespace-nowrap">Edit / Add</th>`.
    - Updated Task ID cell to render `{t.taskTitle || t.taskId}` directly without parenthetical suffix.
    - Updated Edit modal header subtitle to reference `editTaskState.currentTitle`.

#### 🔌 APIs & Business Logic Changed
- **Business Logic**:
  - Task renaming directly replaces the displayed name with the user-provided title across the leaf task row.
  - Adding tasks executes `createProjectTask` without reference errors.
  - Leaf task action buttons remain on each row (`Edit` and `+ Add Task`).

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Database persistence, assignments, timers, and folder hierarchies remain intact.


---

### [2026-11-02] Position-Aware Task Insertion Directly Below Trigger Task

- **Branch**: `uat_clean3`
- **Module**: Projects (Project Tasks Tab - Backend & Frontend)
- **Purpose**:
  1. Ensure that newly added tasks are inserted directly below the existing task row where the user clicked "+ Add Task" (rather than appending at the bottom of the folder).
  2. Maintain clean integer spacing (`10, 20, 30...`) across all tasks in the folder upon insertion, shifting subsequent sibling tasks forward automatically.
  3. Support empty folders or non-targeted creations by appending at the end (`maxSort + 10` or `10`).
  4. Ensure immediate frontend state consistency by re-fetching project tasks via `fetchProjectTasks(project.id)` upon successful creation, guaranteeing instant UI re-ordering without a full page refresh.
  5. Provide UI context in the Add Task Modal indicating which task the new task is being inserted below.

#### 📁 Files Affected
- **Modified**:
  - `apps/backend/Modules/Projects/DTOs/ProjectTaskDtos.cs`:
    - Added `Guid? InsertAfterTaskId = null` to `CreateProjectTaskRequest`.
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - Updated `CreateProjectTaskAsync` to look up `targetTask` by `InsertAfterTaskId`, retrieve all sibling tasks in the exact matching service/phase/period folder, and re-sequence `SortOrder` values in increments of 10 (`targetTask.SortOrder = 10, 20...`, `new task = targetSortOrder`, and subsequent tasks shifted forward).
  - `apps/frontend/src/modules/projects/api/projects.ts`:
    - Added `insertAfterTaskId?: string | null;` to `CreateProjectTaskPayload`.
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Extended `addTaskState` with `insertAfterTaskId` and `insertAfterTaskTitle`.
    - Updated leaf task row "+ Add Task" button to pass `insertAfterTaskId: t.dbId || null` and `insertAfterTaskTitle: t.taskTitle || t.taskId`.
    - Updated `handleCreateTask` to pass `insertAfterTaskId` in payload and call `fetchProjectTasks(project.id)` upon success to refresh the tree state.
    - Added subtitle in `AddTaskModal` showing "• Below: <Task Name>" for user clarity.

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_project_tasks`: Leveraged existing `SortOrder` integer column to persist the relative ordering of tasks within each service/folder.
- **Database Workflow**:
  - Auto-generated tasks start with `SortOrder` spaced by 10 (`10, 20, 30...`).
  - When a new task is inserted below task `T` (at index `k`), sibling tasks from `0` to `k` are normalized to `10, 20, ... (k+1)*10`. The new task is assigned `(k+2)*10`. Sibling tasks from `k+1` onwards are shifted to `(k+3)*10, ...`.
  - EF Core saves the updated sibling rows and inserts the new row in a single atomic transaction.
  - Querying `tbl_project_tasks` with `ORDER BY "SortOrder", "CreatedAtUtc"` retrieves all tasks in exact hierarchical order.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `POST /api/v1/projects/{projectId}/tasks`: Accepts optional `insertAfterTaskId` (UUID). If provided, computes position and updates sibling sort orders.
- **Business Logic**:
  - Tasks added from any row in the Tasks tab are positioned immediately below that row.
  - Sibling folder tasks stay sorted by `SortOrder`.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- All existing AP folder structures, quarter hierarchy, service models, assignment workflows, timer tracking, and progress calculations remain 100% intact.
