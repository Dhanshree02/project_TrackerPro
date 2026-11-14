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
    Task NotifyCustomerEditedAsync(Guid clientId, string clientName, string? clientCode, string? performerName, Guid? engagementManagerId = null, string? engagementManager = null, Guid? salesManagerId = null, string? salesManager = null, CancellationToken ct = default);
    Task NotifySubVentureEditedAsync(Guid clientId, string clientName, Guid subVentureId, string subVentureName, string? subVentureCode, string? performerName, Guid? engagementManagerId = null, string? engagementManager = null, Guid? salesManagerId = null, string? salesManager = null, CancellationToken ct = default);
    Task NotifyWbsCreatedAsync(Guid projectId, string projectName, string? wbsId, string? projectCode, string? createdByName, CancellationToken ct = default);
    Task NotifyResourceOnboardedAsync(Guid employeeId, string employeeName, string employeeCode, Guid? reportingManagerId, string? performerName, CancellationToken ct = default);
    Task NotifyResourceProfileUpdatedAsync(Guid employeeId, string employeeName, string employeeCode, Guid? reportingManagerId, IReadOnlyList<string> modifiedFields, string? performerName, Guid? performerEmployeeId, CancellationToken ct = default);
    Task NotifyCustomerManagerChangedAsync(Guid clientId, string clientName, string? clientCode, string managerRole, string managerName, Guid? managerEmployeeId, string? previousManagerName = null, Guid? previousManagerEmployeeId = null, string? performerName = null, CancellationToken ct = default);
    Task NotifyRepositoryDocumentUploadedAsync(Guid documentId, string fileName, string category, IReadOnlyList<Guid> departmentIds, string? uploaderName, Guid? uploaderEmployeeId = null, CancellationToken ct = default);
}
