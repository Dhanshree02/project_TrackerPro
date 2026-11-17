# Changelog - Customer and Sub-Venture Edit Notifications & Title Formatting

## Summary of Changes
Updated Action Centre notification dispatching and formatting for Customer and Customer Sub-Venture profile edits:
1. **Target Recipients**:
   - Notifications are dispatched directly to the customer's assigned **Engagement Manager** (`EngagementManagerId` / `EngagementManager`).
   - Notifications are dispatched to all active employees whose On Floor Role is **`Head Of Department`** (`resource.tbl_onfloorrole` mapped via `DesignationId` or role definition `Head Of Department` / `-HOD`, strictly excluding Team Leaders).
2. **Notification Title Formatting**:
   - Single field edited: `{Customer name or Subventure name} {Field name of the edited field} is edited` (e.g., `Acme Corp Industry is edited`, `Acme Subventure Name is edited`).
   - Multiple fields edited (>1): `{Customer name or Subventure name} {Fields name of the edited field} are edited` (e.g., `Acme Corp Industry, Notes are edited`, `Acme Subventure Name, Notes are edited`).
   - No fields specified: `{Customer name or Subventure name} is edited`.
   - History details text aligned to match singular/plural verb (`is edited by {editorName}.` / `are edited by {editorName}.`).

---

## Affected Files
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - Added `ResolveCustomerEditNotificationRecipientsAsync` to strictly resolve the customer's assigned Engagement Manager and all active HODs with On Floor Role `Head Of Department`.
  - Updated `NotifyCustomerEditedAsync` and `NotifySubVentureEditedAsync` to dynamically format titles using singular (`is edited`) vs plural (`are edited`) based on distinct changed field counts.
- `apps/backend/tests/PMS.IntegrationTests/CustomerNotificationIntegrationTests.cs`:
  - Updated `CustomerProfileEdit_DispatchesNotification_WithEditedStatusAndTitle` to expect plural `are edited` on multi-field updates and verified notification receipt by both Engagement Manager and HODs.
  - Updated `SubVentureEdit_DispatchesNotification_WithSubVentureEditedTitle` to expect plural `are edited` on multi-field updates and verified notification receipt by both Engagement Manager and HODs.
  - Updated `CustomerSingleFieldEdit_DispatchesNotification_WithSingleFieldInTitle` to verify singular `is edited` on single-field updates and verified notification receipt by both Engagement Manager and HODs.
  - Added `SubVentureSingleFieldEdit_DispatchesNotification_WithSingleFieldInTitle` integration test verifying singular `is edited` on single-field updates for sub-ventures and recipient delivery.

---

## Database Changes and Migrations
- **None**: Reuses existing schema in `action.tbl_notifications`, `customer.tbl_clients`, `resource.tbl_employees`, and `resource.tbl_onfloorrole`.

---

## API Changes
- **None**: Internal notification resolution and dispatching logic updated; REST API endpoints for customer and sub-venture updates (`PUT /api/v1/clients/{id}`) remain backward compatible.

---

## Existing Functionality Preserved
- Customer and sub-venture onboarding notifications (`NotifyCustomerOnboardedAsync`, `NotifySubVentureOnboardedAsync`) remain intact.
- Customer manager reassignment notifications (`NotifyCustomerManagerChangedAsync`) remain intact.
- Strict exclusion of Team Leaders from HOD role resolution remains enforced.
- Cross-database notification synchronization (`TrySyncNotificationsToOtherDatabase`) remains intact.

---

# Changelog - WBS Service Wise Prerequisite Tracking Notifications & Multi-Level SLA Breach Escalations

## Summary of Changes
Implemented automated Action Centre notifications and multi-level Hangfire SLA breach escalations for WBS Service wise Prerequisite Tracking:
1. **Service Started Notification**:
   - Triggered when a service is started from "Service wise Prerequisite Tracking" (in UI: "Ready to Start" -> "✓ Started"; API: `PATCH /api/v1/projects/{projectId}/services/{serviceId}/prerequisite` with `{ isReady: true }`).
   - Dispatches Action Centre notification to:
     - Assigned **Project Manager** (`ProjectManagerId` / `ProjectManager` / `ProjectTeamMembers`).
     - Assigned **Engagement Manager** (`EngagementManagerId` / `EngagementManager` / `ProjectTeamMembers`).
     - Assigned **Team Lead** (`TeamLeadId` / `TeamLead` / `ProjectTeamMembers` with `IsTeamLead` or Team Lead role).
   - Cancels and terminates any pending SLA 1st level and 2nd level escalation jobs for this service.
2. **1st Level Breach Escalation (Service Not Started Within 2 Working Days at EOD)**:
   - When a service is added or pending and is not started within 2 working days (1080 minutes working time in business hours, ending at 18:00 IST), a 1st level breach escalation job executes in Hangfire at EOD.
   - Verifies directly from the database that `!service.IsReady`.
   - Dispatches 1st level breach escalation Action Centre notification directly to the **Assigned Project Manager** at EOD (`Title: 1st Level Breach Escalation: Service Not Started | {ServiceName} | {ProjectName}`, Priority: `High`).
3. **2nd Level Breach Escalation (Service Still Not Started After 1st Escalation at EOD)**:
   - When a service remains unstarted after the 1st level escalation, a 2nd level breach escalation job executes in Hangfire at the next EOD (18:00 IST).
   - Verifies directly from the database that `!service.IsReady`.
   - Dispatches 2nd level breach escalation Action Centre notification directly to the **Head of Department (HOD)** at EOD (`Title: 2nd Level Breach Escalation: Service Not Started | {ServiceName} | {ProjectName}`, Priority: `Urgent`).

---

## Affected Files
- `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`:
  - Added method declarations: `NotifyServiceStartedAsync`, `StartServicePrerequisiteSlaWorkflowAsync`, `CancelServicePrerequisiteSlaWorkflowAsync`, `ExecuteServicePrerequisiteL1EscalationJobAsync`, and `ExecuteServicePrerequisiteL2EscalationJobAsync`.
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - Implemented `NotifyServiceStartedAsync` resolving Project Manager, Engagement Manager, and Team Lead.
  - Implemented `StartServicePrerequisiteSlaWorkflowAsync` scheduling 2 working days L1 escalation at EOD (18:00 IST) and subsequent L2 escalation for HODs.
  - Implemented `CancelServicePrerequisiteSlaWorkflowAsync` to terminate Hangfire jobs when service is marked ready/started.
  - Implemented `ExecuteServicePrerequisiteL1EscalationJobAsync` and `ExecuteServicePrerequisiteL2EscalationJobAsync` with database validation against `IsReady` and cross-database sync.
- `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
  - In `UpdateServicePrerequisiteReadyAsync`: triggers `NotifyServiceStartedAsync` and `CancelServicePrerequisiteSlaWorkflowAsync` when `isReady` becomes `true`.
  - In `AddProjectServiceAsync`: triggers `StartServicePrerequisiteSlaWorkflowAsync` when adding a service that is not yet ready.
  - In `CreateProjectAsync`: schedules SLA workflow for unstarted services in new projects.
- `apps/backend/tests/PMS.IntegrationTests/ServicePrerequisiteNotificationTests.cs`:
  - Added integration test suite covering 6 scenarios:
    1. Service started dispatches notification to Project Manager, Engagement Manager, and Team Lead.
    2. Starting service cancels pending Hangfire escalation jobs.
    3. L1 breach escalation job executes and dispatches notification to Project Manager when service is unstarted.
    4. L1 breach escalation job skips notification if service was started prior to job run.
    5. L2 breach escalation job executes and dispatches notification to HOD when service remains unstarted.
    6. L2 breach escalation job skips notification if service was started prior to job run.

---

## Database Changes and Migrations
- **None**: Uses existing schemas in `action.tbl_action_notifications`, `project.tbl_projects`, `project.tbl_project_services`, `resource.tbl_employees`, and `resource.tbl_onfloorrole`.

---

## API Changes
- **None**: Existing prerequisite update endpoint `PATCH /api/v1/projects/{projectId}/services/{serviceId}/prerequisite` remains backward compatible with automatic notification dispatching and workflow cancellation.

---

## Existing Functionality Preserved
- Service prerequisite checklist validation and status updates remain intact.
- Action Centre notification schema and cross-database synchronization remain intact.

---

# Changelog - WBS Edit Service Notifications to Assigned Engagement Manager

## Summary of Changes
Implemented automated Action Centre notification dispatching to the assigned **Engagement Manager** when services are edited from the WBS tab (using the "Edit Services" modal / API service management):
1. **Target Recipient**:
   - Dispatches directly to the assigned **Engagement Manager** of the project (`EngagementManagerRef`, `EngagementManagerId`, `Client.EngagementManagerId`, or `ProjectTeamMembers` holding the Engagement Manager/EM role).
2. **Notification Title & Action Classification**:
   - **Service Modified**: `The {Project_name} service is modify` (Type: `Service Modified`).
   - **Service Deleted**: `The {Project_name} service is deleted` (Type: `Service Deleted`).
   - **Service Added**: `The {Project_name} service is added` (Type: `Service Added`).
3. **Meaningful Content & History Logging**:
   - `HistoryJson` and notification details capture the exact service name, modification details (target quantity, resource distribution, unit price, or department), timestamp, and performer name.
   - Cross-database synchronization ensures immediate visibility in both local databases and the Action Centre notifications tab.

---

## Affected Files
- `apps/backend/Modules/ActionCentre/Services/IActionNotificationService.cs`:
  - Added method declarations: `NotifyServiceEditedAsync`, `NotifyServiceModifiedAsync`, `NotifyServiceDeletedAsync`, and `NotifyServiceAddedAsync`.
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - Implemented `NotifyServiceEditedAsync` (and convenience wrappers) to resolve the assigned Engagement Manager, construct the requested title format (`The {Project_name} service is modify or deleted or added`), format meaningful history details, and sync to the Action Centre.
  - Implemented `ResolveProjectEngagementManagersAsync` to reliably identify assigned Engagement Managers across project properties, client references, team members, and employee email/name fallbacks.
- `apps/backend/Modules/Projects/Services/ProjectAppService.cs`:
  - In `UpdateProjectServiceAsync`: triggers `NotifyServiceModifiedAsync` when an existing service is modified (quantity, resource distribution, pending modification, etc.).
  - In `ApplyServiceModificationAsync`: triggers `NotifyServiceModifiedAsync` when a pending service modification is approved and applied.
  - In `DeleteProjectServiceAsync`: triggers `NotifyServiceDeletedAsync` with the deleted service name and project context.
  - In `AddProjectServiceAsync`: triggers `NotifyServiceAddedAsync` with service name, department, and quantity details.
- `apps/backend/tests/PMS.IntegrationTests/ServicePrerequisiteNotificationTests.cs`:
  - Added 3 new integration tests:
    1. `Scenario7_ServiceModified_DispatchesNotificationTo_EngagementManager_WithTitle`: Verifies notification sent to assigned EM with title `The {project.Name} service is modify`.
    2. `Scenario8_ServiceDeleted_DispatchesNotificationTo_EngagementManager_WithTitle`: Verifies notification sent to assigned EM with title `The {project.Name} service is deleted`.
    3. `Scenario9_ServiceAdded_DispatchesNotificationTo_EngagementManager_WithTitle`: Verifies notification sent to assigned EM with title `The {project.Name} service is added`.

---

## Database Changes and Migrations
- **None**: Uses existing schemas in `action.tbl_action_notifications`, `project.tbl_projects`, `project.tbl_project_services`, and `resource.tbl_employees`.

---

## API Changes
- **None**: Endpoints `PUT /api/v1/projects/{projectId}/services/{serviceId}`, `DELETE /api/v1/projects/{projectId}/services/{serviceId}`, and `POST /api/v1/projects/{projectId}/services` remain backward compatible with automatic notification dispatching.

---

## Existing Functionality Preserved
- Service wise Prerequisite Tracking ready status and multi-level SLA escalation notifications remain intact.
- Project leadership and allocation reminder notifications remain intact.
- Soft-deletion and task rollup behaviors in `ProjectAppService` remain intact.
- Cross-database notification synchronization (`TrySyncNotificationsToOtherDatabase`) remains intact.

---

# Changelog - Customer Sub-Venture Edit `CK_client_contacts_exactly_one_owner` Check Constraint Fix

## Summary of Changes
Fixed PostgreSQL check constraint violation `23514: new row for relation "tbl_client_contacts" violates check constraint "CK_client_contacts_exactly_one_owner"` occurring when editing a customer sub-venture with existing contacts:
1. **Root Cause Analysis**:
   - In `ClientService.PersistContactsAsync`, when updating contacts for a customer or its sub-ventures, existing contact rows were soft-deleted (`DeletedAtUtc = now`).
   - EF Core ChangeTracker kept the soft-deleted contact rows tracked in memory. When `sv.Contacts` or `client.Contacts` navigation collections were subsequently repopulated with the updated contact set (`sv.Contacts = toAdd...`), EF Core relationship fixup determined that the old contacts had been unlinked from their parent sub-venture / client collection.
   - Because `SubVentureId` and `ClientId` on `ClientContactEntity` are nullable foreign keys, EF Core automatically set the foreign key property to `null` and flagged the row as `EntityState.Modified`.
   - When downstream services (such as `notificationService.NotifySubVentureEditedAsync` or `NotifyCustomerEditedAsync`) subsequently invoked `await db.SaveChangesAsync(ct)` within the same scoped request, EF Core attempted to update the soft-deleted contact with both `ClientId = NULL` and `SubVentureId = NULL`, violating PostgreSQL database constraint `CK_client_contacts_exactly_one_owner`.
2. **Resolution**:
   - In `ClientService.PersistContactsAsync`:
     - Updated soft deletion of existing contacts to direct property setting (`c.DeletedAtUtc = now; c.UpdatedAtUtc = now; c.UpdatedBy = userId;`) and immediately detached them (`db.Entry(c).State = EntityState.Detached;`) following `SaveChangesAsync`.
     - This prevents EF Core relationship fixup from tracking them as unlinked orphans or nullifying their foreign keys during subsequent collection reassignments.
     - Enhanced sub-venture lookup during contact mapping to match by both `input.Id` and case-insensitive name.
   - In `AppDbContext.cs`:
     - Guarded `case EntityState.Deleted:` soft-delete conversion to restore any foreign keys nullified by EF Core's relationship fixup (`prop.CurrentValue = prop.OriginalValue; prop.IsModified = false;`), ensuring any soft-deleted entity preserves its original relational integrity and check constraint compliance.
3. **Verification**:
   - Added integration test `Update_EditingSubVentureWithExistingContacts_DoesNotThrowCheckConstraintError` in `CustomerModuleTests.cs` verifying full lifecycle: customer created with sub-venture and contacts, sub-venture edited with updated details and contacts, verifying HTTP 200 OK without check constraint violations.
   - Verified that all existing customer tests and notification integration tests continue to pass.

---

## Affected Files
- `apps/backend/Infrastructure/Persistence/AppDbContext.cs`:
  - Added foreign key restoration for soft-deleted entities in `SaveChangesAsync`.
- `apps/backend/Modules/Customers/Services/ClientService.cs`:
  - In `PersistContactsAsync`: direct soft deletion and detaching of existing contacts prior to new collection assignment.
- `apps/backend/tests/PMS.IntegrationTests/CustomerModuleTests.cs`:
  - Added integration test `Update_EditingSubVentureWithExistingContacts_DoesNotThrowCheckConstraintError`.

---

## Database Changes and Migrations
- **None**: Database schema, check constraint `CK_client_contacts_exactly_one_owner`, and soft-delete definitions remain unchanged.

---

## API Changes
- **None**: Customer and sub-venture endpoints (`PUT /api/v1/clients/{id}`) remain identical in contract and behavior.

---

## Existing Functionality Preserved
- Customer and sub-venture CRUD operations.
- Customer and sub-venture edit notifications to assigned Engagement Manager and HOD.
- Contact persistence and primary SPOC resolution.

---

# Changelog - WBS and Project Creation Notification Dispatch to Engagement Manager, EM HOD, Sales Person/Manager, and PMO

## Summary of Changes
Implemented comprehensive Action Centre notification dispatching when a WBS or project is created/onboarded:
1. **Target Stakeholders**:
   - **Assigned Engagement Manager**: Project's assigned Engagement Manager (`EngagementManagerRef`, `EngagementManagerId`, `Client.EngagementManagerRef`, `Client.EngagementManagerId`, or `ProjectTeamMembers` with EM/Engagement role, with string fallback).
   - **HOD whose Sub-Department is `EM (Engagement Manager)`**: Active employees whose Sub-Department is `EM (Engagement Manager)` (`63bc0f54-4d35-4279-bb62-4daeff6ceeaa` or matching `EM` / `Engagement Manager`) AND whose On Floor Role is `Head Of Department` (`resource.tbl_onfloorrole` mapped via `DesignationId` or role definition `Head Of Department` / `-HOD`), strictly excluding Team Leaders.
   - **Sales Manager or Sales Person**: Project's assigned Sales Person (`SalesPersonRef`, `SalesPersonId`, `SalesPerson`), customer's assigned Sales Manager (`SalesManagerRef`, `SalesManagerId`, `SalesManager`), project team members with sales roles, or active employees with Sales Manager/Sales Person role / Sales sub-department.
   - **PMO**: Active employees whose Sub-Department is `PMO (Project Management Office)` (`fd84aa38-11ef-46af-ade7-241f2a2c08fd` or matching `PMO`), `PmoDepartment` contains PMO, Role / Designation is PMO, On Floor Role is PMO, or mapped to active Users with the `PMO` role.
2. **Notification Title & Formatting**:
   - Title: `{Project_name} is onboarded` (e.g. `Alpha App is onboarded`).
   - Category / Type: `WBS Created`.
   - Priority: `Low`, Status: `Created`.
   - Recipient deduplication: Ensures each stakeholder receives exactly one notification even if they match multiple criteria.
   - History details: Logged with `{Project_name} is onboarded` and creator name.
   - Cross-database synchronization: Synchronized to both local database instances for immediate visibility in the Action Centre notification tab.

---

## Affected Files
- `apps/backend/Modules/ActionCentre/Services/ActionNotificationService.cs`:
  - Updated `NotifyWbsCreatedAsync` to resolve all 4 required stakeholder groups (Assigned Engagement Manager, HOD with EM Sub-Department, Sales Manager/Person, and PMO) with recipient deduplication.
  - Implemented `ResolveProjectSalesPersonsAsync` to resolve sales personnel across project attributes, client attributes, team members, string name matching, and organization roles.
  - Updated notification title to `"{projectName} is onboarded"`.
- `apps/backend/tests/PMS.IntegrationTests/CustomerNotificationIntegrationTests.cs`:
  - Updated `WbsCreated_DispatchesNotification_ToEm_EmHod_SalesPerson_AndPmo_WithOnboardedTitle` to verify delivery to all 4 recipient roles (Assigned EM, EM HOD, Sales Person, PMO) and assert the title format `{proj.Name} is onboarded`.

---

## Database Changes and Migrations
- **None**: Uses existing schemas in `action.tbl_notifications`, `project.tbl_projects`, `customer.tbl_clients`, `resource.tbl_employees`, `resource.tbl_onfloorrole`, and `master.mst_sub_departments`.

---

## API Changes
- **None**: REST API endpoints for project creation (`POST /api/v1/projects`) and project renewal (`POST /api/v1/projects/{id}/renew`) remain unchanged.

---

## Existing Functionality Preserved
- Automated PM/SPM assignment reminder workflow (`StartProjectAllocationReminderWorkflowAsync`) remains intact.
- Strict exclusion of Team Leaders from HOD role resolution remains enforced.
- Cross-database notification synchronization (`TrySyncNotificationsToOtherDatabase`) remains intact.
- Project creation and renewal workflows in `ProjectAppService` remain intact.

