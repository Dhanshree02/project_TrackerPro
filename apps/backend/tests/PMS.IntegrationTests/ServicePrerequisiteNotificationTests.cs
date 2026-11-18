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

public class ServicePrerequisiteNotificationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public ServicePrerequisiteNotificationTests(WebApplicationFactory<Program> factory)
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

    private static async Task<(Project Project, ProjectServiceEntity Service, Employee Pm, Employee Em, Employee Tl, Employee Hod)> SetupEnvironmentAsync(AppDbContext db)
    {
        var suffix = Guid.NewGuid().ToString("N")[..8];

        // 1. Department & HOD Designation & On Floor Role
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

        // 2. Employees: PM, EM, TL, HOD
        var pm = await CreateEmployeeAsync(db, $"PM_{suffix}", "Lead", "PMO", "ProjectManager", departmentId: dept.Id);
        var em = await CreateEmployeeAsync(db, $"EM_{suffix}", "Head", "EM", "EngagementManager", departmentId: dept.Id);
        var tl = await CreateEmployeeAsync(db, $"TL_{suffix}", "Tech", "Engineering", "TeamLead", departmentId: dept.Id);
        var hod = await CreateEmployeeAsync(db, $"HOD_{suffix}", "Director", "Engineering", "Head of Department", designationId: hodDesig.Id, departmentId: dept.Id);

        // 3. Client & Project with PM, EM, TL assigned
        var client = await db.Clients.FirstOrDefaultAsync(c => c.DeletedAtUtc == null);
        var project = new Project
        {
            Id = Guid.NewGuid(),
            Name = $"Prereq_Project_{suffix}",
            ProjectCode = $"PRJ-{suffix.ToUpper()}",
            WbsId = $"WBS-{suffix.ToUpper()}",
            ClientId = client?.Id ?? Guid.NewGuid(),
            ProjectManagerId = pm.Id,
            EngagementManagerId = em.Id,
            TeamLeadId = tl.Id,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Projects.Add(project);

        // 4. Unstarted Project Service (IsReady = false)
        var service = new ProjectServiceEntity
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            ServiceName = $"Cloud Migration {suffix}",
            Department = dept.Name,
            IsReady = false,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.ProjectServices.Add(service);
        await db.SaveChangesAsync();

        return (project, service, pm, em, tl, hod);
    }

    [Fact]
    public async Task Scenario1_ServiceStarted_DispatchesNotificationTo_Pm_Em_And_Tl()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, service, pm, em, tl, _) = await SetupEnvironmentAsync(db);

        // Act: Start service
        service.IsReady = true;
        await db.SaveChangesAsync();

        await notifService.NotifyServiceStartedAsync(project.Id, service.Id, "Admin Tester");

        // Assert: Notifications created for PM, EM, and TL
        var notifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.Type == "Service Started" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(3, notifs.Count);

        var pmNotif = notifs.FirstOrDefault(n => n.RecipientEmployeeId == pm.Id);
        var emNotif = notifs.FirstOrDefault(n => n.RecipientEmployeeId == em.Id);
        var tlNotif = notifs.FirstOrDefault(n => n.RecipientEmployeeId == tl.Id);

        Assert.NotNull(pmNotif);
        Assert.NotNull(emNotif);
        Assert.NotNull(tlNotif);

        Assert.Contains(service.ServiceName, pmNotif.Title);
        Assert.Contains(project.Name, pmNotif.Title);
        Assert.Equal("Service Started", pmNotif.Type);
        Assert.Equal("Started", pmNotif.Status);
        Assert.True(pmNotif.Unread);
    }

    [Fact]
    public async Task Scenario2_ServiceNotStarted_AfterTwoDays_SendsL1EscalationTo_AssignedPm()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, service, pm, _, _, _) = await SetupEnvironmentAsync(db);

        // Act: Service remains not started; L1 escalation job runs at EOD
        await notifService.ExecuteServicePrerequisiteL1EscalationJobAsync(project.Id, service.Id);

        // Assert: L1 escalation notification sent specifically to Assigned PM
        var l1Notifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.Type == "Service Prerequisite Escalation" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Single(l1Notifs);
        var notif = l1Notifs.First();

        Assert.Equal(pm.Id, notif.RecipientEmployeeId);
        Assert.StartsWith("1st Level Breach Escalation: Service Not Started", notif.Title);
        Assert.Equal("High", notif.Priority);
        Assert.Equal("Escalated", notif.Status);
        Assert.Contains("\"level\":1", notif.HistoryJson);
    }

    [Fact]
    public async Task Scenario3_ServiceStillNotStarted_AfterL1Escalation_SendsL2EscalationTo_Hod()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, service, _, _, _, hod) = await SetupEnvironmentAsync(db);

        // Act: Service is STILL not started; L2 escalation job runs at EOD
        await notifService.ExecuteServicePrerequisiteL2EscalationJobAsync(project.Id, service.Id);

        // Assert: L2 escalation notification sent to HOD
        var l2Notifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.Type == "Service Prerequisite Escalation" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.NotEmpty(l2Notifs);
        var hodNotif = l2Notifs.FirstOrDefault(n => n.RecipientEmployeeId == hod.Id);

        Assert.NotNull(hodNotif);
        Assert.StartsWith("2nd Level Breach Escalation: Service Not Started", hodNotif.Title);
        Assert.Equal("Critical", hodNotif.Priority);
        Assert.Equal("Escalated", hodNotif.Status);
        Assert.Contains("\"level\":2", hodNotif.HistoryJson);
    }

    [Fact]
    public async Task Scenario4_ServiceStarted_BeforeBreach_PreventsEscalations()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, service, _, _, _, _) = await SetupEnvironmentAsync(db);

        // Mark service as started
        service.IsReady = true;
        await db.SaveChangesAsync();

        // Act: Both L1 and L2 jobs execute
        await notifService.ExecuteServicePrerequisiteL1EscalationJobAsync(project.Id, service.Id);
        await notifService.ExecuteServicePrerequisiteL2EscalationJobAsync(project.Id, service.Id);

        // Assert: No escalation notifications should be created
        var escalations = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.Type == "Service Prerequisite Escalation" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Empty(escalations);
    }

    [Fact]
    public async Task Scenario5_EscalationJobs_AreIdempotent_NoDuplicatesWhenRetried()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var (project, service, pm, _, _, hod) = await SetupEnvironmentAsync(db);

        // Act: Run L1 twice
        await notifService.ExecuteServicePrerequisiteL1EscalationJobAsync(project.Id, service.Id);
        await notifService.ExecuteServicePrerequisiteL1EscalationJobAsync(project.Id, service.Id);

        // Act: Run L2 twice
        await notifService.ExecuteServicePrerequisiteL2EscalationJobAsync(project.Id, service.Id);
        await notifService.ExecuteServicePrerequisiteL2EscalationJobAsync(project.Id, service.Id);

        // Assert: Exactly one L1 and one L2 notification exists
        var pmL1Count = await db.ActionNotifications
            .CountAsync(n => n.ProjectId == project.Id && n.RecipientEmployeeId == pm.Id && n.HistoryJson.Contains("\"level\":1"));
        var hodL2Count = await db.ActionNotifications
            .CountAsync(n => n.ProjectId == project.Id && n.RecipientEmployeeId == hod.Id && n.HistoryJson.Contains("\"level\":2"));

        Assert.Equal(1, pmL1Count);
        Assert.Equal(1, hodL2Count);
    }

    [Fact]
    public async Task Scenario6_UpdateServicePrerequisite_ViaAppService_TriggersServiceStartedNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var projectService = scope.ServiceProvider.GetRequiredService<IProjectAppService>();

        var (project, service, pm, em, tl, _) = await SetupEnvironmentAsync(db);

        // Act: Set IsReady = true through ProjectAppService.UpdateServicePrerequisiteAsync
        var req = new UpdateServicePrerequisiteRequest(IsReady: true);
        await projectService.UpdateServicePrerequisiteAsync(project.Id, service.Id, req);

        // Assert: ServiceStarted notifications generated for PM, EM, TL
        var notifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.Type == "Service Started" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(3, notifs.Count);
        Assert.Contains(notifs, n => n.RecipientEmployeeId == pm.Id);
        Assert.Contains(notifs, n => n.RecipientEmployeeId == em.Id);
        Assert.Contains(notifs, n => n.RecipientEmployeeId == tl.Id);
    }

    [Fact]
    public async Task Scenario7_ServiceModified_DispatchesNotificationTo_EngagementManager_WithTitle()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var projectService = scope.ServiceProvider.GetRequiredService<IProjectAppService>();

        var (project, service, _, em, _, _) = await SetupEnvironmentAsync(db);

        // Act: Modify the service through UpdateProjectServiceAsync
        var updateReq = new UpdateProjectServiceRequest(
            Qty: 5,
            ResourceLevel: "L2: 3, L3: 2",
            AsPendingModification: true);

        await projectService.UpdateProjectServiceAsync(project.Id, service.Id, updateReq);

        // Assert: Notification generated for assigned Engagement Manager
        var notifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.RecipientEmployeeId == em.Id && n.Type == "Service Modified" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.NotEmpty(notifs);
        var notif = notifs.Last();

        Assert.Equal($"The {project.Name} service is modify", notif.Title);
        Assert.Equal(em.Id, notif.RecipientEmployeeId);
        Assert.Contains(service.ServiceName, notif.HistoryJson);
        Assert.True(notif.Unread);
    }

    [Fact]
    public async Task Scenario8_ServiceDeleted_DispatchesNotificationTo_EngagementManager_WithTitle()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var projectService = scope.ServiceProvider.GetRequiredService<IProjectAppService>();

        var (project, service, _, em, _, _) = await SetupEnvironmentAsync(db);

        // Act: Delete the service
        await projectService.DeleteProjectServiceAsync(project.Id, service.Id);

        // Assert: Notification generated for assigned Engagement Manager with deleted title
        var notifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.RecipientEmployeeId == em.Id && n.Type == "Service Deleted" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.NotEmpty(notifs);
        var notif = notifs.Last();

        Assert.Equal($"The {project.Name} service is deleted", notif.Title);
        Assert.Equal(em.Id, notif.RecipientEmployeeId);
        Assert.Contains(service.ServiceName, notif.HistoryJson);
        Assert.True(notif.Unread);
    }

    [Fact]
    public async Task Scenario9_ServiceAdded_DispatchesNotificationTo_EngagementManager_WithTitle()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var projectService = scope.ServiceProvider.GetRequiredService<IProjectAppService>();

        var (project, _, _, em, _, _) = await SetupEnvironmentAsync(db);

        // Act: Add a new service to the project
        var addReq = new CreateProjectServiceRequest(
            ServiceName: "Mobile Penetration Testing",
            Department: "Cybersecurity",
            Qty: 2);

        var created = await projectService.AddProjectServiceAsync(project.Id, addReq);

        // Assert: Notification generated for assigned Engagement Manager with added title
        var notifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.RecipientEmployeeId == em.Id && n.Type == "Service Added" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.NotEmpty(notifs);
        var notif = notifs.Last();

        Assert.Equal($"The {project.Name} service is added", notif.Title);
        Assert.Equal(em.Id, notif.RecipientEmployeeId);
        Assert.Contains(created.ServiceName, notif.HistoryJson);
        Assert.True(notif.Unread);
    }
}
