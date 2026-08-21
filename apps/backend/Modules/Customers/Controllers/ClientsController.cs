using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Services;
using PMS.API.Shared.Constants;
using PMS.API.Modules.Customers.Services;
using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Customers.Controllers;

[ApiController]
[Route("api/v1/clients")]
public class ClientsController(IClientService clients, ICatalogService catalogs) : ControllerBase
{
    [HttpGet]
    [RequirePermission(Permissions.ClientsRead)]
    public async Task<ActionResult<ApiResponse<PagedResult<ClientDto>>>> List(
        [FromQuery] int page = 1,
        [FromQuery] int perPage = 20,
        [FromQuery] string? search = null,
        CancellationToken ct = default)
    {
        page = Math.Max(1, page);
        perPage = Math.Clamp(perPage, 1, 100);
        var result = await clients.GetClientsAsync(page, perPage, search, ct);

        return Ok(ApiResponse<PagedResult<ClientDto>>.Ok(result, new ApiMeta
        {
            Total = result.Total,
            Page = result.Page,
            PerPage = result.PerPage,
            TotalPages = result.TotalPages,
        }));
    }

    [HttpGet("{id:guid}")]
    [RequirePermission(Permissions.ClientsRead)]
    public async Task<ActionResult<ApiResponse<ClientDto>>> Get(Guid id, CancellationToken ct)
    {
        var client = await clients.GetClientAsync(id, ct);
        return client is null ? NotFound(ApiResponse<ClientDto>.Fail("NOT_FOUND", "Client not found."))
            : Ok(ApiResponse<ClientDto>.Ok(client));
    }

    [HttpPost]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<ClientDto>>> Create(CreateClientRequest request, CancellationToken ct)
    {
        var client = await clients.CreateClientAsync(request, ct);
        return CreatedAtAction(nameof(Get), new { id = client.Id }, ApiResponse<ClientDto>.Ok(client));
    }

    [HttpPut("{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<ActionResult<ApiResponse<ClientDto>>> Update(Guid id, UpdateClientRequest request, CancellationToken ct)
    {
        var client = await clients.UpdateClientAsync(id, request, ct);
        return client is null ? NotFound(ApiResponse<ClientDto>.Fail("NOT_FOUND", "Client not found."))
            : Ok(ApiResponse<ClientDto>.Ok(client));
    }

    [HttpDelete("{id:guid}")]
    [RequirePermission(Permissions.ClientsWrite)]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        var deleted = await clients.SoftDeleteClientAsync(id, ct);
        return deleted ? NoContent() : NotFound(ApiResponse<ClientDto>.Fail("NOT_FOUND", "Client not found."));
    }

    [HttpGet("meta/industries")]
    [RequirePermission(Permissions.ClientsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<string>>>> Industries(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<string>>.Ok(await clients.GetIndustriesAsync(ct)));
    }

    [HttpGet("meta/countries")]
    [RequirePermission(Permissions.ClientsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CatalogOptionDto>>>> Countries(CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CatalogOptionDto>>.Ok(await catalogs.GetCountriesAsync(ct)));
    }

    [HttpGet("meta/cities")]
    [RequirePermission(Permissions.ClientsRead)]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<CityCatalogOptionDto>>>> Cities(
        [FromQuery] Guid? countryId,
        CancellationToken ct)
    {
        return Ok(ApiResponse<IReadOnlyList<CityCatalogOptionDto>>.Ok(
            await catalogs.GetCitiesAsync(countryId, ct)));
    }
}
