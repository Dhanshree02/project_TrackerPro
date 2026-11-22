using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Customers.Models;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class ActionCentreSortingIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ActionCentreSortingIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    private static async Task<Employee> CreateTestEmployeeAsync(AppDbContext db, string firstName, string lastName)
    {
        var existingCodes = await db.Employees.Select(e => e.EmployeeCode).ToHashSetAsync();
        string code;
        do
        {
            code = $"TK-{Random.Shared.Next(1000, 9999):D4}";
        } while (existingCodes.Contains(code));

        var emp = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = code,
            FirstName = firstName,
            LastName = lastName,
            WorkEmail = $"{firstName.ToLower()}.{lastName.ToLower()}.{Guid.NewGuid():N}@talakunchi.com",
            Role = "Employee",
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
                Name = "Test Client For Sorting",
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
    public async Task BucketList_ReturnsRecentTasksFirst_AndHonorsPagination()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var bucketService = scope.ServiceProvider.GetRequiredService<IBucketTaskService>();

        var emp = await CreateTestEmployeeAsync(db, "Bucket", "Tester");
        var project = await CreateTestProjectAsync(db, "Sorting Bucket Project");

        var pTaskA = new ProjectTask { Id = Guid.NewGuid(), ProjectId = project.Id, Title = "Task A", CreatedAtUtc = DateTime.UtcNow };
        var pTaskB = new ProjectTask { Id = Guid.NewGuid(), ProjectId = project.Id, Title = "Task B", CreatedAtUtc = DateTime.UtcNow };
        var pTaskC = new ProjectTask { Id = Guid.NewGuid(), ProjectId = project.Id, Title = "Task C", CreatedAtUtc = DateTime.UtcNow };
        var pTaskD = new ProjectTask { Id = Guid.NewGuid(), ProjectId = project.Id, Title = "Task D", CreatedAtUtc = DateTime.UtcNow };
        db.ProjectTasks.AddRange(pTaskA, pTaskB, pTaskC, pTaskD);
        await db.SaveChangesAsync();

        var baseTime = DateTime.UtcNow.AddHours(-10);

        // Create 4 bucket tasks with deliberate dates
        // Task A: 10 hrs ago
        // Task B: 2 hrs ago (newest)
        // Task C: 6 hrs ago
        // Task D: 4 hrs ago
        var taskA = new BucketTask
        {
            Id = Guid.NewGuid(),
            TaskId = pTaskA.Id,
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            TaskTitle = "Task A - Oldest",
            ProjectName = project.Name,
            Priority = "Medium",
            Status = "To Do",
            TimerRunning = true, // even if timer is running, newest CreatedAtUtc should come first!
            CreatedAtUtc = baseTime,
            UpdatedAtUtc = DateTime.UtcNow // even if updated recently
        };

        var taskB = new BucketTask
        {
            Id = Guid.NewGuid(),
            TaskId = pTaskB.Id,
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            TaskTitle = "Task B - Newest",
            ProjectName = project.Name,
            Priority = "Medium",
            Status = "To Do",
            TimerRunning = false,
            CreatedAtUtc = baseTime.AddHours(8),
            UpdatedAtUtc = baseTime.AddHours(8)
        };

        var taskC = new BucketTask
        {
            Id = Guid.NewGuid(),
            TaskId = pTaskC.Id,
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            TaskTitle = "Task C - Middle Older",
            ProjectName = project.Name,
            Priority = "Medium",
            Status = "To Do",
            TimerRunning = false,
            CreatedAtUtc = baseTime.AddHours(4),
            UpdatedAtUtc = baseTime.AddHours(4)
        };

        var taskD = new BucketTask
        {
            Id = Guid.NewGuid(),
            TaskId = pTaskD.Id,
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            TaskTitle = "Task D - Middle Newer",
            ProjectName = project.Name,
            Priority = "Medium",
            Status = "To Do",
            TimerRunning = false,
            CreatedAtUtc = baseTime.AddHours(6),
            UpdatedAtUtc = baseTime.AddHours(6)
        };

        db.BucketTasks.AddRange(taskA, taskB, taskC, taskD);
        await db.SaveChangesAsync();

        // Query Bucket tasks for this specific employee
        var result = await bucketService.GetBucketTasksAsync(new BucketTaskQueryParameters
        {
            EmployeeId = emp.Id,
            Page = 1,
            PageSize = 10
        });

        Assert.Equal(4, result.Items.Count);
        // Expected order: Task B (newest), Task D, Task C, Task A (oldest)
        Assert.Equal(taskB.Id, result.Items[0].Id);
        Assert.Equal(taskD.Id, result.Items[1].Id);
        Assert.Equal(taskC.Id, result.Items[2].Id);
        Assert.Equal(taskA.Id, result.Items[3].Id);

        // Verify pagination: Page 1 with PageSize=2 returns [Task B, Task D]
        var page1 = await bucketService.GetBucketTasksAsync(new BucketTaskQueryParameters
        {
            EmployeeId = emp.Id,
            Page = 1,
            PageSize = 2
        });
        Assert.Equal(2, page1.Items.Count);
        Assert.Equal(taskB.Id, page1.Items[0].Id);
        Assert.Equal(taskD.Id, page1.Items[1].Id);

        // Page 2 with PageSize=2 returns [Task C, Task A]
        var page2 = await bucketService.GetBucketTasksAsync(new BucketTaskQueryParameters
        {
            EmployeeId = emp.Id,
            Page = 2,
            PageSize = 2
        });
        Assert.Equal(2, page2.Items.Count);
        Assert.Equal(taskC.Id, page2.Items[0].Id);
        Assert.Equal(taskA.Id, page2.Items[1].Id);
    }

    [Fact]
    public async Task Notifications_ReturnsRecentNotificationsFirst()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var adminEmp = await db.Employees.FirstOrDefaultAsync(e => e.WorkEmail == "admin@talakunchi.com");
        var emp = adminEmp ?? await CreateTestEmployeeAsync(db, "Notif", "Tester");
        var project = await CreateTestProjectAsync(db, "Sorting Notif Project");

        var baseTime = DateTime.UtcNow.AddHours(-10);

        var nOld = new ActionNotification
        {
            Id = Guid.NewGuid(),
            RecipientEmployeeId = emp.Id,
            ProjectId = project.Id,
            ProjectName = project.Name,
            Title = "Notification - Old",
            Type = "General",
            Priority = "Low",
            Status = "Pending",
            CreatedAtUtc = baseTime,
            Unread = true
        };

        var nNew = new ActionNotification
        {
            Id = Guid.NewGuid(),
            RecipientEmployeeId = emp.Id,
            ProjectId = project.Id,
            ProjectName = project.Name,
            Title = "Notification - New",
            Type = "General",
            Priority = "Low",
            Status = "Pending",
            CreatedAtUtc = baseTime.AddHours(5),
            Unread = true
        };

        db.ActionNotifications.AddRange(nOld, nNew);
        await db.SaveChangesAsync();

        var res = await _client.GetFromJsonAsync<ApiResponse<IReadOnlyList<ActionNotificationDto>>>(
            $"/api/v1/action-centre/notifications?projectId={project.Id}");

        Assert.NotNull(res);
        Assert.NotNull(res.Data);
        var result = res.Data!;

        Assert.True(result.Count >= 2);
        var filtered = result.Where(n => n.Id == nOld.Id.ToString() || n.Id == nNew.Id.ToString()).ToList();
        Assert.Equal(2, filtered.Count);
        Assert.Equal(nNew.Id.ToString(), filtered[0].Id);
        Assert.Equal(nOld.Id.ToString(), filtered[1].Id);
    }

    [Fact]
    public async Task Alerts_ReturnsRecentAlertsFirst()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var emp = await CreateTestEmployeeAsync(db, "Alert", "Tester");
        var project = await CreateTestProjectAsync(db, "Sorting Alert Project");

        var baseTime = DateTime.UtcNow.AddHours(-8);

        var aOld = new ProjectAlert
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            Title = "Alert - Old",
            Description = "Old Alert",
            AlertType = "Governance",
            Priority = "High",
            Status = "Open",
            RaisedByName = "System",
            CreatedAtUtc = baseTime
        };

        var aNew = new ProjectAlert
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            Title = "Alert - New",
            Description = "New Alert",
            AlertType = "Governance",
            Priority = "High",
            Status = "Open",
            RaisedByName = "System",
            CreatedAtUtc = baseTime.AddHours(4)
        };

        db.ProjectAlerts.AddRange(aOld, aNew);
        await db.SaveChangesAsync();

        var res = await _client.GetFromJsonAsync<ApiResponse<IReadOnlyList<ActionAlertDto>>>(
            $"/api/v1/action-centre/alerts?projectId={project.Id}");

        Assert.NotNull(res);
        Assert.NotNull(res.Data);
        var result = res.Data!;

        Assert.True(result.Count >= 2);
        var filtered = result.Where(a => a.Id == aOld.Id.ToString() || a.Id == aNew.Id.ToString()).ToList();
        Assert.Equal(2, filtered.Count);
        Assert.Equal(aNew.Id.ToString(), filtered[0].Id);
        Assert.Equal(aOld.Id.ToString(), filtered[1].Id);
    }

    [Fact]
    public async Task Approvals_ReturnsRecentApprovalsFirst()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        var emp = await CreateTestEmployeeAsync(db, "Approval", "Tester");
        var project = await CreateTestProjectAsync(db, "Sorting Approvals Project");

        var baseTime = DateTime.UtcNow.AddHours(-12);

        // 1. Additional Requirement Approvals
        var reqOld = new ProjectAdditionalRequirement
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            RequirementId = $"REQ-{Random.Shared.Next(1000, 9999)}",
            RequirementType = "New Service Request",
            Title = "Old Requirement",
            Description = "Old Req Description",
            Status = "Pending Approval",
            CreatedAtUtc = baseTime
        };

        var reqNew = new ProjectAdditionalRequirement
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            RequirementId = $"REQ-{Random.Shared.Next(1000, 9999)}",
            RequirementType = "New Service Request",
            Title = "New Requirement",
            Description = "New Req Description",
            Status = "Pending Approval",
            CreatedAtUtc = baseTime.AddHours(6)
        };

        db.ProjectAdditionalRequirements.AddRange(reqOld, reqNew);

        // 2. Resource Allocation Approvals
        var allocOld = new ProjectResourceAllocationRequest
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            Billability = "Billable",
            ResourceType = "Dedicated",
            Status = "Pending",
            CreatedAtUtc = baseTime
        };

        var allocNew = new ProjectResourceAllocationRequest
        {
            Id = Guid.NewGuid(),
            ProjectId = project.Id,
            EmployeeId = emp.Id,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddMonths(1)),
            Billability = "Billable",
            ResourceType = "Dedicated",
            Status = "Pending",
            CreatedAtUtc = baseTime.AddHours(8)
        };

        db.ProjectResourceAllocationRequests.AddRange(allocOld, allocNew);
        await db.SaveChangesAsync();

        // Test Additional Requirements sorting via API
        var resReq = await _client.GetFromJsonAsync<ApiResponse<IReadOnlyList<ProjectAdditionalRequirementDto>>>("/api/v1/action-centre/approvals");
        Assert.NotNull(resReq?.Data);
        var myReqs = resReq.Data.Where(r => r.Id == reqOld.Id || r.Id == reqNew.Id).ToList();
        Assert.Equal(2, myReqs.Count);
        Assert.Equal(reqNew.Id, myReqs[0].Id);
        Assert.Equal(reqOld.Id, myReqs[1].Id);

        // Test Allocation Approvals sorting via API
        var resAlloc = await _client.GetFromJsonAsync<ApiResponse<IReadOnlyList<ProjectResourceAllocationRequestDto>>>("/api/v1/action-centre/allocation-approvals");
        Assert.NotNull(resAlloc?.Data);
        var myAllocs = resAlloc.Data.Where(a => a.Id == allocOld.Id || a.Id == allocNew.Id).ToList();
        Assert.Equal(2, myAllocs.Count);
        Assert.Equal(allocNew.Id, myAllocs[0].Id);
        Assert.Equal(allocOld.Id, myAllocs[1].Id);
    }
}
