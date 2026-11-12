using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Sla.Models;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class IssueResolutionSlaIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public IssueResolutionSlaIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    [Fact]
    public async Task IssueCreation_StartsSlaTracking_AndCompletion_CancelsPendingJobs()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        // 1. Resolve an active project
        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        // 2. Create an Issue via API
        var createRequest = new CreateProjectIssueRequest
        {
            Subject = $"Integration SLA Test {Guid.NewGuid():N}",
            Description = "Testing end-to-end SLA tracking creation and lifecycle resolution.",
            IssueType = "Technical Related Issues",
            Priority = "High"
        };

        var response = await _client.PostAsJsonAsync($"/api/v1/projects/{project.Id}/issues", createRequest);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var issueResult = await response.Content.ReadFromJsonAsync<ApiResponse<ProjectIssueDto>>();
        Assert.NotNull(issueResult?.Data);
        var issueId = issueResult.Data.Id;

        // 3. Verify SLA Instance created in DB
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == issueId && i.ActivityType == "Resolution of Issues");

        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);
        Assert.Equal("Open", instance.CurrentStage);
        Assert.True(instance.TargetDeadlineUtc > instance.StartedAtUtc);

        // Verify milestone events scheduled (L2 is intentionally NOT pre-scheduled per requirement 3)
        Assert.Contains(instance.Events, e => e.EventType == SlaEventType.Reminder && e.Status == SlaEventStatus.Scheduled);
        Assert.Contains(instance.Events, e => e.EventType == SlaEventType.BreachCheck && e.Status == SlaEventStatus.Scheduled);
        Assert.Contains(instance.Events, e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Scheduled);
        Assert.DoesNotContain(instance.Events, e => e.EventType == SlaEventType.EscalationL2);

        // 4. Find the Alert created for this issue
        var alert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.IssueId == issueId && a.DeletedAtUtc == null);
        Assert.NotNull(alert);

        // 5. Update Alert status to Resolved via API
        var updateRequest = new { status = "Resolved" };
        var updateRes = await _client.PutAsJsonAsync($"/api/v1/projects/{project.Id}/alerts/{alert.Id}/status", updateRequest);
        Assert.Equal(HttpStatusCode.OK, updateRes.StatusCode);

        // 6. Verify SLA Instance Completed and pending jobs cancelled
        var updatedInstance = await db.SlaInstances
            .AsNoTracking()
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.Id == instance.Id);

        Assert.NotNull(updatedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, updatedInstance.Status);
        Assert.NotNull(updatedInstance.CompletedAtUtc);

        // Verify scheduled events were cancelled
        var pendingEvents = updatedInstance.Events
            .Where(e => e.EventType is SlaEventType.Reminder or SlaEventType.BreachCheck or SlaEventType.EscalationL1)
            .ToList();

        Assert.All(pendingEvents, e => Assert.Equal(SlaEventStatus.Cancelled, e.Status));

        // Verify completion event recorded
        Assert.Contains(updatedInstance.Events, e => e.EventType == SlaEventType.Completed && e.Status == SlaEventStatus.Executed);

        // 7. Verify Option C (Reopening - Audit Only): Reopen issue from Resolved to Open
        var reopenRequest = new { status = "Open" };
        var reopenRes = await _client.PutAsJsonAsync($"/api/v1/projects/{project.Id}/alerts/{alert.Id}/status", reopenRequest);
        Assert.Equal(HttpStatusCode.OK, reopenRes.StatusCode);

        var reopenedAlert = await db.ProjectAlerts
            .AsNoTracking()
            .Include(a => a.Issue)
            .FirstOrDefaultAsync(a => a.Id == alert.Id);

        Assert.NotNull(reopenedAlert);
        Assert.Equal("Open", reopenedAlert.Status);
        Assert.NotNull(reopenedAlert.Issue);
        Assert.Equal("Open", reopenedAlert.Issue.Status);
        Assert.Contains("reopened", reopenedAlert.HistoryJson, StringComparison.OrdinalIgnoreCase);

        // Verify no duplicate SLA instance created (Option C preserves previous completed instance)
        var totalInstancesForIssue = await db.SlaInstances
            .CountAsync(i => i.EntityId == issueId && i.ActivityType == "Resolution of Issues");
        Assert.Equal(1, totalInstancesForIssue);
    }
}
