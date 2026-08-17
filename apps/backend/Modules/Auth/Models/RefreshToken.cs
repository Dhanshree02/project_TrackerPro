using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Auth.Models;

/// <summary>
/// Refresh token used to issue new access tokens. Only the SHA-256 hash of the
/// token is persisted so a leaked database cannot be replayed directly.
/// </summary>
public class RefreshToken : BaseEntity
{
    public Guid UserId { get; set; }

    public User? User { get; set; }

    public string TokenHash { get; set; } = string.Empty;

    public DateTime ExpiresAtUtc { get; set; }

    public DateTime? RevokedAtUtc { get; set; }

    public string? ReplacedByTokenHash { get; set; }

    public bool IsActive => RevokedAtUtc is null && ExpiresAtUtc > DateTime.UtcNow;
}
