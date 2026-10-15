using PMS.API.Modules.Projects.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.ActionCentre.Models;

/// <summary>
/// Represents a central approval request across the platform (Scope Change, Leadership Change, Project End Date Extension, Profile Changes, Resource Allocation, etc.)
/// conforming to TK PMS Tool BRD V05.
/// </summary>
public class ApprovalRequest : BaseEntity
{
    public string RequestCode { get; set; } = string.Empty;

    /// <summary>
    /// ScopeChange, LeadershipChange, ProjectExtension, ProfileChanges, CertificationValidation, ResourceAllocation
    /// </summary>
    public string ApprovalType { get; set; } = string.Empty;

    public Guid? ProjectId { get; set; }

    public Project? Project { get; set; }

    public string? ProjectName { get; set; }

    public Guid? EmployeeId { get; set; }

    public string? EmployeeName { get; set; }

    public string? Department { get; set; }

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public Guid RequestedByEmployeeId { get; set; }

    public string RequestedByName { get; set; } = string.Empty;

    public string RequestedByRole { get; set; } = string.Empty;

    /// <summary>
    /// ReportingManager, PMO, Hod, SeniorProjectManager, ProjectManager
    /// </summary>
    public string? AssignedApproverRole { get; set; }

    public Guid? AssignedApproverEmployeeId { get; set; }

    public string? AssignedApproverName { get; set; }

    /// <summary>
    /// Pending, Approved, Rejected, RequestChanges, Hold
    /// </summary>
    public string Status { get; set; } = "Pending";

    /// <summary>
    /// Low, Medium, High, Critical
    /// </summary>
    public string Priority { get; set; } = "Medium";

    /// <summary>
    /// JSON serialized payload specific to the approval type.
    /// E.g. Scope Change: { scopeAction, scopeTitle, reason, serviceName }
    /// E.g. Leadership Change: { leadershipRole, newLeaderId, newLeaderName, effectiveDate, changeReason }
    /// E.g. Project Extension: { currentEndDate, proposedEndDate, daysExtended, reason }
    /// </summary>
    public string PayloadJson { get; set; } = "{}";

    public string? DecisionNotes { get; set; }

    public DateTime? DecidedAtUtc { get; set; }

    public Guid? DecidedByUserId { get; set; }

    public string? DecidedByName { get; set; }

    /// <summary>
    /// JSON serialized audit history array documenting status transitions and reviewer notes.
    /// </summary>
    public string AuditHistoryJson { get; set; } = "[]";
}
