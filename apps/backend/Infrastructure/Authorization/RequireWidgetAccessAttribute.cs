using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Users.Services;

namespace PMS.API.Infrastructure.Authorization;

public enum WidgetAccessLevel { View = 0, Manage = 1 }

[AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, AllowMultiple = true)]
public class RequireWidgetAccessAttribute : TypeFilterAttribute
{
    public string WidgetKey { get; }
    public WidgetAccessLevel Level { get; }

    public RequireWidgetAccessAttribute(string widgetKey, WidgetAccessLevel level = WidgetAccessLevel.View)
        : base(typeof(RequireWidgetAccessFilter))
    {
        WidgetKey = widgetKey;
        Level = level;
        Arguments = [widgetKey, level];
    }
}

public class RequireWidgetAccessFilter(
    string widgetKey,
    WidgetAccessLevel level,
    ICurrentUserService currentUser,
    IRbacWidgetService rbacService) : IAsyncActionFilter
{
    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var roleName = currentUser.Role;

        // 1. Super-admin roles bypass widget checks
        if (roleName is "Admin" or "Dhanshree")
        {
            await next();
            return;
        }

        if (string.IsNullOrEmpty(roleName))
        {
            context.Result = new ObjectResult(new { error = "Access Denied: Unauthenticated or missing role" })
            {
                StatusCode = StatusCodes.Status401Unauthorized
            };
            return;
        }

        // 2. Query effective permissions for role
        var permissions = await rbacService.GetEffectiveUserPermissionsAsync(roleName);
        if (!permissions.TryGetValue(widgetKey, out var perm))
        {
            context.Result = new ObjectResult(new { error = $"Access Denied: Missing widget entitlement for '{widgetKey}'" })
            {
                StatusCode = StatusCodes.Status403Forbidden
            };
            return;
        }

        var canView = perm.CanView;
        var canManage = perm.CanManage;

        if (level == WidgetAccessLevel.View && canView == 0)
        {
            context.Result = new ObjectResult(new { error = $"Access Denied: View permission required for '{widgetKey}'" })
            {
                StatusCode = StatusCodes.Status403Forbidden
            };
            return;
        }

        if (level == WidgetAccessLevel.Manage && canManage == 0)
        {
            context.Result = new ObjectResult(new { error = $"Access Denied: Manage permission required for '{widgetKey}'" })
            {
                StatusCode = StatusCodes.Status403Forbidden
            };
            return;
        }

        await next();
    }
}
