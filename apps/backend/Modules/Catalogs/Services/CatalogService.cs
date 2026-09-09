using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Services;

public sealed class CatalogService(AppDbContext db) : ICatalogService
{
    public async Task<IReadOnlyList<CatalogOptionDto>> GetCountriesAsync(CancellationToken ct = default)
    {
        return await db.Countries
            .Where(c => c.IsActive)
            .OrderBy(c => c.Name)
            .Select(c => new CatalogOptionDto(c.Id, c.Code, c.Name, c.PhoneCode, c.PhoneDigits))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetNationalitiesAsync(CancellationToken ct = default)
    {
        return await db.Nationalities
            .Where(n => n.IsActive)
            .OrderBy(n => n.Name)
            .Select(n => new CatalogOptionDto(n.Id, n.Code, n.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CityCatalogOptionDto>> GetCitiesAsync(
        Guid? countryId,
        CancellationToken ct = default)
    {
        var query = db.Cities.Where(c => c.IsActive);
        if (countryId is not null)
        {
            query = query.Where(c => c.CountryId == countryId);
        }

        return await query
            .OrderBy(c => c.Name)
            .Select(c => new CityCatalogOptionDto(c.Id, c.Code, c.Name, c.CountryId))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetIndustriesAsync(CancellationToken ct = default)
    {
        return await db.Industries
            .Where(i => i.IsActive)
            .OrderBy(i => i.Name)
            .Select(i => new CatalogOptionDto(i.Id, i.Code, i.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetContactDesignationsAsync(CancellationToken ct = default)
    {
        return await db.ContactDesignations
            .Where(d => d.IsActive)
            .OrderBy(d => d.SortOrder)
            .ThenBy(d => d.Name)
            .Select(d => new CatalogOptionDto(d.Id, d.Code, d.Name, null, null))
            .ToListAsync(ct);
    }

    public async Task<IReadOnlyList<CatalogOptionDto>> GetContactTypesAsync(CancellationToken ct = default)
    {
        return await db.ContactTypes
            .Where(t => t.IsActive)
            .OrderBy(t => t.SortOrder)
            .ThenBy(t => t.Name)
            .Select(t => new CatalogOptionDto(t.Id, t.Code, t.Name, null, null))
            .ToListAsync(ct);
    }
}
