namespace PMS.API.Modules.Projects.DTOs;

public record CreateResourceAllocationRequest(
    Guid EmployeeId,
    DateOnly AllocationStartDate,
    DateOnly AllocationEndDate,
    string Billability,
    string ResourceType,
    bool IsTeamLead = false,
    bool IsShadowTeam = false,
    string? Notes = null);

public record ResourceAllocationActionRequest(
    string Status,
    string? Comment = null);

public record ProjectResourceAllocationRequestDto(
    Guid Id,
    Guid ProjectId,
    string ProjectName,
    Guid EmployeeId,
    string EmployeeName,
    string? EmployeeCode,
    string? EmployeeRole,
    string? Department,
    string? SubDepartment,
    DateOnly AllocationStartDate,
    DateOnly AllocationEndDate,
    string Billability,
    string ResourceType,
    bool IsTeamLead,
    bool IsShadowTeam,
    string Status,
    Guid? RequestedByEmployeeId,
    string? RequestedByName,
    Guid? ApproverEmployeeId,
    string? ApproverName,
    string? CommentsJson,
    string? HistoryJson,
    DateTime CreatedAtUtc);
