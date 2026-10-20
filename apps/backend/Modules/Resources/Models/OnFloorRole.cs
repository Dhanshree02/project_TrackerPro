using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>
/// One mapped on-floor role for a designation.
/// Department, sub-department, and RBAC role are the ids from <c>docs/rbac.xlsx</c>.
/// </summary>
public class OnFloorRole : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    public Guid? DepartmentId { get; set; }

    public MstDepartment? Department { get; set; }

    public Guid DesignationId { get; set; }

    public MstDesignation? Designation { get; set; }

    public string? SubDepartment { get; set; }

    public Guid? RbacRoleId { get; set; }

    public Role? RbacRole { get; set; }
}
