using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// One assign or unassign event for a task. The Task tab Assignment History Log reads these rows.
/// </summary>
public class ProjectTaskAssignmentHistory : BaseEntity
{
    public Guid TaskId { get; set; }

    public ProjectTask? Task { get; set; }

    public Guid EmployeeId { get; set; }

    public Employee? Employee { get; set; }

    /// <summary>"Assign" or "Unassign".</summary>
    public string Action { get; set; } = "Assign";

    /// <summary>Name at the time of the event, so the log stays readable later.</summary>
    public string ResourceName { get; set; } = string.Empty;

    /// <summary>"Project Team" or "Shadow Team" at the time of the event.</summary>
    public string TeamType { get; set; } = "Project Team";

    public DateTime OccurredAtUtc { get; set; } = DateTime.UtcNow;
}
