using PMS.API.Modules.Projects.DTOs;

namespace PMS.API.Modules.Projects.Services;

public interface IProjectFeedbackService
{
    Task<ProjectFeedbackDto> CreateAsync(Guid projectId, CreateProjectFeedbackRequest request, CancellationToken ct = default);
    Task<IReadOnlyList<ProjectFeedbackDto>> ListByProjectAsync(Guid projectId, Guid? employeeId = null, CancellationToken ct = default);
    Task<IReadOnlyList<ProjectFeedbackDto>> ListPendingApprovalsAsync(CancellationToken ct = default);
    Task<ProjectFeedbackDto> TakeApprovalActionAsync(Guid feedbackId, FeedbackApprovalActionRequest request, CancellationToken ct = default);
}
