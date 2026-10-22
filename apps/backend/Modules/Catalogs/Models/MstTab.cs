using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Catalogs.Models;

/// <summary>
/// A screen tab. A tab on a module sets <see cref="ModuleId"/>.
/// A tab on a submodule sets <see cref="SubModuleId"/>.
/// A nested tab sets <see cref="TabId"/> to another row in this table.
/// </summary>
public class MstTab : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public int SortOrder { get; set; }

    public bool IsActive { get; set; } = true;

    public Guid? ModuleId { get; set; }

    public MstModule? Module { get; set; }

    public Guid? SubModuleId { get; set; }

    public MstSubModule? SubModule { get; set; }

    public Guid? TabId { get; set; }

    public MstTab? Parent { get; set; }

    public ICollection<MstTab> Children { get; set; } = new List<MstTab>();
}
