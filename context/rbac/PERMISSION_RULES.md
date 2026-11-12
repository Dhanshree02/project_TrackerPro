# RBAC Permission Rules & Constraints

## 1. Matrix Row Constraints in Roles & Permissions (`roles-permissions-page.tsx`)

Certain rows in the configuration matrix have strict business constraints regarding whether an admin can select "Only View", "View + Manage", or if the row is restricted.

### 1. View-Only Rows (`isViewOnlyRow`)
The following items **only** permit "Only view" selection in the UI (the "View + Manage" radio button is disabled):
- **Team Dashboard -> My Team** (`row.kind === "tab" && pName === "Team Dashboard" && row.name === "My Team"`): Strictly peer protection. Peers can never edit or manage another peer's schedule, shift, or leave.
- **Resources -> Exit Summary** (`row.kind === "submodule" && row.name === "Exit Summary"`): Historical termination records.
- **Employee Directory -> Employee Detail Tabs** (`row.kind === "tab" && pName === "Employee Detail"`): Personal info, organization details, bonds, education, activity logs.
- **Projects -> Health -> Alerts** (`pName === "Health" && row.name === "Alerts"`): View-only monitoring.
- **Projects -> Health -> Escalations** (`pName === "Health" && row.name === "Escalations"`): View-only monitoring.

### 2. View + Manage Only Rows (`isViewManageOnlyRow`)
The following items **only** permit "View + Manage" selection:
- **My Team -> Timesheets** (Submodule `timesheets`): Timesheet operations require creation/submission rights.
- **Timesheets Tabs** (`my-timesheet`, `timesheet-history`, `timesheet-approval`).

---

## 2. Action Center RBAC Enforcement
Enforced across `ActionCentreController.cs` and `action-centre-page.tsx`:

| Tab | View Permission | View + Manage Permission |
|---|---|---|
| **Bucket List** | Full task timer execution, status changing, commenting, and issue creation. No functional difference between View and Manage. | Full task timer execution, status changing, commenting, and issue creation. |
| **Approvals** | Read-only list of allocation & extension requests. The entire **"Actions" table column is hidden**, and modal action buttons (Approve / Reject) are omitted. | Full access: "Actions" column visible, Approve & Reject action dialogs enabled. |
| **Alerts** | Read-only alert listing. The entire **"Actions" table column is hidden**, and the Review alert dialog action is omitted. | Full access: "Actions" column visible, Review & Governance update actions enabled. |
| **Notifications** | View-only notification feed. Both View and View+Manage are kept selectable in Roles & Permissions for forward compatibility. | View-only notification feed. |

---

## 3. Team Dashboard Peer Protection Rules
- **My Team Tab (`scope=team`):**
  - Shows peers reporting to the same direct reporting manager.
  - If the logged-in user is an employee with no reportees, this is their primary team view.
  - **Zero peer mutation**: Employees cannot change peers' shift timings, override attendance, or request allocations on their behalf.
  - Backend calendar endpoint `GET /api/v1/my-team/calendar?scope=team` checks `RbacCatalogCodes.MyTeamTab` or `RbacCatalogCodes.TeamDashboard`.
- **My Reportees Tab (`scope=reportees`):**
  - Shows direct subordinates for reporting managers.
  - Managers can assign shifts, approve leave, and request pool allocations.
- **All Employees Tab (`scope=all`):**
  - Company-wide roster for HR, PMO, and Executive roles.

---

## 4. Default Baseline Locking & Reset
- **Schema Columns in `auth.tbl_role_permissions`:**
  - `DefaultCanView` (`smallint NOT NULL DEFAULT 0`): The locked baseline view access.
  - `DefaultCanManage` (`smallint NOT NULL DEFAULT 0`): The locked baseline manage access.
  - Check constraints ensure `DefaultCanManage <= DefaultCanView`.
- **Seeded Baseline (1,512 rows across 28 non-admin roles x 54 items):**
  - Executed via `scripts/seed_rbac_defaults.py`.
  - Permanently preserves original baseline configuration even if customized by administrators.
- **Reset to Baseline API & UI:**
  - `POST /api/v1/roles/{id}/permissions/reset-default`: Restores `CanView = DefaultCanView` and `CanManage = DefaultCanManage`.
  - UI Button "Reset to Baseline" in Roles & Permissions header triggers this reset with instant cache invalidation.


