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
