using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Services;

/// <summary>
/// Shared master-catalog lookups.
/// </summary>
public interface ICatalogService
{
    Task<IReadOnlyList<SidebarModuleDto>> GetModulesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetCountriesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetNationalitiesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CityCatalogOptionDto>> GetCitiesAsync(Guid? countryId, CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetIndustriesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetContactDesignationsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetContactTypesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<AddressCityDto>> GetAddressCitiesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<ServiceGroupDto>> GetServiceGroupsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<ServiceDepartmentDto>> GetServiceDepartmentsAsync(Guid? groupId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceSubDepartmentDto>> GetServiceSubDepartmentsAsync(Guid? departmentId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceCatalogOptionDto>> GetServiceCatalogAsync(Guid? subDepartmentId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceHierarchyGroupDto>> GetServiceHierarchyAsync(CancellationToken ct = default);

    Task<CatalogOptionDto> CreateIndustryAsync(UpsertCatalogItemRequest request, CancellationToken ct = default);

    Task<CatalogOptionDto> UpdateIndustryAsync(Guid id, UpsertCatalogItemRequest request, CancellationToken ct = default);

    Task DeleteIndustryAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateCountryAsync(UpsertCatalogItemRequest request, CancellationToken ct = default);

    Task<CatalogOptionDto> UpdateCountryAsync(Guid id, UpsertCatalogItemRequest request, CancellationToken ct = default);

    Task DeleteCountryAsync(Guid id, CancellationToken ct = default);

    Task<CityCatalogOptionDto> CreateCityAsync(UpsertCityRequest request, CancellationToken ct = default);

    Task<CityCatalogOptionDto> UpdateCityAsync(Guid id, UpsertCityRequest request, CancellationToken ct = default);

    Task DeleteCityAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateContactDesignationAsync(UpsertCatalogItemRequest request, CancellationToken ct = default);

    Task<CatalogOptionDto> UpdateContactDesignationAsync(Guid id, UpsertCatalogItemRequest request, CancellationToken ct = default);

    Task DeleteContactDesignationAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateContactTypeAsync(UpsertCatalogItemRequest request, CancellationToken ct = default);

    Task<CatalogOptionDto> UpdateContactTypeAsync(Guid id, UpsertCatalogItemRequest request, CancellationToken ct = default);

    Task DeleteContactTypeAsync(Guid id, CancellationToken ct = default);

    Task<IReadOnlyList<ScreenOptionDto>> GetScreenOptionsAsync(string? category, CancellationToken ct = default);

    Task<ScreenOptionDto> CreateScreenOptionAsync(UpsertScreenOptionRequest request, CancellationToken ct = default);

    Task<ScreenOptionDto> UpdateScreenOptionAsync(Guid id, UpsertScreenOptionRequest request, CancellationToken ct = default);

    Task DeleteScreenOptionAsync(Guid id, CancellationToken ct = default);
}
