using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Auth.Services;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Modules.Auth.Controllers;

[ApiController]
[Route("api/v1/auth")]
public class AuthController(
    IAuthService authService,
    ICurrentUserService currentUser,
    LoginRateLimiter rateLimiter,
    IHttpContextAccessor httpContextAccessor,
    RefreshTokenCookie refreshCookie) : ControllerBase
{
    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<AuthResult>>> Login(LoginRequest request, CancellationToken ct)
    {
        if (!rateLimiter.Allow(ClientKey()))
        {
            return StatusCode(StatusCodes.Status429TooManyRequests,
                ApiResponse<AuthResult>.Fail("RATE_LIMITED", "Too many login attempts. Try again later."));
        }

        var result = await authService.LoginAsync(request, ct);
        rateLimiter.Reset(ClientKey());
        return Ok(ApiResponse<AuthResult>.Ok(result));
    }

    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<ActionResult<ApiResponse<AuthResult>>> Refresh(
        [FromBody] RefreshTokenRequest? request,
        CancellationToken ct)
    {
        // Prefer the HttpOnly cookie; keep the body token as a fallback so
        // existing clients keep working during the transition.
        var token = refreshCookie.Read(Request) ?? request?.RefreshToken;
        if (string.IsNullOrEmpty(token))
            throw new UnauthorizedException("Refresh token missing.");

        var result = await authService.RefreshAsync(new RefreshTokenRequest(token), ct);
        return Ok(ApiResponse<AuthResult>.Ok(result));
    }

    [HttpPut("change-password")]
    public async Task<IActionResult> ChangePassword(ChangePasswordRequest request, CancellationToken ct)
    {
        if (currentUser.UserId is not { } userId)
            return Unauthorized(ApiResponse<object>.Fail("UNAUTHORIZED", "Not authenticated."));

        await authService.ChangePasswordAsync(userId, request, ct);
        return NoContent();
    }

    private string ClientKey() =>
        httpContextAccessor.HttpContext?.Connection.RemoteIpAddress?.ToString() ?? "unknown";

    [HttpPost("logout")]
    [AllowAnonymous]
    public async Task<IActionResult> Logout(
        [FromBody] RefreshTokenRequest? request,
        CancellationToken ct)
    {
        // The cookie is the source of truth; the body token is a fallback.
        // Anonymous so logout still revokes the session even when the access
        // token has already expired.
        var token = refreshCookie.Read(Request) ?? request?.RefreshToken;
        if (!string.IsNullOrEmpty(token))
            await authService.LogoutAsync(token, ct);
        refreshCookie.Clear(Response);
        return NoContent();
    }

    [HttpGet("me")]
    public async Task<ActionResult<ApiResponse<UserProfileDto>>> Me(CancellationToken ct)
    {
        if (currentUser.UserId is not { } userId)
            return Unauthorized(ApiResponse<object>.Fail("UNAUTHORIZED", "Not authenticated."));

        var profile = await authService.GetProfileAsync(userId, ct);
        return profile is null
            ? Unauthorized(ApiResponse<object>.Fail("UNAUTHORIZED", "User no longer exists."))
            : Ok(ApiResponse<UserProfileDto>.Ok(profile));
    }
}
