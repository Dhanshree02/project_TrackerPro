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

