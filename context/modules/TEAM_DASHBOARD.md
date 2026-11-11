# Team Dashboard Module Context

## 1. Overview & Rosters
The Team Dashboard provides visibility into workforce availability, scheduled shifts, leaves, and allocation statuses.

The module supports 3 distinct rosters:
1. **My Team (`scope=team`):**
   - Displays peers reporting to the same direct reporting manager.
   - For employees with 0 direct reports, this is the default and only relevant personal team roster.
   - **Strict Peer Protection:** Viewing peers is strictly read-only. Cells cannot be edited, shifts cannot be changed, and "Request Allocation" or "Schedule" dialogs are disabled for peers.
2. **My Reportees (`scope=reportees`):**
   - Displays direct subordinates for a reporting manager.
   - Reporting managers have full scheduling and shift management capability if granted Manage permission.
3. **All Employees (`scope=all`):**
   - Displays all active company employees with filters by department, on-floor role, allocation status, and allocation type.
   - Intended for HR, PMO, and Directors.

---

## 2. Endpoints & Controller Logic
Located in `apps/backend/Modules/MyTeam/Controllers/MyTeamController.cs`:

- `GET /api/v1/my-team/calendar?from={date}&to={date}&scope={team|reportees|all}`
  - Gated by `RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.View, ...)`.
  - Also verifies specific roster access (`MyTeamTab`, `MyReportees`, or `AllEmployees`).
- `GET /api/v1/my-team/on-floor-roles`
  - Returns master on-floor roles for calendar filter dropdowns.
- `PUT /api/v1/my-team/days`
  - Upserts daily shifts/attendance overrides. Gated by `RequireRbac(..., RbacAccessType.Manage)`.
- `PUT /api/v1/my-team/members/{id}/schedule`
  - Sets employee recurring weekly shift schedule. Gated by `RequireRbac(..., RbacAccessType.Manage)`.

---

## 3. Database Keys
- Submodule: `9854b7f3-8e7e-4ecb-864f-f2533ff295f9` (`team-dashboard`)
- Tab `My Team`: `9854b7f3-0001-4000-8000-000000000001` (Code: `my-team`, SortOrder: 5)
- Tab `My Reportees`: `b1e81c2a-34de-4dd4-b1f3-47387b8ed52b` (Code: `my-reportees`, SortOrder: 10)
- Tab `All Employees`: `552f9f86-4eb0-473a-8e39-9863cfefcea4` (Code: `all-employees`, SortOrder: 20)

