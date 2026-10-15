using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Shared.Exceptions;
using PMS.API.Modules.Customers.Services;
using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Users.Models;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Shared.Validation;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.Customers.Services;

public sealed class ClientService(AppDbContext db, ICurrentUserService currentUser) : IClientService
{
    // Roles that see every client.
    private static readonly HashSet<string> GlobalVisibilityRoleNames = new(StringComparer.OrdinalIgnoreCase)
    {
        "Admin", "Dhanshree", "CEO", "COO", "CTO", "PMO", "Pmo", "Hod", "BusinessOwner",
        "Sales", "Sales Manager", "Sales team member", "Accounts", "HR", "Hr", "IT Admin",
        "Testing HOD", "Consulting-HOD", "SOC-HOD"
    };

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

        var entities = await ApplyClientGraphIncludes(query)
            .OrderBy(c => c.Name)
            .Skip((page - 1) * perPage)
            .Take(perPage)
            .ToListAsync(ct);

        var clientCodes = await GetAllClientCodesAsync(ct);
        var items = entities.Select(e => MapToDto(e, clientCodes.GetValueOrDefault(e.Id))).ToList();
        return new PagedResult<ClientDto>(items, page, perPage, total);
    }

    public async Task<ClientDto?> GetClientAsync(Guid id, CancellationToken ct = default)
    {
        var entity = await ApplyClientGraphIncludes(BuildScopedQuery())
            .FirstOrDefaultAsync(c => c.Id == id, ct);
        if (entity is null) return null;
        var clientCodes = await GetAllClientCodesAsync(ct);
        return MapToDto(entity, clientCodes.GetValueOrDefault(entity.Id));
    }

    public async Task<ClientDto> CreateClientAsync(CreateClientRequest request, CancellationToken ct = default)
    {
        var trimmedName = request.Name.Trim();
        var existing = await db.Clients
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(c => c.Name.ToLower() == trimmedName.ToLower(), ct);

        var countryId = await ResolveCountryIdAsync(request.Country, ct);
        var subVentureInputs = request.SubVentures ?? [];

        if (existing is not null)
        {
            if (existing.DeletedAtUtc is not null)
            {
                // Restore on Re-Add!
                existing.DeletedAtUtc = null;
                existing.Name = trimmedName;
                existing.Industry = request.Industry.Trim();
                existing.IndustryId = await ResolveIndustryIdAsync(request.Industry, ct);
                existing.Logo = Client.LogoFromName(trimmedName);
                existing.ContactEmail = EmailRules.NullIfEmpty(request.ContactEmail);
                existing.ClientType = request.ClientType == "OLD" ? ClientType.Old : ClientType.New;
                existing.EngagementManager = NormalizeManagerName(request.EngagementManager);
                existing.EngagementManagerId = await ResolveEngagementManagerIdAsync(request.EngagementManager, ct);
                existing.SalesManager = NormalizeManagerName(request.SalesManager);
                existing.SalesManagerId = await ResolveSalesManagerIdAsync(request.SalesManager, ct);
                existing.ContactName = NormalizeManagerName(request.GroupSpocName) ?? request.ContactName;
                existing.ContactPhone = NormalizeManagerName(request.GroupSpocContact) ?? request.ContactPhone;
                existing.ContactDesignation = request.ContactDesignation;
                existing.ContactType = request.ContactType;
                existing.Country = request.Country;
                existing.CountryId = countryId;
                existing.City = request.City;
                existing.CityId = await ResolveCityIdAsync(request.City, countryId, ct);
                existing.BusinessType = request.BusinessType;
                existing.BillingMedium = NormalizeBillingMedium(request.BillingMedium);
                existing.GroupSpocName = NormalizeManagerName(request.GroupSpocName);
                existing.GroupSpocContact = NormalizeManagerName(request.GroupSpocContact);
                existing.Notes = request.Notes;
                existing.KycDocumentName = request.KycDocumentName;
                existing.UpdatedAtUtc = DateTime.UtcNow;

                await db.SaveChangesAsync(ct);
                await PersistContactsAsync(existing, request.Contacts, subVentureInputs, ct);

                var reloaded = await LoadClientGraphAsync(existing.Id, ct);
                var clientCodesMap = await GetAllClientCodesAsync(ct);
                return MapToDto(reloaded, clientCodesMap.GetValueOrDefault(reloaded.Id));
            }

            throw new ConflictException($"Customer '{trimmedName}' already exists.");
        }

        var client = new Client
        {
            Name = trimmedName,
            Industry = request.Industry.Trim(),
            IndustryId = await ResolveIndustryIdAsync(request.Industry, ct),
            // Logo is always derived from the client name.
            Logo = Client.LogoFromName(trimmedName),
            ContactEmail = EmailRules.NullIfEmpty(request.ContactEmail),
            ClientType = request.ClientType == "OLD" ? ClientType.Old : ClientType.New,
            EngagementManager = NormalizeManagerName(request.EngagementManager),
            EngagementManagerId = await ResolveEngagementManagerIdAsync(request.EngagementManager, ct),
            SalesManager = NormalizeManagerName(request.SalesManager),
            SalesManagerId = await ResolveSalesManagerIdAsync(request.SalesManager, ct),
            ContactName = NormalizeManagerName(request.GroupSpocName) ?? request.ContactName,
            ContactPhone = NormalizeManagerName(request.GroupSpocContact) ?? request.ContactPhone,
            ContactDesignation = request.ContactDesignation,
            ContactType = request.ContactType,
            Country = request.Country,
            CountryId = countryId,
            City = request.City,
            CityId = await ResolveCityIdAsync(request.City, countryId, ct),
            BusinessType = request.BusinessType,
            BillingMedium = NormalizeBillingMedium(request.BillingMedium),
            GroupSpocName = NormalizeManagerName(request.GroupSpocName),
            GroupSpocContact = NormalizeManagerName(request.GroupSpocContact),
            ClientCode = await ReserveClientCodeAsync(request.ClientCode, ct),
            GroupSpocPhoneCode = NormalizeManagerName(request.GroupSpocPhoneCode),
            CreatedByName = NormalizeManagerName(request.CreatedByName) ?? NormalizeManagerName(currentUser.Name),
            Notes = request.Notes,
            KycDocumentName = request.KycDocumentName,
            CustomerSince = TodayIst(),
        };

        client.SubVentures = subVentureInputs
            .Select(s => new SubVenture
            {
                ClientId = client.Id,
                Name = s.Name.Trim(),
                Notes = string.IsNullOrWhiteSpace(s.Notes) ? null : s.Notes.Trim(),
            })
            .ToList();

        await using var tx = await db.Database.BeginTransactionAsync(ct);
        client.ClientCode = await AllocateClientCodeAsync(ct);
        db.Clients.Add(client);
        await AssignMissingSubVentureCodesAsync(client.Id, client.SubVentures, ct);
        await db.SaveChangesAsync(ct);

        await PersistContactsAsync(client, request.Contacts, subVentureInputs, ct);
        await tx.CommitAsync(ct);

        var created = await LoadClientGraphAsync(client.Id, ct);
        var clientCodes = await GetAllClientCodesAsync(ct);
        return MapToDto(created, clientCodes.GetValueOrDefault(created.Id));
    }

    public async Task<ClientDto?> UpdateClientAsync(Guid id, UpdateClientRequest request, CancellationToken ct = default)
    {
        var client = await ApplyClientGraphIncludes(BuildScopedQuery())
            .FirstOrDefaultAsync(c => c.Id == id, ct);
        if (client is null) return null;

        await using var tx = await db.Database.BeginTransactionAsync(ct);

        if (request.Name is not null)
        {
            var trimmedName = request.Name.Trim();
            var duplicate = await db.Clients.AnyAsync(c => c.Id != id && c.Name.ToLower() == trimmedName.ToLower() && c.DeletedAtUtc == null, ct);
            if (duplicate)
            {
                throw new ConflictException($"Customer '{trimmedName}' already exists.");
            }
            client.Name = trimmedName;
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
            client.EngagementManager = NormalizeManagerName(request.EngagementManager);
            client.EngagementManagerId = await ResolveEngagementManagerIdAsync(request.EngagementManager, ct);
        }
        if (request.SalesManager is not null)
        {
            client.SalesManager = NormalizeManagerName(request.SalesManager);
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
        if (request.BillingMedium is not null) client.BillingMedium = NormalizeBillingMedium(request.BillingMedium);
        if (request.GroupSpocName is not null)
        {
            client.GroupSpocName = NormalizeManagerName(request.GroupSpocName);
            client.ContactName = client.GroupSpocName;
        }
        if (request.GroupSpocContact is not null)
        {
            client.GroupSpocContact = NormalizeManagerName(request.GroupSpocContact);
            client.ContactPhone = client.GroupSpocContact;
        }
        if (request.GroupSpocPhoneCode is not null)
            client.GroupSpocPhoneCode = NormalizeManagerName(request.GroupSpocPhoneCode);
        if (request.CreatedByName is not null && string.IsNullOrWhiteSpace(client.CreatedByName))
            client.CreatedByName = NormalizeManagerName(request.CreatedByName);
        if (request.Notes is not null) client.Notes = request.Notes;
        if (request.KycDocumentName is not null) client.KycDocumentName = request.KycDocumentName;
        if (request.SubVentures is not null)
        {
            // The incoming list is the full desired set. An id updates that row, including a rename.
            // A row without an id is matched by name, or added when the name is new.
            var incoming = request.SubVentures;
            var existing = client.SubVentures.ToList();

            bool Kept(SubVenture ex) => incoming.Any(i =>
                (i.Id is Guid id && id == ex.Id) ||
                (i.Id is null && string.Equals(i.Name, ex.Name, StringComparison.OrdinalIgnoreCase)));

            foreach (var ex in existing)
            {
                if (!Kept(ex))
                    client.SubVentures.Remove(ex);
            }

            foreach (var input in incoming)
            {
                SubVenture? match;
                if (input.Id is Guid subVentureId)
                {
                    match = existing.FirstOrDefault(e => e.Id == subVentureId);
                    if (match is null)
                        throw new NotFoundException($"Sub-venture '{subVentureId}' was not found for this client.");
                }
                else
                {
                    match = existing.FirstOrDefault(e =>
                        string.Equals(e.Name, input.Name, StringComparison.OrdinalIgnoreCase));
                }

                if (match is not null)
                {
                    match.Name = input.Name.Trim();
                    if (input.Notes is not null)
                        match.Notes = string.IsNullOrWhiteSpace(input.Notes) ? null : input.Notes.Trim();
                }
                else
                {
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

        await AssignMissingSubVentureCodesAsync(client.Id, client.SubVentures, ct);
        await db.SaveChangesAsync(ct);

        if (request.SubVentures is not null || request.Contacts is not null)
        {
            await PersistContactsAsync(client, request.Contacts, request.SubVentures, ct);
        }

        await tx.CommitAsync(ct);

        var updated = await LoadClientGraphAsync(client.Id, ct);
        var clientCodes = await GetAllClientCodesAsync(ct);
        return MapToDto(updated, clientCodes.GetValueOrDefault(updated.Id));
    }

    public async Task<bool> SoftDeleteClientAsync(Guid id, CancellationToken ct = default)
    {
        var client = await BuildScopedQuery().FirstOrDefaultAsync(c => c.Id == id, ct);
        if (client is null) return false;

        db.Clients.Remove(client); // SaveChanges converts to soft delete (DeletedAtUtc)
        await db.SaveChangesAsync(ct);
        return true;
    }

    public async Task<string> GetNextClientCodeAsync(CancellationToken ct = default)
    {
        var codes = await db.Clients.IgnoreQueryFilters()
            .Where(c => c.ClientCode != null && c.ClientCode != "")
            .Select(c => c.ClientCode!)
            .ToListAsync(ct);
        return NextClientCode(codes);
    }

    private async Task<string> AllocateClientCodeAsync(CancellationToken ct)
    {
        await db.Database.ExecuteSqlRawAsync(
            "SELECT pg_advisory_xact_lock(hashtext('client_code_seq'));");
        var codes = await db.Clients.IgnoreQueryFilters()
            .Where(c => c.ClientCode != null && c.ClientCode != "")
            .Select(c => c.ClientCode!)
            .ToListAsync(ct);
        return NextClientCode(codes);
    }

    private static string NextClientCode(IEnumerable<string> existing)
    {
        var max = 0;
        foreach (var code in existing)
        {
            var digits = new string(code.Where(char.IsDigit).ToArray());
            if (int.TryParse(digits, out var n) && n > max) max = n;
        }
        return "C" + (max + 1).ToString("D3");
    }

    private async Task EnsureClientCodeColumnAsync(CancellationToken ct)
    {
        var clients = db.TableName<Client>();
        await db.Database.ExecuteSqlRawAsync(
            $"""
            ALTER TABLE {clients} ADD COLUMN IF NOT EXISTS "ClientCode" character varying(20);
            CREATE UNIQUE INDEX IF NOT EXISTS "IX_clients_ClientCode" ON {clients} ("ClientCode");
            """,
            ct);
    }

    private async Task<Dictionary<Guid, string>> GetAllClientCodesAsync(CancellationToken ct)
    {
        await EnsureClientCodeColumnAsync(ct);
        var rows = await db.Clients
            .IgnoreQueryFilters()
            .OrderBy(c => c.CreatedAtUtc)
            .Select(c => new { c.Id, c.ClientCode })
            .ToListAsync(ct);

        var dict = new Dictionary<Guid, string>(rows.Count);
        var used = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var row in rows)
        {
            if (string.IsNullOrWhiteSpace(row.ClientCode)) continue;
            dict[row.Id] = row.ClientCode;
            used.Add(row.ClientCode);
        }

        var next = 0;
        foreach (var row in rows)
        {
            if (dict.ContainsKey(row.Id)) continue;
            string code;
            do
            {
                next++;
                code = "C" + next.ToString("D3");
            }
            while (used.Contains(code));
            dict[row.Id] = code;
            used.Add(code);
        }

        return dict;
    }

    /// <summary>
    /// Keeps a typed Customer ID. Customers created before this field keep the order-based code.
    /// </summary>
    private async Task<string?> ReserveClientCodeAsync(string? raw, CancellationToken ct)
    {
        var code = NormalizeClientCode(raw);
        if (code is null) return null;

        var existing = await GetAllClientCodesAsync(ct);
        if (existing.Values.Any(value => string.Equals(value, code, StringComparison.OrdinalIgnoreCase)))
            throw new ConflictException($"Customer ID '{code}' is already in use.");

        return code;
    }

    private static string? NormalizeClientCode(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return null;
        var trimmed = raw.Trim().ToUpperInvariant();
        var numbered = Regex.Match(trimmed, @"^(?:CUST-|CL-|C-?)0*(\d+)$", RegexOptions.IgnoreCase);
        if (numbered.Success)
            return "C" + int.Parse(numbered.Groups[1].Value).ToString("D3");
        if (!Regex.IsMatch(trimmed, @"^[A-Z0-9][A-Z0-9-]{0,19}$"))
            throw new ConflictException("Customer ID can use letters, numbers, and hyphens only.");
        return trimmed;
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
        var isGlobal = !string.IsNullOrEmpty(role) && GlobalVisibilityRoleNames.Contains(role);
        if (!isGlobal)
        {
            var userId = currentUser.UserId;
            var isEmOrSpm = string.Equals(role, "EngagementManager", StringComparison.OrdinalIgnoreCase) ||
                            string.Equals(role, "SeniorPm", StringComparison.OrdinalIgnoreCase);

            if (isEmOrSpm && !string.IsNullOrWhiteSpace(currentUser.Name))
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
        Country = NormalizeManagerName(c.Country),
        PhoneCode = NormalizeManagerName(c.PhoneCode),
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
        Country = NormalizeManagerName(c.Country),
        PhoneCode = NormalizeManagerName(c.PhoneCode),
        Designation = c.Designation,
        ContactType = c.ContactType,
    };

    /// <summary>
    /// Fills <see cref="SubVenture.SubVentureCode"/> on rows that do not have one yet.
    /// Holds a per-client advisory lock so two concurrent creates cannot take the same sequence.
    /// Existing codes are left as they are.
    /// </summary>
    private async Task AssignMissingSubVentureCodesAsync(
        Guid clientId,
        IEnumerable<SubVenture> ventures,
        CancellationToken ct)
    {
        await db.Database.ExecuteSqlRawAsync(
            "SELECT pg_advisory_xact_lock(hashtext('subventure_seq_' || {0}));",
            clientId.ToString());

        var pending = ventures.ToList();
        foreach (var entry in db.ChangeTracker.Entries<SubVenture>())
        {
            if (entry.Entity.ClientId == clientId
                && entry.State == EntityState.Added
                && !pending.Contains(entry.Entity))
            {
                pending.Add(entry.Entity);
            }
        }

        var existing = await db.SubVentures
            .IgnoreQueryFilters()
            .Where(s => s.ClientId == clientId && s.SubVentureCode != null && s.SubVentureCode != "")
            .Select(s => s.SubVentureCode!)
            .ToListAsync(ct);

        var clientCode = db.ChangeTracker.Entries<Client>()
            .Select(e => e.Entity)
            .FirstOrDefault(c => c.Id == clientId && !string.IsNullOrWhiteSpace(c.ClientCode))
            ?.ClientCode;
        if (string.IsNullOrWhiteSpace(clientCode))
        {
            clientCode = await db.Clients.IgnoreQueryFilters()
                .Where(c => c.Id == clientId)
                .Select(c => c.ClientCode)
                .FirstOrDefaultAsync(ct);
        }
        if (string.IsNullOrWhiteSpace(clientCode))
        {
            var codes = await GetAllClientCodesAsync(ct);
            clientCode = codes.GetValueOrDefault(clientId) ?? "C001";
        }

        var prefix = clientCode.Trim();
        var max = 0;
        foreach (var code in existing)
        {
            if (!string.Equals(SubVentureCodes.PrefixOf(code), prefix, StringComparison.OrdinalIgnoreCase))
                continue;
            var n = SubVentureCodes.ReadSequence(code);
            if (n > max) max = n;
        }
        foreach (var sv in pending)
        {
            if (string.IsNullOrWhiteSpace(sv.SubVentureCode)) continue;
            if (!string.Equals(SubVentureCodes.PrefixOf(sv.SubVentureCode), prefix, StringComparison.OrdinalIgnoreCase))
                continue;
            var n = SubVentureCodes.ReadSequence(sv.SubVentureCode);
            if (n > max) max = n;
        }

        var used = new HashSet<string>(existing, StringComparer.OrdinalIgnoreCase);
        foreach (var sv in pending)
        {
            if (!string.IsNullOrWhiteSpace(sv.SubVentureCode)) continue;

            string code;
            do
            {
                max++;
                code = SubVentureCodes.Format(prefix, max);
            }
            while (used.Contains(code)
                || await db.SubVentures.IgnoreQueryFilters().AnyAsync(s => s.SubVentureCode == code, ct));

            used.Add(code);
            sv.SubVentureCode = code;
        }
    }

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
            await FillContactPhoneCodesAsync(toAdd, ct);
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
        var needle = trimmed.ToLower();
        var existing = await db.Industries.FirstOrDefaultAsync(i => i.Name.ToLower() == needle, ct);
        return existing?.Id;
    }

    private async Task FillContactPhoneCodesAsync(List<ClientContactEntity> contacts, CancellationToken ct)
    {
        var names = contacts
            .Where(c => !string.IsNullOrWhiteSpace(c.Country) && string.IsNullOrWhiteSpace(c.PhoneCode))
            .Select(c => c.Country!.Trim())
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();
        if (names.Count == 0) return;

        var rows = await db.Countries
            .Where(c => names.Contains(c.Name) || names.Contains(c.Code))
            .Select(c => new { c.Name, c.Code, c.PhoneCode })
            .ToListAsync(ct);

        foreach (var contact in contacts)
        {
            if (string.IsNullOrWhiteSpace(contact.Country) || !string.IsNullOrWhiteSpace(contact.PhoneCode))
                continue;
            var match = rows.FirstOrDefault(r =>
                string.Equals(r.Name, contact.Country, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(r.Code, contact.Country, StringComparison.OrdinalIgnoreCase));
            if (match is not null) contact.PhoneCode = match.PhoneCode;
        }
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
                e.Designation != null && (
                    e.Designation.Name == "Delivery Account Manager - I" ||
                    e.Designation.Name == "Delivery Account Manager - II" ||
                    e.Designation.Name == "Senior Delivery Account Manager - I" ||
                    e.Designation.Name == "Senior Delivery Account Manager - II" ||
                    e.Designation.Name == "Engagement Manager"))
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
                e.Designation != null && (
                    e.Designation.Name == "Business Development Associate - I" ||
                    e.Designation.Name == "Customer Success Representative - II" ||
                    e.Designation.Name == "Sales Manager" ||
                    e.Designation.Name.Contains("Sales")))
            .FirstOrDefaultAsync(ct);

        return employee?.Id;
    }

    private static IQueryable<Client> ApplyClientGraphIncludes(IQueryable<Client> query) =>
        query
            .Include(c => c.IndustryRef)
            .Include(c => c.CountryRef)
            .Include(c => c.CityRef)
            .Include(c => c.EngagementManagerRef)
            .Include(c => c.SalesManagerRef)
            .Include(c => c.Contacts)
            .Include(c => c.SubVentures)
            .ThenInclude(s => s.Contacts);

    private Task<Client> LoadClientGraphAsync(Guid id, CancellationToken ct) =>
        ApplyClientGraphIncludes(db.Clients)
            .FirstAsync(c => c.Id == id, ct);

    public async Task<ClientDto?> SetClientKycAsync(Guid id, string fileName, string relativePath, CancellationToken ct = default)
    {
        var client = await ApplyClientGraphIncludes(BuildScopedQuery())
            .FirstOrDefaultAsync(c => c.Id == id, ct);
        if (client is null) return null;

        client.KycDocumentName = string.IsNullOrWhiteSpace(fileName) ? client.KycDocumentName : fileName.Trim();
        client.KycDocumentPath = string.IsNullOrWhiteSpace(relativePath) ? client.KycDocumentPath : relativePath.Trim();
        await db.SaveChangesAsync(ct);

        var reloaded = await LoadClientGraphAsync(client.Id, ct);
        var clientCodes = await GetAllClientCodesAsync(ct);
        return MapToDto(reloaded, clientCodes.GetValueOrDefault(reloaded.Id));
    }

    public async Task<(string ClientName, string? KycName, string? KycPath)?> GetClientKycRefAsync(Guid id, CancellationToken ct = default)
    {
        var client = await BuildScopedQuery()
            .Where(c => c.Id == id)
            .Select(c => new { c.Name, c.KycDocumentName, c.KycDocumentPath })
            .FirstOrDefaultAsync(ct);
        if (client is null) return null;
        return (client.Name, client.KycDocumentName, client.KycDocumentPath);
    }

    public async Task<ClientDto?> SetSubVentureKycAsync(Guid clientId, Guid subVentureId, string fileName, string relativePath, CancellationToken ct = default)
    {
        // Scope through the parent client so role-based visibility still applies.
        var client = await BuildScopedQuery().FirstOrDefaultAsync(c => c.Id == clientId, ct);
        if (client is null) return null;

        var sv = await db.SubVentures.FirstOrDefaultAsync(s => s.Id == subVentureId && s.ClientId == clientId, ct);
        if (sv is null) return null;

        sv.KycDocumentName = string.IsNullOrWhiteSpace(fileName) ? sv.KycDocumentName : fileName.Trim();
        sv.KycDocumentPath = string.IsNullOrWhiteSpace(relativePath) ? sv.KycDocumentPath : relativePath.Trim();
        await db.SaveChangesAsync(ct);

        var reloaded = await LoadClientGraphAsync(clientId, ct);
        var clientCodes = await GetAllClientCodesAsync(ct);
        return MapToDto(reloaded, clientCodes.GetValueOrDefault(reloaded.Id));
    }

    public async Task<(string ClientName, string SubVentureName, string? KycName, string? KycPath)?> GetSubVentureKycRefAsync(Guid clientId, Guid subVentureId, CancellationToken ct = default)
    {
        var client = await BuildScopedQuery()
            .Where(c => c.Id == clientId)
            .Select(c => new { c.Name })
            .FirstOrDefaultAsync(ct);
        if (client is null) return null;

        var sv = await db.SubVentures
            .Where(s => s.Id == subVentureId && s.ClientId == clientId)
            .Select(s => new { s.Name, s.KycDocumentName, s.KycDocumentPath })
            .FirstOrDefaultAsync(ct);
        if (sv is null) return null;

        return (client.Name, sv.Name, sv.KycDocumentName, sv.KycDocumentPath);
    }

    private static string? NormalizeManagerName(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static string? NormalizeBillingMedium(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static string? ManagerDisplay(string? stored, Employee? employee)
    {
        if (!string.IsNullOrWhiteSpace(stored)) return stored.Trim();
        if (employee is null) return null;
        var formatted = $"{employee.FirstName} {employee.LastName}".Trim();
        return string.IsNullOrWhiteSpace(formatted) ? null : formatted;
    }

    private static ClientDto MapToDto(Client c, string? clientCode = null) => new(
        c.Id,
        c.Name,
        c.IndustryRef?.Name ?? c.Industry,
        c.Logo,
        c.ContactEmail,
        c.ClientType == ClientType.Old ? "OLD" : "NEW",
        c.Status.ToString(),
        ManagerDisplay(c.EngagementManager, c.EngagementManagerRef),
        ManagerDisplay(c.SalesManager, c.SalesManagerRef),
        c.GroupSpocName ?? c.ContactName,
        c.GroupSpocContact ?? c.ContactPhone,
        c.ContactDesignation,
        c.ContactType,
        c.CityRef?.Name ?? c.City,
        c.CountryRef?.Name ?? c.Country,
        c.BusinessType,
        c.BillingMedium,
        c.GroupSpocName,
        c.GroupSpocContact,
        c.Notes,
        c.KycDocumentName,
        c.KycDocumentPath,
        c.SubVentures.Select(s => new SubVentureDto(
            s.Id,
            s.Name,
            s.Contacts.Select(x => new ClientContactDto(x.Name, x.Email, x.Phone, x.Designation, x.ContactType, x.Country, x.PhoneCode)).ToList(),
            s.Notes,
            s.KycDocumentName,
            s.KycDocumentPath,
            s.SubVentureCode)).ToList(),
        c.Contacts.Select(x => new ClientContactDto(x.Name, x.Email, x.Phone, x.Designation, x.ContactType, x.Country, x.PhoneCode)).ToList(),
        c.CustomerSince,
        c.CreatedAtUtc,
        c.ClientCode ?? clientCode,
        c.GroupSpocPhoneCode,
        c.CreatedByName);

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

