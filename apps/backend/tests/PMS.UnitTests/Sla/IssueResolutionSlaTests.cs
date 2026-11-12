using PMS.API.Modules.Sla.Models;
using PMS.API.Modules.Sla.Services;
using Xunit;

namespace PMS.UnitTests.Sla;

public class IssueResolutionSlaTests
{
    private readonly SlaDeadlineCalculator _calculator = new();

    [Fact]
    public void IssueResolution_DuringWorkingHours_SetsDeadlineToEndOfSecondWorkingDay()
    {
        // Monday 10:00 AM IST (04:30 AM UTC)
        var startUtc = new DateTime(2026, 11, 9, 4, 30, 0, DateTimeKind.Utc);

        var policy = new SlaPolicy
        {
            Module = "Projects",
            ActivityType = "Resolution of Issues",
            Stage = "Open",
            TatDurationMinutes = 1080, // 2 working days (2 * 540)
            CalculationMode = SlaCalculationMode.EndOfDay,
            WorkingHoursStart = new TimeSpan(9, 0, 0),
            WorkingHoursEnd = new TimeSpan(18, 0, 0),
            ExcludeWeekends = true,
            ExcludeHolidays = true
        };

        var deadlineUtc = _calculator.CalculateTargetDeadline(startUtc, policy);

        // Expected: Wednesday 18:00 IST = Wednesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 11, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void IssueResolution_AfterWorkingHours_ClockStartsNextWorkingDay()
    {
        // Monday 19:30 IST (14:00 UTC) -> After 18:00 IST
        var startUtc = new DateTime(2026, 11, 9, 14, 0, 0, DateTimeKind.Utc);

        var policy = new SlaPolicy
        {
            Module = "Projects",
            ActivityType = "Resolution of Issues",
            Stage = "Open",
            TatDurationMinutes = 1080, // 2 working days
            CalculationMode = SlaCalculationMode.EndOfDay,
            WorkingHoursStart = new TimeSpan(9, 0, 0),
            WorkingHoursEnd = new TimeSpan(18, 0, 0),
            ExcludeWeekends = true,
            ExcludeHolidays = true
        };

        var deadlineUtc = _calculator.CalculateTargetDeadline(startUtc, policy);

        // Clock starts Tuesday 09:00 IST. 2 working days counting from Tuesday morning = Tuesday + Wednesday EOD.
        // Expected: Wednesday 18:00 IST = Wednesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 11, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void IssueResolution_SpanningWeekend_SkipsSaturdayAndSunday()
    {
        // Friday 14:00 IST (08:30 UTC)
        var startUtc = new DateTime(2026, 11, 13, 8, 30, 0, DateTimeKind.Utc);

        var policy = new SlaPolicy
        {
            Module = "Projects",
            ActivityType = "Resolution of Issues",
            Stage = "Open",
            TatDurationMinutes = 1080, // 2 working days
            CalculationMode = SlaCalculationMode.EndOfDay,
            WorkingHoursStart = new TimeSpan(9, 0, 0),
            WorkingHoursEnd = new TimeSpan(18, 0, 0),
            ExcludeWeekends = true,
            ExcludeHolidays = true
        };

        var deadlineUtc = _calculator.CalculateTargetDeadline(startUtc, policy);

        // Friday is Day 0. Day 1 is Monday. Day 2 is Tuesday.
        // Expected: Tuesday 18:00 IST = Tuesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 17, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void IssueResolution_WithHoliday_SkipsHolidayDate()
    {
        // Monday 10:00 IST (04:30 UTC), Tuesday is a public holiday
        var startUtc = new DateTime(2026, 11, 9, 4, 30, 0, DateTimeKind.Utc);
        var holidays = new HashSet<DateOnly> { new(2026, 11, 10) }; // Tuesday Nov 10

        var policy = new SlaPolicy
        {
            Module = "Projects",
            ActivityType = "Resolution of Issues",
            Stage = "Open",
            TatDurationMinutes = 1080, // 2 working days
            CalculationMode = SlaCalculationMode.EndOfDay,
            WorkingHoursStart = new TimeSpan(9, 0, 0),
            WorkingHoursEnd = new TimeSpan(18, 0, 0),
            ExcludeWeekends = true,
            ExcludeHolidays = true
        };

        var deadlineUtc = _calculator.CalculateTargetDeadline(startUtc, policy, holidays);

        // Monday Day 0 -> Tuesday (Holiday) skipped -> Wednesday Day 1 -> Thursday Day 2
        // Expected: Thursday 18:00 IST = Thursday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 12, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void SecondLevelEscalation_CalculatesEndOfNextWorkingDay()
    {
        // Level 1 escalation occurs at deadline: Wednesday 18:00 IST (12:30 UTC)
        var l1TimeUtc = new DateTime(2026, 11, 11, 12, 30, 0, DateTimeKind.Utc);

        var policy = new SlaPolicy
        {
            Module = "Projects",
            ActivityType = "Resolution of Issues",
            Stage = "Open",
            TatDurationMinutes = 540, // 1 working day
            CalculationMode = SlaCalculationMode.EndOfDay,
            WorkingHoursStart = new TimeSpan(9, 0, 0),
            WorkingHoursEnd = new TimeSpan(18, 0, 0),
            ExcludeWeekends = true,
            ExcludeHolidays = true
        };

        var l2DeadlineUtc = _calculator.CalculateTargetDeadline(l1TimeUtc, policy);

        // 1 working day from Wednesday 18:00 IST -> Thursday 18:00 IST = Thursday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 12, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, l2DeadlineUtc);
    }

    [Fact]
    public void UserExample_Monday11AM_GeneratesExactTimeline_Reminder_Deadline_Escalations()
    {
        // 1. Monday 11:00 AM IST (05:30 UTC) - Issue raised
        var issueRaisedUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);

        var policy = new SlaPolicy
        {
            Module = "Projects",
            ActivityType = "Resolution of Issues",
            Stage = "Open",
            TatDurationMinutes = 1080, // 2 working days
            CalculationMode = SlaCalculationMode.EndOfDay,
            WorkingHoursStart = new TimeSpan(9, 0, 0),
            WorkingHoursEnd = new TimeSpan(18, 0, 0),
            ExcludeWeekends = true,
            ExcludeHolidays = true
        };

        // 2. Tuesday 6:00 PM IST (12:30 UTC) - First daily reminder
        var firstReminderUtc = _calculator.GetNextWorkingDayEndOfDayUtc(issueRaisedUtc);
        Assert.Equal(new DateTime(2026, 11, 10, 12, 30, 0, DateTimeKind.Utc), firstReminderUtc);

        // 3. Wednesday 6:00 PM IST (12:30 UTC) - Two-working-day SLA deadline & L1 escalation
        var slaDeadlineUtc = _calculator.CalculateTargetDeadline(issueRaisedUtc, policy);
        Assert.Equal(new DateTime(2026, 11, 11, 12, 30, 0, DateTimeKind.Utc), slaDeadlineUtc);

        // 4. Thursday 6:00 PM IST (12:30 UTC) - L2 escalation calculated from actual L1 execution
        var actualL1ExecutionUtc = slaDeadlineUtc; // Executed successfully at Wednesday 6:00 PM IST
        var l2DeadlineUtc = _calculator.GetNextWorkingDayEndOfDayUtc(actualL1ExecutionUtc);
        Assert.Equal(new DateTime(2026, 11, 12, 12, 30, 0, DateTimeKind.Utc), l2DeadlineUtc);
    }

    [Fact]
    public void DailyReminder_SpanningWeekend_SkipsSaturdayAndSunday()
    {
        // Friday 18:00 IST (12:30 UTC)
        var fridayEodUtc = new DateTime(2026, 11, 13, 12, 30, 0, DateTimeKind.Utc);
        var nextReminderUtc = _calculator.GetNextWorkingDayEndOfDayUtc(fridayEodUtc);

        // Skips Saturday & Sunday -> Monday 18:00 IST (12:30 UTC)
        Assert.Equal(new DateTime(2026, 11, 16, 12, 30, 0, DateTimeKind.Utc), nextReminderUtc);
    }

    [Fact]
    public void DailyReminder_WithHoliday_SkipsHolidayDate()
    {
        // Monday 18:00 IST (12:30 UTC), Tuesday is a public holiday
        var mondayEodUtc = new DateTime(2026, 11, 9, 12, 30, 0, DateTimeKind.Utc);
        var holidays = new HashSet<DateOnly> { new(2026, 11, 10) }; // Tuesday

        var nextReminderUtc = _calculator.GetNextWorkingDayEndOfDayUtc(mondayEodUtc, holidays);

        // Skips Tuesday -> Wednesday 18:00 IST (12:30 UTC)
        Assert.Equal(new DateTime(2026, 11, 11, 12, 30, 0, DateTimeKind.Utc), nextReminderUtc);
    }
}
