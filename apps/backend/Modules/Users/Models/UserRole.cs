namespace PMS.API.Modules.Users.Models;

/// <summary>
/// System role keys — the canonical set of seeded roles. Kept in sync with the
/// frontend <c>Role</c> type in <c>apps/frontend/src/lib/mock-data.ts</c> and
/// the RBAC matrix (wiki/23_Security_and_RBAC.md).
///
/// <c>Role.Name</c> is a free-text string (system roles use these enum names as
/// their keys; custom roles created by an administrator may use any unique key).
/// </summary>
public enum UserRole
{
    SeniorPm,
    EngagementManager,
    Pmo,
    Hod,
    BusinessOwner,
    Dhanshree,
    Sales,
    Accounts,
    Hr,
    ProjectManager,
    TeamLead,
    Employee,

    /// <summary>Super-admin role — full access to every module and action.</summary>
    Admin,
}
