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
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Sla.Jobs;
using PMS.API.Modules.Sla.Models;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class WbsEscalationSlaIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public WbsEscalationSlaIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    [Fact]
    public async Task WbsEscalation_Creation_StartsSlaTracking_AndResolutionBefore2Days_CompletesSlaWithoutL1()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var escService = scope.ServiceProvider.GetRequiredService<IProjectServiceEscalationService>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve an active project and service
        var project = await db.Projects
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var service = await db.ProjectServices
            .FirstOrDefaultAsync(s => s.ProjectId == project.Id && s.DeletedAtUtc == null);
        if (service == null)
        {
            service = new ProjectServiceEntity
            {
                ProjectId = project.Id,
                ServiceName = "Frontend Architecture & Build",
                Department = "Engineering"
            };
            db.ProjectServices.Add(service);
            await db.SaveChangesAsync();
        }

        // 2. Resolve or prepare a PMO/EM stakeholder
        var pmoSubDept = ProjectServiceEscalationService.PmoSubDepartment;
        var stakeholder = await db.Employees
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.SubDepartment == pmoSubDept)
            ?? await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null);
        Assert.NotNull(stakeholder);

        if (stakeholder.SubDepartment != pmoSubDept)
        {
            stakeholder.SubDepartment = pmoSubDept;
            await db.SaveChangesAsync();
        }

        // 3. Create WBS Escalation via Service
        var createForm = new CreateProjectServiceEscalationForm
        {
            ServiceName = service.ServiceName,
            ProjectServiceId = service.Id,
            EscalationType = "Prerequisite Pending",
            Priority = "High",
            Subject = $"Integration Test WBS Escalation {Guid.NewGuid():N}",
            Description = "Testing WBS escalation SLA tracking and early resolution behavior.",
            StakeholderIds = [stakeholder.Id]
        };

        var created = await escService.CreateAsync(project.Id, createForm);
        Assert.NotNull(created);
        var escalationId = created.Id;

        // 4. Verify initial state:
        // A. Escalation record created in Open status
        var escalationRow = await db.ProjectServiceEscalations
            .Include(e => e.Stakeholders)
            .FirstOrDefaultAsync(e => e.Id == escalationId);
        Assert.NotNull(escalationRow);
        Assert.Equal("Open", escalationRow.Status);
        Assert.Contains(escalationRow.Stakeholders, s => s.EmployeeId == stakeholder.Id);

        // B. Stakeholder received notification
        var stakeholderNotif = await db.ActionNotifications
            .FirstOrDefaultAsync(n => n.RecipientEmployeeId == stakeholder.Id && n.Type == "WBS Escalation" && n.Title.Contains(created.Subject));
        Assert.NotNull(stakeholderNotif);

        // C. Alert created with stakeholder in AudienceUserIds
        var alert = await db.ProjectAlerts
            .FirstOrDefaultAsync(a => a.ServiceEscalationId == escalationId && a.DeletedAtUtc == null);
        Assert.NotNull(alert);
        Assert.Contains(stakeholder.Id.ToString(), alert.AudienceUserIds);

        // D. SLA tracking instance started for WBS Escalation
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == escalationId && i.ActivityType == "WBS Escalation");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);
        Assert.Equal("Open", instance.CurrentStage);
        Assert.True(instance.TargetDeadlineUtc > instance.StartedAtUtc, "Target deadline must be in future (EOD of next 2 working days).");

        // Verify milestone events: BreachCheck and EscalationL1 scheduled; EscalationL2 NOT yet scheduled
        var l1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(l1Event);
        Assert.Contains(instance.Events, e => e.EventType == SlaEventType.BreachCheck && e.Status == SlaEventStatus.Scheduled);
        Assert.DoesNotContain(instance.Events, e => e.EventType == SlaEventType.EscalationL2);

        // 5. Selected stakeholder resolves the escalation before 2 days from their Alert tab
        var updateGovernanceResult = await notifService.UpdateAlertGovernanceAsync(alert.Id, new UpdateAlertGovernanceRequest
        {
            Status = "Resolved",
            Comment = "Stakeholder: Prerequisite received and verified, issue resolved."
        });
        Assert.NotNull(updateGovernanceResult);
        Assert.Equal("Resolved", updateGovernanceResult.Status);

        // 6. Verify SLA instance completed and pending jobs cancelled
        var updatedInstance = await db.SlaInstances
            .AsNoTracking()
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(updatedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, updatedInstance.Status);
        Assert.NotNull(updatedInstance.CompletedAtUtc);

        var pendingEvents = updatedInstance.Events
            .Where(e => e.EventType is SlaEventType.BreachCheck or SlaEventType.EscalationL1)
            .ToList();
        Assert.All(pendingEvents, e => Assert.Equal(SlaEventStatus.Cancelled, e.Status));

        // 7. Verify that even if Hangfire executes the L1 job, it skips and 1st level escalation does not happen
        await worker.ExecuteEscalationAsync(instance.Id, l1Event.Id, 1);

        var spmNotifs = await db.ActionNotifications
            .Where(n => n.Type == "WBS Escalation" && n.Title.Contains("Level 1 Escalation") && n.Title.Contains(created.Subject))
            .ToListAsync();
        Assert.Empty(spmNotifs);
    }

    [Fact]
    public async Task WbsEscalation_UnresolvedAfter2Days_TriggersLevel1ToSpm_AndThenLevel2ToHod()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var escService = scope.ServiceProvider.GetRequiredService<IProjectServiceEscalationService>();
        var notifService = scope.ServiceProvider.GetRequiredService<IActionNotificationService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve an active project and service
        var project = await db.Projects
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var service = await db.ProjectServices
            .FirstOrDefaultAsync(s => s.ProjectId == project.Id && s.DeletedAtUtc == null);
        if (service == null)
        {
            service = new ProjectServiceEntity
            {
                ProjectId = project.Id,
                ServiceName = "Frontend Architecture & Build",
                Department = "Engineering"
            };
            db.ProjectServices.Add(service);
            await db.SaveChangesAsync();
        }

        // 2. Prepare an Assigned Senior Project Manager on the project
        var spmEmployee = await db.Employees
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Role == "SeniorProjectManager")
            ?? await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Id != project.ProjectManagerId);
        Assert.NotNull(spmEmployee);

        var spmMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.ProjectId == project.Id && tm.EmployeeId == spmEmployee.Id && tm.DeletedAtUtc == null);
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
        else if (spmMember.MemberRole != ProjectMemberRoles.SeniorProjectManager)
        {
            spmMember.MemberRole = ProjectMemberRoles.SeniorProjectManager;
            await db.SaveChangesAsync();
        }

        // 3. Prepare an HOD whose On Floor Role is Head Of Department
        var hodRole = await db.OnFloorRoles
            .FirstOrDefaultAsync(o => o.Name.Contains("Head Of Department") && o.DeletedAtUtc == null);
        if (hodRole == null)
        {
            var anyDesignation = await db.Designations.FirstOrDefaultAsync(d => d.DeletedAtUtc == null);
            hodRole = new OnFloorRole
            {
                Name = "Head Of Department",
                DesignationId = anyDesignation?.Id ?? Guid.NewGuid()
            };
            db.OnFloorRoles.Add(hodRole);
            await db.SaveChangesAsync();
        }

        var hodEmployee = await db.Employees
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Id != spmEmployee.Id && e.Id != project.ProjectManagerId);
        Assert.NotNull(hodEmployee);

        if (hodRole.DesignationId != Guid.Empty && hodEmployee.DesignationId != hodRole.DesignationId)
        {
            hodEmployee.DesignationId = hodRole.DesignationId;
        }
        hodEmployee.Role = "Head of Department";
        await db.SaveChangesAsync();

        // 4. Prepare a PMO/EM stakeholder
        var pmoSubDept = ProjectServiceEscalationService.PmoSubDepartment;
        var stakeholder = await db.Employees
            .FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.SubDepartment == pmoSubDept && e.Id != spmEmployee.Id && e.Id != hodEmployee.Id)
            ?? await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null && e.Id != spmEmployee.Id && e.Id != hodEmployee.Id);
        Assert.NotNull(stakeholder);

        if (stakeholder.SubDepartment != pmoSubDept)
        {
            stakeholder.SubDepartment = pmoSubDept;
            await db.SaveChangesAsync();
        }

        // 5. Raise WBS Escalation
        var escSubject = $"Unresolved SLA WBS Escalation {Guid.NewGuid():N}";
        var createForm = new CreateProjectServiceEscalationForm
        {
            ServiceName = service.ServiceName,
            ProjectServiceId = service.Id,
            EscalationType = "Technical Blocker",
            Priority = "High",
            Subject = escSubject,
            Description = "Testing multi-level SLA escalation dispatch and chat participation.",
            StakeholderIds = [stakeholder.Id]
        };

        var created = await escService.CreateAsync(project.Id, createForm);
        Assert.NotNull(created);
        var escalationId = created.Id;

        // Verify initial Alert: SPM and HOD must NOT yet be in AudienceUserIds
        var initialAlert = await db.ProjectAlerts
            .FirstOrDefaultAsync(a => a.ServiceEscalationId == escalationId && a.DeletedAtUtc == null);
        Assert.NotNull(initialAlert);
        Assert.Contains(stakeholder.Id.ToString(), initialAlert.AudienceUserIds);
        Assert.DoesNotContain(spmEmployee.Id.ToString(), initialAlert.AudienceUserIds);
        Assert.DoesNotContain(hodEmployee.Id.ToString(), initialAlert.AudienceUserIds);

        // 6. Execute Level 1 Escalation Job (simulating breach after 2 days)
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == escalationId && i.ActivityType == "WBS Escalation");
        Assert.NotNull(instance);

        var escL1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(escL1Event);

        await worker.ExecuteEscalationAsync(instance.Id, escL1Event.Id, 1);

        // 7. Verify Level 1 Escalation Results:
        // A. Assigned Senior Project Manager receives Notification and Alert request in Alert tab
        var spmNotifs = await db.ActionNotifications
            .Where(n => n.RecipientEmployeeId == spmEmployee.Id && n.Type == "WBS Escalation" && n.Title.Contains("Level 1 Escalation") && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(spmNotifs);
        Assert.Equal("Critical", spmNotifs.First().Priority);

        var l1Alert = await db.ProjectAlerts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == initialAlert.Id);
        Assert.NotNull(l1Alert);
        Assert.Contains(spmEmployee.Id.ToString(), l1Alert.AudienceUserIds);
        Assert.Equal("Critical", l1Alert.Priority);
        Assert.Contains("Level 1", l1Alert.HistoryJson);

        var l1Esc = await db.ProjectServiceEscalations.Include(e => e.Stakeholders).FirstOrDefaultAsync(e => e.Id == escalationId);
        Assert.NotNull(l1Esc);
        Assert.Contains(l1Esc.Stakeholders, s => s.EmployeeId == spmEmployee.Id);
        Assert.Equal("Critical", l1Esc.Priority);

        // B. Verify Level 2 Escalation event dynamically scheduled for EOD of next 1 working day
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2 && e.Status == SlaEventStatus.Scheduled);
        Assert.NotNull(l2Event);
        Assert.True(l2Event.ScheduledAtUtc > DateTime.UtcNow);

        // C. SPM participates in chat and updates status to In Progress
        var spmComment = "Senior Project Manager: Looking into technical blocker with prerequisite team.";
        var spmUpdate = await notifService.UpdateAlertGovernanceAsync(l1Alert.Id, new UpdateAlertGovernanceRequest
        {
            Status = "In Progress",
            Comment = spmComment
        });
        Assert.NotNull(spmUpdate);
        Assert.Equal("In Progress", spmUpdate.Status);

        // 8. Execute Level 2 Escalation Job (simulating breach after next 1 day)
        await worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2);

        // 9. Verify Level 2 Escalation Results:
        // A. HOD receives Notification and Alert request in Alert tab
        var hodNotifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.Type == "WBS Escalation" && n.Title.Contains("Level 2 Escalation") && n.Title.Contains(escSubject) && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(hodNotifs);
        Assert.Equal("Critical", hodNotifs.First().Priority);
        var hodRecipientId = hodNotifs.First().RecipientEmployeeId;

        var l2Alert = await db.ProjectAlerts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == initialAlert.Id);
        Assert.NotNull(l2Alert);
        Assert.Contains(hodRecipientId.ToString(), l2Alert.AudienceUserIds);
        Assert.Contains("Level 2", l2Alert.HistoryJson);

        var l2Esc = await db.ProjectServiceEscalations.Include(e => e.Stakeholders).FirstOrDefaultAsync(e => e.Id == escalationId);
        Assert.NotNull(l2Esc);
        Assert.Contains(l2Esc.Stakeholders, s => s.EmployeeId == hodRecipientId);

        // B. HOD resolves the escalation from Alert tab
        var hodUpdate = await notifService.UpdateAlertGovernanceAsync(l2Alert.Id, new UpdateAlertGovernanceRequest
        {
            Status = "Resolved",
            Comment = "HOD: Escalation resolved with executive authorization."
        });
        Assert.NotNull(hodUpdate);
        Assert.Equal("Resolved", hodUpdate.Status);

        // C. Verify SLA instance marked Completed
        var completedInstance = await db.SlaInstances
            .AsNoTracking()
            .FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(completedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);
    }
}
