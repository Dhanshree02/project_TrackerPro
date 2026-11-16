using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Infrastructure.Persistence.Seeding;
using PMS.API.Modules.Users.Models;

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
            var roleHeader = context.Request.Headers["X-User-Role"].FirstOrDefault();
            var userIdStr = context.Request.Headers["X-User-Id"].FirstOrDefault();

            if (string.IsNullOrWhiteSpace(email)) email = "admin@talakunchi.com";

            var db = context.RequestServices.GetRequiredService<AppDbContext>();
            var normalizedEmail = email.Trim().ToLowerInvariant();

            // Try to resolve matching Employee in resource.tbl_employees to ensure userId matches Employee.Id
            PMS.API.Modules.Resources.Models.Employee? matchingEmp = null;
            if (Guid.TryParse(userIdStr, out var parsedGuid))
            {
                matchingEmp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e => e.Id == parsedGuid && e.DeletedAtUtc == null);
            }
            if (matchingEmp == null)
            {
                matchingEmp = await db.Employees.AsNoTracking().FirstOrDefaultAsync(e =>
                    e.DeletedAtUtc == null && (
                        (e.WorkEmail != null && e.WorkEmail.ToLower() == normalizedEmail) ||
                        (e.PersonalEmail != null && e.PersonalEmail.ToLower() == normalizedEmail) ||
                        (!string.IsNullOrWhiteSpace(userIdStr) && e.EmployeeCode.ToLower() == userIdStr.ToLower()) ||
                        normalizedEmail.Contains(e.EmployeeCode.ToLower())
                    ));
            }

            string role = roleHeader ?? string.Empty;
            if (string.IsNullOrWhiteSpace(role))
            {
                var accessRole = await db.Users.AsNoTracking()
                    .Where(u => u.Email.ToLower() == normalizedEmail && u.Role != null)
                    .Select(u => u.Role!.Name)
                    .FirstOrDefaultAsync();
                if (!string.IsNullOrWhiteSpace(accessRole)) role = accessRole;
                else if (matchingEmp?.Role != null) role = matchingEmp.Role;
            }

            if (string.IsNullOrWhiteSpace(role)) role = nameof(UserRole.Admin);

            Guid userId = matchingEmp?.Id ?? (Guid.TryParse(userIdStr, out var parsedId)
                ? parsedId
                : DbSeeder.StableGuid($"user-{email}"));

            var claims = new List<Claim>
            {
                new(JwtRegisteredClaimNames.Sub, userId.ToString()),
                new(JwtRegisteredClaimNames.Email, email),
                new(ClaimTypes.Email, email),
                new(ClaimTypes.Name, email.Split('@')[0]),
                new(ClaimTypes.Role, role),
            };

            context.User = new ClaimsPrincipal(new ClaimsIdentity(claims, Scheme));
        }

        await next(context);
    }
}
