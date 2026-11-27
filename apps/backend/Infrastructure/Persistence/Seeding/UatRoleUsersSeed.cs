using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Infrastructure.Persistence.Seeding;

/// <summary>
/// Ensures every active employee login account in UAT can sign in with <see cref="DefaultPassword"/>,
/// and removes any synthetic <c>uat.*</c> accounts so only real employees exist in <c>auth.tbl_users</c>.
/// Runs only when <c>App:Stage</c> is <c>"uat"</c>.
/// </summary>
public static class UatRoleUsersSeed
{
    public const string DefaultPassword = "Uat@12345";

    public static async Task<int> EnsureAsync(
        AppDbContext db,
        IPasswordHasher hasher,
        CancellationToken ct = default)
    {
        // Remove synthetic uat.* placeholder accounts if previously seeded
        var synthetic = await db.Users
            .Where(u => u.EmployeeId.StartsWith("UAT-") && u.Email.StartsWith("uat."))
            .ToListAsync(ct);

        if (synthetic.Count > 0)
            db.Users.RemoveRange(synthetic);

        var users = await db.Users
            .Where(u => u.DeletedAtUtc == null && u.IsActive)
            .ToListAsync(ct);

        string? cachedHash = null;
        string GetPasswordHash() => cachedHash ??= hasher.Hash(DefaultPassword);

        var changed = synthetic.Count;

        foreach (var user in users)
        {
            var needsHash = string.IsNullOrWhiteSpace(user.PasswordHash)
                || !hasher.Verify(DefaultPassword, user.PasswordHash);

            if (needsHash)
            {
                user.PasswordHash = GetPasswordHash();
                user.UpdatedAtUtc = DateTime.UtcNow;
                changed++;
            }

            if (user.MustChangePassword)
            {
                user.MustChangePassword = false;
                changed++;
            }
        }

        if (changed > 0)
            await db.SaveChangesAsync(ct);

        return users.Count;
    }
}
