using System.IdentityModel.Tokens.Jwt;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Modules.Auth.Services;

namespace PMS.API.Middleware;

/// <summary>
/// When the access cookie has expired, rotate it from the refresh cookie and continue the request.
/// </summary>
public sealed class SessionRefreshMiddleware(
    RequestDelegate next,
    IOptions<JwtOptions> jwtOptions)
{
    public async Task InvokeAsync(HttpContext context, MicrosoftSignInService signIn)
    {
        if (context.User.Identity?.IsAuthenticated != true
            && !context.Request.Path.StartsWithSegments("/api/v1/auth/microsoft")
            && !context.Request.Path.StartsWithSegments("/api/v1/auth/login"))
        {
            var access = await signIn.TryRefreshAsync(context.Request, context.Response, context.RequestAborted);
            if (!string.IsNullOrWhiteSpace(access))
            {
                var principal = Validate(access);
                if (principal is not null)
                    context.User = principal;
            }
        }

        await next(context);
    }

    private System.Security.Claims.ClaimsPrincipal? Validate(string token)
    {
        var jwt = jwtOptions.Value;
        var handler = new JwtSecurityTokenHandler();
        try
        {
            return handler.ValidateToken(token, new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = jwt.Issuer,
                ValidateAudience = true,
                ValidAudience = jwt.Audience,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(jwt.SigningKey)),
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromMinutes(1),
                NameClaimType = System.Security.Claims.ClaimTypes.Name,
                RoleClaimType = System.Security.Claims.ClaimTypes.Role,
            }, out _);
        }
        catch
        {
            return null;
        }
    }
}
