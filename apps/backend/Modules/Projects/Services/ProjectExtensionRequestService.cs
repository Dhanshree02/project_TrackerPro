using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Sla.DTOs;
using PMS.API.Modules.Sla.Models;
using PMS.API.Modules.Sla.Services;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Projects.Services;

public sealed class ProjectExtensionRequestService(
    AppDbContext db,
    ICurrentUserService currentUser,
    ISlaTrackingService slaTrackingService,
    ISlaRecipientResolver recipientResolver,
    ILogger<ProjectExtensionRequestService> logger) : IProjectExtensionRequestService
{

    public const string PmoSubDepartment = "PMO (Project Management Office)";



    public async Task<IReadOnlyList<ExtensionApproverDto>> ListApproversAsync(CancellationToken ct = default)

    {

        var people = await PmoEmployeesQuery().OrderBy(e => e.FirstName).ThenBy(e => e.LastName).ToListAsync(ct);

        return people.Select(e => ToApprover(e, "Pending")).ToList();

    }



    public async Task<IReadOnlyList<ProjectExtensionRequestDto>> ListAsync(Guid projectId, CancellationToken ct = default)

    {

        await EnsureProjectExistsAsync(projectId, ct);



        var rows = await db.ProjectExtensionRequests

            .AsNoTracking()

            .Include(x => x.Approvers)

            .Include(x => x.Project)

            .Where(x => x.ProjectId == projectId && x.DeletedAtUtc == null)

            .OrderByDescending(x => x.CreatedAtUtc)

            .ToListAsync(ct);



        return rows.Select(Map).ToList();

    }



    public async Task<ProjectExtensionRequestDto> CreateAsync(

        Guid projectId,

        CreateProjectExtensionRequest request,

        CancellationToken ct = default)

    {

        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct)

            ?? throw new NotFoundException($"Project '{projectId}' was not found.");



        if (project.EndDate is not DateOnly currentEnd)

        {

            throw new ConflictException("This project does not have an end date yet.");

        }



        if (request.RequestedEndDate <= currentEnd)

        {

            throw new ConflictException("Requested new end date must be after the current end date.");

        }



        var wanted = request.ApproverEmployeeIds.Where(id => id != Guid.Empty).Distinct().ToList();

        var people = await PmoEmployeesQuery().Where(e => wanted.Contains(e.Id)).ToListAsync(ct);

        if (people.Count != wanted.Count)

        {

            throw new ConflictException("Approvers must be employees in PMO (Project Management Office).");

        }



        var requester = await FindRequesterAsync(ct);

        var requesterName = requester is null

            ? (currentUser.Name ?? currentUser.Email ?? "User")

            : $"{requester.FirstName} {requester.LastName}".Trim();



        var row = new ProjectExtensionRequest

        {

            ProjectId = projectId,

            CurrentEndDate = currentEnd,

            RequestedEndDate = request.RequestedEndDate,

            ExtensionDays = request.RequestedEndDate.DayNumber - currentEnd.DayNumber,

            Reason = request.Reason.Trim(),

            Status = "Pending",

            RequestedByEmployeeId = requester?.Id,

            RequestedByName = string.IsNullOrWhiteSpace(requesterName) ? "User" : requesterName,
            CommentsJson = "[]",
            HistoryJson = JsonSerializer.Serialize(new[]
            {
                new
                {
                    status = "Pending",
                    at = DateTime.UtcNow.ToString("o"),
                    updatedBy = string.IsNullOrWhiteSpace(requesterName) ? "User" : requesterName,
                    details = $"Requested extension to {request.RequestedEndDate:dd-MMM-yyyy}"
                }
            }),

            Approvers = people

                .OrderBy(e => e.FirstName)

                .ThenBy(e => e.LastName)

                .Select(e => new ProjectExtensionApprover

                {

                    EmployeeId = e.Id,

                    EmployeeName = $"{e.FirstName} {e.LastName}".Trim(),

                    Status = "Pending",

                })

                .ToList(),

        };



        db.ProjectExtensionRequests.Add(row);



        // Notify tagged approvers about the extension approval request

        var reqTitle = $"Timeline Extension Approval Request: {project.Name} (Requested: {request.RequestedEndDate:dd-MMM-yyyy})";

        var createdNotifs = new List<ActionNotification>();

        foreach (var approver in people)

        {

            var notif = new ActionNotification

            {

                Id = Guid.NewGuid(),

                RecipientEmployeeId = approver.Id,

                ProjectId = project.Id,

                ProjectCode = project.ProjectCode,

                ProjectName = project.Name,

                Title = reqTitle,

                Type = "Timeline Extension Approval",

                Priority = "High",

                Status = "Pending",

                Unread = true,

                RaisedByEmployeeId = requester?.Id,

                RaisedByName = string.IsNullOrWhiteSpace(requesterName) ? "User" : requesterName,

                RelatedTask = row.Id.ToString(),

                CreatedAtUtc = DateTime.UtcNow,

                HistoryJson = JsonSerializer.Serialize(new[]

                {

                    new

                    {

                        status = "Pending",

                        at = DateTime.UtcNow.ToString("o"),

                        updatedBy = requesterName,

                        details = $"Requested timeline extension of {row.ExtensionDays} days to {row.RequestedEndDate:dd-MMM-yyyy}. Reason: {row.Reason}"

                    }

                })

            };

            db.ActionNotifications.Add(notif);

            createdNotifs.Add(notif);

        }



        await db.SaveChangesAsync(ct);

        TrySyncNotificationsToOtherDatabase(createdNotifs);

        try
        {
            await slaTrackingService.StartTrackingAsync(new SlaStartTrackingRequest(
                Module: "Project",
                ActivityType: "Extension Request",
                EntityId: row.Id,
                EntityReference: $"EXT-{row.Id.ToString("N")[..8].ToUpper()}",
                Stage: "Pending",
                Priority: SlaPriority.High,
                RecipientEmployeeId: people.FirstOrDefault()?.Id,
                ProjectId: project.Id,
                CustomStartTimeUtc: DateTime.UtcNow
            ), ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "[ExtensionRequest] Failed to start SLA tracking for request {RequestId}", row.Id);
        }

        return Map(row);

    }



    public async Task<IReadOnlyList<PendingExtensionApprovalDto>> ListPendingApprovalsAsync(CancellationToken ct = default)

    {

        var currentEmp = await FindRequesterAsync(ct);

        var currentEmpId = currentEmp?.Id;

        var userRole = (currentUser.Role ?? currentEmp?.Role ?? "").Trim();

        var isSuperAdmin = userRole.Equals("Admin", StringComparison.OrdinalIgnoreCase) ||

                           userRole.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) ||

                           string.Equals(currentUser.Name, "Dhanshree", StringComparison.OrdinalIgnoreCase) ||

                           string.Equals(currentUser.Email, "admin@talakunchi.com", StringComparison.OrdinalIgnoreCase);



        var query = db.ProjectExtensionRequests

            .Include(x => x.Project)

            .Include(x => x.Approvers)

            .AsNoTracking()

            .Where(x => x.DeletedAtUtc == null);



        if (!isSuperAdmin)

        {

            if (currentEmpId.HasValue)

            {

                var empId = currentEmpId.Value;

                query = query.Where(x => x.Approvers.Any(a => a.EmployeeId == empId));

            }

            else

            {

                return Array.Empty<PendingExtensionApprovalDto>();

            }

        }



        var items = await query.OrderByDescending(x => x.CreatedAtUtc).ToListAsync(ct);



        return items.Select(x => new PendingExtensionApprovalDto(

            Id: x.Id,

            ProjectId: x.ProjectId,

            ProjectName: x.Project?.Name ?? "Project",

            ProjectCode: x.Project?.ProjectCode,

            CurrentEndDate: x.CurrentEndDate,

            RequestedEndDate: x.RequestedEndDate,

            ExtensionDays: x.ExtensionDays,

            Reason: x.Reason,

            Status: x.Status,

            RequestedByEmployeeId: x.RequestedByEmployeeId,

            RequestedByName: x.RequestedByName,

            CreatedAtUtc: x.CreatedAtUtc,

            Approvers: x.Approvers

                .OrderBy(a => a.EmployeeName)

                .Select(a => new ExtensionApproverDto(a.EmployeeId, a.EmployeeName, null, PmoSubDepartment, a.Status))

                .ToList(),
            CommentsJson: x.CommentsJson,
            HistoryJson: x.HistoryJson

        )).ToList();

    }



    public async Task<ProjectExtensionRequestDto> ApproveAsync(

        Guid projectId,

        Guid extensionRequestId,

        ApproveExtensionRequestDto request,

        CancellationToken ct = default)

    {

        var ext = await db.ProjectExtensionRequests

            .Include(x => x.Approvers)

            .Include(x => x.Project)

            .FirstOrDefaultAsync(x => x.Id == extensionRequestId && x.ProjectId == projectId && x.DeletedAtUtc == null, ct)

            ?? throw new NotFoundException($"Extension request '{extensionRequestId}' was not found.");



        if (ext.Status == "Approved")

        {

            return Map(ext);

        }



        var currentEmp = await FindRequesterAsync(ct);

        var approverName = currentEmp != null ? $"{currentEmp.FirstName} {currentEmp.LastName}".Trim() : (currentUser.Name ?? currentUser.Email ?? "Approver");

        var approverEmployeeId = currentEmp?.Id;



        // 1. Update extension request status

        ext.Status = "Approved";

        ext.UpdatedAtUtc = DateTime.UtcNow;

        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            ext.CommentsJson = AppendComment(ext.CommentsJson, request.Comment, approverEmployeeId?.ToString() ?? "", approverName);
        }
        ext.HistoryJson = AppendHistory(ext.HistoryJson, "Approved", approverName, request.Comment, $"Timeline extension approved to {ext.RequestedEndDate:dd-MMM-yyyy}. {(string.IsNullOrWhiteSpace(request.Comment) ? "" : $"Comment: {request.Comment.Trim()}")}");



        foreach (var app in ext.Approvers)

        {

            if (currentEmp != null && app.EmployeeId == currentEmp.Id)

            {

                app.Status = "Approved";

                app.UpdatedAtUtc = DateTime.UtcNow;

            }

            else

            {

                app.Status = "Approved";

                app.UpdatedAtUtc = DateTime.UtcNow;

            }

        }



        // 2. Update project EndDate

        var project = ext.Project ?? await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct);

        if (project != null)

        {

            project.EndDate = ext.RequestedEndDate;

            project.UpdatedAtUtc = DateTime.UtcNow;



            // Also update the latest service's EndDate in project.tbl_project_services so WBS and services expand

            var services = await db.ProjectServices

                .Where(s => s.ProjectId == projectId && s.DeletedAtUtc == null)

                .OrderByDescending(s => s.EndDate)

                .ToListAsync(ct);



            if (services.Count > 0)

            {

                var maxEndDate = services[0].EndDate;

                foreach (var svc in services)

                {

                    if (svc.EndDate == maxEndDate && svc.EndDate < ext.RequestedEndDate)

                    {

                        svc.EndDate = ext.RequestedEndDate;

                        if (svc.StartDate.HasValue)

                        {

                            svc.TotalDays = ext.RequestedEndDate.DayNumber - svc.StartDate.Value.DayNumber + 1;

                            svc.DurationDays = svc.TotalDays;

                        }

                        svc.UpdatedAtUtc = DateTime.UtcNow;

                    }

                }

            }



            TrySyncEndDateToOtherDatabase(project.Id, ext.RequestedEndDate);

            await NotifyLeadershipAndPmoAsync(project, ext, "Approved", approverName, approverEmployeeId, request.Comment, ct);
        }

        try
        {
            await slaTrackingService.CompleteTrackingAsync(ext.Id, "Extension Request", ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "[ExtensionRequest] Failed to complete SLA tracking for {ExtId}", ext.Id);
        }

        await db.SaveChangesAsync(ct);

        logger.LogInformation("Timeline extension {ExtId} approved for project {ProjectId}. New End Date: {NewEnd}.",

            extensionRequestId, projectId, ext.RequestedEndDate);



        return Map(ext);

    }



    public async Task<ProjectExtensionRequestDto> RejectAsync(

        Guid projectId,

        Guid extensionRequestId,

        RejectExtensionRequestDto request,

        CancellationToken ct = default)

    {

        var ext = await db.ProjectExtensionRequests

            .Include(x => x.Approvers)

            .Include(x => x.Project)

            .FirstOrDefaultAsync(x => x.Id == extensionRequestId && x.ProjectId == projectId && x.DeletedAtUtc == null, ct)

            ?? throw new NotFoundException($"Extension request '{extensionRequestId}' was not found.");



        var currentEmp = await FindRequesterAsync(ct);

        var approverName = currentEmp != null ? $"{currentEmp.FirstName} {currentEmp.LastName}".Trim() : (currentUser.Name ?? currentUser.Email ?? "Approver");

        var approverEmployeeId = currentEmp?.Id;



        ext.Status = "Rejected";

        ext.UpdatedAtUtc = DateTime.UtcNow;

        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            ext.CommentsJson = AppendComment(ext.CommentsJson, request.Comment, approverEmployeeId?.ToString() ?? "", approverName);
        }
        ext.HistoryJson = AppendHistory(ext.HistoryJson, "Rejected", approverName, request.Comment, $"Timeline extension rejected. {(string.IsNullOrWhiteSpace(request.Comment) ? "" : $"Comment: {request.Comment.Trim()}")}");



        foreach (var app in ext.Approvers)

        {

            app.Status = "Rejected";

            app.UpdatedAtUtc = DateTime.UtcNow;

        }

        var project = ext.Project ?? await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct);
        if (project != null)
        {
            await NotifyLeadershipAndPmoAsync(project, ext, "Rejected", approverName, approverEmployeeId, request.Comment, ct);
        }

        try
        {
            await slaTrackingService.CompleteTrackingAsync(ext.Id, "Extension Request", ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "[ExtensionRequest] Failed to complete SLA tracking for {ExtId}", ext.Id);
        }

        await db.SaveChangesAsync(ct);

        return Map(ext);

    }



    private async Task<Employee?> ResolveTeamLeadAsync(Project project, CancellationToken ct)

    {

        if (project.TeamLeadId is Guid tlId)

        {

            var emp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == tlId && e.DeletedAtUtc == null, ct);

            if (emp != null) return emp;

        }



        var tm = await db.ProjectTeamMembers

            .AsNoTracking()

            .Where(m => m.ProjectId == project.Id && m.IsTeamLead && m.DeletedAtUtc == null)

            .OrderBy(m => m.CreatedAtUtc)

            .FirstOrDefaultAsync(ct);



        if (tm != null)

        {

            return await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == tm.EmployeeId && e.DeletedAtUtc == null, ct);

        }



        return null;

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



    private async Task NotifyLeadershipAndPmoAsync(
        Project project,
        ProjectExtensionRequest ext,
        string status,
        string actorName,
        Guid? actorEmployeeId,
        string? comment,
        CancellationToken ct)
    {
        var recipientIds = new HashSet<Guid>();

        // 1. Assigned Project Manager(s)
        if (project.ProjectManagerId.HasValue && project.ProjectManagerId.Value != Guid.Empty)
        {
            recipientIds.Add(project.ProjectManagerId.Value);
        }
        var pmTeamMembers = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(tm => tm.ProjectId == project.Id && tm.DeletedAtUtc == null &&
                         (tm.MemberRole == "ProjectManager" || tm.MemberRole == "PM" || tm.MemberRole == "Project Manager"))
            .Select(tm => tm.EmployeeId)
            .ToListAsync(ct);
        foreach (var id in pmTeamMembers) recipientIds.Add(id);

        // 2. Assigned Engagement Manager(s)
        if (project.EngagementManagerId.HasValue && project.EngagementManagerId.Value != Guid.Empty)
        {
            recipientIds.Add(project.EngagementManagerId.Value);
        }
        if (project.Client != null && project.Client.EngagementManagerId.HasValue && project.Client.EngagementManagerId.Value != Guid.Empty)
        {
            recipientIds.Add(project.Client.EngagementManagerId.Value);
        }
        var emTeamMembers = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(tm => tm.ProjectId == project.Id && tm.DeletedAtUtc == null &&
                         (tm.MemberRole == "EngagementManager" || tm.MemberRole == "EM" || tm.MemberRole == "Engagement Manager"))
            .Select(tm => tm.EmployeeId)
            .ToListAsync(ct);
        foreach (var id in emTeamMembers) recipientIds.Add(id);
        var emByName = await ResolveEngagementManagerAsync(project, ct);
        if (emByName != null) recipientIds.Add(emByName.Id);

        // 3. Assigned Senior Project Manager(s)
        var spmRecipients = await recipientResolver.ResolveRecipientsAsync(new SlaInstance { ProjectId = project.Id }, ["Assigned Senior Project Manager"], ct);
        foreach (var id in spmRecipients) recipientIds.Add(id);

        // 4. Head of Department (HOD)
        var hodRecipients = await recipientResolver.ResolveRecipientsAsync(new SlaInstance { ProjectId = project.Id }, ["Head of Department"], ct);
        foreach (var id in hodRecipients) recipientIds.Add(id);

        // 5. Team Leads of the project
        if (project.TeamLeadId.HasValue && project.TeamLeadId.Value != Guid.Empty)
        {
            recipientIds.Add(project.TeamLeadId.Value);
        }
        var tlMembers = await db.ProjectTeamMembers
            .AsNoTracking()
            .Where(tm => tm.ProjectId == project.Id && tm.DeletedAtUtc == null &&
                         (tm.IsTeamLead || tm.MemberRole == "TeamLead" || tm.MemberRole == "Team Leader" || (tm.MemberRole != null && tm.MemberRole.Contains("TeamLead"))))
            .Select(tm => tm.EmployeeId)
            .ToListAsync(ct);
        foreach (var id in tlMembers) recipientIds.Add(id);

        // 6. PMO whose Resources Sub-Department are `EM (Engagement Manager)`, `PMO (Project Management Office)`
        var targetSubDeptEm = "em (engagement manager)";
        var targetSubDeptPmo = "pmo (project management office)";
        var pmoEmployees = await db.Employees
            .AsNoTracking()
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || !e.Status.ToLower().StartsWith("inactive")))
            .Where(e => (e.SubDepartment != null && (
                            e.SubDepartment.ToLower() == targetSubDeptEm ||
                            e.SubDepartment.ToLower() == targetSubDeptPmo
                        ))
                        || (e.SubDepartmentRef != null && (
                            e.SubDepartmentRef.Name.ToLower() == targetSubDeptEm ||
                            e.SubDepartmentRef.Name.ToLower() == targetSubDeptPmo
                        )))
            .Select(e => e.Id)
            .ToListAsync(ct);
        foreach (var id in pmoEmployees) recipientIds.Add(id);

        var commentPart = string.IsNullOrWhiteSpace(comment) ? "" : $" Remarks: \"{comment.Trim()}\"";
        string notifTitle;
        string notifStatus = status;
        string priority = "High";

        if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase))
        {
            notifTitle = $"Timeline Extension Approved: {project.Name} extended to {ext.RequestedEndDate:dd-MMM-yyyy}.{commentPart}";
            notifStatus = "Approved";
            priority = "High";
        }
        else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
        {
            notifTitle = $"Timeline Extension Rejected: {project.Name}.{commentPart}";
            notifStatus = "Rejected";
            priority = "Medium";
        }
        else if (status.Equals("Hold", StringComparison.OrdinalIgnoreCase))
        {
            notifTitle = $"Timeline Extension On Hold: {project.Name}.{commentPart}";
            notifStatus = "Hold";
            priority = "Medium";
        }
        else
        {
            notifTitle = $"Timeline Extension Changes Requested: {project.Name}.{commentPart}";
            notifStatus = "Request Changes";
            priority = "Medium";
        }

        // Also update any pending approval request notifications for this extension request
        var extIdStr = ext.Id.ToString();
        var existingNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == extIdStr && n.DeletedAtUtc == null && n.Status == "Pending")
            .ToListAsync(ct);
        foreach (var n in existingNotifs)
        {
            n.Status = notifStatus;
            n.Unread = false;
            n.UpdatedAtUtc = DateTime.UtcNow;
        }

        var createdNotifs = new List<ActionNotification>();
        foreach (var recipientId in recipientIds)
        {
            var notif = new ActionNotification
            {
                Id = Guid.NewGuid(),
                RecipientEmployeeId = recipientId,
                ProjectId = project.Id,
                ProjectCode = project.ProjectCode,
                ProjectName = project.Name,
                Title = notifTitle,
                Type = "Timeline Extension",
                Priority = priority,
                Status = notifStatus,
                Unread = true,
                RaisedByEmployeeId = actorEmployeeId,
                RaisedByName = actorName,
                RelatedTask = ext.Id.ToString(),
                CreatedAtUtc = DateTime.UtcNow,
                HistoryJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        status = notifStatus,
                        at = DateTime.UtcNow.ToString("o"),
                        updatedBy = actorName,
                        details = $"{notifTitle}"
                    }
                })
            };
            db.ActionNotifications.Add(notif);
            createdNotifs.Add(notif);
        }

        TrySyncNotificationsToOtherDatabase(createdNotifs);
    }

    private async Task<List<Employee>> GetPmoTeamEmployeesAsync(CancellationToken ct)

    {

        return await PmoEmployeesQuery().ToListAsync(ct);

    }



    private static void TrySyncNotificationsToOtherDatabase(IReadOnlyList<ActionNotification> notifications)

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



    private void TrySyncEndDateToOtherDatabase(Guid projectId, DateOnly newEndDate)

    {

        try

        {

            using var conn = new Npgsql.NpgsqlConnection("Host=127.0.0.1;Port=5432;Database=pms_uat;Username=postgres;Password=123;Timeout=2;Include Error Detail=true");

            conn.Open();

            using var cmd = conn.CreateCommand();

            cmd.CommandText = "UPDATE project.tbl_projects SET \"EndDate\" = @end, \"UpdatedAtUtc\" = NOW() WHERE \"Id\" = @pid";

            cmd.Parameters.AddWithValue("end", newEndDate);

            cmd.Parameters.AddWithValue("pid", projectId);

            cmd.ExecuteNonQuery();



            using var cmd2 = conn.CreateCommand();

            cmd2.CommandText = "UPDATE project.tbl_project_services SET \"EndDate\" = @end, \"UpdatedAtUtc\" = NOW() WHERE \"ProjectId\" = @pid AND \"EndDate\" = (SELECT MAX(\"EndDate\") FROM project.tbl_project_services WHERE \"ProjectId\" = @pid AND \"DeletedAtUtc\" IS NULL)";

            cmd2.Parameters.AddWithValue("end", newEndDate);

            cmd2.Parameters.AddWithValue("pid", projectId);

            cmd2.ExecuteNonQuery();

        }

        catch (Exception ex)

        {

            logger.LogWarning(ex, "Failed to secondary sync EndDate to pms_uat: {Message}", ex.Message);

        }

    }



    private IQueryable<Employee> PmoEmployeesQuery()

    {

        var key = PmoSubDepartment.ToLowerInvariant();

        return db.Employees.AsNoTracking().Where(e =>

            ((e.SubDepartment != null && e.SubDepartment.Trim().ToLower() == key)

             || (e.SubDepartmentRef != null && e.SubDepartmentRef.Name.Trim().ToLower() == key))

            && (e.Status == null || e.Status.ToLower().StartsWith("active"))

            && e.DeletedAtUtc == null);

    }



    private async Task<Employee?> FindRequesterAsync(CancellationToken ct)

    {

        if (currentUser.UserId is Guid userId)

        {

            var byId = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == userId && e.DeletedAtUtc == null, ct);

            if (byId is not null) return byId;



            var byUserId = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.UserId == userId && e.DeletedAtUtc == null, ct);

            if (byUserId is not null) return byUserId;

        }



        var email = currentUser.Email?.Trim().ToLowerInvariant();
        if (!string.IsNullOrWhiteSpace(email))
        {
            var empByEmail = await db.Employees.AsNoTracking()
                .FirstOrDefaultAsync(e => e.WorkEmail.ToLower() == email && e.DeletedAtUtc == null, ct);
            if (empByEmail is not null) return empByEmail;
        }

        if (!string.IsNullOrWhiteSpace(currentUser.Name))
        {
            var name = currentUser.Name.Trim();
            var empByName = await db.Employees.AsNoTracking()
                .FirstOrDefaultAsync(e => EF.Functions.ILike((e.FirstName + " " + e.LastName).Trim(), name) && e.DeletedAtUtc == null, ct);
            if (empByName is not null) return empByName;
        }

        return null;
    }

    private async Task EnsureProjectExistsAsync(Guid projectId, CancellationToken ct)

    {

        var exists = await db.Projects.AnyAsync(p => p.Id == projectId && p.DeletedAtUtc == null, ct);

        if (!exists)

        {

            throw new NotFoundException($"Project '{projectId}' was not found.");

        }

    }



    private static ExtensionApproverDto ToApprover(Employee employee, string status) => new(

        employee.Id,

        $"{employee.FirstName} {employee.LastName}".Trim(),

        employee.EmployeeCode,

        employee.SubDepartment?.Trim() ?? PmoSubDepartment,

        status);



        public async Task<ProjectExtensionRequestDto> TakeActionAsync(
        Guid projectId,
        Guid extensionRequestId,
        TakeExtensionActionRequest request,
        CancellationToken ct = default)
    {
        var normalizedStatus = (request.Status ?? "").Trim();
        if (normalizedStatus.Equals("Approved", StringComparison.OrdinalIgnoreCase))
        {
            return await ApproveAsync(projectId, extensionRequestId, new ApproveExtensionRequestDto(request.Comment), ct);
        }
        if (normalizedStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
        {
            return await RejectAsync(projectId, extensionRequestId, new RejectExtensionRequestDto(request.Comment), ct);
        }

        var ext = await db.ProjectExtensionRequests
            .Include(x => x.Approvers)
            .Include(x => x.Project)
            .FirstOrDefaultAsync(x => x.Id == extensionRequestId && x.ProjectId == projectId && x.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Extension request '{extensionRequestId}' was not found.");

        var currentEmp = await FindRequesterAsync(ct);
        var actorName = currentEmp != null ? $"{currentEmp.FirstName} {currentEmp.LastName}".Trim() : (currentUser.Name ?? currentUser.Email ?? "Approver");
        var actorEmployeeId = currentEmp?.Id;

        var statusLabel = normalizedStatus.Equals("Hold", StringComparison.OrdinalIgnoreCase) ? "Hold" : "Request Changes";
        ext.Status = statusLabel;
        ext.UpdatedAtUtc = DateTime.UtcNow;

        if (!string.IsNullOrWhiteSpace(request.Comment))
        {
            ext.CommentsJson = AppendComment(ext.CommentsJson, request.Comment, actorEmployeeId?.ToString() ?? "", actorName);
        }
        ext.HistoryJson = AppendHistory(ext.HistoryJson, statusLabel, actorName, request.Comment, $"Status changed to {statusLabel} by {actorName}. {(string.IsNullOrWhiteSpace(request.Comment) ? "" : $"Comment: {request.Comment.Trim()}")}");

        var project = ext.Project ?? await db.Projects.FirstOrDefaultAsync(p => p.Id == projectId, ct);
        if (project != null)
        {
            await NotifyLeadershipAndPmoAsync(project, ext, statusLabel, actorName, actorEmployeeId, request.Comment, ct);
        }

        try
        {
            await slaTrackingService.CompleteTrackingAsync(ext.Id, "Extension Request", ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "[ExtensionRequest] Failed to complete SLA tracking for {ExtId}", ext.Id);
        }

        await db.SaveChangesAsync(ct);
        return Map(ext);
    }

    public async Task<ProjectExtensionRequestDto> AddCommentAsync(
        Guid projectId,
        Guid extensionRequestId,
        AddExtensionCommentRequest request,
        CancellationToken ct = default)
    {
        var ext = await db.ProjectExtensionRequests
            .Include(x => x.Approvers)
            .Include(x => x.Project)
            .FirstOrDefaultAsync(x => x.Id == extensionRequestId && x.ProjectId == projectId && x.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Extension request '{extensionRequestId}' was not found.");

        if (string.IsNullOrWhiteSpace(request.Text))
        {
            throw new BadRequestException("Comment text cannot be empty.");
        }

        var currentEmp = await FindRequesterAsync(ct);
        var authorName = currentEmp != null ? $"{currentEmp.FirstName} {currentEmp.LastName}".Trim() : (currentUser.Name ?? currentUser.Email ?? "User");
        var authorId = currentEmp?.Id.ToString() ?? currentUser.UserId?.ToString() ?? "";

        ext.CommentsJson = AppendComment(ext.CommentsJson, request.Text.Trim(), authorId, authorName);
        ext.UpdatedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
        return Map(ext);
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

private static ProjectExtensionRequestDto Map(ProjectExtensionRequest row) => new(

        row.Id,

        row.ProjectId,

        row.CurrentEndDate,

        row.RequestedEndDate,

        row.ExtensionDays,

        row.Reason,

        row.Status,

        row.RequestedByName,

        row.CreatedAtUtc,

        row.Approvers

            .OrderBy(a => a.EmployeeName)

            .Select(a => new ExtensionApproverDto(a.EmployeeId, a.EmployeeName, null, PmoSubDepartment, a.Status))

            .ToList(),

        row.Project?.Name,

        row.Project?.ProjectCode,
        row.CommentsJson,
        row.HistoryJson);

}

