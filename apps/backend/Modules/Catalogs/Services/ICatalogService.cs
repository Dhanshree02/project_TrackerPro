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

    Task<CatalogOptionDto> CreateIndustryAsync(string name, string? code, CancellationToken ct = default);

    Task<CatalogOptionDto> UpdateIndustryAsync(Guid id, string name, string? code, CancellationToken ct = default);

    Task DeleteIndustryAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateContactDesignationAsync(string name, string? code, CancellationToken ct = default);

    Task<CatalogOptionDto> UpdateContactDesignationAsync(Guid id, string name, string? code, CancellationToken ct = default);

    Task DeleteContactDesignationAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateContactTypeAsync(string name, string? code, CancellationToken ct = default);

    Task<CatalogOptionDto> UpdateContactTypeAsync(Guid id, string name, string? code, CancellationToken ct = default);

    Task DeleteContactTypeAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateCountryAsync(string name, string? code, CancellationToken ct = default);

    Task<CatalogOptionDto> UpdateCountryAsync(Guid id, string name, string? code, CancellationToken ct = default);

    Task DeleteCountryAsync(Guid id, CancellationToken ct = default);

    Task<CityCatalogOptionDto> CreateCityAsync(string name, string? code, Guid countryId, CancellationToken ct = default);

    Task<CityCatalogOptionDto> UpdateCityAsync(Guid id, string name, string? code, Guid countryId, CancellationToken ct = default);

    Task DeleteCityAsync(Guid id, CancellationToken ct = default);

    Task<IReadOnlyList<AddressCityDto>> GetAddressCitiesAsync(CancellationToken ct = default);

    Task<AddressCityDto> CreateAddressCityAsync(string name, string? line, CancellationToken ct = default);

    Task DeleteAddressCityAsync(Guid id, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceGroupDto>> GetServiceGroupsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<ServiceDepartmentDto>> GetServiceDepartmentsAsync(Guid? groupId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceSubDepartmentDto>> GetServiceSubDepartmentsAsync(Guid? departmentId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceCatalogOptionDto>> GetServiceCatalogAsync(Guid? subDepartmentId = null, CancellationToken ct = default);

    Task<IReadOnlyList<ServiceHierarchyGroupDto>> GetServiceHierarchyAsync(CancellationToken ct = default);

    Task<ServiceGroupDto> CreateServiceGroupAsync(string name, CancellationToken ct = default);

    Task<ServiceDepartmentDto> CreateServiceDepartmentAsync(Guid groupId, string name, CancellationToken ct = default);

    Task<ServiceSubDepartmentDto> CreateServiceSubDepartmentAsync(Guid departmentId, string name, CancellationToken ct = default);

    Task<ServiceHierarchyItemDto> CreateServiceCatalogAsync(CreateServiceCatalogRequest request, CancellationToken ct = default);

    Task<ServiceHierarchyItemDto> UpdateServiceCatalogAsync(Guid id, UpdateServiceCatalogRequest request, CancellationToken ct = default);

    Task DeleteServiceCatalogAsync(Guid id, CancellationToken ct = default);
}
