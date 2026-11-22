using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.Projects.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Sla.Jobs;
using PMS.API.Modules.Sla.Models;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class IssueStatusNotificationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public IssueStatusNotificationTests(WebApplicationFactory<Program> factory)
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

    private async Task<(Project Project, Employee Pm, Employee Em, Employee Tl, Employee Spm, Employee Hod, Employee Raiser)>
        SetupIssueEnvironmentAsync(AppDbContext db, bool sharePmAndTl = false)
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
            Name = $"Issue Status Test Project {uniqueSuffix}",
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

        var hod = await CreateEmployeeAsync(db, $"HOD_{uniqueSuffix}", "Director", "Department Head", "Head of Department");
        hod.DesignationId = hodRole.DesignationId;
        await db.SaveChangesAsync();

        // 5. Create Issue Raiser (e.g. Developer on team)
        var raiser = await CreateEmployeeAsync(db, $"Raiser_{uniqueSuffix}", "Developer", "Engineering", "Employee");

        return (project, pm, em, tl, spm, hod, raiser);
    }

    [Fact]
    public async Task IssueStatusChange_AllThreeStages_AndEdgeCases_Verified()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var env = await SetupIssueEnvironmentAsync(db);

        // 1. Raiser raises an issue via Project -> Health -> Issue API
        var raiserClient = CreateActorClient(env.Raiser);
        var issueForm = new CreateProjectIssueRequest
        {
            Subject = $"Integration Issue {Guid.NewGuid():N}",
            Description = "Testing Raise Issue status change notification matrix.",
            IssueType = "Technical Related Issues",
            Priority = "High"
        };

        var createRes = await raiserClient.PostAsJsonAsync($"/api/v1/projects/{env.Project.Id}/issues", issueForm);
        Assert.Equal(HttpStatusCode.OK, createRes.StatusCode);

        var createBody = await createRes.Content.ReadFromJsonAsync<ApiResponse<ProjectIssueDto>>();
        Assert.NotNull(createBody?.Data);
        var issueId = createBody.Data.Id;

        var alert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.IssueId == issueId);
        Assert.NotNull(alert);

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == issueId && i.ActivityType == "Resolution of Issues");
        Assert.NotNull(instance);

        // =========================================================================
        // STAGE 1: Initial 2-Day SLA | PM changes status -> EM, TL, Raiser (PM excluded)
        // =========================================================================
        var pmClient = CreateActorClient(env.Pm);
        var stage1Response = await pmClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "In Progress", Comment = "PM acknowledging and assigning issue" });
        Assert.Equal(HttpStatusCode.OK, stage1Response.StatusCode);

        var stage1Notifs = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(3, stage1Notifs.Count);
        var stage1Recipients = stage1Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Em.Id, stage1Recipients);
        Assert.Contains(env.Tl.Id, stage1Recipients);
        Assert.Contains(env.Raiser.Id, stage1Recipients); // Original issue raiser notified
        Assert.DoesNotContain(env.Pm.Id, stage1Recipients); // PM actor excluded
        Assert.DoesNotContain(env.Spm.Id, stage1Recipients); // SPM not notified at initial stage
        Assert.DoesNotContain(env.Hod.Id, stage1Recipients); // HOD not notified at initial stage

        // Verify notification properties
        var sampleNotif = stage1Notifs.First();
        Assert.Equal("Issue Status Update", sampleNotif.Type);
        Assert.Equal("Pending", sampleNotif.Status);
        Assert.Equal("Low", sampleNotif.Priority);
        Assert.True(sampleNotif.Unread);
        Assert.Equal($"{env.Pm.FirstName} {env.Pm.LastName}".Trim(), sampleNotif.RaisedByName);
        Assert.Equal(env.Project.Name, sampleNotif.ProjectName);
        Assert.Equal(env.Project.ProjectCode, sampleNotif.ProjectCode);
        Assert.Contains("In Progress", sampleNotif.Title);

        // =========================================================================
        // EDGE CASE: Status saved without actual change -> No notifications generated
        // =========================================================================
        var beforeUnchangedCount = await db.ActionNotifications
            .CountAsync(n => n.IssueId == issueId && n.Type == "Issue Status Update" && n.DeletedAtUtc == null);

        var unchangedResponse = await pmClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "In Progress", Comment = "Adding comment without changing status" });
        Assert.Equal(HttpStatusCode.OK, unchangedResponse.StatusCode);

        var afterUnchangedCount = await db.ActionNotifications
            .CountAsync(n => n.IssueId == issueId && n.Type == "Issue Status Update" && n.DeletedAtUtc == null);
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

        // Clear previous status update notifications to test Stage 2 cleanly
        db.ActionNotifications.RemoveRange(await db.ActionNotifications.Where(n => n.IssueId == issueId && n.Type == "Issue Status Update").ToListAsync());
        await db.SaveChangesAsync();

        // =========================================================================
        // STAGE 2: After Level 1 Escalation | SPM changes status -> PM, EM, TL, Raiser (SPM excluded)
        // =========================================================================
        var spmClient = CreateActorClient(env.Spm);
        var stage2Response = await spmClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Under Review", Comment = "SPM actively reviewing issue after L1" });
        Assert.Equal(HttpStatusCode.OK, stage2Response.StatusCode);

        var stage2Notifs = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(4, stage2Notifs.Count);
        var stage2Recipients = stage2Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, stage2Recipients);
        Assert.Contains(env.Em.Id, stage2Recipients);
        Assert.Contains(env.Tl.Id, stage2Recipients);
        Assert.Contains(env.Raiser.Id, stage2Recipients); // Raiser notified
        Assert.DoesNotContain(env.Spm.Id, stage2Recipients); // SPM actor excluded
        Assert.DoesNotContain(env.Hod.Id, stage2Recipients); // HOD not notified at L1

        // Clear previous status update notifications to test Stage 3 cleanly
        db.ActionNotifications.RemoveRange(stage2Notifs);
        await db.SaveChangesAsync();

        // =========================================================================
        // Transition to Level 2 Escalation via Hangfire worker
        // =========================================================================
        var escL2Event = await db.SlaEvents.FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2);
        Assert.NotNull(escL2Event);
        await worker.ExecuteEscalationAsync(instance.Id, escL2Event.Id, 2);

        // =========================================================================
        // STAGE 3: After Level 2 Escalation | HOD changes status -> PM, EM, TL, Raiser, SPM (HOD excluded)
        // =========================================================================
        var hodClient = CreateActorClient(env.Hod);
        var stage3Response = await hodClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Resolved", Comment = "HOD executive resolution" });
        Assert.Equal(HttpStatusCode.OK, stage3Response.StatusCode);

        var stage3Notifs = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.True(stage3Notifs.Count >= 5);
        var stage3Recipients = stage3Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, stage3Recipients);
        Assert.Contains(env.Em.Id, stage3Recipients);
        Assert.Contains(env.Tl.Id, stage3Recipients);
        Assert.Contains(env.Raiser.Id, stage3Recipients); // Raiser notified
        Assert.Contains(env.Spm.Id, stage3Recipients); // SPM notified at L2
        Assert.DoesNotContain(env.Hod.Id, stage3Recipients); // HOD actor excluded

        // Verify status is Resolved and SLA instance is marked Completed
        var updatedAlert = await db.ProjectAlerts.AsNoTracking().FirstOrDefaultAsync(a => a.Id == alert.Id);
        Assert.NotNull(updatedAlert);
        Assert.Equal("Resolved", updatedAlert.Status);

        var completedInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(completedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);
    }

    [Fact]
    public async Task IssueRaisedFromBucketList_StatusChange_NotifiesLeadershipAndRaiser()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        var env = await SetupIssueEnvironmentAsync(db);

        // 1. Employee raises issue via Action Centre -> Bucket List endpoint
        var raiserClient = CreateActorClient(env.Raiser);
        var bucketIssueForm = new CreateProjectIssueRequest
        {
            ProjectId = env.Project.Id,
            Subject = $"Bucket List Issue {Guid.NewGuid():N}",
            Description = "Raised from Action Centre Bucket List by team member.",
            IssueType = "Technical Related Issues",
            Priority = "High"
        };

        var response = await raiserClient.PostAsJsonAsync("/api/v1/action-centre/bucket-list/issues", bucketIssueForm);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var body = await response.Content.ReadFromJsonAsync<ApiResponse<ProjectIssueDto>>();
        Assert.NotNull(body?.Data);
        var issueId = body.Data.Id;

        var alert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.IssueId == issueId);
        Assert.NotNull(alert);

        // 2. Engagement Manager updates status to In Progress from Alert tab
        var emClient = CreateActorClient(env.Em);
        var updateRes = await emClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "In Progress", Comment = "EM moving bucket list issue to In Progress" });
        Assert.Equal(HttpStatusCode.OK, updateRes.StatusCode);

        var notifs = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        // Recipients: PM, TL, Raiser (EM excluded as updater)
        Assert.Equal(3, notifs.Count);
        var recipients = notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, recipients);
        Assert.Contains(env.Tl.Id, recipients);
        Assert.Contains(env.Raiser.Id, recipients); // Original raiser received notification
        Assert.DoesNotContain(env.Em.Id, recipients); // EM actor excluded
    }

    [Fact]
    public async Task EdgeCase_SamePersonAssignedMultipleRoles_ReceivesOnlyOneNotification()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        // Create environment where PM and TL are the same person (sharePmAndTl: true)
        var env = await SetupIssueEnvironmentAsync(db, sharePmAndTl: true);
        Assert.Equal(env.Pm.Id, env.Tl.Id);

        var raiserClient = CreateActorClient(env.Raiser);
        var issueForm = new CreateProjectIssueRequest
        {
            Subject = $"MultiRole Issue {Guid.NewGuid():N}",
            Description = "Testing multi-role deduplication for Issue Status Update.",
            IssueType = "Technical Related Issues",
            Priority = "High"
        };

        var createRes = await raiserClient.PostAsJsonAsync($"/api/v1/projects/{env.Project.Id}/issues", issueForm);
        Assert.Equal(HttpStatusCode.OK, createRes.StatusCode);

        var createBody = await createRes.Content.ReadFromJsonAsync<ApiResponse<ProjectIssueDto>>();
        Assert.NotNull(createBody?.Data);
        var issueId = createBody.Data.Id;

        var alert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.IssueId == issueId);
        Assert.NotNull(alert);

        // Raiser updates status from Open to In Progress
        var updateRes = await raiserClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "In Progress", Comment = "Raiser started work on issue" });
        Assert.Equal(HttpStatusCode.OK, updateRes.StatusCode);

        var notifs = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Status Update" && n.DeletedAtUtc == null)
            .ToListAsync();

        // Raiser is actor -> excluded.
        // Candidates: PM/TL, EM.
        // Because PM is also TL, exactly 1 notification is sent to PM/TL, and 1 to EM (Total: 2).
        Assert.Equal(2, notifs.Count);
        var pmTlNotifs = notifs.Where(n => n.RecipientEmployeeId == env.Pm.Id).ToList();
        Assert.Single(pmTlNotifs); // Exactly 1 notification, deduplicated!
        var emNotifs = notifs.Where(n => n.RecipientEmployeeId == env.Em.Id).ToList();
        Assert.Single(emNotifs);
    }
}
