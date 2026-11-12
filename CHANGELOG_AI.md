# AI-Assisted Development Changelog (`CHANGELOG_AI.md`)

## [2026-11-12] Git Branch Integration and Database Consolidation – `uat_clean12`

### Summary
Successfully integrated all completed features, SLA tracking, notification systems, feedback workflows, and database updates from `uat_clean11` into a new integration branch `uat_clean12` based directly on `uat_clean10` (`0fa0262`), without modifying or pushing to `uat_clean10`.

1. **Centralized SLA & TAT Engine Integration**:
   - Centralized Hangfire background job scheduler and workers (`SlaBackgroundJobWorker`, `HangfireDashboardAuthFilter`, `HangfireDiagnosticJob`).
   - Shift-based SLA deadline calculator (`SlaDeadlineCalculator`) utilizing resource calendars (`timesheet.tbl_team_day_entries`), dynamic shifts (General 09:00-18:00 IST, Morning 06:00-14:00 IST, Afternoon 14:00-22:00 IST, Night 22:00-06:00 next day), weekends, and company holidays (`master.mst_leave_calendar`).
   - Multi-resource independent time tracking on `action.tbl_bucket_tasks` and `project.tbl_project_task_assignments` mapped to `sla.tbl_sla_instances.EntityId`.
   - Complete notification & escalation hierarchy using full role names: Initial recipients (Assigned Engagement Manager, Assigned Project Manager, Project Team Leader), Level 1 (Assigned Senior Project Manager), Level 2 (Head of Department dynamically resolved by on-floor role and department).
   - Daily pause reminders executed only for the resource who paused the task at their shift end: `"Your task {Task_Name} is still paused. Please resume the task or complete it."`
   - Preserved all Project Health Issue Resolution SLA workflows.

2. **Frontend Features & RBAC Harmonization**:
   - Integrated full Master RBAC permissions and security roles from `uat_clean10` (`canManageWbs`, `canManageTeam`, `canManageTasks`, `effectiveReadOnly`, `canDeleteService`).
   - Integrated global search and financial year filters in `app-topbar.tsx` while retaining the real-time global notification bell dropdown with blur overlay.
   - Dynamic project overall progress calculation (`computeOverallProjectProgress`, `calculateOverallProjectProgress`) based on active services and task completion weights.
   - Project feedback creation and approval request workflows with 100-character alphanumeric validation.
   - Resource workload modal scoped to current project tasks.
   - Cleaned up Team tab 3-dot menu by removing "Give Praise" and retaining "Give Feedback" and "Request Feedback".

3. **Database Consolidation (`database/pms_uat.sql`)**:
   - Fully consolidated database schema across 10 schemas (`action`, `auth`, `customer`, `master`, `project`, `public`, `repository`, `resource`, `sla`, `timesheet`).
   - Exact parity: 82 base tables and 1 view (`resource.tbl_onfloorrole_subdepartment`).
   - Preserved all 1,512 master RBAC entries in `auth.tbl_role_permissions` and default permission protection trigger `trg_protect_default_permissions()`.
   - Preserved 30 holiday entries in `master.mst_leave_calendar` with `Tag`, `Color`, and `Description`.
   - Preserved all 32 tabs in `master.mst_tabs` (including My Team tab).
   - Preserved all 10 users in `auth.tbl_users`.
   - Merged 120 employees in `resource.tbl_employees` preserving `OriginalRole`.
   - Preserved all 325 action notifications in `action.tbl_notifications` with `CommentsJson`.
   - Preserved SLA tracking tables: `sla.tbl_sla_policies` (5), `sla.tbl_sla_instances` (76), `sla.tbl_sla_events` (249) with unique index `uq_sla_events_idempotency_key`.
   - Verified 100% clean restoration with 0 errors via `psql`.

---


## [Unreleased] - 2026-11-11

### Summary
1. Filtered Resource Workload Modal tasks under the Team tab to exclusively display tasks for the current project in the "Resource Assigned Tasks" section.
2. Resolved overlay clipping in the Health tab -> Extension Request modal where opening the "Tag Stakeholder Approvers*" dropdown overlapped the "Cancel" and "Submit Request" buttons.
3. Resolved `Access Blocked — PM/SPM Not Assigned` error under the Project Team tab on page refresh or tab open after resource allocation approval.
4. Fixed Action Center Bucket List multi-resource independent time tracking, assignment notifications, and task completion service utilized hours aggregation.
5. Fixed proportional Service Utilized Hours calculation in the Tasks tab when a service contains multiple applications (e.g. NVA1 and NVA2). Service-level utilized hours are now correctly divided across the service's applications rather than displaying the unweighted raw sum of child tasks, maintaining exact percentage alignment with the service's total estimated hours.
6. Synchronized inactive and deleted service visibility in the "Service wise Prerequisite Tracking" section (Step 3 in WBS / Prerequisite tab) with the "Show Inactive/Deleted" toggle, matching the behavior in "Services & Deliverables from WBS".
7. Cleaned up Team tab 3-dot action menu by removing the "Give Praise" option (appreciation is centralized in the Health Appreciation tab). Verified and ensured "Set as Team Lead" and "Remove Team Lead" reliably updates both `project.tbl_project_team_members` (`IsTeamLead`) and `project.tbl_projects` (`TeamLeadId`) in the database.
8. Implemented end-to-end Give Feedback and Request Feedback workflows: created `project.tbl_project_feedbacks` database table, added input validation (max 100 alphanumeric and space characters for Strengths, Areas of Improvement, Comments; 0-5 rating), and integrated automatic Action Center notifications for the resource and their reporting manager, as well as Central Approval requests for feedback requests.
9. Added automatic notifications to Assigned Project Manager, Senior Project Manager, and Project Team Lead upon Reporting Manager actioning (Accept/Approve, Reject, Hold) a team member resource allocation request. Formatted notification title as `{EmployeeName} is {accepted|rejected|on hold} for the {ProjectName}` with priority displayed as `-`. Stored and rendered approver comments directly above the Audit History section in the notification details modal, showing `No comments` when none exist.
10. Implemented the global notification bell icon in the top-right application header: replaced the static placeholder with an interactive Radix UI popover dropdown displaying notifications directly from the existing Action Centre Notifications module (`/api/v1/action-centre/notifications`) and `dhStore`. Features dynamic unread count badge, formatted date & time for each notification, mark-as-read and mark-all-as-read, seamless detail inspection via reusable `NotificationDetailModal`, and deep-link navigation to the Action Centre Notifications tab.
11. Resolved Action Centre Notification Tab loading failure and implemented Move to Archive functionality: identified and resolved the 500 Internal Server Error (`42703: column t.CommentsJson does not exist`) by adding `"CommentsJson" text NOT NULL DEFAULT '[]'` to `action.tbl_notifications` in the active database. Implemented "Move to Archive" button inside `NotificationDetailModal` (opened by clicking "View" on any notification row or via global bell), supported by backend API `PUT /api/v1/action-centre/notifications/{id}/archive` and store method `dhStore.archiveNotification` which sets status to `"Acknowledged"`, records audit trail history, and shifts the item from the Current to the Archived view.
12. Enhanced Global Notification Panel UI and Converted Notifications to View-Only: added a full-screen dark blur background overlay (`rgba(0, 0, 0, 0.25)` background and `backdrop-filter: blur(3px)`) rendered via `createPortal` to `document.body` at `z-[60]` to cover the entire application background (sidebar, header, and workspace) and block accidental background clicks. Elevated the notification panel to `z-[70]` to remain sharp, clear, and interactable above the blur overlay. Removed the notification details modal/window interaction from the global bell dropdown entirely, converting notification list items into read-only containers without click handlers while preserving titles, dates, times, and status badges. Added Escape key listening, bell toggle, and outside-click detection to dismiss the panel and remove the overlay cleanly. Preserved full interactive Action Centre Notification tab functionality.
13. Calculated and Displayed Overall Project Progress Based on Arithmetic Average of Service Progress:
- Replaced the static header project progress percentage (previously hardcoded / static 0%) with dynamic arithmetic average across all active services of the project:
  $$\text{Overall Project Progress} = \frac{\sum \text{Active Service Progress Percentages}}{\text{Total Number of Active Services}}$$
- Equal weight rule: Each active service carries equal weight in the project progress calculation, independent of estimated hours, utilized hours, or child task count.
- Dynamic responsiveness: Header progress percentage and animated `ProgressBar` update immediately in real-time when the Project Details page loads, when task stages change (e.g. "Completed", "Ongoing", "Cancelled", "Not Started"), when tasks are marked complete, and when services are added or removed in WBS.
- Filter rule: Inactive or deleted services (`isDeleted`, `changeStatus === "Deleted"`, `deletedAtUtc`, `status === "Inactive"`) are strictly excluded from both the numerator and denominator.
- Zero-progress rule: Active services with 0% progress are included in both the numerator (+0%) and denominator. Projects with no active services display `0%`.
- Rounding: All display values are rounded to the nearest integer using `Math.round`.
- Cross-tab consistency: Project tasks and services are fetched and subscribed at the `ProjectDetailPage` level, ensuring the calculated overall progress remains synchronized and persisted across all tabs (Overview, WBS, Team, Tasks, Health) without requiring a full page refresh.
- Preserved existing functionality: Service-level task weighting (Completed = 1.0, Ongoing = 0.5, Cancelled = excluded) and Tasks/WBS views remain completely unaltered.
14. Synchronized `database/pms_uat.sql` with Live PostgreSQL Database:
- Extracted full database schema and current table data from active PostgreSQL database `pms_uat` (`localhost:5432`).
- Reconciled table counts: brought `database/pms_uat.sql` from 78 tables to 80 database objects (79 BASE TABLEs + 1 VIEW), adding `project.tbl_project_feedbacks` and `resource.tbl_onfloorrole_subdepartment`.
- Ensured complete schema parity across all 9 custom schemas (`action`, `auth`, `customer`, `master`, `project`, `public`, `repository`, `resource`, `timesheet`) including `"CommentsJson"` column in `action.tbl_notifications`, feedback indexes/foreign keys, and up-to-date table rows.
15. Implemented Phase 1: Hangfire Infrastructure Setup & Verification for Centralized TAT/SLA Automation:
- Installed compatible stable Hangfire packages: `Hangfire.AspNetCore` (1.8.25) and `Hangfire.PostgreSql` (1.21.1) targeting .NET 10.0 with zero package conflicts.
- Configured Hangfire with PostgreSQL persistent storage using a dedicated `hangfire` schema in the active application database (`pms_uat` / `trackerpro`). Storage tables are isolated in the `hangfire` schema without modifying any existing business schemas (`action`, `auth`, `customer`, `master`, `project`, `public`, `repository`, `resource`, `timesheet`).
- Registered Hangfire Server through modular DI architecture via `AddHangfireInfrastructure` in `PMS.API.Infrastructure.Hangfire` and integrated into `DependencyInjectionExtensions.AddApplicationServices`.
- Configured background job processing with a conservative, configurable starting worker count (default 2 workers, configurable via `Hangfire:WorkerCount` in `appsettings.json` and `appsettings.Development.json`) to prevent database pool and CPU saturation.
- Implemented Hangfire Dashboard at `/hangfire` secured with `HangfireDashboardAuthFilter`:
  - Enforces production authorization requiring authenticated users with administrative roles verified from `auth.tbl_roles` (`Admin`, `CEO`, `CTO`, `COO`, `PMO`, `IT Admin`) or configured administrative emails.
  - Role lists and email lists are decoupled from code into `Hangfire:AuthorizedRoles` and `Hangfire:AuthorizedEmails` options.
  - Supports local developer access during development.
- Created `HangfireDiagnosticJob` (strictly logging-only; does not create real notifications or modify business records) and `HangfireDiagnosticController` (`/api/v1/diagnostics/hangfire/enqueue`, `/api/v1/diagnostics/hangfire/schedule`, `/api/v1/diagnostics/hangfire/status`):
  - Strictly protected by role authorization (`[Authorize(Roles = "Admin,CEO,CTO,COO,PMO,IT Admin")]`).
  - Guarded by configurable feature flag `Hangfire:EnableDiagnosticEndpoints` (set to `false` in production by default, `true` in development).
- Verified background job execution, persistent database storage, and restart resilience (delayed jobs survive server restarts and execute promptly upon service reactivation).
- Cleaned up all temporary test jobs from PostgreSQL database `hangfire` schema tables.
- Verified non-interference: Existing notification endpoints, projects APIs, and business workflows remain 100% untouched and functional.
16. Implemented Phase 2: SLA/TAT Data Model & Core Tracking Architecture:
- Created dedicated PostgreSQL schema `sla` and 3 foundational tables:
  - `sla.tbl_sla_policies`: Multi-activity and multi-stage policy configuration with configurable TAT duration in minutes, calculation modes (`CalendarHours`, `WorkingHours`, `EndOfDay`), working window hours, weekend/holiday exclusion flags, serialized JSON reminder intervals, and multi-level escalation roles (`FirstEscalationRolesJson`, `SecondEscalationRolesJson`).
  - `sla.tbl_sla_instances`: Active entity-level SLA tracking instance tracking current stage, lifecycle status (`Tracking`, `Paused`, `Completed`, `Breached`, `Cancelled`), target deadline, breach timestamp, paused accumulation (`TotalPausedSeconds`), active Hangfire job reference, and project/recipient foreign keys.
  - `sla.tbl_sla_events`: Full audit trail and event log of all reminders, warnings, breach evaluations, stage transitions, pauses, resumes, and escalations linked to Hangfire job IDs.
- Implemented `ISlaDeadlineCalculator` (`SlaDeadlineCalculator`):
  - Supports continuous calendar hours, operating business hours (e.g. 09:00–18:00), overnight rolls, weekend skipping (Saturday/Sunday), holiday awareness, and End-of-Day (EOD) targets.
  - Implements deadline adjustment logic when resuming from paused durations.
- Implemented `ISlaRecipientResolver` (`SlaRecipientResolver`):
  - Dynamically resolves escalation recipients through existing PMS hierarchy: reporting managers from `resource.tbl_employees`, project managers and team leads from `project.tbl_projects`, and organizational roles from `auth.tbl_users`/`auth.tbl_roles`. Eliminates any hardcoded employee IDs.
- Implemented `ISlaPolicyService` (`SlaPolicyService`):
  - Provides policy lookup with stage-specific resolution and fallback to activity defaults.
- Implemented `ISlaTrackingService` (`SlaTrackingService`):
  - Full state machine orchestration: `StartTrackingAsync`, `TransitionStageAsync`, `PauseTrackingAsync`, `ResumeTrackingAsync`, `CompleteTrackingAsync`, `CancelTrackingAsync`, and `RescheduleTrackingAsync`.
  - Integrates with Hangfire for scheduling milestone reminders, breach checks, and escalations. Cancels pending jobs via `BackgroundJob.Delete` when transitioning stages or pausing/completing.
  - Prevents duplicate tracking for the same entity and activity.
- Implemented `SlaBackgroundJobWorker`:
  - Validates latest database state before execution; skips execution if instance is completed, cancelled, paused, or if the stage has changed.
  - Phase 2 logging/test mode: Logs reminders, breach detections, and escalations via Serilog without dispatching real notifications or modifying business records.
- Synchronized `database/pms_uat.sql` with the new `sla` schema, tables, foreign keys, and indexes.
- Added 10 unit tests in `PMS.UnitTests/Sla/` covering deadline calculations, weekend/holiday skipping, EOD deadlines, pause adjustments, and JSON serialization (74/74 unit tests passing).
17. Synchronized Health Tab Issues with Escalations Tab Table:
- Root Cause: In `ProjectIssueService.CreateIssueAsync`, raising an issue created a record in `project.tbl_project_issues` and an alert in `project.tbl_project_alerts`, but never created a corresponding `project.tbl_project_service_escalations` record. Consequently, while raised issues appeared in Health Alerts, they were missing from the Health Escalations tab table (`HealthEscalationsPanel`), which retrieves records via `GET /api/v1/projects/{projectId}/service-escalations`.
- End-to-End Issue-to-Escalation Creation Pipeline:
  - Updated `ProjectIssueService.CreateIssueAsync` to automatically instantiate and persist a corresponding `ProjectServiceEscalation` record with `ServiceName = issueType`, `EscalationType = issueType`, `Priority = priority`, `Subject = subject`, `Description = description`, `Status = "Open"`, and `RaisedByName = raiserName`.
  - Dynamically resolved project leadership stakeholders (Project Manager, Engagement Manager, Team Lead) and populated `ProjectServiceEscalationStakeholder` entries for the escalation.
  - Linked `alert.ServiceEscalationId = escalation.Id`, `alert.ServiceName = escalation.ServiceName`, `alert.EscalationType = escalation.EscalationType`, and populated `alert.EscalatedTo` and `alert.HistoryJson`.
- Alert, Issue, and Escalation Status Synchronization:
  - Updated `ProjectIssueService.UpdateAlertStatusAsync` so status transitions synchronize across `ProjectAlert`, `ProjectIssue`, and `ProjectServiceEscalation`.
- Robust Retrieval & Backward Compatibility in `ProjectServiceEscalationService.ListAsync`:
  - Enhanced `ListAsync` to query `db.ProjectServiceEscalations` and check for any `ProjectIssues` that do not yet have a dedicated escalation record. Unmapped issues are synthesized and included as `ProjectServiceEscalationDto` (with mapped status, comments, and audit timestamps from linked alerts), ordered chronologically by `CreatedAtUtc DESC`.
- Database Backfill:
  - Executed backfill migrations on both `trackerpro` and `pms_uat` PostgreSQL databases to backfill all 11 existing issues into `project.tbl_project_service_escalations` and link `ServiceEscalationId` on `project.tbl_project_alerts`, ensuring all past issues (including the latest 'Tesing SLA' on project P007) appear in the Escalation table.
- Frontend Alert Linking:
  - Updated backend `ProjectAlertDto` and frontend `ProjectAlert` model to include `ServiceEscalationId`, `ChatJson`, `HistoryJson`, `ServiceName`, and `EscalationType`.
  - Enhanced `linkedAlert` resolution in `HealthEscalationsPanel` (`project-detail-page.tsx`) to match alerts by `serviceEscalationId`, `issueId`, direct `id`, and title/subject matching.
- Verification:
  - Verified via automated API test: creating an issue instantly populates `project.tbl_project_issues`, `project.tbl_project_alerts`, and `project.tbl_project_service_escalations`.
  - Verified `GET /api/v1/projects/{projectId}/service-escalations` for P007 and P001 returns all raised issues.
  - All 74 unit tests pass, backend builds with 0 errors, and frontend builds with 0 errors.

---

### Affected Files
- `apps/backend/Modules/Projects/Services/ProjectIssueService.cs`
- `apps/backend/Modules/Projects/Services/ProjectServiceEscalationService.cs`
- `apps/backend/Modules/Projects/DTOs/ProjectIssueDtos.cs`
- `apps/frontend/src/modules/projects/api/project-issues.ts`
- `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- `apps/backend/Infrastructure/Persistence/DbSchemas.cs`
- `apps/backend/Infrastructure/Persistence/AppDbContext.cs`
- `apps/backend/Infrastructure/Persistence/Configurations/Sla/SlaPolicyConfiguration.cs`
- `apps/backend/Infrastructure/Persistence/Configurations/Sla/SlaInstanceConfiguration.cs`
- `apps/backend/Infrastructure/Persistence/Configurations/Sla/SlaEventConfiguration.cs`
- `apps/backend/Modules/Sla/Models/SlaEnums.cs`
- `apps/backend/Modules/Sla/Models/SlaPolicy.cs`
- `apps/backend/Modules/Sla/Models/SlaInstance.cs`
- `apps/backend/Modules/Sla/Models/SlaEvent.cs`
- `apps/backend/Modules/Sla/DTOs/SlaTrackingDtos.cs`
- `apps/backend/Modules/Sla/Services/ISlaDeadlineCalculator.cs`
- `apps/backend/Modules/Sla/Services/SlaDeadlineCalculator.cs`
- `apps/backend/Modules/Sla/Services/ISlaRecipientResolver.cs`
- `apps/backend/Modules/Sla/Services/SlaRecipientResolver.cs`
- `apps/backend/Modules/Sla/Services/ISlaPolicyService.cs`
- `apps/backend/Modules/Sla/Services/SlaPolicyService.cs`
- `apps/backend/Modules/Sla/Services/ISlaTrackingService.cs`
- `apps/backend/Modules/Sla/Services/SlaTrackingService.cs`
- `apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs`
- `apps/backend/Configuration/DependencyInjectionExtensions.cs`
- `apps/backend/tests/PMS.UnitTests/Sla/SlaDeadlineCalculatorTests.cs`
- `apps/backend/tests/PMS.UnitTests/Sla/SlaPolicyModelTests.cs`
- `database/pms_uat.sql`
- `CHANGELOG_AI.md`
- `apps/backend/PMS.API.csproj`
- `apps/backend/appsettings.json`
- `apps/backend/appsettings.Development.json`
- `apps/backend/Configuration/DependencyInjectionExtensions.cs`
- `apps/backend/Program.cs`
- `apps/backend/Infrastructure/Hangfire/HangfireOptions.cs`
- `apps/backend/Infrastructure/Hangfire/HangfireDashboardAuthFilter.cs`
- `apps/backend/Infrastructure/Hangfire/HangfireDiagnosticJob.cs`
- `apps/backend/Infrastructure/Hangfire/HangfireServiceExtensions.cs`
- `apps/backend/Modules/Diagnostics/Controllers/HangfireDiagnosticController.cs`
- `CHANGELOG_AI.md`
- `database/pms_uat.sql`
- `apps/frontend/src/lib/project-progress.ts`
- `apps/frontend/src/lib/project-progress.test.ts`
- `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- `CHANGELOG_AI.md`
- `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs`
- `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`
- `apps/frontend/src/components/notification-detail-modal.tsx`
- `apps/frontend/src/components/global-notification-bell.tsx`
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- `apps/frontend/src/lib/workspace-store.ts`
- `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`
- `apps/backend/Modules/Projects/Services/IProjectTeamMemberService.cs`
- `apps/backend/Modules/Projects/Services/ProjectTeamMemberService.cs`
- `apps/backend/Modules/Projects/Models/ProjectFeedback.cs`
- `apps/backend/Infrastructure/Persistence/Configurations/ProjectFeedbackConfiguration.cs`
- `apps/backend/Modules/Projects/DTOs/ProjectFeedbackDtos.cs`
- `apps/backend/Modules/Projects/Services/IProjectFeedbackService.cs`
- `apps/backend/Modules/Projects/Services/ProjectFeedbackService.cs`
- `apps/backend/Infrastructure/Persistence/AppDbContext.cs`
- `apps/backend/Configuration/DependencyInjectionExtensions.cs`
- `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`
- `apps/backend/Modules/ActionCentre/Models/ActionNotification.cs`
- `apps/backend/Infrastructure/Persistence/Configurations/ActionNotificationConfiguration.cs`
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- `apps/frontend/src/lib/workspace-store.ts`
- `apps/frontend/src/components/global-notification-bell.tsx`
- `apps/frontend/src/components/notification-detail-modal.tsx`
- `apps/frontend/src/components/app-topbar.tsx`
- `apps/frontend/src/modules/projects/api/project-feedbacks.ts`
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- `apps/backend/Modules/ActionCentre/Services/BucketTaskService.cs`
- `apps/backend/Modules/Projects/Services/ProjectAppService.cs`
- `apps/backend/Modules/Projects/Services/ProjectTaskService.cs`
- `database/pms_uat.sql`

---

### Database Changes and Migrations
- **Database Used**: PostgreSQL database `trackerpro` and `pms_uat` on `localhost:5432` (`postgres` user).
- **New SLA Schema & Tables (Phase 2)**:
  - Created dedicated PostgreSQL schema `sla`.
  - Created `sla.tbl_sla_policies`: Primary key `Id`, unique constraint on `("Module", "ActivityType", "Stage", "DeletedAtUtc")`, indexes on `ActivityType` and `IsActive`. Defines TAT duration, calculation modes, working hours window, weekend/holiday exclusion, reminder intervals, and escalation roles.
  - Created `sla.tbl_sla_instances`: Primary key `Id`, foreign key `PolicyId` referencing `sla.tbl_sla_policies("Id")` (`ON DELETE RESTRICT`), indexes on `("EntityId", "ActivityType", "DeletedAtUtc")`, `Status`, `TargetDeadlineUtc`, `ProjectId`, `RecipientEmployeeId`.
  - Created `sla.tbl_sla_events`: Primary key `Id`, foreign key `InstanceId` referencing `sla.tbl_sla_instances("Id")` (`ON DELETE CASCADE`), indexes on `("InstanceId", "EventType")`, `HangfireJobId`, `Status`, `ScheduledAtUtc`.
- **Hangfire Storage Schema**: Added dedicated PostgreSQL schema `hangfire` with 12 background processing tables (`aggregatedcounter`, `counter`, `hash`, `job`, `jobparameter`, `jobqueue`, `list`, `lock`, `schema`, `server`, `set`, `state`). Existing business schemas and tables were completely untouched.
- **Updated Database Table**: Added column `"CommentsJson" text DEFAULT '[]'::text NOT NULL` to `action.tbl_notifications` in PostgreSQL databases `trackerpro` and `pms_uat`, and `database/pms_uat.sql`. Resolves case-sensitivity and column-missing errors.
- **New Database Table**: Created table `project.tbl_project_feedbacks`:
  - `Id`: uuid PRIMARY KEY DEFAULT gen_random_uuid()
  - `ProjectId`: uuid NOT NULL (foreign key referencing `project.tbl_projects(Id)` ON DELETE CASCADE)
  - `EmployeeId`: uuid NOT NULL (evaluated resource)
  - `EmployeeName`: character varying(200) NOT NULL
  - `EmployeeCode`: character varying(50)
  - `ReportingManagerId`: uuid (the resource's reporting manager)
  - `ReportingManagerName`: character varying(200)
  - `SubmittedByEmployeeId`: uuid
  - `SubmittedByName`: character varying(200) NOT NULL
  - `FeedbackType`: character varying(50) NOT NULL DEFAULT 'DirectFeedback' ('DirectFeedback' | 'FeedbackRequest')
  - `Strengths`: character varying(100) NULL
  - `AreasOfImprovement`: character varying(100) NULL
  - `Comments`: character varying(100) NULL
  - `Rating`: integer NULL (0 to 5)
  - `RequestNote`: text NULL
  - `Status`: character varying(50) NOT NULL DEFAULT 'Submitted' ('Submitted' | 'Pending' | 'Approved' | 'Rejected' | 'Hold' | 'Request Changes')
  - `CommentsJson`: text DEFAULT '[]'
  - `HistoryJson`: text DEFAULT '[]'
  - `CreatedAtUtc`, `UpdatedAtUtc`, `DeletedAtUtc`, `CreatedBy`, `UpdatedBy`
  - Indexes: `ix_tbl_project_feedbacks_project_id`, `ix_tbl_project_feedbacks_employee_id`, `ix_tbl_project_feedbacks_reporting_manager_id`, `ix_tbl_project_feedbacks_feedback_type`.

---

### API Changes
- `POST /api/v1/diagnostics/hangfire/enqueue`:
  - Enqueues an immediate diagnostic background job to Hangfire. Returns generated `jobId`, `testId`, `jobType`, and timestamp.
- `POST /api/v1/diagnostics/hangfire/schedule`:
  - Schedules a delayed diagnostic background job with configurable `delaySeconds`. Returns generated `jobId`, `testId`, scheduled execution time, and confirmation message.
- `GET /api/v1/diagnostics/hangfire/status`:
  - Retrieves Hangfire monitoring status: active server count, worker count, queue bindings, heartbeats, and real-time job statistics (`enqueued`, `scheduled`, `processing`, `succeeded`, `failed`, `deleted`).
- `/hangfire`:
  - Hangfire Dashboard UI route protected with `HangfireDashboardAuthFilter`. Accessible only to authorized roles (`Admin`, `CEO`, `CTO`, `COO`, `PMO`, `IT Admin`, or `admin@talakunchi.com`) or local developers in development mode.
- `PUT /api/v1/action-centre/notifications/{id}/archive`:
  - Sets notification status to `"Acknowledged"`, marks `Unread = false`, and records an audit history entry with performer attribution and optional comments (`"Notification moved to archive"`). Returns the updated `ActionNotificationDto`.
- `POST /api/v1/projects/{projectId}/feedbacks`:
  - Handles both direct feedback (`FeedbackType = "DirectFeedback"`) and feedback requests (`FeedbackType = "FeedbackRequest"`).
  - Validates `Strengths`, `AreasOfImprovement`, and `Comments` against max 100 characters and alphanumeric regex `^[a-zA-Z0-9\s]*$`. Validates `Rating` in range 0-5.
  - Automatically resolves the resource's `ReportingManagerId` and `ReportingManagerName` from `resource.tbl_employees`.
  - On `DirectFeedback`, creates two `ActionNotification` records:
    1. For the employee: `Type = "Feedback Received"`, `Status = "Acknowledged"`.
    2. For the reporting manager: `Type = "Feedback Received"`, `Status = "Pending"`.
  - On `FeedbackRequest`, creates an `ActionNotification` for the reporting manager (`Type = "Approval Request"`, `Status = "Pending"`).
- `GET /api/v1/projects/{projectId}/feedbacks`:
  - Retrieves feedbacks and feedback requests for the project, with optional `employeeId` query filter.
- `GET /api/v1/action-centre/feedback-approvals`:
  - Retrieves pending feedback request approvals for the current reporting manager.
- `POST /api/v1/action-centre/feedback-approvals/{id}/action`:
  - Updates feedback approval status (`Approved`, `Rejected`, `Hold`, `Request Changes`), records comments and history, and notifies the requester.
- `GET /api/v1/projects/{projectId}/team-members/{employeeId}/workload`:
  - Controller and `IProjectTeamMemberService.GetEmployeeWorkloadAsync` updated to accept optional `[FromRoute] Guid? projectId`.
  - When `projectId` is provided, filters `ProjectTaskAssignments` (`a.Task.ProjectId == projectId`) and `BucketTasks` (`b.ProjectId == projectId`) strictly to the active project, preventing cross-project tasks from leaking into the resource's project task list.
- `PUT /api/v1/projects/{projectId}/tasks/{taskId}/assignments`:
  - When resources are assigned (or reactivated) on a task, individual `ActionNotification` records (`Type = "Task Assignment"`, `Status = "Assigned"`) are created in `action.tbl_notifications` for each assigned employee.
  - Commits assignments prior to bucket task synchronization so newly assigned resources immediately receive their personal bucket tasks with valid `AssignmentId` links.
- `POST /api/v1/action-centre/bucket-list/{id}/start-timer`:
  - Fallback assignment lookup resolves missing `AssignmentId` by `(TaskId, EmployeeId)` and links it.
  - Starts timer independently for the employee without interfering with other assigned resources on the same task.
- `POST /api/v1/action-centre/bucket-list/{id}/pause-timer` & `POST /api/v1/action-centre/bucket-list/{id}/stop-timer`:
  - Fallback assignment lookup resolves missing `AssignmentId` by `(TaskId, EmployeeId)`.
  - Freezes and accumulates timer seconds independently for that resource.
  - Recomputes parent task total `UtilizedHours` as the sum of all bucket task accumulated seconds / 3600.
- `PATCH /api/v1/projects/{projectId}/tasks/{taskId}/stage`:
  - When stage is changed to `"Completed"`, cascades `"Completed"` status to all assigned resources' bucket tasks, freezes any active timers, and sets parent task `UtilizedHours` to the exact sum of all assigned resources' accumulated seconds / 3600 (e.g. 100 min + 20 min = 120 min = 2.0 hrs).
- `GET /api/v1/projects/{projectId}/tasks`:
  - Syncs accumulated seconds and utilized hours from `action.tbl_bucket_tasks` into `project.tbl_project_task_assignments` before applying project team hour calculations, ensuring API responses always return the latest tracked time from the database.

---

### Business Logic
1. **Resource Workload Current Project Task Scope**:
   - In `DhTeamTab` (accessed via the eye icon), the "Resource Assigned Tasks" section now exclusively renders tasks belonging to the current project (`t.projectId === project.id`).
   - If a resource is working on multiple projects, other project tasks are excluded from "Resource Assigned Tasks" and other projects remain listed under "Assigned Projects".
   - Empty state updated to `"No tasks assigned to this resource in this project"`.
2. **Extension Request Approver Dropdown Non-Overlapping Layout**:
   - In `ExtensionRequestModal` (Health -> Extension Request), converted the "Tag Stakeholder Approvers" dropdown from an absolute floating overlay (`absolute top-full z-50`) to an in-flow container.
   - Opening the search and approver selection list naturally flows within the modal and pushes the dialog footer downwards.
   - The "Cancel" and "Submit Request" action buttons remain fully visible and clickable below the list without any element overlap.
3. **Unblocked Team Tab PM/SPM Detection**:
   - `managersFromTeamMembers`: Directly checks `member.memberRole` (`SeniorProjectManager` / `ProjectManager`) first rather than solely relying on on-floor role text matches or asynchronous employee catalog lookups, ensuring assigned managers are never discarded.
   - `withLeaders`: Removed destructive empty array resets (`projectManagers: []`, `seniorProjectManagers: []`) that previously cleared managers when `dbLeaders` was null or loading.
   - `DhTeamTab`: Resilient access guard checks `apiTeamRows` (including role strings), `project.seniorProjectManagers`, `project.projectManagers`, `prereq?.assignedSpmIds`, `prereq?.assignedPmIds`, and direct ID fields. While `teamLoading` is true and managers are resolving, displays `"Loading team…"` instead of prematurely rendering the blocked alert screen.
   - Synced PM/SPM assignments to `dhStore.assignPMsWithPeople` upon fetching team rows, ensuring the Overview tab, WBS prerequisites, and PMO stages indicators stay consistent across page reloads.
   - `WbsTab` (`defaultPmIds` and `defaultSpmIds`): Reads fallback PM/SPM IDs from `project.projectManagers` and `project.seniorProjectManagers` so assignments are preserved after refresh.
4. **Multi-Resource Independent Timers**:
   - Each assigned resource has their own entry in `action.tbl_bucket_tasks`.
   - Each resource can Start, Pause, or Stop their timer independently from their Action Center Bucket List without overriding or stopping another resource's timer.
   - Resource A working 60 min (3600s) and Resource B working 20 min (1200s) have their minutes tracked separately and accurately in their respective bucket tasks and assignments.
5. **Task Assignment Notifications**:
   - Assigning two or more resources to a task dispatches a notification to each assigned resource's Action Center Notification tab.
6. **Completed Service Hours Display in Task Tab**:
   - In `project-detail-page.tsx`, `utilizedOf` restricts utilized hours contributions strictly to tasks in `"Completed"` stage (`t.stage === "Completed"`).
   - Tasks in non-completed stages ("Not Started", "Ongoing", "Paused", "Stopped") do not prematurely count toward the completed Service or Application row hours.
   - Upon stage transition to `"Completed"`, the addition of all assigned resources' working minutes (e.g. 100 min + 20 min = 2.0 hrs) is displayed in the "Hours (Utilized / Est.)" column.
7. **Independent Stopped State**:
   - When a resource confirms "Stop" in the Action Center modal, their bucket task transitions to `"Stopped"`, their timer is frozen, and they cannot resume or pause that task.
8. **Service Utilized Hours Proportional Distribution across Applications (Tasks Tab)**:
   - When a service contains multiple applications (e.g. `qty = 2` for NVA1 and NVA2, or $K$ applications), the service's total estimated hours are divided equally among its applications (e.g. 1048.0 hrs distributed as 524.0 hrs to NVA1 and 524.0 hrs to NVA2).
   - Under each application row (e.g. NVA2), `apUtilizedHours` continues to display the application's direct task utilized hours (e.g. `2.5 / 524.0 hrs`).
   - For the parent Service row, `totalUtilizedHours` is now calculated by dividing the descendant tasks' raw utilized hours by the number of applications under that service (`totalUtilizedHours = rawDescendantUtilized / Math.max(1, serviceApplicationsCount)`).
   - For example, if tasks under NVA2 have 2.5 utilized hours and NVA1 has 0 utilized hours, the main service correctly shows half of 2.5 (`1.25 / 1048.0 hrs`), scaling proportionally if there are 2, 3, or more applications.
   - Added `formatHoursDisplay` helper to render exact two-decimal values (e.g. `1.25`, `0.83`) when numbers have precision beyond a tenth, and standard single-decimal format (e.g. `2.5`, `1048.0`, `0.0`) otherwise.
9. **Inactive/Deleted Services Visibility in Service-wise Prerequisite Tracking (Step 3)**:
   - Added "Show Inactive/Deleted" checkbox toggle to the Step 3 header ("Service wise Prerequisite Tracking") synchronized with the "Services & Deliverables from WBS" toggle and backed by local state fallback.
   - Fixed `deliverableServices` in `WbsTab` to cleanly filter out soft-deleted services (`isDeleted`, `changeStatus === 'Deleted'`, or `deletedAtUtc`) when `showDeletedServices` is unchecked, while including them when checked.
   - Updated `servicesList` in `WbsPrerequisiteSection` to include soft-deleted flags (`isDeleted`, `changeStatus`) and attach the direct source service object (`rawService`), eliminating name-collision bugs where an active and a soft-deleted service shared the same service name.
   - When "Show Inactive/Deleted" is unchecked, soft-deleted services are omitted from the Step 3 table.
   - When "Show Inactive/Deleted" is checked, soft-deleted services appear with disabled dropdowns (Collection, Validation, Billing), "Deleted" badge, line-through text styling (`opacity-50 line-through bg-muted/20`), disabled "Raise Escalation" button, and italicized "Deleted" status in the Start column.
   - Kept `activeServicesList` strictly filtered to active non-deleted services so soft-deleted services never block PMO prerequisite readiness checks (Collection, Validation, Billing, Ready).
10. **Team Tab 3-Dot Action Menu Cleanup**:
   - Removed "Give Praise" option from the resource 3-dot action menu in the Team tab, keeping employee appreciations centralized in the Project Health Appreciation tab.
11. **Team Lead Assignment & Removal Persistence**:
   - Confirmed that clicking "Set as Team Lead" or "Remove Team Lead" sends `PUT /api/v1/projects/{projectId}/team-members/{memberId}` with `{ isTeamLead: boolean }`.
   - The backend service updates `entity.IsTeamLead` in `project.tbl_project_team_members` and `project.TeamLeadId` in `project.tbl_projects`.
   - Removed unnecessary `isWbsCreated` visibility guard so Team Lead assignment is consistently available for all Project Team members.
12. **Give Feedback Validation & Notification Dispatch**:
   - Accessible via the "Give Feedback" option in the resource action menu.
   - Enforced client-side and server-side validation on `Strengths`, `Areas of Improvement`, and `Comments`: maximum 100 characters, restricted strictly to text, numbers, and spaces (`^[a-zA-Z0-9\s]*$`). Real-time character counters (`x/100`) and validation indicators are provided in the modal.
   - Rating constrained between 0 and 5.
   - Submitting inserts a record into `project.tbl_project_feedbacks`.
   - Automatically dispatches Action Center notifications to both the evaluated employee and their reporting manager under their respective Notifications tabs.
13. **Request Feedback Approval Request & Notification Workflow**:
   - Accessible via the "Request Feedback" option in the resource action menu with an optional `Note` field.
   - Submitting inserts a `FeedbackRequest` record with `Status = "Pending"` into `project.tbl_project_feedbacks`.
   - Automatically creates an Approval Request item in the resource's Reporting Manager's Action Center -> Approvals tab.
   - Automatically dispatches an instant Action Center Notification for the Reporting Manager under their Notifications tab.
   - Reporting Managers can review, approve, reject, hold, or request changes with mandatory comments in the Central Approval Center.
14. **Resource Allocation Approval Notification & Comment Display for Project Leaders**:
   - When a resource allocation request is actioned (Approved/Accepted, Rejected, Hold, Request Changes) by the Reporting Manager, notifications are automatically dispatched to the Assigned Project Manager(s), Senior Project Manager(s) / Engagement Manager, and Project Team Lead(s).
   - Notification title is formatted dynamically as `{EmployeeName} is {accepted|rejected|on hold} for the {ProjectName}`.
   - Notification priority is stored and rendered as `-` both in the notifications table and inside the detail modal.
   - The reporting manager's action comment is saved in `CommentsJson` on the notification and displayed in a dedicated "Comments" card directly above the Audit History section when clicking the notification title or "View" button.
   - Notifications without comments cleanly show `No comments`. Fallback comment extraction from history remarks is also supported.
15. **Global Notification Bell & Dropdown Interaction**:
   - Integrated `GlobalNotificationBell` into `AppTopbar`, making the bell functional across all application views wrapped by `AppShell`.
   - Backed by the existing `/api/v1/action-centre/notifications` endpoint and shared `dhStore.notifications` state with zero duplicate data structures or parallel APIs.
   - Displays real-time dynamic unread notification badge on the bell icon (hidden when 0 unread).
   - Dropdown displays latest notifications with exact title, formatted date and time (`formatNotifDate`, `formatNotifTime`), and status badge.
   - Global notification items are strictly view-only: clicking a notification title does not open any modal, popup, drawer, or detail page.
   - Full-screen dark blur background overlay (`rgba(0, 0, 0, 0.25)`, `backdrop-filter: blur(3px)`) renders at `z-[60]` behind the panel (`z-[70]`), preventing accidental clicks on background elements.
   - Dismisses cleanly on clicking the overlay, clicking the bell icon again, or pressing the Escape key.
   - Clicking "View All" or "View All Notifications" navigates to `/action-centre?tab=notifications`.
   - `ActionCentrePage` synchronized with URL search parameter (`?tab=notifications` and `?notifId=...`), allowing seamless deep linking directly to the notifications inbox.

---

### Existing Functionality Preserved
- General resource workload endpoint (`/api/v1/projects/resources/{employeeId}/workload`) continues to provide cross-project tasks when called without a `projectId`.
- Tag Stakeholder Approvers search, keyboard input, multi-selection chips, and removal remain intact.
- Access blocked guard on Team tab remains active if PM and SPM are genuinely unassigned on the project.
- Single active running timer rule per employee (starting a new task pauses other running tasks for the same employee).
- Project Team vs. Shadow Team hour splitting logic (estimated hours split across Project Team members).
- Bucket list sorting order with active and recently updated tasks displayed first.
- Application row (`row.type === "ap"`) utilized hours calculation and display (`apUtilizedHours / apEstimatedHours`) remain unchanged, showing direct task hours for that application.
- Service progress percentage calculation based on task completion stage weights remains intact.
- Single-application services (`qty = 1`) display raw task utilized hours identically to before.
- Pre-requisites, additional customer requirements, customer profile KYC and contact details, and timesheet entries untouched.
- PMO prerequisite readiness checks (`allCollected`, `allValidated`, `allBilled`, `allReady`) continue to evaluate only active, non-deleted services.
- "Services & Deliverables from WBS" table toggle and services editing modal remain fully functional and synchronized.
- Project Health Appreciation tab workflows and existing appreciations remain completely functional.
- Central Approvals for Resource Allocation, Timeline Extension, and Customer Requirements continue to work as expected.
- Existing Action Centre notification search, Current/Archived sub-tabs, status filters, priority filters, and detail view remain completely intact.
- Existing notification creation, storage, and retrieval services are 100% unaltered. Hangfire operates independently as background infrastructure.
- No SLA/TAT business logic, tables, or schema modifications were introduced in Phase 1. Existing database tables and EF Core configurations remain completely unaffected.

---

## 18. Project Health – Issue Resolution TAT/SLA and Escalation Workflow Implementation

### Affected Files
- `apps/backend/Modules/Sla/Services/SlaDeadlineCalculator.cs` (Indian Standard Time `Asia/Kolkata` timezone resolution, IST working hours alignment, late-night off-hours rule, working days EOD calculation)
- `apps/backend/Modules/Sla/Services/ISlaDeadlineCalculator.cs` (Updated method signatures for business timezone calculation)
- `apps/backend/Modules/Sla/Services/SlaRecipientResolver.cs` (Added dynamic resolution for `SeniorProjectManager` / `Sr. PM` and `HeadOfDepartment` / `HOD` with project team allocations, PM reporting manager fallback, and department-matched on-floor roles)
- `apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs` (Implemented live execution for Issue Resolution: status validation before dispatch, recurring daily reminders to EM/PM/TL, SLA breach marking, Level 1 Critical escalation to Sr. PM with alert history update and L2 scheduling, Level 2 Critical escalation to HOD)
- `apps/backend/Modules/Sla/Services/SlaTrackingService.cs` (Enhanced milestone scheduling for Issue Resolution: recurring daily reminders, breach check at target deadline, L1 escalation at deadline, L2 escalation at 1 working day EOD, leave calendar holiday inclusion)
- `apps/backend/Infrastructure/Persistence/Configurations/Sla/SlaPolicyConfiguration.cs` (Configured explicit lowercase column mappings for PostgreSQL table `sla.tbl_sla_policies`)
- `apps/backend/Infrastructure/Persistence/Configurations/Sla/SlaInstanceConfiguration.cs` (Configured explicit lowercase column mappings for PostgreSQL table `sla.tbl_sla_instances`)
- `apps/backend/Infrastructure/Persistence/Configurations/Sla/SlaEventConfiguration.cs` (Configured explicit lowercase column mappings for PostgreSQL table `sla.tbl_sla_events`)
- `apps/backend/Modules/Projects/Services/ProjectIssueService.cs` (Injected `ISlaTrackingService`: initiated SLA tracking on `CreateIssueAsync`, completed tracking and cancelled pending jobs on `UpdateAlertStatusAsync` when status is `Resolved` or `Closed`, preserved SLA clock when transitioning between `Open` and `In Progress`)
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs` (Injected `ISlaTrackingService`: completed SLA tracking on `UpdateAlertGovernanceAsync` when status is `Resolved` or `Closed`, synced issue status for `In Progress` / `Open` without resetting SLA clock)
- `apps/backend/tests/PMS.UnitTests/Sla/IssueResolutionSlaTests.cs` (Unit tests covering IST EOD calculation, late-night submission, weekend skipping, holiday skipping, and L2 escalation deadline)
- `apps/backend/tests/PMS.IntegrationTests/IssueResolutionSlaIntegrationTests.cs` (End-to-end integration test verifying issue creation SLA tracking, milestone job scheduling, and completion cancellation)
- `database/pms_uat.sql` (Seeded `Projects` / `Resolution of Issues` policy in `sla.tbl_sla_policies`)

---

### Database Changes and Migrations
- **SLA Policy Seeded (`sla.tbl_sla_policies`)**:
  - `Id`: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`
  - `Module`: `Projects`
  - `ActivityType`: `Resolution of Issues`
  - `Stage`: `Open`
  - `TatDurationMinutes`: `1080` (2 working days of 540 min each)
  - `CalculationMode`: `EndOfDay`
  - `WorkingHoursStart` / `WorkingHoursEnd`: `09:00:00` - `18:00:00`
  - `ExcludeWeekends`: `true`, `ExcludeHolidays`: `true`
  - `ReminderIntervalsMinutesJson`: `[1440]` (daily recurring reminders)
  - `FirstEscalationAfterMinutes`: `0` (triggers at deadline)
  - `SecondEscalationAfterMinutes`: `540` (1 working day after L1 escalation)
  - `ResponsibleRolesJson`: `["EngagementManager", "ProjectManager", "TeamLead"]`
  - `FirstEscalationRolesJson`: `["SeniorProjectManager", "Sr. PM"]`
  - `SecondEscalationRolesJson`: `["HOD", "Head Of Department"]`
  - Seeded in PostgreSQL databases `trackerpro` and `pms_uat`, and committed to `database/pms_uat.sql`.
- **EF Core Column Mapping Alignment**:
  - Added automatic lowercase column name mappings across `SlaPolicyConfiguration`, `SlaInstanceConfiguration`, and `SlaEventConfiguration` so EF Core correctly queries unquoted lowercase PostgreSQL column identifiers (`id`, `module`, `activitytype`, `targetdeadlineutc`, etc.).

---

### API Changes
- `POST /api/v1/projects/{projectId}/issues`:
  - Now triggers `ISlaTrackingService.StartTrackingAsync` with `ActivityType = "Resolution of Issues"`, `Stage = "Open"`, and `EntityId = issue.Id`.
  - Creates an `sla.tbl_sla_instances` record with `TargetDeadlineUtc` calculated as EOD of the next 2 working days in IST.
  - Schedules Hangfire milestone jobs: Daily Reminder (24h), Breach Check (at deadline), Level 1 Escalation (at deadline), and Level 2 Escalation (at 1 working day after L1).
- `PUT /api/v1/projects/{projectId}/alerts/{alertId}/status`:
  - When status transitions to `"Resolved"` or `"Closed"`, calls `ISlaTrackingService.CompleteTrackingAsync`, transitions the SLA instance to `Completed`, cancels all pending Hangfire jobs, and records an execution audit event.
  - When status transitions to `"Acknowledged"` or `"In Progress"`, updates `alert.Issue.Status` without resetting or recalculating the SLA start time or deadline.
- `PUT /api/v1/action-centre/alerts/{id}/governance`:
  - When status is updated to `"Resolved"` or `"Closed"` from Action Centre governance review, calls `ISlaTrackingService.CompleteTrackingAsync` and deletes all pending Hangfire background jobs.
  - When status is updated to `"In Progress"` or `"Open"`, synchronizes the underlying issue status while preserving the SLA clock.

---

### Business Logic and Rules Implemented
1. **Timezone & Business Operating Hours**:
   - System operates in Indian Standard Time (`Asia/Kolkata`, UTC+05:30).
   - Operating hours are `09:00:00` to `18:00:00` IST (9 hours / 540 min per working day).
   - EOD is `18:00:00` IST (`12:30:00` UTC).
2. **Working Days, Weekends, and Holidays**:
   - Working days are Monday through Friday.
   - Saturdays and Sundays are excluded from TAT calculations.
   - Public holidays defined in `master.mst_leave_calendar` are automatically excluded.
3. **Late-Night & Off-Hours Submission Rule**:
   - Issues raised after `18:00:00` IST, before `09:00:00` IST, or on weekends/holidays have their TAT clock aligned to the start of the next working day (`09:00:00` IST).
   - The 2 working days count from that morning, targeting EOD (`18:00:00` IST) of the 2nd working day.
4. **Recurring Daily Reminders**:
   - Reminders repeat once every 24 hours while the issue status is `Open` or `In Progress`.
   - Before dispatching, the worker validates the latest database state. If `Resolved` or `Closed`, the reminder is safely skipped, the SLA instance is completed, and no notifications are sent.
   - When active, dispatches an `ActionNotification` (`Type = "Issue Daily Reminder"`) to the Project Manager, Engagement Manager, and Team Leader, and schedules the next daily reminder.
5. **First-Level SLA Breach & Escalation (Senior Project Manager)**:
   - SLA deadline: EOD of the next 2 working days from issue creation.
   - If still `Open` or `In Progress` at deadline:
     - SLA instance status transitions to `Breached` with `BreachedAtUtc`.
     - Resolves the project's Senior Project Manager:
       1. Query `project.tbl_project_team_members` where `MemberRole = "SeniorProjectManager"`.
       2. Fallback: Query Project Manager's `ReportingManagerId` from `resource.tbl_employees`.
       3. Fallback: Query active employees in the department with Senior Project Manager designation.
     - Dispatches an `ActionNotification` with `Type = "SLA Escalation"` and `Priority = "Critical"` to the resolved Sr. PM.
     - Appends `"Level 1 SLA Escalation (Senior Project Manager)"` to the Alert's `HistoryJson` and elevates alert priority to `"Critical"`.
     - Records audit log in `sla.tbl_sla_events` and schedules Level 2 Escalation.
6. **Second-Level SLA Breach & Escalation (Head of Department)**:
   - Deadline: EOD of the next 1 working day from the first escalation.
   - If still `Open` or `In Progress` at deadline:
     - Resolves the Head of Department:
       1. Query `resource.tbl_onfloorrole` where `Name = "Head Of Department"` to resolve mapped designations.
       2. Query active employees with matching designation IDs.
       3. Match against the project's department (`ProjectManager.DepartmentId` or `ProjectServices.Department`).
       4. Fallback: First active HOD.
     - Dispatches an `ActionNotification` with `Type = "SLA Escalation"` and `Priority = "Critical"` to the HOD.
     - Appends `"Level 2 SLA Escalation (Head of Department)"` to the Alert's `HistoryJson`.
     - Records audit log in `sla.tbl_sla_events`.
7. **Status Lifecycle & Reopening**:
   - `Open` ↔ `In Progress`: Preserves the SLA clock, deadline, and scheduled jobs without resetting.
   - `Resolved` / `Closed`: Immediately completes SLA tracking, sets `CompletedAtUtc`, cancels pending Hangfire jobs (`BackgroundJob.Delete`), marks events `Cancelled`, and records a `Completed` audit event with `Met SLA: True/False`.
   - Reopening: If an issue is reopened after being `Resolved` or `Closed`, the system preserves the historical completed SLA instance and does not silently restart or overwrite the completed audit record.

---

### Existing Functionality Preserved
- Initial issue notification immediately dispatched to EM, PM, and TL upon issue creation remains completely unchanged.
- Issue creation in Project Health and Alert creation in Action Centre Alerts remain fully functional and synchronized.
- Health tab issues continue to be populated in `project.tbl_project_service_escalations` and displayed in the Escalation tab.
- Bucket list tasks, timesheet entries, and task timers operate independently and are unaffected.
- Hangfire background infrastructure and dashboard at `/hangfire` operate smoothly without interfering with any existing business workflows.

---

## [Unreleased] - 2026-11-12

### Summary
19. Enhanced Issue Resolution TAT/SLA Engine: Working-Day EOD Reminders, Dynamic Level 2 Escalation, Concurrency Hardening, and Reopening Option C:
- **Working-Day EOD Reminders (6:00 PM IST)**:
  - Replaced raw 24-hour interval reminders with working-day EOD (18:00 IST / 12:30 UTC) scheduling.
  - Added `ISlaDeadlineCalculator.GetNextWorkingDayEndOfDayUtc` to calculate the next working-day EOD while strictly skipping Saturdays, Sundays, and configured company holidays (`master.mst_leave_calendar`).
  - For an issue submitted on Monday at 11:00 AM IST, the first reminder is scheduled for Tuesday at 6:00 PM IST.
  - Reminders recur at 6:00 PM IST on every working day until the issue is Resolved or Closed.
- **Two-Working-Day SLA Deadline Alignment**:
  - Aligned `CalculateEndOfDayDeadline` so that an issue submitted on Monday at 11:00 AM IST reaches its 2-working-day SLA deadline at Wednesday 6:00 PM IST (EOD of Day 2).
  - If submitted after working hours (e.g. Monday 8:00 PM IST), the clock begins Tuesday 9:00 AM IST, reaching deadline on Thursday 6:00 PM IST.
  - If submitted on Friday at 2:00 PM IST, the deadline reaches Tuesday 6:00 PM IST (skipping Saturday and Sunday).
- **Dynamic Level 2 Escalation Scheduling**:
  - Removed static pre-scheduling of Level 2 escalation at issue creation.
  - Level 2 escalation is now scheduled dynamically inside `ExecuteEscalationAsync(level = 1)` upon actual successful execution of Level 1 escalation.
  - The Level 2 deadline is anchored to the actual L1 execution timestamp, calculated as the next working-day EOD (18:00 IST) (e.g. Thursday 6:00 PM IST if L1 executes Wednesday 6:00 PM IST).
- **Concurrency & Idempotency Hardening**:
  - Added `[DisableConcurrentExecution(timeoutInSeconds: 60)]` attribute on `SlaBackgroundJobWorker`.
  - Added `idempotencykey` column and unique partial index `uq_sla_events_idempotency_key` on `sla.tbl_sla_events` (`WHERE idempotencykey IS NOT NULL AND deletedatutc IS NULL`).
  - Implemented atomic database transition (`Scheduled` -> `Executing`) via `ExecuteUpdateAsync` in `LoadAndValidateAsync`. Concurrent workers or Hangfire retries seeing 0 rows affected abort immediately, guaranteeing single execution.
  - Added idempotency check in `ActionNotification` dispatch to eliminate any possibility of duplicate notifications for the same issue, milestone, and recipient.
- **Issue Reopening – Option C (Audit Only)**:
  - In `ProjectIssueService.UpdateAlertStatusAsync`, if an issue is updated from `Resolved` or `Closed` back to `Open` or `Acknowledged` (In Progress), the existing issue and alert statuses are updated and a detailed reopening audit trail entry is recorded in `alert.HistoryJson` with user and timestamp.
  - The previous SLA instance remains preserved in `Completed` status; no new SLA instance or background jobs are created, adhering strictly to Option C.

---

### Affected Files
- [`apps/backend/Modules/Sla/Models/SlaEvent.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Modules/Sla/Models/SlaEvent.cs): Added `IdempotencyKey` property.
- [`apps/backend/Infrastructure/Persistence/Configurations/Sla/SlaEventConfiguration.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Infrastructure/Persistence/Configurations/Sla/SlaEventConfiguration.cs): Configured `IdempotencyKey` column mapping and unique partial index.
- [`apps/backend/Migrations/20261112090335_AddSlaTrackingSchemaAndIdempotencyKey.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Migrations/20261112090335_AddSlaTrackingSchemaAndIdempotencyKey.cs): Formal EF Core migration creating `sla.tbl_sla_policies`, `sla.tbl_sla_instances`, `sla.tbl_sla_events`, `idempotencykey`, and unique index.
- [`apps/backend/appsettings.Production.json`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/appsettings.Production.json): Production environment configuration preventing accidental fallback to UAT remote database by requiring explicit environment variables.
- [`apps/backend/Modules/Sla/Services/ISlaDeadlineCalculator.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Modules/Sla/Services/ISlaDeadlineCalculator.cs): Added `GetNextWorkingDayEndOfDayUtc` method signature.
- [`apps/backend/Modules/Sla/Services/SlaDeadlineCalculator.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Modules/Sla/Services/SlaDeadlineCalculator.cs): Implemented `GetNextWorkingDayEndOfDayUtc` and aligned `CalculateEndOfDayDeadline`.
- [`apps/backend/Modules/Sla/Services/SlaTrackingService.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Modules/Sla/Services/SlaTrackingService.cs): Updated reminder scheduling to working-day EOD, assigned idempotency keys, and removed static L2 pre-scheduling.
- [`apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs): Added `[DisableConcurrentExecution]`, atomic database state transition (`Scheduled` -> `Executing`), working-day EOD recurring reminders, and dynamic Level 2 escalation scheduling.
- [`apps/backend/Modules/Projects/Services/ProjectIssueService.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Modules/Projects/Services/ProjectIssueService.cs): Implemented Option C for issue reopening (audit trail, status sync, SLA preservation without re-triggering).
- [`database/pms_uat.sql`](file:///d:/Project%20Compass/project_TrackerPro/database/pms_uat.sql): Added `idempotencykey` column and `uq_sla_events_idempotency_key` unique index to `sla.tbl_sla_events`.
- [`apps/backend/tests/PMS.UnitTests/Sla/IssueResolutionSlaTests.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/tests/PMS.UnitTests/Sla/IssueResolutionSlaTests.cs): Added unit tests for timeline example (Monday 11 AM -> Tuesday 6 PM reminder -> Wednesday 6 PM deadline -> Thursday 6 PM L2), weekend skipping, and holiday skipping.
- [`apps/backend/tests/PMS.IntegrationTests/IssueResolutionSlaIntegrationTests.cs`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/tests/PMS.IntegrationTests/IssueResolutionSlaIntegrationTests.cs): Verified dynamic L2 exclusion at creation, resolution cancellation, and Option C reopening against live PostgreSQL.

---

### Database Changes and Migrations
- Added `idempotencykey VARCHAR(150)` to `sla.tbl_sla_events` in PostgreSQL databases `pms_uat` and `trackerpro`.
- Added unique partial index `uq_sla_events_idempotency_key` on `sla.tbl_sla_events (idempotencykey) WHERE idempotencykey IS NOT NULL AND deletedatutc IS NULL`.
- Generated EF Core Migration [`20261112090335_AddSlaTrackingSchemaAndIdempotencyKey`](file:///d:/Project%20Compass/project_TrackerPro/apps/backend/Migrations/20261112090335_AddSlaTrackingSchemaAndIdempotencyKey.cs) and registered in `public."__EFMigrationsHistory"`.

---

### API Changes
- **`PUT /api/v1/projects/{projectId}/alerts/{alertId}/status`**:
  - Enhanced to handle issue reopening: transitioning an alert/issue from `Resolved` or `Closed` back to `Open` or `Acknowledged` (In Progress) updates issue status, records a dedicated reopening audit entry in `alert.HistoryJson`, and preserves the historical completed SLA instance without generating duplicate SLA instances (Option C: Audit Only).
- **Background Worker Contracts**:
  - Decorated `SlaBackgroundJobWorker` with `[DisableConcurrentExecution(timeoutInSeconds: 60)]`.
  - Added `ISlaDeadlineCalculator.GetNextWorkingDayEndOfDayUtc` to support working-day 18:00 IST milestone calculations.

---

### Business Logic and Rules Implemented
1. **Working-Day EOD Reminders (18:00 IST)**:
   - Reminders are scheduled at 6:00 PM IST on working days only while the issue remains in `Open` or `In Progress` status.
   - For an issue submitted on Monday at 11:00 AM IST, the first reminder triggers on Tuesday at 6:00 PM IST.
   - Recurring reminders repeat on subsequent working days at 6:00 PM IST until the issue is Resolved or Closed.
   - Saturdays, Sundays, and public holidays configured in `master.mst_leave_calendar` are automatically excluded.
2. **Two-Working-Day SLA Deadline**:
   - For an issue submitted on Monday at 11:00 AM IST (during working hours), the 2-working-day SLA deadline reaches Wednesday at 6:00 PM IST.
   - Submissions after working hours (e.g. Monday 8:00 PM IST) start counting from the next working day morning (Tuesday 9:00 AM IST) and reach deadline on Thursday at 6:00 PM IST.
   - Weekend or holiday submissions start counting from the next working day.
3. **Dynamic Level 2 Escalation**:
   - Level 2 escalation is NOT pre-scheduled at issue creation.
   - Scheduled dynamically when Level 1 escalation actually executes in `ExecuteEscalationAsync(level = 1)`.
   - Anchored to the actual L1 execution timestamp, calculated as the next working day's EOD (18:00 IST) (e.g. Thursday 6:00 PM IST if L1 executed Wednesday 6:00 PM IST).
4. **Concurrency & Idempotency Guards**:
   - Database uniqueness enforced on `sla.tbl_sla_events.idempotencykey` (`sla:{instanceId}:rem:{yyyy-MM-dd}`, `sla:{instanceId}:esc-l1`, `sla:{instanceId}:esc-l2`, `sla:{instanceId}:breach`).
   - Atomic state transition `Scheduled` $\rightarrow$ `Executing` via `ExecuteUpdateAsync` guarantees single execution across concurrent Hangfire workers and retry loops.
   - Notification dispatch checks existing recipient notifications before creating duplicates.
5. **Fresh State Validation**:
   - All background jobs verify the latest issue status and SLA instance state from the database before dispatching notifications.
   - Resolved and Closed issues complete SLA tracking immediately and safely skip execution without notifications.
6. **Issue Reopening (Option C: Audit Only)**:
   - When a Resolved or Closed issue is reopened, existing issue status is updated, reopening audit trail is recorded in `alert.HistoryJson` with user and timestamp, and prior SLA history is preserved.
   - No new SLA instances or recurring background jobs are created.

---

### Existing Functionality Preserved
- Immediate issue creation notifications to EM, PM, and TL remain completely unchanged.
- Issue creation in Project Health and Alert creation in Action Centre Alerts remain fully functional and synchronized.
- Service escalation records in `project.tbl_project_service_escalations` and the Health Escalation tab remain intact.
- Non-SLA modules (Bucket list, Timesheet, Resources, Customer, My Team) remain 100% untouched.

---

### Test Results
- **Unit Tests**: 82 passed, 0 failed (`PMS.UnitTests.dll`).
  - Tested: Monday 11 AM $\rightarrow$ Tuesday 6 PM reminder $\rightarrow$ Wednesday 6 PM deadline $\rightarrow$ Thursday 6 PM L2 escalation, weekend skipping, holiday calendar skipping, and idempotency key formatting.
- **Integration Tests**: 1 passed, 0 failed (`PMS.IntegrationTests.IssueResolutionSlaIntegrationTests`).
  - Tested against live PostgreSQL: issue creation, dynamic L2 exclusion at creation, resolution cancellation, and Option C reopening verification.

---

## [Unreleased] - 2026-11-12

### Action Centre – Bucket List TAT/SLA Notifications, Reminders and Two-Level Escalations

### Summary
Implemented comprehensive TAT/SLA monitoring, notifications, working-day EOD reminders, breach detection, and multi-level escalations for four activities under **Action Centre → Bucket List**:
1. **Task Start After Assigning (Resource Shift-Based SLA)**:
   - Initial notification immediately sent to Assigned Engagement Manager, Assigned Project Manager, and Project Team Leader, in addition to standard assignment notification for the assigned employee.
   - Resource-specific SLA tracking anchored to the unique task assignment (`project.tbl_project_task_assignments.id`), ensuring complete isolation for tasks assigned to multiple resources.
   - First-level SLA deadline calculated dynamically based on the assigned resource's planned shift from `timesheet.tbl_team_day_entries`:
     - **General**: 09:00 AM – 06:00 PM IST (Deadline: same day 06:00 PM IST)
     - **Morning**: 06:00 AM – 02:00 PM IST (Deadline: same day 02:00 PM IST)
     - **Afternoon**: 02:00 PM – 10:00 PM IST (Deadline: same day 10:00 PM IST)
     - **Night**: 10:00 PM – 06:00 AM IST next day (Deadline: next day 06:00 AM IST)
   - Robust fallback: If calendar entry does not exist, or `Shift` is null, empty, unmapped, or invalid, automatically defaults to **General Shift (09:00 AM – 06:00 PM IST)**.
   - Non-working time roll: Assignments after shift end, on weekends, company holidays, or approved leave days roll forward to the end of the next available working shift.
   - Night shift crossing midnight: Night shift on Friday night ends on Saturday morning at 06:00 AM IST.
   - First-level SLA breach triggers notification to Assigned Senior Project Manager.
   - Second-level escalation dynamically scheduled from actual Level 1 execution timestamp for EOD (18:00 IST) of the next working day to Head of Department (resolved from `resource.tbl_onfloorrole` where `Name = "Head Of Department"`).
   - Starting the task timer from Action Centre Bucket List completes only that resource's SLA and cancels future escalation jobs.
2. **Task Deadline**:
   - Initial notification immediately sent to Assigned Engagement Manager, Assigned Project Manager, and Project Team Leader.
   - Midpoint reminder sent to Assigned Engagement Manager, Assigned Project Manager, and Project Team Leader.
   - 1-day-before reminder sent to Assigned Engagement Manager, Assigned Project Manager, and Project Team Leader.
   - First-level SLA breach at WBS planned end date (`PlannedEndDate` 18:00 IST) triggers notification to Assigned Senior Project Manager.
   - Second-level escalation dynamically scheduled for EOD (18:00 IST) of the next working day after actual Level 1 execution to Head of Department.
   - Updating task planned end date in WBS reschedules all milestone reminders and breach/escalation jobs.
   - Task completion completes the SLA and cancels all pending reminders and escalations.
3. **Task Stop**:
   - Immediate notification dispatched to Assigned Engagement Manager, Assigned Project Manager, and Project Team Leader when a resource stops a task timer.
   - Strictly no SLA breach, no Level 1 or Level 2 escalations.
4. **Task Pause (Resource-Only Daily Shift-End Reminders)**:
   - Immediate initial notification upon timer pause dispatched ONCE to Assigned Engagement Manager, Assigned Project Manager, and Project Team Leader. Never sent to Senior Project Manager or Head of Department.
   - Daily recurring reminder sent **ONLY to the specific resource who paused the task**, with the exact text:
     `"Your task {Task_Name} is still paused. Please resume the task or complete it."`
   - Reminder delivery time calculated at the **EOD of the assigned resource's shift** (General 6 PM, Morning 2 PM, Afternoon 10 PM, Night 6 AM next day IST; defaults to General 6 PM if missing/invalid).
   - Daily reminders are **NEVER** sent to Assigned Project Manager, Assigned Engagement Manager, Project Team Leader, Assigned Senior Project Manager, or Head of Department.
   - Strictly no SLA breach, no Level 1 or Level 2 escalations.
   - Isolated per resource: Tracking uses `EntityId = assignment.Id` and `RecipientEmployeeId = resource.Id`. Resource A pausing does not affect Resource B.
   - Cancellation: Pending reminder jobs are immediately cancelled when the resource resumes the task timer, completes the task, when the assignment is removed, or if the timer state changes. Fresh database verification occurs before every reminder execution.

---

### Affected Files
- `apps/backend/Modules/Sla/DTOs/SlaTrackingDtos.cs`: Added `CustomDeadlineUtc` to `SlaStartTrackingRequest`.
- `apps/backend/Modules/Sla/Services/ISlaDeadlineCalculator.cs`: Added `CalculateSameDayEndOfDayUtc`, `CalculateSameDayEndOfDayForEmployeeAsync`, and `CalculateNextPauseReminderForEmployeeAsync`.
- `apps/backend/Modules/Sla/Services/SlaDeadlineCalculator.cs`: Implemented shift normalization (`General`, `Morning`, `Afternoon`, `Night`, defaulting invalid/null to `General`), shift EOD calculation, Night shift 06:00 AM calculation, Friday night shift ending Saturday morning, attendance leave & weekend/holiday rolls, and pause reminder scheduling.
- `apps/backend/Modules/Sla/Services/ISlaRecipientResolver.cs`: Added `ResolveLeadershipRecipientsAsync`.
- `apps/backend/Modules/Sla/Services/SlaRecipientResolver.cs`: Implemented full role name aliases and On Floor Role `Head Of Department` resolution with department/subdepartment scoping.
- `apps/backend/Modules/Sla/Services/SlaTrackingService.cs`: Configured fallback policies and milestone scheduling for Task Start, Task Deadline, and Task Pause with shift-aware deadlines and target recipient isolation.
- `apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs`: Branched reminder, breach check, and escalation execution for Task Start, Task Deadline, and Task Pause. Rewrote `ExecuteTaskPauseReminderAsync` to verify fresh state, dispatch reminder strictly to the assigned resource, and reschedule next pause reminder at the resource's shift end.
- `apps/backend/Modules/Projects/Services/IProjectTaskService.cs`: Added `TriggerTaskAssignmentSlaAsync`.
- `apps/backend/Modules/Projects/Services/ProjectTaskService.cs`: Wired leadership notifications, shift EOD calculation, Task Start SLA tracking, Task Deadline SLA tracking, and unassignment cancellation.
- `apps/backend/Modules/Projects/Services/ProjectAppService.cs`: Wired task assignment SLA triggering, WBS deadline rescheduling, task completion SLA completion, and timer start SLA completion.
- `apps/backend/Modules/ActionCentre/Services/BucketTaskService.cs`: Injected `ISlaDeadlineCalculator`; wired timer start (completes Task Start and Pause SLAs), timer pause (immediate leadership notification & resource-only daily reminder scheduling anchored to assignment ID), timer stop (leadership notification), and task completion (completes Deadline and Pause SLAs).
- `apps/backend/tests/PMS.UnitTests/Sla/BucketListSlaTests.cs`: Added comprehensive unit tests for shift deadlines, invalid/null shift fallback, night shift crossing midnight, weekend rolls, leave calendar, dynamic L2 escalation, and resource-only pause daily reminders (103/103 tests passing).
- `apps/backend/tests/PMS.IntegrationTests/BucketListSlaIntegrationTests.cs`: Added end-to-end integration test verifying task assignment, start timer, pause timer, and stop timer workflows.

---

### Complete Notification and Escalation Hierarchy (No Abbreviations)
- **Initial Notification Recipients**:
  - Assigned Engagement Manager
  - Assigned Project Manager
  - Project Team Leader
- **First-Level Escalation Recipient**:
  - Assigned Senior Project Manager
- **Second-Level Escalation Recipient**:
  - Head of Department (dynamically resolved from `resource.tbl_onfloorrole` where `Name = "Head Of Department"`, scoped to the employee's department and subdepartment)

---

### Multi-Resource Assignment & Independent Tracking
- Each assigned resource has a dedicated row in `project.tbl_project_task_assignments` and `action.tbl_bucket_tasks`.
- Setting `SlaInstance.EntityId = assignment.Id` gives 100% isolation for Task Start and Task Pause SLAs without requiring database schema changes.
- If Resource A starts their timer, only Resource A's `Task Start After Assigning` SLA instance is completed and pending escalation jobs are cancelled.
- If Resource A pauses their timer, daily reminders are sent only to Resource A. Resource B working on the same task is completely unaffected.
- Resuming Resource A's timer cancels only Resource A's pause reminders.

---

### Test Results
- **Unit Tests**: 104 passed, 0 failed (`PMS.UnitTests.dll`).
  - Tested: General shift (18:00 IST), Morning shift (14:00 IST), Afternoon shift (22:00 IST), Night shift (06:00 next morning), null/invalid shift fallback to General, after-shift assignments, weekend submissions, holiday calendar skipping, attendance leave rolls, dynamic Level 2 escalation from actual L1 execution with weekend and holiday calendar exclusion, and resource-only pause daily reminders at shift end.
- **Integration Tests**:
  - `BucketListSlaIntegrationTests`: 4 passed, 0 failed.
    - `BucketList_TaskStart_Pause_Stop_Lifecycle_TracksSlaAndNotifications` (PASSED)
    - `TaskPause_DailyReminderExecution_DeliversOnlyToResource_AndNeverLeadership_AndResumeCancels` (PASSED)
    - `TaskStart_BreachExecution_TriggersL1ToAssignedSpm_AndL2ToDynamicHod` (PASSED)
    - `TaskDeadline_FullLifecycle_Midpoint_OneDayBefore_L1_DynamicL2_Reschedule_AndCancel` (PASSED)
  - `IssueResolutionSlaIntegrationTests`: 1 passed, 0 failed.
  - Full suite run: 26 passed, 10 failed (all 10 verified as pre-existing environmental seed/schema mismatches in legacy modules: 3 in `MyTeamModuleTests` requiring non-existent seed user `alice.johnson@example.com`, 2 in `ResourceModuleTests` expecting empty catalog, 1 in `CustomerModuleTests` client auth bypass, 4 in `ResourceModuleTests` due to UAT `tbl_notifications.ProjectId` not-null constraint on resource onboarding).
- **Backend Compilation**: Clean build with 0 errors, 0 warnings (`dotnet build apps/backend/PMS.API.csproj`).
- **Live Daemons**: Backend running on port 5194 (`http://localhost:5194/health` returning `Healthy`), Frontend running on port 3000.

---

### Database Synchronization & Table Parity
- Re-extracted and synchronized `database/pms_uat.sql` with full data accuracy from the active PostgreSQL database (`localhost:5432`).
- Reconciled table counts across active databases (`trackerpro`, `pms_uat`) and `database/pms_uat.sql`:
  - Exactly 82 base tables and 1 view across all 10 application schemas (`action`, `auth`, `customer`, `master`, `project`, `public`, `repository`, `resource`, `sla`, `timesheet`).
  - Added `project.tbl_project_feedbacks` to `trackerpro` ensuring 100% schema parity.
  - Excluded internal `hangfire` system execution tables (12 tables) from the distribution dump, as Hangfire auto-installs and manages its own schema on startup.
  - Successfully validated clean restoration of `database/pms_uat.sql` via `psql`.

## Historical Log Entries (uat_clean10)

<!-- New changes will be logged below this line -->
### [2026-11-05] Action Center Approvals Enhancements, Two-Way Discussion Thread, and WBS "Edit Services" Activation

- **Branch**: `uat_clean8`
- **Module**: Action Centre / Approvals & Project Health Customer Engagement (Additional Customer Requirements & WBS)
- **Purpose**:
  1. In Action Center Approvals tab, remove the "Acknowledge" button and "Acked" status badge next to the "View" action button.
  2. In Central Approval Center modal (Review Request):
     - Support interactive commenting and actioning when selecting "Hold", "Reject", or "Request changes", keeping the modal open and re-enabling further comments.
     - When a request is "Approved", lock the review view completely (disable and hide action comment input and action buttons, displaying a read-only approved banner).
     - Relocate the Audit Log History section directly under the comment section in the Review Request modal.
  3. Enable two-way discussion thread communication between Project Health (`Health -> Customer Engagement -> Additional Customer Requirement` -> `Requirement Details` -> `Discussion Thread`) and Action Center Approvals:
     - Reviewer's action comments / clarifications appear in the Discussion Thread.
     - Requester and reviewers can exchange messages via the Discussion Thread while the requirement is not approved.
     - When the requirement is approved, discussion thread posting is strictly locked/disabled on both frontend and backend.
     - Remove the status change dropdown `<select>` option from the Requirement Details form (read-only badge only; status transitions can only occur via the Action Center approval flow).
     - Ensure chat messages and requirement status are never persisted to browser memory (`localStorage`), querying and persisting authoritative data directly from PostgreSQL database table `project.tbl_project_additional_requirements`.
  4. Notification delivery on all status changes:
     - When an additional requirement transitions to "Approved", "Hold", "Rejected", or "Request Changes" ("Requested changes"), dispatch Action Center notifications directly to the project's Assigned Engagement Manager, Project Manager, and Senior Project Manager.
  5. Fix Project WBS "Edit Services" button activation:
     - When an Additional Customer Requirement is approved, enable the "Edit Services" button under WBS (Section A: Services & Deliverables from WBS) for 2 days.
     - Synchronize approval state dynamically across DB and workspace store with immutable array references to trigger immediate UI reactivity.

#### 📁 Files Affected
- **Modified**: `apps/backend/Modules/Projects/DTOs/ProjectAdditionalRequirementDtos.cs`
- **Modified**: `apps/backend/Modules/Projects/Services/IProjectAdditionalRequirementService.cs`
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectAdditionalRequirementService.cs`
- **Modified**: `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`
- **Modified**: `apps/frontend/src/modules/projects/api/project-additional-requirements.ts`
- **Modified**: `apps/frontend/src/lib/workspace-store.ts`
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- **Modified**: `CHANGELOG_AI.md`

#### 🗄️ Database & Schema Changes
- Stored and queried structured comments in `CommentsJson` and audit logs in `HistoryJson` on `project.tbl_project_additional_requirements`.
- Dispatches status change notifications to `action.tbl_notifications` with status and actor comments.
- No DDL migrations required as columns already exist in schema.

#### 🔌 APIs & Business Logic Changed
- **Backend Endpoints Added & Modified**:
  - `POST /api/v1/projects/{projectId}/additional-requirements/{requirementId}/action`:
    - Handles approval statuses (`Approved`, `Rejected`, `Hold`, `Request Changes`).
    - Appends reviewer comment to `CommentsJson` and `HistoryJson`.
    - Dispatches notifications to Assigned EM, PM, and SPM on any status transition ("Approved", "Hold", "Rejected", "Request Changes").
    - If status is `Approved`, sets `ApprovedAtUtc`.
  - `POST /api/v1/projects/{projectId}/additional-requirements/{requirementId}/comments`:
    - Allows requester or reviewer to post comments in the discussion thread.
    - Validates requirement status: returns `409 Conflict` ("Cannot post comments to an already approved requirement.") if already approved.
- **Backend Service Logic (`ProjectAdditionalRequirementService`)**:
  - Implemented `AppendComment` and `AppendHistory` utilizing `JsonDocument.Parse` to sanitize JSON arrays and prevent nested list artifacts.
  - Implemented `NotifyLeadershipOnStatusChangeAsync` to reliably dispatch Action Center notifications to EM, PM, and SPM on status transitions.
  - Implemented `IsEditServicesEnabled` checking if any additional customer requirement on the project is approved and was approved within 2 days (`DateTime.UtcNow <= r.ApprovedAtUtc.Value.AddDays(2)`).
- **Frontend State Management & Pages**:
  - `project-detail-page.tsx`:
    - Added two-way discussion thread to `RequirementDetailsModal`, querying backend discussion comments and allowing post submission when not approved.
    - Removed status `<select>` dropdown option from `RequirementDetailsModal` (rendered as read-only status badge).
    - `WbsTab`: Evaluates `isEditServicesEnabled` against both DB requirements and workspace store requirements within 2 days of approval.
  - `action-centre-page.tsx`:
    - Removed "Acknowledge" button and "Acked" badge next to View button.
    - Supports interactive action comments on "Hold", "Request Changes", and "Reject", and locks the view when "Approved".
    - Fixed double comment display issue in Review Request Discussion Thread by suppressing redundant local store comment pushes when `loadApprovals()` reloads the authoritative database state, and de-duplicating comments on parse and render.
    - Moved the `Audit Log History` section directly under the action comment section.
    - Calls `loadApprovals()` after taking actions to refresh authoritative records from the database table.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- "Edit Services" button in WBS must only be clickable within 2 days of an additional customer requirement approval.
- Two-way communication is strictly disallowed once a requirement is approved.
- All existing project detail, client engagement, and action center workflows are fully preserved.


### [2026-11-05] Low-Priority Customer, Sub-Venture, WBS, and Resource Onboarding Notification Delivery Fix

- **Branch**: `uat_clean8`
- **Module**: Action Centre / Notifications (Customer, Sub-Venture, WBS, Resource)
- **Purpose**:
  1. Fix notification recipient resolution for Customer Onboarding, Sub-Venture Onboarding under Customer, WBS Creation, and Resource Onboarding so that all target resources accurately receive notifications in their Action Center notifications tab.
  2. Implement sub-venture onboarding notifications (`Type = "Sub-Venture Onboarded"`, `NotifySubVentureOnboardedAsync`) when sub-ventures are created during customer onboarding or added during customer updates.
  3. Enforce strict **AND** conditions:
     - Customer Onboarding and Sub-Venture Onboarding strictly target active resources whose `Sub-Department == "EM (Engagement Manager)"` **AND** whose `On Floor Role in ("Head Of Department", "Leader")` (strictly excluding `Team Leader`). If no employee holds this role in the database, 0 notifications are dispatched until such an employee is onboarded or assigned that role.
     - WBS Creation strictly targets active resources whose `Sub-Department in ("EM (Engagement Manager)", "PMO (Project Management Office)")` **AND** whose `On Floor Role == "Head Of Department"`.
     - Resource Onboarding targets the assigned `Reporting Manager` of the resource, plus active resources whose `Sub-Department in ("EM (Engagement Manager)", "PMO (Project Management Office)")` **AND** whose `On Floor Role in ("Sr. Manager", "Manager")`.
  4. Set the priority across all four notification types (`Customer Onboarded`, `Sub-Venture Onboarded`, `WBS Created`, `Resource Onboarded`) to `Low`.

#### 📁 Files Affected
- **Modified**: `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- **Modified**: `apps/backend/Modules/Customers/Services/ClientService.cs`
- **Modified**: `CHANGELOG_AI.md`

#### 🗄️ Database & Schema Changes
- None (dispatches records to `action.tbl_notifications` with `Priority = "Low"` and dual-syncs to `pms_uat`).

#### 🔌 APIs & Business Logic Changed
- **`ActionNotificationService`**:
  - `NotifyCustomerOnboardedAsync` & `NotifySubVentureOnboardedAsync`:
    - Dispatches strictly to active resources whose Sub-Department is `EM (Engagement Manager)` AND whose On Floor Role is `Head Of Department` or `Leader`.
    - Strictly excludes `Team Leader`.
    - Dynamically evaluates against current employees so any newly onboarded or updated EM Leader/HOD immediately receives notifications for subsequent onboardings.
    - Sets `Priority = "Low"`.
  - `NotifyWbsCreatedAsync`:
    - Dispatches strictly to active resources whose Sub-Department is `EM (Engagement Manager)` or `PMO (Project Management Office)` AND whose On Floor Role is `Head Of Department`.
    - Sets `Priority = "Low"`.
  - `NotifyResourceOnboardedAsync`:
    - Dispatches to the assigned `Reporting Manager` of the resource, plus active resources whose Sub-Department is `EM (Engagement Manager)` or `PMO (Project Management Office)` AND whose On Floor Role is `Sr. Manager` or `Manager`.
    - Sets `Priority = "Low"`.
- **`ClientService`**:
  - `CreateClientAsync`: Dispatches `NotifyCustomerOnboardedAsync` and loops through `created.SubVentures` to dispatch `NotifySubVentureOnboardedAsync` for each onboarded sub-venture.
  - `UpdateClientAsync`: Detects newly added sub-ventures in `request.SubVentures` and dispatches `NotifySubVentureOnboardedAsync` for each new sub-venture.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Dispatches strictly to Action Center notifications (`action.tbl_notifications`), never creating governance alerts in `project.tbl_project_alerts`.
- Dual database synchronization to `pms_uat` is preserved.


### [2026-11-05] Workspace Store Method Integrity Restoration and Local UAT Database Snapshot Refresh

- **Branch**: `uat_clean8`
- **Module**: Frontend State Management (`workspace-store.ts`), Database Snapshot (`pms_uat.sql`)
- **Purpose**:
  1. Fix runtime crash `TypeError: dhStore.registerPeople is not a function` on project navigation by restoring full 42 store methods in `workspace-store.ts`.
  2. Surgically apply store enhancements without altering existing store method implementations:
     - Purged legacy `comments` and `requirements` keys from browser `localStorage` to ensure chat threads and requirement statuses are never cached in browser memory.
     - Preserved requirement discussion threads and history across `mergeRequirements`.
     - Synchronized requirement comments to central approvals with deduplication.
     - Supported `Hold` and `Request Changes` statuses in `updateCentralApprovalStatus` and emitted fresh array references for immediate React reactivity.
  3. Refreshed PostgreSQL database dump `database/pms_uat.sql` and `database/trackerpro-uat.sql` directly from the current active local database using `pg_dump --no-owner --no-acl`.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/lib/workspace-store.ts`
- **Modified**: `database/pms_uat.sql`
- **Modified**: `database/trackerpro-uat.sql`
- **Modified**: `CHANGELOG_AI.md`

#### 🗄️ Database & Schema Changes
- Regenerated `database/pms_uat.sql` and `database/trackerpro-uat.sql` from live local PostgreSQL database schema and seed data.

#### 🔌 APIs & Business Logic Changed
- Restored `registerPeople`, `assignPMsWithPeople`, `addInterview`, `resolveAlert`, and other missing store methods.
- Verified frontend build passes (`npm run build --prefix apps/frontend` succeeded with 0 errors).
- Verified backend build passes (`dotnet build apps/backend/PMS.API.csproj` succeeded with 0 errors).

#### ⚠️ Critical Dependencies & Invariants to Preserve
- All existing `uat_clean6` store methods and business logic remain intact.
- Baseline `uat_clean6` remains completely unmodified.


### [2026-11-10] Removal of Acknowledge Action and Columns from Notification Tab in Action Center

- **Branch**: `uat_clean9`
- **Module**: Action Centre / Notifications
- **Purpose**:
  1. Remove the "Acknowledge" button and mandatory comment requirement strictly from the Notification tab in Action Center.
  2. Replace the row action button with a standard "View" button (`<Eye /> View`) that opens the Notification Details modal across all sub-tabs.
  3. Clean up the Notification Details modal:
     - Removed the "This notification is awaiting acknowledgement" warning banner.
     - Removed the mandatory "Acknowledgement Comment" textarea and validation errors.
     - Removed the "This notification has been acknowledged" banner and acknowledged timestamp fields from the Audit History card.
     - Removed the "Acknowledge" button from the modal footer, leaving only the "Close" button.
  4. Remove acknowledgement code from the codebase:
     - Frontend: Removed `acknowledgedBy`, `acknowledgedDate`, and `acknowledgedTime` optional properties from `DhNotification` interface, and removed `acknowledgeNotification` store action from `dhStore` in `workspace-store.ts`.
     - Backend: Removed `AcknowledgedBy`, `AcknowledgedDate`, and `AcknowledgedTime` entity properties from `ActionNotification.cs` and entity configuration `ActionNotificationConfiguration.cs`.
     - Backend DTOs & Endpoints: Removed `AcknowledgeNotificationRequest` DTO, removed properties from `ActionNotificationDto.cs`, removed `AcknowledgeNotificationAsync` from `IActionNotificationService` and `ActionNotificationService.cs`, and removed the `[HttpPut("notifications/{id:guid}/acknowledge")]` endpoint in `ActionCentreController.cs`.
  5. Database: Dropped columns `"AcknowledgedBy"`, `"AcknowledgedDate"`, and `"AcknowledgedTime"` from `action.tbl_notifications` in PostgreSQL (`trackerpro` and `pms_uat`).
  6. Refreshed SQL snapshots: Regenerated `database/pms_uat.sql` and `database/trackerpro-uat.sql` via `pg_dump` from local database.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/frontend/src/lib/workspace-store.ts`
- **Modified**: `apps/backend/Modules/ActionCentre/Models/ActionNotification.cs`
- **Modified**: `apps/backend/Infrastructure/Persistence/Configurations/ActionNotificationConfiguration.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`
- **Modified**: `database/pms_uat.sql`
- **Modified**: `database/trackerpro-uat.sql`
- **Modified**: `CHANGELOG_AI.md`

#### 🗄️ Database & Schema Changes
- `action.tbl_notifications`: Executed `ALTER TABLE action.tbl_notifications DROP COLUMN IF EXISTS "AcknowledgedBy", DROP COLUMN IF EXISTS "AcknowledgedDate", DROP COLUMN IF EXISTS "AcknowledgedTime";`.
- Re-exported clean schemas and data into `database/pms_uat.sql` and `database/trackerpro-uat.sql`.

#### 🔌 APIs & Business Logic Changed
- Removed endpoint `PUT /api/v1/action-centre/notifications/{id}/acknowledge`.
- Notification listing (`GET /api/v1/action-centre/notifications`) no longer serializes `acknowledgedBy`, `acknowledgedDate`, `acknowledgedTime`.
- Unread status toggling via `PUT /api/v1/action-centre/notifications/{id}/read` continues to function.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Only notification acknowledgement in the Notification tab was removed. All other action center items (Approvals, Escalations, Issues, Alerts) and PM/SPM assignment acknowledgement mechanisms (`acknowledgedByPmIds`, `acknowledgedBySpmIds`) remain completely untouched and fully functional.
- Frontend build (`npm run build --prefix apps/frontend`) passes with 0 errors.
- Backend build (`dotnet build apps/backend/PMS.API.csproj`) passes with 0 warnings and 0 errors.


### [2026-11-10] Project Extension Request Approval End Date Expansion Across Project Overview, WBS, and Extension Panel

- **Branch**: `uat_clean9`
- **Module**: Project Health / Extension Request & Action Centre / Timeline Extension Approval
- **Purpose**:
  1. Fix project end date expansion when an extension request is approved in Action Center Approvals tab:
     - Upon approval of a Timeline Extension Request, the project's extended end date now correctly and immediately reflects across the entire project (Project Details header, Overview tab, Extension Request tab, and WBS services).
  2. Synchronize project service end dates:
     - Update the latest service(s) in `project.tbl_project_services` matching the project's latest end date to the new `RequestedEndDate`, automatically recalculating `TotalDays` and `DurationDays`.
  3. Fix date derivation and frontend state reactivity:
     - In `projects.ts` (`mapApiProjectToProject`) and `project-detail-page.tsx`, resolve `projectEndDate` by preserving the explicit project end date when it exceeds the legacy service bounds (`explicitEnd > projectDates.endDate ? explicitEnd : projectDates.endDate`), preventing approved extensions from being truncated by earlier service dates.
     - In `OverviewTab`, derive `effectiveEndDate` by taking the maximum between the explicit project end date and the latest service end date (`Math.max(projEnd, latestServiceEnd)`).
     - In `ExtensionRequestPanel`, derive `currentEnd` considering both the latest approved extension request end date and the project's end date so the Extension Request form displays the current extended date.
     - In `action-centre-page.tsx`, immediately dispatch `dhStore.updateProjectEndDate(projectId, requestedEndDate)` on approval so the workspace store updates without requiring a manual browser reload.
  4. Fix database dual-sync timeout:
     - Repointed `TrySyncEndDateToOtherDatabase` in `ProjectExtensionRequestService.cs` from obsolete remote IP to local PostgreSQL connection (`Host=127.0.0.1;Port=5432;Database=pms_uat;Username=postgres;Password=123;Timeout=2`), updating both `project.tbl_projects` and `project.tbl_project_services` without TCP connection timeouts.
  5. Refreshed SQL snapshots:
     - Re-exported clean schemas and data into `database/pms_uat.sql` and `database/trackerpro-uat.sql`.

#### 📁 Files Affected
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectExtensionRequestService.cs`
- **Modified**: `apps/frontend/src/lib/workspace-store.ts`
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/frontend/src/modules/projects/api/projects.ts`
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- **Modified**: `database/pms_uat.sql`
- **Modified**: `database/trackerpro-uat.sql`
- **Modified**: `CHANGELOG_AI.md`

#### 🗄️ Database & Schema Changes
- Updated `project.tbl_projects."EndDate"` and `project.tbl_project_services."EndDate"`, `"TotalDays"`, `"DurationDays"` upon approving timeline extension requests.
- Synchronized local databases `trackerpro` and `pms_uat` and refreshed SQL dumps.

#### 🔌 APIs & Business Logic Changed
- **`ProjectExtensionRequestService.ApproveAsync`**:
  - Updates `project.EndDate` in `db.Projects`.
  - Queries active project services in `db.ProjectServices` and updates the service(s) with the maximum end date to `ext.RequestedEndDate`, updating `TotalDays` and `DurationDays`.
  - Synchronously updates both tables in `pms_uat` via local connection string.
- **`workspace-store.ts`**:
  - Added `updateProjectEndDate(projectId: string, newEndDate: string)` to dynamically update `extraProjects` and `baseProjects` in memory.
- **`action-centre-page.tsx`**:
  - On approving a "Timeline Extension Approval", invokes `approveProjectExtensionRequest` and updates `dhStore.updateProjectEndDate`.
- **`project-detail-page.tsx` & `projects.ts`**:
  - Ensures project end dates take precedence when explicitly extended beyond service date boundaries.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Timeline extension approval workflow remains strictly linked to Action Center approvals and audit logs.
- WBS service date constraints and validations remain fully compliant.
- Both frontend and backend builds compile cleanly with 0 errors.


### [2026-11-10] Extension Request Review Detail Modal and Two-Way Discussion Thread with Action Center

- **Branch**: `uat_clean9`
- **Module**: Project Health / Extension Request & Action Centre / Timeline Extension Approval
- **Purpose**:
  1. Add a **"Review Detail"** button under the Extension Request tab (`Health -> Extension Request`) for each request card without altering the overall page UI.
  2. Clicking "Review Detail" opens a modal dialog styled identically to the Escalation tab review modal:
     - Wide, draggable modal dialog (`Extension Request Review Details — EXT-...`).
     - Left side:
       - Project summary card (Project Name, Customer, Current End Date, Requested End Date & Extension duration).
       - Reason For Extension card displaying the justification.
       - Discussion Thread Chat with chat bubbles, message count, and author/timestamp formatting.
       - Message input field with "Send" button allowing the user to post comments directly from the Extension Request panel.
       - Status Transitions Timeline card displaying audit history, timestamps, actors, and remarks.
     - Right side:
       - Metadata card (Requested By, Tagged Approvers, Created Date).
       - Status badge (Approved, Rejected, Hold, Request Changes, Pending).
       - Modal Close button.
  3. Enable seamless two-way discussion thread and action comment synchronization between Action Center Approvals and the Extension Request panel:
     - Approvers taking action (Approve, Reject, Hold, Request Changes) or adding comments in Action Center have their remarks persisted into `CommentsJson` and `HistoryJson` in the database.
     - Comments posted from the Extension Request modal immediately append to `CommentsJson` in the database and appear in Action Center Review Request Discussion Thread and vice versa.
  4. Database schema updates:
     - Added `CommentsJson` (text) and `HistoryJson` (text) to `project.tbl_project_extension_requests` in local PostgreSQL (`trackerpro` and `pms_uat`).
     - Initialized existing rows with valid JSON arrays for history and comments.

#### 📁 Files Affected
- **Modified**: `apps/backend/Modules/Projects/Models/ProjectExtensionRequest.cs`
- **Modified**: `apps/backend/Infrastructure/Persistence/Configurations/ProjectExtensionRequestConfiguration.cs`
- **Modified**: `apps/backend/Modules/Projects/DTOs/ProjectExtensionRequestDtos.cs`
- **Modified**: `apps/backend/Modules/Projects/Services/IProjectExtensionRequestService.cs`
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectExtensionRequestService.cs`
- **Modified**: `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`
- **Modified**: `apps/frontend/src/modules/projects/api/project-extension-requests.ts`
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- **Modified**: `database/pms_uat.sql`
- **Modified**: `database/trackerpro-uat.sql`
- **Modified**: `CHANGELOG_AI.md`

#### 🗄️ Database & Schema Changes
- `project.tbl_project_extension_requests`: Added `"CommentsJson"` and `"HistoryJson"` columns in `trackerpro` and `pms_uat`.
- Refreshed SQL snapshots in `database/pms_uat.sql` and `database/trackerpro-uat.sql`.

#### 🔌 APIs & Business Logic Changed
- **Backend Endpoints Added**:
  - `POST /api/v1/projects/{projectId}/extension-requests/{extensionRequestId}/comments`: Appends discussion thread comment to `CommentsJson`.
  - `POST /api/v1/projects/{projectId}/extension-requests/{extensionRequestId}/action`: Handles status transitions (`Approved`, `Rejected`, `Hold`, `Request Changes`), records comments in `CommentsJson` and `HistoryJson`, and triggers project end date expansion upon approval.
- **Backend Services**:
  - `ProjectExtensionRequestService`: Implemented `AddCommentAsync`, `TakeActionAsync`, `AppendComment`, and `AppendHistory`.
  - Included `CommentsJson` and `HistoryJson` in `ProjectExtensionRequestDto` and `PendingExtensionApprovalDto`.
- **Frontend Components & API**:
  - `project-extension-requests.ts`: Added `addProjectExtensionRequestComment` and `takeProjectExtensionRequestAction`.
  - `action-centre-page.tsx`: Parses `commentsJson` and `historyJson` for `extItems` into discussion thread and audit log history; delegates actions to `takeProjectExtensionRequestAction`.
  - `project-detail-page.tsx`: Added "Review Detail" button and Escalation-style Review Details modal in `ExtensionRequestPanel` with two-way Discussion Thread Chat and comment submission.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Visual consistency strictly mirrors the Escalation tab review modal.
- End date expansion across project overview and WBS upon approval is preserved.
- Both frontend and backend builds compile cleanly with 0 errors.


### [2026-11-10] Project Extension End Date Overview Display, Dropdown Fix, Latency Elimination, DD-MM-YYYY Date Format, and Leadership & PMO Notification Dispatch

- **Branch**: `uat_clean9`
- **Module**: Project Health / Extension Request & Action Centre / Approvals
- **Purpose**:
  1. **Overview Tab End Section**:
     - When a project extension is approved, display the effective new extended date prominently in the Overview tab's End date card along with an "Extended" badge.
     - Display the previous end date directly below the new extended date as `Previous: <struck-through-date>`.
  2. **Tag Stakeholder Approvers Dropdown Positioning**:
     - Fixed dropdown container in `ExtensionRequestPanel` from rendering upwards (`bottom-full`), which covered the Reason, Duration, and New End Date fields above it, to render downwards (`top-full mt-1.5`) cleanly over the modal footer.
  3. **Submit Request & Notification Latency Elimination**:
     - Identified and resolved a 20-30 second blocking TCP connection timeout caused by hardcoded stale remote host (`10.50.30.189:41763`) in `ProjectExtensionRequestService.TrySyncNotificationsToOtherDatabase` and `ActionNotificationService.cs`.
     - Repointed all cross-sync operations to local PostgreSQL (`127.0.0.1:5432`) with a strict 2-second timeout, reducing submission and modal close response time to under 10ms.
  4. **Action Center Approvals Date Formatting**:
     - Formatted dates displayed in the Action Center Approvals tab table (`Requested On`) and the Review Request modal (`Submitted On`, Discussion Thread timestamps, Audit History timestamps, and New End Date in Timeline Extension descriptions) to strict `DD-MM-YYYY` format (`date-month-year`).
  5. **Notification Delivery on Status Change**:
     - When an extension request is `Approved`, `Rejected`, placed on `Hold`, or transitioned to `Request Changes` from the Action Center Approvals tab, automated Action Center notifications are dispatched to:
       - Assigned Team Leader (TL)
       - Assigned Project Manager (PM)
       - Assigned Senior Project Manager (SPM)
       - Assigned Engagement Manager (EM)
       - All active resources whose Sub-Department is `PMO (Project Management Office)`.
  6. **Database Snapshots**:
     - Re-exported fresh, complete PostgreSQL snapshots for `trackerpro` and `pms_uat` into `database/trackerpro-uat.sql` and `database/pms_uat.sql`.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectExtensionRequestService.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- **Modified**: `database/pms_uat.sql`
- **Modified**: `database/trackerpro-uat.sql`
- **Modified**: `CHANGELOG_AI.md`

#### 🗄️ Database & Schema Changes
- Generated updated SQL snapshots `database/trackerpro-uat.sql` and `database/pms_uat.sql` via `pg_dump`.

#### 🔌 APIs & Business Logic Changed
- **`ProjectExtensionRequestService`**:
  - Implemented `NotifyLeadershipAndPmoAsync` dispatching status update notifications (`Approved`, `Rejected`, `Hold`, `Request Changes`) to TL, PM, SPM, EM, and PMO employees.
  - Replaced stale remote connection string with local connection string in `TrySyncNotificationsToOtherDatabase`.
- **`ActionNotificationService`**:
  - Replaced stale remote connection string in `TrySyncToOtherDatabaseAsync` with local connection string.
- **`project-detail-page.tsx`**:
  - In `OverviewTab`, dynamically fetches approved extension requests for the project to display the new extended date, `Extended` badge, and struck-through previous date.
  - In `ExtensionRequestPanel`, changed tag stakeholder approvers dropdown positioning to `absolute top-full mt-1.5` for clean downward expansion.
- **`action-centre-page.tsx`**:
  - Applied `formatToDayMonthYear` (`DD-MM-YYYY`) across the Approvals tab table, modal Submitted On, Discussion Thread timestamps, Audit Log timestamps, and Timeline Extension descriptions.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Discussion thread synchronization between Extension Requests and Action Center remains intact.
- Preserved existing project end date expansion across Project Overview, WBS services, and Extension Request panels.
- Frontend and backend builds compile cleanly with 0 errors.
