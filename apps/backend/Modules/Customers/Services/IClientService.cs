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

    Task<IReadOnlyList<string>> GetIndustriesAsync(CancellationToken ct = default);

    /// <summary>Persists the stored KYC file reference (name + Documents-relative path) on the client.</summary>
    Task<ClientDto?> SetClientKycAsync(Guid id, string fileName, string relativePath, CancellationToken ct = default);

    /// <summary>Returns the client name plus stored KYC reference for streaming; null when the client is missing.</summary>
    Task<(string ClientName, string? KycName, string? KycPath)?> GetClientKycRefAsync(Guid id, CancellationToken ct = default);

    /// <summary>Persists the stored KYC file reference on a specific sub-venture of the client.</summary>
    Task<ClientDto?> SetSubVentureKycAsync(Guid clientId, Guid subVentureId, string fileName, string relativePath, CancellationToken ct = default);

    /// <summary>Returns the client + sub-venture names and the sub-venture's KYC reference for streaming; null when missing.</summary>
    Task<(string ClientName, string SubVentureName, string? KycName, string? KycPath)?> GetSubVentureKycRefAsync(Guid clientId, Guid subVentureId, CancellationToken ct = default);
}
