using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Services;

public sealed class CatalogService(AppDbContext db) : ICatalogService
{
    public async Task<IReadOnlyList<CatalogOptionDto>> GetCountriesAsync(CancellationToken ct = default)
    {
        return await db.Countries
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .Select(c => new CatalogOptionDto(c.Id, c.Code, c.Name, c.PhoneCode, c.PhoneDigits))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetNationalitiesAsync(CancellationToken ct = default)
    {
        return await db.Nationalities
            .Where(n => n.IsActive)
            .OrderBy(n => n.Name)
            .Select(n => new CatalogOptionDto(n.Id, n.Code, n.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CityCatalogOptionDto>> GetCitiesAsync(
        Guid? countryId,
        CancellationToken ct = default)
    {
        var query = db.Cities.Where(c => c.IsActive);
        if (countryId is not null)
        {
            query = query.Where(c => c.CountryId == countryId);
        }

        return await query
            .OrderBy(c => c.Name)
            .Select(c => new CityCatalogOptionDto(c.Id, c.Code, c.Name, c.CountryId))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetIndustriesAsync(CancellationToken ct = default)
    {
        return await db.Industries
            .Where(i => i.IsActive)
            .OrderBy(i => i.Name)
            .Select(i => new CatalogOptionDto(i.Id, i.Code, i.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetContactDesignationsAsync(CancellationToken ct = default)
    {
        return await db.ContactDesignations
            .Where(d => d.IsActive)
            .OrderBy(d => d.SortOrder)
            .ThenBy(d => d.Name)
            .Select(d => new CatalogOptionDto(d.Id, d.Code, d.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetContactTypesAsync(CancellationToken ct = default)
    {
        return await db.ContactTypes
            .Where(t => t.IsActive)
            .OrderBy(t => t.SortOrder)
            .ThenBy(t => t.Name)
            .Select(t => new CatalogOptionDto(t.Id, t.Code, t.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceGroupDto>> GetServiceGroupsAsync(CancellationToken ct = default)
    {
        return await db.ServiceGroups
            .Where(g => g.IsActive)
            .OrderBy(g => g.SortOrder)
            .ThenBy(g => g.Name)
            .Select(g => new ServiceGroupDto(g.Id, g.Code, g.Name, g.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceDepartmentDto>> GetServiceDepartmentsAsync(
        Guid? groupId = null,
        CancellationToken ct = default)
    {
        var query = db.ServiceDepartments
            .Include(d => d.Group)
            .Where(d => d.IsActive);

        if (groupId.HasValue)
        {
            query = query.Where(d => d.GroupId == groupId.Value);
        }

        return await query
            .OrderBy(d => d.SortOrder)
            .ThenBy(d => d.Name)
            .Select(d => new ServiceDepartmentDto(
                d.Id,
                d.Code,
                d.Name,
                d.GroupId,
                d.Group != null ? d.Group.Name : string.Empty,
                d.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceSubDepartmentDto>> GetServiceSubDepartmentsAsync(
        Guid? departmentId = null,
        CancellationToken ct = default)
    {
        var query = db.ServiceSubDepartments
            .Include(s => s.Department)
            .Where(s => s.IsActive);

        if (departmentId.HasValue)
        {
            query = query.Where(s => s.DepartmentId == departmentId.Value);
        }

        return await query
            .OrderBy(s => s.SortOrder)
            .ThenBy(s => s.Name)
            .Select(s => new ServiceSubDepartmentDto(
                s.Id,
                s.Code,
                s.Name,
                s.DepartmentId,
                s.Department != null ? s.Department.Name : string.Empty,
                s.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceCatalogOptionDto>> GetServiceCatalogAsync(
        Guid? subDepartmentId = null,
        CancellationToken ct = default)
    {
        var query = db.ServiceCatalogs
            .Include(c => c.SubDepartment)
            .Where(c => c.IsActive);

        if (subDepartmentId.HasValue)
        {
            query = query.Where(c => c.SubDepartmentId == subDepartmentId.Value);
        }

        return await query
            .OrderBy(c => c.SortOrder)
            .ThenBy(c => c.Name)
            .Select(c => new ServiceCatalogOptionDto(
                c.Id,
                c.Code,
                c.Name,
                c.SubDepartmentId,
                c.SubDepartment != null ? c.SubDepartment.Name : string.Empty,
                c.DefaultTools,
                c.DefaultUnitPrice,
                c.DefaultDurationDays,
                c.Description,
                c.SortOrder))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<ServiceHierarchyGroupDto>> GetServiceHierarchyAsync(CancellationToken ct = default)
    {
        var groups = await db.ServiceGroups
            .Where(g => g.IsActive)
            .OrderBy(g => g.SortOrder)
            .ThenBy(g => g.Name)
            .Include(g => g.Departments.Where(d => d.IsActive))
                .ThenInclude(d => d.SubDepartments.Where(s => s.IsActive))
                    .ThenInclude(s => s.Services.Where(c => c.IsActive))
            .ToListAsync(ct);

        return groups.Select(g => new ServiceHierarchyGroupDto(
            g.Id,
            g.Code,
            g.Name,
            g.SortOrder,
            g.Departments
                .OrderBy(d => d.SortOrder)
                .ThenBy(d => d.Name)
                .Select(d => new ServiceHierarchyDeptDto(
                    d.Id,
                    d.Code,
                    d.Name,
                    g.Code,
                    g.Name,
                    d.SortOrder,
                    d.SubDepartments
                        .OrderBy(s => s.SortOrder)
                        .ThenBy(s => s.Name)
                        .Select(s => new ServiceHierarchySubDeptDto(
                            s.Id,
                            s.Code,
                            s.Name,
                            s.SortOrder,
                            s.Services
                                .OrderBy(c => c.SortOrder)
                                .ThenBy(c => c.Name)
                                .Select(c => new ServiceHierarchyItemDto(
                                    c.Id,
                                    c.Code,
                                    c.Name,
                                    c.DefaultTools,
                                    c.DefaultUnitPrice,
                                    c.DefaultDurationDays,
                                    c.Description,
                                    c.SortOrder))
                                .ToList()))
                        .ToList()))
                .ToList()))
            .ToList();
    }
}
