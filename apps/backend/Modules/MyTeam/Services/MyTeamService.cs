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

    public async Task<TeamCalendarDto> GetCalendarAsync(DateOnly from, DateOnly to, CancellationToken ct = default)
    {
        EnsureRange(from, to);
        var caller = await CallerEmployeeAsync(ct);
        if (caller is null)
        {
            return new TeamCalendarDto([], [], []);
        }

        var members = await TeamQuery(caller.Id)
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .OrderBy(e => e.FirstName)
            .ThenBy(e => e.LastName)
            .ToListAsync(ct);

        if (members.Count == 0)
        {
            return new TeamCalendarDto([], [], []);
        }

        var ids = members.Select(m => m.Id).ToList();
        var entries = await db.TeamDayEntries
            .Where(e => ids.Contains(e.EmployeeId) && e.WorkDate >= from && e.WorkDate <= to)
            .OrderBy(e => e.WorkDate)
            .ToListAsync(ct);
        var schedules = await db.TeamMemberSchedules
            .Where(s => ids.Contains(s.EmployeeId))
            .ToListAsync(ct);
        var holidays = await db.TeamMemberHolidays
            .Where(h => ids.Contains(h.EmployeeId))
            .OrderBy(h => h.HolidayDate)
            .ToListAsync(ct);

        var scheduleByEmployee = schedules.ToDictionary(s => s.EmployeeId);
        var holidaysByEmployee = holidays.GroupBy(h => h.EmployeeId)
            .ToDictionary(g => g.Key, g => g.ToList());

        return new TeamCalendarDto(
            members.Select(MapMember).ToList(),
            entries.Select(e => new TeamDayEntryDto(e.EmployeeId, e.WorkDate, e.Attendance, e.Shift)).ToList(),
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

    private IQueryable<Employee> TeamQuery(Guid callerId) =>
        db.Employees.Where(e =>
            e.Status != null
            && e.Status.ToLower() == "active"
            && e.EngagementManagerEmployeeId != null
            && e.ReportingManagerId != null
            && e.ProjectManagerId != null
            && (e.EngagementManagerEmployeeId == callerId
                || e.ReportingManagerId == callerId
                || e.ProjectManagerId == callerId));

    private async Task<Employee> RequireTeamMemberAsync(Guid employeeId, CancellationToken ct)
    {
        var caller = await CallerEmployeeAsync(ct)
            ?? throw new ForbiddenException("Your user is not linked to an employee.");

        var employee = await db.Employees.FirstOrDefaultAsync(e => e.Id == employeeId, ct)
            ?? throw new NotFoundException("Employee not found.");

        var onTeam = await TeamQuery(caller.Id).AnyAsync(e => e.Id == employee.Id, ct);
        if (!onTeam)
        {
            throw new ForbiddenException("This employee is not on your team.");
        }

        return employee;
    }

    private async Task<Employee?> CallerEmployeeAsync(CancellationToken ct)
    {
        var userId = currentUser.UserId;
        if (userId is null) return null;
        return await db.Employees.FirstOrDefaultAsync(e => e.UserId == userId, ct);
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

    private static TeamMemberDto MapMember(Employee employee)
    {
        var name = $"{employee.FirstName} {employee.LastName}".Trim();
        return new TeamMemberDto(
            employee.Id,
            name,
            Initials(employee.FirstName, employee.LastName),
            employee.Designation?.Name ?? "",
            employee.Department?.Name ?? "");
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
