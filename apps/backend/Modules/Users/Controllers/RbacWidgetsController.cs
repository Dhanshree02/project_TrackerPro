using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Users.DTOs;
using PMS.API.Modules.Users.Services;

namespace PMS.API.Modules.Users.Controllers;

[ApiController]
[Route("api/v1/rbac")]
public class RbacWidgetsController(
    IRbacWidgetService rbacService,
    ICurrentUserService currentUser) : ControllerBase
{
    [HttpGet("catalog")]
    [HttpGet("catalog-tree")]
    public async Task<IActionResult> GetCatalogTree([FromQuery] Guid? roleId, CancellationToken ct)
    {
        var tree = await rbacService.GetCatalogTreeAsync(roleId, ct);
        return Ok(tree);
    }

    [HttpGet("roles/{roleId:guid}/permissions")]
    public async Task<IActionResult> GetRolePermissions(Guid roleId, CancellationToken ct)
    {
        var permissions = await rbacService.GetRolePermissionsAsync(roleId, ct);
        return Ok(permissions);
    }

    [HttpPut("roles/{roleId:guid}/permissions")]
    [HttpPut("roles/{roleId:guid}/widget-permissions")]
    public async Task<IActionResult> UpdateRolePermissions(
        Guid roleId,
        [FromBody] UpdateRoleWidgetPermissionsDto dto,
        CancellationToken ct)
    {
        await rbacService.UpdateRolePermissionsAsync(roleId, dto, currentUser.UserId, ct);
        return Ok(new { message = "Role permissions updated successfully." });
    }

    [HttpPost("roles/{roleId:guid}/reset-baseline")]
    [HttpPost("roles/{roleId:guid}/reset-widget-baseline")]
    public async Task<IActionResult> ResetRoleBaseline(Guid roleId, CancellationToken ct)
    {
        await rbacService.ResetRoleBaselineAsync(roleId, currentUser.UserId, ct);
        return Ok(new { message = "Role permissions reset to baseline successfully." });
    }

    [HttpGet("permissions/my")]
    public async Task<IActionResult> GetMyPermissions(
        [FromQuery] string? role,
        CancellationToken ct)
    {
        var targetRole = !string.IsNullOrWhiteSpace(role) ? role : (currentUser.Role ?? "Admin");
        var perms = await rbacService.GetEffectiveUserPermissionsAsync(targetRole, ct);

        var response = perms.ToDictionary(
            kv => kv.Key,
            kv => new { canView = kv.Value.CanView, canManage = kv.Value.CanManage }
        );

        return Ok(response);
    }
}
