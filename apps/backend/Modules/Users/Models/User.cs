using PMS.API.Modules.Auth.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Users.Models;

/// <summary>
/// Company user (employee). Map fields from <c>people[]</c> in
/// <c>apps/frontend/src/lib/mock-data.ts</c> during seeding.
/// </summary>
public class User : BaseEntity
{
    public string Email { get; set; } = string.Empty;

    /// <summary>BCrypt hash — never store plaintext passwords.</summary>
    public string PasswordHash { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public string EmployeeId { get; set; } = string.Empty;

    public string? Department { get; set; }

    public string? SubDepartment { get; set; }

    public string? Avatar { get; set; }

    public string? Designation { get; set; }

    public bool IsActive { get; set; } = true;

    public bool MustChangePassword { get; set; }

    /// <summary>Lockout: 5 consecutive failures locks the account for 15 minutes.</summary>
    public int FailedLoginAttempts { get; set; }

    public DateTime? LockedUntilUtc { get; set; }

    public DateTime? LastLoginAtUtc { get; set; }

    public DateTime? PasswordChangedAtUtc { get; set; }

    public Guid? RoleId { get; set; }

    public Role? Role { get; set; }

    public ICollection<RefreshToken> RefreshTokens { get; set; } = [];
}
