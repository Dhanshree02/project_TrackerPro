using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class MstReportingManager : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public string? Designation { get; set; }

    public string? Email { get; set; }

    public Guid? EmployeeId { get; set; }

    public Employee? Employee { get; set; }

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; } = 0;
}
