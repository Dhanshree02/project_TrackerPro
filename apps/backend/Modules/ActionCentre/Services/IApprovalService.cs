using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Services;

public interface IApprovalService
{
    Task<PagedResult<ApprovalRequestDto>> GetApprovalsAsync(ApprovalQueryParameters query, CancellationToken ct = default);
    Task<ApprovalMetricsDto> GetMetricsAsync(CancellationToken ct = default);
    Task<ApprovalRequestDto?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<ApprovalRequestDto> CreateApprovalAsync(CreateApprovalRequestDto request, CancellationToken ct = default);
    Task<ApprovalRequestDto> TakeActionAsync(Guid id, ApprovalActionRequest actionRequest, CancellationToken ct = default);
}
