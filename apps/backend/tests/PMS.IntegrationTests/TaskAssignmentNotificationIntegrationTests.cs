using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Resources.Models;
using Xunit;

namespace PMS.IntegrationTests;

public class TaskAssignmentNotificationIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public TaskAssignmentNotificationIntegrationTests(WebApplicationFactory<Program> factory)
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
            Role = "Security Consultant",
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
                Name = "Test Client For Tasks",
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
    public async Task AssignResourceToTask_SyncTaskAssignments_GeneratesNotificationWithFormattedTitle()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var resource = await CreateTestEmployeeAsync(db, "Rohan", "Deshpande");
        var project = await CreateTestProjectAsync(db, "FinTech Security Assessment");

        // Add service to project
        var service = new ProjectServiceEntity
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            ServiceName = "Network Penetration Testing",
            Department = "Cybersecurity",
            SortOrder = 1,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.ProjectServices.Add(service);

        // Add task under this service
        var task = new ProjectTask
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            ProjectServiceId = service.Id,
            Title = "Vulnerability Assessment",
            Stage = "Ready to Start",
            Priority = "High",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.ProjectTasks.Add(task);

        // Add resource to project team
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = resource.Id,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-1)),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            Billability = "Billable",
            MemberRole = ProjectMemberRoles.ProjectTeam,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        await db.SaveChangesAsync();

        // Assign resource to task via API (simulating Task Tab assignment)
        var response = await _client.PutAsJsonAsync(
            $"/api/v1/projects/{project.Id}/tasks/{task.Id}/assignments",
            new SyncTaskAssignmentsRequest(new[] { resource.Id }, "High"));

        Assert.True(response.IsSuccessStatusCode, $"Sync task assignments failed: {await response.Content.ReadAsStringAsync()}");

        // Verify notification in Action Center
        using var verifyScope = _factory.Services.CreateScope();
        var verifyDb = verifyScope.ServiceProvider.GetRequiredService<AppDbContext>();

        var notif = await verifyDb.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == resource.Id && n.ProjectId == project.Id && n.RelatedTask == "Vulnerability Assessment");

        Assert.NotNull(notif);
        Assert.Equal("The Rohan Deshpande is assigned to the Vulnerability Assessment of the Network Penetration Testing", notif.Title);
        Assert.Equal("Task Assignment", notif.Type);
        Assert.Equal("Assigned", notif.Status);
        Assert.Equal(project.Name, notif.ProjectName);
        Assert.True(notif.Unread);
    }

    [Fact]
    public async Task AssignResourceToTask_FallbackService_ResolvesFirstService()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var taskService = scope.ServiceProvider.GetRequiredService<IProjectTaskService>();

        var resource = await CreateTestEmployeeAsync(db, "Alice", "Smith");
        var project = await CreateTestProjectAsync(db, "Cloud Migration Audit");

        // Add first service to project
        var service = new ProjectServiceEntity
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            ServiceName = "Cloud Infrastructure Security",
            Department = "Cloud Security",
            SortOrder = 1,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.ProjectServices.Add(service);

        // Add task WITHOUT ProjectServiceId explicitly linked
        var task = new ProjectTask
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            ProjectServiceId = null,
            Title = "IAM Configuration Review",
            Stage = "Ready to Start",
            Priority = "Medium",
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.ProjectTasks.Add(task);

        // Add resource to project team
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = resource.Id,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-1)),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            Billability = "Billable",
            MemberRole = ProjectMemberRoles.ProjectTeam,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        });

        await db.SaveChangesAsync();

        // Assign via task service directly
        await taskService.SynchronizeAssignmentsAsync(project.Id, task.Id, new[] { resource.Id }, "Medium");

        // Verify notification resolves fallback service name
        using var verifyScope = _factory.Services.CreateScope();
        var verifyDb = verifyScope.ServiceProvider.GetRequiredService<AppDbContext>();

        var notif = await verifyDb.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == resource.Id && n.ProjectId == project.Id && n.RelatedTask == "IAM Configuration Review");

        Assert.NotNull(notif);
        Assert.Equal("The Alice Smith is assigned to the IAM Configuration Review of the Cloud Infrastructure Security", notif.Title);
        Assert.Equal("Task Assignment", notif.Type);
        Assert.Equal("Assigned", notif.Status);
    }
}
