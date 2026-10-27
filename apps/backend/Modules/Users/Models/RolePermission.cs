using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Users.Models;

/// <summary>
/// Unified role permission entry stored in <c>auth.tbl_role_permissions</c>.
/// Maps a Role to any catalog Item (module, submodule, widget, tab) with binary CanView and CanManage.
/// </summary>
public class RolePermission : BaseEntity
{
    public Guid RoleId { get; set; }
    public Role Role { get; set; } = null!;

    public Guid ItemId { get; set; }
    public string ItemType { get; set; } = string.Empty; // "module" | "submodule" | "widget" | "tab"

    public short CanView { get; set; }
    public short CanManage { get; set; }
}
