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
    string? SalesManager,
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
    string? Logo = null,
    string? ContactEmail = null,
    string? ClientType = null,          // optional: "NEW" | "OLD", defaults to NEW
    string? EngagementManager = null,
    string? SalesManager = null,
    string? ContactName = null,
    string? ContactPhone = null,
    string? ContactDesignation = null,
    string? ContactType = null,
    string? City = null,
    string? Country = null,
    string? BusinessType = null,
    string? Notes = null,
    string? KycDocumentName = null,
    List<SubVentureInput>? SubVentures = null,
    List<ClientContactDto>? Contacts = null);

public sealed record UpdateClientRequest(
    string? Name = null,
    string? Industry = null,
    string? Logo = null,
    string? ContactEmail = null,
    string? ClientType = null,
    string? Status = null,
    string? EngagementManager = null,
    string? SalesManager = null,
    string? ContactName = null,
    string? ContactPhone = null,
    string? ContactDesignation = null,
    string? ContactType = null,
    string? City = null,
    string? Country = null,
    string? BusinessType = null,
    string? Notes = null,
    string? KycDocumentName = null,
    List<SubVentureInput>? SubVentures = null,
    List<ClientContactDto>? Contacts = null);
