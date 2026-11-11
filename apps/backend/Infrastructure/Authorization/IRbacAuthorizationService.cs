using System.Security.Claims;

namespace PMS.API.Infrastructure.Authorization;

public interface IRbacAuthorizationService
{
    Task<bool> HasAccessAsync(ClaimsPrincipal? user, string itemCodeOrId, RbacAccessType accessType, CancellationToken ct = default);
    Task<bool> HasRoleAccessAsync(string roleName, string itemCodeOrId, RbacAccessType accessType, CancellationToken ct = default);
    void InvalidateRoleCache(Guid roleId);
}

