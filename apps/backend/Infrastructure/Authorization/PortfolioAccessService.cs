using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Resources.Models;

namespace PMS.API.Infrastructure.Authorization;

/// <summary>
/// Who the signed-in person may see on Customers and Projects.
/// Engagement Managers and Sales Managers only see the records they are assigned on.
/// </summary>
public sealed record PortfolioAccess(
    bool Unrestricted,
    bool EngagementManager,
    bool SalesManager,
    Guid? EmployeeId,
    string? EmployeeName)
{
    public bool LimitsToAssignments => EngagementManager || SalesManager;
}

public interface IPortfolioAccessService
{
    Task<PortfolioAccess> ResolveAsync(CancellationToken ct = default);
}

public sealed class PortfolioAccessService(AppDbContext db, ICurrentUserService currentUser) : IPortfolioAccessService
{
    private static readonly HashSet<string> GlobalVisibilityRoleNames = new(StringComparer.OrdinalIgnoreCase)
    {
        "Admin", "Dhanshree", "CEO", "COO", "CTO", "PMO", "Pmo", "Hod", "BusinessOwner",
        "Sales", "Sales team member", "Accounts", "HR", "Hr", "IT Admin",
        "Testing HOD", "Consulting-HOD", "SOC-HOD",
    };

    private static readonly string[] EngagementManagerDesignations =
    [
        "Delivery Account Manager - I",
        "Delivery Account Manager - II",
        "Senior Delivery Account Manager - I",
        "Senior Delivery Account Manager - II",
        "Engagement Manager",
    ];

    private static readonly string[] SalesManagerDesignations =
    [
        "Business Development Associate - I",
        "Customer Success Representative - II",
        "Sales Manager",
    ];

    public async Task<PortfolioAccess> ResolveAsync(CancellationToken ct = default)
    {
        var role = currentUser.Role?.Trim() ?? "";
        if (GlobalVisibilityRoleNames.Contains(role))
            return new PortfolioAccess(true, false, false, null, null);

        var employee = await FindEmployeeAsync(ct);
        var designation = employee?.Designation?.Name;
        var subDepartment = employee?.SubDepartmentRef?.Name ?? employee?.SubDepartment;

        var isEngagementManager =
            RoleIs(role, "EngagementManager", "Engagement Manager") ||
            DesignationIs(designation, EngagementManagerDesignations) ||
            ContainsText(subDepartment, "Engagement Manager");

        var isSalesManager =
            RoleIs(role, "Sales Manager") ||
            DesignationIs(designation, SalesManagerDesignations);

        var name = employee is null
            ? null
            : string.Join(' ', new[] { employee.FirstName, employee.LastName }.Where(part => !string.IsNullOrWhiteSpace(part))).Trim();
        if (name?.Length == 0) name = null;

        return new PortfolioAccess(false, isEngagementManager, isSalesManager, employee?.Id, name);
    }

    private async Task<Employee?> FindEmployeeAsync(CancellationToken ct)
    {
        var id = currentUser.UserId;
        if (id.HasValue)
        {
            var byEmployeeId = await Employees().FirstOrDefaultAsync(e => e.Id == id.Value, ct);
            if (byEmployeeId is not null) return byEmployeeId;

            var loginEmail = await db.Users.AsNoTracking()
                .Where(u => u.Id == id.Value)
                .Select(u => u.Email)
                .FirstOrDefaultAsync(ct);
            var email = string.IsNullOrWhiteSpace(loginEmail) ? currentUser.Email : loginEmail;
            if (!string.IsNullOrWhiteSpace(email))
            {
                var normalized = email.Trim().ToLower();
                return await Employees().FirstOrDefaultAsync(e => e.WorkEmail.ToLower() == normalized, ct);
            }
        }

        if (!string.IsNullOrWhiteSpace(currentUser.Email))
        {
            var normalized = currentUser.Email.Trim().ToLower();
            return await Employees().FirstOrDefaultAsync(e => e.WorkEmail.ToLower() == normalized, ct);
        }

        return null;
    }

    private IQueryable<Employee> Employees() =>
        db.Employees.AsNoTracking()
            .Include(e => e.Designation)
            .Include(e => e.SubDepartmentRef);

    private static bool RoleIs(string role, params string[] names) =>
        names.Any(name => string.Equals(role, name, StringComparison.OrdinalIgnoreCase));

    private static bool DesignationIs(string? designation, IEnumerable<string> names)
    {
        if (string.IsNullOrWhiteSpace(designation)) return false;
        return names.Any(name => string.Equals(designation.Trim(), name, StringComparison.OrdinalIgnoreCase));
    }

    private static bool ContainsText(string? value, string needle) =>
        !string.IsNullOrWhiteSpace(value) &&
        value.Contains(needle, StringComparison.OrdinalIgnoreCase);
}
