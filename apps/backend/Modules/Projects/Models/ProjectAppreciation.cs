using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Appreciation awarded to a project team member/resource under Project Health.
/// Stored in database schema 'project', table 'tbl_project_appreciations'.
/// </summary>
public class ProjectAppreciation : BaseEntity
{
    public Guid ProjectId { get; set; }

    public virtual Project? Project { get; set; }

    public Guid RecipientEmployeeId { get; set; }

    public string RecipientName { get; set; } = string.Empty;

    public string? RecipientEmail { get; set; }

    public string? RecipientRole { get; set; }

    public string Badge { get; set; } = "Star Performer";

    public string Message { get; set; } = string.Empty;

    public Guid? GivenByEmployeeId { get; set; }

    public string GivenByName { get; set; } = string.Empty;
}
