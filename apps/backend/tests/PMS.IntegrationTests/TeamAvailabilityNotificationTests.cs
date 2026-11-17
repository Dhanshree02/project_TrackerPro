using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.MyTeam.Models;
using PMS.API.Modules.MyTeam.Services;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class TeamAvailabilityNotificationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public TeamAvailabilityNotificationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(b =>
            b.UseSetting("Database:AutoMigrate", "false"));
        _client = _factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
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

    private static async Task<Employee> CreateEmployeeAsync(
        AppDbContext db,
        string firstName,
        string lastName,
        string role = "Employee",
        Guid? reportingManagerId = null)
    {
        var emp = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = firstName,
            LastName = lastName,
            WorkEmail = $"{firstName.ToLower()}.{lastName.ToLower()}.{Guid.NewGuid():N}@talakunchi.com",
            Role = role,
            Status = "Active",
            ReportingManagerId = reportingManagerId,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Employees.Add(emp);
        await db.SaveChangesAsync();
        return emp;
    }

    private static async Task<Project> CreateProjectAsync(AppDbContext db, string projectName, Guid? pmId = null)
    {
        var client = await db.Clients.FirstOrDefaultAsync(c => c.DeletedAtUtc == null);
        Guid clientId;
        if (client != null)
        {
            clientId = client.Id;
        }
        else
        {
            var newClient = new Client
            {
                Id = Guid.NewGuid(),
                Name = "Team Test Client " + Guid.NewGuid().ToString("N")[..6],
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            };
            db.Clients.Add(newClient);
            await db.SaveChangesAsync();
            clientId = newClient.Id;
        }

        var prj = new Project
        {
            Id = Guid.NewGuid(),
            ClientId = clientId,
            Name = projectName,
            ProjectCode = $"PRJ-{Random.Shared.Next(1000, 9999)}",
            ProjectManagerId = pmId,
            StartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(-1)),
            EndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(5)),
            Status = "In Progress",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Projects.Add(prj);
        await db.SaveChangesAsync();
        return prj;
    }

    private static async Task<ProjectTeamMember> AllocateMemberAsync(
        AppDbContext db,
        Guid projectId,
        Guid employeeId,
        string memberRole,
        DateOnly start,
        DateOnly end,
        bool isTeamLead = false)
    {
        var tm = new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = projectId,
            EmployeeId = employeeId,
            MemberRole = memberRole,
            IsTeamLead = isTeamLead,
            AllocationStartDate = start,
            AllocationEndDate = end,
            Billability = "Billable",
            ResourceType = "Dedicated",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.ProjectTeamMembers.Add(tm);
        await db.SaveChangesAsync();
        return tm;
    }

    [Fact]
    public async Task Tier1_ReportingManagerTwoHourReminders_DispatchesNotificationWithProjectAndTitles_WhenReporteeIsPending()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITeamAvailabilityNotificationService>();

        var testDate = new DateOnly(2026, 11, 18); // A Wednesday
        var rm = await CreateEmployeeAsync(db, "ManagerTier1", "Alpha", "Manager");
        var reportee = await CreateEmployeeAsync(db, "DevTier1", "Beta", "Developer", rm.Id);

        var project = await CreateProjectAsync(db, "Project Availability Tier1 " + Guid.NewGuid().ToString("N")[..6]);
        await AllocateMemberAsync(db, project.Id, reportee.Id, "Developer", testDate.AddDays(-5), testDate.AddDays(5));

        // Act: Run 2-hour reminder
        var dispatchedCount = await notifService.SendReportingManagerTwoHourRemindersAsync(testDate);
        Assert.True(dispatchedCount > 0);

        // Assert: Notification received by RM
        var notifs = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == rm.Id && n.Type == "Team Availability Reminder")
            .OrderByDescending(n => n.CreatedAtUtc)
            .ToListAsync();

        var notif = Assert.Single(notifs, n => n.ProjectId == project.Id);
        Assert.Equal("Team Availability Reminder", notif.Type);
        Assert.Equal(project.Id, notif.ProjectId);
        Assert.Equal(project.ProjectCode, notif.ProjectCode);
        Assert.Equal(project.Name, notif.ProjectName);
        Assert.Contains("Pending Team Availability & Shift Coverage", notif.Title);
        Assert.Contains("DevTier1 Beta", notif.CommentsJson);
        Assert.Equal("Medium", notif.Priority);
        Assert.Equal("Pending", notif.Status);

        // Now resolve reportee's availability
        var dayEntry = new TeamDayEntry
        {
            Id = Guid.NewGuid(),
            EmployeeId = reportee.Id,
            WorkDate = testDate,
            Attendance = "onsite",
            Shift = "General",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.TeamDayEntries.Add(dayEntry);
        await db.SaveChangesAsync();

        // Second run: reportee is no longer pending, so no new reminder for this reportee/project
        var notifsBeforeCount = await db.ActionNotifications.CountAsync(n => n.RecipientEmployeeId == rm.Id && n.ProjectId == project.Id);
        await notifService.SendReportingManagerTwoHourRemindersAsync(testDate);
        var notifsAfterCount = await db.ActionNotifications.CountAsync(n => n.RecipientEmployeeId == rm.Id && n.ProjectId == project.Id);
        Assert.Equal(notifsBeforeCount, notifsAfterCount);
    }

    [Fact]
    public async Task Tier2_ProjectLeadershipDailyAlert_DispatchesToLeadership_AndUpdatesStatusWhenResolved()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITeamAvailabilityNotificationService>();

        var testDate = new DateOnly(2026, 11, 19); // A Thursday
        var pm = await CreateEmployeeAsync(db, "LeadPM", "One", "Project Manager");
        var em = await CreateEmployeeAsync(db, "LeadEM", "Two", "Engagement Manager");
        var tl = await CreateEmployeeAsync(db, "LeadTL", "Three", "Team Leader");

        var rm = await CreateEmployeeAsync(db, "LeadRM", "Four", "Manager");
        var dev = await CreateEmployeeAsync(db, "LeadDev", "Five", "Developer", rm.Id);

        var project = await CreateProjectAsync(db, "Project Leadership Tier2 " + Guid.NewGuid().ToString("N")[..6], pm.Id);
        await AllocateMemberAsync(db, project.Id, pm.Id, "ProjectManager", testDate.AddDays(-5), testDate.AddDays(5));
        await AllocateMemberAsync(db, project.Id, em.Id, "EngagementManager", testDate.AddDays(-5), testDate.AddDays(5));
        await AllocateMemberAsync(db, project.Id, tl.Id, "Developer", testDate.AddDays(-5), testDate.AddDays(5), isTeamLead: true);
        await AllocateMemberAsync(db, project.Id, dev.Id, "Developer", testDate.AddDays(-5), testDate.AddDays(5));

        // Act 1: 11 AM Alert while Dev is pending
        var count11Am = await notifService.SendProjectLeadershipDailyAlertAsync(11, testDate);
        Assert.True(count11Am > 0);

        var pmNotif11 = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == pm.Id && n.ProjectId == project.Id && n.Title.Contains("11:00 AM"));
        Assert.NotNull(pmNotif11);
        Assert.Equal("Project Shift & Availability Alert", pmNotif11.Type);
        Assert.Equal("Pending", pmNotif11.Status);
        Assert.Equal(project.Name, pmNotif11.ProjectName);
        Assert.Contains("Pending Resource Availability & Shift Coverage", pmNotif11.Title);

        var emNotif11 = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == em.Id && n.ProjectId == project.Id && n.Title.Contains("11:00 AM"));
        Assert.NotNull(emNotif11);

        var tlNotif11 = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == tl.Id && n.ProjectId == project.Id && n.Title.Contains("11:00 AM"));
        Assert.NotNull(tlNotif11);

        // Act 2: 12 PM Alert
        var count12Pm = await notifService.SendProjectLeadershipDailyAlertAsync(12, testDate);
        Assert.True(count12Pm > 0);

        var pmNotif12 = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == pm.Id && n.ProjectId == project.Id && n.Title.Contains("12:00 PM"));
        Assert.NotNull(pmNotif12);

        // Act 3: Resolve all members and test status alert
        var allocatedEmpIds = new[] { pm.Id, em.Id, tl.Id, dev.Id };
        foreach (var empId in allocatedEmpIds)
        {
            db.TeamDayEntries.Add(new TeamDayEntry
            {
                Id = Guid.NewGuid(),
                EmployeeId = empId,
                WorkDate = testDate,
                Attendance = "wfh",
                Shift = "Morning",
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            });
        }
        await db.SaveChangesAsync();

        var countResolved = await notifService.SendProjectLeadershipDailyAlertAsync(12, testDate);
        Assert.True(countResolved > 0);

        var completedNotif = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == pm.Id && n.ProjectId == project.Id && n.Status == "Completed")
            .OrderByDescending(n => n.CreatedAtUtc)
            .FirstOrDefaultAsync();

        Assert.NotNull(completedNotif);
        Assert.Equal("Project Shift & Availability Status", completedNotif.Type);
        Assert.Contains("Project Team Availability Updated", completedNotif.Title);
    }

    [Fact]
    public async Task Tier3_SpmDailyAlert_DispatchesToSpm_WhenResourcesPending()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITeamAvailabilityNotificationService>();

        var testDate = new DateOnly(2026, 11, 20); // A Friday
        var spm = await CreateEmployeeAsync(db, "SpmTier3", "Senior", "Senior Project Manager");
        var rm = await CreateEmployeeAsync(db, "RMTier3", "Regular", "Manager");
        var dev = await CreateEmployeeAsync(db, "DevTier3", "Cody", "Developer", rm.Id);

        var project = await CreateProjectAsync(db, "Project SPM Tier3 " + Guid.NewGuid().ToString("N")[..6]);
        await AllocateMemberAsync(db, project.Id, spm.Id, "SeniorProjectManager", testDate.AddDays(-5), testDate.AddDays(5));
        await AllocateMemberAsync(db, project.Id, dev.Id, "Developer", testDate.AddDays(-5), testDate.AddDays(5));

        // Act: 1 PM SPM Alert
        var dispatched = await notifService.SendSpmDailyAlertAsync(testDate);
        Assert.True(dispatched > 0);

        // Assert: SPM notification
        var spmNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == spm.Id && n.ProjectId == project.Id && n.Type == "SPM Shift & Availability Escalation");

        Assert.NotNull(spmNotif);
        Assert.Equal("High", spmNotif.Priority);
        Assert.Equal("Pending", spmNotif.Status);
        Assert.Equal(project.Name, spmNotif.ProjectName);
        Assert.Equal(project.ProjectCode, spmNotif.ProjectCode);
        Assert.Contains("Escalation: Pending Resource Availability & Shift Coverage", spmNotif.Title);
        Assert.Contains("1:00 PM", spmNotif.Title);
    }

    [Fact]
    public async Task Tier4_HodNextDayEodEscalation_DispatchesToHod_ForUnresolvedPriorDay()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<ITeamAvailabilityNotificationService>();

        var evalDate = new DateOnly(2026, 11, 16); // A Monday
        var hod = await CreateEmployeeAsync(db, "HodTier4", "Chief", "Head of Department");
        var rm = await CreateEmployeeAsync(db, "RMTier4", "Manager", "Manager");
        var dev = await CreateEmployeeAsync(db, "DevTier4", "PendingGuy", "Developer", rm.Id);

        var project = await CreateProjectAsync(db, "Project HOD Tier4 " + Guid.NewGuid().ToString("N")[..6]);
        await AllocateMemberAsync(db, project.Id, dev.Id, "Developer", evalDate.AddDays(-5), evalDate.AddDays(5));

        // Act: HOD EOD Escalation for unresolved prior-day records
        var count = await notifService.SendHodNextDayEodEscalationAsync(evalDate);
        Assert.True(count > 0);

        // Assert: HOD receives escalation notification
        var hodNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == hod.Id && n.ProjectId == project.Id && n.Type == "HOD Shift & Availability Escalation");

        Assert.NotNull(hodNotif);
        Assert.Equal("High", hodNotif.Priority);
        Assert.Equal("Escalated", hodNotif.Status);
        Assert.Contains("HOD Escalation: Reporting Manager Failed to Update Shift & Availability", hodNotif.Title);
        Assert.Equal(project.Name, hodNotif.ProjectName);
    }

    [Fact]
    public async Task MyTeamController_TriggerEndpoints_ReturnSuccess()
    {
        var testDate = new DateOnly(2026, 11, 23);

        // 1. 2-Hour Reminders Endpoint
        var res1 = await _client.PostAsync($"/api/v1/my-team/notifications/trigger-2hour-reminders?date={testDate:yyyy-MM-dd}", null);
        Assert.Equal(HttpStatusCode.OK, res1.StatusCode);
        var envelope1 = await res1.Content.ReadFromJsonAsync<ApiResponse<int>>();
        Assert.NotNull(envelope1);
        Assert.Null(envelope1.Errors);
        Assert.True(envelope1.Data >= 0);

        // 2. Leadership Alerts Endpoint (11 AM)
        var res2 = await _client.PostAsync($"/api/v1/my-team/notifications/trigger-leadership-alerts?hour=11&date={testDate:yyyy-MM-dd}", null);
        Assert.Equal(HttpStatusCode.OK, res2.StatusCode);
        var envelope2 = await res2.Content.ReadFromJsonAsync<ApiResponse<int>>();
        Assert.NotNull(envelope2);
        Assert.Null(envelope2.Errors);
        Assert.True(envelope2.Data >= 0);

        // 3. SPM Alerts Endpoint
        var res3 = await _client.PostAsync($"/api/v1/my-team/notifications/trigger-spm-alerts?date={testDate:yyyy-MM-dd}", null);
        Assert.Equal(HttpStatusCode.OK, res3.StatusCode);
        var envelope3 = await res3.Content.ReadFromJsonAsync<ApiResponse<int>>();
        Assert.NotNull(envelope3);
        Assert.Null(envelope3.Errors);
        Assert.True(envelope3.Data >= 0);

        // 4. HOD Escalations Endpoint
        var res4 = await _client.PostAsync($"/api/v1/my-team/notifications/trigger-hod-escalations?date={testDate:yyyy-MM-dd}", null);
        Assert.Equal(HttpStatusCode.OK, res4.StatusCode);
        var envelope4 = await res4.Content.ReadFromJsonAsync<ApiResponse<int>>();
        Assert.NotNull(envelope4);
        Assert.Null(envelope4.Errors);
        Assert.True(envelope4.Data >= 0);
    }
}
