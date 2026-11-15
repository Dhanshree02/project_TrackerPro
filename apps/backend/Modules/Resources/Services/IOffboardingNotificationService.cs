namespace PMS.API.Modules.Resources.Services;

public interface IOffboardingNotificationService
{
    /// <summary>
    /// Dispatches immediate notification to the Engagement Manager of each active project assigned
    /// to the offboarded resource immediately after the resignation/offboarding request is saved.
    /// </summary>
    Task<int> SendImmediateResignationNotificationAsync(
        Guid employeeId,
        string? initiatorName = null,
        Guid? initiatorId = null,
        CancellationToken ct = default);

    /// <summary>
    /// Processes recurring 2-day LWD reminder notifications to Engagement Managers up to the employee's Last Working Day.
    /// </summary>
    Task<int> ProcessLwdRemindersAsync(
        DateOnly? targetDateIst = null,
        CancellationToken ct = default);

    /// <summary>
    /// Sends post-offboarding notification to Head of Department and assigned Senior Project Managers
    /// on the next calendar date following the employee's Last Working Day.
    /// </summary>
    Task<int> ProcessPostOffboardingNotificationsAsync(
        DateOnly? targetDateIst = null,
        CancellationToken ct = default);
}
