using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Catalogs.Models;

/// <summary>
/// Dropdown values that used to be fixed in the screens: worker type, billing medium,
/// project type, billing model, payment terms, and the related employee choices.
/// </summary>
public class MstScreenOption : BaseEntity
{
    public string Category { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    /// <summary>Empty for a flat list. Billing models point at a project type; payment terms point at a billing model.</summary>
    public string ParentName { get; set; } = string.Empty;

    public int SortOrder { get; set; }

    public bool IsActive { get; set; } = true;
}

public static class ScreenOptionCategory
{
    public const string WorkerType = "WorkerType";
    public const string BondDelivered = "BondDelivered";
    public const string ExperienceType = "ExperienceType";
    public const string BillableStatus = "BillableStatus";
    public const string BillingMedium = "BillingMedium";
    public const string EmployeeProjectType = "EmployeeProjectType";
    public const string WbsProjectType = "WbsProjectType";
    public const string BillingModel = "BillingModel";
    public const string PaymentTerm = "PaymentTerm";

    public static readonly string[] All =
    [
        WorkerType,
        BondDelivered,
        ExperienceType,
        BillableStatus,
        BillingMedium,
        EmployeeProjectType,
        WbsProjectType,
        BillingModel,
        PaymentTerm,
    ];

    public static bool RequiresParent(string category) =>
        category is WbsProjectType or BillingModel or PaymentTerm;
}
