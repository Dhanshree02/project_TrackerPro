using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Controllers;

[ApiController]
[Route("api/v1/alerts")]
public class AlertsController(IAlertService alertService) : ControllerBase
{
    /// <summary>
    /// Retrieves paged alerts filtered by category, severity, status, or search query.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<AlertDto>>>> GetAlerts(
        [FromQuery] AlertQueryParameters query,
        CancellationToken ct)
    {
        var result = await alertService.GetAlertsAsync(query, ct);
        return Ok(ApiResponse<PagedResult<AlertDto>>.Ok(result));
    }

    /// <summary>
    /// Retrieves summary counts for the Action Centre alerts dashboard metric cards.
    /// </summary>
    [HttpGet("metrics")]
    public async Task<ActionResult<ApiResponse<AlertMetricsDto>>> GetAlertMetrics(CancellationToken ct)
    {
        var metrics = await alertService.GetAlertMetricsAsync(ct);
        return Ok(ApiResponse<AlertMetricsDto>.Ok(metrics));
    }

    /// <summary>
    /// Retrieves full details and timeline history for a specific alert.
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<AlertDto>>> GetAlertById(Guid id, CancellationToken ct)
    {
        var alert = await alertService.GetAlertByIdAsync(id, ct);
        if (alert == null)
        {
            return NotFound(ApiResponse<AlertDto>.Fail("NOT_FOUND", "Alert not found."));
        }
        return Ok(ApiResponse<AlertDto>.Ok(alert));
    }

    /// <summary>
    /// Acknowledges an alert and records actor audit history.
    /// </summary>
    [HttpPost("{id:guid}/acknowledge")]
    public async Task<ActionResult<ApiResponse<AlertDto>>> AcknowledgeAlert(
        Guid id,
        [FromBody] AcknowledgeAlertRequest request,
        CancellationToken ct)
    {
        try
        {
            var alert = await alertService.AcknowledgeAlertAsync(id, request, ct);
            return Ok(ApiResponse<AlertDto>.Ok(alert));
        }
        catch (KeyNotFoundException)
        {
            return NotFound(ApiResponse<AlertDto>.Fail("NOT_FOUND", "Alert not found."));
        }
    }

    /// <summary>
    /// Resolves an alert with mandatory resolution details.
    /// </summary>
    [HttpPost("{id:guid}/resolve")]
    public async Task<ActionResult<ApiResponse<AlertDto>>> ResolveAlert(
        Guid id,
        [FromBody] ResolveAlertRequest request,
        CancellationToken ct)
    {
        try
        {
            var alert = await alertService.ResolveAlertAsync(id, request, ct);
            return Ok(ApiResponse<AlertDto>.Ok(alert));
        }
        catch (KeyNotFoundException)
        {
            return NotFound(ApiResponse<AlertDto>.Fail("NOT_FOUND", "Alert not found."));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ApiResponse<AlertDto>.Fail("VALIDATION_ERROR", ex.Message));
        }
    }

    /// <summary>
    /// Triggers an immediate scan across all BRD evaluation rules to detect breaches and update alerts.
    /// </summary>
    [HttpPost("scan")]
    public async Task<ActionResult<ApiResponse<object>>> TriggerScan(CancellationToken ct)
    {
        var count = await alertService.EvaluateAllAlertsAsync(ct);
        return Ok(ApiResponse<object>.Ok(new { scannedCount = count, message = "Alert scan completed successfully." }));
    }

    /// <summary>
    /// Retrieves historical on-bench resource counts captured at 10:30 AM, 2:30 PM, and 6:30 PM.
    /// </summary>
    [HttpGet("bench-snapshots")]
    public async Task<ActionResult<ApiResponse<List<BenchResourceSnapshotDto>>>> GetBenchSnapshots(
        [FromQuery] DateOnly? date,
        CancellationToken ct)
    {
        var snapshots = await alertService.GetBenchSnapshotsAsync(date, ct);
        return Ok(ApiResponse<List<BenchResourceSnapshotDto>>.Ok(snapshots));
    }
}
