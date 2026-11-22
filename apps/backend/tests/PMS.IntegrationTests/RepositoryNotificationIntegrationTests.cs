using System.Net.Http.Headers;
using System.Text;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Repository.Services;
using Xunit;

namespace PMS.IntegrationTests;

public class RepositoryNotificationIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public RepositoryNotificationIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(b =>
            b.UseSetting("Database:AutoMigrate", "false"));
    }

    [Fact]
    public async Task DocumentUpload_DispatchesNotification_ToSelectedDepartmentEmployees()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var repoService = scope.ServiceProvider.GetRequiredService<IRepositoryService>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        // 1. Find an active department that has active employees
        var dept = await db.Departments
            .Where(d => d.IsActive)
            .FirstOrDefaultAsync(d => db.Employees.Any(e => e.DeletedAtUtc == null &&
                (e.Status == null || e.Status.ToLower().StartsWith("active")) &&
                (e.DepartmentId == d.Id || (e.SubDepartmentRef != null && e.SubDepartmentRef.DepartmentId == d.Id))));

        Assert.NotNull(dept);

        var deptEmployees = await db.Employees
            .Include(e => e.SubDepartmentRef)
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || e.Status.ToLower().StartsWith("active")))
            .Where(e => e.DepartmentId == dept.Id || (e.SubDepartmentRef != null && e.SubDepartmentRef.DepartmentId == dept.Id))
            .ToListAsync();

        Assert.NotEmpty(deptEmployees);

        // 2. Prepare test file
        var fileContent = "Test PDF document content for repository notification test"u8.ToArray();
        var fileName = "TestRepoDoc-" + Guid.NewGuid().ToString("N")[..8] + ".pdf";
        var stream = new MemoryStream(fileContent);
        var formFile = new FormFile(stream, 0, fileContent.Length, "file", fileName)
        {
            Headers = new HeaderDictionary(),
            ContentType = "application/pdf"
        };

        var uploaderName = "Repo Uploader User";

        // 3. Upload document
        var result = await repoService.UploadDocumentAsync(
            category: "Tech",
            file: formFile,
            userEmailOrName: uploaderName,
            departmentIds: new List<Guid> { dept.Id }
        );

        Assert.NotNull(result);

        // 4. Verify notifications generated in DB
        var notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == fileName && n.Type == "Document Uploaded")
            .ToListAsync();

        Assert.NotEmpty(notifs);

        // Every employee in the selected department must receive a notification
        foreach (var emp in deptEmployees)
        {
            var empNotif = notifs.FirstOrDefault(n => n.RecipientEmployeeId == emp.Id);
            Assert.NotNull(empNotif);
            Assert.Equal("Document is Uploaded", empNotif.Title);
            Assert.Equal("Upload", empNotif.Status);
            Assert.Equal("-", empNotif.Priority);
            Assert.Equal("-", empNotif.ProjectName);
            Assert.Equal(uploaderName, empNotif.RaisedByName);
        }

        // 5. Verify DTO mapping through notifService
        var dtos = await notifService.GetNotificationsAsync(new NotificationQueryParameters
        {
            Search = fileName
        });

        var targetDto = dtos.FirstOrDefault(d => d.RelatedTask == fileName && d.Title == "Document is Uploaded");
        Assert.NotNull(targetDto);
        Assert.Equal("Document is Uploaded", targetDto.Title);
        Assert.Equal("Upload", targetDto.Status);
        Assert.Equal("-", targetDto.Priority);
        Assert.Equal("-", targetDto.RelatedProject);
        Assert.Equal(uploaderName, targetDto.RaisedBy);
    }
}
