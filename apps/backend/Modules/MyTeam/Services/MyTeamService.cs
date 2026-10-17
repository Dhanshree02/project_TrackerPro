using FluentValidation;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.MyTeam.DTOs;
using PMS.API.Modules.MyTeam.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.MyTeam.Services;

public sealed class MyTeamService(AppDbContext db, ICurrentUserService currentUser) : IMyTeamService
{
    private static readonly short[] DefaultWorkingDays = [1, 2, 3, 4, 5];

    public async Task<TeamCalendarDto> GetCalendarAsync(
        DateOnly from,
        DateOnly to,
        bool allEmployees = false,
        CancellationToken ct = default)
    {
        EnsureRange(from, to);
        var caller = await CallerEmployeeAsync(ct);
        if (caller is null)
        {
            return new TeamCalendarDto([], [], []);
        }

        var members = await TeamQuery(caller.Id, allEmployees)
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Include(e => e.ReportingManager)
            .Include(e => e.JobRole)
            .OrderBy(e => e.FirstName)
            .ThenBy(e => e.LastName)
            .ToListAsync(ct);

        if (members.Count == 0)
        {
            return new TeamCalendarDto([], [], []);
        }

        var today = TodayInIst();
        var ids = members.Select(m => m.Id).ToList();
        var entries = await db.TeamDayEntries
            .Where(e => ids.Contains(e.EmployeeId) && ((e.WorkDate >= from && e.WorkDate <= to) || e.WorkDate == today))
            .OrderBy(e => e.WorkDate)
            .ToListAsync(ct);
        var schedules = await db.TeamMemberSchedules
            .Where(s => ids.Contains(s.EmployeeId))
            .ToListAsync(ct);
        var holidays = await db.TeamMemberHolidays
            .Where(h => ids.Contains(h.EmployeeId))
            .OrderBy(h => h.HolidayDate)
            .ToListAsync(ct);

        var minAllocEnd = from < today ? from : today;
        var teamAllocations = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Project)
            .Where(m => ids.Contains(m.EmployeeId)
                && m.Project != null
                && m.Project.DeletedAtUtc == null
                && m.AllocationEndDate >= minAllocEnd)
            .ToListAsync(ct);

        var allocationsByEmployee = teamAllocations
            .GroupBy(m => m.EmployeeId)
            .ToDictionary(
                g => g.Key,
                g => g
                    .OrderBy(m => m.MemberRole is "ProjectTeam" or "ShadowTeam" ? 0 : 1)
                    .ThenBy(m => m.AllocationStartDate <= today ? 0 : 1)
                    .ThenByDescending(m => m.AllocationEndDate)
                    .ThenByDescending(m => m.CreatedAtUtc)
                    .ToList());

        var todayAttendanceByEmp = entries
            .Where(e => e.WorkDate == today)
            .GroupBy(e => e.EmployeeId)
            .ToDictionary(g => g.Key, g => g.First().Attendance);

        var scheduleByEmployee = schedules.ToDictionary(s => s.EmployeeId);
        var holidaysByEmployee = holidays.GroupBy(h => h.EmployeeId)
            .ToDictionary(g => g.Key, g => g.ToList());

        var rangeEntries = entries
            .Where(e => e.WorkDate >= from && e.WorkDate <= to)
            .Select(e => new TeamDayEntryDto(e.EmployeeId, e.WorkDate, e.Attendance, e.Shift))
            .ToList();

        return new TeamCalendarDto(
            members.Select(m => MapMember(
                m,
                m.ReportingManagerId == caller.Id,
                today,
                todayAttendanceByEmp.GetValueOrDefault(m.Id),
                allocationsByEmployee.GetValueOrDefault(m.Id))).ToList(),
            rangeEntries,
            members.Select(m => MapSchedule(
                m.Id,
                scheduleByEmployee.GetValueOrDefault(m.Id),
                holidaysByEmployee.GetValueOrDefault(m.Id))).ToList());
    }

    public async Task UpsertDaysAsync(UpsertTeamDaysRequest request, CancellationToken ct = default)
    {
        var employee = await RequireTeamMemberAsync(request.EmployeeId, ct);
        var dates = request.Dates.Distinct().ToList();
        var today = TodayInIst();
        if (dates.Any(d => d < today))
        {
            throw new ValidationException([new ValidationFailure("dates", "Past dates cannot be changed.")]);
        }

        var holidayDates = await db.TeamMemberHolidays
            .Where(h => h.EmployeeId == employee.Id && dates.Contains(h.HolidayDate))
            .Select(h => h.HolidayDate)
            .ToListAsync(ct);
        if (holidayDates.Count > 0)
        {
            throw new ValidationException([new ValidationFailure("dates", "Holiday dates cannot be changed.")]);
        }

        var attendance = NormalizeAttendance(request.Attendance);
        var shift = string.IsNullOrWhiteSpace(request.Shift) ? null : request.Shift.Trim();
        var setAttendance = !string.IsNullOrWhiteSpace(request.Attendance);
        var setShift = shift is not null;

        var existing = await db.TeamDayEntries
            .Where(e => e.EmployeeId == employee.Id && dates.Contains(e.WorkDate))
            .ToListAsync(ct);
        var byDate = existing.ToDictionary(e => e.WorkDate);

        foreach (var date in dates)
        {
            byDate.TryGetValue(date, out var row);
            var nextAttendance = setAttendance ? attendance : row?.Attendance;
            var nextShift = setShift ? shift : row?.Shift;

            // When an employee is on leave, they have no shift data
            if (string.Equals(nextAttendance, "leave", StringComparison.OrdinalIgnoreCase))
            {
                nextShift = null;
            }

            if (nextAttendance is null && nextShift is null)
            {
                if (row is not null) db.TeamDayEntries.Remove(row);
                continue;
            }

            if (row is null)
            {
                db.TeamDayEntries.Add(new TeamDayEntry
                {
                    EmployeeId = employee.Id,
                    WorkDate = date,
                    Attendance = nextAttendance,
                    Shift = nextShift,
                });
                continue;
            }

            row.Attendance = nextAttendance;
            row.Shift = nextShift;
        }

        await db.SaveChangesAsync(ct);
    }

    public async Task<IReadOnlyList<string>> GetOnFloorRoleNamesAsync(CancellationToken ct = default)
    {
        var names = await db.JobRoles
            .AsNoTracking()
            .Where(r => r.IsActive && r.DeletedAtUtc == null)
            .Select(r => r.Name)
            .ToListAsync(ct);

        return names
            .Where(n => !string.IsNullOrWhiteSpace(n))
            .Select(n => n.Trim())
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(n => n, StringComparer.OrdinalIgnoreCase)
            .ToList();
    }

    public async Task SaveScheduleAsync(Guid employeeId, SaveTeamScheduleRequest request, CancellationToken ct = default)
    {
        var employee = await RequireTeamMemberAsync(employeeId, ct);
        var workingDays = request.WorkingDays.Distinct().OrderBy(d => d).ToArray();
        var notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim();

        var schedule = await db.TeamMemberSchedules
            .FirstOrDefaultAsync(s => s.EmployeeId == employee.Id, ct);
        if (schedule is null)
        {
            schedule = new TeamMemberSchedule
            {
                EmployeeId = employee.Id,
                WorkingDays = workingDays,
                Notes = notes,
            };
            db.TeamMemberSchedules.Add(schedule);
        }
        else
        {
            schedule.WorkingDays = workingDays;
            schedule.Notes = notes;
        }

        var existingHolidays = await db.TeamMemberHolidays
            .Where(h => h.EmployeeId == employee.Id)
            .ToListAsync(ct);
        var incoming = request.Holidays
            .GroupBy(h => h.Date)
            .Select(g => g.First())
            .ToList();
        foreach (var row in existingHolidays)
        {
            var match = incoming.FirstOrDefault(h => h.Date == row.HolidayDate);
            if (match is null)
            {
                db.TeamMemberHolidays.Remove(row);
                continue;
            }

            row.Name = match.Name.Trim();
            row.Comment = string.IsNullOrWhiteSpace(match.Comment) ? null : match.Comment.Trim();
        }

        foreach (var holiday in incoming.Where(h => existingHolidays.All(row => row.HolidayDate != h.Date)))
        {
            db.TeamMemberHolidays.Add(new TeamMemberHoliday
            {
                EmployeeId = employee.Id,
                HolidayDate = holiday.Date,
                Name = holiday.Name.Trim(),
                Comment = string.IsNullOrWhiteSpace(holiday.Comment) ? null : holiday.Comment.Trim(),
            });
        }

        var dayEntries = await db.TeamDayEntries
            .Where(e => e.EmployeeId == employee.Id)
            .ToListAsync(ct);
        var working = workingDays.ToHashSet();
        foreach (var entry in dayEntries)
        {
            if (!working.Contains((short)entry.WorkDate.DayOfWeek))
            {
                db.TeamDayEntries.Remove(entry);
            }
        }

        await db.SaveChangesAsync(ct);
    }

    /// <summary>
    /// Direct reports of the signed-in employee, or every employee when the All Employees tab is open.
    /// </summary>
    private IQueryable<Employee> TeamQuery(Guid callerId, bool allEmployees) =>
        allEmployees
            ? db.Employees
            : db.Employees.Where(e => e.ReportingManagerId == callerId);

    private async Task<Employee> RequireTeamMemberAsync(Guid employeeId, CancellationToken ct)
    {
        var caller = await CallerEmployeeAsync(ct)
            ?? throw new ForbiddenException("Your user is not linked to an employee.");

        var employee = await db.Employees.FirstOrDefaultAsync(e => e.Id == employeeId, ct)
            ?? throw new NotFoundException("Employee not found.");

        var onTeam = await TeamQuery(caller.Id, allEmployees: false).AnyAsync(e => e.Id == employee.Id, ct);
        if (!onTeam)
        {
            throw new ForbiddenException("This employee is not on your team.");
        }

        return employee;
    }

    private async Task<Employee?> CallerEmployeeAsync(CancellationToken ct)
    {
        var userId = currentUser.UserId;
        if (userId is not null)
        {
            // The user switch sends the employee id. A signed-in account matches UserId.
            var byId = await db.Employees.FirstOrDefaultAsync(e => e.Id == userId, ct);
            if (byId is not null) return byId;

            var byUser = await db.Employees.FirstOrDefaultAsync(e => e.UserId == userId, ct);
            if (byUser is not null) return byUser;
        }

        var email = currentUser.Email;
        if (string.IsNullOrWhiteSpace(email)) return null;
        var normalized = email.Trim().ToLowerInvariant();
        return await db.Employees.FirstOrDefaultAsync(
            e => e.WorkEmail.ToLower() == normalized, ct);
    }

    private static void EnsureRange(DateOnly from, DateOnly to)
    {
        if (from == default || to == default || to < from || to.DayNumber - from.DayNumber > 400)
        {
            throw new ValidationException([
                new ValidationFailure("from", "Choose a from date and a to date no more than 400 days apart."),
            ]);
        }
    }

    private static string? NormalizeAttendance(string? value)
    {
        if (string.IsNullOrWhiteSpace(value) || value.Trim().Equals("clear", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        return value.Trim().ToLowerInvariant();
    }

    private static TeamMemberDto MapMember(
        Employee employee,
        bool directReport,
        DateOnly today,
        string? todayAttendance,
        List<PMS.API.Modules.Projects.Models.ProjectTeamMember>? allocations)
    {
        var name = $"{employee.FirstName} {employee.LastName}".Trim();
        var managerName = employee.ReportingManager is null
            ? null
            : $"{employee.ReportingManager.FirstName} {employee.ReportingManager.LastName}".Trim();

        var activeAlloc = allocations?.FirstOrDefault(a => a.AllocationEndDate >= today);
        var isOnLeave = string.Equals(todayAttendance, "leave", StringComparison.OrdinalIgnoreCase)
            || string.Equals(employee.Status, "On Leave", StringComparison.OrdinalIgnoreCase);

        var allocationStatus = isOnLeave
            ? "On Leave"
            : activeAlloc is not null
                ? "Occupied"
                : "Free";

        string? allocationType = null;
        if (activeAlloc is not null && !string.IsNullOrWhiteSpace(activeAlloc.ResourceType))
        {
            allocationType = activeAlloc.ResourceType.StartsWith("Shared", StringComparison.OrdinalIgnoreCase)
                ? "Shared"
                : "Dedicated";
        }

        var allocDtos = (allocations ?? [])
            .Select(a => new TeamMemberAllocationDto(
                a.ProjectId,
                a.Project?.Name ?? "Project",
                a.ResourceType.StartsWith("Shared", StringComparison.OrdinalIgnoreCase) ? "Shared" : "Dedicated",
                a.AllocationStartDate,
                a.AllocationEndDate,
                a.Billability,
                a.MemberRole))
            .ToList();

        return new TeamMemberDto(
            employee.Id,
            name,
            Initials(employee.FirstName, employee.LastName),
            employee.Designation?.Name ?? "",
            employee.Department?.Name ?? "",
            employee.JobRole?.Name,
            employee.JobRoleId,
            directReport,
            employee.EmployeeCode,
            managerName,
            employee.Status,
            allocationStatus,
            allocationType,
            activeAlloc?.AllocationStartDate,
            activeAlloc?.AllocationEndDate,
            activeAlloc?.Project?.Name,
            allocDtos);
    }

    private static TeamMemberScheduleDto MapSchedule(
        Guid employeeId,
        TeamMemberSchedule? schedule,
        List<TeamMemberHoliday>? holidays)
    {
        var days = schedule?.WorkingDays is { Length: > 0 } stored ? stored : DefaultWorkingDays;
        return new TeamMemberScheduleDto(
            employeeId,
            days,
            schedule?.Notes,
            (holidays ?? []).Select(h => new TeamHolidayDto(h.HolidayDate, h.Name, h.Comment)).ToList());
    }

    private static string Initials(string first, string last)
    {
        var a = string.IsNullOrWhiteSpace(first) ? "" : char.ToUpperInvariant(first.Trim()[0]).ToString();
        var b = string.IsNullOrWhiteSpace(last) ? "" : char.ToUpperInvariant(last.Trim()[0]).ToString();
        var initials = a + b;
        return initials.Length == 0 ? "?" : initials;
    }

    private static DateOnly TodayInIst()
    {
        TimeZoneInfo tz;
        try
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch (TimeZoneNotFoundException)
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }

        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz));
    }
}
