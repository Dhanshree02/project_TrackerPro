using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Services;
using PMS.API.Shared.Common.Wrappers;

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
}
