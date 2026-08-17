namespace PMS.API.Modules.Auth.DTOs;

public sealed record LoginRequest(string Email, string Password);

public sealed record RefreshTokenRequest(string RefreshToken);

public sealed record ChangePasswordRequest(string CurrentPassword, string NewPassword);

/// <summary>
/// Login/refresh response. Contains the short-lived access token only — the
/// refresh token is delivered via an HttpOnly cookie and never in a body.
/// </summary>
public sealed record AuthResult(string AccessToken, DateTime AccessTokenExpiresAtUtc, UserProfileDto User);

public sealed record UserProfileDto(
    Guid Id,
    string Email,
    string Name,
    string? EmployeeId,
    string? Role,
    Guid? RoleId,
    bool MustChangePassword,
    IReadOnlyList<string> Permissions);
