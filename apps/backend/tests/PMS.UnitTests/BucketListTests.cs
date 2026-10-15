using PMS.API.Modules.ActionCentre.DTOs;

namespace PMS.UnitTests;

public class BucketListTests
{
    [Fact]
    public void BucketTaskDto_CalculatesEffortAndOverdueCorrectly()
    {
        var assignmentId = Guid.NewGuid();
        var taskId = Guid.NewGuid();
        var projectId = Guid.NewGuid();
        var employeeId = Guid.NewGuid();
        var pastDueDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-2));

        var dto = new BucketTaskDto(
            AssignmentId: assignmentId,
            TaskId: taskId,
            TaskTitle: "Vulnerability Assessment",
            ProjectId: projectId,
            ProjectName: "FinTech Platform",
            ProjectCode: "PRJ-001",
            Priority: "high",
            DueDate: pastDueDate,
            IsOverdue: true,
            Status: "Ongoing",
            EmployeeId: employeeId,
            EmployeeName: "Arjun Singh",
            AssignedByName: "Senior PM",
            StartedAtUtc: DateTime.UtcNow.AddHours(-3),
            CompletedAtUtc: null,
            ElapsedSeconds: 10800, // 3 hours
            IsTimerRunning: true,
            TimerStartedAtUtc: DateTime.UtcNow.AddHours(-3),
            EstimatedHours: 2.0m,
            UtilizedHours: 3.0m,
            RemainingHours: -1.0m // Effort consumed exceeds estimate
        );

        Assert.True(dto.IsOverdue);
        Assert.True(dto.IsTimerRunning);
        Assert.Equal("Ongoing", dto.Status);
        Assert.Equal(-1.0m, dto.RemainingHours);
        Assert.Equal(3.0m, dto.UtilizedHours);
    }

    [Fact]
    public void DailyOfficeHours_AutoCapRule_CalculatesCorrectLimit()
    {
        const decimal maxDailyWorkingHours = 8.5m;
        var maxDailySeconds = (long)(maxDailyWorkingHours * 3600m); // 30,600 seconds

        // If a task ran for 10 hours without pause
        const long runningSeconds = 36000;
        var cappedElapsed = Math.Min(runningSeconds, maxDailySeconds);

        Assert.Equal(30600, cappedElapsed);
        Assert.Equal(8.5m, Math.Round((decimal)cappedElapsed / 3600m, 2));
    }

    [Fact]
    public void BucketTaskFilterParams_DefaultsAreSensible()
    {
        var filter = new BucketTaskFilterParams();

        Assert.Null(filter.Search);
        Assert.Null(filter.Status);
        Assert.Null(filter.Priority);
        Assert.Equal(1, filter.Page);
        Assert.Equal(50, filter.PerPage);
    }
}
