using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Resource allocation and execution tracking for a project task.
/// </summary>
public class ProjectTaskAssignment : BaseEntity
{
    public Guid TaskId { get; set; }

    public ProjectTask? Task { get; set; }

    public Guid EmployeeId { get; set; }

    public Employee? Employee { get; set; }

    /// <summary>Assigned role on the task: e.g. "Lead", "Contributor", "Reviewer".</summary>
    public string Role { get; set; } = "Contributor";

    public decimal? AllocatedHours { get; set; }

    public decimal UtilizedHours { get; set; }

    /// <summary>UTC timestamp when the live execution timer was started, if currently active.</summary>
    public DateTime? TimerStartedAtUtc { get; set; }

    /// <summary>Accumulated active timer runtime in seconds.</summary>
    public long TimerAccumulatedSeconds { get; set; }

    /// <summary>Whether this assignment is currently active.</summary>
    public bool IsActive { get; set; } = true;
}
