using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Controllers;

[ApiController]
[Route("api/v1/approvals")]
public class ApprovalsController(IApprovalService approvalService) : ControllerBase
{
    /// <summary>
    /// Retrieves paged approval requests filtered by approval type, status, project, or department.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<ApprovalRequestDto>>>> GetApprovals(
        [FromQuery] ApprovalQueryParameters query,
        CancellationToken ct)
    {
        var result = await approvalService.GetApprovalsAsync(query, ct);
        return Ok(ApiResponse<PagedResult<ApprovalRequestDto>>.Ok(result));
    }

    /// <summary>
    /// Retrieves summary metrics for the Approvals dashboard tab (Total, Pending, Approved, Rejected, Scope, Leadership, Extension counts).
    /// </summary>
    [HttpGet("metrics")]
    public async Task<ActionResult<ApiResponse<ApprovalMetricsDto>>> GetMetrics(CancellationToken ct)
    {
        var metrics = await approvalService.GetMetricsAsync(ct);
        return Ok(ApiResponse<ApprovalMetricsDto>.Ok(metrics));
    }

    /// <summary>
    /// Retrieves detailed information for a specific approval request.
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<ApprovalRequestDto>>> GetById(Guid id, CancellationToken ct)
    {
        var item = await approvalService.GetByIdAsync(id, ct);
        if (item == null)
        {
            return NotFound(ApiResponse<ApprovalRequestDto>.Fail("NOT_FOUND", "Approval request not found."));
        }
        return Ok(ApiResponse<ApprovalRequestDto>.Ok(item));
    }

    /// <summary>
    /// Submits a new approval request (Scope Change, Leadership Change, Project End Date Extension, Profile Changes, etc.).
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ApiResponse<ApprovalRequestDto>>> CreateApproval(
        [FromBody] CreateApprovalRequestDto request,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.ApprovalType) || string.IsNullOrWhiteSpace(request.Title))
        {
            return BadRequest(ApiResponse<ApprovalRequestDto>.Fail("VALIDATION_ERROR", "ApprovalType and Title are required."));
        }

        var created = await approvalService.CreateApprovalAsync(request, ct);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, ApiResponse<ApprovalRequestDto>.Ok(created));
    }

    /// <summary>
    /// Takes an action on an approval request (Approve, Reject, RequestChanges, Hold) with mandatory decision notes.
    /// </summary>
    [HttpPost("{id:guid}/action")]
    public async Task<ActionResult<ApiResponse<ApprovalRequestDto>>> TakeAction(
        Guid id,
        [FromBody] ApprovalActionRequest request,
        CancellationToken ct)
    {
        try
        {
            var updated = await approvalService.TakeActionAsync(id, request, ct);
            return Ok(ApiResponse<ApprovalRequestDto>.Ok(updated));
        }
        catch (KeyNotFoundException)
        {
            return NotFound(ApiResponse<ApprovalRequestDto>.Fail("NOT_FOUND", "Approval request not found."));
        }
        catch (ArgumentException ex)
        {
            return BadRequest(ApiResponse<ApprovalRequestDto>.Fail("VALIDATION_ERROR", ex.Message));
        }
    }
}
