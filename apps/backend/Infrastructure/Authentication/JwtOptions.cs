namespace PMS.API.Infrastructure.Authentication;

/// <summary>
/// JWT settings, bound from the <c>Jwt</c> configuration section.
/// All values come from environment variables / user secrets in production.
/// </summary>
public sealed class JwtOptions
{
    public const string SectionName = "Jwt";

    public string Issuer { get; set; } = "TrackerPro";

    public string Audience { get; set; } = "TrackerPro.Client";

    /// <summary>512-bit minimum recommended. Override in production secrets.</summary>
    public string SigningKey { get; set; } = string.Empty;

    public int AccessTokenExpiryMinutes { get; set; } = 15;

    public int RefreshTokenExpiryDays { get; set; } = 7;
}
