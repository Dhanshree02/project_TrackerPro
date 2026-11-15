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
    public async Task ExtensionRequest_Creation_StartsSlaTracking_AndApproval_IncreasesProjectDate_AndNotifiesExpectedRoles()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var extService = scope.ServiceProvider.GetRequiredService<IProjectExtensionRequestService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve an active project with an EndDate
        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null && p.EndDate.HasValue);
        Assert.NotNull(project);

        var currentEndDate = project.EndDate!.Value;
        var requestedEndDate = currentEndDate.AddDays(15);

        // 2. Resolve a PMO approver
        var pmoApprover = await db.Employees.FirstOrDefaultAsync(e =>
            e.DeletedAtUtc == null && (e.SubDepartment == ProjectExtensionRequestService.PmoSubDepartment || (e.SubDepartment != null && e.SubDepartment.Contains("PMO"))));
        if (pmoApprover == null)
        {
            pmoApprover = await db.Employees.FirstAsync(e => e.DeletedAtUtc == null);
            pmoApprover.SubDepartment = ProjectExtensionRequestService.PmoSubDepartment;
            await db.SaveChangesAsync();
        }

        // 3. Create extension request
        var createReq = new CreateProjectExtensionRequest(
            requestedEndDate,
            "Integration Test Extension Reason - Client Scope Expansion",
            [pmoApprover.Id]
        );

        var created = await extService.CreateAsync(project.Id, createReq);
        Assert.NotNull(created);
        Assert.Equal("Pending", created.Status);

        // Verify initial notification to tagged approver
        var approverNotif = await db.ActionNotifications.FirstOrDefaultAsync(n =>
            n.RecipientEmployeeId == pmoApprover.Id && n.Type == "Timeline Extension Approval" && n.RelatedTask == created.Id.ToString());
        Assert.NotNull(approverNotif);

        // Verify SLA tracking instance started
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Extension Request");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);
        Assert.Equal("Pending", instance.CurrentStage);
        Assert.True(instance.TargetDeadlineUtc > instance.StartedAtUtc);

        // Verify daily reminder event can execute
        var reminderEvent = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.Reminder && e.Status == SlaEventStatus.Scheduled);
        if (reminderEvent != null)
        {
            await worker.ExecuteReminderAsync(instance.Id, reminderEvent.Id);
            var reminderNotif = await db.ActionNotifications.FirstOrDefaultAsync(n =>
                n.RecipientEmployeeId == pmoApprover.Id && n.Type == "Timeline Extension Reminder" && n.RelatedTask == created.Id.ToString());
            Assert.NotNull(reminderNotif);
        }

        // 4. Approver approves the request from Action Centre -> Approval Tab
        var approveResult = await extService.ApproveAsync(project.Id, created.Id, new ApproveExtensionRequestDto("Approved by PMO approver for scope expansion"));
        Assert.NotNull(approveResult);
        Assert.Equal("Approved", approveResult.Status);

        // 5. Verify project EndDate increased
        var updatedProject = await db.Projects.AsNoTracking().FirstOrDefaultAsync(p => p.Id == project.Id);
        Assert.NotNull(updatedProject);
        Assert.Equal(requestedEndDate, updatedProject.EndDate);

        // 6. Verify SLA instance marked Completed
        var completedInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(completedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);
        Assert.NotNull(completedInstance.CompletedAtUtc);

        // 7. Verify notifications sent to expected leadership & PMO
        var completionNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.Id.ToString() && n.Type == "Timeline Extension" && n.Status == "Approved")
            .ToListAsync();
        Assert.NotEmpty(completionNotifs);
    }

    [Fact]
    public async Task ExtensionRequest_UnresolvedAfter2Days_TriggersLevel1ToSpm_AndThenLevel2ToHod()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var extService = scope.ServiceProvider.GetRequiredService<IProjectExtensionRequestService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve an active project with EndDate
        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null && p.EndDate.HasValue);
        Assert.NotNull(project);

        var currentEndDate = project.EndDate!.Value;
        var requestedEndDate = currentEndDate.AddDays(20);

        // 2. Prepare Assigned Senior Project Manager on the project
        var spmEmployee = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Role == "SeniorProjectManager")
            ?? await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Id != project.ProjectManagerId);
        Assert.NotNull(spmEmployee);

        var spmMember = await db.ProjectTeamMembers.FirstOrDefaultAsync(tm => tm.ProjectId == project.Id && tm.EmployeeId == spmEmployee.Id && tm.DeletedAtUtc == null);
        if (spmMember == null)
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

        // 3. Prepare an HOD whose On Floor Role is Head Of Department
        var hodEmployee = await db.Employees.FirstOrDefaultAsync(e =>
            e.DeletedAtUtc == null && (e.Role.Contains("HOD") || e.Role.Contains("Head")) && e.Id != spmEmployee.Id);
        Assert.NotNull(hodEmployee);

        // 4. Prepare PMO approver
        var pmoApprover = await db.Employees.FirstOrDefaultAsync(e =>
            e.DeletedAtUtc == null && e.SubDepartment == ProjectExtensionRequestService.PmoSubDepartment && e.Id != spmEmployee.Id && e.Id != hodEmployee.Id)
            ?? await db.Employees.FirstAsync(e => e.DeletedAtUtc == null && e.Id != spmEmployee.Id && e.Id != hodEmployee.Id);
        if (pmoApprover.SubDepartment != ProjectExtensionRequestService.PmoSubDepartment)
        {
            pmoApprover.SubDepartment = ProjectExtensionRequestService.PmoSubDepartment;
            await db.SaveChangesAsync();
        }

        // 5. Create extension request
        var createReq = new CreateProjectExtensionRequest(
            requestedEndDate,
            "Testing Multi-Level SLA Escalation for Timeline Extension Request",
            [pmoApprover.Id]
        );

        var created = await extService.CreateAsync(project.Id, createReq);
        Assert.NotNull(created);

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Extension Request");
        Assert.NotNull(instance);

        // 6. Execute Level 1 Escalation Job (simulating breach after 2 days)
        var escL1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(escL1Event);

        await worker.ExecuteEscalationAsync(instance.Id, escL1Event.Id, 1);

        // 7. Verify Level 1 Escalation notification went ONLY to Assigned SPM
        var spmNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.Id.ToString() && n.Type == "Timeline Extension Escalation" && n.Title.Contains("Level 1 SLA Escalation"))
            .ToListAsync();
        Assert.NotEmpty(spmNotifs);
        Assert.Contains(spmNotifs, n => n.RecipientEmployeeId == spmEmployee.Id);
        Assert.Equal("Critical", spmNotifs.First().Priority);

        // 8. Verify Level 2 Escalation event dynamically scheduled
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(l2Event);

        // 9. Execute Level 2 Escalation Job (simulating breach after next 1 day)
        await worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2);

        // 10. Verify Level 2 Escalation notification went ONLY to HOD
        var hodNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == created.Id.ToString() && n.Type == "Timeline Extension Escalation" && n.Title.Contains("Level 2 SLA Escalation"))
            .ToListAsync();
        Assert.NotEmpty(hodNotifs);
        Assert.Contains(hodNotifs, n => n.RecipientEmployeeId == hodEmployee.Id);
        Assert.Equal("Critical", hodNotifs.First().Priority);

        // 11. Approver puts the request on Hold
        var holdResult = await extService.TakeActionAsync(project.Id, created.Id, new TakeExtensionActionRequest(
            "Hold",
            "Need additional budget verification before timeline extension."
        ));
        Assert.NotNull(holdResult);
        Assert.Equal("Hold", holdResult.Status);

        // 12. Verify SLA instance marked Completed
        var completedInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(completedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);
    }
}
