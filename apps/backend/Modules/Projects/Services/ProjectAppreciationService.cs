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

public sealed class ProjectAppreciationService(
    AppDbContext db,
    ICurrentUserService currentUser) : IProjectAppreciationService
{
    public async Task<IReadOnlyList<ProjectAppreciationDto>> ListAsync(Guid projectId, CancellationToken ct = default)
    {
        await EnsureProjectExistsAsync(projectId, ct);

        var rows = await db.ProjectAppreciations
            .AsNoTracking()
            .Where(x => x.ProjectId == projectId)
            .OrderByDescending(x => x.CreatedAtUtc)
            .ToListAsync(ct);

        return rows.Select(Map).ToList();
    }

    public async Task<ProjectAppreciationDto> CreateAsync(
        Guid projectId,
        CreateProjectAppreciationRequest request,
        CancellationToken ct = default)
    {
        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct)
            ?? throw new NotFoundException($"Project '{projectId}' was not found.");

        if (request.RecipientEmployeeId == Guid.Empty)
            throw new ConflictException("Select a resource to appreciate.");

        var badge = request.Badge?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(badge))
            throw new ConflictException("Select a badge.");

        var message = request.Message?.Trim() ?? "";
        if (string.IsNullOrWhiteSpace(message))
            throw new ConflictException("Appreciation message is required.");

        // Validate that the resource is present in the project's Team tab
        var onTeam = await db.ProjectTeamMembers
            .Include(m => m.Employee)
            .FirstOrDefaultAsync(m =>
                m.ProjectId == projectId
                && m.EmployeeId == request.RecipientEmployeeId
                && m.DeletedAtUtc == null, ct);

        if (onTeam is null)
        {
            throw new ConflictException("The selected resource must be a member of the project Team tab.");
        }

        var recipientName = onTeam.Employee is not null
            ? $"{onTeam.Employee.FirstName} {onTeam.Employee.LastName}".Trim()
            : "Team Member";

        var recipientEmail = onTeam.Employee?.WorkEmail;
        var recipientRole = onTeam.Employee?.Role ?? (onTeam.IsTeamLead ? "Team Lead" : onTeam.MemberRole);

        var giver = await FindGiverAsync(ct);
        var giverName = giver is not null
            ? $"{giver.FirstName} {giver.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : (currentUser.Email ?? "Team Member"));

        var row = new ProjectAppreciation
        {
            ProjectId = projectId,
            RecipientEmployeeId = request.RecipientEmployeeId,
            RecipientName = recipientName,
            RecipientEmail = recipientEmail,
            RecipientRole = recipientRole,
            Badge = badge,
            Message = message,
            GivenByEmployeeId = giver?.Id,
            GivenByName = giverName,
        };

        db.ProjectAppreciations.Add(row);

        // Dispatch Action Centre Notification directly to the recipient (notification only, not alert)
        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        var notificationHistory = new[]
        {
            new
            {
                action = $"Appreciation received: {badge} from {giverName} — \"{(message.Length > 80 ? message[..80] + "..." : message)}\"",
                date = dateStr,
                time = timeStr,
                by = giverName,
            }
        };

        var notification = new ActionNotification
        {
            Id = Guid.NewGuid(),
            RecipientEmployeeId = request.RecipientEmployeeId,
            ProjectId = project.Id,
            ProjectCode = project.ProjectCode,
            ProjectName = project.Name,
            Title = $"Appreciation: You received a {badge} badge from {giverName}!",
            Type = "Appreciation Received",
            Priority = "Low",
            Status = "Pending",
            Unread = true,
            RaisedByEmployeeId = giver?.Id,
            RaisedByName = giverName,
            RelatedTask = message.Length > 250 ? message[..250] : message,
            HistoryJson = JsonSerializer.Serialize(notificationHistory),
            CreatedAtUtc = now,
        };

        db.ActionNotifications.Add(notification);

        await db.SaveChangesAsync(ct);
        return Map(row);
    }

    private async Task EnsureProjectExistsAsync(Guid projectId, CancellationToken ct)
    {
        var exists = await db.Projects.AnyAsync(p => p.Id == projectId, ct);
        if (!exists)
            throw new NotFoundException($"Project '{projectId}' was not found.");
    }

    private async Task<Employee?> FindGiverAsync(CancellationToken ct)
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

    private static ProjectAppreciationDto Map(ProjectAppreciation row) => new(
        row.Id,
        row.ProjectId,
        row.RecipientEmployeeId,
        row.RecipientName,
        row.RecipientEmail,
        row.RecipientRole,
        row.Badge,
        row.Message,
        row.GivenByEmployeeId,
        row.GivenByName,
        row.CreatedAtUtc);
}
