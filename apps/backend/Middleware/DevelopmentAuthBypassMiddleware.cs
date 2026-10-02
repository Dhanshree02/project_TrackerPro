using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Infrastructure.Persistence.Seeding;
using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Constants;

namespace PMS.API.Middleware;

/// <summary>
/// Development-only bypass: treats unauthenticated requests as the active user
/// selected in the frontend user-switcher dropdown (via X-User-Email / X-User-Role headers)
/// or defaults to Admin, with full permissions.
/// Production M365 authentication will replace this after full development.
/// </summary>
public sealed class DevelopmentAuthBypassMiddleware(RequestDelegate next)
{
    private const string Scheme = "DevelopmentBypass";

    public async Task InvokeAsync(HttpContext context)
    {
        if (context.User.Identity?.IsAuthenticated != true)
        {
            var email = context.Request.Headers["X-User-Email"].FirstOrDefault();
            var role = context.Request.Headers["X-User-Role"].FirstOrDefault();
            var userIdStr = context.Request.Headers["X-User-Id"].FirstOrDefault();

            if (string.IsNullOrWhiteSpace(email)) email = "admin@acme.co";
            if (string.IsNullOrWhiteSpace(role)) role = nameof(UserRole.Admin);

            Guid userId = Guid.TryParse(userIdStr, out var parsedId)
                ? parsedId
                : DbSeeder.StableGuid($"user-{email}");

            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, userId.ToString()),
                new(JwtRegisteredClaimNames.Email, email),
                new(ClaimTypes.Name, email.Split('@')[0]),
                new(ClaimTypes.Role, role),
            };

            // Grant baseline permissions for the active role (or Admin baseline as fallback)
            var permissions = RoleBaselines.For(role);
            if (permissions.Count == 0)
                permissions = RoleBaselines.For(nameof(UserRole.Admin));

            foreach (var permission in permissions)
                claims.Add(new Claim(AuthClaimTypes.Permission, permission));

            context.User = new ClaimsPrincipal(new ClaimsIdentity(claims, Scheme));
        }

        await next(context);
    }
}
