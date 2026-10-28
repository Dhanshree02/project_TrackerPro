using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Catalogs.Services;

public sealed class ProjectMastersService(AppDbContext db) : IProjectMastersService
{
    private const string DefaultSubDepartmentName = "General";

    public async Task<IReadOnlyList<ProjectMasterRowDto>> ListAsync(CancellationToken ct = default)
    {
        var rows = await db.ServiceCatalogs
            .AsNoTracking()
            .Where(c => c.IsActive)
            .Include(c => c.SubDepartment!)
                .ThenInclude(s => s.Department!)
                    .ThenInclude(d => d.Group)
            .OrderBy(c => c.SubDepartment!.Department!.Group!.SortOrder)
            .ThenBy(c => c.SubDepartment!.Department!.SortOrder)
            .ThenBy(c => c.SortOrder)
            .ThenBy(c => c.Name)
            .ToListAsync(ct);

        return rows
            .Where(c => c.SubDepartment?.Department?.Group is not null)
            .Select(MapRow)
            .ToList();
    }

    public async Task<ProjectMasterRowDto> CreateAsync(CreateProjectMasterRequest request, CancellationToken ct = default)
    {
        ValidateMasterFields(request.ContractType, request.Department, request.Service, request.Tools, request.DurationDays, request.UnitPrice);

        var group = await ResolveOrCreateGroupAsync(request.ContractType, ct);
        var department = await ResolveOrCreateDepartmentAsync(group.Id, request.Department.Trim(), ct);
        var subDepartment = await ResolveOrCreateSubDepartmentAsync(
            department.Id,
            string.IsNullOrWhiteSpace(request.SubDepartment) ? DefaultSubDepartmentName : request.SubDepartment!.Trim(),
            ct);

        var serviceName = request.Service.Trim();
        var existing = await db.ServiceCatalogs
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(
                c => c.SubDepartmentId == subDepartment.Id &&
                     c.Name.ToLower() == serviceName.ToLower(),
                ct);

        if (existing is not null && existing.DeletedAtUtc is null && existing.IsActive)
            throw new ConflictException(
                $"Service \"{serviceName}\" already exists for {group.Name} → {department.Name}.");

        MstServiceCatalog entity;
        if (existing is not null)
        {
            existing.DeletedAtUtc = null;
            existing.IsActive = true;
            existing.DefaultTools = request.Tools.Trim();
            existing.DefaultDurationDays = request.DurationDays;
            existing.DefaultUnitPrice = request.UnitPrice;
            existing.UpdatedAtUtc = DateTime.UtcNow;
            entity = existing;
        }
        else
        {
            entity = new MstServiceCatalog
            {
                SubDepartmentId = subDepartment.Id,
                Name = serviceName,
                Code = await UniqueCatalogCodeAsync(serviceName, ct),
                DefaultTools = request.Tools.Trim(),
                DefaultDurationDays = request.DurationDays,
                DefaultUnitPrice = request.UnitPrice,
                IsActive = true,
                SortOrder = await NextCatalogSortAsync(subDepartment.Id, ct),
            };
            db.ServiceCatalogs.Add(entity);
        }

        await db.SaveChangesAsync(ct);
        return await LoadRowAsync(entity.Id, ct);
    }

    public async Task<ProjectMasterRowDto> UpdateAsync(
        Guid serviceCatalogId,
        UpdateProjectMasterRequest request,
        CancellationToken ct = default)
    {
        ValidateMasterFields(request.ContractType, request.Department, request.Service, request.Tools, request.DurationDays, request.UnitPrice);

        var catalog = await db.ServiceCatalogs
            .Include(c => c.SubDepartment!)
                .ThenInclude(s => s.Department!)
                    .ThenInclude(d => d.Group)
            .FirstOrDefaultAsync(c => c.Id == serviceCatalogId, ct)
            ?? throw new NotFoundException("Project master service not found.");

        var group = await ResolveOrCreateGroupAsync(request.ContractType, ct);
        var department = await ResolveOrCreateDepartmentAsync(group.Id, request.Department.Trim(), ct);
        var subName = string.IsNullOrWhiteSpace(request.SubDepartment) ? DefaultSubDepartmentName : request.SubDepartment!.Trim();
        var subDepartment = await ResolveOrCreateSubDepartmentAsync(department.Id, subName, ct);

        var serviceName = request.Service.Trim();
        var duplicate = await db.ServiceCatalogs.AnyAsync(
            c => c.Id != serviceCatalogId &&
                 c.SubDepartmentId == subDepartment.Id &&
                 c.Name.ToLower() == serviceName.ToLower() &&
                 c.DeletedAtUtc == null &&
                 c.IsActive,
            ct);
        if (duplicate)
            throw new ConflictException($"Another service named \"{serviceName}\" already exists in this department.");

        catalog.SubDepartmentId = subDepartment.Id;
        catalog.Name = serviceName;
        catalog.DefaultTools = request.Tools.Trim();
        catalog.DefaultDurationDays = request.DurationDays;
        catalog.DefaultUnitPrice = request.UnitPrice;
        catalog.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return await LoadRowAsync(catalog.Id, ct);
    }

    public async Task DeleteAsync(Guid serviceCatalogId, CancellationToken ct = default)
    {
        var catalog = await db.ServiceCatalogs.FirstOrDefaultAsync(c => c.Id == serviceCatalogId, ct)
            ?? throw new NotFoundException("Project master service not found.");
        catalog.IsActive = false;
        db.ServiceCatalogs.Remove(catalog);
        await db.SaveChangesAsync(ct);
    }

    public async Task<ServiceGroupDto> CreateGroupAsync(string name, CancellationToken ct = default)
    {
        var trimmed = name.Trim();
        if (string.IsNullOrWhiteSpace(trimmed))
            throw new ConflictException("Contract type name is required.");

        var existing = await db.ServiceGroups
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(g => g.Name.ToLower() == trimmed.ToLower(), ct);
        if (existing is not null)
        {
            if (existing.DeletedAtUtc is not null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }

            return new ServiceGroupDto(existing.Id, existing.Code, existing.Name, existing.SortOrder);
        }

        var sort = await db.ServiceGroups.IgnoreQueryFilters().MaxAsync(g => (int?)g.SortOrder, ct) ?? 0;
        var entity = new MstServiceGroup
        {
            Name = trimmed,
            Code = await UniqueGroupCodeAsync(trimmed, ct),
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.ServiceGroups.Add(entity);
        await db.SaveChangesAsync(ct);
        return new ServiceGroupDto(entity.Id, entity.Code, entity.Name, entity.SortOrder);
    }

    public async Task<ServiceDepartmentDto> CreateDepartmentAsync(
        CreateServiceDepartmentRequest request,
        CancellationToken ct = default)
    {
        var deptName = request.Name.Trim();
        if (string.IsNullOrWhiteSpace(deptName))
            throw new ConflictException("Department name is required.");

        var group = await ResolveOrCreateGroupAsync(request.ContractType, ct);
        var department = await ResolveOrCreateDepartmentAsync(group.Id, deptName, ct);
        await ResolveOrCreateSubDepartmentAsync(department.Id, DefaultSubDepartmentName, ct);

        return new ServiceDepartmentDto(
            department.Id,
            department.Code,
            department.Name,
            group.Id,
            group.Name,
            department.SortOrder);
    }

    public async Task<ServiceSubDepartmentDto> CreateSubDepartmentAsync(
        CreateServiceSubDepartmentRequest request,
        CancellationToken ct = default)
    {
        var subName = request.Name.Trim();
        if (string.IsNullOrWhiteSpace(subName))
            throw new ConflictException("Sub-department name is required.");

        var group = await ResolveOrCreateGroupAsync(request.ContractType, ct);
        var department = await ResolveOrCreateDepartmentAsync(group.Id, request.Department.Trim(), ct);
        var subDepartment = await ResolveOrCreateSubDepartmentAsync(department.Id, subName, ct);

        return new ServiceSubDepartmentDto(
            subDepartment.Id,
            subDepartment.Code,
            subDepartment.Name,
            department.Id,
            department.Name,
            subDepartment.SortOrder);
    }

    public async Task<ProjectMasterRowDto> CreateServiceOnlyAsync(
        CreateServiceOnlyRequest request,
        CancellationToken ct = default)
    {
        var tools = request.Tools?.Trim() ?? string.Empty;
        var days = request.DurationDays is > 0 ? request.DurationDays.Value : 5;
        var price = request.UnitPrice is > 0 ? request.UnitPrice.Value : 0m;

        return await CreateAsync(
            new CreateProjectMasterRequest(
                request.ContractType,
                request.Department,
                request.Service,
                string.IsNullOrEmpty(tools) ? "TBD" : tools,
                days,
                price > 0 ? price : 1m,
                request.SubDepartment),
            ct);
    }

    private static void ValidateMasterFields(
        string contractType,
        string department,
        string service,
        string tools,
        int durationDays,
        decimal unitPrice)
    {
        if (string.IsNullOrWhiteSpace(contractType))
            throw new ConflictException("Contract type is required.");
        if (string.IsNullOrWhiteSpace(department))
            throw new ConflictException("Department is required.");
        if (string.IsNullOrWhiteSpace(service))
            throw new ConflictException("Service is required.");
        if (string.IsNullOrWhiteSpace(tools))
            throw new ConflictException("Tools is required.");
        if (durationDays <= 0)
            throw new ConflictException("Duration must be at least 1 day.");
        if (unitPrice <= 0)
            throw new ConflictException("Unit price must be greater than zero.");
    }

    private static ProjectMasterRowDto MapRow(MstServiceCatalog c)
    {
        var dept = c.SubDepartment!.Department!;
        var group = dept.Group!;
        return new ProjectMasterRowDto(
            c.Id,
            group.Id,
            group.Name,
            dept.Id,
            dept.Name,
            c.SubDepartmentId,
            c.SubDepartment!.Name,
            c.Name,
            c.Code,
            c.DefaultTools,
            c.DefaultDurationDays,
            c.DefaultUnitPrice,
            c.CreatedAtUtc);
    }

    private async Task<ProjectMasterRowDto> LoadRowAsync(Guid id, CancellationToken ct)
    {
        var catalog = await db.ServiceCatalogs
            .AsNoTracking()
            .Include(c => c.SubDepartment!)
                .ThenInclude(s => s.Department!)
                    .ThenInclude(d => d.Group)
            .FirstAsync(c => c.Id == id, ct);
        return MapRow(catalog);
    }

    private async Task<MstServiceGroup> ResolveOrCreateGroupAsync(string contractTypeName, CancellationToken ct)
    {
        var trimmed = contractTypeName.Trim();
        var groups = await db.ServiceGroups.Where(g => g.IsActive).ToListAsync(ct);
        var match = groups.FirstOrDefault(g => GroupNamesMatch(g.Name, trimmed));
        if (match is not null)
            return match;

        var dto = await CreateGroupAsync(trimmed, ct);
        return await db.ServiceGroups.FirstAsync(g => g.Id == dto.Id, ct);
    }

    private static bool GroupNamesMatch(string groupName, string contractTypeName)
    {
        if (string.Equals(groupName, contractTypeName, StringComparison.OrdinalIgnoreCase))
            return true;

        var g = groupName.ToLowerInvariant();
        var c = contractTypeName.ToLowerInvariant();
        if (c.Contains("resource") && g.Contains("resource"))
            return true;
        if (c.Contains("scope") && g.Contains("scope"))
            return true;
        return false;
    }

    private async Task<MstServiceDepartment> ResolveOrCreateDepartmentAsync(
        Guid groupId,
        string departmentName,
        CancellationToken ct)
    {
        var existing = await db.ServiceDepartments
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(
                d => d.GroupId == groupId && d.Name.ToLower() == departmentName.ToLower(),
                ct);

        if (existing is not null)
        {
            if (existing.DeletedAtUtc is not null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }

            return existing;
        }

        var sort = await db.ServiceDepartments
            .IgnoreQueryFilters()
            .Where(d => d.GroupId == groupId)
            .MaxAsync(d => (int?)d.SortOrder, ct) ?? 0;

        var group = await db.ServiceGroups.FirstAsync(g => g.Id == groupId, ct);
        var entity = new MstServiceDepartment
        {
            GroupId = groupId,
            Name = departmentName,
            Code = await UniqueDepartmentCodeAsync(group.Code, departmentName, ct),
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.ServiceDepartments.Add(entity);
        await db.SaveChangesAsync(ct);
        return entity;
    }

    private async Task<MstServiceSubDepartment> ResolveOrCreateSubDepartmentAsync(
        Guid departmentId,
        string subDepartmentName,
        CancellationToken ct)
    {
        var existing = await db.ServiceSubDepartments
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(
                s => s.DepartmentId == departmentId && s.Name.ToLower() == subDepartmentName.ToLower(),
                ct);

        if (existing is not null)
        {
            if (existing.DeletedAtUtc is not null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }

            return existing;
        }

        var dept = await db.ServiceDepartments.FirstAsync(d => d.Id == departmentId, ct);
        var sort = await db.ServiceSubDepartments
            .IgnoreQueryFilters()
            .Where(s => s.DepartmentId == departmentId)
            .MaxAsync(s => (int?)s.SortOrder, ct) ?? 0;

        var entity = new MstServiceSubDepartment
        {
            DepartmentId = departmentId,
            Name = subDepartmentName,
            Code = await UniqueSubDepartmentCodeAsync(dept.Code, subDepartmentName, ct),
            IsActive = true,
            SortOrder = sort + 1,
        };
        db.ServiceSubDepartments.Add(entity);
        await db.SaveChangesAsync(ct);
        return entity;
    }

    private async Task<string> UniqueGroupCodeAsync(string name, CancellationToken ct)
    {
        var baseCode = Truncate(Slug(name), 40);
        return await UniqueCodeAsync(baseCode, c => db.ServiceGroups.IgnoreQueryFilters().AnyAsync(g => g.Code == c, ct), 40);
    }

    private async Task<string> UniqueDepartmentCodeAsync(string groupCode, string name, CancellationToken ct)
    {
        var baseCode = Truncate($"{groupCode}_{Slug(name)}", 80);
        return await UniqueCodeAsync(baseCode, c => db.ServiceDepartments.IgnoreQueryFilters().AnyAsync(d => d.Code == c, ct), 80);
    }

    private async Task<string> UniqueSubDepartmentCodeAsync(string deptCode, string name, CancellationToken ct)
    {
        var baseCode = Truncate($"{deptCode}_{Slug(name)}", 120);
        return await UniqueCodeAsync(baseCode, c => db.ServiceSubDepartments.IgnoreQueryFilters().AnyAsync(s => s.Code == c, ct), 120);
    }

    private async Task<string> UniqueCatalogCodeAsync(string name, CancellationToken ct)
    {
        var baseCode = Truncate($"SVC_{Slug(name)}", 50);
        return await UniqueCodeAsync(baseCode, c => db.ServiceCatalogs.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 50);
    }

    private async Task<int> NextCatalogSortAsync(Guid subDepartmentId, CancellationToken ct)
    {
        var max = await db.ServiceCatalogs
            .IgnoreQueryFilters()
            .Where(c => c.SubDepartmentId == subDepartmentId)
            .MaxAsync(c => (int?)c.SortOrder, ct);
        return (max ?? 0) + 1;
    }

    private static async Task<string> UniqueCodeAsync(
        string baseCode,
        Func<string, Task<bool>> exists,
        int maxLen)
    {
        var candidate = Truncate(baseCode, maxLen);
        if (!await exists(candidate))
            return candidate;

        for (var i = 2; i < 1000; i++)
        {
            var suffix = $"_{i}";
            var trimmed = Truncate(baseCode, maxLen - suffix.Length) + suffix;
            if (!await exists(trimmed))
                return trimmed;
        }

        return Truncate($"{baseCode}_{Guid.NewGuid():N}"[..8], maxLen);
    }

    private static string Slug(string value)
    {
        var chars = value.Trim().ToUpperInvariant()
            .Select(ch => char.IsLetterOrDigit(ch) ? ch : '_')
            .ToArray();
        var slug = new string(chars).Trim('_');
        while (slug.Contains("__", StringComparison.Ordinal))
            slug = slug.Replace("__", "_", StringComparison.Ordinal);
        return string.IsNullOrEmpty(slug) ? "ITEM" : slug;
    }

    private static string Truncate(string value, int maxLen) =>
        value.Length <= maxLen ? value : value[..maxLen];
}
