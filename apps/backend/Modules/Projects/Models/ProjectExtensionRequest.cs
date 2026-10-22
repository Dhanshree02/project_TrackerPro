using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// A request to move a project's end date later.
/// Saving the row does not change the project end date and does not notify anyone.
/// Action Centre will deliver it to the tagged PMO approvers later.
/// </summary>
public class ProjectExtensionRequest : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public DateOnly CurrentEndDate { get; set; }

    public DateOnly RequestedEndDate { get; set; }

    public int ExtensionDays { get; set; }

    public string Reason { get; set; } = string.Empty;

    /// <summary>Pending until Action Centre approval is built.</summary>
    public string Status { get; set; } = "Pending";

    public Guid? RequestedByEmployeeId { get; set; }

    public string RequestedByName { get; set; } = string.Empty;

    public ICollection<ProjectExtensionApprover> Approvers { get; set; } = new List<ProjectExtensionApprover>();
}
