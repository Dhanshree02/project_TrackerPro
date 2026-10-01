using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Users.DTOs;
using PMS.API.Modules.Users.Services;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.Users.Controllers;

[ApiController]
[Route("api/v1/rbac")]
public class RbacWidgetsController(IRbacWidgetService rbacService, ICurrentUserService currentUser, AppDbContext db) : ControllerBase
{
    /// <summary>
    /// Returns the full hierarchical Module -> Submodule -> Widget tree.
    /// If roleId is supplied, the nodes include that role's CanView and CanManage flags.
    /// </summary>
    [HttpGet("catalog-tree")]
    public async Task<ActionResult<ApiResponse<List<ModuleNodeDto>>>> GetCatalogTree(
        [FromQuery] Guid? roleId,
        CancellationToken ct)
    {
        var tree = await rbacService.GetCatalogTreeAsync(roleId, ct);
        return Ok(ApiResponse<List<ModuleNodeDto>>.Ok(tree));
    }

    /// <summary>
    /// Returns the flat list of widget permissions for a role.
    /// </summary>
    [HttpGet("roles/{roleId:guid}/widget-permissions")]
    public async Task<ActionResult<ApiResponse<List<RoleWidgetPermissionDto>>>> GetRolePermissions(
        Guid roleId,
        CancellationToken ct)
    {
        var perms = await rbacService.GetRoleWidgetPermissionsAsync(roleId, ct);
        return Ok(ApiResponse<List<RoleWidgetPermissionDto>>.Ok(perms));
    }

    /// <summary>
    /// Bulk updates 1/0 View and Manage permissions for a role.
    /// </summary>
    [HttpPut("roles/{roleId:guid}/widget-permissions")]
    [RequirePermission(Permissions.RolesManage)]
    public async Task<ActionResult<ApiResponse<bool>>> UpdateRolePermissions(
        Guid roleId,
        [FromBody] UpdateRoleWidgetPermissionsRequest request,
        CancellationToken ct)
    {
        await rbacService.UpdateRoleWidgetPermissionsAsync(roleId, request, currentUser.UserId, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    /// <summary>
    /// Resets all 49 widget permissions of a role to baseline defaults.
    /// </summary>
    [HttpPost("roles/{roleId:guid}/reset-widget-baseline")]
    [RequirePermission(Permissions.RolesManage)]
    public async Task<ActionResult<ApiResponse<bool>>> ResetBaseline(
        Guid roleId,
        CancellationToken ct)
    {
        await rbacService.ResetRoleToBaselineAsync(roleId, currentUser.UserId, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    /// <summary>
    /// Returns the widget permissions map: { [widgetKey]: { v, m } } for the active user or requested role.
    /// </summary>
    [HttpGet("my-permissions")]
    public async Task<ActionResult<ApiResponse<Dictionary<string, object>>>> GetMyPermissions(
        [FromQuery] Guid? roleId,
        [FromQuery] string? role,
        CancellationToken ct)
    {
        var targetRoleId = roleId;
        if (!targetRoleId.HasValue && !string.IsNullOrWhiteSpace(role))
        {
            var rTrim = role.Trim();
            targetRoleId = await db.Roles
                .Where(r => r.Name.ToLower() == rTrim.ToLower() || r.DisplayName.ToLower() == rTrim.ToLower())
                .Select(r => (Guid?)r.Id)
                .FirstOrDefaultAsync(ct);
        }

        if (!targetRoleId.HasValue)
        {
            targetRoleId = currentUser.RoleId;
        }

        if (!targetRoleId.HasValue && currentUser.UserId.HasValue)
        {
            targetRoleId = await db.Users
                .Where(u => u.Id == currentUser.UserId.Value)
                .Select(u => u.RoleId)
                .FirstOrDefaultAsync(ct);
        }

        if (!targetRoleId.HasValue)
        {
            return Ok(ApiResponse<Dictionary<string, object>>.Ok([]));
        }

        var map = await rbacService.GetRoleWidgetMapAsync(targetRoleId.Value, ct);
        var formatted = map.ToDictionary(
            kv => kv.Key,
            kv => (object)new { v = kv.Value.v, m = kv.Value.m });

        return Ok(ApiResponse<Dictionary<string, object>>.Ok(formatted));
    }
}
