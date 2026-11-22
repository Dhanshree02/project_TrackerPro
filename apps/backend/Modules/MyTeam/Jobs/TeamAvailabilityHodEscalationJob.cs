using Hangfire;
using Microsoft.Extensions.Logging;
using PMS.API.Modules.MyTeam.Services;

namespace PMS.API.Modules.MyTeam.Jobs;

/// <summary>
/// Hangfire recurring job running next day by EOD (18:00 IST)
/// to escalate unresolved prior-day Team Availability & Shift Coverage to Head of Department (HOD).
/// </summary>
public sealed class TeamAvailabilityHodEscalationJob(
    ITeamAvailabilityNotificationService notificationService,
    ILogger<TeamAvailabilityHodEscalationJob> logger)
{
    [JobDisplayName("My Team | Next-Day EOD HOD Escalation for Unresolved Shift Availability")]
    public async Task ExecuteAsync(CancellationToken ct = default)
    {
        logger.LogInformation("Starting Next-Day EOD HOD Escalation Job.");
        try
        {
            var count = await notificationService.SendHodNextDayEodEscalationAsync(null, ct);
            logger.LogInformation("Completed Next-Day EOD HOD Escalation Job. Dispatched {Count} escalations.", count);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Error occurred during Next-Day EOD HOD Escalation Job execution.");
            throw;
        }
    }
}
