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

    /// <summary>Creates a new role copied from an existing role.</summary>
    Task<RoleDto> CloneRoleAsync(Guid id, CloneRoleRequest request, CancellationToken ct = default);

    Task<IReadOnlyList<RolePermissionDto>> GetRolePermissionsAsync(Guid roleId, CancellationToken ct = default);

    Task<bool> UpdateRolePermissionsAsync(Guid roleId, IReadOnlyList<RolePermissionDto> permissions, CancellationToken ct = default);

    Task<bool> ResetRolePermissionsToDefaultAsync(Guid roleId, CancellationToken ct = default);

    // ---- Userwise Role Access ----

    Task<PagedResult<UserRoleAccessDto>> GetUserRoleAccessListAsync(
        int page,
        int perPage,
        string? search,
        string? department,
        CancellationToken ct = default);

    Task<UserRoleAccessDto?> UpdateUserRoleAccessAsync(Guid employeeId, Guid roleId, CancellationToken ct = default);

    Task<UserRoleAccessDto?> ResetUserRoleAccessAsync(Guid employeeId, CancellationToken ct = default);

    Task<int> ResetAllUserRoleAccessAsync(CancellationToken ct = default);

    Task<IReadOnlyDictionary<string, IReadOnlyList<RoleDto>>> GetDepartmentRolesAsync(CancellationToken ct = default);
}
