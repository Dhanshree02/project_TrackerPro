using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using System.Text.Json;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Sla.DTOs;
using PMS.API.Modules.Sla.Models;
using PMS.API.Modules.Sla.Services;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectServiceEscalationService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IFileStorageService storage,
    ISlaTrackingService slaTrackingService,
    ILogger<ProjectServiceEscalationService> logger) : IProjectServiceEscalationService
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

        var alerts = await db.ProjectAlerts
            .AsNoTracking()
            .Where(a => a.ProjectId == projectId && a.DeletedAtUtc == null)
            .ToListAsync(ct);

        var alertMap = alerts
            .Where(a => a.ServiceEscalationId != null)
            .GroupBy(a => a.ServiceEscalationId!.Value)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.UpdatedAtUtc ?? x.CreatedAtUtc).First());

        var result = rows.Select(r =>
        {
            alertMap.TryGetValue(r.Id, out var linkedAlert);
            var status = linkedAlert != null && !string.IsNullOrWhiteSpace(linkedAlert.Status) ? linkedAlert.Status : r.Status;
            var changedBy = linkedAlert?.StatusChangedBy ?? linkedAlert?.ResolutionOwner;
            var changedAt = linkedAlert?.StatusChangedAtUtc ?? (status != "Open" ? (linkedAlert?.UpdatedAtUtc ?? r.UpdatedAtUtc) : null);
            var chatJson = !string.IsNullOrWhiteSpace(r.ChatJson) ? r.ChatJson : linkedAlert?.ChatJson;
            var resDetails = linkedAlert?.ResolutionDetails;
            return Map(r, status, changedBy, changedAt, chatJson, resDetails);
        }).ToList();

        // Check for any ProjectIssues that do not already have a ProjectServiceEscalation row
        var existingEscalationIds = new HashSet<Guid>(rows.Select(r => r.Id));
        var issues = await db.ProjectIssues
            .AsNoTracking()
            .Where(x => x.ProjectId == projectId && x.DeletedAtUtc == null)
            .ToListAsync(ct);

        var issueAlertMap = alerts
            .Where(a => a.IssueId != null)
            .GroupBy(a => a.IssueId!.Value)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(x => x.UpdatedAtUtc ?? x.CreatedAtUtc).First());

        foreach (var issue in issues)
        {
            issueAlertMap.TryGetValue(issue.Id, out var linkedAlert);
            if (linkedAlert?.ServiceEscalationId != null && existingEscalationIds.Contains(linkedAlert.ServiceEscalationId.Value))
            {
                continue;
            }
            if (existingEscalationIds.Contains(issue.Id))
            {
                continue;
            }

            var status = linkedAlert != null && !string.IsNullOrWhiteSpace(linkedAlert.Status) ? linkedAlert.Status : issue.Status;
            var changedBy = linkedAlert?.StatusChangedBy ?? linkedAlert?.ResolutionOwner;
            var changedAt = linkedAlert?.StatusChangedAtUtc ?? (status != "Open" ? (linkedAlert?.UpdatedAtUtc ?? issue.UpdatedAtUtc) : null);
            var chatJson = linkedAlert?.ChatJson;

            result.Add(new ProjectServiceEscalationDto(
                issue.Id,
                issue.ProjectId,
                null,
                issue.ProjectCode,
                issue.ProjectName,
                null,
                !string.IsNullOrWhiteSpace(issue.IssueType) ? issue.IssueType : "Technical Related Issues",
                !string.IsNullOrWhiteSpace(issue.IssueType) ? issue.IssueType : "Issue",
                issue.Priority,
                issue.Subject,
                issue.Description,
                null,
                null,
                null,
                status,
                issue.RaisedByName,
                issue.CreatedAtUtc,
                Array.Empty<ServiceEscalationStakeholderDto>(),
                changedBy,
                changedAt,
                chatJson,
                null));
        }

        return result.OrderByDescending(x => x.CreatedAtUtc).ToList();
    }

    public async Task<(Stream Stream, string ContentType, string FileName)?> DownloadAttachmentAsync(
        Guid projectId,
        Guid escalationId,
        CancellationToken ct = default)
    {
        var esc = await db.ProjectServiceEscalations
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == escalationId && e.ProjectId == projectId, ct);
        if (esc == null || string.IsNullOrWhiteSpace(esc.AttachmentPath)) return null;

        var fileResult = storage.GetProjectFileStream(esc.AttachmentPath);
        if (fileResult == null) return null;

        return (fileResult.Value.Stream, fileResult.Value.ContentType, esc.AttachmentFileName ?? Path.GetFileName(esc.AttachmentPath));
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

        string? attachmentName = null;
        string? attachmentPath = null;
        string? attachmentType = null;
        long? attachmentSize = null;
        StoredRepositoryFileInfo? stored = null;
        if (request.File is { Length: > 0 })
        {
            if (request.File.Length > 20 * 1024 * 1024)
                throw new ConflictException("Attachment must be 20 MB or smaller.");
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

        if (stored != null)
        {
            var projDoc = new ProjectDocument
            {
                ProjectId = projectId,
                DocumentType = "Escalation",
                FileName = stored.FileName,
                OriginalFileName = stored.OriginalFileName,
                FilePath = stored.RelativePath,
                ContentType = stored.ContentType,
                SizeBytes = stored.SizeBytes,
                Description = $"Escalation attachment for {serviceName}: {subject}"
            };
            db.ProjectDocuments.Add(projDoc);
        }

        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");
        var defaultHistoryJson = JsonSerializer.Serialize(new[]
        {
            new
            {
                action = "Notification created",
                date = dateStr,
                time = timeStr,
                by = row.RaisedByName
            }
        });

        var notifTitle = $"WBS Escalation: {serviceName} - {subject}";
        if (notifTitle.Length > 255) notifTitle = notifTitle[..255];
        var relatedTask = serviceName.Length > 255 ? serviceName[..255] : serviceName;

        foreach (var stakeholder in people)
        {
            db.ActionNotifications.Add(new ActionNotification
            {
                RecipientEmployeeId = stakeholder.Id,
                ProjectId = projectId,
                ProjectCode = row.ProjectCode,
                ProjectName = row.ProjectName,
                Title = notifTitle,
                Type = "WBS Escalation",
                Priority = priority,
                Status = "Pending",
                Unread = true,
                RaisedByEmployeeId = raiser?.Id,
                RaisedByName = row.RaisedByName,
                RelatedTask = relatedTask,
                ServiceEscalationId = row.Id,
                HistoryJson = defaultHistoryJson,
                CreatedAtUtc = now
            });
        }

        var stakeholderIdStrings = people.Select(p => p.Id.ToString()).ToList();
        var stakeholderNames = people.Select(p => $"{p.FirstName} {p.LastName}".Trim()).ToList();
        var alertTitle = $"WBS Escalation: {serviceName} - {subject}";
        if (alertTitle.Length > 255) alertTitle = alertTitle[..255];
        var expDateStr = request.ExpectedResolutionDate?.ToString("yyyy-MM-dd");

        var alert = new ProjectAlert
        {
            ProjectId = projectId,
            Title = alertTitle,
            Description = $"{escalationType}: {description}",
            AlertType = "WBS Escalation",
            Priority = priority,
            Status = "Open",
            Owner = row.RaisedByName,
            RaisedByEmployeeId = raiser?.Id,
            RaisedByName = row.RaisedByName,
            AudienceUserIds = JsonSerializer.Serialize(stakeholderIdStrings),
            HistoryJson = defaultHistoryJson,
            CreatedAtUtc = now,
            ServiceName = serviceName,
            EscalationType = escalationType,
            ExpectedResolutionDate = expDateStr,
            AttachmentFileName = stored?.OriginalFileName,
            AttachmentPath = stored?.RelativePath,
            EscalatedTo = JsonSerializer.Serialize(stakeholderNames),
            ServiceEscalationId = row.Id,
            ResolutionDetails = !string.IsNullOrWhiteSpace(expDateStr)
                ? $"Expected Resolution Date: {expDateStr}"
                : null
        };
        db.ProjectAlerts.Add(alert);

        await db.SaveChangesAsync(ct);

        // Start centralized TAT/SLA tracking for the WBS Escalation workflow (EOD of next 2 working days)
        try
        {
            var slaPriority = priority.ToLowerInvariant() switch
            {
                "low" => SlaPriority.Low,
                "high" => SlaPriority.High,
                "critical" => SlaPriority.Critical,
                _ => SlaPriority.Medium
            };

            await slaTrackingService.StartTrackingAsync(new SlaStartTrackingRequest(
                Module: "Projects",
                ActivityType: "WBS Escalation",
                EntityId: row.Id,
                EntityReference: $"WBS-{row.ServiceName}-{row.Subject}",
                Stage: "Open",
                Priority: slaPriority,
                RecipientEmployeeId: null,
                ProjectId: projectId,
                CustomPayloadJson: JsonSerializer.Serialize(new
                {
                    serviceEscalationId = row.Id,
                    alertId = alert.Id,
                    serviceName = row.ServiceName,
                    subject = row.Subject,
                    raisedBy = row.RaisedByName
                }),
                CustomStartTimeUtc: row.CreatedAtUtc
            ), ct);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "[WBS Escalation] Failed to start SLA tracking for Escalation {EscalationId}", row.Id);
        }

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

    private static ProjectServiceEscalationDto Map(
        ProjectServiceEscalation row,
        string? statusOverride = null,
        string? statusChangedBy = null,
        DateTime? statusChangedAtUtc = null,
        string? chatJsonOverride = null,
        string? resolutionDetails = null) => new(
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
        statusOverride ?? row.Status,
        row.RaisedByName,
        row.CreatedAtUtc,
        row.Stakeholders
            .OrderBy(s => s.EmployeeName)
            .Select(s => new ServiceEscalationStakeholderDto(s.EmployeeId, s.EmployeeName, null, s.SubDepartment, s.Status))
            .ToList(),
        statusChangedBy,
        statusChangedAtUtc,
        chatJsonOverride ?? row.ChatJson,
        resolutionDetails);
}
