namespace PMS.API.Modules.Projects.DTOs;

public sealed record ProjectIssueDto(
    Guid Id,
    Guid ProjectId,
    string? ProjectCode,
    string ProjectName,
    string IssueType,
    string Priority,
    string Subject,
    string Description,
    string Status,
    Guid? RaisedByEmployeeId,
    string RaisedByName,
    string? RaisedByRole,
    DateTime CreatedAtUtc);

public sealed class CreateProjectIssueRequest
{
    public Guid? ProjectId { get; set; }

    public string Subject { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public string? IssueType { get; set; }

    public string? Priority { get; set; }
}

public sealed record ProjectAlertDto(
    Guid Id,
    Guid ProjectId,
    Guid? IssueId,
    string Title,
    string? Description,
    string AlertType,
    string Priority,
    string Status,
    Guid? RaisedByEmployeeId,
    string RaisedByName,
    DateTime CreatedAtUtc);

public sealed record UpdateAlertStatusRequest(string Status);

public sealed record AssignedProjectSummaryDto(
    Guid Id,
    string Name,
    string? ProjectCode,
    string? CustomerName,
    string? Status);
