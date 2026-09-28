using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectTeamMemberService(AppDbContext db) : IProjectTeamMemberService
{
    public async Task<IReadOnlyList<ProjectTeamMemberDto>> ListAsync(
        Guid projectId,
        bool shadowTeam = false,
        CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);

        var rows = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Employee)
            .Include(m => m.Department)
            .Where(m => m.ProjectId == projectId && m.IsShadowTeam == shadowTeam)
            .OrderByDescending(m => m.IsTeamLead)
            .ThenBy(m => m.Employee!.FirstName)
            .ThenBy(m => m.Employee!.LastName)
            .ToListAsync(ct);

        return rows.Select(MapToDto).ToList();
    }

    public async Task<ProjectTeamMemberDto?> GetByIdAsync(Guid projectId, Guid memberId, CancellationToken ct = default)
    {
        var row = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Employee)
            .Include(m => m.Department)
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.Id == memberId, ct);

        return row is null ? null : MapToDto(row);
    }

    public async Task<IReadOnlyList<ProjectTeamCandidateDto>> SearchCandidatesAsync(
        Guid projectId,
        string? search,
        int limit = 50,
        bool internsOnly = false,
        CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);

        // Exclude people already on the same list (project vs shadow).
        var assignedEmployeeIds = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == projectId && m.IsShadowTeam == internsOnly)
            .Select(m => m.EmployeeId)
            .ToListAsync(ct);

        var take = Math.Clamp(limit, 1, 100);
        var query = db.Employees
            .AsNoTracking()
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Include(e => e.JobRole)
            // Include Active / Active - Probation / Active - Notice Period
            .Where(e => e.Status == null || e.Status.StartsWith("Active"))
            .Where(e => !assignedEmployeeIds.Contains(e.Id));

        if (internsOnly)
        {
            query = query.Where(e =>
                (e.EmploymentType != null && e.EmploymentType.ToLower() == "intern") ||
                EF.Functions.ILike(e.EmployeeCode, "TKI-%") ||
                (e.Role != null && e.Role.ToLower().Contains("intern")) ||
                (e.Category != null && e.Category.ToLower().Contains("intern")) ||
                (e.Designation != null && e.Designation.Name != null && e.Designation.Name.ToLower().Contains("intern")) ||
                (e.JobRole != null && e.JobRole.Name != null && e.JobRole.Name.ToLower().Contains("intern")));
        }
        else
        {
            query = query.Where(e =>
                (e.EmploymentType == null || e.EmploymentType.ToLower() != "intern") &&
                !EF.Functions.ILike(e.EmployeeCode, "TKI-%") &&
                (e.Role == null || !e.Role.ToLower().Contains("intern")) &&
                (e.Category == null || !e.Category.ToLower().Contains("intern")) &&
                (e.Designation == null || e.Designation.Name == null || !e.Designation.Name.ToLower().Contains("intern")) &&
                (e.JobRole == null || e.JobRole.Name == null || !e.JobRole.Name.ToLower().Contains("intern")));
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.Trim().ToLower();
            query = query.Where(e =>
                (e.FirstName + " " + e.LastName).ToLower().Contains(s) ||
                e.EmployeeCode.ToLower().Contains(s) ||
                e.WorkEmail.ToLower().Contains(s));
        }

        var items = await query
            .OrderBy(e => e.FirstName)
            .ThenBy(e => e.LastName)
            .Take(take)
            .ToListAsync(ct);

        return items.Select(e => new ProjectTeamCandidateDto(
            e.Id,
            e.EmployeeCode,
            FullName(e),
            e.WorkEmail,
            e.JobRole?.Name ?? e.Role,
            e.Designation?.Name,
            e.DepartmentId,
            e.Department?.Name ?? e.PmoDepartment,
            e.SubDepartment)).ToList();
    }

    public async Task<ProjectTeamMemberDto> AddAsync(
        Guid projectId,
        CreateProjectTeamMemberRequest request,
        CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project '{projectId}' was not found.");

        if (request.AllocationEndDate < request.AllocationStartDate)
        {
            throw new ConflictException("Allocation end date must not be before start date.");
        }

        var employee = await db.Employees
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Include(e => e.JobRole)
            .FirstOrDefaultAsync(e => e.Id == request.EmployeeId, ct)
            ?? throw new NotFoundException($"Employee '{request.EmployeeId}' was not found.");

        var isShadow = request.IsShadowTeam;
        var isIntern = IsInternEmployee(employee);

        if (isShadow)
        {
            if (!isIntern)
            {
                throw new ConflictException("Only interns can be added to the Shadow Team.");
            }
        }
        else if (isIntern)
        {
            throw new ConflictException("Interns cannot be added to the Project Team. Use Shadow Team for interns.");
        }

        var alreadyAssigned = await db.ProjectTeamMembers
            .AnyAsync(m => m.ProjectId == projectId && m.EmployeeId == request.EmployeeId, ct);
        if (alreadyAssigned)
        {
            throw new ConflictException("Employee is already assigned to this project.");
        }

        // Shadow Team is always Non-Billable + Shared Resource; never Team Lead
        var billability = isShadow ? "Non-Billable" : NormalizeBillability(request.Billability);
        var resourceType = isShadow ? "Shared Resource" : NormalizeResourceType(request.ResourceType);
        var isTeamLead = !isShadow && request.IsTeamLead;

        var entity = new ProjectTeamMember
        {
            ProjectId = projectId,
            EmployeeId = employee.Id,
            DepartmentId = employee.DepartmentId,
            SubDepartment = string.IsNullOrWhiteSpace(employee.SubDepartment) ? null : employee.SubDepartment.Trim(),
            AllocationStartDate = request.AllocationStartDate,
            AllocationEndDate = request.AllocationEndDate,
            Billability = billability,
            IsTeamLead = isTeamLead,
            ResourceType = resourceType,
            IsShadowTeam = isShadow,
        };

        db.ProjectTeamMembers.Add(entity);

        if (isTeamLead)
        {
            project.TeamLeadId = employee.Id;
            project.UpdatedAtUtc = DateTime.UtcNow;
        }

        await db.SaveChangesAsync(ct);

        entity.Employee = employee;
        entity.Department = employee.Department;
        return MapToDto(entity);
    }

    public async Task<ProjectTeamMemberDto> UpdateAsync(
        Guid projectId,
        Guid memberId,
        UpdateProjectTeamMemberRequest request,
        CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project '{projectId}' was not found.");

        var entity = await db.ProjectTeamMembers
            .Include(m => m.Employee)
            .Include(m => m.Department)
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.Id == memberId, ct)
            ?? throw new NotFoundException("Project team member was not found.");

        var start = request.AllocationStartDate ?? entity.AllocationStartDate;
        var end = request.AllocationEndDate ?? entity.AllocationEndDate;
        if (end < start)
        {
            throw new ConflictException("Allocation end date must not be before start date.");
        }

        entity.AllocationStartDate = start;
        entity.AllocationEndDate = end;

        if (entity.IsShadowTeam)
        {
            // Shadow stays Non-Billable / Shared / never Team Lead
            entity.Billability = "Non-Billable";
            entity.ResourceType = "Shared Resource";
            entity.IsTeamLead = false;
        }
        else
        {
            if (request.Billability is not null)
            {
                entity.Billability = NormalizeBillability(request.Billability);
            }

            if (request.ResourceType is not null)
            {
                entity.ResourceType = NormalizeResourceType(request.ResourceType);
            }

            if (request.IsTeamLead.HasValue)
            {
                entity.IsTeamLead = request.IsTeamLead.Value;
                if (request.IsTeamLead.Value)
                {
                    project.TeamLeadId = entity.EmployeeId;
                }
                else if (project.TeamLeadId == entity.EmployeeId)
                {
                    var otherLead = await db.ProjectTeamMembers
                        .Where(m => m.ProjectId == projectId && m.Id != memberId && m.IsTeamLead && !m.IsShadowTeam)
                        .Select(m => (Guid?)m.EmployeeId)
                        .FirstOrDefaultAsync(ct);
                    project.TeamLeadId = otherLead;
                }

                project.UpdatedAtUtc = DateTime.UtcNow;
            }
        }

        entity.UpdatedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
        return MapToDto(entity);
    }

    public async Task<bool> RemoveAsync(Guid projectId, Guid memberId, CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct);
        if (project is null) return false;

        var entity = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(m => m.ProjectId == projectId && m.Id == memberId, ct);
        if (entity is null) return false;

        if (!entity.IsShadowTeam && project.TeamLeadId == entity.EmployeeId)
        {
            var otherLead = await db.ProjectTeamMembers
                .Where(m => m.ProjectId == projectId && m.Id != memberId && m.IsTeamLead && !m.IsShadowTeam)
                .Select(m => (Guid?)m.EmployeeId)
                .FirstOrDefaultAsync(ct);
            project.TeamLeadId = otherLead;
            project.UpdatedAtUtc = DateTime.UtcNow;
        }

        db.ProjectTeamMembers.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    private async Task EnsureProjectExistsAsync(Guid projectId, CancellationToken ct)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists)
        {
            throw new NotFoundException($"Project '{projectId}' was not found.");
        }
    }

    internal static bool IsInternEmployee(Employee e)
    {
        if (e.EmploymentType?.Equals("intern", StringComparison.OrdinalIgnoreCase) == true)
            return true;

        if (e.EmployeeCode.StartsWith("TKI-", StringComparison.OrdinalIgnoreCase))
            return true;

        if (ContainsIntern(e.Role) || ContainsIntern(e.Category) || ContainsIntern(e.ContractType))
            return true;

        if (ContainsIntern(e.Designation?.Name) || ContainsIntern(e.JobRole?.Name))
            return true;

        return false;
    }

    private static bool ContainsIntern(string? value) =>
        !string.IsNullOrWhiteSpace(value) &&
        value.Contains("intern", StringComparison.OrdinalIgnoreCase);

    private static string NormalizeBillability(string value)
    {
        if (value.Equals("Non-Billable", StringComparison.OrdinalIgnoreCase))
            return "Non-Billable";
        if (value.Equals("Billable", StringComparison.OrdinalIgnoreCase))
            return "Billable";
        throw new ConflictException("Billability must be Billable or Non-Billable.");
    }

    private static string NormalizeResourceType(string value)
    {
        if (value.Equals("Shared Resource", StringComparison.OrdinalIgnoreCase))
            return "Shared Resource";
        if (value.Equals("Dedicated", StringComparison.OrdinalIgnoreCase))
            return "Dedicated";
        throw new ConflictException("ResourceType must be Dedicated or Shared Resource.");
    }

    private static string FullName(Employee e) => $"{e.FirstName} {e.LastName}".Trim();

    private static ProjectTeamMemberDto MapToDto(ProjectTeamMember m)
    {
        var emp = m.Employee;
        return new ProjectTeamMemberDto(
            m.Id,
            m.ProjectId,
            m.EmployeeId,
            emp is null ? string.Empty : FullName(emp),
            emp?.EmployeeCode ?? string.Empty,
            emp?.WorkEmail,
            emp?.JobRole?.Name ?? emp?.Role,
            m.DepartmentId,
            m.Department?.Name ?? emp?.Department?.Name ?? emp?.PmoDepartment,
            m.SubDepartment ?? emp?.SubDepartment,
            m.AllocationStartDate,
            m.AllocationEndDate,
            m.Billability,
            m.IsTeamLead,
            m.ResourceType,
            m.IsShadowTeam,
            m.CreatedAtUtc,
            m.UpdatedAtUtc);
    }
}
