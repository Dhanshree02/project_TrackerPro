using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Services;

public interface IProjectMastersService
{
    Task<IReadOnlyList<ProjectMasterRowDto>> ListAsync(CancellationToken ct = default);

    Task<ProjectMasterRowDto> CreateAsync(CreateProjectMasterRequest request, CancellationToken ct = default);

    Task<ProjectMasterRowDto> UpdateAsync(Guid serviceCatalogId, UpdateProjectMasterRequest request, CancellationToken ct = default);

    Task DeleteAsync(Guid serviceCatalogId, CancellationToken ct = default);

    Task<ServiceGroupDto> CreateGroupAsync(string name, CancellationToken ct = default);

    Task<ServiceDepartmentDto> CreateDepartmentAsync(CreateServiceDepartmentRequest request, CancellationToken ct = default);

    Task<ProjectMasterRowDto> CreateServiceOnlyAsync(CreateServiceOnlyRequest request, CancellationToken ct = default);
}
