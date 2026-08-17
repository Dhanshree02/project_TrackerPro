using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PMS.API.Modules.Auth.Services;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Modules.Auth.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Infrastructure.Persistence;

namespace PMS.API.Infrastructure.Authentication;

/// <summary>
/// JWT authentication: BCrypt password verification, short-lived access tokens
/// and rotating refresh tokens stored as SHA-256 hashes. Reusing a revoked token
/// revokes the whole token family (theft detection).
/// </summary>
public sealed class AuthService(
    AppDbContext db,
    JwtTokenService jwt,
    IPasswordHasher passwordHasher,
    IOptions<JwtOptions> options,
    IHttpContextAccessor httpContextAccessor,
    RefreshTokenCookie refreshCookie) : IAuthService
{
    private readonly JwtOptions _options = options.Value;

    public const int MaxFailedAttempts = 5;

    public static readonly TimeSpan LockoutDuration = TimeSpan.FromMinutes(15);

    public async Task<AuthResult> LoginAsync(LoginRequest request, CancellationToken ct = default)
    {
        var user = await LoadUserAsync(email: request.Email, ct: ct)
            ?? throw new UnauthorizedException("Invalid email or password.");

        // Lockout window active?
        if (user.LockedUntilUtc is { } lockedUntil && lockedUntil > DateTime.UtcNow)
        {
            var minutes = (int)Math.Ceiling((lockedUntil - DateTime.UtcNow).TotalMinutes);
            throw new UnauthorizedException($"Account locked. Try again in {minutes} minute(s).");
        }

        if (!passwordHasher.Verify(request.Password, user.PasswordHash))
        {
            user.FailedLoginAttempts += 1;
            if (user.FailedLoginAttempts >= MaxFailedAttempts)
            {
                user.LockedUntilUtc = DateTime.UtcNow.Add(LockoutDuration);
                user.FailedLoginAttempts = 0;
            }
            await db.SaveChangesAsync(ct);
            throw new UnauthorizedException("Invalid email or password.");
        }

        if (!user.IsActive)
            throw new UnauthorizedException("Account is disabled. Contact your administrator.");

        // Success — clear lockout state.
        user.FailedLoginAttempts = 0;
        user.LockedUntilUtc = null;
        user.LastLoginAtUtc = DateTime.UtcNow;

        // Login invalidates previous refresh tokens (single active session per device is fine
        // for the MVP; session-per-device can be added with a device claim later).
        var oldTokens = await db.RefreshTokens.Where(t => t.UserId == user.Id && t.RevokedAtUtc == null).ToListAsync(ct);
        foreach (var t in oldTokens) t.RevokedAtUtc = DateTime.UtcNow;

        return await IssueTokensAsync(user, ct);
    }

    /// <summary>
    /// Changes the authenticated user's password. Clears MustChangePassword and
    /// revokes every refresh token so other sessions must re-authenticate.
    /// </summary>
    public async Task ChangePasswordAsync(
        Guid userId,
        ChangePasswordRequest request,
        CancellationToken ct = default)
    {
        var user = await LoadUserAsync(userId: userId, ct: ct)
            ?? throw new UnauthorizedException("User not found.");

        if (!passwordHasher.Verify(request.CurrentPassword, user.PasswordHash))
            throw new UnauthorizedException("Current password is incorrect.");

        user.PasswordHash = passwordHasher.Hash(request.NewPassword);
        user.MustChangePassword = false;
        user.PasswordChangedAtUtc = DateTime.UtcNow;

        var tokens = await db.RefreshTokens.Where(t => t.UserId == user.Id && t.RevokedAtUtc == null).ToListAsync(ct);
        foreach (var t in tokens) t.RevokedAtUtc = DateTime.UtcNow;

        await db.SaveChangesAsync(ct);
    }

    public async Task<AuthResult> RefreshAsync(RefreshTokenRequest request, CancellationToken ct = default)
    {
        var tokenHash = jwt.HashToken(request.RefreshToken);
        var stored = await db.RefreshTokens
            .Include(t => t.User)!
            .ThenInclude(u => u!.Role)
            .FirstOrDefaultAsync(t => t.TokenHash == tokenHash, ct);

        if (stored is null || stored.User is null)
            throw new UnauthorizedException("Invalid refresh token.");

        // Reuse of an already-revoked token ⇒ possible theft ⇒ revoke the whole family.
        if (stored.RevokedAtUtc is not null)
        {
            await RevokeFamilyAsync(stored.UserId, ct);
            throw new UnauthorizedException("Refresh token reuse detected. All sessions were revoked.");
        }

        if (stored.ExpiresAtUtc <= DateTime.UtcNow)
            throw new UnauthorizedException("Refresh token has expired. Please log in again.");

        // Rotation: revoke the used token, issue a fresh pair.
        stored.RevokedAtUtc = DateTime.UtcNow;
        return await IssueTokensAsync(stored.User, ct);
    }

    public async Task LogoutAsync(string refreshToken, CancellationToken ct = default)
    {
        var tokenHash = jwt.HashToken(refreshToken);
        var stored = await db.RefreshTokens.FirstOrDefaultAsync(
            t => t.TokenHash == tokenHash, ct);

        if (stored is not null)
        {
            stored.RevokedAtUtc = DateTime.UtcNow;
            await db.SaveChangesAsync(ct);
        }
    }

    public async Task<UserProfileDto?> GetProfileAsync(Guid userId, CancellationToken ct = default)
    {
        var user = await LoadUserAsync(userId: userId, ct: ct);
        return user is null ? null : MapProfile(user);
    }

    // ---------- internals ----------

    private async Task<AuthResult> IssueTokensAsync(User user, CancellationToken ct)
    {
        var permissions = user.Role?.Permissions ?? [];
        var (accessToken, expiresAt) = jwt.GenerateAccessToken(user, permissions);

        var rawRefresh = JwtTokenService.GenerateRefreshToken();
        var refreshExpiresAt = DateTime.UtcNow.AddDays(_options.RefreshTokenExpiryDays);
        db.RefreshTokens.Add(new RefreshToken
        {
            UserId = user.Id,
            TokenHash = jwt.HashToken(rawRefresh),
            ExpiresAtUtc = refreshExpiresAt,
        });
        await db.SaveChangesAsync(ct);

        // The raw refresh token only ever lives in the HttpOnly cookie — it is
        // never returned in a response body. When no HTTP request is present
        // (e.g. a direct unit-test call), the cookie is simply skipped.
        var response = httpContextAccessor.HttpContext?.Response;
        if (response is not null)
            refreshCookie.Append(response, rawRefresh, refreshExpiresAt);

        return new AuthResult(accessToken, expiresAt, MapProfile(user));
    }

    private async Task RevokeFamilyAsync(Guid userId, CancellationToken ct)
    {
        var active = await db.RefreshTokens
            .Where(t => t.UserId == userId && t.RevokedAtUtc == null)
            .ToListAsync(ct);
        foreach (var t in active) t.RevokedAtUtc = DateTime.UtcNow;
        await db.SaveChangesAsync(ct);
    }

    private async Task<User?> LoadUserAsync(string? email = null, Guid? userId = null, CancellationToken ct = default)
    {
        var query = db.Users
            .Include(u => u.Role)
            .AsQueryable();

        if (email is not null)
            query = query.Where(u => u.Email == email);
        else if (userId is not null)
            query = query.Where(u => u.Id == userId.Value);

        return await query.FirstOrDefaultAsync(ct);
    }

    private static UserProfileDto MapProfile(User user) => new(
        user.Id,
        user.Email,
        user.Name,
        user.EmployeeId,
        user.Role?.Name,
        user.RoleId,
        user.MustChangePassword,
        user.Role?.Permissions ?? []);
}

/// <summary>Thrown for authentication/authorization failures (maps to 401 in the API).</summary>
public sealed class UnauthorizedException(string message) : Exception(message);
