namespace PMS.API.Modules.Customers.DTOs;

public sealed record ClientDto(
    Guid Id,
    string Name,
    string Industry,
    string? Logo,
    string? ContactEmail,
    string ClientType,          // "NEW" | "OLD" (frontend contract)
    string Status,              // "Active" | "Inactive" | "Onboarding"
    string? EngagementManager,
    string? ContactName,
    string? ContactPhone,
    string? ContactDesignation,
    string? ContactType,
    string? City,
    string? Country,
    string? BusinessType,
    string? Notes,
    string? KycDocumentName,
    IReadOnlyList<SubVentureDto> SubVentures,
    IReadOnlyList<ClientContactDto> Contacts,
    DateOnly? CustomerSince,
    DateTime CreatedAtUtc);

public sealed record ClientContactDto(
    string? Name,
    string? Email,
    string? Phone,
    string? Designation,
    string? ContactType);

/// <summary>A sub-venture with its own SPOC contacts and onboarding notes.</summary>
public sealed record SubVentureDto(
    string Name,
    IReadOnlyList<ClientContactDto> Contacts,
    string? Notes = null);

/// <summary>Sub-venture payload for create/update requests.</summary>
public sealed record SubVentureInput(
    string Name,
    List<ClientContactDto>? Contacts,
    string? Notes = null);

public sealed record CreateClientRequest(
    string Name,
    string Industry,
    string? Logo,
    string? ContactEmail,
    string? ClientType,          // optional: "NEW" | "OLD", defaults to NEW
    string? EngagementManager,
    string? ContactName,
    string? ContactPhone,
    string? ContactDesignation,
    string? ContactType,
    string? City,
    string? Country,
    string? BusinessType,
    string? Notes,
    string? KycDocumentName,
    List<SubVentureInput>? SubVentures,
    List<ClientContactDto>? Contacts);

public sealed record UpdateClientRequest(
    string? Name,
    string? Industry,
    string? Logo,
    string? ContactEmail,
    string? ClientType,
    string? Status,
    string? EngagementManager,
    string? ContactName,
    string? ContactPhone,
    string? ContactDesignation,
    string? ContactType,
    string? City,
    string? Country,
    string? BusinessType,
    string? Notes,
    string? KycDocumentName,
    List<SubVentureInput>? SubVentures,
    List<ClientContactDto>? Contacts);
