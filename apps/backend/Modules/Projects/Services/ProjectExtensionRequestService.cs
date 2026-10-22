using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectExtensionRequestService(AppDbContext db, ICurrentUserService currentUser) : IProjectExtensionRequestService
{
    public const string PmoSubDepartment = "PMO (Project Management Office)";

    public async Task<IReadOnlyList<ExtensionApproverDto>> ListApproversAsync(CancellationToken ct = default)
    {
        var people = await PmoEmployeesQuery().OrderBy(e => e.FirstName).ThenBy(e => e.LastName).ToListAsync(ct);
        return people.Select(e => ToApprover(e, "Pending")).ToList();
    }

    public async Task<IReadOnlyList<ProjectExtensionRequestDto>> ListAsync(Guid projectId, CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);

        var rows = await db.ProjectExtensionRequests
            .AsNoTracking()
            .Include(x => x.Approvers)
            .Where(x => x.ProjectId == projectId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return rows.Select(Map).ToList();
    }

    public async Task<ProjectExtensionRequestDto> CreateAsync(
        Guid projectId,
        CreateProjectExtensionRequest request,
        CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project '{projectId}' was not found.");

        if (project.EndDate is not DateOnly currentEnd)
        {
            throw new ConflictException("This project does not have an end date yet.");
        }

        if (request.RequestedEndDate <= currentEnd)
        {
            throw new ConflictException("Requested new end date must be after the current end date.");
        }

        var wanted = request.ApproverEmployeeIds.Where(id => id != Guid.Empty).Distinct().ToList();
        var people = await PmoEmployeesQuery().Where(e => wanted.Contains(e.Id)).ToListAsync(ct);
        if (people.Count != wanted.Count)
        {
            throw new ConflictException("Approvers must be employees in PMO (Project Management Office).");
        }

        var requester = await FindRequesterAsync(ct);
        var requesterName = requester is null
            ? (currentUser.Name ?? currentUser.Email ?? "User")
            : $"{requester.FirstName} {requester.LastName}".Trim();

        var row = new ProjectExtensionRequest
        {
            ProjectId = projectId,
            CurrentEndDate = currentEnd,
            RequestedEndDate = request.RequestedEndDate,
            ExtensionDays = request.RequestedEndDate.DayNumber - currentEnd.DayNumber,
            Reason = request.Reason.Trim(),
            Status = "Pending",
            RequestedByEmployeeId = requester?.Id,
            RequestedByName = string.IsNullOrWhiteSpace(requesterName) ? "User" : requesterName,
            Approvers = people
                .OrderBy(e => e.FirstName)
                .ThenBy(e => e.LastName)
                .Select(e => new ProjectExtensionApprover
                {
                    EmployeeId = e.Id,
                    EmployeeName = $"{e.FirstName} {e.LastName}".Trim(),
                    Status = "Pending",
                })
                .ToList(),
        };

        db.ProjectExtensionRequests.Add(row);
        await db.SaveChangesAsync(ct);
        return Map(row);
    }

    private IQueryable<Employee> PmoEmployeesQuery()
    {
        var key = PmoSubDepartment.ToLowerInvariant();
        return db.Employees.AsNoTracking().Where(e =>
            ((e.SubDepartment != null && e.SubDepartment.Trim().ToLower() == key)
             || (e.SubDepartmentRef != null && e.SubDepartmentRef.Name.Trim().ToLower() == key))
            && (e.Status == null || e.Status.ToLower().StartsWith("active")));
    }

    private async Task<Employee?> FindRequesterAsync(CancellationToken ct)
    {
        if (currentUser.UserId is Guid userId)
        {
            var byId = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == userId, ct);
            if (byId is not null) return byId;
        }

        var email = currentUser.Email?.Trim().ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(email)) return null;
        return await db.Employees.AsNoTracking()
            .FirstOrDefaultAsync(e => e.WorkEmail.ToLower() == email, ct);
    }

    private async Task EnsureProjectExistsAsync(Guid projectId, CancellationToken ct)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists)
        {
            throw new NotFoundException($"Project '{projectId}' was not found.");
        }
    }

    private static ExtensionApproverDto ToApprover(Employee employee, string status) => new(
        employee.Id,
        $"{employee.FirstName} {employee.LastName}".Trim(),
        employee.EmployeeCode,
        employee.SubDepartment?.Trim() ?? PmoSubDepartment,
        status);

    private static ProjectExtensionRequestDto Map(ProjectExtensionRequest row) => new(
        row.Id,
        row.ProjectId,
        row.CurrentEndDate,
        row.RequestedEndDate,
        row.ExtensionDays,
        row.Reason,
        row.Status,
        row.RequestedByName,
        row.CreatedAtUtc,
        row.Approvers
            .OrderBy(a => a.EmployeeName)
            .Select(a => new ExtensionApproverDto(a.EmployeeId, a.EmployeeName, null, PmoSubDepartment, a.Status))
            .ToList());
}
