using Microsoft.Extensions.Options;

namespace PMS.API.Infrastructure.Authentication;

/// <summary>
/// Configuration for the refresh-token HttpOnly cookie, bound from the
/// <c>Auth:RefreshCookie</c> section. <c>SameSite=None</c> + <c>Secure=true</c>
/// are required so the cookie travels with cross-origin XHR between the
/// frontend and the API. Browsers treat <c>http://localhost</c> as a secure
/// context, so <c>Secure</c> cookies also work during local development; in
/// production the API is served over HTTPS anyway.
/// </summary>
public sealed class RefreshCookieOptions
{
    public const string SectionName = "Auth:RefreshCookie";

    public string Name { get; set; } = "refresh_token";

    /// <summary>
    /// Restricted to the auth endpoints so the cookie is never sent with
    /// regular API requests.
    /// </summary>
    public string Path { get; set; } = "/api/v1/auth";

    public bool HttpOnly { get; set; } = true;

    public bool Secure { get; set; } = true;

    /// <summary>Parsed as a <see cref="SameSiteMode"/> (e.g. "None", "Lax", "Strict").</summary>
    public string SameSite { get; set; } = "None";

    /// <summary>Optional cookie lifetime. When null the cookie is a session cookie.</summary>
    public TimeSpan? MaxAge { get; set; }
}

/// <summary>
/// Reads and writes the refresh-token HttpOnly cookie. The raw token never
/// touches JavaScript — it only ever exists inside this cookie and, briefly,
/// in memory on the server.
/// </summary>
public sealed class RefreshTokenCookie(IOptions<RefreshCookieOptions> options)
{
    private readonly RefreshCookieOptions _options = options.Value;

    public string? Read(HttpRequest request) => request.Cookies[_options.Name];

    public void Append(HttpResponse response, string token, DateTimeOffset? expiresAt = null)
    {
        response.Cookies.Append(_options.Name, token, BuildOptions(expiresAt));
    }

    public void Clear(HttpResponse response)
    {
        response.Cookies.Delete(_options.Name, BuildOptions(expiresAt: null));
    }

    private CookieOptions BuildOptions(DateTimeOffset? expiresAt) => new()
    {
        HttpOnly = _options.HttpOnly,
        Secure = _options.Secure,
        SameSite = ParseSameSite(_options.SameSite),
        Path = _options.Path,
        Expires = expiresAt,
        MaxAge = _options.MaxAge,
    };

    private static SameSiteMode ParseSameSite(string value) =>
        Enum.TryParse<SameSiteMode>(value, ignoreCase: true, out var mode)
            ? mode
            : SameSiteMode.None;
}
