using Microsoft.Extensions.Logging;
using PMS.API.Modules.Resources.Services;

namespace PMS.API.Modules.Resources.Jobs;

/// <summary>
/// Hangfire recurring job that executes daily at 09:00 IST (03:30 UTC) to process:
/// 1. Two-day recurring LWD reminders to Engagement Managers until the employee's Last Working Day.
/// 2. Post-offboarding notifications to HOD and assigned Senior Project Managers on the next calendar date after LWD.
/// </summary>
public sealed class EmployeeOffboardingReminderJob(
    IOffboardingNotificationService offboardingNotificationService,
    ILogger<EmployeeOffboardingReminderJob> logger)
{
    public async Task ExecuteAsync(CancellationToken ct = default)
    {
        logger.LogInformation("Starting Employee Offboarding Reminder Job execution.");
        try
        {
            var reminderCount = await offboardingNotificationService.ProcessLwdRemindersAsync(null, ct);
            var postOffboardCount = await offboardingNotificationService.ProcessPostOffboardingNotificationsAsync(null, ct);
            logger.LogInformation(
                "Employee Offboarding Reminder Job completed successfully. Dispatched: {ReminderCount} LWD reminders, {PostCount} post-offboard notifications.",
                reminderCount, postOffboardCount);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "An error occurred during Employee Offboarding Reminder Job execution.");
            throw;
        }
    }
}
