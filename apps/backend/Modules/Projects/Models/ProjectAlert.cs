using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

public class ProjectAlert : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public Guid? IssueId { get; set; }

    public ProjectIssue? Issue { get; set; }

    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    public string AlertType { get; set; } = "Issue";

    public string Priority { get; set; } = "Medium";

    public string Status { get; set; } = "Open";

    public Guid? RaisedByEmployeeId { get; set; }

    public Employee? RaisedByEmployee { get; set; }

    public string RaisedByName { get; set; } = string.Empty;

    /// <summary>
    /// Comma-separated or JSON list of target audience user/employee IDs
    /// </summary>
    public string? AudienceUserIds { get; set; }

    public string? Owner { get; set; }

    public string? ResolutionOwner { get; set; }

    public string? EscalationOwner { get; set; }

    public string? ResolutionDetails { get; set; }

    public string HistoryJson { get; set; } = "[]";
}
