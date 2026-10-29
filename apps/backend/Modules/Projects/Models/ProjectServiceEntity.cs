using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Project-specific service selection line item (Section A of WBS form).
/// Represents a service attached to a project with customized quantity, pricing, dates, and resource levels.
/// </summary>
public class ProjectServiceEntity : BaseEntity
{
    public Guid ProjectId { get; set; }

    public Project? Project { get; set; }

    public Guid? ServiceCatalogId { get; set; }

    public MstServiceCatalog? ServiceCatalog { get; set; }

    /// <summary>Catalog task / service code reference (e.g. "PT001").</summary>
    public string? TaskId { get; set; }

    public string Department { get; set; } = string.Empty;

    public string? SubDepartment { get; set; }

    public string ServiceName { get; set; } = string.Empty;

    public string? ServiceAbbreviation { get; set; }

    public int Qty { get; set; } = 1;

    public string? Description { get; set; }

    /// <summary>Compact resource level summary e.g. "L1=2, L2=1, Senior=1" or "L1".</summary>
    public string? ResourceLevel { get; set; }

    /// <summary>Service frequency: "Once", "Half yearly", "Yearly", etc.</summary>
    public string? Frequency { get; set; }

    /// <summary>Delivery location type: "Onsite", "Offsite", "Hybrid".</summary>
    public string? Location { get; set; }

    /// <summary>Specific project site / location details.</summary>
    public string? LocationText { get; set; }

    /// <summary>Service model: "Fixed", "T&M", "NA".</summary>
    public string? ServiceModel { get; set; }

    /// <summary>Delivery model: "Agile", "Waterfall", etc.</summary>
    public string? DeliveryModel { get; set; }

    /// <summary>Final delivery format.</summary>
    public string? FinalDeliveryFormat { get; set; }

    /// <summary>Service billing model.</summary>
    public string? BillingModel { get; set; }

    /// <summary>Security tools to be used (e.g. "Nessus, Metasploit").</summary>
    public string? Tools { get; set; }

    public DateOnly? StartDate { get; set; }

    public DateOnly? EndDate { get; set; }

    /// <summary>Duration per unit in working days.</summary>
    public int? DurationDays { get; set; }

    /// <summary>Duration per unit in hours (DurationDays * 8).</summary>
    public int? DurationHours { get; set; }

    /// <summary>Total days across all units (Qty * DurationDays).</summary>
    public int? TotalDays { get; set; }

    /// <summary>Total hours across all units (Qty * DurationHours).</summary>
    public int? TotalHours { get; set; }

    /// <summary>Unit price in project currency.</summary>
    public decimal? UnitPrice { get; set; }

    /// <summary>Total price (Qty * UnitPrice).</summary>
    public decimal? Total { get; set; }

    public int SortOrder { get; set; }

    /// <summary>Prerequisite collection status. Resource services are shown as NA in the WBS table.</summary>
    public string CollectionStatus { get; set; } = "Pending To Collect";

    /// <summary>Prerequisite validation status. Resource services are shown as NA in the WBS table.</summary>
    public string ValidationStatus { get; set; } = "Pending To Validate";

    /// <summary>Prerequisite billing status.</summary>
    public string BillingStatus { get; set; } = "Advance Pending";

    /// <summary>True after the service is marked Ready and its task folder is shown.</summary>
    public bool IsReady { get; set; }

    /// <summary>Service Change Management status: "Active", "Newly Added", "Modification Pending".</summary>
    public string ChangeStatus { get; set; } = "Active";

    /// <summary>Original quantity before a pending modification was requested.</summary>
    public int? OriginalQty { get; set; }

    /// <summary>New quantity requested in a pending modification.</summary>
    public int? PendingQty { get; set; }

    /// <summary>New resource level distribution requested in a pending modification.</summary>
    public string? PendingResourceLevel { get; set; }

    /// <summary>New unit price requested in a pending modification.</summary>
    public decimal? PendingUnitPrice { get; set; }

    /// <summary>Prerequisite collection status for a pending modification.</summary>
    public string? ModCollectionStatus { get; set; }

    /// <summary>Prerequisite validation status for a pending modification.</summary>
    public string? ModValidationStatus { get; set; }

    /// <summary>Prerequisite billing status for a pending modification.</summary>
    public string? ModBillingStatus { get; set; }

    /// <summary>True after the pending modification is marked Ready to apply.</summary>
    public bool? ModIsReady { get; set; }
}
