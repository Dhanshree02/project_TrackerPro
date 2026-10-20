using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectInterviewService
{
    Task<IReadOnlyList<ProjectInterviewDto>> ListAsync(Guid projectId, CancellationToken ct = default);

    Task<ProjectInterviewDto> CreateAsync(Guid projectId, CreateProjectInterviewRequest request, CancellationToken ct = default);

    Task<ProjectInterviewDto> UpdateAsync(Guid projectId, Guid interviewId, UpdateProjectInterviewRequest request, CancellationToken ct = default);
}
