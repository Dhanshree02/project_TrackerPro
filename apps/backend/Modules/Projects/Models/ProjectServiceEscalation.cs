using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Escalation raised from Service wise Prerequisite Tracking.
/// Saving the row does not notify Action Centre. That delivery comes later.
/// </summary>
public class ProjectServiceEscalation : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public Guid? ProjectServiceId { get; set; }

    public string? ProjectCode { get; set; }

    public string ProjectName { get; set; } = string.Empty;

    public string? CustomerName { get; set; }

    public string ServiceName { get; set; } = string.Empty;

    public string EscalationType { get; set; } = string.Empty;

    public string Priority { get; set; } = "High";

    public string Subject { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public DateOnly? ExpectedResolutionDate { get; set; }

    public string? AttachmentFileName { get; set; }

    /// <summary>Path under Documents/, for example Escalation/20261022_file.pdf.</summary>
    public string? AttachmentPath { get; set; }

    public string? AttachmentContentType { get; set; }

    public long? AttachmentSizeBytes { get; set; }

    /// <summary>Open until Action Centre can resolve it.</summary>
    public string Status { get; set; } = "Open";

    public Guid? RaisedByEmployeeId { get; set; }

    public string RaisedByName { get; set; } = string.Empty;

    public ICollection<ProjectServiceEscalationStakeholder> Stakeholders { get; set; } = new List<ProjectServiceEscalationStakeholder>();
}
