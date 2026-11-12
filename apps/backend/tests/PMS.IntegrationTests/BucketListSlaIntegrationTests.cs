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
using PMS.API.Modules.Sla.DTOs;
using PMS.API.Modules.Sla.Jobs;
using PMS.API.Modules.Sla.Models;
using PMS.API.Modules.Sla.Services;
using PMS.API.Shared.Common.Wrappers;
using Xunit;

namespace PMS.IntegrationTests;

public class BucketListSlaIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public BucketListSlaIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(b =>
            b.UseSetting("Database:AutoMigrate", "false"));
        _client = _factory.CreateClient();
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "dev-bypass-token");
        _client.DefaultRequestHeaders.Add("X-User-Email", "admin@talakunchi.com");
    }

    [Fact]
    public async Task BucketList_TaskStart_Pause_Stop_Lifecycle_TracksSlaAndNotifications()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        // 1. Resolve an active project and a verified team member
        var teamMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.DeletedAtUtc == null && tm.MemberRole == "ProjectTeam");
        Assert.NotNull(teamMember);

        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == teamMember.ProjectId && p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var employee = await db.Employees.FirstOrDefaultAsync(e => e.Id == teamMember.EmployeeId && e.DeletedAtUtc == null);
        Assert.NotNull(employee);

        // 2. Create a test task in the project
        var createTaskReq = new CreateProjectTaskRequest(
            Title: $"Bucket List SLA Test Task {Guid.NewGuid():N}",
            Description: "Testing SLA workflow for Task Start, Pause, and Stop",
            PlannedStartDate: DateOnly.FromDateTime(DateTime.UtcNow),
            PlannedEndDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(3)),
            EstimatedHours: 8m,
            Priority: "High");

        var taskResponse = await _client.PostAsJsonAsync($"/api/v1/projects/{project.Id}/tasks", createTaskReq);
        Assert.True(taskResponse.IsSuccessStatusCode);

        var taskResult = await taskResponse.Content.ReadFromJsonAsync<ApiResponse<ProjectTaskDto>>();
        Assert.NotNull(taskResult?.Data);
        var taskId = taskResult.Data.Id;

        // 3. Assign employee to task via synchronize endpoint
        var assignResponse = await _client.PutAsJsonAsync(
            $"/api/v1/projects/{project.Id}/tasks/{taskId}/assignments",
            new SyncTaskAssignmentsRequest([employee.Id], "High"));
        Assert.Equal(HttpStatusCode.OK, assignResponse.StatusCode);

        // Verify Activity 1: Task Start After Assigning SLA tracking started
        var assignment = await db.ProjectTaskAssignments
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.EmployeeId == employee.Id && a.IsActive && a.DeletedAtUtc == null);
        Assert.NotNull(assignment);

        var startSla = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == assignment.Id && i.ActivityType == "Task Start After Assigning" && i.DeletedAtUtc == null);
        Assert.NotNull(startSla);
        Assert.Equal(SlaInstanceStatus.Tracking, startSla.Status);

        // Verify initial notifications for leadership and employee
        var assignNotifications = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.RelatedTask == taskResult.Data.Title && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(assignNotifications);

        // Verify Bucket Task was created for Action Centre
        var bucketTask = await db.BucketTasks
            .FirstOrDefaultAsync(b => b.TaskId == taskId && b.EmployeeId == employee.Id && b.DeletedAtUtc == null);
        Assert.NotNull(bucketTask);

        // 4. Start Bucket Task Timer
        var startTimerResponse = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/start-timer", null);
        Assert.Equal(HttpStatusCode.OK, startTimerResponse.StatusCode);

        // Verify Task Start After Assigning SLA is now Completed!
        var refreshedStartSla = await db.SlaInstances
            .AsNoTracking()
            .FirstOrDefaultAsync(i => i.Id == startSla.Id);
        Assert.NotNull(refreshedStartSla);
        Assert.Equal(SlaInstanceStatus.Completed, refreshedStartSla.Status);

        // 5. Pause Bucket Task Timer (Activity 4: Task Pause)
        var pauseTimerResponse = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/pause-timer", null);
        Assert.Equal(HttpStatusCode.OK, pauseTimerResponse.StatusCode);

        // Verify Task Pause SLA instance created with daily reminders (anchored to assignment.Id)
        var pauseSla = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == assignment.Id && i.ActivityType == "Task Pause" && i.DeletedAtUtc == null);
        Assert.NotNull(pauseSla);
        Assert.Equal(SlaInstanceStatus.Tracking, pauseSla.Status);

        // Verify Task Paused notification was created for leadership
        var pauseNotifications = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.Type == "Task Paused" && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(pauseNotifications);

        // 6. Stop Bucket Task Timer (Activity 3: Task Stop)
        var stopTimerResponse = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/stop-timer", null);
        Assert.Equal(HttpStatusCode.OK, stopTimerResponse.StatusCode);

        // Verify Task Stopped notification was created for leadership
        var stopNotifications = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.Type == "Task Stopped" && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(stopNotifications);
    }

    [Fact]
    public async Task TaskPause_DailyReminderExecution_DeliversOnlyToResource_AndNeverLeadership_AndResumeCancels()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve project with team member AND SeniorProjectManager
        var spmMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.MemberRole == ProjectMemberRoles.SeniorProjectManager && tm.DeletedAtUtc == null);
        Assert.NotNull(spmMember);

        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == spmMember.ProjectId && p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var teamMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.ProjectId == project.Id && tm.MemberRole == "ProjectTeam" && tm.DeletedAtUtc == null);
        Assert.NotNull(teamMember);

        var employee = await db.Employees.FirstOrDefaultAsync(e => e.Id == teamMember.EmployeeId && e.DeletedAtUtc == null);
        Assert.NotNull(employee);

        // 2. Create task and assign employee
        var taskTitle = $"Pause Reminder Test {Guid.NewGuid():N}";
        var createTaskReq = new CreateProjectTaskRequest(
            Title: taskTitle,
            Description: "Testing Pause reminders",
            PlannedStartDate: DateOnly.FromDateTime(DateTime.UtcNow),
            PlannedEndDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(3)),
            EstimatedHours: 4m,
            Priority: "Medium");

        var taskResponse = await _client.PostAsJsonAsync($"/api/v1/projects/{project.Id}/tasks", createTaskReq);
        Assert.True(taskResponse.IsSuccessStatusCode);
        var taskResult = await taskResponse.Content.ReadFromJsonAsync<ApiResponse<ProjectTaskDto>>();
        var taskId = taskResult!.Data.Id;

        await _client.PutAsJsonAsync(
            $"/api/v1/projects/{project.Id}/tasks/{taskId}/assignments",
            new SyncTaskAssignmentsRequest([employee.Id], "Medium"));

        var assignment = await db.ProjectTaskAssignments
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.EmployeeId == employee.Id && a.IsActive && a.DeletedAtUtc == null);
        Assert.NotNull(assignment);

        var bucketTask = await db.BucketTasks
            .FirstOrDefaultAsync(b => b.TaskId == taskId && b.EmployeeId == employee.Id && b.DeletedAtUtc == null);
        Assert.NotNull(bucketTask);

        // 3. Start timer then Pause timer
        await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/start-timer", null);
        var pauseResp = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/pause-timer", null);
        Assert.Equal(HttpStatusCode.OK, pauseResp.StatusCode);

        // 4. Verify Task Pause SLA instance created with reminder event
        db.ChangeTracker.Clear();
        var pauseSla = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == assignment.Id && i.ActivityType == "Task Pause" && i.DeletedAtUtc == null);
        Assert.NotNull(pauseSla);
        Assert.Equal(SlaInstanceStatus.Tracking, pauseSla.Status);
        Assert.Equal(employee.Id, pauseSla.RecipientEmployeeId);

        var reminderEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == pauseSla.Id && e.EventType == SlaEventType.Reminder && e.DeletedAtUtc == null);
        Assert.NotNull(reminderEvent);

        // 5. Execute worker reminder job
        db.ChangeTracker.Clear();
        await worker.ExecuteReminderAsync(pauseSla.Id, reminderEvent.Id);

        // 6. Verify daily reminder was created ONLY for assigned resource
        var reminderNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == taskTitle && n.Type == "Task Pause Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(reminderNotifs);

        foreach (var rn in reminderNotifs)
        {
            Assert.Equal(employee.Id, rn.RecipientEmployeeId);
            Assert.Equal($"Task Paused Reminder: {taskTitle}", rn.Title);
            Assert.Contains($"Your task {taskTitle} is still paused. Please resume the task or complete it.", rn.CommentsJson);
        }

        // 7. Verify NO reminder went to PM, EM, TL, SPM, or HOD
        var leadershipReminderCount = await db.ActionNotifications
            .CountAsync(n => n.RelatedTask == taskTitle && n.Type == "Task Pause Reminder" && n.RecipientEmployeeId != employee.Id && n.DeletedAtUtc == null);
        Assert.Equal(0, leadershipReminderCount);

        // 8. Resume task timer and verify Pause SLA is completed
        var resumeResp = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/start-timer", null);
        Assert.Equal(HttpStatusCode.OK, resumeResp.StatusCode);

        var refreshedPauseSla = await db.SlaInstances
            .AsNoTracking()
            .FirstOrDefaultAsync(i => i.Id == pauseSla.Id);
        Assert.NotNull(refreshedPauseSla);
        Assert.Equal(SlaInstanceStatus.Completed, refreshedPauseSla.Status);
    }

    [Fact]
    public async Task TaskStart_BreachExecution_TriggersL1ToAssignedSpm_AndL2ToDynamicHod()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve project with team member AND SeniorProjectManager
        var spmMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.MemberRole == ProjectMemberRoles.SeniorProjectManager && tm.DeletedAtUtc == null);
        Assert.NotNull(spmMember);

        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == spmMember.ProjectId && p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var teamMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.ProjectId == project.Id && tm.MemberRole == "ProjectTeam" && tm.DeletedAtUtc == null);
        Assert.NotNull(teamMember);

        var employee = await db.Employees.FirstOrDefaultAsync(e => e.Id == teamMember.EmployeeId && e.DeletedAtUtc == null);
        Assert.NotNull(employee);

        // 2. Create task and assign employee
        var taskTitle = $"L1-L2 Escalation Test {Guid.NewGuid():N}";
        var createTaskReq = new CreateProjectTaskRequest(
            Title: taskTitle,
            Description: "Testing L1 and L2 escalations",
            PlannedStartDate: DateOnly.FromDateTime(DateTime.UtcNow),
            PlannedEndDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(3)),
            EstimatedHours: 4m,
            Priority: "High");

        var taskResponse = await _client.PostAsJsonAsync($"/api/v1/projects/{project.Id}/tasks", createTaskReq);
        Assert.True(taskResponse.IsSuccessStatusCode);
        var taskResult = await taskResponse.Content.ReadFromJsonAsync<ApiResponse<ProjectTaskDto>>();
        var taskId = taskResult!.Data.Id;

        await _client.PutAsJsonAsync(
            $"/api/v1/projects/{project.Id}/tasks/{taskId}/assignments",
            new SyncTaskAssignmentsRequest([employee.Id], "High"));

        var assignment = await db.ProjectTaskAssignments
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.EmployeeId == employee.Id && a.IsActive && a.DeletedAtUtc == null);
        Assert.NotNull(assignment);

        var startSla = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == assignment.Id && i.ActivityType == "Task Start After Assigning" && i.DeletedAtUtc == null);
        Assert.NotNull(startSla);

        var breachEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == startSla.Id && e.EventType == SlaEventType.BreachCheck && e.DeletedAtUtc == null);
        Assert.NotNull(breachEvent);

        var esc1Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == startSla.Id && e.EventType == SlaEventType.EscalationL1 && e.DeletedAtUtc == null);
        Assert.NotNull(esc1Event);

        // 3. Execute L1 breach check and L1 escalation
        await worker.ExecuteBreachCheckAsync(startSla.Id, breachEvent.Id);
        await worker.ExecuteEscalationAsync(startSla.Id, esc1Event.Id, 1);

        // 4. Verify L1 notification sent to Assigned Senior Project Manager
        var l1Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == taskTitle && n.Type == "SLA Escalation" && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(l1Notifs);
        Assert.Contains(l1Notifs, n => n.Title.Contains("First Level Escalation") || n.Title.Contains("Level 1"));

        // 5. Verify dynamically scheduled L2 escalation event
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == startSla.Id && e.EventType == SlaEventType.EscalationL2 && e.DeletedAtUtc == null);
        Assert.NotNull(l2Event);
        Assert.Equal(SlaEventStatus.Scheduled, l2Event.Status);
        Assert.Equal($"sla:{startSla.Id}:esc-l2", l2Event.IdempotencyKey);

        // 6. Execute L2 escalation job
        await worker.ExecuteEscalationAsync(startSla.Id, l2Event.Id, 2);

        // 7. Verify L2 notification created for Head of Department
        var l2Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == taskTitle && n.Title.Contains("Second Level Escalation") && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(l2Notifs);

        // Verify HOD recipient matches Head Of Department on-floor role
        var hodRecipientId = l2Notifs.First().RecipientEmployeeId;
        var hodEmployee = await db.Employees.FirstOrDefaultAsync(e => e.Id == hodRecipientId);
        Assert.NotNull(hodEmployee);
    }

    [Fact]
    public async Task TaskDeadline_FullLifecycle_Midpoint_OneDayBefore_L1_DynamicL2_Reschedule_AndCancel()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var trackingService = scope.ServiceProvider.GetRequiredService<ISlaTrackingService>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve active project with Senior Project Manager
        var spmMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.MemberRole == ProjectMemberRoles.SeniorProjectManager && tm.DeletedAtUtc == null);
        Assert.NotNull(spmMember);

        var project = await db.Projects.FirstOrDefaultAsync(p => p.Id == spmMember.ProjectId && p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var teamMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.ProjectId == project.Id && tm.MemberRole == "ProjectTeam" && tm.DeletedAtUtc == null);
        Assert.NotNull(teamMember);

        // 2. Create a test project task with planned end date 4 days in future
        var taskId = Guid.NewGuid();
        var taskTitle = $"Deadline SLA Test Task {Guid.NewGuid():N}";
        var plannedEnd = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(4));

        var testTask = new ProjectTask
        {
            Id = taskId,
            ProjectId = project.Id,
            Title = taskTitle,
            Stage = "Ongoing",
            Priority = "High",
            PlannedStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            PlannedEndDate = plannedEnd,
            CreatedAtUtc = DateTime.UtcNow
        };
        db.ProjectTasks.Add(testTask);
        await db.SaveChangesAsync();

        // 3. Start Task Deadline SLA tracking
        var deadlineUtc = DateTime.UtcNow.AddDays(4);
        var instance = await trackingService.StartTrackingAsync(new SlaStartTrackingRequest(
            Module: "ActionCentre",
            ActivityType: "Task Deadline",
            EntityId: taskId,
            EntityReference: taskTitle,
            Stage: "Ongoing",
            Priority: SlaPriority.High,
            ProjectId: project.Id,
            RecipientEmployeeId: teamMember.EmployeeId,
            CustomDeadlineUtc: deadlineUtc,
            CustomStartTimeUtc: DateTime.UtcNow
        ));

        Assert.NotNull(instance);
        Assert.Equal(SlaInstanceStatus.Tracking, instance.Status);

        // 4. Verify scheduled milestones: Midpoint, 1-Day Before, BreachCheck, L1 Escalation
        var midpointEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.IdempotencyKey != null && e.IdempotencyKey.Contains("midpoint") && e.DeletedAtUtc == null);
        Assert.NotNull(midpointEvent);
        Assert.Equal(SlaEventStatus.Scheduled, midpointEvent.Status);

        var oneDayEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.IdempotencyKey != null && e.IdempotencyKey.Contains("1day") && e.DeletedAtUtc == null);
        Assert.NotNull(oneDayEvent);
        Assert.Equal(SlaEventStatus.Scheduled, oneDayEvent.Status);

        var breachEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.BreachCheck && e.DeletedAtUtc == null);
        Assert.NotNull(breachEvent);

        var l1EscEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL1 && e.DeletedAtUtc == null);
        Assert.NotNull(l1EscEvent);

        // 5. Execute Midpoint Reminder
        await worker.ExecuteReminderAsync(instance.Id, midpointEvent.Id);
        var midpointNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == taskTitle && n.Title.Contains("Midpoint Reminder") && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(midpointNotifs);

        // 6. Execute One-Day-Before Reminder
        await worker.ExecuteReminderAsync(instance.Id, oneDayEvent.Id);
        var oneDayNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == taskTitle && n.Title.Contains("Approaching Reminder") && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(oneDayNotifs);

        // 7. Execute L1 Escalation
        await worker.ExecuteBreachCheckAsync(instance.Id, breachEvent.Id);
        await worker.ExecuteEscalationAsync(instance.Id, l1EscEvent.Id, 1);

        var l1Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == taskTitle && n.Type == "SLA Escalation" && n.Title.Contains("First Level Escalation") && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(l1Notifs);

        // 8. Verify dynamic Level 2 escalation scheduled
        var l2Event = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == instance.Id && e.EventType == SlaEventType.EscalationL2 && e.DeletedAtUtc == null);
        Assert.NotNull(l2Event);
        Assert.Equal(SlaEventStatus.Scheduled, l2Event.Status);

        // Execute L2 Escalation
        await worker.ExecuteEscalationAsync(instance.Id, l2Event.Id, 2);
        var l2Notifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == taskTitle && n.Title.Contains("Second Level Escalation") && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(l2Notifs);

        // 9. Verify Rescheduling on WBS Deadline Change
        var newDeadlineUtc = DateTime.UtcNow.AddDays(7);
        var rescheduledInstance = await trackingService.RescheduleTrackingAsync(new SlaRescheduleRequest(
            EntityId: taskId,
            ActivityType: "Task Deadline",
            NewDeadlineUtc: newDeadlineUtc,
            Reason: "WBS planned end date extended"
        ));
        Assert.Equal(newDeadlineUtc, rescheduledInstance.TargetDeadlineUtc);

        // 10. Verify Invalidation on Completion
        var completedInstance = await trackingService.CompleteTrackingAsync(taskId, "Task Deadline");
        Assert.Equal(SlaInstanceStatus.Completed, completedInstance.Status);

        var pendingEventsAfterComplete = await db.SlaEvents
            .Where(e => e.InstanceId == instance.Id && e.Status == SlaEventStatus.Scheduled && e.DeletedAtUtc == null)
            .ToListAsync();
        Assert.Empty(pendingEventsAfterComplete);
    }
}
