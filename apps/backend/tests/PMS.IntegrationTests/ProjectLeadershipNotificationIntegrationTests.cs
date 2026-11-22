using System.Net.Http.Headers;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Resources.Models;
using Xunit;

namespace PMS.IntegrationTests;

public class ProjectLeadershipNotificationIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ProjectLeadershipNotificationIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
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

    private static async Task<Employee> CreateTestEmployeeAsync(AppDbContext db, string firstName, string lastName)
    {
        var emp = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = await GenerateUniqueEmployeeCodeAsync(db),
            FirstName = firstName,
            LastName = lastName,
            WorkEmail = $"{firstName.ToLower()}.{lastName.ToLower()}.{Guid.NewGuid():N}@talakunchi.com",
            Role = "Project Manager",
            Status = "Active",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Employees.Add(emp);
        await db.SaveChangesAsync();
        return emp;
    }

    private static async Task<Project> CreateTestProjectAsync(AppDbContext db, string projectName)
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
                Name = "Test Client For Leadership",
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
    public async Task AssignPM_FirstTime_DispatchesNotificationToNewPM_WithAllRequiredFields()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var pm = await CreateTestEmployeeAsync(db, "Alice", "Manager");
        var project = await CreateTestProjectAsync(db, "Test PM Project Alpha");

        // 1. Assign PM
        var res = await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(ProjectManagerIds: new[] { pm.Id }));

        Assert.NotEmpty(res);

        // 2. Query ActionNotifications for this PM
        var notifs = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == pm.Id && n.ProjectId == project.Id)
            .ToListAsync();

        Assert.Single(notifs);
        var notif = notifs[0];

        Assert.Equal("You are assigned as Project Manager", notif.Title);
        Assert.Equal("Project Manager Assigned", notif.Type);
        Assert.Equal("Low", notif.Priority);
        Assert.Equal("Assigned", notif.Status);
        Assert.True(notif.Unread);
        Assert.Equal(project.Name, notif.ProjectName);
        Assert.Contains($"You have been assigned as the Project Manager for the project {project.Name}.", notif.HistoryJson);

        // 3. Query through DTO projection
        var dtos = await notifService.GetNotificationsAsync(new NotificationQueryParameters
        {
            ProjectId = project.Id,
            Search = "Project Manager"
        });

        var targetDto = dtos.FirstOrDefault(d => d.Id == notif.Id.ToString());
        Assert.NotNull(targetDto);
        Assert.Equal(project.Name, targetDto.RelatedProject);
        Assert.Equal("Assigned", targetDto.Status);
        Assert.Equal("Low", targetDto.Priority);
    }

    [Fact]
    public async Task AssignSPM_FirstTime_DispatchesNotificationToNewSPM_WithAllRequiredFields()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var spm = await CreateTestEmployeeAsync(db, "Brian", "SeniorPM");
        var project = await CreateTestProjectAsync(db, "Test SPM Project Beta");

        // 1. Assign SPM
        var res = await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(SeniorProjectManagerIds: new[] { spm.Id }));

        Assert.NotEmpty(res);

        // 2. Query ActionNotifications for this SPM
        var notifs = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == spm.Id && n.ProjectId == project.Id)
            .ToListAsync();

        Assert.Single(notifs);
        var notif = notifs[0];

        Assert.Equal("You are assigned as Senior Project Manager", notif.Title);
        Assert.Equal("Senior Project Manager Assigned", notif.Type);
        Assert.Equal("Low", notif.Priority);
        Assert.Equal("Assigned", notif.Status);
        Assert.True(notif.Unread);
        Assert.Equal(project.Name, notif.ProjectName);
        Assert.Contains($"You have been assigned as the Senior Project Manager for the project {project.Name}.", notif.HistoryJson);

        // 3. Query through DTO projection
        var dtos = await notifService.GetNotificationsAsync(new NotificationQueryParameters
        {
            ProjectId = project.Id,
            Search = "Senior Project Manager"
        });

        var targetDto = dtos.FirstOrDefault(d => d.Id == notif.Id.ToString());
        Assert.NotNull(targetDto);
        Assert.Equal(project.Name, targetDto.RelatedProject);
        Assert.Equal("Assigned", targetDto.Status);
        Assert.Equal("Low", targetDto.Priority);
    }

    [Fact]
    public async Task AssignBothPMAndSPM_Simultaneously_DispatchesRespectiveNotificationToEach()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        var pm = await CreateTestEmployeeAsync(db, "Claire", "LeadPM");
        var spm = await CreateTestEmployeeAsync(db, "David", "LeadSPM");
        var project = await CreateTestProjectAsync(db, "Test Dual Leadership Project Gamma");

        // Assign both
        var res = await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(
                ProjectManagerIds: new[] { pm.Id },
                SeniorProjectManagerIds: new[] { spm.Id }));

        Assert.Equal(2, res.Count);

        // PM receives PM assignment
        var pmNotifs = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == pm.Id && n.ProjectId == project.Id)
            .ToListAsync();
        Assert.Single(pmNotifs);
        Assert.Equal("You are assigned as Project Manager", pmNotifs[0].Title);

        // SPM receives SPM assignment
        var spmNotifs = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == spm.Id && n.ProjectId == project.Id)
            .ToListAsync();
        Assert.Single(spmNotifs);
        Assert.Equal("You are assigned as Senior Project Manager", spmNotifs[0].Title);
    }

    [Fact]
    public async Task ReplaceExistingPM_DispatchesNotificationOnlyToNewPM_NotPreviousPM()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        var pmOld = await CreateTestEmployeeAsync(db, "OldPM", "Person");
        var pmNew = await CreateTestEmployeeAsync(db, "NewPM", "Person");
        var project = await CreateTestProjectAsync(db, "Test Replace PM Project");

        // 1. Initial assignment of OldPM
        await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(ProjectManagerIds: new[] { pmOld.Id }));

        var oldNotifsInitial = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == pmOld.Id && n.ProjectId == project.Id);
        Assert.Equal(1, oldNotifsInitial);

        // 2. Replace OldPM with NewPM
        await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(ProjectManagerIds: new[] { pmNew.Id }));

        // OldPM must NOT receive any new notification (count still 1)
        var oldNotifsAfter = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == pmOld.Id && n.ProjectId == project.Id);
        Assert.Equal(1, oldNotifsAfter);

        // NewPM receives exactly 1 notification
        var newNotifsAfter = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == pmNew.Id && n.ProjectId == project.Id)
            .ToListAsync();
        Assert.Single(newNotifsAfter);
        Assert.Equal("You are assigned as Project Manager", newNotifsAfter[0].Title);
    }

    [Fact]
    public async Task UnchangedAssignment_DoesNotGenerateDuplicateNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        var pm = await CreateTestEmployeeAsync(db, "StablePM", "Person");
        var project = await CreateTestProjectAsync(db, "Test Unchanged PM Project");

        // 1. Assign PM
        await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(ProjectManagerIds: new[] { pm.Id }));

        var notifsCount1 = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == pm.Id && n.ProjectId == project.Id);
        Assert.Equal(1, notifsCount1);

        // 2. Save again with unchanged PM
        await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(ProjectManagerIds: new[] { pm.Id }));

        var notifsCount2 = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == pm.Id && n.ProjectId == project.Id);
        Assert.Equal(1, notifsCount2); // No duplicate notification!
    }

    [Fact]
    public async Task Removal_DoesNotGenerateAssignmentNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        var pm = await CreateTestEmployeeAsync(db, "RemovedPM", "Person");
        var project = await CreateTestProjectAsync(db, "Test Remove PM Project");

        // 1. Assign PM
        await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(ProjectManagerIds: new[] { pm.Id }));

        var totalBefore = await db.ActionNotifications.CountAsync(n => n.ProjectId == project.Id);
        Assert.Equal(1, totalBefore);

        // 2. Remove PM (empty list)
        await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(ProjectManagerIds: Array.Empty<Guid>()));

        var totalAfter = await db.ActionNotifications.CountAsync(n => n.ProjectId == project.Id);
        Assert.Equal(1, totalAfter); // No new notification generated on removal
    }

    [Fact]
    public async Task IndependentAssignments_ChangingPMDoesNotNotifySPM_AndViceVersa()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        var pm1 = await CreateTestEmployeeAsync(db, "IndepPM1", "Person");
        var pm2 = await CreateTestEmployeeAsync(db, "IndepPM2", "Person");
        var spm = await CreateTestEmployeeAsync(db, "IndepSPM", "Person");
        var project = await CreateTestProjectAsync(db, "Test Independent PM SPM Project");

        // 1. Initial setup with PM1 and SPM
        await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(
                ProjectManagerIds: new[] { pm1.Id },
                SeniorProjectManagerIds: new[] { spm.Id }));

        var spmNotifCount1 = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == spm.Id && n.ProjectId == project.Id);
        Assert.Equal(1, spmNotifCount1);

        // 2. Update PM only (replace PM1 with PM2; SeniorProjectManagerIds is null)
        await teamService.SetLeadershipAsync(
            project.Id,
            new SetProjectLeadershipRequest(ProjectManagerIds: new[] { pm2.Id }));

        // SPM must NOT receive another notification
        var spmNotifCount2 = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == spm.Id && n.ProjectId == project.Id);
        Assert.Equal(1, spmNotifCount2);

        // PM2 received their notification
        var pm2NotifCount = await db.ActionNotifications
            .CountAsync(n => n.RecipientEmployeeId == pm2.Id && n.ProjectId == project.Id);
        Assert.Equal(1, pm2NotifCount);
    }
}
