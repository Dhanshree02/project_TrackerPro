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

### [2026-10-29] Backend and Database Integration for Previous Raise Issue Form & Health Alerts

- **Branch**: `uat_clean3`
- **Module**: Action Centre & Project Health (Issues and Alerts)
- **Purpose**: Connect the previous Raise Issue form UI directly to PostgreSQL database persistence across Action Centre and Project Health. Retain the exact previous form fields (Project, Issue Title, Description, Issue Type, Priority) without any extra fields, persist issues to `tbl_project_issues`, mirror alerts to `tbl_project_alerts`, and display live data in Project Health.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Migrations/20261029140000_AddProjectIssuesAndAlerts.cs` (Migration for issues and alerts)
  - `apps/backend/Modules/Projects/Models/ProjectIssue.cs` (Entity model for issues)
  - `apps/backend/Modules/Projects/Models/ProjectAlert.cs` (Entity model for project alerts)
  - `apps/backend/Infrastructure/Persistence/Configurations/ProjectIssueConfiguration.cs` (EF Core configurations)
  - `apps/backend/Modules/Projects/DTOs/ProjectIssueDtos.cs` (DTOs and request models)
  - `apps/backend/Modules/Projects/Services/IProjectIssueService.cs` (Service interface)
  - `apps/backend/Modules/Projects/Services/ProjectIssueService.cs` (Service implementation)
  - `apps/frontend/src/modules/projects/api/project-issues.ts` (Frontend API client)
- **Modified**:
  - `apps/backend/Infrastructure/Persistence/AppDbContext.cs` (Registered DbSets for `ProjectIssues` and `ProjectAlerts`)
  - `apps/backend/Configuration/DependencyInjectionExtensions.cs` (Registered `IProjectIssueService`)
  - `apps/backend/Modules/Projects/Controllers/ProjectsController.cs` (Added issue and alert endpoints)
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx` (Retained exact previous Raise Issue modal UI, connected to backend database API and dynamic assigned project dropdown)
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx` (Retained exact previous Raise Issue modal UI, connected to backend database API, with live database issues and interactive alert status persistence)

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_project_issues`: Primary key `Id`, `ProjectId` FK, `ProjectCode`, `ProjectName`, `IssueType`, `Priority`, `Subject`, `Description`, `Status`, `RaisedByEmployeeId` FK, `RaisedByName`, `RaisedByRole`, audit & soft-delete timestamps.
  - `project.tbl_project_alerts`: Primary key `Id`, `ProjectId` FK, `IssueId` FK nullable, `Title`, `Description`, `AlertType`, `Priority`, `Status`, `RaisedByEmployeeId` FK, `RaisedByName`, `AudienceUserIds`, audit timestamps.
- **Migrations / Scripts**:
  - Created migration `20261029140000_AddProjectIssuesAndAlerts`.
  - Executed and recorded in `__EFMigrationsHistory`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/projects/my-assigned-projects`: Retrieves projects authorized and assigned to the current employee for the Action Centre project dropdown.
  - `GET /api/v1/projects/{projectId}/issues`: Lists all active database issues for that project.
  - `POST /api/v1/projects/{projectId}/issues` & `POST /api/v1/projects/issues`: Creates an issue with validation, persists to `tbl_project_issues`, and mirrors an alert into `tbl_project_alerts` for project leadership.
  - `GET /api/v1/projects/{projectId}/alerts`: Lists all active alerts for that project from `tbl_project_alerts`.
  - `PUT /api/v1/projects/{projectId}/alerts/{alertId}/status`: Updates alert status (`"Open"`, `"Acknowledged"`, `"Resolved"`, `"Closed"`) and synchronizes the linked issue status.
- **Business Logic**:
  - Retained the exact previous Raise Issue form UI without any additional fields (only Project, Issue Title, Description, Issue Type, Priority).
  - In Action Centre: The Project dropdown is dynamically populated from `GET /api/v1/projects/my-assigned-projects` with actual database projects.
  - In Project Health: Current project is used automatically without requiring project re-selection.
  - Newly created issues appear immediately in the Project Health Issues tab without requiring full page reload.
  - Project Health Alerts tab displays live database alerts with interactive status tracking.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Preserved PostgreSQL schema `project`.
- Both frontend and backend builds compile cleanly with 0 errors.


### [2026-10-29] Action Centre Notifications Tab Integration & Issue Notifications for PM, SPM, and TL

- **Branch**: `uat_clean3`
- **Module**: Action Centre (Notifications Tab) & Project Issues
- **Purpose**: Connect the Action Centre Notifications Tab to PostgreSQL database persistence. Automatically notify the assigned Project Manager (PM), Senior Project Manager (SPM), and Team Leader (TL) whenever an issue is raised on a project. Support live notification loading, unread tracking, and persistent acknowledgement with mandatory comments without altering the existing Notifications UI.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Migrations/20261029150000_AddActionNotifications.cs` (EF Core migration for `action.tbl_notifications`)
  - `apps/backend/Modules/ActionCentre/Models/ActionNotification.cs` (Entity model for notifications)
  - `apps/backend/Infrastructure/Persistence/Configurations/ActionNotificationConfiguration.cs` (EF Core entity configuration)
  - `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs` (DTOs, request models, and query parameters)
  - `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs` (Notification service interface)
  - `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs` (Notification service implementation with employee scoping and history log tracking)
- **Modified**:
  - `apps/backend/Infrastructure/Persistence/AppDbContext.cs` (Added `DbSet<ActionNotification> ActionNotifications`)
  - `apps/backend/Configuration/DependencyInjectionExtensions.cs` (Registered `IActionNotificationService`)
  - `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs` (Exposed notification endpoints)
  - `apps/backend/Modules/Projects/Services/ProjectIssueService.cs` (Added automatic notification dispatch to assigned PM, SPM, and TL upon issue creation)
  - `apps/frontend/src/lib/role-context.tsx` (Exposed `isTeamLead` in `RoleContextValue` and provider)
  - `apps/frontend/src/lib/workspace-store.ts` (Added `setNotifications` to `dhStore`)
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx` (Loaded live database notifications into NotificationsTab, connected read and acknowledge handlers to backend API while preserving 100% of the UI layout, metrics, subtabs, filters, and modals)

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `action.tbl_notifications`:
    - `Id` (uuid, PK)
    - `RecipientEmployeeId` (uuid FK -> `resource.tbl_employees`, on delete cascade)
    - `ProjectId` (uuid FK -> `project.tbl_projects`, on delete cascade)
    - `ProjectCode` (varchar 50)
    - `ProjectName` (varchar 255)
    - `Title` (varchar 255)
    - `Type` (varchar 100, default `'Issue Raised'`)
    - `Priority` (varchar 20, default `'Medium'`)
    - `Status` (varchar 50, default `'Pending'`)
    - `Unread` (boolean, default `true`)
    - `RaisedByEmployeeId` (uuid, nullable)
    - `RaisedByName` (varchar 255)
    - `RelatedTask` (varchar 255, nullable)
    - `IssueId` (uuid FK -> `project.tbl_project_issues`, nullable, on delete set null)
    - `AcknowledgedBy` (varchar 255, nullable)
    - `AcknowledgedDate` (varchar 50, nullable)
    - `AcknowledgedTime` (varchar 50, nullable)
    - `HistoryJson` (text JSON array of audit entries)
    - `CreatedAtUtc`, `UpdatedAtUtc`, `CreatedBy`, `UpdatedBy`, `DeletedAtUtc`
  - Indexes:
    - `IX_tbl_notifications_RecipientEmployeeId` on `("RecipientEmployeeId", "DeletedAtUtc")`
    - `IX_tbl_notifications_ProjectId` on `("ProjectId", "DeletedAtUtc")`
    - `IX_tbl_notifications_Status` on `("Status")`
- **Migrations / Scripts**:
  - Created migration `20261029150000_AddActionNotifications.cs` in `apps/backend/Migrations/`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/action-centre/notifications`: Fetches notifications for the authenticated employee/manager with optional status, search, and project filters.
  - `PUT /api/v1/action-centre/notifications/{id}/acknowledge`: Validates mandatory comment, marks status as `'Acknowledged'`, sets `Unread = false`, records acknowledger name and timestamp, appends to the audit history timeline in `HistoryJson`.
  - `PUT /api/v1/action-centre/notifications/{id}/read`: Marks notification as read (`Unread = false`) and logs to history.
- **Business Logic**:
  - When an issue is raised (from either Action Centre or Project Health):
    - Assigned **Project Manager (PM)** is resolved from `project.ProjectManagerId` and team members with role `'ProjectManager'`.
    - Assigned **Senior Project Manager (SPM)** is resolved from team members with role `'SeniorProjectManager'`.
    - Assigned **Team Leader (TL)** is resolved from `project.TeamLeadId` and team members with `IsTeamLead == true` or role `'TeamLead'`.
    - An individual notification row is created in `action.tbl_notifications` for each assigned PM, SPM, and TL.
  - When a PM, SPM, or TL accesses Action Centre -> Notifications:
    - The Notifications Tab fetches live database notifications targeted to their employee identity.
    - Metrics cards (Total, Pending, Critical Pending, Archived) dynamically count based on live records.
    - Sub-tabs ("Current" and "Archived"), search queries, type filters, priority filters, date filters, and status filters work on live data.
    - Clicking a notification marks it read in the database and opens the details modal.
    - Submitting an acknowledgement comment persists the change to PostgreSQL and moves the notification to the Archived tab.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Notification UI in `action-centre-page.tsx` is completely preserved without visual modifications.
- Both frontend and backend builds compile cleanly with 0 errors.


### [2026-10-29] Fix Recipient Routing to PM, EM, TL (Exclude SPM), Connect Action Centre Alerts Tab & Fix Review Details Error

- **Branch**: `uat_clean3`
- **Module**: Action Centre (Alerts Tab & Notifications Tab) & Project Health (Issues and Alerts)
- **Purpose**:
  1. Fix issue notification and alert dispatch to route strictly to assigned **Project Manager (PM)**, **Engagement Manager (EM)**, and **Team Leaders (TL)**, and **explicitly exclude Senior Project Manager (SPM)**.
  2. Ensure issues raised from either the **Project Health tab** (`Raise Issues Alerts`) or the **Action Centre bucket list** (`Raise Issue`) populate directly into the assigned PM's, EM's, and TL's Action Centre Alert Tab and Notification Tab.
  3. Connect Action Centre -> Alerts Tab to live PostgreSQL backend persistence (`GET /api/v1/action-centre/alerts` and `PUT /api/v1/action-centre/alerts/{id}/governance`).
  4. Fix runtime frontend crash `ReferenceError: people is not defined at AlertsTab` when clicking the "Review detail" button in the Alert Tab.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs` (Extended with `ActionAlertDto` and `UpdateAlertGovernanceRequest`)
- **Modified**:
  - `apps/backend/Modules/Projects/Services/ProjectIssueService.cs`:
    - Removed Senior Project Manager (`isSpm`) from notification and alert recipients.
    - Added Engagement Manager (`project.EngagementManagerId ?? project.Client?.EngagementManagerId` and team members with `EngagementManager` role) to notification and alert recipients.
    - Both `ActionNotification` and `ProjectAlert` audience now target PM, EM, and TL only.
  - `apps/backend/Modules/Projects/Models/ProjectAlert.cs`:
    - Added governance and audit properties: `Owner`, `ResolutionOwner`, `EscalationOwner`, `ResolutionDetails`, `HistoryJson`.
  - `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`:
    - Added `GetAlertsAsync(NotificationQueryParameters query, CancellationToken ct)`
    - Added `UpdateAlertGovernanceAsync(Guid id, UpdateAlertGovernanceRequest request, CancellationToken ct)`
  - `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
    - Implemented `GetAlertsAsync` and `UpdateAlertGovernanceAsync` with role-based and audience-based filtering.
    - Handled null safety on `project.ClientId` and client metadata mapping.
  - `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`:
    - Exposed `GET /api/v1/action-centre/alerts`
    - Exposed `PUT /api/v1/action-centre/alerts/{id}/governance`
  - `apps/frontend/src/lib/workspace-store.ts`:
    - Added `setAlerts` method to `dhStore`.
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`:
    - Imported `people` from `@/lib/domain-models` and added null-safe fallback `(people || [])` to fix `ReferenceError: people is not defined`.
    - Integrated live alerts fetching (`loadAlerts`) from `/api/v1/action-centre/alerts` in `AlertsTab`.
    - Wired `handleUpdateAlert` to persist alert governance and status updates via `PUT /api/v1/action-centre/alerts/{selectedAlertId}/governance`.

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_project_alerts`:
    - Added column `Owner` (varchar 255, nullable)
    - Added column `ResolutionOwner` (varchar 255, nullable)
    - Added column `EscalationOwner` (varchar 255, nullable)
    - Added column `ResolutionDetails` (text, nullable)
    - Added column `HistoryJson` (text JSON array, nullable)
  - `project.tbl_projects`:
    - Populated `EngagementManagerId` and `EngagementManager` name for active client projects (`P001`, `P002`, `P003`) linked to client Engagement Manager Karan Wardhan (`d9584ade-2bc0-42c2-91c0-d5cb3cf0f09c`).
  - `action.tbl_notifications`:
    - Purged legacy test notifications mistakenly addressed to SPM.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/action-centre/alerts`: Retrieves governance alerts for PM, EM, and TL where their employee ID is included in `AudienceUserIds` or where they are project owners/superadmins.
  - `PUT /api/v1/action-centre/alerts/{id}/governance`: Updates alert status, owner, resolution owner, escalation owner, resolution details, and appends timestamped entries to `HistoryJson`.
- **Business Logic**:
  - Notification and alert creation logic in `ProjectIssueService.CreateIssueAsync` now strictly gathers:
    1. Assigned **Project Manager (PM)** (`project.ProjectManagerId` or project team members with role `ProjectManager`).
    2. Assigned **Engagement Manager (EM)** (`project.EngagementManagerId`, `project.Client.EngagementManagerId`, or project team members with role `EngagementManager`).
    3. Assigned **Team Leaders (TL)** (`project.TeamLeadId`, `IsTeamLead == true`, or role `TeamLead`).
    4. **Senior Project Manager (SPM) is completely excluded** from alert audience and notification recipients.
  - Verified across PM (Divya Deshmukh), EM (Karan Wardhan), TL (Harsh Gupta), and SPM (Reyansh Patel):
    - PM, EM, and TL receive all alerts and notifications.
    - SPM receives 0 alerts and 0 notifications for raised issues.
  - Clicking "Review detail" in Action Centre -> Alerts Tab renders properly without throwing `ReferenceError: people is not defined` or `TypeError: Cannot read properties of undefined (reading 'map')` by ensuring `comments`, `attachments`, and `history` are normalized to empty arrays on alert load and guarded in JSX with `(selectedAlert.comments || []).map(...)`.
  - Updating governance fields (Status, Owner, Resolution Owner, Escalation Owner, Resolution Details) updates PostgreSQL `project.tbl_project_alerts` and synchronizes status with the linked `project.tbl_project_issues` record.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- The UI layout, styling, filter bars, and modal structure of Action Centre Alerts and Notifications remain completely identical to the existing design.
- Zero compile or bundling errors in both backend .NET API and frontend Vite production builds.
- Current active branch remains `uat_clean3`.

