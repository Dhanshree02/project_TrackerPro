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

public sealed class ProjectIssueService(
    AppDbContext db,
    ICurrentUserService currentUser) : IProjectIssueService
{
    private static readonly string[] AllowedPriorities = ["Low", "Medium", "High", "Critical"];

    public async Task<IReadOnlyList<AssignedProjectSummaryDto>> GetEmployeeAssignedProjectsAsync(CancellationToken ct = default)
    {
        var role = (currentUser.Role ?? "").Trim();
        var isPmoOrAdmin = role.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("PMO", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("Senior Project Manager", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("Head of Delivery", StringComparison.OrdinalIgnoreCase);

        var employee = await FindCurrentEmployeeAsync(ct);

        if (isPmoOrAdmin || employee == null)
        {
            var all = await db.Projects
                .AsNoTracking()
                .Include(p => p.Client)
                .Where(p => p.DeletedAtUtc == null)
                .OrderBy(p => p.Name)
                .Select(p => new AssignedProjectSummaryDto(
                    p.Id,
                    p.Name,
                    p.ProjectCode,
                    p.Client != null ? p.Client.Name : null,
                    p.Status))
                .ToListAsync(ct);
            return all;
        }

        var empId = employee.Id;

        // Find projects where employee is team member
        var teamMemberProjectIds = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(tm => tm.EmployeeId == empId && tm.DeletedAtUtc == null)
            .Select(tm => tm.ProjectId)
            .ToListAsync(ct);

        // Find projects where employee is assigned to a task
        var taskProjectIds = await db.ProjectTaskAssignments
            .AsNoTracking()
            .Where(ta => ta.EmployeeId == empId && ta.DeletedAtUtc == null)
            .Join(db.ProjectTasks, ta => ta.TaskId, t => t.Id, (ta, t) => t.ProjectId)
            .ToListAsync(ct);

        // Find projects where employee has bucket tasks
        var bucketProjectIds = await db.BucketTasks
            .AsNoTracking()
            .Where(bt => bt.EmployeeId == empId && bt.ProjectId != Guid.Empty)
            .Select(bt => bt.ProjectId)
            .ToListAsync(ct);

        // Find projects where employee is PM, TL, or EM
        var managerProjectIds = await db.Projects
            .AsNoTracking()
            .Where(p => p.DeletedAtUtc == null && (
                p.ProjectManagerId == empId ||
                p.TeamLeadId == empId ||
                p.EngagementManagerId == empId ||
                p.SalesPersonId == empId))
            .Select(p => p.Id)
            .ToListAsync(ct);

        var allAssignedIds = teamMemberProjectIds
            .Concat(taskProjectIds)
            .Concat(bucketProjectIds)
            .Concat(managerProjectIds)
            .Distinct()
            .ToList();

        var query = db.Projects
            .AsNoTracking()
            .Include(p => p.Client)
            .Where(p => p.DeletedAtUtc == null);

        if (allAssignedIds.Count > 0)
        {
            query = query.Where(p => allAssignedIds.Contains(p.Id));
        }

        var results = await query
            .OrderBy(p => p.Name)
            .Select(p => new AssignedProjectSummaryDto(
                p.Id,
                p.Name,
                p.ProjectCode,
                p.Client != null ? p.Client.Name : null,
                p.Status))
            .ToListAsync(ct);

        // Fallback: if no projects were explicitly assigned, return all active projects
        if (results.Count == 0)
        {
            results = await db.Projects
                .AsNoTracking()
                .Include(p => p.Client)
                .Where(p => p.DeletedAtUtc == null)
                .OrderBy(p => p.Name)
                .Select(p => new AssignedProjectSummaryDto(
                    p.Id,
                    p.Name,
                    p.ProjectCode,
                    p.Client != null ? p.Client.Name : null,
                    p.Status))
                .ToListAsync(ct);
        }

        return results;
    }

    public async Task<IReadOnlyList<ProjectIssueDto>> GetProjectIssuesAsync(Guid projectId, CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);

        var rows = await db.ProjectIssues
            .AsNoTracking()
            .Where(x => x.ProjectId == projectId && x.DeletedAtUtc == null)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return rows.Select(MapIssue).ToList();
    }

    public async Task<ProjectIssueDto> CreateIssueAsync(
        Guid projectId,
        CreateProjectIssueRequest request,
        CancellationToken ct = default)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Project '{projectId}' was not found.");

        var subject = request.Subject?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(subject))
            throw new ConflictException("Issue title/subject is required.");

        var description = request.Description?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(description))
            throw new ConflictException("Description is required.");

        var issueType = string.IsNullOrWhiteSpace(request.IssueType)
            ? "Technical Related Issues"
            : request.IssueType.Trim();

        var priority = string.IsNullOrWhiteSpace(request.Priority)
            ? "Medium"
            : request.Priority.Trim();

        if (!AllowedPriorities.Contains(priority, StringComparer.OrdinalIgnoreCase))
            throw new ConflictException("Priority must be Low, Medium, High, or Critical.");

        // Resolve current user / employee
        var employee = await FindCurrentEmployeeAsync(ct);
        var raiserName = employee is not null
            ? $"{employee.FirstName} {employee.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : (currentUser.Email ?? "User"));
        var raiserRole = currentUser.Role ?? "Employee";

        var issue = new ProjectIssue
        {
            ProjectId = projectId,
            ProjectCode = project.ProjectCode,
            ProjectName = project.Name,
            IssueType = issueType,
            Priority = priority,
            Subject = subject,
            Description = description,
            Status = "Open",
            RaisedByEmployeeId = employee?.Id,
            RaisedByName = raiserName,
            RaisedByRole = raiserRole,
        };

        db.ProjectIssues.Add(issue);

        // Mirror notification & alert for assigned Project Manager, Engagement Manager, and Team Leader (NOT Senior Project Manager)
        var recipientEmpIds = new HashSet<Guid>();

        // 1. Assigned Project Manager from Project record
        if (project.ProjectManagerId.HasValue && project.ProjectManagerId.Value != Guid.Empty)
        {
            recipientEmpIds.Add(project.ProjectManagerId.Value);
        }

        // 2. Assigned Engagement Manager from Project record or Client record
        var emId = project.EngagementManagerId ?? project.Client?.EngagementManagerId;
        if (emId.HasValue && emId.Value != Guid.Empty)
        {
            recipientEmpIds.Add(emId.Value);
        }

        // 3. Assigned Team Lead from Project record
        if (project.TeamLeadId.HasValue && project.TeamLeadId.Value != Guid.Empty)
        {
            recipientEmpIds.Add(project.TeamLeadId.Value);
        }

        // 4. Project Team Members with PM, EM, or TL roles (EXCLUDING SeniorProjectManager)
        var teamLeadership = await db.ProjectTeamMembers
            .AsNoTracking()
            .Include(tm => tm.Employee)
            .Where(tm => tm.ProjectId == projectId && tm.DeletedAtUtc == null)
            .ToListAsync(ct);

        foreach (var tm in teamLeadership)
        {
            var memberRole = tm.MemberRole?.Trim() ?? "";
            var empRole = tm.Employee?.Role?.Trim() ?? "";

            var isPm = memberRole.Equals("ProjectManager", StringComparison.OrdinalIgnoreCase)
                       || memberRole.Equals("Project Manager", StringComparison.OrdinalIgnoreCase)
                       || memberRole.Equals("PM", StringComparison.OrdinalIgnoreCase);

            var isEm = memberRole.Equals("EngagementManager", StringComparison.OrdinalIgnoreCase)
                       || memberRole.Equals("Engagement Manager", StringComparison.OrdinalIgnoreCase)
                       || memberRole.Equals("EM", StringComparison.OrdinalIgnoreCase)
                       || empRole.Equals("EngagementManager", StringComparison.OrdinalIgnoreCase)
                       || empRole.Equals("Engagement Manager", StringComparison.OrdinalIgnoreCase);

            var isTl = tm.IsTeamLead
                       || memberRole.Equals("TeamLead", StringComparison.OrdinalIgnoreCase)
                       || memberRole.Equals("Team Leader", StringComparison.OrdinalIgnoreCase)
                       || memberRole.Equals("Team-Leader", StringComparison.OrdinalIgnoreCase);

            // Note: Senior Project Manager is intentionally omitted per requirements
            if (isPm || isEm || isTl)
            {
                recipientEmpIds.Add(tm.EmployeeId);
            }
        }

        var audienceIds = recipientEmpIds.Select(id => id.ToString()).Distinct().ToList();

        var alert = new ProjectAlert
        {
            ProjectId = projectId,
            Issue = issue,
            Title = subject,
            Description = description,
            AlertType = "Issue",
            Priority = priority,
            Status = "Open",
            RaisedByEmployeeId = employee?.Id,
            RaisedByName = raiserName,
            AudienceUserIds = JsonSerializer.Serialize(audienceIds),
        };

        db.ProjectAlerts.Add(alert);

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
                by = raiserName
            }
        });

        foreach (var recipientId in recipientEmpIds)
        {
            db.ActionNotifications.Add(new ActionNotification
            {
                RecipientEmployeeId = recipientId,
                ProjectId = projectId,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = $"Issue Raised: {subject}",
                Type = "Issue Raised",
                Priority = priority,
                Status = "Pending",
                Unread = true,
                RaisedByEmployeeId = employee?.Id,
                RaisedByName = raiserName,
                RelatedTask = issueType,
                Issue = issue,
                HistoryJson = defaultHistoryJson,
                CreatedAtUtc = now
            });
        }

        await db.SaveChangesAsync(ct);

        return MapIssue(issue);
    }

    public async Task<IReadOnlyList<ProjectAlertDto>> GetProjectAlertsAsync(Guid projectId, CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);

        var rows = await db.ProjectAlerts
            .AsNoTracking()
            .Where(x => x.ProjectId == projectId && x.DeletedAtUtc == null)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return rows.Select(MapAlert).ToList();
    }

    public async Task<ProjectAlertDto> UpdateAlertStatusAsync(
        Guid projectId,
        Guid alertId,
        string status,
        CancellationToken ct = default)
    {
        var alert = await db.ProjectAlerts
            .Include(a => a.Issue)
            .FirstOrDefaultAsync(a => a.Id == alertId && a.ProjectId == projectId && a.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Alert '{alertId}' was not found for this project.");

        var normalizedStatus = status.Trim();
        var validStatuses = new[] { "Open", "Acknowledged", "Resolved", "Closed" };
        if (!validStatuses.Contains(normalizedStatus, StringComparer.OrdinalIgnoreCase))
            throw new ConflictException("Status must be Open, Acknowledged, Resolved, or Closed.");

        alert.Status = normalizedStatus;
        alert.UpdatedAtUtc = DateTime.UtcNow;

        // If alert is linked to an issue, and alert is resolved/closed, sync issue status
        if (alert.Issue is not null)
        {
            if (normalizedStatus.Equals("Resolved", StringComparison.OrdinalIgnoreCase))
            {
                alert.Issue.Status = "Resolved";
                alert.Issue.UpdatedAtUtc = DateTime.UtcNow;
            }
            else if (normalizedStatus.Equals("Acknowledged", StringComparison.OrdinalIgnoreCase) && alert.Issue.Status == "Open")
            {
                alert.Issue.Status = "In Progress";
                alert.Issue.UpdatedAtUtc = DateTime.UtcNow;
            }
        }

        await db.SaveChangesAsync(ct);
        return MapAlert(alert);
    }

    private async Task<Employee?> FindCurrentEmployeeAsync(CancellationToken ct)
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
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct);
        if (!exists) throw new NotFoundException($"Project '{projectId}' was not found.");
    }

    private static ProjectIssueDto MapIssue(ProjectIssue row) => new(
        row.Id,
        row.ProjectId,
        row.ProjectCode,
        row.ProjectName,
        row.IssueType,
        row.Priority,
        row.Subject,
        row.Description,
        row.Status,
        row.RaisedByEmployeeId,
        row.RaisedByName,
        row.RaisedByRole,
        row.CreatedAtUtc);

    private static ProjectAlertDto MapAlert(ProjectAlert row) => new(
        row.Id,
        row.ProjectId,
        row.IssueId,
        row.Title,
        row.Description,
        row.AlertType,
        row.Priority,
        row.Status,
        row.RaisedByEmployeeId,
        row.RaisedByName,
        row.CreatedAtUtc);
}
