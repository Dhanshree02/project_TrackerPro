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

<!-- New changes will be logged below this line -->

### [2026-11-04] Escalation Review Form Refinements: Remove Resolution Notes, 3-Chat Scroll, Staged Chat Submission, and Inline Attachment Viewer

- **Branch**: `uat_clean5`
- **Module**: Action Centre / Escalation Review Details Modal
- **Purpose**:
  1. Remove the *Resolution Notes* field from the *Resolution Timeline Details* section so it only contains the read-only Expected Resolution Date.
  2. Make the *Discussion Chat Thread* section scrollable after 3 chats (`max-h-36 overflow-y-auto`), matching the scroll behavior and height proportion of the *Status Transitions Timeline* section.
  3. Ensure clicking an attachment name opens the document inline in a new browser tab/window instead of forcing a file download.
  4. Decouple local chat drafting from backend submission: clicking "Send" in the chat thread displays the message immediately in the thread (staged), while clicking the "Save Governance Changes" button actually persists the message(s) to the database for all stakeholders.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**: None (leveraged `project.tbl_project_service_escalations.ChatJson` and `project.tbl_project_alerts.ChatJson`).
- **Migrations / Scripts**: None required.

#### 🔌 APIs & Business Logic Changed
- **Backend**:
  - `GET /api/v1/action-centre/alerts/{id}/attachment` (`ActionCentreController.DownloadAlertAttachment`):
    - Added `Response.Headers["Content-Disposition"] = $"inline; filename=\"{result.Value.FileName}\"";` and returned `File(stream, contentType)` so browsers render PDFs and images inline rather than forcing a file download.
  - `PUT /api/v1/action-centre/alerts/{id}/governance` (`ActionNotificationService.UpdateAlertGovernanceAsync`):
    - Added `List<string>? Comments` to `UpdateAlertGovernanceRequest` supporting single or batch comment persistence when saving governance changes.
- **Frontend (`action-centre-page.tsx`)**:
  - Removed `Resolution Notes` textarea from the *Resolution Timeline Details* card.
  - Adjusted Discussion Chat Thread container to `max-h-36 overflow-y-auto`, ensuring that 3 chats fit comfortably and any additional messages enable smooth vertical scrolling.
  - Attachment click handler attaches proper MIME type (e.g. `application/pdf`, `image/jpeg`, `image/png`) to the blob and opens it via `window.open(blobUrl, "_blank", "noopener,noreferrer")`.
  - Added `pendingChatMsgs` state: clicking "Send" (or pressing Enter) stages the message into `allDisplayComments` so it renders immediately in the conversation thread.
  - On clicking "Save Governance Changes", `handleUpdateAlert` submits all staged messages (and input text) via the API and persists them to the project escalation and alert tables.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- WhatsApp-style chat bubble layouts, read-only `day-month-year` dates, and status transitions timeline integrity remain intact.
- Multi-stakeholder alert and escalation synchronization remains fully operational.

### [2026-11-04] WhatsApp-Style Escalation Chat Persistence, Layout Swapping, Readonly Day-Month-Year Dates, and Attachment Viewer

- **Branch**: `uat_clean5`
- **Module**: Action Centre / Escalation Review & Governance Alert Details
- **Purpose**:
  1. Render dates in `day-month-year` (`DD-MM-YYYY`) format across the Resolution Timeline Details section (readonly Expected Resolution Date) and Status Transitions Timeline.
  2. Enable authenticated direct opening and viewing of alert attachments by clicking the attachment name via `apiFetchBlob`.
  3. Swap form layout: remove the *Governance Allocation & Ownership* section, place *Discussion Chat Thread* in the wide left column (`md:col-span-2`), and move *Resolution Timeline Details* under *Set Status* in the right column.
  4. Implement persistent WhatsApp-style multi-stakeholder chat messaging stored in the project's escalation table (`project.tbl_project_service_escalations.ChatJson`) and alert table (`project.tbl_project_alerts.ChatJson`), with 50-character limit, live remaining characters counter, message bubbles distinguishing sender vs other participants, and smooth scrollable history.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/backend/Modules/Projects/Models/ProjectServiceEscalation.cs`
- **Modified**: `apps/backend/Infrastructure/Persistence/Configurations/ProjectServiceEscalationConfiguration.cs`
- **Modified**: `apps/backend/Modules/Projects/Models/ProjectAlert.cs`
- **Modified**: `apps/backend/Infrastructure/Persistence/Configurations/ProjectIssueConfiguration.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_project_service_escalations`: Added `"ChatJson" text`.
  - `project.tbl_project_alerts`: Added `"ChatJson" text`.
- **Migrations / Scripts**:
  - Executed SQL:
    ```sql
    ALTER TABLE project.tbl_project_service_escalations ADD COLUMN IF NOT EXISTS "ChatJson" text;
    ALTER TABLE project.tbl_project_alerts ADD COLUMN IF NOT EXISTS "ChatJson" text;
    ```

#### 🔌 APIs & Business Logic Changed
- **Backend**:
  - `ActionNotificationDtos.cs`: Added `AlertCommentDto` (`Id`, `AuthorName`, `AuthorEmail`, `Text`, `At`) and added `Comments` list to `ActionAlertDto`.
  - `PUT /api/v1/action-centre/alerts/{id}/governance` (`ActionNotificationService.UpdateAlertGovernanceAsync`):
    - Truncates incoming comment text to 50 characters max.
    - Appends comment to `alert.ChatJson`.
    - If `ServiceEscalationId` is set, updates `project.tbl_project_service_escalations.ChatJson` and synchronizes all sibling `ProjectAlert` records for that escalation.
  - `GET /api/v1/action-centre/alerts` (`ActionNotificationService.GetAlertsAsync` & `MapAlertDto`):
    - Backfills `alertRow.ChatJson` from `matchEsc.ChatJson` if empty.
    - Deserializes `ChatJson` into `Comments` so all stakeholders see the full shared chat thread.
- **Frontend (`action-centre-page.tsx`)**:
  - Added helper `formatToDayMonthYear(val)` converting dates into `DD-MM-YYYY`.
  - Changed `Expected Resolution Date` input in *Resolution Timeline Details* to `readOnly` with `day-month-year` format.
  - Changed `Status Transitions Timeline` timestamps to display `day-month-year` (`DD-MM-YYYY`).
  - Updated attachment item click handler to use `apiFetchBlob` with bypass headers and open the blob in a new tab.
  - Removed `Governance Allocation & Ownership` section completely.
  - Positioned *Discussion Chat Thread* into the left column (`md:col-span-2`) with WhatsApp-style bubbles (green aligned right for current user, white/gray aligned left for other stakeholders).
  - Implemented 50-character limit with live `${50 - len} left` indicator and instant "Send" button + Enter key submission.
  - Moved *Resolution Timeline Details* to the right column directly under *Set Status*.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Status transitions, audit history logging, and resolution notes persistence remain intact.
- WBS escalation stakeholder notification delivery and acknowledgement status synchronization continue functioning without regression.
- Attachment download endpoint stream security remains verified.

### [2026-11-04] Unblock WBS Service Raise Escalation, Store Attachments in Documents/Escalation, and Display in Action Center

- **Branch**: `uat_clean5`
- **Module**: Projects / WBS Escalations / Action Centre / Document Storage
- **Purpose**:
  1. Unblock the "Raise Escalation" button in the WBS tab under *Service wise Prerequisite Tracking* so users can raise subsequent escalations for the same service at any time without restriction.
  2. Store uploaded escalation attachment files in `Documents -> Escalation Folder` (under `<solutionRoot>/Documents/Escalation/`) and register an entry in `project.tbl_project_documents` with `DocumentType = 'Escalation'`.
  3. In the Action Center (`/action-centre`) -> Alerts tab, when stakeholders click "Review details", display the uploaded attachment in the Governance Alert Details modal's *Attachments* section with clickable download/view functionality.
  4. Display the escalation's *Expected Resolution Date* inside the *Resolution Timeline Details* section of the Governance Alert Details form.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectServiceEscalationService.cs`
- **Modified**: `apps/backend/Infrastructure/Storage/FileStorageService.cs`
- **Modified**: `apps/backend/Modules/Projects/Validators/ProjectDocumentValidators.cs`
- **Modified**: `apps/backend/Modules/Projects/Models/ProjectAlert.cs`
- **Modified**: `apps/backend/Infrastructure/Persistence/Configurations/ProjectIssueConfiguration.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_project_alerts`: Added columns `"AttachmentFileName" character varying(255)`, `"AttachmentPath" text`, `"ExpectedResolutionDate" character varying(50)`, `"ServiceName" character varying(255)`, `"EscalationType" character varying(100)`, `"EscalatedTo" text`, and `"ServiceEscalationId" uuid`.
  - `project.tbl_project_documents`: Inserted record on escalation upload with `"DocumentType" = 'Escalation'`.
- **Migrations / Scripts**:
  - Applied SQL:
    ```sql
    ALTER TABLE project.tbl_project_alerts
      ADD COLUMN IF NOT EXISTS "AttachmentFileName" character varying(255),
      ADD COLUMN IF NOT EXISTS "AttachmentPath" text,
      ADD COLUMN IF NOT EXISTS "ExpectedResolutionDate" character varying(50),
      ADD COLUMN IF NOT EXISTS "ServiceName" character varying(255),
      ADD COLUMN IF NOT EXISTS "EscalationType" character varying(100),
      ADD COLUMN IF NOT EXISTS "EscalatedTo" text,
      ADD COLUMN IF NOT EXISTS "ServiceEscalationId" uuid;
    ```

#### 🔌 APIs & Business Logic Changed
- **WBS Service Escalations (`POST /api/v1/projects/{projectId}/service-escalations`)**:
  - Removed duplicate/open escalation constraint check (`alreadyOpen` throwing 409 Conflict), permitting multiple escalations to be raised for the same service.
  - When an attachment file is provided, stores file under `Documents/Escalation/` using `storage.SaveEscalationDocumentAsync` and registers a `ProjectDocument` entity in `project.tbl_project_documents` (`DocumentType = "Escalation"`).
  - Populates `AttachmentFileName`, `AttachmentPath`, `ExpectedResolutionDate`, `ServiceName`, `EscalationType`, `EscalatedTo`, `ServiceEscalationId`, and initializes `ResolutionDetails = $"Expected Resolution Date: {expectedResolutionDate}"` on the corresponding `ProjectAlert` entity.
- **File Storage Root Resolution (`FileStorageService.cs`)**:
  - Enhanced repo-root traversal to search upward for the solution root containing both `Documents` and `apps`, ensuring proper resolution to `<solutionRoot>/Documents` even when hosted from deep binary directories (`bin/run-uat5`).
  - Added `"Escalation"` to allowed `ValidDocumentTypes` in `ProjectDocumentValidators.cs`.
- **Action Centre Alerts & Attachments**:
  - Added endpoint `GET /api/v1/action-centre/alerts/{id:guid}/attachment` to stream and download the escalation attachment file.
  - In `ActionNotificationService.MapAlertDto`, mapped `Kind = "Escalation"`, `Attachments = [alert.AttachmentFileName]`, `AttachmentUrl = $"/api/v1/action-centre/alerts/{id}/attachment"`, `ExpectedResolutionDate`, `ServiceName`, `EscalationType`, and `EscalatedTo`.
- **Frontend UI**:
  - `project-detail-page.tsx`: Removed the `activeEsc` condition in the WBS prerequisite tracking table that previously swapped the "Raise Escalation" button for a badge; the button is now permanently unblocked and clickable.
  - `action-centre-page.tsx`:
    - Updated Governance Alert Details form (opened via "Review details") to render the escalation attachment under the *Attachments* section with clickable download/view links.
    - Updated *Resolution Timeline Details* section to feature an *Expected Resolution Date* banner badge and pre-populate the resolution timeline.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Stakeholder action notification and alert dispatch to PMO and EM resources remain fully operational.
- Existing Project Document management, KYC, PO, and repository templates under `Documents/` remain unchanged.
- Action Center alert governance status changes and audit log integrity are preserved.


### [2026-11-04] Make Project Health Alerts Status Read-Only and Display Status Transition Actor

- **Branch**: `uat_clean5`
- **Module**: Projects / Health / Alerts & Action Centre
- **Purpose**: Restrict alert status modification within the Project -> Health -> Alerts subtab to be strictly read-only, reflecting only updates made from the Action Center (via Alerts governance or Notification acknowledgement). In the project Alerts list, display green status badges for resolved/solved/closed states, and show who transitioned the status under the raised-by details (e.g. "Alert is resolved by Atharv Reddy" or "Alert is Closed by Vihaan Pillai").

#### 📁 Files Affected
- **Modified**: `apps/backend/Modules/Projects/Models/ProjectAlert.cs`
- **Modified**: `apps/backend/Infrastructure/Persistence/Configurations/ProjectIssueConfiguration.cs`
- **Modified**: `apps/backend/Modules/Projects/DTOs/ProjectIssueDtos.cs`
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectIssueService.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- **Modified**: `apps/frontend/src/modules/projects/api/project-issues.ts`
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_project_alerts`: Added columns `"StatusChangedBy" character varying(255)` and `"StatusChangedAtUtc" timestamp with time zone`.
- **Migrations / Scripts**:
  - Executed SQL: `ALTER TABLE project.tbl_project_alerts ADD COLUMN IF NOT EXISTS "StatusChangedBy" character varying(255); ALTER TABLE project.tbl_project_alerts ADD COLUMN IF NOT EXISTS "StatusChangedAtUtc" timestamp with time zone;`.

#### 🔌 APIs & Business Logic Changed
- **Backend**:
  - `PUT /api/v1/action-centre/alerts/{id}/governance` (`ActionNotificationService.UpdateAlertGovernanceAsync`):
    - Records `alert.StatusChangedBy = userName` and `alert.StatusChangedAtUtc = DateTime.UtcNow` when alert status is updated.
    - If status transitions to "Resolved" or "Closed" and `ResolutionOwner` is empty, defaults `alert.ResolutionOwner = userName`.
  - `PUT /api/v1/action-centre/notifications/{id}/acknowledge` (`ActionNotificationService.AcknowledgeNotificationAsync`):
    - When a `"WBS Escalation"` or issue-linked notification is acknowledged, synchronizes the corresponding `ProjectAlert` to `"Acknowledged"` and records `StatusChangedBy = userName` and `StatusChangedAtUtc`.
  - `GET /api/v1/projects/{projectId}/alerts` (`ProjectIssueService.GetProjectAlertsAsync`):
    - Added `StatusChangedBy`, `StatusChangedAtUtc`, and `ResolutionOwner` to `ProjectAlertDto` mapping (with fallback to `ResolutionOwner` or latest status update author from `HistoryJson`).
  - `PUT /api/v1/projects/{projectId}/alerts/{alertId}/status` (`ProjectIssueService.UpdateAlertStatusAsync`):
    - Updated to record `StatusChangedBy` and `StatusChangedAtUtc`.
- **Frontend**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx` (`HealthAlertsPanel`):
    - Replaced the editable status `<select>` dropdown with a read-only status badge.
    - Applied green badge styling (`bg-emerald-50 text-emerald-700 border-emerald-200`) for "Resolved", "Solved", and "Closed" statuses (as well as standard styled badges for "Open", "Acknowledged", and "In Progress").
    - Rendered status actor line underneath the "Raised by ..." line: `Alert is {status} by {changedBy}` (with transition date).

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Action Center Alert governance drawer and modal functionality remain intact with full history auditing.
- Notification inbox acknowledgement flow continues to update stakeholder statuses and alerts seamlessly.
- Other subtabs under Project Health (Interviews, Requirements, Escalations, Issues) remain unaffected.

### [2026-11-03] Dispatch Action Center Notifications and Alerts for WBS Escalations

- **Branch**: `uat_clean5`
- **Module**: Projects / Action Centre / WBS Escalations
- **Purpose**: Ensure stakeholders selected in "Escalate To (Select Stakeholders) *" when raising a WBS Escalation from the Service wise Prerequisite Tracking section under the WBS tab receive notifications and alerts in their Action Center (`/action-centre`).

#### 📁 Files Affected
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectServiceEscalationService.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `action.tbl_notifications` (Records inserted with `Type = 'WBS Escalation'`)
  - `project.tbl_project_alerts` (Records inserted with `AlertType = 'WBS Escalation'`)
  - `project.tbl_project_service_escalations` & `project.tbl_project_service_escalation_stakeholders` (Status updated upon acknowledgement)
- **Migrations / Scripts**: None required (leveraged existing tables and schemas).

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `POST /api/v1/projects/{projectId}/service-escalations`:
    - Automatically creates an `ActionNotification` in `action.tbl_notifications` for each selected stakeholder employee, addressed to their `RecipientEmployeeId` with title `WBS Escalation: {serviceName} - {subject}`, priority matching the escalation, status `"Pending"`, unread flag, and initial audit history.
    - Automatically creates a corresponding `ProjectAlert` in `project.tbl_project_alerts` with `AlertType = "WBS Escalation"` and `AudienceUserIds` populated with the stakeholder ID list.
  - `PUT /api/v1/action-centre/notifications/{id}/acknowledge`:
    - Added synchronization logic: when a notification of type `"WBS Escalation"` is acknowledged by a stakeholder, that stakeholder's status in `project.tbl_project_service_escalation_stakeholders` is updated from `"Pending"` to `"Acknowledged"`.
    - If all tagged stakeholders on that escalation have acknowledged, the parent escalation's status in `project.tbl_project_service_escalations` automatically transitions from `"Open"` to `"Acknowledged"`.
- **Frontend Action Center (`apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`)**:
  - Added `"WBS Escalation"` to `NOTIFICATION_TYPES` filter options so stakeholders can easily filter and view WBS escalations.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Existing WBS escalation file attachment storage and persistence in `project.tbl_project_service_escalations` remain intact.
- Other notification workflows (e.g. "New Project Assignment", "New Task Assignment", "WBS Assignment") and alerts processing continue unaffected.
- Action Center acknowledgement status flow and history auditing remain fully functional.


### [2026-11-03] Fix Automatic Duplicate Task Creation When Editing Task Title

- **Branch**: `uat_clean5`
- **Module**: Projects / Project Tasks
- **Purpose**: Fix a bug in the Project Tasks tab where renaming an existing task's `Task Title *` caused a duplicate default task (e.g. `Task 01`) to be automatically generated on subsequent tab loads or reloads. Tasks must only be created when the user explicitly clicks "+ Add Task", never upon editing an existing task.

#### 📁 Files Affected
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectTaskService.cs`
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**: `project.tbl_project_tasks` (no schema changes).
- **Migrations / Scripts**: None required.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `POST /api/v1/projects/{projectId}/tasks/auto-generate` (`GenerateMissingTasksAsync`):
    - Added branch-level existing base task slot check (`branchBaseTasks.Count > specIdx`) and description label matching check so that base tasks whose titles were customized or renamed by the user are recognized as present, preventing auto-generating redundant default `Task 0X` tasks.
    - Excluded soft-deleted tasks (`t.DeletedAtUtc == null`) when querying existing project tasks.
    - Updated `IsGeneratedLeaf` to check `string.IsNullOrWhiteSpace(task.TaskType)` instead of strictly checking the default title prefix `"Task "`, ensuring utilized hours and team hour splits continue working after task titles are customized.
- **Frontend UI (`DhTasksTab` in `project-detail-page.tsx`)**:
  - Added safety guard `disabled={useApiTasks && !t.dbId}` on the task row Edit button to prevent editing before task database ID is loaded.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Explicit task creation via "+ Add Task" button (`POST /api/v1/projects/{projectId}/tasks`) remains completely intact and functional for adding custom tasks (e.g., Managerial Tasks, Training/Learning).
- Base task hour distribution, status transitions (e.g., locking on "Completed"), assignment synchronization, and timesheet logging remain functional regardless of customized task titles.
