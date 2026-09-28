namespace PMS.API.Modules.Projects.DTOs;

public sealed record ProjectTaskAssignmentDto(
    Guid Id,
    Guid TaskId,
    Guid EmployeeId,
    string EmployeeName,
    string EmployeeCode,
    string? EmployeeEmail,
    string Role,
    decimal? AllocatedHours,
    decimal UtilizedHours,
    DateTime? TimerStartedAtUtc,
    long TimerAccumulatedSeconds,
    bool IsActive,
    bool IsTimerRunning,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed record AssignTaskResourceRequest(
    Guid EmployeeId,
    string? Role = "Contributor",
    decimal? AllocatedHours = null);

public sealed record UpdateTaskAssignmentRequest(
    string? Role = null,
    decimal? AllocatedHours = null,
    decimal? UtilizedHours = null,
    bool? IsActive = null);

public sealed record SyncTaskAssignmentsRequest(IReadOnlyList<Guid>? EmployeeIds);

/// <summary>One line in the Task tab Assignment History Log.</summary>
public sealed record ProjectTaskAssignmentHistoryDto(
    Guid Id,
    Guid TaskId,
    Guid EmployeeId,
    string ResourceName,
    string Action,
    string TeamType,
    DateTime Timestamp);

/// <summary>Project Team + Shadow Team member available for task assignment.</summary>
public sealed record AssignableTaskResourceDto(
    Guid EmployeeId,
    string EmployeeName,
    string EmployeeCode,
    string? EmployeeRole,
    string TeamType,
    bool IsAssigned);

public sealed record TimerStatusDto(
    Guid AssignmentId,
    Guid TaskId,
    Guid EmployeeId,
    bool IsRunning,
    DateTime? StartedAtUtc,
    long TotalSeconds,
    decimal TotalHours);
