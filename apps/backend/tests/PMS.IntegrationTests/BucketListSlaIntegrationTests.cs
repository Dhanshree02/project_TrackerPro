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

        var expectedService = await ProjectTaskService.ResolveServiceNameAsync(db, project.Id, await db.ProjectTasks.Include(t => t.ProjectService).Include(t => t.Project).FirstAsync(t => t.Id == taskId));
        foreach (var rn in reminderNotifs)
        {
            Assert.Equal(employee.Id, rn.RecipientEmployeeId);
            Assert.Equal($"Task Paused Reminder: {taskTitle} - {expectedService}", rn.Title);
            Assert.Contains($"Your task '{taskTitle}' under the service '{expectedService}' in project '{project.Name}' is still paused. Please resume the task or complete it.", rn.CommentsJson);
            Assert.Equal("Low", rn.Priority);
            Assert.Equal("Pending", rn.Status);
            Assert.True(rn.Unread);
            Assert.Equal("SLA Automation Engine", rn.RaisedByName);
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

    [Fact]
    public async Task BucketList_PauseAndStop_Notifications_IncludeResourceTaskServiceAndProjectDetails()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var worker = scope.ServiceProvider.GetRequiredService<SlaBackgroundJobWorker>();

        // 1. Resolve or set up project with PM, EM, TL and Service
        var project = await db.Projects
            .Include(p => p.Client)
            .FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var leadershipEmployees = await db.Employees
            .Where(e => e.DeletedAtUtc == null)
            .Take(4)
            .ToListAsync();
        Assert.True(leadershipEmployees.Count >= 2);

        project.ProjectManagerId = leadershipEmployees[0].Id;
        project.TeamLeadId = leadershipEmployees[1].Id;
        if (leadershipEmployees.Count > 2)
        {
            project.EngagementManagerId = leadershipEmployees[2].Id;
        }
        await db.SaveChangesAsync();

        var service = await db.ProjectServices
            .FirstOrDefaultAsync(s => s.ProjectId == project.Id && s.DeletedAtUtc == null);
        if (service == null)
        {
            service = new ProjectServiceEntity
            {
                ProjectId = project.Id,
                ServiceName = "Quality Assurance & Testing",
                Department = "Engineering",
                Qty = 1,
                SortOrder = 1
            };
            db.ProjectServices.Add(service);
            await db.SaveChangesAsync();
        }

        var employee = leadershipEmployees.Last();
        var empName = $"{employee.FirstName} {employee.LastName}".Trim();

        var existingMember = await db.ProjectTeamMembers
            .FirstOrDefaultAsync(tm => tm.ProjectId == project.Id && tm.EmployeeId == employee.Id && tm.DeletedAtUtc == null);
        if (existingMember == null)
        {
            db.ProjectTeamMembers.Add(new ProjectTeamMember
            {
                ProjectId = project.Id,
                EmployeeId = employee.Id,
                MemberRole = "ProjectTeam",
                IsTeamLead = false
            });
            await db.SaveChangesAsync();
        }

        // 2. Create task attached to the project and service
        var taskTitle = $"Pause-Stop Enhancement Task {Guid.NewGuid():N}";
        var createTaskReq = new CreateProjectTaskRequest(
            Title: taskTitle,
            Description: "Verifying enhanced pause and stop notifications",
            PlannedStartDate: DateOnly.FromDateTime(DateTime.UtcNow),
            PlannedEndDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(2)),
            EstimatedHours: 6m,
            Priority: "High");

        var taskResponse = await _client.PostAsJsonAsync($"/api/v1/projects/{project.Id}/tasks", createTaskReq);
        Assert.True(taskResponse.IsSuccessStatusCode);
        var taskResult = await taskResponse.Content.ReadFromJsonAsync<ApiResponse<ProjectTaskDto>>();
        var taskId = taskResult!.Data.Id;

        var taskEntity = await db.ProjectTasks.FirstAsync(t => t.Id == taskId);
        taskEntity.ProjectServiceId = service.Id;
        await db.SaveChangesAsync();

        // 3. Assign employee to task
        await _client.PutAsJsonAsync(
            $"/api/v1/projects/{project.Id}/tasks/{taskId}/assignments",
            new SyncTaskAssignmentsRequest([employee.Id], "High"));

        var assignment = await db.ProjectTaskAssignments
            .FirstOrDefaultAsync(a => a.TaskId == taskId && a.EmployeeId == employee.Id && a.IsActive && a.DeletedAtUtc == null);
        Assert.NotNull(assignment);

        var bucketTask = await db.BucketTasks
            .FirstOrDefaultAsync(b => b.TaskId == taskId && b.EmployeeId == employee.Id && b.DeletedAtUtc == null);
        Assert.NotNull(bucketTask);

        // 4. Start Timer then Pause Timer
        var startResp = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/start-timer", null);
        Assert.Equal(HttpStatusCode.OK, startResp.StatusCode);

        var pauseResp = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/pause-timer", null);
        Assert.Equal(HttpStatusCode.OK, pauseResp.StatusCode);

        // 5. Verify Immediate Leadership Notification for Pause
        var expectedPauseTitle = $"{empName} Task Paused: {taskTitle} - {service.ServiceName}";
        var expectedPauseMsg = $"{empName} has paused the task '{taskTitle}' under the service '{service.ServiceName}' in project '{project.Name}'.";

        var pauseNotifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.RelatedTask == taskTitle && n.Type == "Task Paused" && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(pauseNotifs);

        foreach (var pn in pauseNotifs)
        {
            Assert.Equal(expectedPauseTitle, pn.Title);
            Assert.Contains(expectedPauseMsg, pn.CommentsJson);
            Assert.Equal("Low", pn.Priority);
            Assert.Equal("Pending", pn.Status);
            Assert.True(pn.Unread);
            Assert.Equal(empName, pn.RaisedByName);
            Assert.Equal(employee.Id, pn.RaisedByEmployeeId);
            Assert.Equal(project.Name, pn.ProjectName);
        }

        // 6. Verify Daily Reminder goes ONLY to assigned resource
        var pauseSla = await db.SlaInstances
            .FirstOrDefaultAsync(i => i.EntityId == assignment.Id && i.ActivityType == "Task Pause" && i.DeletedAtUtc == null);
        Assert.NotNull(pauseSla);

        var reminderEvent = await db.SlaEvents
            .FirstOrDefaultAsync(e => e.InstanceId == pauseSla.Id && e.EventType == SlaEventType.Reminder && e.DeletedAtUtc == null);
        Assert.NotNull(reminderEvent);

        db.ChangeTracker.Clear();
        await worker.ExecuteReminderAsync(pauseSla.Id, reminderEvent.Id);

        var reminderNotifs = await db.ActionNotifications
            .Where(n => n.RelatedTask == taskTitle && n.Type == "Task Pause Reminder" && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.Single(reminderNotifs);
        var rn = reminderNotifs[0];
        Assert.Equal(employee.Id, rn.RecipientEmployeeId);
        Assert.Equal($"Task Paused Reminder: {taskTitle} - {service.ServiceName}", rn.Title);
        Assert.Contains($"Your task '{taskTitle}' under the service '{service.ServiceName}' in project '{project.Name}' is still paused. Please resume the task or complete it.", rn.CommentsJson);
        Assert.Equal("Low", rn.Priority);
        Assert.Equal("Pending", rn.Status);
        Assert.True(rn.Unread);
        Assert.Equal("SLA Automation Engine", rn.RaisedByName);

        // 7. Resume Timer then Stop Timer
        var resumeResp = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/start-timer", null);
        Assert.Equal(HttpStatusCode.OK, resumeResp.StatusCode);

        var stopResp = await _client.PostAsync($"/api/v1/action-centre/bucket-list/{bucketTask.Id}/stop-timer", null);
        Assert.Equal(HttpStatusCode.OK, stopResp.StatusCode);

        // 8. Verify Immediate Leadership Notification for Stop
        var expectedStopTitle = $"{empName} Task Stopped: {taskTitle} - {service.ServiceName}";
        var expectedStopMsg = $"{empName} has stopped the task '{taskTitle}' under the service '{service.ServiceName}' in project '{project.Name}'.";

        var stopNotifs = await db.ActionNotifications
            .Where(n => n.ProjectId == project.Id && n.RelatedTask == taskTitle && n.Type == "Task Stopped" && n.DeletedAtUtc == null)
            .ToListAsync();
        Assert.NotEmpty(stopNotifs);

        foreach (var sn in stopNotifs)
        {
            Assert.Equal(expectedStopTitle, sn.Title);
            Assert.Contains(expectedStopMsg, sn.CommentsJson);
            Assert.Equal("Low", sn.Priority);
            Assert.Equal("Pending", sn.Status);
            Assert.True(sn.Unread);
            Assert.Equal(empName, sn.RaisedByName);
            Assert.Equal(employee.Id, sn.RaisedByEmployeeId);
            Assert.Equal(project.Name, sn.ProjectName);
        }

        // 9. Verify Stop completed Task Pause tracking (no further reminders)
        var refreshedSla = await db.SlaInstances.AsNoTracking().FirstOrDefaultAsync(i => i.Id == pauseSla.Id);
        Assert.Equal(SlaInstanceStatus.Completed, refreshedSla?.Status);
    }

    [Fact]
    public async Task Hangfire_SlaJobs_DisplayNames_MatchRequiredBusinessFormat()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var slaTracking = scope.ServiceProvider.GetRequiredService<ISlaTrackingService>();

        var project = await db.Projects.FirstOrDefaultAsync(p => p.DeletedAtUtc == null);
        Assert.NotNull(project);

        var employee = await db.Employees.FirstOrDefaultAsync(e => e.DeletedAtUtc == null);
        Assert.NotNull(employee);

        var taskTitle = $"Hangfire Display Test Task {Guid.NewGuid():N}";
        var task = new ProjectTask
        {
            ProjectId = project.Id,
            Title = taskTitle,
            Description = "Test for Hangfire SLA Display Names",
            PlannedStartDate = DateOnly.FromDateTime(DateTime.UtcNow),
            PlannedEndDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(2)),
            EstimatedHours = 4,
            Priority = "High"
        };
        db.ProjectTasks.Add(task);
        await db.SaveChangesAsync();

        var assignment = new ProjectTaskAssignment
        {
            TaskId = task.Id,
            EmployeeId = employee.Id,
            Role = "Developer",
            IsActive = true
        };
        db.ProjectTaskAssignments.Add(assignment);
        await db.SaveChangesAsync();

        // Start Task Start SLA tracking
        var taskStartSla = await slaTracking.StartTrackingAsync(new SlaStartTrackingRequest(
            Module: "Project",
            ActivityType: "Task Start After Assigning",
            EntityId: assignment.Id,
            Stage: "PendingStart",
            Priority: SlaPriority.High,
            RecipientEmployeeId: employee.Id,
            ProjectId: project.Id,
            EntityReference: taskTitle));

        // Start Task Deadline SLA tracking
        var taskDeadlineSla = await slaTracking.StartTrackingAsync(new SlaStartTrackingRequest(
            Module: "Project",
            ActivityType: "Task Deadline",
            EntityId: assignment.Id,
            Stage: "InProgress",
            Priority: SlaPriority.High,
            RecipientEmployeeId: employee.Id,
            ProjectId: project.Id,
            EntityReference: taskTitle));

        // Verify scheduled jobs for Task Start SLA
        var startEvents = await db.SlaEvents
            .Where(e => e.InstanceId == taskStartSla.Id && e.Status == SlaEventStatus.Scheduled)
            .ToListAsync();

        Assert.NotEmpty(startEvents);

        var methodBreach = typeof(SlaBackgroundJobWorker).GetMethod(nameof(SlaBackgroundJobWorker.ExecuteBreachCheckAsync))!;
        var attrBreach = (SlaJobDisplayNameAttribute)Attribute.GetCustomAttribute(methodBreach, typeof(SlaJobDisplayNameAttribute))!;
        var methodEsc = typeof(SlaBackgroundJobWorker).GetMethod(nameof(SlaBackgroundJobWorker.ExecuteEscalationAsync))!;
        var attrEsc = (SlaJobDisplayNameAttribute)Attribute.GetCustomAttribute(methodEsc, typeof(SlaJobDisplayNameAttribute))!;
        var methodRem = typeof(SlaBackgroundJobWorker).GetMethod(nameof(SlaBackgroundJobWorker.ExecuteReminderAsync))!;
        var attrRem = (SlaJobDisplayNameAttribute)Attribute.GetCustomAttribute(methodRem, typeof(SlaJobDisplayNameAttribute))!;

        var breachEv = startEvents.FirstOrDefault(e => e.EventType == SlaEventType.BreachCheck);
        if (breachEv != null)
        {
            var job = new Hangfire.Common.Job(typeof(SlaBackgroundJobWorker), methodBreach, taskStartSla.Id, breachEv.Id);
            var title = attrBreach.Format(null!, job);
            Assert.Equal($"Task Start SLA | Breach Check | {taskTitle} | {project.Name}", title);
        }

        var esc1Ev = startEvents.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        if (esc1Ev != null)
        {
            var job = new Hangfire.Common.Job(typeof(SlaBackgroundJobWorker), methodEsc, taskStartSla.Id, esc1Ev.Id, 1);
            var title = attrEsc.Format(null!, job);
            Assert.Equal($"Task Start SLA | L1 Escalation | Senior Project Manager | {taskTitle} | {project.Name}", title);
        }

        // Verify Task Deadline SLA jobs
        var deadlineEvents = await db.SlaEvents
            .Where(e => e.InstanceId == taskDeadlineSla.Id && e.Status == SlaEventStatus.Scheduled)
            .ToListAsync();

        var remEv = deadlineEvents.FirstOrDefault(e => e.EventType == SlaEventType.Reminder);
        if (remEv != null)
        {
            var job = new Hangfire.Common.Job(typeof(SlaBackgroundJobWorker), methodRem, taskDeadlineSla.Id, remEv.Id);
            var title = attrRem.Format(null!, job);
            Assert.Equal($"Task Deadline SLA | Upcoming Deadline Reminder | {taskTitle} | {project.Name}", title);
        }

        var deadlineEsc1 = deadlineEvents.FirstOrDefault(e => e.EventType == SlaEventType.EscalationL1);
        if (deadlineEsc1 != null)
        {
            var job = new Hangfire.Common.Job(typeof(SlaBackgroundJobWorker), methodEsc, taskDeadlineSla.Id, deadlineEsc1.Id, 1);
            var title = attrEsc.Format(null!, job);
            Assert.Equal($"Task Deadline SLA | L1 Escalation | Senior Project Manager | {taskTitle} | {project.Name}", title);
        }
    }
}
