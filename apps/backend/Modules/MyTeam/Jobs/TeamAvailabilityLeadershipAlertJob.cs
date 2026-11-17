using Hangfire;
using Microsoft.Extensions.Logging;
using PMS.API.Modules.MyTeam.Services;

namespace PMS.API.Modules.MyTeam.Jobs;

/// <summary>
/// Hangfire recurring job running daily at 11:00 AM and 12:00 PM IST
/// to alert Project Managers, Engagement Managers, and Team Leaders on project resource availability.
/// </summary>
public sealed class TeamAvailabilityLeadershipAlertJob(
    ITeamAvailabilityNotificationService notificationService,
    ILogger<TeamAvailabilityLeadershipAlertJob> logger)
{
    [JobDisplayName("My Team | Daily Leadership Project Availability Alert | {0}:00")]
    public async Task ExecuteAsync(int hour, CancellationToken ct = default)
    {
        logger.LogInformation("Starting Daily Leadership Project Availability Alert Job for {Hour}:00.", hour);
        try
        {
            var count = await notificationService.SendProjectLeadershipDailyAlertAsync(hour, null, ct);
            logger.LogInformation("Completed Daily Leadership Alert Job for {Hour}:00. Dispatched {Count} notifications.", hour, count);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error occurred during Daily Leadership Alert Job execution for {Hour}:00.", hour);
            throw;
        }
    }
}
