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

public sealed record TimerStatusDto(
    Guid AssignmentId,
    Guid TaskId,
    Guid EmployeeId,
    bool IsRunning,
    DateTime? StartedAtUtc,
    long TotalSeconds,
    decimal TotalHours);
