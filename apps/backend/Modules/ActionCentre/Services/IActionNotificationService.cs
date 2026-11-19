using Hangfire;
using PMS.API.Modules.ActionCentre.DTOs;

namespace PMS.API.Modules.ActionCentre.Services;

public interface IActionNotificationService
{
    Task<IReadOnlyList<ActionNotificationDto>> GetNotificationsAsync(NotificationQueryParameters query, CancellationToken ct = default);
    Task<ActionNotificationDto> MarkNotificationAsReadAsync(Guid id, CancellationToken ct = default);
    Task<ActionNotificationDto> ArchiveNotificationAsync(Guid id, string? comment = null, CancellationToken ct = default);

    Task<IReadOnlyList<ActionAlertDto>> GetAlertsAsync(NotificationQueryParameters query, CancellationToken ct = default);
    Task<ActionAlertDto> UpdateAlertGovernanceAsync(Guid id, UpdateAlertGovernanceRequest request, CancellationToken ct = default);
    Task<(Stream Stream, string ContentType, string FileName)?> DownloadAlertAttachmentAsync(Guid id, CancellationToken ct = default);

    Task NotifyCustomerOnboardedAsync(Guid clientId, string clientName, string? clientCode, string? createdByName, Guid? engagementManagerId = null, string? engagementManager = null, Guid? salesManagerId = null, string? salesManager = null, CancellationToken ct = default);
    Task NotifySubVentureOnboardedAsync(Guid clientId, string clientName, Guid subVentureId, string subVentureName, string? subVentureCode, string? createdByName, Guid? engagementManagerId = null, string? engagementManager = null, Guid? salesManagerId = null, string? salesManager = null, CancellationToken ct = default);
    Task NotifyCustomerEditedAsync(Guid clientId, string clientName, string? clientCode, string? performerName, IReadOnlyList<string>? modifiedFields = null, Guid? engagementManagerId = null, string? engagementManager = null, Guid? salesManagerId = null, string? salesManager = null, CancellationToken ct = default);
    Task NotifySubVentureEditedAsync(Guid clientId, string clientName, Guid subVentureId, string subVentureName, string? subVentureCode, string? performerName, IReadOnlyList<string>? modifiedFields = null, Guid? engagementManagerId = null, string? engagementManager = null, Guid? salesManagerId = null, string? salesManager = null, CancellationToken ct = default);
    Task NotifyWbsCreatedAsync(Guid projectId, string projectName, string? wbsId, string? projectCode, string? createdByName, CancellationToken ct = default);
    Task NotifyResourceOnboardedAsync(Guid employeeId, string employeeName, string employeeCode, Guid? reportingManagerId, string? performerName, CancellationToken ct = default);
    Task NotifyResourceProfileUpdatedAsync(Guid employeeId, string employeeName, string employeeCode, Guid? reportingManagerId, IReadOnlyList<string> modifiedFields, string? performerName, Guid? performerEmployeeId, CancellationToken ct = default);
    Task NotifyCustomerManagerChangedAsync(Guid clientId, string clientName, string? clientCode, string managerRole, string managerName, Guid? managerEmployeeId, string? previousManagerName = null, Guid? previousManagerEmployeeId = null, string? performerName = null, CancellationToken ct = default);
    Task NotifyRepositoryDocumentUploadedAsync(Guid documentId, string fileName, string category, IReadOnlyList<Guid> departmentIds, string? uploaderName, Guid? uploaderEmployeeId = null, CancellationToken ct = default);
    Task NotifyProjectLeadershipAssignedAsync(Guid projectId, string projectName, string? projectCode, Guid recipientEmployeeId, string leadershipRole, string? performerName, Guid? performerEmployeeId = null, CancellationToken ct = default);

    Task StartProjectAllocationReminderWorkflowAsync(Guid projectId, CancellationToken ct = default);
    Task CancelProjectAllocationRemindersAsync(Guid projectId, CancellationToken ct = default);

    [JobDisplayName("Project Allocation | PM-SPM Assignment Reminder | {1} | {2}")]
    Task ExecuteProjectAllocationReminderJobAsync(Guid projectId, string projectName, string wbsId, int reminderCount);

    [JobDisplayName("Project Allocation | Same-Day Pending Assignment Alert | HOD | {1} | {2}")]
    Task ExecuteSameDayHodCheckJobAsync(Guid projectId, string projectName, string wbsId);

    Task NotifyServiceStartedAsync(Guid projectId, Guid serviceId, string? performerName = null, CancellationToken ct = default);
    Task StartServicePrerequisiteSlaWorkflowAsync(Guid projectId, Guid serviceId, CancellationToken ct = default);
    Task CancelServicePrerequisiteSlaWorkflowAsync(Guid serviceId, CancellationToken ct = default);

    Task StartProjectServicePrerequisiteReminderWorkflowAsync(Guid projectId, CancellationToken ct = default);
    Task CancelProjectServicePrerequisiteReminderWorkflowAsync(Guid projectId, CancellationToken ct = default);

    [JobDisplayName("Service Prerequisite | 2-Day Daily EOD Reminder | PMO & EM | {0} | Day {1}")]
    Task ExecuteServicePrerequisitePendingReminderJobAsync(Guid projectId, int reminderDay);

    [JobDisplayName("Service Prerequisite | Daily EOD Check All Projects | PMO & EM")]
    Task ExecuteAllProjectsServicePrerequisiteDailyEodCheckAsync();

    [JobDisplayName("Service Prerequisite | 1st Level Breach Escalation | PM | {0} | {1}")]
    Task ExecuteServicePrerequisiteL1EscalationJobAsync(Guid projectId, Guid serviceId);

    [JobDisplayName("Service Prerequisite | 2nd Level Breach Escalation | HOD | {0} | {1}")]
    Task ExecuteServicePrerequisiteL2EscalationJobAsync(Guid projectId, Guid serviceId);

    Task NotifyServiceEditedAsync(Guid projectId, string serviceName, string action, string? details = null, string? performerName = null, CancellationToken ct = default);
    Task NotifyServiceModifiedAsync(Guid projectId, string serviceName, string? details = null, string? performerName = null, CancellationToken ct = default);
    Task NotifyServiceDeletedAsync(Guid projectId, string serviceName, string? performerName = null, CancellationToken ct = default);
    Task NotifyServiceAddedAsync(Guid projectId, string serviceName, string? details = null, string? performerName = null, CancellationToken ct = default);

    Task NotifyProjectTaskLifecycleAsync(
        Guid projectId,
        Guid taskId,
        string taskTitle,
        string? serviceName,
        string action,
        string? performerName = null,
        Guid? performerEmployeeId = null,
        CancellationToken ct = default);
}
