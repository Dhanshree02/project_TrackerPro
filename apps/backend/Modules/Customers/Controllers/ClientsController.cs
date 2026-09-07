using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Storage;
using PMS.API.Modules.Catalogs.DTOs;
using PMS.API.Modules.Catalogs.Services;
using PMS.API.Shared.Constants;
using PMS.API.Modules.Customers.Services;
using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Customers.Controllers;

[ApiController]
[Route("api/v1/clients")]
public class ClientsController(IClientService clients, ICatalogService catalogs, IFileStorageService storage) : ControllerBase
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

    /// <summary>Uploads the client's KYC document into the Documents/KYC folder and stores its reference.</summary>
    [HttpPost("{id:guid}/kyc")]
    [RequirePermission(Permissions.ClientsWrite)]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<ApiResponse<ClientDto>>> UploadKyc(Guid id, IFormFile file, CancellationToken ct)
    {
        if (file is null || file.Length == 0)
        {
            return BadRequest(ApiResponse<ClientDto>.Fail("NO_FILE", "Please attach a KYC document."));
        }

        var kycRef = await clients.GetClientKycRefAsync(id, ct);
        if (kycRef is null)
        {
            return NotFound(ApiResponse<ClientDto>.Fail("NOT_FOUND", "Client not found."));
        }

        var stored = await storage.SaveKycDocumentAsync(kycRef.Value.ClientName, file, ct);
        var updated = await clients.SetClientKycAsync(id, stored.OriginalFileName, stored.RelativePath, ct);
        return updated is null
            ? NotFound(ApiResponse<ClientDto>.Fail("NOT_FOUND", "Client not found."))
            : Ok(ApiResponse<ClientDto>.Ok(updated));
    }

    /// <summary>Streams the stored KYC document (inline preview, or download=true for attachment).</summary>
    [HttpGet("{id:guid}/kyc")]
    [RequirePermission(Permissions.ClientsRead)]
    public async Task<IActionResult> GetKyc(Guid id, [FromQuery] bool download = false, CancellationToken ct = default)
    {
        var kycRef = await clients.GetClientKycRefAsync(id, ct);
        if (kycRef is null)
        {
            return NotFound(ApiResponse<object>.Fail("NOT_FOUND", "Client not found."));
        }

        var lookup = !string.IsNullOrWhiteSpace(kycRef.Value.KycPath)
            ? kycRef.Value.KycPath!
            : kycRef.Value.KycName;

        if (string.IsNullOrWhiteSpace(lookup))
        {
            return NotFound(ApiResponse<object>.Fail("NO_KYC", "No KYC document is attached to this client."));
        }

        var fileResult = storage.GetKycFileStream(lookup);
        if (fileResult is null)
        {
            return NotFound(ApiResponse<object>.Fail("FILE_NOT_FOUND", "The KYC document file was not found on the server."));
        }

        var (stream, contentType, _) = fileResult.Value;
        var downloadName = string.IsNullOrWhiteSpace(kycRef.Value.KycName) ? "kyc-document" : kycRef.Value.KycName!;

        if (download)
        {
            return File(stream, contentType, downloadName);
        }

        Response.Headers["Content-Disposition"] = $"inline; filename=\"{downloadName.Replace("\"", "")}\"";
        return File(stream, contentType);
    }

    /// <summary>Uploads a sub-venture's KYC document into Documents/KYC and stores its reference.</summary>
    [HttpPost("{clientId:guid}/subventures/{subVentureId:guid}/kyc")]
    [RequirePermission(Permissions.ClientsWrite)]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<ApiResponse<ClientDto>>> UploadSubVentureKyc(Guid clientId, Guid subVentureId, IFormFile file, CancellationToken ct)
    {
        if (file is null || file.Length == 0)
        {
            return BadRequest(ApiResponse<ClientDto>.Fail("NO_FILE", "Please attach a KYC document."));
        }

        var kycRef = await clients.GetSubVentureKycRefAsync(clientId, subVentureId, ct);
        if (kycRef is null)
        {
            return NotFound(ApiResponse<ClientDto>.Fail("NOT_FOUND", "Client or sub-venture not found."));
        }

        var label = $"{kycRef.Value.ClientName}_{kycRef.Value.SubVentureName}";
        var stored = await storage.SaveKycDocumentAsync(label, file, ct);
        var updated = await clients.SetSubVentureKycAsync(clientId, subVentureId, stored.OriginalFileName, stored.RelativePath, ct);
        return updated is null
            ? NotFound(ApiResponse<ClientDto>.Fail("NOT_FOUND", "Client or sub-venture not found."))
            : Ok(ApiResponse<ClientDto>.Ok(updated));
    }

    /// <summary>Streams a sub-venture's stored KYC document (inline preview, or download=true for attachment).</summary>
    [HttpGet("{clientId:guid}/subventures/{subVentureId:guid}/kyc")]
    [RequirePermission(Permissions.ClientsRead)]
    public async Task<IActionResult> GetSubVentureKyc(Guid clientId, Guid subVentureId, [FromQuery] bool download = false, CancellationToken ct = default)
    {
        var kycRef = await clients.GetSubVentureKycRefAsync(clientId, subVentureId, ct);
        if (kycRef is null)
        {
            return NotFound(ApiResponse<object>.Fail("NOT_FOUND", "Client or sub-venture not found."));
        }

        var lookup = !string.IsNullOrWhiteSpace(kycRef.Value.KycPath)
            ? kycRef.Value.KycPath!
            : kycRef.Value.KycName;

        if (string.IsNullOrWhiteSpace(lookup))
        {
            return NotFound(ApiResponse<object>.Fail("NO_KYC", "No KYC document is attached to this sub-venture."));
        }

        var fileResult = storage.GetKycFileStream(lookup);
        if (fileResult is null)
        {
            return NotFound(ApiResponse<object>.Fail("FILE_NOT_FOUND", "The KYC document file was not found on the server."));
        }

        var (stream, contentType, _) = fileResult.Value;
        var downloadName = string.IsNullOrWhiteSpace(kycRef.Value.KycName) ? "kyc-document" : kycRef.Value.KycName!;

        if (download)
        {
            return File(stream, contentType, downloadName);
        }

        Response.Headers["Content-Disposition"] = $"inline; filename=\"{downloadName.Replace("\"", "")}\"";
        return File(stream, contentType);
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
