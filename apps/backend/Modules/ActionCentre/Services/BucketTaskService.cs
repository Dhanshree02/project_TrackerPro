using Microsoft.EntityFrameworkCore;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.ActionCentre.Models;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Exceptions;

namespace PMS.API.Modules.ActionCentre.Services;

public class BucketTaskService : IBucketTaskService
{
    private readonly AppDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public BucketTaskService(AppDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<PagedResult<BucketTaskDto>> GetBucketTasksAsync(BucketTaskQueryParameters query, CancellationToken ct = default)
    {
        // 1. Sync any new assignments from projects into action.tbl_bucket_tasks automatically
        await SyncBucketTasksFromAssignmentsAsync(null, null, ct);

        // 2. Build query
        var q = _db.BucketTasks
            .AsNoTracking()
            .Where(b => b.DeletedAtUtc == null);

        // Filter by EmployeeId
        if (query.EmployeeId.HasValue)
        {
            q = q.Where(b => b.EmployeeId == query.EmployeeId.Value);
        }
        else
        {
            var currentEmpId = await ResolveCurrentEmployeeIdAsync(ct);
            var isSuperAdmin = _currentUser.Role is "Admin" or "SuperAdmin" || _currentUser.Email == "admin@talakunchi.com";

            if (currentEmpId.HasValue)
            {
                // When switched to any assigned resource / employee, filter down to their assigned tasks
                // If the user is SuperAdmin and has no directly assigned tasks, allow viewing all tasks
                if (isSuperAdmin)
                {
                    var hasTasks = await _db.BucketTasks
                        .AsNoTracking()
                        .AnyAsync(b => b.EmployeeId == currentEmpId.Value && b.DeletedAtUtc == null, ct);
                    if (hasTasks)
                    {
                        q = q.Where(b => b.EmployeeId == currentEmpId.Value);
                    }
                }
                else
                {
                    q = q.Where(b => b.EmployeeId == currentEmpId.Value);
                }
            }
            else if (!isSuperAdmin && _currentUser.UserId.HasValue)
            {
                // If non-admin user cannot be resolved to an employee in DB, match directly on EmployeeId
                q = q.Where(b => b.EmployeeId == _currentUser.UserId.Value);
            }
        }

        // Search text matching Task Title or Project Name
        if (!string.IsNullOrWhiteSpace(query.Search))
        {
            var search = query.Search.Trim().ToLower();
            q = q.Where(b => b.TaskTitle.ToLower().Contains(search) || b.ProjectName.ToLower().Contains(search));
        }

        // Priority filter
        if (!string.IsNullOrWhiteSpace(query.Priority) && !query.Priority.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            var priority = query.Priority.Trim();
            q = q.Where(b => EF.Functions.ILike(b.Priority, priority));
        }

        // Status filter
        if (!string.IsNullOrWhiteSpace(query.Status) && !query.Status.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            var s = query.Status.Trim().ToLower();
            if (s is "todo" or "to do" or "not started")
            {
                q = q.Where(b => b.Status == "Not Started" || b.Status == "Ready to Start" || b.Status == "To Do");
            }
            else if (s is "in_progress" or "inprogress" or "ongoing")
            {
                q = q.Where(b => b.Status == "Ongoing" || b.Status == "In Progress" || b.Status == "Paused" || b.Status == "Stopped");
            }
            else if (s is "on_hold" or "on hold" or "onhold")
            {
                q = q.Where(b => b.Status == "On Hold");
            }
            else if (s is "done" or "completed")
            {
                q = q.Where(b => b.Status == "Completed");
            }
            else if (s is "cancelled" or "canceled")
            {
                q = q.Where(b => b.Status == "Cancelled");
            }
            else if (s is "review" or "under_review" or "under review")
            {
                q = q.Where(b => b.Status == "Under Review");
            }
            else
            {
                q = q.Where(b => EF.Functions.ILike(b.Status, query.Status.Trim()));
            }
        }

        var total = await q.CountAsync(ct);

        var page = query.Page > 0 ? query.Page : 1;
        var pageSize = query.PageSize > 0 ? query.PageSize : 50;

        var items = await q
            .OrderBy(b => b.DueDate)
            .ThenByDescending(b => b.CreatedAtUtc)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(ct);

        var dtos = items.Select(MapToDto).ToList();

        return new PagedResult<BucketTaskDto>(dtos, page, pageSize, total);
    }

    public async Task<BucketTaskDto?> GetBucketTaskByIdAsync(Guid id, CancellationToken ct = default)
    {
        var item = await _db.BucketTasks
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == id && b.DeletedAtUtc == null, ct);

        return item == null ? null : MapToDto(item);
    }

    public async Task<BucketTaskDto> StartBucketTaskTimerAsync(Guid id, CancellationToken ct = default)
    {
        var bucketTask = await _db.BucketTasks
            .FirstOrDefaultAsync(b => (b.Id == id || b.AssignmentId == id) && b.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Bucket task with ID '{id}' was not found.");

        if (bucketTask.Status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            throw new BadRequestException("A completed task cannot be started or restarted.");
        }

        if (bucketTask.Status.Equals("On Hold", StringComparison.OrdinalIgnoreCase) || bucketTask.Status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
        {
            throw new BadRequestException($"Cannot start or resume a task while it is {bucketTask.Status}. The task stage must be Ongoing.");
        }

        var nowUtc = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(nowUtc);

        // Single active task timer rule: if resource has other running tasks in their bucket list, pause them
        var otherRunning = await _db.BucketTasks
            .Where(b => b.EmployeeId == bucketTask.EmployeeId && b.Id != bucketTask.Id && b.TimerRunning && b.DeletedAtUtc == null)
            .ToListAsync(ct);

        foreach (var other in otherRunning)
        {
            if (other.TimerStartedAtUtc.HasValue)
            {
                var el = (long)(nowUtc - other.TimerStartedAtUtc.Value).TotalSeconds;
                other.TimerAccumulatedSeconds += Math.Max(0, el);
                other.UtilizedHours = Math.Round((decimal)other.TimerAccumulatedSeconds / 3600m, 2);
            }
            other.TimerRunning = false;
            other.TimerStartedAtUtc = null;
            other.Status = "Paused";
            other.UpdatedAtUtc = nowUtc;

            if (other.AssignmentId.HasValue)
            {
                var otherAssign = await _db.ProjectTaskAssignments
                    .FirstOrDefaultAsync(a => a.Id == other.AssignmentId.Value, ct);
                if (otherAssign != null)
                {
                    otherAssign.TimerStartedAtUtc = null;
                    otherAssign.TimerAccumulatedSeconds = other.TimerAccumulatedSeconds;
                    otherAssign.UtilizedHours = other.UtilizedHours;
                    otherAssign.UpdatedAtUtc = nowUtc;
                }
            }
        }

        // 1. Update timer and status on Bucket Task
        bucketTask.TimerRunning = true;
        bucketTask.TimerStartedAtUtc = nowUtc;
        bucketTask.ActualStartDate ??= today;

        if (bucketTask.Status is "Not Started" or "Ready to Start" or "To Do" or "Paused" or "Stopped")
        {
            bucketTask.Status = "Ongoing";
        }

        bucketTask.UpdatedAtUtc = nowUtc;

        // 2. Synchronize onto ProjectTask
        var task = await _db.ProjectTasks.FirstOrDefaultAsync(t => t.Id == bucketTask.TaskId, ct);
        if (task != null)
        {
            task.ActualStartDate ??= today;
            if (task.Stage is "Ready to Start" or "To Do" or "Not Started" or "Stopped")
            {
                task.Stage = "Ongoing";
            }
            task.UpdatedAtUtc = nowUtc;
        }

        // 3. Synchronize onto ProjectTaskAssignment
        if (bucketTask.AssignmentId.HasValue)
        {
            var assignment = await _db.ProjectTaskAssignments
                .FirstOrDefaultAsync(a => a.Id == bucketTask.AssignmentId.Value, ct);
            if (assignment != null)
            {
                assignment.TimerStartedAtUtc = nowUtc;
                assignment.UpdatedAtUtc = nowUtc;
            }
        }

        await _db.SaveChangesAsync(ct);

        return MapToDto(bucketTask);
    }

    public async Task<BucketTaskDto> PauseBucketTaskTimerAsync(Guid id, CancellationToken ct = default)
    {
        var bucketTask = await _db.BucketTasks
            .FirstOrDefaultAsync(b => (b.Id == id || b.AssignmentId == id) && b.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Bucket task with ID '{id}' was not found.");

        if (bucketTask.Status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            throw new BadRequestException("A completed task cannot be paused.");
        }

        if (bucketTask.Status.Equals("On Hold", StringComparison.OrdinalIgnoreCase) || bucketTask.Status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
        {
            throw new BadRequestException($"Cannot pause a task that is already {bucketTask.Status}.");
        }

        var nowUtc = DateTime.UtcNow;

        if (bucketTask.TimerRunning && bucketTask.TimerStartedAtUtc.HasValue)
        {
            var elapsed = (long)(nowUtc - bucketTask.TimerStartedAtUtc.Value).TotalSeconds;
            bucketTask.TimerAccumulatedSeconds += Math.Max(0, elapsed);
            bucketTask.TimerRunning = false;
            bucketTask.TimerStartedAtUtc = null;
            bucketTask.UtilizedHours = Math.Round((decimal)bucketTask.TimerAccumulatedSeconds / 3600m, 2);
        }

        bucketTask.Status = "Paused";
        bucketTask.UpdatedAtUtc = nowUtc;

        // Sync to Assignment
        if (bucketTask.AssignmentId.HasValue)
        {
            var assignment = await _db.ProjectTaskAssignments
                .FirstOrDefaultAsync(a => a.Id == bucketTask.AssignmentId.Value, ct);
            if (assignment != null)
            {
                assignment.TimerStartedAtUtc = null;
                assignment.TimerAccumulatedSeconds = bucketTask.TimerAccumulatedSeconds;
                assignment.UtilizedHours = bucketTask.UtilizedHours;
                assignment.UpdatedAtUtc = nowUtc;

                // Update task total utilized hours
                var task = await _db.ProjectTasks.FirstOrDefaultAsync(t => t.Id == bucketTask.TaskId, ct);
                if (task != null)
                {
                    var otherHours = await _db.ProjectTaskAssignments
                        .Where(a => a.TaskId == bucketTask.TaskId && a.Id != assignment.Id && a.DeletedAtUtc == null)
                        .SumAsync(a => a.UtilizedHours, ct);
                    task.UtilizedHours = otherHours + assignment.UtilizedHours;
                    task.UpdatedAtUtc = nowUtc;
                }
            }
        }

        await _db.SaveChangesAsync(ct);

        return MapToDto(bucketTask);
    }

    public async Task<BucketTaskDto> StopBucketTaskTimerAsync(Guid id, CancellationToken ct = default)
    {
        var bucketTask = await _db.BucketTasks
            .FirstOrDefaultAsync(b => (b.Id == id || b.AssignmentId == id) && b.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Bucket task with ID '{id}' was not found.");

        if (bucketTask.Status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            throw new BadRequestException("A completed task cannot be stopped.");
        }

        if (bucketTask.Status.Equals("Cancelled", StringComparison.OrdinalIgnoreCase))
        {
            throw new BadRequestException("A cancelled task cannot be stopped.");
        }

        var nowUtc = DateTime.UtcNow;

        if (bucketTask.TimerRunning && bucketTask.TimerStartedAtUtc.HasValue)
        {
            var elapsed = (long)(nowUtc - bucketTask.TimerStartedAtUtc.Value).TotalSeconds;
            bucketTask.TimerAccumulatedSeconds += Math.Max(0, elapsed);
            bucketTask.TimerRunning = false;
            bucketTask.TimerStartedAtUtc = null;
            bucketTask.UtilizedHours = Math.Round((decimal)bucketTask.TimerAccumulatedSeconds / 3600m, 2);
        }

        bucketTask.Status = "Stopped";
        bucketTask.UpdatedAtUtc = nowUtc;

        // Sync to Assignment
        if (bucketTask.AssignmentId.HasValue)
        {
            var assignment = await _db.ProjectTaskAssignments
                .FirstOrDefaultAsync(a => a.Id == bucketTask.AssignmentId.Value, ct);
            if (assignment != null)
            {
                assignment.TimerStartedAtUtc = null;
                assignment.TimerAccumulatedSeconds = bucketTask.TimerAccumulatedSeconds;
                assignment.UtilizedHours = bucketTask.UtilizedHours;
                assignment.UpdatedAtUtc = nowUtc;

                var task = await _db.ProjectTasks.FirstOrDefaultAsync(t => t.Id == bucketTask.TaskId, ct);
                if (task != null)
                {
                    var otherHours = await _db.ProjectTaskAssignments
                        .Where(a => a.TaskId == bucketTask.TaskId && a.Id != assignment.Id && a.DeletedAtUtc == null)
                        .SumAsync(a => a.UtilizedHours, ct);
                    task.UtilizedHours = otherHours + assignment.UtilizedHours;
                    task.UpdatedAtUtc = nowUtc;
                }
            }
        }

        await _db.SaveChangesAsync(ct);

        return MapToDto(bucketTask);
    }

    public async Task<BucketTaskDto> CompleteBucketTaskAsync(Guid id, CancellationToken ct = default)
    {
        var bucketTask = await _db.BucketTasks
            .FirstOrDefaultAsync(b => (b.Id == id || b.AssignmentId == id) && b.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Bucket task with ID '{id}' was not found.");

        var nowUtc = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(nowUtc);

        if (bucketTask.TimerRunning && bucketTask.TimerStartedAtUtc.HasValue)
        {
            var elapsed = (long)(nowUtc - bucketTask.TimerStartedAtUtc.Value).TotalSeconds;
            bucketTask.TimerAccumulatedSeconds += Math.Max(0, elapsed);
            bucketTask.TimerRunning = false;
            bucketTask.TimerStartedAtUtc = null;
            bucketTask.UtilizedHours = Math.Round((decimal)bucketTask.TimerAccumulatedSeconds / 3600m, 2);
        }

        bucketTask.Status = "Completed";
        bucketTask.ActualEndDate ??= today;
        bucketTask.UpdatedAtUtc = nowUtc;

        // Sync to Task
        var task = await _db.ProjectTasks.FirstOrDefaultAsync(t => t.Id == bucketTask.TaskId, ct);
        if (task != null)
        {
            task.Stage = "Completed";
            task.ActualEndDate ??= today;
            task.Progress = 100;
            task.UpdatedAtUtc = nowUtc;
        }

        // Sync to Assignment
        if (bucketTask.AssignmentId.HasValue)
        {
            var assignment = await _db.ProjectTaskAssignments
                .FirstOrDefaultAsync(a => a.Id == bucketTask.AssignmentId.Value, ct);
            if (assignment != null)
            {
                assignment.TimerStartedAtUtc = null;
                assignment.TimerAccumulatedSeconds = bucketTask.TimerAccumulatedSeconds;
                assignment.UtilizedHours = bucketTask.UtilizedHours;
                assignment.UpdatedAtUtc = nowUtc;
            }
        }

        await _db.SaveChangesAsync(ct);

        return MapToDto(bucketTask);
    }

    public async Task<BucketTaskDto> UpdateBucketTaskStatusAsync(Guid id, string status, CancellationToken ct = default)
    {
        var bucketTask = await _db.BucketTasks
            .FirstOrDefaultAsync(b => (b.Id == id || b.AssignmentId == id) && b.DeletedAtUtc == null, ct)
            ?? throw new NotFoundException($"Bucket task with ID '{id}' was not found.");

        if (bucketTask.Status.Equals("Completed", StringComparison.OrdinalIgnoreCase) && !status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            throw new BadRequestException("A completed task cannot be changed to another stage.");
        }

        var nowUtc = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(nowUtc);
        var isRunningStage = status.Equals("Ongoing", StringComparison.OrdinalIgnoreCase) ||
                             status.Equals("In Progress", StringComparison.OrdinalIgnoreCase);

        bucketTask.Status = status.Trim();
        bucketTask.UpdatedAtUtc = nowUtc;

        if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
        {
            bucketTask.ActualEndDate ??= today;
            if (bucketTask.TimerRunning && bucketTask.TimerStartedAtUtc.HasValue)
            {
                var elapsed = (long)(nowUtc - bucketTask.TimerStartedAtUtc.Value).TotalSeconds;
                bucketTask.TimerAccumulatedSeconds += Math.Max(0, elapsed);
                bucketTask.TimerRunning = false;
                bucketTask.TimerStartedAtUtc = null;
                bucketTask.UtilizedHours = Math.Round((decimal)bucketTask.TimerAccumulatedSeconds / 3600m, 2);
            }
        }
        else if (isRunningStage)
        {
            bucketTask.ActualStartDate ??= today;
        }
        else
        {
            // Moving to any non-running stage (On Hold, Paused, Stopped, etc.) pauses active timer
            if (bucketTask.TimerRunning && bucketTask.TimerStartedAtUtc.HasValue)
            {
                var elapsed = (long)(nowUtc - bucketTask.TimerStartedAtUtc.Value).TotalSeconds;
                bucketTask.TimerAccumulatedSeconds += Math.Max(0, elapsed);
                bucketTask.TimerRunning = false;
                bucketTask.TimerStartedAtUtc = null;
                bucketTask.UtilizedHours = Math.Round((decimal)bucketTask.TimerAccumulatedSeconds / 3600m, 2);
            }
        }

        // Synchronize onto ProjectTask
        var task = await _db.ProjectTasks.FirstOrDefaultAsync(t => t.Id == bucketTask.TaskId, ct);
        if (task != null)
        {
            task.Stage = bucketTask.Status;
            if (status.Equals("Completed", StringComparison.OrdinalIgnoreCase))
            {
                task.ActualEndDate ??= today;
                task.Progress = 100;
            }
            else if (isRunningStage)
            {
                task.ActualStartDate ??= today;
            }
            task.UpdatedAtUtc = nowUtc;
        }

        // Also synchronize timer pause to ProjectTaskAssignment if moved to non-running stage
        if (!isRunningStage && bucketTask.AssignmentId.HasValue)
        {
            var assignment = await _db.ProjectTaskAssignments
                .FirstOrDefaultAsync(a => a.Id == bucketTask.AssignmentId.Value, ct);
            if (assignment != null)
            {
                assignment.TimerStartedAtUtc = null;
                assignment.TimerAccumulatedSeconds = bucketTask.TimerAccumulatedSeconds;
                assignment.UtilizedHours = bucketTask.UtilizedHours;
                assignment.UpdatedAtUtc = nowUtc;
            }
        }

        await _db.SaveChangesAsync(ct);

        return MapToDto(bucketTask);
    }

    public async Task SyncBucketTasksFromAssignmentsAsync(Guid? projectId = null, Guid? taskId = null, CancellationToken ct = default)
    {
        // Query active task assignments
        var query = _db.ProjectTaskAssignments
            .Include(a => a.Task)
                .ThenInclude(t => t.ProjectService)
            .Include(a => a.Task)
                .ThenInclude(t => t.Project)
            .Where(a => a.DeletedAtUtc == null && a.IsActive && a.Task != null && a.Task.DeletedAtUtc == null);

        if (projectId.HasValue)
        {
            query = query.Where(a => a.Task.ProjectId == projectId.Value);
        }

        if (taskId.HasValue)
        {
            query = query.Where(a => a.TaskId == taskId.Value);
        }

        var assignments = await query.ToListAsync(ct);
        if (assignments.Count == 0) return;

        // Existing bucket tasks
        var taskIds = assignments.Select(a => a.TaskId).Distinct().ToList();
        var existingBucketTasks = await _db.BucketTasks
            .Where(b => taskIds.Contains(b.TaskId) && b.DeletedAtUtc == null)
            .ToListAsync(ct);

        var existingMap = existingBucketTasks.ToDictionary(b => (b.TaskId, b.EmployeeId));

        // Preload assigner employee and user lookup
        var creatorIds = assignments
            .Select(a => a.CreatedBy)
            .Where(id => id.HasValue)
            .Select(id => id!.Value)
            .Distinct()
            .ToList();

        var assignerEmployees = await _db.Employees
            .Where(e => creatorIds.Contains(e.Id) || creatorIds.Contains(e.UserId ?? Guid.Empty))
            .ToDictionaryAsync(e => e.Id, ct);

        var assignerUsers = await _db.Users
            .Where(u => creatorIds.Contains(u.Id))
            .ToDictionaryAsync(u => u.Id, ct);

        var pmIds = assignments
            .Select(a => a.Task.Project?.ProjectManagerId)
            .Where(id => id.HasValue)
            .Select(id => id!.Value)
            .Distinct()
            .ToList();

        var pmEmployees = await _db.Employees
            .Where(e => pmIds.Contains(e.Id))
            .ToDictionaryAsync(e => e.Id, ct);

        var nowUtc = DateTime.UtcNow;
        var modified = false;

        foreach (var a in assignments)
        {
            var task = a.Task;
            var project = task.Project;
            var service = task.ProjectService;

            // Resolve DueDate: parent service EndDate takes precedence, fallback to task PlannedEndDate, then project EndDate
            var dueDate = service?.EndDate ?? task.PlannedEndDate ?? project?.EndDate;

            // Resolve AssignedBy Name
            string? assignerName = null;
            Guid? assignerId = a.CreatedBy;

            if (a.CreatedBy.HasValue)
            {
                if (assignerEmployees.TryGetValue(a.CreatedBy.Value, out var emp))
                {
                    assignerName = $"{emp.FirstName} {emp.LastName}".Trim();
                }
                else if (assignerUsers.TryGetValue(a.CreatedBy.Value, out var usr))
                {
                    assignerName = string.IsNullOrWhiteSpace(usr.Name) ? usr.Email : usr.Name;
                }
            }

            if (string.IsNullOrWhiteSpace(assignerName) && project?.ProjectManagerId.HasValue == true)
            {
                if (pmEmployees.TryGetValue(project.ProjectManagerId.Value, out var pm))
                {
                    assignerName = $"{pm.FirstName} {pm.LastName}".Trim();
                    assignerId ??= pm.Id;
                }
            }

            if (string.IsNullOrWhiteSpace(assignerName))
            {
                assignerName = project?.EngagementManager ?? "Project Manager";
            }

            if (existingMap.TryGetValue((a.TaskId, a.EmployeeId), out var bucketTask))
            {
                // Update dynamic fields if changed
                var changed = false;
                if (bucketTask.TaskTitle != task.Title) { bucketTask.TaskTitle = task.Title; changed = true; }
                if (project != null && bucketTask.ProjectName != project.Name) { bucketTask.ProjectName = project.Name; changed = true; }
                if (bucketTask.Priority != task.Priority) { bucketTask.Priority = task.Priority; changed = true; }
                if (bucketTask.DueDate != dueDate) { bucketTask.DueDate = dueDate; changed = true; }

                // Synchronize Status:
                // Overriding stages (Completed, On Hold, Cancelled) always cascade to bucket task
                if (task.Stage is "Completed" or "On Hold" or "Cancelled")
                {
                    if (bucketTask.Status != task.Stage)
                    {
                        bucketTask.Status = task.Stage;
                        changed = true;
                    }
                }
                else if (task.Stage is "Ongoing" or "In Progress")
                {
                    // If previously On Hold, unpause to Paused (if timer accumulated) or Not Started
                    if (bucketTask.Status is "On Hold")
                    {
                        bucketTask.Status = bucketTask.TimerAccumulatedSeconds > 0 ? "Paused" : "Not Started";
                        changed = true;
                    }
                    else if (bucketTask.Status == "Ongoing" && !bucketTask.TimerRunning && bucketTask.TimerAccumulatedSeconds > 0)
                    {
                        // Self-heal: task is not actively running timer, mark as Paused
                        bucketTask.Status = "Paused";
                        changed = true;
                    }
                }
                else if (task.Stage is "Not Started")
                {
                    if (bucketTask.Status != "Not Started" && !bucketTask.TimerRunning && bucketTask.TimerAccumulatedSeconds == 0 && !bucketTask.ActualStartDate.HasValue)
                    {
                        bucketTask.Status = "Not Started";
                        changed = true;
                    }
                }

                if (bucketTask.TimerRunning || bucketTask.TimerAccumulatedSeconds > 0)
                {
                    if (bucketTask.ActualStartDate == null && task.ActualStartDate != null)
                    {
                        bucketTask.ActualStartDate = task.ActualStartDate;
                        changed = true;
                    }
                }
                if (bucketTask.ActualEndDate != task.ActualEndDate && task.Stage.Equals("Completed", StringComparison.OrdinalIgnoreCase))
                {
                    bucketTask.ActualEndDate = task.ActualEndDate;
                    changed = true;
                }
                if (bucketTask.AssignmentId != a.Id) { bucketTask.AssignmentId = a.Id; changed = true; }
                if (string.IsNullOrWhiteSpace(bucketTask.AssignedByName) && !string.IsNullOrWhiteSpace(assignerName)) { bucketTask.AssignedByName = assignerName; changed = true; }

                var isRunningStage = task.Stage.Equals("Ongoing", StringComparison.OrdinalIgnoreCase) ||
                                     task.Stage.Equals("In Progress", StringComparison.OrdinalIgnoreCase);
                if (!isRunningStage && bucketTask.TimerRunning)
                {
                    if (bucketTask.TimerStartedAtUtc.HasValue)
                    {
                        var el = (long)(nowUtc - bucketTask.TimerStartedAtUtc.Value).TotalSeconds;
                        bucketTask.TimerAccumulatedSeconds += Math.Max(0, el);
                        bucketTask.UtilizedHours = Math.Round((decimal)bucketTask.TimerAccumulatedSeconds / 3600m, 2);
                    }
                    bucketTask.TimerRunning = false;
                    bucketTask.TimerStartedAtUtc = null;
                    changed = true;
                }

                if (changed)
                {
                    bucketTask.UpdatedAtUtc = nowUtc;
                    modified = true;
                }
            }
            else
            {
                var isRunningStage = task.Stage.Equals("Ongoing", StringComparison.OrdinalIgnoreCase) ||
                                     task.Stage.Equals("In Progress", StringComparison.OrdinalIgnoreCase);

                // Create new Bucket Task
                var newBucketTask = new BucketTask
                {
                    Id = Guid.NewGuid(),
                    TaskId = a.TaskId,
                    ProjectId = task.ProjectId,
                    ProjectServiceId = task.ProjectServiceId,
                    AssignmentId = a.Id,
                    EmployeeId = a.EmployeeId,
                    AssignedById = assignerId,
                    AssignedByName = assignerName,
                    TaskTitle = task.Title,
                    ProjectName = project?.Name ?? "Project",
                    Priority = string.IsNullOrWhiteSpace(task.Priority) ? "Medium" : task.Priority,
                    DueDate = dueDate,
                    Status = isRunningStage ? (a.TimerStartedAtUtc.HasValue ? "Ongoing" : (a.TimerAccumulatedSeconds > 0 ? "Paused" : "Not Started")) : (string.IsNullOrWhiteSpace(task.Stage) ? "Not Started" : task.Stage),
                    ActualStartDate = a.TimerStartedAtUtc.HasValue || a.TimerAccumulatedSeconds > 0 ? task.ActualStartDate : null,
                    ActualEndDate = task.Stage.Equals("Completed", StringComparison.OrdinalIgnoreCase) ? task.ActualEndDate : null,
                    TimerRunning = isRunningStage && a.TimerStartedAtUtc.HasValue,
                    TimerStartedAtUtc = isRunningStage ? a.TimerStartedAtUtc : null,
                    TimerAccumulatedSeconds = a.TimerAccumulatedSeconds,
                    UtilizedHours = a.UtilizedHours,
                    CreatedAtUtc = nowUtc,
                };

                _db.BucketTasks.Add(newBucketTask);
                existingMap[(a.TaskId, a.EmployeeId)] = newBucketTask;
                modified = true;
            }
        }

        if (modified)
        {
            await _db.SaveChangesAsync(ct);
        }
    }

    private static BucketTaskDto MapToDto(BucketTask b)
    {
        var elapsed = b.TimerAccumulatedSeconds;
        if (b.TimerRunning && b.TimerStartedAtUtc.HasValue)
        {
            elapsed += Math.Max(0, (long)(DateTime.UtcNow - b.TimerStartedAtUtc.Value).TotalSeconds);
        }

        return new BucketTaskDto(
            b.Id,
            b.TaskId,
            b.ProjectId,
            b.ProjectServiceId,
            b.AssignmentId,
            b.EmployeeId,
            b.AssignedById,
            b.AssignedByName,
            b.TaskTitle,
            b.ProjectName,
            b.Priority,
            b.DueDate,
            b.Status,
            b.ActualStartDate,
            b.ActualEndDate,
            b.TimerRunning,
            b.TimerStartedAtUtc,
            b.TimerAccumulatedSeconds,
            elapsed,
            b.UtilizedHours,
            b.CreatedAtUtc
        );
    }

    private async Task<Guid?> ResolveCurrentEmployeeIdAsync(CancellationToken ct)
    {
        var userId = _currentUser.UserId;
        var email = _currentUser.Email?.Trim().ToLowerInvariant();

        // 1. Direct match: Did X-User-Id pass an Employee ID directly (which is what persona switcher passes)?
        if (userId.HasValue)
        {
            var empExists = await _db.Employees
                .AsNoTracking()
                .AnyAsync(e => e.Id == userId.Value && e.DeletedAtUtc == null, ct);
            if (empExists)
            {
                return userId.Value;
            }
        }

        // 2. Match by UserId foreign key
        if (userId.HasValue)
        {
            var empByUserId = await _db.Employees
                .AsNoTracking()
                .Where(e => e.UserId == userId.Value && e.DeletedAtUtc == null)
                .Select(e => (Guid?)e.Id)
                .FirstOrDefaultAsync(ct);
            if (empByUserId.HasValue)
            {
                return empByUserId.Value;
            }
        }

        // 3. Match by WorkEmail (case-insensitive)
        if (!string.IsNullOrWhiteSpace(email))
        {
            var empByEmail = await _db.Employees
                .AsNoTracking()
                .Where(e => e.DeletedAtUtc == null && e.WorkEmail != null && e.WorkEmail.ToLower() == email)
                .Select(e => (Guid?)e.Id)
                .FirstOrDefaultAsync(ct);
            if (empByEmail.HasValue)
            {
                return empByEmail.Value;
            }
        }

        return null;
    }
}
