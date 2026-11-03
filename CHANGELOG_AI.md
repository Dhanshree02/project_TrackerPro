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
