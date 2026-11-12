using System.ComponentModel;
using Microsoft.Extensions.Logging;

namespace PMS.API.Infrastructure.Hangfire;

/// <summary>
/// Temporary diagnostic job used in Phase 1 to verify Hangfire background job
/// execution, persistent storage, scheduling, and DI resolution.
/// Strictly logging only - does NOT create notifications or alter business data.
/// </summary>
public sealed class HangfireDiagnosticJob(ILogger<HangfireDiagnosticJob> logger)
{
    [DisplayName("Diagnostic Health Check: {0}")]
    public void RunDiagnostic(string testId, DateTime scheduledAtUtc)
    {
        var executedAtUtc = DateTime.UtcNow;
        var latencyMs = (executedAtUtc - scheduledAtUtc).TotalMilliseconds;

        logger.LogInformation(
            "[Hangfire Diagnostic] Successfully executed background job. TestId: {TestId}, ScheduledAt: {ScheduledAtUtc:u}, ExecutedAt: {ExecutedAtUtc:u}, ExecutionLatency: {LatencyMs:F1}ms",
            testId,
            scheduledAtUtc,
            executedAtUtc,
            Math.Max(0, latencyMs));
    }
}
