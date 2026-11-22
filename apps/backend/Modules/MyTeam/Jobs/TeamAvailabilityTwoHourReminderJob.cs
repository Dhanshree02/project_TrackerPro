using Hangfire;
using Microsoft.Extensions.Logging;
using PMS.API.Modules.MyTeam.Services;

namespace PMS.API.Modules.MyTeam.Jobs;

/// <summary>
/// Hangfire recurring job running every 2 hours during working hours (09:00 - 17:00 IST)
/// to remind Reporting Managers with pending reportee Team Availability & Shift Coverage updates.
/// </summary>
public sealed class TeamAvailabilityTwoHourReminderJob(
    ITeamAvailabilityNotificationService notificationService,
    ILogger<TeamAvailabilityTwoHourReminderJob> logger)
{
    [JobDisplayName("My Team | 2-Hour Reporting Manager Availability & Shift Reminders")]
    public async Task ExecuteAsync(CancellationToken ct = default)
    {
        logger.LogInformation("Starting 2-Hour Reporting Manager Availability & Shift Reminder Job.");
        try
        {
            var count = await notificationService.SendReportingManagerTwoHourRemindersAsync(null, ct);
            logger.LogInformation("Completed 2-Hour Reporting Manager Reminder Job. Dispatched {Count} notifications.", count);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error occurred during 2-Hour Reporting Manager Reminder Job execution.");
            throw;
        }
    }
}
