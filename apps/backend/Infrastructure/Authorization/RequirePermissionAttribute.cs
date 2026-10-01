using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Shared.Constants;

namespace PMS.API.Infrastructure.Authorization;

/// <summary>
/// Declarative permission guard for controllers/actions. Usage:
/// <c>[RequirePermission(Permissions.ProjectsRead)]</c>.
/// Checks for direct claim, canonical permission aliases, super-admin privileges,
/// and dynamic module/widget permissions from the database.
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

        // 1. Super Admins always have full access
        var role = user.FindFirst(ClaimTypes.Role)?.Value;
        if (!string.IsNullOrEmpty(role) && (
            role.Equals("Admin", StringComparison.OrdinalIgnoreCase) ||
            role.Equals("CEO", StringComparison.OrdinalIgnoreCase) ||
            role.Equals("COO", StringComparison.OrdinalIgnoreCase) ||
            role.Equals("Dhanshree", StringComparison.OrdinalIgnoreCase)))
        {
            return;
        }

        // 2. Direct permission claim
        if (user.HasClaim(AuthClaimTypes.Permission, permission))
        {
            return;
        }

        // 3. Canonical permission alias resolution
        var claims = user.FindAll(AuthClaimTypes.Permission).Select(c => c.Value).ToHashSet(StringComparer.OrdinalIgnoreCase);

        if (IsAliasSatisfied(permission, claims))
        {
            return;
        }

        // 4. Dynamic DB check against role_widget_permissions
        try
        {
            var db = context.HttpContext.RequestServices.GetService(typeof(AppDbContext)) as AppDbContext;
            if (db != null)
            {
                var roleIdStr = user.FindFirst(AuthClaimTypes.RoleId)?.Value ?? user.FindFirst("role_id")?.Value;
                Guid? roleId = Guid.TryParse(roleIdStr, out var parsedId) ? parsedId : null;

                if (!roleId.HasValue && !string.IsNullOrEmpty(role))
                {
                    var foundRole = db.Roles.AsNoTracking().FirstOrDefault(r => r.Name == role);
                    roleId = foundRole?.Id;
                }

                if (roleId.HasValue && HasDynamicDatabaseAccess(db, roleId.Value, permission))
                {
                    return;
                }
            }
        }
        catch
        {
            // Fallback to strict claim check on DB error
        }

        context.Result = new ForbidResult();
    }

    private static bool IsAliasSatisfied(string requiredPerm, HashSet<string> userPerms)
    {
        // Projects Read
        if (requiredPerm.Equals(Permissions.ProjectsRead, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("projects.view") ||
                userPerms.Contains("projects:read") ||
                userPerms.Contains("projects.assigned-projects.view") ||
                userPerms.Contains("projects.overview.view") ||
                userPerms.Contains("projects.overview") ||
                userPerms.Any(p => p.StartsWith("projects.", StringComparison.OrdinalIgnoreCase)))
            {
                return true;
            }
        }

        // Projects Write
        if (requiredPerm.Equals(Permissions.ProjectsWrite, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("projects.create") ||
                userPerms.Contains("projects.manage") ||
                userPerms.Contains("projects.edit") ||
                userPerms.Contains("projects.overview.edit") ||
                userPerms.Any(p => p.StartsWith("projects.", StringComparison.OrdinalIgnoreCase) && p.EndsWith(".manage", StringComparison.OrdinalIgnoreCase)))
            {
                return true;
            }
        }

        // WBS Read
        if (requiredPerm.Equals(Permissions.WbsRead, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("wbs.view") ||
                userPerms.Contains("wbs:read") ||
                userPerms.Contains("projects.wbs") ||
                userPerms.Contains("projects.wbs.view") ||
                userPerms.Contains("projects.view") ||
                userPerms.Contains(Permissions.ProjectsRead))
            {
                return true;
            }
        }

        // Clients / Customers Read
        if (requiredPerm.Equals(Permissions.ClientsRead, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("customers.view") ||
                userPerms.Contains("clients:read") ||
                userPerms.Any(p => p.StartsWith("customers.", StringComparison.OrdinalIgnoreCase)))
            {
                return true;
            }
        }

        // Clients Write
        if (requiredPerm.Equals(Permissions.ClientsWrite, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("customers.create") ||
                userPerms.Contains("customers.edit") ||
                userPerms.Contains("customers.manage") ||
                userPerms.Contains("clients:write"))
            {
                return true;
            }
        }

        // Resources Read
        if (requiredPerm.Equals(Permissions.ResourcesRead, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("resources.view") ||
                userPerms.Contains("resources.directory.view") ||
                userPerms.Contains("resources:read") ||
                userPerms.Any(p => p.StartsWith("resources.", StringComparison.OrdinalIgnoreCase)))
            {
                return true;
            }
        }

        // Resources Manage
        if (requiredPerm.Equals(Permissions.ResourcesManage, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("resources.manage") ||
                userPerms.Contains("resources:manage"))
            {
                return true;
            }
        }

        // Reports Read
        if (requiredPerm.Equals(Permissions.ReportsRead, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("reports.view") ||
                userPerms.Contains("reports:read") ||
                userPerms.Any(p => p.StartsWith("reports.", StringComparison.OrdinalIgnoreCase)))
            {
                return true;
            }
        }

        // Timesheets Submit
        if (requiredPerm.Equals(Permissions.TimesheetsSubmit, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("timesheets:submit") ||
                userPerms.Contains("my-team.my-timesheet.submit") ||
                userPerms.Contains("my-team.my-timesheet.view") ||
                userPerms.Contains("timesheet.my"))
            {
                return true;
            }
        }

        // Timesheets Approve
        if (requiredPerm.Equals(Permissions.TimesheetsApprove, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("timesheets:approve") ||
                userPerms.Contains("my-team.timesheet-approval.approve") ||
                userPerms.Contains("my-team.timesheet-approval.view") ||
                userPerms.Contains("timesheet.approve"))
            {
                return true;
            }
        }

        // Issues Raise
        if (requiredPerm.Equals(Permissions.IssuesRaise, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("issues:raise") ||
                userPerms.Contains("projects.health.raise-issue") ||
                userPerms.Contains("projects.health-issues.create"))
            {
                return true;
            }
        }

        // Issues Manage
        if (requiredPerm.Equals(Permissions.IssuesManage, StringComparison.OrdinalIgnoreCase))
        {
            if (userPerms.Contains("issues:manage") ||
                userPerms.Contains("projects.health.manage") ||
                userPerms.Contains("projects.health-issues.resolve") ||
                userPerms.Contains("projects.health-issues.edit"))
            {
                return true;
            }
        }

        return false;
    }

    private static bool HasDynamicDatabaseAccess(AppDbContext db, Guid roleId, string requiredPerm)
    {
        // Query permissions for this role
        var query = db.RoleWidgetPermissions
            .AsNoTracking()
            .Include(p => p.Widget)
            .Where(p => p.RoleId == roleId);

        if (requiredPerm.Equals(Permissions.ProjectsRead, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanView == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("projects.", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.ProjectsWrite, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanManage == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("projects.", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.WbsRead, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanView == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("projects.", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.ClientsRead, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanView == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("customers.", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.ClientsWrite, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanManage == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("customers.", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.ResourcesRead, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanView == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("resources.", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.ResourcesManage, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanManage == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("resources.", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.ReportsRead, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanView == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("reports.", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.TimesheetsSubmit, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => p.CanView == 1 &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("my_team.my_timesheet", StringComparison.OrdinalIgnoreCase));
        }

        if (requiredPerm.Equals(Permissions.TimesheetsApprove, StringComparison.OrdinalIgnoreCase))
        {
            return query.Any(p => (p.CanView == 1 || p.CanManage == 1) &&
                p.Widget != null &&
                p.Widget.WidgetKey.StartsWith("my_team.timesheet_approval", StringComparison.OrdinalIgnoreCase));
        }

        return false;
    }
}
