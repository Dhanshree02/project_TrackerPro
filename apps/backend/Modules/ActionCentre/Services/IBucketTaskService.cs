using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Services;

public interface IBucketTaskService
{
    /// <summary>
    /// Retrieves bucket list tasks for the current user (or specified employee if manager/admin).
    /// </summary>
    Task<PagedResult<BucketTaskDto>> GetBucketTasksAsync(
        BucketTaskFilterParams filters,
        CancellationToken ct = default);

    /// <summary>
    /// Starts timer for the assigned task. Automatically pauses any other active timer for this employee.
    /// </summary>
    Task<TimerActionResponseDto> StartTimerAsync(
        Guid assignmentId,
        CancellationToken ct = default);

    /// <summary>
    /// Pauses timer for the assigned task, accumulating elapsed working seconds.
    /// </summary>
    Task<TimerActionResponseDto> PauseTimerAsync(
        Guid assignmentId,
        CancellationToken ct = default);

    /// <summary>
    /// Resumes a paused timer for the assigned task. Automatically pauses any other running timer.
    /// </summary>
    Task<TimerActionResponseDto> ResumeTimerAsync(
        Guid assignmentId,
        CancellationToken ct = default);

    /// <summary>
    /// Marks the assigned task as completed and stops any active timer session.
    /// Synchronizes overall task stage with the originating Projects module.
    /// </summary>
    Task<TimerActionResponseDto> CompleteTaskAsync(
        Guid assignmentId,
        CancellationToken ct = default);
}
