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
public class CatalogsController(
    ICatalogService catalogs,
    IProjectMastersService projectMasters,
    IResourceMastersService resourceMasters) : ControllerBase
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
    public async Task<ActionResult<ApiResponse<AddressCityDto>>> CreateAddressCity(
        UpsertAddressCityRequest request,
        CancellationToken ct)
    {
        var created = await resourceMasters.CreateAddressCityAsync(request.Name, request.Line, ct);
        return Ok(ApiResponse<AddressCityDto>.Ok(created));
    }

    [HttpPut("address-cities/{id:guid}")]
    public async Task<ActionResult<ApiResponse<AddressCityDto>>> UpdateAddressCity(
        Guid id,
        UpsertAddressCityRequest request,
        CancellationToken ct)
    {
        var updated = await resourceMasters.UpdateAddressCityAsync(id, request.Name, request.Line, ct);
        return Ok(ApiResponse<AddressCityDto>.Ok(updated));
    }

    [HttpDelete("address-cities/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteAddressCity(Guid id, CancellationToken ct)
    {
        await resourceMasters.DeleteAddressCityAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpGet("resource-masters")]
    public async Task<ActionResult<ApiResponse<ResourceMastersSnapshotDto>>> ResourceMasters(CancellationToken ct)
    {
        return Ok(ApiResponse<ResourceMastersSnapshotDto>.Ok(
            await resourceMasters.GetSnapshotAsync(ct)));
    }

    [HttpPost("resource-masters/hierarchy")]
    public async Task<ActionResult<ApiResponse<DepartmentHierarchyRowDto>>> CreateHierarchy(
        UpsertDepartmentHierarchyRequest request,
        CancellationToken ct)
    {
        var created = await resourceMasters.CreateHierarchyAsync(request, ct);
        return Ok(ApiResponse<DepartmentHierarchyRowDto>.Ok(created));
    }

    [HttpPut("resource-masters/hierarchy/{id:guid}")]
    public async Task<ActionResult<ApiResponse<DepartmentHierarchyRowDto>>> UpdateHierarchy(
        Guid id,
        UpsertDepartmentHierarchyRequest request,
        CancellationToken ct)
    {
        var updated = await resourceMasters.UpdateHierarchyAsync(id, request, ct);
        return Ok(ApiResponse<DepartmentHierarchyRowDto>.Ok(updated));
    }

    [HttpDelete("resource-masters/hierarchy/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteHierarchy(Guid id, CancellationToken ct)
    {
        await resourceMasters.DeleteHierarchyAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("resource-masters/email-domains")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> CreateEmailDomain(
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var created = await resourceMasters.CreateEmailDomainAsync(request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(created));
    }

    [HttpPut("resource-masters/email-domains/{id:guid}")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> UpdateEmailDomain(
        Guid id,
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var updated = await resourceMasters.UpdateEmailDomainAsync(id, request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(updated));
    }

    [HttpDelete("resource-masters/email-domains/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteEmailDomain(Guid id, CancellationToken ct)
    {
        await resourceMasters.DeleteEmailDomainAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("resource-masters/business-units")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> CreateBusinessUnit(
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var created = await resourceMasters.CreateBusinessUnitAsync(request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(created));
    }

    [HttpPut("resource-masters/business-units/{id:guid}")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> UpdateBusinessUnit(
        Guid id,
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var updated = await resourceMasters.UpdateBusinessUnitAsync(id, request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(updated));
    }

    [HttpDelete("resource-masters/business-units/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteBusinessUnit(Guid id, CancellationToken ct)
    {
        await resourceMasters.DeleteBusinessUnitAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("resource-masters/work-locations")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> CreateWorkLocation(
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var created = await resourceMasters.CreateWorkLocationAsync(request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(created));
    }

    [HttpPut("resource-masters/work-locations/{id:guid}")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> UpdateWorkLocation(
        Guid id,
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var updated = await resourceMasters.UpdateWorkLocationAsync(id, request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(updated));
    }

    [HttpDelete("resource-masters/work-locations/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteWorkLocation(Guid id, CancellationToken ct)
    {
        await resourceMasters.DeleteWorkLocationAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("resource-masters/graduation-degrees")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> CreateGraduationDegree(
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var created = await resourceMasters.CreateGraduationDegreeAsync(request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(created));
    }

    [HttpPut("resource-masters/graduation-degrees/{id:guid}")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> UpdateGraduationDegree(
        Guid id,
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var updated = await resourceMasters.UpdateGraduationDegreeAsync(id, request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(updated));
    }

    [HttpDelete("resource-masters/graduation-degrees/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteGraduationDegree(Guid id, CancellationToken ct)
    {
        await resourceMasters.DeleteGraduationDegreeAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("resource-masters/post-graduation-degrees")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> CreatePostGraduationDegree(
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var created = await resourceMasters.CreatePostGraduationDegreeAsync(request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(created));
    }

    [HttpPut("resource-masters/post-graduation-degrees/{id:guid}")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> UpdatePostGraduationDegree(
        Guid id,
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var updated = await resourceMasters.UpdatePostGraduationDegreeAsync(id, request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(updated));
    }

    [HttpDelete("resource-masters/post-graduation-degrees/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeletePostGraduationDegree(Guid id, CancellationToken ct)
    {
        await resourceMasters.DeletePostGraduationDegreeAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("resource-masters/certifications")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> CreateCertification(
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var created = await resourceMasters.CreateCertificationAsync(request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(created));
    }

    [HttpPut("resource-masters/certifications/{id:guid}")]
    public async Task<ActionResult<ApiResponse<NamedMasterDto>>> UpdateCertification(
        Guid id,
        UpsertNamedMasterRequest request,
        CancellationToken ct)
    {
        var updated = await resourceMasters.UpdateCertificationAsync(id, request.Name, ct);
        return Ok(ApiResponse<NamedMasterDto>.Ok(updated));
    }

    [HttpDelete("resource-masters/certifications/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteCertification(Guid id, CancellationToken ct)
    {
        await resourceMasters.DeleteCertificationAsync(id, ct);
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

    [HttpGet("project-masters")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ProjectMasterRowDto>>>> ProjectMasters(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<ProjectMasterRowDto>>.Ok(
            await projectMasters.ListAsync(ct)));
    }

    [HttpPost("project-masters")]
    public async Task<ActionResult<ApiResponse<ProjectMasterRowDto>>> CreateProjectMaster(
        CreateProjectMasterRequest request,
        CancellationToken ct)
    {
        var created = await projectMasters.CreateAsync(request, ct);
        return Ok(ApiResponse<ProjectMasterRowDto>.Ok(created));
    }

    [HttpPut("project-masters/{id:guid}")]
    public async Task<ActionResult<ApiResponse<ProjectMasterRowDto>>> UpdateProjectMaster(
        Guid id,
        UpdateProjectMasterRequest request,
        CancellationToken ct)
    {
        var updated = await projectMasters.UpdateAsync(id, request, ct);
        return Ok(ApiResponse<ProjectMasterRowDto>.Ok(updated));
    }

    [HttpDelete("project-masters/{id:guid}")]
    public async Task<ActionResult<ApiResponse<Guid>>> DeleteProjectMaster(Guid id, CancellationToken ct)
    {
        await projectMasters.DeleteAsync(id, ct);
        return Ok(ApiResponse<Guid>.Ok(id));
    }

    [HttpPost("service-groups")]
    public async Task<ActionResult<ApiResponse<ServiceGroupDto>>> CreateServiceGroup(
        CreateServiceGroupRequest request,
        CancellationToken ct)
    {
        var created = await projectMasters.CreateGroupAsync(request.Name, ct);
        return Ok(ApiResponse<ServiceGroupDto>.Ok(created));
    }

    [HttpPost("service-departments")]
    public async Task<ActionResult<ApiResponse<ServiceDepartmentDto>>> CreateServiceDepartment(
        CreateServiceDepartmentRequest request,
        CancellationToken ct)
    {
        var created = await projectMasters.CreateDepartmentAsync(request, ct);
        return Ok(ApiResponse<ServiceDepartmentDto>.Ok(created));
    }

    [HttpPost("project-masters/service-only")]
    public async Task<ActionResult<ApiResponse<ProjectMasterRowDto>>> CreateServiceOnly(
        CreateServiceOnlyRequest request,
        CancellationToken ct)
    {
        var created = await projectMasters.CreateServiceOnlyAsync(request, ct);
        return Ok(ApiResponse<ProjectMasterRowDto>.Ok(created));
    }
}
