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

public sealed class ProjectInterviewService(
    AppDbContext db,
    ICurrentUserService currentUser) : IProjectInterviewService
{
    public async Task<IReadOnlyList<ProjectInterviewDto>> ListAsync(Guid projectId, CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);

        var rows = await db.ProjectInterviews
            .AsNoTracking()
            .Where(x => x.ProjectId == projectId)
            .OrderByDescending(x => x.InterviewDate)
            .ThenByDescending(x => x.InterviewTime)
            .ToListAsync(ct);

        return rows.Select(Map).ToList();
    }

    public async Task<ProjectInterviewDto> CreateAsync(Guid projectId, CreateProjectInterviewRequest request, CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);

        var onTeam = await db.ProjectTeamMembers
            .Include(m => m.Employee)
            .FirstOrDefaultAsync(m =>
                m.ProjectId == projectId
                && m.EmployeeId == request.EmployeeId
                && (m.MemberRole == ProjectMemberRoles.ProjectTeam || m.MemberRole == ProjectMemberRoles.ShadowTeam), ct);

        if (onTeam is null)
        {
            throw new ConflictException("Select a team member added on the Team tab. Project Managers and Senior Project Managers are not included.");
        }

        var name = onTeam.Employee is null
            ? "Team member"
            : $"{onTeam.Employee.FirstName} {onTeam.Employee.LastName}".Trim();

        var row = new ProjectInterview
        {
            ProjectId = projectId,
            EmployeeId = request.EmployeeId,
            ResourceName = string.IsNullOrWhiteSpace(name) ? "Team member" : name,
            InterviewDate = request.InterviewDate,
            InterviewTime = request.InterviewTime,
            Result = "Pending",
            Comments = null,
        };

        db.ProjectInterviews.Add(row);
        await db.SaveChangesAsync(ct);
        return Map(row);
    }

    public async Task<ProjectInterviewDto> UpdateAsync(Guid projectId, Guid interviewId, UpdateProjectInterviewRequest request, CancellationToken ct = default)
    {
        var row = await db.ProjectInterviews
            .FirstOrDefaultAsync(x => x.ProjectId == projectId && x.Id == interviewId, ct)
            ?? throw new NotFoundException("Interview was not found.");

        var oldResult = row.Result ?? "Pending";
        var resultChanged = false;

        if (request.Result is not null)
        {
            var nextResult = request.Result.Trim();
            if (!string.Equals(oldResult.Trim(), nextResult, StringComparison.OrdinalIgnoreCase))
            {
                resultChanged = true;
            }
            row.Result = nextResult;
        }

        if (request.Comments is not null)
        {
            row.Comments = string.IsNullOrWhiteSpace(request.Comments) ? null : request.Comments.Trim();
        }

        if (request.InterviewDate is DateOnly date)
        {
            row.InterviewDate = date;
        }

        if (request.InterviewTime is TimeOnly time)
        {
            row.InterviewTime = time;
        }

        if (row.Result == "Postponed" && string.IsNullOrWhiteSpace(row.Comments))
        {
            throw new ConflictException("Add a comment when the interview is postponed.");
        }

        row.UpdatedAtUtc = DateTime.UtcNow;

        if (resultChanged)
        {
            await DispatchInterviewResultNotificationsAsync(projectId, row, oldResult, ct);
        }

        await db.SaveChangesAsync(ct);
        return Map(row);
    }

    private async Task DispatchInterviewResultNotificationsAsync(
        Guid projectId,
        ProjectInterview interview,
        string oldResult,
        CancellationToken ct)
    {
        var project = await db.Projects
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == projectId, ct);

        var projectName = project?.Name ?? "Project";
        var projectCode = project?.ProjectCode;

        // Fetch candidate resource and their reporting manager
        var candidate = await db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == interview.EmployeeId && e.DeletedAtUtc == null, ct);

        var candidateName = candidate is not null
            ? $"{candidate.FirstName} {candidate.LastName}".Trim()
            : interview.ResourceName;

        // Resolve updater/actor
        var updater = await FindUpdaterAsync(ct);
        var updaterName = updater is not null
            ? $"{updater.FirstName} {updater.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name)
                ? currentUser.Name
                : (!string.IsNullOrWhiteSpace(currentUser.Email) ? currentUser.Email : "Engagement Manager"));

        var notifType = interview.Result switch
        {
            "Selected" => "Customer Interview Selected",
            "Rejected" => "Customer Interview Rejected",
            "Postponed" => "Customer Interview Postponed",
            _ => $"Customer Interview {interview.Result}"
        };

        var priority = interview.Result switch
        {
            "Rejected" => "High",
            "Selected" => "Medium",
            "Postponed" => "Medium",
            _ => "Medium"
        };

        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        var remarks = !string.IsNullOrWhiteSpace(interview.Comments)
            ? $" — Remarks: \"{interview.Comments.Trim()}\""
            : "";

        var historyJson = JsonSerializer.Serialize(new[]
        {
            new
            {
                action = $"Interview result changed from '{oldResult}' to '{interview.Result}' by {updaterName}{remarks}",
                date = dateStr,
                time = timeStr,
                by = updaterName,
            }
        });

        var relatedTask = !string.IsNullOrWhiteSpace(interview.Comments)
            ? interview.Comments.Trim()
            : $"Interview date: {interview.InterviewDate:yyyy-MM-dd} at {interview.InterviewTime:HH:mm}";

        // Collect recipient IDs: Candidate Resource + Candidate's Reporting Manager
        var recipientEmployeeIds = new HashSet<Guid>();
        if (interview.EmployeeId != Guid.Empty)
        {
            recipientEmployeeIds.Add(interview.EmployeeId);
        }

        if (candidate?.ReportingManagerId is Guid mgrId && mgrId != Guid.Empty)
        {
            recipientEmployeeIds.Add(mgrId);
        }

        foreach (var recipientId in recipientEmployeeIds)
        {
            var isRecipientCandidate = recipientId == interview.EmployeeId;

            var title = isRecipientCandidate
                ? $"Customer Interview Result: {interview.Result} — {projectName}"
                : $"Customer Interview {interview.Result}: {candidateName} — {projectName}";

            var notification = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipientId,
                ProjectId = projectId,
                ProjectCode = projectCode,
                ProjectName = projectName,
                Title = title,
                Type = notifType,
                Priority = priority,
                Status = "Pending",
                Unread = true,
                RaisedByEmployeeId = updater?.Id,
                RaisedByName = updaterName,
                RelatedTask = relatedTask,
                HistoryJson = historyJson,
                CreatedAtUtc = now,
            };

            db.ActionNotifications.Add(notification);
        }
    }

    private async Task<Employee?> FindUpdaterAsync(CancellationToken ct)
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

    private async Task EnsureProjectExistsAsync(Guid projectId, CancellationToken ct)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists)
        {
            throw new NotFoundException($"Project '{projectId}' was not found.");
        }
    }

    private static ProjectInterviewDto Map(ProjectInterview row) => new(
        row.Id,
        row.ProjectId,
        row.EmployeeId,
        row.ResourceName,
        row.InterviewDate,
        row.InterviewTime,
        row.Result,
        row.Comments,
        row.CreatedAtUtc,
        row.UpdatedAtUtc);
}
