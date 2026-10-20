using PMS.API.Shared.Common.Models;
using PMS.API.Modules.Users.Models;

namespace PMS.API.Modules.Users.Models;

/// <summary>
/// Access role stored on <c>auth.tbl_roles</c>. Permission grants are not stored on this row.
/// </summary>
public class Role : BaseEntity
{
    /// <summary>
    /// Unique role key. System roles use the <see cref="UserRole"/> enum names;
    /// administrator-created roles may use any unique key.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    public string DisplayName { get; set; } = string.Empty;

    public string? Description { get; set; }

    /// <summary>System roles are seeded and cannot be deleted.</summary>
    public bool IsSystemRole { get; set; }

    /// <summary>Inactive roles cannot be assigned to users.</summary>
    public bool IsActive { get; set; } = true;

    public ICollection<User> Users { get; set; } = [];
}
