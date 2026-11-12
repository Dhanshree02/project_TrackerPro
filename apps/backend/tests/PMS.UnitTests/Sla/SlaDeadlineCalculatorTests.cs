using PMS.API.Modules.Sla.Models;
using PMS.API.Modules.Sla.Services;

namespace PMS.UnitTests.Sla;

public class SlaDeadlineCalculatorTests
{
    private readonly SlaDeadlineCalculator _calculator = new();

    [Fact]
    public void CalendarHours_AddsMinutesDirectly()
    {
        // Friday 10:00 AM UTC
        var start = new DateTime(2026, 11, 13, 10, 0, 0, DateTimeKind.Utc);
        var deadline = _calculator.CalculateTargetDeadline(
            start,
            120, // 2 hours
            SlaCalculationMode.CalendarHours);

        Assert.Equal(new DateTime(2026, 11, 13, 12, 0, 0, DateTimeKind.Utc), deadline);
    }

    [Fact]
    public void WorkingHours_WithinSameWorkingDay_AddsMinutesDirectly()
    {
        // Monday 10:00 AM UTC (Working window: 09:00 - 18:00)
        var start = new DateTime(2026, 11, 9, 10, 0, 0, DateTimeKind.Utc);
        var deadline = _calculator.CalculateTargetDeadline(
            start,
            180, // 3 hours -> 13:00 (within 18:00)
            SlaCalculationMode.WorkingHours,
            new TimeSpan(9, 0, 0),
            new TimeSpan(18, 0, 0),
            excludeWeekends: true);

        Assert.Equal(new DateTime(2026, 11, 9, 13, 0, 0, DateTimeKind.Utc), deadline);
    }

    [Fact]
    public void WorkingHours_SpanningOvernight_RollsToNextDay9AM()
    {
        // Monday 17:00 UTC (1 hour before 18:00 close)
        var start = new DateTime(2026, 11, 9, 17, 0, 0, DateTimeKind.Utc);
        var deadline = _calculator.CalculateTargetDeadline(
            start,
            120, // 2 hours total: 1 hour today (until 18:00) + 1 hour tomorrow (09:00 - 10:00)
            SlaCalculationMode.WorkingHours,
            new TimeSpan(9, 0, 0),
            new TimeSpan(18, 0, 0),
            excludeWeekends: true);

        Assert.Equal(new DateTime(2026, 11, 10, 10, 0, 0, DateTimeKind.Utc), deadline);
    }

    [Fact]
    public void WorkingHours_SpanningWeekend_SkipsSaturdayAndSunday()
    {
        // Friday 16:00 UTC (2 hours before 18:00 close)
        var start = new DateTime(2026, 11, 13, 16, 0, 0, DateTimeKind.Utc);
        Assert.Equal(DayOfWeek.Friday, start.DayOfWeek);

        var deadline = _calculator.CalculateTargetDeadline(
            start,
            180, // 3 hours total: 2 hours Friday (16:00-18:00) + 1 hour Monday (09:00-10:00)
            SlaCalculationMode.WorkingHours,
            new TimeSpan(9, 0, 0),
            new TimeSpan(18, 0, 0),
            excludeWeekends: true);

        Assert.Equal(DayOfWeek.Monday, deadline.DayOfWeek);
        Assert.Equal(new DateTime(2026, 11, 16, 10, 0, 0, DateTimeKind.Utc), deadline);
    }

    [Fact]
    public void WorkingHours_StartingOnWeekend_RollsToMonday9AMFirst()
    {
        // Saturday 14:00 UTC
        var start = new DateTime(2026, 11, 14, 14, 0, 0, DateTimeKind.Utc);
        Assert.Equal(DayOfWeek.Saturday, start.DayOfWeek);

        var deadline = _calculator.CalculateTargetDeadline(
            start,
            60, // 1 hour -> Monday 09:00 + 1 hr = 10:00
            SlaCalculationMode.WorkingHours,
            new TimeSpan(9, 0, 0),
            new TimeSpan(18, 0, 0),
            excludeWeekends: true);

        Assert.Equal(DayOfWeek.Monday, deadline.DayOfWeek);
        Assert.Equal(new DateTime(2026, 11, 16, 10, 0, 0, DateTimeKind.Utc), deadline);
    }

    [Fact]
    public void WorkingHours_ExcludingHoliday_SkipsConfiguredHolidays()
    {
        // Friday 16:00 UTC
        var start = new DateTime(2026, 11, 13, 16, 0, 0, DateTimeKind.Utc);
        var holidays = new HashSet<DateOnly>
        {
            new(2026, 11, 16) // Monday is a holiday!
        };

        var deadline = _calculator.CalculateTargetDeadline(
            start,
            180, // 2 hrs on Friday + 1 hr on next working day (Tuesday!)
            SlaCalculationMode.WorkingHours,
            new TimeSpan(9, 0, 0),
            new TimeSpan(18, 0, 0),
            excludeWeekends: true,
            excludeHolidays: true,
            holidays: holidays);

        Assert.Equal(DayOfWeek.Tuesday, deadline.DayOfWeek);
        Assert.Equal(new DateTime(2026, 11, 17, 10, 0, 0, DateTimeKind.Utc), deadline);
    }

    [Fact]
    public void EndOfDay_SameDay_TargetsWorkEnd()
    {
        // Monday 11:00 UTC
        var start = new DateTime(2026, 11, 9, 11, 0, 0, DateTimeKind.Utc);
        var deadline = _calculator.CalculateTargetDeadline(
            start,
            120, // Same-day requirement (< 1 day)
            SlaCalculationMode.EndOfDay,
            new TimeSpan(9, 0, 0),
            new TimeSpan(18, 0, 0));

        Assert.Equal(new DateTime(2026, 11, 9, 18, 0, 0, DateTimeKind.Utc), deadline);
    }

    [Fact]
    public void AdjustDeadlineForPause_ExtendsDeadlineAppropriately()
    {
        var currentDeadline = new DateTime(2026, 11, 9, 14, 0, 0, DateTimeKind.Utc);
        var pausedDuration = TimeSpan.FromHours(2);

        var extended = _calculator.AdjustDeadlineForPause(
            currentDeadline,
            pausedDuration,
            SlaCalculationMode.WorkingHours,
            new TimeSpan(9, 0, 0),
            new TimeSpan(18, 0, 0));

        Assert.Equal(new DateTime(2026, 11, 9, 16, 0, 0, DateTimeKind.Utc), extended);
    }
}
