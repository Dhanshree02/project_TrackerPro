using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectTeamMemberService
{
    Task<IReadOnlyList<ProjectTeamMemberDto>> ListAsync(
        Guid projectId,
        bool shadowTeam = false,
        CancellationToken ct = default);

    Task<ProjectTeamMemberDto?> GetByIdAsync(Guid projectId, Guid memberId, CancellationToken ct = default);

    Task<IReadOnlyList<ProjectTeamCandidateDto>> SearchCandidatesAsync(
        Guid projectId,
        string? search,
        int limit = 50,
        bool internsOnly = false,
        CancellationToken ct = default);

    Task<ProjectTeamMemberDto> AddAsync(Guid projectId, CreateProjectTeamMemberRequest request, CancellationToken ct = default);

    Task<ProjectTeamMemberDto> UpdateAsync(
        Guid projectId,
        Guid memberId,
        UpdateProjectTeamMemberRequest request,
        CancellationToken ct = default);

    Task<bool> RemoveAsync(Guid projectId, Guid memberId, CancellationToken ct = default);
}
