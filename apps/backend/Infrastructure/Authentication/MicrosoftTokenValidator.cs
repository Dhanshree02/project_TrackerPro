using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;

namespace PMS.API.Infrastructure.Authentication;

public sealed record MicrosoftUserInfo(
    string Oid,
    string Email,
    string Name,
    string? TenantId);

public sealed class MicrosoftTokenValidator
{
    private readonly MicrosoftAuthOptions _options;
    private readonly ConfigurationManager<OpenIdConnectConfiguration> _configManager;
    private readonly JwtSecurityTokenHandler _tokenHandler = new();

    public MicrosoftTokenValidator(IOptions<MicrosoftAuthOptions> options)
    {
        _options = options.Value;
        var metadataAddress = $"https://login.microsoftonline.com/{_options.TenantId}/v2.0/.well-known/openid-configuration";
        _configManager = new ConfigurationManager<OpenIdConnectConfiguration>(
            metadataAddress,
            new OpenIdConnectConfigurationRetriever(),
            new HttpDocumentRetriever());
    }

    public async Task<MicrosoftUserInfo> ValidateAsync(string idToken, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(idToken))
            throw new UnauthorizedException("Microsoft ID token is missing.");

        OpenIdConnectConfiguration discoveryDocument;
        try
        {
            discoveryDocument = await _configManager.GetConfigurationAsync(ct);
        }
        catch (Exception ex)
        {
            throw new UnauthorizedException($"Failed to retrieve Microsoft OpenID Connect configuration: {ex.Message}");
        }

        var validationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuers =
            [
                $"https://login.microsoftonline.com/{_options.TenantId}/v2.0",
                $"https://sts.windows.net/{_options.TenantId}/",
            ],
            ValidateAudience = true,
            ValidAudience = _options.ClientId,
            ValidateIssuerSigningKey = true,
            IssuerSigningKeys = discoveryDocument.SigningKeys,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(5),
        };

        ClaimsPrincipal principal;
        try
        {
            principal = _tokenHandler.ValidateToken(idToken, validationParameters, out var validatedToken);
            if (validatedToken is not JwtSecurityToken)
                throw new UnauthorizedException("Invalid token format.");
        }
        catch (Exception ex) when (ex is not UnauthorizedException)
        {
            throw new UnauthorizedException($"Microsoft token validation failed: {ex.Message}");
        }

        var oid = principal.FindFirst("oid")?.Value
            ?? principal.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? throw new UnauthorizedException("Token missing 'oid' (Object ID) claim.");

        var email = principal.FindFirst("preferred_username")?.Value
            ?? principal.FindFirst("email")?.Value
            ?? principal.FindFirst(ClaimTypes.Email)?.Value
            ?? principal.FindFirst(ClaimTypes.Upn)?.Value
            ?? throw new UnauthorizedException("Token missing email/username claim.");

        var name = principal.FindFirst("name")?.Value
            ?? principal.FindFirst(ClaimTypes.Name)?.Value
            ?? email.Split('@')[0];

        var tenantId = principal.FindFirst("tid")?.Value;

        return new MicrosoftUserInfo(oid, email.Trim().ToLowerInvariant(), name.Trim(), tenantId);
    }
}
