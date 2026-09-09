using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>
/// Contact-person designation for customer onboarding (SPOC, CISO, …).
/// Separate from <see cref="MstDesignation"/>, which is employee job titles.
/// </summary>
public class MstContactDesignation : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; }
}
