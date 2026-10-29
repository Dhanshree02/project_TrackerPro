using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectIssueService
{
    Task<IReadOnlyList<AssignedProjectSummaryDto>> GetEmployeeAssignedProjectsAsync(CancellationToken ct = default);

    Task<IReadOnlyList<ProjectIssueDto>> GetProjectIssuesAsync(Guid projectId, CancellationToken ct = default);

    Task<ProjectIssueDto> CreateIssueAsync(Guid projectId, CreateProjectIssueRequest request, CancellationToken ct = default);

    Task<IReadOnlyList<ProjectAlertDto>> GetProjectAlertsAsync(Guid projectId, CancellationToken ct = default);

    Task<ProjectAlertDto> UpdateAlertStatusAsync(Guid projectId, Guid alertId, string status, CancellationToken ct = default);
}
