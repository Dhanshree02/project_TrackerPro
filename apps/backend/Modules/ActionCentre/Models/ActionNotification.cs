using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.ActionCentre.Models;

/// <summary>
/// Represents an Action Centre Notification record assigned to an employee.
/// Stored in database schema 'action', table 'tbl_notifications'.
/// </summary>
public class ActionNotification : BaseEntity
{
    public Guid RecipientEmployeeId { get; set; }

    public Guid ProjectId { get; set; }

    public string? ProjectCode { get; set; }

    public string ProjectName { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;

    public string Type { get; set; } = "Issue Raised";

    public string Priority { get; set; } = "Medium";

    public string Status { get; set; } = "Pending";

    public bool Unread { get; set; } = true;

    public Guid? RaisedByEmployeeId { get; set; }

    public string RaisedByName { get; set; } = "System";

    public string? RelatedTask { get; set; }

    public Guid? IssueId { get; set; }

    public string? AcknowledgedBy { get; set; }

    public string? AcknowledgedDate { get; set; }

    public string? AcknowledgedTime { get; set; }

    public string HistoryJson { get; set; } = "[]";

    // Navigation properties
    public virtual Employee? RecipientEmployee { get; set; }

    public virtual Project? Project { get; set; }

    public virtual ProjectIssue? Issue { get; set; }
}
