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

    [HttpPost("service-departments")]
    public async Task<ActionResult<ApiResponse<ServiceDepartmentDto>>> CreateServiceDepartment(
        [FromBody] CreateServiceDepartmentRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateServiceDepartmentAsync(request, ct);
        return StatusCode(201, ApiResponse<ServiceDepartmentDto>.Ok(created));
    }

    [HttpPost("service-sub-departments")]
    public async Task<ActionResult<ApiResponse<ServiceSubDepartmentDto>>> CreateServiceSubDepartment(
        [FromBody] CreateServiceSubDepartmentRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateServiceSubDepartmentAsync(request, ct);
        return StatusCode(201, ApiResponse<ServiceSubDepartmentDto>.Ok(created));
    }

    [HttpPost("service-catalog")]
    public async Task<ActionResult<ApiResponse<ServiceCatalogOptionDto>>> CreateServiceCatalog(
        [FromBody] CreateServiceCatalogRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateServiceCatalogAsync(request, ct);
        return StatusCode(201, ApiResponse<ServiceCatalogOptionDto>.Ok(created));
    }

    [HttpGet("project-masters")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectMasterDto>>>> GetProjectMasters(
        CancellationToken ct)
    {
        var list = await catalogs.GetProjectMastersAsync(ct);
        return Ok(ApiResponse<IReadOnlyList<ProjectMasterDto>>.Ok(list));
    }

    [HttpPost("project-masters")]
    public async Task<ActionResult<ApiResponse<ProjectMasterDto>>> CreateProjectMaster(
        [FromBody] CreateProjectMasterRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateProjectMasterAsync(request, ct);
        return StatusCode(201, ApiResponse<ProjectMasterDto>.Ok(created));
    }

    [HttpPut("project-masters/{id:guid}")]
    public async Task<ActionResult<ApiResponse<ProjectMasterDto>>> UpdateProjectMaster(
        [FromRoute] Guid id,
        [FromBody] UpdateProjectMasterRequest request,
        CancellationToken ct)
    {
        var updated = await catalogs.UpdateProjectMasterAsync(id, request, ct);
        return Ok(ApiResponse<ProjectMasterDto>.Ok(updated));
    }

    [HttpDelete("project-masters/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteProjectMaster(
        [FromRoute] Guid id,
        CancellationToken ct)
    {
        var deleted = await catalogs.DeleteProjectMasterAsync(id, ct);
        return Ok(ApiResponse<bool>.Ok(deleted));
    }

    [HttpPost("service-groups")]
    public async Task<ActionResult<ApiResponse<ServiceGroupDto>>> CreateServiceGroup(
        [FromBody] CreateServiceGroupRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateServiceGroupAsync(request, ct);
        return StatusCode(201, ApiResponse<ServiceGroupDto>.Ok(created));
    }

    // ══════════════════════════════════════════════════════════════════════════
    // Customer Masters Endpoints
    // ══════════════════════════════════════════════════════════════════════════

    // ── Countries ──
    [HttpPost("countries")]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> CreateCountry(
        [FromBody] CreateCountryRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateCountryAsync(request, ct);
        return StatusCode(201, ApiResponse<CatalogOptionDto>.Ok(created));
    }

    [HttpPut("countries/{id:guid}")]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> UpdateCountry(
        [FromRoute] Guid id,
        [FromBody] UpdateCountryRequest request,
        CancellationToken ct)
    {
        var updated = await catalogs.UpdateCountryAsync(id, request, ct);
        return Ok(ApiResponse<CatalogOptionDto>.Ok(updated));
    }

    [HttpDelete("countries/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteCountry(
        [FromRoute] Guid id,
        CancellationToken ct)
    {
        var deleted = await catalogs.DeleteCountryAsync(id, ct);
        return Ok(ApiResponse<bool>.Ok(deleted));
    }

    // ── Cities (Country Dependency) ──
    [HttpPost("cities")]
    public async Task<ActionResult<ApiResponse<CityCatalogOptionDto>>> CreateCity(
        [FromBody] CreateCustomerCityRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateCityAsync(request, ct);
        return StatusCode(201, ApiResponse<CityCatalogOptionDto>.Ok(created));
    }

    [HttpPut("cities/{id:guid}")]
    public async Task<ActionResult<ApiResponse<CityCatalogOptionDto>>> UpdateCity(
        [FromRoute] Guid id,
        [FromBody] UpdateCustomerCityRequest request,
        CancellationToken ct)
    {
        var updated = await catalogs.UpdateCityAsync(id, request, ct);
        return Ok(ApiResponse<CityCatalogOptionDto>.Ok(updated));
    }

    [HttpDelete("cities/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteCity(
        [FromRoute] Guid id,
        CancellationToken ct)
    {
        var deleted = await catalogs.DeleteCityAsync(id, ct);
        return Ok(ApiResponse<bool>.Ok(deleted));
    }

    // ── Industries ──
    [HttpPost("industries")]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> CreateIndustry(
        [FromBody] CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateIndustryAsync(request, ct);
        return StatusCode(201, ApiResponse<CatalogOptionDto>.Ok(created));
    }

    [HttpPut("industries/{id:guid}")]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> UpdateIndustry(
        [FromRoute] Guid id,
        [FromBody] UpdateCatalogItemRequest request,
        CancellationToken ct)
    {
        var updated = await catalogs.UpdateIndustryAsync(id, request, ct);
        return Ok(ApiResponse<CatalogOptionDto>.Ok(updated));
    }

    [HttpDelete("industries/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteIndustry(
        [FromRoute] Guid id,
        CancellationToken ct)
    {
        var deleted = await catalogs.DeleteIndustryAsync(id, ct);
        return Ok(ApiResponse<bool>.Ok(deleted));
    }

    // ── Contact Designations ──
    [HttpPost("contact-designations")]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> CreateContactDesignation(
        [FromBody] CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateContactDesignationAsync(request, ct);
        return StatusCode(201, ApiResponse<CatalogOptionDto>.Ok(created));
    }

    [HttpPut("contact-designations/{id:guid}")]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> UpdateContactDesignation(
        [FromRoute] Guid id,
        [FromBody] UpdateCatalogItemRequest request,
        CancellationToken ct)
    {
        var updated = await catalogs.UpdateContactDesignationAsync(id, request, ct);
        return Ok(ApiResponse<CatalogOptionDto>.Ok(updated));
    }

    [HttpDelete("contact-designations/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteContactDesignation(
        [FromRoute] Guid id,
        CancellationToken ct)
    {
        var deleted = await catalogs.DeleteContactDesignationAsync(id, ct);
        return Ok(ApiResponse<bool>.Ok(deleted));
    }

    // ── Contact Types ──
    [HttpPost("contact-types")]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> CreateContactType(
        [FromBody] CreateCatalogItemRequest request,
        CancellationToken ct)
    {
        var created = await catalogs.CreateContactTypeAsync(request, ct);
        return StatusCode(201, ApiResponse<CatalogOptionDto>.Ok(created));
    }

    [HttpPut("contact-types/{id:guid}")]
    public async Task<ActionResult<ApiResponse<CatalogOptionDto>>> UpdateContactType(
        [FromRoute] Guid id,
        [FromBody] UpdateCatalogItemRequest request,
        CancellationToken ct)
    {
        var updated = await catalogs.UpdateContactTypeAsync(id, request, ct);
        return Ok(ApiResponse<CatalogOptionDto>.Ok(updated));
    }

    [HttpDelete("contact-types/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteContactType(
        [FromRoute] Guid id,
        CancellationToken ct)
    {
        var deleted = await catalogs.DeleteContactTypeAsync(id, ct);
        return Ok(ApiResponse<bool>.Ok(deleted));
    }
}


