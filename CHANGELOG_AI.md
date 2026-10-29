# AI-Assisted Development Changelog (`CHANGELOG_AI.md`)

This file tracks all significant backend, database, API, and architectural changes for the **Action Center** module. Its purpose is to maintain a clear audit trail, aid code reviews, and prevent regressions.

---

## Change Log Template

Whenever a new feature, database migration, API route, or business logic change is implemented, an entry will be added following this format:

```markdown
### [YYYY-MM-DD] <Feature or Task Title>

- **Branch**: `<branch-name>`
- **Module**: Action Center
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

### [2026-10-28] Action Center Bucket List Backend Implementation & Two-Way Task Synchronization

- **Branch**: `uat_clean2`
- **Module**: Action Center (Bucket List Backend)
- **Database**: PostgreSQL 16.15 (`10.50.30.189:41763` on `pms_uat_clean`)
- **Purpose**: Implement the Action Center Bucket List backend enabling assigned resources to search, filter (by status and priority), manage timers, and display task, project, priority, due date (parent WBS service end date), status/stage, assigner name (SPM/PM/TL hierarchy), actual start date, and actual completion date with two-way synchronization between Project Tasks and Action Center Bucket Tasks.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Modules/ActionCentre/Models/BucketTask.cs`: Entity model mapped to `action.tbl_bucket_tasks`.
  - `apps/backend/Infrastructure/Persistence/Configurations/BucketTaskConfiguration.cs`: EF Core entity mapping and constraints.
  - `apps/backend/Modules/ActionCentre/DTOs/BucketTaskDtos.cs`: DTOs for bucket tasks, query filters, status updates, and timer responses.
  - `apps/backend/Modules/ActionCentre/Services/IBucketTaskService.cs`: Service interface defining query, timer, completion, and sync methods.
  - `apps/backend/Modules/ActionCentre/Services/BucketTaskService.cs`: Service implementation with search/filter, assigner resolution, timer lifecycle, and sync logic.
  - `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`: REST endpoints under `/api/v1/action-centre/bucket-list`.
- **Modified**:
  - `apps/backend/Infrastructure/Persistence/DbSchemas.cs`: Added `public const string Action = "action";`.
  - `apps/backend/Infrastructure/Persistence/AppDbContext.cs`: Registered `DbSet<BucketTask> BucketTasks`.
  - `apps/backend/Configuration/DependencyInjectionExtensions.cs`: Registered `IBucketTaskService` -> `BucketTaskService`.
  - `apps/backend/Modules/Projects/Services/ProjectTaskService.cs`: Added automatic bucket task sync (`SyncBucketTasksForTaskAsync`) invoked when task assignments are saved.
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`: Integrated two-way synchronization in `UpdateTaskStageAsync`, `StartTaskTimerAsync`, and `StopTaskTimerAsync` to sync stage, actual start date, and actual end date between node tasks and bucket tasks.
  - `apps/backend/appsettings.Development.json`: Configured to connect to `10.50.30.189:41763` (`pms_uat_clean`).

#### 🗄️ Database & Schema Changes
- **Schema Created**: `action` (on both `10.50.30.189:41763` and local fallback).
- **Table Created**: `action.tbl_bucket_tasks` with:
  - Columns: `Id` (UUID PK), `TaskId` (UUID FK -> `project.tbl_project_tasks`), `ProjectId` (UUID FK -> `project.tbl_projects`), `ProjectServiceId` (UUID FK nullable), `AssignmentId` (UUID FK nullable), `EmployeeId` (UUID FK -> `resource.tbl_employees`), `AssignedById` (UUID nullable), `AssignedByName` (varchar 200), `TaskTitle` (varchar 300), `ProjectName` (varchar 300), `Priority` (varchar 50), `DueDate` (date nullable), `Status` (varchar 100), `ActualStartDate` (date nullable), `ActualEndDate` (date nullable), `TimerRunning` (bool), `TimerStartedAtUtc` (timestamp nullable), `TimerAccumulatedSeconds` (bigint), `UtilizedHours` (numeric 8,2), `CreatedAtUtc`, `UpdatedAtUtc`, `CreatedBy`, `UpdatedBy`, `DeletedAtUtc`.
  - Constraints: Unique constraint on `("TaskId", "EmployeeId") WHERE "DeletedAtUtc" IS NULL`.
  - Indexes: B-tree indexes on `EmployeeId`, `TaskId`, `ProjectId`, `Status`, `Priority`, `DueDate`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/action-centre/bucket-list`: Returns paginated bucket list with search (`search`), status filter (`status`), priority filter (`priority`), and optional `employeeId`. Automatically scopes to the current resource if not a manager/admin.
  - `GET /api/v1/action-centre/bucket-list/{id}`: Returns bucket task details by ID.
  - `POST /api/v1/action-centre/bucket-list/{id}/start-timer`: Starts the timer, sets `TimerRunning = true`, stamps `ActualStartDate` as current date (`DateOnly.FromDateTime(DateTime.UtcNow)`), and synchronizes `Stage = Ongoing` and `ActualStartDate` on the underlying `project.tbl_project_tasks`.
  - `POST /api/v1/action-centre/bucket-list/{id}/pause-timer`: Pauses the timer, accumulates elapsed seconds, and updates `UtilizedHours`.
  - `POST /api/v1/action-centre/bucket-list/{id}/stop-timer`: Stops the timer, accumulates elapsed seconds, updates `UtilizedHours`, and updates underlying task.
  - `POST /api/v1/action-centre/bucket-list/{id}/complete`: Completes task, marks `Status = Completed`, stops any running timer, stamps `ActualEndDate` as current date on both the bucket task and the node task (`project.tbl_project_tasks`), and sets task progress to 100%.
  - `PATCH /api/v1/action-centre/bucket-list/{id}/status`: Updates task status/stage and synchronizes onto the project task.
  - `POST /api/v1/action-centre/bucket-list/sync`: Backfills/syncs all active assignments from `project.tbl_project_task_assignments` into `action.tbl_bucket_tasks`.
- **Business Logic**:
  - **Due Date Resolution**: Precedence order is parent WBS service `EndDate` -> task `PlannedEndDate` -> project `EndDate`.
  - **Assigned By Resolution**: Hierarchy resolves assigner name from `Assignment.CreatedBy` (Employee or User) -> Project `ProjectManagerId` -> Team Lead -> Engagement Manager.
  - **Service Modifications Safety**: Service additions and modifications do NOT impact assigned resources. When services are updated, only excess branches beyond the kept quantity (`AP > keepQty`) are deactivated via `DeactivateExcessTaskBranchesAsync`. Kept branches (`AP1` to `APkeepQty`), their task assignments, and bucket tasks are preserved intact.

#### ⚠️ Critical Dependencies & Invariants Preserved
- `project.tbl_projects`, `project.tbl_project_tasks`, and `project.tbl_project_task_assignments` data integrity preserved.
- Non-destructive DB migration: only added schema `action` and table `action.tbl_bucket_tasks`.
- Two-way stage updates: changes from Task Tab (`UpdateTaskStageAsync`) update Bucket Tasks, and changes from Bucket List update Node Tasks.
- Service quantity adjustments preserve existing assignments on retained branches.

### [2026-10-28] Fix Assigned Resource Profile Switching & Action Center Frontend Integration

- **Branch**: `uat_clean2`
- **Module**: Action Center (Bucket List Frontend & User Context Resolution)
- **Purpose**: Fix assigned resource profile switching so that when switching to an assigned resource's profile (e.g. Alok Deshpande, Aditi Roy, or any team member), their assigned bucket tasks are dynamically fetched and displayed with active timers and actions.

#### 📁 Files Affected
- **Created**:
  - `apps/frontend/src/modules/action-centre/api/action-centre.ts`: API client functions (`fetchBucketList`, `startBucketTaskTimer`, `pauseBucketTaskTimer`, `stopBucketTaskTimer`, `completeBucketTask`, `updateBucketTaskStatus`).
- **Modified**:
  - `apps/backend/Infrastructure/Authorization/CurrentUserService.cs`: Added fallback to `ClaimTypes.Email` in `Email` claim resolution.
  - `apps/backend/Middleware/DevelopmentAuthBypassMiddleware.cs`: Added `ClaimTypes.Email` alongside `JwtRegisteredClaimNames.Email` in identity claims.
  - `apps/backend/Modules/ActionCentre/Services/BucketTaskService.cs`: Implemented `ResolveCurrentEmployeeIdAsync` with multi-strategy resolution (`e.Id == userId`, `e.UserId == userId`, `e.WorkEmail.ToLower() == email.ToLower()`), properly scoping the bucket list to the switched employee profile.
  - `apps/frontend/src/modules/action-centre/index.ts`: Exported Action Centre API functions and types.
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`: Connected `BucketList` and `BucketListRow` to the live backend API, refetching on profile switch and executing timer actions directly against backend endpoints.

#### 🔌 APIs & Business Logic Changed
- **Employee Persona Resolution**: The backend now checks direct employee ID matching (`e.Id == _currentUser.UserId.Value`) which is sent by the frontend's persona headers (`X-User-Id`), as well as foreign key `e.UserId` and `e.WorkEmail`.
- **Frontend Live Data Binding**: `BucketList` now fetches from `GET /api/v1/action-centre/bucket-list` using `fetchBucketList` whenever the switched user/persona changes, and triggers real backend updates on start/pause/stop/complete.

#### ⚠️ Critical Dependencies & Invariants Preserved
- SuperAdmin continues to have full visibility over all tasks when no specific resource is selected.
- Each assigned resource only sees their assigned tasks in their bucket list.
- Two-way timer and task stage updates between Bucket List and Project Tasks tab remain in sync.

### [2026-10-28] Project Task Stage Confirmation & Lock, Read-Only Dates, Hover Started Status, Single Active Timer Rule & Timer Drift Fix

- **Branch**: `uat_clean2`
- **Module**: Project Tasks & Action Center Bucket List
- **Database**: PostgreSQL 16.15 (`10.50.30.189:41763` on `pms_uat_clean`)
- **Purpose**: Enforce read-only system-driven `Actual Start` and `Actual End` dates in the project task tab, display "Started" on hover for assigned resources who initiated tasks, enforce task completion confirmation modal with irreversible locking, implement the single-active-task-timer rule per resource, and fix timer drift when stage changes to "On Hold".

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Made `Actual Start` and `Actual End` cells non-editable formatted date spans.
    - Updated `AvatarStack` and hover popover to display `"Started"` with an active green pulse indicator and native hover tooltip for resources whose timer has run or is running.
    - Enforced stage locking for completed tasks: displays locked badge with checkmark (`Completed`) and disables stage modification.
    - Added task completion confirmation modal (*"Are you sure that task <Task ID> is completed?"*) prompting before transitioning to "Completed", auto-stamping `Actual End` with today's date and locking the task.
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
    - Fixed timer calculation: prevented fallback to `elapsedTimeSeconds` which previously double-counted elapsed seconds on paused/running tasks.
  - `apps/backend/Modules/ActionCentre/Services/BucketTaskService.cs`:
    - `StartBucketTaskTimerAsync`: Throws `BadRequestException` if task is already completed; implemented single-active-timer rule by automatically pausing any other running task timer for the employee.
    - `UpdateBucketTaskStatusAsync`: Throws `BadRequestException` if attempting to change stage on an already completed task; pauses active timers when moving to non-running stages (such as "On Hold").
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - `UpdateTaskStageAsync`: Throws `BadRequestException` if attempting to change an already completed task; auto-stamps `ActualEndDate = today` and `Progress = 100` on completion; pauses active bucket tasks and assignment timers when moving to non-running stages (e.g. "On Hold").
    - `StartTaskTimerAsync`: Added single-active-timer rule ensuring starting a task timer pauses any other running timer for that resource.

#### 🔌 APIs & Business Logic Changed
- **Read-Only Actual Dates**: `Actual Start` is automatically populated on backend when the resource starts the task timer; `Actual End` is automatically stamped with today's date when the stage transitions to "Completed". Neither date can be arbitrarily edited in the task table.
- **Assigned Resources Hover Status**: In the Assigned Resources column, hovering over the avatar or avatar stack displays `"Started"` (or `"Not Started"`) for each assignee based on active timer status (`isTimerRunning`, `timerStartedAtUtc`, `timerAccumulatedSeconds > 0`).
- **Completion Confirmation & Permanence**: When moving stage to "Completed", a confirmation dialog confirms the irreversible action. Once marked "Completed", it is permanently locked in both UI and backend (`BadRequestException("A completed task cannot be changed to another stage.")`).
- **Single Active Timer Rule**: When an employee starts a timer on a task in their bucket list, all other currently running timers for that employee are automatically paused, accumulating their elapsed time and updating utilized hours.
- **Timer Drift Fix**: When a task's stage transitions to "On Hold" (or any non-running stage), active timers are immediately paused and accumulated seconds are saved. Frontend live timer calculation no longer double-counts elapsed time.

#### ⚠️ Critical Dependencies & Invariants Preserved
- No destructive database alterations performed; all existing tables and data on `pms_uat_clean` remain intact.
- Two-way stage and timer synchronization between Project Task node and Bucket List row remains fully intact.
- Both frontend and backend builds compile cleanly with 0 errors.

### [2026-10-28] Timer Preservation for On Hold & Cancelled Tasks, Resumption Gating, Completed Task Locking & Database Verification

- **Branch**: `uat_clean2`
- **Module**: Action Center (Bucket List Lifecycle & Task Controls)
- **Database**: PostgreSQL 16.15 (`10.50.30.189:41763` on `pms_uat_clean`)
- **Purpose**: Prevent timer from vanishing when tasks are moved to "On Hold" or "Cancelled", keeping accumulated working time visible while paused; restrict starting or resuming tasks until stage is set back to "Ongoing"; disallow pausing or stopping "Completed" tasks; and audit/verify that all data originates directly from PostgreSQL.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
    - Updated `BucketListRow` timer block visibility condition to display whenever `r.status !== "Not Started" || workingTimeSeconds > 0 || !!r.actualStartDate`.
    - Added styled badges and sub-notices for `On Hold` (`Timer Paused (On Hold)`) and `Cancelled` (`Task Cancelled`).
    - Rendered disabled action buttons with explanatory tooltips for `On Hold` and `Cancelled` tasks, instructing users that the stage must be set to `Ongoing` in the task tab to resume.
    - Verified `Completed` tasks display only the non-actionable `Task Completed` badge with zero pause or stop controls.
    - Added `On Hold` filter button to the Bucket List status filter bar.
  - `apps/backend/Modules/ActionCentre/Services/BucketTaskService.cs`:
    - `StartBucketTaskTimerAsync`: Throws `BadRequestException` if task is `On Hold` or `Cancelled`, requiring stage to be `Ongoing`.
    - `PauseBucketTaskTimerAsync`: Throws `BadRequestException` if task is `Completed`, `On Hold`, or `Cancelled`.
    - `StopBucketTaskTimerAsync`: Throws `BadRequestException` if task is `Completed` or `Cancelled`.
    - `GetBucketTasksAsync`: Added query handling for `on_hold` and `cancelled` status filters.
    - `SyncBucketTasksFromAssignmentsAsync`: Added automatic timer reset (`TimerRunning = false`, `TimerStartedAtUtc = null`) for non-running tasks.
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - `StartTaskTimerAsync`: Rejects starting/resuming when task is `Completed`, `On Hold`, or `Cancelled`.
    - `StopTaskTimerAsync`: Rejects stopping when task is `Completed` or `Cancelled`.
    - `UpdateTaskStageAsync`: Guarantees `TimerRunning` is reset to `false` when stage transitions to non-running stages.

#### 🔌 APIs & Business Logic Changed
- **Persistent Timer Visibility**: When a task moves to `On Hold` or `Cancelled`, the timer card does not vanish. It remains visible showing recorded `Started` date, accumulated `Working Time`, and a clear paused status notice.
- **Stage Gating for Timers**: Resources cannot start or resume a task while it is `On Hold` or `Cancelled`. Starting or resuming is strictly prohibited until the stage is updated to `Ongoing` from the Project Tasks tab.
- **Completed Task Invariant**: Completed tasks cannot be paused or stopped in the UI or via API (`BadRequestException`).
- **Database Sourcing Audit**: Verified that all data displayed in the Bucket List and Project Tasks tab (tasks, projects, priorities, due dates, statuses/stages, assigners, actual start/end dates, timers, utilized hours) is 100% sourced from and persisted in PostgreSQL database `pms_uat_clean` on `10.50.30.189:41763`. Zero mock or local placeholder data.

#### ⚠️ Critical Dependencies & Invariants Preserved
- No destructive schema operations; existing data on `pms_uat_clean` preserved.
- Both frontend and backend builds compile cleanly with 0 errors and live daemons are running.

### [2026-10-28] Task Assignment Priority Field, Action Center Reflection & Unassign Confirmation Modal

- **Branch**: `uat_clean2`
- **Module**: Project Task Assignments & Action Center Bucket List
- **Database**: PostgreSQL 16.15 (`10.50.30.189:41763` on `pms_uat_clean`)
- **Purpose**: Add Priority selection (`Low`, `Medium`, `High`, `Critical`) in the Assign Task Modal, synchronize and store the chosen priority into both `project.tbl_project_tasks` and `action.tbl_bucket_tasks`, reflect the updated priority in the assigned resource's Action Center -> Bucket List column and filters, and require a confirmation prompt before deselecting or removing any resource from an assigned task.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Updated `interface TreeTask` to include `priority?: string;`.
    - Updated `applyPersistedTasks` (`mapTask`) to map task priority (`hit.priority || "Medium"`).
    - Updated `AssignTaskModal` invocation in `DhTasksTab` to pass task priority, save chosen priority via `syncTaskAssignments`, and update local task state and dhStore.
    - Added Priority selector (`Low`, `Medium`, `High`, `Critical`) to `AssignTaskModal` with distinct visual styling and selection state.
    - Added Unassign Confirmation dialog in `AssignTaskModal` that triggers whenever an already-selected resource is deselected (via clicking pill 'X' or resource row in the list), asking: *"Are you sure you want to remove <Resource Name> from the assigned task?"*.
  - `apps/frontend/src/modules/projects/api/projects.ts`:
    - Updated `syncTaskAssignments` to accept optional `priority?: string` in its signature and transmit `{ employeeIds, priority }` in the PUT body.
  - `apps/backend/Modules/Projects/DTOs/ProjectTaskAssignmentDtos.cs`:
    - Updated `SyncTaskAssignmentsRequest` record to accept optional `string? Priority = null`.
  - `apps/backend/Modules/Projects/Services/IProjectTaskService.cs`:
    - Updated `SynchronizeAssignmentsAsync` method signature to accept `string? priority = null`.
  - `apps/backend/Modules/Projects/Services/ProjectTaskService.cs`:
    - In `SynchronizeAssignmentsAsync`: When `priority` is provided, updates `task.Priority` in `project.tbl_project_tasks` and sets `UpdatedAtUtc = DateTime.UtcNow`.
    - In `SyncBucketTasksForTaskAsync`: Automatically synchronizes `Priority` across all active `BucketTasks` for the assigned task in `action.tbl_bucket_tasks`.
  - `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`:
    - In `SyncTaskAssignments` endpoint: Passed `request.Priority` to `taskService.SynchronizeAssignmentsAsync`.

#### 🗄️ Database & Schema Changes
- **Tables Verified & Updated**:
  - `project.tbl_project_tasks`: Updated column `Priority` with chosen priority level (`Low`, `Medium`, `High`, `Critical`).
  - `action.tbl_bucket_tasks`: Automatically updated column `Priority` for all bucket task entries associated with the task.

#### 🔌 APIs & Business Logic Changed
- **Endpoint**:
  - `PUT /api/v1/projects/{projectId}/tasks/{taskId}/assignments`: Accepts payload `{ "employeeIds": [...], "priority": "Low" | "Medium" | "High" | "Critical" }`.
- **Priority Synchronization**:
  - When assigning resources or updating task assignments with a priority, the backend immediately persists the priority to `project.tbl_project_tasks` and synchronizes it to all active bucket tasks in `action.tbl_bucket_tasks`.
  - In `BucketTaskService.cs`, `GetBucketTasksAsync` continues to query and filter bucket tasks by `Priority` and returns `Priority` in `BucketTaskDto`.
  - In Action Center Bucket List, the `Priority` column displays the updated priority using `PriorityPill` and responds dynamically to the priority filter dropdown.
- **Unassign Confirmation Safeguard**:
  - Attempting to remove/deselect an assigned resource from a task in the Assign Task window prompts a confirmation dialog displaying the exact resource name (*"Are you sure you want to remove [Name] from the assigned task?"*). Removal only executes if the user confirms "Yes, Remove".

#### ⚠️ Critical Dependencies & Invariants Preserved
- Preserved PostgreSQL database integrity on `pms_uat_clean` (`10.50.30.189:41763`).
- Existing assignments, timers, and leaf utilized hour distributions remain intact.
- Both frontend and backend builds compile cleanly with 0 errors (`dotnet publish` and `vite build`).
- End-to-end integration verified: tested API assignment updates across `Low`, `Medium`, `High`, and `Critical` priorities and verified immediate persistence in both `project.tbl_project_tasks` and `action.tbl_bucket_tasks`, as well as reflection in `GET /api/v1/action-centre/bucket-list`.

### [2026-10-28] Removed "Assigned" Stage, Independent Assignee Hover Status, Viewport-Safe Popover & Optimistic Start/Pause/Resume Timer Controls

- **Branch**: `uat_clean2`
- **Module**: Project Tasks Tab & Action Center Bucket List
- **Database**: PostgreSQL 16.15 (`10.50.30.189:41763` on `pms_uat_clean`)
- **Purpose**:
  1. Remove "Assigned" from the stage column options in the Project Tasks tab.
  2. Compute individual "Started" / "Not Started" status for each assigned resource on a task, so that assigning an additional resource does not mark them as started until they personally start their timer in the Action Center.
  3. Fix the Assigned Resources hover popover so that it never clips or hides off-screen near window edges/bottom and provides smooth cursor transition.
  4. In Action Center Bucket List Actions & Timer section, render initial Start and Pause (disabled) buttons, smoothly replacing Pause with Resume when clicked and Resume with Pause and Stop when resumed, with zero stutter or timer drift.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Removed `"Assigned"` from `TREE_TASK_STAGES` and stage select dropdown options.
    - Updated `DhTasksTab` assignee `started` computation to check only individual assignment timer states (`isTimerRunning`, `timerStartedAtUtc`, `timerAccumulatedSeconds > 0`, `utilizedHours > 0`), removing the shared `t.actualStartDate` fallback.
    - Updated `AvatarStack` hover tooltip with dynamic viewport collision detection (flips upward when close to bottom of screen and clamps horizontal position within viewport bounds), added a 180ms mouse-leave transition buffer, and eliminated conflicting browser native tooltip attributes.
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
    - Added `useCallback` and `useRef` to React imports, resolving runtime `ReferenceError: useCallback is not defined`.
    - Updated `BucketListRow` to introduce optimistic local state (`localStatus`, `localTimerRunning`, `localAccumulatedSeconds`, `localTimerStartedAt`).
    - Added initial dual-button layout for unstarted tasks: active **Start** button and disabled **Pause** button.
    - Added instant button replacement: clicking **Pause** immediately freezes timer and smoothly renders **Resume** + **Stop**; clicking **Resume** immediately resumes timer counting from paused elapsed time and renders **Pause** + **Stop**.
  - `apps/backend/Modules/ActionCentre/Services/BucketTaskService.cs`:
    - In `StartBucketTaskTimerAsync`: Added support for transitioning tasks from `"Stopped"` to `"Ongoing"`, smoothly restarting the timer on stopped tasks.

#### 🔌 APIs & Business Logic Changed
- **Removed "Assigned" Stage**: The stage dropdown in the task tab now strictly presents valid operational stages (`Ongoing`, `On Hold`, `Cancelled`, `Completed`), eliminating "Assigned".
- **Independent Assignee Started Tracking**: Multiple resources assigned to the same task are evaluated independently. If Resource A starts their timer, only Resource A shows green "Started" badge on hover; Resource B continues to show "Not Started" until Resource B personally initiates the timer from their own Action Center bucket list.
- **Viewport-Safe Hover Tooltip**: `AvatarStack` tooltip window detects screen coordinates and automatically flips above the cursor if positioned near the viewport bottom, clamping horizontally to prevent being hidden or clipped off-screen.
- **Optimistic Smooth Timer Actions**: In Action Center Bucket List, clicking Pause or Resume immediately transitions local state and timer ticking without waiting for network roundtrip, preventing UI stutter or timer jumps.

#### ⚠️ Critical Dependencies & Invariants Preserved
- Database integrity on `pms_uat_clean` (`10.50.30.189:41763`) preserved.
- Two-way stage synchronization between Project Tasks and Action Center Bucket Tasks preserved.
- Both frontend and backend builds compile cleanly with 0 errors (`dotnet publish` and `vite build`).
- Live backend daemon (port 5194) and frontend dev server (port 3000) verified running and healthy.

### [2026-10-28] Resume Button Visibility for Paused Tasks & Zero-Flicker Action Center Updates

- **Branch**: `uat_clean2`
- **Module**: Action Center (Bucket List Controls & Lifecycle)
- **Database**: PostgreSQL 16.15 (`10.50.30.189:41763` on `pms_uat_clean`)
- **Purpose**: Fix issue where paused task working time did not show the "Resume" button (due to background status overwriting and condition gating), and eliminate page/table blinking on start/pause/resume/stop actions by decoupling in-place row state updates from full-table loading states.

#### 📁 Files Affected
- **Modified**:
  - `apps/backend/Modules/ActionCentre/Services/BucketTaskService.cs`:
    - In `SyncBucketTasksFromAssignmentsAsync`: Prevented `task.Stage` ("Ongoing") from clobbering an individual resource's `bucketTask.Status` when it is `"Paused"` or `"Stopped"`.
    - Added self-healing: if a bucket task was `"Ongoing"` but `TimerRunning == false` with accumulated seconds, automatically maps it to `"Paused"`.
    - Preserved `ActualStartDate` scoping so newly assigned resources on an ongoing task remain `null` until they start their own timer.
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
    - In `UpdateTaskStageAsync`: Preserved individual `"Paused"` / `"Stopped"` status on bucket tasks when a project moves to `"Ongoing"`.
    - In `StopTaskTimerAsync`: Sets `bucketTask.Status = "Paused"`.
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
    - Updated `BucketListRow` action buttons logic: whenever a task's timer is not running and has accumulated working time (or is `"Paused"`/`"Stopped"`), it always renders the active **`Resume`** button (alongside Stop).
    - When running, it always renders **`Pause`** and **`Stop`**.
    - Updated status pill to compute `displayStatus` dynamically (`"Ongoing"` when timer is running, `"Paused"` when timer is paused/stopped with accumulated time).
    - In `BucketList`: Added `onUpdateRow` callback to update table rows in-place when timer actions resolve without re-mounting the table.
    - Updated `loadData(showLoader = false)` so background silent refreshes do not trigger `setLoading(true)`, completely eliminating full page / table blinking and flicker on button clicks.

#### 🔌 APIs & Business Logic Changed
- **Guaranteed Resume Button Availability**: When an employee pauses a task, `displayStatus` resolves to `"Paused"` and the UI prominently displays the **`Resume`** button. Clicking Resume immediately restarts the timer, switches to Ongoing, and renders Pause and Stop without network lag.
- **Zero-Blink Optimistic Updates**: Button clicks (Start, Pause, Resume, Stop) update row state locally and in `apiTasks` state immediately without unmounting `<tbody>` or displaying the `<Loader2 />` table overlay. Full-table loader is now strictly reserved for initial mount and filter changes.

#### ⚠️ Critical Dependencies & Invariants Preserved
- Database integrity on `pms_uat_clean` (`10.50.30.189:41763`) preserved.
- Two-way synchronization between Project Tasks and Action Center Bucket Tasks preserved.
- Both frontend and backend builds compile cleanly with 0 errors (`dotnet publish` and `vite build`).
- Live backend daemon (port 5194) and frontend dev server (port 3000) verified running and healthy.


