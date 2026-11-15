using Microsoft.Extensions.Logging;
using PMS.API.Modules.Timesheets.Services;

namespace PMS.API.Modules.Timesheets.Jobs;

/// <summary>
/// Hangfire recurring job to process alternate-day timesheet submission reminders
/// during the active submission window (Friday through Monday deadline).
/// </summary>
public sealed class TimesheetReminderJob(
    ITimesheetNotificationService notificationService,
    ILogger<TimesheetReminderJob> logger)
{
    public async Task ExecuteAsync(CancellationToken ct = default)
    {
        logger.LogInformation("Starting recurring Timesheet Reminder Job execution.");
        try
        {
            var count = await notificationService.ProcessTimesheetRemindersAsync(null, ct);
            logger.LogInformation("Timesheet Reminder Job completed successfully. Dispatched {Count} reminders.", count);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "An error occurred during Timesheet Reminder Job execution.");
            throw;
        }
    }
}
