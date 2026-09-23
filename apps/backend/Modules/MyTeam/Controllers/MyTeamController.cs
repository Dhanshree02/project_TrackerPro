using Microsoft.AspNetCore.Mvc;
using PMS.API.Infrastructure.Authorization;
using PMS.API.Modules.MyTeam.DTOs;
using PMS.API.Modules.MyTeam.Services;
using PMS.API.Shared.Common.Wrappers;
using PMS.API.Shared.Constants;

namespace PMS.API.Modules.MyTeam.Controllers;

[ApiController]
[Route("api/v1/my-team")]
public class MyTeamController(IMyTeamService myTeam) : ControllerBase
{
    [HttpGet("calendar")]
    [RequirePermission(Permissions.MyTeamDashboardView)]
    public async Task<ActionResult<ApiResponse<TeamCalendarDto>>> Calendar(
        [FromQuery] DateOnly from,
        [FromQuery] DateOnly to,
        CancellationToken ct)
    {
        return Ok(ApiResponse<TeamCalendarDto>.Ok(await myTeam.GetCalendarAsync(from, to, ct)));
    }

    [HttpPut("days")]
    [RequirePermission(Permissions.MyTeamDashboardView)]
    public async Task<ActionResult<ApiResponse<bool>>> UpsertDays(
        [FromBody] UpsertTeamDaysRequest request,
        CancellationToken ct)
    {
        await myTeam.UpsertDaysAsync(request, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }

    [HttpPut("members/{employeeId:guid}/schedule")]
    [RequirePermission(Permissions.MyTeamDashboardView)]
    public async Task<ActionResult<ApiResponse<bool>>> SaveSchedule(
        Guid employeeId,
        [FromBody] SaveTeamScheduleRequest request,
        CancellationToken ct)
    {
        await myTeam.SaveScheduleAsync(employeeId, request, ct);
        return Ok(ApiResponse<bool>.Ok(true));
    }
}
