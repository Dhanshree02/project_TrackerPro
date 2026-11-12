using PMS.API.Modules.Sla.DTOs;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Services;

/// <summary>
/// Core orchestration service for managing SLA lifecycles: starting,
/// stage transitions, pause, resume, reschedule, completion, and cancellation.
/// </summary>
public interface ISlaTrackingService
{
    Task<SlaInstance> StartTrackingAsync(SlaStartTrackingRequest request, CancellationToken ct = default);

    Task<SlaInstance> TransitionStageAsync(SlaStageTransitionRequest request, CancellationToken ct = default);

    Task<SlaInstance> PauseTrackingAsync(SlaPauseResumeRequest request, CancellationToken ct = default);

    Task<SlaInstance> ResumeTrackingAsync(SlaPauseResumeRequest request, CancellationToken ct = default);

    Task<SlaInstance> CompleteTrackingAsync(Guid entityId, string activityType, CancellationToken ct = default);

    Task<SlaInstance> CancelTrackingAsync(Guid entityId, string activityType, string? reason = null, CancellationToken ct = default);

    Task<SlaInstance> RescheduleTrackingAsync(SlaRescheduleRequest request, CancellationToken ct = default);

    Task<SlaInstance?> GetInstanceAsync(Guid entityId, string activityType, CancellationToken ct = default);
}
