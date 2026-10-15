using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Projects.Controllers;

[ApiController]
[Route("api/v1/issues")]
public class IssuesController(IIssueService issueService) : ControllerBase
{
    /// <summary>
    /// Raises a new project issue. Routed immediately to the project's Dotted-Line Reporting Manager (PM).
    /// Starts the 2-day auto-escalation timer across the hierarchy (PM → SPM → EM → PMO → HOD → CEO).
    /// <summary>
    /// Returns available active projects for the issue creation dropdown.
    /// Accessible to all authenticated personas (Team Members, TLs, PMs, etc.).
    /// </summary>
    [HttpGet("project-options")]
    public async Task<ActionResult<ApiResponse<List<IssueProjectOption>>>> GetProjectOptions(CancellationToken ct)
    {
        var options = await issueService.GetProjectOptionsAsync(ct);
        return Ok(ApiResponse<List<IssueProjectOption>>.Ok(options));
    }

    /// <summary>
    /// Raises a new project issue. Routed immediately to the project's Dotted-Line Reporting Manager (PM).
    /// Starts the 2-day auto-escalation timer across the hierarchy (PM → SPM → EM → PMO → HOD → CEO).
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ApiResponse<IssueResponse>>> CreateIssue(
        [FromBody] CreateIssueRequest request,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.ProjectId))
        {
            return BadRequest(ApiResponse<IssueResponse>.Fail("VALIDATION_ERROR", "Valid ProjectId is required."));
        }

        if (string.IsNullOrWhiteSpace(request.Title) || string.IsNullOrWhiteSpace(request.Description))
        {
            return BadRequest(ApiResponse<IssueResponse>.Fail("VALIDATION_ERROR", "Issue Title and Description are required."));
        }

        var result = await issueService.CreateIssueAsync(request, ct);
        return Ok(ApiResponse<IssueResponse>.Ok(result));
    }

    /// <summary>
    /// Retrieves issues with optional filters for project, status, escalation level, or assignee role.
    /// Automatically applies 2-day escalation SLA checks on retrieval.
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<IssueResponse>>>> GetIssues(
        [FromQuery] Guid? projectId,
        [FromQuery] string? status,
        [FromQuery] int? escalationLevel,
        [FromQuery] string? assigneeRole,
        CancellationToken ct)
    {
        var result = await issueService.GetIssuesAsync(projectId, status, escalationLevel, assigneeRole, ct);
        return Ok(ApiResponse<List<IssueResponse>>.Ok(result));
    }

    /// <summary>
    /// Retrieves issues scoped to a specific project.
    /// </summary>
    [HttpGet("/api/v1/projects/{projectId:guid}/issues")]
    public async Task<ActionResult<ApiResponse<List<IssueResponse>>>> GetIssuesByProject(
        Guid projectId,
        [FromQuery] string? status,
        [FromQuery] int? escalationLevel,
        [FromQuery] string? assigneeRole,
        CancellationToken ct)
    {
        var result = await issueService.GetIssuesAsync(projectId, status, escalationLevel, assigneeRole, ct);
        return Ok(ApiResponse<List<IssueResponse>>.Ok(result));
    }

    /// <summary>
    /// Retrieves a specific issue by its ID.
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<IssueResponse>>> GetIssueById(
        Guid id,
        CancellationToken ct)
    {
        var result = await issueService.GetIssueByIdAsync(id, ct);
        if (result == null)
        {
            return NotFound(ApiResponse<IssueResponse>.Fail("NOT_FOUND", "Issue not found."));
        }

        return Ok(ApiResponse<IssueResponse>.Ok(result));
    }

    /// <summary>
    /// Updates an issue's status (e.g. Open → In Progress → Resolved → Closed).
    /// </summary>
    [HttpPatch("{id:guid}/status")]
    public async Task<ActionResult<ApiResponse<IssueResponse>>> UpdateStatus(
        Guid id,
        [FromBody] UpdateIssueStatusRequest request,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Status))
        {
            return BadRequest(ApiResponse<IssueResponse>.Fail("VALIDATION_ERROR", "Status is required."));
        }

        var result = await issueService.UpdateIssueStatusAsync(id, request, ct);
        return Ok(ApiResponse<IssueResponse>.Ok(result));
    }

    /// <summary>
    /// Manually escalates an issue to the next level in the hierarchy before the 2-day SLA window.
    /// </summary>
    [HttpPost("{id:guid}/escalate")]
    public async Task<ActionResult<ApiResponse<IssueResponse>>> EscalateManually(
        Guid id,
        [FromQuery] string actorName,
        [FromQuery] string? notes,
        CancellationToken ct)
    {
        var result = await issueService.EscalateIssueManuallyAsync(id, actorName ?? "Manager", notes, ct);
        return Ok(ApiResponse<IssueResponse>.Ok(result));
    }
}
