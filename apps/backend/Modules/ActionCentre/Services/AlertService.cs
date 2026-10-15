using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Services;

public class AlertService : IAlertService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public AlertService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<AlertDto>> GetAlertsAsync(AlertQueryParameters query, CancellationToken ct = default)
    {
        var dbQuery = _db.Alerts.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(query.Category) && query.Category != "all")
        {
            dbQuery = dbQuery.Where(a => a.Category == query.Category);
        }

        if (!string.IsNullOrWhiteSpace(query.Severity) && query.Severity != "all")
        {
            dbQuery = dbQuery.Where(a => a.Severity == query.Severity);
        }

        if (!string.IsNullOrWhiteSpace(query.Status) && query.Status != "all")
        {
            dbQuery = dbQuery.Where(a => a.Status == query.Status);
        }

        if (query.ProjectId.HasValue)
        {
            dbQuery = dbQuery.Where(a => a.ProjectId == query.ProjectId.Value);
        }

        if (query.ClientId.HasValue)
        {
            dbQuery = dbQuery.Where(a => a.ClientId == query.ClientId.Value);
        }

        if (!string.IsNullOrWhiteSpace(query.Search))
        {
            var term = query.Search.Trim().ToLower();
            dbQuery = dbQuery.Where(a =>
                a.Title.ToLower().Contains(term) ||
                a.AlertCode.ToLower().Contains(term) ||
                (a.ProjectName != null && a.ProjectName.ToLower().Contains(term)) ||
                (a.ClientName != null && a.ClientName.ToLower().Contains(term)));
        }

        var total = await dbQuery.CountAsync(ct);

        var page = query.Page < 1 ? 1 : query.Page;
        var pageSize = query.PageSize < 1 ? 50 : (query.PageSize > 100 ? 100 : query.PageSize);

        var items = await dbQuery
            .OrderByDescending(a => a.Severity == "Critical")
            .ThenByDescending(a => a.Severity == "High")
            .ThenByDescending(a => a.CreatedAtUtc)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(ct);

        var dtos = items.Select(MapToDto).ToList();

        return new PagedResult<AlertDto>(dtos, page, pageSize, total);
    }

    public async Task<AlertMetricsDto> GetAlertMetricsAsync(CancellationToken ct = default)
    {
        var activeAlerts = await _db.Alerts.AsNoTracking().ToListAsync(ct);

        var total = activeAlerts.Count;
        var open = activeAlerts.Count(a => a.Status == "Open");
        var critical = activeAlerts.Count(a => a.Severity == "Critical");
        var resolved = activeAlerts.Count(a => a.Status == "Resolved");
        var escalated = activeAlerts.Count(a => a.Category == "EscalationTatBreach" || (a.Severity == "Critical" && a.Status != "Resolved"));

        return new AlertMetricsDto(
            Total: total,
            Open: open,
            Critical: critical,
            Resolved: resolved,
            Escalated: escalated
        );
    }

    public async Task<AlertDto?> GetAlertByIdAsync(Guid id, CancellationToken ct = default)
    {
        var alert = await _db.Alerts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == id, ct);
        return alert != null ? MapToDto(alert) : null;
    }

    public async Task<AlertDto> AcknowledgeAlertAsync(Guid id, AcknowledgeAlertRequest request, CancellationToken ct = default)
    {
        var alert = await _db.Alerts.FirstOrDefaultAsync(a => a.Id == id, ct);
        if (alert == null)
        {
            throw new KeyNotFoundException($"Alert with ID {id} not found.");
        }

        var now = DateTime.UtcNow;
        var userName = _currentUser.Name ?? "User";
        var userId = _currentUser.UserId;

        alert.Status = "Acknowledged";
        alert.AcknowledgedAtUtc = now;
        alert.AcknowledgedByUserId = userId;
        alert.AcknowledgedByName = userName;
        alert.UpdatedAtUtc = now;

        var history = ParseAuditHistory(alert.AuditHistoryJson);
        history.Add(new AlertAuditEntry(
            Action: "Acknowledged",
            Details: string.IsNullOrWhiteSpace(request.Comment)
                ? $"Alert acknowledged by {userName}."
                : $"Alert acknowledged by {userName}. Comment: {request.Comment.Trim()}",
            TimestampUtc: now,
            ActorName: userName
        ));
        alert.AuditHistoryJson = JsonSerializer.Serialize(history, JsonOptions);

        await _db.SaveChangesAsync(ct);
        return MapToDto(alert);
    }

    public async Task<AlertDto> ResolveAlertAsync(Guid id, ResolveAlertRequest request, CancellationToken ct = default)
    {
        var alert = await _db.Alerts.FirstOrDefaultAsync(a => a.Id == id, ct);
        if (alert == null)
        {
            throw new KeyNotFoundException($"Alert with ID {id} not found.");
        }

        if (string.IsNullOrWhiteSpace(request.ResolutionDetails))
        {
            throw new ArgumentException("Resolution details are required to resolve an alert.");
        }

        var now = DateTime.UtcNow;
        var userName = _currentUser.Name ?? "User";
        var userId = _currentUser.UserId;

        alert.Status = "Resolved";
        alert.ResolutionDetails = request.ResolutionDetails.Trim();
        alert.ResolvedAtUtc = now;
        alert.ResolvedByUserId = userId;
        alert.ResolvedByName = userName;
        alert.UpdatedAtUtc = now;

        var history = ParseAuditHistory(alert.AuditHistoryJson);
        history.Add(new AlertAuditEntry(
            Action: "Resolved",
            Details: $"Alert resolved by {userName}. Notes: {request.ResolutionDetails.Trim()}",
            TimestampUtc: now,
            ActorName: userName
        ));
        alert.AuditHistoryJson = JsonSerializer.Serialize(history, JsonOptions);

        await _db.SaveChangesAsync(ct);
        return MapToDto(alert);
    }

    public async Task<BenchResourceSnapshotDto> CaptureBenchSnapshotAsync(string? timeSlot = null, CancellationToken ct = default)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var slot = timeSlot ?? DetermineCurrentTimeSlot();

        var employees = await _db.Employees
            .Include(e => e.Department)
            .AsNoTracking()
            .ToListAsync(ct);

        var activeAllocations = await _db.ProjectTeamMembers
            .AsNoTracking()
            .Where(ptm => ptm.AllocationStartDate <= today && ptm.AllocationEndDate >= today)
            .Select(ptm => ptm.EmployeeId)
            .Distinct()
            .ToListAsync(ct);

        var allocatedSet = activeAllocations.ToHashSet();

        var benchEmployees = employees
            .Where(e => e.BillableStatus == "Non-Billable" || !allocatedSet.Contains(e.Id))
            .ToList();

        var totalBench = benchEmployees.Count;
        var nonBillable = benchEmployees.Count(e => e.BillableStatus == "Non-Billable");
        var billable = totalBench - nonBillable;

        var deptBreakdown = benchEmployees
            .GroupBy(e => e.Department?.Name ?? (!string.IsNullOrWhiteSpace(e.Role) ? e.Role : "General"))
            .ToDictionary(g => g.Key, g => g.Count());

        var benchItems = benchEmployees.Select(e => new BenchEmployeeItemDto(
            Id: e.Id,
            EmployeeCode: e.EmployeeCode,
            Name: $"{e.FirstName} {e.LastName}".Trim(),
            Department: e.Department?.Name ?? e.Role ?? "Unassigned",
            Designation: e.Role ?? "Resource",
            Role: e.Role ?? "Employee",
            ReportingManagerName: null
        )).ToList();

        var existingSnapshot = _db.BenchResourceSnapshots.Local
            .FirstOrDefault(s => s.SnapshotDate == today && s.TimeSlot == slot)
            ?? await _db.BenchResourceSnapshots
                .FirstOrDefaultAsync(s => s.SnapshotDate == today && s.TimeSlot == slot, ct);

        if (existingSnapshot != null)
        {
            existingSnapshot.TotalBenchCount = totalBench;
            existingSnapshot.BillableCount = billable;
            existingSnapshot.NonBillableCount = nonBillable;
            existingSnapshot.DepartmentBreakdownJson = JsonSerializer.Serialize(deptBreakdown, JsonOptions);
            existingSnapshot.EmployeeListJson = JsonSerializer.Serialize(benchItems, JsonOptions);
            existingSnapshot.CreatedAtUtc = DateTime.UtcNow;
        }
        else
        {
            existingSnapshot = new BenchResourceSnapshot
            {
                Id = Guid.NewGuid(),
                SnapshotDate = today,
                TimeSlot = slot,
                TotalBenchCount = totalBench,
                BillableCount = billable,
                NonBillableCount = nonBillable,
                DepartmentBreakdownJson = JsonSerializer.Serialize(deptBreakdown, JsonOptions),
                EmployeeListJson = JsonSerializer.Serialize(benchItems, JsonOptions),
                CreatedAtUtc = DateTime.UtcNow
            };
            _db.BenchResourceSnapshots.Add(existingSnapshot);
        }

        // Also evaluate daily bench alert if bench count exceeds 0
        await UpsertBenchAlertAsync(today, slot, totalBench, ct);

        await _db.SaveChangesAsync(ct);

        return new BenchResourceSnapshotDto(
            Id: existingSnapshot.Id,
            SnapshotDate: existingSnapshot.SnapshotDate,
            TimeSlot: existingSnapshot.TimeSlot,
            TotalBenchCount: existingSnapshot.TotalBenchCount,
            BillableCount: existingSnapshot.BillableCount,
            NonBillableCount: existingSnapshot.NonBillableCount,
            DepartmentBreakdown: deptBreakdown,
            EmployeeList: benchItems,
            CreatedAtUtc: existingSnapshot.CreatedAtUtc
        );
    }

    public async Task<List<BenchResourceSnapshotDto>> GetBenchSnapshotsAsync(DateOnly? date = null, CancellationToken ct = default)
    {
        var targetDate = date ?? DateOnly.FromDateTime(DateTime.UtcNow);

        var snapshots = await _db.BenchResourceSnapshots
            .AsNoTracking()
            .Where(s => s.SnapshotDate == targetDate)
            .OrderBy(s => s.TimeSlot)
            .ToListAsync(ct);

        return snapshots.Select(s => new BenchResourceSnapshotDto(
            Id: s.Id,
            SnapshotDate: s.SnapshotDate,
            TimeSlot: s.TimeSlot,
            TotalBenchCount: s.TotalBenchCount,
            BillableCount: s.BillableCount,
            NonBillableCount: s.NonBillableCount,
            DepartmentBreakdown: JsonSerializer.Deserialize<Dictionary<string, int>>(s.DepartmentBreakdownJson, JsonOptions) ?? new(),
            EmployeeList: JsonSerializer.Deserialize<List<BenchEmployeeItemDto>>(s.EmployeeListJson, JsonOptions) ?? new(),
            CreatedAtUtc: s.CreatedAtUtc
        )).ToList();
    }

    public async Task<int> EvaluateAllAlertsAsync(CancellationToken ct = default)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var now = DateTime.UtcNow;
        int evaluatedCount = 0;

        // ----------------------------------------------------
        // A. Delivery TAT / SLA Breach
        // ----------------------------------------------------
        var ongoingProjects = await _db.Projects
            .Include(p => p.Client)
            .Include(p => p.ProjectManager)
            .AsNoTracking()
            .Where(p => p.Status != "completed" && p.Status != "cancelled" && p.EndDate.HasValue)
            .ToListAsync(ct);

        foreach (var proj in ongoingProjects)
        {
            var endDate = proj.EndDate!.Value;
            var isOverdue = endDate < today;
            var isApproaching = !isOverdue && endDate <= today.AddDays(2);

            if (isOverdue)
            {
                var created = await UpsertAlertAsync(new AlertUpsertModel(
                    Category: "DeliveryTatBreach",
                    Severity: "Critical",
                    Title: $"Delivery TAT Breach: Project {proj.Name} ({proj.ProjectCode}) Overdue",
                    Description: $"Project delivery deadline was breached on {endDate:yyyy-MM-dd}. Immediate PMO and EM intervention required.",
                    ProjectId: proj.Id,
                    ProjectName: proj.Name,
                    ClientId: proj.ClientId,
                    ClientName: proj.Client?.Name,
                    SourceEntity: "Project",
                    SourceEntityId: proj.Id.ToString(),
                    TriggerCondition: $"Project EndDate {endDate:yyyy-MM-dd} < Current Date {today:yyyy-MM-dd}",
                    OwnerEmployeeId: proj.ProjectManagerId ?? new Guid("00000000-0000-4000-8000-000000000040"),
                    OwnerName: proj.ProjectManager != null && !string.IsNullOrWhiteSpace(proj.ProjectManager.FirstName)
                        ? $"{proj.ProjectManager.FirstName} {proj.ProjectManager.LastName}".Trim()
                        : "Divya Rao"
                ), ct);
                if (created) evaluatedCount++;
            }
            else if (isApproaching)
            {
                var created = await UpsertAlertAsync(new AlertUpsertModel(
                    Category: "DeliveryTatBreach",
                    Severity: "High",
                    Title: $"Delivery SLA Approaching: Project {proj.Name} ({proj.ProjectCode})",
                    Description: $"Project delivery deadline is approaching in {(endDate.DayNumber - today.DayNumber)} day(s) on {endDate:yyyy-MM-dd}.",
                    ProjectId: proj.Id,
                    ProjectName: proj.Name,
                    ClientId: proj.ClientId,
                    ClientName: proj.Client?.Name,
                    SourceEntity: "Project",
                    SourceEntityId: proj.Id.ToString(),
                    TriggerCondition: $"Project EndDate {endDate:yyyy-MM-dd} approaching within 48 hours",
                    OwnerEmployeeId: proj.ProjectManagerId ?? new Guid("00000000-0000-4000-8000-000000000040"),
                    OwnerName: proj.ProjectManager != null && !string.IsNullOrWhiteSpace(proj.ProjectManager.FirstName)
                        ? $"{proj.ProjectManager.FirstName} {proj.ProjectManager.LastName}".Trim()
                        : "Divya Rao"
                ), ct);
                if (created) evaluatedCount++;
            }
        }

        // ----------------------------------------------------
        // B. Escalation & Issues Management TAT / SLA Breach
        // ----------------------------------------------------
        var openIssues = await _db.ProjectIssues
            .Include(i => i.Project)
            .AsNoTracking()
            .Where(i => i.Status == "Open" || i.Status == "In Progress")
            .ToListAsync(ct);

        foreach (var issue in openIssues)
        {
            var elapsedHours = (now - issue.CreatedAtUtc).TotalHours;
            var isSlaBreached = elapsedHours > 48.0 || issue.EscalationLevel >= 3 || issue.Priority == "Critical";

            if (isSlaBreached)
            {
                var severity = (issue.EscalationLevel >= 3 || issue.Priority == "Critical") ? "Critical" : "High";
                var created = await UpsertAlertAsync(new AlertUpsertModel(
                    Category: "EscalationTatBreach",
                    Severity: severity,
                    Title: $"Issue Escalation SLA Breach: {issue.Title}",
                    Description: $"Issue is unresolved after {Math.Round(elapsedHours, 1)} hours at Escalation Level {issue.EscalationLevel} ({issue.CurrentAssigneeRole}). Assigned to {issue.DottedLineManagerName ?? issue.CurrentAssigneeRole}.",
                    ProjectId: issue.ProjectId,
                    ProjectName: issue.Project?.Name,
                    ClientId: issue.Project?.ClientId,
                    ClientName: null,
                    SourceEntity: "ProjectIssue",
                    SourceEntityId: issue.Id.ToString(),
                    TriggerCondition: $"Issue open for {Math.Round(elapsedHours, 1)}h exceeding 48h SLA threshold at Level {issue.EscalationLevel}",
                    OwnerEmployeeId: issue.DottedLineManagerId ?? issue.CurrentAssigneeEmployeeId,
                    OwnerName: issue.DottedLineManagerName ?? issue.CurrentAssigneeName ?? "PM"
                ), ct);
                if (created) evaluatedCount++;
            }
        }

        // ----------------------------------------------------
        // C. Change Management TAT / SLA Breach
        // ----------------------------------------------------
        var pendingDrafts = await _db.ProjectDrafts
            .AsNoTracking()
            .Where(d => d.Status == "active")
            .ToListAsync(ct);

        foreach (var draft in pendingDrafts)
        {
            var elapsedHours = (now - draft.CreatedAtUtc).TotalHours;
            if (elapsedHours > 48.0)
            {
                var created = await UpsertAlertAsync(new AlertUpsertModel(
                    Category: "ChangeManagementTatBreach",
                    Severity: "High",
                    Title: $"Change Request SLA Breach: {draft.ProjectName}",
                    Description: $"Project change/draft '{draft.ProjectName}' has been pending action/conversion for {Math.Round(elapsedHours, 1)} hours (SLA: 48h).",
                    ProjectId: null,
                    ProjectName: draft.ProjectName,
                    ClientId: draft.ClientId,
                    ClientName: draft.ClientName,
                    SourceEntity: "ProjectDraft",
                    SourceEntityId: draft.Id.ToString(),
                    TriggerCondition: $"Project draft '{draft.ProjectName}' active for {Math.Round(elapsedHours, 1)} hours exceeding 48h SLA",
                    OwnerEmployeeId: null,
                    OwnerName: !string.IsNullOrWhiteSpace(draft.CreatedByName) ? draft.CreatedByName : "PMO / Approver"
                ), ct);
                if (created) evaluatedCount++;
            }
        }

        // ----------------------------------------------------
        // D. Daily On-Bench Resource Snapshot
        // ----------------------------------------------------
        var currentSlot = DetermineCurrentTimeSlot();
        await CaptureBenchSnapshotAsync(currentSlot, ct);

        // ----------------------------------------------------
        // E. Timesheet TAT / SLA Breach
        // ----------------------------------------------------
        var lastWeekStart = today.AddDays(-((int)today.DayOfWeek == 0 ? 7 : (int)today.DayOfWeek) - 6);

        var pendingWeeks = await _db.TimesheetWeeks
            .Include(w => w.Employee)
                .ThenInclude(e => e.ReportingManager)
            .AsNoTracking()
            .Where(w => w.WeekStart <= lastWeekStart && (w.Status == "draft" || w.Status == "Draft" || w.Status == "submitted" || w.Status == "Submitted"))
            .ToListAsync(ct);

        foreach (var week in pendingWeeks)
        {
            var empName = week.Employee != null ? $"{week.Employee.FirstName} {week.Employee.LastName}".Trim() : "Employee";
            if (string.Equals(week.Status, "Draft", StringComparison.OrdinalIgnoreCase))
            {
                // Unsubmitted timesheet breach
                var created = await UpsertAlertAsync(new AlertUpsertModel(
                    Category: "TimesheetTatBreach",
                    Severity: "Medium",
                    Title: $"Timesheet Submission Overdue: {empName}",
                    Description: $"Employee {empName} has not submitted the timesheet for week starting {week.WeekStart:yyyy-MM-dd}.",
                    ProjectId: null,
                    ProjectName: null,
                    ClientId: null,
                    ClientName: null,
                    SourceEntity: "TimesheetWeek",
                    SourceEntityId: week.Id.ToString(),
                    TriggerCondition: $"Timesheet unsubmitted past Monday submission deadline",
                    OwnerEmployeeId: week.EmployeeId,
                    OwnerName: empName
                ), ct);
                if (created) evaluatedCount++;
            }
            else if (string.Equals(week.Status, "Submitted", StringComparison.OrdinalIgnoreCase) && week.SubmittedAtUtc.HasValue)
            {
                var submittedElapsed = (now - week.SubmittedAtUtc.Value).TotalHours;
                if (submittedElapsed > 48.0)
                {
                    var mgrName = week.Employee?.ReportingManager != null && !string.IsNullOrWhiteSpace(week.Employee.ReportingManager.FirstName)
                        ? $"{week.Employee.ReportingManager.FirstName} {week.Employee.ReportingManager.LastName}".Trim()
                        : "Divya Rao";

                    var created = await UpsertAlertAsync(new AlertUpsertModel(
                        Category: "TimesheetTatBreach",
                        Severity: "High",
                        Title: $"Timesheet Approval SLA Breach: {empName}",
                        Description: $"Timesheet submitted by {empName} for week {week.WeekStart:yyyy-MM-dd} has been pending manager approval for {Math.Round(submittedElapsed, 1)} hours.",
                        ProjectId: null,
                        ProjectName: null,
                        ClientId: null,
                        ClientName: null,
                        SourceEntity: "TimesheetWeek",
                        SourceEntityId: week.Id.ToString(),
                        TriggerCondition: $"Timesheet approval pending > 48 hours",
                        OwnerEmployeeId: week.Employee?.ReportingManagerId ?? new Guid("00000000-0000-4000-8000-000000000040"),
                        OwnerName: mgrName
                    ), ct);
                    if (created) evaluatedCount++;
                }
            }
        }

        await _db.SaveChangesAsync(ct);
        return evaluatedCount;
    }

    private async Task<bool> UpsertAlertAsync(AlertUpsertModel model, CancellationToken ct)
    {
        // Check local change tracker first, then database
        var existing = _db.Alerts.Local
            .FirstOrDefault(a =>
                a.Category == model.Category &&
                a.SourceEntityId == model.SourceEntityId &&
                (a.Status == "Open" || a.Status == "Acknowledged" || a.Status == "InProgress"))
            ?? await _db.Alerts
                .FirstOrDefaultAsync(a =>
                    a.Category == model.Category &&
                    a.SourceEntityId == model.SourceEntityId &&
                    (a.Status == "Open" || a.Status == "Acknowledged" || a.Status == "InProgress"),
                    ct);

        if (existing != null)
        {
            // Update trigger and severity if changed, preserve lifecycle state
            existing.Title = model.Title;
            existing.Description = model.Description;
            existing.Severity = model.Severity;
            existing.TriggerCondition = model.TriggerCondition;
            existing.UpdatedAtUtc = DateTime.UtcNow;
            return false;
        }

        var prefix = model.Category switch
        {
            "DeliveryTatBreach" => "ALT-DEL",
            "EscalationTatBreach" => "ALT-ESC",
            "ChangeManagementTatBreach" => "ALT-CHG",
            "DailyOnBenchCount" => "ALT-BCH",
            "TimesheetTatBreach" => "ALT-TS",
            _ => "ALT-GEN"
        };

        var uniqueSuffix = Guid.NewGuid().ToString("N")[..6].ToUpperInvariant();
        var alertCode = $"{prefix}-{DateTime.UtcNow:yyyyMMdd}-{uniqueSuffix}";

        var now = DateTime.UtcNow;
        var initialAudit = new List<AlertAuditEntry>
        {
            new(
                Action: "Generated",
                Details: $"System alert generated automatically under BRD rule: {model.TriggerCondition}.",
                TimestampUtc: now,
                ActorName: "System Alert Engine"
            )
        };

        var newAlert = new Alert
        {
            Id = Guid.NewGuid(),
            AlertCode = alertCode,
            Title = model.Title,
            Description = model.Description,
            Category = model.Category,
            Severity = model.Severity,
            Status = "Open",
            ProjectId = model.ProjectId,
            ProjectName = model.ProjectName,
            ClientId = model.ClientId,
            ClientName = model.ClientName,
            SourceEntity = model.SourceEntity,
            SourceEntityId = model.SourceEntityId,
            TriggerCondition = model.TriggerCondition,
            OwnerEmployeeId = model.OwnerEmployeeId,
            OwnerName = model.OwnerName,
            AuditHistoryJson = JsonSerializer.Serialize(initialAudit, JsonOptions),
            CreatedAtUtc = now
        };

        _db.Alerts.Add(newAlert);
        return true;
    }

    private async Task UpsertBenchAlertAsync(DateOnly date, string slot, int totalBench, CancellationToken ct)
    {
        var existing = await _db.Alerts
            .FirstOrDefaultAsync(a =>
                a.Category == "DailyOnBenchCount" &&
                a.SourceEntityId == date.ToString("yyyy-MM-dd") &&
                (a.Status == "Open" || a.Status == "Acknowledged"),
                ct);

        if (existing != null)
        {
            existing.Title = $"Daily On-Bench Resources: {totalBench} Resources ({slot})";
            existing.Description = $"On-bench resource count captured at {slot} on {date:yyyy-MM-dd}. Current total on bench: {totalBench}.";
            existing.TriggerCondition = $"Captured at {slot} scheduled frequency";
            existing.UpdatedAtUtc = DateTime.UtcNow;
        }
        else
        {
            await UpsertAlertAsync(new AlertUpsertModel(
                Category: "DailyOnBenchCount",
                Severity: "Low",
                Title: $"Daily On-Bench Resources: {totalBench} Resources ({slot})",
                Description: $"On-bench resource count captured at {slot} on {date:yyyy-MM-dd}. Current total on bench: {totalBench}.",
                ProjectId: null,
                ProjectName: null,
                ClientId: null,
                ClientName: null,
                SourceEntity: "ResourcePool",
                SourceEntityId: date.ToString("yyyy-MM-dd"),
                TriggerCondition: $"Captured at {slot} scheduled frequency",
                OwnerEmployeeId: null,
                OwnerName: "PMO / Resource Manager"
            ), ct);
        }
    }

    private static string DetermineCurrentTimeSlot()
    {
        // Using Indian Standard Time (UTC+5:30) for BRD defined slots (10:30 AM, 2:30 PM, 6:30 PM)
        var istTime = DateTime.UtcNow.AddHours(5).AddMinutes(30);
        var hour = istTime.Hour;

        if (hour < 12) return "10:30 AM";
        if (hour < 16) return "02:30 PM";
        return "06:30 PM";
    }

    private static List<AlertAuditEntry> ParseAuditHistory(string json)
    {
        if (string.IsNullOrWhiteSpace(json)) return [];
        try
        {
            return JsonSerializer.Deserialize<List<AlertAuditEntry>>(json, JsonOptions) ?? [];
        }
        catch
        {
            return [];
        }
    }

    private static AlertDto MapToDto(Alert a)
    {
        return new AlertDto(
            Id: a.Id,
            AlertCode: a.AlertCode,
            Title: a.Title,
            Description: a.Description,
            Category: a.Category,
            Severity: a.Severity,
            Status: a.Status,
            ProjectId: a.ProjectId,
            ProjectName: a.ProjectName,
            ClientId: a.ClientId,
            ClientName: a.ClientName,
            SourceEntity: a.SourceEntity,
            SourceEntityId: a.SourceEntityId,
            TriggerCondition: a.TriggerCondition,
            OwnerEmployeeId: a.OwnerEmployeeId,
            OwnerName: a.OwnerName,
            ResolutionDetails: a.ResolutionDetails,
            AcknowledgedAtUtc: a.AcknowledgedAtUtc,
            AcknowledgedByName: a.AcknowledgedByName,
            ResolvedAtUtc: a.ResolvedAtUtc,
            ResolvedByName: a.ResolvedByName,
            AuditHistory: ParseAuditHistory(a.AuditHistoryJson),
            CreatedAtUtc: a.CreatedAtUtc
        );
    }

    private record AlertUpsertModel(
        string Category,
        string Severity,
        string Title,
        string Description,
        Guid? ProjectId,
        string? ProjectName,
        Guid? ClientId,
        string? ClientName,
        string SourceEntity,
        string SourceEntityId,
        string TriggerCondition,
        Guid? OwnerEmployeeId,
        string? OwnerName
    );
}
