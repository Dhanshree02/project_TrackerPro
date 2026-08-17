using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Customers.Services;
using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Infrastructure.Persistence;

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
                c.Industry.ToLower().Contains(needle));
        }

        var total = await query.CountAsync(ct);

        var entities = await query
            .Include(c => c.SubVentures)
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
            .Include(c => c.SubVentures)
            .FirstOrDefaultAsync(c => c.Id == id, ct);
        return entity is null ? null : MapToDto(entity);
    }

    public async Task<ClientDto> CreateClientAsync(CreateClientRequest request, CancellationToken ct = default)
    {
        var client = new Client
        {
            Name = request.Name.Trim(),
            Industry = request.Industry.Trim(),
            // Logo is always derived from the client name.
            Logo = Client.LogoFromName(request.Name),
            ContactEmail = request.ContactEmail,
            ClientType = request.ClientType == "OLD" ? ClientType.Old : ClientType.New,
            EngagementManager = request.EngagementManager,
            ContactName = request.ContactName,
            ContactPhone = request.ContactPhone,
            ContactDesignation = request.ContactDesignation,
            ContactType = request.ContactType,
            City = request.City,
            Country = request.Country,
            BusinessType = request.BusinessType,
            Notes = request.Notes,
            KycDocumentName = request.KycDocumentName,
            Contacts = request.Contacts?.Select(ToContact).ToList() ?? [],
        };

        client.SubVentures = request.SubVentures?.Select(s => new SubVenture
        {
            ClientId = client.Id,
            Name = s.Name,
            Contacts = s.Contacts?.Select(ToContact).ToList() ?? [],
        }).ToList() ?? [];

        db.Clients.Add(client);
        await db.SaveChangesAsync(ct);

        return MapToDto(client);
    }

    public async Task<ClientDto?> UpdateClientAsync(Guid id, UpdateClientRequest request, CancellationToken ct = default)
    {
        var client = await BuildScopedQuery()
            .Include(c => c.SubVentures)
            .FirstOrDefaultAsync(c => c.Id == id, ct);
        if (client is null) return null;

        if (request.Name is not null)
        {
            client.Name = request.Name.Trim();
            // Keep the logo in sync with the name (first + last letter).
            client.Logo = Client.LogoFromName(client.Name);
        }
        if (request.Industry is not null) client.Industry = request.Industry.Trim();
        if (request.Logo is not null) client.Logo = request.Logo;
        if (request.ContactEmail is not null) client.ContactEmail = request.ContactEmail;
        if (request.ClientType is not null) client.ClientType = request.ClientType == "OLD" ? ClientType.Old : ClientType.New;
        if (request.Status is not null &&
            Enum.TryParse<ClientStatus>(request.Status, ignoreCase: true, out var status))
        {
            client.Status = status;
        }
        if (request.EngagementManager is not null) client.EngagementManager = request.EngagementManager;
        if (request.ContactName is not null) client.ContactName = request.ContactName;
        if (request.ContactPhone is not null) client.ContactPhone = request.ContactPhone;
        if (request.ContactDesignation is not null) client.ContactDesignation = request.ContactDesignation;
        if (request.ContactType is not null) client.ContactType = request.ContactType;
        if (request.City is not null) client.City = request.City;
        if (request.Country is not null) client.Country = request.Country;
        if (request.BusinessType is not null) client.BusinessType = request.BusinessType;
        if (request.Notes is not null) client.Notes = request.Notes;
        if (request.KycDocumentName is not null) client.KycDocumentName = request.KycDocumentName;
        if (request.SubVentures is not null)
        {
            // Replace semantics: the incoming list is the full desired set (matched by
            // name, case-insensitive). Soft-delete removed rows, add new ones.
            var incoming = request.SubVentures.Select(ToSubVenture).ToList();
            var existing = client.SubVentures.ToList();

            foreach (var ex in existing)
            {
                if (!incoming.Any(i => string.Equals(i.Name, ex.Name, StringComparison.OrdinalIgnoreCase)))
                {
                    client.SubVentures.Remove(ex);
                }
            }
            foreach (var inc in incoming)
            {
                var match = existing.FirstOrDefault(e =>
                    string.Equals(e.Name, inc.Name, StringComparison.OrdinalIgnoreCase));
                if (match is not null)
                {
                    match.Name = inc.Name;
                    match.Contacts = inc.Contacts;
                }
                else
                {
                    inc.ClientId = client.Id;
                    // Track explicitly as Added: entities discovered only through a
                    // navigation collection are otherwise picked up by DetectChanges as
                    // Modified (they carry a non-default client-generated Id), which makes
                    // EF issue an UPDATE for a row that does not exist yet → 0 rows
                    // affected → DbUpdateConcurrencyException.
                    db.SubVentures.Add(inc);
                }
            }
        }
        if (request.Contacts is not null)
        {
            client.Contacts = request.Contacts.Select(ToContact).ToList();
        }

        await db.SaveChangesAsync(ct);
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

    private static ClientContact ToContact(ClientContactDto c) => new()
    {
        Name = c.Name,
        Email = c.Email,
        Phone = c.Phone,
        Designation = c.Designation,
        ContactType = c.ContactType,
    };

    private static SubVenture ToSubVenture(SubVentureInput s) => new()
    {
        Name = s.Name,
        Contacts = s.Contacts?.Select(ToContact).ToList() ?? [],
    };


    private static ClientDto MapToDto(Client c) => new(
        c.Id,
        c.Name,
        c.Industry,
        c.Logo,
        c.ContactEmail,
        c.ClientType == ClientType.Old ? "OLD" : "NEW",
        c.Status.ToString(),
        c.EngagementManager,
        c.ContactName,
        c.ContactPhone,
        c.ContactDesignation,
        c.ContactType,
        c.City,
        c.Country,
        c.BusinessType,
        c.Notes,
        c.KycDocumentName,
        c.SubVentures.Select(s => new SubVentureDto(
            s.Name,
            s.Contacts.Select(x => new ClientContactDto(x.Name, x.Email, x.Phone, x.Designation, x.ContactType)).ToList())).ToList(),
        c.Contacts.Select(x => new ClientContactDto(x.Name, x.Email, x.Phone, x.Designation, x.ContactType)).ToList(),
        c.CreatedAtUtc);
}

