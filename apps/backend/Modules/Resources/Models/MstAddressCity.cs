using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>
/// Current Address - City options for employee onboarding.
/// The stored <see cref="Name"/> is the value saved on <c>resource.tbl_employees."Address"</c>.
/// </summary>
public class MstAddressCity : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    /// <summary>Corridor or area shown beside the city, such as Western Line.</summary>
    public string? Line { get; set; }

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; }
}
