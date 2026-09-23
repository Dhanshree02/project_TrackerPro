using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Service domain department (e.g. "Penetration Testing", "Vulnerability Assessment", "Cloud Security").
/// Distinct from HR departments in mst_departments.
/// </summary>
public class MstServiceDepartment : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public Guid GroupId { get; set; }

    public MstServiceGroup? Group { get; set; }

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; }

    public ICollection<MstServiceSubDepartment> SubDepartments { get; set; } = [];
}
