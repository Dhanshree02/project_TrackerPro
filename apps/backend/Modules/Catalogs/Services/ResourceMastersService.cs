using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Common.Models;
using PMS.API.Shared.Constants;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Catalogs.Services;

/// <summary>
/// Settings → Resource Masters. Writes only the existing master-schema catalogs:
/// departments, designations, on-floor roles, org-role map, email domains,
/// business units, work locations, degrees, certifications, and address cities.
/// Assigned RBAC Role is chosen from <c>auth.tbl_roles</c> and stored as a foreign key.
/// </summary>
public sealed class ResourceMastersService(AppDbContext db) : IResourceMastersService
{
    private static readonly Regex DomainPattern = new(
        @"^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?)+$",
        RegexOptions.Compiled | RegexOptions.CultureInvariant);

    public async Task<ResourceMastersSnapshotDto> GetSnapshotAsync(CancellationToken ct = default)
    {
        return new ResourceMastersSnapshotDto(
            await BuildHierarchyBundleAsync(ct),
            await ListEmailDomainsAsync(ct),
            await ListBusinessUnitsAsync(ct),
            await ListWorkLocationsAsync(ct),
            await ListGraduationDegreesAsync(ct),
            await ListPostGraduationDegreesAsync(ct),
            await ListCertificationsAsync(ct),
            await ListAddressCitiesAsync(ct));
    }

    public async Task<DepartmentHierarchyRowDto> CreateHierarchyAsync(
        UpsertDepartmentHierarchyRequest request,
        CancellationToken ct = default)
    {
        var departmentName = RequireName(request.Department, "Department", 150);
        var designationName = RequireName(request.Designation, "Designation", 150);
        var subDepartment = RequireName(request.SubDepartment, "Sub-Department", 250);
        var onFloorName = RequireName(request.OnFloorRole, "On Floor Role", 150);
        var rbac = await RequireRbacAsync(request.RbacRoleId, ct);
        var department = await ResolveDepartmentAsync(departmentName, ct);
        var onFloor = await ResolveOnFloorRoleAsync(onFloorName, ct);

        var matches = await db.Designations
            .IgnoreQueryFilters()
            .Where(d => d.DepartmentId == department.Id && d.Name.ToLower() == designationName.ToLower())
            .ToListAsync(ct);
        var live = matches.FirstOrDefault(d => d.DeletedAtUtc == null && d.IsActive);
        if (live is not null)
            throw new ConflictException(
                $"\"{designationName}\" already exists under {department.Name}. Edit that row instead.");

        MstDesignation designation;
        if (matches.Count > 0)
        {
            designation = matches[0];
            foreach (var extra in matches.Skip(1))
                ParkDesignation(extra);
            designation.DeletedAtUtc = null;
            designation.IsActive = true;
            designation.Name = designationName;
        }
        else
        {
            designation = new MstDesignation
            {
                Code = await UniqueCodeAsync(
                    Truncate($"{department.Code}_{Slug(designationName)}", 80),
                    code => db.Designations.IgnoreQueryFilters().AnyAsync(d => d.Code == code, ct)),
                Name = designationName,
                DepartmentId = department.Id,
                IsActive = true,
            };
            db.Designations.Add(designation);
        }

        await LinkHierarchyAsync(designation, department, onFloor, rbac, subDepartment, ct);
        await db.SaveChangesAsync(ct);
        return await LoadHierarchyRowAsync(designation.Id, ct);
    }

    public async Task<DepartmentHierarchyRowDto> UpdateHierarchyAsync(
        Guid designationId,
        UpsertDepartmentHierarchyRequest request,
        CancellationToken ct = default)
    {
        var departmentName = RequireName(request.Department, "Department", 150);
        var designationName = RequireName(request.Designation, "Designation", 150);
        var subDepartment = RequireName(request.SubDepartment, "Sub-Department", 250);
        var onFloorName = RequireName(request.OnFloorRole, "On Floor Role", 150);
        var rbac = await RequireRbacAsync(request.RbacRoleId, ct);
        var department = await ResolveDepartmentAsync(departmentName, ct);
        var onFloor = await ResolveOnFloorRoleAsync(onFloorName, ct);

        var designation = await db.Designations
            .FirstOrDefaultAsync(d => d.Id == designationId, ct)
            ?? throw new NotFoundException("Department hierarchy row was not found.");

        var previousOnFloorId = designation.JobRoleId;
        var matches = await db.Designations
            .IgnoreQueryFilters()
            .Where(d =>
                d.Id != designationId &&
                d.DepartmentId == department.Id &&
                d.Name.ToLower() == designationName.ToLower())
            .ToListAsync(ct);
        if (matches.Any(d => d.DeletedAtUtc == null && d.IsActive))
            throw new ConflictException(
                $"\"{designationName}\" already exists under {department.Name}.");

        foreach (var extra in matches.Where(d => d.DeletedAtUtc != null || !d.IsActive))
            ParkDesignation(extra);

        designation.Name = designationName;
        designation.DepartmentId = department.Id;
        designation.IsActive = true;
        designation.DeletedAtUtc = null;
        await LinkHierarchyAsync(designation, department, onFloor, rbac, subDepartment, ct);
        await db.SaveChangesAsync(ct);
        await RetireUnusedCustomOnFloorAsync(previousOnFloorId, designation.Id, ct);
        await db.SaveChangesAsync(ct);
        return await LoadHierarchyRowAsync(designation.Id, ct);
    }

    public async Task DeleteHierarchyAsync(Guid designationId, CancellationToken ct = default)
    {
        var designation = await db.Designations
            .FirstOrDefaultAsync(d => d.Id == designationId, ct)
            ?? throw new NotFoundException("Department hierarchy row was not found.");

        var inUse = await db.Employees.AnyAsync(e => e.DesignationId == designation.Id, ct);
        if (inUse)
            throw new ConflictException(
                $"\"{designation.Name}\" is assigned to employees. Move those employees before deleting it.");

        var previousOnFloorId = designation.JobRoleId;
        var departmentId = designation.DepartmentId;
        var maps = await db.OrgRoleMaps
            .IgnoreQueryFilters()
            .Where(m => m.DesignationId == designation.Id)
            .ToListAsync(ct);
        foreach (var map in maps.Where(m => m.DeletedAtUtc == null))
        {
            db.OrgRoleMaps.Remove(map);
        }

        designation.IsActive = false;
        db.Designations.Remove(designation);
        await db.SaveChangesAsync(ct);
        await RetireUnusedCustomOnFloorAsync(previousOnFloorId, designation.Id, ct);
        await RetireUnusedDepartmentAsync(departmentId, ct);
        await db.SaveChangesAsync(ct);
    }

    private async Task RetireUnusedDepartmentAsync(Guid? departmentId, CancellationToken ct)
    {
        if (departmentId is not Guid id) return;
        var stillUsed = await db.Designations.AnyAsync(d => d.DepartmentId == id, ct)
            || await db.Employees.AnyAsync(e => e.DepartmentId == id, ct);
        if (stillUsed) return;

        var department = await db.Departments.FirstOrDefaultAsync(d => d.Id == id, ct);
        if (department is null) return;
        ParkDepartment(department);
        department.IsActive = false;
        department.DeletedAtUtc = DateTime.UtcNow;
    }

    public Task<NamedMasterDto> CreateEmailDomainAsync(string name, CancellationToken ct = default) =>
        SaveEmailDomainAsync(null, name, ct);

    public Task<NamedMasterDto> UpdateEmailDomainAsync(Guid id, string name, CancellationToken ct = default) =>
        SaveEmailDomainAsync(id, name, ct);

    public async Task DeleteEmailDomainAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.EmailDomains.FirstOrDefaultAsync(d => d.Id == id, ct)
            ?? throw new NotFoundException("Work email domain was not found.");
        row.IsActive = false;
        db.EmailDomains.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<NamedMasterDto> CreateBusinessUnitAsync(string name, CancellationToken ct = default) =>
        SaveBusinessUnitAsync(null, name, ct);

    public Task<NamedMasterDto> UpdateBusinessUnitAsync(Guid id, string name, CancellationToken ct = default) =>
        SaveBusinessUnitAsync(id, name, ct);

    public async Task DeleteBusinessUnitAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.BusinessUnits.FirstOrDefaultAsync(b => b.Id == id, ct)
            ?? throw new NotFoundException("Business unit was not found.");
        row.IsActive = false;
        db.BusinessUnits.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<NamedMasterDto> CreateWorkLocationAsync(string name, CancellationToken ct = default) =>
        SaveWorkLocationAsync(null, name, ct);

    public Task<NamedMasterDto> UpdateWorkLocationAsync(Guid id, string name, CancellationToken ct = default) =>
        SaveWorkLocationAsync(id, name, ct);

    public async Task DeleteWorkLocationAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.WorkLocations.FirstOrDefaultAsync(w => w.Id == id, ct)
            ?? throw new NotFoundException("Work location was not found.");
        row.IsActive = false;
        db.WorkLocations.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<NamedMasterDto> CreateGraduationDegreeAsync(string name, CancellationToken ct = default) =>
        SaveGraduationAsync(null, name, ct);

    public Task<NamedMasterDto> UpdateGraduationDegreeAsync(Guid id, string name, CancellationToken ct = default) =>
        SaveGraduationAsync(id, name, ct);

    public async Task DeleteGraduationDegreeAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.GraduationDegrees.FirstOrDefaultAsync(g => g.Id == id, ct)
            ?? throw new NotFoundException("Graduation degree was not found.");
        row.IsActive = false;
        db.GraduationDegrees.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<NamedMasterDto> CreatePostGraduationDegreeAsync(string name, CancellationToken ct = default) =>
        SavePostGraduationAsync(null, name, ct);

    public Task<NamedMasterDto> UpdatePostGraduationDegreeAsync(Guid id, string name, CancellationToken ct = default) =>
        SavePostGraduationAsync(id, name, ct);

    public async Task DeletePostGraduationDegreeAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.PostGraduationDegrees.FirstOrDefaultAsync(p => p.Id == id, ct)
            ?? throw new NotFoundException("Post graduation degree was not found.");
        row.IsActive = false;
        db.PostGraduationDegrees.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public Task<NamedMasterDto> CreateCertificationAsync(string name, CancellationToken ct = default) =>
        SaveCertificationAsync(null, name, ct);

    public Task<NamedMasterDto> UpdateCertificationAsync(Guid id, string name, CancellationToken ct = default) =>
        SaveCertificationAsync(id, name, ct);

    public async Task DeleteCertificationAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.Certifications.FirstOrDefaultAsync(c => c.Id == id, ct)
            ?? throw new NotFoundException("Certification was not found.");
        row.IsActive = false;
        db.Certifications.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    public async Task<AddressCityDto> CreateAddressCityAsync(string name, string? line, CancellationToken ct = default)
    {
        var city = await SaveAddressCityAsync(null, name, line, ct);
        return MapCity(city);
    }

    public async Task<AddressCityDto> UpdateAddressCityAsync(Guid id, string name, string? line, CancellationToken ct = default)
    {
        var city = await SaveAddressCityAsync(id, name, line, ct);
        return MapCity(city);
    }

    public async Task DeleteAddressCityAsync(Guid id, CancellationToken ct = default)
    {
        var row = await db.AddressCities.FirstOrDefaultAsync(c => c.Id == id, ct)
            ?? throw new NotFoundException("Address city was not found.");
        row.IsActive = false;
        db.AddressCities.Remove(row);
        await db.SaveChangesAsync(ct);
    }

    private async Task<DepartmentHierarchyBundleDto> BuildHierarchyBundleAsync(CancellationToken ct)
    {
        var departments = await db.Departments
            .AsNoTracking()
            .Where(d => d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => new NamedMasterDto(d.Id, d.Code, d.Name))
            .ToListAsync(ct);

        var designationOptions = await db.Designations
            .AsNoTracking()
            .Where(d => d.IsActive)
            .OrderBy(d => d.Name)
            .Select(d => new HierarchyDesignationOptionDto(
                d.Id,
                d.Name,
                d.DepartmentId,
                d.Department != null ? d.Department.Name : "",
                d.SubDepartment))
            .ToListAsync(ct);

        var onFloorRoles = await db.JobRoles
            .AsNoTracking()
            .Where(r => r.IsActive)
            .OrderBy(r => r.Name)
            .Select(r => new NamedMasterDto(r.Id, r.Code, r.Name))
            .ToListAsync(ct);

        var rbacRoles = await db.Roles
            .AsNoTracking()
            .Where(r => r.IsActive)
            .OrderBy(r => r.DisplayName)
            .ThenBy(r => r.Name)
            .Select(r => new RbacRoleOptionDto(r.Id, r.Name, r.DisplayName))
            .ToListAsync(ct);

        var designations = await db.Designations
            .AsNoTracking()
            .Where(d => d.IsActive)
            .Include(d => d.Department)
            .Include(d => d.JobRole)
            .Include(d => d.DefaultRole)
            .ToListAsync(ct);

        var maps = await db.OrgRoleMaps
            .AsNoTracking()
            .Include(m => m.OnFloorRole)
            .Include(m => m.RbacRole)
            .ToListAsync(ct);
        var mapByDesignation = maps
            .GroupBy(m => m.DesignationId)
            .ToDictionary(g => g.Key, g => g.First());

        var rows = designations
            .Select(d =>
            {
                mapByDesignation.TryGetValue(d.Id, out var map);
                var floor = map?.OnFloorRole is { IsActive: true, DeletedAtUtc: null }
                    ? map.OnFloorRole
                    : d.JobRole is { IsActive: true, DeletedAtUtc: null } ? d.JobRole : null;
                var rbac = map?.RbacRole is { IsActive: true, DeletedAtUtc: null }
                    ? map.RbacRole
                    : d.DefaultRole is { IsActive: true, DeletedAtUtc: null } ? d.DefaultRole : null;
                var subDepartment = !string.IsNullOrWhiteSpace(map?.SubDepartment)
                    ? map!.SubDepartment
                    : d.SubDepartment;
                return new DepartmentHierarchyRowDto(
                    d.Id,
                    d.DepartmentId,
                    d.Department?.Name ?? "",
                    d.Id,
                    d.Name,
                    subDepartment,
                    floor?.Id,
                    floor?.Name,
                    rbac?.Id,
                    rbac?.Name,
                    string.IsNullOrWhiteSpace(rbac?.DisplayName) ? rbac?.Name : rbac!.DisplayName);
            })
            .OrderBy(r => r.Department, StringComparer.OrdinalIgnoreCase)
            .ThenBy(r => r.Designation, StringComparer.OrdinalIgnoreCase)
            .ToList();

        return new DepartmentHierarchyBundleDto(rows, departments, designationOptions, onFloorRoles, rbacRoles);
    }

    private async Task<DepartmentHierarchyRowDto> LoadHierarchyRowAsync(Guid designationId, CancellationToken ct)
    {
        var bundle = await BuildHierarchyBundleAsync(ct);
        return bundle.Rows.FirstOrDefault(r => r.Id == designationId)
            ?? throw new NotFoundException("Department hierarchy row was not found.");
    }

    private async Task LinkHierarchyAsync(
        MstDesignation designation,
        MstDepartment department,
        MstRole onFloor,
        Role rbac,
        string subDepartment,
        CancellationToken ct)
    {
        designation.DepartmentId = department.Id;
        designation.JobRoleId = onFloor.Id;
        designation.DefaultRoleId = rbac.Id;
        designation.SubDepartment = subDepartment;

        var map = await db.OrgRoleMaps
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(m => m.DesignationId == designation.Id, ct);
        if (map is null)
        {
            map = new MstOrgRoleMap
            {
                DepartmentId = department.Id,
                DesignationId = designation.Id,
                OnFloorRoleId = onFloor.Id,
                RbacRoleId = rbac.Id,
                SubDepartment = subDepartment,
            };
            db.OrgRoleMaps.Add(map);
            return;
        }

        map.DeletedAtUtc = null;
        map.DepartmentId = department.Id;
        map.OnFloorRoleId = onFloor.Id;
        map.RbacRoleId = rbac.Id;
        map.SubDepartment = subDepartment;
    }

    private async Task<MstDepartment> ResolveDepartmentAsync(string name, CancellationToken ct)
    {
        var matches = await db.Departments
            .IgnoreQueryFilters()
            .Where(d => d.Name.ToLower() == name.ToLower())
            .ToListAsync(ct);
        var live = matches.FirstOrDefault(d => d.DeletedAtUtc == null && d.IsActive);
        if (live is not null)
            return live;

        if (matches.Count > 0)
        {
            var keeper = matches[0];
            foreach (var extra in matches.Skip(1))
                ParkDepartment(extra);
            keeper.DeletedAtUtc = null;
            keeper.IsActive = true;
            keeper.Name = name;
            return keeper;
        }

        var created = new MstDepartment
        {
            Code = await UniqueCodeAsync(
                Truncate(Slug(name), 50),
                code => db.Departments.IgnoreQueryFilters().AnyAsync(d => d.Code == code, ct),
                50),
            Name = name,
            IsActive = true,
        };
        db.Departments.Add(created);
        return created;
    }

    private async Task<MstRole> ResolveOnFloorRoleAsync(string name, CancellationToken ct)
    {
        var matches = await db.JobRoles
            .IgnoreQueryFilters()
            .Where(r => r.Name.ToLower() == name.ToLower())
            .ToListAsync(ct);
        var live = matches
            .Where(r => r.DeletedAtUtc == null && r.IsActive)
            .OrderBy(r => r.DesignationId.HasValue)
            .ThenBy(r => r.CreatedAtUtc)
            .FirstOrDefault();
        if (live is not null)
        {
            if (IsCanonicalOnFloor(live.Name))
                live.DesignationId = null;
            return live;
        }

        if (matches.Count > 0)
        {
            var keeper = matches
                .OrderBy(r => r.Name.StartsWith("retired_", StringComparison.OrdinalIgnoreCase))
                .ThenBy(r => r.CreatedAtUtc)
                .First();
            foreach (var extra in matches.Where(r => r.Id != keeper.Id))
                ParkOnFloor(extra);
            keeper.DeletedAtUtc = null;
            keeper.IsActive = true;
            keeper.Name = name;
            keeper.DesignationId = null;
            return keeper;
        }

        var created = new MstRole
        {
            Code = await UniqueCodeAsync(
                Truncate(OrgRoleMatrix.OnFloorCode(name), 80),
                code => db.JobRoles.IgnoreQueryFilters().AnyAsync(r => r.Code == code, ct)),
            Name = name,
            IsActive = true,
            DesignationId = null,
        };
        db.JobRoles.Add(created);
        return created;
    }

    private async Task<Role> RequireRbacAsync(Guid id, CancellationToken ct)
    {
        if (id == Guid.Empty)
            throw new ConflictException("Assigned RBAC Role is required.");

        var role = await db.Roles.FirstOrDefaultAsync(r => r.Id == id, ct)
            ?? throw new NotFoundException("Assigned RBAC Role was not found.");
        if (!role.IsActive)
            throw new ConflictException($"\"{RoleLabel(role)}\" is inactive. Choose an active access role.");
        return role;
    }

    private async Task RetireUnusedCustomOnFloorAsync(Guid? roleId, Guid exceptDesignationId, CancellationToken ct)
    {
        if (roleId is not Guid id) return;
        var role = await db.JobRoles.IgnoreQueryFilters().FirstOrDefaultAsync(r => r.Id == id, ct);
        if (role is null || role.DeletedAtUtc is not null) return;
        if (IsCanonicalOnFloor(role.Name)) return;

        var usedByDesignation = await db.Designations.AnyAsync(
            d => d.Id != exceptDesignationId && d.JobRoleId == id, ct);
        var usedByMap = await db.OrgRoleMaps.AnyAsync(
            m => m.DesignationId != exceptDesignationId && m.OnFloorRoleId == id, ct);
        var usedByEmployee = await db.Employees.AnyAsync(e => e.JobRoleId == id, ct);
        if (usedByDesignation || usedByMap || usedByEmployee) return;

        ParkOnFloor(role);
        role.IsActive = false;
        role.DeletedAtUtc = DateTime.UtcNow;
    }

    private async Task<NamedMasterDto> SaveEmailDomainAsync(Guid? id, string rawName, CancellationToken ct)
    {
        var domain = NormalizeDomain(rawName);
        var domainQuery = db.EmailDomains
            .IgnoreQueryFilters()
            .Where(d => d.DomainName.ToLower() == domain);
        if (id is Guid domainId)
            domainQuery = domainQuery.Where(d => d.Id != domainId);
        var matches = await domainQuery.ToListAsync(ct);

        if (id is Guid existingId)
        {
            var row = await db.EmailDomains.FirstOrDefaultAsync(d => d.Id == existingId, ct)
                ?? throw new NotFoundException("Work email domain was not found.");
            if (matches.Any(d => d.DeletedAtUtc == null && d.IsActive))
                throw new ConflictException($"\"{domain}\" already exists.");
            foreach (var extra in matches.Where(d => d.DeletedAtUtc != null || !d.IsActive))
                ParkEmail(extra);
            row.DomainName = domain;
            row.DisplayName = domain;
            row.IsActive = true;
            await db.SaveChangesAsync(ct);
            return MapEmail(row);
        }

        if (matches.Any(d => d.DeletedAtUtc == null && d.IsActive))
            throw new ConflictException($"\"{domain}\" already exists.");

        if (matches.Count > 0)
        {
            var keeper = matches[0];
            foreach (var extra in matches.Skip(1))
                ParkEmail(extra);
            keeper.DeletedAtUtc = null;
            keeper.IsActive = true;
            keeper.DomainName = domain;
            keeper.DisplayName = domain;
            await db.SaveChangesAsync(ct);
            return MapEmail(keeper);
        }

        var sort = await db.EmailDomains.IgnoreQueryFilters().MaxAsync(d => (int?)d.SortOrder, ct) ?? 0;
        var created = new MstEmailDomain
        {
            Code = await UniqueCodeAsync(
                Truncate(Slug(domain), 80),
                code => db.EmailDomains.IgnoreQueryFilters().AnyAsync(d => d.Code == code, ct)),
            DomainName = domain,
            DisplayName = domain,
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.EmailDomains.Add(created);
        await db.SaveChangesAsync(ct);
        return MapEmail(created);
    }

    private async Task<NamedMasterDto> SaveBusinessUnitAsync(Guid? id, string rawName, CancellationToken ct)
    {
        var name = RequireName(rawName, "Business unit", 150);
        return await SaveSimpleNameAsync(
            id,
            name,
            "Business unit",
            () => db.BusinessUnits.IgnoreQueryFilters().Where(b => b.Name.ToLower() == name.ToLower()).ToListAsync(ct),
            async existingId => await db.BusinessUnits.FirstOrDefaultAsync(b => b.Id == existingId, ct),
            (row, value) => row.Name = value,
            row => row.IsActive,
            row => row.IsActive = true,
            row => ParkCodeName(row, row.Name, value => row.Name = value, row.Code, value => row.Code = value, 150, 80),
            async () =>
            {
                var sort = await db.BusinessUnits.IgnoreQueryFilters().MaxAsync(b => (int?)b.SortOrder, ct) ?? 0;
                var created = new MstBusinessUnit
                {
                    Code = await UniqueCodeAsync(
                        Truncate(Slug(name), 80),
                        code => db.BusinessUnits.IgnoreQueryFilters().AnyAsync(b => b.Code == code, ct)),
                    Name = name,
                    IsActive = true,
                    SortOrder = sort + 1,
                };
                db.BusinessUnits.Add(created);
                return created;
            },
            row => new NamedMasterDto(row.Id, row.Code, row.Name),
            ct);
    }

    private async Task<NamedMasterDto> SaveWorkLocationAsync(Guid? id, string rawName, CancellationToken ct)
    {
        var name = RequireName(rawName, "Work location", 150);
        return await SaveSimpleNameAsync(
            id,
            name,
            "Work location",
            () => db.WorkLocations.IgnoreQueryFilters().Where(w => w.Name.ToLower() == name.ToLower()).ToListAsync(ct),
            async existingId => await db.WorkLocations.FirstOrDefaultAsync(w => w.Id == existingId, ct),
            (row, value) => row.Name = value,
            row => row.IsActive,
            row => row.IsActive = true,
            row => ParkCodeName(row, row.Name, value => row.Name = value, row.Code, value => row.Code = value, 150, 80),
            async () =>
            {
                var sort = await db.WorkLocations.IgnoreQueryFilters().MaxAsync(w => (int?)w.SortOrder, ct) ?? 0;
                var created = new MstWorkLocation
                {
                    Code = await UniqueCodeAsync(
                        Truncate(Slug(name), 80),
                        code => db.WorkLocations.IgnoreQueryFilters().AnyAsync(w => w.Code == code, ct)),
                    Name = name,
                    IsActive = true,
                    SortOrder = sort + 1,
                };
                db.WorkLocations.Add(created);
                return created;
            },
            row => new NamedMasterDto(row.Id, row.Code, row.Name),
            ct);
    }

    private async Task<NamedMasterDto> SaveGraduationAsync(Guid? id, string rawName, CancellationToken ct)
    {
        var name = RequireName(rawName, "Graduation degree", 200);
        return await SaveSimpleNameAsync(
            id,
            name,
            "Graduation degree",
            () => db.GraduationDegrees.IgnoreQueryFilters().Where(g => g.Name.ToLower() == name.ToLower()).ToListAsync(ct),
            async existingId => await db.GraduationDegrees.FirstOrDefaultAsync(g => g.Id == existingId, ct),
            (row, value) => row.Name = value,
            row => row.IsActive,
            row => row.IsActive = true,
            row => ParkCodeName(row, row.Name, value => row.Name = value, row.Code, value => row.Code = value, 200, 100),
            async () =>
            {
                var created = new MstGraduationDegree
                {
                    Code = await UniqueCodeAsync(
                        Truncate(Slug(name), 100),
                        code => db.GraduationDegrees.IgnoreQueryFilters().AnyAsync(g => g.Code == code, ct),
                        100),
                    Name = name,
                    IsActive = true,
                };
                db.GraduationDegrees.Add(created);
                return created;
            },
            row => new NamedMasterDto(row.Id, row.Code, row.Name),
            ct);
    }

    private async Task<NamedMasterDto> SavePostGraduationAsync(Guid? id, string rawName, CancellationToken ct)
    {
        var name = RequireName(rawName, "Post graduation degree", 200);
        return await SaveSimpleNameAsync(
            id,
            name,
            "Post graduation degree",
            () => db.PostGraduationDegrees.IgnoreQueryFilters().Where(p => p.Name.ToLower() == name.ToLower()).ToListAsync(ct),
            async existingId => await db.PostGraduationDegrees.FirstOrDefaultAsync(p => p.Id == existingId, ct),
            (row, value) => row.Name = value,
            row => row.IsActive,
            row => row.IsActive = true,
            row => ParkCodeName(row, row.Name, value => row.Name = value, row.Code, value => row.Code = value, 200, 100),
            async () =>
            {
                var created = new MstPostGraduationDegree
                {
                    Code = await UniqueCodeAsync(
                        Truncate(Slug(name), 100),
                        code => db.PostGraduationDegrees.IgnoreQueryFilters().AnyAsync(p => p.Code == code, ct),
                        100),
                    Name = name,
                    IsActive = true,
                };
                db.PostGraduationDegrees.Add(created);
                return created;
            },
            row => new NamedMasterDto(row.Id, row.Code, row.Name),
            ct);
    }

    private async Task<NamedMasterDto> SaveCertificationAsync(Guid? id, string rawName, CancellationToken ct)
    {
        var name = RequireName(rawName, "Certification", 200);
        return await SaveSimpleNameAsync(
            id,
            name,
            "Certification",
            () => db.Certifications.IgnoreQueryFilters().Where(c => c.Name.ToLower() == name.ToLower()).ToListAsync(ct),
            async existingId => await db.Certifications.FirstOrDefaultAsync(c => c.Id == existingId, ct),
            (row, value) => row.Name = value,
            row => row.IsActive,
            row => row.IsActive = true,
            row => ParkCodeName(row, row.Name, value => row.Name = value, row.Code, value => row.Code = value, 200, 100),
            async () =>
            {
                var created = new MstCertification
                {
                    Code = await UniqueCodeAsync(
                        Truncate(Slug(name), 100),
                        code => db.Certifications.IgnoreQueryFilters().AnyAsync(c => c.Code == code, ct),
                        100),
                    Name = name,
                    IsActive = true,
                };
                db.Certifications.Add(created);
                return created;
            },
            row => new NamedMasterDto(row.Id, row.Code, row.Name),
            ct);
    }

    private async Task<MstAddressCity> SaveAddressCityAsync(Guid? id, string rawName, string? rawLine, CancellationToken ct)
    {
        var name = RequireName(rawName, "City", 200);
        var line = string.IsNullOrWhiteSpace(rawLine) ? null : rawLine.Trim();
        if (line is { Length: > 80 })
            throw new ConflictException("Line must be 80 characters or fewer.");

        var cityQuery = db.AddressCities
            .IgnoreQueryFilters()
            .Where(c => c.Name.ToLower() == name.ToLower());
        if (id is Guid cityId)
            cityQuery = cityQuery.Where(c => c.Id != cityId);
        var matches = await cityQuery.ToListAsync(ct);

        if (id is Guid existingId)
        {
            var row = await db.AddressCities.FirstOrDefaultAsync(c => c.Id == existingId, ct)
                ?? throw new NotFoundException("Address city was not found.");
            if (matches.Any(c => c.DeletedAtUtc == null && c.IsActive))
                throw new ConflictException($"\"{name}\" already exists.");
            foreach (var extra in matches.Where(c => c.DeletedAtUtc != null || !c.IsActive))
                ParkAddressCity(extra);
            row.Name = name;
            row.Line = line;
            row.IsActive = true;
            await db.SaveChangesAsync(ct);
            return row;
        }

        if (matches.Any(c => c.DeletedAtUtc == null && c.IsActive))
            throw new ConflictException($"\"{name}\" already exists.");

        if (matches.Count > 0)
        {
            var keeper = matches[0];
            foreach (var extra in matches.Skip(1))
                ParkAddressCity(extra);
            keeper.DeletedAtUtc = null;
            keeper.IsActive = true;
            keeper.Name = name;
            keeper.Line = line;
            await db.SaveChangesAsync(ct);
            return keeper;
        }

        var sort = await db.AddressCities.IgnoreQueryFilters().MaxAsync(c => (int?)c.SortOrder, ct) ?? 0;
        var created = new MstAddressCity
        {
            Code = await UniqueCodeAsync(
                Truncate(Slug(name), 80),
                code => db.AddressCities.IgnoreQueryFilters().AnyAsync(c => c.Code == code, ct)),
            Name = name,
            Line = line,
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.AddressCities.Add(created);
        await db.SaveChangesAsync(ct);
        return created;
    }

    private async Task<NamedMasterDto> SaveSimpleNameAsync<T>(
        Guid? id,
        string name,
        string label,
        Func<Task<List<T>>> loadMatches,
        Func<Guid, Task<T?>> loadById,
        Action<T, string> writeName,
        Func<T, bool> readActive,
        Action<T> markActive,
        Action<T> park,
        Func<Task<T>> create,
        Func<T, NamedMasterDto> map,
        CancellationToken ct)
        where T : BaseEntity
    {
        ct.ThrowIfCancellationRequested();
        var matches = (await loadMatches())
            .Where(item => id is null || item.Id != id.Value)
            .ToList();
        if (id is Guid existingId)
        {
            var row = await loadById(existingId) ?? throw new NotFoundException($"{label} was not found.");
            if (matches.Any(item => item.DeletedAtUtc == null && readActive(item)))
                throw new ConflictException($"\"{name}\" already exists.");
            foreach (var extra in matches.Where(item => item.DeletedAtUtc != null || !readActive(item)))
                park(extra);
            writeName(row, name);
            markActive(row);
            await db.SaveChangesAsync(ct);
            return map(row);
        }

        if (matches.Any(item => item.DeletedAtUtc == null && readActive(item)))
            throw new ConflictException($"\"{name}\" already exists.");

        if (matches.Count > 0)
        {
            var keeper = matches[0];
            foreach (var extra in matches.Skip(1))
                park(extra);
            keeper.DeletedAtUtc = null;
            markActive(keeper);
            writeName(keeper, name);
            await db.SaveChangesAsync(ct);
            return map(keeper);
        }

        var created = await create();
        await db.SaveChangesAsync(ct);
        return map(created);
    }

    private async Task<IReadOnlyList<NamedMasterDto>> ListEmailDomainsAsync(CancellationToken ct) =>
        await db.EmailDomains
            .AsNoTracking()
            .Where(d => d.IsActive)
            .OrderBy(d => d.SortOrder)
            .ThenBy(d => d.DomainName)
            .Select(d => new NamedMasterDto(d.Id, d.DomainName, d.DomainName))
            .ToListAsync(ct);

    private async Task<IReadOnlyList<NamedMasterDto>> ListBusinessUnitsAsync(CancellationToken ct) =>
        await db.BusinessUnits
            .AsNoTracking()
            .Where(b => b.IsActive)
            .OrderBy(b => b.SortOrder)
            .ThenBy(b => b.Name)
            .Select(b => new NamedMasterDto(b.Id, b.Code, b.Name))
            .ToListAsync(ct);

    private async Task<IReadOnlyList<NamedMasterDto>> ListWorkLocationsAsync(CancellationToken ct) =>
        await db.WorkLocations
            .AsNoTracking()
            .Where(w => w.IsActive)
            .OrderBy(w => w.SortOrder)
            .ThenBy(w => w.Name)
            .Select(w => new NamedMasterDto(w.Id, w.Code, w.Name))
            .ToListAsync(ct);

    private async Task<IReadOnlyList<NamedMasterDto>> ListGraduationDegreesAsync(CancellationToken ct) =>
        await db.GraduationDegrees
            .AsNoTracking()
            .Where(g => g.IsActive)
            .OrderBy(g => g.Name)
            .Select(g => new NamedMasterDto(g.Id, g.Code, g.Name))
            .ToListAsync(ct);

    private async Task<IReadOnlyList<NamedMasterDto>> ListPostGraduationDegreesAsync(CancellationToken ct) =>
        await db.PostGraduationDegrees
            .AsNoTracking()
            .Where(p => p.IsActive)
            .OrderBy(p => p.Name)
            .Select(p => new NamedMasterDto(p.Id, p.Code, p.Name))
            .ToListAsync(ct);

    private async Task<IReadOnlyList<NamedMasterDto>> ListCertificationsAsync(CancellationToken ct) =>
        await db.Certifications
            .AsNoTracking()
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .Select(c => new NamedMasterDto(c.Id, c.Code, c.Name))
            .ToListAsync(ct);

    private async Task<IReadOnlyList<AddressCityDto>> ListAddressCitiesAsync(CancellationToken ct) =>
        await db.AddressCities
            .AsNoTracking()
            .Where(c => c.IsActive)
            .OrderBy(c => c.SortOrder)
            .ThenBy(c => c.Name)
            .Select(c => new AddressCityDto(c.Id, c.Code, c.Name, c.Line, c.SortOrder))
            .ToListAsync(ct);

    private static NamedMasterDto MapEmail(MstEmailDomain row) =>
        new(row.Id, row.DomainName, row.DomainName);

    private static AddressCityDto MapCity(MstAddressCity row) =>
        new(row.Id, row.Code, row.Name, row.Line, row.SortOrder);

    private static string RoleLabel(Role role) =>
        string.IsNullOrWhiteSpace(role.DisplayName) ? role.Name : role.DisplayName;

    private static bool IsCanonicalOnFloor(string name) =>
        OrgRoleMatrix.OnFloorRoles.Contains(name.Trim(), StringComparer.OrdinalIgnoreCase);

    private static string NormalizeDomain(string raw)
    {
        var domain = raw.Trim().TrimStart('@').Trim().ToLowerInvariant();
        if (domain.Length == 0)
            throw new ConflictException("Domain is required.");
        if (domain.Length > 150)
            throw new ConflictException("Domain must be 150 characters or fewer.");
        if (!DomainPattern.IsMatch(domain))
            throw new ConflictException("Enter a domain such as talakunchi.com.");
        return domain;
    }

    private static string RequireName(string? name, string label, int max)
    {
        var trimmed = (name ?? string.Empty).Trim();
        if (trimmed.Length == 0)
            throw new ConflictException($"{label} is required.");
        if (trimmed.Length > max)
            throw new ConflictException($"{label} must be {max} characters or fewer.");
        return trimmed;
    }

    private static void ParkDepartment(MstDepartment row)
    {
        var token = row.Id.ToString("N")[..8];
        row.Name = Truncate($"retired {token} {row.Name}", 150);
        row.Code = Truncate($"x{token}", 50);
        row.IsActive = false;
    }

    private static void ParkDesignation(MstDesignation row)
    {
        var token = row.Id.ToString("N")[..8];
        row.Name = Truncate($"retired {token} {row.Name}", 150);
        row.Code = Truncate($"x{token}", 80);
        row.IsActive = false;
    }

    private static void ParkOnFloor(MstRole row)
    {
        var token = row.Id.ToString("N")[..8];
        row.Name = Truncate($"retired_{token}_{row.Name}", 150);
        row.Code = Truncate($"retired_{token}", 80);
        row.IsActive = false;
    }

    private static void ParkEmail(MstEmailDomain row)
    {
        var token = row.Id.ToString("N")[..8];
        row.DomainName = Truncate($"retired-{token}-{row.DomainName}", 150);
        row.DisplayName = row.DomainName;
        row.Code = Truncate($"x{token}", 80);
        row.IsActive = false;
    }

    private static void ParkAddressCity(MstAddressCity row)
    {
        var token = row.Id.ToString("N")[..8];
        row.Name = Truncate($"retired {token} {row.Name}", 200);
        row.Code = Truncate($"x{token}", 80);
        row.IsActive = false;
    }

    private static void ParkCodeName(
        BaseEntity row,
        string name,
        Action<string> writeName,
        string code,
        Action<string> writeCode,
        int nameMax,
        int codeMax)
    {
        var token = row.Id.ToString("N")[..8];
        writeName(Truncate($"retired {token} {name}", nameMax));
        writeCode(Truncate($"x{token}{code}", codeMax));
    }

    private static string Slug(string value)
    {
        var chars = value.Trim().ToLowerInvariant()
            .Select(c => char.IsLetterOrDigit(c) ? c : '_')
            .ToArray();
        var slug = new string(chars);
        while (slug.Contains("__", StringComparison.Ordinal))
            slug = slug.Replace("__", "_", StringComparison.Ordinal);
        slug = slug.Trim('_');
        return string.IsNullOrEmpty(slug) ? "item" : slug;
    }

    private static string Truncate(string value, int max) =>
        value.Length <= max ? value : value[..max].Trim('_', '-', ' ');

    private static async Task<string> UniqueCodeAsync(
        string baseCode,
        Func<string, Task<bool>> exists,
        int maxLength = 80)
    {
        var seed = string.IsNullOrWhiteSpace(baseCode) ? "item" : Truncate(baseCode, maxLength);
        var code = seed;
        var n = 2;
        while (await exists(code))
        {
            var suffix = $"_{n}";
            code = Truncate(seed, Math.Max(1, maxLength - suffix.Length)) + suffix;
            n++;
        }

        return code;
    }
}
