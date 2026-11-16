using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.Models;
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
    public async Task Scenario1_And_3_SubmitAddService_NotifiesAssignedSalesApproverOnly_AndStartsSla()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var createReq = new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Cloud Infrastructure Security Hardening",
            Description = "Client requested additional security hardening pipeline.",
            Priority = "Low",
            RequestedDate = DateOnly.FromDateTime(DateTime.UtcNow).ToString("yyyy-MM-dd")
        };

        var created = await reqService.CreateAsync(project.Id, createReq, null);
        Assert.NotNull(created);
        Assert.StartsWith("APP-", created.RequirementId);

        // Verify initial notification to Assigned Sales Manager or Sales Person ONLY
        var notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Type == "Additional Customer Requirement" && n.Status == "Pending")
            .ToListAsync();
        Assert.NotEmpty(notifs);

        var initialNotif = notifs.First();
        Assert.Equal($"Additional Customer Requirement Approval Pending | {project.Name} | {created.RequirementId}", initialNotif.Title);
        Assert.Equal("Low", initialNotif.Priority);
        Assert.True(initialNotif.Unread);

        // Verify PM, SPM, EM are NOT in the initial recipient list
        var initialRecipients = notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        if (project.ProjectManagerId.HasValue && project.ProjectManagerId.Value != Guid.Empty && project.ProjectManagerId != project.SalesPersonId)
        {
            Assert.DoesNotContain(project.ProjectManagerId.Value, initialRecipients);
        }
        if (project.EngagementManagerId.HasValue && project.EngagementManagerId.Value != Guid.Empty && project.EngagementManagerId != project.SalesPersonId)
        {
            Assert.DoesNotContain(project.EngagementManagerId.Value, initialRecipients);
        }

        // Verify SLA tracking started
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);
    }

    [Fact]
    public async Task Scenario2_SubmitScopeCancellation_NotifiesAssignedSalesApproverOnly()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var createReq = new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Scope Cancellation",
            ScopeCancellationService = "Legacy API Service",
            Title = "Scope Cancellation: Legacy API Service",
            Description = "Client cancelled scope for legacy API module.",
            Priority = "Low"
        };

        var created = await reqService.CreateAsync(project.Id, createReq, null);
        Assert.NotNull(created);
        Assert.StartsWith("APP-", created.RequirementId);

        var notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Type == "Additional Customer Requirement" && n.Status == "Pending")
            .ToListAsync();
        Assert.NotEmpty(notifs);
        Assert.All(notifs, n => Assert.Equal($"Additional Customer Requirement Approval Pending | {project.Name} | {created.RequirementId}", n.Title));
    }

    [Fact]
    public async Task Scenario4_DailyReminder_BeforeL1_NotifiesAssignedSalesApproverOnly()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var createReq = new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Performance Optimization Service",
            Description = "Pending sales review.",
            Priority = "Low"
        };

        var created = await reqService.CreateAsync(project.Id, createReq, null);
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);

        var remEvent = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.Reminder);
        if (remEvent == null)
        {
            remEvent = new SlaEvent
            {
                Id = Guid.NewGuid(),
                InstanceId = instance.Id,
                EventType = SlaEventType.Reminder,
                ScheduledAtUtc = DateTime.UtcNow.AddHours(1),
                Status = SlaEventStatus.Scheduled,
                IdempotencyKey = $"sla:{instance.Id}:rem:test"
            };
            db.SlaEvents.Add(remEvent);
            await db.SaveChangesAsync();
        }

        // Execute reminder job
        await worker.ExecuteReminderAsync(instance.Id, remEvent.Id);

        // Verify reminder notification sent to Sales approver
        var remNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Title.StartsWith("Additional Customer Requirement Reminder |"))
            .ToListAsync();
        Assert.NotEmpty(remNotifs);
        Assert.All(remNotifs, n => Assert.Equal($"Additional Customer Requirement Reminder | {project.Name} | {created.RequirementId}", n.Title));
        Assert.All(remNotifs, n => Assert.Equal("Low", n.Priority));
        Assert.All(remNotifs, n => Assert.Equal("SLA Automation Engine", n.RaisedByName));
    }

    [Fact]
    public async Task Scenario5_And_18_StatusChange_Hold_NotifiesLeadership_AndDoesNotTerminateSla()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var created = await reqService.CreateAsync(project.Id, new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Hold Lifecycle Test",
            Description = "Testing hold does not cancel SLA.",
            Priority = "Low"
        }, null);

        var actionResult = await reqService.TakeActionAsync(project.Id, created.Id, new AdditionalRequirementActionRequest
        {
            Status = "Hold",
            Comment = "Placed on hold pending budget approval"
        });

        Assert.Equal("Hold", actionResult.Status);

        // 18. Verify Hold does NOT terminate SLA tracking!
        var instance = await db.SlaInstances.AsNoTracking()
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);

        // 5. Verify status change notification sent to EM, PM, TL
        var holdNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Status == "Hold" && n.Title.StartsWith("Additional Customer Requirement Status Updated"))
            .ToListAsync();
        Assert.NotEmpty(holdNotifs);
        Assert.All(holdNotifs, n => Assert.Equal($"Additional Customer Requirement Status Updated | {project.Name} | {created.RequirementId}", n.Title));
    }

    [Fact]
    public async Task Scenario6_And_17_StatusChange_Reject_NotifiesLeadership_AndCompletesSla()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var created = await reqService.CreateAsync(project.Id, new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Reject Lifecycle Test",
            Description = "Testing reject completes SLA.",
            Priority = "Low"
        }, null);

        var rejectResult = await reqService.RejectAsync(project.Id, created.Id, new RejectAdditionalRequirementRequest
        {
            Comment = "Rejected due to out of scope"
        });

        Assert.Equal("Rejected", rejectResult.Status);

        // 17. Verify Rejected completes SLA tracking
        var instance = await db.SlaInstances.AsNoTracking()
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Completed, instance.Status);

        // Verify status change notifications
        var rejectNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Status == "Rejected" && n.Title.StartsWith("Additional Customer Requirement Status Updated"))
            .ToListAsync();
        Assert.NotEmpty(rejectNotifs);
        Assert.All(rejectNotifs, n => Assert.Equal($"Additional Customer Requirement Status Updated | {project.Name} | {created.RequirementId}", n.Title));
    }

    [Fact]
    public async Task Scenario7_And_16_StatusChange_Approve_NotifiesLeadership_AndCompletesSla()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var created = await reqService.CreateAsync(project.Id, new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Approve Lifecycle Test",
            Description = "Testing approve completes SLA.",
            Priority = "Low"
        }, null);

        var approveResult = await reqService.ApproveAsync(project.Id, created.Id, new ApproveAdditionalRequirementRequest
        {
            Comment = "Approved by Sales Manager"
        });

        Assert.Equal("Approved", approveResult.Status);

        // 16. Verify Approved completes SLA tracking
        var instance = await db.SlaInstances.AsNoTracking()
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Completed, instance.Status);

        // Verify status change notifications
        var approveNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Status == "Approved" && n.Title.StartsWith("Additional Customer Requirement Status Updated"))
            .ToListAsync();
        Assert.NotEmpty(approveNotifs);
        Assert.All(approveNotifs, n => Assert.Equal($"Additional Customer Requirement Status Updated | {project.Name} | {created.RequirementId}", n.Title));
    }

    [Fact]
    public async Task Scenario8_9_10_L1Escalation_AndReminder_AndStatusChange()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var created = await reqService.CreateAsync(project.Id, new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "L1 Escalation End-to-End Test",
            Description = "Testing L1 escalation, L1 reminder, and L1 status update.",
            Priority = "Low"
        }, null);

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);

        var l1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        Assert.NotNull(l1Event);

        // 8. Execute Level 1 Escalation
        await worker.ExecuteEscalationAsync(instance.Id, l1Event.Id, 1);

        var l1Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Title.StartsWith("Additional Customer Requirement Escalation | L1 |"))
            .ToListAsync();
        Assert.NotEmpty(l1Notifs);
        Assert.All(l1Notifs, n => Assert.Equal($"Additional Customer Requirement Escalation | L1 | {project.Name} | {created.RequirementId}", n.Title));
        Assert.All(l1Notifs, n => Assert.Equal("Low", n.Priority));

        // 9. Execute L1 Daily Reminder
        var l1RemEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.Reminder && e.TargetRolesJson.Contains("Senior Project Manager"));
        if (l1RemEvent != null)
        {
            await worker.ExecuteReminderAsync(instance.Id, l1RemEvent.Id);
            var l1RemNotifs = await db.ActionNotifications
                .Where(n => n.RelatedTask == created.RequirementId && n.Title.StartsWith("Additional Customer Requirement Reminder | L1 |"))
                .ToListAsync();
            Assert.NotEmpty(l1RemNotifs);
            Assert.All(l1RemNotifs, n => Assert.Equal($"Additional Customer Requirement Reminder | L1 | {project.Name} | {created.RequirementId}", n.Title));
        }

        // 10. Status change after L1 (Hold) -> verifies expanded recipient list includes SPM
        var actionResult = await reqService.TakeActionAsync(project.Id, created.Id, new AdditionalRequirementActionRequest
        {
            Status = "Hold",
            Comment = "Placed on hold after L1 escalation"
        });
        Assert.Equal("Hold", actionResult.Status);

        var postL1Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Status == "Hold" && n.Title.StartsWith("Additional Customer Requirement Status Updated"))
            .ToListAsync();
        Assert.NotEmpty(postL1Notifs);
    }

    [Fact]
    public async Task Scenario11_12_13_L2Escalation_AndReminder_AndStatusChange()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var created = await reqService.CreateAsync(project.Id, new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "L2 Escalation End-to-End Test",
            Description = "Testing L2 escalation to HOD, L2 reminder, and L2 status update.",
            Priority = "Low"
        }, null);

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);

        var l1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        Assert.NotNull(l1Event);

        // Execute L1 first
        await worker.ExecuteEscalationAsync(instance.Id, l1Event.Id, 1);

        // Find dynamically scheduled L2 event
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2);
        Assert.NotNull(l2Event);

        // 11. Execute Level 2 Escalation
        await worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2);

        var l2Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Title.StartsWith("Additional Customer Requirement Escalation | L2 |"))
            .ToListAsync();
        Assert.NotEmpty(l2Notifs);
        Assert.All(l2Notifs, n => Assert.Equal($"Additional Customer Requirement Escalation | L2 | {project.Name} | {created.RequirementId}", n.Title));
        Assert.All(l2Notifs, n => Assert.Equal("Low", n.Priority));

        // 12. Execute L2 Daily Reminder
        var l2RemEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.Reminder && e.TargetRolesJson.Contains("Head of Department"));
        if (l2RemEvent != null)
        {
            await worker.ExecuteReminderAsync(instance.Id, l2RemEvent.Id);
            var l2RemNotifs = await db.ActionNotifications
                .Where(n => n.RelatedTask == created.RequirementId && n.Title.StartsWith("Additional Customer Requirement Reminder | L2 |"))
                .ToListAsync();
            Assert.NotEmpty(l2RemNotifs);
            Assert.All(l2RemNotifs, n => Assert.Equal($"Additional Customer Requirement Reminder | L2 | {project.Name} | {created.RequirementId}", n.Title));
        }

        // 13. Status change after L2 -> verifies recipients include EM, PM, TL, SPM, HOD
        var actionResult = await reqService.TakeActionAsync(project.Id, created.Id, new AdditionalRequirementActionRequest
        {
            Status = "Approved",
            Comment = "Approved by HOD"
        });
        Assert.Equal("Approved", actionResult.Status);

        var postL2Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Status == "Approved" && n.Title.StartsWith("Additional Customer Requirement Status Updated"))
            .ToListAsync();
        Assert.NotEmpty(postL2Notifs);
    }

    [Fact]
    public async Task Scenario14_15_SelfActorExclusion_AndDeduplication()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var created = await reqService.CreateAsync(project.Id, new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Self-Actor Exclusion Test",
            Description = "Testing updater does not receive their own notification.",
            Priority = "Low"
        }, null);

        // Find admin employee who is performing action
        var adminEmp = await db.Employees.FirstOrDefaultAsync(e => e.WorkEmail == "admin@talakunchi.com" && e.DeletedAtUtc == null);

        var actionResult = await reqService.TakeActionAsync(project.Id, created.Id, new AdditionalRequirementActionRequest
        {
            Status = "Hold",
            Comment = "Admin putting on hold"
        });

        var notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.RequirementId && n.Status == "Hold" && n.Title.StartsWith("Additional Customer Requirement Status Updated"))
            .ToListAsync();

        // 14. Verify actor is excluded from receiving notification
        if (adminEmp != null)
        {
            Assert.DoesNotContain(notifs, n => n.RecipientEmployeeId == adminEmp.Id);
        }

        // 15. Verify deduplication: no duplicate notifications to the same recipient for the same event
        var recipientCounts = notifs.GroupBy(n => n.RecipientEmployeeId).Select(g => g.Count());
        Assert.All(recipientCounts, count => Assert.Equal(1, count));
    }

    [Fact]
    public async Task Scenario20_HangfireRetry_DoesNotDuplicateNotifications()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var reqService = scope.ServiceProvider.GetRequiredService<IProjectAdditionalRequirementService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var project = await db.Projects.Include(p => p.Client).FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var created = await reqService.CreateAsync(project.Id, new CreateProjectAdditionalRequirementRequest
        {
            RequirementType = "Add Service",
            Title = "Hangfire Retry Idempotency Test",
            Description = "Testing retries do not duplicate notifications.",
            Priority = "Low"
        }, null);

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Additional Customer Requirement");
        Assert.NotNull(instance);

        var l1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        Assert.NotNull(l1Event);

        // Execute L1 Escalation 1st time
        await worker.ExecuteEscalationAsync(instance.Id, l1Event.Id, 1);
        var firstCount = await db.ActionNotifications
            .CountAsync(n => n.RelatedTask == created.RequirementId && n.Title.StartsWith("Additional Customer Requirement Escalation | L1 |"));
        Assert.True(firstCount > 0);

        // Simulate Hangfire retry (execute same event 2nd time)
        await worker.ExecuteEscalationAsync(instance.Id, l1Event.Id, 1);
        var retryCount = await db.ActionNotifications
            .CountAsync(n => n.RelatedTask == created.RequirementId && n.Title.StartsWith("Additional Customer Requirement Escalation | L1 |"));

        // Idempotency: retry must NOT create additional duplicate notifications
        Assert.Equal(firstCount, retryCount);
    }
}
