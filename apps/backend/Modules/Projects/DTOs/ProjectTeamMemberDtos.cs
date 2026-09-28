namespace PMS.API.Modules.Projects.DTOs;

public sealed record ProjectTeamMemberDto(
    Guid Id,
    Guid ProjectId,
    Guid EmployeeId,
    string EmployeeName,
    string EmployeeCode,
    string? EmployeeEmail,
    string? EmployeeRole,
    Guid? DepartmentId,
    string? Department,
    string? SubDepartment,
    DateOnly AllocationStartDate,
    DateOnly AllocationEndDate,
    string Billability,
    bool IsTeamLead,
    string ResourceType,
    bool IsShadowTeam,
    DateTime CreatedAtUtc,
    DateTime? UpdatedAtUtc);

/// <summary>Employee eligible for Project Team / Shadow Team Add Resource.</summary>
public sealed record ProjectTeamCandidateDto(
    Guid Id,
    string EmployeeCode,
    string FullName,
    string WorkEmail,
    string? Role,
    string? Designation,
    Guid? DepartmentId,
    string? Department,
    string? SubDepartment);

public sealed record CreateProjectTeamMemberRequest(
    Guid EmployeeId,
    DateOnly AllocationStartDate,
    DateOnly AllocationEndDate,
    string Billability = "Billable",
    bool IsTeamLead = false,
    string ResourceType = "Dedicated",
    bool IsShadowTeam = false);

public sealed record UpdateProjectTeamMemberRequest(
    DateOnly? AllocationStartDate = null,
    DateOnly? AllocationEndDate = null,
    string? Billability = null,
    bool? IsTeamLead = null,
    string? ResourceType = null);
