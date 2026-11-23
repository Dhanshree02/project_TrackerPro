using System.Collections.Concurrent;
using System.Text.Json;
using Hangfire;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Sla.Models;
using PMS.API.Modules.Sla.Services;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.ActionCentre.Services;

public sealed class ActionNotificationService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IFileStorageService storage,
    ISlaTrackingService slaTrackingService,
    ISlaRecipientResolver? slaRecipientResolver = null,
    ISlaDeadlineCalculator? deadlineCalculator = null,
    ILogger<ActionNotificationService>? logger = null) : IActionNotificationService
{
    private static readonly ConcurrentDictionary<Guid, string> s_activeReminderJobs = new();
    private static readonly ConcurrentDictionary<Guid, string> s_activeHodJobs = new();
    private static readonly ConcurrentDictionary<Guid, string> s_activeServiceL1Jobs = new();
    private static readonly ConcurrentDictionary<Guid, string> s_activeServiceL2Jobs = new();
    private static readonly ConcurrentDictionary<Guid, string> s_activeServicePrereqReminderJobs = new();

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
            .Include(n => n.Issue)
            .Include(n => n.ServiceEscalation)
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
                var empId = currentEmpId.Value;
                var uId = currentUser.UserId;
                if (uId.HasValue && uId.Value != empId)
                {
                    q = q.Where(n => n.RecipientEmployeeId == empId || n.RecipientEmployeeId == uId.Value);
                }
                else
                {
                    q = q.Where(n => n.RecipientEmployeeId == empId);
                }
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
                n.NotificationNumber.ToString().Contains(search) ||
                n.Title.ToLower().Contains(search) ||
                n.ProjectName.ToLower().Contains(search) ||
                (n.ProjectCode != null && n.ProjectCode.ToLower().Contains(search)) ||
                n.Type.ToLower().Contains(search) ||
                n.RaisedByName.ToLower().Contains(search) ||
                (n.RelatedTask != null && n.RelatedTask.ToLower().Contains(search)));

        }



        var rows = await q
            .OrderByDescending(n => n.CreatedAtUtc)
            .ThenByDescending(n => n.Id)
            .ToListAsync(ct);



        return rows.Select(MapDto).ToList();

    }



    public async Task<ActionNotificationDto> MarkNotificationAsReadAsync(

        Guid id,

        CancellationToken ct = default)

    {

        var notification = await db.ActionNotifications
            .Include(n => n.Issue)
            .Include(n => n.ServiceEscalation)
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

                By = "System",
                At = now.ToString("o")

            });



            notification.Unread = false;

            notification.HistoryJson = JsonSerializer.Serialize(history);

            notification.UpdatedAtUtc = now;



            await db.SaveChangesAsync(ct);

        }



        return MapDto(notification);

    }



    public async Task<ActionNotificationDto> ArchiveNotificationAsync(

        Guid id,

        string? comment = null,

        CancellationToken ct = default)

    {

        var notification = await db.ActionNotifications
            .Include(n => n.Issue)
            .Include(n => n.ServiceEscalation)
            .FirstOrDefaultAsync(n => n.Id == id && n.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Notification '{id}' was not found.");



        var employee = await FindCurrentEmployeeAsync(ct);

        var userName = employee is not null

            ? $"{employee.FirstName} {employee.LastName}".Trim()

            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : (currentUser.Email?.Split('@')[0] ?? "User"));



        var now = DateTime.UtcNow;

        var dateStr = now.ToString("yyyy-MM-dd");

        var timeStr = now.ToString("HH:mm:ss");



        var history = ParseHistory(notification.HistoryJson);

        var actionText = string.IsNullOrWhiteSpace(comment)

            ? "Notification moved to archive"

            : $"Notification moved to archive (Remarks: \"{comment.Trim()}\")";



        history.Add(new NotificationHistoryItemDto

        {

            Action = actionText,

            Date = dateStr,

            Time = timeStr,

            By = userName,
            At = now.ToString("o")

        });



        notification.Status = "Acknowledged";

        notification.Unread = false;

        notification.HistoryJson = JsonSerializer.Serialize(history);

        notification.UpdatedAtUtc = now;



        await db.SaveChangesAsync(ct);

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
            var userIdStr = currentUser.UserId?.ToString();

            var spmProjectIds = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.EmployeeId == empId && tm.DeletedAtUtc == null &&
                             (tm.MemberRole == ProjectMemberRoles.SeniorProjectManager ||
                              tm.MemberRole == "Senior Project Manager" ||
                              tm.MemberRole == "Senior PM" ||
                              tm.MemberRole == "SPM"))
                .Select(tm => tm.ProjectId)
                .Distinct()
                .ToListAsync(ct);

            var stakeholderEscalationIds = await db.ProjectServiceEscalationStakeholders
                .AsNoTracking()
                .Where(s => s.EmployeeId == empId)
                .Select(s => s.EscalationId)
                .Distinct()
                .ToListAsync(ct);

            q = q.Where(a =>
                (a.AudienceUserIds != null && (a.AudienceUserIds.Contains(empIdStr) || (userIdStr != null && a.AudienceUserIds.Contains(userIdStr)))) ||
                (spmProjectIds.Count > 0 && spmProjectIds.Contains(a.ProjectId)) ||
                (a.ServiceEscalationId.HasValue && stakeholderEscalationIds.Count > 0 && stakeholderEscalationIds.Contains(a.ServiceEscalationId.Value)) ||
                (a.Project != null && (
                    a.Project.ProjectManagerId == empId ||
                    a.Project.EngagementManagerId == empId ||
                    (a.Project.Client != null && a.Project.Client.EngagementManagerId == empId) ||
                    a.Project.TeamLeadId == empId
                )));
        }
        else if (!isSuperAdmin && currentUser.UserId.HasValue)
        {
            var userIdStr = currentUser.UserId.Value.ToString();
            q = q.Where(a => a.AudienceUserIds != null && a.AudienceUserIds.Contains(userIdStr));
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
            .ThenByDescending(a => a.Id)
            .ToListAsync(ct);



        // Backfill any escalation details if not directly present on older project alert records

        var wbsAlerts = rows.Where(r => (r.AlertType == "WBS Escalation" || (r.AlertType != null && r.AlertType.StartsWith("WBS", StringComparison.OrdinalIgnoreCase)) || r.ServiceEscalationId.HasValue) && (r.AttachmentFileName == null || r.ExpectedResolutionDate == null)).ToList();

        if (wbsAlerts.Count > 0)

        {

            var projectIds = wbsAlerts.Select(w => w.ProjectId).Distinct().ToList();

            var escalations = await db.ProjectServiceEscalations

                .AsNoTracking()

                .Include(e => e.Stakeholders)

                .Where(e => projectIds.Contains(e.ProjectId))

                .ToListAsync(ct);



            foreach (var alertRow in wbsAlerts)

            {

                var matchEsc = escalations.FirstOrDefault(e => e.Id == alertRow.ServiceEscalationId)

                               ?? escalations.FirstOrDefault(e => e.ProjectId == alertRow.ProjectId && alertRow.Title.Contains(e.ServiceName));

                if (matchEsc != null)

                {

                    if (string.IsNullOrWhiteSpace(alertRow.AttachmentFileName) && !string.IsNullOrWhiteSpace(matchEsc.AttachmentFileName))

                    {

                        alertRow.AttachmentFileName = matchEsc.AttachmentFileName;

                        alertRow.AttachmentPath = matchEsc.AttachmentPath;

                    }

                    if (string.IsNullOrWhiteSpace(alertRow.ExpectedResolutionDate) && matchEsc.ExpectedResolutionDate.HasValue)

                    {

                        alertRow.ExpectedResolutionDate = matchEsc.ExpectedResolutionDate.Value.ToString("yyyy-MM-dd");

                    }

                    if (string.IsNullOrWhiteSpace(alertRow.ServiceName))

                    {

                        alertRow.ServiceName = matchEsc.ServiceName;

                    }

                    if (string.IsNullOrWhiteSpace(alertRow.EscalationType))

                    {

                        alertRow.EscalationType = matchEsc.EscalationType;

                    }

                    if (string.IsNullOrWhiteSpace(alertRow.ResolutionDetails) && matchEsc.ExpectedResolutionDate.HasValue)

                    {

                        alertRow.ResolutionDetails = $"Expected Resolution Date: {matchEsc.ExpectedResolutionDate.Value:yyyy-MM-dd}";

                    }

                    if (string.IsNullOrWhiteSpace(alertRow.EscalatedTo) && matchEsc.Stakeholders.Count > 0)

                    {

                        alertRow.EscalatedTo = JsonSerializer.Serialize(matchEsc.Stakeholders.Select(s => s.EmployeeName).ToList());

                    }

                    if (string.IsNullOrWhiteSpace(alertRow.ChatJson) && !string.IsNullOrWhiteSpace(matchEsc.ChatJson))

                    {

                        alertRow.ChatJson = matchEsc.ChatJson;

                    }

                }

            }

        }



        var missingProjectEscalationIds = rows
            .Where(r => r.Project == null && r.ServiceEscalationId.HasValue)
            .Select(r => r.ServiceEscalationId!.Value)
            .Distinct()
            .ToList();

        Dictionary<Guid, string> escProjectNames = [];
        if (missingProjectEscalationIds.Count > 0)
        {
            escProjectNames = await db.ProjectServiceEscalations
                .AsNoTracking()
                .Where(e => missingProjectEscalationIds.Contains(e.Id))
                .ToDictionaryAsync(e => e.Id, e => e.ProjectName, ct);
        }

        return rows.Select(r => MapAlertDto(r, escProjectNames)).ToList();

    }



    public async Task<(Stream Stream, string ContentType, string FileName)?> DownloadAlertAttachmentAsync(

        Guid id,

        CancellationToken ct = default)

    {

        var alert = await db.ProjectAlerts

            .AsNoTracking()

            .FirstOrDefaultAsync(a => a.Id == id && a.DeletedAtUtc == null, ct);



        if (alert == null) return null;



        var path = alert.AttachmentPath;

        var name = alert.AttachmentFileName;



        if (string.IsNullOrWhiteSpace(path) && (alert.AlertType == "WBS Escalation" || (alert.AlertType != null && alert.AlertType.StartsWith("WBS", StringComparison.OrdinalIgnoreCase)) || alert.ServiceEscalationId.HasValue))

        {

            var matchEsc = await db.ProjectServiceEscalations

                .AsNoTracking()

                .FirstOrDefaultAsync(e => e.Id == alert.ServiceEscalationId || (e.ProjectId == alert.ProjectId && alert.Title.Contains(e.ServiceName)), ct);

            if (matchEsc != null)

            {

                path = matchEsc.AttachmentPath;

                name = matchEsc.AttachmentFileName;

            }

        }



        if (string.IsNullOrWhiteSpace(path)) return null;



        var fileResult = storage.GetProjectFileStream(path);

        if (fileResult == null) return null;



        return (fileResult.Value.Stream, fileResult.Value.ContentType, name ?? Path.GetFileName(path));

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

        var role = (currentUser.Role ?? "").Trim();
        var isSuperAdmin = role.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("PMO", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("CEO", StringComparison.OrdinalIgnoreCase)
                           || role.Equals("COO", StringComparison.OrdinalIgnoreCase)
                           || currentUser.Email == "admin@talakunchi.com";

        if (!isSuperAdmin && employee != null)
        {
            var empId = employee.Id;
            var empIdStr = empId.ToString();
            var userIdStr = currentUser.UserId?.ToString();

            var isAudience = !string.IsNullOrWhiteSpace(alert.AudienceUserIds) &&
                             (alert.AudienceUserIds.Contains(empIdStr) || (userIdStr != null && alert.AudienceUserIds.Contains(userIdStr)));
            var isProjectManager = alert.Project != null && (
                alert.Project.ProjectManagerId == empId ||
                alert.Project.EngagementManagerId == empId ||
                (alert.Project.Client != null && alert.Project.Client.EngagementManagerId == empId) ||
                alert.Project.TeamLeadId == empId);
            var isRaiser = alert.RaisedByEmployeeId == empId;

            var isStakeholder = false;
            if (alert.ServiceEscalationId.HasValue)
            {
                isStakeholder = await db.ProjectServiceEscalationStakeholders
                    .AnyAsync(s => s.EscalationId == alert.ServiceEscalationId.Value && s.EmployeeId == empId, ct);
            }

            var isSpm = await db.ProjectTeamMembers
                .AnyAsync(tm => tm.ProjectId == alert.ProjectId && tm.EmployeeId == empId && tm.DeletedAtUtc == null &&
                                (tm.MemberRole == ProjectMemberRoles.SeniorProjectManager ||
                                 tm.MemberRole == "Senior Project Manager" ||
                                 tm.MemberRole == "Senior PM" ||
                                 tm.MemberRole == "SPM"), ct);

            if (!isAudience && !isProjectManager && !isRaiser && !isStakeholder && !isSpm)
            {
                throw new ForbiddenException("You do not have permission to update this alert.");
            }
        }



        var now = DateTime.UtcNow;

        var dateStr = now.ToString("yyyy-MM-dd");

        var timeStr = now.ToString("HH:mm:ss");



        var oldStatus = alert.Status;

        var newStatus = string.IsNullOrWhiteSpace(request.Status) ? alert.Status : request.Status.Trim();

        alert.Status = newStatus;

        if (request.Owner != null) alert.Owner = request.Owner.Trim();

        if (request.ResolutionOwner != null) alert.ResolutionOwner = request.ResolutionOwner.Trim();

        if (request.EscalationOwner != null) alert.EscalationOwner = request.EscalationOwner.Trim();

        if (request.ResolutionDetails != null) alert.ResolutionDetails = request.ResolutionDetails.Trim();



        if (!string.Equals(oldStatus, newStatus, StringComparison.OrdinalIgnoreCase) || string.IsNullOrWhiteSpace(alert.StatusChangedBy))

        {

            alert.StatusChangedBy = userName;

            alert.StatusChangedAtUtc = now;

        }



        if (string.IsNullOrWhiteSpace(alert.ResolutionOwner) && (alert.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) || alert.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase)))

        {

            alert.ResolutionOwner = userName;

        }



        var history = ParseHistory(alert.HistoryJson);

        var newCommentsToAdd = new List<string>();

        if (!string.IsNullOrWhiteSpace(request.Comment))

        {

            newCommentsToAdd.Add(request.Comment.Trim());

        }

        if (request.Comments != null && request.Comments.Count > 0)

        {

            foreach (var c in request.Comments)

            {

                if (!string.IsNullOrWhiteSpace(c))

                {

                    newCommentsToAdd.Add(c.Trim());

                }

            }

        }



        if (newCommentsToAdd.Count > 0)

        {

            var commentsList = ParseComments(alert.ChatJson);

            foreach (var rawComment in newCommentsToAdd)

            {

                var commentText = rawComment.Length > 50 ? rawComment[..50] : rawComment;

                commentsList.Add(new AlertCommentDto

                {

                    Id = Guid.NewGuid().ToString(),

                    AuthorName = userName,

                    AuthorEmail = currentUser.Email,

                    Text = commentText,

                    At = now.ToString("o")

                });



                history.Add(new NotificationHistoryItemDto

                {

                    Action = $"Comment added: \"{commentText}\"",

                    Date = dateStr,

                    Time = timeStr,

                    By = userName,
            At = now.ToString("o")

                });

            }



            var serializedComments = JsonSerializer.Serialize(commentsList, JsonOptions);

            alert.ChatJson = serializedComments;

        }



        if (alert.ServiceEscalationId.HasValue)

        {

            var esc = await db.ProjectServiceEscalations.FirstOrDefaultAsync(e => e.Id == alert.ServiceEscalationId.Value, ct);

            if (esc != null)

            {

                if (!string.IsNullOrWhiteSpace(alert.Status))

                {

                    esc.Status = alert.Status;

                }

                if (!string.IsNullOrWhiteSpace(alert.ChatJson))

                {

                    esc.ChatJson = alert.ChatJson;

                }

                esc.UpdatedAtUtc = now;

            }



            var siblings = await db.ProjectAlerts

                .Where(a => a.ServiceEscalationId == alert.ServiceEscalationId.Value && a.Id != alert.Id && a.DeletedAtUtc == null)

                .ToListAsync(ct);

            foreach (var sib in siblings)

            {

                sib.Status = alert.Status;

                sib.StatusChangedBy = alert.StatusChangedBy;

                sib.StatusChangedAtUtc = alert.StatusChangedAtUtc;

                if (!string.IsNullOrWhiteSpace(alert.ChatJson))

                {

                    sib.ChatJson = alert.ChatJson;

                }

                sib.UpdatedAtUtc = now;

            }

        }

        history.Add(new NotificationHistoryItemDto

        {

            Action = $"Governance updated - Status: {alert.Status}",

            Date = dateStr,

            Time = timeStr,

            By = userName,
            At = now.ToString("o")

        });

        alert.HistoryJson = JsonSerializer.Serialize(history);

        alert.UpdatedAtUtc = now;



        // Synchronize linked issue
        if (alert.Issue != null)
        {
            if (alert.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase) ||
                alert.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase))
            {
                alert.Issue.Status = alert.Status;
                alert.Issue.UpdatedAtUtc = now;
            }
            else if (alert.Status.Equals("In Progress", StringComparison.OrdinalIgnoreCase) ||
                     alert.Status.Equals("Open", StringComparison.OrdinalIgnoreCase))
            {
                alert.Issue.Status = alert.Status;
                alert.Issue.UpdatedAtUtc = now;
            }
        }

        // Sync linked WBS escalation status & chat if applicable
        if (alert.ServiceEscalationId.HasValue)
        {
            var esc = await db.ProjectServiceEscalations.FirstOrDefaultAsync(e => e.Id == alert.ServiceEscalationId.Value, ct);
            if (esc != null)
            {
                esc.Status = alert.Status;
                if (!string.IsNullOrWhiteSpace(alert.ChatJson))
                {
                    esc.ChatJson = alert.ChatJson;
                }
                esc.UpdatedAtUtc = now;
            }
        }

        // Synchronize status and history to all related notifications for this issue across all recipients
        var targetIssueId = alert.IssueId ?? alert.Issue?.Id;
        if (targetIssueId.HasValue)
        {
            var relatedNotifs = await db.ActionNotifications
                .Where(n => n.IssueId == targetIssueId.Value
                            && n.Type != "Issue Status Update"
                            && n.Type != "Issue Escalation Reminder"
                            && n.DeletedAtUtc == null)
                .ToListAsync(ct);

            foreach (var notif in relatedNotifs)
            {
                notif.Status = alert.Status;
                notif.HistoryJson = alert.HistoryJson;
                notif.UpdatedAtUtc = now;
            }
        }

        // Synchronize status and history to all related notifications for WBS Escalation across all recipients
        if (alert.ServiceEscalationId.HasValue || alert.AlertType == "WBS Escalation" || (alert.AlertType != null && alert.AlertType.StartsWith("WBS", StringComparison.OrdinalIgnoreCase)) || (alert.Title != null && alert.Title.Contains("WBS Escalation")))
        {
            var relatedWbsNotifs = await db.ActionNotifications
                .Where(n => (n.Type == "WBS Escalation" || n.Title.Contains("WBS Escalation"))
                            && n.Type != "WBS Escalation Status Update"
                            && n.Type != "WBS Escalation Reminder"
                            && n.ProjectId == alert.ProjectId
                            && n.DeletedAtUtc == null
                            && (alert.ServiceEscalationId == null || n.ServiceEscalationId == null || n.ServiceEscalationId == alert.ServiceEscalationId.Value))
                .ToListAsync(ct);

            foreach (var notif in relatedWbsNotifs)
            {
                notif.Status = alert.Status;
                notif.HistoryJson = alert.HistoryJson;
                notif.UpdatedAtUtc = now;
            }
        }

        await db.SaveChangesAsync(ct);

        // Complete SLA tracking if resolved or closed
        var issueIdForSla = alert.IssueId ?? alert.Issue?.Id;
        if (issueIdForSla.HasValue && (alert.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase) ||
                                       alert.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase)))
        {
            try
            {
                await slaTrackingService.CompleteTrackingAsync(issueIdForSla.Value, "Resolution of Issues", ct);
            }
            catch
            {
                // Non-fatal
            }
        }

        // Complete SLA tracking for WBS Escalation if resolved or closed
        if (alert.ServiceEscalationId.HasValue && (alert.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase) ||
                                                   alert.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase)))
        {
            try
            {
                await slaTrackingService.CompleteTrackingAsync(alert.ServiceEscalationId.Value, "WBS Escalation", ct);
            }
            catch
            {
                // Non-fatal
            }
        }

        // Dispatch status update notifications according to the dynamic SLA recipient matrix
        if (!string.Equals(oldStatus, newStatus, StringComparison.OrdinalIgnoreCase))
        {
            var actorEmpId = employee?.Id ?? await ResolveCurrentEmployeeIdAsync(ct);
            var isIssueAlert = alert.IssueId.HasValue || alert.Issue != null
                               || (alert.AlertType != null && alert.AlertType.StartsWith("issue", StringComparison.OrdinalIgnoreCase));

            if (isIssueAlert)
            {
                await SendIssueStatusChangeNotificationsAsync(alert, oldStatus, newStatus, userName, actorEmpId, ct);
            }
            else if (alert.ServiceEscalationId.HasValue)
            {
                await SendWbsEscalationStatusChangeNotificationsAsync(alert, oldStatus, newStatus, userName, actorEmpId, ct);
            }
        }

        if (string.IsNullOrWhiteSpace(alert.Project?.Name) && alert.ServiceEscalationId.HasValue)
        {
            var fallbackName = await db.ProjectServiceEscalations
                .AsNoTracking()
                .Where(e => e.Id == alert.ServiceEscalationId.Value)
                .Select(e => e.ProjectName)
                .FirstOrDefaultAsync(ct);
            return MapAlertDto(alert, fallbackName != null ? new Dictionary<Guid, string> { [alert.ServiceEscalationId.Value] = fallbackName } : null);
        }

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

            var userRecord = await db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == userId.Value, ct);
            if (userRecord != null && !string.IsNullOrWhiteSpace(userRecord.EmployeeId))
            {
                var empByCode = await db.Employees
                    .AsNoTracking()
                    .Where(e => e.EmployeeCode == userRecord.EmployeeId && e.DeletedAtUtc == null)
                    .Select(e => (Guid?)e.Id)
                    .FirstOrDefaultAsync(ct);
                if (empByCode.HasValue) return empByCode.Value;
            }

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
            using var doc = JsonDocument.Parse(json);
            if (doc.RootElement.ValueKind != JsonValueKind.Array) return [];

            var list = new List<NotificationHistoryItemDto>();
            foreach (var elem in doc.RootElement.EnumerateArray())
            {
                if (elem.ValueKind != JsonValueKind.Object) continue;

                var item = new NotificationHistoryItemDto();

                if (elem.TryGetProperty("action", out var pAction) && pAction.ValueKind == JsonValueKind.String)
                    item.Action = pAction.GetString() ?? "";

                if (elem.TryGetProperty("details", out var pDetails) && pDetails.ValueKind == JsonValueKind.String)
                {
                    item.Details = pDetails.GetString();
                    if (string.IsNullOrWhiteSpace(item.Action))
                        item.Action = item.Details ?? "";
                }

                if (elem.TryGetProperty("status", out var pStatus) && pStatus.ValueKind == JsonValueKind.String)
                {
                    item.Status = pStatus.GetString();
                    if (string.IsNullOrWhiteSpace(item.Action))
                        item.Action = $"Status: {item.Status}";
                }

                if (elem.TryGetProperty("by", out var pBy) && pBy.ValueKind == JsonValueKind.String)
                    item.By = pBy.GetString() ?? "";
                else if (elem.TryGetProperty("updatedBy", out var pUpBy) && pUpBy.ValueKind == JsonValueKind.String)
                    item.By = pUpBy.GetString() ?? "";

                if (elem.TryGetProperty("at", out var pAt) && pAt.ValueKind == JsonValueKind.String)
                {
                    item.At = pAt.GetString();
                    if (DateTime.TryParse(item.At, null, System.Globalization.DateTimeStyles.RoundtripKind, out var dtAt))
                    {
                        var utc = dtAt.Kind == DateTimeKind.Utc ? dtAt : dtAt.ToUniversalTime();
                        item.Date = utc.ToString("yyyy-MM-dd");
                        item.Time = utc.ToString("HH:mm:ss");
                    }
                }

                if (elem.TryGetProperty("date", out var pDate) && pDate.ValueKind == JsonValueKind.String)
                    item.Date = pDate.GetString() ?? "";

                if (elem.TryGetProperty("time", out var pTime) && pTime.ValueKind == JsonValueKind.String)
                    item.Time = pTime.GetString() ?? "";

                if (string.IsNullOrWhiteSpace(item.At) && !string.IsNullOrWhiteSpace(item.Date) && !string.IsNullOrWhiteSpace(item.Time))
                {
                    if (DateTime.TryParse($"{item.Date} {item.Time}", out var parsedDt))
                    {
                        item.At = DateTime.SpecifyKind(parsedDt, DateTimeKind.Utc).ToString("o");
                    }
                }

                list.Add(item);
            }
            return list;
        }
        catch
        {
            return [];
        }
    }



    private static ActionNotificationDto MapDto(ActionNotification n)
    {
        var relatedProj = n.ProjectName == "-"
            ? "-"
            : (!string.IsNullOrWhiteSpace(n.ProjectCode)
                ? $"{n.ProjectCode} - {n.ProjectName}"
                : (string.IsNullOrWhiteSpace(n.ProjectName) ? "-" : n.ProjectName));

        var notifCode = n.NotificationNumber > 0
            ? $"NOT-{n.NotificationNumber:D4}"
            : $"NOT-{n.Id.ToString()[..8].ToUpper()}";

        var notifHistory = ParseHistory(n.HistoryJson);
        if (notifHistory.Count == 0)
        {
            notifHistory.Add(new NotificationHistoryItemDto
            {
                Action = "Notification created",
                Date = n.CreatedAtUtc.ToString("yyyy-MM-dd"),
                Time = n.CreatedAtUtc.ToString("HH:mm:ss"),
                By = n.RaisedByName,
                At = n.CreatedAtUtc.ToString("o")
            });
        }

        return new ActionNotificationDto
        {
            Id = n.Id.ToString(),
            NotificationCode = notifCode,
            Title = n.Title,
            Type = n.Type,
            RelatedProject = relatedProj,
            RelatedTask = n.RelatedTask,
            RaisedBy = n.RaisedByName,
            CreatedAt = n.CreatedAtUtc.ToString("o"),
            CreatedAtUtc = n.CreatedAtUtc,
            Status = n.Status,
            Priority = n.Priority,
            Unread = n.Unread,
            CreatedBy = n.RaisedByName,
            CreatedDate = n.CreatedAtUtc.ToString("yyyy-MM-dd"),
            History = notifHistory,
            Comments = ParseComments(n.CommentsJson),
            ProjectId = n.ProjectId,
            IssueId = n.IssueId,
            IssueTitle = n.Issue?.Subject ?? n.ServiceEscalation?.Subject,
            IssueDescription = n.Issue?.Description ?? n.ServiceEscalation?.Description,
            IssueType = n.Issue?.IssueType ?? n.ServiceEscalation?.EscalationType ?? (n.Type.Contains("Issue", StringComparison.OrdinalIgnoreCase) ? n.RelatedTask : null)
        };
    }



    private static List<AlertCommentDto> ParseComments(string? json)

    {

        if (string.IsNullOrWhiteSpace(json)) return [];

        try

        {

            return JsonSerializer.Deserialize<List<AlertCommentDto>>(json, JsonOptions) ?? [];

        }

        catch

        {

            return [];

        }

    }



    private static ActionAlertDto MapAlertDto(ProjectAlert a, IReadOnlyDictionary<Guid, string>? escProjectNames = null)

    {
        var projName = a.Project?.Name;
        if (string.IsNullOrWhiteSpace(projName) && a.ServiceEscalationId.HasValue && escProjectNames != null && escProjectNames.TryGetValue(a.ServiceEscalationId.Value, out var fallbackName))
        {
            projName = fallbackName;
        }

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



        var attachments = new List<string>();

        if (!string.IsNullOrWhiteSpace(a.AttachmentFileName))

        {

            attachments.Add(a.AttachmentFileName);

        }



        var escalatedTo = new List<string>();

        if (!string.IsNullOrWhiteSpace(a.EscalatedTo))

        {

            try

            {

                escalatedTo = JsonSerializer.Deserialize<List<string>>(a.EscalatedTo, JsonOptions) ?? [];

            }

            catch

            {

                // fallback

            }

        }



        var alertHistory = ParseHistory(a.HistoryJson);
        if (alertHistory.Count == 0)
        {
            alertHistory.Add(new NotificationHistoryItemDto
            {
                Action = "Notification created",
                Date = a.CreatedAtUtc.ToString("yyyy-MM-dd"),
                Time = a.CreatedAtUtc.ToString("HH:mm:ss"),
                By = a.RaisedByName,
                At = a.CreatedAtUtc.ToString("o")
            });
        }

        return new ActionAlertDto

        {

            Id = a.Id.ToString(),

            AlertId = $"ALT-{a.Id.ToString()[..8].ToUpper()}",

            Title = a.Title,

            Description = a.Description,

            ProjectId = a.ProjectId.ToString(),

            ProjectName = projName ?? "",

            CustomerId = a.Project != null ? a.Project.ClientId.ToString() : null,

            CustomerName = a.Project?.Client?.Name ?? "",

            AlertType = ResolveAlertDisplayType(a),

            Kind = IsWbsEscalationAlert(a) ? "Escalation" : "Alert",

            Priority = a.Priority,

            Status = a.Status,

            RaisedByEmployeeId = a.RaisedByEmployeeId,

            RaisedByName = a.RaisedByName,

            AudienceUserIds = audience,

            CreatedAt = a.CreatedAtUtc.ToString("o"),

            CreatedAtUtc = a.CreatedAtUtc,

            Owner = a.Owner ?? a.RaisedByName,

            ResolutionOwner = a.ResolutionOwner,

            EscalationOwner = a.EscalationOwner,

            ResolutionDetails = a.ResolutionDetails,

            StatusChangedBy = a.StatusChangedBy,

            StatusChangedAtUtc = a.StatusChangedAtUtc,

            History = alertHistory,

            Comments = ParseComments(a.ChatJson),

            ServiceName = a.ServiceName,

            EscalationType = a.EscalationType,

            ExpectedResolutionDate = a.ExpectedResolutionDate,

            EscalatedTo = escalatedTo.Count > 0 ? escalatedTo : audience,

            Attachments = attachments,

            AttachmentUrl = !string.IsNullOrWhiteSpace(a.AttachmentFileName) ? $"/api/v1/action-centre/alerts/{a.Id}/attachment" : null

        };

    }

    private static bool IsWbsEscalationAlert(ProjectAlert a)
    {
        return a.ServiceEscalationId.HasValue
            || (!string.IsNullOrWhiteSpace(a.AlertType) && a.AlertType.StartsWith("WBS", StringComparison.OrdinalIgnoreCase))
            || (!string.IsNullOrWhiteSpace(a.Title) && a.Title.Contains("WBS Escalation", StringComparison.OrdinalIgnoreCase));
    }

    private static string ResolveAlertDisplayType(ProjectAlert a)
    {
        if (!string.IsNullOrWhiteSpace(a.AlertType) && (a.AlertType.StartsWith("issue:", StringComparison.OrdinalIgnoreCase) || a.AlertType.StartsWith("WBS:", StringComparison.OrdinalIgnoreCase)))
        {
            return a.AlertType;
        }

        if (IsWbsEscalationAlert(a))
        {
            var escType = !string.IsNullOrWhiteSpace(a.EscalationType)
                ? a.EscalationType.Trim()
                : (!string.IsNullOrWhiteSpace(a.Description) && a.Description.Contains(':') ? a.Description.Split(':')[0].Trim() : "Escalation");
            return $"WBS:{escType}";
        }

        var issueType = !string.IsNullOrWhiteSpace(a.EscalationType)
            ? a.EscalationType.Trim()
            : (!string.IsNullOrWhiteSpace(a.ServiceName) ? a.ServiceName.Trim() : "Issue");
        return $"issue:{issueType}";
    }



    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolveCustomerNotificationRecipientsAsync(
        Guid? clientId = null,
        Guid? engagementManagerId = null,
        string? engagementManager = null,
        Guid? salesManagerId = null,
        string? salesManager = null,
        Guid? additionalEmployeeId = null,
        string? additionalEmployeeName = null,
        CancellationToken ct = default)
    {
        // 1. If client details (EM/SM) are not explicitly passed, look up from DB if clientId is provided
        if (clientId.HasValue && (!engagementManagerId.HasValue && string.IsNullOrWhiteSpace(engagementManager) ||
                                  !salesManagerId.HasValue && string.IsNullOrWhiteSpace(salesManager)))
        {
            var c = await db.Clients.AsNoTracking().FirstOrDefaultAsync(x => x.Id == clientId.Value, ct);
            if (c != null)
            {
                engagementManagerId ??= c.EngagementManagerId;
                engagementManager ??= c.EngagementManager;
                salesManagerId ??= c.SalesManagerId;
                salesManager ??= c.SalesManager;
            }
        }

        // 2. Active employees whose Sub-Department is `EM (Engagement Manager)` AND On Floor Role is `Head Of Department` or `Leader`
        var emKey = "em (engagement manager)";
        var emSubDeptId = Guid.Parse("63bc0f54-4d35-4279-bb62-4daeff6ceeaa");

        var candidates = await db.Employees
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))
            .ToListAsync(ct);

        var desigIds = candidates.Where(e => e.DesignationId.HasValue).Select(e => e.DesignationId!.Value).Distinct().ToList();
        var floorRoleList = await db.OnFloorRoles
            .Where(r => desigIds.Contains(r.DesignationId) && r.DeletedAtUtc == null)
            .Select(r => new { r.DesignationId, r.Name })
            .ToListAsync(ct);

        var floorRoles = new Dictionary<Guid, string>();
        foreach (var fr in floorRoleList)
        {
            if (!floorRoles.ContainsKey(fr.DesignationId) && !string.IsNullOrWhiteSpace(fr.Name))
            {
                floorRoles[fr.DesignationId] = fr.Name;
            }
        }

        var recipients = new List<PMS.API.Modules.Resources.Models.Employee>();
        foreach (var e in candidates)
        {
            var subDept = (e.SubDepartment ?? e.SubDepartmentRef?.Name ?? "").Trim().ToLowerInvariant();
            var subDeptCode = (e.SubDepartmentRef?.Code ?? "").Trim().ToLowerInvariant();
            var isEm = e.SubDepartmentId == emSubDeptId ||
                       subDept == emKey ||
                       subDeptCode == "em_engagement_manager" ||
                       subDept.Contains("engagement manager") ||
                       subDept == "em" || subDept.StartsWith("em ") || subDept.StartsWith("em-");

            string roleFromFloor = string.Empty;
            if (e.DesignationId.HasValue && floorRoles.TryGetValue(e.DesignationId.Value, out var mappedRole))
            {
                roleFromFloor = mappedRole;
            }

            var rLower = roleFromFloor.Trim().ToLowerInvariant();
            var roleFieldLower = (e.Role ?? "").Trim().ToLowerInvariant();

            // Strictly exclude Team Leader
            var isTeamLeader = rLower.Contains("team leader") || roleFieldLower.Contains("team leader");
            if (isTeamLeader) continue;

            var isHodOrLeader = rLower == "head of department" || rLower == "leader" || rLower == "hod" || rLower.Contains("head of department") ||
                                roleFieldLower == "head of department" || roleFieldLower == "leader" || roleFieldLower == "hod" || roleFieldLower.Contains("head of department");

            // Strict AND condition: Sub-Department is EM AND On Floor Role is Head Of Department or Leader
            if (isEm && isHodOrLeader)
            {
                if (!recipients.Any(r => r.Id == e.Id))
                {
                    recipients.Add(e);
                }
            }
        }

        AddAllPmo(recipients, candidates);

        // 3. Resolve and add customer's assigned Engagement Manager
        AddCandidateIfFound(recipients, candidates, engagementManagerId, engagementManager);

        // 4. Resolve and add customer's assigned Sales Manager
        AddCandidateIfFound(recipients, candidates, salesManagerId, salesManager);

        // 5. Resolve and add Additional Manager (e.g. previous manager or newly changed manager)
        AddCandidateIfFound(recipients, candidates, additionalEmployeeId, additionalEmployeeName);

        return recipients;
    }

    private static void AddAllPmo(
        List<PMS.API.Modules.Resources.Models.Employee> recipients,
        List<PMS.API.Modules.Resources.Models.Employee> candidates)
    {
        foreach (var employee in candidates)
        {
            if (!IsPmoEmployee(employee)) continue;
            if (!recipients.Any(r => r.Id == employee.Id))
            {
                recipients.Add(employee);
            }
        }
    }

    private static bool IsPmoEmployee(PMS.API.Modules.Resources.Models.Employee employee)
    {
        var subDepartment = (employee.SubDepartment ?? employee.SubDepartmentRef?.Name ?? "").Trim();
        var role = (employee.Role ?? "").Trim();
        var pmoDepartment = (employee.PmoDepartment ?? "").Trim();
        return subDepartment.Contains("pmo", StringComparison.OrdinalIgnoreCase)
            || role.Contains("pmo", StringComparison.OrdinalIgnoreCase)
            || pmoDepartment.Contains("pmo", StringComparison.OrdinalIgnoreCase);
    }

    private static void AddCandidateIfFound(
        List<PMS.API.Modules.Resources.Models.Employee> recipients,
        List<PMS.API.Modules.Resources.Models.Employee> candidates,
        Guid? employeeId,
        string? employeeName)
    {
        if (employeeId.HasValue && employeeId.Value != Guid.Empty)
        {
            var match = candidates.FirstOrDefault(e => e.Id == employeeId.Value);
            if (match != null && !recipients.Any(r => r.Id == match.Id))
            {
                recipients.Add(match);
                return;
            }
        }

        if (!string.IsNullOrWhiteSpace(employeeName))
        {
            var norm = employeeName.Trim().ToLowerInvariant();
            var match = candidates.FirstOrDefault(e =>
                (e.FirstName + " " + e.LastName).Trim().ToLower() == norm ||
                (e.LastName + " " + e.FirstName).Trim().ToLower() == norm ||
                (e.FirstName ?? "").Trim().ToLower() == norm ||
                (e.LastName ?? "").Trim().ToLower() == norm);
            if (match != null && !recipients.Any(r => r.Id == match.Id))
            {
                recipients.Add(match);
            }
        }
    }

    public async Task NotifyCustomerOnboardedAsync(
        Guid clientId,
        string clientName,
        string? clientCode,
        string? createdByName,
        Guid? engagementManagerId = null,
        string? engagementManager = null,
        Guid? salesManagerId = null,
        string? salesManager = null,
        CancellationToken ct = default)
    {
        var recipients = await ResolveCustomerNotificationRecipientsAsync(
            clientId,
            engagementManagerId,
            engagementManager,
            salesManagerId,
            salesManager,
            null,
            null,
            ct);
        if (recipients.Count == 0) return;

        var title = $"Customer Onboarded: {clientName}";
        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                Title = title,
                Type = "Customer Onboarded",
                Priority = "Low",
                Status = "Created",
                ProjectName = "-",
                Unread = true,
                RaisedByName = createdByName ?? currentUser.Name ?? "System",
                RelatedTask = clientCode ?? clientName,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Created",
                        at = DateTime.UtcNow.ToString("o"),
                        details = $"Customer '{clientName}' has been successfully onboarded."
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    public async Task NotifySubVentureOnboardedAsync(
        Guid clientId,
        string clientName,
        Guid subVentureId,
        string subVentureName,
        string? subVentureCode,
        string? createdByName,
        Guid? engagementManagerId = null,
        string? engagementManager = null,
        Guid? salesManagerId = null,
        string? salesManager = null,
        CancellationToken ct = default)
    {
        var recipients = await ResolveCustomerNotificationRecipientsAsync(
            clientId,
            engagementManagerId,
            engagementManager,
            salesManagerId,
            salesManager,
            null,
            null,
            ct);
        if (recipients.Count == 0) return;

        var title = $"Sub-Venture Onboarded: {subVentureName} ({clientName})";
        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                Title = title,
                Type = "Sub-Venture Onboarded",
                Priority = "Low",
                Status = "Created",
                ProjectName = "-",
                Unread = true,
                RaisedByName = createdByName ?? currentUser.Name ?? "System",
                RelatedTask = subVentureCode ?? subVentureName,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Created",
                        at = DateTime.UtcNow.ToString("o"),
                        details = $"Sub-Venture '{subVentureName}' under Customer '{clientName}' has been successfully onboarded."
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolveCustomerEditNotificationRecipientsAsync(
        Guid? clientId = null,
        Guid? engagementManagerId = null,
        string? engagementManager = null,
        CancellationToken ct = default)
    {
        // 1. If customer's Engagement Manager is not passed, resolve from DB using clientId
        if (clientId.HasValue && (!engagementManagerId.HasValue && string.IsNullOrWhiteSpace(engagementManager)))
        {
            var c = await db.Clients.AsNoTracking().FirstOrDefaultAsync(x => x.Id == clientId.Value, ct);
            if (c != null)
            {
                engagementManagerId = c.EngagementManagerId;
                engagementManager = c.EngagementManager;
            }
        }

        // 2. Fetch all active employees
        var candidates = await db.Employees
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))
            .ToListAsync(ct);

        var desigIds = candidates.Where(e => e.DesignationId.HasValue).Select(e => e.DesignationId!.Value).Distinct().ToList();
        var floorRoleList = await db.OnFloorRoles
            .Where(r => desigIds.Contains(r.DesignationId) && r.DeletedAtUtc == null)
            .Select(r => new { r.DesignationId, r.Name })
            .ToListAsync(ct);

        var floorRoles = new Dictionary<Guid, string>();
        foreach (var fr in floorRoleList)
        {
            if (!floorRoles.ContainsKey(fr.DesignationId) && !string.IsNullOrWhiteSpace(fr.Name))
            {
                floorRoles[fr.DesignationId] = fr.Name;
            }
        }

        var recipients = new List<PMS.API.Modules.Resources.Models.Employee>();

        // 3. Add all active employees whose On Floor Role is `Head Of Department`
        foreach (var e in candidates)
        {
            string roleFromFloor = string.Empty;
            if (e.DesignationId.HasValue && floorRoles.TryGetValue(e.DesignationId.Value, out var mappedRole))
            {
                roleFromFloor = mappedRole;
            }

            var rLower = roleFromFloor.Trim().ToLowerInvariant();
            var roleFieldLower = (e.Role ?? "").Trim().ToLowerInvariant();

            // Strictly exclude Team Leader
            var isTeamLeader = rLower.Contains("team leader") || roleFieldLower.Contains("team leader");
            if (isTeamLeader) continue;

            // Check if On Floor Role is Head Of Department
            var isHod = rLower == "head of department" || rLower.Contains("head of department") ||
                        roleFieldLower == "head of department" || roleFieldLower.Contains("head of department") ||
                        roleFieldLower.EndsWith("-hod") || roleFieldLower == "hod";

            if (isHod)
            {
                if (!recipients.Any(r => r.Id == e.Id))
                {
                    recipients.Add(e);
                }
            }
        }

        AddAllPmo(recipients, candidates);

        // 4. Resolve and add customer's assigned Engagement Manager
        AddCandidateIfFound(recipients, candidates, engagementManagerId, engagementManager);

        return recipients;
    }

    public async Task NotifyCustomerEditedAsync(
        Guid clientId,
        string clientName,
        string? clientCode,
        string? performerName,
        IReadOnlyList<string>? modifiedFields = null,
        Guid? engagementManagerId = null,
        string? engagementManager = null,
        Guid? salesManagerId = null,
        string? salesManager = null,
        CancellationToken ct = default)
    {
        var recipients = await ResolveCustomerEditNotificationRecipientsAsync(
            clientId,
            engagementManagerId,
            engagementManager,
            ct);
        if (recipients.Count == 0) return;

        var distinctChanges = modifiedFields?.Where(f => !string.IsNullOrWhiteSpace(f)).Distinct().ToList() ?? [];
        var fieldsText = distinctChanges.Count > 0 ? string.Join(", ", distinctChanges) : null;
        var verb = distinctChanges.Count > 1 ? "are edited" : "is edited";
        var title = fieldsText != null
            ? $"{clientName} {fieldsText} {verb}"
            : $"{clientName} is edited";
        if (title.Length > 255) title = title[..255];

        var editorName = !string.IsNullOrWhiteSpace(performerName)
            ? performerName
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : "System");

        var detailsText = fieldsText != null
            ? $"{clientName} {fieldsText} {verb} by {editorName}."
            : $"{clientName} is edited by {editorName}.";

        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                Title = title,
                Type = "Customer Profile Edited",
                Priority = "Low",
                Status = "Edited",
                ProjectName = "-",
                Unread = true,
                RaisedByName = editorName,
                RelatedTask = clientCode ?? clientName,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Edited",
                        at = DateTime.UtcNow.ToString("o"),
                        details = detailsText
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    public async Task NotifySubVentureEditedAsync(
        Guid clientId,
        string clientName,
        Guid subVentureId,
        string subVentureName,
        string? subVentureCode,
        string? performerName,
        IReadOnlyList<string>? modifiedFields = null,
        Guid? engagementManagerId = null,
        string? engagementManager = null,
        Guid? salesManagerId = null,
        string? salesManager = null,
        CancellationToken ct = default)
    {
        var recipients = await ResolveCustomerEditNotificationRecipientsAsync(
            clientId,
            engagementManagerId,
            engagementManager,
            ct);
        if (recipients.Count == 0) return;

        var distinctChanges = modifiedFields?.Where(f => !string.IsNullOrWhiteSpace(f)).Distinct().ToList() ?? [];
        var fieldsText = distinctChanges.Count > 0 ? string.Join(", ", distinctChanges) : null;
        var verb = distinctChanges.Count > 1 ? "are edited" : "is edited";
        var title = fieldsText != null
            ? $"{subVentureName} {fieldsText} {verb}"
            : $"{subVentureName} is edited";
        if (title.Length > 255) title = title[..255];

        var editorName = !string.IsNullOrWhiteSpace(performerName)
            ? performerName
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : "System");

        var detailsText = fieldsText != null
            ? $"{subVentureName} {fieldsText} {verb} by {editorName}."
            : $"{subVentureName} is edited by {editorName}.";

        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                Title = title,
                Type = "Sub-Venture Profile Edited",
                Priority = "Low",
                Status = "Edited",
                ProjectName = "-",
                Unread = true,
                RaisedByName = editorName,
                RelatedTask = subVentureCode ?? subVentureName,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Edited",
                        at = DateTime.UtcNow.ToString("o"),
                        details = detailsText
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    public async Task NotifyWbsCreatedAsync(
        Guid projectId,
        string projectName,
        string? wbsId,
        string? projectCode,
        string? createdByName,
        CancellationToken ct = default)
    {
        var project = await db.Projects
            .Include(p => p.Client)
                .ThenInclude(c => c!.SalesManagerRef)
            .Include(p => p.Client)
                .ThenInclude(c => c!.EngagementManagerRef)
            .Include(p => p.EngagementManagerRef)
            .Include(p => p.SalesPersonRef)
            .FirstOrDefaultAsync(p => p.Id == projectId, ct);

        var recipients = new Dictionary<Guid, PMS.API.Modules.Resources.Models.Employee>();

        // 1. Assigned Engagement Manager of the project
        if (project != null)
        {
            var emRecipients = await ResolveProjectEngagementManagersAsync(project, ct);
            foreach (var em in emRecipients)
            {
                if (em.DeletedAtUtc == null && !recipients.ContainsKey(em.Id))
                {
                    recipients[em.Id] = em;
                }
            }
        }

        // 2. Sales Manager or the person
        var salesRecipients = await ResolveProjectSalesPersonsAsync(project, ct);
        foreach (var s in salesRecipients)
        {
            if (s.DeletedAtUtc == null && !recipients.ContainsKey(s.Id))
            {
                recipients[s.Id] = s;
            }
        }

        // Resolve HOD whose Sub-Department is EM and PMO
        var emSubDeptId = Guid.Parse("63bc0f54-4d35-4279-bb62-4daeff6ceeaa");
        var pmoSubDeptId = Guid.Parse("fd84aa38-11ef-46af-ade7-241f2a2c08fd");

        var candidates = await db.Employees
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))
            .ToListAsync(ct);

        if (candidates.Count > 0)
        {
            var desigIds = candidates.Where(e => e.DesignationId.HasValue).Select(e => e.DesignationId!.Value).Distinct().ToList();
            var floorRoleList = await db.OnFloorRoles
                .Where(r => desigIds.Contains(r.DesignationId) && r.DeletedAtUtc == null)
                .Select(r => new { r.DesignationId, r.Name })
                .ToListAsync(ct);

            var floorRoles = new Dictionary<Guid, string>();
            foreach (var fr in floorRoleList)
            {
                if (!floorRoles.ContainsKey(fr.DesignationId) && !string.IsNullOrWhiteSpace(fr.Name))
                {
                    floorRoles[fr.DesignationId] = fr.Name;
                }
            }

            foreach (var e in candidates)
            {
                var subDept = (e.SubDepartment ?? e.SubDepartmentRef?.Name ?? "").Trim().ToLowerInvariant();
                var subDeptCode = (e.SubDepartmentRef?.Code ?? "").Trim().ToLowerInvariant();

                string roleFromFloor = string.Empty;
                if (e.DesignationId.HasValue && floorRoles.TryGetValue(e.DesignationId.Value, out var mappedRole))
                {
                    roleFromFloor = mappedRole;
                }

                var rLower = roleFromFloor.Trim().ToLowerInvariant();
                var roleFieldLower = (e.Role ?? "").Trim().ToLowerInvariant();

                var isTeamLeader = rLower.Contains("team leader") || roleFieldLower.Contains("team leader");

                // 3. HOD whose Sub-Department is `EM (Engagement Manager)`
                var isEm = e.SubDepartmentId == emSubDeptId ||
                           subDept == "em (engagement manager)" ||
                           subDeptCode == "em_engagement_manager" ||
                           subDept.Contains("engagement manager") ||
                           subDept == "em" || subDept.StartsWith("em ") || subDept.StartsWith("em-");

                var isHod = (rLower == "head of department" || rLower == "hod" || rLower.Contains("head of department") ||
                             roleFieldLower == "head of department" || roleFieldLower == "hod" || roleFieldLower.Contains("head of department")) && !isTeamLeader;

                if (isEm && isHod)
                {
                    if (!recipients.ContainsKey(e.Id))
                    {
                        recipients[e.Id] = e;
                    }
                }

                // 4. PMO
                var isPmo = e.SubDepartmentId == pmoSubDeptId ||
                            subDept == "pmo (project management office)" ||
                            subDept == "pmo" ||
                            subDeptCode == "pmo_project_management_office" ||
                            subDept.Contains("project management office") ||
                            subDept.StartsWith("pmo ") || subDept.StartsWith("pmo-") ||
                            (!string.IsNullOrWhiteSpace(e.PmoDepartment) && e.PmoDepartment.Trim().ToLowerInvariant().Contains("pmo")) ||
                            roleFieldLower == "pmo" || roleFieldLower.Contains("pmo") ||
                            rLower == "pmo" || rLower.Contains("pmo");

                if (isPmo || IsPmoEmployee(e))
                {
                    if (!recipients.ContainsKey(e.Id))
                    {
                        recipients[e.Id] = e;
                    }
                }
            }
        }

        // Check for users with Role PMO whose employee records might not have PMO string in fields
        var pmoUsers = await db.Users
            .Include(u => u.Role)
            .Where(u => u.IsActive && u.Role != null && u.Role.Name.ToUpper() == "PMO")
            .ToListAsync(ct);

        if (pmoUsers.Count > 0)
        {
            var pmoUserEmails = pmoUsers.Select(u => u.Email.Trim().ToLower()).Where(em => !string.IsNullOrEmpty(em)).ToHashSet();
            var pmoEmpCodes = pmoUsers.Select(u => u.EmployeeId.Trim().ToLower()).Where(c => !string.IsNullOrEmpty(c)).ToHashSet();

            foreach (var cand in candidates)
            {
                if (recipients.ContainsKey(cand.Id)) continue;

                var cEmail = (cand.WorkEmail ?? cand.PersonalEmail ?? "").Trim().ToLower();
                var cCode = (cand.EmployeeCode ?? "").Trim().ToLower();
                if ((!string.IsNullOrEmpty(cEmail) && pmoUserEmails.Contains(cEmail)) ||
                    (!string.IsNullOrEmpty(cCode) && pmoEmpCodes.Contains(cCode)) ||
                    pmoEmpCodes.Contains(cand.Id.ToString().ToLower()))
                {
                    recipients[cand.Id] = cand;
                }
            }
        }

        if (recipients.Count > 0)
        {
            var title = $"{projectName} is onboarded";
            var addedList = new List<ActionNotification>();
            foreach (var recipient in recipients.Values)
            {
                var notif = new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = recipient.Id,
                    Title = title,
                    Type = "WBS Created",
                    Priority = "Low",
                    Status = "Created",
                    Unread = true,
                    RaisedByName = createdByName ?? currentUser.Name ?? "System",
                    ProjectId = projectId,
                    ProjectName = "-",
                    ProjectCode = null,
                    RelatedTask = wbsId ?? projectCode ?? projectName,
                    CreatedAtUtc = DateTime.UtcNow,
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            status = "Created",
                            at = DateTime.UtcNow.ToString("o"),
                            details = $"{projectName} is onboarded"
                        }
                    })
                };
                db.ActionNotifications.Add(notif);
                addedList.Add(notif);
            }

            await db.SaveChangesAsync(ct);
            TrySyncNotificationsToOtherDatabase(addedList);
        }

        // Automated PM/SPM assignment reminder workflow
        await StartProjectAllocationReminderWorkflowAsync(projectId, ct);
    }

    public async Task NotifyResourceOnboardedAsync(
        Guid employeeId,
        string employeeName,
        string employeeCode,
        Guid? reportingManagerId,
        string? performerName,
        CancellationToken ct = default)
    {
        // Criteria:
        // 1. Assigned Reporting Manager
        // AND / OR
        // 2. Resources whose Sub-Department is `EM (Engagement Manager)` or `PMO (Project Management Office)`
        //    AND whose On Floor Role is `Sr. Manager` or `Manager`
        var recipients = new List<PMS.API.Modules.Resources.Models.Employee>();

        if (reportingManagerId.HasValue)
        {
            var mgr = await db.Employees.FirstOrDefaultAsync(e => e.Id == reportingManagerId.Value && e.DeletedAtUtc == null, ct);
            if (mgr != null && !recipients.Any(r => r.Id == mgr.Id))
            {
                recipients.Add(mgr);
            }
        }

        var emSubDeptId = Guid.Parse("63bc0f54-4d35-4279-bb62-4daeff6ceeaa");
        var pmoSubDeptId = Guid.Parse("fd84aa38-11ef-46af-ade7-241f2a2c08fd");

        var candidates = await db.Employees
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))
            .ToListAsync(ct);

        if (candidates.Count > 0)
        {
            var desigIds = candidates.Where(e => e.DesignationId.HasValue).Select(e => e.DesignationId!.Value).Distinct().ToList();
            var floorRoleList = await db.OnFloorRoles
                .Where(r => desigIds.Contains(r.DesignationId) && r.DeletedAtUtc == null)
                .Select(r => new { r.DesignationId, r.Name })
                .ToListAsync(ct);

            var floorRoles = new Dictionary<Guid, string>();
            foreach (var fr in floorRoleList)
            {
                if (!floorRoles.ContainsKey(fr.DesignationId) && !string.IsNullOrWhiteSpace(fr.Name))
                {
                    floorRoles[fr.DesignationId] = fr.Name;
                }
            }

            foreach (var e in candidates)
            {
                var subDept = (e.SubDepartment ?? e.SubDepartmentRef?.Name ?? "").Trim().ToLowerInvariant();
                var subDeptCode = (e.SubDepartmentRef?.Code ?? "").Trim().ToLowerInvariant();
                var isEmOrPmo = e.SubDepartmentId == emSubDeptId || e.SubDepartmentId == pmoSubDeptId ||
                                subDept == "em (engagement manager)" || subDept == "pmo (project management office)" ||
                                subDeptCode == "em_engagement_manager" || subDeptCode == "pmo_project_management_office" ||
                                subDept.Contains("engagement manager") || subDept.Contains("project management office") ||
                                subDept == "em" || subDept == "pmo" || subDept.StartsWith("em ") || subDept.StartsWith("pmo ") ||
                                subDept.StartsWith("em-") || subDept.StartsWith("pmo-");

                string roleFromFloor = string.Empty;
                if (e.DesignationId.HasValue && floorRoles.TryGetValue(e.DesignationId.Value, out var mappedRole))
                {
                    roleFromFloor = mappedRole;
                }

                var rLower = roleFromFloor.Trim().ToLowerInvariant();
                var roleFieldLower = (e.Role ?? "").Trim().ToLowerInvariant();

                var isTeamLeader = rLower.Contains("team leader") || roleFieldLower.Contains("team leader");
                if (isTeamLeader) continue;

                var isMgrOrSrMgr = rLower == "sr. manager" || rLower == "manager" || rLower == "senior manager" ||
                                   roleFieldLower == "sr. manager" || roleFieldLower == "manager" || roleFieldLower == "senior manager" ||
                                   (!rLower.Contains("associate") && rLower.Contains("manager") && !rLower.Contains("account manager") && !rLower.Contains("engagement manager"));

                // Strict AND: Sub-Department is (EM or PMO) AND On Floor Role is Sr. Manager or Manager
                if (isEmOrPmo && isMgrOrSrMgr)
                {
                    if (!recipients.Any(r => r.Id == e.Id))
                    {
                        recipients.Add(e);
                    }
                }
            }
        }

        if (recipients.Count == 0) return;

        var title = $"Resource Onboarded: {employeeName} ({employeeCode})";
        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                Title = title,
                Type = "Resource Onboarded",
                Priority = "Low",
                Status = "Created",
                ProjectName = "-",
                Unread = true,
                RaisedByName = performerName ?? currentUser.Name ?? "System",
                RelatedTask = employeeCode,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Created",
                        at = DateTime.UtcNow.ToString("o"),
                        details = $"Resource '{employeeName}' ({employeeCode}) has been successfully onboarded."
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    public async Task NotifyResourceProfileUpdatedAsync(
        Guid employeeId,
        string employeeName,
        string employeeCode,
        Guid? reportingManagerId,
        IReadOnlyList<string> modifiedFields,
        string? performerName,
        Guid? performerEmployeeId,
        CancellationToken ct = default)
    {
        if (!reportingManagerId.HasValue || reportingManagerId.Value == Guid.Empty) return;

        var mgr = await db.Employees.FirstOrDefaultAsync(e => e.Id == reportingManagerId.Value && e.DeletedAtUtc == null, ct);
        if (mgr == null) return;

        var distinctChanges = modifiedFields.Distinct().ToList();
        var fieldsText = distinctChanges.Count > 0 ? string.Join(", ", distinctChanges) : "details";
        var editorName = !string.IsNullOrWhiteSpace(performerName)
            ? performerName
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : "Admin User");

        var title = $"{employeeName} change their profile {fieldsText} by {editorName}";

        var notif = new ActionNotification
        {
            Id = Guid.NewGuid(),
            RecipientEmployeeId = mgr.Id,
            Title = title,
            Type = "Resource Profile Updated",
            Priority = "Low",
            Status = "Edited",
            ProjectName = "-",
            Unread = true,
            RaisedByName = editorName,
            RaisedByEmployeeId = performerEmployeeId,
            RelatedTask = employeeCode,
            CreatedAtUtc = DateTime.UtcNow,
            HistoryJson = JsonSerializer.Serialize(new[]
            {
                new
                {
                    status = "Edited",
                    at = DateTime.UtcNow.ToString("o"),
                    details = title
                }
            })
        };

        db.ActionNotifications.Add(notif);
        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(new[] { notif });
    }


    public async Task NotifyCustomerManagerChangedAsync(
        Guid clientId,
        string clientName,
        string? clientCode,
        string managerRole,
        string managerName,
        Guid? managerEmployeeId,
        string? previousManagerName = null,
        Guid? previousManagerEmployeeId = null,
        string? performerName = null,
        CancellationToken ct = default)
    {
        var recipients = await ResolveCustomerNotificationRecipientsAsync(
            clientId: clientId,
            engagementManagerId: managerRole == "Engagement Manager" ? managerEmployeeId : null,
            engagementManager: managerRole == "Engagement Manager" ? managerName : null,
            salesManagerId: managerRole == "Sales Manager" ? managerEmployeeId : null,
            salesManager: managerRole == "Sales Manager" ? managerName : null,
            additionalEmployeeId: previousManagerEmployeeId,
            additionalEmployeeName: previousManagerName,
            ct: ct);

        if (recipients.Count == 0) return;

        var managerLabel = !string.IsNullOrWhiteSpace(previousManagerName) ? previousManagerName : managerRole;
        var title = $"{managerLabel} of the Customer ({clientName}) change to the {managerName}";

        var editorName = !string.IsNullOrWhiteSpace(performerName)
            ? performerName
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : "System");

        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                Title = title,
                Type = $"{managerRole} Changed",
                Priority = "Low",
                Status = "Edited",
                ProjectName = "-",
                Unread = true,
                RaisedByName = editorName,
                RelatedTask = clientCode ?? clientName,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Edited",
                        at = DateTime.UtcNow.ToString("o"),
                        details = title
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    public async Task NotifyRepositoryDocumentUploadedAsync(
        Guid documentId,
        string fileName,
        string category,
        IReadOnlyList<Guid> departmentIds,
        string? uploaderName,
        Guid? uploaderEmployeeId = null,
        CancellationToken ct = default)
    {
        if (departmentIds == null || departmentIds.Count == 0) return;

        var validDeptIds = departmentIds.Where(id => id != Guid.Empty).Distinct().ToList();
        if (validDeptIds.Count == 0) return;

        var candidates = await db.Employees
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))
            .Where(e => (e.DepartmentId.HasValue && validDeptIds.Contains(e.DepartmentId.Value)) ||
                        (e.SubDepartmentRef != null && e.SubDepartmentRef.DepartmentId.HasValue && validDeptIds.Contains(e.SubDepartmentRef.DepartmentId.Value)))
            .ToListAsync(ct);

        var recipients = new List<PMS.API.Modules.Resources.Models.Employee>();
        foreach (var emp in candidates)
        {
            if (!recipients.Any(r => r.Id == emp.Id))
            {
                recipients.Add(emp);
            }
        }

        if (recipients.Count == 0) return;

        var title = "Document is Uploaded";
        var editorName = !string.IsNullOrWhiteSpace(uploaderName)
            ? uploaderName
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : "System");

        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                Title = title,
                Type = "Document Uploaded",
                Priority = "-",
                Status = "Upload",
                ProjectName = "-",
                ProjectCode = null,
                Unread = true,
                RaisedByName = editorName,
                RaisedByEmployeeId = uploaderEmployeeId,
                RelatedTask = fileName,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Upload",
                        at = DateTime.UtcNow.ToString("o"),
                        details = $"Document '{fileName}' in category '{category}' was uploaded by {editorName}."
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    public async Task NotifyProjectLeadershipAssignedAsync(
        Guid projectId,
        string projectName,
        string? projectCode,
        Guid recipientEmployeeId,
        string leadershipRole,
        string? performerName,
        Guid? performerEmployeeId = null,
        CancellationToken ct = default)
    {
        var isSpm = leadershipRole.Equals("Senior Project Manager", StringComparison.OrdinalIgnoreCase) ||
                    leadershipRole.Equals("SPM", StringComparison.OrdinalIgnoreCase) ||
                    leadershipRole.Equals(ProjectMemberRoles.SeniorProjectManager, StringComparison.OrdinalIgnoreCase);

        var title = isSpm
            ? "You are assigned as Senior Project Manager"
            : "You are assigned as Project Manager";

        var roleLabel = isSpm ? "Senior Project Manager" : "Project Manager";
        var message = $"You have been assigned as the {roleLabel} for the project {projectName}.";

        var editorName = !string.IsNullOrWhiteSpace(performerName)
            ? performerName
            : (!string.IsNullOrWhiteSpace(currentUser.Name) ? currentUser.Name : "System");

        // Duplicate prevention check
        var duplicateExists = await db.ActionNotifications
            .AnyAsync(n => n.RecipientEmployeeId == recipientEmployeeId &&
                           n.ProjectId == projectId &&
                           n.Title == title &&
                           n.Status == "Assigned" &&
                           n.DeletedAtUtc == null &&
                           n.CreatedAtUtc >= DateTime.UtcNow.AddMinutes(-5), ct);
        if (duplicateExists)
        {
            return;
        }

        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        var historyItem = new
        {
            action = message,
            date = dateStr,
            time = timeStr,
            by = editorName,
            status = "Assigned",
            at = now.ToString("o"),
            details = message
        };

        var notif = new ActionNotification
        {
            Id = Guid.NewGuid(),
            RecipientEmployeeId = recipientEmployeeId,
            ProjectId = projectId,
            ProjectCode = null,
            ProjectName = projectName,
            Title = title,
            Type = isSpm ? "Senior Project Manager Assigned" : "Project Manager Assigned",
            Priority = "Low",
            Status = "Assigned",
            Unread = true,
            RaisedByName = editorName,
            RaisedByEmployeeId = performerEmployeeId,
            RelatedTask = !string.IsNullOrWhiteSpace(projectCode) ? projectCode : projectName,
            CreatedAtUtc = now,
            HistoryJson = JsonSerializer.Serialize(new[] { historyItem }),
            CommentsJson = "[]"
        };

        db.ActionNotifications.Add(notif);
        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(new[] { notif });
    }

    public static void TrySyncNotificationsToOtherDatabase(IReadOnlyList<ActionNotification> notifications)

    {

        try

        {

            using var conn = new Npgsql.NpgsqlConnection("Host=127.0.0.1;Port=5432;Database=pms_uat;Username=postgres;Password=123;Timeout=2;Include Error Detail=true");

            conn.Open();

            foreach (var n in notifications)

            {

                using var cmd = conn.CreateCommand();

                cmd.CommandText = @"

                    INSERT INTO action.tbl_notifications 

                    (""Id"", ""RecipientEmployeeId"", ""ProjectId"", ""ProjectCode"", ""ProjectName"", ""Title"", ""Type"", ""Priority"", ""Status"", ""Unread"", ""RaisedByName"", ""RelatedTask"", ""HistoryJson"", ""CommentsJson"", ""CreatedAtUtc"")

                    VALUES (@id, @recip, @pid, @pcode, @pname, @title, @type, @pri, @stat, @unread, @raised, @task, @hist, @comments, @created)

                    ON CONFLICT (""Id"") DO UPDATE SET ""Status"" = EXCLUDED.""Status"", ""HistoryJson"" = EXCLUDED.""HistoryJson"", ""CommentsJson"" = EXCLUDED.""CommentsJson"";";

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

                cmd.Parameters.AddWithValue("hist", (object?)n.HistoryJson ?? DBNull.Value);

                cmd.Parameters.AddWithValue("comments", (object?)n.CommentsJson ?? "[]");

                cmd.Parameters.AddWithValue("created", n.CreatedAtUtc);

                cmd.ExecuteNonQuery();

            }

        }

        catch

        {

            // Silently ignore secondary sync failure

        }

    }

    private async Task SendWbsEscalationStatusChangeNotificationsAsync(
        ProjectAlert alert,
        string oldStatus,
        string newStatus,
        string userName,
        Guid? actorEmployeeId,
        CancellationToken ct = default)
    {
        if (string.Equals(oldStatus, newStatus, StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        if (alert.IssueId.HasValue || alert.Issue != null || (alert.AlertType != null && alert.AlertType.StartsWith("issue", StringComparison.OrdinalIgnoreCase)))
        {
            return;
        }

        if (!alert.ServiceEscalationId.HasValue)
        {
            return;
        }

        var esc = await db.ProjectServiceEscalations
            .Include(e => e.Stakeholders)
            .Include(e => e.Project)
                .ThenInclude(p => p!.Client)
            .FirstOrDefaultAsync(e => e.Id == alert.ServiceEscalationId.Value && e.DeletedAtUtc == null, ct);

        if (esc == null)
        {
            return;
        }

        // 1. Query SLA Instance and Events for this WBS Escalation
        var slaInstance = await db.SlaInstances
            .AsNoTracking()
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == esc.Id && i.ActivityType == "WBS Escalation", ct);

        // 2. Resolve Senior Project Manager(s) dynamically
        var spmIds = new HashSet<Guid>();
        if (alert.ProjectId != Guid.Empty)
        {
            var projectSpms = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == alert.ProjectId
                             && tm.DeletedAtUtc == null
                             && (tm.MemberRole == ProjectMemberRoles.SeniorProjectManager
                                 || tm.MemberRole == "Senior Project Manager"
                                 || tm.MemberRole == "Senior PM"
                                 || tm.MemberRole == "SPM"
                                 || (tm.MemberRole != null && (tm.MemberRole.ToLower().Contains("senior") || tm.MemberRole.ToLower().Contains("spm")))))
                .Select(tm => tm.EmployeeId)
                .ToListAsync(ct);
            foreach (var id in projectSpms) spmIds.Add(id);
        }

        var escSpms = esc.Stakeholders
            .Where(s => string.Equals(s.SubDepartment, "Senior Project Management", StringComparison.OrdinalIgnoreCase))
            .Select(s => s.EmployeeId);
        foreach (var id in escSpms) spmIds.Add(id);

        var l1NotifRecipients = await db.ActionNotifications
            .AsNoTracking()
            .Where(n => n.ServiceEscalationId == esc.Id
                        && n.Type == "WBS Escalation"
                        && n.Title.Contains("Level 1 Escalation")
                        && n.DeletedAtUtc == null)
            .Select(n => n.RecipientEmployeeId)
            .Distinct()
            .ToListAsync(ct);
        foreach (var id in l1NotifRecipients) spmIds.Add(id);

        if (spmIds.Count == 0 && slaRecipientResolver != null)
        {
            var dummyInstance = slaInstance ?? new SlaInstance { ProjectId = alert.ProjectId, ActivityType = "WBS Escalation", EntityId = esc.Id };
            var resolvedSpms = await slaRecipientResolver.ResolveRecipientsAsync(dummyInstance, ["Assigned Senior Project Manager"], ct);
            foreach (var id in resolvedSpms) spmIds.Add(id);
        }

        // 3. Resolve Head of Department(s) dynamically
        var hodIds = new HashSet<Guid>();
        var escHods = esc.Stakeholders
            .Where(s => string.Equals(s.SubDepartment, "Department Head", StringComparison.OrdinalIgnoreCase))
            .Select(s => s.EmployeeId);
        foreach (var id in escHods) hodIds.Add(id);

        var l2NotifRecipients = await db.ActionNotifications
            .AsNoTracking()
            .Where(n => n.ServiceEscalationId == esc.Id
                        && n.Type == "WBS Escalation"
                        && n.Title.Contains("Level 2 Escalation")
                        && n.DeletedAtUtc == null)
            .Select(n => n.RecipientEmployeeId)
            .Distinct()
            .ToListAsync(ct);
        foreach (var id in l2NotifRecipients) hodIds.Add(id);

        if (hodIds.Count == 0 && esc.Project != null)
        {
            var projectHods = await ResolveProjectHodAsync(esc.Project, ct);
            foreach (var id in projectHods) hodIds.Add(id);
        }

        if (hodIds.Count == 0 && slaRecipientResolver != null)
        {
            var dummyInstance = slaInstance ?? new SlaInstance { ProjectId = alert.ProjectId, ActivityType = "WBS Escalation", EntityId = esc.Id };
            var resolvedHods = await slaRecipientResolver.ResolveRecipientsAsync(dummyInstance, ["Head of Department"], ct);
            foreach (var id in resolvedHods) hodIds.Add(id);
        }

        if (hodIds.Count == 0)
        {
            var hodOnFloorRoles = await db.OnFloorRoles
                .AsNoTracking()
                .Where(o => o.DeletedAtUtc == null && (
                    o.Name.ToLower() == "head of department"
                    || o.Name.ToLower() == "hod"
                    || o.Name.ToLower().Contains("head of department")
                    || o.Name.Contains("Head Of Department")
                ))
                .Select(o => o.DesignationId)
                .Distinct()
                .ToListAsync(ct);

            if (hodOnFloorRoles.Count > 0)
            {
                var hodEmps = await db.Employees
                    .AsNoTracking()
                    .Where(e => e.DeletedAtUtc == null
                                && (e.Status == null || !e.Status.ToLower().StartsWith("inactive"))
                                && e.DesignationId.HasValue
                                && hodOnFloorRoles.Contains(e.DesignationId.Value))
                    .Select(e => e.Id)
                    .ToListAsync(ct);
                foreach (var id in hodEmps) hodIds.Add(id);
            }
        }

        // 4. Resolve Original Selected Stakeholders
        var initialStakeholderIds = new HashSet<Guid>();
        foreach (var s in esc.Stakeholders)
        {
            var isSpmOrHod = string.Equals(s.SubDepartment, "Senior Project Management", StringComparison.OrdinalIgnoreCase)
                             || string.Equals(s.SubDepartment, "Department Head", StringComparison.OrdinalIgnoreCase)
                             || spmIds.Contains(s.EmployeeId)
                             || hodIds.Contains(s.EmployeeId);
            if (!isSpmOrHod)
            {
                initialStakeholderIds.Add(s.EmployeeId);
            }
        }

        if (initialStakeholderIds.Count == 0)
        {
            var initialNotifRecipients = await db.ActionNotifications
                .AsNoTracking()
                .Where(n => n.ServiceEscalationId == esc.Id
                            && n.Type == "WBS Escalation"
                            && !n.Title.Contains("Level 1 Escalation")
                            && !n.Title.Contains("Level 2 Escalation")
                            && n.DeletedAtUtc == null)
                .Select(n => n.RecipientEmployeeId)
                .Distinct()
                .ToListAsync(ct);
            foreach (var id in initialNotifRecipients) initialStakeholderIds.Add(id);
        }

        if (initialStakeholderIds.Count == 0 && esc.Stakeholders.Count > 0)
        {
            var earliest = esc.Stakeholders.OrderBy(s => s.CreatedAtUtc).FirstOrDefault();
            if (earliest != null) initialStakeholderIds.Add(earliest.EmployeeId);
        }

        // 5. Determine Current SLA Stage dynamically
        bool isL2 = (slaInstance?.Events.Any(e => e.EventType == SlaEventType.EscalationL2 && e.Status == SlaEventStatus.Executed) == true)
                    || esc.Stakeholders.Any(s => string.Equals(s.SubDepartment, "Department Head", StringComparison.OrdinalIgnoreCase))
                    || l2NotifRecipients.Count > 0
                    || (!string.IsNullOrWhiteSpace(alert.Title) && alert.Title.Contains("Level 2 Escalation"));

        bool isL1 = !isL2 && (
                    (slaInstance?.Events.Any(e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Executed) == true)
                    || esc.Stakeholders.Any(s => string.Equals(s.SubDepartment, "Senior Project Management", StringComparison.OrdinalIgnoreCase))
                    || l1NotifRecipients.Count > 0
                    || (!string.IsNullOrWhiteSpace(alert.Title) && alert.Title.Contains("Level 1 Escalation")));

        // 6. Resolve Project Leadership (PM, EM, TL)
        var project = esc.Project ?? alert.Project;
        if (project == null && alert.ProjectId != Guid.Empty)
        {
            project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.Id == alert.ProjectId, ct);
        }

        var pmId = project?.ProjectManagerId;
        if (!pmId.HasValue && project != null)
        {
            pmId = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == project.Id && tm.MemberRole == ProjectMemberRoles.ProjectManager && tm.DeletedAtUtc == null)
                .Select(tm => (Guid?)tm.EmployeeId)
                .FirstOrDefaultAsync(ct);
        }

        var emId = project?.EngagementManagerId ?? project?.Client?.EngagementManagerId;
        if (!emId.HasValue && project != null)
        {
            emId = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == project.Id && (tm.MemberRole == "EngagementManager" || tm.MemberRole == "EM") && tm.DeletedAtUtc == null)
                .Select(tm => (Guid?)tm.EmployeeId)
                .FirstOrDefaultAsync(ct);
        }

        var tlId = project?.TeamLeadId;
        if (!tlId.HasValue && project != null)
        {
            tlId = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == project.Id && (tm.MemberRole == "TeamLead" || tm.MemberRole == "Team Leader") && tm.DeletedAtUtc == null)
                .Select(tm => (Guid?)tm.EmployeeId)
                .FirstOrDefaultAsync(ct);
        }

        // 7. Build Recipient Set based on Matrix:
        // Initial SLA: Selected Stakeholder -> PM, EM, TL
        // After L1: Selected Stakeholder -> PM, EM, TL, SPM
        // After L1: SPM -> PM, EM, TL, Selected Stakeholder
        // After L2: Selected Stakeholder -> PM, EM, TL, SPM, HOD
        // After L2: SPM -> PM, EM, TL, Selected Stakeholder, HOD
        // After L2: HOD -> PM, EM, TL, Selected Stakeholder, SPM
        var recipientSet = new HashSet<Guid>();
        if (pmId.HasValue) recipientSet.Add(pmId.Value);
        if (emId.HasValue) recipientSet.Add(emId.Value);
        if (tlId.HasValue) recipientSet.Add(tlId.Value);

        if (isL2)
        {
            foreach (var id in initialStakeholderIds) recipientSet.Add(id);
            foreach (var id in spmIds) recipientSet.Add(id);
            foreach (var id in hodIds) recipientSet.Add(id);
        }
        else if (isL1)
        {
            foreach (var id in initialStakeholderIds) recipientSet.Add(id);
            foreach (var id in spmIds) recipientSet.Add(id);
        }
        else
        {
            foreach (var id in initialStakeholderIds) recipientSet.Add(id);
        }

        // 8. Actor Exclusion: The person performing the status update must NOT receive a duplicate notification for their own action
        if (actorEmployeeId.HasValue)
        {
            recipientSet.Remove(actorEmployeeId.Value);
        }
        else if (!string.IsNullOrWhiteSpace(userName))
        {
            var matchingEmp = await db.Employees
                .AsNoTracking()
                .Where(e => (e.FirstName + " " + e.LastName).Trim().ToLower() == userName.Trim().ToLower() && e.DeletedAtUtc == null)
                .Select(e => (Guid?)e.Id)
                .FirstOrDefaultAsync(ct);
            if (matchingEmp.HasValue)
            {
                recipientSet.Remove(matchingEmp.Value);
            }
        }

        var candidateIds = recipientSet.Distinct().ToList();
        if (candidateIds.Count == 0)
        {
            return;
        }

        // 9. Filter out inactive or deleted employees
        var activeRecipientIds = await db.Employees
            .AsNoTracking()
            .Where(e => candidateIds.Contains(e.Id)
                        && e.DeletedAtUtc == null
                        && (e.Status == null || !e.Status.ToLower().StartsWith("inactive")))
            .Select(e => e.Id)
            .ToListAsync(ct);

        if (activeRecipientIds.Count == 0)
        {
            return;
        }

        // 10. Prepare Notification Data
        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        var notifTitle = $"WBS Escalation Status Updated: {esc.ServiceName} - {esc.Subject} [{oldStatus} -> {newStatus}]";
        if (notifTitle.Length > 255) notifTitle = notifTitle[..255];

        var relatedTask = esc.ServiceName.Length > 255 ? esc.ServiceName[..255] : esc.ServiceName;
        var projectName = project?.Name ?? esc.ProjectName;
        if (string.IsNullOrWhiteSpace(projectName)) projectName = "Project";

        var notifHistory = JsonSerializer.Serialize(new[]
        {
            new
            {
                action = $"WBS Escalation status changed from '{oldStatus}' to '{newStatus}'",
                date = dateStr,
                time = timeStr,
                by = userName
            }
        });

        var notificationsToAdd = new List<ActionNotification>();
        foreach (var rId in activeRecipientIds)
        {
            var alreadyExists = await db.ActionNotifications.AnyAsync(n =>
                n.RecipientEmployeeId == rId &&
                n.ProjectId == alert.ProjectId &&
                n.ServiceEscalationId == esc.Id &&
                n.Type == "WBS Escalation Status Update" &&
                n.Title == notifTitle &&
                n.CreatedAtUtc >= now.AddMinutes(-2) &&
                n.DeletedAtUtc == null, ct);

            if (!alreadyExists)
            {
                var notif = new ActionNotification
                {
                    RecipientEmployeeId = rId,
                    ProjectId = alert.ProjectId,
                    ProjectCode = project?.ProjectCode ?? esc.ProjectCode,
                    ProjectName = projectName,
                    Title = notifTitle,
                    Type = "WBS Escalation Status Update",
                    Priority = "Low",
                    Status = "Pending",
                    Unread = true,
                    RaisedByEmployeeId = actorEmployeeId,
                    RaisedByName = userName,
                    RelatedTask = relatedTask,
                    ServiceEscalationId = esc.Id,
                    HistoryJson = notifHistory,
                    CreatedAtUtc = now
                };
                db.ActionNotifications.Add(notif);
                notificationsToAdd.Add(notif);
            }
        }

        if (notificationsToAdd.Count > 0)
        {
            await db.SaveChangesAsync(ct);
            TrySyncNotificationsToOtherDatabase(notificationsToAdd);
        }
    }

    private async Task SendIssueStatusChangeNotificationsAsync(
        ProjectAlert alert,
        string oldStatus,
        string newStatus,
        string userName,
        Guid? actorEmployeeId,
        CancellationToken ct = default)
    {
        if (string.Equals(oldStatus, newStatus, StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        var issue = alert.Issue;
        if (issue == null && alert.IssueId.HasValue)
        {
            issue = await db.ProjectIssues
                .Include(i => i.Project)
                    .ThenInclude(p => p!.Client)
                .Include(i => i.RaisedByEmployee)
                .FirstOrDefaultAsync(i => i.Id == alert.IssueId.Value && i.DeletedAtUtc == null, ct);
        }

        if (issue == null && alert.ProjectId != Guid.Empty && !string.IsNullOrWhiteSpace(alert.Title))
        {
            issue = await db.ProjectIssues
                .Include(i => i.Project)
                    .ThenInclude(p => p!.Client)
                .Include(i => i.RaisedByEmployee)
                .FirstOrDefaultAsync(i => i.ProjectId == alert.ProjectId && i.Subject == alert.Title && i.DeletedAtUtc == null, ct);
        }

        if (issue == null)
        {
            return;
        }

        // 1. Query SLA Instance and Events for this Issue
        var slaInstance = await db.SlaInstances
            .AsNoTracking()
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == issue.Id && i.ActivityType == "Resolution of Issues", ct);

        // 2. Resolve notifications previously dispatched for L1 / L2 escalation of this issue
        var l2NotifRecipients = await db.ActionNotifications
            .AsNoTracking()
            .Where(n => n.IssueId == issue.Id
                        && (n.Type == "SLA Escalation" || n.Title.Contains("Level 2"))
                        && n.Title.Contains("Level 2")
                        && n.DeletedAtUtc == null)
            .Select(n => n.RecipientEmployeeId)
            .Distinct()
            .ToListAsync(ct);

        var l1NotifRecipients = await db.ActionNotifications
            .AsNoTracking()
            .Where(n => n.IssueId == issue.Id
                        && (n.Type == "SLA Escalation" || n.Title.Contains("Level 1"))
                        && n.Title.Contains("Level 1")
                        && n.DeletedAtUtc == null)
            .Select(n => n.RecipientEmployeeId)
            .Distinct()
            .ToListAsync(ct);

        // 3. Determine Current SLA Escalation Stage dynamically
        bool isL2 = (slaInstance?.Events.Any(e => e.EventType == SlaEventType.EscalationL2 && e.Status == SlaEventStatus.Executed) == true)
                    || l2NotifRecipients.Count > 0
                    || (!string.IsNullOrWhiteSpace(alert.HistoryJson) && alert.HistoryJson.Contains("Level 2 SLA Escalation"))
                    || (!string.IsNullOrWhiteSpace(alert.Title) && alert.Title.Contains("Level 2"));

        bool isL1 = !isL2 && (
                    (slaInstance?.Events.Any(e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Executed) == true)
                    || l1NotifRecipients.Count > 0
                    || (!string.IsNullOrWhiteSpace(alert.HistoryJson) && alert.HistoryJson.Contains("Level 1 SLA Escalation"))
                    || (!string.IsNullOrWhiteSpace(alert.Title) && alert.Title.Contains("Level 1")));

        // 4. Resolve Project Leadership (PM, EM, TL)
        var project = issue.Project ?? alert.Project;
        if (project == null && alert.ProjectId != Guid.Empty)
        {
            project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.Id == alert.ProjectId, ct);
        }

        var pmId = project?.ProjectManagerId;
        if (!pmId.HasValue && project != null)
        {
            pmId = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == project.Id && tm.MemberRole == ProjectMemberRoles.ProjectManager && tm.DeletedAtUtc == null)
                .Select(tm => (Guid?)tm.EmployeeId)
                .FirstOrDefaultAsync(ct);
        }

        var emId = project?.EngagementManagerId ?? project?.Client?.EngagementManagerId;
        if (!emId.HasValue && project != null)
        {
            emId = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == project.Id && (tm.MemberRole == "EngagementManager" || tm.MemberRole == "EM") && tm.DeletedAtUtc == null)
                .Select(tm => (Guid?)tm.EmployeeId)
                .FirstOrDefaultAsync(ct);
        }

        var tlId = project?.TeamLeadId;
        if (!tlId.HasValue && project != null)
        {
            tlId = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == project.Id && (tm.MemberRole == "TeamLead" || tm.MemberRole == "Team Leader") && tm.DeletedAtUtc == null)
                .Select(tm => (Guid?)tm.EmployeeId)
                .FirstOrDefaultAsync(ct);
        }

        // 5. Resolve Original Issue Raiser
        Guid? raiserId = issue.RaisedByEmployeeId ?? alert.RaisedByEmployeeId;
        if (!raiserId.HasValue && !string.IsNullOrWhiteSpace(issue.RaisedByName))
        {
            raiserId = await db.Employees
                .AsNoTracking()
                .Where(e => (e.FirstName + " " + e.LastName).Trim().ToLower() == issue.RaisedByName.Trim().ToLower() && e.DeletedAtUtc == null)
                .Select(e => (Guid?)e.Id)
                .FirstOrDefaultAsync(ct);
        }

        // 6. Resolve Senior Project Manager(s) dynamically
        var spmIds = new HashSet<Guid>();
        if (alert.ProjectId != Guid.Empty)
        {
            var projectSpms = await db.ProjectTeamMembers
                .AsNoTracking()
                .Where(tm => tm.ProjectId == alert.ProjectId
                             && tm.DeletedAtUtc == null
                             && (tm.MemberRole == ProjectMemberRoles.SeniorProjectManager
                                 || tm.MemberRole == "Senior Project Manager"
                                 || tm.MemberRole == "Senior PM"
                                 || tm.MemberRole == "SPM"
                                 || (tm.MemberRole != null && (tm.MemberRole.ToLower().Contains("senior") || tm.MemberRole.ToLower().Contains("spm")))))
                .Select(tm => tm.EmployeeId)
                .ToListAsync(ct);
            foreach (var id in projectSpms) spmIds.Add(id);
        }

        foreach (var id in l1NotifRecipients) spmIds.Add(id);

        if (spmIds.Count == 0 && slaRecipientResolver != null)
        {
            var dummyInstance = slaInstance ?? new SlaInstance { ProjectId = alert.ProjectId, ActivityType = "Resolution of Issues", EntityId = issue.Id };
            var resolvedSpms = await slaRecipientResolver.ResolveRecipientsAsync(dummyInstance, ["Assigned Senior Project Manager"], ct);
            foreach (var id in resolvedSpms) spmIds.Add(id);
        }

        // 7. Resolve Head of Department(s) dynamically
        var hodIds = new HashSet<Guid>();
        foreach (var id in l2NotifRecipients) hodIds.Add(id);

        if (hodIds.Count == 0 && project != null)
        {
            var projectHods = await ResolveProjectHodAsync(project, ct);
            foreach (var id in projectHods) hodIds.Add(id);
        }

        if (hodIds.Count == 0 && slaRecipientResolver != null)
        {
            var dummyInstance = slaInstance ?? new SlaInstance { ProjectId = alert.ProjectId, ActivityType = "Resolution of Issues", EntityId = issue.Id };
            var resolvedHods = await slaRecipientResolver.ResolveRecipientsAsync(dummyInstance, ["Head of Department"], ct);
            foreach (var id in resolvedHods) hodIds.Add(id);
        }

        if (hodIds.Count == 0)
        {
            var hodOnFloorRoles = await db.OnFloorRoles
                .AsNoTracking()
                .Where(o => o.DeletedAtUtc == null && (
                    o.Name.ToLower() == "head of department"
                    || o.Name.ToLower() == "hod"
                    || o.Name.ToLower().Contains("head of department")
                    || o.Name.Contains("Head Of Department")
                ))
                .Select(o => o.DesignationId)
                .Distinct()
                .ToListAsync(ct);

            if (hodOnFloorRoles.Count > 0)
            {
                var hodEmps = await db.Employees
                    .AsNoTracking()
                    .Where(e => e.DeletedAtUtc == null
                                && (e.Status == null || !e.Status.ToLower().StartsWith("inactive"))
                                && e.DesignationId.HasValue
                                && hodOnFloorRoles.Contains(e.DesignationId.Value))
                    .Select(e => e.Id)
                    .ToListAsync(ct);
                foreach (var id in hodEmps) hodIds.Add(id);
            }
        }

        // 8. Build Recipient Set based on Matrix (Section 5):
        // Initial SLA: Any user -> PM, EM, TL, Issue Raiser, excluding updater
        // After L1:    Any user -> PM, EM, TL, Issue Raiser, SPM, excluding updater
        // After L2:    Any user -> PM, EM, TL, Issue Raiser, SPM, HOD, excluding updater
        var recipientSet = new HashSet<Guid>();
        if (pmId.HasValue) recipientSet.Add(pmId.Value);
        if (emId.HasValue) recipientSet.Add(emId.Value);
        if (tlId.HasValue) recipientSet.Add(tlId.Value);
        if (raiserId.HasValue) recipientSet.Add(raiserId.Value);

        if (isL2)
        {
            foreach (var id in spmIds) recipientSet.Add(id);
            foreach (var id in hodIds) recipientSet.Add(id);
        }
        else if (isL1)
        {
            foreach (var id in spmIds) recipientSet.Add(id);
        }

        // 9. Actor Exclusion: Never send a notification to the user who performed the status update
        if (actorEmployeeId.HasValue)
        {
            recipientSet.Remove(actorEmployeeId.Value);
        }
        else if (!string.IsNullOrWhiteSpace(userName))
        {
            var matchingEmp = await db.Employees
                .AsNoTracking()
                .Where(e => (e.FirstName + " " + e.LastName).Trim().ToLower() == userName.Trim().ToLower() && e.DeletedAtUtc == null)
                .Select(e => (Guid?)e.Id)
                .FirstOrDefaultAsync(ct);
            if (matchingEmp.HasValue)
            {
                recipientSet.Remove(matchingEmp.Value);
            }
        }

        var candidateIds = recipientSet.Distinct().ToList();
        if (candidateIds.Count == 0)
        {
            return;
        }

        // 10. Filter out inactive or deleted employees
        var activeRecipientIds = await db.Employees
            .AsNoTracking()
            .Where(e => candidateIds.Contains(e.Id)
                        && e.DeletedAtUtc == null
                        && (e.Status == null || !e.Status.ToLower().StartsWith("inactive")))
            .Select(e => e.Id)
            .ToListAsync(ct);

        if (activeRecipientIds.Count == 0)
        {
            return;
        }

        // 11. Prepare Notification Data
        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");

        var notifTitle = $"Issue Status Updated: {issue.Subject} [{oldStatus} -> {newStatus}]";
        if (notifTitle.Length > 255) notifTitle = notifTitle[..255];

        var relatedTask = issue.Subject.Length > 255 ? issue.Subject[..255] : issue.Subject;
        var projectName = project?.Name ?? issue.ProjectName;
        if (string.IsNullOrWhiteSpace(projectName)) projectName = "Project";

        var notifHistory = JsonSerializer.Serialize(new[]
        {
            new
            {
                action = $"Issue status changed from '{oldStatus}' to '{newStatus}'",
                date = dateStr,
                time = timeStr,
                by = userName
            }
        });

        var notificationsToAdd = new List<ActionNotification>();
        foreach (var rId in activeRecipientIds)
        {
            var alreadyExists = await db.ActionNotifications.AnyAsync(n =>
                n.RecipientEmployeeId == rId &&
                n.ProjectId == alert.ProjectId &&
                n.IssueId == issue.Id &&
                n.Type == "Issue Status Update" &&
                n.Title == notifTitle &&
                n.CreatedAtUtc >= now.AddMinutes(-2) &&
                n.DeletedAtUtc == null, ct);

            if (!alreadyExists)
            {
                var notif = new ActionNotification
                {
                    RecipientEmployeeId = rId,
                    ProjectId = alert.ProjectId,
                    ProjectCode = project?.ProjectCode ?? issue.ProjectCode,
                    ProjectName = projectName,
                    Title = notifTitle,
                    Type = "Issue Status Update",
                    Priority = "Low",
                    Status = "Pending",
                    Unread = true,
                    RaisedByEmployeeId = actorEmployeeId,
                    RaisedByName = userName,
                    RelatedTask = relatedTask,
                    IssueId = issue.Id,
                    ServiceEscalationId = alert.ServiceEscalationId,
                    HistoryJson = notifHistory,
                    CreatedAtUtc = now
                };
                db.ActionNotifications.Add(notif);
                notificationsToAdd.Add(notif);
            }
        }

        if (notificationsToAdd.Count > 0)
        {
            await db.SaveChangesAsync(ct);
            TrySyncNotificationsToOtherDatabase(notificationsToAdd);
        }
    }



    #region Project Allocation PM/SPM Assignment Automated Reminders

    public async Task StartProjectAllocationReminderWorkflowAsync(Guid projectId, CancellationToken ct = default)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct);

        if (project == null) return;

        // Check if both PM and SPM are already assigned
        var isPmAssigned = project.ProjectManagerId.HasValue || await db.ProjectTeamMembers.AnyAsync(m =>
            m.ProjectId == projectId &&
            (m.MemberRole == ProjectMemberRoles.ProjectManager || m.MemberRole == "Project Manager") &&
            m.DeletedAtUtc == null, ct);

        var isSpmAssigned = await db.ProjectTeamMembers.AnyAsync(m =>
            m.ProjectId == projectId &&
            (m.MemberRole == ProjectMemberRoles.SeniorProjectManager || m.MemberRole == "Senior Project Manager") &&
            m.DeletedAtUtc == null, ct);

        // If both are already assigned, no reminders needed
        if (isPmAssigned && isSpmAssigned) return;

        // Avoid duplicate reminder workflows if the same Project/WBS creation operation is retried
        var workflowAlreadyStarted = await db.ActionNotifications.AnyAsync(n =>
            n.ProjectId == projectId &&
            n.Type == "Project Allocation Reminder" &&
            n.DeletedAtUtc == null, ct);

        if (workflowAlreadyStarted)
        {
            logger?.LogInformation("Project allocation reminder workflow already started for project {ProjectId}. Skipping duplicate initialization.", projectId);
            return;
        }

        // Resolve assigned Engagement Manager
        var emId = await ResolveEngagementManagerIdAsync(project, ct);
        if (!emId.HasValue)
        {
            logger?.LogWarning("Engagement Manager could not be resolved for project {ProjectId} ('{ProjectName}'). Reminders cannot be dispatched.", projectId, project.Name);
            return;
        }

        var projectName = project.Name;
        var wbsId = !string.IsNullOrWhiteSpace(project.WbsId) ? project.WbsId : project.ProjectCode;
        var jobWbsId = !string.IsNullOrWhiteSpace(wbsId) ? wbsId : projectName;

        // Send initial assignment reminder to Engagement Manager
        var title = BuildEmReminderTitle(projectName, project.WbsId);
        var details = $"Project Manager and Senior Project Manager assignment is pending for project '{projectName}'{(string.IsNullOrWhiteSpace(project.WbsId) ? "" : $" (WBS: {project.WbsId})")}. Please assign both positions.";

        var initialNotif = new ActionNotification
        {
            Id = Guid.NewGuid(),
            RecipientEmployeeId = emId.Value,
            ProjectId = project.Id,
            ProjectCode = project.ProjectCode,
            ProjectName = projectName,
            Title = title,
            Type = "Project Allocation Reminder",
            Priority = "Low",
            Status = "Pending",
            Unread = true,
            RaisedByName = "System / Automation Engine",
            RelatedTask = wbsId ?? projectName,
            CreatedAtUtc = DateTime.UtcNow,
            HistoryJson = JsonSerializer.Serialize(new[]
            {
                new
                {
                    status = "Pending",
                    interval = 0,
                    at = DateTime.UtcNow.ToString("o"),
                    details = details
                }
            })
        };

        db.ActionNotifications.Add(initialNotif);
        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(new[] { initialNotif });

        // Schedule 2-Hour Reminder Job in Hangfire
        var remJobId = BackgroundJob.Schedule<IActionNotificationService>(
            s => s.ExecuteProjectAllocationReminderJobAsync(project.Id, projectName, jobWbsId, 1),
            TimeSpan.FromHours(2));
        s_activeReminderJobs[projectId] = remJobId;

        // Schedule Same-Day HOD Check Job in Hangfire (at End of Day in IST)
        var ist = ResolveIstTimeZone();
        var createdInIst = TimeZoneInfo.ConvertTimeFromUtc(project.CreatedAtUtc != default ? project.CreatedAtUtc : DateTime.UtcNow, ist);
        var eodIst = createdInIst.Date.AddHours(18); // 18:00 IST
        if (createdInIst >= eodIst)
        {
            eodIst = createdInIst.Date.AddDays(1).AddSeconds(-1);
        }
        var eodUtc = TimeZoneInfo.ConvertTimeToUtc(eodIst, ist);
        var hodDelay = eodUtc > DateTime.UtcNow ? eodUtc - DateTime.UtcNow : TimeSpan.FromMinutes(1);

        var hodJobId = BackgroundJob.Schedule<IActionNotificationService>(
            s => s.ExecuteSameDayHodCheckJobAsync(project.Id, projectName, jobWbsId),
            hodDelay);
        s_activeHodJobs[projectId] = hodJobId;
    }

    [JobDisplayName("Project Allocation | PM-SPM Assignment Reminder | {1} | {2}")]
    public async Task ExecuteProjectAllocationReminderJobAsync(Guid projectId, string projectName, string wbsId, int reminderCount)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null);

        if (project == null)
        {
            logger?.LogWarning("Project {ProjectId} not found or deleted. Terminating reminder job.", projectId);
            s_activeReminderJobs.TryRemove(projectId, out _);
            return;
        }

        // Always verify latest assignment state directly from database
        var isPmAssigned = project.ProjectManagerId.HasValue || await db.ProjectTeamMembers.AnyAsync(m =>
            m.ProjectId == projectId &&
            (m.MemberRole == ProjectMemberRoles.ProjectManager || m.MemberRole == "Project Manager") &&
            m.DeletedAtUtc == null);

        var isSpmAssigned = await db.ProjectTeamMembers.AnyAsync(m =>
            m.ProjectId == projectId &&
            (m.MemberRole == ProjectMemberRoles.SeniorProjectManager || m.MemberRole == "Senior Project Manager") &&
            m.DeletedAtUtc == null);

        // Note: Reminder notifications will continue until and unless BOTH PM and SPM are assigned
        if (isPmAssigned && isSpmAssigned)
        {
            logger?.LogInformation("Both PM and SPM are assigned for project {ProjectId}. Stopping 2-hour reminder workflow.", projectId);
            s_activeReminderJobs.TryRemove(projectId, out _);
            return;
        }

        // Check duplicate execution guard for this interval
        var duplicateInterval = await db.ActionNotifications.AnyAsync(n =>
            n.ProjectId == projectId &&
            n.Type == "Project Allocation Reminder" &&
            n.HistoryJson.Contains($"\"interval\":{reminderCount}") &&
            n.DeletedAtUtc == null);

        if (!duplicateInterval)
        {
            var emId = await ResolveEngagementManagerIdAsync(project);
            if (emId.HasValue)
            {
                var title = BuildEmReminderTitle(project.Name, project.WbsId);
                var details = $"Project Manager and Senior Project Manager assignment is still pending for project '{project.Name}'{(string.IsNullOrWhiteSpace(project.WbsId) ? "" : $" (WBS: {project.WbsId})")}.";

                var reminderNotif = new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = emId.Value,
                    ProjectId = project.Id,
                    ProjectCode = project.ProjectCode,
                    ProjectName = project.Name,
                    Title = title,
                    Type = "Project Allocation Reminder",
                    Priority = "Low",
                    Status = "Pending",
                    Unread = true,
                    RaisedByName = "System / Automation Engine",
                    RelatedTask = project.WbsId ?? project.ProjectCode ?? project.Name,
                    CreatedAtUtc = DateTime.UtcNow,
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            status = "Pending",
                            interval = reminderCount,
                            at = DateTime.UtcNow.ToString("o"),
                            details = details
                        }
                    })
                };

                db.ActionNotifications.Add(reminderNotif);
                await db.SaveChangesAsync();
                TrySyncNotificationsToOtherDatabase(new[] { reminderNotif });
            }
        }

        // Schedule next 2-hour reminder
        var jobWbsId = !string.IsNullOrWhiteSpace(project.WbsId) ? project.WbsId : (!string.IsNullOrWhiteSpace(project.ProjectCode) ? project.ProjectCode : project.Name);
        var nextJobId = BackgroundJob.Schedule<IActionNotificationService>(
            s => s.ExecuteProjectAllocationReminderJobAsync(project.Id, project.Name, jobWbsId, reminderCount + 1),
            TimeSpan.FromHours(2));
        s_activeReminderJobs[projectId] = nextJobId;
    }

    [JobDisplayName("Project Allocation | Same-Day Pending Assignment Alert | HOD | {1} | {2}")]
    public async Task ExecuteSameDayHodCheckJobAsync(Guid projectId, string projectName, string wbsId)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null);

        if (project == null)
        {
            logger?.LogWarning("Project {ProjectId} not found or deleted. Terminating HOD alert job.", projectId);
            s_activeHodJobs.TryRemove(projectId, out _);
            return;
        }

        // Check latest PM/SPM assignment state from database
        var isPmAssigned = project.ProjectManagerId.HasValue || await db.ProjectTeamMembers.AnyAsync(m =>
            m.ProjectId == projectId &&
            (m.MemberRole == ProjectMemberRoles.ProjectManager || m.MemberRole == "Project Manager") &&
            m.DeletedAtUtc == null);

        var isSpmAssigned = await db.ProjectTeamMembers.AnyAsync(m =>
            m.ProjectId == projectId &&
            (m.MemberRole == ProjectMemberRoles.SeniorProjectManager || m.MemberRole == "Senior Project Manager") &&
            m.DeletedAtUtc == null);

        // Section 5 & 10: If PM or SPM was assigned before the end-of-day HOD check -> HOD notification is not generated.
        // Only if BOTH remain unassigned at end of creation day -> send HOD alert.
        if (isPmAssigned || isSpmAssigned)
        {
            logger?.LogInformation("Project {ProjectId} has at least one leadership position assigned (PM: {IsPm}, SPM: {IsSpm}). HOD alert will not be generated.", projectId, isPmAssigned, isSpmAssigned);
            s_activeHodJobs.TryRemove(projectId, out _);
            return;
        }

        // Guard against duplicate HOD alert for this project
        var alreadySent = await db.ActionNotifications.AnyAsync(n =>
            n.ProjectId == projectId &&
            n.Type == "Project Allocation Escalation" &&
            n.DeletedAtUtc == null);

        if (alreadySent)
        {
            logger?.LogInformation("HOD alert already generated for project {ProjectId}. Skipping duplicate.", projectId);
            s_activeHodJobs.TryRemove(projectId, out _);
            return;
        }

        // Resolve relevant HOD(s) dynamically using On Floor Role = Head Of Department
        var hodIds = await ResolveProjectHodAsync(project);
        if (hodIds.Count == 0)
        {
            logger?.LogWarning("No Head of Department found for project {ProjectId} ('{ProjectName}'). HOD alert could not be dispatched.", projectId, project.Name);
            s_activeHodJobs.TryRemove(projectId, out _);
            return;
        }

        var title = BuildHodAlertTitle(project.Name, project.WbsId);
        var details = $"Both Project Manager and Senior Project Manager assignments remain pending at the end of the creation day for project '{project.Name}'{(string.IsNullOrWhiteSpace(project.WbsId) ? "" : $" (WBS: {project.WbsId})")}.";

        var addedList = new List<ActionNotification>();
        foreach (var hodId in hodIds)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = hodId,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = title,
                Type = "Project Allocation Escalation",
                Priority = "Low",
                Status = "Pending",
                Unread = true,
                RaisedByName = "System / Automation Engine",
                RelatedTask = project.WbsId ?? project.ProjectCode ?? project.Name,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Pending",
                        at = DateTime.UtcNow.ToString("o"),
                        details = details
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync();
        TrySyncNotificationsToOtherDatabase(addedList);
        s_activeHodJobs.TryRemove(projectId, out _);
    }

    public Task CancelProjectAllocationRemindersAsync(Guid projectId, CancellationToken ct = default)
    {
        if (s_activeReminderJobs.TryRemove(projectId, out var remJobId))
        {
            try
            {
                BackgroundJob.Delete(remJobId);
                logger?.LogInformation("Deleted Hangfire reminder job {JobId} for project {ProjectId}.", remJobId, projectId);
            }
            catch (Exception ex)
            {
                logger?.LogWarning(ex, "Failed deleting Hangfire reminder job {JobId} for project {ProjectId}.", remJobId, projectId);
            }
        }

        if (s_activeHodJobs.TryRemove(projectId, out var hodJobId))
        {
            try
            {
                BackgroundJob.Delete(hodJobId);
                logger?.LogInformation("Deleted Hangfire HOD alert job {JobId} for project {ProjectId}.", hodJobId, projectId);
            }
            catch (Exception ex)
            {
                logger?.LogWarning(ex, "Failed deleting Hangfire HOD alert job {JobId} for project {ProjectId}.", hodJobId, projectId);
            }
        }

        return Task.CompletedTask;
    }

    private async Task<Guid?> ResolveEngagementManagerIdAsync(Project project, CancellationToken ct = default)
    {
        if (project.EngagementManagerId.HasValue && project.EngagementManagerId.Value != Guid.Empty)
            return project.EngagementManagerId.Value;

        if (project.Client?.EngagementManagerId.HasValue == true && project.Client.EngagementManagerId.Value != Guid.Empty)
            return project.Client.EngagementManagerId.Value;

        if (!string.IsNullOrWhiteSpace(project.EngagementManager))
        {
            var trimmed = project.EngagementManager.Trim().ToLower();
            var emp = await db.Employees.FirstOrDefaultAsync(e =>
                e.DeletedAtUtc == null &&
                ((e.FirstName + " " + e.LastName).Trim().ToLower() == trimmed ||
                 (e.WorkEmail != null && e.WorkEmail.ToLower() == trimmed) ||
                 (e.PersonalEmail != null && e.PersonalEmail.ToLower() == trimmed)), ct);
            if (emp != null) return emp.Id;
        }

        if (project.ClientId != Guid.Empty)
        {
            var client = await db.Clients.FirstOrDefaultAsync(c => c.Id == project.ClientId && c.DeletedAtUtc == null, ct);
            if (client?.EngagementManagerId.HasValue == true && client.EngagementManagerId.Value != Guid.Empty)
                return client.EngagementManagerId.Value;

            if (!string.IsNullOrWhiteSpace(client?.EngagementManager))
            {
                var trimmed = client.EngagementManager.Trim().ToLower();
                var emp = await db.Employees.FirstOrDefaultAsync(e =>
                    e.DeletedAtUtc == null &&
                    ((e.FirstName + " " + e.LastName).Trim().ToLower() == trimmed ||
                     (e.WorkEmail != null && e.WorkEmail.ToLower() == trimmed) ||
                     (e.PersonalEmail != null && e.PersonalEmail.ToLower() == trimmed)), ct);
                if (emp != null) return emp.Id;
            }
        }

        // Fallback: Check project team members with role EngagementManager or EM
        var tmEmId = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null &&
                        (m.MemberRole.ToLower().Contains("engagement") || m.MemberRole.ToLower() == "em"))
            .Select(m => (Guid?)m.EmployeeId)
            .FirstOrDefaultAsync(ct);

        return tmEmId;
    }

    private async Task<List<Guid>> ResolveProjectHodAsync(Project project, CancellationToken ct = default)
    {
        var projectDeptIds = new HashSet<Guid>();
        var projectSubDeptNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        // 1. From Project Services
        var services = await db.ProjectServices
            .AsNoTracking()
            .Include(s => s.ServiceCatalog)
                .ThenInclude(sc => sc.SubDepartment)
            .Where(s => s.ProjectId == project.Id && s.DeletedAtUtc == null)
            .ToListAsync(ct);

        foreach (var s in services)
        {
            if (s.ServiceCatalog?.SubDepartment != null && s.ServiceCatalog.SubDepartment.DepartmentId != Guid.Empty)
                projectDeptIds.Add(s.ServiceCatalog.SubDepartment.DepartmentId);
            if (!string.IsNullOrWhiteSpace(s.Department))
            {
                var d = await db.Departments.FirstOrDefaultAsync(dept => dept.Name.ToLower() == s.Department.ToLower() && dept.DeletedAtUtc == null, ct);
                if (d != null) projectDeptIds.Add(d.Id);
            }
            if (!string.IsNullOrWhiteSpace(s.SubDepartment))
                projectSubDeptNames.Add(s.SubDepartment.Trim());
        }

        // 2. From EM if project services don't yield department
        if (projectDeptIds.Count == 0 && project.EngagementManagerId.HasValue)
        {
            var em = await db.Employees.FirstOrDefaultAsync(e => e.Id == project.EngagementManagerId.Value, ct);
            if (em?.DepartmentId.HasValue == true)
                projectDeptIds.Add(em.DepartmentId.Value);
            if (!string.IsNullOrWhiteSpace(em?.SubDepartment))
                projectSubDeptNames.Add(em.SubDepartment.Trim());
        }

        // 3. Find OnFloorRoles with Name = "Head Of Department" / "Head of Department" / "HOD"
        var hodRoles = await db.OnFloorRoles
            .AsNoTracking()
            .Where(o => o.DeletedAtUtc == null && (
                o.Name.ToLower() == "head of department" ||
                o.Name.ToLower() == "hod" ||
                o.Name.Contains("Head Of Department") ||
                o.Name.ToLower().Contains("head of department")
            ))
            .ToListAsync(ct);

        var hodDesigIds = hodRoles.Select(o => o.DesignationId).Distinct().ToList();

        // 4. Query active employees holding those designations
        var candidates = await db.Employees
            .AsNoTracking()
            .Include(e => e.Department)
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null &&
                        (e.Status == null || !e.Status.ToLower().StartsWith("inactive")))
            .Where(e => e.DesignationId.HasValue && hodDesigIds.Contains(e.DesignationId.Value))
            .ToListAsync(ct);

        // Filter by matching department/subdepartment if available
        var matchedHodIds = new List<Guid>();
        if (projectDeptIds.Count > 0 || projectSubDeptNames.Count > 0)
        {
            foreach (var c in candidates)
            {
                bool deptMatch = c.DepartmentId.HasValue && projectDeptIds.Contains(c.DepartmentId.Value);
                bool subDeptMatch = (!string.IsNullOrWhiteSpace(c.SubDepartment) && projectSubDeptNames.Contains(c.SubDepartment))
                    || (c.SubDepartmentRef != null && projectSubDeptNames.Contains(c.SubDepartmentRef.Name));

                if (deptMatch || subDeptMatch)
                {
                    matchedHodIds.Add(c.Id);
                }
            }
        }

        // Fallback: if no department match or project has no services yet, return active employees with Head of Department OnFloorRole
        if (matchedHodIds.Count == 0 && candidates.Count > 0)
        {
            var deptHodDesigs = hodRoles.Where(r => r.DepartmentId.HasValue && projectDeptIds.Contains(r.DepartmentId.Value))
                                        .Select(r => r.DesignationId).ToHashSet();
            if (deptHodDesigs.Count > 0)
            {
                var deptMatches = candidates.Where(c => c.DesignationId.HasValue && deptHodDesigs.Contains(c.DesignationId.Value)).Select(c => c.Id).ToList();
                if (deptMatches.Count > 0) return deptMatches;
            }

            matchedHodIds.AddRange(candidates.Select(c => c.Id));
        }

        // If still 0, try slaRecipientResolver if available
        if (matchedHodIds.Count == 0 && slaRecipientResolver != null)
        {
            var dummyInstance = new SlaInstance { ProjectId = project.Id, ActivityType = "Project Allocation" };
            var resolved = await slaRecipientResolver.ResolveRecipientsAsync(dummyInstance, ["Head of Department"], ct);
            matchedHodIds.AddRange(resolved);
        }

        return matchedHodIds.Distinct().ToList();
    }

    private static string BuildEmReminderTitle(string projectName, string? wbsId)
    {
        if (string.IsNullOrWhiteSpace(wbsId))
            return $"Project Manager and Senior Project Manager Assignment Pending | {projectName}";
        return $"Project Manager and Senior Project Manager Assignment Pending | {projectName} | {wbsId}";
    }

    private static string BuildHodAlertTitle(string projectName, string? wbsId)
    {
        if (string.IsNullOrWhiteSpace(wbsId))
            return $"Project Manager and Senior Project Manager Assignment Still Pending | {projectName}";
        return $"Project Manager and Senior Project Manager Assignment Still Pending | {projectName} | {wbsId}";
    }

    private static TimeZoneInfo ResolveIstTimeZone()
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch
        {
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
            }
            catch
            {
                return TimeZoneInfo.CreateCustomTimeZone("IST", TimeSpan.FromHours(5.5), "India Standard Time", "India Standard Time");
            }
        }
    }

    #endregion

    #region WBS Service Wise Prerequisite Tracking Notifications & SLA Escalations

    public async Task NotifyServiceStartedAsync(Guid projectId, Guid serviceId, string? performerName = null, CancellationToken ct = default)
    {
        // 1. Cancel pending SLA escalation jobs for this service
        await CancelServicePrerequisiteSlaWorkflowAsync(serviceId, ct);

        var service = await db.ProjectServices
            .Include(s => s.Project)
                .ThenInclude(p => p.Client)
            .FirstOrDefaultAsync(s => s.Id == serviceId && s.ProjectId == projectId && s.DeletedAtUtc == null, ct);

        if (service?.Project == null) return;
        var project = service.Project;

        var recipients = await ResolveServiceStartedRecipientsAsync(project, ct);
        if (recipients.Count == 0) return;

        var title = $"Service Started: {service.ServiceName} | {project.Name}";
        var details = $"Service '{service.ServiceName}' has been started from Service wise Prerequisite Tracking for project '{project.Name}'.";

        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = title,
                Type = "Service Started",
                Priority = "Low",
                Status = "Started",
                Unread = true,
                RaisedByName = performerName ?? currentUser.Name ?? "System",
                RelatedTask = service.ServiceName,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Started",
                        serviceId = service.Id.ToString(),
                        serviceName = service.ServiceName,
                        at = DateTime.UtcNow.ToString("o"),
                        details = details
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);

        // 2. Check if all services in this project are now started
        var remainingUnstarted = await db.ProjectServices
            .AnyAsync(s => s.ProjectId == projectId && s.Id != serviceId && !s.IsReady && s.DeletedAtUtc == null, ct);

        if (!remainingUnstarted)
        {
            await CancelProjectServicePrerequisiteReminderWorkflowAsync(projectId, ct);
        }
    }

    public async Task StartProjectServicePrerequisiteReminderWorkflowAsync(Guid projectId, CancellationToken ct = default)
    {
        var project = await db.Projects
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct);

        if (project == null) return;

        var hasUnstartedServices = await db.ProjectServices
            .AnyAsync(s => s.ProjectId == projectId && !s.IsReady && s.DeletedAtUtc == null, ct);
        if (!hasUnstartedServices) return;

        if (s_activeServicePrereqReminderJobs.ContainsKey(projectId)) return;

        DateTime deadlineUtc;
        if (deadlineCalculator != null)
        {
            deadlineUtc = deadlineCalculator.CalculateTargetDeadline(
                project.CreatedAtUtc != default ? project.CreatedAtUtc : DateTime.UtcNow,
                1080, // 2 working days (2 * 540 min) to EOD in IST
                SlaCalculationMode.EndOfDay,
                useBusinessTimeZone: true);
        }
        else
        {
            var ist = ResolveIstTimeZone();
            var nowIst = TimeZoneInfo.ConvertTimeFromUtc(project.CreatedAtUtc != default ? project.CreatedAtUtc : DateTime.UtcNow, ist);
            var targetIst = nowIst.Date.AddDays(2).AddHours(18); // 18:00 IST
            deadlineUtc = TimeZoneInfo.ConvertTimeToUtc(targetIst, ist);
        }

        var delay = deadlineUtc > DateTime.UtcNow ? deadlineUtc - DateTime.UtcNow : TimeSpan.FromMinutes(1);

        var jobId = BackgroundJob.Schedule<IActionNotificationService>(
            s => s.ExecuteServicePrerequisitePendingReminderJobAsync(projectId, 1),
            delay);
        s_activeServicePrereqReminderJobs[projectId] = jobId;
    }

    public Task CancelProjectServicePrerequisiteReminderWorkflowAsync(Guid projectId, CancellationToken ct = default)
    {
        if (s_activeServicePrereqReminderJobs.TryRemove(projectId, out var jobId))
        {
            try
            {
                BackgroundJob.Delete(jobId);
                logger?.LogInformation("Deleted Service Prerequisite Reminder job {JobId} for project {ProjectId}.", jobId, projectId);
            }
            catch (Exception ex)
            {
                logger?.LogWarning(ex, "Failed deleting Service Prerequisite Reminder job {JobId} for project {ProjectId}.", jobId, projectId);
            }
        }
        return Task.CompletedTask;
    }

    [JobDisplayName("Service Prerequisite | 2-Day Daily EOD Reminder | PMO & EM | {0} | Day {1}")]
    public async Task ExecuteServicePrerequisitePendingReminderJobAsync(Guid projectId, int reminderDay)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null);

        if (project == null)
        {
            s_activeServicePrereqReminderJobs.TryRemove(projectId, out _);
            return;
        }

        var unstartedServices = await db.ProjectServices
            .Where(s => s.ProjectId == projectId && !s.IsReady && s.DeletedAtUtc == null)
            .ToListAsync();

        if (unstartedServices.Count == 0)
        {
            logger?.LogInformation("All services started for project {ProjectId}. Terminating prerequisite reminder workflow.", projectId);
            s_activeServicePrereqReminderJobs.TryRemove(projectId, out _);
            return;
        }

        await DispatchServicePrerequisitePendingReminderAsync(project, unstartedServices, reminderDay);

        s_activeServicePrereqReminderJobs.TryRemove(projectId, out _);

        // Schedule next daily EOD reminder at 18:00 IST
        DateTime nextEodUtc;
        if (deadlineCalculator != null)
        {
            nextEodUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(DateTime.UtcNow);
        }
        else
        {
            var ist = ResolveIstTimeZone();
            var nowIst = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, ist);
            var targetIst = nowIst.Date.AddDays(1).AddHours(18);
            nextEodUtc = TimeZoneInfo.ConvertTimeToUtc(targetIst, ist);
        }

        var delay = nextEodUtc > DateTime.UtcNow ? nextEodUtc - DateTime.UtcNow : TimeSpan.FromDays(1);
        var nextJobId = BackgroundJob.Schedule<IActionNotificationService>(
            s => s.ExecuteServicePrerequisitePendingReminderJobAsync(projectId, reminderDay + 1),
            delay);
        s_activeServicePrereqReminderJobs[projectId] = nextJobId;
    }

    private async Task DispatchServicePrerequisitePendingReminderAsync(Project project, List<ProjectServiceEntity> unstartedServices, int reminderDay)
    {
        var todayUtc = DateTime.UtcNow.Date;
        var alreadySentToday = await db.ActionNotifications.AnyAsync(n =>
            n.ProjectId == project.Id &&
            n.Type == "Service Prerequisite Reminder" &&
            n.CreatedAtUtc >= todayUtc &&
            n.DeletedAtUtc == null);

        if (alreadySentToday)
        {
            logger?.LogInformation("Service prerequisite reminder already sent today for project {ProjectId}.", project.Id);
            return;
        }

        var recipients = new List<PMS.API.Modules.Resources.Models.Employee>();

        // 1. PMO
        var pmoList = await ResolvePmoEmployeesAsync();
        foreach (var pmo in pmoList)
        {
            if (!recipients.Any(r => r.Id == pmo.Id)) recipients.Add(pmo);
        }

        // 2. Assigned Engagement Manager
        var emId = await ResolveEngagementManagerIdAsync(project);
        if (emId.HasValue)
        {
            var em = await db.Employees.FirstOrDefaultAsync(e => e.Id == emId.Value && e.DeletedAtUtc == null);
            if (em != null && !recipients.Any(r => r.Id == em.Id))
            {
                recipients.Add(em);
            }
        }

        if (recipients.Count == 0) return;

        var title = $"{project.Name} Service wise Prerequisite Tracking is still pending";
        var details = $"Service wise Prerequisite Tracking is still pending for project '{project.Name}'. The following {unstartedServices.Count} service(s) have not been started within 2 days: {string.Join(", ", unstartedServices.Select(s => s.ServiceName))}.";

        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = title,
                Type = "Service Prerequisite Reminder",
                Priority = "Medium",
                Status = "Pending",
                Unread = true,
                RaisedByName = "System / Automation Engine",
                RelatedTask = project.Name,
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = "Pending",
                        day = reminderDay,
                        unstartedCount = unstartedServices.Count,
                        unstartedServices = unstartedServices.Select(s => s.ServiceName).ToArray(),
                        at = DateTime.UtcNow.ToString("o"),
                        details = details
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync();
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    [JobDisplayName("Service Prerequisite | Daily EOD Check All Projects | PMO & EM")]
    public async Task ExecuteAllProjectsServicePrerequisiteDailyEodCheckAsync()
    {
        var cutoffUtc = DateTime.UtcNow.AddDays(-2); // At least 2 days old
        var unstartedProjectIds = await db.ProjectServices
            .Where(s => !s.IsReady && s.DeletedAtUtc == null)
            .Select(s => s.ProjectId)
            .Distinct()
            .ToListAsync();

        var candidateProjects = await db.Projects
            .Include(p => p.Client)
            .Where(p => unstartedProjectIds.Contains(p.Id) && p.DeletedAtUtc == null && p.CreatedAtUtc <= cutoffUtc)
            .ToListAsync();

        foreach (var project in candidateProjects)
        {
            var unstartedServices = await db.ProjectServices
                .Where(s => s.ProjectId == project.Id && !s.IsReady && s.DeletedAtUtc == null)
                .ToListAsync();

            if (unstartedServices.Count > 0)
            {
                await DispatchServicePrerequisitePendingReminderAsync(project, unstartedServices, 1);
            }
        }
    }

    public async Task StartServicePrerequisiteSlaWorkflowAsync(Guid projectId, Guid serviceId, CancellationToken ct = default)
    {
        var service = await db.ProjectServices
            .Include(s => s.Project)
            .FirstOrDefaultAsync(s => s.Id == serviceId && s.ProjectId == projectId && s.DeletedAtUtc == null, ct);

        if (service == null || service.IsReady) return;

        if (s_activeServiceL1Jobs.ContainsKey(serviceId)) return;

        DateTime l1DeadlineUtc;
        if (deadlineCalculator != null)
        {
            l1DeadlineUtc = deadlineCalculator.CalculateTargetDeadline(
                service.CreatedAtUtc != default ? service.CreatedAtUtc : DateTime.UtcNow,
                1080, // 2 working days (2 * 540 min) to EOD in IST
                SlaCalculationMode.EndOfDay,
                useBusinessTimeZone: true);
        }
        else
        {
            var ist = ResolveIstTimeZone();
            var nowIst = TimeZoneInfo.ConvertTimeFromUtc(service.CreatedAtUtc != default ? service.CreatedAtUtc : DateTime.UtcNow, ist);
            var targetIst = nowIst.Date.AddDays(2).AddHours(18);
            l1DeadlineUtc = TimeZoneInfo.ConvertTimeToUtc(targetIst, ist);
        }

        var delay = l1DeadlineUtc > DateTime.UtcNow ? l1DeadlineUtc - DateTime.UtcNow : TimeSpan.FromMinutes(1);

        var jobId = BackgroundJob.Schedule<IActionNotificationService>(
            s => s.ExecuteServicePrerequisiteL1EscalationJobAsync(projectId, serviceId),
            delay);
        s_activeServiceL1Jobs[serviceId] = jobId;
    }

    public Task CancelServicePrerequisiteSlaWorkflowAsync(Guid serviceId, CancellationToken ct = default)
    {
        if (s_activeServiceL1Jobs.TryRemove(serviceId, out var l1JobId))
        {
            try
            {
                BackgroundJob.Delete(l1JobId);
                logger?.LogInformation("Deleted Service Prerequisite L1 job {JobId} for service {ServiceId}.", l1JobId, serviceId);
            }
            catch (Exception ex)
            {
                logger?.LogWarning(ex, "Failed deleting Service Prerequisite L1 job {JobId} for service {ServiceId}.", l1JobId, serviceId);
            }
        }

        if (s_activeServiceL2Jobs.TryRemove(serviceId, out var l2JobId))
        {
            try
            {
                BackgroundJob.Delete(l2JobId);
                logger?.LogInformation("Deleted Service Prerequisite L2 job {JobId} for service {ServiceId}.", l2JobId, serviceId);
            }
            catch (Exception ex)
            {
                logger?.LogWarning(ex, "Failed deleting Service Prerequisite L2 job {JobId} for service {ServiceId}.", l2JobId, serviceId);
            }
        }

        return Task.CompletedTask;
    }

    [JobDisplayName("Service Prerequisite | 1st Level Breach Escalation | PM | {0} | {1}")]
    public async Task ExecuteServicePrerequisiteL1EscalationJobAsync(Guid projectId, Guid serviceId)
    {
        var service = await db.ProjectServices
            .Include(s => s.Project)
                .ThenInclude(p => p.Client)
            .FirstOrDefaultAsync(s => s.Id == serviceId && s.ProjectId == projectId && s.DeletedAtUtc == null);

        if (service?.Project == null || service.IsReady)
        {
            logger?.LogInformation("Service {ServiceId} in project {ProjectId} is already started, deleted, or missing project. Terminating L1 escalation.", serviceId, projectId);
            s_activeServiceL1Jobs.TryRemove(serviceId, out _);
            return;
        }

        var alreadySent = await db.ActionNotifications.AnyAsync(n =>
            n.ProjectId == projectId &&
            n.Type == "Service Prerequisite Escalation" &&
            n.HistoryJson.Contains(serviceId.ToString()) &&
            n.HistoryJson.Contains("\"level\":1") &&
            n.DeletedAtUtc == null);

        if (!alreadySent)
        {
            var pmRecipients = await ResolveAssignedProjectManagersAsync(service.Project);
            if (pmRecipients.Count > 0)
            {
                var title = $"1st Level Breach Escalation: Service Not Started | {service.ServiceName} | {service.Project.Name}";
                var details = $"1st level breach escalation: Service '{service.ServiceName}' in project '{service.Project.Name}' has not been started within 2 days from Service wise Prerequisite Tracking.";

                var addedList = new List<ActionNotification>();
                foreach (var pm in pmRecipients)
                {
                    var notif = new ActionNotification
                    {
                        Id = Guid.NewGuid(),
                        RecipientEmployeeId = pm.Id,
                        ProjectId = service.ProjectId,
                        ProjectCode = service.Project.ProjectCode,
                        ProjectName = service.Project.Name,
                        Title = title,
                        Type = "Service Prerequisite Escalation",
                        Priority = "High",
                        Status = "Escalated",
                        Unread = true,
                        RaisedByName = "System / SLA Engine",
                        RelatedTask = service.ServiceName,
                        CreatedAtUtc = DateTime.UtcNow,
                        HistoryJson = JsonSerializer.Serialize(new[]
                        {
                            new
                            {
                                status = "Escalated",
                                level = 1,
                                serviceId = service.Id.ToString(),
                                serviceName = service.ServiceName,
                                at = DateTime.UtcNow.ToString("o"),
                                details = details
                            }
                        })
                    };
                    db.ActionNotifications.Add(notif);
                    addedList.Add(notif);
                }

                await db.SaveChangesAsync();
                TrySyncNotificationsToOtherDatabase(addedList);
            }
        }

        s_activeServiceL1Jobs.TryRemove(serviceId, out _);

        // Schedule 2nd Level Escalation Job at next working day EOD
        DateTime l2DeadlineUtc;
        if (deadlineCalculator != null)
        {
            l2DeadlineUtc = deadlineCalculator.GetNextWorkingDayEndOfDayUtc(DateTime.UtcNow);
        }
        else
        {
            var ist = ResolveIstTimeZone();
            var nowIst = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, ist);
            var targetIst = nowIst.Date.AddDays(1).AddHours(18);
            l2DeadlineUtc = TimeZoneInfo.ConvertTimeToUtc(targetIst, ist);
        }

        var l2Delay = l2DeadlineUtc > DateTime.UtcNow ? l2DeadlineUtc - DateTime.UtcNow : TimeSpan.FromMinutes(1);

        var l2JobId = BackgroundJob.Schedule<IActionNotificationService>(
            s => s.ExecuteServicePrerequisiteL2EscalationJobAsync(projectId, serviceId),
            l2Delay);
        s_activeServiceL2Jobs[serviceId] = l2JobId;
    }

    [JobDisplayName("Service Prerequisite | 2nd Level Breach Escalation | HOD | {0} | {1}")]
    public async Task ExecuteServicePrerequisiteL2EscalationJobAsync(Guid projectId, Guid serviceId)
    {
        var service = await db.ProjectServices
            .Include(s => s.Project)
                .ThenInclude(p => p.Client)
            .FirstOrDefaultAsync(s => s.Id == serviceId && s.ProjectId == projectId && s.DeletedAtUtc == null);

        if (service?.Project == null || service.IsReady)
        {
            logger?.LogInformation("Service {ServiceId} in project {ProjectId} is already started, deleted, or missing project. Terminating L2 escalation.", serviceId, projectId);
            s_activeServiceL2Jobs.TryRemove(serviceId, out _);
            return;
        }

        var alreadySent = await db.ActionNotifications.AnyAsync(n =>
            n.ProjectId == projectId &&
            n.Type == "Service Prerequisite Escalation" &&
            n.HistoryJson.Contains(serviceId.ToString()) &&
            n.HistoryJson.Contains("\"level\":2") &&
            n.DeletedAtUtc == null);

        if (!alreadySent)
        {
            var hodIds = await ResolveServiceHodAsync(service, service.Project);
            if (hodIds.Count > 0)
            {
                var title = $"2nd Level Breach Escalation: Service Not Started | {service.ServiceName} | {service.Project.Name}";
                var details = $"2nd level breach escalation: Service '{service.ServiceName}' in project '{service.Project.Name}' remains not started after 1st level breach escalation.";

                var addedList = new List<ActionNotification>();
                foreach (var hodId in hodIds)
                {
                    var notif = new ActionNotification
                    {
                        Id = Guid.NewGuid(),
                        RecipientEmployeeId = hodId,
                        ProjectId = service.ProjectId,
                        ProjectCode = service.Project.ProjectCode,
                        ProjectName = service.Project.Name,
                        Title = title,
                        Type = "Service Prerequisite Escalation",
                        Priority = "Critical",
                        Status = "Escalated",
                        Unread = true,
                        RaisedByName = "System / SLA Engine",
                        RelatedTask = service.ServiceName,
                        CreatedAtUtc = DateTime.UtcNow,
                        HistoryJson = JsonSerializer.Serialize(new[]
                        {
                            new
                            {
                                status = "Escalated",
                                level = 2,
                                serviceId = service.Id.ToString(),
                                serviceName = service.ServiceName,
                                at = DateTime.UtcNow.ToString("o"),
                                details = details
                            }
                        })
                    };
                    db.ActionNotifications.Add(notif);
                    addedList.Add(notif);
                }

                await db.SaveChangesAsync();
                TrySyncNotificationsToOtherDatabase(addedList);
            }
        }

        s_activeServiceL2Jobs.TryRemove(serviceId, out _);
    }

    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolveServiceStartedRecipientsAsync(
        Project project, CancellationToken ct = default)
    {
        var recipients = new List<PMS.API.Modules.Resources.Models.Employee>();

        // 1. Assigned Project Manager
        var pmList = await ResolveAssignedProjectManagersAsync(project, ct);
        foreach (var pm in pmList)
        {
            if (!recipients.Any(r => r.Id == pm.Id)) recipients.Add(pm);
        }

        // 2. Assigned Senior Project Manager
        var spmList = await ResolveAssignedSeniorProjectManagersAsync(project, ct);
        foreach (var spm in spmList)
        {
            if (!recipients.Any(r => r.Id == spm.Id)) recipients.Add(spm);
        }

        // 3. Assigned Engagement Manager
        var emId = await ResolveEngagementManagerIdAsync(project, ct);
        if (emId.HasValue && !recipients.Any(r => r.Id == emId.Value))
        {
            var em = await db.Employees.FirstOrDefaultAsync(e => e.Id == emId.Value && e.DeletedAtUtc == null, ct);
            if (em != null) recipients.Add(em);
        }

        // 4. Assigned Team Lead
        var tlList = await ResolveAssignedTeamLeadsAsync(project, ct);
        foreach (var tl in tlList)
        {
            if (!recipients.Any(r => r.Id == tl.Id)) recipients.Add(tl);
        }

        return recipients;
    }

    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolveAssignedSeniorProjectManagersAsync(
        Project project, CancellationToken ct = default)
    {
        var spms = new List<PMS.API.Modules.Resources.Models.Employee>();

        var tmSpms = await db.ProjectTeamMembers
            .Include(m => m.Employee)
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null &&
                        (m.MemberRole == ProjectMemberRoles.SeniorProjectManager ||
                         m.MemberRole == "Senior Project Manager" ||
                         m.MemberRole.ToLower().Contains("senior project manager") ||
                         m.MemberRole.ToLower() == "spm" ||
                         m.MemberRole.ToLower() == "senior pm"))
            .ToListAsync(ct);

        foreach (var tm in tmSpms)
        {
            if (tm.Employee != null && tm.Employee.DeletedAtUtc == null && !spms.Any(p => p.Id == tm.Employee.Id))
            {
                spms.Add(tm.Employee);
            }
        }

        return spms;
    }

    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolvePmoEmployeesAsync(CancellationToken ct = default)
    {
        var key = "pmo (project management office)";
        var pmoList = await db.Employees
            .AsNoTracking()
            .Include(e => e.SubDepartmentRef)
            .Include(e => e.Department)
            .Where(e => e.DeletedAtUtc == null &&
                        (e.Status == null || e.Status.ToLower().StartsWith("active")) &&
                        ((e.SubDepartment != null && e.SubDepartment.Trim().ToLower() == key) ||
                         (e.SubDepartmentRef != null && e.SubDepartmentRef.Name.Trim().ToLower() == key) ||
                         (e.SubDepartment != null && e.SubDepartment.Trim().ToLower() == "pmo") ||
                         (e.SubDepartmentRef != null && e.SubDepartmentRef.Name.Trim().ToLower() == "pmo") ||
                         (e.Role != null && e.Role.Trim().ToLower() == "pmo") ||
                         (e.Department != null && e.Department.Name.Trim().ToLower() == "pmo")))
            .ToListAsync(ct);

        return pmoList;
    }

    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolveAssignedProjectManagersAsync(
        Project project, CancellationToken ct = default)
    {
        var pms = new List<PMS.API.Modules.Resources.Models.Employee>();

        if (project.ProjectManager != null && !pms.Any(p => p.Id == project.ProjectManager.Id))
        {
            pms.Add(project.ProjectManager);
        }

        if (project.ProjectManagerId.HasValue && !pms.Any(p => p.Id == project.ProjectManagerId.Value))
        {
            var pm = await db.Employees.FirstOrDefaultAsync(e => e.Id == project.ProjectManagerId.Value && e.DeletedAtUtc == null, ct);
            if (pm != null && !pms.Any(p => p.Id == pm.Id)) pms.Add(pm);
        }

        var tmPms = await db.ProjectTeamMembers
            .Include(m => m.Employee)
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null &&
                        (m.MemberRole == ProjectMemberRoles.ProjectManager ||
                         m.MemberRole.ToLower().Contains("project manager") ||
                         m.MemberRole.ToLower() == "pm"))
            .ToListAsync(ct);

        foreach (var tm in tmPms)
        {
            if (tm.Employee != null && tm.Employee.DeletedAtUtc == null && !pms.Any(p => p.Id == tm.Employee.Id))
            {
                pms.Add(tm.Employee);
            }
        }

        return pms;
    }

    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolveAssignedTeamLeadsAsync(
        Project project, CancellationToken ct = default)
    {
        var tls = new List<PMS.API.Modules.Resources.Models.Employee>();

        if (project.TeamLead != null && !tls.Any(t => t.Id == project.TeamLead.Id))
        {
            tls.Add(project.TeamLead);
        }

        if (project.TeamLeadId.HasValue && !tls.Any(t => t.Id == project.TeamLeadId.Value))
        {
            var tl = await db.Employees.FirstOrDefaultAsync(e => e.Id == project.TeamLeadId.Value && e.DeletedAtUtc == null, ct);
            if (tl != null && !tls.Any(t => t.Id == tl.Id)) tls.Add(tl);
        }

        var tmTls = await db.ProjectTeamMembers
            .Include(m => m.Employee)
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null &&
                        (m.IsTeamLead ||
                         m.MemberRole == "TeamLead" ||
                         m.MemberRole == "Team Lead" ||
                         m.MemberRole == "Team Leader" ||
                         m.MemberRole.ToLower().Contains("team lead") ||
                         m.MemberRole.ToLower().Contains("team leader") ||
                         m.MemberRole.ToLower() == "tl"))
            .ToListAsync(ct);

        foreach (var tm in tmTls)
        {
            if (tm.Employee != null && tm.Employee.DeletedAtUtc == null && !tls.Any(t => t.Id == tm.Employee.Id))
            {
                tls.Add(tm.Employee);
            }
        }

        return tls;
    }

    private async Task<List<Guid>> ResolveServiceHodAsync(
        ProjectServiceEntity service, Project project, CancellationToken ct = default)
    {
        var hodIds = new List<Guid>();

        Guid? serviceDeptId = null;
        if (service.ServiceCatalog?.SubDepartment != null && service.ServiceCatalog.SubDepartment.DepartmentId != Guid.Empty)
        {
            serviceDeptId = service.ServiceCatalog.SubDepartment.DepartmentId;
        }
        else if (!string.IsNullOrWhiteSpace(service.Department))
        {
            var dept = await db.Departments.FirstOrDefaultAsync(d => d.Name.ToLower() == service.Department.ToLower() && d.DeletedAtUtc == null, ct);
            if (dept != null) serviceDeptId = dept.Id;
        }

        var hodRoles = await db.OnFloorRoles
            .AsNoTracking()
            .Where(o => o.DeletedAtUtc == null && (
                o.Name.ToLower() == "head of department" ||
                o.Name.ToLower() == "hod" ||
                o.Name.ToLower().Contains("head of department")
            ))
            .ToListAsync(ct);

        var hodDesigIds = hodRoles.Select(o => o.DesignationId).Distinct().ToList();

        var candidates = await db.Employees
            .AsNoTracking()
            .Include(e => e.Department)
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null &&
                        (e.Status == null || !e.Status.ToLower().StartsWith("inactive")))
            .Where(e => e.DesignationId.HasValue && hodDesigIds.Contains(e.DesignationId.Value))
            .ToListAsync(ct);

        candidates = candidates.Where(c =>
        {
            var rLower = (c.Role ?? "").ToLowerInvariant();
            return !rLower.Contains("team leader") && !rLower.Contains("team lead");
        }).ToList();

        if (serviceDeptId.HasValue || !string.IsNullOrWhiteSpace(service.SubDepartment))
        {
            foreach (var c in candidates)
            {
                bool deptMatch = serviceDeptId.HasValue && c.DepartmentId == serviceDeptId.Value;
                bool subDeptMatch = !string.IsNullOrWhiteSpace(service.SubDepartment) &&
                    ((c.SubDepartment != null && c.SubDepartment.Equals(service.SubDepartment, StringComparison.OrdinalIgnoreCase)) ||
                     (c.SubDepartmentRef != null && c.SubDepartmentRef.Name.Equals(service.SubDepartment, StringComparison.OrdinalIgnoreCase)));

                if (deptMatch || subDeptMatch)
                {
                    hodIds.Add(c.Id);
                }
            }
        }

        if (hodIds.Count == 0)
        {
            var projectHodIds = await ResolveProjectHodAsync(project, ct);
            hodIds.AddRange(projectHodIds);
        }

        if (hodIds.Count == 0 && candidates.Count > 0)
        {
            hodIds.AddRange(candidates.Select(c => c.Id));
        }

        return hodIds.Distinct().ToList();
    }

    public async Task NotifyServiceEditedAsync(
        Guid projectId,
        string serviceName,
        string action,
        string? details = null,
        string? performerName = null,
        CancellationToken ct = default)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .Include(p => p.EngagementManagerRef)
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct);

        if (project == null)
        {
            logger?.LogWarning("Project {ProjectId} not found or deleted. Service edit notification cannot be dispatched.", projectId);
            return;
        }

        var recipients = new List<PMS.API.Modules.Resources.Models.Employee>();

        // 1. Assigned Engagement Manager(s)
        var emRecipients = await ResolveProjectEngagementManagersAsync(project, ct);
        foreach (var em in emRecipients)
        {
            if (!recipients.Any(r => r.Id == em.Id)) recipients.Add(em);
        }

        // 2. PMO (Project Management Office)
        var pmoList = await ResolvePmoEmployeesAsync(ct);
        foreach (var pmo in pmoList)
        {
            if (!recipients.Any(r => r.Id == pmo.Id)) recipients.Add(pmo);
        }

        if (recipients.Count == 0)
        {
            logger?.LogWarning("No Engagement Manager or PMO resolved for project {ProjectId} ('{ProjectName}'). Service edit notification cannot be dispatched.", projectId, project.Name);
            return;
        }

        var act = (action ?? "modify").Trim().ToLowerInvariant();
        string actionWord;
        string notifType;
        if (act.Contains("del"))
        {
            actionWord = "deleted";
            notifType = "Service Deleted";
        }
        else if (act.Contains("add"))
        {
            actionWord = "added";
            notifType = "Service Added";
        }
        else
        {
            actionWord = "modify";
            notifType = "Service Modified";
        }

        var title = $"The {project.Name} service is {actionWord}";
        var meaningfulDetails = !string.IsNullOrWhiteSpace(details)
            ? details
            : (actionWord == "deleted"
                ? $"Service '{serviceName}' was deleted from project '{project.Name}'."
                : (actionWord == "added"
                    ? $"Service '{serviceName}' was added to project '{project.Name}'."
                    : $"Service '{serviceName}' was modified in project '{project.Name}'."));

        var now = DateTime.UtcNow;
        var dateStr = now.ToString("yyyy-MM-dd");
        var timeStr = now.ToString("HH:mm:ss");
        var byUser = performerName ?? currentUser.Name ?? "System";

        var addedList = new List<ActionNotification>();
        foreach (var recipient in recipients)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipient.Id,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = title,
                Type = notifType,
                Priority = "Medium",
                Status = "Pending",
                Unread = true,
                RaisedByName = byUser,
                RelatedTask = serviceName,
                CreatedAtUtc = now,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = actionWord,
                        action = meaningfulDetails,
                        serviceName = serviceName,
                        at = now.ToString("o"),
                        date = dateStr,
                        time = timeStr,
                        by = byUser,
                        details = meaningfulDetails
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    public Task NotifyServiceModifiedAsync(Guid projectId, string serviceName, string? details = null, string? performerName = null, CancellationToken ct = default)
        => NotifyServiceEditedAsync(projectId, serviceName, "modify", details, performerName, ct);

    public Task NotifyServiceDeletedAsync(Guid projectId, string serviceName, string? performerName = null, CancellationToken ct = default)
        => NotifyServiceEditedAsync(projectId, serviceName, "deleted", $"Service '{serviceName}' was deleted from project.", performerName, ct);

    public Task NotifyServiceAddedAsync(Guid projectId, string serviceName, string? details = null, string? performerName = null, CancellationToken ct = default)
        => NotifyServiceEditedAsync(projectId, serviceName, "added", details, performerName, ct);

    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolveProjectEngagementManagersAsync(
        Project project, CancellationToken ct = default)
    {
        var ems = new List<PMS.API.Modules.Resources.Models.Employee>();

        if (project.EngagementManagerRef != null && project.EngagementManagerRef.DeletedAtUtc == null)
        {
            ems.Add(project.EngagementManagerRef);
        }

        if (project.EngagementManagerId.HasValue && project.EngagementManagerId.Value != Guid.Empty && !ems.Any(e => e.Id == project.EngagementManagerId.Value))
        {
            var emp = await db.Employees.FirstOrDefaultAsync(e => e.Id == project.EngagementManagerId.Value && e.DeletedAtUtc == null, ct);
            if (emp != null) ems.Add(emp);
        }

        if (project.Client?.EngagementManagerId.HasValue == true && project.Client.EngagementManagerId.Value != Guid.Empty && !ems.Any(e => e.Id == project.Client.EngagementManagerId.Value))
        {
            var emp = await db.Employees.FirstOrDefaultAsync(e => e.Id == project.Client.EngagementManagerId.Value && e.DeletedAtUtc == null, ct);
            if (emp != null) ems.Add(emp);
        }

        var tmEms = await db.ProjectTeamMembers
            .Include(m => m.Employee)
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null &&
                        (m.MemberRole.ToLower().Contains("engagement") || m.MemberRole.ToLower() == "em"))
            .ToListAsync(ct);

        foreach (var tm in tmEms)
        {
            if (tm.Employee != null && tm.Employee.DeletedAtUtc == null && !ems.Any(e => e.Id == tm.Employee.Id))
            {
                ems.Add(tm.Employee);
            }
        }

        if (ems.Count == 0)
        {
            var emName = !string.IsNullOrWhiteSpace(project.EngagementManager)
                ? project.EngagementManager
                : project.Client?.EngagementManager;

            if (!string.IsNullOrWhiteSpace(emName))
            {
                var trimmed = emName.Trim().ToLower();
                var emp = await db.Employees.FirstOrDefaultAsync(e =>
                    e.DeletedAtUtc == null &&
                    ((e.FirstName + " " + e.LastName).Trim().ToLower() == trimmed ||
                     (e.WorkEmail != null && e.WorkEmail.ToLower() == trimmed) ||
                     (e.PersonalEmail != null && e.PersonalEmail.ToLower() == trimmed)), ct);
                if (emp != null && !ems.Any(p => p.Id == emp.Id)) ems.Add(emp);
            }
        }

        return ems;
    }

    private async Task<List<PMS.API.Modules.Resources.Models.Employee>> ResolveProjectSalesPersonsAsync(
        Project? project, CancellationToken ct = default)
    {
        var sales = new List<PMS.API.Modules.Resources.Models.Employee>();

        if (project != null)
        {
            // 1. Direct project.SalesPersonRef
            if (project.SalesPersonRef != null && project.SalesPersonRef.DeletedAtUtc == null)
            {
                sales.Add(project.SalesPersonRef);
            }

            // 2. Direct project.SalesPersonId
            if (project.SalesPersonId.HasValue && project.SalesPersonId.Value != Guid.Empty && !sales.Any(e => e.Id == project.SalesPersonId.Value))
            {
                var emp = await db.Employees.FirstOrDefaultAsync(e => e.Id == project.SalesPersonId.Value && e.DeletedAtUtc == null, ct);
                if (emp != null) sales.Add(emp);
            }

            // 3. Client.SalesManagerRef
            if (project.Client?.SalesManagerRef != null && project.Client.SalesManagerRef.DeletedAtUtc == null && !sales.Any(e => e.Id == project.Client.SalesManagerRef.Id))
            {
                sales.Add(project.Client.SalesManagerRef);
            }

            // 4. Client.SalesManagerId
            if (project.Client?.SalesManagerId.HasValue == true && project.Client.SalesManagerId.Value != Guid.Empty && !sales.Any(e => e.Id == project.Client.SalesManagerId.Value))
            {
                var emp = await db.Employees.FirstOrDefaultAsync(e => e.Id == project.Client.SalesManagerId.Value && e.DeletedAtUtc == null, ct);
                if (emp != null) sales.Add(emp);
            }

            // 5. ProjectTeamMembers with sales role
            var tmSales = await db.ProjectTeamMembers
                .Include(m => m.Employee)
                .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null &&
                            (m.MemberRole.ToLower().Contains("sales") || m.MemberRole.ToLower().Contains("sale")))
                .ToListAsync(ct);

            foreach (var tm in tmSales)
            {
                if (tm.Employee != null && tm.Employee.DeletedAtUtc == null && !sales.Any(e => e.Id == tm.Employee.Id))
                {
                    sales.Add(tm.Employee);
                }
            }

            // 6. Name match on project.SalesPerson or Client.SalesManager
            var salesName = !string.IsNullOrWhiteSpace(project.SalesPerson)
                ? project.SalesPerson
                : project.Client?.SalesManager;

            if (!string.IsNullOrWhiteSpace(salesName))
            {
                var trimmed = salesName.Trim().ToLower();
                var emp = await db.Employees.FirstOrDefaultAsync(e =>
                    e.DeletedAtUtc == null &&
                    ((e.FirstName + " " + e.LastName).Trim().ToLower() == trimmed ||
                     (e.WorkEmail != null && e.WorkEmail.ToLower() == trimmed) ||
                     (e.PersonalEmail != null && e.PersonalEmail.ToLower() == trimmed)), ct);
                if (emp != null && !sales.Any(p => p.Id == emp.Id)) sales.Add(emp);
            }
        }

        // 7. Fallback if no specific sales person is assigned on project or customer:
        // include active employees whose Role is Sales Manager or Sales Person or SubDepartment contains Sales
        if (sales.Count == 0)
        {
            var generalSales = await db.Employees
                .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")) &&
                            ((e.Role != null && (e.Role.ToLower().Contains("sales manager") || e.Role.ToLower().Contains("sales person"))) ||
                             (e.SubDepartment != null && e.SubDepartment.ToLower().Contains("sales"))))
                .ToListAsync(ct);

            foreach (var s in generalSales)
            {
                if (!sales.Any(e => e.Id == s.Id)) sales.Add(s);
            }
        }

        return sales;
    }

    public async Task NotifyProjectTaskLifecycleAsync(
        Guid projectId,
        Guid taskId,
        string taskTitle,
        string? serviceName,
        string action,
        string? performerName = null,
        Guid? performerEmployeeId = null,
        CancellationToken ct = default)
    {
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct);

        if (project == null)
        {
            logger?.LogWarning("Project {ProjectId} not found or deleted. Task lifecycle notification cannot be dispatched.", projectId);
            return;
        }

        // 1. Resolve actual Service Name if missing or general
        if (string.IsNullOrWhiteSpace(serviceName) || serviceName.Equals("General", StringComparison.OrdinalIgnoreCase))
        {
            var task = await db.ProjectTasks
                .Include(t => t.ProjectService)
                .FirstOrDefaultAsync(t => t.Id == taskId, ct);
            if (task?.ProjectService != null)
            {
                serviceName = task.ProjectService.ServiceName;
            }
            else
            {
                var firstService = await db.ProjectServices
                    .Where(s => s.ProjectId == projectId && s.DeletedAtUtc == null)
                    .OrderBy(s => s.SortOrder)
                    .FirstOrDefaultAsync(ct);
                serviceName = firstService?.ServiceName?.Trim() ?? "General";
            }
        }
        if (string.IsNullOrWhiteSpace(serviceName)) serviceName = "General";

        // 2. Resolve performer resource name
        string resourceName = performerName ?? "";
        if (string.IsNullOrWhiteSpace(resourceName) && performerEmployeeId.HasValue)
        {
            var emp = await db.Employees.FirstOrDefaultAsync(e => e.Id == performerEmployeeId.Value && e.DeletedAtUtc == null, ct);
            if (emp != null)
            {
                resourceName = $"{emp.FirstName} {emp.LastName}".Trim();
            }
        }
        if (string.IsNullOrWhiteSpace(resourceName))
        {
            resourceName = currentUser.Name ?? "Assigned Resource";
        }

        // 3. Format Title, Type, and Content according to user specification
        var act = (action ?? "").Trim().ToLowerInvariant();
        string title;
        string notifType;
        string content;

        if (act.Contains("pause"))
        {
            title = $"{project.Name} : {taskTitle} of {serviceName} is paused by {resourceName}";
            notifType = "Task Paused";
            content = $"{resourceName} has paused the task '{taskTitle}' under the service '{serviceName}' in project '{project.Name}'.";
        }
        else if (act.Contains("resume") || act.Contains("start"))
        {
            title = $"{project.Name} : {taskTitle} of {serviceName} is resume by {resourceName}";
            notifType = "Task Resumed";
            content = $"{resourceName} has resumed the task '{taskTitle}' under the service '{serviceName}' in project '{project.Name}'.";
        }
        else if (act.Contains("stop"))
        {
            title = $"{project.Name} : {taskTitle} of {serviceName} is stop by {resourceName}";
            notifType = "Task Stopped";
            content = $"{resourceName} has stopped the task '{taskTitle}' under the service '{serviceName}' in project '{project.Name}'.";
        }
        else if (act.Contains("complete"))
        {
            title = $"{project.Name} : {taskTitle} of {serviceName} is completed";
            notifType = "Task Completed";
            content = $"Task '{taskTitle}' under the service '{serviceName}' in project '{project.Name}' is completed.";
        }
        else
        {
            title = $"{project.Name} : {taskTitle} of {serviceName} is {action}";
            notifType = "Task Updated";
            content = $"Task '{taskTitle}' in project '{project.Name}' is {action}.";
        }

        // 4. Resolve Leadership Recipients: Assigned Project Manager, Assigned Engagement Manager, Project Team Leader
        var recipientIds = new HashSet<Guid>();
        if (slaRecipientResolver != null)
        {
            var resolved = await slaRecipientResolver.ResolveLeadershipRecipientsAsync(
                projectId,
                ["Assigned Engagement Manager", "Assigned Project Manager", "Project Team Leader"],
                ct);
            foreach (var id in resolved) recipientIds.Add(id);
        }

        if (project.ProjectManagerId.HasValue && project.ProjectManagerId.Value != Guid.Empty)
            recipientIds.Add(project.ProjectManagerId.Value);

        if (project.TeamLeadId.HasValue && project.TeamLeadId.Value != Guid.Empty)
            recipientIds.Add(project.TeamLeadId.Value);

        var emId = project.EngagementManagerId ?? project.Client?.EngagementManagerId;
        if (emId.HasValue && emId.Value != Guid.Empty)
            recipientIds.Add(emId.Value);

        var tmLeaders = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(m => m.ProjectId == projectId && m.DeletedAtUtc == null &&
                        (m.IsTeamLead ||
                         m.MemberRole.ToLower().Contains("manager") ||
                         m.MemberRole.ToLower().Contains("lead") ||
                         m.MemberRole.ToLower() == "pm" ||
                         m.MemberRole.ToLower() == "em" ||
                         m.MemberRole.ToLower() == "tl"))
            .Select(m => m.EmployeeId)
            .ToListAsync(ct);

        foreach (var id in tmLeaders) recipientIds.Add(id);

        if (recipientIds.Count == 0)
        {
            logger?.LogWarning("No leadership recipients (PM, EM, TL) resolved for project {ProjectId} ('{ProjectName}'). Task notification cannot be dispatched.", projectId, project.Name);
            return;
        }

        var nowUtc = DateTime.UtcNow;
        var dateStr = nowUtc.ToString("yyyy-MM-dd");
        var timeStr = nowUtc.ToString("HH:mm:ss");

        var addedList = new List<ActionNotification>();
        foreach (var recId in recipientIds)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recId,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = title,
                Type = notifType,
                Priority = "Medium",
                Status = "Pending",
                Unread = true,
                RelatedTask = taskTitle,
                RaisedByName = resourceName,
                RaisedByEmployeeId = performerEmployeeId,
                CreatedAtUtc = nowUtc,
                CommentsJson = JsonSerializer.Serialize(new[]
                {
                    new { text = content, by = resourceName, at = nowUtc.ToString("o") }
                }, JsonOptions),
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        action = title,
                        date = dateStr,
                        time = timeStr,
                        by = resourceName,
                        details = content,
                        at = nowUtc.ToString("o")
                    }
                }, JsonOptions)
            };
            db.ActionNotifications.Add(notif);
            addedList.Add(notif);
        }

        await db.SaveChangesAsync(ct);
        TrySyncNotificationsToOtherDatabase(addedList);
    }

    [JobDisplayName("Dedicated Allocation | 2-Day Daily EOD Reminder | PMO")]
    public async Task ExecuteDedicatedAllocationPmoDailyEodCheckAsync()
    {
        var twoDaysAgo = DateTime.UtcNow.AddDays(-2);
        var pendingRequests = await db.ProjectResourceAllocationRequests
            .Include(r => r.Project)
            .Include(r => r.Employee)
            .Where(r => r.DeletedAtUtc == null &&
                        r.Status == "Pending" &&
                        (r.ResourceType == "Dedicated" || r.RequiresPmoApproval) &&
                        r.CreatedAtUtc <= twoDaysAgo)
            .ToListAsync();

        if (pendingRequests.Count == 0) return;

        var pmoEmployees = await db.Employees
            .AsNoTracking()
            .Where(e => e.DeletedAtUtc == null &&
                ((e.Role != null && e.Role.Contains("PMO")) ||
                 (e.SubDepartment != null && e.SubDepartment.ToLower().Contains("pmo")) ||
                 e.Role == "Admin"))
            .ToListAsync();

        var pmoUsers = await db.Users
            .Include(u => u.Role)
            .Where(u => u.IsActive && u.Role != null && u.Role.Name.ToUpper() == "PMO")
            .ToListAsync();

        var pmoIds = new HashSet<Guid>(pmoEmployees.Select(e => e.Id));
        foreach (var u in pmoUsers)
        {
            if (Guid.TryParse(u.EmployeeId, out var empGuid))
            {
                pmoIds.Add(empGuid);
            }
        }

        if (pmoIds.Count == 0) return;

        var todayUtc = DateTime.UtcNow.Date;
        var addedNotifs = new List<ActionNotification>();

        foreach (var req in pendingRequests)
        {
            var allocTaskCode = $"ALLOC-{req.Id.ToString()[..8].ToUpper()}";

            var alreadySentToday = await db.ActionNotifications.AnyAsync(n =>
                n.RelatedTask == allocTaskCode &&
                n.Type == "PMO Allocation Reminder" &&
                n.CreatedAtUtc >= todayUtc &&
                n.DeletedAtUtc == null);

            if (alreadySentToday) continue;

            var candidateName = req.Employee != null ? $"{req.Employee.FirstName} {req.Employee.LastName}".Trim() : "Resource";
            var projectName = req.Project?.Name ?? "Project";
            var title = $"{projectName}: Dedicated Resource Allocation Request for {candidateName} is pending PMO approval";

            foreach (var pmoId in pmoIds)
            {
                var notif = new ActionNotification
                {
                    Id = Guid.NewGuid(),
                    RecipientEmployeeId = pmoId,
                    ProjectId = req.ProjectId,
                    ProjectCode = req.Project?.ProjectCode,
                    ProjectName = projectName,
                    Title = title,
                    Type = "PMO Allocation Reminder",
                    Priority = "High",
                    Status = "Pending",
                    Unread = true,
                    RaisedByName = "System Reminder",
                    RelatedTask = allocTaskCode,
                    HistoryJson = JsonSerializer.Serialize(new[]
                    {
                        new
                        {
                            action = "Reminder: Dedicated resource allocation request has been pending for over 2 days without decision.",
                            date = DateTime.UtcNow.ToString("yyyy-MM-dd"),
                            time = DateTime.UtcNow.ToString("HH:mm:ss"),
                            by = "System Reminder",
                            status = "Pending",
                            at = DateTime.UtcNow.ToString("o")
                        }
                    }, JsonOptions)
                };

                db.ActionNotifications.Add(notif);
                addedNotifs.Add(notif);
            }
        }

        if (addedNotifs.Count > 0)
        {
            await db.SaveChangesAsync();
            TrySyncNotificationsToOtherDatabase(addedNotifs);
        }
    }

    #endregion
}

