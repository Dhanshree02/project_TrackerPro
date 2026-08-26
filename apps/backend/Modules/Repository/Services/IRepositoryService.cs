using PMS.API.Modules.Repository.DTOs;
using PMS.API.Modules.Repository.Models;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Repository.Services;

public interface IRepositoryService
{
    Task<PagedResult<RepositoryItemDto>> GetDocumentsAsync(
        int page,
        int perPage,
        string? category = null,
        string? search = null,
        CancellationToken ct = default);

    Task<RepositoryItemDto> UploadDocumentAsync(
        string category,
        IFormFile file,
        string? userEmailOrName = null,
        CancellationToken ct = default);

    Task<RepositoryItem?> GetDocumentByIdAsync(
        Guid id,
        CancellationToken ct = default);

    Task RecordViewAsync(
        Guid documentId,
        string? userEmailOrName = null,
        string action = "Downloaded",
        CancellationToken ct = default);

    Task<bool> DeleteDocumentAsync(
        Guid id,
        string? userEmailOrName = null,
        CancellationToken ct = default);

    Task<IReadOnlyList<RepositoryActivityLogDto>> GetActivityLogsAsync(
        int limit = 100,
        CancellationToken ct = default);

    Task<IReadOnlyList<RepositoryActivityLogDto>> GetDocumentLogsAsync(
        Guid documentId,
        CancellationToken ct = default);

    Task<IReadOnlyList<DocumentAccessSummaryDto>> GetDocumentAccessSummariesAsync(
        string? category = null,
        string? search = null,
        CancellationToken ct = default);

    Task<IReadOnlyList<RepositoryCategoryCountDto>> GetCategoryCountsAsync(
        CancellationToken ct = default);
}
