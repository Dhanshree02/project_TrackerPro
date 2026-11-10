using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectTeamMemberService(AppDbContext db, ICurrentUserService currentUser) : IProjectTeamMemberService
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
            .Where(m => m.ProjectId == projectId && (shadowTeam
                ? m.MemberRole == ProjectMemberRoles.ShadowTeam
                : m.MemberRole != ProjectMemberRoles.ShadowTeam))
            .ToListAsync(ct);

        return rows
            .OrderBy(TeamDisplayRank)
            .ThenBy(m => m.Employee?.FirstName)
            .ThenBy(m => m.Employee?.LastName)
            .Select(MapToDto)
            .ToList();
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

        // One person has one membership on a project, including manager rows.
        var assignedEmployeeIds = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == projectId)
            .Select(m => m.EmployeeId)
            .ToListAsync(ct);

        var take = Math.Clamp(limit, 1, 100);
        var query = db.Employees
            .AsNoTracking()
            .Include(e => e.Department)
            .Include(e => e.Designation)
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
                (e.Designation != null && e.Designation.Name != null && e.Designation.Name.ToLower().Contains("intern")));
        }
        else
        {
            query = query.Where(e =>
                (e.EmploymentType == null || e.EmploymentType.ToLower() != "intern") &&
                !EF.Functions.ILike(e.EmployeeCode, "TKI-%") &&
                (e.Role == null || !e.Role.ToLower().Contains("intern")) &&
                (e.Category == null || !e.Category.ToLower().Contains("intern")) &&
                (e.Designation == null || e.Designation.Name == null || !e.Designation.Name.ToLower().Contains("intern")));
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
            e.Role,
            e.Designation?.Name,
            e.DepartmentId,
            e.Department?.Name ?? e.PmoDepartment,
            e.SubDepartment)).ToList();
    }

    public async Task<IReadOnlyList<EmployeeAllocationBookingDto>> ListOtherAllocationsAsync(
        Guid projectId,
        Guid employeeId,
        CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);
        var today = TodayIst();

        var rows = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Project)
            .Where(m => m.EmployeeId == employeeId && m.ProjectId != projectId)
            .Where(m => m.MemberRole == ProjectMemberRoles.ProjectTeam || m.MemberRole == ProjectMemberRoles.ShadowTeam)
            .Where(m => m.AllocationEndDate >= today)
            .OrderBy(m => m.AllocationStartDate)
            .ToListAsync(ct);

        return rows.Select(m => new EmployeeAllocationBookingDto(
            m.ProjectId,
            m.Project?.Name ?? "Another project",
            m.AllocationStartDate,
            m.AllocationEndDate,
            m.ResourceType)).ToList();
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

        await EnsureNoDedicatedOverlapAsync(projectId, request.EmployeeId, request.AllocationStartDate, request.AllocationEndDate, ct);

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
            MemberRole = isShadow ? ProjectMemberRoles.ShadowTeam : ProjectMemberRoles.ProjectTeam,
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

        if (ProjectMemberRoles.IsManager(entity.MemberRole))
        {
            throw new ConflictException("Project Manager and Senior Project Manager are changed from WBS Project Allocation.");
        }

        var start = request.AllocationStartDate ?? entity.AllocationStartDate;
        var end = request.AllocationEndDate ?? entity.AllocationEndDate;
        if (end < start)
        {
            throw new ConflictException("Allocation end date must not be before start date.");
        }

        await EnsureNoDedicatedOverlapAsync(projectId, entity.EmployeeId, start, end, ct);

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
                        .Where(m => m.ProjectId == projectId && m.Id != memberId && m.IsTeamLead && m.MemberRole == ProjectMemberRoles.ProjectTeam)
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

        if (ProjectMemberRoles.IsManager(entity.MemberRole))
        {
            throw new ConflictException("Project Manager and Senior Project Manager are changed from WBS Project Allocation.");
        }

        if (entity.MemberRole == ProjectMemberRoles.ProjectTeam && project.TeamLeadId == entity.EmployeeId)
        {
            var otherLead = await db.ProjectTeamMembers
                .Where(m => m.ProjectId == projectId && m.Id != memberId && m.IsTeamLead && m.MemberRole == ProjectMemberRoles.ProjectTeam)
                .Select(m => (Guid?)m.EmployeeId)
                .FirstOrDefaultAsync(ct);
            project.TeamLeadId = otherLead;
            project.UpdatedAtUtc = DateTime.UtcNow;
        }

        db.ProjectTeamMembers.Remove(entity);
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<IReadOnlyList<ProjectTeamMemberDto>> SetLeadershipAsync(
        Guid projectId,
        SetProjectLeadershipRequest request,
        CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project '{projectId}' was not found.");

        if (request.ProjectManagerIds is not null)
        {
            var pmIds = DistinctIds(request.ProjectManagerIds);
            await ReplaceManagersAsync(project, ProjectMemberRoles.ProjectManager, pmIds, ct);
            project.ProjectManagerId = pmIds.Count == 0 ? null : pmIds[0];
            project.UpdatedAtUtc = DateTime.UtcNow;
        }

        if (request.SeniorProjectManagerIds is not null)
        {
            await ReplaceManagersAsync(project, ProjectMemberRoles.SeniorProjectManager, request.SeniorProjectManagerIds, ct);
        }

        await db.SaveChangesAsync(ct);

        var managers = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Employee)
            .Include(m => m.Department)
            .Where(m => m.ProjectId == projectId &&
                        (m.MemberRole == ProjectMemberRoles.ProjectManager ||
                         m.MemberRole == ProjectMemberRoles.SeniorProjectManager))
            .ToListAsync(ct);

        return managers
            .OrderBy(TeamDisplayRank)
            .ThenBy(m => m.Employee?.FirstName)
            .ThenBy(m => m.Employee?.LastName)
            .Select(MapToDto)
            .ToList();
    }

    private async Task ReplaceManagersAsync(
        Project project,
        string role,
        IReadOnlyList<Guid> employeeIds,
        CancellationToken ct)
    {
        var ids = DistinctIds(employeeIds);
        if (ids.Count == 0)
        {
            var clearing = await db.ProjectTeamMembers
                .Where(m => m.ProjectId == project.Id && m.MemberRole == role)
                .ToListAsync(ct);
            foreach (var row in clearing)
            {
                db.ProjectTeamMembers.Remove(row);
            }

            return;
        }

        var employees = await db.Employees
            .Include(e => e.Department)
            .Where(e => ids.Contains(e.Id))
            .ToListAsync(ct);
        if (employees.Count != ids.Count)
        {
            throw new NotFoundException("One or more selected employees were not found.");
        }

        var blocked = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == project.Id && ids.Contains(m.EmployeeId) && m.MemberRole != role)
            .Select(m => m.MemberRole)
            .FirstOrDefaultAsync(ct);
        if (blocked is not null)
        {
            var label = blocked switch
            {
                ProjectMemberRoles.SeniorProjectManager => "a Senior Project Manager",
                ProjectMemberRoles.ProjectManager => "a Project Manager",
                ProjectMemberRoles.ShadowTeam => "on the Shadow Team",
                _ => "on the Project Team",
            };
            throw new ConflictException($"That person is already {label} on this project.");
        }

        var existing = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == project.Id && m.MemberRole == role)
            .ToListAsync(ct);

        foreach (var row in existing.Where(r => !ids.Contains(r.EmployeeId)))
        {
            db.ProjectTeamMembers.Remove(row);
        }

        var (start, end) = ProjectAllocationDates(project);
        foreach (var id in ids)
        {
            var employee = employees.First(e => e.Id == id);
            var row = existing.FirstOrDefault(r => r.EmployeeId == id);
            if (row is null)
            {
                db.ProjectTeamMembers.Add(new ProjectTeamMember
                {
                    ProjectId = project.Id,
                    EmployeeId = employee.Id,
                    DepartmentId = employee.DepartmentId,
                    SubDepartment = string.IsNullOrWhiteSpace(employee.SubDepartment) ? null : employee.SubDepartment.Trim(),
                    AllocationStartDate = start,
                    AllocationEndDate = end,
                    Billability = "Billable",
                    IsTeamLead = false,
                    ResourceType = "Dedicated",
                    IsShadowTeam = false,
                    MemberRole = role,
                });
                continue;
            }

            row.DepartmentId = employee.DepartmentId;
            row.SubDepartment = string.IsNullOrWhiteSpace(employee.SubDepartment) ? null : employee.SubDepartment.Trim();
            row.AllocationStartDate = start;
            row.AllocationEndDate = end;
            row.IsTeamLead = false;
            row.IsShadowTeam = false;
            row.MemberRole = role;
        }
    }

    private static List<Guid> DistinctIds(IReadOnlyList<Guid> employeeIds)
    {
        var ids = new List<Guid>();
        foreach (var id in employeeIds)
        {
            if (id == Guid.Empty || ids.Contains(id)) continue;
            ids.Add(id);
        }

        return ids;
    }

    private static (DateOnly Start, DateOnly End) ProjectAllocationDates(Project project)
    {
        var start = project.StartDate ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var end = project.EndDate ?? start;
        if (end < start) end = start;
        return (start, end);
    }

    private static int TeamDisplayRank(ProjectTeamMember member) => member.MemberRole switch
    {
        ProjectMemberRoles.SeniorProjectManager => 0,
        ProjectMemberRoles.ProjectManager => 1,
        _ when member.IsTeamLead => 2,
        _ => 3,
    };

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

        if (ContainsIntern(e.Designation?.Name) || ContainsIntern(e.Role))
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

    private async Task EnsureNoDedicatedOverlapAsync(
        Guid projectId,
        Guid employeeId,
        DateOnly start,
        DateOnly end,
        CancellationToken ct)
    {
        var clash = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Project)
            .Where(m => m.EmployeeId == employeeId && m.ProjectId != projectId)
            .Where(m => m.MemberRole == ProjectMemberRoles.ProjectTeam || m.MemberRole == ProjectMemberRoles.ShadowTeam)
            .Where(m => m.ResourceType == "Dedicated")
            .Where(m => m.AllocationStartDate <= end && m.AllocationEndDate >= start)
            .OrderBy(m => m.AllocationEndDate)
            .FirstOrDefaultAsync(ct);

        if (clash is null) return;

        var projectName = string.IsNullOrWhiteSpace(clash.Project?.Name) ? "another project" : clash.Project!.Name;
        throw new ConflictException(
            $"This person is Dedicated on {projectName} until {clash.AllocationEndDate:dd-MM-yyyy}. Choose dates that do not overlap that allocation.");
    }

    private static DateOnly TodayIst()
    {
        TimeZoneInfo tz;
        try
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }
        catch (TimeZoneNotFoundException)
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }

        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz));
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
            emp?.Role,
            m.DepartmentId,
            m.Department?.Name ?? emp?.Department?.Name ?? emp?.PmoDepartment,
            m.SubDepartment ?? emp?.SubDepartment,
            m.AllocationStartDate,
            m.AllocationEndDate,
            m.Billability,
            m.IsTeamLead,
            m.ResourceType,
            m.IsShadowTeam,
            string.IsNullOrWhiteSpace(m.MemberRole) ? ProjectMemberRoles.ProjectTeam : m.MemberRole,
            m.CreatedAtUtc,
            m.UpdatedAtUtc);
    }

    public async Task<ProjectResourceAllocationRequestDto> RequestAllocationAsync(
        Guid projectId,
        CreateResourceAllocationRequest request,
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
            .FirstOrDefaultAsync(e => e.Id == request.EmployeeId && e.DeletedAtUtc == null, ct)
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
            .AnyAsync(m => m.ProjectId == projectId && m.EmployeeId == request.EmployeeId && m.DeletedAtUtc == null, ct);
        if (alreadyAssigned)
        {
            throw new ConflictException("Employee is already assigned to this project.");
        }

        var alreadyPending = await db.ProjectResourceAllocationRequests
            .AnyAsync(r => r.ProjectId == projectId && r.EmployeeId == request.EmployeeId && r.Status == "Pending" && r.DeletedAtUtc == null, ct);
        if (alreadyPending)
        {
            throw new ConflictException("An allocation request for this employee is already pending approval.");
        }

        await EnsureNoDedicatedOverlapAsync(projectId, request.EmployeeId, request.AllocationStartDate, request.AllocationEndDate, ct);

        // Resolve candidate's Reporting Manager
        Employee? reportingManager = null;
        if (employee.ReportingManagerId is Guid mgrId && mgrId != Guid.Empty)
        {
            reportingManager = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == mgrId && e.DeletedAtUtc == null, ct);
        }

        if (reportingManager == null)
        {
            reportingManager = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => (e.Role == "Admin" || (e.Role != null && e.Role.Contains("PMO"))) && e.DeletedAtUtc == null, ct);
        }

        var approverId = reportingManager?.Id;
        var approverName = reportingManager != null ? $"{reportingManager.FirstName} {reportingManager.LastName}".Trim() : "Reporting Manager";

        var requester = await FindCurrentEmployeeAsync(ct);
        var requesterId = requester?.Id;
        var requesterName = requester != null ? $"{requester.FirstName} {requester.LastName}".Trim() : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : "Project Manager");

        var allocReqId = Guid.NewGuid();
        var allocTaskCode = $"ALLOC-{allocReqId.ToString()[..8].ToUpper()}";
        var billability = isShadow ? "Non-Billable" : NormalizeBillability(request.Billability);
        var resourceType = isShadow ? "Shared Resource" : NormalizeResourceType(request.ResourceType);
        var isTeamLead = !isShadow && request.IsTeamLead;

        var history = new[]
        {
            new
            {
                status = "Pending",
                at = DateTime.UtcNow.ToString("o"),
                updatedBy = requesterName,
                comment = request.Notes ?? "Resource allocation approval request submitted"
            }
        };

        var entity = new ProjectResourceAllocationRequest
        {
            Id = allocReqId,
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
            Status = "Pending",
            RequestedByEmployeeId = requesterId,
            RequestedByName = requesterName,
            ApproverEmployeeId = approverId,
            ApproverName = approverName,
            CommentsJson = "[]",
            HistoryJson = JsonSerializer.Serialize(history)
        };

        db.ProjectResourceAllocationRequests.Add(entity);

        // Dispatch Notification to Selected Resource's Reporting Manager
        var candidateName = $"{employee.FirstName} {employee.LastName}".Trim();
        var durationStr = $"{request.AllocationStartDate:dd/MM/yyyy} to {request.AllocationEndDate:dd/MM/yyyy}";
        var notifTitle = $"Resource Allocation Request: {candidateName} — {project.Name}";

        var notif = new ActionNotification
        {
            Id = Guid.NewGuid(),
            RecipientEmployeeId = approverId ?? Guid.Empty,
            ProjectId = projectId,
            ProjectCode = project.ProjectCode,
            ProjectName = project.Name,
            Title = notifTitle,
            Type = "Resource Allocation Approval",
            Priority = "Medium",
            Status = "Pending",
            Unread = true,
            RaisedByEmployeeId = requesterId,
            RaisedByName = requesterName,
            RelatedTask = allocTaskCode,
            HistoryJson = JsonSerializer.Serialize(new[]
            {
                new
                {
                    action = $"Requested {candidateName} ({resourceType}, {billability}, Duration: {durationStr}) for {project.Name} by {requesterName}",
                    date = DateTime.UtcNow.ToString("yyyy-MM-dd"),
                    time = DateTime.UtcNow.ToString("HH:mm:ss"),
                    by = requesterName,
                    status = "Pending"
                }
            })
        };

        if (approverId.HasValue && approverId != Guid.Empty)
        {
            db.ActionNotifications.Add(notif);
        }

        await db.SaveChangesAsync(ct);

        entity.Project = project;
        entity.Employee = employee;
        entity.Department = employee.Department;

        TrySyncNotificationsToOtherDatabase(new[] { notif });
        TrySyncAllocationRequestToOtherDatabase(entity);

        return MapAllocationDto(entity);
    }

    public async Task<IReadOnlyList<ProjectResourceAllocationRequestDto>> ListPendingAllocationsAsync(
        CancellationToken ct = default)
    {
        var currentEmp = await FindCurrentEmployeeAsync(ct);
        var currentEmpId = currentEmp?.Id;
        var isSuper = currentUser.Role is "Admin" or "SuperAdmin" || currentUser.Email == "admin@talakunchi.com";

        var query = db.ProjectResourceAllocationRequests
            .Include(r => r.Project)
            .Include(r => r.Employee)
            .Include(r => r.Department)
            .AsNoTracking()
            .Where(r => r.DeletedAtUtc == null);

        if (!isSuper && currentEmpId.HasValue)
        {
            query = query.Where(r => r.ApproverEmployeeId == currentEmpId.Value);
        }

        var list = await query
            .OrderByDescending(r => r.CreatedAtUtc)
            .ToListAsync(ct);

        return list.Select(MapAllocationDto).ToList();
    }

    public async Task<IReadOnlyList<ProjectResourceAllocationRequestDto>> ListProjectAllocationRequestsAsync(
        Guid projectId,
        CancellationToken ct = default)
    {
        var list = await db.ProjectResourceAllocationRequests
            .Include(r => r.Project)
            .Include(r => r.Employee)
            .Include(r => r.Department)
            .AsNoTracking()
            .Where(r => r.ProjectId == projectId && r.DeletedAtUtc == null)
            .OrderByDescending(r => r.CreatedAtUtc)
            .ToListAsync(ct);

        return list.Select(MapAllocationDto).ToList();
    }

    public async Task<ProjectResourceAllocationRequestDto> TakeAllocationActionAsync(
        Guid projectId,
        Guid requestId,
        ResourceAllocationActionRequest request,
        CancellationToken ct = default)
    {
        var entity = await db.ProjectResourceAllocationRequests
            .Include(r => r.Project)
            .Include(r => r.Employee)
            .Include(r => r.Department)
            .FirstOrDefaultAsync(r => r.Id == requestId && r.ProjectId == projectId && r.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Allocation request '{requestId}' was not found.");

        var normStatus = (request.Status ?? "").Trim();
        var mappedStatus = normStatus.Equals("Approved", StringComparison.OrdinalIgnoreCase) ? "Approved"
            : normStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase) ? "Rejected"
            : normStatus.Equals("Hold", StringComparison.OrdinalIgnoreCase) ? "Hold"
            : normStatus.Equals("Request Changes", StringComparison.OrdinalIgnoreCase) ? "Request Changes"
            : normStatus;

        var actor = await FindCurrentEmployeeAsync(ct);
        var actorName = actor != null ? $"{actor.FirstName} {actor.LastName}".Trim() : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : "Reporting Manager");

        var allocTaskCode = $"ALLOC-{entity.Id.ToString()[..8].ToUpper()}";
        var candidateName = entity.Employee != null ? $"{entity.Employee.FirstName} {entity.Employee.LastName}".Trim() : "Resource";
        var projectName = entity.Project?.Name ?? "Project";

        entity.Status = mappedStatus;
        entity.ApproverEmployeeId = actor?.Id;
        entity.ApproverName = actorName;
        entity.UpdatedAtUtc = DateTime.UtcNow;

        var nowStr = DateTime.UtcNow.ToString("o");
        var histList = new List<object>();
        if (!string.IsNullOrWhiteSpace(entity.HistoryJson))
        {
            try
            {
                var existingHist = JsonSerializer.Deserialize<List<JsonElement>>(entity.HistoryJson);
                if (existingHist != null)
                {
                    foreach (var h in existingHist) histList.Add(h);
                }
            }
            catch {}
        }
        histList.Add(new
        {
            status = mappedStatus,
            at = nowStr,
            updatedBy = actorName,
            comment = request.Comment ?? $"{mappedStatus} by {actorName}"
        });
        entity.HistoryJson = JsonSerializer.Serialize(histList);

        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            var commentList = new List<object>();
            if (!string.IsNullOrWhiteSpace(entity.CommentsJson))
            {
                try
                {
                    var existingComments = JsonSerializer.Deserialize<List<JsonElement>>(entity.CommentsJson);
                    if (existingComments != null)
                    {
                        foreach (var c in existingComments) commentList.Add(c);
                    }
                }
                catch {}
            }
            commentList.Add(new
            {
                id = Guid.NewGuid().ToString("N"),
                authorId = actor?.Id.ToString() ?? "",
                authorName = actorName,
                text = request.Comment.Trim(),
                at = nowStr
            });
            entity.CommentsJson = JsonSerializer.Serialize(commentList);
        }

        var createdNotifs = new List<ActionNotification>();

        var priorNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == allocTaskCode && n.DeletedAtUtc == null)
            .ToListAsync(ct);
        foreach (var p in priorNotifs)
        {
            p.Status = mappedStatus;
        }

        if (mappedStatus == "Approved")
        {
            var alreadyInTeam = await db.ProjectTeamMembers
                .AnyAsync(m => m.ProjectId == projectId && m.EmployeeId == entity.EmployeeId && m.DeletedAtUtc == null, ct);

            if (!alreadyInTeam)
            {
                var teamMember = new ProjectTeamMember
                {
                    Id = Guid.NewGuid(),
                    ProjectId = projectId,
                    EmployeeId = entity.EmployeeId,
                    DepartmentId = entity.DepartmentId,
                    SubDepartment = entity.SubDepartment,
                    AllocationStartDate = entity.AllocationStartDate,
                    AllocationEndDate = entity.AllocationEndDate,
                    Billability = entity.Billability,
                    IsTeamLead = entity.IsTeamLead,
                    ResourceType = entity.ResourceType,
                    IsShadowTeam = entity.IsShadowTeam,
                    MemberRole = entity.IsShadowTeam ? ProjectMemberRoles.ShadowTeam : ProjectMemberRoles.ProjectTeam
                };
                db.ProjectTeamMembers.Add(teamMember);

                if (entity.IsTeamLead)
                {
                    var project = entity.Project ?? await db.Projects.FindAsync(new object[] { projectId }, ct);
                    if (project != null)
                    {
                        project.TeamLeadId = entity.EmployeeId;
                        project.UpdatedAtUtc = DateTime.UtcNow;
                    }
                }

                TrySyncTeamMemberToOtherDatabase(teamMember);
            }

            var resNotif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = entity.EmployeeId,
                ProjectId = projectId,
                ProjectCode = entity.Project?.ProjectCode,
                ProjectName = projectName,
                Title = $"Resource Allocation Approved: You have been assigned to {projectName}",
                Type = "Resource Allocation Approval",
                Priority = "Low",
                Status = "Approved",
                Unread = true,
                RaisedByEmployeeId = actor?.Id,
                RaisedByName = actorName,
                RelatedTask = allocTaskCode,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        action = $"Allocation approved by {actorName}",
                        date = DateTime.UtcNow.ToString("yyyy-MM-dd"),
                        time = DateTime.UtcNow.ToString("HH:mm:ss"),
                        by = actorName,
                        status = "Approved"
                    }
                })
            };
            db.ActionNotifications.Add(resNotif);
            createdNotifs.Add(resNotif);

            if (entity.RequestedByEmployeeId.HasValue && entity.RequestedByEmployeeId != actor?.Id)
            {
                var reqNotif = new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = entity.RequestedByEmployeeId.Value,
                    ProjectId = projectId,
                    ProjectCode = entity.Project?.ProjectCode,
                    ProjectName = projectName,
                    Title = $"Resource Allocation Approved: {candidateName} for {projectName}",
                    Type = "Resource Allocation Approval",
                    Priority = "Low",
                    Status = "Approved",
                    Unread = true,
                    RaisedByEmployeeId = actor?.Id,
                    RaisedByName = actorName,
                    RelatedTask = allocTaskCode,
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            action = $"Allocation approved by {actorName}",
                            date = DateTime.UtcNow.ToString("yyyy-MM-dd"),
                            time = DateTime.UtcNow.ToString("HH:mm:ss"),
                            by = actorName,
                            status = "Approved"
                        }
                    })
                };
                db.ActionNotifications.Add(reqNotif);
                createdNotifs.Add(reqNotif);
            }
        }
        else
        {
            if (entity.RequestedByEmployeeId.HasValue && entity.RequestedByEmployeeId != actor?.Id)
            {
                var commentSnippet = !string.IsNullOrWhiteSpace(request.Comment) ? $". Remarks: {request.Comment.Trim()}" : "";
                var reqNotif = new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = entity.RequestedByEmployeeId.Value,
                    ProjectId = projectId,
                    ProjectCode = entity.Project?.ProjectCode,
                    ProjectName = projectName,
                    Title = $"Resource Allocation {mappedStatus}: {candidateName} for {projectName}",
                    Type = "Resource Allocation Approval",
                    Priority = "Low",
                    Status = mappedStatus,
                    Unread = true,
                    RaisedByEmployeeId = actor?.Id,
                    RaisedByName = actorName,
                    RelatedTask = allocTaskCode,
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            action = $"Allocation marked {mappedStatus} by {actorName}{commentSnippet}",
                            date = DateTime.UtcNow.ToString("yyyy-MM-dd"),
                            time = DateTime.UtcNow.ToString("HH:mm:ss"),
                            by = actorName,
                            status = mappedStatus
                        }
                    })
                };
                db.ActionNotifications.Add(reqNotif);
                createdNotifs.Add(reqNotif);
            }
        }

        await db.SaveChangesAsync(ct);

        TrySyncNotificationsToOtherDatabase(createdNotifs, allocTaskCode, mappedStatus);
        TrySyncAllocationRequestToOtherDatabase(entity);

        return MapAllocationDto(entity);
    }

    private static ProjectResourceAllocationRequestDto MapAllocationDto(ProjectResourceAllocationRequest r) => new(
        r.Id,
        r.ProjectId,
        r.Project?.Name ?? "Project",
        r.EmployeeId,
        r.Employee != null ? FullName(r.Employee) : "Resource",
        r.Employee?.EmployeeCode,
        r.Employee?.Role,
        r.Department?.Name ?? r.Employee?.Department?.Name,
        r.SubDepartment ?? r.Employee?.SubDepartment,
        r.AllocationStartDate,
        r.AllocationEndDate,
        r.Billability,
        r.ResourceType,
        r.IsTeamLead,
        r.IsShadowTeam,
        r.Status,
        r.RequestedByEmployeeId,
        r.RequestedByName,
        r.ApproverEmployeeId,
        r.ApproverName,
        r.CommentsJson,
        r.HistoryJson,
        r.CreatedAtUtc);

    private async Task<Employee?> FindCurrentEmployeeAsync(CancellationToken ct)
    {
        if (currentUser.UserId is Guid userId)
        {
            var empByUserId = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.UserId == userId && e.DeletedAtUtc == null, ct);
            if (empByUserId != null) return empByUserId;
        }

        if (!string.IsNullOrWhiteSpace(currentUser.Email))
        {
            var normalized = currentUser.Email.Trim().ToLowerInvariant();
            var empByEmail = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e =>
                    e.DeletedAtUtc == null &&
                    ((e.WorkEmail != null && e.WorkEmail.ToLower() == normalized) ||
                     (e.PersonalEmail != null && e.PersonalEmail.ToLower() == normalized)), ct);
            if (empByEmail != null) return empByEmail;
        }

        return null;
    }

    private static void TrySyncAllocationRequestToOtherDatabase(ProjectResourceAllocationRequest req)
    {
        try
        {
            using var conn = new Npgsql.NpgsqlConnection("Host=127.0.0.1;Port=5432;Database=pms_uat;Username=postgres;Password=123;Timeout=2;Include Error Detail=true");
            conn.Open();

            using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                INSERT INTO project.tbl_resource_allocation_requests
                (""Id"", ""ProjectId"", ""EmployeeId"", ""DepartmentId"", ""SubDepartment"", ""AllocationStartDate"", ""AllocationEndDate"", ""Billability"", ""IsTeamLead"", ""ResourceType"", ""IsShadowTeam"", ""Status"", ""RequestedByEmployeeId"", ""RequestedByName"", ""ApproverEmployeeId"", ""ApproverName"", ""CommentsJson"", ""HistoryJson"", ""CreatedAtUtc"", ""UpdatedAtUtc"")
                VALUES (@id, @pid, @eid, @did, @subdept, @sdate, @edate, @bill, @lead, @rtype, @shadow, @stat, @reqid, @reqname, @appid, @appname, @cmts, @hist, @created, @updated)
                ON CONFLICT (""Id"") DO UPDATE SET ""Status"" = EXCLUDED.""Status"", ""ApproverEmployeeId"" = EXCLUDED.""ApproverEmployeeId"", ""ApproverName"" = EXCLUDED.""ApproverName"", ""CommentsJson"" = EXCLUDED.""CommentsJson"", ""HistoryJson"" = EXCLUDED.""HistoryJson"", ""UpdatedAtUtc"" = EXCLUDED.""UpdatedAtUtc"";";

            cmd.Parameters.AddWithValue("id", req.Id);
            cmd.Parameters.AddWithValue("pid", req.ProjectId);
            cmd.Parameters.AddWithValue("eid", req.EmployeeId);
            cmd.Parameters.AddWithValue("did", (object?)req.DepartmentId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("subdept", (object?)req.SubDepartment ?? DBNull.Value);
            cmd.Parameters.AddWithValue("sdate", req.AllocationStartDate.ToDateTime(TimeOnly.MinValue));
            cmd.Parameters.AddWithValue("edate", req.AllocationEndDate.ToDateTime(TimeOnly.MinValue));
            cmd.Parameters.AddWithValue("bill", req.Billability);
            cmd.Parameters.AddWithValue("lead", req.IsTeamLead);
            cmd.Parameters.AddWithValue("rtype", req.ResourceType);
            cmd.Parameters.AddWithValue("shadow", req.IsShadowTeam);
            cmd.Parameters.AddWithValue("stat", req.Status);
            cmd.Parameters.AddWithValue("reqid", (object?)req.RequestedByEmployeeId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reqname", (object?)req.RequestedByName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("appid", (object?)req.ApproverEmployeeId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("appname", (object?)req.ApproverName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("cmts", (object?)req.CommentsJson ?? DBNull.Value);
            cmd.Parameters.AddWithValue("hist", (object?)req.HistoryJson ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created", req.CreatedAtUtc);
            cmd.Parameters.AddWithValue("updated", (object?)req.UpdatedAtUtc ?? DBNull.Value);
            cmd.ExecuteNonQuery();
        }
        catch
        {
            // Best effort
        }
    }

    private static void TrySyncTeamMemberToOtherDatabase(ProjectTeamMember m)
    {
        try
        {
            using var conn = new Npgsql.NpgsqlConnection("Host=127.0.0.1;Port=5432;Database=pms_uat;Username=postgres;Password=123;Timeout=2;Include Error Detail=true");
            conn.Open();

            using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                INSERT INTO project.tbl_project_team_members
                (""Id"", ""ProjectId"", ""EmployeeId"", ""DepartmentId"", ""SubDepartment"", ""AllocationStartDate"", ""AllocationEndDate"", ""Billability"", ""IsTeamLead"", ""ResourceType"", ""IsShadowTeam"", ""MemberRole"", ""CreatedAtUtc"")
                VALUES (@id, @pid, @eid, @did, @subdept, @sdate, @edate, @bill, @lead, @rtype, @shadow, @role, @created)
                ON CONFLICT (""Id"") DO NOTHING;";

            cmd.Parameters.AddWithValue("id", m.Id);
            cmd.Parameters.AddWithValue("pid", m.ProjectId);
            cmd.Parameters.AddWithValue("eid", m.EmployeeId);
            cmd.Parameters.AddWithValue("did", (object?)m.DepartmentId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("subdept", (object?)m.SubDepartment ?? DBNull.Value);
            cmd.Parameters.AddWithValue("sdate", m.AllocationStartDate.ToDateTime(TimeOnly.MinValue));
            cmd.Parameters.AddWithValue("edate", m.AllocationEndDate.ToDateTime(TimeOnly.MinValue));
            cmd.Parameters.AddWithValue("bill", m.Billability);
            cmd.Parameters.AddWithValue("lead", m.IsTeamLead);
            cmd.Parameters.AddWithValue("rtype", m.ResourceType);
            cmd.Parameters.AddWithValue("shadow", m.IsShadowTeam);
            cmd.Parameters.AddWithValue("role", m.MemberRole);
            cmd.Parameters.AddWithValue("created", m.CreatedAtUtc);
            cmd.ExecuteNonQuery();
        }
        catch
        {
            // Best effort
        }
    }

    private static void TrySyncNotificationsToOtherDatabase(
        IReadOnlyList<ActionNotification> notifications,
        string? relatedTask = null,
        string? newStatus = null)
    {
        try
        {
            using var conn = new Npgsql.NpgsqlConnection("Host=127.0.0.1;Port=5432;Database=pms_uat;Username=postgres;Password=123;Timeout=2;Include Error Detail=true");
            conn.Open();

            if (!string.IsNullOrWhiteSpace(relatedTask) && !string.IsNullOrWhiteSpace(newStatus))
            {
                using var updateCmd = conn.CreateCommand();
                updateCmd.CommandText = "UPDATE action.tbl_notifications SET \"Status\" = @stat WHERE \"RelatedTask\" = @task AND \"DeletedAtUtc\" IS NULL";
                updateCmd.Parameters.AddWithValue("stat", newStatus);
                updateCmd.Parameters.AddWithValue("task", relatedTask);
                updateCmd.ExecuteNonQuery();
            }

            foreach (var n in notifications)
            {
                using var cmd = conn.CreateCommand();
                cmd.CommandText = @"
                    INSERT INTO action.tbl_notifications 
                    (""Id"", ""RecipientEmployeeId"", ""ProjectId"", ""ProjectCode"", ""ProjectName"", ""Title"", ""Type"", ""Priority"", ""Status"", ""Unread"", ""RaisedByName"", ""RelatedTask"", ""HistoryJson"", ""CreatedAtUtc"")
                    VALUES (@id, @recip, @pid, @pcode, @pname, @title, @type, @pri, @stat, @unread, @raised, @task, @hist, @created)
                    ON CONFLICT (""Id"") DO UPDATE SET ""Status"" = EXCLUDED.""Status"", ""HistoryJson"" = EXCLUDED.""HistoryJson"";";

                cmd.Parameters.AddWithValue("id", n.Id);
                cmd.Parameters.AddWithValue("recip", n.RecipientEmployeeId);
                cmd.Parameters.AddWithValue("pid", (object?)n.ProjectId ?? DBNull.Value);
                cmd.Parameters.AddWithValue("pcode", (object?)n.ProjectCode ?? DBNull.Value);
                cmd.Parameters.AddWithValue("pname", (object?)n.ProjectName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("title", n.Title);
                cmd.Parameters.AddWithValue("type", n.Type);
                cmd.Parameters.AddWithValue("pri", n.Priority);
                cmd.Parameters.AddWithValue("stat", n.Status);
                cmd.Parameters.AddWithValue("unread", n.Unread);
                cmd.Parameters.AddWithValue("raised", (object?)n.RaisedByName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("task", (object?)n.RelatedTask ?? DBNull.Value);
                cmd.Parameters.AddWithValue("hist", n.HistoryJson);
                cmd.Parameters.AddWithValue("created", n.CreatedAtUtc);
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
            // Best effort
        }
    }

    public async Task<EmployeeWorkloadDto> GetEmployeeWorkloadAsync(Guid employeeId, CancellationToken ct = default)
    {
        var emp = await db.Employees
            .AsNoTracking()
            .Include(e => e.Designation)
            .Include(e => e.Department)
            .FirstOrDefaultAsync(e => e.Id == employeeId && e.DeletedAtUtc == null, ct);

        var employeeName = emp is null ? "Unknown Resource" : FullName(emp);
        var employeeCode = emp?.EmployeeCode;
        var role = emp?.Designation?.Name ?? emp?.Department?.Name ?? "Team Member";
        var email = emp?.WorkEmail;

        // 1. Assigned Tasks from tbl_project_task_assignments
        var taskAssignments = await db.ProjectTaskAssignments
            .AsNoTracking()
            .Include(a => a.Task)
                .ThenInclude(t => t!.Project)
            .Where(a => a.EmployeeId == employeeId && a.IsActive && a.DeletedAtUtc == null && a.Task != null && a.Task.DeletedAtUtc == null)
            .ToListAsync(ct);

        // 2. Assigned Tasks from tbl_bucket_tasks
        var bucketTasks = await db.BucketTasks
            .AsNoTracking()
            .Where(b => b.EmployeeId == employeeId && b.DeletedAtUtc == null)
            .ToListAsync(ct);

        var tasks = new List<EmployeeAssignedTaskDto>();
        var seenTaskIds = new HashSet<Guid>();

        foreach (var a in taskAssignments)
        {
            if (a.Task == null || seenTaskIds.Contains(a.TaskId)) continue;
            seenTaskIds.Add(a.TaskId);
            tasks.Add(new EmployeeAssignedTaskDto(
                a.TaskId,
                a.Task.Title,
                a.Task.ProjectId,
                a.Task.Project?.Name ?? "Project",
                a.Task.Stage ?? "Ready to Start",
                a.Task.Progress,
                a.Task.Priority ?? "Medium",
                a.Role,
                a.Task.PlannedStartDate,
                a.Task.PlannedEndDate,
                a.Task.PlannedEndDate
            ));
        }

        foreach (var b in bucketTasks)
        {
            if (seenTaskIds.Contains(b.TaskId)) continue;
            seenTaskIds.Add(b.TaskId);
            tasks.Add(new EmployeeAssignedTaskDto(
                b.TaskId,
                b.TaskTitle,
                b.ProjectId,
                b.ProjectName,
                b.Status ?? "Ready to Start",
                string.Equals(b.Status, "Completed", StringComparison.OrdinalIgnoreCase) ? 100 : 0,
                b.Priority ?? "Medium",
                "Assigned",
                b.ActualStartDate,
                b.DueDate,
                b.DueDate
            ));
        }

        // 3. Assigned Projects from tbl_project_team_members
        var teamMemberships = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(m => m.Project)
            .Where(m => m.EmployeeId == employeeId && m.DeletedAtUtc == null && m.Project != null && m.Project.DeletedAtUtc == null)
            .OrderBy(m => m.AllocationStartDate)
            .ToListAsync(ct);

        // 4. Assigned Projects from tbl_projects (PM, SPM, TL)
        var leadershipProjects = await db.Projects
            .AsNoTracking()
            .Where(p => (p.ProjectManagerId == employeeId || p.TeamLeadId == employeeId) && p.DeletedAtUtc == null)
            .ToListAsync(ct);

        var projectsList = new List<EmployeeAssignedProjectDto>();
        var seenProjectKeys = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var m in teamMemberships)
        {
            if (m.Project == null) continue;
            var projectRole = m.IsTeamLead ? "Team Lead" : (m.MemberRole ?? "Team Member");
            var key = $"{m.ProjectId}-{projectRole}";
            if (seenProjectKeys.Contains(key)) continue;
            seenProjectKeys.Add(key);

            projectsList.Add(new EmployeeAssignedProjectDto(
                m.ProjectId,
                m.Project.Name,
                m.Project.Status,
                projectRole,
                m.AllocationStartDate,
                m.AllocationEndDate,
                m.Billability,
                m.ResourceType
            ));
        }

        foreach (var lp in leadershipProjects)
        {
            if (lp.ProjectManagerId == employeeId)
            {
                var key = $"{lp.Id}-Project Manager";
                if (!seenProjectKeys.Contains(key))
                {
                    seenProjectKeys.Add(key);
                    projectsList.Add(new EmployeeAssignedProjectDto(
                        lp.Id,
                        lp.Name,
                        lp.Status,
                        "Project Manager",
                        lp.StartDate,
                        lp.EndDate,
                        "Billable",
                        "Dedicated"
                    ));
                }
            }

            if (lp.TeamLeadId == employeeId)
            {
                var key = $"{lp.Id}-Team Lead";
                if (!seenProjectKeys.Contains(key))
                {
                    seenProjectKeys.Add(key);
                    projectsList.Add(new EmployeeAssignedProjectDto(
                        lp.Id,
                        lp.Name,
                        lp.Status,
                        "Team Lead",
                        lp.StartDate,
                        lp.EndDate,
                        "Billable",
                        "Dedicated"
                    ));
                }
            }
        }

        return new EmployeeWorkloadDto(
            employeeId,
            employeeName,
            employeeCode,
            role,
            email,
            tasks,
            projectsList
        );
    }

}
