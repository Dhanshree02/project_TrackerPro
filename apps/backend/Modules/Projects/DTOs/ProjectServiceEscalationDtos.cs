using Microsoft.AspNetCore.Http;

namespace PMS.API.Modules.Projects.DTOs;

public sealed record ServiceEscalationStakeholderDto(
    Guid EmployeeId,
    string Name,
    string? EmployeeCode,
    string SubDepartment,
    string Status);

public sealed record ProjectServiceEscalationDto(
    Guid Id,
    Guid ProjectId,
    Guid? ProjectServiceId,
    string? ProjectCode,
    string ProjectName,
    string? CustomerName,
    string ServiceName,
    string EscalationType,
    string Priority,
    string Subject,
    string Description,
    DateOnly? ExpectedResolutionDate,
    string? AttachmentFileName,
    string? AttachmentPath,
    string Status,
    string RaisedByName,
    DateTime CreatedAtUtc,
    IReadOnlyList<ServiceEscalationStakeholderDto> Stakeholders);

public sealed class CreateProjectServiceEscalationForm
{
    public Guid? ProjectServiceId { get; set; }

    public string? ServiceName { get; set; }

    public string? ProjectCode { get; set; }

    public string? ProjectName { get; set; }

    public string? CustomerName { get; set; }

    public string? EscalationType { get; set; }

    public string? Priority { get; set; }

    public string? Subject { get; set; }

    public string? Description { get; set; }

    public DateOnly? ExpectedResolutionDate { get; set; }

    public List<Guid>? StakeholderIds { get; set; }

    public IFormFile? File { get; set; }
}
