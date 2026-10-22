using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectServiceEscalationService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IFileStorageService storage) : IProjectServiceEscalationService
{
    public const string PmoSubDepartment = "PMO (Project Management Office)";
    public const string EmSubDepartment = "EM (Engagement Manager)";

    private static readonly string[] EscalationTypes =
    [
        "Prerequisite Pending",
        "Customer Dependency",
        "Billing Issue",
        "Technical Blocker",
        "Resource Blocker",
        "Approval Pending",
        "Infrastructure Issue",
        "Requirement Clarification",
        "Timeline Risk",
        "Other",
    ];

    private static readonly string[] Priorities = ["Low", "Medium", "High", "Critical"];

    public async Task<IReadOnlyList<ServiceEscalationStakeholderDto>> ListStakeholdersAsync(CancellationToken ct = default)
    {
        var people = await StakeholderQuery().OrderBy(e => e.SubDepartment).ThenBy(e => e.FirstName).ThenBy(e => e.LastName).ToListAsync(ct);
        return people.Select(e => ToStakeholder(e, "Pending")).ToList();
    }

    public async Task<IReadOnlyList<ProjectServiceEscalationDto>> ListAsync(Guid projectId, CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);
        var rows = await db.ProjectServiceEscalations
            .AsNoTracking()
            .Include(x => x.Stakeholders)
            .Where(x => x.ProjectId == projectId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);
        return rows.Select(Map).ToList();
    }

    public async Task<ProjectServiceEscalationDto> CreateAsync(
        Guid projectId,
        CreateProjectServiceEscalationForm request,
        CancellationToken ct = default)
    {
        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project '{projectId}' was not found.");

        var serviceName = request.ServiceName?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(serviceName))
            throw new ConflictException("Service name is required.");

        var escalationType = request.EscalationType?.Trim() ?? "";
        if (!EscalationTypes.Contains(escalationType))
            throw new ConflictException("Select an escalation type.");

        var priority = request.Priority?.Trim() ?? "";
        if (!Priorities.Contains(priority))
            throw new ConflictException("Priority must be Low, Medium, High, or Critical.");

        var subject = request.Subject?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(subject))
            throw new ConflictException("Subject is required.");

        var description = request.Description?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(description))
            throw new ConflictException("Description is required.");

        if (request.ProjectServiceId is Guid serviceId)
        {
            var ownsService = await db.ProjectServices.AnyAsync(s => s.Id == serviceId && s.ProjectId == projectId, ct);
            if (!ownsService)
                throw new ConflictException("Select a service on this project.");
        }

        var wanted = (request.StakeholderIds ?? []).Where(id => id != Guid.Empty).Distinct().ToList();
        if (wanted.Count == 0)
            throw new ConflictException("Select at least one stakeholder.");

        var people = await StakeholderQuery().Where(e => wanted.Contains(e.Id)).ToListAsync(ct);
        if (people.Count != wanted.Count)
            throw new ConflictException("Stakeholders must be employees in PMO (Project Management Office) or EM (Engagement Manager).");

        var alreadyOpen = await db.ProjectServiceEscalations.AnyAsync(x =>
            x.ProjectId == projectId
            && x.Status == "Open"
            && (request.ProjectServiceId != null
                ? x.ProjectServiceId == request.ProjectServiceId
                : x.ServiceName == serviceName), ct);
        if (alreadyOpen)
            throw new ConflictException("This service already has an open escalation.");

        string? attachmentName = null;
        string? attachmentPath = null;
        string? attachmentType = null;
        long? attachmentSize = null;
        if (request.File is { Length: > 0 })
        {
            if (request.File.Length > 20 * 1024 * 1024)
                throw new ConflictException("Attachment must be 20 MB or smaller.");
            StoredRepositoryFileInfo stored;
            try
            {
                stored = await storage.SaveEscalationDocumentAsync(project.ProjectCode, request.File, ct);
            }
            catch (InvalidOperationException ex)
            {
                throw new ConflictException(ex.Message);
            }
            attachmentName = stored.OriginalFileName;
            attachmentPath = stored.RelativePath;
            attachmentType = stored.ContentType;
            attachmentSize = stored.SizeBytes;
        }

        var raiser = await FindRaiserAsync(ct);
        var raiserName = raiser is null
            ? (currentUser.Name ?? currentUser.Email ?? "User")
            : $"{raiser.FirstName} {raiser.LastName}".Trim();

        var row = new ProjectServiceEscalation
        {
            ProjectId = projectId,
            ProjectServiceId = request.ProjectServiceId,
            ProjectCode = string.IsNullOrWhiteSpace(project.ProjectCode) ? request.ProjectCode?.Trim() : project.ProjectCode,
            ProjectName = project.Name,
            CustomerName = project.Client?.Name ?? request.CustomerName?.Trim(),
            ServiceName = serviceName,
            EscalationType = escalationType,
            Priority = priority,
            Subject = subject,
            Description = description,
            ExpectedResolutionDate = request.ExpectedResolutionDate,
            AttachmentFileName = attachmentName,
            AttachmentPath = attachmentPath,
            AttachmentContentType = attachmentType,
            AttachmentSizeBytes = attachmentSize,
            Status = "Open",
            RaisedByEmployeeId = raiser?.Id,
            RaisedByName = string.IsNullOrWhiteSpace(raiserName) ? "User" : raiserName,
            Stakeholders = people
                .OrderBy(e => e.FirstName)
                .ThenBy(e => e.LastName)
                .Select(e => new ProjectServiceEscalationStakeholder
                {
                    EmployeeId = e.Id,
                    EmployeeName = $"{e.FirstName} {e.LastName}".Trim(),
                    SubDepartment = e.SubDepartment?.Trim() ?? "",
                    Status = "Pending",
                })
                .ToList(),
        };

        db.ProjectServiceEscalations.Add(row);
        await db.SaveChangesAsync(ct);
        return Map(row);
    }

    private IQueryable<Employee> StakeholderQuery()
    {
        var pmo = PmoSubDepartment.ToLowerInvariant();
        var em = EmSubDepartment.ToLowerInvariant();
        return db.Employees.AsNoTracking().Where(e =>
            ((e.SubDepartment != null && (e.SubDepartment.Trim().ToLower() == pmo || e.SubDepartment.Trim().ToLower() == em))
             || (e.SubDepartmentRef != null && (e.SubDepartmentRef.Name.Trim().ToLower() == pmo || e.SubDepartmentRef.Name.Trim().ToLower() == em)))
            && (e.Status == null || e.Status.ToLower().StartsWith("active")));
    }

    private async Task<Employee?> FindRaiserAsync(CancellationToken ct)
    {
        if (currentUser.UserId is Guid userId)
        {
            var byId = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == userId, ct);
            if (byId is not null) return byId;
        }

        var email = currentUser.Email?.Trim().ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(email)) return null;
        return await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.WorkEmail.ToLower() == email, ct);
    }

    private async Task EnsureProjectExistsAsync(Guid projectId, CancellationToken ct)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists) throw new NotFoundException($"Project '{projectId}' was not found.");
    }

    private static ServiceEscalationStakeholderDto ToStakeholder(Employee employee, string status) => new(
        employee.Id,
        $"{employee.FirstName} {employee.LastName}".Trim(),
        employee.EmployeeCode,
        employee.SubDepartment?.Trim() ?? "",
        status);

    private static ProjectServiceEscalationDto Map(ProjectServiceEscalation row) => new(
        row.Id,
        row.ProjectId,
        row.ProjectServiceId,
        row.ProjectCode,
        row.ProjectName,
        row.CustomerName,
        row.ServiceName,
        row.EscalationType,
        row.Priority,
        row.Subject,
        row.Description,
        row.ExpectedResolutionDate,
        row.AttachmentFileName,
        row.AttachmentPath,
        row.Status,
        row.RaisedByName,
        row.CreatedAtUtc,
        row.Stakeholders
            .OrderBy(s => s.EmployeeName)
            .Select(s => new ServiceEscalationStakeholderDto(s.EmployeeId, s.EmployeeName, null, s.SubDepartment, s.Status))
            .ToList());
}
