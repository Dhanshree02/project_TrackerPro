using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Modules.Users.Models;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Seeds one active UAT login account per active RBAC role so testers can sign in
/// with email and password without using the development user-switcher.
/// Runs only when App:Stage is "uat".
/// </summary>
public static partial class UatRoleUsersSeed
{
    public const string DefaultPassword = "Uat@12345";

    [GeneratedRegex("[^a-z0-9]+")]
    private static partial Regex SlugSeparator();

    public static string RoleEmail(string roleName)
    {
        var slug = SlugSeparator()
            .Replace(roleName.Trim().ToLowerInvariant(), "-")
            .Trim('-');
        return $"uat.{slug}@talakunchi.com";
    }

    public static async Task<int> EnsureAsync(
        AppDbContext db,
        IPasswordHasher hasher,
        CancellationToken ct = default)
    {
        var roles = await db.Roles
            .Where(r => r.DeletedAtUtc == null && r.IsActive)
            .OrderBy(r => r.Name)
            .ToListAsync(ct);

        if (roles.Count == 0) return 0;

        var existingUsers = await db.Users
            .Where(u => u.DeletedAtUtc == null)
            .ToListAsync(ct);

        var byEmail = existingUsers
            .ToDictionary(u => u.Email.Trim().ToLowerInvariant(), u => u);

        string? cachedHash = null;
        string GetPasswordHash() => cachedHash ??= hasher.Hash(DefaultPassword);

        var changed = 0;
        var index = 1;

        foreach (var role in roles)
        {
            var email = RoleEmail(role.Name);
            var display = string.IsNullOrWhiteSpace(role.DisplayName) ? role.Name : role.DisplayName;

            if (byEmail.TryGetValue(email, out var existing))
            {
                var updated = false;
                if (existing.RoleId != role.Id)
                {
                    existing.RoleId = role.Id;
                    updated = true;
                }
                if (!existing.IsActive)
                {
                    existing.IsActive = true;
                    updated = true;
                }
                if (string.IsNullOrWhiteSpace(existing.PasswordHash))
                {
                    existing.PasswordHash = GetPasswordHash();
                    updated = true;
                }
                if (updated) changed++;
            }
            else
            {
                var user = new User
                {
                    Id = Guid.NewGuid(),
                    Email = email,
                    PasswordHash = GetPasswordHash(),
                    Name = $"UAT {display}",
                    EmployeeId = $"UAT-{index:00}",
                    IsActive = true,
                    MustChangePassword = false,
                    RoleId = role.Id,
                    CreatedAtUtc = DateTime.UtcNow,
                };
                db.Users.Add(user);
                byEmail[email] = user;
                changed++;
            }

            index++;
        }

        if (changed > 0)
            await db.SaveChangesAsync(ct);

        return roles.Count;
    }
}
