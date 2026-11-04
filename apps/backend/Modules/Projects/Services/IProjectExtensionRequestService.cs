using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectExtensionRequestService
{
    Task<IReadOnlyList<ExtensionApproverDto>> ListApproversAsync(CancellationToken ct = default);

    Task<IReadOnlyList<ProjectExtensionRequestDto>> ListAsync(Guid projectId, CancellationToken ct = default);

    Task<ProjectExtensionRequestDto> CreateAsync(Guid projectId, CreateProjectExtensionRequest request, CancellationToken ct = default);

    Task<IReadOnlyList<PendingExtensionApprovalDto>> ListPendingApprovalsAsync(CancellationToken ct = default);

    Task<ProjectExtensionRequestDto> ApproveAsync(Guid projectId, Guid extensionRequestId, ApproveExtensionRequestDto request, CancellationToken ct = default);

    Task<ProjectExtensionRequestDto> RejectAsync(Guid projectId, Guid extensionRequestId, RejectExtensionRequestDto request, CancellationToken ct = default);
}
