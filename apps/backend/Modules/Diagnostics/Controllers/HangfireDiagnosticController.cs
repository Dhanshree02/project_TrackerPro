using Hangfire;
using Hangfire.Storage;
using Hangfire.Storage.Monitoring;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using PMS.API.Infrastructure.Hangfire;

namespace PMS.API.Modules.Diagnostics.Controllers;

/// <summary>
/// Diagnostic endpoints for Hangfire infrastructure verification.
/// Strictly restricted to administrative roles and disabled by default in production.
/// </summary>
[ApiController]
[Route("api/v1/diagnostics/hangfire")]
[Authorize(Roles = "Admin,CEO,CTO,COO,PMO,IT Admin")]
public sealed class HangfireDiagnosticController(IOptions<HangfireOptions> options) : ControllerBase
{
    private readonly HangfireOptions _options = options.Value;

    private IActionResult? CheckEnabled()
    {
        if (!_options.EnableDiagnosticEndpoints)
        {
            return NotFound(new
            {
                success = false,
                message = "Hangfire diagnostic endpoints are disabled in this environment."
            });
        }
        return null;
    }

    /// <summary>
    /// Enqueues an immediate test background job.
    /// Disabled unless Hangfire:EnableDiagnosticEndpoints is explicitly true.
    /// </summary>
    [HttpPost("enqueue")]
    public IActionResult EnqueueDiagnosticJob([FromQuery] string? tag)
    {
        var disabled = CheckEnabled();
        if (disabled != null) return disabled;

        var testId = string.IsNullOrWhiteSpace(tag)
            ? $"diag-{Guid.NewGuid():N}"
            : $"diag-{tag.Trim()}-{Guid.NewGuid():N}";

        var jobId = BackgroundJob.Enqueue<HangfireDiagnosticJob>(job =>
            job.RunDiagnostic(testId, DateTime.UtcNow));

        return Ok(new
        {
            success = true,
            jobId,
            testId,
            jobType = "Immediate",
            enqueuedAtUtc = DateTime.UtcNow,
            message = "Diagnostic job successfully enqueued to Hangfire."
        });
    }

    /// <summary>
    /// Schedules a delayed test background job to verify scheduler persistence.
    /// Disabled unless Hangfire:EnableDiagnosticEndpoints is explicitly true.
    /// </summary>
    [HttpPost("schedule")]
    public IActionResult ScheduleDiagnosticJob([FromQuery] int delaySeconds = 10, [FromQuery] string? tag = null)
    {
        var disabled = CheckEnabled();
        if (disabled != null) return disabled;

        if (delaySeconds < 1) delaySeconds = 1;
        if (delaySeconds > 300) delaySeconds = 300;

        var testId = string.IsNullOrWhiteSpace(tag)
            ? $"delayed-{Guid.NewGuid():N}"
            : $"delayed-{tag.Trim()}-{Guid.NewGuid():N}";

        var scheduledTime = DateTime.UtcNow.AddSeconds(delaySeconds);

        var jobId = BackgroundJob.Schedule<HangfireDiagnosticJob>(
            job => job.RunDiagnostic(testId, scheduledTime),
            TimeSpan.FromSeconds(delaySeconds));

        return Ok(new
        {
            success = true,
            jobId,
            testId,
            jobType = "Scheduled",
            delaySeconds,
            scheduledForUtc = scheduledTime,
            message = $"Diagnostic job scheduled for execution in {delaySeconds} seconds."
        });
    }

    /// <summary>
    /// Returns current Hangfire monitoring statistics and active server health.
    /// </summary>
    [HttpGet("status")]
    public IActionResult GetHangfireStatus()
    {
        var disabled = CheckEnabled();
        if (disabled != null) return disabled;

        var monitoringApi = JobStorage.Current.GetMonitoringApi();
        var stats = monitoringApi.GetStatistics();
        var servers = monitoringApi.Servers();

        return Ok(new
        {
            isHealthy = servers.Count > 0,
            serverCount = servers.Count,
            servers = servers.Select(s => new
            {
                name = s.Name,
                workersCount = s.WorkersCount,
                queues = s.Queues,
                heartbeat = s.Heartbeat
            }),
            statistics = new
            {
                enqueued = stats.Enqueued,
                scheduled = stats.Scheduled,
                processing = stats.Processing,
                succeeded = stats.Succeeded,
                failed = stats.Failed,
                deleted = stats.Deleted,
                recurring = stats.Recurring
            }
        });
    }
}
