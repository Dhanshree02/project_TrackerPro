using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Catalogs.Models;

/// <summary>
/// Sidebar submodule. A direct child of a module sets <see cref="ModuleId"/>.
/// A deeper row (sub-submodule and below) sets <see cref="ParentId"/> to another row in this table.
/// </summary>
public class MstSubModule : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public string? Route { get; set; }

    public int SortOrder { get; set; }

    public bool IsActive { get; set; } = true;

    public Guid? ModuleId { get; set; }

    public MstModule? Module { get; set; }

    public Guid? ParentId { get; set; }

    public MstSubModule? Parent { get; set; }

    public ICollection<MstSubModule> Children { get; set; } = new List<MstSubModule>();
}
