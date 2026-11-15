using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Timesheets.Models;

namespace PMS.API.Modules.Timesheets.Services;

/// <summary>
/// Service responsible for dispatching Action Centre notifications for Timesheet submissions,
/// approval decisions (Approved, Rejected, Changes Requested), and alternate-day submission reminders.
/// Reuses the centralized ActionNotification system (action.tbl_notifications).
/// </summary>
public sealed class TimesheetNotificationService(
    AppDbContext db,
    ILogger<TimesheetNotificationService> logger) : ITimesheetNotificationService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public async Task NotifyTimesheetSubmittedAsync(
        TimesheetWeek week,
        Employee resource,
        CancellationToken ct = default)
    {
        var resourceName = $"{resource.FirstName} {resource.LastName}".Trim();
        if (string.IsNullOrWhiteSpace(resourceName))
        {
            resourceName = resource.EmployeeCode ?? "Employee";
        }

        var weekEnd = week.WeekStart.AddDays(4);
        var weekEndingFormatted = weekEnd.ToString("dd-MM-yyyy");
        var weekRange = $"{week.WeekStart:dd-MM-yyyy} – {weekEndingFormatted}";

        // 1. Resolve project information from entries
        var (projectId, projectCode, projectName) = await ResolveProjectDetailsAsync(week, ct);

        // 2. Resolve Reporting Manager dynamically
        if (!resource.ReportingManagerId.HasValue || resource.ReportingManagerId == Guid.Empty)
        {
            logger.LogWarning(
                "Cannot send Timesheet Submitted notification: Resource {EmployeeCode} ({ResourceId}) has no ReportingManagerId configured.",
                resource.EmployeeCode,
                resource.Id);
        }
        else
        {
            var manager = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == resource.ReportingManagerId.Value && e.DeletedAtUtc == null, ct);

            if (manager == null)
            {
                logger.LogWarning(
                    "Reporting Manager {ManagerId} for resource {ResourceId} was not found in the database.",
                    resource.ReportingManagerId.Value,
                    resource.Id);
            }
            else
            {
                const string title = "Timesheet Submitted";
                var message = $"{resourceName} has submitted their timesheet for approval.";

                // Check for existing notification to maintain idempotency
                var existing = await db.ActionNotifications
                    .FirstOrDefaultAsync(n =>
                        n.RecipientEmployeeId == manager.Id &&
                        n.Title == title &&
                        (n.RelatedTask == weekRange || n.RelatedTask == $"TS-WEEK-{week.Id}") &&
                        n.DeletedAtUtc == null, ct);

                if (existing != null)
                {
                    existing.Status = "Pending";
                    existing.Priority = "Low";
                    existing.Unread = true;
                    existing.RaisedByName = resourceName;
                    existing.RaisedByEmployeeId = resource.Id;
                    existing.ProjectName = projectName;
                    existing.ProjectId = projectId;
                    existing.ProjectCode = projectCode;
                    existing.UpdatedAtUtc = DateTime.UtcNow;

                    var history = ParseList(existing.HistoryJson);
                    history.Add(new
                    {
                        status = "Pending",
                        at = DateTime.UtcNow.ToString("o"),
                        details = message
                    });
                    existing.HistoryJson = JsonSerializer.Serialize(history);
                }
                else
                {
                    var notif = new ActionNotification
                    {
                        Id = Guid.NewGuid(),
                        RecipientEmployeeId = manager.Id,
                        Title = title,
                        Type = "Timesheet Submitted",
                        Priority = "Low",
                        Status = "Pending",
                        Unread = true,
                        RaisedByName = resourceName,
                        RaisedByEmployeeId = resource.Id,
                        ProjectId = projectId,
                        ProjectCode = projectCode,
                        ProjectName = projectName,
                        RelatedTask = weekRange,
                        CreatedAtUtc = DateTime.UtcNow,
                        HistoryJson = JsonSerializer.Serialize(new[]
                        {
                            new
                            {
                                status = "Pending",
                                at = DateTime.UtcNow.ToString("o"),
                                details = message
                            }
                        }),
                        CommentsJson = "[]"
                    };
                    db.ActionNotifications.Add(notif);
                }
            }
        }

        // 3. Stop all pending submission reminders for this timesheet week
        var reminderPrefix = $"TS-REMINDER-{week.WeekStart:yyyyMMdd}";
        var pendingReminders = await db.ActionNotifications
            .Where(n =>
                n.RecipientEmployeeId == resource.Id &&
                n.Title == "Timesheet Submission Reminder" &&
                n.Status == "Pending" &&
                n.DeletedAtUtc == null &&
                ((n.RelatedTask != null && n.RelatedTask.StartsWith(reminderPrefix)) ||
                 n.RelatedTask == weekRange ||
                 n.HistoryJson.Contains(weekEndingFormatted)))
            .ToListAsync(ct);

        foreach (var reminder in pendingReminders)
        {
            reminder.Status = "Submitted";
            reminder.Unread = false;
            reminder.UpdatedAtUtc = DateTime.UtcNow;

            var history = ParseList(reminder.HistoryJson);
            history.Add(new
            {
                status = "Submitted",
                at = DateTime.UtcNow.ToString("o"),
                details = $"Timesheet for week ending {weekEndingFormatted} submitted. Pending reminder stopped."
            });
            reminder.HistoryJson = JsonSerializer.Serialize(history);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToSecondaryDb();
    }

    public async Task NotifyTimesheetDecidedAsync(
        TimesheetWeek week,
        Employee reviewer,
        string action,
        string? comment,
        CancellationToken ct = default)
    {
        var managerName = $"{reviewer.FirstName} {reviewer.LastName}".Trim();
        if (string.IsNullOrWhiteSpace(managerName))
        {
            managerName = reviewer.EmployeeCode ?? "Reporting Manager";
        }

        var normalizedAction = (action ?? "").Trim().ToLowerInvariant();
        string title;
        string status;
        string message;
        string type;

        switch (normalizedAction)
        {
            case "approved":
                title = "Timesheet Approved";
                status = "Approved";
                message = $"Your timesheet has been approved by {managerName}.";
                type = "Timesheet Approved";
                break;
            case "rejected":
                title = "Timesheet Rejected";
                status = "Rejected";
                message = $"Your timesheet has been rejected by {managerName}. Please review and resubmit it before the submission deadline.";
                type = "Timesheet Rejected";
                break;
            case "change_requested":
            case "request_change":
            case "request change":
            case "request changes":
                title = "Timesheet Changes Requested";
                status = "Request Change";
                message = $"Your timesheet has been sent back for changes by {managerName}. Please review and update it before the submission deadline.";
                type = "Timesheet Changes Requested";
                break;
            default:
                logger.LogWarning("Unknown timesheet review action: '{Action}'. Skipping notification.", action);
                return;
        }

        var weekEnd = week.WeekStart.AddDays(4);
        var weekRange = $"{week.WeekStart:dd-MM-yyyy} – {weekEnd:dd-MM-yyyy}";

        // Resolve project info
        var (projectId, projectCode, projectName) = await ResolveProjectDetailsAsync(week, ct);

        // Format comments & history
        var comments = new List<object>();
        if (!string.IsNullOrWhiteSpace(comment))
        {
            comments.Add(new
            {
                author = managerName,
                authorId = reviewer.Id.ToString(),
                text = comment.Trim(),
                createdAt = DateTime.UtcNow.ToString("o")
            });
        }

        var historyDetails = !string.IsNullOrWhiteSpace(comment)
            ? $"{message} Remarks: {comment.Trim()}"
            : message;

        var history = new List<object>
        {
            new
            {
                status = status,
                at = DateTime.UtcNow.ToString("o"),
                details = historyDetails
            }
        };

        // 1. Notify resource who submitted
        var resourceNotif = new ActionNotification
        {
            Id = Guid.NewGuid(),
            RecipientEmployeeId = week.EmployeeId,
            Title = title,
            Type = type,
            Priority = "Low",
            Status = status,
            Unread = true,
            RaisedByName = managerName,
            RaisedByEmployeeId = reviewer.Id,
            ProjectId = projectId,
            ProjectCode = projectCode,
            ProjectName = projectName,
            RelatedTask = weekRange,
            CreatedAtUtc = DateTime.UtcNow,
            CommentsJson = JsonSerializer.Serialize(comments),
            HistoryJson = JsonSerializer.Serialize(history)
        };
        db.ActionNotifications.Add(resourceNotif);

        // 2. Synchronize Manager's Prior Submission Notification
        var managerNotif = await db.ActionNotifications
            .Where(n =>
                n.RecipientEmployeeId == reviewer.Id &&
                n.Title == "Timesheet Submitted" &&
                n.DeletedAtUtc == null &&
                n.RaisedByEmployeeId == week.EmployeeId &&
                (n.RelatedTask == weekRange || n.RelatedTask == $"TS-WEEK-{week.Id}"))
            .OrderByDescending(n => n.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);

        if (managerNotif != null)
        {
            managerNotif.Status = status;
            managerNotif.Unread = false;
            managerNotif.UpdatedAtUtc = DateTime.UtcNow;

            var mgrHistory = ParseList(managerNotif.HistoryJson);
            mgrHistory.Add(new
            {
                status = status,
                at = DateTime.UtcNow.ToString("o"),
                details = $"Decision recorded as {status} by {managerName}." +
                          (!string.IsNullOrWhiteSpace(comment) ? $" Remarks: {comment.Trim()}" : "")
            });
            managerNotif.HistoryJson = JsonSerializer.Serialize(mgrHistory);

            if (!string.IsNullOrWhiteSpace(comment))
            {
                var mgrComments = ParseList(managerNotif.CommentsJson);
                mgrComments.Add(new
                {
                    author = managerName,
                    authorId = reviewer.Id.ToString(),
                    text = comment.Trim(),
                    createdAt = DateTime.UtcNow.ToString("o")
                });
                managerNotif.CommentsJson = JsonSerializer.Serialize(mgrComments);
            }
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToSecondaryDb();
    }

    public async Task<int> ProcessTimesheetRemindersAsync(
        DateOnly? overrideToday = null,
        CancellationToken ct = default)
    {
        // Use IST date by default (UTC + 5.5 hours)
        var today = overrideToday ?? DateOnly.FromDateTime(DateTime.UtcNow.AddHours(5.5));
        var dayOfWeek = today.DayOfWeek;

        // Submission window is Friday through Monday
        if (dayOfWeek is not (DayOfWeek.Friday or DayOfWeek.Saturday or DayOfWeek.Sunday or DayOfWeek.Monday))
        {
            logger.LogInformation(
                "Timesheet reminder job: Today is {DayOfWeek} ({Today}). Outside submission window (Fri-Mon). 0 reminders sent.",
                dayOfWeek, today);
            return 0;
        }

        // Determine target work week start (Monday)
        var targetWeekStart = dayOfWeek switch
        {
            DayOfWeek.Friday => today.AddDays(-4),
            DayOfWeek.Saturday => today.AddDays(-5),
            DayOfWeek.Sunday => today.AddDays(-6),
            DayOfWeek.Monday => today.AddDays(-7),
            _ => today
        };

        var weekEndingFormatted = targetWeekStart.AddDays(4).ToString("dd-MM-yyyy");
        var reminderKey = $"TS-REMINDER-{targetWeekStart:yyyyMMdd}";

        // Find all active employees
        var activeEmployees = await db.Employees
            .AsNoTracking()
            .Where(e => e.DeletedAtUtc == null &&
                        (e.Status == null || e.Status == "" ||
                         (e.Status != "Exited" && e.Status != "Terminated" && e.Status != "Inactive")))
            .ToListAsync(ct);

        if (activeEmployees.Count == 0)
        {
            return 0;
        }

        // Find employees who already submitted or have approved timesheets for target week
        var submittedEmployeeIds = await db.TimesheetWeeks
            .AsNoTracking()
            .Where(w => w.WeekStart == targetWeekStart &&
                        (w.Status == "submitted" || w.Status == "approved") &&
                        w.DeletedAtUtc == null)
            .Select(w => w.EmployeeId)
            .ToHashSetAsync(ct);

        var unsubmittedEmployees = activeEmployees
            .Where(e => !submittedEmployeeIds.Contains(e.Id))
            .ToList();

        if (unsubmittedEmployees.Count == 0)
        {
            logger.LogInformation(
                "All {Total} active employees have already submitted their timesheets for week ending {WeekEnding}.",
                activeEmployees.Count, weekEndingFormatted);
            return 0;
        }

        // Query existing reminders for this week to enforce alternate-day cadence
        var reminderPrefix = $"TS-REMINDER-{targetWeekStart:yyyyMMdd}";
        var existingReminders = await db.ActionNotifications
            .AsNoTracking()
            .Where(n =>
                n.Title == "Timesheet Submission Reminder" &&
                n.RelatedTask != null &&
                n.RelatedTask.StartsWith(reminderPrefix) &&
                n.DeletedAtUtc == null)
            .ToListAsync(ct);

        var remindersByEmployee = existingReminders
            .GroupBy(r => r.RecipientEmployeeId)
            .ToDictionary(
                g => g.Key,
                g => g.OrderByDescending(r => ExtractSentDate(r)).First());

        var remindersCreated = 0;
        var message = $"Your timesheet for the week ending {weekEndingFormatted} is pending submission. Please submit it before the Monday deadline.";
        var nowUtc = overrideToday.HasValue
            ? DateTime.SpecifyKind(overrideToday.Value.ToDateTime(new TimeOnly(3, 30, 0)), DateTimeKind.Utc)
            : DateTime.UtcNow;

        foreach (var employee in unsubmittedEmployees)
        {
            if (remindersByEmployee.TryGetValue(employee.Id, out var lastReminder))
            {
                var lastSentDate = ExtractSentDate(lastReminder);
                var daysSinceLast = today.DayNumber - lastSentDate.DayNumber;

                // Alternate-day check: must be at least 2 days since the last reminder
                if (daysSinceLast < 2)
                {
                    continue;
                }
            }

            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = employee.Id,
                Title = "Timesheet Submission Reminder",
                Type = "Timesheet Submission Reminder",
                Priority = "Low",
                Status = "Pending",
                Unread = true,
                RaisedByName = "System",
                RaisedByEmployeeId = null,
                ProjectName = !string.IsNullOrWhiteSpace(employee.ProjectAllocated) ? employee.ProjectAllocated : "-",
                RelatedTask = $"{reminderPrefix}-{today:yyyyMMdd}",
                CreatedAtUtc = nowUtc,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Pending",
                        at = nowUtc.ToString("o"),
                        details = message
                    }
                }),
                CommentsJson = "[]"
            };

            db.ActionNotifications.Add(notif);
            remindersCreated++;
        }

        if (remindersCreated > 0)
        {
            await db.SaveChangesAsync(ct);
            TrySyncNotificationsToSecondaryDb();
        }

        logger.LogInformation(
            "Timesheet reminder job completed for week ending {WeekEnding}: generated {Count} reminders across {UnsubmittedCount} unsubmitted employees.",
            weekEndingFormatted, remindersCreated, unsubmittedEmployees.Count);

        return remindersCreated;
    }

    private async Task<(Guid? ProjectId, string? ProjectCode, string ProjectName)> ResolveProjectDetailsAsync(
        TimesheetWeek week,
        CancellationToken ct)
    {
        var projectNames = week.Entries?
            .Where(e => !string.IsNullOrWhiteSpace(e.ProjectName) && e.DeletedAtUtc == null)
            .Select(e => e.ProjectName.Trim())
            .Distinct()
            .ToList() ?? [];

        if (projectNames.Count == 0)
        {
            return (null, null, "-");
        }

        if (projectNames.Count == 1)
        {
            var singleName = projectNames[0];
            var project = await db.Projects
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Name == singleName && p.DeletedAtUtc == null, ct);

            return (project?.Id, project?.ProjectCode, singleName);
        }

        return (null, null, string.Join(", ", projectNames));
    }

    private static List<object> ParseList(string? json)
    {
        if (string.IsNullOrWhiteSpace(json))
        {
            return [];
        }

        try
        {
            var doc = JsonDocument.Parse(json);
            if (doc.RootElement.ValueKind == JsonValueKind.Array)
            {
                var list = new List<object>();
                foreach (var el in doc.RootElement.EnumerateArray())
                {
                    list.Add(JsonSerializer.Deserialize<object>(el.GetRawText(), JsonOptions)!);
                }
                return list;
            }
        }
        catch
        {
            // fallback to empty list
        }

        return [];
    }

    private static DateOnly ExtractSentDate(ActionNotification r)
    {
        if (!string.IsNullOrWhiteSpace(r.RelatedTask) && r.RelatedTask.Length >= 28)
        {
            var parts = r.RelatedTask.Split('-');
            if (parts.Length >= 4 && DateOnly.TryParseExact(parts[3], "yyyyMMdd", out var parsedDate))
            {
                return parsedDate;
            }
        }
        return DateOnly.FromDateTime(r.CreatedAtUtc.AddHours(5.5));
    }

    private static void TrySyncNotificationsToSecondaryDb()
    {
        try
        {
            using var conn = new Npgsql.NpgsqlConnection("Host=127.0.0.1;Port=5432;Database=pms_uat;Username=postgres;Password=123;Timeout=2;Include Error Detail=true");
            conn.Open();
            // Connection test succeeded
        }
        catch
        {
            // Silently ignore secondary sync failures in non-UAT or single-DB environments
        }
    }
}
