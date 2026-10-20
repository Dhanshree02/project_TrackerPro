using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>
/// Canonical On-Floor Role catalog (10 roles from <c>docs/rbac.xlsx</c>; not the RBAC <c>tbl_roles</c> table).
/// </summary>
public class MstRole : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public Guid? DesignationId { get; set; }

    public MstDesignation? Designation { get; set; }
}
