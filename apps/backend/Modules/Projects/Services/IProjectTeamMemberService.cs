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

    Task<IReadOnlyList<EmployeeAllocationBookingDto>> ListOtherAllocationsAsync(
        Guid projectId,
        Guid employeeId,
        CancellationToken ct = default);

    Task<ProjectTeamMemberDto> AddAsync(Guid projectId, CreateProjectTeamMemberRequest request, CancellationToken ct = default);

    Task<ProjectTeamMemberDto> UpdateAsync(
        Guid projectId,
        Guid memberId,
        UpdateProjectTeamMemberRequest request,
        CancellationToken ct = default);

    Task<bool> RemoveAsync(Guid projectId, Guid memberId, CancellationToken ct = default);

    Task<IReadOnlyList<ProjectTeamMemberDto>> SetLeadershipAsync(
        Guid projectId,
        SetProjectLeadershipRequest request,
        CancellationToken ct = default);

    Task<ProjectResourceAllocationRequestDto> RequestAllocationAsync(
        Guid projectId,
        CreateResourceAllocationRequest request,
        CancellationToken ct = default);

    Task<IReadOnlyList<ProjectResourceAllocationRequestDto>> ListPendingAllocationsAsync(
        CancellationToken ct = default);

    Task<IReadOnlyList<ProjectResourceAllocationRequestDto>> ListProjectAllocationRequestsAsync(
        Guid projectId,
        CancellationToken ct = default);

    Task<ProjectResourceAllocationRequestDto> TakeAllocationActionAsync(
        Guid projectId,
        Guid requestId,
        ResourceAllocationActionRequest request,
        CancellationToken ct = default);

    Task<EmployeeWorkloadDto> GetEmployeeWorkloadAsync(
        Guid employeeId,
        Guid? projectId = null,
        CancellationToken ct = default);
}
