using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.Customers.Services;

/// <summary>
/// Client module service. Implementations must apply role-based data scoping
/// (global roles see all clients; SPM/EM see assigned clients only).
/// </summary>
public interface IClientService
{
    Task<PagedResult<ClientDto>> GetClientsAsync(
        int page,
        int perPage,
        string? search,
        CancellationToken ct = default);

    Task<ClientDto?> GetClientAsync(Guid id, CancellationToken ct = default);

    Task<ClientDto> CreateClientAsync(CreateClientRequest request, CancellationToken ct = default);

    Task<ClientDto?> UpdateClientAsync(Guid id, UpdateClientRequest request, CancellationToken ct = default);

    /// <summary>Soft-deletes the client (sets DeletedAtUtc). Returns false when not found.</summary>
    Task<bool> SoftDeleteClientAsync(Guid id, CancellationToken ct = default);
}
