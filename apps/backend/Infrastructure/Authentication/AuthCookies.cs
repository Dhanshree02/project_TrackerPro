namespace PMS.API.Infrastructure.Authentication;

/// <summary>
/// HttpOnly session cookies. The browser script cannot read them.
/// Secure stays off because production is served over http on localhost.
/// </summary>
public static class AuthCookies
{
    public const string Access = "pms_access";
    public const string Refresh = "pms_refresh";
    public const string OAuth = "pms_oauth";

    public static CookieOptions Persistent(DateTime expiresUtc) => new()
    {
        HttpOnly = true,
        Secure = false,
        SameSite = SameSiteMode.Lax,
        Path = "/",
        Expires = new DateTimeOffset(DateTime.SpecifyKind(expiresUtc, DateTimeKind.Utc)),
    };

    public static CookieOptions ShortLived(TimeSpan lifetime) => new()
    {
        HttpOnly = true,
        Secure = false,
        SameSite = SameSiteMode.Lax,
        Path = "/",
        MaxAge = lifetime,
    };

    public static CookieOptions Clearing() => new()
    {
        HttpOnly = true,
        Secure = false,
        SameSite = SameSiteMode.Lax,
        Path = "/",
        Expires = DateTimeOffset.UnixEpoch,
    };
}
