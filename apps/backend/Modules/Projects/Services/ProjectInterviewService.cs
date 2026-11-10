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

        // When we schedule interview: selected Resource and their Reporting Manager get notification with Pending status & Low priority
        await DispatchInterviewScheduledNotificationsAsync(projectId, row, ct);
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

        if (resultChanged || request.Result is not null)
        {
            await DispatchInterviewResultNotificationsAsync(projectId, row, oldResult, ct);
        }

        await db.SaveChangesAsync(ct);
        return Map(row);
    }

    private async Task DispatchInterviewScheduledNotificationsAsync(
        Guid projectId,
        ProjectInterview interview,
        CancellationToken ct)
    {
        var project = await db.Projects
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == projectId, ct);

        var projectName = project?.Name ?? "Project";
        var projectCode = project?.ProjectCode;

        var candidate = await db.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(e => e.Id == interview.EmployeeId && e.DeletedAtUtc == null, ct);

        var candidateName = candidate is not null
            ? $"{candidate.FirstName} {candidate.LastName}".Trim()
            : interview.ResourceName;

        var updater = await FindUpdaterAsync(ct);
        var updaterName = updater is not null
            ? $"{updater.FirstName} {updater.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name)
                ? currentUser.Name
                : (!string.IsNullOrWhiteSpace(currentUser.Email) ? currentUser.Email : "Engagement Manager"));

        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        var interviewTaskCode = $"INT-{interview.Id.ToString()[..8].ToUpper()}";
        var scheduleDetail = $"Interview scheduled on {interview.InterviewDate:yyyy-MM-dd} at {interview.InterviewTime:HH:mm}";

        var historyJson = JsonSerializer.Serialize(new[]
        {
            new
            {
                action = $"{scheduleDetail} by {updaterName}",
                date = dateStr,
                time = timeStr,
                by = updaterName,
                status = "Pending"
            }
        });

        var recipientEmployeeIds = new HashSet<Guid>();
        if (interview.EmployeeId != Guid.Empty)
        {
            recipientEmployeeIds.Add(interview.EmployeeId);
        }

        if (candidate?.ReportingManagerId is Guid mgrId && mgrId != Guid.Empty)
        {
            recipientEmployeeIds.Add(mgrId);
        }

        var createdNotifs = new List<ActionNotification>();
        foreach (var recipientId in recipientEmployeeIds)
        {
            var isRecipientCandidate = recipientId == interview.EmployeeId;
            var title = isRecipientCandidate
                ? $"Customer Interview Scheduled — {projectName}"
                : $"Customer Interview Scheduled: {candidateName} — {projectName}";

            var notification = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipientId,
                ProjectId = projectId,
                ProjectCode = projectCode,
                ProjectName = projectName,
                Title = title,
                Type = "Customer Interview Scheduled",
                Priority = "Low",
                Status = "Pending",
                Unread = true,
                RaisedByEmployeeId = updater?.Id,
                RaisedByName = updaterName,
                RelatedTask = interviewTaskCode,
                HistoryJson = historyJson,
                CreatedAtUtc = now,
            };

            db.ActionNotifications.Add(notification);
            createdNotifs.Add(notification);
        }

        TrySyncNotificationsToOtherDatabase(createdNotifs, interviewTaskCode, "Pending");
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

        // User requirement: "And the priority for this will always shows as Low into thire action center notification tab..."
        var priority = "Low";

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
                status = interview.Result
            }
        });

        var interviewTaskCode = $"INT-{interview.Id.ToString()[..8].ToUpper()}";

        // Update all prior notifications for this interview so they show the updated status as well
        var existingNotifs = await db.ActionNotifications
            .Where(n => (n.RelatedTask == interviewTaskCode || (n.ProjectId == projectId && n.Type.Contains("Interview") && (n.RecipientEmployeeId == interview.EmployeeId || (candidate != null && n.RecipientEmployeeId == candidate.ReportingManagerId)))) && n.DeletedAtUtc == null)
            .ToListAsync(ct);

        foreach (var ex in existingNotifs)
        {
            ex.Status = interview.Result;
            ex.Priority = "Low";
            if (string.IsNullOrWhiteSpace(ex.RelatedTask) || !ex.RelatedTask.StartsWith("INT-"))
            {
                ex.RelatedTask = interviewTaskCode;
            }
        }

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

        var createdNotifs = new List<ActionNotification>();
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
                Status = interview.Result, // Status matches the edited result!
                Unread = true,
                RaisedByEmployeeId = updater?.Id,
                RaisedByName = updaterName,
                RelatedTask = interviewTaskCode,
                HistoryJson = historyJson,
                CreatedAtUtc = now,
            };

            db.ActionNotifications.Add(notification);
            createdNotifs.Add(notification);
        }

        TrySyncNotificationsToOtherDatabase(createdNotifs, interviewTaskCode, interview.Result);
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
                updateCmd.CommandText = "UPDATE action.tbl_notifications SET \"Status\" = @stat, \"Priority\" = 'Low' WHERE \"RelatedTask\" = @task AND \"DeletedAtUtc\" IS NULL";
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
                    ON CONFLICT (""Id"") DO UPDATE SET ""Status"" = EXCLUDED.""Status"", ""Priority"" = EXCLUDED.""Priority"", ""HistoryJson"" = EXCLUDED.""HistoryJson""";

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
            // Best effort sync
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
