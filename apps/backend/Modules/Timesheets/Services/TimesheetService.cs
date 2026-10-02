using FluentValidation;
using FluentValidation.Results;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Timesheets.DTOs;
using PMS.API.Modules.Timesheets.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Timesheets.Services;

public sealed class TimesheetService(AppDbContext db, ICurrentUserService currentUser) : ITimesheetService
{
    private static readonly HashSet<string> Editable = ["draft", "rejected", "change_requested"];

    public async Task<TimesheetWeekDto?> GetMineAsync(DateOnly weekStart, CancellationToken ct = default)
    {
        var employee = await RequireCallerAsync(ct);
        EnsureMonday(weekStart);
        var week = await LoadWeekAsync(employee.Id, weekStart, ct);
        return week is null ? null : Map(week, employee.Id);
    }

    public async Task<TimesheetWeekDto?> GetPreviousAsync(DateOnly weekStart, CancellationToken ct = default)
    {
        var employee = await RequireCallerAsync(ct);
        EnsureMonday(weekStart);
        var week = await LoadWeekAsync(employee.Id, weekStart.AddDays(-7), ct);
        return week is null ? null : Map(week, employee.Id);
    }

    public Task<TimesheetWeekDto> SaveDraftAsync(SaveTimesheetRequest request, CancellationToken ct = default) =>
        UpsertAsync(request, submit: false, ct);

    public Task<TimesheetWeekDto> SubmitAsync(SaveTimesheetRequest request, CancellationToken ct = default) =>
        UpsertAsync(request, submit: true, ct);

    public async Task<IReadOnlyList<TimesheetWeekDto>> ListForApprovalAsync(CancellationToken ct = default)
    {
        var caller = await RequireCallerAsync(ct);
        var weeks = await db.TimesheetWeeks
            .Include(w => w.Employee)
            .Include(w => w.Entries.Where(e => e.DeletedAtUtc == null))
            .ThenInclude(e => e.Days.Where(d => d.DeletedAtUtc == null))
            .Where(w =>
                w.Status != "draft"
                && w.Employee != null
                && (w.EmployeeId == caller.Id || w.Employee.ReportingManagerId == caller.Id))
            .OrderByDescending(w => w.SubmittedAtUtc)
            .ToListAsync(ct);
        return weeks.Select(w => Map(w, caller.Id)).ToList();
    }

    public async Task<TimesheetWeekDto> DecideAsync(
        Guid timesheetId,
        DecideTimesheetRequest request,
        CancellationToken ct = default)
    {
        var caller = await RequireCallerAsync(ct);
        var action = request.Action?.Trim().ToLowerInvariant() ?? "";
        if (action is not ("approved" or "rejected" or "change_requested"))
        {
            throw new ValidationException([new ValidationFailure("action", "Choose approve, reject, or request changes.")]);
        }

        var comment = request.Comment?.Trim() ?? "";
        if (comment.Length == 0)
        {
            throw new ValidationException([new ValidationFailure("comment", "A comment is required.")]);
        }

        if (comment.Length > 200)
        {
            throw new ValidationException([new ValidationFailure("comment", "Comment must be 200 characters or fewer.")]);
        }

        var ids = request.EntryIds.Distinct().ToList();
        if (ids.Count == 0)
        {
            throw new ValidationException([new ValidationFailure("entryIds", "Select at least one project.")]);
        }

        var week = await db.TimesheetWeeks
            .Include(w => w.Employee)
            .Include(w => w.Entries)
            .ThenInclude(e => e.Days)
            .FirstOrDefaultAsync(w => w.Id == timesheetId, ct)
            ?? throw new NotFoundException("Timesheet not found.");

        if (week.Employee?.ReportingManagerId != caller.Id)
        {
            throw new ForbiddenException("You can review timesheets for your direct reports.");
        }

        if (week.Status != "submitted")
        {
            throw new ValidationException([new ValidationFailure("status", "Only a submitted timesheet can be reviewed.")]);
        }

        var selected = week.Entries.Where(e => e.DeletedAtUtc == null && ids.Contains(e.Id)).ToList();
        if (selected.Count != ids.Count)
        {
            throw new ValidationException([new ValidationFailure("entryIds", "One or more selected lines are not on this timesheet.")]);
        }

        foreach (var entry in selected)
        {
            entry.ReviewDecision = action;
        }

        week.ReviewComment = comment;
        var open = week.Entries.Where(e => e.DeletedAtUtc == null).ToList();
        if (open.All(e => e.ReviewDecision != null))
        {
            week.Status = open.Any(e => e.ReviewDecision == "rejected")
                ? "rejected"
                : open.Any(e => e.ReviewDecision == "change_requested")
                    ? "change_requested"
                    : "approved";
            week.ReviewedByEmployeeId = caller.Id;
            week.ReviewedAtUtc = DateTime.UtcNow;
        }

        await db.SaveChangesAsync(ct);
        return Map(week, caller.Id);
    }

    private async Task<TimesheetWeekDto> UpsertAsync(SaveTimesheetRequest request, bool submit, CancellationToken ct)
    {
        var employee = await RequireCallerAsync(ct);
        EnsureMonday(request.WeekStart);
        var lines = ValidateLines(request.Entries);

        var week = await db.TimesheetWeeks
            .Include(w => w.Entries)
            .ThenInclude(e => e.Days)
            .FirstOrDefaultAsync(w => w.EmployeeId == employee.Id && w.WeekStart == request.WeekStart, ct);

        if (week is not null && !Editable.Contains(week.Status))
        {
            throw new ValidationException([
                new ValidationFailure("status", "This week is already with your reporting manager."),
            ]);
        }

        if (week is null)
        {
            week = new TimesheetWeek
            {
                EmployeeId = employee.Id,
                WeekStart = request.WeekStart,
                Status = "draft",
            };
            db.TimesheetWeeks.Add(week);
        }

        var preserved = week.Entries
            .SelectMany(entry => entry.Days.Select(day => (entry.ProjectKey, entry.TaskKey, day.DayIndex, day.Hours, day.Comment)))
            .ToDictionary(item => (item.ProjectKey, item.TaskKey, item.DayIndex), item => (item.Hours, item.Comment));
        var today = TodayInIst();
        var now = DateTime.UtcNow;
        var oldIds = week.Entries.Select(e => e.Id).ToList();
        foreach (var existing in week.Entries.ToList())
        {
            foreach (var day in existing.Days.ToList())
            {
                db.Entry(day).State = EntityState.Detached;
            }

            db.Entry(existing).State = EntityState.Detached;
        }

        week.Entries.Clear();
        if (oldIds.Count > 0)
        {
            await db.TimesheetEntryDays
                .IgnoreQueryFilters()
                .Where(d => oldIds.Contains(d.TimesheetEntryId) && d.DeletedAtUtc == null)
                .ExecuteUpdateAsync(s => s
                    .SetProperty(d => d.DeletedAtUtc, now)
                    .SetProperty(d => d.UpdatedAtUtc, now), ct);
            await db.TimesheetEntries
                .IgnoreQueryFilters()
                .Where(e => oldIds.Contains(e.Id) && e.DeletedAtUtc == null)
                .ExecuteUpdateAsync(s => s
                    .SetProperty(e => e.DeletedAtUtc, now)
                    .SetProperty(e => e.UpdatedAtUtc, now), ct);
        }

        decimal total = 0;
        foreach (var line in lines)
        {
            var entry = new TimesheetEntry
            {
                TimesheetWeekId = week.Id,
                ProjectKey = line.ProjectKey.Trim(),
                ProjectName = line.ProjectName.Trim(),
                TaskKey = line.TaskKey.Trim(),
                TaskName = line.TaskName.Trim(),
            };
            db.TimesheetEntries.Add(entry);
            foreach (var day in line.Days.OrderBy(d => d.DayIndex))
            {
                var open = IsDayOpen(request.WeekStart, day.DayIndex, today);
                preserved.TryGetValue((entry.ProjectKey, entry.TaskKey, day.DayIndex), out var previous);
                var hours = open ? day.Hours : previous.Hours;
                var comment = open
                    ? (string.IsNullOrWhiteSpace(day.Comment) ? null : day.Comment.Trim())
                    : previous.Comment;
                total += hours;
                entry.Days.Add(new TimesheetEntryDay
                {
                    TimesheetEntryId = entry.Id,
                    DayIndex = day.DayIndex,
                    Hours = hours,
                    Comment = comment,
                });
            }

            week.Entries.Add(entry);
        }

        week.TotalHours = total;
        if (submit)
        {
            week.Status = "submitted";
            week.SubmittedAtUtc = now;
            week.ReviewedAtUtc = null;
            week.ReviewedByEmployeeId = null;
            week.ReviewComment = null;
        }
        else if (week.Status is "rejected" or "change_requested")
        {
            week.Status = "draft";
        }

        await db.SaveChangesAsync(ct);
        week.Employee = employee;
        return Map(week, employee.Id);
    }

    private async Task<TimesheetWeek?> LoadWeekAsync(Guid employeeId, DateOnly weekStart, CancellationToken ct)
    {
        return await db.TimesheetWeeks
            .Include(w => w.Employee)
            .Include(w => w.Entries.Where(e => e.DeletedAtUtc == null))
            .ThenInclude(e => e.Days.Where(d => d.DeletedAtUtc == null))
            .FirstOrDefaultAsync(w => w.EmployeeId == employeeId && w.WeekStart == weekStart, ct);
    }

    private async Task<Employee> RequireCallerAsync(CancellationToken ct)
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
        if (!string.IsNullOrWhiteSpace(email))
        {
            var normalized = email.Trim().ToLowerInvariant();
            var byEmail = await db.Employees.FirstOrDefaultAsync(
                e => e.WorkEmail.ToLower() == normalized, ct);
            if (byEmail is not null) return byEmail;
        }

        throw new ForbiddenException("Your user is not linked to an employee.");
    }

    private static bool IsDayOpen(DateOnly weekStart, short dayIndex, DateOnly today)
    {
        var date = weekStart.AddDays(dayIndex);
        return date >= today.AddDays(-7) && date <= today.AddDays(2);
    }

    private static DateOnly TodayInIst()
    {
        TimeZoneInfo tz;
        try
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }
        catch (TimeZoneNotFoundException)
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }

        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz));
    }

    private static void EnsureMonday(DateOnly weekStart)
    {
        if (weekStart == default || weekStart.DayOfWeek != DayOfWeek.Monday)
        {
            throw new ValidationException([new ValidationFailure("weekStart", "Week start must be a Monday.")]);
        }
    }

    private static IReadOnlyList<SaveTimesheetLineRequest> ValidateLines(IReadOnlyList<SaveTimesheetLineRequest>? entries)
    {
        var lines = entries ?? [];
        if (lines.Count == 0)
        {
            throw new ValidationException([new ValidationFailure("entries", "Add at least one project row.")]);
        }

        foreach (var line in lines)
        {
            if (string.IsNullOrWhiteSpace(line.ProjectKey) || string.IsNullOrWhiteSpace(line.TaskKey))
            {
                throw new ValidationException([new ValidationFailure("entries", "Each row needs a project and a task.")]);
            }

            if (line.Days is null || line.Days.Count != 7 || line.Days.Select(d => d.DayIndex).Distinct().Count() != 7)
            {
                throw new ValidationException([new ValidationFailure("days", "Each row needs Monday through Sunday.")]);
            }

            if (line.Days.Any(d => d.DayIndex is < 0 or > 6 || d.Hours < 0 || d.Hours > 24))
            {
                throw new ValidationException([new ValidationFailure("hours", "Hours must be between 0 and 24.")]);
            }
        }

        return lines;
    }

    private static TimesheetWeekDto Map(TimesheetWeek week, Guid callerId)
    {
        var employee = week.Employee;
        var name = employee is null ? "" : $"{employee.FirstName} {employee.LastName}".Trim();
        var entries = week.Entries
            .Where(e => e.DeletedAtUtc == null)
            .Select(e => new TimesheetLineDto(
                e.Id,
                e.ProjectKey,
                e.ProjectName,
                e.TaskKey,
                e.TaskName,
                e.Days
                    .Where(d => d.DeletedAtUtc == null)
                    .OrderBy(d => d.DayIndex)
                    .Select(d => new TimesheetDayDto(d.DayIndex, d.Hours, d.Comment))
                    .ToList(),
                e.ReviewDecision))
            .ToList();

        return new TimesheetWeekDto(
            week.Id,
            week.EmployeeId,
            name,
            employee?.EmployeeCode ?? "",
            week.WeekStart,
            week.Status,
            week.TotalHours,
            week.SubmittedAtUtc,
            week.ReviewComment,
            week.EmployeeId != callerId
                && week.Employee?.ReportingManagerId == callerId
                && week.Status == "submitted",
            entries);
    }
}
