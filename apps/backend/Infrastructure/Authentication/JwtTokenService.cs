using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using PMS.API.Modules.Users.Models;

namespace PMS.API.Infrastructure.Authentication;

/// <summary>
/// Issues signed JWT access tokens and handles refresh-token hashing.
/// </summary>
public sealed class JwtTokenService(IOptions<JwtOptions> options)
{
    private readonly JwtOptions _options = options.Value;

    /// <summary>
    /// Issues an access token. The returned expiry matches the JWT <c>exp</c> claim exactly.
    /// NOTE: <paramref name="user"/> must be loaded with <c>.Include(u => u.Role)</c> or the
    /// role claim will be empty.
    /// </summary>
    public (string Token, DateTime ExpiresAtUtc) GenerateAccessToken(User user, IReadOnlyList<string> permissions)
    {
        var expiresAtUtc = DateTime.UtcNow.AddMinutes(_options.AccessTokenExpiryMinutes);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(JwtRegisteredClaimNames.Email, user.Email),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new(ClaimTypes.Name, user.Name),
            new(ClaimTypes.Role, user.Role?.Name ?? string.Empty),
        };

        // Permissions as individual claims for policy checks.
        foreach (var permission in permissions)
            claims.Add(new Claim(AuthClaimTypes.Permission, permission));

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.SigningKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512);

        var token = new JwtSecurityToken(
            issuer: _options.Issuer,
            audience: _options.Audience,
            claims: claims,
            expires: expiresAtUtc,
            signingCredentials: creds);

        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAtUtc);
    }

    public string HashToken(string token) =>
        Convert.ToBase64String(SHA256.HashData(Encoding.UTF8.GetBytes(token)));

    public static string GenerateRefreshToken() =>
        Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));
}
