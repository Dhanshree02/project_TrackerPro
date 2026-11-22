using Hangfire;
using Microsoft.Extensions.Logging;
using PMS.API.Modules.MyTeam.Services;

namespace PMS.API.Modules.MyTeam.Jobs;

/// <summary>
/// Hangfire recurring job running daily at 1:00 PM IST (13:00 IST)
/// to escalate pending project resource availability to Senior Project Managers (SPMs).
/// </summary>
public sealed class TeamAvailabilitySpmAlertJob(
    ITeamAvailabilityNotificationService notificationService,
    ILogger<TeamAvailabilitySpmAlertJob> logger)
{
    [JobDisplayName("My Team | Daily SPM Project Availability Alert (1:00 PM)")]
    public async Task ExecuteAsync(CancellationToken ct = default)
    {
        logger.LogInformation("Starting Daily SPM Project Availability Alert Job (1:00 PM).");
        try
        {
            var count = await notificationService.SendSpmDailyAlertAsync(null, ct);
            logger.LogInformation("Completed Daily SPM Alert Job. Dispatched {Count} notifications.", count);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error occurred during Daily SPM Alert Job execution.");
            throw;
        }
    }
}
