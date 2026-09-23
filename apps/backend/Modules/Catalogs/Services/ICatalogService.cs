using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Services;

/// <summary>
/// Shared master-catalog lookups.
/// </summary>
public interface ICatalogService
{
    Task<IReadOnlyList<CatalogOptionDto>> GetCountriesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetNationalitiesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CityCatalogOptionDto>> GetCitiesAsync(Guid? countryId, CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetIndustriesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetContactDesignationsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetContactTypesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<ServiceGroupDto>> GetServiceGroupsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<ServiceDepartmentDto>> GetServiceDepartmentsAsync(Guid? groupId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceSubDepartmentDto>> GetServiceSubDepartmentsAsync(Guid? departmentId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceCatalogOptionDto>> GetServiceCatalogAsync(Guid? subDepartmentId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceHierarchyGroupDto>> GetServiceHierarchyAsync(CancellationToken ct = default);
}
