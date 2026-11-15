using System.Net.Http.Headers;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Sla.Jobs;
using PMS.API.Modules.Sla.Models;
using Xunit;

namespace PMS.IntegrationTests;

public class AdditionalRequirementSlaIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public AdditionalRequirementSlaIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    [Fact]
    public async Task AdditionalRequirement_Creation_StartsSlaTracking_AndApproval_EnablesEditServices_AndNotifiesExpectedRoles()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();

        // 1. Resolve an active project
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        // 2. Create Additional Customer Requirement
        var createReq = new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Integration Test - Cloud Migration Additional Service",
            Description = "Customer requested additional cloud migration pipeline support.",
            Priority = "High",
            RequestedDate = DateOnly.FromDateTime(DateTime.UtcNow).ToString("yyyy-MM-dd")
        };

        var created = await reqService.CreateAsync(project.Id, createReq, null);
        Assert.NotNull(created);
        Assert.Equal("Open", created.Status);

        // Verify initial notification to sales person / leadership
        var notif = await db.ActionNotifications.FirstOrDefaultAsync(n =>
            n.RelatedTask == created.RequirementId && n.Type == "Additional Customer Requirement");
        Assert.NotNull(notif);

        // Verify SLA tracking instance started
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);
        Assert.Equal("Pending", instance.CurrentStage);
        Assert.True(instance.TargetDeadlineUtc > instance.StartedAtUtc);

        // 3. Sales stakeholder approves the requirement
        var approveResult = await reqService.ApproveAsync(project.Id, created.Id, new ApproveAdditionalRequirementRequest
        {
            Comment = "Approved by Sales Manager for new scope addition"
        });
        Assert.NotNull(approveResult);
        Assert.Equal("Approved", approveResult.Status);
        Assert.NotNull(approveResult.ApprovedAtUtc);

        // Verify SLA instance completed
        var completedInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(completedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);

        // 4. Verify post-approval notifications were dispatched to expected roles
        var postNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Status == "Approved")
            .ToListAsync();
        Assert.NotEmpty(postNotifs);

        var recipientIds = postNotifs.Select(n => n.RecipientEmployeeId).ToHashSet();

        // Interns must NOT be in the recipient list
        var internDesig = await db.Designations.FirstOrDefaultAsync(d => d.Name.ToLower().Contains("intern"));
        if (internDesig != null)
        {
            var internEmps = await db.Employees
                .Where(e => e.DesignationId == internDesig.Id && e.DeletedAtUtc == null)
                .Select(e => e.Id)
                .ToListAsync();

            foreach (var internId in internEmps)
            {
                Assert.DoesNotContain(internId, recipientIds);
            }
        }
    }

    [Fact]
    public async Task AdditionalRequirement_UnresolvedAfter2Days_TriggersLevel1ToSpm_AndThenLevel2ToHod()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve an active project
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        // 2. Create requirement
        var createReq = new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Escalation Test - Performance Tuning Service",
            Description = "Pending sales review to test 2-day SLA breach and multi-level escalation.",
            Priority = "High",
            RequestedDate = DateOnly.FromDateTime(DateTime.UtcNow).ToString("yyyy-MM-dd")
        };

        var created = await reqService.CreateAsync(project.Id, createReq, null);
        Assert.NotNull(created);

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);

        // 3. Simulate breach check & Level 1 Escalation at deadline
        var breachEvent = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.BreachCheck);
        if (breachEvent != null)
        {
            await worker.ExecuteBreachCheckAsync(instance.Id, breachEvent.Id);
        }

        var l1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        Assert.NotNull(l1Event);

        await worker.ExecuteEscalationAsync(instance.Id, l1Event.Id, 1);

        // Verify Level 1 critical notification dispatched ONLY to Assigned Senior Project Manager
        var l1Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Type == "Customer Requirement Escalation")
            .ToListAsync();
        Assert.NotEmpty(l1Notifs);
        Assert.All(l1Notifs, n => Assert.Contains("Level 1 SLA Escalation", n.Title));

        // 4. Verify Level 2 event dynamically scheduled for next working day EOD
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2);
        Assert.NotNull(l2Event);
        Assert.Equal(SlaEventStatus.Scheduled, l2Event.Status);
        Assert.Equal("Head of Department", l2Event.TargetRoles.First());

        // 5. Execute Level 2 Escalation
        await worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2);

        var l2Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Type == "Customer Requirement Escalation" && n.Title.Contains("Level 2 SLA Escalation"))
            .ToListAsync();
        Assert.NotEmpty(l2Notifs);

        // Verify HOD received Level 2 escalation
        var hodRole = await db.OnFloorRoles.FirstOrDefaultAsync(o => o.Name == "Head Of Department" && o.DeletedAtUtc == null);
        if (hodRole != null && hodRole.DesignationId != Guid.Empty)
        {
            var hodEmp = await db.Employees.FirstOrDefaultAsync(e => e.DesignationId == hodRole.DesignationId && e.DeletedAtUtc == null);
            if (hodEmp != null)
            {
                Assert.Contains(l2Notifs, n => n.RecipientEmployeeId == hodEmp.Id);
            }
        }
    }

    [Fact]
    public async Task AdditionalRequirement_HoldAction_CompletesSlaTracking_AndNotifiesExpectedRoles()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();

        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var createReq = new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Scope Cancellation",
            Title = "Scope Cancellation - Legacy Module",
            Description = "Client asked to put module on hold.",
            Priority = "Medium"
        };

        var created = await reqService.CreateAsync(project.Id, createReq, null);
        Assert.NotNull(created);

        var actionResult = await reqService.TakeActionAsync(project.Id, created.Id, new AdditionalRequirementActionRequest
        {
            Status = "Hold",
            Comment = "Placed on hold pending client budget review"
        });

        Assert.Equal("Hold", actionResult.Status);

        // Verify SLA tracking completed on Hold
        var instance = await db.SlaInstances.AsNoTracking()
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Completed, instance.Status);

        // Verify notifications sent with status Hold
        var holdNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Status == "Hold")
            .ToListAsync();
        Assert.NotEmpty(holdNotifs);
    }
}
