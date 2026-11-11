# Action Center Module Context

## 1. Overview & 4 Tabs
The Action Center provides centralized management of daily work, governance alerts, approvals, and notifications.

- Module UUID: `5a049953-8170-4ef4-a59e-43dc19e12de5` (`action-centre` / `action-center`)

The 4 Tabs:
1. **Bucket List (`bucket-list` - `db9aa2d2-1876-4d81-9ff6-6b55be19fb7a`):**
   - Individual task work list with timer start/pause/stop/complete.
   - Allows commenting, raising issues, and filtering by status/priority.
   - **RBAC Policy:** No difference between View and View+Manage. Any user permitted to view the Bucket List can work on their assigned tasks and run timers.
2. **Approvals (`approvals` - `a7bd6c40-4e96-4abb-be93-4ed4e4211978`):**
   - Central approval inbox for allocation requests and project extension requests.
   - **View-only:** "Actions" table column is hidden. Approve/Reject dialogs are inaccessible.
   - **View+Manage:** "Actions" table column is visible with Approve and Reject buttons. Mandatory approval comments required.
3. **Alerts (`alerts` / `action-alerts` - `5b828ae3-0b45-4a1c-a1cb-78b29e882cf3`):**
   - Operational alerts regarding overdue milestones, SLA breaches, and unallocated resources.
   - **View-only:** "Actions" table column is hidden. Review dialog is inaccessible.
   - **View+Manage:** "Actions" table column is visible with "Review" action button to submit governance updates.
4. **Notifications (`notifications` - `69e5bbc5-3f28-494e-a9c7-e4cff3c3dccc`):**
   - Notification feed. Currently strictly view-only, but configurable with both View and View+Manage for forward extensibility.

---

## 2. Controller & Endpoints
Located in `apps/backend/Modules/ActionCentre/Controllers/ActionCentreController.cs`:

- Top-level: `[RequireRbac("action-centre", RbacAccessType.View, "action-center")]`
- Bucket List:
  - `GET /api/v1/action-centre/bucket-list` -> `RequireRbac(ActionBucketList, RbacAccessType.View)`
  - `POST /api/v1/action-centre/bucket-list/{id}/start-timer` -> `RequireRbac(ActionBucketList, RbacAccessType.View)`
  - `POST /api/v1/action-centre/bucket-list/{id}/pause-timer` -> `RequireRbac(ActionBucketList, RbacAccessType.View)`
  - `POST /api/v1/action-centre/bucket-list/{id}/resume-timer` -> `RequireRbac(ActionBucketList, RbacAccessType.View)`
  - `POST /api/v1/action-centre/bucket-list/{id}/stop-timer` -> `RequireRbac(ActionBucketList, RbacAccessType.View)`
  - `POST /api/v1/action-centre/bucket-list/{id}/complete` -> `RequireRbac(ActionBucketList, RbacAccessType.View)`
- Approvals:
  - `GET /api/v1/action-centre/allocation-approvals` -> `RequireRbac(ActionApprovals, RbacAccessType.View)`
  - `POST /api/v1/action-centre/allocation-approvals/{id}/action` -> `RequireRbac(ActionApprovals, RbacAccessType.Manage)`
- Alerts:
  - `GET /api/v1/action-centre/alerts` -> `RequireRbac(ActionAlerts, RbacAccessType.View)`
  - `PUT /api/v1/action-centre/alerts/{id}/governance` -> `RequireRbac(ActionAlerts, RbacAccessType.Manage)`
- Notifications:
  - `GET /api/v1/action-centre/notifications` -> `RequireRbac(ActionNotifications, RbacAccessType.View)`
  - `PUT /api/v1/action-centre/notifications/{id}/read` -> `RequireRbac(ActionNotifications, RbacAccessType.View)`

