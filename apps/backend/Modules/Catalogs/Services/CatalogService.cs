using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Catalogs.Services;

public sealed class CatalogService(AppDbContext db) : ICatalogService
{
    public async Task<IReadOnlyList<CatalogOptionDto>> GetCountriesAsync(CancellationToken ct = default)
    {
        return await db.Countries
            .Where(c => c.IsActive && c.DeletedAtUtc == null)
            .OrderBy(c => c.Name)
            .Select(c => new CatalogOptionDto(c.Id, c.Code, c.Name, c.PhoneCode, c.PhoneDigits))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetNationalitiesAsync(CancellationToken ct = default)
    {
        return await db.Nationalities
            .Where(n => n.IsActive && n.DeletedAtUtc == null)
            .OrderBy(n => n.Name)
            .Select(n => new CatalogOptionDto(n.Id, n.Code, n.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CityCatalogOptionDto>> GetCitiesAsync(
        Guid? countryId,
        CancellationToken ct = default)
    {
        var query = db.Cities.Include(c => c.Country).Where(c => c.IsActive && c.DeletedAtUtc == null);
        if (countryId is not null)
        {
            query = query.Where(c => c.CountryId == countryId);
        }

        return await query
            .OrderBy(c => c.Name)
            .Select(c => new CityCatalogOptionDto(c.Id, c.Code, c.Name, c.CountryId, c.Country != null ? c.Country.Name : null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetIndustriesAsync(CancellationToken ct = default)
    {
        return await db.Industries
            .Where(i => i.IsActive && i.DeletedAtUtc == null)
            .OrderBy(i => i.Name)
            .Select(i => new CatalogOptionDto(i.Id, i.Code, i.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetContactDesignationsAsync(CancellationToken ct = default)
    {
        return await db.ContactDesignations
            .Where(d => d.IsActive && d.DeletedAtUtc == null)
            .OrderBy(d => d.SortOrder)
            .ThenBy(d => d.Name)
            .Select(d => new CatalogOptionDto(d.Id, d.Code, d.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetContactTypesAsync(CancellationToken ct = default)
    {
        return await db.ContactTypes
            .Where(t => t.IsActive && t.DeletedAtUtc == null)
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

        var existingDept = await db.ServiceDepartments.IgnoreQueryFilters()
            .FirstOrDefaultAsync(d => d.GroupId == groupId && d.Name.ToLower() == trimmedName.ToLower(), ct);

        if (existingDept is not null)
        {
            if (existingDept.DeletedAtUtc != null || !existingDept.IsActive)
            {
                existingDept.DeletedAtUtc = null;
                existingDept.IsActive = true;
                existingDept.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }
            var grp = await db.ServiceGroups.FindAsync([groupId], ct);
            return new ServiceDepartmentDto(
                existingDept.Id,
                existingDept.Code,
                existingDept.Name,
                existingDept.GroupId,
                grp?.Name ?? string.Empty,
                existingDept.SortOrder);
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
        while (await db.ServiceDepartments.IgnoreQueryFilters().AnyAsync(d => d.Code == code, ct))
        {
            code = $"{baseCode}_{codeCounter++}";
        }

        var maxSort = await db.ServiceDepartments.IgnoreQueryFilters()
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

        var existingSub = await db.ServiceSubDepartments.IgnoreQueryFilters()
            .FirstOrDefaultAsync(s => s.DepartmentId == dept.Id && s.Name.ToLower() == trimmedName.ToLower(), ct);

        if (existingSub is not null)
        {
            if (existingSub.DeletedAtUtc != null || !existingSub.IsActive)
            {
                existingSub.DeletedAtUtc = null;
                existingSub.IsActive = true;
                existingSub.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                return new ServiceSubDepartmentDto(
                    existingSub.Id,
                    existingSub.Code,
                    existingSub.Name,
                    existingSub.DepartmentId,
                    dept.Name,
                    existingSub.SortOrder);
            }
            throw new InvalidOperationException($"Sub-department '{trimmedName}' already exists under {dept.Name}.");
        }

        var code = !string.IsNullOrWhiteSpace(request.Code)
            ? request.Code.Trim().ToUpperInvariant()
            : "SUB_" + Regex.Replace(trimmedName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');

        var baseCode = code.Length > 100 ? code[..100] : code;
        code = baseCode;
        var codeCounter = 1;
        while (await db.ServiceSubDepartments.IgnoreQueryFilters().AnyAsync(s => s.Code == code, ct))
        {
            code = $"{baseCode}_{codeCounter++}";
        }

        var maxSort = await db.ServiceSubDepartments.IgnoreQueryFilters()
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

        var existingSvc = await db.ServiceCatalogs.IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => c.SubDepartmentId == subDept.Id && c.Name.ToLower() == trimmedName.ToLower(), ct);

        if (existingSvc is not null)
        {
            if (existingSvc.DeletedAtUtc != null || !existingSvc.IsActive)
            {
                existingSvc.DeletedAtUtc = null;
                existingSvc.IsActive = true;
                if (!string.IsNullOrWhiteSpace(request.DefaultTools)) existingSvc.DefaultTools = request.DefaultTools.Trim();
                if (request.DefaultUnitPrice.HasValue) existingSvc.DefaultUnitPrice = request.DefaultUnitPrice;
                if (request.DefaultDurationDays.HasValue) existingSvc.DefaultDurationDays = request.DefaultDurationDays;
                if (!string.IsNullOrWhiteSpace(request.Description)) existingSvc.Description = request.Description.Trim();
                existingSvc.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                return new ServiceCatalogOptionDto(
                    existingSvc.Id,
                    existingSvc.Code,
                    existingSvc.Name,
                    existingSvc.SubDepartmentId,
                    subDept.Name,
                    existingSvc.DefaultTools,
                    existingSvc.DefaultUnitPrice,
                    existingSvc.DefaultDurationDays,
                    existingSvc.Description,
                    existingSvc.SortOrder);
            }
            throw new InvalidOperationException($"Service '{trimmedName}' already exists under {subDept.Name}.");
        }

        var code = !string.IsNullOrWhiteSpace(request.Code)
            ? request.Code.Trim().ToUpperInvariant()
            : "SVC_" + Regex.Replace(trimmedName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');

        var baseCode = code.Length > 40 ? code[..40] : code;
        code = baseCode;
        var codeCounter = 1;
        while (await db.ServiceCatalogs.IgnoreQueryFilters().AnyAsync(c => c.Code == code, ct))
        {
            code = $"{baseCode}_{codeCounter++}";
        }

        var maxSort = await db.ServiceCatalogs.IgnoreQueryFilters()
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

    public async Task<ServiceGroupDto> CreateServiceGroupAsync(
        CreateServiceGroupRequest request,
        CancellationToken ct = default)
    {
        var trimmedName = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(trimmedName))
        {
            throw new ArgumentException("Contract Type / Service Group name is required.");
        }

        var existing = await db.ServiceGroups.IgnoreQueryFilters()
            .FirstOrDefaultAsync(g => g.Name.ToLower() == trimmedName.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc != null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }
            return new ServiceGroupDto(existing.Id, existing.Code, existing.Name, existing.SortOrder);
        }

        var code = !string.IsNullOrWhiteSpace(request.Code)
            ? request.Code.Trim().ToUpperInvariant()
            : Regex.Replace(trimmedName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');

        if (string.IsNullOrEmpty(code)) code = "GRP";
        if (code.Length > 50) code = code[..50];

        var codeCounter = 1;
        var uniqueCode = code;
        while (await db.ServiceGroups.IgnoreQueryFilters().AnyAsync(g => g.Code == uniqueCode, ct))
        {
            uniqueCode = $"{code}_{codeCounter++}";
        }

        var maxSort = await db.ServiceGroups.IgnoreQueryFilters().MaxAsync(g => (int?)g.SortOrder, ct) ?? 0;

        var entity = new MstServiceGroup
        {
            Id = Guid.NewGuid(),
            Code = uniqueCode,
            Name = trimmedName,
            SortOrder = maxSort + 1,
            IsActive = true
        };

        db.ServiceGroups.Add(entity);
        await db.SaveChangesAsync(ct);

        return new ServiceGroupDto(entity.Id, entity.Code, entity.Name, entity.SortOrder);
    }

    public async Task<IReadOnlyList<ProjectMasterDto>> GetProjectMastersAsync(CancellationToken ct = default)
    {
        var services = await db.ServiceCatalogs
            .Include(c => c.SubDepartment)
                .ThenInclude(s => s!.Department)
                    .ThenInclude(d => d!.Group)
            .Where(c => c.IsActive)
            .OrderBy(c => c.SubDepartment!.Department!.Group!.SortOrder)
            .ThenBy(c => c.SubDepartment!.Department!.SortOrder)
            .ThenBy(c => c.SubDepartment!.SortOrder)
            .ThenBy(c => c.SortOrder)
            .ToListAsync(ct);

        var result = new List<ProjectMasterDto>();

        foreach (var svc in services)
        {
            var sub = svc.SubDepartment;
            var dept = sub?.Department;
            var group = dept?.Group;

            var groupName = group?.Name ?? "Scope";
            var deptName = dept?.Name ?? "—";
            var subDeptName = sub?.Name ?? "—";
            var tools = svc.DefaultTools ?? "—";
            var duration = svc.DefaultDurationDays.HasValue ? $"{svc.DefaultDurationDays.Value} Days" : "5 Days";
            var unitPrice = svc.DefaultUnitPrice ?? 50000m;

            result.Add(new ProjectMasterDto(
                svc.Id,
                groupName,
                groupName,
                deptName,
                subDeptName,
                svc.Name,
                tools,
                duration,
                unitPrice,
                svc.CreatedAtUtc
            ));
        }

        var allDepts = await db.ServiceDepartments
            .Include(d => d.Group)
            .Include(d => d.SubDepartments.Where(s => s.IsActive))
                .ThenInclude(s => s.Services.Where(c => c.IsActive))
            .Where(d => d.IsActive)
            .ToListAsync(ct);

        foreach (var dept in allDepts)
        {
            var groupName = dept.Group?.Name ?? "Scope";
            if (!dept.SubDepartments.Any())
            {
                result.Add(new ProjectMasterDto(
                    dept.Id,
                    groupName,
                    groupName,
                    dept.Name,
                    "—",
                    "—",
                    "—",
                    "—",
                    0m,
                    dept.CreatedAtUtc
                ));
            }
            else
            {
                foreach (var sub in dept.SubDepartments)
                {
                    if (!sub.Services.Any())
                    {
                        result.Add(new ProjectMasterDto(
                            sub.Id,
                            groupName,
                            groupName,
                            dept.Name,
                            sub.Name,
                            "—",
                            "—",
                            "—",
                            0m,
                            sub.CreatedAtUtc
                        ));
                    }
                }
            }
        }

        return result;
    }

    public async Task<ProjectMasterDto> CreateProjectMasterAsync(
        CreateProjectMasterRequest request,
        CancellationToken ct = default)
    {
        var groupName = string.IsNullOrWhiteSpace(request.ContractType) ? "Scope" : request.ContractType.Trim();
        var deptName = request.Department?.Trim();
        var serviceName = request.Service?.Trim();

        if (string.IsNullOrWhiteSpace(deptName)) throw new ArgumentException("Department is required.");
        if (string.IsNullOrWhiteSpace(serviceName)) throw new ArgumentException("Service is required.");

        var subDeptName = !string.IsNullOrWhiteSpace(request.SubDepartment)
            ? request.SubDepartment.Trim()
            : deptName + " Services";

        // 1. Ensure Group
        var group = await db.ServiceGroups.IgnoreQueryFilters()
            .FirstOrDefaultAsync(g => g.Name.ToLower() == groupName.ToLower() || g.Code.ToLower() == groupName.ToLower(), ct);
        if (group is null)
        {
            var code = Regex.Replace(groupName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');
            if (string.IsNullOrEmpty(code)) code = "GRP";
            group = new MstServiceGroup
            {
                Id = Guid.NewGuid(),
                Code = code,
                Name = groupName,
                SortOrder = (await db.ServiceGroups.IgnoreQueryFilters().MaxAsync(g => (int?)g.SortOrder, ct) ?? 0) + 1,
                IsActive = true
            };
            db.ServiceGroups.Add(group);
            await db.SaveChangesAsync(ct);
        }
        else if (group.DeletedAtUtc != null || !group.IsActive)
        {
            group.DeletedAtUtc = null;
            group.IsActive = true;
            group.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
        }

        // 2. Ensure Department
        var dept = await db.ServiceDepartments.IgnoreQueryFilters()
            .FirstOrDefaultAsync(d => d.Name.ToLower() == deptName.ToLower(), ct);
        if (dept is null)
        {
            var dCode = Regex.Replace(deptName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');
            if (string.IsNullOrEmpty(dCode)) dCode = "DEPT";
            if (dCode.Length > 70) dCode = dCode[..70];

            dept = new MstServiceDepartment
            {
                Id = Guid.NewGuid(),
                GroupId = group.Id,
                Code = dCode,
                Name = deptName,
                SortOrder = (await db.ServiceDepartments.IgnoreQueryFilters().Where(d => d.GroupId == group.Id).MaxAsync(d => (int?)d.SortOrder, ct) ?? 0) + 1,
                IsActive = true
            };
            db.ServiceDepartments.Add(dept);
            await db.SaveChangesAsync(ct);
        }
        else
        {
            var needsSave = false;
            if (dept.GroupId != group.Id)
            {
                dept.GroupId = group.Id;
                needsSave = true;
            }
            if (dept.DeletedAtUtc != null || !dept.IsActive)
            {
                dept.DeletedAtUtc = null;
                dept.IsActive = true;
                dept.UpdatedAtUtc = DateTime.UtcNow;
                needsSave = true;
            }
            if (needsSave)
            {
                await db.SaveChangesAsync(ct);
            }
        }

        // 3. Ensure SubDepartment
        var subDept = await db.ServiceSubDepartments.IgnoreQueryFilters()
            .FirstOrDefaultAsync(s => s.DepartmentId == dept.Id && s.Name.ToLower() == subDeptName.ToLower(), ct);
        if (subDept is null)
        {
            var sCode = "SUB_" + Regex.Replace(subDeptName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');
            if (sCode.Length > 100) sCode = sCode[..100];

            subDept = new MstServiceSubDepartment
            {
                Id = Guid.NewGuid(),
                DepartmentId = dept.Id,
                Code = sCode,
                Name = subDeptName,
                SortOrder = (await db.ServiceSubDepartments.IgnoreQueryFilters().Where(s => s.DepartmentId == dept.Id).MaxAsync(s => (int?)s.SortOrder, ct) ?? 0) + 1,
                IsActive = true
            };
            db.ServiceSubDepartments.Add(subDept);
            await db.SaveChangesAsync(ct);
        }
        else if (subDept.DeletedAtUtc != null || !subDept.IsActive)
        {
            subDept.DeletedAtUtc = null;
            subDept.IsActive = true;
            subDept.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
        }

        // 4. Parse duration days
        var daysMatch = Regex.Match(request.Duration ?? "", @"\d+");
        var durationDays = daysMatch.Success ? int.Parse(daysMatch.Value) : 5;

        // 5. Find or Create Service
        var svc = await db.ServiceCatalogs.IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => c.SubDepartmentId == subDept.Id && c.Name.ToLower() == serviceName.ToLower(), ct);

        if (svc is not null)
        {
            svc.DefaultTools = request.Tools?.Trim();
            svc.DefaultUnitPrice = request.UnitPrice;
            svc.DefaultDurationDays = durationDays;
            svc.DeletedAtUtc = null;
            svc.IsActive = true;
            svc.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
        }
        else
        {
            var svcCode = "SVC_" + Regex.Replace(serviceName.ToUpperInvariant(), @"[^A-Z0-9]+", "_").Trim('_');
            if (svcCode.Length > 40) svcCode = svcCode[..40];

            var cCounter = 1;
            var uCode = svcCode;
            while (await db.ServiceCatalogs.IgnoreQueryFilters().AnyAsync(c => c.Code == uCode, ct))
            {
                uCode = $"{svcCode}_{cCounter++}";
            }

            svc = new MstServiceCatalog
            {
                Id = Guid.NewGuid(),
                SubDepartmentId = subDept.Id,
                Code = uCode,
                Name = serviceName,
                DefaultTools = request.Tools?.Trim(),
                DefaultUnitPrice = request.UnitPrice,
                DefaultDurationDays = durationDays,
                SortOrder = (await db.ServiceCatalogs.IgnoreQueryFilters().Where(c => c.SubDepartmentId == subDept.Id).MaxAsync(c => (int?)c.SortOrder, ct) ?? 0) + 1,
                IsActive = true
            };
            db.ServiceCatalogs.Add(svc);
            await db.SaveChangesAsync(ct);
        }

        return new ProjectMasterDto(
            svc.Id,
            group.Name,
            group.Name,
            dept.Name,
            subDept.Name,
            svc.Name,
            svc.DefaultTools ?? "—",
            $"{svc.DefaultDurationDays ?? 5} Days",
            svc.DefaultUnitPrice ?? 50000m,
            svc.CreatedAtUtc
        );
    }

    public async Task<ProjectMasterDto> UpdateProjectMasterAsync(
        Guid id,
        UpdateProjectMasterRequest request,
        CancellationToken ct = default)
    {
        var svc = await db.ServiceCatalogs
            .Include(c => c.SubDepartment)
                .ThenInclude(s => s!.Department)
                    .ThenInclude(d => d!.Group)
            .FirstOrDefaultAsync(c => c.Id == id, ct);

        if (svc is not null)
        {
            if (!string.IsNullOrWhiteSpace(request.Service))
            {
                svc.Name = request.Service.Trim();
            }
            if (request.Tools is not null)
            {
                svc.DefaultTools = request.Tools.Trim();
            }
            if (request.UnitPrice.HasValue)
            {
                svc.DefaultUnitPrice = request.UnitPrice.Value;
            }
            if (!string.IsNullOrWhiteSpace(request.Duration))
            {
                var match = Regex.Match(request.Duration, @"\d+");
                if (match.Success)
                {
                    svc.DefaultDurationDays = int.Parse(match.Value);
                }
            }

            if (!string.IsNullOrWhiteSpace(request.Department) || !string.IsNullOrWhiteSpace(request.ContractType) || !string.IsNullOrWhiteSpace(request.SubDepartment))
            {
                var targetGroupName = string.IsNullOrWhiteSpace(request.ContractType) ? (svc.SubDepartment?.Department?.Group?.Name ?? "Scope") : request.ContractType.Trim();
                var targetDeptName = string.IsNullOrWhiteSpace(request.Department) ? (svc.SubDepartment?.Department?.Name ?? "General") : request.Department.Trim();
                var targetSubName = string.IsNullOrWhiteSpace(request.SubDepartment) ? (svc.SubDepartment?.Name ?? targetDeptName + " Services") : request.SubDepartment.Trim();

                var grp = await db.ServiceGroups.FirstOrDefaultAsync(g => g.Name.ToLower() == targetGroupName.ToLower(), ct);
                if (grp is null)
                {
                    grp = new MstServiceGroup { Id = Guid.NewGuid(), Code = targetGroupName.ToUpperInvariant(), Name = targetGroupName, IsActive = true };
                    db.ServiceGroups.Add(grp);
                    await db.SaveChangesAsync(ct);
                }

                var dpt = await db.ServiceDepartments.FirstOrDefaultAsync(d => d.Name.ToLower() == targetDeptName.ToLower(), ct);
                if (dpt is null)
                {
                    dpt = new MstServiceDepartment { Id = Guid.NewGuid(), GroupId = grp.Id, Code = targetDeptName.ToUpperInvariant(), Name = targetDeptName, IsActive = true };
                    db.ServiceDepartments.Add(dpt);
                    await db.SaveChangesAsync(ct);
                }
                else if (dpt.GroupId != grp.Id)
                {
                    dpt.GroupId = grp.Id;
                }

                var sdept = await db.ServiceSubDepartments.FirstOrDefaultAsync(s => s.DepartmentId == dpt.Id && s.Name.ToLower() == targetSubName.ToLower(), ct);
                if (sdept is null)
                {
                    sdept = new MstServiceSubDepartment { Id = Guid.NewGuid(), DepartmentId = dpt.Id, Code = "SUB_" + targetSubName.ToUpperInvariant(), Name = targetSubName, IsActive = true };
                    db.ServiceSubDepartments.Add(sdept);
                    await db.SaveChangesAsync(ct);
                }

                svc.SubDepartmentId = sdept.Id;
                svc.SubDepartment = sdept;
                sdept.Department = dpt;
                dpt.Group = grp;
            }

            await db.SaveChangesAsync(ct);

            var gName = svc.SubDepartment?.Department?.Group?.Name ?? "Scope";
            var dName = svc.SubDepartment?.Department?.Name ?? "—";
            var sName = svc.SubDepartment?.Name ?? "—";

            return new ProjectMasterDto(
                svc.Id,
                gName,
                gName,
                dName,
                sName,
                svc.Name,
                svc.DefaultTools ?? "—",
                $"{svc.DefaultDurationDays ?? 5} Days",
                svc.DefaultUnitPrice ?? 50000m,
                svc.CreatedAtUtc
            );
        }

        var sub = await db.ServiceSubDepartments
            .Include(s => s.Department)
                .ThenInclude(d => d!.Group)
            .FirstOrDefaultAsync(s => s.Id == id, ct);

        if (sub is not null)
        {
            if (!string.IsNullOrWhiteSpace(request.SubDepartment))
            {
                sub.Name = request.SubDepartment.Trim();
            }
            if (!string.IsNullOrWhiteSpace(request.Department) && sub.Department != null)
            {
                sub.Department.Name = request.Department.Trim();
            }
            await db.SaveChangesAsync(ct);

            var gName = sub.Department?.Group?.Name ?? "Scope";
            var dName = sub.Department?.Name ?? "—";
            return new ProjectMasterDto(
                sub.Id,
                gName,
                gName,
                dName,
                sub.Name,
                "—",
                "—",
                "—",
                0m,
                sub.CreatedAtUtc
            );
        }

        var deptStub = await db.ServiceDepartments
            .Include(d => d.Group)
            .FirstOrDefaultAsync(d => d.Id == id, ct);

        if (deptStub is not null)
        {
            if (!string.IsNullOrWhiteSpace(request.Department))
            {
                deptStub.Name = request.Department.Trim();
            }
            await db.SaveChangesAsync(ct);

            var gName = deptStub.Group?.Name ?? "Scope";
            return new ProjectMasterDto(
                deptStub.Id,
                gName,
                gName,
                deptStub.Name,
                "—",
                "—",
                "—",
                "—",
                0m,
                deptStub.CreatedAtUtc
            );
        }

        throw new KeyNotFoundException($"Project Master with ID '{id}' was not found.");
    }

    public async Task<bool> DeleteProjectMasterAsync(Guid id, CancellationToken ct = default)
    {
        var now = DateTime.UtcNow;
        var svc = await db.ServiceCatalogs.FirstOrDefaultAsync(c => c.Id == id, ct);
        if (svc is not null)
        {
            svc.IsActive = false;
            svc.DeletedAtUtc = now;
            svc.UpdatedAtUtc = now;
            await db.SaveChangesAsync(ct);
            return true;
        }

        var sub = await db.ServiceSubDepartments.FirstOrDefaultAsync(s => s.Id == id, ct);
        if (sub is not null)
        {
            sub.IsActive = false;
            sub.DeletedAtUtc = now;
            sub.UpdatedAtUtc = now;
            await db.SaveChangesAsync(ct);
            return true;
        }

        var dept = await db.ServiceDepartments.FirstOrDefaultAsync(d => d.Id == id, ct);
        if (dept is not null)
        {
            dept.IsActive = false;
            dept.DeletedAtUtc = now;
            dept.UpdatedAtUtc = now;
            await db.SaveChangesAsync(ct);
            return true;
        }

        return false;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // Customer Masters CRUD (Countries, Cities, Industries, Contact Designations, Contact Types)
    // ══════════════════════════════════════════════════════════════════════════

    public async Task<CatalogOptionDto> CreateCountryAsync(CreateCountryRequest request, CancellationToken ct = default)
    {
        var name = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Country name is required.");

        var code = request.Code?.Trim().ToUpperInvariant();

        var existing = await db.Countries
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => c.Name.ToLower() == name.ToLower() || (!string.IsNullOrEmpty(code) && c.Code.ToUpper() == code), ct);

        if (existing != null)
        {
            if (existing.DeletedAtUtc != null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.Name = name;
                if (!string.IsNullOrEmpty(code)) existing.Code = code;
                if (!string.IsNullOrWhiteSpace(request.PhoneCode)) existing.PhoneCode = request.PhoneCode.Trim();
                if (request.PhoneDigits.HasValue) existing.PhoneDigits = request.PhoneDigits.Value;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                return new CatalogOptionDto(existing.Id, existing.Code, existing.Name, existing.PhoneCode, existing.PhoneDigits);
            }
            throw new ConflictException($"Country '{name}' already exists.");
        }

        var finalCode = !string.IsNullOrEmpty(code)
            ? (code.Length > 8 ? code[..8] : code)
            : await UniqueCodeAsync(Slug(name).ToUpperInvariant(), c => db.Countries.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 8);

        var country = new MstCountry
        {
            Name = name,
            Code = finalCode,
            PhoneCode = !string.IsNullOrWhiteSpace(request.PhoneCode) ? request.PhoneCode.Trim() : "+91",
            PhoneDigits = request.PhoneDigits ?? 10,
            IsActive = true
        };

        db.Countries.Add(country);
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(country.Id, country.Code, country.Name, country.PhoneCode, country.PhoneDigits);
    }

    public async Task<CatalogOptionDto> UpdateCountryAsync(Guid id, UpdateCountryRequest request, CancellationToken ct = default)
    {
        var country = await db.Countries.FirstOrDefaultAsync(c => c.Id == id && c.DeletedAtUtc == null, ct);
        if (country == null)
            throw new NotFoundException($"Country with ID '{id}' was not found.");

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var trimmedName = request.Name.Trim();
            var duplicate = await db.Countries.AnyAsync(c => c.Id != id && c.Name.ToLower() == trimmedName.ToLower() && c.DeletedAtUtc == null, ct);
            if (duplicate)
                throw new ConflictException($"Country '{trimmedName}' already exists.");
            country.Name = trimmedName;
        }

        if (!string.IsNullOrWhiteSpace(request.Code))
        {
            var trimmedCode = request.Code.Trim().ToUpperInvariant();
            if (trimmedCode.Length > 8) trimmedCode = trimmedCode[..8];
            var duplicateCode = await db.Countries.AnyAsync(c => c.Id != id && c.Code.ToUpper() == trimmedCode && c.DeletedAtUtc == null, ct);
            if (duplicateCode)
                throw new ConflictException($"Country code '{trimmedCode}' is already in use.");
            country.Code = trimmedCode;
        }

        if (!string.IsNullOrWhiteSpace(request.PhoneCode))
            country.PhoneCode = request.PhoneCode.Trim();

        if (request.PhoneDigits.HasValue)
            country.PhoneDigits = request.PhoneDigits.Value;

        country.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(country.Id, country.Code, country.Name, country.PhoneCode, country.PhoneDigits);
    }

    public async Task<bool> DeleteCountryAsync(Guid id, CancellationToken ct = default)
    {
        var country = await db.Countries.FirstOrDefaultAsync(c => c.Id == id && c.DeletedAtUtc == null, ct);
        if (country == null)
            return false;

        var now = DateTime.UtcNow;
        country.IsActive = false;
        country.DeletedAtUtc = now;
        country.UpdatedAtUtc = now;

        var cities = await db.Cities.Where(c => c.CountryId == id && c.DeletedAtUtc == null).ToListAsync(ct);
        foreach (var city in cities)
        {
            city.IsActive = false;
            city.DeletedAtUtc = now;
            city.UpdatedAtUtc = now;
        }

        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<CityCatalogOptionDto> CreateCityAsync(CreateCustomerCityRequest request, CancellationToken ct = default)
    {
        if (request.CountryId == Guid.Empty)
            throw new ArgumentException("Country selection is required for city.");

        var country = await db.Countries.FirstOrDefaultAsync(c => c.Id == request.CountryId && c.DeletedAtUtc == null, ct);
        if (country == null)
            throw new NotFoundException("Selected country was not found.");

        var name = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("City name is required.");

        var code = request.Code?.Trim().ToUpperInvariant();

        var existing = await db.Cities
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => (c.CountryId == request.CountryId && c.Name.ToLower() == name.ToLower()) || (!string.IsNullOrEmpty(code) && c.Code.ToUpper() == code), ct);

        if (existing != null)
        {
            if (existing.DeletedAtUtc != null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.Name = name;
                existing.CountryId = request.CountryId;
                if (!string.IsNullOrEmpty(code)) existing.Code = code;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                return new CityCatalogOptionDto(existing.Id, existing.Code, existing.Name, existing.CountryId, country.Name);
            }
            throw new ConflictException($"City '{name}' already exists in {country.Name}.");
        }

        var finalCode = !string.IsNullOrEmpty(code)
            ? code
            : await UniqueCodeAsync($"{country.Code}_{Slug(name)}".ToUpperInvariant(), c => db.Cities.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80);

        var city = new MstCity
        {
            Name = name,
            Code = finalCode,
            CountryId = country.Id,
            IsActive = true
        };

        db.Cities.Add(city);
        await db.SaveChangesAsync(ct);
        return new CityCatalogOptionDto(city.Id, city.Code, city.Name, city.CountryId, country.Name);
    }

    public async Task<CityCatalogOptionDto> UpdateCityAsync(Guid id, UpdateCustomerCityRequest request, CancellationToken ct = default)
    {
        var city = await db.Cities.Include(c => c.Country).FirstOrDefaultAsync(c => c.Id == id && c.DeletedAtUtc == null, ct);
        if (city == null)
            throw new NotFoundException($"City with ID '{id}' was not found.");

        Guid targetCountryId = request.CountryId.HasValue && request.CountryId.Value != Guid.Empty
            ? request.CountryId.Value
            : city.CountryId;

        string countryName = city.Country?.Name ?? string.Empty;

        if (targetCountryId != city.CountryId)
        {
            var targetCountry = await db.Countries.FirstOrDefaultAsync(c => c.Id == targetCountryId && c.DeletedAtUtc == null, ct);
            if (targetCountry == null)
                throw new NotFoundException("Target country was not found.");
            city.CountryId = targetCountryId;
            countryName = targetCountry.Name;
        }

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var trimmedName = request.Name.Trim();
            var duplicate = await db.Cities.AnyAsync(c => c.Id != id && c.CountryId == targetCountryId && c.Name.ToLower() == trimmedName.ToLower() && c.DeletedAtUtc == null, ct);
            if (duplicate)
                throw new ConflictException($"City '{trimmedName}' already exists in this country.");
            city.Name = trimmedName;
        }

        if (!string.IsNullOrWhiteSpace(request.Code))
        {
            var trimmedCode = request.Code.Trim().ToUpperInvariant();
            var duplicateCode = await db.Cities.AnyAsync(c => c.Id != id && c.Code.ToUpper() == trimmedCode && c.DeletedAtUtc == null, ct);
            if (duplicateCode)
                throw new ConflictException($"City code '{trimmedCode}' is already in use.");
            city.Code = trimmedCode;
        }

        city.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return new CityCatalogOptionDto(city.Id, city.Code, city.Name, city.CountryId, countryName);
    }

    public async Task<bool> DeleteCityAsync(Guid id, CancellationToken ct = default)
    {
        var city = await db.Cities.FirstOrDefaultAsync(c => c.Id == id && c.DeletedAtUtc == null, ct);
        if (city == null)
            return false;

        var now = DateTime.UtcNow;
        city.IsActive = false;
        city.DeletedAtUtc = now;
        city.UpdatedAtUtc = now;
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<CatalogOptionDto> CreateIndustryAsync(CreateCatalogItemRequest request, CancellationToken ct = default)
    {
        var name = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Industry name is required.");

        var code = request.Code?.Trim().ToUpperInvariant();
        var existing = await db.Industries
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(i => i.Name.ToLower() == name.ToLower() || (!string.IsNullOrEmpty(code) && i.Code.ToUpper() == code), ct);

        if (existing != null)
        {
            if (existing.DeletedAtUtc != null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.Name = name;
                if (!string.IsNullOrEmpty(code)) existing.Code = code;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                return new CatalogOptionDto(existing.Id, existing.Code, existing.Name);
            }
            throw new ConflictException($"Industry '{name}' already exists.");
        }

        var finalCode = !string.IsNullOrEmpty(code)
            ? code
            : await UniqueCodeAsync(Slug(name).ToUpperInvariant(), c => db.Industries.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80);

        var industry = new MstIndustry
        {
            Name = name,
            Code = finalCode,
            IsActive = true
        };
        db.Industries.Add(industry);
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(industry.Id, industry.Code, industry.Name);
    }

    public async Task<CatalogOptionDto> UpdateIndustryAsync(Guid id, UpdateCatalogItemRequest request, CancellationToken ct = default)
    {
        var item = await db.Industries.FirstOrDefaultAsync(i => i.Id == id && i.DeletedAtUtc == null, ct);
        if (item == null)
            throw new NotFoundException($"Industry with ID '{id}' was not found.");

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var trimmed = request.Name.Trim();
            var duplicate = await db.Industries.AnyAsync(i => i.Id != id && i.Name.ToLower() == trimmed.ToLower() && i.DeletedAtUtc == null, ct);
            if (duplicate)
                throw new ConflictException($"Industry '{trimmed}' already exists.");
            item.Name = trimmed;
        }

        if (!string.IsNullOrWhiteSpace(request.Code))
        {
            var trimmedCode = request.Code.Trim().ToUpperInvariant();
            var duplicateCode = await db.Industries.AnyAsync(i => i.Id != id && i.Code.ToUpper() == trimmedCode && i.DeletedAtUtc == null, ct);
            if (duplicateCode)
                throw new ConflictException($"Industry code '{trimmedCode}' is already in use.");
            item.Code = trimmedCode;
        }

        item.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(item.Id, item.Code, item.Name);
    }

    public async Task<bool> DeleteIndustryAsync(Guid id, CancellationToken ct = default)
    {
        var item = await db.Industries.FirstOrDefaultAsync(i => i.Id == id && i.DeletedAtUtc == null, ct);
        if (item == null) return false;

        var now = DateTime.UtcNow;
        item.IsActive = false;
        item.DeletedAtUtc = now;
        item.UpdatedAtUtc = now;
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<CatalogOptionDto> CreateContactDesignationAsync(CreateCatalogItemRequest request, CancellationToken ct = default)
    {
        var name = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Contact designation name is required.");

        var code = request.Code?.Trim().ToUpperInvariant();
        var existing = await db.ContactDesignations
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(d => d.Name.ToLower() == name.ToLower() || (!string.IsNullOrEmpty(code) && d.Code.ToUpper() == code), ct);

        if (existing != null)
        {
            if (existing.DeletedAtUtc != null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.Name = name;
                if (!string.IsNullOrEmpty(code)) existing.Code = code;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                return new CatalogOptionDto(existing.Id, existing.Code, existing.Name);
            }
            throw new ConflictException($"Contact designation '{name}' already exists.");
        }

        var finalCode = !string.IsNullOrEmpty(code)
            ? code
            : await UniqueCodeAsync(Slug(name).ToUpperInvariant(), c => db.ContactDesignations.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80);

        var desig = new MstContactDesignation
        {
            Name = name,
            Code = finalCode,
            IsActive = true
        };
        db.ContactDesignations.Add(desig);
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(desig.Id, desig.Code, desig.Name);
    }

    public async Task<CatalogOptionDto> UpdateContactDesignationAsync(Guid id, UpdateCatalogItemRequest request, CancellationToken ct = default)
    {
        var item = await db.ContactDesignations.FirstOrDefaultAsync(d => d.Id == id && d.DeletedAtUtc == null, ct);
        if (item == null)
            throw new NotFoundException($"Contact designation with ID '{id}' was not found.");

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var trimmed = request.Name.Trim();
            var duplicate = await db.ContactDesignations.AnyAsync(d => d.Id != id && d.Name.ToLower() == trimmed.ToLower() && d.DeletedAtUtc == null, ct);
            if (duplicate)
                throw new ConflictException($"Contact designation '{trimmed}' already exists.");
            item.Name = trimmed;
        }

        if (!string.IsNullOrWhiteSpace(request.Code))
        {
            var trimmedCode = request.Code.Trim().ToUpperInvariant();
            var duplicateCode = await db.ContactDesignations.AnyAsync(d => d.Id != id && d.Code.ToUpper() == trimmedCode && d.DeletedAtUtc == null, ct);
            if (duplicateCode)
                throw new ConflictException($"Contact designation code '{trimmedCode}' is already in use.");
            item.Code = trimmedCode;
        }

        item.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(item.Id, item.Code, item.Name);
    }

    public async Task<bool> DeleteContactDesignationAsync(Guid id, CancellationToken ct = default)
    {
        var item = await db.ContactDesignations.FirstOrDefaultAsync(d => d.Id == id && d.DeletedAtUtc == null, ct);
        if (item == null) return false;

        var now = DateTime.UtcNow;
        item.IsActive = false;
        item.DeletedAtUtc = now;
        item.UpdatedAtUtc = now;
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<CatalogOptionDto> CreateContactTypeAsync(CreateCatalogItemRequest request, CancellationToken ct = default)
    {
        var name = request.Name?.Trim() ?? string.Empty;
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Contact type name is required.");

        var code = request.Code?.Trim().ToUpperInvariant();
        var existing = await db.ContactTypes
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(t => t.Name.ToLower() == name.ToLower() || (!string.IsNullOrEmpty(code) && t.Code.ToUpper() == code), ct);

        if (existing != null)
        {
            if (existing.DeletedAtUtc != null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.Name = name;
                if (!string.IsNullOrEmpty(code)) existing.Code = code;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                return new CatalogOptionDto(existing.Id, existing.Code, existing.Name);
            }
            throw new ConflictException($"Contact type '{name}' already exists.");
        }

        var finalCode = !string.IsNullOrEmpty(code)
            ? code
            : await UniqueCodeAsync(Slug(name).ToUpperInvariant(), c => db.ContactTypes.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80);

        var type = new MstContactType
        {
            Name = name,
            Code = finalCode,
            IsActive = true
        };
        db.ContactTypes.Add(type);
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(type.Id, type.Code, type.Name);
    }

    public async Task<CatalogOptionDto> UpdateContactTypeAsync(Guid id, UpdateCatalogItemRequest request, CancellationToken ct = default)
    {
        var item = await db.ContactTypes.FirstOrDefaultAsync(t => t.Id == id && t.DeletedAtUtc == null, ct);
        if (item == null)
            throw new NotFoundException($"Contact type with ID '{id}' was not found.");

        if (!string.IsNullOrWhiteSpace(request.Name))
        {
            var trimmed = request.Name.Trim();
            var duplicate = await db.ContactTypes.AnyAsync(t => t.Id != id && t.Name.ToLower() == trimmed.ToLower() && t.DeletedAtUtc == null, ct);
            if (duplicate)
                throw new ConflictException($"Contact type '{trimmed}' already exists.");
            item.Name = trimmed;
        }

        if (!string.IsNullOrWhiteSpace(request.Code))
        {
            var trimmedCode = request.Code.Trim().ToUpperInvariant();
            var duplicateCode = await db.ContactTypes.AnyAsync(t => t.Id != id && t.Code.ToUpper() == trimmedCode && t.DeletedAtUtc == null, ct);
            if (duplicateCode)
                throw new ConflictException($"Contact type code '{trimmedCode}' is already in use.");
            item.Code = trimmedCode;
        }

        item.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return new CatalogOptionDto(item.Id, item.Code, item.Name);
    }

    public async Task<bool> DeleteContactTypeAsync(Guid id, CancellationToken ct = default)
    {
        var item = await db.ContactTypes.FirstOrDefaultAsync(t => t.Id == id && t.DeletedAtUtc == null, ct);
        if (item == null) return false;

        var now = DateTime.UtcNow;
        item.IsActive = false;
        item.DeletedAtUtc = now;
        item.UpdatedAtUtc = now;
        await db.SaveChangesAsync(ct);
        return true;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // Helpers
    // ══════════════════════════════════════════════════════════════════════════

    private static string Slug(string value)
    {
        var lower = value.Trim().ToLowerInvariant();
        var clean = Regex.Replace(lower, @"[^a-z0-9]+", "_").Trim('_');
        return string.IsNullOrEmpty(clean) ? "item" : clean;
    }

    private static async Task<string> UniqueCodeAsync(string baseCode, Func<string, Task<bool>> existsAsync, int maxLength = 80)
    {
        var candidate = baseCode.Length > maxLength ? baseCode[..maxLength] : baseCode;
        if (!await existsAsync(candidate)) return candidate;

        var i = 2;
        while (true)
        {
            var suffix = $"_{i}";
            var prefixLen = Math.Min(baseCode.Length, maxLength - suffix.Length);
            var next = baseCode[..prefixLen] + suffix;
            if (!await existsAsync(next)) return next;
            i++;
        }
    }
}

