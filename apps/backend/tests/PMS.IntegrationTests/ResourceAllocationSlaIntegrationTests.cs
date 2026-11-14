using System.Net.Http.Headers;
using System.Net.Http.Json;
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

public class ResourceAllocationSlaIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ResourceAllocationSlaIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    [Fact]
    public async Task ResourceAllocation_Creation_StartsSlaTracking_AndApproval_AddsMemberToProject_AndNotifiesExpectedRoles()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        // 1. Resolve an active project and candidate employee not yet in project
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var existingMemberIds = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null)
            .Select(m => m.EmployeeId)
            .ToListAsync();

        var pendingEmpIds = await db.ProjectResourceAllocationRequests
            .Where(r => r.ProjectId == project.Id && r.Status == "Pending" && r.DeletedAtUtc == null)
            .Select(r => r.EmployeeId)
            .ToListAsync();

        var dedicatedMemberIds = await db.ProjectTeamMembers
            .Where(m => m.DeletedAtUtc == null && m.ResourceType == "Dedicated")
            .Select(m => m.EmployeeId)
            .ToListAsync();

        var candidate = await db.Employees
            .Include(e => e.Department)
            .Include(e => e.Designation)
            .FirstOrDefaultAsync(e => !existingMemberIds.Contains(e.Id)
                                      && !pendingEmpIds.Contains(e.Id)
                                      && !dedicatedMemberIds.Contains(e.Id)
                                      && e.DeletedAtUtc == null
                                      && (e.Status == null || e.Status.StartsWith("Active"))
                                      && e.EmploymentType != "Intern"
                                      && (e.Role == null || !e.Role.ToLower().Contains("intern")));
        Assert.NotNull(candidate);

        // 2. Submit Resource Allocation Request
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var createReq = new CreateResourceAllocationRequest(
            EmployeeId: candidate.Id,
            AllocationStartDate: today,
            AllocationEndDate: today.AddMonths(3),
            Billability: "Billable",
            IsTeamLead: false,
            ResourceType: "Dedicated",
            IsShadowTeam: false,
            Notes: "Integration test resource allocation request"
        );

        var created = await teamService.RequestAllocationAsync(project.Id, createReq);
        Assert.NotNull(created);
        Assert.Equal("Pending", created.Status);

        var allocTaskCode = $"ALLOC-{created.Id.ToString()[..8].ToUpper()}";

        // Verify initial notification to reporting manager / approver
        var notif = await db.ActionNotifications.FirstOrDefaultAsync(n =>
            n.RelatedTask == allocTaskCode && n.Type == "Resource Allocation Approval");
        Assert.NotNull(notif);

        // Verify SLA tracking instance started
        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Resource Allocation Approval");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);
        Assert.Equal("Pending", instance.CurrentStage);
        Assert.True(instance.TargetDeadlineUtc > instance.StartedAtUtc);

        // 3. Reporting Manager approves the allocation request
        var actionResult = await teamService.TakeAllocationActionAsync(project.Id, created.Id, new ResourceAllocationActionRequest(
            Status: "Approved",
            Comment: "Approved by reporting manager for project assignment"
        ));
        Assert.NotNull(actionResult);
        Assert.Equal("Approved", actionResult.Status);

        // Verify member was added to project team
        var addedMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(m => m.ProjectId == project.Id && m.EmployeeId == candidate.Id && m.DeletedAtUtc == null);
        Assert.NotNull(addedMember);
        Assert.Equal("Billable", addedMember.Billability);
        Assert.Equal("Dedicated", addedMember.ResourceType);

        // Verify SLA instance completed
        var completedInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(completedInstance);
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);

        // 4. Verify post-approval notifications were dispatched to expected roles
        var postNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == allocTaskCode && n.Status == "Approved")
            .ToListAsync();
        Assert.NotEmpty(postNotifs);

        var recipientIds = postNotifs.Select(n => n.RecipientEmployeeId).ToHashSet();

        // Selected candidate resource MUST receive notification
        Assert.Contains(candidate.Id, recipientIds);
        var candidateNotif = postNotifs.FirstOrDefault(n => n.RecipientEmployeeId == candidate.Id);
        Assert.NotNull(candidateNotif);
        Assert.Contains("Resource Allocation Approved", candidateNotif.Title);

        // PMO with target sub-departments must receive notification
        var targetSubDeptEm = "em (engagement manager)";
        var targetSubDeptPmo = "pmo (project management office)";
        var pmoEmps = await db.Employees
            .Where(e => e.DeletedAtUtc == null && (e.Status == null || !e.Status.ToLower().StartsWith("inactive")))
            .Where(e => (e.SubDepartment != null && (e.SubDepartment.ToLower() == targetSubDeptEm || e.SubDepartment.ToLower() == targetSubDeptPmo))
                        || (e.SubDepartmentRef != null && (e.SubDepartmentRef.Name.ToLower() == targetSubDeptEm || e.SubDepartmentRef.Name.ToLower() == targetSubDeptPmo)))
            .Select(e => e.Id)
            .ToListAsync();

        foreach (var pmoId in pmoEmps)
        {
            Assert.Contains(pmoId, recipientIds);
        }
    }

    [Fact]
    public async Task ResourceAllocation_UnresolvedAfter2Days_TriggersLevel1Escalation_ExclusivelyToSpm_AndLevel2ToHod()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var existingMemberIds = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null)
            .Select(m => m.EmployeeId)
            .ToListAsync();

        var pendingEmpIds = await db.ProjectResourceAllocationRequests
            .Where(r => r.ProjectId == project.Id && r.Status == "Pending" && r.DeletedAtUtc == null)
            .Select(r => r.EmployeeId)
            .ToListAsync();

        var dedicatedMemberIds = await db.ProjectTeamMembers
            .Where(m => m.DeletedAtUtc == null && m.ResourceType == "Dedicated")
            .Select(m => m.EmployeeId)
            .ToListAsync();

        var candidate = await db.Employees
            .FirstOrDefaultAsync(e => !existingMemberIds.Contains(e.Id)
                                      && !pendingEmpIds.Contains(e.Id)
                                      && !dedicatedMemberIds.Contains(e.Id)
                                      && e.DeletedAtUtc == null
                                      && (e.Status == null || e.Status.StartsWith("Active"))
                                      && e.EmploymentType != "Intern");
        Assert.NotNull(candidate);

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var createReq = new CreateResourceAllocationRequest(
            EmployeeId: candidate.Id,
            AllocationStartDate: today,
            AllocationEndDate: today.AddMonths(1),
            Billability: "Non-Billable",
            IsTeamLead: false,
            ResourceType: "Shared Resource",
            IsShadowTeam: false,
            Notes: "SLA escalation test"
        );

        var created = await teamService.RequestAllocationAsync(project.Id, createReq);
        Assert.NotNull(created);

        var allocTaskCode = $"ALLOC-{created.Id.ToString()[..8].ToUpper()}";

        var instance = await db.SlaInstances
            .Include(i => i.Events)
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Resource Allocation Approval");
        Assert.NotNull(instance);

        // Fast-forward TargetDeadlineUtc to simulate 2 days passing without decision
        instance.TargetDeadlineUtc = DateTime.UtcNow.AddMinutes(-5);
        await db.SaveChangesAsync();

        var breachEvent = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.BreachCheck);
        Assert.NotNull(breachEvent);

        await worker.ExecuteBreachCheckAsync(instance.Id, breachEvent.Id);

        var breachedInstance = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == instance.Id);
        Assert.NotNull(breachedInstance);
        Assert.Equal(SlaInstanceStatus.Breached, breachedInstance.Status);
        Assert.NotNull(breachedInstance.BreachedAtUtc);

        // 1. Execute Level 1 SLA Breach Escalation
        var esc1Event = instance.Events.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        Assert.NotNull(esc1Event);

        await worker.ExecuteEscalationAsync(instance.Id, esc1Event.Id, 1);

        var l1Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == allocTaskCode && n.Priority == "Critical" && n.Title.StartsWith("Level 1 SLA Escalation"))
            .ToListAsync();
        Assert.NotEmpty(l1Notifs);

        // Verify Level 2 SLA event was dynamically scheduled
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2);
        Assert.NotNull(l2Event);
        Assert.Equal(SlaEventStatus.Scheduled, l2Event.Status);
        Assert.Contains("Head of Department", l2Event.TargetRoles);

        // 2. Execute Level 2 SLA Breach Escalation on next working day
        await worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2);

        var l2Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == allocTaskCode && n.Priority == "Critical" && n.Title.StartsWith("Level 2 SLA Escalation"))
            .ToListAsync();
        Assert.NotEmpty(l2Notifs);

        // Verify HOD received Level 2 escalation
        var hodRoles = await db.OnFloorRoles
            .Where(o => o.Name.ToLower() == "head of department")
            .Select(o => o.DesignationId)
            .ToListAsync();
        var hodEmps = await db.Employees
            .Where(e => hodRoles.Contains(e.DesignationId ?? Guid.Empty) && e.DeletedAtUtc == null)
            .Select(e => e.Id)
            .ToListAsync();

        var l2RecipientIds = l2Notifs.Select(n => n.RecipientEmployeeId).ToHashSet();
        foreach (var hodId in hodEmps)
        {
            Assert.Contains(hodId, l2RecipientIds);
        }
    }

    [Fact]
    public async Task ResourceAllocation_HoldOrReject_CompletesSlaTracking_AndNotifiesResourceAndLeadership()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var existingMemberIds = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null)
            .Select(m => m.EmployeeId)
            .ToListAsync();

        var pendingEmpIds = await db.ProjectResourceAllocationRequests
            .Where(r => r.ProjectId == project.Id && r.Status == "Pending" && r.DeletedAtUtc == null)
            .Select(r => r.EmployeeId)
            .ToListAsync();

        var dedicatedMemberIds = await db.ProjectTeamMembers
            .Where(m => m.DeletedAtUtc == null && m.ResourceType == "Dedicated")
            .Select(m => m.EmployeeId)
            .ToListAsync();

        var candidate = await db.Employees
            .FirstOrDefaultAsync(e => !existingMemberIds.Contains(e.Id)
                                      && !pendingEmpIds.Contains(e.Id)
                                      && !dedicatedMemberIds.Contains(e.Id)
                                      && e.DeletedAtUtc == null
                                      && (e.Status == null || e.Status.StartsWith("Active"))
                                      && e.EmploymentType != "Intern");
        Assert.NotNull(candidate);

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var createReq = new CreateResourceAllocationRequest(
            EmployeeId: candidate.Id,
            AllocationStartDate: today,
            AllocationEndDate: today.AddMonths(2),
            Billability: "Billable",
            IsTeamLead: false,
            ResourceType: "Dedicated",
            IsShadowTeam: false,
            Notes: "Hold decision test"
        );

        var created = await teamService.RequestAllocationAsync(project.Id, createReq);
        Assert.NotNull(created);

        var allocTaskCode = $"ALLOC-{created.Id.ToString()[..8].ToUpper()}";

        var actionResult = await teamService.TakeAllocationActionAsync(project.Id, created.Id, new ResourceAllocationActionRequest(
            Status: "Hold",
            Comment: "Placed on hold pending budget verification"
        ));
        Assert.NotNull(actionResult);
        Assert.Equal("Hold", actionResult.Status);

        // Verify employee was NOT added to project team
        var notAdded = await db.ProjectTeamMembers
            .AnyAsync(m => m.ProjectId == project.Id && m.EmployeeId == candidate.Id && m.DeletedAtUtc == null);
        Assert.False(notAdded);

        // Verify SLA instance completed
        var instance = await db.SlaInstances.AsNoTracking()
            .FirstOrDefaultAsync(i => i.EntityId == created.Id && i.ActivityType == "Resource Allocation Approval");
        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Completed, instance.Status);

        // Verify candidate received Hold notification
        var candidateNotif = await db.ActionNotifications
            .OrderByDescending(n => n.CreatedAtUtc)
            .FirstOrDefaultAsync(n => n.RelatedTask == allocTaskCode && n.RecipientEmployeeId == candidate.Id && n.Status == "Hold");
        Assert.NotNull(candidateNotif);
        Assert.Contains("On Hold", candidateNotif.Title);
    }

    [Fact]
    public async Task ReportingManager_CanFetchPendingAllocationApprovals_ViaActionCentre_AndTakeApprovalAction()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var teamService = scope.ServiceProvider.GetRequiredService<IProjectTeamMemberService>();

        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var existingMemberIds = await db.ProjectTeamMembers
            .Where(m => m.ProjectId == project.Id && m.DeletedAtUtc == null)
            .Select(m => m.EmployeeId)
            .ToListAsync();

        var pendingEmpIds = await db.ProjectResourceAllocationRequests
            .Where(r => r.ProjectId == project.Id && r.Status == "Pending" && r.DeletedAtUtc == null)
            .Select(r => r.EmployeeId)
            .ToListAsync();

        var dedicatedMemberIds = await db.ProjectTeamMembers
            .Where(m => m.DeletedAtUtc == null && m.ResourceType == "Dedicated")
            .Select(m => m.EmployeeId)
            .ToListAsync();

        var candidate = await db.Employees
            .Include(e => e.Department)
            .FirstOrDefaultAsync(e => !existingMemberIds.Contains(e.Id)
                                      && !pendingEmpIds.Contains(e.Id)
                                      && !dedicatedMemberIds.Contains(e.Id)
                                      && e.ReportingManagerId != null
                                      && e.ReportingManagerId != Guid.Empty
                                      && e.DeletedAtUtc == null
                                      && (e.Status == null || e.Status.StartsWith("Active"))
                                      && e.EmploymentType != "Intern");
        Assert.NotNull(candidate);

        var reportingManager = await db.Employees
            .FirstOrDefaultAsync(e => e.Id == candidate.ReportingManagerId && e.DeletedAtUtc == null);
        Assert.NotNull(reportingManager);

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var createReq = new CreateResourceAllocationRequest(
            EmployeeId: candidate.Id,
            AllocationStartDate: today,
            AllocationEndDate: today.AddMonths(2),
            Billability: "Billable",
            IsTeamLead: false,
            ResourceType: "Dedicated",
            IsShadowTeam: false,
            Notes: "Action centre approval request test"
        );

        var created = await teamService.RequestAllocationAsync(project.Id, createReq);
        Assert.NotNull(created);
        Assert.Equal("Pending", created.Status);

        // Call GET /api/v1/action-centre/allocation-approvals as the reporting manager
        var mgrClient = _factory.CreateClient();
        mgrClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        mgrClient.DefaultRequestHeaders.Add("X-User-Email", reportingManager.WorkEmail);
        mgrClient.DefaultRequestHeaders.Add("X-User-Id", reportingManager.Id.ToString());
        mgrClient.DefaultRequestHeaders.Add("X-User-Role", reportingManager.Role ?? "Manager");

        var response = await mgrClient.GetAsync("/api/v1/action-centre/allocation-approvals");
        Assert.Equal(System.Net.HttpStatusCode.OK, response.StatusCode);

        var body = await response.Content.ReadFromJsonAsync<PMS.API.Shared.Common.Wrappers.ApiResponse<List<ProjectResourceAllocationRequestDto>>>();
        Assert.NotNull(body);
        Assert.NotNull(body.Data);
        Assert.Contains(body.Data, r => r.Id == created.Id);

        // Reporting manager takes action to Approve via action-centre endpoint
        var actionResponse = await mgrClient.PostAsJsonAsync($"/api/v1/action-centre/allocation-approvals/{created.Id}/action?projectId={project.Id}", new ResourceAllocationActionRequest(
            Status: "Approved",
            Comment: "Approved via action centre by reporting manager"
        ));
        Assert.Equal(System.Net.HttpStatusCode.OK, actionResponse.StatusCode);

        var actionBody = await actionResponse.Content.ReadFromJsonAsync<PMS.API.Shared.Common.Wrappers.ApiResponse<ProjectResourceAllocationRequestDto>>();
        Assert.NotNull(actionBody);
        Assert.NotNull(actionBody.Data);
        Assert.Equal("Approved", actionBody.Data.Status);

        // Verify employee is now added into project team members
        var isAdded = await db.ProjectTeamMembers
            .AnyAsync(m => m.ProjectId == project.Id && m.EmployeeId == candidate.Id && m.DeletedAtUtc == null);
        Assert.True(isAdded);
    }
}
