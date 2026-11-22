using System.Collections.Concurrent;
using System.Text.Json;
using Hangfire.Common;
using Hangfire.Dashboard;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Jobs;

/// <summary>
/// Central registry and dynamic display-name formatter for Hangfire SLA jobs.
/// Generates human-readable business descriptions dynamically from database records
/// for Scheduled, Enqueued, Processing, Succeeded, and Deleted dashboard views.
/// </summary>
public static class SlaJobDisplayNameFormatter
{
    private static readonly ConcurrentDictionary<(Guid InstanceId, Guid EventId), string> s_cache = new();
    private static IServiceScopeFactory? s_scopeFactory;
    private static ILogger? s_logger;

    /// <summary>
    /// Configures the formatter with application services and initiates background cache pre-warming.
    /// </summary>
    public static void Initialize(IServiceProvider services)
    {
        s_scopeFactory = services.GetService<IServiceScopeFactory>();
        var loggerFactory = services.GetService<ILoggerFactory>();
        s_logger = loggerFactory?.CreateLogger("PMS.API.Modules.Sla.Jobs.SlaJobDisplayNameFormatter");

        if (s_scopeFactory != null)
        {
            // Fire-and-forget background pre-warm of existing active/scheduled SLA events
            _ = Task.Run(async () =>
            {
                try
                {
                    await PrewarmCacheAsync();
                }
                catch (Exception ex)
                {
                    s_logger?.LogWarning(ex, "[SLA DisplayName] Background cache pre-warm encountered an error.");
                }
            });
        }
    }

    /// <summary>
    /// Pre-registers a human-readable name in memory when an SLA job is scheduled or rescheduled.
    /// </summary>
    public static void Register(Guid instanceId, Guid eventId, string displayName)
    {
        if (instanceId != Guid.Empty && eventId != Guid.Empty && !string.IsNullOrWhiteSpace(displayName))
        {
            s_cache[(instanceId, eventId)] = displayName;
        }
    }

    /// <summary>
    /// Formats the job name for the Hangfire Dashboard.
    /// Looks up the cached description first; if not found, dynamically queries the database.
    /// </summary>
    public static string FormatJobName(DashboardContext? context, Job job, string fallback)
    {
        if (job?.Args == null || job.Args.Count < 2)
        {
            return fallback;
        }

        if (!TryParseGuid(job.Args[0], out var instanceId) ||
            !TryParseGuid(job.Args[1], out var eventId))
        {
            return fallback;
        }

        int? escalationLevel = null;
        if (job.Args.Count >= 3)
        {
            if (job.Args[2] is int lvl) escalationLevel = lvl;
            else if (int.TryParse(job.Args[2]?.ToString(), out var parsedLvl)) escalationLevel = parsedLvl;
        }

        // Fast path: cached description
        if (s_cache.TryGetValue((instanceId, eventId), out var cachedName) && !string.IsNullOrWhiteSpace(cachedName))
        {
            return cachedName;
        }

        // Slow path: resolve from database
        try
        {
            var resolvedName = ResolveSynchronously(context, instanceId, eventId, escalationLevel, job.Method?.Name ?? string.Empty);
            if (!string.IsNullOrWhiteSpace(resolvedName))
            {
                s_cache[(instanceId, eventId)] = resolvedName;
                return resolvedName;
            }
        }
        catch (Exception ex)
        {
            s_logger?.LogDebug(ex, "[SLA DisplayName] Failed to resolve dynamic name for instance {InstanceId}, event {EventId}.", instanceId, eventId);
        }

        return fallback;
    }

    /// <summary>
    /// Builds the standard human-readable SLA job description string according to project business rules.
    /// </summary>
    public static string BuildJobName(
        string? activityType,
        string? eventType,
        int? escalationLevel,
        string? entityTitle,
        string? projectName,
        IReadOnlyList<string>? targetRoles = null)
    {
        var cleanActivity = activityType?.Trim() ?? string.Empty;
        var cleanEntity = string.IsNullOrWhiteSpace(entityTitle) ? "General" : entityTitle.Trim();
        var cleanProject = string.IsNullOrWhiteSpace(projectName) ? "Project" : projectName.Trim();

        // 0. Dedicated Format for Extension Request (Section 11)
        if (cleanActivity.Contains("Extension", StringComparison.OrdinalIgnoreCase))
        {
            var reqId = cleanEntity;
            if (string.IsNullOrWhiteSpace(reqId) || reqId == "General")
            {
                reqId = "EXT-REQ";
            }

            if (escalationLevel == 1 || string.Equals(eventType, nameof(SlaEventType.EscalationL1), StringComparison.OrdinalIgnoreCase))
            {
                return $"Extension Request | L1 Escalation | Senior Project Manager | {cleanProject} | {reqId}";
            }

            if (escalationLevel == 2 || string.Equals(eventType, nameof(SlaEventType.EscalationL2), StringComparison.OrdinalIgnoreCase))
            {
                return $"Extension Request | L2 Escalation | Head of Department | {cleanProject} | {reqId}";
            }

            if (string.Equals(eventType, nameof(SlaEventType.Reminder), StringComparison.OrdinalIgnoreCase))
            {
                if (targetRoles != null && targetRoles.Any(r => r.Contains("Head of Department", StringComparison.OrdinalIgnoreCase) || r.Equals("HOD", StringComparison.OrdinalIgnoreCase)))
                {
                    return $"Extension Request | L2 Daily Reminder | Head of Department | {cleanProject} | {reqId}";
                }
                if (targetRoles != null && targetRoles.Any(r => r.Contains("Senior Project Manager", StringComparison.OrdinalIgnoreCase) || r.Equals("SPM", StringComparison.OrdinalIgnoreCase)))
                {
                    return $"Extension Request | L1 Daily Reminder | Senior Project Manager | {cleanProject} | {reqId}";
                }

                return $"Extension Request | Initial Approval Reminder | {cleanProject} | {reqId}";
            }

            if (string.Equals(eventType, nameof(SlaEventType.BreachCheck), StringComparison.OrdinalIgnoreCase))
            {
                return $"Extension Request | Breach Check | {cleanProject} | {reqId}";
            }

            return $"Extension Request | {eventType ?? "Milestone"} | {cleanProject} | {reqId}";
        }

        // 0. Dedicated Format for Additional Customer Requirement (Section 11)
        if (cleanActivity.Contains("Requirement", StringComparison.OrdinalIgnoreCase))
        {
            if (escalationLevel == 1 || string.Equals(eventType, nameof(SlaEventType.EscalationL1), StringComparison.OrdinalIgnoreCase))
            {
                return $"Additional Customer Requirement | L1 Escalation | Senior Project Manager | {cleanProject} | {cleanEntity}";
            }

            if (escalationLevel == 2 || string.Equals(eventType, nameof(SlaEventType.EscalationL2), StringComparison.OrdinalIgnoreCase))
            {
                return $"Additional Customer Requirement | L2 Escalation | Head of Department | {cleanProject} | {cleanEntity}";
            }

            if (string.Equals(eventType, nameof(SlaEventType.Reminder), StringComparison.OrdinalIgnoreCase))
            {
                if (targetRoles != null && targetRoles.Any(r => r.Contains("Head of Department", StringComparison.OrdinalIgnoreCase) || r.Equals("HOD", StringComparison.OrdinalIgnoreCase)))
                {
                    return $"Additional Customer Requirement | L2 Daily Reminder | Head of Department | {cleanProject} | {cleanEntity}";
                }
                if (targetRoles != null && targetRoles.Any(r => r.Contains("Senior Project Manager", StringComparison.OrdinalIgnoreCase) || r.Equals("SPM", StringComparison.OrdinalIgnoreCase)))
                {
                    return $"Additional Customer Requirement | L1 Daily Reminder | Senior Project Manager | {cleanProject} | {cleanEntity}";
                }

                return $"Additional Customer Requirement | Initial Approval Reminder | {cleanProject} | {cleanEntity}";
            }

            if (string.Equals(eventType, nameof(SlaEventType.BreachCheck), StringComparison.OrdinalIgnoreCase))
            {
                return $"Additional Customer Requirement | Breach Check | {cleanProject} | {cleanEntity}";
            }

            return $"Additional Customer Requirement | {eventType ?? "Milestone"} | {cleanProject} | {cleanEntity}";
        }

        // 1. Resolve SLA Category Prefix
        string slaCategory;
        if (cleanActivity.Equals("Task Start After Assigning", StringComparison.OrdinalIgnoreCase))
        {
            slaCategory = "Task Start SLA";
        }
        else if (cleanActivity.Equals("Task Deadline", StringComparison.OrdinalIgnoreCase))
        {
            slaCategory = "Task Deadline SLA";
        }
        else if (cleanActivity.Equals("Task Pause", StringComparison.OrdinalIgnoreCase))
        {
            slaCategory = "Task Pause SLA";
        }
        else if (cleanActivity.Contains("Issue", StringComparison.OrdinalIgnoreCase) || cleanActivity.Equals("Resolution of Issues", StringComparison.OrdinalIgnoreCase))
        {
            slaCategory = "Project Issue SLA";
        }
        else if (cleanActivity.Contains("WBS", StringComparison.OrdinalIgnoreCase) || cleanActivity.Contains("Service Escalation", StringComparison.OrdinalIgnoreCase))
        {
            slaCategory = "WBS Escalation SLA";
        }
        else if (cleanActivity.Contains("Extension", StringComparison.OrdinalIgnoreCase))
        {
            slaCategory = "Extension Request SLA";
        }
        else if (cleanActivity.Contains("Requirement", StringComparison.OrdinalIgnoreCase))
        {
            slaCategory = "Customer Requirement SLA";
        }
        else if (cleanActivity.Contains("Allocation", StringComparison.OrdinalIgnoreCase))
        {
            slaCategory = "Resource Allocation SLA";
        }
        else
        {
            slaCategory = string.IsNullOrWhiteSpace(cleanActivity) ? "SLA" : $"{cleanActivity} SLA";
        }

        // 2. Resolve Action, Recipient Role, and Specific Job Name
        // A & B & D: Level 1 Escalation
        if (escalationLevel == 1 || string.Equals(eventType, nameof(SlaEventType.EscalationL1), StringComparison.OrdinalIgnoreCase))
        {
            return $"{slaCategory} | L1 Escalation | Senior Project Manager | {cleanEntity} | {cleanProject}";
        }

        // A & B & D: Level 2 Escalation
        if (escalationLevel == 2 || string.Equals(eventType, nameof(SlaEventType.EscalationL2), StringComparison.OrdinalIgnoreCase))
        {
            return $"{slaCategory} | L2 Escalation | Head of Department | {cleanEntity} | {cleanProject}";
        }

        // E: Breach Check Jobs
        if (string.Equals(eventType, nameof(SlaEventType.BreachCheck), StringComparison.OrdinalIgnoreCase))
        {
            return $"{slaCategory} | Breach Check | {cleanEntity} | {cleanProject}";
        }

        // F: Reminder Jobs
        if (string.Equals(eventType, nameof(SlaEventType.Reminder), StringComparison.OrdinalIgnoreCase))
        {
            if (slaCategory == "Task Deadline SLA")
            {
                return $"Task Deadline SLA | Upcoming Deadline Reminder | {cleanEntity} | {cleanProject}";
            }

            if (slaCategory == "Task Pause SLA")
            {
                return $"Task Pause SLA | Daily Reminder | Assigned Resource | {cleanEntity} | {cleanProject}";
            }

            if (slaCategory == "Project Issue SLA")
            {
                return $"Project Issue SLA | Reminder | EM, PM & TL | {cleanEntity} | {cleanProject}";
            }

            var recipientRole = FormatRecipientRoles(targetRoles, cleanActivity);
            return $"{slaCategory} | Reminder | {recipientRole} | {cleanEntity} | {cleanProject}";
        }

        // Immediate / Initial Notification
        if (string.Equals(eventType, "ImmediateNotification", StringComparison.OrdinalIgnoreCase)
            || string.Equals(eventType, "Immediate Notification", StringComparison.OrdinalIgnoreCase)
            || string.Equals(eventType, "Initial Notification", StringComparison.OrdinalIgnoreCase))
        {
            var recipientRole = FormatRecipientRoles(targetRoles, cleanActivity);
            return $"{slaCategory} | Immediate Notification | {recipientRole} | {cleanEntity} | {cleanProject}";
        }

        // Generic fallback for any other SLA event
        return $"{slaCategory} | {eventType ?? "Milestone"} | {cleanEntity} | {cleanProject}";
    }

    private static string FormatRecipientRoles(IReadOnlyList<string>? roles, string activityType)
    {
        if (roles == null || roles.Count == 0)
        {
            if (activityType.Equals("Task Pause", StringComparison.OrdinalIgnoreCase))
                return "Assigned Resource";
            return "EM, PM & TL";
        }

        bool hasEm = roles.Any(r => r.Contains("Engagement", StringComparison.OrdinalIgnoreCase) || r.Equals("EM", StringComparison.OrdinalIgnoreCase));
        bool hasPm = roles.Any(r => r.Contains("Project Manager", StringComparison.OrdinalIgnoreCase) || r.Equals("PM", StringComparison.OrdinalIgnoreCase) || r.Equals("ProjectManager", StringComparison.OrdinalIgnoreCase));
        bool hasTl = roles.Any(r => r.Contains("Team Lead", StringComparison.OrdinalIgnoreCase) || r.Contains("Team Leader", StringComparison.OrdinalIgnoreCase) || r.Equals("TL", StringComparison.OrdinalIgnoreCase) || r.Equals("TeamLead", StringComparison.OrdinalIgnoreCase));

        if ((hasEm && hasPm) || (hasEm && hasTl) || (hasPm && hasTl))
        {
            return "EM, PM & TL";
        }

        if (roles.Any(r => r.Contains("Senior Project Manager", StringComparison.OrdinalIgnoreCase) || r.Equals("SeniorProjectManager", StringComparison.OrdinalIgnoreCase)))
        {
            return "Senior Project Manager";
        }

        if (roles.Any(r => r.Contains("Head of Department", StringComparison.OrdinalIgnoreCase) || r.Equals("HOD", StringComparison.OrdinalIgnoreCase)))
        {
            return "Head of Department";
        }

        if (roles.Any(r => r.Contains("Assigned Resource", StringComparison.OrdinalIgnoreCase) || r.Equals("Resource", StringComparison.OrdinalIgnoreCase)))
        {
            return "Assigned Resource";
        }

        if (roles.Any(r => r.Contains("Reporting Manager", StringComparison.OrdinalIgnoreCase)))
        {
            return "Reporting Manager";
        }

        return roles[0].Trim();
    }

    private static string? ResolveSynchronously(
        DashboardContext? context,
        Guid instanceId,
        Guid eventId,
        int? escalationLevel,
        string methodName)
    {
        AppDbContext? db = null;
        IServiceScope? scope = null;

        try
        {
            var httpContext = context?.GetHttpContext();
            if (httpContext != null)
            {
                db = httpContext.RequestServices.GetService<AppDbContext>();
            }

            if (db == null && s_scopeFactory != null)
            {
                scope = s_scopeFactory.CreateScope();
                db = scope.ServiceProvider.GetService<AppDbContext>();
            }

            if (db == null)
            {
                return null;
            }

            return Task.Run(() => ResolveFromDbAsync(db, instanceId, eventId, escalationLevel, methodName))
                .GetAwaiter()
                .GetResult();
        }
        finally
        {
            scope?.Dispose();
        }
    }

    private static async Task<string?> ResolveFromDbAsync(
        AppDbContext db,
        Guid instanceId,
        Guid eventId,
        int? escalationLevel,
        string methodName)
    {
        var instance = await db.SlaInstances
            .AsNoTracking()
            .FirstOrDefaultAsync(i => i.Id == instanceId);

        if (instance == null) return null;

        var eventRecord = await db.SlaEvents
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == eventId);

        // Resolve Project Name
        string projectName = "Project";
        if (instance.ProjectId.HasValue)
        {
            var pName = await db.Projects
                .AsNoTracking()
                .Where(p => p.Id == instance.ProjectId.Value && p.DeletedAtUtc == null)
                .Select(p => p.Name)
                .FirstOrDefaultAsync();

            if (!string.IsNullOrWhiteSpace(pName))
            {
                projectName = pName;
            }
        }

        // Resolve Entity Title
        string entityTitle = instance.EntityReference ?? string.Empty;

        if (instance.ActivityType.Contains("Task", StringComparison.OrdinalIgnoreCase))
        {
            var assignment = await db.ProjectTaskAssignments
                .AsNoTracking()
                .Include(a => a.Task)
                    .ThenInclude(t => t!.Project)
                .FirstOrDefaultAsync(a => a.Id == instance.EntityId && a.DeletedAtUtc == null);

            if (assignment?.Task != null)
            {
                if (!string.IsNullOrWhiteSpace(assignment.Task.Title))
                    entityTitle = assignment.Task.Title;

                if (projectName == "Project" && assignment.Task.Project != null && !string.IsNullOrWhiteSpace(assignment.Task.Project.Name))
                    projectName = assignment.Task.Project.Name;
            }
            else
            {
                var task = await db.ProjectTasks
                    .AsNoTracking()
                    .Include(t => t.Project)
                    .FirstOrDefaultAsync(t => t.Id == instance.EntityId && t.DeletedAtUtc == null);

                if (task != null)
                {
                    if (!string.IsNullOrWhiteSpace(task.Title))
                        entityTitle = task.Title;

                    if (projectName == "Project" && task.Project != null && !string.IsNullOrWhiteSpace(task.Project.Name))
                        projectName = task.Project.Name;
                }
            }
        }
        else if (instance.ActivityType.Contains("Issue", StringComparison.OrdinalIgnoreCase) ||
                 instance.ActivityType.Equals("Resolution of Issues", StringComparison.OrdinalIgnoreCase))
        {
            var issue = await db.ProjectIssues
                .AsNoTracking()
                .Include(i => i.Project)
                .FirstOrDefaultAsync(i => i.Id == instance.EntityId && i.DeletedAtUtc == null);

            if (issue != null)
            {
                if (!string.IsNullOrWhiteSpace(issue.Subject))
                    entityTitle = issue.Subject;

                if (projectName == "Project" && issue.Project != null && !string.IsNullOrWhiteSpace(issue.Project.Name))
                    projectName = issue.Project.Name;
            }
        }
        else if (instance.ActivityType.Contains("WBS", StringComparison.OrdinalIgnoreCase) ||
                 instance.ActivityType.Contains("Service Escalation", StringComparison.OrdinalIgnoreCase))
        {
            var esc = await db.ProjectServiceEscalations
                .AsNoTracking()
                .Include(e => e.Project)
                .FirstOrDefaultAsync(e => e.Id == instance.EntityId && e.DeletedAtUtc == null);

            if (esc != null)
            {
                if (!string.IsNullOrWhiteSpace(esc.Subject))
                    entityTitle = esc.Subject;

                if (projectName == "Project" && esc.Project != null && !string.IsNullOrWhiteSpace(esc.Project.Name))
                    projectName = esc.Project.Name;
            }
        }
        else if (instance.ActivityType.Contains("Extension", StringComparison.OrdinalIgnoreCase))
        {
            var ext = await db.ProjectExtensionRequests
                .AsNoTracking()
                .Include(e => e.Project)
                .FirstOrDefaultAsync(e => e.Id == instance.EntityId && e.DeletedAtUtc == null);

            if (ext != null)
            {
                entityTitle = !string.IsNullOrWhiteSpace(instance.EntityReference)
                    ? instance.EntityReference
                    : $"EXT-{ext.Id.ToString("N")[..8].ToUpperInvariant()}";

                if (projectName == "Project" && ext.Project != null && !string.IsNullOrWhiteSpace(ext.Project.Name))
                    projectName = ext.Project.Name;
            }
            else if (!string.IsNullOrWhiteSpace(instance.EntityReference))
            {
                entityTitle = instance.EntityReference;
            }
        }
        else if (instance.ActivityType.Contains("Requirement", StringComparison.OrdinalIgnoreCase))
        {
            var req = await db.ProjectAdditionalRequirements
                .AsNoTracking()
                .Include(r => r.Project)
                .FirstOrDefaultAsync(r => r.Id == instance.EntityId && r.DeletedAtUtc == null);

            if (req != null)
            {
                entityTitle = !string.IsNullOrWhiteSpace(req.RequirementId)
                    ? req.RequirementId
                    : $"APP-{req.Id.ToString("N")[..8].ToUpperInvariant()}";

                if (projectName == "Project" && req.Project != null && !string.IsNullOrWhiteSpace(req.Project.Name))
                    projectName = req.Project.Name;
            }
            else if (!string.IsNullOrWhiteSpace(instance.EntityReference))
            {
                entityTitle = instance.EntityReference;
            }
        }

        if (string.IsNullOrWhiteSpace(entityTitle))
        {
            entityTitle = instance.EntityReference ?? "Item";
        }

        string eventTypeStr = eventRecord?.EventType.ToString() ?? methodName switch
        {
            nameof(SlaBackgroundJobWorker.ExecuteBreachCheckAsync) => nameof(SlaEventType.BreachCheck),
            nameof(SlaBackgroundJobWorker.ExecuteReminderAsync) => nameof(SlaEventType.Reminder),
            nameof(SlaBackgroundJobWorker.ExecuteEscalationAsync) => escalationLevel == 2 ? nameof(SlaEventType.EscalationL2) : nameof(SlaEventType.EscalationL1),
            _ => "Job"
        };

        int? effectiveLevel = escalationLevel;
        if (!effectiveLevel.HasValue)
        {
            if (eventRecord?.EventType == SlaEventType.EscalationL1) effectiveLevel = 1;
            else if (eventRecord?.EventType == SlaEventType.EscalationL2) effectiveLevel = 2;
        }

        return BuildJobName(
            instance.ActivityType,
            eventTypeStr,
            effectiveLevel,
            entityTitle,
            projectName,
            eventRecord?.TargetRoles);
    }

    private static async Task PrewarmCacheAsync()
    {
        if (s_scopeFactory == null) return;
        using var scope = s_scopeFactory.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        // Query all SLA events that have a HangfireJobId
        var eventsWithJobs = await db.SlaEvents
            .AsNoTracking()
            .Where(e => e.HangfireJobId != null && e.DeletedAtUtc == null)
            .Select(e => new
            {
                EventId = e.Id,
                InstanceId = e.InstanceId,
                EventType = e.EventType,
                TargetRolesJson = e.TargetRolesJson,
                ActivityType = e.Instance != null ? e.Instance.ActivityType : string.Empty,
                EntityId = e.Instance != null ? e.Instance.EntityId : Guid.Empty,
                EntityReference = e.Instance != null ? e.Instance.EntityReference : string.Empty,
                ProjectId = e.Instance != null ? e.Instance.ProjectId : null
            })
            .ToListAsync();

        if (eventsWithJobs.Count == 0) return;

        // Collect all distinct project IDs to fetch project names in a single batch
        var projectIds = eventsWithJobs
            .Where(x => x.ProjectId.HasValue)
            .Select(x => x.ProjectId!.Value)
            .Distinct()
            .ToList();

        var projectDict = await db.Projects
            .AsNoTracking()
            .Where(p => projectIds.Contains(p.Id) && p.DeletedAtUtc == null)
            .ToDictionaryAsync(p => p.Id, p => p.Name);

        // Collect all task assignment IDs to fetch task titles in a single batch
        var assignmentIds = eventsWithJobs
            .Where(x => x.ActivityType.Contains("Task", StringComparison.OrdinalIgnoreCase))
            .Select(x => x.EntityId)
            .Distinct()
            .ToList();

        var taskTitles = await db.ProjectTaskAssignments
            .AsNoTracking()
            .Where(a => assignmentIds.Contains(a.Id) && a.Task != null && a.DeletedAtUtc == null)
            .ToDictionaryAsync(a => a.Id, a => a.Task!.Title);

        // Collect issue IDs to fetch issue subjects in a single batch
        var issueIds = eventsWithJobs
            .Where(x => x.ActivityType.Contains("Issue", StringComparison.OrdinalIgnoreCase) || x.ActivityType.Equals("Resolution of Issues", StringComparison.OrdinalIgnoreCase))
            .Select(x => x.EntityId)
            .Distinct()
            .ToList();

        var issueTitles = await db.ProjectIssues
            .AsNoTracking()
            .Where(i => issueIds.Contains(i.Id) && i.DeletedAtUtc == null)
            .ToDictionaryAsync(i => i.Id, i => i.Subject);

        // Populate cache
        foreach (var ev in eventsWithJobs)
        {
            string projectName = ev.ProjectId.HasValue && projectDict.TryGetValue(ev.ProjectId.Value, out var pName)
                ? pName
                : "Project";

            string entityTitle = ev.EntityReference;
            if (taskTitles.TryGetValue(ev.EntityId, out var tTitle) && !string.IsNullOrWhiteSpace(tTitle))
            {
                entityTitle = tTitle;
            }
            else if (issueTitles.TryGetValue(ev.EntityId, out var iSubject) && !string.IsNullOrWhiteSpace(iSubject))
            {
                entityTitle = iSubject;
            }

            int? level = ev.EventType switch
            {
                SlaEventType.EscalationL1 => 1,
                SlaEventType.EscalationL2 => 2,
                _ => null
            };

            List<string>? targetRoles = null;
            if (!string.IsNullOrWhiteSpace(ev.TargetRolesJson) && ev.TargetRolesJson != "[]")
            {
                try
                {
                    targetRoles = JsonSerializer.Deserialize<List<string>>(ev.TargetRolesJson);
                }
                catch
                {
                    // Ignore deserialization error
                }
            }

            var jobName = BuildJobName(
                ev.ActivityType,
                ev.EventType.ToString(),
                level,
                entityTitle,
                projectName,
                targetRoles);

            s_cache[(ev.InstanceId, ev.EventId)] = jobName;
        }

        s_logger?.LogInformation("[SLA DisplayName] Successfully pre-warmed {Count} Hangfire SLA job descriptions.", eventsWithJobs.Count);
    }

    private static bool TryParseGuid(object? value, out Guid guid)
    {
        guid = Guid.Empty;
        if (value is Guid g)
        {
            guid = g;
            return true;
        }

        if (value is string s && Guid.TryParse(s, out var parsed))
        {
            guid = parsed;
            return true;
        }

        return false;
    }
}
