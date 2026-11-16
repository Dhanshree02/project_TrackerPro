using System.Net.Http.Headers;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Resources.Models;
using Xunit;

namespace PMS.IntegrationTests;

public class ProjectAllocationReminderTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public ProjectAllocationReminderTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    private static async Task<Employee> CreateEmployeeAsync(
        AppDbContext db,
        string firstName,
        string lastName,
        string subDepartment = "Engineering",
        string role = "Employee",
        Guid? designationId = null,
        Guid? departmentId = null)
    {
        while (true)
        {
            var code = $"TKI-{Random.Shared.Next(1000, 9999):D4}";
            if (await db.Employees.AnyAsync(e => e.EmployeeCode == code)) continue;

            var emp = new Employee
            {
                Id = Guid.NewGuid(),
                EmployeeCode = code,
                FirstName = firstName,
                LastName = lastName,
                WorkEmail = $"{firstName.ToLower()}.{lastName.ToLower()}.{Guid.NewGuid():N}@talakunchi.com",
                Role = role,
                SubDepartment = subDepartment,
                DesignationId = designationId,
                DepartmentId = departmentId,
                Status = "Active",
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            };
            db.Employees.Add(emp);
            try
            {
                await db.SaveChangesAsync();
                return emp;
            }
            catch (DbUpdateException)
            {
                db.Employees.Remove(emp);
            }
        }
    }

    private static async Task<(Project Project, Employee Em, Employee Hod, Employee Pm, Employee Spm)> SetupEnvironmentAsync(AppDbContext db)
    {
        var suffix = Guid.NewGuid().ToString("N")[..8];

        // 1. Department & Designation for HOD
        var dept = new MstDepartment
        {
            Id = Guid.NewGuid(),
            Name = $"Dept_{suffix}",
            Code = $"D_{suffix}",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Departments.Add(dept);

        var hodDesig = new MstDesignation
        {
            Id = Guid.NewGuid(),
            Name = $"Head of Department_{suffix}",
            Code = $"HOD_{suffix}",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Designations.Add(hodDesig);

        var onFloorRole = new OnFloorRole
        {
            Id = Guid.NewGuid(),
            Name = "Head of Department",
            DesignationId = hodDesig.Id,
            DepartmentId = dept.Id,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.OnFloorRoles.Add(onFloorRole);
        await db.SaveChangesAsync();

        // 2. Employees
        var em = await CreateEmployeeAsync(db, $"EM_{suffix}", "Lead", "EM (Engagement Manager)", "EngagementManager", departmentId: dept.Id);
        var hod = await CreateEmployeeAsync(db, $"HOD_{suffix}", "Chief", "Engineering", "Head of Department", designationId: hodDesig.Id, departmentId: dept.Id);
        var pm = await CreateEmployeeAsync(db, $"PM_{suffix}", "Manager", "PMO (Project Management Office)", "ProjectManager");
        var spm = await CreateEmployeeAsync(db, $"SPM_{suffix}", "SeniorManager", "Senior Project Management", "SeniorProjectManager");

        // 3. Client & Project without PM/SPM assigned
        var client = await db.Clients.FirstOrDefaultAsync(c => c.DeletedAtUtc == null);
        var project = new Project
        {
            Id = Guid.NewGuid(),
            Name = $"Test_Project_{suffix}",
            ProjectCode = $"PRJ-{suffix.ToUpper()}",
            WbsId = $"WBS-{suffix.ToUpper()}",
            ClientId = client?.Id ?? Guid.NewGuid(),
            EngagementManagerId = em.Id,
            ProjectManagerId = null,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Projects.Add(project);

        var service = new ProjectServiceEntity
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            ServiceName = "Security Assessment",
            Department = dept.Name,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.ProjectServices.Add(service);
        await db.SaveChangesAsync();

        return (project, em, hod, pm, spm);
    }

    [Fact]
    public async Task Scenario1_NewProjectCreated_WithUnassignedPmAndSpm_SendsInitialReminderToEm()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, em, _, _, _) = await SetupEnvironmentAsync(db);

        // Act: Start reminder workflow on project creation
        await notifService.StartProjectAllocationReminderWorkflowAsync(project.Id);

        // Assert: Notification created for EM
        var notif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.ProjectId == project.Id && n.Type == "Project Allocation Reminder" && n.DeletedAtUtc == null);

        Assert.NotNull(notif);
        Assert.Equal(em.Id, notif.RecipientEmployeeId);
        Assert.Equal($"Project Manager and Senior Project Manager Assignment Pending | {project.Name} | {project.WbsId}", notif.Title);
        Assert.Equal("Pending", notif.Status);
        Assert.Equal("Low", notif.Priority);
        Assert.True(notif.Unread);
        Assert.Equal("System / Automation Engine", notif.RaisedByName);
        Assert.Equal(project.Name, notif.ProjectName);
        Assert.Equal(project.WbsId, notif.RelatedTask);
    }

    [Fact]
    public async Task Scenario2_NewWbsCreated_StartsWorkflowWithWbsIdentifier()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, em, _, _, _) = await SetupEnvironmentAsync(db);

        await notifService.StartProjectAllocationReminderWorkflowAsync(project.Id);

        var notif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.ProjectId == project.Id && n.RecipientEmployeeId == em.Id && n.DeletedAtUtc == null);

        Assert.NotNull(notif);
        Assert.Contains(project.WbsId!, notif.Title);
        Assert.Equal(project.WbsId, notif.RelatedTask);
    }

    [Fact]
    public async Task Scenario3_SubsequentReminders_ExecuteForUnassignedPositions()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, em, _, _, _) = await SetupEnvironmentAsync(db);

        // Start workflow (initial reminder)
        await notifService.StartProjectAllocationReminderWorkflowAsync(project.Id);

        // Act: Execute interval 1 reminder (simulating 2-hour job)
        await notifService.ExecuteProjectAllocationReminderJobAsync(project.Id, project.Name, project.WbsId!, 1);

        // Assert: Two reminders exist for EM (initial + interval 1)
        var reminders = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.RecipientEmployeeId == em.Id && n.Type == "Project Allocation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(2, reminders.Count);
        Assert.Contains(reminders, r => r.HistoryJson.Contains("\"interval\":0"));
        Assert.Contains(reminders, r => r.HistoryJson.Contains("\"interval\":1"));
    }

    [Fact]
    public async Task Scenario4_RemindersContinue_WhenOnlyPmIsAssigned_UntilBothAssigned()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, em, _, pm, _) = await SetupEnvironmentAsync(db);

        // Assign ONLY PM (SPM is still unassigned)
        project.ProjectManagerId = pm.Id;
        await db.SaveChangesAsync();

        // Act: Execute reminder job
        await notifService.ExecuteProjectAllocationReminderJobAsync(project.Id, project.Name, project.WbsId!, 1);

        // Assert: Reminder was sent because SPM is still missing (as per user note: reminder continues until and unless both are assigned)
        var reminder = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.ProjectId == project.Id && n.RecipientEmployeeId == em.Id && n.HistoryJson.Contains("\"interval\":1"));

        Assert.NotNull(reminder);
    }

    [Fact]
    public async Task Scenario5_RemindersStop_WhenBothPmAndSpmAreAssigned()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, em, _, pm, spm) = await SetupEnvironmentAsync(db);

        // Assign BOTH PM and SPM
        project.ProjectManagerId = pm.Id;
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = spm.Id,
            MemberRole = ProjectMemberRoles.SeniorProjectManager,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });
        await db.SaveChangesAsync();

        var countBefore = await db.ActionNotifications.CountAsync(n => n.ProjectId == project.Id);

        // Act: Execute reminder job
        await notifService.ExecuteProjectAllocationReminderJobAsync(project.Id, project.Name, project.WbsId!, 1);

        var countAfter = await db.ActionNotifications.CountAsync(n => n.ProjectId == project.Id);

        // Assert: No new reminder created because both are assigned
        Assert.Equal(countBefore, countAfter);
    }

    [Fact]
    public async Task Scenario6_SameDayHodCheck_WhenBothRemainUnassigned_SendsAlertToHod()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, _, hod, _, _) = await SetupEnvironmentAsync(db);

        // Neither PM nor SPM is assigned
        // Act: Execute end-of-day HOD check job
        await notifService.ExecuteSameDayHodCheckJobAsync(project.Id, project.Name, project.WbsId!);

        // Assert: HOD receives escalation notification
        var hodNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.ProjectId == project.Id && n.RecipientEmployeeId == hod.Id && n.Type == "Project Allocation Escalation");

        Assert.NotNull(hodNotif);
        Assert.Equal($"Project Manager and Senior Project Manager Assignment Still Pending | {project.Name} | {project.WbsId}", hodNotif.Title);
        Assert.Equal("Pending", hodNotif.Status);
        Assert.Equal("Low", hodNotif.Priority);
        Assert.True(hodNotif.Unread);
        Assert.Equal("System / Automation Engine", hodNotif.RaisedByName);
    }

    [Fact]
    public async Task Scenario7_SameDayHodCheck_WhenPmAssignedBeforeEod_DoesNotGenerateHodNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, _, hod, pm, _) = await SetupEnvironmentAsync(db);

        // PM is assigned before the EOD check
        project.ProjectManagerId = pm.Id;
        await db.SaveChangesAsync();

        // Act: Execute EOD check job
        await notifService.ExecuteSameDayHodCheckJobAsync(project.Id, project.Name, project.WbsId!);

        // Assert: HOD alert is NOT generated
        var hodNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.ProjectId == project.Id && n.Type == "Project Allocation Escalation");

        Assert.Null(hodNotif);
    }

    [Fact]
    public async Task Scenario8_DuplicateJobExecution_GuardsAgainstDuplicateNotifications()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, em, _, _, _) = await SetupEnvironmentAsync(db);

        // Start workflow twice (simulating duplicate trigger or retry)
        await notifService.StartProjectAllocationReminderWorkflowAsync(project.Id);
        await notifService.StartProjectAllocationReminderWorkflowAsync(project.Id);

        var initialCount = await db.ActionNotifications.CountAsync(n =>
            n.ProjectId == project.Id && n.RecipientEmployeeId == em.Id && n.HistoryJson.Contains("\"interval\":0"));
        Assert.Equal(1, initialCount);

        // Execute interval 1 reminder twice (simulating Hangfire retry)
        await notifService.ExecuteProjectAllocationReminderJobAsync(project.Id, project.Name, project.WbsId!, 1);
        await notifService.ExecuteProjectAllocationReminderJobAsync(project.Id, project.Name, project.WbsId!, 1);

        var interval1Count = await db.ActionNotifications.CountAsync(n =>
            n.ProjectId == project.Id && n.RecipientEmployeeId == em.Id && n.HistoryJson.Contains("\"interval\":1"));
        Assert.Equal(1, interval1Count);

        // Execute HOD check twice
        await notifService.ExecuteSameDayHodCheckJobAsync(project.Id, project.Name, project.WbsId!);
        await notifService.ExecuteSameDayHodCheckJobAsync(project.Id, project.Name, project.WbsId!);

        var hodCount = await db.ActionNotifications.CountAsync(n =>
            n.ProjectId == project.Id && n.Type == "Project Allocation Escalation");
        Assert.Equal(1, hodCount);
    }

    [Fact]
    public async Task Scenario9_MultipleProjects_RemindersAreIsolatedPerProject()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (projA, emA, _, _, _) = await SetupEnvironmentAsync(db);
        var (projB, emB, _, _, _) = await SetupEnvironmentAsync(db);

        await notifService.StartProjectAllocationReminderWorkflowAsync(projA.Id);
        await notifService.StartProjectAllocationReminderWorkflowAsync(projB.Id);

        var notifsA = await db.ActionNotifications.Where(n => n.ProjectId == projA.Id).ToListAsync();
        var notifsB = await db.ActionNotifications.Where(n => n.ProjectId == projB.Id).ToListAsync();

        Assert.Single(notifsA);
        Assert.Single(notifsB);
        Assert.Equal(emA.Id, notifsA[0].RecipientEmployeeId);
        Assert.Equal(emB.Id, notifsB[0].RecipientEmployeeId);
        Assert.Equal(projA.Name, notifsA[0].ProjectName);
        Assert.Equal(projB.Name, notifsB[0].ProjectName);
    }

    [Fact]
    public async Task Scenario10_SetLeadership_CancelsPendingRemindersWhenBothAssigned()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, em, _, pm, spm) = await SetupEnvironmentAsync(db);

        // Start reminder workflow
        await notifService.StartProjectAllocationReminderWorkflowAsync(project.Id);

        // Assign both PM and SPM via SetLeadershipAsync
        await teamService.SetLeadershipAsync(project.Id, new SetProjectLeadershipRequest(
            ProjectManagerIds: new[] { pm.Id },
            SeniorProjectManagerIds: new[] { spm.Id }));

        // Now run 2-hour job: it must find both assigned and not send any reminder
        var countBefore = await db.ActionNotifications.CountAsync(n => n.ProjectId == project.Id);
        await notifService.ExecuteProjectAllocationReminderJobAsync(project.Id, project.Name, project.WbsId!, 1);
        var countAfter = await db.ActionNotifications.CountAsync(n => n.ProjectId == project.Id);

        Assert.Equal(countBefore, countAfter);
    }
}
