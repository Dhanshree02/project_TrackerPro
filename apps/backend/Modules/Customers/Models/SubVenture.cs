using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Customers.Models;

/// <summary>
/// A sub-venture (end-customer division) under a client. Lives in its own table and
/// references the parent client via <see cref="ClientId"/>.
/// </summary>
public class SubVenture : BaseEntity
{
    public Guid ClientId { get; set; }

    public string Name { get; set; } = string.Empty;

    /// <summary>SPOC persons specific to this sub-venture.</summary>
    public ICollection<ClientContactEntity> Contacts { get; set; } = [];

    public Client? Client { get; set; }
}
