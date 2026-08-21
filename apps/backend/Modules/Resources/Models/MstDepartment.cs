using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class MstDepartment : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public ICollection<MstDesignation> Designations { get; set; } = [];
}
