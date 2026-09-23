using PMS.API.Modules.Projects.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectDraftService
{
    Task<PagedResult<ProjectDraftListDto>> GetDraftsAsync(ProjectDraftQueryParameters queryParams, CancellationToken ct = default);

    Task<ProjectDraftDto?> GetDraftByIdAsync(Guid id, CancellationToken ct = default);

    Task<ProjectDraftDto> CreateDraftAsync(CreateProjectDraftRequest request, CancellationToken ct = default);

    Task<ProjectDraftDto> UpdateDraftAsync(Guid id, UpdateProjectDraftRequest request, CancellationToken ct = default);

    Task<bool> DeleteDraftAsync(Guid id, CancellationToken ct = default);

    Task<bool> MarkDraftConvertedAsync(Guid id, CancellationToken ct = default);
}
