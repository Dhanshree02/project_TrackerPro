namespace PMS.API.Modules.Auth.DTOs;

/// <summary>
/// The signed-in person. The profile page reads this and never takes an employee id.
/// </summary>
public sealed record MeResponse(
    string Id,
    string Email,
    string Name,
    string? EmployeeId,
    string? EmployeeCode,
    string? Role,
    string? RoleId,
    bool MustChangePassword,
    string? Phone,
    string? Department,
    string? SubDepartment,
    string? Designation,
    string? ReportingManager,
    string? WorkLocation,
    string? Status);
