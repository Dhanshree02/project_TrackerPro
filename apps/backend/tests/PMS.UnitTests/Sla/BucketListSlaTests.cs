using PMS.API.Modules.Sla.Models;
using PMS.API.Modules.Sla.Services;
using Xunit;

namespace PMS.UnitTests.Sla;

public class BucketListSlaTests
{
    private readonly SlaDeadlineCalculator _calculator = new();

    #region Activity 1: Task Start After Assigning - Shifts & Deadlines

    [Fact]
    public void TaskStart_GeneralShift_AssignedDuringHours_SetsDeadlineToSameDay1800Ist()
    {
        // Monday 11:00 AM IST (05:30 UTC)
        var assignedUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "General",
            attendance: "onsite");

        // Expected: Monday 18:00 IST = Monday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_MorningShift_AssignedDuringHours_SetsDeadlineToSameDay1400Ist()
    {
        // Monday 08:00 AM IST (02:30 UTC)
        var assignedUtc = new DateTime(2026, 11, 9, 2, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "Morning",
            attendance: "onsite");

        // Morning shift 06:00 - 14:00 IST. Expected: Monday 14:00 IST = Monday 08:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 8, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_AfternoonShift_AssignedDuringHours_SetsDeadlineToSameDay2200Ist()
    {
        // Monday 15:00 IST (09:30 UTC)
        var assignedUtc = new DateTime(2026, 11, 9, 9, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "Afternoon",
            attendance: "onsite");

        // Afternoon shift 14:00 - 22:00 IST. Expected: Monday 22:00 IST = Monday 16:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 16, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_NightShift_AssignedAt10Am_SetsDeadlineToNextMorning0600Ist()
    {
        // Monday 10:00 AM IST (04:30 UTC)
        var assignedUtc = new DateTime(2026, 11, 9, 4, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "Night",
            attendance: "onsite");

        // Night shift 22:00 Monday - 06:00 Tuesday. Expected: Tuesday 06:00 IST = Tuesday 00:30 UTC
        var expectedUtc = new DateTime(2026, 11, 10, 0, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_NightShift_AssignedAt11Pm_SetsDeadlineToNextMorning0600Ist()
    {
        // Monday 23:00 IST (17:30 UTC)
        var assignedUtc = new DateTime(2026, 11, 9, 17, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "Night",
            attendance: "onsite");

        // Night shift 22:00 - 06:00 next day IST. Expected: Tuesday 06:00 IST = Tuesday 00:30 UTC
        var expectedUtc = new DateTime(2026, 11, 10, 0, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_NightShift_AssignedOnFridayNight_EndsSaturday0600Ist()
    {
        // Friday 23:00 IST (17:30 UTC)
        var assignedUtc = new DateTime(2026, 11, 13, 17, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "Night",
            attendance: "onsite");

        // Friday night shift finishes Saturday 06:00 IST = Saturday 00:30 UTC
        var expectedUtc = new DateTime(2026, 11, 14, 0, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_NullShift_DefaultsToGeneralShift1800Ist()
    {
        // Monday 11:00 AM IST (05:30 UTC) with NULL shift
        var assignedUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: null,
            attendance: "onsite");

        // Expected: Monday 18:00 IST = Monday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_EmptyShift_DefaultsToGeneralShift1800Ist()
    {
        // Monday 11:00 AM IST (05:30 UTC) with whitespace shift
        var assignedUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "   ",
            attendance: "onsite");

        // Expected: Monday 18:00 IST = Monday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_InvalidShift_DefaultsToGeneralShift1800Ist()
    {
        // Monday 11:00 AM IST (05:30 UTC) with invalid/unmapped shift name
        var assignedUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "Rotational_Custom_Shift_XYZ",
            attendance: "onsite");

        // Expected: Monday 18:00 IST = Monday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_AssignedAfterShiftHours_RollsToNextWorkingDayEod()
    {
        // Monday 19:00 IST (13:30 UTC) -> after 18:00 IST general shift
        var assignedUtc = new DateTime(2026, 11, 9, 13, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "General",
            attendance: "onsite");

        // Expected: Tuesday 18:00 IST = Tuesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 10, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_AssignedOnWeekend_RollsToMondayEod()
    {
        // Sunday 11:00 AM IST (05:30 UTC)
        var assignedUtc = new DateTime(2026, 11, 8, 5, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "General",
            attendance: "onsite");

        // Expected: Monday 18:00 IST = Monday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_AssignedWhenOnLeave_RollsToNextWorkingDayEod()
    {
        // Monday 11:00 AM IST (05:30 UTC), but employee attendance is "leave"
        var assignedUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "General",
            attendance: "leave");

        // Expected: Tuesday 18:00 IST = Tuesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 10, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    [Fact]
    public void TaskStart_AssignedOnCompanyHoliday_RollsToNextWorkingDayEod()
    {
        // Monday 11:00 AM IST (05:30 UTC), and Monday is a configured holiday
        var assignedUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);
        var holidays = new HashSet<DateOnly> { new(2026, 11, 9) };

        var deadlineUtc = _calculator.CalculateSameDayEndOfDayUtc(
            assignedUtc,
            shiftName: "General",
            attendance: "onsite",
            holidays: holidays);

        // Expected: Tuesday 18:00 IST = Tuesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 10, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, deadlineUtc);
    }

    #endregion

    #region Activity 4: Task Pause - Resource-Only Daily Reminders & Shift Alignment

    [Fact]
    public void TaskPause_GeneralShift_ReminderAt1800Ist()
    {
        // Resource pauses on Monday at 11:00 AM IST (05:30 UTC)
        var pausedAtUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);

        var reminderUtc = _calculator.CalculateSameDayEndOfDayUtc(
            pausedAtUtc,
            shiftName: "General",
            attendance: "onsite");

        // Reminder at end of General shift: Monday 18:00 IST = Monday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, reminderUtc);
    }

    [Fact]
    public void TaskPause_MorningShift_ReminderAt1400Ist()
    {
        // Resource pauses on Monday at 09:00 AM IST (03:30 UTC)
        var pausedAtUtc = new DateTime(2026, 11, 9, 3, 30, 0, DateTimeKind.Utc);

        var reminderUtc = _calculator.CalculateSameDayEndOfDayUtc(
            pausedAtUtc,
            shiftName: "Morning",
            attendance: "onsite");

        // Reminder at end of Morning shift: Monday 14:00 IST = Monday 08:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 8, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, reminderUtc);
    }

    [Fact]
    public void TaskPause_AfternoonShift_ReminderAt2200Ist()
    {
        // Resource pauses on Monday at 15:00 IST (09:30 UTC)
        var pausedAtUtc = new DateTime(2026, 11, 9, 9, 30, 0, DateTimeKind.Utc);

        var reminderUtc = _calculator.CalculateSameDayEndOfDayUtc(
            pausedAtUtc,
            shiftName: "Afternoon",
            attendance: "onsite");

        // Reminder at end of Afternoon shift: Monday 22:00 IST = Monday 16:30 UTC
        var expectedUtc = new DateTime(2026, 11, 9, 16, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, reminderUtc);
    }

    [Fact]
    public void TaskPause_NightShift_ReminderAt0600NextMorningIst()
    {
        // Resource pauses on Monday at 23:00 IST (17:30 UTC)
        var pausedAtUtc = new DateTime(2026, 11, 9, 17, 30, 0, DateTimeKind.Utc);

        var reminderUtc = _calculator.CalculateSameDayEndOfDayUtc(
            pausedAtUtc,
            shiftName: "Night",
            attendance: "onsite");

        // Reminder at end of Night shift: Tuesday 06:00 IST = Tuesday 00:30 UTC
        var expectedUtc = new DateTime(2026, 11, 10, 0, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, reminderUtc);
    }

    [Fact]
    public void TaskPause_NullOrInvalidShift_DefaultsToGeneral1800Ist()
    {
        // Resource pauses on Monday at 11:00 AM IST with null/invalid shift
        var pausedAtUtc = new DateTime(2026, 11, 9, 5, 30, 0, DateTimeKind.Utc);

        var nullShiftUtc = _calculator.CalculateSameDayEndOfDayUtc(pausedAtUtc, shiftName: null);
        var invalidShiftUtc = _calculator.CalculateSameDayEndOfDayUtc(pausedAtUtc, shiftName: "Unknown_Shift");

        var expectedUtc = new DateTime(2026, 11, 9, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, nullShiftUtc);
        Assert.Equal(expectedUtc, invalidShiftUtc);
    }

    [Fact]
    public void TaskPause_PausedAfterShiftEnd_RollsToNextWorkingDayShiftEnd()
    {
        // Resource pauses on Monday at 19:00 IST (13:30 UTC) -> after 18:00 IST general shift
        var pausedAtUtc = new DateTime(2026, 11, 9, 13, 30, 0, DateTimeKind.Utc);

        var reminderUtc = _calculator.CalculateSameDayEndOfDayUtc(
            pausedAtUtc,
            shiftName: "General",
            attendance: "onsite");

        // Expected: Tuesday 18:00 IST = Tuesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 10, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, reminderUtc);
    }

    #endregion

    #region Dynamic Level 2 Escalation & Deadlines

    [Fact]
    public void DynamicLevel2Escalation_CalculatesFromActualL1ExecutionTimestamp()
    {
        // L1 executed on Tuesday at 18:30 IST (13:00 UTC)
        var actualL1ExecutedUtc = new DateTime(2026, 11, 10, 13, 0, 0, DateTimeKind.Utc);

        var l2DeadlineUtc = _calculator.GetNextWorkingDayEndOfDayUtc(actualL1ExecutedUtc);

        // Next working day EOD: Wednesday 18:00 IST = Wednesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 11, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, l2DeadlineUtc);
    }

    [Fact]
    public void DynamicLevel2Escalation_OverWeekend_CalculatesToMondayEod()
    {
        // L1 executed on Friday at 18:30 IST (13:00 UTC)
        var actualL1ExecutedUtc = new DateTime(2026, 11, 13, 13, 0, 0, DateTimeKind.Utc);

        var l2DeadlineUtc = _calculator.GetNextWorkingDayEndOfDayUtc(actualL1ExecutedUtc);

        // Friday after EOD -> Next working day is Monday EOD: Monday 18:00 IST = Monday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 16, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, l2DeadlineUtc);
    }

    [Fact]
    public void DynamicLevel2Escalation_OverWeekendAndHoliday_CalculatesToTuesdayEod()
    {
        // L1 executed on Friday at 18:30 IST (13:00 UTC)
        var actualL1ExecutedUtc = new DateTime(2026, 11, 13, 13, 0, 0, DateTimeKind.Utc);
        var holidays = new HashSet<DateOnly> { new DateOnly(2026, 11, 16) }; // Monday is holiday

        var l2DeadlineUtc = _calculator.GetNextWorkingDayEndOfDayUtc(actualL1ExecutedUtc, holidays);

        // Next working day EOD: Tuesday 18:00 IST = Tuesday 12:30 UTC
        var expectedUtc = new DateTime(2026, 11, 17, 12, 30, 0, DateTimeKind.Utc);
        Assert.Equal(expectedUtc, l2DeadlineUtc);
    }

    #endregion
}
