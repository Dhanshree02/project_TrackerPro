using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectAppreciationService
{
    Task<IReadOnlyList<ProjectAppreciationDto>> ListAsync(Guid projectId, CancellationToken ct = default);

    Task<ProjectAppreciationDto> CreateAsync(Guid projectId, CreateProjectAppreciationRequest request, CancellationToken ct = default);
}
