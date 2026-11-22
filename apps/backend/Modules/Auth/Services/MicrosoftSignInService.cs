using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Auth.DTOs;
using PMS.API.Modules.Users.Models;

namespace PMS.API.Modules.Auth.Services;

public sealed class MicrosoftSignInService(
    IHttpClientFactory httpClientFactory,
    IOptions<AzureAdOptions> azureOptions,
    IOptions<JwtOptions> jwtOptions,
    JwtTokenService tokens,
    AppDbContext db,
    ICurrentUserService currentUser,
    ILogger<MicrosoftSignInService> logger)
{
    private readonly AzureAdOptions _azure = azureOptions.Value;
    private readonly JwtOptions _jwt = jwtOptions.Value;

    public string? CreateAuthorizeRedirect(HttpResponse response)
    {
        if (!_azure.IsConfigured) return null;

        var verifier = Base64Url(RandomNumberGenerator.GetBytes(32));
        var challenge = Base64Url(SHA256.HashData(Encoding.ASCII.GetBytes(verifier)));
        var state = Base64Url(RandomNumberGenerator.GetBytes(16));
        var nonce = Base64Url(RandomNumberGenerator.GetBytes(16));

        response.Cookies.Append(AuthCookies.OAuth, $"{state}|{nonce}|{verifier}", AuthCookies.ShortLived(TimeSpan.FromMinutes(10)));

        var url = QueryHelpers.AddQueryString(
            $"https://login.microsoftonline.com/{_azure.TenantId}/oauth2/v2.0/authorize",
            new Dictionary<string, string?>
            {
                ["client_id"] = _azure.ClientId,
                ["response_type"] = "code",
                ["redirect_uri"] = _azure.RedirectUri,
                ["response_mode"] = "query",
                ["scope"] = "openid profile email",
                ["state"] = state,
                ["nonce"] = nonce,
                ["code_challenge"] = challenge,
                ["code_challenge_method"] = "S256",
                ["prompt"] = "login",
            });
        return url;
    }

    public async Task<string> CompleteAsync(
        HttpRequest request,
        HttpResponse response,
        string? code,
        string? state,
        string? microsoftError,
        CancellationToken ct)
    {
        if (!string.IsNullOrWhiteSpace(microsoftError))
            return LoginUrl("microsoft_denied");

        if (!_azure.IsConfigured || string.IsNullOrWhiteSpace(code) || string.IsNullOrWhiteSpace(state))
            return LoginUrl("sign_in_failed");

        if (!request.Cookies.TryGetValue(AuthCookies.OAuth, out var pending))
            return LoginUrl("sign_in_expired");

        response.Cookies.Delete(AuthCookies.OAuth, AuthCookies.Clearing());
        var parts = pending.Split('|');
        if (parts.Length != 3 || !string.Equals(parts[0], state, StringComparison.Ordinal))
            return LoginUrl("sign_in_expired");

        var nonce = parts[1];
        var verifier = parts[2];

        string idToken;
        try
        {
            idToken = await ExchangeCodeAsync(code, verifier, ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Microsoft code exchange failed.");
            return LoginUrl("sign_in_failed");
        }

        ClaimsPrincipal principal;
        try
        {
            principal = await ValidateIdTokenAsync(idToken, nonce, ct);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Microsoft id token was rejected.");
            return LoginUrl("sign_in_failed");
        }

        var email = ReadEmail(principal);
        if (string.IsNullOrWhiteSpace(email))
            return LoginUrl("sign_in_failed");

        var normalized = email.Trim().ToLowerInvariant();
        var employee = await db.Employees
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Include(e => e.ReportingManager)
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.WorkEmail.ToLower() == normalized, ct);
        if (employee is null)
            return LoginUrl("not_an_employee");

        var user = await db.Users
            .Include(u => u.Role)
            .FirstOrDefaultAsync(u =>
                u.DeletedAtUtc == null &&
                (u.Id == employee.UserId ||
                 u.Email.ToLower() == normalized ||
                 u.EmployeeId == employee.EmployeeCode), ct);
        if (user is null)
            return LoginUrl("no_account");
        if (!user.IsActive)
            return LoginUrl("account_inactive");

        if (employee.UserId != user.Id)
            employee.UserId = user.Id;

        user.LastLoginAtUtc = DateTime.UtcNow;
        await IssueSessionAsync(user, response, ct);
        await db.SaveChangesAsync(ct);
        return AppRoot();
    }

    public async Task LogoutAsync(HttpRequest request, HttpResponse response, CancellationToken ct)
    {
        if (request.Cookies.TryGetValue(AuthCookies.Refresh, out var refresh) && !string.IsNullOrWhiteSpace(refresh))
        {
            var hash = tokens.HashToken(refresh);
            var stored = await db.RefreshTokens.FirstOrDefaultAsync(t => t.TokenHash == hash, ct);
            if (stored is not null && stored.RevokedAtUtc is null)
            {
                stored.RevokedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }
        }

        response.Cookies.Delete(AuthCookies.Access, AuthCookies.Clearing());
        response.Cookies.Delete(AuthCookies.Refresh, AuthCookies.Clearing());
        response.Cookies.Delete(AuthCookies.OAuth, AuthCookies.Clearing());
    }

    public string LoginRedirect(string error) => LoginUrl(error);

    public async Task<string?> TryRefreshAsync(HttpRequest request, HttpResponse response, CancellationToken ct)
    {
        if (!request.Cookies.TryGetValue(AuthCookies.Refresh, out var refresh) || string.IsNullOrWhiteSpace(refresh))
            return null;

        var hash = tokens.HashToken(refresh);
        var stored = await db.RefreshTokens.FirstOrDefaultAsync(t => t.TokenHash == hash, ct);
        if (stored is null) return null;

        if (stored.RevokedAtUtc is not null || stored.ExpiresAtUtc <= DateTime.UtcNow)
        {
            if (stored.RevokedAtUtc is not null)
            {
                var live = await db.RefreshTokens
                    .Where(t => t.UserId == stored.UserId && t.RevokedAtUtc == null)
                    .ToListAsync(ct);
                foreach (var token in live)
                    token.RevokedAtUtc = DateTime.UtcNow;
                await db.SaveChangesAsync(ct);
            }
            response.Cookies.Delete(AuthCookies.Access, AuthCookies.Clearing());
            response.Cookies.Delete(AuthCookies.Refresh, AuthCookies.Clearing());
            return null;
        }

        var user = await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Id == stored.UserId && u.DeletedAtUtc == null && u.IsActive, ct);
        if (user is null) return null;

        stored.RevokedAtUtc = DateTime.UtcNow;
        var replacement = JwtTokenService.GenerateRefreshToken();
        stored.ReplacedByTokenHash = tokens.HashToken(replacement);
        db.RefreshTokens.Add(new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            TokenHash = stored.ReplacedByTokenHash,
            ExpiresAtUtc = DateTime.UtcNow.AddDays(_jwt.RefreshTokenExpiryDays),
            CreatedAtUtc = DateTime.UtcNow,
        });
        var (access, accessExpires) = tokens.GenerateAccessToken(user);
        response.Cookies.Append(AuthCookies.Access, access, AuthCookies.Persistent(accessExpires));
        response.Cookies.Append(AuthCookies.Refresh, replacement, AuthCookies.Persistent(DateTime.UtcNow.AddDays(_jwt.RefreshTokenExpiryDays)));
        await db.SaveChangesAsync(ct);
        return access;
    }

    public async Task<MeResponse?> GetMeAsync(CancellationToken ct)
    {
        var userId = currentUser.UserId;
        var email = currentUser.Email?.Trim().ToLowerInvariant();
        var user = await db.Users.Include(u => u.Role).FirstOrDefaultAsync(u =>
            u.DeletedAtUtc == null &&
            ((userId != null && u.Id == userId) || (email != null && u.Email.ToLower() == email)), ct);
        if (user is null || !user.IsActive) return null;

        var employee = await db.Employees
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .Include(e => e.ReportingManager)
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && (e.UserId == user.Id || e.WorkEmail.ToLower() == user.Email.ToLower()), ct);

        var manager = employee?.ReportingManager;
        var managerName = manager is null ? null : $"{manager.FirstName} {manager.LastName}".Trim();

        return new MeResponse(
            user.Id.ToString(),
            user.Email,
            employee is null ? user.Name : $"{employee.FirstName} {employee.LastName}".Trim(),
            employee?.Id.ToString(),
            employee?.EmployeeCode ?? user.EmployeeId,
            user.Role?.Name,
            user.RoleId?.ToString(),
            user.MustChangePassword,
            employee?.Phone,
            employee?.Department?.Name ?? user.Department,
            employee?.SubDepartment,
            employee?.Designation?.Name ?? user.Designation,
            managerName,
            employee?.WorkLocation,
            employee?.Status);
    }

    private async Task IssueSessionAsync(User user, HttpResponse response, CancellationToken ct)
    {
        var (access, accessExpires) = tokens.GenerateAccessToken(user);
        var refresh = JwtTokenService.GenerateRefreshToken();
        db.RefreshTokens.Add(new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            TokenHash = tokens.HashToken(refresh),
            ExpiresAtUtc = DateTime.UtcNow.AddDays(_jwt.RefreshTokenExpiryDays),
            CreatedAtUtc = DateTime.UtcNow,
        });
        response.Cookies.Append(AuthCookies.Access, access, AuthCookies.Persistent(accessExpires));
        response.Cookies.Append(AuthCookies.Refresh, refresh, AuthCookies.Persistent(DateTime.UtcNow.AddDays(_jwt.RefreshTokenExpiryDays)));
        await Task.CompletedTask;
    }

    private async Task<string> ExchangeCodeAsync(string code, string verifier, CancellationToken ct)
    {
        // This Entra app redeems codes as a single-page client: no secret, and
        // the Origin of the redirect URI must be present (AADSTS9002327).
        // A Web registration asks for the secret instead (AADSTS7000218).
        var first = await RequestTokenAsync(code, verifier, includeSecret: false, ct);
        if (first.IdToken is not null)
            return first.IdToken;

        if (first.Codes?.Split(',').Contains("7000218") == true)
        {
            var second = await RequestTokenAsync(code, verifier, includeSecret: true, ct);
            if (second.IdToken is not null)
                return second.IdToken;
            throw new InvalidOperationException(second.Describe());
        }

        throw new InvalidOperationException(first.Describe());
    }

    private async Task<TokenExchange> RequestTokenAsync(string code, string verifier, bool includeSecret, CancellationToken ct)
    {
        var fields = new Dictionary<string, string>
        {
            ["client_id"] = _azure.ClientId,
            ["grant_type"] = "authorization_code",
            ["code"] = code,
            ["redirect_uri"] = _azure.RedirectUri,
            ["code_verifier"] = verifier,
            ["scope"] = "openid profile email",
        };
        if (includeSecret)
            fields["client_secret"] = _azure.ClientSecret;

        var client = httpClientFactory.CreateClient("microsoft");
        using var body = new FormUrlEncodedContent(fields);
        using var request = new HttpRequestMessage(
            HttpMethod.Post,
            $"https://login.microsoftonline.com/{_azure.TenantId}/oauth2/v2.0/token")
        {
            Content = body,
        };
        if (!includeSecret && Uri.TryCreate(_azure.RedirectUri, UriKind.Absolute, out var redirect))
            request.Headers.TryAddWithoutValidation("Origin", $"{redirect.Scheme}://{redirect.Authority}");

        using var res = await client.SendAsync(request, ct);
        var json = await res.Content.ReadAsStringAsync(ct);
        using var doc = JsonDocument.Parse(json);
        if (res.IsSuccessStatusCode &&
            doc.RootElement.TryGetProperty("id_token", out var idToken) &&
            idToken.GetString() is { Length: > 0 } token)
        {
            return new TokenExchange((int)res.StatusCode, token, null, null);
        }

        var error = doc.RootElement.TryGetProperty("error", out var errorProp) ? errorProp.GetString() : null;
        var codes = doc.RootElement.TryGetProperty("error_codes", out var codesProp)
            ? string.Join(",", codesProp.EnumerateArray().Select(c => c.ToString()))
            : null;
        return new TokenExchange((int)res.StatusCode, null, error, codes);
    }

    private readonly record struct TokenExchange(int Status, string? IdToken, string? Error, string? Codes)
    {
        public string Describe() => $"Microsoft token exchange failed ({Status} {Error} {Codes}).";
    }

    private async Task<ClaimsPrincipal> ValidateIdTokenAsync(string idToken, string nonce, CancellationToken ct)
    {
        var metadata = $"https://login.microsoftonline.com/{_azure.TenantId}/v2.0/.well-known/openid-configuration";
        var manager = new ConfigurationManager<OpenIdConnectConfiguration>(
            metadata,
            new OpenIdConnectConfigurationRetriever(),
            new HttpDocumentRetriever { RequireHttps = true });
        var config = await manager.GetConfigurationAsync(ct);
        var handler = new JwtSecurityTokenHandler { MapInboundClaims = false };
        var principal = handler.ValidateToken(idToken, new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuers =
            [
                $"https://login.microsoftonline.com/{_azure.TenantId}/v2.0",
                config.Issuer,
            ],
            ValidateAudience = true,
            ValidAudience = _azure.ClientId,
            ValidateLifetime = true,
            IssuerSigningKeys = config.SigningKeys,
            ClockSkew = TimeSpan.FromMinutes(2),
        }, out _);

        var tokenNonce = principal.FindFirst("nonce")?.Value;
        if (!string.Equals(tokenNonce, nonce, StringComparison.Ordinal))
            throw new InvalidOperationException("Nonce mismatch.");

        var tenant = principal.FindFirst("tid")?.Value;
        if (!string.Equals(tenant, _azure.TenantId, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Tenant mismatch.");

        return principal;
    }

    private static string? ReadEmail(ClaimsPrincipal principal)
    {
        return principal.FindFirst("preferred_username")?.Value
            ?? principal.FindFirst("email")?.Value
            ?? principal.FindFirst("upn")?.Value;
    }

    private string AppRoot()
    {
        if (!Uri.TryCreate(_azure.RedirectUri, UriKind.Absolute, out var uri))
            return "http://localhost:39127/";
        return $"{uri.Scheme}://{uri.Authority}/";
    }

    private string LoginUrl(string error) => $"{AppRoot().TrimEnd('/')}/login?error={Uri.EscapeDataString(error)}";

    private static string Base64Url(byte[] bytes) =>
        Convert.ToBase64String(bytes).TrimEnd('=').Replace('+', '-').Replace('/', '_');
}
