using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.ActionCentre.Controllers;

[ApiController]
[Route("api/v1/action-centre/bucket-tasks")]
public class BucketTasksController(IBucketTaskService bucketTasks) : ControllerBase
{
    /// <summary>
    /// Retrieves assigned bucket list tasks for the current employee with optional filtering by status, priority, and search.
    /// Overdue tasks remain visible until completed.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<BucketTaskDto>>>> GetBucketTasks(
        [FromQuery] BucketTaskFilterParams filters,
        CancellationToken ct)
    {
        var result = await bucketTasks.GetBucketTasksAsync(filters, ct);
        return Ok(ApiResponse<PagedResult<BucketTaskDto>>.Ok(result, new ApiMeta
        {
            Total = result.Total,
            Page = result.Page,
            PerPage = result.PerPage,
            TotalPages = result.TotalPages
        }));
    }

    /// <summary>
    /// Starts the live timer for an assigned task.
    /// Automatically pauses any other active timer for this employee to prevent duplicate/conflicting sessions.
    /// </summary>
    [HttpPost("{assignmentId:guid}/start")]
    public async Task<ActionResult<ApiResponse<TimerActionResponseDto>>> StartTimer(
        Guid assignmentId,
        CancellationToken ct)
    {
        var result = await bucketTasks.StartTimerAsync(assignmentId, ct);
        return Ok(ApiResponse<TimerActionResponseDto>.Ok(result));
    }

    /// <summary>
    /// Pauses the live timer for an assigned task and persists accumulated working seconds.
    /// Automatically caps duration to configured daily working hours if user forgot to pause.
    /// </summary>
    [HttpPost("{assignmentId:guid}/pause")]
    public async Task<ActionResult<ApiResponse<TimerActionResponseDto>>> PauseTimer(
        Guid assignmentId,
        CancellationToken ct)
    {
        var result = await bucketTasks.PauseTimerAsync(assignmentId, ct);
        return Ok(ApiResponse<TimerActionResponseDto>.Ok(result));
    }

    /// <summary>
    /// Resumes the live timer for a paused task.
    /// </summary>
    [HttpPost("{assignmentId:guid}/resume")]
    public async Task<ActionResult<ApiResponse<TimerActionResponseDto>>> ResumeTimer(
        Guid assignmentId,
        CancellationToken ct)
    {
        var result = await bucketTasks.ResumeTimerAsync(assignmentId, ct);
        return Ok(ApiResponse<TimerActionResponseDto>.Ok(result));
    }

    /// <summary>
    /// Completes the task assignment and synchronizes execution stage with the originating Projects module.
    /// </summary>
    [HttpPost("{assignmentId:guid}/complete")]
    public async Task<ActionResult<ApiResponse<TimerActionResponseDto>>> CompleteTask(
        Guid assignmentId,
        CancellationToken ct)
    {
        var result = await bucketTasks.CompleteTaskAsync(assignmentId, ct);
        return Ok(ApiResponse<TimerActionResponseDto>.Ok(result));
    }
}
