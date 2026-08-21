using Microsoft.AspNetCore.Mvc;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Services;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Catalogs.Controllers;

/// <summary>
/// Shared catalogs. Authenticated callers from any module can load these
/// for country / city / nationality dropdowns.
/// </summary>
[ApiController]
[Route("api/v1/catalogs")]
public class CatalogsController(ICatalogService catalogs) : ControllerBase
{
    [HttpGet("countries")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CatalogOptionDto>>>> Countries(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CatalogOptionDto>>.Ok(await catalogs.GetCountriesAsync(ct)));
    }

    [HttpGet("nationalities")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CatalogOptionDto>>>> Nationalities(
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CatalogOptionDto>>.Ok(await catalogs.GetNationalitiesAsync(ct)));
    }

    [HttpGet("cities")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CityCatalogOptionDto>>>> Cities(
        [FromQuery] Guid? countryId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CityCatalogOptionDto>>.Ok(
            await catalogs.GetCitiesAsync(countryId, ct)));
    }
}
