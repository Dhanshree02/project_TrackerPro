using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Infrastructure.Persistence;
using PMS.API.Modules.ActionCentre.DTOs;
using PMS.API.Modules.Projects.Models;
using PMS.API.Modules.Resources.Models;
using PMS.API.Shared.Exceptions;
using PMS.API.Shared.Common.Wrappers;

namespace PMS.API.Modules.ActionCentre.Services;

public class BucketTaskService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IConfiguration configuration) : IBucketTaskService
{
    private readonly decimal _maxDailyWorkingHours = decimal.TryParse(
        configuration["TimerSettings:MaxDailyWorkingHours"], out var maxHrs) ? maxHrs : 8.5m;

    public async Task<PagedResult<BucketTaskDto>> GetBucketTasksAsync(
        BucketTaskFilterParams filters,
        CancellationToken ct = default)
    {
        var role = currentUser.Role ?? string.Empty;
        var isManagerOrAdmin = role.Contains("Admin", StringComparison.OrdinalIgnoreCase) ||
                               role.Contains("Manager", StringComparison.OrdinalIgnoreCase) ||
                               role.Contains("Leader", StringComparison.OrdinalIgnoreCase) ||
                               role.Contains("Lead", StringComparison.OrdinalIgnoreCase) ||
                               role.Contains("PMO", StringComparison.OrdinalIgnoreCase) ||
                               role.Contains("HOD", StringComparison.OrdinalIgnoreCase) ||
                               role.Equals("CEO", StringComparison.OrdinalIgnoreCase) ||
                               role.Equals("COO", StringComparison.OrdinalIgnoreCase) ||
                               role.Equals("CTO", StringComparison.OrdinalIgnoreCase);

        var showAll = string.Equals(filters.EmployeeId, "all", StringComparison.OrdinalIgnoreCase);
        var targetEmployee = showAll ? null : await ResolveTargetEmployeeAsync(filters.EmployeeId, ct);

        // Fetch assignments
        var query = db.ProjectTaskAssignments
            .AsNoTracking()
            .Include(a => a.Task)
                .ThenInclude(t => t!.Project)
            .Include(a => a.Employee)
            .Where(a => a.IsActive);

        if (targetEmployee != null)
        {
            query = query.Where(a => a.EmployeeId == targetEmployee.Id);
        }
        else if (!showAll)
        {
            return new PagedResult<BucketTaskDto>([], 0, filters.Page, filters.PerPage);
        }

        if (filters.ProjectId.HasValue)
        {
            query = query.Where(a => a.Task != null && a.Task.ProjectId == filters.ProjectId.Value);
        }

        if (!string.IsNullOrWhiteSpace(filters.Priority) && !filters.Priority.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            query = query.Where(a => a.Task != null && a.Task.Priority.ToLower() == filters.Priority.ToLower());
        }

        if (!string.IsNullOrWhiteSpace(filters.Search))
        {
            var term = filters.Search.Trim().ToLower();
            query = query.Where(a => (a.Task != null && a.Task.Title.ToLower().Contains(term)) ||
                                     (a.Task != null && a.Task.Project != null && a.Task.Project.Name.ToLower().Contains(term)) ||
                                     (a.Employee != null && (a.Employee.FirstName.ToLower().Contains(term) || a.Employee.LastName.ToLower().Contains(term))));
        }

        if (!string.IsNullOrWhiteSpace(filters.Status) && !filters.Status.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            if (filters.Status.Equals("todo", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(a => a.Task != null && a.Task.Stage == "Not Started" && a.TimerStartedAtUtc == null);
            }
            else if (filters.Status.Equals("in_progress", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(a => a.Task != null && (a.Task.Stage == "Ongoing" || a.TimerStartedAtUtc != null || a.TimerAccumulatedSeconds > 0));
            }
            else if (filters.Status.Equals("done", StringComparison.OrdinalIgnoreCase))
            {
                query = query.Where(a => a.Task != null && a.Task.Stage == "Completed");
            }
        }

        var allAssignments = await query.ToListAsync(ct);
        var now = DateTime.UtcNow;
        var today = DateOnly.FromDateTime(now);
        var maxDailySeconds = (long)(_maxDailyWorkingHours * 3600m);

        var dtoList = new List<BucketTaskDto>();
        var needsDbSave = false;

        foreach (var a in allAssignments)
        {
            if (a.Task == null) continue;

            // Check & apply 8.5-hour daily office working duration auto-pause rule
            if (a.TimerStartedAtUtc.HasValue)
            {
                var runningSeconds = (long)(now - a.TimerStartedAtUtc.Value).TotalSeconds;
                if (runningSeconds >= maxDailySeconds)
                {
                    // Track capped working time and pause timer
                    var trackedEntity = await db.ProjectTaskAssignments.FindAsync([a.Id], ct);
                    if (trackedEntity != null)
                    {
                        trackedEntity.TimerAccumulatedSeconds += maxDailySeconds;
                        trackedEntity.TimerStartedAtUtc = null;
                        trackedEntity.UtilizedHours = Math.Round((decimal)trackedEntity.TimerAccumulatedSeconds / 3600m, 2);
                        needsDbSave = true;
                    }

                    a.TimerAccumulatedSeconds += maxDailySeconds;
                    a.TimerStartedAtUtc = null;
                    a.UtilizedHours = Math.Round((decimal)a.TimerAccumulatedSeconds / 3600m, 2);
                }
            }

            var isRunning = a.TimerStartedAtUtc.HasValue;
            var elapsedSecs = a.TimerAccumulatedSeconds;
            if (isRunning)
            {
                var curRunningSecs = (long)(now - a.TimerStartedAtUtc!.Value).TotalSeconds;
                elapsedSecs += Math.Max(0, Math.Min(curRunningSecs, maxDailySeconds));
            }

            var isCompleted = a.Task.Stage.Equals("Completed", StringComparison.OrdinalIgnoreCase);
            var isOverdue = a.Task.PlannedEndDate.HasValue && a.Task.PlannedEndDate.Value < today && !isCompleted;

            string status;
            if (isCompleted)
            {
                status = "Completed";
            }
            else if (isRunning)
            {
                status = "Ongoing";
            }
            else if (a.TimerAccumulatedSeconds > 0)
            {
                status = "Paused";
            }
            else
            {
                status = "Not Started";
            }

            // Estimate and remaining effort calculations
            var estHours = a.AllocatedHours ?? a.Task.EstimatedHours ?? 0m;
            var utilHours = a.UtilizedHours > 0 ? a.UtilizedHours : Math.Round((decimal)elapsedSecs / 3600m, 2);
            var remHours = Math.Round(estHours - utilHours, 2); // Can be negative indicating effort overrun

            // Filter by search query (Task Title, Project Name, Project Code)
            if (!string.IsNullOrWhiteSpace(filters.Search))
            {
                var term = filters.Search.Trim().ToLowerInvariant();
                var matches = (a.Task.Title ?? "").ToLowerInvariant().Contains(term) ||
                              (a.Task.Project?.Name ?? "").ToLowerInvariant().Contains(term) ||
                              (a.Task.Project?.ProjectCode ?? "").ToLowerInvariant().Contains(term);
                if (!matches) continue;
            }

            // Filter by status tab
            if (!string.IsNullOrWhiteSpace(filters.Status) && !filters.Status.Equals("all", StringComparison.OrdinalIgnoreCase))
            {
                var filterStatus = filters.Status.ToLowerInvariant();
                if (filterStatus == "todo" && status != "Not Started") continue;
                if (filterStatus == "in_progress" && status != "Ongoing" && status != "Paused") continue;
                if (filterStatus == "done" && status != "Completed") continue;
            }

            // Overdue filter
            if (filters.OverdueOnly == true && !isOverdue)
            {
                continue;
            }

            dtoList.Add(new BucketTaskDto(
                AssignmentId: a.Id,
                TaskId: a.TaskId,
                TaskTitle: a.Task.Title ?? "Task",
                ProjectId: a.Task.ProjectId,
                ProjectName: a.Task.Project?.Name ?? "Project",
                ProjectCode: a.Task.Project?.ProjectCode,
                Priority: a.Task.Priority,
                DueDate: a.Task.PlannedEndDate,
                IsOverdue: isOverdue,
                Status: status,
                EmployeeId: a.EmployeeId,
                EmployeeName: a.Employee != null ? $"{a.Employee.FirstName} {a.Employee.LastName}".Trim() : "Assigned Member",
                AssignedByName: a.Task.Project?.ProjectManager != null ? $"{a.Task.Project.ProjectManager.FirstName} {a.Task.Project.ProjectManager.LastName}".Trim() : "Project Manager",
                StartedAtUtc: a.Task.ActualStartDate.HasValue ? a.Task.ActualStartDate.Value.ToDateTime(TimeOnly.MinValue) : null,
                CompletedAtUtc: a.Task.ActualEndDate.HasValue ? a.Task.ActualEndDate.Value.ToDateTime(TimeOnly.MinValue) : null,
                ElapsedSeconds: elapsedSecs,
                IsTimerRunning: isRunning,
                TimerStartedAtUtc: a.TimerStartedAtUtc,
                EstimatedHours: estHours,
                UtilizedHours: utilHours,
                RemainingHours: remHours
            ));
        }

        if (needsDbSave)
        {
            await db.SaveChangesAsync(ct);
        }

        // Apply sorting: Overdue first, then Ongoing, then Due Date ascending
        var sorted = dtoList
            .OrderByDescending(d => d.IsOverdue)
            .ThenByDescending(d => d.IsTimerRunning)
            .ThenBy(d => d.DueDate ?? DateOnly.MaxValue)
            .ToList();

        var page = Math.Max(1, filters.Page);
        var perPage = Math.Clamp(filters.PerPage, 1, 100);
        var total = sorted.Count;
        var pagedItems = sorted.Skip((page - 1) * perPage).Take(perPage).ToList();

        return new PagedResult<BucketTaskDto>(pagedItems, page, perPage, total);
    }

    public async Task<TimerActionResponseDto> StartTimerAsync(Guid assignmentId, CancellationToken ct = default)
    {
        var assignment = await db.ProjectTaskAssignments
            .Include(a => a.Task)
            .Include(a => a.Employee)
            .FirstOrDefaultAsync(a => a.Id == assignmentId && a.IsActive, ct)
            ?? throw new NotFoundException($"Task assignment with ID '{assignmentId}' was not found.");

        ValidateAssignmentOwnership(assignment);

        if (assignment.Task == null)
            throw new ConflictException("Task details not found for this assignment.");

        if (assignment.Task.Stage.Equals("Completed", StringComparison.OrdinalIgnoreCase))
            throw new ConflictException("Cannot start a timer on a completed task.");

        var now = DateTime.UtcNow;

        // Conflict Prevention: Automatically pause any other active running timer for this employee
        var conflictingActive = await db.ProjectTaskAssignments
            .Where(a => a.EmployeeId == assignment.EmployeeId && a.Id != assignmentId && a.TimerStartedAtUtc != null && a.IsActive)
            .ToListAsync(ct);

        foreach (var other in conflictingActive)
        {
            var otherElapsed = (long)(now - other.TimerStartedAtUtc!.Value).TotalSeconds;
            other.TimerAccumulatedSeconds += Math.Max(0, otherElapsed);
            other.TimerStartedAtUtc = null;
            other.UtilizedHours = Math.Round((decimal)other.TimerAccumulatedSeconds / 3600m, 2);
        }

        // Start timer for this assignment
        if (!assignment.TimerStartedAtUtc.HasValue)
        {
            assignment.TimerStartedAtUtc = now;

            // Sync with Projects module: Advance task stage from Ready to Start / Not Started to Ongoing
            if (assignment.Task.Stage.Equals("Ready to Start", StringComparison.OrdinalIgnoreCase) ||
                assignment.Task.Stage.Equals("Not Started", StringComparison.OrdinalIgnoreCase))
            {
                assignment.Task.Stage = "Ongoing";
                assignment.Task.ActualStartDate ??= DateOnly.FromDateTime(now);
            }

            await db.SaveChangesAsync(ct);
        }

        var totalSeconds = assignment.TimerAccumulatedSeconds + (long)(now - assignment.TimerStartedAtUtc.Value).TotalSeconds;
        var utilized = Math.Round((decimal)totalSeconds / 3600m, 2);

        return new TimerActionResponseDto(
            AssignmentId: assignment.Id,
            TaskId: assignment.TaskId,
            EmployeeId: assignment.EmployeeId,
            Status: "Ongoing",
            IsTimerRunning: true,
            TimerStartedAtUtc: assignment.TimerStartedAtUtc,
            TotalAccumulatedSeconds: totalSeconds,
            UtilizedHours: utilized,
            Message: "Timer started successfully."
        );
    }

    public async Task<TimerActionResponseDto> PauseTimerAsync(Guid assignmentId, CancellationToken ct = default)
    {
        var assignment = await db.ProjectTaskAssignments
            .Include(a => a.Task)
            .FirstOrDefaultAsync(a => a.Id == assignmentId && a.IsActive, ct)
            ?? throw new NotFoundException($"Task assignment with ID '{assignmentId}' was not found.");

        ValidateAssignmentOwnership(assignment);

        var now = DateTime.UtcNow;
        var maxDailySeconds = (long)(_maxDailyWorkingHours * 3600m);

        if (assignment.TimerStartedAtUtc.HasValue)
        {
            var elapsed = (long)(now - assignment.TimerStartedAtUtc.Value).TotalSeconds;
            // Cap to daily office maximum if user forgot to pause
            var cappedElapsed = Math.Min(Math.Max(0, elapsed), maxDailySeconds);

            assignment.TimerAccumulatedSeconds += cappedElapsed;
            assignment.TimerStartedAtUtc = null;
            assignment.UtilizedHours = Math.Round((decimal)assignment.TimerAccumulatedSeconds / 3600m, 2);

            // Synchronize task overall utilized hours
            if (assignment.Task != null)
            {
                var otherTotal = await db.ProjectTaskAssignments
                    .Where(a => a.TaskId == assignment.TaskId && a.Id != assignmentId)
                    .SumAsync(a => a.UtilizedHours, ct);

                assignment.Task.UtilizedHours = otherTotal + assignment.UtilizedHours;
            }

            await db.SaveChangesAsync(ct);
        }

        return new TimerActionResponseDto(
            AssignmentId: assignment.Id,
            TaskId: assignment.TaskId,
            EmployeeId: assignment.EmployeeId,
            Status: "Paused",
            IsTimerRunning: false,
            TimerStartedAtUtc: null,
            TotalAccumulatedSeconds: assignment.TimerAccumulatedSeconds,
            UtilizedHours: assignment.UtilizedHours,
            Message: "Timer paused successfully."
        );
    }

    public async Task<TimerActionResponseDto> ResumeTimerAsync(Guid assignmentId, CancellationToken ct = default)
    {
        return await StartTimerAsync(assignmentId, ct);
    }

    public async Task<TimerActionResponseDto> CompleteTaskAsync(Guid assignmentId, CancellationToken ct = default)
    {
        var assignment = await db.ProjectTaskAssignments
            .Include(a => a.Task)
            .FirstOrDefaultAsync(a => a.Id == assignmentId && a.IsActive, ct)
            ?? throw new NotFoundException($"Task assignment with ID '{assignmentId}' was not found.");

        ValidateAssignmentOwnership(assignment);

        var now = DateTime.UtcNow;

        // If timer is still running, freeze and accumulate time
        if (assignment.TimerStartedAtUtc.HasValue)
        {
            var elapsed = (long)(now - assignment.TimerStartedAtUtc.Value).TotalSeconds;
            var maxDailySeconds = (long)(_maxDailyWorkingHours * 3600m);
            var cappedElapsed = Math.Min(Math.Max(0, elapsed), maxDailySeconds);

            assignment.TimerAccumulatedSeconds += cappedElapsed;
            assignment.TimerStartedAtUtc = null;
            assignment.UtilizedHours = Math.Round((decimal)assignment.TimerAccumulatedSeconds / 3600m, 2);
        }

        // Check sibling assignments for the task
        if (assignment.Task != null)
        {
            var siblingAssignments = await db.ProjectTaskAssignments
                .Where(a => a.TaskId == assignment.TaskId && a.IsActive)
                .ToListAsync(ct);

            // Recompute task utilized hours
            assignment.Task.UtilizedHours = siblingAssignments.Sum(a => a.UtilizedHours);

            // Mark task stage completed if this is the only or last assignee completing
            assignment.Task.Stage = "Completed";
            assignment.Task.ActualEndDate ??= DateOnly.FromDateTime(now);
            assignment.Task.Progress = 100;
        }

        await db.SaveChangesAsync(ct);

        return new TimerActionResponseDto(
            AssignmentId: assignment.Id,
            TaskId: assignment.TaskId,
            EmployeeId: assignment.EmployeeId,
            Status: "Completed",
            IsTimerRunning: false,
            TimerStartedAtUtc: null,
            TotalAccumulatedSeconds: assignment.TimerAccumulatedSeconds,
            UtilizedHours: assignment.UtilizedHours,
            Message: "Task completed successfully."
        );
    }

    private async Task<Employee?> ResolveTargetEmployeeAsync(string? requestedEmployeeId, CancellationToken ct)
    {
        // 1. If caller specifies an employee ID, code, or email:
        if (!string.IsNullOrWhiteSpace(requestedEmployeeId) && !requestedEmployeeId.Equals("all", StringComparison.OrdinalIgnoreCase))
        {
            var req = requestedEmployeeId.Trim();
            if (Guid.TryParse(req, out var empGuid))
            {
                var byId = await db.Employees
                    .FirstOrDefaultAsync(e => e.Id == empGuid && e.DeletedAtUtc == null, ct);
                if (byId != null) return byId;
            }

            var byCodeOrEmail = await db.Employees
                .FirstOrDefaultAsync(e =>
                    (e.EmployeeCode.ToLower() == req.ToLower() ||
                     e.WorkEmail.ToLower() == req.ToLower()) &&
                    e.DeletedAtUtc == null, ct);
            if (byCodeOrEmail != null) return byCodeOrEmail;
        }

        // 2. Otherwise resolve caller's own employee record
        var currentUserId = currentUser.UserId;
        var currentUserEmail = currentUser.Email;

        Employee? employee = null;
        if (currentUserId.HasValue)
        {
            employee = await db.Employees
                .FirstOrDefaultAsync(e => (e.Id == currentUserId.Value || e.UserId == currentUserId.Value) && e.DeletedAtUtc == null, ct);
        }

        if (employee == null && !string.IsNullOrWhiteSpace(currentUserEmail))
        {
            var normEmail = currentUserEmail.Trim().ToLowerInvariant();
            employee = await db.Employees
                .FirstOrDefaultAsync(e => e.WorkEmail.ToLower() == normEmail && e.DeletedAtUtc == null, ct);
        }

        return employee;
    }

    private void ValidateAssignmentOwnership(ProjectTaskAssignment assignment)
    {
        var role = currentUser.Role ?? string.Empty;
        var isPrivileged = role.Contains("Admin", StringComparison.OrdinalIgnoreCase) ||
                           role.Contains("Manager", StringComparison.OrdinalIgnoreCase) ||
                           role.Contains("Leader", StringComparison.OrdinalIgnoreCase) ||
                           role.Contains("Lead", StringComparison.OrdinalIgnoreCase) ||
                           role.Contains("PMO", StringComparison.OrdinalIgnoreCase);
        if (isPrivileged) return;

        // Non-admin can only operate on their own task timer
        var currentUserId = currentUser.UserId;
        var currentUserEmail = currentUser.Email?.Trim().ToLowerInvariant();

        var callerOwnsTask = assignment.Employee != null &&
            ((currentUserId.HasValue && assignment.Employee.UserId == currentUserId.Value) ||
             (!string.IsNullOrEmpty(currentUserEmail) && assignment.Employee.WorkEmail.ToLower() == currentUserEmail));

        // If not directly resolved on employee relation, verify via DB lookup
        if (!callerOwnsTask)
        {
            var userEmpId = db.Employees
                .Where(e => (currentUserId.HasValue && e.UserId == currentUserId.Value) ||
                            (!string.IsNullOrEmpty(currentUserEmail) && e.WorkEmail.ToLower() == currentUserEmail))
                .Select(e => e.Id)
                .FirstOrDefault();

            if (userEmpId != Guid.Empty && userEmpId != assignment.EmployeeId)
            {
                throw new ForbiddenException("You cannot start, pause, or complete tasks assigned to another team member.");
            }
        }
    }
}
