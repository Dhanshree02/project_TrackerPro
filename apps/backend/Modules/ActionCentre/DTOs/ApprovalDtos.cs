namespace PMS.API.Modules.ActionCentre.DTOs;

public record ApprovalAuditEntry(
    string Action,
    string Details,
    DateTime TimestampUtc,
    string? ActorName = null
);

public record ApprovalRequestDto(
    Guid Id,
    string RequestCode,
    string ApprovalType,
    Guid? ProjectId,
    string? ProjectName,
    Guid? EmployeeId,
    string? EmployeeName,
    string? Department,
    string Title,
    string Description,
    Guid RequestedByEmployeeId,
    string RequestedByName,
    string RequestedByRole,
    string? AssignedApproverRole,
    Guid? AssignedApproverEmployeeId,
    string? AssignedApproverName,
    string Status,
    string Priority,
    string PayloadJson,
    string? DecisionNotes,
    DateTime? DecidedAtUtc,
    string? DecidedByName,
    List<ApprovalAuditEntry> AuditHistory,
    DateTime CreatedAtUtc
);

public class CreateApprovalRequestDto
{
    public string ApprovalType { get; set; } = string.Empty;
    public Guid? ProjectId { get; set; }
    public string? ProjectName { get; set; }
    public Guid? EmployeeId { get; set; }
    public string? EmployeeName { get; set; }
    public string? Department { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public Guid RequestedByEmployeeId { get; set; }
    public string RequestedByName { get; set; } = string.Empty;
    public string RequestedByRole { get; set; } = string.Empty;
    public string? AssignedApproverRole { get; set; }
    public Guid? AssignedApproverEmployeeId { get; set; }
    public string? AssignedApproverName { get; set; }
    public string Priority { get; set; } = "Medium";
    public string PayloadJson { get; set; } = "{}";
}

public record ApprovalActionRequest(
    string Action, // "Approve", "Reject", "RequestChanges", "Hold"
    string? DecisionNotes
);

public record ApprovalMetricsDto(
    int Total,
    int Pending,
    int Approved,
    int Rejected,
    int ScopeChanges,
    int LeadershipChanges,
    int Extensions
);

public class ApprovalQueryParameters
{
    public string? ApprovalType { get; set; }
    public string? Status { get; set; }
    public Guid? ProjectId { get; set; }
    public string? Department { get; set; }
    public string? Search { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 50;
}
