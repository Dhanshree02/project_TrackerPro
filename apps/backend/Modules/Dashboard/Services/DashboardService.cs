using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Dashboard.DTOs;

namespace PMS.API.Modules.Dashboard.Services;

public sealed class DashboardService(AppDbContext db) : IDashboardService
{
    public async Task<TeamSummaryDto> GetTeamSummaryAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        var today = TodayInIst();
        var quarter = string.IsNullOrWhiteSpace(query.Quarter)
            ? FinancialQuarter.CurrentCode(today)
            : query.Quarter.Trim().ToUpperInvariant();
        var financialYear = query.FinancialYear ?? FinancialQuarter.CurrentFinancialYearStart(today);
        var months = FinancialQuarter.Months(quarter, financialYear);

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

        var points = months.Select(month =>
        {
            var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
            var onTeam = people.Where(p => IsOnTeamForMonth(p, exitByEmployee, monthEnd, today)).ToList();
            var total = onTeam.Count;
            var onsite = onTeam.Count(p => IsOnsite(p.WorkLocation));
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
        var quarter = string.IsNullOrWhiteSpace(query.Quarter)
            ? FinancialQuarter.CurrentCode(today)
            : query.Quarter.Trim().ToUpperInvariant();
        var financialYear = query.FinancialYear ?? FinancialQuarter.CurrentFinancialYearStart(today);
        var months = FinancialQuarter.Months(quarter, financialYear);

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

        // Offsite, Remote, and Hybrid services are ignored. A person is on the onsite
        // team only when they are assigned to a task under a service whose Location is Onsite.
        // Billable / Non-Billable is the choice saved on the project team member.
        var links = await db.Database.SqlQueryRaw<OnsiteServiceLink>(
            """
            SELECT a."EmployeeId",
                   m."Billability",
                   m."AllocationStartDate",
                   m."AllocationEndDate",
                   s."StartDate" AS "ServiceStart",
                   s."EndDate" AS "ServiceEnd",
                   p."StartDate" AS "ProjectStart",
                   p."EndDate" AS "ProjectEnd",
                   p."Name" AS "ProjectName"
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

        var exitByEmployee = exits
            .GroupBy(e => e.OriginalEmployeeId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(e => e.ExitedAtUtc).First());
        var peopleById = people.ToDictionary(p => p.Id);

        var points = months.Select(month =>
        {
            var monthStart = new DateOnly(month.Year, month.Month, 1);
            var monthEnd = FinancialQuarter.EndOfMonth(month.Year, month.Month);
            var covered = links
                .Where(link => CoversMonth(link, monthStart, monthEnd))
                .Where(link => peopleById.TryGetValue(link.EmployeeId, out var person)
                    && IsOnTeamForMonth(person, exitByEmployee, monthEnd, today))
                .GroupBy(link => link.EmployeeId)
                .ToList();

            var billable = 0;
            var projects = new SortedSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var personLinks in covered)
            {
                if (personLinks.Any(link => IsBillable(link.Billability)))
                {
                    billable++;
                    continue;
                }

                foreach (var link in personLinks)
                {
                    if (!string.IsNullOrWhiteSpace(link.ProjectName))
                        projects.Add(link.ProjectName.Trim());
                }
            }

            var total = covered.Count;
            var nonBillable = total - billable;
            return new OnsiteUtilizationMonthDto(
                month.Label,
                month.Year,
                total,
                billable,
                nonBillable,
                Percent(billable, total),
                Percent(nonBillable, total),
                projects.ToArray());
        }).ToList();

        return new OnsiteUtilizationDto(quarter, financialYear, points);
    }

    public async Task<RoleAllocationDto> GetRoleAllocationAsync(TeamSummaryQuery query, CancellationToken ct = default)
    {
        var today = TodayInIst();
        var quarter = string.IsNullOrWhiteSpace(query.Quarter)
            ? FinancialQuarter.CurrentCode(today)
            : query.Quarter.Trim().ToUpperInvariant();
        var financialYear = query.FinancialYear ?? FinancialQuarter.CurrentFinancialYearStart(today);
        var months = FinancialQuarter.Months(quarter, financialYear);

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

    private static bool IsOnsite(string? workLocation) =>
        string.Equals(workLocation?.Trim(), "Onsite", StringComparison.OrdinalIgnoreCase);

    private static bool IsBillable(string? billability) =>
        string.Equals(billability?.Trim(), "Billable", StringComparison.OrdinalIgnoreCase);

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
}
