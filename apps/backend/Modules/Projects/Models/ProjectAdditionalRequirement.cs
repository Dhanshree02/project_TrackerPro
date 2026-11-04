using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Represents an additional customer requirement or scope cancellation request logged under Project Health.
/// Stored in database schema 'project', table 'tbl_project_additional_requirements'.
/// </summary>
public class ProjectAdditionalRequirement : BaseEntity
{
    public string RequirementId { get; set; } = string.Empty;

    public Guid ProjectId { get; set; }

    public virtual Project? Project { get; set; }

    public string? ClientName { get; set; }

    public string? ProjectName { get; set; }

    public string RequirementType { get; set; } = "Add Service"; // "Add Service" or "Scope Cancellation"

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public string Priority { get; set; } = "Medium";

    public Guid? RequestedByEmployeeId { get; set; }

    public string RequestedByName { get; set; } = string.Empty;

    public DateOnly RequestedDate { get; set; }

    public string? AttachmentFileName { get; set; }

    public string? AttachmentPath { get; set; }

    public string? ScopeCancellationService { get; set; }

    public string Status { get; set; } = "Open"; // "Open", "Approved", "Rejected"

    public DateTime? ApprovedAtUtc { get; set; }

    public Guid? ApprovedByEmployeeId { get; set; }

    public string? ApprovedByName { get; set; }

    public string? ApprovalComments { get; set; }

    public string CommentsJson { get; set; } = "[]";

    public string HistoryJson { get; set; } = "[]";
}
