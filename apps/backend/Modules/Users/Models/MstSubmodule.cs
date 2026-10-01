using System.ComponentModel.DataAnnotations.Schema;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Users.Models;

[Table("mst_submodules")]
public class MstSubmodule : BaseEntity
{
    public Guid ModuleId { get; set; }
    public MstModule Module { get; set; } = null!;

    public Guid? ParentSubmoduleId { get; set; }
    public MstSubmodule? ParentSubmodule { get; set; }

    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? RoutePrefix { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;

    public ICollection<MstSubmodule> ChildSubmodules { get; set; } = [];
    public ICollection<MstWidget> Widgets { get; set; } = [];
}
