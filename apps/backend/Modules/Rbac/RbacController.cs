using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Rbac;

[ApiController]
[Route("api/v1/rbac")]
public class RbacController(IRbacAccessService rbac, ICurrentUserService currentUser) : ControllerBase
{
    [HttpGet("user-access")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<UserAccessRow>>>> UserAccess(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<UserAccessRow>>.Ok(await rbac.ListUserAccessAsync(ct)));
    }

    [HttpPut("user-access")]
    public async Task<ActionResult<ApiResponse<bool>>> SetUserAccess([FromBody] SetUserAccessRequest request, CancellationToken ct)
    {
        await rbac.SetUserAccessAsync(request.UserId, request.RoleName, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpGet("roles")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<RbacRoleOption>>>> Roles(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<RbacRoleOption>>.Ok(await rbac.ListRolesAsync(ct)));
    }

    [HttpPost("matrix/reset")]
    public async Task<ActionResult<ApiResponse<bool>>> Reset([FromBody] ResetRbacMatrixRequest request, CancellationToken ct)
    {
        await rbac.ResetToDefaultAsync(request.RoleName, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpGet("matrix")]
    public async Task<ActionResult<ApiResponse<RbacMatrix>>> Matrix([FromQuery] string roleName, CancellationToken ct)
    {
        var name = string.IsNullOrWhiteSpace(roleName) ? currentUser.Role ?? "" : roleName;
        return Ok(ApiResponse<RbacMatrix>.Ok(await rbac.GetMatrixAsync(name, ct)));
    }

    [HttpPut("matrix")]
    public async Task<ActionResult<ApiResponse<bool>>> Save([FromBody] SaveRbacMatrixRequest request, CancellationToken ct)
    {
        await rbac.SaveAsync(request.RoleName, request.Items, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpGet("effective")]
    public async Task<ActionResult<ApiResponse<EffectiveAccessDto>>> Effective(CancellationToken ct)
    {
        var role = currentUser.Role ?? "";
        var permissions = await rbac.GetClaimsAsync(role, ct);
        return Ok(ApiResponse<EffectiveAccessDto>.Ok(new EffectiveAccessDto(role, permissions)));
    }
}

public sealed record EffectiveAccessDto(string Role, IReadOnlyList<string> Permissions);

public sealed class SaveRbacMatrixRequest
{
    public string RoleName { get; set; } = "";
    public List<RbacGrantUpdate> Items { get; set; } = [];
}

public sealed class ResetRbacMatrixRequest
{
    public string RoleName { get; set; } = "";
}

public sealed class SetUserAccessRequest
{
    public Guid UserId { get; set; }
    public string RoleName { get; set; } = "";
}
