using PMS.API.Shared.Common.Models;

namespace PMS.API.Modules.Customers.Models;

/// <summary>
/// Normalized client contact row attached either to a client or one sub-venture.
/// </summary>
public class ClientContactEntity : BaseEntity
{
    public Guid? ClientId { get; set; }

    public Guid? SubVentureId { get; set; }

    public string? Name { get; set; }

    public string? Email { get; set; }

    public string? Phone { get; set; }

    public string? Designation { get; set; }

    public string? ContactType { get; set; }

    public bool IsPrimary { get; set; }

    public Client? Client { get; set; }

    public SubVenture? SubVenture { get; set; }
}
