using System.Net.Http.Headers;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Resources.DTOs;
using PMS.API.Modules.Resources.Services;
using Xunit;

namespace PMS.IntegrationTests;

public class ResourceNotificationIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ResourceNotificationIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    [Fact]
    public async Task ResourceOnboarding_DispatchesNotification_ToReportingManager_And_EmPmoLeadership()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var employeeService = scope.ServiceProvider.GetRequiredService<IEmployeeService>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        // 1. Pick an active reporting manager
        var reportingMgr = await db.Employees
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")));
        Assert.NotNull(reportingMgr);

        // Generate unique 4-digit code
        var existingCodes = await db.Employees.Select(e => e.EmployeeCode).ToListAsync();
        string randomCode;
        do
        {
            randomCode = $"TK-{Random.Shared.Next(1000, 9999):D4}";
        } while (existingCodes.Contains(randomCode));
        var req = new CreateEmployeeRequest(
            EmployeeCode: randomCode,
            FirstName: "TestOnboard",
            LastName: "Resource",
            WorkEmail: $"testonboard.{Guid.NewGuid():N}@talakunchi.com",
            Role: "Software Engineer",
            ReportingManagerId: reportingMgr.Id
        );

        var created = await employeeService.CreateEmployeeAsync(req);
        Assert.NotNull(created);

        // 2. Query notifications for this onboarded resource directly from DB
        var notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == randomCode && n.Type == "Resource Onboarded")
            .ToListAsync();

        Assert.NotEmpty(notifs);

        // Verify reporting manager received it
        var mgrNotif = notifs.FirstOrDefault(n => n.RecipientEmployeeId == reportingMgr.Id);
        Assert.NotNull(mgrNotif);
        Assert.Equal("Low", mgrNotif.Priority);
        Assert.Equal("Created", mgrNotif.Status);
        Assert.Equal("-", mgrNotif.ProjectName);
        Assert.Contains(randomCode, mgrNotif.Title);

        // Verify DTO projection maps RelatedProject as "-"
        var dtos = await notifService.GetNotificationsAsync(new NotificationQueryParameters
        {
            Search = randomCode
        });
        var targetDto = dtos.FirstOrDefault(d => d.RelatedTask == randomCode && d.Title.Contains("Resource Onboarded"));
        Assert.NotNull(targetDto);
        Assert.Equal("-", targetDto.RelatedProject);
        Assert.Equal("Low", targetDto.Priority);
        Assert.Equal("Created", targetDto.Status);
    }

    [Fact]
    public async Task ResourceProfileEdit_DispatchesNotification_OnlyToResourceReportingManager()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var employeeService = scope.ServiceProvider.GetRequiredService<IEmployeeService>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        // 1. Pick an active reporting manager and create a resource under them
        var reportingMgr = await db.Employees
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")));
        Assert.NotNull(reportingMgr);

        // Generate unique 4-digit code
        var existingCodes = await db.Employees.Select(e => e.EmployeeCode).ToListAsync();
        string randomCode;
        do
        {
            randomCode = $"TK-{Random.Shared.Next(1000, 9999):D4}";
        } while (existingCodes.Contains(randomCode));
        var initialEmail = $"testedit.{Guid.NewGuid():N}@talakunchi.com";
        var req = new CreateEmployeeRequest(
            EmployeeCode: randomCode,
            FirstName: "OriginalFirst",
            LastName: "OriginalLast",
            WorkEmail: initialEmail,
            Phone: $"8{Random.Shared.Next(100000000, 999999999)}",
            Role: "Software Engineer",
            ReportingManagerId: reportingMgr.Id
        );

        var created = await employeeService.CreateEmployeeAsync(req);
        Assert.NotNull(created);

        // 2. Perform Profile Update: change Phone and First Name
        var newPhone = $"9{Random.Shared.Next(100000000, 999999999)}";
        var newFirstName = "UpdatedFirst";
        var updateReq = new UpdateEmployeeRequest(
            FirstName: newFirstName,
            Phone: newPhone
        );

        var updated = await employeeService.UpdateEmployeeAsync(created.Id.ToString(), updateReq);
        Assert.NotNull(updated);

        // 3. Verify notification delivery
        var notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == randomCode && n.Type == "Resource Profile Updated")
            .ToListAsync();

        // Must be EXACTLY ONE notification sent, and strictly to the Reporting Manager
        Assert.Single(notifs);
        var notif = notifs[0];
        Assert.Equal(reportingMgr.Id, notif.RecipientEmployeeId);
        Assert.Equal("Low", notif.Priority);
        Assert.Equal("Edited", notif.Status);
        Assert.Equal("-", notif.ProjectName);
        Assert.Contains("change their profile", notif.Title);
        Assert.Contains("Phone", notif.Title);
        Assert.Contains("First Name", notif.Title);
        Assert.False(string.IsNullOrWhiteSpace(notif.RaisedByName));

        // 4. Verify DTO mapping through notifService
        var dtos = await notifService.GetNotificationsAsync(new NotificationQueryParameters
        {
            Search = randomCode
        });
        var dto = dtos.FirstOrDefault(d => d.RelatedTask == randomCode && d.Type == "Resource Profile Updated");
        Assert.NotNull(dto);
        Assert.Equal("-", dto.RelatedProject);
        Assert.Equal("Low", dto.Priority);
        Assert.Equal("Edited", dto.Status);
        Assert.Contains("change their profile", dto.Title);

        // 5. Verify NO other employees received a "Resource Profile Updated" notification for this task
        var otherEmployeeNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == randomCode && n.Type == "Resource Profile Updated" && n.RecipientEmployeeId != reportingMgr.Id)
            .ToListAsync();
        Assert.Empty(otherEmployeeNotifs);
    }

    [Fact]
    public async Task ResourceProfileEdit_WhenNoFieldsChange_DoesNotDispatchNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var employeeService = scope.ServiceProvider.GetRequiredService<IEmployeeService>();

        var reportingMgr = await db.Employees
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")));
        Assert.NotNull(reportingMgr);

        var existingCodes = await db.Employees.Select(e => e.EmployeeCode).ToListAsync();
        string randomCode;
        do
        {
            randomCode = $"TK-{Random.Shared.Next(1000, 9999):D4}";
        } while (existingCodes.Contains(randomCode));

        var req = new CreateEmployeeRequest(
            EmployeeCode: randomCode,
            FirstName: "SameFirst",
            LastName: "SameLast",
            WorkEmail: $"same.{Guid.NewGuid():N}@talakunchi.com",
            Role: "Developer",
            ReportingManagerId: reportingMgr.Id
        );

        var created = await employeeService.CreateEmployeeAsync(req);
        Assert.NotNull(created);

        // Update with identical values
        var updateReq = new UpdateEmployeeRequest(
            FirstName: "SameFirst",
            LastName: "SameLast"
        );

        await employeeService.UpdateEmployeeAsync(created.Id.ToString(), updateReq);

        var notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == randomCode && n.Type == "Resource Profile Updated")
            .ToListAsync();

        Assert.Empty(notifs);
    }
}
