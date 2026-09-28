using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Project execution work item under a service or period/phase (Section B of WBS form and Execution view).
/// </summary>
public class ProjectTask : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public Guid? ProjectServiceId { get; set; }

    public ProjectServiceEntity? ProjectService { get; set; }

    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    /// <summary>Execution period / quarter e.g. "Q1", "Q2", "H1", "Annual".</summary>
    public string? Period { get; set; }

    /// <summary>Assessment Phase (AP) descriptor.</summary>
    public string? Phase { get; set; }

    /// <summary>
    /// Task execution stage:
    /// "Ready to Start", "Ongoing", "Completed", "On Hold (Internal)", "On Hold (Client End)", "After Release".
    /// </summary>
    public string Stage { get; set; } = "Ready to Start";

    /// <summary>Task priority: "low", "medium", "high", "critical".</summary>
    public string Priority { get; set; } = "medium";

    public DateOnly? PlannedStartDate { get; set; }

    public DateOnly? PlannedEndDate { get; set; }

    public DateOnly? ActualStartDate { get; set; }

    public DateOnly? ActualEndDate { get; set; }

    public decimal? EstimatedHours { get; set; }

    public decimal UtilizedHours { get; set; }

    /// <summary>Progress percentage (0-100).</summary>
    public int Progress { get; set; }

    public int SortOrder { get; set; }
}
