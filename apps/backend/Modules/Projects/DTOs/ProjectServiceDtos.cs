namespace PMS.API.Modules.Projects.DTOs;

public sealed record ProjectServiceResourceLevelDto(
    Guid Id,
    string Level,
    int Count);

public sealed record ResourceLevelInput(
    string Level,
    int Count);

public sealed record ProjectServiceDto(
    Guid Id,
    Guid ProjectId,
    Guid? ServiceCatalogId,
    string? TaskId,
    string Department,
    string? SubDepartment,
    string ServiceName,
    int Qty,
    string? Description,
    string? ResourceLevel,
    string? Frequency,
    string? Location,
    string? LocationText,
    string? ServiceModel,
    string? DeliveryModel,
    string? FinalDeliveryFormat,
    string? BillingModel,
    string? Tools,
    DateOnly? StartDate,
    DateOnly? EndDate,
    int? DurationDays,
    int? DurationHours,
    int? TotalDays,
    int? TotalHours,
    decimal? UnitPrice,
    decimal? Total,
    int SortOrder,
    IReadOnlyList<ProjectServiceResourceLevelDto> ResourceLevels,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

public sealed record CreateProjectServiceRequest(
    Guid? ServiceCatalogId = null,
    string? TaskId = null,
    string? Department = null,
    string? SubDepartment = null,
    string? ServiceName = null,
    int Qty = 1,
    string? Description = null,
    string? ResourceLevel = null,
    string? Frequency = null,
    string? Location = null,
    string? LocationText = null,
    string? ServiceModel = null,
    string? DeliveryModel = null,
    string? FinalDeliveryFormat = null,
    string? BillingModel = null,
    string? Tools = null,
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    int? DurationDays = null,
    decimal? UnitPrice = null,
    int SortOrder = 0,
    List<ResourceLevelInput>? ResourceLevels = null);

public sealed record UpdateProjectServiceRequest(
    string? Department = null,
    string? SubDepartment = null,
    string? ServiceName = null,
    int? Qty = null,
    string? Description = null,
    string? ResourceLevel = null,
    string? Frequency = null,
    string? Location = null,
    string? LocationText = null,
    string? ServiceModel = null,
    string? DeliveryModel = null,
    string? FinalDeliveryFormat = null,
    string? BillingModel = null,
    string? Tools = null,
    DateOnly? StartDate = null,
    DateOnly? EndDate = null,
    int? DurationDays = null,
    decimal? UnitPrice = null,
    int? SortOrder = null,
    List<ResourceLevelInput>? ResourceLevels = null);

public sealed record SetResourceLevelsRequest(
    List<ResourceLevelInput> Levels);
