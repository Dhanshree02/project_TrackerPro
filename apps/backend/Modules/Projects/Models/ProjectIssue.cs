using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Project issue entity tracked across the 2-day escalation hierarchy:
/// PM (Level 1) → SPM (Level 2) → EM (Level 3) → PMO (Level 4) → HOD (Level 5) → CEO (Level 6).
/// </summary>
public class ProjectIssue : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Category: "Technical Related Issues", "Behavioral Related Issues", "Process Related Issues".
    /// </summary>
    public string Category { get; set; } = "Technical Related Issues";

    /// <summary>
    /// Priority: "Low", "Medium", "High", "Critical".
    /// </summary>
    public string Priority { get; set; } = "Medium";

    /// <summary>
    /// Status: "Open", "In Progress", "Resolved", "Closed".
    /// </summary>
    public string Status { get; set; } = "Open";

    public Guid? RaisedByEmployeeId { get; set; }

    public Employee? RaisedByEmployee { get; set; }

    public string RaisedByName { get; set; } = string.Empty;

    public string RaisedByRole { get; set; } = string.Empty;

    /// <summary>
    /// Escalation level (1 to 6):
    /// 1 = PM
    /// 2 = SPM
    /// 3 = EM
    /// 4 = PMO
    /// 5 = HOD
    /// 6 = CEO
    /// </summary>
    public int EscalationLevel { get; set; } = 1;

    /// <summary>
    /// Current assignee role: "PM", "SPM", "EM", "PMO", "HOD", "CEO".
    /// </summary>
    public string CurrentAssigneeRole { get; set; } = "PM";

    public Guid? CurrentAssigneeEmployeeId { get; set; }

    public string? CurrentAssigneeName { get; set; }

    public Guid? DottedLineManagerId { get; set; }

    public string? DottedLineManagerName { get; set; }

    public DateTime? LastEscalatedAtUtc { get; set; }

    public DateTime? ResolvedAtUtc { get; set; }

    public string? ResolvedByName { get; set; }

    public string? ResolutionNotes { get; set; }

    /// <summary>
    /// JSON array storing audit timeline and escalation history.
    /// </summary>
    public string? AuditHistoryJson { get; set; }
}
