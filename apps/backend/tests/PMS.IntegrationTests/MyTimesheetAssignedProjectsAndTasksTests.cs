using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class MyTimesheetAssignedProjectsAndTasksTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public MyTimesheetAssignedProjectsAndTasksTests(WebApplicationFactory<Program> factory)
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

    private static async Task<string> GenerateUniqueProjectCodeAsync(AppDbContext db)
    {
        var existingCodes = await db.Projects.Select(p => p.ProjectCode).ToHashSetAsync();
        string code;
        do
        {
            code = $"PRJ-{Random.Shared.Next(1000, 9999):D4}";
        } while (existingCodes.Contains(code));
        return code;
    }

    [Fact]
    public async Task GetAssignedProjects_And_Tasks_FilterByEmployee_Correctly()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        // 1. Get or create a client
        var client = await db.Clients.FirstOrDefaultAsync();
        if (client == null)
        {
            client = new PMS.API.Modules.Customers.Models.Client
            {
                Id = Guid.NewGuid(),
                Name = "Test Client",
                ClientCode = $"CLI-{Random.Shared.Next(1000, 9999)}",
                Status = PMS.API.Modules.Customers.Models.ClientStatus.Active
            };
            db.Clients.Add(client);
            await db.SaveChangesAsync();
        }

        // 2. Create an employee
        var empCode = await GenerateUniqueEmployeeCodeAsync(db);
        var email = $"emp.{Guid.NewGuid():N}@talakunchi.com";
        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = empCode,
            FirstName = "Test",
            LastName = "Employee",
            WorkEmail = email,
            Status = "Active"
        };
        db.Employees.Add(employee);

        // 3. Create Project A (Assigned via Team Member) and Project B (Not assigned)
        var projCodeA = await GenerateUniqueProjectCodeAsync(db);
        var projectA = new Project
        {
            Id = Guid.NewGuid(),
            ClientId = client.Id,
            Name = $"Assigned Project {Guid.NewGuid():N}",
            ProjectCode = projCodeA,
            Status = "active"
        };
        db.Projects.Add(projectA);

        var projCodeB = await GenerateUniqueProjectCodeAsync(db);
        var projectB = new Project
        {
            Id = Guid.NewGuid(),
            ClientId = client.Id,
            Name = $"Unassigned Project {Guid.NewGuid():N}",
            ProjectCode = projCodeB,
            Status = "active"
        };
        db.Projects.Add(projectB);

        // Assign employee to Project A
        var teamMember = new ProjectTeamMember
        {
            Id = Guid.NewGuid(),
            ProjectId = projectA.Id,
            EmployeeId = employee.Id,
            MemberRole = "ProjectTeam",
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-30)),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(30))
        };
        db.ProjectTeamMembers.Add(teamMember);

        // 3. Create Task 1 (Assigned to employee) and Task 2 (Not assigned to employee) in Project A
        var task1 = new ProjectTask
        {
            Id = Guid.NewGuid(),
            ProjectId = projectA.Id,
            Title = "Assigned Task 1",
            Stage = "Development",
            Priority = "Medium",
            SortOrder = 1
        };
        db.ProjectTasks.Add(task1);

        var taskAssignment1 = new ProjectTaskAssignment
        {
            Id = Guid.NewGuid(),
            TaskId = task1.Id,
            EmployeeId = employee.Id,
            IsActive = true
        };
        db.ProjectTaskAssignments.Add(taskAssignment1);

        var task2 = new ProjectTask
        {
            Id = Guid.NewGuid(),
            ProjectId = projectA.Id,
            Title = "Unassigned Task 2",
            Stage = "Testing",
            Priority = "Low",
            SortOrder = 2
        };
        db.ProjectTasks.Add(task2);

        await db.SaveChangesAsync();

        // 4. Test GET /api/v1/projects?employeeId={employee.Id}&status=active
        var projectRes = await _client.GetFromJsonAsync<ApiResponse<PagedResult<ProjectDto>>>(
            $"/api/v1/projects?employeeId={employee.Id}&status=active&perPage=50");
        Assert.NotNull(projectRes?.Data?.Items);
        var projItems = projectRes.Data.Items;
        Assert.Contains(projItems, p => p.Id == projectA.Id);
        Assert.DoesNotContain(projItems, p => p.Id == projectB.Id);

        // 5. Test GET /api/v1/projects/{projectA.Id}/tasks?employeeId={employee.Id}
        var tasksRes = await _client.GetFromJsonAsync<ApiResponse<IReadOnlyList<ProjectTaskDto>>>(
            $"/api/v1/projects/{projectA.Id}/tasks?employeeId={employee.Id}");
        Assert.NotNull(tasksRes?.Data);
        var taskItems = tasksRes.Data;
        Assert.Contains(taskItems, t => t.Id == task1.Id);
        Assert.DoesNotContain(taskItems, t => t.Id == task2.Id);

        // 6. Test GET /api/v1/timesheets/mine/projects as the employee
        using var empClient = _factory.CreateClient();
        empClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        empClient.DefaultRequestHeaders.Add("X-User-Email", email);
        empClient.DefaultRequestHeaders.Add("X-User-Id", employee.Id.ToString());

        var mineProjectsRes = await empClient.GetFromJsonAsync<ApiResponse<IReadOnlyList<ProjectDto>>>(
            "/api/v1/timesheets/mine/projects");
        Assert.NotNull(mineProjectsRes?.Data);
        var mineProjItems = mineProjectsRes.Data;
        Assert.Contains(mineProjItems, p => p.Id == projectA.Id);
        Assert.DoesNotContain(mineProjItems, p => p.Id == projectB.Id);

        // 7. Test GET /api/v1/timesheets/mine/tasks?projectId={projectA.Id} as the employee
        var mineTasksRes = await empClient.GetFromJsonAsync<ApiResponse<IReadOnlyList<ProjectTaskDto>>>(
            $"/api/v1/timesheets/mine/tasks?projectId={projectA.Id}");
        Assert.NotNull(mineTasksRes?.Data);
        var mineTaskItems = mineTasksRes.Data;
        Assert.Contains(mineTaskItems, t => t.Id == task1.Id);
        Assert.DoesNotContain(mineTaskItems, t => t.Id == task2.Id);
    }
}
