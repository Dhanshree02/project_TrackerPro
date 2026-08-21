using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class MstDesignation : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public Guid? DepartmentId { get; set; }

    public MstDepartment? Department { get; set; }

    public ICollection<MstRole> Roles { get; set; } = [];
}
