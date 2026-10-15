using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.ActionCentre.Models;

/// <summary>
/// Represents a system governance alert in the Action Centre, conforming to TK PMS Tool BRD V05.
/// Tracks delivery SLA, issue escalation SLA, change management SLA, daily bench count, and timesheet breaches.
/// </summary>
public class Alert : BaseEntity
{
    public string AlertCode { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// DeliveryTatBreach, EscalationTatBreach, ChangeManagementTatBreach, DailyOnBenchCount, TimesheetTatBreach
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Low, Medium, High, Critical
    /// </summary>
    public string Severity { get; set; } = "Medium";

    /// <summary>
    /// Open, Acknowledged, InProgress, Resolved, Closed
    /// </summary>
    public string Status { get; set; } = "Open";

    public Guid? ProjectId { get; set; }

    public Project? Project { get; set; }

    public string? ProjectName { get; set; }

    public Guid? ClientId { get; set; }

    public Client? Client { get; set; }

    public string? ClientName { get; set; }

    /// <summary>
    /// Project, ProjectTask, ProjectIssue, ProjectDraft, TimesheetWeek, ResourcePool
    /// </summary>
    public string SourceEntity { get; set; } = string.Empty;

    public string SourceEntityId { get; set; } = string.Empty;

    public string TriggerCondition { get; set; } = string.Empty;

    public Guid? OwnerEmployeeId { get; set; }

    public string? OwnerName { get; set; }

    public string? ResolutionDetails { get; set; }

    public DateTime? AcknowledgedAtUtc { get; set; }

    public Guid? AcknowledgedByUserId { get; set; }

    public string? AcknowledgedByName { get; set; }

    public DateTime? ResolvedAtUtc { get; set; }

    public Guid? ResolvedByUserId { get; set; }

    public string? ResolvedByName { get; set; }

    /// <summary>
    /// JSON serialized audit entries documenting the lifecycle of the alert.
    /// </summary>
    public string AuditHistoryJson { get; set; } = "[]";
}
