namespace PMS.API.Modules.ActionCentre.DTOs;

public record AlertAuditEntry(
    string Action,
    string Details,
    DateTime TimestampUtc,
    string? ActorName = null
);

public record AlertDto(
    Guid Id,
    string AlertCode,
    string Title,
    string Description,
    string Category,
    string Severity,
    string Status,
    Guid? ProjectId,
    string? ProjectName,
    Guid? ClientId,
    string? ClientName,
    string SourceEntity,
    string SourceEntityId,
    string TriggerCondition,
    Guid? OwnerEmployeeId,
    string? OwnerName,
    string? ResolutionDetails,
    DateTime? AcknowledgedAtUtc,
    string? AcknowledgedByName,
    DateTime? ResolvedAtUtc,
    string? ResolvedByName,
    List<AlertAuditEntry> AuditHistory,
    DateTime CreatedAtUtc
);

public record AlertMetricsDto(
    int Total,
    int Open,
    int Critical,
    int Resolved,
    int Escalated
);

public class AlertQueryParameters
{
    public string? Category { get; set; }
    public string? Severity { get; set; }
    public string? Status { get; set; }
    public Guid? ProjectId { get; set; }
    public Guid? ClientId { get; set; }
    public string? Search { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 50;
}

public record AcknowledgeAlertRequest(
    string? Comment = null
);

public record ResolveAlertRequest(
    string ResolutionDetails
);

public record BenchResourceSnapshotDto(
    Guid Id,
    DateOnly SnapshotDate,
    string TimeSlot,
    int TotalBenchCount,
    int BillableCount,
    int NonBillableCount,
    Dictionary<string, int> DepartmentBreakdown,
    List<BenchEmployeeItemDto> EmployeeList,
    DateTime CreatedAtUtc
);

public record BenchEmployeeItemDto(
    Guid Id,
    string EmployeeCode,
    string Name,
    string Department,
    string Designation,
    string Role,
    string? ReportingManagerName
);
