using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectAdditionalRequirementService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IFileStorageService storage,
    ILogger<ProjectAdditionalRequirementService> logger) : IProjectAdditionalRequirementService
{
    public async Task<ProjectAdditionalRequirementDto> CreateAsync(
        Guid projectId,
        CreateProjectAdditionalRequirementRequest request,
        IFormFile? file,
        CancellationToken ct = default)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Project with id {projectId} not found.");

        if (string.IsNullOrWhiteSpace(request.Title))
            throw new ConflictException("Requirement title is required.");

        if (string.IsNullOrWhiteSpace(request.Description))
            throw new ConflictException("Requirement description is required.");

        var creator = await FindCurrentUserEmployeeAsync(ct);
        var requestedByName = !string.IsNullOrWhiteSpace(creator?.FirstName)
            ? $"{creator.FirstName} {creator.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name.Trim() : "System");
        var requestedByEmployeeId = creator?.Id;

        DateOnly requestedDate;
        if (!string.IsNullOrWhiteSpace(request.RequestedDate) && DateOnly.TryParse(request.RequestedDate, out var parsedDate))
        {
            requestedDate = parsedDate;
        }
        else
        {
            requestedDate = DateOnly.FromDateTime(DateTime.UtcNow);
        }

        string? attachmentFileName = null;
        string? attachmentPath = null;

        if (file != null && file.Length > 0)
        {
            var stored = await storage.SaveCustomerRequirementDocumentAsync(project.ProjectCode, file, ct);
            attachmentFileName = stored.FileName;
            attachmentPath = stored.RelativePath;
        }

        var reqId = $"REQ-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString("N")[..4].ToUpperInvariant()}";
        var isCancellation = string.Equals(request.RequirementType, "Scope Cancellation", StringComparison.OrdinalIgnoreCase);

        var finalTitle = request.Title.Trim();
        if (isCancellation && !string.IsNullOrWhiteSpace(request.ScopeCancellationService))
        {
            if (!finalTitle.StartsWith("Scope Cancellation", StringComparison.OrdinalIgnoreCase))
            {
                finalTitle = $"Scope Cancellation: {request.ScopeCancellationService.Trim()}";
            }
        }

        var initialHistory = new[]
        {
            new
            {
                status = "Open",
                at = DateTime.UtcNow.ToString("o"),
                updatedBy = requestedByName,
                details = $"Additional customer requirement logged for {project.Name}"
            }
        };

        var requirement = new ProjectAdditionalRequirement
        {
            Id = Guid.NewGuid(),
            RequirementId = reqId,
            ProjectId = project.Id,
            ClientName = project.Client?.Name ?? string.Empty,
            ProjectName = project.Name,
            RequirementType = isCancellation ? "Scope Cancellation" : "Add Service",
            Title = finalTitle,
            Description = request.Description.Trim(),
            Priority = string.IsNullOrWhiteSpace(request.Priority) ? "Medium" : request.Priority.Trim(),
            RequestedByEmployeeId = requestedByEmployeeId,
            RequestedByName = requestedByName,
            RequestedDate = requestedDate,
            AttachmentFileName = attachmentFileName,
            AttachmentPath = attachmentPath,
            ScopeCancellationService = isCancellation ? request.ScopeCancellationService?.Trim() : null,
            Status = "Open",
            CommentsJson = "[]",
            HistoryJson = JsonSerializer.Serialize(initialHistory)
        };

        db.ProjectAdditionalRequirements.Add(requirement);

        // ── Identify Leadership Stakeholders ──
        var salesPerson = await ResolveSalesPersonAsync(project, ct);
        var projectManager = await ResolveProjectManagerAsync(project, ct);
        var seniorProjectManager = await ResolveSeniorProjectManagerAsync(project, ct);
        var engagementManager = await ResolveEngagementManagerAsync(project, ct);

        // All 4 get "notification only"
        var notifyRecipients = new List<Employee>();
        if (salesPerson != null) notifyRecipients.Add(salesPerson);
        if (projectManager != null && !notifyRecipients.Any(r => r.Id == projectManager.Id)) notifyRecipients.Add(projectManager);
        if (seniorProjectManager != null && !notifyRecipients.Any(r => r.Id == seniorProjectManager.Id)) notifyRecipients.Add(seniorProjectManager);
        if (engagementManager != null && !notifyRecipients.Any(r => r.Id == engagementManager.Id)) notifyRecipients.Add(engagementManager);

        var notifTitle = $"Customer Requirement: {finalTitle} — {project.Name}";
        foreach (var recipient in notifyRecipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = notifTitle,
                Type = "Additional Customer Requirement",
                Priority = requirement.Priority,
                Status = "Pending",
                Unread = true,
                RaisedByEmployeeId = requestedByEmployeeId,
                RaisedByName = requestedByName,
                RelatedTask = requirement.RequirementId,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Pending",
                        at = DateTime.UtcNow.ToString("o"),
                        updatedBy = requestedByName,
                        details = $"Requirement logged by {requestedByName}"
                    }
                })
            };
            db.ActionNotifications.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        logger.LogInformation("Logged Additional Customer Requirement {ReqId} for project {ProjectId}. Notified {Count} stakeholders.",
            reqId, projectId, notifyRecipients.Count);

        return MapToDto(requirement);
    }

    public async Task<IReadOnlyList<ProjectAdditionalRequirementDto>> ListAsync(
        Guid projectId,
        CancellationToken ct = default)
    {
        var list = await db.ProjectAdditionalRequirements
            .AsNoTracking()
            .Where(r => r.ProjectId == projectId && r.DeletedAtUtc == null)
            .OrderByDescending(r => r.CreatedAtUtc)
            .ToListAsync(ct);

        return list.Select(MapToDto).ToList();
    }

    public async Task<ProjectAdditionalRequirementDto> ApproveAsync(
        Guid projectId,
        Guid requirementId,
        ApproveAdditionalRequirementRequest request,
        CancellationToken ct = default)
    {
        var requirement = await db.ProjectAdditionalRequirements
            .Include(r => r.Project)
            .FirstOrDefaultAsync(r => r.Id == requirementId && r.ProjectId == projectId && r.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Requirement with id {requirementId} not found.");

        if (string.Equals(requirement.Status, "Approved", StringComparison.OrdinalIgnoreCase))
        {
            return MapToDto(requirement);
        }

        var approver = await FindCurrentUserEmployeeAsync(ct);
        var approverName = !string.IsNullOrWhiteSpace(approver?.FirstName)
            ? $"{approver.FirstName} {approver.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name.Trim() : "Sales Manager");
        var approverEmployeeId = approver?.Id;

        requirement.Status = "Approved";
        requirement.ApprovedAtUtc = DateTime.UtcNow;
        requirement.ApprovedByEmployeeId = approverEmployeeId;
        requirement.ApprovedByName = approverName;
        requirement.ApprovalComments = request.Comment?.Trim();

        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            requirement.CommentsJson = AppendComment(requirement.CommentsJson, request.Comment, approverEmployeeId?.ToString() ?? currentUser.UserId?.ToString() ?? "", approverName);
        }

        requirement.HistoryJson = AppendHistory(requirement.HistoryJson, "Approved", approverName, request.Comment, $"Approved by {approverName}");

        var project = requirement.Project ?? await db.Projects.FindAsync(new object[] { projectId }, ct);
        if (project != null)
        {
            await NotifyLeadershipOnStatusChangeAsync(requirement, project, "Approved", approverName, approverEmployeeId, request.Comment, ct);
        }

        await db.SaveChangesAsync(ct);
        logger.LogInformation("Approved requirement {ReqId} by {ApproverName}.", requirement.RequirementId, approverName);

        return MapToDto(requirement);
    }

    public async Task<ProjectAdditionalRequirementDto> RejectAsync(
        Guid projectId,
        Guid requirementId,
        RejectAdditionalRequirementRequest request,
        CancellationToken ct = default)
    {
        var requirement = await db.ProjectAdditionalRequirements
            .Include(r => r.Project)
            .FirstOrDefaultAsync(r => r.Id == requirementId && r.ProjectId == projectId && r.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Requirement with id {requirementId} not found.");

        var rejecter = await FindCurrentUserEmployeeAsync(ct);
        var rejecterName = !string.IsNullOrWhiteSpace(rejecter?.FirstName)
            ? $"{rejecter.FirstName} {rejecter.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name.Trim() : "Sales Manager");

        requirement.Status = "Rejected";
        requirement.ApprovalComments = request.Comment?.Trim();

        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            requirement.CommentsJson = AppendComment(requirement.CommentsJson, request.Comment, rejecter?.Id.ToString() ?? currentUser.UserId?.ToString() ?? "", rejecterName);
        }

        requirement.HistoryJson = AppendHistory(requirement.HistoryJson, "Rejected", rejecterName, request.Comment, $"Rejected by {rejecterName}");

        var project = requirement.Project ?? await db.Projects.FindAsync(new object[] { projectId }, ct);
        if (project != null)
        {
            await NotifyLeadershipOnStatusChangeAsync(requirement, project, "Rejected", rejecterName, rejecter?.Id, request.Comment, ct);
        }

        await db.SaveChangesAsync(ct);
        return MapToDto(requirement);
    }

    public async Task<ProjectAdditionalRequirementDto> TakeActionAsync(
        Guid projectId,
        Guid requirementId,
        AdditionalRequirementActionRequest request,
        CancellationToken ct = default)
    {
        var normStatus = (request.Status ?? "").Trim();
        if (normStatus.Equals("Approved", StringComparison.OrdinalIgnoreCase))
        {
            return await ApproveAsync(projectId, requirementId, new ApproveAdditionalRequirementRequest { Comment = request.Comment }, ct);
        }
        if (normStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
        {
            return await RejectAsync(projectId, requirementId, new RejectAdditionalRequirementRequest { Comment = request.Comment }, ct);
        }

        var requirement = await db.ProjectAdditionalRequirements
            .Include(r => r.Project)
            .FirstOrDefaultAsync(r => r.Id == requirementId && r.ProjectId == projectId && r.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Requirement with id {requirementId} not found.");

        var performer = await FindCurrentUserEmployeeAsync(ct);
        var performerName = !string.IsNullOrWhiteSpace(performer?.FirstName)
            ? $"{performer.FirstName} {performer.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name.Trim() : "Reviewer");
        var performerId = performer?.Id.ToString() ?? currentUser.UserId?.ToString() ?? "";

        var mappedStatus = normStatus.Equals("Hold", StringComparison.OrdinalIgnoreCase) ? "Hold"
            : (normStatus.Equals("Request Changes", StringComparison.OrdinalIgnoreCase) || normStatus.Equals("Requested changes", StringComparison.OrdinalIgnoreCase)) ? "Request Changes"
            : normStatus;

        requirement.Status = mappedStatus;
        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            requirement.ApprovalComments = request.Comment.Trim();
            requirement.CommentsJson = AppendComment(requirement.CommentsJson, request.Comment, performerId, performerName);
        }

        requirement.HistoryJson = AppendHistory(requirement.HistoryJson, mappedStatus, performerName, request.Comment, $"{mappedStatus} by {performerName}");

        var project = requirement.Project ?? await db.Projects.FindAsync(new object[] { projectId }, ct);
        if (project != null)
        {
            await NotifyLeadershipOnStatusChangeAsync(requirement, project, mappedStatus, performerName, performer?.Id, request.Comment, ct);
        }

        await db.SaveChangesAsync(ct);
        logger.LogInformation("Action {Status} taken on requirement {ReqId} by {PerformerName}.", mappedStatus, requirement.RequirementId, performerName);
        return MapToDto(requirement);
    }

    public async Task<ProjectAdditionalRequirementDto> AddCommentAsync(
        Guid projectId,
        Guid requirementId,
        AddRequirementCommentRequest request,
        CancellationToken ct = default)
    {
        var requirement = await db.ProjectAdditionalRequirements
            .Include(r => r.Project)
            .FirstOrDefaultAsync(r => r.Id == requirementId && r.ProjectId == projectId && r.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Requirement with id {requirementId} not found.");

        if (string.Equals(requirement.Status, "Approved", StringComparison.OrdinalIgnoreCase))
        {
            throw new ConflictException("Cannot post comments to an already approved requirement.");
        }

        var performer = await FindCurrentUserEmployeeAsync(ct);
        var authorName = !string.IsNullOrWhiteSpace(request.AuthorName)
            ? request.AuthorName.Trim()
            : (!string.IsNullOrWhiteSpace(performer?.FirstName)
                ? $"{performer.FirstName} {performer.LastName}".Trim()
                : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name.Trim() : "User"));
        var authorId = performer?.Id.ToString() ?? currentUser.UserId?.ToString() ?? "";

        requirement.CommentsJson = AppendComment(requirement.CommentsJson, request.Text, authorId, authorName);

        await db.SaveChangesAsync(ct);
        logger.LogInformation("Comment added to requirement {ReqId} by {AuthorName}.", requirement.RequirementId, authorName);
        return MapToDto(requirement);
    }

    public async Task<IReadOnlyList<ProjectAdditionalRequirementDto>> ListPendingApprovalsAsync(
        CancellationToken ct = default)
    {
        var currentEmp = await FindCurrentUserEmployeeAsync(ct);
        var currentEmpId = currentEmp?.Id;
        var currentEmpName = currentEmp != null ? $"{currentEmp.FirstName} {currentEmp.LastName}".Trim() : currentUser.Name?.Trim();

        var query = db.ProjectAdditionalRequirements
            .Include(r => r.Project)
            .AsNoTracking()
            .Where(r => r.DeletedAtUtc == null);

        // If user is a sales person, filter to requirements where project's sales person is the user
        // If user is admin/PMO/Dhanshree, return all
        var userRole = currentUser.Role ?? currentEmp?.Role ?? "";
        var isPmoOrAdmin = userRole.Contains("PMO", StringComparison.OrdinalIgnoreCase) ||
                           userRole.Contains("Admin", StringComparison.OrdinalIgnoreCase) ||
                           string.Equals(currentUser.Name, "Dhanshree", StringComparison.OrdinalIgnoreCase);

        if (!isPmoOrAdmin && (currentEmpId != null || !string.IsNullOrWhiteSpace(currentEmpName)))
        {
            query = query.Where(r =>
                (r.Project != null && r.Project.SalesPersonId != null && r.Project.SalesPersonId == currentEmpId) ||
                (r.Project != null && r.Project.SalesPerson != null && currentEmpName != null && EF.Functions.ILike(r.Project.SalesPerson, $"%{currentEmpName}%"))
            );
        }

        var list = await query.OrderByDescending(r => r.CreatedAtUtc).ToListAsync(ct);
        return list.Select(MapToDto).ToList();
    }

    private async Task<Employee?> FindCurrentUserEmployeeAsync(CancellationToken ct)
    {
        if (currentUser.UserId is Guid userId)
        {
            var emp = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.UserId == userId && e.DeletedAtUtc == null, ct);
            if (emp != null) return emp;
        }

        if (!string.IsNullOrWhiteSpace(currentUser.Email))
        {
            var emp = await db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.WorkEmail == currentUser.Email && e.DeletedAtUtc == null, ct);
            if (emp != null) return emp;
        }

        var userName = currentUser.Name?.Trim();
        if (!string.IsNullOrWhiteSpace(userName))
        {
            var parts = userName.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length > 0)
            {
                var first = parts[0];
                var emp = await db.Employees
                    .AsNoTracking()
                    .FirstOrDefaultAsync(e => e.FirstName == first && e.DeletedAtUtc == null, ct);
                if (emp != null) return emp;
            }
        }

        return null;
    }

    private async Task NotifyLeadershipOnStatusChangeAsync(
        ProjectAdditionalRequirement requirement,
        Project project,
        string status,
        string actorName,
        Guid? actorEmployeeId,
        string? comment,
        CancellationToken ct)
    {
        var projectManager = await ResolveProjectManagerAsync(project, ct);
        var seniorProjectManager = await ResolveSeniorProjectManagerAsync(project, ct);
        var engagementManager = await ResolveEngagementManagerAsync(project, ct);

        var notifyRecipients = new List<Employee>();
        if (projectManager != null) notifyRecipients.Add(projectManager);
        if (seniorProjectManager != null && !notifyRecipients.Any(r => r.Id == seniorProjectManager.Id)) notifyRecipients.Add(seniorProjectManager);
        if (engagementManager != null && !notifyRecipients.Any(r => r.Id == engagementManager.Id)) notifyRecipients.Add(engagementManager);

        if (notifyRecipients.Count == 0) return;

        var actionVerb = status.Equals("Request Changes", StringComparison.OrdinalIgnoreCase) || status.Equals("Requested changes", StringComparison.OrdinalIgnoreCase)
            ? "Changes Requested"
            : status.Equals("Hold", StringComparison.OrdinalIgnoreCase)
                ? "Put on Hold"
                : status.Equals("Approved", StringComparison.OrdinalIgnoreCase)
                    ? "Approved"
                    : status.Equals("Rejected", StringComparison.OrdinalIgnoreCase)
                        ? "Rejected"
                        : status;

        var notifTitle = $"Requirement {actionVerb}: {requirement.Title} — {project.Name}";
        var commentDetail = !string.IsNullOrWhiteSpace(comment) ? $". Comment: {comment.Trim()}" : string.Empty;

        foreach (var recipient in notifyRecipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = notifTitle,
                Type = "Additional Customer Requirement",
                Priority = requirement.Priority,
                Status = status,
                Unread = true,
                RaisedByEmployeeId = actorEmployeeId,
                RaisedByName = actorName,
                RelatedTask = requirement.RequirementId,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status,
                        at = DateTime.UtcNow.ToString("o"),
                        updatedBy = actorName,
                        details = $"{status} by {actorName}{commentDetail}"
                    }
                })
            };
            db.ActionNotifications.Add(notif);
        }
    }

    private async Task<Employee?> ResolveSalesPersonAsync(Project project, CancellationToken ct)
    {
        if (project.SalesPersonId is Guid spId)
        {
            var emp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == spId && e.DeletedAtUtc == null, ct);
            if (emp != null) return emp;
        }

        if (!string.IsNullOrWhiteSpace(project.SalesPerson))
        {
            var name = project.SalesPerson.Trim();
            var parts = name.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            var emp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e =>
                e.DeletedAtUtc == null &&
                ((e.FirstName + " " + e.LastName).ToLower() == name.ToLower() ||
                 (parts.Length > 0 && e.FirstName.ToLower() == parts[0].ToLower())), ct);
            if (emp != null) return emp;
        }

        // Fallback: any sales manager or sales member
        return await db.Employees.AsNoTracking()
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Role != null && e.Role.Contains("Sales"), ct);
    }

    private async Task<Employee?> ResolveProjectManagerAsync(Project project, CancellationToken ct)
    {
        if (project.ProjectManagerId is Guid pmId)
        {
            var emp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == pmId && e.DeletedAtUtc == null, ct);
            if (emp != null) return emp;
        }

        var tm = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(m => m.ProjectId == project.Id && m.MemberRole == "ProjectManager" && m.DeletedAtUtc == null)
            .OrderBy(m => m.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);

        if (tm != null)
        {
            return await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == tm.EmployeeId && e.DeletedAtUtc == null, ct);
        }

        return null;
    }

    private async Task<Employee?> ResolveSeniorProjectManagerAsync(Project project, CancellationToken ct)
    {
        var tm = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(m => m.ProjectId == project.Id && m.MemberRole == "SeniorProjectManager" && m.DeletedAtUtc == null)
            .OrderBy(m => m.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);

        if (tm != null)
        {
            return await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == tm.EmployeeId && e.DeletedAtUtc == null, ct);
        }

        return null;
    }

    private async Task<Employee?> ResolveEngagementManagerAsync(Project project, CancellationToken ct)
    {
        if (project.EngagementManagerId is Guid emId)
        {
            var emp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == emId && e.DeletedAtUtc == null, ct);
            if (emp != null) return emp;
        }

        var tm = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(m => m.ProjectId == project.Id && m.MemberRole == "EngagementManager" && m.DeletedAtUtc == null)
            .OrderBy(m => m.CreatedAtUtc)
            .FirstOrDefaultAsync(ct);

        if (tm != null)
        {
            return await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == tm.EmployeeId && e.DeletedAtUtc == null, ct);
        }

        if (!string.IsNullOrWhiteSpace(project.EngagementManager))
        {
            var name = project.EngagementManager.Trim();
            var parts = name.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            var emp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e =>
                e.DeletedAtUtc == null &&
                ((e.FirstName + " " + e.LastName).ToLower() == name.ToLower() ||
                 (parts.Length > 0 && e.FirstName.ToLower() == parts[0].ToLower())), ct);
            if (emp != null) return emp;
        }

        return null;
    }


    private static string AppendComment(string? currentJson, string text, string authorId, string authorName)
    {
        var comments = new List<object>();
        if (!string.IsNullOrWhiteSpace(currentJson))
        {
            try
            {
                using var doc = JsonDocument.Parse(currentJson);
                if (doc.RootElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var elem in doc.RootElement.EnumerateArray())
                    {
                        if (elem.ValueKind == JsonValueKind.Object)
                        {
                            comments.Add(elem.Clone());
                        }
                    }
                }
            }
            catch { }
        }

        comments.Add(new
        {
            id = "cm-" + Guid.NewGuid().ToString("N")[..8],
            authorId,
            authorName,
            text = text?.Trim() ?? string.Empty,
            at = DateTime.UtcNow.ToString("o")
        });

        return JsonSerializer.Serialize(comments);
    }

    private static string AppendHistory(string? currentJson, string status, string updatedBy, string? comment, string details)
    {
        var historyList = new List<object>();
        if (!string.IsNullOrWhiteSpace(currentJson))
        {
            try
            {
                using var doc = JsonDocument.Parse(currentJson);
                if (doc.RootElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var elem in doc.RootElement.EnumerateArray())
                    {
                        if (elem.ValueKind == JsonValueKind.Object)
                        {
                            historyList.Add(elem.Clone());
                        }
                    }
                }
            }
            catch { }
        }

        historyList.Add(new
        {
            status,
            at = DateTime.UtcNow.ToString("o"),
            updatedBy,
            comment = comment?.Trim() ?? string.Empty,
            details
        });

        return JsonSerializer.Serialize(historyList);
    }

    private static ProjectAdditionalRequirementDto MapToDto(ProjectAdditionalRequirement r) => new(
        Id: r.Id,
        RequirementId: r.RequirementId,
        ProjectId: r.ProjectId,
        ClientName: r.ClientName,
        ProjectName: r.ProjectName,
        RequirementType: r.RequirementType,
        Title: r.Title,
        Description: r.Description,
        Priority: r.Priority,
        RequestedByEmployeeId: r.RequestedByEmployeeId,
        RequestedByName: r.RequestedByName,
        RequestedDate: r.RequestedDate.ToString("yyyy-MM-dd"),
        AttachmentFileName: r.AttachmentFileName,
        AttachmentPath: r.AttachmentPath,
        ScopeCancellationService: r.ScopeCancellationService,
        Status: r.Status,
        ApprovedAtUtc: r.ApprovedAtUtc,
        ApprovedByEmployeeId: r.ApprovedByEmployeeId,
        ApprovedByName: r.ApprovedByName,
        ApprovalComments: r.ApprovalComments,
        CommentsJson: r.CommentsJson,
        HistoryJson: r.HistoryJson,
        CreatedAtUtc: r.CreatedAtUtc
    );
}
