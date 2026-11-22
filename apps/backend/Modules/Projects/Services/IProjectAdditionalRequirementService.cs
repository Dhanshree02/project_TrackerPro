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

    Task<ProjectAdditionalRequirementDto> TakeActionAsync(
        Guid projectId,
        Guid requirementId,
        AdditionalRequirementActionRequest request,
        CancellationToken ct = default);

    Task<ProjectAdditionalRequirementDto> AddCommentAsync(
        Guid projectId,
        Guid requirementId,
        AddRequirementCommentRequest request,
        CancellationToken ct = default);

    Task<ProjectAdditionalRequirementDto> TakeActionByIdentifierAsync(
        Guid? projectId,
        string identifier,
        AdditionalRequirementActionRequest request,
        CancellationToken ct = default);

    Task<ProjectAdditionalRequirementDto> ApproveByIdentifierAsync(
        Guid? projectId,
        string identifier,
        ApproveAdditionalRequirementRequest request,
        CancellationToken ct = default);

    Task<ProjectAdditionalRequirementDto> RejectByIdentifierAsync(
        Guid? projectId,
        string identifier,
        RejectAdditionalRequirementRequest request,
        CancellationToken ct = default);

    Task<ProjectAdditionalRequirementDto> AddCommentByIdentifierAsync(
        Guid? projectId,
        string identifier,
        AddRequirementCommentRequest request,
        CancellationToken ct = default);

    Task<IReadOnlyList<ProjectAdditionalRequirementDto>> ListPendingApprovalsAsync(
        CancellationToken ct = default);
}
