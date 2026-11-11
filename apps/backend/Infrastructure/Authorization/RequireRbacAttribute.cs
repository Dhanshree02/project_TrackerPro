using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Infrastructure.Authorization;

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
public sealed class RequireRbacAttribute : Attribute, IAsyncActionFilter, IOrderedFilter
{
    public string ItemCodeOrId { get; }
    public RbacAccessType AccessType { get; }
    public string[] FallbackCodes { get; }
    public int Order { get; set; } = -100;

    public RequireRbacAttribute(string itemCodeOrId, RbacAccessType accessType = RbacAccessType.Manage, params string[] fallbackCodes)
    {
        ItemCodeOrId = itemCodeOrId;
        AccessType = accessType;
        FallbackCodes = fallbackCodes;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var rbacService = context.HttpContext.RequestServices.GetRequiredService<IRbacAuthorizationService>();
        var user = context.HttpContext.User;

        var authorized = await rbacService.HasAccessAsync(user, ItemCodeOrId, AccessType, context.HttpContext.RequestAborted);

        if (!authorized && FallbackCodes != null && FallbackCodes.Length > 0)
        {
            foreach (var fallback in FallbackCodes)
            {
                if (await rbacService.HasAccessAsync(user, fallback, AccessType, context.HttpContext.RequestAborted))
                {
                    authorized = true;
                    break;
                }
            }
        }

        if (!authorized)
        {
            var msg = AccessType == RbacAccessType.Manage
                ? "You do not have permission to manage this section."
                : "You do not have permission to view this section.";

            context.Result = new ObjectResult(ApiResponse<object>.Fail("FORBIDDEN", msg))
            {
                StatusCode = StatusCodes.Status403Forbidden
            };
            return;
        }

        await next();
    }
}
