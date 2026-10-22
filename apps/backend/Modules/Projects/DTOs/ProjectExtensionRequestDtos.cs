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
    IReadOnlyList<ExtensionApproverDto> Approvers);

public sealed record CreateProjectExtensionRequest(
    DateOnly RequestedEndDate,
    string Reason,
    IReadOnlyList<Guid> ApproverEmployeeIds);
