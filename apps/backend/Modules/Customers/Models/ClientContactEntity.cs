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

    /// <summary>Country name from mst_countries (contact-person Country / Region).</summary>
    public string? Country { get; set; }

    /// <summary>Dial code for that country (e.g. +91), used to display phone without showing the country name.</summary>
    public string? PhoneCode { get; set; }

    public string? Designation { get; set; }

    public string? ContactType { get; set; }

    public bool IsPrimary { get; set; }

    public Client? Client { get; set; }

    public SubVenture? SubVenture { get; set; }
}
