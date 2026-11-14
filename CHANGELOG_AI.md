# Changelog - Issue Resolution SLA Escalation Alert Request & Multi-Party Communication

## Summary of Changes
Extended the Issue Resolution SLA escalation workflow in Hangfire and Action Centre so that when Level 1 and Level 2 escalations trigger, recipients do not merely receive notification cards—they are assigned full Alert requests in their Action Centre Alerts tab. This grants Assigned Senior Project Managers (Level 1) and Heads of Department (Level 2) direct visibility into all previous conversation history from initial project leadership (Project Team Leader, Assigned Project Manager, Assigned Engagement Manager), the ability to communicate directly via the discussion thread, and permission to update governance/status (e.g., In Progress, Resolved, Closed).

---

## Affected Files
- `apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs`:
  - Updated `ExecuteIssueEscalationAsync` to resolve recipients and deliver Alert requests directly into `ProjectAlert.AudienceUserIds` and `ProjectAlert.EscalatedTo`.
  - Appends audit trail entries to `ProjectAlert.HistoryJson` with exact role attribution (`Assigned Senior Project Manager`, `Head of Department`).
  - Sets `Priority = "Critical"`, synchronizes `ChatJson` between `ProjectAlert` and `ProjectServiceEscalation`, and registers recipients in `tbl_project_service_escalation_stakeholders`.
  - Populates notification `HistoryJson` so Action Centre notification modals reflect full history.
- `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`:
  - Added fallback module code `"action-centre"` to `[RequireRbac]` attribute for alert endpoints (`GetAlerts`, `UpdateAlertGovernance`, `DownloadAlertAttachment`) ensuring all authenticated and assigned stakeholders can access alert actions.
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - Enhanced `UpdateAlertGovernanceAsync` with fine-grained authorization checks allowing assigned alert audience members, project leadership, and escalation stakeholders to participate in chat and change status.
- `apps/backend/Modules/Projects/DTOs/ProjectIssueDtos.cs`:
  - Updated `UpdateAlertStatusRequest` record to accept an optional `Comment` string.
- `apps/backend/Modules/Projects/Services/IProjectIssueService.cs` & `ProjectIssueService.cs`:
  - Updated `UpdateAlertStatusAsync` to accept optional comments, append them to `alert.ChatJson`, record them in `alert.HistoryJson`, and sync to `ProjectServiceEscalation.ChatJson`.
- `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`:
  - Passed `request.Comment` through to `projectIssueService.UpdateAlertStatusAsync`.
- `apps/backend/tests/PMS.IntegrationTests/IssueResolutionSlaIntegrationTests.cs`:
  - Added comprehensive end-to-end integration test `IssueResolution_Level1AndLevel2Escalation_AssignsAlertRequestAndChatAccess` verifying issue creation, initial alert audience, Level 1 escalation assignment to Assigned Senior Project Manager with chat communication, Level 2 escalation assignment to Head of Department with complete message history visibility, status transition to Resolved, and SLA instance completion.
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
  - Updated `canActOnAlert` to evaluate `isAlertAudience`, granting assigned alert audience members access to the Actions column, Review details modal, discussion thread chat, and status updates.

---

## Database Changes and Migrations
- **No schema migrations required**:
  - Leveraged existing JSON fields (`AudienceUserIds`, `EscalatedTo`, `ChatJson`, `HistoryJson`) on `project.tbl_project_alerts`.
  - Leveraged `project.tbl_project_service_escalation_stakeholders` table to store relational stakeholder entries for escalated employees.

---

## API Changes
- `PATCH /api/v1/projects/{projectId}/issues/{issueId}/alerts/{alertId}/status`:
  - Request body: `{ "status": string, "comment": string? }`
- `PATCH /api/v1/action-centre/alerts/{alertId}/governance`:
  - Authorized for all assigned audience members and stakeholders.
  - Allows concurrent status transitions and commentary.

---

## Business Logic
1. **Initial Issue Creation**:
   - Alert request and immediate notifications are delivered to Assigned Engagement Manager, Assigned Project Manager, and Project Team Leader.
   - SLA tracking begins with Scheduled breach check and Level 1 escalation events.
2. **Level 1 Escalation (Breach Execution)**:
   - Target role: `Assigned Senior Project Manager`.
   - Notification dispatched: Critical Level 1 SLA Escalation notification.
   - Alert request assigned: Senior Project Manager employee ID appended to `ProjectAlert.AudienceUserIds` and name to `ProjectAlert.EscalatedTo`.
   - Access: Assigned Senior Project Manager views the Alert in Action Centre Alerts tab, reads prior chat, participates in discussion thread, and can change status.
   - Scheduling: Schedules Level 2 escalation for the end of the next working day (6:00 PM IST) taking into account holidays and weekends.
3. **Level 2 Escalation (Follow-up Breach Execution)**:
   - Target role: `Head of Department`.
   - Notification dispatched: Critical Level 2 SLA Escalation notification.
   - Alert request assigned: Head of Department employee ID appended to `ProjectAlert.AudienceUserIds` and name to `ProjectAlert.EscalatedTo`.
   - Access: Head of Department views the Alert in Action Centre Alerts tab, reads all past communications from Project Team Leader, Assigned Project Manager, Assigned Engagement Manager, and Assigned Senior Project Manager, participates in discussion thread, and can change status.
4. **Resolution**:
   - Once marked "Resolved" or "Closed" by any authorized party, `slaTrackingService.CompleteTrackingAsync` completes the SLA instance and cancels pending Hangfire jobs.

---

## Preserved Functionality
- Task Start After Assigning SLA calculation, reminders, and escalations.
- Task Pause SLA reminders and notifications.
- Task Deadline SLA reminders and escalations.
- Exact role nomenclature enforcement (`Assigned Project Manager`, `Assigned Engagement Manager`, `Project Team Leader`, `Assigned Senior Project Manager`, `Head of Department`).

---

# Changelog - Notification Sequential ID, Modal Issue Section, Alert Status Sync & Tab Badge Clean-up

## Summary of Changes
Implemented sequential string identification for notifications (`0001`, `0002`, `0003`, etc.), enhanced the Notification Detail Modal to display the string ID in the window title, removed the raw ID from the metadata grid, and introduced a dedicated Issue details section (Title, Description, Issue Type) placed directly above the Comments section for issue-related notifications (hidden for non-issue notifications). Enhanced the Notification Inbox search to support searching by Notification ID across backend and frontend. Enabled real-time notification status synchronization across all recipients when any stakeholder updates the issue status from their Alert tab. Removed the unread count red circle badge from the Action Centre Notifications tab while strictly preserving the global notification bell count in the topbar.

---

## Affected Files
- `apps/backend/Modules/ActionCentre/Models/ActionNotification.cs`:
  - Added `NotificationNumber` integer property to the domain model mapped to database sequence `action.tbl_notifications_number_seq`.
- `apps/backend/Infrastructure/Persistence/Configurations/ActionNotificationConfiguration.cs`:
  - Configured `NotificationNumber` to have `ValueGeneratedOnAdd()`.
- `apps/backend/Infrastructure/Persistence/Seeding/DbInitializerHostedService.cs`:
  - Added idempotent migration initializing `action.tbl_notifications_number_seq` and assigning sequential `NotificationNumber` values to all existing notification records ordered chronologically by `CreatedAtUtc`.
- `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs`:
  - Added `NotificationCode`, `IssueTitle`, `IssueDescription`, and `IssueType` to `ActionNotificationDto`.
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - Included navigation property `.Include(n => n.Issue)` in queries.
  - Formatted `NotificationCode` as zero-padded 4-digit string (`0001`, `0002`, etc.).
  - Populated `IssueTitle`, `IssueDescription`, and `IssueType` from related `ProjectIssue`.
  - Extended notification search filter to match `NotificationNumber`.
  - Added multi-recipient notification status synchronization in `UpdateAlertGovernanceAsync` updating all notification records linked to the target `IssueId`.
- `apps/backend/Modules/Projects/Services/ProjectIssueService.cs`:
  - Added multi-recipient notification status synchronization in `UpdateAlertStatusAsync` updating all notification records linked to the target `IssueId`.
- `apps/backend/tests/PMS.IntegrationTests/IssueResolutionSlaIntegrationTests.cs`:
  - Enhanced integration test assertions verifying `NotificationCode` format, populated issue details, and synchronized notification statuses across all issue recipients upon alert resolution.
- `apps/frontend/src/lib/workspace-store.ts`:
  - Added `notificationCode`, `issueTitle`, `issueDescription`, and `issueType` fields to `DhNotification` interface.
- `apps/frontend/src/components/notification-detail-modal.tsx`:
  - Updated window title to format `Notification Details — <NotificationCode>` (e.g. `Notification Details — 0001`).
  - Removed Notification ID row from metadata grid, preserving Related Project, Related Task, Raised By, Date, and Time.
  - Added Issue Section displaying Issue Title, Description, and Issue Type directly above Comments section, conditionally rendered only when issue details are present.
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
  - Removed the red circle badge count (`pendingCount`) on the Notifications tab button.
  - Updated client-side search filter and placeholder to include searching by notification ID.
- `database/pms_uat.sql`:
  - Updated database dump with sequence `action.tbl_notifications_number_seq` and column `action.tbl_notifications.NotificationNumber`.

---

## Database Changes and Migrations
- **Sequence Added**:
  - `action.tbl_notifications_number_seq` (bigint, start 1, increment 1).
- **Column Added**:
  - `action.tbl_notifications."NotificationNumber"` (integer, default `nextval('action.tbl_notifications_number_seq'::regclass)`).
- **Backfill**:
  - All existing notification records backfilled with sequential numbers ordered chronologically by `CreatedAtUtc`.

---

## API Changes
- `GET /api/v1/action-centre/notifications`:
  - Response items include `notificationCode` (e.g. `"0001"`), `issueTitle`, `issueDescription`, and `issueType`.
  - Supports query parameter `search` matching against sequential notification number.
- `PATCH /api/v1/action-centre/alerts/{alertId}/governance` & `PATCH /api/v1/projects/{projectId}/issues/{issueId}/alerts/{alertId}/status`:
  - Status updates synchronize immediately to all related `action.tbl_notifications` records matching `IssueId`.

---

## Preserved Functionality
- Global notification bell count badge in top header (`app-topbar.tsx`) remains completely intact.
- Metadata in notification modal (Related Project, Related Task, Raised By, Date, Time) remains intact.
- Non-issue notification view modals cleanly omit the Issue Details section.
- Issue SLA Escalation workflow with multi-party communication and status transition.
- Exact role nomenclature enforcement (`Assigned Project Manager`, `Assigned Engagement Manager`, `Project Team Leader`, `Assigned Senior Project Manager`, `Head of Department`).

---

# Changelog - Action Centre Tables Header Theming, Pagination & Notification Modal Formatting

## Summary of Changes
Refined the Action Centre UI across all primary tabs (Bucket List, Approvals, Alerts, and Notifications). Removed the cluttered "Related Task" column from the Notifications table view while preserving it inside the View Details modal. Adjusted the font size of the Issue Title inside the Notification View modal Issue Details section to match normal metadata text. Added full pagination (page size selection, range indicator, and previous/next page navigation) to the Notification, Alert, Bucket List, and Approval tables matching the Employee Directory table pattern. Harmonized the table header color theme across all four Action Centre tables with the Employee Directory table design (`bg-blue-50/80 dark:bg-blue-950/45` header with `text-blue-950/85 dark:text-blue-100/85` and `border-slate-300 dark:border-slate-700`).

---

## Affected Files
- `apps/frontend/src/components/notification-detail-modal.tsx`:
  - Adjusted the Issue Title font styling from `text-sm font-semibold` to `text-xs font-medium` inside the Issue Details section to harmonize with adjacent fields.
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
  - Removed "Related Task" table header and table data cell from the Notifications tab table.
  - Adjusted empty state `colSpan` from 10 to 9 for the Notifications table.
  - Implemented reusable `TablePaginationFooter` styled identically to the Employee Directory pagination bar using `RowsPerPageSelect`, `paginateSlice`, `paginationRange`, and `totalPageCount`.
  - Added stateful pagination (`page`, `pageSize`, automatic reset on filter/search change, slice memoization) to:
    - **Notifications Table** (`NotificationsTab`)
    - **Alerts Table** (`AlertsTab`)
    - **Bucket List Table** (`BucketList`)
    - **Approvals Table** (`ApprovalsTab`)
  - Standardized the table header theme across all four tables to match the Employee Directory styling (`bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md text-left text-xs text-blue-950/85 dark:text-blue-100/85 border-b border-slate-300 dark:border-slate-700 shadow-2xs` with `px-3 py-2.5 font-semibold text-blue-950/85 dark:text-blue-100/85`).

---

## Database Changes and Migrations
- None. (Pure UI presentation, theming, and client-side pagination enhancements).

---

## API Changes
- None.

---

## Business Logic
1. **Notifications Table Simplification**:
   - The "Related Task" column is omitted from the table layout to reduce visual noise and avoid horizontal crowding.
   - Users inspect the related task by clicking "View", where it remains fully available in the metadata grid.
2. **Standardized Header Theming**:
   - Headers across Bucket List, Approvals, Alerts, and Notifications now consistently use the soft blue translucent theme and slate border from Employee Directory.
3. **Table Pagination Behavior**:
   - Each table defaults to 15 items per page with support for 10, 15, 25, 50, 100, and All.
   - Modifying search queries or dropdown filters automatically resets the active page to 1.
   - Footers accurately display item counts and ranges.

---

## Preserved Functionality
- "Related Task" remains clearly visible in the Notification Details modal.
- Global notification bell icon and badge in `app-topbar.tsx` remain unchanged.
- All filtering, search by ID, timer actions, approval actions, and governance workflows remain fully operational.
- Existing backend SLA tracking and database schemas remain intact.

---

# Changelog - Global Table Theming & Pagination Expansion (Projects, Customers, Repository & Project Masters)

## Summary of Changes
Expanded the Employee Directory color theme (translucent blue title header and bottom pagination bar) and full pagination controls to the Project List View table, Customer List View table, Document Repository table, and Existing Project Masters table (under the Project Master tab). Extracted the reusable `TablePaginationFooter` component to guarantee consistent pagination controls and theme styling across the entire frontend application.

---

## Affected Files
- `apps/frontend/src/components/table-pagination-footer.tsx`:
  - Created shared component encapsulating the Employee Directory pagination bar (`bg-blue-50/80 dark:bg-blue-950/45 backdrop-blur-md px-4 py-3 text-xs text-blue-950/80 dark:text-blue-100/80 border-t border-slate-300 dark:border-slate-700 shadow-xs`), with `RowsPerPageSelect` (10, 15, 25, 50, 100, All), item count range display, and Previous/Next buttons.
- `apps/frontend/src/modules/projects/pages/projects-list-page.tsx`:
  - Added stateful pagination (`tablePage`, `tablePageSize`, `pagedProjects`, reset on tab/search/year changes) to the Project list view table.
  - Updated table title header to match Employee Directory theme (`bg-blue-50/80 dark:bg-blue-950/45` with `text-blue-950/85 dark:text-blue-100/85 font-semibold` and `border-slate-300 dark:border-slate-700`).
  - Added `TablePaginationFooter` below the table.
- `apps/frontend/src/modules/customers/pages/customers-list-page.tsx`:
  - Added stateful pagination (`tablePage`, `tablePageSize`, `pagedCustomers`, reset on search/year/sort changes) to the Customer list view table.
  - Updated table title header to match Employee Directory theme (`bg-blue-50/80 dark:bg-blue-950/45` with `text-blue-950/85 dark:text-blue-100/85 font-semibold` and `border-slate-300 dark:border-slate-700`).
  - Added `TablePaginationFooter` below the table.
- `apps/frontend/src/modules/repository/pages/repository-page.tsx`:
  - Updated document table header to match Employee Directory theme (`bg-blue-50/80 dark:bg-blue-950/45` with `text-blue-950/85 dark:text-blue-100/85 font-semibold` and `border-slate-300 dark:border-slate-700`).
  - Replaced inline pagination footer with `TablePaginationFooter` matching the Employee Directory theme.
- `apps/frontend/src/modules/settings/components/masters/project-masters-section.tsx`:
  - Added stateful pagination (`page`, `pageSize`, `pagedItems`, reset on search query and contract type filter changes) to the Existing Project Masters table.
  - Updated table title header to match Employee Directory theme (`bg-blue-50/80 dark:bg-blue-950/45` with `text-blue-950/85 dark:text-blue-100/85 font-semibold` and `border-slate-300 dark:border-slate-700`).
  - Added `TablePaginationFooter` below the table.
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
  - Refactored pagination footers to use the shared `TablePaginationFooter` component across Notifications, Alerts, Bucket List, and Approvals tables.

---

## Database Changes and Migrations
- None. (Pure UI presentation, theming, and pagination enhancements).

---

## API Changes
- None.

---

## Preserved Functionality
- Card and Grid views for projects and customers remain intact and unaffected.
- Sorting and column resizing in the Customer list view table remain operational.
- Filter cascading, search, add, edit, and delete functionality in Project Masters remain operational.
- File upload, category counts, search, and document preview/download in Repository remain operational.
- All existing unit tests and integration tests continue to pass.

---

# Changelog - Bucket List Assignee Removal & Status Transitions Timeline Readability Formatting

## Summary of Changes
1. **Bucket List Task Column**: Removed the redundant `Assigned to: <Name>` text under the Task column in the Action Centre Bucket List table, since all tasks populated in the Bucket List are already implicitly assigned to the logged-in user.
2. **Status Transitions Timeline Readability Formatting**: Re-formatted the Status Transitions Timeline logs across the Extension Request Review Detail window, Escalation Review Detail window, and Governance Review Detail window. Pinned the timestamp column with non-shrinking, non-wrapping attributes so long transition remarks never compress or break the date/time string, and wrapped the message text with comfortable line height (`leading-relaxed`), word breaking, and distinct styling between status actions (`font-semibold text-foreground`) and quoted remarks/comments (`text-muted-foreground italic`), without converting to HTML tables or breaking the timeline into arbitrary multi-line attributes.

---

## Affected Files
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
  - Removed `Assigned to: {employeeName}` display in the Bucket List tab Task column.
  - Updated Governance Review Details modal's Status Transitions Timeline list:
    - Added `shrink-0 font-medium text-muted-foreground tabular-nums whitespace-nowrap` to date and time container to prevent wrapping/shrinking under large messages.
    - Updated message container to `min-w-0 flex-1 break-words text-foreground/90 text-[11px] leading-relaxed`.
    - Formatted action and remarks inline with distinct typographic hierarchy.
- `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
  - Updated Extension Request Review Details modal's Status Transitions Timeline logs:
    - Applied non-shrinking, non-wrapping date/time layout with `shrink-0 tabular-nums whitespace-nowrap`.
    - Formatted large messages with `min-w-0 flex-1 break-words text-[11px] leading-relaxed`, cleanly separating action text and quotation remarks.
  - Updated Escalation Review Details modal's Status Transitions Timeline logs:
    - Applied identical readable, non-collapsing inline timeline formatting.

---

## Database Changes and Migrations
- None. (Pure frontend display formatting).

---

## API Changes
- None.

---

## Preserved Functionality
- No HTML `<table>` or tabular alterations were made to the timeline sections.
- No changes to modal window structures, actions, comments/chat threads, or submission handlers.
- Task navigation links in the Bucket List remain fully functional.
- All frontend and backend builds and test suites continue to pass cleanly.

---

# Changelog - WBS Escalation Multi-Level SLA Tracking & Hangfire Escalation Workflow

## Summary of Changes
Implemented end-to-end SLA tracking and multi-tier Hangfire escalation for WBS Escalations (raised under the Service-wise Prerequisite Tracking section in the Project WBS tab). When a WBS Escalation is raised, selected stakeholders receive immediate notifications and Alert requests in their Action Centre Alerts tab with discussion and status transition permissions. If an assigned stakeholder resolves or closes the escalation within 2 working days, Level 1 escalation is prevented and the SLA instance is marked Completed. If unresolved by EOD of the next 2 working days (18:00 IST), Hangfire triggers Level 1 escalation: the Assigned Senior Project Manager (SPM) receives a Critical notification and an assigned Alert request (with full chat history and status update access), and Level 2 escalation is scheduled for EOD of the next 1 working day. If still unresolved by EOD of the next 1 working day, Level 2 escalation executes: the Head of Department (HOD, whose On Floor Role is `Head Of Department`) receives a Critical notification and an assigned Alert request with full prior chat visibility and status update permissions.

---

## Affected Files
- `apps/backend/Modules/Sla/Services/SlaTrackingService.cs`:
  - Added default SLA policy for `WBS Escalation` and `Service Escalation` with `TatDurationMinutes = 1080` (2 working days * 540 min/day, 09:00-18:00 IST), `CalculationMode = SlaCalculationMode.EndOfDay`, `FirstEscalationAfterMinutes = 0`, and `SecondEscalationAfterMinutes = null`.
  - Configured `isDynamicL2` for `WBS Escalation` and `Service Escalation` so Level 2 is dynamically scheduled upon Level 1 breach execution.
- `apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs`:
  - Added dispatch routing in `ExecuteBreachCheckAsync` and `ExecuteEscalationAsync` for `WBS Escalation`.
  - Implemented `ExecuteWbsBreachCheckAsync` and `ExecuteWbsEscalationAsync`:
    - Checks whether the escalation or alert is already `Resolved` or `Closed`; if so, skips execution immediately (guaranteeing early resolution prevents Level 1 escalation).
    - Level 1 Escalation: Resolves Assigned Senior Project Manager, dispatches Critical notification and Alert request (`AudienceUserIds`, `EscalatedTo`, `Stakeholders`), elevates priority to `Critical`, logs audit entry in `HistoryJson`, and schedules Level 2 dynamically by EOD of the next 1 working day.
    - Level 2 Escalation: Verifies resolution status, resolves Head of Department whose On Floor Role is `Head Of Department`, dispatches Critical notification and Alert request (`AudienceUserIds`, `EscalatedTo`, `Stakeholders`), and records audit entry.
- `apps/backend/Modules/Projects/Services/ProjectServiceEscalationService.cs`:
  - Injected `ISlaTrackingService` into `ProjectServiceEscalationService`.
  - Integrated `slaTrackingService.StartTrackingAsync` upon WBS Escalation creation with `ActivityType = "WBS Escalation"`, `EntityId = row.Id`, and target deadline calculated as EOD of next 2 working days.
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - In `UpdateAlertGovernanceAsync`: On status change to `Resolved` or `Closed` on an alert with `ServiceEscalationId`, completes SLA tracking via `slaTrackingService.CompleteTrackingAsync` and synchronizes status to all related WBS Escalation notifications.
- `apps/backend/Modules/Projects/Services/ProjectIssueService.cs`:
  - In `UpdateAlertStatusAsync`: On status change to `Resolved` or `Closed` on an alert with `ServiceEscalationId`, completes SLA tracking and synchronizes status across all related WBS Escalation notifications.
- `apps/backend/Modules/Sla/Services/SlaRecipientResolver.cs`:
  - Enhanced `ResolveSeniorProjectManagersAsync` and `ResolveHeadOfDepartmentsAsync` with case-insensitive matching for `Head Of Department` on floor roles, designations, and roles.
- `apps/backend/tests/PMS.IntegrationTests/WbsEscalationSlaIntegrationTests.cs`:
  - Created end-to-end integration test suite verifying early resolution prevention of Level 1 escalation, Hangfire Level 1 escalation dispatch to Senior Project Manager with Alert request, and Level 2 escalation dispatch to Head of Department.

---

## Database Changes and Migrations
- **No schema migrations required**:
  - Leveraged existing SLA tracking tables (`sla.tbl_sla_tracking_instances`, `sla.tbl_sla_tracking_events`), alert tables (`project.tbl_project_alerts`, `project.tbl_project_service_escalations`), and stakeholder relational table (`project.tbl_project_service_escalation_stakeholders`).

---

## API Changes
- None (Leveraged existing WBS Escalation and Action Centre Alert APIs: `POST /api/v1/projects/{projectId}/services/{serviceId}/escalations`, `PATCH /api/v1/action-centre/alerts/{alertId}/governance`, and `PATCH /api/v1/projects/{projectId}/issues/{issueId}/alerts/{alertId}/status`).

---

## Business Logic
1. **Initial WBS Escalation Creation**:
   - User raises an escalation for a service under WBS Prerequisite Tracking and selects stakeholders (`Escalate To (Select Stakeholders)`).
   - Selected stakeholders receive immediate notifications and Alert requests in their Action Centre Alerts tab with chat and status change permissions.
   - SLA tracking starts with a 2-working-day TAT ending at EOD (18:00 IST).
2. **Early Resolution (< 2 Working Days)**:
   - If any selected stakeholder updates the status to `Resolved` or `Closed` from their Alert tab before the deadline, SLA tracking is marked `Completed` and pending Hangfire jobs are bypassed/cancelled. Level 1 escalation does not occur.
3. **Level 1 Escalation (At Breach - EOD of Next 2 Days)**:
   - If unresolved by 18:00 IST of the 2nd working day, Hangfire executes the Level 1 breach check.
   - Assigned Senior Project Manager (SPM) receives a Critical notification and is added to `AudienceUserIds`, `EscalatedTo`, and `Stakeholders` of the Alert.
   - SPM can review previous chat history, participate in the discussion thread, and update the status.
   - Level 2 escalation is scheduled for EOD of the next 1 working day (18:00 IST).
4. **Level 2 Escalation (EOD of Next 1 Day from Level 1)**:
   - If still unresolved by 18:00 IST of the next working day, Hangfire executes Level 2 escalation.
   - Head of Department whose On Floor Role is `Head Of Department` receives a Critical notification and is added to `AudienceUserIds`, `EscalatedTo`, and `Stakeholders` of the Alert.
   - HOD has full access to the Alert tab, complete conversation history, and status update permissions.

---

## Preserved Functionality
- Issue Resolution SLA multi-level escalation workflow.
- Task Start After Assigning, Task Pause, and Task Deadline SLAs.
- Global topbar notification bell count badge and Action Centre table pagination/theming.
- Existing WBS prerequisite tracking, file attachments, and discussion threads.

---

# Changelog - UI Refinements: Leadership Change Buttons, Escalation Table Pagination, Bucket List Fixed Layout & Alert/Approval ID Clean-up

## Summary of Changes
1. **Overview Tab Leadership "Change" Buttons**: Refactored the UI of `LeadershipBlock` cards (Senior Project Managers, Project Managers, and Team Leads). Replaced the full-width block buttons at the bottom of cards with compact, well-proportioned `Change` action buttons positioned in the card header next to the role title, featuring a subtle border divider, pencil icon, and reduced card minimum height for a sleek, balanced appearance.
2. **Health Tab Escalations Table Theming & Pagination**: Applied the Employee Directory theme (`bg-blue-50/80 dark:bg-blue-950/45` header with `text-blue-950/85 dark:text-blue-100/85` and `border-slate-300 dark:border-slate-700`) and integrated `TablePaginationFooter` with automatic page reset upon filter switching in the Health -> Escalations tab.
3. **Action Centre Bucket List Column Position Stability**: Fixed table header column positions across all filter states (e.g., when switching from "All Priority" to empty states like "On Hold") by enforcing `table-fixed`, explicit `<colgroup>` column width percentages, and cell text truncation.
4. **Alerts Tab Table Clean-up**: Removed the redundant "Alert ID" column from the Action Centre Alerts table (the Alert ID remains fully visible in the Alert Review Details modal).
5. **Approvals Tab Table Clean-up**: Removed the redundant "Approval ID" column from the Action Centre Approvals table (the Approval ID remains fully visible in the Request Review modal) and adjusted empty/loading state column spans.

---

## Affected Files
- `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
  - Refactored `LeadershipBlock` to move the "Change" action into the card header with a compact, stylish button (`px-2 py-0.5 text-[11px]`) and pencil icon, reducing container height from `min-h-[120px]` to `min-h-[90px]`.
  - Updated `HealthEscalationsPanel` table header styling to match the Employee Directory theme (`bg-blue-50/80 dark:bg-blue-950/45`, `border-slate-300 dark:border-slate-700`).
  - Added stateful pagination (`page`, `pageSize`, `pagedEscalations`, and reset on `activeFilter`) and `TablePaginationFooter` to the Health Escalations table.
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
  - Added `table-fixed min-w-[980px]` and `<colgroup>` to the Bucket List table, and applied truncation to Task, Project, and Assigned By cells to ensure column positions remain strictly identical across all filters including empty states.
  - Removed "Alert ID" table header and table cell from the Alerts tab table.
  - Removed "Approval ID" table header and table cell from the Approvals tab table, and updated empty/loading `colSpan` values (`canManageApprovals ? 6 : 5`).

---

## Database Changes and Migrations
- None. (Pure UI presentation, theming, table layout stability, and pagination enhancements).

---

## API Changes
- None.

---

## Preserved Functionality
- Leadership assignment modals and workflows (`ChangeLeaderPanel`) remain fully functional.
- Escalation review modals, status transitions, discussion threads, and backend SLA tracking remain intact.
- Bucket List timers, status changes, task links, and issue raising modals remain fully operational.
- Alert Review Details and Approval Request Review modals continue to display the full IDs in titles and metadata.
- All backend unit tests and integration tests continue to pass.

---

# Changelog - Level 2 WBS Escalation to HOD Fix, Modal Details, Empty Comments Clean-up & Universal Status Synchronization

## Summary of Changes
1. **Level 2 WBS Escalation Notification and Alert Request Delivery to HOD**:
   - Overhauled `SlaRecipientResolver.ResolveHeadOfDepartmentsAsync`: eliminated the restrictive `.Take(1)` clause that previously caused only the first matching HOD employee to receive notifications/alerts, ignoring other on-floor and department HODs.
   - Expanded matching logic to find active employees by on-floor roles (`Head Of Department`, `HOD`), RBAC user roles containing `HOD` (such as `Testing - HOD`, `SOC - HOD`, `Consulting - HOD`), matching employee designations, and employees linked to HOD user accounts.
   - Updated `SlaBackgroundJobWorker.ExecuteWbsEscalationAsync` to register both employee IDs and linked user IDs (`emp.UserId`) in `ProjectAlert.AudienceUserIds` and `ProjectAlert.EscalatedTo`, ensuring that any logged-in HOD user immediately sees the Alert request in their Action Centre Alerts tab with chat and status update permissions.
   - Explicitly assigned `ServiceEscalationId = esc.Id` on all generated `ActionNotification` records.
2. **Notification View Modal WBS Escalation Details**:
   - Added `ServiceEscalationId` foreign key and navigation property to `ActionNotification` domain model and EF Core entity configuration.
   - Added automatic idempotent database migration in `OrgRoleMatrixHostedService` and `DbInitializerHostedService` to ensure `action.tbl_notifications."ServiceEscalationId"` column and foreign key constraint exist in all environments (including `AutoMigrate=false`).
   - Populated `ServiceEscalationId = row.Id` on creation in `ProjectServiceEscalationService.cs` and preserved `ServiceName` and `EscalationType` on `ProjectAlert`.
   - Updated `ActionNotificationService.MapDto` to map fallback issue fields from `ServiceEscalation` (`IssueTitle = n.Issue?.Subject ?? n.ServiceEscalation?.Subject`, `IssueDescription = n.Issue?.Description ?? n.ServiceEscalation?.Description`, `IssueType = n.Issue?.IssueType ?? n.ServiceEscalation?.EscalationType`).
   - Updated `notification-detail-modal.tsx` to render the details card as "WBS Escalation Details" with labels "Subject", "Escalation Type", and "Description" when viewing a WBS Escalation notification.
3. **Hide Empty Comments Section**:
   - Updated `notification-detail-modal.tsx` so that when `displayList.length === 0` (no comments, remarks, or notes exist), the entire Comments section is completely omitted from the modal across all notification windows.
4. **Universal Status Synchronization from Alert Tab to Notifications**:
   - Removed the restrictive `Resolved` / `Closed` condition from `ActionNotificationService.UpdateAlertGovernanceAsync` and `ProjectIssueService.UpdateAlertStatusAsync`.
   - Now on **any** status transition (`Open`, `In Progress`, `Acknowledged`, `Resolved`, `Closed`) performed from the Alert tab, the system updates the `Status` and appends the latest audit history to all `ActionNotification` records linked to that `ServiceEscalationId` (and `IssueId`).
5. **Architectural Verification & Test Coverage**:
   - Added and passed automated end-to-end integration tests in `WbsEscalationSlaIntegrationTests.cs` verifying Level 1 and Level 2 WBS Escalation SLA breaches, alert audience assignments, and notification data mapping.
   - Verified that all unit tests (`PMS.UnitTests`) and integration tests (`PMS.IntegrationTests`) pass cleanly.

---

## Affected Files
- `apps/backend/Modules/ActionCentre/Models/ActionNotification.cs`:
  - Added `ServiceEscalationId` property and `ProjectServiceEscalation? ServiceEscalation` navigation property.
- `apps/backend/Infrastructure/Persistence/Configurations/ActionNotificationConfiguration.cs`:
  - Configured one-to-many relationship with `ProjectServiceEscalation` and `OnDelete(DeleteBehavior.SetNull)`.
- `apps/backend/Infrastructure/Persistence/Seeding/OrgRoleMatrixHostedService.cs` & `DbInitializerHostedService.cs`:
  - Added idempotent SQL migration to add `"ServiceEscalationId"` column, index, foreign key, and historical notification backfill.
- `apps/backend/Modules/Projects/Services/ProjectServiceEscalationService.cs`:
  - Populated `ServiceEscalationId = row.Id` on action notification creation and set `ServiceName` and `EscalationType` on `ProjectAlert`.
- `apps/backend/Modules/Sla/Jobs/SlaBackgroundJobWorker.cs`:
  - In `ExecuteWbsEscalationAsync`: populated `ServiceEscalationId = esc.Id` and included both employee IDs and user IDs in `alert.AudienceUserIds`.
- `apps/backend/Modules/Sla/Services/SlaRecipientResolver.cs`:
  - In `ResolveHeadOfDepartmentsAsync`: removed `.Take(1)` restriction and implemented robust multi-role fallback resolution.
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - Included navigation property `.Include(n => n.ServiceEscalation)` across queries.
  - Mapped DTO fields from `n.ServiceEscalation`.
  - Added multi-recipient notification status and history synchronization on any status transition in `UpdateAlertGovernanceAsync`.
- `apps/backend/Modules/Projects/Services/ProjectIssueService.cs`:
  - Added multi-recipient notification status and history synchronization on any status transition in `UpdateAlertStatusAsync`.
- `apps/frontend/src/components/notification-detail-modal.tsx`:
  - Added dedicated WBS Escalation Details display.
  - Conditionally hid Comments section when `displayList.length === 0`.
- `apps/backend/tests/PMS.IntegrationTests/WbsEscalationSlaIntegrationTests.cs`:
  - Integration tests verifying full Level 1 and Level 2 WBS Escalation SLA breach flow.

---

## Database Changes and Migrations
- Added column `action.tbl_notifications."ServiceEscalationId"` (uuid, nullable) referencing `project.tbl_project_service_escalations("Id")` on delete set null.
- Created index `IX_tbl_notifications_ServiceEscalationId` on `action.tbl_notifications ("ServiceEscalationId") WHERE ("DeletedAtUtc" IS NULL)`.
- Automatically applied via `OrgRoleMatrixHostedService` on startup.

---

## API Changes
- None (DTO response model `ActionNotificationDto` now returns populated `IssueTitle`, `IssueDescription`, and `IssueType` for WBS Escalation notifications).

---

## Business Logic
1. **WBS Escalation SLA Level 1 (At Breach - EOD of Next 2 Days)**:
   - Target role: `Assigned Senior Project Manager`.
   - Notification and Alert request delivered with chat access and status update permissions.
   - Schedules Level 2 SLA escalation job for EOD of the next 1 working day (18:00 IST).
2. **WBS Escalation SLA Level 2 (At Breach - EOD of Next 1 Day from Level 1)**:
   - Target role: All active `Head of Department` employees.
   - All HODs receive critical notification cards and direct assignment in `ProjectAlert.AudienceUserIds`.
   - In Action Centre Alerts tab, HODs can view full past chat history, participate in discussion threads, and update status.
3. **Notification Details View**:
   - For WBS Escalation notifications: shows Subject, Escalation Type, Description directly above the Comments section.
   - For all notifications: hides Comments section if no remarks/comments exist.
4. **Alert Status Synchronization**:
   - Any status change in Alert tab (`Open`, `In Progress`, `Acknowledged`, `Resolved`, `Closed`) immediately updates the status and audit trail history of all related notifications.

---

## Preserved Functionality
- Issue Resolution SLA Level 1 & Level 2 multi-level escalation workflow.
- Task Start After Assigning, Task Pause, and Task Deadline SLAs.
- Global topbar notification bell counter badge.
- Action Centre table layouts, pagination, and theme alignments.



---

## [uat_clean12] - 2026-11-14

### Resource Onboarding & Resource Profile Edit Governance Notifications

#### Summary
Implemented dedicated Action Centre notifications for Resource Onboarding and Resource Profile Updates:
1. **Resource Onboarding Notification**: When a new resource is onboarded successfully, Low-priority notifications with Status `"Done"`, Priority `"Low"`, and Related Project as `"-"` are dispatched exclusively to:
   - The resource's assigned Reporting Manager (`ReportingManagerId`).
   - Active resources whose Sub-Department is `EM (Engagement Manager)` or `PMO (Project Management Office)` AND whose On Floor Role is `Sr. Manager` or `Manager`.
2. **Resource Profile Edit Notification**: When an existing resource profile is modified, a Low-priority notification with Status `"Done"`, Priority `"Low"`, and Related Project as `"-"` is dispatched exclusively to:
   - The resource's assigned Reporting Manager (`ReportingManagerId`) into their Action Centre notification tab.
   - Title dynamically formats the exact modified fields and editor: `{Resource name} change their profile {field(s)} by {Who edit the profile}` (e.g. `John Doe change their profile Phone, First Name by Admin User`).
   - Raised By: the user who edited the profile (`performerName` / current user).
   - Related Project: `"-"`.
   - If no fields were modified, no notification is dispatched.

---

### 1. Affected Files
- `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- `apps/backend/Modules/Resources/Services/EmployeeService.cs`
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- `apps/backend/tests/PMS.IntegrationTests/ResourceNotificationIntegrationTests.cs`
- `apps/backend/tests/PMS.IntegrationTests/ResourceAllocationSlaIntegrationTests.cs`
- `CHANGELOG_AI.md`

---

### 2. Database Changes & Migrations
- No database alterations required. Utilizes existing tables `action.tbl_notifications`, `resource.tbl_employees`, and `resource.tbl_onfloorrole` with dual database synchronization to secondary UAT database.

---

### 3. API & Business Logic Changes
1. **Contract Update** (`IActionNotificationService.cs`):
   - Added method `NotifyResourceProfileUpdatedAsync(Guid employeeId, string employeeName, string employeeCode, Guid? reportingManagerId, IReadOnlyList<string> modifiedFields, string? performerName, Guid? performerEmployeeId, CancellationToken ct = default);`.

2. **Onboarding & Profile Update Dispatch** (`ActionNotificationService.cs`):
   - **`NotifyResourceOnboardedAsync`**:
     - Sets `Status = "Done"`, `ProjectName = "-"`, `Priority = "Low"`.
     - Recipient resolution targets the assigned `ReportingManagerId`, plus active employees whose Sub-Department is `EM (Engagement Manager)` or `PMO (Project Management Office)` AND whose On Floor Role is `Sr. Manager` or `Manager`.
   - **`NotifyResourceProfileUpdatedAsync`**:
     - Resolves the resource's assigned `ReportingManagerId`; exits early if no reporting manager is assigned.
     - Formats title string: `"{employeeName} change their profile {fieldsText} by {editorName}"`.
     - Creates `ActionNotification` with `Type = "Resource Profile Updated"`, `Priority = "Low"`, `Status = "Done"`, `ProjectName = "-"`, `RaisedByName = editorName`, `RaisedByEmployeeId = performerEmployeeId`, `RelatedTask = employeeCode`.
     - Dual database syncs via `TrySyncNotificationsToOtherDatabase`.
   - **DTO Mapping (`MapDto`)**:
     - Enhanced `relatedProj` expression so that if `ProjectCode` is absent and `ProjectName` is null or empty/whitespace, it returns `"-"`.

3. **Trigger on Employee Update** (`EmployeeService.cs`):
   - In `UpdateEmployeeAsync`, after persisting entity changes and updating linked user account, checks `distinctChanges.Count > 0` and `entity.ReportingManagerId.HasValue`.
   - Resolves current performer employee identity and dispatches `NotifyResourceProfileUpdatedAsync`.

4. **Frontend Table & Search Hardening** (`action-centre-page.tsx`):
   - Guarded search filter against null/undefined `relatedProject`, `raisedBy`, `type`, and `title` properties.

---

### 4. Existing Functionality Preserved
- Employee onboarding CRUD, identity validation, document moving on code changes, and activity logging remain intact.
- Resource allocation, extension request, additional customer requirement, and WBS service escalation SLA escalation pipelines remain intact.
- Bucket list task stop, pause, resume, and deadline notifications remain functional.

---

### 5. Verification & Testing
- `PMS.IntegrationTests` (`ResourceNotificationIntegrationTests.cs`): 3 passed, 0 failed.
  - Test 1 (`ResourceOnboarding_DispatchesNotification_ToReportingManager_And_EmPmoLeadership`): Verified notification with `Priority = "Low"`, `Status = "Done"`, `RelatedProject = "-"` delivered to assigned Reporting Manager and EM/PMO managers.
  - Test 2 (`ResourceProfileEdit_DispatchesNotification_OnlyToResourceReportingManager`): Verified editing Phone and First Name dispatches notification exclusively to assigned Reporting Manager with title matching `{Name} change their profile Phone, First Name by {Performer}`, `Status = "Done"`, `Priority = "Low"`, `RelatedProject = "-"`, and verifies zero notifications delivered to other employees.
  - Test 3 (`ResourceProfileEdit_WhenNoFieldsChange_DoesNotDispatchNotification`): Verified updating an employee with unchanged fields does not trigger any notification.
- `ResourceAllocationSlaIntegrationTests`: 3 passed, 0 failed.
- All 104 Unit Tests in `PMS.UnitTests`: Passed (104 passed, 0 failed).
- Backend API (`http://localhost:5194/health`): Verified `Healthy`.
- Frontend Dev Server (`http://localhost:3000`): Verified `200 OK`.


---

## [uat_clean12] - 2026-11-14

### Customer Onboarding, Customer Profile Edit & Manager Change Governance Notifications

#### Summary
Implemented dedicated Action Centre notifications for Customer Onboarding, Customer Profile Edits, Sub-Venture Edits, and Manager (Engagement Manager / Sales Manager) Changes:
1. **Customer & Sub-Venture Onboarding Notifications**:
   - When a Customer or Sub-Venture is onboarded, notifications are dispatched **exclusively** to:
     - Resources whose On Floor Role is `Head Of Department` or `Leader` AND whose Sub-Department is `EM (Engagement Manager)` (strictly excluding Team Leader).
     - The customer's assigned **Engagement Manager**.
     - The customer's assigned **Sales Manager**.
   - Notifications are populated with `Priority = "Low"`, `Status = "Pending"`, and `ProjectName = "-"`.
2. **Customer / Sub-Venture Profile Edit Notifications**:
   - When any customer profile field or existing sub-venture (Name, Notes) is edited:
     - Dispatched **exclusively** to EM HODs/Leaders, the assigned Engagement Manager, and the assigned Sales Manager.
     - Title formats:
       - Customer edited: `"{Customer Name} is edited"`
       - Sub-venture edited: `"{Subventure Name} is edited"`
     - Attributes: `Status = "edited"`, `Priority = "Low"`, `ProjectName = "-"`, `RaisedByName = <performerName / currentUser>`.
3. **Engagement Manager / Sales Manager Changed Notifications**:
   - When the Engagement Manager or Sales Manager of a customer is modified:
     - Dispatched **exclusively** to EM HODs/Leaders, the customer's assigned Engagement Manager, Sales Manager, and the previous manager.
     - Title format:
       `"{Previous Manager or manager role} of the Customer ({Customer Name}) change to the {Changed Manager Name}"`
       (e.g., `"Atharv Reddy of the Customer (Acme Corp) change to the John Doe"` or `"Engagement Manager of the Customer (Acme Corp) change to the John Doe"`).
     - Attributes: `Status = "edited"`, `Priority = "Low"`, `ProjectName = "-"`, `RaisedByName = <performerName / currentUser>`.
4. **Action Centre UI Enhancements**:
   - Added badge styling, icon representation (`Pencil`), and filter dropdown support for `"edited"` status in Action Centre Notifications.

---

### 1. Affected Files
- `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- `apps/backend/Modules/Customers/Services/ClientService.cs`
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- `apps/backend/tests/PMS.IntegrationTests/CustomerNotificationIntegrationTests.cs`
- `CHANGELOG_AI.md`

---

### 2. Database Changes & Migrations
- No database alterations required. Utilizes existing tables `action.tbl_notifications`, `resource.tbl_employees`, `resource.tbl_onfloorrole`, `customer.tbl_clients`, and `customer.tbl_subventures` with secondary database synchronization.

---

### 3. API & Business Logic Changes
1. **Contract Update** (`IActionNotificationService.cs`):
   - Added `NotifyCustomerEditedAsync` and `NotifySubVentureEditedAsync`.
   - Updated `NotifyCustomerOnboardedAsync` and `NotifySubVentureOnboardedAsync` signatures to accept optional `engagementManagerId`, `engagementManager`, `salesManagerId`, `salesManager`.
   - Updated `NotifyCustomerManagerChangedAsync` to accept `previousManagerName` and `previousManagerEmployeeId`.

2. **Recipient Resolution & Dispatch** (`ActionNotificationService.cs`):
   - Implemented `ResolveCustomerNotificationRecipientsAsync`:
     - Queries active resources where Sub-Department is `EM (Engagement Manager)` AND On Floor Role is `Head Of Department` or `Leader` (excluding Team Leader).
     - Resolves and adds customer's assigned Engagement Manager and Sales Manager (by ID or full name).
     - Resolves and adds additional manager (e.g., previous manager during manager change).
     - Deduplicates all recipient employees.
   - **`NotifyCustomerOnboardedAsync` & `NotifySubVentureOnboardedAsync`**:
     - Uses `ResolveCustomerNotificationRecipientsAsync`.
     - Sets `ProjectName = "-"`, `Priority = "Low"`, `Status = "Pending"`.
   - **`NotifyCustomerEditedAsync`**:
     - Title: `"{clientName} is edited"`.
     - Sets `Status = "edited"`, `Priority = "Low"`, `ProjectName = "-"`, `RaisedByName = performerName`.
   - **`NotifySubVentureEditedAsync`**:
     - Title: `"{subVentureName} is edited"`.
     - Sets `Status = "edited"`, `Priority = "Low"`, `ProjectName = "-"`, `RaisedByName = performerName`.
   - **`NotifyCustomerManagerChangedAsync`**:
     - Formats title: `"{managerLabel} of the Customer ({clientName}) change to the {managerName}"`.
     - Sets `Status = "edited"`, `Priority = "Low"`, `ProjectName = "-"`, `Type = "{managerRole} Changed"`, `RaisedByName = performerName`.

3. **Customer Service Integrations** (`ClientService.cs`):
   - In `CreateClientAsync`:
     - Passes assigned `EngagementManagerId`, `EngagementManager`, `SalesManagerId`, `SalesManager` to `NotifyCustomerOnboardedAsync` and `NotifySubVentureOnboardedAsync`.
   - In `UpdateClientAsync`:
     - Tracks `clientProfileChanged` across all customer-level fields (Name, Industry, ContactEmail, ClientType, Status, Country, City, Notes, etc.).
     - Tracks `editedSubVentures` for any modified sub-venture names or notes.
     - Preserves `previousEm`, `previousEmId`, `previousSm`, `previousSmId`.
     - On manager change (`emChanged` / `smChanged`): invokes `NotifyCustomerManagerChangedAsync` with previous and new manager details.
     - On profile change (`clientProfileChanged`): invokes `NotifyCustomerEditedAsync`.
     - On sub-venture edit: invokes `NotifySubVentureEditedAsync` for each modified sub-venture.
     - On new sub-venture addition: invokes `NotifySubVentureOnboardedAsync`.

4. **Action Centre UI** (`action-centre-page.tsx`):
   - Added `"edited"` style: `bg-blue-50 text-blue-700 border-blue-200`.
   - Added `"edited"` icon: `Pencil` icon.
   - Added `"edited"` and `"Done"` to `availableStatuses` filter dropdown.

---

### 4. Existing Functionality Preserved
- Customer creation, update, soft-delete, client code allocation, and sub-venture code generation remain fully intact.
- Resource onboarding and profile edit notifications remain fully intact.
- Multi-level SLA escalation tracking across WBS services, extension requests, additional requirements, and resource allocations remain fully functional.
- Bucket list task workflows and topbar counters remain unaffected.

---

### 5. Verification & Testing
- Automated Integration Tests in `CustomerNotificationIntegrationTests.cs`: 4 passed, 0 failed.
  - Test 1 (`CustomerOnboarding_DispatchesNotification_ToEmLeadership_And_AssignedManagers`): Customer onboarding dispatches notification to EM HOD/Leader and assigned managers with `Priority = "Low"`, `RelatedProject = "-"`.
  - Test 2 (`CustomerProfileEdit_DispatchesNotification_WithEditedStatusAndTitle`): Customer profile update dispatches notification with title `"{Customer Name} is edited"`, `Status = "edited"`, `Priority = "Low"`, `ProjectName = "-"`.
  - Test 3 (`SubVentureEdit_DispatchesNotification_WithSubVentureEditedTitle`): Sub-venture modification dispatches notification with title `"{Subventure Name} is edited"`, `Status = "edited"`, `Priority = "Low"`, `ProjectName = "-"`.
  - Test 4 (`CustomerManagerChanged_DispatchesNotification_WithExactTitleFormat`): Engagement Manager update dispatches notification with title `"{prevEm} of the Customer ({clientName}) change to the {newEm}"`, `Status = "edited"`, `Priority = "Low"`, `ProjectName = "-"`.
- Unit & Integration Test Suite regression: `ResourceNotificationIntegrationTests` (3 passed, 0 failed), Customer CRUD tests passing.


---

## [uat_clean12] - 2026-11-14

### WBS Creation & Standardized Initial/Edit Lifecycle Governance Notifications

#### Summary
Standardized the status lifecycle and recipient routing for WBS creation, Resource onboarding/editing, and Customer onboarding/editing:
1. **WBS Created Governance Notification**:
   - Dispatched **exclusively** to resources whose Sub-Department is `EM (Engagement Manager)` or `PMO (Project Management Office)` **AND** whose On Floor Role is `Head Of Department` (strictly excluding Team Leaders and non-HODs).
   - **Title**: `"WBS or the Project is Created with the {Project name}"`.
   - **Status**: `"Created"`.
   - **Priority**: `"Low"`.
   - **Related Project**: `"-"` (enforced with `ProjectName = "-"`, `ProjectCode = null`, and `MapDto` mapping).
   - **Raised By**: The user who created the WBS / project (`createdByName ?? currentUser.Name ?? "System"`).
2. **Standardized Initial Creation Notifications (Resource & Customer)**:
   - **Resource Onboarded**: Updated status from `"Done"` to `"Created"`. Priority remains `"Low"`, Related Project as `"-"`, Raised By as the user who added the resource (`performerName`).
   - **Customer Onboarded & Sub-Venture Onboarded**: Updated status from `"Pending"` to `"Created"`. Priority remains `"Low"`, Related Project as `"-"`, Raised By as the user who created the customer (`createdByName`).
3. **Standardized Edit Notifications (Resource & Customer)**:
   - **Resource Profile Updated**: Updated status from `"Done"` to `"Edited"`. Priority remains `"Low"`, Related Project as `"-"`, Raised By as the user who edited the profile.
   - **Customer Profile Edited, Sub-Venture Edited, and Manager Changed**: Standardized status to `"Edited"`. Priority remains `"Low"`, Related Project as `"-"`, Raised By as the editor.
4. **Action Centre UI Enhancements**:
   - Added badge styling for `"Created"` (`bg-sky-50 text-sky-700 border-sky-200`) and `"Edited"` (`bg-blue-50 text-blue-700 border-blue-200`).
   - Added `Plus` icon for `"Created"` and `Pencil` icon for `"Edited"` notifications.
   - Added `"Created"` and `"Edited"` to the available status dropdown filters.

---

### 1. Affected Files
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- `apps/backend/tests/PMS.IntegrationTests/CustomerNotificationIntegrationTests.cs`
- `apps/backend/tests/PMS.IntegrationTests/ResourceNotificationIntegrationTests.cs`
- `CHANGELOG_AI.md`

---

### 2. Database Changes & Migrations
- No schema changes required. Dual synchronization to secondary UAT database (`action.tbl_notifications`) applies automatically on creation and updates.

---

### 3. API & Business Logic Changes
1. **`ActionNotificationService.cs`**:
   - **`NotifyWbsCreatedAsync`**:
     - Routes strictly to active resources whose Sub-Department is EM or PMO and whose On Floor Role is Head Of Department.
     - Title set to `$"WBS or the Project is Created with the {projectName}"`.
     - Sets `Status = "Created"`, `Priority = "Low"`, `ProjectName = "-"`, `ProjectCode = null`, `RaisedByName = createdByName ?? currentUser.Name ?? "System"`.
   - **`NotifyCustomerOnboardedAsync` & `NotifySubVentureOnboardedAsync`**:
     - Sets `Status = "Created"`, `Priority = "Low"`, `ProjectName = "-"`.
   - **`NotifyResourceOnboardedAsync`**:
     - Sets `Status = "Created"`, `Priority = "Low"`, `ProjectName = "-"`.
   - **`NotifyResourceProfileUpdatedAsync`**:
     - Sets `Status = "Edited"`, `Priority = "Low"`, `ProjectName = "-"`.
   - **`NotifyCustomerEditedAsync`, `NotifySubVentureEditedAsync`, `NotifyCustomerManagerChangedAsync`**:
     - Sets `Status = "Edited"`, `Priority = "Low"`, `ProjectName = "-"`.
   - **`MapDto`**:
     - Added explicit guard: when `n.ProjectName == "-"`, `RelatedProject` is mapped directly as `"-"` regardless of project code.

2. **`action-centre-page.tsx`**:
   - Mapped `"created"` status to sky blue badge (`bg-sky-50 text-sky-700 border-sky-200`) with `<Plus />` icon.
   - Mapped `"edited"` status to blue badge (`bg-blue-50 text-blue-700 border-blue-200`) with `<Pencil />` icon.
   - Added `"Created"` and `"Edited"` to `availableStatuses` filter dropdown.

---

### 4. Existing Functionality Preserved
- All SLA escalations (WBS SLA breach, Extension Request SLA breach, Additional Customer Requirement SLA breach, Resource Allocation SLA breach) remain untouched.
- Bucket list task tracking and lifecycle notifications remain fully functional.
- Project creation and WBS creation transactional flows remain intact.

---

### 5. Verification & Testing
- Automated Integration Tests in `CustomerNotificationIntegrationTests.cs`: 5 passed, 0 failed.
  - Test 1: `CustomerOnboarding_DispatchesNotification_ToEmLeadership_And_AssignedManagers` (Status: `"Created"`, Priority: `"Low"`, RelatedProject: `"-"`) -> Passed.
  - Test 2: `CustomerProfileEdit_DispatchesNotification_WithEditedStatusAndTitle` (Status: `"Edited"`, Priority: `"Low"`, RelatedProject: `"-"`) -> Passed.
  - Test 3: `SubVentureEdit_DispatchesNotification_WithSubVentureEditedTitle` (Status: `"Edited"`, Priority: `"Low"`, RelatedProject: `"-"`) -> Passed.
  - Test 4: `CustomerManagerChanged_DispatchesNotification_WithExactTitleFormat` (Status: `"Edited"`, Priority: `"Low"`, RelatedProject: `"-"`) -> Passed.
  - Test 5: `WbsCreated_DispatchesNotification_ToEmPmoHod_WithCreatedStatusAndDashProjectName` (Title: `"WBS or the Project is Created with the {Name}"`, Status: `"Created"`, Priority: `"Low"`, RelatedProject: `"-"`, Recipients: EM/PMO HOD) -> Passed.
- Automated Integration Tests in `ResourceNotificationIntegrationTests.cs`: 3 passed, 0 failed.
  - Resource onboarding verified with Status: `"Created"`.
  - Resource profile edit verified with Status: `"Edited"`.
- All 104 Unit Tests in `PMS.UnitTests`: 104 passed, 0 failed.
- Backend API (`http://localhost:5194/health`): 200 Healthy.
- Frontend Server (`http://localhost:3000`): 200 OK.


---

## [uat_clean12] - 2026-11-14

### Repository Document Upload Governance Notifications

#### Summary
Implemented Action Centre notifications dispatched upon successful repository document uploads:
1. **Target Recipients**:
   - Dispatched **exclusively** to all active resources belonging to the departments selected under "Visible to departments" (`uniqueDeptIds` / `validDeptIds`).
   - Resolves employee membership via direct `DepartmentId` or parent department through `SubDepartmentRef.DepartmentId`.
   - Deduplicates recipient employees.
2. **Notification Attributes**:
   - **Title**: `"Document is Uploaded"`.
   - **Raised By**: The user who uploaded the document (`uploader` / `currentUser.Name`).
   - **Related Project**: `"-"` (`ProjectName = "-"`, `ProjectCode = null`).
   - **Status**: `"Upload"`.
   - **Priority**: `"-"`.
   - **Related Task**: The uploaded file name (`fileName`).
3. **Action Centre UI Enhancements**:
   - Mapped `"upload"` / `"uploaded"` status to teal badge (`bg-teal-50 text-teal-700 border-teal-200`) with `<Upload />` icon.
   - Added `"Upload"` to the `availableStatuses` filter dropdown.
   - Verified that `Priority = "-"` renders cleanly as a muted hyphen.

---

### 1. Affected Files
- `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- `apps/backend/Modules/Repository/Services/RepositoryService.cs`
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- `apps/backend/tests/PMS.IntegrationTests/RepositoryNotificationIntegrationTests.cs`
- `CHANGELOG_AI.md`

---

### 2. Database Changes & Migrations
- No database alterations required. Dual synchronization to secondary UAT database (`action.tbl_notifications`) applies automatically upon notification creation.

---

### 3. API & Business Logic Changes
1. **Contract Update** (`IActionNotificationService.cs`):
   - Added `NotifyRepositoryDocumentUploadedAsync(Guid documentId, string fileName, string category, IReadOnlyList<Guid> departmentIds, string? uploaderName, Guid? uploaderEmployeeId = null, CancellationToken ct = default);`.
2. **Notification Dispatch** (`ActionNotificationService.cs`):
   - Implemented `NotifyRepositoryDocumentUploadedAsync`:
     - Queries active resources where `DepartmentId` or `SubDepartmentRef.DepartmentId` matches any of `validDeptIds`.
     - Creates `ActionNotification` with `Title = "Document is Uploaded"`, `Type = "Document Uploaded"`, `Status = "Upload"`, `Priority = "-"`, `ProjectName = "-"`, `ProjectCode = null`, `RaisedByName = uploaderName`, `RelatedTask = fileName`.
     - Persists to primary database and executes dual-write sync via `TrySyncNotificationsToOtherDatabase`.
3. **Trigger on Document Upload** (`RepositoryService.cs`):
   - Injected `IActionNotificationService notificationService`.
   - In `UploadDocumentAsync`, immediately after persisting document and activity log, dispatches `NotifyRepositoryDocumentUploadedAsync`.
4. **Action Centre UI** (`action-centre-page.tsx`):
   - Imported `Upload` icon from `lucide-react`.
   - Added `"upload"` status badge styling and icon helper.
   - Added `"Upload"` to `defaultStatuses` in `availableStatuses` hook.

---

### 4. Existing Functionality Preserved
- File storage, physical categorization, MIME validation, and department visibility checks remain intact.
- Repository activity logging for upload, download, and deletion remain intact.
- All existing governance notifications (Customer, Resource, WBS, SLA breach) remain intact.

---

### 5. Verification & Testing
- Automated Integration Tests in `RepositoryNotificationIntegrationTests.cs`: 1 passed, 0 failed.
  - Verified document upload dispatches notification with `Title = "Document is Uploaded"`, `Status = "Upload"`, `Priority = "-"`, `RelatedProject = "-"`, `RaisedBy = uploader` delivered to all active resources in the selected department.
- Automated Integration Tests in `CustomerNotificationIntegrationTests.cs`: 5 passed, 0 failed.
- Automated Integration Tests in `ResourceNotificationIntegrationTests.cs`: 3 passed, 0 failed.
- Backend API (`http://localhost:5194/health`): 200 Healthy.
- Frontend Dev Server (`http://localhost:3000`): 200 OK.

---

## [uat_clean12] - 2026-11-14

### Resource Allocation Approval Request Delivery to Reporting Manager Action Centre Approvals Tab

#### Summary
Fixed the issue where adding a team member from the Team tab generated the notification to the Resource's Reporting Manager, but the Resource Allocation Approval request did not appear in the Reporting Manager's Action Centre Approvals tab:
1. **Backend RBAC Restriction Removal**:
   - Removed `[RequireRbac(RbacCatalogCodes.ActionApprovals, RbacAccessType.View)]` from `GET /api/v1/action-centre/allocation-approvals` and `[RequireRbac(RbacCatalogCodes.ActionApprovals, RbacAccessType.Manage)]` from `POST /api/v1/action-centre/allocation-approvals/{id:guid}/action`.
   - Removed `[RequireRbac("project-team", RbacAccessType.Manage)]` from `POST /api/v1/projects/{projectId}/allocation-requests/{requestId}/action`.
   - Previously, these endpoints returned `403 Forbidden` for reporting managers (such as CEO, CTO, COO, HR, IT Admin, Sales Managers, and Team Leaders) whose RBAC role lacked the global admin `approvals` catalog permission. The frontend `fetchPendingAllocationApprovals()` caught this error and silently returned an empty array, hiding all allocation approvals from the reporting manager.
2. **Current Employee Resolution Enhancement**:
   - Updated `FindCurrentEmployeeAsync` in `ProjectTeamMemberService.cs` to check `e.Id == userId` (matching `ActionNotificationService.cs` behavior) in addition to `e.UserId == userId`.
   - Added resolution fallbacks for `e.EmployeeCode` and `tbl_users` email mappings, ensuring employees switched via persona or authenticating with development bypass headers are reliably matched to their employee profile.
3. **In-Memory Query Safe Matching in `ListPendingAllocationsAsync`**:
   - Replaced the brittle EF Core LINQ-to-SQL expression `myNotifTaskCodes.Contains("ALLOC-" + r.Id.ToString().Substring(0, 8).ToUpper())` with in-memory ID and task code matching (`r.ApproverEmployeeId == currentEmpId` || `r.ApproverEmployeeId == currentUser.UserId` || `matchingPrefixes.Any(p => r.Id.ToString().ToUpper().StartsWith(p))`).
   - Ensures non-admin reporting managers consistently retrieve all allocation approval requests assigned to them or for which they received notifications.
4. **Action Centre Approvals Tab UI Enhancements**:
   - Updated `visibleTabs` in `action-centre-page.tsx` so the "Approvals" tab is accessible to users with `canView("approvals")`, `canView("action-centre")`, `canView("action-center")`, or `hasPermission("action-center.view")`.
   - Updated `canManageApprovals = true` in `ApprovalsTab` so that the Actions column and the "View" button are displayed to all reporting managers and approvers reviewing their approvals.
   - Enhanced the Approvals project filter dropdown to include projects from loaded approvals even if the reporting manager is not a member of that project's team.

---

### 1. Affected Files
- `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`
- `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`
- `apps/backend/Modules/Projects/Services/ProjectTeamMemberService.cs`
- `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- `apps/backend/tests/PMS.IntegrationTests/ResourceAllocationSlaIntegrationTests.cs`
- `CHANGELOG_AI.md`

---

### 2. Database Changes & Migrations
- None required.

---

### 3. API & Business Logic Changes
1. **Action Centre Controller** (`ActionCentreController.cs`):
   - Removed `[RequireRbac(RbacCatalogCodes.ActionApprovals, ...)]` on `allocation-approvals` endpoints.
   - Added fallback catalog codes `"action-center"`, `"action-centre"` to `[HttpGet("approvals")]`.
2. **Projects Controller** (`ProjectsController.cs`):
   - Removed `[RequireRbac("project-team", ...)]` on `allocation-requests/{requestId}/action` to allow the candidate resource's assigned reporting manager to action approvals without requiring project-team membership.
3. **Team Member Service** (`ProjectTeamMemberService.cs`):
   - Enhanced `FindCurrentEmployeeAsync` to resolve employees by `e.Id == userId`, `e.UserId == userId`, work/personal email, employee code, and `tbl_users` email.
   - Overhauled `ListPendingAllocationsAsync` to match requests in-memory via `r.ApproverEmployeeId` and notification task code prefix matching (`ALLOC-XXXXXXXX`).
4. **Action Centre Frontend** (`action-centre-page.tsx`):
   - Rendered "Approvals" tab when user has Action Centre view permissions.
   - Set `canManageApprovals = true` to allow approvers to view and action pending approval requests.
   - Populated project filter dropdown with all projects present in loaded approvals.

---

### 4. Existing Functionality Preserved
- Resource Allocation approval workflow, SLA tracking, and SLA completion remain intact.
- Multi-role leadership notifications on allocation status change (`Approved`, `Rejected`, `Hold`) remain intact.
- Adding approved members to project team and shadow team remains intact.
- Timeline extension, customer requirement, and feedback approval flows remain intact.

---

### 5. Verification & Testing
- Automated Integration Tests in `ResourceAllocationSlaIntegrationTests.cs`: 4 passed, 0 failed.
  - `ResourceAllocation_Creation_StartsSlaTracking_AndApproval_AddsMemberToProject_AndNotifiesExpectedRoles` (PASSED)
  - `ResourceAllocation_Rejection_DoesNotAddMember_NotifiesExpectedRoles` (PASSED)
  - `ResourceAllocation_Hold_DoesNotAddMember_NotifiesCandidate` (PASSED)
  - `ReportingManager_CanFetchPendingAllocationApprovals_ViaActionCentre_AndTakeApprovalAction` (PASSED)
- Verified `GET /api/v1/action-centre/allocation-approvals` returns 200 OK across roles (CEO, HOD, Manager).
- Backend API (`http://localhost:5194/health`): 200 Healthy.
- Frontend Dev Server (`http://localhost:3000`): 200 OK.
