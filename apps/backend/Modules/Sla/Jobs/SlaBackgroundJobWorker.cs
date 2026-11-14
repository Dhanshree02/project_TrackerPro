using System.ComponentModel;
using System.Text.Json;
using Hangfire;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Sla.Models;
using PMS.API.Modules.Sla.Services;

namespace PMS.API.Modules.Sla.Jobs;

/// <summary>
/// Hangfire background job worker that processes scheduled SLA reminders,
/// breach checks, and multi-level escalations for Issues, Task Start, Task Deadline, and Task Pause.
/// Protected by distributed concurrency lock and database-level idempotency guards.
/// </summary>
[DisableConcurrentExecution(timeoutInSeconds: 60)]
public sealed class SlaBackgroundJobWorker(
    AppDbContext db,
    ISlaRecipientResolver recipientResolver,
    ISlaDeadlineCalculator deadlineCalculator,
    ILogger<SlaBackgroundJobWorker> logger)
{
    [DisplayName("SLA Reminder Job: Instance {0}, Event {1}")]
    public async Task ExecuteReminderAsync(Guid instanceId, Guid eventId)
    {
        var (instance, eventRecord) = await LoadAndValidateAsync(instanceId, eventId, SlaEventType.Reminder);
        if (instance == null || eventRecord == null) return;

        if (string.Equals(instance.ActivityType, "Task Deadline", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteTaskDeadlineReminderAsync(instance, eventRecord);
        }
        else if (string.Equals(instance.ActivityType, "Task Pause", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteTaskPauseReminderAsync(instance, eventRecord);
        }
        else if (string.Equals(instance.ActivityType, "Extension Request", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Timeline Extension Approval", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Project Extension Request", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteExtensionRequestReminderAsync(instance, eventRecord);
        }
        else
        {
            await ExecuteIssueReminderAsync(instance, eventRecord);
        }
    }

    [DisplayName("SLA Breach Check Job: Instance {0}, Event {1}")]
    public async Task ExecuteBreachCheckAsync(Guid instanceId, Guid eventId)
    {
        var (instance, eventRecord) = await LoadAndValidateAsync(instanceId, eventId, SlaEventType.BreachCheck);
        if (instance == null || eventRecord == null) return;

        if (string.Equals(instance.ActivityType, "Task Start After Assigning", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteTaskStartBreachCheckAsync(instance, eventRecord);
        }
        else if (string.Equals(instance.ActivityType, "Task Deadline", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteTaskDeadlineBreachCheckAsync(instance, eventRecord);
        }
        else if (string.Equals(instance.ActivityType, "WBS Escalation", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Service Escalation", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteWbsBreachCheckAsync(instance, eventRecord);
        }
        else if (string.Equals(instance.ActivityType, "Extension Request", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Timeline Extension Approval", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Project Extension Request", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteExtensionRequestBreachCheckAsync(instance, eventRecord);
        }
        else if (string.Equals(instance.ActivityType, "Additional Customer Requirement", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Customer Requirement Approval", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Customer Requirement", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteAdditionalRequirementBreachCheckAsync(instance, eventRecord);
        }
        else if (instance.ActivityType.Contains("Resource Allocation", StringComparison.OrdinalIgnoreCase)
                 || instance.ActivityType.Contains("Team Member Allocation", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteResourceAllocationBreachCheckAsync(instance, eventRecord);
        }
        else
        {
            await ExecuteIssueBreachCheckAsync(instance, eventRecord);
        }
    }

    [DisplayName("SLA Escalation Job: Instance {0}, Event {1}, Level {2}")]
    public async Task ExecuteEscalationAsync(Guid instanceId, Guid eventId, int level)
    {
        var expectedType = level == 1 ? SlaEventType.EscalationL1 : SlaEventType.EscalationL2;
        var (instance, eventRecord) = await LoadAndValidateAsync(instanceId, eventId, expectedType);
        if (instance == null || eventRecord == null) return;

        if (string.Equals(instance.ActivityType, "Task Start After Assigning", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteTaskStartEscalationAsync(instance, eventRecord, level);
        }
        else if (string.Equals(instance.ActivityType, "Task Deadline", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteTaskDeadlineEscalationAsync(instance, eventRecord, level);
        }
        else if (string.Equals(instance.ActivityType, "WBS Escalation", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Service Escalation", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteWbsEscalationAsync(instance, eventRecord, level);
        }
        else if (string.Equals(instance.ActivityType, "Extension Request", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Timeline Extension Approval", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Project Extension Request", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteExtensionRequestEscalationAsync(instance, eventRecord, level);
        }
        else if (string.Equals(instance.ActivityType, "Additional Customer Requirement", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Customer Requirement Approval", StringComparison.OrdinalIgnoreCase)
                 || string.Equals(instance.ActivityType, "Customer Requirement", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteAdditionalRequirementEscalationAsync(instance, eventRecord, level);
        }
        else if (instance.ActivityType.Contains("Resource Allocation", StringComparison.OrdinalIgnoreCase)
                 || instance.ActivityType.Contains("Team Member Allocation", StringComparison.OrdinalIgnoreCase))
        {
            await ExecuteResourceAllocationEscalationAsync(instance, eventRecord, level);
        }
        else
        {
            await ExecuteIssueEscalationAsync(instance, eventRecord, level);
        }
    }

    #region Activity: Issue Resolution Handlers

    private async Task ExecuteIssueReminderAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var issue = await db.ProjectIssues
            .FirstOrDefaultAsync(i => i.Id == instance.EntityId && i.DeletedAtUtc == null);

        if (issue == null || issue.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) || issue.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase))
        {
            logger.LogInformation(
                "[SLA Worker] Issue {IssueId} is already {Status}. Completing SLA instance.",
                instance.EntityId,
                issue?.Status ?? "not found");

            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Issue already {issue?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        var targetRoles = eventRecord.TargetRoles.Count > 0
            ? eventRecord.TargetRoles
            : ["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"];

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var now = DateTime.UtcNow;
        var reminderTitle = $"Daily Reminder: Issue Pending Resolution - {issue.Subject}";

        foreach (var recipientId in recipientIds)
        {
            var alreadyNotified = await db.ActionNotifications.AnyAsync(n =>
                n.IssueId == issue.Id &&
                n.RecipientEmployeeId == recipientId &&
                n.Title == reminderTitle &&
                n.CreatedAtUtc >= now.Date &&
                n.DeletedAtUtc == null);

            if (!alreadyNotified)
            {
                db.ActionNotifications.Add(new ActionNotification
                {
                    RecipientEmployeeId = recipientId,
                    ProjectId = instance.ProjectId,
                    ProjectCode = issue.ProjectCode,
                    ProjectName = issue.ProjectName,
                    Title = reminderTitle,
                    Type = "Issue Daily Reminder",
                    Priority = issue.Priority ?? "High",
                    Status = "Pending",
                    Unread = true,
                    RelatedTask = issue.IssueType,
                    Issue = issue,
                    CreatedAtUtc = now
                });
            }
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"Daily reminder sent to {recipientIds.Count} recipients (Roles: [{string.Join(", ", targetRoles)}]).";

        if (instance.Status == SlaInstanceStatus.Tracking || instance.Status == SlaInstanceStatus.Breached)
        {
            var holidays = await db.LeaveCalendarHolidays
                .AsNoTracking()
                .Where(h => h.DeletedAtUtc == null)
                .Select(h => h.HolidayDate)
                .ToHashSetAsync();

            var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);
            var nextReminderTime = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(now, holidays, policy?.WorkingHoursEnd);
            var nextReminderKey = $"sla:{instance.Id}:rem:{nextReminderTime:yyyy-MM-dd}";

            var exists = await db.SlaEvents.AnyAsync(e => e.IdempotencyKey == nextReminderKey && e.DeletedAtUtc == null);
            if (!exists)
            {
                var nextReminderEvent = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.Reminder,
                    ScheduledAtUtc = nextReminderTime,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = targetRoles,
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = nextReminderKey
                };
                db.SlaEvents.Add(nextReminderEvent);
                await db.SaveChangesAsync();

                var delay = nextReminderTime > now ? nextReminderTime - now : TimeSpan.FromDays(1);
                var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    w => w.ExecuteReminderAsync(instance.Id, nextReminderEvent.Id),
                    delay);
                nextReminderEvent.HangfireJobId = jobId;
            }
        }

        await db.SaveChangesAsync();
    }

    private async Task ExecuteIssueBreachCheckAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var issue = await db.ProjectIssues
            .FirstOrDefaultAsync(i => i.Id == instance.EntityId && i.DeletedAtUtc == null);

        if (issue == null || issue.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) || issue.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Issue already {issue?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (DateTime.UtcNow >= instance.TargetDeadlineUtc && instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;

            logger.LogWarning(
                "[SLA Worker] SLA BREACH DETECTED for Instance {InstanceId} ({ActivityType}, Stage: {Stage}). TargetDeadline: {Deadline:u}, BreachedAt: {BreachedAt:u}",
                instance.Id,
                instance.ActivityType,
                instance.CurrentStage,
                instance.TargetDeadlineUtc,
                instance.BreachedAtUtc);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = DateTime.UtcNow;
        eventRecord.ExecutionLog = $"Breach check executed. Instance status: {instance.Status}. BreachedAt: {instance.BreachedAtUtc:u}";

        await db.SaveChangesAsync();
    }

    private async Task ExecuteIssueEscalationAsync(SlaInstance instance, SlaEvent eventRecord, int level)
    {
        var issue = await db.ProjectIssues
            .FirstOrDefaultAsync(i => i.Id == instance.EntityId && i.DeletedAtUtc == null);

        if (issue == null || issue.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) || issue.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Issue already {issue?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
        }

        var targetRoles = level == 1
            ? (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Assigned Senior Project Manager"])
            : (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Head of Department"]);

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var now = DateTime.UtcNow;
        var nowIst = TimeZoneInfo.ConvertTimeFromUtc(now, SlaDeadlineCalculator.IndianTimeZone);
        var dateStr = nowIst.ToString("yyyy-MM-dd");
        var timeStr = nowIst.ToString("HH:mm:ss");

        var levelLabel = level == 1 ? "Level 1 SLA Escalation (Assigned Senior Project Manager)" : "Level 2 SLA Escalation (Head of Department)";
        var notificationTitle = $"{levelLabel}: Issue Pending Resolution - {issue.Subject}";

        var recipientEmployees = await db.Employees
            .AsNoTracking()
            .Where(e => recipientIds.Contains(e.Id))
            .ToListAsync();

        foreach (var recipientId in recipientIds)
        {
            var alreadyNotified = await db.ActionNotifications.AnyAsync(n =>
                n.IssueId == issue.Id &&
                n.RecipientEmployeeId == recipientId &&
                n.Title == notificationTitle &&
                n.DeletedAtUtc == null);

            if (!alreadyNotified)
            {
                db.ActionNotifications.Add(new ActionNotification
                {
                    RecipientEmployeeId = recipientId,
                    ProjectId = instance.ProjectId,
                    ProjectCode = issue.ProjectCode,
                    ProjectName = issue.ProjectName,
                    Title = notificationTitle,
                    Type = "SLA Escalation",
                    Priority = "Critical",
                    Status = "Pending",
                    Unread = true,
                    RaisedByName = string.IsNullOrWhiteSpace(issue.RaisedByName) ? "SLA Automation Engine" : issue.RaisedByName,
                    RaisedByEmployeeId = issue.RaisedByEmployeeId,
                    RelatedTask = issue.IssueType,
                    IssueId = issue.Id,
                    Issue = issue,
                    CreatedAtUtc = now
                });
            }
        }

        var alerts = await db.ProjectAlerts
            .Where(a => a.IssueId == issue.Id && a.DeletedAtUtc == null)
            .ToListAsync();

        if (alerts.Count == 0 && !string.IsNullOrWhiteSpace(instance.CustomPayloadJson))
        {
            try
            {
                using var doc = JsonDocument.Parse(instance.CustomPayloadJson);
                if (doc.RootElement.TryGetProperty("alertId", out var alertIdProp) && alertIdProp.TryGetGuid(out var aId))
                {
                    var fallbackAlert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.Id == aId && a.DeletedAtUtc == null);
                    if (fallbackAlert != null) alerts.Add(fallbackAlert);
                }
            }
            catch { }
        }

        var targetRoleName = level == 1 ? "Assigned Senior Project Manager" : "Head of Department";
        var recipientNamesList = recipientEmployees
            .Select(e => $"{e.FirstName} {e.LastName}".Trim())
            .Where(n => !string.IsNullOrWhiteSpace(n))
            .Distinct()
            .ToList();
        var recipientNamesStr = string.Join(", ", recipientNamesList);

        foreach (var alert in alerts)
        {
            // 1. Add recipient IDs to AudienceUserIds so they receive the Alert request in their Alert tab
            var audienceSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (!string.IsNullOrWhiteSpace(alert.AudienceUserIds))
            {
                try
                {
                    var parsedList = JsonSerializer.Deserialize<List<string>>(alert.AudienceUserIds);
                    if (parsedList != null)
                    {
                        foreach (var id in parsedList)
                        {
                            if (!string.IsNullOrWhiteSpace(id)) audienceSet.Add(id.Trim());
                        }
                    }
                }
                catch
                {
                    var parts = alert.AudienceUserIds.Split([',', ';', '[', ']', '"'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
                    foreach (var part in parts) audienceSet.Add(part);
                }
            }
            foreach (var rId in recipientIds)
            {
                audienceSet.Add(rId.ToString());
            }
            foreach (var emp in recipientEmployees)
            {
                if (emp.UserId.HasValue) audienceSet.Add(emp.UserId.Value.ToString());
            }
            alert.AudienceUserIds = JsonSerializer.Serialize(audienceSet.ToList());

            // 2. Add recipient names to EscalatedTo
            var escalatedToNames = new List<string>();
            if (!string.IsNullOrWhiteSpace(alert.EscalatedTo))
            {
                try
                {
                    var parsedNames = JsonSerializer.Deserialize<List<string>>(alert.EscalatedTo);
                    if (parsedNames != null) escalatedToNames.AddRange(parsedNames);
                }
                catch
                {
                    var parts = alert.EscalatedTo.Split([',', ';', '[', ']', '"'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
                    escalatedToNames.AddRange(parts);
                }
            }
            foreach (var name in recipientNamesList)
            {
                if (!escalatedToNames.Contains(name, StringComparer.OrdinalIgnoreCase))
                {
                    escalatedToNames.Add(name);
                }
            }
            alert.EscalatedTo = JsonSerializer.Serialize(escalatedToNames);

            // 3. Append to HistoryJson
            var history = string.IsNullOrWhiteSpace(alert.HistoryJson)
                ? []
                : (JsonSerializer.Deserialize<List<NotificationHistoryItemDto>>(alert.HistoryJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? []);

            var actionDesc = !string.IsNullOrWhiteSpace(recipientNamesStr)
                ? $"{levelLabel}: Alert assigned to {targetRoleName} ({recipientNamesStr})"
                : levelLabel;

            history.Add(new NotificationHistoryItemDto
            {
                Action = actionDesc,
                Date = dateStr,
                Time = timeStr,
                By = "SLA Automation Engine"
            });

            alert.HistoryJson = JsonSerializer.Serialize(history);
            alert.Priority = "Critical";
            alert.UpdatedAtUtc = now;

            // 4. Update linked ProjectServiceEscalation and add stakeholders
            ProjectServiceEscalation? serviceEscalation = null;
            if (alert.ServiceEscalationId.HasValue)
            {
                serviceEscalation = await db.ProjectServiceEscalations
                    .Include(e => e.Stakeholders)
                    .FirstOrDefaultAsync(e => e.Id == alert.ServiceEscalationId.Value);
            }
            if (serviceEscalation == null && instance.ProjectId.HasValue)
            {
                serviceEscalation = await db.ProjectServiceEscalations
                    .Include(e => e.Stakeholders)
                    .FirstOrDefaultAsync(e => e.ProjectId == instance.ProjectId.Value && e.Subject == issue.Subject);
            }

            if (serviceEscalation != null)
            {
                serviceEscalation.Priority = "Critical";
                serviceEscalation.UpdatedAtUtc = now;

                foreach (var emp in recipientEmployees)
                {
                    if (!serviceEscalation.Stakeholders.Any(s => s.EmployeeId == emp.Id))
                    {
                        var subDept = emp.SubDepartment?.Trim();
                        if (string.IsNullOrWhiteSpace(subDept))
                        {
                            subDept = level == 1 ? "Senior Project Management" : "Department Head";
                        }

                        var newStakeholder = new ProjectServiceEscalationStakeholder
                        {
                            EscalationId = serviceEscalation.Id,
                            EmployeeId = emp.Id,
                            EmployeeName = $"{emp.FirstName} {emp.LastName}".Trim(),
                            SubDepartment = subDept,
                            Status = "Pending"
                        };
                        serviceEscalation.Stakeholders.Add(newStakeholder);
                        db.ProjectServiceEscalationStakeholders.Add(newStakeholder);
                    }
                }

                // Sync ChatJson between alert and serviceEscalation
                if (!string.IsNullOrWhiteSpace(alert.ChatJson) && string.IsNullOrWhiteSpace(serviceEscalation.ChatJson))
                {
                    serviceEscalation.ChatJson = alert.ChatJson;
                }
                else if (!string.IsNullOrWhiteSpace(serviceEscalation.ChatJson) && string.IsNullOrWhiteSpace(alert.ChatJson))
                {
                    alert.ChatJson = serviceEscalation.ChatJson;
                }
            }
        }

        var firstAlertHistory = alerts.FirstOrDefault()?.HistoryJson;
        if (!string.IsNullOrWhiteSpace(firstAlertHistory))
        {
            var notifsToUpdate = await db.ActionNotifications
                .Where(n => n.IssueId == issue.Id && recipientIds.Contains(n.RecipientEmployeeId) && n.DeletedAtUtc == null)
                .ToListAsync();
            foreach (var n in notifsToUpdate)
            {
                n.HistoryJson = firstAlertHistory;
            }
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"{levelLabel} executed at {now:u}. Dispatched Critical escalation notification & alert request to {recipientIds.Count} recipients.";

        if (level == 1)
        {
            var l2Key = $"sla:{instance.Id}:esc-l2";
            var l2Exists = await db.SlaEvents
                .AnyAsync(e => (e.IdempotencyKey == l2Key || (e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2))
                               && e.Status != SlaEventStatus.Skipped
                               && e.Status != SlaEventStatus.Cancelled
                               && e.DeletedAtUtc == null);

            if (!l2Exists)
            {
                var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);

                var holidays = await db.LeaveCalendarHolidays
                    .AsNoTracking()
                    .Where(h => h.DeletedAtUtc == null)
                    .Select(h => h.HolidayDate)
                    .ToHashSetAsync();

                var l2DeadlineUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(now, holidays, policy?.WorkingHoursEnd);
                var l2Delay = l2DeadlineUtc > now ? l2DeadlineUtc - now : TimeSpan.FromHours(24);

                var l2Event = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL2,
                    ScheduledAtUtc = l2DeadlineUtc,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = ["Head of Department"],
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = l2Key
                };
                db.SlaEvents.Add(l2Event);
                await db.SaveChangesAsync();

                var l2JobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    w => w.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2),
                    l2Delay);
                l2Event.HangfireJobId = l2JobId;
            }
        }

        await db.SaveChangesAsync();
    }

    #endregion

    #region Activity: Task Start After Assigning Handlers

    private async Task ExecuteTaskStartBreachCheckAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var assignment = await db.ProjectTaskAssignments
            .AsNoTracking()
            .Include(a => a.Task)
            .FirstOrDefaultAsync(a => a.Id == instance.EntityId && a.DeletedAtUtc == null);

        if (assignment == null || !assignment.IsActive)
        {
            instance.Status = SlaInstanceStatus.Cancelled;
            instance.CancelledAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Assignment removed or inactive. SLA tracking cancelled.";
            await db.SaveChangesAsync();
            return;
        }

        var bucketTask = await db.BucketTasks
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.AssignmentId == assignment.Id && b.DeletedAtUtc == null);

        bool hasStarted = assignment.TimerStartedAtUtc.HasValue ||
                          assignment.TimerAccumulatedSeconds > 0 ||
                          (bucketTask != null && (bucketTask.TimerRunning ||
                                                  bucketTask.TimerAccumulatedSeconds > 0 ||
                                                  bucketTask.ActualStartDate != null ||
                                                  bucketTask.Status == "Ongoing" ||
                                                  bucketTask.Status == "Paused" ||
                                                  bucketTask.Status == "Completed"));

        if (hasStarted)
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Resource has already started the task. SLA tracking completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (DateTime.UtcNow >= instance.TargetDeadlineUtc && instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;

            logger.LogWarning(
                "[SLA Worker] TASK START BREACH DETECTED for Assignment {AssignmentId} ({TaskTitle}). Deadline: {Deadline:u}",
                instance.EntityId,
                assignment.Task?.Title,
                instance.TargetDeadlineUtc);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = DateTime.UtcNow;
        eventRecord.ExecutionLog = $"Task Start breach check executed. Status: {instance.Status}.";
        await db.SaveChangesAsync();
    }

    private async Task ExecuteTaskStartEscalationAsync(SlaInstance instance, SlaEvent eventRecord, int level)
    {
        var assignment = await db.ProjectTaskAssignments
            .AsNoTracking()
            .Include(a => a.Task)
                .ThenInclude(t => t!.Project)
            .Include(a => a.Employee)
            .FirstOrDefaultAsync(a => a.Id == instance.EntityId && a.DeletedAtUtc == null);

        if (assignment == null || !assignment.IsActive)
        {
            instance.Status = SlaInstanceStatus.Cancelled;
            instance.CancelledAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Assignment removed or inactive. SLA tracking cancelled.";
            await db.SaveChangesAsync();
            return;
        }

        var bucketTask = await db.BucketTasks
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.AssignmentId == assignment.Id && b.DeletedAtUtc == null);

        bool hasStarted = assignment.TimerStartedAtUtc.HasValue ||
                          assignment.TimerAccumulatedSeconds > 0 ||
                          (bucketTask != null && (bucketTask.TimerRunning ||
                                                  bucketTask.TimerAccumulatedSeconds > 0 ||
                                                  bucketTask.ActualStartDate != null ||
                                                  bucketTask.Status == "Ongoing" ||
                                                  bucketTask.Status == "Paused" ||
                                                  bucketTask.Status == "Completed"));

        if (hasStarted)
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Resource {assignment.Employee?.FirstName} already started task. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
        }

        var targetRoles = level == 1
            ? (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Assigned Senior Project Manager"])
            : (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Head of Department"]);

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var now = DateTime.UtcNow;
        var resourceName = assignment.Employee != null ? $"{assignment.Employee.FirstName} {assignment.Employee.LastName}".Trim() : "Assigned Resource";
        var taskTitle = assignment.Task?.Title ?? "Task";
        var projectName = assignment.Task?.Project?.Name ?? "Project";

        string notificationTitle;
        string notificationContent;

        if (level == 1)
        {
            notificationTitle = $"Task Start SLA Breach - First Level Escalation: {taskTitle}";
            notificationContent = $"Task '{taskTitle}' has not been started by {resourceName} by the end of the assignment day. This task has been escalated to the Assigned Senior Project Manager.";
        }
        else
        {
            notificationTitle = $"Task Start SLA Breach - Second Level Escalation: {taskTitle}";
            notificationContent = $"Task '{taskTitle}' remains unstarted by {resourceName} after the first-level escalation. This task has been escalated to the Head of Department.";
        }

        foreach (var recipientId in recipientIds)
        {
            var alreadyNotified = await db.ActionNotifications.AnyAsync(n =>
                n.RecipientEmployeeId == recipientId &&
                n.Title == notificationTitle &&
                n.RelatedTask == taskTitle &&
                n.DeletedAtUtc == null);

            if (!alreadyNotified)
            {
                db.ActionNotifications.Add(new ActionNotification
                {
                    RecipientEmployeeId = recipientId,
                    ProjectId = instance.ProjectId,
                    ProjectCode = assignment.Task?.Project?.ProjectCode,
                    ProjectName = projectName,
                    Title = notificationTitle,
                    Type = "SLA Escalation",
                    Priority = "Critical",
                    Status = "Pending",
                    Unread = true,
                    RelatedTask = taskTitle,
                    RaisedByName = "SLA Automation Engine",
                    CreatedAtUtc = now,
                    CommentsJson = JsonSerializer.Serialize(new[]
                    {
                        new { text = notificationContent, by = "SLA Automation Engine", at = now.ToString("o") }
                    })
                });
            }
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"Level {level} Escalation executed at {now:u}. Dispatched to {recipientIds.Count} recipients.";

        // Dynamic Level 2 Scheduling on actual Level 1 execution
        if (level == 1)
        {
            var l2Key = $"sla:{instance.Id}:esc-l2";
            var l2Exists = await db.SlaEvents
                .AnyAsync(e => (e.IdempotencyKey == l2Key || (e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2))
                               && e.Status != SlaEventStatus.Skipped
                               && e.Status != SlaEventStatus.Cancelled
                               && e.DeletedAtUtc == null);

            if (!l2Exists)
            {
                var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);
                var holidays = await db.LeaveCalendarHolidays
                    .AsNoTracking()
                    .Where(h => h.DeletedAtUtc == null)
                    .Select(h => h.HolidayDate)
                    .ToHashSetAsync();

                var l2DeadlineUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(now, holidays, policy?.WorkingHoursEnd);
                var l2Delay = l2DeadlineUtc > now ? l2DeadlineUtc - now : TimeSpan.FromHours(24);

                var l2Event = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL2,
                    ScheduledAtUtc = l2DeadlineUtc,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = ["Head of Department"],
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = l2Key
                };
                db.SlaEvents.Add(l2Event);
                await db.SaveChangesAsync();

                var l2JobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    w => w.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2),
                    l2Delay);
                l2Event.HangfireJobId = l2JobId;
            }
        }

        await db.SaveChangesAsync();
    }

    #endregion

    #region Activity: Task Deadline Handlers

    private async Task ExecuteTaskDeadlineReminderAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var task = await db.ProjectTasks
            .Include(t => t.Project)
            .FirstOrDefaultAsync(t => t.Id == instance.EntityId && t.DeletedAtUtc == null);

        if (task == null || task.Stage.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Task already completed. Reminder skipped.";
            await db.SaveChangesAsync();
            return;
        }

        if (task.Stage.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Cancelled;
            instance.CancelledAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Task cancelled. Reminder skipped.";
            await db.SaveChangesAsync();
            return;
        }

        var targetRoles = eventRecord.TargetRoles.Count > 0
            ? eventRecord.TargetRoles
            : ["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"];

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var now = DateTime.UtcNow;
        var taskTitle = task.Title;
        var projectName = task.Project?.Name ?? "Project";
        var wbsDeadline = task.PlannedEndDate.HasValue ? task.PlannedEndDate.Value.ToString("dd-MM-yyyy") : "Scheduled Deadline";

        string reminderTitle;
        string reminderContent;

        if (eventRecord.IdempotencyKey != null && eventRecord.IdempotencyKey.Contains("midpoint"))
        {
            reminderTitle = $"Task Deadline Midpoint Reminder: {taskTitle}";
            reminderContent = $"Task '{taskTitle}' in project '{projectName}' has reached the midpoint of its planned duration. Scheduled deadline: {wbsDeadline}.";
        }
        else
        {
            reminderTitle = $"Task Deadline Approaching Reminder: {taskTitle}";
            reminderContent = $"Task '{taskTitle}' in project '{projectName}' is due tomorrow ({wbsDeadline}). Please verify completion progress.";
        }

        foreach (var recipientId in recipientIds)
        {
            var alreadyNotified = await db.ActionNotifications.AnyAsync(n =>
                n.RecipientEmployeeId == recipientId &&
                n.Title == reminderTitle &&
                n.RelatedTask == taskTitle &&
                n.DeletedAtUtc == null);

            if (!alreadyNotified)
            {
                db.ActionNotifications.Add(new ActionNotification
                {
                    RecipientEmployeeId = recipientId,
                    ProjectId = instance.ProjectId,
                    ProjectCode = task.Project?.ProjectCode,
                    ProjectName = projectName,
                    Title = reminderTitle,
                    Type = "Task Reminder",
                    Priority = task.Priority ?? "Medium",
                    Status = "Pending",
                    Unread = true,
                    RelatedTask = taskTitle,
                    RaisedByName = "SLA Automation Engine",
                    CreatedAtUtc = now,
                    CommentsJson = JsonSerializer.Serialize(new[]
                    {
                        new { text = reminderContent, by = "SLA Automation Engine", at = now.ToString("o") }
                    })
                });
            }
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"Reminder executed and dispatched to {recipientIds.Count} recipients.";
        await db.SaveChangesAsync();
    }

    private async Task ExecuteTaskDeadlineBreachCheckAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var task = await db.ProjectTasks
            .FirstOrDefaultAsync(t => t.Id == instance.EntityId && t.DeletedAtUtc == null);

        if (task == null || task.Stage.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Task already completed. SLA tracking completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (task.Stage.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Cancelled;
            instance.CancelledAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Task cancelled. SLA tracking cancelled.";
            await db.SaveChangesAsync();
            return;
        }

        if (DateTime.UtcNow >= instance.TargetDeadlineUtc && instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;

            logger.LogWarning(
                "[SLA Worker] TASK DEADLINE BREACH DETECTED for Task {TaskId} ({TaskTitle}). Deadline: {Deadline:u}",
                instance.EntityId,
                task.Title,
                instance.TargetDeadlineUtc);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = DateTime.UtcNow;
        eventRecord.ExecutionLog = $"Task Deadline breach check executed. Status: {instance.Status}.";
        await db.SaveChangesAsync();
    }

    private async Task ExecuteTaskDeadlineEscalationAsync(SlaInstance instance, SlaEvent eventRecord, int level)
    {
        var task = await db.ProjectTasks
            .Include(t => t.Project)
            .FirstOrDefaultAsync(t => t.Id == instance.EntityId && t.DeletedAtUtc == null);

        if (task == null || task.Stage.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Task is already completed. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (task.Stage.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Cancelled;
            instance.CancelledAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Task is cancelled. SLA cancelled.";
            await db.SaveChangesAsync();
            return;
        }

        if (instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
        }

        var targetRoles = level == 1
            ? (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Assigned Senior Project Manager"])
            : (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Head of Department"]);

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var now = DateTime.UtcNow;
        var taskTitle = task.Title;
        var projectName = task.Project?.Name ?? "Project";

        string notificationTitle;
        string notificationContent;

        if (level == 1)
        {
            notificationTitle = $"Task Deadline SLA Breach - First Level Escalation: {taskTitle}";
            notificationContent = $"Task '{taskTitle}' has crossed its WBS-defined deadline and remains incomplete. This task has been escalated to the Assigned Senior Project Manager.";
        }
        else
        {
            notificationTitle = $"Task Deadline SLA Breach - Second Level Escalation: {taskTitle}";
            notificationContent = $"Task '{taskTitle}' remains incomplete after the first-level escalation. This task has been escalated to the Head of Department.";
        }

        foreach (var recipientId in recipientIds)
        {
            var alreadyNotified = await db.ActionNotifications.AnyAsync(n =>
                n.RecipientEmployeeId == recipientId &&
                n.Title == notificationTitle &&
                n.RelatedTask == taskTitle &&
                n.DeletedAtUtc == null);

            if (!alreadyNotified)
            {
                db.ActionNotifications.Add(new ActionNotification
                {
                    RecipientEmployeeId = recipientId,
                    ProjectId = instance.ProjectId,
                    ProjectCode = task.Project?.ProjectCode,
                    ProjectName = projectName,
                    Title = notificationTitle,
                    Type = "SLA Escalation",
                    Priority = "Critical",
                    Status = "Pending",
                    Unread = true,
                    RelatedTask = taskTitle,
                    RaisedByName = "SLA Automation Engine",
                    CreatedAtUtc = now,
                    CommentsJson = JsonSerializer.Serialize(new[]
                    {
                        new { text = notificationContent, by = "SLA Automation Engine", at = now.ToString("o") }
                    })
                });
            }
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"Level {level} Escalation executed at {now:u}. Dispatched to {recipientIds.Count} recipients.";

        // Dynamic Level 2 Scheduling on actual Level 1 execution
        if (level == 1)
        {
            var l2Key = $"sla:{instance.Id}:esc-l2";
            var l2Exists = await db.SlaEvents
                .AnyAsync(e => (e.IdempotencyKey == l2Key || (e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2))
                               && e.Status != SlaEventStatus.Skipped
                               && e.Status != SlaEventStatus.Cancelled
                               && e.DeletedAtUtc == null);

            if (!l2Exists)
            {
                var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);
                var holidays = await db.LeaveCalendarHolidays
                    .AsNoTracking()
                    .Where(h => h.DeletedAtUtc == null)
                    .Select(h => h.HolidayDate)
                    .ToHashSetAsync();

                var l2DeadlineUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(now, holidays, policy?.WorkingHoursEnd);
                var l2Delay = l2DeadlineUtc > now ? l2DeadlineUtc - now : TimeSpan.FromHours(24);

                var l2Event = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL2,
                    ScheduledAtUtc = l2DeadlineUtc,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = ["Head of Department"],
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = l2Key
                };
                db.SlaEvents.Add(l2Event);
                await db.SaveChangesAsync();

                var l2JobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    w => w.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2),
                    l2Delay);
                l2Event.HangfireJobId = l2JobId;
            }
        }

        await db.SaveChangesAsync();
    }

    #endregion

    #region Activity: Task Pause Handlers

    private async Task ExecuteTaskPauseReminderAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        // 1. Reload latest state from DB using assignment ID (instance.EntityId)
        var assignment = await db.ProjectTaskAssignments
            .AsNoTracking()
            .Include(a => a.Task)
                .ThenInclude(t => t!.Project)
            .Include(a => a.Employee)
            .FirstOrDefaultAsync(a => a.Id == instance.EntityId && a.DeletedAtUtc == null);

        // Fallback for legacy task-level instances
        if (assignment == null)
        {
            var fallbackTask = await db.ProjectTasks.AsNoTracking().Include(t => t.Project).FirstOrDefaultAsync(t => t.Id == instance.EntityId && t.DeletedAtUtc == null);
            if (fallbackTask != null && instance.RecipientEmployeeId.HasValue)
            {
                assignment = await db.ProjectTaskAssignments
                    .AsNoTracking()
                    .Include(a => a.Task)
                        .ThenInclude(t => t!.Project)
                    .Include(a => a.Employee)
                    .FirstOrDefaultAsync(a => a.TaskId == fallbackTask.Id && a.EmployeeId == instance.RecipientEmployeeId.Value && a.DeletedAtUtc == null);
            }
        }

        if (assignment == null || !assignment.IsActive)
        {
            instance.Status = SlaInstanceStatus.Cancelled;
            instance.CancelledAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Assignment removed or inactive. Pause reminders cancelled.";
            await db.SaveChangesAsync();
            return;
        }

        var task = assignment.Task;
        if (task == null || task.Stage.Equals("Completed", StringComparison.OrdinalIgnoreCase) || task.Stage.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Task completed or cancelled. Pause reminders stopped.";
            await db.SaveChangesAsync();
            return;
        }

        var bucketTask = await db.BucketTasks
            .AsNoTracking()
            .FirstOrDefaultAsync(b => (b.AssignmentId == assignment.Id || (b.TaskId == assignment.TaskId && b.EmployeeId == assignment.EmployeeId)) && b.DeletedAtUtc == null);

        bool isNoLongerPaused = assignment.TimerStartedAtUtc.HasValue ||
                                (bucketTask != null && (bucketTask.TimerRunning || bucketTask.Status != "Paused"));

        if (isNoLongerPaused)
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = "Resource has resumed, stopped, or completed the task timer. Pause reminders stopped.";
            await db.SaveChangesAsync();
            return;
        }

        // 2. Daily reminder sent ONLY to the resource who paused the task (never to PM, EM, TL, SPM, HOD)
        var resourceId = instance.RecipientEmployeeId ?? assignment.EmployeeId;
        eventRecord.TargetRecipientIds = [resourceId];

        var now = DateTime.UtcNow;
        var taskTitle = task.Title;
        var projectName = task.Project?.Name ?? "Project";
        var reminderTitle = $"Task Paused Reminder: {taskTitle}";
        var reminderContent = $"Your task {taskTitle} is still paused. Please resume the task or complete it.";

        var alreadyNotified = await db.ActionNotifications.AnyAsync(n =>
            n.RecipientEmployeeId == resourceId &&
            n.Title == reminderTitle &&
            n.RelatedTask == taskTitle &&
            n.CreatedAtUtc >= now.Date &&
            n.DeletedAtUtc == null);

        if (!alreadyNotified)
        {
            db.ActionNotifications.Add(new ActionNotification
            {
                RecipientEmployeeId = resourceId,
                ProjectId = instance.ProjectId,
                ProjectCode = task.Project?.ProjectCode,
                ProjectName = projectName,
                Title = reminderTitle,
                Type = "Task Pause Reminder",
                Priority = task.Priority ?? "Medium",
                Status = "Pending",
                Unread = true,
                RelatedTask = taskTitle,
                RaisedByName = "SLA Automation Engine",
                CreatedAtUtc = now,
                CommentsJson = JsonSerializer.Serialize(new[]
                {
                    new { text = reminderContent, by = "SLA Automation Engine", at = now.ToString("o") }
                })
            });
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"Task Pause daily reminder sent ONLY to assigned resource {assignment.Employee?.FirstName} {assignment.Employee?.LastName}.";

        // 3. Schedule next working-day reminder aligned to this resource's shift end (General 18:00, Morning 14:00, Afternoon 22:00, Night 06:00 next day IST)
        var holidays = await db.LeaveCalendarHolidays
            .AsNoTracking()
            .Where(h => h.DeletedAtUtc == null)
            .Select(h => h.HolidayDate)
            .ToHashSetAsync();

        var nextReminderTime = await deadlineCalculator.CalculateNextPauseReminderForEmployeeAsync(
            now.AddMinutes(5),
            resourceId,
            holidays);

        var nextReminderKey = $"sla:{instance.Id}:rem:{nextReminderTime:yyyy-MM-dd-HH-mm}";

        var exists = await db.SlaEvents.AnyAsync(e => e.IdempotencyKey == nextReminderKey && e.DeletedAtUtc == null);
        if (!exists && nextReminderTime > now)
        {
            var nextReminderEvent = new SlaEvent
            {
                InstanceId = instance.Id,
                EventType = SlaEventType.Reminder,
                ScheduledAtUtc = nextReminderTime,
                StageAtExecution = instance.CurrentStage,
                TargetRoles = ["Assigned Resource"],
                TargetRecipientIds = [resourceId],
                Status = SlaEventStatus.Scheduled,
                IdempotencyKey = nextReminderKey
            };
            db.SlaEvents.Add(nextReminderEvent);
            await db.SaveChangesAsync();

            var delay = nextReminderTime - now;
            var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                w => w.ExecuteReminderAsync(instance.Id, nextReminderEvent.Id),
                delay);
            nextReminderEvent.HangfireJobId = jobId;
        }

        await db.SaveChangesAsync();
    }

    #endregion

    #region Activity: WBS Escalation Handlers

    private async Task ExecuteWbsBreachCheckAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var esc = await db.ProjectServiceEscalations
            .FirstOrDefaultAsync(e => e.Id == instance.EntityId && e.DeletedAtUtc == null);

        var alert = await db.ProjectAlerts
            .FirstOrDefaultAsync(a => a.ServiceEscalationId == instance.EntityId && a.DeletedAtUtc == null);

        if (esc == null || esc.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) || esc.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase)
            || (alert != null && (alert.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) || alert.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase))))
        {
            logger.LogInformation(
                "[SLA Worker] WBS Escalation {EscalationId} is already {Status}. Completing SLA instance.",
                instance.EntityId,
                esc?.Status ?? alert?.Status ?? "not found");

            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"WBS Escalation already {esc?.Status ?? alert?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        instance.Status = SlaInstanceStatus.Breached;
        instance.BreachedAtUtc = DateTime.UtcNow;
        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = DateTime.UtcNow;
        eventRecord.ExecutionLog = $"WBS Escalation {esc.Id} breached SLA at {DateTime.UtcNow:u}. Initial stakeholders did not Resolve or Close within 2 days.";
        await db.SaveChangesAsync();
    }

    private async Task ExecuteWbsEscalationAsync(SlaInstance instance, SlaEvent eventRecord, int level)
    {
        var esc = await db.ProjectServiceEscalations
            .Include(e => e.Stakeholders)
            .FirstOrDefaultAsync(e => e.Id == instance.EntityId && e.DeletedAtUtc == null);

        var alert = await db.ProjectAlerts
            .FirstOrDefaultAsync(a => a.ServiceEscalationId == instance.EntityId && a.DeletedAtUtc == null);

        if (esc == null || esc.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) || esc.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase)
            || (alert != null && (alert.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) || alert.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase))))
        {
            logger.LogInformation(
                "[SLA Worker] WBS Escalation {EscalationId} is already {Status}. Completing SLA instance.",
                instance.EntityId,
                esc?.Status ?? alert?.Status ?? "not found");

            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"WBS Escalation already {esc?.Status ?? alert?.Status ?? "not found"}. Escalation skipped and SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        var levelLabel = level == 1 ? "Level 1 Escalation" : "Level 2 Escalation";
        var targetRoles = eventRecord.TargetRoles.Count > 0
            ? eventRecord.TargetRoles
            : (level == 1 ? ["Assigned Senior Project Manager"] : ["Head of Department"]);

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var recipientEmployees = await db.Employees
            .AsNoTracking()
            .Where(e => recipientIds.Contains(e.Id) && e.DeletedAtUtc == null)
            .ToListAsync();

        var targetRoleName = level == 1 ? "Assigned Senior Project Manager" : "Head of Department";
        var recipientNamesList = recipientEmployees
            .Select(e => $"{e.FirstName} {e.LastName}".Trim())
            .Where(n => !string.IsNullOrWhiteSpace(n))
            .Distinct()
            .ToList();
        var recipientNamesStr = string.Join(", ", recipientNamesList);

        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        // 1. Dispatch ActionNotifications to recipients
        var notifTitle = $"{levelLabel}: WBS Escalation - {esc.ServiceName} - {esc.Subject}";
        if (notifTitle.Length > 255) notifTitle = notifTitle[..255];
        var relatedTask = esc.ServiceName.Length > 255 ? esc.ServiceName[..255] : esc.ServiceName;

        foreach (var recipientId in recipientIds)
        {
            var alreadyNotified = await db.ActionNotifications.AnyAsync(n =>
                n.RecipientEmployeeId == recipientId &&
                n.ProjectId == esc.ProjectId &&
                n.Title == notifTitle &&
                n.Type == "WBS Escalation" &&
                n.DeletedAtUtc == null);

            if (!alreadyNotified)
            {
                db.ActionNotifications.Add(new ActionNotification
                {
                    RecipientEmployeeId = recipientId,
                    ProjectId = esc.ProjectId,
                    ProjectCode = esc.ProjectCode,
                    ProjectName = esc.ProjectName,
                    Title = notifTitle,
                    Type = "WBS Escalation",
                    Priority = "Critical",
                    Status = "Pending",
                    Unread = true,
                    RaisedByEmployeeId = esc.RaisedByEmployeeId,
                    RaisedByName = "SLA Automation Engine",
                    RelatedTask = relatedTask,
                    ServiceEscalationId = esc.Id,
                    HistoryJson = alert?.HistoryJson ?? "[]",
                    CreatedAtUtc = now
                });
            }
        }

        // 2. Update ProjectAlert if available
        if (alert != null)
        {
            // Add recipient IDs to AudienceUserIds so they receive the Alert request in their Alert tab
            var audienceSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (!string.IsNullOrWhiteSpace(alert.AudienceUserIds))
            {
                try
                {
                    var parsedList = JsonSerializer.Deserialize<List<string>>(alert.AudienceUserIds);
                    if (parsedList != null)
                    {
                        foreach (var id in parsedList)
                        {
                            if (!string.IsNullOrWhiteSpace(id)) audienceSet.Add(id.Trim());
                        }
                    }
                }
                catch
                {
                    var parts = alert.AudienceUserIds.Split([',', ';', '[', ']', '"'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
                    foreach (var part in parts) audienceSet.Add(part);
                }
            }
            foreach (var rId in recipientIds)
            {
                audienceSet.Add(rId.ToString());
            }
            foreach (var emp in recipientEmployees)
            {
                if (emp.UserId.HasValue) audienceSet.Add(emp.UserId.Value.ToString());
            }
            alert.AudienceUserIds = JsonSerializer.Serialize(audienceSet.ToList());

            // Add recipient names to EscalatedTo
            var escalatedToNames = new List<string>();
            if (!string.IsNullOrWhiteSpace(alert.EscalatedTo))
            {
                try
                {
                    var parsedNames = JsonSerializer.Deserialize<List<string>>(alert.EscalatedTo);
                    if (parsedNames != null) escalatedToNames.AddRange(parsedNames);
                }
                catch
                {
                    var parts = alert.EscalatedTo.Split([',', ';', '[', ']', '"'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
                    escalatedToNames.AddRange(parts);
                }
            }
            foreach (var name in recipientNamesList)
            {
                if (!escalatedToNames.Contains(name, StringComparer.OrdinalIgnoreCase))
                {
                    escalatedToNames.Add(name);
                }
            }
            alert.EscalatedTo = JsonSerializer.Serialize(escalatedToNames);

            // Append to HistoryJson
            var history = string.IsNullOrWhiteSpace(alert.HistoryJson)
                ? []
                : (JsonSerializer.Deserialize<List<NotificationHistoryItemDto>>(alert.HistoryJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true }) ?? []);

            var actionDesc = !string.IsNullOrWhiteSpace(recipientNamesStr)
                ? $"{levelLabel}: Alert assigned to {targetRoleName} ({recipientNamesStr})"
                : levelLabel;

            history.Add(new NotificationHistoryItemDto
            {
                Action = actionDesc,
                Date = dateStr,
                Time = timeStr,
                By = "SLA Automation Engine"
            });

            alert.HistoryJson = JsonSerializer.Serialize(history);
            alert.Priority = "Critical";
            alert.UpdatedAtUtc = now;
        }

        // 3. Update ProjectServiceEscalation and add stakeholders
        esc.Priority = "Critical";
        esc.UpdatedAtUtc = now;

        foreach (var emp in recipientEmployees)
        {
            if (!esc.Stakeholders.Any(s => s.EmployeeId == emp.Id))
            {
                var subDept = emp.SubDepartment?.Trim();
                if (string.IsNullOrWhiteSpace(subDept))
                {
                    subDept = level == 1 ? "Senior Project Management" : "Department Head";
                }

                var newStakeholder = new ProjectServiceEscalationStakeholder
                {
                    EscalationId = esc.Id,
                    EmployeeId = emp.Id,
                    EmployeeName = $"{emp.FirstName} {emp.LastName}".Trim(),
                    SubDepartment = subDept,
                    Status = "Pending"
                };
                esc.Stakeholders.Add(newStakeholder);
                db.ProjectServiceEscalationStakeholders.Add(newStakeholder);
            }
        }

        // Sync ChatJson between alert and escalation
        if (alert != null)
        {
            if (!string.IsNullOrWhiteSpace(alert.ChatJson) && string.IsNullOrWhiteSpace(esc.ChatJson))
            {
                esc.ChatJson = alert.ChatJson;
            }
            else if (!string.IsNullOrWhiteSpace(esc.ChatJson) && string.IsNullOrWhiteSpace(alert.ChatJson))
            {
                alert.ChatJson = esc.ChatJson;
            }
        }

        // Sync notification HistoryJson
        if (alert != null && !string.IsNullOrWhiteSpace(alert.HistoryJson))
        {
            var notifsToUpdate = await db.ActionNotifications
                .Where(n => n.Type == "WBS Escalation" && n.ProjectId == esc.ProjectId && recipientIds.Contains(n.RecipientEmployeeId) && n.DeletedAtUtc == null)
                .ToListAsync();
            foreach (var n in notifsToUpdate)
            {
                n.HistoryJson = alert.HistoryJson;
            }
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"{levelLabel} executed at {now:u}. Dispatched Critical WBS escalation notification & alert request to {recipientIds.Count} recipients.";
        instance.Status = SlaInstanceStatus.Breached;
        instance.BreachedAtUtc = now;

        // 4. If Level 1, schedule Level 2 by EOD of next 1 working day
        if (level == 1)
        {
            var l2Key = $"sla:{instance.Id}:esc-l2";
            var l2Exists = await db.SlaEvents
                .AnyAsync(e => (e.IdempotencyKey == l2Key || (e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2))
                               && e.Status != SlaEventStatus.Skipped
                               && e.Status != SlaEventStatus.Cancelled
                               && e.DeletedAtUtc == null);

            if (!l2Exists)
            {
                var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);
                var holidays = await db.LeaveCalendarHolidays
                    .AsNoTracking()
                    .Where(h => h.DeletedAtUtc == null)
                    .Select(h => h.HolidayDate)
                    .ToHashSetAsync();

                var l2DeadlineUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(now, holidays, policy?.WorkingHoursEnd);
                var l2Delay = l2DeadlineUtc > now ? l2DeadlineUtc - now : TimeSpan.FromHours(24);

                var l2Event = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL2,
                    ScheduledAtUtc = l2DeadlineUtc,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = ["Head of Department"],
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = l2Key
                };
                db.SlaEvents.Add(l2Event);
                await db.SaveChangesAsync();

                var l2JobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    w => w.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2),
                    l2Delay);
                l2Event.HangfireJobId = l2JobId;
            }
        }

        await db.SaveChangesAsync();
    }

    #endregion

    #region Activity: Project Extension Request Handlers

    private async Task ExecuteExtensionRequestReminderAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var ext = await db.ProjectExtensionRequests
            .Include(x => x.Approvers)
            .Include(x => x.Project)
            .FirstOrDefaultAsync(x => x.Id == instance.EntityId && x.DeletedAtUtc == null);

        if (ext == null || !ext.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Extension request already {ext?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        var approverIds = ext.Approvers
            .Where(a => a.DeletedAtUtc == null && a.Status == "Pending")
            .Select(a => a.EmployeeId)
            .Distinct()
            .ToList();

        if (approverIds.Count == 0 && instance.RecipientEmployeeId.HasValue)
        {
            approverIds.Add(instance.RecipientEmployeeId.Value);
        }

        eventRecord.TargetRecipientIds = approverIds;

        var now = DateTime.UtcNow;
        var nowIst = TimeZoneInfo.ConvertTimeFromUtc(now, SlaDeadlineCalculator.IndianTimeZone);
        var dateStr = nowIst.ToString("yyyy-MM-dd");
        var timeStr = nowIst.ToString("HH:mm:ss");

        var project = ext.Project ?? await db.Projects.FirstOrDefaultAsync(p => p.Id == ext.ProjectId);
        var projName = project?.Name ?? "Project";
        var projCode = project?.ProjectCode;

        var reminderTitle = $"Daily Reminder: Timeline Extension Approval Pending - {projName} (Requested: {ext.RequestedEndDate:dd-MMM-yyyy})";

        foreach (var approverId in approverIds)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = approverId,
                ProjectId = ext.ProjectId,
                ProjectCode = projCode,
                ProjectName = projName,
                Title = reminderTitle,
                Type = "Timeline Extension Reminder",
                Priority = "High",
                Status = "Pending",
                Unread = true,
                RaisedByName = "SLA Automation Engine",
                RelatedTask = ext.Id.ToString(),
                CreatedAtUtc = now,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        action = "Daily EOD Reminder: Timeline extension approval request pending action.",
                        date = dateStr,
                        time = timeStr,
                        by = "SLA Automation Engine"
                    }
                })
            };
            db.ActionNotifications.Add(notif);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"Daily EOD reminder sent to {approverIds.Count} approvers at {now:u}.";

        // Schedule next daily reminder if before TargetDeadlineUtc
        var holidays = await db.LeaveCalendarHolidays
            .AsNoTracking()
            .Where(h => h.DeletedAtUtc == null)
            .Select(h => h.HolidayDate)
            .ToHashSetAsync();

        var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);
        var schedTime = eventRecord.ScheduledAtUtc ?? now;
        var baseDate = (now > schedTime ? now : schedTime).Date.AddDays(1);
        var nextReminderTime = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(baseDate, holidays, policy?.WorkingHoursEnd);

        if (nextReminderTime < instance.TargetDeadlineUtc && nextReminderTime > now)
        {
            var delay = nextReminderTime - now;
            var reminderKey = $"sla:{instance.Id}:rem:{nextReminderTime:yyyy-MM-dd}";

            var exists = await db.SlaEvents.AnyAsync(e => e.IdempotencyKey == reminderKey && e.DeletedAtUtc == null);
            if (!exists)
            {
                var nextReminderEvent = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.Reminder,
                    ScheduledAtUtc = nextReminderTime,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = ["Select Stakeholders"],
                    TargetRecipientIds = approverIds,
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = reminderKey
                };
                db.SlaEvents.Add(nextReminderEvent);
                await db.SaveChangesAsync();

                var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteReminderAsync(instance.Id, nextReminderEvent.Id),
                    delay);

                nextReminderEvent.HangfireJobId = jobId;
            }
        }

        await db.SaveChangesAsync();
    }

    private async Task ExecuteExtensionRequestBreachCheckAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var ext = await db.ProjectExtensionRequests
            .FirstOrDefaultAsync(x => x.Id == instance.EntityId && x.DeletedAtUtc == null);

        if (ext == null || !ext.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Extension request already {ext?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (DateTime.UtcNow >= instance.TargetDeadlineUtc && instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
            logger.LogWarning(
                "[SLA Worker] SLA BREACH DETECTED for Extension Request {ExtId}. TargetDeadline: {Deadline:u}, BreachedAt: {BreachedAt:u}",
                instance.EntityId,
                instance.TargetDeadlineUtc,
                instance.BreachedAtUtc);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = DateTime.UtcNow;
        eventRecord.ExecutionLog = $"Breach check executed. Instance status: {instance.Status}. BreachedAt: {instance.BreachedAtUtc:u}";
        await db.SaveChangesAsync();
    }

    private async Task ExecuteExtensionRequestEscalationAsync(SlaInstance instance, SlaEvent eventRecord, int level)
    {
        var ext = await db.ProjectExtensionRequests
            .Include(x => x.Project)
            .FirstOrDefaultAsync(x => x.Id == instance.EntityId && x.DeletedAtUtc == null);

        if (ext == null || !ext.Status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Extension request already {ext?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
        }

        var targetRoles = level == 1
            ? (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Assigned Senior Project Manager"])
            : (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Head of Department"]);

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var now = DateTime.UtcNow;
        var nowIst = TimeZoneInfo.ConvertTimeFromUtc(now, SlaDeadlineCalculator.IndianTimeZone);
        var dateStr = nowIst.ToString("yyyy-MM-dd");
        var timeStr = nowIst.ToString("HH:mm:ss");

        var levelLabel = level == 1 ? "Level 1 SLA Escalation" : "Level 2 SLA Escalation";
        var targetRoleName = level == 1 ? "Assigned Senior Project Manager" : "Head of Department";

        var project = ext.Project ?? await db.Projects.FirstOrDefaultAsync(p => p.Id == ext.ProjectId);
        var projName = project?.Name ?? "Project";
        var projCode = project?.ProjectCode;

        var notifTitle = $"{levelLabel}: Timeline Extension Approval Pending - {projName} (Requested: {ext.RequestedEndDate:dd-MMM-yyyy})";

        foreach (var recipientId in recipientIds)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipientId,
                ProjectId = ext.ProjectId,
                ProjectCode = projCode,
                ProjectName = projName,
                Title = notifTitle,
                Type = "Timeline Extension Escalation",
                Priority = "Critical",
                Status = "Pending",
                Unread = true,
                RaisedByName = "SLA Automation Engine",
                RelatedTask = ext.Id.ToString(),
                CreatedAtUtc = now,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        action = $"{levelLabel}: Dispatched to {targetRoleName} due to pending timeline extension approval.",
                        date = dateStr,
                        time = timeStr,
                        by = "SLA Automation Engine"
                    }
                })
            };
            db.ActionNotifications.Add(notif);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"{levelLabel} executed at {now:u}. Dispatched Critical escalation notification to {recipientIds.Count} recipients.";

        if (level == 1)
        {
            var l2Key = $"sla:{instance.Id}:esc-l2";
            var l2Exists = await db.SlaEvents
                .AnyAsync(e => (e.IdempotencyKey == l2Key || (e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2))
                               && e.Status != SlaEventStatus.Skipped
                               && e.Status != SlaEventStatus.Cancelled
                               && e.DeletedAtUtc == null);

            if (!l2Exists)
            {
                var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);
                var holidays = await db.LeaveCalendarHolidays
                    .AsNoTracking()
                    .Where(h => h.DeletedAtUtc == null)
                    .Select(h => h.HolidayDate)
                    .ToHashSetAsync();

                var l2DeadlineUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(now, holidays, policy?.WorkingHoursEnd);
                var l2Delay = l2DeadlineUtc > now ? l2DeadlineUtc - now : TimeSpan.FromHours(24);

                var l2Event = new SlaEvent
                {
                    Id = Guid.NewGuid(),
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL2,
                    Status = SlaEventStatus.Scheduled,
                    ScheduledAtUtc = l2DeadlineUtc,
                    TargetRoles = ["Head of Department"],
                    StageAtExecution = instance.CurrentStage,
                    IdempotencyKey = l2Key
                };
                db.SlaEvents.Add(l2Event);
                await db.SaveChangesAsync();

                var l2JobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2),
                    l2Delay);

                l2Event.HangfireJobId = l2JobId;
                await db.SaveChangesAsync();
            }
        }

        await db.SaveChangesAsync();
    }

    #endregion

    #region Activity: Additional Customer Requirement Handlers

    private async Task ExecuteAdditionalRequirementBreachCheckAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var req = await db.ProjectAdditionalRequirements
            .FirstOrDefaultAsync(x => x.Id == instance.EntityId && x.DeletedAtUtc == null);

        var isResolved = req == null ||
                         req.Status.Equals("Approved", StringComparison.OrdinalIgnoreCase) ||
                         req.Status.Equals("Rejected", StringComparison.OrdinalIgnoreCase) ||
                         req.Status.Equals("Hold", StringComparison.OrdinalIgnoreCase);

        if (isResolved)
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Customer requirement already {req?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (DateTime.UtcNow >= instance.TargetDeadlineUtc && instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
            logger.LogWarning(
                "[SLA Worker] SLA BREACH DETECTED for Customer Requirement {ReqId}. TargetDeadline: {Deadline:u}, BreachedAt: {BreachedAt:u}",
                instance.EntityId,
                instance.TargetDeadlineUtc,
                instance.BreachedAtUtc);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = DateTime.UtcNow;
        eventRecord.ExecutionLog = $"Breach check executed. Instance status: {instance.Status}. BreachedAt: {instance.BreachedAtUtc:u}";
        await db.SaveChangesAsync();
    }

    private async Task ExecuteAdditionalRequirementEscalationAsync(SlaInstance instance, SlaEvent eventRecord, int level)
    {
        var req = await db.ProjectAdditionalRequirements
            .Include(x => x.Project)
            .FirstOrDefaultAsync(x => x.Id == instance.EntityId && x.DeletedAtUtc == null);

        var isResolved = req == null ||
                         req.Status.Equals("Approved", StringComparison.OrdinalIgnoreCase) ||
                         req.Status.Equals("Rejected", StringComparison.OrdinalIgnoreCase) ||
                         req.Status.Equals("Hold", StringComparison.OrdinalIgnoreCase);

        if (isResolved)
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Customer requirement already {req?.Status ?? "not found"}. Escalation skipped.";
            await db.SaveChangesAsync();
            return;
        }

        if (instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
        }

        var targetRoles = level == 1
            ? (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Assigned Senior Project Manager"])
            : (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Head of Department"]);

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var now = DateTime.UtcNow;
        var nowIst = TimeZoneInfo.ConvertTimeFromUtc(now, SlaDeadlineCalculator.IndianTimeZone);
        var dateStr = nowIst.ToString("yyyy-MM-dd");
        var timeStr = nowIst.ToString("HH:mm:ss");

        var levelLabel = level == 1 ? "Level 1 SLA Escalation" : "Level 2 SLA Escalation";
        var targetRoleName = level == 1 ? "Assigned Senior Project Manager" : "Head of Department";

        var project = req.Project ?? await db.Projects.FirstOrDefaultAsync(p => p.Id == req.ProjectId);
        var projName = project?.Name ?? "Project";
        var projCode = project?.ProjectCode;

        var notifTitle = $"{levelLabel}: Customer Requirement Approval Pending - {req.Title} ({projName})";

        foreach (var recipientId in recipientIds)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipientId,
                ProjectId = req.ProjectId,
                ProjectCode = projCode,
                ProjectName = projName,
                Title = notifTitle,
                Type = "Customer Requirement Escalation",
                Priority = "Critical",
                Status = "Pending",
                Unread = true,
                RaisedByName = "SLA Automation Engine",
                RelatedTask = req.RequirementId,
                CreatedAtUtc = now,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        action = $"{levelLabel}: Dispatched to {targetRoleName} due to pending customer requirement approval.",
                        date = dateStr,
                        time = timeStr,
                        by = "SLA Automation Engine"
                    }
                })
            };
            db.ActionNotifications.Add(notif);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"{levelLabel} executed at {now:u}. Dispatched Critical escalation notification to {recipientIds.Count} recipients.";

        if (level == 1)
        {
            var l2Key = $"sla:{instance.Id}:esc-l2";
            var l2Exists = await db.SlaEvents
                .AnyAsync(e => (e.IdempotencyKey == l2Key || (e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2))
                               && e.Status != SlaEventStatus.Skipped
                               && e.Status != SlaEventStatus.Cancelled
                               && e.DeletedAtUtc == null);

            if (!l2Exists)
            {
                var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);
                var holidays = await db.LeaveCalendarHolidays
                    .AsNoTracking()
                    .Where(h => h.DeletedAtUtc == null)
                    .Select(h => h.HolidayDate)
                    .ToHashSetAsync();

                var l2DeadlineUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(now, holidays, policy?.WorkingHoursEnd);
                var l2Delay = l2DeadlineUtc > now ? l2DeadlineUtc - now : TimeSpan.FromHours(24);

                var l2Event = new SlaEvent
                {
                    Id = Guid.NewGuid(),
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL2,
                    Status = SlaEventStatus.Scheduled,
                    ScheduledAtUtc = l2DeadlineUtc,
                    TargetRoles = ["Head of Department"],
                    StageAtExecution = instance.CurrentStage,
                    IdempotencyKey = l2Key
                };
                db.SlaEvents.Add(l2Event);
                await db.SaveChangesAsync();

                var l2JobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2),
                    l2Delay);

                l2Event.HangfireJobId = l2JobId;
                await db.SaveChangesAsync();
            }
        }

        await db.SaveChangesAsync();
    }

    #endregion

    #region Activity: Resource Allocation Handlers

    private async Task ExecuteResourceAllocationBreachCheckAsync(SlaInstance instance, SlaEvent eventRecord)
    {
        var req = await db.ProjectResourceAllocationRequests
            .FirstOrDefaultAsync(x => x.Id == instance.EntityId && x.DeletedAtUtc == null);

        var isResolved = req == null ||
                         req.Status.Equals("Approved", StringComparison.OrdinalIgnoreCase) ||
                         req.Status.Equals("Rejected", StringComparison.OrdinalIgnoreCase) ||
                         req.Status.Equals("Hold", StringComparison.OrdinalIgnoreCase);

        if (isResolved)
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Resource allocation request already {req?.Status ?? "not found"}. SLA completed.";
            await db.SaveChangesAsync();
            return;
        }

        if (DateTime.UtcNow >= instance.TargetDeadlineUtc && instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
            logger.LogWarning(
                "[SLA Worker] SLA BREACH DETECTED for Resource Allocation Request {ReqId}. TargetDeadline: {Deadline:u}, BreachedAt: {BreachedAt:u}",
                instance.EntityId,
                instance.TargetDeadlineUtc,
                instance.BreachedAtUtc);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = DateTime.UtcNow;
        eventRecord.ExecutionLog = $"Breach check executed. Instance status: {instance.Status}. BreachedAt: {instance.BreachedAtUtc:u}";
        await db.SaveChangesAsync();
    }

    private async Task ExecuteResourceAllocationEscalationAsync(SlaInstance instance, SlaEvent eventRecord, int level)
    {
        var req = await db.ProjectResourceAllocationRequests
            .Include(x => x.Project)
            .Include(x => x.Employee)
            .FirstOrDefaultAsync(x => x.Id == instance.EntityId && x.DeletedAtUtc == null);

        var isResolved = req == null ||
                         req.Status.Equals("Approved", StringComparison.OrdinalIgnoreCase) ||
                         req.Status.Equals("Rejected", StringComparison.OrdinalIgnoreCase) ||
                         req.Status.Equals("Hold", StringComparison.OrdinalIgnoreCase);

        if (isResolved)
        {
            instance.Status = SlaInstanceStatus.Completed;
            instance.CompletedAtUtc = DateTime.UtcNow;
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Resource allocation request already {req?.Status ?? "not found"}. Escalation skipped.";
            await db.SaveChangesAsync();
            return;
        }

        if (instance.Status == SlaInstanceStatus.Tracking)
        {
            instance.Status = SlaInstanceStatus.Breached;
            instance.BreachedAtUtc = DateTime.UtcNow;
        }

        if (instance.ProjectId == null && req?.ProjectId != null)
        {
            instance.ProjectId = req.ProjectId;
        }

        var targetRoles = level == 1
            ? (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Assigned Senior Project Manager"])
            : (eventRecord.TargetRoles.Count > 0 ? eventRecord.TargetRoles : ["Head of Department"]);

        var recipientIds = await recipientResolver.ResolveRecipientsAsync(instance, targetRoles);
        eventRecord.TargetRecipientIds = recipientIds;

        var now = DateTime.UtcNow;
        var nowIst = TimeZoneInfo.ConvertTimeFromUtc(now, SlaDeadlineCalculator.IndianTimeZone);
        var dateStr = nowIst.ToString("yyyy-MM-dd");
        var timeStr = nowIst.ToString("HH:mm:ss");

        var levelLabel = level == 1 ? "Level 1 SLA Escalation" : "Level 2 SLA Escalation";
        var targetRoleName = level == 1 ? "Assigned Senior Project Manager" : "Head of Department";

        var project = req.Project ?? await db.Projects.FirstOrDefaultAsync(p => p.Id == req.ProjectId);
        var projName = project?.Name ?? "Project";
        var projCode = project?.ProjectCode;
        var candidateName = req.Employee != null ? $"{req.Employee.FirstName} {req.Employee.LastName}".Trim() : "Resource";
        var allocTaskCode = $"ALLOC-{req.Id.ToString()[..8].ToUpper()}";

        var notifTitle = $"{levelLabel}: Resource Allocation Approval Pending - {candidateName} ({projName})";

        foreach (var recipientId in recipientIds)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipientId,
                ProjectId = req.ProjectId,
                ProjectCode = projCode,
                ProjectName = projName,
                Title = notifTitle,
                Type = "Resource Allocation Escalation",
                Priority = "Critical",
                Status = "Pending",
                Unread = true,
                RaisedByName = "SLA Automation Engine",
                RelatedTask = allocTaskCode,
                CreatedAtUtc = now,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        action = $"{levelLabel}: Dispatched to {targetRoleName} due to pending resource allocation approval.",
                        date = dateStr,
                        time = timeStr,
                        by = "SLA Automation Engine"
                    }
                })
            };
            db.ActionNotifications.Add(notif);
        }

        eventRecord.Status = SlaEventStatus.Executed;
        eventRecord.ExecutedAtUtc = now;
        eventRecord.ExecutionLog = $"{levelLabel} executed at {now:u}. Dispatched Critical escalation notification to {recipientIds.Count} recipients.";

        if (level == 1)
        {
            var l2Key = $"sla:{instance.Id}:esc-l2";
            var l2Exists = await db.SlaEvents
                .AnyAsync(e => (e.IdempotencyKey == l2Key || (e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2))
                               && e.Status != SlaEventStatus.Skipped
                               && e.Status != SlaEventStatus.Cancelled
                               && e.DeletedAtUtc == null);

            if (!l2Exists)
            {
                var policy = instance.Policy ?? await db.SlaPolicies.FirstOrDefaultAsync(p => p.Id == instance.PolicyId);
                var holidays = await db.LeaveCalendarHolidays
                    .AsNoTracking()
                    .Where(h => h.DeletedAtUtc == null)
                    .Select(h => h.HolidayDate)
                    .ToHashSetAsync();

                var l2DeadlineUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(now, holidays, policy?.WorkingHoursEnd);
                var l2Delay = l2DeadlineUtc > now ? l2DeadlineUtc - now : TimeSpan.FromHours(24);

                var l2Event = new SlaEvent
                {
                    Id = Guid.NewGuid(),
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL2,
                    Status = SlaEventStatus.Scheduled,
                    ScheduledAtUtc = l2DeadlineUtc,
                    TargetRoles = ["Head of Department"],
                    StageAtExecution = instance.CurrentStage,
                    IdempotencyKey = l2Key
                };
                db.SlaEvents.Add(l2Event);
                await db.SaveChangesAsync();

                var l2JobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2),
                    l2Delay);

                l2Event.HangfireJobId = l2JobId;
                await db.SaveChangesAsync();
            }
        }

        await db.SaveChangesAsync();
    }

    #endregion
    /// Atomically transitions event status from Scheduled to Executing to guarantee single execution across concurrent workers.
    /// Safely skips execution if the instance was cancelled, completed, paused, or transitioned.
    /// </summary>
    private async Task<(SlaInstance? Instance, SlaEvent? Event)> LoadAndValidateAsync(
        Guid instanceId,
        Guid eventId,
        SlaEventType expectedType)
    {
        // 1. Atomic state transition: Scheduled -> Executing (guarantees idempotency and concurrency protection)
        var rowsAffected = await db.SlaEvents
            .Where(e => e.Id == eventId && e.Status == SlaEventStatus.Scheduled && e.DeletedAtUtc == null)
            .ExecuteUpdateAsync(s => s
                .SetProperty(e => e.Status, SlaEventStatus.Executing)
                .SetProperty(e => e.UpdatedAtUtc, DateTime.UtcNow));

        if (rowsAffected == 0)
        {
            logger.LogInformation("[SLA Worker] Event {EventId} is not in Scheduled state (already Executing, Executed, or Skipped). Skipping duplicate execution.", eventId);
            return (null, null);
        }

        var instance = await db.SlaInstances
            .Include(i => i.Policy)
            .FirstOrDefaultAsync(i => i.Id == instanceId && i.DeletedAtUtc == null);

        var eventRecord = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.Id == eventId && e.DeletedAtUtc == null);

        if (instance == null || eventRecord == null)
        {
            logger.LogWarning("[SLA Worker] Job aborted: Instance {InstanceId} or Event {EventId} not found in database.", instanceId, eventId);
            return (null, null);
        }

        // Validate instance active status (tracking or breached can proceed with escalations; paused/completed/cancelled must skip)
        SlaInstanceStatus[] allowedStatuses = expectedType is SlaEventType.EscalationL1 or SlaEventType.EscalationL2
            ? [SlaInstanceStatus.Tracking, SlaInstanceStatus.Breached]
            : [SlaInstanceStatus.Tracking];

        if (!allowedStatuses.Contains(instance.Status))
        {
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Skipped because instance status is {instance.Status}.";
            await db.SaveChangesAsync();

            logger.LogInformation(
                "[SLA Worker] Skipped Event {EventId} because instance status is {Status}.",
                eventId,
                instance.Status);

            return (null, null);
        }

        // Validate stage match: if stage changed, previous stage's jobs must safely skip
        if (!string.Equals(instance.CurrentStage, eventRecord.StageAtExecution, StringComparison.OrdinalIgnoreCase))
        {
            eventRecord.Status = SlaEventStatus.Skipped;
            eventRecord.ExecutionLog = $"Skipped because stage changed from '{eventRecord.StageAtExecution}' to '{instance.CurrentStage}'.";
            await db.SaveChangesAsync();

            logger.LogInformation(
                "[SLA Worker] Skipped Event {EventId} due to stage mismatch (Scheduled: '{ScheduledStage}', Current: '{CurrentStage}').",
                eventId,
                eventRecord.StageAtExecution,
                instance.CurrentStage);

            return (null, null);
        }

        return (instance, eventRecord);
    }
}
