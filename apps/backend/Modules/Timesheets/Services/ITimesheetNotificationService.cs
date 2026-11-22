using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Timesheets.Models;

namespace PMS.API.Modules.Timesheets.Services;

/// <summary>
/// Service responsible for dispatching Action Centre notifications for Timesheet submissions,
/// approval decisions (Approved, Rejected, Changes Requested), and alternate-day submission reminders.
/// Reuses the centralized ActionNotification system (action.tbl_notifications).
/// </summary>
public interface ITimesheetNotificationService
{
    /// <summary>
    /// Dispatches a notification to the resource's Reporting Manager when a timesheet is submitted.
    /// Also stops any pending submission reminders for this timesheet week.
    /// </summary>
    Task NotifyTimesheetSubmittedAsync(
        TimesheetWeek week,
        Employee resource,
        CancellationToken ct = default);

    /// <summary>
    /// Dispatches a notification to the resource when the Reporting Manager approves, rejects,
    /// or requests changes on their timesheet.
    /// Also synchronizes the manager's prior submission notification to the new status.
    /// </summary>
    Task NotifyTimesheetDecidedAsync(
        TimesheetWeek week,
        Employee reviewer,
        string action,
        string? comment,
        CancellationToken ct = default);

    /// <summary>
    /// Processes alternate-day timesheet submission reminders for resources who have not submitted
    /// their timesheet within the open submission window (Friday through Monday deadline).
    /// </summary>
    Task<int> ProcessTimesheetRemindersAsync(
        DateOnly? overrideToday = null,
        CancellationToken ct = default);
}
