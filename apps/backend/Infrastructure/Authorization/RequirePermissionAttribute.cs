using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using PMS.API.Infrastructure.Authentication;

namespace PMS.API.Infrastructure.Authorization;

/// <summary>
/// Declarative permission guard for controllers/actions. Usage:
/// <c>[RequirePermission(Permissions.WbsAllocate)]</c>.
/// The JWT must contain a <c>permission</c> claim matching the requested key.
/// </summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
public sealed class RequirePermissionAttribute(string permission) : Attribute, IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;

        if (user.Identity?.IsAuthenticated != true)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        if (!user.HasClaim(AuthClaimTypes.Permission, permission))
        {
            context.Result = new ForbidResult();
        }
    }
}
