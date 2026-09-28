using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Projects.Models;

/// <summary>
/// Core project record. Field names align with the frontend Project type in mock-data.ts and WBS form.
/// </summary>
public class Project : BaseEntity
{
    /// <summary>FY-scoped sequential project code e.g. "P001", "P002".</summary>
    public string ProjectCode { get; set; } = string.Empty;

    /// <summary>Full WBS identifier e.g. "IN-2026-27-C011-P001".</summary>
    public string? WbsId { get; set; }

    /// <summary>Auto-generated or custom project name e.g. "Acme(Div1)_NetworkPT_01".</summary>
    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public Guid ClientId { get; set; }

    public Client? Client { get; set; }

    public Guid? SubVentureId { get; set; }

    public SubVenture? SubVenture { get; set; }

    /// <summary>Project execution status: "ongoing", "completed", "on_hold", "archived", "Draft".</summary>
    public string Status { get; set; } = "ongoing";

    /// <summary>Project health indicator: "green", "amber", "red".</summary>
    public string Health { get; set; } = "green";

    /// <summary>Project progress percentage (0 - 100).</summary>
    public int Progress { get; set; }

    /// <summary>Contract type: "Fixed Price", "T&M", "Retainer", etc.</summary>
    public string? ContractType { get; set; }

    /// <summary>Project duration type: "Short term (Ad-hoc)", "Long Term".</summary>
    public string? ProjectType { get; set; }

    /// <summary>Billing currency (INR, USD, EUR, etc.).</summary>
    public string Currency { get; set; } = "INR";

    /// <summary>Applicable tax percentage (e.g. 18 for 18% GST).</summary>
    public decimal TaxPercent { get; set; } = 18m;

    public DateOnly? StartDate { get; set; }

    public DateOnly? EndDate { get; set; }

    /// <summary>Overall project budget/value.</summary>
    public decimal? Budget { get; set; }

    /// <summary>Spent / utilized amount to date.</summary>
    public decimal Spent { get; set; }

    public decimal? TotalHours { get; set; }

    public decimal? TotalDays { get; set; }

    public decimal? InvoiceValue { get; set; }

    public Guid? ProjectManagerId { get; set; }

    public Employee? ProjectManager { get; set; }

    public Guid? TeamLeadId { get; set; }

    public Employee? TeamLead { get; set; }

    public string? EngagementManager { get; set; }

    public Guid? EngagementManagerId { get; set; }

    public Employee? EngagementManagerRef { get; set; }

    public string? SalesPerson { get; set; }

    public Guid? SalesPersonId { get; set; }

    public Employee? SalesPersonRef { get; set; }

    public DateOnly? ProjectIssuedDate { get; set; }

    public string? SectionAComments { get; set; }

    public string? SectionBComments { get; set; }

    /// <summary>
    /// WBS lifecycle status: "draft", "approval_pending", "ph_approved", "accounts_approved", "approved", "started", "assigned".
    /// </summary>
    public string WbsStatus { get; set; } = "draft";

    public string? WbsSubStatus { get; set; }

    /// <summary>Points to original project when this record is a renewal.</summary>
    public Guid? RenewedFromProjectId { get; set; }

    public Project? RenewedFromProject { get; set; }

    public string? PoStatus { get; set; }

    public string? PoNumber { get; set; }

    public DateOnly? PoDate { get; set; }

    public string? BillingModel { get; set; }

    public string? PaymentTerms { get; set; }

    public DateOnly? TargetDate { get; set; }

    public string? AccountContactName { get; set; }

    public string? AccountContactPhone { get; set; }

    public string? AccountContactEmail { get; set; }
}
