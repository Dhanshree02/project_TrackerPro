using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.ActionCentre.Models;

/// <summary>
/// Represents an assigned task item appearing in a resource's Bucket List under the Action Center.
/// Stored in database schema 'action', table 'tbl_bucket_tasks'.
/// </summary>
public class BucketTask : BaseEntity
{
    public Guid TaskId { get; set; }

    public Guid ProjectId { get; set; }

    public Guid? ProjectServiceId { get; set; }

    public Guid? AssignmentId { get; set; }

    public Guid EmployeeId { get; set; }

    public Guid? AssignedById { get; set; }

    public string? AssignedByName { get; set; }

    public string TaskTitle { get; set; } = string.Empty;

    public string ProjectName { get; set; } = string.Empty;

    public string Priority { get; set; } = "Medium";

    /// <summary>
    /// Service End Date (Due Date of the task derived from the parent WBS service).
    /// </summary>
    public DateOnly? DueDate { get; set; }

    /// <summary>
    /// Current task stage / status (e.g., Not Started, Ready to Start, Ongoing, In Progress, Paused, Completed, Stopped).
    /// </summary>
    public string Status { get; set; } = "Not Started";

    /// <summary>
    /// Actual start date, recorded when the resource clicks start / starts the timer.
    /// </summary>
    public DateOnly? ActualStartDate { get; set; }

    /// <summary>
    /// Actual end date, recorded when the task stage is transitioned to Completed.
    /// </summary>
    public DateOnly? ActualEndDate { get; set; }

    public bool TimerRunning { get; set; }

    public DateTime? TimerStartedAtUtc { get; set; }

    public long TimerAccumulatedSeconds { get; set; }

    public decimal UtilizedHours { get; set; }

    // Navigation properties
    public ProjectTask? Task { get; set; }

    public Project? Project { get; set; }

    public ProjectServiceEntity? ProjectService { get; set; }

    public ProjectTaskAssignment? Assignment { get; set; }

    public Employee? Employee { get; set; }
}
