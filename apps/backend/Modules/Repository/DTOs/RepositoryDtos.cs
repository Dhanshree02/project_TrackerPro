namespace PMS.API.Modules.Repository.DTOs;

public sealed record RepositoryItemDto(
    Guid Id,
    string FileName,
    string Category,
    long Size,
    DateTime LastUpdated,
    string UploadedBy,
    DateTime CreatedAtUtc);

public sealed record RepositoryActivityLogDto(
    Guid Id,
    string Action,
    Guid? DocumentId,
    string FileName,
    string Category,
    string PerformedBy,
    string? Details,
    DateTime CreatedAtUtc);

public sealed record RepositoryCategoryCountDto(
    string Id,
    string Name,
    string Description,
    int DocumentCount);

public sealed record DocumentAccessEntryDto(
    Guid LogId,
    string EmployeeName,
    string Action,
    DateTime AccessedAtUtc,
    string? Details);

public sealed record DocumentAccessSummaryDto(
    Guid DocumentId,
    string FileName,
    string Category,
    long Size,
    DateTime LastUpdated,
    string UploadedBy,
    int TotalDownloads,
    int UniqueEmployeeCount,
    IReadOnlyList<DocumentAccessEntryDto> Accessors);
