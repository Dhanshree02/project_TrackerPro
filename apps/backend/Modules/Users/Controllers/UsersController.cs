using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Shared.Constants;
using PMS.API.Modules.Users.Services;
using PMS.API.Modules.Users.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Users.Controllers;

[ApiController]
[Route("api/v1/users")]
[RequirePermission(Permissions.UsersManage)]
public class UsersController(IUserService users) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<PagedResult<UserDto>>>> List(
        [FromQuery] int page = 1,
        [FromQuery] int perPage = 20,
        [FromQuery] string? search = null,
        [FromQuery] string? role = null,
        CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        perPage = Math.Clamp(perPage, 1, 100);

        var result = await users.GetUsersAsync(page, perPage, search, role, ct);
        return Ok(ApiResponse<PagedResult<UserDto>>.Ok(result, new ApiMeta
        {
            Total = result.Total,
            Page = result.Page,
            PerPage = result.PerPage,
            TotalPages = result.TotalPages,
        }));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<UserDto>>> Get(Guid id, CancellationToken ct)
    {
        var user = await users.GetUserAsync(id, ct);
        return user is null ? NotFound(ApiResponse<UserDto>.Fail("NOT_FOUND", "User not found."))
            : Ok(ApiResponse<UserDto>.Ok(user));
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<UserDto>>> Create(CreateUserRequest request, CancellationToken ct)
    {
        var user = await users.CreateUserAsync(request, ct);
        return CreatedAtAction(nameof(Get), new { id = user.Id }, ApiResponse<UserDto>.Ok(user));
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ApiResponse<UserDto>>> Update(Guid id, UpdateUserRequest request, CancellationToken ct)
    {
        var user = await users.UpdateUserAsync(id, request, ct);
        return user is null ? NotFound(ApiResponse<UserDto>.Fail("NOT_FOUND", "User not found."))
            : Ok(ApiResponse<UserDto>.Ok(user));
    }

    [HttpPut("{id:guid}/reset-password")]
    public async Task<IActionResult> ResetPassword(Guid id, ResetPasswordRequest request, CancellationToken ct)
    {
        var reset = await users.ResetPasswordAsync(id, request, ct);
        return reset ? NoContent() : NotFound(ApiResponse<object>.Fail("NOT_FOUND", "User not found."));
    }
}

[ApiController]
[Route("api/v1/roles")]
[RequirePermission(Permissions.UsersManage)]
public class RolesController(IUserService users) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<RoleDto>>>> List(CancellationToken ct)
    {
        var roles = await users.GetRolesAsync(ct);
        return Ok(ApiResponse<IReadOnlyList<RoleDto>>.Ok(roles));
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ApiResponse<RoleDto>>> Get(Guid id, CancellationToken ct)
    {
        var role = await users.GetRoleAsync(id, ct);
        return role is null ? NotFound(ApiResponse<RoleDto>.Fail("NOT_FOUND", "Role not found."))
            : Ok(ApiResponse<RoleDto>.Ok(role));
    }

    [HttpPost]
    [RequirePermission(Permissions.RolesManage)]
    public async Task<ActionResult<ApiResponse<RoleDto>>> Create(CreateRoleRequest request, CancellationToken ct)
    {
        var role = await users.CreateRoleAsync(request, ct);
        return CreatedAtAction(nameof(Get), new { id = role.Id }, ApiResponse<RoleDto>.Ok(role));
    }

    [HttpPut("{id:guid}")]
    [RequirePermission(Permissions.RolesManage)]
    public async Task<ActionResult<ApiResponse<RoleDto>>> Update(Guid id, UpdateRoleRequest request, CancellationToken ct)
    {
        var role = await users.UpdateRoleAsync(id, request, ct);
        return role is null ? NotFound(ApiResponse<RoleDto>.Fail("NOT_FOUND", "Role not found."))
            : Ok(ApiResponse<RoleDto>.Ok(role));
    }

    [HttpPost("{id:guid}/clone")]
    [RequirePermission(Permissions.RolesManage)]
    public async Task<ActionResult<ApiResponse<RoleDto>>> Clone(Guid id, CloneRoleRequest request, CancellationToken ct)
    {
        var role = await users.CloneRoleAsync(id, request, ct);
        return CreatedAtAction(nameof(Get), new { id = role.Id }, ApiResponse<RoleDto>.Ok(role));
    }

    [HttpPut("{id:guid}/permissions")]
    [RequirePermission(Permissions.RolesManage)]
    public async Task<ActionResult<ApiResponse<RoleDto>>> UpdatePermissions(
        Guid id,
        UpdateRolePermissionsRequest request,
        CancellationToken ct)
    {
        var role = await users.UpdateRolePermissionsAsync(id, request, ct);
        return role is null
            ? NotFound(ApiResponse<RoleDto>.Fail("NOT_FOUND", "Role not found."))
            : Ok(ApiResponse<RoleDto>.Ok(role));
    }

    [HttpPost("{id:guid}/reset-baseline")]
    [RequirePermission(Permissions.RolesManage)]
    public async Task<ActionResult<ApiResponse<RoleDto>>> ResetBaseline(Guid id, CancellationToken ct)
    {
        var role = await users.ResetRolePermissionsAsync(id, ct);
        return role is null
            ? NotFound(ApiResponse<RoleDto>.Fail("NOT_FOUND", "Role not found."))
            : Ok(ApiResponse<RoleDto>.Ok(role));
    }
}

[ApiController]
[Route("api/v1/permissions")]
[RequirePermission(Permissions.UsersManage)]
public class PermissionCatalogController : ControllerBase
{
    /// <summary>
    /// The module → submodule → action permission tree that drives the Settings →
    /// Role & Access Management UI. Centralised on the backend so the frontend
    /// never hard-codes the permission structure.
    /// </summary>
    [HttpGet("catalog")]
    public ActionResult<ApiResponse<IReadOnlyList<PermissionModuleDto>>> Catalog()
        => Ok(ApiResponse<IReadOnlyList<PermissionModuleDto>>.Ok(PermissionCatalogMapper.Map(PermissionCatalog.All)));
}

[ApiController]
[Route("api/v1/audit")]
[RequirePermission(Permissions.AuditRead)]
public class PermissionAuditController(IUserService users) : ControllerBase
{
    [HttpGet("permissions")]
    public async Task<ActionResult<ApiResponse<PagedResult<PermissionAuditDto>>>> List(
        [FromQuery] int page = 1,
        [FromQuery] int perPage = 50,
        [FromQuery] Guid? roleId = null,
        CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        perPage = Math.Clamp(perPage, 1, 200);

        var result = await users.GetPermissionAuditsAsync(page, perPage, roleId, ct);
        return Ok(ApiResponse<PagedResult<PermissionAuditDto>>.Ok(result, new ApiMeta
        {
            Total = result.Total,
            Page = result.Page,
            PerPage = result.PerPage,
            TotalPages = result.TotalPages,
        }));
    }
}
