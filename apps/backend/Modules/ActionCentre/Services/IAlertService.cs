using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Services;

public interface IAlertService
{
    Task<PagedResult<AlertDto>> GetAlertsAsync(AlertQueryParameters query, CancellationToken ct = default);
    Task<AlertMetricsDto> GetAlertMetricsAsync(CancellationToken ct = default);
    Task<AlertDto?> GetAlertByIdAsync(Guid id, CancellationToken ct = default);
    Task<AlertDto> AcknowledgeAlertAsync(Guid id, AcknowledgeAlertRequest request, CancellationToken ct = default);
    Task<AlertDto> ResolveAlertAsync(Guid id, ResolveAlertRequest request, CancellationToken ct = default);
    Task<BenchResourceSnapshotDto> CaptureBenchSnapshotAsync(string? timeSlot = null, CancellationToken ct = default);
    Task<List<BenchResourceSnapshotDto>> GetBenchSnapshotsAsync(DateOnly? date = null, CancellationToken ct = default);
    Task<int> EvaluateAllAlertsAsync(CancellationToken ct = default);
}
