namespace PMS.API.Modules.Projects.DTOs;

public sealed record CreateProjectDraftRequest(
    string ProjectName,
    Guid? ClientId,
    string? ClientName,
    string? SalesPerson,
    string SavedByName,
    string FormSnapshotJson
);

public sealed record UpdateProjectDraftRequest(
    string ProjectName,
    Guid? ClientId,
    string? ClientName,
    string? SalesPerson,
    string SavedByName,
    string FormSnapshotJson,
    uint RowVersion
);

public sealed record ProjectDraftDto(
    Guid Id,
    string ProjectName,
    Guid? ClientId,
    string? ClientName,
    string? SalesPerson,
    string CreatedByName,
    string? UpdatedByName,
    string Status,
    uint RowVersion,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc,
    string FormSnapshotJson
);

public sealed record ProjectDraftListDto(
    Guid Id,
    string ProjectName,
    Guid? ClientId,
    string? ClientName,
    string? SalesPerson,
    string CreatedByName,
    string? UpdatedByName,
    string Status,
    uint RowVersion,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc
);

public sealed class ProjectDraftQueryParameters
{
    private const int MaxPerPage = 100;
    private int _perPage = 20;

    public int Page { get; set; } = 1;

    public int PerPage
    {
        get => _perPage;
        set => _perPage = value > MaxPerPage ? MaxPerPage : value < 1 ? 1 : value;
    }

    public string? Search { get; set; }
}
