using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Project onboarding draft snapshot. A draft is a shared workflow resource,
/// distinct from a finalized Project entity.
/// </summary>
public class ProjectDraft : BaseEntity
{
    public string ProjectName { get; set; } = string.Empty;

    public Guid? ClientId { get; set; }

    public string? ClientName { get; set; }

    public string? SalesPerson { get; set; }

    /// <summary>
    /// Complete serialized JSON representation of the project onboarding form state.
    /// </summary>
    public string FormSnapshotJson { get; set; } = "{}";

    public string CreatedByName { get; set; } = string.Empty;

    public string? UpdatedByName { get; set; }

    /// <summary>
    /// Lifecycle status of draft: "active" (still being worked on) or "converted" (WBS created).
    /// </summary>
    public string Status { get; set; } = "active";

    /// <summary>
    /// PostgreSQL xmin system column mapped for optimistic concurrency control.
    /// </summary>
    public uint RowVersion { get; set; }
}
