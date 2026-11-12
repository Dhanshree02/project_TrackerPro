using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.DTOs;

public sealed record SlaStartTrackingRequest(
    string Module,
    string ActivityType,
    Guid EntityId,
    string? EntityReference = null,
    string Stage = "Default",
    SlaPriority Priority = SlaPriority.Medium,
    Guid? RecipientEmployeeId = null,
    Guid? ProjectId = null,
    string? CustomPayloadJson = null,
    DateTime? CustomStartTimeUtc = null,
    DateTime? CustomDeadlineUtc = null);

public sealed record SlaStageTransitionRequest(
    Guid EntityId,
    string ActivityType,
    string NewStage,
    string? Reason = null);

public sealed record SlaPauseResumeRequest(
    Guid EntityId,
    string ActivityType,
    string? Reason = null);

public sealed record SlaRescheduleRequest(
    Guid EntityId,
    string ActivityType,
    DateTime NewDeadlineUtc,
    string? Reason = null);

public sealed record SlaInstanceDto(
    Guid Id,
    Guid PolicyId,
    string Module,
    string ActivityType,
    Guid EntityId,
    string? EntityReference,
    string CurrentStage,
    string Status,
    string Priority,
    DateTime StartedAtUtc,
    DateTime TargetDeadlineUtc,
    DateTime? BreachedAtUtc,
    DateTime? CompletedAtUtc,
    DateTime? CancelledAtUtc,
    DateTime? PausedAtUtc,
    int TotalPausedSeconds,
    Guid? RecipientEmployeeId,
    Guid? ProjectId);
