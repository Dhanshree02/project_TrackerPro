namespace PMS.API.Modules.MyTeam.Services;

/// <summary>
/// Service responsible for managing Team Availability and Shift Coverage notifications and escalations:
/// - Tier 1: 2-hour recurring reminders to Reporting Managers with pending reportees.
/// - Tier 2: 11:00 AM & 12:00 PM daily status alerts to PM, EM, and Team Leaders for project-allocated resources.
/// - Tier 3: 1:00 PM daily escalation alert to Senior Project Managers (SPMs).
/// - Tier 4: Next-day EOD (18:00 IST) compliance escalation to Head of Department (HOD) for unresolved prior-day records.
/// </summary>
public interface ITeamAvailabilityNotificationService
{
    Task<int> SendReportingManagerTwoHourRemindersAsync(DateOnly? targetDate = null, CancellationToken ct = default);
    Task<int> SendProjectLeadershipDailyAlertAsync(int hour, DateOnly? targetDate = null, CancellationToken ct = default);
    Task<int> SendSpmDailyAlertAsync(DateOnly? targetDate = null, CancellationToken ct = default);
    Task<int> SendHodNextDayEodEscalationAsync(DateOnly? targetDate = null, CancellationToken ct = default);
}
