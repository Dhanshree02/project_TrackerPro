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

- **Branch**: `uat_clean7`
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
  - Implemented `NotifyLeadershipOnStatusChangeAsync` to reliably dispatch Action Center notifications to EM, PM, and SPM when status changes to Approved, Hold, Rejected, or Request Changes.
- **Frontend State Management (`workspace-store.ts`)**:
  - Purged legacy `comments` from `localStorage` persistence and removed comments/requirements from `persistState` and `loadPersistedState` to ensure chat and status are never stored in browser memory.
  - Updated `updateCentralApprovalStatus` to de-duplicate comments and history before appending, preventing duplicate entries when local state synchronizes.
  - Updated `updateCentralApprovalStatus` to handle "Hold", "Request Changes", "Approved", and "Rejected", updating `req.status`, `req.approvedAtUtc`, and appending comments.
  - Replaced array in-place mutations with shallow copies (`state.requirements = [...state.requirements]`) to ensure React observers re-render immediately.
- **Frontend Project Detail Page (`project-detail-page.tsx`)**:
  - `WbsTab`: Fetches additional requirements via `fetchProjectAdditionalRequirements` and evaluates `isEditServicesEnabled` against both DB requirements and store requirements within 2 days of approval.
  - `RequirementDetailsModal`:
    - Removed the `<select>` status change dropdown list option, displaying the status as a read-only badge.
    - Added on-mount database query (`fetchProjectAdditionalRequirements`) to retrieve chat messages and status directly from the database table.
    - When comments are posted, updates state directly from the backend API response.
    - Displays closed notice with `CheckCircle2` icon and disables input when approved.
- **Frontend Action Center Page (`action-centre-page.tsx`)**:
  - Removed "Acknowledge" button and "Acked" badge from Central Approval Center table.
  - In Review Request modal, renders full Discussion Thread with duplicate message prevention, enables iterative action comments on "Hold", "Request Changes", and "Reject", and locks the view when "Approved".
  - Fixed double comment display issue in Review Request Discussion Thread by suppressing redundant local store comment pushes when `loadApprovals()` reloads the authoritative database state, and de-duplicating comments on parse and render.
  - Moved the `Audit Log History` section directly under the action comment section.
  - Calls `loadApprovals()` after taking actions to refresh authoritative records from the database table.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- "Edit Services" button in WBS must only be clickable within 2 days of an additional customer requirement approval.
- Two-way communication is strictly disallowed once a requirement is approved.
- All existing project detail, client engagement, and action center workflows are fully preserved.


### [2026-11-05] Low-Priority Customer, Sub-Venture, WBS, and Resource Onboarding Notification Delivery Fix

- **Branch**: `uat_clean7`
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

### [2026-11-04] Customer Onboarded Notification Recipient Refinement (Strictly Exclude Team Leader)

- **Branch**: `uat_clean6`
- **Module**: Action Centre / Customer Onboarding Notifications
- **Purpose**:
  - Refine the recipient filter for the "Customer Onboarded" notification (triggered when a customer is onboarded via `POST /api/v1/clients` -> `ClientService.CreateClientAsync`).
  - Strictly limit notification recipients to active resources whose Sub-Department is `EM (Engagement Manager)` AND whose On Floor Role in `resource.tbl_onfloorrole` is `Head Of Department` or `Leader`.
  - Explicitly exclude `Team Leader` from receiving the notification.

#### 📁 Files Affected
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
- **Modified**: `CHANGELOG_AI.md`

#### 🗄️ Database & Schema Changes
- None (uses existing `resource.tbl_employees`, `resource.tbl_onfloorrole`, and `action.tbl_notifications`).

#### 🔌 APIs & Business Logic Changed
- **`ActionNotificationService.NotifyCustomerOnboardedAsync`**:
  - Updated role matching filter to strictly verify `!rLower.Contains("team leader") && (rLower == "head of department" || rLower == "leader" || rLower.Contains("hod"))`.
  - Resources with On Floor Role `Team Leader` are explicitly excluded. Only `Head Of Department` and `Leader` within `EM (Engagement Manager)` receive the High priority `Customer Onboarded` notification.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Notification Priority remains `High`, Type remains `Customer Onboarded`.
- Dual database synchronization to `pms_uat` is preserved.


### [2026-11-04] Action Center Approvals Database Synchronization, Stakeholder-Specific Filtering, and Real-Time Reactive Rendering

- **Branch**: `uat_clean6`
- **Module**: Action Centre / Approvals & Project Health Extension Requests
- **Purpose**:
  1. Fix the Action Center Approvals tab where raised timeline extension requests were taking too much time or not appearing for the tagged stakeholder approvers.
  2. Implement reactive rendering across Zustand / store subscribers so newly submitted extension requests and backend fetch results display instantly without requiring manual UI dropdown clicks to force re-render.
  3. Ensure the database tables `project.tbl_project_extension_requests` and `project.tbl_project_extension_approvers` correctly filter pending and historical approvals strictly for the tagged stakeholder (and all requests for SuperAdmin).
  4. Add real-time loading feedback with a spinner and a one-click "Refresh" button in the Central Approval Center header.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/lib/workspace-store.ts`
- **Modified**: `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectExtensionRequestService.cs`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_project_extension_requests`
  - `project.tbl_project_extension_approvers`
  - `action.tbl_notifications`
- Verified schema and foreign key relationships. Ensured dual-database synchronization between `pms_uat_clean` and `pms_uat`.

#### 🔌 APIs & Business Logic Changed
- **Endpoints**:
  - `GET /api/v1/projects/extension-requests/pending-approvals`: Updated query logic to retrieve requests where `DeletedAtUtc == null` and approver matches `Approvers.Any(a => a.EmployeeId == empId)`. For SuperAdmin (`admin@talakunchi.com`, `Dhanshree`, `SuperAdmin`, `Admin`), returns all requests.
  - User resolution via `FindRequesterAsync` enhanced with fallback lookup on `tbl_employees.work_email` and `(FirstName + ' ' + LastName)` matching `currentUser.Name`.
- **Business Logic & Reactive Rendering**:
  - Added `setApprovals(approvals)` and `mergeApprovals(approvals)` methods to `dhStore` in `workspace-store.ts` that call `emit()` to notify all subscribers reactively.
  - Replaced silent in-place array mutation (`store.approvals.unshift`) with `dhStore.setApprovals` and `dhStore.mergeApprovals` in `action-centre-page.tsx` and `project-detail-page.tsx`.
  - Added `loadApprovals` callback tied to `[user.id, user.email, user.role]` so persona switching triggers an immediate re-fetch.
  - Added visual loading indicator in the Approvals table body and a "Refresh" button with spin animation in the header.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Approvals must only be visible to their explicitly tagged stakeholder approvers (except SuperAdmin who can view and govern all).
- Preserve existing Central Approval Center layout, request type filters, status filters, review modals, and acknowledge flow.
- Maintain dual DB sync to `pms_uat` for extension approvals and notifications.

### [2026-11-04] Health Tab Escalation Database Integration, Metric Filter Cards, Read-Only Review Modal, and Button Cleanup

- **Branch**: `uat_clean6`
- **Module**: Projects / Health / Escalations
- **Purpose**:
  1. Remove the "Raise Escalation" button, modal, and associated raising logic from the Project Health -> Escalations subtab (escalations are raised from the WBS tab).
  2. Preserve the exact existing Escalation table UI (`Escalation ID`, `Service`, `Subject`, `Type`, `Priority`, `Raised By`, `Expected Date`, `Status`, `Actions`), replacing the mock store binding with live database fetching via `fetchProjectServiceEscalations(project.id)`.
  3. Wire the 6 metric summary boxes (`Total`, `Open`, `In Progress`, `Waiting Customer`, `Resolved`, `Critical`) as interactive filters that filter table rows accordingly on click.
  4. Ensure the Review Details action is strictly view-only/read-only (no editing, read-only status badge, read-only resolution notes, read-only chat discussion, clickable inline attachments via `apiFetchBlob`, and a "Close" dismissal button).
  5. Synchronize escalation status, audit actors, and comments between Action Center alerts and `project.tbl_project_service_escalations`.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
- **Modified**: `apps/frontend/src/modules/projects/api/project-service-escalations.ts`
- **Modified**: `apps/backend/Modules/Projects/DTOs/ProjectServiceEscalationDtos.cs`
- **Modified**: `apps/backend/Modules/Projects/Services/IProjectServiceEscalationService.cs`
- **Modified**: `apps/backend/Modules/Projects/Services/ProjectServiceEscalationService.cs`
- **Modified**: `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`
- **Modified**: `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**: None (leveraged existing columns `Status`, `ChatJson`, `AttachmentPath`, and `ExpectedResolutionDate` in `project.tbl_project_service_escalations` and `project.tbl_project_alerts`).
- **Migrations / Scripts**: None required.

#### 🔌 APIs & Business Logic Changed
- **Backend API**:
  - `GET /api/v1/projects/{projectId}/service-escalations`:
    - Updated `ProjectServiceEscalationService.ListAsync` to join linked `ProjectAlert` rows to supply synchronized statuses (`Resolved`, `In Progress`, `Acknowledged`, etc.), `statusChangedBy`, `statusChangedAtUtc`, `chatJson`, and `resolutionDetails`.
    - Added `StatusChangedBy`, `StatusChangedAtUtc`, `ChatJson`, and `ResolutionDetails` to `ProjectServiceEscalationDto`.
  - `GET /api/v1/projects/{projectId}/service-escalations/{escalationId}/attachment`:
    - Added endpoint in `ProjectsController.cs` using `serviceEscalationService.DownloadAttachmentAsync` to stream escalation documents inline.
  - `PUT /api/v1/action-centre/alerts/{id}/governance`:
    - Updated `ActionNotificationService.UpdateAlertGovernanceAsync` to ensure `esc.Status = alert.Status` and `esc.ChatJson = alert.ChatJson` are saved whenever `alert.ServiceEscalationId` is present, even without new comments.
- **Frontend UI (`HealthEscalationsPanel` in `project-detail-page.tsx`)**:
  - Removed "Raise Escalation" button, `showRaiseModal`, and form states.
  - Bound the table to live project service escalations fetched via `fetchProjectServiceEscalations(project.id)`.
  - Added click handlers to `Total`, `Open`, `In Progress`, `Waiting Customer`, `Resolved`, and `Critical` summary boxes with active visual indicators (`ring-2 ring-primary border-primary`).
  - Added `formatToDayMonthYear` helper for `DD-MM-YYYY` dates on `Expected Date` and timeline items.
  - Transformed the Review Details modal into a read-only viewer displaying escalation metadata, inline clickable attachments, read-only status badge, read-only resolution notes, read-only discussion thread, and a "Close" button.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Escalation raising from the WBS tab prerequisite tracking section remains functional without restriction.
- Action Center alert governance, notifications acknowledgement, and WhatsApp-style discussion threads continue operating normally.
- Existing Health subtabs (`Issues`, `Alerts`, `Appreciation`, `Customer Engagement`, `Extension Request`) remain completely intact.

### [2026-11-04] WBS Prerequisite Tracking Escalation Raising for Newly Added and Modified Services

- **Branch**: `uat_clean6`
- **Module**: Projects / WBS / Prerequisite Tracking & Escalations
- **Purpose**:
  Enable raising escalations for Newly Added and Modified services directly from the WBS Tab -> "Service wise Prerequisite Tracking" table, matching the functionality and styling of standard service escalations.

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**: None (`tbl_project_service_escalations` already supports service escalations with or without GUID service IDs and custom service names).
- **Migrations / Scripts**: None required.

#### 🔌 APIs & Business Logic Changed
- **Frontend UI (`WbsPrerequisiteSection` in `project-detail-page.tsx`)**:
  - Replaced the static text placeholder (`Applied` / `Pending Start`) in the Escalation column of the linked modification prerequisite sub-row (`hasModification && wbsSvc`) with an interactive "Raise Escalation" button styled consistently with the main row button.
  - Linked the modification row button to `setEscalationModalSvc` passing `{ ...svc, serviceId: svc.serviceId || wbsSvc?.id, serviceName: \`${svc.serviceName || wbsSvc?.serviceName || "Service"} (Modification)\` }` and opening the Raise Escalation modal.
  - Enhanced the main row "Raise Escalation" button to reliably resolve `serviceId` and `serviceName` from either `svc` or `wbsSvc`, guaranteeing full support for Newly Added services (`changeStatus === "Newly Added"`).
  - Strengthened `wbsSvc` finding logic in `servicesList` iteration to reliably match by service ID, virtual index key (`svc-${idx}`), or service name.
  - Verified submission to `POST /api/v1/projects/{projectId}/service-escalations`, which saves the escalation and immediately displays it across both the WBS modal state and the Health tab Escalations list.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Ready to Start workflow for service modifications (`modCollectionStatus`, `modValidationStatus`, `modBillingStatus`, `modIsReady`) remains fully functional and unchanged.
- Deleted services (`isDeleted || changeStatus === "Deleted"`) remain disabled from raising escalations.
- Health Tab Escalations table and Action Center alerts continue to display and manage all raised escalations smoothly.

### [2026-11-04] Escalation Review Details Modal Chat Visibility, Scrollability, Stakeholder Hover, and Section Swap

- **Branch**: `uat_clean6`
- **Module**: Projects / Health / Escalations Review Details
- **Purpose**:
  1. Fix Discussion Thread Chat visibility in the Escalation Review Details modal by normalizing PascalCase and camelCase keys from `ChatJson`.
  2. Implement conditional scrollability on the chat section after 2 chats (`max-h-40 overflow-y-auto`) to allow viewing earlier messages.
  3. Prevent "Escalated To" stakeholder names from overlapping the field label by enforcing `shrink-0 whitespace-nowrap` on the label, displaying one name followed by `...` when multiple stakeholders are tagged, and showing all stakeholder names on hover via tooltip.
  4. Swap the positions and column widths of the "Resolution & Outcome Notes" section and the "Discussion Thread Chat" section so the chat occupies the wider left column (`md:col-span-2`) and the resolution notes occupy the narrower right column (`md:col-span-1`).

#### 📁 Files Affected
- **Modified**: `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**: None (leveraged existing columns `ChatJson`, `Status`, `ResolutionDetails`, `ExpectedResolutionDate` in `project.tbl_project_service_escalations`).
- **Migrations / Scripts**: None required.

#### 🔌 APIs & Business Logic Changed
- **Frontend UI (`HealthEscalationsPanel` in `project-detail-page.tsx`)**:
  - `parsedComments`: Normalizes parsed JSON comment objects mapping both PascalCase (`Text`, `AuthorName`, `AuthorEmail`, `At`) and camelCase keys, resolving invisible chat message text.
  - `stakeholderNames`: Maps escalation stakeholders safely. When more than one stakeholder is present, renders `{stakeholderNames[0]}...` with `title={stakeholderNames.join(", ")}` and `cursor-pointer hover:underline`, avoiding label overlap.
  - Discussion Thread Chat: Relocated to the wide left column (`md:col-span-2`) and configured with `max-h-40 overflow-y-auto pr-1` whenever there are more than 2 messages.
  - Resolution & Outcome Notes: Relocated to the narrow right column (`md:col-span-1`) below status and attachments.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Read-only integrity of the Review Details modal remains enforced.
- Inline attachment viewing via `apiFetchBlob` remains functional.
- Dynamic filtering on summary metric cards (`Total`, `Open`, `In Progress`, `Waiting Customer`, `Resolved`, `Critical`) remains intact.

### [2026-11-04] Health Tab Appreciation Feature, Team Tab Resource Integration, and Action Center Notification Dispatch

- **Branch**: `uat_clean6`
- **Module**: Projects / Health / Appreciation & Action Center
- **Purpose**:
  1. Implement the Appreciation tab under the Health tab in project details.
  2. Render the "Appreciation" button which opens a modal with 3 fields:
     - Resource: Dropdown strictly listing project resources present in the Team tab from the database.
     - Badge: Dropdown to select an appreciation badge.
     - Message: Textarea for the appreciation note.
  3. On Send, persist the appreciation into a new database table under the project schema (`project.tbl_project_appreciations`).
  4. Display the list of appreciated resources loaded from the database table directly underneath the Appreciation button.
  5. Dispatch an Action Center notification into `action.tbl_notifications` assigned to the selected recipient's Action Center (notification only, strictly no alert created in `project.tbl_project_alerts`).

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Modules/Projects/Models/ProjectAppreciation.cs`
  - `apps/backend/Modules/Projects/DTOs/ProjectAppreciationDtos.cs`
  - `apps/backend/Infrastructure/Persistence/Configurations/ProjectAppreciationConfiguration.cs`
  - `apps/backend/Modules/Projects/Services/IProjectAppreciationService.cs`
  - `apps/backend/Modules/Projects/Services/ProjectAppreciationService.cs`
  - `apps/frontend/src/modules/projects/api/project-appreciations.ts`
- **Modified**:
  - `apps/backend/Infrastructure/Persistence/AppDbContext.cs`
  - `apps/backend/Configuration/DependencyInjectionExtensions.cs`
  - `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
  - `.env`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - Created `project.tbl_project_appreciations`:
    - Columns: `Id` (UUID PK), `ProjectId` (UUID FK), `RecipientEmployeeId` (UUID), `RecipientName` (VARCHAR(200)), `RecipientEmail` (VARCHAR(200)), `RecipientRole` (VARCHAR(100)), `Badge` (VARCHAR(100)), `Message` (TEXT), `GivenByEmployeeId` (UUID), `GivenByName` (VARCHAR(200)), `CreatedAtUtc` (TIMESTAMPTZ), `UpdatedAtUtc` (TIMESTAMPTZ), `DeletedAtUtc` (TIMESTAMPTZ), `CreatedBy` (UUID), `UpdatedBy` (UUID).
    - Indexes: `ix_tbl_project_appreciations_project_id` on `ProjectId`, `ix_tbl_project_appreciations_recipient_id` on `RecipientEmployeeId`.
  - Created and verified on active remote PostgreSQL web database (`10.50.30.189:41763/pms_uat_clean`), remote `pms_uat`, and local `trackerpro`.
- **Migrations / Scripts**: Applied direct DDL and EF Core entity configuration in `ProjectAppreciationConfiguration.cs`.

#### 🔌 APIs & Business Logic Changed
- **Backend API**:
  - `GET /api/v1/projects/{projectId}/appreciations`: Returns list of appreciations for the project ordered by `CreatedAtUtc DESC`.
  - `POST /api/v1/projects/{projectId}/appreciations`:
    - Validates that `RecipientEmployeeId` belongs to an active team member allocated in `project.tbl_project_team_members` for that project.
    - Resolves recipient profile details and current user identity.
    - Inserts record into `project.tbl_project_appreciations`.
    - Automatically creates a notification record in `action.tbl_notifications` (`Type = "Appreciation Received"`, `Status = "Pending"`, `Priority = "Low"`, `RecipientEmployeeId = RecipientEmployeeId`) so it surfaces in the recipient's Action Center. No alert is added to `project.tbl_project_alerts`.
- **Frontend UI**:
  - Created API client `apps/frontend/src/modules/projects/api/project-appreciations.ts`.
  - Updated `HealthAppreciationPanel` in `project-detail-page.tsx`:
    - Resource dropdown is loaded via `fetchProjectTeamMembers(project.id)` to guarantee only resources on the Team tab can be selected.
    - Badge dropdown includes standard recognition badges (`Star Performer`, `Team Player`, `Problem Solver`, `Innovator`, `Quick Learner`, `Customer Champion`, `Quality Champion`, `High Ownership`).
    - Message field provides note input.
    - Send button submits payload to `POST /api/v1/projects/{projectId}/appreciations` with loading state and error handling.
    - Under the Appreciation button, renders live cards displaying recipient name, role, badge chip, appreciation note, giver name, and formatted date (`formatToDayMonthYear`).
  - Added purple pill styling for `Appreciation Received` notification badges in `action-centre-page.tsx`.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Only resources present in the Team tab from the database are selectable for appreciation.
- Strictly notifications only in `action.tbl_notifications`; no records are created in `project.tbl_project_alerts`.
- All other Health subtabs (`Issues`, `Alerts`, `Escalations`, `Customer Engagement`, `Extension Request`) and existing Team tab functionality remain unaffected.

### [2026-11-04] Customer Engagement Interview Scheduling Database Verification and Action Center Notification Dispatch on Interview Result Changes

- **Branch**: `uat_clean6`
- **Module**: Projects / Health / Customer Engagement / Interview Scheduling & Action Center
- **Purpose**:
  1. Verify the backend and database integration for Customer Engagement -> Interview Scheduling under the Health tab.
  2. When the `Interview Result *` status is updated (e.g. to `Selected`, `Rejected`, `Postponed`, or rescheduled), automatically dispatch Action Center notifications to:
     - The selected candidate Resource.
     - The selected Resource's Reporting Manager (`ReportingManagerId`).
  3. Ensure notifications are created exclusively in `action.tbl_notifications` (notification tab, strictly no alerts in `project.tbl_project_alerts`).
  4. Ensure both recipients see the notification in their Action Center Notifications tab with appropriate type badges (`Customer Interview Selected`, `Customer Interview Rejected`, `Customer Interview Postponed`).

#### 📁 Files Affected
- **Modified**:
  - `apps/backend/Modules/Projects/Services/ProjectInterviewService.cs`
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - Verified existing table `project.tbl_project_interviews` across remote PostgreSQL web database (`10.50.30.189:41763/pms_uat_clean`), remote `pms_uat`, and local `trackerpro`.
  - Notification records inserted into `action.tbl_notifications`.
- **Migrations / Scripts**: None required (leveraged existing tables and schemas).

#### 🔌 APIs & Business Logic Changed
- **Backend API (`ProjectInterviewService.cs`)**:
  - Injected `ICurrentUserService` into `ProjectInterviewService`.
  - Updated `UpdateAsync`:
    - Detects when `request.Result` changes compared to existing `row.Result`.
    - Resolves the candidate employee and their reporting manager from `resource.tbl_employees`.
    - Resolves the updater actor name from `ICurrentUserService` / `db.Employees`.
    - Dispatches an `ActionNotification` into `action.tbl_notifications` for both the candidate resource and their reporting manager:
      - Candidate Resource receives title: `Customer Interview Result: {Result} — {ProjectName}`.
      - Reporting Manager receives title: `Customer Interview {Result}: {ResourceName} — {ProjectName}`.
      - Type mapped appropriately (`Customer Interview Selected`, `Customer Interview Rejected`, `Customer Interview Postponed`).
      - Priority set based on outcome (`Rejected` -> `High`, `Selected` / `Postponed` -> `Medium`).
      - Status set to `Pending` and `Unread = true`.
      - Related task populated with interview remarks or date/time.
      - Full timeline history JSON attached.
- **Frontend UI (`action-centre-page.tsx`)**:
  - Added `"Customer Interview Postponed"` to `NOTIFICATION_TYPES` filter options.
  - Enhanced `getTypeStyles` so that `selected` displays emerald badge, `rejected` displays red badge, and `postponed` displays amber badge.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Interview scheduling and reschedule functionality continue operating without modification.
- Existing validation enforcing comments when an interview is postponed remains intact.
- Notifications are strictly dispatched to `action.tbl_notifications` without generating alerts in `project.tbl_project_alerts`.


### [2026-11-04] Health Tab Customer Engagement Additional Customer Requirements & Scope Cancellation, Documents Storage, Multi-Stakeholder Action Center Notifications, Sales Approval Workflow, and 2-Day WBS Edit Services Gate

- **Branch**: `uat_clean6`
- **Module**: Projects / Health / Customer Engagement / Additional Customer Requirements & WBS & Action Center
- **Purpose**:
  1. Implement the backend, database persistence, and frontend workflow for Health tab -> Customer Engagement -> Additional Customer Requirement.
  2. Remove the manual "Requested By" field from the modal form and automatically record the authenticated user who initiated the request.
  3. Ensure that when using the "Scope Cancellation" tab, the "Service to Cancel *" dropdown values are dynamically loaded from the live project services in the database (`project.tbl_project_services`).
  4. Ensure any uploaded requirement attachment file is physically stored into the repo root directory `Documents/Customer Requirement` (creating the directory if absent).
  5. On requirement creation, automatically dispatch "notification only" (in `action.tbl_notifications`, no alerts) to:
     - Assigned Sales Person
     - Project Manager
     - Senior Project Manager
     - Engagement Manager
  6. ONLY the Assigned Sales Person receives an "Approval Request" in their Action Center Approvals tab.
  7. When the Assigned Sales Person approves the requirement:
     - The Project Manager, Senior Project Manager, and Engagement Manager receive an Action Center notification stating that the requirement is Approved.
     - The "Edit Services" button in the WBS tab ("Services & Deliverables from WBS" section) is unlocked and enabled for exactly 2 days (48 hours) from the timestamp of approval. If no approved requirement exists within the 2-day window, the button remains disabled with an informative tooltip.

#### 📁 Files Affected
- **Created**:
  - `apps/backend/Modules/Projects/Models/ProjectAdditionalRequirement.cs`
  - `apps/backend/Modules/Projects/DTOs/ProjectAdditionalRequirementDtos.cs`
  - `apps/backend/Infrastructure/Persistence/Configurations/ProjectAdditionalRequirementConfiguration.cs`
  - `apps/backend/Modules/Projects/Services/IProjectAdditionalRequirementService.cs`
  - `apps/backend/Modules/Projects/Services/ProjectAdditionalRequirementService.cs`
  - `apps/frontend/src/modules/projects/api/project-additional-requirements.ts`
  - `Documents/Customer Requirement/` (directory for uploaded attachments)
- **Modified**:
  - `apps/backend/Infrastructure/Storage/IFileStorageService.cs`
  - `apps/backend/Infrastructure/Storage/FileStorageService.cs`
  - `apps/backend/Infrastructure/Persistence/AppDbContext.cs`
  - `apps/backend/Configuration/DependencyInjectionExtensions.cs`
  - `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`
  - `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`
  - `apps/frontend/src/lib/workspace-store.ts`
  - `apps/frontend/src/types/domain.types.ts`
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - Created `project.tbl_project_additional_requirements` on PostgreSQL (`10.50.30.189:41763/pms_uat_clean` and `pms_uat`):
    - `Id` UUID PRIMARY KEY DEFAULT gen_random_uuid()
    - `RequirementId` VARCHAR(50) NOT NULL
    - `ProjectId` UUID NOT NULL REFERENCES `project.tbl_projects(Id)` ON DELETE CASCADE
    - `ClientName` VARCHAR(255)
    - `ProjectName` VARCHAR(255)
    - `RequirementType` VARCHAR(50) NOT NULL ("Add Service" or "Scope Cancellation")
    - `Title` VARCHAR(255) NOT NULL
    - `Description` TEXT NOT NULL
    - `Priority` VARCHAR(50) NOT NULL DEFAULT 'Medium'
    - `RequestedByEmployeeId` UUID NULL
    - `RequestedByName` VARCHAR(255) NOT NULL
    - `RequestedDate` DATE NOT NULL DEFAULT CURRENT_DATE
    - `AttachmentFileName` VARCHAR(255) NULL
    - `AttachmentPath` TEXT NULL
    - `ScopeCancellationService` VARCHAR(255) NULL
    - `Status` VARCHAR(50) NOT NULL DEFAULT 'Open'
    - `ApprovedAtUtc` TIMESTAMPTZ NULL
    - `ApprovedByEmployeeId` UUID NULL
    - `ApprovedByName` VARCHAR(255) NULL
    - `ApprovalComments` TEXT NULL
    - `CommentsJson` TEXT NOT NULL DEFAULT '[]'
    - `HistoryJson` TEXT NOT NULL DEFAULT '[]'
    - Audit fields: `CreatedAtUtc`, `UpdatedAtUtc`, `CreatedBy`, `UpdatedBy`, `DeletedAtUtc`
  - Indexes: `IX_tbl_project_additional_requirements_ProjectId` and `IX_tbl_project_additional_requirements_Status`.
  - Notification records inserted into `action.tbl_notifications`.

#### 🔌 APIs & Business Logic Changed
- **Backend API**:
  - `IFileStorageService` / `FileStorageService`: Added `SaveCustomerRequirementDocumentAsync`, ensuring uploads are written to `Documents/Customer Requirement` with timestamp and sanitized identifiers.
  - `POST /api/v1/projects/{projectId}/additional-requirements`:
    - Accepts multipart form data with optional `AttachmentFile`.
    - Automatically records the current user as requester.
    - Resolves project leadership (Sales Person via `SalesPersonId` or employee lookup, Project Manager, Senior Project Manager from team members, Engagement Manager).
    - Dispatches notifications only into `action.tbl_notifications` to Assigned Sales Person, PM, SPM, and EM.
  - `GET /api/v1/projects/{projectId}/additional-requirements`: Returns all additional customer requirements logged for the project.
  - `POST /api/v1/projects/{projectId}/additional-requirements/{id}/approve`:
    - Validates approval, updates requirement status to `Approved`, records `ApprovedAtUtc = DateTime.UtcNow`, approver identity, and comment.
    - Dispatches notifications into `action.tbl_notifications` to Project Manager, Senior Project Manager, and Engagement Manager notifying them of the approval.
  - `POST /api/v1/projects/{projectId}/additional-requirements/{id}/reject`: Marks requirement as `Rejected`.
  - `GET /api/v1/action-centre/approvals`: Retrieves pending requirement approvals for the logged-in user.
- **Frontend UI**:
  - Created `apps/frontend/src/modules/projects/api/project-additional-requirements.ts`.
  - Updated `AdditionalRequirementsPanel` in `project-detail-page.tsx`:
    - Removed manual "Requested By" input field from the modal form.
    - Automatically captures authenticated user's name as requester.
    - Loaded live services for "Scope Cancellation" dropdown from database via `fetchProjectServices(project.id)`.
    - Added file browse upload wired to `createProjectAdditionalRequirement` multipart form submission.
    - Synchronized created requirement and added approval entry to `store.approvals`.
  - Updated `ActionCentrePage`:
    - Added `"approvals"` to `salesTabCodes` (`["approvals", "alerts", "notifications"]`) so Sales Person can access the Approvals tab.
    - In `ApprovalsTab`, loaded pending approvals from backend and wired approval/rejection actions to backend APIs.
  - Updated `WbsTab` in `project-detail-page.tsx`:
    - Enforced the 2-day gate on the "Edit Services" button: only enabled if an approved customer requirement exists for the project where `Date.now() - new Date(approvedAtUtc).getTime() <= 2 * 24 * 60 * 60 * 1000`.
    - Shows an informative tooltip when disabled explaining that Edit Services requires an approved customer requirement by Sales within the last 2 days.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Notifications are strictly dispatched to `action.tbl_notifications` without generating alerts in `project.tbl_project_alerts`.
- Only the Assigned Sales Person receives the approval request in Action Center Approvals.
- The 2-day Edit Services enablement gate strictly respects the 48-hour window from approval timestamp.
- Scope cancellation services are dynamically sourced from live project services in the database.
- Existing Health subtabs, WBS calculations, and Action Center workflows remain fully operational.


### [2026-11-04] Fix ReferenceError: store is not defined in WbsTab

- **Branch**: `uat_clean6`
- **Module**: Projects / WBS
- **Purpose**:
  Resolve runtime crash `ReferenceError: store is not defined at WbsTab` when opening the WBS tab.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/lib/workspace-store.ts`
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**: None.
- **Migrations / Scripts**: None.

#### 🔌 APIs & Business Logic Changed
- **Frontend (`project-detail-page.tsx`)**:
  - Added `const store = useDhStore((s) => s);` inside `WbsTab` component so `store.requirements` is available.
  - Replaced manual snapshot array mutations with `dhStore.mergeRequirements(...)` in both `WbsTab` and `AdditionalRequirementsPanel`.
- **Frontend Store (`workspace-store.ts`)**:
  - Added `setRequirements(requirements)` and `mergeRequirements(requirements)` methods to `dhStore` with proper reactive `emit()`.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Preserves the 2-day enablement window for the "Edit Services" button based on approved customer requirements.
- Preserves all other WBS table interactions, deliverables, and service modification flows.


### [2026-11-04] Health Tab Extension Request Modal UI Improvement, Action Center Approvals Integration, Project End Date Update, and Multi-Stakeholder Notification Workflow

- **Branch**: `uat_clean6`
- **Module**: Projects / Health / Extension Request & Action Center Approvals
- **Purpose**:
  1. Fix the UI bug where clicking the "Tag Stakeholder Approvers" list field in the Extension Request modal expanded/stretched the modal dialog vertically; improved the UI of the approver selection field with a non-expanding floating popover (opening upwards over textarea), search bar, employee avatar initials, department badge, and clean compact chips.
  2. Implement the end-to-end approval flow: when an extension request is submitted with tagged PMO approvers, an approval request is dispatched to the selected stakeholders in their Action Center Approvals tab.
  3. On approval by the tagged stakeholder in Action Center:
     - The extension request status is updated to `Approved`.
     - The project's `EndDate` in `project.tbl_projects` (both `pms_uat_clean` and `pms_uat`) is replaced/increased with `RequestedEndDate`.
     - Notification ONLY (dispatched to `action.tbl_notifications`, NO alerts in `project.tbl_project_alerts`) is sent to:
       - Assigned Team Lead
       - Assigned Project Manager
       - Assigned Senior Project Manager
       - Assigned Engagement Manager
       - Whole PMO Team (all active employees whose Sub-Department is `PMO (Project Management Office)` in `resource.tbl_employees`).
  4. On rejection, request is marked as `Rejected` and the requester is notified.

#### 📁 Files Affected
- **Modified**:
  - `apps/frontend/src/modules/projects/pages/project-detail-page.tsx`
  - `apps/frontend/src/modules/projects/api/project-extension-requests.ts`
  - `apps/frontend/src/modules/action-centre/pages/action-centre-page.tsx`
  - `apps/backend/Modules/Projects/DTOs/ProjectExtensionRequestDtos.cs`
  - `apps/backend/Modules/Projects/Services/IProjectExtensionRequestService.cs`
  - `apps/backend/Modules/Projects/Services/ProjectExtensionRequestService.cs`
  - `apps/backend/Modules/Projects/Controllers/ProjectsController.cs`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `project.tbl_projects` (`EndDate`, `UpdatedAtUtc` updated on approval in both `pms_uat_clean` and `pms_uat`).
  - `project.tbl_project_extension_requests` (`Status`, `UpdatedAtUtc`).
  - `project.tbl_project_extension_approvers` (`Status`, `UpdatedAtUtc`).
  - `action.tbl_notifications` (inserted notifications for tagged approvers on submit, and for TL, PM, SPM, EM, and PMO team on approval).
- **Migrations / Scripts**: Leveraged existing schemas and verified across both `pms_uat_clean` and `pms_uat`.

#### 🔌 APIs & Business Logic Changed
- **Backend API**:
  - `GET /api/v1/projects/extension-requests/pending-approvals`:
    - Retrieves pending extension requests for tagged approvers (or all pending requests for PMO/Admin).
  - `POST /api/v1/projects/{projectId}/extension-requests/{extensionRequestId}/approve`:
    - Validates pending request, marks status as `Approved`, updates project `EndDate` to `RequestedEndDate`, synchronizes to `pms_uat`, and creates notifications for TL, PM, SPM, EM, and all PMO employees.
  - `POST /api/v1/projects/{projectId}/extension-requests/{extensionRequestId}/reject`:
    - Marks status as `Rejected` and notifies requester.
- **Frontend UI & API**:
  - `project-detail-page.tsx` (`ExtensionRequestPanel`):
    - Converted the inline expanding approver list into a floating popover (`absolute bottom-full mb-1.5 left-0 right-0 z-50`) with outside-click dismissal (`useRef`), ensuring the modal window height never increases when interacting with the approver field.
    - Added user initials avatar, employee code, checkmarks, live search, and compact removable chip badges.
    - On submit, adds the new approval request to `store.approvals` and refreshes extension requests.
  - `action-centre-page.tsx` (`ApprovalsTab`):
    - Added loading of `fetchPendingExtensionApprovals()` to display pending timeline extension requests.
    - Updated `handleAction` to invoke `approveProjectExtensionRequest` / `rejectProjectExtensionRequest` when acting on `"Timeline Extension Approval"`.
  - `project-extension-requests.ts`:
    - Added API client methods `fetchPendingExtensionApprovals`, `approveProjectExtensionRequest`, and `rejectProjectExtensionRequest`.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Only notifications are dispatched (`action.tbl_notifications`), never creating alerts in `project.tbl_project_alerts`.
- Project `EndDate` is updated strictly when the stakeholder approves the request.
- Tagged approvers must be active employees in `PMO (Project Management Office)`.
- Existing UI table in Extension Request panel and all other Health subtabs remain unchanged.


### [2026-11-04] Targeted Action Center Notifications for Customer Onboarding, WBS Creation, and Resource Onboarding

- **Branch**: `uat_clean6`
- **Module**: Action Center / Customers / Projects / Resources
- **Purpose**:
  1. Trigger Action Center notifications upon Customer Onboarding (`POST /api/v1/clients`), dispatched strictly to active resources whose Sub-Department is `EM (Engagement Manager)` and whose On Floor Role is `Head Of Department` or `Leader` (including `Team Leader`).
  2. Trigger Action Center notifications upon WBS / Project Creation (`POST /api/v1/projects`), dispatched strictly to active resources whose Sub-Department is `EM (Engagement Manager)` or `PMO (Project Management Office)` and whose On Floor Role is `Head Of Department`.
  3. Trigger Action Center notifications upon Resource Onboarding (`POST /api/v1/employees`), dispatched strictly to:
     - The Reporting Manager assigned to the newly onboarded resource.
     - Active resources whose Sub-Department is `EM (Engagement Manager)` or `PMO (Project Management Office)` and whose On Floor Role is `Sr. Manager` or `Manager`.
  4. Ensure notifications are created exclusively in `action.tbl_notifications` (no alerts generated in `project.tbl_project_alerts`) and properly synchronized across both `pms_uat_clean` and `pms_uat`.

#### 📁 Files Affected
- **Modified**:
  - `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`
  - `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`
  - `apps/backend/Modules/Customers/Services/ClientService.cs`
  - `apps/backend/Modules/Projects/Services/ProjectAppService.cs`
  - `apps/backend/Modules/Resources/Services/EmployeeService.cs`
  - `apps/backend/Modules/ActionCentre/Models/ActionNotification.cs`
  - `apps/backend/Infrastructure/Persistence/Configurations/ActionNotificationConfiguration.cs`
  - `apps/backend/Modules/ActionCentre/DTOs/ActionNotificationDtos.cs`

#### 🗄️ Database & Schema Changes
- **Tables / Columns Affected**:
  - `action.tbl_notifications` (`ProjectId` and `ProjectName` made nullable via `ALTER TABLE action.tbl_notifications ALTER COLUMN "ProjectId" DROP NOT NULL;` and `ALTER COLUMN "ProjectName" DROP NOT NULL;` across both `pms_uat_clean` and `pms_uat`) to allow org-wide, customer-level, and resource-level notification records without a mandatory project foreign key.
- **Migrations / Scripts**:
  - Updated `ActionNotification.cs` (`Guid? ProjectId`, `string? ProjectName`), `ActionNotificationConfiguration.cs` (`IsRequired(false)` on FK and ProjectName), and `ActionNotificationDtos.cs` (`Guid? ProjectId`).

#### 🔌 APIs & Business Logic Changed
- **`IActionNotificationService` & `ActionNotificationService`**:
  - Added `NotifyCustomerOnboardedAsync(Guid clientId, string clientName, string? clientCode, string? createdByName, CancellationToken ct)`:
    - Filters active candidates where `SubDepartment` is `EM (Engagement Manager)`.
    - Matches On-Floor Role from `resource.tbl_onfloorrole` (or employee role) against `Head Of Department` and `Leader` (excluding `Team Leader`).
    - Creates `Type = "Customer Onboarded"` notification with Priority `High` and syncs to `pms_uat`.
  - Added `NotifyWbsCreatedAsync(Guid projectId, string projectName, string? wbsId, string? projectCode, string? createdByName, CancellationToken ct)`:
    - Filters active candidates where `SubDepartment` is `EM (Engagement Manager)` or `PMO (Project Management Office)`.
    - Matches On-Floor Role from `resource.tbl_onfloorrole` (or employee role) against `Head Of Department`.
    - Creates `Type = "WBS Created"` notification with Priority `High` and syncs to `pms_uat`.
  - Added `NotifyResourceOnboardedAsync(Guid employeeId, string employeeName, string employeeCode, Guid? reportingManagerId, string? performerName, CancellationToken ct)`:
    - Adds the assigned `reportingManagerId` resource if specified.
    - Filters active candidates where `SubDepartment` is `EM (Engagement Manager)` or `PMO (Project Management Office)`.
    - Matches On-Floor Role from `resource.tbl_onfloorrole` (or employee role) against `Sr. Manager` or `Manager`.
    - Creates `Type = "Resource Onboarded"` notification with Priority `High` and syncs to `pms_uat`.
- **`ClientService.cs`**:
  - Injected `IActionNotificationService` and invoked `NotifyCustomerOnboardedAsync` right after client graph persistence and code generation.
- **`ProjectAppService.cs`**:
  - Injected `IActionNotificationService` and `ICurrentUserService`, invoking `NotifyWbsCreatedAsync` after project creation transaction commit.
- **`EmployeeService.cs`**:
  - Injected `IActionNotificationService`, invoking `NotifyResourceOnboardedAsync` after employee insertion and user sync.

#### ⚠️ Critical Dependencies & Invariants to Preserve
- Notifications are strictly dispatched to `action.tbl_notifications` without generating alerts in `project.tbl_project_alerts`.
- Dual database synchronization to `pms_uat` is maintained for all newly created notifications.
- Existing Action Center Notification flows (approvals, extension requests, prerequisite escalations, interview scheduling) remain fully operational and unaltered.
