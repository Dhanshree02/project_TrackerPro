using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Infrastructure.Persistence.Seeding;
using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Constants;

namespace PMS.API.Middleware;

/// <summary>
/// Development-only: treats unauthenticated requests as the seeded Admin user
/// with full permissions so the frontend can work without a live JWT session.
/// Remove or disable before production / M365 auth.
/// </summary>
public sealed class DevelopmentAuthBypassMiddleware(RequestDelegate next)
{
    private const string Scheme = "DevelopmentBypass";

    public async Task InvokeAsync(HttpContext context)
    {
        if (context.User.Identity?.IsAuthenticated != true)
        {
            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, DbSeeder.StableGuid("user-u15").ToString()),
                new(JwtRegisteredClaimNames.Email, "admin@acme.co"),
                new(ClaimTypes.Name, "Admin User"),
                new(ClaimTypes.Role, nameof(UserRole.Admin)),
            };

            foreach (var permission in RoleBaselines.For(nameof(UserRole.Admin)))
                claims.Add(new Claim(AuthClaimTypes.Permission, permission));

            context.User = new ClaimsPrincipal(new ClaimsIdentity(claims, Scheme));
        }

        await next(context);
    }
}
