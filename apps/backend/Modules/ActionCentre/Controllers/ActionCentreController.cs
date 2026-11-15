using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Controllers;

[ApiController]
[Route("api/v1/action-centre")]
[RequireRbac("action-centre", RbacAccessType.View, "action-center")]
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
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View)]
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
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View)]
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
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View)]
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
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View)]
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
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View)]
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
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View)]
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
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View)]
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
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View)]
    public async Task<ActionResult<ApiResponse<bool>>> SyncAssignments(
        [FromQuery] Guid? projectId = null,
        [FromQuery] Guid? taskId = null,
        CancellationToken ct = default)
    {
        await _bucketTaskService.SyncBucketTasksFromAssignmentsAsync(projectId, taskId, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    /// <summary>
    /// Gets assigned projects for the current authenticated employee for Bucket List issue raising.
    /// Accessible to any user with Action Centre Bucket List permissions.
    /// </summary>
    [HttpGet("bucket-list/assigned-projects")]
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View, "bucket-list", "action-centre")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<AssignedProjectSummaryDto>>>> GetBucketListAssignedProjects(
        [FromServices] IProjectIssueService issueService,
        CancellationToken ct = default)
    {
        var list = await issueService.GetEmployeeAssignedProjectsAsync(ct);
        return Ok(ApiResponse<IReadOnlyList<AssignedProjectSummaryDto>>.Ok(list));
    }

    /// <summary>
    /// Raises a project issue directly from the Action Centre bucket list for an assigned project.
    /// Accessible to any user with Action Centre Bucket List permissions without requiring Project Health permissions.
    /// </summary>
    [HttpPost("bucket-list/issues")]
    [HttpPost("bucket-list/raise-issue")]
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View, "bucket-list", "action-centre")]
    public async Task<ActionResult<ApiResponse<ProjectIssueDto>>> RaiseBucketListIssue(
        [FromBody] CreateProjectIssueRequest request,
        [FromServices] IProjectIssueService issueService,
        CancellationToken ct = default)
    {
        if (request.ProjectId == null || request.ProjectId == Guid.Empty)
        {
            return BadRequest(ApiResponse<ProjectIssueDto>.Fail("VALIDATION_ERROR", "Project is required."));
        }

        if (string.IsNullOrWhiteSpace(request.Subject) || string.IsNullOrWhiteSpace(request.Description))
        {
            return BadRequest(ApiResponse<ProjectIssueDto>.Fail("VALIDATION_ERROR", "All fields are required."));
        }

        var issue = await issueService.CreateIssueAsync(request.ProjectId.Value, request, ct);
        return Ok(ApiResponse<ProjectIssueDto>.Ok(issue));
    }

    /// <summary>
    /// Raises a project issue directly from the Action Centre bucket list for an assigned project route.
    /// </summary>
    [HttpPost("bucket-list/{projectId:guid}/issues")]
    [RequireRbac(RbacCatalogCodes.ActionBucketList, RbacAccessType.View, "bucket-list", "action-centre")]
    public async Task<ActionResult<ApiResponse<ProjectIssueDto>>> RaiseBucketListIssueWithRoute(
        Guid projectId,
        [FromBody] CreateProjectIssueRequest request,
        [FromServices] IProjectIssueService issueService,
        CancellationToken ct = default)
    {
        request.ProjectId = projectId;
        return await RaiseBucketListIssue(request, issueService, ct);
    }

    // ── Notifications ────────────────────────────────────────────────────────

    /// <summary>
    /// Gets Action Centre notifications for the current authenticated employee / manager.
    /// </summary>
    [HttpGet("notifications")]
    [RequireRbac(RbacCatalogCodes.ActionNotifications, RbacAccessType.View)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ActionNotificationDto>>>> GetNotifications(
        [FromQuery] NotificationQueryParameters query,
        CancellationToken ct = default)
    {
        var items = await _notificationService.GetNotificationsAsync(query, ct);
        return Ok(ApiResponse<IReadOnlyList<ActionNotificationDto>>.Ok(items));
    }

    /// <summary>
    /// Marks an Action Centre notification as read.
    /// </summary>
    [HttpPut("notifications/{id:guid}/read")]
    [RequireRbac(RbacCatalogCodes.ActionNotifications, RbacAccessType.View)]
    public async Task<ActionResult<ApiResponse<ActionNotificationDto>>> MarkNotificationAsRead(
        Guid id,
        CancellationToken ct = default)
    {
        var updated = await _notificationService.MarkNotificationAsReadAsync(id, ct);
        return Ok(ApiResponse<ActionNotificationDto>.Ok(updated));
    }

    /// <summary>
    /// Archives an Action Centre notification (moves it to the Archive tab by setting its status to Acknowledged).
    /// </summary>
    [HttpPut("notifications/{id:guid}/archive")]
    [RequireRbac(RbacCatalogCodes.ActionNotifications, RbacAccessType.View)]
    public async Task<ActionResult<ApiResponse<ActionNotificationDto>>> ArchiveNotification(
        Guid id,
        [FromBody] ArchiveNotificationRequest? request,
        CancellationToken ct = default)
    {
        var updated = await _notificationService.ArchiveNotificationAsync(id, request?.Comment, ct);
        return Ok(ApiResponse<ActionNotificationDto>.Ok(updated));
    }
    // ── Alerts ───────────────────────────────────────────────────────────────

    /// <summary>
    /// Gets Action Centre governance and health alerts for the current authenticated employee / manager.
    /// </summary>
    [HttpGet("alerts")]
    [RequireRbac(RbacCatalogCodes.ActionAlerts, RbacAccessType.View, "action-alerts", "action-centre")]
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
    [RequireRbac(RbacCatalogCodes.ActionAlerts, RbacAccessType.View, "action-alerts", "action-centre")]
    public async Task<ActionResult<ApiResponse<ActionAlertDto>>> UpdateAlertGovernance(
        Guid id,
        [FromBody] UpdateAlertGovernanceRequest request,
        CancellationToken ct = default)
    {
        var updated = await _notificationService.UpdateAlertGovernanceAsync(id, request, ct);
        return Ok(ApiResponse<ActionAlertDto>.Ok(updated));
    }

    /// <summary>
    /// Downloads the attachment file for a governance or escalation alert if present.
    /// </summary>
    [HttpGet("alerts/{id:guid}/attachment")]
    [RequireRbac(RbacCatalogCodes.ActionAlerts, RbacAccessType.View, "action-alerts", "action-centre")]
    public async Task<IActionResult> DownloadAlertAttachment(Guid id, CancellationToken ct = default)
    {
        var result = await _notificationService.DownloadAlertAttachmentAsync(id, ct);
        if (result == null)
        {
            return NotFound();
        }

        Response.Headers["Content-Disposition"] = $"inline; filename=\"{result.Value.FileName}\"";
        return File(result.Value.Stream, result.Value.ContentType);
    }

    /// <summary>
    /// Gets pending central approvals (e.g. Customer Requirements, etc.) for current user.
    /// </summary>
    [HttpGet("approvals")]
    [RequireRbac(RbacCatalogCodes.ActionApprovals, RbacAccessType.View, "action-center", "action-centre")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<PMS.API.Modules.Projects.DTOs.ProjectAdditionalRequirementDto>>>> GetApprovals(
        [FromServices] PMS.API.Modules.Projects.Services.IProjectAdditionalRequirementService requirementService,
        CancellationToken ct = default)
    {
        var items = await requirementService.ListPendingApprovalsAsync(ct);
        return Ok(ApiResponse<IReadOnlyList<PMS.API.Modules.Projects.DTOs.ProjectAdditionalRequirementDto>>.Ok(items));
    }

    /// <summary>
    /// Gets pending resource allocation approvals for the current reporting manager.
    /// </summary>
    [HttpGet("allocation-approvals")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<PMS.API.Modules.Projects.DTOs.ProjectResourceAllocationRequestDto>>>> GetPendingAllocationApprovals(
        [FromServices] PMS.API.Modules.Projects.Services.IProjectTeamMemberService teamMemberService,
        CancellationToken ct = default)
    {
        var items = await teamMemberService.ListPendingAllocationsAsync(ct);
        return Ok(ApiResponse<IReadOnlyList<PMS.API.Modules.Projects.DTOs.ProjectResourceAllocationRequestDto>>.Ok(items));
    }

    /// <summary>
    /// Takes action (Approve, Reject, Hold, Request Changes, Cancelled) on a resource allocation approval request.
    /// Supports GUID requestId, ActionNotification ID, or task code (e.g. ALLOC-XXXXXXXX).
    /// </summary>
    [HttpPost("allocation-approvals/{identifier}/action")]
    public async Task<ActionResult<ApiResponse<PMS.API.Modules.Projects.DTOs.ProjectResourceAllocationRequestDto>>> TakeAllocationApprovalAction(
        string identifier,
        [FromQuery] Guid? projectId,
        [FromBody] PMS.API.Modules.Projects.DTOs.ResourceAllocationActionRequest request,
        [FromServices] PMS.API.Modules.Projects.Services.IProjectTeamMemberService teamMemberService,
        CancellationToken ct = default)
    {
        var result = await teamMemberService.TakeAllocationActionAsync(projectId, identifier, request, ct);
        return Ok(ApiResponse<PMS.API.Modules.Projects.DTOs.ProjectResourceAllocationRequestDto>.Ok(result));
    }
    /// <summary>
    /// Gets pending feedback request approvals for the current reporting manager.
    /// </summary>
    [HttpGet("feedback-approvals")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<PMS.API.Modules.Projects.DTOs.ProjectFeedbackDto>>>> GetPendingFeedbackApprovals(
        [FromServices] PMS.API.Modules.Projects.Services.IProjectFeedbackService feedbackService,
        CancellationToken ct = default)
    {
        var items = await feedbackService.ListPendingApprovalsAsync(ct);
        return Ok(ApiResponse<IReadOnlyList<PMS.API.Modules.Projects.DTOs.ProjectFeedbackDto>>.Ok(items));
    }

    /// <summary>
    /// Takes action (Approve, Reject, Hold, Request Changes) on a feedback approval request.
    /// </summary>
    [HttpPost("feedback-approvals/{id:guid}/action")]
    public async Task<ActionResult<ApiResponse<PMS.API.Modules.Projects.DTOs.ProjectFeedbackDto>>> TakeFeedbackApprovalAction(
        Guid id,
        [FromBody] PMS.API.Modules.Projects.DTOs.FeedbackApprovalActionRequest request,
        [FromServices] PMS.API.Modules.Projects.Services.IProjectFeedbackService feedbackService,
        CancellationToken ct = default)
    {
        var result = await feedbackService.TakeApprovalActionAsync(id, request, ct);
        return Ok(ApiResponse<PMS.API.Modules.Projects.DTOs.ProjectFeedbackDto>.Ok(result));
    }
}
