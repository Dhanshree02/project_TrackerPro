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

### [2026-10-29] Refresh database/pms_uat.sql from pms_uat_clean

- **Branch**: `uat_clean3`
- **Module**: Database
- **Purpose**: Regenerate `database/pms_uat.sql` directly from the live `pms_uat_clean` PostgreSQL database (`10.50.30.189:41763/pms_uat_clean`) using `pg_dump` to capture the latest schema definitions and seed data (including `Abbreviation` in `master.mst_service_catalog`, `ServiceAbbreviation` in `project.tbl_project_services`, latest project tasks, action items, and notification tables).

#### 📁 Files Affected
- **Modified**:
  - `database/pms_uat.sql` (Exported complete database schema, constraints, sequences, and table records from `pms_uat_clean`).

#### 🗄️ Database & Schema Changes
- Captured latest schema and table snapshots:
  - `master.mst_service_catalog`: added `Abbreviation` (`character varying(50)`).
  - `project.tbl_project_services`: added `ServiceAbbreviation` (`character varying(50)`).
  - Captured tables `action.tbl_bucket_tasks`, `action.tbl_notifications`, `project.tbl_project_alerts`, `project.tbl_project_issues`.

#### 🔌 APIs & Business Logic Changed
- None (database snapshot refresh only).

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Docker/fresh Postgres volume bootstrap scripts (`database/init-databases.sh`) can load `pms_uat.sql` directly without syntax or constraint errors.

### [2026-10-29] Fix Missing fetchServiceHierarchy Import in Project Tasks Tab

- **Branch**: `uat_clean3`
- **Module**: Projects (Project Detail Tasks Tab)
- **Purpose**: Resolve runtime `ReferenceError: fetchServiceHierarchy is not defined` when opening the Project Tasks tab by adding the missing named import from `@/lib/api/catalogs`.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx` (Added `import { fetchServiceHierarchy } from "@/lib/api/catalogs";`).

#### 🗄️ Database & Schema Changes
- None.

#### 🔌 APIs & Business Logic Changed
- Fixed missing module import in `project-detail-page.tsx`.
- Successfully validated frontend build (`npm --prefix apps/frontend run build`) with 0 errors.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Catalog abbreviation resolution and caching in `DhTasksTab` for dynamic task folder labels (`AWS1`, `FSRE1`, etc.) remain fully functional.

### [2026-10-29] Fix Service Abbreviation Display in Project Tasks Folders

- **Branch**: `uat_clean3`
- **Module**: Projects (Project Onboarding, Edit Services, Project Detail Tasks Tab)
- **Purpose**: Fix issue where task folders under services and quarters (Quarter 1..4) continued to show generic `AP1`, `AP2` instead of dynamic service abbreviation names (e.g. `AWS1`, `FSRE1`, `INPT1`, `NVA1`) when services are configured during Project Onboarding or added via the "Edit Services" modal.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/api/projects.ts` (Mapped `serviceCatalogId`, `serviceAbbreviation`, and `abbreviation` in `mapApiProjectToProject`).
  - `apps/frontend/src/modules/projects/pages/project-onboarding-page.tsx` (Propagated `serviceCatalogId`, `catalogId`, `serviceAbbreviation`, and `abbreviation` in `buildWbsDetails` when generating project WBS service rows; restored abbreviation fallback from `dynamicDeptServices`).
  - `apps/frontend/src/modules/projects/components/edit-services-modal.tsx` (Ensured staged add payloads include trimmed `serviceAbbreviation`, `abbreviation`, and `serviceCatalogId` using case-insensitive service matching).
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - In `setApiWbsServices`: mapped `serviceCatalogId`, `serviceAbbreviation`, `abbreviation`.
    - In `buildServiceTree`: implemented multi-source abbreviation resolution checking direct service abbreviation, `liveServices` (API services), `project.wbsDetails.services`, catalog hierarchy cache state, and existing persisted database task phases.
    - In `applyPersistedTasks`: added dominant abbreviation extraction from persisted tasks, folder label reconciliation from persisted phase (`resolveFolderLabel`), and bidirectional fallback matching between abbreviation and AP prefixes.
    - In `DhTasksTab`: added `catalogAbbrMap` state populated from `fetchServiceHierarchy()` on mount to guarantee React re-render when abbreviations load; added `refreshKey` dependency to re-run task and service fetching whenever services or prerequisites change.
    - In `ProjectDetailPage`: linked `onServicesRefreshed` and `EditServicesModal` updates to trigger page-level `refreshProjectServices` and pass `refreshKey` down to `DhTasksTab`.
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs` (Enhanced `GetProjectServicesAsync` and `GetProjectServiceByIdAsync` to match catalog records by `ServiceCatalogId` as well as name/code).
  - `apps/backend/Modules/Projects/Services/ProjectTaskService.cs` (Enhanced catalog abbreviation lookup in task generation to resolve by `ServiceCatalogId`).

#### 🗄️ Database & Schema Changes
- None (schema already supports `service_abbreviation` in `project_services` and `service_catalogs`; reinforced data-flow and resolution).

#### 🔌 APIs & Business Logic Changed
- Ensured service abbreviations persist seamlessly from service picker / catalog through WBS details into database `ProjectServices` and are mapped to task folder display labels.
- Preserved existing quantity sequence (`{abbr}1`, `{abbr}2`), quarter hierarchies (Once, Half Yearly, Yearly), task hours, assignments, timers, and progress tracking.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Fallback to `AP1`, `AP2` is maintained for any custom or legacy services that have no abbreviation configured.
- Existing task assignments, time logging, stage updates, and prerequisite workflows remain intact.

### [2026-10-29] Read-Only Engagement Manager & Sales Manager for Existing Customer Sub-ventures

- **Branch**: `uat_clean3`
- **Module**: Customers (New Customer / Add Sub-venture Modal)
- **Purpose**: When adding a new sub-venture under an existing customer, lock the Engagement Manager and Sales Manager fields to read-only so they display the customer's existing database values without allowing accidental manual edits, while preserving full selectability when onboarding a new customer.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/customers/pages/customers-list-page.tsx` (When `selectedExisting` is true, render Engagement Manager and Sales Manager as read-only inputs using `readOnlyCls`; update `selectExistingClient` to directly set `engagementManager` and `salesManager` from the existing client record).

#### 🗄️ Database & Schema Changes
- None (frontend modal field behavior adjustment; existing database schema and endpoints preserved).

#### 🔌 APIs & Business Logic Changed
- **Business Logic**:
  - In `NewClientModal`, selecting an existing customer switches Engagement Manager and Sales Manager to read-only fields populated from the database.
  - Creating a brand new customer continues to render searchable selection dropdowns for both roles.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Sub-venture creation under an existing customer preserves the customer's existing leadership mappings.
- New customer onboarding retains full stakeholder selection and validation.

---

### [2026-10-29] Prerequisite Workflow Reactivity & Project Onboarding Adjustments

- **Branch**: `uat_clean3`
- **Module**: Projects (Onboarding & Prerequisite Workflow)
- **Purpose**: Remove customer industry display from the TK Customer / Partner dropdown (showing only sub-venture count), set the Engagement Manager field to read-only in Project Onboarding, and fix UI reactivity in Service-wise Prerequisite Tracking so status changes for Collection Status, Validation Status, and Billing Status reflect instantaneously on screen upon selection without requiring page reload.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-onboarding-page.tsx` (Removed industry from customer search list item; set `engagementManager` input to `readOnly` with placeholder `"Auto-populated from customer"`)
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx` (Added `localServiceStatus` optimistic state in `WbsPrerequisiteSection`; resolved priority in `servicesList` so latest user selections display instantaneously; updated `handleServiceChange`, `Start` button, and modification rows to update local state immediately and notify `onServicesRefreshed`)

#### 🗄️ Database & Schema Changes
- None (pure frontend reactivity and form adjustment; existing PostgreSQL tables and endpoints preserved).

#### 🔌 APIs & Business Logic Changed
- **Business Logic**:
  - In Project Onboarding, selecting a customer populates `engagementManager` as read-only.
  - In Project Detail &rarr; Prerequisite Tracking, dropdown changes to Collection Status, Validation Status, and Billing Status update immediately in the UI while asynchronously saving to `PATCH /api/v1/projects/{projectId}/services/{serviceId}/prerequisite` and triggering parent service synchronization.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Customer selection still auto-populates the Engagement Manager from the selected client model.
- Prerequisite validation hierarchy (Collection &rarr; Validation &rarr; Billing &rarr; Ready to Start) must remain enforced.

---

### [2026-10-29] Service Abbreviation Task Folders & End-to-End Service Abbreviation Persistence

- **Branch**: `uat_clean3`
- **Module**: Project Masters (Settings) & Projects (Onboarding & Tasks)
- **Purpose**: Verify that Service Abbreviation is persisted in the PostgreSQL database and correctly propagated through Project Onboarding to project services and tasks, ensuring task folder names in Project -> Tasks dynamically render `{Abbreviation}{Index}` (e.g. `NVA1`) instead of `AP1`.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Migrations/20261029190000_AddServiceCatalogAbbreviation.cs`
- **Modified**:
  - `apps/backend/Modules/Projects/Models/MstServiceCatalog.cs` (Added `Abbreviation` property)
  - `apps/backend/Modules/Projects/Models/ProjectServiceEntity.cs` (Added `ServiceAbbreviation` property)
  - `apps/backend/Infrastructure/Persistence/Configurations/ServiceCatalogConfiguration.cs` (Mapped `Abbreviation` column)
  - `apps/backend/Infrastructure/Persistence/Configurations/ProjectServiceConfiguration.cs` (Mapped `ServiceAbbreviation` column)
  - `apps/backend/Modules/Catalogs/DTOs/CatalogDtos.cs` (Added `Abbreviation` to catalog request and DTO records)
  - `apps/backend/Modules/Catalogs/Services/CatalogService.cs` (Included abbreviation in hierarchy and catalog items)
  - `apps/backend/Modules/Catalogs/Services/ProjectMastersService.cs` (Loaded and saved `Abbreviation` for service catalog)
  - `apps/backend/Modules/Projects/DTOs/ProjectServiceDtos.cs` (Added `ServiceAbbreviation` to create/update requests and response DTOs)
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs` (Auto-resolved `ServiceCatalogId` and `ServiceAbbreviation` by service name on project creation/retrieval, returned abbreviation in DTO)
  - `apps/backend/Modules/Projects/Services/ProjectTaskService.cs` (Auto-resolved catalog abbreviation, generated task phase using abbreviation, migrated existing `AP{n}` tasks to `{abbr}{n}`)
  - `apps/frontend/src/lib/api/catalogs.ts` (Added `abbreviation` to hierarchy types)
  - `apps/frontend/src/modules/projects/api/projects.ts` (Added `serviceAbbreviation` to project service payloads)
  - `apps/frontend/src/modules/projects/pages/project-onboarding-page.tsx` (Propagated catalog ID and abbreviation from catalog hierarchy without exposing UI field)
  - `apps/frontend/src/modules/projects/components/edit-services-modal.tsx` (Propagated catalog ID and abbreviation on staged service additions)
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx` (Built tree folders from `serviceAbbreviation`, added fallback abbreviation catalog cache)
  - `apps/frontend/src/modules/settings/components/masters/project-masters-section.tsx` (Service Abbreviation field, currency formatting fix, duration input validation)
  - `apps/frontend/src/modules/settings/masters/project-catalog-store.ts` (Stored and synced abbreviation in master state)
  - `apps/frontend/src/modules/settings/masters/types.ts` (Added `abbreviation` field to types)
  - `apps/frontend/src/modules/settings/masters/use-masters.ts` (Managed abbreviation state)

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `master.mst_service_catalog` (Column: `Abbreviation` VARCHAR(50))
  - `project.tbl_project_services` (Column: `ServiceAbbreviation` VARCHAR(50))
  - `project.tbl_project_tasks` (Phase updated from `AP1` to `NVA1` for Project P004 and other catalog-linked services)
- **Migrations / Scripts**:
  - `20261029190000_AddServiceCatalogAbbreviation.cs`
  - Backfilled unlinked services in `project.tbl_project_services` and synchronized `Phase` in `project.tbl_project_tasks`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/catalogs/service-hierarchy` includes `abbreviation` in service leaf nodes.
  - `GET /api/v1/projects/{projectId}/services` returns `serviceAbbreviation` on service DTOs.
  - `POST /api/v1/projects/{projectId}/services` automatically matches `ServiceName` to catalog if `ServiceCatalogId` is omitted, resolving both `ServiceCatalogId` and `ServiceAbbreviation`.
- **Business Logic**:
  - Service Abbreviation is entered and edited in Project Masters (Settings).
  - Project Onboarding passes the catalog's abbreviation in memory without exposing an input field in the onboarding form.
  - When Project -> Tasks tab loads, task folders are generated as `{Abbreviation}{QtyIndex}` (e.g. `NVA1`), with fallback to `AP1` only if no abbreviation is defined.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Project Onboarding UI must never show an abbreviation input field.
- Quantity calculation, task generation structure, working hour distributions, and frequency hierarchies (Once, Half Yearly, Yearly) must remain intact.

---

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



### [2026-10-29] Dynamic Service Abbreviation-Based Task Folder Names & Project Masters Abbreviation Configuration

- **Branch**: `uat_clean3`
- **Module**: Masters (Project Masters) & Project Details (Tasks Tab)
- **Purpose**:
  1. Add a **Service Abbreviation** field to Project Masters (immediately following the Service field, enabled only when a service is selected). Store abbreviation in PostgreSQL (`master.mst_service_catalog.Abbreviation`) and EF Core models. Support creating and editing master service abbreviations.
  2. Replace hardcoded `AP1`, `AP2`, `AP3`, etc. task folder names in Project → Tasks with dynamically generated folder names based on each service's stored abbreviation (e.g., `AWS1`, `AWS2`, `FSRE1`, `FSRE2`), with safe fallback to `AP1`, `AP2`, etc. when no abbreviation is configured.
  3. Maintain 100% integrity of quantity-based folder generation, quarter/frequency hierarchy (`Once`, `Half Yearly`, `Yearly`), task creation, assignment logic, estimated/utilized hours, timers, task completion, and progress calculations.
  4. Ensure Project Onboarding form does NOT display the Service Abbreviation field.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Migrations/20261029190000_AddServiceCatalogAbbreviation.cs` (EF Core migration for `master.mst_service_catalog.Abbreviation` and `project.tbl_project_services.ServiceAbbreviation`)
- **Modified**:
  - `apps/backend/Modules/Projects/Models/MstServiceCatalog.cs`: Added `public string? Abbreviation { get; set; }`
  - `apps/backend/Infrastructure/Persistence/Configurations/ServiceCatalogConfiguration.cs`: Added EF Core builder property mapping for `Abbreviation` (`maxLength: 50`)
  - `apps/backend/Modules/Projects/Models/ProjectServiceEntity.cs`: Added `public string? ServiceAbbreviation { get; set; }`
  - `apps/backend/Infrastructure/Persistence/Configurations/ProjectServiceConfiguration.cs`: Added EF Core builder property mapping for `ServiceAbbreviation` (`maxLength: 50`)
  - `apps/backend/Modules/Catalogs/DTOs/CatalogDtos.cs`: Added `string? Abbreviation = null` to `ServiceCatalogOptionDto`, `ServiceHierarchyItemDto`, `ProjectMasterRowDto`, `CreateProjectMasterRequest`, `UpdateProjectMasterRequest`, and `CreateServiceOnlyRequest`
  - `apps/backend/Modules/Projects/DTOs/ProjectServiceDtos.cs`: Added `string? ServiceAbbreviation = null` to `ProjectServiceDto`, `CreateProjectServiceRequest`, and `UpdateProjectServiceRequest`
  - `apps/backend/Modules/Catalogs/Services/ProjectMastersService.cs`: Supported saving, updating, and mapping `Abbreviation` on master service catalog records
  - `apps/backend/Modules/Catalogs/Services/CatalogService.cs`: Included `Abbreviation` in `GetServiceCatalogAsync` and `GetServiceHierarchyAsync`
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`: Included `ServiceCatalog` in `GetProjectServicesAsync` and mapped `ServiceAbbreviation = s.ServiceAbbreviation ?? s.ServiceCatalog?.Abbreviation`
  - `apps/backend/Modules/Projects/Services/ProjectTaskService.cs`:
    - Updated `GenerateMissingTasksAsync` to use service abbreviation for task phase generation (e.g. `${abbr}{ap}`) with fallback check to avoid duplicate generation against existing `AP` tasks
    - Updated `ParseApNumber` to parse trailing sequence numbers using regex `(\d+)$`, supporting any abbreviation prefix (`AWS1`, `FSRE2`, `AP1`)
  - `apps/frontend/src/lib/api/catalogs.ts`: Added `abbreviation?: string | null` to `ServiceHierarchyItem`
  - `apps/frontend/src/modules/settings/masters/project-catalog-store.ts`: Added `abbreviation` to `CatalogServiceItem` and store mapping
  - `apps/frontend/src/modules/settings/masters/types.ts`: Added `abbreviation?: string` to `ProjectMasterItem`
  - `apps/frontend/src/modules/settings/api/project-masters.ts`: Added `abbreviation` to `ProjectMasterRow`, `CreateProjectMasterPayload`, and mapper functions
  - `apps/frontend/src/modules/settings/masters/use-masters.ts`: Forwarded `abbreviation` in `addProjectMaster` and `updateProjectMasterItem`
  - `apps/frontend/src/modules/settings/components/masters/project-masters-section.tsx`:
    - Added **Service Abbreviation** input field immediately following the Service dropdown in Add New Master form, enabled only when a service is selected
    - Added auto-population of abbreviation when a catalog service is selected
    - Added Service Abbreviation input in Edit Master dialog, loading and saving abbreviations
    - Added Service Abbreviation optional field in Add Service dialog
    - Rendered abbreviation badges next to service names in Project Masters table
  - `apps/frontend/src/modules/projects/api/projects.ts`: Added `serviceAbbreviation?: string | null` to `ApiProjectService`
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`:
    - Updated `buildServiceTree` to generate AP folders using `(svc.serviceAbbreviation || svc.abbreviation || "AP") + index` (e.g. `AWS1`, `FSRE1`)
    - Updated `applyPersistedTasks` to match tasks by `${abbr}${index}` with backward-compatible fallback to `AP${index}`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `master.mst_service_catalog`: Added column `"Abbreviation" character varying(50)` (nullable).
  - `project.tbl_project_services`: Added column `"ServiceAbbreviation" character varying(50)` (nullable).
  - Associated existing project services with their catalog entries via `ServiceCatalogId`.
- **Migrations / Scripts**:
  - `apps/backend/Migrations/20261029190000_AddServiceCatalogAbbreviation.cs`.
  - Executed migration in PostgreSQL and recorded in `__EFMigrationsHistory`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/catalogs/project-masters`: Returns `abbreviation` for each master service catalog record.
  - `POST /api/v1/catalogs/project-masters`: Accepts `abbreviation` and stores it with the service catalog item.
  - `PUT /api/v1/catalogs/project-masters/{id}`: Updates `abbreviation` on existing service catalog items.
  - `GET /api/v1/catalogs/service-hierarchy`: Returns `abbreviation` in `ServiceHierarchyItemDto`.
  - `GET /api/v1/projects/{projectId}/services`: Returns `serviceAbbreviation` from `tbl_project_services.ServiceAbbreviation` or linked `mst_service_catalog.Abbreviation`.
- **Business Logic**:
  - Dynamic folder naming in Project → Tasks: Displays abbreviations configured in Project Masters (e.g. `AWS1`, `AWS2`, `FSRE1`, `ISO1`). Services without an abbreviation default safely to `AP1`, `AP2`, etc.
  - Existing task state preservation: Backward-compatible phase matching in `applyPersistedTasks` ensures previously created tasks stored with `AP` phase match seamlessly, preserving assigned resources, hours, timer data, and stages (`Not Started`, `Ongoing`, `Completed`).
  - Project Onboarding form does NOT display the Service Abbreviation field, preserving existing onboarding experience.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Task quantity calculations, quarter/frequency hierarchy, and progress bars remain unchanged.
- Both frontend and backend compile and build with 0 errors.
- Active branch is `uat_clean3`.


### [2026-10-29] Fix Project Masters Edit Modal Department Loading, Currency to ₹, Numeric Duration, and Field Overlap

- **Branch**: `uat_clean3`
- **Module**: Masters (Project Masters & Existing Project Masters)
- **Purpose**:
  1. Fix Edit Project Master modal so it correctly displays the existing department, sub-department, and service when opened (resolved lowercase key mismatch in `project-catalog-store.ts` so `departmentsForContractType` preserves database title-casing, aligned `openEditModal` with case-insensitive matching, and guaranteed current selections are always present in the select options).
  2. Change Unit Price currency sign from dollar (`$`) to rupee (`₹`) in Existing Project Masters table header, table rows, Add Form, Edit Modal, and Add Service Modal.
  3. Update Project Master Configuration Duration field: removed "40 hours" placeholder text, changed placeholder to `"e.g. 5"`, and restricted input to numbers only (`inputMode="numeric"`, `replace(/\D/g, "")`).
  4. Fix plus button and field overlap in Row 1: added `min-w-0`, `w-0 flex-1 min-w-0 overflow-hidden [&>span]:truncate [&>span]:block` to prevent long selected names (e.g. sub-departments, services) from expanding flex containers and overlapping adjacent fields.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/settings/masters/project-catalog-store.ts`: Preserved proper casing of department names per contract type in `contractTypeDepts` so `departmentsForContractType` returns exact database department names.
  - `apps/frontend/src/modules/settings/components/masters/project-masters-section.tsx`:
    - Case-insensitively aligned `item.department`, `item.subDepartment`, and `item.service` in `openEditModal` and ensured current selections are included in option lists.
    - Replaced `$` with `₹` in Existing Project Masters table, Add Form, Edit Modal, and Add Service Modal.
    - Restricted Duration field to numbers only with placeholder `"e.g. 5"`.
    - Added `min-w-0`, `w-0 flex-1`, and text truncation across Row 1 dropdowns and plus buttons to eliminate field overlapping.

#### 🗄️ Database & Schema Changes
- None (frontend UI display, state, and layout alignment).

#### 🔌 APIs & Business Logic Changed
- Preserved existing `updateProjectMaster` API logic, with `durationDays` accurately parsed from numbers-only input.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Edit modal saves correctly to backend API and updates PostgreSQL.
- Frontend builds cleanly with 0 errors.
- Active branch is `uat_clean3`.
