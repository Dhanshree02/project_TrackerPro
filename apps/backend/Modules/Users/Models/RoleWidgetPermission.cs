using System.ComponentModel.DataAnnotations.Schema;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Users.Models;

[Table("role_widget_permissions")]
public class RoleWidgetPermission : BaseEntity
{
    public Guid RoleId { get; set; }
    public Role Role { get; set; } = null!;

    public Guid WidgetId { get; set; }
    public MstWidget Widget { get; set; } = null!;

    public short CanView { get; set; }
    public short CanManage { get; set; }
}
