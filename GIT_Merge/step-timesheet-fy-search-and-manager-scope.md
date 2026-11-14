# Merge Context: Timesheet save, financial year, search scroll, and manager scope

- **Branch:** `uat_clean12`
- **Date:** 2026-11-14
- **Author:** Omkar Gaikwad / AI Pair Programming

---

## Purpose of Changes

1. **A timesheet line is saved once.** Saving a draft no longer inserts the same line twice. Submit keeps one line for the week. After submit, that line leaves My Timesheet and stays in Timesheet History. When the reporting manager requests a change, the employee gets an Action Centre notification and History shows Edit for that week only. Edit opens the week on My Timesheet with the saved rows.

2. **Timesheet review scrolls sideways.** The Logged Hours Breakdown no longer squeezes Monday through Sunday into overlapping columns. The wheel, shift-wheel, and the ‹ › buttons move Friday through Sunday and Total into view.

3. **Financial year filter.** The header year is 1 April–31 March. The list runs from FY 2016-17 through the next year. Employee Directory keeps a person only when the joining date itself falls in a selected year. Exit Summary uses the last working day. The year control is a fixed-width pill, so choosing one year does not move global search.

4. **Global search holds the page still.** While the search results are open, the page behind them does not scroll. The result list still scrolls. Esc or a click outside closes search and the page scrolls again.

5. **Holiday info icon.** The Total Holidays i icon on Settings → Holiday Calendar no longer draws its own tooltip on top of Chrome’s tooltip. The browser title remains: “Click any holiday to edit. Click any empty date to quickly add a new holiday.”

6. **Engagement Manager and Sales Manager scope.** An Engagement Manager sees only customers and projects where they are the Engagement Manager. A Sales Manager sees only customers where they are the Sales Manager, and projects where they are the sales person or that customer’s Sales Manager. Admin, PMO, and the other wide roles still see every record. Opening a project or customer outside that assignment returns nothing.

7. **Database dump.** `database/pms_uat.sql` was regenerated from the live `pms_uat_clean` database (PostgreSQL 16) with `pg_dump --no-owner --no-acl`. `\restrict` and `transaction_timeout` are not in the file.

---

## Files to bring across

### Backend
- `apps/backend/Infrastructure/Authorization/PortfolioAccessService.cs` (new)
- `apps/backend/Configuration/DependencyInjectionExtensions.cs`
- `apps/backend/Modules/Customers/Services/ClientService.cs`
- `apps/backend/Modules/Projects/Services/ProjectAppService.cs`
- `apps/backend/Modules/Timesheets/Services/TimesheetService.cs`

### Frontend
- `apps/frontend/src/components/global-search.tsx`
- `apps/frontend/src/lib/financial-year.tsx`
- `apps/frontend/src/modules/employees/pages/employee-directory-page.tsx`
- `apps/frontend/src/modules/projects/pages/projects-list-page.tsx`
- `apps/frontend/src/modules/settings/components/masters/leave-calendar-section.tsx`
- `apps/frontend/src/modules/timesheets/pages/timesheets-page.tsx`
- `apps/frontend/src/styles.css`

### Database and notes
- `database/pms_uat.sql`
- `database/trackerpro-uat.sql` (timesheet seed rows removed from the previous dump)
- `.cursor/rules/current-work.mdc`
- `GIT_Merge/step-timesheet-fy-search-and-manager-scope.md`
- `GIT_Merge/archive/step-backend-rbac-enforcement-and-leave-calendar-fix.md` (moved here from `GIT_Merge/`)

---

## Leave untouched

- Do not redesign `users` / `roles`.
- Do not commit `.env`.
- Do not hand-edit `apps/frontend/src/routeTree.gen.ts`.
- `Database__AutoMigrate` and `Database__Seed` stay false.
- Team calendar, Action Center, and global search results are not filtered by the financial-year calendar.
- Dashboard graphs still use only the latest selected year.
- Sales team members who are not Sales Managers still see every customer and project.
