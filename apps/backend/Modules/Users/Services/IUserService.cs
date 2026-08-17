using PMS.API.Modules.Users.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Users.Services;

public interface IUserService
{
    Task<PagedResult<UserDto>> GetUsersAsync(
        int page,
        int perPage,
        string? search,
        string? role,
        CancellationToken ct = default);

    Task<UserDto?> GetUserAsync(Guid id, CancellationToken ct = default);

    Task<UserDto> CreateUserAsync(CreateUserRequest request, CancellationToken ct = default);

    Task<UserDto?> UpdateUserAsync(Guid id, UpdateUserRequest request, CancellationToken ct = default);

    /// <summary>Resets a user's password (admin) — sets MustChangePassword.</summary>
    Task<bool> ResetPasswordAsync(Guid id, ResetPasswordRequest request, CancellationToken ct = default);

    // ---- Role management ----

    Task<IReadOnlyList<RoleDto>> GetRolesAsync(CancellationToken ct = default);

    Task<RoleDto?> GetRoleAsync(Guid id, CancellationToken ct = default);

    /// <summary>Creates a role (optionally cloning another role's permission set).</summary>
    Task<RoleDto> CreateRoleAsync(CreateRoleRequest request, CancellationToken ct = default);

    /// <summary>Edits display name / description / active state. System roles cannot be deactivated.</summary>
    Task<RoleDto?> UpdateRoleAsync(Guid id, UpdateRoleRequest request, CancellationToken ct = default);

    /// <summary>Creates a new role with a copy of the source role's permission set.</summary>
    Task<RoleDto> CloneRoleAsync(Guid id, CloneRoleRequest request, CancellationToken ct = default);

    /// <summary>
    /// Replaces a role's permission set. Guards against dropping the last
    /// users:manage capability and records every grant/revoke in the audit log.
    /// </summary>
    Task<RoleDto?> UpdateRolePermissionsAsync(Guid id, UpdateRolePermissionsRequest request, CancellationToken ct = default);

    /// <summary>Restores a system role to its baseline permission matrix.</summary>
    Task<RoleDto?> ResetRolePermissionsAsync(Guid id, CancellationToken ct = default);

    // ---- Audit log ----

    Task<PagedResult<PermissionAuditDto>> GetPermissionAuditsAsync(
        int page,
        int perPage,
        Guid? roleId = null,
        CancellationToken ct = default);
}
