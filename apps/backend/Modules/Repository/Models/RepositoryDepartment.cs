using PMS.API.Modules.Resources.Models;

namespace PMS.API.Modules.Repository.Models;

/// <summary>
/// Junction: a repository document is visible to employees in this department.
/// </summary>
public class RepositoryDepartment
{
    public Guid RepositoryItemId { get; set; }

    public RepositoryItem? RepositoryItem { get; set; }

    public Guid DepartmentId { get; set; }

    public MstDepartment? Department { get; set; }
}
