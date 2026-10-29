namespace PMS.API.Modules.ActionCentre.DTOs;

public record BucketTaskDto(
    Guid Id,
    Guid TaskId,
    Guid ProjectId,
    Guid? ProjectServiceId,
    Guid? AssignmentId,
    Guid EmployeeId,
    Guid? AssignedById,
    string? AssignedByName,
    string TaskTitle,
    string ProjectName,
    string Priority,
    DateOnly? DueDate,
    string Status,
    DateOnly? ActualStartDate,
    DateOnly? ActualEndDate,
    bool TimerRunning,
    DateTime? TimerStartedAtUtc,
    long TimerAccumulatedSeconds,
    long ElapsedTimeSeconds,
    decimal UtilizedHours,
    DateTime CreatedAtUtc
);

public class BucketTaskQueryParameters
{
    public Guid? EmployeeId { get; set; }

    public string? Search { get; set; }

    public string? Status { get; set; }

    public string? Priority { get; set; }

    public int Page { get; set; } = 1;

    public int PageSize { get; set; } = 50;
}

public record UpdateBucketTaskStatusRequest(
    string Status
);

public record BucketTaskTimerResponse(
    Guid Id,
    Guid TaskId,
    bool TimerRunning,
    DateTime? TimerStartedAtUtc,
    long ElapsedTimeSeconds,
    decimal UtilizedHours,
    DateOnly? ActualStartDate,
    DateOnly? ActualEndDate,
    string Status
);
