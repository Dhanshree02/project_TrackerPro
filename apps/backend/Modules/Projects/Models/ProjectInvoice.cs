using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Billing and invoice milestone record for a project.
/// </summary>
public class ProjectInvoice : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public string MilestoneName { get; set; } = string.Empty;

    public decimal? Percentage { get; set; }

    public decimal Amount { get; set; }

    public decimal TaxAmount { get; set; }

    public decimal TotalAmount { get; set; }

    /// <summary>
    /// Status: "Pending", "Raised", "Paid", "Overdue", "Cancelled".
    /// </summary>
    public string Status { get; set; } = "Pending";

    public string? InvoiceNumber { get; set; }

    public DateOnly? InvoiceDate { get; set; }

    public DateOnly? DueDate { get; set; }

    public DateOnly? PaymentDate { get; set; }

    public string? Remarks { get; set; }

    public int SortOrder { get; set; }

    /// <summary>Service line this milestone was generated from.</summary>
    public string? ServiceName { get; set; }

    public int? Qty { get; set; }

    public decimal? UnitPrice { get; set; }

    public string? Currency { get; set; }

    public string? ResourceLevel { get; set; }

    /// <summary>Payment capture: "Not Received" or "Received".</summary>
    public string? PaymentStatus { get; set; }

    /// <summary>Optional link to specific project service entity.</summary>
    public Guid? ProjectServiceId { get; set; }

    public ProjectServiceEntity? ProjectService { get; set; }
}
