using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.ActionCentre.Services;

public sealed class ActionNotificationService(
    AppDbContext db,
    ICurrentUserService currentUser) : IActionNotificationService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public async Task<IReadOnlyList<ActionNotificationDto>> GetNotificationsAsync(
        NotificationQueryParameters query,
        CancellationToken ct = default)
    {
        var currentEmpId = await ResolveCurrentEmployeeIdAsync(ct);
        var isSuperAdmin = currentUser.Role is "Admin" or "SuperAdmin" || currentUser.Email == "admin@talakunchi.com";

        var q = db.ActionNotifications
            .AsNoTracking()
            .Where(n => n.DeletedAtUtc == null);

        if (currentEmpId.HasValue)
        {
            if (isSuperAdmin)
            {
                var hasOwn = await db.ActionNotifications
                    .AsNoTracking()
                    .AnyAsync(n => n.RecipientEmployeeId == currentEmpId.Value && n.DeletedAtUtc == null, ct);
                if (hasOwn)
                {
                    q = q.Where(n => n.RecipientEmployeeId == currentEmpId.Value);
                }
            }
            else
            {
                q = q.Where(n => n.RecipientEmployeeId == currentEmpId.Value);
            }
        }
        else if (!isSuperAdmin && currentUser.UserId.HasValue)
        {
            q = q.Where(n => n.RecipientEmployeeId == currentUser.UserId.Value);
        }

        if (!string.IsNullOrWhiteSpace(query.Status) && !query.Status.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            var s = query.Status.Trim();
            q = q.Where(n => n.Status.ToLower() == s.ToLower());
        }

        if (query.ProjectId.HasValue)
        {
            q = q.Where(n => n.ProjectId == query.ProjectId.Value);
        }

        if (!string.IsNullOrWhiteSpace(query.Search))
        {
            var search = query.Search.Trim().ToLower();
            q = q.Where(n =>
                n.Title.ToLower().Contains(search) ||
                n.ProjectName.ToLower().Contains(search) ||
                (n.ProjectCode != null && n.ProjectCode.ToLower().Contains(search)) ||
                n.Type.ToLower().Contains(search) ||
                n.RaisedByName.ToLower().Contains(search) ||
                (n.RelatedTask != null && n.RelatedTask.ToLower().Contains(search)));
        }

        var rows = await q
            .OrderByDescending(n => n.CreatedAtUtc)
            .ToListAsync(ct);

        return rows.Select(MapDto).ToList();
    }

    public async Task<ActionNotificationDto> AcknowledgeNotificationAsync(
        Guid id,
        string comment,
        CancellationToken ct = default)
    {
        var notification = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.Id == id && n.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Notification '{id}' was not found.");

        if (string.IsNullOrWhiteSpace(comment))
            throw new ConflictException("Acknowledgement comment is mandatory.");

        var employee = await FindCurrentEmployeeAsync(ct);
        var userName = employee is not null
            ? $"{employee.FirstName} {employee.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : (currentUser.Email ?? "User"));

        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        var history = ParseHistory(notification.HistoryJson);
        history.Add(new NotificationHistoryItemDto
        {
            Action = $"Notification acknowledged - Remarks: \"{comment.Trim()}\"",
            Date = dateStr,
            Time = timeStr,
            By = userName
        });

        notification.Status = "Acknowledged";
        notification.Unread = false;
        notification.AcknowledgedBy = userName;
        notification.AcknowledgedDate = dateStr;
        notification.AcknowledgedTime = timeStr;
        notification.HistoryJson = JsonSerializer.Serialize(history);
        notification.UpdatedAtUtc = now;

        await db.SaveChangesAsync(ct);

        return MapDto(notification);
    }

    public async Task<ActionNotificationDto> MarkNotificationAsReadAsync(
        Guid id,
        CancellationToken ct = default)
    {
        var notification = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.Id == id && n.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Notification '{id}' was not found.");

        if (notification.Unread)
        {
            var now = DateTime.UtcNow;
            var dateStr = now.ToString("yyyy-MM-dd");
            var timeStr = now.ToString("HH:mm:ss");

            var history = ParseHistory(notification.HistoryJson);
            history.Add(new NotificationHistoryItemDto
            {
                Action = "Notification marked as read",
                Date = dateStr,
                Time = timeStr,
                By = "System"
            });

            notification.Unread = false;
            notification.HistoryJson = JsonSerializer.Serialize(history);
            notification.UpdatedAtUtc = now;

            await db.SaveChangesAsync(ct);
        }

        return MapDto(notification);
    }

    // ── Action Centre Alerts ─────────────────────────────────────────────────

    public async Task<IReadOnlyList<ActionAlertDto>> GetAlertsAsync(
        NotificationQueryParameters query,
        CancellationToken ct = default)
    {
        var currentEmpId = await ResolveCurrentEmployeeIdAsync(ct);
        var role = (currentUser.Role ?? "").Trim();
        var isSuperAdmin = role.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("PMO", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("CEO", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("COO", StringComparison.OrdinalIgnoreCase)
                           || currentUser.Email == "admin@talakunchi.com";

        var q = db.ProjectAlerts
            .AsNoTracking()
            .Include(a => a.Project)
                .ThenInclude(p => p!.Client)
            .Where(a => a.DeletedAtUtc == null);

        if (!isSuperAdmin && currentEmpId.HasValue)
        {
            var empId = currentEmpId.Value;
            var empIdStr = empId.ToString();

            q = q.Where(a =>
                (a.AudienceUserIds != null && a.AudienceUserIds.Contains(empIdStr)) ||
                (a.Project != null && (
                    a.Project.ProjectManagerId == empId ||
                    a.Project.EngagementManagerId == empId ||
                    (a.Project.Client != null && a.Project.Client.EngagementManagerId == empId) ||
                    a.Project.TeamLeadId == empId
                )));
        }

        if (!string.IsNullOrWhiteSpace(query.Status) && !query.Status.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            var s = query.Status.Trim();
            q = q.Where(a => a.Status.ToLower() == s.ToLower());
        }

        if (query.ProjectId.HasValue)
        {
            q = q.Where(a => a.ProjectId == query.ProjectId.Value);
        }

        if (!string.IsNullOrWhiteSpace(query.Search))
        {
            var search = query.Search.Trim().ToLower();
            q = q.Where(a =>
                a.Title.ToLower().Contains(search) ||
                (a.Description != null && a.Description.ToLower().Contains(search)) ||
                a.RaisedByName.ToLower().Contains(search) ||
                (a.Project != null && a.Project.Name.ToLower().Contains(search)));
        }

        var rows = await q
            .OrderByDescending(a => a.CreatedAtUtc)
            .ToListAsync(ct);

        return rows.Select(MapAlertDto).ToList();
    }

    public async Task<ActionAlertDto> UpdateAlertGovernanceAsync(
        Guid id,
        UpdateAlertGovernanceRequest request,
        CancellationToken ct = default)
    {
        var alert = await db.ProjectAlerts
            .Include(a => a.Project)
                .ThenInclude(p => p!.Client)
            .Include(a => a.Issue)
            .FirstOrDefaultAsync(a => a.Id == id && a.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Alert '{id}' was not found.");

        var employee = await FindCurrentEmployeeAsync(ct);
        var userName = employee is not null
            ? $"{employee.FirstName} {employee.LastName}".Trim()
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : (currentUser.Email ?? "User"));

        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        alert.Status = string.IsNullOrWhiteSpace(request.Status) ? alert.Status : request.Status.Trim();
        if (request.Owner != null) alert.Owner = request.Owner.Trim();
        if (request.ResolutionOwner != null) alert.ResolutionOwner = request.ResolutionOwner.Trim();
        if (request.EscalationOwner != null) alert.EscalationOwner = request.EscalationOwner.Trim();
        if (request.ResolutionDetails != null) alert.ResolutionDetails = request.ResolutionDetails.Trim();

        var history = ParseHistory(alert.HistoryJson);
        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            history.Add(new NotificationHistoryItemDto
            {
                Action = $"Comment added: \"{request.Comment.Trim()}\"",
                Date = dateStr,
                Time = timeStr,
                By = userName
            });
        }
        history.Add(new NotificationHistoryItemDto
        {
            Action = $"Governance updated - Status: {alert.Status}",
            Date = dateStr,
            Time = timeStr,
            By = userName
        });
        alert.HistoryJson = JsonSerializer.Serialize(history);
        alert.UpdatedAtUtc = now;

        // Synchronize linked issue if closed or resolved
        if (alert.Issue != null && (alert.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase) ||
                                    alert.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase)))
        {
            alert.Issue.Status = alert.Status;
            alert.Issue.UpdatedAtUtc = now;
        }

        await db.SaveChangesAsync(ct);

        return MapAlertDto(alert);
    }

    private async Task<Guid?> ResolveCurrentEmployeeIdAsync(CancellationToken ct)
    {
        var userId = currentUser.UserId;
        var email = currentUser.Email?.Trim().ToLowerInvariant();

        if (userId.HasValue)
        {
            var empExists = await db.Employees
                .AsNoTracking()
                .AnyAsync(e => e.Id == userId.Value && e.DeletedAtUtc == null, ct);
            if (empExists) return userId.Value;

            var empByUserId = await db.Employees
                .AsNoTracking()
                .Where(e => e.UserId == userId.Value && e.DeletedAtUtc == null)
                .Select(e => (Guid?)e.Id)
                .FirstOrDefaultAsync(ct);
            if (empByUserId.HasValue) return empByUserId.Value;
        }

        if (!string.IsNullOrWhiteSpace(email))
        {
            var empByEmail = await db.Employees
                .AsNoTracking()
                .Where(e => e.DeletedAtUtc == null &&
                    ((e.WorkEmail != null && e.WorkEmail.ToLower() == email) ||
                     (e.PersonalEmail != null && e.PersonalEmail.ToLower() == email)))
                .Select(e => (Guid?)e.Id)
                .FirstOrDefaultAsync(ct);
            if (empByEmail.HasValue) return empByEmail.Value;
        }

        return null;
    }

    private async Task<PMS.API.Modules.Resources.Models.Employee?> FindCurrentEmployeeAsync(CancellationToken ct)
    {
        var userId = currentUser.UserId;
        var email = currentUser.Email?.Trim().ToLowerInvariant();

        if (userId.HasValue)
        {
            var emp = await db.Employees
                .FirstOrDefaultAsync(e => e.Id == userId.Value && e.DeletedAtUtc == null, ct);
            if (emp != null) return emp;

            emp = await db.Employees
                .FirstOrDefaultAsync(e => e.UserId == userId.Value && e.DeletedAtUtc == null, ct);
            if (emp != null) return emp;
        }

        if (!string.IsNullOrWhiteSpace(email))
        {
            var emp = await db.Employees
                .FirstOrDefaultAsync(e => e.DeletedAtUtc == null &&
                    ((e.WorkEmail != null && e.WorkEmail.ToLower() == email) ||
                     (e.PersonalEmail != null && e.PersonalEmail.ToLower() == email)), ct);
            if (emp != null) return emp;
        }

        return null;
    }

    private static List<NotificationHistoryItemDto> ParseHistory(string? json)
    {
        if (string.IsNullOrWhiteSpace(json)) return [];
        try
        {
            return JsonSerializer.Deserialize<List<NotificationHistoryItemDto>>(json, JsonOptions) ?? [];
        }
        catch
        {
            return [];
        }
    }

    private static ActionNotificationDto MapDto(ActionNotification n)
    {
        var relatedProj = !string.IsNullOrWhiteSpace(n.ProjectCode)
            ? $"{n.ProjectCode} - {n.ProjectName}"
            : n.ProjectName;

        return new ActionNotificationDto
        {
            Id = n.Id.ToString(),
            Title = n.Title,
            Type = n.Type,
            RelatedProject = relatedProj,
            RelatedTask = n.RelatedTask,
            RaisedBy = n.RaisedByName,
            CreatedAt = n.CreatedAtUtc.ToString("o"),
            Status = n.Status,
            Priority = n.Priority,
            Unread = n.Unread,
            AcknowledgedBy = n.AcknowledgedBy,
            AcknowledgedDate = n.AcknowledgedDate,
            AcknowledgedTime = n.AcknowledgedTime,
            CreatedBy = n.RaisedByName,
            CreatedDate = n.CreatedAtUtc.ToString("yyyy-MM-dd"),
            History = ParseHistory(n.HistoryJson),
            ProjectId = n.ProjectId,
            IssueId = n.IssueId
        };
    }

    private static ActionAlertDto MapAlertDto(ProjectAlert a)
    {
        var audience = new List<string>();
        if (!string.IsNullOrWhiteSpace(a.AudienceUserIds))
        {
            try
            {
                audience = JsonSerializer.Deserialize<List<string>>(a.AudienceUserIds, JsonOptions) ?? [];
            }
            catch
            {
                // fallback
            }
        }

        return new ActionAlertDto
        {
            Id = a.Id.ToString(),
            AlertId = $"ALT-{a.Id.ToString()[..8].ToUpper()}",
            Title = a.Title,
            Description = a.Description,
            ProjectId = a.ProjectId.ToString(),
            ProjectName = a.Project?.Name ?? "",
            CustomerId = a.Project != null ? a.Project.ClientId.ToString() : null,
            CustomerName = a.Project?.Client?.Name ?? "",
            AlertType = a.AlertType ?? "Issue",
            Priority = a.Priority,
            Status = a.Status,
            RaisedByEmployeeId = a.RaisedByEmployeeId,
            RaisedByName = a.RaisedByName,
            AudienceUserIds = audience,
            CreatedAt = a.CreatedAtUtc.ToString("o"),
            Owner = a.Owner ?? a.RaisedByName,
            ResolutionOwner = a.ResolutionOwner,
            EscalationOwner = a.EscalationOwner,
            ResolutionDetails = a.ResolutionDetails,
            History = ParseHistory(a.HistoryJson)
        };
    }
}
