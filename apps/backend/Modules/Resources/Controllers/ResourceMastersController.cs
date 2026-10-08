using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Resources.Controllers;

[ApiController]
[Route("api/v1/resource-masters")]
public class ResourceMastersController(AppDbContext db) : ControllerBase
{
    // ══════════════════════════════════════════════════════════════════════════
    // 1. Department Hierarchy
    // ══════════════════════════════════════════════════════════════════════════

    [HttpGet("hierarchy")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ResourceHierarchyDto>>>> GetHierarchy(CancellationToken ct)
    {
        var result = new List<ResourceHierarchyDto>();

        // 1. All job roles that belong to a designation and department
        var jobRoles = await db.JobRoles
            .Include(r => r.Designation)
                .ThenInclude(d => d.Department)
            .Include(r => r.Designation)
                .ThenInclude(d => d.DefaultRole)
            .Where(r => r.DeletedAtUtc == null && r.Designation.DeletedAtUtc == null && (r.Designation.Department == null || r.Designation.Department.DeletedAtUtc == null))
            .OrderBy(r => r.Designation.Department != null ? r.Designation.Department.Name : "")
            .ThenBy(r => r.Designation.Name)
            .ThenBy(r => r.Name)
            .ToListAsync(ct);

        var coveredDesignationIds = new HashSet<Guid>();
        var coveredDepartmentIds = new HashSet<Guid>();

        foreach (var r in jobRoles)
        {
            var desig = r.Designation;
            var dept = desig?.Department;
            var rbacRole = desig?.DefaultRole;

            if (desig != null) coveredDesignationIds.Add(desig.Id);
            if (dept != null) coveredDepartmentIds.Add(dept.Id);

            result.Add(new ResourceHierarchyDto(
                Id: r.Id,
                DepartmentId: dept?.Id,
                DepartmentName: dept?.Name ?? "General",
                DepartmentCode: dept?.Code,
                DesignationId: desig?.Id,
                DesignationName: desig?.Name ?? "General",
                DesignationCode: desig?.Code,
                OnFloorRoleId: r.Id,
                OnFloorRoleName: r.Name,
                OnFloorRoleCode: r.Code,
                AssignedRbacRoleId: rbacRole?.Id,
                AssignedRbacRoleName: rbacRole?.DisplayName ?? rbacRole?.Name ?? "Employee",
                AssignedRbacRoleCode: rbacRole?.Name,
                IsActive: r.IsActive,
                CreatedAtUtc: r.CreatedAtUtc
            ));
        }

        // 2. Designations without on-floor roles
        var standaloneDesignations = await db.Designations
            .Include(d => d.Department)
            .Include(d => d.DefaultRole)
            .Where(d => d.DeletedAtUtc == null && (d.Department == null || d.Department.DeletedAtUtc == null) && !coveredDesignationIds.Contains(d.Id))
            .OrderBy(d => d.Department != null ? d.Department.Name : "")
            .ThenBy(d => d.Name)
            .ToListAsync(ct);

        foreach (var desig in standaloneDesignations)
        {
            var dept = desig.Department;
            var rbacRole = desig.DefaultRole;
            if (dept != null) coveredDepartmentIds.Add(dept.Id);

            result.Add(new ResourceHierarchyDto(
                Id: desig.Id,
                DepartmentId: dept?.Id,
                DepartmentName: dept?.Name ?? "General",
                DepartmentCode: dept?.Code,
                DesignationId: desig.Id,
                DesignationName: desig.Name,
                DesignationCode: desig.Code,
                OnFloorRoleId: null,
                OnFloorRoleName: desig.Name,
                OnFloorRoleCode: null,
                AssignedRbacRoleId: rbacRole?.Id,
                AssignedRbacRoleName: rbacRole?.DisplayName ?? rbacRole?.Name ?? "Employee",
                AssignedRbacRoleCode: rbacRole?.Name,
                IsActive: desig.IsActive,
                CreatedAtUtc: desig.CreatedAtUtc
            ));
        }

        // 3. Departments without any designations
        var standaloneDepartments = await db.Departments
            .Where(d => d.DeletedAtUtc == null && !coveredDepartmentIds.Contains(d.Id))
            .OrderBy(d => d.Name)
            .ToListAsync(ct);

        foreach (var dept in standaloneDepartments)
        {
            result.Add(new ResourceHierarchyDto(
                Id: dept.Id,
                DepartmentId: dept.Id,
                DepartmentName: dept.Name,
                DepartmentCode: dept.Code,
                DesignationId: null,
                DesignationName: "General",
                DesignationCode: null,
                OnFloorRoleId: null,
                OnFloorRoleName: "General",
                OnFloorRoleCode: null,
                AssignedRbacRoleId: null,
                AssignedRbacRoleName: "Employee",
                AssignedRbacRoleCode: null,
                IsActive: dept.IsActive,
                CreatedAtUtc: dept.CreatedAtUtc
            ));
        }

        return Ok(ApiResponse<IReadOnlyList<ResourceHierarchyDto>>.Ok(result));
    }

    [HttpPost("hierarchy")]
    public async Task<ActionResult<ApiResponse<ResourceHierarchyDto>>> CreateHierarchy(
        [FromBody] CreateResourceHierarchyRequest request,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.DepartmentName))
            return BadRequest(ApiResponse<ResourceHierarchyDto>.Fail("VALIDATION", "Department name is required."));
        if (string.IsNullOrWhiteSpace(request.DesignationName))
            return BadRequest(ApiResponse<ResourceHierarchyDto>.Fail("VALIDATION", "Designation name is required."));

        var deptName = request.DepartmentName.Trim();
        var desigName = request.DesignationName.Trim();
        var roleName = !string.IsNullOrWhiteSpace(request.OnFloorRoleName) ? request.OnFloorRoleName.Trim() : desigName;

        var rbacRoleId = await ResolveRbacRoleIdAsync(request.AssignedRbacRoleId, request.AssignedRbacRoleCode, request.AssignedRbacRoleName, ct);

        // 1. Department
        var dept = await db.Departments.IgnoreQueryFilters().FirstOrDefaultAsync(d => d.Name.ToLower() == deptName.ToLower(), ct);
        if (dept == null)
        {
            dept = new MstDepartment
            {
                Name = deptName,
                Code = !string.IsNullOrWhiteSpace(request.DepartmentCode)
                    ? request.DepartmentCode.Trim()
                    : await UniqueCodeAsync(Slug(deptName), c => db.Departments.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 50),
                IsActive = true
            };
            db.Departments.Add(dept);
            await db.SaveChangesAsync(ct);
        }
        else if (dept.DeletedAtUtc != null || !dept.IsActive)
        {
            dept.DeletedAtUtc = null;
            dept.IsActive = true;
            dept.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
        }

        // 2. Designation
        var desig = await db.Designations.IgnoreQueryFilters().FirstOrDefaultAsync(d => d.DepartmentId == dept.Id && d.Name.ToLower() == desigName.ToLower(), ct);
        if (desig == null)
        {
            desig = new MstDesignation
            {
                Name = desigName,
                DepartmentId = dept.Id,
                DefaultRoleId = rbacRoleId,
                Code = !string.IsNullOrWhiteSpace(request.DesignationCode)
                    ? request.DesignationCode.Trim()
                    : await UniqueCodeAsync($"{dept.Code}_{Slug(desigName)}", c => db.Designations.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80),
                IsActive = true
            };
            db.Designations.Add(desig);
            await db.SaveChangesAsync(ct);
        }
        else
        {
            var needsSave = false;
            if (desig.DeletedAtUtc != null || !desig.IsActive)
            {
                desig.DeletedAtUtc = null;
                desig.IsActive = true;
                desig.UpdatedAtUtc = DateTime.UtcNow;
                needsSave = true;
            }
            if (rbacRoleId.HasValue && desig.DefaultRoleId != rbacRoleId)
            {
                desig.DefaultRoleId = rbacRoleId;
                desig.UpdatedAtUtc = DateTime.UtcNow;
                needsSave = true;
            }
            if (needsSave)
            {
                await db.SaveChangesAsync(ct);
            }
        }

        // 3. On-Floor Job Role
        var role = await db.JobRoles.IgnoreQueryFilters().FirstOrDefaultAsync(r => r.DesignationId == desig.Id && r.Name.ToLower() == roleName.ToLower(), ct);
        if (role == null)
        {
            role = new MstRole
            {
                Name = roleName,
                DesignationId = desig.Id,
                Code = !string.IsNullOrWhiteSpace(request.OnFloorRoleCode)
                    ? request.OnFloorRoleCode.Trim()
                    : await UniqueCodeAsync($"{desig.Code}_{Slug(roleName)}", c => db.JobRoles.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80),
                IsActive = true
            };
            db.JobRoles.Add(role);
            await db.SaveChangesAsync(ct);
        }
        else if (role.DeletedAtUtc != null || !role.IsActive)
        {
            role.DeletedAtUtc = null;
            role.IsActive = true;
            role.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
        }

        var rbacRole = desig.DefaultRoleId.HasValue
            ? await db.Roles.FirstOrDefaultAsync(r => r.Id == desig.DefaultRoleId.Value, ct)
            : null;

        var dto = new ResourceHierarchyDto(
            Id: role.Id,
            DepartmentId: dept.Id,
            DepartmentName: dept.Name,
            DepartmentCode: dept.Code,
            DesignationId: desig.Id,
            DesignationName: desig.Name,
            DesignationCode: desig.Code,
            OnFloorRoleId: role.Id,
            OnFloorRoleName: role.Name,
            OnFloorRoleCode: role.Code,
            AssignedRbacRoleId: rbacRole?.Id,
            AssignedRbacRoleName: rbacRole?.DisplayName ?? rbacRole?.Name ?? "Employee",
            AssignedRbacRoleCode: rbacRole?.Name,
            IsActive: role.IsActive,
            CreatedAtUtc: role.CreatedAtUtc
        );

        return Ok(ApiResponse<ResourceHierarchyDto>.Ok(dto));
    }

    [HttpPut("hierarchy/{id:guid}")]
    public async Task<ActionResult<ApiResponse<ResourceHierarchyDto>>> UpdateHierarchy(
        Guid id,
        [FromBody] UpdateResourceHierarchyRequest request,
        CancellationToken ct)
    {
        // Check if id is JobRole
        var role = await db.JobRoles
            .Include(r => r.Designation)
                .ThenInclude(d => d.Department)
            .Include(r => r.Designation)
                .ThenInclude(d => d.DefaultRole)
            .FirstOrDefaultAsync(r => r.Id == id && r.DeletedAtUtc == null, ct);

        if (role != null)
        {
            if (!string.IsNullOrWhiteSpace(request.OnFloorRoleName))
                role.Name = request.OnFloorRoleName.Trim();
            if (request.IsActive.HasValue)
                role.IsActive = request.IsActive.Value;

            if (role.Designation != null)
            {
                if (!string.IsNullOrWhiteSpace(request.DesignationName))
                    role.Designation.Name = request.DesignationName.Trim();
                var resolvedRoleId = await ResolveRbacRoleIdAsync(request.AssignedRbacRoleId, request.AssignedRbacRoleCode, request.AssignedRbacRoleName, ct);
                if (resolvedRoleId.HasValue)
                    role.Designation.DefaultRoleId = resolvedRoleId;

                if (role.Designation.Department != null && !string.IsNullOrWhiteSpace(request.DepartmentName))
                    role.Designation.Department.Name = request.DepartmentName.Trim();
            }

            role.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);

            var rbacRole = role.Designation?.DefaultRoleId.HasValue == true
                ? await db.Roles.FirstOrDefaultAsync(r => r.Id == role.Designation.DefaultRoleId.Value, ct)
                : null;

            return Ok(ApiResponse<ResourceHierarchyDto>.Ok(new ResourceHierarchyDto(
                Id: role.Id,
                DepartmentId: role.Designation?.Department?.Id,
                DepartmentName: role.Designation?.Department?.Name ?? "General",
                DepartmentCode: role.Designation?.Department?.Code,
                DesignationId: role.Designation?.Id,
                DesignationName: role.Designation?.Name ?? "General",
                DesignationCode: role.Designation?.Code,
                OnFloorRoleId: role.Id,
                OnFloorRoleName: role.Name,
                OnFloorRoleCode: role.Code,
                AssignedRbacRoleId: rbacRole?.Id,
                AssignedRbacRoleName: rbacRole?.DisplayName ?? rbacRole?.Name ?? "Employee",
                AssignedRbacRoleCode: rbacRole?.Name,
                IsActive: role.IsActive,
                CreatedAtUtc: role.CreatedAtUtc
            )));
        }

        // Check if id is Designation
        var desig = await db.Designations
            .Include(d => d.Department)
            .Include(d => d.DefaultRole)
            .FirstOrDefaultAsync(d => d.Id == id && d.DeletedAtUtc == null, ct);

        if (desig != null)
        {
            if (!string.IsNullOrWhiteSpace(request.DesignationName))
                desig.Name = request.DesignationName.Trim();
            var resolvedRoleId = await ResolveRbacRoleIdAsync(request.AssignedRbacRoleId, request.AssignedRbacRoleCode, request.AssignedRbacRoleName, ct);
            if (resolvedRoleId.HasValue)
                desig.DefaultRoleId = resolvedRoleId;
            if (request.IsActive.HasValue)
                desig.IsActive = request.IsActive.Value;
            if (desig.Department != null && !string.IsNullOrWhiteSpace(request.DepartmentName))
                desig.Department.Name = request.DepartmentName.Trim();

            desig.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);

            var rbacRole = desig.DefaultRoleId.HasValue
                ? await db.Roles.FirstOrDefaultAsync(r => r.Id == desig.DefaultRoleId.Value, ct)
                : null;

            return Ok(ApiResponse<ResourceHierarchyDto>.Ok(new ResourceHierarchyDto(
                Id: desig.Id,
                DepartmentId: desig.Department?.Id,
                DepartmentName: desig.Department?.Name ?? "General",
                DepartmentCode: desig.Department?.Code,
                DesignationId: desig.Id,
                DesignationName: desig.Name,
                DesignationCode: desig.Code,
                OnFloorRoleId: null,
                OnFloorRoleName: desig.Name,
                OnFloorRoleCode: null,
                AssignedRbacRoleId: rbacRole?.Id,
                AssignedRbacRoleName: rbacRole?.DisplayName ?? rbacRole?.Name ?? "Employee",
                AssignedRbacRoleCode: rbacRole?.Name,
                IsActive: desig.IsActive,
                CreatedAtUtc: desig.CreatedAtUtc
            )));
        }

        // Check if id is Department
        var dept = await db.Departments.FirstOrDefaultAsync(d => d.Id == id && d.DeletedAtUtc == null, ct);
        if (dept != null)
        {
            if (!string.IsNullOrWhiteSpace(request.DepartmentName))
                dept.Name = request.DepartmentName.Trim();
            if (request.IsActive.HasValue)
                dept.IsActive = request.IsActive.Value;

            dept.UpdatedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);

            return Ok(ApiResponse<ResourceHierarchyDto>.Ok(new ResourceHierarchyDto(
                Id: dept.Id,
                DepartmentId: dept.Id,
                DepartmentName: dept.Name,
                DepartmentCode: dept.Code,
                DesignationId: null,
                DesignationName: "General",
                DesignationCode: null,
                OnFloorRoleId: null,
                OnFloorRoleName: "General",
                OnFloorRoleCode: null,
                AssignedRbacRoleId: null,
                AssignedRbacRoleName: "Employee",
                AssignedRbacRoleCode: null,
                IsActive: dept.IsActive,
                CreatedAtUtc: dept.CreatedAtUtc
            )));
        }

        return NotFound(ApiResponse<ResourceHierarchyDto>.Fail("NOT_FOUND", "Hierarchy record not found."));
    }

    [HttpDelete("hierarchy/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteHierarchy(Guid id, CancellationToken ct)
    {
        var now = DateTime.UtcNow;

        // Try JobRole
        var role = await db.JobRoles.FirstOrDefaultAsync(r => r.Id == id && r.DeletedAtUtc == null, ct);
        if (role != null)
        {
            role.DeletedAtUtc = now;
            role.IsActive = false;
            await db.SaveChangesAsync(ct);
            return Ok(ApiResponse<bool>.Ok(true));
        }

        // Try Designation
        var desig = await db.Designations.Include(d => d.Roles).FirstOrDefaultAsync(d => d.Id == id && d.DeletedAtUtc == null, ct);
        if (desig != null)
        {
            desig.DeletedAtUtc = now;
            desig.IsActive = false;
            foreach (var r in desig.Roles)
            {
                r.DeletedAtUtc = now;
                r.IsActive = false;
            }
            await db.SaveChangesAsync(ct);
            return Ok(ApiResponse<bool>.Ok(true));
        }

        // Try Department
        var dept = await db.Departments.Include(d => d.Designations).ThenInclude(d => d.Roles).FirstOrDefaultAsync(d => d.Id == id && d.DeletedAtUtc == null, ct);
        if (dept != null)
        {
            dept.DeletedAtUtc = now;
            dept.IsActive = false;
            foreach (var d in dept.Designations)
            {
                d.DeletedAtUtc = now;
                d.IsActive = false;
                foreach (var r in d.Roles)
                {
                    r.DeletedAtUtc = now;
                    r.IsActive = false;
                }
            }
            await db.SaveChangesAsync(ct);
            return Ok(ApiResponse<bool>.Ok(true));
        }

        return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Hierarchy item not found."));
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 2. Email Domains
    // ══════════════════════════════════════════════════════════════════════════

    [HttpGet("email-domains")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ResourceEmailDomainDto>>>> GetEmailDomains(CancellationToken ct)
    {
        var items = await db.EmailDomains
            .Where(e => e.DeletedAtUtc == null)
            .OrderBy(e => e.SortOrder)
            .ThenBy(e => e.DomainName)
            .Select(e => new ResourceEmailDomainDto(e.Id, e.DomainName, e.DisplayName, e.Code, e.IsActive, e.SortOrder, e.CreatedAtUtc))
            .ToListAsync(ct);

        return Ok(ApiResponse<IReadOnlyList<ResourceEmailDomainDto>>.Ok(items));
    }

    [HttpPost("email-domains")]
    public async Task<ActionResult<ApiResponse<ResourceEmailDomainDto>>> CreateEmailDomain(
        [FromBody] CreateEmailDomainRequest request,
        CancellationToken ct)
    {
        var domain = request.DomainName?.Trim().ToLowerInvariant().TrimStart('@');
        if (string.IsNullOrWhiteSpace(domain) || !domain.Contains('.'))
            return BadRequest(ApiResponse<ResourceEmailDomainDto>.Fail("VALIDATION", "Valid domain name (e.g. talakunchi.in) is required."));

        var existing = await db.EmailDomains.IgnoreQueryFilters().FirstOrDefaultAsync(d => d.DomainName.ToLower() == domain.ToLower(), ct);
        if (existing != null)
        {
            if (existing.DeletedAtUtc != null || !existing.IsActive)
            {
                existing.DeletedAtUtc = null;
                existing.IsActive = true;
                if (!string.IsNullOrWhiteSpace(request.DisplayName)) existing.DisplayName = request.DisplayName.Trim();
                if (!string.IsNullOrWhiteSpace(request.Code)) existing.Code = request.Code.Trim();
                existing.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                return Ok(ApiResponse<ResourceEmailDomainDto>.Ok(new ResourceEmailDomainDto(
                    existing.Id, existing.DomainName, existing.DisplayName, existing.Code, existing.IsActive, existing.SortOrder, existing.CreatedAtUtc
                )));
            }
            return Conflict(ApiResponse<ResourceEmailDomainDto>.Fail("CONFLICT", $"Domain @{domain} already exists."));
        }

        var maxOrder = await db.EmailDomains.IgnoreQueryFilters().MaxAsync(e => (int?)e.SortOrder, ct) ?? 0;
        var entity = new MstEmailDomain
        {
            DomainName = domain,
            DisplayName = !string.IsNullOrWhiteSpace(request.DisplayName) ? request.DisplayName.Trim() : $"@{domain}",
            Code = !string.IsNullOrWhiteSpace(request.Code) ? request.Code.Trim() : await UniqueCodeAsync(domain.Replace(".", "_"), c => db.EmailDomains.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80),
            IsActive = true,
            SortOrder = maxOrder + 1
        };

        db.EmailDomains.Add(entity);
        await db.SaveChangesAsync(ct);

        return Ok(ApiResponse<ResourceEmailDomainDto>.Ok(new ResourceEmailDomainDto(
            entity.Id, entity.DomainName, entity.DisplayName, entity.Code, entity.IsActive, entity.SortOrder, entity.CreatedAtUtc
        )));
    }

    [HttpPut("email-domains/{id:guid}")]
    public async Task<ActionResult<ApiResponse<ResourceEmailDomainDto>>> UpdateEmailDomain(
        Guid id,
        [FromBody] UpdateEmailDomainRequest request,
        CancellationToken ct)
    {
        var entity = await db.EmailDomains.FirstOrDefaultAsync(e => e.Id == id && e.DeletedAtUtc == null, ct);
        if (entity == null)
            return NotFound(ApiResponse<ResourceEmailDomainDto>.Fail("NOT_FOUND", "Email domain not found."));

        if (!string.IsNullOrWhiteSpace(request.DomainName))
        {
            var domain = request.DomainName.Trim().ToLowerInvariant().TrimStart('@');
            if (domain.Contains('.'))
            {
                entity.DomainName = domain;
                if (string.IsNullOrWhiteSpace(request.DisplayName))
                    entity.DisplayName = $"@{domain}";
            }
        }

        if (!string.IsNullOrWhiteSpace(request.DisplayName))
            entity.DisplayName = request.DisplayName.Trim();
        if (!string.IsNullOrWhiteSpace(request.Code))
            entity.Code = request.Code.Trim();
        if (request.IsActive.HasValue)
            entity.IsActive = request.IsActive.Value;

        entity.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);

        return Ok(ApiResponse<ResourceEmailDomainDto>.Ok(new ResourceEmailDomainDto(
            entity.Id, entity.DomainName, entity.DisplayName, entity.Code, entity.IsActive, entity.SortOrder, entity.CreatedAtUtc
        )));
    }

    [HttpDelete("email-domains/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteEmailDomain(Guid id, CancellationToken ct)
    {
        var entity = await db.EmailDomains.FirstOrDefaultAsync(e => e.Id == id && e.DeletedAtUtc == null, ct);
        if (entity == null)
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Email domain not found."));

        entity.DeletedAtUtc = DateTime.UtcNow;
        entity.IsActive = false;
        await db.SaveChangesAsync(ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 3. Current Address – Cities / Stations
    // ══════════════════════════════════════════════════════════════════════════

    [HttpGet("cities")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<ResourceCityDto>>>> GetCities(CancellationToken ct)
    {
        var cities = await db.Cities
            .Where(c => c.DeletedAtUtc == null)
            .OrderBy(c => c.Name)
            .Select(c => new ResourceCityDto(
                c.Id,
                c.Name,
                c.Code,
                c.Code.Contains("_") ? c.Code.Split('_', StringSplitOptions.None)[0] : "Central Line",
                c.Name,
                c.Name,
                c.IsActive,
                c.CreatedAtUtc
            ))
            .ToListAsync(ct);

        return Ok(ApiResponse<IReadOnlyList<ResourceCityDto>>.Ok(cities));
    }

    [HttpPost("cities")]
    public async Task<ActionResult<ApiResponse<ResourceCityDto>>> CreateCity(
        [FromBody] CreateCityRequest request,
        CancellationToken ct)
    {
        var name = request.Name?.Trim();
        if (string.IsNullOrWhiteSpace(name))
            return BadRequest(ApiResponse<ResourceCityDto>.Fail("VALIDATION", "City / Station name is required."));

        var line = !string.IsNullOrWhiteSpace(request.Line) ? request.Line.Trim() : "Western Line";
        var existingCountry = await db.Countries.FirstOrDefaultAsync(c => c.DeletedAtUtc == null, ct);
        if (existingCountry == null)
        {
            existingCountry = new MstCountry { Code = "IN", Name = "India", PhoneCode = "+91", PhoneDigits = 10, IsActive = true };
            db.Countries.Add(existingCountry);
            await db.SaveChangesAsync(ct);
        }

        var existingCity = await db.Cities.FirstOrDefaultAsync(c => c.Name.ToLower() == name.ToLower() && c.DeletedAtUtc == null, ct);
        if (existingCity != null)
            return Conflict(ApiResponse<ResourceCityDto>.Fail("CONFLICT", $"Station / City '{name}' already exists."));

        var entity = new MstCity
        {
            Name = name,
            CountryId = existingCountry.Id,
            Code = !string.IsNullOrWhiteSpace(request.Code)
                ? request.Code.Trim()
                : await UniqueCodeAsync($"{Slug(line)}_{Slug(name)}", c => db.Cities.AnyAsync(x => x.Code == c, ct), 80),
            IsActive = true
        };

        db.Cities.Add(entity);
        await db.SaveChangesAsync(ct);

        return Ok(ApiResponse<ResourceCityDto>.Ok(new ResourceCityDto(
            entity.Id, entity.Name, entity.Code, line, entity.Name, entity.Name, entity.IsActive, entity.CreatedAtUtc
        )));
    }

    [HttpPut("cities/{id:guid}")]
    public async Task<ActionResult<ApiResponse<ResourceCityDto>>> UpdateCity(
        Guid id,
        [FromBody] UpdateCityRequest request,
        CancellationToken ct)
    {
        var entity = await db.Cities.FirstOrDefaultAsync(c => c.Id == id && c.DeletedAtUtc == null, ct);
        if (entity == null)
            return NotFound(ApiResponse<ResourceCityDto>.Fail("NOT_FOUND", "City / Station not found."));

        if (!string.IsNullOrWhiteSpace(request.Name))
            entity.Name = request.Name.Trim();
        if (!string.IsNullOrWhiteSpace(request.Code))
            entity.Code = request.Code.Trim();
        if (request.IsActive.HasValue)
            entity.IsActive = request.IsActive.Value;

        entity.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);

        return Ok(ApiResponse<ResourceCityDto>.Ok(new ResourceCityDto(
            entity.Id, entity.Name, entity.Code, request.Line ?? "Western Line", entity.Name, entity.Name, entity.IsActive, entity.CreatedAtUtc
        )));
    }

    [HttpDelete("cities/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteCity(Guid id, CancellationToken ct)
    {
        var entity = await db.Cities.FirstOrDefaultAsync(c => c.Id == id && c.DeletedAtUtc == null, ct);
        if (entity == null)
            return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "City / Station not found."));

        entity.DeletedAtUtc = DateTime.UtcNow;
        entity.IsActive = false;
        await db.SaveChangesAsync(ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 4–8. Simple Masters (Business Units, Work Locations, Grad Degrees, Post Grad, Certs)
    // ══════════════════════════════════════════════════════════════════════════

    [HttpGet("{category}")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<SimpleMasterDto>>>> GetSimpleMasters(
        string category,
        CancellationToken ct)
    {
        var normalized = category.ToLowerInvariant();
        List<SimpleMasterDto> items = normalized switch
        {
            "business-units" or "businessunits" => await db.BusinessUnits
                .Where(x => x.DeletedAtUtc == null)
                .OrderBy(x => x.SortOrder).ThenBy(x => x.Name)
                .Select(x => new SimpleMasterDto(x.Id, x.Name, x.Code, null, x.IsActive, x.CreatedAtUtc))
                .ToListAsync(ct),

            "work-locations" or "worklocations" => await db.WorkLocations
                .Where(x => x.DeletedAtUtc == null)
                .OrderBy(x => x.SortOrder).ThenBy(x => x.Name)
                .Select(x => new SimpleMasterDto(x.Id, x.Name, x.Code, null, x.IsActive, x.CreatedAtUtc))
                .ToListAsync(ct),

            "graduation-degrees" or "graduationdegrees" => await db.GraduationDegrees
                .Where(x => x.DeletedAtUtc == null)
                .OrderBy(x => x.Name)
                .Select(x => new SimpleMasterDto(x.Id, x.Name, x.Code, null, x.IsActive, x.CreatedAtUtc))
                .ToListAsync(ct),

            "post-graduation-degrees" or "postgraduationdegrees" => await db.PostGraduationDegrees
                .Where(x => x.DeletedAtUtc == null)
                .OrderBy(x => x.Name)
                .Select(x => new SimpleMasterDto(x.Id, x.Name, x.Code, null, x.IsActive, x.CreatedAtUtc))
                .ToListAsync(ct),

            "certifications" => await db.Certifications
                .Where(x => x.DeletedAtUtc == null)
                .OrderBy(x => x.Name)
                .Select(x => new SimpleMasterDto(x.Id, x.Name, x.Code, null, x.IsActive, x.CreatedAtUtc))
                .ToListAsync(ct),

            _ => null!
        };

        if (items == null)
            return NotFound(ApiResponse<IReadOnlyList<SimpleMasterDto>>.Fail("NOT_FOUND", $"Unknown master category '{category}'."));

        return Ok(ApiResponse<IReadOnlyList<SimpleMasterDto>>.Ok(items));
    }

    [HttpPost("{category}")]
    public async Task<ActionResult<ApiResponse<SimpleMasterDto>>> CreateSimpleMaster(
        string category,
        [FromBody] CreateSimpleMasterRequest request,
        CancellationToken ct)
    {
        var name = request.Name?.Trim();
        if (string.IsNullOrWhiteSpace(name))
            return BadRequest(ApiResponse<SimpleMasterDto>.Fail("VALIDATION", "Master name is required."));

        var normalized = category.ToLowerInvariant();
        SimpleMasterDto result;

        switch (normalized)
        {
            case "business-units" or "businessunits":
            {
                var existing = await db.BusinessUnits.IgnoreQueryFilters().FirstOrDefaultAsync(x => x.Name.ToLower() == name.ToLower(), ct);
                if (existing != null)
                {
                    if (existing.DeletedAtUtc != null || !existing.IsActive)
                    {
                        existing.DeletedAtUtc = null;
                        existing.IsActive = true;
                        if (!string.IsNullOrWhiteSpace(request.Code)) existing.Code = request.Code.Trim();
                        existing.UpdatedAtUtc = DateTime.UtcNow;
                        await db.SaveChangesAsync(ct);
                        result = new SimpleMasterDto(existing.Id, existing.Name, existing.Code, request.Description, existing.IsActive, existing.CreatedAtUtc);
                        break;
                    }
                    return Conflict(ApiResponse<SimpleMasterDto>.Fail("CONFLICT", $"Business unit '{name}' already exists."));
                }

                var entity = new MstBusinessUnit
                {
                    Name = name,
                    Code = !string.IsNullOrWhiteSpace(request.Code) ? request.Code.Trim() : await UniqueCodeAsync(Slug(name), c => db.BusinessUnits.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80),
                    IsActive = true
                };
                db.BusinessUnits.Add(entity);
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            case "work-locations" or "worklocations":
            {
                var existing = await db.WorkLocations.IgnoreQueryFilters().FirstOrDefaultAsync(x => x.Name.ToLower() == name.ToLower(), ct);
                if (existing != null)
                {
                    if (existing.DeletedAtUtc != null || !existing.IsActive)
                    {
                        existing.DeletedAtUtc = null;
                        existing.IsActive = true;
                        if (!string.IsNullOrWhiteSpace(request.Code)) existing.Code = request.Code.Trim();
                        existing.UpdatedAtUtc = DateTime.UtcNow;
                        await db.SaveChangesAsync(ct);
                        result = new SimpleMasterDto(existing.Id, existing.Name, existing.Code, request.Description, existing.IsActive, existing.CreatedAtUtc);
                        break;
                    }
                    return Conflict(ApiResponse<SimpleMasterDto>.Fail("CONFLICT", $"Work location '{name}' already exists."));
                }

                var entity = new MstWorkLocation
                {
                    Name = name,
                    Code = !string.IsNullOrWhiteSpace(request.Code) ? request.Code.Trim() : await UniqueCodeAsync(Slug(name), c => db.WorkLocations.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 80),
                    IsActive = true
                };
                db.WorkLocations.Add(entity);
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            case "graduation-degrees" or "graduationdegrees":
            {
                var existing = await db.GraduationDegrees.IgnoreQueryFilters().FirstOrDefaultAsync(x => x.Name.ToLower() == name.ToLower(), ct);
                if (existing != null)
                {
                    if (existing.DeletedAtUtc != null || !existing.IsActive)
                    {
                        existing.DeletedAtUtc = null;
                        existing.IsActive = true;
                        if (!string.IsNullOrWhiteSpace(request.Code)) existing.Code = request.Code.Trim();
                        existing.UpdatedAtUtc = DateTime.UtcNow;
                        await db.SaveChangesAsync(ct);
                        result = new SimpleMasterDto(existing.Id, existing.Name, existing.Code, request.Description, existing.IsActive, existing.CreatedAtUtc);
                        break;
                    }
                    return Conflict(ApiResponse<SimpleMasterDto>.Fail("CONFLICT", $"Graduation degree '{name}' already exists."));
                }

                var entity = new MstGraduationDegree
                {
                    Name = name,
                    Code = !string.IsNullOrWhiteSpace(request.Code) ? request.Code.Trim() : await UniqueCodeAsync(Slug(name), c => db.GraduationDegrees.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 100),
                    IsActive = true
                };
                db.GraduationDegrees.Add(entity);
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            case "post-graduation-degrees" or "postgraduationdegrees":
            {
                var existing = await db.PostGraduationDegrees.IgnoreQueryFilters().FirstOrDefaultAsync(x => x.Name.ToLower() == name.ToLower(), ct);
                if (existing != null)
                {
                    if (existing.DeletedAtUtc != null || !existing.IsActive)
                    {
                        existing.DeletedAtUtc = null;
                        existing.IsActive = true;
                        if (!string.IsNullOrWhiteSpace(request.Code)) existing.Code = request.Code.Trim();
                        existing.UpdatedAtUtc = DateTime.UtcNow;
                        await db.SaveChangesAsync(ct);
                        result = new SimpleMasterDto(existing.Id, existing.Name, existing.Code, request.Description, existing.IsActive, existing.CreatedAtUtc);
                        break;
                    }
                    return Conflict(ApiResponse<SimpleMasterDto>.Fail("CONFLICT", $"Post graduation degree '{name}' already exists."));
                }

                var entity = new MstPostGraduationDegree
                {
                    Name = name,
                    Code = !string.IsNullOrWhiteSpace(request.Code) ? request.Code.Trim() : await UniqueCodeAsync(Slug(name), c => db.PostGraduationDegrees.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 100),
                    IsActive = true
                };
                db.PostGraduationDegrees.Add(entity);
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            case "certifications":
            {
                var existing = await db.Certifications.IgnoreQueryFilters().FirstOrDefaultAsync(x => x.Name.ToLower() == name.ToLower(), ct);
                if (existing != null)
                {
                    if (existing.DeletedAtUtc != null || !existing.IsActive)
                    {
                        existing.DeletedAtUtc = null;
                        existing.IsActive = true;
                        if (!string.IsNullOrWhiteSpace(request.Code)) existing.Code = request.Code.Trim();
                        existing.UpdatedAtUtc = DateTime.UtcNow;
                        await db.SaveChangesAsync(ct);
                        result = new SimpleMasterDto(existing.Id, existing.Name, existing.Code, request.Description, existing.IsActive, existing.CreatedAtUtc);
                        break;
                    }
                    return Conflict(ApiResponse<SimpleMasterDto>.Fail("CONFLICT", $"Certification '{name}' already exists."));
                }

                var entity = new MstCertification
                {
                    Name = name,
                    Code = !string.IsNullOrWhiteSpace(request.Code) ? request.Code.Trim() : await UniqueCodeAsync(Slug(name), c => db.Certifications.IgnoreQueryFilters().AnyAsync(x => x.Code == c, ct), 100),
                    IsActive = true
                };
                db.Certifications.Add(entity);
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            default:
                return NotFound(ApiResponse<SimpleMasterDto>.Fail("NOT_FOUND", $"Unknown master category '{category}'."));
        }

        return Ok(ApiResponse<SimpleMasterDto>.Ok(result));
    }

    [HttpPut("{category}/{id:guid}")]
    public async Task<ActionResult<ApiResponse<SimpleMasterDto>>> UpdateSimpleMaster(
        string category,
        Guid id,
        [FromBody] UpdateSimpleMasterRequest request,
        CancellationToken ct)
    {
        var normalized = category.ToLowerInvariant();
        SimpleMasterDto result;

        switch (normalized)
        {
            case "business-units" or "businessunits":
            {
                var entity = await db.BusinessUnits.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<SimpleMasterDto>.Fail("NOT_FOUND", "Item not found."));
                if (!string.IsNullOrWhiteSpace(request.Name)) entity.Name = request.Name.Trim();
                if (!string.IsNullOrWhiteSpace(request.Code)) entity.Code = request.Code.Trim();
                if (request.IsActive.HasValue) entity.IsActive = request.IsActive.Value;
                entity.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            case "work-locations" or "worklocations":
            {
                var entity = await db.WorkLocations.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<SimpleMasterDto>.Fail("NOT_FOUND", "Item not found."));
                if (!string.IsNullOrWhiteSpace(request.Name)) entity.Name = request.Name.Trim();
                if (!string.IsNullOrWhiteSpace(request.Code)) entity.Code = request.Code.Trim();
                if (request.IsActive.HasValue) entity.IsActive = request.IsActive.Value;
                entity.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            case "graduation-degrees" or "graduationdegrees":
            {
                var entity = await db.GraduationDegrees.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<SimpleMasterDto>.Fail("NOT_FOUND", "Item not found."));
                if (!string.IsNullOrWhiteSpace(request.Name)) entity.Name = request.Name.Trim();
                if (!string.IsNullOrWhiteSpace(request.Code)) entity.Code = request.Code.Trim();
                if (request.IsActive.HasValue) entity.IsActive = request.IsActive.Value;
                entity.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            case "post-graduation-degrees" or "postgraduationdegrees":
            {
                var entity = await db.PostGraduationDegrees.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<SimpleMasterDto>.Fail("NOT_FOUND", "Item not found."));
                if (!string.IsNullOrWhiteSpace(request.Name)) entity.Name = request.Name.Trim();
                if (!string.IsNullOrWhiteSpace(request.Code)) entity.Code = request.Code.Trim();
                if (request.IsActive.HasValue) entity.IsActive = request.IsActive.Value;
                entity.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            case "certifications":
            {
                var entity = await db.Certifications.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<SimpleMasterDto>.Fail("NOT_FOUND", "Item not found."));
                if (!string.IsNullOrWhiteSpace(request.Name)) entity.Name = request.Name.Trim();
                if (!string.IsNullOrWhiteSpace(request.Code)) entity.Code = request.Code.Trim();
                if (request.IsActive.HasValue) entity.IsActive = request.IsActive.Value;
                entity.UpdatedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
                result = new SimpleMasterDto(entity.Id, entity.Name, entity.Code, request.Description, entity.IsActive, entity.CreatedAtUtc);
                break;
            }
            default:
                return NotFound(ApiResponse<SimpleMasterDto>.Fail("NOT_FOUND", $"Unknown master category '{category}'."));
        }

        return Ok(ApiResponse<SimpleMasterDto>.Ok(result));
    }

    [HttpDelete("{category}/{id:guid}")]
    public async Task<ActionResult<ApiResponse<bool>>> DeleteSimpleMaster(
        string category,
        Guid id,
        CancellationToken ct)
    {
        var normalized = category.ToLowerInvariant();
        var now = DateTime.UtcNow;

        switch (normalized)
        {
            case "business-units" or "businessunits":
            {
                var entity = await db.BusinessUnits.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Item not found."));
                entity.DeletedAtUtc = now;
                entity.IsActive = false;
                await db.SaveChangesAsync(ct);
                break;
            }
            case "work-locations" or "worklocations":
            {
                var entity = await db.WorkLocations.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Item not found."));
                entity.DeletedAtUtc = now;
                entity.IsActive = false;
                await db.SaveChangesAsync(ct);
                break;
            }
            case "graduation-degrees" or "graduationdegrees":
            {
                var entity = await db.GraduationDegrees.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Item not found."));
                entity.DeletedAtUtc = now;
                entity.IsActive = false;
                await db.SaveChangesAsync(ct);
                break;
            }
            case "post-graduation-degrees" or "postgraduationdegrees":
            {
                var entity = await db.PostGraduationDegrees.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Item not found."));
                entity.DeletedAtUtc = now;
                entity.IsActive = false;
                await db.SaveChangesAsync(ct);
                break;
            }
            case "certifications":
            {
                var entity = await db.Certifications.FirstOrDefaultAsync(x => x.Id == id && x.DeletedAtUtc == null, ct);
                if (entity == null) return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", "Item not found."));
                entity.DeletedAtUtc = now;
                entity.IsActive = false;
                await db.SaveChangesAsync(ct);
                break;
            }
            default:
                return NotFound(ApiResponse<bool>.Fail("NOT_FOUND", $"Unknown master category '{category}'."));
        }

        return Ok(ApiResponse<bool>.Ok(true));
    }

    // ══════════════════════════════════════════════════════════════════════════
    // 9. RBAC Roles list for dropdown assignment
    // ══════════════════════════════════════════════════════════════════════════

    [HttpGet("rbac-roles")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<RbacRoleOptionDto>>>> GetRbacRoles(CancellationToken ct)
    {
        var roles = await db.Roles
            .Where(r => r.DeletedAtUtc == null && r.IsActive)
            .OrderBy(r => r.DisplayName)
            .Select(r => new RbacRoleOptionDto(r.Id, r.Name, r.DisplayName, r.Description, r.IsActive))
            .ToListAsync(ct);

        return Ok(ApiResponse<IReadOnlyList<RbacRoleOptionDto>>.Ok(roles));
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

    private async Task<Guid?> ResolveRbacRoleIdAsync(string? roleIdStr, string? roleCode, string? roleName, CancellationToken ct)
    {
        if (!string.IsNullOrWhiteSpace(roleIdStr) && Guid.TryParse(roleIdStr, out var parsedGuid))
        {
            var exists = await db.Roles.AnyAsync(r => r.Id == parsedGuid && r.DeletedAtUtc == null, ct);
            if (exists) return parsedGuid;
        }

        if (!string.IsNullOrWhiteSpace(roleCode))
        {
            var normCode = roleCode.Trim().ToLower();
            var matched = await db.Roles.FirstOrDefaultAsync(r => r.DeletedAtUtc == null && r.Name.ToLower() == normCode, ct);
            if (matched != null) return matched.Id;
        }

        if (!string.IsNullOrWhiteSpace(roleName))
        {
            var normName = roleName.Trim().ToLower();
            var matched = await db.Roles.FirstOrDefaultAsync(r => r.DeletedAtUtc == null && (r.DisplayName.ToLower() == normName || r.Name.ToLower() == normName), ct);
            if (matched != null) return matched.Id;

            // Auto-provision in auth.tbl_roles if user created a new custom role
            var autoCode = !string.IsNullOrWhiteSpace(roleCode)
                ? roleCode.Trim()
                : Slug(roleName);
            var newRole = new Role
            {
                Name = autoCode,
                DisplayName = roleName.Trim(),
                Description = $"Operational RBAC role: {roleName.Trim()}",
                IsActive = true
            };
            db.Roles.Add(newRole);
            await db.SaveChangesAsync(ct);
            return newRole.Id;
        }

        return null;
    }
}
