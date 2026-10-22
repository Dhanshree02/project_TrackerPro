using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Catalogs.Models;

/// <summary>
/// A screen widget. <see cref="ParentId"/> is the module it belongs to, so Roles &amp; Permissions
/// can list the widget under that module.
/// </summary>
public class MstWidget : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public int SortOrder { get; set; }

    public bool IsActive { get; set; } = true;

    public Guid ParentId { get; set; }

    public MstModule? Module { get; set; }
}
