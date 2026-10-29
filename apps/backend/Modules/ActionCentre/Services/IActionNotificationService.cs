using PMS.API.Modules.ActionCentre.DTOs;

namespace PMS.API.Modules.ActionCentre.Services;

public interface IActionNotificationService
{
    Task<IReadOnlyList<ActionNotificationDto>> GetNotificationsAsync(NotificationQueryParameters query, CancellationToken ct = default);
    Task<ActionNotificationDto> AcknowledgeNotificationAsync(Guid id, string comment, CancellationToken ct = default);
    Task<ActionNotificationDto> MarkNotificationAsReadAsync(Guid id, CancellationToken ct = default);

    Task<IReadOnlyList<ActionAlertDto>> GetAlertsAsync(NotificationQueryParameters query, CancellationToken ct = default);
    Task<ActionAlertDto> UpdateAlertGovernanceAsync(Guid id, UpdateAlertGovernanceRequest request, CancellationToken ct = default);
}
