using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

public class ProjectIssue : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public string? ProjectCode { get; set; }

    public string ProjectName { get; set; } = string.Empty;

    public string IssueType { get; set; } = "Technical Related Issues";

    public string Priority { get; set; } = "Medium";

    public string Subject { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public string Status { get; set; } = "Open";

    public Guid? RaisedByEmployeeId { get; set; }

    public Employee? RaisedByEmployee { get; set; }

    public string RaisedByName { get; set; } = string.Empty;

    public string? RaisedByRole { get; set; }

    public ICollection<ProjectAlert> Alerts { get; set; } = new List<ProjectAlert>();
}
