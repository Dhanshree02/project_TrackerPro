using System.ComponentModel.DataAnnotations.Schema;
using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Users.Models;

[Table("mst_modules")]
public class MstModule : BaseEntity
{
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Icon { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;

    public ICollection<MstSubmodule> Submodules { get; set; } = [];
}
