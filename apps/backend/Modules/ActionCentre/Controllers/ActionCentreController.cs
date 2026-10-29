using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Controllers;

[ApiController]
[Route("api/v1/action-centre")]
public class ActionCentreController : ControllerBase
{
    private readonly IBucketTaskService _bucketTaskService;
    private readonly IActionNotificationService _notificationService;

    public ActionCentreController(
        IBucketTaskService bucketTaskService,
        IActionNotificationService notificationService)
    {
        _bucketTaskService = bucketTaskService;
        _notificationService = notificationService;
    }

    /// <summary>
    /// Gets assigned tasks in the Bucket List for the specified or current resource.
    /// Supports searching by task/project and filtering by status and priority.
    /// </summary>
    [HttpGet("bucket-list")]
    public async Task<ActionResult<ApiResponse<PagedResult<BucketTaskDto>>>> GetBucketList(
        [FromQuery] BucketTaskQueryParameters query,
        CancellationToken ct = default)
    {
        var result = await _bucketTaskService.GetBucketTasksAsync(query, ct);
        return Ok(ApiResponse<PagedResult<BucketTaskDto>>.Ok(result, new ApiMeta
        {
            Total = result.Total,
            Page = result.Page,
            PerPage = result.PerPage,
            TotalPages = result.TotalPages,
        }));
    }

    /// <summary>
    /// Gets a single bucket list task by ID.
    /// </summary>
    [HttpGet("bucket-list/{id:guid}")]
    public async Task<ActionResult<ApiResponse<BucketTaskDto>>> GetBucketTaskById(
        Guid id,
        CancellationToken ct = default)
    {
        var item = await _bucketTaskService.GetBucketTaskByIdAsync(id, ct);
        if (item == null)
        {
            return NotFound(ApiResponse<BucketTaskDto>.Fail("NOT_FOUND", $"Bucket task '{id}' not found."));
        }

        return Ok(ApiResponse<BucketTaskDto>.Ok(item));
    }

    /// <summary>
    /// Starts the task timer and records the Actual Start date on the task.
    /// </summary>
    [HttpPost("bucket-list/{id:guid}/start-timer")]
    public async Task<ActionResult<ApiResponse<BucketTaskDto>>> StartTimer(
        Guid id,
        CancellationToken ct = default)
    {
        var result = await _bucketTaskService.StartBucketTaskTimerAsync(id, ct);
        return Ok(ApiResponse<BucketTaskDto>.Ok(result));
    }

    /// <summary>
    /// Pauses the task timer and accumulates elapsed working time.
    /// </summary>
    [HttpPost("bucket-list/{id:guid}/pause-timer")]
    public async Task<ActionResult<ApiResponse<BucketTaskDto>>> PauseTimer(
        Guid id,
        CancellationToken ct = default)
    {
        var result = await _bucketTaskService.PauseBucketTaskTimerAsync(id, ct);
        return Ok(ApiResponse<BucketTaskDto>.Ok(result));
    }

    /// <summary>
    /// Stops the task timer and accumulates elapsed working time.
    /// </summary>
    [HttpPost("bucket-list/{id:guid}/stop-timer")]
    public async Task<ActionResult<ApiResponse<BucketTaskDto>>> StopTimer(
        Guid id,
        CancellationToken ct = default)
    {
        var result = await _bucketTaskService.StopBucketTaskTimerAsync(id, ct);
        return Ok(ApiResponse<BucketTaskDto>.Ok(result));
    }

    /// <summary>
    /// Marks the task as Completed and records the Actual End date.
    /// </summary>
    [HttpPost("bucket-list/{id:guid}/complete")]
    public async Task<ActionResult<ApiResponse<BucketTaskDto>>> CompleteTask(
        Guid id,
        CancellationToken ct = default)
    {
        var result = await _bucketTaskService.CompleteBucketTaskAsync(id, ct);
        return Ok(ApiResponse<BucketTaskDto>.Ok(result));
    }

    /// <summary>
    /// Updates the status/stage of the bucket task and synchronizes the node task.
    /// </summary>
    [HttpPatch("bucket-list/{id:guid}/status")]
    public async Task<ActionResult<ApiResponse<BucketTaskDto>>> UpdateStatus(
        Guid id,
        [FromBody] UpdateBucketTaskStatusRequest request,
        CancellationToken ct = default)
    {
        var result = await _bucketTaskService.UpdateBucketTaskStatusAsync(id, request.Status, ct);
        return Ok(ApiResponse<BucketTaskDto>.Ok(result));
    }

    /// <summary>
    /// Synchronizes project task assignments into the Action Center bucket list.
    /// </summary>
    [HttpPost("bucket-list/sync")]
    public async Task<ActionResult<ApiResponse<bool>>> SyncAssignments(
        [FromQuery] Guid? projectId = null,
        [FromQuery] Guid? taskId = null,
        CancellationToken ct = default)
    {
        await _bucketTaskService.SyncBucketTasksFromAssignmentsAsync(projectId, taskId, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    // ── Notifications ────────────────────────────────────────────────────────

    /// <summary>
    /// Gets Action Centre notifications for the current authenticated employee / manager.
    /// </summary>
    [HttpGet("notifications")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ActionNotificationDto>>>> GetNotifications(
        [FromQuery] NotificationQueryParameters query,
        CancellationToken ct = default)
    {
        var items = await _notificationService.GetNotificationsAsync(query, ct);
        return Ok(ApiResponse<IReadOnlyList<ActionNotificationDto>>.Ok(items));
    }

    /// <summary>
    /// Acknowledges an Action Centre notification with a required comment.
    /// </summary>
    [HttpPut("notifications/{id:guid}/acknowledge")]
    public async Task<ActionResult<ApiResponse<ActionNotificationDto>>> AcknowledgeNotification(
        Guid id,
        [FromBody] AcknowledgeNotificationRequest request,
        CancellationToken ct = default)
    {
        var updated = await _notificationService.AcknowledgeNotificationAsync(id, request.Comment, ct);
        return Ok(ApiResponse<ActionNotificationDto>.Ok(updated));
    }

    /// <summary>
    /// Marks an Action Centre notification as read.
    /// </summary>
    [HttpPut("notifications/{id:guid}/read")]
    public async Task<ActionResult<ApiResponse<ActionNotificationDto>>> MarkNotificationAsRead(
        Guid id,
        CancellationToken ct = default)
    {
        var updated = await _notificationService.MarkNotificationAsReadAsync(id, ct);
        return Ok(ApiResponse<ActionNotificationDto>.Ok(updated));
    }

    // ── Alerts ───────────────────────────────────────────────────────────────

    /// <summary>
    /// Gets Action Centre governance and health alerts for the current authenticated employee / manager.
    /// </summary>
    [HttpGet("alerts")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ActionAlertDto>>>> GetAlerts(
        [FromQuery] NotificationQueryParameters query,
        CancellationToken ct = default)
    {
        var items = await _notificationService.GetAlertsAsync(query, ct);
        return Ok(ApiResponse<IReadOnlyList<ActionAlertDto>>.Ok(items));
    }

    /// <summary>
    /// Updates governance details and status for an Action Centre alert.
    /// </summary>
    [HttpPut("alerts/{id:guid}/governance")]
    public async Task<ActionResult<ApiResponse<ActionAlertDto>>> UpdateAlertGovernance(
        Guid id,
        [FromBody] UpdateAlertGovernanceRequest request,
        CancellationToken ct = default)
    {
        var updated = await _notificationService.UpdateAlertGovernanceAsync(id, request, ct);
        return Ok(ApiResponse<ActionAlertDto>.Ok(updated));
    }
}
