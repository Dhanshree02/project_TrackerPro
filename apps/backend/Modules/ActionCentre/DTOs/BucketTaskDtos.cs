namespace PMS.API.Modules.ActionCentre.DTOs;

/// <summary>
/// DTO representing an assigned task within the Action Centre → Bucket List.
/// </summary>
public record BucketTaskDto(
    Guid AssignmentId,
    Guid TaskId,
    string TaskTitle,
    Guid ProjectId,
    string ProjectName,
    string? ProjectCode,
    string Priority,
    DateOnly? DueDate,
    bool IsOverdue,
    string Status, // "Not Started", "Ongoing", "Paused", "Stopped", "Completed"
    Guid EmployeeId,
    string EmployeeName,
    string? AssignedByName,
    DateTime? StartedAtUtc,
    DateTime? CompletedAtUtc,
    long ElapsedSeconds,
    bool IsTimerRunning,
    DateTime? TimerStartedAtUtc,
    decimal EstimatedHours,
    decimal UtilizedHours,
    decimal RemainingHours
);

/// <summary>
/// Query filters for the Bucket List endpoint.
/// </summary>
public record BucketTaskFilterParams(
    string? Search = null,
    string? Status = null, // "all", "todo", "in_progress", "done"
    string? Priority = null, // "all", "low", "medium", "high", "critical"
    Guid? ProjectId = null,
    string? EmployeeId = null,
    bool? OverdueOnly = null,
    int Page = 1,
    int PerPage = 50
);

/// <summary>
/// Response payload for timer actions (start, pause, resume, complete).
/// </summary>
public record TimerActionResponseDto(
    Guid AssignmentId,
    Guid TaskId,
    Guid EmployeeId,
    string Status,
    bool IsTimerRunning,
    DateTime? TimerStartedAtUtc,
    long TotalAccumulatedSeconds,
    decimal UtilizedHours,
    string Message
);
