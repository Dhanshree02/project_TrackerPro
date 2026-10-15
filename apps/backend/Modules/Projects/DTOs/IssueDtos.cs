using System.Text.Json.Serialization;

namespace PMS.API.Modules.Projects.DTOs;

public record IssueProjectOption(
    Guid Id,
    string Name,
    string ProjectCode
);

public record CreateIssueRequest(
    string ProjectId,
    string Title,
    string Description,
    string Category,
    string Priority,
    string? RaisedByEmployeeId = null,
    string? RaisedByName = null,
    string? RaisedByRole = null
);

public record UpdateIssueStatusRequest(
    string Status,
    string? ResolutionNotes = null,
    string? ActorName = null
);

public record IssueAuditEntry(
    string Action,
    string Details,
    DateTime TimestampUtc,
    string? ActorName = null
);

public record IssueResponse(
    Guid Id,
    Guid ProjectId,
    string ProjectName,
    string ProjectCode,
    string Title,
    string Description,
    string Category,
    string Priority,
    string Status,
    Guid? RaisedByEmployeeId,
    string RaisedByName,
    string RaisedByRole,
    int EscalationLevel,
    string CurrentAssigneeRole,
    Guid? CurrentAssigneeEmployeeId,
    string? CurrentAssigneeName,
    Guid? DottedLineManagerId,
    string? DottedLineManagerName,
    double DaysElapsed,
    double HoursUntilNextEscalation,
    DateTime CreatedAtUtc,
    DateTime? LastEscalatedAtUtc,
    DateTime? ResolvedAtUtc,
    string? ResolvedByName,
    string? ResolutionNotes,
    List<IssueAuditEntry> AuditHistory
);
