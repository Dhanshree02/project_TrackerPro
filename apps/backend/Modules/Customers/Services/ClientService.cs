using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Customers.Services;
using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Shared.Validation;

namespace PMS.API.Modules.Customers.Services;

public sealed class ClientService(AppDbContext db, ICurrentUserService currentUser) : IClientService
{
    // Roles that see every client.
    private static readonly UserRole[] GlobalVisibilityRoles =
    [
        UserRole.Admin,
        UserRole.Dhanshree,
        UserRole.Pmo,
        UserRole.Hod,
        UserRole.BusinessOwner,
        UserRole.Sales,
        UserRole.Accounts,
        UserRole.Hr,
    ];

    public async Task<PagedResult<ClientDto>> GetClientsAsync(
        int page,
        int perPage,
        string? search,
        CancellationToken ct = default)
    {
        var query = BuildScopedQuery();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var needle = search.Trim().ToLower();
            query = query.Where(c =>
                c.Name.ToLower().Contains(needle) ||
                c.Industry.ToLower().Contains(needle) ||
                (c.IndustryRef != null && c.IndustryRef.Name.ToLower().Contains(needle)) ||
                (c.ContactEmail != null && c.ContactEmail.ToLower().Contains(needle)) ||
                (c.ContactName != null && c.ContactName.ToLower().Contains(needle)) ||
                (c.ContactPhone != null && c.ContactPhone.ToLower().Contains(needle)) ||
                (c.ContactDesignation != null && c.ContactDesignation.ToLower().Contains(needle)) ||
                (c.City != null && c.City.ToLower().Contains(needle)) ||
                (c.Country != null && c.Country.ToLower().Contains(needle)) ||
                (c.Notes != null && c.Notes.ToLower().Contains(needle)) ||
                (c.EngagementManager != null && c.EngagementManager.ToLower().Contains(needle)) ||
                (c.SalesManager != null && c.SalesManager.ToLower().Contains(needle)) ||
                c.Contacts.Any(ct =>
                    (ct.Name != null && ct.Name.ToLower().Contains(needle)) ||
                    (ct.Email != null && ct.Email.ToLower().Contains(needle)) ||
                    (ct.Phone != null && ct.Phone.ToLower().Contains(needle)) ||
                    (ct.Designation != null && ct.Designation.ToLower().Contains(needle))) ||
                c.SubVentures.Any(sv =>
                    sv.Name.ToLower().Contains(needle) ||
                    (sv.Notes != null && sv.Notes.ToLower().Contains(needle)) ||
                    sv.Contacts.Any(sct =>
                        (sct.Name != null && sct.Name.ToLower().Contains(needle)) ||
                        (sct.Email != null && sct.Email.ToLower().Contains(needle)) ||
                        (sct.Phone != null && sct.Phone.ToLower().Contains(needle)) ||
                        (sct.Designation != null && sct.Designation.ToLower().Contains(needle)))));
        }

        var total = await query.CountAsync(ct);

        var entities = await query
            .Include(c => c.IndustryRef)
            .Include(c => c.CountryRef)
            .Include(c => c.CityRef)
            .Include(c => c.EngagementManagerRef)
            .Include(c => c.SalesManagerRef)
            .Include(c => c.Contacts)
            .Include(c => c.SubVentures)
            .ThenInclude(s => s.Contacts)
            .OrderBy(c => c.Name)
            .Skip((page - 1) * perPage)
            .Take(perPage)
            .ToListAsync(ct);

        var items = entities.Select(MapToDto).ToList();
        return new PagedResult<ClientDto>(items, page, perPage, total);
    }

    public async Task<ClientDto?> GetClientAsync(Guid id, CancellationToken ct = default)
    {
        var entity = await BuildScopedQuery()
            .Include(c => c.IndustryRef)
            .Include(c => c.CountryRef)
            .Include(c => c.CityRef)
            .Include(c => c.EngagementManagerRef)
            .Include(c => c.SalesManagerRef)
            .Include(c => c.Contacts)
            .Include(c => c.SubVentures)
            .ThenInclude(s => s.Contacts)
            .FirstOrDefaultAsync(c => c.Id == id, ct);
        return entity is null ? null : MapToDto(entity);
    }

    public async Task<ClientDto> CreateClientAsync(CreateClientRequest request, CancellationToken ct = default)
    {
        var countryId = await ResolveCountryIdAsync(request.Country, ct);
        var client = new Client
        {
            Name = request.Name.Trim(),
            Industry = request.Industry.Trim(),
            IndustryId = await ResolveIndustryIdAsync(request.Industry, ct),
            // Logo is always derived from the client name.
            Logo = Client.LogoFromName(request.Name),
            ContactEmail = EmailRules.NullIfEmpty(request.ContactEmail),
            ClientType = request.ClientType == "OLD" ? ClientType.Old : ClientType.New,
            EngagementManager = request.EngagementManager,
            EngagementManagerId = await ResolveEngagementManagerIdAsync(request.EngagementManager, ct),
            SalesManager = request.SalesManager,
            SalesManagerId = await ResolveSalesManagerIdAsync(request.SalesManager, ct),
            ContactName = request.ContactName,
            ContactPhone = request.ContactPhone,
            ContactDesignation = request.ContactDesignation,
            ContactType = request.ContactType,
            Country = request.Country,
            CountryId = countryId,
            City = request.City,
            CityId = await ResolveCityIdAsync(request.City, countryId, ct),
            BusinessType = request.BusinessType,
            Notes = request.Notes,
            KycDocumentName = request.KycDocumentName,
            CustomerSince = TodayIst(),
        };

        var subVentureInputs = request.SubVentures ?? [];
        client.SubVentures = subVentureInputs
            .Select(s => new SubVenture
            {
                ClientId = client.Id,
                Name = s.Name.Trim(),
                Notes = string.IsNullOrWhiteSpace(s.Notes) ? null : s.Notes.Trim(),
            })
            .ToList();

        db.Clients.Add(client);
        await db.SaveChangesAsync(ct);

        await PersistContactsAsync(client, request.Contacts, subVentureInputs, ct);

        return MapToDto(client);
    }

    public async Task<ClientDto?> UpdateClientAsync(Guid id, UpdateClientRequest request, CancellationToken ct = default)
    {
        var client = await BuildScopedQuery()
            .Include(c => c.IndustryRef)
            .Include(c => c.CountryRef)
            .Include(c => c.CityRef)
            .Include(c => c.EngagementManagerRef)
            .Include(c => c.SalesManagerRef)
            .Include(c => c.Contacts)
            .Include(c => c.SubVentures)
            .ThenInclude(s => s.Contacts)
            .FirstOrDefaultAsync(c => c.Id == id, ct);
        if (client is null) return null;

        if (request.Name is not null)
        {
            client.Name = request.Name.Trim();
            // Keep the logo in sync with the name (first + last letter).
            client.Logo = Client.LogoFromName(client.Name);
        }
        if (request.Industry is not null)
        {
            client.Industry = request.Industry.Trim();
            client.IndustryId = await ResolveIndustryIdAsync(request.Industry, ct);
        }
        if (request.Logo is not null) client.Logo = request.Logo;
        if (request.ContactEmail is not null) client.ContactEmail = EmailRules.NullIfEmpty(request.ContactEmail);
        if (request.ClientType is not null) client.ClientType = request.ClientType == "OLD" ? ClientType.Old : ClientType.New;
        if (request.Status is not null &&
            Enum.TryParse<ClientStatus>(request.Status, ignoreCase: true, out var status))
        {
            client.Status = status;
        }
        if (request.EngagementManager is not null)
        {
            client.EngagementManager = request.EngagementManager;
            client.EngagementManagerId = await ResolveEngagementManagerIdAsync(request.EngagementManager, ct);
        }
        if (request.SalesManager is not null)
        {
            client.SalesManager = request.SalesManager;
            client.SalesManagerId = await ResolveSalesManagerIdAsync(request.SalesManager, ct);
        }
        if (request.ContactName is not null) client.ContactName = request.ContactName;
        if (request.ContactPhone is not null) client.ContactPhone = request.ContactPhone;
        if (request.ContactDesignation is not null) client.ContactDesignation = request.ContactDesignation;
        if (request.ContactType is not null) client.ContactType = request.ContactType;
        if (request.Country is not null)
        {
            client.Country = request.Country;
            client.CountryId = await ResolveCountryIdAsync(request.Country, ct);
        }
        if (request.City is not null)
        {
            client.City = request.City;
            client.CityId = await ResolveCityIdAsync(request.City, client.CountryId, ct);
        }
        if (request.BusinessType is not null) client.BusinessType = request.BusinessType;
        if (request.Notes is not null) client.Notes = request.Notes;
        if (request.KycDocumentName is not null) client.KycDocumentName = request.KycDocumentName;
        if (request.SubVentures is not null)
        {
            // Replace semantics: the incoming list is the full desired set (matched by
            // name, case-insensitive). Soft-delete removed rows, add new ones.
            var incoming = request.SubVentures;
            var existing = client.SubVentures.ToList();

            foreach (var ex in existing)
            {
                if (!incoming.Any(i => string.Equals(i.Name, ex.Name, StringComparison.OrdinalIgnoreCase)))
                {
                    client.SubVentures.Remove(ex);
                }
            }

            foreach (var input in incoming)
            {
                var match = existing.FirstOrDefault(e =>
                    string.Equals(e.Name, input.Name, StringComparison.OrdinalIgnoreCase));
                if (match is not null)
                {
                    match.Name = input.Name.Trim();
                    if (input.Notes is not null)
                        match.Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim();
                }
                else
                {
                    // Add via the DbSet (not the nav collection) so EF marks the new
                    // entity as Added. Adding a non-default-Guid entity directly to a
                    // tracked (Unchanged) client's nav collection makes EF treat it as
                    // an existing row (Modified), which then fails with a 0-row UPDATE.
                    var subVenture = new SubVenture
                    {
                        ClientId = client.Id,
                        Name = input.Name.Trim(),
                        Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim(),
                    };
                    db.SubVentures.Add(subVenture);
                }
            }
        }

        await db.SaveChangesAsync(ct);

        if (request.SubVentures is not null || request.Contacts is not null)
        {
            await PersistContactsAsync(client, request.Contacts, request.SubVentures, ct);
        }

        return MapToDto(client);
    }

    public async Task<bool> SoftDeleteClientAsync(Guid id, CancellationToken ct = default)
    {
        var client = await BuildScopedQuery().FirstOrDefaultAsync(c => c.Id == id, ct);
        if (client is null) return false;

        db.Clients.Remove(client); // SaveChanges converts to soft delete (DeletedAtUtc)
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<IReadOnlyList<string>> GetIndustriesAsync(CancellationToken ct = default)
    {
        return await db.Industries
            .Where(i => i.IsActive)
            .OrderBy(i => i.Name)
            .Select(i => i.Name)
            .ToListAsync(ct);
    }

    /// <summary>
    /// Applies role-based data scoping:
    ///  - global roles → all clients
    ///  - SPM/EM → their engagement-manager clients + explicit assignments
    ///  - everyone else → explicit assignments only
    /// </summary>
    private IQueryable<Client> BuildScopedQuery()
    {
        var query = db.Clients.AsQueryable();

        var role = currentUser.Role;
        if (!Enum.TryParse<UserRole>(role, ignoreCase: true, out var userRole) ||
            !GlobalVisibilityRoles.Contains(userRole))
        {
            var userId = currentUser.UserId;

            if ((userRole is UserRole.SeniorPm or UserRole.EngagementManager) &&
                !string.IsNullOrWhiteSpace(currentUser.Name))
            {
                var name = currentUser.Name;
                query = query.Where(c =>
                    c.EngagementManager == name ||
                    (c.EngagementManagerRef != null && c.EngagementManagerRef.FirstName + " " + c.EngagementManagerRef.LastName == name) ||
                    (userId.HasValue && c.Assignments.Any(a => a.UserId == userId.Value)));
            }
            else if (userId.HasValue)
            {
                var uid = userId.Value;
                query = query.Where(c => c.Assignments.Any(a => a.UserId == uid));
            }
            else
            {
                query = query.Where(_ => false);
            }
        }

        return query;
    }

    private static ClientContactEntity ToClientContact(Guid clientId, ClientContactDto c) => new()
    {
        ClientId = clientId,
        SubVentureId = null,
        Name = c.Name,
        Email = EmailRules.NullIfEmpty(c.Email),
        Phone = c.Phone,
        Designation = c.Designation,
        ContactType = c.ContactType,
    };

    private static ClientContactEntity ToSubVentureContact(Guid subVentureId, ClientContactDto c) => new()
    {
        ClientId = null,
        SubVentureId = subVentureId,
        Name = c.Name,
        Email = EmailRules.NullIfEmpty(c.Email),
        Phone = c.Phone,
        Designation = c.Designation,
        ContactType = c.ContactType,
    };

    private static bool HasContactContent(ClientContactDto c) =>
        !string.IsNullOrWhiteSpace(c.Name) ||
        !string.IsNullOrWhiteSpace(c.Email) ||
        !string.IsNullOrWhiteSpace(c.Phone);

    /// <summary>
    /// Persists contacts as standalone rows with exactly one owner FK (ClientId XOR SubVentureId),
    /// bypassing EF navigation-collection fixup which would otherwise set both FKs and trip
    /// CK_client_contacts_exactly_one_owner. Replace semantics: existing contacts for the
    /// client and its sub-ventures are soft-deleted, then the desired set is inserted.
    /// </summary>
    private async Task PersistContactsAsync(
        Client client,
        List<ClientContactDto>? clientContacts,
        List<SubVentureInput>? subVentureInputs,
        CancellationToken ct)
    {
        var subVentureIds = client.SubVentures.Select(s => s.Id).ToList();

        var existing = await db.ClientContacts
            .Where(c => c.ClientId == client.Id
                || (c.SubVentureId != null && subVentureIds.Contains(c.SubVentureId.Value)))
            .ToListAsync(ct);

        foreach (var c in existing)
        {
            db.ClientContacts.Remove(c); // SaveChanges converts to soft delete (DeletedAtUtc)
        }
        await db.SaveChangesAsync(ct);

        var toAdd = new List<ClientContactEntity>();

        foreach (var c in clientContacts ?? [])
        {
            if (HasContactContent(c))
                toAdd.Add(ToClientContact(client.Id, c));
        }

        if (subVentureInputs is not null)
        {
            foreach (var input in subVentureInputs)
            {
                var sv = client.SubVentures.FirstOrDefault(s =>
                    string.Equals(s.Name, input.Name.Trim(), StringComparison.OrdinalIgnoreCase));
                if (sv is null) continue;

                foreach (var c in input.Contacts ?? [])
                {
                    if (HasContactContent(c))
                        toAdd.Add(ToSubVentureContact(sv.Id, c));
                }
            }
        }

        if (toAdd.Count > 0)
        {
            db.ClientContacts.AddRange(toAdd);
            await db.SaveChangesAsync(ct);
        }

        // Populate navigation collections for the DTO projection (no further save).
        client.Contacts = toAdd.Where(c => c.ClientId == client.Id).ToList();
        foreach (var sv in client.SubVentures)
        {
            sv.Contacts = toAdd.Where(c => c.SubVentureId == sv.Id).ToList();
        }
    }

    private async Task<Guid?> ResolveIndustryIdAsync(string? industryName, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(industryName)) return null;
        var trimmed = industryName.Trim();
        var existing = await db.Industries.FirstOrDefaultAsync(i => i.Name == trimmed, ct);
        if (existing is not null) return existing.Id;

        var slug = trimmed.ToLowerInvariant().Replace(" ", "_");
        var entity = new MstIndustry
        {
            Code = slug,
            Name = trimmed,
            IsActive = true,
        };
        db.Industries.Add(entity);
        return entity.Id;
    }

    private async Task<Guid?> ResolveCountryIdAsync(string? countryName, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(countryName)) return null;
        var trimmed = countryName.Trim();
        var existing = await db.Countries.FirstOrDefaultAsync(
            c => c.Name == trimmed || c.Code == trimmed, ct);
        return existing?.Id;
    }

    private async Task<Guid?> ResolveCityIdAsync(string? cityName, Guid? countryId, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(cityName)) return null;
        var trimmed = cityName.Trim();
        var query = db.Cities.Where(c => c.Name == trimmed);
        if (countryId is not null)
        {
            query = query.Where(c => c.CountryId == countryId);
        }

        var existing = await query.FirstOrDefaultAsync(ct);
        return existing?.Id;
    }

    private async Task<Guid?> ResolveEngagementManagerIdAsync(string? managerName, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(managerName)) return null;
        var trimmed = managerName.Trim();
        var parts = trimmed.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 0) return null;
        var first = parts[0];
        var last = parts.Length > 1 ? string.Join(' ', parts.Skip(1)) : string.Empty;

        var employee = await db.Employees
            .Include(e => e.Designation)
            .Where(e =>
                (e.FirstName + " " + e.LastName).Trim().ToLower() == trimmed.ToLower() ||
                (e.FirstName == first && (last.Length == 0 || e.LastName == last)))
            .OrderByDescending(e =>
                e.Designation != null && e.Designation.Name == "Engagement Manager")
            .FirstOrDefaultAsync(ct);

        return employee?.Id;
    }

    private async Task<Guid?> ResolveSalesManagerIdAsync(string? managerName, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(managerName)) return null;
        var trimmed = managerName.Trim();
        var parts = trimmed.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 0) return null;
        var first = parts[0];
        var last = parts.Length > 1 ? string.Join(' ', parts.Skip(1)) : string.Empty;

        var employee = await db.Employees
            .Include(e => e.Designation)
            .Where(e =>
                (e.FirstName + " " + e.LastName).Trim().ToLower() == trimmed.ToLower() ||
                (e.FirstName == first && (last.Length == 0 || e.LastName == last)))
            .OrderByDescending(e =>
                e.Designation != null && (e.Designation.Name == "Sales Manager" || e.Designation.Name.Contains("Sales")))
            .FirstOrDefaultAsync(ct);

        return employee?.Id;
    }

    private static ClientDto MapToDto(Client c) => new(
        c.Id,
        c.Name,
        c.IndustryRef?.Name ?? c.Industry,
        c.Logo,
        c.ContactEmail,
        c.ClientType == ClientType.Old ? "OLD" : "NEW",
        c.Status.ToString(),
        c.EngagementManagerRef is null ? c.EngagementManager : $"{c.EngagementManagerRef.FirstName} {c.EngagementManagerRef.LastName}",
        c.SalesManagerRef is null ? c.SalesManager : $"{c.SalesManagerRef.FirstName} {c.SalesManagerRef.LastName}",
        c.ContactName,
        c.ContactPhone,
        c.ContactDesignation,
        c.ContactType,
        c.CityRef?.Name ?? c.City,
        c.CountryRef?.Name ?? c.Country,
        c.BusinessType,
        c.Notes,
        c.KycDocumentName,
        c.SubVentures.Select(s => new SubVentureDto(
            s.Name,
            s.Contacts.Select(x => new ClientContactDto(x.Name, x.Email, x.Phone, x.Designation, x.ContactType)).ToList(),
            s.Notes)).ToList(),
        c.Contacts.Select(x => new ClientContactDto(x.Name, x.Email, x.Phone, x.Designation, x.ContactType)).ToList(),
        c.CustomerSince,
        c.CreatedAtUtc);

    private static DateOnly TodayIst()
    {
        TimeZoneInfo tz;
        try
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
        }
        catch (TimeZoneNotFoundException)
        {
            tz = TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }

        return DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz));
    }
}

