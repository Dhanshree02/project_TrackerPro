namespace PMS.API.Modules.Projects.DTOs;

public sealed record SaveWbsDraftRequest(
    string? SectionAComments = null,
    string? SectionBComments = null,
    string? WbsSubStatus = "Draft",
    IReadOnlyList<CreateProjectServiceRequest>? Services = null,
    IReadOnlyList<CreateProjectTaskRequest>? Tasks = null);

public sealed record PublishWbsRequest(
    string? PublishComments = null);

public sealed record WbsPublishResultDto(
    Guid ProjectId,
    string WbsId,
    string WbsStatus,
    string WbsSubStatus,
    int ServiceCount,
    int TaskCount,
    decimal TotalBudget,
    decimal TotalHours,
    DateTime PublishedAtUtc);
