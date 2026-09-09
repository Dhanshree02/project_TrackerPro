using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using PMS.API.Infrastructure.Authentication;
using PMS.API.Shared.Constants;

namespace PMS.API.Infrastructure.Authorization;

/// <summary>
/// Declarative permission guard for controllers/actions. Usage:
/// <c>[RequirePermission(Permissions.ClientsRead)]</c>.
/// Checks exact permission matches, equivalent hierarchical permission aliases,
/// and grants full access to SuperAdmin roles.
/// </summary>
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
public sealed class RequirePermissionAttribute(string permission) : Attribute, IAuthorizationFilter
{
    private static readonly Dictionary<string, string[]> Aliases = new(StringComparer.OrdinalIgnoreCase)
    {
        [Permissions.ClientsRead] = ["clients:read", "customers.view", "customers", "clients:write", "customers.create", "customers.edit", "clients:approve", "customers.approve"],
        [Permissions.ClientsWrite] = ["clients:write", "customers.create", "customers.edit", "customers.delete", "customers"],
        [Permissions.ClientsApprove] = ["clients:approve", "customers.approve"],
        [Permissions.ProjectsRead] = ["projects:read", "projects.view", "projects", "projects:write", "projects.create", "projects.overview.view", "projects.overview.edit"],
        [Permissions.ProjectsWrite] = ["projects:write", "projects.create", "projects.overview.edit", "projects"],
        [Permissions.ProjectsClose] = ["projects:close", "projects"],
        [Permissions.WbsRead] = ["wbs:read", "projects.wbs.view", "projects.tab.wbs", "wbs.view", "wbs:allocate", "projects.wbs.project_allocation"],
        [Permissions.WbsAllocate] = ["wbs:allocate", "projects.wbs.project_allocation", "wbs.allocate"],
        [Permissions.TimesheetsSubmit] = ["timesheets:submit", "timesheet.my", "my-team.my-timesheet.submit", "my-team.my-timesheet.view"],
        [Permissions.TimesheetsApprove] = ["timesheets:approve", "timesheet.approve", "my-team.timesheet-approval.approve", "my-team.timesheet-approval.view"],
        [Permissions.TimesheetsMonitor] = ["timesheets:monitor", "timesheet.approve", "my-team.timesheet-approval.view", "timesheets:approve"],
        [Permissions.IssuesRaise] = ["issues:raise", "projects.health.raise-issue", "projects.health.view", "projects.tab.health", "issues:manage", "projects.health.manage"],
        [Permissions.IssuesManage] = ["issues:manage", "projects.health.manage", "projects.health.resolve-issue", "projects.health.edit-issue"],
        [Permissions.InvoicesRaise] = ["invoices:raise", "projects.tab.invoices", "projects.invoices.view", "projects.invoice-schedule.manage", "projects.invoice-schedule.view"],
        [Permissions.InvoicesPayment] = ["invoices:payment", "projects.tab.invoices", "projects.invoice-schedule.manage"],
        [Permissions.ResourcesRead] = ["resources:read", "resources.view", "resources.directory.view", "resources", "resources:manage", "resources.manage"],
        [Permissions.ResourcesManage] = ["resources:manage", "resources.manage", "resources.add_employee", "resources.directory.add-employee", "resources.profile.edit"],
        [Permissions.ReportsRead] = ["reports:read", "reports.view", "reports", "reports.export"],
        [Permissions.RolesManage] = ["roles:manage", "settings.manage_roles", "settings.roles.manage", "settings.view"],
        [Permissions.UsersManage] = ["users:manage", "settings.manage_roles", "settings.roles.manage", "settings.view"],
        [Permissions.AuditRead] = ["audit:read", "settings.audit.view", "settings.view"],
    };

    public void OnAuthorization(AuthorizationFilterContext context)
    {
        var user = context.HttpContext.User;

        if (user.Identity?.IsAuthenticated != true)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        // Super-admin bypass: Admin / Dhanshree / role with full access
        var role = user.FindFirst(ClaimTypes.Role)?.Value;
        if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(role, "Dhanshree", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(role, "SuperAdmin", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        // Exact match
        if (user.HasClaim(AuthClaimTypes.Permission, permission))
        {
            return;
        }

        // Check aliases if configured
        if (Aliases.TryGetValue(permission, out var equivalentKeys))
        {
            foreach (var key in equivalentKeys)
            {
                if (user.HasClaim(AuthClaimTypes.Permission, key))
                {
                    return;
                }
            }
        }

        context.Result = new ForbidResult();
    }
}
