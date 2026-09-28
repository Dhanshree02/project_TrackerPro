using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Service sub-department (e.g. "Network Penetration Testing", "AWS Security Assessment").
/// Used directly in project naming convention.
/// </summary>
public class MstServiceSubDepartment : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public Guid DepartmentId { get; set; }

    public MstServiceDepartment? Department { get; set; }

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; }

    public ICollection<MstServiceCatalog> Services { get; set; } = [];
}
