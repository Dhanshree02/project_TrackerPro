using System.Text.Encodings.Web;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Sla.Services;

namespace PMS.API.Modules.MyTeam.Services;

public sealed class TeamAvailabilityNotificationService : ITeamAvailabilityNotificationService
{
    private static readonly JsonSerializerOptions s_jsonOptions = new()
    {
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    private readonly AppDbContext _db;
    private readonly ISlaRecipientResolver _slaRecipientResolver;
    private readonly ILogger<TeamAvailabilityNotificationService> _logger;

    public TeamAvailabilityNotificationService(
        AppDbContext db,
        ISlaRecipientResolver slaRecipientResolver,
        ILogger<TeamAvailabilityNotificationService> logger)
    {
        _db = db;
        _slaRecipientResolver = slaRecipientResolver;
        _logger = logger;
    }

    public async Task<int> SendReportingManagerTwoHourRemindersAsync(DateOnly? targetDate = null, CancellationToken ct = default)
    {
        var date = targetDate ?? TodayInIst();
        var isExplicit = targetDate.HasValue;

        if (!isExplicit && (date.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday))
        {
            return 0;
        }

        if (!isExplicit && await _db.LeaveCalendarHolidays.AnyAsync(h => h.DeletedAtUtc == null && h.HolidayDate == date, ct))
        {
            return 0;
        }

        var activeReportees = await _db.Employees
            .AsNoTracking()
            .Include(e => e.ReportingManager)
            .Where(e => e.DeletedAtUtc == null
                     && e.ReportingManagerId != null
                     && (e.Status == null || !e.Status.ToLower().StartsWith("inactive") && !e.Status.ToLower().StartsWith("terminated")))
            .ToListAsync(ct);

        if (activeReportees.Count == 0) return 0;

        var empIds = activeReportees.Select(e => e.Id).ToList();

        var dayEntries = await _db.TeamDayEntries
            .AsNoTracking()
            .Where(e => empIds.Contains(e.EmployeeId) && e.WorkDate == date && e.DeletedAtUtc == null)
            .ToListAsync(ct);

        var entriesByEmpId = dayEntries.ToDictionary(e => e.EmployeeId);

        var allocations = await _db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Project)
            .Where(m => empIds.Contains(m.EmployeeId)
                     && m.DeletedAtUtc == null
                     && m.Project != null
                     && m.Project.DeletedAtUtc == null
                     && m.AllocationStartDate <= date
                     && m.AllocationEndDate >= date)
            .ToListAsync(ct);

        var allocsByEmpId = allocations
            .GroupBy(m => m.EmployeeId)
            .ToDictionary(g => g.Key, g => g.FirstOrDefault()?.Project);

        var pendingReportees = activeReportees.Where(e =>
        {
            if (!entriesByEmpId.TryGetValue(e.Id, out var entry)) return true;
            if (string.IsNullOrWhiteSpace(entry.Attendance)) return true;
            if (string.Equals(entry.Attendance, "leave", StringComparison.OrdinalIgnoreCase)) return false;
            return string.IsNullOrWhiteSpace(entry.Shift);
        }).ToList();

        if (pendingReportees.Count == 0) return 0;

        var nowUtc = DateTime.UtcNow;
        var notifications = new List<ActionNotification>();

        // Group pending reportees by ReportingManagerId and ProjectId (the project the resource is under)
        var groups = pendingReportees
            .GroupBy(e => new
            {
                ManagerId = e.ReportingManagerId!.Value,
                ProjectId = allocsByEmpId.GetValueOrDefault(e.Id)?.Id
            })
            .ToList();

        foreach (var group in groups)
        {
            var manager = activeReportees.FirstOrDefault(e => e.ReportingManagerId == group.Key.ManagerId)?.ReportingManager
                       ?? await _db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == group.Key.ManagerId, ct);
            if (manager == null) continue;

            Project? project = null;
            if (group.Key.ProjectId.HasValue)
            {
                project = await _db.Projects.AsNoTracking().FirstOrDefaultAsync(p => p.Id == group.Key.ProjectId.Value && p.DeletedAtUtc == null, ct);
            }

            var resourceNamesList = group.Select(r => $"{r.FirstName} {r.LastName}".Trim()).Distinct().ToList();
            var resourceNames = string.Join(", ", resourceNamesList);

            string title;
            if (project != null)
            {
                title = $"Pending Team Availability & Shift Coverage: {resourceNames} - {project.Name}";
            }
            else
            {
                title = $"Pending Team Availability & Shift Coverage: {resourceNames}";
            }

            if (title.Length > 255) title = title[..255];

            var projectName = project?.Name ?? "-";
            var message = $"Reminder: You have {group.Count()} reportee(s) ({resourceNames}) pending Team Availability and Shift Coverage updates for {date:dd-MMM-yyyy}. Please update them under My Team -> Team Dashboard -> My Reportees.";

            notifications.Add(new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = manager.Id,
                ProjectId = project?.Id,
                ProjectCode = project?.ProjectCode,
                ProjectName = projectName,
                Title = title,
                Type = "Team Availability Reminder",
                Priority = "Medium",
                Status = "Pending",
                Unread = true,
                RelatedTask = "Team Availability & Shift Coverage",
                RaisedByName = "System",
                CreatedAtUtc = nowUtc,
                CommentsJson = JsonSerializer.Serialize(new[]
                {
                    new { text = message, by = "System", at = nowUtc.ToString("o") }
                }, s_jsonOptions),
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        action = "Reminder Dispatched",
                        date = nowUtc.ToString("yyyy-MM-dd"),
                        time = nowUtc.ToString("HH:mm:ss"),
                        by = "System",
                        details = message
                    }
                }, s_jsonOptions)
            });
        }

        if (notifications.Count > 0)
        {
            _db.ActionNotifications.AddRange(notifications);
            await _db.SaveChangesAsync(ct);
            _logger.LogInformation("[TeamAvailability] Dispatched {Count} 2-hour reminders to reporting managers for date {Date}.", notifications.Count, date);
        }

        return notifications.Count;
    }

    public async Task<int> SendProjectLeadershipDailyAlertAsync(int hour, DateOnly? targetDate = null, CancellationToken ct = default)
    {
        var date = targetDate ?? TodayInIst();
        var isExplicit = targetDate.HasValue;

        if (!isExplicit && (date.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday))
        {
            return 0;
        }

        if (!isExplicit && await _db.LeaveCalendarHolidays.AnyAsync(h => h.DeletedAtUtc == null && h.HolidayDate == date, ct))
        {
            return 0;
        }

        var activeProjects = await _db.Projects
            .AsNoTracking()
            .Where(p => p.DeletedAtUtc == null)
            .ToListAsync(ct);

        if (activeProjects.Count == 0) return 0;

        var nowUtc = DateTime.UtcNow;
        var notifications = new List<ActionNotification>();
        var hourLabel = hour == 12 ? "12:00 PM" : $"{hour}:00 AM";

        foreach (var project in activeProjects)
        {
            var projectAllocations = await _db.ProjectTeamMembers
                .AsNoTracking()
                .Include(m => m.Employee)
                    .ThenInclude(e => e!.ReportingManager)
                .Where(m => m.ProjectId == project.Id
                         && m.DeletedAtUtc == null
                         && m.AllocationStartDate <= date
                         && m.AllocationEndDate >= date
                         && m.Employee != null
                         && m.Employee.DeletedAtUtc == null)
                .ToListAsync(ct);

            if (projectAllocations.Count == 0) continue;

            var empIds = projectAllocations.Select(m => m.EmployeeId).Distinct().ToList();

            var dayEntries = await _db.TeamDayEntries
                .AsNoTracking()
                .Where(e => empIds.Contains(e.EmployeeId) && e.WorkDate == date && e.DeletedAtUtc == null)
                .ToListAsync(ct);

            var entriesByEmpId = dayEntries.ToDictionary(e => e.EmployeeId);

            var pendingMembers = projectAllocations.Where(m =>
            {
                if (!entriesByEmpId.TryGetValue(m.EmployeeId, out var entry)) return true;
                if (string.IsNullOrWhiteSpace(entry.Attendance)) return true;
                if (string.Equals(entry.Attendance, "leave", StringComparison.OrdinalIgnoreCase)) return false;
                return string.IsNullOrWhiteSpace(entry.Shift);
            }).ToList();

            var leadershipRecipients = await _slaRecipientResolver.ResolveLeadershipRecipientsAsync(
                project.Id,
                ["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"],
                ct);

            if (leadershipRecipients.Count == 0) continue;

            string title;
            string message;
            string priority;
            string status;
            string type;

            var totalCount = projectAllocations.Count;
            if (pendingMembers.Count > 0)
            {
                var pendingNames = string.Join(", ", pendingMembers.Select(m => $"{m.Employee!.FirstName} {m.Employee.LastName}".Trim()).Distinct());
                var managerNames = string.Join(", ", pendingMembers
                    .Where(m => m.Employee?.ReportingManager != null)
                    .Select(m => $"{m.Employee!.ReportingManager!.FirstName} {m.Employee.ReportingManager.LastName}".Trim())
                    .Distinct());

                title = $"Alert: Pending Resource Availability & Shift Coverage - {project.Name} ({hourLabel})";
                type = "Project Shift & Availability Alert";
                priority = "Medium";
                status = "Pending";
                message = $"{pendingMembers.Count} of {totalCount} resource(s) ({pendingNames}) allocated to '{project.Name}' have NOT been updated by their reporting manager(s) ({managerNames}) for {date:dd-MMM-yyyy}.";
            }
            else
            {
                title = $"Project Team Availability Updated: {project.Name} ({hourLabel})";
                type = "Project Shift & Availability Status";
                priority = "Low";
                status = "Completed";
                message = $"All {totalCount} allocated resource(s) under '{project.Name}' have their Team Availability and Shift Coverage updated for {date:dd-MMM-yyyy} by their reporting managers.";
            }

            if (title.Length > 255) title = title[..255];

            foreach (var recId in leadershipRecipients)
            {
                notifications.Add(new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = recId,
                    ProjectId = project.Id,
                    ProjectCode = project.ProjectCode,
                    ProjectName = project.Name,
                    Title = title,
                    Type = type,
                    Priority = priority,
                    Status = status,
                    Unread = true,
                    RelatedTask = "Team Availability & Shift Coverage",
                    RaisedByName = "System",
                    CreatedAtUtc = nowUtc,
                    CommentsJson = JsonSerializer.Serialize(new[]
                    {
                        new { text = message, by = "System", at = nowUtc.ToString("o") }
                    }, s_jsonOptions),
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            action = $"{hourLabel} Project Leadership Alert",
                            date = nowUtc.ToString("yyyy-MM-dd"),
                            time = nowUtc.ToString("HH:mm:ss"),
                            by = "System",
                            details = message
                        }
                    }, s_jsonOptions)
                });
            }
        }

        if (notifications.Count > 0)
        {
            _db.ActionNotifications.AddRange(notifications);
            await _db.SaveChangesAsync(ct);
            _logger.LogInformation("[TeamAvailability] Dispatched {Count} leadership alerts for {HourLabel} for date {Date}.", notifications.Count, hourLabel, date);
        }

        return notifications.Count;
    }

    public async Task<int> SendSpmDailyAlertAsync(DateOnly? targetDate = null, CancellationToken ct = default)
    {
        var date = targetDate ?? TodayInIst();
        var isExplicit = targetDate.HasValue;

        if (!isExplicit && (date.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday))
        {
            return 0;
        }

        if (!isExplicit && await _db.LeaveCalendarHolidays.AnyAsync(h => h.DeletedAtUtc == null && h.HolidayDate == date, ct))
        {
            return 0;
        }

        var activeProjects = await _db.Projects
            .AsNoTracking()
            .Where(p => p.DeletedAtUtc == null)
            .ToListAsync(ct);

        if (activeProjects.Count == 0) return 0;

        var nowUtc = DateTime.UtcNow;
        var notifications = new List<ActionNotification>();

        foreach (var project in activeProjects)
        {
            var projectAllocations = await _db.ProjectTeamMembers
                .AsNoTracking()
                .Include(m => m.Employee)
                    .ThenInclude(e => e!.ReportingManager)
                .Where(m => m.ProjectId == project.Id
                         && m.DeletedAtUtc == null
                         && m.AllocationStartDate <= date
                         && m.AllocationEndDate >= date
                         && m.Employee != null
                         && m.Employee.DeletedAtUtc == null)
                .ToListAsync(ct);

            if (projectAllocations.Count == 0) continue;

            var spmRecipients = await _slaRecipientResolver.ResolveLeadershipRecipientsAsync(
                project.Id,
                ["Assigned Senior Project Manager"],
                ct);

            if (spmRecipients.Count == 0) continue;

            var empIds = projectAllocations.Select(m => m.EmployeeId).Distinct().ToList();

            var dayEntries = await _db.TeamDayEntries
                .AsNoTracking()
                .Where(e => empIds.Contains(e.EmployeeId) && e.WorkDate == date && e.DeletedAtUtc == null)
                .ToListAsync(ct);

            var entriesByEmpId = dayEntries.ToDictionary(e => e.EmployeeId);

            var pendingMembers = projectAllocations.Where(m =>
            {
                if (!entriesByEmpId.TryGetValue(m.EmployeeId, out var entry)) return true;
                if (string.IsNullOrWhiteSpace(entry.Attendance)) return true;
                if (string.Equals(entry.Attendance, "leave", StringComparison.OrdinalIgnoreCase)) return false;
                return string.IsNullOrWhiteSpace(entry.Shift);
            }).ToList();

            string title;
            string message;
            string priority;
            string status;
            string type;

            var totalCount = projectAllocations.Count;
            if (pendingMembers.Count > 0)
            {
                var pendingNames = string.Join(", ", pendingMembers.Select(m => $"{m.Employee!.FirstName} {m.Employee.LastName}".Trim()).Distinct());
                var managerNames = string.Join(", ", pendingMembers
                    .Where(m => m.Employee?.ReportingManager != null)
                    .Select(m => $"{m.Employee!.ReportingManager!.FirstName} {m.Employee.ReportingManager.LastName}".Trim())
                    .Distinct());

                title = $"Escalation: Pending Resource Availability & Shift Coverage - {project.Name} (1:00 PM)";
                type = "SPM Shift & Availability Escalation";
                priority = "High";
                status = "Pending";
                message = $"As of 1:00 PM, {pendingMembers.Count} of {totalCount} resource(s) ({pendingNames}) under '{project.Name}' still have NOT been updated by their reporting managers ({managerNames}) for {date:dd-MMM-yyyy}.";
            }
            else
            {
                title = $"Project Team Availability Status: {project.Name} (1:00 PM)";
                type = "SPM Shift & Availability Status";
                priority = "Low";
                status = "Completed";
                message = $"As of 1:00 PM, all {totalCount} resource(s) under '{project.Name}' have their Team Availability and Shift Coverage updated for {date:dd-MMM-yyyy}.";
            }

            if (title.Length > 255) title = title[..255];

            foreach (var recId in spmRecipients)
            {
                notifications.Add(new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = recId,
                    ProjectId = project.Id,
                    ProjectCode = project.ProjectCode,
                    ProjectName = project.Name,
                    Title = title,
                    Type = type,
                    Priority = priority,
                    Status = status,
                    Unread = true,
                    RelatedTask = "Team Availability & Shift Coverage",
                    RaisedByName = "System",
                    CreatedAtUtc = nowUtc,
                    CommentsJson = JsonSerializer.Serialize(new[]
                    {
                        new { text = message, by = "System", at = nowUtc.ToString("o") }
                    }, s_jsonOptions),
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            action = "1:00 PM SPM Daily Escalation Alert",
                            date = nowUtc.ToString("yyyy-MM-dd"),
                            time = nowUtc.ToString("HH:mm:ss"),
                            by = "System",
                            details = message
                        }
                    }, s_jsonOptions)
                });
            }
        }

        if (notifications.Count > 0)
        {
            _db.ActionNotifications.AddRange(notifications);
            await _db.SaveChangesAsync(ct);
            _logger.LogInformation("[TeamAvailability] Dispatched {Count} SPM alerts for date {Date}.", notifications.Count, date);
        }

        return notifications.Count;
    }

    public async Task<int> SendHodNextDayEodEscalationAsync(DateOnly? targetDate = null, CancellationToken ct = default)
    {
        DateOnly evalDate;
        if (targetDate.HasValue)
        {
            evalDate = targetDate.Value;
        }
        else
        {
            var today = TodayInIst();
            evalDate = today.AddDays(-1);
            while (evalDate.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday)
            {
                evalDate = evalDate.AddDays(-1);
            }
        }

        var activeReportees = await _db.Employees
            .AsNoTracking()
            .Include(e => e.ReportingManager)
            .Include(e => e.Department)
            .Where(e => e.DeletedAtUtc == null
                     && e.ReportingManagerId != null
                     && (e.Status == null || !e.Status.ToLower().StartsWith("inactive") && !e.Status.ToLower().StartsWith("terminated")))
            .ToListAsync(ct);

        if (activeReportees.Count == 0) return 0;

        var empIds = activeReportees.Select(e => e.Id).ToList();

        var dayEntries = await _db.TeamDayEntries
            .AsNoTracking()
            .Where(e => empIds.Contains(e.EmployeeId) && e.WorkDate == evalDate && e.DeletedAtUtc == null)
            .ToListAsync(ct);

        var entriesByEmpId = dayEntries.ToDictionary(e => e.EmployeeId);

        var allocations = await _db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Project)
            .Where(m => empIds.Contains(m.EmployeeId)
                     && m.DeletedAtUtc == null
                     && m.Project != null
                     && m.Project.DeletedAtUtc == null
                     && m.AllocationStartDate <= evalDate
                     && m.AllocationEndDate >= evalDate)
            .ToListAsync(ct);

        var allocsByEmpId = allocations
            .GroupBy(m => m.EmployeeId)
            .ToDictionary(g => g.Key, g => g.FirstOrDefault()?.Project);

        var unfulfilledReportees = activeReportees.Where(e =>
        {
            if (!entriesByEmpId.TryGetValue(e.Id, out var entry)) return true;
            if (string.IsNullOrWhiteSpace(entry.Attendance)) return true;
            if (string.Equals(entry.Attendance, "leave", StringComparison.OrdinalIgnoreCase)) return false;
            return string.IsNullOrWhiteSpace(entry.Shift);
        }).ToList();

        if (unfulfilledReportees.Count == 0) return 0;

        var nowUtc = DateTime.UtcNow;
        var notifications = new List<ActionNotification>();

        var groups = unfulfilledReportees
            .GroupBy(e => new
            {
                ManagerId = e.ReportingManagerId!.Value,
                ProjectId = allocsByEmpId.GetValueOrDefault(e.Id)?.Id
            })
            .ToList();

        foreach (var group in groups)
        {
            var manager = activeReportees.FirstOrDefault(e => e.ReportingManagerId == group.Key.ManagerId)?.ReportingManager
                       ?? await _db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == group.Key.ManagerId, ct);
            if (manager == null) continue;

            var managerName = $"{manager.FirstName} {manager.LastName}".Trim();

            Project? project = null;
            if (group.Key.ProjectId.HasValue)
            {
                project = await _db.Projects.AsNoTracking().FirstOrDefaultAsync(p => p.Id == group.Key.ProjectId.Value && p.DeletedAtUtc == null, ct);
            }

            var resourceNamesList = group.Select(r => $"{r.FirstName} {r.LastName}".Trim()).Distinct().ToList();
            var resourceNames = string.Join(", ", resourceNamesList);

            // Resolve HOD recipients
            List<Guid> hodRecipients = [];
            if (project != null)
            {
                var resolved = await _slaRecipientResolver.ResolveLeadershipRecipientsAsync(
                    project.Id,
                    ["Head of Department"],
                    ct);
                hodRecipients.AddRange(resolved);
            }

            if (hodRecipients.Count == 0)
            {
                // Fallback query for employees designated as HOD
                var fallbackHods = await (
                    from e in _db.Employees.AsNoTracking()
                    where e.DeletedAtUtc == null && (e.Status == null || !e.Status.ToLower().StartsWith("inactive"))
                    join r in _db.OnFloorRoles.AsNoTracking() on e.DesignationId equals r.DesignationId into roles
                    from r in roles.DefaultIfEmpty()
                    where (r != null && r.DeletedAtUtc == null && (r.Name.ToLower().Contains("head of department") || r.Name.ToLower() == "hod"))
                       || (e.Role != null && (e.Role.ToLower().Contains("head of department") || e.Role.ToLower() == "hod"))
                    select e.Id
                ).Distinct().ToListAsync(ct);

                hodRecipients.AddRange(fallbackHods);
            }

            if (hodRecipients.Count == 0) continue;

            string title;
            if (project != null)
            {
                title = $"HOD Escalation: Reporting Manager Failed to Update Shift & Availability - {managerName} - {project.Name}";
            }
            else
            {
                title = $"HOD Escalation: Reporting Manager Failed to Update Shift & Availability - {managerName}";
            }

            if (title.Length > 255) title = title[..255];

            var projectName = project?.Name ?? "-";
            var message = $"Reporting Manager {managerName} failed to update Team Availability and Shift Coverage for reportee(s) ({resourceNames}) for {evalDate:dd-MMM-yyyy}. This compliance breach is escalated to HOD.";

            foreach (var hodId in hodRecipients.Distinct())
            {
                notifications.Add(new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = hodId,
                    ProjectId = project?.Id,
                    ProjectCode = project?.ProjectCode,
                    ProjectName = projectName,
                    Title = title,
                    Type = "HOD Shift & Availability Escalation",
                    Priority = "High",
                    Status = "Escalated",
                    Unread = true,
                    RelatedTask = "Shift & Availability Compliance Breach",
                    RaisedByName = "System",
                    CreatedAtUtc = nowUtc,
                    CommentsJson = JsonSerializer.Serialize(new[]
                    {
                        new { text = message, by = "System", at = nowUtc.ToString("o") }
                    }, s_jsonOptions),
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            action = "Next-Day EOD HOD Escalation",
                            date = nowUtc.ToString("yyyy-MM-dd"),
                            time = nowUtc.ToString("HH:mm:ss"),
                            by = "System",
                            details = message
                        }
                    }, s_jsonOptions)
                });
            }
        }

        if (notifications.Count > 0)
        {
            _db.ActionNotifications.AddRange(notifications);
            await _db.SaveChangesAsync(ct);
            _logger.LogInformation("[TeamAvailability] Dispatched {Count} HOD escalations for date {Date}.", notifications.Count, evalDate);
        }

        return notifications.Count;
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
