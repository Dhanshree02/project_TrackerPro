using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Dashboard.DTOs;

namespace PMS.API.Modules.Dashboard.Services;

public sealed class DashboardService(AppDbContext db) : IDashboardService
{
    public async Task<TeamSummaryDto> GetTeamSummaryAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        var today = TodayInIst();
        var (quarter, financialYear, months) = FinancialQuarter.Resolve(query.Period, query.Quarter, query.FinancialYear, today);

        // trackerpro_development stores these rows outside public:
        // resource.tbl_employees and resource.tbl_exited_employees.
        var people = await db.Database.SqlQueryRaw<PersonRow>(
            """
            SELECT "Id", "JoiningDate", "WorkLocation", "DeletedAtUtc"
            FROM resource.tbl_employees
            WHERE "JoiningDate" IS NOT NULL
            """).ToListAsync(ct);

        var exits = await db.Database.SqlQueryRaw<ExitRow>(
            """
            SELECT "OriginalEmployeeId", "LastWorkingDay", "ExitedAtUtc"
            FROM resource.tbl_exited_employees
            WHERE "DeletedAtUtc" IS NULL
            """).ToListAsync(ct);

        var exitByEmployee = exits
            .GroupBy(e => e.OriginalEmployeeId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(e => e.ExitedAtUtc).First());

        var locationChanges = await db.Database.SqlQueryRaw<ProfileFieldChange>(
            """
            SELECT "EmployeeId", "Action", "Details", "CreatedAtUtc"
            FROM resource.log_employee_activity
            WHERE "DeletedAtUtc" IS NULL
              AND "Action" = 'WorkLocationChanged'
            """).ToListAsync(ct);
        var locationByEmployee = locationChanges
            .GroupBy(change => change.EmployeeId)
            .ToDictionary(g => g.Key, g => (IReadOnlyList<ProfileFieldChange>)g.ToList());

        var points = months.Select(month =>
        {
            var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
            var onTeam = people.Where(p => IsOnTeamForMonth(p, exitByEmployee, monthEnd, today)).ToList();
            var total = onTeam.Count;
            var onsite = onTeam.Count(p =>
            {
                locationByEmployee.TryGetValue(p.Id, out var changes);
                var location = ValueForMonth(changes ?? [], p.WorkLocation, month.Year, month.Month);
                return IsOnsite(location);
            });
            var offsite = total - onsite;
            var onboarding = people.Count(p => p.JoiningDate.Year == month.Year && p.JoiningDate.Month == month.Month);
            var offboarding = exitByEmployee.Values.Count(e => CountsAsOffboarded(e, month.Year, month.Month, today));

            return new TeamSummaryMonthDto(
                month.Label,
                month.Year,
                total,
                onsite,
                offsite,
                Percent(onsite, total),
                Percent(offsite, total),
                onboarding,
                offboarding);
        }).ToList();

        return new TeamSummaryDto(quarter, financialYear, points);
    }

    public async Task<OnsiteUtilizationDto> GetOnsiteUtilizationAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        var today = TodayInIst();
        var (quarter, financialYear, months) = FinancialQuarter.Resolve(query.Period, query.Quarter, query.FinancialYear, today);

        // Onsite, billable, and non-billable come from the employee record.
        // Work location Onsite is the onsite team. Billable Status is Billable or Non-Billable.
        var people = await db.Database.SqlQueryRaw<OnsiteEmployeeRow>(
            """
            SELECT "Id", "JoiningDate", "WorkLocation", "BillableStatus", "DeletedAtUtc"
            FROM resource.tbl_employees
            WHERE "JoiningDate" IS NOT NULL
            """).ToListAsync(ct);

        var exits = await db.Database.SqlQueryRaw<ExitRow>(
            """
            SELECT "OriginalEmployeeId", "LastWorkingDay", "ExitedAtUtc"
            FROM resource.tbl_exited_employees
            WHERE "DeletedAtUtc" IS NULL
            """).ToListAsync(ct);

        var exitByEmployee = exits
            .GroupBy(e => e.OriginalEmployeeId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(e => e.ExitedAtUtc).First());

        var fieldChanges = await db.Database.SqlQueryRaw<ProfileFieldChange>(
            """
            SELECT "EmployeeId", "Action", "Details", "CreatedAtUtc"
            FROM resource.log_employee_activity
            WHERE "DeletedAtUtc" IS NULL
              AND "Action" IN ('WorkLocationChanged', 'BillableStatusChanged')
            """).ToListAsync(ct);
        var changesByEmployee = fieldChanges
            .GroupBy(change => change.EmployeeId)
            .ToDictionary(g => g.Key, g => (IReadOnlyList<ProfileFieldChange>)g.ToList());

        var points = months.Select(month =>
        {
            var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
            var onsite = people.Where(person =>
            {
                changesByEmployee.TryGetValue(person.Id, out var changes);
                var locationChanges = (changes ?? []).Where(change => change.Action == "WorkLocationChanged").ToList();
                var location = ValueForMonth(locationChanges, person.WorkLocation, month.Year, month.Month);
                if (!IsOnsite(location)) return false;
                return IsOnTeamForMonth(new PersonRow
                {
                    Id = person.Id,
                    JoiningDate = person.JoiningDate,
                    WorkLocation = location,
                    DeletedAtUtc = person.DeletedAtUtc,
                }, exitByEmployee, monthEnd, today);
            }).ToList();

            var total = onsite.Count;
            var billable = onsite.Count(person =>
            {
                changesByEmployee.TryGetValue(person.Id, out var changes);
                var statusChanges = (changes ?? []).Where(change => change.Action == "BillableStatusChanged").ToList();
                var status = ValueForMonth(statusChanges, person.BillableStatus, month.Year, month.Month);
                return IsBillable(status);
            });
            var nonBillable = total - billable;
            return new OnsiteUtilizationMonthDto(
                month.Label,
                month.Year,
                total,
                billable,
                nonBillable,
                Percent(billable, total),
                Percent(nonBillable, total),
                []);
        }).ToList();

        return new OnsiteUtilizationDto(quarter, financialYear, points);
    }

    public async Task<OnsiteProjectCountDto> GetOnsiteProjectCountsAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        var today = TodayInIst();
        var (quarter, financialYear, months) = FinancialQuarter.Resolve(query.Period, query.Quarter, query.FinancialYear, today);

        var people = await db.Database.SqlQueryRaw<PersonRow>(
            """
            SELECT "Id", "JoiningDate", "WorkLocation", "DeletedAtUtc"
            FROM resource.tbl_employees
            WHERE "JoiningDate" IS NOT NULL
            """).ToListAsync(ct);

        var exits = await db.Database.SqlQueryRaw<ExitRow>(
            """
            SELECT "OriginalEmployeeId", "LastWorkingDay", "ExitedAtUtc"
            FROM resource.tbl_exited_employees
            WHERE "DeletedAtUtc" IS NULL
            """).ToListAsync(ct);

        var links = await db.Database.SqlQueryRaw<OnsiteProjectLink>(
            """
            SELECT p."Id" AS "ProjectId",
                   p."Name" AS "ProjectName",
                   a."EmployeeId",
                   m."AllocationStartDate",
                   m."AllocationEndDate",
                   s."StartDate" AS "ServiceStart",
                   s."EndDate" AS "ServiceEnd",
                   p."StartDate" AS "ProjectStart",
                   p."EndDate" AS "ProjectEnd"
            FROM project.tbl_project_task_assignments AS a
            JOIN project.tbl_project_tasks AS t
              ON t."Id" = a."TaskId" AND t."DeletedAtUtc" IS NULL
            JOIN project.tbl_project_services AS s
              ON s."Id" = t."ProjectServiceId" AND s."DeletedAtUtc" IS NULL
            JOIN project.tbl_projects AS p
              ON p."Id" = s."ProjectId" AND p."DeletedAtUtc" IS NULL
            LEFT JOIN project.tbl_project_team_members AS m
              ON m."ProjectId" = p."Id"
             AND m."EmployeeId" = a."EmployeeId"
             AND m."DeletedAtUtc" IS NULL
            WHERE a."DeletedAtUtc" IS NULL
              AND a."IsActive" = TRUE
              AND lower(btrim(s."Location")) = 'onsite'
            """).ToListAsync(ct);

        var onsiteProjects = await db.Database.SqlQueryRaw<OnsiteProjectNameRow>(
            """
            SELECT DISTINCT p."Id" AS "ProjectId", p."Name" AS "ProjectName"
            FROM project.tbl_projects AS p
            JOIN project.tbl_project_services AS s
              ON s."ProjectId" = p."Id" AND s."DeletedAtUtc" IS NULL
            WHERE p."DeletedAtUtc" IS NULL
              AND lower(btrim(s."Location")) = 'onsite'
              AND p."Name" IS NOT NULL
              AND btrim(p."Name") <> ''
            """).ToListAsync(ct);

        var exitByEmployee = exits
            .GroupBy(e => e.OriginalEmployeeId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(e => e.ExitedAtUtc).First());
        var peopleById = people.ToDictionary(p => p.Id);

        var linksByProject = links.GroupBy(link => link.ProjectId).ToDictionary(g => g.Key, g => g.ToList());

        var rows = onsiteProjects
            .GroupBy(project => project.ProjectId)
            .Select(group =>
            {
                var name = group.Select(project => project.ProjectName?.Trim()).First(name => !string.IsNullOrWhiteSpace(name))!;
                linksByProject.TryGetValue(group.Key, out var projectLinks);
                var monthly = months.Select(month =>
                {
                    var monthStart = new DateOnly(month.Year, month.Month, 1);
                    var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
                    return DistinctOnsitePeople(projectLinks ?? [], peopleById, exitByEmployee, monthStart, monthEnd, today).Count;
                }).ToArray();
                var peak = monthly.Length == 0 ? 0 : monthly.Max();
                return new OnsiteProjectCountRowDto(name, peak, monthly);
            })
            .OrderBy(row => row.ProjectName, StringComparer.OrdinalIgnoreCase)
            .ToList();

        return new OnsiteProjectCountDto(
            quarter,
            financialYear,
            months.Select(month => new OnsiteProjectCountMonthDto(month.Label, month.Year)).ToList(),
            rows);
    }

    private static HashSet<Guid> DistinctOnsitePeople(
        IEnumerable<OnsiteProjectLink> links,
        IReadOnlyDictionary<Guid, PersonRow> peopleById,
        IReadOnlyDictionary<Guid, ExitRow> exits,
        DateOnly rangeStart,
        DateOnly rangeEnd,
        DateOnly today)
    {
        var people = new HashSet<Guid>();
        foreach (var link in links)
        {
            if (!peopleById.TryGetValue(link.EmployeeId, out var person)) continue;
            if (!IsOnTeamForMonth(person, exits, rangeEnd, today)) continue;
            if (!CoversMonth(ToServiceLink(link), rangeStart, rangeEnd)) continue;
            people.Add(link.EmployeeId);
        }

        return people;
    }

    private static OnsiteServiceLink ToServiceLink(OnsiteProjectLink link) => new()
    {
        EmployeeId = link.EmployeeId,
        AllocationStartDate = link.AllocationStartDate,
        AllocationEndDate = link.AllocationEndDate,
        ServiceStart = link.ServiceStart,
        ServiceEnd = link.ServiceEnd,
        ProjectStart = link.ProjectStart,
        ProjectEnd = link.ProjectEnd,
        ProjectName = link.ProjectName,
    };

    public async Task<RoleAllocationDto> GetRoleAllocationAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        var today = TodayInIst();
        var (quarter, financialYear, months) = FinancialQuarter.Resolve(query.Period, query.Quarter, query.FinancialYear, today);

        var people = await db.Database.SqlQueryRaw<PersonRow>(
            """
            SELECT "Id", "JoiningDate", "WorkLocation", "DeletedAtUtc"
            FROM resource.tbl_employees
            WHERE "JoiningDate" IS NOT NULL
            """).ToListAsync(ct);

        var exits = await db.Database.SqlQueryRaw<ExitRow>(
            """
            SELECT "OriginalEmployeeId", "LastWorkingDay", "ExitedAtUtc"
            FROM resource.tbl_exited_employees
            WHERE "DeletedAtUtc" IS NULL
            """).ToListAsync(ct);

        var links = await db.Database.SqlQueryRaw<RoleServiceLink>(
            """
            SELECT a."EmployeeId",
                   m."IsTeamLead",
                   m."MemberRole",
                   m."AllocationStartDate",
                   m."AllocationEndDate",
                   s."Location",
                   s."StartDate" AS "ServiceStart",
                   s."EndDate" AS "ServiceEnd",
                   p."StartDate" AS "ProjectStart",
                   p."EndDate" AS "ProjectEnd"
            FROM project.tbl_project_task_assignments AS a
            JOIN project.tbl_project_tasks AS t
              ON t."Id" = a."TaskId" AND t."DeletedAtUtc" IS NULL
            JOIN project.tbl_project_services AS s
              ON s."Id" = t."ProjectServiceId" AND s."DeletedAtUtc" IS NULL
            JOIN project.tbl_projects AS p
              ON p."Id" = s."ProjectId" AND p."DeletedAtUtc" IS NULL
            LEFT JOIN project.tbl_project_team_members AS m
              ON m."ProjectId" = p."Id"
             AND m."EmployeeId" = a."EmployeeId"
             AND m."DeletedAtUtc" IS NULL
            WHERE a."DeletedAtUtc" IS NULL
              AND a."IsActive" = TRUE
              AND lower(btrim(s."Location")) IN ('onsite', 'offsite')
            """).ToListAsync(ct);

        var exitByEmployee = exits
            .GroupBy(e => e.OriginalEmployeeId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(e => e.ExitedAtUtc).First());
        var peopleById = people.ToDictionary(p => p.Id);

        var points = months.Select(month =>
        {
            var monthStart = new DateOnly(month.Year, month.Month, 1);
            var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
            var onsiteTm = new HashSet<Guid>();
            var onsiteLeads = new HashSet<Guid>();
            var offsiteTm = new HashSet<Guid>();
            var offsiteLeads = new HashSet<Guid>();

            foreach (var link in links)
            {
                if (!peopleById.TryGetValue(link.EmployeeId, out var person)) continue;
                if (!IsOnTeamForMonth(person, exitByEmployee, monthEnd, today)) continue;
                if (!RoleCoversMonth(link, monthStart, monthEnd)) continue;
                if (IsProjectManagerRole(link.MemberRole)) continue;

                var onsite = string.Equals(link.Location?.Trim(), "Onsite", StringComparison.OrdinalIgnoreCase);
                var leads = link.IsTeamLead == true;
                if (onsite)
                {
                    if (leads) onsiteLeads.Add(link.EmployeeId);
                    else onsiteTm.Add(link.EmployeeId);
                }
                else
                {
                    if (leads) offsiteLeads.Add(link.EmployeeId);
                    else offsiteTm.Add(link.EmployeeId);
                }
            }

            onsiteTm.ExceptWith(onsiteLeads);
            offsiteTm.ExceptWith(offsiteLeads);

            return new RoleAllocationMonthDto(
                month.Label,
                month.Year,
                onsiteTm.Count,
                onsiteLeads.Count,
                offsiteTm.Count,
                offsiteLeads.Count,
                0);
        }).ToList();

        return new RoleAllocationDto(quarter, financialYear, points);
    }

    public async Task<OffsiteTeamUtilizationDto> GetOffsiteTeamUtilizationAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        var today = TodayInIst();
        var (quarter, financialYear, months) = FinancialQuarter.Resolve(query.Period, query.Quarter, query.FinancialYear, today);

        var people = await db.Database.SqlQueryRaw<OffsiteUtilEmployee>(
            """
            SELECT e."Id",
                   e."JoiningDate",
                   e."WorkLocation",
                   e."DeletedAtUtc",
                   e."SubDepartment"
            FROM resource.tbl_employees AS e
            WHERE e."JoiningDate" IS NOT NULL
            """).ToListAsync(ct);

        var exits = await db.Database.SqlQueryRaw<ExitRow>(
            """
            SELECT "OriginalEmployeeId", "LastWorkingDay", "ExitedAtUtc"
            FROM resource.tbl_exited_employees
            WHERE "DeletedAtUtc" IS NULL
            """).ToListAsync(ct);

        var workedRows = await db.Database.SqlQueryRaw<TimesheetWorkedDay>(
            """
            SELECT w."EmployeeId",
                   w."WeekStart",
                   d."DayIndex",
                   d."Hours"
            FROM timesheet.tbl_timesheet_entry_days AS d
            JOIN timesheet.tbl_timesheet_entries AS en
              ON en."Id" = d."TimesheetEntryId" AND en."DeletedAtUtc" IS NULL
            JOIN timesheet.tbl_timesheets AS w
              ON w."Id" = en."TimesheetWeekId" AND w."DeletedAtUtc" IS NULL
            WHERE d."DeletedAtUtc" IS NULL
              AND d."Hours" > 0
            """).ToListAsync(ct);

        var exitByEmployee = exits
            .GroupBy(e => e.OriginalEmployeeId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(e => e.ExitedAtUtc).First());

        var locationChanges = await db.Database.SqlQueryRaw<ProfileFieldChange>(
            """
            SELECT "EmployeeId", "Action", "Details", "CreatedAtUtc"
            FROM resource.log_employee_activity
            WHERE "DeletedAtUtc" IS NULL
              AND "Action" = 'WorkLocationChanged'
            """).ToListAsync(ct);
        var locationByEmployee = locationChanges
            .GroupBy(change => change.EmployeeId)
            .ToDictionary(g => g.Key, g => (IReadOnlyList<ProfileFieldChange>)g.ToList());

        var workedDates = new Dictionary<Guid, HashSet<DateOnly>>();
        foreach (var row in workedRows)
        {
            if (row.DayIndex is < 0 or > 6) continue;
            var date = row.WeekStart.AddDays(row.DayIndex);
            if (!workedDates.TryGetValue(row.EmployeeId, out var dates))
            {
                dates = [];
                workedDates[row.EmployeeId] = dates;
            }

            dates.Add(date);
        }

        var departmentNames = people
            .SelectMany(employee => SubDepartmentNames(employee.SubDepartment))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(name => name, StringComparer.OrdinalIgnoreCase)
            .ToList();

        var rows = departmentNames.Select(department =>
        {
            var strength = new int[months.Count];
            var utilization = new int[months.Count];
            for (var i = 0; i < months.Count; i++)
            {
                var month = months[i];
                var monthStart = new DateOnly(month.Year, month.Month, 1);
                var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
                var worked = 0;
                var calendar = 0;
                var count = 0;
                foreach (var employee in people)
                {
                    if (!SubDepartmentNames(employee.SubDepartment).Any(name => string.Equals(name, department, StringComparison.OrdinalIgnoreCase))) continue;
                    locationByEmployee.TryGetValue(employee.Id, out var changes);
                    var location = ValueForMonth(changes ?? [], employee.WorkLocation, month.Year, month.Month);
                    if (IsOnsite(location)) continue;
                    var person = new PersonRow
                    {
                        Id = employee.Id,
                        JoiningDate = employee.JoiningDate,
                        WorkLocation = location,
                        DeletedAtUtc = employee.DeletedAtUtc,
                    };
                    if (!IsOnTeamForMonth(person, exitByEmployee, monthEnd, today)) continue;

                    var calStart = employee.JoiningDate > monthStart ? employee.JoiningDate : monthStart;
                    if (calStart > monthEnd) continue;
                    var days = monthEnd.DayNumber - calStart.DayNumber + 1;
                    count++;
                    calendar += days;
                    if (workedDates.TryGetValue(employee.Id, out var dates))
                        worked += dates.Count(date => date >= calStart && date <= monthEnd);
                }

                strength[i] = count;
                utilization[i] = calendar == 0 ? 0 : (int)Math.Round(worked * 100d / calendar, MidpointRounding.AwayFromZero);
            }

            return new OffsiteTeamUtilizationRowDto(department, strength, utilization);
        }).Where(row => row.TeamStrength.Any(count => count > 0)).ToList();

        return new OffsiteTeamUtilizationDto(
            quarter,
            financialYear,
            months.Select(month => new OffsiteTeamUtilizationMonthDto(month.Label, month.Year)).ToList(),
            rows);
    }

    public async Task<ResignationCountDto> GetResignationCountsAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        var today = TodayInIst();
        var (quarter, financialYear, months) = FinancialQuarter.Resolve(query.Period, query.Quarter, query.FinancialYear, today);
        var periodStart = new DateOnly(months[0].Year, months[0].Month, 1);
        var periodEnd = FinancialQuarter.EndOfMonth(months[^1].Year, months[^1].Month);

        var people = await db.Database.SqlQueryRaw<ResignationEmployee>(
            """
            SELECT e."Id",
                   e."JoiningDate",
                   e."WorkLocation",
                   e."DeletedAtUtc",
                   e."SubDepartment",
                   e."BondStatus",
                   e."ExitType",
                   e."Role",
                   r."Name" AS "JobRoleName"
            FROM resource.tbl_employees AS e
            LEFT JOIN master.mst_roles AS r ON r."Id" = e."JobRoleId"
            WHERE e."JoiningDate" IS NOT NULL
            """).ToListAsync(ct);

        var exits = await db.Database.SqlQueryRaw<ResignationExitRow>(
            """
            SELECT "OriginalEmployeeId", "ExitType", "ResignationDate", "LastWorkingDay", "ExitedAtUtc"
            FROM resource.tbl_exited_employees
            WHERE "DeletedAtUtc" IS NULL
            """).ToListAsync(ct);

        var locationChanges = await db.Database.SqlQueryRaw<ProfileFieldChange>(
            """
            SELECT "EmployeeId", "Action", "Details", "CreatedAtUtc"
            FROM resource.log_employee_activity
            WHERE "DeletedAtUtc" IS NULL
              AND "Action" = 'WorkLocationChanged'
            """).ToListAsync(ct);

        var exitByEmployee = exits
            .GroupBy(row => row.OriginalEmployeeId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(row => row.ExitedAtUtc).First());
        var teamExits = exitByEmployee.ToDictionary(
            pair => pair.Key,
            pair => new ExitRow
            {
                OriginalEmployeeId = pair.Key,
                LastWorkingDay = pair.Value.LastWorkingDay,
                ExitedAtUtc = pair.Value.ExitedAtUtc,
            });
        var locationByEmployee = locationChanges
            .GroupBy(change => change.EmployeeId)
            .ToDictionary(g => g.Key, g => (IReadOnlyList<ProfileFieldChange>)g.ToList());

        var offsite = new Dictionary<Guid, ResignationSeat>();
        var onsite = new Dictionary<Guid, ResignationSeat>();
        foreach (var employee in people)
        {
            var bucket = ClassifyResignationRole(employee.JobRoleName, employee.Role);
            if (bucket == ResignationBucket.Excluded) continue;

            var person = new PersonRow
            {
                Id = employee.Id,
                JoiningDate = employee.JoiningDate,
                WorkLocation = employee.WorkLocation,
                DeletedAtUtc = employee.DeletedAtUtc,
            };
            var bondFree = IsBondFree(employee.BondStatus);
            exitByEmployee.TryGetValue(employee.Id, out var exit);
            var exitType = string.IsNullOrWhiteSpace(exit?.ExitType) ? employee.ExitType : exit.ExitType;
            var resignationDate = exit?.ResignationDate ?? exit?.LastWorkingDay;
            var resignedInPeriod = IsResignationExit(exitType)
                && resignationDate is DateOnly resigned
                && resigned >= periodStart
                && resigned <= periodEnd;

            foreach (var month in months)
            {
                var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
                if (!IsOnTeamForMonth(person, teamExits, monthEnd, today)) continue;

                locationByEmployee.TryGetValue(employee.Id, out var changes);
                var location = ValueForMonth(changes ?? [], employee.WorkLocation, month.Year, month.Month);
                var side = IsOnsite(location) ? onsite : offsite;
                if (!side.ContainsKey(employee.Id))
                {
                    side[employee.Id] = new ResignationSeat { Bucket = bucket, BondFree = bondFree };
                }

                if (resignedInPeriod
                    && resignationDate!.Value.Year == month.Year
                    && resignationDate.Value.Month == month.Month)
                {
                    side[employee.Id].OnPaper = true;
                }
            }
        }

        return new ResignationCountDto(
            quarter,
            financialYear,
            BuildResignationRows(offsite, includeProjectManagers: true),
            BuildResignationRows(onsite, includeProjectManagers: false));
    }

    public async Task<OffsiteCapacityDto> GetOffsiteCapacityAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        const int calendarDays = 21;
        var today = TodayInIst();
        var (quarter, financialYear, months) = FinancialQuarter.Resolve(query.Period, query.Quarter, query.FinancialYear, today);

        var people = await db.Database.SqlQueryRaw<OffsiteUtilEmployee>(
            """
            SELECT e."Id",
                   e."JoiningDate",
                   e."WorkLocation",
                   e."DeletedAtUtc",
                   e."SubDepartment"
            FROM resource.tbl_employees AS e
            WHERE e."JoiningDate" IS NOT NULL
            """).ToListAsync(ct);

        var exits = await db.Database.SqlQueryRaw<ExitRow>(
            """
            SELECT "OriginalEmployeeId", "LastWorkingDay", "ExitedAtUtc"
            FROM resource.tbl_exited_employees
            WHERE "DeletedAtUtc" IS NULL
            """).ToListAsync(ct);

        var locationChanges = await db.Database.SqlQueryRaw<ProfileFieldChange>(
            """
            SELECT "EmployeeId", "Action", "Details", "CreatedAtUtc"
            FROM resource.log_employee_activity
            WHERE "DeletedAtUtc" IS NULL
              AND "Action" = 'WorkLocationChanged'
            """).ToListAsync(ct);

        var exitByEmployee = exits
            .GroupBy(row => row.OriginalEmployeeId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(row => row.ExitedAtUtc).First());
        var locationByEmployee = locationChanges
            .GroupBy(change => change.EmployeeId)
            .ToDictionary(g => g.Key, g => (IReadOnlyList<ProfileFieldChange>)g.ToList());

        var departmentNames = people
            .SelectMany(employee => SubDepartmentNames(employee.SubDepartment))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        var rows = departmentNames.Select(department =>
        {
            var rule = ResolveCapacityRule(department);
            var tm = new int[months.Count];
            var effectiveDays = new int[months.Count];
            var capacity = new int?[months.Count];
            for (var i = 0; i < months.Count; i++)
            {
                var month = months[i];
                var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
                var peopleInDepartment = new HashSet<Guid>();
                foreach (var employee in people)
                {
                    if (!SubDepartmentNames(employee.SubDepartment).Any(name => string.Equals(name, department, StringComparison.OrdinalIgnoreCase))) continue;
                    locationByEmployee.TryGetValue(employee.Id, out var changes);
                    var location = ValueForMonth(changes ?? [], employee.WorkLocation, month.Year, month.Month);
                    if (IsOnsite(location)) continue;
                    var person = new PersonRow
                    {
                        Id = employee.Id,
                        JoiningDate = employee.JoiningDate,
                        WorkLocation = location,
                        DeletedAtUtc = employee.DeletedAtUtc,
                    };
                    if (!IsOnTeamForMonth(person, exitByEmployee, monthEnd, today)) continue;
                    peopleInDepartment.Add(employee.Id);
                }

                tm[i] = peopleInDepartment.Count;
                effectiveDays[i] = calendarDays * tm[i];
                capacity[i] = rule.Formula switch
                {
                    OffsiteCapacityFormula.DaysPerApp => (int)Math.Round(effectiveDays[i] / 7d, MidpointRounding.AwayFromZero),
                    OffsiteCapacityFormula.IpsPerDay => effectiveDays[i] * 10,
                    _ => null,
                };
            }

            return new OffsiteCapacityRowDto(department, rule.Effort, rule.Unit, tm, effectiveDays, capacity);
        }).Where(row => row.Tm.Any(count => count > 0))
          .OrderBy(row => CapacitySortRank(row.SubDepartment))
          .ThenBy(row => row.SubDepartment, StringComparer.OrdinalIgnoreCase)
          .ToList();

        return new OffsiteCapacityDto(
            quarter,
            financialYear,
            calendarDays,
            months.Select(month => new OffsiteCapacityMonthDto(month.Label, month.Year)).ToList(),
            rows);
    }

    /// <summary>
    /// A stored last working day is the exit date, not proof the person has already left.
    /// Until that date, they stay in Total, Onsite, and Offsite. Onsite is work location
    /// "Onsite"; every other location is offsite. There is no monthly location history.
    /// </summary>
    private static bool IsOnTeamForMonth(
        PersonRow person,
        IReadOnlyDictionary<Guid, ExitRow> exits,
        DateOnly monthEnd,
        DateOnly today)
    {
        if (person.JoiningDate > monthEnd) return false;

        if (exits.TryGetValue(person.Id, out var exit) && exit.LastWorkingDay is DateOnly left)
        {
            // Notice period: the exit has not happened yet, so they are still on the team.
            if (today < left) return true;
            // The exit date has been reached. They are out of any month that does not end before that day.
            return left > monthEnd;
        }

        if (person.DeletedAtUtc is not null)
        {
            var removed = ToIstDate(person.DeletedAtUtc.Value);
            return removed > monthEnd;
        }

        return true;
    }

    /// <summary>
    /// Offboarding is counted in the month of the last working day, and only once that day has arrived.
    /// </summary>
    private static bool CountsAsOffboarded(ExitRow exit, int year, int month, DateOnly today)
    {
        if (exit.LastWorkingDay is not DateOnly left) return false;
        return today >= left && left.Year == year && left.Month == month;
    }

    private static readonly string[] AllowedSubDepartments =
    [
        "Leading Sales & A/C Dept.",
        "Leading Delivery Dept.",
        "Leading Compliance & HR Dept.",
        "PMO (Project Management Office)",
        "EM (Engagement Manager)",
        "Service - Testing - AppSec",
        "Service - Testing - Mobile",
        "Service - Testing - Infra",
        "Services - Testing - DevSecOps",
        "Services - Testing - Red Team",
        "Services - Testing - Cloud & AI",
    ];

    private static IReadOnlyList<string> SubDepartmentNames(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return [];
        return value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(NormalizeSubDepartment)
            .Where(name => AllowedSubDepartments.Any(allowed => allowed.Equals(name, StringComparison.OrdinalIgnoreCase)))
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToArray();
    }

    private static string NormalizeSubDepartment(string name)
    {
        if (name.Equals("EM (Engagement Manager)", StringComparison.OrdinalIgnoreCase)
            || name.Equals("Engagement Manager", StringComparison.OrdinalIgnoreCase))
            return "EM (Engagement Manager)";
        return name;
    }

    private static bool IsOnsite(string? workLocation) =>
        string.Equals(workLocation?.Trim(), "Onsite", StringComparison.OrdinalIgnoreCase);

    private static bool IsBillable(string? billability) =>
        string.Equals(billability?.Trim(), "Billable", StringComparison.OrdinalIgnoreCase);

    /// <summary>
    /// A profile change applies from the month it was saved through later months.
    /// Months before that change keep the previous value.
    /// </summary>
    private static string? ValueForMonth(
        IReadOnlyList<ProfileFieldChange> changes,
        string? current,
        int year,
        int month)
    {
        if (changes.Count == 0) return current;
        var ordered = changes.OrderBy(change => change.CreatedAtUtc).ToList();
        ProfileFieldChange? applied = null;
        foreach (var change in ordered)
        {
            var when = ToIstDate(change.CreatedAtUtc);
            if (when.Year < year || (when.Year == year && when.Month <= month))
                applied = change;
        }

        if (applied is null)
            return ParseChange(ordered[0].Details).From;

        return ParseChange(applied.Details).To ?? current;
    }

    private static (string? From, string? To) ParseChange(string? details)
    {
        if (string.IsNullOrEmpty(details)) return (null, null);
        const string separator = " -> ";
        var index = details.IndexOf(separator, StringComparison.Ordinal);
        if (index < 0) return (null, null);
        var from = details[..index];
        var to = details[(index + separator.Length)..];
        return (from.Length == 0 ? null : from, to.Length == 0 ? null : to);
    }

    /// <summary>
    /// The person counts in a month the onsite service is running. Their team allocation
    /// narrows that window only when it overlaps the service. An allocation that sits
    /// outside the service dates still counts for the service months, because the task
    /// assignment is what attaches them to the service.
    /// </summary>
    private static bool CoversMonth(OnsiteServiceLink link, DateOnly monthStart, DateOnly monthEnd)
    {
        var start = link.ServiceStart ?? link.ProjectStart;
        var end = link.ServiceEnd ?? link.ProjectEnd;

        if (link.AllocationStartDate is DateOnly allocationStart
            && link.AllocationEndDate is DateOnly allocationEnd
            && start is DateOnly serviceStart
            && end is DateOnly serviceEnd
            && allocationStart <= serviceEnd
            && allocationEnd >= serviceStart)
        {
            if (allocationStart > start) start = allocationStart;
            if (allocationEnd < end) end = allocationEnd;
        }

        if (start is null || end is null || start > end) return false;
        return start <= monthEnd && end >= monthStart;
    }

    private static bool RoleCoversMonth(RoleServiceLink link, DateOnly monthStart, DateOnly monthEnd)
    {
        var start = link.ServiceStart ?? link.ProjectStart;
        var end = link.ServiceEnd ?? link.ProjectEnd;
        if (link.AllocationStartDate is DateOnly allocationStart
            && link.AllocationEndDate is DateOnly allocationEnd
            && start is DateOnly serviceStart
            && end is DateOnly serviceEnd
            && allocationStart <= serviceEnd
            && allocationEnd >= serviceStart)
        {
            if (allocationStart > start) start = allocationStart;
            if (allocationEnd < end) end = allocationEnd;
        }

        if (start is null || end is null || start > end) return false;
        return start <= monthEnd && end >= monthStart;
    }

    private static bool IsProjectManagerRole(string? memberRole) =>
        string.Equals(memberRole, "ProjectManager", StringComparison.OrdinalIgnoreCase)
        || string.Equals(memberRole, "SeniorProjectManager", StringComparison.OrdinalIgnoreCase);

    private static int Percent(int part, int total) =>
        total == 0 ? 0 : (int)Math.Round(part * 100d / total, MidpointRounding.AwayFromZero);

    private static DateOnly TodayInIst() => ToIstDate(DateTime.UtcNow);

    private static DateOnly ToIstDate(DateTime value)
    {
        var utc = value.Kind switch
        {
            DateTimeKind.Utc => value,
            DateTimeKind.Local => value.ToUniversalTime(),
            _ => DateTime.SpecifyKind(value, DateTimeKind.Utc),
        };

        TimeZoneInfo tz;
        try
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch (TimeZoneNotFoundException)
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }

        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(utc, tz));
    }

    private sealed class ProfileFieldChange
    {
        public Guid EmployeeId { get; set; }
        public string? Action { get; set; }
        public string? Details { get; set; }
        public DateTime CreatedAtUtc { get; set; }
    }

    private sealed class OnsiteEmployeeRow
    {
        public Guid Id { get; set; }
        public DateOnly JoiningDate { get; set; }
        public string? WorkLocation { get; set; }
        public string? BillableStatus { get; set; }
        public DateTime? DeletedAtUtc { get; set; }
    }

    private sealed class PersonRow
    {
        public Guid Id { get; set; }
        public DateOnly JoiningDate { get; set; }
        public string? WorkLocation { get; set; }
        public DateTime? DeletedAtUtc { get; set; }
    }

    private sealed class ExitRow
    {
        public Guid OriginalEmployeeId { get; set; }
        public DateOnly? LastWorkingDay { get; set; }
        public DateTime ExitedAtUtc { get; set; }
    }

    private sealed class OnsiteServiceLink
    {
        public Guid EmployeeId { get; set; }
        public string? Billability { get; set; }
        public DateOnly? AllocationStartDate { get; set; }
        public DateOnly? AllocationEndDate { get; set; }
        public DateOnly? ServiceStart { get; set; }
        public DateOnly? ServiceEnd { get; set; }
        public DateOnly? ProjectStart { get; set; }
        public DateOnly? ProjectEnd { get; set; }
        public string? ProjectName { get; set; }
    }

    private sealed class OnsiteProjectNameRow
    {
        public Guid ProjectId { get; set; }
        public string? ProjectName { get; set; }
    }

    private sealed class OnsiteProjectLink
    {
        public Guid ProjectId { get; set; }
        public string? ProjectName { get; set; }
        public Guid EmployeeId { get; set; }
        public DateOnly? AllocationStartDate { get; set; }
        public DateOnly? AllocationEndDate { get; set; }
        public DateOnly? ServiceStart { get; set; }
        public DateOnly? ServiceEnd { get; set; }
        public DateOnly? ProjectStart { get; set; }
        public DateOnly? ProjectEnd { get; set; }
    }

    private sealed class OffsiteUtilEmployee
    {
        public Guid Id { get; set; }
        public DateOnly JoiningDate { get; set; }
        public string? WorkLocation { get; set; }
        public DateTime? DeletedAtUtc { get; set; }
        public string? SubDepartment { get; set; }
    }

    private sealed class TimesheetWorkedDay
    {
        public Guid EmployeeId { get; set; }
        public DateOnly WeekStart { get; set; }
        public int DayIndex { get; set; }
        public decimal Hours { get; set; }
    }

    private sealed class RoleServiceLink
    {
        public Guid EmployeeId { get; set; }
        public bool? IsTeamLead { get; set; }
        public string? MemberRole { get; set; }
        public DateOnly? AllocationStartDate { get; set; }
        public DateOnly? AllocationEndDate { get; set; }
        public string? Location { get; set; }
        public DateOnly? ServiceStart { get; set; }
        public DateOnly? ServiceEnd { get; set; }
        public DateOnly? ProjectStart { get; set; }
        public DateOnly? ProjectEnd { get; set; }
    }

    private static List<ResignationCountRowDto> BuildResignationRows(
        IReadOnlyDictionary<Guid, ResignationSeat> people,
        bool includeProjectManagers)
    {
        ResignationCountRowDto Row(string role, Func<ResignationSeat, bool> match)
        {
            var matched = people.Values.Where(match).ToList();
            return new ResignationCountRowDto(
                role,
                matched.Count,
                matched.Count(seat => seat.BondFree),
                matched.Count(seat => seat.OnPaper));
        }

        var rows = new List<ResignationCountRowDto>
        {
            Row("Total Team", _ => true),
            Row(includeProjectManagers ? "Offsite - TM" : "Onsite TM", seat => seat.Bucket == ResignationBucket.Tm),
            Row(includeProjectManagers ? "Offsite - Leads" : "Onsite Leads", seat => seat.Bucket == ResignationBucket.Leads),
        };
        if (includeProjectManagers)
            rows.Add(Row("Offsite - PM", seat => seat.Bucket == ResignationBucket.Pm));
        return rows;
    }

    /// <summary>
    /// On Floor Role names come from master.mst_roles. Junior leads are left out.
    /// </summary>
    private static ResignationBucket ClassifyResignationRole(string? jobRoleName, string? legacyRole)
    {
        var role = string.IsNullOrWhiteSpace(jobRoleName) ? legacyRole?.Trim() ?? "" : jobRoleName.Trim();
        if (IsJuniorLeadRole(role)) return ResignationBucket.Excluded;
        if (IsTeamMemberRole(role)) return ResignationBucket.Tm;
        if (IsTeamLeadRole(role)) return ResignationBucket.Leads;
        if (IsProjectManagerFloorRole(role)) return ResignationBucket.Pm;
        return ResignationBucket.Other;
    }

    private static bool IsTeamMemberRole(string role) =>
        role.Contains("Team Member", StringComparison.OrdinalIgnoreCase);

    private static bool IsTeamLeadRole(string role) =>
        !IsJuniorLeadRole(role)
        && (role.Contains("Team Leader", StringComparison.OrdinalIgnoreCase)
            || role.Contains("Team Lead", StringComparison.OrdinalIgnoreCase));

    private static bool IsJuniorLeadRole(string role)
    {
        var name = role.ToLowerInvariant();
        return name.Contains("jr") && name.Contains("lead");
    }

    private static bool IsProjectManagerFloorRole(string role) =>
        role.Equals("Manager (Mng.)", StringComparison.OrdinalIgnoreCase)
        || role.Equals("Sr. Manager (Sr.Mng.)", StringComparison.OrdinalIgnoreCase)
        || role.Equals("Project Manager", StringComparison.OrdinalIgnoreCase)
        || role.Equals("Senior Project Manager", StringComparison.OrdinalIgnoreCase);

    private static (OffsiteCapacityFormula Formula, string? Effort, string? Unit) ResolveCapacityRule(string subDepartment)
    {
        if (HasNameToken(subDepartment, "Infra"))
            return (OffsiteCapacityFormula.IpsPerDay, "10 IPs per day", "ips");
        return (OffsiteCapacityFormula.DaysPerApp, "7 days per app", "apps");
    }

    private static int CapacitySortRank(string subDepartment)
    {
        if (HasNameToken(subDepartment, "AppSec")) return 0;
        if (HasNameToken(subDepartment, "Mobile")) return 1;
        if (HasNameToken(subDepartment, "Infra")) return 2;
        return 3;
    }

    private static bool HasNameToken(string name, string token) =>
        name.Split([' ', '-', '/', ',', '(', ')'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Any(part => part.Equals(token, StringComparison.OrdinalIgnoreCase));

    private enum OffsiteCapacityFormula
    {
        None,
        DaysPerApp,
        IpsPerDay,
    }

    private static bool IsBondFree(string? bondStatus) =>
        string.Equals(bondStatus?.Trim(), "No", StringComparison.OrdinalIgnoreCase);

    private static bool IsResignationExit(string? exitType)
    {
        var value = exitType?.Trim();
        return value is not null
            && (value.Equals("Resign", StringComparison.OrdinalIgnoreCase)
                || value.Equals("Resignation", StringComparison.OrdinalIgnoreCase)
                || value.Equals("Resigned", StringComparison.OrdinalIgnoreCase));
    }

    private enum ResignationBucket
    {
        Excluded,
        Tm,
        Leads,
        Pm,
        Other,
    }

    private sealed class ResignationSeat
    {
        public ResignationBucket Bucket { get; set; }
        public bool BondFree { get; set; }
        public bool OnPaper { get; set; }
    }

    private sealed class ResignationEmployee
    {
        public Guid Id { get; set; }
        public DateOnly JoiningDate { get; set; }
        public string? WorkLocation { get; set; }
        public DateTime? DeletedAtUtc { get; set; }
        public string? SubDepartment { get; set; }
        public string? BondStatus { get; set; }
        public string? ExitType { get; set; }
        public string? Role { get; set; }
        public string? JobRoleName { get; set; }
    }

    private sealed class ResignationExitRow
    {
        public Guid OriginalEmployeeId { get; set; }
        public string? ExitType { get; set; }
        public DateOnly? ResignationDate { get; set; }
        public DateOnly? LastWorkingDay { get; set; }
        public DateTime ExitedAtUtc { get; set; }
    }
}
