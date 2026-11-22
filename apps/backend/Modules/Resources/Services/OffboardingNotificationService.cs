using System.Globalization;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;

namespace PMS.API.Modules.Resources.Services;

public sealed class OffboardingNotificationService(
    AppDbContext db,
    ILogger<OffboardingNotificationService> logger) : IOffboardingNotificationService
{
    private static readonly JsonSerializerOptions s_jsonOptions = new()
    {
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    public static TimeZoneInfo GetIstTimeZone()
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch (TimeZoneNotFoundException)
        {
            return TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }
    }

    public static DateOnly GetTodayInIst()
    {
        var tz = GetIstTimeZone();
        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz));
    }

    public async Task<int> SendImmediateResignationNotificationAsync(
        Guid employeeId,
        string? initiatorName = null,
        Guid? initiatorId = null,
        CancellationToken ct = default)
    {
        var employee = await db.Employees
            .AsNoTracking()
            .Include(e => e.Department)
            .FirstOrDefaultAsync(e => e.Id == employeeId, ct);

        var exitRecord = await db.ExitedEmployees
            .AsNoTracking()
            .OrderByDescending(x => x.ExitedAtUtc)
            .FirstOrDefaultAsync(x => x.OriginalEmployeeId == employeeId && x.DeletedAtUtc == null, ct);

        if (exitRecord == null && employee == null)
        {
            logger.LogWarning("[OffboardingNotificationService] Cannot find employee or exit record for ID {EmployeeId}", employeeId);
            return 0;
        }

        var resourceName = employee != null
            ? $"{employee.FirstName} {employee.LastName}".Trim()
            : (exitRecord?.FullName ?? "Resource");

        var employeeCode = employee?.EmployeeCode ?? exitRecord?.EmployeeCode ?? "";
        var lwd = exitRecord?.LastWorkingDay;
        var lwdFormatted = lwd.HasValue ? lwd.Value.ToString("d MMMM yyyy", CultureInfo.InvariantCulture) : "N/A";

        var activeProjects = await GetActiveProjectsForEmployeeAsync(employeeId, ct);
        if (activeProjects.Count == 0)
        {
            logger.LogInformation("[OffboardingNotificationService] Employee {EmployeeId} ({Name}) has no active project assignments.", employeeId, resourceName);
            return 0;
        }

        var title = $"{resourceName} Resignation Applied";
        var raisedBy = !string.IsNullOrWhiteSpace(initiatorName) ? initiatorName.Trim() : "System";
        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        var dispatched = 0;
        foreach (var project in activeProjects)
        {
            var emId = await ResolveProjectEngagementManagerAsync(project, ct);
            if (!emId.HasValue || emId.Value == Guid.Empty)
            {
                logger.LogInformation("[OffboardingNotificationService] No Engagement Manager found for project {ProjectName} ({ProjectId})", project.Name, project.Id);
                continue;
            }

            // Check if notification already sent to avoid duplicate
            var alreadySent = await db.ActionNotifications.AnyAsync(n =>
                n.RecipientEmployeeId == emId.Value &&
                n.ProjectId == project.Id &&
                n.Title == title &&
                n.RelatedTask == employeeCode &&
                n.DeletedAtUtc == null, ct);

            if (alreadySent)
            {
                logger.LogInformation("[OffboardingNotificationService] Immediate resignation notification already sent to EM {EmId} for project {ProjectId}", emId.Value, project.Id);
                continue;
            }

            var messageContent = $"{resourceName} has applied for resignation under project '{project.Name}'. Last working date is {lwdFormatted}.";

            db.ActionNotifications.Add(new ActionNotification
            {
                RecipientEmployeeId = emId.Value,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = title,
                Type = "Resignation Applied",
                Priority = "Low",
                Status = "Pending",
                Unread = true,
                RaisedByName = raisedBy,
                RaisedByEmployeeId = initiatorId,
                RelatedTask = employeeCode,
                CreatedAtUtc = now,
                CommentsJson = JsonSerializer.Serialize(new[]
                {
                    new { text = messageContent, by = raisedBy, at = now.ToString("o") }
                }, s_jsonOptions),
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        action = "Resignation Applied",
                        date = dateStr,
                        time = timeStr,
                        by = raisedBy
                    }
                }, s_jsonOptions)
            });

            dispatched++;
        }

        if (dispatched > 0)
        {
            await db.SaveChangesAsync(ct);
            logger.LogInformation("[OffboardingNotificationService] Dispatched {Count} immediate resignation notifications for {Name}", dispatched, resourceName);
        }

        return dispatched;
    }

    public async Task<int> ProcessLwdRemindersAsync(
        DateOnly? targetDateIst = null,
        CancellationToken ct = default)
    {
        var todayIst = targetDateIst ?? GetTodayInIst();
        var istTz = GetIstTimeZone();
        var todayStartUtc = TimeZoneInfo.ConvertTimeToUtc(todayIst.ToDateTime(TimeOnly.MinValue), istTz);
        var todayEndUtc = TimeZoneInfo.ConvertTimeToUtc(todayIst.ToDateTime(TimeOnly.MaxValue), istTz);

        var activeExits = await db.ExitedEmployees
            .AsNoTracking()
            .Where(x => x.DeletedAtUtc == null && x.ResignationDate != null && x.LastWorkingDay != null)
            .ToListAsync(ct);

        if (activeExits.Count == 0) return 0;

        var dispatched = 0;
        var now = DateTime.UtcNow;

        foreach (var exit in activeExits)
        {
            var lwd = exit.LastWorkingDay!.Value;
            var resDate = exit.ResignationDate!.Value;

            // 1. Check if offboarding is cancelled
            var employee = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == exit.OriginalEmployeeId && e.DeletedAtUtc == null, ct);

            if (employee != null)
            {
                var status = employee.Status?.Trim().ToLowerInvariant() ?? "";
                bool isExiting = status == "notice period" || status == "resigned" || status == "offboarded" || status.Contains("exit") || status.Contains("notice") || status.Contains("resign");
                if (!isExiting)
                {
                    // Offboarding cancelled; skip reminder
                    continue;
                }
            }

            // 2. Frequency rules:
            // - Do not send reminders after the Last Working Day
            if (todayIst > lwd)
            {
                continue;
            }

            // - Do not send reminders on or before the resignation date itself (day 0 was immediate)
            if (todayIst <= resDate)
            {
                continue;
            }

            // - Reminders occur every 2 days
            int daysSinceResignation = todayIst.DayNumber - resDate.DayNumber;
            if (daysSinceResignation % 2 != 0)
            {
                continue;
            }

            // 3. Resolve active projects for employee
            var activeProjects = await GetActiveProjectsForEmployeeAsync(exit.OriginalEmployeeId, ct);
            if (activeProjects.Count == 0) continue;

            var lwdFormatted = lwd.ToString("d MMMM yyyy", CultureInfo.InvariantCulture);
            var title = $"{exit.FullName} Last Working date is {lwdFormatted}";

            foreach (var project in activeProjects)
            {
                var emId = await ResolveProjectEngagementManagerAsync(project, ct);
                if (!emId.HasValue || emId.Value == Guid.Empty) continue;

                // Idempotency: Ensure notification is generated at most once per recipient, project, resource, and scheduled reminder date
                var dateStr = todayIst.ToString("yyyy-MM-dd");
                var alreadySentToday = await db.ActionNotifications.AnyAsync(n =>
                    n.RecipientEmployeeId == emId.Value &&
                    n.ProjectId == project.Id &&
                    n.Title == title &&
                    n.Type == "LWD Reminder" &&
                    n.RelatedTask == exit.EmployeeCode &&
                    n.DeletedAtUtc == null &&
                    ((n.CreatedAtUtc >= todayStartUtc && n.CreatedAtUtc <= todayEndUtc) || n.HistoryJson.Contains(dateStr)), ct);

                if (alreadySentToday) continue;

                var messageContent = $"Reminder: {exit.FullName}'s Last Working Day under project '{project.Name}' is {lwdFormatted}.";

                db.ActionNotifications.Add(new ActionNotification
                {
                    RecipientEmployeeId = emId.Value,
                    ProjectId = project.Id,
                    ProjectCode = project.ProjectCode,
                    ProjectName = project.Name,
                    Title = title,
                    Type = "LWD Reminder",
                    Priority = "Low",
                    Status = "Pending",
                    Unread = true,
                    RaisedByName = "System / Automation Engine",
                    RelatedTask = exit.EmployeeCode,
                    CreatedAtUtc = now,
                    CommentsJson = JsonSerializer.Serialize(new[]
                    {
                        new { text = messageContent, by = "System / Automation Engine", at = now.ToString("o") }
                    }, s_jsonOptions),
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            action = "LWD Reminder",
                            date = todayIst.ToString("yyyy-MM-dd"),
                            time = now.ToString("HH:mm:ss"),
                            by = "System / Automation Engine"
                        }
                    }, s_jsonOptions)
                });

                dispatched++;
            }
        }

        if (dispatched > 0)
        {
            await db.SaveChangesAsync(ct);
            logger.LogInformation("[OffboardingNotificationService] Processed LWD reminders for date {DateIst}. Dispatched: {Count}", todayIst, dispatched);
        }

        return dispatched;
    }

    public async Task<int> ProcessPostOffboardingNotificationsAsync(
        DateOnly? targetDateIst = null,
        CancellationToken ct = default)
    {
        var todayIst = targetDateIst ?? GetTodayInIst();

        // On the next calendar date after the employee's Last Working Day
        var dueExits = await db.ExitedEmployees
            .AsNoTracking()
            .Where(x => x.DeletedAtUtc == null && x.LastWorkingDay != null && x.LastWorkingDay.Value.AddDays(1) == todayIst)
            .ToListAsync(ct);

        if (dueExits.Count == 0) return 0;

        var dispatched = 0;
        var now = DateTime.UtcNow;

        foreach (var exit in dueExits)
        {
            // Verify offboarding was not cancelled
            var employee = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == exit.OriginalEmployeeId && e.DeletedAtUtc == null, ct);

            if (employee != null)
            {
                var status = employee.Status?.Trim().ToLowerInvariant() ?? "";
                bool isExiting = status == "notice period" || status == "resigned" || status == "offboarded" || status.Contains("exit") || status.Contains("notice") || status.Contains("resign");
                if (!isExiting)
                {
                    continue;
                }
            }

            var title = $"{exit.FullName} is offboarded";
            var lwdFormatted = exit.LastWorkingDay!.Value.ToString("d MMMM yyyy", CultureInfo.InvariantCulture);

            var activeProjects = await GetActiveProjectsForEmployeeAsync(exit.OriginalEmployeeId, ct);
            var primaryProject = activeProjects.FirstOrDefault();

            // 1. Resolve HOD using On Floor Role = Head Of Department
            var hodRecipientIds = await ResolveHodRecipientsAsync(exit, ct);
            foreach (var hodId in hodRecipientIds)
            {
                var alreadySentHod = await db.ActionNotifications.AnyAsync(n =>
                    n.RecipientEmployeeId == hodId &&
                    n.Title == title &&
                    n.Type == "Employee Offboarded" &&
                    n.RelatedTask == exit.EmployeeCode &&
                    n.DeletedAtUtc == null, ct);

                if (alreadySentHod) continue;

                var hodMessage = $"{exit.FullName} is offboarded following the completion of their Last Working Day on {lwdFormatted}.";

                db.ActionNotifications.Add(new ActionNotification
                {
                    RecipientEmployeeId = hodId,
                    ProjectId = primaryProject?.Id,
                    ProjectCode = primaryProject?.ProjectCode,
                    ProjectName = primaryProject?.Name ?? (exit.DepartmentName ?? "Organization"),
                    Title = title,
                    Type = "Employee Offboarded",
                    Priority = "Low",
                    Status = "Pending",
                    Unread = true,
                    RaisedByName = "System / Automation Engine",
                    RelatedTask = exit.EmployeeCode,
                    CreatedAtUtc = now,
                    CommentsJson = JsonSerializer.Serialize(new[]
                    {
                        new { text = hodMessage, by = "System / Automation Engine", at = now.ToString("o") }
                    }, s_jsonOptions),
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            action = "Employee Offboarded",
                            date = todayIst.ToString("yyyy-MM-dd"),
                            time = now.ToString("HH:mm:ss"),
                            by = "System / Automation Engine"
                        }
                    }, s_jsonOptions)
                });

                dispatched++;
            }

            // 2. Resolve Senior Project Manager (SPM) assigned to the employee's project(s)
            foreach (var project in activeProjects)
            {
                var spmIds = await ResolveSeniorProjectManagersAsync(project.Id, ct);
                foreach (var spmId in spmIds)
                {
                    var alreadySentSpm = await db.ActionNotifications.AnyAsync(n =>
                        n.RecipientEmployeeId == spmId &&
                        n.ProjectId == project.Id &&
                        n.Title == title &&
                        n.Type == "Employee Offboarded" &&
                        n.RelatedTask == exit.EmployeeCode &&
                        n.DeletedAtUtc == null, ct);

                    if (alreadySentSpm) continue;

                    var spmMessage = $"{exit.FullName} is offboarded from project '{project.Name}' following completion of their Last Working Day on {lwdFormatted}.";

                    db.ActionNotifications.Add(new ActionNotification
                    {
                        RecipientEmployeeId = spmId,
                        ProjectId = project.Id,
                        ProjectCode = project.ProjectCode,
                        ProjectName = project.Name,
                        Title = title,
                        Type = "Employee Offboarded",
                        Priority = "Low",
                        Status = "Pending",
                        Unread = true,
                        RaisedByName = "System / Automation Engine",
                        RelatedTask = exit.EmployeeCode,
                        CreatedAtUtc = now,
                        CommentsJson = JsonSerializer.Serialize(new[]
                        {
                            new { text = spmMessage, by = "System / Automation Engine", at = now.ToString("o") }
                        }, s_jsonOptions),
                        HistoryJson = JsonSerializer.Serialize(new[]
                        {
                            new
                            {
                                action = "Employee Offboarded",
                                date = todayIst.ToString("yyyy-MM-dd"),
                                time = now.ToString("HH:mm:ss"),
                                by = "System / Automation Engine"
                            }
                        }, s_jsonOptions)
                    });

                    dispatched++;
                }
            }
        }

        if (dispatched > 0)
        {
            await db.SaveChangesAsync(ct);
            logger.LogInformation("[OffboardingNotificationService] Processed post-offboarding notifications for date {DateIst}. Dispatched: {Count}", todayIst, dispatched);
        }

        return dispatched;
    }

    private async Task<List<Project>> GetActiveProjectsForEmployeeAsync(Guid employeeId, CancellationToken ct)
    {
        var teamProjIds = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(tm => tm.EmployeeId == employeeId && tm.DeletedAtUtc == null)
            .Select(tm => tm.ProjectId)
            .ToListAsync(ct);

        var taskProjIds = await db.ProjectTaskAssignments
            .AsNoTracking()
            .Where(ta => ta.EmployeeId == employeeId && ta.IsActive && ta.DeletedAtUtc == null && ta.Task != null && ta.Task.DeletedAtUtc == null)
            .Select(ta => ta.Task!.ProjectId)
            .ToListAsync(ct);

        var bucketProjIds = await db.BucketTasks
            .AsNoTracking()
            .Where(bt => bt.EmployeeId == employeeId && bt.DeletedAtUtc == null && bt.Status != "Cancelled" && bt.Status != "Completed")
            .Select(bt => bt.ProjectId)
            .ToListAsync(ct);

        var allProjIds = teamProjIds.Concat(taskProjIds).Concat(bucketProjIds).Distinct().ToList();
        if (allProjIds.Count == 0) return [];

        return await db.Projects
            .AsNoTracking()
            .Include(p => p.Client)
            .Where(p => allProjIds.Contains(p.Id) && p.DeletedAtUtc == null &&
                        (p.Status == null || (p.Status.ToLower() != "completed" && p.Status.ToLower() != "cancelled")))
            .ToListAsync(ct);
    }

    private async Task<Guid?> ResolveProjectEngagementManagerAsync(Project project, CancellationToken ct)
    {
        if (project.EngagementManagerId.HasValue && project.EngagementManagerId.Value != Guid.Empty)
        {
            return project.EngagementManagerId.Value;
        }

        if (project.Client?.EngagementManagerId.HasValue == true && project.Client.EngagementManagerId.Value != Guid.Empty)
        {
            return project.Client.EngagementManagerId.Value;
        }

        var emMember = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(tm => tm.Employee)
            .Where(tm => tm.ProjectId == project.Id && tm.DeletedAtUtc == null)
            .FirstOrDefaultAsync(tm =>
                (tm.MemberRole != null && (tm.MemberRole.ToLower() == "engagementmanager" ||
                                           tm.MemberRole.ToLower() == "engagement manager" ||
                                           tm.MemberRole.ToLower() == "em")) ||
                (tm.Employee != null && tm.Employee.Role != null && (tm.Employee.Role.ToLower() == "engagementmanager" ||
                                                                     tm.Employee.Role.ToLower() == "engagement manager" ||
                                                                     tm.Employee.Role.ToLower() == "em")), ct);

        return emMember?.EmployeeId;
    }

    private async Task<List<Guid>> ResolveSeniorProjectManagersAsync(Guid projectId, CancellationToken ct)
    {
        var spmIds = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(tm => tm.ProjectId == projectId && tm.DeletedAtUtc == null &&
                         (tm.MemberRole == ProjectMemberRoles.SeniorProjectManager ||
                          tm.MemberRole == "SeniorProjectManager" ||
                          tm.MemberRole == "Senior Project Manager" ||
                          tm.MemberRole == "SPM"))
            .Select(tm => tm.EmployeeId)
            .Distinct()
            .ToListAsync(ct);

        if (spmIds.Count == 0)
        {
            spmIds = await db.ProjectTeamMembers
                .AsNoTracking()
                .Include(tm => tm.Employee)
                .Where(tm => tm.ProjectId == projectId && tm.DeletedAtUtc == null && tm.Employee != null &&
                             tm.Employee.Role != null && (tm.Employee.Role.ToLower() == "seniorprojectmanager" ||
                                                          tm.Employee.Role.ToLower() == "senior project manager" ||
                                                          tm.Employee.Role.ToLower() == "spm"))
                .Select(tm => tm.EmployeeId)
                .Distinct()
                .ToListAsync(ct);
        }

        return spmIds;
    }

    private async Task<List<Guid>> ResolveHodRecipientsAsync(ExitedEmployee exit, CancellationToken ct)
    {
        // 1. Mandatory condition: On Floor Role = Head Of Department
        var hodDesignationIds = await db.OnFloorRoles
            .AsNoTracking()
            .Where(o => o.DeletedAtUtc == null && (
                o.Name.ToLower() == "head of department" ||
                o.Name.ToLower() == "hod" ||
                o.Name.Contains("Head Of Department")
            ))
            .Select(o => o.DesignationId)
            .Distinct()
            .ToListAsync(ct);

        var activeHods = await db.Employees
            .AsNoTracking()
            .Include(e => e.Department)
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || !e.Status.ToLower().StartsWith("inactive")))
            .Where(e =>
                (e.DesignationId.HasValue && hodDesignationIds.Contains(e.DesignationId.Value)) ||
                (e.Role != null && (e.Role.ToLower() == "head of department" || e.Role.ToLower() == "hod" || e.Role.Contains("Head Of Department")))
            )
            .ToListAsync(ct);

        if (activeHods.Count == 0) return [];

        // 2. Resolve employee department/subdepartment
        var employee = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == exit.OriginalEmployeeId, ct);
        var deptId = employee?.DepartmentId;
        var subDeptId = employee?.SubDepartmentId;

        // Match subdepartment if available
        if (subDeptId.HasValue)
        {
            var subMatches = activeHods.Where(h => h.SubDepartmentId == subDeptId.Value).ToList();
            if (subMatches.Count > 0)
                return subMatches.Select(h => h.Id).Distinct().ToList();
        }

        // Match department by ID if available
        if (deptId.HasValue)
        {
            var deptMatches = activeHods.Where(h => h.DepartmentId == deptId.Value).ToList();
            if (deptMatches.Count > 0)
                return deptMatches.Select(h => h.Id).Distinct().ToList();
        }

        // Match by department name text
        if (!string.IsNullOrWhiteSpace(exit.DepartmentName))
        {
            var nameMatches = activeHods.Where(h =>
                (h.Department != null && h.Department.Name.Equals(exit.DepartmentName, StringComparison.OrdinalIgnoreCase)) ||
                (h.SubDepartment != null && h.SubDepartment.Contains(exit.DepartmentName, StringComparison.OrdinalIgnoreCase))
            ).ToList();
            if (nameMatches.Count > 0)
                return nameMatches.Select(h => h.Id).Distinct().ToList();
        }

        // Fallback to all active HODs
        return activeHods.Select(h => h.Id).Distinct().ToList();
    }
}
