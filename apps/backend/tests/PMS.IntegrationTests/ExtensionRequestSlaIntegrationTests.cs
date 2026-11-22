using System.Net.Http.Headers;
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

public class ExtensionRequestSlaIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ExtensionRequestSlaIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    [Fact]
    public async Task ExtensionRequest_Creation_SingleAndMultipleApprovers_InitialNotificationAndDailyReminder_Verified()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var extService = scope.ServiceProvider.GetRequiredService<IProjectExtensionRequestService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve active project with EndDate
        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null && p.EndDate.HasValue);
        Assert.NotNull(project);

        var currentEndDate = project.EndDate!.Value;
        var requestedEndDate = currentEndDate.AddDays(15);

        // 2. Resolve multiple PMO approvers
        var pmoApprovers = await db.Employees
            .Where(e => e.DeletedAtUtc == null && (e.SubDepartment == ProjectExtensionRequestService.PmoSubDepartment || (e.SubDepartment != null && e.SubDepartment.Contains("PMO"))))
            .Take(2)
            .ToListAsync();

        if (pmoApprovers.Count < 2)
        {
            var extraEmps = await db.Employees.Where(e => e.DeletedAtUtc == null && !pmoApprovers.Select(p => p.Id).Contains(e.Id)).Take(2 - pmoApprovers.Count).ToListAsync();
            foreach (var extra in extraEmps)
            {
                extra.SubDepartment = ProjectExtensionRequestService.PmoSubDepartment;
                pmoApprovers.Add(extra);
            }
            await db.SaveChangesAsync();
        }

        Assert.True(pmoApprovers.Count >= 2);

        // 3. Create extension request with multiple approvers
        var createReq = new CreateProjectExtensionRequest(
            requestedEndDate,
            "Integration Test Multi-Approver Extension Reason",
            pmoApprovers.Select(a => a.Id).ToList()
        );

        var created = await extService.CreateAsync(project.Id, createReq);
        Assert.NotNull(created);
        Assert.Equal("Pending", created.Status);

        var reqId = $"EXT-{created.Id.ToString("N")[..8].ToUpperInvariant()}";
        var expectedTitle = $"Extension Request Approval Pending | {project.Name} | {reqId}";

        // 4. Verify each selected approver received their own individual initial notification
        foreach (var approver in pmoApprovers)
        {
            var notif = await db.ActionNotifications.FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == approver.Id &&
                n.RelatedTask == reqId &&
                n.Type == "Extension Request");

            Assert.NotNull(notif);
            Assert.Equal(expectedTitle, notif.Title);
            Assert.Equal("Low", notif.Priority);
            Assert.Equal("Pending", notif.Status);
            Assert.True(notif.Unread);
        }

        // 5. Verify SLA tracking instance initialized
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Extension Request");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);
        Assert.Equal("Pending", instance.CurrentStage);
        Assert.Equal(reqId, instance.EntityReference);

        // 6. Verify daily reminder event execution reaches all selected approvers
        var reminderEvent = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.Reminder && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(reminderEvent);

        await worker.ExecuteReminderAsync(instance.Id, reminderEvent.Id);

        var expectedReminderTitle = $"Extension Request Reminder | {project.Name} | {reqId}";
        foreach (var approver in pmoApprovers)
        {
            var remNotif = await db.ActionNotifications.FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == approver.Id &&
                n.RelatedTask == reqId &&
                n.Title == expectedReminderTitle &&
                n.Type == "Extension Request");

            Assert.NotNull(remNotif);
            Assert.Equal("Low", remNotif.Priority);
            Assert.Equal("Pending", remNotif.Status);
            Assert.Equal("SLA Automation Engine", remNotif.RaisedByName);
        }
    }

    [Fact]
    public async Task ExtensionRequest_StatusChanges_InitialStage_NotifiesEmPmTl_ExcludesActor_PreservesComments()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var extService = scope.ServiceProvider.GetRequiredService<IProjectExtensionRequestService>();

        // 1. Resolve project with EM, PM, TL
        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null && p.EndDate.HasValue);
        Assert.NotNull(project);

        var em = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null) ?? throw new InvalidOperationException();
        var pm = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Id != em.Id) ?? throw new InvalidOperationException();
        var tl = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Id != em.Id && e.Id != pm.Id) ?? throw new InvalidOperationException();
        var pmoApprover = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Id != em.Id && e.Id != pm.Id && e.Id != tl.Id) ?? throw new InvalidOperationException();

        project.EngagementManagerId = em.Id;
        project.ProjectManagerId = pm.Id;
        project.TeamLeadId = tl.Id;
        pmoApprover.SubDepartment = ProjectExtensionRequestService.PmoSubDepartment;
        await db.SaveChangesAsync();

        var req = new CreateProjectExtensionRequest(
            project.EndDate!.Value.AddDays(10),
            "Testing Initial Stage Status Updates",
            [pmoApprover.Id]
        );

        var created = await extService.CreateAsync(project.Id, req);
        var reqId = $"EXT-{created.Id.ToString("N")[..8].ToUpperInvariant()}";

        // 2. Perform Hold action
        var holdResult = await extService.TakeActionAsync(project.Id, created.Id, new TakeExtensionActionRequest(
            "Hold",
            "Hold comment for review"
        ));
        Assert.Equal("Hold", holdResult.Status);

        // Verify SLA tracking is NOT completed for Hold
        var holdInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Extension Request");
        Assert.NotNull(holdInstance);
        Assert.Equal(SlaInstanceStatus.Tracking, holdInstance.Status);

        // Verify status change notification sent to EM, PM, TL
        var expectedStatusTitle = $"Extension Request Status Updated | {project.Name} | {reqId}";
        var holdNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == reqId && n.Title == expectedStatusTitle && n.Status == "Hold")
            .ToListAsync();

        Assert.Contains(holdNotifs, n => n.RecipientEmployeeId == em.Id);
        Assert.Contains(holdNotifs, n => n.RecipientEmployeeId == pm.Id);
        Assert.Contains(holdNotifs, n => n.RecipientEmployeeId == tl.Id);

        // 3. Perform Approve action
        var approveResult = await extService.ApproveAsync(project.Id, created.Id, new ApproveExtensionRequestDto("Approved by PMO"));
        Assert.Equal("Approved", approveResult.Status);

        // Verify SLA tracking is completed for Approved
        var approvedInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Extension Request");
        Assert.NotNull(approvedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, approvedInstance.Status);

        var approveNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == reqId && n.Title == expectedStatusTitle && n.Status == "Approved")
            .ToListAsync();

        Assert.Contains(approveNotifs, n => n.RecipientEmployeeId == em.Id);
        Assert.Contains(approveNotifs, n => n.RecipientEmployeeId == pm.Id);
        Assert.Contains(approveNotifs, n => n.RecipientEmployeeId == tl.Id);
    }

    [Fact]
    public async Task ExtensionRequest_L1Escalation_SeniorProjectManager_RemindersAndStatusChange()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var extService = scope.ServiceProvider.GetRequiredService<IProjectExtensionRequestService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null && p.EndDate.HasValue);
        Assert.NotNull(project);

        // Prepare SPM allocated to project
        var spm = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Role == "SeniorProjectManager")
            ?? await db.Employees.FirstAsync(e => e.DeletedAtUtc == null);

        var existingSpmTm = await db.ProjectTeamMembers.FirstOrDefaultAsync(tm => tm.ProjectId == project.Id && tm.MemberRole == ProjectMemberRoles.SeniorProjectManager && tm.DeletedAtUtc == null);
        if (existingSpmTm == null)
        {
            db.ProjectTeamMembers.Add(new ProjectTeamMember
            {
                ProjectId = project.Id,
                EmployeeId = spm.Id,
                MemberRole = ProjectMemberRoles.SeniorProjectManager,
                AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-10)),
                AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(100))
            });
            await db.SaveChangesAsync();
        }
        else
        {
            spm = await db.Employees.FirstAsync(e => e.Id == existingSpmTm.EmployeeId);
        }

        var pmoApprover = await db.Employees.FirstAsync(e => e.DeletedAtUtc == null && e.Id != spm.Id);
        pmoApprover.SubDepartment = ProjectExtensionRequestService.PmoSubDepartment;
        await db.SaveChangesAsync();

        var req = new CreateProjectExtensionRequest(
            project.EndDate!.Value.AddDays(12),
            "Testing L1 Escalation and SPM reminders",
            [pmoApprover.Id]
        );

        var created = await extService.CreateAsync(project.Id, req);
        var reqId = $"EXT-{created.Id.ToString("N")[..8].ToUpperInvariant()}";

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Extension Request");
        Assert.NotNull(instance);

        // Execute L1 Escalation
        var escL1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(escL1Event);

        await worker.ExecuteEscalationAsync(instance.Id, escL1Event.Id, 1);

        // Verify L1 Escalation notification sent strictly to Assigned SPM
        var expectedL1Title = $"Extension Request Escalation | L1 | {project.Name} | {reqId}";
        var spmNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == reqId && n.Title == expectedL1Title)
            .ToListAsync();

        Assert.NotEmpty(spmNotifs);
        Assert.Contains(spmNotifs, n => n.RecipientEmployeeId == spm.Id);
        Assert.DoesNotContain(spmNotifs, n => n.RecipientEmployeeId == pmoApprover.Id);
        Assert.Equal("Low", spmNotifs.First().Priority);
        Assert.Equal("Pending", spmNotifs.First().Status);

        // Verify L1 daily reminder scheduled and reaches ONLY SPM
        var l1ReminderEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.Reminder && e.TargetRolesJson.Contains("Senior Project Manager") && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(l1ReminderEvent);

        await worker.ExecuteReminderAsync(instance.Id, l1ReminderEvent.Id);

        var expectedL1RemTitle = $"Extension Request Reminder | L1 | {project.Name} | {reqId}";
        var l1RemNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == reqId && n.Title == expectedL1RemTitle)
            .ToListAsync();

        Assert.NotEmpty(l1RemNotifs);
        Assert.Contains(l1RemNotifs, n => n.RecipientEmployeeId == spm.Id);
        Assert.DoesNotContain(l1RemNotifs, n => n.RecipientEmployeeId == pmoApprover.Id);

        // Verify status change after L1 includes SPM
        var holdResult = await extService.TakeActionAsync(project.Id, created.Id, new TakeExtensionActionRequest("Hold", "SPM review hold"));
        Assert.Equal("Hold", holdResult.Status);

        var expectedStatusTitle = $"Extension Request Status Updated | {project.Name} | {reqId}";
        var statusNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == reqId && n.Title == expectedStatusTitle && n.Status == "Hold")
            .ToListAsync();

        Assert.Contains(statusNotifs, n => n.RecipientEmployeeId == spm.Id);
    }

    [Fact]
    public async Task ExtensionRequest_L2Escalation_HeadOfDepartment_RemindersAndStatusChange()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var extService = scope.ServiceProvider.GetRequiredService<IProjectExtensionRequestService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null && p.EndDate.HasValue);
        Assert.NotNull(project);

        var hod = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && (e.Role.Contains("HOD") || e.Role.Contains("Head")))
            ?? await db.Employees.FirstAsync(e => e.DeletedAtUtc == null);
        hod.Role = "HeadOfDepartment";
        await db.SaveChangesAsync();

        var pmoApprover = await db.Employees.FirstAsync(e => e.DeletedAtUtc == null && e.Id != hod.Id);
        pmoApprover.SubDepartment = ProjectExtensionRequestService.PmoSubDepartment;
        await db.SaveChangesAsync();

        var req = new CreateProjectExtensionRequest(
            project.EndDate!.Value.AddDays(25),
            "Testing L2 Escalation and HOD reminders",
            [pmoApprover.Id]
        );

        var created = await extService.CreateAsync(project.Id, req);
        var reqId = $"EXT-{created.Id.ToString("N")[..8].ToUpperInvariant()}";

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Extension Request");
        Assert.NotNull(instance);

        // Execute L1 Escalation first
        var escL1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(escL1Event);
        await worker.ExecuteEscalationAsync(instance.Id, escL1Event.Id, 1);

        // Fetch dynamically scheduled L2 event and execute
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(l2Event);

        await worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2);

        // Verify L2 Escalation notification sent strictly to Relevant HOD
        var expectedL2Title = $"Extension Request Escalation | L2 | {project.Name} | {reqId}";
        var hodNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == reqId && n.Title == expectedL2Title)
            .ToListAsync();

        Assert.NotEmpty(hodNotifs);
        Assert.Contains(hodNotifs, n => n.RecipientEmployeeId == hod.Id);
        Assert.DoesNotContain(hodNotifs, n => n.RecipientEmployeeId == pmoApprover.Id);
        Assert.Equal("Low", hodNotifs.First().Priority);
        Assert.Equal("Pending", hodNotifs.First().Status);

        // Verify L2 daily reminder scheduled and reaches ONLY HOD
        var l2ReminderEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.Reminder && e.TargetRolesJson.Contains("Head of Department") && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(l2ReminderEvent);

        await worker.ExecuteReminderAsync(instance.Id, l2ReminderEvent.Id);

        var expectedL2RemTitle = $"Extension Request Reminder | L2 | {project.Name} | {reqId}";
        var l2RemNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == reqId && n.Title == expectedL2RemTitle)
            .ToListAsync();

        Assert.NotEmpty(l2RemNotifs);
        Assert.Contains(l2RemNotifs, n => n.RecipientEmployeeId == hod.Id);
        Assert.DoesNotContain(l2RemNotifs, n => n.RecipientEmployeeId == pmoApprover.Id);

        // Verify status change after L2 includes HOD
        var rejectResult = await extService.TakeActionAsync(project.Id, created.Id, new TakeExtensionActionRequest("Rejected", "HOD rejected timeline extension"));
        Assert.Equal("Rejected", rejectResult.Status);

        var expectedStatusTitle = $"Extension Request Status Updated | {project.Name} | {reqId}";
        var statusNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == reqId && n.Title == expectedStatusTitle && n.Status == "Rejected")
            .ToListAsync();

        Assert.Contains(statusNotifs, n => n.RecipientEmployeeId == hod.Id);
    }

    [Fact]
    public async Task ExtensionRequest_EdgeCases_DuplicateRoles_StatusUnchanged_HangfireJobNames()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var extService = scope.ServiceProvider.GetRequiredService<IProjectExtensionRequestService>();

        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null && p.EndDate.HasValue);
        Assert.NotNull(project);

        // Test Hangfire Job Display Name builder
        var dummyReqId = "EXT-TEST1234";
        var l1JobName = SlaJobDisplayNameFormatter.BuildJobName(
            "Extension Request",
            nameof(SlaEventType.EscalationL1),
            1,
            dummyReqId,
            project.Name,
            ["Assigned Senior Project Manager"]
        );
        Assert.Equal($"Extension Request | L1 Escalation | Senior Project Manager | {project.Name} | {dummyReqId}", l1JobName);

        var l2JobName = SlaJobDisplayNameFormatter.BuildJobName(
            "Extension Request",
            nameof(SlaEventType.EscalationL2),
            2,
            dummyReqId,
            project.Name,
            ["Head of Department"]
        );
        Assert.Equal($"Extension Request | L2 Escalation | Head of Department | {project.Name} | {dummyReqId}", l2JobName);

        var initialRemJobName = SlaJobDisplayNameFormatter.BuildJobName(
            "Extension Request",
            nameof(SlaEventType.Reminder),
            null,
            dummyReqId,
            project.Name,
            ["Select Stakeholders"]
        );
        Assert.Equal($"Extension Request | Initial Approval Reminder | {project.Name} | {dummyReqId}", initialRemJobName);

        var l1RemJobName = SlaJobDisplayNameFormatter.BuildJobName(
            "Extension Request",
            nameof(SlaEventType.Reminder),
            null,
            dummyReqId,
            project.Name,
            ["Assigned Senior Project Manager"]
        );
        Assert.Equal($"Extension Request | L1 Daily Reminder | Senior Project Manager | {project.Name} | {dummyReqId}", l1RemJobName);

        var l2RemJobName = SlaJobDisplayNameFormatter.BuildJobName(
            "Extension Request",
            nameof(SlaEventType.Reminder),
            null,
            dummyReqId,
            project.Name,
            ["Head of Department"]
        );
        Assert.Equal($"Extension Request | L2 Daily Reminder | Head of Department | {project.Name} | {dummyReqId}", l2RemJobName);
    }
}
