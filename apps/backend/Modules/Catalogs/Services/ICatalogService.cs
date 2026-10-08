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

    Task<ServiceDepartmentDto> CreateServiceDepartmentAsync(CreateServiceDepartmentRequest request, CancellationToken ct = default);

    Task<ServiceSubDepartmentDto> CreateServiceSubDepartmentAsync(CreateServiceSubDepartmentRequest request, CancellationToken ct = default);

    Task<ServiceCatalogOptionDto> CreateServiceCatalogAsync(CreateServiceCatalogRequest request, CancellationToken ct = default);

    Task<ServiceGroupDto> CreateServiceGroupAsync(CreateServiceGroupRequest request, CancellationToken ct = default);

    Task<IReadOnlyList<ProjectMasterDto>> GetProjectMastersAsync(CancellationToken ct = default);

    Task<ProjectMasterDto> CreateProjectMasterAsync(CreateProjectMasterRequest request, CancellationToken ct = default);

    Task<ProjectMasterDto> UpdateProjectMasterAsync(Guid id, UpdateProjectMasterRequest request, CancellationToken ct = default);

    Task<bool> DeleteProjectMasterAsync(Guid id, CancellationToken ct = default);

    // Customer Masters CRUD
    Task<CatalogOptionDto> CreateCountryAsync(CreateCountryRequest request, CancellationToken ct = default);
    Task<CatalogOptionDto> UpdateCountryAsync(Guid id, UpdateCountryRequest request, CancellationToken ct = default);
    Task<bool> DeleteCountryAsync(Guid id, CancellationToken ct = default);

    Task<CityCatalogOptionDto> CreateCityAsync(CreateCustomerCityRequest request, CancellationToken ct = default);
    Task<CityCatalogOptionDto> UpdateCityAsync(Guid id, UpdateCustomerCityRequest request, CancellationToken ct = default);
    Task<bool> DeleteCityAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateIndustryAsync(CreateCatalogItemRequest request, CancellationToken ct = default);
    Task<CatalogOptionDto> UpdateIndustryAsync(Guid id, UpdateCatalogItemRequest request, CancellationToken ct = default);
    Task<bool> DeleteIndustryAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateContactDesignationAsync(CreateCatalogItemRequest request, CancellationToken ct = default);
    Task<CatalogOptionDto> UpdateContactDesignationAsync(Guid id, UpdateCatalogItemRequest request, CancellationToken ct = default);
    Task<bool> DeleteContactDesignationAsync(Guid id, CancellationToken ct = default);

    Task<CatalogOptionDto> CreateContactTypeAsync(CreateCatalogItemRequest request, CancellationToken ct = default);
    Task<CatalogOptionDto> UpdateContactTypeAsync(Guid id, UpdateCatalogItemRequest request, CancellationToken ct = default);
    Task<bool> DeleteContactTypeAsync(Guid id, CancellationToken ct = default);
}
