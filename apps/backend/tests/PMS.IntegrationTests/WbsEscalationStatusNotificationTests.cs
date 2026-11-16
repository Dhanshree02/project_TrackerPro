using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Sla.Jobs;
using PMS.API.Modules.Sla.Models;
using Xunit;

namespace PMS.IntegrationTests;

public class WbsEscalationStatusNotificationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public WbsEscalationStatusNotificationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
    }

    private HttpClient CreateActorClient(Employee actor)
    {
        var client = _factory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        client.DefaultRequestHeaders.Add("X-User-Email", actor.WorkEmail ?? $"{actor.FirstName.ToLower()}@test.com");
        client.DefaultRequestHeaders.Add("X-User-Id", actor.Id.ToString());
        client.DefaultRequestHeaders.Add("X-User-Role", "Admin");
        return client;
    }

    private static async Task<Employee> CreateEmployeeAsync(AppDbContext db, string firstName, string lastName, string subDepartment = "Engineering", string role = "Employee")
    {
        while (true)
        {
            var code = $"TKI-{Random.Shared.Next(1000, 9999):D4}";
            if (await db.Employees.AnyAsync(e => e.EmployeeCode == code)) continue;

            var emp = new Employee
            {
                Id = Guid.NewGuid(),
                EmployeeCode = code,
                FirstName = firstName,
                LastName = lastName,
                WorkEmail = $"{firstName.ToLower()}.{lastName.ToLower()}.{Guid.NewGuid():N}@talakunchi.com",
                Role = role,
                SubDepartment = subDepartment,
                Status = "Active",
                CreatedAtUtc = DateTime.UtcNow,
                UpdatedAtUtc = DateTime.UtcNow
            };
            db.Employees.Add(emp);
            try
            {
                await db.SaveChangesAsync();
                return emp;
            }
            catch (DbUpdateException)
            {
                db.Employees.Remove(emp);
            }
        }
    }

    private async Task<(Project Project, ProjectServiceEntity Service, Employee Pm, Employee Em, Employee Tl, Employee Spm, Employee Hod, Employee Stakeholder)>
        SetupWbsEscalationEnvironmentAsync(AppDbContext db, bool sharePmAndTl = false)
    {
        var uniqueSuffix = Guid.NewGuid().ToString("N")[..8];

        // 1. Create PM, EM, TL
        var pm = await CreateEmployeeAsync(db, $"PM_{uniqueSuffix}", "Manager", "PMO (Project Management Office)", "ProjectManager");
        var em = await CreateEmployeeAsync(db, $"EM_{uniqueSuffix}", "Manager", "EM (Engagement Manager)", "EngagementManager");
        var tl = sharePmAndTl ? pm : await CreateEmployeeAsync(db, $"TL_{uniqueSuffix}", "Lead", "Engineering", "TeamLead");

        // 2. Create Project
        var client = await db.Clients.FirstOrDefaultAsync(c => c.DeletedAtUtc == null);
        var project = new Project
        {
            Id = Guid.NewGuid(),
            Name = $"WBS Status Test Project {uniqueSuffix}",
            ProjectCode = $"PRJ-{uniqueSuffix.ToUpper()}",
            ClientId = client?.Id ?? Guid.NewGuid(),
            ProjectManagerId = pm.Id,
            EngagementManagerId = em.Id,
            TeamLeadId = tl.Id,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };
        db.Projects.Add(project);
        await db.SaveChangesAsync();

        // 3. Create SPM and allocate as SeniorProjectManager on project
        var spm = await CreateEmployeeAsync(db, $"SPM_{uniqueSuffix}", "SeniorManager", "Senior Project Management", "SeniorProjectManager");
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            ProjectId = project.Id,
            EmployeeId = spm.Id,
            MemberRole = ProjectMemberRoles.SeniorProjectManager,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-10)),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(100))
        });

        // 4. Create HOD with OnFloorRole = Head Of Department
        var hodRole = await db.OnFloorRoles.FirstOrDefaultAsync(o => o.Name.Contains("Head Of Department") && o.DeletedAtUtc == null);
        if (hodRole == null)
        {
            var desig = await db.Designations.FirstOrDefaultAsync(d => d.DeletedAtUtc == null);
            hodRole = new OnFloorRole
            {
                Name = "Head Of Department",
                DesignationId = desig?.Id ?? Guid.NewGuid()
            };
            db.OnFloorRoles.Add(hodRole);
            await db.SaveChangesAsync();
        }

        var serviceDept = $"Engineering_{uniqueSuffix}";
        var hod = await CreateEmployeeAsync(db, $"HOD_{uniqueSuffix}", "Director", serviceDept, "Head of Department");
        hod.DesignationId = hodRole.DesignationId;
        await db.SaveChangesAsync();

        // 5. Create Selected Stakeholder (PMO)
        var stakeholder = await CreateEmployeeAsync(db, $"Stakeholder_{uniqueSuffix}", "Coordinator", "PMO (Project Management Office)", "PMO");

        // 6. Create Service on Project
        var service = new ProjectServiceEntity
        {
            ProjectId = project.Id,
            ServiceName = $"Security Prerequisite {uniqueSuffix}",
            Department = serviceDept
        };
        db.ProjectServices.Add(service);
        await db.SaveChangesAsync();

        return (project, service, pm, em, tl, spm, hod, stakeholder);
    }

    [Fact]
    public async Task CompleteMatrix_AllSixRows_AndEdgeCases_Verified()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var escService = scope.ServiceProvider.GetRequiredService<IProjectServiceEscalationService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var env = await SetupWbsEscalationEnvironmentAsync(db);

        // Raise WBS Escalation with Selected Stakeholder
        var escForm = new CreateProjectServiceEscalationForm
        {
            ServiceName = env.Service.ServiceName,
            ProjectServiceId = env.Service.Id,
            EscalationType = "Prerequisite Pending",
            Priority = "High",
            Subject = $"Matrix Verification {Guid.NewGuid():N}",
            Description = "Testing complete 6-row recipient matrix and edge cases.",
            StakeholderIds = [env.Stakeholder.Id]
        };

        var createdEsc = await escService.CreateAsync(env.Project.Id, escForm);
        Assert.NotNull(createdEsc);

        var alert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.ServiceEscalationId == createdEsc.Id);
        Assert.NotNull(alert);

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == createdEsc.Id && i.ActivityType == "WBS Escalation");
        Assert.NotNull(instance);

        // =========================================================================
        // ROW 1: Initial 2-day SLA | Selected Stakeholder changes status -> PM, EM, TL
        // =========================================================================
        var stakeholderClient = CreateActorClient(env.Stakeholder);
        var row1Response = await stakeholderClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "In Progress", Comment = "Stakeholder changing status in initial SLA" });
        Assert.Equal(HttpStatusCode.OK, row1Response.StatusCode);

        var row1Notifs = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(3, row1Notifs.Count);
        var row1Recipients = row1Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, row1Recipients);
        Assert.Contains(env.Em.Id, row1Recipients);
        Assert.Contains(env.Tl.Id, row1Recipients);
        Assert.DoesNotContain(env.Stakeholder.Id, row1Recipients); // Actor excluded
        Assert.DoesNotContain(env.Spm.Id, row1Recipients); // Not escalated to L1 yet
        Assert.DoesNotContain(env.Hod.Id, row1Recipients); // Not escalated to L2 yet

        // Verify notification properties as required by prompt Section 10
        var sampleNotif = row1Notifs.First();
        Assert.Equal("WBS Escalation Status Update", sampleNotif.Type);
        Assert.Equal("Pending", sampleNotif.Status);
        Assert.Equal("Low", sampleNotif.Priority);
        Assert.True(sampleNotif.Unread);
        Assert.Equal($"{env.Stakeholder.FirstName} {env.Stakeholder.LastName}".Trim(), sampleNotif.RaisedByName);
        Assert.Equal(env.Project.Name, sampleNotif.ProjectName);
        Assert.Equal(env.Project.ProjectCode, sampleNotif.ProjectCode);
        Assert.Contains("In Progress", sampleNotif.Title);

        // =========================================================================
        // EDGE CASE: Status saved without actual change -> No notifications generated
        // =========================================================================
        var beforeUnchangedCount = await db.ActionNotifications
            .CountAsync(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null);

        var unchangedResponse = await stakeholderClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "In Progress", Comment = "Adding comment without changing status" });
        Assert.Equal(HttpStatusCode.OK, unchangedResponse.StatusCode);

        var afterUnchangedCount = await db.ActionNotifications
            .CountAsync(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null);
        Assert.Equal(beforeUnchangedCount, afterUnchangedCount);

        // =========================================================================
        // Transition to Level 1 Escalation via Hangfire worker
        // =========================================================================
        var escL1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        Assert.NotNull(escL1Event);
        await worker.ExecuteEscalationAsync(instance.Id, escL1Event.Id, 1);

        // Refresh alert & instance
        var l1Alert = await db.ProjectAlerts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == alert.Id);
        Assert.NotNull(l1Alert);

        // Clear previous status update notifications to test Row 2 cleanly
        db.ActionNotifications.RemoveRange(await db.ActionNotifications.Where(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update").ToListAsync());
        await db.SaveChangesAsync();

        // =========================================================================
        // ROW 2: After L1 escalation | Selected Stakeholder changes status -> PM, EM, TL, SPM
        // =========================================================================
        var row2Response = await stakeholderClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Under Review", Comment = "Stakeholder moving to Under Review after L1" });
        Assert.Equal(HttpStatusCode.OK, row2Response.StatusCode);

        var row2Notifs = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(4, row2Notifs.Count);
        var row2Recipients = row2Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, row2Recipients);
        Assert.Contains(env.Em.Id, row2Recipients);
        Assert.Contains(env.Tl.Id, row2Recipients);
        Assert.Contains(env.Spm.Id, row2Recipients); // SPM notified at L1
        Assert.DoesNotContain(env.Stakeholder.Id, row2Recipients); // Actor excluded
        Assert.DoesNotContain(env.Hod.Id, row2Recipients); // Not escalated to L2 yet

        // Clear previous status update notifications to test Row 3 cleanly
        db.ActionNotifications.RemoveRange(row2Notifs);
        await db.SaveChangesAsync();

        // =========================================================================
        // ROW 3: After L1 escalation | Senior Project Manager changes status -> PM, EM, TL, Selected Stakeholder
        // =========================================================================
        var spmClient = CreateActorClient(env.Spm);
        var row3Response = await spmClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Work in Progress", Comment = "SPM taking ownership at L1" });
        Assert.Equal(HttpStatusCode.OK, row3Response.StatusCode);

        var row3Notifs = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(4, row3Notifs.Count);
        var row3Recipients = row3Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, row3Recipients);
        Assert.Contains(env.Em.Id, row3Recipients);
        Assert.Contains(env.Tl.Id, row3Recipients);
        Assert.Contains(env.Stakeholder.Id, row3Recipients); // Selected Stakeholder notified
        Assert.DoesNotContain(env.Spm.Id, row3Recipients); // SPM actor excluded
        Assert.DoesNotContain(env.Hod.Id, row3Recipients); // Not escalated to L2 yet

        // Clear previous status update notifications to test Row 4-6 cleanly
        db.ActionNotifications.RemoveRange(row3Notifs);
        await db.SaveChangesAsync();

        // =========================================================================
        // Transition to Level 2 Escalation via Hangfire worker
        // =========================================================================
        var escL2Event = await db.SlaEvents.FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2);
        Assert.NotNull(escL2Event);
        await worker.ExecuteEscalationAsync(instance.Id, escL2Event.Id, 2);

        // =========================================================================
        // ROW 4: After L2 escalation | Selected Stakeholder changes status -> PM, EM, TL, SPM, HOD
        // =========================================================================
        var row4Response = await stakeholderClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Pending Vendor", Comment = "Stakeholder update at L2" });
        Assert.Equal(HttpStatusCode.OK, row4Response.StatusCode);

        var row4Notifs = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(5, row4Notifs.Count);
        var row4Recipients = row4Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, row4Recipients);
        Assert.Contains(env.Em.Id, row4Recipients);
        Assert.Contains(env.Tl.Id, row4Recipients);
        Assert.Contains(env.Spm.Id, row4Recipients); // SPM notified at L2
        Assert.Contains(env.Hod.Id, row4Recipients); // HOD notified at L2
        Assert.DoesNotContain(env.Stakeholder.Id, row4Recipients); // Actor excluded

        // Clear previous status update notifications to test Row 5 cleanly
        db.ActionNotifications.RemoveRange(row4Notifs);
        await db.SaveChangesAsync();

        // =========================================================================
        // ROW 5: After L2 escalation | Senior Project Manager changes status -> PM, EM, TL, Selected Stakeholder, HOD
        // =========================================================================
        var row5Response = await spmClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Executive Review", Comment = "SPM update at L2" });
        Assert.Equal(HttpStatusCode.OK, row5Response.StatusCode);

        var row5Notifs = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(5, row5Notifs.Count);
        var row5Recipients = row5Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, row5Recipients);
        Assert.Contains(env.Em.Id, row5Recipients);
        Assert.Contains(env.Tl.Id, row5Recipients);
        Assert.Contains(env.Stakeholder.Id, row5Recipients); // Selected Stakeholder notified
        Assert.Contains(env.Hod.Id, row5Recipients); // HOD notified
        Assert.DoesNotContain(env.Spm.Id, row5Recipients); // SPM actor excluded

        // Clear previous status update notifications to test Row 6 cleanly
        db.ActionNotifications.RemoveRange(row5Notifs);
        await db.SaveChangesAsync();

        // =========================================================================
        // ROW 6: After L2 escalation | HOD changes status -> PM, EM, TL, Selected Stakeholder, SPM
        // =========================================================================
        var hodClient = CreateActorClient(env.Hod);
        var row6Response = await hodClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Resolved", Comment = "HOD executive resolution" });
        Assert.Equal(HttpStatusCode.OK, row6Response.StatusCode);

        var row6Notifs = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == createdEsc.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(5, row6Notifs.Count);
        var row6Recipients = row6Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, row6Recipients);
        Assert.Contains(env.Em.Id, row6Recipients);
        Assert.Contains(env.Tl.Id, row6Recipients);
        Assert.Contains(env.Stakeholder.Id, row6Recipients); // Selected Stakeholder notified
        Assert.Contains(env.Spm.Id, row6Recipients); // SPM notified
        Assert.DoesNotContain(env.Hod.Id, row6Recipients); // HOD actor excluded

        // Verify status is Resolved and SLA is completed
        var updatedAlert = await db.ProjectAlerts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == alert.Id);
        Assert.NotNull(updatedAlert);
        Assert.Equal("Resolved", updatedAlert.Status);

        var completedInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(completedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);
    }

    [Fact]
    public async Task EdgeCase_SamePersonAssignedMultipleRoles_ReceivesOnlyOneNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var escService = scope.ServiceProvider.GetRequiredService<IProjectServiceEscalationService>();

        // Create environment where PM and TL are the same person (sharePmAndTl: true)
        var env = await SetupWbsEscalationEnvironmentAsync(db, sharePmAndTl: true);
        Assert.Equal(env.Pm.Id, env.Tl.Id);

        var escForm = new CreateProjectServiceEscalationForm
        {
            ServiceName = env.Service.ServiceName,
            ProjectServiceId = env.Service.Id,
            EscalationType = "Technical Blocker",
            Priority = "High",
            Subject = $"MultiRole Test {Guid.NewGuid():N}",
            Description = "Testing deduplication when PM is also TL.",
            StakeholderIds = [env.Stakeholder.Id]
        };

        var created = await escService.CreateAsync(env.Project.Id, escForm);
        var alert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.ServiceEscalationId == created.Id);
        Assert.NotNull(alert);

        var stakeholderClient = CreateActorClient(env.Stakeholder);
        var response = await stakeholderClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "In Progress", Comment = "Multi-role status change" });
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var notifs = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == created.Id && n.Type == "WBS Escalation Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        // Should be 2 notifications total: 1 for PM/TL (deduplicated), 1 for EM
        Assert.Equal(2, notifs.Count);
        var pmTlNotifs = notifs.Where(n => n.RecipientEmployeeId == env.Pm.Id).ToList();
        Assert.Single(pmTlNotifs); // Exactly 1 notification sent to PM/TL, not 2
        var emNotifs = notifs.Where(n => n.RecipientEmployeeId == env.Em.Id).ToList();
        Assert.Single(emNotifs);
    }
}
