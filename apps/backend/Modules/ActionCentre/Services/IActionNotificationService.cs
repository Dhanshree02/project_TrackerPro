using PMS.API.Modules.ActionCentre.DTOs;

namespace PMS.API.Modules.ActionCentre.Services;

public interface IActionNotificationService
{
    Task<IReadOnlyList<ActionNotificationDto>> GetNotificationsAsync(NotificationQueryParameters query, CancellationToken ct = default);
    Task<ActionNotificationDto> AcknowledgeNotificationAsync(Guid id, string comment, CancellationToken ct = default);
    Task<ActionNotificationDto> MarkNotificationAsReadAsync(Guid id, CancellationToken ct = default);

    Task<IReadOnlyList<ActionAlertDto>> GetAlertsAsync(NotificationQueryParameters query, CancellationToken ct = default);
    Task<ActionAlertDto> UpdateAlertGovernanceAsync(Guid id, UpdateAlertGovernanceRequest request, CancellationToken ct = default);
    Task<(Stream Stream, string ContentType, string FileName)?> DownloadAlertAttachmentAsync(Guid id, CancellationToken ct = default);

    Task NotifyCustomerOnboardedAsync(Guid clientId, string clientName, string? clientCode, string? createdByName, CancellationToken ct = default);
    Task NotifyWbsCreatedAsync(Guid projectId, string projectName, string? wbsId, string? projectCode, string? createdByName, CancellationToken ct = default);
    Task NotifyResourceOnboardedAsync(Guid employeeId, string employeeName, string employeeCode, Guid? reportingManagerId, string? performerName, CancellationToken ct = default);
}
