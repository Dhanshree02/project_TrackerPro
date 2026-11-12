using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Security.Claims;
using Hangfire.Dashboard;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;

namespace PMS.API.Infrastructure.Hangfire;

/// <summary>
/// Authorizes access to the Hangfire Dashboard at /hangfire.
/// Integrates with Project Compass PMS authentication and configurable RBAC roles.
/// </summary>
public sealed class HangfireDashboardAuthFilter(
    IWebHostEnvironment environment,
    HangfireOptions options) : IDashboardAuthorizationFilter
{
    private readonly HashSet<string> _authorizedRoles = new(
        options.AuthorizedRoles ?? ["Admin", "CEO", "CTO", "COO", "PMO", "IT Admin"],
        StringComparer.OrdinalIgnoreCase);

    private readonly HashSet<string> _authorizedEmails = new(
        options.AuthorizedEmails ?? [],
        StringComparer.OrdinalIgnoreCase);

    public bool Authorize(DashboardContext context)
    {
        var httpContext = context.GetHttpContext();
        if (httpContext == null)
        {
            return false;
        }

        // In Development, allow local developers accessing via loopback/localhost
        if (environment.IsDevelopment())
        {
            var remoteIp = httpContext.Connection.RemoteIpAddress;
            if (remoteIp == null || IPAddress.IsLoopback(remoteIp))
            {
                return true;
            }
        }

        var user = httpContext.User;
        if (user?.Identity?.IsAuthenticated != true)
        {
            return false;
        }

        // Check user email against configured authorized emails
        if (_authorizedEmails.Count > 0)
        {
            var email = user.FindFirstValue(ClaimTypes.Email)
                        ?? user.FindFirstValue(JwtRegisteredClaimNames.Email)
                        ?? user.FindFirstValue("email");

            if (!string.IsNullOrWhiteSpace(email) && _authorizedEmails.Contains(email))
            {
                return true;
            }
        }

        // Check user roles against configured authorized roles
        var userRoles = user.FindAll(c => c.Type == ClaimTypes.Role || c.Type == "role")
                            .Select(c => c.Value);

        if (userRoles.Any(r => _authorizedRoles.Contains(r)))
        {
            return true;
        }

        return false;
    }
}
