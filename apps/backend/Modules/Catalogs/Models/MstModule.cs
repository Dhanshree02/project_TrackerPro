using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Catalogs.Models;

/// <summary>Sidebar module. The name shown in the menu is <see cref="Name"/>.</summary>
public class MstModule : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public string? Route { get; set; }

    public string IconKey { get; set; } = string.Empty;

    public int SortOrder { get; set; }

    public bool IsActive { get; set; } = true;
}
