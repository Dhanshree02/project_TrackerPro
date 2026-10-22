using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// A PMO employee tagged on an extension request.
/// The decision stays Pending until Action Centre approval is built.
/// </summary>
public class ProjectExtensionApprover : BaseEntity
{
    public Guid ExtensionRequestId { get; set; }

    public ProjectExtensionRequest? ExtensionRequest { get; set; }

    public Guid EmployeeId { get; set; }

    public string EmployeeName { get; set; } = string.Empty;

    /// <summary>Pending until the approver accepts or rejects the request.</summary>
    public string Status { get; set; } = "Pending";
}
