using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectInterviewService(AppDbContext db) : IProjectInterviewService
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

        if (request.Result is not null)
        {
            row.Result = request.Result;
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
        await db.SaveChangesAsync(ct);
        return Map(row);
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
