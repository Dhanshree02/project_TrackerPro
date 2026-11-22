using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.MyTeam.DTOs;
using PMS.API.Modules.MyTeam.Services;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.MyTeam.Controllers;

[ApiController]
[Route("api/v1/my-team")]
public class MyTeamController(
    IMyTeamService myTeam,
    IRbacAuthorizationService rbacService,
    ITeamAvailabilityNotificationService notificationService) : ControllerBase
{
    [HttpGet("on-floor-roles")]
    [RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.View, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees, RbacCatalogCodes.MyTeamTab, "6055ce3c-b466-4354-ba9a-b4c309111e9d")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<string>>>> OnFloorRoles(CancellationToken ct = default)
    {
        return Ok(ApiResponse<IReadOnlyList<string>>.Ok(await myTeam.GetOnFloorRoleNamesAsync(ct)));
    }

    [HttpGet("calendar")]
    [RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.View, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees, RbacCatalogCodes.MyTeamTab, "6055ce3c-b466-4354-ba9a-b4c309111e9d")]
    public async Task<ActionResult<ApiResponse<TeamCalendarDto>>> Calendar(
        [FromQuery] DateOnly from,
        [FromQuery] DateOnly to,
        [FromQuery] bool all = false,
        [FromQuery] string? scope = null,
        CancellationToken ct = default)
    {
        var normalizedScope = (scope ?? (all ? "all" : null))?.Trim().ToLowerInvariant();
        var targetCode = normalizedScope switch
        {
            "all" => RbacCatalogCodes.AllEmployees,
            "reportees" => RbacCatalogCodes.MyReportees,
            _ => RbacCatalogCodes.MyTeamTab
        };
        var hasSpecific = await rbacService.HasAccessAsync(User, targetCode, RbacAccessType.View, ct);
        var hasDashboard = await rbacService.HasAccessAsync(User, RbacCatalogCodes.TeamDashboard, RbacAccessType.View, ct) ||
                           await rbacService.HasAccessAsync(User, "6055ce3c-b466-4354-ba9a-b4c309111e9d", RbacAccessType.View, ct);
        if (!hasSpecific && !hasDashboard)
        {
            return StatusCode(StatusCodes.Status403Forbidden, ApiResponse<TeamCalendarDto>.Fail("FORBIDDEN", "You do not have permission to view this roster."));
        }

        return Ok(ApiResponse<TeamCalendarDto>.Ok(await myTeam.GetCalendarAsync(from, to, all, normalizedScope, ct)));
    }

    [HttpPut("days")]
    [RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.View, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees, RbacCatalogCodes.MyTeamTab)]
    public async Task<ActionResult<ApiResponse<bool>>> UpsertDays(
        [FromBody] UpsertTeamDaysRequest request,
        CancellationToken ct)
    {
        await myTeam.UpsertDaysAsync(request, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpPut("members/{employeeId:guid}/schedule")]
    [RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.View, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees, RbacCatalogCodes.MyTeamTab)]
    public async Task<ActionResult<ApiResponse<bool>>> SaveSchedule(
        Guid employeeId,
        [FromBody] SaveTeamScheduleRequest request,
        CancellationToken ct)
    {
        await myTeam.SaveScheduleAsync(employeeId, request, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpPost("notifications/trigger-2hour-reminders")]
    [RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.Manage, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees)]
    public async Task<ActionResult<ApiResponse<int>>> TriggerTwoHourReminders(
        [FromQuery] DateOnly? date = null,
        CancellationToken ct = default)
    {
        var count = await notificationService.SendReportingManagerTwoHourRemindersAsync(date, ct);
        return Ok(ApiResponse<int>.Ok(count));
    }

    [HttpPost("notifications/trigger-leadership-alerts")]
    [RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.Manage, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees)]
    public async Task<ActionResult<ApiResponse<int>>> TriggerLeadershipAlerts(
        [FromQuery] int hour = 11,
        [FromQuery] DateOnly? date = null,
        CancellationToken ct = default)
    {
        var count = await notificationService.SendProjectLeadershipDailyAlertAsync(hour, date, ct);
        return Ok(ApiResponse<int>.Ok(count));
    }

    [HttpPost("notifications/trigger-spm-alerts")]
    [RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.Manage, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees)]
    public async Task<ActionResult<ApiResponse<int>>> TriggerSpmAlerts(
        [FromQuery] DateOnly? date = null,
        CancellationToken ct = default)
    {
        var count = await notificationService.SendSpmDailyAlertAsync(date, ct);
        return Ok(ApiResponse<int>.Ok(count));
    }

    [HttpPost("notifications/trigger-hod-escalations")]
    [RequireRbac(RbacCatalogCodes.TeamDashboard, RbacAccessType.Manage, RbacCatalogCodes.MyReportees, RbacCatalogCodes.AllEmployees)]
    public async Task<ActionResult<ApiResponse<int>>> TriggerHodEscalations(
        [FromQuery] DateOnly? date = null,
        CancellationToken ct = default)
    {
        var count = await notificationService.SendHodNextDayEodEscalationAsync(date, ct);
        return Ok(ApiResponse<int>.Ok(count));
    }
}
