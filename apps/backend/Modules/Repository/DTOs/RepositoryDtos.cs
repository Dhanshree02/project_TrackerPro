namespace PMS.API.Modules.Repository.DTOs;

public sealed class UploadRepositoryDocumentRequest
{
    public string Category { get; set; } = string.Empty;
    public IFormFile File { get; set; } = null!;
    public string? UploadedBy { get; set; }

    /// <summary>Departments that may view this document. Bound from repeated form field <c>departmentIds</c>.</summary>
    public List<Guid>? DepartmentIds { get; set; }
}

public sealed record RepositoryDepartmentDto(Guid Id, string Name);

public sealed record RepositoryDepartmentOptionDto(Guid Id, string Code, string Name);

public sealed record RepositoryItemDto(
    Guid Id,
    string FileName,
    string Category,
    long Size,
    DateTime LastUpdated,
    string UploadedBy,
    DateTime CreatedAtUtc,
    IReadOnlyList<RepositoryDepartmentDto> Departments);

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
