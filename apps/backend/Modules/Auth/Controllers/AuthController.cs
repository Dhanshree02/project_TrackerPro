using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Modules.Auth.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Auth.Controllers;

[ApiController]
[Route("api/v1/auth")]
public class AuthController(MicrosoftSignInService signIn) : ControllerBase
{
    [AllowAnonymous]
    [HttpGet("microsoft/start")]
    public IActionResult Start()
    {
        var url = signIn.CreateAuthorizeRedirect(Response);
        if (url is null)
            return Redirect(signIn.LoginRedirect("not_configured"));
        return Redirect(url);
    }

    [AllowAnonymous]
    [HttpGet("microsoft/callback")]
    public async Task<IActionResult> Callback(
        [FromQuery] string? code,
        [FromQuery] string? state,
        [FromQuery] string? error,
        CancellationToken ct)
    {
        var destination = await signIn.CompleteAsync(Request, Response, code, state, error, ct);
        return Redirect(destination);
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<ActionResult<ApiResponse<MeResponse>>> Login(
        [FromBody] PasswordLoginRequest body,
        CancellationToken ct)
    {
        var me = await signIn.LoginWithPasswordAsync(Response, body.Email, body.Password, ct);
        return me is null
            ? Unauthorized(ApiResponse<MeResponse>.Fail("INVALID_CREDENTIALS", "Invalid email or password."))
            : Ok(ApiResponse<MeResponse>.Ok(me));
    }

    [AllowAnonymous]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout(CancellationToken ct)
    {
        await signIn.LogoutAsync(Request, Response, ct);
        return NoContent();
    }

    [HttpGet("me")]
    public async Task<ActionResult<ApiResponse<MeResponse>>> Me(CancellationToken ct)
    {
        var me = await signIn.GetMeAsync(ct);
        return me is null
            ? Unauthorized(ApiResponse<MeResponse>.Fail("UNAUTHENTICATED", "Sign in to continue."))
            : Ok(ApiResponse<MeResponse>.Ok(me));
    }
}

public sealed record PasswordLoginRequest(string Email, string Password);
