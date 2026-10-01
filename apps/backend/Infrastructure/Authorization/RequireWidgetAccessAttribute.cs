using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace PMS.API.Infrastructure.Authorization;

public enum WidgetAccessRequirement
{
    View = 1,
    Manage = 2
}

[AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, AllowMultiple = true)]
public sealed class RequireWidgetAccessAttribute(string widgetKey, WidgetAccessRequirement requirement) 
    : Attribute, IAuthorizationFilter
{
    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;
        if (user.Identity?.IsAuthenticated != true)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        // Super-admin bypass (Admin, Dhanshree, CEO)
        var role = user.FindFirst(ClaimTypes.Role)?.Value?.ToLower();
        if (role is "admin" or "dhanshree" or "ceo")
            return;

        // Check widget claims: formatted as "<widget_key>:<can_view>,<can_manage>"
        var claims = user.FindAll("w");
        var match = claims.FirstOrDefault(c => c.Value.StartsWith($"{widgetKey}:", StringComparison.OrdinalIgnoreCase));

        if (match == null)
        {
            context.Result = new ForbidResult();
            return;
        }

        var parts = match.Value.Split(':')[1].Split(',');
        int canView = parts.Length > 0 && int.TryParse(parts[0], out var v) ? v : 0;
        int canManage = parts.Length > 1 && int.TryParse(parts[1], out var m) ? m : 0;

        bool authorized = requirement switch
        {
            WidgetAccessRequirement.View => canView == 1,
            WidgetAccessRequirement.Manage => canManage == 1,
            _ => false
        };

        if (!authorized)
        {
            context.Result = new ForbidResult();
        }
    }
}
