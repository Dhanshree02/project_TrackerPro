using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace PMS.API.Modules.ActionCentre.Services;

/// <summary>
/// Background worker that periodically scans for TAT/SLA breaches across:
/// 1. Delivery (Projects & Tasks)
/// 2. Escalations & Issues
/// 3. Change Requests
/// 4. Timesheet Submissions & Approvals
/// And captures daily on-bench resource snapshots at BRD-mandated times (10:30 AM, 2:30 PM, 6:30 PM IST).
/// </summary>
public sealed class AlertScannerHostedService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<AlertScannerHostedService> _logger;

    // Scan frequency: every 15 minutes
    private static readonly TimeSpan ScanInterval = TimeSpan.FromMinutes(15);

    public AlertScannerHostedService(
        IServiceScopeFactory scopeFactory,
        ILogger<AlertScannerHostedService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("AlertScannerHostedService started. Running initial scan in 15 seconds...");

        // Initial delay to let DB migrations & seeds settle
        try
        {
            await Task.Delay(TimeSpan.FromSeconds(15), stoppingToken);
        }
        catch (OperationCanceledException)
        {
            return;
        }

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await RunScanCycleAsync(stoppingToken);
            }
            catch (Exception ex) when (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogError(ex, "Error occurred during AlertScanner scan cycle.");
            }

            try
            {
                await Task.Delay(ScanInterval, stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }
        }

        _logger.LogInformation("AlertScannerHostedService is stopping.");
    }

    private async Task RunScanCycleAsync(CancellationToken ct)
    {
        using var scope = _scopeFactory.CreateScope();
        var alertService = scope.ServiceProvider.GetRequiredService<IAlertService>();

        _logger.LogInformation("AlertScanner: Evaluating all TAT/SLA alert rules...");
        var generatedCount = await alertService.EvaluateAllAlertsAsync(ct);
        _logger.LogInformation("AlertScanner: Evaluation complete. Active/breached alerts detected: {Count}", generatedCount);

        // Check if any bench snapshots for 10:30 AM, 2:30 PM, or 6:30 PM IST need to be captured
        await CheckAndCaptureBenchSnapshotsAsync(alertService, ct);
    }

    private async Task CheckAndCaptureBenchSnapshotsAsync(IAlertService alertService, CancellationToken ct)
    {
        try
        {
            // IST is UTC+5:30
            var istNow = TimeZoneInfo.ConvertTimeFromUtc(
                DateTime.UtcNow,
                TimeZoneInfo.FindSystemTimeZoneById("India Standard Time"));

            var today = DateOnly.FromDateTime(istNow);
            var timeOfDay = istNow.TimeOfDay;

            var existingSnapshots = await alertService.GetBenchSnapshotsAsync(today, ct);
            var capturedSlots = existingSnapshots.Select(s => s.TimeSlot).ToHashSet(StringComparer.OrdinalIgnoreCase);

            // 10:30 AM slot (trigger if past 10:30)
            if (timeOfDay >= new TimeSpan(10, 30, 0) && !capturedSlots.Contains("10:30 AM"))
            {
                _logger.LogInformation("Capturing 10:30 AM bench resource snapshot...");
                await alertService.CaptureBenchSnapshotAsync("10:30 AM", ct);
            }

            // 2:30 PM slot (trigger if past 14:30)
            if (timeOfDay >= new TimeSpan(14, 30, 0) && !capturedSlots.Contains("02:30 PM"))
            {
                _logger.LogInformation("Capturing 02:30 PM bench resource snapshot...");
                await alertService.CaptureBenchSnapshotAsync("02:30 PM", ct);
            }

            // 6:30 PM slot (trigger if past 18:30)
            if (timeOfDay >= new TimeSpan(18, 30, 0) && !capturedSlots.Contains("06:30 PM"))
            {
                _logger.LogInformation("Capturing 06:30 PM bench resource snapshot...");
                await alertService.CaptureBenchSnapshotAsync("06:30 PM", ct);
            }
        }
        catch (TimeZoneNotFoundException)
        {
            // Fallback for non-Windows systems or systems without "India Standard Time"
            var istOffset = TimeSpan.FromHours(5.5);
            var istNow = DateTime.UtcNow.Add(istOffset);
            var today = DateOnly.FromDateTime(istNow);
            var timeOfDay = istNow.TimeOfDay;

            var existingSnapshots = await alertService.GetBenchSnapshotsAsync(today, ct);
            var capturedSlots = existingSnapshots.Select(s => s.TimeSlot).ToHashSet(StringComparer.OrdinalIgnoreCase);

            if (timeOfDay >= new TimeSpan(10, 30, 0) && !capturedSlots.Contains("10:30 AM"))
            {
                await alertService.CaptureBenchSnapshotAsync("10:30 AM", ct);
            }
            if (timeOfDay >= new TimeSpan(14, 30, 0) && !capturedSlots.Contains("02:30 PM"))
            {
                await alertService.CaptureBenchSnapshotAsync("02:30 PM", ct);
            }
            if (timeOfDay >= new TimeSpan(18, 30, 0) && !capturedSlots.Contains("06:30 PM"))
            {
                await alertService.CaptureBenchSnapshotAsync("06:30 PM", ct);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to capture scheduled bench snapshots.");
        }
    }
}
