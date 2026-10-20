using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Customer interview scheduled for a project team member.
/// The file is not stored here — only the schedule, result, and comments.
/// </summary>
public class ProjectInterview : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public Guid EmployeeId { get; set; }

    public string ResourceName { get; set; } = string.Empty;

    public DateOnly InterviewDate { get; set; }

    public TimeOnly InterviewTime { get; set; }

    /// <summary>Pending, Selected, Rejected, or Postponed.</summary>
    public string Result { get; set; } = "Pending";

    public string? Comments { get; set; }
}
