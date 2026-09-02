using PMS.API.Modules.Auth.DTOs;

namespace PMS.API.Modules.Auth.Services;

/// <summary>
/// Authentication service — Phase 1 scope. Implementation lives in
/// <c>PMS.API.Infrastructure.Authentication</c>.
/// </summary>
public interface IAuthService
{
    Task<AuthResult> LoginAsync(LoginRequest request, CancellationToken ct = default);

    Task<AuthResult> LoginWithMicrosoftAsync(MicrosoftLoginRequest request, CancellationToken ct = default);

    Task<AuthResult> RefreshAsync(RefreshTokenRequest request, CancellationToken ct = default);

    Task LogoutAsync(string refreshToken, CancellationToken ct = default);

    Task<UserProfileDto?> GetProfileAsync(Guid userId, CancellationToken ct = default);

    Task ChangePasswordAsync(Guid userId, ChangePasswordRequest request, CancellationToken ct = default);
}
