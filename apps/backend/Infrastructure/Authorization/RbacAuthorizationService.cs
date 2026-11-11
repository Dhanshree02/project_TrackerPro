using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using PMS.API.Infrastructure.Persistence;

namespace PMS.API.Infrastructure.Authorization;

public sealed class RbacAuthorizationService(
    AppDbContext db,
    IMemoryCache cache,
    IHttpContextAccessor httpContextAccessor,
    ILogger<RbacAuthorizationService> logger) : IRbacAuthorizationService
{
    private static readonly TimeSpan CacheExpiry = TimeSpan.FromMinutes(5);

    public async Task<bool> HasAccessAsync(
        ClaimsPrincipal? user,
        string itemCodeOrId,
        RbacAccessType accessType,
        CancellationToken ct = default)
    {
        var roleName = user?.FindFirst(ClaimTypes.Role)?.Value;

        if (string.IsNullOrWhiteSpace(roleName) && httpContextAccessor.HttpContext != null)
        {
            roleName = httpContextAccessor.HttpContext.Request.Headers["X-User-Role"].FirstOrDefault();
        }

        if (string.IsNullOrWhiteSpace(roleName))
        {
            logger.LogWarning("RBAC check failed: No role found in claims or X-User-Role header.");
            return false;
        }

        return await HasRoleAccessAsync(roleName, itemCodeOrId, accessType, ct);
    }

    public async Task<bool> HasRoleAccessAsync(
        string roleName,
        string itemCodeOrId,
        RbacAccessType accessType,
        CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(roleName) || string.IsNullOrWhiteSpace(itemCodeOrId))
            return false;

        // Admin role always has full unrestricted access
        if (roleName.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            return true;

        var targetItemId = RbacCatalogCodes.ResolveId(itemCodeOrId);
        if (!targetItemId.HasValue)
        {
            logger.LogWarning("RBAC check failed: Unknown catalog code or ID '{ItemCodeOrId}'.", itemCodeOrId);
            return false;
        }

        var normalizedRole = roleName.Trim().ToLowerInvariant();
        var roleCacheKey = $"rbac_role_id_{normalizedRole}";
        if (!cache.TryGetValue(roleCacheKey, out Guid roleId))
        {
            var role = await db.Roles.AsNoTracking()
                .Where(r => r.DeletedAtUtc == null && r.Name.ToLower() == normalizedRole)
                .Select(r => new { r.Id })
                .FirstOrDefaultAsync(ct);

            if (role == null)
            {
                logger.LogWarning("RBAC check failed: Role '{RoleName}' was not found in auth.tbl_roles.", roleName);
                return false;
            }

            roleId = role.Id;
            cache.Set(roleCacheKey, roleId, CacheExpiry);
        }

        var permsCacheKey = $"rbac_perms_{roleId}";
        if (!cache.TryGetValue(permsCacheKey, out Dictionary<Guid, (short CanView, short CanManage)>? perms) || perms == null)
        {
            var dbPerms = await db.RolePermissions.AsNoTracking()
                .Where(p => p.RoleId == roleId && (p.CanView == 1 || p.CanManage == 1))
                .Select(p => new { p.ItemId, p.CanView, p.CanManage })
                .ToListAsync(ct);

            perms = dbPerms.ToDictionary(p => p.ItemId, p => (p.CanView, p.CanManage));
            cache.Set(permsCacheKey, perms, CacheExpiry);
        }

        if (perms.TryGetValue(targetItemId.Value, out var p))
        {
            return accessType switch
            {
                RbacAccessType.Manage => p.CanManage == 1,
                RbacAccessType.View => p.CanView == 1 || p.CanManage == 1,
                _ => false
            };
        }

        // If no explicit permissions exist in DB for this role yet (unconfigured role):
        if (perms.Count == 0)
        {
            // Manage access is strictly reserved for Admin (or explicit grants)
            if (accessType == RbacAccessType.Manage)
                return false;

            // Strict security items default to false when unconfigured
            var code = RbacCatalogCodes.ResolveCode(targetItemId.Value);
            var isStrict = string.Equals(code, "repository", StringComparison.OrdinalIgnoreCase) ||
                           string.Equals(code, "settings", StringComparison.OrdinalIgnoreCase) ||
                           string.Equals(code, "master", StringComparison.OrdinalIgnoreCase) ||
                           string.Equals(code, "roles-permissions", StringComparison.OrdinalIgnoreCase);

            return !isStrict;
        }

        return false;
    }

    public void InvalidateRoleCache(Guid roleId)
    {
        cache.Remove($"rbac_perms_{roleId}");
    }
}

