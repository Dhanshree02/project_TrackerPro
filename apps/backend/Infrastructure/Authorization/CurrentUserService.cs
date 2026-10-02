using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Infrastructure.Authorization;

/// <summary>
/// Resolves the authenticated user from the current HTTP request claims.
/// </summary>
public sealed class CurrentUserService(IHttpContextAccessor accessor) : ICurrentUserService
{
    private ClaimsPrincipal? Principal => accessor.HttpContext?.User;

    public Guid? UserId
    {
        get
        {
            var sub = Principal?.FindFirstValue(JwtRegisteredClaimNames.Sub)
                      ?? Principal?.FindFirstValue(ClaimTypes.NameIdentifier);
            return Guid.TryParse(sub, out var id) ? id : null;
        }
    }

    public string? Email => Principal?.FindFirstValue(JwtRegisteredClaimNames.Email);

    public string? Name => Principal?.FindFirstValue(ClaimTypes.Name);

    public string? Role => Principal?.FindFirstValue(ClaimTypes.Role);

    public IReadOnlyList<string> Permissions =>
        Principal?.FindAll(AuthClaimTypes.Permission).Select(c => c.Value).Distinct().ToList() ?? [];

    public bool HasPermission(string permission) => Permissions.Contains(permission);

    ClaimsPrincipal? ICurrentUserService.Principal => Principal;
}
