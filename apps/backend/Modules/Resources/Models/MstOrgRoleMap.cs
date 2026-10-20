using PMS.API.Modules.Users.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>
/// One row per designation: Department → Designation → Sub-Department → On Floor → RBAC.
/// Catalogs stay in their own tables; this is the only mapping.
/// </summary>
public class MstOrgRoleMap : BaseEntity
{
    public Guid? DepartmentId { get; set; }

    public MstDepartment? Department { get; set; }

    public Guid DesignationId { get; set; }

    public MstDesignation? Designation { get; set; }

    public string? SubDepartment { get; set; }

    public Guid? OnFloorRoleId { get; set; }

    public MstRole? OnFloorRole { get; set; }

    public Guid? RbacRoleId { get; set; }

    public Role? RbacRole { get; set; }
}
