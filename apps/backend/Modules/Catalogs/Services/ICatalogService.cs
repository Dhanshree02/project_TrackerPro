using PMS.API.Modules.Catalogs.DTOs;

namespace PMS.API.Modules.Catalogs.Services;

/// <summary>
/// Shared master-catalog lookups (country / city). Used by any module that
/// currently stores those values as free text.
/// </summary>
public interface ICatalogService
{
    Task<IReadOnlyList<CatalogOptionDto>> GetCountriesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CatalogOptionDto>> GetNationalitiesAsync(CancellationToken ct = default);

    Task<IReadOnlyList<CityCatalogOptionDto>> GetCitiesAsync(Guid? countryId, CancellationToken ct = default);
}
