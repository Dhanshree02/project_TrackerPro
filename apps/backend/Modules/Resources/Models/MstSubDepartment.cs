using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>
/// Org sub-department catalog. Other tables store <see cref="Id"/>, not the name.
/// </summary>
public class MstSubDepartment : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public Guid? DepartmentId { get; set; }

    public MstDepartment? Department { get; set; }
}
