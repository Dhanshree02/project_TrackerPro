using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Services;

/// <summary>
/// Calculates SLA target deadlines and working durations considering
/// calendar time, operating business hours, weekends, and holidays.
/// </summary>
public interface ISlaDeadlineCalculator
{
    /// <summary>
    /// Computes the exact target deadline in UTC given a start time and policy parameters.
    /// </summary>
    DateTime CalculateTargetDeadline(
        DateTime startAtUtc,
        int durationMinutes,
        SlaCalculationMode calculationMode,
        TimeSpan? workingHoursStart = null,
        TimeSpan? workingHoursEnd = null,
        bool excludeWeekends = true,
        bool excludeHolidays = true,
        IReadOnlySet<DateOnly>? holidays = null,
        bool useBusinessTimeZone = false);

    /// <summary>
    /// Computes the target deadline using the configured SlaPolicy (uses IST business timezone).
    /// </summary>
    DateTime CalculateTargetDeadline(DateTime startAtUtc, SlaPolicy policy, IReadOnlySet<DateOnly>? holidays = null);

    /// <summary>
    /// Computes the End-Of-Day (18:00 IST) deadline for the next working day in UTC,
    /// skipping weekends and configured company holidays.
    /// </summary>
    DateTime GetNextWorkingDayEndOfDayUtc(
        DateTime fromUtc,
        IReadOnlySet<DateOnly>? holidays = null,
        TimeSpan? workingHoursEnd = null);

    /// <summary>
    /// Computes the same-day End-Of-Day (18:00 IST) deadline in UTC for a task assignment.
    /// Considers planned shifts (General, Morning, Afternoon, Night), weekends, holidays, and leave.
    /// </summary>
    DateTime CalculateSameDayEndOfDayUtc(
        DateTime assignedAtUtc,
        string? shiftName = null,
        string? attendance = null,
        IReadOnlySet<DateOnly>? holidays = null,
        TimeSpan? workingHoursEnd = null);

    /// <summary>
    /// Computes the same-day End-Of-Day deadline for an assigned employee by looking up their shift and leave calendar.
    /// </summary>
    Task<DateTime> CalculateSameDayEndOfDayForEmployeeAsync(
        DateTime assignedAtUtc,
        Guid employeeId,
        IReadOnlySet<DateOnly>? holidays = null,
        CancellationToken ct = default);

    /// <summary>
    /// Computes the next daily pause reminder for a resource who paused their task,
    /// aligned to the end of that resource's assigned shift (General 18:00, Morning 14:00, Afternoon 22:00, Night 06:00 next day IST).
    /// </summary>
    Task<DateTime> CalculateNextPauseReminderForEmployeeAsync(
        DateTime fromUtc,
        Guid employeeId,
        IReadOnlySet<DateOnly>? holidays = null,
        CancellationToken ct = default);

    /// <summary>
    /// Adjusts an existing deadline when an instance resumes from paused state.
    /// </summary>
    DateTime AdjustDeadlineForPause(
        DateTime currentDeadlineUtc,
        TimeSpan pausedDuration,
        SlaCalculationMode calculationMode,
        TimeSpan? workingHoursStart = null,
        TimeSpan? workingHoursEnd = null,
        bool excludeWeekends = true,
        bool excludeHolidays = true,
        IReadOnlySet<DateOnly>? holidays = null,
        bool useBusinessTimeZone = false);
}
