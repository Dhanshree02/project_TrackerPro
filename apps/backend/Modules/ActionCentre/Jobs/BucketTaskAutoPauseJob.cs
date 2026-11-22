using Hangfire;
using Microsoft.Extensions.Logging;
using PMS.API.Modules.ActionCentre.Services;

namespace PMS.API.Modules.ActionCentre.Jobs;

/// <summary>
/// Hangfire recurring job to inspect actively running bucket list task timers,
/// automatically pausing any task that has been running continuously for 12 hours or more,
/// and capping the credited working time for that abandoned session to 8 hours (standard shift duration).
/// </summary>
public sealed class BucketTaskAutoPauseJob(
    IBucketTaskService bucketTaskService,
    ILogger<BucketTaskAutoPauseJob> logger)
{
    [JobDisplayName("Bucket Task | Shift Auto-Pause Over-12-Hour Timers (8h Cap)")]
    public async Task ExecuteAsync(CancellationToken ct = default)
    {
        logger.LogInformation("Starting recurring Bucket Task Auto-Pause Job execution.");
        try
        {
            var count = await bucketTaskService.AutoPauseAbandonedTasksAsync(ct);
            if (count > 0)
            {
                logger.LogInformation("Bucket Task Auto-Pause Job completed successfully. Auto-paused {Count} abandoned task(s).", count);
            }
            else
            {
                logger.LogInformation("Bucket Task Auto-Pause Job executed. No abandoned tasks exceeded the 12-hour threshold.");
            }
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "An error occurred during Bucket Task Auto-Pause Job execution.");
            throw;
        }
    }
}
