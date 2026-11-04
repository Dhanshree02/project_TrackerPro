using System.Text.Json;

using Microsoft.EntityFrameworkCore;

using Microsoft.Extensions.Logging;

using PMS.API.Infrastructure.Authorization;

using PMS.API.Infrastructure.Persistence;

using PMS.API.Modules.ActionCentre.Models;

using PMS.API.Modules.Projects.DTOs;

using PMS.API.Modules.Projects.Models;

using PMS.API.Modules.Resources.Models;

using PMS.API.Shared.Exceptions;



namespace PMS.API.Modules.Projects.Services;



public sealed class ProjectExtensionRequestService(

    AppDbContext db,

    ICurrentUserService currentUser,

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

                .ToList()

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



            TrySyncEndDateToOtherDatabase(project.Id, ext.RequestedEndDate);



            // 3. Dispatch notification ONLY to:

            // Assigned Team Lead, Assigned Project Manager, Assigned Senior Project Manager, Assigned Engagement Manager, and PMO Team

            var recipients = new List<Employee>();



            var tl = await ResolveTeamLeadAsync(project, ct);

            if (tl != null) recipients.Add(tl);



            var pm = await ResolveProjectManagerAsync(project, ct);

            if (pm != null && !recipients.Any(r => r.Id == pm.Id)) recipients.Add(pm);



            var spm = await ResolveSeniorProjectManagerAsync(project, ct);

            if (spm != null && !recipients.Any(r => r.Id == spm.Id)) recipients.Add(spm);



            var em = await ResolveEngagementManagerAsync(project, ct);

            if (em != null && !recipients.Any(r => r.Id == em.Id)) recipients.Add(em);



            var pmoTeam = await GetPmoTeamEmployeesAsync(ct);

            foreach (var pmoMember in pmoTeam)

            {

                if (!recipients.Any(r => r.Id == pmoMember.Id))

                {

                    recipients.Add(pmoMember);

                }

            }



            var approvedNotifTitle = $"Timeline Extension Approved: {project.Name} extended to {ext.RequestedEndDate:dd-MMM-yyyy}";

            foreach (var recipient in recipients)

            {

                var notif = new ActionNotification

                {

                    Id = Guid.NewGuid(),

                    RecipientEmployeeId = recipient.Id,

                    ProjectId = project.Id,

                    ProjectCode = project.ProjectCode,

                    ProjectName = project.Name,

                    Title = approvedNotifTitle,

                    Type = "Timeline Extension",

                    Priority = "High",

                    Status = "Approved",

                    Unread = true,

                    RaisedByEmployeeId = approverEmployeeId,

                    RaisedByName = approverName,

                    RelatedTask = ext.Id.ToString(),

                    CreatedAtUtc = DateTime.UtcNow,

                    HistoryJson = JsonSerializer.Serialize(new[]

                    {

                        new

                        {

                            status = "Approved",

                            at = DateTime.UtcNow.ToString("o"),

                            updatedBy = approverName,

                            details = $"Timeline extension approved to {ext.RequestedEndDate:dd-MMM-yyyy}. {(string.IsNullOrWhiteSpace(request.Comment) ? "" : $"Comment: {request.Comment.Trim()}")}"

                        }

                    })

                };

                db.ActionNotifications.Add(notif);

            }

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



        foreach (var app in ext.Approvers)

        {

            app.Status = "Rejected";

            app.UpdatedAtUtc = DateTime.UtcNow;

        }



        if (ext.RequestedByEmployeeId.HasValue)

        {

            var notif = new ActionNotification

            {

                Id = Guid.NewGuid(),

                RecipientEmployeeId = ext.RequestedByEmployeeId.Value,

                ProjectId = ext.ProjectId,

                ProjectCode = ext.Project?.ProjectCode,

                ProjectName = ext.Project?.Name ?? "Project",

                Title = $"Timeline Extension Rejected: {ext.Project?.Name ?? "Project"}",

                Type = "Timeline Extension",

                Priority = "Medium",

                Status = "Rejected",

                Unread = true,

                RaisedByEmployeeId = approverEmployeeId,

                RaisedByName = approverName,

                RelatedTask = ext.Id.ToString(),

                CreatedAtUtc = DateTime.UtcNow,

                HistoryJson = JsonSerializer.Serialize(new[]

                {

                    new

                    {

                        status = "Rejected",

                        at = DateTime.UtcNow.ToString("o"),

                        updatedBy = approverName,

                        details = $"Timeline extension rejected. {(string.IsNullOrWhiteSpace(request.Comment) ? "" : $"Comment: {request.Comment.Trim()}")}"

                    }

                })

            };

            db.ActionNotifications.Add(notif);

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



    private async Task<List<Employee>> GetPmoTeamEmployeesAsync(CancellationToken ct)

    {

        return await PmoEmployeesQuery().ToListAsync(ct);

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

            using var conn = new Npgsql.NpgsqlConnection("Host=10.50.30.189;Port=41763;Database=pms_uat;Username=postgres;Password=clockit;Include Error Detail=true");

            conn.Open();

            using var cmd = conn.CreateCommand();

            cmd.CommandText = "UPDATE project.tbl_projects SET \"EndDate\" = @end, \"UpdatedAtUtc\" = NOW() WHERE \"Id\" = @pid";

            cmd.Parameters.AddWithValue("end", newEndDate);

            cmd.Parameters.AddWithValue("pid", projectId);

            cmd.ExecuteNonQuery();

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

        row.Project?.ProjectCode);

}

