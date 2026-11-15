using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Customers.DTOs;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class CustomerNotificationIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public CustomerNotificationIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(b =>
            b.UseSetting("Database:AutoMigrate", "false"));
        _client = _factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    [Fact]
    public async Task CustomerOnboarding_DispatchesNotification_ToEmLeadership_And_AssignedManagers()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var emCandidate = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")));
        Assert.NotNull(emCandidate);
        var emName = $"{emCandidate.FirstName} {emCandidate.LastName}".Trim();

        var clientName = "CustomerTest-" + Guid.NewGuid().ToString("N")[..8];
        var req = new CreateClientRequest(
            Name: clientName,
            Industry: "Technology",
            Logo: null,
            ContactEmail: null,
            ClientType: "NEW",
            EngagementManager: emName,
            ContactName: null,
            ContactPhone: null,
            ContactDesignation: null,
            ContactType: null,
            City: null,
            Country: null,
            BusinessType: null,
            Notes: null,
            KycDocumentName: null,
            SubVentures: new List<SubVentureInput>
            {
                new SubVentureInput(Name: clientName + "-SV1", Contacts: null)
            },
            Contacts: null
        );

        var createRes = await _client.PostAsJsonAsync("/api/v1/clients", req);
        Assert.Equal(HttpStatusCode.Created, createRes.StatusCode);
        var created = await createRes.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
        Assert.NotNull(created?.Data);

        // Verify customer onboarded notifications
        var notifs = await db.ActionNotifications
            .Where(n => n.Title == $"Customer Onboarded: {clientName}" && n.Type == "Customer Onboarded")
            .ToListAsync();

        Assert.NotEmpty(notifs);

        // Verify EM candidate received notification
        var emNotif = notifs.FirstOrDefault(n => n.RecipientEmployeeId == emCandidate.Id);
        Assert.NotNull(emNotif);
        Assert.Equal("Low", emNotif.Priority);
        Assert.Equal("Created", emNotif.Status);
        Assert.Equal("-", emNotif.ProjectName);

        // Verify DTO projection maps RelatedProject as "-"
        var dtos = await notifService.GetNotificationsAsync(new NotificationQueryParameters
        {
            Search = clientName
        });
        var targetDto = dtos.FirstOrDefault(d => d.Title == $"Customer Onboarded: {clientName}");
        Assert.NotNull(targetDto);
        Assert.Equal("-", targetDto.RelatedProject);
        Assert.Equal("Low", targetDto.Priority);
        Assert.Equal("Created", targetDto.Status);
    }

    [Fact]
    public async Task CustomerProfileEdit_DispatchesNotification_WithEditedStatusAndTitle()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var emCandidate = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")));
        Assert.NotNull(emCandidate);
        var emName = $"{emCandidate.FirstName} {emCandidate.LastName}".Trim();

        var clientName = "CustomerEdit-" + Guid.NewGuid().ToString("N")[..8];
        var req = new CreateClientRequest(
            Name: clientName,
            Industry: "Healthcare",
            Logo: null,
            ContactEmail: null,
            ClientType: "NEW",
            EngagementManager: emName,
            ContactName: null,
            ContactPhone: null,
            ContactDesignation: null,
            ContactType: null,
            City: null,
            Country: null,
            BusinessType: null,
            Notes: null,
            KycDocumentName: null,
            SubVentures: null,
            Contacts: null
        );

        var createRes = await _client.PostAsJsonAsync("/api/v1/clients", req);
        Assert.Equal(HttpStatusCode.Created, createRes.StatusCode);
        var created = await createRes.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
        Assert.NotNull(created?.Data);
        var clientId = created!.Data!.Id;

        // Now edit customer profile (e.g. Industry and Notes)
        var updateReq = new UpdateClientRequest(
            Name: null,
            Industry: "Finance & Banking",
            Logo: null,
            ContactEmail: null,
            ClientType: null,
            Status: null,
            EngagementManager: null,
            ContactName: null,
            ContactPhone: null,
            ContactDesignation: null,
            ContactType: null,
            City: null,
            Country: null,
            BusinessType: null,
            Notes: "Updated notes for profile",
            KycDocumentName: null,
            SubVentures: null,
            Contacts: null
        );

        var updateRes = await _client.PutAsJsonAsync($"/api/v1/clients/{clientId}", updateReq);
        Assert.Equal(HttpStatusCode.OK, updateRes.StatusCode);

        // Verify "{Customer name} is edited" notification
        var expectedTitle = $"{clientName} is edited";
        var editNotifs = await db.ActionNotifications
            .Where(n => n.Title == expectedTitle && n.Type == "Customer Profile Edited")
            .ToListAsync();

        Assert.NotEmpty(editNotifs);
        var emNotif = editNotifs.FirstOrDefault(n => n.RecipientEmployeeId == emCandidate.Id);
        Assert.NotNull(emNotif);
        Assert.Equal("Edited", emNotif.Status);
        Assert.Equal("Low", emNotif.Priority);
        Assert.Equal("-", emNotif.ProjectName);
    }

    [Fact]
    public async Task SubVentureEdit_DispatchesNotification_WithSubVentureEditedTitle()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var emCandidate = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")));
        Assert.NotNull(emCandidate);
        var emName = $"{emCandidate.FirstName} {emCandidate.LastName}".Trim();

        var clientName = "SvEditTest-" + Guid.NewGuid().ToString("N")[..8];
        var svOriginalName = clientName + "-SV-Initial";
        var req = new CreateClientRequest(
            Name: clientName,
            Industry: "Retail",
            Logo: null,
            ContactEmail: null,
            ClientType: "NEW",
            EngagementManager: emName,
            ContactName: null,
            ContactPhone: null,
            ContactDesignation: null,
            ContactType: null,
            City: null,
            Country: null,
            BusinessType: null,
            Notes: null,
            KycDocumentName: null,
            SubVentures: new List<SubVentureInput>
            {
                new SubVentureInput(Name: svOriginalName, Contacts: null, Notes: "Initial Notes")
            },
            Contacts: null
        );

        var createRes = await _client.PostAsJsonAsync("/api/v1/clients", req);
        Assert.Equal(HttpStatusCode.Created, createRes.StatusCode);
        var created = await createRes.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
        Assert.NotNull(created?.Data);
        var clientId = created!.Data!.Id;
        Assert.NotEmpty(created.Data.SubVentures);
        var svId = created.Data.SubVentures[0].Id;

        // Edit subventure name and notes
        var svNewName = clientName + "-SV-Renamed";
        var updateReq = new UpdateClientRequest(
            Name: null,
            Industry: null,
            Logo: null,
            ContactEmail: null,
            ClientType: null,
            Status: null,
            EngagementManager: null,
            ContactName: null,
            ContactPhone: null,
            ContactDesignation: null,
            ContactType: null,
            City: null,
            Country: null,
            BusinessType: null,
            Notes: null,
            KycDocumentName: null,
            SubVentures: new List<SubVentureInput>
            {
                new SubVentureInput(Name: svNewName, Contacts: null, Notes: "Updated SV Notes", Id: svId)
            },
            Contacts: null
        );

        var updateRes = await _client.PutAsJsonAsync($"/api/v1/clients/{clientId}", updateReq);
        Assert.Equal(HttpStatusCode.OK, updateRes.StatusCode);

        // Verify "{Subventure Name} is edited" notification
        var expectedTitle = $"{svNewName} is edited";
        var svNotifs = await db.ActionNotifications
            .Where(n => n.Title == expectedTitle && n.Type == "Sub-Venture Profile Edited")
            .ToListAsync();

        Assert.NotEmpty(svNotifs);
        var emNotif = svNotifs.FirstOrDefault(n => n.RecipientEmployeeId == emCandidate.Id);
        Assert.NotNull(emNotif);
        Assert.Equal("Edited", emNotif.Status);
        Assert.Equal("Low", emNotif.Priority);
        Assert.Equal("-", emNotif.ProjectName);
    }

    [Fact]
    public async Task CustomerManagerChanged_DispatchesNotification_WithExactTitleFormat()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var emCandidates = await db.Employees
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))
            .Take(2)
            .ToListAsync();
        Assert.True(emCandidates.Count >= 2, "Expected at least 2 active employees in test db");

        var prevEm = $"{emCandidates[0].FirstName} {emCandidates[0].LastName}".Trim();
        var newEm = $"{emCandidates[1].FirstName} {emCandidates[1].LastName}".Trim();

        var clientName = "MgrChangeTest-" + Guid.NewGuid().ToString("N")[..8];
        var req = new CreateClientRequest(
            Name: clientName,
            Industry: "Education",
            Logo: null,
            ContactEmail: null,
            ClientType: "NEW",
            EngagementManager: prevEm,
            ContactName: null,
            ContactPhone: null,
            ContactDesignation: null,
            ContactType: null,
            City: null,
            Country: null,
            BusinessType: null,
            Notes: null,
            KycDocumentName: null,
            SubVentures: null,
            Contacts: null
        );

        var createRes = await _client.PostAsJsonAsync("/api/v1/clients", req);
        Assert.Equal(HttpStatusCode.Created, createRes.StatusCode);
        var created = await createRes.Content.ReadFromJsonAsync<ApiResponse<ClientDto>>();
        Assert.NotNull(created?.Data);
        var clientId = created!.Data!.Id;

        // Update manager to newEm
        var updateReq = new UpdateClientRequest(
            Name: null,
            Industry: null,
            Logo: null,
            ContactEmail: null,
            ClientType: null,
            Status: null,
            EngagementManager: newEm,
            ContactName: null,
            ContactPhone: null,
            ContactDesignation: null,
            ContactType: null,
            City: null,
            Country: null,
            BusinessType: null,
            Notes: null,
            KycDocumentName: null,
            SubVentures: null,
            Contacts: null
        );

        var updateRes = await _client.PutAsJsonAsync($"/api/v1/clients/{clientId}", updateReq);
        Assert.Equal(HttpStatusCode.OK, updateRes.StatusCode);

        // Verify "{Engagement Manager name} of the Customer ({Customer Name}) change to the {Changed Engagement Manager Name}"
        var expectedTitle = $"{prevEm} of the Customer ({clientName}) change to the {newEm}";
        var notifs = await db.ActionNotifications
            .Where(n => n.Title == expectedTitle && n.Type == "Engagement Manager Changed")
            .ToListAsync();

        Assert.NotEmpty(notifs);
        var notif = notifs[0];
        Assert.Equal("Edited", notif.Status);
        Assert.Equal("Low", notif.Priority);
        Assert.Equal("-", notif.ProjectName);
    }

    [Fact]
    public async Task WbsCreated_DispatchesNotification_ToEmPmoHod_WithCreatedStatusAndDashProjectName()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        var emSubDeptId = Guid.Parse("63bc0f54-4d35-4279-bb62-4daeff6ceeaa");
        var pmoSubDeptId = Guid.Parse("fd84aa38-11ef-46af-ade7-241f2a2c08fd");

        // Find candidate with EM/PMO and HOD
        var candidates = await db.Employees
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))
            .ToListAsync();

        var desigIds = candidates.Where(e => e.DesignationId.HasValue).Select(e => e.DesignationId!.Value).Distinct().ToList();
        var floorRoleList = await db.OnFloorRoles
            .Where(r => desigIds.Contains(r.DesignationId) && r.DeletedAtUtc == null)
            .Select(r => new { r.DesignationId, r.Name })
            .ToListAsync();

        var floorRoles = floorRoleList.ToDictionary(r => r.DesignationId, r => r.Name);

        var hodEmPmo = candidates.FirstOrDefault(e =>
        {
            var subDept = (e.SubDepartment ?? e.SubDepartmentRef?.Name ?? "").Trim().ToLowerInvariant();
            var isEmOrPmo = e.SubDepartmentId == emSubDeptId || e.SubDepartmentId == pmoSubDeptId ||
                            subDept.Contains("engagement manager") || subDept.Contains("project management office") || subDept == "em" || subDept == "pmo";
            var roleName = (e.DesignationId.HasValue && floorRoles.TryGetValue(e.DesignationId.Value, out var rn) ? rn : e.Role ?? "").Trim().ToLowerInvariant();
            var isHod = (roleName == "head of department" || roleName == "hod" || roleName.Contains("head of department")) && !roleName.Contains("team leader");
            return isEmOrPmo && isHod;
        });

        Assert.NotNull(hodEmPmo);

        var proj = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(proj);

        var testCreatedBy = "WbsCreator User";

        await notifService.NotifyWbsCreatedAsync(proj.Id, proj.Name, "WBS-123", proj.ProjectCode, testCreatedBy);

        var expectedTitle = $"WBS or the Project is Created with the {proj.Name}";
        var notifs = await db.ActionNotifications
            .Where(n => n.Title == expectedTitle && n.Type == "WBS Created")
            .ToListAsync();

        Assert.NotEmpty(notifs);
        var targetNotif = notifs.FirstOrDefault(n => n.RecipientEmployeeId == hodEmPmo.Id);
        Assert.NotNull(targetNotif);
        Assert.Equal("Created", targetNotif.Status);
        Assert.Equal("Low", targetNotif.Priority);
        Assert.Equal("-", targetNotif.ProjectName);
        Assert.Equal(testCreatedBy, targetNotif.RaisedByName);

        // Verify DTO projection maps RelatedProject as "-"
        var dtos = await notifService.GetNotificationsAsync(new NotificationQueryParameters
        {
            Search = proj.Name
        });
        var dto = dtos.FirstOrDefault(d => d.Title == expectedTitle);
        Assert.NotNull(dto);
        Assert.Equal("-", dto.RelatedProject);
        Assert.Equal("Low", dto.Priority);
        Assert.Equal("Created", dto.Status);
        Assert.Equal(testCreatedBy, dto.RaisedBy);
    }
}
