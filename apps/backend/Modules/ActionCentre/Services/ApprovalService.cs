using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Services;

public class ApprovalService : IApprovalService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private static readonly JsonSerializerOptions JsonOptions = new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public ApprovalService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<ApprovalRequestDto>> GetApprovalsAsync(ApprovalQueryParameters query, CancellationToken ct = default)
    {
        var dbQuery = _db.ApprovalRequests.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(query.ApprovalType) && query.ApprovalType != "all")
        {
            var type = query.ApprovalType.Trim();
            dbQuery = dbQuery.Where(a => a.ApprovalType.ToLower() == type.ToLower()
                || (type == "Scope Change" && a.ApprovalType == "ScopeChange")
                || (type == "Leadership Change" && a.ApprovalType == "LeadershipChange")
                || (type == "Project Extension" && a.ApprovalType == "ProjectExtension")
                || (type == "Timeline Extension Approval" && a.ApprovalType == "ProjectExtension")
                || (type == "Scope Change Approval" && a.ApprovalType == "ScopeChange")
                || (type == "Leadership Change Approval" && a.ApprovalType == "LeadershipChange"));
        }

        if (!string.IsNullOrWhiteSpace(query.Status) && query.Status != "all")
        {
            var status = query.Status.Trim();
            dbQuery = dbQuery.Where(a => a.Status.ToLower() == status.ToLower());
        }

        if (query.ProjectId.HasValue)
        {
            dbQuery = dbQuery.Where(a => a.ProjectId == query.ProjectId.Value);
        }

        if (!string.IsNullOrWhiteSpace(query.Department) && query.Department != "all")
        {
            dbQuery = dbQuery.Where(a => a.Department != null && a.Department.ToLower() == query.Department.Trim().ToLower());
        }

        if (!string.IsNullOrWhiteSpace(query.Search))
        {
            var term = query.Search.Trim().ToLower();
            dbQuery = dbQuery.Where(a =>
                a.Title.ToLower().Contains(term) ||
                a.RequestCode.ToLower().Contains(term) ||
                (a.ProjectName != null && a.ProjectName.ToLower().Contains(term)) ||
                a.RequestedByName.ToLower().Contains(term) ||
                (a.AssignedApproverName != null && a.AssignedApproverName.ToLower().Contains(term)));
        }

        var total = await dbQuery.CountAsync(ct);

        var page = query.Page <= 0 ? 1 : query.Page;
        var pageSize = query.PageSize <= 0 ? 50 : query.PageSize;

        var items = await dbQuery
            .OrderByDescending(a => a.CreatedAtUtc)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(ct);

        var dtos = items.Select(MapToDto).ToList();

        return new PagedResult<ApprovalRequestDto>(dtos, page, pageSize, total);
    }

    public async Task<ApprovalMetricsDto> GetMetricsAsync(CancellationToken ct = default)
    {
        var all = await _db.ApprovalRequests.AsNoTracking().ToListAsync(ct);

        return new ApprovalMetricsDto(
            Total: all.Count,
            Pending: all.Count(a => a.Status == "Pending"),
            Approved: all.Count(a => a.Status == "Approved"),
            Rejected: all.Count(a => a.Status == "Rejected"),
            ScopeChanges: all.Count(a => a.ApprovalType.Contains("Scope", StringComparison.OrdinalIgnoreCase)),
            LeadershipChanges: all.Count(a => a.ApprovalType.Contains("Leadership", StringComparison.OrdinalIgnoreCase)),
            Extensions: all.Count(a => a.ApprovalType.Contains("Extension", StringComparison.OrdinalIgnoreCase))
        );
    }

    public async Task<ApprovalRequestDto?> GetByIdAsync(Guid id, CancellationToken ct = default)
    {
        var entity = await _db.ApprovalRequests.AsNoTracking().FirstOrDefaultAsync(a => a.Id == id, ct);
        return entity == null ? null : MapToDto(entity);
    }

    public async Task<ApprovalRequestDto> CreateApprovalAsync(CreateApprovalRequestDto request, CancellationToken ct = default)
    {
        var prefix = request.ApprovalType switch
        {
            "ScopeChange" or "Scope Change" or "Scope Change Approval" => "APR-SCP",
            "LeadershipChange" or "Leadership Change" or "Leadership Change Approval" => "APR-LDR",
            "ProjectExtension" or "Timeline Extension" or "Timeline Extension Approval" => "APR-EXT",
            "ProfileChanges" => "APR-PRF",
            "CertificationValidation" => "APR-CRT",
            "ResourceAllocation" => "APR-RES",
            _ => "APR-REQ"
        };

        var dateTag = DateTime.UtcNow.ToString("yyyyMMdd");
        var randomHex = Guid.NewGuid().ToString("N")[..6].ToUpper();
        var requestCode = $"{prefix}-{dateTag}-{randomHex}";

        string? projectName = request.ProjectName;
        if (string.IsNullOrWhiteSpace(projectName) && request.ProjectId.HasValue)
        {
            var proj = await _db.Projects.AsNoTracking().FirstOrDefaultAsync(p => p.Id == request.ProjectId.Value, ct);
            if (proj != null) projectName = proj.Name;
        }

        var normalizedType = request.ApprovalType switch
        {
            "Scope Change" or "Scope Change Approval" => "ScopeChange",
            "Leadership Change" or "Leadership Change Approval" => "LeadershipChange",
            "Timeline Extension" or "Timeline Extension Approval" => "ProjectExtension",
            _ => request.ApprovalType
        };

        var audit = new List<ApprovalAuditEntry>
        {
            new("Submitted", $"Request submitted by {request.RequestedByName}.", DateTime.UtcNow, request.RequestedByName)
        };

        var entity = new ApprovalRequest
        {
            RequestCode = requestCode,
            ApprovalType = normalizedType,
            ProjectId = request.ProjectId,
            ProjectName = projectName,
            EmployeeId = request.EmployeeId,
            EmployeeName = request.EmployeeName,
            Department = request.Department,
            Title = request.Title,
            Description = request.Description,
            RequestedByEmployeeId = request.RequestedByEmployeeId,
            RequestedByName = request.RequestedByName,
            RequestedByRole = request.RequestedByRole,
            AssignedApproverRole = request.AssignedApproverRole,
            AssignedApproverEmployeeId = request.AssignedApproverEmployeeId,
            AssignedApproverName = request.AssignedApproverName,
            Status = "Pending",
            Priority = string.IsNullOrWhiteSpace(request.Priority) ? "Medium" : request.Priority,
            PayloadJson = string.IsNullOrWhiteSpace(request.PayloadJson) ? "{}" : request.PayloadJson,
            AuditHistoryJson = JsonSerializer.Serialize(audit, JsonOptions),
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.ApprovalRequests.Add(entity);
        await _db.SaveChangesAsync(ct);

        return MapToDto(entity);
    }

    public async Task<ApprovalRequestDto> TakeActionAsync(Guid id, ApprovalActionRequest actionRequest, CancellationToken ct = default)
    {
        var approval = await _db.ApprovalRequests.FirstOrDefaultAsync(a => a.Id == id, ct)
            ?? throw new KeyNotFoundException($"Approval request with ID {id} was not found.");

        if (string.IsNullOrWhiteSpace(actionRequest.DecisionNotes))
        {
            throw new ArgumentException("Decision notes are mandatory for every approval action.");
        }

        var newStatus = actionRequest.Action switch
        {
            "Approve" or "Approved" => "Approved",
            "Reject" or "Rejected" => "Rejected",
            "RequestChanges" or "Request Changes" => "RequestChanges",
            "Hold" => "Hold",
            _ => actionRequest.Action
        };

        var actorName = _currentUser.Email ?? _currentUser.UserId?.ToString() ?? "Approver";
        var actorId = _currentUser.UserId;
        var now = DateTime.UtcNow;

        approval.Status = newStatus;
        approval.DecisionNotes = actionRequest.DecisionNotes;
        approval.DecidedAtUtc = now;
        approval.DecidedByUserId = actorId;
        approval.DecidedByName = actorName;
        approval.UpdatedAtUtc = now;

        var auditList = ParseAuditHistory(approval.AuditHistoryJson);
        auditList.Add(new ApprovalAuditEntry(
            newStatus,
            $"Marked as {newStatus}. Notes: {actionRequest.DecisionNotes.Trim()}",
            now,
            actorName
        ));
        approval.AuditHistoryJson = JsonSerializer.Serialize(auditList, JsonOptions);

        // --- Execute Business Domain Effects on Approval ---
        if (newStatus == "Approved")
        {
            await ApplyApprovalEffectsAsync(approval, ct);
        }

        await _db.SaveChangesAsync(ct);

        return MapToDto(approval);
    }

    private async Task ApplyApprovalEffectsAsync(ApprovalRequest approval, CancellationToken ct)
    {
        try
        {
            using var doc = JsonDocument.Parse(approval.PayloadJson);
            var root = doc.RootElement;

            if (approval.ApprovalType == "ProjectExtension" && approval.ProjectId.HasValue)
            {
                // Extension: update Project.EndDate
                string? proposedEndDateStr = null;
                if (root.TryGetProperty("proposedEndDate", out var pEnd))
                {
                    proposedEndDateStr = pEnd.GetString();
                }
                else if (root.TryGetProperty("newEndDate", out var nEnd))
                {
                    proposedEndDateStr = nEnd.GetString();
                }

                if (!string.IsNullOrWhiteSpace(proposedEndDateStr) && DateOnly.TryParse(proposedEndDateStr, out var newDate))
                {
                    var proj = await _db.Projects.FirstOrDefaultAsync(p => p.Id == approval.ProjectId.Value, ct);
                    if (proj != null)
                    {
                        proj.EndDate = newDate;
                        proj.UpdatedAtUtc = DateTime.UtcNow;
                    }
                }
            }
            else if (approval.ApprovalType == "LeadershipChange" && approval.ProjectId.HasValue)
            {
                // Leadership Change: update Project Manager, Senior Project Manager, or Team Lead
                var proj = await _db.Projects.FirstOrDefaultAsync(p => p.Id == approval.ProjectId.Value, ct);
                if (proj != null)
                {
                    string? role = root.TryGetProperty("leadershipRole", out var rProp) ? rProp.GetString() : null;
                    role ??= root.TryGetProperty("role", out var rProp2) ? rProp2.GetString() : null;

                    string? targetIdStr = root.TryGetProperty("targetEmployeeId", out var tProp) ? tProp.GetString() : null;
                    targetIdStr ??= root.TryGetProperty("newLeaderId", out var tProp2) ? tProp2.GetString() : null;
                    if (string.IsNullOrWhiteSpace(targetIdStr) && root.TryGetProperty("newLeaderIds", out var nIdsProp) && nIdsProp.GetArrayLength() > 0)
                    {
                        targetIdStr = nIdsProp[0].GetString();
                    }

                    string? targetName = root.TryGetProperty("targetEmployeeName", out var tnProp) ? tnProp.GetString() : null;
                    targetName ??= root.TryGetProperty("newLeaderName", out var tnProp2) ? tnProp2.GetString() : null;

                    if (Guid.TryParse(targetIdStr, out var targetEmpId))
                    {
                        if (role == "ProjectManager" || role == "Project Manager")
                        {
                            proj.ProjectManagerId = targetEmpId;
                            // Also ensure ProjectTeamMember record has MemberRole = ProjectManager
                            var ptm = await _db.ProjectTeamMembers.FirstOrDefaultAsync(m => m.ProjectId == proj.Id && m.MemberRole == "ProjectManager", ct);
                            if (ptm != null)
                            {
                                ptm.EmployeeId = targetEmpId;
                                ptm.UpdatedAtUtc = DateTime.UtcNow;
                            }
                            else
                            {
                                _db.ProjectTeamMembers.Add(new ProjectTeamMember
                                {
                                    ProjectId = proj.Id,
                                    EmployeeId = targetEmpId,
                                    MemberRole = "ProjectManager",
                                    AllocationStartDate = proj.StartDate ?? DateOnly.FromDateTime(DateTime.UtcNow),
                                    AllocationEndDate = proj.EndDate ?? DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(3)),
                                    Billability = "Non-Billable",
                                    ResourceType = "Dedicated",
                                    IsShadowTeam = false
                                });
                            }
                        }
                        else if (role == "SeniorProjectManager" || role == "Senior Project Manager")
                        {
                            var ptm = await _db.ProjectTeamMembers.FirstOrDefaultAsync(m => m.ProjectId == proj.Id && m.MemberRole == "SeniorProjectManager", ct);
                            if (ptm != null)
                            {
                                ptm.EmployeeId = targetEmpId;
                                ptm.UpdatedAtUtc = DateTime.UtcNow;
                            }
                            else
                            {
                                _db.ProjectTeamMembers.Add(new ProjectTeamMember
                                {
                                    ProjectId = proj.Id,
                                    EmployeeId = targetEmpId,
                                    MemberRole = "SeniorProjectManager",
                                    AllocationStartDate = proj.StartDate ?? DateOnly.FromDateTime(DateTime.UtcNow),
                                    AllocationEndDate = proj.EndDate ?? DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(3)),
                                    Billability = "Non-Billable",
                                    ResourceType = "Dedicated",
                                    IsShadowTeam = false
                                });
                            }
                        }
                        else if (role == "TeamLead" || role == "Team Lead")
                        {
                            proj.TeamLeadId = targetEmpId;
                            // Set IsTeamLead on ProjectTeamMember
                            var teamMembers = await _db.ProjectTeamMembers.Where(m => m.ProjectId == proj.Id).ToListAsync(ct);
                            foreach (var member in teamMembers)
                            {
                                member.IsTeamLead = (member.EmployeeId == targetEmpId);
                            }
                        }
                        proj.UpdatedAtUtc = DateTime.UtcNow;
                    }
                }
            }
            else if (approval.ApprovalType == "ScopeChange" && approval.ProjectId.HasValue)
            {
                // Scope Change: scope cancellation or addition
                string? action = root.TryGetProperty("scopeAction", out var sProp) ? sProp.GetString() : null;
                string? serviceName = root.TryGetProperty("serviceName", out var snProp) ? snProp.GetString() : null;
                serviceName ??= root.TryGetProperty("scopeCancellationService", out var snProp2) ? snProp2.GetString() : null;

                if (action == "Cancellation" || !string.IsNullOrWhiteSpace(serviceName))
                {
                    var projService = await _db.ProjectServices.FirstOrDefaultAsync(
                        ps => ps.ProjectId == approval.ProjectId.Value && ps.ServiceName.ToLower() == serviceName!.ToLower(), ct);
                    if (projService != null)
                    {
                        projService.ValidationStatus = "Cancelled";
                        projService.UpdatedAtUtc = DateTime.UtcNow;
                    }
                }
            }
        }
        catch
        {
            // Do not fail the approval decision if payload parsing encounters non-critical schema variances
        }
    }

    private static ApprovalRequestDto MapToDto(ApprovalRequest a)
    {
        return new ApprovalRequestDto(
            Id: a.Id,
            RequestCode: a.RequestCode,
            ApprovalType: a.ApprovalType,
            ProjectId: a.ProjectId,
            ProjectName: a.ProjectName,
            EmployeeId: a.EmployeeId,
            EmployeeName: a.EmployeeName,
            Department: a.Department,
            Title: a.Title,
            Description: a.Description,
            RequestedByEmployeeId: a.RequestedByEmployeeId,
            RequestedByName: a.RequestedByName,
            RequestedByRole: a.RequestedByRole,
            AssignedApproverRole: a.AssignedApproverRole,
            AssignedApproverEmployeeId: a.AssignedApproverEmployeeId,
            AssignedApproverName: a.AssignedApproverName,
            Status: a.Status,
            Priority: a.Priority,
            PayloadJson: a.PayloadJson,
            DecisionNotes: a.DecisionNotes,
            DecidedAtUtc: a.DecidedAtUtc,
            DecidedByName: a.DecidedByName,
            AuditHistory: ParseAuditHistory(a.AuditHistoryJson),
            CreatedAtUtc: a.CreatedAtUtc
        );
    }

    private static List<ApprovalAuditEntry> ParseAuditHistory(string json)
    {
        if (string.IsNullOrWhiteSpace(json)) return [];
        try
        {
            return JsonSerializer.Deserialize<List<ApprovalAuditEntry>>(json, JsonOptions) ?? [];
        }
        catch
        {
            return [];
        }
    }
}
