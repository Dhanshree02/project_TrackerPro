using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Projects.Models;

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

    public async Task<ServiceDepartmentDto> CreateServiceDepartmentAsync(
        CreateServiceDepartmentRequest request,
        CancellationToken ct = default)
    {
        var trimmedName = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(trimmedName))
        {
            throw new ArgumentException("Department name is required.");
        }

        var exists = await db.ServiceDepartments
            .AnyAsync(d => d.Name.ToLower() == trimmedName.ToLower(), ct);
        if (exists)
        {
            throw new InvalidOperationException($"Department '{trimmedName}' already exists.");
        }

        Guid groupId;
        if (request.GroupId.HasValue && request.GroupId.Value != Guid.Empty)
        {
            groupId = request.GroupId.Value;
        }
        else
        {
            var targetGroupName = string.IsNullOrWhiteSpace(request.Group) ? "Scope" : request.Group.Trim();
            var matchedGroup = await db.ServiceGroups
                .FirstOrDefaultAsync(g => g.Name.ToLower() == targetGroupName.ToLower() || g.Code.ToLower() == targetGroupName.ToLower(), ct)
                ?? await db.ServiceGroups.OrderBy(g => g.SortOrder).FirstOrDefaultAsync(ct);

            if (matchedGroup is null)
            {
                matchedGroup = new MstServiceGroup
                {
                    Id = Guid.NewGuid(),
                    Code = targetGroupName.ToUpperInvariant(),
                    Name = targetGroupName,
                    SortOrder = 1,
                    IsActive = true
                };
                db.ServiceGroups.Add(matchedGroup);
                await db.SaveChangesAsync(ct);
            }
            groupId = matchedGroup.Id;
        }

        var code = !string.IsNullOrWhiteSpace(request.Code)
            ? request.Code.Trim().ToUpperInvariant()
            : Regex.Replace(trimmedName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');

        if (string.IsNullOrEmpty(code))
        {
            code = "DEPT";
        }

        var baseCode = code.Length > 70 ? code[..70] : code;
        code = baseCode;
        var codeCounter = 1;
        while (await db.ServiceDepartments.AnyAsync(d => d.Code == code, ct))
        {
            code = $"{baseCode}_{codeCounter++}";
        }

        var maxSort = await db.ServiceDepartments
            .Where(d => d.GroupId == groupId)
            .MaxAsync(d => (int?)d.SortOrder, ct) ?? 0;

        var entity = new MstServiceDepartment
        {
            Id = Guid.NewGuid(),
            GroupId = groupId,
            Code = code,
            Name = trimmedName,
            SortOrder = maxSort + 1,
            IsActive = true
        };

        db.ServiceDepartments.Add(entity);
        await db.SaveChangesAsync(ct);

        var group = await db.ServiceGroups.FindAsync([groupId], ct);
        return new ServiceDepartmentDto(
            entity.Id,
            entity.Code,
            entity.Name,
            entity.GroupId,
            group?.Name ?? string.Empty,
            entity.SortOrder);
    }

    public async Task<ServiceSubDepartmentDto> CreateServiceSubDepartmentAsync(
        CreateServiceSubDepartmentRequest request,
        CancellationToken ct = default)
    {
        var trimmedName = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(trimmedName))
        {
            throw new ArgumentException("Sub-department name is required.");
        }

        MstServiceDepartment? dept = null;
        if (request.DepartmentId.HasValue && request.DepartmentId.Value != Guid.Empty)
        {
            dept = await db.ServiceDepartments.FirstOrDefaultAsync(d => d.Id == request.DepartmentId.Value, ct);
        }
        else if (!string.IsNullOrWhiteSpace(request.DepartmentName))
        {
            var deptName = request.DepartmentName.Trim().ToLower();
            dept = await db.ServiceDepartments.FirstOrDefaultAsync(d => d.Name.ToLower() == deptName, ct);
        }

        if (dept is null)
        {
            throw new KeyNotFoundException("Parent department not found.");
        }

        var exists = await db.ServiceSubDepartments
            .AnyAsync(s => s.DepartmentId == dept.Id && s.Name.ToLower() == trimmedName.ToLower(), ct);
        if (exists)
        {
            throw new InvalidOperationException($"Sub-department '{trimmedName}' already exists under {dept.Name}.");
        }

        var code = !string.IsNullOrWhiteSpace(request.Code)
            ? request.Code.Trim().ToUpperInvariant()
            : "SUB_" + Regex.Replace(trimmedName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');

        var baseCode = code.Length > 100 ? code[..100] : code;
        code = baseCode;
        var codeCounter = 1;
        while (await db.ServiceSubDepartments.AnyAsync(s => s.Code == code, ct))
        {
            code = $"{baseCode}_{codeCounter++}";
        }

        var maxSort = await db.ServiceSubDepartments
            .Where(s => s.DepartmentId == dept.Id)
            .MaxAsync(s => (int?)s.SortOrder, ct) ?? 0;

        var entity = new MstServiceSubDepartment
        {
            Id = Guid.NewGuid(),
            DepartmentId = dept.Id,
            Code = code,
            Name = trimmedName,
            SortOrder = maxSort + 1,
            IsActive = true
        };

        db.ServiceSubDepartments.Add(entity);
        await db.SaveChangesAsync(ct);

        return new ServiceSubDepartmentDto(
            entity.Id,
            entity.Code,
            entity.Name,
            entity.DepartmentId,
            dept.Name,
            entity.SortOrder);
    }

    public async Task<ServiceCatalogOptionDto> CreateServiceCatalogAsync(
        CreateServiceCatalogRequest request,
        CancellationToken ct = default)
    {
        var trimmedName = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(trimmedName))
        {
            throw new ArgumentException("Service name is required.");
        }

        MstServiceSubDepartment? subDept = null;
        if (request.SubDepartmentId.HasValue && request.SubDepartmentId.Value != Guid.Empty)
        {
            subDept = await db.ServiceSubDepartments
                .Include(s => s.Department)
                .FirstOrDefaultAsync(s => s.Id == request.SubDepartmentId.Value, ct);
        }
        else if (!string.IsNullOrWhiteSpace(request.SubDepartmentName))
        {
            var subName = request.SubDepartmentName.Trim().ToLower();
            var query = db.ServiceSubDepartments.Include(s => s.Department).Where(s => s.Name.ToLower() == subName);
            if (!string.IsNullOrWhiteSpace(request.DepartmentName))
            {
                var deptName = request.DepartmentName.Trim().ToLower();
                query = query.Where(s => s.Department != null && s.Department.Name.ToLower() == deptName);
            }
            subDept = await query.FirstOrDefaultAsync(ct);
        }

        // If sub-department not found, but department is provided, auto-create sub-department
        if (subDept is null && !string.IsNullOrWhiteSpace(request.DepartmentName))
        {
            var deptName = request.DepartmentName.Trim().ToLower();
            var dept = await db.ServiceDepartments.FirstOrDefaultAsync(d => d.Name.ToLower() == deptName, ct);
            if (dept is not null)
            {
                var newSubName = !string.IsNullOrWhiteSpace(request.SubDepartmentName)
                    ? request.SubDepartmentName.Trim()
                    : dept.Name + " Services";

                var subCode = "SUB_" + Regex.Replace(newSubName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');
                if (subCode.Length > 100) subCode = subCode[..100];

                var subCounter = 1;
                var uniqueSubCode = subCode;
                while (await db.ServiceSubDepartments.AnyAsync(s => s.Code == uniqueSubCode, ct))
                {
                    uniqueSubCode = $"{subCode}_{subCounter++}";
                }

                subDept = new MstServiceSubDepartment
                {
                    Id = Guid.NewGuid(),
                    DepartmentId = dept.Id,
                    Code = uniqueSubCode,
                    Name = newSubName,
                    SortOrder = 1,
                    IsActive = true
                };
                db.ServiceSubDepartments.Add(subDept);
                await db.SaveChangesAsync(ct);
                subDept.Department = dept;
            }
        }

        if (subDept is null)
        {
            throw new KeyNotFoundException("Sub-department or parent department not found.");
        }

        var exists = await db.ServiceCatalogs
            .AnyAsync(c => c.SubDepartmentId == subDept.Id && c.Name.ToLower() == trimmedName.ToLower(), ct);
        if (exists)
        {
            throw new InvalidOperationException($"Service '{trimmedName}' already exists under {subDept.Name}.");
        }

        var code = !string.IsNullOrWhiteSpace(request.Code)
            ? request.Code.Trim().ToUpperInvariant()
            : "SVC_" + Regex.Replace(trimmedName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');

        var baseCode = code.Length > 40 ? code[..40] : code;
        code = baseCode;
        var codeCounter = 1;
        while (await db.ServiceCatalogs.AnyAsync(c => c.Code == code, ct))
        {
            code = $"{baseCode}_{codeCounter++}";
        }

        var maxSort = await db.ServiceCatalogs
            .Where(c => c.SubDepartmentId == subDept.Id)
            .MaxAsync(c => (int?)c.SortOrder, ct) ?? 0;

        var entity = new MstServiceCatalog
        {
            Id = Guid.NewGuid(),
            SubDepartmentId = subDept.Id,
            Code = code,
            Name = trimmedName,
            DefaultTools = request.DefaultTools?.Trim(),
            DefaultUnitPrice = request.DefaultUnitPrice,
            DefaultDurationDays = request.DefaultDurationDays,
            Description = request.Description?.Trim(),
            SortOrder = maxSort + 1,
            IsActive = true
        };

        db.ServiceCatalogs.Add(entity);
        await db.SaveChangesAsync(ct);

        return new ServiceCatalogOptionDto(
            entity.Id,
            entity.Code,
            entity.Name,
            entity.SubDepartmentId,
            subDept.Name,
            entity.DefaultTools,
            entity.DefaultUnitPrice,
            entity.DefaultDurationDays,
            entity.Description,
            entity.SortOrder);
    }
}

