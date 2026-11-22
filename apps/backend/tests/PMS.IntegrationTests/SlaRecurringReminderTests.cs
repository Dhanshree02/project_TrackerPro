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
using PMS.API.Modules.Projects.Services;
using PMS.API.Modules.Resources.Models;
using PMS.API.Modules.Sla.Jobs;
using PMS.API.Modules.Sla.Models;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class SlaRecurringReminderTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;

    public SlaRecurringReminderTests(WebApplicationFactory<Program> factory)
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
        SetupWbsEnvironmentAsync(AppDbContext db)
    {
        var uniqueSuffix = Guid.NewGuid().ToString("N")[..8];

        var pm = await CreateEmployeeAsync(db, $"PM_{uniqueSuffix}", "Manager", "PMO (Project Management Office)", "ProjectManager");
        var em = await CreateEmployeeAsync(db, $"EM_{uniqueSuffix}", "Manager", "EM (Engagement Manager)", "EngagementManager");
        var tl = await CreateEmployeeAsync(db, $"TL_{uniqueSuffix}", "Lead", "Engineering", "TeamLead");

        var client = await db.Clients.FirstOrDefaultAsync(c => c.DeletedAtUtc == null);
        var project = new Project
        {
            Id = Guid.NewGuid(),
            Name = $"WBS Reminder Test Project {uniqueSuffix}",
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

        var spm = await CreateEmployeeAsync(db, $"SPM_{uniqueSuffix}", "SeniorManager", "Senior Project Management", "SeniorProjectManager");
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            ProjectId = project.Id,
            EmployeeId = spm.Id,
            MemberRole = ProjectMemberRoles.SeniorProjectManager,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-10)),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(100))
        });

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

        var stakeholder = await CreateEmployeeAsync(db, $"Stakeholder_{uniqueSuffix}", "Coordinator", "PMO (Project Management Office)", "PMO");

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

    private async Task<(Project Project, Employee Pm, Employee Em, Employee Tl, Employee Spm, Employee Hod, Employee Raiser)>
        SetupIssueEnvironmentAsync(AppDbContext db, bool sharePmAndTl = false)
    {
        var uniqueSuffix = Guid.NewGuid().ToString("N")[..8];

        var pm = await CreateEmployeeAsync(db, $"PM_{uniqueSuffix}", "Manager", "PMO (Project Management Office)", "ProjectManager");
        var em = await CreateEmployeeAsync(db, $"EM_{uniqueSuffix}", "Manager", "EM (Engagement Manager)", "EngagementManager");
        var tl = sharePmAndTl ? pm : await CreateEmployeeAsync(db, $"TL_{uniqueSuffix}", "Lead", "Engineering", "TeamLead");

        var client = await db.Clients.FirstOrDefaultAsync(c => c.DeletedAtUtc == null);
        var project = new Project
        {
            Id = Guid.NewGuid(),
            Name = $"Issue Reminder Test Project {uniqueSuffix}",
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

        var spm = await CreateEmployeeAsync(db, $"SPM_{uniqueSuffix}", "SeniorManager", "Senior Project Management", "SeniorProjectManager");
        db.ProjectTeamMembers.Add(new ProjectTeamMember
        {
            ProjectId = project.Id,
            EmployeeId = spm.Id,
            MemberRole = ProjectMemberRoles.SeniorProjectManager,
            AllocationStartDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-10)),
            AllocationEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(100))
        });

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

        var raiser = await CreateEmployeeAsync(db, $"Raiser_{uniqueSuffix}", "Developer", "Engineering", "Employee");

        return (project, pm, em, tl, spm, hod, raiser);
    }

    [Fact]
    public async Task WbsEscalation_RecurringReminders_Initial_L1_L2_AndStopOnResolved()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var escalationService = scope.ServiceProvider.GetRequiredService<IProjectServiceEscalationService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var env = await SetupWbsEnvironmentAsync(db);

        // 1. Raise WBS Escalation
        var createRequest = new CreateProjectServiceEscalationForm
        {
            ProjectServiceId = env.Service.Id,
            ServiceName = env.Service.ServiceName,
            EscalationType = "Prerequisite Pending",
            Priority = "High",
            Subject = $"WBS Reminder Test Subject {Guid.NewGuid():N}",
            Description = "Testing WBS recurring reminder notifications across all stages.",
            StakeholderIds = [env.Stakeholder.Id]
        };

        var dto = await escalationService.CreateAsync(env.Project.Id, createRequest);
        Assert.NotNull(dto);

        var escalationId = dto.Id;
        var alert = await db.ProjectAlerts.FirstOrDefaultAsync(a => a.ServiceEscalationId == escalationId);
        Assert.NotNull(alert);

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == escalationId && i.ActivityType == "WBS Escalation");
        Assert.NotNull(instance);

        // =========================================================================
        // STAGE 1: Initial Stage -> Reminder to Selected Stakeholder ONLY
        // =========================================================================
        var remEventInitial = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:test-init"
        };
        db.SlaEvents.Add(remEventInitial);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEventInitial.Id);

        var stage1Reminders = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == escalationId && n.Type == "WBS Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Single(stage1Reminders);
        var r1 = stage1Reminders[0];
        Assert.Equal(env.Stakeholder.Id, r1.RecipientEmployeeId);
        Assert.Equal("WBS Escalation Reminder", r1.Type);
        Assert.Equal("Low", r1.Priority);
        Assert.Equal("Pending", r1.Status);
        Assert.True(r1.Unread);
        Assert.Equal("SLA Automation Engine", r1.RaisedByName);
        Assert.Contains(env.Project.Name, r1.Title);
        var expectedAlertCode = $"ALT-{alert.Id.ToString()[..8].ToUpperInvariant()}";
        Assert.Contains(expectedAlertCode, r1.Title);

        // =========================================================================
        // STAGE 2: After Level 1 Escalation -> Reminder to Stakeholder AND SPM
        // =========================================================================
        var escL1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        Assert.NotNull(escL1Event);
        await worker.ExecuteEscalationAsync(instance.Id, escL1Event.Id, 1);

        // Clear stage 1 reminder notifications for clean verification
        db.ActionNotifications.RemoveRange(stage1Reminders);
        await db.SaveChangesAsync();

        var remEventL1 = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:test-l1"
        };
        db.SlaEvents.Add(remEventL1);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEventL1.Id);

        var stage2Reminders = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == escalationId && n.Type == "WBS Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(2, stage2Reminders.Count);
        var stage2Recipients = stage2Reminders.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Stakeholder.Id, stage2Recipients);
        Assert.Contains(env.Spm.Id, stage2Recipients);
        Assert.DoesNotContain(env.Hod.Id, stage2Recipients);

        // =========================================================================
        // STAGE 3: After Level 2 Escalation -> Reminder to Stakeholder, SPM, AND HOD
        // =========================================================================
        var updatedEvents = await db.SlaEvents.Where(e => e.InstanceId == instance.Id).ToListAsync();
        var escL2Event = updatedEvents.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL2);
        Assert.NotNull(escL2Event);
        await worker.ExecuteEscalationAsync(instance.Id, escL2Event.Id, 2);

        // Clear stage 2 reminder notifications for clean verification
        db.ActionNotifications.RemoveRange(stage2Reminders);
        await db.SaveChangesAsync();

        var remEventL2 = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:test-l2"
        };
        db.SlaEvents.Add(remEventL2);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEventL2.Id);

        var stage3Reminders = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == escalationId && n.Type == "WBS Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.True(stage3Reminders.Count >= 3);
        var stage3Recipients = stage3Reminders.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Stakeholder.Id, stage3Recipients);
        Assert.Contains(env.Spm.Id, stage3Recipients);
        Assert.Contains(env.Hod.Id, stage3Recipients);

        // =========================================================================
        // STAGE 4: Resolution / Closure -> Reminders stop immediately
        // =========================================================================
        var spmClient = CreateActorClient(env.Spm);
        var resolveResponse = await spmClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Resolved", Comment = "Issue resolved by SPM" });
        Assert.Equal(HttpStatusCode.OK, resolveResponse.StatusCode);

        db.ChangeTracker.Clear();
        // Clear existing reminders
        var existingWbsReminders = await db.ActionNotifications.Where(n => n.ServiceEscalationId == escalationId && n.Type == "WBS Escalation Reminder").ToListAsync();
        db.ActionNotifications.RemoveRange(existingWbsReminders);
        await db.SaveChangesAsync();

        var remEventAfterResolved = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:test-after-resolved"
        };
        db.SlaEvents.Add(remEventAfterResolved);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEventAfterResolved.Id);

        var remindersAfterResolved = await db.ActionNotifications
            .Where(n => n.ServiceEscalationId == escalationId && n.Type == "WBS Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Empty(remindersAfterResolved);

        var finalInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.Equal(SlaInstanceStatus.Completed, finalInstance?.Status);
    }

    [Fact]
    public async Task RaiseIssue_RecurringReminders_Initial_L1_L2_AndStopOnResolved()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var env = await SetupIssueEnvironmentAsync(db);

        // 1. Raiser raises an issue via Project -> Health -> Issue API
        var raiserClient = CreateActorClient(env.Raiser);
        var issueForm = new CreateProjectIssueRequest
        {
            Subject = $"Integration Issue Reminders {Guid.NewGuid():N}",
            Description = "Testing Raise Issue recurring reminders matrix.",
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
        // STAGE 1: Initial Stage -> Reminder to PM, EM, TL
        // =========================================================================
        var remEventInitial = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:test-issue-init"
        };
        db.SlaEvents.Add(remEventInitial);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEventInitial.Id);

        var stage1Reminders = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(3, stage1Reminders.Count);
        var stage1Recipients = stage1Reminders.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, stage1Recipients);
        Assert.Contains(env.Em.Id, stage1Recipients);
        Assert.Contains(env.Tl.Id, stage1Recipients);
        Assert.DoesNotContain(env.Spm.Id, stage1Recipients);
        Assert.DoesNotContain(env.Hod.Id, stage1Recipients);

        var r1 = stage1Reminders[0];
        Assert.Equal("Issue Escalation Reminder", r1.Type);
        Assert.Equal("Low", r1.Priority);
        Assert.Equal("Pending", r1.Status);
        Assert.True(r1.Unread);
        Assert.Equal("SLA Automation Engine", r1.RaisedByName);
        Assert.Contains(env.Project.Name, r1.Title);
        var expectedAlertCode = $"ALT-{alert.Id.ToString()[..8].ToUpperInvariant()}";
        Assert.Contains(expectedAlertCode, r1.Title);

        // =========================================================================
        // STAGE 2: After Level 1 Escalation -> Reminder to PM, EM, TL, AND SPM
        // =========================================================================
        var escL1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        Assert.NotNull(escL1Event);
        await worker.ExecuteEscalationAsync(instance.Id, escL1Event.Id, 1);

        // Clear stage 1 reminders
        db.ActionNotifications.RemoveRange(stage1Reminders);
        await db.SaveChangesAsync();

        var remEventL1 = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:test-issue-l1"
        };
        db.SlaEvents.Add(remEventL1);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEventL1.Id);

        var stage2Reminders = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Equal(4, stage2Reminders.Count);
        var stage2Recipients = stage2Reminders.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, stage2Recipients);
        Assert.Contains(env.Em.Id, stage2Recipients);
        Assert.Contains(env.Tl.Id, stage2Recipients);
        Assert.Contains(env.Spm.Id, stage2Recipients);
        Assert.DoesNotContain(env.Hod.Id, stage2Recipients);

        // =========================================================================
        // STAGE 3: After Level 2 Escalation -> Reminder to PM, EM, TL, SPM, AND HOD
        // =========================================================================
        var updatedEvents = await db.SlaEvents.Where(e => e.InstanceId == instance.Id).ToListAsync();
        var escL2Event = updatedEvents.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL2);
        Assert.NotNull(escL2Event);
        await worker.ExecuteEscalationAsync(instance.Id, escL2Event.Id, 2);

        // Clear stage 2 reminders
        db.ActionNotifications.RemoveRange(stage2Reminders);
        await db.SaveChangesAsync();

        var remEventL2 = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:test-issue-l2"
        };
        db.SlaEvents.Add(remEventL2);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEventL2.Id);

        var stage3Reminders = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.True(stage3Reminders.Count >= 5);
        var stage3Recipients = stage3Reminders.Select(n => n.RecipientEmployeeId).ToHashSet();
        Assert.Contains(env.Pm.Id, stage3Recipients);
        Assert.Contains(env.Em.Id, stage3Recipients);
        Assert.Contains(env.Tl.Id, stage3Recipients);
        Assert.Contains(env.Spm.Id, stage3Recipients);
        Assert.Contains(env.Hod.Id, stage3Recipients);

        // =========================================================================
        // STAGE 4: Resolution / Closure -> Reminders stop immediately
        // =========================================================================
        var pmClient = CreateActorClient(env.Pm);
        var resolveResponse = await pmClient.PutAsJsonAsync(
            $"/api/v1/action-centre/alerts/{alert.Id}/governance",
            new UpdateAlertGovernanceRequest { Status = "Resolved", Comment = "Issue resolved by PM" });
        Assert.Equal(HttpStatusCode.OK, resolveResponse.StatusCode);

        db.ChangeTracker.Clear();
        // Clear stage 3 reminders
        var existingIssueReminders = await db.ActionNotifications.Where(n => n.IssueId == issueId && n.Type == "Issue Escalation Reminder").ToListAsync();
        db.ActionNotifications.RemoveRange(existingIssueReminders);
        await db.SaveChangesAsync();

        var remEventAfterResolved = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:test-issue-after-resolved"
        };
        db.SlaEvents.Add(remEventAfterResolved);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEventAfterResolved.Id);

        var remindersAfterResolved = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        Assert.Empty(remindersAfterResolved);

        var finalInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.Equal(SlaInstanceStatus.Completed, finalInstance?.Status);
    }

    [Fact]
    public async Task RecurringReminders_MultiRoleDeduplication_AndIdempotency()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // Environment where PM is also the Team Lead
        var env = await SetupIssueEnvironmentAsync(db, sharePmAndTl: true);

        var raiserClient = CreateActorClient(env.Raiser);
        var issueForm = new CreateProjectIssueRequest
        {
            Subject = $"Deduplication Issue {Guid.NewGuid():N}",
            Description = "Testing multi-role deduplication and idempotency.",
            IssueType = "Technical Related Issues",
            Priority = "Medium"
        };

        var createRes = await raiserClient.PostAsJsonAsync($"/api/v1/projects/{env.Project.Id}/issues", issueForm);
        Assert.Equal(HttpStatusCode.OK, createRes.StatusCode);

        var createBody = await createRes.Content.ReadFromJsonAsync<ApiResponse<ProjectIssueDto>>();
        Assert.NotNull(createBody?.Data);
        var issueId = createBody.Data.Id;

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == issueId && i.ActivityType == "Resolution of Issues");
        Assert.NotNull(instance);

        // 1. Execute reminder
        var remEvent1 = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:dedup-1"
        };
        db.SlaEvents.Add(remEvent1);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEvent1.Id);

        var reminders = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        // PM is also TL -> Exactly 2 distinct recipients: PM and EM
        Assert.Equal(2, reminders.Count);
        var pmCount = reminders.Count(n => n.RecipientEmployeeId == env.Pm.Id);
        Assert.Equal(1, pmCount);

        // 2. Execute reminder again on the same day (idempotency check)
        var remEvent2 = new SlaEvent
        {
            InstanceId = instance.Id,
            EventType = SlaEventType.Reminder,
            ScheduledAtUtc = DateTime.UtcNow,
            StageAtExecution = instance.CurrentStage,
            Status = SlaEventStatus.Scheduled,
            IdempotencyKey = $"sla:{instance.Id}:rem:dedup-2"
        };
        db.SlaEvents.Add(remEvent2);
        await db.SaveChangesAsync();

        await worker.ExecuteReminderAsync(instance.Id, remEvent2.Id);

        var afterReminders = await db.ActionNotifications
            .Where(n => n.IssueId == issueId && n.Type == "Issue Escalation Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();

        // Still exactly 2 reminders (no duplicate created on the same day)
        Assert.Equal(2, afterReminders.Count);
    }
}
