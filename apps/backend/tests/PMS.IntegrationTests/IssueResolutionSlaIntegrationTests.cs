using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Services;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Sla.Jobs;
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

    [Fact]
    public async Task IssueResolution_Level1AndLevel2Escalation_AssignsAlertRequestAndChatAccess()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();

        // 1. Resolve an active project and an Assigned Senior Project Manager
        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var spmEmployee = await db.Employees
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Role == "SeniorProjectManager")
            ?? await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Id != project.ProjectManagerId);
        Assert.NotNull(spmEmployee);

        // Ensure SPM is linked as a ProjectTeamMember with role SeniorProjectManager
        var existingSpmMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.ProjectId == project.Id && tm.EmployeeId == spmEmployee.Id && tm.DeletedAtUtc == null);
        if (existingSpmMember == null)
        {
            db.ProjectTeamMembers.Add(new ProjectTeamMember
            {
                ProjectId = project.Id,
                EmployeeId = spmEmployee.Id,
                MemberRole = ProjectMemberRoles.SeniorProjectManager,
                AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-10)),
                AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(100))
            });
            await db.SaveChangesAsync();
        }
        else if (existingSpmMember.MemberRole != ProjectMemberRoles.SeniorProjectManager)
        {
            existingSpmMember.MemberRole = ProjectMemberRoles.SeniorProjectManager;
            await db.SaveChangesAsync();
        }

        // 2. Create an Issue via API
        var issueSubject = $"Escalation Flow Issue {Guid.NewGuid():N}";
        var createRequest = new CreateProjectIssueRequest
        {
            Subject = issueSubject,
            Description = "Testing L1 and L2 escalation alert request delivery and multi-party chat access.",
            IssueType = "Technical Related Issues",
            Priority = "High"
        };

        var response = await _client.PostAsJsonAsync($"/api/v1/projects/{project.Id}/issues", createRequest);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var issueResult = await response.Content.ReadFromJsonAsync<ApiResponse<ProjectIssueDto>>();
        Assert.NotNull(issueResult?.Data);
        var issueId = issueResult.Data.Id;

        // 3. Verify initial Alert: SPM must NOT yet be in AudienceUserIds
        var initialAlert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.IssueId == issueId && a.DeletedAtUtc == null);
        Assert.NotNull(initialAlert);
        Assert.False(string.IsNullOrWhiteSpace(initialAlert.AudienceUserIds));
        Assert.DoesNotContain(spmEmployee.Id.ToString(), initialAlert.AudienceUserIds);

        // 4. Retrieve SLA Instance and scheduled L1 event
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == issueId && i.ActivityType == "Resolution of Issues");
        Assert.NotNull(instance);

        var escL1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(escL1Event);

        // 5. Execute Level 1 Escalation Job
        await worker.ExecuteEscalationAsync(instance.Id, escL1Event.Id, 1);

        // 6. Verify Level 1 Escalation results:
        // A. SPM receives Notification
        var spmNotifs = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.RecipientEmployeeId == spmEmployee.Id && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(spmNotifs);
        var spmNotif = spmNotifs.First();
        Assert.Equal("SLA Escalation", spmNotif.Type);
        Assert.Equal("Critical", spmNotif.Priority);
        Assert.Contains("Level 1", spmNotif.Title);

        // B. SPM is assigned the Alert request (AudienceUserIds, EscalatedTo, Stakeholders)
        var l1Alert = await db.ProjectAlerts
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.Id == initialAlert.Id);
        Assert.NotNull(l1Alert);
        Assert.Contains(spmEmployee.Id.ToString(), l1Alert.AudienceUserIds);
        Assert.Contains(spmEmployee.FirstName, l1Alert.EscalatedTo);
        Assert.Equal("Critical", l1Alert.Priority);
        Assert.Contains("Level 1", l1Alert.HistoryJson);

        if (l1Alert.ServiceEscalationId.HasValue)
        {
            var l1ServiceEsc = await db.ProjectServiceEscalations
                .Include(e => e.Stakeholders)
                .FirstOrDefaultAsync(e => e.Id == l1Alert.ServiceEscalationId.Value);
            Assert.NotNull(l1ServiceEsc);
            Assert.Contains(l1ServiceEsc.Stakeholders, s => s.EmployeeId == spmEmployee.Id);
        }

        // C. SPM adds chat message to discussion thread and confirms status
        var spmComment = "SPM: Reviewing technical blocker with PM and TL.";
        var spmGovernanceUpdate = await notifService.UpdateAlertGovernanceAsync(l1Alert.Id, new UpdateAlertGovernanceRequest
        {
            Status = "In Progress",
            Comment = spmComment
        });
        Assert.NotNull(spmGovernanceUpdate);
        Assert.Contains(spmGovernanceUpdate.Comments, c => c.Text.Contains("SPM: Reviewing"));

        // D. Verify L2 event dynamically scheduled
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(l2Event);

        // 7. Execute Level 2 Escalation Job
        await worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2);

        // 8. Verify Level 2 Escalation results:
        // A. HOD receives Notification and Alert request assigned
        var l2Alert = await db.ProjectAlerts
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.Id == initialAlert.Id);
        Assert.NotNull(l2Alert);
        Assert.Contains("Level 2", l2Alert.HistoryJson);

        var hodNotifs = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Title.Contains("Level 2") && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(hodNotifs);
        var hodRecipientId = hodNotifs.First().RecipientEmployeeId;

        // B. HOD is in AudienceUserIds and EscalatedTo
        Assert.Contains(hodRecipientId.ToString(), l2Alert.AudienceUserIds);

        // C. HOD can see SPM's previous chat
        var parsedL2Comments = JsonSerializer.Deserialize<List<AlertCommentDto>>(l2Alert.ChatJson ?? "[]", new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        Assert.NotNull(parsedL2Comments);
        Assert.Contains(parsedL2Comments, c => c.Text.Contains("SPM: Reviewing"));

        // D. HOD communicates and changes status to Resolved
        var hodComment = "HOD: Infrastructure approved. Issue Resolved.";
        var hodGovernanceUpdate = await notifService.UpdateAlertGovernanceAsync(l2Alert.Id, new UpdateAlertGovernanceRequest
        {
            Status = "Resolved",
            Comment = hodComment
        });
        Assert.NotNull(hodGovernanceUpdate);
        Assert.Equal("Resolved", hodGovernanceUpdate.Status);
        Assert.Contains(hodGovernanceUpdate.Comments, c => c.Text.Contains("HOD: Infrastructure approved"));

        // E. Verify status reflected on all notifications for this issue, plus NotificationCode and Issue details
        var allIssueNotifs = await notifService.GetNotificationsAsync(new NotificationQueryParameters());
        var matchedNotifs = allIssueNotifs.Where(n => n.IssueId == issueId).ToList();
        Assert.NotEmpty(matchedNotifs);
        foreach (var notif in matchedNotifs)
        {
            Assert.Equal("Resolved", notif.Status);
            Assert.False(string.IsNullOrWhiteSpace(notif.NotificationCode));
            Assert.Equal(issueSubject, notif.IssueTitle);
            Assert.Equal("Testing L1 and L2 escalation alert request delivery and multi-party chat access.", notif.IssueDescription);
            Assert.Equal("Technical Related Issues", notif.IssueType);
        }

        // 9. Verify SLA Instance Completed
        var completedInstance = await db.SlaInstances
            .AsNoTracking()
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(completedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);
        Assert.NotNull(completedInstance.CompletedAtUtc);

        // Verify linked Issue status is Resolved
        var finalIssue = await db.ProjectIssues.AsNoTracking().FirstOrDefaultAsync(i => i.Id == issueId);
        Assert.NotNull(finalIssue);
        Assert.Equal("Resolved", finalIssue.Status);
    }
}
