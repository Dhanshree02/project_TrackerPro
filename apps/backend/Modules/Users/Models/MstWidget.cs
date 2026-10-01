using System.ComponentModel.DataAnnotations.Schema;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Users.Models;

[Table("mst_widgets")]
public class MstWidget : BaseEntity
{
    public Guid? SubmoduleId { get; set; }
    public MstSubmodule? Submodule { get; set; }

    public Guid? ModuleId { get; set; }
    public MstModule? Module { get; set; }

    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string WidgetKey { get; set; } = string.Empty;
    public string WidgetType { get; set; } = "widget";
    public bool HasManageAction { get; set; } = true;
    public string? Description { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;

    public ICollection<RoleWidgetPermission> RolePermissions { get; set; } = [];
}
