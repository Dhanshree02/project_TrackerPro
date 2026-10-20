namespace PMS.API.Modules.Projects.DTOs;

public sealed record ProjectInterviewDto(
    Guid Id,
    Guid ProjectId,
    Guid EmployeeId,
    string ResourceName,
    DateOnly InterviewDate,
    TimeOnly InterviewTime,
    string Result,
    string? Comments,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed record CreateProjectInterviewRequest(
    Guid EmployeeId,
    DateOnly InterviewDate,
    TimeOnly InterviewTime);

public sealed record UpdateProjectInterviewRequest(
    string? Result = null,
    string? Comments = null,
    DateOnly? InterviewDate = null,
    TimeOnly? InterviewTime = null);
