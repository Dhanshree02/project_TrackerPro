using Microsoft.Extensions.Options;
using PMS.API.Modules.Users.Models;
using PMS.API.Infrastructure.Authentication;

namespace PMS.UnitTests;

public class JwtTokenServiceTests
{
    private static JwtTokenService CreateService() =>
        new(Options.Create(new JwtOptions
        {
            Issuer = "TrackerPro",
            Audience = "TrackerPro.Client",
            SigningKey = "test-secret-key-that-is-longer-than-64-characters-for-sha512-signing-!!!!",
            AccessTokenExpiryMinutes = 30,
            RefreshTokenExpiryDays = 7,
        }));

    [Fact]
    public void GenerateAccessToken_ReturnsNonEmptyToken()
    {
        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = "pm@company.com",
            Name = "Test PM",
            Role = new Role { Name = nameof(UserRole.Pmo) },
        };

        var (token, expiresAt) = CreateService().GenerateAccessToken(user, ["projects:read"]);

        Assert.False(string.IsNullOrWhiteSpace(token));
        Assert.Contains('.', token); // JWT header.payload.signature
        Assert.True(expiresAt > DateTime.UtcNow);
    }

    [Fact]
    public void HashToken_IsDeterministicSha256()
    {
        var service = CreateService();

        var h1 = service.HashToken("abc");
        var h2 = service.HashToken("abc");

        Assert.Equal(h1, h2);
        Assert.NotEqual(h1, service.HashToken("abd"));
    }

    [Fact]
    public void GenerateRefreshToken_IsUniqueAndBase64()
    {
        var service = CreateService();

        var a = JwtTokenService.GenerateRefreshToken();
        var b = JwtTokenService.GenerateRefreshToken();

        Assert.NotEqual(a, b);
        Assert.True(Convert.TryFromBase64String(a, new byte[64], out _));
    }
}
