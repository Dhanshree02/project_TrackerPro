using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Services;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.Projects.Controllers;

[ApiController]
[Route("api/v1/projects")]
public class ProjectsController(IProjectAppService projectService, IProjectTeamMemberService teamMemberService) : ControllerBase
{
    [HttpGet]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<PagedResult<ProjectDto>>>> GetProjects(
        [FromQuery] ProjectQueryParameters queryParams,
        CancellationToken ct)
    {
        var result = await projectService.GetProjectsAsync(queryParams, ct);
        return Ok(ApiResponse<PagedResult<ProjectDto>>.Ok(result));
    }

    [HttpGet("{id:guid}")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<ProjectDto>>> GetProjectById(
        Guid id,
        CancellationToken ct)
    {
        var project = await projectService.GetProjectByIdAsync(id, ct);
        if (project == null)
        {
            return NotFound(ApiResponse<ProjectDto>.Fail("NOT_FOUND", "Project not found"));
        }
        return Ok(ApiResponse<ProjectDto>.Ok(project));
    }

    [HttpGet("next-code")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<NextProjectCodeDto>>> GetNextProjectCode(
        [FromQuery] Guid clientId,
        CancellationToken ct)
    {
        var result = await projectService.GetNextProjectCodeAsync(clientId, ct);
        return Ok(ApiResponse<NextProjectCodeDto>.Ok(result));
    }

    [HttpPost]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectDto>>> CreateProject(
        [FromBody] CreateProjectRequest request,
        CancellationToken ct)
    {
        var project = await projectService.CreateProjectAsync(request, ct);
        return CreatedAtAction(nameof(GetProjectById), new { id = project.Id }, ApiResponse<ProjectDto>.Ok(project));
    }

    [HttpPut("{id:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectDto>>> UpdateProject(
        Guid id,
        [FromBody] UpdateProjectRequest request,
        CancellationToken ct)
    {
        var project = await projectService.UpdateProjectAsync(id, request, ct);
        return Ok(ApiResponse<ProjectDto>.Ok(project));
    }

    [HttpDelete("{id:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteProject(
        Guid id,
        CancellationToken ct)
    {
        var success = await projectService.DeleteProjectAsync(id, ct);
        if (!success)
        {
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Project not found"));
        }
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpPatch("{id:guid}/status")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectDto>>> UpdateStatus(
        Guid id,
        [FromBody] UpdateProjectStatusRequest request,
        CancellationToken ct)
    {
        var project = await projectService.UpdateStatusAsync(id, request.Status, ct);
        return Ok(ApiResponse<ProjectDto>.Ok(project));
    }

    [HttpPatch("{id:guid}/wbs-status")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectDto>>> UpdateWbsStatus(
        Guid id,
        [FromBody] UpdateWbsStatusRequest request,
        CancellationToken ct)
    {
        var project = await projectService.UpdateWbsStatusAsync(id, request.WbsStatus, request.WbsSubStatus, ct);
        return Ok(ApiResponse<ProjectDto>.Ok(project));
    }

    // ── Project Services Endpoints ──

    [HttpGet("{projectId:guid}/services")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectServiceDto>>>> GetProjectServices(
        Guid projectId,
        CancellationToken ct)
    {
        var services = await projectService.GetProjectServicesAsync(projectId, ct);
        return Ok(ApiResponse<IReadOnlyList<ProjectServiceDto>>.Ok(services));
    }

    [HttpGet("{projectId:guid}/services/{serviceId:guid}")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<ProjectServiceDto>>> GetProjectServiceById(
        Guid projectId,
        Guid serviceId,
        CancellationToken ct)
    {
        var service = await projectService.GetProjectServiceByIdAsync(projectId, serviceId, ct);
        if (service == null)
        {
            return NotFound(ApiResponse<ProjectServiceDto>.Fail("NOT_FOUND", "Project service not found"));
        }
        return Ok(ApiResponse<ProjectServiceDto>.Ok(service));
    }

    [HttpPost("{projectId:guid}/services")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectServiceDto>>> AddProjectService(
        Guid projectId,
        [FromBody] CreateProjectServiceRequest request,
        CancellationToken ct)
    {
        var service = await projectService.AddProjectServiceAsync(projectId, request, ct);
        return CreatedAtAction(nameof(GetProjectServiceById), new { projectId, serviceId = service.Id }, ApiResponse<ProjectServiceDto>.Ok(service));
    }

    [HttpPut("{projectId:guid}/services/{serviceId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectServiceDto>>> UpdateProjectService(
        Guid projectId,
        Guid serviceId,
        [FromBody] UpdateProjectServiceRequest request,
        CancellationToken ct)
    {
        var service = await projectService.UpdateProjectServiceAsync(projectId, serviceId, request, ct);
        return Ok(ApiResponse<ProjectServiceDto>.Ok(service));
    }

    [HttpDelete("{projectId:guid}/services/{serviceId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteProjectService(
        Guid projectId,
        Guid serviceId,
        CancellationToken ct)
    {
        var success = await projectService.DeleteProjectServiceAsync(projectId, serviceId, ct);
        if (!success)
        {
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Project service not found"));
        }
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpPut("{projectId:guid}/services/{serviceId:guid}/resource-levels")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectServiceDto>>> SetResourceLevels(
        Guid projectId,
        Guid serviceId,
        [FromBody] SetResourceLevelsRequest request,
        CancellationToken ct)
    {
        var service = await projectService.SetResourceLevelsAsync(projectId, serviceId, request, ct);
        return Ok(ApiResponse<ProjectServiceDto>.Ok(service));
    }

    // ── Project Tasks Endpoints ──

    [HttpGet("{projectId:guid}/tasks")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectTaskDto>>>> GetProjectTasks(
        Guid projectId,
        CancellationToken ct)
    {
        var tasks = await projectService.GetProjectTasksAsync(projectId, ct);
        return Ok(ApiResponse<IReadOnlyList<ProjectTaskDto>>.Ok(tasks));
    }

    [HttpGet("{projectId:guid}/tasks/{taskId:guid}")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<ProjectTaskDto>>> GetProjectTaskById(
        Guid projectId,
        Guid taskId,
        CancellationToken ct)
    {
        var task = await projectService.GetProjectTaskByIdAsync(projectId, taskId, ct);
        if (task == null)
        {
            return NotFound(ApiResponse<ProjectTaskDto>.Fail("NOT_FOUND", "Project task not found"));
        }
        return Ok(ApiResponse<ProjectTaskDto>.Ok(task));
    }

    [HttpPost("{projectId:guid}/tasks")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectTaskDto>>> CreateProjectTask(
        Guid projectId,
        [FromBody] CreateProjectTaskRequest request,
        CancellationToken ct)
    {
        var task = await projectService.CreateProjectTaskAsync(projectId, request, ct);
        return CreatedAtAction(nameof(GetProjectTaskById), new { projectId, taskId = task.Id }, ApiResponse<ProjectTaskDto>.Ok(task));
    }

    [HttpPut("{projectId:guid}/tasks/{taskId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectTaskDto>>> UpdateProjectTask(
        Guid projectId,
        Guid taskId,
        [FromBody] UpdateProjectTaskRequest request,
        CancellationToken ct)
    {
        var task = await projectService.UpdateProjectTaskAsync(projectId, taskId, request, ct);
        return Ok(ApiResponse<ProjectTaskDto>.Ok(task));
    }

    [HttpDelete("{projectId:guid}/tasks/{taskId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteProjectTask(
        Guid projectId,
        Guid taskId,
        CancellationToken ct)
    {
        var success = await projectService.DeleteProjectTaskAsync(projectId, taskId, ct);
        if (!success)
        {
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Project task not found"));
        }
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpPatch("{projectId:guid}/tasks/{taskId:guid}/stage")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectTaskDto>>> UpdateTaskStage(
        Guid projectId,
        Guid taskId,
        [FromBody] UpdateTaskStageRequest request,
        CancellationToken ct)
    {
        var task = await projectService.UpdateTaskStageAsync(projectId, taskId, request.Stage, ct);
        return Ok(ApiResponse<ProjectTaskDto>.Ok(task));
    }

    [HttpPost("{projectId:guid}/tasks/auto-generate")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<AutoGeneratedTasksSummaryDto>>> AutoGenerateTasks(
        Guid projectId,
        CancellationToken ct)
    {
        var result = await projectService.AutoGenerateTasksFromServicesAsync(projectId, ct);
        return Ok(ApiResponse<AutoGeneratedTasksSummaryDto>.Ok(result));
    }

    // ── Task Assignments & Timer Endpoints ──

    [HttpGet("{projectId:guid}/tasks/{taskId:guid}/assignments")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectTaskAssignmentDto>>>> GetTaskAssignments(
        Guid projectId,
        Guid taskId,
        CancellationToken ct)
    {
        var assignments = await projectService.GetTaskAssignmentsAsync(projectId, taskId, ct);
        return Ok(ApiResponse<IReadOnlyList<ProjectTaskAssignmentDto>>.Ok(assignments));
    }

    [HttpPost("{projectId:guid}/tasks/{taskId:guid}/assignments")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectTaskAssignmentDto>>> AssignTaskResource(
        Guid projectId,
        Guid taskId,
        [FromBody] AssignTaskResourceRequest request,
        CancellationToken ct)
    {
        var assignment = await projectService.AssignTaskResourceAsync(projectId, taskId, request, ct);
        return Ok(ApiResponse<ProjectTaskAssignmentDto>.Ok(assignment));
    }

    [HttpPut("{projectId:guid}/tasks/{taskId:guid}/assignments/{assignmentId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectTaskAssignmentDto>>> UpdateTaskAssignment(
        Guid projectId,
        Guid taskId,
        Guid assignmentId,
        [FromBody] UpdateTaskAssignmentRequest request,
        CancellationToken ct)
    {
        var assignment = await projectService.UpdateTaskAssignmentAsync(projectId, taskId, assignmentId, request, ct);
        return Ok(ApiResponse<ProjectTaskAssignmentDto>.Ok(assignment));
    }

    [HttpDelete("{projectId:guid}/tasks/{taskId:guid}/assignments/{assignmentId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<bool>>> RemoveTaskAssignment(
        Guid projectId,
        Guid taskId,
        Guid assignmentId,
        CancellationToken ct)
    {
        var success = await projectService.RemoveTaskAssignmentAsync(projectId, taskId, assignmentId, ct);
        if (!success)
        {
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Task assignment not found"));
        }
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpPost("{projectId:guid}/tasks/{taskId:guid}/assignments/{assignmentId:guid}/start-timer")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<TimerStatusDto>>> StartTaskTimer(
        Guid projectId,
        Guid taskId,
        Guid assignmentId,
        CancellationToken ct)
    {
        var status = await projectService.StartTaskTimerAsync(projectId, taskId, assignmentId, ct);
        return Ok(ApiResponse<TimerStatusDto>.Ok(status));
    }

    [HttpPost("{projectId:guid}/tasks/{taskId:guid}/assignments/{assignmentId:guid}/stop-timer")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<TimerStatusDto>>> StopTaskTimer(
        Guid projectId,
        Guid taskId,
        Guid assignmentId,
        CancellationToken ct)
    {
        var status = await projectService.StopTaskTimerAsync(projectId, taskId, assignmentId, ct);
        return Ok(ApiResponse<TimerStatusDto>.Ok(status));
    }

    // ── Project Invoices Endpoints ──

    [HttpGet("{projectId:guid}/invoices")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectInvoiceDto>>>> GetProjectInvoices(
        Guid projectId,
        CancellationToken ct)
    {
        var invoices = await projectService.GetProjectInvoicesAsync(projectId, ct);
        return Ok(ApiResponse<IReadOnlyList<ProjectInvoiceDto>>.Ok(invoices));
    }

    [HttpGet("{projectId:guid}/invoices/{invoiceId:guid}")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<ProjectInvoiceDto>>> GetProjectInvoiceById(
        Guid projectId,
        Guid invoiceId,
        CancellationToken ct)
    {
        var invoice = await projectService.GetProjectInvoiceByIdAsync(projectId, invoiceId, ct);
        if (invoice == null)
        {
            return NotFound(ApiResponse<ProjectInvoiceDto>.Fail("NOT_FOUND", "Project invoice not found"));
        }
        return Ok(ApiResponse<ProjectInvoiceDto>.Ok(invoice));
    }

    [HttpPost("{projectId:guid}/invoices")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectInvoiceDto>>> CreateProjectInvoice(
        Guid projectId,
        [FromBody] CreateProjectInvoiceRequest request,
        CancellationToken ct)
    {
        var invoice = await projectService.CreateProjectInvoiceAsync(projectId, request, ct);
        return CreatedAtAction(nameof(GetProjectInvoiceById), new { projectId, invoiceId = invoice.Id }, ApiResponse<ProjectInvoiceDto>.Ok(invoice));
    }

    [HttpPut("{projectId:guid}/invoices/{invoiceId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectInvoiceDto>>> UpdateProjectInvoice(
        Guid projectId,
        Guid invoiceId,
        [FromBody] UpdateProjectInvoiceRequest request,
        CancellationToken ct)
    {
        var invoice = await projectService.UpdateProjectInvoiceAsync(projectId, invoiceId, request, ct);
        return Ok(ApiResponse<ProjectInvoiceDto>.Ok(invoice));
    }

    [HttpDelete("{projectId:guid}/invoices/{invoiceId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteProjectInvoice(
        Guid projectId,
        Guid invoiceId,
        CancellationToken ct)
    {
        var success = await projectService.DeleteProjectInvoiceAsync(projectId, invoiceId, ct);
        if (!success)
        {
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Project invoice not found"));
        }
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpPost("{projectId:guid}/invoices/auto-generate")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<AutoGenerateInvoicesSummaryDto>>> AutoGenerateInvoices(
        Guid projectId,
        CancellationToken ct)
    {
        var result = await projectService.AutoGenerateInvoicesAsync(projectId, ct);
        return Ok(ApiResponse<AutoGenerateInvoicesSummaryDto>.Ok(result));
    }

    // ── Project Documents Endpoints ──

    [HttpGet("{projectId:guid}/documents")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectDocumentDto>>>> GetProjectDocuments(
        Guid projectId,
        CancellationToken ct)
    {
        var docs = await projectService.GetProjectDocumentsAsync(projectId, ct);
        return Ok(ApiResponse<IReadOnlyList<ProjectDocumentDto>>.Ok(docs));
    }

    [HttpGet("{projectId:guid}/documents/{documentId:guid}")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<ProjectDocumentDto>>> GetProjectDocumentById(
        Guid projectId,
        Guid documentId,
        CancellationToken ct)
    {
        var doc = await projectService.GetProjectDocumentByIdAsync(projectId, documentId, ct);
        if (doc == null)
        {
            return NotFound(ApiResponse<ProjectDocumentDto>.Fail("NOT_FOUND", "Project document not found"));
        }
        return Ok(ApiResponse<ProjectDocumentDto>.Ok(doc));
    }

    [HttpPost("{projectId:guid}/documents")]
    [RequirePermission(Permissions.ProjectsWrite)]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<ApiResponse<ProjectDocumentDto>>> UploadProjectDocument(
        Guid projectId,
        [FromForm] IFormFile file,
        [FromForm] string? documentType,
        [FromForm] string? description,
        CancellationToken ct)
    {
        var doc = await projectService.UploadProjectDocumentAsync(projectId, documentType, description, file, ct);
        return CreatedAtAction(nameof(GetProjectDocumentById), new { projectId, documentId = doc.Id }, ApiResponse<ProjectDocumentDto>.Ok(doc));
    }

    [HttpGet("{projectId:guid}/documents/{documentId:guid}/download")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<IActionResult> DownloadProjectDocument(
        Guid projectId,
        Guid documentId,
        CancellationToken ct)
    {
        var (stream, contentType, downloadFileName) = await projectService.DownloadProjectDocumentAsync(projectId, documentId, ct);
        return File(stream, contentType, downloadFileName);
    }

    [HttpDelete("{projectId:guid}/documents/{documentId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteProjectDocument(
        Guid projectId,
        Guid documentId,
        CancellationToken ct)
    {
        var success = await projectService.DeleteProjectDocumentAsync(projectId, documentId, ct);
        if (!success)
        {
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Project document not found"));
        }
        return Ok(ApiResponse<bool>.Ok(true));
    }

    // ── Project Renewal Endpoint ──

    [HttpPost("{id:guid}/renew")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectDto>>> RenewProject(
        Guid id,
        [FromBody] RenewProjectRequest request,
        CancellationToken ct)
    {
        var renewed = await projectService.RenewProjectAsync(id, request, ct);
        return CreatedAtAction(nameof(GetProjectById), new { id = renewed.Id }, ApiResponse<ProjectDto>.Ok(renewed));
    }

    // ── WBS Draft & Publish Endpoints ──

    [HttpPost("{id:guid}/wbs/draft")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectDto>>> SaveWbsDraft(
        Guid id,
        [FromBody] SaveWbsDraftRequest request,
        CancellationToken ct)
    {
        var project = await projectService.SaveWbsDraftAsync(id, request, ct);
        return Ok(ApiResponse<ProjectDto>.Ok(project));
    }

    [HttpPost("{id:guid}/wbs/publish")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<WbsPublishResultDto>>> PublishWbs(
        Guid id,
        [FromBody] PublishWbsRequest? request,
        CancellationToken ct)
    {
        var result = await projectService.PublishWbsAsync(id, request, ct);
        return Ok(ApiResponse<WbsPublishResultDto>.Ok(result));
    }

    // ── Project Team Members ──

    [HttpGet("{projectId:guid}/team-members")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectTeamMemberDto>>>> GetTeamMembers(
        Guid projectId,
        [FromQuery] bool shadow = false,
        CancellationToken ct = default)
    {
        var items = await teamMemberService.ListAsync(projectId, shadow, ct);
        return Ok(ApiResponse<IReadOnlyList<ProjectTeamMemberDto>>.Ok(items));
    }

    [HttpGet("{projectId:guid}/team-members/candidates")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectTeamCandidateDto>>>> SearchTeamCandidates(
        Guid projectId,
        [FromQuery] string? search,
        [FromQuery] int limit = 50,
        [FromQuery] bool internsOnly = false,
        CancellationToken ct = default)
    {
        var items = await teamMemberService.SearchCandidatesAsync(projectId, search, limit, internsOnly, ct);
        return Ok(ApiResponse<IReadOnlyList<ProjectTeamCandidateDto>>.Ok(items));
    }

    [HttpGet("{projectId:guid}/team-members/{memberId:guid}")]
    [RequirePermission(Permissions.ProjectsRead)]
    public async Task<ActionResult<ApiResponse<ProjectTeamMemberDto>>> GetTeamMember(
        Guid projectId,
        Guid memberId,
        CancellationToken ct)
    {
        var item = await teamMemberService.GetByIdAsync(projectId, memberId, ct);
        if (item is null)
        {
            return NotFound(ApiResponse<ProjectTeamMemberDto>.Fail("NOT_FOUND", "Project team member not found"));
        }
        return Ok(ApiResponse<ProjectTeamMemberDto>.Ok(item));
    }

    [HttpPost("{projectId:guid}/team-members")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectTeamMemberDto>>> AddTeamMember(
        Guid projectId,
        [FromBody] CreateProjectTeamMemberRequest request,
        CancellationToken ct)
    {
        var created = await teamMemberService.AddAsync(projectId, request, ct);
        return CreatedAtAction(
            nameof(GetTeamMember),
            new { projectId, memberId = created.Id },
            ApiResponse<ProjectTeamMemberDto>.Ok(created));
    }

    [HttpPut("{projectId:guid}/team-members/{memberId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ProjectTeamMemberDto>>> UpdateTeamMember(
        Guid projectId,
        Guid memberId,
        [FromBody] UpdateProjectTeamMemberRequest request,
        CancellationToken ct)
    {
        var updated = await teamMemberService.UpdateAsync(projectId, memberId, request, ct);
        return Ok(ApiResponse<ProjectTeamMemberDto>.Ok(updated));
    }

    [HttpDelete("{projectId:guid}/team-members/{memberId:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<bool>>> RemoveTeamMember(
        Guid projectId,
        Guid memberId,
        CancellationToken ct)
    {
        var success = await teamMemberService.RemoveAsync(projectId, memberId, ct);
        if (!success)
        {
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Project team member not found"));
        }
        return Ok(ApiResponse<bool>.Ok(true));
    }
}






