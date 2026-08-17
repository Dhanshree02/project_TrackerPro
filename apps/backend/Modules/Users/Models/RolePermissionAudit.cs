using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Users.Models;

/// <summary>
/// Audit trail for role/permission changes made through the Settings → Role &
/// Access Management UI. One row per changed permission (grant/revoke), with
/// before/after values and the administrator who made the change.
/// </summary>
public class RolePermissionAudit : BaseEntity
{
    public Guid RoleId { get; set; }

    public Role? Role { get; set; }

    /// <summary>Role display name at the time of the change (snapshot).</summary>
    public string RoleName { get; set; } = string.Empty;

    public string ModuleKey { get; set; } = string.Empty;

    public string ModuleLabel { get; set; } = string.Empty;

    public string? SubmoduleKey { get; set; }

    public string? SubmoduleLabel { get; set; }

    public string PermissionKey { get; set; } = string.Empty;

    public string ActionLabel { get; set; } = string.Empty;

    /// <summary>"granted" | "revoked"</summary>
    public string ChangeType { get; set; } = string.Empty;

    public string PreviousValue { get; set; } = string.Empty;

    public string NewValue { get; set; } = string.Empty;

    public Guid? ChangedById { get; set; }

    public string? ChangedByName { get; set; }
}
