using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Timesheets.DTOs;
using PMS.API.Modules.Timesheets.Models;
using PMS.API.Modules.Timesheets.Services;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class TimesheetNotificationIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public TimesheetNotificationIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    private static DateOnly GetPreviousMonday()
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow.AddHours(5.5));
        var daysSinceMonday = ((int)today.DayOfWeek - (int)DayOfWeek.Monday + 7) % 7;
        return today.AddDays(-daysSinceMonday - 7);
    }

    private static async Task<string> GenerateUniqueEmployeeCodeAsync(AppDbContext db)
    {
        var existingCodes = await db.Employees.Select(e => e.EmployeeCode).ToHashSetAsync();
        string code;
        do
        {
            code = $"TK-{Random.Shared.Next(1000, 9999):D4}";
        } while (existingCodes.Contains(code));
        return code;
    }

    [Fact]
    public async Task SubmitTimesheet_DispatchesNotification_ToReportingManager_WithCorrectFields()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITimesheetNotificationService>();

        // 1. Create a manager and employee
        var manager = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Alice",
            LastName = "Manager",
            WorkEmail = $"mgr.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active"
        };
        db.Employees.Add(manager);
        await db.SaveChangesAsync();

        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Bob",
            LastName = "Developer",
            WorkEmail = $"dev.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active",
            ReportingManagerId = manager.Id
        };
        db.Employees.Add(employee);
        await db.SaveChangesAsync();

        // 2. Create timesheet week with project entries
        var weekStart = GetPreviousMonday();
        var week = new TimesheetWeek
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            WeekStart = weekStart,
            Status = "submitted",
            TotalHours = 40,
            Entries = new List<TimesheetEntry>
            {
                new()
                {
                    Id = Guid.NewGuid(),
                    ProjectKey = "PROJ-ALPHA",
                    ProjectName = "Project Alpha",
                    TaskKey = "TASK-1",
                    TaskName = "Backend Development"
                }
            }
        };
        db.TimesheetWeeks.Add(week);
        await db.SaveChangesAsync();

        // 3. Dispatch submission notification
        await notifService.NotifyTimesheetSubmittedAsync(week, employee);

        // 4. Assert reporting manager received the notification
        var weekEnd = weekStart.AddDays(4);
        var expectedRange = $"{weekStart:dd-MM-yyyy} – {weekEnd:dd-MM-yyyy}";

        var notif = await db.ActionNotifications
            .FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == manager.Id &&
                n.Title == "Timesheet Submitted" &&
                n.RelatedTask == expectedRange);

        Assert.NotNull(notif);
        Assert.Equal("Pending", notif.Status);
        Assert.Equal("Low", notif.Priority);
        Assert.True(notif.Unread);
        Assert.Equal("Bob Developer", notif.RaisedByName);
        Assert.Equal(employee.Id, notif.RaisedByEmployeeId);
        Assert.Equal("Project Alpha", notif.ProjectName);
        Assert.Contains("Bob Developer has submitted their timesheet for approval.", notif.HistoryJson);
    }

    [Fact]
    public async Task SubmitTimesheet_WithMultipleProjects_SetsCommaSeparatedProjectName()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITimesheetNotificationService>();

        var manager = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Carol",
            LastName = "Director",
            WorkEmail = $"dir.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active"
        };
        db.Employees.Add(manager);
        await db.SaveChangesAsync();

        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Dave",
            LastName = "Engineer",
            WorkEmail = $"eng.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active",
            ReportingManagerId = manager.Id
        };
        db.Employees.Add(employee);
        await db.SaveChangesAsync();

        var weekStart = GetPreviousMonday();
        var week = new TimesheetWeek
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            WeekStart = weekStart,
            Status = "submitted",
            TotalHours = 40,
            Entries = new List<TimesheetEntry>
            {
                new() { Id = Guid.NewGuid(), ProjectKey = "P1", ProjectName = "Project Alpha", TaskKey = "T1", TaskName = "Task 1" },
                new() { Id = Guid.NewGuid(), ProjectKey = "P2", ProjectName = "Project Beta", TaskKey = "T2", TaskName = "Task 2" }
            }
        };
        db.TimesheetWeeks.Add(week);
        await db.SaveChangesAsync();

        await notifService.NotifyTimesheetSubmittedAsync(week, employee);

        var weekEnd = weekStart.AddDays(4);
        var expectedRange = $"{weekStart:dd-MM-yyyy} – {weekEnd:dd-MM-yyyy}";

        var notif = await db.ActionNotifications
            .FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == manager.Id &&
                n.Title == "Timesheet Submitted" &&
                n.RelatedTask == expectedRange);

        Assert.NotNull(notif);
        Assert.Equal("Project Alpha, Project Beta", notif.ProjectName);
    }

    [Fact]
    public async Task SubmitTimesheet_WithNoReportingManager_LogsWarningAndDoesNotFail()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITimesheetNotificationService>();

        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Solo",
            LastName = "Worker",
            WorkEmail = $"solo.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active",
            ReportingManagerId = null // No manager
        };
        db.Employees.Add(employee);
        await db.SaveChangesAsync();

        var week = new TimesheetWeek
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            WeekStart = GetPreviousMonday(),
            Status = "submitted",
            TotalHours = 40
        };
        db.TimesheetWeeks.Add(week);
        await db.SaveChangesAsync();

        // Must succeed without throwing
        var ex = await Record.ExceptionAsync(() => notifService.NotifyTimesheetSubmittedAsync(week, employee));
        Assert.Null(ex);
    }

    [Fact]
    public async Task DecideTimesheet_Approved_DispatchesNotification_AndSynchronizesManagerNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITimesheetNotificationService>();

        var manager = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Eve",
            LastName = "Manager",
            WorkEmail = $"eve.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active"
        };
        db.Employees.Add(manager);
        await db.SaveChangesAsync();

        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Frank",
            LastName = "Dev",
            WorkEmail = $"frank.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active",
            ReportingManagerId = manager.Id
        };
        db.Employees.Add(employee);
        await db.SaveChangesAsync();

        var weekStart = GetPreviousMonday();
        var week = new TimesheetWeek
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            WeekStart = weekStart,
            Status = "submitted",
            Entries = new List<TimesheetEntry>
            {
                new() { Id = Guid.NewGuid(), ProjectName = "Cloud Migration", TaskName = "Infra" }
            }
        };
        db.TimesheetWeeks.Add(week);
        await db.SaveChangesAsync();

        // Create manager submission notification first
        await notifService.NotifyTimesheetSubmittedAsync(week, employee);

        // Manager decides: Approved
        await notifService.NotifyTimesheetDecidedAsync(week, manager, "approved", "Well done!");

        // 1. Assert Resource received Approved notification
        var resourceNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == employee.Id &&
                n.Title == "Timesheet Approved");

        Assert.NotNull(resourceNotif);
        Assert.Equal("Approved", resourceNotif.Status);
        Assert.Equal("Low", resourceNotif.Priority);
        Assert.Equal("Eve Manager", resourceNotif.RaisedByName);
        Assert.Contains("Your timesheet has been approved by Eve Manager.", resourceNotif.HistoryJson);

        // 2. Assert Manager's prior submission notification is synchronized to Approved
        var weekEnd = weekStart.AddDays(4);
        var expectedRange = $"{weekStart:dd-MM-yyyy} – {weekEnd:dd-MM-yyyy}";
        var managerNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == manager.Id &&
                n.Title == "Timesheet Submitted" &&
                n.RelatedTask == expectedRange);

        Assert.NotNull(managerNotif);
        Assert.Equal("Approved", managerNotif.Status);
        Assert.False(managerNotif.Unread);
    }

    [Fact]
    public async Task DecideTimesheet_Rejected_DispatchesNotification_WithRemarks_ToResource()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITimesheetNotificationService>();

        var manager = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Grace",
            LastName = "Lead",
            WorkEmail = $"grace.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active"
        };
        db.Employees.Add(manager);
        await db.SaveChangesAsync();

        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Hank",
            LastName = "Tester",
            WorkEmail = $"hank.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active",
            ReportingManagerId = manager.Id
        };
        db.Employees.Add(employee);
        await db.SaveChangesAsync();

        var weekStart = GetPreviousMonday();
        var week = new TimesheetWeek
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            WeekStart = weekStart,
            Status = "submitted"
        };
        db.TimesheetWeeks.Add(week);
        await db.SaveChangesAsync();

        const string remark = "Hours exceed 40 without prior approval.";
        await notifService.NotifyTimesheetDecidedAsync(week, manager, "rejected", remark);

        var resourceNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == employee.Id &&
                n.Title == "Timesheet Rejected");

        Assert.NotNull(resourceNotif);
        Assert.Equal("Rejected", resourceNotif.Status);
        Assert.Equal("Low", resourceNotif.Priority);
        Assert.Contains("Your timesheet has been rejected by Grace Lead. Please review and resubmit it before the submission deadline.", resourceNotif.HistoryJson);
        Assert.Contains(remark, resourceNotif.HistoryJson);
        Assert.Contains(remark, resourceNotif.CommentsJson);
    }

    [Fact]
    public async Task DecideTimesheet_ChangesRequested_DispatchesNotification_WithRemarks_ToResource()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITimesheetNotificationService>();

        var manager = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Ian",
            LastName = "Manager",
            WorkEmail = $"ian.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active"
        };
        db.Employees.Add(manager);
        await db.SaveChangesAsync();

        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Julia",
            LastName = "Designer",
            WorkEmail = $"julia.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active",
            ReportingManagerId = manager.Id
        };
        db.Employees.Add(employee);
        await db.SaveChangesAsync();

        var weekStart = GetPreviousMonday();
        var week = new TimesheetWeek
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            WeekStart = weekStart,
            Status = "submitted"
        };
        db.TimesheetWeeks.Add(week);
        await db.SaveChangesAsync();

        const string remark = "Please adjust Wednesday task description.";
        await notifService.NotifyTimesheetDecidedAsync(week, manager, "change_requested", remark);

        var resourceNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == employee.Id &&
                n.Title == "Timesheet Changes Requested");

        Assert.NotNull(resourceNotif);
        Assert.Equal("Request Change", resourceNotif.Status);
        Assert.Equal("Low", resourceNotif.Priority);
        Assert.Contains("Your timesheet has been sent back for changes by Ian Manager. Please review and update it before the submission deadline.", resourceNotif.HistoryJson);
        Assert.Contains(remark, resourceNotif.HistoryJson);
        Assert.Contains(remark, resourceNotif.CommentsJson);
    }

    [Fact]
    public async Task TimesheetReminders_EnforcesSubmissionWindow_AndAlternateDayCadence()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITimesheetNotificationService>();

        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = "Kevin",
            LastName = "RemindMe",
            WorkEmail = $"kevin.{Guid.NewGuid():N}@talakunchi.com",
            Status = "Active",
            ProjectAllocated = "Project Gamma"
        };
        db.Employees.Add(employee);
        await db.SaveChangesAsync();

        // 1. Outside submission window: Wednesday (e.g. 2026-11-18)
        var wednesday = new DateOnly(2026, 11, 18);
        Assert.Equal(DayOfWeek.Wednesday, wednesday.DayOfWeek);
        var wednesdayCount = await notifService.ProcessTimesheetRemindersAsync(wednesday);
        Assert.Equal(0, wednesdayCount);

        // 2. Window open: Friday (e.g. 2026-11-20)
        var friday = new DateOnly(2026, 11, 20);
        Assert.Equal(DayOfWeek.Friday, friday.DayOfWeek);
        var fridayCount = await notifService.ProcessTimesheetRemindersAsync(friday);
        Assert.True(fridayCount >= 1);

        var reminderFri = await db.ActionNotifications
            .FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == employee.Id &&
                n.Title == "Timesheet Submission Reminder");

        Assert.NotNull(reminderFri);
        Assert.Equal("Pending", reminderFri.Status);
        Assert.Equal("Low", reminderFri.Priority);
        Assert.Equal("System", reminderFri.RaisedByName);
        Assert.Equal("Project Gamma", reminderFri.ProjectName);
        Assert.Contains("pending submission. Please submit it before the Monday deadline.", reminderFri.HistoryJson);

        // 3. Saturday (2026-11-21): 1 day since Friday -> Must be skipped due to alternate-day rule
        var saturday = new DateOnly(2026, 11, 21);
        Assert.Equal(DayOfWeek.Saturday, saturday.DayOfWeek);
        var saturdayCount = await notifService.ProcessTimesheetRemindersAsync(saturday);

        var reminderCountForKevinOnSat = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == employee.Id && n.Title == "Timesheet Submission Reminder");
        // Still 1 (no new reminder on Saturday)
        Assert.Equal(1, reminderCountForKevinOnSat);

        // 4. Sunday (2026-11-22): 2 days since Friday -> Alternate-day reminder sent!
        var sunday = new DateOnly(2026, 11, 22);
        Assert.Equal(DayOfWeek.Sunday, sunday.DayOfWeek);
        var sundayCount = await notifService.ProcessTimesheetRemindersAsync(sunday);

        var reminderCountForKevinOnSun = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == employee.Id && n.Title == "Timesheet Submission Reminder");
        Assert.Equal(2, reminderCountForKevinOnSun);

        // 5. When employee submits timesheet, pending reminders are stopped
        var targetWeekStart = friday.AddDays(-4); // Monday of that week
        var week = new TimesheetWeek
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            WeekStart = targetWeekStart,
            Status = "submitted"
        };
        db.TimesheetWeeks.Add(week);
        await db.SaveChangesAsync();

        await notifService.NotifyTimesheetSubmittedAsync(week, employee);

        // Verify all pending reminders for Kevin are marked "Submitted"
        var reminders = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == employee.Id && n.Title == "Timesheet Submission Reminder")
            .ToListAsync();

        Assert.All(reminders, r => Assert.Equal("Submitted", r.Status));
        Assert.All(reminders, r => Assert.False(r.Unread));
    }

    [Fact]
    public async Task ProcessReminders_ViaApiEndpoint_ReturnsSuccess()
    {
        var response = await _client.PostAsync("/api/v1/timesheets/reminders/process?overrideToday=2026-11-18", null);
        response.EnsureSuccessStatusCode();

        var body = await response.Content.ReadFromJsonAsync<ApiResponse<int>>();
        Assert.NotNull(body);
        Assert.Null(body.Errors);
        Assert.Equal(0, body.Data); // Wednesday = 0
    }
}
