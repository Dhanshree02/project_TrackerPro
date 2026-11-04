using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectAdditionalRequirementService
{
    Task<ProjectAdditionalRequirementDto> CreateAsync(
        Guid projectId,
        CreateProjectAdditionalRequirementRequest request,
        IFormFile? file,
        CancellationToken ct = default);

    Task<IReadOnlyList<ProjectAdditionalRequirementDto>> ListAsync(
        Guid projectId,
        CancellationToken ct = default);

    Task<ProjectAdditionalRequirementDto> ApproveAsync(
        Guid projectId,
        Guid requirementId,
        ApproveAdditionalRequirementRequest request,
        CancellationToken ct = default);

    Task<ProjectAdditionalRequirementDto> RejectAsync(
        Guid projectId,
        Guid requirementId,
        RejectAdditionalRequirementRequest request,
        CancellationToken ct = default);

    Task<IReadOnlyList<ProjectAdditionalRequirementDto>> ListPendingApprovalsAsync(
        CancellationToken ct = default);
}
