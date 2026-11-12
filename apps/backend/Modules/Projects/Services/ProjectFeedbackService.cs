using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectFeedbackService(
    AppDbContext db,
    ICurrentUserService currentUser) : IProjectFeedbackService
{
    private static readonly Regex AlphanumericTextRegex = new(@"^[a-zA-Z0-9\s]*$", RegexOptions.Compiled);

    public async Task<ProjectFeedbackDto> CreateAsync(
        Guid projectId,
        CreateProjectFeedbackRequest request,
        CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project '{projectId}' was not found.");

        if (request.EmployeeId == Guid.Empty)
            throw new ConflictException("Select a resource for feedback.");

        var employee = await db.Employees.FirstOrDefaultAsync(e => e.Id == request.EmployeeId, ct)
            ?? throw new NotFoundException($"Resource '{request.EmployeeId}' was not found.");

        var employeeName = $"{employee.FirstName} {employee.LastName}".Trim();
        var employeeCode = employee.EmployeeCode;

        Guid? reportingManagerId = employee.ReportingManagerId;
        string? reportingManagerName = null;

        if (reportingManagerId.HasValue)
        {
            var rm = await db.Employees.FirstOrDefaultAsync(e => e.Id == reportingManagerId.Value, ct);
            if (rm != null)
            {
                reportingManagerName = $"{rm.FirstName} {rm.LastName}".Trim();
            }
        }
        else
        {
            // Fallback reporting manager to Project Manager or Engagement Manager
            reportingManagerId = project.ProjectManagerId ?? project.EngagementManagerId;
            if (reportingManagerId.HasValue)
            {
                var rm = await db.Employees.FirstOrDefaultAsync(e => e.Id == reportingManagerId.Value, ct);
                if (rm != null)
                {
                    reportingManagerName = $"{rm.FirstName} {rm.LastName}".Trim();
                }
            }
        }

        var isFeedbackRequest = string.Equals(request.FeedbackType, "FeedbackRequest", StringComparison.OrdinalIgnoreCase);
        var feedbackType = isFeedbackRequest ? "FeedbackRequest" : "DirectFeedback";

        string? strengths = null;
        string? improvements = null;
        string? comments = null;
        int? rating = null;

        if (!isFeedbackRequest)
        {
            // Validate rating 0 to 5
            if (request.Rating is not null)
            {
                if (request.Rating < 0 || request.Rating > 5)
                {
                    throw new BadRequestException("Rating must be between 0 and 5.");
                }
                rating = request.Rating;
            }
            else
            {
                rating = 0;
            }

            // Validate Strengths, Areas of Improvement, Comments: max 100 chars, text & number only
            static string? ValidateAndClean(string? text, string fieldName)
            {
                if (string.IsNullOrWhiteSpace(text)) return null;
                var trimmed = text.Trim();
                if (trimmed.Length > 100)
                {
                    throw new BadRequestException($"{fieldName} cannot exceed 100 characters.");
                }
                if (!AlphanumericTextRegex.IsMatch(trimmed))
                {
                    throw new BadRequestException($"{fieldName} can only contain letters, numbers, and spaces.");
                }
                return trimmed;
            }

            strengths = ValidateAndClean(request.Strengths, "Strengths");
            improvements = ValidateAndClean(request.AreasOfImprovement, "Areas of Improvement");
            comments = ValidateAndClean(request.Comments, "Comments");

            if (strengths is null && improvements is null && comments is null)
            {
                throw new BadRequestException("Please provide Strengths, Areas of Improvement, or Comments.");
            }
        }

        var submitter = await FindSubmitterAsync(ct);
        var submitterName = submitter is not null
            ? $"{submitter.FirstName} {submitter.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : (currentUser.Email ?? "Project Manager"));

        var now = DateTime.UtcNow;
        var initialHistory = new[]
        {
            new
            {
                status = isFeedbackRequest ? "Pending" : "Submitted",
                at = now.ToString("o"),
                updatedBy = submitterName,
                details = isFeedbackRequest
                    ? $"Feedback requested for {employeeName}"
                    : $"Feedback submitted for {employeeName} with rating {rating}/5"
            }
        };

        var feedback = new ProjectFeedback
        {
            ProjectId = projectId,
            EmployeeId = request.EmployeeId,
            EmployeeName = employeeName,
            EmployeeCode = employeeCode,
            ReportingManagerId = reportingManagerId,
            ReportingManagerName = reportingManagerName,
            SubmittedByEmployeeId = submitter?.Id,
            SubmittedByName = submitterName,
            FeedbackType = feedbackType,
            Strengths = strengths,
            AreasOfImprovement = improvements,
            Comments = comments,
            Rating = rating,
            RequestNote = isFeedbackRequest ? request.RequestNote?.Trim() : null,
            Status = isFeedbackRequest ? "Pending" : "Submitted",
            CommentsJson = "[]",
            HistoryJson = JsonSerializer.Serialize(initialHistory),
            CreatedAtUtc = now
        };

        db.ProjectFeedbacks.Add(feedback);

        if (!isFeedbackRequest)
        {
            // 1. Notification to the Employee / Resource
            var empHistory = new[]
            {
                new
                {
                    action = $"Feedback received from {submitterName}: Rating {rating}/5",
                    date = now.ToString("yyyy-MM-dd"),
                    time = now.ToString("HH:mm:ss"),
                    by = submitterName
                }
            };

            var empNotification = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = employee.Id,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = $"Feedback received on project {project.Name} — Rating: {rating}/5",
                Type = "Feedback Received",
                Priority = "Medium",
                Status = "Acknowledged",
                Unread = true,
                RaisedByEmployeeId = submitter?.Id,
                RaisedByName = submitterName,
                RelatedTask = $"Strengths: {strengths ?? "—"} | Areas of Improvement: {improvements ?? "—"}",
                HistoryJson = JsonSerializer.Serialize(empHistory),
                CreatedAtUtc = now
            };
            db.ActionNotifications.Add(empNotification);

            // 2. Notification to Resource Reporting Manager
            if (reportingManagerId.HasValue && reportingManagerId.Value != employee.Id)
            {
                var rmHistory = new[]
                {
                    new
                    {
                        action = $"Feedback submitted for {employeeName} by {submitterName}",
                        date = now.ToString("yyyy-MM-dd"),
                        time = now.ToString("HH:mm:ss"),
                        by = submitterName
                    }
                };

                var rmNotification = new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = reportingManagerId.Value,
                    ProjectId = project.Id,
                    ProjectCode = project.ProjectCode,
                    ProjectName = project.Name,
                    Title = $"Feedback submitted for {employeeName} on {project.Name}",
                    Type = "Feedback Received",
                    Priority = "Medium",
                    Status = "Pending",
                    Unread = true,
                    RaisedByEmployeeId = submitter?.Id,
                    RaisedByName = submitterName,
                    RelatedTask = $"Rating: {rating}/5 | Comments: {comments ?? "—"}",
                    HistoryJson = JsonSerializer.Serialize(rmHistory),
                    CreatedAtUtc = now
                };
                db.ActionNotifications.Add(rmNotification);
            }
        }
        else
        {
            // Request Feedback -> Approval Request & Notification for Reporting Manager
            if (reportingManagerId.HasValue)
            {
                var reqHistory = new[]
                {
                    new
                    {
                        action = $"Feedback requested for {employeeName} by {submitterName}",
                        date = now.ToString("yyyy-MM-dd"),
                        time = now.ToString("HH:mm:ss"),
                        by = submitterName
                    }
                };

                var reqNotification = new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = reportingManagerId.Value,
                    ProjectId = project.Id,
                    ProjectCode = project.ProjectCode,
                    ProjectName = project.Name,
                    Title = $"Approval Request: Feedback requested for {employeeName} on {project.Name}",
                    Type = "Approval Request",
                    Priority = "Medium",
                    Status = "Pending",
                    Unread = true,
                    RaisedByEmployeeId = submitter?.Id,
                    RaisedByName = submitterName,
                    RelatedTask = string.IsNullOrWhiteSpace(request.RequestNote)
                        ? $"Feedback Request: {employeeName}"
                        : $"Feedback Request: {employeeName} — {request.RequestNote}",
                    HistoryJson = JsonSerializer.Serialize(reqHistory),
                    CreatedAtUtc = now
                };
                db.ActionNotifications.Add(reqNotification);
            }
        }

        await db.SaveChangesAsync(ct);
        return MapToDto(feedback, project.Name);
    }

    public async Task<IReadOnlyList<ProjectFeedbackDto>> ListByProjectAsync(
        Guid projectId,
        Guid? employeeId = null,
        CancellationToken ct = default)
    {
        var q = db.ProjectFeedbacks
            .Include(f => f.Project)
            .AsNoTracking()
            .Where(f => f.ProjectId == projectId && f.DeletedAtUtc == null);

        if (employeeId.HasValue)
        {
            q = q.Where(f => f.EmployeeId == employeeId.Value);
        }

        var items = await q.OrderByDescending(f => f.CreatedAtUtc).ToListAsync(ct);
        return items.Select(f => MapToDto(f, f.Project?.Name)).ToList();
    }

    public async Task<IReadOnlyList<ProjectFeedbackDto>> ListPendingApprovalsAsync(CancellationToken ct = default)
    {
        var currentEmpId = await ResolveCurrentEmployeeIdAsync(ct);
        var isSuperAdmin = currentUser.Role is "Admin" or "SuperAdmin" || currentUser.Email == "admin@talakunchi.com";

        var q = db.ProjectFeedbacks
            .Include(f => f.Project)
            .AsNoTracking()
            .Where(f => f.DeletedAtUtc == null && f.FeedbackType == "FeedbackRequest" && f.Status == "Pending");

        if (currentEmpId.HasValue && !isSuperAdmin)
        {
            q = q.Where(f => f.ReportingManagerId == currentEmpId.Value);
        }

        var items = await q.OrderByDescending(f => f.CreatedAtUtc).ToListAsync(ct);
        return items.Select(f => MapToDto(f, f.Project?.Name)).ToList();
    }

    public async Task<ProjectFeedbackDto> TakeApprovalActionAsync(
        Guid feedbackId,
        FeedbackApprovalActionRequest request,
        CancellationToken ct = default)
    {
        var entity = await db.ProjectFeedbacks
            .Include(f => f.Project)
            .FirstOrDefaultAsync(f => f.Id == feedbackId && f.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Feedback request '{feedbackId}' was not found.");

        var normStatus = request.Status?.Trim();
        if (string.IsNullOrWhiteSpace(normStatus))
        {
            throw new BadRequestException("Action status is required.");
        }

        entity.Status = normStatus;
        entity.UpdatedAtUtc = DateTime.UtcNow;

        var submitter = await FindSubmitterAsync(ct);
        var actorName = submitter is not null
            ? $"{submitter.FirstName} {submitter.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : (currentUser.Email ?? "Reporting Manager"));

        // Append to history
        var historyList = new List<object>();
        try
        {
            if (!string.IsNullOrWhiteSpace(entity.HistoryJson))
            {
                var existing = JsonSerializer.Deserialize<List<object>>(entity.HistoryJson);
                if (existing is not null) historyList.AddRange(existing);
            }
        }
        catch {}

        historyList.Add(new
        {
            status = normStatus,
            at = DateTime.UtcNow.ToString("o"),
            updatedBy = actorName,
            comment = request.Comment ?? string.Empty
        });
        entity.HistoryJson = JsonSerializer.Serialize(historyList);

        // Append to comments if provided
        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            var commentsList = new List<object>();
            try
            {
                if (!string.IsNullOrWhiteSpace(entity.CommentsJson))
                {
                    var existing = JsonSerializer.Deserialize<List<object>>(entity.CommentsJson);
                    if (existing is not null) commentsList.AddRange(existing);
                }
            }
            catch {}

            commentsList.Add(new
            {
                id = Guid.NewGuid().ToString(),
                authorName = actorName,
                authorEmail = currentUser.Email ?? string.Empty,
                text = request.Comment.Trim(),
                at = DateTime.UtcNow.ToString("o")
            });
            entity.CommentsJson = JsonSerializer.Serialize(commentsList);
        }

        // Notify requester about approval/action result
        if (entity.SubmittedByEmployeeId.HasValue)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = entity.SubmittedByEmployeeId.Value,
                ProjectId = entity.ProjectId,
                ProjectCode = entity.Project?.ProjectCode,
                ProjectName = entity.Project?.Name,
                Title = $"Feedback request for {entity.EmployeeName} was marked as {normStatus}",
                Type = "Approval Request",
                Priority = "Medium",
                Status = normStatus == "Approved" ? "Approved" : "Acknowledged",
                Unread = true,
                RaisedByEmployeeId = submitter?.Id,
                RaisedByName = actorName,
                RelatedTask = $"Feedback Request: {entity.EmployeeName}",
                CreatedAtUtc = DateTime.UtcNow
            };
            db.ActionNotifications.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        return MapToDto(entity, entity.Project?.Name);
    }

    private async Task<Employee?> FindSubmitterAsync(CancellationToken ct)
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

    private async Task<Guid?> ResolveCurrentEmployeeIdAsync(CancellationToken ct)
    {
        if (currentUser.UserId is Guid uid)
        {
            var emp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == uid, ct);
            if (emp is not null) return emp.Id;
        }

        var email = currentUser.Email?.Trim().ToLowerInvariant();
        if (!string.IsNullOrWhiteSpace(email))
        {
            var emp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.WorkEmail.ToLower() == email, ct);
            if (emp is not null) return emp.Id;
        }

        return null;
    }

    private static ProjectFeedbackDto MapToDto(ProjectFeedback f, string? projectName = null) => new(
        f.Id,
        f.ProjectId,
        projectName ?? f.Project?.Name,
        f.EmployeeId,
        f.EmployeeName,
        f.EmployeeCode,
        f.ReportingManagerId,
        f.ReportingManagerName,
        f.SubmittedByEmployeeId,
        f.SubmittedByName,
        f.FeedbackType,
        f.Strengths,
        f.AreasOfImprovement,
        f.Comments,
        f.Rating,
        f.RequestNote,
        f.Status,
        f.CommentsJson,
        f.HistoryJson,
        f.CreatedAtUtc
    );
}
