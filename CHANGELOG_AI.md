# Changelog (AI Generated)

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

---

### Affected Files
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
