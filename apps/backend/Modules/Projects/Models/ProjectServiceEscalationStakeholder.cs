using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// A PMO or Engagement Manager employee tagged on a service escalation.
/// </summary>
public class ProjectServiceEscalationStakeholder : BaseEntity
{
    public Guid EscalationId { get; set; }

    public ProjectServiceEscalation? Escalation { get; set; }

    public Guid EmployeeId { get; set; }

    public string EmployeeName { get; set; } = string.Empty;

    public string SubDepartment { get; set; } = string.Empty;

    public string Status { get; set; } = "Pending";
}
