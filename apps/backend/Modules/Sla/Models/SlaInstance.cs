using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Sla.Models;

/// <summary>
/// Tracks the live SLA lifecycle, progress, and stage state for a specific business entity.
/// </summary>
public class SlaInstance : BaseEntity
{
    public Guid PolicyId { get; set; }

    public string Module { get; set; } = string.Empty;

    public string ActivityType { get; set; } = string.Empty;

    /// <summary>
    /// ID of the tracked business record (e.g. AllocationId, ExtensionRequestId, TaskId).
    /// </summary>
    public Guid EntityId { get; set; }

    /// <summary>
    /// Optional human-readable business identifier (e.g. "ALLOC-21BB0AE5", "P004").
    /// </summary>
    public string? EntityReference { get; set; }

    /// <summary>
    /// Current activity stage (e.g. "PendingApproval", "InProgress").
    /// </summary>
    public string CurrentStage { get; set; } = "Default";

    public SlaInstanceStatus Status { get; set; } = SlaInstanceStatus.Tracking;

    public SlaPriority Priority { get; set; } = SlaPriority.Medium;

    public DateTime StartedAtUtc { get; set; } = DateTime.UtcNow;

    public DateTime TargetDeadlineUtc { get; set; }

    public DateTime? BreachedAtUtc { get; set; }

    public DateTime? CompletedAtUtc { get; set; }

    public DateTime? CancelledAtUtc { get; set; }

    public DateTime? PausedAtUtc { get; set; }

    /// <summary>
    /// Total seconds the instance has spent in Paused state.
    /// Added to TargetDeadlineUtc upon Resume.
    /// </summary>
    public int TotalPausedSeconds { get; set; } = 0;

    /// <summary>
    /// Hangfire Job ID of the currently active scheduled milestone/check.
    /// </summary>
    public string? ActiveHangfireJobId { get; set; }

    /// <summary>
    /// Responsible resource/employee ID (if assigned to a specific individual).
    /// </summary>
    public Guid? RecipientEmployeeId { get; set; }

    /// <summary>
    /// Associated project ID (if applicable).
    /// </summary>
    public Guid? ProjectId { get; set; }

    /// <summary>
    /// Additional context payload serialized as JSON.
    /// </summary>
    public string CustomPayloadJson { get; set; } = "{}";

    public virtual SlaPolicy? Policy { get; set; }

    public virtual ICollection<SlaEvent> Events { get; set; } = new List<SlaEvent>();
}
