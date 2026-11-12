using Hangfire;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Sla.DTOs;
using PMS.API.Modules.Sla.Jobs;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Services;

public sealed class SlaTrackingService(
    AppDbContext db,
    ISlaPolicyService policyService,
    ISlaDeadlineCalculator deadlineCalculator,
    ILogger<SlaTrackingService> logger) : ISlaTrackingService
{
    public async Task<SlaInstance> StartTrackingAsync(SlaStartTrackingRequest request, CancellationToken ct = default)
    {
        // 1. Prevent duplicate active instances for the same entity and activity
        var existingActive = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == request.EntityId
                                      && i.ActivityType == request.ActivityType
                                      && i.Status != SlaInstanceStatus.Completed
                                      && i.Status != SlaInstanceStatus.Cancelled
                                      && i.DeletedAtUtc == null, ct);

        if (existingActive != null)
        {
            logger.LogWarning(
                "[SLA Tracking] Active SLA tracking instance already exists for EntityId {EntityId}, Activity {ActivityType}. Returning existing instance.",
                request.EntityId,
                request.ActivityType);
            return existingActive;
        }

        // 2. Resolve policy
        var policy = await policyService.GetPolicyAsync(request.Module, request.ActivityType, request.Stage, ct);
        if (policy == null)
        {
            if (string.Equals(request.ActivityType, "Task Start After Assigning", StringComparison.OrdinalIgnoreCase))
            {
                policy = new SlaPolicy
                {
                    Module = request.Module,
                    ActivityType = request.ActivityType,
                    Stage = request.Stage,
                    Name = "Task Start After Assigning SLA Policy",
                    TatDurationMinutes = 540,
                    CalculationMode = SlaCalculationMode.EndOfDay,
                    FirstEscalationAfterMinutes = 0,
                    SecondEscalationAfterMinutes = null,
                    ResponsibleRolesJson = "[\"Assigned Engagement Manager\", \"Assigned Project Manager\", \"Project Team Leader\"]",
                    FirstEscalationRolesJson = "[\"Assigned Senior Project Manager\"]",
                    SecondEscalationRolesJson = "[\"Head of Department\"]"
                };
            }
            else if (string.Equals(request.ActivityType, "Task Deadline", StringComparison.OrdinalIgnoreCase))
            {
                policy = new SlaPolicy
                {
                    Module = request.Module,
                    ActivityType = request.ActivityType,
                    Stage = request.Stage,
                    Name = "Task Deadline SLA Policy",
                    TatDurationMinutes = 1440,
                    CalculationMode = SlaCalculationMode.EndOfDay,
                    FirstEscalationAfterMinutes = 0,
                    SecondEscalationAfterMinutes = null,
                    ResponsibleRolesJson = "[\"Assigned Engagement Manager\", \"Assigned Project Manager\", \"Project Team Leader\"]",
                    FirstEscalationRolesJson = "[\"Assigned Senior Project Manager\"]",
                    SecondEscalationRolesJson = "[\"Head of Department\"]"
                };
            }
            else if (string.Equals(request.ActivityType, "Task Pause", StringComparison.OrdinalIgnoreCase))
            {
                policy = new SlaPolicy
                {
                    Module = request.Module,
                    ActivityType = request.ActivityType,
                    Stage = request.Stage,
                    Name = "Task Pause Daily Reminder Policy",
                    TatDurationMinutes = 1440,
                    CalculationMode = SlaCalculationMode.EndOfDay,
                    FirstEscalationAfterMinutes = null,
                    SecondEscalationAfterMinutes = null,
                    ResponsibleRolesJson = "[\"Assigned Engagement Manager\", \"Assigned Project Manager\", \"Project Team Leader\"]",
                    FirstEscalationRolesJson = "[]",
                    SecondEscalationRolesJson = "[]"
                };
            }
            else if (string.Equals(request.ActivityType, "WBS Escalation", StringComparison.OrdinalIgnoreCase)
                     || string.Equals(request.ActivityType, "Service Escalation", StringComparison.OrdinalIgnoreCase))
            {
                policy = new SlaPolicy
                {
                    Module = request.Module,
                    ActivityType = request.ActivityType,
                    Stage = request.Stage,
                    Name = "WBS Escalation SLA Policy",
                    TatDurationMinutes = 1080, // 2 working days (2 * 540) to EOD
                    CalculationMode = SlaCalculationMode.EndOfDay,
                    WorkingHoursStart = new TimeSpan(9, 0, 0),
                    WorkingHoursEnd = new TimeSpan(18, 0, 0),
                    ExcludeWeekends = true,
                    ExcludeHolidays = true,
                    FirstEscalationAfterMinutes = 0, // Triggers at TargetDeadlineUtc (EOD of next 2 days)
                    SecondEscalationAfterMinutes = null, // Dynamically scheduled on L1 execution (EOD of next 1 day)
                    ResponsibleRolesJson = "[\"Select Stakeholders\"]",
                    FirstEscalationRolesJson = "[\"Assigned Senior Project Manager\"]",
                    SecondEscalationRolesJson = "[\"Head of Department\"]"
                };
            }
            else
            {
                // Create a sensible fallback default policy if none configured yet
                policy = new SlaPolicy
                {
                    Module = request.Module,
                    ActivityType = request.ActivityType,
                    Stage = request.Stage,
                    Name = $"{request.ActivityType} ({request.Stage}) Default SLA Policy",
                    TatDurationMinutes = 1440, // 24 hours default
                    CalculationMode = SlaCalculationMode.WorkingHours,
                    ReminderIntervalsMinutesJson = "[120, 60, 15]",
                    FirstEscalationAfterMinutes = 60,
                    SecondEscalationAfterMinutes = 180,
                    ResponsibleRolesJson = "[\"ProjectManager\", \"SeniorProjectManager\"]",
                    FirstEscalationRolesJson = "[\"PMO\", \"HOD\"]",
                    SecondEscalationRolesJson = "[\"CEO\", \"COO\", \"Admin\"]"
                };
            }
            await policyService.CreateOrUpdatePolicyAsync(policy, ct);
        }

        var holidays = await db.LeaveCalendarHolidays
            .AsNoTracking()
            .Where(h => h.DeletedAtUtc == null)
            .Select(h => h.HolidayDate)
            .ToHashSetAsync(ct);

        var startTimeUtc = request.CustomStartTimeUtc ?? DateTime.UtcNow;
        var deadlineUtc = request.CustomDeadlineUtc ?? deadlineCalculator.CalculateTargetDeadline(startTimeUtc, policy, holidays);

        var instance = new SlaInstance
        {
            PolicyId = policy.Id,
            Module = request.Module,
            ActivityType = request.ActivityType,
            EntityId = request.EntityId,
            EntityReference = request.EntityReference,
            CurrentStage = request.Stage,
            Status = SlaInstanceStatus.Tracking,
            Priority = request.Priority,
            StartedAtUtc = startTimeUtc,
            TargetDeadlineUtc = deadlineUtc,
            RecipientEmployeeId = request.RecipientEmployeeId,
            ProjectId = request.ProjectId,
            CustomPayloadJson = request.CustomPayloadJson ?? "{}"
        };

        db.SlaInstances.Add(instance);
        await db.SaveChangesAsync(ct);

        // 3. Schedule Hangfire milestone jobs
        await ScheduleMilestonesAsync(instance, policy, DateTime.UtcNow, ct);

        logger.LogInformation(
            "[SLA Tracking] Started tracking for Entity {EntityId} ({ActivityType}, Stage: {Stage}). TargetDeadline: {Deadline:u}",
            instance.EntityId,
            instance.ActivityType,
            instance.CurrentStage,
            instance.TargetDeadlineUtc);

        return instance;
    }

    public async Task<SlaInstance> TransitionStageAsync(SlaStageTransitionRequest request, CancellationToken ct = default)
    {
        var instance = await GetActiveInstanceOrThrowAsync(request.EntityId, request.ActivityType, ct);

        // Cancel pending jobs from the old stage
        await CancelPendingJobsAsync(instance.Id, ct);

        var oldStage = instance.CurrentStage;
        instance.CurrentStage = request.NewStage;

        // Resolve policy for the new stage
        var policy = await policyService.GetPolicyAsync(instance.Module, instance.ActivityType, request.NewStage, ct)
                     ?? await policyService.GetPolicyAsync(instance.Module, instance.ActivityType, "Default", ct);

        if (policy != null && policy.TatDurationMinutes > 0)
        {
            // Recalculate deadline for new stage from current moment
            instance.TargetDeadlineUtc = deadlineCalculator.CalculateTargetDeadline(DateTime.UtcNow, policy);
        }

        // Record transition audit event
        var transitionEvent = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.StageTransition,
            ScheduledAtUtc = DateTime.UtcNow,
            ExecutedAtUtc = DateTime.UtcNow,
            Status = SlaEventStatus.Executed,
            StageAtExecution = request.NewStage,
            ExecutionLog = $"Stage transitioned from '{oldStage}' to '{request.NewStage}'. Reason: {request.Reason ?? "Workflow progression"}"
        };
        db.SlaEvents.Add(transitionEvent);
        await db.SaveChangesAsync(ct);

        // Schedule milestones for the new stage
        if (policy != null && instance.Status == SlaInstanceStatus.Tracking)
        {
            await ScheduleMilestonesAsync(instance, policy, DateTime.UtcNow, ct);
        }

        logger.LogInformation(
            "[SLA Tracking] Transitioned Entity {EntityId} ({ActivityType}) from Stage '{OldStage}' to '{NewStage}'. New Deadline: {Deadline:u}",
            instance.EntityId,
            instance.ActivityType,
            oldStage,
            instance.CurrentStage,
            instance.TargetDeadlineUtc);

        return instance;
    }

    public async Task<SlaInstance> PauseTrackingAsync(SlaPauseResumeRequest request, CancellationToken ct = default)
    {
        var instance = await GetActiveInstanceOrThrowAsync(request.EntityId, request.ActivityType, ct);

        if (instance.Status == SlaInstanceStatus.Paused)
        {
            return instance;
        }

        await CancelPendingJobsAsync(instance.Id, ct);

        instance.Status = SlaInstanceStatus.Paused;
        instance.PausedAtUtc = DateTime.UtcNow;

        var pauseEvent = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Paused,
            ScheduledAtUtc = DateTime.UtcNow,
            ExecutedAtUtc = DateTime.UtcNow,
            Status = SlaEventStatus.Executed,
            StageAtExecution = instance.CurrentStage,
            ExecutionLog = $"Tracking paused. Reason: {request.Reason ?? "User or process pause"}"
        };
        db.SlaEvents.Add(pauseEvent);
        await db.SaveChangesAsync(ct);

        logger.LogInformation(
            "[SLA Tracking] Paused tracking for Entity {EntityId} ({ActivityType}).",
            instance.EntityId,
            instance.ActivityType);

        return instance;
    }

    public async Task<SlaInstance> ResumeTrackingAsync(SlaPauseResumeRequest request, CancellationToken ct = default)
    {
        var instance = await GetActiveInstanceOrThrowAsync(request.EntityId, request.ActivityType, ct);

        if (instance.Status != SlaInstanceStatus.Paused || !instance.PausedAtUtc.HasValue)
        {
            return instance;
        }

        var pausedDuration = DateTime.UtcNow - instance.PausedAtUtc.Value;
        instance.TotalPausedSeconds += (int)pausedDuration.TotalSeconds;

        // Resolve policy for working hour adjustments
        var policy = await policyService.GetPolicyAsync(instance.Module, instance.ActivityType, instance.CurrentStage, ct);
        if (policy != null)
        {
            instance.TargetDeadlineUtc = deadlineCalculator.AdjustDeadlineForPause(
                instance.TargetDeadlineUtc,
                pausedDuration,
                policy.CalculationMode,
                policy.WorkingHoursStart,
                policy.WorkingHoursEnd,
                policy.ExcludeWeekends,
                policy.ExcludeHolidays);
        }
        else
        {
            instance.TargetDeadlineUtc = instance.TargetDeadlineUtc.Add(pausedDuration);
        }

        instance.Status = SlaInstanceStatus.Tracking;
        instance.PausedAtUtc = null;

        var resumeEvent = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Resumed,
            ScheduledAtUtc = DateTime.UtcNow,
            ExecutedAtUtc = DateTime.UtcNow,
            Status = SlaEventStatus.Executed,
            StageAtExecution = instance.CurrentStage,
            ExecutionLog = $"Tracking resumed after {(int)pausedDuration.TotalMinutes} minutes. Extended Deadline: {instance.TargetDeadlineUtc:u}. Reason: {request.Reason ?? "Resumed"}"
        };
        db.SlaEvents.Add(resumeEvent);
        await db.SaveChangesAsync(ct);

        if (policy != null)
        {
            await ScheduleMilestonesAsync(instance, policy, DateTime.UtcNow, ct);
        }

        logger.LogInformation(
            "[SLA Tracking] Resumed tracking for Entity {EntityId} ({ActivityType}). New Deadline: {Deadline:u}",
            instance.EntityId,
            instance.ActivityType,
            instance.TargetDeadlineUtc);

        return instance;
    }

    public async Task<SlaInstance> CompleteTrackingAsync(Guid entityId, string activityType, CancellationToken ct = default)
    {
        var instance = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == entityId
                                      && i.ActivityType == activityType
                                      && i.Status != SlaInstanceStatus.Completed
                                      && i.Status != SlaInstanceStatus.Cancelled
                                      && i.DeletedAtUtc == null, ct);

        if (instance == null)
        {
            logger.LogInformation("[SLA Tracking] No active instance to complete for Entity {EntityId}, Activity {ActivityType}.", entityId, activityType);
            var completed = await db.SlaInstances
                .OrderByDescending(i => i.CreatedAtUtc)
                .FirstOrDefaultAsync(i => i.EntityId == entityId && i.ActivityType == activityType && i.DeletedAtUtc == null, ct);
            return completed ?? throw new InvalidOperationException($"SLA instance not found for Entity {entityId}, Activity {activityType}");
        }

        await CancelPendingJobsAsync(instance.Id, ct);

        instance.Status = SlaInstanceStatus.Completed;
        instance.CompletedAtUtc = DateTime.UtcNow;

        var completeEvent = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Completed,
            ScheduledAtUtc = DateTime.UtcNow,
            ExecutedAtUtc = DateTime.UtcNow,
            Status = SlaEventStatus.Executed,
            StageAtExecution = instance.CurrentStage,
            ExecutionLog = $"Activity completed at {DateTime.UtcNow:u}. Met SLA: {instance.CompletedAtUtc <= instance.TargetDeadlineUtc}"
        };
        db.SlaEvents.Add(completeEvent);
        await db.SaveChangesAsync(ct);

        logger.LogInformation(
            "[SLA Tracking] Completed tracking for Entity {EntityId} ({ActivityType}). Target: {Deadline:u}, CompletedAt: {CompletedAt:u}",
            instance.EntityId,
            instance.ActivityType,
            instance.TargetDeadlineUtc,
            instance.CompletedAtUtc);

        return instance;
    }

    public async Task<SlaInstance> CancelTrackingAsync(Guid entityId, string activityType, string? reason = null, CancellationToken ct = default)
    {
        var instance = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == entityId
                                      && i.ActivityType == activityType
                                      && i.Status != SlaInstanceStatus.Completed
                                      && i.Status != SlaInstanceStatus.Cancelled
                                      && i.DeletedAtUtc == null, ct);

        if (instance == null)
        {
            var existing = await db.SlaInstances
                .OrderByDescending(i => i.CreatedAtUtc)
                .FirstOrDefaultAsync(i => i.EntityId == entityId && i.ActivityType == activityType && i.DeletedAtUtc == null, ct);
            return existing ?? throw new InvalidOperationException($"SLA instance not found for Entity {entityId}, Activity {activityType}");
        }

        await CancelPendingJobsAsync(instance.Id, ct);

        instance.Status = SlaInstanceStatus.Cancelled;
        instance.CancelledAtUtc = DateTime.UtcNow;

        var cancelEvent = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Cancelled,
            ScheduledAtUtc = DateTime.UtcNow,
            ExecutedAtUtc = DateTime.UtcNow,
            Status = SlaEventStatus.Executed,
            StageAtExecution = instance.CurrentStage,
            ExecutionLog = $"Tracking cancelled. Reason: {reason ?? "Request cancelled or deleted"}"
        };
        db.SlaEvents.Add(cancelEvent);
        await db.SaveChangesAsync(ct);

        logger.LogInformation(
            "[SLA Tracking] Cancelled tracking for Entity {EntityId} ({ActivityType}).",
            instance.EntityId,
            instance.ActivityType);

        return instance;
    }

    public async Task<SlaInstance> RescheduleTrackingAsync(SlaRescheduleRequest request, CancellationToken ct = default)
    {
        var instance = await GetActiveInstanceOrThrowAsync(request.EntityId, request.ActivityType, ct);

        await CancelPendingJobsAsync(instance.Id, ct);

        var oldDeadline = instance.TargetDeadlineUtc;
        instance.TargetDeadlineUtc = request.NewDeadlineUtc;

        var rescheduleEvent = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.StageTransition,
            ScheduledAtUtc = DateTime.UtcNow,
            ExecutedAtUtc = DateTime.UtcNow,
            Status = SlaEventStatus.Executed,
            StageAtExecution = instance.CurrentStage,
            ExecutionLog = $"Deadline rescheduled from {oldDeadline:u} to {request.NewDeadlineUtc:u}. Reason: {request.Reason ?? "Timeline adjustment"}"
        };
        db.SlaEvents.Add(rescheduleEvent);
        await db.SaveChangesAsync(ct);

        var policy = await policyService.GetPolicyAsync(instance.Module, instance.ActivityType, instance.CurrentStage, ct);
        if (policy != null && instance.Status == SlaInstanceStatus.Tracking)
        {
            await ScheduleMilestonesAsync(instance, policy, DateTime.UtcNow, ct);
        }

        logger.LogInformation(
            "[SLA Tracking] Rescheduled Entity {EntityId} ({ActivityType}) deadline to {NewDeadline:u}.",
            instance.EntityId,
            instance.ActivityType,
            instance.TargetDeadlineUtc);

        return instance;
    }

    public async Task<SlaInstance?> GetInstanceAsync(Guid entityId, string activityType, CancellationToken ct = default)
    {
        return await db.SlaInstances
            .Include(i => i.Policy)
            .Include(i => i.Events.OrderBy(e => e.CreatedAtUtc))
            .AsNoTracking()
            .OrderByDescending(i => i.CreatedAtUtc)
            .FirstOrDefaultAsync(i => i.EntityId == entityId
                                      && i.ActivityType == activityType
                                      && i.DeletedAtUtc == null, ct);
    }

    private async Task<SlaInstance> GetActiveInstanceOrThrowAsync(Guid entityId, string activityType, CancellationToken ct)
    {
        var instance = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == entityId
                                      && i.ActivityType == activityType
                                      && i.Status != SlaInstanceStatus.Completed
                                      && i.Status != SlaInstanceStatus.Cancelled
                                      && i.DeletedAtUtc == null, ct);

        return instance ?? throw new InvalidOperationException(
            $"Active SLA instance not found for EntityId {entityId}, ActivityType {activityType}.");
    }

    private async Task ScheduleMilestonesAsync(
        SlaInstance instance,
        SlaPolicy policy,
        DateTime nowUtc,
        CancellationToken ct)
    {
        var holidays = await db.LeaveCalendarHolidays
            .AsNoTracking()
            .Where(h => h.DeletedAtUtc == null)
            .Select(h => h.HolidayDate)
            .ToHashSetAsync(ct);

        // 1. Reminders
        if (instance.ActivityType.Contains("Issue", StringComparison.OrdinalIgnoreCase))
        {
            // Recurring daily reminders for issues at 6:00 PM IST on working days only
            var firstReminderTime = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(
                instance.StartedAtUtc,
                holidays,
                policy.WorkingHoursEnd);

            if (firstReminderTime > nowUtc)
            {
                var delay = firstReminderTime - nowUtc;
                var reminderKey = $"sla:{instance.Id}:rem:{firstReminderTime:yyyy-MM-dd}";

                var reminderEvent = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.Reminder,
                    ScheduledAtUtc = firstReminderTime,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = policy.ResponsibleRoles.Count > 0
                        ? policy.ResponsibleRoles
                        : ["EngagementManager", "ProjectManager", "TeamLead"],
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = reminderKey
                };
                db.SlaEvents.Add(reminderEvent);
                await db.SaveChangesAsync(ct);

                var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteReminderAsync(instance.Id, reminderEvent.Id),
                    delay);

                reminderEvent.HangfireJobId = jobId;
            }
        }
        else if (instance.ActivityType.Equals("Task Pause", StringComparison.OrdinalIgnoreCase))
        {
            // Daily reminders for paused task aligned to the resource's assigned shift end
            var firstReminderTime = instance.TargetDeadlineUtc;

            if (firstReminderTime <= nowUtc && instance.RecipientEmployeeId.HasValue)
            {
                firstReminderTime = await deadlineCalculator.CalculateNextPauseReminderForEmployeeAsync(
                    nowUtc.AddMinutes(5),
                    instance.RecipientEmployeeId.Value,
                    holidays,
                    ct);
            }

            if (firstReminderTime > nowUtc)
            {
                var delay = firstReminderTime - nowUtc;
                var reminderKey = $"sla:{instance.Id}:rem:{firstReminderTime:yyyy-MM-dd-HH-mm}";

                var reminderEvent = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.Reminder,
                    ScheduledAtUtc = firstReminderTime,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = ["Assigned Resource"],
                    TargetRecipientIds = instance.RecipientEmployeeId.HasValue ? [instance.RecipientEmployeeId.Value] : [],
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = reminderKey
                };
                db.SlaEvents.Add(reminderEvent);
                await db.SaveChangesAsync(ct);

                var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteReminderAsync(instance.Id, reminderEvent.Id),
                    delay);

                reminderEvent.HangfireJobId = jobId;
            }
        }
        else if (instance.ActivityType.Equals("Task Deadline", StringComparison.OrdinalIgnoreCase))
        {
            // Midpoint reminder
            if (instance.TargetDeadlineUtc > instance.StartedAtUtc)
            {
                var midpoint = instance.StartedAtUtc.AddTicks((instance.TargetDeadlineUtc - instance.StartedAtUtc).Ticks / 2);
                if (midpoint > nowUtc)
                {
                    var delay = midpoint - nowUtc;
                    var reminderKey = $"sla:{instance.Id}:rem:midpoint";
                    var reminderEvent = new SlaEvent
                    {
                        InstanceId = instance.Id,
                        EventType = SlaEventType.Reminder,
                        ScheduledAtUtc = midpoint,
                        StageAtExecution = instance.CurrentStage,
                        TargetRoles = policy.ResponsibleRoles.Count > 0
                            ? policy.ResponsibleRoles
                            : ["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"],
                        Status = SlaEventStatus.Scheduled,
                        IdempotencyKey = reminderKey
                    };
                    db.SlaEvents.Add(reminderEvent);
                    await db.SaveChangesAsync(ct);

                    var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                        worker => worker.ExecuteReminderAsync(instance.Id, reminderEvent.Id),
                        delay);

                    reminderEvent.HangfireJobId = jobId;
                }
            }

            // One day before reminder
            var oneDayBefore = instance.TargetDeadlineUtc.AddDays(-1);
            if (oneDayBefore > nowUtc)
            {
                var delay = oneDayBefore - nowUtc;
                var reminderKey = $"sla:{instance.Id}:rem:1day";
                var reminderEvent = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.Reminder,
                    ScheduledAtUtc = oneDayBefore,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = policy.ResponsibleRoles.Count > 0
                        ? policy.ResponsibleRoles
                        : ["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"],
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = reminderKey
                };
                db.SlaEvents.Add(reminderEvent);
                await db.SaveChangesAsync(ct);

                var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteReminderAsync(instance.Id, reminderEvent.Id),
                    delay);

                reminderEvent.HangfireJobId = jobId;
            }
        }
        else if (!instance.ActivityType.Equals("Task Start After Assigning", StringComparison.OrdinalIgnoreCase))
        {
            // Standard policy intervals before deadline
            foreach (var intervalMinutes in policy.ReminderIntervals)
            {
                var reminderTime = instance.TargetDeadlineUtc.AddMinutes(-intervalMinutes);
                if (reminderTime > nowUtc)
                {
                    var delay = reminderTime - nowUtc;
                    var reminderEvent = new SlaEvent
                    {
                        InstanceId = instance.Id,
                        EventType = SlaEventType.Reminder,
                        ScheduledAtUtc = reminderTime,
                        StageAtExecution = instance.CurrentStage,
                        TargetRoles = policy.ResponsibleRoles,
                        Status = SlaEventStatus.Scheduled,
                        IdempotencyKey = $"sla:{instance.Id}:rem:{reminderTime:yyyy-MM-dd-HH-mm}"
                    };
                    db.SlaEvents.Add(reminderEvent);
                    await db.SaveChangesAsync(ct);

                    var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                        worker => worker.ExecuteReminderAsync(instance.Id, reminderEvent.Id),
                        delay);

                    reminderEvent.HangfireJobId = jobId;
                }
            }
        }

        // 2. Breach Check at TargetDeadlineUtc (Task Pause does not have breach checks)
        if (!instance.ActivityType.Equals("Task Pause", StringComparison.OrdinalIgnoreCase) && instance.TargetDeadlineUtc > nowUtc)
        {
            var delay = instance.TargetDeadlineUtc - nowUtc;
            var breachEvent = new SlaEvent
            {
                InstanceId = instance.Id,
                EventType = SlaEventType.BreachCheck,
                ScheduledAtUtc = instance.TargetDeadlineUtc,
                StageAtExecution = instance.CurrentStage,
                Status = SlaEventStatus.Scheduled,
                IdempotencyKey = $"sla:{instance.Id}:breach"
            };
            db.SlaEvents.Add(breachEvent);
            await db.SaveChangesAsync(ct);

            var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                worker => worker.ExecuteBreachCheckAsync(instance.Id, breachEvent.Id),
                delay);

            breachEvent.HangfireJobId = jobId;
            instance.ActiveHangfireJobId = jobId;
        }

        // 3. Level 1 Escalation (Task Pause does not have escalations)
        if (!instance.ActivityType.Equals("Task Pause", StringComparison.OrdinalIgnoreCase)
            && policy.FirstEscalationAfterMinutes.HasValue && policy.FirstEscalationAfterMinutes.Value >= 0)
        {
            var esc1Time = instance.TargetDeadlineUtc.AddMinutes(policy.FirstEscalationAfterMinutes.Value);
            if (esc1Time > nowUtc)
            {
                var delay = esc1Time - nowUtc;
                var esc1Event = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL1,
                    ScheduledAtUtc = esc1Time,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = policy.FirstEscalationRoles.Count > 0
                        ? policy.FirstEscalationRoles
                        : ["Assigned Senior Project Manager"],
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = $"sla:{instance.Id}:esc-l1"
                };
                db.SlaEvents.Add(esc1Event);
                await db.SaveChangesAsync(ct);

                var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteEscalationAsync(instance.Id, esc1Event.Id, 1),
                    delay);

                esc1Event.HangfireJobId = jobId;
            }
        }

        // 4. Level 2 Escalation (Issues, Task Start, Task Deadline, and WBS Escalation dynamically schedule L2 upon actual L1 execution)
        var isDynamicL2 = instance.ActivityType.Contains("Issue", StringComparison.OrdinalIgnoreCase)
                          || instance.ActivityType.Equals("Task Start After Assigning", StringComparison.OrdinalIgnoreCase)
                          || instance.ActivityType.Equals("Task Deadline", StringComparison.OrdinalIgnoreCase)
                          || instance.ActivityType.Equals("Task Pause", StringComparison.OrdinalIgnoreCase)
                          || instance.ActivityType.Equals("WBS Escalation", StringComparison.OrdinalIgnoreCase)
                          || instance.ActivityType.Equals("Service Escalation", StringComparison.OrdinalIgnoreCase);

        if (!isDynamicL2
            && policy.SecondEscalationAfterMinutes.HasValue
            && policy.SecondEscalationAfterMinutes.Value > 0)
        {
            var esc2Time = instance.TargetDeadlineUtc.AddMinutes(policy.SecondEscalationAfterMinutes.Value);
            if (esc2Time > nowUtc)
            {
                var delay = esc2Time - nowUtc;
                var esc2Event = new SlaEvent
                {
                    InstanceId = instance.Id,
                    EventType = SlaEventType.EscalationL2,
                    ScheduledAtUtc = esc2Time,
                    StageAtExecution = instance.CurrentStage,
                    TargetRoles = policy.SecondEscalationRoles,
                    Status = SlaEventStatus.Scheduled,
                    IdempotencyKey = $"sla:{instance.Id}:esc-l2"
                };
                db.SlaEvents.Add(esc2Event);
                await db.SaveChangesAsync(ct);

                var jobId = BackgroundJob.Schedule<SlaBackgroundJobWorker>(
                    worker => worker.ExecuteEscalationAsync(instance.Id, esc2Event.Id, 2),
                    delay);

                esc2Event.HangfireJobId = jobId;
            }
        }

        await db.SaveChangesAsync(ct);
    }

    private async Task CancelPendingJobsAsync(Guid instanceId, CancellationToken ct)
    {
        var pendingEvents = await db.SlaEvents
            .Where(e => e.InstanceId == instanceId && e.Status == SlaEventStatus.Scheduled)
            .ToListAsync(ct);

        foreach (var ev in pendingEvents)
        {
            if (!string.IsNullOrEmpty(ev.HangfireJobId))
            {
                try
                {
                    BackgroundJob.Delete(ev.HangfireJobId);
                }
                catch (Exception ex)
                {
                    logger.LogWarning(ex, "[SLA Tracking] Failed to delete Hangfire job {JobId} for Event {EventId}.", ev.HangfireJobId, ev.Id);
                }
            }

            ev.Status = SlaEventStatus.Cancelled;
            ev.ExecutionLog = "Cancelled by SLA lifecycle transition/pause/reschedule.";
        }

        await db.SaveChangesAsync(ct);
    }
}
