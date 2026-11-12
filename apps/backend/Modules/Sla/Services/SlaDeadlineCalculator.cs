using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Sla.Models;

namespace PMS.API.Modules.Sla.Services;

public sealed class SlaDeadlineCalculator(AppDbContext? db = null) : ISlaDeadlineCalculator
{
    private static readonly TimeSpan DefaultStart = new(9, 0, 0);
    private static readonly TimeSpan DefaultEnd = new(18, 0, 0);

    public static readonly TimeZoneInfo IndianTimeZone = ResolveIndianTimeZone();

    private static TimeZoneInfo ResolveIndianTimeZone()
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById("Asia/Kolkata");
        }
        catch
        {
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById("India Standard Time");
            }
            catch
            {
                return TimeZoneInfo.CreateCustomTimeZone(
                    "IST",
                    TimeSpan.FromHours(5.5),
                    "India Standard Time",
                    "India Standard Time");
            }
        }
    }

    public DateTime CalculateTargetDeadline(
        DateTime startAtUtc,
        int durationMinutes,
        SlaCalculationMode calculationMode,
        TimeSpan? workingHoursStart = null,
        TimeSpan? workingHoursEnd = null,
        bool excludeWeekends = true,
        bool excludeHolidays = true,
        IReadOnlySet<DateOnly>? holidays = null,
        bool useBusinessTimeZone = false)
    {
        if (durationMinutes <= 0)
        {
            return startAtUtc;
        }

        return calculationMode switch
        {
            SlaCalculationMode.CalendarHours => startAtUtc.AddMinutes(durationMinutes),
            SlaCalculationMode.WorkingHours => CalculateWorkingHoursDeadline(
                startAtUtc,
                durationMinutes,
                workingHoursStart ?? DefaultStart,
                workingHoursEnd ?? DefaultEnd,
                excludeWeekends,
                excludeHolidays,
                holidays,
                useBusinessTimeZone),
            SlaCalculationMode.EndOfDay => CalculateEndOfDayDeadline(
                startAtUtc,
                durationMinutes,
                workingHoursStart ?? DefaultStart,
                workingHoursEnd ?? DefaultEnd,
                excludeWeekends,
                excludeHolidays,
                holidays,
                useBusinessTimeZone),
            _ => startAtUtc.AddMinutes(durationMinutes)
        };
    }

    public DateTime CalculateTargetDeadline(DateTime startAtUtc, SlaPolicy policy, IReadOnlySet<DateOnly>? holidays = null)
    {
        return CalculateTargetDeadline(
            startAtUtc,
            policy.TatDurationMinutes,
            policy.CalculationMode,
            policy.WorkingHoursStart,
            policy.WorkingHoursEnd,
            policy.ExcludeWeekends,
            policy.ExcludeHolidays,
            holidays,
            useBusinessTimeZone: true);
    }

    public DateTime GetNextWorkingDayEndOfDayUtc(
        DateTime fromUtc,
        IReadOnlySet<DateOnly>? holidays = null,
        TimeSpan? workingHoursEnd = null)
    {
        var workStart = DefaultStart;
        var workEnd = workingHoursEnd ?? DefaultEnd;
        var fromIst = TimeZoneInfo.ConvertTimeFromUtc(fromUtc, IndianTimeZone);

        // Advance to next calendar date and resolve next working day
        var nextDay = fromIst.Date.AddDays(1);
        var targetDate = MoveToNextWorkingDay(nextDay, workStart, excludeWeekends: true, excludeHolidays: true, holidays).Date;
        var deadlineIst = targetDate.Add(workEnd);
        return TimeZoneInfo.ConvertTimeToUtc(deadlineIst, IndianTimeZone);
    }

    public DateTime CalculateSameDayEndOfDayUtc(
        DateTime assignedAtUtc,
        string? shiftName = null,
        string? attendance = null,
        IReadOnlySet<DateOnly>? holidays = null,
        TimeSpan? workingHoursEnd = null)
    {
        var workStart = DefaultStart;
        var workEnd = workingHoursEnd ?? DefaultEnd;
        var fromIst = TimeZoneInfo.ConvertTimeFromUtc(assignedAtUtc, IndianTimeZone);
        var workDate = DateOnly.FromDateTime(fromIst);

        // Normalize shift: default to "General" if null, empty, whitespace, unmapped, or invalid
        string normalizedShift = "General";
        if (!string.IsNullOrWhiteSpace(shiftName))
        {
            var s = shiftName.Trim();
            if (s.Equals("Morning", StringComparison.OrdinalIgnoreCase)) normalizedShift = "Morning";
            else if (s.Equals("Afternoon", StringComparison.OrdinalIgnoreCase)) normalizedShift = "Afternoon";
            else if (s.Equals("Night", StringComparison.OrdinalIgnoreCase)) normalizedShift = "Night";
            else if (s.Equals("General", StringComparison.OrdinalIgnoreCase)) normalizedShift = "General";
            else normalizedShift = "General";
        }

        var isOnLeave = string.Equals(attendance, "leave", StringComparison.OrdinalIgnoreCase);

        // Check if assigned after shift end on this calendar date
        var timeOfDay = fromIst.TimeOfDay;
        bool isAfterShift = false;

        if (normalizedShift.Equals("Morning", StringComparison.OrdinalIgnoreCase))
        {
            // Morning shift is 06:00 - 14:00 IST
            isAfterShift = timeOfDay > new TimeSpan(14, 0, 0);
        }
        else if (normalizedShift.Equals("Afternoon", StringComparison.OrdinalIgnoreCase))
        {
            // Afternoon shift is 14:00 - 22:00 IST
            isAfterShift = timeOfDay > new TimeSpan(22, 0, 0);
        }
        else if (normalizedShift.Equals("Night", StringComparison.OrdinalIgnoreCase))
        {
            // Night shift is 22:00 - 06:00 next morning.
            isAfterShift = false;
        }
        else
        {
            // General shift: 09:00 - 18:00 IST
            isAfterShift = timeOfDay > workEnd;
        }

        DateOnly targetDate = workDate;

        // If assigned after shift, advance to next calendar date
        if (isAfterShift)
        {
            targetDate = targetDate.AddDays(1);
        }

        // If today is on leave, advance to next calendar date
        if (isOnLeave && targetDate == workDate)
        {
            targetDate = targetDate.AddDays(1);
        }

        // Skip weekends and holidays
        while (targetDate.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday || (holidays != null && holidays.Contains(targetDate)))
        {
            targetDate = targetDate.AddDays(1);
        }

        // For Night Shift, shift crosses midnight and ends at 06:00 next morning
        if (normalizedShift.Equals("Night", StringComparison.OrdinalIgnoreCase))
        {
            DateTime deadlineNightIst;
            if (timeOfDay < new TimeSpan(6, 0, 0) && !isAfterShift && targetDate == workDate)
            {
                // In progress shift ending this morning at 06:00 IST
                deadlineNightIst = targetDate.ToDateTime(new TimeOnly(6, 0, 0));
            }
            else
            {
                // Night shift starting on targetDate evening (22:00) and ending next morning at 06:00 AM IST
                var nextMorning = targetDate.AddDays(1);
                deadlineNightIst = nextMorning.ToDateTime(new TimeOnly(6, 0, 0));
            }
            return TimeZoneInfo.ConvertTimeToUtc(deadlineNightIst, IndianTimeZone);
        }

        TimeOnly shiftEndTime;
        if (normalizedShift.Equals("Morning", StringComparison.OrdinalIgnoreCase))
        {
            shiftEndTime = new TimeOnly(14, 0, 0);
        }
        else if (normalizedShift.Equals("Afternoon", StringComparison.OrdinalIgnoreCase))
        {
            shiftEndTime = new TimeOnly(22, 0, 0);
        }
        else
        {
            shiftEndTime = new TimeOnly(workEnd.Hours, workEnd.Minutes, workEnd.Seconds);
        }

        var deadlineIst = targetDate.ToDateTime(shiftEndTime);
        return TimeZoneInfo.ConvertTimeToUtc(deadlineIst, IndianTimeZone);
    }

    public async Task<DateTime> CalculateSameDayEndOfDayForEmployeeAsync(
        DateTime assignedAtUtc,
        Guid employeeId,
        IReadOnlySet<DateOnly>? holidays = null,
        CancellationToken ct = default)
    {
        string? shift = null;
        string? attendance = null;

        var fromIst = TimeZoneInfo.ConvertTimeFromUtc(assignedAtUtc, IndianTimeZone);
        var workDate = DateOnly.FromDateTime(fromIst);

        if (holidays == null && db != null)
        {
            holidays = await db.LeaveCalendarHolidays
                .AsNoTracking()
                .Where(h => h.DeletedAtUtc == null)
                .Select(h => h.HolidayDate)
                .ToHashSetAsync(ct);
        }

        if (db != null)
        {
            var entry = await db.TeamDayEntries
                .AsNoTracking()
                .Where(e => e.EmployeeId == employeeId && e.WorkDate == workDate && e.DeletedAtUtc == null)
                .Select(e => new { e.Shift, e.Attendance })
                .FirstOrDefaultAsync(ct);

            if (entry != null)
            {
                shift = entry.Shift;
                attendance = entry.Attendance;
            }
        }

        var deadlineUtc = CalculateSameDayEndOfDayUtc(assignedAtUtc, shift, attendance, holidays);

        // If rolled forward because of after-shift, leave, or weekend, check if target date has a shift entry
        if (db != null)
        {
            var deadlineIst = TimeZoneInfo.ConvertTimeFromUtc(deadlineUtc, IndianTimeZone);
            var targetCalDate = DateOnly.FromDateTime(deadlineIst);
            var targetWorkDate = deadlineIst.TimeOfDay <= new TimeSpan(6, 0, 0) ? targetCalDate.AddDays(-1) : targetCalDate;

            if (targetWorkDate != workDate)
            {
                var targetEntry = await db.TeamDayEntries
                    .AsNoTracking()
                    .Where(e => e.EmployeeId == employeeId && e.WorkDate == targetWorkDate && e.DeletedAtUtc == null)
                    .Select(e => new { e.Shift, e.Attendance })
                    .FirstOrDefaultAsync(ct);

                if (targetEntry != null && !string.IsNullOrWhiteSpace(targetEntry.Shift))
                {
                    var targetFromUtc = TimeZoneInfo.ConvertTimeToUtc(targetWorkDate.ToDateTime(new TimeOnly(9, 0, 0)), IndianTimeZone);
                    deadlineUtc = CalculateSameDayEndOfDayUtc(targetFromUtc, targetEntry.Shift, targetEntry.Attendance, holidays);
                }
            }
        }

        return deadlineUtc;
    }

    public async Task<DateTime> CalculateNextPauseReminderForEmployeeAsync(
        DateTime fromUtc,
        Guid employeeId,
        IReadOnlySet<DateOnly>? holidays = null,
        CancellationToken ct = default)
    {
        return await CalculateSameDayEndOfDayForEmployeeAsync(fromUtc, employeeId, holidays, ct);
    }

    public DateTime AdjustDeadlineForPause(
        DateTime currentDeadlineUtc,
        TimeSpan pausedDuration,
        SlaCalculationMode calculationMode,
        TimeSpan? workingHoursStart = null,
        TimeSpan? workingHoursEnd = null,
        bool excludeWeekends = true,
        bool excludeHolidays = true,
        IReadOnlySet<DateOnly>? holidays = null,
        bool useBusinessTimeZone = false)
    {
        var pausedMinutes = (int)Math.Ceiling(pausedDuration.TotalMinutes);
        if (pausedMinutes <= 0) return currentDeadlineUtc;

        return CalculateTargetDeadline(
            currentDeadlineUtc,
            pausedMinutes,
            calculationMode,
            workingHoursStart,
            workingHoursEnd,
            excludeWeekends,
            excludeHolidays,
            holidays,
            useBusinessTimeZone);
    }

    private static DateTime CalculateWorkingHoursDeadline(
        DateTime startAtUtc,
        int durationMinutes,
        TimeSpan workStart,
        TimeSpan workEnd,
        bool excludeWeekends,
        bool excludeHolidays,
        IReadOnlySet<DateOnly>? holidays,
        bool useBusinessTimeZone)
    {
        if (workEnd <= workStart)
        {
            workEnd = workStart.Add(TimeSpan.FromHours(9));
        }

        var start = useBusinessTimeZone
            ? TimeZoneInfo.ConvertTimeFromUtc(startAtUtc, IndianTimeZone)
            : startAtUtc;

        var cursor = AlignToWorkingHours(start, workStart, workEnd, excludeWeekends, excludeHolidays, holidays);
        var remainingMinutes = durationMinutes;
        var safetyCounter = 0;

        while (remainingMinutes > 0 && safetyCounter++ < 500)
        {
            var dayEnd = cursor.Date.Add(workEnd);
            var availableMinutesToday = (int)(dayEnd - cursor).TotalMinutes;

            if (remainingMinutes <= availableMinutesToday)
            {
                cursor = cursor.AddMinutes(remainingMinutes);
                remainingMinutes = 0;
            }
            else
            {
                remainingMinutes -= availableMinutesToday;
                // Move to start of next working day
                cursor = MoveToNextWorkingDay(cursor.Date.AddDays(1), workStart, excludeWeekends, excludeHolidays, holidays);
            }
        }

        return useBusinessTimeZone
            ? TimeZoneInfo.ConvertTimeToUtc(cursor, IndianTimeZone)
            : cursor;
    }

    private static DateTime CalculateEndOfDayDeadline(
        DateTime startAtUtc,
        int durationMinutes,
        TimeSpan workStart,
        TimeSpan workEnd,
        bool excludeWeekends,
        bool excludeHolidays,
        IReadOnlySet<DateOnly>? holidays,
        bool useBusinessTimeZone)
    {
        if (workEnd <= workStart)
        {
            workEnd = workStart.Add(TimeSpan.FromHours(9));
        }

        if (!useBusinessTimeZone)
        {
            var cursorUtc = AlignToWorkingHours(startAtUtc, workStart, workEnd, excludeWeekends, excludeHolidays, holidays);
            var dailyWorkingMinutesUtc = (int)(workEnd - workStart).TotalMinutes;
            if (dailyWorkingMinutesUtc <= 0) dailyWorkingMinutesUtc = 540;

            var additionalDaysUtc = durationMinutes / dailyWorkingMinutesUtc;
            var dayRemainderUtc = durationMinutes % dailyWorkingMinutesUtc;

            if (additionalDaysUtc == 0 && dayRemainderUtc > 0)
            {
                return cursorUtc.Date.Add(workEnd);
            }

            for (var i = 0; i < additionalDaysUtc; i++)
            {
                cursorUtc = MoveToNextWorkingDay(cursorUtc.Date.AddDays(1), workStart, excludeWeekends, excludeHolidays, holidays);
            }

            return cursorUtc.Date.Add(workEnd);
        }

        // IST Business EOD behavior
        var startIst = TimeZoneInfo.ConvertTimeFromUtc(startAtUtc, IndianTimeZone);
        var dailyWorkingMinutes = (int)(workEnd - workStart).TotalMinutes;
        if (dailyWorkingMinutes <= 0) dailyWorkingMinutes = 540;

        DateTime cursor;
        bool isNextDayMorning = false;
        if (IsNonWorkingDay(startIst.Date, excludeWeekends, excludeHolidays, holidays) || startIst.TimeOfDay >= workEnd)
        {
            cursor = MoveToNextWorkingDay(startIst.Date.AddDays(1), workStart, excludeWeekends, excludeHolidays, holidays);
            isNextDayMorning = true;
        }
        else if (startIst.TimeOfDay < workStart)
        {
            cursor = startIst.Date.Add(workStart);
            isNextDayMorning = true;
        }
        else
        {
            cursor = startIst;
        }

        var targetDays = durationMinutes / dailyWorkingMinutes;
        if (targetDays <= 0 && durationMinutes > 0)
        {
            targetDays = 1;
        }

        var advancesNeeded = isNextDayMorning ? (targetDays - 1) : targetDays;
        if (advancesNeeded < 0) advancesNeeded = 0;

        var targetDate = cursor.Date;
        for (var i = 0; i < advancesNeeded; i++)
        {
            targetDate = MoveToNextWorkingDay(targetDate.AddDays(1), workStart, excludeWeekends, excludeHolidays, holidays).Date;
        }

        var deadlineIst = targetDate.Add(workEnd);
        return TimeZoneInfo.ConvertTimeToUtc(deadlineIst, IndianTimeZone);
    }

    private static DateTime AlignToWorkingHours(
        DateTime current,
        TimeSpan workStart,
        TimeSpan workEnd,
        bool excludeWeekends,
        bool excludeHolidays,
        IReadOnlySet<DateOnly>? holidays)
    {
        while (IsNonWorkingDay(current.Date, excludeWeekends, excludeHolidays, holidays))
        {
            current = current.Date.AddDays(1).Add(workStart);
        }

        var timeOfDay = current.TimeOfDay;

        if (timeOfDay < workStart)
        {
            return current.Date.Add(workStart);
        }

        if (timeOfDay >= workEnd)
        {
            var nextDay = current.Date.AddDays(1);
            return MoveToNextWorkingDay(nextDay, workStart, excludeWeekends, excludeHolidays, holidays);
        }

        return current;
    }

    public static DateTime MoveToNextWorkingDay(
        DateTime day,
        TimeSpan workStart,
        bool excludeWeekends,
        bool excludeHolidays,
        IReadOnlySet<DateOnly>? holidays)
    {
        var cursor = day.Date;
        var safetyCounter = 0;

        while (IsNonWorkingDay(cursor, excludeWeekends, excludeHolidays, holidays) && safetyCounter++ < 60)
        {
            cursor = cursor.AddDays(1);
        }

        return cursor.Add(workStart);
    }

    public static bool IsNonWorkingDay(
        DateTime date,
        bool excludeWeekends,
        bool excludeHolidays,
        IReadOnlySet<DateOnly>? holidays)
    {
        if (excludeWeekends && (date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday))
        {
            return true;
        }

        if (excludeHolidays && holidays != null && holidays.Contains(DateOnly.FromDateTime(date)))
        {
            return true;
        }

        return false;
    }
}
