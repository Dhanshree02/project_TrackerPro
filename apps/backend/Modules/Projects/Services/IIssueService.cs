using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IIssueService
{
    Task<IssueResponse> CreateIssueAsync(CreateIssueRequest request, CancellationToken cancellationToken = default);
    Task<List<IssueProjectOption>> GetProjectOptionsAsync(CancellationToken cancellationToken = default);
    Task<List<IssueResponse>> GetIssuesAsync(Guid? projectId = null, string? status = null, int? escalationLevel = null, string? assigneeRole = null, CancellationToken cancellationToken = default);
    Task<IssueResponse?> GetIssueByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IssueResponse> UpdateIssueStatusAsync(Guid id, UpdateIssueStatusRequest request, CancellationToken cancellationToken = default);
    Task<IssueResponse> EscalateIssueManuallyAsync(Guid id, string actorName, string? notes = null, CancellationToken cancellationToken = default);
}
