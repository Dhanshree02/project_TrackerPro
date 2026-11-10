namespace PMS.API.Modules.Projects.DTOs;

public sealed record ExtensionApproverDto(
    Guid EmployeeId,
    string Name,
    string? EmployeeCode,
    string SubDepartment,
    string Status);

public sealed record ProjectExtensionRequestDto(
    Guid Id,
    Guid ProjectId,
    DateOnly CurrentEndDate,
    DateOnly RequestedEndDate,
    int ExtensionDays,
    string Reason,
    string Status,
    string RequestedByName,
    DateTime CreatedAtUtc,
    IReadOnlyList<ExtensionApproverDto> Approvers,
    string? ProjectName = null,
    string? ProjectCode = null,
    string? CommentsJson = null,
    string? HistoryJson = null);

public sealed record CreateProjectExtensionRequest(
    DateOnly RequestedEndDate,
    string Reason,
    IReadOnlyList<Guid> ApproverEmployeeIds);

public sealed record ApproveExtensionRequestDto(
    string? Comment);

public sealed record RejectExtensionRequestDto(
    string? Comment);

public sealed record TakeExtensionActionRequest(
    string Status,
    string? Comment);

public sealed record AddExtensionCommentRequest(
    string Text);

public sealed record PendingExtensionApprovalDto(
    Guid Id,
    Guid ProjectId,
    string ProjectName,
    string? ProjectCode,
    DateOnly CurrentEndDate,
    DateOnly RequestedEndDate,
    int ExtensionDays,
    string Reason,
    string Status,
    Guid? RequestedByEmployeeId,
    string RequestedByName,
    DateTime CreatedAtUtc,
    IReadOnlyList<ExtensionApproverDto> Approvers,
    string? CommentsJson = null,
    string? HistoryJson = null);
