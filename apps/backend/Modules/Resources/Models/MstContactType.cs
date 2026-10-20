using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Resources.Models;

/// <summary>
/// Contact-person type for customer onboarding (Accounts, Procurement, …).
/// Stored as the contact's <c>ContactType</c> name until Settings CRUD exists.
/// </summary>
public class MstContactType : BaseEntity
{
    public string Code { get; set; } = string.Empty;

    public string Name { get; set; } = string.Empty;

    public bool IsActive { get; set; } = true;

    public int SortOrder { get; set; }
}
