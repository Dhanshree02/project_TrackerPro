using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

public class MstEmployeeStatus : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    /// <summary>When true, status may be selected during employee onboarding (currently Active only).</summary>
    public bool AllowOnboarding { get; set; }

    public int SortOrder { get; set; }
}
