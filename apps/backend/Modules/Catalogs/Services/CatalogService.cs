using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Models;

namespace PMS.API.Modules.Catalogs.Services;

public sealed class CatalogService(AppDbContext db) : ICatalogService
{
    public async Task<IReadOnlyList<SidebarModuleDto>> GetModulesAsync(CancellationToken ct = default)
    {
        var modules = await db.Modules
            .Where(m => m.IsActive)
            .OrderBy(m => m.SortOrder)
            .ThenBy(m => m.Name)
            .ToListAsync(ct);
        var subModules = await db.SubModules
            .Where(s => s.IsActive)
            .OrderBy(s => s.SortOrder)
            .ThenBy(s => s.Name)
            .ToListAsync(ct);
        var widgets = await db.Widgets
            .Where(w => w.IsActive)
            .OrderBy(w => w.SortOrder)
            .ThenBy(w => w.Name)
            .ToListAsync(ct);
        var tabs = await db.Tabs
            .Where(t => t.IsActive)
            .OrderBy(t => t.SortOrder)
            .ThenBy(t => t.Name)
            .ToListAsync(ct);

        return modules
            .Select(m => new SidebarModuleDto(
                m.Id,
                m.Code,
                m.Name,
                m.Route,
                m.SortOrder,
                m.IconKey,
                ChildrenOf(subModules, tabs, m.Id, null),
                widgets
                    .Where(w => w.ParentId == m.Id)
                    .Select(w => new SidebarWidgetDto(w.Id, w.Code, w.Name, w.SortOrder, w.ParentId))
                    .ToList(),
                DirectTabs(tabs, moduleId: m.Id, subModuleId: null)))
            .ToList();
    }

    private static IReadOnlyList<SidebarTabDto> DirectTabs(
        IReadOnlyList<MstTab> rows,
        Guid? moduleId,
        Guid? subModuleId)
    {
        var matches = moduleId is not null
            ? rows.Where(t => t.ModuleId == moduleId && t.SubModuleId is null && t.TabId is null)
            : rows.Where(t => t.SubModuleId == subModuleId && t.ModuleId is null && t.TabId is null);

        return matches
            .Select(t => new SidebarTabDto(
                t.Id,
                t.Code,
                t.Name,
                t.SortOrder,
                t.ModuleId,
                t.SubModuleId,
                t.TabId,
                NestedTabs(rows, t.Id)))
            .ToList();
    }

    private static IReadOnlyList<SidebarTabDto> NestedTabs(IReadOnlyList<MstTab> rows, Guid tabId)
    {
        return rows
            .Where(t => t.TabId == tabId)
            .Select(t => new SidebarTabDto(
                t.Id,
                t.Code,
                t.Name,
                t.SortOrder,
                t.ModuleId,
                t.SubModuleId,
                t.TabId,
                NestedTabs(rows, t.Id)))
            .ToList();
    }

    private static IReadOnlyList<SidebarSubModuleDto> ChildrenOf(
        IReadOnlyList<MstSubModule> rows,
        IReadOnlyList<MstTab> tabs,
        Guid? moduleId,
        Guid? parentId)
    {
        var matches = parentId is null
            ? rows.Where(s => s.ModuleId == moduleId && s.ParentId is null)
            : rows.Where(s => s.ParentId == parentId);

        return matches
            .Select(s => new SidebarSubModuleDto(
                s.Id,
                s.Code,
                s.Name,
                s.Route,
                s.SortOrder,
                s.ParentId,
                ChildrenOf(rows, tabs, null, s.Id),
                DirectTabs(tabs, moduleId: null, subModuleId: s.Id)))
            .ToList();
    }

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

    public async Task<IReadOnlyList<AddressCityDto>> GetAddressCitiesAsync(CancellationToken ct = default)
    {
        return await db.AddressCities
            .Where(c => c.IsActive)
            .OrderBy(c => c.SortOrder)
            .ThenBy(c => c.Name)
            .Select(c => new AddressCityDto(c.Id, c.Code, c.Name, c.Line, c.SortOrder))
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
                c.SortOrder,
                c.Abbreviation))
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
                                    c.SortOrder,
                                    c.Abbreviation))
                                .ToList()))
                        .ToList()))
                .ToList()))
            .ToList();
    }
}
