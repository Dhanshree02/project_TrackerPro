using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Services;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.Catalogs.Controllers;

/// <summary>
/// Shared catalogs. Authenticated callers from any module can load these
/// for country / city / nationality / service catalog dropdowns.
/// </summary>
[ApiController]
[Route("api/v1/catalogs")]
public class CatalogsController(ICatalogService catalogs) : ControllerBase
{
    [HttpGet("countries")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CatalogOptionDto>>>> Countries(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CatalogOptionDto>>.Ok(await catalogs.GetCountriesAsync(ct)));
    }

    [HttpGet("nationalities")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CatalogOptionDto>>>> Nationalities(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CatalogOptionDto>>.Ok(await catalogs.GetNationalitiesAsync(ct)));
    }

    [HttpGet("cities")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CityCatalogOptionDto>>>> Cities(
        [FromQuery] Guid? countryId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CityCatalogOptionDto>>.Ok(
            await catalogs.GetCitiesAsync(countryId, ct)));
    }

    [HttpGet("industries")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CatalogOptionDto>>>> Industries(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CatalogOptionDto>>.Ok(await catalogs.GetIndustriesAsync(ct)));
    }

    [HttpGet("contact-designations")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CatalogOptionDto>>>> ContactDesignations(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CatalogOptionDto>>.Ok(
            await catalogs.GetContactDesignationsAsync(ct)));
    }

    [HttpGet("contact-types")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CatalogOptionDto>>>> ContactTypes(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CatalogOptionDto>>.Ok(
            await catalogs.GetContactTypesAsync(ct)));
    }

    [HttpPost("industries")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> CreateIndustry(
        UpsertNamedCatalogRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CatalogOptionDto>.Ok(await catalogs.CreateIndustryAsync(request.Name, request.Code, ct)));

    [HttpPut("industries/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> UpdateIndustry(
        Guid id, UpsertNamedCatalogRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CatalogOptionDto>.Ok(await catalogs.UpdateIndustryAsync(id, request.Name, request.Code, ct)));

    [HttpDelete("industries/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteIndustry(Guid id, CancellationToken ct)
    {
        await catalogs.DeleteIndustryAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("contact-designations")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> CreateContactDesignation(
        UpsertNamedCatalogRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CatalogOptionDto>.Ok(await catalogs.CreateContactDesignationAsync(request.Name, request.Code, ct)));

    [HttpPut("contact-designations/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> UpdateContactDesignation(
        Guid id, UpsertNamedCatalogRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CatalogOptionDto>.Ok(await catalogs.UpdateContactDesignationAsync(id, request.Name, request.Code, ct)));

    [HttpDelete("contact-designations/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteContactDesignation(Guid id, CancellationToken ct)
    {
        await catalogs.DeleteContactDesignationAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("contact-types")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> CreateContactType(
        UpsertNamedCatalogRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CatalogOptionDto>.Ok(await catalogs.CreateContactTypeAsync(request.Name, request.Code, ct)));

    [HttpPut("contact-types/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> UpdateContactType(
        Guid id, UpsertNamedCatalogRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CatalogOptionDto>.Ok(await catalogs.UpdateContactTypeAsync(id, request.Name, request.Code, ct)));

    [HttpDelete("contact-types/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteContactType(Guid id, CancellationToken ct)
    {
        await catalogs.DeleteContactTypeAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("countries")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> CreateCountry(
        UpsertNamedCatalogRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CatalogOptionDto>.Ok(await catalogs.CreateCountryAsync(request.Name, request.Code, ct)));

    [HttpPut("countries/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> UpdateCountry(
        Guid id, UpsertNamedCatalogRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CatalogOptionDto>.Ok(await catalogs.UpdateCountryAsync(id, request.Name, request.Code, ct)));

    [HttpDelete("countries/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteCountry(Guid id, CancellationToken ct)
    {
        await catalogs.DeleteCountryAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("cities")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CityCatalogOptionDto>>> CreateCity(
        UpsertCityRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CityCatalogOptionDto>.Ok(await catalogs.CreateCityAsync(request.Name, request.Code, request.CountryId, ct)));

    [HttpPut("cities/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<CityCatalogOptionDto>>> UpdateCity(
        Guid id, UpsertCityRequest request, CancellationToken ct) =>
        Ok(ApiResponse<CityCatalogOptionDto>.Ok(await catalogs.UpdateCityAsync(id, request.Name, request.Code, request.CountryId, ct)));

    [HttpDelete("cities/{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteCity(Guid id, CancellationToken ct)
    {
        await catalogs.DeleteCityAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpGet("address-cities")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<AddressCityDto>>>> AddressCities(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<AddressCityDto>>.Ok(
            await catalogs.GetAddressCitiesAsync(ct)));
    }

    [HttpPost("address-cities")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<AddressCityDto>>> CreateAddressCity(
        CreateAddressCityRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateAddressCityAsync(request.Name, request.Line, ct);
        return Ok(ApiResponse<AddressCityDto>.Ok(created));
    }

    [HttpDelete("address-cities/{id:guid}")]
    [RequirePermission(Permissions.ResourcesManage)]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteAddressCity(Guid id, CancellationToken ct)
    {
        await catalogs.DeleteAddressCityAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpGet("service-groups")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ServiceGroupDto>>>> ServiceGroups(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<ServiceGroupDto>>.Ok(
            await catalogs.GetServiceGroupsAsync(ct)));
    }

    [HttpGet("service-departments")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ServiceDepartmentDto>>>> ServiceDepartments(
        [FromQuery] Guid? groupId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<ServiceDepartmentDto>>.Ok(
            await catalogs.GetServiceDepartmentsAsync(groupId, ct)));
    }

    [HttpGet("service-sub-departments")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ServiceSubDepartmentDto>>>> ServiceSubDepartments(
        [FromQuery] Guid? departmentId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<ServiceSubDepartmentDto>>.Ok(
            await catalogs.GetServiceSubDepartmentsAsync(departmentId, ct)));
    }

    [HttpGet("service-catalog")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ServiceCatalogOptionDto>>>> ServiceCatalog(
        [FromQuery] Guid? subDepartmentId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<ServiceCatalogOptionDto>>.Ok(
            await catalogs.GetServiceCatalogAsync(subDepartmentId, ct)));
    }

    [HttpGet("service-hierarchy")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ServiceHierarchyGroupDto>>>> ServiceHierarchy(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<ServiceHierarchyGroupDto>>.Ok(
            await catalogs.GetServiceHierarchyAsync(ct)));
    }

    [HttpPost("service-groups")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ServiceGroupDto>>> CreateServiceGroup(
        CreateServiceGroupRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateServiceGroupAsync(request.Name, ct);
        return Ok(ApiResponse<ServiceGroupDto>.Ok(created));
    }

    [HttpPost("service-departments")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ServiceDepartmentDto>>> CreateServiceDepartment(
        CreateServiceDepartmentRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateServiceDepartmentAsync(request.GroupId, request.Name, ct);
        return Ok(ApiResponse<ServiceDepartmentDto>.Ok(created));
    }

    [HttpPost("service-sub-departments")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ServiceSubDepartmentDto>>> CreateServiceSubDepartment(
        CreateServiceSubDepartmentRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateServiceSubDepartmentAsync(request.DepartmentId, request.Name, ct);
        return Ok(ApiResponse<ServiceSubDepartmentDto>.Ok(created));
    }

    [HttpPost("service-catalog")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ServiceHierarchyItemDto>>> CreateServiceCatalog(
        CreateServiceCatalogRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateServiceCatalogAsync(request, ct);
        return Ok(ApiResponse<ServiceHierarchyItemDto>.Ok(created));
    }

    [HttpPut("service-catalog/{id:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<ServiceHierarchyItemDto>>> UpdateServiceCatalog(
        Guid id,
        UpdateServiceCatalogRequest request,
        CancellationToken ct)
    {
        var updated = await catalogs.UpdateServiceCatalogAsync(id, request, ct);
        return Ok(ApiResponse<ServiceHierarchyItemDto>.Ok(updated));
    }

    [HttpDelete("service-catalog/{id:guid}")]
    [RequirePermission(Permissions.ProjectsWrite)]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteServiceCatalog(Guid id, CancellationToken ct)
    {
        await catalogs.DeleteServiceCatalogAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }
}
