using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Persistence.Seeding;
using PMS.API.Modules.Rbac;
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

            if (string.IsNullOrWhiteSpace(email)) email = "admin@talakunchi.com";
            if (string.IsNullOrWhiteSpace(role)) role = nameof(UserRole.Admin);

            // User Role Access stores a temporary access role on the login account.
            // That role decides what they can open. It is not their resource profile.
            var db = context.RequestServices.GetRequiredService<AppDbContext>();
            var normalized = email.Trim().ToLowerInvariant();
            var accessRole = await db.Users.AsNoTracking()
                .Where(u => u.Email.ToLower() == normalized && u.Role != null)
                .Select(u => u.Role!.Name)
                .FirstOrDefaultAsync();
            if (!string.IsNullOrWhiteSpace(accessRole)) role = accessRole;

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

            var rbac = context.RequestServices.GetRequiredService<IRbacAccessService>();
            var permissions = await rbac.GetClaimsAsync(role);
            if (permissions.Count == 0)
                permissions = RoleBaselines.For(nameof(UserRole.Admin));

            foreach (var permission in permissions)
                claims.Add(new Claim(AuthClaimTypes.Permission, permission));

            context.User = new ClaimsPrincipal(new ClaimsIdentity(claims, Scheme));
        }

        await next(context);
    }
}
