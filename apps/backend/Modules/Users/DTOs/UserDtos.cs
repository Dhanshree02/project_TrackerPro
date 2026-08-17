using PMS.API.Shared.Constants;

namespace PMS.API.Modules.Users.DTOs;

public sealed record UserDto(
    Guid Id,
    string Email,
    string Name,
    string EmployeeId,
    string? Avatar,
    string? Department,
    string? SubDepartment,
    string? Designation,
    string? Role,                // role key, e.g. "Pmo"
    bool IsActive,
    bool MustChangePassword,
    DateTime? LastLoginAtUtc,
    DateTime CreatedAtUtc);

public sealed record RoleDto(
    Guid Id,
    string Name,
    string DisplayName,
    IReadOnlyList<string> Permissions,
    string? Description,
    bool IsSystemRole,
    bool IsActive,
    int UserCount);

public sealed record CreateUserRequest(
    string Email,
    string Name,
    string EmployeeId,
    string Role,                  // role key, e.g. "Pmo"
    string? Avatar,
    string? Department,
    string? SubDepartment,
    string? Designation);

public sealed record UpdateUserRequest(
    string? Name,
    string? Avatar,
    string? Department,
    string? SubDepartment,
    string? Designation,
    string? Role,
    bool? IsActive);

public sealed record ResetPasswordRequest(string NewPassword);

public sealed record UpdateRolePermissionsRequest(IReadOnlyList<string> Permissions);

// ---- Role management (Settings → Role & Access Management) ----

public sealed record CreateRoleRequest(
    string Name,           // role key, e.g. "AdminOps"
    string DisplayName,
    string? Description,
    Guid? CloneFromRoleId); // optional — copies the source role's permission set

public sealed record UpdateRoleRequest(
    string? DisplayName,
    string? Description,
    bool? IsActive);

public sealed record CloneRoleRequest(
    string Name,
    string DisplayName,
    string? Description);

// ---- Permission catalogue (Settings UI) ----

public sealed record PermissionActionDto(string Key, string Label, IReadOnlyList<string> LegacyKeys);

public sealed record PermissionSubmoduleDto(string? Key, string Label, IReadOnlyList<PermissionActionDto> Actions);

public sealed record PermissionModuleDto(string Key, string Label, IReadOnlyList<PermissionSubmoduleDto> Submodules);

public static class PermissionCatalogMapper
{
    public static IReadOnlyList<PermissionModuleDto> Map(IEnumerable<PermissionModule> modules) =>
        modules.Select(m => new PermissionModuleDto(
            m.Key,
            m.Label,
            m.Submodules.Select(s => new PermissionSubmoduleDto(
                string.IsNullOrEmpty(s.Key) ? null : s.Key,
                s.Label,
                s.Actions.Select(a => new PermissionActionDto(a.Key, a.Label, a.LegacyKeys)).ToList()
            )).ToList()
        )).ToList();
}

// ---- Audit log ----

public sealed record PermissionAuditDto(
    Guid Id,
    Guid RoleId,
    string RoleName,
    string ModuleLabel,
    string? SubmoduleLabel,
    string PermissionKey,
    string ActionLabel,
    string ChangeType,
    string PreviousValue,
    string NewValue,
    string? ChangedByName,
    DateTime CreatedAtUtc);
