using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Feedback given to or requested for a project team member/resource.
/// Stored in database schema 'project', table 'tbl_project_feedbacks'.
/// </summary>
public class ProjectFeedback : BaseEntity
{
    public Guid ProjectId { get; set; }
    public virtual Project? Project { get; set; }

    public Guid EmployeeId { get; set; }
    public string EmployeeName { get; set; } = string.Empty;
    public string? EmployeeCode { get; set; }

    public Guid? ReportingManagerId { get; set; }
    public string? ReportingManagerName { get; set; }

    public Guid? SubmittedByEmployeeId { get; set; }
    public string SubmittedByName { get; set; } = string.Empty;

    public string FeedbackType { get; set; } = "DirectFeedback"; // "DirectFeedback" or "FeedbackRequest"

    public string? Strengths { get; set; }
    public string? AreasOfImprovement { get; set; }
    public string? Comments { get; set; }
    public int? Rating { get; set; }

    public string? RequestNote { get; set; }

    public string Status { get; set; } = "Submitted"; // "Submitted" for direct, "Pending", "Approved", "Rejected" for requests

    public string? CommentsJson { get; set; } = "[]";
    public string? HistoryJson { get; set; } = "[]";
}
