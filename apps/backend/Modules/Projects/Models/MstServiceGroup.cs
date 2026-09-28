using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Top-level group for project services: "Resource" or "Scope".
/// </summary>
public class MstServiceGroup : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; }

    public ICollection<MstServiceDepartment> Departments { get; set; } = [];
}
