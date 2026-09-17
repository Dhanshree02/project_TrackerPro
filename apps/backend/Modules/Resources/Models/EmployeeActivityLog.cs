using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class EmployeeActivityLog : BaseEntity
{
    public Guid EmployeeId { get; set; }

    public string Action { get; set; } = string.Empty; // "Created", "Updated", "Offboarded"

    public string PerformedByEmail { get; set; } = string.Empty;

    public string? PerformedByName { get; set; }

    public string? Details { get; set; }

    public Employee? Employee { get; set; }
}
