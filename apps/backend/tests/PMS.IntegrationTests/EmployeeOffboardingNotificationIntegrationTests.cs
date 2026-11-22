using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Resources.Services;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class EmployeeOffboardingNotificationIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public EmployeeOffboardingNotificationIntegrationTests(WebApplicationFactory<Program> factory)
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

    private static async Task<Employee> CreateTestEmployeeAsync(
        AppDbContext db,
        string firstName,
        string lastName,
        string role = "Software Engineer",
        string status = "Active",
        Guid? departmentId = null)
    {
        var emp = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = firstName,
            LastName = lastName,
            WorkEmail = $"{firstName.ToLower()}.{lastName.ToLower()}.{Guid.NewGuid():N}@talakunchi.com",
            Role = role,
            Status = status,
            DepartmentId = departmentId,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Employees.Add(emp);
        await db.SaveChangesAsync();
        return emp;
    }

    private static async Task<Project> CreateTestProjectAsync(AppDbContext db, string projectName, Guid? engagementManagerId = null)
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
                Name = "Client-" + Guid.NewGuid().ToString("N")[..8],
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
            EngagementManagerId = engagementManagerId,
            Name = projectName,
            ProjectCode = $"OB-PRJ-{Random.Shared.Next(1000, 9999)}",
            StartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            EndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(6)),
            Status = "In Progress",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Projects.Add(prj);
        await db.SaveChangesAsync();
        return prj;
    }

    [Fact]
    public async Task ImmediateResignationNotification_OffboardEmployee_DispatchesNotificationToEngagementManager()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        var em = await CreateTestEmployeeAsync(db, "Emma", "Manager", role: "Engagement Manager");
        var emp = await CreateTestEmployeeAsync(db, "John", "Doe");
        var project = await CreateTestProjectAsync(db, "Project Phoenix", em.Id);

        // Assign resource to project
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        // Add ExitedEmployee record
        var resDate = new DateOnly(2026, 11, 15);
        var lwd = new DateOnly(2026, 11, 30);
        db.ExitedEmployees.Add(new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            ResignationDate = resDate,
            LastWorkingDay = lwd,
            StatusAtExit = "Notice Period",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        // 1. Send immediate resignation notification
        var count = await notifService.SendImmediateResignationNotificationAsync(emp.Id, "HR Lead");
        Assert.True(count >= 1);

        // 2. Verify ActionNotification properties
        var expectedTitle = $"{emp.FirstName} {emp.LastName} Resignation Applied";
        var notif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == em.Id &&
                                      n.ProjectId == project.Id &&
                                      n.Title == expectedTitle);

        Assert.NotNull(notif);
        Assert.Equal("Resignation Applied", notif.Type);
        Assert.Equal("Pending", notif.Status);
        Assert.Equal("Low", notif.Priority);
        Assert.True(notif.Unread);
        Assert.Equal(project.Name, notif.ProjectName);
        Assert.Equal("HR Lead", notif.RaisedByName);
        Assert.Contains("Resignation Applied", notif.HistoryJson);

        // 3. Idempotency test: calling again must not send duplicate
        var duplicateCount = await notifService.SendImmediateResignationNotificationAsync(emp.Id, "HR Lead");
        Assert.Equal(0, duplicateCount);
    }

    [Fact]
    public async Task ImmediateResignationNotification_MultiProjectResource_DispatchesNotificationToRespectiveEMs()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        var em1 = await CreateTestEmployeeAsync(db, "EM", "Alpha", role: "Engagement Manager");
        var em2 = await CreateTestEmployeeAsync(db, "EM", "Beta", role: "Engagement Manager");
        var emp = await CreateTestEmployeeAsync(db, "Multi", "Resource");

        var proj1 = await CreateTestProjectAsync(db, "MultiProj 1", em1.Id);
        var proj2 = await CreateTestProjectAsync(db, "MultiProj 2", em2.Id);

        db.ProjectTeamMembers.AddRange(
            new ProjectTeamMember
            {
                Id = Guid.NewGuid(),
                ProjectId = proj1.Id,
                EmployeeId = emp.Id,
                MemberRole = ProjectMemberRoles.ProjectTeam,
                AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
                AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            },
            new ProjectTeamMember
            {
                Id = Guid.NewGuid(),
                ProjectId = proj2.Id,
                EmployeeId = emp.Id,
                MemberRole = ProjectMemberRoles.ProjectTeam,
                AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
                AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            }
        );

        db.ExitedEmployees.Add(new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            ResignationDate = new DateOnly(2026, 11, 15),
            LastWorkingDay = new DateOnly(2026, 11, 30),
            StatusAtExit = "Notice Period",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        var count = await notifService.SendImmediateResignationNotificationAsync(emp.Id, "Lead PM");
        Assert.Equal(2, count);

        // Verify EM1 got proj1 notification
        var notif1 = await db.ActionNotifications.FirstOrDefaultAsync(n => n.RecipientEmployeeId == em1.Id && n.ProjectId == proj1.Id);
        Assert.NotNull(notif1);
        Assert.Equal($"{emp.FirstName} {emp.LastName} Resignation Applied", notif1.Title);
        Assert.Equal(proj1.Name, notif1.ProjectName);

        // Verify EM2 got proj2 notification
        var notif2 = await db.ActionNotifications.FirstOrDefaultAsync(n => n.RecipientEmployeeId == em2.Id && n.ProjectId == proj2.Id);
        Assert.NotNull(notif2);
        Assert.Equal($"{emp.FirstName} {emp.LastName} Resignation Applied", notif2.Title);
        Assert.Equal(proj2.Name, notif2.ProjectName);
    }

    [Fact]
    public async Task ProcessLwdReminders_EveryTwoDays_GeneratesReminderNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        var em = await CreateTestEmployeeAsync(db, "LwdEM", "Boss", role: "Engagement Manager");
        var emp = await CreateTestEmployeeAsync(db, "Karan", "Patel", status: "Notice Period");
        var project = await CreateTestProjectAsync(db, "LWD Project", em.Id);

        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        var resDate = new DateOnly(2026, 11, 10);
        var lwdDate = new DateOnly(2026, 11, 20);

        db.ExitedEmployees.Add(new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            ResignationDate = resDate,
            LastWorkingDay = lwdDate,
            StatusAtExit = "Notice Period",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        // 1. Day 2 after resignation: 2026-11-12 (diff = 2) -> Should dispatch
        var day2 = new DateOnly(2026, 11, 12);
        var day2Count = await notifService.ProcessLwdRemindersAsync(day2);
        Assert.True(day2Count >= 1);

        var expectedTitle = $"{emp.FirstName} {emp.LastName} Last Working date is 20 November 2026";
        var reminderNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == em.Id &&
                                      n.ProjectId == project.Id &&
                                      n.Title == expectedTitle);
        Assert.NotNull(reminderNotif);
        Assert.Equal("LWD Reminder", reminderNotif.Type);
        Assert.Equal("Pending", reminderNotif.Status);
        Assert.Equal("Low", reminderNotif.Priority);
        Assert.True(reminderNotif.Unread);
        Assert.Equal("System / Automation Engine", reminderNotif.RaisedByName);
        Assert.Contains("20 November 2026", reminderNotif.CommentsJson);

        // 2. Day 3 after resignation: 2026-11-13 (diff = 3) -> Should NOT dispatch (not alternate day)
        var day3 = new DateOnly(2026, 11, 13);
        var day3Count = await notifService.ProcessLwdRemindersAsync(day3);
        var day3Notif = await db.ActionNotifications
            .AnyAsync(n => n.RecipientEmployeeId == em.Id &&
                           n.ProjectId == project.Id &&
                           n.HistoryJson.Contains("2026-11-13"));
        Assert.False(day3Notif);

        // 3. Day 4 after resignation: 2026-11-14 (diff = 4) -> Should dispatch
        var day4 = new DateOnly(2026, 11, 14);
        var day4Count = await notifService.ProcessLwdRemindersAsync(day4);
        Assert.True(day4Count >= 1);

        var day4Notif = await db.ActionNotifications
            .AnyAsync(n => n.RecipientEmployeeId == em.Id &&
                           n.ProjectId == project.Id &&
                           n.HistoryJson.Contains("2026-11-14"));
        Assert.True(day4Notif);
    }

    [Fact]
    public async Task ProcessLwdReminders_Idempotent_DoesNotCreateDuplicatesOnSameDay()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        var em = await CreateTestEmployeeAsync(db, "IdemEM", "Lead", role: "Engagement Manager");
        var emp = await CreateTestEmployeeAsync(db, "Idem", "Resource", status: "Notice Period");
        var project = await CreateTestProjectAsync(db, "Idem LWD Project", em.Id);

        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        var resDate = new DateOnly(2026, 11, 10);
        var lwdDate = new DateOnly(2026, 11, 20);

        db.ExitedEmployees.Add(new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            ResignationDate = resDate,
            LastWorkingDay = lwdDate,
            StatusAtExit = "Notice Period",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        var day2 = new DateOnly(2026, 11, 12);
        var firstRun = await notifService.ProcessLwdRemindersAsync(day2);
        Assert.True(firstRun >= 1);

        // Immediate second run on the exact same IST date must return 0 for this employee
        var initialNotifsCount = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == em.Id && n.ProjectId == project.Id && n.Type == "LWD Reminder");

        await notifService.ProcessLwdRemindersAsync(day2);

        var afterSecondRunCount = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == em.Id && n.ProjectId == project.Id && n.Type == "LWD Reminder");

        Assert.Equal(initialNotifsCount, afterSecondRunCount);
    }

    [Fact]
    public async Task ProcessLwdReminders_LwdDateChanged_ReflectsUpdatedLwd()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        var em = await CreateTestEmployeeAsync(db, "ChangeEM", "Leader", role: "Engagement Manager");
        var emp = await CreateTestEmployeeAsync(db, "Vikram", "Rao", status: "Notice Period");
        var project = await CreateTestProjectAsync(db, "LWD Changed Project", em.Id);

        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        var resDate = new DateOnly(2026, 11, 10);
        var initialLwd = new DateOnly(2026, 11, 20);

        var exit = new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            ResignationDate = resDate,
            LastWorkingDay = initialLwd,
            StatusAtExit = "Notice Period",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.ExitedEmployees.Add(exit);
        await db.SaveChangesAsync();

        // Now LWD is updated/extended to 2026-11-26
        exit.LastWorkingDay = new DateOnly(2026, 11, 26);
        await db.SaveChangesAsync();

        // On Day 2 (2026-11-12)
        var day2 = new DateOnly(2026, 11, 12);
        await notifService.ProcessLwdRemindersAsync(day2);

        var expectedUpdatedTitle = $"{emp.FirstName} {emp.LastName} Last Working date is 26 November 2026";
        var updatedNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == em.Id &&
                                      n.ProjectId == project.Id &&
                                      n.Title == expectedUpdatedTitle);
        Assert.NotNull(updatedNotif);
        Assert.Contains("26 November 2026", updatedNotif.CommentsJson);
    }

    [Fact]
    public async Task ProcessLwdReminders_OffboardingCancelled_StopsReminders()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        var em = await CreateTestEmployeeAsync(db, "CancelEM", "Lead", role: "Engagement Manager");
        // Status is active, representing cancelled resignation
        var emp = await CreateTestEmployeeAsync(db, "Active", "Retained", status: "Active");
        var project = await CreateTestProjectAsync(db, "Cancelled Resignation Project", em.Id);

        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        db.ExitedEmployees.Add(new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            ResignationDate = new DateOnly(2026, 11, 10),
            LastWorkingDay = new DateOnly(2026, 11, 20),
            StatusAtExit = "Cancelled",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        var day2 = new DateOnly(2026, 11, 12);
        await notifService.ProcessLwdRemindersAsync(day2);

        var notifSent = await db.ActionNotifications
            .AnyAsync(n => n.RecipientEmployeeId == em.Id && n.ProjectId == project.Id && n.Type == "LWD Reminder");
        Assert.False(notifSent);
    }

    [Fact]
    public async Task ProcessLwdReminders_AfterLwdPassed_DoesNotSendReminders()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        var em = await CreateTestEmployeeAsync(db, "PastEM", "Head", role: "Engagement Manager");
        var emp = await CreateTestEmployeeAsync(db, "Past", "Resource", status: "Notice Period");
        var project = await CreateTestProjectAsync(db, "Past LWD Project", em.Id);

        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        var resDate = new DateOnly(2026, 11, 10);
        var lwdDate = new DateOnly(2026, 11, 20);

        db.ExitedEmployees.Add(new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            ResignationDate = resDate,
            LastWorkingDay = lwdDate,
            StatusAtExit = "Notice Period",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        // Check date 2026-11-22 (2 days after LWD): must NOT dispatch LWD reminder
        var dayAfterLwd = new DateOnly(2026, 11, 22);
        await notifService.ProcessLwdRemindersAsync(dayAfterLwd);

        var notifSent = await db.ActionNotifications
            .AnyAsync(n => n.RecipientEmployeeId == em.Id && n.ProjectId == project.Id && n.Type == "LWD Reminder");
        Assert.False(notifSent);
    }

    [Fact]
    public async Task ProcessPostOffboarding_NextCalendarDateAfterLwd_NotifiesHODAndSPM()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        // Set up Department
        var dept = await db.Departments.FirstOrDefaultAsync(d => d.DeletedAtUtc == null);
        Guid deptId;
        string deptName;
        if (dept != null)
        {
            deptId = dept.Id;
            deptName = dept.Name;
        }
        else
        {
            var newDept = new MstDepartment
            {
                Id = Guid.NewGuid(),
                Code = "ENG",
                Name = "Engineering",
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            };
            db.Departments.Add(newDept);
            await db.SaveChangesAsync();
            deptId = newDept.Id;
            deptName = newDept.Name;
        }

        // Set up HOD with Role = "Head Of Department"
        var hod = await CreateTestEmployeeAsync(db, "Harry", "Hod", role: "Head Of Department", departmentId: deptId);

        // Set up SPM
        var spm = await CreateTestEmployeeAsync(db, "Sam", "Spm", role: "Senior Project Manager");

        // Set up Resource
        var emp = await CreateTestEmployeeAsync(db, "Elena", "Rostova", departmentId: deptId, status: "Exited");

        // Set up Project
        var project = await CreateTestProjectAsync(db, "Project PostOffboard Alpha");

        // Add SPM to Project
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = spm.Id,
            MemberRole = ProjectMemberRoles.SeniorProjectManager,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        // Add Employee to Project
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        var resDate = new DateOnly(2026, 11, 10);
        var lwdDate = new DateOnly(2026, 11, 20);

        db.ExitedEmployees.Add(new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            DepartmentName = deptName,
            ResignationDate = resDate,
            LastWorkingDay = lwdDate,
            StatusAtExit = "Exited",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        // 1. Next calendar date after LWD is 2026-11-21
        var nextDate = new DateOnly(2026, 11, 21);
        var postCount = await notifService.ProcessPostOffboardingNotificationsAsync(nextDate);
        Assert.True(postCount >= 2); // At least HOD + SPM

        var expectedTitle = $"{emp.FirstName} {emp.LastName} is offboarded";

        // Verify HOD notification
        var hodNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == hod.Id &&
                                      n.ProjectId == project.Id &&
                                      n.Title == expectedTitle);
        Assert.NotNull(hodNotif);
        Assert.Equal("Employee Offboarded", hodNotif.Type);
        Assert.Equal("Pending", hodNotif.Status);
        Assert.Equal("Low", hodNotif.Priority);
        Assert.True(hodNotif.Unread);
        Assert.Equal("System / Automation Engine", hodNotif.RaisedByName);
        Assert.Equal(project.Name, hodNotif.ProjectName);
        Assert.Contains("offboarded", hodNotif.CommentsJson);

        // Verify SPM notification
        var spmNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == spm.Id &&
                                      n.ProjectId == project.Id &&
                                      n.Title == expectedTitle);
        Assert.NotNull(spmNotif);
        Assert.Equal("Employee Offboarded", spmNotif.Type);
        Assert.Equal("Pending", spmNotif.Status);
        Assert.Equal("Low", spmNotif.Priority);
        Assert.True(spmNotif.Unread);
        Assert.Equal("System / Automation Engine", spmNotif.RaisedByName);
        Assert.Equal(project.Name, spmNotif.ProjectName);

        // 2. Second execution on same date must be idempotent
        await notifService.ProcessPostOffboardingNotificationsAsync(nextDate);
        var hodNotifCount = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == hod.Id && n.ProjectId == project.Id && n.Title == expectedTitle);
        var spmNotifCount = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == spm.Id && n.ProjectId == project.Id && n.Title == expectedTitle);

        Assert.Equal(1, hodNotifCount);
        Assert.Equal(1, spmNotifCount);
    }

    [Fact]
    public async Task ProcessPostOffboarding_NotNextCalendarDate_DoesNotTrigger()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IOffboardingNotificationService>();

        var hod = await CreateTestEmployeeAsync(db, "Harvey", "Specter", role: "Head Of Department");
        var emp = await CreateTestEmployeeAsync(db, "Donna", "Paulsen", status: "Exited");
        var project = await CreateTestProjectAsync(db, "Project Law PostOffboard");

        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        var lwdDate = new DateOnly(2026, 11, 20);
        db.ExitedEmployees.Add(new ExitedEmployee
        {
            Id = Guid.NewGuid(),
            OriginalEmployeeId = emp.Id,
            EmployeeCode = emp.EmployeeCode,
            FullName = $"{emp.FirstName} {emp.LastName}".Trim(),
            ResignationDate = new DateOnly(2026, 11, 10),
            LastWorkingDay = lwdDate,
            StatusAtExit = "Exited",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        // Test on LWD date itself (not LWD + 1) -> Must NOT trigger
        await notifService.ProcessPostOffboardingNotificationsAsync(lwdDate);

        var notifSentOnLwd = await db.ActionNotifications
            .AnyAsync(n => n.RecipientEmployeeId == hod.Id && n.ProjectId == project.Id && n.Type == "Employee Offboarded");
        Assert.False(notifSentOnLwd);

        // Test on LWD + 2 days -> Must NOT trigger
        await notifService.ProcessPostOffboardingNotificationsAsync(lwdDate.AddDays(2));

        var notifSentAfter2Days = await db.ActionNotifications
            .AnyAsync(n => n.RecipientEmployeeId == hod.Id && n.ProjectId == project.Id && n.Type == "Employee Offboarded");
        Assert.False(notifSentAfter2Days);
    }

    [Fact]
    public async Task OffboardEmployee_HttpEndpoint_TriggersImmediateResignationNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var em = await CreateTestEmployeeAsync(db, "ApiEM", "Leader", role: "Engagement Manager");
        var emp = await CreateTestEmployeeAsync(db, "Api", "Offboardee");
        var project = await CreateTestProjectAsync(db, "API Test Project Phoenix", em.Id);

        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            MemberRole = ProjectMemberRoles.ProjectTeam,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        // Call HTTP POST /api/v1/employees/{id}/offboard
        var request = new OffboardEmployeeRequest(
            ResignationDate: new DateOnly(2026, 11, 15),
            LastWorkingDay: new DateOnly(2026, 11, 30),
            ReasonForLeaving: "Better Opportunity",
            NoticePeriodServed: "Yes",
            ExitChecklistJson: null,
            AssetReturnJson: null,
            FinalSettlementJson: null,
            ExitType: "Voluntary",
            ExitReason: "Career Growth",
            ClearanceCompleted: true,
            ExitRating: 4.5m
        );

        var res = await _client.PostAsJsonAsync($"/api/v1/employees/{emp.Id}/offboard", request);
        Assert.Equal(HttpStatusCode.OK, res.StatusCode);

        // Verify ActionNotification record was created for EM
        var expectedTitle = $"{emp.FirstName} {emp.LastName} Resignation Applied";
        var notif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == em.Id &&
                                      n.ProjectId == project.Id &&
                                      n.Title == expectedTitle);

        Assert.NotNull(notif);
        Assert.Equal("Resignation Applied", notif.Type);
        Assert.Equal("Pending", notif.Status);
        Assert.Equal("Low", notif.Priority);
        Assert.True(notif.Unread);
        Assert.Equal(project.Name, notif.ProjectName);
    }
}
