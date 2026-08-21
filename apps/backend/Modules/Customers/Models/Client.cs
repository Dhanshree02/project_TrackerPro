using System.Text.RegularExpressions;
using PMS.API.Shared.Common.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;

namespace PMS.API.Modules.Customers.Models;

/// <summary>
/// Customer / TK partner. Field names mirror the frontend <c>Client</c> type in
/// <c>apps/frontend/src/lib/mock-data.ts</c> so API responses map 1:1.
/// </summary>
public class Client : BaseEntity
{
    public string Name { get; set; } = string.Empty;

    public string Industry { get; set; } = string.Empty;

    public Guid? IndustryId { get; set; }

    /// <summary>Two-letter initials used as the avatar text.</summary>
    public string? Logo { get; set; }

    public string? ContactEmail { get; set; }

    public ClientType ClientType { get; set; } = ClientType.New;

    public ClientStatus Status { get; set; } = ClientStatus.Active;

    public string? EngagementManager { get; set; }

    public Guid? EngagementManagerId { get; set; }

    public string? ContactName { get; set; }

    public string? ContactPhone { get; set; }

    public string? ContactDesignation { get; set; }

    public string? ContactType { get; set; }

    /// <summary>Head-office city captured during onboarding (name, API-compatible).</summary>
    public string? City { get; set; }

    public Guid? CityId { get; set; }

    /// <summary>Head-office country / region captured during onboarding (name, API-compatible).</summary>
    public string? Country { get; set; }

    public Guid? CountryId { get; set; }

    /// <summary>Enterprise / Mid-Market / SMB / Public Sector.</summary>
    public string? BusinessType { get; set; }

    /// <summary>Free-text notes captured during onboarding.</summary>
    public string? Notes { get; set; }

    /// <summary>Name of the KYC document attached during onboarding.</summary>
    public string? KycDocumentName { get; set; }

    /// <summary>
    /// Sub-ventures / end-customer divisions. One-to-many: each sub-venture lives in its own
    /// <c>sub_ventures</c> row referencing this client, and carries its own SPOC contacts so
    /// different sub-ventures can have different contact numbers.
    /// </summary>
    public ICollection<SubVenture> SubVentures { get; set; } = [];

    /// <summary>
    /// Derives the avatar initials from the client name: the first letter of the first two
    /// words, uppercased. E.g. "Northwind Bank" → "NB", "AutoDrive Systems" → "AS",
    /// "ABC" → "A". Returns null for blank names.
    /// </summary>
    public static string? LogoFromName(string? name)
    {
        var trimmed = name?.Trim() ?? string.Empty;
        if (trimmed.Length == 0) return null;
        var words = Regex.Split(trimmed, @"\s+");
        var initials = new string(words.Take(2).Select(w => w[0]).ToArray()).ToUpperInvariant();
        return initials;
    }

    /// <summary>SPOC contact persons attached to the client.</summary>
    public ICollection<ClientContactEntity> Contacts { get; set; } = [];

    /// <summary>Users explicitly granted visibility of this client (data scoping).</summary>
    public ICollection<ClientAssignment> Assignments { get; set; } = [];

    public MstIndustry? IndustryRef { get; set; }

    public Employee? EngagementManagerRef { get; set; }

    public MstCountry? CountryRef { get; set; }

    public MstCity? CityRef { get; set; }
}
