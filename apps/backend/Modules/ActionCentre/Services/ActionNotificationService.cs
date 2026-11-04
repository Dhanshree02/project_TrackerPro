using System.Text.Json;

using Microsoft.EntityFrameworkCore;

using PMS.API.Infrastructure.Authorization;

using PMS.API.Infrastructure.Persistence;

using PMS.API.Infrastructure.Storage;

using PMS.API.Modules.ActionCentre.DTOs;

using PMS.API.Modules.ActionCentre.Models;

using PMS.API.Modules.Projects.Models;

using PMS.API.Shared.Exceptions;



namespace PMS.API.Modules.ActionCentre.Services;



public sealed class ActionNotificationService(

    AppDbContext db,

    ICurrentUserService currentUser,

    IFileStorageService storage) : IActionNotificationService

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



        if (notification.Type == "WBS Escalation")

        {

            var openEscalations = await db.ProjectServiceEscalations

                .Include(e => e.Stakeholders)

                .Where(e => e.ProjectId == notification.ProjectId && e.Status == "Open")

                .ToListAsync(ct);



            foreach (var esc in openEscalations)

            {

                if (!string.IsNullOrWhiteSpace(notification.RelatedTask) &&

                    !string.Equals(esc.ServiceName, notification.RelatedTask, StringComparison.OrdinalIgnoreCase))

                {

                    continue;

                }



                var matchStakeholder = esc.Stakeholders

                    .FirstOrDefault(s => s.EmployeeId == notification.RecipientEmployeeId);



                if (matchStakeholder != null)

                {

                    matchStakeholder.Status = "Acknowledged";

                    matchStakeholder.UpdatedAtUtc = now;

                }



                if (esc.Stakeholders.Count > 0 && esc.Stakeholders.All(s => s.Status == "Acknowledged"))

                {

                    esc.Status = "Acknowledged";

                    esc.UpdatedAtUtc = now;

                }

            }



            var wbsAlerts = await db.ProjectAlerts

                .Where(a => a.ProjectId == notification.ProjectId &&

                            a.AlertType == "WBS Escalation" &&

                            a.Status == "Open" &&

                            a.DeletedAtUtc == null)

                .ToListAsync(ct);



            foreach (var wbsAlert in wbsAlerts)

            {

                if (!string.IsNullOrWhiteSpace(notification.RelatedTask) &&

                    !wbsAlert.Title.Contains(notification.RelatedTask, StringComparison.OrdinalIgnoreCase))

                {

                    continue;

                }



                wbsAlert.Status = "Acknowledged";

                wbsAlert.StatusChangedBy = userName;

                wbsAlert.StatusChangedAtUtc = now;

                wbsAlert.UpdatedAtUtc = now;



                var alertHist = ParseHistory(wbsAlert.HistoryJson);

                alertHist.Add(new NotificationHistoryItemDto

                {

                    Action = "Status transitioned to Acknowledged via Action Center notification",

                    Date = dateStr,

                    Time = timeStr,

                    By = userName

                });

                wbsAlert.HistoryJson = JsonSerializer.Serialize(alertHist);

            }

        }

        else if (notification.IssueId != null)

        {

            var linkedAlerts = await db.ProjectAlerts

                .Where(a => a.IssueId == notification.IssueId && a.Status == "Open" && a.DeletedAtUtc == null)

                .ToListAsync(ct);



            foreach (var linkedAlert in linkedAlerts)

            {

                linkedAlert.Status = "Acknowledged";

                linkedAlert.StatusChangedBy = userName;

                linkedAlert.StatusChangedAtUtc = now;

                linkedAlert.UpdatedAtUtc = now;



                var alertHist = ParseHistory(linkedAlert.HistoryJson);

                alertHist.Add(new NotificationHistoryItemDto

                {

                    Action = "Status transitioned to Acknowledged via Action Center notification",

                    Date = dateStr,

                    Time = timeStr,

                    By = userName

                });

                linkedAlert.HistoryJson = JsonSerializer.Serialize(alertHist);

            }

        }



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



        // Backfill any escalation details if not directly present on older project alert records

        var wbsAlerts = rows.Where(r => r.AlertType == "WBS Escalation" && (r.AttachmentFileName == null || r.ExpectedResolutionDate == null)).ToList();

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



        return rows.Select(MapAlertDto).ToList();

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



        if (string.IsNullOrWhiteSpace(path) && alert.AlertType == "WBS Escalation")

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

                    By = userName

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

            Kind = a.AlertType == "WBS Escalation" ? "Escalation" : "Alert",

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

            StatusChangedBy = a.StatusChangedBy,

            StatusChangedAtUtc = a.StatusChangedAtUtc,

            History = ParseHistory(a.HistoryJson),

            Comments = ParseComments(a.ChatJson),

            ServiceName = a.ServiceName,

            EscalationType = a.EscalationType,

            ExpectedResolutionDate = a.ExpectedResolutionDate,

            EscalatedTo = escalatedTo.Count > 0 ? escalatedTo : audience,

            Attachments = attachments,

            AttachmentUrl = !string.IsNullOrWhiteSpace(a.AttachmentFileName) ? $"/api/v1/action-centre/alerts/{a.Id}/attachment" : null

        };

    }



    public async Task NotifyCustomerOnboardedAsync(

        Guid clientId,

        string clientName,

        string? clientCode,

        string? createdByName,

        CancellationToken ct = default)

    {

        // Criteria: Resources whose Sub-Department are `EM (Engagement Manager)`

        // AND whose On Floor Role are `Head Of Department`, `Leader`

        var emKey = "em (engagement manager)";

        var candidates = await db.Employees

            .Include(e => e.SubDepartmentRef)

            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))

            .Where(e => (e.SubDepartment != null && e.SubDepartment.Trim().ToLower() == emKey)

                     || (e.SubDepartmentRef != null && e.SubDepartmentRef.Name.Trim().ToLower() == emKey))

            .ToListAsync(ct);



        if (candidates.Count == 0) return;



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

            string roleName = string.Empty;

            if (e.DesignationId.HasValue && floorRoles.TryGetValue(e.DesignationId.Value, out var mappedRole))

            {

                roleName = mappedRole;

            }

            else if (!string.IsNullOrWhiteSpace(e.Role))

            {

                roleName = e.Role;

            }



            string rLower = roleName.Trim().ToLowerInvariant();

            // Strictly Head Of Department or Leader (explicitly excludes Team Leader)
            if (!rLower.Contains("team leader") && (rLower == "head of department" || rLower == "leader" || rLower.Contains("hod")))

            {

                recipients.Add(e);

            }

        }



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

                Priority = "High",

                Status = "Pending",

                Unread = true,

                RaisedByName = createdByName ?? currentUser.Name ?? "System",

                RelatedTask = clientCode ?? clientName,

                CreatedAtUtc = DateTime.UtcNow,

                HistoryJson = JsonSerializer.Serialize(new[]

                {

                    new

                    {

                        status = "Pending",

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



    public async Task NotifyWbsCreatedAsync(

        Guid projectId,

        string projectName,

        string? wbsId,

        string? projectCode,

        string? createdByName,

        CancellationToken ct = default)

    {

        // Criteria: Resources whose Sub-Department are `EM (Engagement Manager)`, `PMO (Project Management Office)`

        // AND whose On Floor Role are `Head Of Department`

        var targetSubDepts = new[] { "em (engagement manager)", "pmo (project management office)" };

        var candidates = await db.Employees

            .Include(e => e.SubDepartmentRef)

            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))

            .Where(e => (e.SubDepartment != null && targetSubDepts.Contains(e.SubDepartment.Trim().ToLower()))

                     || (e.SubDepartmentRef != null && targetSubDepts.Contains(e.SubDepartmentRef.Name.Trim().ToLower())))

            .ToListAsync(ct);



        if (candidates.Count == 0) return;



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

            string roleName = string.Empty;

            if (e.DesignationId.HasValue && floorRoles.TryGetValue(e.DesignationId.Value, out var mappedRole))

            {

                roleName = mappedRole;

            }

            else if (!string.IsNullOrWhiteSpace(e.Role))

            {

                roleName = e.Role;

            }



            string rLower = roleName.Trim().ToLowerInvariant();

            if (rLower == "head of department" || rLower.Contains("head of department") || rLower.Contains("hod"))

            {

                recipients.Add(e);

            }

        }



        if (recipients.Count == 0) return;



        var title = $"WBS Created: {projectName} ({wbsId ?? projectCode})";

        var addedList = new List<ActionNotification>();

        foreach (var recipient in recipients)

        {

            var notif = new ActionNotification

            {

                Id = Guid.NewGuid(),

                RecipientEmployeeId = recipient.Id,

                ProjectId = projectId,

                ProjectCode = projectCode,

                ProjectName = projectName,

                Title = title,

                Type = "WBS Created",

                Priority = "High",

                Status = "Pending",

                Unread = true,

                RaisedByName = createdByName ?? currentUser.Name ?? "System",

                RelatedTask = wbsId ?? projectCode,

                CreatedAtUtc = DateTime.UtcNow,

                HistoryJson = JsonSerializer.Serialize(new[]

                {

                    new

                    {

                        status = "Pending",

                        at = DateTime.UtcNow.ToString("o"),

                        details = $"WBS created for project '{projectName}' with ID {wbsId ?? projectCode}."

                    }

                })

            };

            db.ActionNotifications.Add(notif);

            addedList.Add(notif);

        }



        await db.SaveChangesAsync(ct);

        TrySyncNotificationsToOtherDatabase(addedList);

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

        // 2. Resources whose Sub-Department are `EM (Engagement Manager)`, `PMO (Project Management Office)`

        //    AND whose Resource On Floor Role are `Sr. Manager`, `Manager`

        var recipients = new List<PMS.API.Modules.Resources.Models.Employee>();



        if (reportingManagerId.HasValue)

        {

            var mgr = await db.Employees.FirstOrDefaultAsync(e => e.Id == reportingManagerId.Value && e.DeletedAtUtc == null, ct);

            if (mgr != null)

            {

                recipients.Add(mgr);

            }

        }



        var targetSubDepts = new[] { "em (engagement manager)", "pmo (project management office)" };

        var candidates = await db.Employees

            .Include(e => e.SubDepartmentRef)

            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))

            .Where(e => (e.SubDepartment != null && targetSubDepts.Contains(e.SubDepartment.Trim().ToLower()))

                     || (e.SubDepartmentRef != null && targetSubDepts.Contains(e.SubDepartmentRef.Name.Trim().ToLower())))

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

                string roleName = string.Empty;

                if (e.DesignationId.HasValue && floorRoles.TryGetValue(e.DesignationId.Value, out var mappedRole))

                {

                    roleName = mappedRole;

                }

                else if (!string.IsNullOrWhiteSpace(e.Role))

                {

                    roleName = e.Role;

                }



                string rLower = roleName.Trim().ToLowerInvariant();

                if (rLower == "sr. manager" || rLower == "manager" || rLower.Contains("senior manager") || rLower.Contains("manager"))

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

                Priority = "High",

                Status = "Pending",

                Unread = true,

                RaisedByName = performerName ?? currentUser.Name ?? "System",

                RelatedTask = employeeCode,

                CreatedAtUtc = DateTime.UtcNow,

                HistoryJson = JsonSerializer.Serialize(new[]

                {

                    new

                    {

                        status = "Pending",

                        at = DateTime.UtcNow.ToString("o"),

                        details = $"Resource '{employeeName}' ({employeeCode}) was successfully onboarded."

                    }

                })

            };

            db.ActionNotifications.Add(notif);

            addedList.Add(notif);

        }



        await db.SaveChangesAsync(ct);

        TrySyncNotificationsToOtherDatabase(addedList);

    }



    private static void TrySyncNotificationsToOtherDatabase(IReadOnlyList<ActionNotification> notifications)

    {

        try

        {

            using var conn = new Npgsql.NpgsqlConnection("Host=10.50.30.189;Port=41763;Database=pms_uat;Username=postgres;Password=clockit;Include Error Detail=true");

            conn.Open();

            foreach (var n in notifications)

            {

                using var cmd = conn.CreateCommand();

                cmd.CommandText = @"

                    INSERT INTO action.tbl_notifications 

                    (""Id"", ""RecipientEmployeeId"", ""ProjectId"", ""ProjectCode"", ""ProjectName"", ""Title"", ""Type"", ""Priority"", ""Status"", ""Unread"", ""RaisedByName"", ""RelatedTask"", ""HistoryJson"", ""CreatedAtUtc"")

                    VALUES (@id, @recip, @pid, @pcode, @pname, @title, @type, @pri, @stat, @unread, @raised, @task, @hist, @created)

                    ON CONFLICT (""Id"") DO NOTHING";

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

                cmd.Parameters.AddWithValue("created", n.CreatedAtUtc);

                cmd.ExecuteNonQuery();

            }

        }

        catch

        {

            // Silently ignore secondary sync failure

        }

    }

}

