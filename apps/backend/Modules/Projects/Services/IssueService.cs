using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;

namespace PMS.API.Modules.Projects.Services;

public class IssueService : IIssueService
{
    private readonly AppDbContext _db;
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    private static readonly Dictionary<int, string> EscalationRoles = new()
    {
        { 1, "PM" },
        { 2, "SPM" },
        { 3, "EM" },
        { 4, "PMO" },
        { 5, "HOD" },
        { 6, "CEO" }
    };

    public IssueService(AppDbContext db)
    {
        _db = db;
    }

    public async Task<List<IssueProjectOption>> GetProjectOptionsAsync(CancellationToken cancellationToken = default)
    {
        return await _db.Projects
            .AsNoTracking()
            .OrderBy(p => p.Name)
            .Select(p => new IssueProjectOption(p.Id, p.Name, p.ProjectCode))
            .ToListAsync(cancellationToken);
    }

    public async Task<IssueResponse> CreateIssueAsync(CreateIssueRequest request, CancellationToken cancellationToken = default)
    {
        Project? project = null;
        if (!string.IsNullOrWhiteSpace(request.ProjectId) && Guid.TryParse(request.ProjectId, out var parsedGuid))
        {
            project = await _db.Projects
                .Include(p => p.ProjectManager)
                .Include(p => p.EngagementManagerRef)
                .FirstOrDefaultAsync(p => p.Id == parsedGuid, cancellationToken);
        }

        if (project == null && !string.IsNullOrWhiteSpace(request.ProjectId))
        {
            project = await _db.Projects
                .Include(p => p.ProjectManager)
                .Include(p => p.EngagementManagerRef)
                .FirstOrDefaultAsync(p => p.ProjectCode == request.ProjectId || p.Name == request.ProjectId, cancellationToken);
        }

        if (project == null)
        {
            project = await _db.Projects
                .Include(p => p.ProjectManager)
                .Include(p => p.EngagementManagerRef)
                .FirstOrDefaultAsync(cancellationToken);
        }

        if (project == null)
        {
            throw new InvalidOperationException("No valid project found in database.");
        }

        Guid? raisedByEmpId = null;
        if (!string.IsNullOrWhiteSpace(request.RaisedByEmployeeId) && Guid.TryParse(request.RaisedByEmployeeId, out var parsedEmpGuid))
        {
            raisedByEmpId = parsedEmpGuid;
        }

        Employee? raisedByEmp = null;
        if (raisedByEmpId.HasValue)
        {
            raisedByEmp = await _db.Employees
                .FirstOrDefaultAsync(e => e.Id == raisedByEmpId.Value, cancellationToken);
        }
        else if (!string.IsNullOrWhiteSpace(request.RaisedByName))
        {
            raisedByEmp = await _db.Employees
                .FirstOrDefaultAsync(e => (e.FirstName + " " + e.LastName) == request.RaisedByName || e.WorkEmail == request.RaisedByName, cancellationToken);
            if (raisedByEmp != null)
            {
                raisedByEmpId = raisedByEmp.Id;
            }
        }

        // Level 1: Dotted line reporting manager (Reporting Manager of the employee who raised the issue)
        Guid? dottedMgrId = null;
        string dottedMgrName = string.Empty;

        // 1. Direct Reporting Manager of the employee raising the issue
        if (raisedByEmp?.ReportingManagerId != null)
        {
            var repMgr = await _db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == raisedByEmp.ReportingManagerId.Value, cancellationToken);
            if (repMgr != null && repMgr.FirstName != "HR" && repMgr.Role != "HR")
            {
                dottedMgrId = repMgr.Id;
                dottedMgrName = $"{repMgr.FirstName} {repMgr.LastName}".Trim();
            }
        }

        // 2. Project Manager assigned to the employee
        if (string.IsNullOrWhiteSpace(dottedMgrName) && raisedByEmp?.ProjectManagerId != null)
        {
            var pmEmp = await _db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Id == raisedByEmp.ProjectManagerId.Value, cancellationToken);
            if (pmEmp != null && pmEmp.FirstName != "HR" && pmEmp.Role != "HR")
            {
                dottedMgrId = pmEmp.Id;
                dottedMgrName = $"{pmEmp.FirstName} {pmEmp.LastName}".Trim();
            }
        }

        // 3. Project Manager assigned to the project (excluding HR User)
        if (string.IsNullOrWhiteSpace(dottedMgrName) && project.ProjectManager != null && project.ProjectManager.FirstName != "HR" && project.ProjectManager.Role != "HR")
        {
            dottedMgrId = project.ProjectManager.Id;
            dottedMgrName = $"{project.ProjectManager.FirstName} {project.ProjectManager.LastName}".Trim();
        }

        // 4. Project team members with Project Manager or Team Lead role (excluding HR)
        if (string.IsNullOrWhiteSpace(dottedMgrName))
        {
            var pmTeamMember = await _db.ProjectTeamMembers
                .Include(ptm => ptm.Employee)
                .AsNoTracking()
                .FirstOrDefaultAsync(ptm => ptm.ProjectId == project.Id && ptm.Employee != null && (ptm.IsTeamLead || (ptm.Employee.Role != null && ptm.Employee.Role.Contains("Manager"))) && ptm.Employee.FirstName != "HR", cancellationToken);
            if (pmTeamMember?.Employee != null)
            {
                dottedMgrId = pmTeamMember.Employee.Id;
                dottedMgrName = $"{pmTeamMember.Employee.FirstName} {pmTeamMember.Employee.LastName}".Trim();
            }
        }

        // 5. Fallback: Manager from the employees catalog (excluding HR)
        if (string.IsNullOrWhiteSpace(dottedMgrName))
        {
            var deptPm = await _db.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(e => e.Role != null && e.Role.Contains("Manager") && e.FirstName != "HR", cancellationToken);
            if (deptPm != null)
            {
                dottedMgrId = deptPm.Id;
                dottedMgrName = $"{deptPm.FirstName} {deptPm.LastName}".Trim();
            }
            else
            {
                dottedMgrName = "Reporting Manager";
            }
        }

        var raisedByName = !string.IsNullOrWhiteSpace(request.RaisedByName)
            ? request.RaisedByName
            : (raisedByEmp != null ? $"{raisedByEmp.FirstName} {raisedByEmp.LastName}".Trim() : "Team Member");

        var raisedByRole = !string.IsNullOrWhiteSpace(request.RaisedByRole)
            ? request.RaisedByRole
            : (raisedByEmp?.Role ?? "Team Member");

        var now = DateTime.UtcNow;

        var auditEntries = new List<IssueAuditEntry>
        {
            new(
                Action: "Raised",
                Details: $"Issue raised by {raisedByName} ({raisedByRole}) and routed to Dotted-Line Reporting Manager ({dottedMgrName} · PM). 2-day escalation SLA started.",
                TimestampUtc: now,
                ActorName: raisedByName
            )
        };

        var issue = new ProjectIssue
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            Title = request.Title.Trim(),
            Description = request.Description.Trim(),
            Category = string.IsNullOrWhiteSpace(request.Category) ? "Technical Related Issues" : request.Category.Trim(),
            Priority = string.IsNullOrWhiteSpace(request.Priority) ? "Medium" : request.Priority.Trim(),
            Status = "Open",
            RaisedByEmployeeId = raisedByEmpId,
            RaisedByName = raisedByName,
            RaisedByRole = raisedByRole,
            EscalationLevel = 1,
            CurrentAssigneeRole = "PM",
            CurrentAssigneeEmployeeId = dottedMgrId,
            CurrentAssigneeName = dottedMgrName,
            DottedLineManagerId = dottedMgrId,
            DottedLineManagerName = dottedMgrName,
            LastEscalatedAtUtc = now,
            AuditHistoryJson = JsonSerializer.Serialize(auditEntries, JsonOptions),
            CreatedAtUtc = now
        };

        _db.ProjectIssues.Add(issue);
        await _db.SaveChangesAsync(cancellationToken);

        return MapToResponse(issue, project.Name, project.ProjectCode, auditEntries);
    }

    public async Task<List<IssueResponse>> GetIssuesAsync(
        Guid? projectId = null,
        string? status = null,
        int? escalationLevel = null,
        string? assigneeRole = null,
        CancellationToken cancellationToken = default)
    {
        var query = _db.ProjectIssues
            .Include(i => i.Project)
            .AsQueryable();

        if (projectId.HasValue)
        {
            query = query.Where(i => i.ProjectId == projectId.Value);
        }

        if (!string.IsNullOrWhiteSpace(status) && status != "all")
        {
            var s = status.Trim().ToLowerInvariant();
            query = query.Where(i => i.Status.ToLower() == s);
        }

        if (escalationLevel.HasValue)
        {
            query = query.Where(i => i.EscalationLevel == escalationLevel.Value);
        }

        if (!string.IsNullOrWhiteSpace(assigneeRole) && assigneeRole != "all")
        {
            var r = assigneeRole.Trim().ToUpperInvariant();
            query = query.Where(i => i.CurrentAssigneeRole.ToUpper() == r);
        }

        var issues = await query
            .OrderByDescending(i => i.CreatedAtUtc)
            .ToListAsync(cancellationToken);

        bool changesSaved = false;
        var responses = new List<IssueResponse>();

        foreach (var issue in issues)
        {
            bool escalated = await CheckAndApplyAutoEscalationAsync(issue, cancellationToken);
            if (escalated)
            {
                changesSaved = true;
            }

            var audit = DeserializeAudit(issue.AuditHistoryJson);
            responses.Add(MapToResponse(issue, issue.Project?.Name ?? "Project", issue.Project?.ProjectCode ?? "", audit));
        }

        if (changesSaved)
        {
            await _db.SaveChangesAsync(cancellationToken);
        }

        return responses;
    }

    public async Task<IssueResponse?> GetIssueByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var issue = await _db.ProjectIssues
            .Include(i => i.Project)
            .FirstOrDefaultAsync(i => i.Id == id, cancellationToken);

        if (issue == null) return null;

        if (await CheckAndApplyAutoEscalationAsync(issue, cancellationToken))
        {
            await _db.SaveChangesAsync(cancellationToken);
        }

        var audit = DeserializeAudit(issue.AuditHistoryJson);
        return MapToResponse(issue, issue.Project?.Name ?? "Project", issue.Project?.ProjectCode ?? "", audit);
    }

    public async Task<IssueResponse> UpdateIssueStatusAsync(Guid id, UpdateIssueStatusRequest request, CancellationToken cancellationToken = default)
    {
        var issue = await _db.ProjectIssues
            .Include(i => i.Project)
            .FirstOrDefaultAsync(i => i.Id == id, cancellationToken);

        if (issue == null)
        {
            throw new InvalidOperationException($"Issue with ID {id} not found.");
        }

        var oldStatus = issue.Status;
        issue.Status = request.Status.Trim();
        var now = DateTime.UtcNow;

        if (issue.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) ||
            issue.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase))
        {
            issue.ResolvedAtUtc = now;
            issue.ResolvedByName = request.ActorName ?? "Manager";
            issue.ResolutionNotes = request.ResolutionNotes;
        }

        var audit = DeserializeAudit(issue.AuditHistoryJson);
        audit.Add(new IssueAuditEntry(
            Action: "StatusUpdate",
            Details: $"Status updated from {oldStatus} to {issue.Status} by {request.ActorName ?? "User"}" +
                     (!string.IsNullOrWhiteSpace(request.ResolutionNotes) ? $". Notes: {request.ResolutionNotes}" : ""),
            TimestampUtc: now,
            ActorName: request.ActorName
        ));

        issue.AuditHistoryJson = JsonSerializer.Serialize(audit, JsonOptions);
        await _db.SaveChangesAsync(cancellationToken);

        return MapToResponse(issue, issue.Project?.Name ?? "Project", issue.Project?.ProjectCode ?? "", audit);
    }

    public async Task<IssueResponse> EscalateIssueManuallyAsync(Guid id, string actorName, string? notes = null, CancellationToken cancellationToken = default)
    {
        var issue = await _db.ProjectIssues
            .Include(i => i.Project)
            .FirstOrDefaultAsync(i => i.Id == id, cancellationToken);

        if (issue == null)
        {
            throw new InvalidOperationException($"Issue with ID {id} not found.");
        }

        if (issue.EscalationLevel >= 6)
        {
            throw new InvalidOperationException("Issue is already at the maximum escalation level (CEO).");
        }

        int nextLevel = issue.EscalationLevel + 1;
        string nextRole = EscalationRoles[nextLevel];
        var now = DateTime.UtcNow;

        var audit = DeserializeAudit(issue.AuditHistoryJson);
        audit.Add(new IssueAuditEntry(
            Action: "ManualEscalation",
            Details: $"Issue manually escalated from Level {issue.EscalationLevel} ({issue.CurrentAssigneeRole}) to Level {nextLevel} ({nextRole}) by {actorName}" +
                     (!string.IsNullOrWhiteSpace(notes) ? $". Notes: {notes}" : ""),
            TimestampUtc: now,
            ActorName: actorName
        ));

        issue.EscalationLevel = nextLevel;
        issue.CurrentAssigneeRole = nextRole;
        issue.LastEscalatedAtUtc = now;
        issue.AuditHistoryJson = JsonSerializer.Serialize(audit, JsonOptions);

        await AssignTargetEmployeeForLevelAsync(issue, nextLevel, cancellationToken);
        await _db.SaveChangesAsync(cancellationToken);

        return MapToResponse(issue, issue.Project?.Name ?? "Project", issue.Project?.ProjectCode ?? "", audit);
    }

    private async Task<bool> CheckAndApplyAutoEscalationAsync(ProjectIssue issue, CancellationToken cancellationToken)
    {
        if (issue.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) ||
            issue.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        double totalElapsedDays = (DateTime.UtcNow - issue.CreatedAtUtc).TotalDays;
        int targetLevel = Math.Clamp(1 + (int)(totalElapsedDays / 2.0), 1, 6);

        if (targetLevel <= issue.EscalationLevel)
        {
            return false;
        }

        var audit = DeserializeAudit(issue.AuditHistoryJson);
        var now = DateTime.UtcNow;

        for (int lvl = issue.EscalationLevel + 1; lvl <= targetLevel; lvl++)
        {
            string prevRole = EscalationRoles[lvl - 1];
            string newRole = EscalationRoles[lvl];

            audit.Add(new IssueAuditEntry(
                Action: "AutoEscalation",
                Details: $"Auto-escalated to Level {lvl} ({newRole}) because issue remained unresolved for 2 days at Level {lvl - 1} ({prevRole}).",
                TimestampUtc: now,
                ActorName: "System (SLA Escalation Engine)"
            ));
        }

        issue.EscalationLevel = targetLevel;
        issue.CurrentAssigneeRole = EscalationRoles[targetLevel];
        issue.LastEscalatedAtUtc = now;
        issue.AuditHistoryJson = JsonSerializer.Serialize(audit, JsonOptions);

        await AssignTargetEmployeeForLevelAsync(issue, targetLevel, cancellationToken);
        return true;
    }

    private async Task AssignTargetEmployeeForLevelAsync(ProjectIssue issue, int level, CancellationToken cancellationToken)
    {
        switch (level)
        {
            case 1: // PM
                issue.CurrentAssigneeRole = "PM";
                issue.CurrentAssigneeName = issue.DottedLineManagerName ?? "Project Manager";
                issue.CurrentAssigneeEmployeeId = issue.DottedLineManagerId;
                break;

            case 2: // SPM
                issue.CurrentAssigneeRole = "SPM";
                var spm = await _db.Employees
                    .FirstOrDefaultAsync(e => e.Role != null && (e.Role.Contains("Senior Project Manager") || e.Role.Contains("SPM")), cancellationToken);
                issue.CurrentAssigneeName = spm != null ? $"{spm.FirstName} {spm.LastName}".Trim() : "Senior Project Manager";
                issue.CurrentAssigneeEmployeeId = spm?.Id;
                break;

            case 3: // EM
                issue.CurrentAssigneeRole = "EM";
                var em = issue.Project?.EngagementManagerRef ?? await _db.Employees
                    .FirstOrDefaultAsync(e => e.Role != null && (e.Role.Contains("Engagement Manager") || e.Role.Contains("EM")), cancellationToken);
                issue.CurrentAssigneeName = em != null ? $"{em.FirstName} {em.LastName}".Trim() : (issue.Project?.EngagementManager ?? "Engagement Manager");
                issue.CurrentAssigneeEmployeeId = em?.Id;
                break;

            case 4: // PMO
                issue.CurrentAssigneeRole = "PMO";
                var pmo = await _db.Employees
                    .FirstOrDefaultAsync(e => e.Role != null && (e.Role.Contains("PMO") || e.Role.Contains("Program Management")), cancellationToken);
                issue.CurrentAssigneeName = pmo != null ? $"{pmo.FirstName} {pmo.LastName}".Trim() : "PMO Department Head";
                issue.CurrentAssigneeEmployeeId = pmo?.Id;
                break;

            case 5: // HOD
                issue.CurrentAssigneeRole = "HOD";
                var hod = await _db.Employees
                    .FirstOrDefaultAsync(e => e.Role != null && (e.Role.Contains("Head of Department") || e.Role.Contains("HOD") || e.Role.Contains("Director")), cancellationToken);
                issue.CurrentAssigneeName = hod != null ? $"{hod.FirstName} {hod.LastName}".Trim() : "Head of Department (HOD)";
                issue.CurrentAssigneeEmployeeId = hod?.Id;
                break;

            case 6: // CEO
                issue.CurrentAssigneeRole = "CEO";
                var ceo = await _db.Employees
                    .FirstOrDefaultAsync(e => e.Role != null && (e.Role.Contains("CEO") || e.Role.Contains("Chief Executive")), cancellationToken);
                issue.CurrentAssigneeName = ceo != null ? $"{ceo.FirstName} {ceo.LastName}".Trim() : "Chief Executive Officer (CEO)";
                issue.CurrentAssigneeEmployeeId = ceo?.Id;
                break;
        }
    }

    private static List<IssueAuditEntry> DeserializeAudit(string? json)
    {
        if (string.IsNullOrWhiteSpace(json)) return [];
        try
        {
            return JsonSerializer.Deserialize<List<IssueAuditEntry>>(json, JsonOptions) ?? [];
        }
        catch
        {
            return [];
        }
    }

    private static IssueResponse MapToResponse(
        ProjectIssue issue,
        string projectName,
        string projectCode,
        List<IssueAuditEntry> audit)
    {
        double elapsedDays = (DateTime.UtcNow - issue.CreatedAtUtc).TotalDays;
        double hoursUntilNext;

        if (issue.Status.Equals("Resolved", StringComparison.OrdinalIgnoreCase) ||
            issue.Status.Equals("Closed", StringComparison.OrdinalIgnoreCase) ||
            issue.EscalationLevel >= 6)
        {
            hoursUntilNext = 0;
        }
        else
        {
            var nextEscalationAt = issue.CreatedAtUtc.AddDays(issue.EscalationLevel * 2.0);
            hoursUntilNext = Math.Max(0, (nextEscalationAt - DateTime.UtcNow).TotalHours);
        }

        return new IssueResponse(
            Id: issue.Id,
            ProjectId: issue.ProjectId,
            ProjectName: projectName,
            ProjectCode: projectCode,
            Title: issue.Title,
            Description: issue.Description,
            Category: issue.Category,
            Priority: issue.Priority,
            Status: issue.Status,
            RaisedByEmployeeId: issue.RaisedByEmployeeId,
            RaisedByName: issue.RaisedByName,
            RaisedByRole: issue.RaisedByRole,
            EscalationLevel: issue.EscalationLevel,
            CurrentAssigneeRole: issue.CurrentAssigneeRole,
            CurrentAssigneeEmployeeId: issue.CurrentAssigneeEmployeeId,
            CurrentAssigneeName: issue.CurrentAssigneeName,
            DottedLineManagerId: issue.DottedLineManagerId,
            DottedLineManagerName: issue.DottedLineManagerName,
            DaysElapsed: Math.Round(elapsedDays, 2),
            HoursUntilNextEscalation: Math.Round(hoursUntilNext, 1),
            CreatedAtUtc: issue.CreatedAtUtc,
            LastEscalatedAtUtc: issue.LastEscalatedAtUtc,
            ResolvedAtUtc: issue.ResolvedAtUtc,
            ResolvedByName: issue.ResolvedByName,
            ResolutionNotes: issue.ResolutionNotes,
            AuditHistory: audit
        );
    }
}
