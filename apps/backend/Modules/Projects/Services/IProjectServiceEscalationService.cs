using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectServiceEscalationService
{
    Task<IReadOnlyList<ServiceEscalationStakeholderDto>> ListStakeholdersAsync(CancellationToken ct = default);

    Task<IReadOnlyList<ProjectServiceEscalationDto>> ListAsync(Guid projectId, CancellationToken ct = default);

    Task<(Stream Stream, string ContentType, string FileName)?> DownloadAttachmentAsync(Guid projectId, Guid escalationId, CancellationToken ct = default);

    Task<ProjectServiceEscalationDto> CreateAsync(Guid projectId, CreateProjectServiceEscalationForm request, CancellationToken ct = default);
}
