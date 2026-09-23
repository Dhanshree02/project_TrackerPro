using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Services;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.Projects.Controllers;

[ApiController]
[Route("api/v1/project-drafts")]
public class ProjectDraftsController(IProjectDraftService draftService) : ControllerBase
{
    [HttpGet]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<PagedResult<ProjectDraftListDto>>>> GetDrafts(
        [FromQuery] ProjectDraftQueryParameters queryParams,
        CancellationToken ct)
    {
        var result = await draftService.GetDraftsAsync(queryParams, ct);
        return Ok(ApiResponse<PagedResult<ProjectDraftListDto>>.Ok(result));
    }

    [HttpGet("{id:guid}")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<ProjectDraftDto>>> GetDraftById(
        Guid id,
        CancellationToken ct)
    {
        var draft = await draftService.GetDraftByIdAsync(id, ct);
        if (draft is null)
        {
            return NotFound(ApiResponse<ProjectDraftDto>.Fail("NotFound", $"Project draft with ID '{id}' was not found."));
        }

        return Ok(ApiResponse<ProjectDraftDto>.Ok(draft));
    }

    [HttpPost]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectDraftDto>>> CreateDraft(
        [FromBody] CreateProjectDraftRequest request,
        CancellationToken ct)
    {
        var draft = await draftService.CreateDraftAsync(request, ct);
        return CreatedAtAction(nameof(GetDraftById), new { id = draft.Id }, ApiResponse<ProjectDraftDto>.Ok(draft));
    }

    [HttpPut("{id:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectDraftDto>>> UpdateDraft(
        Guid id,
        [FromBody] UpdateProjectDraftRequest request,
        CancellationToken ct)
    {
        var draft = await draftService.UpdateDraftAsync(id, request, ct);
        return Ok(ApiResponse<ProjectDraftDto>.Ok(draft));
    }

    [HttpDelete("{id:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<object>>> DeleteDraft(
        Guid id,
        CancellationToken ct)
    {
        await draftService.DeleteDraftAsync(id, ct);
        return Ok(ApiResponse<object>.Ok(new { success = true }));
    }

    [HttpPatch("{id:guid}/convert")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<object>>> MarkDraftConverted(
        Guid id,
        CancellationToken ct)
    {
        var success = await draftService.MarkDraftConvertedAsync(id, ct);
        return Ok(ApiResponse<object>.Ok(new { success }));
    }
}
