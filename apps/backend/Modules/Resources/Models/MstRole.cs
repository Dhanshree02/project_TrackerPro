using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>
/// Job-role catalog under a designation (not the RBAC <c>roles</c> table).
/// </summary>
public class MstRole : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public Guid DesignationId { get; set; }

    public MstDesignation Designation { get; set; } = null!;
}
